#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1024.CH"
  
//���������������������������Ŀ
//�Tipo de transacoes enviadas�
//�����������������������������
#DEFINE OPERADORAS 		1					//Carga de tabela de operadoras
#DEFINE TELACOMPL 		2					//Carga de tela complementar de operadoras
#DEFINE PREAUTORI 		3                   //Recuperacao da pre-autorizacao
#DEFINE CONSPROD  		4                   //Consulta produto
#DEFINE AUTPROD   		5                   //Autorizacao com produto
#DEFINE CANCPROD  		6					//Cancelamento da autorizacao com produto
#DEFINE ABREVENDA 		7					//Abertura da venda

//���������������������������������Ŀ
//�Meios para buscar pre-autorizacao�
//�����������������������������������
#DEFINE CARTAOMAG		1					//Cartao magnetico
#DEFINE CARTAO			2                   //Cartao digitado
#DEFINE AUTORIZACAO		3					//Numero da autorizacao

//���������������������������������Ŀ
//�Separadores						�
//�����������������������������������
#DEFINE SEPARADOR Chr(0)					//Utilizado para separar os dados da mensagem
#DEFINE SEPTRILHA Chr(4)					//Utilizado para separar as trilhas do cartao

//���������������������������������Ŀ
//�Tipos de servicoX				�
//�����������������������������������
#DEFINE TELCOMPL  		"c"					//Tipo de dados retornado no servicoX da tela complementar
#DEFINE OPERADORA 		"o"					//Tipo de dados retornado no servicoX da operadora
#DEFINE PRODAUT   		"p"					//Tipo de dados retornado no servicoX da pre-autorizacao
#DEFINE TELCOMPLPRO		"t"					//Tipo de dados retornado no servicoX da tela complementar produto

//���������������������������������Ŀ
//�Status do produto				�
//�����������������������������������
#DEFINE OK_TRN 			0                   //Ok, solicitacao atendida
#DEFINE OK_ATENDIMENTO	2					//Ok, produto aprovado com preco atendimento
#DEFINE PEND 			21					//PEND, administradora solicira dados complementares do produto 
#DEFINE NEGADA			41					//NEGADA, solicitacao recusada por dados invalidos

User Function LOJA1024 ; Return  			// "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTrnCentre     �Autor  �Vendas Clientes     � Data �  06/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel por tratar o processo PBM TrnCentre.   		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTrnCentre From LJCSitefDireto
	
	//Variaveis internas
	Data oOperadors													//Objeto com as operadoras
	Data oTelCompl													//Objeto com as telas complementares
	Data cNumCartao													//Numero do cartao
	Data cTrilha1													//Trilha1 do cartao
	Data cTrilha2                                                   //Trilha2 do cartao
	Data nTpAutori	   												//Tipo da autorizacao selecionada
	Data oXProdVend													//Objeto com os produtos vendidos
	Data cDataCanc													//Data da transacao para o cancelamento
	Data lTemAutori													//Se possui ou nao pre-autorizacao
	Data oTelComPro													//Objeto com a tela complementar do produto
		
	//Metodos externos da interface	
	Method TrnCentre()												//Metodo construtor
	Method IniciaVend(cCupom, cOperador, cTpDoc)					//Inica a venda com o PBM
	Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, ;			//Realiza a venda do produto
					lItemPbm)
	Method CancProd(cCodBarra, nQtde)								//Cancela o produto da PBM
	Method FinalVend()												//Finaliza a venda
	Method BuscaRel()												//Busca relatorio para impressao
	Method BuscaSubs()												//Busca valor do subsidio
	Method ConfProd(cCodBarra, nQtde, lOk)							//Confirma o produto vendido
	Method ConfVend(lConfirma)										//Confirma a venda na PBM
	Method CancPBM()												//Cancela a transacao total da PBM
		
	//Metodos internos
	Method TrataOpera()												//Metodo que ira carregar os dados da operadora
	Method TraTelComp()												//Metodo que ira carregar os dados da tela complementar
	Method ExibTelSel(aDados, cTitulo, cLabel)						//Metodo que ira exibir uma tela para selecao
	Method ArrayOpera()												//Metodo que ira criar um array com as operadoras
	Method TrataAutor()												//Metodo que ira solicitar o numero da autorizacao
	Method TratCartao()												//Metodo que ira solicitar o numero do cartao
	Method TratCarMag()												//Metodo que ira solicitar para passar o cartao no pinpad 
	Method SelTpAutor()												//Metodo que ira solicitar como sera feito a recuperacao da pre-autorizacao
	Method BuscPreAut()												//Metodo que ira buscar os produtos da pre-autorizacao
	Method PrepPreAut(nIndCont, cNSU)								//Metodo que ira montar os dados para recuperacao da pre-autorizacao
	Method BusDadTela()												//Metodo que ira buscar os dados capturados da tela complementar
	Method RetTxPad(nIndCont)										//Metodo que ira retornar o que vai de padrao
	Method PrepAutProd(nIndCont, oProduto, cQtdeProd) 				//Metodo que ira montar os dados da autorizacao com produto
	Method CfCancProd(cCodBarra, nQtde)								//Metodo que ira confirmar o cancelamento do item
	Method SlCancDat()												//Metodo que ira solicitar a data que a autorizacao foi efetuada
	Method SlCancCup()												//Metodo que ira solicitar o numero do cupom fiscal da autorizacao a ser cancelada
	Method PrepAutCanc()											//Metodo que ira montar os dados para o cancelamento da transacao
	Method TrataServ(oServEsp)										//Metodo que ira tratar os servicos especificos da TrnCentre
	Method AbreVenda()												//Metodo que ira efetuar a abertura da venda quando nao houver pre-autorizacao
	Method SlTemAut()												//Metodo que ira solicitar se tem ou nao pre-autorizacao
	Method VendComAut(cCodBarra, nQtde, nPrUnit, nPercDesc, ;
					  lItemPbm)										//Venda com pre-autorizacao
	Method VendSemAut(cCodBarra, nQtde, nPrUnit, nPercDesc, ;
					  lItemPbm)										//Venda sem pre-autorizacao
	Method DadTelaProd()											//Metodo que ira buscar os dados capturados da tela complementar do produto
	Method CarTelProd()												//Metodo que ira solicitar os dados da tela complementar de produto 	
	Method TratTelProd()											//Carrega o objeto com os dados da tela do produto
	
EndClass
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrnCentre �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTrnCentre.                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros� 											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TrnCentre(oClisitef) Class LJCTrnCentre
    
	//Executa o construtor da classe pai
	::SitefDireto(oClisitef)
	
	::oOperadors	:= Nil
	::oTelCompl		:= Nil
	::cNumCartao	:= ""
	::cTrilha1		:= Space(200)
	::cTrilha2		:= Space(200)
	::nTpAutori 	:= 0
	::oXProdVend	:= Nil
	::cDataCanc		:= ""
	::nRedeDest		:= 99
	::nIndTrans		:= 41
	::lTemAutori	:= .F.
	::oTelComPro	:= Nil
	::oComprova:aComprovan := {}
	
Return Self

/*---------------------------------------------------------------------------
���Metodo    �IniciaVend�Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicia o metodo do processo de venda.                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametro �ExpC1 (1 - cCupom) 	- Numero do cupom Fiscal.             ���
���			 �ExpC2 (2 - cOperador) - Codigo do operador.	              ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
---------------------------------------------------------------------------*/
Method IniciaVend(cCupom, cOperador, cTpDoc) Class LJCTrnCentre
	
	Local lRetorno 	:= .F.		//Retorno do Metodo
		
	//Inicializando variaveis da classe AbstrataPBM
	::cNumCupom     := cCupom
	::nCodOper      := val(cOperador)
	
	//Carrega as operadoras
	lRetorno := ::TrataOpera()
	
	//Carrega dados tela complementar
	If lRetorno
		lRetorno := ::TraTelComp()
	EndIf
	
	//Verifica se tem ou nao pre-autorizacao
	If lRetorno
		lRetorno := ::SlTemAut()
	EndIf
	
	//Seleciona como sera feita a recuperacao da pre autorizacao
	If lRetorno
		lRetorno := ::SelTpAutor()
	EndIf

	If lRetorno
		Do Case
			Case ::nTpAutori == CARTAOMAG
				//Solicita cartao magnetico
				lRetorno := ::TratCarMag()
				
			Case ::nTpAutori == CARTAO
				//Solicita o numero do cartao
				lRetorno := ::TratCartao()	
					
			Case ::nTpAutori == AUTORIZACAO
		  		//Solicita o numero da autorizacao
				lRetorno := ::TrataAutor()	
		EndCase
	EndIf

	If lRetorno
	    If ::lTemAutori
    		//Carrega os produtos da pre-autorizacao
	    	lRetorno := ::BuscPreAut()	
	    Else
	    	//Efetua a abertura da venda
	    	lRetorno := ::AbreVenda()
	    Endif
	EndIf
					
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �VendProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a venda do Produto.                                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
���          �ExpN2	(3 - nPrUnit)	- Preco do produto.                   ���
���          �ExpN3 (4 - nPercDesc) - Percentual de desconto do produto.  ���
���          �ExpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, ;
			    lItemPbm) Class LJCTrnCentre
	
	Local lRetorno 	:= .F.		//Variavel de retorno da funcao
	
	cCodBarra := AllTrim(cCodBarra)
	
	If ::lTemAutori
		//Venda com pre-autorizacao
		lRetorno := ::VendComAut(cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm)
	Else
	    //Venda sem pre-autorizacao
	    lRetorno := ::VendSemAut(cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm)
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CancProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza o cancelamento do produto vendido no PBM.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancProd(cCodBarra, nQtde) Class LJCTrnCentre

	Local lRetorno 		:= .F.		//Variavel de retorno da funcao
	Local oProdEnv 		:= Nil		//Objeto com os dados do produto que foi enviado
	Local oProdCanc		:= Nil		//Objeto com o produto a ser cancelado
	
	cCodBarra := AllTrim(cCodBarra)
	cCodBarra := Padl(cCodBarra, 13, "0")	
					
	//Busca o produto dos itens enviados
	oProdEnv := ::oProdVend:oProdutos:ElementKey(cCodBarra)
	//Cria um objeto com os dados do produto a ser cancelado
	oProdCanc := LJCProdutoTrnCentre():ProTrnCent()
			
	//Atribui os dados para o produto a ser cancelado
    oProdCanc:cCodProdut	:= oProdEnv:cCodProdut
    oProdCanc:cTpEmbalag	:= oProdEnv:cTpEmbalag
    oProdCanc:nQtdeComp		:= nQtde * -1
    oProdCanc:nPrcBruto		:= oProdEnv:nPrcBruto
    oProdCanc:nPrcLiqui		:= oProdEnv:nPrcLiqui
    oProdCanc:nVlRecLoja	:= oProdEnv:nVlRecLoja
    oProdCanc:nDescConce	:= 0

	//Envia a transacao de cancelamento de produto
	lRetorno := ::EnvTrans(::PrepAutProd(1, oProdCanc, "1"), AUTPROD, 11)
	
	If lRetorno
		//Processa o retorno da transacao
		lRetorno := ::PcRetSitef()
	EndIf	
				
	If lRetorno
		//Confirma o cancelamento do produto
		::CfCancProd(cCodBarra, nQtde)
	Else
		//Problemas ao processar servicos
		lRetorno := .F.		
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �FinalVend �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Finaliza a venda no PBM.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FinalVend() Class LJCTrnCentre
	
	Local lRetorno 			:= .T.		//Retorno da funcao
	Local oProdFinal		:= Nil		//Objeto com o produto para finalizacao
	
	//Verifica se algum produto foi vendido
	If ::oProdVend:PrVendidos()

		//Cria um objeto produto para finalizacao
		oProdFinal := LJCProdutoTrnCentre():ProTrnCent()
				
		//Atribui os dados ao produto para finalizar da transacao
	    oProdFinal:cTpEmbalag	:= "U"
	    
		//Desfaz o objeto de tela complementar, porque nao e preciso enviar na finalizacao
		::oTelCompl := Nil
		
		//Envia a transacao de finalizacao
		lRetorno := ::EnvTrans(::PrepAutProd(0, oProdFinal, "0"), AUTPROD, 11)
		
		If lRetorno
			//Processa o retorno da transacao
			lRetorno := ::PcRetSitef()
		EndIf
	
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscaRel  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o relatorio a ser impresso, na finalizacao da ven- ���
���          � da no processo da PBM.                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���
�������������������������������������������������������������������������͹��
���Retorno   �Array                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaRel() Class LJCTrnCentre
Return ::oComprova:aComprovan

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscaSubs �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca o valor do subsidio.								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaSubs() Class LJCTrnCentre

	Local nRetVal := 0		//Retorna o valor do subisidio
	
	//Busca o valor do subsidio nos produtos vendidos
	nRetVal := ::oProdVend:BusVlSub()		
	
Return(nRetVal)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirma o produto vendido.								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
���          �ExpL1	(3 - lOk)		- Se o produto foi vendido ou nao.    ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfProd(cCodBarra, nQtde, lOk) Class LJCTrnCentre

	Local lRetorno 		:= .F.		//Retorno da funcao
	
	cCodBarra := AllTrim(cCodBarra)
	
	//Produto nao foi vendido
	If !lOk
		//Cancela o produto
		lRetorno := ::CancProd(cCodBarra, nQtde)    
	Else
		lRetorno := .T.
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfVend  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirma a venda PBM.     								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpL1 (1 - lConfirma) - Indica se a transacao sera confirma-���
���			 �da ou desfeita.       							          ���
�������������������������������������������������������������������������͹��
���Retorno   �		                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfVend(lConfirma) Class LJCTrnCentre
	
	//Confirma ou desfaz a venda
	::FimTrans(lConfirma)
	
	//Apaga o arquivo de controle
	::ApagArqTef()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrataOpera�Autor  �Vendas Clientes     � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel por carregar os dados das operadoras.			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TrataOpera() Class LJCTrnCentre

	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cOpera	:= ""					//Operadora selecionada
	Local oServicos	:= Nil					//Objeto com os servicos retornados
		
	//Envia a transacao para carregar as operadoras
	lRetorno := ::EnvTrans("", OPERADORAS, 0)
	
	If lRetorno
		//Processa o retorno da transacao
		lRetorno := ::PcRetSitef()
	EndIf	
		
	If lRetorno
		//Trata o servico retornado	
		oServicos := ::TrataServ()
	    
	    //Valida se retornou o servico
		If oServicos:Count() > 0
			::oOperadors := oServicos:Elements(1):BuscarOper()
		Else
		   	MsgAlert(STR0013)//"Carga da tabela de operadoras n�o retornada no servicoX"
			lRetorno := .F.
		EndIf
	EndIF
		
	If lRetorno
	    //Exibi a tela para selecao
	    cOpera := ::ExibTelSel(::ArrayOpera(), STR0001, STR0002) //"Operadora";"Selecione a operadora"
	    
	    //Valida a operadora selecionada
	    ::oOperadors:ValOper(cOpera) 
	    
		//Verifica se alguma operadora foi selecionada
		If !Empty(::oOperadors:cOpSelec)
			lRetorno := .T.
		Else
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TraTelComp�Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel por carregar os dados das telas complementares. ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													          ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TraTelComp() Class LJCTrnCentre

	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local nCount	:= 0					//Variavel de controle contador
	Local oRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela
	Local oServicos	:= Nil					//Objeto com os servicos retornados
	
	//Envia a transacao para carregar as telas complementares
	lRetorno := ::EnvTrans(::oOperadors:cOpSelec, TELACOMPL, 0)
	
	If lRetorno
		//Processa o retorno da transacao
		lRetorno := ::PcRetSitef()
	EndIf	

	If lRetorno 
		//Trata o servico retornado	
		oServicos := ::TrataServ()
	    
		//Valida se retornou o servico
		If oServicos:Count() > 0
			::oTelCompl := oServicos:Elements(1):BusTelComp()
		Else
			lRetorno := .F.
			MsgAlert(STR0012)//"Carga da tela complementar n�o retornada no servicoX"
		EndIf
	ElseIf ::oDadosTran:nCodResp == 255
		//255 - Significa que nao possui tela complementar	
		lRetorno := .T.	
	EndIf
		
	//So vai capturar os dados se existir tela complementar
	If lRetorno .AND. ::oTelCompl != Nil
		//Faz um for para capturar todos os campos da tela
		For nCount := 1 To ::oTelCompl:Count()
			 //"Tela Complementar" 			
			lRetorno := ::CapDadTela(STR0003, ;
									 ::oTelCompl:Elements(nCount):cTipoCampo, ;
									 ::oTelCompl:Elements(nCount):nMinimo, ;
									 ::oTelCompl:Elements(nCount):nMaximo, ;
									 ::oTelCompl:Elements(nCount):cCampo, ;
									 @oRetorno)

			//Atribui ao objeto o conteudo digitado
			If lRetorno
				::oTelCompl:Elements(nCount):oValor := oRetorno
			Else
				Exit
			EndIf
		Next
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ExibTelSel�Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em exibir uma tela para selecao.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 (1 - aDados)  - Array com os dados da tela.	          ���
���          �ExpC1 (2 - cTitulo) - Descricao do titulo da tela.		  ���
���          �ExpC2 (3 - cLabel)  - Descricao do label da tela.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ExibTelSel(aDados, cTitulo, cLabel) Class LJCTrnCentre

	Local oTela										//Objeto da tela
	
	//Estancia o objeto da tela
	oTela := LJCTelaSelecao():TelaSelec(aDados, cTitulo, cLabel)	
	
	//Exibi a tela
	oTela:Show()
	
Return oTela:cRetSelect //Retorna o conteudo selecionado

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ArrayOpera�Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar um array das operadoras.               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Array                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ArrayOpera() Class LJCTrnCentre 

	Local aDadosOper	:= {}		//Array de retorno do metodo
	Local nCount 		:= 0        //Variavel de controle contator 
	
	//Cria um array com o nome da operadoras
	For nCount := 1 to ::oOperadors:Count()
		AADD(aDadosOper, ::oOperadors:Elements(nCount):cNomeOpera)	
	Next
		
Return aDadosOper

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TrataAutor�Autor  �Vendas Clientes     � Data �  14/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar o numero da autorizacao.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TrataAutor() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela
	
	//Busca o numero da autorizacao
	lRetorno := ::CapDadTela(STR0004, "N", 1, 12, STR0005, @cRetorno)//"Autoriza��o";"N�mero da autoriza��o"
		
	//Atribui o conteudo digitado
	If lRetorno
		::nNumAutori := Val(cRetorno)
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratCartao�Autor  �Vendas Clientes     � Data �  14/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar o numero do cartao.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratCartao() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cRetorno  := 0					//Retorno do conteudo digitado para o campo da tela
	
	//Busca o numero do cartao
	lRetorno := ::CapDadTela(STR0006, "N", 1, 17, STR0007, @cRetorno)//"Cart�o";"N�mero do cart�o"
		
	//Atribui ao objeto o conteudo digitado
	If lRetorno
		::cNumCartao := cRetorno
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratCarMag�Autor  �Vendas Clientes     � Data �  14/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar que o cartao seja passado no pinpad���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratCarMag() Class LJCTrnCentre

	Local lRetorno 	:= .T.					//Variavel de retorno da funcao
	Local nRetorno	:= 0					//Variavel de retorno do metodo LeCartDir

	nRetorno := ::LeCartDir(STR0015, @::cTrilha1, @::cTrilha2)		//"Passe o Cartao"    
    
	If nRetorno <> 0
		lRetorno := .F.
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SelTpAutor�Autor  �Vendas Clientes     � Data �  17/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar de que forma sera feito a recupera-���
���			 �cao da pre-autorizacao                                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SelTpAutor() Class LJCTrnCentre

	Local lRetorno 	:= .T.					//Variavel de retorno da funcao
   	Local cRetorno  := ""					//Variavel com o retorno da selecao
	Local aDados	:= {}					//Array com os a serem exibidos na combo

	//So ira exibir se tiver autorizacao
	If ::lTemAutori
		AADD(aDados, "AUTORIZACAO")
	EndIf
	
	//Criando array com os dados da combo
	AADD(aDados, "CARTAO")
	AADD(aDados, "CARTAO MAGNETICO")
	
	//Exibi a tela de selecao
	cRetorno := ::ExibTelSel(aDados, STR0008, STR0009) //"Tipo autoriza��o";"Selecione uma op��o"
    
	//Valida o conteudo selecionado
	Do Case
		Case cRetorno == "CARTAO MAGNETICO"
			::nTpAutori := CARTAOMAG
				
		Case cRetorno == "CARTAO"
			::nTpAutori := CARTAO				

		Case cRetorno == "AUTORIZACAO"
			::nTpAutori := AUTORIZACAO					
			
		OtherWise
			lRetorno := .F.
	EndCase

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscPreAut�Autor  �Vendas Clientes     � Data �  17/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em buscar os produtos da pre-autorizacao.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscPreAut() Class LJCTrnCentre

	Local lRetorno 	:= .T.					//Variavel de retorno da funcao
	Local oXProdTrn	:= Nil					//Objeto servicoX dos produtos trn-centre		
	Local nIndCont  := 0					//Indicardor de continuacao do produto quando houver mais de 12 produtos
	Local cNSU		:= ""					//NSU retornado quando houver mais de 12 produtos
	Local oServicoN := Nil					//Objeto do servicoN retornado.
	Local lBuscaPre := .T.					//Variavel de controle do while
	Local oServicos	:= Nil					//Objeto com os servicos retornados
	
	While lBuscaPre
	
		//Envia a transacao para carregar os produtos da pre-autorizacao
		lRetorno := ::EnvTrans(::PrepPreAut(nIndCont, cNSU), PREAUTORI, 11)
		
		If lRetorno
			//Processa o retorno da transacao
			lRetorno := ::PcRetSitef()
		EndIf	
			
		If lRetorno
			//Trata o servico retornado	
			oServicos := ::TrataServ(oXProdTrn)

		    //Valida se retornou o servico
			If oServicos:Count() > 0
				//Busca o servico
				oXProdTrn := oServicos:Elements(1)
				
				nIndCont := oXProdTrn:nIndContin
				//Busca o Nsu se houver mais de 12 produtos, ou seja, indicador de continuacao maior que zero
				If nIndCont > 0
					//Busca o servicoN retornado	
					oServicoN := ::RetServico("N")
					//Valida se retornou servicoN
					If oServicoN != Nil
						cNSU := oServicoN:cNSU
					Else
						MsgAlert(STR0011,"TRNCentre") //"NSU da consulta inicial n�o retornado no servicoN"
						lRetorno := .F.	
						lBuscaPre := .F.
					EndIf
				Else
					//Atribui ao objeto de produtos autorizados os produtos da pre-autorizacao
					::oProdAutor:oProdutos := oXProdTrn:BuscaProd()
					//Nao possui continuacao de produto
					lBuscaPre := .F.					
				EndIf 
			Else
				//ServicoX de produto nao retornado
				MsgAlert(STR0010,"TRNCentre") //"Lista de produtos TRN-CENTRE n�o retornada no servicoX"			
				lRetorno := .F.
				lBuscaPre := .F.
			EndIf
		Else
			//Problemas ao processar servicos
			lRetorno := .F.		
			lBuscaPre := .F.
		EndIf
	End

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PrepPreAut�Autor  �Vendas Clientes     � Data �  17/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em preparar os dados para recuperacao da pre-   ���
���			 �autorizacao.											      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nIndCont) - Indicador de continuacao de produto. ���
���			 �ExpC1 (2 - cNSU) 	   - Numero do NSU. 					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PrepPreAut(nIndCont, cNSU) Class LJCTrnCentre

	Local cRetorno := "" 				//Variavel de retorno do metodo
		
	//Monta os dadosTx padrao das transacoes
	cRetorno := ::RetTxPad(nIndCont)
	
	//Nsu da transacao inicial, somente se o indicador de continuacao for maior que zero
	If nIndCont > 0
		cRetorno += "UNSU:" + cNSU
		cRetorno += SEPARADOR
	EndIf

Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BusDadTela�Autor  �Vendas Clientes     � Data �  17/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em formatar os dados da tela complementar que   ���
���			 �foi capturado.										      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �String                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BusDadTela() Class LJCTrnCentre
	
	Local cRetorno 	:= "" 				//Variavel de retorno do metodo
	Local nCount	:= 0				//Variavel de controle contador
		
	//Concatena os dados da tela complementar no seguinte formato:
	//LLyyy..yyLLyyy..yy, onde LL(quantidade de caracteres capturados) e yyy..yy(sao os dados capturados)
	If ::oTelCompl != Nil
		For nCount :=1 to ::oTelCompl:Count()
	    	If ValType(::oTelCompl:Elements(nCount):oValor) == "N"
		    	cRetorno += StrZero(Len(AllTrim(Str(::oTelCompl:Elements(nCount):oValor))),2) + AllTrim(Str(::oTelCompl:Elements(nCount):oValor)) 		
	    	ElseIf ValType(::oTelCompl:Elements(nCount):oValor) == "C"
	    		cRetorno += StrZero(Len(AllTrim(::oTelCompl:Elements(nCount):oValor)),2) + AllTrim(::oTelCompl:Elements(nCount):oValor) 		
	    	EndIf
		Next
	EndIf

	cRetorno += SEPARADOR
	
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �RetTxPad  �Autor  �Vendas Clientes     � Data �  18/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os dadosTx padrao das transacoes.   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nIndCont) - Indicador de continuacao da transacao���
�������������������������������������������������������������������������͹��
���Retorno   �String                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RetTxPad(nIndCont) Class LJCTrnCentre

	Local cRetorno 	:= "" 				//Variavel de retorno do metodo
	
	//Codigo da operadora
	cRetorno += ::oOperadors:cOpSelec
	cRetorno += SEPARADOR
	
	//Forma da entrada do cartao	
	cRetorno += AllTrim(Str(::nTpAutori))
	cRetorno += SEPARADOR
	
	//Numero cartao, trilha ou autorizacao
	Do Case
		Case ::nTpAutori == CARTAOMAG
			//"0099900000000099901=101200000000001"
			cRetorno += Left(AllTrim(::cTrilha2), 35)// + SEPTRILHA + AllTrim(::cTrilha1)

		Case ::nTpAutori == CARTAO
			cRetorno += AllTrim(::cNumCartao)
		
		Case ::nTpAutori == AUTORIZACAO
			cRetorno += AllTrim(Str(::nNumAutori))	
		
	EndCase
	cRetorno += SEPARADOR
	
	//Indicador de continuacao
	cRetorno += AllTrim(Str(nIndCont))
	cRetorno += SEPARADOR
    
    //Dados da tela complementar
	cRetorno += ::BusDadTela()		

Return cRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �PrepAutProd�Autor  �Vendas Clientes     � Data �  18/09/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em preparar os dados para autorizacao com produto���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nIndCont)  - Indicador de continuacao da transacao���
���			 �ExpO2 (2 - oProduto)  - Objeto do tipo PRODUTOTRNCENTRE      ���
���			 �ExpC1 (3 - cQtdeProd) - Quantidade de produtos               ���
��������������������������������������������������������������������������͹��
���Retorno   �String                                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method PrepAutProd(nIndCont, oProduto, cQtdeProd) Class LJCTrnCentre

	Local cRetorno 	:= "" 				//Variavel de retorno do metodo
	
	//Monta os dadosTx padrao das transacoes
	cRetorno := ::RetTxPad(nIndCont)
	
	//Quantidade de medicamentos
	cRetorno += cQtdeProd
	cRetorno += SEPARADOR
	
	//Codigo de barra do medicamento
	cRetorno += PadL(AllTrim(oProduto:cCodProdut), 13, "0")
	cRetorno += SEPARADOR
		
	//Tipo de embalagem
	cRetorno += AllTrim(oProduto:cTpEmbalag)
	cRetorno += SEPARADOR
	
	//Quantidade
	If (oProduto:nQtdeComp < 0)
		cRetorno += "-" + PadL(AllTrim(Str(Abs(oProduto:nQtdeComp))), 2, "0")
	Else
		cRetorno += PadL(AllTrim(Str(oProduto:nQtdeComp)), 3, "0")
	EndIf
	cRetorno += SEPARADOR

	//Preco bruto
	cRetorno += PadL(AllTrim(Str(oProduto:nPrcBruto * 100)), 7, "0")
	cRetorno += SEPARADOR

	//Preco liquido
    cRetorno += PadL(AllTrim(Str(oProduto:nPrcLiqui * 100)), 7, "0")
	cRetorno += SEPARADOR

	//Valor a receber da loja
	cRetorno += PadL(AllTrim(Str(oProduto:nVlRecLoja * 100)), 7, "0")
	cRetorno += SEPARADOR
	
	//Desconto
	cRetorno += PadL(AllTrim(Str(oProduto:nDescConce * 100)), 5, "0")
	cRetorno += SEPARADOR
	
	//Dados complementar do produto
	cRetorno += ::DadTelaProd()
	
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CfCancProd�Autor  �Vendas Clientes     � Data �  20/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirma o cancelamento do produto.						  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CfCancProd(cCodBarra, nQtde) Class LJCTrnCentre

	Local lRetorno 		:= .T.		//Retorno da funcao
	Local oProduto  	:= Nil		//Objeto do produto
	
	cCodBarra := AllTrim(cCodBarra)
		
	//Verifica se tem autorizacao
	If ::lTemAutori
		//Atualiza a quantidade comprada do produto autorizado
		::oProdAutor:AtuQtComp(cCodBarra, nQtde * -1)
	EndIf

	//Busca o produto vendido 
	oProduto := ::oProdVend:oProdutos:ElementKey(cCodBarra)
	
	//Atualiza o valor do subsidio
	::oProdVend:AltVlSub(oProduto:nSubsidio * -1) 
	
	//Atualiza a quantidade autorizada do produto vendido
	oProduto:nQtdeAutor -= nQtde
		
Return lRetorno

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
�������������������������������������������������������������������������͹��
��� DATA     � BOPS �Program.�ALTERACAO                                   ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancPBM() Class LJCTrnCentre

	Local lRetorno 		:= .F.							//Variavel de retorno do metodo 	
	
	//Carrega as operadoras
	lRetorno := ::TrataOpera()	
	
	If lRetorno
		//Solicita o numero do cartao
		lRetorno :=	::TratCartao()
	EndIf
	
	If lRetorno
		//Solicita o numero da autorizacao
		lRetorno := ::TrataAutor()
	EndIf

	If lRetorno
		//Solicita data da transacao
		lRetorno := ::SlCancDat()
	EndIf
	
	If lRetorno
		//Solicita o numero do cupom fiscal da autorizacao
		lRetorno := ::SlCancCup()
	EndIf
	
	If lRetorno
		//Gravar arquivo de controle de transacao TEF
		::GrvArqTef()
	EndIf
	
	If lRetorno
		//Envia a transacao de cancelamento
		lRetorno := ::EnvTrans(::PrepAutCanc(), CANCPROD, 11)
	EndIf
	
	If lRetorno
		//Processa o retorno da transacao
		lRetorno := ::PcRetSitef()
	EndIf
	
	If !lRetorno
		//Apaga o arquivo de controle
		::ApagArqTef()
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SlCancDat �Autor  �Vendas Clientes     � Data �  28/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar a data da transacao.               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SlCancDat() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
	
	//Solicita a data da transacao
	lRetorno := ::CapDadTela(STR0017, "A", 8, 8, STR0018, @cRetorno)//"Data";"Data (DDMMAAAA)"
		
	//Atribui o conteudo digitado
	If lRetorno
		::cDataCanc := cRetorno
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SlCancCup �Autor  �Vendas Clientes     � Data �  28/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar o numero do cupom da transacao.    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SlCancCup() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
	
	//Solicita o numero do cupom fiscal
	lRetorno := ::CapDadTela(STR0019, "A", 1, 6, STR0020, @cRetorno)//"Cupom";"N�mero do cupom"
		
	//Atribui o conteudo digitado
	If lRetorno
		::cNumCupom := PADL(AllTrim(cRetorno), 6, "0")
	EndIf

Return lRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �PrepAutCanc�Autor  �Vendas Clientes     � Data �  28/09/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em preparar os dados para o cancelamento.        ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�															   ���
��������������������������������������������������������������������������͹��
���Retorno   �String                                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method PrepAutCanc() Class LJCTrnCentre

	Local cRetorno 	:= "" 				//Variavel de retorno do metodo
	
	//Codigo da operadora
	cRetorno += ::oOperadors:cOpSelec
	cRetorno += SEPARADOR
	
	//Forma de entrada do cartao
	cRetorno += "2"
	cRetorno += SEPARADOR
		
	//Numero do cartao
	cRetorno += AllTrim(::cNumCartao)
	cRetorno += SEPARADOR
	
	//Numero da autorizacao
	cRetorno += AllTrim(Str(::nNumAutori))
	cRetorno += SEPARADOR
    
	//Data
	cRetorno += AllTrim(::cDataCanc)
	cRetorno += SEPARADOR
	
	//Numero cupom
	cRetorno += AllTrim(::cNumCupom)
	
Return cRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �TrataServ  �Autor  �Vendas Clientes     � Data �  01/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar os servicos especificos do TrnCentre.  ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oServEsp) - Objeto do tipo servico.			   ���
��������������������������������������������������������������������������͹��
���Retorno   �String                                                       ���
��������������������������������������������������������������������������͹��
��� DATA     � BOPS �Program. �ALTERACAO                                   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method TrataServ(oServEsp) Class LJCTrnCentre
	
   	Local nCount	:= 0					//Variavel de controle contador
	Local cTpDados	:= ""					//Tipo de dados do servicoX
	Local oServico	:= Nil					//Objeto do servico retornado
	Local oServicos	:= Nil					//Objeto com os servicos especificos
	
	DEFAULT oServEsp := Nil
	
	oServicos := LJCColecao():Colecao()
	
	oServico := oServEsp
	
	//Verifica todos os servicos retornados
	For nCount:= 1 To ::oServico:GetServs():Count()
		//Verifica se e servicoX
		If ::oServico:GetServs():Elements(nCount):cTpServ == "X"
			//Verifica o tipo de dados do servico
			cTpDados := Substr(::oServico:GetServs():Elements(nCount):cServicoX, 1, 1)
			
			Do Case
				Case cTpDados == OPERADORA
					//Estancia o objeto ServicoXOperadora
					oServico := LJCServicoXOperadora():ServicoXOp("X")
				
				Case cTpDados == TELCOMPL
					//Estancia o objeto ServicoXTelaComplementar
					oServico := LJCServicoXTelaComplementar():XTelaCompl("X")			
				
				Case cTpDados == PRODAUT				
					//Estancia o objeto ServicoXProdutoTrnCentre
					If oServico == Nil
						oServico := LJCServicoXProdutoTrnCentre():XProdTrnCe("X")
					EndIf
				/*Case cTpDados == TELCOMPLPRO
					//Estancia o objeto ServicoXTelaProduto
					oServico := LJCServicoXTelaProduto():XTelaProd("X")*/
			EndCase
			
			//Trata o servico retornado
			oServico:TratarServ(::oServico:GetServs():Elements(nCount):cServicoX)
			
			//Adiciona o servico na colecao de retorno
			oServicos:Add("X", oServico, .T.)
		EndIf 
	Next

Return oServicos

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �AbreVenda  �Autor  �Vendas Clientes     � Data �  04/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em efetuar a abertura da venda quando nao houver ���
���			 �pre-autorizacao.  									       ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�															   ���
��������������������������������������������������������������������������͹��
���Retorno   �Logico                                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method AbreVenda() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
		
	//Envia a transacao para abrir a venda
	lRetorno := ::EnvTrans(::RetTxPad(1), ABREVENDA, 11)
	
	If lRetorno
		//Processa o retorno da transacao
		lRetorno := ::PcRetSitef()
	EndIf	

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SlTemAut  �Autor  �Vendas Clientes     � Data �  04/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar se tem ou nao pre-autorizacao.     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SlTemAut() Class LJCTrnCentre

	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
	
	//Solicita se tem ou nao pre-autorizacao
	lRetorno := ::CapDadTela(STR0004, "F", 1, 1, STR0021, @cRetorno)//"Autoriza��o";"Tem autoriza��o?"
		
	//Atribui o conteudo digitado
	If lRetorno
		If cRetorno == "S"
			::lTemAutori := .T.
		Else
			::lTemAutori := .F.		
		EndIf
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �VendComAut�Autor  �Vendas Clientes     � Data �  04/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a venda do Produto com pre-autorizacao.             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
���          �ExpN2	(3 - nPrUnit)	- Preco do produto.                   ���
���          �ExpN3 (4 - nPercDesc) - Percentual de desconto do produto.  ���
���          �ExpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������͹��
��� DATA     � BOPS �Program.�ALTERACAO                                   ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VendComAut(cCodBarra, nQtde, nPrUnit, nPercDesc, ;
				  lItemPbm) Class LJCTrnCentre

	Local lRetorno 	:= .F.		//Variavel de retorno da funcao
	Local oProdEnv 	:= Nil		//Objeto com os dados do produto a ser enviado 
	Local oProdAut 	:= Nil		//Objeto com o produto da pre-autorizacao
	Local oProdRet 	:= Nil		//Objeto com os dados do produto retornado
	Local nPrcLiqLj	:= 0		//Preco liquido da loja
	Local oServicos	:= Nil		//Objeto com os servicos retornados
	
	cCodBarra := AllTrim(cCodBarra)
	cCodBarra := Padl(cCodBarra, 13, "0")
		
	lItemPbm := .F.
	
	//Verifica se o produto existe nos produtos autorizados
	If ::oProdAutor:ExisteProd(cCodBarra)
		//Verifica se o produto pode ser vendido
		If ::oProdAutor:PodeVender(cCodBarra, nQtde)
			//Calcula o valor liquido da loja
			nPrcLiqLj := ::oGlobal:Funcoes():CalcValor(nPrUnit, (nPrUnit * (nPercDesc / 100)), 2, 2)
			//Busca o produto na pre-autorizacao
			oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
			//Cria um objeto com os dados do produto a ser enviado
			oProdEnv := LJCProdutoTrnCentre():ProTrnCent()
			
			//Atribui os dados para o produto a ser enviado    
		    oProdEnv:cCodProdut	:= oProdAut:cCodProdut
		    oProdEnv:cTpEmbalag	:= oProdAut:cTpEmbalag
		    oProdEnv:nQtdeComp	:= nQtde
		    oProdEnv:nPrcBruto	:= nPrUnit
		    oProdEnv:nPrcLiqui	:= nPrcLiqLj
		    oProdEnv:nVlRecLoja	:= oProdAut:nVlRecLoja
		    oProdEnv:nDescConce	:= nPercDesc
		    
			//Envia a transacao de autorizacao com produto
			lRetorno := ::EnvTrans(::PrepAutProd(1, oProdEnv, "1"), AUTPROD, 11)
						
			If lRetorno
				//Processa o retorno da transacao
				lRetorno := ::PcRetSitef()
			EndIf	
				
			If lRetorno
			    //Trata o servico retornado	
				oServicos := ::TrataServ(::oXProdVend)
			    
			    //Valida se retornou o servico
				If oServicos:Count() > 0
					//Gravar arquivo de controle de transacao TEF
					::GrvArqTef()
					//Busca o servico
					::oXProdVend := oServicos:Elements(1)
					//Seta a variavel para indicar que o item foi enviado a PBM
					lItemPbm := .T.
					//Atribui ao objeto de produtos vendidos o retorno do produto que foi enviado
					::oProdVend:oProdutos := ::oXProdVend:BuscaProd()
					//Busca os dados retornado do produto enviado
					oProdRet := ::oProdVend:oProdutos:ElementKey(cCodBarra)
					//Calcula o percentual de desconto a ser praticado
					nPercDesc := ::oGlobal:Funcoes():CalcValor((oProdRet:nPrcBruto - oProdRet:nPrcLiqui) * 100, oProdRet:nPrcBruto, 4, 2)
					//Atualiza o valor do subsidio
					::oProdVend:AltVlSub(oProdRet:nSubsidio)
					//Atualiza a quantidade comprada do produto autorizado
					::oProdAutor:AtuQtComp(cCodBarra, nQtde)    
				Else
					//ServicoX de produto nao retornado
					MsgAlert(STR0014) //"Autoriza��o com produto n�o retornada no servicoX"
					lRetorno := .F.
				EndIf
			Else
				//Problemas ao processar servicos
				lRetorno := .F.		
			EndIf
		Else
			lRetorno := .F.
		EndIf
	Else
		lRetorno := .T.
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �VendSemAut�Autor  �Vendas Clientes     � Data �  04/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a venda do Produto sem pre-autorizacao.             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
���          �ExpN2	(3 - nPrUnit)	- Preco do produto.                   ���
���          �ExpN3 (4 - nPercDesc) - Percentual de desconto do produto.  ���
���          �ExpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VendSemAut(cCodBarra, nQtde, nPrUnit, nPercDesc, ;
				  lItemPbm) Class LJCTrnCentre

	Local lRetorno 	:= .F.		//Variavel de retorno da funcao
	Local oProdEnv 	:= Nil		//Objeto com os dados do produto a ser enviado 
	Local oProdRet 	:= Nil		//Objeto com os dados do produto retornado
	Local nPrcLiqLj	:= 0		//Preco liquido da loja
	Local oServicos	:= Nil		//Objeto com os servicos retornados
	Local nCount	:= 0		//Variavel de controle contador
	Local lEnvProd  := .T.		//Controla se o produto sera enviado novamente
	
	cCodBarra := AllTrim(cCodBarra)
	cCodBarra := Padl(cCodBarra, 13, "0")	
	
	lItemPbm := .F.

	//Calcula o valor liquido da loja
	nPrcLiqLj := ::oGlobal:Funcoes():CalcValor(nPrUnit, (nPrUnit * (nPercDesc / 100)), 2, 2) // NoRound(nPrUnit - (nPrUnit * (nPercDesc / 100)), 2)
	//Cria um objeto com os dados do produto a ser enviado
	oProdEnv := LJCProdutoTrnCentre():ProTrnCent()
	
	//Atribui os dados para o produto a ser enviado    
    oProdEnv:cCodProdut	:= cCodBarra
    oProdEnv:cTpEmbalag	:= "U"
    oProdEnv:nQtdeComp	:= nQtde
    oProdEnv:nPrcBruto	:= nPrUnit
    oProdEnv:nPrcLiqui	:= nPrcLiqLj
    oProdEnv:nDescConce	:= nPercDesc

	While lEnvProd
	
		//Envia a transacao de autorizacao com produto
		lRetorno := ::EnvTrans(::PrepAutProd(1, oProdEnv, "1"), AUTPROD, 11)
		
		If lRetorno
			//Processa o retorno da transacao
			lRetorno := ::PcRetSitef()
		EndIf	
			
		If lRetorno .OR. ::oDadosTran:nCodResp == 43
		    //Trata o servico retornado	
			oServicos := ::TrataServ(::oXProdVend)
		    
		    //Valida se retornou o servico
			If oServicos:Count() > 0
				
				//Separa os servicos retornados
				For nCount := 1 To oServicos:Count()
					If oServicos:Elements(nCount):cTpDados == PRODAUT
						//Busca o servico X dos produtos retornados
						::oXProdVend := oServicos:Elements(nCount)
						//Busca o retorno do produto 
						oProdRet := ::oXProdVend:BuscaProd():ElementKey(cCodBarra)
					/*ElseIf oServicos:Elements(nCount):cTpDados == TELCOMPLPRO
					    //Busca as telas de produto retornada
					    ::oTelComPro := oServicos:Elements(nCount):BusTelProd()*/
					EndIf 
				Next
				
				//Status do produto
				//O produto foi aceito com sucesso
				If oProdRet:nStProduto == OK_TRN .OR. oProdRet:nStProduto == OK_ATENDIMENTO
					//Gravar arquivo de controle de transacao TEF
					::GrvArqTef()
					//Seta a variavel para indicar que o item foi enviado a PBM
					lItemPbm := .T.
					//Atribui ao objeto de produtos vendidos o retorno do produto que foi enviado
					::oProdVend:oProdutos := ::oXProdVend:BuscaProd()
					//Calcula o percentual de desconto a ser praticado
					nPercDesc := ::oGlobal:Funcoes():CalcValor((oProdRet:nPrcBruto - oProdRet:nPrcLiqui) * 100, oProdRet:nPrcBruto, 4, 2)
					//O produto nao precisa ser enviado novamente
					lEnvProd  := .F.    
					//Atualiza o valor do subsidio
					::oProdVend:AltVlSub(oProdRet:nSubsidio)					                   
				
				//Falta tela complementar de produto
				ElseIf oProdRet:nStProduto == PEND
					//Atualiza a quantidade autorizada do produto vendido
					oProdRet:nQtdeAutor -= nQtde
					//Trata os dados da tela complementar do produto
					::TratTelProd()
					//Carrega dados da tela complementar do produto
					lRetorno := ::CarTelProd()		
					//Se for carregada, enviar o produto novamente com os dados da tela
					If lRetorno
						lEnvProd := .T.
					EndIf
				
				//O produto foi negado por dados invalidos
				ElseIf oProdRet:nStProduto == NEGADA
					//Atualiza a quantidade autorizada do produto vendido
					oProdRet:nQtdeAutor -= nQtde
					//O produto nao precisa ser enviado novamente
					lEnvProd := .F.
					lRetorno := .T.
				EndIf
			Else
				//ServicoX de produto nao retornado
				MsgAlert(STR0014) //"Autoriza��o com produto n�o retornada no servicoX"
				lRetorno := .F.
				lEnvProd  := .F.
			EndIf
		Else
			//Problemas ao processar servicos
			lRetorno := .F.
			lEnvProd  := .F.
		EndIf
	
	End
	
	//Desfaz o objeto de tela complementar do produto
	::oTelComPro := Nil
	
Return lRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �DadTelaProd�Autor  �Vendas Clientes     � Data �  09/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em formatar os dados da tela complementar do pro-���
���			 �duto que foi capturado.								       ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�														       ���
��������������������������������������������������������������������������͹��
���Retorno   �String                                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method DadTelaProd() Class LJCTrnCentre
	
	Local cRetorno 	:= "" 				//Variavel de retorno do metodo
	Local nCount	:= 0				//Variavel de controle contador
		
	//Concatena os dados da tela complementar do produto no seguinte formato:
	//LLyyy..yyLLyyy..yy, onde LL(quantidade de caracteres capturados) e yyy..yy(sao os dados capturados)
	If ::oTelComPro != Nil
		For nCount :=1 to ::oTelComPro:Count()
	    	If ValType(::oTelComPro:Elements(nCount):oValor) == "N"
		    	cRetorno += StrZero(Len(AllTrim(Str(::oTelComPro:Elements(nCount):oValor))),2) + AllTrim(Str(::oTelComPro:Elements(nCount):oValor)) 		
	    	ElseIf ValType(::oTelComPro:Elements(nCount):oValor) == "C"
	    		cRetorno += StrZero(Len(AllTrim(::oTelComPro:Elements(nCount):oValor)),2) + AllTrim(::oTelComPro:Elements(nCount):oValor) 		
	    	EndIf
	    	//Completa a string com espacos ate completar 16 caracteres
	    	cRetorno := PadR(AllTrim(cRetorno), 16, " ")
		Next
	Else
		cRetorno := Repl(" ",16)
	EndIf

	cRetorno += SEPARADOR
	
Return cRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �CarTelProd �Autor  �Vendas Clientes     � Data �  10/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em solicitar os dados da tela complementar do    ���
���			 �produto.												       ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�														       ���
��������������������������������������������������������������������������͹��
���Retorno   �Logico                                                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method CarTelProd() Class LJCTrnCentre
	
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
	Local nCount	:= 0					//Variavel de controle contador
	Local oRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela
	
	//Faz um for para capturar todos os campos da tela de produto
	For nCount := 1 To ::oTelComPro:Count()
		//"Tela Complementar" 			
		lRetorno := ::CapDadTela(STR0003, ;
								 ::oTelComPro:Elements(nCount):cTipoCampo, ;
								 ::oTelComPro:Elements(nCount):nMinimo, ;
								 ::oTelComPro:Elements(nCount):nMaximo, ;
								 ::oTelComPro:Elements(nCount):cCampo, ;
								 @oRetorno)
	
		//Atribui ao objeto o conteudo digitado
		If lRetorno
			::oTelComPro:Elements(nCount):oValor := oRetorno
		Else
			Exit
		EndIf
	Next
	
Return lRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Metodo    �TratTelProd�Autor  �Vendas Clientes     � Data �  10/10/07   ���
��������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o objeto com os dados da tela do produto���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         ���
��������������������������������������������������������������������������͹��
���Parametros�														       ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method TratTelProd() Class LJCTrnCentre

	Local oServico	:= Nil					//Objeto do servico retornado
	
	//Estancia o objeto ServicoXTelaProduto
	oServico := LJCServicoXTelaProduto():XTelaProd("X")
				
	//Trata o servico retornado
	oServico:TratarServ(::oTelCompl:cCapProdut)
	
	//Busca as telas de produto retornada
    ::oTelComPro := oServico:BusTelProd()
	
Return Nil
