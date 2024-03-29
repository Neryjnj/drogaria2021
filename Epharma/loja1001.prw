#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1001.CH"
  
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ipo de transacoes enviadas�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
#DEFINE CONSULTA 		1
#DEFINE VENDA	 		2
#DEFINE CANCELAMENTO	3
#DEFINE SEPARADOR 		CHR(0)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘eios para buscar pre-autorizacao�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
#DEFINE CARTAOMAG		1
#DEFINE CARTAO			2
#DEFINE AUTORIZACAO		3

User Function LOJA1001 ; Return  			// "dummy" function - Internal Use

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇튏lasse    쿗JCEPharma       튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿎lasse responsavel por tratar o processo PBM Epharma.				 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Class LJCEPharma From LJCSitefDireto
	
	Data cDataCanc													//Data da transacao para o cancelamento
	Data cNumPdv													//Numero do PDV que fez a venda
	Data nNSU														//Nsu da venda    
	Data cTpDoc														//Tipo do Documento

	Method EPharma()												//Metodo construtor
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
	
	//Metodos internos
	Method SelTpAutor()												//Metodo que ira solicitar como sera feito a recuperacao da pre-autorizacao
	Method TrataAutor()												//Metodo que ira solicitar o numero da autorizacao
	Method PrepPreAut(nIndCont, cNSU)								//Metodo que ira montar os dados para recuperacao da pre-autorizacao
	Method BuscPreAut() 											//Metodo de busca de pre-autorizacao
	Method TrataServ(oServEsp)										//Metodo que ira tratar os servicos especificos da TrnCentre
	Method LjProd()													//Confirma monta a lista de produtos vendidos
	Method SlCancDat()												//Metodo que ira solicitar a data que a autorizacao foi efetuada
	Method SlCancCup()												//Metodo que ira solicitar o numero do cupom fiscal da autorizacao a ser cancelada
	Method SlCancPdv()												//Metodo que ira solicitar o numero do PDV que fez a venda
	Method PrepAutCanc()											//Prepara a autorizacao para o cancelamento da venda
	Method PrVendido()												//Retorno se houve produtos vendidos
	Method TrataNSU()                                            	//Metodo que ira solicitar o numero do NSU da venda
	
EndClass

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿐Pharma   튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onstrutor da classe LJCEPharma.                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� 											   				  볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method EPharma(oClisitef) Class LJCEPharma

	::SitefDireto(oClisitef)
	
	::nRedeDest		:= 62
	::nIndTrans		:= 27
	::cDataCanc		:= ""
	::cNumCupom		:= ""
	::nNumAutori 	:= 0
	::cNumPdv		:= 0
	::nNSU			:= 0
	::cTpDoc		:= "0" //Tipo documento  -  0 - ECF, 1 - NFCe , 2 - SAT
	::oComprova:aComprovan := {}
Return Self

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿔niciaVend튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿔nicia o metodo do processo de venda.                       볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametro 쿐xpC1 (1 - cCupom) 	- Numero do cupom Fiscal.             볍�
굇�			 쿐xpC2 (2 - cOperador) - Codigo do operador.	              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method IniciaVend( cCupom, cOperador , cTpDoc ) Class LJCEPharma
Local lRetorno := .T.		//Retorno do Metodo

Default cTpDoc := ""

LjGrvLog( cCupom, " Inicio da fun豫o - [cCupom | cOperador | cTpDoc]", {cCupom,cOperador,cTpDoc}, .T. )
::cNumCupom     := cCupom
::nCodOper      := Val(cOperador)
::cTpDoc		:= cTpDoc

//Solicita o numero da autorizacao
lRetorno := ::TrataAutor()

//Carrega os produtos da pre-autorizacao
If lRetorno
	LjGrvLog( cCupom, " Antes de BuscPreAut" )
    lRetorno := ::BuscPreAut()
    LjGrvLog( cCupom, " Depois de BuscPreAut", lRetorno )
EndIf
	
LjGrvLog( cCupom, " Fim da fun豫o - Retorno:", lRetorno )

Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿣endProd  튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝ealiza a venda do Produto.                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - cCodBarra) - Codigo de barras do produto.        볍�
굇�          쿐xpN1	(2 - nQtde)		- Quantidade do produto.              볍�
굇�          쿐xpN2	(3 - nPrUnit)	- Preco do produto.                   볍�
굇�          쿐xpN3 (4 - nPercDesc) - Percentual de desconto do produto.  볍�
굇�          쿐xpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method VendProd(cCodBarra	, nQtde		, nPrUnit	, nPercDesc, ;
				lItemPbm	, lPrioPbm	) Class LJCEPharma
	
Local lRet 		:= .F.		//Retorno da funcao
Local cLogProd	:= ""

Default lItemPbm:= .F.		//Define se a venda do produto foi realizada pela PBM

LjGrvLog( NIL, " Inicio da fun豫o " )

cCodBarra := Alltrim(cCodBarra)
cLogProd  := cCodBarra	
cCodBarra := Padl(cCodBarra, 13, "0")

//Verifica se o produto existe nos produtos autorizados (loja1003)
If ::oProdAutor:ExisteProd(cCodBarra)
	//Verifica se o produto pode ser vendido (loja1003)
	If ::oProdAutor:PodeVender(cCodBarra, nQtde)
		//Calcula o valor liquido da loja
		nPrcLiqLj := nPrUnit - Round((nPrUnit) * (nPercDesc / 100), 2)
		//Busca o produto na pre-autorizacao
		oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
		If nPrcLiqLj > oProdAut:nVlUnVenda
			//obtemos o percentual de desconto que sera aplicado ao item
			nPercDesc := ::oGlobal:Funcoes():CalcValor((nPrUnit - (oProdAut:nVlUnVenda + oProdAut:nVlRepasse)) / nPrUnit, 100, 3, 2)
			lItemPbm	:= .T.
			lRet		:= .T.
			LjGrvLog( NIL, " Obtido valor de desconto do produto [C�digo de barras: " + cLogProd + "]  - Valor Desconto: ",nPercDesc )
		Else
			lRet := .T.
		Endif
    Else
    	lRet := .F.
    	LjGrvLog( NIL, " N�o pode vender o produto [C�digo de barras: " + cLogProd + "]  " )
    EndIf
Else
	LjGrvLog( NIL, " N�o encontrou o produto [C�digo de barras: " + cLogProd + "]  para ser autorizado " )
	lRet := .T.
EndIf

LjGrvLog( NIL, " Fim da Fun豫o ", lRet )
	
Return lRet

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿎ancProd  튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝ealiza o cancelamento do produto vendido no PBM.           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - cCodBarra) - Codigo de barras do produto.        볍�
굇�          쿐xpN1	(2 - nQtde)		- Quantidade do produto.              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method CancProd( cCodBarra, nQtde ) Class LJCEPharma
Local lRet 		:= .T.		//Retorno da funcao
Local oProdAut	:= Nil		//Objeto com os produtos autorizados

LjGrvLog( Nil, " Inicio da fun豫o - [cCodBarra / nQtde]", {cCodBarra,nQtde})
cCodBarra := Alltrim(cCodBarra)	
cCodBarra := Padl(cCodBarra, 13, "0")	
	
//Busca o produto autorizado
oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)		
//Atualiza a quantidade comprada do produto autorizado
::oProdAutor:AtuQtComp(cCodBarra, (nQtde * -1) )
//Atualiza o valor do subsidio
::oProdVend:AltVlSub((oProdAut:nVlRepasse * nQtde) * -1)

LjGrvLog( Nil, " Fim da fun豫o ", lRet)
Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿑inalVend 튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑inaliza a venda no PBM.                                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�													          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
---------------------------------------------------------------------------*/
Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCEPharma
Local lRetorno := .T.		//Retorno da funcao
Local cDadosAdm	:= ""

Default cDoc := "" //Numero documento Fiscal
Default cSerie := "" //Serie do documento Fiscal
Default cKeyDoc := "" //Chave do documento Fiscal 

LjGrvLog( Nil, " Inicio da fun豫o ")
LjGrvLog( Nil, " Par�metros [cDoc | cSerie | cKeyDoc] ", {cDoc,cSerie,cKeyDoc})

cDadosAdm := SEPARADOR + "ParamAdic={TipoDocFiscal="+::cTpDoc +; //Tipo de documento fiscal usado na venda:0 Cupom Fiscal 1 NFC-e 2 SAT
             IIF(::cTpDoc <> "0", ";ChaveAcessoDocFiscal="+ AllTrim(cKeyDoc), "")+"}"//1-  44 N�mero da chave de acesso (para NFC-e ou SAT).

LjGrvLog( Nil, " Comando enviado ao Sitef [" + cDadosAdm + "]")

If ::PrVendido()
	LjGrvLog( Nil, " Antes do m�todo EnvTrans ")
	lRetorno := ::EnvTrans(::LjProd() + cDadosAdm, VENDA, 0)
	LjGrvLog( Nil, " Depois do m�todo EnvTrans ",lRetorno)

	If lRetorno
		//Processa o retorno da transacao
		LjGrvLog( Nil, " Antes do m�todo PcRetSitef ")
		lRetorno := ::PcRetSitef()
		LjGrvLog( Nil, " Depois do m�todo PcRetSitef ", lRetorno)
	EndIf	

	//Grava o arquivo de controle
	If lRetorno
		::GrvArqTef()
	EndIf
EndIf

LjGrvLog( Nil, " Fim da fun豫o ", lRetorno)
	
Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿍uscaRel  튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Retorna o relatorio a ser impresso, na finalizacao da ven- 볍�
굇�          � da no processo da PBM.                                     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�													          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿌rray                                                       볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method BuscaRel() Class LJCEPharma
Local aCupom := {}

aCupom := ::oComprova:aComprovan
LjGrvLog( Nil, " Retorno do Relat�rio do E-pharma a ser impresso ", aCupom)

Return aCupom

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿍uscaSubs 튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿍usca o valor do subsidio.								  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�													          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿙umerico                                                    볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method BuscaSubs() Class LJCEPharma
Local nRetVal := 0					//Retorna o valor do subisidio

//Busca o valor do subsidio nos produtos vendidos
nRetVal := ::oProdVend:BusVlSub()		
	
Return nRetVal

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿎onfProd  튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onfirma o produto vendido.								  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�													          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
굇勁袴袴袴袴曲袴袴袴箇袴袴袴藁袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇� DATA     � BOPS 튡rogram.튍LTERACAO                                   볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method ConfProd( cCodBarra, nQtde, lOk ) Class LJCEPharma
Local lRet 		:= .T.		//Retorno da funcao
Local oProdAut	:= Nil		//Objeto com os produtos autorizados

LjGrvLog( Nil, " Inicio da Fun豫o")

cCodBarra := Alltrim(cCodBarra)
LjGrvLog( Nil, " Produto a ser confirmado - [C�digo]", cCodBarra)	
cCodBarra := Padl(cCodBarra, 13, "0")	
	
If lOk
	//Busca o produto autorizado
	oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
	//Atualiza a quantidade comprada do produto autorizado
	::oProdAutor:AtuQtComp(cCodBarra, nQtde)
	//Atualiza o valor do subsidio
	::oProdVend:AltVlSub(oProdAut:nVlRepasse * nQtde)
EndIf

LjGrvLog( Nil, " Fim da Fun豫o")	
Return lRet

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿎onfVend  튍utor  쿣endas Clientes     � Data �  06/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onfirma a venda PBM.     								  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpL1 (1 - lConfirma) - Indica se a transacao sera confirma-볍�
굇�			 쿭a ou desfeita.       							          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   �		                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method ConfVend(lConfirma) Class LJCEPharma

Default lConfirma := .F.

LjGrvLog( Nil, " Inicio da Fun豫o")
LjGrvLog( Nil, " Confirma ou Desfaz a Venda?",lConfirma)

//Confirma ou desfaz a venda
::FimTrans(lConfirma)

//Apaga o arquivo de controle
::ApagArqTef()

LjGrvLog( Nil, " Fim da Fun豫o")
Return Nil

/*---------------------------------------------------------------------------
굇튝etodo    쿎ancPBM   튍utor  쿣endas Clientes     � Data �  21/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎ancela a transacao da PBM.                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
---------------------------------------------------------------------------*/
Method CancPBM() Class LJCEPharma
Local lRetorno := .F.							//Variavel de retorno do metodo

LjGrvLog( Nil, " Inicio da fun豫o - Cancelamento",,.T.)

//Solicita o numero do NSU da venda
lRetorno := ::TrataNSU()
LjGrvLog( Nil, " Captura NSU da Transa豫o", lRetorno)

If lRetorno
	//Solicita data da venda
	lRetorno := ::SlCancDat()
	LjGrvLog( Nil, " Captura Data da Transa豫o", lRetorno)
EndIf

If lRetorno
	// Solicita o numero do PDV que fez a venda
	lRetorno := ::SlCancPdv()
	LjGrvLog( Nil, " Captura PDV da Transa豫o", lRetorno)
EndIf

If lRetorno
	//Solicita o numero do cupom fiscal da autorizacao
	lRetorno := ::SlCancCup()
	LjGrvLog( Nil, " Captura Numero do Documento da Transa豫o", lRetorno)
EndIf

If lRetorno
	//Envia a transacao de cancelamento
	lRetorno := ::EnvTrans(::PrepAutCanc(), CANCELAMENTO, 11)
	LjGrvLog( Nil, " Envia o comando de cancelamento da Transa豫o", lRetorno)
EndIf

If lRetorno
	//Processa o retorno da transacao
	lRetorno := ::PcRetSitef()
	LjGrvLog( Nil, " Processamento do retorno do cancelamento ", lRetorno)
EndIf

If lRetorno
	//Gravar arquivo de controle de transacao TEF
	::GrvArqTef()
EndIf

LjGrvLog( Nil, " Fim da fun豫o - Cancelamento")

Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿞lCancCup 튍utor  쿣endas Clientes     � Data �  09/11/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em solicitar o numero do cupom da transacao.    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method SlCancCup() Class LJCEPharma
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
Local nTam		:= 6

LjGrvLog( Nil, " Inicio da Fun豫o")

//Solicita o numero do cupom fiscal
lRetorno := ::CapDadTela(STR0014, "A", 1, nTam, STR0015, @cRetorno) //"Cupom";"N�mero do cupom"
LjGrvLog( Nil, " Solicitado numero do documento ",lRetorno)
	
//Atribui o conteudo digitado
If lRetorno
	::cNumCupom := cRetorno
	LjGrvLog( Nil, " Numero do Doc Digitado",cRetorno)
EndIf

LjGrvLog( Nil, " Fim da fun豫o ",lRetorno)
Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿟rataAutor튍utor  쿣endas Clientes     � Data �  02/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em solicitar o numero da autorizacao.           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method TrataAutor() Class LJCEPharma  
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

LjGrvLog( Nil, " Inicio da Fun豫o")

//Busca o numero da autorizacao
lRetorno := ::CapDadTela(STR0001, "N", 1, 12, STR0002, @cRetorno)//"Autoriza豫o";"N�mero da autoriza豫o"
LjGrvLog( Nil, " Busca numero da autoriza豫o ",lRetorno)

//Atribui ao objeto o conteudo digitado
If lRetorno
	::nNumAutori := Val(cRetorno)
	LjGrvLog( Nil, " Numero da autoriza豫o",Val(cRetorno))
EndIf

LjGrvLog( Nil, " Fim da fun豫o ",lRetorno)
Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿟rataAutor튍utor  쿣endas Clientes     � Data �  02/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em solicitar o numero do NSU da venda.          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method TrataNSU() Class LJCEPharma  
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

LjGrvLog( Nil, " Inicio da Fun豫o")

//Captura o numero do NSU da venda
lRetorno := ::CapDadTela(STR0016, "N", 1, 12, STR0017, @cRetorno)//"Autoriza豫o";"N�mero da autoriza豫o"
LjGrvLog( Nil, " Busca numero da NSU ",lRetorno)

//Atribui ao objeto o conteudo digitado
If lRetorno
	::nNSU := Val(cRetorno)
	LjGrvLog( Nil, " Numero da NSU",Val(cRetorno))
EndIf

LjGrvLog( Nil, " Fim da fun豫o ",lRetorno)
Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿍uscPreAut튍utor  쿣endas Clientes     � Data �  02/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em buscar os produtos da pre-autorizacao.       볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method BuscPreAut() Class LJCEPharma
Local lRetorno 	:= .T.					//Variavel de retorno da funcao
Local aServico	:= Nil					//Array com os servicos retornados

//Envia a transacao para carregar os produtos da pre-autorizacao
lRetorno := ::EnvTrans( Alltrim(Str(::nNumAutori) ) , CONSULTA, 0)

If lRetorno
	//Processa o retorno da transacao
	lRetorno := ::PcRetSitef()
EndIf	
	
If lRetorno
	//Trata o servico retornado	
	aServico := ::TrataServ()

    //Valida se retornou o servico
	If aServico:Count() > 0
		//Busca o servico
		oXProdEph := aServico:Elements(1)
		
		//Atribui ao objeto de produtos autorizados os produtos da pre-autorizacao
		::oProdAutor:oProdutos := oXProdEph:BuscaProd()
	Else
		//ServicoX de produto nao retornado
		MsgAlert(STR0008,"EPHARMA") //"Lista de produtos EPHARMA n�o retornada no servicoX"
		lRetorno := .F.
	EndIf
Else
	//Problemas ao processar servicos
	lRetorno := .F.		
EndIf

LjGrvLog( Nil, " Fim da fun豫o - Pr�-Autoriza豫o OK?", lRetorno)

Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿛repPreAut튍utor  쿣endas Clientes     � Data �  02/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em preparar os dados para recuperacao da pre-   볍�
굇�			 쿪utorizacao.											      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpN1 (1 - nIndCont) - Indicador de continuacao de produto. 볍�
굇�			 쿐xpC1 (2 - cNSU) 	   - Numero do NSU. 					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method PrepPreAut(nIndCont, cNSU) Class LJCEPharma
Local cRetorno := "" 				//Variavel de retorno do metodo
	
//Monta os dadosTx padrao das transacoes
cRetorno := ::RetTxPad(nIndCont)

//Nsu da transacao inicial, somente se o indicador de continuacao for maior que zero
If nIndCont > 0
	cRetorno += "UNSU:" + cNSU
	cRetorno += SEPARADOR
EndIf

LjGrvLog( Nil, " Fim da fun豫o ", cRetorno)
Return cRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿟rataServ 튍utor  쿣endas Clientes     � Data �  03/10/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Funcao que trata os servicos da Epharma                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿌rray                                                       볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method TrataServ() Class LJCEPharma
Local nI 			:= 0			// Variavel do FOR
Local aServico 		:= {}			// Retorno da funcao
Local oServico						// Objeto do Produto

aServico := LJCColecao():Colecao()

For nI:= 1 To ::oServico:GetServs():Count()

	//Verifica se e servicoX
	If ::oServico:GetServs():Elements(nI):cTpServ == "X"
	
  		oServico := LJCServicoXProdutoEpharma():XProdEpharma("X")
  		
		//Trata o servico retornado
		oServico:TratarServ(::oServico:GetServs():Elements(nI):cServicoX)
			
		//Adiciona o servico na colecao de retorno
		aServico:Add("X", oServico)
	
	EndIf

Next nI
LjGrvLog( Nil, " Fim da fun豫o ", aServico)
Return aServico

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿗jProd()  튍utor  쿘icrosiga           � Data �  09/11/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Monta a lista dos produtos vendidos                        볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method LjProd()	Class LJCEPharma
Local cProd 	:= ""								// Retorno da funcao
Local nX		:= 0								// Variavel do For
Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
Local nQtdeMed	:= 0								// Quantidade de medicamentos
Local cAux		:= ""								// Variavel auxiliar

LjGrvLog( Nil, " Inicio da fun豫o ")
LjGrvLog( Nil, " Par�metros [Num. Autoriza豫o | Num. Cupom] ", {::nNumAutori , Val(::cNumCupom)})
cProd := Alltrim( Str( ::nNumAutori ) ) + SEPARADOR +  Alltrim( StrZero( Val(::cNumCupom) , 6))

For nX := 1 To nProd
	
	If ::oProdAutor:oProdutos:Elements(nX):nQtdeComp > 0
		
		nQtdeMed++	
		
		cAux += Alltrim(::oProdAutor:oProdutos:Elements(nX):cCodProdut) + SEPARADOR + ;
				Alltrim( Str( ::oProdAutor:oProdutos:Elements(nX):nQtdeComp ) ) + SEPARADOR
		
		LjGrvLog( Nil, " Existe Produto Vendido ", cAux)
	EndIf
	
Next nX

cProd := cProd + SEPARADOR + Alltrim( Str( nQtdeMed ) ) + SEPARADOR + cAux
LjGrvLog( Nil, " Fim da fun豫o - Retorno [cProd]", cProd)
Return cProd

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿞lCancDat 튍utor  쿣endas Clientes     � Data �  28/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em solicitar a data da transacao.               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method SlCancDat() Class LJCEPharma
	
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

//Solicita a data da transacao
lRetorno := ::CapDadTela(STR0010, "A", 8, 8, STR0011, @cRetorno)//"Data";"Data (DDMMAAAA)"
	
//Atribui o conteudo digitado
If lRetorno
	::cDataCanc := cRetorno
EndIf

LjGrvLog( Nil, " Fim da fun豫o", lRetorno)

Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튝etodo    쿞lCancDat 튍utor  쿣endas Clientes     � Data �  28/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em solicitar a data da transacao.               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�														      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method SlCancPdv() Class LJCEPharma
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

//Solicita a data da transacao
lRetorno := ::CapDadTela(STR0012, "A", 1, 4, STR0013, @cRetorno)//"PDV";"Numero do PDV"
	
If lRetorno
	//Atribui o conteudo digitado
	::cNumPdv := StrZero( Val( cRetorno ), 4)
EndIf

LjGrvLog( Nil, " Fim da fun豫o ", lRetorno)

Return lRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇튝etodo    쿛repAutCanc튍utor  쿣endas Clientes     � Data �  28/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em preparar os dados para o cancelamento.        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�															   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿞tring                                                       볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Method PrepAutCanc() Class LJCEPharma
Local cRetorno 	:= "" 				//Variavel de retorno do metodo

//Numero da autorizacao
cRetorno += AllTrim(Str(::nNSU))
cRetorno += SEPARADOR

//Data
cRetorno += AllTrim(::cDataCanc)
cRetorno += SEPARADOR

//PDV
cRetorno += AllTrim(::cNumPdv)
cRetorno += SEPARADOR

//Numero cupom
cRetorno += AllTrim(::cNumCupom)
cRetorno += SEPARADOR

// Cancela a compra toda
cRetorno += "0"

LjGrvLog( Nil, " Fim da fun豫o ", cRetorno)	
Return cRetorno


/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿛rodVend  튍utor  쿣endas Clientes     � Data �  21/11/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Retorna se houve produtos vendidos da PBM                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method PrVendido() Class LJCEPharma
Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
Local lRet 		:= .F.								// Retorno da Funcao
Local nX 		:= 0								// Variavel do FOR

For nX := 1 To nProd
	
	If ::oProdAutor:oProdutos:Elements(nX):nQtdeComp > 0
	
		lRet := .T.
		
	EndIf
	
Next nX
LjGrvLog( Nil, " Fim da fun豫o - Existem Produtos Vendidos?", lRet)
Return lRet
