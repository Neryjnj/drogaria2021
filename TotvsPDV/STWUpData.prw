#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWUPDATA.CH" 
#INCLUDE "STPOS.CH"


//===================================================
// 				Situacoes do _SITUA                             
//
// "  " - Base Errada, Registro Ignorado.          
// "00" - Venda Efetuada com Sucesso               
// "01" - Abertura do Cupom Nao Impressa           
// "02" - Impresso a Abertura do Cupom             
// "03" - Item Nao Impresso                        
// "04" - Impresso o Item                          
// "05" - Solicitado o Cancelamento do Item        
// "06" - Item Cancelado                           
// "07" - Solicitado o Cancelamento do Cupom       
// "08" - Cupom Cancelado                          
// "09" - Encerrado SL1 (Nao gerado SL4)           
// "10" - Encerrado a Venda                        
//        Pode nao ter sido impresso o cupom       
// "TX" - Foi Enviado ao Server (Pdv)
// "ER" - Erro ao envia ao server (Pdv)  
// "EP" - Erro de processamento da venda (Pdv)
// "RE" - Ja foi feita nova tentativa de subir  (Pdv)                      
// "RX" - Foi Recebido Pelo Server (Server)                 
// "OK" - Foi Processado no Server (Serevr)               
//        Enviar um OK ao Client que foi Processado 
// "CP" - Recebido pela Central de PDV
// "C0" - Cancelamento a ser enviado pelo PDV
// "CX" - Cancelamento enviado pelo PDV
//---------------------------------------------------
//  Status da transmissão por NFCe Dll que não vão para retaguarda - interno TotvsPDV Mobile
// "D1" - NFCe Dll - Contingencia off-line - Envia NFCe em contingência e consulta Status da NFce para então enviar para retaguarda
// "D0" - NFCe Dll - Contingencia on-line - Consulta Status da NFce para então enviar para retaguarda
// "I8" - NFCe Dll - Inutilização não realizada - Tentar novamente - Se deu certo envia venda inutilizada para retaguarda
// "DC" - NFCe Dll - Cancelamento on line realizado de Nota não enviada - envia o cancelamento novamente
// "DX" - NFCe Dll - Cancelamento on line realizado de Nota enviada - consulta status da nfce antes de enviar a retaguarda
// "D7" - NFCe Dll - Cancelamento offline - não enviado - envia o cancelamento em contigencia e depois consulta o status
// "D8" - NFCe Dll - Cancelamento  on line não realizado de nota enviada - tenta realizar o cancelamento e consulta o status
// "D9" - NFCe - Cancelamento on line não realizado de nota NÃO enviada - tenta cancelar a nota e consulta o status
//===================================================

/*
Exemplo de configuracao do arquivo ini

[STWUpData]
Main=STWUpData
Environment=PDVPAF11                                                                                                                                                                                                                                                                                                                                                                                                                                                       
nParms=3
Parm1=T1
Parm2=D MG 01                 
Parm3=001

[OnStart]
Jobs=STWUpData
RefreshRate=30

*/


//Exemplo de user function para testes
User Function TesteUp()
	STWUpData( "99" , "01" , "001",".T." )	
Return
	

//-------------------------------------------------------------------
/*/{Protheus.doc} STWUpData
Efetua o envio das tabelas de vendas e outras para o server

@param cEmp			Codigo da empresa
@param cFil			Codigo da filial
@param cPdv			Codigo do PDV

@author  Varejo
@version P11.8
@since   09/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWUpData( cEmp , cFil , cPdv,cClearCDX)

Local lPrepEnv		:= .F.						// Verifica se deve preparar o Ambiente
Local lConnect		:= .F.                		// Controle de conexao
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lLJCLocker 	:= .F. 						// Utiliza Componente Controle de Carga de dados
Local nTamE5Nat		:= ""                       // Tamanho do campo  
Local lCentPDV		:= .F. 						// Eh Central de PDV                
Local lComCPDV		:= .F.						// Usa comunicacao com a Central de PDV 
Local lRMS			:= .F.	 					//Integracao com a RMS 
Local lFirst		:= .F. 						//Integracao com o First
Local cIntegration 	:= "DEFAULT" 				//Tipo da Integracao                                                                      
Local nSendOn		:= 0 						//Retorno como sera a integracao da venda - 0 - via job - 1 online - 2 startjob
Local cMvNatTrc		:= ""						//Natureza do Troco
Local cMvNatSang	:= ""						//Natureza da Sangria

Local cMyUID 		:= "STWClearCDX"	//ID para reserva no APPSERVER
Local cChave 		:= "ClearCDX"		//CHAVE para reserva no APPSERVER
Local nControle		:= 0				//Controla para limpeza de CDX
Local lRet 			:= .F.

Default cEmp		:= ""							// Empresa para processamento
Default cFil		:= ""							// Filial para processamento
Default cPdv		:= "001"						// Conteudo do terceiro parametro (Parm3 do mp8srv.ini)
Default cClearCDX	:= "0"							//Controla se a limpeza de CDX esta habilitada


//Aguarda para evitar erro de __CInternet
Sleep(5000)

lPrepEnv := !Empty(cEmp) .AND. !Empty(cFil)


If lPrepEnv
	RPCSetType(3)
	// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
	RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
ElseIf Empty(cEmpAnt) .AND. Empty(cFilAnt) 
	Conout(STR0001) //"Não foram informados os parametros do processo no arquivo INI"	
EndIf

cEstacao := cPdv 

If cClearCDX == "1"
	Conout("Limpeza dos arquivos CDX na pasta \Data\ ativada")
	LjGrvLog("STWClearCDX","Limpeza dos arquivos CDX da pasta \Data\ ativada")
	
	//Cria uma sessão de memoria no appserver
	lRet := VarSetUID(cMyUID, .T.)
	If(!lRet)
		LjGrvLog("STWClearCDX","Erro na criação da sessão: " + cMyUID)
	EndIf
	
	//Recupera o valor da chave de memoria
	lRet := VarGetX(cMyUID, cChave, @nControle)
	
	If(!lRet)
		LjGrvLog("STWClearCDX","Erro na recuperação da chave ou chave inexistente")
	EndIf

	If nControle <> 1
		Conout("Iniciando limpeza arquivos CDX na pasta \Data\")
		LjGrvLog("STWClearCDX","Iniciando limpeza arquivos CDX na pasta \Data\")
		
		STWClearCDX()
		
		Conout("Finalizando limpeza arquivos CDX na pasta \Data\")
		LjGrvLog("STWClearCDX","Finalizando limpeza arquivos CDX na pasta \Data\")
	EndIf
EndIf

lRMS := SuperGetMv("MV_LJRMS",,.F.)

If ExistFunc("STFCfgIntegration")	
	cIntegration := STFCfgIntegration()
	lRMS  :=  cIntegration ==  "RMS"
Else
	If SuperGetMv("MV_LJRMS",,.F.)
		cIntegration := "RMS"
		lRMS :=  .T.
	EndIf
	
Endif

lFirst := cIntegration == "FIRST"
If lPrepEnv
	cMvNatTrc	:= LjMExeParam("MV_NATTROC",,"TROCO")	//Natureza do Troco
	cMvNatSang	:= LjMExeParam("MV_NATSANG",,"SANGRIA")	//Natureza da Sangria
EndIf	

If !lFirst
	nTamE5Nat 	:= TamSX3("E5_NATUREZ")[1]
	
	lLJCLocker 	:= ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1"
	oLJCLocker  := If( lLJCLocker , LJCGlobalLocker():New(), Nil )	
	
	lCentPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV 
	lComCPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[2] , .F. ) // Usa comunicacao com a central 

	// ATENCAO : Cuidado para chamar funcoes atraves da funcao STBRemoteExecute, pois ela pode sobrecarregar o server, somente chamar se necessario
	ConOut(STR0005+STR0006) //"TOTVS PDV - Estabelecendo conexão com o HOST Superior"
	
	lConnect := FWHostPing() // Funcao disponibilizada pelo Frame para testar comunicacao (Jun/15)
	
	If !lConnect //Testa a comunicacao atraves da STFTestRemoteExecute caso a FWHostPing nao funcione no ambiente do cliente
		lConnect := STFTestRemoteExecute(lComCPDV)
	EndIf    

	//Grava no arquivo ini se conseguiu fazer conexao com a Ret = 1 ou se nao tem conexao com a Ret = 0
	If lConnect
		WritePProString(CSECAO, CCHAVE, '1', GetAdv97())
	Else
		WritePProString(CSECAO, CCHAVE, '0', GetAdv97())
	EndIf	

	If lConnect .AND. (If( lLJCLocker, oLJCLocker:GetLock( "LOJA1115ILLock" ), .T. ))
	
		LjGrvLog("STWUpData", STR0005+STR0002)	////"TOTVS PDV - Conexao estabelecida com o Servidor"
		ConOut(STR0005+STR0002)  //"TOTVS PDV - Conexao estabelecida com o Servidor"	  
	            		
		If lRMS .AND. !lCentPDV 
			 //Grava SLX			 
			STDRecTabServer("SLX",	 3	, "SLX->LX_FILIAL + SLX->LX_SITUA", xFilial("SLX") + "00","TX", "RX", cPDV)		
		EndIf
				            
		//Subir Vendas  
	   	STDSalesForUp(cPDV)            
        
        //Grava Cancelamento
		If !lRMS
			STDCancSales( cPDV )
		EndIf
        
        // Se nao for Central OU FIRST executa demais funcionalidades
		If !lCentPDV 
		 	STDRecTabServer("SFI",	 2	, "SFI->FI_FILIAL + SFI->FI_SITUA", xFilial("SFI") + "00",;
		  					 "TX", "RX"	, cPDV														)    
							 
			// Funcao generica         
	        STDRecGenTabServer()
	        
			 //Grava SLX
			 STDRecTabServer("SLX",	 3	, "SLX->LX_FILIAL + SLX->LX_SITUA", xFilial("SLX") + "00",;
			    				 "TX", "RX"	, cPDV												  )
			    				 
			 //Grava SLX - Inutilizacao de NFC-e
			 STDRecTabServer(	"SLX"	, 3		, "SLX->LX_FILIAL + SLX->LX_SITUA", xFilial("SLX") + "OK"	,;
			 					"TX"	, "OK"	, cPDV														)
			    				 			    				 
			//Grava Sangria
			STDRecTabServer("SE5",	 16, "SE5->E5_FILIAL + SE5->E5_SITUA + SE5->E5_NATUREZ", xFilial("SE5") + "00" + PADR(cMvNatSang, nTamE5Nat) ,;
							 "OK", "OK", cPDV) 
			
			//Grava Suprimento
			STDRecTabServer("SE5",	 16, "SE5->E5_FILIAL + SE5->E5_SITUA + SE5->E5_NATUREZ", xFilial("SE5") + "00" + PADR(cMvNatTrc, nTamE5Nat),;
							 "OK", "OK", cPDV) 
			

			If AliasInDic("MFL") 
				//Grava consulta de produtos
				STDRecTabServer("MFL",	 2	, "MFL->MFL_FILIAL + MFL->MFL_SITUA", xFilial("MFL") + "00",;
								 "TX", "RX"	, cPDV														)
			EndIf
		
			//Grava SLW e SLT caso o parametro MV_LJCONFF esteja ativo e for PDV SigaLoja offline 
	 	   	If SuperGetMV( "MV_LJCONFF",,.F. )    
			    
				STDRecOpenClose("SLW"	,	 4, "SLW->LW_FILIAL + SLW->LW_SITUA", xFilial("SLW") + "00",; 
								"TX"	, "RX", cPDV )				
								
				STDRecTabServer("SLT"	,	 2, "SLT->LT_FILIAL + SLT->LT_SITUA", xFilial("SLT") + "00",;
								 "TX"	, "RX", cPDV )				
			EndIf 		
			//Grava Tabela de Apoio PAF-ECF	
			If AliasInDic( "MDZ" )
				STDRecTabServer("MDZ",	 2, "MDZ->MDZ_FILIAL + MDZ->MDZ_SITUA", xFilial("MDZ") + "00", "OK", "OK", cPDV )
			EndIf

			// Grava Estorno da venda
			STDRecEstSale()

            //Caso utilize Template de Drogarias, sobe informações das tabelas do template para Retaguarda.
			If ExistFunc("STDUpDro") .And. ExistFunc("LjIsDro") .And. LjIsDro()
				STDUpDro( cPDV )
			EndIf
		Else
			//Sobe o cadastro de cliente que esta na central para a retaguarda
			STDGrvCli()
		EndIf
	
		If( lLJCLocker, oLJCLocker:ReleaseLock( "LOJA1115ILLock" ),) 	// Componente de Carga de dados
	
		ConOut(STR0005+STR0003)  // TOTVS PDV - Conexao finalizada com o Servidor
		LjGrvLog("STWUpData", STR0005+STR0003)      // TOTVS PDV - Conexao finalizada com o Servidor 
		
		lConnect := .F.  
	Else
		Conout(STR0004) //"Não foi possivel estabelecer comunicação. Verifique as configurações." 
		Sleep(5000)	
		LjGrvLog("STWUpData", STR0004)      //"Não foi possivel estabelecer comunicação. Verifique as configurações." 
	EndIf	
	
Else
	cEstacao := cPdv
	STWUpFirst(cPDV)
EndIf

FWCloseFunctionality() // Desconecta do Host Superior para liberar memoria alocada

// Tratamento para evitar problemas de performance,
// tinha casos que o RefeshRate estava muito pequeno (ex: 1 )   
nSendOn := SuperGetMV("MV_LJSENDO",,0) //Retorno como sera a integracao da venda - 0 - via job - 1 online - 2 startjob

nRefrRate := Val(GetPvProfString("ONSTART","RefreshRate","",GetAdv97()))

If nSendOn == 0
	If nRefrRate > 0 .AND. nRefrRate < 50
		WritePProString("ONSTART","REFRESHRATE","50",GetAdv97())
	EndIf
Else //Quando venda online esta habilitada o JOB se torna contingencia e por este motivo aumenta o tempo do refreshrate
	If nRefrRate > 0 .AND. nRefrRate < 300
		WritePProString("ONSTART","REFRESHRATE","300",GetAdv97())
	EndIf
EndIf

If lPrepEnv
	RESET ENVIRONMENT // Esta dando erro ao compilar
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWUpFirst
Workflow de envio da integração First

@param cPdv			Codigo do PDV

@author  Varejo
@version P11.8
@since   28/04/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWUpFirst(cPDV)

// Retirado conteudo da rotina por não existir a função chamada WSINTEGRACAOPDV() 
// PDV FIRST não está mais ativo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STWClearCDX
Limpar aquivos CDX da pasta |\data\

@author  Lucas Novais
@version P11.8
@since   09/08/2017
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STWClearCDX()

Local aFiles 	:= {}				//Armazena os arquvos encontrados
Local nX		:= 0				//variavel para controle 
Local cDirComp	:= "\Data\"				//Variavel que armazena o caminho do diretorio 
Local cExtArq	:= "cdx"			//Extenção do arquivo que será deletada
local nCount 	:= 0

Local cMyUID 	:= "STWClearCDX"	//ID para reserva no APPSERVER
Local cChave 	:= "ClearCDX"		//CHAVE para reserva no APPSERVER
Local nValor 	:= 0				//Valor enviado para a Chave de memoria reservada
Local lRet 		:= .F.


//Varre o diretorio
aFiles := Directory( cDirComp + "*." + cExtArq, "D")

nCount := Len( aFiles )
For nX := 1 to nCount
	
	LjGrvLog("STWClearCDX","Arquivo: " + aFiles[nX,1] + " - Size: " + AllTrim(Str(aFiles[nX,2])) )
	
	//Deleta arquivo
	If FERASE(cDirComp + aFiles[nX,1]) == -1
		LjGrvLog("STWClearCDX","Falha ao excluir o arquivo: "+ aFiles[nX,1]) 
    Else
    	LjGrvLog("STWClearCDX","Arquivo:" + aFiles[nX,1] + " deletado com sucesso.")
  Endif

Next nX

//Atualiza o valor da chave de memoria para evitar que a limpeza das tabelas ocorra mais de uma vez
nValor := 1
lRet := VarSetX(cMyUID, cChave, nValor)
If(!lRet)
	LjGrvLog("STWClearCDX","Erro na atualização da chave: " + cChave)
EndIf

Return

