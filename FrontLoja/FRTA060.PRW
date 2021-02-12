#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTA060.CH"

#DEFINE	 FRT_SEPARATOR		"----------------------------------------"

Static nNCCUsaFr	  := 0			// Estatica - Quantidade de NCCs usadas
Static nNCCGerFr	  := 0			// Estatica - Qunatidade de NCCs a ser gerada
Static aNCCItsFr	  := {}			// Estatica - NCC itens
Static lSeleNCC		  := .F.		// Se ja selecionou NCC na venda
Static lNCCMenor	  := .T.		// Utilizada no FRTA060, para controle de NCC.
Static nFr060PercDesc := 0
Static nFr060VlrDesc  := 0 
Static lMvLjPdvPa 	  := LjxBGetPaf()[2] 		// Indica se é pdv

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³ Frt060Alt³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega variaveis estaticas para serem usadas			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Alt(ExpC1,ExpX2)						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo a ser carregado							  ³±±
±±³          ³ ExpX2 - Valor a ser carregado							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Frt060Alt(cCampo,xValor)

DEFAULT cCampo 	:= ""		// Default do campo
DEFAULT xValor	:= 0		// Default do valor

If cCampo == "NCC_USADA"
	nNCCUsaFr	:= xValor
EndIf

If cCampo == "NCC_GERADA"
	nNCCGerFr	:= xValor
EndIf

If cCampo == "NCC_ITENS"
	aNCCItsFr	:= xValor
	If nModulo == 12
		aNCCItens   := xValor
	EndIf
EndIf
    
If cCampo == "NCC_MENOR"
	lNCCMenor := xValor
EndIf

If cCampo == "060_VLRDESC"
	nFr060VlrDesc := xValor
EndIf

If cCampo == "060_PERDESC"
	nFr060PercDesc := xValor
EndIf
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Frt060Ret³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna valor das variaveis estaticas					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Ret(ExpC1)								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo a ser carregado							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060Ret(cCampo)
Local xRet				// Retorno da funcao

DEFAULT cCampo := ""	// Default do Campo

If cCampo == "NCC_USADA"
	xRet	:= nNCCUsaFr
EndIf

If cCampo == "NCC_GERADA"
	xRet	:= nNCCGerFr
EndIf

If cCampo == "NCC_ITENS"
	xRet	:= aNCCItsFr
EndIf
      
If cCampo == "NCC_MENOR"
	xRet	:= lNCCMenor
EndIf

If cCampo == "060_VLRDESC"
	xRet	:= nFr060VlrDesc
EndIf

If cCampo == "060_PERDESC"	
	xRet	:= nFr060PercDesc
EndIf     
Return xRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Frt060End³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reinicializa as variaveis estaticas  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060End()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060End(oVlrTotal,nVlrTotal,lAtualiz,nVlrBruto,lAtuaBkp)

Local nVlrTot := 0                     
Local lNccMaior := (Frt060Ret("NCC_USADA") > 0)

DEFAULT lAtualiz := .T.
DEFAULT lAtuaBkp := .T.
DEFAULT nVlrBruto:= 0

nNCCUsaFr 	  	:= 0	   	  	// Zera a variavel das NCCs usadas
nNCCGerFr 	  	:= 0	   		// Zera a veriavel de NCCs geradas
aNCCItsFr	  	:= {}	   	 	// Zera array com as NCCs
lSeleNCC	  	:= .F.		 	// Restaura valor se ja foi selecionada NCC
nFr060PercDesc 	:= 0
nFr060VlrDesc  	:= 0 
Frt060Alt("NCC_MENOR",.T.) 		// Restaura valor.

If ExistFunc("Fr271SNCCO")
	Fr271SNCCO(0)
EndIf

If !(lAtualiz)
	If lNccMaior
		nVlrTotal 	:= nVlrBkp
		nVlrBruto 	:= nVlrBkp
		oVlrTotal:Refresh()
		nVlrBkp 	:= 0	
		nVlrBkpDes 	:= 0
	EndIf
EndIf

If !(lAtuaBkp)
	nVlrBkp := 0
EndIf

If ValType(oVlrTotal) <> "U" .AND. ValType(nVlrTotal) <> "U"

	nVlrTot := Frt060Save(nVlrTotal)

	//Somente atualiza caso seja selecionada alguma NCC	
	If nVlrTot > 0 .AND. lNccMaior	 
		nVlrTotal := nVlrTot
		oVlrTotal:Refresh()
		Return nVlrTotal
	Endif

EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Frt060NCC³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza pesquisa de NCCs em aberto (WebService)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060NCC(ExpC1,ExpC2,ExpN3,ExpN4,ExpO5)		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente da venda     							  ³±±
±±³          ³ ExpC2 - Loja da venda        							  ³±±
±±³          ³ ExpN3 - Valor total da venda 							  ³±±
±±³          ³ ExpN4 - Valor total da parcela							  ³±±
±±³          ³ ExpO5 - Objeto a ser atualizado do total					  ³±±
±±³          ³ ExpA6 - Parcelas do orcamento           					  ³±±
±±³          ³ ExpA7 - Backup das parcelas do orcamento					  ³±±
±±³          ³ ExpC10 - String com os codigos dos envelopes SIGAPHOTO	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060NCC(	cCliente	, 	cLojaCli	, nVlrTotal	, oVlrTotal 	,;
					aPgtos		,	nVlrBruto	, aParcOrc		, aParcOrcOld	,;
					nVlrDescTot,	cEnvelopes	, lImpOrc		, nVlrMerc		,;
					aItens		,	nFrete)
					
Local oSvc												// Objeto para WebService
Local lRet 		:= .F.									// Retorno do WebService
Local nX   		:= 0									// Contador de For
Local aNCCIts 	:= {}									// Itens da NCC
Local nNCCUsa	:= 0									// NCC usada
Local nNCCGer	:= 0									// NCC gerada
Local cPadCli	:= SuperGetMv( "MV_CLIPAD" )			// Cliente padrao
Local cPadLoj	:= SuperGetMV( "MV_LOJAPAD") 			// Loja padrao
Local lFRTSelNCC:= ExistFunc("U_FRTSELNCC")  			// Ponto de Entrada para substituir a tela padrao e o WebService de consulta da NCC
Local lFRTDesTot:= ExistFunc("U_FRTDESTOT") 			// Ponto de Entrada para validar desconto no total da venda antes da tela da NCC
Local xRet 		:= 0
Local nPerDesc  := 0
Local nY		:= 0									// Contador de For
Local nTotSave	:= 0									// Salva o total
Local lNotLoja  := (nModulo <> 12 .AND. nModulo <> 72) // Verifica se nao eh o Sigaloja e SigaPhoto para ter o mesmo tratamanto
Local cSoapFCode	:= ""						// Codigo retorno WS
Local cSoapFDescr	:= ""						// Retorno do WS
Local cSvcError		:= ""						// Retorno de erro de WS
Local lLjNCCOr		:= SuperGetMv("MV_LJNCCOR", Nil, .F.)	//verifica se a NCC sera mantida no orcamento (F4)

DEFAULT nVlrTotal 	:= 0								// Default do Total
DEFAULT aParcOrc 	:= {} 								// Parcelas do orcamento
DEFAULT aParcOrcOld	:= {}								// Backup das parcelas do orcamento
DEFAULT nVlrDescTot	:= 0     
DEFAULT cEnvelopes  := ""                 		     	// String com os codigos dos envelopes SIGAPHOTO
DEFAULT lImpOrc		:= .F.                		     	// Se o orcamento eh importacao
DEFAULT nVlrMerc	:= 0
DEFAULT aItens		:= {}
DEFAULT nFrete		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Entra no conceito de NCC se:                 ³
//³- Parametro MV_USACRED habilitado            ³
//³- Cliente e loja da venda diferente de padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(SuperGetMV("MV_USACRED",,"SS"),2,1) == "S" .AND. (cCliente + cLojaCli <> cPadCli + cPadLoj)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ja foi selecionada a NCC anteriormente, para não ficar utilizando a todo momento o WebService³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lSeleNCC
		If lFRTSelNCC
	        If lFRTDesTot
	           xRet := ExecBlock("FRTDESTOT", .F.,.F.,{nVlrTotal,nVlrDescTot,nPerDesc})
	           
	           If ValType( xRet ) == "A" .And. (xRet[2]>0 .And. xRet[1]>0) .And. xRet[2]<nVlrTotal

	    			Frt060Alt("060_VLRDESC",xRet[2])
					Frt060Alt("060_PERDESC",xRet[1])
					
					nVlrDescTot := xRet[2]
						
						
			    EndIf
			   
	        EndIf
	        
			 aNCCIts := U_FRTSELNCC((nVlrTotal-nVlrDescTot),@nNCCUsa,cCliente, cLojaCli,aPgtos,nVlrDescTot)
			 
			 If Len(aNCCIts) > 0
			 	lRet := .T.
			 EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia conexao com o WebService para consulta de NCCs abertas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSvc      := WSFRTNCC():New()
			oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/FRTNCC.apw"
			
			//"Aguarde...Verificando NCC em aberto..."
			LJMsgRun( STR0001,, { || lRet := oSvc:FRTGETNCC(cCliente, cLojaCli, cEnvelopes,cEmpAnt,;
															cFilAnt , lMvLjPdvPa, dDataBase, lImpOrc, SL1->L1_NUMORIG) } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a consulta WebService foi executada com sucesso³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndIf
		If ValType(lRet) =="U" .OR. !lRet
			If !lFRTSelNCC
				cSvcError := GetWSCError()
				If Left(cSvcError,6) == "WSCERR"
					If ValType(GetWSCError(3)) == "C"				
						cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
						cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
						Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
					EndIf	
				Else
					//"A pesquisa das NCC em aberto não foi realizada. A venda prosseguirá normalmente."
					//"Sem comunicação com o WebService (Pesquisa da NCC)!"
					MsgStop(STR0002,STR0003)
				EndIf
			Else
				//"A pesquisa das NCC em aberto não foi realizada. A venda prosseguirá normalmente."
				//"Sem comunicação com o WebService (Pesquisa da NCC)!"
				MsgStop(STR0002,STR0003)
			EndIf
		Else
			If !lFRTSelNCC
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retorna array com as NCCs em aberto para o cliente da venda³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to Len( oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO )
					aAdd( aNCCIts, { 	oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:LSELECIONA	,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:nSALDO		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:CNUMTITULO	,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:dDATANCC		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:nNUMRECNO	,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:nSALDO2		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:cMVMOEDA		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:nMOEDA		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:cPREFIXO		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:cPARCELA		,;
					oSvc:oWSFRTGETNCCRESULT:oWSWSRETABERTO[nX]:cTIPO		} )
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama funcao componentizada para apresentar tela com as NCCs do cliente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aNCCIts) > 0
					If lLjNCCOr  .AND. lImpOrc
						aEval( aNCCIts, {|x| nNCCUsa += x[2] } )
						If nModulo == 12
							nNCCUsada := nNCCUsa
						EndIf
					Else
						If (nModulo == 12 .OR. nModulo == 72)
							LjxDSelNCC(	@aNCCIts,"LOJ",nVlrTotal,@nNCCUsa  )
						Else
							LjxDSelNCC(	@aNCCIts,"FRT",nVlrTotal,@nNCCUsa )
						EndIf
					EndIf						
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso não for selecionado nenhuma NCC, não efetua os tratamentos ³
			//³abaixo para não anular a condição de pagamento importado da     ³
			//³retaguarda.				 									   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nNCCUsa > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta variaveis estaticas que seram utilizadas posteriormente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Frt060Alt("NCC_ITENS",aNCCIts)
				Frt060Alt("NCC_USADA",nNCCUsa)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta variavel lSeleNCC para true, para nao ficar chamado o WebService a todo momento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lSeleNCC 	:= 	.T.
				Frt060Alt("NCC_MENOR",.F.)   
				nTotSave	:= nVlrTotal		// Guarda o total antes de chamar a tela de desconto
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento do desconto                   			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
				//³SIGALOJA\SIGAPHOTO - Nao eh permitido desconto no total na tela de forma de pagamento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lNotLoja 
					If Frt060Ret("NCC_USADA") > 0
						Frt060Desc(@oVlrTotal, @nVlrTotal, @nVlrDescTot, lLjNCCOr, lImpOrc, nVlrMerc, aItens)
					Endif
				EndIf	
				             
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica qual sera o valor da NCC a ser gerada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nNCCGer := 	((nTotSave)  - Frt060Ret("060_VLRDESC")) - Frt060Ret("NCC_USADA")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta variaveis estaticas que serao utilizadas posteriormente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nNCCGer >= 0
					Frt060Alt("NCC_GERADA",0)
				Else
					Frt060Alt("NCC_GERADA",Abs(nNCCGer))
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o valor total do FrontLoja, apos selecao da NCC³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nVlrTotal) > 0					
					If (nVlrTotal-nVlrDescTot) > Frt060Ret("NCC_USADA")
						Frt060Alt("NCC_MENOR",.T.)
						nVlrTotal := (nVlrTotal-nVlrDescTot) - Frt060Ret("NCC_USADA")
						nVlrBruto := nVlrTotal
						cCupom 	  := "  S U B T O T A L          " + STR(nVlrTotal)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza a variavel nValor (caso a escolha da forma de pagamento seja via Crlt + 'X')³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nValor := nVlrTotal
					Endif
	            EndIF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Proporcionaliza a NCC nas parcelas do orcamento carregado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(lLjNCCOr  .AND. lImpOrc)
					If Len(aParcOrc) > 0
						aParcOrc 	:= {}
						aParcOrcOld := {}
					EndIf
				EndIf
	
				If !(Frt060Ret("NCC_MENOR")) .AND. lNotLoja 
					nVlrBruto := 0
					AAdd( aPgtos, { Ctod("  /  /  "), 0 , "" , "", "", "", "", "", "", .F., 1, Space(04), 0 ,"" })		
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o objeto do valor total do FrontLoja³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lNotLoja 
					oVlrTotal:Refresh() 
				Endif
			EndIf
		Endif
	EndIf
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060BxNC³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza baixa das NCCs selecionadas (WebService)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060BxNCC(ExpC1,ExpC2,ExpC3,ExpD4,ExpC5,ExpC6,ExpN7)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Documento da venda   							  ³±±
±±³          ³ ExpC2 - Serie da venda       							  ³±±
±±³          ³ ExpC3 - Operador da venda    							  ³±±
±±³          ³ ExpD4 - Data de emissao da venda							  ³±±
±±³          ³ ExpC5 - Cliente da venda                					  ³±±
±±³          ³ ExpC6 - Loja da venda                   					  ³±±
±±³          ³ ExpN7 - Total de credito para o cliente 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060BxNCC(	cL1Doc	  ,	cL1Serie, cL1Oper  	, dL1EmisNf	,;
						cL1Cliente,	cL1Loja	, nL1Credit	, oVlrTotal	,;
						nVlrTotal , lJob    , cL1Num	, cParcela	,;
						aRecnoSE1 , aVlrReceb )

Local nX 		:= 0							// Contador de For
Local lRet		:= .F.							// Retorno do WebService
Local aItensNcc := Frt060Ret("NCC_ITENS")		// Itens da NCC
Local cSerEst	:= "" 							// Serie do cadastro de estacao 
Local oSvc										// Objeto do WebService
Local aMDJ		:= {}							// Array com os dados para gravar na MDJ
Local cSoapFCode	:= ""						// Codigo retorno WS
Local cSoapFDescr	:= ""						// Retorno do WS
Local cSvcError		:= ""						// Retorno de erro de WS
Local lFrTr860A	:= ExistBlock("FRTR860A") .And. SuperGetMv("MV_LJLOCNC",.F.,.F.)		// Verifica a utilização do ponto de entrada para a impressão da NCC 
Local lR5		:= GetRpoRelease("R5")    		// Indica se o release e 11.5 
Local aNewNCC	:= {}    						// Array com as informações da nova NCC 
Local oBanco								   // Objeto do WebService//
Local nVlrRestNcc	:= 0						// Valor restante da NCC usada em Recebimento ou Venda 

DEFAULT lJob	:= .F.							// se .T. foi chamdo pelo JOB do FRTA020
DEFAULT cL1Num	:= SL1->L1_NUM
DEFAULT cParcela:= SuperGetMV("MV_1DUP")		// Parcela da NCC 
DEFAULT	aRecnoSE1 := {}
DEFAULT aVlrReceb := {}

If GetRpoRelease ("R5") .AND. cPaisLoc$"CHI|COL"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Localizacoes                                    ³
	//³Se o pais nao utiliza ECF, utilizar a mesma serie do documento ³
	//³gravada no campo L1_SERIE.Caso contrario,obter o a serie do    ³
	//³cadastro de estacao.                                           ³
	//³Paises:Chile/Colombia - F1CHI								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
	If LjNfPtgNEcf(SM0->M0_CGC)	                                       	
		cSerEst:= cL1Serie	
	Else
		cSerEst:= LjGetStation("LG_SERIE")
		cSerEst:= Padr(cSerEst, TamSx3("LG_SERIE")[1])
	Endif
Else
	cSerEst	:=	LjGetStation("LG_SERIE")
	cSerEst	:=	Padr(cSerEst, TamSx3("LG_SERIE")[1])   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Baixas os Creditos do Cliente   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Frt060Ret("NCC_USADA") > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena das informacoes da NCC a ser baixada. Caso precise gerar LOG para o estorno (cancelamento)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItensNcc) > 0
		Frt060Txt(aItensNcc, cL1Cliente, cL1Loja, cL1Doc, cL1Serie,nL1Credit,Frt060Ret("NCC_GERADA"))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia conexao com o WebService para consulta de NCCs abertas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc := WSBAIXANCC():New()
	oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/BAIXANCC.apw"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Passa para o WebService as variaveis necessarias para realizar a baixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc:nnNCCUsada 	:= Frt060Ret("NCC_USADA")
	oSvc:nnNCCGerada 	:= Frt060Ret("NCC_GERADA")
	oSvc:ccL1Doc 		:= cL1Doc
	oSvc:ccL1Serie 		:= cL1Serie
	oSvc:ccL1Oper 		:= cL1Oper
	oSvc:ddL1EmisNf		:= dL1EmisNf
	oSvc:ccL1Cliente	:= cL1Cliente
	oSvc:ccL1Loja		:= cL1Loja
	oSvc:nnL1Credit		:= nL1Credit
	oSvc:ccSerEst		:= cSerEst 
	oSvc:ccEmpPdv		:= cEmpAnt	
	oSvc:ccFilPdv		:= cFilAnt	
	oSvc:llMvLjPdvPa	:= lMvLjPdvPa
 	oSvc:ccL1Orc 		:= SL1->L1_NUMORIG

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o array dentro do metodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc:oWSARECNOSE1:OWSRECARRAY 					:= BAIXANCC_ARRAYOFWSRecnoSE1():New()
	oSvc:oWSARECNOSE1:OWSRECARRAY:OWSWSRecnoSE1 	:= Array( Len(aRecnoSE1) )
	
	For nX := 1 To Len(aRecnoSE1)
		oSvc:oWSARECNOSE1:OWSRECARRAY:OWSWSRecnoSE1[nX]				:= BAIXANCC_WSRECNOSE1():New()
		oSvc:oWSARECNOSE1:OWSRECARRAY:OWSWSRecnoSE1[nX]:nRecnoSE1	:= aRecnoSE1[nX]
	Next nX
         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o array dentro do metodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc:oWSAVLRRECEB:OWSRECARRAY 					:= BAIXANCC_ARRAYOFWSVLRRECEB():New()
	oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB 	:= Array( Len(aVlrReceb) )
	
	For nX := 1 To Len(aVlrReceb)
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]				:= BAIXANCC_WSVLRRECEB():New()
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]:nVlrReceb	:= aVlrReceb[nX][1]      		
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]:nVlrMulta	:= aVlrReceb[nX][2]      		
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]:nVlrJuros	:= aVlrReceb[nX][3]      		
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]:nVlrDesco	:= aVlrReceb[nX][4]      		
		oSvc:oWSAVLRRECEB:OWSRECARRAY:OWSWSVLRRECEB[nX]:nPosRgSE1	:= aVlrReceb[nX][5]      				
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o array dentro do metodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc:oWSANCCITENS:OWSVERARRAY 						:= BAIXANCC_ARRAYOFWSNCCITENS():New()
	oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS 		:= Array( Len(aItensNcc) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes de chamar o metodo, atribui os valores ³
	//³as propriedades (passagem de parametros)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aItensNcc)
		
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX] := BAIXANCC_WSNCCITENS():New()
		
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:LSELECIONA	:=	aItensNcc[nX][1]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:nSALDO		:=	aItensNcc[nX][2]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:CNUMTITULO	:=	aItensNcc[nX][3]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:dDATANCC	:=	aItensNcc[nX][4]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:nNUMRECNO	:=	aItensNcc[nX][5]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:nSALDO2		:=	aItensNcc[nX][6]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:cMVMOEDA	:=	aItensNcc[nX][7]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:nMOEDA		:=	aItensNcc[nX][8]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:cPREFIXO	:=	aItensNcc[nX][9]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:cPARCELA	:=	aItensNcc[nX][10]
		oSvc:oWSANCCITENS:OWSVERARRAY:OWSWSNCCITENS[nX]:cTIPO		:=	aItensNcc[nX][11]
	Next nX
	
    // Para o Job nao executa pela MsgRun
	If lJob 
		lRet := oSvc:FRTBXNCC() 
	Else
		//"Aguarde...Baixando NCC em aberto..." 
		LJMsgRun( STR0004,, { || lRet := oSvc:FRTBXNCC() } )
	EndIf		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve sobra na NCC utilizada na  
	// venda, permitindo que seja mostrada ao usuario 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(lRet) =="L" .AND. lRet .AND. oSvc:nFRTBXNCCRESULT > 0 
		nVlrRestNcc := oSvc:nFRTBXNCCRESULT
	ElseIf Len(aVlrReceb) > 0 
		nVlrRestNcc := Frt060Ret("NCC_GERADA")
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a operacao ocorreu sem problemas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(lRet) =="U" .OR. !lRet
		cSvcError := GetWSCError()
		If Left(AllTrim(cSvcError),6) == "WSCERR"
			If ValType(GetWSCError(3)) == "C"
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o Situa da da NCC que estava pendente para "ER" - Erro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lJob .AND. Left(cSvcError,9) <> "WSCERR044"
				Frt060MDJok(cL1Doc,cL1Serie,cL1Cliente,cL1Loja,"ER")
			EndIf
		ElseIf !lJob
			//"Sem comunicação com o WebService!"+"Atencao"
			MsgStop(STR0005,STR0006)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apresenta mensagem de erro na consulta WebService³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aItensNcc) > 0 .AND. !lJob
			// Grava as NCCs para uma baixa automatica posteriormente
			Aadd(aMDJ,{"MDJ_FILIAL"  	,xFilial("MDJ")	})
			Aadd(aMDJ,{"MDJ_DOC"  	 	,cL1Doc})
			Aadd(aMDJ,{"MDJ_SERIE"   	,cL1Serie})
			Aadd(aMDJ,{"MDJ_CLIENT" 	,cL1Cliente})
			Aadd(aMDJ,{"MDJ_LOJA"  	 	,cL1Loja})
			Aadd(aMDJ,{"MDJ_OPERAD" 	,cL1Oper})
			Aadd(aMDJ,{"MDJ_EMIS"   	,dL1EmisNf})
			Aadd(aMDJ,{"MDJ_NCCUSA"  	,Frt060Ret("NCC_USADA")})
			Aadd(aMDJ,{"MDJ_NCCGER" 	,Frt060Ret("NCC_GERADA")})
			Aadd(aMDJ,{"MDJ_CREDIT"  	,nL1Credit})
			Aadd(aMDJ,{"MDJ_NUMORC" 	,SL1->L1_NUM})
			Aadd(aMDJ,{"MDJ_OPER"  		,"B"})
			Aadd(aMDJ,{"MDJ_SITUA" 		,"NP"})
			// Faz a gravacao nas tabelas de NCC pendentes para serem baixadas posteriormente
			Frt060GrvNcc( aMDJ , aItensNcc , 1)		
			Frt060Msg(1,cL1Num)
		EndIf
	Else
		If nVlrRestNcc > 0 .AND. !lJob
			//"Nota de Crédito ao Cliente", "Restou um crédito no valor de: "	
			Aviso(STR0028, STR0029 + SuperGetMV("MV_SIMB1") + " " + ;
			AllTrim(Transform(nVlrRestNcc,PesqPict("SE1","E1_VALOR"))), {"Ok"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada utilizado para impressão da NCC com o valor do saldo restante   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Substr(SuperGetMV("MV_USACRED",,"SS"),1,1) == "S"		
				If lFrTr860A .And. lR5					

					If lRet 
						lRet := oSvc:FRTGETSA6()
					Endif
					
					//Adiciona as informacoes da NCC gerada.
					AADD(aNewNCC,{cSerEst,cL1Doc,cParcela,"NCC",oSvc:DDL1EMISNF,DataValida(dL1EmisNf,.T.),nVlrRestNcc,cL1Cliente,cL1Loja,Iif(Len(oSvc:OWSFRTGETSA6RESULT:OWSWSBANCO)>0,oSvc:OWSFRTGETSA6RESULT:OWSWSBANCO[1]:NMOEDA,1) } )

					U_FRTR860A(	aNewNCC, aItensNcc , (nVlrRestNcc) )
					
				Endif 			                                                                    							
			Endif 			
			
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera o Situa da da NCC que estava pendente para "OK" ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lJob  
			Frt060MDJok(cL1Doc,cL1Serie,cL1Cliente,cL1Loja,"OK")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera as variaveis estaticas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Frt060End(oVlrTotal,nVlrTotal,nil,nil,.F.)
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060ExNC³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza estorno das NCCs selecionadas (WebService)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060ExNCC(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial da venda      							  ³±±
±±³          ³ ExpC2 - Documento da venda   							  ³±±
±±³          ³ ExpC3 - Serie da venda       							  ³±±
±±³          ³ ExpC4 - Cliente da venda        							  ³±±
±±³          ³ ExpC5 - Loja da venda                  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060ExNCC(	cL1Filial	, cL1Doc, cL1Serie, cL1Cliente	,;
						cL1Loja 	, lJob    , cL1Num , cL1Oper 	,;
						dL1EmisNf	, nL1Credit)

Local lRet		:= .F.							// Retorno do WebService
Local oSvc										// Objeto do WebService
Local aMDJ		:= {}							// Array com os dados para gravar na MDJ
Local cSoapFCode	:= ""						// Codigo retorno WS
Local cSoapFDescr	:= ""						// Retorno do WS
Local cSvcError		:= ""						// Retorno de erro de WS

DEFAULT lJob		:= .F.						// se .T. foi chamdo pelo JOB do FRTA020
DEFAULT cL1Num		:= SL1->L1_NUM
DEFAULT cL1Oper 	:= ""
DEFAULT dL1EmisNf	:= Ctod(Space(8))
DEFAULT nL1Credit	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia conexao com o WebService para consulta de NCCs abertas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc := WSDELNCC():New()
oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/DELNCC.apw"

If lJob   
	lRet := oSvc:FRTDELNCC(cL1Filial , cL1Doc	,	cL1Serie	,	cL1Cliente	,;
	cL1Loja)  
Else
	//"Aguarde...Estornando a NCC do cliente..."
	LJMsgRun( STR0007,, { || lRet := oSvc:FRTDELNCC(cL1Filial , cL1Doc	,	cL1Serie	,	cL1Cliente	,;
													cL1Loja	  , cEmpAnt ,   cFilAnt		,   lMvLjPdvPa) } )
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a operacao WebService foi realizada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(lRet) == "U" .OR. !lRet   
	cSvcError := GetWSCError()
	If Left(cSvcError,6) == "WSCERR"
		If ValType(GetWSCError(3)) == "C"	
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		EndIf	
	ElseIf !lJob
		//"Sem comunicação com o WebService!"+"Atencao"
		MsgStop(STR0005,STR0006)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta mensagem de erro na consulta WebService³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		Aadd(aMDJ,{"MDJ_FILIAL"  	,cL1Filial	})
		Aadd(aMDJ,{"MDJ_DOC"  	 	,cL1Doc}) 				
		Aadd(aMDJ,{"MDJ_SERIE"   	,cL1Serie})
		Aadd(aMDJ,{"MDJ_CLIENT" 	,cL1Cliente})
		Aadd(aMDJ,{"MDJ_LOJA"  	 	,cL1Loja})
		Aadd(aMDJ,{"MDJ_OPERAD" 	,cL1Oper})
		Aadd(aMDJ,{"MDJ_EMIS"   	,dL1EmisNf})
		Aadd(aMDJ,{"MDJ_NCCUSA"  	,Frt060Ret("NCC_USADA")})
		Aadd(aMDJ,{"MDJ_NCCGER" 	,Frt060Ret("NCC_GERADA")})
		Aadd(aMDJ,{"MDJ_CREDIT"  	,nL1Credit})
		Aadd(aMDJ,{"MDJ_NUMORC" 	,cL1Num})
		Aadd(aMDJ,{"MDJ_OPER"  		,"E"})
		Aadd(aMDJ,{"MDJ_SITUA" 		,"NP"})
		// Faz a gravacao nas tabelas de NCC pendentes para serem baixadas posteriormente
		Frt060GrvNcc( aMDJ  , NIL , 2)		
		Frt060Msg(2,cL1Num)
	EndIf
Else     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera o Situa da da NCC que estava pendente para "OK" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lJob  
		Frt060MDJok(cL1Doc , cL1Serie , cL1Cliente,cL1Loja,"OK")
	EndIf
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Txt ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia operacao para gravacao do LOG.           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Txt(ExpA1,ExpC2,ExpN3,ExpN4,ExpO5)		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - NCCs da venda        							  ³±±
±±³          ³ ExpC2 - Cliente da venda     							  ³±±
±±³          ³ ExpC3 - Loja da venda        							  ³±±
±±³          ³ ExpD4 - Documento da venda      							  ³±±
±±³          ³ ExpC5 - Serie da venda                  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt060Txt(	aCloneNcc, cL1Cliente, cL1Loja, cL1Doc,;
							cL1Serie,nL1Credit,nGerNCCCli )

Local aTexto 	:= {}				// Texto a ser gerado o LOG de erro
Local nX 		:= 0				// Contador de For 

Default nL1Credit := 0
Default nGerNCCCli := 0

//"WEBSERVICE INDISPONÍVEL NA TRANSAÇÃO DE NCC"
Aadd(aTexto,STR0008)
//"Avisar o Supervidor/Administrador!"
Aadd(aTexto,STR0009)
//"Dados da venda abaixo:"
Aadd(aTexto,STR0010)
//"Cliente: "
Aadd(aTexto,STR0011 + cL1Cliente)
//"Loja: "
Aadd(aTexto,STR0012 + cL1Loja)
//"Número/Serie da venda correspondente: "
Aadd(aTexto,STR0013 + cL1Doc	 + "/" + cL1Serie)
//"Número/Serie da venda correspondente: "
Aadd(aTexto, STR0037 + Str(nL1Credit - nGerNCCCli,14,2))//"Valor utilizado de NCC: "

If nGerNCCCli > 0
	//"Número/Serie da venda correspondente: "
	Aadd(aTexto,STR0038 + Str(nGerNCCCli,14,2))//"Saldo restante de NCC: "
EndIf

//"NCCs que precisam ser verificadas manualmente:"
Aadd(aTexto,STR0036)   //"NCCs serão verificadas automáticamente :"
For nX := 1 To Len(aCloneNcc)
	If aCloneNcc[nX][1]
		//Linha que separa
		Aadd(aTexto,STR0015)
		//"Título da NCC : "
		Aadd(aTexto,STR0016 + aCloneNcc[nX][3])
		//"Prefixo da NCC: "
		Aadd(aTexto,STR0017 + aCloneNcc[nX][9])
		//"Parcela da NCC: "
		Aadd(aTexto,STR0018 + aCloneNcc[nX][10])
		//"Tipo da NCC   : "
		Aadd(aTexto,STR0019 + aCloneNcc[nX][11])
	EndIf
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava arquivo fisico do LOG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frt060Log(SL1->L1_NUM,aTexto)

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Log ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia operacao para gravar arquivo fisico de LOG		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Log(ExpN1,ExpC2,ExpA3)					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Operacao da gravacao 							  ³±±
±±³          ³ ExpC2 - Numero orcamento da venda						  ³±±
±±³          ³ ExpA3 - Texto a ser gravado  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt060Log( cNumOrc, aTexto )
Local cCam 		:= Frt060Cam()			// Verifica o campo que deve ser gerado o LOG
Local cTexto 	:= ""					// Texto a ser gerado o LOG
Local nX		:= 0					// Contador de for


If !Empty(cCam)
	For nX := 1 to Len(aTexto)
		cTexto += aTexto[nX] + Chr(10)
	Next nX
	Frt060Dir( cCam + cNumOrc + '.TXT', cTexto )

EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Cam ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Caminho onde sera gerado o LOg                   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Cam()   									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                          						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt060Cam()
Local cDirLog  := ""				//Diretorio de LOG

cDirLog  := "\AUTOCOM\NCC" + cEmpAnt + cFilAnt + "\"

Return (cDirLog)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Dir ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se ja existe o arquivo e caminho a ser criado	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Dir(ExpC1,ExpC2)	    					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Caminho e arquivo    							  ³±±
±±³          ³ ExpC2 - Texto a ser gravado      						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt060Dir( cArq, cTexto )

Local nHandle := 0		//Verifica se criou o arquivo

DEFAULT cTexto:= " "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria diretorio e arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cArq )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\NCC" + cEmpAnt + cFilAnt )
	nHandle := FCreate( cArq )
	FClose( nHandle )
Endif
If File( cArq )
	cTexto  := dtoc(ddatabase) + " " + Time() + " " +cTexto
	nHandle := FOpen( cArq, 2 )
	FSeek ( nHandle, 0, 2 )
	FWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto)+2 )
	FClose( nHandle)
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Msg	³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta mensagem de erro na consulta WebService		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Msg(ExpN1,ExpC2)							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Operacao da apresentacao							  ³±±
±±³          ³ ExpC2 - Numero orcamento da venda						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt060Msg(nTipo,cNumOrc)
Local cTexto	:= ""				//Texto do arquivo
Local nHdlTxt	:= 0				//Leitura do arquivo
Local cDirLog  	:= ""				//Caminho a ser gravado
Local aTexto 	:= {}				//Texto adicional do arquivo
Local nTam 		:= 0				//Tamanho do texto
Local lRet 		:= .F.				//Retorno do LjProfile
Local oFont							//Objeto para apresentacao da tela
Local oDlg							//Objeto para apresentacao da tela
Local oMemo							//Objeto para apresentacao da tela

cDirLog := "\AUTOCOM\NCC" + cEmpAnt + cFilAnt + "\" + cNumOrc + '.TXT'

//"Criado o LOG na pasta: \AUTOCOM\NCC"
Aadd(aTexto,STR0020 + cEmpAnt + cFilAnt + "\" + cNumOrc + '.TXT')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica que operacao esta sendo realizada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	//"Operação do WebSerice indisponivel: BAIXA da NCC"
	Aadd(aTexto,STR0021)
Else
	//"Operação do WebSerice indisponivel: ESTORNO da NCC"
	Aadd(aTexto,STR0022)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava no LOG informacoes adicionais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frt060Log( cNumOrc, aTexto )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abri o arquivo de LOG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlTxt := fOpen(cDirLog,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi aberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHdlTxt <= 0
	If nTipo == 1
		//"As NCCs usadas na venda, precisam ser baixadas manualmente! Avisar o Supervidor!"
		//"Sem comunicação com o WebService (Baixa da NCC)!"
		MsgStop(STR0023,STR0024)
	Else
		//"Não foi possível estornar a baixa das NCCs, necessário realizar manualmente! Avisar o Supervisor!"
		//"Sem comunicação com o WebService (Estorno da NCC)!"
		MsgStop(STR0025,STR0026)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca quantidade de linhas no arquivo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTexto	:=	Space(FSeek(nHdlTxt,0,2))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no final do arquivo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FSeek(nHdlTxt,0,0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tamanho do texto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTam 	:= Len(cTexto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua leitura do arquivo fisico para ser apresentado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fRead(nHdlTxt,@cTexto,nTam)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta tela com as informacoes da NCC nao baixada/estornada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oFont NAME "ARIAL" SIZE 6,16
	//"Sem comunicação com o WebService!"
	DEFINE MSDIALOG oDlg TITLE STR0027 From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTER
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solicita senha do superior³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criada nova permissao no LjProfile somente para o FrontLoja³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := LjProfile( 21 )
		Loop
	End
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Desc³ Autor ³ Venda Clientes        ³ Data ³07/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a teleda de desconto no total, quando utilizado NCC. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Desc(ExpN1,ExpC2)							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Operacao da apresentacao							  ³±±
±±³          ³ ExpC2 - Numero orcamento da venda						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Frt060Desc(oVlrTotal, nVlrTotal, nVlrDescTot, lLjNCCOr, lImporc, nVlrMerc, aItens)

Local  nPerdesc	:= 0
Local  nVlrBruto	:= 0
Local  nOpcDesc	:= 0
Local  nVlrDNCCTot:= 0
Local  lDescNcc	 := SuperGetMV("MV_LJDENCC", ,.T.)	    // Identifica se o cliente utiliza a tela de desconto após uso da Ncc no Front-Loja
Local  xRet
Local  nValFret	 := ( SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA)

Local lFRTDesTot  := ExistFunc("U_FRTDESTOT") 			// Ponto de Entrada para validar desconto no total da venda antes da tela da NCC
Local lAtualiz    :=.T.

Static nVlrTotSv    := 0

DEFAULT nVlrTotal := 0
DEFAULT nVlrDescTot := 0
DEFAULT lLjNCCOr		:= .F.
DEFAULT lImporc			:= .F.
DEFAULT nVlrMerc		:= 0
DEFAULT aItens		:= {}

If nVlrTotal > 0
	nVlrBkp := nVlrTotal
EndIf

nVlrTotSv := nVlrTotal
nVlrBruto := nVlrTotal

If ValType(lDescNcc) == "C" .AND. SubStr(lDescNcc,1,1) == "&"
	xRet  := &(SubStr(lDescNcc,2,Len(lDescNcc))) 
	If ValType(xRet) == "L"
		lDescNcc := xRet
	EndIf
EndIf

nPerdesc := Frt060Ret("060_PERDESC")

If lFRTDesTot .And. nPerdesc > 0 .And. !lDescNcc 
	nOpcDesc	:= 2
   	lAtualiz	:=.F.
Else 
   nPerdesc	:= 0
EndIf

// Para o desconto não pode considerar o valor do frete , pois o desconto é somente em cima do total da venda
// Nao necessario verificar se importacao, pois quando adicionado item retina no front, a variavel lImpOrc fica false
// e frete nunca deve ser considerado no desconto total
If lDescNcc 
	If nValFret > 0 
		nVlrBruto -= nValFret
		nVlrTotal -= nValFret
	EndIf			
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a funcionalidade de manter a NCC no orcameto na retaguarda estiver ligada     |
// (lLjNCCor) não apresenta a tela de desconto , pos nesta regra nao podera alterar
// as condicoes e descontos definidas na retaguarda                                 |
// Caso seja alterado algo , voltara ao padrao, mostrando a tela de desconto       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lDescNcc .AND. ((lLjNCCOr  .AND. !limpOrc) .OR. !lLjNCCOr)
	Frtx272T09(	@nVlrDescTot, @nPerDesc		, @nOpcDesc , nVlrTotal,;
				@nVlrTotal  , @nVlrDNCCTot 	, @nVlrBruto, 1		  ,;
				aItens)
ElseIf lLjNCCOr
	nPerDesc	:= Round( 100 - ( ( ( nVlrBruto - nVlrDescTot) / (nVlrBruto - nVlrDNCCTot) ) * 100 ),2 )
	nOpcDesc	:= 1
EndIf

// volta o valor do frete nos valores de desconto
If lDescNcc .AND. nValFret > 0 
	nVlrBruto += nValFret
	nVlrTotal += nValFret    	
EndIf
		
If (nVlrTotal-nVlrDescTot) > Frt060Ret("NCC_USADA")  
	If nOpcDesc == 1
		If nVlrDescTot > (nVlrTotal-Frt060Ret("NCC_USADA")) 
	        msgstop(STR0035)          					//"O valor do desconto supera o valor total da venda abatido a NCC"
			Frt060Alt("060_VLRDESC",0)
			Frt060Alt("060_PERDESC",0)
	        nVlrDescTot := 0
			nPerdesc   := 0
			nVlrBruto  := 0
			nVlrTotal  := nVlrTotSv
			frt060end(oVlrtotal,nVlrTotal)
     		Return
	     Else
    		Frt060Alt("060_VLRDESC",nVlrDescTot)
			Frt060Alt("060_PERDESC",nPerDesc)
			nVlrDescTot := 0
			nPerdesc   := 0
			nVlrBruto  := 0
			nVlrTotal  := nVlrTotSv
    	Endif
	Else
		If lAtualiz
		   nVlrDescTot := 0
			nPerdesc    := 0
			Frt060Alt("060_VLRDESC",0)
			Frt060Alt("060_PERDESC",0)
		Else
			nVlrDescTot := 0
			nPerdesc   := 0
			nVlrBruto  := 0
			nVlrTotal  := nVlrTotSv			
		EndIf	
	EndIf
Else
	Frt060Alt("060_VLRDESC",nVlrDescTot)
	Frt060Alt("060_PERDESC",nPerDesc)
	nVlrDescTot := 0
	nPerdesc   := 0
	nVlrBruto  := 0
	nVlrTotal  := 0
Endif   

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060Save³ Autor ³ Venda Clientes        ³ Data ³07/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor total Bruto, sem o Desconto e o Vlr da NCC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Desc(ExpN1,ExpC2)							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ nVlrTotOld - Valor total bruto				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060Save(nVlrTotal)
Local nVlrTotOld := 0

nVlrTotOld := nVlrTotSv

Return nVlrTotOld
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR060CalcDesc³ Autor ³ Venda Clientes        ³ Data ³07/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a teleda de desconto no total, quando utilizado NCC.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Frt060Desc(ExpN1,ExpC2)							             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Operacao da apresentacao							     ³±±
±±³          ³ ExpC2 - Numero orcamento da venda						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR060CalcDesc(	nTmpJuros	, nTmpDesc		, lExTela		, oPgtosSint	,;
						aPgtosSint 	, oPgtos		, aPgtos		, oCupom		,;
						nVlrTotal 	, nVlrBruto		, nVlrDescTot	, oVlrTotal		,;
						nEntrada	, nTaxaMoeda	, lRecebe		, dDataCN 		,;
						aItens		, nVlrMerc		, lDescTotal	, lDescSE4		,;
						nTotDedIcms	, nVlrPercTot	, nMoedaCor		, nDecimais		,;
						aImpsSL1	, aImpsSL2		, aImpsProd		, aDadosJur		,;
						aFormCtrl	, cItemCond		, lCondNegF5	, lDescEspec	,;
						nTxJuros	, nValorBase	, lDiaFixo	)


Local nValorDesc	:= 0				// Variavel que contem o valor do desconto
Local nPercDesc		:= 0				// Variavel que contem o percentual do desconto
Local aKey			:= {}				// SetKey's do Fechamento da Venda
Local nOpc			:= 1				// Variavel que determina qual botao foi escolhido da dialog do desconto
Local cFormaId		:= " "				// Id utilizado como identificador das parcelas
Local lVisuSint  	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior

DEFAULT lExTela		:= .T.

nValorDesc := Frt060Ret("060_VLRDESC")
nPercDesc  := Frt060Ret("060_PERDESC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for chamada da rotina de recebimento, retorna sem fazer nada      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao das variaveis                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFormaId	:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Setkey's do fechamento da venda                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()


If nOpc == 1 .OR. !lExTela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ              ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ Para o estado de MG nao eh necessario este passo, mas por impedimento³
	//³ tecnico este passo deverah ser realizado (Nao eh possivel registrar  ³
	//³ desconto depois da forma de pagamento)                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(14)[1]
		If nValorDesc > 0
			nRet := IFDescTot(nHdlECF, AllTrim(Str(nValorDesc,14,2)))
			If nRet <> 0
				HELP(' ',1,'FRT033')	// "Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada.", "Atenção"
				nOpc := 0
			Else
				lDescTotal := .T.				// Seta que o desconto no total da venda foi concedido
			EndIf
		EndIf
	Else
		If nValorDesc == 0
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:AppendText( STR0039 + chr(10) + chr(13) )	// "Desconto no total do cupom : CANCELADO"
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:Refresh()
		Else
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:AppendText(CHR(13)+CHR(10))				
			oCupom:AppendText( PadR(STR0033,40) + chr(10) + chr(13) )	// "Desconto no total do cupom"
			oCupom:AppendText(CHR(13)+CHR(10))				
			oCupom:AppendText( PadR(STR0034,40) + chr(10) + chr(13) )	// "Valor / Percentual"
			oCupom:AppendText( PadR(Trans(nValorDesc,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nPercDesc,"@E 99.99")+"%",40) + chr(10) + chr(13) )	// "Desconto no total do cupom : CANCELADO"
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:Refresh()

		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Frt060GrvNcc ³ Autor ³ Venda Clientes        ³ Data ³07/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os dados da NCC nas tabelas MDJ e MDK				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Dados do Cabecalho da Venda						     ³±±
±±³          ³ ExpA2 - Nccs selecionadas na venda						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060GrvNcc( aMDJ , aItensNcc , nOper )		

Local nX		:= 0												// Contador
Local aMDK		:= {}                                           	// Array com os itens da NCC
Local nPosDoc	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_DOC"	 })		// Posicao do campo de DOC
Local nPosSer	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_SERIE" }) 	// Posicao do campo Serie
Local nPosCli	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_CLIENT"})	// Posicao do campo Cliente
Local nPosLoj	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_LOJA"  })	// Posicao do campo Loja
Local nPosOper	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_OPER"  })	// Posicao do Campo Operacao 
Local nPosOrc	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_NUMORC" 	})	// Posicao do Campo Orcamento
Local lIntSiac	:= SuperGetMv("MV_SCINTEG", Nil, .F.)	//verifica se a integracao Protheus x SIAC esta ativa
Local lLjNCCOr	:= SuperGetMv("MV_LJNCCOR", Nil, .F.)	//verifica se a NCC sera mantida no orcamento (F4)

Local lR5        := GetRpoRelease("R5")								// Verifica Release 11.5 Ativo.

DEFAULT aMDJ 	 := {}                 				   				// Array com os dados dos titulo
DEFAULT aItensNcc:= Array(1)						  		 		// Itens da NCC
DEFAULT nOper	 := 1 				  								// Define a operacao 1-Baixa 2-Estorno 3-Inclusao

If AliasIndic("MDJ") .AND. AliasIndic("MDK")
	DbSelectArea("MDJ")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a integracao Protheus x SIAC estiver ativa,	ou se for mantida a NCC na     |
	// gravacao do orcamento,  verificamos se o orcamento esta                        |
	// ligado a uma NCC e se tiver nos o apagamos o criamos um novo registro.         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntSiac  .OR. lLjNCCOr
		MDJ->( DbSetOrder(3) )	//MDJ_FILIAL + MDJ_NUMORC
		If MDJ->(DbSeek(xFilial("MDJ") + aMDJ[nPosOrc][2]) )
			DbSelectArea("MDK")
			MDK->( DbSetOrder(2) ) //MDJ_FILIAL + MDJ_NUMORC
			If MDK->( DbSeek(MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC) )
				While MDK->( !Eof() ) .AND. ( MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC == MDK->MDK_FILIAL + MDK->MDK_NUMORC )
					// Deleta os Itens da NCC pendentes
					RecLock("MDK",.F.)
					MDK->( dbDelete() )
					MDK->( MsUnlock() )
					MDK->( dbSkip()	)
				End
			EndIf
			// deleta o titulo pendente
			RecLock("MDJ",.F.)
			MDJ->( dbDelete() )
			MDJ->( MsUnlock() )	
		EndIf			
		//Preenche os dados dos itens da NCC
		If nOper == 1
			FrtLdMDK(aMDK, aMDJ, aItensNCC)
		EndIf
	    // Grava o cabecalho da NCC que sera baixada automaticamente
		FR271BGeraSL("MDJ", aMDJ, .T.)
    Else
		MDJ->( DbSetOrder(1) )	//MDJ_FILIAL + MDJ_DOC + MDJ_SERIE + MDJ_CLIENT + MDJ_LOJA 
		If MDJ->( DbSeek(xFilial("MDJ")+aMDJ[nPosDoc][2]+aMDJ[nPosSer][2]+aMDJ[nPosCli][2]+aMDJ[nPosLoj][2]) )
			If MDJ->MDJ_OPER <> aMDJ[nPosOper][2] // Caso ja tenha um registro de tipo diferente exclui o mesmo
				// Procura os itens da NCC
				DbSelectArea("MDK")
				MDK->( DbSetOrder(1) )	//MDK_FILIAL + MDK_DOC + MDK_SERIE + MDK_CLIENTE + MDK_LOJA + MDK_SITUA
				If DbSeek(MDJ->MDJ_FILIAL + MDJ->MDJ_DOC + MDJ->MDJ_SERIE + MDJ->MDJ_CLIENT + MDJ->MDJ_LOJA)
					While MDK->( !EOF() ) .AND.(MDK->MDK_FILIAL+MDK->MDK_DOC+MDK->MDK_SERIE+MDK->MDK_CLIENTE+MDK->MDK_LOJA==;
											MDJ->MDJ_FILIAL+MDJ->MDJ_DOC+MDJ->MDJ_SERIE+MDJ->MDJ_CLIENTE+MDJ->MDJ_LOJA)				
						// Deleta os Itens da NCC pendentes 				
						RecLock("MDK",.F.)
						MDK->( dbDelete() )
						MDK->( MsUnlock() )
					End
					// deleta o titulo pendente
					RecLock("MDJ",.F.)
					MDJ->( dbDelete() )
					MDJ->( MsUnlock() )
				EndIf	
			EndIf	
		Else
			//Preenche os dados dos itens da NCC
			If nOper == 1
				FrtLdMDK(aMDK, aMDJ, aItensNCC)
			EndIf		
		    // Grava o cabecalho da NCC que sera baixada automaticamente
			FR271BGeraSL("MDJ", aMDJ, .T.)
		EndIf
	EndIf
EndIf

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtLdMDK	   ³ Autor ³ Venda Clientes        ³ Data ³16/03/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os dados da NCC nas tabelas MDJ e MDK				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Dados do Cabecalho da Venda						     ³±±
±±³          ³ ExpA2 - Nccs selecionadas na venda						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Frt060GrvNcc												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtLdMDK( aMDK,	aMDJ, aItensNCC )

Local nX := 0

Local nPosDoc	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_DOC"	  	})	// Posicao do campo de DOC
Local nPosSer	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_SERIE" 	}) 	// Posicao do campo Serie
Local nPosCli	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_CLIENT"	})	// Posicao do campo Cliente
Local nPosLoj	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_LOJA"  	})	// Posicao do campo Loja
Local nPosOrc	:= Ascan(aMDJ,{|x| Trim(x[1]) == "MDJ_NUMORC" 	})	// Posicao do Campo Orcamento
			For nX := 1 to Len(aItensNcc)
				If aItensNcc[nX][1]										// Verifica se a NCC foi utilizada na venda
					Aadd(aMDK,{"MDK_FILIAL"  	,xFilial("MDK")	   })
					Aadd(aMDK,{"MDK_DOC"  		,aMDJ[nPosDoc][2] })
					Aadd(aMDK,{"MDK_SERIE"  	,aMDJ[nPosSer][2] })
					Aadd(aMDK,{"MDK_CLIENT"  	,aMDJ[nPosCli][2] })	
					Aadd(aMDK,{"MDK_LOJA"  		,aMDJ[nPosLoj][2] })
					Aadd(aMDK,{"MDK_SALDO"  	,aItensNcc[nX][2] })
					Aadd(aMDK,{"MDK_TITULO"  	,aItensNcc[nX][3] })
					Aadd(aMDK,{"MDK_DTNCC"  	,aItensNcc[nX][4] })
					Aadd(aMDK,{"MDK_NUMREC"  	,aItensNcc[nX][5] })
					Aadd(aMDK,{"MDK_SALDO2"  	,aItensNcc[nX][6] })	
					Aadd(aMDK,{"MDK_MVMOED"  	,aItensNcc[nX][7] })
					Aadd(aMDK,{"MDK_MOEDA"  	,aItensNcc[nX][8] })
					Aadd(aMDK,{"MDK_PREFIX"  	,aItensNcc[nX][9] })
					Aadd(aMDK,{"MDK_PARCEL"  	,aItensNcc[nX][10]})										
					Aadd(aMDK,{"MDK_TIPO"  		,aItensNcc[nX][11]})										
			
        If MDK->(FieldPos("MDK_NUMORC")) > 0
        	Aadd(aMDK,{"MDK_NUMORC"	,aMDJ[nPosOrc][2]})
        EndIF
					FR271BGeraSL("MDK", aMDK, .T.)
				EndIf	
			Next nX		

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Frt060MDJok ³ Autor ³ Venda Clientes        ³ Data ³07/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o status do registro da MDJ      				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil        									                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt060MDJok(cL1Doc ,cL1Serie ,cL1Cliente,cL1Loja,cSitua)

Default cL1Doc		:=  ""
Default cL1Serie	:=  ""
Default cL1Cliente	:=  ""
Default cL1Loja		:=  ""
Default cSitua		:=  ""

If AliasIndic("MDJ") 	// Verifica se o Alias existe
	DbSelectArea("MDJ")
	DbSetOrder(1) 		//MDJ->MDJ_FILIAL + MDJ->MDJ_DOC + MDJ->MDJ_SERIE + MDJ->MDJ_CLIENT + MDJ->MDJ_LOJA
	If DbSeek(xFilial("MDJ")+cL1Doc +cL1Serie +cL1Cliente+cL1Loja)
		RecLock("MDJ",.F.)
		REPLACE MDJ_SITUA WITH cSitua
		MsUnlock()
	EndIf
EndIf

Return(NIL)


