#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"       
#INCLUDE "STWKITSALES.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STWKitSales
Gera a lista de códigos de produtos que compoem determinado Kit
@param	 cCodProdKit, Caractere, Codigo do produto kit.
@param	 aItensKit, Array, Array com os itens do kit de produtos.
@author  Varejo
@version P11.8
@since   16/08/2012
@return	Nil
@obs     
@sample
/*/
//--------------------------------------------------------

Function STWKitSales(cCodProdKit, aItensKit)

Local nI			:= 0			 // Contador de laço
Local nItemLine   	:= 0			 // Linha do item
Local cTypeDesc		:= "P" 			 // Tipo de desconto (percentual)
Local oModelSale  	:= STDGPBModel() // Model de venda
Local nQuantKit     := STBGetQuant() // Quantidade do Kit
local cIdItRel		:= "" 			 // Id do item relacionado.

Default cCodProdKit	:= ""
Default aItensKit   := {}
           
// Carrega lista de produtos a serem sugeridos
If Empty(aItensKit)
	aItensKit := STDKitSales(cCodProdKit)
EndIf

If Len(aItensKit) > 0

	For nI := 1 To Len(aItensKit)
		
		// Selecionados os produtos, seta a quantidade de cada produto que compoe o kit
		STBSetQuant( aItensKit[nI][3] * nQuantKit )
		
		If oModelSale:GetModel("SL2DETAIL"):Length() == 1 .AND. Empty(STDGPBasket("SL2","L2_NUM",1))
			nItemLine := 1
		Else
			nItemLine := oModelSale:GetModel("SL2DETAIL"):Length()+1
		EndIf
		
		If nI == 1 
			cIdItRel := StrZero(nItemLine,TamSx3("L2_ITEM")[1])
		EndIf	

		// Dispara o registro de item para cada produto que compoe o kit
		If !STWItemReg(nItemLine, aItensKit[nI][1],,,,aItensKit[nI][2],cTypeDesc,, ,,,,"KIT",,,,,,,,,,,,cIdItRel,,cCodProdKit)
		
			// Havendo falha no registro do item, gera nova mensagem e aborta a emissão dos demais
			STFMessage("STBKitSales", "STOP", STR0001) //"Não foi possível registrar os itens que compoem o kit."
			Exit
		EndIf
		
	Next nI
	
EndIf

Return Nil


