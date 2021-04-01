#INCLUDE "PROTHEUS.CH"
#INCLUDE "STPOS.CH"               
#INCLUDE "STWRECEIPTTITLE.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "MSOBJECT.CH"

Static cCodCliTit		:= "" 
Static cCodLojaTit	:= ""

Function STWReceTit()
Return;	// Funcao apenas para poder compilar no robo

Class STWReceiptTitle

	Data cOperation				// OP_BAIXA("1") - Baixa de titulos / OP_ESTOR("2") - Estorno de baixa
	Data cPrefix				// Prefixo do titulo
	Data cNumber				// Numero do titulo
	Data cParcel  				// Parcela do titulo
	Data aListTitles			// Array com a lista de titulos em aberto
	Data oCustomer				// Cliente a receber
	Data oPayment				// Objeto de controle de pagamento
	Data lIsContingency			// Indica se esta trabalhando por medida de contingencia (sem conexao com a retaguarda)
	Data nValueContingency		// Valor de pagamento (somente para medida de contigencia)
	Data cCode					// Codigo
	Data cBranch				// Loja
	Data cName					// Nome do Cliente
	Data cCnpjCpf				// Cnpj/Cpf
	Data cCartao				// Codigo do Cartao
	Data cContrato				// Codigo do Contrato
	Data nTotNcc				// Valor de NCC utilizada (para estorno)
	Data dDtRec					// Data do Recebimento
	Data cHrRec					// Hora do Recebimento
	

	// Metodos do controle de recebimento
	Method STWReceiptTitle(	cCode	, cBranch, cCnpjCpf	, cPrefix	,;
							cNumber	, cParcel, cName	, cCartao	,;
							cContrato )
	Method LoadTitles()
	Method DropTitles(oMdlGrd)
	Method GetTotal(lExtrato)
	Method GetTotNCC()
	Method SetTotNCC()
	Method Print(oMdlGrd)
	Method GetReceiptArray(lExtrato)
	Method ExtractPrint()
	Method GetContingencyMode()
	Method SetContingencyMode(lValue)
	Method GetCustomer()
	Method SetCustomer(oValue)
	Method GetPayment()
	Method SetPayment(oValue)
	Method GetReverseMode()
	Method SetReverseMode(lValue)
	Method CountParcels()
	Method ReverseDropTitles()
	Method GetValueContingency()
	Method SetValueContingency(nValue)
	Method VldCustomer(cCodCli,	cLojCli, cCPF)
	
	// Metodos de parcelas
	Method GetParcSelected(nI)
	Method SetParcSelected(nI, lValue)
	Method GetParcInterest(nI)
	Method SetParcInterest(nI, nValue)
	Method GetParcDiscount(nI)
	Method GetParcIncrease(nI)
	Method SetParcDiscount(nI, nValue)
	Method GetParcMulct(nI)
	Method SetParcMulct(nI, nValue)
	Method GetParcTotal(nI)
	Method SetParcTotal(nI, nValue)
	Method ParcRecalculateTotal(nI)
	Method GetParcOrig(nI)
	Method GetParcValor(nI)

EndClass


//------------------------------------------------------------------------------   
/*/{Protheus.doc} STWReceiptTitle
Objeto responsavel pelo controle de recebimento de títulos / estornos de recebimentos
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Objeto STBReceiptTitle - Controle de recebimentos
@obs     
@sample
/*/ 
//------------------------------------------------------------------------------   
Method STWReceiptTitle(	cCode	, cBranch, cCnpjCpf	, cPrefix	,;
						cNumber	, cParcel, cName	, cCartao	,;
						cContrato ) Class STWReceiptTitle

Default cCode		:= "" 
Default cBranch 	:= "" 
Default cCnpjCpf	:= ""  
Default cPrefix		:= "" 	
Default cNumber		:= ""  
Default cParcel		:= "" 
Default cName		:= "" 
Default cCartao		:= ""
Default cContrato 	:= ""
							
Self:cOperation			:= OP_BAIXA

//Dados da parcela
Self:cPrefix			:= cPrefix
Self:cNumber			:= cNumber
Self:cParcel			:= cParcel

//Dados do cliente
Self:cCode				:= cCode
Self:cBranch			:= cBranch
Self:cCnpjCpf			:= cCnpjCpf
Self:cCartao			:= cCartao
Self:cContrato			:= cContrato

Self:aListTitles		:= {}
Self:nValueContingency 	:= 0
Self:lIsContingency		:= .F.
Self:nTotNcc			:= 0
Self:cName				:= cName


Self:dDtRec	:= Ctod("")			//Data do Recebimento
Self:cHrRec	:= ""			// Hora do Recebimento

		
Return Self


//------------------------------------------------------------------------------   
/*/{Protheus.doc} CountParcels
Retorna a quantidade de parcelas
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Retorna a quantidade de parcelas
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method CountParcels() Class STWReceiptTitle

Local nRetorno := 0	// Retorno da funcao

If Len(Self:aListTitles) >= 4
	nRetorno := Len(Self:aListTitles[4])
EndIf

Return nRetorno


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcSelected
Verifica a selecao da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Lista de Titulos
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcSelected(nI) Class STWReceiptTitle
Local lValor := .F.

Default nI := 0

If nI > 0
	lValor := Self:aListTitles[4][nI][TIT_SELE]
EndIf

Return lValor


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetParcSelected
Altera a selecao da parcela
@param	 nI		Posicao da parcela no array aListTitles
@param	 lValue	Novo valor
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetParcSelected(nI, lValue) Class STWReceiptTitle

Default nI 		:= 0
Default lValue  	:= .F.

If nI > 0 .AND. ValType(Self:aListTitles[4][nI][TIT_SELE]) == "L"
	Self:aListTitles[4][nI][TIT_SELE] := lValue
EndIf
	
Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetParcInterest
Altera o valor de Juros da parcela
@param	 nI		Posicao da parcela no array aListTitles
@param	 nValue	Novo valor
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetParcInterest(nI, nValue) Class STWReceiptTitle

Default nI 		:= 0
Default nValue  	:= 0

If nI > 0
	Self:aListTitles[4][nI][TIT_JURO] := nValue
EndIf	

Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcInterest
Retorna o valor de Juros da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Valor de Juros da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcInterest(nI) Class STWReceiptTitle

Local nValor := 0

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_JURO]

EndIf

Return nValor
//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcOrig
Retorna o valor de Juros da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  leandro.lima
@version P11.8
@since   14/04/2016
@return	 Valor original do titulo
/*/
Method GetParcOrig(nI) Class STWReceiptTitle
Local nReturn	:= 0 
Default nI 		:= 0

If nI > 0
	nReturn := Self:aListTitles[4][nI][TIT_SALD] 
Else
	nReturn := 0
EndIf
	
Return nReturn


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetParcMulct
Altera o valor de Multa da parcela
@param	 nI		Posicao da parcela no array aListTitles
@param	 nValue	Novo valor
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetParcMulct(nI, nValue) Class STWReceiptTitle

Default nI 		:= 0
Default nValue  	:= 0

If nI > 0
	Self:aListTitles[4][nI][TIT_MULT] := nValue
EndIf	

Return Nil
       

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcMulct
Retorna o valor de Multa da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Valor de Multa da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcMulct(nI) Class STWReceiptTitle
Local nValor := 0

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_MULT]
EndIf

Return nValor


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetParcDiscount
Altera o valor de Desconto da parcela
@param	 nI		Posicao da parcela no array aListTitles
@param	 nValue	Novo valor
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetParcDiscount(nI, nValue) Class STWReceiptTitle

Default nI 		:= 0
Default nValue  	:= 0

If nI > 0
	Self:aListTitles[4][nI][TIT_DESC] := nValue
EndIf	

Return Nil
                   

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcDiscount
Retorna o valor de Desconto da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Valor de Desconto da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcDiscount(nI) Class STWReceiptTitle
Local nValor := 0

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_DESC]
EndIf

Return nValor

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcIncrease
Retorna o valor de Acrescimo da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Lucas Novais	
@version P12.1.17
@since   30/10/2017
@return	 Valor de acrescimo da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcIncrease(nI) Class STWReceiptTitle
Local nValor := 0

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_ACRS]
EndIf

Return nValor

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcTotal
Retorna o valor Total da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Valor Total da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcTotal(nI) Class STWReceiptTitle

Local nValor := 0   	//Retorno

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_RECE]
EndIf

Return nValor
          

//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetParcTotal
Altera o valor Total da parcela
@param	 nI		Posicao da parcela no array aListTitles
@param	 nValue	Novo valor
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetParcTotal(nI, nValue) Class STWReceiptTitle

Default nI 		:= 0
Default nValue  	:= 0

If nI > 0
	Self:aListTitles[4][nI][TIT_RECE] := nValue
EndIf
	
Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} ParcRecalculateTotal
Atualiza o valor a receber da parcela calculando multa, juros e desconto
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method ParcRecalculateTotal(nI) Class STWReceiptTitle

Default nI 		:= 0

If nI > 0
	Self:SetParcTotal(nI, Self:aListTitles[4][nI][TIT_VALO] + Self:aListTitles[4][nI][TIT_MULT] + Self:aListTitles[4][nI][TIT_JURO] - Self:aListTitles[4][nI][TIT_DESC])
EndIf	

Return Nil


/*/{Protheus.doc} GetContingencyMode()
Verifica se esta trabalhando em modo NORMAL ou em MODO DE CONTINGENCIA
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 .T. Quando esta em MODO DE CONTINGENCIA / .F. Quando estiver em MODO NORMAL
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetContingencyMode() Class STWReceiptTitle
Return Self:lIsContingency


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetContingencyMode()
Alterna entre modo NORMAL / e MODO DE CONTINGENCIA
@param	 lValue	.T. para modo contingencia / .f. para modo normal
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetContingencyMode(lValue) Class STWReceiptTitle

Default lValue  	:= .F.

Self:lIsContingency := lValue

Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetCustomer()
Retorna o cliente
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Objeto cliente
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetCustomer() Class STWReceiptTitle
Return Self:oCustomer


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetCustomer()
Altera o cliente da operacao
@param	oValue	Novo cliente
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetCustomer(oValue) Class STWReceiptTitle

Default oValue 		:= Nil

Self:oCustomer := oValue

Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetPayment()
Retorna o objeto de pagamento
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Objeto de pagamento
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetPayment() Class STWReceiptTitle
Return Self:oPayment


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetPayment()
Altera o objeto de pagamento da operacao
@param	oValue	Novo objeto de pagamento
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetPayment(oValue) Class STWReceiptTitle

Default oValue 		:= Nil

Self:oPayment := oValue

Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetReverseMode()
Retorna se o MODO ESTORNO esta ativado
@param	oValue	Novo objeto de pagamento
@author  Varejo
@version P11.8
@since   14/08/2012
@return	.T. quando estiver em modo ESTORNO / .F. quando estiver em modo RECEBIMENTO
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetReverseMode() Class STWReceiptTitle
Return (Self:cOperation == OP_ESTOR)


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetTotal
Alterna entre modo RECEBIMENTO / ESTORNO DE RECEBIMENTO
@param	lValue	.T. para ativar modo de ESTORNO / .F. para ativar o modo RECEBIMENTO
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetReverseMode(lValue) Class STWReceiptTitle

Default lValue 		:= .F.

If lValue
	// Define que a operacao realizada sera Estorno
	Self:cOperation := OP_ESTOR
Else
	// Define que a operacao realizada sera Baixa de Titulos
	Self:cOperation := OP_BAIXA
EndIf
Return Nil

//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetTotNCC
Seta o valor de NCC utilizada.
@param	
@author  Varejo
@version P11.8
@since   29/06/2015
@return nRet	Valor de NCC utilizada
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetTotNCC(nValor) Class STWReceiptTitle
Self:nTotNcc := nValor
Return Nil

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetTotNCC
Retorna o valor de NCC utilizada.
@param	
@author  Varejo
@version P11.8
@since   29/06/2015
@return nRet	Valor de NCC utilizada
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetTotNCC() Class STWReceiptTitle
Local nRet := Self:nTotNcc
Return nRet



//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetValueContingency
Obtem o valor de contingencia
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Valor de contingencia
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetValueContingency() Class STWReceiptTitle
Return Self:nValueContingency


//------------------------------------------------------------------------------   
/*/{Protheus.doc} SetValueContingency
Altera o valor de contingencia
@param	nValue	Novo valor de contigencia
@author  Varejo
@version P11.8
@since   14/08/2012
@return Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method SetValueContingency(nValue) Class STWReceiptTitle

Default nValue 		:= 0

Self:nValueContingency := nValue

Return Nil


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetTotal
Retorna o total de todas as parcelas selecionadas
@param	 lExtrato Se é extrato
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Total de todas as parcelas selecionadas
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetTotal(lExtrato) Class STWReceiptTitle

Local nRetorno 		:= 0	// Retorno do funcao
Local nI 			:= 0	// Contador

Default lExtrato	:= .F.	// Se for extrato nao verifica se a parcela foi selecionada

If Self:lIsContingency
	nRetorno := Self:nValueContingency
Else
	For nI := 1 To Len(Self:aListTitles[4])
		If lExtrato .OR. Self:aListTitles[4][nI][TIT_SELE]
			nRetorno += Self:aListTitles[4][nI][TIT_RECE]
		EndIf
	Next nI
EndIf

Return nRetorno


//------------------------------------------------------------------------------   
/*/{Protheus.doc} Print
Carrega o comprovante e imprime os documentos
@param   oMdlGrd - Model principal
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 .T. quando impressao realizada com sucesso / .F. caso de falha
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method Print(oMdlGrd) Class STWReceiptTitle

Local lRetorno			:= .F.				// Retorno da funcao
Local cTextoComprovante	:= ""				// Texto completo do comprovante a ser enviado para a impressora
Local cTotalizador		:= ""				// Totalizador recebimento / estorno de estorno de recebimento de titulos
Local aRet				:= {}				// Retorno evento
Local cForma			:= ""				// Forma pgto
Local aValues			:= Array(11)		// Array com valores da sangria em caso de estorno
Local lEmitNfce			:= Iif(ExistFunc("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
Local lGuil				:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
Local oTEF20			:= IIF(ValType(STBGetTef()) == 'O', STBGetTef(), STBGetChkRet())//Objeto do TEF ativo
Local nVlTotal			:= 0				// Valor a ser impresso quando estorno
Local nRet				:= 0
Local lSTRECTIT			:= ExistBlock("STRECTIT") //ponto de entrada para customizar impressão dos titulos
Local nRecVias    		:= SuperGetMV("MV_RECVIAS",,2)	//numero de vias para impressao do comprovante de Recebimento
Local cTxtCNF			:= ""				//Texto que sera enviado para a impressora nao fiscal
Local nI				:= 0				// Contador
Local lTemTEF			:= .F.				// Verifica se foi impresso o comprovante TEF	
Local aParamPE		:= {} //Parametros do ponto de entrada
Local nX				:= 0

Default oMdlGrd := Nil

If Self:GetTotal() > 0

	CursorWait()

	STFMessage( ProcName(0) , "ALERT", STR0023 ) //"Imprimindo comprovantes do recebimento" 
	STFShowMessage(ProcName(0))

	cTextoComprovante := GetTextArray(Self:GetReceiptArray())

	//Ponto de Entrada para customização do comprovante de recebimento de titulos
	If lSTRECTIT
		aParamPE := {cTextoComprovante,Self:aListTitles, Self:lIsContingency, Self:cPrefix, ;
					   Self:cNumber, Self:cParcel, Self:nValueContingency, Self:cCnpjCpf, ;
						Self:cCode, Self:cBranch, Self:cName, Self:dDtRec, ;
						Self:cHrRec}
		LjGrvLog(,"Antes da Chamada do Ponto de Entrada:STRECTIT",aParamPE)
		cTextoComprovante := ExecBlock( "STRECTIT" ,.F.,.F.,aParamPE )
		LjGrvLog(,"Apos a Chamada do Ponto de Entrada:STRECTIT", aParamPE)
	EndIf
	
	If Self:cOperation == OP_BAIXA
	    
	    //deve-se enviar o Indice do totalizador pois as impressoras da SIGALOJA esperam um valor numérico
		cTotalizador	:= STWReceTotalizer("TOTALIZADORES","BAIXA")
		cTotalizador	:= Iif(!Empty(cTotalizador),cTotalizador,"01")
		cForma			:= STWReceTotalizer("FORMA", "BAIXA")

		// Emite os documentos na impressora: 
		//	1. Recebimento Nao Fiscal - Totaliza o recebimento no ECF
		//	2. Se houver TEF, imprime o comprovante vinculado, referente ao Recebimento Nao Fiscal
		//	3. Relatorio Gerencial das parcelas pagas
		
		/*
			Impressao do Comprovante TEF
		*/
		If STIGetCard() .OR. STBGetCheck()
			STWPrintComp( oTEF20, oMdlGrd )
			lTemTEF := .T.
			lRetorno := .T.
		EndIf

		If lEmitNFCe

			// numero de vias do Comprovante de Recebimento que serao impressas
			For nI := 1 to nRecVias				
				cTxtCNF += cTextoComprovante
				//Se for ultima via, nao precisa da quebra de linhas
				If nI <> nRecVias
					cTxtCNF += Replicate( Chr(10),2 )
				EndIf
			Next

			nRet := STWPrintTextNotFiscal(cTxtCNF)		
			AAdd(aRet , nRet )
			lRetorno := .T.
		
			If lGuil 
				STWPrintTextNotFiscal(TAG_GUIL_INI+TAG_GUIL_FIM)
			EndIf
		Else

			If !lTemTEF
				lRetorno := STWReceiveNotFiscal( cTotalizador, Self:GetTotal(), cForma ) == 0
			EndIf

			If lRetorno
				For nX := 1 To nRecVias
					aRet := STFFireEvent(	ProcName(0)					,;	// Nome do processo
											"STManagReportPrint"		,;
											{cTextoComprovante, 1})
		 		Next nX
			 EndIf
		EndIf

		If Len(aRet) == 0 .OR. aRet[1] <> 0        
			STFMessage( ProcName(0) , "STOP", STR0001) //"Falha na impressão do comprovante de recebimento."
			STFShowMessage(ProcName(0))
			lRetorno := .F.
		Else
			lRetorno := .T.	
		EndIf
		
	ElseIf Self:cOperation == OP_ESTOR
        
		//deve-se enviar o Indice do totalizador pois as impressoras da SIGALOJA esperam um valor numérico
		cTotalizador := STWReceTotalizer("TOTALIZADORES","ESTORNO")
		
		//Valor total a ser impresso como sangria
		nVlTotal := Self:GetTotal()
		
		If nVlTotal > 0
			// Independente se foi colocada chave no SIGALOJA
			// ([Estorno Venda])
			// totalizadores= XX
			// Será emitido um cupom de Sangria 
			If !Empty(cForma)
				//Emite o documento na impressora 
				If lEmitNfce
					lRetorno := .T.		
				Else
					lRetorno := STWReceiveNotFiscal( cTotalizador, nVlTotal, cForma ) == 0
				EndIf
			Else					
				aValues[VALUE_MONEY] := nVlTotal
				lRetorno := STWSupplyBleeding( 1 , aValues , STBGetCurrency() , .T. )								
			EndIf
		Else
			lRetorno := .T.
		EndIf
		
		If lRetorno

			If lEmitNfce			
				nRet := STWPrintTextNotFiscal(cTextoComprovante)
				AAdd(aRet , nRet )
				lRetorno := .T.
		
				If lGuil 
					STWPrintTextNotFiscal(TAG_GUIL_INI+TAG_GUIL_FIM)
				EndIf
			
			// Quando estorno, nao exibe relatorio gerencial
			Else
				aRet :=	STFFireEvent(	ProcName(0)				,;	// Nome do processo
										"STManagReportPrint"	,;
	   									{cTextoComprovante, 1} 	)
	 		EndIf			
		
			If Len(aRet) == 0 .OR. aRet[1] <> 0        
				STFMessage( ProcName(0) , "STOP", STR0001) //"Falha na impressão do comprovante de recebimento."
				STFShowMessage(ProcName(0))
				lRetorno := .F.
			Else
				lRetorno := .T.	
			EndIf
		EndIf
		
		If !lRetorno
			STFMessage(ProcName(0), "STOP", STR0002) //"Falha na impressao do Documento Nao Fiscal."
			STFShowMessage( ProcName(0))
		EndIf
	EndIf

	CursorArrow()

Else
	STFMessage(ProcName(0), "STOP", STR0003) //"Nenhum valor a receber foi informado."
	STFShowMessage(ProcName(0))
EndIf

Return lRetorno
                    


//------------------------------------------------------------------------------   
/*/{Protheus.doc} LoadTitles
Conecta com a retaguarda e obtem a lista de títulos em aberto, preenchendo o array aListTitles
@author  Varejo
@version P11.8
@since   14/08/2012
@return lRetorno -  se obteve a lista de titulos na retaguarda
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method LoadTitles() Class STWReceiptTitle

Local aParametros	:= {}	// Array com os parametros da funcao
Local nI			:= 0	// Contador
Local lRetorno 		:= .F.	// Retorno da funcao
Local lRet			:= .F.	// Retorno da funcao STRecLoad
Local aTitles		:= {}	// Lista de titulos a receber
Local aParam		:= {}	//Conteúdo que será enviado para o ponto de entrada
Local lConnect		:= .F.	//Conexão com a retaguarda
Local cLjReceb 		:= SuperGetMV("MV_LJRECEB")
Local cNum			:= Iif(cLjReceb=="3",Self:cContrato,Self:cNumber) //Considera o Número do Contrato ou Número do título

Aadd(aParametros, cLjReceb)		

Aadd(aParametros, Self:cCode)		// cCodCli
Aadd(aParametros, Self:cBranch)		// cLojCli
Aadd(aParametros, Self:cCnpjCpf)	// cCPF

Aadd(aParametros, Self:cCartao)		// cCartao
Aadd(aParametros, "")				// cNumRA 
Aadd(aParametros, Self:cPrefix)		// cPrefixo
Aadd(aParametros, cNum)				// cNum
Aadd(aParametros, Self:cParcel)		// cParcela 	
Aadd(aParametros, Nil)				// nRecno 
Aadd(aParametros, Nil)				// dDataRef

If Type("cEstacao") <> "U"
	Aadd(aParametros, cEstacao)		// Estação (PDV)
	Aadd(aParametros, xNumCaixa())	// Caixa
Else
	Aadd(aParametros, "")			// Estação (PDV)
	Aadd(aParametros, "")			// Caixa
EndIf

CursorWait()

LjMsgRun( "Aguarde...Verificando conexão com o Host",, {|| lConnect := STWReCoHost() } ) //"Aguarde...Verificando conexão com o Host"

If lConnect
	Conout("Recebimento - Buscando titulo na retaguarda !! ")
	lRet := STBRemoteExecute( "STRecLoad",{Self:cOperation, aParametros},Nil,.F.,@aTitles )
	Conout("Recebimento - Retorno " +  cValToChar(lRet))
	conout("--------------------------------------------------------" ) 
	conout("--------------------------------------------------------" ) 
EndIf	

CursorArrow()

lRet := lConnect

// Ponto de entrada para organizar os titulos que serao recebidos
If ExistBlock("STRECVER")
	//Parametros para o ponto de entrada STRECVER
	Aadd(aParam, Self:cOperation)		// Tipo de operação
	Aadd(aParam, Self:cPrefix)			// Prefixo
	Aadd(aParam, Self:cNumber)			// Numero do titulo
	Aadd(aParam, Self:cCnpjCpf)			// Cpf ou Cnpj

	LjGrvLog("Recebimento","Antes da Chamada do Ponto de Entrada:STRECVER - {aTitles,aParam}")
	aTitles := ExecBlock( "STRECVER" ,.F.,.F.,{aTitles,aParam} )
	LjGrvLog("Recebimento","Apos a Chamada do Ponto de Self:cOperationEntrada:STRECVER - {aTitles,aParam}")
	//Caso tenha algum problema com a comunicação com a Retaguarda ou não tenha nenhum titulo no Protheus
	If Len(aTitles) > 3 .And. Len(aTitles[4]) > 0
		lRet := .T.
	EndIf 
EndIf

If !lRet
	STFMessage(ProcName(0), "STOP", STR0008 )//Erro ao carregar títulos -> //"Não foi possível carregar os títulos no momento - Verificar conexão" 
	STFShowMessage(ProcName(0))
Else
	If ValType(aTitles) == "A" .AND. Len(aTitles) > 0
		Self:aListTitles := aTitles
		If ValType(Self:aListTitles) == 'A' .AND. Len(Self:aListTitles) > 0
			If Self:aListTitles[1] == 0
				lRetorno := .T.
				If Len(Self:aListTitles[4]) = 0
					STFMessage(ProcName(0), "STOP", STR0020) //"Nenhum título encontrado!"
					STFShowMessage( ProcName(0))
					lRetorno := .F.
				Else
					// Cria primeira posicao logica de selecao do titulo no array e move as demais para baixo (medida de compatibilidade do LOJXREC)
					For nI := 1 To Len(Self:aListTitles[4])
						ASize(Self:aListTitles[4][nI], Len(Self:aListTitles[4][nI]) + 1)
						AIns(Self:aListTitles[4][nI], 1)
						Self:aListTitles[4][nI][TIT_SELE] := .F.
						If Self:cOperation == "1"
							Self:aListTitles[4][nI][TIT_RECE] += Self:aListTitles[4][nI][TIT_ACRS]
						EndIf
					Next nI
				EndIf     
			ElseIf Self:aListTitles[1] == 1
				// Problema no processamento
				STFMessage(ProcName(0), "STOP", Self:aListTitles[2] + " - " + Self:aListTitles[3])	// Cliente nao encontrado - O codigo do cliente informado nao foi encontrado.
				STFShowMessage(ProcName(0))
			Else
				// Problema nao identificado
				STFMessage(ProcName(0), "STOP", Self:aListTitles[2] + " - " + Self:aListTitles[3])	// Outra causa
				STFShowMessage(ProcName(0))
			EndIf
		EndIf   
	EndIf	   
EndIf

If !lRetorno 
	// Limpa array de titulos em caso de falha
	Self:aListTitles := {}
EndIf

Return lRetorno
                                                          

//------------------------------------------------------------------------------   
/*/{Protheus.doc} DropTitles
Chama função de baixa de títulos na retaguarda
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 .T. quando todos os títulos forem baixados com sucesso / .F. quando houver falha em algum processo
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method DropTitles(oMdlGrd, lContingency) Class STWReceiptTitle

Local aParametros			:= {}	// Array com os parametros da funcao
Local aListDropTitles 	:= {}	// Array com a lista de titulos (aParametros) a baixar na retaguarda
Local nI 					:= 0	// Contador
Local lRetorno 	  		:= .T.	// Retorno da funcao - .T. quando baixados com sucesso / .F. quando houver falha em alguma baixa (aborta as proximas)
Local lRet					:= .F.	// Retorno da funcao STRecLoad
Local lRetTitles			:= .F.	// Retorno da funcao STDropTitles
local aFormas				:= {}	// Array auxiliar com as formas de pgto utilziadas na venda
Local aPgto				:= {}	// Array com as informações de pgto utilizado na baixa do titulo no LOJXREC  
Local aPgtoSint			:= {}	// Array com os pgto sintetisados utilizado na baixa do titulo no LOJXREC
Local aTefpgto			:= {}	// Aray com as informações do TEF utilizado para baixa dos titulos no LOJXREC 
Local aTitSe1				:= {}	// Array com as formas a serem gerados titulos no SE1 apos a baixa do titulos (para serem compensados posteriormente - CH/CC/CD)
Local aParamSE1			:= {}	// Array com os parametros para a execução da função STGeraTitRec na retaguarda.
local aTitulos			:= {}	// Array com os titulos a serem baixados 
Local cCliente			:= ""	// Cliente da baixa
Local cLojaCli			:= ""	// Loja do cliente
Local cInfoTit			:= ""	//
Local nContCheque			:= 0	// Contador que controla informação do cheque
Local aPgtDet				:= {}	// Informações de detalhes das formas de pgto CH/CC/CD
Local aSE5Baixas			:= {}	// Array com as baixas realizadas na retaguarda.
Local aSE5Relacao			:= {}	// Array com a relação forma de pagmento x baixa de titulos x valores
Local aCompNcc			:= {}	// Nccs utilizadas para compensação
Local aCompTit			:= {}	// Titulos utilizadas na compensação
Local lTemFormaSe1		:= .F.	// Verifica se é necessário criar os registro no SE1
Local aCheques			:= STWGetCkRet()	// Retorna as informações dos cheques
Local aNCCs 				:= STDGetNCCs("1")	// NCCs do cliente
Local aSLV					:= {}	// Array com as informações a serem incluidas na tabela SLV.
Local aMovTitulos			:= {}	// Array para geração de SE5 local (para ser exibido no fechamento de caixa) 
Local aMovForma			:= {}	// Array para geração de SE5 local (para ser exibido no fechamento de caixa por forma)
Local lSTDRecSE5			:= ExistFunc("STDRecSE5")
Local nX 					:= 0	// Contador 2
Local nIntervalo			:= SuperGetMV("MV_LJINTER") //Intervalo das parcelas
Local nValCC				:= 0	// Valor Cartão
Local nDataCC					// Data Cartão 
Local nDiferenca			:= 0	// Diferenca da divisão em parcelas no cartao
Local aMdlGrd				:= {}
Local lRetComuBx			:= .F.	// Retorno da comunicacao com retaguarda
Local xRetTitles			:= Nil	// Retorno da funcao STDropTitles
Local lExecBxRet			:= .T.	// Controle para permitir tentar novamente caso ocorra erro 
Local aNumCheq			:= {}	// Array com numeros do cheque
Local nCH					:= 0	// Contador
Local cCPFCli 			:= "" //CPF do cliente em recebimento offline
Local nC					:= 0 //Contador de Recebimento Offline


Default oMdlGrd := Nil
Default lContingency := .F. //Recebimento em contingência


LjGrvLog( "Recebimento_Titulo", "Inicio da baixa")

If ValType(oMdlGrd) == "O"

	CursorWait()

	//Para efetuar a compensação das NCCs com os titulos	
	For nI := 1 To Len(aNCCs)
		If aNCCs[nI][1]
			aAdd(aCompNcc, aNCCs[nI][5]) //RECNO
		EndIf
	Next

	//Este loop é feito para que as informações necessários referente a forma de pagamento
	//estejam em variaveis auxiliares, para que seja possivel efetuar o tratamento a seguir da baixa de titulo. 
	//Onde será feita a organização de qual forma baixa qual titulo.
	For nI := 1 To oMdlGrd:Length()
	
		oMdlGrd:GoLine(nI)
		cFormaBx := AllTrim(oMdlGrd:GetValue("L4_FORMA"))
		
		aAdd(aMdlGrd, {nI,;									//1-Posicao forma
						oMdlGrd:GetValue("L4_DATATEF"),;	//2-Data
						oMdlGrd:GetValue("L4_HORATEF"),;	//3-Hora
						oMdlGrd:GetValue("L4_DOCTEF"),;		//4-DOC
						oMdlGrd:GetValue("L4_AUTORIZ"),;	//5-Autorizacao
						oMdlGrd:GetValue("L4_INSTITU"),;	//6-Instituicao
						oMdlGrd:GetValue("L4_NSUTEF"),;		//7-NSU
						oMdlGrd:GetValue("L4_TIPCART"),;  	//8-Tipo do cartao
						cFormaBx,; 							// 9 -forma de pagamento
						oMdlGrd:GetValue("L4_VALOR"),;		// 10 - valor do pagamento
						oMdlGrd:GetValue("L4_BANDEIR"),;	// 11 - bandeira do cartão
						oMdlGrd:GetValue("L4_REDEAUT")})	// 12 - rede autorizada (adquirência)

		//*
		//**
		//***
		//**** Tratamento para Inclusao de titulo SE1 (Formas de pagamentos diferente de R$) ****
		//Caso a forma seja NCC não deve entrar no tratamento de baixa, pois a mesma será compensada a parte na baixa
		If !(cFormaBx == "CR" .And. Len(aCompNcc) > 0)
			If cFormaBx == "CH"
				nContCheque++

				For nX := 1 To Len(aCheques[nContCheque])		
					If Len(aCheques) >= nContCheque
						lTemFormaSE1 := .T.
						
						If ValType(aCheques[1][1][1]) == 'A' .AND. Len(aCheques[nContCheque][1][1]) >= 11
								aAdd(aPgtDet, {aCheques[nContCheque][nX][1,11]		,;	//01- Valor
												 aCheques[nContCheque][nX][1,10]	,;	//02- Data
									  			 ""									,;	//03- 
									  			 aCheques[nContCheque][nX][1,1] 	,;	//04- Banco
									  			 aCheques[nContCheque][nX][1,3] 	,;	//05- Agencia
									  			 aCheques[nContCheque][nX][1,4] 	,;	//06- Conta
									  			 aCheques[nContCheque][nX][1,2] 	,;	//07- Numero
									  			 aCheques[nContCheque][nX][1,5] 	,;	//08- Compensacao
									  			 aCheques[nContCheque][nX][1,8] 	,;	//09- RG
									  			 aCheques[nContCheque][nX][1,7] 	,;	//10- Telefone
									  			 ""									,;	//11-
									  			 aCheques[nContCheque][nX][1,9] 	,;	//12- Chq Terceiro
									  			 ""									,;	//13- 
									  			 aCheques[nContCheque][nX][1,6] 	})	//14-Nome do terceiro
						Else
							aPgtDet := {oMdlGrd:GetValue("L4_VALOR")	,;	//01- Valor
										oMdlGrd:GetValue("L4_DATA")		,;	//02- Data
							  			""								,;	//03-
							  			aCheques[nContCheque][1,1]		,;	//04- Banco
							  			aCheques[nContCheque][1,3]		,;	//05- Agencia
							  			aCheques[nContCheque][1,4]		,;	//06- Conta
							  			aCheques[nContCheque][1,2]		,;	//07- Numero
							  			aCheques[nContCheque][1,5]		,;	//08- Compensacao
							  			aCheques[nContCheque][1,8]		,;	//09- RG
							  			aCheques[nContCheque][1,7] 		,;	//10- Telefone
							  			""								,;	//11-
							  			aCheques[nContCheque][1,9]		,;	//12- Chq Terceiro
									  	""								,;	//13- 
										aCheques[nContCheque][1,6]	 	}	//14-Nome do terceiro
						EndIf	  
						Aadd(aNumCheq, aCheques[nContCheque][nX][1,2])	  						
					Else
					 	aPgtDet := {}				
					EndIf
					
					If ValType(aCheques[1][1][1]) == 'A' .AND. Len(aCheques[nContCheque][1][1]) >= 11
						aAdd(aPgto,{aCheques[nContCheque][nX][1,10]			,;	//1 - Data
									 aCheques[nContCheque][nX][1,11]		,;	//2 - Valor
									 cFormaBx								,; 	//3 - Forma
									 aPgtDet								,;	//4 - Info
									 Nil									,;	//5 - Nil
									 1					   					,;	//6 - Moeda
									 Nil									,;	//7 - Nil
									 iIf(!Empty(oMdlGrd:GetValue("L4_FORMAID")),oMdlGrd:GetValue("L4_FORMAID"),AllTrim(Str(nI))),;	//8 - FormID
									 AllTrim(Str(nContCheque))				,;	//9 - ChequeId
									 oMdlGrd:GetValue("L4_VALOR")			})	//10 - Valor da moeda
					
						aPgtDet := {}
					EndIf
				Next
			ElseIf cFormaBx $ "CC/CD"
					lTemFormaSE1 := .T.
					nValCC       := STBRound(oMdlGrd:GetValue("L4_VALOR")/oMdlGrd:GetValue("L4_PARC"), 2)
					nDiferenca   := STBRound(oMdlGrd:GetValue("L4_VALOR") - ((STBRound(oMdlGrd:GetValue("L4_VALOR") / oMdlGrd:GetValue("L4_PARC"),2)) * oMdlGrd:GetValue("L4_PARC")), 2)
					
					For nX := 1 To oMdlGrd:GetValue("L4_PARC")
						If nX == oMdlGrd:GetValue("L4_PARC")
							nValCC := nValCC + nDiferenca
						EndIf
						
						nDataCC := oMdlGrd:GetValue("L4_DATA") + If(nX = 1, 0, nIntervalo * (nX - 1))
					
						aPgtDet := { 	nValCC														,;	//01- Valor
									nDataCC													,;	//02- Data
					  				""															,;	//03-
					  				oMdlGrd:GetValue("L4_NUMCART")							,;	//04- Numero do cartao
					  				SubStr(oMdlGrd:GetValue("L4_ADMINIS"),1,TamSx3("AE_COD")[1]),;	//05- Cod.Adm Financeira
					  				""															,;	//06- 
					  				""															,;	//07-
					  				iIf(!Empty(oMdlGrd:GetValue("L4_FORMAID")),oMdlGrd:GetValue("L4_FORMAID"),AllTrim(Str(nI)))	,;	//08- Id do cartao
					  				""															,;	//09-
					  				"" 															,;	//10- 
					  				""															,;	//11-
					  				.F.															,;	//12-
					  				""															,;	//13-
					  				""															}	//14- 
						
						aAdd(aPgto,{	nDataCC									,;	//1 - Data
								 		nValCC										,;	//2 - Valor
								 		cFormaBx									,; 	//3 - Forma
								 		aPgtDet									,;	//4 - Info
								 		Nil											,;	//5 - Nil
								 		1					   						,;	//6 - Moeda
								 		Nil											,;	//7 - Nil
								 		iIf(!Empty(oMdlGrd:GetValue("L4_FORMAID")),oMdlGrd:GetValue("L4_FORMAID"),AllTrim(Str(nI))),;	//8 - FormID
								 		""											,;	//9 - ChequeId
								 		oMdlGrd:GetValue("L4_VALOR")			})	//10 - Valor da moeda		
					Next
					
					aPgtDet := {}
					
					aAdd(aTefpgto, {iIf(!Empty(oMdlGrd:GetValue("L4_FORMAID")),oMdlGrd:GetValue("L4_FORMAID"),AllTrim(Str(nI))),; //1-Id da forma
									oMdlGrd:GetValue("L4_DOCTEF")	,; //2-Numeração do Documento TEF
									oMdlGrd:GetValue("L4_NSUTEF")	}) //3-Numeração do NSU TEF
			Else
				aPgtDet := {}
			EndIf
			
			If cFormaBx $ "R$" .OR. (Len(aCheques) > 0 .AND. ValType(aCheques[1][1][1]) <> 'A' .AND. Len(aCheques[nContCheque][1][1]) < 11)
				aAdd(aPgto,{oMdlGrd:GetValue("L4_DATA")					,;	//1 - Data
							 oMdlGrd:GetValue("L4_VALOR")				,;	//2 - Valor
							 cFormaBx									,; 	//3 - Forma
							 IIF(cFormaBx == "R$", {}, aPgtDet)			,;	//4 - Info
							 Nil										,;	//5 - Nil
							 1					   						,;	//6 - Moeda
							 Nil										,;	//7 - Nil
							 iIf(!Empty(oMdlGrd:GetValue("L4_FORMAID")),oMdlGrd:GetValue("L4_FORMAID"),AllTrim(Str(nI))),;	//8 - FormID
							 Iif(cFormaBx == "CH",AllTrim(Str(nContCheque)),"")	,;	//9 - ChequeId
							 oMdlGrd:GetValue("L4_VALOR")	})	//10 - Valor da moeda			
			EndIf	
			
			aAdd(aPgtoSint,{ cFormaBx						,; //1-Forma
							 oMdlGrd:GetValue("L4_PARC")	,; //2-Quantidade de parcelas
							 oMdlGrd:GetValue("L4_VALOR")	,; //3-Valor da forma
							 oMdlGrd:GetValue("L4_FORMAID")	,; //4-Id da forma
							 oMdlGrd:GetValue("L4_DATA")	,; //5-Data
							 {}								,; //6-Array (não utilizado na baixa)
							 ""								}) //7-String (não utilizado na baixa)
		Else
			aAdd(aMovForma,{	cFormaBx						,; //1-forma de pagamento utilizadas
								oMdlGrd:GetValue("L4_VALOR")	,; //2-Valor de abate do titulo para a forma
								""								,; //3-Prefixo do titulo
								""								,; //4-Numero do titulo
								""								,; //5-Parcela do titulo
								""								,; //6-Filial de origem
								""								}) //7-Ordem da forma de pagamento
		EndIf
		
	Next
	
	//Guardando os titulos no array 'aTitulos' para pode efetuar o tratamento da baixa dos mesmo.
	cCPFCli := Self:cCnpjCpf
	StwRecArr(IIF(!lContingency, Self:aListTitles[4], {}), @aCompTit, @aMovTitulos, aCompNCC, ;
					@aListDropTitles, @aSE5Relacao, aMdlGrd, @aMovForma, ;
					cUserName, @aNumCheq, SuperGetMV("MV_LJRECEB"), @aTitSe1, ;
					lContingency, @cCliente, @cLojaCli, Self)
					
	Self:dDtRec := Date()
	Self:cHrRec := Time()

	//********** EXECUTANDO OS COMANDOS DE BAIXA NA RETAGUARDA ***********
	While lExecBxRet .AND. (Len(aListDropTitles) > 0 .OR. Len(aCompNcc) > 0) 
		 
		LjGrvLog( "Recebimento_Titulo", "Titulos a baixar(aListDropTitles): ", aListDropTitles ) 
		LjGrvLog( "Recebimento_Titulo", "Ncc a compensar(aCompNcc): ", aCompNcc ) 

		If lTemFormaSE1 .Or. lContingency
			//Verifica necessidade da chamada de geração de titulos no SE1/MDM/MDN/SLV
			aParamSE1 := {	"1", aPgto		, aPgtoSint	, aTitSe1		,;
								Nil, Nil		, Nil			, Nil			,;
								Nil, cCliente	, cLojaCli		, Nil			,;
								Nil, Nil		, .F.			, xNumCaixa()	,;
								Nil, Nil		, aTefpgto		, cCPFCli, ;
								cEstacao}
			LjGrvLog( "Recebimento_Titulo", "Dados para geracao SE1(aParamSE1): ", aParamSE1 )
		EndIf

		//ID da requisição de Baixa (comum entre PDV e retaguarda) utilizada no controle da baixa assincrona
		cRequisicao := "REC" + AllTrim(FWCodFil()) + UPPER(AllTrim(cEstacao)) + UPPER(AllTrim(cUserName)) + FWTimeStamp(1)
		LjGrvLog( "Recebimento_Titulo", "Antes executar STDropTitl na Retaguarda."+;
						IIF(lContingency, "Recebimento em contingência. CPF, Valor, Título:" + Self:cCnpjCpf + "," + cValToChar(Self:nValueContingency) + "," +Self:cPrefix+"/"+Self:cNumber+"/"+Self:cParcel , "") + "Requisição: "+ cRequisicao)

		If ExistBlock("STRECALT")
			LjGrvLog("Recebimento","Antes da Chamada do Ponto de Entrada:STRECALT - aListDropTitles",aListDropTitles)
			aListDropTitles := ExecBlock( "STRECALT" ,.F.,.F.,{aListDropTitles} )
			LjGrvLog("Recebimento","Apos a Chamada do Ponto de Entrada:STRECALT - aListDropTitles", aListDropTitles)
		EndIf
		
		If Len(aListDropTitles) > 0 .Or. Len(aCompNcc) > 0
			lRetComuBx := STBRemoteExecute( "STDropTitl",{	aListDropTitles	, {aCompTit,aCompNcc}	, cUserName		, lTemFormaSE1	,;
															aParamSE1		, aTitSe1				, aSE5Relacao	, aMdlGrd		,;
															cRequisicao		, .T.					, lContingency	, Dtos(Self:dDtRec)+StrTran(Self:cHrRec, ":")}	,{"OK", .T.}	,lContingency	,	@xRetTitles )
		EndIf
		
		LjGrvLog( "Recebimento_Titulo", "Apos executar STDropTitl na Retaguarda. Retorno comunicacao(lRetComuBx):",lRetComuBx)
		LjGrvLog( "Recebimento_Titulo", "Apos executar STDropTitl na Retaguarda. Retorno comando(xRetTitles):",xRetTitles)

		If lRetComuBx
			If  ( ( ValType(xRetTitles) == "C" .AND. xRetTitles == 'OK' ) .OR.;	//Se realizou a baixa no modo atualizado, com controle de transacao
				  ValType(xRetTitles) == "L") .OR. lContingency										//Se realizou a baixa com LOJXREC Antigo
				lRetTitles := .T.
			Else
				lRetTitles := .F.
			EndIf
		EndIf
			
		//Mantem compatibilidade quando LOJXREC retaguarda desatualizado com modelo que realizar StartDropTitle na retaguarda
		If ValType(xRetTitles) == "L" .AND. lRetTitles .AND. lTemFormaSE1 .AND. !lContingency

			LjGrvLog( "Recebimento_Titulo", "Retorno StDropTitl tipo logico(Processo sem controle de transacao). Necessario atualizar LOJXREC retaguarda.")
			
			//Verifica necessidade da chamada de geração de titulos no SE1/MDM/MDN/SLV
			aParamSE1 := {	"1", aPgto		, aPgtoSint	, aTitSe1	,;
							Nil, Nil		, Nil		, Nil		,;
							Nil, cCliente	, cLojaCli	, Nil		,;
							Nil, Nil		, .F.		, xNumCaixa(),;
							Nil, Nil		, aTefpgto	, cCPFCli}

			LjGrvLog( "Recebimento_Titulo", "Antes de executar STGeraTitRec - (Processo sem controle de transacao) - aSE5Baixas")
			lRet := STBRemoteExecute( "STGeraTitRec",{"STGRVMDX","1", aParamSE1,aTitSe1},Nil,lContingency,@aSE5Baixas )
			LjGrvLog( "Recebimento_Titulo", "Apos executar STGeraTitRec - (Processo sem controle de transacao). Retorno aSE5Baixas:",aSE5Baixas)

			If lRet .And. Len(aSE5Baixas) > 0
				aSLV := PrepSLVArray(aSE5Baixas,aSE5Relacao,oMdlGrd)
				If Len(aSLV) > 0
					LjGrvLog( "Recebimento_Titulo", "Antes de executar STGeraTitRec - (Processo sem controle de transacao) - aSLV",aSLV)
					lRet := STBRemoteExecute( "STGeraTitRec",{"STGRVSLV","I", aSLV},Nil,lContingency,@lRetTitles )
					LjGrvLog( "Recebimento_Titulo", "Apos executar STGeraTitRec - (Processo sem controle de transacao) - aSLV. Retorno lRetTitles",lRetTitles)
				EndIf
			EndIf
						
		EndIf
							
		CursorArrow()
			
		lExecBxRet := .F.
			
		If (!lRetComuBx .OR. !lRetTitles) .AND. ValType(xRetTitles) == "C"
			
			LjGrvLog( "Recebimento_Titulo", "Não foi possível concluir a baixa do título na Retaguarda. Tentar novamente?",xRetTitles)
			
			xRetTitles := STWRetMsg(xRetTitles)	//Converte mensagem para formato amigavel para usuario nao tecnico 
			
			If MsgYesNo(	xRetTitles + Chr(13)+ Chr(13)+;					
					  	  	STR0029+Chr(13)+;						//"Por esse motivo, não foi possível concluir a baixa na Retaguarda"
					  		STR0031 )								//"Deseja tentar novamente?"
				lExecBxRet := .T.
				CursorWait()
			EndIf
			
			LjGrvLog( "Recebimento_Titulo", "Não foi possível concluir a baixa do título na Retaguarda. Tentar novamente?. Retorno continua:",lExecBxRet)
		EndIf
		
	EndDo
EndIf

If Len(aListDropTitles) > 0 
	If !lRetComuBx
		STFMessage(ProcName(0), "STOP", STR0009)	//"Erro ao executar a baixa de Títulos no servidor"
		STFShowMessage(ProcName(0))
		lRetorno := .F.
	ElseIf !lRetTitles
		STFMessage(ProcName(0), "STOP", STR0025)	//"Não foi possível realizar a baixa na Retaguarda"
		STFShowMessage(ProcName(0))
	EndIf
	lRetorno := lRetTitles
EndIf	

//Popula tabela SE5 para conferencia de caixa
If lRetorno .AND. lSTDRecSE5
	LjGrvLog( "Recebimento_Titulo", "Antes de executar STDRecSE5 (SE5 Local para conferencia de Caixa)",lRetorno)
	STDRecSE5(aMovTitulos,aMovForma, , lContingency)
	LjGrvLog( "Recebimento_Titulo", "Apos executar STDRecSE5 (SE5 Local para conferencia de Caixa)",lRetorno)
EndIf

LjGrvLog( "Recebimento_Titulo", "Fim da baixa. Retorno continua:",lRetorno)

Return lRetorno


//------------------------------------------------------------------------------   
/*/{Protheus.doc} ReverseDropTitles
Chama função de estorno de baixa de títulos na retaguarda
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 .T. quando todos os títulos forem estornados com sucesso / .F. quando houver falha em algum processo
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method ReverseDropTitles() Class STWReceiptTitle

Local aListRever	:= {}		// Array com a lista de titulos (controle loop de estornos)
Local nI			:= 0  		// Contador
Local lRetorno		:= .F.		// Retorno da funcao - .T. quando baixados com sucesso / .F. quando houver falha em alguma baixa (aborta as proximas)
Local lRet			:= .F.		// Retorno da funcao que e executada na retaguarda
Local aEstorno		:= {}		// Retorno da
Local nY			:= 0		// Contador
Local nEstTotal		:= 0		// Valor total dos estornos
Local aVlrCompNCC	:= {}		// Valor de estorno de compensação (NCC)
Local nTotNcc		:= 0		// Valor de NCC utilizado na baixa
Local cNumCaixa		:= xNumCaixa()	//Caixa que efetuou o estorno.
Local aMovForma		:= {}
Local lFuncGrv		:= ExistFunc("STDRecSE5")
Local nZ			:= 0 
Local aMDMLote		:= {} //Array de Lotes
Local cMsgErro		:= ""
Local aListTitles	:= {} //Lista de títulos

CursorWait()
LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Inicio - Self:aListTitles:",Self:aListTitles)
If (STFProFile(29)[1]) // Verifica se tem permissao para estornar o caixa
	aEval(Self:aListTitles[4], { |t| IIF(t[TIT_SELE], aAdd( aListTitles, aClone(t) ) , )})
	For nI := 1 To Len(Self:aListTitles[4])
		If Self:aListTitles[4][nI][TIT_SELE]

			aListRever := {Self:aListTitles[4][nI]}
			LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Titulos Selecionados(aListRever):",aListRever)
	
			lRet		:= .T.
			nEstTotal	:= 0
			aEstorno	:= {}
			aMovForma	:= {}
			
			If ExistBlock("STRECEST")
				LjGrvLog("Recebimento","Antes da Chamada do Ponto de Entrada:STRECEST - aListRever",aListRever)
				aListRever := ExecBlock( "STRECEST" ,.F.,.F.,{aListRever} )
				LjGrvLog("Recebimento","Apos a Chamada do Ponto de Entrada:STRECEST - aListRever", aListRever)
			EndIf			
			
			If Len(aListRever) > 0

				LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Antes de executar STReverseD")
				lRet := STBRemoteExecute( "STReverseD",{aListRever,cNumCaixa, aMDMLote,aListTitles },Nil,.F., @aEstorno )
				LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Apos executar STReverseD. Retorno aEstorno:",aEstorno)

				//Tratamento por causa de possivel fonte desatualizado				
				If ValType(aEstorno) == "L" .Or. !lRet .Or. Len(aEstorno) == 0
					LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Saiu do processo, retorno invalido da retaguarda (ValType(aEstorno) == 'L' .Or. !lRet .Or. Len(aEstorno) == 0). Retorno lRet:",lRet)
					Exit
				Endif

				If ( !(Len(aEstorno) >= 4) .OR. Empty(aEstorno[3]) )  .AND.  (Len(aEstorno[1]) > 0  .Or. Len(aEstorno[2]) > 0)  
					aVlrCompNCC := aEstorno[1] //Estorno referente as NCCs
					aEstorno	:= aEstorno[2] //Estorno referente as formas de pagamento (diferente de NCC)
					nCont := 0
					If Len(aEstorno) >= 4
						aMDMLote := aClone(aEstorno[4])
					EndIf

					//Array para gerar movimentação no SE5 local
					If Len(aMovForma) == 0

						//Tratamento para NCC
						If Len(aVlrCompNCC) == 1
							For nZ := 1 To Len(aVlrCompNCC[1])

								nTotNcc += aVlrCompNCC[1][nZ][8]
								nEstTotal += aVlrCompNCC[1][nZ][8]

								aAdd(aMovForma,{"CR"					,;	//Forma
												aVlrCompNCC[1][nZ][8]	,;	//Valor
												aVlrCompNCC[1][nZ][1]	,;	//Prefixo
												aVlrCompNCC[1][nZ][2]	,;	//Numero
												aVlrCompNCC[1][nZ][3]	,;	//Parcela
												Nil						,;	//Filial origem
												Nil})
							Next
						EndIf

						//Demais formas de pagamentos
						For nZ := Len(aEstorno) To 1 Step -1
						
							If AllTrim(aEstorno[nZ][25]) == "BA"
								nEstTotal := aEstorno[nZ][8]
								aAdd(aMovForma,{aEstorno[nZ][24],;	//Forma
												  aEstorno[nZ][8] ,;	//Valor
												  aEstorno[nZ][1] ,;	//Prefixo
												  aEstorno[nZ][2] ,;	//Numero
												  aEstorno[nZ][3] ,;	//Parcela
												  Nil			    ,;	//Filial origem
												  Nil})
								Exit
							EndIf
						
						Next
						
					Else
						aEval(aEstorno,{|e| nCont += iif(AllTrim(e[25])=="BA",1,0)})
					EndIf

				Else
					lRet := .F.
					If Len(aEstorno) >= 4
						cMsgErro := aEstorno[3]
					EndIf
				EndIf

				//Altera o valor do titulo com o valor de estorno para que este valor de estorn seja impresso
 				If nEstTotal > 0
					Self:SetParcTotal(nI, nEstTotal)
					Self:SetTotNCC(nTotNcc)
				EndIf
			EndIf

			If lRet .And. lFuncGrv
				LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Antes de executar STDRecSE5(aListRever,aMovForma)",{aListRever,aMovForma})
				STDRecSE5(aListRever,aMovForma,.T.)
				LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Apos executar STDRecSE5")
			EndIf
		EndIf
	Next nI
	
	If !lRet
		LjGrvLog( "Recebimento_Titulo", ">>>NC<<< - Processo de ESTORNO - Erro ao executar o estorno de Títulos no servidor: Erro retornado: "+ cMsgErro)
		STFMessage(ProcName(0), "POPUP", STR0010 + cMsgErro)//"Não foi possível realizar o estorno do título"
		STFShowMessage(ProcName(0))
		lRetorno := .F.
	Else
		//Tratamento para caso o LOJXREC nao esteja atualizado, onde o mesmo retornava uma variavel logica	
		LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Estorno efetuado com sucesso")
		lRetorno := lRet
		STFMessage(ProcName(0), "ALERT", STR0022) //#"Estorno efetuado com sucesso!"
		STFShowMessage(ProcName(0))

	EndIf
Else
	LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Caixa sem permissao para efetuar estorno")
	lRetorno := .F.
	STFMessage(ProcName(0), "STOP",STR0026) //#"CAIXA SEM PERMISSAO PARA EFETUAR ESTORNO"
	STFShowMessage(ProcName(0))
EndIf
LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Final")
CursorArrow()

Return lRetorno


                                               
//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetReceiptArray
Obtem o array de texto do comprovante impresso
@param	 lExtrato Se é extrato
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Array com o texto do comprovante
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetReceiptArray(lExtrato) Class STWReceiptTitle

Local aRetorno 			:= {} 					 	// Array de retorno - Texto do comprovante
Local cTextoParcela		:= ""  						// Texto referente a parcela completo
Local cTextoDocParcela	:= "" 						// Texto referente ao documento da parcela 
Local cValorFormatado	:= 0   						// Valor armazenado temporariamente ja formatado, referente a parcela ou valor total
Local nI				:= 0						// Contador
Local nDimensao			:= STFGetStation("LARGCOL")	// Numero de colunas do comprovante de recebimento
Local aTextoTitulo 		:= {}						// Array Texto Titulo
Local nGetTot			:= 0						// Variável para controle do total do título
Local nNccTot			:= 0						// Variável para controle total do valor de NCC
Local nSumTot			:= 0						// Variável para a soma dos totais do valor do título + NCC
Local cMoeda			:= SuperGetMv("MV_SIMB1",.F.,"R$") // Primeira moeda valida do sistema  

Default lExtrato := .F.   


If lExtrato
	aTextoTitulo := {STR0011, STR0012, ""}	//"E X T R A T O", "D E  C O N T A"
ElseIf Self:cOperation == OP_BAIXA
	aTextoTitulo := {STR0013, STR0014, IIF(Self:lIsContingency, STR0039 , "")}//"C O M P R O V A N T E", "D E   R E C E B I M E N T O"// "  O F F L I N E"
ElseIf Self:cOperation == OP_ESTOR
	aTextoTitulo := {STR0015, STR0016, ""}	//"E S T O R N O", "D E   R E C E B I M E N T O" 
EndIf

// O comprovante deve possuir no mínimo 40 colunas
If ValType(nDimensao) == "N" .AND. nDimensao >= 40
	// Cabecalho
	Aadd(aRetorno, PadC(aTextoTitulo[1]			        	, nDimensao))
	Aadd(aRetorno, PadC(aTextoTitulo[2]						, nDimensao))
	Aadd(aRetorno, PadC(aTextoTitulo[3]						, nDimensao))
	Aadd(aRetorno, PadR(""									, nDimensao))
	Aadd(aRetorno, PadR(""									, nDimensao))
	
	cTextoDocParcela := STR0040 + Self:cCnpjCpf //"CPF : "
	Aadd(aRetorno, PadR(cTextoDocParcela, nDimensao))	
	If !Empty(Self:cName)
		cValorFormatado := STR0041 + Self:cName //"NOME : "
		Aadd(aRetorno, PadR(cValorFormatado, nDimensao))
	EndIf

	Aadd(aRetorno, PadR(""										, nDimensao))
	
	// Se Recebimento Normal ou Extrato, imprime as parcelas (nao imprime por contingencia)
	If !Self:lIsContingency .OR. lExtrato
		///////////////////////////////////////////////////////////////////////////////////////////
		//Verifico se existe NCC estornada para a respectiva impressão e soma correta dos valores//
		///////////////////////////////////////////////////////////////////////////////////////////
		If Self:nTotNcc > 0
			Aadd(aRetorno, PadR("", nDimensao))
			Aadd(aRetorno, PadR(STR0046 +  cMoeda + " " + LTrim(Trans(Self:nTotNcc,"@E 999,999,999.99")),nDimensao))//"Valor NCC: "
			Aadd(aRetorno, PadR("", nDimensao))			
		EndIf
		
		Aadd(aRetorno, PadR(PadR(STR0017, nDimensao - Len(STR0018)) + STR0018, nDimensao))//"Documento" ### "Valor"
		
		// Parcelas
		For nI := 1 To Len(Self:aListTitles[4])
			// Na emissao do extrato imprime todas as parcelas, no recebimento, somente as selecionadas
			If Self:aListTitles[4][nI][TIT_SELE] .OR. lExtrato
				cValorFormatado 	:= FormatValueCurrency(Self:aListTitles[4][nI][TIT_RECE])
				cTextoDocParcela	:= Self:aListTitles[4][nI][TIT_PREF] + "/" + Self:aListTitles[4][nI][TIT_NUME] + "/" + Self:aListTitles[4][nI][TIT_PARC]
		  		cTextoParcela		:= cTextoDocParcela + Space(nDimensao - Len(cTextoDocParcela) - Len(cValorFormatado)) + cValorFormatado
		
				Aadd(aRetorno, PadR(cTextoParcela, nDimensao))
			EndIf
		Next nI
	ElseIf Self:lIsContingency
	
		cTextoDocParcela := STR0042 + Dtoc(Self:dDtRec) + " " + Left(Self:cHrRec,5) //"Data/Hora: "
		cValorFormatado := STR0043 + xNumCaixa() //"Caixa: "
		
		
		cTextoParcela :=  cTextoDocParcela + Space(nDimensao - Len(cTextoDocParcela) - Len(cValorFormatado)) + cValorFormatado
		Aadd(aRetorno, PadR(cTextoParcela, nDimensao))
		
		Aadd(aRetorno, PadR("", nDimensao))
		
		Aadd(aRetorno, PadR(PadR(STR0044, nDimensao - Len(STR0018)) + STR0018, nDimensao))//"Documento Informado" ### "Valor"
		
		cValorFormatado := FormatValueCurrency(Self:GetTotal(lExtrato))
		
		If !Empty(Self:cPrefix) .OR. !Empty(Self:cNumber) .OR. !Empty(Self:cParcel)
			cTextoDocParcela	:= Self:cPrefix + "/" + Self:cNumber + "/" + Self:cParcel
			
		Else
			cTextoDocParcela := STR0045 //"<< NÃO INFORMADO >>"
		EndIf
		  	
		cTextoParcela		:= cTextoDocParcela + Space(nDimensao - Len(cTextoDocParcela) - Len(cValorFormatado)) + cValorFormatado
		Aadd(aRetorno, PadR(cTextoParcela, nDimensao))
	EndIf
	
	///////////////////////////////////////////////////////
	//Analisando resultado final para impressão do rodapé//
	///////////////////////////////////////////////////////
	nGetTot := Self:GetTotal(lExtrato)
	nNccTot := Self:nTotNcc
	
	nSumTot := Iif(nNccTot >= nGetTot .Or. Self:cOperation == OP_BAIXA ,nGetTot,nGetTot + nNccTot) 

	// Rodapé
	cValorFormatado := FormatValueCurrency(nSumTot)
	Aadd(aRetorno, PadR("", nDimensao))
	Aadd(aRetorno, PadR(STR0019 + Space(nDimensao - Len(STR0019) - Len(cValorFormatado)) + cValorFormatado, nDimensao))//"T O T A L"
Else
	STFMessage(ProcName(0), "STOP", STR0004) //"O número de colunas do comprovante deve ser ao menos 40. Configure no cadastro de estações o campo LG_LARGCOL"
	STFShowMessage(ProcName(0))
EndIf         

Return aRetorno  


//------------------------------------------------------------------------------   
/*/{Protheus.doc} ExtractPrint()
Emite impressao do Extrato da conta
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 .T. Quando impresso corretamente / .F. Quando houver falha na impressao
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method ExtractPrint() Class STWReceiptTitle

Local lRetorno 			:= .F.		// Retorno	
Local cTextoComprovante	:= ""		// Texto do comprovante

If Self:LoadTitles()
	If Self:CountParcels() > 0
		cTextoComprovante := GetTextArray(Self:GetReceiptArray(.T.))
	
		If IFRelGer( 0, cTextoComprovante, 1) == 0
			lRetorno := .T.
		Else
			STFMessage(ProcName(0), "STOP", STR0007) //"Falha na impressão do extrato."
			STFShowMessage(ProcName(0))
		EndIf
	EndIf
EndIf

Return lRetorno

//------------------------------------------------------------------------------   
/*/{Protheus.doc} VldCustomer
Pesquisa o CPF/CNPJ do cliente desejado
@param	 cCodCli Cliente
@param	 cLojCli Loja
@param	 cCPF CPF do Cliente
@author  Varejo
@version P11.8
@since   14/08/2012
@return  aRet - Array com dados do cliente
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method VldCustomer(cCodCli,	cLojCli, cCPF) Class STWReceiptTitle

Local aArea		:= GetArea()		// Armazena alias corrente
Local aRet 		:= {}				// Array retorno

Default cCodCli 	:= ""
Default cLojCli 	:= ""
Default cCPF		:= ""

If !Empty(cCodCli) .AND. !Empty(cLojCli)
	DbSelectArea("SA1")
	DbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
	If DbSeek(xFilial("SA1") + cCodCli + cLojCli )
		cCPF := SA1->A1_CGC   
	EndIf 
ElseIf !Empty(cCPF)
	DbSelectArea("SA1")
	DbSetOrder(3)//A1_FILIAL+A1_CGC
	If DbSeek(xFilial("SA1") + cCPF)
		cCodCli  := SA1->A1_COD
	   	cLojCli  := SA1->A1_LOJA	     
	EndIf   
EndIf

Aadd(aRet,cCodCli)
Aadd(aRet,cLojCli)
Aadd(aRet,cCPF)

RestArea(aArea)

Return aRet

//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetTextArray
Obtem texto com quebra de linha(chr 10) com base no vetor
@param	 aComprovante Vetor onde cada registro corresponde a uma linha
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Texto do vetor
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Static Function GetTextArray(aComprovante)

Local nI			:= 0	// Contador
Local cRetorno 	:= ""	// Retorno da funcao

Default aComprovante := {}

For nI := 1 To Len(aComprovante)
	cRetorno += aComprovante[nI] + Chr(10)
Next nI

Return cRetorno


//------------------------------------------------------------------------------   
/*/{Protheus.doc} FormatValueCurrency
Formata o valor numerico como monetário
@param	 nValue - Valor a formatar
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 String de valor formatado como monetário
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Static Function FormatValueCurrency(nValue)
Local cRet := ""

Default nValue 	:= 0	// Retorno da funcao

cRet := SuperGetMV("MV_SIMB1") + Trans(nValue, "@E 999,999,999.99")

Return cRet 

//------------------------------------------------------------------------------   
/*/{Protheus.doc} STWVldFldRec
Função responsavel por validar se habilita ou não os campos Multa,Juros e Descontos 
para edição para o titulo selecionado.

@param   aVldTitulo - Titulo selecionado pelo usuario 
@author  Varejo
@version P11.8
@since   22/05/2015
@return	 Logico .T. -> Habilita para edição / .F. ->Desabilita edição de campos
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function STWVldFldRec(aVldTitulo,lAtuValMulta, lAtuValJuros, lAtuValDesconto,;
 				  	  lAtuValtotal,cTpOp		, aLista	   , aSelecionado)
Local lRet 	:= .T.
Local xRet 	:= .T.
Local nI		:= 0
Local oObjRec := STIRetObjTit() 

DEFAULT lAtuValMulta	:= .T.
DEFAULT lAtuValJuros	:= .T.
DEFAULT lAtuValDesconto	:= .T.
DEFAULT lAtuValtotal	:= .T.
DEFAULT aLista			:= {}		//Lista dos Titulos
DEFAULT aSelecionado  	:= {}		//Lista dos Titulos SELECIONADOS
DEFAULT cTpOp			:= ""


LjGrvLog( "Recebimento_Titulo", "STWVldFldRec(Valida edicao de campos) - Inicio")

If Len(aLista) > 0 .And. Len(aSelecionado)>0 
	cTpOp := iIf(cTpOp=="R","1","2") //1-Recebimento /2-Estorno de recebimento
EndIf		

If ExistBlock("STValidRec")

		nTotAntes := 0
		For nI := 1 To Len(aSelecionado)
			If aSelecionado[nI]
				nTotAntes := oObjRec:GetParcTotal(nI)
			EndIf
		Next nI
		LjGrvLog( "Recebimento_Titulo", "Antes do STVALIDREC - oObjRec:GetTotal():",nTotAntes)
		LjGrvLog( "Recebimento_Titulo", "Antes do STVALIDREC - aLista:",aLista)
		xRet := ExecBlock("STValidRec",.F.,.F.,{aVldTitulo,cTpOp,aLista , aSelecionado})
		
		nTotDepois := 0
		For nI := 1 To Len(aSelecionado)
			If aSelecionado[nI]
				nTotDepois := oObjRec:GetParcTotal(nI)
			EndIf
		Next nI

		LjGrvLog( "Recebimento_Titulo", "Apos STVALIDREC - oObjRec:GetTotal():",nTotDepois)
		LjGrvLog( "Recebimento_Titulo", "Apos STVALIDREC - aLista:",aLista)
		LjGrvLog( "Recebimento_Titulo", "Retorno do PE STVALIDREC",xRet)
		STIUpdTit()		
		LjGrvLog( "Recebimento_Titulo", "Apos STIUPDTIT aLista: ",aLista)
				
	If Valtype(xRet) == "A"
		lRet 				:= xRet[1]
		lAtuValMulta		:= xRet[2]
		lAtuValJuros		:= xRet[3] 
		lAtuValDesconto		:= xRet[4]
		lAtuValtotal		:= xRet[5] 
	Else
		lRet := xRet
	EndIf	
EndIf

If !lRet //caso nao valide as alteracoes no titulo e retorne falso , desabilita os campos
	lAtuValMulta	:= .F.		//Habilita a edição dos campos de multa - STIRecSel
	lAtuValJuros	:= .F.		//Habilita a edição dos campos de juros -  STIRecSel
	lAtuValDesconto	:= .F.		//Habilita a edição dos campos de desconto  - STIRecSel
	lAtuValtotal	:= .F.		//Habilita a edição dos campos de Total  - STIRecSel
EndIf

LjGrvLog( "Recebimento_Titulo", "STWVldFldRec(Valida edicao de campos) - Fim. lRet",lRet)

Return lRet

//------------------------------------------------------------------------------   
/*/{Protheus.doc} STWReceTotalizer
Função responsavel retornar a informação de forma de pagamento ou algum totalizador 
do recebimento de titulo

@param	cInfo - Nome da TAG no SIGALOJA.ini ou FORMA para forma de pagamento
		cTipo - Tipo de operação 

@author  Varejo
@version P11.8
@since   15/06/2015
@return	 Caracter - Informação da forma ou do totalizador a ser impresso.
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function STWReceTotalizer(cInfo, cTipo)
Local cRet := ""
Local cNatRece := IIf( ExistFunc("LjMExePara"), LjMExeParam("MV_NATRECE"), &(SuperGetMV("MV_NATRECE")))
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cInfo	:= "TOTALIZADORES"
Default cTipo	:= "BAIXA"

Do Case

	Case AllTrim(Upper(cInfo)) == "FORMA"

		cRet := cNatRece

	OtherWise
		If !lAutomato
			If AllTrim(Upper(cTipo)) == "ESTORNO"
				cRet := GetPvProfString("Estorno Venda"			, cInfo , "", GetClientDir()+"SIGALOJA.INI")
			Else
				cRet := GetPvProfString("Recebimento Titulos"	, cInfo , "", GetClientDir()+"SIGALOJA.INI")
			EndIf
		Endif
EndCase

Return cRet

//------------------------------------------------------------------------------   
/*/{Protheus.doc} PrepSLVArray
Função responsável por retornar os registros a serem incluidos na tabela SLV na retaguarda.
@param		aSE5Baixas	- Baixas realizadas
			aSE5Relacao	- Array com as relações Forma de pagamento x titulos
			oMdlGrd		- Gride de formas de pagamento
@author		Varejo
@version	P11.8
@since		15/06/2015
@return		aRet - Array com informações a serem geradas na tabela SLV.
@obs     
@sample
/*/
//------------------------------------------------------------------------------
Static Function PrepSLVArray(aSE5Baixas,aSE5Relacao,oMdlGrd)
Local aRet			:= {}
Local nI			:= 0
Local nY			:= 0
Local nPosRelacao	:= 0

For nI := 1 To Len(aSE5Baixas)

	For nY := 1 To Len(aSE5Baixas[nI])

		If AllTrim(aSE5Baixas[nI][nY][24]) $ "CC/CD"

			nPosRelacao :=	aScan(aSE5Relacao, {|x| AllTrim(x[1])+AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5]) ==;
							AllTrim(aSE5Baixas[nI][nY][24])+AllTrim(aSE5Baixas[nI][nY][1])+AllTrim(aSE5Baixas[nI][nY][2])+AllTrim(aSE5Baixas[nI][nY][3]) .And. ;
							x[2]==aSE5Baixas[nI][nY][8] })

			If nPosRelacao > 0

				oMdlGrd:GoLine(aSE5Relacao[nPosRelacao][7])			

				aAdd(aRet, {aSE5Baixas[nI][nY][1],;				//01-PREFIXO
							aSE5Baixas[nI][nY][2],;				//02-NUMERO
							aSE5Baixas[nI][nY][3],;				//03-PARCELA
							aSE5Baixas[nI][nY][4],;				//04-TIPO
							aSE5Baixas[nI][nY][9],;				//05-E5_SEQ
							aSE5Relacao[nPosRelacao][6]	,;		//06-FILORIG
							aSE5Baixas[nI][nY][5],;				//07-CLIENTE
							aSE5Baixas[nI][nY][6],;				//08-LOJA
							aSE5Baixas[nI][nY][24],;			//09-Forma Pgto
							aSE5Baixas[nI][nY][8],;				//10-Valor
							oMdlGrd:GetValue("L4_DATATEF"),;	//11-Data
							oMdlGrd:GetValue("L4_HORATEF"),;	//12-Hora
							oMdlGrd:GetValue("L4_DOCTEF"),;		//13-DOC
							oMdlGrd:GetValue("L4_AUTORIZ"),;	//14-Autorizacao
							oMdlGrd:GetValue("L4_INSTITU"),;	//15-Instituicao
							oMdlGrd:GetValue("L4_NSUTEF"),;		//16-NSU
							iIf(!Empty(oMdlGrd:GetValue("L4_TIPCART")), oMdlGrd:GetValue("L4_TIPCART"), aSE5Baixas[nI][nY][24]),;	//17-Tipo do cartao
							"",;								//18-SEQOPER
							0;									//19-RECNO
							} )

			EndIf

		EndIf

	Next

Next

Return aClone(aRet)



//------------------------------------------------------------------------------   
/*/{Protheus.doc} STWValidRecep
Função responsável por executar o Ponto de Entrada para validação dos titulos selecionados
para verificação se baixa ou não os titulos.
@param		aLista			- Lista com todos os titulos (selecionados e não selecionados)
			aSelecionado	- Lista logica com a posição do titulos selecionados.
@author		Varejo
@version	P11.8
@since		24/06/2015
@return		lRet - .T. -> Permite a baixa dos titulos / .F. -> Não permite a baixa dos titulos
@obs     
@sample
/*/
//------------------------------------------------------------------------------
Function STWValidRecep(cTpOp,aLista,aSelecionado)
Local lRet		:= .T.			//Retorno
Local nI		:= 0			//Contador
Local aTitulos	:= {}		//Relação de Títulos

For nI := 1 To Len(aSelecionado)
	If aSelecionado[nI]

		aAdd(aTitulos, {aLista[nI,TIT_PREF],;	//02 - PREFIXO
						aLista[nI,TIT_NUME],;	//03 - TITULO
						aLista[nI,TIT_PARC],;	//04 - PARCELA
						aLista[nI,TIT_VREA],;	//05 - VENCIMENTO
						aLista[nI,TIT_VALO],;	//06 - VALOR
						aLista[nI,TIT_FILI],;	//15 - FILIAL
						aLista[nI,TIT_TIPO],;	//11 - TIPO DO TITULO
						aLista[nI,TIT_MULT],;	//07 - MULTA
						aLista[nI,TIT_JURO],;	//08 - JUROS
						aLista[nI,TIT_DESC],;	//09 - DESCONTO
						aLista[nI,TIT_RECE]})	//10 - RECEBIMENTO 
						
		If aLista[nI,TIT_RECE] <= 0							
			STFMessage(ProcName(0), "STOP", STR0028) //"Título sem nenhum valor para ser recebido"
			STFShowMessage(ProcName(0))
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

If lRet .AND. Len(aTitulos) > 0 .And. ExistBlock("STVALBXREC")
	cTpOp := iIf(cTpOp=="R","1","2") //1-Recebimento /2-Estorno de recebimento
	lRet := ExecBlock("STVALBXREC",.F.,.F.,{cTpOp,aTitulos})
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STWVldVlFinal()
Chamada da função responsavel por validar se o valor informado no 
no campo Valor final esta correto

@author  Varejo
@version P11.8
@since   20/01/2016
@return  
/*/
//--------------------------------------------------------
Function STWVldVlFinal(nGetVlrTot, nGetTotOrig, nVlrAdicio )
Local lRet	:= .T.
Local nVlrTitulo	:= nGetTotOrig + nVlrAdicio

// Valor informado para pagamento deve ser no minimo o valor de ( (Acrescimo + Juros + Multa) - Desconto )
If nGetVlrTot > nVlrTitulo
	STFMessage(ProcName(0), "STOP", STR0027) //"Valor digitado maior do que o valor pendente no titulo."
	STFShowMessage(ProcName(0))
	lRet := .F.
ElseIf nGetVlrTot < nVlrAdicio
	STFMessage(ProcName(0), "STOP", STR0047 ) //"Valor digitado menor do que o valor pendente no titulo."
	STFShowMessage(ProcName(0))
	lRet := .F.		
EndIf
 
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STWSCliLoj()
Função responsavel por setar o codigo do cliente e da loja quando
o cliente for selecionado no Menu F6

@author  Varejo
@version P11.8
@since   22/07/2016
@return  
/*/
//--------------------------------------------------------
Function STWSCliLoj(cCodCli, cCodLoja)

Local lRet	:= .T.

Default cCodCli	:= ""
Default cCodLoja	:= ""

If !Empty(cCodCli) .And. !Empty(cCodLoja)
	cCodCliTit		:= cCodCli 
	cCodLojaTit	:= cCodLoja
Else
	lRet := .F.	 
EndIf 

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STWGCliLoj()
Função responsavel por recuperar o codigo do cliente e da loja do
cliente selecionado no Menu F6

@author  Varejo
@version P11.8
@since   22/07/2016
@return  
/*/
//--------------------------------------------------------
Function STWGCliLoj()

Local aRet	:= {}

aAdd(aRet,cCodCliTit)
aAdd(aRet,cCodLojaTit)

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STWRetMsg()
Quando erro conhecido/tratado/esperado, converte texto que recebeu da retaguarda para um formato amigavel para usuario nao tecnico(caixa)
@author  Varejo
@version P11.8
@since   20/01/2016
@return  
/*/
Static Function STWRetMsg( cMsgErro )
Local cRet			:= ""
Local nPosIni		:= 0
Local nPosFim		:= 0
Local cTipoFalha	:= ""
Local cDetFalha	:= ""

Default cMsgErro := ""

//Verifica se erro de registro alocado por outro usuario
//nPosIni := At("Lock failed On Alias=SE1",cMsgErro)
nPosIni := At("Lock failed On Alias",cMsgErro)
If nPosIni > 0
	cTipoFalha := "Lock failed On Alias"
EndIf

Do Case

	Case cTipoFalha == "Lock failed On Alias"				//Falha por motivo registro alocado na retaguarda
		
		cTipoFalha := SubStr(cMsgErro,nPosIni,24) 		//Captura lock com nome da tabela : "Lock failed On Alias=SE1"
		
		nPosIni := At("Nome do Usuario : ",cMsgErro) 		//captura nome do usuario que alocou o registro		
		If nPosIni > 0
			nPosFim :=	At(" ",SubStr(cMsgErro,nPosIni+18))	//procura primeira espaco vazio apos inicio da descricao do nome do usuario 
			cDetFalha += "[" + AllTrim(SubStr(cMsgErro,nPosIni+18,nPosFim)) + "]"  
		EndIf
				
		Do Case
		
			Case cTipoFalha == "Lock failed On Alias=SE1"				
				cRet := STR0032 + cDetFalha						//"O Título selecionado(SE1) estava em uso por outro usuário:" 
								
			Case cTipoFalha == "Lock failed On Alias=SE8"		
				cRet := STR0033 + cDetFalha						//"O Registro de Saldo Bancário(SE8) estava em uso por outro usuário:"
				
			Case cTipoFalha == "Lock failed On Alias=SA6"		
				cRet := STR0034 + cDetFalha						//"O Registro de Bancos/Caixa(SA6) estava em uso por outro usuário:"

			Case cTipoFalha == "Lock failed On Alias=SA1"		
				cRet := STR0035 + cDetFalha						//"O Cadastro de Cliente do título selecionado estava em uso por outro usuário:"
								
			OtherWise
				cRet := STR0036 + SubStr(cTipoFalha,22,3)+STR0037 + cDetFalha	//"Registro da tabela:" ##	" estava em uso por outro usuário:"  
				
		EndCase
				
	OtherWise
	
		//Tratamento genérico
		cRet := STR0038 + Chr(13) + cMsgErro		//"Ocorreu um evento inesperado na Retaguarda: " 
		
EndCase  

Return cRet 
//--------------------------------------------------------
/*/{Protheus.doc} StwRecArr()
Realiza a geração dos dados do título e movimento bancário do recebimento
@param aListTitles - Títulos retornados pela rotina de consulta de títulos
@param aCompTit - Titulos utilizadas na compensação
@param aMovTitulos - Array para geração de SE5 local (para ser exibido no fechamento de caixa)
@param aCompNCC  - Nccs utilizadas para compensação
@param aListDropTitles - Array com a lista de titulos (aParametros) a baixar na retaguarda
@param aSE5Relacao - Array com a relação forma de pagmento x baixa de titulos x valores
@param aMdlGrd - Model de Pagamentos
@param aMovForma - Array para geração de SE5 local (para ser exibido no fechamento de caixa por forma)
@param cUserName - Usuário que realizou o recebimento
@param aNumCheq - Informações dos cheques
@param cMV_LJRECEB - Parâmetro MV_LJRECEB
@param aTitSe1 - Array com as formas a serem gerados titulos no SE1 apos a baixa do titulos (para serem compensados posteriormente - CH/CC/CD)
@param lContingency - Recebimento em contingencia (offline)?
@param cCliente - Cliente associado ao título
@param cLojaCli - Loja do Cliente associado ao título
@param oWFReceipt - Objeto de Recebimento
@param aFormas - Formas de pagamento do recebimento
@param nValorRec - Valor recebido offline
@author  Varejo
@version P11.8
@since   26/01/2017
@return  nSaldoCr - Saldo do título para gerar uma NCC
/*/
//--------------------------------------------------------
//Tratamento do Array de Recebimento de títulosd
Function StwRecArr(aListTitles		, aCompTit		, aMovTitulos	, aCompNCC	, ;
					aListDropTitles	, aSE5Relacao	, aMdlGrd		, aMovForma	, ;
					cUserName		, aNumCheq		, cMV_LJRECEB	, aTitSe1	, ;
					lContingency	, cCliente		, cLojaCli		, oWFReceipt, ;
					aFormas			, nValorRec		)
					
Local nI 			:= 0 	//Contador de títulos
Local aTitulos 		:= {} 	//titulos
Local nC 			:= 0	//Contador de Títulos
Local nPosTit 		:= 0	//Posição do título		  
Local lPrimBaixa 	:= .T. 	//Primeira baixa
Local nPrimMulta	:= 0 	//Primeira Multa
Local nPrimJuros	:= 0 	//Primeiro Juros
Local nPrimDescon	:= 0 	//Primeiro Desconto
Local cFormaBx  	:= "" 	//Forma de Baixa
Local nSaldoTit 	:= 0 	//Saldo do Título
Local cNumCheq		:= 0 	//Numero do Cheque
Local nCH 			:= 0 	//Contador de Cheque
Local nValorAbate 	:= 0 	//Valor de Abatimento
Local nTotPago 		:= 0 	//total Pago
Local nSaldoCr 		:= 0 	//Saldo Credor 
Local cInfoTit 		:= "" 	//Chave do Título
Local nDifRec 		:= 0	//Diferença a receber
Local nValTroco		:= 0
Local aParametros 	:= {}

Default aListTitles 	:= {} 
Default aCompTit 		:= {}
Default aMovTitulos 	:= {}
Default aCompNCC 		:= {}
Default aListDropTitles := {} 
Default aSE5Relacao 	:= {} 
Default aMdlGrd 		:= {}
Default aMovForma 		:= {}
Default cUserName 		:= {} 
Default aNumCheq 		:= {} 
Default cMV_LJRECEB 	:= ""
Default aTitSe1 		:= {}
Default lContingency 	:= .F. 
Default cCliente 		:= ""
Default cLojaCli 		:= "" 
Default oWFReceipt 		:= NIL
Default aFormas 		:= {} 
Default nValorRec 		:= 0

nDifRec := nValorRec

If lContingency .AND. Len(aListTitles) = 0 .AND. ValType(oWFReceipt) == "O"

	aListTitles := {}
	
	aAdd( aListTitles, Array(25) )
	aFill(aListTitles[1], 0)
	aListTitles[1][TIT_SELE] := .T.  							// Posicao logica.
	aListTitles[1][TIT_PREF] := oWFReceipt:cPrefix				// Prefixo do titulo.
	aListTitles[1][TIT_NUME] :=	oWFReceipt:cNumber				// Titulo.
	aListTitles[1][TIT_PARC] := oWFReceipt:cParcel				// Parcela.
	aListTitles[1][TIT_VREA] := Ctod("") 						// Vencimento real.
	aListTitles[1][TIT_VALO] := oWFReceipt:nValueContingency	// Valor.
	aListTitles[1][TIT_RECE] := oWFReceipt:nValueContingency 	// Recebimento.
	aListTitles[1][TIT_TIPO] := ""								// Tipo.
	aListTitles[1][TIT_CONT] := oWFReceipt:cContrato			// Contrato.
	aListTitles[1][TIT_CLIE] :=	oWFReceipt:cCode				// Cliente.
	aListTitles[1][TIT_LOJA] :=	oWFReceipt:cBranch				// Loja.
	aListTitles[1][TIT_FILI] :=  ""     						// Filial.
	aListTitles[1][TIT_CACR] :=	.F.								// Posicao logica.
	aListTitles[1][TIT_VENC] := Ctod("") 						// Vencimento original.
	aListTitles[1][TIT_LOCK] := ""								// Cod de uso do Registro
	aListTitles[1][TIT_DTBX] :=	Ctod("")						// Dt. da baixa
	aListTitles[1][TIT_SALD] :=	oWFReceipt:nValueContingency	// Saldo do titulo
	
	nValorRec := oWFReceipt:nValueContingency
EndIf

For nI := 1 To Len( aListTitles )
	If aListTitles[nI][TIT_SELE] 					//Titulo Selecionados?
		LjGrvLog( "Recebimento_Titulo", "Titulo SELECIONADO(aListTitles[nI])",aListTitles[nI])
		nSaldoTit := aListTitles[nI][TIT_RECE] - aListTitles[nI][TIT_MULT] - aListTitles[nI][TIT_JURO] + aListTitles[nI][TIT_DESC]
		Aadd(aTitulos, {nI,;						//1-Posição original do titulo 
						(nSaldoTit) ,; 				//2-Saldo
						aListTitles[nI][TIT_MULT],; //3-Multa
						aListTitles[nI][TIT_JURO],; //4-Juros
						aListTitles[nI][TIT_DESC]}) //5-Desconto

		//Para compensar com nccs caso necessário			
		aAdd(aCompTit, {Nil,;						//1-Nil
						aListTitles[nI][TIT_MULT],; //2-Multa
						aListTitles[nI][TIT_JURO],; //3-Juros
						aListTitles[nI][TIT_DESC],; //4-Desconto
						aListTitles[nI][TIT_RECN]}) //5-Recno

		aAdd(aMovTitulos, aListTitles[nI] ) 
		
	EndIf
Next

//IMPORTANTE:
//Este tratamento abaixo consiste na no abatimento dos titulos de acordo com as formas de pagamento,
//ou seja, enquanto o valor da forma de pagamento utilizada for maior que o valor do titulo, será usada a forma.
//Assim que a forma acabar seu saldo, será utilizada outra forma para baixar o titulo. Ate o momento em que os dois
//se acabem. 
//Obs.:Este tratamento nao comtempla baixas parcial, pois ate o momento o totvs pdv nao contempla essa funcionalidade.

nC := 0	
For nC := 1 to Len(aMdlGrd)
	aAdd(aFormas,{	aMdlGrd[nC, 09]				,; // 9 Forma de pagamento
					aMdlGrd[nC, 10]				,; //10 Valor da forma de pagamento
					aMdlGrd[nC, 01]})		
						
	nTotPago += aMdlGrd[nC, 10]
Next nC 

If nValorRec > 0
	nValTroco := nTotPago - nValorRec
EndIf

nCH := 1
While (Len(aTitulos) > 0 .And. Len(aFormas) > 0)

	//** Tratamento para baixa **
	nPosTit   := aTitulos[1][1]	//Atualiza posição do titulo original

	// Os valores de Multa, Juros e Descontos serao aplicados somente na primeira baixa de cada titulo
	// Assim, se nao for a primeira baixa estes campos sao zerados no array
	If lPrimBaixa
		nPrimMulta	:= aListTitles[nPosTit][TIT_MULT]
		nPrimJuros	:= aListTitles[nPosTit][TIT_JURO]
		nPrimDescon	:= aListTitles[nPosTit][TIT_DESC]
		aTitulos[1][2] += (nPrimMulta + nPrimJuros - nPrimDescon)
	Else
		nPrimMulta	:= 0
		nPrimJuros	:= 0
		nPrimDescon	:= 0
	EndIf
	
	//Atualiza a forma de pagamento
	cFormaBx  := AllTrim(aFormas[1][1])

	//Atualiza valor da forma de pagamento
	nVlForma  := aFormas[1][2]

	//Atualiza saldo do titulo
	nSaldoTit := aTitulos[1][2]
	
	// Tratamento para pegar o numero do Cheque
	If cFormaBx == "CH"
		cNumCheq := aNumCheq[nCH]
		
		If nVlForma <= nSaldoTit
			nCH++	
		EndIf
	EndIf

	//Caso o valor da forma seja maior significa que o restante de seu valor
	//sera usado no proximo titulo
	If nVlForma > nSaldoTit
		nValorAbate := nSaldoTit
	Else
		//Caso o valor do titulo seja maior que o valor da forma de pgto
		//significa que sera uma baixa parcial do titulo com a forma
		nValorAbate := nVlForma
	EndIf

	//Abate os valores de baixa dos respectivos arrays de controles
	aFormas[1][2]	-= nValorAbate
	aTitulos[1][2]	-= nValorAbate
	nDifRec -= nValorAbate
	
	//Subtrai o valor pago
	nTotPago -= nValorAbate

	//Quando a forma for NCC NÃO pode ser incluida no array de baixas a serem realizadas, pois a mesma será 
	//compensada primeiramente à baixa. Porem faz-se necessário calcular a simulação da sua baixa para que não ocorra
	//a relação de titulos compensados e o mesmo estar na baixa da forma. (Cenario de NCC + Formas de pgto + baixa de varios titulos).
	If  !(cFormaBx == "CR" .And. Len(aCompNcc) > 0)
		 
		//Parametros para função de baixa na retaguarda
		aParametros := {}
		Aadd(aParametros, cMV_LJRECEB) 						//1
		Aadd(aParametros, aListTitles[nPosTit][TIT_PREF]) 	//2
		Aadd(aParametros, aListTitles[nPosTit][TIT_NUME]) 	//3
		Aadd(aParametros, aListTitles[nPosTit][TIT_PARC]) 	//4
		Aadd(aParametros, aListTitles[nPosTit][TIT_VREA]) 	//5
		Aadd(aParametros, aListTitles[nPosTit][TIT_VALO])	//6
		Aadd(aParametros, nPrimMulta) 						//7
		Aadd(aParametros, nPrimJuros) 						//8
		Aadd(aParametros, nPrimDescon)						//9
		Aadd(aParametros, nValorAbate)						//10
		Aadd(aParametros, aListTitles[nPosTit][TIT_TIPO])	//11
		Aadd(aParametros, aListTitles[nPosTit][TIT_CONT])	//12
		Aadd(aParametros, aListTitles[nPosTit][TIT_FILI])	//13
		Aadd(aParametros, cFormaBx)							//14
		Aadd(aParametros, lPrimBaixa)						//15
		Aadd(aParametros, nPrimMulta)						//16
		Aadd(aParametros, nPrimJuros)						//17
		Aadd(aParametros, nPrimDescon)						//18
		Aadd(aParametros, 0)								//19
		Aadd(aParametros, {})								//20
		Aadd(aParametros, .F.)								//21
		Aadd(aParametros, cUserName)						//22
		Aadd(aParametros, aListTitles[nPosTit][TIT_ABAT])	//23
		Aadd(aParametros, {})								//24
		Aadd(aParametros, {})								//25
		Aadd(aParametros, cNumCheq)							//26
		Aadd(aParametros, {})								//27

		//Este array faz com que seja criada corretamente as tabelas SLV na retaguarda
		//De forma que junto com o controle de baixa de titulo acima
		//seja respeitado os valores das baixas na geração da SLV
		aAdd(aSE5Relacao,{	cFormaBx						,; //1-forma de pagamento utilizadas
							nValorAbate						,; //2-Valor de abate do titulo para a forma
							aListTitles[nPosTit][TIT_PREF]	,; //3-Prefixo do titulo
							aListTitles[nPosTit][TIT_NUME]	,; //4-Numero do titulo
							aListTitles[nPosTit][TIT_PARC]	,; //5-Parcela do titulo
							aListTitles[nPosTit][TIT_FILI]	,; //6-Filial de origem
							aFormas[1,3]					}) //7-Ordem da forma de pagamento

		aAdd(aMovForma, aSE5Relacao[Len(aSE5Relacao)])

		//*
		//**
		//***
		//**** Tratamento para Inclusao de titulo SE1 (Formas de pagamentos diferente de R$) ****
		cCliente := aListTitles[nPosTit][TIT_CLIE]
		cLojaCli := aListTitles[nPosTit][TIT_LOJA]

		cInfoTit := aListTitles[nPosTit][TIT_PREF]+aListTitles[nPosTit][TIT_NUME]+aListTitles[nPosTit][TIT_PARC]

		//Se ja foi incluido no array nao precisa incluir novamente
		If aScan(aTitSe1, {|x| cInfoTit == x[2]+x[3]+x[4] }) == 0
			aAdd(aTitSe1,{	.T.								  ,;
						aListTitles[nPosTit][TIT_PREF],;
						aListTitles[nPosTit][TIT_NUME],;
						aListTitles[nPosTit][TIT_PARC],;
						aListTitles[nPosTit][TIT_VREA],;
						aListTitles[nPosTit][TIT_VALO],;
						aListTitles[nPosTit][TIT_MULT],;
						aListTitles[nPosTit][TIT_JURO],;
						aListTitles[nPosTit][TIT_DESC],;
						aListTitles[nPosTit][TIT_RECE],;
						aListTitles[nPosTit][TIT_TIPO],;
						aListTitles[nPosTit][TIT_CONT],;
						aListTitles[nPosTit][TIT_CLIE],;
						aListTitles[nPosTit][TIT_LOJA],;
						aListTitles[nPosTit][TIT_FILI],;
						aListTitles[nPosTit][TIT_RECN],;
						aListTitles[nPosTit][TIT_ACRS],;
						aListTitles[nPosTit][TIT_CACR],;
						aListTitles[nPosTit][TIT_ABAT],;
						aListTitles[nPosTit][TIT_VENC],;
						aListTitles[nPosTit][TIT_LOCK],;
						aListTitles[nPosTit][TIT_MOED],;
						aListTitles[nPosTit][TIT_INTE],;
						aListTitles[nPosTit][TIT_DTBX],;
						aListTitles[nPosTit][TIT_SALD]})
		EndIf

	EndIf

	//Deletando o titulo do array de controle caso seu saldo 
	//seja zero ou negativo, pois o mesmo não sera mais usado
	If aTitulos[1][2] <= 0
		aDel(aTitulos,1)
		aSize(aTitulos, len(aTitulos)-1)
		lPrimBaixa := .T.
	Else
		lPrimBaixa := .F.
	EndIf

	//Deletando a forma de pgto do array de controle caso seu saldo
	//seja zero ou negativo, pois o mesmo não sera mais usado
	If aFormas[1][2] <= 0
		aDel(aFormas,1)
		aSize(aFormas, len(aFormas)-1)
	ElseIf Len(aFormas) == 1 .And. Len(aTitulos) <= 0 .And. nValTroco == 0
		If lContingency
			nValTroco := 0
		Else
			nValTroco := aFormas[1][2]
		EndIf 
	EndIf
	
	If Len(aParametros) > 0
		Aadd(aParametros, nValTroco)					//28 - TROCO
		Aadd(aParametros, 1)					//29
		Aadd(aListDropTitles, aParametros)
	EndIf

End

//Calcula o Valor da NCC a ser gerada - Valor recebido - Valor do Título (em caso de recebimento off-line)
If nValorRec = 0 
	nSaldoCr :=	nTotPago
Else
	nSaldoCr := nDifRec 
EndIf	
		  
Return nSaldoCr

//-------------------------------------------------------------------
/*/{Protheus.doc} STWReCoHost
Verifica Conexão com o Host
@author  Vendas & CRM
@version P11.8
@since   26/01/2017
@return lConnect - Conectado com o Host
@obs
@sample lConnect := STWReCoHost()
/*/
//-------------------------------------------------------------------
Static Function STWReCoHost()
Local lConnect    := .F.								//Conectou?

//Testa a comunicacao atraves da STFTestRemoteExecute
lConnect := STFTestRemoteExecute() 

Return lConnect


//------------------------------------------------------------------------------   
/*/{Protheus.doc} GetParcValor
Retorna o valor origem da parcela
@param	 nI		Posicao da parcela no array aListTitles
@author  Varejo
@version P11.8
@since   05/01/2018
@return	 Valor origem da parcela
@obs     
@sample
/*/
//------------------------------------------------------------------------------   
Method GetParcValor(nI) Class STWReceiptTitle

Local nValor := 0   	//Retorno

Default nI 		:= 0

If nI > 0
	nValor := Self:aListTitles[4][nI][TIT_VALO]
EndIf

Return nValor