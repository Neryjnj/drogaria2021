#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1007.CH"
  
//������������������
//�Tipo de operacao�
//������������������
#DEFINE	VENDA 	1
#DEFINE CANCEL 	2

User Function LOJA1007 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCPBM    �Autor  �Vendas Clientes     � Data �  03/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria a classe LJCPBM                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class LJCPBM

	Data oPbm														// Obejeto PBM
	Data oSlz														// Objeto do arquivo
	Data oTelaPBM													// Objeto tela
	Data nTpOpera													//Tipo da operacao 1-Venda 2-Cancelamento
	
	Method PBM()													// Metodo construtor
	Method IniciaVend( cCupom, cOperador, cTpDoc )					// Inica a venda com o PBM
	Method VendProd( cCodBarra, nQtde, nPrUnit, nPercDesc, ;		// Realiza a venda do produto
					 lItemPbm, lPrioPbm )
	Method CancProd( cCodBarra, nQtde)								// Cancela o produto da PBM
	Method FinalVend(cDoc, cSerie, cKeyDoc)												// Finaliza a venda
	Method BuscaRel()												// Busca relatoria para impress�o
	Method BuscaSubs()												// Verifica se tem subsidio
	Method ConfProd( cCodBarra, nQtde, lOk)			// Confirma os produtos vendidos
	Method ConfVend(lConfirma)										// Confirma a venda na PBM
	Method CancPBM()												//Cancela a transacao total da PBM		
	Method SelecPbm(cNomePBM)												//Metodo que ira selecionar a PBM
	Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador)
	
	//Metodos internos
	Method CarregaCBO()												// Carrega as informacoes do arquivo SLZ
	Method ExecutaPBM(cCupom, cOperador)							// Retorna a PBM selecionada na tela
	Method GetTpOpera()												//Retorna o tipo de operacao selecionado
	
EndClass
        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PBM       �Autor  �Vendas Clientes     � Data �  03/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construtor do Classe LJCPBM                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PBM() Class LJCPBM

	::oPbm 		:= Nil			// Objeto a ser criado
	::oSlz    	:= Nil			// Inicializacao do Objeto
	::oTelaPBM	:= Nil			// Objeto da Tela
	::nTpOpera	:= 0
	
Return Self


/*���������������������������������������������������������������������������
���Programa  �IniciaVend�Autor  �Microsiga           � Data �  03/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicia o metodo do processo de venda                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametro � 1.ExpC1 - Numero do cupom Fiscal                           ���
�������������������������������������������������������������������������͹��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
���������������������������������������������������������������������������*/
Method IniciaVend( cCupom, cOperador, cTpDoc ) Class LJCPBM
	
Local lRet 		:= .F.		//Retorno do Metodo

lRet := ::oPbm:IniciaVend(cCupom, cOperador, cTpDoc)

//Seta o tipo de operacao como venda
::nTpOpera := VENDA
	
Return lRet                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VendProd  �Autor  �Vendas Clientes        � Data �  09/04/07���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a venda do Produto                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
���          � 3.ExpN2 - Preco do produto                                 ���
���          � 4.ExpN3 - Percentual de desconto do produto                ���
���          � 5.ExpL1 - Se o item foi enviado para pbm                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VendProd( cCodBarra, nQtde, nPrUnit, nPercDesc, ;
				 lItemPbm, lPrioPbm ) Class LJCPBM
	
	Local lRet := .T.		// Retorno da funcao
    
	lRet := ::oPbm:VendProd( cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm, lPrioPbm )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancProd  �Autor  �Vendas Clientes     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza o cancelamento dos produtos vendidos no PBM        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 (cCodBarra)- Codigo de barras do produto           ���
���          � 2.ExpN1 (nQtde)	- Quantidade do produto                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancProd( cCodBarra, nQtde ) Class LJCPBM

	Local lRet	 := .T.		//Retorno da funcao
	
	lRet := ::oPbm:CancProd( cCodBarra, nQtde )

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FinalVend �Autor  �Vendas Clientes     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Finaliza a venda no PBM                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCPBM
	
	Local lRet := .T.		//Retorno da funcao
	
	lRet := ::oPbm:FinalVend(cDoc, cSerie, cKeyDoc)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscaRel  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o relatorio a ser impresso, na finaliza��o da ven- ���
���          � da no processo da PBM                                      ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaRel() Class LJCPBM
	
	Local aRet := {}		// Retono da funcao
	
	aRet := ::oPbm:BuscaRel()

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscaSubs �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o subsidio, caso haja                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaSubs() Class LJCPBM

	Local nRetVal := 0		// Retorna o valor do subisidio, caso haja
	
	nRetVal := ::oPbm:BuscaSubs()
	
Return(nRetVal)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfProd  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Confirma os produtos vendidos na PBM                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfProd( cCodBarra, nQtde, lOk ) Class LJCPBM

	Local lRet := .T.		// Retorno da funcao
	
	lRet := ::oPbm:ConfProd(cCodBarra, nQtde, lOk)
	
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfVend  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Confirma a venda na PBM                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA/FRONTLOJA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfVend(lConfirma) Class LJCPBM
	
	::oPbm:ConfVend(lConfirma)

Return Nil




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CARREGACBO�Autor  �Vendas Clientes     � Data �  17/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega a combo com as informacoes do arquivo SLZ          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregaCBO() Class LJCPBM
	
	Local nI 			:= 0		// Variavel do FOR
	Local aComboPbm     := {}		// Array que contera todas as PBMS
	
	::oSlz := LJCCarregaSLZ():CarregaSLZ()
	::oSlz:LeArqSLZ()
	
	For nI := 1 To Len( ::oSlz:aDadosSLZ )
		
		AADD( aComboPbm, ::oSlz:aDadosSLZ[nI]:cNome )
		
	Next

Return(aComboPbm)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExecutaPBM�Autor  �Microsiga           � Data �  09/17/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a PBM selecionada na tela.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ExecutaPBM(cCupom, cOperador) Class LJCPBM
	
	Local cSelec	:= ""		// PBM Selecionada
	Local nPos		:= 0		// Posicao do array
	Local cFuncao	:= ""		// Funcao a ser executada
	Local lRet		:= .F.		// Retorno da funcao
	
	::oTelaPBM:Show()
	
	If ::oTelaPBM:lCancelado == .F.
		cSelec 	:= ::oTelaPBM:cRetSelect
        nPos 	:= aScan( ::oSlz:aDadosSLZ, { |x| Alltrim(x:cNome) == Alltrim(cSelec) }	)
        If nPos > 0
	        cFuncao := ::oSlz:aDadosSLZ[nPos]:cFuncao
	        ::oPbm 	:= &(cFuncao)
	        lRet := .T.
		EndIf
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CancPBM   �Autor  �Vendas Clientes     � Data �  21/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cancela a transacao da PBM.                                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancPBM() Class LJCPBM

	Local lRetorno := .F.							//Variavel de retorno do metodo 	
	
	lRetorno := ::oPbm:CancPBM()
	
	//Seta o tipo de operacao como cancelamento
    ::nTpOpera := CANCEL

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SelecPbm  �Autor  �Vendas Clientes     � Data �  21/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Seleciona a PBM.                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SelecPbm(cNomePBM) Class LJCPBM

	Local lRet 		:= .F.		//Retorno do Metodo
	Local aComboPbm	:= {}		//Combo da PBM
	
	aComboPbm := ::CarregaCBO()
	
	If Len( aComboPbm ) > 0
	
		::oTelaPBM := LJCTelaSelecao():TelaSelec( aComboPbm, STR0003, STR0002  )
		
		lRet := ::ExecutaPBM()
		
	EndIf

Return lRet

/*���������������������������������������������������������������������������
���Metodo    �GetTpOpera�Autor  �Vendas Clientes     � Data �  26/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o tipo de operacao selecionado.     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico                                                    ���
���������������������������������������������������������������������������*/
Method GetTpOpera() Class LJCPBM
Return ::nTpOpera

/*/{Protheus.doc} VDLinkCons
	Executa consulta do Vida Link
	@type  Metodo
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description

/*/
Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador)

Return lRet