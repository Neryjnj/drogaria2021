#INCLUDE "PROTHEUS.CH" 
#INCLUDE "DROVDLNK.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FRTDEF.CH"

//Definicao de variavel em objeto
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

//Definicao do DEFAULT
#xcommand DEFAULT <uVar1> := <uVal1> ;
     	   [, <uVarN> := <uValN> ] => ;
           <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
		   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
                                  
//Armazena parametros da venda 
Static aParamVL 	:= {}
Static nNumPBM		:= 0
Static nVLP_NVIDAL 	:= 0 // 1 - Gravar VidaLink ; 2 - Jah Gravado VidaLink
Static lCanTelMeC	:= .F.
                                
//Utilizados para conexão RPC da TOTVSVIDA.DLL
Static oRPCServer
Static cRPCServer
Static nRPCPort
Static cRPCEnv
Static cRPCEmp 
Static cRPCFilial

Static _LOJA701PB := nil
Static lValidSitef:= .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLGet  ³ Autor ³ VENDAS CRM	                        ³ Data ³20/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita que o usuario digite o Numero da Autorização. A seguir chama a    ³±±
±±³          ³ funcao DroVLCar() que faz o "Carregamento" dos dados de venda com os dados ³±±
±±³          ³ da cotação do VidaLink referente a este numero de autorizacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLGet( nOpPbm )
Local oNumAutori																				// Objeto do Numero de Autorizacao
Local oNumConv																					// Objeto do Numero do Convenio
Local oNumCartao																				// Objeto do Numero do Cartao do Convenio
Local oDlg																						// Objeto da Caixa de Dialogo
Local oLbx          																			// Objeto do Grid
Local oTotVenda     																			// Objeto do Total da Venda
Local oGetCodCli																				// Objeto de exibicao do cCliCodLoj 
Local oNomeCli																					// Objeto de exibicao do Nome do Cliente
Local aKey		  := {}																			// Armazena SetKeys
Local aCab     	  := {STR0037, STR0038, STR0039, STR0040, STR0041, STR0042}						// Cabecalho do grid    {"Item","Codigo Barra","Produto","Qtd.Autor.","Qtd. a Comprar","Preço" }
Local aLin     	  := { { "", "" , "" , 0, 0, 0 } }												// Linha vazia para o grid
Local aTam    	  := {15,60,80,25,25,25}														// Dimensoes de cada campo do grid
Local nTotVenda   := 0																			// Valor total da venda
Local _cNumAutori := Space(12)																	// Numero da autorizacao
Local _cNumConv   := Space(06)																	// Numero do convenio
Local _cNumCartao := Space(18)																	// Numero do cartao do convenio
Local _cNumAutAnt := Space(12)																	// Numero da autorizacao anterior
Local cCliCodLoj  := ""																			// CodigoCliente - CodigoLoja
Local cNomeCli	  := ""																			// Nome do cliente
Local aListaConv  := {  '000026 - Projeto Faz Bem Teste ',;
						'000009 - Equilibre Saúde       ',;
						'000016 - Takeda - Sempre Saude ',;
						'000022 - Lilly Melhor para Voce'}

// Objetos de pre-autorizacao PharmaLink - PBM 540
Local oCPF         	// Campo 502 do CLISITEF
Local oCRM			// Campo 1023 do CLISITEF
Local oUF			// Campo 1024 do CLISITEF

// Variaveis de pre-autorizacao PharmaLink - PBM 540
Local _cCPF     	:= Space(14) 		// Campo 502 do CLISITEF
Local _cCRM			:= Space(10)		// Campo 1023 do CLISITEF
Local _cUF			:= Space(02)		// Campo 1024 do CLISITEF
Local aVidalinkD	:= {}
Local aVidalinkC 	:= {}
Local lSigaLoja		:= nModulo == 12	// Se utiliza o modulo Venda Assistida
Local bGrvVend		:= Nil				//Bloco de codigo que será executado 
Local aRetPbm		:= {}				//Retorno das informacoes gravadas do PBM Funcional Card
Local lDrGScrExMC	:= NIL
Local lTotvsPDV		:= STFIsPOS()

DEFAULT nOpPbm 	  	:= 1				// Identifica o PBM

If lSigaLoja .Or. lTotvsPDV
	If Len(aParamVL) = 0
		T_DROVLPSet()
		aParamVL[1][VLP_AVLC] := {}
		aParamVL[1][VLP_AVLD] := {}
	EndIf

	If lTotvsPDV
		aParamVL[1][VLP_CCLIEN]	:= STDGPBasket( "SL1" , "L1_CLIENTE" )
		aParamVL[1][VLP_CLOJAC]	:= STDGPBasket( "SL1" , "L1_LOJA" )
		aParamVL[1][VLP_LCXABE]	:= STBCaixaVld()
		aRetPBM := STGDadosVL()
	Else
		aParamVL[1][VLP_CCLIEN]	:= M->LQ_CLIENTE
		aParamVL[1][VLP_CLOJAC]	:= M->LQ_LOJA
		aParamVL[1][VLP_LCXABE]	:= LjCxAberto(.T.,xNumCaixa())
		aRetPbm := LJGDadosVL()
	EndIf
	
	If Len(aRetPbm) > 2 .And. Len(aRetPbm[1]) > 0
		aParamVL[1][VLP_NVIDAL]	:= aRetPbm[3]
	Else
		aParamVL[1][VLP_NVIDAL] := 1
	EndIf

	aParamVL[1][VLP_AVLC] := aSize(aParamVL[1][VLP_AVLC],0)
	aParamVL[1][VLP_AVLD] := aSize(aParamVL[1][VLP_AVLD],0)
EndIf

If nOpPbm <> 540
	cCliCodLoj	:= aParamVL[1][VLP_CCLIEN] + " - " + aParamVL[1][VLP_CLOJAC]
	cNomeCli	:= Subst(Posicione("SA1",1,xFilial("SA1") + aParamVL[1][VLP_CCLIEN] + aParamVL[1][VLP_CLOJAC],"A1_NOME"),1,30)
Else
	If lTotvsPDV
		oTEF := STBGetTEF()
	Else
		oTEF := LJTEFAbre()	    				//Prepara o objeto TEF e carrega as variáveis necessárias par
	EndIf
Endif

nNumPbm	:= nOpPbm	//nNumPBM é uma variavel estatica
T_DROLCS()

If nOpPbm <> 540 .AND. !aParamVL[1][VLP_LCXABE]
	MsgStop(OemToAnsi(STR0007), OemToAnsi(STR0002)) // O Caixa não está aberto. Não será possível alterar o cliente
	Return(NIL)
EndIf

If nOpPbm <> 540 .AND. aParamVL[1][VLP_NVIDAL] == 2 	// Jah Gravado VidaLink
	MsgStop(STR0014 + CHR(10) + STR0015, STR0002) // Nesta venda ja foi utilizado um orçamento da VidaLink., Atenção #"Para utilizar novamente saia da rotina de venda e abra novamente."
	Return(NIL)
EndIf

If !lTotvsPDV
	aKey := FRTSetKey()  //Cancela temporariamente as SetKey's do Fechamento da Venda
EndIf

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 400,650 PIXEL      // Carregamento de Cotação da VidaLink

	If nOpPbm <> 540
	 	oLbx:=TwBrowse():New(055,010,310,100,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  // coordenadas lin.ini, pos.ini, largura, altura
	Else
	 	oLbx:=TwBrowse():New(085,010,310,100,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  // coordenadas lin.ini, pos.ini, largura, altura	
	Endif
	 	
	oLbx:lColDrag	:= .T.
	oLbx:nFreeze	:= 1
	oLbx:bLDblClick :={ || T_DROVLEQtd(@aLin, @aParamVL[1][VLP_AVLD], oLbx, @nTotVenda, @oTotVenda  ) }
	oLbx:SetArray(aLin)
	oLbx:bLine		:= { || { Transform( aLin[oLbx:nAt][1], '') , Transform( aLin[oLbx:nAt][2], '') ,;
				 Transform( aLin[oLbx:nAt][3], ''), Transform( aLin[oLbx:nAt][4], '@E 999,999,999.99'),;
				 Transform( aLin[oLbx:nAt][5], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][6], '@E 999,999,999.99')  } }
	oLbx:Refresh()
	
	//VidaLink so precisa do numero de autorizacao
	If nOpPbm	== 1
		@ 05,010 SAY STR0004 OF oDlg PIXEL
		@ 05,100 GET oNumAutori VAR _cNumAutori  VALID T_DroVLCar( 	@_cNumAutori, @_cNumAutAnt	, @aLin						, @aParamVL[1][VLP_AVLD]	,; 
																	@nTotVenda	, @oTotVenda	, @oLbx						, nNumPbm					,;
																	""			, ""			, aParamVL[1][VLP_CCLIEN]	, @aParamVL[1][VLP_CLOJAC] 	,;
																				,				,							) SIZE 50,7 PIXEL PICTURE "999999999999"
	Else
	
		If nOpPbm	== 540
	
			@ 005,010 SAY "CPF Titular: " OF oDlg PIXEL
			@ 005,040 GET oCPF VAR _cCPF   SIZE 50,7 PIXEL PICTURE "99999999999"

			@ 020,010 SAY "CRM: " OF oDlg PIXEL
			@ 020,040 GET oCRM VAR _cCRM  PIXEL PICTURE "9999999999"
			
			@ 020,170 SAY "UF CRM: " OF oDlg PIXEL
			@ 020,200 GET oUF VAR _cUF   PIXEL PICTURE "@!"					
	
		//PharmaSystem tem que informar o cartao do convenio ou o CPF do cliente
		ElseIf nOpPbm	== 541  //544
			
			@ 005,010 SAY STR0004 OF oDlg PIXEL
			@ 005,100 GET oNumAutori VAR _cNumAutori   SIZE 50,7 PIXEL PICTURE "999999999999"
				
			@ 005,170 SAY "Convenio : " OF oDlg PIXEL

  			_cNumConv	:= aListaConv[1]

		  	oNumConv := TComboBox():New(005,200,{|u|if(PCount()>0,_cNumConv:=u,_cNumConv)},; 
		    							aListaConv,090,007,oDlg,,{||_cNumConv := Substr(_cNumConv,1,6)}; 
		    							,,,,.T.,,,,,,,,,'_cNumConv')  
			
			@ 020,170 SAY "Cartao : " OF oDlg PIXEL
			@ 020,200 GET oNumCartao VAR _cNumCartao   PIXEL PICTURE "999999999999999999"
			 
		ElseIf	nOpPbm == 560 		
			@ 005,010 SAY STR0004 OF oDlg PIXEL
			@ 005,100 GET oNumAutori VAR _cNumAutori   SIZE 50,7 PIXEL PICTURE "999999999999"
			
			@ 005,170 SAY "Cartao : " OF oDlg PIXEL
			@ 005,200 GET oNumCartao VAR _cNumCartao   PIXEL PICTURE "999999999999999999"
		Endif

		If nOpPbm <> 540 		
	    	@ 175,240 BUTTON "Pesquisar" SIZE 39,12 OF oDlg PIXEL ACTION T_DroVLCar( 	@_cNumAutori, @_cNumAutAnt	, @aLin						, @aParamVL[1][VLP_AVLD]	,; 
				    																	@nTotVenda	, @oTotVenda	, @oLbx						, nNumPbm					,; 
		    																			_cNumConv	,_cNumCartao	, aParamVL[1][VLP_CCLIEN]	, @aParamVL[1][VLP_CLOJAC]	,;
	    																				_cCPF  		, _cCRM			, _cUF 						)
	    Else
	    	@ 175,240 BUTTON "Pesquisar" SIZE 39,12 OF oDlg PIXEL ACTION T_DroVLCar( 	@_cNumAutori, @_cNumAutAnt	, @aLin			, @aVidalinkD	,; 
				    																	@nTotVenda	, @oTotVenda	, @oLbx			, nNumPbm		,; 
		    																			_cNumConv	,_cNumCartao	, @aVidalinkC	, Nil			,;
	    																				_cCPF  		, _cCRM			, _cUF 			)	    
	    Endif																						
		
	Endif

 	If nOpPbm <> 540
		@ 020,010 SAY STR0008 OF oDlg PIXEL
		@ 020,100 GET oTotVenda VAR nTotVenda  When .F. SIZE  50,7 PIXEL PICTURE "@E 999,999,999.99"

 
		@ 035,070 SAY STR0011
		@ 035,100 GET oGetCodCli VAR cCliCodLoj  When .F. SIZE  50,7 PIXEL PICTURE "@!"
		@ 035,150 GET oNomeCli   VAR cNomeCli    When .F. SIZE 120,7 PIXEL PICTURE "@!"
		
		/*
		Conforme encontrado na internet bloqueado a troca de cliente, pois essa operação 
		se torna proibida. 
		Com isso é necessário usar o mesmo cliente da venda na pesquisa da PBM
		https://www.funcionalcorp.com.br/com/atendimento-ao-cliente-no-pdv/
		*/
		 
		/*
		If !lSigaLoja
			@ 035,010 BUTTON STR0043 SIZE 50,15 OF oDlg PIXEL ACTION ( T_DROVLACli(@aParamVL[1][VLP_CCLIEN], @aParamVL[1][VLP_CLOJAC], @cCliCodLoj, @oGetCodCli, @cNomeCli, @oNomeCli ) ) // STR0043 "Altera Cliente"
		EndIf
		*/	
	Else
	
		@ 050,010 SAY STR0008 OF oDlg PIXEL
		@ 050,100 GET oTotVenda VAR nTotVenda  When .F. SIZE  50,7 PIXEL PICTURE "@E 999,999,999.99"
			
		@ 065,070 SAY STR0011
		@ 065,100 GET oGetCodCli VAR cCliCodLoj  When .F. SIZE  50,7 PIXEL PICTURE "@!"
		@ 065,150 GET oNomeCli   VAR cNomeCli    When .F. SIZE 120,7 PIXEL PICTURE "@!"
		@ 065,010 BUTTON STR0043 SIZE 50,15 OF oDlg PIXEL ACTION ( T_DROVLACli(  @aParamVL[1][VLP_CCLIEN], @aParamVL[1][VLP_CLOJAC], @cCliCodLoj, @oGetCodCli,;
																				 @cNomeCli				 , @oNomeCli 			   ) ) // STR0043 "Altera Cliente"
	Endif		
		 						
	If nOpPbm == 540
		@ 175,130 BUTTON STR0044 SIZE 39,12 OF oDlg PIXEL ;
				ACTION If( T_DROVLConf(  {"",""}	, aVidalinkD, @nTotVenda, nTotVenda,;
										 @oTotVenda , "000001"	, "01"		, lTotvsPDV),;
							oDlg:End(),oDlg:End()) // STR0044 "Confirma"
	Else
						 
		If lSigaLoja
			bGrvVend := {|| LJMsgRun("Adicionando itens ao orçamento...",,{|| DroAddProd(@aParamVL[1][VLP_AVLD][2]) }),oDlg:End()}
		
		ElseIf lTotvsPDV
			bGrvVend := {|| STFMessage("DROVLGet1", "RUN", "Adicionando itens ao orçamento...",;
							 {|| DroAddProd(@aParamVL[1][VLP_AVLD][2]) }, STFShowMessage("DROVLGet1"), oDlg:End() )}
		Else

			bGrvVend := {|| ;
						FR271HCarrega(oDlg					, Nil						, @aParamVL[1][27]			, @aParamVL[1][145]	,;
									 @aParamVL[1][1]		, @aParamVL[1][2]			, @aParamVL[1][3]			, @aParamVL[1][4]	,;
									 @aParamVL[1][157]		, @aParamVL[1][45] 			, @aParamVL[1][7]			, @aParamVL[1][8]	,;
									 @aParamVL[1][9]		, @aParamVL[1][10]			, @aParamVL[1][11]			, @aParamVL[1][14]	,;
									 @aParamVL[1][5]		, @aParamVL[1][13]			, @aParamVL[1][150]			, @aParamVL[1][29]	,;
									 @aParamVL[1][33]		, @aParamVL[1][61] 			, @aParamVL[1][151]			, @aParamVL[1][15]	,;
									 @aParamVL[1][34]		, @aParamVL[1][35] 			, @aParamVL[1][37]			, @aParamVL[1][38]	,;
									 @aParamVL[1][12]		, @aParamVL[1][17] 			, @aParamVL[1][44]			, @aParamVL[1][28]	,;
									 @aParamVL[1][30]		, @aParamVL[1][31]	 		, @aParamVL[1][32]			, @aParamVL[1][36]	,;
									 @aParamVL[1][39]		, @aParamVL[1][52] 			, @aParamVL[1][53]			, @aParamVL[1][54]	,;
									 @aParamVL[1][55]		, @aParamVL[1][59] 			, @aParamVL[1][60]			, @aParamVL[1][62]	,;
									 @aParamVL[1][158]		, @aParamVL[1][63] 			, @aParamVL[1][152]			, @aParamVL[1][153]	,;
									 Nil					, @aParamVL[1][65] 			, @aParamVL[1][66]			, @aParamVL[1][66]	,;
									 @aParamVL[1][69]		, @aParamVL[1][70] 			, @aParamVL[1][71]			, @aParamVL[1][74]	,;
									 @aParamVL[1][75]		, @aParamVL[1][76] 			, @aParamVL[1][77]			, @aParamVL[1][78]	,;
									 @aParamVL[1][79]		, @aParamVL[1][80] 			, @aParamVL[1][81]			, @aParamVL[1][82]	,;
									 @aParamVL[1][83]		, @aParamVL[1][84] 			, @aParamVL[1][85]			, @aParamVL[1][86]	,;
									 @aParamVL[1][VLP_AVLD]	, @aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_NVIDAL]	, @aParamVL[1][90]	,;
									 @aParamVL[1][91]		, @aParamVL[1][92] 			, @aParamVL[1][93] 			, @aParamVL[1][94]	,;
									 @aParamVL[1][91]		, @aParamVL[1][96] 			, @aParamVL[1][97]			, @aParamVL[1][98]	,;
									 @aParamVL[1][99]		, @aParamVL[1][100]			, @aParamVL[1][101]			, @aParamVL[1][102]	,;
									 @aParamVL[1][103]		, @aParamVL[1][104]			, @aParamVL[1][105]			, @aParamVL[1][106]	,;
									 @aParamVL[1][107]		, @aParamVL[1][16] 			, Nil			   			, @aParamVL[1][111]	,;
									 @aParamVL[1][112]		, @aParamVL[1][113]			, @aParamVL[1][114]			, @aParamVL[1][115]	,;
									 @aParamVL[1][118]		, @aParamVL[1][26]	 		, @aParamVL[1][51]			, @aParamVL[1][67]	,;
									 @aParamVL[1][139]		, @aParamVL[1][155]			, Nil						, Nil				,;
									 @aParamVL[1][144]		, @aParamVL[1][143]			, @aParamVL[1][142]			, Nil				,;
									 @aParamVL[1][147]		, @aParamVL[1][49]			, @aParamVL[1][50]			, Nil				,;
									 @aParamVL[1][6]		, @aParamVL[1][141]			, @aParamVL[1][159]			, Nil				,;
									 Nil),oDlg:End()}
		EndIf
		
		@ 175,130 BUTTON STR0044 SIZE 39,12 OF oDlg PIXEL ACTION; // STR0044 "Confirma"
		 			If( T_DROVLConf(@aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL],;
		 			 				@nTotVenda				, @oTotVenda			, @aParamVL[1][VLP_CCLIEN],;
		 			 				@aParamVL[1][VLP_CLOJAC] ),;
		 			 				Eval(bGrvVend), oDlg:End() )
	Endif
	
    @ 175,180 BUTTON "Sair" SIZE 39,12 OF oDlg PIXEL ACTION If( !lValidSitef .And. T_DROVLCanc( @aParamVL[1][VLP_AVLC], @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL], @nTotVenda, @oTotVenda ) ,  oDlg:End() , )
    
    If nOpPbm <> 540
		oNumAutori:SetFocus()			// Forca o foco inicial neste get
	Else
		oCPF:SetFocus()			// Forca o foco inicial neste get
	Endif
		
	ACTIVATE DIALOG oDlg CENTERED
	
	//Significa que a tela de produtos controlados foi cancelada e com isso deve cancelar tudo
	lDrGScrExMC := T_DrGScrExMC()
	If lDrGScrExMC
		T_DROVLCanc( @aParamVL[1][VLP_AVLC], @aParamVL[1][VLP_AVLD], @aParamVL[1][VLP_NVIDAL], @nTotVenda, NIL , .T.)
		T_DrSScrExMC( .F. )
	EndIf
	
	If !lTotvsPDV
		FRTSetKey(aKey) //Restaura as SetKey's do Fechamento da Venda
	EndIf
	
	If nOpPbm <> 540
		FRT271aVL({aParamVL[1][VLP_AVLD], aParamVL[1][VLP_AVLC], aParamVL[1][VLP_NVIDAL]})
	Endif	
	
	If nOpPbm <> 540 .AND. aParamVL[1][VLP_NVIDAL] == 1  // Gravar VidaLink
		If !lSigaLoja .And. !lTotvsPDV
			FR271HCarrega(   oDlg					, Nil						, @aParamVL[1][27]			, @aParamVL[1][145]	,;
							 @aParamVL[1][1]		, @aParamVL[1][2]			, @aParamVL[1][3]			, @aParamVL[1][4]	,;
							 @aParamVL[1][157]		, @aParamVL[1][45] 			, @aParamVL[1][7]			, @aParamVL[1][8]	,;
							 @aParamVL[1][9]		, @aParamVL[1][10]			, @aParamVL[1][11]			, @aParamVL[1][14]	,;
							 @aParamVL[1][5]		, @aParamVL[1][13]			, @aParamVL[1][150]			, @aParamVL[1][29]	,;
							 @aParamVL[1][33]		, @aParamVL[1][61] 			, @aParamVL[1][151]			, @aParamVL[1][15]	,;
							 @aParamVL[1][34]		, @aParamVL[1][35] 			, @aParamVL[1][37]			, @aParamVL[1][38]	,;
							 @aParamVL[1][12]		, @aParamVL[1][17] 			, @aParamVL[1][44]			, @aParamVL[1][28]	,;
							 @aParamVL[1][30]		, @aParamVL[1][31]	 		, @aParamVL[1][32]			, @aParamVL[1][36]	,;
							 @aParamVL[1][39]		, @aParamVL[1][52] 			, @aParamVL[1][53]			, @aParamVL[1][54]	,;
							 @aParamVL[1][55]		, @aParamVL[1][59] 			, @aParamVL[1][60]			, @aParamVL[1][62]	,;
							 @aParamVL[1][158]		, @aParamVL[1][63] 			, @aParamVL[1][152]			, @aParamVL[1][153]	,;
							 Nil					, @aParamVL[1][65] 			, @aParamVL[1][66]			, @aParamVL[1][66]	,;
							 @aParamVL[1][69]		, @aParamVL[1][70] 			, @aParamVL[1][71]			, @aParamVL[1][74]	,;
							 @aParamVL[1][75]		, @aParamVL[1][76] 			, @aParamVL[1][77]			, @aParamVL[1][78]	,;
							 @aParamVL[1][79]		, @aParamVL[1][80] 			, @aParamVL[1][81]			, @aParamVL[1][82]	,;
							 @aParamVL[1][83]		, @aParamVL[1][84] 			, @aParamVL[1][85]			, @aParamVL[1][86]	,;
							 @aParamVL[1][VLP_AVLD]	, @aParamVL[1][VLP_AVLC]	, @aParamVL[1][VLP_NVIDAL]	, @aParamVL[1][90]	,;
							 @aParamVL[1][91]		, @aParamVL[1][92] 			, @aParamVL[1][93] 			, @aParamVL[1][94]	,;
							 @aParamVL[1][91]		, @aParamVL[1][96] 			, @aParamVL[1][97]			, @aParamVL[1][98]	,;
							 @aParamVL[1][99]		, @aParamVL[1][100]			, @aParamVL[1][101]			, @aParamVL[1][102]	,;
							 @aParamVL[1][103]		, @aParamVL[1][104]			, @aParamVL[1][105]			, @aParamVL[1][106]	,;
							 @aParamVL[1][107]		, @aParamVL[1][16] 			, Nil			   			, @aParamVL[1][111]	,;
							 @aParamVL[1][112]		, @aParamVL[1][113]			, @aParamVL[1][114]			, @aParamVL[1][115]	,;
							 @aParamVL[1][118]		, @aParamVL[1][26]	 		, @aParamVL[1][51]			, @aParamVL[1][67]	,;
							 @aParamVL[1][139]		, @aParamVL[1][155]			, Nil						, Nil				,;
							 @aParamVL[1][144]		, @aParamVL[1][143]			, @aParamVL[1][142]			, Nil				,;
							 @aParamVL[1][147]		, @aParamVL[1][49]			, @aParamVL[1][50]			, Nil				,;
							 @aParamVL[1][6]		, @aParamVL[1][141]			, @aParamVL[1][159]			, Nil				,;
							 Nil)	
		EndIf
	EndIf
Return Nil
                      
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLCar  ³ Autor ³ VENDAS CRM	                        ³ Data ³20/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega a cotacao criada no Host VidaLink no array aVidaLinkD para inico da³±±
±±³          ³ operacao de venda no FrontLoja, referente ao numero de autorizacao digitado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                     					  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLCar( _cNumAutori	, _cNumAutAnt	, aLin			, aVidaLinkD	, ;
							nTotVenda	, oTotVenda		, oLbx			, nNumPbm		, ;	 
							_cNumConv	,_cNumCartao	,  _cCliente	, _cLoja		, ;
							cCPF 		,cNumCRM		, cUFCRM		)

Local I 		:= 0 	//Contador
Local _cCPF		:= ""	//CPF do Cliente
Local nValor	:= 0	//Valor do produto retornado pela Funcional Card
Local lContinua	:= .T.
Local lRet		:= .T.
Local lTotvsPDV :=  STFIsPOS()

Default cCPF 	:= ""
Default cNumCRM := ""
Default cUFCRM	:= ""

lValidSitef := .T.

// Se nao mudou o num. da autorização, não carrego dados novamente 
// para não perder alteracoes na quantidade efetuadas pelo usuario.
If Empty(_cNumAutori) .AND. Empty(_cNumAutAnt ) .AND. nNumPbm <> 540
	lValidSitef := .F.
	lContinua	:= .F.
	lRet := .T.
Endif

If lContinua
	If Empty(cCPF)
		_cCPF := Posicione("SA1",1,xFilial("SA1") + _cCliente + _cLoja,"A1_CGC")
	Else
		_cCPF := cCPF
	Endif	
		
	aVidaLinkD := {}
				
	If nNumPbm <> 540
		If _cNumAutori == _cNumAutAnt
			lContinua := .F.
			lRet := .T.
		Else
			_cNumAutAnt := _cNumAutori
		EndIf
	Endif
EndIf

If lContinua

	aAdd(aVidaLinkD,{_cNumAutori, _cNumConv, _cNumCartao, _cCPF, nNumPbm, cNumCRM, cUFCRM })
	nTotVenda  := 0
	
	//Consulta Vidalink
	If nNumPbm == 1
		If lTotvsPDV
		Else
			oTEF:Operacoes("VIDALINK_CONSULTA"		, aVidaLinkD)
		EndIf
	//Consulta PharmaSystem
	ElseIf nNumPbm == 541
		If lTotvsPDV
		Else
			oTEF:Operacoes("PHARMASYSTEM_CONSULTA"	, aVidaLinkD)     
		EndIf
	ElseIf  nNumPbm == 540
		If lTotvsPDV
		Else
			oTEF:Operacoes("PHARMASYSTEM_AUTORIZA"	, aVidaLinkD)
		EndIf
	//Consulta Funcional Card
	ElseIf nNumPbm == 560
		If lTotvsPDV
		Else
			oTEF:Operacoes("FUNCARD_CONSULTA"		, aVidaLinkD)
		EndIf
	Endif

	If lTotvsPDV
	
	Else

		If oTEF:lTEFOk
			aAdd(aVidaLinkD, {} )
			aAdd(aVidaLinkD, 0  )  
			
			For I := 1 to oTEF:aRetVidaLink:nQtdeMed
				If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 540	//PharmaSystem
		
					aAdd(aVidaLinkD[VL_DETALHE], ;
							{ oTEF:aRetVidaLink:aItems[i]:nIndice     												,;
								oTEF:aRetVidaLink:aItems[i]:cCodigo     											  	,;
								oTEF:aRetVidaLink:aItems[i]:nQuantAut   												,;
								oTEF:aRetVidaLink:aItems[i]:nValLiq													,; 	// nValConsum
								oTEF:aRetVidaLink:aItems[i]:nValLiq	  												,;  // nPreco de Venda da Farmacia
								oTEF:aRetVidaLink:aItems[i]:nQuantAut     												,;  // Quantidade sem alteracao 
								oTEF:aRetVidaLink:aItems[i]:nValTot	   												,;	// Preco de venda VidaLink			 
								0																						,;	// Valor do Subusidio
								oTEF:aRetVidaLink:aItems[i]:nValLiq	 												})	// Valor pago a vista
		
					nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValLiq
		
				ElseIf oTef:nCodFuncao == 560	//Funcional Card
					
					If AllTrim(oTEF:aRetVidaLink:aItems[i]:cPrecoFun) == "0"
						nValor := oTEF:aRetVidaLink:aItems[i]:nValorFC
					Else
						nValor := oTEF:aRetVidaLink:aItems[i]:nValorPrat
					EndIf
					
					aAdd(aVidaLinkD[VL_DETALHE], ;
							{ oTEF:aRetVidaLink:aItems[i]:nIndice     												,;
								oTEF:aRetVidaLink:aItems[i]:cCodigo     											  	,;
								oTEF:aRetVidaLink:aItems[i]:nQuantAut   												,;
								oTEF:aRetVidaLink:aItems[i]:nValConsum													,; 	// nValConsum
								nValor	  																				,;  // nPreco de Venda da Farmacia
								oTEF:aRetVidaLink:aItems[i]:nQuantAut     												,;  // Quantidade sem alteracao 
								oTEF:aRetVidaLink:aItems[i]:nValTot	   												,;	// Preco de venda VidaLink			 
								0																						,;	// Valor do Subusidio
								oTEF:aRetVidaLink:aItems[i]:nValConsum	 												})	// Valor pago a vista
		
					nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValLiq
		
				Else		               
				
					aAdd(aVidaLinkD[VL_DETALHE], ;
							{ oTEF:aRetVidaLink:aItems[i]:nIndice     												,;
								oTEF:aRetVidaLink:aItems[i]:cCodigo     											  	,;
								oTEF:aRetVidaLink:aItems[i]:nQuantAut   												,;
								oTEF:aRetVidaLink:aItems[i]:nPrecoRecomend												,; 	// nValConsum
								oTEF:aRetVidaLink:aItems[i]:nValVendFarm  												,;  // nPreco de Venda da Farmacia
								oTEF:aRetVidaLink:aItems[i]:nQuantAut     												,;  // Quantidade sem alteracao 
								oTEF:aRetVidaLink:aItems[i]:nPrecoMax   												,;	// Preco de venda VidaLink			 
								oTEF:aRetVidaLink:aItems[i]:nValSubsidio + oTEF:aRetVidaLink:aItems[i]:nValReembFarm	,;	// Valor do Subusidio
								oTEF:aRetVidaLink:aItems[i]:nValConsum 												})	// Valor pago a vista
					
					nTotVenda += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nValVendFarm
		
				Endif
			Next
			
			aVidaLinkD[VL_TOTVEND] := nTotVenda  	    
			aAdd(aVidaLinkD,oTef:cCupom)
			
			If Empty( aVidaLinkD[VL_DETALHE] )
				MsgStop(STR0005, STR0002)		//Não encontrado nenhum item na cotação do VidaLink para este numero de autorização
			EndIf
		Else
			MsgStop(STR0006, STR0002)			//Não encontrado cotação no VidaLink para este numero de autorização	
		EndIf
	EndIf

	T_DROVLMItem( @aLin, @nTotVenda, @oTotVenda, @oLbx, @aVidaLinkD )  // Mostra os Itens autorizados pelo VidaLink
EndIf

lValidSitef := .F.

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROVLMItemºAutor  ³VENDAS CRM	  		 º Data ³ 26/04/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os Itens (produto, qtd, preco, etc) autorizados     º±±
±±º          ³ pelo VidaLink                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso		 ³ Front Loja com Template Drogarias        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLMItem( aLin, nTotVenda, oTotVenda, oLbx, aVidaLinkD )
Local _nI 			:= 0						// Contador
Local nBarras 		:= TamSX3("BI_CODBAR")[1]	// Dimensao do codigo de barras
Local cCodBarras 	:= ""					 	// Codigo de barras
Local lSigaLoja		:= nModulo == 12			// Se utiliza o modulo Venda Assistida
Local cTabelaProd	:= "SBI"					// Tabela para consulta do produto
Local cCamDescProd	:= "BI_DESC" 				// Campo para consultado do pruduto
Local nVlSubsidio	:= 0						//Valor do Subsidio

If lSigaLoja
	cTabelaProd 	:= "SB1"
	cCamDescProd 	:= "B1_DESC"
	nBarras			:= TamSX3("B1_CODBAR")[1]
EndIf

If Len( aVidaLinkD ) == 4 
	aLin := {}
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Itens a ser exibido - aVidaLinkD", aVidaLinkD )
	
	For _nI := 1 to Len( aVidaLinkD[VL_DETALHE] )
		cCodBarras := PadR( aVidaLinkD[VL_DETALHE, _nI , VL_EAN ], nBarras )  
		cDescProd := Posicione(cTabelaProd,5,xFilial(cTabelaProd)+ cCodBarras  ,cCamDescProd)	//Com o codigo de barra (EAN) pego a descricao do Produto
		cDescProd := If(Empty(cDescProd) , STR0016, cDescProd ) //"Não encontrado produto com este código"

		nVlSubsidio := IIf(oTef:nCodFuncao == 902 .And. (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - aVidaLinkD[VL_DETALHE,_nI,VL_SUBSIDI] <=0) , 0 , aVidaLinkD[VL_DETALHE,_nI,VL_SUBSIDI] )
		
		aAdd(aLin , {	aVidaLinkD[VL_DETALHE,_nI,VL_NDXPROD]	,;  																					// Indice
  					    aVidaLinkD[VL_DETALHE,_nI,VL_EAN  ]		,;   		  																			// Cod Barra
  					    cDescProd            					,; 	  																					// Desc. Produto
  					    aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ]	,;   		  																			// Quantidade Autorizada
  					    aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ]	,;				 																		// Quantidade Compra
						aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ] * (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - nVlSubsidio) ,; 	// Preco de venda
						aVidaLinkD[VL_DETALHE,_nI,VL_QUANTID ] * (aVidaLinkD[VL_DETALHE,_nI,VL_PRVENDA ] - nVlSubsidio) } )	// Valor a pagar
	Next
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Montagem da linha de cada produto - aLin", aLin )

	If Len(aLin) > 0 .AND. oLbx <> Nil
		oLbx:SetArray(aLin)
		oLbx:bLine		:= { || { Transform( aLin[oLbx:nAt][1], '') , Transform( aLin[oLbx:nAt][2], '') , Transform( aLin[oLbx:nAt][3], ''), Transform( aLin[oLbx:nAt][4], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][5], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][6], '@E 999,999,999.99'), Transform( aLin[oLbx:nAt][7], '@E 999,999,999.99')  } }
		oLbx:Refresh()
		nTotVenda := aVidaLinkD[VL_TOTVEND]

		oTotVenda:Refresh()
	Endif	
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLACli ³ Autor ³ VENDAS CRM	         ³ Data ³05/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o cliente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias 		                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLACli( cCodCli, cLojCli, cCliCodLoj, oGetCodCli,;
							 cNomeCli, oNomeCli )

Local lTotvsPDV := STFIsPOS()

If lTotvsPDV
	//JULIO - DESENVOLVER
Else
	FR271EAltCli( Nil		   				, @cCodCli		   			, @cLojCli		   			, @aParamVL[1][VLP_LOCIOS]	,;
				@aParamVL[1][VLP_LRECEB]	, @aParamVL[1][VLP_LCXABE]	, @aParamVL[1][VLP_ACRDCL]	, @aParamVL[1][VLP_CCODCO]	,;
				@aParamVL[1][VLP_CLOJAC]	, @aParamVL[1][VLP_CNUMCA] 	, @aParamVL[1][VLP_UCLITP]	, @aParamVL[1][VLP_UPRODT]	,;
				@aParamVL[1][VLP_AITENS]	, Nil		   				, Nil						, @aParamVL[1][VLP_CTIPOC]	,;
				Nil							, Nil			  			, Nil						, Nil 						)
EndIf

cCliCodLoj	:= StrZero(Val(cCodCli), 6, 0) + " - " + cLojCli
cNomeCli	:= Subst(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_NOME"),1,30)

If !lTotvsPDV
	oGetCodCli:Refresh()
	oNomeCli:Refresh()
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROVLEQtd ºAutor  ³VENDAS CRM			 º Data ³ 03/05/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para editar a quantidade a ser Vendida por item        º±±
±±º          ³Quantidade pode variar de zero ateh qtd liberada pelo PBM   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja com Template Drogarias                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLEQtd(aLin, aVidaLinkD, oLbx, nTotVenda, oTotVenda)
Local nQtdeComp := aLin[oLbx:nAt][ 5 ]	// Quantidade a comprar
Local nQtdeSug  := aLin[oLbx:nAt][ 4 ]	// Quantidade sugerida
Local oDlgqtd                           // Objeto da tela de dialogo

DEFINE MSDIALOG oDlgqtd FROM  69,70 TO 160,331 TITLE "Quantidade a comprar" PIXEL
	@ 1, 02 TO 24, 128 OF oDlgqtd	PIXEL
	@ 7, 68 MSGET nQtdeComp Picture "@E 9999999.99" VALID IIF(nQtdeComp <= nQtdeSug .AND. nQtdeComp >= 0, .T.,  (Alert("A quantidade a comprar deve ser menor ou igual a quantidade autorizada."), .F.)) SIZE 54, 10 OF oDlgqtd PIXEL
	@ 8, 09 SAY "Quantidade a comprar"  SIZE 54, 7 OF oDlgqtd PIXEL
	DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (IIf( nQtdeComp <= nQtdeSug .And. nQtdeComp >= 0 , (aLin[oLbx:nAt][ 5 ]:=nQtdeComp,  If(!Empty(aVidaLinkD) , aVidaLinkD[VL_DETALHE, oLbx:nAt, VL_QUANTID ] :=nQtdeComp, ) , T_DROVLTot( @nTotVenda, @oTotVenda, @aVidaLinkD, @oLbx ) , oDlgqtd:End()), )) OF oDlgqtd
	DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION ( oDlgqtd:End() ) OF oDlgqtd
ACTIVATE MSDIALOG oDlgqtd CENTERED
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLTot  ³ Autor ³ VENDAS CRM     		                ³ Data ³04/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula o total da compra somando os itens                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLTot( nTotVenda, oTotVenda, aVidaLinkD,oLbx )
Local _nI := 0 // Contador

nTotVenda := 0    

If Len(aVidaLinkD) >= 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA])
		Next
	Endif
Endif

oLbx:AARRAY[oLbx:nAt][6 ] 	:= aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_QUANTID] *(aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_PRVENDA] - aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_SUBSIDI])
oLbx:AARRAY[oLbx:nAt][7 ] 	:= aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_QUANTID] * aVidaLinkD[VL_DETALHE,oLbx:nAt,VL_PRVENDA]
aVidaLinkD[VL_TOTVEND]		:= nTotVenda  // Atualiza o totalizador do array aVidaLink tambem
oTotVenda:Refresh()
oLbx:Refresh()
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLConf ³ Autor ³ VENDAS CRM                     		³ Data ³27/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ No Botão Ok Checa o conteudo da Array aVidaLinkD. Se for valido fecha tela ³±±
±±³          ³ caso contrario continua na tela. Neste caso so sera possivel sair da tela  ³±±
±±³          ³ com o botão cancelar que configura a array aVidaLinkD como vazia.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLConf(	aVidaLinkC	,	aVidaLinkD	,	nVidaLink	,	nTotVenda	,;
 								oTotVenda	,	cCodCli		,	cLojCli		,   lTotvsPDV  )
Local lRet := .F.          	// Retorno da funcao  
Local _nI  := 0            	// Variavel para usa no for
Local aVdLnkDAux := {}     	// Array para auxiliar retorno dos dados
Local aVidalink  := {}     	// Array para enviar os dados para o Frontloja
Local lLojaFRT	 := .T.

Default lTotvsPDV:= .F.

lLojaFRT := !lTotvsPDV

// oTEF:aRetVidalink:cNumPreAut
nTotVenda := 0
If Len(aVidaLinkD) >= 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ])
		Next		

		aVidaLinkD[VL_TOTVEND] := nTotVenda  // Atualiza o totalizador do array aVidaLink tambem
		If oTotVenda <> Nil 
			oTotVenda:Refresh()
		Endif	  
		
		If nTotVenda > 0
			lRet := .T.
		Else
			MsgStop(STR0009,STR0002) // Nao existem itens de venda para este numero de Autorização
		EndIf
	EndIf
EndIf

If lRet
	If (Empty( cCodCli) .or. Empty(cLojCli) ) .or. !ExistCpo("SA1",cCodCli+cLojCli,1)
		lRet := .F.
		MsgStop(STR0012,STR0002) // Informe um codigo de Cliente e Loja Valido
	Endif
Endif

If lRet
	If lTotvsPDV
		// If 

		// Else
		// 	lRet := .T.
		// 	MsgAlert("Numero de Pre-Autorizacao Gerado: " /*+ oTEF:aRetVidalink:cNumPreAut*/)
		// EndIf
	Else
		If oTef:nCodFuncao <> 540 
			If oTef:nCodFuncao <> 560 //PBM Funcional Card
				lRet := MsgYesNo(STR0013,STR0002) // Confirma a Finalização da Venda para esta Autorização do VidaLink ?
			EndIf	
		Else
			lRet := .T.
			MsgAlert("Numero de Pre-Autorizacao Gerado: " + oTEF:aRetVidalink:cNumPreAut)		
		Endif
	EndIf
EndIf

If lRet
	aVidaLinkC := {cCodCli, cLojCli}	// Atualiza aVidaLinkC (Cabecalho) com codigo do Cliente e Loja
EndIf

If lRet
	For _nI := 1 to Len(aVidaLinkD[VL_DETALHE])
		If aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ]	> 0
			aAdd( aVdLnkDAux , aVidaLinkD[VL_DETALHE, _nI] )
		EndIf
	Next      
	
	aVidaLinkD[VL_DETALHE] := aVdLnkDAux
EndIf

If lRet
	nVidaLink := 1
Else
	nVidaLink := 0
EndIf      

aVidalink := {aVidaLinkD,aVidaLinkC,nVidalink}

//FrontLoja
FRT271aVL(aVidalink)  

//Venda Assistida
If Len(aVidaLinkD) > 0
	aVidalink := {aVidaLinkD,aVidaLinkC,2} 
	LJ7DadosVL(aVidalink) 
Else
	LJ7DadosVL({1})
EndIf
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLCanc ³ Autor ³ VENDAS CRM		                    ³ Data ³28/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ No Botão cancela fecha o dialogo e retorna a array aVidaLinkD vazia        ³±±
±±³          ³ Caso aVidaLinkD não esteja vazia pede a confirmação do cliente, avisando   ³±±
±±³          ³ que a array ficara vazia.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLCanc(	aVidaLinkC	,	aVidaLinkD	,	nVidaLink	,	nTotVenda	,;
 								oTotVenda	, 	lCancela	)
Local lRet := .T.	// Retorno da funcao
Local _nI  := 0		// Contador

Default lCancela := .F.

nTotVenda := 0        

If Len(aVidaLinkD) = 4
	If !Empty(aVidaLinkD[VL_DETALHE])
		For _nI := 1 To Len(aVidaLinkD[VL_DETALHE])
			nTotVenda += aVidaLinkD[VL_DETALHE, _nI, VL_QUANTID ] * (aVidaLinkD[VL_DETALHE, _nI, VL_PRVENDA ])
		Next
		
		If oTotVenda <> NIL
			oTotVenda:Refresh()
		EndIf

		If lCancela //Cancela direto sem perguntar
			lRet := .T.
		ElseIf nTotVenda > 0
			lRet := MsgYesNo(STR0010,STR0002) //Confirma o cancelamento do uso desta Autorização do VidaLink ?
		EndIf
	EndIf
EndIf

If lRet	   						// Confirmado o cancelamento do Uso do VidaLink
	aVidaLinkC			:= {}	// Zera array aVidaLinkC (Cabecalho)
	aVidaLinkD			:= {}	// Zera array aVidaLinkC (Detalhe)
	nVidaLink			:= 0	// Nao esta usando o Orcamento do VidaLink
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLVen  ³ Autor ³ VENDAS CRM		                    ³ Data ³26/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Após a conclusão da venda informa ao VidaLink os produto e quantidades     ³±±
±±³          ³ vendidos atraves da array aVidaLinkD.                                      ³±±
±±³          ³ Obs. As quantidades vendidas acima da autorização ou os produtos não auto- ³±±
±±³          ³      zados não serão incluidos na array aVidaLinkD e não terão os seus     ³±±
±±³          ³      preços sem os descontos do PBM.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLVen()
Local aRet := {}					// Retorno da funcao
Local _aVidaLinkC := ParamIxb[2]	// aVidalinkC
Local _aVidaLinkD := ParamIxb[3]	// aVidalinkD
Local _nVidaLink  := ParamIxb[1]	// nVidalink
Local _cDoc		  := ParamIxb[4]	// Numero do Cupom Fiscal

If _nVidaLink = 2  // Gravou VidaLink
	If nNumPbm == 1
		oTEF:Operacoes("VIDALINK_VENDA", _aVidaLinkD, , , _cDoc)			//VidaLink
	ElseIf nNumPbm = 541
		If Len(_aVidaLinkD) > 0
			oTEF:Operacoes("PHARMASYSTEM_VENDA", _aVidaLinkD, , , _cDoc)	//PharmaSystem	
		Endif
	ElseIf nNumPbm = 560
		If Len(_aVidaLinkD) > 0
			oTEF:Operacoes("FUNCARD_VENDA", _aVidaLinkD, , , _cDoc)			//Funcional Card	
		Endif
	ElseIf nNumPbm = 592
		If Len(_aVidaLinkD) > 0
			oTEF:Operacoes("FUNCARD_VENDA", _aVidaLinkD, , , _cDoc)			//Funcional Card	
		Endif		
	Endif
EndIf

_aVidaLinkC := {}	// Zera array aVidaLinkC (Cabecalho)
_aVidaLinkD := {}	// Zera array aVidaLinkD (Detalhe)

aAdd(aRet, _nVidaLink)
aAdd(aRet, aClone(_aVidaLinkC) )
aAdd(aRet, _aVidaLinkD)

Return aRet
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROVDLNK  ºAutor  ³Microsiga           º Data ³  06/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function CANPSys( )
                                                  
Local aVidaLinkD := {}

aAdd(aVidaLinkD, "" )
aAdd(aVidaLinkD, {} )
aAdd(aVidaLinkD, 0  )  
aAdd(aVidaLinkD, 0  )  
	
oTEF:Operacoes("PHARMASYSTEM_CANCELAMENTO", aVidaLinkD, , ,"")	//PharmaSystem	

Return .T.

/*-------------------------------------------------------------------------------------------
±±³Fun‡„o	 ³DROVLImp  ³ Autor ³ VENDAS CRM		                    ³ Data ³26/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Após a conclusão da venda imprime o comprovante de venda Vidalink no ECF   ³±±
±±³          ³ como no exemplo abaixo:                                                    ³±±
±±³          ³ DEMONSTRATIVO PBM VIDALINK@No.Autorizacao.: 123456                         ³±±
±±³          ³                                                                            ³±±
±±³          ³ Obs. Se existir pagamento com TEF, a impressão do cupom VIDALINK se dará   ³±±
±±³          ³      junto com o cupom TEF.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                    				      ³±±
-------------------------------------------------------------------------------------------*/
Template Function DROVLImp()
Local _nVidaLink := ParamIxb[1] // nVidalink
Local aRet := {}				// Retorno da Funcao
Local lTotvsPDV := STFIsPOS()

If _nVidaLink = 2  				// Gravou VidaLink, por isto imprimo cupom vidalink
	If lTotvsPDV
		//JULIOOOOOOO - inserir a chamada para o TotvsPDV
	Else
		oTEF:ImpCupTef()
	EndIf
	_nVidaLink := 0				// Zera variavel após a impressão do cupom
EndIf 

aAdd(aRet,_nVidaLink)
Return aRet

/*-------------------------------------------------------------------------------------------
±±³Fun‡„o	 ³DROVLBPro ³ Autor ³ VENDAS CRM				            ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de busca de produtos na chamada da DLL. 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
-------------------------------------------------------------------------------------------*/
Template Function DROVLBPro(cCodBarra, lIncProd)
Local cRet          := ""  	// Retorno da funcao
Local cDescrProd	:= ""  	// Descricao do produto
Local nPrecoPMC		:= 0   	// Preco Maximo Consumidor
Local nPrecoPromo	:= 0   	// Preco de venda do estabelecimento
Local lEncontrou	:= .F. 	// Encontrou o produto?
Local cCodProd	:= ""

Default lIncProd := .F.

DbSelectArea("SBI")
SBI->(DbSetorder(5))
				
If SBI->(DbSeek(xFilial("SBI") + PADR(cCodBarra, 13)))
	cDescrProd	:= SBI->BI_DESC
	nPrecoPMC	:= SBI->BI_PRV
	nPrecoPromo	:= SBI->BI_PRV
	cCodProd	:= SBI->BI_COD
	lEncontrou	:= .T.
EndIf

If lEncontrou
	cPrecoPMC	:= PadR(AllTrim(Str(nPrecoPMC,14,2)), 11)
	cPrecoPMC	:= StrTran(cPrecoPMC, '.', '', 1)
	cPrecoPromo	:= PadR(AllTrim(Str(nPrecoPromo,14,2)), 11)
	cPrecoPromo	:= StrTran(cPrecoPromo, '.', '', 1)
	cRet := Space(7) + PadR(cDescrProd, 35) + Space(12) + cPrecoPMC + cPrecoPromo + IIF( !lIncProd, Space(1), Space(1) + cCodProd)
Else
	cRet := ""
EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLCall ³ Autor ³ VENDAS CRM				            ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chamada apartir do VidaLink atravez de integração via DLL.          ³±±
±±³          ³ Na digitação do codigo de barra do produto no VidaLink, ele passa este     ³±±
±±³          ³ codigo para a DLL TOTVSVIDA.dll que invoca esta funcao tambem passando o   ³±±
±±³          ³ codigo de barra como parametro, esperando como retorno um strig de 75 bytes³±±
±±³          ³ com o formato abaixo.                                                      ³±±
±±³          ³----------------------------------------------------------------------------³±±
±±³          ³Inicio|Fim |Tamanho|Conteudo                                                ³±±
±±³          ³   01 | 07 | 07    | Espacos                                                ³±±
±±³          ³   08 | 43 | 35    | Descricao do Produto                                   ³±±
±±³          ³   44 | 54 | 11    | Espacos                                                ³±±
±±³          ³   55 | 64 | 10    | PMC - Preco Maximo ao Consumidor                       ³±±
±±³          ³   65 | 74 | 10    | Preco Promocional                                      ³±±
±±³          ³   75 | 75 | 01    | Espaco                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLCall(cFuncao, uParm1, uParm2, uParm3, uParm4, uParm5, uParm6)
	Local cRet := "" // Retorno da Funcao
    Local cEAN := "" // EAN do produto
    Local nX   := 0   
    Local nFor := 0
    Local aAuxSer := {}
    Local aServers:= {}
    Local lNewConnect := .F.
    Local lConnect	  := .F.
    	
	// Conexao RPC
	cRPCServer	:= uParm1
	nRPCPort	:= uParm2
	cRPCEnv		:= uParm3
	cRPCEmp		:= uParm4
    cRPCFilial	:= uParm5  
    cEAN 		:= uParm6
	
	nFor := FrtServRpc()		// Carrega o numero de servidores disponiveis 	

	For nX := 1 To nFor         //  Carrega os dados do server
		aAuxSer	:= FrtDadoRpc() 
		If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) 		
			Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
		EndIf
		aAuxSer := {}
	Next nX
	
	lNewConnect := .F.
	If oRPCServer == Nil
		ConOut(STR0021)				   							// "DROVLCall: Chamada ao VIDALINK"
		ConOut(STR0022) 			   							// "DROVLCall: Abrindo nova instancia RPC..."	
		oRPCServer:=FwRpc():New( cRPCServer, nRPCPort , cRpcEnv )	// Instancia o objeto de oServer	
		oRPCServer:SetRetryConnect(1)								// Tentativas de Conexoes
	
		For nX := 1 To Len(aServers)                            	// Metodo para adicionar os Servers 
			oRPCServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )
		Next nX
	
		ConOut(STR0023) 			   							// "DROVLCall: Conectando com o servidor..."	
		lConnect := oRPCServer:Connect()							// Tenta efetuar conexao
		lNewConnect := .T.
	Else
		lConnect 	:= .T.
		lNewConnect := .F.
	EndIf
	
	If lConnect
		If lNewConnect
			oRPCServer:CallProc("RPCSetType", 3 )
			oRPCServer:SetEnv(cRPCEmp,cRPCFilial,"FRT")                 // Prepara o ambiente no servidor alvo
		EndIf

		ConOut(STR0025) 										// "DROVLCall: Buscando produto..."
	   	cRet := oRPCServer:CallProc("T_DROVLBPro", cEAN)	   
		ConOut("Retorno: #" + cRet + "#")						// Exibe o retorno da funcao, que sera enviado para a DLL

		ConOut(STR0034) 										// "DROVLCALL: Desconectando..."
   		oRPCServer:Disconnect()			

		ConOut(STR0035)											// "DROVLCall: Finalizando VIDALINK"
		oRPCServer := Nil

		ConOut(STR0035)											// "DROVLCall: Fim da chamada ao VIDALINK"        */
	EndIf	
	
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLATbl ³ Autor ³ VENDAS CRM							³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para abrir as tabelas de produto SB0 e SBI na chamada da DLL. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLATbl(cCodEmp, cCodFil)
	Local cDrvX2  := "DBFCDX"				// Driver de acesso
	Local cArqX2  := "SX2" + cCodEmp + "0"	// Nome do arquivo SX2
	Local cArqIX  := "SIX" + cCodEmp + "0"	// Nome do arquivo SXI
	Local cDriver := "DBFCDX"				// Driver de acesso

	Public cFilAnt := cCodFil		  		// Usada no Matxfuna - xFilial                  
	Public cArqTAB := ""					// Usada no Matxfuna - xFilial
	             
	SET DELETED ON
	
	#IFDEF WAXS
		cDrvX2 := "DBFCDXAX"
	#ENDIF
	
	#IFDEF WCODB
		cDrvX2 := "DBFCDXTTS"
	#ENDIF
	                
	USE &("SIGAMAT.EMP") ALIAS "SM0" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0026) //"SM0 Open Failed"
	EndIf
	
	USE &(cArqIX) ALIAS "SIX" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0027) //"SIX Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0028) //"SIX Open Index Failed"
	EndIf
	
	USE &(cArqX2) ALIAS "SX2" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0029) //"SX2 Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0030) //"SX2 Open Index Failed"
	EndIf
	

	#IFDEF AXS
		cDriver := "DBFCDXAX"
	#ENDIF
	
	#IFDEF CTREE
		cDriver := "CTREECDX"
	#ENDIF
	
	#IFDEF BTV
		cDriver := "BTVCDX"
	#ENDIF
	
	T_DROVLAArq("SBI", cDriver)
	
	SET DELETED OFF
Return Nil
          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLAArq ³ Autor ³ VENDAS CRM							³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para abrir as tabelas individualmente.	    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLAArq(cAlias, cDriver)
	Local cArquivo := ""   
	
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek(cAlias)
	
	DbSelectArea("SX2")
	DbSetOrder(1)     
	
	If DbSeek(cAlias)
		cArquivo := AllTrim(SX2->X2_PATH) + AllTrim(SX2->X2_ARQUIVO)
	
		USE &(cArquivo) ALIAS &(cAlias) SHARED NEW VIA cDriver
		
		If NetErr()
			UserException(cAlias + STR0031) //" Open Failed"
		EndIf
		             
 		cArqTab += cAlias+SX2->X2_MODO
		DbSetOrder(1)
	
		If Empty(IndexKey())
			UserException(cAlias + STR0032) //" Open Index Failed"
		EndIf
	Else
		UserException(cAlias + STR0033) //" Not Found in SX2"
	EndIf
Return Nil
      
 
 
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLPSet   ³ Autor ³ VENDAS CRM							  ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para preencher o array aParamVL.	    				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        		   		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLPSet(	oHora			, cHora			, oDoc			, cDoc			,;
								oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;		
								nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;		
								oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;		
								cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;		
								nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;		
								oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;		
								nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;		
								nVlrItem		, oProduto		, oQuant		, oUnidade		,;		
								oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,; 	
								oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
								cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
								cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
								lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
								dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
								nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
								aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
								lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
								cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
								aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
								cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
								lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
								nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
								nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
								nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
								nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
								nNumParcs		, aMoeda		, aSimbs		, cRecCart		,; 
								cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,; 
								aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
								lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
								aCProva			, aFormCtrl		, nTroco		, nTroco2 		,; 
								lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
								aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
								aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
								nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
								cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
								oTimer			, lResume		, nValor 		, aRegTEF		,;
								lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
								_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
								oPDV			, aICMS			, lDescITReg)    
						
	aParamVL := {} 
	
	aAdd(aParamVL, { 	oHora			, cHora			, oDoc			, cDoc			,;
						oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;		
						nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;		
						oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;		
						cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;		
						nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;		
						oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;		
						nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;		
						nVlrItem		, oProduto		, oQuant		, oUnidade		,;		
						oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,; 	
						oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
						cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
						cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
						dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
						nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
						aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
						lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
						cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
						nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
						nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
						nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
						nNumParcs		, aMoeda		, aSimbs		, cRecCart		,; 
						cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,; 
						aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
						lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
						aCProva			, aFormCtrl		, nTroco		, nTroco2 		,; 
						lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
						aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
						aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
						nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
						cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
						oTimer			, lResume		, nValor 		, aRegTEF		,;
						lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
						_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
						oPDV			, aICMS			, lDescITReg})
  						
Return(.T.)
                   



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLPGet      ³ Autor ³ VENDAS CRM				             ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para retornar o array aParamVL.	    				        	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        		   		       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLPGet()
Return(@aParamVL)
             
/*-------------------------------------------------------------------------------------------
±±³Fun‡„o	 ³DROVLPVal ³ Autor ³ Vendas CRM                            ³ Data ³13/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor do item da venda do VidaLink e maior ou menor,         ³±±
±±³          ³ para assumir o menor valor                                                 ³±±
±±³          ³ Recalcula o valor do desconto e percentual quando utiliza o valor do       ³±±
±±³          ³ do VidaLink                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Venda assistida e Front Loja com Template Drogarias                        ³±±
-------------------------------------------------------------------------------------------*/
Template Function DROVLPVal(aVidaLinkD , aVidaLinkc , nVidaLink , cCodProd   ,;
                            nVlrDescIT , nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                            nVlrUnit   , aVidaLinkD , nNumItem  , uProdTPL   ,;
                            uCliTPL	   , lImpOrc	, cDoc		, cSerie )

Local aRetorno   := {}          									// Retorna  o Valor unitario e o Percentual de desconto
Local nQuant     := nTmpQuant  										// Quantidade a ser Vendida pela Vida link
Local nVlrPrVL   := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRECO ]		// Valor do produto do Vida Link     
Local aRet	 	 := {}               								// Array com os retornos dos campos da funcao de Desconto do Template de Droagria
Local nVlrPrVdVl := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRMAX ] 	// Bruto
Local nVdlkPrcV  := aVidaLinkD[VL_DETALHE, nNumItem, VL_PRVENDA ] 	// Liquido
Local nMoedaCor  := 1                                               // Moeda corrente
Local nDecimais  := MsDecimais(nMoedaCor)							// Numero de casas decimais
Local lVidaLink  := nVidaLink == 1
Local nPrcTab	 := 0

Default cDoc	:= ""
Default cSerie	:= ""

nVlrPercIT  := 0
nVlrDescIT  := 0
                     
aRet := ExecTemplate("FrtDescIT",.F.,.F.,{;
							cCodProd, nVlrPercIT, nVlrDescIT, nVlrItem,;
							uProdTPL, uCliTPL   , nQuant	, aParamVL[1][VLP_CCLIEN],;
							aParamVL[1][VLP_CLOJAC],lImpOrc , cDoc , cSerie , ;
							lVidaLink} )

nVlrPercIT  := aRet[1]
nVlrDescIT  := aRet[2] 

//----------------------------------------------------------------
//|  Acerta o preco Dos Itens pela quantidade liberada para a   |
//|  Quantidade determinada pelo usuario                        |
//----------------------------------------------------------------
nVlrPrVdVl  := Round((nVlrPrVdVl) * nQuant,nDecimais)
nVlrPrVL    := Round(nVlrPrVL,nDecimais)

If lTotvsPDV
	If ExistFunc("STWItRnPrice")
		cCodProd := AllTrim(cCodProd)
		nPrcTab := 0
		STWItRnPrice(@nPrcTab, STDGPBasket('SL1','L1_NUM'), /*aInfoItem*/,aParamVL[1][VLP_CCLIEN],;
					aParamVL[1][VLP_CLOJAC], 0, .T.,cCodProd)
		
		If Round(nPrcTab,nDecimais ) >= Round(nVdlkPrcV ,nDecimais)
			nVlrDescIT := Round((nPrcTab)*nQuant  - (nVdlkPrcV * nQuant),nDecimais)
			nVlrPercIT := Round((nVlrDescIT / (nPrcTab * nQuant) ) * 100 ,nDecimais) 
					
			nVlrItem   := Round(nVdlkPrcV *nQuant,nDecimais)
		Else    	    
			nVlrItem := Round((nPrcTab * nQuant) - nVlrDescIT,nDecimais)   	          
			MsgAlert(STR0015) //#"Os Valores da Loja São menores que os do VidaLink"
		EndIf
		
		nVlrUnit := nPrcTab
		
	Else	
		LjGrvLog(STDGPBasket('SL1','L1_NUM'),"Atualize o fonte STWItemRegistry - função STWItRnPrice não encontrada no RPO " +;
											"Portanto não será possivel efetuar os calculos sobre valores de desconto")
		
	EndIf
Else
	DbSelectArea("SBI")  
	DbSetorder(1)

	If DbSeek(xFilial("SBI") + cCodProd )
		If Round((SBI->BI_PRV),nDecimais ) >= Round(nVdlkPrcV ,nDecimais)
			nVlrDescIT := Round((SBI->BI_PRV)* nQuant  - (nVdlkPrcV * nQuant),nDecimais)
			nVlrPercIT := Round((nVlrDescIT / (SBI->BI_PRV * nQuant) ) * 100 ,nDecimais) 
					
			nVlrItem   := Round(nVdlkPrcV *nQuant,nDecimais)
		Else    	    
			nVlrItem := Round((SBI->BI_PRV * nQuant) - nVlrDescIT,nDecimais)   	          
			MsgAlert(STR0015) //#"Os Valores da Loja São menores que os do VidaLink"
		EndIf       
		
		nVlrUnit := SBI->BI_PRV
	EndIf
EndIf
       
aRetorno := {nVlrItem,nVlrDescIT,nVlrPercIT,nVlrunit }  

Return aRetorno

/*/{Protheus.doc} RetPharma
Retorna codigo PBM PharmaSys

@param      	
@author  Varejo
@version P11.80
@since   22/05/2015
@return  .T. se a parcela digitada for válida / .F. Se a parcela digitada NÃO for válida.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function RetPharma()

T_DROVLGet(540)
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DroAddProd
Inseri produtos no venda assistida
@param 	 aProd		- Produtos selecionados do retorno do PBM
@author  Varejo
@version P11.80
@since   07/04/2017
@return  
/*/
//-------------------------------------------------------------------
Static Function DroAddProd(aProd)
Local nX 			:= 0	//Contador
Local nTotal		:= 0	//total pbm
Local nTotalProt	:= 0	//total protheus
Local lRet			:= .F.
Local nPosUni 		:= aScan( aHeader, {|x| Alltrim(Upper(x[2])) == "LR_VRUNIT"   } ) //Posicao do campo LR_VRUNIT
Local lPBMDesc		:= T_DroPbmDe()

Default aProd 		:= {} 

LjGrvLog( "PBM_FUNCIONAL_CARD", "Inseri produtos na venda")

If Len(aProd) > 0
	For nX := 1 To Len(aProd)
		 If lPBMDesc	
		 	lRet := Lj7LancItem(aProd[nX][VL_EAN],aProd[nX][VL_QUANTID],.T., aProd[nX][VL_PRVENDA]) //Inclui Item
		 Else
		 	lRet := Lj7LancItem(aProd[nX][VL_EAN],aProd[nX][VL_QUANTID],.T.)
		 EndIf
		 If lRet
		 	aAdd(aProd[nX],n)
		 	LjGrvLog( "PBM_FUNCIONAL_CARD", "Produto inserido com sucesso - aProd[nX][VL_EAN] " + aProd[nX][VL_EAN], aProd[nX])
	    	nTotalProt += aCols[N][nPosUni] * aProd[nX][VL_QUANTID] //Acumula valor dos produtos do Protheus
	    	nTotal += aProd[nX][VL_PRVENDA] * aProd[nX][VL_QUANTID] //Acumula valor dos produtos do PBM Funcional Card
		 Else
		 
		 	LjGrvLog( "PBM_FUNCIONAL_CARD", "Produto não inserido aProd[nX][VL_EAN] " , aProd[nX][VL_EAN])
		 EndIf
		 
	Next nX
	
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Total de valores dos produtos no protheus - nTotalProt",nTotalProt)
	LjGrvLog( "PBM_FUNCIONAL_CARD", "Total de valores dos produtos no PBM - nTotal",nTotal)
	
	If nTotalProt < nTotal
		MsgAlert(Upper(STR0002) + " : " + STR0045) //"ATENÇÃO: O valor dos produtos do Protheus está menor que o valor do PBM Funcional Card, isto pode ocasionar divergência no valor a ser pago na finalização da venda."
	EndIf

	If !lPBMDesc
		Lj7CondPg(2,"CO",,,,,,Abs(nTotal-nTotalProt))
	EndIf
EndIf	
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DroPbmDe
Verifica se as alterações de desconto no item PBM estao implementadas
@author  Varejo
@version P12.1.17
@since   22/05/2018
@return  _LOJA701PB
/*/
//-------------------------------------------------------------------
Template Function DroPbmDe()
Local aPrgInfo := {}

If _LOJA701PB == NIL
	aPrgInfo := GetAPOInfo("LOJA701.PRW")
	_LOJA701PB := aPrgInfo[04] >= Ctod("25/05/2018")
EndIf

Return _LOJA701PB

//-------------------------------------------------------------------
/*/{Protheus.doc} DrGScrExMC
Retorna o valor da variável estática lCanTelMeC - se cancelou ou não 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lCanTelMeC
/*/
//-------------------------------------------------------------------
Template Function DrGScrExMC()
Return lCanTelMeC

//-------------------------------------------------------------------
/*/{Protheus.doc} DrSScrExMC
Seta o valor da variável estática lCanTelMeC - se cancelou ou não 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lCanTelMeC
/*/
//-------------------------------------------------------------------
Template Function DrSScrExMC( lSet )

lCanTelMeC := lSet

Return lCanTelMeC