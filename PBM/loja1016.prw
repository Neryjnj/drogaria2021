#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1016 ; Return  			// "dummy" function - Internal Use

/*----------------------------------------------------------------------------------
���Classe    �LJCSitefPBM      �Autor  �Vendas Clientes     � Data �  06/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em fazer a comunicacao com o sitef.        	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
----------------------------------------------------------------------------------*/
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
	Method VDLinkCons(oDadosTran)
	Method VDLinkProd(oDadosTran)
	Method VDLinkVenda(oDadosTran)
	Method PharmSCons(oDadosTran)
	Method FuncCrCons(oDadosTran)
	
EndClass

/*---------------------------------------------------------------------------
���Metodo    �SitefPBM  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCSitefPBM.				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
---------------------------------------------------------------------------*/
Method SitefPBM(oClisitef) Class LJCSitefPBM
	
	Default oClisitef := Nil
	
	Self:oClisitef := oClisitef

	//Estancia o objeto Global
	::oGlobal := LJCGlobal():Global()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnvTrans  �Autor  �Vendas Clientes     � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel por enviar as transacoes ao sitef.              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosTran ) - Objeto do tipo DadosSitefDireto   ���
���			 �com os dados da transacao.								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �FimTrans  �Autor  �Vendas Clientes     � Data �  21/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em confirmar ou desfazer a transacao.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1 (1 - lConfirma)  - Se a transacao sera confirmada ou  ���
���			 �						   desfeita.						  ���
���			 �ExpC1 (2 - cCupomFisc) - Numero do cupom fiscal.            ���
���			 �ExpC2 (3 - cDataFisc)  - Data da transacao.(AAAAMMDD)       ���
���			 �ExpC3 (4 - cHorario)   - Hora da transacao.(HHMMSS)         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LeCartDir �Autor  �Vendas Clientes     � Data �  27/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em fazer a leitura direta do cartao.            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cMensagem)  - Mensagem do pinpad.				  ���
���			 �ExpC2 (2 - cTrilha1)   - Trilha 1 do cartao.	              ���
���			 �ExpC3 (3 - cTrilha2)   - Trilha 2 do cartao. 				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrataRet  �Autor  �Vendas Clientes     � Data �  22/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel por tratar o retorno da autocom.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosTran ) - Objeto do tipo DadosSitefDireto   ���
���			 �com os dados da transacao.								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratRetCat�Autor  �Vendas Clientes     � Data �  27/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno da leitura direta do cartao.���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTrilha1)   - Trilha 1 do cartao.	              ���
���			 �ExpC2 (2 - cTrilha2)   - Trilha 2 do cartao. 				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//-------------------------------------------------------------------
/*/{Protheus.doc} VDLinkCons
Consulta PBM Vidalink

@param		oDados, objeto, contem os dados da transa��o
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		nRetDLL		- C�digo do retorno ao comando enviado a DLL	
@obs     
/*/
//-------------------------------------------------------------------
Method VDLinkCons(oDadosTran) Class LJCSitefPBM

//Envia a transacao para o sitef
oDadosTran:nRetorno := Self:oClisitef:EnvVDLCons(@oDadosTran)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VDLinkProd
Produto PBM Vidalink

@param		oDados, objeto, contem os dados da transa��o
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		nRetDLL		- C�digo do retorno ao comando enviado a DLL	
@obs     
/*/
//-------------------------------------------------------------------
Method VDLinkProd(oDadosTran) Class LJCSitefPBM

//Envia a transacao para o sitef
oDadosTran:nRetorno := Self:oClisitef:EnvVDLProd(@oDadosTran)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VDLinkVenda
Venda Produto PBM Vidalink

@param		oDados, objeto, contem os dados da transa��o
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		nRetDLL		- C�digo do retorno ao comando enviado a DLL	
@obs     
/*/
//-------------------------------------------------------------------
Method VDLinkVenda(oDadosTran) Class LJCSitefPBM

//Envia a transacao para o sitef
oDadosTran:nRetorno := Self:oClisitef:EnvVDLVenda(@oDadosTran)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PharmSCons
Consulta PBM PharmaSystem

@param		oDados, objeto, contem os dados da transa��o
@author		Julio.Nery
@version	12
@since		26/03/2021
@return		nRetDLL		- C�digo do retorno ao comando enviado a DLL
/*/
//-------------------------------------------------------------------
Method PharmSCons(oDadosTran) Class LJCSitefPBM
Local oTrans := NIL

oTrans := LJADadosTransacao():New(oDadosTran:nValor,Val(oDadosTran:cCupomFisc), Stod(oDadosTran:cDataFisc),oDadosTran:cHorario,;
								  1,,"",,oDadosTran:cOperador,,,oDadosTran:aVDLink)
Self:oCliSitef:SetTrans(oTrans)

//Envia a transacao para o sitef
oDadosTran:nRetorno := Self:oClisitef:IniciaFunc(oDadosTran:nFuncSitef, oDadosTran:cRestri)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FuncCrCons
Consulta PBM Funcional Card

@param		oDados, objeto, contem os dados da transa��o
@author		Julio.Nery
@version	12
@since		26/03/2021
@return		nRetDLL		- C�digo do retorno ao comando enviado a DLL
/*/
//-------------------------------------------------------------------
Method FuncCrCons(oDadosTran) Class LJCSitefPBM
Local oTrans := NIL

oTrans := LJADadosTransacao():New(oDadosTran:nValor,Val(oDadosTran:cCupomFisc), Stod(oDadosTran:cDataFisc),oDadosTran:cHorario,;
								  1,,"",,oDadosTran:cOperador,,,oDadosTran:aVDLink)
Self:oCliSitef:SetTrans(oTrans)

//Envia a transacao para o sitef
oDadosTran:nRetorno := Self:oClisitef:IniciaFunc(oDadosTran:nFuncSitef, oDadosTran:cRestri)

Return Nil