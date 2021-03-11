#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"

Static lIsRegKit	:= .F. // Variável utilizada para indicar se está registrando Kit de Produtos

//-------------------------------------------------------------------
/*/ {Protheus.doc} STWItemClustered
Efetua os processamentos para produtos agrupados. Chamado durante o processamento do STWItemReg.

@param   cItemCode		Quantidade do Item 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - Executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWItemClustered(aInfoItem)

Local cItemCode		:= aInfoItem[ITEM_CODIGO]		// Codigo do produto
Local cTipoProd		:= aInfoItem[ITEM_TIPO] 		// Tipo do produto
Local lRet			:= .T.							// Retorno da Funcao
Local aItensKit 	:= {}

Default aInfoItem := {}

ParamType 0 Var   	aInfoItem 	As Array	Default 	{}

If !lIsRegKit
	//Verifica se existe KIT configurado no Template de Drogaria para o produto lançado
	If ExistFunc("LjIsDro") .And. LjIsDro() .And. ExistTemplate("FRTKIT")
		aItensKit := ExecTemplate("FRTKIT",.F.,.F., { cItemCode } )
	EndIf

	//Verifica se o produto lançado é KIT de Produdos
	lIsRegKit := Len(aItensKit) > 0 .Or. ; 	// Existe KIT de Produtos do Template de Drogarias configurado (tabelas MHD e MHE).
				 cTipoProd == "KT" 			// Tipo do Produto é KIT (B1_TIPO = KT) (tabelas MEU e MEV).

	If lIsRegKit
		lRet := .F.
		STWKitSales(cItemCode,aItensKit)
		lIsRegKit := .F.
	EndIf
EndIf

Return lRet

