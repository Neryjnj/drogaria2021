#INCLUDE "AUTOCOM.CH"  
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "AUTODEF.CH"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Classe    ≥ Autocom     ≥ Autor ≥ Cesar Valadao      ≥ Data ≥ 23/09/04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Classe de comunicacao com os perifericos atraves da        ≥±±
±±≥          ≥ autocom.dll (Windows) ou autocom.so (Linux)                ≥±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Analista  ≥ Data   ≥BOPS  ≥Manutencao Efetuada                      	  ∫±±
±±πÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Thiago H. ≥25/05/06≥99106 ≥- Caso o sistema nao encontre os arquivos   ∫±±
±±∫          ≥        ≥      ≥autocom.dll(WINDOWS) ou libautocom.so(LINUX)∫±±
±±∫          ≥        ≥      ≥eh permitido entrar no sistema mas nao eh   ∫±±
±±∫          ≥        ≥      ≥listado os perifericos no cadastro de       ∫±±
±±∫          ≥        ≥      ≥estacao.                                    ∫±±
±±∫Mauro S.  ≥07/02/07≥118140≥Feita homologacao da Sweda 9000I Versao 1.7 ∫±±
±±∫Thiago H. ≥07/02/07≥188810≥- Alterado o METHOD New() para adicioar o   ∫±±
±±∫          ≥        ≥      ≥modelo Gaveta MEMMO no array aLstGaveta	  ∫±± 
±±∫Thiago H. ≥07/02/07≥118810≥Alterado o metodo IFAbrCNFis()para impressao∫±±
±±∫          ≥        ≥      ≥correta do numero de parcelas no CUPOM NAO  ∫±±
±±∫          ≥        ≥      ≥FISCAL.                                     ∫±±
±±∫Machima   ≥17/03/07≥104919≥Homologacao do ECF 'EPSON TM-U220' para o   ∫±±
±±∫(Cesar)   ≥        ≥      ≥Mexico e da balanca 'PSC Magellan 8100'     ∫±±
±±∫Mauro S.  ≥20/04/07≥124739≥Corrigida chamada da StrTranf da FormataData∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
CLASS Autocom
	DATA lAtivo
	DATA nHandle
	DATA cPlataforma
	DATA cBuffer
	DATA cDLLName
    DATA Aliquotas
    DATA ICMS     
    DATA ISS      
    DATA FormasPgto
    DATA Pdv       
    DATA NumCaixa  

	DATA oImpFisc
	DATA aImpFisc
	DATA nImpFisc

    DATA oGaveta
	DATA aLstGaveta
	DATA nGaveta

    DATA oCheque
	DATA aLstCheque
	DATA nCheque

    DATA oPinPad
	DATA aLstPinPad
	DATA nPinPad   
	
    DATA oLeitor
	DATA aLstLeitor
	DATA nLeitor

    DATA oBalanca
	DATA aLstBalanca
	DATA nBalanca

    DATA oImpCup
	DATA aLstImpCup
	DATA nImpCup

    DATA oCMC7
	DATA aLstCMC7
	DATA nCMC7

    DATA oDisplay
	DATA aLstDisplay
	DATA nDisplay

	METHOD New       ()
	METHOD IFListar  ()
	METHOD IFAbrir   (cModelo, cPorta)
	METHOD IFFechar  (cPorta)
	METHOD IFLeituraX()
	METHOD IFAbrECF  ()
	METHOD IFStatus  (cTipo)
	METHOD IFPegPDV  ()
	METHOD IFPegCupom(cCancelamento)
	METHOD IFPegSerie()
	METHOD IFReducaoZ(cMapaRes)
	METHOD IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade )
	METHOD IFLeAliq  ()
	METHOD IFLeAliIss()
	METHOD IFLeConPag()
	METHOD IFGrvCondP(cCondicao)
	METHOD IFCancItem(cNumitem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota , cSupervisor, lImpIncl)
	METHOD IFCancCup (cSupervisor)
	METHOD IFFechaCup(cMensagem , cVlrTotal)
	METHOD IFPagto   (cPagto, cVinculado)
	METHOD IFDescTot (cVlrDesconto , cValorVenda)
	METHOD IFAcresTot(cVlrAcrescimo)
	METHOD IFMemFisc (cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)
	METHOD IFAdicAliq(cAliquota, cTipo)
	METHOD IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto, nParcelas)
	METHOD IFTxtNFis (cTexto, cVias)
	METHOD IFFchCNFis()
	METHOD IFTotNFis(cNumero, cDescricao)
	METHOD IFAutentic(cVezes, cValor, cTexto)
	METHOD IFGaveta  ()
	METHOD IFFchECF	 ()
	METHOD IFSupr	 (nTipo, cValor, cForma, cTotal, cModo)
	METHOD IFReImpCNF(cTexto)
	METHOD IFAbreCup (cCliente)
	METHOD IFHorVerao(cTipo)
	METHOD IFRelGer  (cTexto, nVias)
	METHOD IFAlimProp(cNumPdv, cNumCaixa, cNomeCaixa, cNumCupom)
	METHOD IFSubTotal(cImprime)
	METHOD IFNumItem ()
	METHOD IFImposCup()
	METHOD IFPedido  (cTEF, cTexto, cValor, cCondPgTEF)
	METHOD IFRecbNFis(cTotalizador, cValor, cForma)
	METHOD IFReImprim()
	METHOD IFPercepca(cAliqIVA, cTexto, cValor)
	METHOD IFAbreDNFH(cTipoDoc, cDadosCli, cDadosCab, cDocOri)
	METHOD IFFechDNFH()
	METHOD IFTxtRecib(cTexto)
	METHOD IFDownMFD( cTipo, cInicio, cFinal )
	METHOD IFMemTrab ()
	METHOD IFCapacity()
	METHOD IFAbreNota(cCliente)   
	METHOD IFGerRegTipoE( cTipo, cInicio, cFinal, cRazao, cEnd, cBinario )	
	METHOD IFHrVerao( cTipo )
	METHOD ImpCheque (cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso)
	METHOD GavetaLis ()
	METHOD GavetaAbr (cModelo, cPorta)
	METHOD GavetaAci (cPorta)	
	METHOD GavetaFec ()
	METHOD CHListar	 ()
	METHOD CHStatus  (cTipo)
	METHOD CHAbrir	 (cModelo, cPorta)
	METHOD CHImprime (cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela)
	METHOD CHFechar	 (cPorta)
	METHOD PinpadLis ()
	METHOD PinpadAbr (cModelo, cPorta)
	METHOD PinpadLeC (cModalidade)
	METHOD PinpadFin ()
	METHOD LeitorLis ()
	METHOD LeitorAbr (cModelo, cPorta, cFoco)
	METHOD LeitorFec (cPorta)
	METHOD LeitorFoco(lModo)
	METHOD Tef_Banorte(cNumCart, cNomeCli, cSenha, cClientID, cPipeline, cMode, cTransType, cCartao, cDatVenc, cOrderId, cTotal)
	METHOD BalancaLis()
	METHOD BalancaAbr(cModelo, cPorta)
	METHOD BalancaFec()
	METHOD BalancaPegaPeso()
	METHOD ImpCupLis ()
	METHOD CMC7Lis   ()
	METHOD DisplayLis()
	METHOD IFDownMF()
	METHOD IFRedZDado(cBuffer)
	METHOD ComAberta()
	METHOD Finish()

	// Metodos especificos da DLL CliSiTEF32I
	METHOD SIT_CONF  (cEnderecoIP, cCodLoja, cNumTerm, nConfRes)
	METHOD SIT_CONFEX(cEnderecoIP, cCodLoja, cNumTerm, nConfRes, cParamAdic)
	METHOD SIT_INICIA(nFuncao, nValor, cCupom, dData, cHora, cOperador, cRestric)
	METHOD SIT_CONTIN(nProxComan, nTipoCampo, nTamMin, nTamMax, cBuffer, nTamMaxBuffer, nContNaveg)
	METHOD SIT_FINAL (nConfirma, cNumCFis, cData, cHora)
	METHOD SIT_CORRES(cCupom, dData, cHora, cOperador, cRestric )
	METHOD SIT_VLDBAR(pMensagem, pTipo)
	METHOD SIT_VERPIN()
	METHOD SIT_MSNPIN(pMensagem)
	METHOD SIT_VDLCON(cCodigoAutorizacao, cCodigoProduto, cCuponFiscal, cDataFiscal, cHorario, cOperador)
	METHOD SIT_VDLPRO(nIndiceProduto, cCodigoProduto, nQuantidade, cValorVenda)
	METHOD SIT_VDLVEN(cCodigoAutorizacao, nNumeroProdutos, cCuponFiscal, cDataFiscal, cHorario, cOperador)
	METHOD SIT_VDLCAN(nParcialTotal, cCuponFiscal, cDataFiscal, cHorario, cOperador)
	METHOD SIT_LECART(pMensagem, pTrilha1, pTrilha2)
	METHOD SIT_LESENH(pParam, pSenha)
	METHOD SIT_CANCLE()
	METHOD SIT_LSNPIN(pMensagem)
	METHOD SIT_ENVDIR(	nRedeDestino	, nFuncaoSitef	, nOffSetCartao	, cDadosTx			, ;
						nTamDadosTx		, cDadosRx		, nTamMaxDadosRx, nCodigoResposta 	, ;
						nTempoEsperaRx 	, cCupomFiscal 	, cDataFiscal	, cHorario 			, ;
						cOperador 		, nTipoTransacao )
	METHOD SIT_OBTQTR(cDataFiscal, cCupomFiscal)
	METHOD SIT_DIGCPF(cMensagem, cSaida )
	METHOD SIT_VERDLL()
	METHOD VSProtheus()
ENDCLASS

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Metodo    ≥ New         ≥ Autor ≥ Cesar Valadao      ≥ Data ≥ 09/08/04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Inicializa o objeto TEF                                    ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
METHOD New() CLASS Autocom
Local lRet 		:= .T.
Local lPOS		:= STFIsPOS()
Local lIsRmt64	:= If(ExistFunc("IsRmt64"), IsRmt64(), .F.)
Local cBuffer 	:= Space(20)
Local cEadvplDll:= "" 				//Caminho da AdvplCe.dll
Local cClientDir:= GetClientdir()
Local cNomeDLL	:= "autocom.dll"

//-------------------------------------
//| O retorno da funcao GetRemoteType |
//| -1 - Job (Sem Remote)             |
//|  0 - Remote Delphi                |
//|  1 - Remote QT                    |
//|  2 - Remote UNIX/LINUX            |
//|  5 - HTML                         |
//-------------------------------------
If GetRemoteType() == REMOTE_LINUX
	::cPlataforma	:= "LINUX"
Else
	::cPlataforma	:= "WINDOWS"
EndIf

//------------------------------------------------------------------------------
//| !!! IMPORTANTE !!!                                                         |
//| Todos os equipamentos homologados que possuam equivalentes na SIGALOJA.DLL |
//| devem OBRIGATORIAMENTE ter EXATAMENTE o mesmo nome.                        |
//------------------------------------------------------------------------------
//CONTEUDO DA POSICAO ::aImpFisc[X][4] DO ARRAY -> CODIGO DO ECF RELATIVO A TABELA DA SECRETARIA DA FAZENDA
::aImpFisc		:= {{"IBM 4610"							, "MEX", "LJIBM4610"    , "180101"},;
					{"EPSON TM-U220"					, "MEX", "LJIBM4610"    , " "}}
                
If (!lIsRmt64) .And. (GetRemoteType() == REMOTE_LINUX)
	AAdd(::aImpFisc, {"SWEDA IFS V1.00"					, "BRA", "LJSweda"      , " "})
	AAdd(::aImpFisc, {"SWEDA IFS 9000 V1.0"				, "BRA", "LJSweda9000"  , " "})
	AAdd(::aImpFisc, {"SWEDA IFS 9000I V1.7"			, "BRA", "LJSweda9000"  , "381102"})
	AAdd(::aImpFisc, {"SWEDA IF ST120 - Swedanix"		, "BRA", "LJSwedaTER"	, "382001"})
	AAdd(::aImpFisc, {"SWEDA IF ST120 - V. 01.00.01"	, "BRA", "LJSwedaST"	, "382001"})
EndIf

If !lPOS .AND. File(cClientDir+"ecfemul.ini")	
	AAdd(::aImpFisc, {"ECF Emulator"				, "MEX", "LJECFEmulator", " "})
	AAdd(::aImpFisc, {"ECF Emulator"				, "BRA", "LJECFEmulator", " "})
EndIf

::aLstCheque	:= {{"IBM 4610",			"MEX", "LJIBM4610"}}
If File(cClientDir+"ecfemul.ini")
	AAdd(::aLstCheque, {"ECF Emulator",		"   ", "LJECFEmulator"})
EndIf

::aLstGaveta	:= {{"IBM 4610",			"MEX", "IBMGAV4610"},;
					 {"MEMMO",				"BRA", "IBMGAV4610"}}

::aLstPinPad	:= {{"IBM 54P8790",			"MEX", "LJIBM4610"}}

::aLstLeitor	:= {{"Metrolog MS9520",		"MEX", "AutLeitor"}}

::aLstBalanca	:= {{"Metrolog MS2020",		"MEX", "AutBalanca"},;
					{"CAS PD-II",			"MEX", "AutBalanca"},;
					{"PSC Magellan 8100",	"MEX", "AutBalanca"}}

::aLstImpCup	:= {{"                    ","   ", " "}};

::aLstCMC7		:= {{"                    ","   ", " "}};

::aLstDisplay	:= {{"                    ","   ", " "}};

::lAtivo := .F.

If ::cPlataforma == "WINDOWS"
	If lIsRmt64
		cNomeDLL := "autocom64.dll"
	EndIf
	
	::cDLLName 	:= cClientDir + cNomeDLL
	cEadvplDll	:= cClientDir + "advplce.dll"
Else
	::cDLLName := cClientDir+"libautocom.so"
EndIf

::nHandle := ExecInDLLOpen(::cDLLName)
If ::nHandle == -1
	// "Erro ao abrir " ### "Verifique se " ### "ou" ### "estao presentes no diretÛrio \BIN\REMOTE." 		
	Aviso (STR0001,STR0002 + ::cDLLName + STR0015 +  cEadvplDll + STR0016, {STR0004})			
	lRet := .F.
EndIf

If lRet
	nRet := ExeDLLRun2(::nHandle, 999, @cBuffer)
	cBuffer := Substr(cBuffer,1,At(Chr(0),cBuffer)-1)		// Elimina os Chr(0) finais
	LjxVldVrDLL(cBuffer,.T.,.F.)
	::lAtivo := .T.
Endif

Return .T.

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de Impressora Fiscal   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD IFListar() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aImpFisc[1][1]+'",'+::aImpFisc[1][2]+'","'+::aImpFisc[1][4]+"'
For nI := 2 To Len(::aImpFisc)
	::cBuffer += ',"'+::aImpFisc[nI][1]+'",'+::aImpFisc[nI][2]+'","'+::aImpFisc[nI][4]+"'
Next nI

Return 0

//-----------------------------------------------------------------------------
METHOD IFHrVerao( cTipo ) CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFHrVerao( cTipo ) 
EndIf
Return nRet

//-----------------------------------------------------------------------------
METHOD IFAbrir(cModelo, cPorta, nHdlMain) CLASS Autocom
Local nRet := -1
::nImpFisc := AScan(::aImpFisc, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nImpFisc <> 0
	::oImpFisc := &(::aImpFisc[::nImpFisc][3]+"():New()")
	nRet := ::oImpFisc:IFAbrir(cModelo, cPorta, nHdlMain)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFFechar(cPorta ) CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFFechar(cPorta)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFLeituraX() CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFLeituraX()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAbrECF() CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAbrECF()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFStatus(cTipo) CLASS Autocom
Local nRet := -1   
If ValType(::oImpFisc) == 'O'
	::cBuffer := ""
	nRet := ::oImpFisc:IFStatus(cTipo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPegPDV() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPegPDV()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPegCupom(cCancelamento) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPegCupom(cCancelamento)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPegSerie() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPegSerie() 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFReducaoZ(cMapaRes) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFReducaoZ(cMapaRes)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFLeAliq() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFLeAliq()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFLeAliIss() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFLeAliIss()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFLeConPag() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFLeConPag()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFGrvCondP(cCondicao) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFGrvCondP(cCondicao)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFCancItem(cNumitem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota, cSupervisor , lImpIncl ) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFCancItem(cNumitem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota, cSupervisor , lImpIncl)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFCancCup(cSupervisor) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFCancCup(cSupervisor)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFFechaCup(cMensagem , cVlrTotal) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFFechaCup(cMensagem , cVlrTotal)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFDescTot (cVlrDesconto, cValorVenda) CLASS Autocom
Local nRet := -1 
DEFAULT cValorVenda := Nil 
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFDescTot(cVlrDesconto, cValorVenda)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAcresTot(cVlrAcrescimo) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAcresTot(cVlrAcrescimo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFMemFisc(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'    
    cTipo := IIF( 'I' $ Upper(cTipo), 'I', 'D')
	nRet := ::oImpFisc:IFMemFisc(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAdicAliq(cAliquota, cTipo) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAdicAliq(cAliquota, cTipo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto, nParcelas) CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto, nParcelas)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFTxtNFis(cTexto, nVias) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFTxtNFis(cTexto, nVias)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFFchCNFis() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFFchCNFis()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFTotNFis(cNumero, cDescricao) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFTotNFis(cNumero, cDescricao)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAutentic(cVezes, cValor, cTexto) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAutentic(cVezes, cValor, cTexto)
EndIf
Return(nRet)                                              

//-----------------------------------------------------------------------------
METHOD IFGaveta() CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFGaveta()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFFchECF() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFFchECF()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFSupr(nTipo, cValor, cForma, cTotal) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFSupr(nTipo, cValor, cForma, cTotal)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFReImpCNF(cTexto) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFReImpCNF(cTexto)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAbreCup(cCliente) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAbreCup(cCliente)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFHorVerao(cTipo) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFHorVerao(cTipo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFRelGer(cTexto,nVias) CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFRelGer(cTexto,nVias)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAlimProp(cNumPdv, cNumCaixa, cNomeCaixa, cNumCupom) CLASS Autocom
Local nRet := -1
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAlimProp(cNumPdv, cNumCaixa, cNomeCaixa, cNumCupom)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFSubTotal(cImprime)	CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFSubTotal(cImprime)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFNumItem() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFNumItem()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFImposCup() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFImposCup()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPedido(cTEF, cTexto, cValor, cCondPgTEF) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPedido(cTEF, cTexto, cValor, cCondPgTEF) 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFRecbNFis(cTotalizador, cValor, cForma)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFReImprim()	CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPedido(cTEF, cTexto, cValor, cCondPgTEF)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFPercepca(cAliqIVA, cTexto, cValor) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPercepca(cAliqIVA, cTexto, cValor)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFAbreDNFH(cTipoDoc, cDadosCli, cDadosCab, cDocOri) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFAbreDNFH(cTipoDoc, cDadosCli, cDadosCab, cDocOri) 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFFechDNFH() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFPercepca(cAliqIVA, cTexto, cValor)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFTxtRecib(cTexto) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFTxtRecib(cTexto) 
EndIf
Return(nRet)
//-----------------------------------------------------------------------------
METHOD IFDownMFD( cTipo, cInicio, cFinal ) CLASS Autocom
Local nRet := -1     
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFDownLoadMFD(cTipo,cInicio,cFinal) 
EndIf
Return( nRet )

//-----------------------------------------------------------------------------
METHOD IFGerRegTipoE( cTipo, cInicio, cFinal, cRazao, cEnd, cBinario ) CLASS Autocom
Local nRet := -1     
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFGeraRegTipoE(cTipo,cInicio,cFinal,cRazao,cEnd,cBinario) 
EndIf
Return nRet

//-----------------------------------------------------------------------------
METHOD IFMemTrab() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFMemTrab() 
EndIf
Return(nRet)    

//-----------------------------------------------------------------------------
METHOD IFCapacity() CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFCapacidd()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD ImpCheque(cBanco,cValor,cFavorec,cCidade,cData,cMensagem,cVerso,cExtenso) CLASS Autocom
Local nRet := -1  
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:ImpCheque(cBanco,cValor,cFavorec,cCidade,cData,cMensagem,cVerso,cExtenso) 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD IFDownMF() CLASS Autocom
Local nRet := -1     
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFDownMF() 
EndIf
Return( nRet )


//-----------------------------------------------------------------------------
METHOD IFRedZDado(cBuffer) CLASS Autocom
Local nRet := -1     
If ValType(::oImpFisc) == 'O'
	nRet := ::oImpFisc:IFDownMF() 
EndIf
Return( nRet )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de Gaveta			  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD GavetaLis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstGaveta[1][1]+'",'+::aLstGaveta[1][2]

For nI := 2 To Len(::aLstGaveta)
	::cBuffer += ',"'+::aLstGaveta[nI][1]+'",'+::aLstGaveta[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
METHOD GavetaAbr (cModelo, cPorta ) CLASS Autocom
Local nRet := -1
Local cTemp := ""
::nGaveta := AScan(::aLstGaveta, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nGaveta <> 0
	::oGaveta := &(::aLstGaveta[::nGaveta][3]+"():New()")
	nRet := ::oGaveta:GavetaAbr (cModelo, cPorta )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD GavetaAci(cPorta) CLASS Autocom
Local nRet := -1
If ValType(::oGaveta) == 'O'
	nRet := ::oGaveta:GavetaAci(cPorta)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD GavetaFec () CLASS Autocom
Local nRet := -1
If ValType(::oGaveta) == 'O'
	nRet := ::oGaveta:GavetaFec ()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes da Impressora de Cheque≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD CHListar() CLASS Autocom
Local nI := 0	//controle de loop

::cBuffer := '"'+::aLstCheque[1][1]+'",'+::aLstCheque[1][2]

For nI := 2 To Len(::aLstCheque)
	::cBuffer += ',"'+::aLstCheque[nI][1]+'",'+::aLstCheque[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
METHOD CHStatus(cTipo) CLASS Autocom
Local nRet := -1
If ValType(::oCheque) == 'O'
	nRet := ::oCheque:CHStatus(cTipo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD CHAbrir(cModelo, cPorta ) CLASS Autocom
Local nRet := -1
Local cTemp := ""
::nCheque := AScan(::aLstCheque, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nCheque <> 0
	::oCheque := &(::aLstCheque[::nCheque][3]+"():New()")
	nRet := ::oCheque:CHAbrir(cModelo, cPorta )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD CHImprime(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela ) CLASS Autocom
Local nRet := -1
If ValType(::oCheque) == 'O'
	nRet := ::oCheque:CHImprime(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD CHFechar(cPorta) CLASS Autocom
Local nRet := -1
If ValType(::oCheque) == 'O'
	nRet := ::oCheque:CHFechar(cPorta)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes do PinPad              ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD PinPadLis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstPinPad[1][1]+'",'+::aLstPinPad[1][2]

For nI := 2 To Len(::aLstPinPad)
	::cBuffer += ',"'+::aLstPinPad[nI][1]+'",'+::aLstPinPad[nI][2]
Next nI                            

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
METHOD PinPadAbr(cModelo,cPorta ) CLASS Autocom
Local nRet 	:= -1
Local cTemp := ""
::nPinPad := AScan(::aLstPinPad, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nPinPad <> 0
	::oPinPad := &(::aLstPinPad[::nPinPad][3]+"():New()")
	nRet := ::oPinPad:PinpadAbr(cModelo, cPorta )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD PinPadLeC(cModalidade) CLASS Autocom
Local nRet := -1
If ValType(::oPinPad) == 'O'
	nRet := ::oPinPad:PinPadLeC(cModalidade)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD PinPadFin() CLASS Autocom
Local nRet := -1
If ValType(::oPinPad) == 'O'
	nRet := ::oPinPad:PinpadFin()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes dos Leitores de codigo de Barra ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD LeitorLis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstLeitor[1][1]+'",'+::aLstLeitor[1][2]

For nI := 2 To Len(::aLstLeitor)
	::cBuffer += ',"'+::aLstLeitor[nI][1]+'",'+::aLstLeitor[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
METHOD LeitorAbr(cModelo,cPorta,cFoco) CLASS Autocom
Local nRet 	:= -1
Local cTemp := ""
::nLeitor := AScan(::aLstLeitor, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nLeitor <> 0
	::oLeitor := &(::aLstLeitor[::nLeitor][3]+"():New()")
	nRet := ::oLeitor:LeitorAbr(cModelo,cPorta,cFoco) 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD LeitorFec (cPorta ) CLASS Autocom
Local nRet := -1
If ValType(::oLeitor) == 'O'
	nRet := ::oLeitor:LeitorFec(cPorta )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD LeitorFoco(lModo) CLASS Autocom
Local nRet := -1
If ValType(::oLeitor) == 'O'
	nRet := ::oLeitor:LeitorFoco(lModo)
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes da Balancas            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD BalancaLis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstBalanca[1][1]+'",'+::aLstBalanca[1][2]

For nI := 2 To Len(::aLstBalanca)
	::cBuffer += ',"'+::aLstBalanca[nI][1]+'",'+::aLstBalanca[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
METHOD BalancaAbr( cModelo, cPorta ) CLASS Autocom
Local nRet 	:= -1
Local cTemp := ""
::nBalanca := AScan(::aLstBalanca, {|x| Upper(Alltrim(x[1])) == Upper(Alltrim(cModelo))})
If ::nBalanca <> 0
	::oBalanca := &(::aLstBalanca[::nBalanca][3]+"():New()")
	nRet := ::oBalanca:BalancaAbr( cModelo, cPorta )
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD BalancaFec() CLASS Autocom
Local nRet := -1
If ValType(::oBalanca) == 'O'
	nRet := ::oBalanca:BalancaFec() 
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
METHOD BalancaPegaPeso() CLASS Autocom
Local nRet := -1
If ValType(::oBalanca) == 'O'
	nRet := ::oBalanca:BalancaPegaPeso ()
EndIf
Return(nRet)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de Impressora Cupom    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD ImpCupLis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstImpCup[1][1]+'",'+::aLstImpCup[1][2]

For nI := 2 To Len(::aLstImpCup)
	::cBuffer += ',"'+::aLstImpCup[nI][1]+'",'+::aLstImpCup[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de CMC7                ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD CMC7Lis() CLASS Autocom
Local nI := 0	// controle de loop

::cBuffer := '"'+::aLstCMC7[1][1]+'",'+::aLstCMC7[1][2]

For nI := 2 To Len(::aLstCMC7)
	::cBuffer += ',"'+::aLstCMC7[nI][1]+'",'+::aLstCMC7[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de Display             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD DisplayLis() CLASS Autocom
Local nI := 0	//controle de loop

::cBuffer := '"'+::aLstDisplay[1][1]+'",'+::aLstDisplay[1][2]

For nI := 2 To Len(::aLstDisplay)
	::cBuffer += ',"'+::aLstDisplay[nI][1]+'",'+::aLstDisplay[nI][2]
Next nI

Return If(!Empty(::cBuffer),0,1)

//-----------------------------------------------------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Funcoes de TEF do banco Banorte - Mexico≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
METHOD Tef_Banorte(cNumCart,cNomeCli,cSenha,cClientID,cPipeline,cMode,cTransType,cCartao,cDatVenc,cOrderId,cTotal) CLASS Autocom
Local nRet := -1
If !File(GetClientDir()+"BANORTE.DLL")
   MsgInfo(GetClientDir()+STR0005)							//"BANORTE.DLL, nao encontrada!!"
Else   
	nRet := ExecDLL("ProcessTransaction", {cNumCart,cNomeCli,cSenha,cClientID,cPipeline,cMode,cTransType,cCartao,cDatVenc,cOrderId,cTotal})
EndIf	
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_CONF(cEnderecoIP, cCodLoja, cNumTerm, nConfRes) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("ConfiguraIntSitefInterativo", {cEnderecoIP, cCodLoja, cNumTerm, AllTrim(Str(nConfRes))})
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_CONFEX(cEnderecoIP, cCodLoja, cNumTerm, nConfRes, cParamAdic) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("ConfiguraIntSitefInterativoEx", {cEnderecoIP, cCodLoja, cNumTerm, AllTrim(Str(nConfRes)), cParamAdic })
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_INICIA( nFuncao , cValor , cCupom , dData , cHora , cOperador , cRestric ) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("IniciaFuncaoSiTefInterativo", { Alltrim(Str(nFuncao)) , cValor , cCupom , dData , cHora , cOperador , cRestric})
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_CONTIN(nProxComan, nTipoCampo, nTamMin, nTamMax, cBuffer, nTamMaxBuffer, nContNaveg) CLASS Autocom
Local nRet := -99999

nRet := ExecDLL("ContinuaFuncaoSiTefInterativo", { Alltrim(Str(nProxComan)) , Alltrim(Str(nTipoCampo)) , Alltrim(Str(nTamMin)) , Alltrim(Str(nTamMax)) , cBuffer ,  Alltrim(Str(nTamMaxBuffer)) ,  Alltrim(Str(nContNaveg)) })
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_FINAL(nConfirma, cNumCFis, cData, cHora) CLASS Autocom
Local lRet := .T.
ExecDLL("FinalizaTransacaoSiTefInterativo", {  Alltrim(Str(nConfirma)) , cNumCFis , cData , cHora })
Return(lRet)

//-----------------------------------------------------------------------------
METHOD SIT_CORRES( cCupom , dData , cHora , cOperador , cRestric ) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("CorrespondenteBancarioSiTefInterativo", { cCupom , dData , cHora , cOperador , cRestric} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VLDBAR(pDados,pTipo) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("ValidaCampoCodigoEmBarras", {pDados,pTipo} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VERPIN() CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("VerificaPresencaPinPad", {} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_MSNPIN(pMensagem) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("EscreveMensagemPermanentePinPad", {pMensagem} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VDLCON(cCodigoAutorizacao, cCodigoProduto, cCuponFiscal, cDataFiscal, cHorario, cOperador) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("IniciaFuncaoSiTefInterativoConsultaVidalink", {cCodigoAutorizacao, cCodigoProduto, cCuponFiscal, cDataFiscal, cHorario, cOperador} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VDLPRO(nIndiceProduto, cCodigoProduto, nQuantidade, cValorVenda) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("InformaProdutoVendaVidalink", {Alltrim(Str(nIndiceProduto)), cCodigoProduto, Alltrim(Str(nQuantidade)), cValorVenda} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VDLVEN(cCodigoAutorizacao, nNumeroProdutos, cCuponFiscal, cDataFiscal, cHorario, cOperador) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("IniciaFuncaoSiTefInterativoVendaVidalink", {cCodigoAutorizacao, Alltrim(Str(nNumeroProdutos)), cCuponFiscal, cDataFiscal, cHorario, cOperador} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_VDLCAN(nParcialTotal, cCuponFiscal, cDataFiscal, cHorario, cOperador) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("IniciaFuncaoSiTefInterativoCancelamentoVidalink", {Alltrim(Str(nParcialTotal)), cCuponFiscal, cDataFiscal, cHorario, cOperador} )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_LECART(pMensagem, pTrilha1, pTrilha2) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("LeCartaoDireto", { pMensagem, pTrilha1 , pTrilha2 } )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_LESENH(pParam, pSenha) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("LeSenhaDireto", { pParam, pSenha } )
Return(nRet)

//-----------------------------------------------------------------------------
METHOD SIT_CANCLE() CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("InterrompeLeCartaoDireto", {} )
Return(nRet)
	
//-----------------------------------------------------------------------------
METHOD SIT_LSNPIN(pMensagem) CLASS Autocom
Local nRet := -99999
nRet := ExecDLL("LeSimNaoPinPad", {pMensagem} )
Return(nRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SIT_ENVDIR∫Autor  ≥Microsiga           ∫ Data ≥  02/10/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao que envia a transacao direta ao Sitef               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
METHOD SIT_ENVDIR(	nRedeDestino	, nFuncaoSitef	, nOffSetCartao	, cDadosTx			, ;
					nTamDadosTx		, cDadosRx		, nTamMaxDadosRx, nCodigoResposta 	, ;
					nTempoEsperaRx 	, cCupomFiscal 	, cDataFiscal	, cHorario 			, ;
					cOperador 		, nTipoTransacao ) CLASS Autocom


nRet := ExecDLL("EnviaRecebeSiTefDireto", {	Alltrim(Str(nRedeDestino))	, Alltrim(Str(nFuncaoSitef))	, Alltrim(Str(nOffSetCartao))	, cDadosTx				, ;
											Alltrim(Str(nTamDadosTx))	, cDadosRx			, Alltrim(Str(nTamMaxDadosRx))	, Alltrim(Str(nCodigoResposta))	, ;
											Alltrim(Str(nTempoEsperaRx))	, cCupomFiscal 		, cDataFiscal			, cHorario 				, ;
											cOperador 			, Alltrim(Str(nTipoTransacao)) } )


Return(nRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ ExecDLL     ≥ Autor ≥ Cesar Valadao      ≥ Data ≥ 23/09/04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao para executar a chamada da funcao na DLL/SO. Caso a ≥±±
±±≥          ≥ funcao tenha algum retorno, sera colocado em ::cBuffer     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function ExecDLL(cNomeFunc, aParams)
Local nRet 			:= -999
Local nI			:= 0												// controle de loop
Local cBuffer       := ""
Local nPos   		:= 0
Local nFinal        := 0
Local cLogFile		:= GetClientDir()+"autocom.log"						// Log de monitoramento dos comandos enviados a AUTOCOM
Local lExistFile	:= File(cLogFile)									// Existe o arquivo e faz o Log
Local oGlobal		:= Nil												// Objeto do tipo LJCGlobal
oGlobal := LJCGlobal():Global()
Default aParams := {}

oAutocom:cBuffer := ""
cBuffer := cNomeFunc

For nI := 1 To Len(aParams)
	If ValType(aParams[nI]) == "C"
		cBuffer += Chr(1)+aParams[nI]									// O delimitador entre os parametros eh o Chr(1)
	Else
		MsgStop(STR0006+Alltrim(aParams[nI])+STR0007+cNomeFunc+STR0008)	//"O parametro "###" da funÁ„o "###" deve ser do tipo caracter!"
		nRet := -999
		Return(nRet)
	EndIf
Next nI

cBuffer += Chr(2)														// Finalizo o Buffer com Chr(2) indicando que acabaram os par‚metros

// Este log registra toda a comunicacao com a AUTOCOM
If lExistFile
	WriteLog(cLogFile, DToC(dDataBase)+" "+Time()+"  -> "+cBuffer)
EndIf

cBuffer := PadR(cBuffer, 13000)											// E complemento com espaÁos em branco para armazenamento da ·rea de trabalho
cBuffer := Encode64(cBuffer)

If ExeDLLRun2(oAutocom:nHandle, 1, @cBuffer) == 1
	cBuffer := Decode64(cBuffer)
	// Este log registra toda a comunicacao com a AUTOCOM
	If lExistFile
		WriteLog(cLogFile, DToC(dDataBase)+" "+Time()+"  <- "+Substr(cBuffer, 1, At(Chr(0),cBuffer)))
	EndIf

	nPos := At(Chr(1), cBuffer)
	If nPos == 0
		nPos := At(Chr(0), cBuffer)
	EndIf
	If cNomeFunc == "EnviaRecebeSiTefDireto" .OR. cNomeFunc == "LeCartaoDireto" .OR. cNomeFunc == "ObtemDadoPinPadDiretoEx"
		nFinal := oGlobal:Funcoes():Rat(cBuffer, Chr(0))
	Else
		nFinal := At(Chr(0), cBuffer)										// No retorno, o Chr(0) eh o final
	EndIf
	nRet := Val(Substr(cBuffer, 1, nPos-1))
	If nPos <> nFinal
		If  cNomeFunc == "ObtemDadoPinPadDiretoEx"
			oAutocom:cBuffer := Substr(cBuffer, nPos+1, nFinal)			// Coloco o retorno no buffer da oAutocom
		Else
			oAutocom:cBuffer := Substr(cBuffer, nPos+1, nFinal-1)			// Coloco o retorno no buffer da oAutocom
		EndIf
	EndIf
Else
	// Este log registra toda a comunicacao com a AUTOCOM
	If lExistFile
		WriteLog(cLogFile, DToC(dDataBase)+" "+Time()+"  <- Erro de comunicaÁ„o com a AUTOCOM. Retorno <> 1")
	EndIf
EndIf                    

Return( nRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ WriteLog    ≥ Autor ≥ Cesar Valadao      ≥ Data ≥ 08/04/05 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Registra todos os comandos que foram enviados para AUTOCOM ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function WriteLog(cArq, cTexto)
Local nHandle := FOpen( cArq, 2 )
If nHandle <> -1
	FSeek ( nHandle, 0, 2 )												// Posiciona no final do arquivo
	FWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto)+2 )
	FClose( nHandle)
EndIf
Return(NIL)

//----------------------------------------------------------------------------
Function FormataTexto( cValor, nTamanho, nDecimais, nTipo, Separador)
Local nZeros 
Default Separador =","

// Formata o retorno do texto
// 1-  com separador de decimais e zeros a esquerda. Ex.:   00999,99
// 2-  sem separador de decimais e zeros a esquerda. Ex.:    0099999
// 3-  com separador de decimais e espacos a esquerda. Ex.:  '  999,99'
// 4-  sem separador de decimais e espacos a esquerda. Ex.:  '   99999'

cValor := StrTransf(cValor,",",".")

If Len(cValor) > nTamanho
	cValor := SubStr(cValor, Len(cValor)-nTamanho,Len(cValor))
EndIf

If nDecimais > 0
	If At(".",cValor) > 0 .AND. At(".",cValor) <> Len(cValor) - nDecimais  
		If At(".",cValor) < Len(cValor) - nDecimais
			cValor := SubStr(cValor,1, At(".",cValor) + nDecimais)
		ElseIf At(".",cValor) > Len(cValor) - nDecimais
			nZeros :=  At(".",cValor) - (Len(cValor) - nDecimais)
			While At(".",cValor) > Len(cValor) - nDecimais
				cValor := cValor + "0"
			End
		EndIf
	EndIf
EndIf

nTamanho += (If(nDecimais>0 .AND. (nTipo == 1 .OR. nTipo ==3),1,0))

If (nTipo == 2) .OR. (nTipo == 4)  // n„o tem Separador decimal
  cValor := StrTransf(cValor,".","")
EndIf

If (nTipo == 1) .OR. (nTipo == 3)  // tem Separador decimal
	cValor := StrTransf(cValor,".",Separador)

	If Len(cValor) - At(cValor, Separador) <> nDecimais
		cValor := StrTransf(cValor,",","")
		cValor := StrTransf(cValor,".","")	  
		cValor := SubStr(cValor, 1, Len(cValor)-nDecimais)+Separador+SubStr(cValor, Len(cValor)-nDecimais+1, Len(cValor))
	EndIf
EndIf

If (nTipo == 1) .OR. (nTipo == 2)
	While (Len(cValor) < nTamanho)
	  cValor := "0" + cValor
	End
Else
	While (Len(cValor)<nTamanho)
		cValor := " " + cValor  
	End
EndIf

Return(cValor)

//----------------------------------------------------------------------------
Function FormataData( dData, nTipo)
Local cData
// formata data cf. tipo selecionado
// 1- DDMMAA
// 2- DDMMAAAA
// 3- DD/MM/AA
// 4- DD/MM/AAAA
// 5- AAAAMMDD

cData := DToC( dData )
If nTipo == 1 
	cRetorno := SubStr(cData,1,2)+SubStr(cData,4,2)+SubStr(cData,7,2)
ElseIf nTipo == 2 
	cRetorno := StrTransf(sData, '/', '')
ElseIf nTipo == 3 
	cRetorno := SubStr(cData,1,6)+SubStr(cData,9,2)
ElseIf nTipo == 4 
	cRetorno := SubStr(cData,1,6)+AllTrim(Str(Year(dData)))
ElseIf nTipo == 5 
	cRetorno := DToS(dData)
Else
	cRetorno := cData
EndIf
              
Return(cRetorno)

//----------------------------------------------------------------------------
Function StrTransf( cTexto, cOrigem, cDestino)
Local nX := 0	// controle de loop

cRetorno := ""
For nX := 1 to Len(cTexto) 
	If SubStr(cTexto, nX, 1) == cOrigem 
		cRetorno := cRetorno + cDestino
	Else                             
		cRetorno := cRetorno + SubStr(cTexto, nX, 1)
    EndIf
Next nX

Return( cRetorno )

//-------------------------------------------------------------------------------
Function MontArray( cTexto )
Local aFormas 	:= {}
aFormas := StrToKArr( cTexto, "|" )

Return( aFormas )
                 
//-------------------------------------------------------------------------------

METHOD VSProtheus() CLASS Autocom
Local cRet := Space(20)

If ExeDLLRun2(oAutocom:nHandle, 997, @cRet) <> 1
	cRet := "-1"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SIT_OBTQTR
Obtem quantidade de transaÁıes
@type Function
@param cData , caracter , data da transacao
@param cCupom , caracter , Numero do documento
@author  Varejo
@version 	P11.8
@since   	02/05/2016
@return  	nRet , numerico, retorno da DLL
/*/
//-------------------------------------------------------------------
METHOD SIT_OBTQTR(cDataFiscal, cCupomFiscal) CLASS Autocom
Local nRet			:= -99999
Local cVerAutocom	:=  space(20)

//Busca a vers„o da DLL
ExeDLLRun2(oAutocom:nHandle, 999, @cVerAutocom)

If AllTrim(cVerAutocom) > "3.4.1.4" 
	nRet := ExecDLL("ObtemQuantidadeTransacoesPendentes", { cDataFiscal, cCupomFiscal } )
EndIf

Return nRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} SIT_DIGCPF
Chama digiÁ„o do CPF pelo PinPad
@type 		Metodo da classe Autocom
@param
@author  	JMM
@version 	V12.1.25
@since   	25/07/2019
@return  	nRet , numerico, retorno da DLL
/*/
//-----------------------------------------------------------------------------
METHOD SIT_DIGCPF( cEntrada, cSaida ) CLASS Autocom
Local nRet	:= -99999

nRet := ExecDLL("ObtemDadoPinPadDiretoEx", { "" , "", cEntrada, cSaida })

cSaida := oAutocom:cBuffer

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SIT_VERDLL
Retorna a Vers„o da DLL Autocom
@type 		Metodo da classe Autocom
@author		JMM
@version 	V12.1.25
@since   	05/08/2019
@return  	cRet , caractere, versao da DLL
/*/
//-------------------------------------------------------------------
METHOD SIT_VERDLL() CLASS Autocom
Local cRet	:= space(20)

//Busca a vers„o da DLL
ExeDLLRun2(oAutocom:nHandle, 999, @cRet)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ComAberta()
Verifica se o objeto est· aberto
@type 		Metodo da classe Autocom
@author		marisa.cruz
@version 	V12.1.27
@since   	05/06/2020
@return  	lRet , lÛgico, .T. se aberto
/*/
//-------------------------------------------------------------------
Method ComAberta() Class AutoCom
Local lRet := .F.                    //Retorno do mÈtodo
    
lRet := (::nHandle <> -1)
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Finish()
Destroi o objeto Autocom
@type 		Metodo da classe Autocom
@author		marisa.cruz
@version 	V12.1.27
@since   	05/06/2020
@return  	lRet , lÛgico, se fechou o objeto
/*/
//-------------------------------------------------------------------
METHOD Finish() CLASS Autocom
Local lRet := .F.                    //Retorno do mÈtodo

If Self:ComAberta()
	ExecInDllClose( ::nHandle )
    ::nHandle := -1
EndIf

lRet := ( ::nHandle < 0 )

Return lRet