#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1015.CH"
  
#DEFINE SEPARADOR Chr(0)				//Utilizado para separar os dados da mensagem
#DEFINE FUNCSITEF 240                  //Codigo da funcao sitef

User Function LOJA1015 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCSitefDireto   �Autor  �Vendas Clientes     � Data �  04/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em preparar e enviar as transacoes.        	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
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
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SitefDiret�Autor  �Vendas Clientes  � Data �  04/09/07      ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCSitefDireto.				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SitefDiret(oClisitef) Class LJCSitefDireto

	::AbstratPBM()
	
	::oSitefPbm 	:= LJCSitefPBM():SitefPBM(oClisitef)
	::oDadosTran 	:= Nil
	::oServico		:= Nil

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnvTrans  �Autor  �Vendas Clientes     � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar a transacao ao sitef.	              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)      - Dados da transacao TX.            ���
���          �ExpN1 (2 - nTransacao)  - Transacao a ser efetuada.         ���
���          �ExpN2 (3 - nOffSetCart) - Posicao onde comeca o numero do   ���
���			 �	     cartao no dados TX.                                  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
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
	
	//Envia a transacao
	::oSitefPbm:EnvTrans(@::oDadosTran)
	
	teste := ::oDadosTran:nRetorno
	//Verifica se a transacao foi efetuada
	//Se menor ou igual a zero, ocorreu algum problema de comunicacao com o sitef
	If ::oDadosTran:nRetorno <= 0
		//"Problema de comunica��o com Sitef"
		MsgAlert(STR0001)
	Else
		lRetorno := .T.	
	EndIf
				
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PcRetSitef�Autor  �Vendas Clientes     � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa os dados de retorno do sitef.   		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
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
			MsgAlert(::oMensagem:cMensagem)
			lRetorno := .F.	
		EndIf
		//Homologacao
		//MsgAlert(::oMensagem:cMensagem)
	Else
		MsgAlert(STR0002) //"Problema ao processar servi�os"
		lRetorno := .F.
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SepServico�Autor  �Vendas Clientes     � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em separar os servicos comuns retornados        ���
���			 �do sitef (I e D).						   		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �RetServico�Autor  �Vendas Clientes     � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar um servico especifico.              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTpServico) - Tipo do servico solicitado.    	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RetServico(cTpServico) Class LJCSitefDireto

	Local oServico := Nil          		//Objeto do tipo servico que sera retornado

	//Verifica se o servico existe
	If ::oServico:GetServs():Contains(cTpServico)
	    //Retorna o servico se encontrado
    	oServico := ::oServico:GetServs():ElementKey(cTpServico)
    EndIf
    
Return oServico

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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FimTrans(lConfirma) Class LJCSitefDireto
	
	//Confirma ou desfaz a transacao
	::oSitefPbm:FimTrans(lConfirma, ::cNumCupom, ::cData, ::cHora)
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LeCartDir �Autor  �Vendas Clientes     � Data �  21/09/07   ���
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
Method LeCartDir(cMensagem, cTrilha1, cTrilha2) Class LJCSitefDireto 
	
	Local nRetorno := 0					//Retorno do metodo
	
	//Faz a leitura direta do cartao
	nRetorno := ::oSitefPbm:LeCartDir(cMensagem, @cTrilha1, @cTrilha2)
	
Return nRetorno
