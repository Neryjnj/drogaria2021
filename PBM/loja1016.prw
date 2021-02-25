#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1016 ; Return  			// "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCSitefPBM      บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em fazer a comunicacao com o sitef.        	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCSitefPBM
	
	Data oGlobal													//Objeto do tipo global
	Data oClisitef													//Objeto do tipo LJCComClisitef
	
	Method SitefPBM()                    	       					//Metodo construtor
	Method EnvTrans(oDadosTran)    									//Metodo que ira enviar a transacao ao sitef
	Method FimTrans(lConfirma, cCupomFisc, cDataFisc, cHorario)		//Metodo que ira confirmar ou desfazer a transacao
	Method LeCartDir(cMensagem, cTrilha1, cTrilha2)					//Metodo que ira ler o cartao
	
	//Metodos internos
	Method TrataRet(oDadosTran)										//Metodo que ira tratar o retorno da autocom do enviasitefdireto
	Method TratRetCat(cTrilha1, cTrilha2)							//Metodo que ira tratar o retorno da leitura do cartao
	
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSitefPBM  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCSitefPBM.				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออหออออออออหออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ DATA     ณ BOPS บProgram.บALTERACAO                                   บฑฑ
ฑฑฬออออออออออุออออออหออออออออหออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออสออออออออสออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SitefPBM(oClisitef) Class LJCSitefPBM
	
	Default oClisitef := Nil
	
	Self:oClisitef := oClisitef

	//Estancia o objeto Global
	::oGlobal := LJCGlobal():Global()
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnvTrans  บAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel por enviar as transacoes ao sitef.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oDadosTran ) - Objeto do tipo DadosSitefDireto   บฑฑ
ฑฑบ			 ณcom os dados da transacao.								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvTrans(oDadosTran) Class LJCSitefPBM
		
	oDadosTran:cDadosRx 	:= Space(10000)
	oDadosTran:nTaDadosRx	:= Len(oDadosTran:cDadosRx)
	oDadosTran:nTempEspRx 	:= 30
	
	If Self:oClisitef <> Nil
		//Se o objeto oClisitef estiver diferente de NULL, significa que a aplicacao esta configurada para
		//trabalhar com a nova arquitetura do tef que por sua vez utiliza a TOTVSAPI.DLL
		
		//Envia a transacao para o sitef
	   	oDadosTran:nRetorno := Self:oClisitef:EnvSitDir(@oDadosTran)
		
	Else
		//Grava o log dos dados da transacao
		::oGlobal:GravarArq():Log():Tef():_Gravar("RedeDestino(" + AllTrim(Str(oDadosTran:nRedeDest)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("FuncaoSitef(" + AllTrim(Str(oDadosTran:nFuncSitef)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("OffSetCartao(" + AllTrim(Str(oDadosTran:nOffSetCar)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("DadosTX(" + oDadosTran:cDadosTx + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("CupomFiscal(" + oDadosTran:cCupomFisc + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("DataFiscal(" + oDadosTran:cDataFisc + ")")		
		::oGlobal:GravarArq():Log():Tef():_Gravar("Horario(" + oDadosTran:cHorario + ")")			
		::oGlobal:GravarArq():Log():Tef():_Gravar("Operador(" + oDadosTran:cOperador + ")")			
		::oGlobal:GravarArq():Log():Tef():_Gravar("TempoEsperaRx(" + AllTrim(Str(oDadosTran:nTempEspRx)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("TipoTransacao(" + AllTrim(Str(oDadosTran:nTpTrans)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("nTaDadosRx(" + AllTrim(Str(oDadosTran:nTaDadosRx)) + ")")
		
		//Envia a transacao para o sitef
	   	oDadosTran:nRetorno := oTef:SitefDireto(oDadosTran:nRedeDest, oDadosTran:nFuncSitef, ;
												oDadosTran:nOffSetCar, oDadosTran:cDadosTx, ;
												oDadosTran:nTaDadosTx, oDadosTran:cDadosRx, ;
												oDadosTran:nTaDadosRx, oDadosTran:nCodResp, ;
												oDadosTran:nTempEspRx, oDadosTran:cCupomFisc, ;
												oDadosTran:cDataFisc , oDadosTran:cHorario, ;
												oDadosTran:cOperador , oDadosTran:nTpTrans)
	
		//Trata o retorno da autocom	
		If oDadosTran:nRetorno > 0 
			::TrataRet(oDadosTran)
		EndIf
								
		//Grava o log dos dados da transacao
		::oGlobal:GravarArq():Log():Tef():_Gravar("CodigoResposta(" + AllTrim(Str(oDadosTran:nCodResp)) + ")")
		::oGlobal:GravarArq():Log():Tef():_Gravar("Retorno(" + AllTrim(Str(oDadosTran:nRetorno)) + ")")	
		::oGlobal:GravarArq():Log():Tef():_Gravar("DadosRx(" + oDadosTran:cDadosRx + ")")	
		::oGlobal:GravarArq():Log():Tef():_Gravar(" ")
	
	EndIf
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFimTrans  บAutor  ณVendas Clientes     บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em confirmar ou desfazer a transacao.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1 (1 - lConfirma)  - Se a transacao sera confirmada ou  บฑฑ
ฑฑบ			 ณ						   desfeita.						  บฑฑ
ฑฑบ			 ณExpC1 (2 - cCupomFisc) - Numero do cupom fiscal.            บฑฑ
ฑฑบ			 ณExpC2 (3 - cDataFisc)  - Data da transacao.(AAAAMMDD)       บฑฑ
ฑฑบ			 ณExpC3 (4 - cHorario)   - Hora da transacao.(HHMMSS)         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FimTrans(lConfirma, cCupomFisc, cDataFisc, cHorario) Class LJCSitefPBM
	
	Local nConfirma := 0					//Indica se a transacao devera ser confirmada(1) ou desfeita(0)
	Local cCupomTef	:= 0					//Numero do cupom
	Local cDataTef	:= 0					//Data
	Local cHoraTef	:= 0					//Hora
	Local cLog		:= ""					//String que sera gravada no log
				
	If lConfirma
		nConfirma := 1
	EndIf
	
	//Guarda os valores que estao no objeto oTef
	cCupomTef	:= oTef:cCupom
	cDataTef	:= oTef:cData
	cHoraTef	:= oTef:cHora
	
	//Atribui os dados para o objeto do tef
	oTef:cCupom	:= cCupomFisc
	oTef:cData	:= cDataFisc
	oTef:cHora	:= cHorario
	
	//Grava o log
	If nConfirma == 1
		cLog := "Transacao PBM Confirmada"
	Else
		cLog := "Transacao PBM Desfeita"
	EndIf
	
	::oGlobal:GravarArq():Log():Tef():_Gravar(cLog + " (" + cCupomFisc + " - " + cDataFisc + " - " + cHorario + ")")
		
	//Confirma ou desfaz a transacao
	oTef:FinalTrn(nConfirma)
	
	//Retorna os valores para o objeto oTef
	oTef:cCupom := cCupomTef
	oTef:cData	:= cDataTef
	oTef:cHora	:= cHoraTef
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLeCartDir บAutor  ณVendas Clientes     บ Data ณ  27/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em fazer a leitura direta do cartao.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cMensagem)  - Mensagem do pinpad.				  บฑฑ
ฑฑบ			 ณExpC2 (2 - cTrilha1)   - Trilha 1 do cartao.	              บฑฑ
ฑฑบ			 ณExpC3 (3 - cTrilha2)   - Trilha 2 do cartao. 				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCartDir(cMensagem, cTrilha1, cTrilha2) Class LJCSitefPBM
	
	Local nRetorno := 0					//Retorno do metodo
	
	If Self:oClisitef <> Nil
		//Se o objeto oClisitef estiver diferente de NULL, significa que a aplicacao esta configurada para
		//trabalhar com a nova arquitetura do tef que por sua vez utiliza a TOTVSAPI.DLL
		
	   	nRetorno := Self:oClisitef:LeCartao(cMensagem, @cTrilha1, @cTrilha2)
	
	Else
		nRetorno := oTef:LeCartDir(cMensagem, @cTrilha1, @cTrilha2)
	
		If nRetorno == 0
			::TratRetCat(@cTrilha1, @cTrilha2)	
		EndIf
	EndIf
	
Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTrataRet  บAutor  ณVendas Clientes     บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel por tratar o retorno da autocom.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oDadosTran ) - Objeto do tipo DadosSitefDireto   บฑฑ
ฑฑบ			 ณcom os dados da transacao.								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TrataRet(oDadosTran)	Class LJCSitefPBM
	
	Local oDados 	:= {}						//Variavel de retorno do metodo
	Local nCount	:= 1						//Contador utilizado na chave da colecao
	Local nCount1	:= 0                       	//Contador utilizado para ler a string da direita para esquerda
	Local cAux		:= ""						//Variavel auxiliar
	Local lLoop		:= .T.						//Variavel de controle do While
	Local cDelimit  := Chr(1)					//Delimitador dos parametros
	Local cDados	:= ""						//Dados do cBuffer
	Local cDadosR   := ""						//Utilizada para quebrar a string da direita para esquerda
	Local nPosFimRx	:= 0						//Posicao final do dados RX
	
	//Estancia o objeto colecao
	oDados := LJCColecao():Colecao()
	
	//Pega os dados do cBuffer
	cDados := oAutocom:cBuffer

	//Retira o delimitador do inicio da string
	If Substr(cDados, 1, 1) == cDelimit
		cDados := Substr(cDados, 2)
	EndIf

	//Retira o delimitador do fim da string
	If Substr(cDados, Len(cDados), 1) == cDelimit
		cDados := Substr(cDados, 1, Len(cDados) - 1)
	EndIf
	
	While lLoop
		//Parametro DadosRx
		If nCount == 6
			//Coloca a string em uma variavel auxiliar
			cDadosR := cDados
			//Procura a posicao final do dadosRX
			For nCount1 := 1 To 8 
				nPosFimRx := ::oGlobal:Funcoes():Rat(cDadosR, cDelimit)
				cDadosR := Substr(cDadosR, 1, nPosFimRx - 1) 				
			Next
			//Seta a posicao final do dadosRX
			nPos := nPosFimRx
		Else
			//Procura o delimitador na string
			nPos := At(cDelimit, cDados)
		EndIf
			    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			cAux := Substr(cDados, 1, nPos-1)
			cDados := Substr(cDados, nPos + 1)
			oDados:Add("P" + AllTrim(Str(nCount)), cAux)
		Else
			oDados:Add("P" + AllTrim(Str(nCount)), cDados)
			lLoop := .F.
		EndIf
		
		nCount ++
	End

	If oDados:Count() > 0
		//Separa o parametro DadosRx
		oDadosTran:cDadosRx := oDados:Elements(6)
		
		//Separa o parametro CodigoResposta
		oDadosTran:nCodResp := Val(oDados:Elements(8))
	EndIf
			
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTratRetCatบAutor  ณVendas Clientes     บ Data ณ  27/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em tratar o retorno da leitura direta do cartao.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cTrilha1)   - Trilha 1 do cartao.	              บฑฑ
ฑฑบ			 ณExpC2 (2 - cTrilha2)   - Trilha 2 do cartao. 				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TratRetCat(cTrilha1, cTrilha2) Class LJCSitefPBM 
	
	Local oDados 	:= {}						//Variavel de retorno do metodo
	Local nCount	:= 1						//Contador utilizado na chave da colecao
	Local cAux		:= ""						//Variavel auxiliar
	Local lLoop		:= .T.						//Variavel de controle do While
	Local cDelimit  := Chr(1)					//Delimitador dos parametros
	Local cDados	:= ""						//Dados do cBuffer
	
	//Estancia o objeto colecao
	oDados := LJCColecao():Colecao()
	
	//Pega os dados do cBuffer
	cDados := oAutocom:cBuffer
	
	//Retira o delimitador do inicio da string
	If Substr(cDados, 1, 1) == cDelimit
		cDados := Substr(cDados, 2)
	EndIf

	//Retira o delimitador do fim da string
	If Substr(cDados, Len(cDados), 1) == cDelimit
		cDados := Substr(cDados, 1, Len(cDados) - 1)
	EndIf
	
	While lLoop
		
		//Procura o delimitador na string
		nPos := At(cDelimit, cDados)
					    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			cAux := Substr(cDados, 1, nPos-1)
			cDados := Substr(cDados, nPos + 1)
			oDados:Add("P" + AllTrim(Str(nCount)), cAux)						
		Else
			oDados:Add("P" + AllTrim(Str(nCount)), cDados)
			lLoop := .F.
		EndIf
		
		nCount ++
	End

	If oDados:Count() > 0
		//Separa as trilhas
		cTrilha1 := oDados:Elements(2)
		cTrilha2 := oDados:Elements(3)
		cTrilha2 := Substr(cTrilha2, 1, Len(cTrilha2) -1)
	EndIf
	
Return Nil
