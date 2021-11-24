#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIITEMREGISTER.CH"
#INCLUDE "STPOS.CH"

Static oLblProdDados:= NIl
Static oPanGetProd	:= Nil
Static cPictValUnit	:= PesqPict("SL2","L2_VRUNIT")
Static nTotItem		:= 0
Static cQtdDesc		:= ''
Static oImg         := Nil
Static lFinServ		:= SuperGetMv("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Static lStCodDig	:= ExistBlock("STCODDIG")		// PE para poder alterar o código digitado no PDV
Static lStbExistVP 	:= ExistFunc("STBExistVP")
Static lVend		:= Nil
Static oCodProd		:= Nil													// Código Produto
Static oButton		:= Nil
Static lLJ8099		:= ExistBlock("LJ8099")			//Ponto de Entrada que permite retornar o percentual de desconto que sera aplicado sobre o item
Static aMVLJITOP 	:= STIOperIT()

//-------------------------------------------------------------------
/*{Protheus.doc} STIRegItemInterface
Painel Registro de Item.

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIRegItemInterface(lLjPdVen, lDefaultQD)
Local lProssegue	:= .T.
Local nTpPedeCnpj	:= 0
Local lLjInfDocCli	:= ExistFunc("LjInfDocCli")
Local lEmitNFCe     := ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe() 	// Indica a utilizacao da NFC-e

Default lLjPdVen	:= .F.
Default lDefaultQD  := .T. 											// Seta Quantidade e Desconto para Default?

lVend := IIF(lVend == Nil,SuperGetMV("MV_LJPDVEN", ,.F.),lVend) 	//Variavel para ativar o vendedor

oLblProdDados := Nil

If lDefaultQD
	STBSetDefQuant()	// Seta quantidade padrao
	STBDefItDiscount()	// Seta desconto padrao
EndIf

If !lLjInfDocCli
	lProssegue := .T.
Else
	If lLjInfDocCli
		nTpPedeCnpj := LjInfDocCli()
		
		If nTpPedeCnpj <> 2
		
			If lEmitNFCe .AND. nTpPedeCnpj == 1 .AND. !STIGInfCPF() .AND. Isincallstack("STIConfirmProd") 
				STI7InfCPF(.T.)
			Endif 
			//Verifico se sera necessario apresentar a tela para informar o CPF/CNPJ, caso contrario chamo o registro de item
			lProssegue := !STWInfoCNPJ()
		EndIf
	EndIf
EndIf

If lProssegue
	If lVend .AND. lLjPdVen .And. (!ExistFunc("STIGSelVend") .Or. !STIGSelVend())	// Determina se apresenta tela para Alterar o vendedor na venda no POS
		STISalesmanSelection()		   					// Apresenta tela para Alterar o vendedor na venda no POS
	Else
		If !lVend .Or. !lLjPdVen
			STIBtnActivate() //Ativa os botoes da tela
		EndIf
   		STIExchangePanel( { ||  STIPanItemRegister() } )
    EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanItemRegister
Painel Registro de Item

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIPanItemRegister()

Local oPanelMVC	   	    := Nil														// Objeto Painel MVC
Local oLblCab			:= Nil														// Objeto Cabeçalho Label
Local oLblCodProd		:= Nil														// Objeto Código Produto
Local cGetProd			:= Space(40)											// Descrição Produto 
Local oLblHelpGet		:= Nil														// Objeto Label Help Get
Local oLblInfProd		:= Nil														// Objeto Label Info Produto
Local cDados			:= STR0010  + CRLF + CRLF + CRLF + STR0009 // Descrição do Produto ### "Valor"
Local aCustomer			:= IIF(ExistFunc('STDFindCust'),STDFindCust(),{}) //Carrega informacoes do cliente Nome/Cpf 
Local aSalesMan			:= IIF(ExistFunc('STDFindSMan'),STDFindSMan(),{})	//Carrega o nome do vendedor
Local lMobile			:= STFGetCfg("lMobile" , .F. ) 							//PDV em Versao Mobile 
Local oGetQtde			:= Nil							// TGet quantidade do item
Local oGetVlrDesc		:= Nil							// TGet Valor desconto
Local oGetPercDesc		:= Nil							// TGet percentual de desconto
Local nGetQtde			:= 1							// Quantidade
Local nGetVlrDesc		:= 0							// Valor de desconto
Local nGetPercDesc		:= 0 							// Percentual de desconto
Local oButRegItem		:= Nil 							//Botao registrar item
Local oButRegCamItem	:= Nil 							//Botao registrar item com camera
Local bRegItem			:= {||}						//Bloco para registro do item
Local bCamRegItem		:= {||}							//Bloco para registro do item com camera
Local cPathImg          := AllTrim(SuperGetMV("MV_LJIMAGE", .F., ""))	 // Caminho da imagem do produto Opcional 
Local cAtalhosItem		:= "" 
Local aCartCRD			:= IIF(ExistFunc('STDFindCart'),STDFindCart(),{}) //Carrega informacoes do cartão utilizado no SIGACRD 
Local oLblCartCrd		:= nil							//Objeto Label Cartão (SIGACRD)      
Local aRes				:= GetScreenRes()				// Retorna a Resolução atual da tela.
Local oRaas				:= Nil
Local oFidelityC		:= Nil

// -- Limpeza dos descontos do FidelityCore
If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
	oRaas := STBGetRaas()
	
	If Valtype(oRaas) == "O" .AND. oRaas:ServiceIsActive("TFC")
		
		oFidelityC := oRaas:GetFidelityCore()
		
		If oFidelityC:ChoseToUse() 
			oFidelityC:Clean()
		EndIf
 
		If STDGPBasket( "SL1", "L1_DESCFID" ) > 0
			STIClearDisc(.T.,STDGPBasket( "SL1", "L1_DESCFID"))
		Endif 

	EndIf 
EndIf 

If !Empty(aMVLJITOP[1])
	cAtalhosItem += "Quantidade ( "+AllTrim(aMVLJITOP[1])+" ) / "
EndIf

If !Empty(aMVLJITOP[2])
	cAtalhosItem += "Valor Desconto ( "+AllTrim(aMVLJITOP[2])+" ) OU "
EndIf

If !Empty(aMVLJITOP[3])
	cAtalhosItem += "Perc. Desconto ( "+AllTrim(aMVLJITOP[3])+" ) / Código do Produto "
EndIf 

nTotItem := 0  			// Inicia o totalizador para a nova venda

lMobile := ValType(lMobile) == "L" .AND. lMobile

oPanelMVC	   		:= STIGetPanel()	
oPanGetProd 			:= TPanel():New(00,00,"",oPanelMVC,;
										,,,,;
										,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)
STIChangeCssBtn('oBtnRegItem')

oLblProdDados := Nil
//Verifica se e versao mobile 
If lMobile 

	/*/
		Objetos
	/*/
	oLblCab := TSay():New(POSVERT_CAB,POSHOR_1,{|| STR0021 + " > " + STR0001},oPanGetProd,,,,,,.T.,,,,) //"Vendas" "Registro de Item"
	oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 
	
	
	//Quantidade
	oLblQuantidade := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0022},oPanGetProd,,,,,,.T.,,,,100)//"Quantidade"
	oLblQuantidade:SetCSS( POSCSS (GetClassName(oLblQuantidade), CSS_LABEL_NORMAL ))
	
	
	oGetQtde:= TGet():New(	POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,nGetQtde:=u,nGetQtde)}, ;
								oPanGetProd,40 ,ALTURAGET,"@E 999",{|| nGetQtde > 0 .AND. nGetQtde <= 999 },,,,,,.T.,,,,,,,,,,"nGetQtde",,,,,.T.)
	oGetQtde:SetCSS( POSCSS (GetClassName(oGetQtde), CSS_GET_NORMAL ))
	
	
	//Get de valor de desconto
	oLblVlrDesc := TSay():New(POSVERT_LABEL1,oPanelMVC:nWidth/7,{||STR0023},oPanGetProd,,,,,,.T.,,,,100)//"Valor de Desconto"
	oLblVlrDesc:SetCSS( POSCSS (GetClassName(oLblVlrDesc), CSS_LABEL_NORMAL ))
	
	oGetVlrDesc:= TGet():New(	POSVERT_GET1,oPanelMVC:nWidth/7,{|u| If(PCount()>0,nGetVlrDesc:=u,nGetVlrDesc)}, ;
									oPanGetProd,60 ,ALTURAGET,"@E 999,999.99",,,,,,,.T.,,,,,,,,,,"nGetVlrDesc",,,,,.T.)
	oGetVlrDesc:SetCSS( POSCSS (GetClassName(oGetVlrDesc), CSS_GET_NORMAL ))
	
	//Percentual de Desconto
	oLblPercDesc := TSay():New(POSVERT_LABEL1,oPanelMVC:nWidth/3.5,{||STR0024},oPanGetProd,,,,,,.T.,,,,100)//"Percentual de Desconto"
	oLblPercDesc:SetCSS( POSCSS (GetClassName(oLblPercDesc), CSS_LABEL_NORMAL ))
	
	oGetPercDesc:= TGet():New(	POSVERT_GET1,oPanelMVC:nWidth/3.5,{|u| If(PCount()>0,nGetPercDesc:=u,nGetPercDesc)}, ;
									oPanGetProd,60 ,ALTURAGET,"@E 99.99",,,,,,,.T.,,,,,,,,,,"nGetPercDesc",,,,,.T.)
	oGetPercDesc:SetCSS( POSCSS (GetClassName(oGetPercDesc), CSS_GET_NORMAL ))
	
	oLblSimbPerc := TSay():New(POSVERT_GET1 + 5, oPanelMVC:nWidth/3.5 + ((oGetPercDesc:nWidth/2) + 3 ) ,{||"%"},oPanGetProd,,,,,,.T.,,,,100)
	oLblSimbPerc:SetCSS( POSCSS (GetClassName(oLblSimbPerc), CSS_LABEL_NORMAL ))
	

	//Codigo do Produto
	oLblCodProd := TSay():New(POSVERT_LABEL2,POSHOR_1,{||STR0002},oPanGetProd,,,,,,.T.,,,,) //"Código do Produto"
	oLblCodProd:SetCSS( POSCSS (GetClassName(oLblCodProd), CSS_LABEL_FOCAL )) 
	
	oCodProd := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,cGetProd:=u,cGetProd)},oPanGetProd,165,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetProd")
	oCodProd:SetCSS( POSCSS (GetClassName(oCodProd), CSS_GET_FOCAL )) 

	bRegItem					 := { ||  	IIF( !Empty(AllTrim(cGetProd))		,;
											EVal( { || cGetProd := IIF(nGetQtde > 0 .AND. nGetQtde <= 999,AllTrim(STR(nGetQtde))+AllTrim(aMVLJITOP[1]),"")+ ; //Quantidade
											 IIF(nGetVlrDesc > 0 , AllTrim(STR(nGetVlrDesc)) + AllTrim(aMVLJITOP[2]) , IIF(nGetPercDesc > 0 , AllTrim(STR(nGetPercDesc)) + AllTrim(aMVLJITOP[3]) , "" ) ) + ; //Desconto
											 cGetProd		,;
											 cQtdDesc := cGetProd			,;
											 STIItemregister(cGetProd)		,;
											 cGetProd := Space(40)			,;
											 nGetQtde := 1					,;
											 nGetVlrDesc := 0					,;
											 nGetPercDesc := 0				,;
											 oCodProd:SetFocus() } ), .T. ) 	}

	oCodProd:bValid := bRegItem
	
	//"Botao registrar Item"
	oButRegItem	:= TButton():New(	POSVERT_GET2,oPanelMVC:nWidth/3.5, STR0025  + CRLF + STR0026 ,oPanGetProd,bRegItem,40,20,,,,.T.,,,,)//"Registrar" ### "Item"
	oButRegItem:SetCSS( POSCSS (GetClassName(oButRegItem), CSS_BTN_NORMAL ))


	bCamRegItem				 := { ||   EVal( { || cGetProd := IIF(nGetQtde > 0 .AND. nGetQtde <= 999,AllTrim(STR(nGetQtde))+AllTrim(aMVLJITOP[1]),"")+ ; //Quantidade
											 IIF(nGetVlrDesc > 0 , AllTrim(STR(nGetVlrDesc)) + AllTrim(aMVLJITOP[2]) , IIF(nGetPercDesc > 0 , AllTrim(STR(nGetPercDesc)) + AllTrim(aMVLJITOP[3]) , "" ) ) + ; //Desconto
											 cGetProd		,;
											 cQtdDesc := cGetProd			,;
											 STICamRegItem(cGetProd)		,;
											 cGetProd := Space(40)			,;
											 nGetQtde := 1					,;
											 nGetVlrDesc := 0					,;
											 nGetPercDesc := 0				,;
											 oCodProd:SetFocus() } ) 	}

	//"Botao registrar Item com camera"
	oButRegCamItem	:= TButton():New(	POSVERT_GET2,oPanelMVC:nWidth/2.8,STR0025  + CRLF + STR0027,oPanGetProd,bCamRegItem,70,20,,,,.T.,,,,) //  "Registrar" ### "com cãmera"
	oButRegCamItem:SetCSS( POSCSS (GetClassName(oButRegCamItem), CSS_BTN_BARCODE ))


	oLblInfProd := TSay():New(POSVERT_GET3,POSHOR_1,{||cDados},oPanGetProd,,,,,,.T.,,,,100)
	oLblInfProd:SetCSS( POSCSS (GetClassName(oLblInfProd), CSS_LABEL_NORMAL )) 
	
	//Botao finalizar vendas
	oButton := TButton():New( POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0003 ,oPanGetProd,{ || IIF(STIPePay(),STICallPayment(),.F.) }, ; //"Finalizar Venda"
								LARGBTN,ALTURABTN,,,,.T.)
									
	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 
	
	/* Identificação do Cartão relacionado na integração do SIGACRD */
	If Len(aCartCRD) > 0
		oLblCartCRD := TSay():New(POSVERT_LABEL4,POSHOR_1,{||IIf(!Empty(AllTrim(aCartCRD[1])),STR0033 + AllTrim(aCartCRD[1]),"")},oPanGetProd,,,,,,.T.,,,,100) 	//"Cartão "
		oLblCartCRD:SetCSS( POSCSS (GetClassName(oLblCartCRD), CSS_BREADCUMB ))
	EndIf

	//Identificacao do vendedor 
	If Len(aSalesMan) > 0
		oLblSalesMan := TSay():New(POSVERT_LABEL7,POSHOR_1,{||STR0012 + " " + AllTrim(aSalesMan[1])},oPanGetProd,,,,,,.T.,,,,100)
		oLblSalesMan:SetCSS( POSCSS (GetClassName(oLblSalesMan), CSS_LABEL_FOCAL ))
	EndIf
	
	//Identificacao do cliente
	If Len(aCustomer) > 0
		oLblCustomer := TSay():New(POSVERT_LABEL5,POSHOR_1,{||AllTrim(aCustomer[1])},oPanGetProd,,,,,,.T.,,,,100)
		oLblCustomer:SetCSS( POSCSS (GetClassName(oLblCustomer), CSS_LABEL_FOCAL ))
		
		oLblCpf := TSay():New(POSVERT_LABEL6,POSHOR_1,{||AllTrim(aCustomer[2])},oPanGetProd,,,,,,.T.,,,,100)
		oLblCpf:SetCSS( POSCSS (GetClassName(oLblCpf), CSS_LABEL_FOCAL ))
	EndIf
	
	oCodProd:SetFocus()

	
Else

	/*/
		Objetos
	/*/
	oLblCab := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetProd,,,,,,.T.,,,,) //"Registro de Item"
	oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 
	
	oLblCodProd := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0002},oPanGetProd,,,,,,.T.,,,,) //"Código do Produto"
	oLblCodProd:SetCSS( POSCSS (GetClassName(oLblCodProd), CSS_LABEL_FOCAL )) 
	
	oCodProd := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetProd:=u,cGetProd)},oPanGetProd,170,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetProd")
	oCodProd:SetCSS( POSCSS (GetClassName(oCodProd), CSS_GET_FOCAL )) 
	
	oLblHelpGet := TSay():New(POSVERT_GET1+ALTURAGET+5,POSHOR_1,{||cAtalhosItem},oPanGetProd,,,,,,.T.,,,,) //"Quantidade (*) / Valor Desconto (-) OU Perc. Desconto (%) / Código do Produto"
	oLblHelpGet:SetCSS( POSCSS (GetClassName(oLblHelpGet), CSS_LABEL_NORMAL )) 
	
	oLblInfProd := TSay():New(POSVERT_GET2,POSHOR_1,{||cDados},oPanGetProd,,,,,,.T.,,,,100)
	oLblInfProd:SetCSS( POSCSS (GetClassName(oLblInfProd), CSS_LABEL_NORMAL )) 
	
	
	/*Caso exija CPF ou tenha paramterização para chamar tela de CPF no final da venda*/
	If ExistFunc("STWBtFimVnd")
		oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0003+CRLF+"(CTRL+F)",; //"Finalizar Venda"
							oPanGetProd,{ || IIF(STIPePay(),STWBtFimVnd(),.F.) },;
							LARGBTN,ALTURABTN,,,,.T.)
		SetKey(6, { || IIF(STIPePay(),STWBtFimVnd(),.F.) }) // Tecla de atalho para 'Finalizar Venda'
	Else
		oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0003+CRLF+"(CTRL+F)",; //"Finalizar Venda"
								oPanGetProd,{ || IIF(STIPePay(),IIF(lFinServ,STWFindServ(),STICallPayment()),.F.) },; 
								LARGBTN,ALTURABTN,,,,.T.)
		SetKey(6, { || IIF(STIPePay(),IIF(lFinServ,STWFindServ(),STICallPayment()),.F.) }) // Tecla de atalho para 'Finalizar Venda'
	EndIf
	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL ))	
	
	//Verifica se utiliza imagens por folder ou RPO 
	If Empty(cPathImg)
		@ POSVERT_GET2,oPanelMVC:nWidth/3.01886 REPOSITORY oImg OF oPanGetProd NOBORDER SIZE 100,100 PIXEL
	Else
		oImg := TBitmap():New( POSVERT_GET2,oPanelMVC:nWidth/3.01886,100,100,,"",.T.,oPanGetProd,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
		oImg:lStretch:= .T.
	EndIf
	oImg:lVisibleControl := .F.

	/* Identificação do Cartão relacionado na integração do SIGACRD */
	If Len(aCartCRD) > 0
		oLblCartCRD := TSay():New(POSVERT_LABEL4,POSHOR_1,{||IIf(!Empty(AllTrim(aCartCRD[1])),STR0033 + AllTrim(aCartCRD[1]),"")},oPanGetProd,,,,,,.T.,,,,100) 	//"Cartão"
		oLblCartCRD:SetCSS( POSCSS (GetClassName(oLblCartCRD), CSS_BREADCUMB ))
	EndIf

	/* Identificacao do vendedor */
	If Len(aSalesMan) > 0
		oLblSalesMan := TSay():New(POSVERT_LABEL7,POSHOR_1,{||STR0012 + " " + AllTrim(aSalesMan[1])},oPanGetProd,,,,,,.T.,,,,100)
		oLblSalesMan:SetCSS( POSCSS (GetClassName(oLblSalesMan), CSS_BREADCUMB )) 
		
		LjGrvLog( /*cNumControl*/, "Nome do Vendedor", aSalesMan[1] )
	EndIf
	
	/* Identificacao do cliente */
	If Len(aCustomer) > 0

		oLblCustomer := TSay():New(POSVERT_LABEL5,POSHOR_1,{||AllTrim(SubStr(aCustomer[1],1,Int(aRes[1]*0.03)))},oPanGetProd,,,,,,.T.,,,,100)
		oLblCustomer:SetCSS( POSCSS (GetClassName(oLblCustomer), CSS_BREADCUMB )) 
		
		oLblCpf := TSay():New(POSVERT_LABEL6,POSHOR_1,{||AllTrim(aCustomer[2])},oPanGetProd,,,,,,.T.,,,,100)
		oLblCpf:SetCSS( POSCSS (GetClassName(oLblCpf), CSS_BREADCUMB )) 
		
		LjGrvLog( /*cNumControl*/, "Nome do Cliente", aCustomer[1] )
		LjGrvLog( /*cNumControl*/, "CPF/CNPJ do Cliente", aCustomer[2] )	
	EndIf
	
	oCodProd:bGotFocus := { ||  STWReaderFocus(.T.) }
	
	oCodProd:bLostFocus := { || STWReaderFocus(.F.),;
								 IIF( !Empty(AllTrim(cGetProd)),;
										EVal( { ||	cQtdDesc := cGetProd		,;
													STIItemregister(cGetProd)	,;
													cGetProd := Space(40)		,;
													oCodProd:SetFocus() } )		,;
										(oButton := STIGetBtIR()				,;
										) ) }
	
	oCodProd:SetFocus()
	If GetFocus() <> oCodProd:HWND
	    oCodProd:SetFocus()    
	Endif	

EndIf

Return oPanGetProd


//-------------------------------------------------------------------
/*/{Protheus.doc} STICamRegItem
Registro de Item com camera

@param   cGetProd - Texto do Get de produtos 
@author  Varejo
@version P12
@since   25/05/2015
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STICamRegItem( cGetProd )

Local oMbl					:= Nil 	// Objeto Tmobile para codigo de barras
Local cBarType			:= "" 	   	// Tipo de codigo de barras utilizado
Local aBarResult			:= {} 	   	// Resultado da consulta ao objeto de CodBar
Local lContinua			:= .T. 	// Controle de Loop

Default cGetProd := "" 

oMbl:= TMobile():New()

While lContinua

	aBarResult:= oMbl:BarCode(cBarType)
	
	If aBarResult[2] = ""
		lContinua := .F.
	Else		
		STIItemregister(AllTrim(cGetProd) + AllTrim(aBarResult[1] ) )
	EndIf
	
EndDo
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIItemRegister
Registro de Item Interface

@param   lItemFiscal Indica se é item fiscal ou não
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIItemRegister( cGetProd, lItemFiscal )

Local cCodItem			:= ""
Local nQuant			:= 0
Local cCliCode			:= STDGPBasket("SL1","L1_CLIENTE")
Local cCliLoja			:= STDGPBasket("SL1","L1_LOJA")
Local nPosQuant	   		:= 0
Local nPosValDesc		:= 0
Local nPosPercDesc 		:= 0
Local nDiscount	   		:= 0
Local cTypeDesc	   		:= ""
Local nItemLine	  		:= STDPBLength("SL2") + 1
Local nItemLnAte        := 0 
Local lConsultaProd		:= .F.
Local cTesPad			:= ""
Local aRet				:= {}
Local cL1Num			:= "" 
Local lVPProd 			:= SuperGetMv("MV_LJVPPRO",,.F.) 	//Permite vender Vale Presente e produtos na mesma venda       
Local nLJ8099			:= 0								//retorno do ponto de entrada LJ8099

Default cGetProd		:= ""
Default lItemFiscal		:= .T.

LjGrvLog( "STIItemRegister", "Inicio do registro do item ", cGetProd)	

If lSTCodDig // PE para alterar a informacao digitada no GET da tela
	aRet := ExecBlock("STCODDIG",.F., .F., {cGetProd} )
	If ValType(aRet) == "A" .AND. Len(aRet) > 0
		cGetProd := aRet[1] 
	EndIf
EndIf

cGetProd 			:= AllTrim(cGetProd)
nPosQuant	   		:= AT(AllTrim(aMVLJITOP[1]),cGetProd)
nPosValDesc			:= AT(AllTrim(aMVLJITOP[2]),cGetProd)
nPosPercDesc 		:= AT(AllTrim(aMVLJITOP[3]),cGetProd)

If lStbExistVP .And. !lVPProd .And. STBExistVP()
	STFMessage(ProcName(0),"STOP",STR0020) //"A venda do vale presente deve ser feita separada."
	STFShowMessage(ProcName(0))
	Return(.F.)	
EndIf

//Se o sinal de desconto definido na segunda posicao do parametro MV_LJITOP estiver na primeira posicao significa que tentou digitar um valor zerado
//entao desconsidera este valor pois deve ser da quantidade
If nPosValDesc == 1
	nPosValDesc := AT(AllTrim(aMVLJITOP[2]), SUBSTR(cGetProd, 2, Len(cGetProd) ))
	If nPosValDesc > 0
		++nPosValDesc
	EndIf
EndIf

lConsultaProd := SubStr(cGetProd,1, 1) == AllTrim(aMVLJITOP[4])

/*
	O bloco abaixo avalia a string digitada. Se na string cGetProd houver '*' sera setada quantidade
	Caso haja '-' sera setado o valor do desconto e se houver '%' sera setado o percentual de desconto
*/
If ( nPosQuant + nPosValDesc + nPosPercDesc ) > 0
	/*/
		Desconto primeiro, Quantidade depois
	/*/
	If nPosQuant > nPosValDesc .AND. nPosValDesc > 0
		nQuant := STIComma(SubStr(cGetProd,nPosValDesc+1,nPosQuant-1))

		nDiscount 	:= STIComma(SubStr(cGetProd,1,nPosValDesc-1))
		cCodItem	:= SubStr(cGetProd,nPosQuant+1)
		cTypeDesc	:= "V"
	ElseIf nPosQuant > nPosPercDesc .AND. nPosPercDesc > 0
		nQuant := STIComma(SubStr(cGetProd,nPosPercDesc+1,nPosQuant-1))

		nDiscount 	:= STIComma(SubStr(cGetProd,1,nPosPercDesc-1))
		cCodItem	:= SubStr(cGetProd,nPosQuant+1)
		cTypeDesc	:= "P"

	/*/
		Quantidade primeiro, desconto depois
	/*/
	ElseIf nPosQuant > 0
		nQuant := STIComma(SubStr(cGetProd,1,nPosQuant-1))

		If nPosValDesc > 0
			nDiscount 	:= STIComma(SubStr(cGetProd,nPosQuant+1,nPosValDesc-1))
			cCodItem	:= SubStr(cGetProd,nPosValDesc+1)
			cTypeDesc	:= "V"
		ElseIf nPosPercDesc > 0
			nDiscount 	:= STIComma(SubStr(cGetProd,nPosQuant+1,nPosPercDesc-1))
			cCodItem	:= SubStr(cGetProd,nPosPercDesc+1)
			cTypeDesc	:= "P"
		Else
			cCodItem	:= SubStr(cGetProd,nPosQuant+1)
		EndIf

	/*/
		Apenas Descontos
	/*/
	Else
		If nPosValDesc > 0
			nDiscount 	:= STIComma(SubStr(cGetProd,1,nPosValDesc-1))
			cCodItem	:= SubStr(cGetProd,nPosValDesc+1)
			cTypeDesc	:= "V"
		ElseIf nPosPercDesc > 0
			nDiscount 	:= STIComma(SubStr(cGetProd,1,nPosPercDesc-1))
			cCodItem	:= SubStr(cGetProd,nPosPercDesc+1)
			cTypeDesc	:= "P"
		Else
			cCodItem	:= cGetProd // Apenas Produto
		EndIf
	EndIf

/*/
	Passado apenas o código do produto
/*/
Else
	cCodItem := cGetProd // Apenas Produto
EndIf

/*
	Ponto de Entrada LJ8099 - Retorna o percentual de desconto (%)
	Se o usuario informou qualquer tipo de desconto, o ponto de entrada nao sera executado
*/
If lLJ8099 .AND. nDiscount = 0
	nLJ8099 := Execblock("LJ8099", .F., .F.)	
	If ValType(nLJ8099) == "N" .AND. nLJ8099 > 0 .AND. nLJ8099 < 100
		nDiscount := nLJ8099  
		cTypeDesc := "P"
	Else
		LjGrvLog(cL1Num, "Retorno invalido do PE LJ8099", nLJ8099)
	EndIf
EndIf

If !Empty(cCodItem)
	cL1Num	:= STDGPBasket('SL1','L1_NUM')

	If !lConsultaProd // O item apenas sera registrado quando nao for uma consulta

		/*/
			Set Quantidade
		/*/
		If nQuant > 0 // Pode ter setado a quantidade antes por tecla de atalho

			STBSetQuant( nQuant , 2)
		
			LjGrvLog("L1_NUM: " + cL1Num, "Quantidade", nPosQuant) //Grava Log =====================================================================
		
		ElseIf nPosQuant > 0
			STFMessage(ProcName(),"STOP",STR0006 + " " + STR(nQuant) ) //"Quantidade Inválida."
			STFShowMessage(ProcName())
			Return(.F.)			
		EndIf

		/*/
			Set Desconto
		/*/
		If nDiscount > 0 .AND. (cTypeDesc $ "V|P")

			STWIDBefore( nDiscount , cTypeDesc )

		ElseIf nPosValDesc > 0 .OR. nPosPercDesc > 0
			STFMessage(ProcName(),"STOP",STR0007 + " " + STR(nDiscount) ) //"Desconto Inválido."
			STFShowMessage(ProcName())
			Return(.F.)			
		EndIf

		/*/
			Registra Item
		/*/
		
		/* Busca TES Servico Financeiro */
		If lFinServ	.AND. STBIsFinService( cCodItem )		
			MG8->(dbSetOrder(2))
			
			If MG8->(dbSeek(xFilial("MG8") + cCodItem))
				cTesPad := MG8->MG8_TESSB1
			EndIf
		EndIf
		
		LjGrvLog( "L1_NUM: "+cL1Num, "Registra Item - Item" 	, nItemLine)  //Gera LOG
		LjGrvLog( "L1_NUM: "+cL1Num, "Registra Item - Produto" , cCodItem )  //Gera LOG
		LjGrvLog( "L1_NUM: "+cL1Num, "Registra Item - Cliente" , cCliCode )  //Gera LOG
		LjGrvLog( "L1_NUM: "+cL1Num, "Registra Item - Loja" 	, cCliLoja )  //Gera LOG
		
		//Com desconto aplicado verifica se tem que apresentar o tratamento do motivo de desconto
		If nDiscount > 0 .And. cTypeDesc $ "V|P" .And. SuperGetMV("MV_LJMTDIT",,.F.) .AND. FindFunction("STBRFDAtiv") 
			If !STBRFDAtiv(nItemLine,cCodItem,cTesPad,nTotItem)
				STFMessage(ProcName(),"STOP","Motivo de Desconto Inválido")
				Return(.F.)
			EndIf
		Else
			STWSetRegIt(nItemLine,cCodItem,cTesPad,nTotItem,;
			       	 lItemFiscal)
		EndIf
	Else
		cCodItem := SubStr(AllTrim(cCodItem),2)
	EndIf

/*/
	Verifica se informou apenas desconto
/*/
ElseIf nPosValDesc > 0 .OR. nPosPercDesc > 0

	If nDiscount > 0 .OR. (cTypeDesc $ "V|P") // Pode ser que o usuário queira zerar o desconto, por isso o .OR.

		/*/
			Workflow de desconto após regirstro de item via interface
		/*/
		STWIDAfter( nDiscount , cTypeDesc )
		
	EndIf
				
EndIf

nItemLnAte := STDPBLength("SL2") // Busca quantidade de itens gravados da SL2 
nItemLnAte := Iif(nItemLine > nItemLnAte,nItemLine,nItemLnAte) 

STIGridCupRefresh(nItemLine,nItemLnAte) // Sincroniza a Cesta com a interface

LjGrvLog( "STIItemRegister", "Final do registro do item ", cGetProd)

Return (.T.)

//-------------------------------------------------------------------
/*{Protheus.doc} STIShowProdData
Mostra na tela as informacoes do item que sera cancelado

@param   nItem   		- Numero do utem
@author  Vendas & CRM
@version P12
@since   23/05/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIShowProdData(nItem)
Local oPanelMVC	    := STIGetPanel()		// Painel Principal
Local aLines        := FwSaveRows()	// Array de linhas
Local oModelCesta   := STDGPBModel()			// Model da cesta
Local cProdData     := ""
Local cMoedaSimb    := SuperGetMV( "MV_SIMB" + Str(STBGetCurrency() ,1 ) ) 	// Simbolo da moeda corrente
Local nPosVertical  := POSVERT_GET2		//Posicao vertical	
Local lMobile 		:= STFGetCfg("lMobile", .F.)		///Verifica se e versao Mobile
Local cPathImg  	:= AllTrim(SuperGetMV("MV_LJIMAGE", .F., ""))	 // Caminho da pasta de imagens 
Local cExtImg  		:= AllTrim(SuperGetMV("MV_LJIMGEX", .F., ".jpg"))	 // Extensão das imagens Opcional 
Local aProdData		:= {} 
Local cTexto1		:= ""
Local cTexto2		:= ""
Local cMVLJB1COD	:= AllTrim(SuperGetMV("MV_LJB1COD",,"B1_COD")) //Campo que será utilizado para consulta da imagem do produto
Local cNomeImg  	:= ""

Default nItem 		:= 0

//Versao Mobile
If ValType(lMobile) == "L" .AND. lMobile
	nPosVertical := POSVERT_GET3
EndIf

oModelCesta := oModelCesta:GetModel("SL2DETAIL")

If nItem > 0
	oModelCesta:GoLine(nItem)

	cProdData := AllTrim(oModelCesta:GetValue("L2_DESCRI"))+CRLF+CRLF+CRLF;
							+cMoedaSimb+AllTrim(Transform(oModelCesta:GetValue("L2_PRCTAB"),cPictValUnit))

	//Só atualiza os valores do label se o panel existir
	If ValType(oPanGetProd) <> "U"
	 
		aProdData := StrTokArr(cProdData,CHR(10))
			
		If Len(aProdData) > 1
			If Len(aProdData[1]) > 50
				cTexto1 := SubStr(aProdData[1],1,50)
				cTexto2 := SubStr(aProdData[1],51,50) + IIF ( Len(SubStr(aProdData[1],51,50)) < 50 ,"", "..."  )
				
				cProdData := cTexto1 + CHR(10) + cTexto2 + CHR(10) + CHR(10) + aProdData[2]
			EndIf 
		EndIf	 
	 
		If ValType(oLblProdDados) <> "U"
			oLblProdDados:SetText(cProdData)
		Else
			oLblProdDados:= TSay():New(nPosVertical +10,POSHOR_1,{||cProdData},oPanGetProd,,,,,,.T.,,,,100)
			oLblProdDados:SetCSS( POSCSS (GetClassName(oLblProdDados), CSS_LABEL_FOCAL )) 
		EndIf
		
	EndIf	

	If !Empty(oImg)
		If Empty(cPathImg)
			cNomeImg := AllTrim(STDLoadImg(oModelCesta:GetValue("L2_PRODUTO")))
			If !Empty(cNomeImg) .And. oImg:ExistBmp(cNomeImg)
				ShowBitmap(oImg, cNomeImg, "SEMFOTO")
				oImg:lVisibleControl := .T.
			Else
				oImg:lVisibleControl := .F.
			EndIf
		Else
			cNomeImg := AllTrim(SB1->&(cMVLJB1COD))
			If oImg:Load( Nil ,cPathImg + cNomeImg + cExtImg )
				oImg:lVisibleControl := .T.
			Else			
				oImg:SetEmpty()
				oImg:lVisibleControl := .F.
			EndIf	
		EndIf
	EndIf	
EndIf

FwRestRows(aLines)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STICallPayment
Funcao que verifica se ha alguma NCC para o cliente selecionado.
Se houver, sera chamada a tela de selecao de NCCs ao invés da tela de pagamento.

@param
@author  Vendas & CRM
@version P12
@since   30/04/2013
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STICallPayment()

Local aNCCs 		:= STDGetNCCs("1")
Local oTotal  		:= STFGetTot() 											// Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") 						// Valor total da venda
Local cEstado		:= SuperGetMV("MV_ESTADO")
Local lRet			:= .T.													// Retorno
Local lVersao		:= Val(GetVersao(.F.)) >= 12 							// Codigo de barras para NCC soente a partir da versao 12
Local nVLBonif      := IIF(ExistFunc("STIGetBonif"), STIGetBonif(), 0)
Local lSTDSlBrin  	:= AliasInDic("MGC") .And. ExistFunc("STDSalvaBrindes")
Local lReadOnly		:= ExistFunc("STIGetPayRO") .AND. STIGetPayRO()			// Indica se os campos de pagamento estão como Somente Leitura (permissão Alterar Parcelas do caixa)	 
Local lEmitNFCe     := ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe()			// Indica a utilizacao da NFC-e
Local aValLim       := IIf( ExistFunc("Lj950UFVal"), Lj950UFVal(), {} )
Local nPos          := 0
Local cCliCode		:= STDGPBasket("SL1","L1_CLIENTE")
Local cCliLoja		:= STDGPBasket("SL1","L1_LOJA")
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  						// Parametro que indica o CLIENTE PADRAO
Local cLojPad 		:= SuperGetMV("MV_LOJAPAD",,"") 						// Parametro que indica o LOJA PADRAO
Local lRegDesc		:= SuperGetMV('MV_LJRGDES',,.F.) .AND. ExistFunc("STBFORMBF") .AND. ExistFunc("STIDSCBONF") .AND. GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019") //Regra de desconto
Local lContinua		:= .T.
Local oRaas			:= Nil
Local oLjCusFCore 	:= Nil
Local oFidelityC    := Nil
Local oModelCli     := Nil
Local oPhone        := Nil
Local nBonus        := 0 

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Chamada da Tela de Pagamento" )  //Gera LOG

nPos := Ascan(aValLim,{|x| x[1] == cEstado})

If lEmitNFCe // Só permite a venda acima de 10.000 se o cliente for identificado
	If cCliCode + "/" + cCliLoja == cCliPad + "/" + cLojPad .AND. nTotalVend > 10000 
		STFMessage(ProcName(),"STOP",STR0032) // "Não é permitido vendas acima de 10.000 para cliente não identificado!"
		STFShowMessage(ProcName())
		lRet := .F.	
	ElseIf nPos > 0 .AND. Len(aValLim) > 0 .AND. nTotalVend > aValLim[nPos][2]
		STFMessage(ProcName(), "STOP", STR0030 + TRANSFORM(aValLim[nPos][2], "@E 999,999") + STR0031) //"Não é permitido vendas acima de " ", cancele algum item para continuar!"
		STFShowMessage(ProcName())
		lRet := .F.
	EndIf	
ElseIf cEstado == "SP" .AND. nTotalVend > 10000
	STFMessage(ProcName(),"STOP",STR0004) //"Não é permitido vendas acima de 10.000, cancele algum item para continuar!"
	STFShowMessage(ProcName())
	lRet := .F.
EndIf 

//Valida permissão de usuário para vender produto controlado - TPL Drogaria
If lRet .And. !STBPerDro()
	LjGrvLog(NIL,"Não é permitido a venda de produto controlado pois o usuário não tem permissão - " +;
				"SOLUÇÃO: Remova o produto controlado ou efetue a venda com um usuário do tipo FARMACÊUTICO")
	STFMessage(ProcName(),"STOP","Venda de produto controlado não permitida") //"Venda de produto controlado não permitida"
	STFShowMessage(ProcName())
	lRet := .F.
EndIf

If STBMRObrigat() .AND. !STBMRIsRegistered() .AND. STDMRValid()
	/*
	Se o registro de midia for obrigatorio e nao foi informado, 
	chama tela para informar, 	caso tenha midias validas cadastradas
	 */
	STFMessage(ProcName(),"STOP",STR0011) //"E obrigatorio informar a midia"
	STFShowMessage(ProcName())
	STIMultiMedia() 			
	lRet := .F.		
EndIf

If lRet

	If nTotalVend > 0	
		
		/*
		se os pagamentos estão Somente Leitura (caixa sem permissão para Alterar Parcelas E orçamento sem alteração), 
		entao redefinimos a variavel lPayImport, para que os pagamentos sejam obtidos do orçamento importado
		*/
		If lReadOnly
			STISetPayImp(.F.)
		EndIf

		//Salva os brindes na MGC
		If lSTDSlBrin
			STDSalvaBrindes()
		EndIf

		If lVersao	//A partir da versão 12
			lContinua := .T.
			If lRegDesc
				STBFormBf()		//Calcula Bonificação
				IF oTotal:GetValue("L1_BONIF") > 0 .AND. oTotal:GetValue("L1_DESCONT") > 0 
					STIExchangePanel( { || STIDscBonf() } )
					lContinua := .F.
				EndIf
			EndIf
			
			// Inicia FidelityCore apos todos os descontos e antes da NCC
			// Proteger tambem
			
			If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
				oRaas := STBGetRaas()

				If Valtype(oRaas) == "O" .AND. oRaas:ServiceIsActive("TFC")

					oFidelityC := oRaas:GetFidelityCore()
						
					If ValType(oModelCli :=  STDGCliModel()) == "O"
						oPhone := LjPhone():New(oModelCli:GetValue("SA1MASTER","A1_DDD"),oModelCli:GetValue("SA1MASTER","A1_TEL"))
						oLjCusFCore := LjCustomerFidelityCore():New(oModelCli:GetValue("SA1MASTER","A1_NOME"),oModelCli:GetValue("SA1MASTER","A1_CGC"),;
																	oModelCli:GetValue("SA1MASTER","A1_EMAIL"),oPhone,oModelCli:GetValue("SA1MASTER","A1_DTNASC"),oModelCli:GetValue("SA1MASTER","A1_DTNASC"))
					EndIf 

					// -- Desativa Botões na tela
					STIBtnDeActivate()
					oFidelityC:Initiation(xfilial("SL1") + STDGPBasket("SL1","L1_NUM"),oTotal:GetValue("L1_VLRLIQ"),oLjCusFCore)
					// -- Ativa Botões na tela
					STIBtnActivate()

					If oFidelityC:ChoseToUse() .And. (nBonus :=  oFidelityC:GetBonus()) > 0
						STBTotDiscApply(nBonus,"V","FIDELITYCORE",.T.)
						STDSPBasket("SL1","L1_DESCFID", nBonus)
					EndIf 

				EndIf
				
			EndIf 


			If lContinua
				If Len(aNCCs) > 0
					STIExchangePanel( { || STINCCSelection() } )
				Else
					STIExchangePanel( { || STIPayment() } )
				EndIf
			EndIf

		Else
			If Len(aNCCs) > 0
				STIExchangePanel( { || STINCCSelection() } )
			Else				
					If (nVLBonif > 0) .And. (nTotalVend > nVLBonif )                         
						STIExchangePanel( { || STIPayment() } ) 
					    STIAddPay("BF", Nil, 1, Nil, Nil, nVLBonif)  //Bonificacao
					Else				
						STIExchangePanel( { || STIPayment() } ) 
					Endif	                                          							
			EndIf
		Endif

	Else
		STFMessage(ProcName(),"STOP",STR0005) //"Nenhum item foi registrado."
		STFShowMessage(ProcName())
	EndIf

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIComma
Converte String com decimais em vírgula para numérico com decimais em ponto

@param   	cValue			String a ser convertida
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	nValue			Numerico com ponto
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIComma( cValue )

Local nValue		:= 0		// Retorna valor

If !Empty(cValue)

	If AT(",",cValue) > 0
	
		cValue := 	StrTran(cValue, ",", ".")

	EndIf

	nValue := Val( cValue )

Else

	nValue := 0

EndIf

Return( nValue )


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetProd
Retorna o que o usuario digitou no get de produto 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	cGetProd
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetProd()

Return cQtdDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetPrd
Ajusta o campo de produto conforme repassado por parametro 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	16/09/2014
@return  	cGetProd
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STISetPrd(cQtdDAux)

Default cQtdDAux := ""

cQtdDesc := cQtdDAux 
 
Return cQtdDesc


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetPanP
Retorna o Get de digitacao do produto para poder ser manipulado , setfocus por exemplo  

@param   	
@author  	Vendas & CRM
@version 	P11
@since   	09/09/2015
@return  	oPanGetProd
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIGetCodP()

Return oCodProd


//--------------------------
/*/{Protheus.doc} STIGetBtIR
Retorna o botão responsavel por finalizar a venda.

@author  	Vendas & CRM
@version 	P11
@since   	09/09/2015
@return  	oButton
@obs		Essa função foi criada para resolver o problema do foco, quando se apertava o enter quando o get do produto estava vazio
@sample
/*/
//-------------------
Function STIGetBtIR()
Return oButton


/*/{Protheus.doc} STISetBtIR
Seta um valor ao botão responsavel por finalizar a venda  

@param   	oBtn
@author  	Vendas & CRM
@version 	P11
@since   	06/11/2015
@return
@obs
@sample
/*/
//-----------------------
Function STISetBtIR(oBtn)
Default oBtn := Nil

oButton := oBtn

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIOperIT
Retorna o conteudo do parâmetro MV_LJITOP tratado.

@param   	
@author  	albertod
@version 	P11.8
@since   	04/07/2017
@return  	aMVLJITOP Array com o conteudo do parâmetro MV_LJITOP tratado.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIOperIT()
Local cMVLJITOP := ""
Local nI		:= 0

/*
Configuracao do Parametro MV_LJITOP:
  Posicao 1 = * Quantidade
  Posicao 2 = - Valor Desconto
  Posicao 3 = % Perc. Desconto
  Posicao 4 = ? Pesquisa produto
*/
cMVLJITOP := SuperGetMv("MV_LJITOP", ,"*,-,%,?")  	// Parametro com os codigos dos caracteres de atalho de operacoes do item no registro do item 

aMVLJITOP := StrToKarr(cMVLJITOP , ",")

For nI := 1 To Len(aMVLJITOP)
	If AllTrim(aMVLJITOP[nI]) == "0"
		aMVLJITOP[nI] := ""
	EndIf
Next nI

If Len(aMVLJITOP) < 4
	MsgAlert("Conteúdo do parametro MV_LJITOP inválido. Por favor verifique!") //STR0029 "Conteúdo do parametro MV_LJITOP inválido. Por favor verifique!"
	aMVLJITOP := StrToKarr("*,-,%,?" , ",")
EndIf

Return aMVLJITOP


//-------------------------------------------------------------------
/*/{Protheus.doc} STIPePay
Executa o PE StCallPay antes de passar para a proxima tela

@param   	
@author  	Bruno ALmeida
@version 	P12
@since   	11/06/2019
@return  	lRet - Retorna um valor logico
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIPePay()

Local lStCallPay	:= ExistBlock("StCallPay") //Verifica se existe o ponto de entrada StCallPay
Local oModelCesta 	:= STDGPBModel() // Model da cesta
Local lRet 			:= .T. //Variavel de retorno

If lStCallPay
	oModelCesta := oModelCesta:GetModel("SL2DETAIL")
	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Antes de executar o ponto de entrada StCallPay")
	lRet := ExecBlock("StCallPay",.F.,.F.,{STDGPBasket("SL1","L1_CLIENTE"),STDGPBasket("SL1","L1_LOJA"),oModelCesta})
	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Depois de executar o ponto de entrada StCallPay")
	If !(ValType(lRet) == "L")
		LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O ponto de entrada StCallPay nao retornou um valor logico e por conta disso nao abriu a tela de pagamento")
		lRet := .F.
	ElseIf !lRet
		LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O ponto de entrada StCallPay retornou um valor logico igual a .F. e por isto nao ira abrir a tela de pagamento")
	EndIf
EndIf

Return lRet
