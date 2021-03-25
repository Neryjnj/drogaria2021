#include "TOTVS.CH"

#DEFINE _CLISITEF "4" //4=CliSitef

Static lIsRmt64		:= If( ExistFunc("IsRmt64") ,IsRmt64(), .F. ) //Verifica se o SmartClient é 32 ou 64 bits
Static cDLLTOTVSAPI	:= IIf(lIsRmt64,"TOTVSAPI64.DLL","TOTVSAPI.DLL")
Static cDLLAUTOCOM	:= IIf(lIsRmt64,"AUTOCOM64.DLL","AUTOCOM.DLL")

Static cIPSiTEF  := "127.0.0.1"
Static cCodLoja  := "00000000"
Static cNumTerm  := "MS000200"
Static cCNPJEstb := "53113791000122"
Static cCNPJTOTVS:= "53113791000122"
Static cParamAdic:= "[ParmsClient=1=" + cCNPJEstb + ";2=" + cCNPJTOTVS + "]" // 1=CNPJ do estabelecimento 2=CNPJ da Software House

//Variáveis utilizadas como passagem de parâmetros nas duas DLLs (Autocom e TotvsApi)
Static nRedeDestino     := 62
Static nFuncaoSitef     := 240
Static nOffSetCartao    := 0
Static cDadosTx         := "27"+Chr(0)+"1"+Chr(0)+"12345"
Static nTamDadosTx      := 10
Static cDadosRx 	    := Space(10000)
Static nTamMaxDadosRx   := Len(cDadosRx)
Static nCodigoResposta  := 0
Static nTempoEsperaRx   := 30 //Tempo máximo de espera por uma resposta após enviar o comando para o SiTef
Static cCupomFiscal     := "102030" //Codigo qualquer aleatório, cupom fiscal
Static cDataFiscal      := dtos(date())
Static cHorario         := StrTran(Time(),":","")
Static cOperador        := "2" //PDV
Static nTipoTransacao   := 1 //Tipo de documento utilizado no PBM:  0=ECF, 1=NFC-e, 2=SAT

/*
 POC para analisar o funcionamento da comunicação com o TEF (Software Express) 
 utilizando o módulo de PBM (Programas de Benefício em Medicamentos)
*/
User Function POCPBM()
Local oDlg      := Nil
Local oTButton1 := Nil
Local oTButton2 := Nil

DEFINE MSDIALOG oDlg TITLE "POC PBM" FROM 0,0 TO 15,41

TSay():Create(oDlg,{||'*** Ambiente com SMARTCLIENT ' + Iif(lIsRmt64,"64","32") + ' bits ***' },05,20,,,,,,.T.,CLR_RED,,200,20)

TSay():Create(oDlg,{||'Utilizando a DLL ' + cDLLAUTOCOM},25,01,,,,,,.T.,,,200,20)
oTButton1 := TButton():New( 035, 010, "Funcionando",oDlg,{|| PBMAutoCom() }, 100,20,,,.F.,.T.,.F.,,.F.,,,.F. )

TSay():Create(oDlg,{||'Utilizando a DLL ' + cDLLTOTVSAPI},80,01,,,,,,.T.,,,200,20)
oTButton2 := TButton():New( 090, 010, "Com Problema",oDlg,{|| PBMTotvsApi() }, 100,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlg CENTERED

Return 

//*********************************************************************/
// Chamada de comunicação com a DLL Autocom.dll (Funcionando) 
//*********************************************************************/
Static Function PBMAutoCom()
Local nRet		:= -999
Local lContinua := .T.
Local aParams   := {}       //Parâmetros da Função
Local cDLLName  := cDLLAUTOCOM
Local cPath     := GetClientdir()
Local cNome	    := cPath + cDLLName
Local nHandleDLL:= -1
Local cDELIMIT	:= Chr(1)   //Delimitador (Separador de parâmetros) utilizado na DLL AutoCom.DLL
Local cFIMSTR	:= Chr(2)   //Delimitador de Final de string utilizado na DLL AutoCom.DLL

//Abre a Comunicação com a DLL Autocom.DLL
nHandleDLL := ExecInDLLOpen(cNome)
If nHandleDLL == -1
	Alert("Erro ao abrir a DLL: " + cDLLName + Chr(13) + Chr(13) + "Verifique se " +cDLLName+ " ou advplce.dll estão presentes no diretório " + cPath)
	lContinua := .F.
EndIf

If lContinua
    //===========================================================================
    // 1. Envia para a DLL, primeiro o comando de Configuração Sitef Interativo
    //============================================================================
    //Parâmetros da Função
    aParams := {    cIPSiTEF        ,;  //01
                    cCodLoja        ,;  //02
                    cNumTerm        ,;  //03
                    "0"             ,;  //04
                    cParamAdic  }       //05

    nRet := ExeCmdDLL("ConfiguraIntSitefInterativoEx", aParams, nHandleDLL, cDELIMIT, cFIMSTR)

    //===========================================================================
    // 2. Envia para a DLL, o comando EnviaRecebeSiTefDireto (PBM)
    //============================================================================
    //Parâmetros da Função
    aParams := {    AllTrim(Str(nRedeDestino))      ,; //01
                    AllTrim(Str(nFuncaoSitef))      ,; //02
                    AllTrim(Str(nOffSetCartao))     ,; //03
                    cDadosTx                        ,; //04
                    AllTrim(Str(nTamDadosTx))       ,; //05
                    cDadosRx                        ,; //06
                    AllTrim(Str(nTamMaxDadosRx))    ,; //07
                    AllTrim(Str(nCodigoResposta))   ,; //08
                    AllTrim(Str(nTempoEsperaRx))    ,; //09
                    cCupomFiscal                    ,; //10
                    cDataFiscal                     ,; //11
                    cHorario                        ,; //12
                    cOperador                       ,; //13
                    AllTrim(Str(nTipoTransacao))  }    //14

    nRet := ExeCmdDLL("EnviaRecebeSiTefDireto", aParams, nHandleDLL, cDELIMIT, cFIMSTR)

    MsgAlert('Envio do comando "EnviaRecebeSiTefDireto" (DLL AUTOCOM com DLL CliSiTEF)' + Chr(13) + Chr(13) + 'Retorno: ' + cValToChar(nRet))

    If nRet == -5
        MsgStop("Não foi possível se comunicar com o SiTEF!" +Chr(13)+Chr(13)+ "Verifique o IP: " + cIPSiTEF )
    EndIf

    //Encerra a conexão com a DLL
    ExecInDllClose(nHandleDLL)
EndIf

Return


//*********************************************************************/
// Chamada de comunicação com a DLL Totvsapi.dll (Com Problema) 
//*********************************************************************/
Static Function PBMTotvsApi()
Local nRet		:= -999
Local lContinua := .T.
Local aParams   := {}       //Parâmetros da Função
Local cDLLName      := cDLLTOTVSAPI
Local cPath         := GetClientdir()
Local cNome	        := cPath + cDLLName
Local nHandleDLL    := -1
Local cDELIMIT	    := "<@#DELIMIT#@>"  //Delimitador (Separador de parâmetros) utilizado na DLL TOTVSAPI.DLL
Local cFIMSTR	    := "<@#FIMSTR#@>"   //Delimitador de Final de string utilizado na DLL TOTVSAPI.DLL

//Abre Comunicação com a DLL TOTVSAPI.DLL
nHandleDLL    := ExecInDLLOpen(cNome)
If nHandleDLL == -1
	// "Erro ao abrir " ### "Verifique se " ### "ou" ### "estao presentes no diretório \BIN\REMOTE." 		
	Alert("Erro ao abrir a DLL: " + cDLLName + Chr(13) + Chr(13) + "Verifique se " +cDLLName+ " ou advplce.dll estão presentes no diretório " + cPath)
	lContinua := .F.
EndIf

If lContinua
    //===========================================================================
    // 1. Envia para a DLL, primeiro o comando de Configuração Sitef Interativo
    //============================================================================
    //Parâmetros da Função
    aParams := {    _CLISITEF                           ,;  //01- Tipo de DLL externa a ser executada (1=Epson; 2=Bematech; 3=Itautec; 4=Clisitef)
                    "ConfiguraIntSiTefInterativoEx"     ,;  //02 Funcao da DLL Externa a ser executada
                    cIPSiTEF                            ,;  //03
                    cCodLoja                            ,;  //04
                    cNumTerm                            ,;  //05
                    "0"                                 ,;  //06
                    cParamAdic  }                           //14

    nRet := ExeCmdDLL("", aParams, nHandleDll, cDELIMIT, cFIMSTR)

    //===========================================================================
    // 2. Envia para a DLL, o comando EnviaRecebeSiTefDireto (PBM)
    //============================================================================
    //Parâmetros da Função
    aParams := {    _CLISITEF                       ,; //01- Tipo de DLL externa a ser executada (1=Epson; 2=Bematech; 3=Itautec; 4=Clisitef)
                    "EnviaRecebeSiTefDireto"        ,; //02 Funcao da DLL Externa a ser executada
                    AllTrim(Str(nRedeDestino))      ,; //03
                    AllTrim(Str(nFuncaoSitef))      ,; //04
                    AllTrim(Str(nOffSetCartao))     ,; //05
                    cDadosTx                        ,; //06
                    AllTrim(Str(nTamDadosTx))       ,; //07
                    cDadosRx                        ,; //08
                    AllTrim(Str(nTamMaxDadosRx))    ,; //09
                    AllTrim(Str(nCodigoResposta))   ,; //10
                    AllTrim(Str(nTempoEsperaRx))    ,; //11
                    cCupomFiscal                    ,; //12
                    cDataFiscal                     ,; //13
                    cHorario                        ,; //14
                    cOperador                       ,; //15
                    AllTrim(Str(nTipoTransacao))  }    //16

    nRet := ExeCmdDLL("", aParams, nHandleDLL, cDELIMIT, cFIMSTR)

    MsgAlert('Envio do comando "EnviaRecebeSiTefDireto" (DLL TOTVSAPI com DLL CliSiTEF)' + Chr(13) + Chr(13) + 'Retorno: ' + cValToChar(nRet))

    If nRet == -5
        MsgStop("Não foi possível se comunicar com o SiTEF!" +Chr(13)+Chr(13)+ "Verifique o IP: " + cIPSiTEF )
    EndIf

    //Encerra a conexão com a DLL
    ExecInDllClose(nHandleDLL)
EndIf

Return .T.

//Eecuta comando na DLL
Static Function ExeCmdDLL(cNomeFunc, aParams, nHandleDll, cDELIMIT, cFIMSTR)
Local nRet 			:= -999
Local cBuffer       := ""
Local nPos   		:= 0
Local cDLL          := IIF(!Empty(cNomeFunc),cDLLAUTOCOM,cDLLTOTVSAPI)
Local cCmdDLL       := "" //Comando enviado para a DLL
Local nRetCmdDLL    := 0

If "AUTOCOM" $ cDLL
    cBuffer := BuffAutoCom(cNomeFunc,aParams,cDELIMIT,cFIMSTR)
    cFIMSTR := Chr(0)
    cCmdDLL := cNomeFunc
Else
    cBuffer := BuffTotApi(aParams,cDELIMIT,cFIMSTR)
    cCmdDLL := aParams[2]
EndIf

//Executa funçao da DLL
nRetCmdDLL := ExeDLLRun2(nHandleDll, 1, @cBuffer)

If nRetCmdDLL == 1
	cBuffer := Decode64(cBuffer)
	
	nPos := At(cDELIMIT, cBuffer)
	If nPos == 0
		nPos := At(cFIMSTR, cBuffer)
	EndIf
	nRet := Val(Substr(cBuffer, 1, nPos-1))
Else
	// Este log registra toda a comunicacao com a AUTOCOM
	MsgStop("Erro de comunicação com a DLL. Retorno é <> 1" + Chr(13) + Chr(13) + "Código retornado: " + cValToChar(nRetCmdDLL))
EndIf

MsgAlert("Execução do comando: " + cCmdDLL + " na DLL " + cDLL + Chr(13) + Chr(13) + "Buffer Retornado: " + AllTrim(cBuffer) )

Return( nRet )


//Retorna o Buffer formatado para enviar para execução na DLL Autocom.DLL
Static Function BuffAutoCom(cNomeFunc,aParams,cDELIMIT,cFIMSTR)
Local cBuffer   := ""
Local nI        := 0

cBuffer := cNomeFunc

For nI := 1 To Len(aParams)
	cBuffer += cDELIMIT+aParams[nI] // Delimitador entre os parametros
Next nI

cBuffer += cFIMSTR // Finalizo o Buffer indicando que acabaram os parâmetros

cBuffer := PadR(cBuffer, 13000)	// E complemento com espaços em branco para armazenamento da área de trabalho
cBuffer := Encode64(cBuffer)

Return cBuffer



//Retorna o Buffer formatado para enviar para execução na DLL TOTVSAPI.DLL
Static Function BuffTotApi(aParams,cDELIMIT,cFIMSTR)
Local cBuffer   := ""
Local nCount    := 0

//Coloca os parametros em cBuffer
For nCount := 1 To Len(aParams)
    cBuffer += aParams[nCount] + cDELIMIT
Next nCount

cBuffer += cFIMSTR

cBuffer := PadR(cBuffer, 13000)

cBuffer := Encode64(cBuffer)

Return cBuffer