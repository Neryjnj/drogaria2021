#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FRTA271A.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"
 		
#DEFINE	 FRT_SEPARATOR		"---------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				1
#DEFINE AIT_COD			 	    2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM				7
#DEFINE AIT_VALDESC		   		8
#DEFINE AIT_ALIQUOTA			9          
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          		// Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM
#DEFINE AIT_IMPINCL            16                  // Verifica se o imposto esta incluido no valor do item

#DEFINE _FORMATEF				"CC;CD"				//Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  	//Pula linha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DIFINES criados pelo equipe de Templates³
//³Usado no Template de Drogaria.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE VDLNK_CABEC_CODCLI	 1
#DEFINE VDLNK_CABEC_LOJA	 2
#DEFINE VDLNK_INDICEPRODU	 1
#DEFINE VDLNK_CODIGOEAN  	 2
#DEFINE VDLNK_QUANTIDADE 	 3
#DEFINE VDLNK_PRECO      	 4
#DEFINE VDLNK_AUTORIZACAO   1
#DEFINE VDLNK_DETALHE    	 2
#DEFINE VDLNK_TOTALVENDA   	 3



Static cGetCliDir      // Guarda o caminho do rootPath
Static cProfStr1       // Guarda o Retorno da Funcao GetPvProfString
Static lImpCpfNpj	:= .F.
Static lCenVenda	:= SuperGetMv("MV_LJCNVDA",,.F.)		// Indica se usa integracao com cenario de vendas
Static oMultNegoc 	:= Nil								// Obrjeto de Multi negciaçã

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static lProcFidWs	:= .F.					// Indica se os movimentos do cartao fidelidade serao processados via webservice.
Static lRecFid		:= .F.					// Indica se esta sendo realizada a recarga de cartao fidelidade
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Garantia Estendida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aGarant  	:= {}                   // Variavel guarda informaçoes sobre o produto Garantia.
Static aProdGar		:= {}                   // Variável para identificação do produto Garantia no fonte FRTA271B no momento da impressão

Static aItensServ	:= {}                   // Variavel para identificacao dos Itens de Servico no fonte FRTA271G
Static aConnTopRet	:= {}					// Variavel para armazenar dados da conexao do TOP da Retaguarda
Static lFecConfCx	:= .F.
/*Release 11.5 - Controle de Formularios 
  Paises:Chile/Colombia - F1CHI		 */
Static nRecnoFo		:= 0					//Recno do Controle de Formulario selecionado pelo usuario atraves da especie de documento fiscal
Static lCFolLocR5	:= 	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. IIf(ValType(lFiscal) == "U",.F.,!lFiscal)
//-------------
//Vale Presente
//-------------
Static aItensVP	:= {}                   // Variavel para identificacao dos Itens de Vale Presente no fonte FRTA271G

Static lEmitNFCe:= LjEmitNFCe()	//Indica a utilizacao da NFC-e
Static lLjGrvLog:= ExistFunc("LjGrvLog")
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271AProdOK³Autor³ Vendas Clientes       ³ Data ³14/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³ Executa a Validacao do Produto e Registra o Item			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/     
Function FR271AProdOK(	xOrc		, nNumItem		, cChkProduto	, lF3			,; 
						cCodProd	, oTimer		, oHora			, cHora			,;
						oDoc		, cDoc			, oPDV			, cPDV			,; 		
						nLastTotal	, nVlrTotal		, nLastItem		, nTotItens		,;
						nVlrBruto	, oVlrTotal		, oCupom		, oTotItens		,;
						oOnOffLine	, nTmpQuant		, nVlrItem		, nValIPIIT		,;
						nValIPI		, oFotoProd		, oProduto		, oQuant		,;
						oVlrUnit	, oVlrItem		, oDesconto		, cSimbCor		,;
						cOrcam		, cProduto		, nQuant		, cUnidade		,;	
						nVlrUnit	, oUnidade		, lF7   		, cQtd			,;
						cCliente	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe		, lLocked		, lCXAberto		, lDescIT		,;
						nVlrDescTot	, aItens		, aICMS			, nVlrMerc		,;
						_aMult		, _aMultCanc	, lOrc			, aParcOrc		,;
						cItemCOrc	, aParcOrcOld	, lAltVend		, lImpNewIT		,;
						lFechaCup	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd		, aTEFPend	   	, aBckTEFMult	,cCodConv		,;
						cLojConv	, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal	, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
						nVidaLink	, nValTPis		, nValTCof		, nValTCsl		,;
						lVerTEFPend	, nTotDedIcms	, lImpOrc 		, nVlrPercTot	,;
						nVlrPercAcr	, nVlrAcreTot	, nVlrDescCPg	, nQtdeItOri	,;
						aMoeda		, aSimbs		, nMoedaCor		, nDecimais		,;
						aImpsSL1	, aImpsSL2		, aImpsProd		, aImpVarDup	,;
						aTotVen		, aCols			, nVlrPercIT	, nTaxaMoeda  	,;
						aHeader		, nVlrDescIT	, oMensagem		, oFntMoeda		,;
						cMensagem	, cTipoCli		, lBscPrdON		, nConTcLnk		,;
						cEntrega  	, aReserva 		, lReserva		, lAbreCup		,;
						nValor		, cCupom        , cVndLjAlt 	, cCliCGC		,;
						aRegTEF		, lRecarEfet	, lDescITReg	, cGarant		,;
						cNSerie		, cDocFo		, aMostruario	, lLegOk		,;
						nDescOrc	, cVendido 		, lItemImp		, cGarant		,;
						cNSerie		, nVlgApro		, lItemRegEcf	, lErRegItem	,;
						lNewImpOrc, aItensInvalid	, cGrpTrib)  

Local lRet         	:= .F.
Local nRet        
Local cRet         	:= ""
Local lFoco        	:= .F.
Local cAliquota
Local cAliqAux	   	:= ""
Local cTES
Local cCF
Local cQuant
Local cVlrUnit
Local cVlrItem
Local nDec
Local aSL1
Local aSL2
Local cFRTCodB
Local aTmpProd
Local nMaxElem     	:= 1
Local nX
Local nI
Local nE        
Local nY
Local cIndImp 
Local cCampoVal    	:= ""
Local cCampoAlq    	:= ""
Local aImps        	:= {}
Local aImposto     	:= {}
Local nValImp      	:= 0
Local nTotImp      	:= 0          
Local cLocal     
Local cTabela
Local lLeitor      	:= .F.
Local nMoedaTab    	:= 1 						//Moeda da tabela de preco - Localizacoes
Local nDecPDesc    	:= TAMSX3("L2_DESC")[2] 		//Qtde de casas decimais do % de Desconto 
Local nTent 	   	:= 0
Local nPercITOld
Local nDescITOld
Local nVlIcmRet    	:= 0 						//Valor do ICM Retido para ser somado junto ao item
Local cVlIcmRet    	:= 0 						//Valor do ICM Retido para ser impresso no cupom fiscal 
Local nSaveSx8 	  	:= GetSx8Len()
Local lStatusImp13 	:= .F.						// Status 13 do ECF. Indica se o ECF arredonda (.T.) ou trunca (.F.) o valor total
Local aFRTKit	   	:= {}						// P.E. FRTKIT - Para Registrar Varios Produtos de uma vez (KIT)
Local nTamSXG      	:= 0
Local nTamItem     	:= 0         				//Tamanho do campo de item  
Local lConsulta    	:= .T.
Local lFRTProdOKt  	:= ExistTemplate("FRTProdOK")// verifica se existe o PONTO DE ENTRADA FRTProdOK
Local lFRTKITt	   	:= ExistTemplate("FRTKIT")	 // verifica se existe o PONTO DE ENTRADA FRTKIT
Local lFRTDescITt  	:= ExistTemplate("FrtDescIT")// verifica se existe o PONTO DE ENTRADA FRTDescIT
Local lFRTCODB2t   	:= ExistTemplate("FRTCODB2") // verifica se existe o PONTO DE ENTRADA FRTCODB2
Local lFRTCODB3t   	:= ExistTemplate("FRTCODB3") // verifica se existe o PONTO DE ENTRADA FRTCODB3
Local nDedIcmsIt   	:= 0                         // Valor da deducao do ICMS de um item da venda
Local nTB1COD	   	:= TamSX3("BI_COD")[1]		 // Tamanho do campo B1_COD
Local nTB1CODBAR   	:= TamSX3("BI_CODBAR")[1]	 // Tamanho do campo B1_CODBAR
Local cFotoProd		
Local lEntra		:= .T.	   					// Verifica se entra no alerta para aliquota nao cadastrada
Local nValPis		:= 0						// Valor do PIS por item
Local nValCof		:= 0						// Valor do COFINS por item
Local nValCsl		:= 0						// Valor do CSLL por item
Local nBasePS2		:= 0						// Valor da Base do PIS
Local nValPS2		:= 0						// Valor do PIS
Local nAliqPS2		:= 0						// Aliquota do PIS
Local nBaseCF2		:= 0						// Valor da Base do Cofins
Local nValCF2		:= 0						// Valor do Cofins
Local nAliqCF2		:= 0						// Aliquota do Cofins
Local lIsPrdServ 	:= .F. 						// Identifica se o produto eh um servico
Local lFunTesISS  	:= ExistFunc("LjIsTesISS")
Local cCodBar		:= ""						//Codigo de barras
Local cBCONTA		:= ""
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nTamA3_COD    := TamSX3("A3_COD")[1] 		// Tamanho do campo A3_COD
Local cContDoc      := ""                       // Contador de Cupom Fiscal 
Local lExLegSP10	:= ExistFunc("Lj950SP10OK")			// Verifica a existencia da funcao que valida a legislacao paulista que limita o cupom fiscal em 10.000,00
Local lGE          	:= ExistFunc("LjUP104OK") .AND. LjUP104ok(.T.)     			    // Validação do Conceito Garantia Estendida 
Local lCup 			:= .T.						// se conseguiu pegar o numero do cupom da impressora                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A variavel criada abaixo contem o codigo original do produto, e sera usada       ³
//³para verificar se o produto esta no padrao EAN-13. Foi criada como Private para  ³
//³tornar possivel o seu uso nos seguintes P.E.: FRTProdOK,FRTCODB1,FRTKIT,			³
//³FRTQUANT,FRTECF13,FR271EDescIT,FRTCLICHE,FRTCODB2 e FRTCODB3                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodProIni	:= cCodProd
Local cInfProBal	:= SubStr(cCodProd,8,5)
Local cFormDesc  	:= SuperGetMV("MV_LJFORMD",.F.,"1" )	// Tipo de validacao do desconto (valor ou % / valor e %)
Local aDesc			:= {}									// Controle de descontos aplicados ao item para validacao
Local nPerDesc		:= 0									// Percentual de desconto (utilizado somente para validar desconto)
Local aSavArea		:= {}									// Salvando a area
Local cReserva 		:= ""									// Codigo da reserva
Local cLojaRes 		:= ""									// Loja da reserva
Local cNumOrc		:= ""									// Numero do orcamento
Local lFR271AFotPrd	:= ExistBlock("FR271AFotPrd")			// Verifica se o ponto de entrada esta' compilado	
Local c271AFotPrd   := ""								    // Retorno do ponto de entrada
Local cTesInt	    := ""									// Codigo do Tes de saida
Local cProdLocal   	:= ""									// Armazena o codigo de barras ou codigo do produto
Local cMvCodBar	   	:= SuperGetMv("MV_CODBAR",,"N")			// Variavel com parametro para impressao do codigo de barras no cupom
Local cDigQtde		:= Alltrim(SuperGetMV("MV_FRTDIGQ",,""))// Digito separador de quantidade x produto
Local cNumLoc		:= ""		                            // Recebe o conteudo do campo L2_LOCALIZ
Local lItemPbm		:= .F.							   		// Define se o item pertence a PBM
Local cValePre		:= ""									// Numero do vale presente vendido
Local nW			:= 0									// Contador
Local lAbrirCupom   := .F.									// Define se o cupom foi aberto
Local aFrtExcecao	:= {}                               	// Tratamento para Excecao Fiscal do Cliente
Local lExcecaoFcl	:= .F.
Local cDocBkp		:= ""									// Backup do Numero do Documento 
Local nTamSX3		:= 0									// Tamanho do SX3
Local cMVLJPREC		:= SuperGetMv("MV_LJPREC", ,"" )  		// Parametro com o codigo do produto tipo recarga.
Local lCpoRedes		:= .F.                              	// Verifica se o campo LG_REDES esta configurado para recarga de celular
Local cLGRedes		:= ""                               	// Conteudo do campo LG_REDES
Local nRegDesc		:= 0									// Desconto proveniente da regra de descontos
Local nDescItAnt	:= 0									// Percentual do desconto no item antes de aplicar a regra
Local lTemDscRrg	:= .F.									// Indica se houve desconto por regra
Local lBonus		:= IsInCallStack("FRT271EREGDSC")		// Indica que se trata de um produto bonificado  
Local nItem         := 0                                    // Transforma o Numero Item Para 2 Bytes.  
Local nCodANVISA	:= 0	        						// ID de Identificacao de produto controlado. (ANVISA)
Local lImpIncl      := .T.                                  // Verifica se exixte imposto incluido no valor do item 
Local lCAT83 		:= SF4->(ColumnPos("F4_CODLAN")) > 0 .AND. SL2->(ColumnPos("L2_CODLAN")) > 0 .AND. ExistFunc("FISA023") .AND. SuperGetMV("MV_CAT8309",,.F.) // Verifica CAT/83 
Local lImpDesc	 	:= SuperGetMv("MV_LJIPDES",,.F.)		// Define o tratamento para desconto na importacao do orçamento
Local nVlProp 		:= 0                                    // Valor Proporcional do desconto no total do orcamento que sera aplicado no item
Local nDifImp		:= 0									// Diferenca entre o desconto que foi rateado e o valor total
Local lUsaFecha		:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
Local cTransNat		:= SuperGetMV("MV_LJTRNAT",.F.,"")		//Natureza financeira da transferencia
Local lUsaTransf	:= SuperGetMV("MV_LJTRANS",.T.,.F.) .AND. !Empty(cTransNat)
Local lAtivaMn		:= SuperGetMV("MV_LJMULTN", , .F.) 		// Ativa cenario de Vendas 
Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE")       // Define se o Produto é GE
Local lImpGECnf     := .F.                                  // Imprime Garantia Estendida no Cupom Nao Fiscal - Front Loja.
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)				// Sinaliza Ambiente PAF-ECF
/*Release 11.5 - Cartao Fidelidade*/
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.)	.AND. CrdxInt()			//Indica se a recarga de cartao fidelidade esta ativa

//³Release 11.5 - Controle de Formularios 			   ³
//³Paises:Chile/Colombia - F1CHI	   			       ³
Local cSerieAux		:= ""									//Numero da serie direto do cadastrato de estacao
Local cSerieFo		:= ""									//Serie do documento fiscal informado pelo usuario no inicio da venda via controle de formularios.
Local cSigEspFo		:= ""									//Especie de documento fiscal selecionado pelo usuario no inicio da venda.
Local aNumPed		:= {}                          			//Array de documentos retornados pela funcao LjxDNota
Local lEscFo		:= .F.                                 //Indica se o usuario abortou a tela de Selecao de especie de controle de formularios - Controle de Formularios
Local aBreakNota	:= {}									//Notas geradas a partir da venda quando o numero de itens de venda exceder o limite - Release 11.5 - Localizacao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a funcionalidade Lista de Presente esta ativa e aplicada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaLstPre	:= SuperGetMV("MV_LJLSPRE",,.F.) .And. IIf(ExistFunc("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local cTpOper		:= SuperGetMV("MV_LJLPTIV",,"")			//Tipo da Operacao para o Pedido de Venda (TES Inteligente)
Local lMcrTpOper   	:= Substr(cTpOper,1, 1) == "&"          //Controla se pode macro-executar o parametro MV_LJLPTIV
Local cTESLstPre	:= SuperGetMV("MV_LJLPTSV",,"")			//TES padrao para o Pedido de Venda - Lista de Presentes
Local aAux2 		:= {}
Local nVlrItSDesc   := 0                                    //Valor do item sem considerar o desconto
Local xRet  												//Retorno do parametro MV_LJLPTIV, se for macro-executado
Local nCont         := 0                                    //Contador de For
Local lPrioPBM		:= SuperGetMV("MV_PRIOPBM" , .F., .T.) 	//Priorizacao da venda por PBM
Local nVlrFrete     := 0                                    //Valor de Frete(L1_FRETE)
Local nVlrSeguro    := 0                                    //Valor do seguro(L1_SEGURO)
Local nVlrDespesa   := 0                                    //Valor da despesa(L1_DESPESA)
Local nTotalOrc     := 0                                    //Valor total do orcamento(L1_VLRTOT) 
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 	//Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local nAliquota		:= 0
Local nVlrImpNCM	:= 0 											// usada para calculo do Imposto NCM/NBS lei 12741/2012
Local lCpoTotImp  	:=	SBI->(ColumnPos("BI_IMPNCM")) > 0
Local lPosIpi	  	:=	SBI->(ColumnPos("BI_POSIPI")) > 0
Local lCgcCli		:=  SL1->(ColumnPos("L1_CGCCLI")) > 0					
Local lBuscaImp		:=  ExistFunc("lj7BuscaImp")
Local dDtValid		:= ""
Local aRetDtBar		:= {}
Local nVlrTotRe		:= 0								// Valor total de venda com reserva
Local lGeRes		:= .F.								// Verifica se item eh garantia 
Local cItemGar		:= ""
Local cLote			:= ""								// Codigo do Lote do Produto
Local cSubLote	 	:= ""								// Codigo do SubLote do Produto
Local dVldLote		:= CtoD("  /  /  ")					// Data de Validade do Lote
Local cChvFecha		:= ""
Local cNumMov		:= ""
Local aID			:= {}
Local lVPNewRegra 	:= ExistFunc("Lj7VPNew") .And. Lj7VPNew() //Verifica se utiliza as novas modificacoes da implementacao de Vale Presente, para imprimir o comprovante nao fiscal na venda de vale presente.
Local lL2Origem		:= IIF( (lEmitNfce .Or. lLjNfPafEcf) .AND. SL2->(ColumnPos("L2_ORIGEM")) > 0 .And. SBI->(ColumnPos( "BI_ORIGEM")) > 0, .T.,.F.)	//Verifica se possui campo para armazenar B1_Origem, utilizado para otimizar processo da NFCe
Local lL2Modbc		:= IIF( lEmitNfce .AND. SL2->(ColumnPos("L2_MODBC")) > 0, .T., .F.)	//Verifica se possui campo utilizado para otimizar processo da NFCe
Local lL2CEST		:= IIF( (lEmitNFCe .Or. lLjNfPafEcf) .AND. SBI->(ColumnPos("BI_CEST")) > 0 .AND. SL2->(ColumnPos("L2_CEST")) > 0, .T., .F.)
Local lL2CodBar		:= SL2->(ColumnPos("L2_CODBAR")) > 0
Local aModBc		:= {}
Local cModBC		:= ""
Local nValICMS		:= 0
Local nBaseICMS		:= 0
Local nBRICMS		:= 0

Local xB1ImpNcm		:= Nil								// variavel que controla o retorno da função AlqLei2741
Local lAlqLei2741	:=  ExistFunc("AlqLei2741")			// Funcao desenvolvida pelo fiscal para tratar a lei dos impostos 	
Local cMvFisCTrb	:= SuperGetMV("MV_FISCTRB",,"1")	// Informar metodo de consulta do percentual de carga tributaria.Informe 1 para tratamento legado ou 2 aliquotas da Nota Fiscal e CGA/CGB.                 
Local cMvFisAlCT	:= SuperGetMV("MV_FISALCT",,"3")	// Informar qual o metodo de composicao da carga tributaria quando MV_FISCTRB = 2.                      
Local lMvFisFRas	:= SuperGetMV("MV_FISFRAS",,"T")	// Indica se utilizara a rastreabilidade no faturamento para preenchimento dos campos                    
Local aAlqLeiTr		:= {}								// array com valores da  aliquota retornado pela função fiscal (Lei transparência) 1-Aliq Total|2-Aliq Federal|3-Aliq Estadual|4-Aliq Municipal
Local lL2TotImp    	:= SL2->(ColumnPos("L2_TOTIMP")) > 0 // Verifica a existencia do campo de Total de Imposto
Local lCpoImpEnt 	:=	SL2->(ColumnPos("L2_TOTFED")) > 0 .AND. ;
						SL2->(ColumnPos("L2_TOTEST")) > 0 .AND. ;
						SL2->(ColumnPos("L2_TOTMUN")) > 0 // Verifica a existencia do campo de Total de Imposto NCM/NBS
Local lBi_ex_ncm	:= 	SBI->(ColumnPos("BI_EX_NCM")) > 0 // Extensao de codigo ncm
Local lUseSat		:=	LjUseSat()						  //Verifica se usa o SAT
Local lVerBloq 		:=  .T.   							// Verifica se o produto está bloquedo ou nao no cadastro (campo B1_MSBLQL)
Local aSATTrib		:=	IIF(ExistFunc("LjGetTriSat"),LjGetTriSat(),{})		//Tributação produto SAT
Local cAppend		:= "" 
Local cCEST			:= ""
Local cBAKDesPro	:= ""
Local lTentaNov		:= .T.
Local lL2ValISS		:= SL2->(ColumnPos("L2_VALISS")) > 0
Local lL2CmpISS		:= SL2->(ColumnPos("L2_BASEISS")) > 0 .AND. SL2->(ColumnPos("L2_ALIQISS")) > 0 .AND. SL2->(ColumnPos("L2_CODISS")) > 0
Local lL2CNAE		:= SL2->(ColumnPos("L2_CNAE")) > 0	//verifica existencia do campo CNAE [usado para NFC-e com Serviço(Nota Fácil Manaus)]
Local aISSQN		:= Array(5)	//[1]Codigo ISS / [2]Base / [3]Aliquota / [4]Valor	/ [5]CNAE
Local lLj7Arred		:= ExistFunc("Lj7Arred")
Local cTpOrc		:= "" //Tipo do orçamento
Local lF4MKPSOL 	:= SF4->(ColumnPos("F4_MKPSOL")) > 0
Local lMargSol		:= .T.									// Valida se aplica ou não a Margem Solidaria
Local nVlrUnitAnt	:= 0									// Valor Unitário para Vale Presente
Local lHora			:= .T.
Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)
Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
Local nValFECP		:= 0
Local nAlqFECP 		:= 0
Local nValFECPST    := 0
Local nAlqFECPST    := 0
Local lICMDeson     := SL2->(ColumnPos( "L2_DESCICM" )) > 0 .And. SL2->(ColumnPos( "L2_MOTDICM" )) > 0
Local nAux          := 0
Local cMOTDICM		:= ""   //Motivo da desoneração
Local nDESCICM		:= 0   //Valor da desoneração 
Local nAuxVlrI      := 0   //Variavel auxiliar para guardar o valor do Item
Local nAuxVlrU      := 0   //Variavel auxiliar para guardar o valor Unitario


DEFAULT cChkProduto := ""
DEFAULT lF3         := .F. 								//Se o produto foi inserido via F3, obtenho a variavel True para o
														//controle da condicao de pagamento negociada abaixo (caso de orcamento)
DEFAULT lF7			:= .F. 								// Controle da tecla F7
DEFAULT cQtd 		:= "1"            					// Quantidade
DEFAULT nTaxaMoeda 	:= 1              					// Valor da taxa da moeda
DEFAULT nVlrDescIT	:= 0								// Valor de deconto no item 
DEFAULT aHeader     := {}								// Array de Cabecalho
DEFAULT	cTipoCli	:= ""								// Tipo Fiscal do Cliente
DEFAULT	lBscPrdON	:= SuperGetMV("MV_LJPRDON", ,.F.)	// Identifica se o Front irá se conectar com a Retaguarda
DEFAULT	nConTcLnk   := 0								// Controle do TcLink
DEFAULT	cEntrega    := ""								// Tipo de Entrega
DEFAULT	aReserva    := {}								// Contem os itens de reserva
DEFAULT	lReserva    := .F.								// Indica se a venda possui itens do tipo Reserva
DEFAULT	lAbreCup	:= .F.								// Indica se abre cupom
DEFAULT	nValor		:= 0   								// Valor Total
DEFAULT cVndLjAlt	:= ""                               // Vendedor Alterado
DEFAULT cCliCGC		:= ""								// CGC do cliente
DEFAULT cGrpTrib	:= ""								// SitTrib
DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT aItens		:= {} 	
DEFAULT lFechaCup   := .T. 	 
DEFAULT nNumItem 	:= 0  	 
DEFAULT nMoedaCor   := 1								// Moeda Corrente
DEFAULT nDecimais   := MsDecimais(nMoedaCor)
DEFAULT	nVlrMerc 	:= 0
DEFAULT	nVlrUnit	:= 0
DEFAULT nQuant  	:= 0
DEFAULT lDescITReg  := .F.
DEFAULT cGarant     := ""   
DEFAULT cNSerie     := ""
DEFAULT cDocFo		:= ""
DEFAULT aMostruario := {"N",""} 					//Indicador de item finalizadao como MOSTRUARIO (mostruario ou saldao)
DEFAULT cVendido	:= ""							// Quando "N" sinaliza item que deve ser cancelado no ECF
DEFAULT lItemImp	:= .F.							// Indica se o item pertence a um orcamento importado
DEFAULT cGarant     := ""                           // Produto Garantia Estendida
DEFAULT cNSerie     := ""                           // Número de Seríe
DEFAULT	nVlgApro	:= 0
DEFAULT	lItemRegEcf := .F.							// Controle de registro de item no ECF
DEFAULT lLegOK		:= .F.							// Indica se a legislacao paulista que limita em 10.000,00 o CF esta de acordo.
DEFAULT nDescOrc	:= 0							// Desconto no total que foi importado do orçamento.
DEFAULT lErRegItem	:= .F.
Default lNewImpOrc	:= .F.						//Se é outro orçamento importado (para mais de um orçamento importado)
Default aItensInvalid := {} 

If ValType(aMostruario[1]) <> "C" .Or. ValType(aMostruario[2]) <> "C"
	aMostruario := {"N",""}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa variavel, pois vinha suja na ultima importacao de ³
//³pedido                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEntrega := IIF(ProcName(1) == "FR271LISTA",cEntrega,"")
If lRecebe
	Return(NIL)
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o caixa nao estiver aberto nao permite utilizar tecla de funcao F9³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCxAberto
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + STR0068)         //"O Caixa não está aberto.
	EndIf
	HELP("",1,'FRT029')
	Return(Nil)
Endif


//+----------------------------------+
//¦Verifica se o caixa ja esta aberto¦
//+----------------------------------+
FR271ICxFecha(@lCXAberto,,@lHora) 

If ! CheckCaixa(@lCXAberto, @lUsaDisplay,,, @lHora )							// Verifica se o Caixa Esta Aberto
	Return(.T.)								// E exibe Mensagem Caso Esteja Fechado
EndIf

//Não permiti venda de serviço com o SAT ativo
If lUseSat

	SBI->(dbSetorder(1))
	SBI->(dbSeek(xFilial("SBI")+cCodProd))

	If !Empty(SBI->BI_TS)
		
		SF4->(dbSetorder(1))
		SF4->(dbSeek(xFilial("SF4")+SBI->BI_TS))
		
		If SF4->F4_ISS == "S"
			MsgAlert("Não é possível fazer uma venda de serviço utilizando o "+cSiglaSat+" no PDV. Por favor realize a venda na Retaguarada.")
			Return(Nil)
		EndIf		
		
	EndIf

EndIf	


If lUsaFecha .And. !lFecConfCx 
	cChvFecha := ExConfAbLW(2)
	If Empty(cChvFecha)
		aID := LjInfoCxAt()		//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
		cNumMov := AllTrim(LjNumMov())		

		//Caso nao exista numero de movimento
		If Empty(cNumMov)
			cChvFecha := LjUltMovAb(2,aID[1],,,,.T.)
		Else
			cChvFecha := LjUltMovAb(1,aID[1],aID[4],aID[2],cNumMov,.T.)
		Endif
		
		If !Empty(cChvFecha)
			//Ao pesquisar localmente, verificar se a conferencia nao foi feita na retaguarda. Caso tenha sido feita, desconsiderar a chave e atualizar
			If LjRetSitLW(cChvFecha,.T.) == "02"
				cChvFecha := ""
			Endif
		EndIf
	EndIf

	If !Empty(cChvFecha) .And. !ConfCxFecha(cChvFecha)
		lFecConfCx := .F.
		MsgInfo(STR0066,STR0001) //#"Não foi realizada a conferência do fechamento de caixa do dia anterior. Favor fechar o caixa e efetua-la." ##"Atenção"
		Return(.T.)
	Else
		lFecConfCx := .T.
	EndIf
EndIf
If !lFechaCup 
	//"Erro no fechamento do cupom"
	//"É Necessário FECHAR a Venda ou CANCELAR este Cupom Fiscal."
	Aviso( STR0033 , STR0014 , {'&OK'})
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("LaFunhProd")
	If lLjcFid
		If nTotItens > 0
			If LaFunhProd(cCodProd) 							
				MsgStop (STR0055)//"Esta venda ja possui outros produtos. O produto para recarga de cartao fidelidade não poderá ser utilizado."
				Return (.F.)
			Else
				If Fa271aGrcf() 
					MsgStop (STR0056)//"Esta venda ja possui uma recarga de cartao fidelidade.Nenhum outro produto poderá ser utilizado."				
					Return (.F.)
				Endif
			Endif
		Endif
		
		If nQuant > 1
			MsgStop (STR0057)//"Quantidade não permitida para recarga de cartão fidelidade !"		
			Return (.F.)
		EndIf		 		                                 		 
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vale Presente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SBI->( FieldPos( "BI_VALEPRE" ) ) > 0 .And. lVPNewRegra
	If !Empty(Lj7VPYesNo())
		If Lj7VPIsPrd(cCodProd)
			If Lj7VPYesNo() == "N"
				MsgStop(STR0063) //"Esta venda já possui outros produtos. O Vale Presente somente pode ser vendido individualmente."
				Return (.F.)
			EndIf
		Else
			If Lj7VPYesNo() == "S"
				MsgStop(STR0064) //"Esta venda possui Vale Presente. Outros produtos não podem ser adicionados nesta mesma venda."
				Return (.F.)
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Novo procedimento para digitacao de quantidade x item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cDigQtde)

	nI := At(cDigQtde, cCodProd)
	If nI > 0
		nTmpQuant := Val(PadL(cCodProd, nI -  1))
		cCodProd := SubStr( cCodProd, nI + 1, Len(cCodProd))
	EndIf
	
	nI := 0
EndIf

cLGRedes  := LjGetStation("REDES")

// Verifica data e hora para registro de cada item.
// Requisito para Alagoas
If LjAnalisaLeg(31)[1]
   If !CheckIFData()
      Return( .F. )
   EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o nValor com os valores dos itens adicionados   	   ³
//³ antes da queda da venda, quando houver a recuperação da venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor == 0 .AND. Len(aItens) > 0 
	For nW := 1 To Len(aItens)
		If !(aItens[nW][AIT_CANCELADO])
			nValor += aItens[nW][AIT_VLRITEM]
		EndIf
	Next nW
EndIf

If ( ValType(xOrc) == "C" .AND. Len(xOrc) > 0 ) .OR. ( ValType(xOrc) == "A" .AND. Len(xOrc[1]) > 0 )
	lOrc := .T.
	lImpOrc  := .T.
	cCodProd := FR271CAField(xOrc, "L2_PRODUTO", nNumItem)
	cCliente := FR271CAField(xOrc, "L1_CLIENTE")
	cLojaCli := FR271CAField(xOrc, "L1_LOJA")
	cEntrega := FR271CAField(xOrc, "L2_ENTREGA", nNumItem) 	
	If Empty(cEntrega)		//Caso nao tenha sido indicado nada no campo L2_ENTREGA
		cEntrega := "2"     //sera considerado como default tipo 2 - Retira. 
	EndIf 	
	cReserva := FR271CAField(xOrc, "L2_RESERVA", nNumItem) 	
	cLojaRes := FR271CAField(xOrc, "L2_LOJARES", nNumItem) 	
	cNumOrc	 := FR271CAField(xOrc, "L2_NUM", nNumItem) 	

	cNumLoc	 := FR271CAField(xOrc, "L2_LOCALIZ", nNumItem)
	cNSerie	 := FR271CAField(xOrc, "L2_NSERIE", nNumItem)
	cLote	 := FR271CAField(xOrc, "L2_LOTECTL", nNumItem)
	cSubLote := FR271CAField(xOrc, "L2_NLOTE", nNumItem)
	dVldLote := FR271CAField(xOrc, "L2_DTVALID", nNumItem)
			
	If lGE
		cGarant	 := FR271CAField(xOrc, "L2_GARANT", nNumItem)
		nVlgApro := FR271CAField(xOrc, "L2_VLGAPRO", nNumItem)
	
		If SL2->( FieldPos( "L2_ITEMGAR" ) > 0 )
			cItemGar := FR271CAField(xOrc, "L2_ITEMGAR", nNumItem)
		EndIf
		
	EndIf
	   
	//PAF-ECF: Verifica se item foi cancelado na Retaguarda enquanto Orcamento, para realizar o cancelamento logo apos a impressao do Item no ECF
	If lLjNfPafEcf
		cVendido := FR271CAField(xOrc, "L2_VENDIDO", nNumItem) 		
	EndIf
		
	If SL2->( FieldPos( "L2_VALEPRE" ) > 0 )
		cValePre := FR271CAField(xOrc, "L2_VALEPRE", nNumItem)
	EndIf
Else

	// Zera garantia, caso tenha sido importada anteriormente a esse orcamento
	If Len(aItens) == 0 
		LjZGarant()
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na importacao de orcamento, a variavel nValor esta alimentada com o ³
	//³ "Valor Liquido".                                                    ³
	//| Caso o orcamento tenha sido importado, ao adicionar mais produtos   ³
	//| a variavel "nValor" deve passar a assumir o Valor Bruto "nVlrBruto".³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpOrc
		nValor := nVlrBruto
	EndIf
	
	
	lImpOrc  := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao estiver carregando orcamento e nao for alteracao  ³
	//³ de Vendedor, define o Vendedor como o padrao definido no ³
	//³ parametro MV_VENDPAD senao atualiza o Vendedor alterado  ³
	//³ Se já foi carregado (Len(aItens)) e acrescentado mais    ³
	//  itens, mantem o vendedor que foi carrEgado da retaguarda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItens) == 0 
		//se primeiro item e vidalink pode ter alterado o vendedor 
		If lAltVend .AND. nVidaLink = 1 .AND. !Empty(cVendLoja)
			cVndLjAlt := cVendLoja  // apenas para manter as duas variaveis iguais
		ElseIf !lAltVend .OR. Empty(cVndLjAlt)   
			cVendLoja:= Left(PadR(SuperGetMV("MV_VENDPAD"),nTamA3_COD),nTamA3_COD)
	   	Else 
	   		cVendLoja := cVndLjAlt
	   	Endif                                        
	EndIf   
   	//Caso a rotina foi chamada pela pesquisa de lista de presentes e esteja como entrega
   	//coloco "S" na reserva para emitir cupom nao fiscal, conforme necessidade.
   	IF ProcName(1) == "FR271LISTA" .AND. cEntrega == "3"
   		cReserva := "S"
   	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios                        ³
//³Apresentar A tela "Dados do Formulario" para que o usuario 	 ³
//³informe os dados do formulario que sera utilizado na venda 	 ³
//³Paises: Chile/Colombia - F1CHI								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCFolLocR5 .AND. FaGetRecFo() == 0 .AND. nTotItens == 0    
	If !LjxEspxFo(@cSigEspFo,@cDocFo,@cSerieFo,@nRecnoFo,;
					lOrc)
		lEscFo := .T.
		cDoc := ""				
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se a serie e valida em algum controle de formulario(SFP)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
 	If !lEscFo  			
		If !ChkFolCHI(xFilial("SFP"), 	cSerieFo, cDocFo,	"1|2|3|4",;
						NIL,	.F.)						   
			Return (.F.)	
		Else
			cDoc := cDocFo 	   		
		EndIf			
   	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para o GS1 DataBar , aonde faz o controle de data de validade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If SuperGetMv("MV_LJDTBAR",,.F.)
	aRetDtBar := LjxDataBar(cCodProd)
	cCodProd  := aRetDtBar[1][1]
	dDtValid  := aRetDtBar[2][1] 
	If !Empty(dDtValid) .AND. dDtValid <= dDatabase
		// Caso Retorne que o produto esta vencido apresenta uma mensagem informando que nao pode ser vendido
		LjxMsgVenc()	
		Return(.F.)
	EndIf		
	cInfProBal:= SubStr(cCodProd,8,5)
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cCodProd = SBI->BI_COD    ³
//³ cCodBar  = SBI->BI_CODBAR ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodBar := cCodProd
lAchou := LJSB1SLK(@cCodProd,@nTmpQuant,.T.)

//No caso de importacao de orcamento, se nao achou o produto no PDV, tenta se conectar com a base (TopConnect) da retaguarda para trazer o produto para o PDV
If !lAchou .And. lImpOrc .And. !lBscPrdON .And. ExistFunc("FRTXGetTC")
	If Len(aConnTopRet) == 0
		//Executa a funcao FRTXGetTC na retaguarda para ler o SERVER.INI da retaguarda para pegar as configuracoes de comunicacao do TopConnect
		LJMsgRun( STR0061, NIL, { || aConnTopRet := FR271CMyCall( "FRTXGetTC" ) } ) //"Aguarde... Comunicando com a retaguarda"
	EndIf
EndIf

If !lAchou .And. (lBscPrdON .Or. Len(aConnTopRet) > 0)
	aSavArea	:=	GetArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Front irá se conectar com a retaguarda       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(nConTcLnk)=="N" .AND. nConTcLnk >= 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a conexão com a retaguarda.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTAFCHCON(nConTcLnk)			
	EndIf
	If !FRTAABRCON(@nConTcLnk,aConnTopRet)
		Return(NIL)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona/prepara a area da retaguarda para ser utilizada no Check-Out  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTADEFTAB(Posicione("SX2", 1, "SB1", "AllTrim(X2_ARQUIVO)"), "SB1", nConTcLnk)

	If !Empty(cCodProd)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica/atualiza os registros do check-out ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTADNWCHK(nConTcLnk, cCodProd, lBscPrdON, cCliente, cLojaCli)
	EndIf		
	RestArea(aSavArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apos ter efetuado a consulta TCLink verifica se o prod esta na base local ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAchou := LJSB1SLK(@cCodProd,@nTmpQuant,.T.)
EndIf	

If nVidaLink = 1  // Gravando VidaLink
	lOrc := .F.
	lImpOrc  := .F.
	cCodProd := Posicione("SBI",5,xFilial("SBI")+ Substring(aVidaLinkD[VL_DETALHE, nNumItem, VL_EAN ] + space(15),1,15) ,"BI_COD")  //Com o codigo de barra (EAN) pego o cod.prod.
 	cCliente := aVidaLinkc[VL_C_CODCL]
	cLojaCli := aVidaLinkc[VL_C_LOJA]
EndIf
If !Empty(cChkProduto)
	cCodProd := cChkProduto
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄü
//³Atualiza o tipo do Cliente ( tratamento fiscal )³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄü
If Len(aItens) == 0 .AND. !Empty(cCliente) .AND. !Empty(cLojaCli)
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli))
		cTipoCli := SA1->A1_TIPO
	EndIf	
EndIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sendo o primeiro item digitado, busca para saber se existem³
//³tabelas de preco ativadas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItens) == 0 .AND. lCenVenda
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o array estatico do LOJA701E³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjxClFindT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca no LOJA701E se existem tabelas de preco ativa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjxFindTab(cCliente, cLojaCli)
EndIf

If Empty(cCodProd)
	Return(.T.)
Else
	// lLeitor Identifica se o Codigo de Barras foi originado pelo Leitor Serial.
	// Utilizar o PE FRTCodB2 para manipular esta informacao.
	nI := At("|", cCodProd)
	If nI > 0
		cCodProd := PadR(Stuff(cCodProd, nI, 1, ""), nTB1COD)
		lLeitor := .T.
	EndIf
EndIf


//Valida se um produto tipo garantia estendida esta sendo vendido fora de um orçamento
If !lImpOrc .AND. lGE .and. Posicione("SBI",1,xFilial("SBI")+cCodProd, "BI_TIPO") == cMvLjTGar
    MsgStop(STR0060,STR0001) //"Nao é permitida a venda de um produto tipo garantia estendida fora de um orçamento."#"Atenção"
    Return .T.
EndIf             

nRet := IFStatus(nHdlECF, "9", @cRet)		// Verifico o Status do ECF
If nRet <> 0
	FR271HTimer(	@oTimer		, @oHora		, @cHora		, @oDoc			,;
		 		@cDoc		, @oPDV			, @cPDV			, @nLastTotal	,; 
		 		@nVlrTotal	, @nLastItem	, @nTotItens	, @nVlrBruto	,;
				@oVlrTotal	, @oCupom		, @oTotItens	, @oOnOffLine	,;
				@lOcioso	, @lLocked		, @aItens		, @aMoeda		,; 
				@aSimbs		, @nMoedaCor	, @aTotVen		, @oMensagem	,;
				oFntMoeda	, @cMensagem	)
	
	
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	Return(.T.)
EndIf

If lEmitnfce
	If !Fr271aVlDt() 
		MsgAlert(STR0082 + CRLF + STR0083)  // "A Data do dia é diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."
		Return(.T.)
	EndIf
EndIf

If lGaveta
   While !lFoco       
      lFoco := .T.
	  If SLG->LG_GAVSTAT
		If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
			If GavetaStat(nHdlGaveta, LJGetStation("PORTGAV")) == 1
				lFoco := .F.				
			EndIf
		Else
			// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
			If IFStatus(nHdlECF, "14", "") == 1
				lFoco := .F.				
			EndIf
		EndIf
		If !lFoco
			// Desativa foco do Leitor se a gaveta estiver aberta 
			If lUsaLeitor
				LeitorFoco(nHdlLeitor,.F.)			
			EndIf
			// "Não é possível realizar vendas com a gaveta aberta. Favor fechá-la.", "Atenção"
				HELP(' ',1,'FRT012')
		EndIf			                                                               
	  Endif
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Validacao do "Recebimento de Conta" Deve Ser Realizada ³
//³ Dentro do PE "FRTProdOK".                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBCONTA := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa chamada do Template  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTProdOKt 
	aTmpProd := ExecTemplate("FRTProdOK",.F.,.F.,{cCodProd, nQuant, aItens, cVendLoja, cCodProIni})
	If ValType(aTmpProd) == "A"
		If Len(aTmpProd) >= 1
			If ValType(aTmpProd[1])== "C"
				cCodProd := Padr(aTmpProd[1],nTB1COD)
			EndIf
		EndIf
		If Len(aTmpProd) >= 2
			If ValType(aTmpProd[2])== "C"
				cBCONTA := PadR(aTmpProd[2],TamSX3("L2_BCONTA")[1])
			EndIf
		EndIf
		If Len(aTmpProd) >= 3
			If ValType(aTmpProd[3])== "C"
				cVendLoja := aTmpProd[3]
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o Retorno do FRTProdOK Nao Seja Array,   ³
		//³ Eh Interpretado Que Devera Abandonar a Validacao ³
		//³ Voltando Para o Get.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Return(.T.)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE Generico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTProdOK")
	aTmpProd := ExecBlock("FRTProdOK",.F.,.F.,{cCodProd, nQuant, aItens, cVendLoja, cCodProIni})
	If ValType(aTmpProd) == "A"
		If Len(aTmpProd) >= 1
			If ValType(aTmpProd[1])== "C"
				cCodProd := Padr(aTmpProd[1],TamSX3("BI_COD")[1])
			EndIf
		EndIf
		If Len(aTmpProd) >= 2
			If ValType(aTmpProd[2])== "C"
				cBCONTA := PadR(aTmpProd[2],TamSX3("L2_BCONTA")[1])
			EndIf
		EndIf
		If Len(aTmpProd) >= 3
			If ValType(aTmpProd[3])== "C"
				cVendLoja := aTmpProd[3]
			EndIf
		EndIf
	ElseIf ValType(aTmpProd) == "L"
		If aTmpProd == .F.
			Return(.F.)   
		Else
			Return(.T.)   
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o Retorno do FRTProdOK Nao Seja Array,   ³
		//³ Eh Interpretado Que Devera Abandonar a Validacao ³
		//³ Voltando Para o Get.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Return(.T.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso for inserido mais um produto para um orcamento     ³
//³carregado no Front, (via F3) utilizar a seguinte regra: ³
//³                                                        ³
//³- Se for condicao de pagamento Negociada, limpar a array³
//³de condicao de pagamento (orcamento) para que na finali-³
//³zacao, seje informado novamente;                        ³
//³                                                        ³
//³16/09/2002 - Fernando Salvatori                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lF3 .AND. Len( aParcOrc ) > 0
	If AllTrim(cItemCOrc) == "CN"
		aParcOrc    := {}		// Limpando parcelas 
		aParcOrcOld := {}
		cItemCOrc   := ""		// Limpando condicao de pagamento
	EndIf
	lImpNewIT   := .T.	 		// Indica se foi adicionado um novo item ao orcamento
EndIf

If ! lAchou
	If ExistBlock("FRTCODB1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o RDMake nao retornar "" deve estar posicionado no SBI correspondente. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFRTCodB := ExecBlock("FRTCODB1",.F.,.F.,{cCodProd})
		If !Empty(cFRTCodB)
			lAchou	:= .T.
			cCodProd	:= SBI->BI_COD
		EndIf
	EndIf
EndIf
If lAchou
	//Somente verifica se o produto está bloqueado no cadastro para não poder utiliza-lo, se não for importação de orçamento
	lVerBloq := !lImpOrc
	If ExistCPO("SBI", cCodProd, 1, Nil, Nil, lVerBloq)
		If ! SLK->(DbSeek(xFilial("SLK")+cCodBar))
			cCodBar	:= If(Empty(SBI->BI_CODBAR),cCodProd,SBI->BI_CODBAR)
		EndIF
		cCodProd	:= SBI->BI_COD
		cProduto	:= SBI->BI_DESC
		cUnidade	:= SBI->BI_UM
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Cartao Fidelidade                                       ³
		//³Verifica se o produto informado eh do tipo recarga de cartao fidelidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lLjcFid .AND. ExistFunc("LaFunhProd")			
			If LaFunhProd(cCodProd) 
				If !LaFunhInc (	lOrc,;
								IIf(lOrc,FR271CAField(xOrc, "L2_NUMCFID", nNumItem),""),;
								IIf(lOrc,FR271CAField(xOrc, "L2_DTSDFID", nNumItem),""),;
								IIf(lOrc,FR271CAField(xOrc, "L2_VLRCFID", nNumItem),""))
					LaFunhDelS ()
					FA271aSrcf (.F.)
					Fa271aSpfw (.F.)															
					Return .F.
				Else
					Fa271aSrcf (.T.) //Definir que nesta venda esta sendo realizada um recarga de cartao fidelidade
					nVlrUnit:= LaFunhGet(3) //Atualizar valor do produto com o valor da recarga					
				EndIf		 	
		 	Endif		 
		Endif		
		
		
		// Se for alterado algum tratamento referente as variaveis setadas abaixo,
		// nao esquecer de revisar o PE FRTKIT (logo abaixo)
		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. nMoedaCor == 1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Cartao Fidelidade  ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lLjcFid
				If lOrc .AND. !Fa271aGrcf ()//Se for orcamento E nao for recarga de cartao fidelidade
					nVlrUnit := FR271CAField(xOrc, "L2_PRCTAB", nNumItem)
				Else
					If nVidaLink = 1  // Gravando VidaLink
					nVlrUnit := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]
					Else
						If !Fa271aGrcf()//Se nao for recarga de cartao fidelidade
							If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli, /*Moeda*/ , nQuant )
								Return .F.
							EndIf
						EndIf
					Endif
				EndIf			
			Else			
				If lOrc //Se for orcamento 
			
			   		If lGE .AND. SBI->BI_TIPO == cMvLjTGar					
						nVlrUnit := FR271CAField(xOrc, "L2_VRUNIT", nNumItem)
			   		Else
						nVlrUnit := FR271CAField(xOrc, "L2_PRCTAB", nNumItem)
					EndIf		
		
				Else
					If nVidaLink = 1  // Gravando VidaLink
						nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
					Else
						If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli, /*Moeda*/ , nQuant )
							Return .F.
						EndIf					
					Endif
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Cartao Fidelidade  ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLjcFid				
				If lOrc .AND. !Fa271aGrcf ()//Se for orcamento ou nao for recarga de cartao fidelidade		
					nVlrUnit := Round(xMoeda(FR271CAField(xOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
				Else                             
					If cPaisLoc == "BRA"
						nMoedaTab := 1
					Else
						nMoedaTab := SBI->BI_MOEDA
					EndIf
					If nVidaLink = 1  // Gravando VidaLink
					nVlrUnit := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]
					Else  
						//Se nao for recarga de cartao fidelidade
						If !Fa271aGrcf () 
							If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli , /*Moeda*/ , nQuant)
								Return .F.
							EndIf
						Endif
						nVlrUnit := Round(xMoeda(nVlrUnit,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)						
					Endif
				EndIf
			Else
				If lOrc //Se for orcamento	
				
					If lGE .AND. SBI->BI_TIPO == cMvLjTGar						
						nVlrUnit := FR271CAField(xOrc, "L2_VRUNIT", nNumItem)
					Else
						nVlrUnit := Round(xMoeda(FR271CAField(xOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					EndIf        
			
				Else                             
					If cPaisLoc == "BRA"
						nMoedaTab := 1
					Else
						nMoedaTab := SBI->BI_MOEDA
					EndIf 
					
					If nVidaLink = 1  // Gravando VidaLink
						nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
					Else  
						If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli , /*Moeda*/ , nQuant)
							Return .F.
						EndIf
						nVlrUnit := Round(xMoeda(nVlrUnit,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					Endif
				EndIf			
			EndIf
		EndIf      
		
		//³Release 11.5 - Localizacao Chile - Arredondamento do valor unitario  - F1CHI ³
		If cPaisLoc == "CHI" 
			nVlrUnit := Round(xMoeda(nVlrUnit,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
		EndIf		

		If (SubStr(cLGRedes,3,1)) == "1"
			lCpoRedes  := .T.
		EndIf

		aProdRcg   := StrToKarr(cMVLJPREC , "/")  
		nPosProdRc := Ascan(aProdRcg,{|x| AllTrim(x)  == AllTrim(cCodProd)})

		If nPosProdRc > 0 .AND. lCpoRedes .AND. cTipTEF == TEF_CLISITEF		.AND.	!lRecarEfet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para a recarga de celulares ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If !FrtValProd(	@nVlrUnit , cCodProd , .F. 	, "" , @aRegTEF, aItens )
				Return( .F. )
			Else
				lRecarEfet	:= .T.
			EndIf

		ElseIf nPosProdRc > 0 .AND. lCpoRedes .AND. cTipTEF == TEF_CLISITEF		.AND. lRecarEfet
       		MsgAlert( STR0052 )		//"Nao e possivel efetuar mais de uma recarga na mesma venda."
			Return( .F. )		
			
		ElseIf nPosProdRc > 0 .AND. cTipTEF <> TEF_CLISITEF
       		MsgAlert( STR0053 )		//"O produto de recarga so e valido para a modalidade CliSitef."		    
			Return(.F.)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a balanca trabalha por preco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto esta no padrao EAN-13 			   ³
		//³e se o primeiro digito eh 2 (padrao balanca)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
			nTmpQuant := Round(Val(cInfProBal)/100 / nVlrUnit,3)		// A Balanca Utiliza 3 Decimais!!!
		EndIf
		If lOrc
			nTmpQuant := FR271CAField(xOrc, "L2_QUANT", nNumItem)
		EndIf
		If nVidaLink = 1  // Gravando VidaLink
			nTmpQuant := aVidaLinkD[VL_DETALHE, nNumItem, VL_QUANTID]
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao especifica para atender a legislacao do SEFAZ ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lEmitNFCe .AND. LjAnalisaLeg(12)[1]
			If (nVlrPercIT > 0) .OR. (nVlrDescIT > 0)
				nVlrPercIT := 0
				nVlrDescIT := 0
				LJMsgLeg(LjAnalisaLeg(12))
			EndIf	
		EndIf
	
		nValorReal := nVlrUnit  
		If cPaisloc="POR"           
			nMaxElem   := If( SBI->BI_MULT > 1, nQuant, 1) 
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se e' KIT de Produtos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFRTKit := LjInfoKit(cCodProd, lItemImp)							//Localizado no programa LOJXFUND.prw
		If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
			nMaxElem := Len(aFRTKit)
		Else
			aFRTKit := {}
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. Para Registrar Varios Produtos de uma vez (KIT) ³
		//³ Retorno: Array bidimensional com BI_COD e L2_QUANT   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFRTKITt
			aFRTKit := ExecTemplate("FRTKIT",.F.,.F.,{cCodProd,nTmpQuant})
			If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
				nMaxElem := Len(aFRTKit)
			Else
				aFRTKit := {}
			EndIf
		EndIf
		If ExistBlock("FRTKIT")
			aFRTKit := ExecBlock("FRTKIT",.F.,.F.,{cCodProd,nTmpQuant})
			If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
				nMaxElem := Len(aFRTKit)
			Else
				aFRTKit := {}
			EndIf
		EndIf
		
		//Iniciamos o array usado na funcao Lj7Arred, pois usaremos ela para proporcionalizar o Frete / Seguro / Despesa
		Lj7Arred(1)
		
		For nX := 1 TO nMaxElem
			If Len(aFRTKit) > 0		
				If ! SBI->(DbSeek(xFilial("SBI")+aFRTKit[nX][1]))
					Loop
				EndIf
				nTmpQuant	:= aFRTKit[nX][2]
				cCodProd	:= SBI->BI_COD
				cProduto	:= SBI->BI_DESC
				cUnidade	:= SBI->BI_UM
				If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. nMoedaCor == 1)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Release 11.5 - Cartao Fidelidade  ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLjcFid	
						If lOrc .AND. !Fa271aGrcf ()//Se for orcamento ou nao for recarga de cartao fidelidade
							nVlrUnit := FR271CAField(xOrc, "L2_PRCTAB", nNumItem)
						Else
							If nVidaLink = 1  // Gravando VidaLink
							nVlrUnit := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]
							Else							
								If !FA271aGrcf() ////Se nao for recarga de cartao fidelidade
									If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli , /*Moeda*/ , nTmpQuant)
										Return .F.
									EndIf
								EndIf
							Endif
						EndIf
					Else
						If lOrc //Se for orcamento
							nVlrUnit := FR271CAField(xOrc, "L2_PRCTAB", nNumItem)
						Else
							If nVidaLink = 1  // Gravando VidaLink
							nVlrUnit := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]
							Else							
								If !LjxeValPre (@nVlrUnit, cCodProd, cCliente, cLojaCli , /*Moeda*/ , nTmpQuant)
									Return .F.
								EndIf								
							Endif
						EndIf            					
					Endif
				Else					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Release 11.5 - Cartao Fidelidade  ³ 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLjcFid					
						If lOrc .AND. !Fa271aGrcf ()//Se for orcamento ou nao for recarga de cartao fidelidade		
							nVlrUnit := Round(xMoeda(FR271CAField(xOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
						Else
							If nVidaLink = 1  // Gravando VidaLink
								nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
							Else
								nMoedaTab:= If(SBI->(ColumnPos("BI_MOEDA"))>0,SBI->BI_MOEDA,1)
								//Se nao for recarga de cartao fidelidade
								If !Fa271aGrcf()
									nVlrUnit := Round(xMoeda(SBI->BI_PRV,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
								Else
									nVlrUnit := Round(xMoeda(nVlrUnit,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
								EndIf
							Endif
						EndIf 
					Else
						If lOrc //Se for orcamento
							nVlrUnit := Round(xMoeda(FR271CAField(xOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
						Else
							If nVidaLink = 1  // Gravando VidaLink
								nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
							Else
								nMoedaTab:= If(SBI->(ColumnPos("BI_MOEDA"))>0,SBI->BI_MOEDA,1)
								nVlrUnit := Round(xMoeda(nVlrUnit,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)								
							Endif
						EndIf					
					EndIf
				EndIf		

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para a recarga de celulares ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			

				If nPosProdRc > 0 .AND. lCpoRedes .AND. cTipTEF == TEF_CLISITEF		.AND.	!lRecarEfet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento para a recarga de celulares ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If !FrtValProd(	@nVlrUnit , cCodProd , .F. 	, "" , @aRegTEF, aItens )
						Return( .F. )
					Else
						lRecarEfet	:= .T.
					EndIf

				ElseIf nPosProdRc > 0 .AND. lCpoRedes .AND. cTipTEF == TEF_CLISITEF		.AND. lRecarEfet
					MsgAlert( STR0052 )		//"Nao e possivel efetuar mais de uma recarga na mesma venda."
					Return( .F. )		
							
				ElseIf nPosProdRc > 0 .AND. cTipTEF <> TEF_CLISITEF
		       		MsgAlert( STR0053 )		//"O produto de recarga so e valido para a modalidade CliSitef."		    
					Return(.F.)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a balanca trabalha por preco ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o produto esta no padrao EAN-13 			   ³
				//³e se o primeiro digito eh 2 (padrao balanca)            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
					nTmpQuant := Round(Val(cInfProBal)/100 / nVlrUnit,3)		// A Balanca Utiliza 3 Decimais!!!
				EndIf
				If lOrc
					nTmpQuant := FR271CAField(xOrc, "L2_QUANT", nNumItem)
				EndIf
				If nVidaLink = 1  // Gravando VidaLink
					nTmpQuant := aVidaLinkD[VL_DETALHE, nNumItem, VL_QUANTID ]
				EndIf			
			EndIf

			If cPaisloc == "POR"           
				If SBI->BI_MULT > 1
					aAux := FR271HProdMult(	nValorReal	, Len(aItens)+1	, nMaxElem	, @cCodProd	,;
											@_aMult		, @_aMultCanc)
					nTmpQuant := 1
					nVlrUnit  := Val( Str(aAux[2],10,2) )
					If Len(aAux) == 3
						cCodProd	:= aAux[3]
					EndIf
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Modificar a Quantidade e Valor Unitario ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTQUANT")
				aAux := ExecBlock("FRTQUANT",.F.,.F.,{nTmpQuant,nVlrUnit,nQuant,cBCONTA,nVlrTotal,cCodProd,cCodProIni})
				If ValType(aAux) == "A" .AND. Len(aAux) >= 2
					nTmpQuant := aAux[1]
					nVlrUnit  := aAux[2]
					If Len(aAux) == 3 
						cCodProd	:= aAux[3]
					Endif
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso o Retorno do FRTQuant Nao Seja Array,       ³
					//³ Eh Interpretado Que Devera Abandonar a Validacao ³
					//³ Voltando Para o Get.                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Return(.T.)
				EndIf
			EndIf
			
			SBI->(DbSetOrder(1))
			SBI->(DbSeek(xFilial("SBI")+cCodProd))
		
			cCodBar		:= If(Empty(SBI->BI_CODBAR),cCodProd,SBI->BI_CODBAR)			
			cProduto	:= SBI->BI_DESC
			cUnidade	:= SBI->BI_UM
			nQuant		:= nTmpQuant
		               
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para indicar se o ECF faz o arredondamento (.T.) ou ³
			//³ truncamento (.F.) dos valores.                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTECF13")
			    lStatusImp13 := ExecBlock("FRTECF13",.F.,.F.,{cCodProd, nVlrUnit, nQuant})
			Else
				lStatusImp13 := (IFStatus(nHdlECF, "13", @cRet) == 0)		// Indica se arredonda (.T.) ou trunca (.F.) os valores
			Endif
		
			If !lStatusImp13  // Se o ECF Nao Tem Arredondamento
			    nVlrItem := NoRound(nQuant * nVlrUnit,nDecimais)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a balanca trabalha por preco ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o produto esta no padrao EAN-13 			   ³
				//³e se o primeiro digito eh 2 (padrao balanca)            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
					If nVlrItem <> Val(cInfProBal)/100									// Se o Calculo Der Diferenca,
						If NoRound((nQuant+.001)*nVlrUnit,2) == Val(cInfProBal)/100		// Tenta Com UMA Grama a Mais
							nQuant += .001												// Para Que o Valor do Item Seja
							nVlrItem := NoRound(nQuant * nVlrUnit,2)					// o Mesmo do Codigo de Barra.
						EndIf
					EndIf
				EndIf
			Else
			   	/*======================================================================
					Utilizado a função LjxDRound pois caso utilizado Bematech 4000 FI 
					ou 4200 FI ocorre diferença de R$ 0,01 no arredondamento. 
				======================================================================*/
				If ExistFunc("LjxDRound")
					nVlrItem:= LjxDRound(nQuant * nVlrUnit,nDecimais)
				Else
					nVlrItem:= Round(nQuant * nVlrUnit,nDecimais) 
				EndIf	
			EndIf
			If lOrc
				nVlrPercIT	:= Round(FR271CAField(xOrc, "L2_DESC", nNumItem), nDecPDesc)
				nVlrDescIT	:= Round(FR271CAField(xOrc, "L2_VALDESC", nNumItem), nDecimais)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o parametro do novo metedo de tratamento de desconto no total do orc. importado ³
				//³esteja habilitado vai ratear o valor do desconto no total entre os itens.   			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If lImpDesc .AND. cVendido <> "N"
					nVlProp 	:= A410Arred(((nVlrItem - nVlrDescIT)*(FR271CAField( xOrc, "L1_DESCNF" ) / 100)),"D2_TOTAL")
					If nVlProp > 0
						nVlrDescIT  += nVlProp
						nDescOrc	+= nVlProp
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso seja o ultimo item do Orc Importado verifica se nao houve resido(sobra) no rateio³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
						If nLastItem == nNumItem
							nDifImp := FR271CAField( xOrc, "L1_DESCONT" ) - nDescOrc
							If Abs(nDifImp) > 0
								nVlrDescIT  += nDifImp
								nDescOrc	+= nDifImp
							EndIf
						EndIf
						nVlrPercIT	:= 0		// Zera o percentual para ser calculado logo abaixo
					EndIf	
				EndIf	
			EndIf
			If nVidaLink = 1  // Gravando VidaLink
				nVlrPercIT	:= 0
			EndIf                                            
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Integracao com o cenario de vendas, para aplicar desconto³
			//³no item, de acordo com a regra de descontos.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCenVenda .AND. !lOrc

				nDescItAnt := nVlrPercIT

				Fr271ARgrDesc(	@oCupom 	, @oDesconto	, @nVlrPercIT	, @nVlrTotal,;
								@lRecebe	, @lDescIT		, @lDescITReg	, @nVlrBruto,;
								@aItens		, @nMoedaCor	, @nDecimais	, @lCXAberto,;
								@nVlrDescIT	, @cCodProd		, @cCliente 	, @cLojaCli	,;
								nQuant		, nVlrItem		, aMostruario[1]) 

				lTemDscRrg := (nDescItAnt <> nVlrPercIT)

			EndIf			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o percentual de desconto no caso de ter sido    ³
			//³digitado apenas o valor do desconto e nao o percentual  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrPercIT == 0 .AND. nVlrDescIT > 0
				nVlrPercIT 	:= (nVlrDescIT/nVlrItem) * 100
			EndIf
			
			If !(lOrc .And. nVlrDescIT > 0)  //Somente calcula o valor do desconto do item na variavel nVlrDescIT se não for importacao de orcamento
				//Indica se ARREDONDA (.T.) ou TRUNCA
				If lStatusImp13
					nVlrDescIT	:= Round(nVlrItem * (nVlrPercIT/100),nDecimais)
				Else
					nVlrDescIT	:= NoRound(nVlrItem * (nVlrPercIT/100),nDecimais)
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for vale-presente, solicita o codigo e valida³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SBI->( FieldPos( "BI_VALEPRE" ) > 0 .AND. BI_VALEPRE == "1" )
				If nQuant <> 1
					Aviso( STR0049,STR0050, {STR0051} )
					//"Atenção"# "Vales presentes só podem ser vendidos em lançamentos de quantidade 1, para que o registro de seu código seja feito corretamente.""Ok
					Return (.F.)
				EndIf
				If !lOrc .OR. Empty( cValePre )
					nVlrUnitAnt := nVlrUnit
					If !LjGetVlPre( cCodProd, @cValePre, , @nVlrUnit )
						Return (.F.)
					ElseIf (nVlrUnitAnt <> nVlrUnit)
						If !lStatusImp13  // Se o ECF Nao Tem Arredondamento		//Com o valor unitário novo, calculo o valor total do item
			    			nVlrItem := NoRound(nQuant * nVlrUnit,nDecimais)
						Else
			   				nVlrItem:= Round(nQuant * nVlrUnit,nDecimais)
			   			EndIf
					EndIf
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PE para controlar o Desconto no Item. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFRTDescITt
				nPercITOld := nVlrPercIT			// Variavel que retorna o valor anterior
				nDescITOld := nVlrDescIT			// Variavel que retorna o valor anterior
				aRet := ExecTemplate("FrtDescIT",.F.,.F.,{	cCodProd, nVlrPercIT, nVlrDescIT, nVlrItem,;
															uProdTPL, uCliTPL   , nQuant	, cCliente,;
															cLojaCli, lImpOrc   , cDoc      , LJGetStation("SERIE") } )
				If ExistTemplate("DrSScrExMC") //Seta falso para cancelamento da tela de PBM
					T_DrSScrExMC(.F.)
				EndIf
															
				// Caso a tela de medicamento controlado seja cancelada, aborta a emissao do item.
				If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .AND. aRet[5]
					MsgAlert(STR0080 +chr(10)+chr(13)+ STR0081) //"Medicamentos Controlados necessitam de Infomações do Paciente." ##"Produto não será registrado"  
					nVlrPercIT := 0
					nVlrDescIT := 0
					cCodProd := ''
					cProduto := ''
					nQuant   := 1
					nVlrUnit := 0
					nVlrItem := 0
					nTotItens := 0
					nVlrPercIT := 0
					oProduto:Refresh()
					oQuant:Refresh()
					oVlrUnit:Refresh()
					oVlrItem:Refresh()
					oTotItens:Refresh()
					oVlrTotal:Refresh()
					oDesconto:Refresh()
					
					If ExistTemplate("DrSScrExMC") //Seta se cancelou a tela da medicamento controlado para cancelar os produtos da PBM
						T_DrSScrExMC(.T.)
					EndIf
					
					Return (.F.)
				Else
					nVlrPercIT := aRet[1]
					nVlrDescIT := aRet[2]
					uProdTPL   := aClone(aRet[3])
					uCliTPL    := aRet[4]
				EndIf
			EndIf
			
			If ExistBlock("FrtDescIT")
				nPercITOld := nVlrPercIT			// Variavel que retorna o valor anterior
				nDescITOld := nVlrDescIT			// Variavel que retorna o valor anterior
				aRet := ExecBlock("FrtDescIT",.F.,.F.,{ 	cCodProd,	nVlrPercIT,	nVlrDescIT,	nVlrItem,;
															cCliente,	cLojaCli	})
				nVlrPercIT := aRet[1]
				nVlrDescIT := aRet[2]
			EndIf
			
			If LjGetOPBM() <> Nil
				If lPrioPbm //se for VENDA PBM, os descontos oferecidos pela loja serao desconsiderados
					nVlrPercIT  := 0
					nVlrDescIT  := 0
				EndIf
				
				If !LjVendProdPbm(	cCodBar, nQuant, nVlrUnit, @lItemPbm, @nVlrDescIT, lPrioPbm, nVlrPercIT )
					nVlrPercIT  := 0
					nVlrDescIT  := 0
					Return(.F.)
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao da permissao do caixa para conceder descontos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cFormDesc == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Porcentagem³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
				If nVlrPercIT<>0             
					aDesc := { "P", nVlrPercIT }
				//ÚÄÄÄÄÄ¿
				//³Valor³
				//ÀÄÄÄÄÄÙ
				ElseIf nVlrDescIT<>0        
					aDesc := { "V", nVlrDescIT }
				EndIf	
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o percentual de desconto apenas para verificacao³
			//³da permissao do caixa, quando o valor foi informado e o ³
			//³percentual estiver como 0                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrDescIt > 0 .AND. nVlrPercIt == 0
				nPerDesc := (nVlrDescIt/nVlrItem) * 100
			Else
				nPerDesc := nVlrPercIT
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera o desconto se o valor do mesmo supera o   ³
			//³ valor do item a ser registrado.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVidaLink <> 1
				If nVlrDescIt >= nVlrItem
					MsgAlert(STR0048,STR0001) //"O desconto será desconsiderado pois é maior ou igual ao valor do item.","Atenção"
	
					nPerDesc   := 0
					nVlrPercIT := 0
					nVlrDescIT := 0
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao do desconto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .AND. !lImpOrc .AND. !lTemDscRrg 
				If lUsaDisplay
					DisplayEnv( StatDisplay(), "1E  " )  
					DisplayEnv( StatDisplay(), "**" )     //"Inibe os caracteres no display"
				EndIf
				If !LJProfile(11, Nil, aDesc, nPerDesc, nVlrDescIT)
					// Enviar mensagem para o display quanto a permissao do desconto
					LjDescDisp(2)

					If lUsaDisplay 
						DisplayEnv(StatDisplay(), "1C" + Substr(STR0047, 1, 25) )				// ### "Deseja zerar o desconto e prosseguir na venda?"
						DisplayEnv(StatDisplay(), "2C" + Substr(STR0047, 27) )					// ### "Deseja zerar o desconto e prosseguir na venda?"
						DisplayEnv(StatDisplay(), "3C" + STR0070 )                            // ### "Tecle <ENTER> para continuar"
						DisplayEnv(StatDisplay(), "4C" + STR0076 )        						// ### "Tecle <ESC> para cancelar"
					Endif
					
					//"Deseja zerar o desconto e prosseguir na venda?"
					If !(MsgYesNo(STR0047))
						Return (lRet)
					Else
						nPerDesc 	:= 0
						nVlrPercIt 	:= 0
						nVlrDescIT 	:= 0
					EndIf
				Else
				
					// Enviar mensagem para o display quanto a permissao do desconto
					If !Empty(nPerDesc) .OR. !Empty(nVlrDescIT)
						LjDescDisp(1)
					Endif
				
				EndIf
				If lUsaDisplay
					DisplayEnv( StatDisplay(), "*" )     //"Retoma os caracteres"
				
				EndIf   
			Endif
   			If nVidaLink == 1 
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³  Verifica se o preco do VidaLink eh maior que o preco do sistema ³ 
                //³  com desconto.Vale o preco menor aValPerc  						 ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aValPerc	:= T_DroVLPVal(aVidaLinkD,aVidaLinkc,nVidaLink,cCodProd, nVlrDescIT, nTmpQuant, nVlrItem, nVlrPercIT,nVlrUnit,aVidaLinkD,nNumItem,uProdTPL,uCliTPL,lImpOrc)
            	nVlrItem	:= aValPerc[1]  
            	nVlrDescIT	:= aValPerc[2]  
            	nVlrPercIT	:= aValPerc[3]   
            	nVlrUnit	:= aValPerc[4] 
            	nVlrItSDesc	:= nVlrItem + nVlrDescIT
            	If nVlrDescIT > 0  // Verifica se existe o desconto e 
	            	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                //³  Verica se existe desconto										 ³ 
	                //³  lFRTDescITt passo para false para que nao zere o desconto ao 	 ³
	                //³  voltar o backup   						  						 ³
	                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            		lDescIT       := .T.
            		lFRTDescITt   := .F. //passo para false para que nao zere o desconto ao voltar o
            	EndIf	
            Else
            	nVlrItSDesc := nVlrItem
		   		nVlrItem 	:= nVlrItem - nVlrDescIT
			EndIf 

			//Ponto de Entrada executado por último, após todos os tratamentos de desconto, para que o cliente possa definir o desconto desejado no item
			If ExistBlock("FrtItDsc")
				aRet := ExecBlock("FrtItDsc",.F.,.F.,{	cCliente,	cLojaCli, 	cCodProd,	nQuant	,;
														nVlrUnit,	nVlrItem,	nVlrDescIT	})
				nVlrDescIT 	:= aRet[1]
				nVlrPercIT 	:= aRet[2]
				nVlrItem 	:= nVlrItSDesc	- nVlrDescIT
			EndIf

			/* Limitacao de 10.000,00 - Legislacao Paulista 	*/ 
			If cPaisLoc == "BRA" .And. lExLegSP10 .AND. !lLegOK
				If !Lj950SP10OK(nVlrTotal + nVlrItem, 0, cCliente, cLojaCli)				// Primeiro veirifica se ultrapassou os 10K reais
					nVlrTotRe := 0
					If Len(aReserva) > 0								// Carrega o valor total de intes com reserva
						For nX := 1 To Len(aReserva)
							nVlrTotRe += aReserva[nX][8]            	//Os itens de reserva nao entram na lei
						Next nX  
					EndIf	
					If !Lj950SP10OK((nVlrTotal-nVlrTotRe) + nVlrItem, 2, cCliente, cLojaCli)	// Flag = 2 Pergunta se o usuário deseja prosseguir
						Return .F.
					EndIf	
				EndIf
			EndIf
	
			MaFisIni(	cCliente,	cLojaCli, "C"	,	"S",;
						cTipoCli,	NIL		, NIL	,	.F.,;
						"SBI"	,	NIL		, "01"	,	NIL,;
						NIL		,	cGrpTrib		, NIL	,	NIL,;
						NIL		,	NIL		, .F.	)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro da funcao MaTesInt               ³
			//³ExpN1 = Documento de 1-Entrada / 2-Saida   ³
			//³ExpC1 = Tipo de Operacao Tabela "DF" do SX5³
			//³ExpC2 = Codigo do Cliente ou Fornecedor    ³
			//³ExpC3 = Codigo do gracao E-Entrada         ³
			//³ExpC4 = Tipo de Operacao E-Entrada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   		//³Macro-executa o conteudo do parametro MV_LJLPTIV³
	   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lMcrTpOper
		   		xRet  := &(SubStr(cTpOper,2,Len(cTpOper))) 
		   		If ValType(xRet) == "C"
		   	 		cTpOper  := xRet
		   		EndIf	
       		EndIf

       		If lOrc
				cBI_TS := FR271CAField(xOrc, "L2_TES", nNumItem)
			Else		
				//Verifica se os componentes da lista de presentes estao aplicadas e se foi chamado pela tecla de atalho "32" (Consulta Lista)
				If lUsaLstPre .AND. ProcName(1) == "FR271LISTA"
					If !Empty(cTpOper)
						cTesInt := MaTesInt(2	,cTpOper	,cCliente, cLojaCli,;
										 	"C"	,SBI->BI_COD,NIL)
					ElseIf !Empty(cTESLstPre)
						cTesInt := cTESLstPre
					EndIf
					
					//Realiza as buscas padroes caso nao tenha retorno das pesquisas da Lista de Presentes
					If Empty(cTesInt)
						If Empty(cTpOper)
							cTpOper	:=	"01"
						EndIf
						cTesInt := MaTesInt( 2	,cTpOper	,cCliente, cLojaCli,;
											 "C",SBI->BI_COD,NIL)						
					EndIf
				Else
					//Realiza as buscas padroes caso seja um item lancado diretamente
					If Empty(cTpOper)
						cTpOper	:=	"01"
					EndIf
					cTesInt := MaTesInt( 2	,cTpOper	,cCliente, cLojaCli,;
										 "C",SBI->BI_COD,NIL)						
				EndIf
				
				If !Empty(cTesInt)
					cBI_TS := cTesInt
				Else
					cBI_TS := If(Empty(SBI->BI_TS), SuperGetMV("MV_TESSAI"), SBI->BI_TS)
				Endif
			EndIf
		   
		   /*
		   O retorno abaixo da MatxFis, tera sempre 1 como referencia de item , porque
		   é utilizado o MafisAdd temporariamente no produto inserido ,e depois e 
		   inutilizado as informacoes da Matxfis (MafisEnd())
		   */

			MaFisAdd(SBI->BI_COD ,cBI_TS	,nQuant		,nVlrUnit	,;
					 nVlrDescIt	 , ""	 	, ""    	,	        ,;
					 0           , 0	 	, 0     	, 0			,;
					 nVlrItSDesc , 0	 	) 
							
			cTES      := MaFisRet(1, "IT_TES"    )
			cCF       := MaFisRet(1, "IT_CF"     )
			nVlIcmRet := MaFisRet(1, "IT_VALSOL" )
			
			If lOrc 
				If !Empty(cReserva) .AND. cEntrega <> "2"
					cCF := FR271CAField(xOrc, "L2_CF", nNumItem)
				EndIf	

				nValIPIIT := FR271CAField(xOrc, "L2_VALIPI", nNumItem)
			Else
				nValIPIIT := MaFisRet(1, "IT_VALIPI")
			EndIf
	 
			SF4->(DbSeek(xFilial("SF4")+cTES))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o tratamento para excecao fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aFrtExcecao := MaFisRet(1,"IT_EXCECAO")
			lExcecaoFcl := Len(aFrtExcecao) > 0
			LjGrvLog( cOrcam  , " TES " + AllTrim(SF4->F4_CODIGO) + " - Verificação de exceção fiscal ", aFrtExcecao)

			SB1->(DbSetOrder(1))			
			SB1->(DbSeek(xFilial("SB1")+cCodProd))			
			
			If cPaisLoc == "BRA"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ processamento da lei dos impostos             ³
				//³ Colocado aqui por causa dos dados da MatxFis  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				 
				nVlrImpNCM	:= 0 
				xB1ImpNcm := 0 
				
				If lCpoTotImp     
	
					// nova funcionalidade disponibilizada pelo Fiscal
					If lAlqLei2741 

						xB1ImpNcm := AlqLei2741(SBI->Bi_POSIPI  ,IIf(lBi_ex_ncm, SBI->BI_EX_NCM,"")       ,Alltrim(MaSBCampo("CODISS")) ,SA1->A1_EST, ;
						                        SA1->A1_COD_MUN , cCodProd		, 1 /*Ref Item Matxfis*/, cLote		, Nil		,;
						                        cMvFisCTrb      , cMvFisAlCT	, lMvFisFRas			)	
					Else
					
						xB1ImpNcm :=  SBI->BI_IMPNCM
			
						If lBuscaImp .AND. lPosIpi .AND. xB1ImpNcm ==0 .AND. !Empty(SBI->BI_POSIPI)
							xB1ImpNcm	:= lj7BuscaImp(SBI->BI_POSIPI,!Empty(SBI->BI_CODISS), .F. )
						EndIf		
		
					EndIf
					
				EndIf
	
				If ValType(xB1ImpNcm) == "N"
					aAlqLeiTr := {xB1ImpNcm,0,0,0}
				ElseIf Len(xB1ImpNcm) == 2
                  aAlqLeiTr := {xB1ImpNcm[1],0,0,0,xB1ImpNcm[2],0,0,0}	
				Else	
					aAlqLeiTr := aClone(xB1ImpNcm)
				EndIf

				/* fim processamento da lei dos impostos */

				If !lStatusImp13  // Se o ECF Nao Tem Arredondamento
				    nVlrMerc += NoRound(nVlrUnit * nQuant,nDecimais)
				Else			
					nVlrMerc += Round(nVlrUnit * nQuant,nDecimais)
                EndIf

				//Quando possuir valor de aliquota foi definido o padrão de gravação do campo L2_SITTRIB, tanto para NFC-e, CUPOM e SAT: "CNNNN"
				//Exemplo: aliquota de 17% tributado. -> "T1700"
				If SF4->F4_ISS == "S"
					cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
				ElseIf lEmitNFCe .AND. !lUseSAT
					cAliquota := "T" + AllTrim( Str(MaFisRet(1,"IT_ALIQICM"),5,2) )
				Else
					If lF4MKPSOL
						lMargSol := SF4->F4_MKPSOL <> "1"
					EndIf
					
					If lMargSol .And. (SBI->BI_PICMRET > 0 .Or. (SBI->BI_PICMENT > 0 .And. ALLTRIM(SF4->F4_SITTRIB) == "60") .Or. ; 
						(lExcecaoFcl .And. (aFrtExcecao[3] > 0 .Or. aFrtExcecao[16] > 0 ) ) ) .And. ;
						cTipoCli $ SuperGetMV("MV_TPSOLCF") .And. SF4->F4_BSICMST <> 100 
						
						cAliquota := "F"
					ElseIf (SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100 ) .Or. ;
						(lExcecaoFcl .AND. (aFrtExcecao[14] > 0) .AND. (aFrtExcecao[14] < 100))
						
						cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
						
						If lExcecaoFcl
							LjGrvLog( cOrcam, " Redução de Alíquota configurada como exceção fiscal [ se campo estiver zerado preencha a redução no campo BI_ALIQRED] " , SBI->BI_ALIQRED) 		
						Else
							LjGrvLog( cOrcam, " Redução de Alíquota configurada pela TES [campo F4_BASEICM - se alíquota estiver zerada preencha a redução no campo BI_ALIQRED] " , SBI->BI_ALIQRED)
						EndIf
						
					ElseIf SF4->F4_LFICM == "I" 		
						If AllTrim(SF4->F4_SITTRIB) == "41"						
							cAliquota := "N"
						ElseIf AllTrim(SF4->F4_SITTRIB) == "40"	
							cAliquota := "I"
						Else
							cAliquota := "I"				// Isento
						    If SF4->F4_AGREG == "D"			// Deducao de ICMS                 
							   nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
							   nTotDedIcms += nDedIcmsIt
					        Endif
						EndIf				
					Elseif SF4->F4_LFICM == "N" .OR. SF4->F4_LFICM == "O"
						cAliquota := "N"					// Não sujeito a ICMS					
					Else
						nAliquota := AliqIcms(	"N"	,"S",cTipoCli,"I",;
												NIL	,.T.)												
						cAliquota := "T" + AllTrim(Str(nAliquota,5,2))												
					Endif
				EndIf

				nValPis := MaFisRet(1,"IT_VALPIS")
				nValCof := MaFisRet(1,"IT_VALCOF")
				nValCsl := MaFisRet(1,"IT_VALCSL")
				nBasePS2:= MaFisRet(1,"IT_BASEPS2")
				nValPS2	:= MaFisRet(1,"IT_VALPS2")
				nAliqPS2:= MaFisRet(1,"IT_ALIQPS2")
				nBaseCF2:= MaFisRet(1,"IT_BASECF2")
				nValCF2	:= MaFisRet(1,"IT_VALCF2")
				nAliqCF2:= MaFisRet(1,"IT_ALIQCF2")
				aISSQN[1] := Alltrim( MaSBCampo("CODISS") )
				aISSQN[2] := MaFisRet(1,"IT_BASEISS") 
				aISSQN[3] := MaFisRet(1,"IT_ALIQISS") 
				aISSQN[4] := MaFisRet(1,"IT_VALISS")
				aISSQN[5] := MaFisRet(1,"IT_CNAE")
				cCEST := MaFisRet(1,'IT_CEST')
				
				If lL2FECP
				    nValFECP := MaFisRet(1, "IT_VALFECP")
				    nAlqFECP := MaFisRet(1, "IT_ALIQFECP")
				EndIf
				
				If lL2FECPST
				    nValFECPST := MaFisRet(1, "IT_VFECPST")
                    nAlqFECPST := MaFisRet(1, "IT_ALFCST")
                EndIf

				lIsPrdServ := If(lFunTesISS, LjIsTesISS(cDoc,cTES), aISSQN[4] > 0)
				
				If lUseSat
					/* TRIBUTACAO SAT */
					aAdd(aSATTrib, {nTotItens + 1,"IT_BASEPS2",MaFisRet(1,'IT_BASEPS2')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_ALIQPS2",MaFisRet(1,'IT_ALIQPS2')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_BASECF2",MaFisRet(1,'IT_BASECF2')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_ALIQCF2",MaFisRet(1,'IT_ALIQCF2')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_PAUTPIS",MaFisRet(1,'IT_PAUTPIS')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_PAUTCOF",MaFisRet(1,'IT_PAUTCOF')})
					aAdd(aSATTrib, {nTotItens + 1,"IT_CEST",MaFisRet(1,'IT_CEST')})
					
					//Array de tributações do SAT
					If ExistFunc("LjSetTriSat")
						LjSetTriSat(aSATTrib)
					EndIf
				EndIf	

				//Regra utilizada no MatxFis para verificar a modalidade da base de calculo
				If lL2Modbc .Or. lICMDeson
					aModBc := MaFisRet(1,"IT_SPED")
					If Len(aModBc) > 0 .and. lL2Modbc
						cModBc := aModBc[1][6]
					EndIf
					
					If lICMDeson						
						
							If ! Empty(AllTrim(MafisRet(nX,"LF_MOTICMS" )))
																
								cMOTDICM := MafisRet(nX,"LF_MOTICMS")
								
								nAux := Len(aModBc)
								If nAux > 0
									nY := 0
									For nI := 1 to nAux
										nY += aModBc[nI][26] //Referencia SP_DESONE da MatxFis
									Next nI
																		
									nDESCICM := nY
								EndIf
								
								nY := 0
								nI := 0
								nAux := 0
							EndIf

							If  nDESCICM > 0 								
								nAuxVlrI := nVlrItem
								nVlrItem := MafisRet(1, "IT_TOTAL") 
								If nVlrItem <> nAuxVlrI
									nAuxVlrU := nVlrUnit
									nVlrUnit := nVlrItem / nQuant 
								EndIf	
							EndIf						
					EndIf

				EndIf

				//carrega o vetor com os valores referentes a ICMS-ST
				//esse vetor sera substituido por uma Classe, que sera um espelho do layout da NFC-e
				If lEmitNFCe
					If Len(aItens) == 0 
						LjSetICMST(NIL , 1) // Reset no array de ICMS
					EndIf
					
					nValICMS	:= MaFisRet(1,"IT_VALICM")
					nBaseICMS	:= MaFisRet(1,"IT_BASEICM")
					nBRICMS		:= MaFisRet(1,"IT_BASESOL")

					If !lUseSat
						aNFCeICMST := Array(2)

						aNFCeICMST[1] := StrZero(Len(aItens)+1,TamSx3("L2_ITEM")[1],0)
						aNFCeICMST[2] := {}

						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_MARGEM")	)
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_PREDST")	)
						Aadd( aNFCeICMST[2], nBRICMS					)
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_ALIQSOL")	)
						Aadd( aNFCeICMST[2], nVlIcmRet				 	)
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_VALFECP")	)
						
						
						//alimenta o array estatico (aICMSST) do LOJNFCE.PRW
						LjSetICMST( aNFCeICMST )
					EndIf	
				EndIf

			Else  
				nTotImp	 := 0 //necessário zerar a variável, pois em looping do PE pode duplicar os impostos ao lançar os itens

				If !Empty(cTES) .AND. ((nVlrUnit > 0) .OR. (nVlrItem > 0) .OR. (nQuant > 0))
	   				nVlrMerc += nVlrItem
			 	    aImps    := TesImpInf(cTES)
				    Aadd(aImpsSL2,{SBI->BI_COD,cTES,{}})
				    For nI := 1 to Len(aImps)                                                 
				       If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
				          AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
				          nE := Len(aImpsSL1)
				       EndIf   
				       cIndImp  := Substr(aImps[nI][2],10,1)               
				       cCampoVal   := "IT_VALIV"+cIndImp		    
				       cCampoAlq   := "IT_ALIQIV"+cIndImp	 
				       nValImp     := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
					   FR271HGeraImp(@aImposto,aImps[nI],nValImp,nQuant,nVlrUnit,1,cIndImp,nDecimais)
					   AAdd(aImpsSL2[len(aImpsSL2)][3],aClone(aImposto))
					   nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
					   aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
					   aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
				    Next nI
				    nTamItem  := TamSX3("L2_ITEM")[1]  
	                AAdd(aImpsSL2[Len(aImpsSL2)],Space(nTamItem))				
	           		AAdd(aImpsSL2[Len(aImpsSL2)],.F.)				   	           					      
					nVlrUnit  := Round(nVlrItem/nQuant,nDecimais)
					If nTotImp <> 0              // Verifica se existe imposto a incluir no valor do item 
		            	nVlrItem  += nTotImp
		            	lImpIncl  := .F.               
		            Else
		            	lImpIncl  := .T.
		            EndIf 	
				    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
	           		AAdd(aImpsSL2[Len(aImpsSL2)],nQuant)				   	           					                 		
	           		AAdd(aImpsSL2[Len(aImpsSL2)],nVlrUnit)				   	           					                 		           					    
				EndIf
			EndIf
			MaFisEnd()
	
			If Empty(cTES)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FrtDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
																
				If (AScan(aItensInvalid,{|x| x[2] == cCodProd })=0) 				
					Aadd(aItensInvalid, {nNumItem,cCodProd,AllTrim(cProduto)})
				endif

			EndIf	
			If 'SCHALTER' $ LjGetStation( 'IMPFISC' ) 
				If Left(cAliquota,1) == "T" .AND. (AScan(aICMS, {|x| x[1]==StrTran( cAliquota,'.',',' ) })=0) 
					If !(!Empty(cReserva) .AND. cEntrega <> "2")
						lEntra := .F.
					EndIf	
			    EndIf
			ElseIf !lEmitNFCe
			    If Left(cAliquota,1) == "T" .AND. (AScan(aICMS, {|x| x[1]==Val(Substr(cAliquota,2))})=0)
					If !(!Empty(cReserva) .AND. cEntrega <> "2")
						lEntra := .F.
					EndIf	
				Endif
			Endif			
			If !lEntra	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FrtDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
				// "Aliquota " ### " não cadastrada no ECF. Operação não efetuada.", "Atenção"
				MsgStop(STR0011+cAliquota+STR0012, STR0001)
				If cPaisLoc == "BRA" .AND. lImpOrc
					lErRegItem := .T.
				EndIf
				Return(.T.)
			Endif	
	
			If nVlrUnit==0 .OR. nVlrItem==0 .OR. nQuant==0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FrtDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
				
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1C" + Upper(STR0034) )         //"Produto com quantidade ou preco nulo"
					DisplayEnv(StatDisplay(), "2C" + STR0035)         //"PRESSIONE <ESC>"
				EndIf			
				HELP(' ',1,'FRT013')    // "Produto com o valor unitário nulo ou a quantidade nula." ### "Atenção"
				
				//Realiza o acerto do array de impostos para que nao ocorra a gravacao
				//de impostos com valor zero no arquivo SL2...
				If cPaisLoc <> "BRA"
					ADel(aImpsSL2, Len(aImpsSL2))
					ASize(aImpsSL2, Len(aImpsSL2)-1)							
				EndIf
				Return(.T.)
			EndIf
		
			If SF4->F4_INCSOL == 'S' 
				nVlrTotal	+= (nVlrItem + nValIPIIT + nVlIcmRet)
				nVlrBruto	+= (nVlrItem + nValIPIIT + nVlIcmRet)
			Else
				nVlrTotal	+= (nVlrItem + nValIPIIT )
				nVlrBruto	+= (nVlrItem + nValIPIIT )
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula os impostos de IPI, PIS, COFINS e CSLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValIPI		+= nValIPIIT
			nValTPis	:= nValTPis + nValPis
			nValTCof	:= nValTCof + nValCof
			nValTCsl	:= nValTCsl + nValCsl
			
			nItem		:= FRTPegaIT(SL2->L2_ITEM) 
			nCodANVISA  := nItem
			nTotItens++
			
			If !lTouch  
				If Empty(SBI->BI_BITMAP)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWIN³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oFotoProd:ExistBmp("FRTWIN")
						cFotoProd := "FRTWIN"				
					Else 
					 	cFotoProd := "LOJAWIN"
					EndIf	
				Else
					cFotoProd := AllTrim(SBI->BI_BITMAP)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para buscar a foto em diretório especifico   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFR271AFotPrd
					c271AFotPrd := U_FR271AFotPrd(SBI->BI_COD) //codigo da filial					
					If ValType(c271AFotPrd) == "C"
						cFotoProd := c271AFotPrd      
						If oFotoProd:cBMPFile <> cFotoProd
							oFotoProd:cBMPFile := cFotoProd
						EndIf
                    EndIf
			    EndIf
				If oFotoProd:cBMPFile <> cFotoProd
					ShowBitMap(oFotoProd, cFotoProd)
				EndIf
		
				oProduto:Refresh()
				oQuant:Refresh()
				oVlrUnit:Refresh()
				oVlrItem:Refresh()
				oTotItens:Refresh()
				oVlrTotal:Refresh()
				oDesconto:Refresh()  
			Endif	
		
			If (Empty(cEntrega) .OR. cEntrega == "2")  .AND.;
			  !(lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) //Não Imprime produto garantia no cupom vinculado 
			
				IFPegPDV(nHdlECF, @cPDV)
				
				If ! AllTrim(cPDV) == AllTrim(LJGetStation("PDV"))
					// "O Número de PDV do equipamento é diferente do cadastrado na estação." ### "Atenção"
					HELP(' ',1,'FRT019')
					// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
			     	nRet := 1
			    ElseIf !lEmitNFCe			
					If (Empty(cEntrega) .OR. cEntrega == "2")  .And. If(lMVLJPRDSV,(lImpOrc .And. !lIsPrdServ) .Or. !lImpOrc,.T.);
					 	.AND. (!lVPNewRegra .Or. Empty(cValePre))
						If !lAbreCup	//Item de reserva não abre Cupom Fiscal
							nRet 		:= IFAbreCup(nHdlECF,@cCliCGC,cCliente,cLojaCli , @lImpCpfNpj,nil,nil,nil,nVlrTotal)
							lFechaCup	:= .T.			
							lAbreCup	:= .T.
							lReserva	:= .F.
							lAbrirCupom := .T.
						EndIf
					Else
						lReserva	:=	.T.
					EndIf
				Endif				
			EndIf
			If Len(aItens) == 0 .AND. lOcioso
		        If !lTouch
					oTimer:DeActivate()				// Desabilita o Timer Temporariamente Para nao Atrapalhar o Processo
				Endif
					
				aReserva	:= {}
				lOcioso  	:= .F.															// Abriu um Cupom
				aParcOrc 	:= {}
				aParcOrcOld := {}
				aTEFPend 	:= {} 			
				aBckTEFMult := {}
	
				nVlrDescTot	:= 0														// VALOR DO DESCONTO
				nVlrPercTot	:= 0														// PERCENTUAL DE DESCONTO
				nVlrAcreTot	:= 0														// VALOR DO ACRESCIMO
				nVlrPercAcr := 0														// PERCENTUAL DO ACRESCIMO
				nVlrDescCPg	:= 0														// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)			
	
				lDescTotal	:= .F.														// Inicializa a variavel do desconto no total do cupom, caso seja concomitante
				lDescSE4	:= .F.														// Inicializa a variavel do desconto na condicao de pagamento
				lVerTEFPend := .F.
	
				If !lAltVend .AND. Empty(cVendLoja)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define o Vendedor como o padrao definido no parametro ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTamSX3  := Len(SA3->A3_COD)
					cVendLoja:= Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSX3),nTamSX3)
				EndIf
				If lOrc
					cVendLoja := FR271CAField(xOrc, "L1_VEND") 
					lAltVend  := .T.
					cVndLjAlt := cVendLoja
				EndIf

		        cCupom := ""
		        oCupom:refresh()
				If ExistBlock("FRTCLICHE")
					aFRTCliche := ExecBlock("FRTCLICHE", .F., .F., {cVendLoja})
                    For nCont := 1 to Len(aFRTCliche)
                    	ocupom:AppendText(aFRTCliche[nCont])
                    Next nCont
				Else
				    oCupom:AppendText(("") + chr(10) + chr(13))
					oCupom:AppendText((STR0002 + chr(10) + chr(13)))   // "        MICROSIGA SOFTWARE S.A.         "
					oCupom:AppendText((STR0003 + chr(10) + chr(13)))   // "    Av. Braz Leme, 1399 - São Paulo     "
					oCupom:AppendText((STR0004 + chr(10) + chr(13)))   // "          www.microsiga.com.br          "					
				EndIf  
				
			    If cPaisLoc == "MEX" .AND. IFPegCupom(nHdlECF, @cDoc) ==  0  
					oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+StrZero(Val(cDoc),TamSX3("L1_DOC")[1]) + chr(10) + chr(13)))	// "  PDV:" "   COD:"
			    ElseIf lEmitNFCe .AND. !lUseSat
						cDoc := "NFCe"
			    		oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+cDoc+ chr(10)+ chr(13))) // "  PDV:" "   COD:"
			    ElseIf lUseSat
						cDoc := cSiglaSat
			    		oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+cDoc+ chr(10)+ chr(13))) // "  PDV:" "   COD:"			    	
			    Else
			    	oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+StrZero(Val(cDoc)+1,TamSX3("L1_DOC")[1]) + chr(10)+ chr(13))) // "  PDV:" "   COD:"
			    EndIf  
			    
				oCupom:AppendText((FRT_SEPARATOR + chr(10) + chr(13)))
				If Empty(cReserva) .And. (!lVPNewRegra .Or. Empty(cValePre))
			   		oCupom:AppendText((PADC(STR0007,40) + chr(10) + chr(13)))	// "        C U P O M   F I S C A L         "
				Else                                                                         
					If cEntrega == "2" .And. (!lVPNewRegra .Or. Empty(cValePre))
				   		oCupom:AppendText((PADC(STR0007,40) + chr(10) + chr(13)))	// "        C U P O M   F I S C A L         "					
					Else
						oCupom:AppendText((PADC(STR0044,40) + chr(10) + chr(13)))	// "     C U P O M   N Ã O   F I S C A L    "
					Endif
				EndIf
	            oCupom:AppendText((chr(10) + chr(13)))
				oCupom:AppendText((STR0008)+ chr(10) + chr(13))								// "ITEM   CÓDIGO           DESCRIÇãO       "
				oCupom:AppendText((STR0009 + "("+cSimbCor+")" + chr(10) + chr(13)))        	// "      QTDxUNITARIO    ST     VALOR( SIMBOLO ) "
				oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
				oCupom:SetupdatesEnable(.T.)
				oCupom:GoEnd()
				cOrcam := CriaVar("L1_NUM")

				SL1->( DbSetOrder(1) )	//L1_FILIAL + L1_NUM
				
				// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
				nTent := 0

				/* CONSIDERA registros deletados para obter o numero do orcamento, pois se uma venda tivesse deletada(cancelada), 
				era possivel reutilizar essa numeracao, causando problema na subida da venda, ja que ela considera itens deletados */ 	
				SET DELETED OFF
				
				While SL1->( DbSeek(xFilial("SL1") + cOrcam) )
					If ++nTent > 20
						Final(STR0032) // "Impossivel gerar numero sequencial de orcamento correto."
					EndIf

					While (GetSX8Len() > nSaveSx8)
						ConfirmSx8()
					End
					
					// volta ao padrao do sistema, para que ignore registros deletados na consulta do SXE/SXF
					SET DELETED ON

					cOrcam := CriaVar("L1_NUM")

					// volta a considerar registros deletados na consulta, pois sera realizado um seek na SL1 	
					SET DELETED OFF
				End

 				// volta ao padrao do sistema, que é ignorar os registros deletados
				SET DELETED ON

				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Abertura do Cupom - Cria o SL1 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Se o cliente estiver vazio, coloca o cliente padrão
				If Empty(cCliente)
					nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
					cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
				EndIf
				
				If Empty(cLojaCli)
					nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
					cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
				EndIf
				
				If Empty(cVendLoja)
					nTamSXG   := Len(SA3->A3_COD)
					cVendLoja := Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSXG),nTamSXG)				
				Endif				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³Release 11.5 - Controle de Formularios 			     ³
				//³Obter o numero da série de acordo com o lote/controle ³
				//³de formulario escolhido no inicio da venda.           ³
				//³Paises:Chile/Colombia  - F1CHI	   			         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				If lCFolLocR5 										
					cSerieAux:= cSerieFo					
	 			Else	 				
	 				cSerieAux:= LjGetStation("SERIE")
	 			Endif
					
				aSL1 := {	{"L1_FILIAL"	, xFilial("SL1") 		}, ;
						  	{"L1_NUM"		, cOrcam				}, ;
						 	{"L1_EMISSAO"	, dDataBase				}, ;
						 	{"L1_DTLIM"		, dDataBase				}, ;
						 	{"L1_EMISNF"	, dDataBase				}, ;
						 	{"L1_SERIE"		, LJGetStation("SERIE")	}, ;
						 	{"L1_PDV"		, cPDV					}, ;
						 	{"L1_OPERADO"	, xNumCaixa()			}, ;
						 	{"L1_HORA"		, cHora					}, ;
						 	{"L1_CLIENTE"	, cCliente 				}, ;
						 	{"L1_LOJA"		, cLojaCli 				}, ;
						 	{"L1_VEND"		, cVendLoja				}, ;						 	
						 	{"L1_ESTACAO"	, cEstacao 				}, ;
						 	{"L1_SITUA"		, "01"					}  }	// "01" - Abertura do Cupom Nao Impressa
				
				If !lEmitNFCe		 	
					If Empty(AllTrim(LJGetStation("SERPDV")))
						IFPegSerie(nHdlECF, @cSerPDV)
						RecLock('SLG',.F.)
						REPLACE LG_SERPDV WITH cSerPDV
						SLG->(MsUnlock()) 
					EndIf
				EndIf
				
				Aadd(aSL1, {"L1_SERPDV",LJGetStation("SERPDV")})
						 	
				If SuperGetMv("MV_LJRGMID",,0) == 1 .OR. SuperGetMv("MV_LJRGMID",,0) == 2 	
					Aadd(aSL1,{"L1_MIDIA"  ,M->L1_MIDIA})									 						   						 	
				EndIf       
				
				If lOrc				
					AAdd(aSL1,{"L1_OPERACA", "C"})
					AAdd(aSL1,{"L1_NUMORIG", FR271CAField(xOrc, "L1_NUM"		)})
					AAdd(aSL1,{"L1_JUROS"  , FR271CAField(xOrc, "L1_JUROS"		)})
					AAdd(aSL1,{"L1_VLRTOT" , FR271CAField(xOrc, "L1_VLRTOT"		)})
					//campos referentes a Frete/Transporte
					AAdd(aSL1,{"L1_TRANSP"	, FR271CAField(xOrc, "L1_TRANSP"	)})
					If SL1->(ColumnPos('L1_VEICUL1')) > 0															
						AAdd(aSL1,{"L1_VEICUL1"	, FR271CAField(xOrc, "L1_VEICUL1"	)})
					EndIf
					
					AAdd(aSL1,{"L1_ENDCOB"	, FR271CAField(xOrc, "L1_ENDCOB"	)})
					AAdd(aSL1,{"L1_BAIRROC"	, FR271CAField(xOrc, "L1_BAIRROC"	)})
					AAdd(aSL1,{"L1_MUNC"	, FR271CAField(xOrc, "L1_MUNC"		)})
					AAdd(aSL1,{"L1_CEPC"	, FR271CAField(xOrc, "L1_CEPC"		)})
					AAdd(aSL1,{"L1_ESTC"	, FR271CAField(xOrc, "L1_ESTC"		)})
					AAdd(aSL1,{"L1_ENDENT"	, FR271CAField(xOrc, "L1_ENDENT"	)})
					AAdd(aSL1,{"L1_BAIRROE"	, FR271CAField(xOrc, "L1_BAIRROE"	)})
					AAdd(aSL1,{"L1_MUNE"	, FR271CAField(xOrc, "L1_MUNE"		)})
					AAdd(aSL1,{"L1_CEPE"	, FR271CAField(xOrc, "L1_CEPE"		)})
					AAdd(aSL1,{"L1_ESTE"	, FR271CAField(xOrc, "L1_ESTE"		)})
					//campos referentes a Frete / Dados Complementares
					AAdd(aSL1,{"L1_VOLUME"	, FR271CAField(xOrc, "L1_VOLUME"	)})
					AAdd(aSL1,{"L1_ESPECIE"	, FR271CAField(xOrc, "L1_ESPECIE"	)})
					AAdd(aSL1,{"L1_MARCA"	, FR271CAField(xOrc, "L1_MARCA"		)})
					AAdd(aSL1,{"L1_NUMERO"	, FR271CAField(xOrc, "L1_NUMERO"	)})
					AAdd(aSL1,{"L1_PLIQUI"	, FR271CAField(xOrc, "L1_PLIQUI"	)})
					AAdd(aSL1,{"L1_PBRUTO"	, FR271CAField(xOrc, "L1_PBRUTO"	)})
					AAdd(aSL1,{"L1_PLACA"	, FR271CAField(xOrc, "L1_PLACA"		)})
					AAdd(aSL1,{"L1_UFPLACA"	, FR271CAField(xOrc, "L1_UFPLACA"	)})
					//campos referentes a Frete/Valores
					AAdd(aSL1,{"L1_TPFRET"	, FR271CAField(xOrc, "L1_TPFRET"	)})
					AAdd(aSL1,{"L1_FRETE" 	, FR271CAField(xOrc, "L1_FRETE"		)})
					AAdd(aSL1,{"L1_SEGURO"	, FR271CAField(xOrc, "L1_SEGURO"	)})
					AAdd(aSL1,{"L1_DESPESA"	, FR271CAField(xOrc, "L1_DESPESA"	)})	
					AAdd(aSL1,{"L1_VEND2"	, FR271CAField(xOrc, "L1_VEND2"		)})
					
					AAdd(aSL1,{"L1_VALIPI"	, FR271CAField(xOrc, "L1_VALIPI"	)})
					
					If SL1->(ColumnPos("L1_CODMNEG")) > 0
						aAdd(aSL1,{"L1_CODMNEG", FR271CAField(xOrc, "L1_CODMNEG")})
					EndIf					
					
					aAdd(aSL1,{"L1_NUMORC", FR271CAField(xOrc, "L1_NUMORC")})
					
					cTpOrc := FR271CAField(xOrc, "L1_TPORC")

					If !lEmitNFCe .And. AllTrim(cTpOrc) == "E"
						cTpOrc := ""
					EndIf

					aAdd(aSL1,{"L1_TPORC", cTpOrc})
				EndIf

				//Campo adicionado pois o numero movimento (SLW) nao estava sendo gravado na SL1
				aAdd(aSL1,{"L1_NUMMOV",AllTrim(LjNumMov())})
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento dos campos de transferencia de portador e ³
				//³carteira automatico (FRA)                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaFecha .AND. lUsaTransf
					aAdd(aSL1,{"L1_TRCXGER",.T.})
				Else
					aAdd(aSL1,{"L1_TRCXGER",.F.})
				Endif

				If SL1->(FieldPos("L1_TREFETI")) > 0
					aAdd(aSL1,{"L1_TREFETI",.F.})
				Endif

				If cPaisLoc <> "BRA"
					Aadd(aSL1,{"L1_MOEDA"  ,nMoedaCor})	
					Aadd(aSL1,{"L1_TXMOEDA",nTaxaMoeda})
				EndIf	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Função para varrer os campos de usuario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOrc
					FR271ICmpP(aSL1,"SL1",xOrc,0)
				Endif
				FR271BGeraSL("SL1", aSL1, .T.)
				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
								
				IFPegPDV(nHdlECF, @cPDV)
				
				If !AllTrim(cPDV) == AllTrim(LJGetStation("PDV"))
					// "O Número de PDV do equipamento é diferente do cadastrado na estação." ### "Atenção"
					HELP(' ',1,'FRT019')
					// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
			     	nRet := 1
			    Else			
					If !lEmitNFCe
					    If (Empty(cEntrega) .OR. cEntrega == "2") .AND. !(lAbreCup) .AND. !(lAbrirCupom) .AND. ;
					    		If(lMVLJPRDSV,(lImpOrc .And. !lIsPrdServ) .Or. !lImpOrc,.T.) .AND.; //Item de reserva não abre Cupom Fiscal
								!(lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) .And. ;
								(!lVPNewRegra .Or. Empty(cValePre)) //Vale Presente nao pode imprimir no cupom fiscal
								
								nRet := IFAbreCup(nHdlECF,@cCliCGC,cCliente,cLojaCli,@lImpCpfNpj,nil,nil,nil,nVlrTotal)
								lFechaCup := .T.			
								lAbreCup  := .T.
								lReserva  := .F.
						Else
							If cEntrega == "2" .AND. !(lAbreCup) .AND. !(lAbrirCupom) .And. ; 
								If(lMVLJPRDSV,(lImpOrc .And. !lIsPrdServ) .Or. !lImpOrc,.T.) .AND.; //Item de Servico (RPS) de orcamento importado nao abre Cupom Fiscal	
								!(lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) .And. ;
								(!lVPNewRegra .Or. Empty(cValePre)) //Vale Presente nao pode imprimir no cupom fiscal
											
								nRet := IFAbreCup(nHdlECF,@cCliCGC,cCliente,cLojaCli,@lImpCpfNpj,nil,nil,nil,nVlrTotal)								
								lFechaCup := .T.			
								lAbreCup  := .T.
								lAbrirCupom := .T.
							Endif						
						EndIf
					EndIf
					
					//Retorna o Contador de Cupom Fiscal
					If lLjNfPafEcf .AND. nRet == 0
						nRet := IFStatus(nHdlECF, "35", @cContDoc)
					EndIf
					
				EndIf	
							
				If nRet <> 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar a Abertura do Cupom ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FR271BCancela(.T., .F., .F.)					// Deleta Somente o SL1
		
					HELP(" ",1,"FRT001")	// "Não foi possível realizar a abertura do cupom fiscal. Operação não efetuada."
					lOcioso := .T.															// Cancelei a Abertura do Cupom

					nVlrMerc := 0
					nTotItens:= 0
					nVlrTotal:= 0
					nVlrBruto:= 0
					nValIPI  := 0

					cReserva 	:= ""
					lAbreCup	:= .F.
					lAbrirCupom := .F.
	
					If CrdxInt()
	  					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 	Fr271ICrdSet( @cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)
					EndIf   								
	
					If !lTouch
						oVlrTotal:Refresh()
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicializa as variáveis de Templates                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					uCliTPL := Nil     
					uProdTPL:= Nil
					cCodConv:= "" 
					cLojConv:= "" 
					cNumCartConv := ""
					FR271AInitIT(	.T., 		@lF7, 		@cCodProd, 	@cProduto,;
									@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;	
									@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;	
									@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;		
									@cLojaCli)
						
						
					If !lTouch
						If oFotoProd:cBMPFile <> "LOJAWIN"
							ShowBitMap(oFotoProd, "LOJAWIN")
						EndIf
						oTimer:Activate()							// Habilita o Timer Novamente
					EndIF
					Return(lRet)
				EndIf
		
				lConsulta := .F.	
				If lAbrirCupom .OR. ( cPaisLoc == "BRA" .AND. (Empty(cDoc) .OR. Val(cDoc) == 0) ) .Or. lEmitNFCE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   		//³Release 11.5 - Controle de Formularios 			     ³
					//³Utilizar o numero do formulario informado	 		 ³
					//³pelo usuario no inicio da venda. 					 ³
					//³Paises:Chile/Colombia - F1CHI	   			         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
					If lCFolLocR5
						cDoc := cDocFo
					EndIf
					If !lEmitNFCe
						FR271Hora(.T., lConsulta, @oHora, @cHora, @oDoc, @cDoc)	// Atualiza a Hora e o Numero do Cupom

						//Valida possivel erro ao retornar o numero do cupom, nao registra o item. Zera variaveis para nova tentativa do usuário de registrar o primeito item.
						If cPaisLoc == "BRA" .AND. (Empty(cDoc) .OR. Val(cDoc) == 0)
							MsgStop(STR0065)	//"Nao foi possivel retornar o numero do Cupom. Verifique a impressora fiscal !"
							lCup := .F.
							nRet := 1
							lOcioso := .T.
						EndIf
					EndIf

					aSL1 := { 	{"L1_DOC"		, cDoc },;
							 	{"L1_SITUA"		, "02" }}					// "02" - Impresso a Abertura do Cupom
				Else
					aSL1 := {	{"L1_SITUA"	, "02" }}
				EndIf
				
				// Atualiza Contador de Cupom Fiscal
				If SL1->(FieldPos("L1_CONTDOC")) > 0
					Aadd(aSL1,{ "L1_CONTDOC" , cContDoc } )					
				EndIf  
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o campo L1_CGCCLI caso trabalhe com ³
				//³Nota Fiscal Paulista                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If LjAnalisaLeg(30)[1]
					If lCgcCli
						Aadd(aSL1,{ "L1_CGCCLI" , cCliCGC } )
						cCliCGC	:= ""											// Caso abriu o cupom limpa a varivavel de CGC 	
					EndIf
    			EndIf				
				
				FR271BGeraSL("SL1", aSL1)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Informar a Retaguarda o Status Atual do Check-Out. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FR271BGerSLI(cEstacao	, 	"CON"		,	"V|"	+ 	Alltrim(cPDV) 					+ ;
							"|" 	+ AllTrim(cDoc)	+	"|"		+	AllTrim(Str(nVlrTotal,14,2)	)	+ ;
							"|"		+ AllTrim(Str(nTotItens))	, 	"SOBREPOE")
		
				If !lTouch
					oTimer:Activate()								// Habilita o Timer Novamente
				Endif	
		
			EndIf

			//Verifica se é um novo orçamento para poder somar os valores de frete/despesas e segura para uma unica venda
			//porem somente para o 1º item.
			If lNewImpOrc
				nVlrFrete		:= FR271CAField(xOrc, "L1_FRETE"	)
				nVlrSeguro		:= FR271CAField(xOrc, "L1_SEGURO"	)
				nVlrDespesa	:= FR271CAField(xOrc, "L1_DESPESA"	)

				
				aSL1 := {	{"L1_FRETE"	, SL1->L1_FRETE	+	nVlrFrete		},;
						  	{"L1_SEGURO"	, SL1->L1_SEGURO	+	nVlrSeguro		},;
							{"L1_DESPESA"	, SL1->L1_DESPESA	+	nVlrDespesa	}}						  	

				FR271BGeraSL("SL1", aSL1)
			EndIf
	
			If SL1->L1_TPFRET $ "C|F"			
				nVlrFrete 	:= SL1->L1_FRETE
				nVlrSeguro  := SL1->L1_SEGURO
				nVlrDespesa := SL1->L1_DESPESA
				nTotalOrc   := SL1->L1_VLRTOT 
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Nr. do Orc de origem caso a venda tenha iniciado em AutoAtendimento. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOrc .And. Empty(SL1->L1_NUMORIG)
				aSL1 := {	{"L1_OPERACA"	, "C" 							},;
						  	{"L1_NUMORIG"	, FR271CAField(xOrc, "L1_NUM")	},;
							{"L1_CLIENTE"	, cCliente						},;						  	
						  	{"L1_LOJA"		, cLojaCli						},;
						  	{"L1_FRETE"		, FR271CAField(xOrc, "L1_FRETE")}}
				FR271BGeraSL("SL1", aSL1)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Situacoes do _SITUA                              ³
			//³ "  " - Base Errada, Registro Ignorado.           ³
			//³ "00" - Venda Efetuada com Sucesso                ³ 
			//³ "01" - Abertura do Cupom Nao Impressa            ³
			//³ "02" - Impresso a Abertura do Cupom              ³
			//³ "03" - Item Nao Impresso                         ³
			//³ "04" - Impresso o Item                           ³
			//³ "05" - Solicitado o Cancelamento do Item         ³
			//³ "06" - Item Cancelado                            ³
			//³ "07" - Solicitado o Cancelamento do Cupom        ³
			//³ "08" - Cupom Cancelado                           ³
			//³ "09" - Encerrado SL1 (Nao gerado SL4)            ³
			//³ "10" - Encerrado a Venda                         ³
			//³        Pode nao ter sido impresso o cupom        ³
			//³ "TX" - Foi Enviado ao Server                     ³
			//³ "RX" - Foi Recebido Pelo Server                  ³
			//³ "OK" - Foi Processado no Server                  ³
			//³        Enviar um OK ao Client que foi Processado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio - Tam - Descricao                    ³
			//³      1 -   3 - Item                         ³
			//³      5 -  13 - Codigo do Produto            ³
			//³     19 -  21 - Descricao do Produto         ³
			//³      1 -   9 - Quantidade                   ³
			//³     10 -   1 - Multiplicador ("x")          ³
			//³     11 -   9 - Valor Unitario               ³
			//³     20 -   6 - Aliquota de ICM              ³
			//³     26 -   1 - Simbolo de Porcentagem ("%") ³
			//³     27 -  13 - Valor Total do Item          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuant     := PadL(AllTrim(Trans(nQuant, If(nQuant-Int(nQuant)==0, "999999999", PesqPictQt("L2_QUANT")))),9)
			cVlrUnit   := PadR(AllTrim(Trans(nVlrUnit+If(cPaisLoc<>"BRA",(nTotImp/nQuant),0),PesqPict("SBI", "BI_PRV",9,nMoedaCor))),9)
			cVlrItem   := Transform(nVlrItem,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))
		    cVlrPercIT := Transform(nVlrPercIT,"@R 99.99%")
			cValIPIIT  := Transform(nValIPIIT,PesqPict("SL2", "L2_VALIPI", 13,nMoedaCor))
			cVlIcmRet  := Transform(nVlIcmRet,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
			cBAKDesPro := ""
			
			If lLjNfPafEcf .And. !(!Empty(cReserva) .AND. cEntrega <> "2") //item de reserva
				/*				
					CONVÊNIO ICMS 25, DE 8 DE ABRIL DE 2016
					#código CEST#NCM/SH#descrição do item  
				*/
				If !Empty(AllTrim(cCEST)) 
					If lPosIpi .And. !Empty(AllTrim(SBI->BI_POSIPI))
						cBAKDesPro	:= cProduto
						cProduto	:= "#" + AllTrim(cCEST) + "#" + AllTrim(SBI->BI_POSIPI) + "#" +  AllTrim(cProduto)
						cProduto	:= Substr(cProduto,1,200)
					Else
						Conout("Para impressao do código CEST é necessário ter o campo BI_POSIPI ou preenche-lo")
					EndIf
				EndIf
			EndIf

			/* P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. */
			aAux := { 	FR271HLastIT(@aItens)+1	, cCodProd	, cCodBar	, cProduto, ;
						cQuant        	, cVlrUnit	, cAliquota	, cVlrItem, ;
						cVlrPercIT		, cValIPIIT	, lLeitor	, cVlIcmRet }

			lGeRes := .F.
			If lGE .AND. (SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) .And. cVendido <> "N"
				lGeRes := .T.
			EndIf
			
			If !Empty(cReserva) .AND. cEntrega <> "2" //item de reserva
				AAdd(aReserva, { 	FR271HLastIT(	@aItens)+1	, cCodProd	, cCodBar	, cProduto, ;
													cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
													cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet } )
			EndIf
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona os dados do Produto Garantia estendida ao array³
			//³aReserva e ao array aProdGar para realizar a            ³
			//³contabilização do produto no momento da impressão do    ³
			//³Cupom Não Fiscal.                                       ³
			// [1] = Codigo do Produto Garantia 												  ³
			// [2] = Quantidade do prod Garantia												  ³ 
			// [3] = Valor unitario do produto garantia											  ³
			// [4] = Usado para guardar o quanto esta garantia representa no VALOR da venda       ³
			// [5] = Usado para guardar o quanto esta garantia representa no desconto na venda    ³
			// [6] = Usado para guardar o quanto esta garantia representa no acredcimo na venda   ³
			//
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			If lGE .AND. (SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) .And. cVendido <> "N"
				AAdd(aReserva, { 	FR271HLastIT(	@aItens)+1	, cCodProd	, cCodBar	, cProduto, ;
									cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
									cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet } )
			    
			    AAdd(aProdGar,{cCodProd,cQuant,cVlrUnit,0,0,0})
			EndIf            
			
			If lFRTCODB2t
				aAdd(aAux,uProdTPL)	
				aAdd(aAux,uCliTPL)	
				
				aAux := ExecTemplate( "FRTCODB2",	.F.,	.F.,	{aAux, uProdTPL, uCliTPL } )
				cCodProd := Padr(aAux[2], nTB1COD)
				cCodBar  := Padr(aAux[3], nTB1CODBAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³valorizando variaveis do tipo STATIC³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType( aAux[13] ) == "A"
					uProdTPL := aClone(aAux[13])
				Else
					uProdTPL := aAux[13]
				Endif
				If ValType( aAux[14] ) == "A"
					uCliTPL  := aClone(aAux[14])
				Else
					uCliTPL  := aAux[14]
				Endif
			EndIf
			If ExistBlock("FRTCODB2")
				aAux := ExecBlock( "FRTCODB2", .F., .F., aAux )
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)
			EndIf
		
			// Montar aItens (Ultimo Elemento eh Cancelado)
			AAdd(aItens, { FR271HLastIT(@aItens)+1, cCodProd , cCodBar , cProduto, ;
			               nQuant        , nVlrUnit 					, nVlrItem, nVlrDescIT								, ;
			               cAliquota     , nValIPIIT					, .F.     , IIf(SF4->F4_INCSOL == 'S',nVlIcmRet,0)	, ;
			               nDedIcmsIt    , Fr271AItImp(aItens,cEntrega,lGeRes) , .F. 	  , lImpIncl } )
		
			aAux2 := aAux
			
			//Altero a descrição do produto, pois sendo PAF+CEST há
			// dificuldade de visualização do nome do produto no cupom virtual
			If ! Empty(cBAKDesPro)
				aAux2[4] := cBAKDesPro
			EndIf
			
			cLocal  := SBI->BI_LOCPAD
			cTabela := SBI->BI_TABELA
			If lOrc
				cLocal  := FR271CAField(xOrc, "L2_LOCAL",  nNumItem)
				cTabela := FR271CAField(xOrc, "L2_TABELA", nNumItem)
			EndIf
				
			//Protecao para evitar erro de desconto 100% ** Necessário adicionar log para identificar quando ocorrer
			If nVlrPercIT > 99.99			
				nVlrPercIT := 99.99									
				
				//Protecao para evitar item com valor zerado quando desconto 100% (cenario ocorre com integracao Drogaria CONDROFLEX)
				If nVlrUnit  <= 0
					nVlrUnit := 0.1
				EndIf
				
				If nVlrItem  <= 0
					nVlrItem := 0.1
				EndIf				
			Endif			
            			
			If nAuxVlrU <= 0 
					nAuxVlrU := nVlrUnit - If(cPaisLoc=="BRA",(nVlrDescIT / nQuant),0)
			EndIf
			If nAuxVlrI <= 0
				nAuxVlrI := nVlrItem
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Registrando o Item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSL2 := {	{"L2_FILIAL"	,	xFilial("SL2")	},;
					 	{"L2_NUM"		,	cOrcam			},;
					 	{"L2_PRODUTO"	,	cCodProd		},;
					 	{"L2_ITEM"		,	FR271BPegaIT(FR271HLastIT(@aItens))	},;
					 	{"L2_DESCRI"	,	cProduto 		},;
					 	{"L2_QUANT"		,	nQuant			},;
					 	{"L2_VRUNIT"	,	nAuxVlrU		},; 	// Para paises diferentes de Brasil o valor 
					 	{"L2_VLRITEM"	,   nAuxVlrI		},;		// unitario ja foi acertado para a impressao   
		 			 	{"L2_DESC"		,	nVlrPercIT		},; 	// correta no cupom.
					 	{"L2_VALDESC"	,	nVlrDescIT		},;
					 	{"L2_VALIPI"	,	nValIPIIT		},;
					 	{"L2_UM"		,	cUnidade		},;
					 	{"L2_VENDIDO"	,	"S"				},;
					 	{"L2_TES"		,	cTES			},;
					 	{"L2_CF"		,	cCF				},;
					 	{"L2_DOC"		,	SL1->L1_DOC		},;
					 	{"L2_SERIE"		,	SL1->L1_SERIE	},;
					 	{"L2_PDV"		,	SL1->L1_PDV		},;
					 	{"L2_VEND"		,	Frt271aVendRet(lOrc,xOrc,nNumItem,cVendLoja) },;
					 	{"L2_TABELA"	,	cTabela			},;
					 	{"L2_EMISSAO"	,	SL1->L1_EMISSAO	},;
					 	{"L2_GRADE"		,	"N"            	},;
					 	{"L2_BCONTA"	,	cBCONTA  		},;				// Recebimento de Conta
					 	{"L2_SITUA"		,	"03"   			} }				// "03" - Item Nao Impresso
					 	
			aAdd( aSL2, {"L2_VDMOST", aMostruario[1]})			
			aAdd( aSL2, {"L2_VDOBS", aMostruario[2]})

			//desoneração icms
			If lICMDeson
				aAdd( aSL2, {"L2_MOTDICM", cMOTDICM } )
				aAdd( aSL2, { "L2_DESCICM", nDESCICM } )
			EndIf	

	
			aMostruario := {"N",""}
			
			If lLjNfPafEcf
				aAdd(aSL2, {'L2_SERPDV', LJGetStation("SERPDV")})
				
				If Empty( AllTrim( SBI->BI_IPPT )) .Or. Empty( AllTrim( SBI->BI_IAT ))
					Conout(" Orcamento [" + cOrcam + "] - Campo BI_IPPT/BI_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão ")
					LjGrvLog( cOrcam ," Campo BI_IPPT/BI_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão")
					
					RecLock("SBI",.F.)
					
					If Empty( AllTrim( SBI->BI_IPPT ))
						REPLACE SBI->BI_IPPT WITH "T"
					EndIf
					
					REPLACE SBI->BI_IAT	WITH IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
					SB1->(MsUnlock())
				EndIf
				
				If SL2->(ColumnPos("L2_IAT")) > 0
					aAdd( aSL2, { "L2_IAT"		, IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" ) })
				EndIf				
				
				If SL2->(ColumnPos("L2_IPPT")) > 0
					aAdd( aSL2, { "L2_IPPT"		, SBI->BI_IPPT })
				EndIf

				If SL2->(ColumnPos("L2_DECQTD")) > 0
					aAdd( aSL2, { "L2_DECQTD", 	TamSX3("L2_QUANT")[2] } )
				EndIf
				
				If SL2->(ColumnPos("L2_DECVLU")) > 0
					aAdd( aSL2, { "L2_DECVLU", 	TamSX3("L2_VRUNIT")[2] } )
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informacoes de Estoque/Custos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aSL2, {"L2_LOCAL"		,	cLocal	})
			aAdd( aSL2, {"L2_LOTECTL"	,	cLote	})
			aAdd( aSL2, {"L2_NLOTE"		,	cSubLote})			
			aAdd( aSL2,	{"L2_LOCALIZ"	,	cNumLoc	})			
			aAdd( aSL2,	{"L2_NSERIE"	,	cNSerie	})			
			aAdd( aSL2,	{"L2_DTVALID"	,	dVldLote})		
            
	   		If lGE 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona o numero do produto de garantia estendida e o numero de série no produto.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   		aAdd( aSL2,	{"L2_GARANT"	,	cGarant 	})				
		   		aAdd( aSL2,	{"L2_VLGAPRO"	,	nVlgApro	})
		   		
		   		If SL2->( ColumnPos( "L2_ITEMGAR" ) > 0 )
		   			aAdd( aSL2,	{"L2_ITEMGAR"	,	cItemGar	})
		   		EndIf
		   		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a Função para alimentar o array com os produtos que contem garantia estendida ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			EndIf            
			
			If Len(aAlqLeiTr) == 4 .OR. !(cMvFisAlCT == "3" .AND. cMvFisCTrb == "2") 
    		    //Valor de Imposto NCM/NBS
               If lL2TotImp
                   aAdd( aSL2, { "L2_TOTIMP",noRound((nVlrItem * aAlqLeiTr[1])/100 ,nDecimais)} )
               EndIf
    
               //gravacao dos valores lei dos impostos por ente tributario
               If  lCpoImpEnt
                   aAdd( aSL2, { "L2_TOTFED",noRound((nVlrItem * aAlqLeiTr[2])/100 ,nDecimais)} )
                   aAdd( aSL2, { "L2_TOTEST",noRound((nVlrItem * aAlqLeiTr[3])/100 ,nDecimais)} )
                   aAdd( aSL2, { "L2_TOTMUN",noRound((nVlrItem * aAlqLeiTr[4])/100 ,nDecimais)} )
               EndIf 
           ElseIf Len(aAlqLeiTr) == 8 //Por conta de alteração feita pelo Fiscal nos fontes FISXFUN e SPEDNFE, caso o array aAlqLeiTr contenha posição da 5 a 8, logo nestas posicoes ja estiram os valores dos impostos calculados      			
    			If lL2TotImp //Valor de Imposto NCM/NBS
    				aAdd( aSL2, { "L2_TOTIMP", aAlqLeiTr[5]} )
    			EndIf
        			
    			If lCpoImpEnt //Gravacao dos valores lei dos impostos por ente tributario 
    				aAdd( aSL2, { "L2_TOTFED", aAlqLeiTr[6]} )
    				aAdd( aSL2, { "L2_TOTEST", aAlqLeiTr[7]} )
    				aAdd( aSL2, { "L2_TOTMUN", aAlqLeiTr[8]} )
    			EndIf    		     		
    		EndIf	
			
			If lL2CodBar
				aAdd( aSL2, { "L2_CODBAR", cCodBar} )
			EndIf
			
			//Campos para NFC-e ( alguns também são usados para o PAF)
			If SL2->(ColumnPos("L2_POSIPI")) > 0
				aAdd( aSL2, { "L2_POSIPI", SBI->BI_POSIPI} )
			EndIf

			If lL2Origem
				aAdd( aSL2, { "L2_ORIGEM", SBI->BI_ORIGEM} )
			EndIf

			//Regra utilizada no MatxFis para verificar a modalidade da base de calculo ()
			If lL2Modbc
				aAdd( aSL2, { "L2_MODBC", cModBc } )
			EndIf
			
			If lL2CEST
				Aadd( aSL2, { "L2_CEST", cCEST} )
			EndIf

			If lEmitNFCe
				aAdd( aSL2, { "L2_VALICM"	, nValICMS	} )
				aAdd( aSL2, { "L2_BASEICM"	, nBaseICMS } )
				aAdd( aSL2, { "L2_BRICMS"	, nBRICMS	} )
				aAdd( aSL2, { "L2_ICMSRET"	, nVlIcmRet	} )
			EndIf
			
			If lL2FECP
				aAdd( aSL2, { "L2_VALFECP"	, nValFECP } )
				aAdd( aSL2, { "L2_ALQFECP"	, nAlqFECP } )
			EndIf
			
			If lL2FECPST
                aAdd( aSL2, { "L2_ALQFCST",  nValFECPST } )
                aAdd( aSL2, { "L2_VFECPST",  nAlqFECPST } )
			EndIf

			If lL2CmpISS	// campos para gravacao do ISSQN
				aAdd( aSL2, {"L2_CODISS"	, aISSQN[1]} )
				aAdd( aSL2, {"L2_BASEISS"	, aISSQN[2]} )
				aAdd( aSL2, {"L2_ALIQISS"	, aISSQN[3]} )
				If lL2CNAE
					aAdd( aSL2, {"L2_CNAE"	, aISSQN[5]} )
				EndIf
			EndIf

			If lOrc
				If SL2->(ColumnPos("L2_FDTENTR")) > 0
					aAdd( aSL2, { "L2_FDTENTR", FR271CAField( xOrc, "L2_FDTENTR", nNumItem ) } )
				EndIf

				If SL2->(ColumnPos("L2_FDTMONT")) > 0
					aAdd( aSL2, { "L2_FDTMONT", FR271CAField( xOrc, "L2_FDTMONT", nNumItem ) } )
				EndIf		
				If SL2->(ColumnPos("L2_TURNO")) > 0
					aAdd( aSL2, { "L2_TURNO", FR271CAField( xOrc, "L2_TURNO", nNumItem ) } )
				EndIf
				If lCAT83
					aAdd( aSL2, { "L2_CODLAN", FR271CAField( xOrc, "L2_CODLAN", nNumItem ) } )
				EndIf
				If nVlProp > 0 .AND. SL2->(ColumnPos("L2_DESCORC")) > 0
					aAdd( aSL2, { "L2_DESCORC", nVlProp } )
				EndIf

				//Atualiza os campos da Lista de Presentes caso existam
				If SL2->(ColumnPos("L2_CODLPRE")) > 0
					aAdd( aSL2, { "L2_CODLPRE", FR271CAField( xOrc, "L2_CODLPRE", nNumItem ) } )
				EndIf

				If SL2->(ColumnPos("L2_ITLPRE")) > 0
					aAdd( aSL2, { "L2_ITLPRE", FR271CAField( xOrc, "L2_ITLPRE", nNumItem ) } )
				EndIf
				
				If SL2->(ColumnPos("L2_MSGLPRE")) > 0
					aAdd( aSL2, { "L2_MSGLPRE", FR271CAField( xOrc, "L2_MSGLPRE", nNumItem ) } )
				EndIf
				
				If SL2->(ColumnPos("L2_REVLPRE")) > 0
					aAdd( aSL2, { "L2_REVLPRE", FR271CAField( xOrc, "L2_REVLPRE", nNumItem ) } )
				EndIf
				
				If SL2->(ColumnPos("L2_MSMLPRE")) > 0
					aAdd( aSL2, { "L2_MSMLPRE", FR271CAField( xOrc, "L2_MSMLPRE", nNumItem ) } )
				EndIf
				
				If SL2->(ColumnPos("L2_REMLPRE")) > 0
					aAdd( aSL2, { "L2_REMLPRE", FR271CAField( xOrc, "L2_REMLPRE", nNumItem ) } )
				EndIf
				
				If SL2->(ColumnPos("L2_CODCONT")) > 0
					aAdd( aSL2, { "L2_CODCONT", FR271CAField( xOrc, "L2_CODCONT", nNumItem ) } )
				EndIf
				
				AAdd(aSL2,{"L2_VALIPI"	, FR271CAField(xOrc, "L2_VALIPI", nNumItem	)})
				
				If SL2->( ColumnPos("L2_VALACRS")) > 0
					Aadd( aSL2,	{"L2_VALACRS", FR271CAField( xOrc, "L2_VALACRS", nNumItem ) } )
	        	EndIf
			Else
				If lCAT83
					aAdd( aSL2, { "L2_CODLAN", SF4->F4_CODLAN } )
				EndIf					
			EndIf
			
			If SL2->(ColumnPos("L2_SITTRIB")) > 0 .AND. !Empty(cAliquota)
				cAliqAux := cAliquota
				
				Lj7AjustSt( @cAliqAux )

				Aadd( aSL2,	{"L2_SITTRIB",	cAliqAux} )
	        EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Função para varrer os campos de usuario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOrc
				FR271ICmpP(aSL2, "SL2", xOrc, nNumItem)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma todas as parcelas para identificar Acrescimo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValor += nVlrItem
			Endif
			
			
			LjLogFront("FRT271A - Valor acumulado",nValor)
			LjLogFront("FRT271A - Desconto no item",nVlrDescIT) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os campos referente a  multiorcamentos e reserva ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOrc
		        Aadd(aSL2,{"L2_ENTREGA"	,	cEntrega	})   // Tipo de Entrega 1=Retira Posterior; 2=Retira; 3=Entrega
		        Aadd(aSL2,{"L2_RESERVA"	,	cReserva	})   // Numero da Reserva realizado no Venda Assistida
	    	    Aadd(aSL2,{"L2_LOJARES"	,	cLojaRes	})   // Numero da Reserva realizado no Venda Assistida
		        Aadd(aSL2,{"L2_NUMORIG"	,	cNumOrc		})   // Numero do Orçamento de origem na retaguarda
	  		EndIf
		    
	  		
	  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Cartaoo Fidelidade³
			//³Recarga 							³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If lLjcFid
				If FA271aGrcf()
					aAdd( aSL2, { "L2_PRODUTO", 	cCodProd } ) 
					aAdd( aSL2, { "L2_NUMCFID", 	LaFunhGet(1) } ) 
					aAdd( aSL2, { "L2_DTSDFID", 	LaFunhGet(2) } ) 
					aAdd( aSL2, { "L2_VLRCFID", 	LaFunhGet(3) } )					
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Recarga do cartao fidelidade processada: ³				
					//³B - Via processo batch (LJGRVBATCH)      ³
					//³W - Via WebService(LJCCARFID) 		    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ													
					If Ca280CkWs ()                                          
						//W - Via WebService(LJCCARFID)                 
						aAdd( aSL2, { "L2_PROCFID", "W" } )										
						Fa271aSpfw (.T.)					
					Else
						//B - Via processo batch (LJGRVBATCH)       
						aAdd( aSL2, { "L2_PROCFID", "B" } )				
						Fa271aSpfw (.F.)
					EndIf				
				EndIf
			EndIf			
			
					    
		    If cPaisLoc <> "BRA"  
				//Encontra no aImpsSL2 a posicao correspondente ao item da venda...
		    	nI :=  Len(aItens)
		    	
		        For nY := 1 to Len(aImpsSL2[nI][3])
		        	Aadd(aSL2,{aImpsSL2[nI][3][nY][6],aImpsSL2[nI][3][nY][4]})   //Valor do imposto
	                Aadd(aSL2,{aImpsSL2[nI][3][nY][7],aImpsSL2[nI][3][nY][3]})   //Base do imposto         
	                Aadd(aSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nY][7],10,1),aImpsSL2[nI][3][nY][2]})   //Aliquota do imposto                           
					//Eh abatido o valor dos impostos pois o item foi gravado com base
					//na variavel nVlrItem, que teve os impostos somadas para a
					//exibicao do total na tela...
					If SubStr(aImpsSL2[nI][03][nY][05],2,1) == "1"
						aSL2[Ascan(aSL2,{|x| Trim(x[1]) == "L2_VLRITEM"})][2] -= aImpsSL2[nI][3][nY][4]
					EndIf 
	            Next nY   
	
	           	aImpsSL2[nI][4]  := aSL2[4][2]
	           	aImpsSL2[nI][5]  := .F.           
	           	aImpsSL2[nI][6]  := nQuant				
	           	aImpsSL2[nI][7]  := nVlrUnit				   	           					                 					           	           	
			   	Aadd(aSL2,{"L2_PRCTAB",	nVlrUnit+(nVlrDescIT / nQuant)})
			   	
				FR271ITotVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda	, @aTotVen	,; 
							@aMoeda		)
				FR271ISimACols(	cCodProd,	nQuant												, nVlrUnit	, cTES		,;
								cCF     ,  aSL2[Ascan(aSL2	, {|x| Trim(x[1])=="L2_ITEM"})][2]	, Nil		, @aCols	,;
							 	@aHeader)
				AAdd(	aImpsProd,	aClone(aImpsSL2[nI] ) )
			Else
				Aadd( aSL2, {"L2_PRCTAB",	nVlrUnit} )

				If lL2ValISS				
					Aadd( aSL2, {"L2_VALISS",	aISSQN[4]} )
					If lMVLJPRDSV
						If Len(aReserva) > 0  //Se tiver itens de reserva, limpa o array "aItensServ" para desconsiderar a geracao dos itens de servico em NF separada (RPS)
							aItensServ := {}
							//Somente considera ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas, se a venda nao for com "Reserva"
						ElseIf lImpOrc .And. lIsPrdServ
							//Somente adiciona os Itens de "servico" no array "aItensServ" no momento da importacao de orcamento
							AAdd(aItensServ, {	Len(aItens)	, cCodProd	, cCodBar	, cProduto	,;
												cQuant		, cVlrUnit	, cAliquota	, nVlrItem	,;
												cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet } )
						EndIf
					EndIf
				EndIf				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava o valor do PIS, Cofins e CSLL somente se o campo existir³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SL2->( ColumnPos( "L2_VALPIS" ) ) > 0 
					Aadd( aSL2, {"L2_VALPIS",	nValPis	} )
					Aadd( aSL2,	{"L2_VALCOFI",	nValCof	} )
					Aadd( aSL2,	{"L2_VALCSLL",	nValCsl	} )
					Aadd( aSL2,	{"L2_BASEPS2",	nBasePS2} )
					Aadd( aSL2,	{"L2_VALPS2",	nValPS2 } )
					Aadd( aSL2,	{"L2_ALIQPS2",	nAliqPS2} )
					Aadd( aSL2,	{"L2_BASECF2",	nBaseCF2} )
					Aadd( aSL2,	{"L2_VALCF2",	nValCF2 } )
					Aadd( aSL2,	{"L2_ALIQCF2",	nAliqCF2} )
				Endif
	        EndIf
	        If SL2->( ColumnPos("L2_ITEMSD1")) > 0
				Aadd( aSL2,	{"L2_ITEMSD1",	"000000"} )	        	
	        EndIf
					 
	        If SL2->( ColumnPos("L2_VALEPRE")) > 0 .AND. !Empty( cValePre )
				Aadd( aSL2,	{"L2_VALEPRE",	cValePre} )
				
				If lVPNewRegra
					//Adiciona o Item de "Vale Presente" no array aItensVP
					AAdd(aItensVP, { FR271HLastIT(@aItens)+1	, cCodProd	, cCodBar	, cProduto, ;
													cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
													cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet } )
				EndIf
	        EndIf
	        
			FR271BGeraSL("SL2", aSL2, .T. 	)
			
			If lVPNewRegra
		        If !Empty( cValePre )
					Lj7VPVdaVP(1) //Indica que eh venda de "Vale Presente"
		        Else
		        	Lj7VPVdaVP(2) //Indica que eh venda de produto que nao eh "Vale Presente"
		        EndIf
		   	EndIf
			
			If lOrc
				//Calcula os valores de Frete/Seguro/Despesa proporcional no item.
				If nLastItem > 1
					If lLj7Arred
	   					nVlrFrete	:= Lj7Arred( 3, 3, LjxPropItem(nTotalOrc, nVlrFrete,  .T.) )
						nVlrSeguro	:= Lj7Arred( 3, 3, LjxPropItem(nTotalOrc, nVlrSeguro, .T.) )
						nVlrDespesa	:= Lj7Arred( 3, 3, LjxPropItem(nTotalOrc, nVlrDespesa,.T.) )
					Else
						nVlrFrete	:= NoRound( LjxPropItem(nTotalOrc, nVlrFrete,  .T. ) , nDecimais )
						nVlrSeguro	:= NoRound( LjxPropItem(nTotalOrc, nVlrSeguro, .T. ) , nDecimais )
						nVlrDespesa	:= NoRound( LjxPropItem(nTotalOrc, nVlrDespesa,.T. ) , nDecimais )					
					EndIf
				EndIf
				
				aSL2 := { { "L2_VALFRE" , nVlrFrete	  },;
				          { "L2_SEGURO" , nVlrSeguro  },;
				          { "L2_DESPESA", nVlrDespesa } } 
				
				FR271BGeraSL("SL2", aSL2) 
			EndIf 
			
			aSL1 := {{"L1_SITUA" ,	"03"} }	// "03" - Item Nao Impresso
			FR271BGeraSL( "SL1", aSL1 )
			nDec := TamSX3("L2_QUANT")[2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Tratamento dos Dados Que Serao Impressos no Cupom. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				If SF4->F4_INCSOL == 'S' 			
					aAux := {	cCodProd, cCodBar, cProduto, nQuant, ;
								nVlrUnit + (nValIPIIT / nQuant) + (nVlIcmRet / nQuant), nVlrDescIT, cAliquota, ;
								nVlrItem + nVlrDescIT + nValIPIIT + nVlIcmRet, lOrc, xOrc, nNumItem, ;
								cUnidade	}
				Else
					aAux := {	cCodProd, cCodBar, cProduto, nQuant, ;
								nVlrUnit + (nValIPIIT / nQuant) , nVlrDescIT, cAliquota, nVlrItem + nVlrDescIT + nValIPIIT, ;
								lOrc, xOrc, nNumItem, cUnidade	}
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FrtDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld		// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld		// Variavel que retorna o valor anterior
				EndIf
			Else
				aAux := {	cCodProd	, cCodBar	, cProduto	, nQuant	, ;
							nVlrUnit	, nVlrDescIT, cAliquota	, nVlrItem 	, ;
							lOrc		, xOrc		, nNumItem	, cUnidade	}
			EndIf  
			If lFRTCODB3t
				/*Adicionando Variaveis STATIC no final do array          
				  para que as mesmas possam ser tratadas nas EXECTEMPLATES*/
				aAdd(aAux,uProdTPL)
				aAdd(aAux,uCliTPL)
								
				aAux := ExecTemplate("FRTCODB3",.F.,.F.,{aAux,uProdTPL,uCliTPL})
	            uProdTPL := aClone(aAux[13])			
	            uCliTPL  := aAux[14]			
			EndIf
			   
			If ExistBlock("FRTCODB3")
				If lLjGrvLog
					LjGrvLog(Nil," Ponto de entrada FRTCODB3 - Parametros:",aAux)
				EndIf 
				aAux := ExecBlock("FRTCODB3",.F.,.F.,aAux)
				If lLjGrvLog
					LjGrvLog(Nil," Ponto de entrada FRTCODB3 - Retorno:",aAux)
				EndIf 
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibir Mensagem de Registro de Items no Display ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(5, aAux)            
            
			If cMvCodBar == "S" .AND. !Empty(cCodBar)	
				cProdLocal := cCodBar                                      
				
			Else
				cProdLocal := cCodProd
			EndIf      
		
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Item de reserva nao abre Cupom Fiscal.  						   ³
			//³Item de garantia com parametro habilitado nao abre Cupom Fiscal.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lGE .AND. (SuperGetMv("MV_LJIMPGF",,.F.) .AND. SBI->BI_TIPO == cMvLjTGar) .And. cVendido <> "N"
				lImpGECnf := .T.	
			Else
				lImpGECnf := .F.	
			EndIf
			  
			/*Adicionada variável lImpGECnf para realizar a identificaçao
			  do Produto de Garantia Estendida e não Adicionar ao        
			  Cupom Fiscal e depois adicionar ao Não Fiscal.             */
			If !lEmitNFCe
				If (Empty(cEntrega) .OR. cEntrega == "2") .AND.  !lImpGECnf .AND. If(lMVLJPRDSV,(lImpOrc .And. !lIsPrdServ) .Or. !lImpOrc,.T.) .And. (!lVPNewRegra .Or. Empty(cValePre)) //Item de reserva não abre Cupom Fiscal			
	
					If lAbrirCupom
	
						cDocBkp	 := cDoc                                        // Guarda o numero do Doc antes de altera-lo
						FR271Hora(.T., lConsulta, @oHora, @cHora, @oDoc, @cDoc)	// Atualiza a Hora e o Numero do Cupom
						If Empty(cDoc) .OR. Val(cDoc) == 0			// Protecao para o numero do Documento
							cDoc := cDocBkp
						EndIf

						//Valida possivel erro ao retornar o numero do cupom, nao registra o item. Zera variaveis para nova tentativa do usuário de registrar o primeito item.
						If cPaisLoc == "BRA" .AND. (Empty(cDoc) .OR. Val(cDoc) == 0)
							MsgStop(STR0065)	//"Nao foi possivel retornar o numero do Cupom. Verifique a impressora fiscal !"
							cDocBkp := ''
							lCup 	:= .F.
							nRet 	:= 1 
							lOcioso := .T.
						EndIf
							
						aSL1 := {	{"L1_NUMCFIS"	, cDoc },;
							 		{"L1_DOC"		, cDoc }}
	
						If lCgcCli .AND. Empty(SL1->L1_CGCCLI)
							Aadd(aSL1,{"L1_CGCCLI" , cCliCGC})
							cCliCGC := ""						
						EndIf	
	
						FR271BGeraSL("SL1", aSL1)
					
					EndIf
						
					If lCup
						While lTentaNov 
							If LjAnalisaLeg(39)[1] 
								nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(aAux[2]),13),aAux[1]), aAux[3], AllTrim(Str(aAux[4],8,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
										      AllTrim(Str(aAux[6],14,2)), aAux[7],Alltrim(Str(aAux[8],14,2)), aAux[12])
							Else			      
								nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(cProdLocal),13),cProdLocal), aAux[3], AllTrim(Str(aAux[4],8,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
												  AllTrim(Str(aAux[6],14,2)), aAux[7],Alltrim(Str(aAux[8],14,2)), aAux[12])
							EndIf
							
							If nRet <> 0
								lTentaNov := MsgYesNo(STR0077, STR0001) // Erro na Impressão do Cupom Fiscal. Verifique a conexão com a impressora e/ou falta de papel. Tentar Novamente?
							Else
								Exit		
							EndIf
						End						  								  
					EndIf									  
				Else
				
					If cEntrega == "2" .And. !lImpGECnf .AND. If(lMVLJPRDSV,(lImpOrc .And. !lIsPrdServ) .Or. !lImpOrc,.T.) .And. (!lVPNewRegra .Or. Empty(cValePre)) //Vale Presente nao pode imprimir no cupom fiscal
				
						If lAbrirCupom .AND. Empty(SL1->L1_DOC)
							cDocBkp	 := cDoc                                        // Guarda o numero do Doc antes de altera-lo
							FR271Hora(.T., lConsulta, @oHora, @cHora, @oDoc, @cDoc)	// Atualiza a Hora e o Numero do Cupom
							If Empty(cDoc) .OR. Val(cDoc) == 0			// Protecao para o numero do Documento
								cDoc := cDocBkp
							EndIf
	
							//Valida possivel erro ao retornar o numero do cupom, nao registra o item. Zera variaveis para nova tentativa do usuário de registrar o primeito item.
							If cPaisLoc == "BRA" .AND. (Empty(cDoc) .OR. Val(cDoc) == 0)
								MsgStop(STR0065)	//"Nao foi possivel retornar o numero do Cupom. Verifique a impressora fiscal !"
								lCup := .F.
								nRet := 1
								lOcioso := .T.
							EndIf
								
							aSL1 := {	{"L1_NUMCFIS"	, cDoc },;
									 	{"L1_DOC"		, cDoc }}
	
							If lCgcCli .AND. Empty(SL1->L1_CGCCLI)
								Aadd(aSL1,{"L1_CGCCLI" , cCliCGC})
								cCliCGC := ""
							EndIf	
	
							FR271BGeraSL("SL1", aSL1)					
	
						EndIf
				
						If lCup
							nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(cProdLocal),13),cProdLocal), aAux[3], AllTrim(Str(aAux[4],8,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
											  AllTrim(Str(aAux[6],14,2)), aAux[7],Alltrim(Str(aAux[8],14,2)), aAux[12])
						EndIf
					Endif  
				EndIf
			EndIf
						
			If nRet <> 0
				If LjGetOPBM() <> Nil
					If !LjConfProdPBM( 	cCodBar, nQuant, .T., lItemPbm, ;
									@aItens, len(aItens))
						Return( .F. )
					EndIf
				EndIf   

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar o Item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SL2")
				RecLock("SL2", .F.)
				SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
				dbDelete()
				MsUnLock()
		
				nVlrTotal -= (aItens[Len(aItens)][AIT_VLRITEM] + aItens[Len(aItens)][AIT_VALIPI] + aItens[Len(aItens)][AIT_VALSOL])
				nVlrBruto -= (aItens[Len(aItens)][AIT_VLRITEM] + aItens[Len(aItens)][AIT_VALIPI] + aItens[Len(aItens)][AIT_VALSOL])
				ASize(aItens, Len(aItens)-1)
				nTotItens--
	                                           
				//Realiza o acerto em todos os arrays para evitar a gravacao errada 
				//dos campos de impostos e do valor total do item...
				If cPaisLoc <> "BRA"
					FR271ITotVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda	, @aTotVen	,; 
								@aMoeda)
	
					//Exclui item do aCols
					Asize(aCols,(Len(aCols)-1))                        		
							
					//Exclui item do aImpsProd
					Asize(aImpsProd,(Len(aImpsProd)-1))                        								
					
					//Abate o valor dos impostos, referente ao item excluido, 
					//do array aImpsSL1, para futura gravacao no arquivo SL1.
		   			For nI := 1 To Len(aImpsSL2[Len(aImpsSL2)][3])
		   				nE := Ascan( aImpsSL1,{|x| x[1] == aImpsSL2[Len(aImpsSL2)][3][nI][1]})
		   				aImpsSL1[ nE,3 ] -= aImpsSL2[Len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
		   				aImpsSL1[ nE,5 ] -= aImpsSL2[Len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   						
					Next nI
					
					//Exclui item do aImpsSL2
					Asize(aImpsSL2,(Len(aImpsSL2)-1))                        												
				EndIf
				
				If cPaisLoc == "BRA" .AND. lImpOrc
					lErRegItem := .T.
				EndIf
			Else
				lItemRegEcf := .T.
				If !Empty(cReserva) .AND. cEntrega == "1"                 
					oCupom:AppendText(( STR0045 )+ chr(13) + chr(10))				//"ITEM DE RETIRA POSTERIOR"
				ElseIf !Empty(cReserva) .AND. cEntrega == "3"
					oCupom:AppendText(( STR0046 ) +chr(13) + chr(10))				//"ITEM DE ENTREGA"
				ElseIf lMVLJPRDSV .And. lImpOrc .And. lIsPrdServ
					oCupom:AppendText(( STR0059 ) +chr(13) + chr(10))				//"ITEM DE SERVICO"
				EndIf	
	
				If cMvCodBar == "S" .AND. !Empty(cCodBar)	
					cProdLocal := cCodBar
				Else
					cProdLocal := aAux2[2]
				EndIf
				
				cAppend := ""
			    cAppend += (StrZero(aAux2[1],3)+" "+Left(cProdLocal,13)+" "+Left(aAux2[4],21) ) + chr(10) + chr(13)			 		      
				If cPaisLoc == "BRA"
				  	cAppend +=( aAux2[5]+"x"+aAux2[6]+PadR(aAux2[7],6)+"%"+aAux2[8] )+ chr(10) + chr(13)			  				  
				Else       
					cAppend += (( aAux2[5]+"x"+aAux2[6]+Space(06)+aAux2[8] )+ chr(10) + chr(13))
				EndIf
				If nVlrPercIT > 0 
					cAppend +=((STR0010+aAux2[9])+ chr(10) + chr(13))  // "Desconto de :  "
				Endif
				If nValIPIIT > 0 
					cAppend +=(( "IPI: " + aAux2[10] )+ chr(10) + chr(13))
				Endif
				If nVlIcmRet > 0 .AND. SF4->F4_INCSOL == 'S' 		
					cAppend +=(( "ICMS Retido: " + aAux2[12] )+ chr(10) + chr(13))
				Endif
				oCupom:AppendText(cAppend)
			   	oCupom:GoEnd() 
				
				
				// Indica que o o item atual AINDA NAO TEVE DESCONTO
				lDescIT := .F.
				
				If lAbrirCupom
					aSL2 := {	{	"L2_DOC"	,	cDoc	},;
							 	{	"L2_SITUA"	,	"04"	}} 	// "04" - Impresso o Item				
				Else
					aSL2 := {	{	"L2_SITUA"	,	"04"	}} 				
				EndIf
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Cartao Fidelidade 		³				
				//³Recarga do cartao fidelidade processada: ³				
				//³B - Via processo batch (LJGRVBATCH)      ³
				//³W - Via WebService(LJCCARFID) 		    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ													
				If lLjcFid
					If FA271aGrcf ()
						If Ca280CkWs ()                                          
							//W - Via WebService(LJCCARFID)                 
							aSL2 := {{"L2_PROCFID",	"W"}}									
							Fa271aSpfw (.T.)
						Else
							//B - Via processo batch (LJGRVBATCH)       
							aSL2 := {{"L2_PROCFID",	"B"}}				
							Fa271aSpfw (.F.)
						EndIf		
					EndIf
				EndIf
				
				FR271BGeraSL("SL2", aSL2)
				If nTotItens == 1
					aSL1 := { { "L1_SITUA", "04" } }			// "04" - Impresso o Item
					FR271BGeraSL("SL1", aSL1)
		    	EndIf

				nTmpQuant := 1
				If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
				    If T_DroVerCont( cCodProd )
						T_DroAltANVISA( cCodProd, nQuant, cDoc, LJGetStation("SERIE"),;
	     								nCodANVISA  )
					Endif
				Endif	
				If LjGetOPBM() <> Nil
					If !LjConfProdPBM( 	cCodBar, nQuant, .T., lItemPbm, ;
									@aItens, len(aItens))
						Return( .F. )
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
Else
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + Upper(STR0013) )	// "Produto não cadastrado!!!"
		DisplayEnv(StatDisplay(), "2C" + STR0035 )     //"PRESSIONE <ESC>
		cCodProd := ""
	EndIf

	FRT272XMsg(cCodProd)
	If cPaisLoc == "BRA" .AND. lImpOrc
		lErRegItem := .T.
	EndIf
EndIf

If lGE
	If !Empty(SL2->L2_GARANT) .AND. SBI->BI_TIPO <> cMvLjTGar 
		LjSetGarant(cCodProd,cProduto,cVlrItem,cNSerie, FR271CAField(xOrc, "L2_ITEM", nNumItem))
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a função para alimentar o array de impressão de Relatorio gerencial quando o produto for do TIPO "GE"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SBI->BI_TIPO == cMvLjTGar
		LjSetGarant(cCodProd,cProduto,cVlrItem,cNSerie, FR271CAField(xOrc, "L2_ITEM", nNumItem))
	EndIf 
EndIf                
			
// Limpando as variaveis
cQtd := "1"
nVlrPercIT := 0
nVlrDescIt := 0

Return lRet                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271AInitIT³Autor³ Vendas Clientes       ³ Data ³15/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa os Objetos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function FR271AInitIT(	lForced		, lF7		, cCodProd	, cProduto	,;
						nTmpQuant	, nQuant	, cUnidade	, nVlrUnit	,;	
						nVlrItem	, oProduto	, oQuant	, oUnidade	,;	
						oVlrUnit	, oVlrItem	, oDesconto	, cCliente	,;		
						cLojaCli	, cOrigem)
	                                                                  
Local nTamCodProd	:= 0
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local cDigQtde	   	:= Alltrim(SuperGetMV("MV_FRTDIGQ",,"")) 	//Digito separador de quantidade x produto
Local nTL2QUANT	    := TamSX3("L2_QUANT")[1]		  			// Tamanho do campo B1_COD
Local nTB1COD	    := TamSX3("BI_COD")[1]			  			// Tamanho do campo B1_COD

DEFAULT lForced 	:= .F.
DEFAULT cOrigem		:= ""  

If SuperGetMv("MV_LJDTBAR",,.F.)
   	nTB1COD := Max(nTB1COD,30)	// Caso seja Codigo de barras databar,colocar mais caracteres no Get
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usa Recebimento de Conta no FrontLoja. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJUSARC")
	nTamCodProd := TamSX3("L2_BCONTA")[1]
ElseIf !Empty(cDigQtde)
	nTamCodProd := nTB1COD + nTL2QUANT
Else
	nTamCodProd := nTB1COD
EndIf

cCodProd := Space(nTamCodProd)
If lF7 .OR. lForced
	cProduto := space(15)
	nTmpQuant:= 1
	nQuant   := 1
	cUnidade := "UN"
	nVlrUnit := 0
	nVlrItem := 0
    If !lTouch .AND. cOrigem <> "LOJA160"  
		oProduto:Refresh()
		oQuant:Refresh()
		oUnidade:Refresh()
		oVlrUnit:Refresh()
		oVlrItem:Refresh()
		oDesconto:Refresh()
	Endif	
EndIf                              
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271AConfExit³Autor³ Vendas Clientes      ³Data ³16/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirmacao da Saida da Venda                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271AConfExit(	lOcioso		, lRecebe , lCXAberto	, nHdlOPE	,;
							lExitNow)
Local lRet:=.F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

If lExitNow .OR. lRecebe
	lRet := .T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	If lCXAberto
		If !lOcioso
			HELP(' ',1,'FRT015')	// "É Necessário FECHAR a Venda ou CANCELAR este Cupom Fiscal.", "Atenção"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Permissao "Saida do Atendimento" - #10 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaDisplay
				DisplayEnv( StatDisplay(), "1E  " )  
				DisplayEnv( StatDisplay(), "**" )     //"Inibe os caracteres no display"
			EndIf
			If LJProFile(10)
	  			If lUsaDisplay
					DisplayEnv( StatDisplay(), "*" )     //"Exibe os caracteres no display"
   					DisplayEnv(StatDisplay(), "1C" + Upper(STR0001) )         
   			 		DisplayEnv(StatDisplay(), "2C" + STR0015)
				EndIf
				lRet := MsgYesNo(STR0015, STR0001)	// "Deseja sair da rotina de venda?", "Aneção"
				If lRet
					FClose(nHdlOPE)
					If lUsaDisplay
	  					DisplayEnv( StatDisplay(), "1E"+ " " )     //"Exibe os caracteres no display"
					EndIf
				Else
		  			If lUsaDisplay
						DisplayEnv(StatDisplay(), "2E"+ STR0036)
						DisplayEnv(StatDisplay(), "1E"+ " ")
					EndIf
				EndIf
			Else
                Alert(STR0078) //"Não é possível sair, caixa aberto."
			EndIf
		EndIf
	Else
		If !lOcioso
			HELP(' ',1,'FRT016')	// "Houve a retomada da Venda. Abra o Caixa e FECHE ou CANCELE este Cupom Fiscal.", "Atenção"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Permissao "Saida do Atendimento" - #10 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaDisplay
				DisplayEnv( StatDisplay(), "1E  " )  
				DisplayEnv( StatDisplay(), "**" )     //"Inibe os caracteres no display"
			EndIf
			If LJProFile(10)
				lRet := .T.				// Se o Caixa Nao Estiver Aberto, E Nao Houve FR271Resume,
             Else
                Alert(STR0079) //"Não é possível sair, o usuário não tem permissão"
			EndIf						// Saida Automatica
			If lUsaDisplay
				DisplayEnv( StatDisplay(), "*" )     //"Exibe os caracteres no display"
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271AStart³ Autor³ Vendas Clientes       ³ Data ³07/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializacao do PDV                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271AStart( 	oTimer		, oHora			, cHora			, oDoc			,;
						cDoc		, oPDV			, cPDV			, oMoedaCor		,;	
						nMoedaCor	, cMoeda		, oTaxaMoeda	, nTaxaMoeda	,;	
						cSimbCor	, oTemp3		, cCodProd		, oFotoProd		,;	
						oProduto	, oUnidade		, oQuant		, oVlrUnit		,;	
						oVlrItem	, oVlrTotal		, oTotItens		, oDesconto		,;
						nVlrTotal	, nVlrBruto		, nTotItens		, cProduto		,;
						cUnidade	, nQuant		, nVlrUnit		, oCupom		,;
						cOrcam		, cImpressora	, cCliente		, cLojaCli		,;
						lOcioso 	, lDescITReg	, aItens		, aICMS			,;
						nVlrMerc	, lExitNow		, lFechaCup		, aCrdCliente	,;
						uCliTPL		, uProdTPL		, nTotDedIcms	, aMoeda		,;
						aSimbs		, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen		, aCols			, aHeader		,;
						lBalanca	, cPorta		, cVendLoja		, cTipoCli		,;
						aPgtos		, lResume		, cCupom 	    , lAbreCup 	 	,;
						cMensagem)


Local nRet 		:= -1					// Retorno do Handle de comunicacao com ECF - DEFAULT negativo
Local cRet		:= " " 
Local aKey
Local aAux
Local nSaveSx8 	:= GetSx8Len()
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
Local lMvLjPdvPa  := LjxBGetPaf()[2] //Indica se é PDV

DEFAULT cTipoCli 	:= ""
DEFAULT aPgtos	 	:= {}
DEFAULT lResume		:= .F.
DEFAULT cCupom		:= ""
DEFAULT lAbreCup	:= .F.
DEFAULT lDescITReg	:= .F.
DEFAULT cMensagem   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If !lTouch
	oTimer:DeActivate()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PTG,ANG,CHI,COL - Nao Utilizara ECF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("LjNfPtgNEcf") .AND. LjNfPtgNEcf(SM0->M0_CGC)	
	If !(cPaisLoc$"CHI|COL") 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios 			                    ³
		//³Nao utilizara o ECF se o usuario for NAO FISCAL                      ³
		//³Nao atualiza a SLG, pois sera usada a serie escolhida pelo usuario   ³
		//³Paises:Chile/Colombia  - F1CHI	   			     					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SLG",.F.)
		SLG->LG_PDV		:= AllTrim(cEstacao)														// Numero do PDV - usa o codigo da estacao como numero do PDV
		SLG->LG_SERIE	:= AllTrim(SuperGetMv("MV_LOJAPED", /*lHelp*/, "PED", /*cFilial*/)) 		// Serie que sera usada para pegar o numero do documento
		MsUnlock()
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Gaveta Serial         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"GAVETA","PORTGAV"})
If lGaveta .AND. !Empty(aAux[2]) .AND. (LJGetStation("PORTIF") <> aAux[2])
	nHdlGaveta := GavetaAbr(aAux[1], aAux[2])
	If nHdlGaveta == -1
		// "Erro ao conectar com a Gaveta Serial " ### " na porta " ###, "Atenção"
		MsgStop(STR0029+AllTrim(aAux[1])+STR0027+aAux[2]+".", STR0001)
		lGaveta := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do Leitor Optico Serial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"OPTICO","PORTOPT"})
If lUsaLeitor .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
	nHdlLeitor := LeitorAbr(aAux[1], aAux[2],'T')
	If nHdlLeitor == -1
		// "Erro ao conectar com o Leitor Optico Serial " ### " na porta " ###, "Atenção"
		MsgStop(STR0030 + AllTrim(aAux[1]) + STR0027+aAux[2] + ".", STR0001 )
		lUsaLeitor := .F.
	EndIf
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Balanca              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If SLG->( FieldPos("LG_PORTBAL")) > 0
	aAux := LJGetStation({"BALANCA","PORTBAL"})
	If lBalanca .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
		nHdl := BalancaAbr(aAux[1], aAux[2],'T')
		If nHdl == -1
			// "Erro ao conectar com a Balanca Serial " ### " na porta " ###, "Atenção"
			MsgStop(STR0037 + AllTrim(aAux[1]) + STR0027+aAux[2] + ".", STR0001 )//"Erro ao conectar com a Balanca Serial "
			lBalanca := .F.
		EndIf
		StatBalanca(nHdl)
	EndIf   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"DISPLAY","PORTDIS"})

If lUsaDisplay .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
	StatDisplay (DisplayAbr(aAux[1], aAux[2]))
	If StatDisplay() == -1
		// "Erro ao conectar com o Display " ### " na porta " ###, "Atenção"
		MsgStop( STR0031 + AllTrim(aAux[1]) + STR0027 + aAux[2] + ".", STR0001 )
		lUsaDisplay := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibir Mensagem de Inicializacao no Display ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgDisplay(1)
	EndIf
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   
//³ Abertura do CMC7 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"CMC7", "PORTMC7"})
If lUsaCMC7
	If Empty(aAux[1])
		lUsaCMC7 := .F.
	Else
	    nHdlCMC7:= CMC7Abr(aAux[1], aAux[2]) 
		If nHdlCMC7 == -1
			// "Erro ao conectar com o Leitor de CMC7 " ### " na porta " ###, "Atenção"
			MsgStop( STR0026 + AllTrim(aAux[1]) + STR0027+aAux[2] + ".", STR0001 )
			lUsaCMC7 := .F.
		EndIf
	EndIf
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Impressora de Cheque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"IMPCHQ", "PORTCHQ"})
If lUsaCH
	If Empty(aAux[1])
		lUsaCH := .F.
	Else
		nHdlCH := CHAbrir( aAux[1], aAux[2] )
	    If nHdlCH < 0
			// "Erro ao conectar com a Impressora de Cheque " ### " na porta " ###, "Atenção"
			MsgStop(STR0028+AllTrim(aAux[1])+STR0027+aAux[2]+".", STR0001)
			lUsaCH := .F.
	    Endif
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Impressora Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEmitNFCe
	LjMsgRun( STR0067,, { || nHdlECF := INFAbrir( cImpressora,cPorta ) } ) //#"Aguarde. Abrindo a Impressora Não Fiscal..."
Else
	nHdlECF := IFAbrir(cImpressora, cPorta)
EndIf

If nHdlECF == -1
	// "Erro ao conectar com a Impressora Fiscal " ### " na porta ", "Atenção"
	MsgStop(STR0016+AllTrim(cImpressora)+STR0017+cPorta+".", STR0001)
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
Else
	// Grava o numero de serie do ECF no campo LG_SERPDV
	If ExistFunc("LJXGrSerie")
		LJXGrSerie(nHdlECF, cEstacao)
	EndIf
EndIf

If !LjNfPafEcf(SM0->M0_CGC)
	If !LjVldSerie()
		// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
		lExitNow := .T.
		Return(NIL)
	EndIf
EndIf

nRet := IFAbrECF(nHdlECF)
If nRet <> 0
	// "Não consegui abrir o ECF. É possível que esteja desligado. Erro: " ###, "Atenção"
	MsgStop(STR0018+Str(nRet,2,0), STR0001)
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Apos a Abertura do ECF 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("U_FRTABRECF")
	U_FRTABRECF(nHdlECF,cImpressora,cPorta)
Endif 

If !lEmitNFCe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara a data do ECF com a data do Sistema. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IFStatus(nHdlECF, "2", @cRet)
	If dDataBase <> CToD(cRet)
		// "A data do ECF é diferente da data do Sistema." ### "Atenção"
		HELP(' ',1,'FRT017')
		// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
		lExitNow := .T.
		Return(NIL)
	Else
		If LjAnalisaLeg(3)[1]
			If ! VerifHora()
				/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Março de 2013),
					para PAF-ECF admite-se somente uma tolerância em minutos entre a hora do Sistema e a hora do ECF,
					limitada a uma hora, desde que na mesma data." */
				LjMsgLeg(LjAnalisaLeg(3))
				If lMvLjPdvPa
					Help(' ',1,STR0001,Nil,STR0062,3,1) //"Atenção"
				Else
					HELP(' ',1,'FRT018') // "Hora do Sistema diferente da hora do ECF."
				EndIf
				// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
				lExitNow := .T.
				Return(NIL)
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o CNPJ cadastrado na impressora, eh o mesmo do SIGAMAT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal
	If !LjEcfIFCNPJ()
		lExitNow := .T.
		Return (NIL)
	EndIf
EndIf
aICMS := LJSetAliq()   


If !lEmitNFCe
	FR271Hora(.T., nil, oHora, cHora, oDoc, cDoc)  		// Atualiza a Hora e o Numero do Cupom
EndIf

If lEmitNFCe
	cPDV := LJGetStation("PDV")
Else 
	IFPegPDV(nHdlECF, @cPDV)		// Numero do PDV
	If ! AllTrim(cPDV) == AllTrim(LJGetStation("PDV"))
		// "O Número de PDV do equipamento é diferente do cadastrado na estação." ### "Atenção"
		HELP(' ',1,'FRT019')
		// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
		lExitNow := .T.
		Return(NIL) 
	EndIf
EndIf
cPDV := PadR( cPDV, TamSX3("L1_PDV")[1] )

If !lTouch
	oPDV:Refresh()
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o ECF permite desconto apos registrar o item (0=Permite) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe() 
	lDescITReg := .F.
Else
	lDescITReg := (IFStatus(nHdlECF, "15", "") == 0)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se utiliza troca de serie automatica quando o COO for reinicializado.³
//³Emite aviso para rodar a rotina de reserva de series.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJNSrDisp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando a Retomada da Ultima Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun( STR0038, "", { || FR271Resume( 	@cPDV			, @oMoedaCor	, @nMoedaCor	, @cMoeda		,;
										@oTaxaMoeda		, @nTaxaMoeda	, @cSimbCor		, @oTemp3		,;
										@cCodProd		, @oFotoProd	, @oProduto		, @oUnidade		,;
										@oQuant			, @oVlrUnit		, @oVlrItem		, @oVlrTotal	,;
										@oTotItens		, @oDesconto	, @cDoc			, @nVlrTotal	,;	
										@nVlrBruto		, @nTotItens	, @cProduto		, @cUnidade		,;
										@nQuant			, @nVlrUnit		, @oCupom		, @cOrcam		,;
										@cCliente		, @cLojaCli		, @lOcioso		, @aItens		,;
										@nVlrMerc		, @lExitNow		, @lFechaCup	, @aCrdCliente	,;
										@uCliTPL		, @uProdTPL		, @nTotDedIcms 	, @aMoeda		,;
										@aSimbs			, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,; 
										@aImpVarDup		, @aTotVen		, @aCols		, @aHeader		,;
										@cVendLoja		, @cTipoCli		, @oHora		, @cHora		,;
										@oDoc			, @cDoc			, @aPgtos		, @lResume		,;
										@cCupom			, @lAbreCup		, @cMensagem)})		// "Aguarde ... verificando situação do PDV ..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inserido a CriaVar e a RollBacSX8, Pois o GetSXENum Contido na        ³
//³ Inicializacao do L1_NUM, Na Primeira Execucao Cria um Indice.         ³
//³                                                                       ³
//³ Inserido as Funcoes Fiscais, Pois na Primeira Execucao Leva-se Muito  ³
//³ Tempo na Inicializacao dos Arrays Estaticos.                          ³
//³                                                                       ³
//³ Estas Linhas Devem Ser Retiradas Quando Esses Problemas Forem         ³
//³ Solucionados.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaVar("L1_NUM")
While (GetSX8Len() > nSaveSx8)
	RollBackSx8()
End  

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek( xFilial("SA1") + cCliente + cLojaCli )
	MaFisIni(	SA1->A1_COD	,	SA1->A1_LOJA	,	"C"	, 	"S"	,;
				SA1->A1_TIPO,	NIL				,	NIL	, 	.F.	,;
				"SBI"		,	NIL				,	"01",	NIL	,;
				NIL			,	NIL				,	NIL	,	NIL	,;
				NIL			,	NIL				,	.F.	)
    DbSelectArea("SBI")
    DbSetOrder(1)
    If DbSeek( xFilial("SBI") )
    	MaFisAdd(SBI->BI_COD, SuperGetMV("MV_TESSAI"), 1, 1, 0, "", "",, 0, 0, 0, 0, 1, 0)
	Endif
	MaFisEnd()
Endif        

If !lTouch
	oTimer:Activate()
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271AAbreCX³ Autor³ Vendas Clientes       ³ Data³19/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abertura do Caixa (F4)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function FR271AAbreCX( 	oCupom	, cCupom	, cPDV	, lCXAberto	,;
				   		nHdlOPE )            
					
Local aKey         		:= {}
Local cSupervisor		:= Space(15)
Local cString			:= ""
Local nRet				:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay 		:= !Empty(LjGetStation("DISPLAY"))
Local lChangeCxa  		:= .F.
Local cNumMov			:= AllTrim(LjNumMov())
Local cChvFecha			:= ""
Local aID				:= {}
Local lConfFecha		:= SuperGetMV("MV_LJCONFF",.F.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Verifica se a conferencia de caixa esta ativa e se o ambiente esta preparado
Local lExConf			:= .F.		//Existe conferencia pedente ou o caixa esta aberto em outro terminal
Local lObgCon			:= SuperGetMV("MV_LJOBGCF",,.T.) //indica se a Conferencia de Caixa eh obrigatoria

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa como .T. para Regra de Desconto - opção Acumulativa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc( "LJSETRACUMUL" )
	LjSetRAcumul(.T.)
EndIf	 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mesmo o caixa estando aberto verifica se nao houve          ³
//³troca do operador , caso ocorra nao prossegue com a operacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
dbSelectArea("SLI")
SLI->(dbSetOrder(1))
If SLI->(dbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE"))	
	If !Empty(SLI->LI_MSG) .AND. AllTrim(SLI->LI_USUARIO) <> AllTrim(cUserName)
		lCXAberto 	:= .F.				 	
		lChangeCxa  := .T.
		// "O usuário " ### " não fechou o caixa. Favor iniciar com este usuário e fechar o caixa.", "Atenção"
		MsgStop(STR0022+AllTrim(SLI->LI_USUARIO)+STR0023, STR0001)
	EndIf
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se nao existe pendencia de conferencia na retaguarda e localmente (se necessario)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lChangeCxa .AND. lConfFecha
	//Pesquisar se existe conferencia e/ou movimento em aberto do operador na retaguarda
	cChvFecha := ExConfAbLW(2)
	//Caso nao tenha sido encontrada nada na retaguarda, pesquisar localmente	
    If Empty(cChvFecha) .OR. ValType(cChvFecha) # "C"
    	aID := LjInfoCxAt()
		Do While .T.
			//Caso nao exista numero de movimento
			If Empty(cNumMov)
				cChvFecha := LjUltMovAb(2,aID[1],,,,.T.)
			Else
				cChvFecha := LjUltMovAb(1,aID[1],aID[4],aID[2],cNumMov,.T.)
			Endif
			If Empty(cChvFecha)
				Exit
			Endif
			//Ao pesquisar localmente, verificar se a conferencia nao foi feita na retaguarda. Caso tenha sido feita, desconsiderar a chave e atualizar
			If LjRetSitLW(cChvFecha,.T.) == "02"
				cChvFecha := ""
			Else
				Exit
			Endif
		EndDo    	
	Endif
	If !Empty(cChvFecha)
		lExConf		:= .T.
		If lObgCon
			MsgStop(STR0054,STR0001) //#"Existe algum movimento de conferência pendente para este operador ou o caixa já está aberto." ##"Atenção"
		ElseIf !ConfCxFecha(cChvFecha)
			MsgInfo(STR0066,STR0001) //#"Não foi realizada a conferência do fechamento de caixa do dia anterior. Favor fechar o caixa e efetua-la." ##"Atenção"
		EndIf
	Endif
Endif
 
If !lCXAberto .AND. !lChangeCxa .AND. !lExConf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()

    If lUsaDisplay
    	LjLimpDisp()
		DisplayEnv(StatDisplay(), "1C" + STR0073) // ### "ABERTURA DE CAIXA"
		DisplayEnv(StatDisplay(), "2E" + STR0074)	// ### "Utilize o monitor para visualizar"
		DisplayEnv(StatDisplay(), "3C" + STR0075)	// ### "as mensagens de abertura."
	End

	If LJ260Abre(,,,@cSupervisor,.T.,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar se Houve Troca de Operador ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE"))
		If Empty(SLI->LI_MSG)
			oCupom:SetupdatesEnable(.F.)
			oCupom:AppendText((chr(10) + chr(13)))
			oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
			oCupom:AppendText((PADC(STR0019,40))+ chr(10) + chr(13)) 	// "   A B E R T U R A   D E   C A I X A    "
			oCupom:AppendText((chr(10) + chr(13))+ chr(10) + chr(13))
			oCupom:AppendText((STR0020+cUserName+STR0021+xNumCaixa())+ chr(10) + chr(13))	// "Usuário: " " Caixa: "
			oCupom:AppendText((DToC(dDatabase)+" "+Time()+Space(13)+STR0005+PadR(cPDV,4)) + chr(10) + chr(13))
			oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
			oCupom:SetupdatesEnable(.T.)
			oCupom:GoEnd()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Impressao do Relatorio de Abertura ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTABRCX")
				cString := ExecBlock("FRTABRCX", .F., .F., {cSupervisor})
			EndIf
			If Len(cString) > 0
				nRet := IFStatus(nHdlECF, "5", "")				// Verifica Cupom Fechado
				If (nRet == 0 .AND. IFRelGer(nHdlECF, cString) == 0) .OR. (nRet == 7)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Informar que Houve Troca de Operador ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FR271BGerSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
					If !FR271BSemaforo("OPE", cEstacao, @nHdlOPE)
						// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
						HELP(' ',1,'FRT020')
					EndIf
					lCXAberto := .T.
				Else
					// "Não foi possível realizar a Abertura do Caixa. Erro na impressão do comprovante.", "Atenção"
					HELP(' ',1,'FRT021')
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Informar que Houve Troca de Operador ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FR271BGerSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
				If !FR271BSemaforo("OPE", cEstacao, @nHdlOPE)
					// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
					HELP(' ',1,'FRT020')
				EndIf
				lCXAberto := .T.
			EndIf
		Else
			If Alltrim(SLI->LI_USUARIO) == Alltrim(cUserName)
				oCupom:SetupdatesEnable(.F.)
				oCupom:AppendText((chr(10) + chr(13))+ chr(10) + chr(13))
				oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
				oCupom:AppendText((PADC(STR0019,40))+ chr(10) + chr(13))	// "   A B E R T U R A   D E   C A I X A    "
				oCupom:AppendText((chr(10) + chr(13)))
				oCupom:AppendText((STR0020+cUserName+STR0021+xNumCaixa()) + chr(10) + chr(13))	// "Usuário: " " Caixa: "
				oCupom:AppendText((DToC(dDatabase)+" "+Time()+Space(13)+STR0005+PadR(cPDV,4))+ chr(10) + chr(13))
				oCupom:AppendText((FRT_SEPARATOR)  + chr(10) + chr(13))
		    	oCupom:SetupdatesEnable(.T.)
		    	oCupom:GoEnd()
				FR271BGerSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
				If !FR271BSemaforo("OPE", cEstacao, @nHdlOPE)
					// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
					HELP(' ',1,'FRT020')
				EndIf
				lCXAberto := .T.
			Else
				// "O usuário " ### " não fechou o caixa. Favor iniciar com este usuário e fechar o caixa.", "Atenção"
				MsgStop(STR0022+AllTrim(SLI->LI_USUARIO)+STR0023, STR0001)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibir Mensagem de Caixa Disponivel no Display ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCXAberto
			MsgDisplay(3)
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1E"+ STR0036 + "|")
		   		End
		EndIf
	Else
	    If lUsaDisplay
			DisplayEnv(StatDisplay(), "1E"+ STR0036 + "|")
		End	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                      
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271AItImp ³ Autor³ Vendas Clientes      ³ Data³20/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³    				  				 	 	    	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/      
Function Fr271AItImp(aItens,cEntrega,lGeRes)

Local nRet 		:= 0
Local aBkpItens := {}
Local nX 		:= 0
Local nNumberIt	:= 0

DEFAULT aItens	 :={}
DEFAULT cEntrega :=''	
DEFAULT lGeRes	 :=.F. 

If Len(aItens) > 0 
	aBkpItens := aClone(aItens)
EndIf

// Tirado o cEntrega igual "3", pois Entrega nao imprime, assim como Retira Posterior
If cEntrega $ "2" .OR. Empty(cEntrega) 
	If !lGeRes  	
		For nX := 1 To Len(aBkpItens)
			If Len(aBkpItens[nX]) >= 14
				If !Empty(aBkpItens[nX][AIT_ITIMP])
					If aBkpItens[nX][AIT_ITIMP] <> 0
						nNumberIt := aBkpItens[nX][AIT_ITIMP]
					EndIf
				EndIf
			EndIf
		Next nX 
		
		If nNumberIt == 0
			nRet := 1
		Else
			nNumberIt := nNumberIt + 1
			nRet := nNumberIt
		EndIf
	EndIf
EndIf

Return nRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271AVendRet³ Autor³ Vendas Clientes      ³ Data³20/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica qual vendedor será registrado no item	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/      
Static Function Frt271aVendRet(lOrc,xOrc,nNumItem,cVendLoja)

Local cRet 			:= 	""

DEFAULT lOrc        := .F.
DEFAULT xOrc        := ""
DEFAULT nNumItem  := 0
DEFAULT cVendLoja   := ""

If lOrc
	cRet := FR271CAField(xOrc,"L2_VEND",nNumItem)	
	If Empty(cRet)
		cRet := FR271CAField(xOrc, "L1_VEND")
	EndIf
Else
	cRet := cVendLoja
EndIf	
	
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr271ARgrDescºAutor  ³Vendas CRM       º Data ³  03/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica desconto proveniente da regra de descontos sobre o   º±±
±±º          ³item, quando houver regra que se adeque ao item atual.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr271ARgrDesc(	oCupom 		, oDesconto	, nVlrPercIT, nVlrTotal	,;
								lRecebe		, lDescIT	, lDescITReg, nVlrBruto	,;
								aItens		, nMoedaCor	, nDecimais	, lCXAberto	,;
								nVlrDescIT	, cCodProd	, cCliente  , cLojaCli	,;
								nQuant		, nVlrItem	, cTipoProd) 

Local nRegDesc := 0			//Percentual de desconto sobre o item
Local cTabPreco:= LjXETabPre(cCliente,cLojaCli) // Parametro da tabela de preco padrao

Default nVlrItem	:= 0   	// Valor do item
Default cTipoProd   := ""	// Tipo de Produto

nRegDesc := LjRgrDesc(	cCodProd	, cCliente	, cLojaCli	, cTabPreco	,;
						nQuant		, 1			, Nil		, Nil		,;
						Nil			, nVlrItem	, cTipoProd	) 

If nRegDesc > 0
	FR271EDescIT( 	@oCupom 	, @oDesconto	, @nVlrPercIT	, @nVlrTotal,;
					@lRecebe	, @lDescIT		, @lDescITReg	, @nVlrBruto,;
					@aItens		, @nMoedaCor	, @nDecimais	, @lCXAberto,;
					@nVlrDescIT	, .F.			, nRegDesc		)
EndIf

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  |FRTAImpCpfºAutor  ³Microsiga           º Data ³  08/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se foi impresso CPF/CNPj no Cupom                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTAImpCpf()
Local lRet	:= lImpCpfNpj

lImpCpfNpj	:= .F.

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FRT27AMuNeºAutor  ³Venda & Crm         º Data ³  08/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Objeto                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT27AMuNe(nTipo)     

Default nTipo := 1

If nTipo == 0
	oMultNegoc := Nil
EndIf

Return (oMultNegoc)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271aGpfw  ³Autor³ Vendas Clientes       ³ Data ³14/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Retorna se o processamento do movimento do cartao fidelidade³±±
±±³			 ³sera via WebSerice										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function Fa271aGpfw ()


Return lProcFidWs

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271aSpfw  ³Autor³ Vendas Clientes       ³ Data ³14/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Define  se o processamento do movimento do cartao fidelidade³±±
±±³			 ³sera via WebSerice										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function Fa271aSpfw (lPar)

DEFAULT lPar := .F.

lProcFidWs := lPar

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271aGrcf  ³Autor³ Vendas Clientes       ³ Data ³14/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Retorna se esta sendo realizada recarga de cartao fidelidade³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function Fa271aGrcf ()


Return lRecFid

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA271aSrcf  ³Autor³ Vendas Clientes       ³ Data ³14/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³ Define se esta sendo realizada recarga de cartao fidelidade³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function Fa271aSrcf (lPar)

DEFAULT lPar := .F.

lRecFid := lPar

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjSetGarant ³Autor³ Vendas Clientes       ³ Data ³23/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Define se este item tem garantia estendida 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function LjSetGarant(cProduto,cDescri,cValItem,cNSerie,;
					cItem, cProdGE) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribui o valor da variavel static³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aGarant, {cProduto,cDescri,cValItem,cNSerie,;
					cItem, cProdGE}) 


Return         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjGetGarant ³Autor³ Vendas Clientes       ³ Data ³23/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Retorna Array static com produtos de Garantia estendida	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function LjGetGarant()


Return aGarant


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FaGetRecFo  ³Autor³ Vendas Clientes       ³ Data ³11/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Obtem RECNO do controle de formulario escolhido pelo usuario³±±
±±³			 ³Release 11.5 - Controle de Formularios                   	  ³±±
±±³			 ³Paises : Chile/Colombia - F1CHI							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FaGetRecFo ()

Return nRecnoFo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FaZerRecFo  ³Autor³ Vendas Clientes       ³ Data ³14/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Limpa RECNO do controle de formulario escolhido pelo usuario³±±
±±³			 ³Release 11.5 - Controle de Formularios                   	  ³±±
±±³			 ³Paises : Chile/Colombia  - F1CHI							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FaZerRecFo() 

nRecnoFo := 0

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³GetProdGar  ³Autor³ Ricardo.Bueno Vendas  ³ Data ³18/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aProdGar entre os Fontes		  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Carrega informacoes sobre os produtos de Garantia Estend. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function GetProdGar()
Return aProdGar

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SetProdGar  ³Autor³ Ricardo.Bueno Vendas  ³ Data ³24/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aProdGar entre os Fontes		  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Zera informacoes sobre os produtos de Garantia Estend.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function SetProdGar()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera array para nao influenciar na Proxima Venda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProdGar := {} 
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjZGarant ³Autor³ Vendas Clientes       ³ Data ³23/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³Retorna Array static com produtos de Garantia estendida	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function LjZGarant()
aGarant := {}
Return              

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtGetItSv  ³Autor³ Vendas Clientes       ³ Data ³17/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aItensServ entre os Fontes	  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Carrega informacoes referente aos Itens de Servico.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FrtGetItSv()
Return aItensServ

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtSetItSv  ³Autor³ Vendas Clientes       ³ Data ³17/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aItensServ entre os Fontes	  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Zera informacoes referente aos Itens de Servico.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FrtSetItSv()
	//Zera array para nao influenciar na Proxima Venda.
	aItensServ := {} 
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtGetItVP  ³Autor³ Vendas Clientes       ³ Data ³08/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aItensVP entre os Fontes		  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Retorna informacoes referente aos Itens de Vale Presente. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FrtGetItVP()
Return aItensVP

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtSetItVP  ³Autor³ Vendas Clientes       ³ Data ³08/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aItensVP entre os Fontes	 	  ³±±
±±³			 ³	FRTA271A e FRTA271G.									  ³±±
±±³			 ³  Zera informacoes referente aos Itens de Vale Presente.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function FrtSetItVP()
	//Zera array para nao influenciar na Proxima Venda.
	aItensVP := {} 
Return Nil


/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ConfCxFecha  ³Autor³ Vendas Clientes    	³ Data ³22/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³	Verifica se o caixa nao foi fechado no dia anterior.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271A										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function ConfCxFecha(cChave)
Local lRet := .T.
Local cResChave := ""

If AliasIndic("SLW")
	DbSelectArea("SLW")
	SLW->(DbSetOrder(1))
	cResChave := SubStr( cChave, 1, Len(SLW->(LW_FILIAL+LW_PDV+LW_OPERADO+ DTOS(LW_DTABERT))))
	If SLW->(DBSeek(cResChave)) 
		While !SLW->(EOF()) .And. cResChave == SLW->(LW_FILIAL+LW_PDV+LW_OPERADO+ DTOS(LW_DTABERT))
			If Empty(SLW->LW_DTFECHA) .And. SLW->LW_DTABERT < dDataBase .And. cChave == SLW->(LW_FILIAL+LW_PDV+LW_OPERADO+ DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV)
				lRet := .F.
				Exit
			EndIf
			SLW->(DBSkip())
		End
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjDescDisp
Funcao para apresentar no display se o desconto foi permitido ou nao
@author	Vendas Cliente
@param     nOpcao Opcao de mensagem de desconto onde 1: Desconto Permitido; 2: Desconto Negado
@return    Nil
@version	P10
@since	08/01/2014
/*/
//------------------------------------------------------------------------------------------------------------------
Function LjDescDisp(nOpcao)

Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))	// Verifica se a estacao possui Display

DEFAULT nOpcao := 0

// Funcao executada somente quando a estacao estah configurada para usar display
If !lUsaDisplay
	Return Nil
Endif

// Limpar o display para apresentar novas mensagens
LjLimpDisp()

DO CASE

	// Desconto permitido
	CASE nOpcao == 1
		DisplayEnv( StatDisplay(), "1E " + STR0069 )     // ### "Desconto permitdo"
		DisplayEnv( StatDisplay(), "2E " + STR0070 )     // ### "Tecle <ENTER> para continuar"
		
		MsgInfo(	STR0069 + CRLF + ;		// ### "Desconto permitdo"
					STR0070, STR0072)		// ### "Tecle <ENTER> para continuar" ### "Desconto"	

	// Desconto nao permitido
	CASE nOpcao == 2
		DisplayEnv( StatDisplay(), "1E " + STR0071 )     // ### "Desconto nao permitdo"
		DisplayEnv( StatDisplay(), "2E " + STR0070 )     // ### "Tecle <ENTER> para continuar"
		
		MsgInfo(	STR0071 + CRLF + ;		// ### "Desconto nao permitdo"
					STR0070, STR0072)		// ### "Tecle <ENTER> para continuar" ### "Desconto"
	
END CASE

Return Nil

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtSetVPIi  ³Autor³ Vendas Clientes       ³ Data ³08/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descri‡„o ³	Transita o Valor do Array aItensVP entre os Fontes	 	  ³±±
±±³			 ³	FRTA271 e FRTA271G.									  ³±±
±±³			 ³  Adiciona informacoes referente aos Itens de Vale Presente.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT - FRTA271G										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FrtSetVPIt(nItem, cCodProd	, cCodBar	, cProduto, ;
						cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
						cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet  )

AAdd(aItensVP, { nItem	, cCodProd	, cCodBar	, cProduto, ;
					cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
					cVlrPercIT	, cValIPIIT	, lLeitor	, cVlIcmRet } )

Return

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fr271aVlDt()
Funcao para validação de data para nfce e sat pois o sistema deve ser reinciado para ajustar as variaveis do dia
@author	Rene.lascano
@param     
@return     Retorno logico se a database divergir a variavel retorna falso para que o sistema nao permita digitação de movimento
@version	P11
@since	20/03/2018
/*/
//------------------------------------------------------------------------------------------------------------------

Function Fr271aVlDt(lValida)
Local lRet := .T.
/*
02 - Impresso a Abertura do Cupom
03 - Item Não Impresso
04 - Impresso o Item
05 - Solicitado o Cancelamento do Item
06 - Item Cancelado
*/
Default lValida := .F.
// Caso esteja realizando uma venda, permitir a finalização da venda
If lValida .Or. !SL1->L1_SITUA $ "02|03|04|05|06"  
	If dDataBase <> Date()
		lRet := .F.
	EndIf	
EndIf

Return lRet

