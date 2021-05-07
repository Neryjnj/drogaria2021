#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWCREDITANALYSISINTEGRATION.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} STWAvalCRDIntegration

Rotina de integracao do POS com o SIGACRD. Chama a CRDxVenda, que avalia o credito e realiza a transacao de venda.
@param 
@author  Varejo
@version P11.8
@since   03/09/2012
@return	lRet - .T. se o credito foi aprovado / .F. se o credito foi reprovado
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWAvalCRDIntegration(aParcelas,aRecCrd)

Local aArea			:= GetArea()
Local aDadosCrd 	:= {}		//para CRDxVenda()
Local aParcVda		:= {}
Local aParcCRD		:= {}
Local aProdCrd		:= {}
Local aRetCrd			:= {}
Local cOrcam		:= Alltrim(STBRetCup())
Local cCliente		:= STDGPBasket("SL1","L1_CLIENTE")
Local cLojaCli		:= STDGPBasket("SL1","L1_LOJA")
Local cItemCond		:= STBGetCdPg()
Local cVendLoja		:= STDGPBasket("SL1","L1_VEND")
Local oTotal  		:= STFGetTot() 					// Recebe o Objeto totalizador
Local nVlrTotal		:= oTotal:GetValue("L1_VLRTOT") // Valor total da venda 
Local nVlrAcreTot	:= 0
Local nTotAcres 	:= 0
Local nMoedaParc	:= 0
Local nI			:= 0
Local lCheque		:= .F.
Local lRet			:= .T.
Local cRespForcada	:= ""
Local aCrdCliente	:= {"",""}		//Seleção Cartão/CNPJ para Integração CRD
Local aDadosCli		:= {}			//Dados do Cartão/CNPJ para Integração CRD
Local cContrato		:= ""			//Retorna o contrato na primeira verificação do CRDxVenda

Default aParcelas   	:= {}
Default aRecCrd   	 	:= {}

//Verifico o CNPJ/CPF e o cartão
If ExistFunc("STBGetCrdIdent")
	aDadosCli := STBGetCrdIdent()
EndIf                        
If Len(aDadosCli) >= 4
	aCrdCliente[2] := aDadosCli[1]  //Numero do cartao
 	aCrdCliente[1] := aDadosCli[2]  //CNPJ/CPF
EndIf

//Monta os dados com as a venda para o sistema de credito fazer a
//checagem do credito e a liberacao da venda
aParcVda := {}
For nI := 1 To Len(aParcelas)
   lCheque     := AllTrim(aParcelas[nI][4])=="CH"
   nMoedaParc  := IIf(cPaisLoc == "BRA", 1, aParcelas[nI][24])
   Aadd(aParcVda,{aParcelas[nI][2],;                								// Data de vencimento
		aParcelas[nI][3],;															// Valor da parcela
		aParcelas[nI][4],;															// Forma de pagamento
		aParcelas[nI][5],;                											// Codigo da administradora ou numero do banco
		aParcelas[nI][6],;                											// Numero do cartao ou cheque
		IIf(lCheque,aParcelas[nI][7],""),;  										// Agencia do cheque
		IIf(lCheque,aParcelas[nI][8],""),;  										// Conta do cheque
		IIf(lCheque,aParcelas[nI][9],""),;  										// RG do cheque
		IIf(lCheque,aParcelas[nI][10],""),;  										// Telefone do portador do cheque
		.F.,;                             											// (Mantido por compatibilidade)
		nMoedaParc })                    											// Moeda da parcela		     		  		     		  
Next nI

aProdCrd := {}
SL2->( DbSetOrder( 1 ))
SL2->( DbSeek( xFilial("SL2") + cOrcam) )
While SL2->( !Eof() ) .AND. SL2->(xFilial("SL2") + cOrcam == L2_FILIAL+L2_NUM )
	AAdd( aProdCrd, { SL2->L2_ITEM,;      //Item do Produto
	                  SL2->L2_PRODUTO,;   //Codigo do Produto
	                  SL2->L2_DESCRI,;    //Descricao do Produto
	                  SL2->L2_QUANT,;     //Quantidade de pecas vendidas
	                  SL2->L2_VRUNIT,;    //Valor unitario do produto
	                  SL2->L2_VLRITEM} )  //Valor total da venda do item
	SL2->( dbSkip() )
	Loop
End

If Len(aParcVda) > 0

	//Estrutura da array aDadosCrd                                   
	//[1] - Numero do cartao                                         
	//[2] - Numero do CPF                                            
	//[3] - Valor da venda (valor liquido)                           
	//[4] - Juros da venda (%)                                       
	//[5] - Numeros de parcelas                                      
	//[6] - Venda forcada (1-Venda Normal 2-Venda forcada)           
	//[7] - Responsavel pela venda forcada                           
	//[8] - Array com as parcelas para o financiamento               
	//      [1] - Data de vencto                                     
	//      [2] - Valor da parcela                                   
	//      [3] - Forma de pagto                                     
	//      [4] - Administradora financeira                          
	//[9] - Loja que solicitou a transacao                           
	//[10] - Numero do PDV que solicitou a transacao                 
	//[11] - Caixa que solicitou a transacao                         
	//[12] - Numero do Orcamento selecionado                         
	//[13] - Produtos contido na venda atual.                        
	//      [1] - Item do produto                                    
	//      [2] - Codigo do produto                                  
	//      [3] - Descricao do produto                               
	//      [4] - Quantidade de pecas                                
	//      [5] - Valor unitario do produto                          
	//      [6] - Valor total do item do produto                     
	//[14] - Parcelas de uma venda.                                  		
	//      [1] - Data de vencto                                     
	//      [2] - Valor da parcela                                   
	//      [3] - Forma de pagto                                     
	//      [4] - Administradora                                     
	//      [5] - Numero do cartao / cheque                          
	//      [6] - Agencia - Cheque                                   
	//      [7] - Conta - Cheque                                     
	//      [8] - Rg - Cheque                                        
	//      [9] - Telefone - Cheque                                  
	//      [10] - Valor logico                                      
	//      [11] - Moeda da parcela (localizacoes)                   
	//      [12] - ID para identif.da forma de pagto na operação TEF 
	//      [13] - Acrescimo financeiro 							 
	//      [14] - Cpf/Cnpj do Cliente				                 
	//[15] - Filial do Caixa que esta sendo utilizado.               
	//[16] - Codigo do cliente                                       		
	//[17] - Loja do cliente                                         		
	//[18] - Nome do usuario                                         		
	//[19] - Condicao de Pagamento                                   		
	//[20] - Modulo que chamou a avaliacao de credito                		
	//[21] - Codigo do vendedor                                      

	aDadosCrd := {}
	aAdd( aDadosCrd, aCrdCliente[2] )													// 01 Numero do cartao
	aAdd( aDadosCrd, aCrdCliente[1] )													// 02 CNPJ/CPF
	aAdd( aDadosCrd, nVlrTotal+ nTotAcres )												// 03 Valor da venda
	aAdd( aDadosCrd, (nVlrAcreTot * 100 / (nVlrTotal-nVlrAcreTot)) )				// 04 Juros da venda
	aAdd( aDadosCrd, Len(aParcVda) )													// 05 Numero de parcelas
	aAdd( aDadosCrd, 1 )																	// 06 Venda forcada
	aAdd( aDadosCrd, cRespForcada )														// 07 Responsavel pela venda forcada
	aAdd( aDadosCrd, aClone(aParcVda) )													// 08 Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
	aAdd( aDadosCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME) ) // 09 Loja da venda
	aAdd( aDadosCrd, STFGetStation("LG_PDV"))											// 10 PDV
	aAdd( aDadosCrd, xNumCaixa() )														// 11 Caixa
	aAdd( aDadosCrd, cOrcam )															// 12 Num. do orcamento
	aAdd( aDadosCrd, aClone(aProdCrd) )													// 13 Produtos selecionados numa venda
	aAdd( aDadosCrd, aClone(aParcVda) )													// 14 Parcelas de uma venda
	aAdd( aDadosCrd, FWGETCODFILIAL )													// 15 Filial do Caixa que esta sendo utilizado 	
	aAdd( aDadosCrd, cCliente )															// 16 Codigo do cliente
	aAdd( aDadosCrd, cLojaCli )															// 17 Loja do cliente  
	aAdd( aDadosCrd, cUserName )															// 18 Nome do usuario		
	aAdd( aDadosCrd, cItemCond )												  			// 19 Condicao de Pagamento
	aAdd( aDadosCrd, "FRT"     )												  			// 20 Modulo chamador		
	aAdd( aDadosCrd, cVendLoja )												  			// 21 Codigo do vendedor
    
	aRetCrd := aClone(CrdxVenda( "1"   	,@aDadosCrd  	, Nil   , .T.  ,;
	                              Nil   ,"43" 			, Nil	, @aRecCrd))
	
	If Len(aRetCrd) < 5		//Errorlog
		STFMessage( ProcName(0),"STOP", STR0001) //"Erro na transmissão da análise de crédito" 
		STFShowMessage(ProcName(0))
		lRet := .F.
	EndIf
	
	If lRet
		//Verifica se eh venda financiada
		If Len(aDadosCrd[8]) > 0
			//O array recebe as parcelas que foram financiadas
			aParcCrd:= aClone(aDadosCrd[8])
			If !aRetCrd[5]
				
				//A liberacao do credito foi confirmada  
				lTransCrd   := .T.
				
				//Alimenta as variaveis referente aos dados do cliente                  
				// Verifica se a venda foi off-line 
				If aRetCrd[1] == 2 
					lForcada   := .T.
					If HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())
						If Empty(AllTrim(cCliente)) .And. Empty(AllTrim(cLojaCli))
					 		cCliente	:= SuperGetMV("MV_CLIPAD")
					 		cLojaCli	:= SuperGetMV("MV_LOJAPAD")
					 	EndIf
					Else
						cCliente	:= SuperGetMV("MV_CLIPAD")	
						cLojaCli	:= SuperGetMV("MV_LOJAPAD")
					EndIf
				Else
					cCliente	:= aDadosCrd[16]
					cLojaCli	:= aDadosCrd[17]
				EndIf
			Else
				
				//A liberacao do credito nao foi confirmada  
				cCliente	:= aDadosCrd[16]
				cLojaCli	:= aDadosCrd[17]
				lTransCrd	:= .F.
			EndIf
	
		   //[1]-CPF [2]-Numero do Cartao Private Label
		   aCrdCliente[1]	:= aDadosCrd[2]  		
		   aCrdCliente[2]	:= aDadosCrd[1]  				
		   cContrato 	   	:= aRetCrd[4]		
		Else
			cContrato    := Space(TamSx3("MAH_CONTRA")[1])		   
		EndIf
		
		STDSPBasket("SL1","L1_CONTRA",cContrato)	//Indispensável para subida via GrvBatch, excluindo o MAL e gravando o SE1 (E1_NUMCRD).  
		
		If ValType(aRetCrd[5]) == "L" 
			// aRetCrd[5] recebe .T. caso a venda tenha sido rejeitada. Portanto, lRet recebe o seu inverso.
			lRet := !aRetCrd[5]
		EndIf
	EndIf	 

	If lRet	.AND. lTransCrd //Transação
		 aRetCrd := CrdxVenda( "2" 	 ,aDadosCrd   	,cContrato  ,.T.   ,;
			                          Nil  	 ,Nil			,Nil		,aRecCrd)
	Else	//Cancelamento
	    aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,cContrato   ,.T.   ,;
			                           NIL  ,NIL )		
		STDSPBasket("SL1","L1_CONTRA","")  
	EndIf

EndIf	

RestArea(aArea)

Return lRet

