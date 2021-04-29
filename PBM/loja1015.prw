#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1015.CH"
  
#DEFINE SEPARADOR Chr(0)				//Utilizado para separar os dados da mensagem
#DEFINE FUNCSITEF 240                  //Codigo da funcao sitef

User Function LOJA1015 ; Return  // "dummy" function - Internal Use

/*----------------------------------------------------------------------------------
ฑฑบClasse    ณLJCSitefDireto   บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em preparar e enviar as transacoes.        	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
----------------------------------------------------------------------------------*/
Class LJCSitefDireto From LJAAbstrataPBM

	Data oSitefPbm								  					//Objeto do tipo SitefPBM
	Data oDadosTran													//Objeto do tipo DadosSitefDireto que sera enviado ao site
	Data oServico													//Objeto do tipo SERVICOS
	
	Method SitefDiret()                           					//Metodo construtor
	Method EnvTrans(cDados, nTransacao, nOffSetCar)	 				//Metodo que ira enviar a transacao ao sitef	     
	Method PcRetSitef()												//Metodo que ira processar os dados retornados							  	
	Method SepServico() 											//Metodo que ira separar os servicos retornados    
	Method RetServico(cTpServico)									//Metodo que retorna um objeto do tipo AbstrataServico do array de servicos.
	Method FimTrans(lConfirma)										//Metodo que ira confirmar ou desfazer a transacao
	Method LeCartDir(cMensagem, cTrilha1, cTrilha2)					//Metodo que ira fazer a leitura direta do cartao
	Method ConsVDLink()
	Method ProdVDLink()
	Method VendaVDLink()
	Method CancVDLink()
	Method ConsPharmS()
	Method ConsFuncCr()
EndClass

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณSitefDiretบAutor  ณVendas Clientes  บ Data ณ  04/09/07      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCSitefDireto.				          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
---------------------------------------------------------------------------*/
Method SitefDiret(oClisitef) Class LJCSitefDireto

	::AbstratPBM()
	
	::oSitefPbm 	:= LJCSitefPBM():SitefPBM(oClisitef)
	::oDadosTran 	:= Nil
	::oServico		:= Nil

Return Nil

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณEnvTrans  บAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em enviar a transacao ao sitef.	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cDados)      - Dados da transacao TX.            บฑฑ
ฑฑบ          ณExpN1 (2 - nTransacao)  - Transacao a ser efetuada.         บฑฑ
ฑฑบ          ณExpN2 (3 - nOffSetCart) - Posicao onde comeca o numero do   บฑฑ
ฑฑบ			 ณ	     cartao no dados TX.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico													  บฑฑ
---------------------------------------------------------------------------*/
Method EnvTrans(cDados, nTransacao, nOffSetCar) Class LJCSitefDireto
	
	Local cDadosTX := ""								//Dados da transacao
	Local lRetorno := .F.								//Retorno da funcao
	
	//Estancia o objeto
	::oDadosTran := LJCDadosSitefDireto():DadosSitef()
	
	//Prepara os dados de envio
	cDadosTX += AllTrim(Str(::nIndTrans))
	cDadosTX += SEPARADOR
	cDadosTX += AllTrim(Str(nTransacao))
		
	If !Empty(cDados)
		cDadosTX += SEPARADOR
		cDadosTX += cDados
	EndIf
	
	//Atribui o dados da transacao ao objeto criado
	::oDadosTran:nRedeDest 		:= ::nRedeDest
	::oDadosTran:nFuncSitef 	:= FUNCSITEF
	::oDadosTran:nOffSetCar		:= nOffSetCar
	::oDadosTran:cDadosTx		:= cDadosTX
	::oDadosTran:nTaDadosTx		:= Len(cDadosTX)
	::oDadosTran:cCupomFisc		:= ::cNumCupom
	::oDadosTran:cDataFisc		:= ::cData
	::oDadosTran:cHorario		:= ::cHora
	::oDadosTran:cOperador		:= AllTrim(Str(::nCodOper))
	::oDadosTran:nTpTrans		:= 1
	::oDadosTran:dData			:= STOD(AllTrim(::cData))
	::oDadosTran:cHora			:= AllTrim(StrTran(::cHora,":"))
	::oDadosTran:nCupom			:= Val(AllTrim(::cNumCupom))
	
	//Envia a transacao
	::oSitefPbm:EnvTrans(@::oDadosTran)
	
	teste := ::oDadosTran:nRetorno
	//Verifica se a transacao foi efetuada
	//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
	If ::oDadosTran:nRetorno <= 0
		//"Problema de comunica็ใo com Sitef"
		MsgAlert(STR0001,"TEF")
	Else
		lRetorno := .T.	
	EndIf
				
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณPcRetSitefบAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os dados de retorno do sitef.   		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico													  บฑฑ
---------------------------------------------------------------------------*/
Method PcRetSitef() Class LJCSitefDireto
	
	Local lRetorno		:= .F.					//Variavel de retorno do metodo
	
	//Estanciando o objeto Servicos
	::oServico := LJCServico():Servico()
	
	//Processa os servicos retornados
	lRetorno := ::oServico:ProcServ(::oDadosTran:cDadosRx)
	
	If lRetorno
		//Separa os servicos
		::SepServico()
		
		//Verifica se a transacao foi efetuada com sucesso, senao, 
		//exibi a mensagem retornada no servico D
		If (::oDadosTran:nCodResp == 0)
			lRetorno := .T.		
		Else
			//Exibir mensagem do servico D
			MsgAlert(::oMensagem:cMensagem,"TEF")
			lRetorno := .F.	
		EndIf
		//Homologacao
		//MsgAlert(::oMensagem:cMensagem)
	Else
		MsgAlert(STR0002,"TEF") //"Problema ao processar servi็os"
		lRetorno := .F.
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSepServicoบAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em separar os servicos comuns retornados        บฑฑ
ฑฑบ			 ณdo sitef (I e D).						   		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SepServico() Class LJCSitefDireto
	Local nI := 0
	Local nTam := 0
	
	Local oServico := Nil					//Objeto que ira armazenar o servico
	
	//Separa o servico D
	oServico := ::RetServico("D") 
	
	If oServico != Nil
		::oMensagem:cMensagem := oServico:cMensagem
	EndIf
	
	//Separa o servico I
	oServico := ::RetServico("I") 
	
	If oServico != Nil
	    ::oComprova:aComprovan := oServico:aComprov
	EndIf
	
	//Separa o servico I
	oServico := ::RetServico("/") 
	
	If oServico != Nil .AND. ( nTam := Len(oServico:aComprov) ) > 0
		For nI := 1 to nTam
	    	aAdd( ::oComprova:aComprovan, oServico:aComprov[nI])
	    Next nI
	EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณRetServicoบAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em retornar um servico especifico.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cTpServico) - Tipo do servico solicitado.    	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetServico(cTpServico) Class LJCSitefDireto

	Local oServico := Nil          		//Objeto do tipo servico que sera retornado

	//Verifica se o servico existe
	If ::oServico:GetServs():Contains(cTpServico)
	    //Retorna o servico se encontrado
    	oServico := ::oServico:GetServs():ElementKey(cTpServico)
    EndIf
    
Return oServico

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณFimTrans  บAutor  ณVendas Clientes     บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em confirmar ou desfazer a transacao.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1 (1 - lConfirma)  - Se a transacao sera confirmada ou  บฑฑ
ฑฑบ			 ณ						   desfeita.						  บฑฑ
---------------------------------------------------------------------------*/
Method FimTrans(lConfirma) Class LJCSitefDireto
	
//Confirma ou desfaz a transacao
::oSitefPbm:FimTrans(lConfirma, ::cNumCupom, ::cData, ::cHora)
	
Return Nil

/*---------------------------------------------------------------------------
ฑฑบMetodo    ณLeCartDir บAutor  ณVendas Clientes     บ Data ณ  21/09/07   บฑฑ
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
---------------------------------------------------------------------------*/
Method LeCartDir(cMensagem, cTrilha1, cTrilha2) Class LJCSitefDireto
Local nRetorno := 0					//Retorno do metodo

//Faz a leitura direta do cartao
nRetorno := ::oSitefPbm:LeCartDir(cMensagem, @cTrilha1, @cTrilha2)
	
Return nRetorno

/*/{Protheus.doc} ConsVDLink
	Executa consulta do Vida Link
	@type  Metodo
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method ConsVDLink() Class LJCSitefDireto
Local lRet := .F.	//Retorno da funcao

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()

::oDadosTran:cCupomFisc		:= AllTrim(::cCupom)
::oDadosTran:cDataFisc		:= ::cData
::oDadosTran:cHorario		:= ::cHora
::oDadosTran:cOperador		:= AllTrim(::cOperador)
::oDadosTran:cCodAut		:= AllTrim(::cCodAut)
::oDadosTran:cCodProd		:= ::cCodProd
::oDadosTran:aVDLink		:= ::aVDLink

//Envia a transacao
::oSitefPbm:VDLinkCons(@::oDadosTran)

//Verifica se a transacao foi efetuada
//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
If ::oDadosTran:nRetorno <= 0	
	MsgAlert(STR0001,"TEF") //#"Problema de comunica็ใo com Sitef"
Else
	lRet := .T.	
EndIf

Return lRet

/*/{Protheus.doc} ProdVDLink
	Produto consulta VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method ProdVDLink() Class LJCSitefDireto
Local lRet := .T.	//Retorno da funcao

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()
::oDadosTran:aVDLink := ::aVDLink

//Envia a transacao
::oSitefPbm:VDLinkProd(@::oDadosTran)

Return lRet

/*/{Protheus.doc} VendaVDLink
	Venda Produto VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return lRet, l๓gico, retorno ok?
/*/
Method VendaVDLink() Class LJCSitefDireto
Local lRet := .F.	//Retorno da funcao

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()

::oDadosTran:cCupomFisc		:= AllTrim(::cCupom)
::oDadosTran:cDataFisc		:= ::cData
::oDadosTran:cHorario		:= ::cHora
::oDadosTran:cOperador		:= AllTrim(::cOperador)
::oDadosTran:cCodAut		:= AllTrim(::cCodAut)
::oDadosTran:aVDLink		:= ::aVDLink

//Envia a transacao
::oSitefPbm:VDLinkVenda(@::oDadosTran)

//Verifica se a transacao foi efetuada
//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
If ::oDadosTran:nRetorno <= 0	
	MsgAlert(STR0001,"TEF") //#"Problema de comunica็ใo com Sitef"
Else
	lRet := .T.	
EndIf

Return lRet

/*/{Protheus.doc} CancVDLink
	Cancelamento de Venda Vidalink
	@type  Class
	@author Julio.Nery
	@since 29/04/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method CancVDLink() Class LJCSitefDireto
Local lRet := .F.

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()

::oDadosTran:lCancTotal := ::lCancTotal
::oDadosTran:cCupomFisc	:= AllTrim(::cCupom)
::oDadosTran:cDataFisc	:= ::cData
::oDadosTran:cHorario	:= ::cHora
::oDadosTran:cOperador	:= AllTrim(::cOperador)
::oDadosTran:aVDLink	:= ::aVDLink

//Envia a transacao
::oSitefPbm:VDLinkCanc(@::oDadosTran)

//Verifica se a transacao foi efetuada
//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
If ::oDadosTran:nRetorno <= 0	
	MsgAlert(STR0001,"TEF") //#"Problema de comunica็ใo com Sitef"
Else
	lRet := .T.	
EndIf

Return lRet

/*/{Protheus.doc} ConsPharmS
	Executa consulta do PharmaSystem
	@type  Metodo
	@author Julio.Nery
	@since 26/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method ConsPharmS() Class LJCSitefDireto
Local lRet := .F.	//Retorno da funcao

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()

//Atribui o dados da transacao ao objeto criado
::oDadosTran:nFuncSitef 	:= ::nFuncao
::oDadosTran:cCupomFisc		:= ::cCupom
::oDadosTran:cDataFisc		:= ::cData
::oDadosTran:cHorario		:= ::cHora
::oDadosTran:cOperador		:= AllTrim(::cOperador)
::oDadosTran:aVDLink		:= ::aVDLink

//Envia a transacao
::oSitefPbm:PharmSCons(@::oDadosTran)

//Verifica se a transacao foi efetuada
//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
If ::oDadosTran:nRetorno <= 0
	//"Problema de comunica็ใo com Sitef"
	MsgAlert(STR0001,"TEF")
Else
	lRet := .T.	
EndIf

Return lRet

/*/{Protheus.doc} ConsFuncCr
	Executa consulta do Funcional Card
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method ConsFuncCr() Class LJCSitefDireto
Local lRet := .F.	//Retorno da funcao

//Estancia o objeto
::oDadosTran := LJCDadosSitefDireto():DadosSitef()

//Atribui o dados da transacao ao objeto criado
::oDadosTran:nFuncSitef 	:= ::nFuncao
::oDadosTran:cCupomFisc		:= ::cCupom
::oDadosTran:cDataFisc		:= ::cData
::oDadosTran:cHorario		:= ::cHora
::oDadosTran:cOperador		:= AllTrim(::cOperador)
::oDadosTran:aVDLink		:= ::aVDLink
::oDadosTran:nCupom			:= Val(::cCupom)

//Envia a transacao
::oSitefPbm:FuncCrCons(@::oDadosTran)

//Verifica se a transacao foi efetuada
//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
If ::oDadosTran:nRetorno <= 0
	//"Problema de comunica็ใo com Sitef"
	MsgAlert(STR0001,"TEF")
Else
	lRet := .T.
EndIf

Return lRet