#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBCANCELSALE.CH"

Static lLjcFid	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()//Indica se a recarga de cartao fidelidade esta ativa
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSIsProgressSale
Verifica se a venda está em andamento

@param 	 nenhum
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se a venda está em andamento ou não
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSIsProgressSale()

Local lRet 				:= .F.				// Retorna se a venda está em andamento ou não
Local aRet				:= {}				// Armazena retorno impressora
Local aIsOpenReceipt   	:= { "5" , "" }	// Armazena retorno se o cupom está aberto

/*/
	Se usa impressora Fiscal, verifica cupom aberto
/*/
If STFUseFiscalPrinter() 

	/*/
		Verifica cupom aberto
	/*/	
	aRet := STFFireEvent( 	ProcName(0)						, ; // Nome do processo
   							"STPrinterStatus"						, ; // Nome do evento
					   		aIsOpenReceipt	  					)		
					   						
	If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"						    
		If aRet[1] == 7
  			lRet := .T.	// Aberto
  		Else
   			lRet := .F.	// Fechado
		EndIf
	EndIf
	
	/*/
		Verifica se existe venda com apenas itens não-fiscais
	/*/
	If !lRet
	
		If STDPBLength("SL2") > 0
			
			If !STBExistItemFiscal()			
				lRet := .T.
			EndIf
			
		EndIf	
		
	EndIf

Else 
	
	/*/
		Verifica se existe item registrado
	/*/	
	If STDPBLength("SL2") > 0		
		lRet := .T.	
	Else	
		lRet := .F.		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSNumPrinter
Busca o Ultimo Cupom da Impressora

@param	 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cNumDoc						Retorna o ultimo cupom da impressora
@obs     								Se der erro na impressora retorna "ERROR", se nao usa impressora retorna vazio
@sample
/*/
//-------------------------------------------------------------------
Function STBCSNumPrinter()

Local cNumDoc 		:= ""					// Retorno funcao
Local aPrinter		:= {}					// Armazena retorno da impressora
Local aDados 			:= { "" , Nil }		// Dados do evento

aPrinter := STFFireEvent( ProcName(0) , "STGetReceipt" , aDaDos )
			
If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aDados) < 1     

	STFMessage("STCancelSale","STOP", STR0003) //Falha na obtenção do cupom
	STFShowMessage("STCancelSale") 
	
	cNumDoc := "ERROR"

Else	
	cNumDoc := aDados[1]	
EndIf

Return cNumDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSGetPDV
Busca o PDV atual

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   aRet					Retorna se obteve e a numeração do PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSGetPDV()

Local aPrinter	:= {}			// Armazena retorno da impressora
Local aRet		:= {}			// Retorno funcao
Local aPDV		:= {""}			// Retorno evento get PDV

If STFUseFiscalPrinter()
	/*/
		Get PDV Impressora
	/*/
	aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )
			
	If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
	
		STFMessage("STCancelSale","STOP", STR0003) //Falha na obtenção do cupom
		STFShowMessage("STCancelSale")
		aRet := { .F. , "" }
		
	Else	
		aRet := { .T. , PadR( AllTrim(aPDV[1] ) , TamSx3("L1_PDV")[1] , " " ) }		
	EndIf 
	
Else    
	aRet := { .T. , STFGetStat("PDV") }		
EndIf
		
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCanChoose
Verifica se pode escolher a venda a ser cancelada

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se pode escolher a venda a ser cancelada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCanChoose()

Local lRet := .F.		//	Retorna se pode escolher a venda a ser cancelada

If STFGetCfg("lCanChoose")
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSFiCanCancel
Verifica se é premitido cancelar vendas Finalizadas

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se é permitido cancelar vendas finalizadas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSFiCanCancel()

Local lRet := .T.			// Retorna se é permitido cancelar vendas finalizadas

If STFGetCfg("lFiCanCancel")
	lRet := .F.
	STFMessage("STCancelSale","STOP", STR0004) //Comprovantes de vendas anteriores nao podem ser cancelados
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCanCancel
Verifica se pode Cancelar a Venda em andamento

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return   aRet Retorna array com informacoes do cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSCanCancel(cGetDoc, lProfile, cGetSerie)

Local aRet				:= {}				// Retorno funcao
Local lCanCancel			:= .F.				// Retorna se pode cancelar a venda
Local lIsProgressSale	:= .F.				// Define se a venda está em andamento
Local aProfile			:= {}				// Armazena retorno permissao do usuario
Local cNumLastSale		:= ""				// Numeração da ultima venda
Local cLastDoc			:= ""				// Numeração do ultimo doc do banco
Local cDocPrinter		:= ""				// Numeraçãp do Doc atual da impressora
Local cPDV				:= STFGetStation("PDV")    // Numero do PDV
Local cSuperior			:= ""
Local cDocPed			:= "" //Doc da serie nao fiscal

Default cGetDoc			:= ""
Default lProfile		:= .T.
Default cGetSerie		:= STFGetStation("SERIE")

If STBOpenCash() 

	If lProfile
		aProfile	:= STFProfile( 8 )
		lCanCancel	:= aProfile[1]
		cSuperior	:= aProfile[2]
	Else
		lCanCancel := .T.
	EndIf 	 
	
	If lCanCancel
	    
		lIsProgressSale := STBCSIsProgressSale() // Venda em Andamento?
		
		/*/
			Venda em andamento
		/*/
		If lIsProgressSale
				
			If STFGetCfg("lCanActSale")
			
				If STDPBLength("SL2") == 0 // Permitido apenas o cancelamento da venda corrente com mais de um item lancado
					lCanCancel := .F.
					STFMessage("STCancelSale","STOP", STR0005) //Permitido apenas o cancelamento da venda corrente com mais de um item lançado
				EndIf
				
			EndIf
		    
		   If lCanCancel
		   
				If STFUseFiscalPrinter()
				
					cDocPrinter := STBCSNumPrinter()
					
					If cDocPrinter == "ERROR" 										
						lCanCancel := .F.												
					Else					
						lCanCancel 	:= .T.
						cLastDoc	:= cDocPrinter					
					EndIf
					
				EndIf
				
			EndIf
			
		Else
			/*/
				Venda Finalizada
			/*/		
			
			If !Empty(cGetDoc)	
				cLastDoc		:= cGetDoc
				cNumLastSale	:= STDCSNum(cGetDoc,cPDV,,cGetSerie)
			Else				
				cNumLastSale 	:= STDCSLastSale()	
				cLastDoc		:= STDCSDoc( cNumLastSale )
			EndIf
			
			If Empty(cLastDoc) .AND. ExistFunc("STDGetDocP")
				//Recupera o numedo do documento nao fiscal
				cDocPed := STDGetDocP()
			EndIf
			
			If STFUseFiscalPrinter()
			
				cDocPrinter := STBCSNumPrinter()
				
				If cDocPrinter == "ERROR"				
					lCanCancel := .F.					
				EndIf 
				
				If lCanCancel
				
					If !STBCanChoose()
					
						If AllTrim(cLastDoc) == AllTrim(cDocPrinter)					    	
					    	lCanCancel	:= .T.
					    	cLastDoc	:= cDocPrinter					    	 

						ElseIf FindFunction("STDCancTef") .And. STDCancTef(cNumLastSale)
					    	lCanCancel	:= .T.

						Else
							lCanCancel := .F.
							STFMessage("STCancelSale","STOP", STR0006) //A numeração do último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom
						EndIf
					
					EndIf 
					
				EndIf
				
			EndIf
			
		EndIf

	Else
		STFShowMessage("STFProfile")  // "Acesso Negado. O caixa XX não tem permissão para executar a seguinte operação: Cancelamento Cupom"
	EndIf
	
Else

	STFMessage("STCancelSale","STOP", STR0007) // Caixa Fechado
	
EndIf

STFShowMessage("STCancelSale")

If lCanCancel

	AADD( aRet , lCanCancel			)
	AADD( aRet , lIsProgressSale	)
	AADD( aRet , cSuperior			)
	AADD( aRet , cLastDoc	   		)
	AADD( aRet , cNumLastSale  		)
	AADD( aRet , cDocPed  			)
	AADD( aRet , cGetSerie 			)
	
Else 

	AADD( aRet , .F.				)
	AADD( aRet , .F.				)
	AADD( aRet , ""					)
	AADD( aRet , ""			   		)
	AADD( aRet , ""			   		)
	AADD( aRet , ""			   		)
	AADD( aRet , ""		 			)
	
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCanLastCancel
Valida se pode cancelar Ultimo Cupom

@param   cNumDocPrint			Numero do documento da Impressora
@param   cNumSale					Numero da Venda a ser cancelada
@param   cNumDoc					Numero do Documento da venda a ser cancelada
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se pode cancelar
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSCanLastCancel( cNumDocPrint , cNumSale , cNumDoc )

Local lRet 				:= .T.				// Retorna se Pode Cancelar

Default cNumDocPrint  	:= ""
Default cNumSale  		:= ""
Default cNumDoc  		:= ""

ParamType 0 Var  cNumDocPrint 	As Character	 Default ""
ParamType 1 Var  cNumSale 		As Character	 Default ""
ParamType 2 Var  cNumDoc 		As Character	 Default ""

If STFGetCfg("lVldCanLastSale")  // Configuração para Bloquear se a ultima venda nao eh o Ultimo Cupom
	// Num da Impressora Diferente do Num da ultima venda Bloqueia
	If cNumDocPrint <> cNumDoc
		lRet := .F.
		STFMessage("STCancelSale","STOP", STR0008) //"O último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom.")
	Endif
EndIf

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSUseDocChoose
Verifica se escolhe venda a ser Cancelada a Partir do L1_DOC

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se escolhe por DOC
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBCSUseDocChoose()

Local lRet := .F.		// Retorna se escolhe por DOC

// Verifica se escolhe a venda a partir do Ultimo L1_DOC
If STFGetCfg("lseDocChoose")
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSFactura
Valida se Cancela a Venda verificando se pertence a uma Factura Global

@param   cNumSale					Numero da Venda a ser cancelada
@param   cNumDoc					Numero do documento
@param   cPDVPrint				Numero do PDV
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se Pode Cancelar a Venda
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSFactura( cNumSale , cNumDoc , cPDVPrint )

Local lRet				:= .T.			// Retorna se Pode Cancelar a Venda
Local aSale				:= {}			// Armazena dados da venda para analise de factura global
Local oRemoteCall		:= NIL			// Retorna da chamada da funcao na Retaguarda

Default cNumSale  		:= ""
Default cNumDoc  		:= ""
Default cPDVPrint  		:= ""

ParamType 0 Var  cNumSale 		As Character	 Default ""
ParamType 1 Var  cNumDoc 		As Character	 Default ""
ParamType 2 Var  cPDVPrint 	As Character	 Default ""

If STFGetCfg("lGlobFact") // Verifica Factura Global

	// Busca informações da Venda para analise de Factura Global
	aSale := STDCSFactura( cNumDoc , cPDVPrint ) 
	
	oRemoteCall := FWCallFunctionality("FR271CPGlobal", {aSale[1], aSale[2], aSale[3], aSale[4]})
	If oRemoteCall:nStatusCode < 0
		lRet := STFMessage("STCancelSale","YESNO", STR0009) //"A conexao com o servidor de BackOffice por alguma razao se encontra interrompida. Esse cupom pode pertencer a uma Nota Fiscal. Assim mesmo deseja cancelar o cupom de numero " + cNumDoc)	
	Else
		aRet := oRemoteCall:uResult
		lRet := aRet[2]
		Do Case 
			Case AllTrim(aRet) == "GLOBAL"
				STFMessage("STCancelSale","STOP", STR0010) //O cupom nao podera ser cancelado porque pertence a uma Nota Fiscal Global
			Case AllTrim(aRet) == "NFCUPOM"
				STFMessage("STCancelSale","STOP", STR0011) //O cupom nao podera ser cancelado porque foi gerada uma Nota Fiscal sobre cupom
			Case AllTrim(aRet) == "QTDEDEV"
				STFMessage("STCancelSale","STOP", STR0012) //Cupom não poderá ser cancelado, porque foi realizado devolução de um ou mais itens desta venda
			Case AllTrim(aRet) == "BAIXADO"
				STFMessage("STCancelSale","STOP", STR0013) //O cupom nao podera ser cancelado porque ja foi gerada a baixa
		EndCase
	EndIf
EndIf
				
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCancCupPrint
Manda o cancelamento para a impressora

@param   cSupervisor				ID do Usuario Supervisor
@param   cNumDoc					Numero do documento
@param   cNumSale					Numero da Venda
@param   lNFCETSS					NFCe Transmitida pelo TSS?
@param   lForceCancel				Força cancelamento da Venda?
@param   cTipoCanc					Tipo de Cancelamento
@param   lInutiliza					Inutiliza NFCe?
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se cancelou na impressora
/*/
//------------------------------------------------------------------- 
Function STBCSCancCupPrint( cSupervisor , cNumDoc, cNumSale, lNFCETSS,;
 							lForceCancel, cTipoCanc, lInutiliza, cSerie )
Local lRet			:= .T.				// Retorna se cancelou na impressora
Local aPrinter		:= {}				// Armazena Retorno da impressora
Local cCOOCCD		:= ""				// Armazena o Comprovante vinculado (CCD) a ser estornado
Local cNumCup		:= ""				// Armazena o numero do Comprovante vinculado (CCD) menos 1
Local cCpfCnpj		:= ""				// Cnpj/CPF do cliente da venda para o estorno do CCD
Local cMensagem		:= ""				// Mensagem a ser impressa no estorno do CCD

Default cNumSale	:= ""
Default cSupervisor	:= ""
Default cNumDoc		:= ""
Default lNFCETSS	:= .T.
Default lForceCancel:= .F.
Default cTipoCanc	:= ""
Default lInutiliza	:= .F.
Default cSerie		:= STFGetStation("SERIE")

LjGrvLog( "L1_NUM: "+cNumSale+"L1_DOC: "+cNumDoc, "Cancelamento de venda" )  //Gera LOG

If STFUseFiscalPrinter()

	//Solicitar o cancelamento do CCD antes do cancelamento do cupom se tiver.
	cCOOCCD := STBCSNumPrinter()
	cNumCup := PADR(StrZero(Val(AllTrim(cCOOCCD))-1,Len(cCOOCCD)),TamSX3("L1_DOC")[1])
	If !Empty(cNumDoc) .And. AllTrim(cNumDoc) == AllTrim(cNumCup)

		cCpfCnpj  := AllTrim(STDCSLastSale("L1_CGCCLI"))
		cMensagem := "Cancelamento de Comprovante de Credito e Debito"

		aPrinter  := STFFireEvent( ProcName(0) , "STCancelBound" , {cCpfCnpj, "" , "", cMensagem, cCOOCCD } )

		If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0
			lRet := .F.
			STFMessage("STCancelSale","STOP", STR0022) //Erro com a Impressora Fiscal. Não foi efetuado o cancelamento do Comprovante de Credito e Debito (CCD).
		EndIf
	EndIf

	If lRet
		aPrinter := STFFireEvent( ProcName(0) , "STCancelReceipt" , {cSupervisor} )
		If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0
			lRet := .F.
			STFMessage("STCancelSale","STOP", STR0014) //Erro com a Impressora Fiscal. Não foi efetuado Cancelamento do Cupom
		Else
			lRet := .T.
		EndIf
	EndIf
Else        
	/*/
		Se nao utiliza impressora fiscal, retornar .T.
	/*/
	lRet := .T.
	If !lNFCETSS .AND. ExistFunc("LjDNFCeCanc")
		lRet :=  LjDNFCeCanc( @cNumDoc, @cNumSale, lNFCETSS, @cTipoCanc,@lInutiliza, cSerie )
		If lForceCancel .AND. !lRet
			lRet := .T.
			LjGrvLog( "L1_NUM: "+cNumSale+"L1_DOC"+cNumDoc, "Ocorreu erro no cancelamento da NFCe mas a venda será excluída" )  //Gera LOG
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCancGP
Cancelar Vale Presente

@param   cNumSale					Numero da Venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se cancelou VPs
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSCancGP( cNumSale )

Local lRet				:= .T.					// Retorna se cancelou VPs
Local uResult		:= NIL						// Retorno da chamada da funcao na Retaguarda
Local aGiftVoucher		:= {}					// Armazena VP a estornar

Default cNumSale  	:= ""

ParamType 0 Var  cNumSale 	As Character	 Default "" 

aGiftVoucher := STDCSGiftVoucher( cNumsale ) // Busca VPs na Venda

If Len(aGiftVoucher) > 0

	If STBRemoteExecute("LjVpAtiva" ,{aGiftVoucher}, NIL,.T.	,@uResult)
		lRet := uResult
	EndIf
	
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSChkStatusPrint
Verifica STATUS Impressora

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet						Retorna se STATUS da impressora está ok
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSChkStatusPrint()

Local lRet				:= .T.					// Retorna se STATUS da impressora está ok
Local aRet				:= {}					// Armazena retorno impressora
Local aStatusPrint   	:= { "9" , "" }		// Armazena retorno Impressora

/*/
	Se usa impressora Fiscal, verifica cupom aberto
/*/
If STFUseFiscalPrinter() 

	/*/
		Verifica Status
	/*/	
	aRet := STFFireEvent( 	ProcName(0)					   		, ; // Nome do processo
   							"STPrinterStatus"							, ; // Nome do evento
					   		aStatusPrint	  							)	
					   							
	If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"		
					    
		If aRet[1] == 0
  			lRet := .T.
  		Else
   			lRet := .F.
   			STFMessage("STCancelSale","STOP", STR0015) //"Erro com a Impressora Fiscal. Operação não efetuada
		EndIf
		
	EndIf
	
Else
	lRet := .T.
EndIf
	 
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSQuestion
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   lAllNotFiscal		Todos os itens não fiscais
@param   cNumber			Numeração a ser cancelada
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cQuestion			Retorna Pergunta de confirmação
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSQuestion( lIsProgressSale , lAllNotFiscal , cNumber )

Local cQuestion				:= ""		// Mensagem

Default lIsProgressSale		:= .F.
Default lAllNotFiscal		:= .F.
Default cNumber				:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  lAllNotFiscal 		As Logical	 Default .F.
ParamType 2 Var  cNumber   			As Character Default ""

If lIsProgressSale
	/*/
		Venda em andamento
	/*/
	If STFUseFiscalPrinter() 
	
		If STBExistItemFiscal() 		
			cQuestion := STR0016 //Venda em andamento. Realiza o CANCELAMENTO deste Cupom Fiscal?		
		Else		
			cQuestion := STR0017 //Venda em andamento. Realiza o CANCELAMENTO deste Cupom Não Fiscal?			
		EndIf
		
	Else
		
		cQuestion :=  STR0018 //Venda em andamento. Realiza o CANCELAMENTO desta venda?
		
	EndIf
	
Else

	/*/	
		Venda Finalizada
	/*/
	If STBCanChoose()	
		cQuestion := STR0019 + cNumber + ")" //"Deseja cancelar o último cupom emitido (Numero: "		
	Else
		
		If STFUseFiscalPrinter()
		
			If lAllNotFiscal		
				cQuestion := STR0020 //"Realiza o CANCELAMENTO do Cupom não Fiscal. "				
			Else			
				cQuestion := STR0021 + cNumber + " ?"	//"Realiza o CANCELAMENTO do Cupom Fiscal nº "		
			EndIf
		
		EndIf	
	
	EndIf
	
EndIf

Return cQuestion


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSTotalSale
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   cNumberSale		Numeração a ser cancelada (L1_NUM)
@author  Varejo
@version P11.8
@since   29/03/2012
@return   nTotalSale		Retorna o total da venda a ser cancelada
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSTotalSale( lIsProgressSale , cNumberSale )

Local nTotalSale			:= 0 				// Retorna o total da venda a ser cancelada
Local oTotal				:= STFGetTot()		// Totalizador	

Default lIsProgressSale		:= .F.
Default cNumberSale			:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  cNumberSale		As Character Default ""


If lIsProgressSale

	nTotalSale := oTotal:GetValue("L1_VLRTOT") 

Else
	
	If !Empty(cNumberSale)
		
		nTotalSale := STDCSTotalSale(cNumberSale)
		
	EndIf
	
EndIf

Return nTotalSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSNumberSale
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   cDocSale			Numeração do Documento(L1_DOC)
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cDocSale			Retorna o documento
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSNumberSale( lIsProgressSale , cDocSale )

Default lIsProgressSale		:= .F.
Default cDocSale			:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  cDocSale		As Character Default ""

If lIsProgressSale

	cDocSale := STDGPBasket("SL1","L1_DOC")	

Else

	If Empty(cDocSale)
   		
   		/*/
   			Busca o DOC a partir da ultima venda
   		/*/		
		cDocSale := STDCSDoc( STDCSLastSale() )		
		
	EndIf

EndIf

Return cDocSale

//-------------------------------------------------------------------
/*/{Protheus.doc} STBActionCancel
Ação botão de cancelar venda

@param		cGetCanc	Código da venda 
@author	Varejo
@version	P11.8
@since		17/04/2015
@return   
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBActionCancel(cGetCanc, cGetSerie)
Local lEmitNFCe	:= STBGetNFCE()	//valida se é NFC-e ou não
Local cDoc		:= ""			//numero do documento
Local lUseSat	:= STFGetCfg("lUseSAT", .F.) //Utiliza SAT
Local lRet		:= .T.
Local cNFisCanc	:= "" //doc de cancelamento
Local cRetsx5	:= ""			//Tamanho da serie no SX5
Local cMsg		:= ""	//Mensagem referente ao cancelamento do SAT
Local aInfCanSAT:= {}
Local aCancel	:= STIGetCancel() 	//Retornar o array com as informacoes da venda a ser cancelada
Local lDocNf	:= .F. 				//Indica se a venda que esta sendo cancelada eh nao fiscal
Local aProfile	:= {} //Recebe o retorno do STFProfile
Local aSTCSCanDro:= Array(2)

Default cGetCanc := ""
Default cGetSerie := STFGetStation("SERIE")

If ValType(aCancel) == "A" .AND. Len(aCancel) > 5 .AND. !Empty(aCancel[6])
	//Se entrar no IF, significa que eh uma venda nao fiscal vale credito ou vale presente
	lDocNf := .T.
EndIf

If Valtype(lUseSat) = "U"
	lUseSat := .F.
	If lEmitNFCe
		lUseSat := LjUseSat()
	EndIf
EndIf

//Ponto de Entrada ao checar se esse cupom pode cancelar ou não
If ExistBlock("STCANACT")
	LjGrvLog(STDGPBasket("SL1","L1_NUM"),"Antes da execução do PE STCANACT")	
	lRet := ExecBlock( "STCANACT",.F.,.F.,{PadL(AllTrim(cGetCanc),TamSX3("L1_DOC")[1], "0")})
	LjGrvLog(STDGPBasket("SL1","L1_NUM"),"Depois da execução do PE STCANACT",lRet)
	If !lRet
		STIGridCupRefresh() // Sincroniza a Cesta com a interface
		STIRegItemInterface()
		STFMessage(ProcName(), "STOP", "Nao será permitido o cancelamento dessa venda.") //"Nao permitido o cancelamento desta venda."
		STFShowMessage(ProcName())
	EndIf
EndIf

If lRet .And. lEmitNFCe .And. !STBCSIsProgressSale() .And. !lUseSat

	If !lDocNf
		//Ajusta tamanho caso o usuario ano informe os zeros.
		cRetsx5 := Tabela("01", AllTrim(cGetSerie) )
		If !Empty(cRetsx5)
			cGetCanc := PadL(AllTrim(cGetCanc),Len(AllTrim(cRetsx5)), "0")
		Else
			cGetCanc := PadL(AllTrim(cGetCanc),TamSX3("L1_DOC")[1], "0")
		EndIf
	EndIf

	//verifica o SITUA do documento antes de prosseguir com a exclusao
	If STBSitCanc(cGetCanc, cGetSerie)
		If !lDocNf
			STICancelSale(cGetCanc, cGetSerie)
			aSTCSCanDro := {cGetCanc , cGetSerie}
		Else
			If ExistFunc('STWCancNF')
				aProfile := STFProfile( 8 )
				If ValType(aProfile) == 'A' .AND. aProfile[1]
					STWCancNF()
				Else
					lRet := .F.
					LJGrvLog(Nil, "Venda nao foi cancelada porque nao foi informado o superior - L1_DOCPED: ", cGetCanc)
				EndIf
			Else
				lRet := .F.
				LJGrvLog(Nil, "Venda nao foi cancelada porque nao existe a funcao STWCancNF - L1_DOCPED: ", cGetCanc)				
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	
ElseIf lRet .And. lEmitNFCe .And. STBCSIsProgressSale()
	/*Cancela venda quando configurado com nfc-e e esta em andamento*/
	cDoc := STDGPBasket("SL1","L1_DOC")
	aSTCSCanDro := {cDoc ,cGetSerie}
	STWCancelSale(.T.,,,cDoc, "L1_NUM",,)
	STIGridCupRefresh()
	STIRegItemInterface()	
	
Else 
	
	If lRet .And. lUseSat .And. !STBCSIsProgressSale() 	

		DbSelectArea("SL1")
		SL1->( DbSetOrder(2) )	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		If SL1->( DbSeek(xFilial("SL1") + STFGetStation("SERIE") + cGetCanc + STFGetStation("PDV")) )
			aSTCSCanDro := {cGetCanc,cGetSerie}
			aInfCanSAT := STBCSCanCancel(cGetCanc)
			STISetCancel( aInfCanSAT )
			
			lRet :=  aInfCanSAT[1]
			
			If lRet
				// Gera cancelamento SAT
				lRet := IIF(ExistFunc("LJSatxCanc"),LJSatxCanc(.F.,@cNFisCanc),.F.)
			
				If !lRet
					cMsg := StrTran(STR0027,"SAT",cSiglaSat) //"SAT - Venda já cancelada ou excedeu o período de 30 minutos."
				EndIf
			Else
				cMsg := StrTran(STR0031,"SAT",cSiglaSat) //"SAT - Usuário sem permissão para cancelar venda"
			EndIf
			
		Else
			lRet := .F.	
			cMsg := StrTran(STR0028,"SAT",cSiglaSat) //"SAT - Venda não encontrada."
		EndIf	
		
		If !lRet  
			STFMessage(ProcName(), "STOP", cMsg) //"SAT - Venda já cancelada." ou "SAT - Venda não encontrada."
			STFShowMessage(ProcName())
		EndIf		
				    
	EndIf
	
	/*Cancela venda ecf */
	If lRet
		If lUseSat
			STICancel(cGetCanc,cNFisCanc)
		Else	
			STICancel()
		EndIf	
	EndIf
EndIf

If lRet
	STCSCanDro(aSTCSCanDro[1],aSTCSCanDro[2])
EndIf

// Limpa variavel de verificação de regra de desconto por item
STBLimpRegra(.F.)
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSitDoc
Verifica o L1_SITUA do documento antes de permitir o cancelamento

@param		cDoc	Número do documento fiscal 
@author	Varejo
@version	P11.8
@since		21/07/2015
@return   	lRet	Indica se pode continuar com o cancelamento
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Static Function STBSitCanc(cDoc, cSerie)

Local lRet 		:= .T.	//indica se o cancelamento pode continuar
Local cPDV		:= ""	//numero do PDV ( LG_PDV )
Local lDSitDoc	:= FindFunction("STDSitDoc")	//retorna o L1_SITUA do documento fiscal
Local aSitua	:= {}
Local nSpedExc  := SuperGetMV("MV_SPEDEXC",, 72) // Indica a quantidade de horas q a NFe pode ser cancelada
Local nNfceExc  := SuperGetMV("MV_NFCEEXC",, 0)  // Indica a quantidade de horas q a NFCe pode ser cancelada
Local aCancel	:= STIGetCancel() 	//Retornar o array com as informacoes da venda a ser cancelada
Local lDocNf	:= .F. 				//Indica se a venda que esta sendo cancelada eh nao fiscal

Default cSerie := STFGetStation("SERIE")

cPDV := STFGetStation("PDV")

//Tratamento para manter o legado do parametro MV_SPEDEXC 
If nNfceExc <= 0
    nNfceExc := nSpedExc
EndIf 

//se nao estiver compilado, nao validamos o documento, assim como era antes
If lDSitDoc
	
	If ValType(aCancel) == "A" .AND. Len(aCancel) > 5 .AND. !Empty(aCancel[6])
		//Se entrar no IF, significa que eh uma venda nao fiscal vale credito ou vale presente
		lDocNf := .T.
	EndIf

	//retorna os campos L1_SITUA e L1_STORC
	aSitua := STDSitDoc(cSerie, cDoc, cPDV, lDocNf)

	If aSitua[1] == "404"
		lRet := .F.
		STFMessage("STCancelSale", "STOP", STR0023) //"Documento fiscal não encontrado"
		STFShowMessage("STCancelSale")
	
	//A - caso de nota cancelada automaticamente | C - cancelamento manual
	ElseIf aSitua[2] $ "A|C"
		lRet := .F.
		If !lDocNf
			STFMessage("STCancelSale", "STOP", STR0024)	//"Documento fiscal já enviado para cancelamento"
		Else
			STFMessage("STCancelSale", "STOP", STR0033)	//"Documento não fiscal já enviado para cancelamento"
		EndIf
		STFShowMessage("STCancelSale")
	ElseIf !lDocNf .AND. !STBCancTime(nNfceExc, cDoc, cSerie) //verifica o prazo do documento antes de prosseguir com a exclusao
	   lRet := .F.
	   STFMessage("STCancelSale", "STOP", STR0029 + " " + AllTrim(STR(nNfceExc)) + STR0030) //"Prazo para o cancelamento de venda é de"#"horas. Verifique o parâmetro MV_NFCEEXC"
	   STFShowMessage("STCancelSale")
	ElseIf aSitua[1] $ "00|TX"
		If !lDocNf
			STFMessage("STCancelSale", "YESNO", STR0025 + cDoc + "/" + cSerie + " ?" )	//Deseja cancelar o documento fiscal: "
		Else
			STFMessage("STCancelSale", "YESNO", STR0032 + cDoc +  "/" + cSerie + " ?" )	//"Deseja cancelar o documento não fiscal: "
		EndIf
		lRet := STFShowMessage("STCancelSale")
	
	Else
		STFMessage( "STCancelSale", "STOP", STR0026 )	//"Venda não finalizada/cancelada. Por favor, verifique a venda."
		STFShowMessage("STCancelSale")
	EndIf
	
EndIf

Return lRet


/*/{Protheus.doc} STBChkInut
Verifica se todos os requisitos foram atendidos
@type		function
@author  	Varejo
@version 	P12
@since   	14/10/2016
@return  	logico, se todos os requisitos foram atendidos
@obs     	Melhoria: Pode ser usada como funcao generica, recebendo o array
/*/
Function STBChkInut()

Local cAliasName 	:= ""
Local nI			:= 0
Local nPos			:= 0
Local lRet			:= .T.
Local aAux			:= {}
Local aArea			:= GetArea()

//Campos e funcoes necessarias para a Inutilizacao
Aadd( aAux, {"FIELD", "LX_MODDOC"	, .F.} )
Aadd( aAux, {"FUNC"	, "STWDELPAY"	, .F.} )		//STWCANCELSALE.PRW
Aadd( aAux, {"FUNC"	, "STDDELPAY"	, .F.} )		//STDCANCELSALE.PRW

For nI := 1 to Len(aAux)
	
	If aAux[nI][1] == "FIELD"
		
		nPos := At( "_", aAux[nI][2] )
			
		//ZZ_FieldName
		If nPos == 3
			cAliasName := 'S' + SubStr(aAux[nI][2], 1, 2)  		
		//ZZZ_FieldName
		Else
			cAliasName := SubStr(aAux[nI][2], 1, 3)
		EndIf	
		
		DbSelectArea( cAliasName )
		If &(cAliasName)->( ColumnPos(aAux[nI][2]) ) > 0
			aAux[nI][3] := .T.
		Else
			LJGrvLog(Nil, "CAMPO não encontrada no dicionario de dados", aAux[nI][2])
		EndIf

	ElseIf aAux[nI][1] == "FUNC"

		If ExistFunc(aAux[nI][2])
			aAux[nI][3] := .T.
		Else
			LJGrvLog(Nil, "FUNCAO não encontrada no repositorio", aAux[nI][2])
		EndIf

	EndIf

Next

RestArea(aArea)

nPos := aScan( aAux, {|x| !x[3]} )
If nPos > 0
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCancTime
Verifica se eh venda NFCe transmitida, pois neste caso deve respeitar o
parametro MV_SPEDEXC que indica o numero de horas que pode ser excluida

@type       function
@author     Varejo
@version    P12
@since      22/02/2017
@return     logico, se venda esta no prazo de cancelamento
/*/
//-------------------------------------------------------------------
Static Function STBCancTime(nNfceExc, cDoc, cSerie)
Local aArea     := GetArea()
Local aAreaSL1  := SL1->(GetArea())
Local lRet      := .T.
Local dDtDigit  := dDataBase
Local nHoras    := 0
Local cEstacao  := Padr(STFGetStation("PDV"), TamSx3("L1_PDV")[1])
Local lEndFis   := SuperGetMv("MV_SPEDEND",, .F.)						// Se estiver como F refere-se ao endereço de Cobrança se estiver T ao endereço de Entrega.
Local cEstSM0	:= IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)
Local cHoraUF 	:= FwTimeUF(cEstSM0)[2]

DEFAULT cSerie	:= Padr(STFGetStation("SERIE"), TamSx3("L1_SERIE")[1])

If Empty(cHoraUF)
	cHoraUF := Time()
EndIf

cDoc := Padr(cDoc, TamSx3("L1_DOC")[1])

SL1->(dbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

If SL1->(dbSeek(xFilial("SL1") + cSerie + cDoc + cEstacao)) .And. ExistFunc("LjSubtHora")
    //Verifica se a NFCe foi transmitida pela chave            
    If !Empty(SL1->L1_KEYNFCE)
        dDtDigit := SL1->L1_EMISNF
        nHoras   := LjSubtHora(dDtdigit, SL1->L1_HORA, dDataBase, SubStr(cHoraUF, 1, 2) + ":" + SubStr(cHoraUF, 4, 2))                 
        
        If nHoras > nNfceExc        
            lRet := .F.             
        EndIf
    EndIf
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} STFimVnDro
	Execução do PE Template e Cancelamento de Log da Anvisa (LK9)
	@type  Function
	@author Julio.Nery
	@since 10/03/2021
	@version 12
	@param param, param_type, param_descr
	@return NIL
/*/
Function STCSCanDro(cDoc,cSerie)
Local aSTBDroVar := {}

Default cDoc   := ""
Default cSerie := ""

If ExistFunc("LjIsDro") .And. LjIsDro()
	If ExistFunc("STBDroVars") .And. ExistTemplate("FRTCancela")
		aSTBDroVar := STBDroVars(.T.)
		aSTBDroVar[1] := ExecTemplate("FRTCancela",.F.,.F.,{2,STFProfile(42)[2],,aSTBDroVar[1]})
		STBDroVars(.F.,.T.,aSTBDroVar[1],NIL)
	EndIf
	
	//Cancela, se houver, algum registro de log da ANVISA (tabela LK9)
	T_DROCancANVISA(cDoc,cSerie)
EndIf

Return NIL