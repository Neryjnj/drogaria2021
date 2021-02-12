#INCLUDE "MSOBJECT.CH"
 
User Function DRO001 ; Return  // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณDROConsultaAnvisaบAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em buscar informacoes na tabela LK9.			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class DROConsultaAnvisa From LJCColecao
		
	Method ConsAnvisa()									//Metodo construtor
	Method ConsDtTp(dDtInicio, dDtFinal, cTipo)        	//Metodo que ira efetuar a consulta por data e tipo
		
EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณConsAnvisa       บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe ConsultaAnvisa.					     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ConsAnvisa() Class DROConsultaAnvisa

	//Executa o metodo construtor da classe pai
	::Colecao()
	
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณConsDtTp         บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em efetuar a consulta por data e tipo.		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPD1 (1 - dDtInicio) - Data inicio da consulta.					 บฑฑ
ฑฑบ			 ณEXPD2 (2 - dDtFim) 	- Data final da consulta.					 บฑฑ
ฑฑบ			 ณEXPC1 (3 - cTipo) 	- Tipo da consulta.							 บฑฑ
ฑฑบ			 ณ							1 - Entrada.	   						 บฑฑ
ฑฑบ			 ณ							2 - Saida por venda.    				 บฑฑ
ฑฑบ			 ณ							3 - Saida por transferencia.	    	 บฑฑ
ฑฑบ			 ณ							4 - Saida por perda.			         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ      														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ConsDtTp(dDtInicio, dDtFinal, cTipo) Class DROConsultaAnvisa
    
	Local cQuery			:= ""	 					//Query da consulta
	Local nCont				:= 0	 					//Contador utilizado no retorno do PE DROXMLQ1
	Local aArea				:= {}						//Array para guardar a area
	Local oEntAnvisa		:= Nil						//Objeto do tipo Entidade Anvisa
	Local oInvAnvisa		:= Nil						//Objeto do tipo Entidade Anvisa Inventario	
	Local lExporta			:= .T.						//Controla se o registro sera exportado
	Local lDROXMLQ1			:= ExistBlock( "DROXMLQ1" )
	
	//Guarda a area corrente
	aArea := GetArea()
	
	If cTipo <> "5"   // Inventแrio
		//Monta a query
		cQuery := "SELECT"
		cQuery += " LK9_FILIAL , LK9_DATA	, LK9_DOC	, LK9_SERIE,"
		cQuery += " LK9_TIPMOV , LK9_CNPJFO	, LK9_DATANF, LK9_CNPJOR,"
		cQuery += " LK9_CNPJDE , LK9_NUMREC	, LK9_TIPREC, LK9_TIPUSO,"
		cQuery += " LK9_DATARE , LK9_NOMMED	, LK9_NUMPRO, LK9_CONPRO,"
		cQuery += " LK9_UFCONS , LK9_NOME	, LK9_TIPOID, LK9_NUMID,"
		cQuery += " LK9_ORGEXP , LK9_UFEMIS	, LK9_MTVPER, LK9_CODPRO,"
		cQuery += " LK9_DESCRI , LK9_UM		, LK9_LOTE	, LK9_QUANT,"
		cQuery += " LK9_REGMS  , LK9_SITUA  , LK9_NOMEP  ,LK9.D_E_L_E_T_, LK9.R_E_C_N_O_"
		cQuery += " ,LK9_CLASST"
		cQuery += " ,LK9_USOPRO"
		cQuery += " ,LK9_IDADEP"
		cQuery += " ,LK9_UNIDAP"
		cQuery += " ,LK9_SEXOPA"
		cQuery += " ,LK9_CIDPA"			
		cQuery += " FROM " + RetSqlName("LK9") + " LK9"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1"
		cQuery += " ON LK9.D_E_L_E_T_ = B1.D_E_L_E_T_"
		cQuery += " AND LK9.LK9_CODPRO = B1_COD"
		cQuery += " WHERE LK9_FILIAL = '" + xFilial("LK9") + "'"
		cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += " AND B1_CONSIST <> '2'"
		cQuery += " AND LK9_DATA BETWEEN '" + DTOS(dDtInicio) + "' AND '" + DTOS(dDtFinal) + "'"
		cQuery += " AND LK9_TIPMOV = '" + cTipo + "'"
		cQuery += " AND LK9_STATUS <> '1'"
		cQuery += " AND LK9.D_E_L_E_T_ <> '*'"
		
		cQuery := ChangeQuery(cQuery)
	    
	 	//Executa a query
	    dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMP_LK9", .T., .F. )
		
		//Seleciona a tabela
		dbSelectArea("TMP_LK9")
			
		While !EOF() 
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPonto de Entrada que filtra os produtos a serem exportadosณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock( "DROXML0001" )
				lExporta := ExecBlock( "DROXML0001", .F., .F., {TMP_LK9->LK9_CODPRO, TMP_LK9->LK9_REGMS, TMP_LK9->LK9_DESCRI} )
			EndIf
	
			If lExporta
				//Estancia o objeto EntidadeAnvisa
				oEntAnvisa := DROEntidadeAnvisa():EntAnvisa()
		        
		        //Atribui os valores retornados da query
		 		oEntAnvisa:cLK9_FILIAL 	:= TMP_LK9->LK9_FILIAL
				oEntAnvisa:cLK9_DATA	:= STOD(TMP_LK9->LK9_DATA)
				oEntAnvisa:cLK9_DOC		:= TMP_LK9->LK9_DOC
				oEntAnvisa:cLK9_SERIE	:= TMP_LK9->LK9_SERIE
				oEntAnvisa:cLK9_TIPMOV	:= TMP_LK9->LK9_TIPMOV
				oEntAnvisa:cLK9_CNPJFO	:= TMP_LK9->LK9_CNPJFO
				oEntAnvisa:cLK9_DATANF	:= STOD(TMP_LK9->LK9_DATANF)
				oEntAnvisa:cLK9_CNPJOR	:= TMP_LK9->LK9_CNPJOR
				oEntAnvisa:cLK9_CNPJDE	:= TMP_LK9->LK9_CNPJDE
				oEntAnvisa:cLK9_NUMREC	:= TMP_LK9->LK9_NUMREC
				oEntAnvisa:cLK9_TIPREC	:= TMP_LK9->LK9_TIPREC
				oEntAnvisa:cLK9_TIPUSO	:= TMP_LK9->LK9_TIPUSO 	
				oEntAnvisa:cLK9_DATARE	:= STOD(TMP_LK9->LK9_DATARE)
				oEntAnvisa:cLK9_NOMMED	:= TMP_LK9->LK9_NOMMED
				oEntAnvisa:cLK9_NUMPRO	:= TMP_LK9->LK9_NUMPRO
				oEntAnvisa:cLK9_CONPRO	:= TMP_LK9->LK9_CONPRO
				oEntAnvisa:cLK9_UFCONS	:= TMP_LK9->LK9_UFCONS
				oEntAnvisa:cLK9_NOME	:= TMP_LK9->LK9_NOME
				oEntAnvisa:cLK9_TIPOID	:= TMP_LK9->LK9_TIPOID
				oEntAnvisa:cLK9_NUMID	:= TMP_LK9->LK9_NUMID
				oEntAnvisa:cLK9_ORGEXP	:= TMP_LK9->LK9_ORGEXP
				oEntAnvisa:cLK9_UFEMIS	:= TMP_LK9->LK9_UFEMIS
				oEntAnvisa:cLK9_MTVPER	:= TMP_LK9->LK9_MTVPER
				oEntAnvisa:cLK9_CODPRO	:= TMP_LK9->LK9_CODPRO
				oEntAnvisa:cLK9_DESCRI	:= TMP_LK9->LK9_DESCRI
				oEntAnvisa:cLK9_UM		:= TMP_LK9->LK9_UM
				oEntAnvisa:cLK9_LOTE	:= TMP_LK9->LK9_LOTE
				oEntAnvisa:nLK9_QUANT	:= TMP_LK9->LK9_QUANT
				oEntAnvisa:cLK9_REGMS	:= TMP_LK9->LK9_REGMS
				oEntAnvisa:cLK9_SITUA	:= TMP_LK9->LK9_SITUA
				oEntAnvisa:cLK9_NOMEP	:= TMP_LK9->LK9_NOMEP	
				oEntAnvisa:cLK9_CLASST	:= TMP_LK9->LK9_CLASST
				
				// Guia SNGPC V2.0 regra 4.1.4 , Item 8
				If oEntAnvisa:cLK9_CLASST == '1'
					oEntAnvisa:cLK9_USOPRO := TMP_LK9->LK9_USOPRO
				Else
					oEntAnvisa:cLK9_USOPRO := ""
				EndIf
				
				oEntAnvisa:nLK9_IDADEP := TMP_LK9->LK9_IDADEP
				oEntAnvisa:cLK9_UNIDAP := TMP_LK9->LK9_UNIDAP
				oEntAnvisa:cLK9_SEXOPA := TMP_LK9->LK9_SEXOPA
				oEntAnvisa:cLK9_CIDPA  := TMP_LK9->LK9_CIDPA
				oEntAnvisa:nR_E_C_N_O_ := TMP_LK9->R_E_C_N_O_
		        
		        //Adiciona na colecao
		    	::Add(oEntAnvisa:nR_E_C_N_O_, oEntAnvisa)
			EndIf
	    	
	    	//Proximo registro
	    	DbSkip()
		End
	 
	    //Fecha a tabela
		dbCloseArea()

	Else  // Inventario
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPonto de Entrada que busca Informacoes personalizado do  cliente ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lDROXMLQ1  
			aRet	:= ExecBlock( "DROXMLQ1", .F., .F.,{} )
			If Len(aRet) > 0  
				For nCont := 1 to Len (aRet)
					//Estancia o objeto EntidadeAnvisa
					oInvAnvisa := DROEntidadeAnvisaInv():InvAnvisa()
			        
			        //Atribui os valores retornados da query
			 		oInvAnvisa:cB1_FILIAL 	:= aRet[nCont][1] //FILIAL
					oInvAnvisa:cB1_CLASSTE	:= aRet[nCont][2] //CLASSTE
					oInvAnvisa:cB1_REGMS	:= aRet[nCont][3] //REGMS
					oInvAnvisa:cLOTE		:= aRet[nCont][4] //LOTE
					oInvAnvisa:cB1_UM		:= aRet[nCont][5] //UM
					oInvAnvisa:nB2_QATU		:= aRet[nCont][6] //QTD
					oInvAnvisa:nR_E_C_N_O_	:= aRet[nCont][7] //R_E_C_N_O_
				        
			        //Adiciona na colecao
			    	::Add(oInvAnvisa:nR_E_C_N_O_, oInvAnvisa)
		    	
		    	//Proximo registro
				Next 
			EndIf
		Else

			//Monta a query
			cQuery := "SELECT"
			cQuery += " B1_FILIAL FILIAL,"
			cQuery += " B1_COD COD,"
			cQuery += " B1_CLASSTE CLASSTE,"
			cQuery += " B1_REGMS REGMS,"
			cQuery += " B1_UM UM,"
			cQuery += " '1' LOTE,"
			cQuery += " B2_QATU QTD,"
			cQuery += " SB1.R_E_C_N_O_"
			cQuery += " FROM " +  RetSqlName("SB1") + " SB1"
			cQuery += " LEFT JOIN " + RetSqlName("SB2") + " SB2"
			cQuery += " ON SB1.D_E_L_E_T_ = SB2.D_E_L_E_T_"
			cQuery += " AND B2_COD = B1_COD"
			cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
			cQuery += " AND B2_FILIAL = '" + xFilial("SB2") + "'"
			cQuery += " AND (B1_PSICOTR = '1' OR B1_CLASSTE IN ('1','2'))"
			cQuery += " AND SB1.D_E_L_E_T_ <> '*'"
	
			cQuery := ChangeQuery(cQuery)
		    
		 	//Executa a query
		    dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMP_SB1", .T., .F. )
			
			//Seleciona a tabela
			dbSelectArea("TMP_SB1")
				
			While TMP_SB1->(!EOF()) 
				  
				//Estancia o objeto EntidadeAnvisa
				oInvAnvisa := DROEntidadeAnvisaInv():InvAnvisa()
		        
		        //Atribui os valores retornados da query
		 		oInvAnvisa:cB1_FILIAL 	:= TMP_SB1->FILIAL
				oInvAnvisa:cB1_CLASSTE	:= TMP_SB1->CLASSTE
				oInvAnvisa:cB1_REGMS	:= TMP_SB1->REGMS
				oInvAnvisa:cLOTE		:= TMP_SB1->LOTE
				oInvAnvisa:cB1_UM		:= TMP_SB1->UM
				oInvAnvisa:nB2_QATU		:= TMP_SB1->QTD		
				oInvAnvisa:nR_E_C_N_O_	:= TMP_SB1->R_E_C_N_O_
			        
		        //Adiciona na colecao
		    	::Add(oInvAnvisa:nR_E_C_N_O_, oInvAnvisa)
	    	
		    	//Proximo registro
		    	TMP_SB1->(DbSkip())
			End
		 
		    //Fecha a tabela
			dbCloseArea()
		EndIf
	Endif
	//Restaura a area
	RestArea(aArea)
 
Return Nil
