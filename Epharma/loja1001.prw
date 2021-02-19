#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1001.CH"
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipo de transacoes enviadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE CONSULTA 		1
#DEFINE VENDA	 		2
#DEFINE CANCELAMENTO	3
#DEFINE SEPARADOR 		CHR(0)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMeios para buscar pre-autorizacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE CARTAOMAG		1
#DEFINE CARTAO			2
#DEFINE AUTORIZACAO		3

User Function LOJA1001 ; Return  			// "dummy" function - Internal Use

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณLJCEPharma       บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel por tratar o processo PBM Epharma.				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณEPharma   บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCEPharma.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 											   				  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณIniciaVendบAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia o metodo do processo de venda.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpC1 (1 - cCupom) 	- Numero do cupom Fiscal.             บฑฑ
ฑฑบ			 ณExpC2 (2 - cOperador) - Codigo do operador.	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method IniciaVend( cCupom, cOperador , cTpDoc ) Class LJCEPharma
Local lRetorno := .T.		//Retorno do Metodo

Default cTpDoc := ""

LjGrvLog( cCupom, " Inicio da fun็ใo - [cCupom | cOperador | cTpDoc]", {cCupom,cOperador,cTpDoc}, .T. )
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
	
LjGrvLog( cCupom, " Fim da fun็ใo - Retorno:", lRetorno )

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณVendProd  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a venda do Produto.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cCodBarra) - Codigo de barras do produto.        บฑฑ
ฑฑบ          ณExpN1	(2 - nQtde)		- Quantidade do produto.              บฑฑ
ฑฑบ          ณExpN2	(3 - nPrUnit)	- Preco do produto.                   บฑฑ
ฑฑบ          ณExpN3 (4 - nPercDesc) - Percentual de desconto do produto.  บฑฑ
ฑฑบ          ณExpL1 (5 - lItemPbm)  - Se o item foi enviado para pbm.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method VendProd(cCodBarra	, nQtde		, nPrUnit	, nPercDesc, ;
				lItemPbm	, lPrioPbm	) Class LJCEPharma
	
Local lRet 		:= .F.		//Retorno da funcao
Local cLogProd	:= ""

Default lItemPbm:= .F.		//Define se a venda do produto foi realizada pela PBM

LjGrvLog( NIL, " Inicio da fun็ใo " )

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
			LjGrvLog( NIL, " Obtido valor de desconto do produto [C๓dgio de barras: " + cLogProd + "]  - Valor Desconto: ",nPercDesc )
		Else
			lRet := .T.
		Endif
    Else
    	lRet := .F.
    	LjGrvLog( NIL, " Nใo pode vender o produto [C๓dgio de barras: " + cLogProd + "]  " )
    EndIf
Else
	LjGrvLog( NIL, " Nใo encontrou o produto [C๓dgio de barras: " + cLogProd + "]  para ser autorizado " )
	lRet := .T.
EndIf

LjGrvLog( NIL, " Fim da Fun็ใo ", lRet )
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCancProd  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o cancelamento do produto vendido no PBM.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cCodBarra) - Codigo de barras do produto.        บฑฑ
ฑฑบ          ณExpN1	(2 - nQtde)		- Quantidade do produto.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CancProd( cCodBarra, nQtde ) Class LJCEPharma
Local lRet 		:= .T.		//Retorno da funcao
Local oProdAut	:= Nil		//Objeto com os produtos autorizados

LjGrvLog( Nil, " Inicio da fun็ใo - [cCodBarra / nQtde]", {cCodBarra,nQtde})
cCodBarra := Alltrim(cCodBarra)	
cCodBarra := Padl(cCodBarra, 13, "0")	
	
//Busca o produto autorizado
oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)		
//Atualiza a quantidade comprada do produto autorizado
::oProdAutor:AtuQtComp(cCodBarra, (nQtde * -1) )
//Atualiza o valor do subsidio
::oProdVend:AltVlSub((oProdAut:nVlRepasse * nQtde) * -1)

LjGrvLog( Nil, " Fim da fun็ใo ", lRet)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFinalVend บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFinaliza a venda no PBM.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCEPharma
Local lRetorno := .T.		//Retorno da funcao
Local cDadosAdm	:= ""

Default cDoc := "" //Numero documento Fiscal
Default cSerie := "" //Serie do documento Fiscal
Default cKeyDoc := "" //Chave do documento Fiscal 

LjGrvLog( Nil, " Inicio da fun็ใo ")
LjGrvLog( Nil, " Parโmetros [cDoc | cSerie | cKeyDoc] ", {cDoc,cSerie,cKeyDoc})

cDadosAdm := SEPARADOR + "ParamAdic={TipoDocFiscal="+::cTpDoc +; //Tipo de documento fiscal usado na venda:0 Cupom Fiscal 1 NFC-e 2 SAT
             IIF(::cTpDoc <> "0", ";ChaveAcessoDocFiscal="+ AllTrim(cKeyDoc), "")+"}"//1-  44 N๚mero da chave de acesso (para NFC-e ou SAT).

LjGrvLog( Nil, " Comando enviado ao Sitef [" + cDadosAdm + "]")

If ::PrVendido()
	LjGrvLog( Nil, " Antes do m้todo EnvTrans ")
	lRetorno := ::EnvTrans(::LjProd() + cDadosAdm, VENDA, 0)
	LjGrvLog( Nil, " Depois do m้todo EnvTrans ",lRetorno)

	If lRetorno
		//Processa o retorno da transacao
		LjGrvLog( Nil, " Antes do m้todo PcRetSitef ")
		lRetorno := ::PcRetSitef()
		LjGrvLog( Nil, " Depois do m้todo PcRetSitef ", lRetorno)
	EndIf	

	//Grava o arquivo de controle
	If lRetorno
		::GrvArqTef()
	EndIf
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ", lRetorno)
	
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณBuscaRel  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o relatorio a ser impresso, na finalizacao da ven- บฑฑ
ฑฑบ          ณ da no processo da PBM.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method BuscaRel() Class LJCEPharma
Local aCupom := {}

aCupom := ::oComprova:aComprovan
LjGrvLog( Nil, " Retorno do Relat๓rio do E-pharma a ser impresso ", aCupom)

Return aCupom

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณBuscaSubs บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca o valor do subsidio.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method BuscaSubs() Class LJCEPharma
Local nRetVal := 0					//Retorna o valor do subisidio

//Busca o valor do subsidio nos produtos vendidos
nRetVal := ::oProdVend:BusVlSub()		
	
Return nRetVal

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณConfProd  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirma o produto vendido.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
ฑฑฬออออออออออุออออออหออออออออหออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ DATA     ณ BOPS บProgram.บALTERACAO                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ConfProd( cCodBarra, nQtde, lOk ) Class LJCEPharma
Local lRet 		:= .T.		//Retorno da funcao
Local oProdAut	:= Nil		//Objeto com os produtos autorizados

LjGrvLog( Nil, " Inicio da Fun็ใo")

cCodBarra := Alltrim(cCodBarra)
LjGrvLog( Nil, " Produto a ser confirmado - [C๓digo]", cCodBarra)	
cCodBarra := Padl(cCodBarra, 13, "0")	
	
If lOk
	//Busca o produto autorizado
	oProdAut := ::oProdAutor:oProdutos:ElementKey(cCodBarra)
	//Atualiza a quantidade comprada do produto autorizado
	::oProdAutor:AtuQtComp(cCodBarra, nQtde)
	//Atualiza o valor do subsidio
	::oProdVend:AltVlSub(oProdAut:nVlRepasse * nQtde)
EndIf

LjGrvLog( Nil, " Fim da Fun็ใo")	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณConfVend  บAutor  ณVendas Clientes     บ Data ณ  06/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirma a venda PBM.     								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpL1 (1 - lConfirma) - Indica se a transacao sera confirma-บฑฑ
ฑฑบ			 ณda ou desfeita.       							          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ		                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ConfVend(lConfirma) Class LJCEPharma

Default lConfirma := .F.

LjGrvLog( Nil, " Inicio da Fun็ใo")
LjGrvLog( Nil, " Confirma ou Desfaz a Venda?",lConfirma)

//Confirma ou desfaz a venda
::FimTrans(lConfirma)

//Apaga o arquivo de controle
::ApagArqTef()

LjGrvLog( Nil, " Fim da Fun็ใo")
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณCancPBM   บAutor  ณVendas Clientes     บ Data ณ  21/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela a transacao da PBM.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CancPBM() Class LJCEPharma
Local lRetorno := .F.							//Variavel de retorno do metodo

LjGrvLog( Nil, " Inicio da fun็ใo - Cancelamento",,.T.)


//Solicita o numero do NSU da venda
lRetorno := ::TrataNSU()
LjGrvLog( Nil, " Captura NSU da Transa็ใo", lRetorno)

If lRetorno
	//Solicita data da venda
	lRetorno := ::SlCancDat()
	LjGrvLog( Nil, " Captura Data da Transa็ใo", lRetorno)
EndIf

If lRetorno
	// Solicita o numero do PDV que fez a venda
	lRetorno := ::SlCancPdv()
	LjGrvLog( Nil, " Captura PDV da Transa็ใo", lRetorno)
EndIf

If lRetorno
	//Solicita o numero do cupom fiscal da autorizacao
	lRetorno := ::SlCancCup()
	LjGrvLog( Nil, " Captura Numero do Documento da Transa็ใo", lRetorno)
EndIf

If lRetorno
	//Envia a transacao de cancelamento
	lRetorno := ::EnvTrans(::PrepAutCanc(), CANCELAMENTO, 11)
	LjGrvLog( Nil, " Envia o comando de cancelamento da Transa็ใo", lRetorno)
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

LjGrvLog( Nil, " Fim da fun็ใo - Cancelamento")

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณSlCancCup บAutor  ณVendas Clientes     บ Data ณ  09/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar o numero do cupom da transacao.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method SlCancCup() Class LJCEPharma
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela
Local nTam		:= 6

LjGrvLog( Nil, " Inicio da Fun็ใo")

//Solicita o numero do cupom fiscal
lRetorno := ::CapDadTela(STR0014, "A", 1, nTam, STR0015, @cRetorno) //"Cupom";"N๚mero do cupom"
LjGrvLog( Nil, " Solicitado numero do documento ",lRetorno)
	
//Atribui o conteudo digitado
If lRetorno
	::cNumCupom := cRetorno
	LjGrvLog( Nil, " Numero do Doc Digitado",cRetorno)
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ",lRetorno)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณTrataAutorบAutor  ณVendas Clientes     บ Data ณ  02/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar o numero da autorizacao.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method TrataAutor() Class LJCEPharma  
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

LjGrvLog( Nil, " Inicio da Fun็ใo")

//Busca o numero da autorizacao
lRetorno := ::CapDadTela(STR0001, "N", 1, 12, STR0002, @cRetorno)//"Autoriza็ใo";"N๚mero da autoriza็ใo"
LjGrvLog( Nil, " Busca numero da autoriza็ใo ",lRetorno)

//Atribui ao objeto o conteudo digitado
If lRetorno
	::nNumAutori := Val(cRetorno)
	LjGrvLog( Nil, " Numero da autoriza็ใo",Val(cRetorno))
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ",lRetorno)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณTrataAutorบAutor  ณVendas Clientes     บ Data ณ  02/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar o numero do NSU da venda.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method TrataNSU() Class LJCEPharma  
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := Nil					//Retorno do conteudo digitado para o campo da tela

LjGrvLog( Nil, " Inicio da Fun็ใo")

//Captura o numero do NSU da venda
lRetorno := ::CapDadTela(STR0016, "N", 1, 12, STR0017, @cRetorno)//"Autoriza็ใo";"N๚mero da autoriza็ใo"
LjGrvLog( Nil, " Busca numero da NSU ",lRetorno)

//Atribui ao objeto o conteudo digitado
If lRetorno
	::nNSU := Val(cRetorno)
	LjGrvLog( Nil, " Numero da NSU",Val(cRetorno))
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ",lRetorno)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณBuscPreAutบAutor  ณVendas Clientes     บ Data ณ  02/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em buscar os produtos da pre-autorizacao.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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
		MsgAlert(STR0008) //"Lista de produtos EPHARMA nใo retornada no servicoX"
		lRetorno := .F.
	EndIf
Else
	//Problemas ao processar servicos
	lRetorno := .F.		
EndIf

LjGrvLog( Nil, " Fim da fun็ใo - Pr้-Autoriza็ใo OK?", lRetorno)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณPrepPreAutบAutor  ณVendas Clientes     บ Data ณ  02/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em preparar os dados para recuperacao da pre-   บฑฑ
ฑฑบ			 ณautorizacao.											      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 (1 - nIndCont) - Indicador de continuacao de produto. บฑฑ
ฑฑบ			 ณExpC1 (2 - cNSU) 	   - Numero do NSU. 					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method PrepPreAut(nIndCont, cNSU) Class LJCEPharma
Local cRetorno := "" 				//Variavel de retorno do metodo
	
//Monta os dadosTx padrao das transacoes
cRetorno := ::RetTxPad(nIndCont)

//Nsu da transacao inicial, somente se o indicador de continuacao for maior que zero
If nIndCont > 0
	cRetorno += "UNSU:" + cNSU
	cRetorno += SEPARADOR
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ", cRetorno)
Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTrataServ บAutor  ณVendas Clientes     บ Data ณ  03/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que trata os servicos da Epharma                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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
LjGrvLog( Nil, " Fim da fun็ใo ", aServico)
Return aServico

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjProd()  บAutor  ณMicrosiga           บ Data ณ  09/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a lista dos produtos vendidos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LjProd()	Class LJCEPharma
Local cProd 	:= ""								// Retorno da funcao
Local nX		:= 0								// Variavel do For
Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
Local nQtdeMed	:= 0								// Quantidade de medicamentos
Local cAux		:= ""								// Variavel auxiliar

LjGrvLog( Nil, " Inicio da fun็ใo ")
LjGrvLog( Nil, " Parโmetros [Num. Autoriza็ใo | Num. Cupom] ", {::nNumAutori , Val(::cNumCupom)})
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
LjGrvLog( Nil, " Fim da fun็ใo - Retorno [cProd]", cProd)
Return cProd

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณSlCancDat บAutor  ณVendas Clientes     บ Data ณ  28/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar a data da transacao.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method SlCancDat() Class LJCEPharma
	
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

//Solicita a data da transacao
lRetorno := ::CapDadTela(STR0010, "A", 8, 8, STR0011, @cRetorno)//"Data";"Data (DDMMAAAA)"
	
//Atribui o conteudo digitado
If lRetorno
	::cDataCanc := cRetorno
EndIf

LjGrvLog( Nil, " Fim da fun็ใo", lRetorno)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณSlCancDat บAutor  ณVendas Clientes     บ Data ณ  28/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em solicitar a data da transacao.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ														      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method SlCancPdv() Class LJCEPharma
Local lRetorno 	:= .F.					//Variavel de retorno da funcao
Local cRetorno  := ""					//Retorno do conteudo digitado para o campo da tela

//Solicita a data da transacao
lRetorno := ::CapDadTela(STR0012, "A", 1, 4, STR0013, @cRetorno)//"PDV";"Numero do PDV"
	
If lRetorno
	//Atribui o conteudo digitado
	::cNumPdv := StrZero( Val( cRetorno ), 4)
EndIf

LjGrvLog( Nil, " Fim da fun็ใo ", lRetorno)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณPrepAutCancบAutor  ณVendas Clientes     บ Data ณ  28/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em preparar os dados para o cancelamento.        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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

LjGrvLog( Nil, " Fim da fun็ใo ", cRetorno)	
Return cRetorno


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณProdVend  บAutor  ณVendas Clientes     บ Data ณ  21/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se houve produtos vendidos da PBM                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method PrVendido() Class LJCEPharma
Local nProd		:= ::oProdAutor:oProdutos:Count()  // Total de produtos vendidos
Local lRet 		:= .F.								// Retorno da Funcao
Local nX 		:= 0								// Variavel do FOR

For nX := 1 To nProd
	
	If ::oProdAutor:oProdutos:Elements(nX):nQtdeComp > 0
	
		lRet := .T.
		
	EndIf
	
Next nX
LjGrvLog( Nil, " Fim da fun็ใo - Existem Produtos Vendidos?", lRet)
Return lRet
