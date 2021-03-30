#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTOTAPI.CH"
#INCLUDE "LOJA1926.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "AUTODEF.CH"

Function LOJA1926 ; Return  // "dummy" function - Internal Use 

//Tipo de mensagem
#DEFINE _INICIALIZACAO	1					//Inicializando sitef
#DEFINE _TRANSACAO 		2					//Efetuando transacao


/*
	PARA HOMOLOGACAO SOFTWARE EXPRESS E CERTIFIED  
	Atentar para:                                                           
	
	1 - Criar e habilitar o parametro:
	"MV_LJHMTEF" Boleano = .T.    
	Ao habilitar o parametro "MV_LJHMTEF" a impressao de 3 em 3 linhas sera habilitada.
	alguns sleeps serao habilitados em momentos como fechamento de venda etc...
	
	2 - Usar SIGALOJA.DLL pois eha unica (Ate o momento) que aceita o comando de envio do relatorio gerencial de 3 em 3 linhas
	pois isso eh exigido uma vez que nao pode bufferizar os comprovantes na impressora.
	Para isso basta criar uma chave no  SmartClient\Sigaloja.ini como segue:
		[HOMOLOGACAO]
		homolog = 1        
		
	3 - Para homologacao do TOTVS PDV necessario compilar uma nova SIGALOJA.DLL retirando a mensagem de erro.
	
	4 -	Pois no TOTVS PDV ao exibir essa mensagem o sitema perde o foco, parecendo que esta travado.
	Exemplo: Function TrataRetornoBematech; Comentar a linha //MessageDlg( sMsg, mtError,[mbOK],0);
	Isso resolve pois no TOTVS PDV eh capturado o retorno e tratado internamente , nao precisa de MsgBOx.
	
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCComClisitef   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia os dados de todas as operacoes para o sitef  				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCComClisitef
   	
   	Data oTotvsApi														//Objeto do tipo LJCTotvsApi
   	Data lIniciado														//Indica se o sitef ja foi iniciado
   	Data nProxComan														//Proximo comando
   	Data nTipoCampo														//Tipo do campo retornado do sitef
   	Data nTamMin														//Tamanho minimo do campo
   	Data nTamMax														//Tamanho maximo do campo
   	Data cBuffer														//Area de transferencia de dados entre aplicacao e clisitef
   	Data nMaxBuffer														//Tamanho maximo do buffer
   	Data nContinua														//Controla se o fluxo (troca de informacoes) vai continuar
	Data oRetorno														//Objeto do tipo LJCRetornoSitef
	Data oFrmTef														//Objeto do tipo LJCFrmTef
	Data oTransacao														//Objeto do tipo LJADadosTransacao
	Data oGlobal														//Objeto do tipo LJCGlobal
	Data cClisitef														//Versao da clisitef32 ou clisitef64
	Data cClisitefI														//Versao da clisitef32I ou clisitef64i
	Data cTitTran														//Titulo da transacao
	Data oRedes															//HashTable com os tipos de redes autorizadas
	Data oTiposCart														//HashTable com os tipos de cartoes
	Data lLeuCMC7														//Indica se o documento foi lido atraves do CMC7
	Data lLog                                                           //Grava o Log
	Data cEntrada 														// Entrada de dados para a dll comando de digita็ใo do CPF pelo PinPad
	Data cSaida															// Saida de dados da dll comando de digita็ใo do CPF pelo PinPad

	Method New()
	Method EnviarCom()
	Method PrepParam()
	Method ConfSitef()
	Method IniciaFunc()
	Method ContinFunc()
	Method FinTrans()
	Method VerPinPad()
	Method MsgPinPad()
	Method LeCartao()
	Method IniciaCB()
	Method ValCodBar()
	Method ConfPinPad()
	Method EnvSitDir(oDadosTran)
	Method SetTrans()
	Method GetRetorno()
	Method Fechar()
	Method EnvVDLCons(oDadosTran)
	
	//Metodos internos
	Method RedeTpCart()
	Method LogEnvio()
	Method LogRetorno()
	Method GravarLog()
	Method TratarRet()
	Method VerDll()
	Method ExibirMsg()
	Method VerPend()
	Method FormatData()
	Method GrvArqCtrl(cNSU)
	Method Show()
	Method ValColeta()
	Method ValidarSup()
	Method ApgArqCtrl()
	Method TratarCmd()
	Method TrataCampo()
	Method LeDadChq()
	Method LeCodBar()   
	Method RetornaAdm(cCodBand, cForma, nParcelas, cCodRede)
	Method TefProcessa(lEndTef)
	Method ValidaParc()
	Method Lj1926VlCan(oArquivos, cDoc, lExistSL4)
	Method TrataAdm( nParcela)
	Method CPFPinPad( cEntrada, cSaida )
	
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCComClisitef.  			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - oTotvsApi) - Objeto do tipo LJCTotvsApi   				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(oTotvsApi) Class LJCComClisitef           
	
	Self:oTotvsApi		:= oTotvsApi
   	Self:lIniciado		:= .F.
   	Self:nProxComan		:= 0
   	Self:nTipoCampo		:= 0
   	Self:nTamMin		:= 0
   	Self:nTamMax		:= 0
   	Self:cBuffer		:= ""
   	Self:nMaxBuffer		:= 0
   	Self:nContinua		:= 0
	Self:oRetorno		:= Nil
	Self:oFrmTef		:= Nil
	Self:oGlobal		:= LJCGlobal():Global()
	Self:cClisitef		:= ""
	Self:cClisitefI		:= ""
	Self:cTitTran		:= ""
   	Self:oRedes			:= Nil
   	Self:oTiposCart		:= Nil
   	Self:oTransacao		:= Nil
   	Self:lLeuCMC7		:= .F. 
   	Self:lLog			:= NIL

   	//Carrega as redes e tipo de cartoes para efetuar as transacoes
   	Self:RedeTpCart()  
   	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnviarCom	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia o comando para TotvsApi.dll/so.	    	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnviarCom(oParams) Class LJCComClisitef
	
	Local cRetorno 	:= ""					//Retorno do metodo      
	
	If ::lLog == Nil       
	   ::lLog := ::oGlobal:GravarArq():Log():Tef():lHabilitad
	EndIf 
	
	If ::lLog
		::LogEnvio(oParams)
    EndIf
    
	cRetorno := ::oTotvsAPI:EnviarCom(oParams)

	If ::lLog
		::LogRetorno(cRetorno, oParams) 
	EndIf
		
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepParam	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara os parametros de envio para TotvsApi.dll/so				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepParam(aDados) Class LJCComClisitef
	
	Local oParamsApi	:= Nil							//Objeto do tipo LJCParamsAPI
	Local nCount		:= 0                            //Variavel contador
	
	oParamsApi := LJCParamsAPI():New()
	
	For nCount := 1 To Len(aDados)
				
		oParamsApi:ADD(nCount, LJCParamAPI():New(aDados[nCount]), .T.)
	Next 
	
Return oParamsApi 

/*----------------------------------------------------------------------------------
ฑฑบMetodo    ณConfSitef	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura o sitef													 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cEndIp) - Endereco IP do Sitef.	     				 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cLoja) - Numero da loja.			     				 บฑฑ
ฑฑบ			 ณEXPC3 (3 - cTerminal) - Codigo do terminal.	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno   ณNumerico														     บฑฑ
----------------------------------------------------------------------------------*/
Method ConfSitef(cEndIp, cLoja, cTerminal) Class LJCComClisitef
	
	Local nRetorno		:= 0			//Retorno do metodo
	Local oParamsApi	:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 		:= ""       	//Retorno do comando enviado
	Local cMensagem 	:= Alltrim(STFGetStat("PADMSG"))  				// Mensagem Padrao informada no Cadastro de Estacoes
	Local cCNPJEstb		:= SM0->M0_CGC									// CNPJ do estabelecimento
	local cParamAdic	:= "[ParmsClient=1=" + cCNPJEstb + ";2=" + _CNPJTOT + "]"  	// 1=CNPJ do estabelecimento 2=CNPJ da Software House

	LjGrvLog( NIL, "LOJA1926 - ConfSitef | Inicio do metodo ConfSitef", cParamAdic )

	//Verifica se o sitef ja foi iniciado 
	If !::lIniciado
				 
		//Prepara os parametros de envio no Clisitef
  
		//Se usa Cielo Premia chama outro inicializador
		If STFGetStat( "CIELOP" , .T. ) == "1"
			oParamsApi := ::PrepParam({CLISITEF, "ConfiguraIntSiTefInterativoEx", cEndIp, cLoja, cTerminal, "0" , "[VersaoAutomacaoCielo=TOTVSPOS10]"})			
		Else
			oParamsApi := ::PrepParam({CLISITEF, "ConfiguraIntSiTefInterativoEx", cEndIp, cLoja, cTerminal, "0" , cParamAdic})
		EndIf	
		    
	    cRetorno := ::EnviarCom(oParamsApi) 
	    
	    oParamsApi:DesTroy()
	    
	    oParamsApi := FreeObj(oParamsApi)
		nRetorno := Val(cRetorno)
		
		//Verifica se conseguiu conectar
		If nRetorno != 0
	    	::TratarRet(nRetorno, _INICIALIZACAO)	
		Else
			::lIniciado := .T.
			//Carrega versao da dll
			::VerDll()
			
			//Verifica se o pinpad esta conectado
			If ::VerPinPad() != 1
				::ExibirMsg(STR0001)//"Pin-Pad nใo configurado. Nใo serแ possํvel realizar transa็๕es de D้bito."
			Else
				// Exibe mensagem no visor do pinpad
				::MsgPinPad(cMensagem)
			EndIf
			
			//Verificar se existe alguma transacao pendente
			::VerPend()
		EndIf
	EndIf
		
Return nRetorno

/*----------------------------------------------------------------------------------
ฑฑบMetodo    ณIniciaFunc       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia uma transacao de tef										 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nFuncao) - Codigo da funcao.		     				 บฑฑ
ฑฑบ			 ณEXPC1 (2 - cRestricao) - Restricoes da transacao.		     		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
----------------------------------------------------------------------------------*/
Method IniciaFunc(nFuncao, cRestricao) Class LJCComClisitef
	
	Local nRetorno	:= 0			//Retorno do metodo
	Local oParamsApi 	:= Nil		//Objeto do tipo LJCParamsAPI
	Local cRetorno 	:= ""       	//Retorno do comando enviado
	Local cValor	:= ""			//Valor da transacao
	Local cData		:= ""			//Data da transacao
	Local cHora  	:= "" 			//Hora da transacao
	
	::oRetorno := LJCRetornoSitef():New()
	
	cValor := AllTrim(Transform(::oTransacao:nValor, "@E 999999999999.99"))
	
	::FormatData(::oTransacao:dData, ::oTransacao:cHora, @cData, @cHora)
			
	//Prepara os parametros de envio
	
	// Se usa cielo premia passa mais parametros de restricao
	If STFGetStat( "CIELOP" , .T. ) == "1"
		cRestricao += ";{TipoTratamento=4}"
	EndIf	
                        	   
	oParamsApi := ::PrepParam({CLISITEF, "IniciaFuncaoSiTefInterativo", AllTrim(Str(nFuncao)), cValor, ;
	                         	   AllTrim(Str(::oTransacao:nCupom)), cData, cHora, " ", cRestricao})

    cRetorno := ::EnviarCom(oParamsApi)
    oParamsApi:Destroy()  
    oParamsApi := FreeObj(oParamsApi)
    nRetorno := Val(cRetorno)
    
    If nRetorno == 10000
    	//Gravar arquivo de controle para confirmar ou desfazer a transacao
    	::GrvArqCtrl()
    	//Carrega tela do sitef para troca de informacoes
    	::Show()
    Else
    	::TratarRet(nRetorno, _TRANSACAO)
    EndIf
    	
Return nRetorno

/*----------------------------------------------------------------------------------
ฑฑบMetodo    ณContinFunc       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
------------------------------------------------------------------------------------
ฑฑบDesc.     ณContinuar o fluxo da transacao					 				 บฑฑ
------------------------------------------------------------------------------------
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
------------------------------------------------------------------------------------
ฑฑบParametrosณEXPC1 (1 - cBuffer) - Buffer a ser enviado ao sitef. 				 บฑฑ
ฑฑบ			 ณEXPN1 (2 - nContinua) - Indica se o fluxo continua.				 บฑฑ
------------------------------------------------------------------------------------
ฑฑบRetorno   ณNumerico														     บฑฑ
----------------------------------------------------------------------------------*/
Method ContinFunc(cBuffer, nContinua) Class LJCComClisitef

	Local nRetorno		:= 0			//Retorno do metodo
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 		:= ""       	//Retorno do comando enviado   
	Local lSaida 		:= .F.         	//Controle do laco
	Local cCMC7 		:= ""			//Utilizado na leitura do correspondente bancario atraves do CMC7
	Local cUltMSG		:= ""			//Guarda ultima mensagem informada ao usuario para o comando 	 
	Local cDROVLBPro	:= ""
	Local cValBrut		:= ""
	Local lControl		:= .F.			//Controle a execucao do processo 23 do TEf
	Local lEndTef 		:= .F.			//Controle do botao cancelar comando 23
	Local cQtdParc		:= "" 			//Quantidade de Parcelas
	Local lPharmSys		:= .F.
		
	Default cBuffer := ""
	Default nContinua := 0
	
	::cBuffer := cBuffer
	::nContinua := nContinua
	
	//Verifica se o fluxo continua e valida o dado coletado
	If nContinua != 0 .OR. ::ValColeta()
		
		While !lSaida			
			//Prepara os parametros de envio
			oParamsApi := ::PrepParam({CLISITEF, "ContinuaFuncaoSiTefInterativo", AllTrim(Str(::nProxComan)), ;
			                         	   AllTrim(Str(::nTipoCampo)), AllTrim(Str(::nTamMin)), AllTrim(Str(::nTamMax)), ;
			                              ::cBuffer, AllTrim(Str(Len(::cBuffer))), AllTrim(Str(::nContinua))})
	
		    cRetorno := ::EnviarCom(oParamsApi)
		    nRetorno := Val(cRetorno)
		    
		    If nRetorno == 10000
		    	
		    	::nProxComan	:= Val(oParamsApi:Elements(3):cParametro)
		    	::nTipoCampo	:= Val(oParamsApi:Elements(4):cParametro)
		    	::nTamMin		:= Val(oParamsApi:Elements(5):cParametro)
		    	::nTamMax		:= Val(oParamsApi:Elements(6):cParametro)
		    	::cBuffer		:= oParamsApi:Elements(7):cParametro
		    	::nMaxBuffer	:= Val(oParamsApi:Elements(8):cParametro)	
		    	::nContinua		:= Val(oParamsApi:Elements(9):cParametro)	
		    	
		    	oParamsApi:Destroy()   
		    	oParamsApi := FreeObj(oParamsApi)
		    	
		    	oParamsApi := NIL
		    	
		    	//Trata o conteudo do campo retornado
		    	//::TratarCmd()
	
				Do Case
				
					Case ::nProxComan == 0
						//Esta devolvendo um valor para, se desejado, ser armazenado pela automacao
						
						::TrataCampo()
						lSaida := .F. 
						cBuffer := ""
						nContinua := 0 
						::cBuffer := cBuffer
						::nContinua := nContinua
						//::ContinFunc()
						
					Case ::nProxComan == 1 .OR. ::nProxComan == 2 .OR. ::nProxComan == 3 .OR. ::nProxComan == 4
						//1 - Mensagem para o visor do operador
						//2 - Mensagem para o visor do cliente
						//3 - Mensagem para os dois visores
						//4 - Texto que devera ser utilizado como cabecalho na apresenta็ใo do menu (Comando 21)
						
						//Guarda a ultima mensagem informada ao usuario
						cUltMSG := ::cBuffer
			
						::oFrmTef:MsgVisor(::cBuffer) 
						Sleep(1000) 
						cBuffer := ""
						nContinua := 0 
						::cBuffer := cBuffer
						::nContinua := nContinua
						lSaida := .F.
					
					Case ::nProxComan == 11 .OR. ::nProxComan == 12 .OR. ::nProxComan == 13 .OR. ::nProxComan == 14
						//11 - Deve remover a mensagem apresentada no visor do operador
						//12 - Deve remover a mensagem apresentada no visor do cliente
						//13 - Deve remover mensagem apresentada no visor do operador e do cliente
						//14 - Deve limpar o texto utilizado como cabe็alho na apresenta็ใo do menu
						
						::oFrmTef:LimpaVisor()
						//::ContinFunc()  
						cBuffer := ""
						nContinua := 0 
						::cBuffer := cBuffer
						::nContinua := nContinua
					    lSaida := .F.
					    
					Case ::nProxComan == 20
						//Deve obter uma resposta do tipo SIM/NAO. 
						//No retorno o primeiro caracter presente em Buffer deve conter 0 se confirma e 1 se cancela
						If lPharmSys
							::nTipoCampo := -1
							::nTamMax  := 1
							::nTamMin  := 1
							::cBuffer  := "1"
							Loop
						EndIf

						::TrataCampo()   
						::cBuffer := ::oFrmTef:Questionar(::cBuffer)
						cBuffer := ::cBuffer
						nContinua := 0 
						::cBuffer := cBuffer
						::nContinua := nContinua

						lSaida := .F.
					    //::ContinFunc(::cBuffer)
						
					Case ::nProxComan == 21

						//Numero do Convenio
						If ::nTipoCampo == 4022
							::nProxComan := 4022	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 6
							::cBuffer    := "1"
							::nMaxBuffer := 18
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys := .T.
								Loop
							Endif
						Endif
						
						If lPharmSys
							::nTipoCampo:= -1
							::nTamMin   := 1
							::nTamMax   := 2   
							
							//Informado o numero do cartao do convenio
							If ::oTransacao:aVDLink[1,5] == 560	//Funcional card, solicita digitacao do cartao do convenio              
								::cBuffer	:= "2"               				   
							ElseIf !Empty(::oTransacao:aVDLink[1,3])
								::cBuffer	:= "1"               
							//Informado o numero do CPF do cliente
							Else
								::cBuffer  	:= "2"
							Endif

							::nMaxBuffer := 2
							Loop
						EndIf

						//Deve apresentar um menu de opcoes e permitir que o usuario selecione uma delas. 
						//Na chamada o parametro Buffer contem as opcoes no formato 1:texto;2:texto;...i:Texto;... 
						//A rotina da aplicacao deve apresentar as opcoes da forma que ela desejar 
						//(nao sendo necessario incluir os indices 1,2, ...) e apos a selecao feita pelo 
						//usuario, retornar em Buffer o indice i escolhido pelo operador (em ASCII)

						::oFrmTef:MenuOpcoes(::cBuffer)
						//Valida็ใo para ter certeza da forma de pagamento selecionada
						If ::nTipoCampo == 731 .And. ::oTransacao:nTipoTrans == 7 //Recarga Celular
							 ::oTransacao:cFormaPgto := ::cBuffer
						EndIf

						lSaida := .T.

					Case ::nProxComan == 22
						//Deve aguardar uma tecla do operador utilizada quando se deseja que
						//o operador seja avisado de alguma mensagem apresentada na tela
						
						::oFrmTef:Confirmar(::cBuffer)
						lSaida := .T.
						
					Case ::nProxComan == 23
						//Este comando indica que a rotina esta perguntando para a aplica็ใo se ele   
						//deseja interromper o processo de coleta de dados ou nao. Esse codigo ocorre  
						//quando a CliSiTEF esta acessando algum periferico e permite que a automacao  
						//interrompa esse acesso (por exemplo: aguardando a passagem de um cartao pela 
						//leitora ou a digitacao de senha pelo cliente)
						
						/*                                         
							Na homologacao abrir uma janela em outra thead com a funcao processa para controlar o botao
							cancela pois no fluxo normal o mesmo nao funcionava.
							O comando 23 arquarda um cancelamento do usuario enquanto o TEf processa alguma outra coisa
							ex: Insira o cartao ou digite a senha
						*/	
			
					 	If( SuperGetMV("MV_LJHMTEF", ,.F.) .AND. !Empty(cUltMSG) )
						
							lEndTef := .F.
							
							Processa( {| lEndTef | lControl := ::TefProcessa(@lEndTef) } , "" , cUltMSG , .T. )
	
							cBuffer := ""
							nContinua := 0 
							::cBuffer := cBuffer
							::nContinua := nContinua
							lSaida := .F.
							If lControl
								nRetorno := -6
								Exit
							EndIF
							
							Loop
							
						Else
						
							cBuffer := ""
							nContinua := 0 
							::cBuffer := cBuffer
							::nContinua := nContinua	
						
						EndIf

					Case ::nProxComan == 30
						//Deve ser lido um campo cujo tamanho esta entre TamMinimo e TamMaximo. 
						//O campo lido deve ser devolvido em Buffer
						If ::nTipoCampo == 500  
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin,  ::nTamMax, , .T.)
														
						ElseIf ::nTipoCampo == 505
							//Numero de parcelas
							If ::oTransacao:nParcela > 1
								cQtdParc := Padr(::oTransacao:nParcela,::nTamMax)
							Else
								cQtdParc := Space(::nTamMax)
							EndIf
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, cQtdParc , .F. , .T.)
						
						ElseIf ::nTipoCampo == 506 
							//Data do Pre-Datado no formato DDMMAAAA
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, Space(::nTamMax) , .F. , .T. )
	
						ElseIf ::nTipoCampo == 508 
							//Intervalo em dias entre parcelas
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, "30")
							
						ElseIf ::nTipoCampo == 515
							//Data da transacao a ser cancelada (DDMMAAAA) ou a ser re-impressa	
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, StrZero(Day(::oTransacao:dData), 2) + StrZero(Month(::oTransacao:dData), 2) + Str(Year(::oTransacao:dData), 4))			
						
						ElseIf ::nTipoCampo == 1023
							::nProxComan	:= 1023	
							::nTipoCampo	:= 0		
							::nTamMin   	:= 1
							::nTamMax     	:= 10
							::cBuffer     	:= ::oTransacao:aVDLink[1,6]
							::nMaxBuffer	:= 10
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys	:= .T.
								Loop
							Endif
						ElseIf ::nTipoCampo == 1024
							::nProxComan	:= 1024	
							::nTipoCampo	:= 0		
							::nTamMin   	:= 1
							::nTamMax     	:= 2
							::cBuffer     	:= ::oTransacao:aVDLink[1,7]
							::nMaxBuffer	:= 10
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys	:= .T.
								Loop
							Endif

						ElseIf ::nTipoCampo == 1025
							cDROVLBPro := T_DROVLBPro(Alltrim(Self:oFrmTef:cGetDados),.T.)
							If Empty(cDROVLBPro)
								MsgAlert("Codigo de Produto Invแlido")
								::nProxComan := 30	
								::nTipoCampo := 1012		
								::nTamMin    := 1
								::nTamMax    := 30
								::nMaxBuffer := 30
								Loop
							Endif
									
							::nProxComan := 1025	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 35
							::cBuffer    := Alltrim(Substr(cDROVLBPro,08,35))
							::nMaxBuffer := 30
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys := .T.
								Loop		
							Endif
						ElseIf ::nTipoCampo == 1026
							// Antes de solicitar a quantidade, verifica existncia do produto
							If ::oTransacao:aVDLink[1,5] == 540
								cDROVLBPro := T_DROVLBPro(Alltrim(Self:oFrmTef:cGetDados), .T.)
								If Empty(cDROVLBPro)
									MsgAlert("C๓digo de Produto Invแlido")
									::nProxComan := 30	
									::nTipoCampo := 1012		
									::nTamMin    := 1
									::nTamMax    := 30
									::nMaxBuffer := 30
									Loop
								Endif
							Endif
									
							::nProxComan := 1026	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 30
							::cBuffer    := Alltrim(Substr(cDROVLBPro,76,13))
							::nMaxBuffer := 30
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys		:= .T.
								Loop
							Endif

						//Numero de Autorizacao PBM PharmaSystem
						ElseIf ::nTipoCampo == 1030  			
							::nProxComan := 1030	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 9
							::nMaxBuffer := 18
							::cBuffer    := ::oTransacao:aVDLink[1,1]						
							lPharmSys	 := .T.
							Loop		
						
						//Numero do Convenio
						ElseIf ::nTipoCampo == 4022
							::nProxComan := 4022	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 6
							::cBuffer    := ::oTransacao:aVDLink[1,2]
							::nMaxBuffer := 18     
							If !Empty(::oTransacao:aVDLink[1,5])
								lPharmSys := .T.
								Loop		
							Endif
						Else
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax)
						EndIf

						If lPharmSys
							//CPF do cliente
							If ::nTipoCampo == 502
								::nProxComan := 502	
								::nTipoCampo := 0		
								::nTamMin    := 1
								::nTamMax    := 11  
								::cBuffer    := ::oTransacao:aVDLink[1][4]			
								::nMaxBuffer := 29     
								Loop						
							Endif	
				
							//Numero do Cartao	
							If ::nTipoCampo == 512
								::nProxComan := 512	
								::nTipoCampo := 0		
								::nTamMin    := 1
								::nTamMax    := 2  
								::cBuffer    := ::oTransacao:aVDLink[1][3]			
								::nMaxBuffer := 18     
								Loop						
							Endif
						Endif

					    lSaida := .T.
					Case ::nProxComan == 31
					    //Deve ser lido o numero de um cheque. A coleta pode ser feita via leitura de CMC-7 ou pela 
					    //digitacao da primeira linha do cheque. No retorno deve ser devolvido em Buffer "0:" ou "1:"  
					    //seguido do numero coletado manualmente ou pela leitura do CMC-7, respectivamente. Quando o  
					    //numero for coletado manualmente o formato eh o seguinte: Compensacao (3), Banco (3), Agencia (4), 
					    //C1 (1), ContaCorrente (10), C2 (1), Numero do Cheque (6) e C3 (1), nesta ordem. Notar que 
					    //estes campos sao os que estao na parte superior de um cheque e na ordem apresentada. Sugerimos  
					    //que na coleta seja apresentada uma interface que permita ao operador identificar e digitar  
					    //adequadamente estas informacoes de forma que a consulta nao seja feita com dados errados,  
					    //retornando como bom um cheque com problemas
						
						::oFrmTef:MsgVisor(::cBuffer)
				
						::LeDadChq(cCMC7)
									
						::ContinFunc("0:" + StrZero(::oRetorno:nCompensa, 3) + ;
												StrZero(::oRetorno:nBanco, 3) + ;
												StrZero(::oRetorno:nAgencia, 4) + ;
												StrZero(::oRetorno:nC1, 1) + ;
												StrZero(::oRetorno:nConta, 10) + ;
												StrZero(::oRetorno:nC2, 1) + ; 
												StrZero(::oRetorno:nCheque, 6) + ;
												StrZero(::oRetorno:nC3, 1)) 
						lSaida := .T.  
					
					Case ::nProxComan == 34
						//Deve ser lido um campo monetario ou seja, aceita o delimitador de 
						//centavos e devolvido no parโmetro Buffer
						
						If ::nTipoCampo == 146
							//A rotina esta sendo chamada para ler o Valor a ser cancelado. Caso o  
							//aplicativo de automacao possua esse valor, pode apresenta-lo para o 
							//operador e permitir que ele confirme o valor antes  de passa-lo devolve-lo 
							//para a rotina. Caso ele nใo possua esse valor, deve le-lo. 
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("N", ::nTamMin, ::nTamMax, ::oTransacao:nValor)
						
						ElseIf ::nTipoCampo == 4016		
							cValBrut := StrZero(Val(StrTran(Alltrim(Str((Val(Substr(cDROVLBPro,55,10))/100),10,2)), '.', '', 1)),7) 
							::nProxComan := 4016	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 10
							::cBuffer    := cValBrut  //Valor Bruto, pego da tabela SB0/DA0
							::nMaxBuffer := 18     
							lPharmSys := .T.
							Loop				
						ElseIf ::nTipoCampo == 4017
							cValBrut := StrZero(Val(StrTran(Alltrim(Str((Val(Substr(cDROVLBPro,55,10))/100),10,2)), '.', '', 1)),7)			
							::nProxComan := 4017	
							::nTipoCampo := 0		
							::nTamMin    := 1
							::nTamMax    := 6
							::cBuffer    := cValBrut  //Valor Bruto, pego da tabela SB0/DA0
							::nMaxBuffer := 18     
							lPharmSys	:= .T.
							Loop
						Else
							::oFrmTef:MsgVisor(::cBuffer)
							::oFrmTef:Capturar("N", ::nTamMin, ::nTamMax)
						EndIf

						lSaida := .T. 
					
					Case ::nProxComan == 35
					//Deve ser lido um c๓digo em barras ou o mesmo deve ser coletado manualmente. 
					//No retorno Buffer deve conter "0:" ou "1:" seguido do c๓digo em barras coletado manualmente 
					//ou pela leitora, respectivamente. Cabe ao aplicativo decidir se a coleta serแ manual ou atrav้s 
					//de uma leitora. Caso seja coleta manual, recomenda-se seguir o procedimento descrito na rotina 
					//ValidaCampoCodigoEmBarras de forma a tratar um c๓digo em barras da forma mais gen้rica possํvel, 
					//deixando o aplicativo de automa็ใo independente de futuras altera็๕es que possam surgir nos formatos em barras. 
					//No retorno do Buffer tamb้m pode ser passado "2:", indicando que a coleta foi cancelada, por้m o fluxo 
					//nใo serแ interrompido, logo no caso de pagamentos m๚ltiplos, todos os documentados coletados anteriormente 
					//serใo mantidos e o fluxo retomado, permitindo a efetiva็ใo de tais pagamentos.
					    
					    ::lLeuCMC7 := .F.
					    
						::oFrmTef:MsgVisor(::cBuffer)
					
						If ::LeCodBar(@cCMC7)
							::lLeuCMC7 := .T.
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, cCMC7)
						Else
							::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax)			
						EndIf
						lSaida := .T. 			
					
					Otherwise
					lSaida := .T. 	
				EndCase
		    
		    ElseIf nRetorno == 0
		    	//Transacao OK
		    	::oRetorno:lTransOK := .T.
				
				//Grava o arquivo com o numero do NSU gerado na transacao
				::GrvArqCtrl(Self:oRetorno:cNSUAUTO)
				                                 
				//Na homologacao Esperar alguns segundos 
				//com a msg de confirmacao na tela
				If SuperGetMV("MV_LJHMTEF", ,.F.)
					Sleep(3000)
				EndIf	
				
				//Controla o numero de cartoes usados na venda
				//Usado na homologacao
				STIUsedCard()
					
		    	::oFrmTef:Fechar()
		    	lSaida := .T.
		    Else
		    	//Apaga o arquivo de controle
		    	::ApgArqCtrl()
		    	//Trata retorno
		    	::TratarRet(nRetorno, _TRANSACAO)
	
		    	::oFrmTef:Fechar()  
		    	lSaida := .T.
		    EndIf
		End
		 
	    If ValType(oParamsApi) == "O"
	    	oParamsApi:Destroy() 
	    	oParamsApi := FreeObj(oParamsApi)
	    	oParamsApi := NIL
	    EndIf
	    
	 EndIf
				  
Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMsgPinPad	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia uma mensagem para o pinpad					 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem do pinpad.	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MsgPinPad(cMensagem) Class LJCComClisitef
	
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 		:= ""       	//Retorno do comando enviado	
					
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "EscreveMensagemPermanentePinPad", cMensagem})
    
    cRetorno := ::EnviarCom(oParamsApi) 
    
    oParamsApi:Destroy() 
    oParamsApi := FreeObj(oParamsApi)
	
Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLeCartao	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe o cartao no pinpad								 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Msg exibida no pinpad.     				 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cTrilha1) - Trilha 1 do cartao.	     				 บฑฑ
ฑฑบ			 ณEXPC3 (3 - cTrilha2) - Trilha 2 do cartao.	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCartao(cMensagem, cTrilha1, cTrilha2) Class LJCComClisitef

	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 		:= ""       	//Retorno do comando enviado	
						
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "LeCartaoDireto", cMensagem, cTrilha1, cTrilha2})
    
    cRetorno := ::EnviarCom(oParamsApi)
    
    If Val(cRetorno) == 0
		cTrilha1 := oParamsApi:Elements(4):cParametro
		cTrilha2 := oParamsApi:Elements(5):cParametro
	EndIf 
	
	oParamsApi:Destroy()
	oParamsApi := FreeObj(oParamsApi)
Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIniciaCB         บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia uma transacao de correspondente bancario	 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRestricao) - Restricao da transacao.		     		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IniciaCB(cRestricao) Class LJCComClisitef
	
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 		:= ""       	//Retorno do comando enviado
	Local cData			:= ""			//Data da transacao
	Local cHora			:= "" 			//Hora da transacao
	Local nRetorno		:= 0			//Retorno do metodo
	
	::oRetorno := LJCRetornoSitef():New()
	
	//Formata os dados
	::FormatData(::oTransacao:dData, ::oTransacao:cHora, @cData, @cHora)
			
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "CorrespondenteBancarioSiTefInterativo", AllTrim(Str(::oTransacao:nCupom)), cData, ;
								   cHora, "1", cRestricao})
    //Envia o comando
    cRetorno := ::EnviarCom(oParamsApi)
    nRetorno := Val(cRetorno)
    
    If nRetorno == 10000
    	//Gravar arquivo de controle para confirmar ou desfazer a transacao
    	::GrvArqCtrl()
    	//Carrega tela do sitef para troca de informacoes
    	::Show()
    Else
    	::TratarRet(nRetorno, _TRANSACAO)
    EndIf
	
	oParamsApi:Destroy() 
	oParamsApi := FreeObj(oParamsApi)
Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValCodBar        บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o codigo barra do CB						 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cDados) - Codigo de barra.			     				 บฑฑ
ฑฑบ			 ณEXPC2 (2 - nTipo) - Tipo de documento. 0 - Arrecadacao ; 1 - Tituloบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValCodBar(cDados, nTipo) Class LJCComClisitef

	Local cRetorno 		:= ""       	//Retorno do comando enviado
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
			
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "ValidaCampoCodigoEmBarras", cDados, AllTrim(Str(nTipo))})

    cRetorno := ::EnviarCom(oParamsApi)
    
    oParamsApi:Destroy()
    oParamsApi := FreeObj(oParamsApi)
    
Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConfPinPad       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua uma confirmacao no pinpad					 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem.				     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfPinPad(cMensagem) Class LJCComClisitef
	
	Local cRetorno 		:= ""       	//Retorno do comando enviado
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
			
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "LeSimNaoPinPad", cMensagem})

    cRetorno := ::EnviarCom(oParamsApi) 
    
    oParamsApi:Destroy()
    oParamsApi := FreeObj(oParamsApi)
    
Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnvSitDir        บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia uma transacao atraves do mecanismo de acesso direto do sitef บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoDadosTran - Dados do acesso direto ao sitef						 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvSitDir(oDadosTran) Class LJCComClisitef
				 
	Local cRetorno 		:= ""       	//Retorno do comando enviado
	Local oParamsApi	:= Nil			//Objeto do tipo LJCParamsAPI
							
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "EnviaRecebeSitefDireto", AllTrim(Str(oDadosTran:nRedeDest)), ;
								   AllTrim(Str(oDadosTran:nFuncSitef)), AllTrim(Str(oDadosTran:nOffSetCar)), ;
								   oDadosTran:cDadosTx, AllTrim(Str(oDadosTran:nTaDadosTx)), oDadosTran:cDadosRx, ;
	                               AllTrim(Str(oDadosTran:nTaDadosRx)), AllTrim(Str(oDadosTran:nCodResp)), ;
	                               AllTrim(Str(oDadosTran:nTempEspRx)), oDadosTran:cCupomFisc, oDadosTran:cDataFisc, ;
	                               oDadosTran:cHorario, oDadosTran:cOperador, AllTrim(Str(oDadosTran:nTpTrans))})

    cRetorno := ::EnviarCom(oParamsApi)
    
	//Carrega o retorno
    oDadosTran:nRedeDest 	:= Val(oParamsApi:Elements(3):cParametro)
    oDadosTran:nFuncSitef 	:= Val(oParamsApi:Elements(4):cParametro)
	oDadosTran:nOffSetCar 	:= Val(oParamsApi:Elements(5):cParametro)
    oDadosTran:cDadosTx 	:= oParamsApi:Elements(6):cParametro
    oDadosTran:nTaDadosTx 	:= Val(oParamsApi:Elements(7):cParametro)
	oDadosTran:cDadosRx 	:= oParamsApi:Elements(8):cParametro
    oDadosTran:nTaDadosRx 	:= Val(oParamsApi:Elements(9):cParametro)
	oDadosTran:nCodResp 	:= Val(oParamsApi:Elements(10):cParametro)
	oDadosTran:nTempEspRx 	:= Val(oParamsApi:Elements(11):cParametro)
	oDadosTran:cCupomFisc 	:= oParamsApi:Elements(12):cParametro
    oDadosTran:cDataFisc 	:= oParamsApi:Elements(13):cParametro
    oDadosTran:cHorario 	:= oParamsApi:Elements(14):cParametro
    oDadosTran:cOperador 	:= oParamsApi:Elements(15):cParametro
    oDadosTran:nTpTrans 	:= Val(oParamsApi:Elements(16):cParametro)
    
	oParamsApi:Destroy() 
	oParamsApi := FreeObj(oParamsApi)
Return Val(cRetorno)				 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTratarCmd   	   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata o conteudo do campo retornado do sitef		 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TratarCmd() Class LJCComClisitef
	
	Local cCMC7 := ""							//Utilizado na leitura do correspondente bancario atraves do CMC7

	
	Do Case
	
		Case ::nProxComan == 0
			//Esta devolvendo um valor para, se desejado, ser armazenado pela automacao
			
			::TrataCampo()
			::ContinFunc()
			
		Case ::nProxComan == 1 .OR. ::nProxComan == 2 .OR. ::nProxComan == 3 .OR. ::nProxComan == 4
			//1 - Mensagem para o visor do operador
			//2 - Mensagem para o visor do cliente
			//3 - Mensagem para os dois visores
			//4 - Texto que devera ser utilizado como cabecalho na apresenta็ใo do menu (Comando 21)

			::oFrmTef:MsgVisor(::cBuffer) 
			Sleep(1000)
			::ContinFunc()
		
		Case ::nProxComan == 11 .OR. ::nProxComan == 12 .OR. ::nProxComan == 13 .OR. ::nProxComan == 14
			//11 - Deve remover a mensagem apresentada no visor do operador
			//12 - Deve remover a mensagem apresentada no visor do cliente
			//13 - Deve remover mensagem apresentada no visor do operador e do cliente
			//14 - Deve limpar o texto utilizado como cabe็alho na apresenta็ใo do menu
			
			::oFrmTef:LimpaVisor()
			::ContinFunc()
		
		Case ::nProxComan == 20
			//Deve obter uma resposta do tipo SIM/NAO. 
			//No retorno o primeiro caracter presente em Buffer deve conter 0 se confirma e 1 se cancela
			
			::cBuffer := ::oFrmTef:Questionar(::cBuffer)
			::ContinFunc(::cBuffer)
			
		Case ::nProxComan == 21
			//Deve apresentar um menu de opcoes e permitir que o usuario selecione uma delas. 
			//Na chamada o parametro Buffer contem as opcoes no formato 1:texto;2:texto;...i:Texto;... 
			//A rotina da aplicacao deve apresentar as opcoes da forma que ela desejar 
			//(nao sendo necessario incluir os indices 1,2, ...) e apos a selecao feita pelo 
			//usuario, retornar em Buffer o indice i escolhido pelo operador (em ASCII)
						
			::oFrmTef:MenuOpcoes(::cBuffer)		    
		
		Case ::nProxComan == 22
			//Deve aguardar uma tecla do operador utilizada quando se deseja que
			//o operador seja avisado de alguma mensagem apresentada na tela
			
			::oFrmTef:Confirmar(::cBuffer)
			
		Case ::nProxComan == 23
			//Este comando indica que a rotina esta perguntando para a aplica็ใo se ele   
			//deseja interromper o processo de coleta de dados ou nao. Esse codigo ocorre  
			//quando a CliSiTEF esta acessando algum periferico e permite que a automacao  
			//interrompa esse acesso (por exemplo: aguardando a passagem de um cartao pela 
			//leitora ou a digitacao de senha pelo cliente)
			Sleep(1000)
			::ContinFunc()
			
		Case ::nProxComan == 30
			//Deve ser lido um campo cujo tamanho esta entre TamMinimo e TamMaximo. 
			//O campo lido deve ser devolvido em Buffer
			
			If ::nTipoCampo == 505
				//Numero de parcelas
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, cValToChar(::oTransacao:nParcela))
			
			ElseIf ::nTipoCampo == 506 
				//Data do Pre-Datado no formato DDMMAAAA
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, StrZero(Day(::oRetorno:dPredatado), 2) + StrZero(Month(::oRetorno:dPredatado), 2) + Str(Year(::oRetorno:dPredatado), 4))
						
			ElseIf ::nTipoCampo == 508 
				//Intervalo em dias entre parcelas
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, "30")
				
			ElseIf ::nTipoCampo == 515
				//Data da transacao a ser cancelada (DDMMAAAA) ou a ser re-impressa	
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, StrZero(Day(::oTransacao:dData), 2) + StrZero(Month(::oTransacao:dData), 2) + Str(Year(::oTransacao:dData), 4))			
			
			Else
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax)
			EndIf
		
		Case ::nProxComan == 31
		    //Deve ser lido o numero de um cheque. A coleta pode ser feita via leitura de CMC-7 ou pela 
		    //digitacao da primeira linha do cheque. No retorno deve ser devolvido em Buffer "0:" ou "1:"  
		    //seguido do numero coletado manualmente ou pela leitura do CMC-7, respectivamente. Quando o  
		    //numero for coletado manualmente o formato eh o seguinte: Compensacao (3), Banco (3), Agencia (4), 
		    //C1 (1), ContaCorrente (10), C2 (1), Numero do Cheque (6) e C3 (1), nesta ordem. Notar que 
		    //estes campos sao os que estao na parte superior de um cheque e na ordem apresentada. Sugerimos  
		    //que na coleta seja apresentada uma interface que permita ao operador identificar e digitar  
		    //adequadamente estas informacoes de forma que a consulta nao seja feita com dados errados,  
		    //retornando como bom um cheque com problemas
			
			::oFrmTef:MsgVisor(::cBuffer)

	
			::LeDadChq(cCMC7)
						
			::ContinFunc("0:" + StrZero(::oRetorno:nCompensa, 3) + ;
									StrZero(::oRetorno:nBanco, 3) + ;
									StrZero(::oRetorno:nAgencia, 4) + ;
									StrZero(::oRetorno:nC1, 1) + ;
									StrZero(::oRetorno:nConta, 10) + ;
									StrZero(::oRetorno:nC2, 1) + ; 
									StrZero(::oRetorno:nCheque, 6) + ;
									StrZero(::oRetorno:nC3, 1))   
		
		Case ::nProxComan == 34
			//Deve ser lido um campo monetario ou seja, aceita o delimitador de 
			//centavos e devolvido no parโmetro Buffer
			
			If ::nTipoCampo == 146
				//A rotina esta sendo chamada para ler o Valor a ser cancelado. Caso o  
				//aplicativo de automacao possua esse valor, pode apresenta-lo para o 
				//operador e permitir que ele confirme o valor antes  de passa-lo devolve-lo 
				//para a rotina. Caso ele nใo possua esse valor, deve le-lo. 
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("N", ::nTamMin, ::nTamMax, ::oTransacao:nValor)
			
			Else
				::oFrmTef:MsgVisor(::cBuffer)
				::oFrmTef:Capturar("N", ::nTamMin, ::nTamMax)
			EndIf
		
		Case ::nProxComan == 35
		//Deve ser lido um c๓digo em barras ou o mesmo deve ser coletado manualmente. 
		//No retorno Buffer deve conter "0:" ou "1:" seguido do c๓digo em barras coletado manualmente 
		//ou pela leitora, respectivamente. Cabe ao aplicativo decidir se a coleta serแ manual ou atrav้s 
		//de uma leitora. Caso seja coleta manual, recomenda-se seguir o procedimento descrito na rotina 
		//ValidaCampoCodigoEmBarras de forma a tratar um c๓digo em barras da forma mais gen้rica possํvel, 
		//deixando o aplicativo de automa็ใo independente de futuras altera็๕es que possam surgir nos formatos em barras. 
		//No retorno do Buffer tamb้m pode ser passado "2:", indicando que a coleta foi cancelada, por้m o fluxo 
		//nใo serแ interrompido, logo no caso de pagamentos m๚ltiplos, todos os documentados coletados anteriormente 
		//serใo mantidos e o fluxo retomado, permitindo a efetiva็ใo de tais pagamentos.
		    
		    ::lLeuCMC7 := .F.
		    
			::oFrmTef:MsgVisor(::cBuffer)
		
			If ::LeCodBar(@cCMC7)
				::lLeuCMC7 := .T.
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, cCMC7)
			Else
				::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax)			
			EndIf
						
		Otherwise
			
	EndCase		
		
Return Nil

/*----------------------------------------------------------------------------------
ฑฑบMetodo    ณTrataCampo   	   บAutor  ณVendas Clientes     บ Data ณ  12/11/08   บฑฑ
------------------------------------------------------------------------------------
ฑฑบDesc.     ณTratar o tipo campo retornado do sitef							 บฑฑ
------------------------------------------------------------------------------------
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
------------------------------------------------------------------------------------
ฑฑบRetorno   ณ																     บฑฑ
----------------------------------------------------------------------------------*/
Method TrataCampo() Class LJCComClisitef  
	Local nParcela	:= 1
	Local cBuffer	:= ""
	Local nX		:= 0
	Local nY 		:= 0

	//Tratamento para retirar os caracteres especiais	 
	If !Empty(AllTrim(::cBuffer))
		LjGrvLog( Nil, "::cBuffer - antes de LjRmvAcent: ", AllTrim(::cBuffer) )
		cBuffer	:= LjRmvAcent(Alltrim(::cBuffer))
		::cBuffer := cBuffer
		LjGrvLog( Nil, "cBuffer - depois de LjRmvAcent: ", AllTrim(cBuffer) )
	EndIf
   
    Do Case
	
		Case ::nTipoCampo == -1
			//Nao existem informacoes que podem/devem ser tratadas pela automacao
		Case ::nTipoCampo == 0
			//A rotina esta sendo chamada para indicar que acabou de coletar os dados 
			//da transacao e ira iniciar a interacao com o SiTEF para obter a autorizacao
		Case ::nTipoCampo >= 10 .AND. ::nTipoCampo <= 99
			//Informa qual a opcao selecionada no menu de navegacao de transacoes seguindo
			//a mesma codificacao utilizada para definir as restricoes no pagamento  
			//descritas no item 5
			::oRetorno:nCodTrans := ::nTipoCampo 
		
		Case ::nTipoCampo == 100 .OR. ::nTipoCampo == 110
			//Contem a modalidade de pagamento no formato xxnn xx corresponde ao grupo da 
			//modalidade e nn ao sub-grupo. Vide tabela no final deste documento descrevendo 
			//os possํveis valores de xx e nn.
			::oRetorno:cCodMod := AllTrim(::cBuffer)
			
			::oRetorno:lJurosLoja := IIF(SubStr(::oRetorno:cCodMod, 3, 2) == "02", .T., .F.)	
		
		Case ::nTipoCampo == 101 .OR. ::nTipoCampo == 111
			//Contem o texto real da modalidade de pagamento que pode ser memorizado pela aplicacao 
			//caso exista essa necessidade. Descreve por extenso o par xxnn fornecido em 100
			::oRetorno:cDescMod := AllTrim(::cBuffer)    
		
		Case ::nTipoCampo == 102
			//Cont้m o texto descritivo da modalidade de pagamento que deve ser impresso no cupon fiscal 
			//(p/ex: T.E.F., Cheque, etc...)
			::oRetorno:cDesModCup := AllTrim(::cBuffer)
				
		Case ::nTipoCampo == 105
			//Contem a data e hora da transacao no formato AAAAMMDDHHMMSS
			::oRetorno:dData := CTOD(SubStr(::cBuffer, 7, 2) + "/" + SubStr(::cBuffer, 5, 2) + "/" + SubStr(::cBuffer, 1, 4))
			::oRetorno:cHora := SubStr(::cBuffer, 9, 2) + ":" + SubStr(::cBuffer, 11, 2) + ":" + SubStr(::cBuffer, 13, 2)

		Case ::nTipoCampo == 106
			// ID da Administradora da Carteira Virtual, Ex: MERCADO PAGO, ITI, IzPay
			::oRetorno:cIDAdmCV := SubStr(AllTrim(::cBuffer),1,TamSX3("MDE_CODSIT")[1])

			If ::oRedes:Contains(::oRetorno:cIDAdmCV)
				::oRetorno:cRede :=  ::oRedes:ElementKey(::oRetorno:cIDAdmCV)
			Else
				::oRetorno:cRede := ::oRedes:Elements(1)
			EndIf

			LjGrvLog( Nil, "nTipoCampo -> 106 - Codigo da institui็ใo financeira da Carteira Virtual retornado pelo SITEF: ", AllTrim(::cBuffer) )
			
		Case ::nTipoCampo == 107
			// Administradora da Carteira Virtual, Ex: MERCADO PAGO, ITI, IzPay
			::oRetorno:cAdmCV := AllTrim(::cBuffer)
			LjGrvLog( Nil, "nTipoCampo -> 107 - Institui็ใo financeira da Carteira Virtual retornado pelo SITEF: ", AllTrim(::cBuffer) )

		Case ::nTipoCampo == 120
			//Buffer contem a linha de autenticacao do cheque para ser impresso no verso do mesmo
			::oRetorno:cAutentica := AllTrim(::cBuffer)
			STFMessage("TEF", "POPUP", ::cBuffer )
			STFShowMessage( "TEF")	

		Case ::nTipoCampo == 121
			//Buffer contem a primeira via do comprovante de pagamento (via do cliente) a ser impressa 
			//na impressora fiscal. Essa via, quando possํvel, he reduzida de forma a ocupar poucas linhas 
			//na impressora. Pode ser um comprovante de venda ou administrativo
			LjGrvLog( Nil, "nTipoCampo -> 121 - Primeira via do comprovante de pagamento (via do cliente) - antes de LjRmvAcent: ", AllTrim(::cBuffer) )
             ::oRetorno:cViaCliente	:= LjRmvAcent(::cBuffer)
			LjGrvLog( Nil, "nTipoCampo -> 121 - Primeira via do comprovante de pagamento (via do cliente) - depois de LjRmvAcent: ", AllTrim( ::oRetorno:cViaCliente) )

		Case ::nTipoCampo == 122
			//Buffer cont้m a segunda via do comprovante de pagamento (via do caixa) a ser impresso na 
			//impressora fiscal. Pode ser um comprovante de venda ou administrativo
			LjGrvLog( Nil, "nTipoCampo -> 122 - Segunda via do comprovante de pagamento (via do caixa) - antes de LjRmvAcent: ", AllTrim(::cBuffer) )
			::oRetorno:cViaCaixa := LjRmvAcent(::cBuffer)
			LjGrvLog( Nil, "nTipoCampo -> 122 - Segunda via do comprovante de pagamento (via do caixa) - depois de LjRmvAcent: ", AllTrim(::oRetorno:cViaCaixa) )
		
		Case ::nTipoCampo == 123
			//Indica que os comprovantes que serใo entregues na seqü๊ncia sใo de determinado tipo:
	        //COMPROVANTE_COMPRAS = "00"
	        //COMPROVANTE_VOUCHER = "01"
	        //COMPROVANTE_CHEQUE = "02"
	        //COMPROVANTE_PAGAMENTO = "03"
	        //COMPROVANTE_GERENCIAL = "04"
	        //COMPROVANTE_CB = "05"
	        //COMPROVANTE_RECARGA_CELULAR = "06"
	        //COMPROVANTE_RECARGA_BONUS = "07"
	        //COMPROVANTE_RECARGA_PRESENTE = "08"
	        //COMPROVANTE_RECARGA_SP_TRANS = "09"
	        //COMPROVANTE_MEDICAMENTOS = "10"
			::oRetorno:cTpComprov := AllTrim(::cBuffer)
				
		Case ::nTipoCampo == 130
			//Indica, na coleta, que o campo em questใo ้ o valor do troco em dinheiro a ser devolvido para o cliente. 
			//Na devolu็ใo de resultado (Comando = 0) cont้m o valor efetivamente aprovado para o troco
			::oRetorno:nVlrSaque	:= Round( Val(StrTran(::cBuffer, "," , ".")) ,2)
		
		Case ::nTipoCampo == 131 .AND. Empty(::oRetorno:cRede)
			//Contem um indice que indica qual a instituicao que ira processar a transacao segundo a tabela
			// presente no final do documento (5 posicoes)
            ::oRetorno:cInstit := AllTrim(::cBuffer) 
            
			If ::oRedes:Contains(::oRetorno:cInstit)
				::oRetorno:cRede := ::oRedes:ElementKey(::oRetorno:cInstit)
			Else
				::oRetorno:cRede := ::oRedes:Elements(1)
			EndIf

			LjGrvLog( Nil, "nTipoCampo -> 131 - Codigo da institui็ใo financeira retornado pelo SITEF: ", AllTrim(::cBuffer) )

		Case ::nTipoCampo == 132
			//Contem um indice que indica qual o tipo do cartใo quando esse tipo for identificavel,
			// segundo uma tabela a ser fornecida (5 posicoes)
            
            ::oRetorno:cTpCartao := AllTrim(::cBuffer)
            LjGrvLog( Nil, "nTipoCampo -> 132 - Codigo da bandeira retornado pelo SITEF: ", ::oRetorno:cTpCartao )
			
			If ValType(Self:oTransacao:nParcela) == "N" .AND. Self:oTransacao:nParcela > 0
				nParcela := Self:oTransacao:nParcela
	        EndIf   
	        
	       	LjGrvLog( Nil, "nTipoCampo -> 132 - Quantidade de Parcelas ", nParcela )         
            Self:TrataAdm( nParcela) 

		
		Case ::nTipoCampo == 133

			LjGrvLog( Nil, "nTipoCampo -> 133 - NSU do SiTEF (6 posicoes) - Antes LjRmvAcent ", AllTrim(::cBuffer) )			
			// LjRmvAcent - Remove acentos/caracteres especiais nao suportados pelo ECF

			//Contem o NSU do SiTEF (6 posicoes)
			::oRetorno:cNsuSitef := LjRmvAcent( AllTrim(::cBuffer) )

			LjGrvLog( Nil, "nTipoCampo -> 133 - NSU do SiTEF (6 posicoes) - Depois LjRmvAcent ", ::oRetorno:cNsuSitef ) 

		Case ::nTipoCampo == 134
			//Contem o NSU do Host autorizador (15 posicoes no maximo)
			::oRetorno:cNsuAuto	:= AllTrim(::cBuffer)
			
		Case ::nTipoCampo == 135
			//Contem o Codigo de Autorizacao para as transacoes de credito (15 posicoes no maximo)
			::oRetorno:cCodAuto := AllTrim(::cBuffer)            

		Case ::nTipoCampo == 136
			//Contem as 6 primeiras posicoes do cartao (bin)
			::oRetorno:cBinCartao := Substr(AllTrim(::cBuffer), 1, 6)
																								
		Case ::nTipoCampo == 140
			//Data da primeira parcela no formato ddmmaaaa
			::oRetorno:dPrimParc	:= CTOD(SubStr(::cBuffer, 1, 2) + "/" + SubStr(::cBuffer, 3, 2) + "/" + SubStr(::cBuffer, 5, 4))
		
		Case ::nTipoCampo == 141
			//Os campos 141 e 142 sใo chamados n vezes onde n = conte๚do do campo 505
			//Data da parcela no formato aaaammdd
			::oRetorno:oDataParcs:ADD(::oDataParcs:Count() + 1, CTOD(SubStr(::cBuffer, 7, 2) + "/" + SubStr(::cBuffer, 5, 2) + "/" + SubStr(::cBuffer, 1, 4)))
																					
		Case ::nTipoCampo == 142
			//Os campos 141 e 142 sใo chamados n vezes onde n = conte๚do do campo 505
			//Valor da parcela
			::oRetorno:oValParcs:ADD(::oDataParcs:Count() + 1, Round(Val(::cBuffer),2))
		
		Case ::nTipoCampo == 145
			//Valor de pagamento
			::oRetorno:nValorPgto := Round(Val(::cBuffer) / 100, 2) 
																								
		Case ::nTipoCampo == 147
			//Valor a ser cancelado
			::oRetorno:nValorCanc := Round(Val(::cBuffer),2) 
		
		Case ::nTipoCampo == 148
			//Indica, na coleta, que o campo em questใo ้ o valor da venda com desconto
			::oRetorno:nVlrVndcDesc := Round(Val(::cBuffer) / 100, 2)
		
		Case ::nTipoCampo == 150
			//Cont้m a Trilha 1, quando disponํvel, obtida na fun็ใo LeCartaoInterativo
			::oRetorno:cTrilha1	:= AllTrim(::cBuffer)
																								
		Case ::nTipoCampo == 151
			//Cont้m a Trilha 2, quando disponํvel, obtida na fun็ใo LeCartaoInterativo
			::oRetorno:cTrilha2	:= AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 153
			//Contem a senha do cliente capturada atrav้s da rotina LeSenhaInterativo e que deve ser passada 
			//a lib de seguran็a da Software Express personalizada para o estabelecimento comercial de forma 
			//a obter a senha aberta
			::oRetorno:cSenhaCli	:= AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 200
			//PharmaSystem Preco Liquido
			::oRetorno:cSaldoDisp := AllTrim(::cBuffer)
																								
	    //------------------------
		//Recarga de Celular      
	    //------------------------
		Case ::nTipoCampo == 590
			//Nome da Operadora de Celular selecionada para a opera็ใo
  			::oRetorno:cOperadora := AllTrim(::cBuffer)

		Case ::nTipoCampo == 591
			//Valor selecionado para a recarga
  			::oRetorno:nValorPgto := Round(Val(::cBuffer) / 100, 2)
																								
		Case ::nTipoCampo == 592
			//DDD + N๚mero do celular a ser recarregado
  			::oRetorno:cCelular := AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 593
			//Digito(s) verificadores
		 	::oRetorno:cDigitos	:= AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 594
			//Cep da localidade onde estแ o terminal no qual a opera็ใo estแ sendo feita
  			::oRetorno:cCep := AllTrim(::cBuffer)
  			
		Case ::nTipoCampo == 595
			//Nsu do SiTef correspondente a transa็ใo de pagamento da Recarga com cartใo
		 	::oRetorno:cNsuSitef	:= AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 596
			//Nsu do Host Autorizador correspondente a transa็ใo de pagamento da Recarga com cartใo
  			::oRetorno:cNsuAuto := AllTrim(::cBuffer)  			
		
		//--------------------------
		//Correspondente Bancario																						
		//--------------------------
		Case ::nTipoCampo == 600
			//Data de vencimento do titulo/convenio no formato aaaammdd
			::oRetorno:oDataVenc:Add(::oRetorno:nIndiceDoc , CTOD(SubStr(::cBuffer, 7, 2) + "/" + SubStr(::cBuffer, 5, 2) + "/" + SubStr(::cBuffer, 1, 4))) 
		
		Case ::nTipoCampo == 601
			//Valor Pago
			::oRetorno:oVlrPgto:Add(::oRetorno:nIndiceDoc , Round(Val(::cBuffer) / 100, 2))
																								
		Case ::nTipoCampo == 602
			//Valor Original
			::oRetorno:oVlrOrig:Add(::oRetorno:nIndiceDoc , Round(Val(::cBuffer) / 100, 2))
		
		Case ::nTipoCampo == 603
			//Valor Acrescimo
			::oRetorno:oVlrAcre:Add(::oRetorno:nIndiceDoc , Round(Val(::cBuffer) / 100, 2))
		
		Case ::nTipoCampo == 604
			//Valor do Abatimento
			::oRetorno:oVlrAbat:Add(::oRetorno:nIndiceDoc , Round(Val(::cBuffer) / 100, 2))
																								
		Case ::nTipoCampo == 605
			//Data Contabil do Pagamento aaaammdd
			::oRetorno:dDataPgto := CTOD(SubStr(::cBuffer, 7, 2) + "/" + SubStr(::cBuffer, 5, 2) + "/" + SubStr(::cBuffer, 1, 4)) 
			::oRetorno:dDataPgto	:= IIF(Empty(::oRetorno:dDataPgto), dDataBase, ::oRetorno:dDataPgto)
		
		Case ::nTipoCampo == 606
			//Nome do Cedente do Titulo. Deve ser impresso no cheque quando o pagamento for feito via essa modalidade
			::oRetorno:cCedente := AllTrim(::cBuffer)
																								
		Case ::nTipoCampo == 607
			//Indice do documento, no caso do pagamento em lote, dos campos 600 a 604 que virao em seguida
			::oRetorno:nIndiceDoc := Val(AllTrim(::cBuffer))
		
		Case ::nTipoCampo == 608
			//Contem a modalidade de pagamento no formato xxnn xx corresponde ao grupo da 
			//modalidade e nn ao sub-grupo. Vide tabela no final deste documento descrevendo 
			//os possํveis valores de xx e nn.
			::oRetorno:cCodMod := AllTrim(::cBuffer)
	
		Case ::nTipoCampo == 609
			//Valor total dos titulos efetivamente pagos no caso de pagamento em lote
			::oRetorno:nVlrTotCB := Round(Val(::cBuffer) / 100, 2)
																								
		Case ::nTipoCampo == 610
			//Valor total dos titulos nao pagos no caso de pagamento em lote
			::oRetorno:nVlrNaoPago := Round(Val(::cBuffer) / 100, 2)
		
		Case ::nTipoCampo == 611
			//NSU Correspondente Bancario
			::oRetorno:cNsuSitef := AllTrim(::cBuffer)
																								
		Case ::nTipoCampo == 612
			//Tipo do documento: 0 ' Arrecadacao, 1 ' Titulo (Ficha de compensacao), 2 ' Tributo
			::oRetorno:nTipoDocCB := Val(AllTrim(::cBuffer))
		
		Case ::nTipoCampo == 613
			//Contem os dados do cheque utilizado para efetuar o pagamento das contas no seguinte formato: 
			//CCCBBBAAAACCCCCCCCCCNNNNNN
			//Compensacao (3), Banco (3), Agencia (4), ContaCorrente (10), e Numero do Cheque (6), nesta ordem. 
			//Notar que a ordem eh a mesma presente na linha superior do cheque sem os digitos verificadores
			::oRetorno:nBanco := Val(AllTrim(Substr(::cBuffer, 4, 3)))
		   	::oRetorno:nAgencia := Val(AllTrim(Substr(::cBuffer, 7, 4)))
		   	::oRetorno:nConta := Val(AllTrim(Substr(::cBuffer, 11, 10)))
		   	::oRetorno:nCheque := Val(AllTrim(Substr(::cBuffer, 21, 6)))
		   	::oRetorno:nCompensa := Val(AllTrim(Substr(::cBuffer, 1, 3)))
																										
		Case ::nTipoCampo == 614
			//NSU SiTEF transacao de pagamento
			::oRetorno:cNsuSitef := AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 620
			//NSU SiTEF da transacao original (transacao de cancelamento)
			::oRetorno:cNsuCancCB := AllTrim(::cBuffer)
																								
		Case ::nTipoCampo == 621
			//NSU Correspondente Bancario da transacao original (transacao de cancelamento)
			::oRetorno:cNsuOriCan := AllTrim(::cBuffer)
																								
		Case ::nTipoCampo == 623
			//Codigo impresso no rodape do comprovante do CB e utilizado para er-impressao/cancelamento
			::oRetorno:cCodAuto	:= AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 624
			//Codigo em barras pago. Aparece uma vez para cada indice de documento (campo 607). O formato eh o 
			//mesmo utilizado para entrada do campo ou seja, 0:numero ou 1:numero
			::oRetorno:oCodBarras:Add(::oRetorno:nIndiceDoc , AllTrim(::cBuffer))

		Case ::nTipoCampo == 641
			::oRetorno:cDataIni := AllTrim(::cBuffer)

		Case ::nTipoCampo == 642
			::oRetorno:cDataFim := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1010
			//Qtde de medicamentos
			nX := Val(AllTrim(::cBuffer))
			::oRetorno:nQtdeMed  := nX
			::oRetorno:aItemsPBM := Array(nX)
			For nY:= 1 to nX
				::oRetorno:aItemsPBM[nY] := MSRetVidaLinkItem():New() //Classe no LOXTEF
			Next nY

			If ::oTransacao:aVDLink[1,5] == 560
				::oRetorno:nIndAtuMed := ::oRetorno:nIndAtuMed + 1
				nX := ::oRetorno:nIndAtuMed
			EndIf

		Case ::nTipoCampo == 1011
			//Indice de medicamentos
			nX := Val(AllTrim(::cBuffer))
			::oRetorno:nIndAtuMed := nX
			::oRetorno:aItemsPBM[nX]:nIndice := nX

		Case ::nTipoCampo == 1012
			//Codigo do medicamento

			//PBM PharmaSystem
			If ::oTransacao:aVDLink[1,5] == 541 .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:nIndAtuMed := ::oRetorno:nIndAtuMed + 1
				::oRetorno:nQtdeMed	 := ::oRetorno:nIndAtuMed

				If ::oRetorno:nIndAtuMed == 1
					::oRetorno:aItemsPBM := {}
				Endif
				
				AADD( ::oRetorno:aItemsPBM , MSRetVidaLinkItem():New() ) //Classe no LOJXTEF
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nIndice := ::oRetorno:nIndAtuMed
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:cCodigo := AllTrim(::cBuffer)
			Else
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:cCodigo := AllTrim(::cBuffer)
			Endif

		Case ::nTipoCampo == 1013
			//PBM PharmaSystem
			::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nQuantAut := Val(AllTrim(::cBuffer))
			
		Case ::nTipoCampo == 1014
			//Pre็o unitแrio mแximo de venda ao consumidor
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nPrecoMax := Val(AllTrim(::cBuffer))/100
		
		Case ::nTipoCampo == 1015
			//Valor unitแrio recomendado de venda ao consumidor
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nPrecoRecomend	:= Val(AllTrim(::cBuffer))/100
		
		Case ::nTipoCampo == 1016
			//Valor unitแrio de venda เ farmแcia. Corresponde ao Valor de venda ao consumidor + Reembolso da farmแcia
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValVendFarm := Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 1017
			//Valor unitแrio de reembolso da farmแcia
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValReembFarm := Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 1018
			//Valor unitแrio de reposi็ใo
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValReposiFarm	:= Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 1019
			//Valor do subsํdio do conv๊nio
			nX := ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValSubsidio := Val(AllTrim(::cBuffer))/100
		
		Case ::nTipoCampo == 1020
			//CNPJ do conv๊nio
			::oRetorno:cCNPJConvenio := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1021
			//C๓digo do plano de desconto do Conv๊nio
			::oRetorno:cCodPlano := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1022
			//N๚mero do documento (retorno na venda e solicitado no cancelamento)
			MsgStop("TipoCampo "+Str(::nTipoCampo)+"= "+AllTrim(::cBuffer))

		Case ::nTipoCampo == 1023
			//Data da venda a ser cancelada no formato DDMMAAAA
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cCRM := AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 1024
			//N๚mero do cupon fiscal original a ser cancelado
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cUF := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1025
			//C๓digo do medicamento a ser devolvido
			MsgStop("TipoCampo "+Str(::nTipoCampo)+"= "+AllTrim(::cBuffer))

		Case ::nTipoCampo == 1026
			//Quantidade do medicamento a ser devolvida
			MsgStop("TipoCampo "+Str(::nTipoCampo)+"= "+AllTrim(::cBuffer))

		Case ::nTipoCampo == 1029
			//1029	Data da receita m้dica
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:dDataRec := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1030
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:cNumPreAut := AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 1033
			//VidaLink Valor unitแrio de venda ao consumidor para pagamento เ vista
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValConsum	:= Val(AllTrim(::cBuffer))/100
		
		Case ::nTipoCampo == 1039
			::oRetorno:cAdmFin := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1040
			//Tipo de Medicamento PBM (01–Medicamento, 02-Manipula็ใo, 03-Manipula็ใo Especial, 04-Perfumaria)
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cTpMedic := AllTrim(::cBuffer)

		Case ::nTipoCampo == 1041
			//1041	Descri็ใo do Medicamento
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cDescMedic	:= AllTrim(::cBuffer)                                                    

		Case ::nTipoCampo == 1042
			//1042	Condi็ใo p/venda:Se 0 obrigat๓rio utilizar pre็o Funcional Card (PF) Se 1 pode vender por pre็o inferior ao pre็o PF
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cPrecoFun := AllTrim(::cBuffer)
			
		Case ::nTipoCampo == 1043
			//1043	Pre็o Funcional Card
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValorFC		:= Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 1044
			//1044	Pre็o praticado
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValorPrat		:= Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 1045
			//PharmaSystem Status do Medicamento
			If ::oTransacao:aVDLink[1,5] == 541  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:cStatMedic := AllTrim(::cBuffer)
			Endif

		Case ::nTipoCampo == 1046
			//1046	Quantidade receitada
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nQtdReceit	:= Val(AllTrim(::cBuffer))

		Case ::nTipoCampo == 1047
			//1047	Refer๊ncia
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cRef := AllTrim(::cBuffer)

		Case  ::nTipoCampo == 1047
			//1048	Indicador da venda PBM (0-Produto venda cartใo 1-Produto venda a vista)
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cIndPBM := AllTrim(::cBuffer)

		Case ::nTipoCampo == 4001
			//4001	CRF
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cCRF := AllTrim(::cBuffer)

		Case ::nTipoCampo == 4002
			//4002	UF do CRF
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cUFCRF := AllTrim(::cBuffer)

		Case ::nTipoCampo == 4003
			//4003	Tipo de venda
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:cTipoVen := AllTrim(::cBuffer)

		Case ::nTipoCampo == 4004
			//PharmaSystem Valor Total
			If ::oTransacao:aVDLink[1,5] == 541 .OR. ::oTransacao:aVDLink[1,5] == 560  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nValTot := Val(AllTrim(::cBuffer))/100
			Endif               

		Case ::nTipoCampo == 4005
			//4005	Valor a Vista
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nValConsum	:= Val(AllTrim(::cBuffer))/100
			
		Case ::nTipoCampo == 4006
			//4006	Valor cartใo PBM
			nX	:= ::oRetorno:nIndAtuMed
			::oRetorno:aItemsPBM[nX]:nVlCartao := Val(AllTrim(::cBuffer))/100

		Case ::nTipoCampo == 4008 
			//PharmaSystem % De Desconto
			If ::oTransacao:aVDLink[1,5] == 541 .OR. ::oTransacao:aVDLink[1,5] == 560  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nPerDesc := Val(AllTrim(::cBuffer))
			Endif

		Case  ::nTipoCampo == 4016
			//PharmaSystem Preco Bruto
			MsgAlert("LjTEFTrata - 4016")
					
			If ::oTransacao:aVDLink[1,5] == 541  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nValTot := Val(AllTrim(::cBuffer)) /100
			Endif
		
		Case ::nTipoCampo == 4017
			If ::oTransacao:aVDLink[1,5] == 541  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nValLiq	:= Val(AllTrim(::cBuffer)) /100
			Endif
		
		Case ::nTipoCampo == 4022
			::oRetorno:cNumPreAut := AllTrim(::cBuffer)
		
		Case ::nTipoCampo == 4023 .Or. ::nTipoCampo == 4025 .Or. ::nTipoCampo == 4026 .Or. ::nTipoCampo == 4027
			::oRetorno:cNomeConveniado := AllTrim(::cBuffer)

		Case ::nTipoCampo == 4024
			::oRetorno:cNomEmpConv := AllTrim(::cBuffer)

		//PharmaSystem Valor a Receber do Conveniado
		Case ::nTipoCampo == 4028
			If ::oTransacao:aVDLink[1,5] == 541  .OR. ::oTransacao:aVDLink[1,5] == 540
				::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:nValRec	:= Val(AllTrim(::cBuffer))  /100
			Endif 

		Case ::nTipoCampo == 4029
			//Indica, na coleta, que o campo em questใo ้ o valor do desconto concedido pelo SITEF
			::oRetorno:nVlrDescTEF	:= Round(Val(::cBuffer) / 100, 2)
		
		Case ::nTipoCampo == 4033
			//4033	Tipo de documento PBM (0 = CRM, 1 = CRO)			
			::oRetorno:aItemsPBM[::oRetorno:nIndAtuMed]:cTpBPM := AllTrim(::cBuffer)
			
		Otherwise
			
	EndCase			
		
Return Nil

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณTratarRet บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata o retorno do sitef.							          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 (1 - nRetorno) - Retorno do tef.		    		  บฑฑ
ฑฑบ			 ณExpC1 (1 - cTipo) - Tipo de mensagem.			    		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ		                                                      บฑฑ
---------------------------------------------------------------------------*/
Method TratarRet(nRetorno, cTipo) Class LJCComClisitef
		
		If cTipo == _INICIALIZACAO
			
			Do Case
				Case nRetorno == 1
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Endere็o IP invแlido ou nใo resolvido")
				Case nRetorno == 2
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : C๓digo da loja invแlido")
				Case nRetorno == 3
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : C๓digo de terminal invแlido")
				Case nRetorno == 6
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Erro na inicializa็ใo do Tcp/Ip")
				Case nRetorno == 7
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Falta de mem๓ria")
				Case nRetorno == 8
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Nใo encontrou a CliSiTef ou ela estแ com problemas")
				Case nRetorno == 10
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : O PinPad nใo estแ devidamente configurado no arquivo CliSiTef.ini")			
				OtherWise
					If ExistFunc("IsRmt64") .AND. IsRmt64()
						::ExibirMsg(AllTrim(Str(nRetorno)) + " : Erro nใo previsto pela CLISITEF64I")
					Else
						::ExibirMsg(AllTrim(Str(nRetorno)) + " : Erro nใo previsto pela CLISITEF32I")
					EndIf			
			EndCase		

		ElseIf cTipo == _TRANSACAO
			
			Do Case
		    	Case nRetorno > 0
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Negada pelo autorizador")		    	
		    	Case nRetorno == -1
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : M๓dulo nใo inicializado")		    	    	
		    	Case nRetorno == -2
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Opera็ใo cancelada pelo operador")		    	
		    	Case nRetorno == -3
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Fornecida uma modalidade invแlida")		    	
		    	Case nRetorno == -4
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Falta de mem๓ria para rodar a fun็ใo")		    	
		    	Case nRetorno == -5
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Sem comunica็ใo com o SiTef")		    	    	
		    	Case nRetorno == -6
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Opera็ใo cancelada pelo usuแrio")		    	    	
		    	OtherWise
					::ExibirMsg(AllTrim(Str(nRetorno)) + " : Erros detectados internamente pela rotina")		    	    	
	    	EndCase    		
		EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSetTrans  บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecebe o objeto com os dados da transacao   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oTransacao) - Objeto do tipo LJADadosTransacao	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SetTrans(oTransacao) Class LJCComClisitef

	::oTransacao := oTransacao
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGravarLog	       บAutor  ณVendas Clientes     บ Data ณ  18/11/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o log do Tef									    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTexto) - Mensagem do log.          				 	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GravarLog(cTexto) Class LJCComClisitef

	
	If ::lLog == Nil       
	   ::lLog := ::oGlobal:GravarArq():Log():Tef():lHabilitad
	EndIf  
	                                                
    If ::lLog
		::oGlobal:GravarArq():Log():Tef():Gravar(cTexto) 
	EndIf
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLogEnvio         บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravar o log com os dados de envio.	    	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LogEnvio(oParams) Class LJCComClisitef
	
	Local cAux		:= ""									//Variavel para gravacao do log
	Local nCount	:= ""									//Variavel contador
	Local nParams	:= 0

	Default oParams := Nil	

	If ValType(oParams) == "O" 
	
		nParams	:= oParams:Count()
	
		cAux := "Comando Enviado: "
		
		For nCount := 2 To nParams
			
			If nCount == 2 .AND. nCount == nParams
				cAux += oParams:Elements(nCount):cParametro + "()"
			
			ElseIf nCount == 2 .AND. nCount < nParams
				cAux += oParams:Elements(nCount):cParametro + "("		
			
			ElseIf nCount > 2
				cAux += oParams:Elements(nCount):cParametro + ","
				
			EndIf
		Next 
		
		If (nCount - 1) > 2 .AND. (nCount -1) == nParams
			cAux := Substr(cAux, 1, Len(cAux) - 1) + ")"
		EndIf
		
		::GravarLog(cAux)
		  
	EndIF	   
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLogRetorno       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o log com os dados de retorno.	    	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRetorno) - Retorno da dll.							 บฑฑ
ฑฑบ			 ณEXPO1 (2 - oParams) - Objeto do tipo LJCParamsApi.				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LogRetorno(cRetorno, oParams) Class LJCComClisitef
	
	Local cAux		:= ""									//Variavel para gravacao do log
	Local nCount	:= ""									//Variavel contador
	Local nParams	:= oParams:Count()
    //Local nParams := Len(oParams)
   
	cAux := "Retorno: " + cRetorno
	
	For nCount := 2 To nParams
		
		If nCount == 2 .AND. nCount < nParams
			cAux += " -> ("		

		ElseIf nCount > 2
			cAux += oParams:Elements(nCount):cParametro + ","
			//cAux += oParams[nCount] + ","
		EndIf
	Next
	
	If (nCount - 1) > 2 .AND. (nCount -1) == nParams
		cAux := Substr(cAux, 1, Len(cAux) - 1) + ")"
	EndIf
	
	::GravarLog(cAux)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณVerDll    	   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVersao da clisite32 e clisite32i			 						 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VerDll() Class LJCComClisitef
	
	Local nRetorno			:= 0			//Retorno do metodo
	Local oParamsApi 		:= Nil			//Objeto do tipo LJCParamsAPI
	Local cRetorno 			:= ""       	//Retorno do comando enviado
			
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "ObtemVersao", Space(64), Space(64)})

    cRetorno := ::EnviarCom(oParamsApi)
	nRetorno := Val(cRetorno)
	
	If nRetorno == 0
  		::cClisitef	:= Substr(oParamsApi:Elements(3):cParametro, 1, At(Chr(0), oParamsApi:Elements(3):cParametro) - 1)
		::cClisitefI	:= Substr(oParamsApi:Elements(4):cParametro, 1, At(Chr(0), oParamsApi:Elements(4):cParametro) - 1)
	EndIf 
	
	oParamsApi:Destroy()
	oParamsApi := FreeObj(oParamsApi)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValidarSupบAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar o supervisor informado			      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValidarSup(cSenha) Class LJCComClisitef
	
	Local cUserIDOld 	:= __cUserID					//Variavel com o acesso do usuario logado no sistema
   Local lRet := .T.

	If Empty(cSenha)	
		cSenha := __cUserID
	EndIf

	lRet := FWAuthSuper(cSenha)
	
	If !lRet

			::ExibirMsg(STR0004) //"Acesso negado, senha do Superior invแlida!"
	EndIf

	//Volta o posicionamento da senha para o operador inicial
	__cUserID := cUserIDOld
	PswOrder(1)
	PswSeek(__cUserID)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณRedeTpCartบAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarregar as redes e tipos de cartoes						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ				                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method RedeTpCart() Class LJCComClisitef
	
	Local lMVLJADMFI:= SuperGetMv("MV_LJADMFI",,.F.)
	Local lAEREDEAUT:= SAE->(ColumnPos("AE_REDEAUT")) > 0
	Local aRet		:= {}	//Array com as informacoes disponibilizadas pela Software Express
	Local nX 		:= 0
	
	//Carrega os dados das redes
	::oRedes := LJCHashTable():New()
	
	
	If lMVLJADMFI .And. lAEREDEAUT .And. ExistFunc("LjCodSiTEF")
		aRet := LjCodSiTEF("RD")
	EndIf
	
	If Len(aRet) == 0
		::oRedes:ADD("00000", "OUTRAS")
		::oRedes:ADD("00001", "TECBAN")
		::oRedes:ADD("00004", "VISANET")
		::oRedes:ADD("00005", "REDECARD")	
		::oRedes:ADD("00006", "AMEX")		
		::oRedes:ADD("00021", "BANRISUL")
		::oRedes:ADD("00031", "TICKET COMBUSTIVEL")
		::oRedes:ADD("00082", "GETNET")	
		::oRedes:ADD("00125", "VISA")
		::oRedes:ADD("00290", "MERCADO PAGO")
		::oRedes:ADD("00380", "ITI ITAU")
		::oRedes:ADD("00210", "IZPAY")
		::oRedes:ADD("00260", "VEE")
	Else
		For nX:=1 To Len(aRet)
			::oRedes:ADD(aRet[nX][1], aRet[nX][2])
		Next nX
	EndIf
		
	//Carrega os tipos de cartoes
	::oTiposCart := LJCHashTable():New()
	
	If lMVLJADMFI .And. lAEREDEAUT .And. ExistFunc("LjCodSiTEF")
		aRet := LjCodSiTEF("CC")
	EndIf
	
	If Len(aRet) == 0
		::oTiposCart:ADD("00000", "OUTRAS")
		::oTiposCart:ADD("00001", "VISA")
		::oTiposCart:ADD("00002", "MASTERCARD")
		::oTiposCart:ADD("00003", "DINERS")
		::oTiposCart:ADD("00004", "AMEX")
		::oTiposCart:ADD("00005", "SOLLO")
		::oTiposCart:ADD("00006", "SIDECARD")
		::oTiposCart:ADD("00007", "PRIVATE LABEL")
		::oTiposCart:ADD("00008", "REDESHOP")
		::oTiposCart:ADD("00010", "FININVEST")
		::oTiposCart:ADD("00011", "SERASA DETALHADO")
		::oTiposCart:ADD("00012", "HIPERCARD")
		::oTiposCart:ADD("00013", "AURA")
		::oTiposCart:ADD("00014", "LOSANGO")
		::oTiposCart:ADD("00015", "SOROCRED")
	Else
		For nX:=1 To Len(aRet)
			::oTiposCart:ADD(aRet[nX][1], aRet[nX][2])
		Next nX
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณVerPinPad        บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerificar se o pinpad esta conectado   			 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VerPinPad() Class LJCComClisitef

	Local cRetorno 		:= ""       	//Retorno do comando enviado	
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
					
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "VerificaPresencaPinPad"})

    cRetorno := ::EnviarCom(oParamsApi)
    
    oParamsApi:Destroy()
    oParamsApi := FreeObj(oParamsApi)
    
Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExibirMsg บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a mensagem retornada pelo Tef.          			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cMensagem) - Mensagem.				    		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExibirMsg(cMensagem) Class LJCComClisitef
			
	STFMessage("SiTEF", "ALERT", cMensagem)
	STFShowMessage("SiTEF")
		
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณVerPend   	   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe transacao pendente				 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VerPend() Class LJCComClisitef
    
  	Local aArea 			:= GetArea() 					//Guarda area
	Local cStrTRS			:= ""							//Guarda a string para a transacao
	Local oDadosTRS	 		:= Nil							//Guarda as informacoes para a transacao
	Local oArquivos	 		:= Nil							//Objeto do tipo LJCArquivos
	Local nCount			:= 0							//Variavel de controle contador
	Local cNSUTxt			:=	""							//Texto a ser exibido com NSUs
	Local lCancel			:= 	.F.							//Controla se Cancela toda a transacao
	Local dData		 		:= ""							//Data da transacao
	Local cHora				:= "" 							//Hora da transacao
	Local cDataArq	 		:= ""							//Data da transacao
	Local cHoraArq	  		:= "" 							//Hora da transacao
	Local cNumLastSale 		:= STDCSLastSale()		 		//Numero da ultima venda realizada
	Local cDoc		  		:= ""							//Numero do Doc da venda
	Local lCancela	   		:= .f.							//Cancela o TEF?
	Local cVendasOk 		:= "00|10|RX|TX"				//L1_SITUA aceito
	Local lEmitNfce	  		:= Iif(FindFunction("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-es
	Local lExistSL4	    	:= .F.							//Valida se encontrou registro na SL4 
	Local lUseSat			:= STFGetCfg("lUseSAT",.F.) //Usa SAT?
	Local nPos 				:= 0
	Local cTexto			:= "" //Texto do arquivo
	Local lNovoNum			:= .F. //Nova numera็ใo de nfce
	Local aPrgInfo			:= {} //Dados do programa
	
	//Le os arquivos do diretorio de transacoes pendentes
	oArquivos := ::oGlobal:GravarArq():TransTef(Time(), DtoS(Date())):LerArqs()
	
	//Se existir o arquivos de transacoes
	If oArquivos:Count() > 0 
	
	   	cTexto	:= oArquivos:Elements(1):Dados():Elements(1):Linha()
		nPos := At( "/" , cTexto)
		cDoc :=  Left(cTexto, nPos - 1)
	
		::GravarLog("Documento do arquivo Pendente" + " (" + cDoc + ")") 	
		
		DbSelectArea("SL1")
		DbSetOrder(1) //L1_FILIAL+L1_NUM 
		
		::GravarLog("Localizando venda " + " (" + cNumLastSale + ")") 	
		If DbSeek( xFilial("SL1") + cNumLastSale )
		
			If !Eof()
				
				If lEmitNfce
					cVendasOk := "00|RX|TX"	
				EndIf
				
				//Se a venda nao foi confirmada, precisa cancelar as transacoes TEF
				If !( SL1->L1_SITUA $ cVendasOk )
					lCancel := .T.
				EndIf
				
				If lEmitNfce .AND. !lUseSat
					//verifica se o programa estแ com a versใo que grava o NFCE no L1_DOC
						
					aPrgInfo :=  GetAPOInfo("STBPAYMENT.PRW")
					lNovoNum :=  aPrgInfo[4] >= Ctod("16/01/2018")
					
					If lNovoNum
						aPrgInfo :=  GetAPOInfo("STBITEMREGISTRY.PRW")
						lNovoNum :=  aPrgInfo[4] >= Ctod("16/01/2018")
					EndIf
					
					If !lNovoNum
						cDoc := SL1->L1_DOC	
					EndIf
					
					::GravarLog("VerPend - Nova Numera็ใo de L1_DOC - " + cValToChar(lNovoNum))

				EndIf
				
				If !lEmitNfce .OR. lUseSat .OR. !lNovoNum
					//Pega o documento do arquivo //TEF
					cDoc := SL1->L1_DOC	 
				EndIf
				
				::GravarLog("Documento da Venda " + " (" + cDoc + ")") 
		
				DbSelectArea("SL4")
				DbSetOrder(1) //L4_FILIAL+L4_NUM 	
				If DbSeek( xFilial("SL4") + cNumLastSale) 
			    
			   		lExistSL4 := .T.
			    
					While !EOF() .AND. SL4->L4_FILIAL == xFilial("SL4") .AND. SL4->L4_NUM == cNumLastSale

						//Prepara os dados para o desfazimento ou confirmacao
						If !Empty( SL4->L4_DOCTEF)
							//Se a data do TEf nao estiver vazia
							If !Empty( SL4->L4_DATATEF )
								dData := CTOD(Substr( SL4->L4_DATATEF , 7, 2) + "/" + Substr( SL4->L4_DATATEF , 5, 2) + "/" + Substr( SL4->L4_DATATEF , 1, 4))	
							EndIf
							
							//Se a Hora do TEf nao estiver vazia
							If !Empty( SL4->L4_HORATEF )
								cHora := Substr( SL4->L4_HORATEF , 1, 2) + ":" + Substr( SL4->L4_HORATEF , 3, 2) + ":" + Substr( SL4->L4_HORATEF , 5, 2)	
							EndIf

						
							//Criar uma transacao generica para fazer o desfazimento ou confirmacao
							::oTransacao := LJCDadosTransacaoGenerica():New(Nil, Val(cDoc) , dData, cHora)
							
							If lCancel
				
								STFMessage("SiTEF","RUN","Cancelando Transacao TEF. Aguarde...", {|| ::FinTrans(0)})					
								STFShowMessage("SiTEF")	
								::GravarLog("Transacao Tef Desfeita" + " (" + cDoc + " - " + SL4->L4_DATATEF + " - " + SL4->L4_HORATEF + ")")
											
							Else
							
								STFMessage("SiTEF","RUN","Confirmando Transacao TEF. Aguarde...", {|| ::FinTrans(1)})				
								STFShowMessage("SiTEF")
								::GravarLog("Transacao Tef Confirmada" + " (" + cDoc + " - " + SL4->L4_DATATEF + " - " + SL4->L4_HORATEF + ")")
									
								//Add as transacoes NSUHOST para exibir na mensagem ao usuario
								//Se o Doc do TEf nao estiver vazio
								If !Empty( SL4->L4_DOCTEF )
									//Add as transacoes NSUHOST para exibir na mensagem ao usuario
									cNSUTxt += CRLF + " NSU: " + SL4->L4_DOCTEF		
								EndIf
													
							EndIf							
						EndIf
						
						SL4->(DbSkip())
						
					End 
					
					::Lj1926VlCan(oArquivos, cDoc, lExistSL4)
					
				ElseIf lCancel					
					
					//Nao achou o L4 significa que nao fechou a venda precisa cancelar com base nos arquivos textos
					::Lj1926VlCan(oArquivos, cDoc, lExistSL4)

				EndIf
		
			EndIf
		
		Else
			//Nao achou o L4 significa que nao fechou a venda precisa cancelar com base nos arquivos textos
			::Lj1926VlCan(oArquivos, cDoc, .f.)
		EndIf
		 
	EndIf
	

	If !Empty(cNSUTxt) .AND. !lCancel
		
		cNSUTxt += CRLF + "Para rede Cielo ultilizar os 6 ultimos dํgitos do NSU"		
		STFMessage("TEF", "POPUP", "Transa็ใo TEF efetuada. Favor reimprimir ๚ltimo cupom." + cNSUTxt ) //"Transa็ใo TEF nใo foi efetuada. Favor reter o Cupom!"
		STFShowMessage( "TEF")	
		
	ElseIf lCancel
	
		If oArquivos:Count() > 1		
			STFMessage("TEF", "POPUP","ฺltima transa็ใo TEF nใo foi efetuada. Favor reter o Cupom."  + cNSUTxt ) //"Ultima transacao TEF nao foi efetuada. Favor reter o Cupom."
			STFShowMessage( "TEF")		
		Else		
			STFMessage("TEF", "POPUP", STR0003  ) //"Transa็ใo TEF nใo foi efetuada. Favor reter o Cupom!"
			STFShowMessage( "TEF")	
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFormatData	   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFormata data e hora												 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPD1 (1 - dData) - Data da transacao.		     				 บฑฑ
ฑฑบ			 ณEXPC1 (2 - cHora) - Hora da transacao.		     				 บฑฑ
ฑฑบ			 ณEXPC2 (3 - cDataAux) - Data formatada.		     				 บฑฑ
ฑฑบ			 ณEXPC3 (4 - cHoraAux) - Hora formatada.		     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FormatData(dData, cHora, cDataAux, cHoraAux) Class LJCComClisitef
	If !Empty(dData)
	
	cDataAux	:= Str(Year(dData),4) + StrZero(Month(dData),2) + StrZero(Day(dData),2)
	Else
		cDataAux	:= space(8)
	EndIf

	If !Empty(cHora)
		cHoraAux	:= SubStr(cHora,1,2) + SubStr(cHora,4,2) + SubStr(cHora,7,2)
	Else
		cHoraAux	:= space(6)
	EndIf
		
Return Nil


/*---------------------------------------------------------------------------
ฑฑบMetodo    ณGrvArqCtrlบAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
-----------------------------------------------------------------------------
ฑฑบDesc.     ณGravar o arquivo de controle do tef.         				  บฑฑ
-----------------------------------------------------------------------------
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
-----------------------------------------------------------------------------
ฑฑบRetorno   ณ		                                                      บฑฑ
---------------------------------------------------------------------------*/
Method GrvArqCtrl( cNSU ) Class LJCComClisitef
Local cData		:= ""						//Data da transacao
Local cHora		:= "" 						//Hora da transacao
Local cCupom	:= ""						//Numero do cupom
Local lRetorno	:= .F.						//Controla se o arquivo foi gravado

Default cNSU := ""

::FormatData(::oTransacao:dData, ::oTransacao:cHora, @cData, @cHora)

cCupom := AllTrim(Str(::oTransacao:nCupom))

//Grava o arquivo de controle
If Empty(cNSU)
	lRetorno := ::oGlobal:GravarArq():TransTef(cData, cHora):Gravar(cCupom + "/" + cData + "/" + cHora )
Else
	lRetorno := ::oGlobal:GravarArq():TransTef(cData, cHora):Gravar(cCupom + "/" + cData + "/" + cHora + "/" + cNSU )
EndIf
	
//Grava log
If lRetorno
	::GravarLog("Arquivo de controle gravado com sucesso (Cupom: " + cCupom + " ; Data: " + cData + " ; Hora: " + cHora + ")")
Else
	::GravarLog("Arquivo de controle nao foi gravado (Cupom: " + cCupom + " ; Data: " + cData + " ; Hora: " + cHora + ")")
EndIf
	
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณShow      	   บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tela para troca de dados com o sitef  	 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method Show() Class LJCComClisitef

If ExistFunc("IsRmt64") .AND. IsRmt64()
	::oFrmTef := LJCFrmTef():New(Self, ::cTitTran, "Clisitef64: " + ::cClisitef + " - Clisitef64I: " + ::cClisitefI)
Else
	::oFrmTef := LJCFrmTef():New(Self, ::cTitTran, "Clisitef32: " + ::cClisitef + " - Clisitef32I: " + ::cClisitefI)
EndIf

::oFrmTef:Show()
	
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณValColeta บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida / Armazena os dados coletados quando necessario	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ValColeta() Class LJCComClisitef

	Local lRetorno 	:= .T.			//Retorno do metodo
    Local nRetorno	:= 0			//Retorno do metodo que valida o codigo de barra - correspondente bancario
    Local aPgto		:= {}			//Array das formas de pagamento configuradas no clisitef.ini
    Local nPos		:= 0			//Posi็ใo encontrada da forma de pagamento selecionada
	Local nParcela	:= 1 			//Parcelas da transa็ใo    
    
	Do Case																							
	
		Case ::nProxComan == 20
			//Deve apresentar um menu de op็๕es e permitir que o usuแrio selecione uma delas. 
			//Na chamada o parโmetro Buffer cont้m as op็๕es no formato 1:texto;2:texto;...i:Texto;... 
			//A rotina da aplica็ใo deve apresentar as op็๕es da forma que ela desejar 
			//(nใo sendo necessแrio incluir os ํndices 1,2, ...) e ap๓s a sele็ใo feita pelo usuแrio, 
			//retornar em Buffer o ํndice i escolhido pelo operador (em ASCII)
			
			If ::nTipoCampo == 509
				//Captura se eh mes fechado (0) ou nao (1)
				::oRetorno:nMesFechad := Val(AllTrim(::cBuffer))
			EndIf
				
		Case ::nProxComan == 21
			//Deve apresentar um menu de op็๕es e permitir que o usuแrio selecione uma delas. 
			//Na chamada o parโmetro Buffer cont้m as op็๕es no formato 1:texto;2:texto;...i:Texto;... 
			//A rotina da aplica็ใo deve apresentar as op็๕es da forma que ela desejar 
			//(nใo sendo necessแrio incluir os ํndices 1,2, ...) e ap๓s a sele็ใo feita pelo usuแrio, 
			//retornar em Buffer o ํndice i escolhido pelo operador (em ASCII)
			
			If ::nTipoCampo == 731
				//Forma de pagamento selecionada na recarga de celular nao fiscal
				//1 - Dinheiro ; 2 - Cheque
				::oRetorno:cFormaCel 	:= AllTrim(::cBuffer)
				
				If ::oTransacao:nTipoTrans == 7 //Recarga de Celular
		            Do Case
		            	Case ::oRetorno:cFormaCel == "1"	//Dinheiro
		            		::oTransacao:cFormaPgto := SuperGetMV("MV_SIMB1",,"R$")
		            	Case ::oRetorno:cFormaCel == "2"	//Cheque
		            		::oTransacao:cFormaPgto := "CH"
		            	Otherwise
		            		/*
		            		Este tratamento ้ feito devido a configura็ใo do usuแrio com as formas de pagamento
		            		O indice atribuido para cada forma de pagamento pode variar, menos para Dinheiro e Cheque que sใo do padrใo
		            		De acordo com a cofigura็ใo do clisitef.ini. Abaixo tem um exemplo da remo็ใo do Cartใo de D้bito (62)
		            		fazendo o Cartใo de Cr้dito (63) mudar do indice 4 para o 3 
		            		
		            			Exemplo :	1 - Dinheiro			(60)			1 - Dinheiro			(60)
		            						2 - Cheque				(61)			2 - Cheque				(61)
		            						3 - Cartใo de D้bito	(62)			3 - Cartใo de Cr้dito	(63)
		            						4 - Cartใo de Cr้dito   (63)
		            		*/
		            		aPgto := StrTokarr(::oTransacao:cFormaPgto,";")
							nPos := aScan(aPgto, {|x| SubStr(x,1,1) == ::oRetorno:cFormaCel}) 
							::oTransacao:cFormaPgto := ""
							If nPos > 0
								If At("CART",Upper(aPgto[nPos])) > 0 .And. AT("DITO",Upper(aPgto[nPos])) > 0 //Valida็ใo para cartใo de credito
				            		::oTransacao:cFormaPgto := "CC"
				            	ElseIf At("CART",Upper(aPgto[nPos])) > 0 .And. AT("BITO",Upper(aPgto[nPos])) > 0 //Valida็ใo para cartใo de debito
				            		::oTransacao:cFormaPgto := "CD"	
								EndIf
							EndIf	            		
		            EndCase
				EndIf 
			EndIf
				
		Case ::nProxComan == 30
			//Deve ser lido um campo cujo tamanho esta entre TamMinimo e TamMaximo. 
			//O campo lido deve ser devolvido em Buffer
			
			If ::nTipoCampo == 500
				//Indica que o campo em questao eh o codigo do supervisor. A automacao, pode, se desejado, 
				//validar os dados coletados, deixando o fluxo da transacao seguir normalmente caso seja 
				//um supervisor aceitavel
			
				If !STFPROFILE(8)[1] // Cancela TEF
					If ExistFunc('STFAccess') .AND. !STFAccess()
						::ExibirMsg(STR0010) //"Acesso negado, usuแrio sem permissใo para cancelar transa็ใo TEF!" 
						lRetorno := .F.
					Else					 
						lRetorno := ::ValidarSup(AllTrim(::cBuffer))
					EndIf
				EndIf	  
			
			ElseIf ::nTipoCampo == 501
				//Tipo do Documento a ser consultado (0 - CPF, 1 - CGC)
				::oRetorno:nTipoDocCh := Val(AllTrim(::cBuffer))
		
			ElseIf ::nTipoCampo == 502
				//Numero do documento (CPF ou CGC)
				::oRetorno:cCPFCGC := AllTrim(::cBuffer)
																								
			ElseIf ::nTipoCampo == 503
				//Numero do Telefone
				::oRetorno:cTelefone	:= AllTrim(::cBuffer)
			
			ElseIf ::nTipoCampo == 505
				//Numero de parcelas
				::oRetorno:nParcelas  := Val(AllTrim(::cBuffer))

				If ValType(Self:oTransacao:nParcela) == "N" .AND. Self:oTransacao:nParcela > 0
					nParcela := Self:oTransacao:nParcela
	            EndIf

				::oTransacao:nParcela := Val(AllTrim(::cBuffer))

	       		lRetorno := ::ValidaParc(nParcela)   //Valida qtde de parcela digitada

				If !lRetorno
					If nParcela > 0
						::oTransacao:nParcela  := nParcela
						::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, PadR(cValToChar(nParcela),::nTamMax) , .F. , .T.)
					Else
						::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax, Space(::nTamMax) , .F. , .T.)
					EndIf
	       		ElseIf ::oRetorno:nParcelas <> nParcela //Se houve altera็ใo no n๚mero de parcela, reprocessa a Adm Financeira
					nParcela := ::oRetorno:nParcelas
	       			LjGrvLog(Nil, "Houve altera็ใo do numero de parcelas: ", nParcela)
					Self:TrataAdm(nParcela)
				EndIf
			
			ElseIf ::nTipoCampo == 506 
				//Data do Pre-Datado no formato DDMMAAAA
				::oRetorno:dPredatado := CTOD(SubStr(::cBuffer, 1, 2) + "/" + SubStr(::cBuffer, 3, 2) + "/" + SubStr(::cBuffer, 5, 4))
						
			ElseIf ::nTipoCampo == 508 
				//Intervalo em dias entre parcelas
				::oRetorno:nIntervalo := Val(AllTrim(::cBuffer))
			
			ElseIf ::nTipoCampo == 512
				//N๚mero do Cartใo de Cr้dito Digitado
				::oRetorno:cCartao := Val(AllTrim(::cBuffer))
			
			ElseIf ::nTipoCampo == 513
				//Data de vencimento do Cartao
				::oRetorno:cVencCartao := AllTrim(::cBuffer)
					
			ElseIf ::nTipoCampo == 514
				//Codigo de seguranca do Cartao
				::oRetorno:cSegCartao := AllTrim(::cBuffer)
						
			ElseIf ::nTipoCampo == 515
				//Data da transacao a ser cancelada (DDMMAAAA) ou a ser re-impressa	
				::oRetorno:dDataCanRei := CTOD(SubStr(::cBuffer, 1, 2) + "/" + SubStr(::cBuffer, 3, 2) + "/" + SubStr(::cBuffer, 5, 4)) 

			ElseIf ::nTipoCampo == 516
				//N๚mero do documento a ser cancelado ou a ser re-impresso
				::oRetorno:cDocCanRei := AllTrim(::cBuffer)
							
			ElseIf ::nTipoCampo == 592	//Recarga de Celular
				//N๚mero do documento a ser cancelado ou a ser re-impresso
				::oRetorno:cCelular := AllTrim(::cBuffer)
							
			EndIf
		
		Case ::nProxComan == 34
		
			If ::nTipoCampo == 146
				//Valor a ser cancelado
				::oRetorno:nValorCanc := Round(Val(::cBuffer),2)
			EndIf			
		    
			::cBuffer := AllTrim(StrTran(TransForm(Val(::cBuffer), "@E 999999999.99"), "," , "."))
		
		Case ::nProxComan == 35
			//Deve ser lido um c๓digo em barras ou o mesmo deve ser coletado manualmente. 
			//No retorno Buffer deve conter "0:" ou "1:" seguido do c๓digo em barras coletado manualmente 
			//ou pela leitora, respectivamente. Cabe ao aplicativo decidir se a coleta serแ manual ou atrav้s 
			//de uma leitora. Caso seja coleta manual, recomenda-se seguir o procedimento descrito na rotina 
			//ValidaCampoCodigoEmBarras de forma a tratar um c๓digo em barras da forma mais gen้rica possํvel, 
			//deixando o aplicativo de automa็ใo independente de futuras altera็๕es que possam surgir nos formatos em barras. 
			//No retorno do Buffer tamb้m pode ser passado "2:", indicando que a coleta foi cancelada, por้m o fluxo 
			//nใo serแ interrompido, logo no caso de pagamentos m๚ltiplos, todos os documentados coletados anteriormente 
			//serใo mantidos e o fluxo retomado, permitindo a efetiva็ใo de tais pagamentos.
						
			//Verifica se o documento foi lido atraves do CMC7
			If !::lLeuCMC7
				//Valida o codigo de barra
				nRetorno := ::ValCodBar(AllTrim(::cBuffer), -1)
				
				If nRetorno == 0
					::cBuffer := "0:" + AllTrim(::cBuffer)
				Else
					If nRetorno == 5 
						STFMessage("SiTEF", "STOP","C๓digo de barras inconsistente.")
						STFShowMessage("SiTEF") 
					Else
						STFMessage("SiTEF", "STOP", STR0008 + CVALTOCHAR(nRetorno) + STR0009)//"Inconsist๊ncias no bloco "#" do c๓digo de barras."
						STFShowMessage("SiTEF") 
					EndIf
					
					lRetorno := .F.
					
					::oFrmTef:Capturar("A", ::nTamMin, ::nTamMax)
				EndIf

			Else
				::cBuffer := "1:" + AllTrim(::cBuffer)	
			EndIf
									
		Otherwise
			
	EndCase		

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณApgArqCtrlบAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga o arquivo de controle do tef.         				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ				                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ApgArqCtrl() Class LJCComClisitef						
	
	Local lRetorno 	:= .F.							//Verifica se o arquivo foi apagado
	Local cData		:= ""							//Data da transacao
	Local cHora		:= "" 							//Hora da transacao
	
	::FormatData(::oTransacao:dData, ::oTransacao:cHora, @cData, @cHora)
	
	lRetorno := ::oGlobal:GravarArq():TransTef(cData, cHora):Apagar()
    
	If lRetorno
		::GravarLog("Arquivo de controle apagado com sucesso (" + "Data: " + cData + " - Hora: " + cHora + ")")
	Else
		::GravarLog("Arquivo de controle nao foi apagado (" + "Data: " + cData + " - Hora: " + cHora + ")")
	EndIf 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFinTrans         บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfimar ou desfaz uma transacao					 				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nConfirma) - Identifica se a transacao deve ser confirmaบฑฑ
ฑฑบ			 ณ						  (1) ou desfeita(0)	     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ																     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FinTrans(nConfirma) Class LJCComClisitef
	
	Local cData			:= ""			//Data da transacao
	Local cHora			:= "" 			//Hora da transacao
	Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI
		
	::FormatData(::oTransacao:dData, ::oTransacao:cHora, @cData, @cHora)
					
	//Prepara os parametros de envio
	oParamsApi := ::PrepParam({CLISITEF, "FinalizaTransacaoSiTefInterativo", AllTrim(Str(nConfirma)), ;
	                         	   AllTrim(Str(::oTransacao:nCupom)), cData, cHora})
    ::EnviarCom(oParamsApi)
    
    //Apagar o arquivo de controle da transacao
    ::ApgArqCtrl()
    
    oParamsApi:Destroy()
    oParamsApi := FreeObj(oParamsApi)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetRetornoบAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o objeto do tipo LJCRetornoSitef.  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ				                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetRetorno() Class LJCComClisitef
Return ::oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFechar   บAutor  ณVendas Clientes     บ Data ณ  18/01/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia o comando de encerramento da TotvsApi  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ				                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Fechar() Class LJCComClisitef
	::oTotvsApi:FecharCom()
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLeDadChq  บAutor  ณVendas Clientes     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe os dados do cheque solicitado pelo campo 31			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ				                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeDadChq(cBufCMC7) Class LJCComClisitef
	
	Local oFrmChq := LJCFrmCheque():New()				//Objeto do tipo LJCFrmCheque	
	Local lRetorno  := .F.								//Retorno do metodo
	//Local cBufCMC7  := ""								//String com o codigo de barra lido
    Local aRet		:= {} //Array de Retorno dos Dados
    Local aDados	:= {} //Array dos Dados de Retorno
    Local lUsaCMC7	:= .T.   //Verifica se usa CMC7
    Local nCount	:= 0     //Variavel contadora
    Local cCMC7		:= ""    //Valor do CMC7

	//Limpa os dados do cheque
	::oRetorno:nBanco		:= 0
   	::oRetorno:nAgencia		:= 0
   	::oRetorno:nConta		:= 0
   	::oRetorno:nCheque		:= 0
   	::oRetorno:nC1			:= 0
   	::oRetorno:nC2			:= 0
   	::oRetorno:nC3			:= 0
   	::oRetorno:nCompensa		:= 0

	//Verifica se utiliza CMC7 e se o mesmo efetua leitura de correspondente bancario
  
	
		aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
		 												"STCMC7Use"																,;		// Nome do evento
		 			   									{}  )

	  lUsaCMC7 := Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]
	
	If  lUsaCMC7 .AND. ::oTransacao:nTipoTrans <> _CHEQUE
	    aRet		:= {1}
    	cBufCMC7 := Space(200)
    	aDados := { , cBufCMC7 } 
    	
    
	    //Efetua a leitura         
		While (Len(aRet) < 1 .OR. aRet[1] == 1)  
		
		  	
		  	STFMessage("SiTEF", "RUN",STR0005,;    	
	 	 	{|| Sleep( 2000 ), 	aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
		 												"STCMC7DRead"																,;		// Nome do evento
		 			   									aDados)})// "Passe o documento e aguarde a leitura..."
            STFShowMesssage("SiTEF")
					   									
					   									
			
			cBufCMC7 := IIF(Len(aDados) > 1, aDados[2], "")   
			If  (Len(aRet) < 1 .OR. aRet[1] == 1) .OR. Empty(cBufCMC7)
	 			STFMessage("SiTEF", "YESNO", STR0006 ) //"Erro ao tentar ler o documento. Tentar ler novamente?" 
	 			If STFShowMessage("SiTEF") 
	 				//MsgYesNo(STR0006)//"Erro ao tentar ler o documento. Tentar ler novamente?"                
		            cBufCMC7 := Space(200)
		            aDados := { , cBufCMC7 }
		            aRet := {1}
				Else
					aRet := {0}
					lRetorno := .F.
				EndIf
			Else
	 	     	cCMC7:= ""                            
			    //cCMC7:= cBufCMC7	
				aRet := {0}
				lRetorno := .T.
	        EndIf
		End
		If lRetorno 
			oFrmChq:ShowCmC7(@cBufCMC7) 
		EndIf		
	
	Else
	
		//Transacao de cheque
		If ::oTransacao:nTipoTrans == _CHEQUE
		
			//Neste caso os dados do cheque ja estao na transacao
			oFrmChq:nBanco		:= ::oTransacao:nBanco
	   		oFrmChq:nAgencia	:= ::oTransacao:nAgencia
	   		oFrmChq:nConta		:= ::oTransacao:nConta 
	   		oFrmChq:nCheque		:= ::oTransacao:nCheque
	   		oFrmChq:nC1			:= ::oTransacao:nC1
	   		oFrmChq:nC2			:= ::oTransacao:nC2
	   		oFrmChq:nC3			:= ::oTransacao:nC3
	   		oFrmChq:nCompensa	:= ::oTransacao:nCompensa
			
		EndIf
		
		//Exibe a tela
		oFrmChq:Show()
		
		//Atribui os dados lido para os atributos da classe de retorno
		::oRetorno:nBanco		:= oFrmChq:nBanco
	   	::oRetorno:nAgencia		:= oFrmChq:nAgencia
	   	::oRetorno:nConta		:= oFrmChq:nConta
	   	::oRetorno:nCheque		:= oFrmChq:nCheque
	   	::oRetorno:nC1 			:= oFrmChq:nC1
	   	::oRetorno:nC2			:= oFrmChq:nC2
	   	::oRetorno:nC3			:= oFrmChq:nC3
		::oRetorno:nCompensa		:= oFrmChq:nCompensa
				
	
	EndIf  
	

	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLeDadChq  บAutor  ณVendas Clientes     บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe o codigo de barra do correspondente bancario			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCodBar(cCMC7)Class LJCComClisitef

	Local lRetorno  := .F.								//Retorno do metodo
	Local cBufCMC7  := ""								//String com o codigo de barra lido
	Local nRetorno	:= 1								//Retorno da funcao que efetua a leitura.
	Local lCmc7Cb	:= SuperGetMv("MV_LJLECB",,.F.)	//Utilizado para habilitar a leitura do documento atraves do cmc7 da impressora fiscal
    Local aRet		:= {} //Array de Retorno dos Dados
    Local aDados	:= {} //Array dos Dados de Retorno
    Local lUsaCMC7	:= .F.  //Verifica se a esta็ใo usa CMC7
	//Verifica se utiliza CMC7 e se o mesmo efetua leitura de correspondente bancario         
	
		
	aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
		 												"STCMC7Use"																,;		// Nome do evento
		 			   									{})

	lUsaCMC7 := Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]
	
	If  lUsaCMC7 .AND. lCmc7Cb
	    aRet		:= {1}
    	cBufCMC7 := Space(500)
    	aDados := {, cBufCMC7} 
    	
    
	    //Efetua a leitura         
		While (Len(aRet) < 1 .OR. aRet[1] == 1)     
			
			
			STFMessage("SiTEF","RUN",STR0005,; // "Passe o documento e aguarde a leitura..."		   									
		 		{|| Sleep( 2000 ), 	aRet :=	STFFireEvent(	ProcName(0),"STCMC7DCRead",aDados)})// "Passe o documento e aguarde a leitura..."					   									
				
			cBufCMC7 := IIF(Len(aDados) > 1, aDados[2], "")   
						If  (Len(aRet) < 1 .OR. aRet[1] == 1) .OR. Empty(cBufCMC7)
	 		
	 		STFMessage("SiTEF", "YESNO", STR0006 ) //"Erro ao tentar ler o documento. Tentar ler novamente?" 
	 		If STFShowMessage("SiTEF")                
		            cBufCMC7 := Space(500)
		            aRet := {1}
				Else
					aRet := {0}
					lRetorno := .F.
				EndIf
			Else
	 	     	cCMC7:= ""
			    cCMC7:= cBufCMC7	
				aRet := {0}
				lRetorno := .T.
	        EndIf
		End
	EndIf

Return lRetorno    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณRetornaAdmบAutor  ณVendas Clientes     บ Data ณ  25/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Administradora Financeira, conforme codigo SiTEF  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico		                                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method RetornaAdm(cCodBand, cForma, nParcelas, cCodRede) Class LJCComClisitef
Local aRetorno	:= {}
Local oTEF		:= STBGetTef()
Local aAdmin	:= oTef:Administradoras()
Local nPos		:= 0
Local lPesqREDE := Len(aAdmin) > 0 .And. Len(aAdmin[1]) > 8 //Verifica se alem da Bandeira, considera tambem a pesquisa por Rede  
Local lAchouADM := .F.

Default cCodRede := ""

LjGrvLog( Nil, "Forma de pagamento", cForma )
LjGrvLog( Nil, "Quantidade de Parcelas", nParcelas )
LjGrvLog( Nil, "Codigo da Bandeira retornada pelo SITEF", cCodBand )
LjGrvLog( Nil, "Codigo da Rede retornada pelo SITEF", cCodRede )

aSort(aAdmin, , , { |a, b| a[2] + a[8] + StrZero(a[4], 4) + StrZero(a[5], 4) < b[2] + b[8] + StrZero(b[4], 4) + StrZero(b[5], 4)} )

//realiza a busca da Adm.Fin. baseado no Codigo SITEF (oitava posicao do array)
If ( nPos := aScan(aAdmin, { |a| a[2] == cForma .AND. a[8] == cCodBand }) )  > 0

	Do While nPos <= Len(aAdmin) .AND. aAdmin[nPos, 2] == cForma .AND. aAdmin[nPos, 8] == cCodBand 		  
	  	
	  	//Verifica se esta dentro do range de parcelas
	  	If aAdmin[nPos, 4]  <= nParcelas .AND. aAdmin[nPos, 5] >=  nParcelas
			lAchouADM := .T.
		Else
			LjGrvLog( Nil, "A parcela retornada nao esta entre os valores dos campos Parcela De e Ate da Adm.Fin.", aAdmin[nPos][3] )
			lAchouADM := .F.				
		EndIf
		
	  	//Verifica se esta relacionado com o codigo da REDE retornada pelo SITEF
	  	If lAchouADM .And. lPesqREDE
	  		//Verifica se a Rede configurada eh igual a Rede retornada pelo SITEF ou se a Rede estah em branco (nao configurado o campo AE_REDEAUT)
	  		If aAdmin[nPos, 9] == cCodRede .Or. Empty(aAdmin[nPos, 9]) 
				lAchouADM := .T.
			Else
				lAchouADM := .F.				
			EndIf
		EndIf
		
		If lAchouADM
			Aadd( aRetorno, aAdmin[nPos] )
		EndIf

		nPos++
	EndDo
Else
	LjGrvLog( Nil, "Nenhuma Adm.Fin. possui o campo Cod.SITEF vinculado ao codigo da bandeira retornado", cCodBand )		 
EndIf

If Len(aRetorno) == 0
	LjGrvLog(Nil, "Nao foi possivel selecionar nenhuma Adm.Fin. atraves da tabela MDE")
ElseIf Len(aRetorno) > 1
	LjGrvLog(Nil, "Retornado mais de uma Adm. Fin com o mesmo Cod.SITEF / Forma de Pagamento / Parcelas" )
EndIf

Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTefProcessaบAutor  ณVendas Clientes     บ Data ณ  31/07/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta em nova janela de proceso o comando 23 do sitef     บฑฑ
ฑฑบ          ณque aguarda acao de cancelar do usuario enquanto captura    บฑฑ 
ฑฑบ          ณdados como cartao e senha etc... usado na homologacao       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja / POS                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TefProcessa( lEndTef ) Class LJCComClisitef

Local nRetorno		:= 0			//Retorno do metodo
Local cRetorno 		:= ""       	//Retorno do comando enviado   
Local cBuffer 		:= ""          	//Buffer 
Local nContinua 	:= 0 	        //Continua funcao
Local oParamsApi 	:= Nil			//Objeto do tipo LJCParamsAPI

Default lEndTef 	:= .F.

::cBuffer 	:= cBuffer
::nContinua := nContinua
	
ProcRegua(10)

While !lEndTef

	IncProc(10)
	
    //Prepara os parametros de envio

	oParamsApi := ::PrepParam({CLISITEF, "ContinuaFuncaoSiTefInterativo", AllTrim(Str(::nProxComan)), ;
                         	   AllTrim(Str(::nTipoCampo)), AllTrim(Str(::nTamMin)), AllTrim(Str(::nTamMax)), ;
                              ::cBuffer, AllTrim(Str(Len(::cBuffer))), AllTrim(Str(::nContinua))})  
	
	cRetorno := ::EnviarCom(oParamsApi)
	nRetorno := Val(cRetorno)
	
	
   If nRetorno == 10000
    	
    	::nProxComan		:= Val(oParamsApi:Elements(3):cParametro)
    	::nTipoCampo		:= Val(oParamsApi:Elements(4):cParametro)
    	::nTamMin			:= Val(oParamsApi:Elements(5):cParametro)
    	::nTamMax			:= Val(oParamsApi:Elements(6):cParametro)
    	::cBuffer			:= oParamsApi:Elements(7):cParametro
    	::nMaxBuffer		:= Val(oParamsApi:Elements(8):cParametro)	
    	::nContinua			:= Val(oParamsApi:Elements(9):cParametro)	
    	
    	oParamsApi:Destroy()   
    	oParamsApi := FreeObj(oParamsApi)
    	
    	oParamsApi := Nil
    	
		If ::nProxComan == 23
			cBuffer := ""
			nContinua := 0 
			::cBuffer := cBuffer
			::nContinua := nContinua
		Else
			Exit			
		EndIf
   
   Else //Se teve Erro no TEF
   			
   		//Apaga o arquivo de controle
    	::ApgArqCtrl()
    	//Trata retorno
    	::TratarRet(nRetorno, _TRANSACAO)
    	::oFrmTef:Fechar()  
   EndIf 
   	
	
	If lEndTef
      ::oFrmTef:ContinFunc(-1)
      Exit
   EndIf
	
EndDo

Return lEndTef

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaParc
Validacao da Qtde de parcelas informada na tela do TEF.

@param      	
@author  Varejo
@version P12
@since   02/04/2015
@Param 	nParcAnt Recebe o numero da parcela anterior 
@return  .T. se a parcela digitada for vแlida / .F. Se a parcela digitada NรO for vแlida.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method ValidaParc(nParcAnt) Class LJCComClisitef
Local lRet 		:= .T.

If ExistFunc("STBVldParc")
	//Chama a funcao de validacao da parcela digitada
	lRet := STBVldParc(Self:oFrmTef:cGetDados,Self:oFrmTef:oComSitef:oRetorno:cAdmFin,Self:oFrmTef:oComSitef:oRetorno:cRede,Self:oFrmTef:oComSitef:oRetorno:cTpCartao,nParcAnt,Self:oFrmTef:oComSitef:oTransacao:nValor)
EndIf

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj1926VlCan
Validacao da exclusใo do arquivo de queda do sistema do TEF.

@param      	
@author  Varejo
@version P11
@since   09/05/2017
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method Lj1926VlCan(oArquivos, cDoc, lExistSL4) Class LJCComClisitef

Local nCount 	:= 0		// Contador
Local dData		:= ""		// Data da transacao
Local cHora		:= "" 		// Hora da transacao
Local cDataArq	:= ""		// Data do Arquivo
Local cHoraArq	:= "" 		// Hora do Arquivo


For nCount := 1 To oArquivos:Count()


	cDataArq := Substr( oArquivos:acolecao[nCount][1] , 4, 8)
	cHoraArq := Substr( oArquivos:acolecao[nCount][1] , 12, 6)
	
	If !lExistSL4
		dData := CTOD(Substr( cDataArq , 7, 2) + "/" + Substr( cDataArq , 5, 2) + "/" + Substr( cDataArq , 1, 4))
		cHora := Substr( cHoraArq , 1, 2) + ":" + Substr( cHoraArq , 3, 2) + ":" + Substr( cHoraArq , 5, 2)
		
		//Criar uma transacao generica para fazer o desfazimento ou confirmacao
		::oTransacao := LJCDadosTransacaoGenerica():New(Nil, Val(cDoc) , dData, cHora)
		
		STFMessage("SiTEF","RUN","Cancelando Transacao TEF. Aguarde...", {|| ::FinTrans(0)})					
		STFShowMessage("SiTEF")	
		::GravarLog("Transacao Tef Desfeita" + " (" + cDoc + " - " + cDataArq + " - " + cHoraArq + ")")
	EndIf
		
	FERASE(GetClientDir() + "transtef" + "\tef" + cDataArq + cHoraArq + ".txt")

Next

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} TrataAdm
Trata a Administrador Financeira

@param nParcela     	
@author  fabiana.silva
@version P11
@since   02/06/2017
@return  nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method TrataAdm(nParcela) Class LJCComClisitef

			
If (::oTransacao:nTipoTrans > 0 .AND. ::oTransacao:nTipoTrans <= 5) .Or. (::oTransacao:nTipoTrans == 7) //7 = Recarga Celular
	
    LjGrvLog(Nil, "Quantidade de parcelas informado na rotina: ", nParcela)
	
   ::oRetorno:aAdmin := aClone( Self:RetornaAdm(::oRetorno:cTpCartao, ::oTransacao:cFormaPgto, nParcela, ::oRetorno:cInstit) )

EndIf


If Len(::oRetorno:aAdmin) == 1
	::oRetorno:cAdmFin := ::oRetorno:aAdmin[1][7]
	LjGrvLog(Nil, "Descricao da bandeira(MDE_DESC) retornada pela tabela MDE: ", ::oRetorno:cAdmFin )
Else
	If ::oTiposCart:Contains(::oRetorno:cTpCartao)
		::oRetorno:cAdmFin := ::oTiposCart:ElementKey(::oRetorno:cTpCartao)
		LjGrvLog(Nil, "Descricao da bandeira retornada pelo HashTable: ", ::oRetorno:cAdmFin ) 
	Else
		::oRetorno:cAdmFin := ::oTiposCart:Elements(1)
		LjGrvLog(Nil, "Descricao da bandeira nao encontrada, sera retornada a descricao OUTRAS")
	EndIf            		
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CPFPinPad
Solicita o CPF pelo PinPad

@param		cEntrada 	- String com o texto para ser apresentado no Pinpad
			cSaida		- String para retorno com o CPF digitado
@author		JMM
@version	V12.1.25
@since		09/08/2019
@return		nRetDLL		- C๓digo do retorno ao comando enviado a DLL	
@obs     
/*/
//-------------------------------------------------------------------
Method CPFPinPad( cEntrada, cSaida ) Class LJCComClisitef
Local nRetDLL		:= -99999	// Retorno de sucesso ou nใo ao comando da DLL
Local oParamsApi 	:= Nil		//Objeto do tipo LJCParamsAPI

//Prepara os parametros de envio
oParamsApi	:= ::PrepParam({CLISITEF, "ObtemDadoPinPadDiretoEx", "", "", cEntrada, cSaida})
nRetDLL		:= ::EnviarCom(oParamsApi)

cSaida 	:= oParamsApi:aColecao[3][2]:cParametro

oParamsApi:Destroy()
oParamsApi := FreeObj(oParamsApi)

Return nRetDLL

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvVDLCons
Consulta PBM Vidalink

@param		oDados, objeto, contem os dados da transa็ใo
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		nRetDLL		- C๓digo do retorno ao comando enviado a DLL	
@obs     
/*/
//-------------------------------------------------------------------
Method EnvVDLCons(oDadosTran) Class LJCComClisitef
Local nRet		:= 0
Local cRetorno 	:= ""       	//Retorno do comando enviado
Local oParamsApi:= Nil			//Objeto do tipo LJCParamsAPI

::oRetorno := LJCRetornoSitef():New()

//Prepara os parametros de envio
oParamsApi := ::PrepParam({CLISITEF, "IniciaFuncaoSiTefInterativoConsultaVidalink", oDadosTran:cCodAut, ;
								oDadosTran:cCodProd, oDadosTran:cCupomFisc, oDadosTran:cDataFisc,;
								oDadosTran:cHorario, oDadosTran:cOperador})

cRetorno := ::EnviarCom(oParamsApi)

//Carrega o retorno
oDadosTran:cCodAut 	:= oParamsApi:Elements(3):cParametro
oDadosTran:cCodProd := Val(oParamsApi:Elements(4):cParametro)
oDadosTran:cCupomFisc:= oParamsApi:Elements(5):cParametro
oDadosTran:cDataFisc:= oParamsApi:Elements(6):cParametro
oDadosTran:cHorario := oParamsApi:Elements(7):cParametro
oDadosTran:cOperador:= oParamsApi:Elements(8):cParametro
oParamsApi:Destroy()
oParamsApi := FreeObj(oParamsApi)

nRet := Val(cRetorno)

If nRet == 10000
	//Gravar arquivo de controle para confirmar ou desfazer a transacao
	
	If ValType( ::oTransacao ) <> "O"
		::oTransacao := LJCDadosTransacaoGenerica():New(Nil, Val(oDadosTran:cCupomFisc) , SToD(oDadosTran:cDataFisc), StrTran(oDadosTran:cHorario,":"))
	EndIf

	::oTransacao:aVDLink := oDadosTran:aVDLink

	::GrvArqCtrl()
	//Carrega tela do sitef para troca de informacoes
	::Show()
Else
	::TratarRet(nRet, _TRANSACAO)
EndIf

Return nRet