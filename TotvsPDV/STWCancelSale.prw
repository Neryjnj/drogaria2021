#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWCANCELSALE.CH"

Static lRms := SuperGetMv("MV_LJRMS",,.F.) //Integração com a RMS

/* 

Static lLjcFid	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() // TO DO: Avaliar se sera implementado o CRDxINT
//Indica se a recarga de cartao fidelidade esta ativa
 
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} STWCancelSale
Cancelar Venda

@param lForceCancel				Define se força o cancelamento da venda, via erro por exemploVenda em andamento?
@param lIsProgressSale			Venda em andamento?
@param cSuperior					Superior que autorizou cancelamento
@param cDoc							Numero Doc a Cancelar (L1_DOC)
@param cNumSale						Numeração venda a cancelar (L1_NUM)
@param lCancVenc						Cancela no server a venda vencida
@param cNumForce					Forca numeracao da venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se efetuou cancelamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCancelSale( 	lForceCancel 	, lIsProgressSale , cSuperior 	, cDoc			, ;
							cNumSale 		, lCancVenc		, cNFisCanc  	, cNumForce     , ;
							cSerie )

Local lRet		:= .F.					// Retorno funcao
Local aParam	:= {}					// Parametros passados para a retaguarda
Local cNome		:= ""
Local cCGCCli	:= ""
Local cL1NumOri	:= STDGPBasket("SL1" , "L1_NUMORIG")
Local cL1Num	:= STDGPBasket("SL1" , "L1_NUM")
Local cL1PDV	:= STDGPBasket("SL1" , "L1_PDV")
Local lUseSAT	:= LjUseSat() 							// Sinaliza se utiliza SAT

Default lForceCancel  		:= .F.
Default lIsProgressSale 	:= .F.
Default cSuperior  			:= ""
Default cDoc   				:= ""
Default cNumSale   			:= ""
Default lCancVenc   		:= .F.
Default cNFisCanc			:= ""
Default cNumForce			:= ""
Default cSerie				:= STFGetStation("SERIE")

LjGrvLog( "NumOrc: "+cNumSale+"/DOC: "+cDoc + "-" + cSerie, "Cancela venda" )  //Gera LOG

Do Case

	Case lForceCancel

		LjGrvLog( "Cancela venda","NumOrc: "+cNumSale+"/DOC: "+cDoc+" - lForceCancel = .T.") 
		lRet := STWCSForceCancel( lCancVenc, @cNome, @cCGCCli , cNumForce )

	Case lIsProgressSale  		// Venda em Andamento

		LjGrvLog( "Cancela venda","NumOrc: "+cNumSale+"/DOC: "+cDoc+" - Venda em Andamento(lForceCancel = .T.)")
		lRet := STWCSProgressSale( cSuperior , cDoc, @cNome, @cCGCCli, cSerie )

	Case !lIsProgressSale		// Venda Finalizada

		LjGrvLog( "Cancela venda","NumOrc: "+cNumSale+"/DOC: "+cDoc+"-"+cSerie+" - Venda Finalizada(lForceCancel = .F.)")	
		lRet := STWCSFinalized( cSuperior , cDoc , cNumSale, @cNome, @cCGCCli, cNFisCanc, "StiPosMain", , cSerie )
		If AllTrim(cNumSale) <> AllTrim(cL1Num)
			cL1Num := cNumSale
		EndIf

EndCase

/*/
	Verifica se já houve importação de orçamento. Caso positivo deleta arquivo de controle
/*/
If lRet
	//Quando a venda já foi finalizada e vai cancelar o ultimo cupom, a cesta de vendas esta vazia mas 
	//o ponteiro esta posicionada na venda a ser cancelada, neste caso busco o L1_NUMORIG da linha posicionada na L1.
	If Empty(cL1NumOri) .AND. AllTrim(cNumSale) == AllTrim(SL1->L1_NUM)
		cL1NumOri := SL1->L1_NUMORIG
	EndIf

	If !(Empty(cL1NumOri))
		//Exclui arquivo .TXT
		aParam := {{ cL1NumOri, cL1PDV},Nil,.T.}
		STBRemoteExecute( "FR271HArq", aParam,,.T. ) 
		
		//Exclui arquivo .RET
		aParam := {{ cL1NumOri, cL1PDV},Nil,.T.,, .T.}
		STBRemoteExecute( "FR271HArq", aParam,,.T. ) 		
	Else
		STFFireEvent(ProcName(0), "STGrvMdz",	{"R4",,cL1Num, cNome, cCGCCli}) //"CANCELAMENTO" 
	EndIf
	
	//Apaga o arquivo de cancelamento SAT
	If lUseSAT
		LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo sinal de recuperação de cancelamento
	EndIf
EndIf

STFShowMessage("STCancelSale")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCSProgressSale
Cancela Venda em Andamento

@param cSupervisor			ID do Usuário Supervisor
@param cDoc					Numero do documento
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se Cancelou a venda
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCSProgressSale( cSupervisor , cDoc, cNome, cCGCCli, cSerie )
Local lRet			:= .T.									// Retorna se Cancelou a venda
Local lAllNotfiscal	:= .F.									// Todos os Itens são não fiscais?
Local lDelChange	:= SuperGetMV("MV_LJTRLOC",,.F.)	// Define se Usa troco localizado
Local oTEF20		:= Nil									// Objeto TEF
Local oCliModel		:= NIL
Local aSL1			:= {} 									//Grava status da L1_SITUA 
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local lNFCETSS		:= STFGetCfg("lNFCETSS", .T.) 		//Enviar NFC-e pelo TSS

Default cSupervisor	:= ""
Default cDoc		:= ""
Default cNome		:= "" 
Default cCGCCli		:= ""
Default cSerie		:= ""

LjGrvLog( "DOC: "+cDoc+"/"+cSerie, "Cancela Venda em Andamento" )  //Gera LOG

If Valtype(lNFCETSS) == "U" //Default é enviar NFCe pelo TSS
	lNFCETSS := .T.
EndIf

lRet := STBCSChkStatusPrint()

If lRet

	/*/
		Todos os Itens possuem reserva?
	/*/
	If STBExistItemFiscal()
		lAllNotfiscal := .F.
	Else
		lAllNotfiscal	:= .T.
	EndIf

	If !lAllNotfiscal .AND. !lSaveOrc  
		/*/
			Cancelamento na impressora fiscal
		/*/
		
		lRet := STBCSCancCupPrint( cSupervisor , cDoc, /*cNumSale*/, lNFCETSS, /*lForceCancel*/, /*cTipoCanc*/, .T.)
		If lRet
			/*/
				Desfazimento Transação TEF
			/*/
			oTEF20 := STBGetTef()
			If ValType(oTEF20) == 'O'
				oTEF20:Desfazer()   
				LjGrvLog( "DOC: "+cDoc, "Desfazimento Transação TEF" )  //Gera LOG   
				If SuperGetMV("MV_LJHMTEF", ,.F.)
					STFMessage("TEF", "POPUP", STR0006 )//"Transação não foi efetuada. Favor reter o cupom."
		   			STFShowMessage( "TEF")
		   		EndIf
			EndIf

		EndIf

	EndIf

	If lRet
		cCGCCli	:= SL1->L1_CGCCLI      
		oCliModel:= STWCustomerSelection(SL1->(L1_CLIENTE+L1_LOJA))
		cNome 	:= oCliModel:GetValue("SA1MASTER","A1_NOME") 

		//Verifica se grava  flag nfce por TSS 
		If SL1->(ColumnPos("L1_TPTNFCE")) > 0
			STDSPBasket( "SL1", "L1_TPTNFCE"   , IIF(!lNFCETSS, "0", "1") )
		EndIf
		
		If !lRms
			LjGrvLog( "L1_NUM: "+SL1->L1_NUM, "Deleta SL1, SL2 e SL4" )  //Gera LOG
			STDCSDeleteSale( SL1->L1_NUM , lDelChange ) // Deleta SL1, SL2 e SL4 e SE5(troco localizado)											
		EndIf
			
		//Se a integracao da RMS esta habilitado, grava SLX e L1_SITUA = 00 (Quando for cancelamento)
		aSL1 := {{"L1_SITUA",	"00"}}
		STFSaveTab( "SL1" , aSL1 )
		
		If !STbIsPaf() // o PAF grava a SLX no comando do cancelamento do ECF
			STDLogCanc(,,cSupervisor)
		EndIf
		
		If lAllNotfiscal
			STFMessage("STCancelSale","STOP", STR0001 ) //Cupom Não Fiscal Cancelado
			LjGrvLog( "L1_NUM: "+SL1->L1_NUM, "Cupom Não Fiscal Cancelado" )  //Gera LOG
		Else
			STFMessage("STCancelSale","STOP", STR0002 ) //Cupom Fiscal Cancelado
			LjGrvLog( "L1_NUM: "+SL1->L1_NUM, "Cupom Fiscal Cancelado" )  //Gera LOG
		EndIf

	EndIf
	
	LjGrvLog( "L1_NUM: "+SL1->L1_NUM, "Reinicia variáveis para iniciar próxima venda" )  //Gera LOG
	STFRestart()

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCSFinalized
Cancelar Vendas Finalizadas

@param cSupervisor			ID do Usuário Supervisor
@param cDoc					Numero do Documento
@param cNumSale				Numero da venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se Cancelou a venda
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCSFinalized( cSupervisor , cDoc , cNumSale, cNome,;
 						cCGCCli, cNFisCanc, cFlowAction, lCancNf, cSerie )
Local lRet			:= .T.									// Retorna se Efetuou Cancelamento
Local oTEF20		:= Nil									// Objeto TEF
Local oCliModel		:= NIL									// Model do cliente
Local aEstornoNCC	:= {}									// Array de parametros para realizar estorno de NCC
Local lFuncExVP		:= ExistFunc("STDExecEstorVP	") /// estorno de VP
Local lNFCETSS		:= STFGetCfg("lNFCETSS", .T.) 		// Enviar NFC-e pelo TSS
Local aVendaTEF		:= {}									// Acumula a quantidade transacoes TEF
Local nX			:= 1									// Variavel de controle do For
Local cTipoCanc		:= ""									// tipo de cancelamento off-line
Local lUseSAT		:= LjUseSat() 							// Sinaliza se utiliza SAT
Local cStation 		:= STFGetStation("CODIGO")				// Estacao atual, utilizado na gravacao da SLI de controle de comandos do ECF
Local aParamFlow	:= {}
Local lExecCanCup	:= .T.									//Sinaliza se deve realizar o comando de cancelamento de cupom
Local lSTBAddFlow	:= ExistFunc("STBAddFlow")
Local lSTDSatRecovery:= IsInCallStack("STDSatRecovery")
Local cMvLjPref		:= SuperGetMV("MV_LJPREF")				//Regra para gravacao do SF2->F2_PREFIXO
Local cPrefE1		:= ""
Local nMvLjTpCan	:= SuperGetMV("MV_LJTPCAN",,1)  		//Parametro que indica se utiliza o novo processo de cancelamento
Local oCancNfce		:= Nil									//Armazena o objeto CancNfce
Local lEmitNFCe		:= STBGetNFCE()							//Indica se NFC-e
Local nPosSL4 		:= 0
Local lCmpsIdTRN	:= SL4->(ColumnPos("L4_TRNID")) > 0 .And. SL4->(ColumnPos("L4_TRNPCID")) > 0 .And. SL4->(ColumnPos("L4_TRNEXID")) > 0 //Verifica se existem os campos que guardam os IDs das transações TEF

Default cSupervisor := ""
Default cDoc   		:= ""	
Default cNumSale  	:= ""
Default cNFisCanc  	:= ""
Default cFlowAction := ""	//Recebe conteudo quando reprocessando. Exemplo: STBCSCancCupPrint|1 , sendo o ultimo parametro a qtde de vezes que ja tentou reprocessar para evitar looping infinito.
Default lCancNf		:= .F. 	//Sinaliza que eh uma venda nao fiscal venda de vale presente ou vale credito
Default cSerie		:= STFGetStation("SERIE")

If Valtype(lNFCETSS) == "U" //Default é enviar NFCe pelo TSS
	lNFCETSS := .T.
EndIf		

//Guarda parametros da rotina para controle de fluxo de execucao
Aadd(aParamFlow,cSupervisor)
Aadd(aParamFlow,cDoc)
Aadd(aParamFlow,cNumSale)
Aadd(aParamFlow,cNome)
Aadd(aParamFlow,cCGCCli)
Aadd(aParamFlow,cNFisCanc)
Aadd(aParamFlow,cFlowAction)
Aadd(aParamFlow,.F.)	//-- Evitar erro ao iniciar o recuperar venda pq senao cSerie entra no lugar
Aadd(aParamFlow,cSerie)

DbSelectArea("SL1")
DbSetOrder(1)//L1_FILIAL+L1_NUM
lRet := SL1->(DbSeek( xFilial("SL1") + cNumSale))

If !lCancNf
	LjGrvLog( "NumOrc: "+cNumSale+"/DOC: "+cDoc+"/"+cSerie, "Cancelar Venda Finalizada" )  //Gera LOG
Else
	LjGrvLog( "NumOrc: "+cNumSale+"/DOC NF: "+cNFisCanc, "Cancelar Venda Finalizada" )  //Gera LOG
EndIf
STFMessage("STWCSFinalized","ALERT", STR0007 )//"CANCELANDO A VENDA, AGUARDE..."
STFShowMessage("STWCSFinalized")

If Empty(cDoc) .AND. !lCancNf 
	LjGrvLog( "Cancelamento da Venda", "Cancelamento nao processado. Motivo: Nao recebeu parametro com o DOC para cancelamento" ) 
	lRet := .F.
EndIf

If lRet
	If STDCSChkRes(cNumSale) // Checa se TODOS os Itens são com Reserva
		lRet := .F.
		MsgAlert(STR0003)		
		STFMessage("STCancelSale","STOP", STR0003) //Não será possível cancelar o pedido pois ja foi finalizado
		LjGrvLog(cNumSale,STR0003)
	EndIf
EndIf

//FlowControl: Cancela cupom no ECF -> "STBCSCancCupPrint"
If lRet
	LjGrvLog( "NumOrc: "+cNumSale+"/DOC: "+cDoc+"/"+cSerie, "Cancelar Venda Finalizada" )  //Gera LOG

	If "STBCSCancCupPrint" $ cFlowAction
		LjGrvLog( "DOC: "+cDoc+"/"+cSerie, "Reprocessando cancelamento" )  
		IIF(lSTBAddFlow,STBAddFlow(cFlowAction,aParamFlow),Nil)  //Controle de fluxo, sinaliza que ira executar a rotina STBCSCancCupPrint

		If STWFlwCheck("STBCSCancCupPrint",aParamFlow) //verifica se houve ou nao o cancelamento no ECF
			lExecCanCup		:= .F.	//Sinaliza que nao deve mais executar o comando de cancelamento no ECF
			cFlowAction 	:= ""
			lRet 			:= .T. 
		EndIf
	EndIf

	If lExecCanCup 	
		IIF(lSTBAddFlow,STBAddFlow("STBCSCancCupPrint",aParamFlow),Nil)  //Controle de fluxo, sinaliza que ira executar a rotina STBCSCancCupPrint
		lRet := STBCSCancCupPrint( cSupervisor , cDoc, , lNFCETSS,,@cTipoCanc, ,cSerie )
	EndIf			
EndIf

//FlowControl: Se possuir TEF, cancela a transacao(Desfazimento Transação TEF) -> "TEFDesfazer" 
If lRet		
	IIF(lSTBAddFlow,STBAddFlow("TEFDesfazer",aParamFlow),Nil)
	DbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	If SL4->(DbSeek(xFilial("SL4") + cNumSale))			
		While !SL4->(Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cNumSale
			If (Alltrim(SL4->L4_FORMA) == "CC" .OR. Alltrim(SL4->L4_FORMA) == "CD") .And. !Empty(SL4->L4_DOCTEF)
				nPosSL4 := aScan(aVendaTEF,{|x| AllTrim(x[1]) == Alltrim(SL4->L4_DOCTEF) })
				If nPosSL4 == 0
					Aadd(aVendaTEF, {} )
					nPosSL4 := Len(aVendaTEF)
					Aadd(aVendaTEF[nPosSL4], Alltrim(SL4->L4_DOCTEF) )
					Aadd(aVendaTEF[nPosSL4], SL4->L4_VALOR )
					If lCmpsIdTRN
						Aadd(aVendaTEF[nPosSL4], Alltrim(SL4->L4_TRNID) )
						Aadd(aVendaTEF[nPosSL4], Alltrim(SL4->L4_TRNPCID) )
						Aadd(aVendaTEF[nPosSL4], Alltrim(SL4->L4_TRNEXID) )
					Else
						Aadd(aVendaTEF[nPosSL4], "" )
						Aadd(aVendaTEF[nPosSL4], "" )
						Aadd(aVendaTEF[nPosSL4], "" )
					EndIf
					Aadd(aVendaTEF[nPosSL4], SL4->L4_DATATEF )
				Else
					aVendaTEF[nPosSL4][2] += SL4->L4_VALOR
				Endif
			Endif				
			SL4->(DbSkip())
		Enddo
	
		// Faz a chamada da tela para cancelamento dos cartoes
		For nX := 1 to Len(aVendaTEF)			
			STBFunAdm(,lSTDSatRecovery,aVendaTEF[nX])
		Next nX
	Endif
			
	If Len(aVendaTEF) > 0
		oTEF20 := STBGetTef()
		If ValType(oTEF20) == 'O'		
			oTEF20:Desfazer()    
			If SuperGetMV("MV_LJHMTEF", ,.F.)
				STFMessage("TEF", "POPUP", STR0006 )//"Transação não foi efetuada. Favor reter o cupom."
	   			STFShowMessage( "TEF")
	   		EndIf
		EndIf
	EndIf
EndIf
 
If lRet .AND. lEmitNFCe .AND. !lCancNf .AND. !lUseSAT .AND. (nMvLjTpCan == 2 .OR. nMvLjTpCan == 3)
	
	oCancNfce := LOJCNFCE():New()
	
	//Tenta realizar o cancelamento Online
	oCancNfce:LjCancOnline(SL1->(L1_SERIE+L1_DOC))

	If oCancNfce:aResultCancelamento[1]
		//Grava log informando que a venda foi cancelada online
		LjGrvLog( "NumOrc: "+cNumSale, "NFC-e cancelada ONLINE, Id: " +  SL1->(L1_SERIE+L1_DOC) ) 
		STFMessage("CancNFCE", "ALERT", STR0009)//"Cancelamento realizado com sucesso."
		STFShowMessage( "CancNFCE")
	ElseIf oCancNfce:aResultMetodo[1] .AND. oCancNfce:aResultTSS[1] //Nota transmitida porem com rejeição (Online ou Offline Barra cancelamento)
		lRet := .F. //Avisa que a nota foi rejeitada e printa na tela o motivo da rejeição.
		LjGrvLog( "NumOrc: "+cNumSale,  "Não foi possivel realizar o cancelamento. Motivo: " + oCancNfce:aResultCancelamento[3]) 
		STFMessage("CancNFCE", "POPUP", STR0010 + oCancNfce:aResultCancelamento[3])//"Não foi possivel realizar o cancelamento. Motivo:
		STFShowMessage( "CancNFCE")
	Else
		If nMvLjTpCan == 3 .And. !oCancNfce:aResultTSS[1]
			LjGrvLog( "NumOrc: "+cNumSale,  "Não foi possivel realizar o cancelamento. Motivo: Sem comunicação com TSS / Sefaz.")
			LjGrvLog( "NumOrc: "+cNumSale,  "Retorno do TSS: " + oCancNfce:aResultTSS[3])
			STFMessage("CancNFCE", "POPUP", STR0011)//"Não foi possivel realizar o cancelamento. Motivo: Sem comunicação com TSS / Sefaz."
			STFShowMessage( "CancNFCE")
			lRet := .F.
		ElseIf (nMvLjTpCan == 3 .AND. !oCancNfce:aResultMetodo[1] .AND. oCancNfce:aResultTSS[1]) .OR. nMvLjTpCan == 2
			If oCancNfce:LjCancOffLine(SL1->L1_SERIE,SL1->L1_DOC, Substr(SL1->L1_KEYNFCE,21,2) )
				LjGrvLog( "NumOrc: "+cNumSale,  "Envio de cancelamento para o TSS realizado com sucesso!")
				lRet := .T.
			Else
				LjGrvLog( "NumOrc: "+cNumSale,  "Não foi possivel realizar o envio do cancelamento para o TSS, o cancelamento devera ser realizado pelo job LJCANCNFCE")
				lRet := .T. 
			EndIf 
		EndIf
	EndIf
EndIf

If lRet

	// Solicita cancelamento no Back Office	
	If lNFCETSS .OR. Empty(cTipoCanc)
		LjGrvLog( "NumOrc: "+cNumSale, "Solicita cancelamento no Back Office" )  //Gera LOG
		IIF(lSTBAddFlow,STBAddFlow("STDCSRequestCancel",aParamFlow),Nil)  
		STDCSRequestCancel( cNumSale,,cNFisCanc,cTipoCanc)	
	EndIf

	/* TO DO: Avaliar se a variavel lLjcFid sera usada
	If lLjcFid oTEF20
		STDCSShopCard( cNumSale )
	EndIf
	*/

	If lRet

		IIF(lSTBAddFlow,STBAddFlow("STBCSCancGP",aParamFlow),Nil) 		 

		cCGCCli	:= STDGPBasket("SL1","L1_CGCCLI")      
		oCliModel := STWCustomerSelection(STDGPBasket("SL1","L1_CLIENTE")+STDGPBasket("SL1","L1_LOJA"))
		cNome 	:= oCliModel:GetValue("SA1MASTER","A1_NOME") 
		
		If lRMS
			//Grava SLX
			STFSLICreate( cStation, "TRN", "STWCSFinalized|Sistema|STDLogCanc|"+cDoc, "SOBREPOE" )		//Controle de ECF: Comando de cancelamento realizado no ECF, processando gravacao 						
		EndIf
		
		//Permito Gravar o Log somente quando não usar PAF-ECF, pois dentro da função 
		//de cancelamento do ECF tem o comando para gerar o log
		If lEmitNFCe .Or. !STBIsPaf()
			STDLogCanc(,,cSupervisor,,lCancNf)
		EndIf
	EndIf
	
	If lFuncExVP
		IIF(lSTBAddFlow,STBAddFlow("STDExecEstorVP",aParamFlow),Nil)
		STDExecEstorVP(cNumSale) //Estorno Vale Presente 
	EndIf
	//
	//	Realiza estorno das NCCs utilizadas na venda
	//		
	If SL1->L1_CREDITO > 0 
		//////////////////////////////////////////////////////////////////////////////////
		//Tratamento para retornar o prefixo correto de acordo com o parâmetro MV_LJPREF//
		//////////////////////////////////////////////////////////////////////////////////
		If AllTrim(Upper(cMvLjPref)) <> "SF2->F2_SERIE"
			cPrefE1 := PadR(&(cMvLjPref),TamSX3("F2_SERIE")[01]) //como o conteudo do parametro nao e padrao, ele e macro executado.
		Else
			cPrefE1 := IIf( !Empty( SL1->L1_SERIE ) 	, SL1->L1_SERIE  	, SL1->L1_SERPED	)			
		EndIf

		aEstornoNCC := { 	SL1->L1_FILIAL				,;
							IIf( !Empty( SL1->L1_DOC   ) 	, SL1->L1_DOC 	, SL1->L1_DOCPED	)			,;
							cPrefE1						,;
							SL1->L1_CLIENTE				,;
							SL1->L1_LOJA				}
		
		//Executa o estorno da NCC no server
		IIF(lSTBAddFlow,STBAddFlow("FRTNCCEXC",aParamFlow),Nil)
		STBRemoteExecute( "FRTNCCEXC", aEstornoNCC , , .T. )						
	EndIf
	
	If ExistBlock("STRelCanVc") .AND. lCancNf
		LjGrvLog( NIL , "Antes da execução do P.E. STRelCanVc",{SL1->L1_FILIAL, SL1->L1_NUM})
		ExecBlock("STRelCanVc", .F., .F., {SL1->L1_FILIAL, SL1->L1_NUM})
		LjGrvLog( NIL , "Retorno da execução do P.E. STRelCanVc")
	ElseIf lEmitNFCe .And. !lCancNf .AND. !lUseSAT 
		//Imprime comprovante Nao-Fiscal referente a Solicitacao de Cancelamento de NFC-e
		LjNFCePrtC(SL1->L1_PDV, SL1->L1_DOC, SL1->L1_SERIE, dDatabase, Time())
	EndIf	

	If STFUseFiscalPrinter()
		STFMessage("STCancelSale","STOP", STR0002) //Cupom Fiscal Cancelado
		LjGrvLog( "NumOrc: "+cNumSale, "Cupom Fiscal Cancelado" )  //Gera LOG
	Else
		STFMessage("STCancelSale","STOP", STR0004) //Venda Cancelada
		LjGrvLog( "NumOrc: "+cNumSale, "Venda Cancelada" )  //Gera LOG
	EndIf
	
	IIF(lSTBAddFlow,STBAddFlow(""),Nil) // finaliza controle de fluxo da rotina 
	
	If !lSTDSatRecovery
		LjGrvLog( "NumOrc: "+cNumSale, "Reinicia variáveis para iniciar próxima venda" )  //Gera LOG
		STFRestart()
	EndIf
Else
	IIF(lSTBAddFlow,STBAddFlow(""),Nil) // finaliza controle de fluxo da rotina
EndIf

//Ponto de Entrada apos concluir o cancelamento
If lRet .AND. ExistBlock("STCANSALE")
	LjGrvLog( NIL , "Antes da execução do P.E. STCANSALE")
	ExecBlock( "STCANSALE",.F.,.F.)
	LjGrvLog( NIL , "Retorno da execução do P.E. STCANSALE")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCSForceCancel
Força Cancelamento

@param lCancVenc Cancela vendas vencidas
@param cNumSale Numero da venda a ser cancelada  
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se efetuou cancelamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCSForceCancel(lCancVenc, cNome, cCGCCli , cNumSale )
Local lRet				:= .T.						// Retorna se efetuou cancelamento
Local lIsOpenReceipt	:= .F.						// Define se o cupom está aberto
Local aRetPrinter		:= {}						// Armazena retorno impressora
Local aProfile 			:= STFPROFILE(8)
Local cSuperior	   		:= ""						// ID do Usuário Superior
Local aIsOpenReceipt   	:= { "5" , "" }	   		// Armazena retorno se o cupom está aberto
Local lFiscalPrinter	:= STFUseFiscalPrinter()// Indica se utiliza impressora fiscal
Local oCliModel			:= NIL
Local lNFCETSS			:= STFGetCfg("lNFCETSS", .T.) 		//Enviar NFC-e pelo TSS
Local lProgrs 			:= STBCSIsProgressSale()
Local lInutiliza		:= .F. //Inutiliza a venda
Local lEmitNFCe         := STBGetNFCE()         //valida se é NFC-e ou não

Default lCancVenc   	:= .F.
Default cNome			:= ""
Default cCGCCli			:= ""
Default cNumSale		:= ""

If Valtype(lNFCETSS) == "U" //Default é enviar NFCe pelo TSS
	lNFCETSS := .T.
EndIf

LjGrvLog( "L1_NUM: "+STDGPBasket("SL1","L1_NUM"), "Força Cancelamento da venda" )

//se a venda está em progresso, verifica o TEF para desfazer a transação
If lProgrs
	STBSetRetTef( STIGetCard() )
EndIf

//validação para ver se o usuário tem permissão para cancelar venda
If Len(aProfile) > 0 .And. aProfile[1] 
	/*/
		Verifica cupom aberto
	/*/
	aRetPrinter := STFFireEvent(ProcName(0)			, ; // Nome do processo
								"STPrinterStatus"	, ; // Nome do evento
						   	   	aIsOpenReceipt	  	)

	If Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N"
		If aRetPrinter[1] == 7
  			lIsOpenReceipt := .T.	// Aberto
  		Else
   			lIsOpenReceipt := .F.	// Fechado
		EndIf
	EndIf

	If lIsOpenReceipt .OR. !lFiscalPrinter
	
		/*/
			Verifica Status da impressora
		/*/
		lRet := STBCSChkStatusPrint()
		If !lRet
			STFMessage("STCancelSale","STOP", STR0005) //Erro com a Impressora Fiscal. Operação não efetuada. É necessário efetuar Nota de Devolução;
			LjGrvLog( "L1_DOC: "+STDGPBasket("SL1","L1_DOC"), "Erro com a Impressora Fiscal. Operação não efetuada. É necessário efetuar Nota de Devolução" )  //Gera LOG
		EndIf
	
		If lRet
	
			//Se nao recebeu numero da venda pega do model
			If Empty(cNumSale)
				cNumSale  := STDGPBasket("SL1","L1_NUM")
			EndIf

			oCliModel  := STWCustomerSelection(STDGPBasket("SL1","L1_CLIENTE")+STDGPBasket("SL1","L1_LOJA"))
			cNome 		:= oCliModel:GetValue("SA1MASTER","A1_NOME") 
			cSuperior	:= aProfile[2]
			lInutiliza :=  STDGPBasket("SL1","L1_SITUA") == "65"		
	
			If lNFCETSS .OR. !Empty(cNumSale)
				cNumDoc 	:= STDGPBasket("SL1","L1_DOC")
	
				cCGCCli	:= STDGPBasket("SL1","L1_CGCCLI")      
				If !lNFCETSS 
					LjGrvLog( "L1_NUM: "+cNumSale, "Força Cancelamento da venda", lProgrs )  //Gera LOG
					If lProgrs
						lRet := STBCSCancCupPrint( cSuperior , cNumDoc,cNumSale,lNFCETSS, , , @lInutiliza)
					EndIf // OBS: O Front Nem valida o retorno da impressora
				Else
					 STBCSCancCupPrint( cSuperior , cNumDoc,@cNumSale,lNFCETSS ) // OBS: O Front Nem valida o retorno da impressora
				EndIf
			ElseIf !lNFCETSS
				//Se não for TSS (mobile), posiciona e cancela a ultima venda
				cNumDoc := STDCSLastSale("L1_DOC")
				cNumSale := STDCSLastSale("L1_NUM")
				cCGCCli	:= STDCSLastSale("L1_CGCCLI")      
				lInutiliza :=  STDGPBasket("SL1","L1_SITUA") == "65"
			
				//TSS valida o retorno para excluir a venda
				If !lProgrs
					cSuperior	:= aProfile[2]
					lRet := STBCSCancCupPrint( cSuperior , @cNumDoc,@cNumSale,lNFCETSS, , , @lInutiliza ) // OBS: O Front Nem valida o retorno da impressora
				Endif
			EndIf

			If lRet
				If lNFCETSS .and. Empty(cNumSale)
					cNumSale := STDCSLastSale()
				EndIf
	
				If !Empty(cNumSale)
					If lNFCETSS .OR. (!lNFCETSS .and. lProgrs)
						STDCSDeleteSale( cNumSale)					
					EndIf
				Endif		

				If lCancVenc				
					// Solicita cancelamento no Back Office
					STDCSRequestCancel( cNumSale , lCancVenc )
				EndIf
	
				If lFiscalPrinter
					STFMessage("STCancelSale","STOP", STR0002) //Cupom Fiscal Cancelado
					LjGrvLog( "NumOrc: "+cNumSale, "Cupom Fiscal Cancelado" )  //Gera LOG
				Else
					STFMessage("STCancelSale","STOP", STR0004) //Venda Cancelada
					LjGrvLog( "NumOrc: "+cNumSale, "Venda Cancelada" )  //Gera LOG
				EndIf
	
				If lEmitNFCe .Or. !STBIsRecovered()
					STDAjstSLX(SL1->L1_DOC)  // Deleta na SLX o registro referente a NFCe
					STFRestart() // Zera variáveis de venda
				EndIf
			EndIf
		EndIf
	EndIf
Else
	STFMessage("STCancelSale","STOP", "Sem permissão para cancelar a venda!") //Venda Cancelada
	LjGrvLog( "NumOrc: "+cNumSale, "Sem permissão para cancelar a venda!" )  //Gera LOG			
EndIf	

Return lRet


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} STWInuNFCE
Cria o registro na SLX para que a NFC-e seja inutilizada
@type		function
@param		cDoc, caracter, numero da Doc Fiscal
@param		[cSerie], caracter, serie do Doc Fiscal
@param		[cPDV], caracter, codigo do PDV em uso
@param		[cOperador], caracter, codigo do Operador
@param		[cStation], caracter, codigo da Estacao
@author  	Varejo
@version 	P12
@since   	14/10/2016
@return  	logico, se gerou SLX e a cesta foi renovada
/*/
//---------------------------------------------------------------------------------------
Function STWInuNFCE(	cDoc		, cSerie	, cPDV		, cOperador	,;
						cStation	, cMsgErro	, cNumOrc	)

Local lRet	:= .F.
Local aSLX	:= {}

Default cDoc		:= ""
Default cSerie		:= ""
Default cPDV		:= ""
Default cOperador	:= ""
Default cStation	:= ""
Default cMsgErro	:= ""
Default cNumOrc		:= ""

//
// inclui o documento na SLX //Lj7SLXDocE("65", cDoc, cSerie, cPDV, cOperador, "X0")
//
Aadd( aSLX,	{"LX_FILIAL" 	, xFilial("SLX")} )
Aadd( aSLX,	{"LX_CUPOM" 	, cDoc			} )
Aadd( aSLX,	{"LX_SERIE" 	, cSerie		} )
Aadd( aSLX,	{"LX_PDV" 		, cPDV			} )
Aadd( aSLX,	{"LX_OPERADO"	, cOperador		} )
Aadd( aSLX, {"LX_MODDOC"	, iif( AllTrim(cSerie) == STFGetStation("SERIE"), "65", "55") } )
Aadd( aSLX,	{"LX_SITUA"		, "OK"			} )
Aadd( aSLX, {"LX_DTMOVTO"	, DDATABASE		} )
Aadd( aSLX, {"LX_HORA"		, Time()		} )
Aadd( aSLX, {"LX_TPCANC"	, "X"			} )

If SLX->(ColumnPos("LX_MOTIVO")) > 0
	Aadd( aSLX, {"LX_MOTIVO"	, _NoTags(cMsgErro) } )
EndIf

If SLX->(ColumnPos("LX_NUMORC")) > 0
	Aadd( aSLX, {"LX_NUMORC"	, cNumOrc		} )
EndIf

lRet := STFSaveTab( "SLX" , aSLX, .T. /*inclui um novo registro*/ )

//
// atualiza a cesta
//
If lRet
	STDSPBasket("SL1", "L1_DOC"		, CriaVar("L1_DOC")		)
	STDSPBasket("SL1", "L1_SERIE"	, CriaVar("L1_SERIE") 	)
	STDSPBasket("SL1", "L1_KEYNFCE"	, CriaVar("L1_KEYNFCE") )
	STDSPBasket("SL1", "L1_STORC"	, CriaVar("L1_STORC") 	)
	STDSPBasket("SL1", "L1_HORA"	, CriaVar("L1_HORA") 	)
	STDSPBasket("SL1", "L1_SITUA"	, "04"					)
Else
	LJGrvLog(Nil, "Falha ao incluir o Doc na SLX", cDoc)
EndIf

Return lRet


/*/{Protheus.doc} STWDelPay
Exclui os pagamentos e reseta a cesta
@type		function
@param		cNum, caracter, numero do orcamento
@author  	Varejo
@version 	P12
@since   	14/10/2016
@return  	logico, se todos os registros do bd foram excluidos e a cesta foi resetada
/*/
Function STWDelPay( cNum )

Local lRet := .F.
Local lFinishSales	:= IsInCallStack("STWFinishSale")

Default cNum := ""

//
// Apaga os registros de pagamento, pois ao finalizar a venda novamente, eles serao recriados
lRet := STDDelPay(cNum)

If lRet
	//
	// Limpa os campos da cesta referente a Forma de Pagamento
	STDSPBasket("SL1", "L1_DINHEIR"	, CriaVar("L1_DINHEIR")	)
	STDSPBasket("SL1", "L1_CHEQUES"	, CriaVar("L1_CHEQUES") )
	STDSPBasket("SL1", "L1_CARTAO"	, CriaVar("L1_CARTAO")	)
	STDSPBasket("SL1", "L1_CONVENI"	, CriaVar("L1_CONVENI") )
	STDSPBasket("SL1", "L1_VALES"	, CriaVar("L1_VALES") 	)
	STDSPBasket("SL1", "L1_FINANC"	, CriaVar("L1_FINANC")	)
	STDSPBasket("SL1", "L1_OUTROS"	, CriaVar("L1_OUTROS")	)
	STDSPBasket("SL1", "L1_ENTRADA"	, CriaVar("L1_ENTRADA") )

	//-- Quando se utiliza a condicao de pagamento e ocorre um erro de transmissão durante a venda e a mesma e inutilizada
	//-- nao devemos apagar o conteudo destes campos, pois retorna para a tela de fechamento da venda e o usuario ira 
	//-- tentar finalizar novamente e finalizara sem os dados da condicao de pagamento colocando como condicao negociada
	//-- como se tivesse finalizando a venda escolhendo as formas de pagamento e nao escolhendo o legado das condicoes de pagamento
	if !lFinishSales		
		STDSPBasket("SL1", "L1_CONDPG"	, CriaVar("L1_CONDPG")	)
		STDSPBasket("SL1", "L1_FORMPG"	, CriaVar("L1_FORMPG")	)
	endif

	STDSPBasket("SL1", "L1_CREDITO"	, CriaVar("L1_CREDITO") )
	STDSPBasket("SL1", "L1_VENDTEF"	, CriaVar("L1_VENDTEF") )
	STDSPBasket("SL1", "L1_DATATEF"	, CriaVar("L1_DATATEF") )
	STDSPBasket("SL1", "L1_HORATEF"	, CriaVar("L1_HORATEF") )
	STDSPBasket("SL1", "L1_DOCTEF"	, CriaVar("L1_DOCTEF")	)
	STDSPBasket("SL1", "L1_AUTORIZ"	, CriaVar("L1_AUTORIZ") )
	STDSPBasket("SL1", "L1_INSTITU"	, CriaVar("L1_INSTITU") )
	STDSPBasket("SL1", "L1_NSUTEF"	, CriaVar("L1_NSUTEF")	)
	STDSPBasket("SL1", "L1_PARCTEF"	, CriaVar("L1_PARCTEF") )
	STDSPBasket("SL1", "L1_IMPRIME"	, CriaVar("L1_IMPRIME") )
	STDSPBasket("SL1", "L1_VLRDEBI"	, CriaVar("L1_VLRDEBI") )
	
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} STWCancNF()
Cancela uma venda nao fiscal, vale credito, vale presente
@type		function
@param		
@author  	Bruno Almeida
@version 	P12
@since   	28/06/2019
@return  	
/*/
//---------------------------------------------------------------------------------------
Function STWCancNF()

Local lRet 		:= .F. 											//Variavel de retorno
Local aCanc		:= STIGetCancel() 								//Retorna o conteudo do array aCancel
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) 	//Verifica se eh automacao de teste

If Len(aCanc) >= 6
	lRet := STWCSFinalized( aCanc[3] , aCanc[4] , aCanc[5], , , aCanc[6], , .T. )
EndIf

If !lAutomato
	STIGridCupRefresh() // Sincroniza a Cesta com a interface
	STIRegItemInterface()
EndIf

Return lRet


