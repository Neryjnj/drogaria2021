#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1001.CH"
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de transacoes enviadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE CONSULTA 		1
#DEFINE VENDA	 		2
#DEFINE CANCELAMENTO	3
#DEFINE SEPARADOR 		CHR(0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Meios para buscar pre-autorizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE CARTAOMAG		1
#DEFINE CARTAO			2
#DEFINE AUTORIZACAO		3

User Function LOJA1971 ; Return  	// "dummy" function - Internal Use

/*--------------------------------------------------------------------------------
|Classe    |LJCPharmSys       |Autor  |Julio Nery     | Data |  26/03/21         |
|--------------------------------------------------------------------------------|
|Desc.     |Classe responsavel por tratar o processo PBM PharmaSystem.			 |
|--------------------------------------------------------------------------------|
|Uso       |TotvsPDV                                                    		 |
--------------------------------------------------------------------------------*/
Class LJCPharmSys From LJCSitefDireto
	
	DATA nFuncao
	DATA nValor
	DATA cCupom
	DATA cData
	DATA cHora
	DATA cOperador
	DATA cRestri
	DATA aVDLink

	Method PharmaSystem(oClisitef)						//Metodo construtor
    Method PharmSCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink)

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
/*/{Protheus.doc} PharmaSystem
Inicia PBM PharmaSystem

@param		oCLisitef, objeto do CLisitef
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		Self - Objeto
/*/
//-------------------------------------------------------------------
Method PharmaSystem(oClisitef) Class LJCPharmSys

::SitefDireto(oClisitef)

::nFuncao := 0
::nValor := 0
::cCupom := ""
::cData := ""
::cHora := ""
::cOperador:= ""
::cRestri := ""
::aVDLink := {}

Return Self

/*/{Protheus.doc} PharmSCons
	Classe de consulta de dados PharmaSystem
	@type  Class
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method PharmSCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink) Class LJCPharmSys
Local lRet := .T.

::nFuncao := nFuncao
::nValor := nValor
::cCupom := cCupom
::cData := cData
::cHora := cHora
::cOperador:= cOperador
::cRestri := cRestri
::cNumCupom := cCupom
::aVDLink := aVDLink

lRet := ::ConsPharmS()

Return lRet