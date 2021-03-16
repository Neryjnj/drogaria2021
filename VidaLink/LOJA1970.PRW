#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1001.CH"
  
//���������������������������Ŀ
//�Tipo de transacoes enviadas�
//�����������������������������
#DEFINE CONSULTA 		1
#DEFINE VENDA	 		2
#DEFINE CANCELAMENTO	3
#DEFINE SEPARADOR 		CHR(0)

//���������������������������������Ŀ
//�Meios para buscar pre-autorizacao�
//�����������������������������������
#DEFINE CARTAOMAG		1
#DEFINE CARTAO			2
#DEFINE AUTORIZACAO		3

User Function LOJA1970 ; Return  			// "dummy" function - Internal Use

/*--------------------------------------------------------------------------------
|Classe    |LJCVDLINK       |Autor  |Julio Nery     | Data |  15/03/21           |
|--------------------------------------------------------------------------------|
|Desc.     |Classe responsavel por tratar o processo PBM VidaLink.				 |
|--------------------------------------------------------------------------------|
|Uso       |TotvsPDV                                                    		 |
--------------------------------------------------------------------------------*/
Class LJCVDLINK From LJCSitefDireto
	
	DATA nQtdeMed												//Quantidade de medicamentos retornados na consulta
	DATA nIndAtual												//Indice do medicamento que esta sendo retornado no VidaLink
	DATA cCNPJConvenio											//CNPJ do Convenio
	DATA cCodPlano												//Codigo do plano de desconto do Convenio
	DATA cCupom01												//Primeira via do cupom VIDALINK
	DATA cCupom02												//Segunda via do cupom VIDALINK
	DATA aItems													//Items da Consulta VIDALINK
	DATA cNsuAutor                                              //Numero de Autorizacao do VidaLink
	DATA cNsuSitef                                              //Numero do NSU do SiTEF 
    DATA cHoraTrans        										//Hora da transacao
    DATA cAutoriza                          					//Cont�m o C�digo de Autoriza��o para as transa��es de cr�dito (15 posi��es no m�ximo)  
    DATA cDescAdm                                               //Nome da Administradora de cartao	
	DATA cTipCart												//Identificador de cartao diferenciado
	DATA lConfTran												//Controla a Confirmacao de Envio da Venda Do Vidalink
	DATA cNumPreAut
	DATA cNomeConveniado	
	DATA cNomEmpConv
	DATA cSaldoDisp	
	DATA cDataIni
	DATA cDataFim	
	DATA cQtdeDependentes
	DATA cCodDependente	
	DATA cNomDependente
	DATA cCodAut
	DATA cCodProd
	DATA cCupom
	DATA cData
	DATA cHora
	DATA cOperador	

    //JULIOOOOOOOO
	Method PVidaLink()												//Metodo construtor
    Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador)

    /*
	Method IniciaVend(cCupom, cOperador)							//Inica a venda com o PBM
	Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, ;			//Realiza a venda do produto
					lItemPbm, lPrioPbm)
	Method CancProd(cCodBarra, nQtde)								//Cancela o produto da PBM
	Method FinalVend()												//Finaliza a venda
	Method BuscaRel()												//Busca relatorio para impressao
	Method BuscaSubs()												//Busca valor do subsidio
	Method ConfProd( cCodBarra, nQtde, lOk )						//Confirma o produto vendido
	Method ConfVend(lConfirma)										//Confirma a venda na PBM
	Method CancPBM()												//Cancela a transacao total da PBM	
	*/

	//Metodos internos
	// Method SelTpAutor()												//Metodo que ira solicitar como sera feito a recuperacao da pre-autorizacao
	// Method TrataAutor()												//Metodo que ira solicitar o numero da autorizacao
	// Method PrepPreAut(nIndCont, cNSU)								//Metodo que ira montar os dados para recuperacao da pre-autorizacao
	// Method BuscPreAut() 											//Metodo de busca de pre-autorizacao
	// Method TrataServ(oServEsp)										//Metodo que ira tratar os servicos especificos da TrnCentre
	// Method LjProd()													//Confirma monta a lista de produtos vendidos
	// Method SlCancDat()												//Metodo que ira solicitar a data que a autorizacao foi efetuada
	// Method SlCancCup()												//Metodo que ira solicitar o numero do cupom fiscal da autorizacao a ser cancelada
	// Method SlCancPdv()												//Metodo que ira solicitar o numero do PDV que fez a venda
	// Method PrepAutCanc()											//Prepara a autorizacao para o cancelamento da venda
	// Method PrVendido()												//Retorno se houve produtos vendidos
	// Method TrataNSU()                                            	//Metodo que ira solicitar o numero do NSU da venda
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} PVidaLink
Inicia PBM Vidalink

@param		oCLisitef, objeto do CLisitef
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		Self - Objeto
/*/
//-------------------------------------------------------------------
Method PVidaLink(oClisitef) Class LJCVDLINK

::SitefDireto(oClisitef)

::nQtdeMed			:= 0
::nIndAtual			:= 0
::cCNPJConvenio		:= ""
::cCodPlano			:= ""
::cCupom01			:= ""
::cCupom02			:= ""
::cNsuAutor	    	:= ""
::cNsuSitef         := ""
::cHoraTrans        := ""
::cAutoriza         := "" 
::cDescAdm          := "" 
::cTipCart          := ""
::lConfTran      	:= .F.
::cNumPreAut		:= ""
::cNomeConveniado   := ""
::cNomEmpConv		:= ""
::cSaldoDisp		:= ""
::cDataIni			:= ""
::cDataFim			:= ""
::cQtdeDependentes  := ""
::cCodDependente    := ""
::cNomDependente	:= ""
::cCodAut			:= ""
::cCodProd			:= ""
::cCupom			:= ""
::cData				:= ""
::cHora				:= ""
::cOperador			:= ""

Return Self

/*/{Protheus.doc} VDLinkCons
	Classe de consulta de dados VidaLINK
	@type  Class
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCons(cCodAut,cCodProd,nCupom,dData,cHora,cOperador) Class LJCVDLINK
Local lRet := .T.

::cCodAut	:= cCodAut
::cCodProd	:= cCodProd
::cCupom	:= cValToChar(nCupom)
::cData		:= DToS(dData)
::cHora		:= StrTran(cHora,":")
::cOperador	:= cOperador

//JULIOOOOOOOOOOOOOOOOO - continuar daqui, verificando aonde chamar pra ir pro proximo fonte
// lRet := ::

Return lRet

// /*���������������������������������������������������������������������������
// ���Programa  �IniciaVend�Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Inicia o metodo do processo de venda.                       ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametro �ExpC1 (1 - cCupom) 	- Numero do cupom Fiscal.             ���
// ���			 �ExpC2 (2 - cOperador) - Codigo do operador.	              ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method IniciaVend( cCupom, cOperador , cTpDoc ) Class LJCFunCard
// Local lRetorno := .T.		//Retorno do Metodo

// Default cTpDoc := ""

// LjGrvLog( cCupom, " Inicio da fun��o - [cCupom | cOperador | cTpDoc]", {cCupom,cOperador,cTpDoc}, .T. )
// ::cNumCupom     := cCupom
// ::nCodOper      := Val(cOperador)
// ::cTpDoc		:= cTpDoc

// //Solicita o numero da autorizacao
// lRetorno := ::TrataAutor()

// //Carrega os produtos da pre-autorizacao
// If lRetorno
// 	LjGrvLog( cCupom, " Antes de BuscPreAut" )
//     lRetorno := ::BuscPreAut()
//     LjGrvLog( cCupom, " Depois de BuscPreAut", lRetorno )
// EndIf
	
// LjGrvLog( cCupom, " Fim da fun��o - Retorno:", lRetorno )

// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Programa  �VendProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Realiza a venda do Produto.                                 ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
// ���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
// ���          �ExpN2	(3 - nPrUnit)	- Preco do produto.                   ���
// ���          �ExpN3 (4 - nPercDesc) - Percentual de desconto do produto.  ���
// ���          �ExpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method VendProd(cCodBarra	, nQtde		, nPrUnit	, nPercDesc, ;
// 				lItemPbm	, lPrioPbm	) Class LJCFunCard
	
// Local lRet 		:= .F.		//Retorno da funcao
// Local cLogProd	:= ""

// Default lItemPbm:= .F.		//Define se a venda do produto foi realizada pela PBM

// LjGrvLog( NIL, " Inicio da fun��o " )

// cCodBarra := Alltrim(cCodBarra)
// cLogProd  := cCodBarra	
// cCodBarra := Padl(cCodBarra, 13, "0")

// //Verifica se o produto existe nos produtos autorizados (loja1003)
// If ::oProdAutor:ExisteProd(cCodBarra)
// 	//Verifica se o produto pode ser vendido (loja1003)
// 	If ::oProdAutor:PodeVender(cCodBarra, nQtde)
// 		//Calcula o valor liquido da loja
// 		nPrcLiqLj := nPrUnit - Round((nPrUnit) * (nPercDesc / 100), 2)
// 		//Busca o produto na pre-autorizacao
// 		oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
// 		If nPrcLiqLj > oProdAut:nVlUnVenda
// 			//obtemos o percentual de desconto que sera aplicado ao item
// 			nPercDesc := ::oGlobal:Funcoes():CalcValor((nPrUnit - (oProdAut:nVlUnVenda + oProdAut:nVlRepasse)) / nPrUnit, 100, 3, 2)
// 			lItemPbm	:= .T.
// 			lRet		:= .T.
// 			LjGrvLog( NIL, " Obtido valor de desconto do produto [C�dgio de barras: " + cLogProd + "]  - Valor Desconto: ",nPercDesc )
// 		Else
// 			lRet := .T.
// 		Endif
//     Else
//     	lRet := .F.
//     	LjGrvLog( NIL, " N�o pode vender o produto [C�dgio de barras: " + cLogProd + "]  " )
//     EndIf
// Else
// 	LjGrvLog( NIL, " N�o encontrou o produto [C�dgio de barras: " + cLogProd + "]  para ser autorizado " )
// 	lRet := .T.
// EndIf

// LjGrvLog( NIL, " Fim da Fun��o ", lRet )
	
// Return lRet

// /*���������������������������������������������������������������������������
// ���Programa  �CancProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Realiza o cancelamento do produto vendido no PBM.           ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�ExpC1 (1 - cCodBarra) - Codigo de barras do produto.        ���
// ���          �ExpN1	(2 - nQtde)		- Quantidade do produto.              ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method CancProd( cCodBarra, nQtde ) Class LJCFunCard
// Local lRet 		:= .T.		//Retorno da funcao
// Local oProdAut	:= Nil		//Objeto com os produtos autorizados

// LjGrvLog( Nil, " Inicio da fun��o - [cCodBarra / nQtde]", {cCodBarra,nQtde})
// cCodBarra := Alltrim(cCodBarra)	
// cCodBarra := Padl(cCodBarra, 13, "0")	
	
// //Busca o produto autorizado
// oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)		
// //Atualiza a quantidade comprada do produto autorizado
// ::oProdAutor:AtuQtComp(cCodBarra, (nQtde * -1) )
// //Atualiza o valor do subsidio
// ::oProdVend:AltVlSub((oProdAut:nVlRepasse * nQtde) * -1)

// LjGrvLog( Nil, " Fim da fun��o ", lRet)
// Return lRet

// /*���������������������������������������������������������������������������
// ���Programa  �FinalVend �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Finaliza a venda no PBM.                                    ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�													          ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCFunCard
// Local lRetorno := .T.		//Retorno da funcao
// Local cDadosAdm	:= ""

// Default cDoc := "" //Numero documento Fiscal
// Default cSerie := "" //Serie do documento Fiscal
// Default cKeyDoc := "" //Chave do documento Fiscal 

// LjGrvLog( Nil, " Inicio da fun��o ")
// LjGrvLog( Nil, " Par�metros [cDoc | cSerie | cKeyDoc] ", {cDoc,cSerie,cKeyDoc})

// cDadosAdm := SEPARADOR + "ParamAdic={TipoDocFiscal="+::cTpDoc +; //Tipo de documento fiscal usado na venda:0 Cupom Fiscal 1 NFC-e 2 SAT
//              IIF(::cTpDoc <> "0", ";ChaveAcessoDocFiscal="+ AllTrim(cKeyDoc), "")+"}"//1-  44 N�mero da chave de acesso (para NFC-e ou SAT).

// LjGrvLog( Nil, " Comando enviado ao Sitef [" + cDadosAdm + "]")

// If ::PrVendido()
// 	LjGrvLog( Nil, " Antes do m�todo EnvTrans ")
// 	lRetorno := ::EnvTrans(::LjProd() + cDadosAdm, VENDA, 0)
// 	LjGrvLog( Nil, " Depois do m�todo EnvTrans ",lRetorno)

// 	If lRetorno
// 		//Processa o retorno da transacao
// 		LjGrvLog( Nil, " Antes do m�todo PcRetSitef ")
// 		lRetorno := ::PcRetSitef()
// 		LjGrvLog( Nil, " Depois do m�todo PcRetSitef ", lRetorno)
// 	EndIf	

// 	//Grava o arquivo de controle
// 	If lRetorno
// 		::GrvArqTef()
// 	EndIf
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ", lRetorno)
	
// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Programa  �BuscaRel  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     � Retorna o relatorio a ser impresso, na finalizacao da ven- ���
// ���          � da no processo da PBM.                                     ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�													          ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Array                                                       ���
// ���������������������������������������������������������������������������*/
// Method BuscaRel() Class LJCFunCard
// Local aCupom := {}

// aCupom := ::oComprova:aComprovan
// LjGrvLog( Nil, " Retorno do Relat�rio do E-pharma a ser impresso ", aCupom)

// Return aCupom

// /*���������������������������������������������������������������������������
// ���Programa  �BuscaSubs �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Busca o valor do subsidio.								  ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�													          ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Numerico                                                    ���
// ���������������������������������������������������������������������������*/
// Method BuscaSubs() Class LJCFunCard
// Local nRetVal := 0					//Retorna o valor do subisidio

// //Busca o valor do subsidio nos produtos vendidos
// nRetVal := ::oProdVend:BusVlSub()		
	
// Return nRetVal

// /*���������������������������������������������������������������������������
// ���Programa  �ConfProd  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Confirma o produto vendido.								  ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�													          ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// �������������������������������������������������������������������������͹��
// ��� DATA     � BOPS �Program.�ALTERACAO                                   ���
// ���������������������������������������������������������������������������*/
// Method ConfProd( cCodBarra, nQtde, lOk ) Class LJCFunCard
// Local lRet 		:= .T.		//Retorno da funcao
// Local oProdAut	:= Nil		//Objeto com os produtos autorizados

// LjGrvLog( Nil, " Inicio da Fun��o")

// cCodBarra := Alltrim(cCodBarra)
// LjGrvLog( Nil, " Produto a ser confirmado - [C�digo]", cCodBarra)	
// cCodBarra := Padl(cCodBarra, 13, "0")	
	
// If lOk
// 	//Busca o produto autorizado
// 	oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
// 	//Atualiza a quantidade comprada do produto autorizado
// 	::oProdAutor:AtuQtComp(cCodBarra, nQtde)
// 	//Atualiza o valor do subsidio
// 	::oProdVend:AltVlSub(oProdAut:nVlRepasse * nQtde)
// EndIf

// LjGrvLog( Nil, " Fim da Fun��o")	
// Return lRet

// /*���������������������������������������������������������������������������
// ���Programa  �ConfVend  �Autor  �Vendas Clientes     � Data �  06/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Confirma a venda PBM.     								  ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�ExpL1 (1 - lConfirma) - Indica se a transacao sera confirma-���
// ���			 �da ou desfeita.       							          ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �		                                                      ���
// ���������������������������������������������������������������������������*/
// Method ConfVend(lConfirma) Class LJCFunCard

// Default lConfirma := .F.

// LjGrvLog( Nil, " Inicio da Fun��o")
// LjGrvLog( Nil, " Confirma ou Desfaz a Venda?",lConfirma)

// //Confirma ou desfaz a venda
// ::FimTrans(lConfirma)

// //Apaga o arquivo de controle
// ::ApagArqTef()

// LjGrvLog( Nil, " Fim da Fun��o")
// Return Nil

// /*���������������������������������������������������������������������������
// ���Metodo    �CancPBM   �Autor  �Vendas Clientes     � Data �  21/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Cancela a transacao da PBM.                                 ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method CancPBM() Class LJCFunCard
// Local lRetorno := .F.							//Variavel de retorno do metodo

// LjGrvLog( Nil, " Inicio da fun��o - Cancelamento",,.T.)


// //Solicita o numero do NSU da venda
// lRetorno := ::TrataNSU()
// LjGrvLog( Nil, " Captura NSU da Transa��o", lRetorno)

// If lRetorno
// 	//Solicita data da venda
// 	lRetorno := ::SlCancDat()
// 	LjGrvLog( Nil, " Captura Data da Transa��o", lRetorno)
// EndIf

// If lRetorno
// 	// Solicita o numero do PDV que fez a venda
// 	lRetorno := ::SlCancPdv()
// 	LjGrvLog( Nil, " Captura PDV da Transa��o", lRetorno)
// EndIf

// If lRetorno
// 	//Solicita o numero do cupom fiscal da autorizacao
// 	lRetorno := ::SlCancCup()
// 	LjGrvLog( Nil, " Captura Numero do Documento da Transa��o", lRetorno)
// EndIf

// If lRetorno
// 	//Envia a transacao de cancelamento
// 	lRetorno := ::EnvTrans(::PrepAutCanc(), CANCELAMENTO, 11)
// 	LjGrvLog( Nil, " Envia o comando de cancelamento da Transa��o", lRetorno)
// EndIf

// If lRetorno
// 	//Processa o retorno da transacao
// 	lRetorno := ::PcRetSitef()
// 	LjGrvLog( Nil, " Processamento do retorno do cancelamento ", lRetorno)
// EndIf

// If lRetorno
// 	//Gravar arquivo de controle de transacao TEF
// 	::GrvArqTef()
// EndIf

// LjGrvLog( Nil, " Fim da fun��o - Cancelamento")

// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �SlCancCup �Autor  �Vendas Clientes     � Data �  09/11/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em solicitar o numero do cupom da transacao.    ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method SlCancCup() Class LJCFunCard
// Local lRetorno 	:= .F.					//Variavel de retorno da funcao
// Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
// Local nTam		:= 6

// LjGrvLog( Nil, " Inicio da Fun��o")

// //Solicita o numero do cupom fiscal
// lRetorno := ::CapDadTela(STR0014, "A", 1, nTam, STR0015, @cRetorno) //"Cupom";"N�mero do cupom"
// LjGrvLog( Nil, " Solicitado numero do documento ",lRetorno)
	
// //Atribui o conteudo digitado
// If lRetorno
// 	::cNumCupom := cRetorno
// 	LjGrvLog( Nil, " Numero do Doc Digitado",cRetorno)
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ",lRetorno)
// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �TrataAutor�Autor  �Vendas Clientes     � Data �  02/10/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em solicitar o numero da autorizacao.           ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method TrataAutor() Class LJCFunCard  
// Local lRetorno 	:= .F.					//Variavel de retorno da funcao
// Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

// LjGrvLog( Nil, " Inicio da Fun��o")

// //Busca o numero da autorizacao
// lRetorno := ::CapDadTela(STR0001, "N", 1, 12, STR0002, @cRetorno)//"Autoriza��o";"N�mero da autoriza��o"
// LjGrvLog( Nil, " Busca numero da autoriza��o ",lRetorno)

// //Atribui ao objeto o conteudo digitado
// If lRetorno
// 	::nNumAutori := Val(cRetorno)
// 	LjGrvLog( Nil, " Numero da autoriza��o",Val(cRetorno))
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ",lRetorno)
// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �TrataAutor�Autor  �Vendas Clientes     � Data �  02/10/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em solicitar o numero do NSU da venda.          ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method TrataNSU() Class LJCFunCard  
// Local lRetorno 	:= .F.					//Variavel de retorno da funcao
// Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

// LjGrvLog( Nil, " Inicio da Fun��o")

// //Captura o numero do NSU da venda
// lRetorno := ::CapDadTela(STR0016, "N", 1, 12, STR0017, @cRetorno)//"Autoriza��o";"N�mero da autoriza��o"
// LjGrvLog( Nil, " Busca numero da NSU ",lRetorno)

// //Atribui ao objeto o conteudo digitado
// If lRetorno
// 	::nNSU := Val(cRetorno)
// 	LjGrvLog( Nil, " Numero da NSU",Val(cRetorno))
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ",lRetorno)
// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �BuscPreAut�Autor  �Vendas Clientes     � Data �  02/10/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em buscar os produtos da pre-autorizacao.       ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method BuscPreAut() Class LJCFunCard
// Local lRetorno 	:= .T.					//Variavel de retorno da funcao
// Local aServico	:= Nil					//Array com os servicos retornados

// //Envia a transacao para carregar os produtos da pre-autorizacao
// lRetorno := ::EnvTrans( Alltrim(Str(::nNumAutori) ) , CONSULTA, 0)

// If lRetorno
// 	//Processa o retorno da transacao
// 	lRetorno := ::PcRetSitef()
// EndIf	
	
// If lRetorno
// 	//Trata o servico retornado	
// 	aServico := ::TrataServ()

//     //Valida se retornou o servico
// 	If aServico:Count() > 0
// 		//Busca o servico
// 		oXProdEph := aServico:Elements(1)
		
// 		//Atribui ao objeto de produtos autorizados os produtos da pre-autorizacao
// 		::oProdAutor:oProdutos := oXProdEph:BuscaProd()
// 	Else
// 		//ServicoX de produto nao retornado
// 		MsgAlert(STR0008) //"Lista de produtos EPHARMA n�o retornada no servicoX"
// 		lRetorno := .F.
// 	EndIf
// Else
// 	//Problemas ao processar servicos
// 	lRetorno := .F.		
// EndIf

// LjGrvLog( Nil, " Fim da fun��o - Pr�-Autoriza��o OK?", lRetorno)

// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �PrepPreAut�Autor  �Vendas Clientes     � Data �  02/10/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em preparar os dados para recuperacao da pre-   ���
// ���			 �autorizacao.											      ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�ExpN1 (1 - nIndCont) - Indicador de continuacao de produto. ���
// ���			 �ExpC1 (2 - cNSU) 	   - Numero do NSU. 					  ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method PrepPreAut(nIndCont, cNSU) Class LJCFunCard
// Local cRetorno := "" 				//Variavel de retorno do metodo
	
// //Monta os dadosTx padrao das transacoes
// cRetorno := ::RetTxPad(nIndCont)

// //Nsu da transacao inicial, somente se o indicador de continuacao for maior que zero
// If nIndCont > 0
// 	cRetorno += "UNSU:" + cNSU
// 	cRetorno += SEPARADOR
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ", cRetorno)
// Return cRetorno

// /*���������������������������������������������������������������������������
// ���Programa  �TrataServ �Autor  �Vendas Clientes     � Data �  03/10/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     � Funcao que trata os servicos da Epharma                    ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Array                                                       ���
// �������������������������������������������������������������������������͹��
// ���Uso       � AP                                                         ���
// ���������������������������������������������������������������������������*/
// Method TrataServ() Class LJCFunCard
// Local nI 			:= 0			// Variavel do FOR
// Local aServico 		:= {}			// Retorno da funcao
// Local oServico						// Objeto do Produto

// aServico := LJCColecao():Colecao()

// For nI:= 1 To ::oServico:GetServs():Count()

// 	//Verifica se e servicoX
// 	If ::oServico:GetServs():Elements(nI):cTpServ == "X"
	
//   		oServico := LJCServicoXProdutoEpharma():XProdEpharma("X")
  		
// 		//Trata o servico retornado
// 		oServico:TratarServ(::oServico:GetServs():Elements(nI):cServicoX)
			
// 		//Adiciona o servico na colecao de retorno
// 		aServico:Add("X", oServico)
	
// 	EndIf

// Next nI
// LjGrvLog( Nil, " Fim da fun��o ", aServico)
// Return aServico

// /*���������������������������������������������������������������������������
// ���Programa  �LjProd()  �Autor  �Microsiga           � Data �  09/11/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     � Monta a lista dos produtos vendidos                        ���
// ���          �                                                            ���
// �������������������������������������������������������������������������͹��
// ���Uso       � AP                                                         ���
// ���������������������������������������������������������������������������*/
// Method LjProd()	Class LJCFunCard
// Local cProd 	:= ""								// Retorno da funcao
// Local nX		:= 0								// Variavel do For
// Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
// Local nQtdeMed	:= 0								// Quantidade de medicamentos
// Local cAux		:= ""								// Variavel auxiliar

// LjGrvLog( Nil, " Inicio da fun��o ")
// LjGrvLog( Nil, " Par�metros [Num. Autoriza��o | Num. Cupom] ", {::nNumAutori , Val(::cNumCupom)})
// cProd := Alltrim( Str( ::nNumAutori ) ) + SEPARADOR +  Alltrim( StrZero( Val(::cNumCupom) , 6))

// For nX := 1 To nProd
	
// 	If ::oProdAutor:oProdutos:Elements(nX):nQtdeComp > 0
		
// 		nQtdeMed++	
		
// 		cAux += Alltrim(::oProdAutor:oProdutos:Elements(nX):cCodProdut) + SEPARADOR + ;
// 				Alltrim( Str( ::oProdAutor:oProdutos:Elements(nX):nQtdeComp ) ) + SEPARADOR
		
// 		LjGrvLog( Nil, " Existe Produto Vendido ", cAux)
// 	EndIf
	
// Next nX

// cProd := cProd + SEPARADOR + Alltrim( Str( nQtdeMed ) ) + SEPARADOR + cAux
// LjGrvLog( Nil, " Fim da fun��o - Retorno [cProd]", cProd)
// Return cProd

// /*���������������������������������������������������������������������������
// ���Metodo    �SlCancDat �Autor  �Vendas Clientes     � Data �  28/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em solicitar a data da transacao.               ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method SlCancDat() Class LJCFunCard
	
// Local lRetorno 	:= .F.					//Variavel de retorno da funcao
// Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

// //Solicita a data da transacao
// lRetorno := ::CapDadTela(STR0010, "A", 8, 8, STR0011, @cRetorno)//"Data";"Data (DDMMAAAA)"
	
// //Atribui o conteudo digitado
// If lRetorno
// 	::cDataCanc := cRetorno
// EndIf

// LjGrvLog( Nil, " Fim da fun��o", lRetorno)

// Return lRetorno

// /*���������������������������������������������������������������������������
// ���Metodo    �SlCancDat �Autor  �Vendas Clientes     � Data �  28/09/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em solicitar a data da transacao.               ���
// �������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                        ���
// �������������������������������������������������������������������������͹��
// ���Parametros�														      ���
// �������������������������������������������������������������������������͹��
// ���Retorno   �Logico                                                      ���
// ���������������������������������������������������������������������������*/
// Method SlCancPdv() Class LJCFunCard
// Local lRetorno 	:= .F.					//Variavel de retorno da funcao
// Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

// //Solicita a data da transacao
// lRetorno := ::CapDadTela(STR0012, "A", 1, 4, STR0013, @cRetorno)//"PDV";"Numero do PDV"
	
// If lRetorno
// 	//Atribui o conteudo digitado
// 	::cNumPdv := StrZero( Val( cRetorno ), 4)
// EndIf

// LjGrvLog( Nil, " Fim da fun��o ", lRetorno)

// Return lRetorno

// /*����������������������������������������������������������������������������
// ���Metodo    �PrepAutCanc�Autor  �Vendas Clientes     � Data �  28/09/07   ���
// ��������������������������������������������������������������������������͹��
// ���Desc.     �Responsavel em preparar os dados para o cancelamento.        ���
// ��������������������������������������������������������������������������͹��
// ���Uso       �SigaLoja / FrontLoja                                         ���
// ��������������������������������������������������������������������������͹��
// ���Parametros�															   ���
// ��������������������������������������������������������������������������͹��
// ���Retorno   �String                                                       ���
// ����������������������������������������������������������������������������*/
// Method PrepAutCanc() Class LJCFunCard
// Local cRetorno 	:= "" 				//Variavel de retorno do metodo

// //Numero da autorizacao
// cRetorno += AllTrim(Str(::nNSU))
// cRetorno += SEPARADOR

// //Data
// cRetorno += AllTrim(::cDataCanc)
// cRetorno += SEPARADOR

// //PDV
// cRetorno += AllTrim(::cNumPdv)
// cRetorno += SEPARADOR

// //Numero cupom
// cRetorno += AllTrim(::cNumCupom)
// cRetorno += SEPARADOR

// // Cancela a compra toda
// cRetorno += "0"

// LjGrvLog( Nil, " Fim da fun��o ", cRetorno)	
// Return cRetorno


// /*���������������������������������������������������������������������������
// ���Programa  �ProdVend  �Autor  �Vendas Clientes     � Data �  21/11/07   ���
// �������������������������������������������������������������������������͹��
// ���Desc.     � Retorna se houve produtos vendidos da PBM                  ���
// ���          �                                                            ���
// �������������������������������������������������������������������������͹��
// ���Uso       � AP                                                         ���
// ���������������������������������������������������������������������������*/
// Method PrVendido() Class LJCFunCard
// Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
// Local lRet 		:= .F.								// Retorno da Funcao
// Local nX 		:= 0								// Variavel do FOR

// For nX := 1 To nProd
	
// 	If ::oProdAutor:oProdutos:Elements(nX):nQtdeComp > 0
	
// 		lRet := .T.
		
// 	EndIf
	
// Next nX
// LjGrvLog( Nil, " Fim da fun��o - Existem Produtos Vendidos?", lRet)
// Return lRet