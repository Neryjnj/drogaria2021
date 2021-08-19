#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} STDCondPg
Consulta no banco as condicoes de pagamento disponiveis

@param   	
@author  	Varejo
@version 	P11.8
@since   	25/03/2013

@param 		cCodCliLoj, Caractere, Codigo + Loja do Cliente da venda
@return  	aCondicoes, Array, Array de condicoes de pagamentos.

@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STDCondPg(cCodCliLoj)

Local aArea			:= GetArea()		// Armazena alias corrente
Local aCondicoes 	:= {} 				// Array de condicoes de pagamentos
Local cFormPgNot	:= ""				// Formas de Pagamentos a serem desconsideradas

Default cCodCliLoj 	:= ""				//Codigo + Loja do Cliente da venda

//Se for Cliente Padrão, não carrega a condição de pagamento do tipo (FI=Financiado)
If !Empty(cCodCliLoj) .And. (AllTrim(cCodCliLoj) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD")))
	cFormPgNot := "|" + PadR("FI",TamSX3("E4_FORMA")[1]) + "|"
EndIf

//Carrega com as condicoes gravadas no SE4
DbSelectArea("SE4")
DbSeek(xFilial("SE4"))
While !SE4->(Eof()) .AND. SE4->E4_FILIAL == xFilial("SE4")
	If !Empty(cFormPgNot) .And. SE4->E4_FORMA $ cFormPgNot
		LjGrvLog( NIL, "Venda p/ Cliente padrão, não carrega a condição de pagamento do tipo (FI=Financiado). Foi deconsiderada a Cond. Pagto (SE4): " + SE4->E4_CODIGO)
		SE4->(dbSkip())
		Loop
	EndIf
	If SE4->E4_TIPO <> "9"
		Aadd(aCondicoes, {SE4->E4_CODIGO, SubStr( SE4->E4_DESCRI, 1, 20 ), SE4->E4_FORMA, SE4->E4_TIPO, SE4->E4_DESCFIN, SE4->E4_ACRSFIN, SE4->E4_ACRES})
	EndIf
	SE4->(dbSkip())
End

RestArea(aArea)
													  
Return aCondicoes

//--------------------------------------------------------------------
/*/{Protheus.doc} STDCondPg
Consulta no banco a condicao de pagamento padrao

@author  	Leandro Lima
@version 	P12.17
@since   	21/09/2017
@return  	aCondicoes - Array de condicoes de pagamentos
/*/
//--------------------------------------------------------------------
Function STDCondPad(cCod)

Local aArea			:= GetArea()	// Armazena alias corrente
Local aCondicoes 	:= {} 			// Array de condicoes de pagamentos
Local aDiasPgChck	:= {}			// Dias da condicao de pagamento

Default cCod			:= ""

//Carrega com as condicoes gravadas no SE4
DbSelectArea("SE4")
DbSetOrder(1) //E4_FILIAL+E4_CODIGO
If DbSeek(xFilial("SE4")+cCod)
	If SE4->E4_TIPO <> "9"
		aDiasPgChck := StrTokArr( SE4->E4_COND, "," )
		Aadd(aCondicoes,{SE4->E4_CODIGO,SubStr(E4_DESCRI,1,20),E4_FORMA,E4_TIPO,E4_DESCFIN,E4_ACRSFIN,E4_ACRES,aDiasPgChck })
	EndIf	
EndIf

RestArea(aArea)
													  
Return aCondicoes

//--------------------------------------------------------------------
/*/{Protheus.doc} STDSCDPG
Persiste o campo L1_CONDPG

@param   	
@author  	Varejo
@version 	P11.8
@since   	10/06/2015
@return  	aCondicoes - Array de condicoes de pagamentos
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STDSCondPG(cInfo)

STDSPBasket("SL1", "L1_CONDPG", cInfo)

Return Nil
