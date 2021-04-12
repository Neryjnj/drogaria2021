#INCLUDE "Protheus.ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"  
#INCLUDE "STIPAYMENT.CH"
#INCLUDE "STPOS.CH"

#DEFINE SE1SALDO		6	// Posicao do campo E1_SALDO do Array aNCCs

Static nUsedCards	:= 0                                // Numero de cartoes usados na venda Homologacao TEF
Static oPay			:= STBWCPayment():STBWCPayment()
Static aGetSX5Pay   := STIGetSx5()
Static aPaym 		:= aClone(aGetSX5Pay[1])
Static aCopyPaym	:= aClone(aGetSX5Pay[2])
Static aNCCPay		:= {}
Static oModel		:= Nil
Static oListTpPaym	:= Nil
Static oListResPg	:= Nil
Static nAjustCols	:= 0									//Largura do listbox de resumo de pagamento para ajuste das colunas
Static oLblGroup1	:= Nil		
Static lListWhen	:= .T.									//Indica se o listbox de selecao de pagamento È editavel
Static oPnlAdconal	:= Nil									//Objeto do painel adicional																						
Static oPanBkpPay	:= Nil									//Backup do objeto oPanPayment
Static lDisableBtn	:= .T.									//Desabilita/Habilita os botoes de Limpar e Finalizar pagamentos
Static bDataCheck	:= Nil
Static lIsPAF		:= STBIsPAF()
Static lHomolPaf	:= ExistFunc("STBHomolPaf") .AND. STBHomolPaf() //HomologaÁ„o PAF-ECF
Static lPayImport	:= .F.	//Pagamento no momento da importacao do orcamento
Static aCallADM		:= {}									// Armazena formas de pagamento para informar Adm. Fin.
Static aCheckRms	:= {} //Valores pagos em cheque para RMS 
Static aConvRms		:= {} //Valores pagos em convenio para RMS 
Static nPayROnly	:= 0	//indica se os campos de pagamentos ser„o Somente Leitura 
Static oPPanel 		:= Nil	//Paint Painel para pagamentos modo scroll
Static oPanPayment	:= Nil
Static lSTIAtvTefP	:= NIL
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )		//Se utiliza MFE
	
/*
Detalhes sobre nPayROnly:
Nos casos onde um orÁamento for importado e o Caixa n„o tiver permiss„o para Alterar Parcelas, 
os Gets dos pagamentos dever„o estar como Somente Leitura. Os valores para essa variavel s„o:
(0)(.F.) - permiss„o n„o verificada / (-1)(.F.) - permite escrita / (1)(.T.) - somente leitura
Essa variavel tambÈm pode retornar um valor LÛgico, atravÈs da funÁ„o STIGetPayRO() 
*/ 

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPayment
Interface para Pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPayment(lAutom)

Local oPanelMVC		:= STIGetPanel()									//Painel do MVC	Painel de botoes
Local nAltura 		:= 0		 										//Altura
Local nCol			:= 0												//Coordenada horizontal
Local nLargura		:= 0												//Largura
Local oLblVendPay	:= Nil												//Objeto de venda > pagamento
Local oLblTpPaym	:= Nil												//Label de pagamento
Local oLblGroup2	:= Nil												//Label 2 que fica dentro do group (oGrpPaym)
Local oMdlMst		:= Nil												//Model master
Local oMdlParc		:= Nil												//Model parcelas
Local oMdlaPaym		:= Nil												//Model apayments
Local aResPay		:= {}												//Resumo de pagamento
Local nI 			:= 0												//Contador
Local cNumOrig		:= STDGPBasket("SL1" , "L1_NUMORIG")
Local aFormMultNeg  := Nil												//Forma de pagamento contida na multinegociacao

Static oLblRestVP	:= Nil												//Saldo Restante do Vale Presente
Static oLblValVPRest:= Nil												//Valor Saldo Restante do Vale Presente
Local lMobile 		:= STFGetCfg("lMobile", .F.)						//Smart Client Mobile

/* Variaveis do objeto -> oLblTpPaym */
Local nPosAltTpLbl	:= oPanelMVC:nHeight * 0.030						//Posicao: Altura do ListBox
 
/* Variaveis do objeto -> oListTpPaym */
Local nPosAltListBox:= oPanelMVC:nHeight * 0.046						//Posicao: Altura do ListBox
Local nTamAltListBox:= oPanelMVC:nHeight * 0.11							//Tamanho: Altura do ListBox

/* Variaveis do objeto -> oGrpPaym */
Local nPosAltGroup	:= oPanelMVC:nHeight/4.807							//Posicao: Altura do GroupBox
Local nTamAltGroup	:= oPanelMVC:nHeight/3.9588							//Tamanho: Altura do GroupBox
Local nTamLarGroup	:= oPanelMVC:nWidth  * 0.485						//Tamanho: Lagura do GroupBox 

/* Variaveis do objeto -> oLblGroup1 */
Local nPosAltLb1	:= oPanelMVC:nHeight * 0.178						//Posicao: Altura do Label1 GroupBox 
Local nPosHozLb1	:= oPanelMVC:nWidth  * 0.140						//Posicao: Horizontal do Label1 GroupBox
	
/* Variaveis do objeto -> oLblGroup2 */
Local nPosAltLb2	:= oPanelMVC:nHeight * 0.190						//Posicao: Altura do Label2 GroupBox
Local nPosHozLb2	:= oPanelMVC:nWidth  * 0.140						//Posicao: Horizontal do Label2 GroupBox

/* Cria um bloco de codigo para ser utilizado na tela do cheque qdo for chamado pela condicao de pagamento */
Local nPosHozPan	:= 0					   							//Posicao horizontal do painel
Local nPosAltPan	:= 0   												//Posicao: Altura do Painel
Local nTamLagPan	:= 0   												//Tamanho: Largura do Painel
Local nTamAltPan	:= 0      											//Tamanho: Altura do Painel
Local bCreatePan	:= Nil						  						// Bloco de codigo para criacao do Painel adicional
Local oTEF20		:= IIF(ValType(STBGetTef()) == 'O', STBGetTef(), STBGetChkRet())	//Objeto do TEF ativo
Local nVLBonif      := 0    		// valor total das bonificacoes
Local lFixaPgto     := .F.  		// existe forma de pagamento pre-determinada

Local nId 			:= 0			//Id do shape
Local nTop 			:= 1			//Posicao Top	
Local nLeft 		:= 1			//Posicao Left
Local nHeight 		:= 122			//Altura  
Local nShapeDim 	:= 145			//Dimensao  //160
Local cColor 		:= ""			//Cor normal 
Local cColorHover 	:= ""			//Cor hover   
Local cColorSelec 	:= ""			//cor Selecao 
Local cImage 		:= ""			// Nome da Imagem
Local cTextPgto		:= ""			// Descricao do Pagamento
Local aButtonText	:= {}			// Array com botoes de texto para crair os shapes
Local aTextPgto		:= {} 			// vetor com o texto dos botoes criados
Local nLastShape 	:= -1 			// Ultimo shape antes da nova seleÁ„o
Local cButtonText	:= ""			// Texto botao
Local cPdvColor		:= SuperGetMv( "MV_LJCOLOR",,"07334C")	// Quarda Cor da tela do PDV
Local aPdvColors	:= {}			//Paleta de cores do PDV
Local IsFly01 		:=  FindFunction('ISFly01') .AND. ISFly01() //Verifica se È Fly01
Local oScroll		:= Nil			//Obj scroll 
Local lFirstTime	:= .T.			// Valida a exibiÁ„o da tela de CC/CD para criar somente uma tela
Local lTotDA1		:= ExistFunc('STDGetDA1') //Verifica se existe a funcao STDGetDA1
Local nTotNCC		:= STDGetNCCs("2") //Total de NCC
Local lImport		:= !Empty(STDGPBasket("SL1" , "L1_NUMORIG")) // Variavel de controle que identifica se È importaÁ„o de orÁamento
Local lBonificacao	:= .F. 				//Identifica se a venda tera alguma bonificacao ou nao
Local lRegDesc		:= SuperGetMV('MV_LJRGDES',,.F.) .AND. ExistFunc("STBFORMBF") .AND. ExistFunc("STIDSCBONF") .AND. GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019") //Regra de desconto
Local oTotal        := STFGetTot()      											//Recebe o Objeto totalizador
Local lIsOrc		:= STBIsImpOrc()												// -- Indica se È importaÁ„o de orÁamento
Local bZeraPay		:= { || STIZeraPay(Iif(lIsOrc,.T.,.F.), Iif(lIsOrc,.F.,.T.)) }	// -- Zera os pagamentos baseados na Permiss„o de usuario + a variavel lIsOrc
Local nVSubsidio	:= 0 				//Valor de subsidio da venda referente ao PBM (Drogaria)
Local cFormaSub		:= ""				//Forma de Pagamento de subsidio da venda referente ao PBM (Drogaria)
Local lTFrtAltPg	:= .F.

Default lAutom		:= .T. // Inclui a forma de pagamento autom·tica

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Monta a interface de pagamento" )  //Gera LOG

oPanPayment		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2) 	//Painel do pagamento
nAltura			:= (oPanPayment:nHeight / 2) * 0.20 		 										//Altura
nCol			:= (oPanPayment:nWidth / 2) * 0.03													//Coordenada horizontal
nLargura		:= (oPanPayment:nWidth / 2) - (2 * nCol)											//Largura

nPosHozPan		:= oPanelMVC:nWidth/76.2            							//Posicao horizontal do painel
nPosAltPan		:= oPanPayment:nHeight/4.807        							//Posicao: Altura do Painel
nTamLagPan		:= oPanPayment:nWidth/2.09836       							//Tamanho: Largura do Painel
nTamAltPan		:= oPanPayment:nHeight/3.4512       							//Tamanho: Altura do Painel
bCreatePan		:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanPayment;
												,,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional

/*
Se for orÁamento importado e o usu·rio n„o tem permiss„o para Alterar Parcelas, 
o usuario nao pode editar os campos Data/Valor e Parcela das formas de pagamento
*/
If nPayROnly == 0	
	If !Empty(cNumOrig) .AND. !STFProfile(9)[1]
		STISetPayRO(1)	//campos somente leitura
	Else
		STISetPayRO(-1)	//campos com escrita
	EndIf	
EndIf

/* Limpa as mensagens das etapas anteriores ao pagamento */
STFCleanInterfaceMessage()

nAjustCols 	:= nLargura
oPanBkpPay 	:= oPanPayment
bDataCheck		:= {||TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,oPanelMVC:nHeight/2)}

/* Label: Pagamento */
oLblVendPay := TSay():New(POSVERT_CAB, POSHOR_1, {||STR0006}, oPanPayment,,,,,,.T.,,,nLargura,11.5) //'Pagamento'
oLblVendPay:SetCSS( POSCSS (GetClassName(oLblVendPay), CSS_BREADCUMB )) 

/* Label: Selecione a forma de pagamento */
oLblTpPaym := TSay():New(POSVERT_LABEL1	, POSHOR_1, {||STR0002}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Selecione a forma de pagamento'
oLblTpPaym:SetCSS( POSCSS (GetClassName(oLblTpPaym), CSS_LABEL_FOCAL )) 

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Template de Drogaria
If ExistFunc("LjIsDro") .And. LjIsDro()
	lTFrtAltPg := ExistTemplate("FRTALTPG") //Template Function utilizada para omitir formas de pagamento.
	//Verifica se tem Subsidio de PBM na venda.
	If STBSubsidio(@nVSubsidio, @cFormaSub)
		//Se tiver subsidio, seta a variavel de template igual a falso para carrega todas as formas de pagamento padr„o.
		lTFrtAltPg := .F.
	EndIf
EndIf

//Filtra os meios de pagamento disponÌveis para seleÁ„o na interface.
If ExistFunc("STBFiltPay")
    aPaym := STBFiltPay(aGetSX5Pay,lTFrtAltPg)
EndIf

//N„o sendo versao mobile exibe um listbox de pagamentos
If !lMobile 

	//------------------------------------
    // ListBox dos tipos de pagamentos
    //-----------------------------------
	oListTpPaym := TListBox():Create(oPanPayment, POSVERT_GET1, POSHOR_1, Nil, aPaym, nLargura, nTamAltListBox,,,,,;
					.T.,,{||lListWhen := .F., lDisableBtn := .F., STIAddNewPan(oPanPayment, oListTpPaym)},,,,{||lListWhen == .T.})
	
	oListTpPaym:SetCSS( POSCSS (GetClassName(oListTpPaym), CSS_LISTBOX )) 
	//Verifico se tem permiss„o para alterar a forma de pagamento
	If lIsOrc .And.  STFGetCfg("lChangePay", .F.) 
		oListTpPaym:lReadOnly := !STFPROFILE(41)[1]
	Else
		oListTpPaym:lReadOnly := STIGetPayRO()
	EndIf
Else
		
	//-----------------------------------------
	// Painel de pagamentos para vers„o Mobile
	//------------------------------------

	//Para a Vers„o Fly os valores das cores sao fixos, para o PDV Movel Totvs de acordo com parametro
	aPdvColors := IIF( IsFly01 , {'FF9300','F37021','F16E01','FF8000','FFA200'}, FWGetMonocromatic(cPdvColor) )
     
	cColor 		:= "1,0,0,0,0,0.0,#FFFFFF"	//Cor Padr„o - Branco
	cColorHover 	:= "1,0,0,0,0,0.0,#" +	AllTrim(aPdvColors[5]) 	//Cor hover  
	cColorSelec 	:= "1,0,0,0,0,0.0,#"	+  AllTrim(aPdvColors[5]	)	//cor Selecao 
    
    oScroll := TScrollArea():New(oPanPayment,POSVERT_LABEL1,POSHOR_1,65,nLargura)
    
    // lTracking permite o arrasto atraves dos itens do TPaintPanel
    oScroll:lTracking := .T. 
    oScroll:setCss(POSCSS( GetClassName(oScroll), CSS_CHOOSE_PAYMENT) )

	// Painel que ira conter os itens
    oPPanel := TPaintPanel():new(0,0,nLargura,62,oScroll)
    oPPanel:SetReleaseButton (.T.) 
    oPPanel:SetCss(POSCSS( GetClassName(oScroll), CSS_PAYMENT_ITEM))
    oScroll:SetFrame( oPPanel )
	 
	For nI := 1 to 3
	
		nId++	
		cButtonText := ""
		//  Insere botao
		oPPanel:addShape(	"id="+cValTochar(nId)+;
							";type=1;left="+cValToChar(nLeft)+;
							";top="+cValToChar(nTop)+";"+;
							"width="+cValTochar(nShapeDim)+;
							";height="+cValTochar(nHeight)+";"+;
							"gradient="+cColor+;
							";gradient-hover="+cColorHover+;
							";pen-width=0;"+;
							"pen-width=1;"+;
							"can-move=0;")
				

		If nI == 1
			cImage := "dinheiro"
			cTextPgto := "DINHEIRO"
		ElseIf nI == 2
			cImage := "cartao"
			cTextPgto := "CART√O"
		ElseIf nI == 3
			cImage := "cheque"
			cTextPgto := "CHEQUE"
		EndIf
		
		aAdd(aTextPgto, cTextPgto)
		
		//Imagem
	
		oPPanel:addShape(	"id="+cValToChar(nId)+ ";" +;
							"subID=1;" +;
							"type=8;" +;
							"left="+cValToChar(nLeft)+ ";" +;
							"top="+cValToChar(nTop-10)+";"+; 
							"width="+cValTochar(nShapeDim) + ";" +;
							"height="+cValTochar(nHeight)+ ";" +;
							"image-file=rpo:"+cImage+".png;" +;
							"can-move=0;"+;
							"gradient="+cColor+";" + ;
							"gradient-hover="+cColorHover+";") 	
						
		//Texto	
		
        aadd( aButtonText,;
        	   "id="+cValToChar(nId)+;
        	   ";subID=2;type=7;pen-width=1;font=arial,14,0,0,3;can-move=0;"+;
              "left="+cValToChar(nLeft)+;
              ";top="+cValToChar(90)+";"+; 
              "width="+cValTochar(nShapeDim)+;
              ";height="+cValTochar(nHeight)+";"+;
              "text="+cTextPgto+";"+;
              "pen-color=@@COLOR@@;"+;
              "gradient="+cColor+";" )

       cButtonText := strTran( aButtonText[nI] , "@@COLOR@@" , "#000000"  ) 	// Substitui cor (black) "#000000"  "#757575"
       oPPanel:addShape( cButtonText )					

		nLeft += (nShapeDim)
		
		
		
	Next nI
	
	// Define tamanho final do painel dos botoes
	oPPanel:nWidth := nLeft
	// Acao do botao
	oPPanel:blClicked  := {	|x,y| adjShape( 	oPPanel		, nId			, cColor				, cColorHover 	,;
							 						@nLastShape	,aButtonText	, aButtonText			, oPanPayment	)	,;
						    	oPPanel:SetGradient(oPPanel:ShapeAtu,.T.,cColorSelec),;
						    	oPPanel:SetGradient(oPPanel:ShapeAtu,.F.,cColorSelec)}

EndIf

/* Label: Resumo do pagamento */
oLblResPay := TSay():New(oPanelMVC:nHeight/4.2566, POSHOR_1, {||STR0013}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Resumo do pagamento' 
oLblResPay:SetCSS( POSCSS (GetClassName(oLblResPay), CSS_LABEL_FOCAL )) 

/* Label: Forma */
oLblForma := TSay():New(oPanelMVC:nHeight/3.7966, POSHOR_1, {||STR0014}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Forma'
oLblForma:SetCSS( POSCSS (GetClassName(oLblForma), CSS_LABEL_FOCAL )) 

/* Label: Valor */
oLblValor := TSay():New(oPanelMVC:nHeight/3.7966, POSHOR_1 * 7.3, {||STR0015}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Valor'
oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 

/* Label: Parcelas */
oLblParcelas := TSay():New(oPanelMVC:nHeight/3.7966, POSHOR_1 * 12.3, {||STR0016}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Parcelas'
oLblParcelas:SetCSS( POSCSS (GetClassName(oLblParcelas), CSS_LABEL_FOCAL ))

/* Label: Vale Presente Restante */
oLblRestVP := TSay():New(oPanelMVC:nHeight/4.0966, POSHOR_1 * 17.4, {||STR0027}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Saldo Vale Presente'
oLblRestVP:SetCSS( POSCSS (GetClassName(oLblRestVP),CSS_BREADCUMB ))

/* Label: Restante */
oLblRest := TSay():New(oPanelMVC:nHeight/3.2966, POSHOR_1 * 18.9, {||STR0028}, oPanPayment,,,,,,.T.,,,nLargura,9) //'Saldo a Pagar'
oLblRest:SetCSS( POSCSS (GetClassName(oLblRest),CSS_BREADCUMB )) 

/* Label: Troco */
oLblTroco := TSay():New(oPanelMVC:nHeight/2.7966, POSHOR_1 * 21.1, {||STR0018}, oPanPayment,,,,,,.T.,,,nLargura,8) //'Troco'
oLblTroco:SetCSS( POSCSS (GetClassName(oLblTroco),CSS_BREADCUMB )) 

/* ListBox dos resumos de pagamentos */
oListResPg := TListBox():Create(oPanPayment, oPanelMVC:nHeight/3.45882 /*POSVERT_GET5*/, POSHOR_1, Nil, {}, nLargura * 0.65, nTamAltListBox,,,,,.T.,,{||.T.},,,,{||.F.})
oListResPg:SetCSS( POSCSS (GetClassName(oListResPg),CSS_LISTBOX )) 

/* Button para finalizacao do pagamento */
oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0019 + IIF(lMobile,"",CRLF+"(CTRL+P)") ,oPanPayment,{ || STIConfPay(,"Click") }, ; //"Finalizar pagamento"
							LARGBTN,ALTURABTN,,,,.T.,,,,{||lDisableBtn})
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

/* Limpar pagamento */
oBtnLimpar := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0020 + IIF(lMobile,"",CRLF+"(CTRL+L)") ,oPanPayment,bZeraPay, LARGBTN,ALTURABTN,,,,.T.,,,,{||lDisableBtn}) //"Limpar Pagto(s)." e checa se existe Brinde ou Bonificacao j· concedidos
oBtnLimpar:SetCSS( POSCSS (GetClassName(oBtnLimpar), CSS_BTN_ATIVO )) 

SetKey(6,  {|| "" }) //Desabilita CTRL + F neste momento
SetKey(16, {|| STIConfPay(,"Atalho") })
SetKey(12, bZeraPay)

/*Chamada da Regra da Promocao Desconto por Desconto*/   
If lAutom
	STWRuleTotal()
Endif	

/* Model Payment */
If ValType(oModel) == "U"
	ModelPayme()
EndIf

/* Ativacao do model Parcelas */
oMdlParc := oModel:GetModel("PARCELAS")
oMdlParc:Activate()

/* Ativacao do model aPayments */
oMdlaPaym := oModel:GetModel("APAYMENTS") 
oMdlaPaym:Activate()

If lAutom .And. !STIBlqMnTef()
	STILmpTef(oMdlParc,oMdlaPaym)
Else
	oMdlaPaym:ClearData()
	oMdlaPaym:InitLine()
	oMdlParc:ClearData()
	oMdlParc:InitLine()
EndIf

/* Label: 0.00 Saldo Vale Presente*/
oLblValVPRest := TSay():New(oPanelMVC:nHeight/3.7666, POSHOR_1 * 20.9,, oPanPayment,,,,,,.T.,,,nLargura,8)
oLblValVPRest:SetCSS( POSCSS (GetClassName(oLblValVPRest), CSS_LABEL_FOCAL ))

/* Label: 0.00 */
oLblValRest := TSay():New(oPanelMVC:nHeight/3.0666, POSHOR_1 * 20.9, {||Str(STBCalcSald("1"),10,2)}, oPanPayment,,,,,,.T.,,,nLargura,8)
oLblValRest:SetCSS( POSCSS (GetClassName(oLblValRest), CSS_LABEL_FOCAL )) 

/* Label: 0.00 */
oLblValTroco := TSay():New(oPanelMVC:nHeight/2.6386, POSHOR_1 * 20.9, {||Str(STBGetTroco(),10,2)}, oPanPayment,,,,,,.T.,,,nLargura,8)
oLblValTroco:SetCSS( POSCSS (GetClassName(oLblValTroco), CSS_LABEL_FOCAL ))

STISetaCallADM({}) //Limpa Array Adm. Fin.
If ExistFunc("STISetnCards")
    STISetnCards(1) //Configura o array de Contador de Cartıes
EndIf

If lRegDesc
	nVlBonif := oTotal:GetValue("L1_BONIF")
	If nVlBonif > 0
		lBonificacao := .T.
		STIAddPay("BF", Nil, 1, Nil, Nil, nVlBonif)
	EndIf
EndIf

//Adiciona no grid de pagamento a forma de pagamento utilizada como padr„o na venda PBM com subsidio
If nVSubsidio > 0 .And. !Empty(cFormaSub)
	STIAddPay(cFormaSub, Nil, 1, Nil, Nil, nVSubsidio)
EndIf

/* Inclui o primeiro pagamento com base no parametro  */
If lAutom .AND. !lMobile .AND.;
		 !( lImport .AND. ExistFunc("STBGetDiscTotPDV") .AND. STBGetDiscTotPDV()) .AND. !lBonificacao .AND. nVSubsidio == 0
	aResPay := STBUpdResPg(nAjustCols,.T.,nVLBonif,oListTpPaym)
	oListResPg:Reset()
	oListResPg:SetArray(aResPay)
Endif	

/* Verifica se foi concedido desconto do Total pelo PDV */
If lImport .AND. ExistFunc("STBGetDiscTotPDV") .AND. STBGetDiscTotPDV()
	STISetaCallADM( {} )	
Else
	aCallAdm := STIGetaCallADM() 
EndIf

/* Tratamento para venda com cart„o na tela de multinegocicao */
If !lAutom .And. IIf(ExistFunc("STIFMultNeg"),STIFMultNeg(),.F.)

	// Verifica forma de pagamento da multinegociacao
	aFormMultNeg := IIf(ExistFunc("STITEFMultNeg"),STITEFMultNeg(),.F.)
	
	For nI := 1 To Len(aFormMultNeg)	
		// Se forma de pagamento da multinegocicao conter CC ou CD abre a tela do cart„o
		If aFormMultNeg[nI][01] $ "CC|CD"
			oPnlAdconal := Eval(bCreatePan)
	
			/* Tela do cartao */	
			STIPayCard(oPnlAdconal, aFormMultNeg[nI][01], aFormMultNeg[nI][02], aFormMultNeg[nI][03] )
		EndIf
	Next
EndIf
	
For nI := 1 To Len(aCallAdm)
	/* Tratamento para abrir a tela de financiamento */
	If aCallAdm[nI][5] == "FI"
		oPnlAdconal := Eval(bCreatePan)
		
		/* Tela do financiamento */
		STIFinOrc(oPnlAdconal, aCallAdm[nI][2] , aCallAdm[nI][3], aCallAdm[nI][5], aCallAdm[nI][1])

	ElseIf aCallAdm[nI][5] $ "CC|CD"	//retiramos o trecho que faz a chamada do TEF quando um orÁamento È importado		
		If lFirstTime
			oPnlAdconal := Eval(bCreatePan)
		
			/* Tela do cartao */
			STIPayCard(oPnlAdconal, aCallAdm[nI][5] , aCallAdm[nI][2], aCallAdm[nI][3] )
			
			lFirstTime := .F.
		EndIf
	Else
		oPnlAdconal := Eval(bCreatePan)

		//Tela do formas genericas (criadas pelo usuario ou diferentes das citadas acima)
		STIFinOrc(oPnlAdconal, aCallAdm[nI][2] , aCallAdm[nI][3], aCallAdm[nI][5], aCallAdm[nI][1])
	EndIf
Next nI

STIRfshVP(.T.) // esconde saldo vale presente atÈ que o usuario selecione o vale presente como forma de pagamento

If lMobile
	STIZeraPay(.T.)
EndIf

//Limpa o desconto caso o cliente tenha escolhido NCC e a regra 
//de desconto esteja configurado com tabela de preco
If lTotDA1 .AND. STDGetDA1() > 0 .AND. nTotNCC > 0
	STIClearDisc(.T.)
EndIf

/* Posiciona no primeiro registro e seta o focus */
//Se nao for versao mobile foca no List
If !lMobile
	oListTpPaym:GoTop()
	oListTpPaym:SetFocus()
	//Caso tenha uma linha no resumo de pagamento e a forma de pagamento em branco, permite definir uma nova forma de pagamento
	If oMdlParc:Length() == 1 .And. Empty(oMdlParc:GetValue('L4_FORMA'))
		oListTpPaym:bWhen :=  {||.T.}
	EndIf
EndIf

Return oPanPayment

//-------------------------------------------------------------------
/*/{Protheus.doc} AdjShape
Retorna shapes a cor original e chama rotina correspondente

@param   	oPPanel  		- Paint Painel dos Objetos com shape
@param   	nId  			- Id do shape selecionado
@param   	cColor  		- Cor do shape
@param   	cColorHover 	- Cor do shape quando o ponteiro estiver posicionado sobre o objeto
@author  	Varejo
@version 	P11.8
@since   	25/03/2015
@return	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function AdjShape( oPPanel		, nId			, cColor		, cColorHover ,;
							 nLastShape	, aButtonText	, aTextPgto   , oPanPayment	)

Local nX 				:= 0  		//Contador
Local cButtonText		:= ""		//texto do botao

Default oPPanel 			:= Nil	
Default nId 				:= 1	
Default cColor 			:= ""	
Default cColorHover 		:= ""	
Default nLastShape 		:= 1	
Default aButtonText 		:= {}
Default aTextPgto 		:= {}	
Default oPanPayment 		:= Nil	
	
// Retorna shape anterior a cor original
If nLastShape > -1
    cButtonText := strTran( aButtonText[nLastShape], "@@COLOR@@", "#000000"  ) //  Substitui cor (black)
    oPPanel:updateShape( cButtonText )
EndIf

// Assumi novo "LASTSHAPE"
nLastShape := oPPanel:ShapeAtu

// Muda a cor do texto do item selecionado
cButtonText := strTran( aButtonText[oPPanel:ShapeAtu], "@@COLOR@@", "#FFFFFF" ) // Substitui cor (white)
oPPanel:updateShape( cButtonText )

For nX := 1 to nId
	oPPanel:SetGradient(nX,.T., cColorHover)
	oPPanel:SetGradient(nX,.F., cColor)
Next


If STBCalcSald("1") > 0

	//Seleciona forma de pagamento de acordo com ID 	 	
	//OBS: os Ids sao fixos 
	oPPanel:bWhen := {||.F.}
	
	Do Case
		
		Case oPPanel:ShapeAtu == 1	
			STIAddNewPan(oPanBkpPay, "R$")		
			
		Case oPPanel:ShapeAtu == 2
			STIAddNewPan(oPanBkpPay, "CC")
			
		Case oPPanel:ShapeAtu == 3
			STIAddNewPan(oPanBkpPay, "CH")
	
	EndCase	
	
EndIf
	
Return Nil

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIAddNewPan
Painel para SeleÁ„o de Forma de Pagamento

@param   	oPanPayment
@param   	oListTpPaym
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIAddNewPan(oPanPayment, oListTpPaym, cPgtoSelected, aPayment)

Local oPanelMVC		:= STIGetPanel()							// Object Painel MVC
Local nPosHozPan	:= oPanelMVC:nWidth/76.2					//Posicao horizontal do painel
Local nPosAltPan	:= oPanPayment:nHeight/4.807			//Posicao: Altura do Painel
Local nTamLagPan	:= oPanPayment:nWidth/2.09836			//Tamanho: Largura do Painel
Local nTamAltPan	:= oPanPayment:nHeight/3.4512			//Tamanho: Altura do Painel
Local bCreatePan	:= {||TPanel():New(nPosAltPan,nPosHozPan,"",oPanPayment;
						,,,,,,nTamLagPan,nTamAltPan)}   // Bloco de codigo para criacao do Painel adicional			
Local cTypeCard		:= ""                               // Tipo do cartao, utilizado quando a opcao de pagamento igual a CC ou CD
Local cTpForm		:= ''									//Tipo da forma de pagamento					
Local lRet          := .F.                              // Confirma se o pagamento foi concluÌdo ou cancelado   
Local lOk           := .F.									// Vari·vel de pesquisa
Local aPgto         := {}									// Array para formas de pagamento
Local lContinua		:= .T.
Local lPayFin		:= .T.									// Em caso de condicao de pagamento especifica abre painel de pagamento especifico
//Criado proteÁ„o na variavel lPromPgto para validar o par‚metro da regra de desconto pois 
//estava retornando sempre .T. e dava erro ao definir a condiÁ„o de pagamento
Local lPromPgto     := ExistFunc("STBPromPgto") .AND. SuperGetMv("MV_LJRGDES",,.F.) // "Nova" Regra de Desconto - Se existe promoÁ„o por forma de pagamento
Local nX			:= 0
Local lMobile		:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile
Local lVldDesc		:= .F. //Valida se concede o desconto para a forma de pagamento
Local lCart			:= IIF(ExistFunc('STBGetCart'),STBGetCart(),.T.) //Verifica se aplica o desconto para CC ou CD
Local lClearDesc	:= IIF(ExistFunc('STBVldDesc'),STBVldDesc( '3', oModel:GetModel('PARCELAS') ),.F.)  //Verifica se limpa o desconto antes de abrir a tela para uma nova forma de pagamento

Default oPanPayment		:= Nil
Default oListTpPaym		:= Nil
Default cPgtoSelected	:= ""
Default	aPayment		:= ARRAY(2)

//Limpa as mensagens anteriores a cada novo pagamento
STFCleanInterfaceMessage()

lMobile := ValType(lMobile) == "L" .AND. lMobile

If !lMobile .And. oListTpPaym <> Nil
	cPgtoSelected := aCopyPaym[aScan(aCopyPaym,{ |x| x[2] == AllTrim(oListTpPaym:GetSelText()) })][1]
	oListTpPaym:SetFocus()
EndIf

cPgtoSelected := AllTrim(cPgtoSelected) //Pagamento selecionado

// FunÁ„o presente no Fonte STFTotalUpdate, responsavel por realizar o Back-Up de valores dos totalizadores do RodapÈ 
If ExistFunc("STFBkpTot")
	STFBkpTot()
EndIf

// Se tiver panel ativo eh retirado, pois soh pode ser criado se entrar em algum Case a baixo
If oPnlAdconal <> NIL 
    oPnlAdconal:Hide()
EndIf

lVldDesc := IIF(ExistFunc('STBVldDesc'),STBVldDesc( '1', oModel:GetModel('PARCELAS') ),.T.) 

If lClearDesc
	STIClearDisc(.T.)
EndIf

Do Case
	/* Se o saldo da venda zerou, entao nao abre mais nenhuma forma de pagamento */
	Case IIF(lPayImport .And. cPgtoSelected == 'R$',.F., .T.) .And. STBCalcSald("1") == 0
		STIEnblPaymentOptions()	
		Return .T.
		
	/* OpÁ„o de pagamento dinheiro */	
	Case cPgtoSelected == 'R$'
		
		/* So cria o painel se entrar dentro de algum case */
		oPnlAdconal := Eval(bCreatePan)
		
		If lPromPgto .AND. STBPromPgto("R$") .AND. lVldDesc //Verifica se existe regra de bonificacao
		    STBTotRlDi( ,,, .T.,"R$") 
		EndIf  

		/* Tela de dinheiro */                       
		STIPayCash(oPnlAdconal)//Dentro da PayCash que validar· se existe regra por Brinde, porque n„o precisar· adicionar nenhuma forma de pagto somente exibir as opÁıes de brinde para selecionar
	
	/* OpÁ„o de pagamento credito ou debito */
	Case cPgtoSelected $ 'CC|CD'

		// Homologacao TEF
		// Se for homologacao limita o Numero de cartoes em no Maximo 2 por venda
		If SuperGetMV("MV_LJHMTEF", ,.F.) .AND. nUsedCards >= 2 
			STFMessage(ProcName(),"POPUP",STR0021) //"Maximo de 2 cartoes utilizados na venda"
			STFShowMessage(ProcName())
		Else
			/* So cria o painel se entrar dentro de algum case */
			oPnlAdconal := Eval(bCreatePan)
			
			cTypeCard := cPgtoSelected
			
			If lPromPgto .AND. STBPromPgto(cTypeCard) .AND. lVldDesc .AND. lCart //Verifica se existe regra de bonificacao
		    	STBTotRlDi( ,,, .T.,cTypeCard,oPnlAdconal) 
			EndIf
			/* Tela do cartao */
			STIPayCard(oPnlAdconal, cTypeCard, aPayment[1], aPayment[2])	
		Endif	
	
	/* OpÁ„o de pagamento financiado */
	Case cPgtoSelected  == 'FI'
		
		cTpForm := cPgtoSelected
		
		If Len(STDGetAdmFin(cTpForm)) > 1
			/* So cria o painel se entrar dentro de algum case */
			oPnlAdconal := Eval(bCreatePan)
			
			If lPromPgto .AND. STBPromPgto("FI") .AND. lVldDesc //Verifica se existe regra de bonificacao
		    	STBTotRlDi( ,,, .T.,"FI",oPnlAdconal)
			EndIf 
			STIPayFinancial(oPnlAdconal, cTpForm)
		Endif	
		
	/* OpÁ„o de pagamento Shop Card (Cartao Fidelidade) */
	Case cPgtoSelected == 'FID'
		

		/* So cria o painel se entrar dentro de algum case */
		oPnlAdconal := Eval(bCreatePan)
			
		If !STDGUpdShopCardFundsResult() // Caso haja um produto de recarga de cartao fidelidade, a opcao fica indisponivel.
			If lPromPgto .AND. STBPromPgto("FID") .AND. lVldDesc //Verifica se existe regra de bonificacao
		    	STBTotRlDi( ,,, .T.,"FID",oPnlAdconal)
		    Else	
				STIPayShopCard(oPnlAdconal)
			Endif	
		Else
			STFMessage(ProcName(),"STOP",STR0022) //"Por se tratar de recarga de cart„o fidelidade, essa opÁ„o est· indisponÌvel."
			STFShowMessage(ProcName())
			STFCleanMessage(ProcName())
		EndIf
	
	/* OpÁ„o de pagamento cheque */
	Case cPgtoSelected  == 'CH'

		/* So cria o painel se entrar dentro de algum case */
		oPnlAdconal := Eval(bCreatePan)
		
		If lPromPgto .AND. STBPromPgto("CH") .AND. lVldDesc //Verifica se existe regra de bonificacao
	    	STBTotRlDi( ,,, .T.,"CH",oPnlAdconal)
	    EndIf	

		/* Telado do cheque */
		STIPayCheck(oPnlAdconal, bDataCheck)
		
	/* OpÁ„o de pagamento vale presente */
	Case cPgtoSelected == 'VP'
	
		/* So cria o painel se entrar dentro de algum case */
		oPnlAdconal := Eval(bCreatePan)
		
		If lPromPgto .AND. STBPromPgto("VP") .AND. lVldDesc //Verifica se existe regra de bonificacao
	    	STBTotRlDi( ,,, .T.,"VP",oPnlAdconal)
	    Else	
			/* Tela do vale presente */
			STIPayGiftV(oPnlAdconal)  
		Endif	
	/* OpÁ„o de condicao de pagamento */
	Case cPgtoSelected  == 'CP'

		lContinua := STIVerCTef()
		
		If lContinua
			lDisableBtn := .T.

			/* So cria o painel se entrar dentro de algum case */
			oPnlAdconal := Eval(bCreatePan)
			
			If lPromPgto .AND. STBPromPgto("CP") //Verifica se existe regra de bonificacao
		    	STBTotRlDi( ,,, .T.,"CP",oPnlAdconal)
		    Else	
				/* Tela da condicao de pagamento */
				STIPayCdPg(oPnlAdconal)
			Endif
		Else
			If !lMobile .AND. oListTpPaym <> NIL
				oListTpPaym:SetFocus()
			EndIf
		EndIf

	/* OpÁ„o de Multi Negociacao */
	Case cPgtoSelected == 'MN'

		lContinua := STIVerCTef()
		
		If lContinua	   		
			// Reutilizacao da NCC
			// Quando vai alterar para multinegociacao, revalida a Ncc escolhida anteriormente
			// para ser considerada nos calculos.
			STIZeraPay(.T.) 	// limpa tudo
		   	aNCCs 		:= STDGetNCCs("1")
			For nX := 1 to Len(aNCCs)
				If aNCCs[nX,1]
					STDSetNCCs("2",aNCCs[nX,SE1SALDO]) 						// Atualiza o saldo total de NCCs selecionadas
				EndIf
			Next nX  
			STIPayment(.F.)	
			STIAddPay("CR", Nil, 1, Nil, Nil, STDGetNCCs("2"))
				   		
			/* So cria o painel se entrar dentro de algum case */
			If Len( STIGetRules(STBCalcSald("1")-STWGetIncrease()) ) > 1  //aqui seta o valor que sera utilizado na multinegocicao 
				/* So cria o painel se entrar dentro de algum case */
				oPnlAdconal := NIL
				
				If lPromPgto .AND. STBPromPgto("MN") //Verifica se existe regra de multinegociacao
		    		STBTotRlDi( ,,, .T.,"MN",oPnlAdconal)
			    Else	
					/* Tela da condicao de pagamento */
					STIExchangePanel({|| STIPnlMulti(oPnlAdconal) })
				Endif
			Else
				STIEnblPaymentOptions()
				If !lMobile .AND. oListTpPaym <> NIL
					oListTpPaym:SetFocus() 
				EndIf
			EndIf
		Else
			If !lMobile .AND. oListTpPaym <> NIL
				oListTpPaym:SetFocus()
			EndIf
		EndIf
		
	/* Nota de CrÈdito CÛd. Barras */
	Case cPgtoSelected  == 'NB'
	
		/* So cria o painel se entrar dentro de algum case */
		oPnlAdconal := Eval(bCreatePan)
		
		If lPromPgto .AND. STBPromPgto("NB") //Verifica se existe regra de bonificacao
    		STBTotRlDi( ,,, .T.,"NB",oPnlAdconal)
	    Else	
			/* Tela da Nota de CrÈdito CÛd. Barras */
			STIPayNCCBC(oPnlAdconal)
		Endif
	OtherWise
	
		cTpForm := cPgtoSelected
		If Len(STDGetAdmFin(cTpForm)) > 1
			/* So cria o painel se entrar dentro de algum case */
			oPnlAdconal := Eval(bCreatePan)

			If lPromPgto .AND. STBPromPgto(cTpForm) .AND. lVldDesc //Verifica se existe regra de bonificacao
	    		STBTotRlDi( ,,, .T.,cTpForm,oPnlAdconal)
		    EndIf
			
			//Ponto de Entrada que permite customizar o painel de pagamentos da condicao de pagamento especifica
			If ExistBlock("STIPAYCST")
				lPayFin := ExecBlock("STIPAYCST",.F.,.F., {oPnlAdconal, cTpForm})
			Endif

			If lPayFin
				STIPayFinancial(oPnlAdconal, cTpForm)//Retirar a chamada STBTotRlDi desse fonte
			Endif	
			
		Else
			STIEnblPaymentOptions()
			If !lMobile .AND. oListTpPaym <> Nil
				oListTpPaym:SetFocus() 
			EndIf
		EndIf
	EndCase

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelPayme
Model - Escolha parcelas

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function ModelPayme()

Local oStruMst 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela
Local oStruDtl 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela

If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
EndIf

oModel := MPFormModel():New("STIPayment")
oModel:SetDescription(STR0006)  //"Pagamento"

oStruMst := STIStruMod(oStruMst, "Mst")
oModel:AddFields( 'BOTOES', Nil, oStruMst)
oModel:GetModel ( 'BOTOES' ):SetDescription(STR0006) //PAgamento
oModel:SetPrimaryKey({})

oStruDtl := FWFormStruct(1,"SL4",{|cCampo| Alltrim(cCampo) <> "L4_FILIAL"})
oStruDtl := STIStruMod(oStruDtl, "Dtl")
oModel:AddGrid('PARCELAS','BOTOES',oStruDtl, Nil, Nil, Nil, Nil, Nil)
oModel:GetModel( 'PARCELAS' ):SetDescription(STR0006) //"Pagamento"
oModel:GetModel( 'PARCELAS' ):SetOptional(.T.)

oModel:AddGrid('APAYMENTS','BOTOES',oStruDtl, Nil, Nil, Nil, Nil, Nil)
oModel:GetModel( 'APAYMENTS' ):SetDescription(STR0006) //"Pagamento"
oModel:GetModel( 'APAYMENTS' ):SetOptional(.T.)

Return oModel

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod
Estrutura do Model

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStru, cType)

Local nI := 0 //Variavel de Loop

Default oStru := Nil
Default cType := ""

If cType == 'Mst'

	oStru:AddField(	STR0007		,; //[01] Titulo do campo
						STR0007		,; //[02] Desc do campo
						"L4_FILIAL"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						8				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual
	
	oStru:AddField(	STR0008		,; //[01] Titulo do campo
						STR0008		,; //[02] Desc do campo
						"L4_CONDPG"		,; //[03] Id do Field
						"BT"				,; //[04] Tipo do campo
						005					,; //[05] Tamanho do campo
						0					,; //[06] Decimal do campo
						{|| .T. }			,; //[07] Code-block de validacao do campo
						Nil					,; //[08] Code-block de validacao When do campo
						Nil					,; //[09] Lista de valores permitido do campo
						Nil					,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil					,; //[11] Code-block de inicializacao do campo
						Nil					,; //[12] Indica se trata-se de um campo chave
						Nil					,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						Nil					)  //[14] Indica se o campo e virtual	

Else
	
	oStru:AddField(	STR0009		,; //[01] Titulo do campo
						STR0009		,; //[02] Desc do campo
						"L4_PARC"		,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						TamSX3("L1_PARCELA")[1],; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	"Tef"		,; //[01] Titulo do campo
						"Tef"		,; //[02] Desc do campo
						"L4_TEF"	,; //[03] Id do Field
						"L"			,; //[04] Tipo do campo
						1			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual

	oStru:AddField(	"Cod VP"	,; //[01] Titulo do campo
						"Cod VP"	,; //[02] Desc do campo
						"L4_CODVP"	,; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						TamSx3("MDD_CODIGO")[1],; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual
						
	oStru:AddField(	"Desc Fin"	,; //[01] Titulo do campo
						"Desc Fin"	,; //[02] Desc do campo
						"L4_DESCFIN"	,; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						16			,; //[05] Tamanho do campo
						2			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.			)  //[14] Indica se o campo e virtual								
						

EndIf		
											
Return oStru


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIAddPay
Add os pagamentos na grid

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	lRet - Se adicionou o pagamento com sucesso
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIAddPay(cForma, oModelFormaPag, nParc, lTef, cCodVp, nValor, aPgto)

Local oMdl 				:= oModel  			//Recupera o model ativo
Local oMdlGrd			:= oMdl:GetModel("PARCELAS")//Seta o model do grid
Local aFieldsParcelas	:= oMdlGrd:GetStruct():GetFields()		// SeleÁ„o - Parcelas
Local aFieldsFormPag	:= IIF(ValType(oModelFormaPag) == 'O', oModelFormaPag:GetStruct():GetFields(), {}) // SeleÁ„o - Forma Pag.
Local oRetTef			:= STBGetRetTef()	//Retorno da transacao TEF
Local nJ				:= 1				//Linha atual
Local nX				:= 0				//Contador do For
Local nFieldPos			:= 0				//Posicao do campo dentro da estrutura
Local cCampo			:= ""				//Campo da estrutura da SL4
Local aResPay			:= {}				//Resumo de pagamento
Local nTotPago			:= 0				//total do Pagamento
Local nTotVenda			:= 0				//total da Venda
Local nY				:= 0				//Contador do For
Local lMobile 			:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile
Local lTemDinNCC		:= .F.				// Verifica se j· houve recebimento em dinheiro ou NCC
Local lPromPgto    		:= SuperGetMv("MV_LJRGDES",,.F.) .AND. STBPromPgto(cForma)
Local nValRgDes			:= 0 //Novo valor da regra de desconto
Local nValFPgt			:= IIF(ValType(oModelFormaPag) == 'O', oModelFormaPag:GetValue("L4_VALOR"), nValor)//Valor Forma Pagto
Local lCodBand			:= IIF(ExistFunc("STILJTEF") , STILJTEF() , .F. ) 
Local lRet				:= .T.				//Retona se executou com sucesso
Local lLJRMBAC			:= SuperGetMV("MV_LJRMBAC",,.F.)  		//Habilita a integraÁ„o com RM 
Local lSTDGetDias 		:= ExistFunc("STDGetDias") 			 	//Indica se a funÁ„o STDGetDias existe 
Local nTotDA1			:= IIF(ExistFunc('STDGetDA1'),STDGetDA1(),0) //Verifica se houve desconto no total atraves de uma regra de desconto


Default cForma			:= ""
Default oModelFormaPag 	:= Nil
Default nParc			:= 1
Default lTef 			:= .F.
Default cCodVp 			:= ""
Default nValor			:= 0
Default aPgto           := {} //Resumo de Pagamento

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Inicio STIAddPay. Chamada por: " + ProcName(1) )

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Parcela tem que ser 1 - mesmo se for a vista
If nParc < 1
	nParc := 1
EndIf

//Verifica se a forma de pagamento existe na SX5 local //Pois pode ocorrer erro em importacoes de orcamento.
If  lRet .AND. !Empty(cForma) .AND. !(cForma $ 'BOL|CR|DC|BF') .AND. ( ValType(aCopyPaym) == "A" .AND. Len(aCopyPaym) > 1 .AND. Ascan(aCopyPaym,{|x| x[1] == AllTrim(cForma)  }) == 0 )
	//Nao encontrou forma de pagamento na SX5
	STFMessage("STIPayment","POPUP", STR0034 + AllTrim(cForma) + STR0035 + "SX5." ) //"A Forma de pagamento: " ### " selecionada n„o est· cadastrada neste PDV Tabela " 
	STFShowMessage("STIPayment")
	lRet := .F.
EndIf

If lRet .AND. (!Empty(aPgto) .And. cForma == "BF"  ) 
	// Atualiza o grid aPayments
     oMdlGrd:acols := aPgto
Endif 

If lRet .AND. lPromPgto .AND. nTotDA1 > 0 .AND. !(AllTrim(cForma) $ 'CC|CD') .AND. ExistFunc('STBVldDesc')
	STBVldDesc('2',,IIF(ValType(oModelFormaPag) == 'O', oModelFormaPag:GetValue('L4_VALOR'),nValor))
	STBSetReg(.T.)
ElseIf lRet .AND. (lPromPgto .And. STBCalcSald("1") > nValFPgt) .AND. nTotDA1 == 0
	nValRgDes := (STDGPBasket( "SL1" , "L1_VLRTOT" ) - STBCalcSald("1")) + nValFPgt   
	STBTotRlDi(nValRgDes,,,, cForma )	//Atualiza valor, caso regra de pagamento se aplique
EndIf

If  lRet .AND. ((ValType(oModelFormaPag) == 'O' .AND. oModelFormaPag:GetValue('L4_VALOR') > 0) .OR. (nValor > 0))

	oMdlGrd:SetNoInsertLine(.F.)
	
	/* Tratamento para somar v·rios pagamentos em dinheiro ou NCC*/
	If alltrim(cForma) == 'R$' .Or. AllTrim(cForma) == 'CR'
		//O metodo SeekLine substitui o aScan no acols (que nao esta sendo mais utilizado para a versao 12)
		//Se retornar .T. È que foi encontrado a busca e automaticamente ja esta sendo posicionada na linha desejada.	
	    If oMdlGrd:SeekLine({{"L4_FORMA", alltrim(cForma)}})
	    	nJ := oMdlGrd:GetLine()

	    	//Neste trecho contem o tratamento (adotado como padr„o seguindo FrontLoja) para substituir o valor em dinheiro  
	    	//quando ja possua a forma dinheiro informado anteriormente.
	    	//Caso necessario basta alterar para a seguinte informaÁ„o para comeÁar a somar os valores (o valor ja informado e novo valor)
	    	//oMdlGrd:LoadValue( "L4_VALOR",oModelFormaPag:GetValue("L4_VALOR")+oMdlGrd:aCols[nj,aScan( oMdlGrd:aheader,{|x| alltrim(x[2])=='L4_VALOR'} )],nJ)
		    oMdlGrd:LoadValue( "L4_VALOR",oModelFormaPag:GetValue("L4_VALOR"),nJ)
		    lTemDinNCC := .T.
	    Else
	    	nJ := 1
	    Endif
	Endif

	If !lTemDinNCC
		/* Caso seja necess·rio, e adicionada uma linha ao grid */
		IIF(oMdlGrd:Length() == 1 .AND. Empty(oMdlGrd:GetValue("L4_DATA")), Nil, nJ := oMdlGrd:AddLine(.T.))
	
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Gravacao Model SL4" )
	
		/*
			Busca nos campos da SL4 os campos que foram preenchidos pela forma de pagamento.
			Para isso, os campos devem ter o seu nome (ID) exatamente igual
		*/
		For nX := 1 To Len(aFieldsParcelas)
			cCampo := aFieldsParcelas[nX][MODEL_FIELD_IDFIELD]
			nFieldPos := aScan(aFieldsFormPag,{|aCampo| aCampo[MODEL_FIELD_IDFIELD] == cCampo})
			If nFieldPos > 0
				If lLJRMBAC .AND. lSTDGetDias .AND. ValType(oRetTef) == "O" .AND. ALLTRIM(cCampo) == "L4_DATA" .AND. !Empty(oRetTef:cAdmFin) .AND. AllTrim(cForma) == "CD"  
					oMdlGrd:LoadValue( cCampo, oModelFormaPag:GetValue(cCampo) + STDGetDias(SubStr(oRetTef:cAdmFin,1,TamSx3('L4_ADMINIS')[1])),nJ)
				Else
					oMdlGrd:LoadValue( cCampo, oModelFormaPag:GetValue(cCampo),nJ)
				EndIf 
			EndIf
		Next nX
		If Len(aFieldsFormPag) == 0
			oMdlGrd:LoadValue( "L4_DATA", dDataBase, nJ)
			oMdlGrd:LoadValue( "L4_VALOR", nValor, nJ)
		EndIf
	
		oMdlGrd:LoadValue( "L4_FORMA"	, cForma,nJ)
		oMdlGrd:LoadValue( "L4_PARC"	, nParc,nJ)
		oMdlGrd:LoadValue( "L4_TEF"		, lTef,nJ)
		oMdlGrd:LoadValue( "L4_CODVP"	, cCodVp,nJ)
		oMdlGrd:LoadValue( "L4_NUMCART"	, cCodVp,nJ)
		oMdlGrd:LoadValue( "L4_CONTDOC"	,STDGPBasket( "SL1" , "L1_CONTDOC" ))
		oMdlGrd:LoadValue( "L4_SERPDV"	, STFGetStat("SERPDV"),nJ)

		If ValType(oRetTef) == "O"
		
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Grava Dados TEF" )	
					
	    	If ValType(oRetTef:DDATA) == "D"
				oMdlGrd:LoadValue( "L4_DATATEF"	, DTOS(oRetTef:DDATA),nJ)
			Else
				oRetTef:DDATA := StrTran(oRetTef:DDATA, "/")
				If Left(oRetTef:DDATA,4)  == Str(Year(Date()),4)
					oMdlGrd:LoadValue( "L4_DATATEF"	, oRetTef:DDATA,nJ)
				Else
					oMdlGrd:LoadValue( "L4_DATATEF"	, Right(oRetTef:DDATA,4) + Substr(oRetTef:DDATA,3,2)+ Left(oRetTef:DDATA,2) ,nJ)
				EndIf
			EndIf
			oMdlGrd:LoadValue( "L4_HORATEF"	, Replace(oRetTef:CHORA,":",""),nJ )
			oMdlGrd:LoadValue( "L4_DOCTEF"	, oRetTef:CNSUAUTOR,nJ )
			oMdlGrd:LoadValue( "L4_AUTORIZ"	, oRetTef:CAUTORIZ,nJ )
			oMdlGrd:LoadValue( "L4_INSTITU"	, oRetTef:CREDE,nJ )
			oMdlGrd:LoadValue( "L4_NSUTEF"	, oRetTef:CNSU,nJ )
			oMdlGrd:LoadValue( "L4_TIPCART"	, "",nJ ) // Verificar o tipo de cartao
			oMdlGrd:LoadValue( "L4_PARCTEF"	, oRetTef:CPARCTEF,nJ )
			oMdlGrd:LoadValue( "L4_DESCFIN"	, oRetTef:nVlrDescTEF,nJ )
			oMdlGrd:LoadValue( "L4_ADMINIS"	, AllTrim(oRetTef:cAdmFin), nJ)

			If SL4->(ColumnPos("L4_BANDEIR")) > 0 .And. lCodBand //Verifica se o atributo cCodBand existe no objeto
				//Codigo da Bandeira que foi utilizada
				oMdlGrd:LoadValue( "L4_BANDEIR" , oRetTef:cCodBand,nJ )
			EndIf
			
			If SL4->(ColumnPos("L4_REDEAUT")) > 0
				//Codigo da Rede que autorizou a transacao TEF
				oMdlGrd:LoadValue( "L4_REDEAUT"	, oRetTef:cTipCart,nJ )
			EndIf
			
			oMdlGrd:LoadValue( "L4_NOMECLI"	, PadR( "RD: " + Alltrim(oRetTef:CREDE) + " / BD: " + Alltrim(oRetTef:cAdmFin), TamSX3("L4_NOMECLI")[1]) ,nJ )
			
			If SL4->(ColumnPos("L4_TRNID")) > 0 .And. AttIsMemberOf(oRetTef, "cExternalTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				oMdlGrd:LoadValue( "L4_TRNID"	, oRetTef:cIdtransaction,nJ )
			EndIf
			If SL4->(ColumnPos("L4_TRNPCID")) > 0 .And. AttIsMemberOf(oRetTef, "cProcessorTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				oMdlGrd:LoadValue( "L4_TRNPCID"	, oRetTef:cProcessorTransactionId,nJ )
			EndIf
			If SL4->(ColumnPos("L4_TRNEXID")) > 0 .And. AttIsMemberOf(oRetTef, "cExternalTransactionId", .T.) //Verifica se existe o campo e o Atributo da classe LJARetTransacaoTef (LOJA1934)
				oMdlGrd:LoadValue( "L4_TRNEXID"	, oRetTef:cExternalTransactionId,nJ )
			EndIf
		
			If lHomolPaf	.AND. lIsPAF .AND. LJAnalisaLeg(63)[1] //Troco em Santa Catarina
				nTotPago  := STIGetTotal() //Retorna o Total Pago
				nTotVenda := STDGPBasket( "SL1" , "L1_VLRTOT" )
			
				If nTotPago > nTotVenda
					oMdlGrd:LoadValue( "L4_TROCO"	, nTotPago - nTotVenda,nJ )
				EndIf
			EndIf
		
			STBSetRetTef()
		Else
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Venda sem TEF" )	
		EndIf
	Endif
	
	/* controle sobre o ID do CARTAO */
	If ExistFunc("STBSetIDTF") .AND. oMdlGrd:HasField("L4_FORMAID")	//verifica se o campo existe na estrutura
		If cForma == "CC"
			//incrementa o ID do cartao de CREDITO
			STBSetIDTF("CC")
			oMdlGrd:LoadValue( "L4_FORMAID"	, cValToChar(STBGetIDTF("CC")), nJ )
		ElseIf cForma == "CD"
			//incrementa o ID do cartao de DEBITO
			STBSetIDTF("CD")
			oMdlGrd:LoadValue( "L4_FORMAID"	, cValToChar(STBGetIDTF("CD")), nJ )
		EndIf
	EndIf

	// Grava informaÁıes do troco na SL4
	nTotPago  := STIGetTotal() //Retorna o Total Pago
	nTotVenda := STDGPBasket( "SL1" , "L1_VLRTOT" )
	If nTotPago > nTotVenda
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Grava valor troco L4_TROCO." )
		oMdlGrd:LoadValue( "L4_TROCO"	, nTotPago - nTotVenda,nJ )
	EndIf

	/* Atualiza o grid aPayments */
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Antes chamada STBUpdPaym" )
	STBUpdPaym(oMdl)
	
	/* Atualiza a lista de resumo de pagamento */
	If ValType(oListResPg) <> "U"
		aResPay := STBUpdResPg(nAjustCols,.F.)
			
		oListResPg:Reset()
		oListResPg:SetArray(aResPay)
	EndIf	
	oMdlGrd:GoLine(1)
   
    For nX := 1 To len(oMdlGrd:acols)
    	If !Empty(oMdlGrd:acols[1][4])
	    	If !Empty(aPgto)
		    	If aPgto[nX][4] <> oMdlGrd:acols[1][4]
		    		For nY := 1 To len(oMdlGrd:acols[nX])                
		    			aPgto[nX][nY] := oMdlGrd:acols[nX][nY]
		    		Next nY
		    	Endif		
	    	Else
	    		aPgto:= oMdlGrd:acols
	    	Endif
	    Endif	
    Next nX 

ElseIf lRet
	IIF(ValType(oModelFormaPag) == 'O', nValInvalid := oModelFormaPag:GetValue('L4_VALOR'),  nValInvalid := nValor )
	STFMessage("STIPayment","STOP", STR0025 + AllTrim(Str(nValInvalid,10,2))) //'Valor inv·lido. '
	STFShowMessage("STIPayment")
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Valor Inv·lido" )
EndIf

If  lRet .AND. ( ValType(oListTpPaym) <> "U" .AND. !lMobile )
	STIEnblPaymentOptions()
	oListTpPaym:SetFocus()
EndIf	

If  lRet .AND. ( cForma == "VP" )
	STIRfshVP(.F.) // exibe saldo do vale presente
EndIf

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Retorno: " + IIF(lRet,".T.",".F.") )

Return lRet


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIZeraPay
Zera todos os pagamentos da grid

@param   	lCheca , logico , Checa se tem Regra de desconto
@param   	lPermis , logico , verifica se tem permissao para alterar parcelas
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIZeraPay(lCheca, lPermis) 

Local oMdl 	:= oModel 						//Model ativo
Local oParc	:= oMdl:GetModel('PARCELAS')	//Model de parcelas
Local oPaym	:= oMdl:GetModel('APAYMENTS')	//Model de pagamentos
Local cMV_TEFPEND:= AllTrim(SuperGetMv("MV_TEFPEND",,"0"))
Local lTemTEF	:= .F.
Local lMantemCrd:= .F.
Local lZeraTEF	:= .F.
Local aFormas	:= {}
Local nFrtDesc  := SuperGetMv("MV_FRTDESC",,2) //Verifica se considera o desconto ou nao de uma importacao de orcamento - 1=Considera; 2=Desconsidera o desconto; 3=Pergunta
Local lMNeg		:= IIF(ExistFunc("STIGetMult"),STIGetMult(),.F.) //Retorna se o pagamento foi multinegociacao

Local nOpcDesc	:= STFUserProfInfo("LF_OPCDESC") // Opcao de desconto -> 1 - Prioriza a regra de descontos | 2 - Prioriza configuraÁ„o do caixa. 
Local nTotDA1	:= IIF(ExistFunc('STDGetDA1'),STDGetDA1(),0) // Total dos itens para conceder o desconto 
Local nCols		:= 0
Local lBonif	:= .F.																//ProteÁ„o para n„o deletar bonificaÁ„o
Local lRegDesc		:= SuperGetMV('MV_LJRGDES',,.F.) .AND. ExistFunc("STBFORMBF") .AND. ExistFunc("STIDSCBONF") .AND. GetAPOInfo("STFTOTALUPDATE.PRW")[4] >= Ctod("19/12/2019") //Regra de desconto
Local oTotal        := STFGetTot()      											//Recebe o Objeto totalizador

Default lCheca  := .F.
Default lPermis := .T. //Verifica permissao para zerar formas de pagamento

If STIGetPayRO()	
	
	STFMessage( ProcName(),"ALERT", STR0029)	//"Sem permiss„o para Alterar Parcelas"
	STFShowMessage( ProcName() )
Else
	If lCheca .And. GetApoInfo("LOJA120.PRW")[4] >= CTOD("11/11/2016") .And. !lPermis //Chamada pelo botao Limpa Pagto(s) - CTRL + L
		lPermis := STFProfile(41)[1] //Valida permissao de usuario para zerar pagamentos 
	EndIf

	If ExistFunc("STBGetDPgChck")
		STBGetDPgChck()
	EndIF
	
	If lPermis  //Permissao zerar pagamentos 
	 
	 	lTemTEF := STIGetCard()
		oParc:Activate()
		oPaym:Activate()
	
		/*
			Caso os fontes estejam em datas diferentes n„o afeta o 
			funcionamento anterior a esta implementaÁ„o no sistema
		*/
		If !STIAtvTefP()
			lZeraTEF := .T.
		EndIf

			If lRegDesc
				For nCols := 1 to Len(oListResPg:aItems)
					If Left(oListResPg:aItems[nCols],2) = "BF"  //oListResPg:aItems
						lBonif := .T.
					EndIf
				Next
			EndIf

		If lZeraTEF .Or. !lTemTEF .Or. (lTemTEF .And. cMV_TEFPEND == "0")	
		
			oParc:ClearData()
			oParc:InitLine()		
			
			oPaym:ClearData()
			oPaym:InitLine()
		
			If lBonif
				STBFormBf()				
			EndIf
		
			lMantemCrd := .F.
		Else
			STILmpTef(@oParc,@oPaym,lBonif)
			If oParc:Length() > 0
				lMantemCrd := .T.
			EndIf
		EndIf

		STISetCard(lMantemCrd)
		STBSetCheck()
	
		If nOpcDesc == 1 .AND. nTotDA1 > 0 .AND. ProcName(3) == 'STIPOSMAIN' 
			STIClearDisc(.T.)
		EndIf

		If ExistFunc('STBSetCart')
			STBSetCart(.T.)
		EndIf

		//Se for multinegociacao e tem acrescimo, limpa o 
		//acrescimo ao limpar as formas de pagamento
		If lMNeg .AND. STWGetIncrease() > 0
			STWAddIncrease( 0 , 0 )
			STISetMult(.F.)
		EndIf

		//Limpa NCC's selecionadas.
		STDSetNCCs("2")		
		
		//Limpa beckup da aSl4
		If ExistFunc("STBLMPaSl4")
			STBLMPaSl4()
		EndIf
		
		//Volta ao estado original da variavel que indica se houve alteraÁ„o em alguma informaÁ„o do orÁamento do tipo FI
		If ExistFunc("STISFiAltImp")
			STISFiAltImp()
		EndIf	

		If lMantemCrd			
			If lBonif
				STIAddPay("BF", Nil, 1, Nil, Nil, oTotal:GetValue("L1_BONIF") )
			EndIf
			aFormas		:= STBUpdResPg(nAjustCols,.F.)
			
    		If ValType(oListResPg) <> "U"
    		  	oListResPg:Reset()
    		  oListResPg:SetArray(aFormas)
            EndIf
            
		Else		
			STBSetRetTef(lTemTEF)	
			STBSetEnt()
		
    		If ValType(oListResPg) <> "U" 
    		  oListResPg:Reset()
				If lBonif
					STIAddPay("BF", Nil, 1, Nil, Nil, oTotal:GetValue("L1_BONIF") )
				EndIf
            EndIf
        
			STBSetParc()
			
			// Retorna o objeto do model com todos os totais definidos
			STFGetTot()
	
			If ExistFunc("STBSetIDTF")
				STBSetIDTF()	//reseta a variavel de controle dos IDs dos CARTOES
			EndIf
			
			//Limpa variaveis da condiÁ„o de pagamento da venda
			If ExistFunc("STBCDPGAtuBasket")
				STBCDPGAtuBasket(.T.)
			EndIf
		EndIf
		
		If ExistFunc("STISetVPSaldo")
			STISetVPSaldo() // define saldo do vale presente
		EndIf
		STIRfshVP(.T.)  // esconde o campo saldo do vale presente
		
		If ExistFunc("STDDelBonificacao")
			//Exclui produto comprado por bonificacao via forma de pagamento, precisa vir antes para poder atualizar o valor da cesta 
			STDDelBonificacao(,lCheca)
		EndIf	
			
		/* Limpa o desconto e acrescimo financeiro */
		If ExistFunc("STBLDsAcFin")
			STBLDsAcFin()
		EndIf		
		
		If AliasInDic("MGC") .And. ExistFunc("STDDelBrindeCesta")
			//Deleta brinde por Forma de pagamento
			STDDelBrindeCesta(lCheca)
		EndIf
	
		/*/ Verifica se Regra Desconto esta ativa e existe regra cadastrada
		 Verifica se venda teve desconto no total vindo de alguma regra cadastrada, 
		 caso positivo limpa desconto pois preciso manter a forma de pagamento. /*/
		If Len(STIGetOrc()) > 0
			//1=Considera; 2=Desconsidera o desconto; 3=Pergunta
			If nFrtDesc == 2 .Or. (nFrtDesc == 3 .AND. MsgNoYes(STR0043,STR0044))//"Deseja limpar o desconto no total da venda ?"#"AtenÁ„o"
				STIClearDisc()
			EndIf
		Else		
			If lCheca .And. !STIGetRecTit() .And. SuperGetMv("MV_LJRGDES",,.F.) .And.;
			 	STBPromPgto() .or. IIf(ExistFunc("STIDescRegVar"),STIDescRegVar(),.F.)
				STIClearDisc()  //limpas os descontos da regra de desconto varejo
			EndIf
		EndIf
		
		// Sincroniza a Cesta com a interface
		STIGridCupRefresh()
		
		// Limpa variavel  dos dados do cheque
		STWSetCkRet()

		//FunÁ„o respons·vel por limpar arrays/objetos das formas de pagamento.
		If ExistFunc("STBClearPay")
			STBClearPay()
		EndIf		
		
		//Limpa as mensagens anteriores
		STFCleanInterfaceMessage()
	Else
		STFMessage( ProcName(),"ALERT", STR0037) //#"Sem permiss„o para zerar pagamentos"	
		STFShowMessage( ProcName() )	
	EndIf
EndIf 

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGetSx5
Pesquisa as formas de pagamento na tabela SX5

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGetSx5()

Local aPayments	:= {}									//Array com todas as formas de pagamento
Local aCopyPaym	:= {}									//Array com todas as formas de pagamento
Local nI			:= 0									//Variavel de Loop
Local oDataAe		:= oPay:oPayX5:GetAllData()			//Recebe todos os models
Local oModDt		:= oDataAe:GetModel("GridStr")		//Recebe o model GridStr

For nI := 1 To oModDt:Length()
	oModDt:GoLine(nI)
	If !(AllTrim(oModDt:GetValue("X5_TYPE")) $ 'BOL|CR|DC|BF')
		Aadd(aPayments, AllTrim(Str(nI)) + ' - ' + oModDt:GetValue("X5_DESC"))
		Aadd(aCopyPaym, {AllTrim(oModDt:GetValue("X5_TYPE")),AllTrim(Str(nI)) + ' - ' + AllTrim(oModDt:GetValue("X5_DESC")),oModDt:GetValue("X5_DESC")})
	EndIf
	
Next nI

/* Inclui nos arrays o tipo condicao de pagamento */
Aadd(aPayments, AllTrim(Str(nI)) + STR0010) //' - Condicao de pagamento'
Aadd(aCopyPaym, {'CP',AllTrim(Str(nI++)) + STR0010, STR0010})

/* Inclui nos arrays o tipo Multi-NegociaÁ„o */
Aadd(aPayments, AllTrim(Str(nI)) + ' - ' + STR0024) //'Multi NegociaÁ„o'
Aadd(aCopyPaym, {'MN',AllTrim(Str(nI++)) + ' - ' + STR0024, STR0024}) //'Multi NegociaÁ„o'

/* Inclui no arrays o tipo NCC com BarCode */
If SuperGetMv("MV_LJNCCBC", , "0" ) <> "0"
	Aadd(aPayments, AllTrim(Str(nI)) + ' - ' + STR0026 ) //"Nota de CrÈdito CÛd. Barras"
	Aadd(aCopyPaym, {'NB',AllTrim(Str(nI++)) + ' - ' + STR0026 , STR0026 }) //"Nota de CrÈdito CÛd. Barras"
EndIf

Return { aPayments, aCopyPaym }

//-----------------------------------------------------------------
/*/{Protheus.doc} STIConfPay
Confirmacao dos pagamentos

@param   	lShowRgIt		Chama registro de item ao finalizar
@author  	Vendas & CRM
@version 	P12
@since   	06/02/2013
@return  	
@obs     
@sample
/*/
//-----------------------------------------------------------------
Function STIConfPay( lShowRgIt, cKey )
Local oMdl 			:= Nil													//Recupera o model ativo
Local oMdlGrd		:= Nil													//Seta o model do grid
Local oMdlPaym		:= Nil													//Seta o model do pagamento
Local lRet			:= .F.													//Vari·vel de retorno
Local lMobile 		:= STFGetCfg("lMobile", .F.)							//Smart Client Mobile
Local cMV_FORMCRD	:= SuperGetMV("MV_FORMCRD",,"CH/FI")					//Forma de Pagamento para CRD
Local aCRD			:= {}													//Traz informaÁıes do cart„o utilizado para CRD

Default lShowRgIt := .T.
Default cKey := "Buffer > Desconhecido"

SetKey(16, Nil)

lMobile := ValType(lMobile) == "L" .AND. lMobile

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "ConfirmaÁ„o dos pagamentos" )  //Gera LOG
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Acionamento via : " + cKey )  //Gera LOG

oMdl 		:= oModel													
oMdlGrd		:= oMdl:GetModel("PARCELAS")
oMdlPaym	:= oMdl:GetModel("APAYMENTS")

If STBCalcSald("1") == 0

	If STIGetTotal() > 0

		/* Solicita a selecao da Adm. Financeira p/ Condicao de Pagamento cujo Forma È do tipo "FI" */
		STIAdmCdPg(aCopyPaym, oListTpPaym, oMdl)

		lRet := .T.
		
		//An·lise para IntegraÁ„o SIGACRD
		If ExistFunc("STBGetCrdIdent") .AND. ExistFunc("STWAvalCRDIntegration") .AND.;
						 AllTrim(oMdlGrd:GetValue("L4_FORMA")) $ cMV_FORMCRD .AND. CrdXInt(.F.,.F.)

			//Primeiro passo: Vejo se o cart„o foi habilitado. Se n„o, n„o prossigo e volto para a forma de pagamento.
			aCrd := STBGetCrdIdent()

			If Len(aCRD) >= 2 .AND. Empty(aCrd[2])
				lRet := .F.
				STFMessage(ProcName(),"POPUP",STR0045) //"A seleÁ„o do Cliente Identificado com CPF/CNPJ È obrigatÛria antes da venda. Escolha outra forma de pagamento."
				STFShowMessage(ProcName())
			EndIf
			
			If lRet
				lRet := STWAvalCRDIntegration(STBRPayaCols(oMdlGrd))		//Se .F., voltar para a condiÁ„o de pagamento.
			EndIf
			
			If !lRet .AND. Len(oListResPg:aItems) > 0	//Se retornar false, e se estiver preenchido a forma de pagamento, eu limpo a forma.
				STIZeraPay(.T.)
			EndIf
		EndIf
		
		If lRet
			STISetPayImp(.F.)
			lRet := STBConfPay(oMdlGrd, aCopyPaym, oMdlPaym)
		EndIf
		
		If lRet
			nUsedCards := 0
			STIGridCupRefresh()
			
			If lShowRgIt 
				STIRegItemInterface()
			EndIf
		EndIf
			
	Else
		STFMessage( ProcName(0),"STOP", STR0036) //"Informar forma de pagamento" 
		STFShowMessage(ProcName(0))
		lRet := .F.
	EndIf
Else
	If !lMobile .AND. ValType(oListTpPaym) == "O"
		oListTpPaym:SetFocus()
	EndIf
	STFMessage(ProcName(),"STOP",STR0023) //"Saldo da venda maior que o valor pago!"
	STFShowMessage(ProcName())
EndIf

If lRet
	// Limpa variavel de verificaÁ„o de regra de desconto por item
	If ExistFunc("STBLimpRegra")
		STBLimpRegra(.F.)
	EndIf
	
	If !lRet
		SetKey(16, {|| STIConfPay() })
	EndIf
EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} STIGetTotal
Retorna o saldo dos pagamentos

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	06/02/2013
@return  	nTotal, numerico, total da venda
/*/
//-----------------------------------------------------------------------------
Function STIGetTotal()

Local oMdl		:= oModel 	//Recupera o model ativo
Local oMdlGrd	:= Nil		//Seta o model do grid
Local nI		:= 1		//Variavel de Loop
Local nTotal	:= 0		//Soma os totais
Local nPosMdl	:= 0		//Guarda a Posicao do model para restaurar ao final

If ValType(oMdl) == "O"
	
	oMdlGrd	:= oMdl:GetModel("PARCELAS")

	nPosMdl := oMdlGrd:nLine
	
	For nI := 1 To oMdlGrd:Length()
		oMdlGrd:GoLine(nI)
		nTotal += oMdlGrd:GetValue( "L4_VALOR" )
	Next nI
	
	oMdlGrd:GoLine(nPosMdl)

EndIf

Return nTotal

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIUpdBask
Atualiza a cesta com as informacoes de pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	19/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIUpdBask()

Local oMdl 		:= oModel								//Recupera o model ativo
Local oMdlGrd		:= oMdl:GetModel("APAYMENTS")       // Model de pagamentos
Local aFieldsGrd	:= oMdlGrd:GetStruct():GetFields()	//Estrutura do model
Local cFilL4		:= STDGPBasket("SL1","L1_FILIAL")	//Filial do OrÁamento
Local cNumL4		:= STDGPBasket("SL1","L1_NUM")		//N˙mero do OrÁamento
Local nX			:= 0								//Variavel de loop
Local nJ			:= 0								//Variavel de loop
Local lRMS			:= SuperGetMv("MV_LJRMS",,.F.)		//Integracao com CRM da RMS
Local oModelParcelas := oMdl:GetModel("PARCELAS")    	//Model do resumo de pagamento
Local nI            := 1								//Variavel de loop
Local nCheques		:= 0								//Incremento de pagamento em cheques			
Local aIdPgtoMfe	:= IIF(ExistFunc("STWGetIdPgto"),STWGetIdPgto(), {} )				
Local aSL4bkp		:= {} 								//Armazena Backup da ASL4 importada 
Local lAcrRet		:= SuperGetMV("MV_ACRSRET",,.F.) 	//parametro que determina se  considera o acrescimo financeiro da retaguarda 
Local nPosACRS		:= 0 								//PosiÁ„o do campo L4_ACRSFIN no array
Local cNsuTef       := "" 								//Nsu Tef para controle de transacao
Local aAcresFin		:= {0,0,} 							// Array com os valores de acrescimo financeiro

//Gravacao de campos da SL1
STIAtlzSl1(oMdl:GetModel("PARCELAS"))

//Restaura backup da Sl4 importada
If lAcrRet
	aSL4bkp := STBGetaSL4()
	If Len(aSL4Bkp) >= 1
		nPosACRS :=  AScan( aSL4bkp[1] , { |x| x[1] == "L4_ACRSFIN" } )
	EndIf
EndIf


For nX := 1 To oMdlGrd:Length()
	
	If nX > 1
		STDPBAddLine("SL4")
	EndIf
	
	oMdlGrd:GoLine(nX)

	STDSPBasket("SL4", "L4_FILIAL"	,cFilL4					, nX )
	STDSPBasket("SL4", "L4_NUM"		,cNumL4					, nX )
	
	If lMFE .And. Len(aIdPgtoMfe) > 0 .And. AllTrim(oMdlGrd:GetValue("L4_FORMA")) $ "CC|CD"
		//Tratamento para posicionar no Id MF-e correto para todas as parcelas da transaÁ„o Tef
        If nX > 1 .And. !Empty(cNsuTef) .And. cNsuTef <> oMdlGrd:GetValue('L4_NSUTEF')
            nI++
        EndIf
	
		STDSPBasket("SL4", "L4_IDPGVFP"		,aIdPgtoMfe[nI][1]	, nX )
		cNsuTef := oMdlGrd:GetValue('L4_NSUTEF')
	EndIf	
	
	//Serie do PDV
	STDSPBasket("SL4", "L4_SERPDV" ,STFGetStat("SERPDV")		, nX )
	
	//Grava o valor do acrescimo financeiro do campo L4_ACRSFIN no model
	If ExistFunc("STBGetAcresFin")
		aAcresFin := STBGetAcresFin()
	EndIf	

	If lAcrRet .AND. Len(aSL4bkp) >= nX .AND. nPosACRS > 0 
		oMdlGrd:LoadValue( "L4_ACRSFIN"	,aSL4bkp[nX][nPosACRS][2]) 	
	ElseIf lAcrRet .AND. Len(aAcresFin) > 1 .AND. aAcresFin[1] > 0
		oMdlGrd:LoadValue( "L4_ACRSFIN"	,aAcresFin[1] )
	EndIf
		
	For nJ := 1 To Len(aFieldsGrd)
		If !(aFieldsGrd[nJ][3] $ 'L4_FILIAL|L4_NUM|L4_IDPGVFP') .AND. !aFieldsGrd[nJ][14]
			STDSPBasket("SL4", aFieldsGrd[nJ][3], oMdlGrd:GetValue(aFieldsGrd[nJ][3]), nX)
		EndIf
	Next nJ

	// tratamento de troco:
	If IsMoney(oMdlGrd:GetValue('L4_FORMA'))
		If ExistFunc("STBGrvTroco")
			STBGrvTroco(oMdlGrd,nX)
		Else
			LjGrvLog( "L4_NUM: " + cNumL4, "GravaÁ„o de troco" ,"Atualizar o fonte STBPayment.prw para uma data superior a 15/02/2016." )  //Gera LOG
			STDSPBasket("SL4","L4_VALOR",oMdlGrd:GetValue("L4_VALOR") - STBGetTroco(),nX) 
		EndIf
	EndIf 

	If lRMS 
		Do Case 
			Case (AllTrim(oMdlGrd:GetValue("L4_FORMA")) == "CH") .AND. (oMdlGrd:GetValue("L4_CODCRM") > 0)
				aAdd(aCheckRms,STBRmsCheck())
			Case (AllTrim(oMdlGrd:GetValue("L4_FORMA")) == "CO") .AND. (oMdlGrd:GetValue("L4_CODCRM") > 0)
				aAdd(aConvRms,STBRmsConv())
		EndCase		 
	EndIf
	
	If (AllTrim(oMdlGrd:GetValue("L4_FORMA")) == "CH")
		nCheques += oMdlGrd:GetValue('L4_VALOR')
		STDSPBasket("SL1", "L1_CHEQUES", nCheques )
	EndiF	
	
Next nX

Return Nil

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIAtlzSl1
Grava os campos da SL1 referente a pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	02/04/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIAtlzSl1(oModel)

Local nI 			:= 0 //Variavel de loop
Local nParcels		:= 0 //Qtd de parcelas
Local nValEnt		:= 0 // Valor de Entrada
Local lHabTroco 	:= SuperGetMV("MV_LJTROCO",,.F.) 	//Habilita troco
Local lMvLjTrDin	:= SuperGetMV("MV_LJTRDIN", , 0 ) == 0	// Determina se utiliza troco para diferentes formas de pagamento
Local nVlrCredito	:= 0 //Valor total de credito da venda. (NCC)
Local oTotal		:= Nil

//Limpa conteudo para evitar duplicidade caso retorne para a venda por erro apÛs clicar em Finalizar Venda (exemplo: NFC-e entrando em contingÍncia)
STDSPBasket("SL1", "L1_VLRDEBI"	, CriaVar("L1_VLRDEBI") )
STDSPBasket("SL1", "L1_CARTAO"	, CriaVar("L1_CARTAO")	)

For nI := 1 To oModel:Length()
	oModel:GoLine(nI)
	Do Case
		Case IsMoney(AllTrim(oModel:GetValue('L4_FORMA'))) 
			STDSPBasket("SL1", "L1_DINHEIR", oModel:GetValue('L4_VALOR') - STBGetTroco() )
		Case AllTrim(oModel:GetValue('L4_FORMA')) == 'CH'
			STDSPBasket("SL1", "L1_CHEQUES", oModel:GetValue('L4_VALOR') )//Valores de Cheque ja foram acumulados na rotina STIUpdBask
		Case AllTrim(oModel:GetValue('L4_FORMA')) $ 'CC|CD'
			IF !STBIsRecovered() 
					IF AllTrim(oModel:GetValue('L4_FORMA')) == 'CC'  
						STDSPBasket("SL1", "L1_CARTAO", STDGPBasket( "SL1" , "L1_CARTAO" ) + oModel:GetValue('L4_VALOR') )
					Else
						STDSPBasket("SL1", "L1_VLRDEBI", STDGPBasket( "SL1" , "L1_VLRDEBI" ) + oModel:GetValue('L4_VALOR') )
					EndIf
			Else 
					IF AllTrim(oModel:GetValue('L4_FORMA')) == 'CC'  
						STDSPBasket("SL1", "L1_CARTAO", oModel:GetValue('L4_VALOR') )
					Else
						STDSPBasket("SL1", "L1_VLRDEBI", oModel:GetValue('L4_VALOR') )
					EndIf
			EndIF		
			STDSPBasket("SL1", "L1_VENDTEF", 'S' )
			STDSPBasket("SL1", "L1_DATATEF", oModel:GetValue('L4_DATATEF') )
			STDSPBasket("SL1", "L1_HORATEF", oModel:GetValue('L4_HORATEF') )
			STDSPBasket("SL1", "L1_DOCTEF",  oModel:GetValue('L4_DOCTEF') )
			STDSPBasket("SL1", "L1_AUTORIZ", oModel:GetValue('L4_AUTORIZ') )
			STDSPBasket("SL1", "L1_INSTITU", oModel:GetValue('L4_INSTITU') )
			STDSPBasket("SL1", "L1_NSUTEF", oModel:GetValue('L4_NSUTEF') )
			STDSPBasket("SL1", "L1_TIPCART", oModel:GetValue('L4_TIPCART') )
			STDSPBasket("SL1", "L1_PARCTEF", oModel:GetValue('L4_PARCTEF') )
		Case AllTrim(oModel:GetValue('L4_FORMA')) == 'CO'
			STDSPBasket("SL1", "L1_CONVENI", STDGPBasket( "SL1" , "L1_CONVENI" ) + oModel:GetValue('L4_VALOR') )
		Case AllTrim(oModel:GetValue('L4_FORMA')) == 'VA'
			STDSPBasket("SL1", "L1_VALES",  STDGPBasket( "SL1" , "L1_VALES" ) + oModel:GetValue('L4_VALOR') )
		Case AllTrim(oModel:GetValue('L4_FORMA')) == 'FI'
			STDSPBasket("SL1", "L1_FINANC", STDGPBasket( "SL1" , "L1_FINANC" ) + oModel:GetValue('L4_VALOR') )
		Case AllTrim(oModel:GetValue('L4_FORMA')) == 'CR'
			STDSPBasket("SL1", "L1_CREDITO", oModel:GetValue('L4_VALOR') ) //Valores de NCC ja estao acumulados
		Case AllTrim(oModel:GetValue('L4_FORMA')) <> 'CR'
			STDSPBasket("SL1", "L1_OUTROS", STDGPBasket( "SL1" , "L1_OUTROS" ) + oModel:GetValue('L4_VALOR') )
	EndCase
	nParcels += oModel:GetValue('L4_PARC')
	STDSPBasket("SL1", "L1_PARCELA", nParcels )
	STDSPBasket("SL1", "L1_FORMPG", AllTrim(oModel:GetValue('L4_FORMA')) )
	
	// Grava o valor do troco
	If lHabTroco .And. oModel:GetValue('L4_TROCO') > 0 .And. ((AllTrim(oModel:GetValue('L4_FORMA')) $ "CH|CD|CC") .Or. (lMvLjTrDin .And. IsMoney(AllTrim(oModel:GetValue('L4_FORMA')))))
		STDSPBasket("SL1", "L1_TROCO1", oModel:GetValue('L4_TROCO'))
	EndIf
	
	nValEnt := STBGetEnt() - STBGetTroco()
	If nValEnt < 0	// O valor minimo nao pode ser negativo
		nValEnt := 0
	EndIf
	STDSPBasket("SL1", "L1_ENTRADA", nValEnt )
Next nI

//Se existir NCC e o seu valor for maior que o total da venda
//deve ser abatido o troco (condiÁ„o esta somente quando o parametro MV_LJCPNCC estiver igual a 4
//obrigatoriamente passando pela funÁ„o STISNCCPayment(). 
nVlrCredito := STDGPBasket("SL1", "L1_CREDITO")
If nVlrCredito > 0
	oTotal := STFGetTot()
	If nVlrCredito >= oTotal:GetValue("L1_VLRTOT")
		STDSPBasket("SL1", "L1_CREDITO", nVlrCredito - STBGetTroco()) 
		If lHabTroco .And. lMvLjTrDin .And. STBGetTroco() > 0
			STDSPBasket("SL1", "L1_TROCO1", STBGetTroco() )
		EndIf
	EndIf
EndIf

STBSetEnt()

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGetLstB
Retorna o objeto ListBox

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/04/2013
@return	oListTpPaym  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGetLstB()
Return oListTpPaym

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPayCancel
Retornar a tela das formas de pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	15/04/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPayCancel()

Local lMobile := STFGetCfg("lMobile", .F.)		//Smart Client Mobile

lMobile := ValType(lMobile) == "L" .AND. lMobile

If STIGetPayRO()
	STFMessage( ProcName(),"ALERT", STR0029)	//"Sem permiss„o para Alterar Parcelas"
	STFShowMessage( ProcName() )
Else
	/*/ Se essa funcao nao for chamada por um componente de tela,
	o objeto nao fica instanciado, por isso a protecao /*/
	If ValType(oPnlAdconal) == "O"
		oPnlAdconal:Hide()
	EndIf

    STIEnblPaymentOptions()

	If !lMobile
		oListTpPaym:SetFocus()
		If GetFocus() <> oListTpPaym:HWND
            oListTpPaym:SetFocus()		  
		Endif
	EndIf
		
	If ExistFunc("STFRestVlr")
		STFRestVlr()    // FunÁ„o presente no Fonte STFTotalUpdate, Restura os valores antes da seleÁ„o da forma de pagamento
	EndIf

EndIf

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIEnblPaymentOptions
Habilita o listbox e botoes Limpar e Finalizar com as opcoes de pagamento.
	
@author  	Vendas & CRM
@version 	P12
@since   	08/05/2013

/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIEnblPaymentOptions()
lListWhen 		:= .T.
lDisableBtn 	:= .T.

If ValType(oPPanel) == "O"
	oPPanel:bWhen := {||.T.}
ElseIf ValType(oListTpPaym) == "O"
	If STBIsImpOrc() .And.  STFGetCfg("lChangePay", .F.)
		oListTpPaym:bWhen := {||.F.}
	Else
		oListTpPaym:bWhen := {||.T.}
	EndIf
EndIf
	
Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STISetMdlPay
Retorna o model do resumo do pagamento
	
@author  	Vendas & CRM
@version 	P12
@since   	08/05/2013

/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetMdlPay()
Return oModel
  

//-------------------------------------------------------------------
/*/{Protheus.doc} STIUsedCard
Seta que um cartao foi usado na venda
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIUsedCard()

nUsedCards += 1

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STISetUsedCard
Faz um reset do numero de cartoes no fim da venda
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetUsedCard()

nUsedCards := 0

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetPan
Retorna o objeto oPanBkpPay que È uma copia do oPanPayment
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	oPanBkpPay
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetPan()
Return oPanBkpPay

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetBlCod
Retorna um bloco de codigo para criacao de painel de dados do cheque
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	bDataCheck
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetBlCod()
Return bDataCheck


//-------------------------------------------------------------------
/*/{Protheus.doc} STISetPayImp
Set o lPayImport
Variavel controla para nao passar duas vezes no pagamento quando e
importacao de orcamento
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetPayImp(lImp)
lPayImport := lImp
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetPayImp
Retorna o lPayImport
Variavel controla para nao passar duas vezes no pagamento quando e
importacao de orcamento
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	lPayImport
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetPayImp()
Return lPayImport

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetaCallADM
Seta o array de cartıes a serem chamados para ser informado Adm. Fin.
@param   	aSet			Array com as formas a ser chamado Adm. Fin.
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	lPayImport
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetaCallADM( aSet )
aCallADM := aSet
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetaCallADM
Retorna o aCallADM
@param   
@author  	Varejo
@version 	P11.8
@since   	29/07/2013
@return  	lPayImport
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetaCallADM()
Return(aCallADM)

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetChRms
Retorna o array STIGetChRms
@param   
@author  	Varejo
@version 	P11.8
@since   	25/08/2014
@return	aCheckRms  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetChRms()
Return {aCheckRms,aConvRms}

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetChRms
Limpa o array
@param   
@author  	Varejo
@version 	P11.8
@since   	25/08/2014
@return	aCheckRms  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetChRms()
aCheckRms := {}
aConvRms := {}
Return .T.


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*{Protheus.doc} STIInsArrTax
Se houver taxa administrativa no SAE, descontar a taxa tambÈm na doaÁ„o
Instituto Arredondar

@param   	
@author  	Varejo
@version 	P118
@since   	04/11/2014
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIInsArrTax(cForma)

Local oMdl 			:= oModel  						//Recupera o model ativo
Local oMdlGrd		:= oMdl:GetModel("PARCELAS")	//Seta o model do grid

Default cForma		:= ""

STDTaxDiscInsArr(cForma,oMdlGrd:GetValue("L4_ADMINIS"))
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STIRfshVP
Atualiza o campo "Saldo Vale Presente" para exibir ou n„o o saldo
@param   	lUpdVP Para zerar ou n„o o saldo
@author  	Varejo
@version 	P11.8
@since   	09/01/2015
@return	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIRfshVP(lUpdVP)
	
If Valtype(oLblRestVP) == "O"
	If lUpdVP
		oLblRestVP:SetText("")
		oLblValVPRest:SetText("")
	Else
		oLblRestVP:SetText(STR0027)
		oLblValVPRest:SetText(Str(STIGetVPSaldo(),10,2))
	EndIf
EndIf
	
Return Nil


/*/{Protheus.doc} STISetPayRO
Atribui um valor a variavel est·tica nPayROnly 
@param		nAuxROnly - valor que ser· atribuido a variavel estatica
@author  	Varejo
@version 	P11.8
@since   	09/05/2015
@return  	Nil
@obs		[0] reseta a permiss„o [-1] com escrita [1] somente leitura
@sample
/*/
//-------------------------------------------------------------------
Function STISetPayRO(nAuxROnly)

Default nAuxROnly := 0

nPayROnly := nAuxROnly

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetPayRO
Indica se os campos de pagamento ser„o Somente Leitura. Pode retornar uma variavel do tipo N ou L
@param		cVarType - indica se o retorno ser· NumÈrico ou LÛgico
@author  	Varejo
@version 	P11.8
@since   	09/05/2015
@return  	xRet - retorna um valor LÛgico ou NumÈrico
@obs		O retorno numÈrico È util para verificar se a permiss„o j· foi verificada     
@sample		STIGetPayRO() / STIGetPayRo("N")
/*/
//-------------------------------------------------------------------
Function STIGetPayRO(cVarType)

Local xRet := .F.

Default cVarType := "L"
		
If cVarType == "L"
		
	If nPayROnly > 0
		xRet := .T.		//Somente Leitura
	Else
		 xRet := .F.	//Escrita
	EndIf

ElseIf cVarType == "N"

	xRet := nPayROnly
	
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPayMdlc
Funcao para limpar o model de pagamentos.

@author  	Varejo
@version 	P12
@since   	12/07/2016
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STIPayMdlc()
If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STILmpTef
Funcao para limpar o model de pagamentos quando TEF n„o pode apagar

@author  	julio.nery
@version 	P12
@since   	01/02/2017
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STILmpTef(oParc,oPaym,lBonif)
Local nX, nI	:= 0
Local lRet		:= .T.
Local aStruct	:= {}
Local aFormPg	:= {}

Default oParc	:= oModel:GetModel('PARCELAS')	//Model de parcelas
Default oPaym	:= oModel:GetModel('APAYMENTS')	//Model de pagamentos
Default lBonif  := .F.							//Se for bonificaÁ„o

If lBonif
	STBFormBf()				
EndIf

aStruct := oParc:GetStruct():aFields
For nX := 1 to oParc:Length()
	oParc:GoLine(nX)
	If AllTrim(oParc:GetValue('L4_FORMA')) $ "CC|CD"
		Aadd(aFormPg , {})
		aFormPg[Len(aFormPg)] := Array(Len(aStruct),2)
		For nI := 1 To Len(aStruct)
			aFormPg[Len(aFormPg)][nI][1] := AllTrim(aStruct[nI][3])
			aFormPg[Len(aFormPg)][nI][2] := oParc:GetValue(aStruct[nI][3])
		Next nI
	EndIf
Next nX

oParc:ClearData()
oPaym:ClearData()
oParc:InitLine()
oPaym:InitLine()

For nX := 1 To Len(aFormPg)
	If nX > 1
		oParc:AddLine(.T.)
		oPaym:AddLine(.T.)
	EndIf
	
	For nI:= 1 to Len(aFormPg[nX])
		oParc:LoadValue(aFormPg[nX][nI][1], aFormPg[nX][nI][2])
		oPaym:LoadValue(aFormPg[nX][nI][1], aFormPg[nX][nI][2])
	Next nI
Next nX

STIBlqTlTef()
STIMBlPTef()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIBlqTlTef
Funcao para bloquear os botes ao finalizar a venda TEF
que possua o param MV_TEFPEND impedindo apagar a forma

@author  	julio.nery
@version 	P12
@since   	03/02/2017
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STIBlqTlTef()
Local lRet			:= .T.
Local cMV_TEFPEND	:= AllTrim(SuperGetMv("MV_TEFPEND",,"0"))

If STIAtvTefP() .And. cMV_TEFPEND <> "0"
	STIBtnDeActivate()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIBlqMnTef
FunÁ„o para verificaÁ„o se tem TEF e se permite excluir a venda
j· efetuada ou tambÈm se prossegue com acesso aos menus (STBSalesOperations)

@author  	julio.nery
@version 	P12
@since   	03/02/2017
@return  	lRet, logico, pode excluir (S) ou (N)?
/*/
//-------------------------------------------------------------------
Function STIBlqMnTef()
Local lRet			:= .T.
Local cMV_TEFPEND	:= AllTrim(SuperGetMv("MV_TEFPEND",,"0"))

If STIAtvTefP() .And. cMV_TEFPEND <> "0" .And. STIGetCard()
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIMBlPTef
Funcao para emitir mensagem sobre a utilizaÁ„o do parametro
MV_TEFPEND, no momento que o sistema impede o prosseguimento
ou acesso a outras rotinas.

@author  	julio.nery
@version 	P12
@since   	03/02/2017
@return  	cMsg, caracter, mensagem emitida
/*/
//-------------------------------------------------------------------
Function STIMBlPTef(cType)
Local cMsg			:= ""
Local cRotina		:= ProcName()
Local cMV_TEFPEND	:= AllTrim(SuperGetMv("MV_TEFPEND",,"0"))

Default cType := "POPUP"

cMsg	:=	STR0038 + cMV_TEFPEND +; //#"O par‚metro MV_TEFPEND est· configurado com " 
			STR0039 + CHR(13) +; //#" conforme documentaÁ„o n„o ser· permitido limpar todas as formas/acesso a outras telas/incluir condiÁ„o negociada ou multinegociaÁ„o pois existe vendas do tipo TEF (CC/CD) aprovadas! " 
			STR0040 //#"Por favor selecione: uma nova forma de pagamento/cancele ou encerre a venda / reconfigurar o par‚metro MV_TEFPEND."

STFMessage(cRotina,cType,cMsg)
STFShowMessage(cRotina)

Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} STIVerCTef
Valida se pode limpar o TEF

@param		lEmiteMsg , lÛgico , emite mensagem de explicaÁ„o	
@author  	julio.nery
@version 	P12
@since   	08/02/2017
@return  	lRet, logico, se continua ou n„o
/*/
//-------------------------------------------------------------------
Function STIVerCTef(lEmiteMsg)
Local lRet	:= .T.

Default lEmiteMsg	:= .T.

If STIAtvTefP() .And. !STIBlqMnTef()
	lEmiteMsg := lEmiteMsg .And. !IsInCallStack("STIRInPay")
	
	If lEmiteMsg
		STIMBlPTef()
	EndIf
	
	lRet := .F.	
	STIPayCancel()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIAtvTefP
ValidaÁ„o para data compativel de todos os fontes para que o
par‚metro MV_TEFPEND possa ser usado 

@author  	julio.nery
@version 	P12
@since   	08/02/2017
@return  	lRet, logico, se continua ou n„o
/*/
//-------------------------------------------------------------------
Function STIAtvTefP()
Local lRet	:= .T.
Local dDataF:= Ctod("22/02/2017")

If lSTIAtvTefP == NIL
	lRet := GetApoInfo("STIDATACHECK.PRW")[4]	>= dDataF .And.;
			GetApoInfo("STBPAYCARD.PRW")[4]		>= dDataF .And.;
			GetApoInfo(Upper("STBSalesOperations.PRW"))[4]	>= dDataF .And.;
			GetApoInfo("STICANCELSALE.PRW")[4]	>= dDataF .And.;
			GetApoInfo(Upper("STWPayCdPg.PRW"))[4]	>= dDataF
	
	lSTIAtvTefP := lRet
EndIf

lRet := lSTIAtvTefP

If !lRet
	LjGrvLog("STIAtvTefP", "Para ativaÁ„o do MV_TEFPEND atualize os seguintes fontes com data" +;
		" igual ou superior a 21/02/2017 : STIPayment , STIDataCheck , STBPayCard, STBSalesOperations ," +;
		" STICancelSale e STWPayCdPg")	
EndIf

Return lRet
