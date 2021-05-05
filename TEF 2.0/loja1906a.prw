#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1906A.CH"
#DEFINE ENTER	   	Chr(13)+Chr(10)
#DEFINE Desbloqueia		.F.

Static oCfgTef   	:= Nil
Static lUsePayHub 	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()
Static cTermTefPH 	:= "" //Código do terminal TEF Selecionado na Consulta Padrão

Function LOJA1906A ; Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCCfgTef         ºAutor  ³VENDAS CRM  º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as configuracoes de TEF disponiveis para a aplica-  º±± 
±±º          ³-cao.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class LJCCfgTef

	Data lAtivo					// Se configuracao esta ativa
	Data oSitef					// Objeto de configuracao Sitef
	Data oDiscado 				// Objeto de configuracao Discado
	Data oPayGo					// Objeto de configuracao Pay Go
	Data oDirecao				// Objeto de configuracao Direcao
	Data cCodigo				// Codigo de PDV (estacao)
	Data cMenssagem				// Menssagem ao usuario
 	Data oFunc					// Objeto de Funcao
	Data oPaymentHub			// Objeto de configuracao Payment Hub
		 
	Method New()
	Method Show()
	Method Carregar()
	Method Salvar()
    
	// Method's Internos
	Method PayGoHb()
	Method SiTefHb()
	Method DiscadoHb()
	Method DirecaoHb()
	Method PayHubHb()

	Method SiTefVl()
	Method PayGoVl()
 	Method DiscadoVl()
 	Method DirecaoVl()
	Method TefVl()
	Method PayHubVl()
	
	Method GetDirectory()
	Method GetAppPath()  
	Method ValSitefPbm()

EndClass                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³New          ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCCfgTef  

	Self:lAtivo		:= .F.
	Self:cCodigo	:= Space(200)
	Self:oSitef 	:= LJCCfgTefSitef():New()
	Self:oDiscado 	:= LJCCfgTefDiscado():New() 
	Self:oPayGo		:= LJCCfgTefPayGo():New()
	Self:oDirecao	:= LJCCfgTefDirecao():New()
	Self:oFunc		:= LJCFuncoes():Funcoes()
	
	If lUsePayHub
		Self:oPaymentHub:= LJCCfgTefPaymentHub():New()
	EndIf

Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Carregar     ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as configuracoes de TEF disponiveis.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Carrega as configuracoes de TEF disponiveis.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Carregar(cCodigo, lMensagem) Class LJCCfgTef
	
	Local lRet 			:= .F.					//Retorno do metodo
	Local aAreaAtual 	:= GetArea()			//Guarda a area atual             
	Local aLTT			:= Array(2)
	DEFAULT lMensagem  := .T.

	Self:cCodigo := cCodigo
	
	DbSelectArea("MDG")
	
	DbSetOrder(1) //MDG_FILIAL+MDG_CODEST
	
	If DbSeek(xFilial("MDG") + cCodigo)    
			
		Self:lAtivo := Iif(MDG->MDG_TEFATV == "1",.T.,.F.)

		If ExistFunc("STGetLTT")
			aLTT := STGetLTT()
			If Self:lAtivo .And. !IsInCallStack("LOJA121") .And. !aLTT[1]
				STFMessage("TEF", "STOPPOPUP", aLTT[2]) 
				STFShowMessage( "TEF")	
			EndIf 
		EndIf 

	    lRet := Self:oSitef:Carregar("MDG")
	    lRet := Self:oDiscado:Carregar("MDG") 
	    lRet := Self:oPayGo:Carregar("MDG") 
	    lRet := Self:oDirecao:Carregar("MDG")
		If lUsePayHub
			lRet := Self:oPaymentHub:Carregar("MDG")
		EndIf
			    
	    If !lRet  
			STFMessage("TEF", "ALERT", STR0001) //"Não foi possível carregar as configuração do SITEF, TEF Discado(GP) e TEF Discado(PayGo/Direcao)."
			STFShowMessage( "TEF")
	    EndIf
	Else    
		If lMensagem
			STFMessage("TEF", "ALERT",STR0002 + ": " + cCodigo)//"Não existe configuração do TEF para a estação: " + cCodigo 
			STFShowMessage( "TEF") 
		EndIf
	EndIf
	
	RestArea(aAreaAtual)

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Salvar       ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva as configuracoes de TEF disponiveis.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Salvar() Class LJCCfgTef
	
	Local lRet 			:= .F.					//Retorno do metodo 
    Local aAreaAtual 	:= GetArea()			//Guarda a area atual 
    Local aAreaSLG		:= SLG->(GetArea())     //WorkArea do Cadastro de estação
    Local nVias			:= 0					//Numero de Vias
           
	If !Empty(Self:cCodigo)
	    
		DbSelectArea("MDG")
		
		DbSetOrder(1) //MDG_FILIAL+MDG_CODEST
		
		lInc := DbSeek( xFilial("MDG") + Self:cCodigo)
		
		RecLock("MDG", !lInc) 
		
		REPLACE MDG->MDG_FILIAL	WITH xFilial("MDG")
	    REPLACE MDG->MDG_CODEST	WITH Self:cCodigo
	    REPLACE MDG->MDG_TEFATV	WITH IIf(Self:lAtivo,"1","2")
	    
	    lRet := Self:oSitef:Salvar("MDG")
   	    lRet := Self:oDiscado:Salvar("MDG") 
	    lRet := Self:oPayGo:Salvar("MDG") 
	    lRet := Self:oDirecao:Salvar("MDG")	
		If lUsePayHub
			lRet := Self:oPaymentHub:Salvar("MDG")
		EndIf
		
		MsUnLock() 
		
		If ( Self:oDiscado:lGPCCCD .OR. Self:oDiscado:lGPCheque .OR. ; 
				Self:oDiscado:lTECBANCCCD .OR. Self:oDiscado:lTECBANCheque .OR. ;
				Self:oDiscado:lHIPERCDCCCD	) .OR. ;
			Self:oPayGo:lCCCD	.OR. Self:oPayGo:lCheque  .OR.;
			Self:oDirecao:lCCCD		//Verifica ativo Discado/Paygo ou Direcao
			
			Do Case
				Case Self:oDiscado:lGPCCCD .OR. Self:oDiscado:lGPCheque
					nVias := Self:oDiscado:nVias
				Case Self:oDiscado:lTECBANCCCD .OR. Self:oDiscado:lTECBANCheque 
					nVias := Self:oDiscado:nTECVias
				Case Self:oDiscado:lHIPERCDCCCD
					nVias := Self:oDiscado:nHIPERVIas
				Case Self:oPayGo:lCCCD	.OR. Self:oPayGo:lCheque 
					nVias :=  Self:oPayGo:nVias
				Case Self:oDirecao:lCCCD
					nvias := Self:oDirecao:nVias
				Otherwise
					nVias := 0
			EndCase
			
			SLG->(DbSetOrder(1)) //Filial + Codigo
			SLG->(DbSeek(xFilial() + Self:cCodigo))
			RecLock("SLG", .F.)
			SlG->LG_TEFVIAS := nVias
			SLG->(MsUnLock())
		EndIf
	
	EndIf 
	RestArea(aAreaSLG)
	RestArea(aAreaAtual)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Show         ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apresenta a interface de configuração                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Indica se é visualizacao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Show(nOpc, oDlg) Class LJCCfgTef 

	Local lRet := .F.	 
	Local lCriaDLg	:= .T. //Cria o dialogo?                             
	Local aSize		:= {}
	Local aObjects 	:= {}
	Local aObjects2	:= {}
	Local aInfo 	:= {}
	Local aPosObj 	:= {} 
	Local aPosObj2	:= {}
	Local nOpcA		:= 0	// Indica se o usuario clicou em 1=OK ou 0=Cancelar
	Local aTitles	:= {} 
	Local aPages	:= {}   
	Local lMobile 	:= STFGetCfg("lMobile", .F.)
	
	Local oCodigo
	Local oDescric   
	
	Local oFolderSitef
	Local oFolderDiscado   
	Local oFolder2Discado
	Local oFolderPayGo
	Local oFolderPHub
	
	Local oPnlSitefScroll
	Local oPanelPrincipal
	Local oPanelSitef1
	Local oPanelSitef2
	Local oPanelSitef3
	Local oPanelSitef4
	Local oPanelSitef5
	Local oPanelSitef6
	Local oPanelDiscado1
	Local oPanelDiscado2
	Local oPanelDiscado3 
	Local oPanelPayGo 
	Local oPanelDirecao
	Local oPanelPGHip 	
	Local oPanelPGTec
	Local oPanelPHub1
	Local oPanelPHub2
	
	Local oSitefEmp
	Local oSitefTerm
	Local oSitefIP        
	Local oCCCDHab      
	Local oChequeHab
	Local oRCHab
	Local oCBHab            
	Local oCbx   
	Local cCbx   
	Local nSelected
	Local oPBMHab   
	Local oSitPBMEpha   
	Local oSitPBMTrn  
	Local OSITEFCCCDHAB  
	Local oSitefChequeHab   
	Local oSitefRCHab 
	Local oSitefCBHab
	Local oSitefPBMHab
	Local oSitefCPHab
	Local lIsTplDro		:= ExistFunc("LJIsDro") .And. LJIsDro() //Verifica se usa o Template de Drogaria

	
	Local oDiscGpApp
	Local oDiscGpTx
	Local oDiscGpRx 

	
	Local oDiscGPCCCDHab
	Local oDiscGPChequeHab
	Local oHIPCDApp
	Local oHIPCDTx
	Local oHIPCDRx
	Local oHIPCDCCCDHab
	
	Local oTecBanApp
	Local oTecBanTx
	Local oTecBanRx
	Local oTecBanCCCDHab
	Local oTecBanChequeHab
	
	Local oPayGoApp
	Local oPayGoTx
	Local oPayGoRx
	Local oPayGoCCCDHab
	Local oPayGoChequeHab   
	
	Local oDirecaoApp
	Local oDirecaoTx
	Local oDirecaoRx
	Local oDirecaoCCCDHab
	Local oDirecaoChequeHab     
	
	Local oDiscGpBtApp
	Local oDiscGpBtTx
	Local oDiscGpBtRx
	Local oHIPCDBtApp
	Local oHIPCDBtTx
	Local oHIPCDBtRx
	Local oTecBanBtApp
	Local oTecBanBtTx
	Local oTecBanBtRx
	Local oPayGoBtApp
	Local oPayGoBtTx
	Local oPayGoBtRx
	Local oDirecaoBtApp
	Local oDirecaoBtTx
	Local oDirecaoBtRx
	Local cMenssagem

	Local bTefDisable 	:= {||oSitefIP:Refresh(),oSitefIP:Disable(),oSitefTerm:Refresh(),oSitefTerm:Disable(),oSitefEmp:Refresh(),oSitefEmp:Disable(),oSitefCCCDHab:Refresh(),oSitefCCCDHab:Disable(),oSitefChequeHab:Refresh(),oSitefChequeHab:Disable(),oSitefRCHab:Refresh(),oSitefRCHab:Disable(),oSitefCBHab:Refresh(),oSitefCBHab:Disable(),oSitefCPHab:Refresh(),oSitefCPHab:Disable(),oDiscGpApp:Disable(),oDiscGpTx:Disable(),oDiscGPCCCDHab:Disable(),oDiscGPChequeHab:Disable(),oHIPCDApp:Disable(),oHIPCDTx:Disable(),oHIPCDRx:Disable(),oHIPCDCCCDHab:Disable(),oTecBanApp:Disable(),oTecBanTx:Disable(),oTecBanRx:Disable(),oTecBanCCCDHab:Disable(),oTecBanChequeHab:Disable(),oPayGoApp:Disable(),oPayGoTx:Disable(),oPayGoRx:Disable(),oPayGoCCCDHab:Disable(),oPayGoChequeHab:Disable(),oDiscGpBtApp:Disable(),oDiscGpBtTx:Disable(),oDiscGpBtRx:Disable(),oHIPCDBtApp:Disable(),oHIPCDBtTx:Disable(),oHIPCDBtRx:Disable(),oTecBanBtApp:Disable(),oTecBanBtTx:Disable(),oTecBanBtRx:Disable(),oPayGoBtApp:Disable(),oPayGoBtTx:Disable(),oPayGoBtRx:Disable(),IIF(lUsePayHub,{oPHCodeComp:Disable(),oPHTenant:Disable(),oPHUserName:Disable(),oPHPassword:Disable(),oPHCliId:Disable(),oPHCliSecret:Disable(),oPHIdPinPed:Disable(),oPHCCCDHab:Disable(), Iif(lIsTplDro,(oSitefPBMHab:Refresh(),oSitefPBMHab:Disable()), Nil) },Nil)}
	Local bTefEnable 	:= {||oSitefIP:Enable(),oSitefTerm:Enable(),oSitefEmp:Enable(),oSitefCCCDHab:Refresh(),oSitefCCCDHab:Enable(),oSitefChequeHab:Refresh(),oSitefChequeHab:Enable(),oSitefRCHab:Refresh(),oSitefRCHab:Enable(),oSitefCBHab:Refresh(),oSitefCBHab:Enable(),oSitefCPHab:Refresh(),oSitefCPHab:Enable(),oDiscGpApp:Enable(),oDiscGpTx:Enable(), oDiscGPCCCDHab:Enable(),oDiscGPChequeHab:Enable(),oHIPCDApp:Enable(),oHIPCDTx:Enable(),oHIPCDRx:Enable(),oHIPCDCCCDHab:Enable(),oTecBanApp:Enable(),oTecBanTx:Enable(),oTecBanRx:Enable(),oTecBanCCCDHab:Enable(),oTecBanChequeHab:Enable(),oPayGoApp:Enable(),oPayGoTx:Enable(),oPayGoRx:Enable(),oPayGoCCCDHab:Enable(),oPayGoChequeHab:Enable(),oDiscGpBtApp:Enable(),oDiscGpBtTx:Enable(),oDiscGpBtRx:Enable(),oHIPCDBtApp:Enable(),oHIPCDBtTx:Enable(),oHIPCDBtRx:Enable(),oTecBanBtApp:Enable(),oTecBanBtTx:Enable(),oTecBanBtRx:Enable(),oPayGoBtApp:Enable(),oPayGoBtTx:Enable(),oPayGoBtRx:Enable(), IIF(lUsePayHub,{oPHCodeComp:Enable(),oPHTenant:Enable(),oPHUserName:Enable(),oPHPassword:Enable(),oPHCliId:Enable(),oPHCliSecret:Enable(),oPHIdPinPed:Enable(),oPHCCCDHab:Enable(), Iif(lIsTplDro,(oSitefPBMHab:Refresh(),oSitefPBMHab:Enable()), Nil) },Nil)}


	Local lPBMEpha	:= .F.
	Local lPBMtrn	:= .F.
	
	Local nTefAtivo := 1 
	Local lViewOnly	:= (nOpc == 2)
	Local oFontPq	:= Nil	  
	Local nUltLin	:= 0
	
	
	Local oDiscnVias
	Local oHIPnVias
	Local oTECnVias
	Local oPayGonVias
	Local oDirecaonVias
	
	Local oPHCodeComp
	Local oPHIdPinPed
	Local oPHTenant
	Local oPHUserName
	Local oPHPassword
	Local oPHCliId
	Local oPHCliSecret
	Local oPHCCCDHab

	oCfgTef := SELF //Objeto da propria classe LJCCfgTef

	//DEFINE FONT oFontPq  NAME "TIMES NEW ROMAN" SIZE 6,16 BOLD
	DEFINE FONT oFontPq  BOLD
	   
	AAdd( aObjects, { 480, 40, .F., .F. } )
	AAdd( aObjects, { 005, 005, .F., .F. } )
   	AAdd( aObjects, { 480, 160, .F., .F. } )                    
	
	If oDlg == NIL
		aSize := MsAdvSize(.T.,.F.,470)
	Else       
        aSize := {0, 0 , Int((oDlg:nHeight ) / 2), Int((oDlg:nWidth ) / 2)}
	EndIf
			
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObjFolder	:= MsObjSize( aInfo, aObjects ) 

    If oDlg == NIL
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL 
    Else
    	lCriaDLg := .F.
    EndIf 
	oPanelTef := tPanel():New(aPosObjFolder[1,1],aPosObjFolder[1,2], STR0003, oDlg,,.F.,,CLR_BLACK,,aPosObjFolder[1,4],aPosObjFolder[1,3] + 20, .T.) 	//"Utilização do TEF"
	
	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 005, 020, .F., .F. } )
	
	aInfo 	:= { aPosObjFolder[1,1], aPosObjFolder[1,2], aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects )	 		

	If !oCfgTef:lAtivo  
		nTefAtivo := 2	
	EndIf
	
	@  aPosObj[02,01],aPosObj[02,02] RADIO oTEFAtivo VAR nTefAtivo OF oPanelTef PIXEL SIZE 70,08 ITEMS STR0004, STR0005 ON CHANGE (oCfgTef:lAtivo:=IIf(nTefAtivo==1,.T.,.F.),Eval(IIf(oCfgTef:lAtivo,bTefEnable,bTefDisable /*bTefDisable*/ ))) 3D    //"Habilitado"  //"Desabilitado"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criação dos folders com as modalidades³
	//³de TEF disponivies.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aTitles, "Dedicado(Sitef)")
	aAdd(aTitles, "Discado(Gerenciador Padrão)")
	aAdd(aTitles, "Discado(PayGo)")
	If lUsePayHub
		aAdd(aTitles, "Payment Hub")
	EndIf
	
	aPages	:= {"HEADER","HEADER","HEADER"}

	oFolder := TFolder():New(70, 3 ,aTitles, aPages, oDlg,,,,.T.,.F., aPosObjFolder[3,4],aPosObjFolder[3,3]-20,)

	oFolderSitef	:= oFolder:aDialogs[1] 
	oFolderDiscado	:= oFolder:aDialogs[2]
	oFolderPayGo	:= oFolder:aDialogs[3]
	If lUsePayHub
		oFolderPHub		:= oFolder:aDialogs[4]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1. Criacao do Folder Sitef³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}                      
	AAdd( aObjects, { 460, 050, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )
 
	aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 

	aPosObj	:= MsObjSize( aInfo, aObjects )	 	 				

	// Cria objeto do tipo Painel com barra de rolagem (Scroll)
	oPnlSitefScroll := TScrollArea():New(oFolderSitef,01,01,200,200)
	oPnlSitefScroll:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelPrincipal:= tPanel():New(01,01,Nil,oPnlSitefScroll,Nil,.T.,,,,100,250)
	
	oPnlSitefScroll:SetFrame( oPanelPrincipal ) //Define objeto painel como filho do Panel com Scroll
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.1. Configuracoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oPanelSitef1 := tPanel():New(aPosObj[1,1], aPosObj[1,2], STR0006,	oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4] + 50 ,aPosObj[1,3] + 50, .T.) //"Configurações"
	aObjects := {}                      

	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 005, 005, .F., .F. } )
	AAdd( aObjects, { 002, 001, .F., .F. } )
	AAdd( aObjects, { 005, 005, .F., .F. } )
	AAdd( aObjects, { 002, 001, .F., .F. } )
	AAdd( aObjects, { 005, 005, .F., .F. } )
	
	aInfo 		:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 	
	
	@ aPosObj2[02,01],aPosObj2[02,02]  		SAY STR0007 PIXEL SIZE 55,9 OF oPanelSitef1 //"Endereço IP:"
	@ aPosObj2[02,01],aPosObj2[02,02]+40 	GET oSitefIP VAR oCfgTef:oSitef:cIpAddress SIZE 160,08 PIXEL OF oPanelSitef1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER		 
	@ aPosObj2[02,01],aPosObj2[02,02]+205  	SAY "(000.000.000)" PIXEL COLOR CLR_HRED FONT oFontPq SIZE 55,9 OF oPanelSitef1 //"Endereço IP:"
	

	@ aPosObj2[04,01],aPosObj2[04,02]  		SAY STR0008 PIXEL SIZE 55,9 OF oPanelSitef1 //"Terminal:"
	@ aPosObj2[04,01],aPosObj2[04,02]+040 	GET oSitefTerm VAR oCfgTef:oSitef:cTerminal SIZE 160,08 PIXEL Picture 'AA999999' OF oPanelSitef1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER		 	
	@ aPosObj2[04,01],aPosObj2[04,02]+205  	SAY "(CCNNNNNN)"  PIXEL COLOR CLR_HRED FONT oFontPq SIZE 55,9 OF oPanelSitef1 //"Terminal:"
	


	@ aPosObj2[06,01],aPosObj2[06,02]  		SAY STR0009 PIXEL SIZE 55,9   OF oPanelSitef1 //"Empresa:"
	@ aPosObj2[06,01],aPosObj2[06,02]+40 	GET oSitefEmp VAR oCfgTef:oSitef:cEmpresa SIZE 160,08 PIXEL Picture 'NNNNNNNN' OF oPanelSitef1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER		 		
	@ aPosObj2[06,01],aPosObj2[06,02]+205  	SAY "(XXXXXXXX)" PIXEL COLOR CLR_HRED FONT oFontPq SIZE 55,9   OF oPanelSitef1 //"Empresa:"


   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.2. Cartão Crédito/Débito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oPanelSitef2 := tPanel():New(aPosObj[3,1],aPosObj[3,2], STR0010,	oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3], .T.) 	//"Cartão Crédito/Débito"
	
	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 001, 001, .F., .F. } )

	aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

	@ aPosObj2[02,01],aPosObj2[02,02]  	CHECKBOX oSitefCCCDHab VAR oCfgTef:oSitef:lCCCD PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelSitef2 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef) .OR. Self:PayHubHb(oCfgTef) .Or. Self:PayHubHb(oCfgTef)) //"Habilitado"

	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.3. Cheque³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelSitef3 := tPanel():New(aPosObj[5,1],aPosObj[5,2],STR0011,					oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3]-25, .T.) 	//"Cheque"

	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 001, 001, .F., .F. } )

	aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

	@ aPosObj2[02,01],aPosObj2[02,02]  	CHECKBOX oSitefChequeHab VAR oCfgTef:oSitef:lCheque PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelSitef3 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef) ) //"Habilitado"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.4. Recarga de Celular³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelSitef4 := tPanel():New(aPosObj[7,1],aPosObj[7,2], STR0012,		oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3]-25, .T.) //"Recarga de Celular"
    
	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 001, 001, .F., .F. } )

	aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

	@ aPosObj2[02,01],aPosObj2[02,02]	 	CHECKBOX oSitefRCHab VAR oCfgTef:oSitef:lRC PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelSitef4 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef) ) //"Habilitado"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.5. Correspondente Bancário³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelSitef5 := tPanel():New(aPosObj[9,1],aPosObj[9,2], STR0013,	oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3]-25, .T.) //"Correspondente Bancário"

	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 001, 001, .F., .F. } )

	aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

	@ aPosObj2[02,01],aPosObj2[02,02]	 	CHECKBOX oSitefCBHab VAR oCfgTef:oSitef:lCB PROMPT STR0014 PIXEL SIZE 55,9 OF oPanelSitef5 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef).OR. Self:DiscadoHb(oCfgTef)) //"Banco do Brasil"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1.6. Cielo Premia				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelSitef6 := tPanel():New(aPosObj[11,1],aPosObj[11,2], STR0040 ,	oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3]-25, .T.) //""Cielo Premia""

	aObjects := {}                      
	AAdd( aObjects, { 002, 002, .F., .F. } )
	AAdd( aObjects, { 001, 001, .F., .F. } )

	aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

	@ aPosObj2[02,01],aPosObj2[02,02]	 	CHECKBOX oSitefCPHab VAR oCfgTef:oSitef:lCieloPrem PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelSitef6 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef).OR. Self:DiscadoHb(oCfgTef)) //"Banco do Brasil"

	
	//---------------------
	// 1.7. PBM (Drogaria)
	//---------------------
	If lIsTplDro
		oPanelSitef6 := tPanel():New(aPosObj[13,1],aPosObj[13,2], "PBM (Drogaria)", oPanelPrincipal,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3]-25, .T.)

		aObjects := {}                      
		AAdd( aObjects, { 002, 002, .F., .F. } )
		AAdd( aObjects, { 001, 001, .F., .F. } )

		aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
		aPosObj2:= MsObjSize( aInfo, aObjects )	 		

		@ aPosObj2[02,01],aPosObj2[02,02]	CHECKBOX oSitefPBMHab VAR oCfgTef:oSitef:lPBM PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelSitef6 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:PayGoHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef)) //"Habilitado"
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2. Criacao do Folder Discado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}                      
	AAdd( aObjects, { 460, 090, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
 	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
 	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
		
	aInfo 	:= { aPosObjFolder[1,1]-13, aPosObjFolder[1,2], aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 	 				
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2.1. Gerenciador Padrão³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oPanelDiscado1 := tPanel():New(aPosObj[1,1],aPosObj[1,2] + 6, STR0018,	oFolderDiscado,,.F.,,CLR_BLACK,,aPosObj[1,4],aPosObj[1,3], .T.) //"Visa/ Amex/ Redecard (Gerenciador Padrão)"
	nUltLin := aPosObj[1,3] - 15   
	aObjects := {} 

	
	AAdd( aObjects, { 020, 002, .F., .F., .F. } )  //1
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  //2
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //3
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  //4
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //5
	AAdd( aObjects, { 001, 010, .F., .F., .F. } )  //6
	
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //7
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  //8
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //9
	AAdd( aObjects, { 005, 010, .F., .F., .F. } )

	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //10
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  //11
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //12
	AAdd( aObjects, { 010, 010, .F., .F., .F. } ) //13
	AAdd( aObjects, { 001, 002, .F., .F., .F. } ) //14	
	AAdd( aObjects, { 010, 002, .F., .F., .F. } ) //15  
	
	aInfo 	:= { aPosObjFolder[1,1], aPosObjFolder[1,2]+5, aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 	
		
	aPosObj2[01,02] += 4
	aPosObj2[03,02] += 4
	aPosObj2[05,02] += 4
	aPosObj2[11,02] += 4

	
	@ aPosObj2[01,01],aPosObj2[01,02]  		SAY STR0019 PIXEL SIZE 55,9 OF oPanelDiscado1 //"Caminho da aplicação:"
	@ aPosObj2[01,01],aPosObj2[01,02]+60 	GET oDiscGpApp VAR oCfgTef:oDiscado:cGPAppPath SIZE 160,08 PIXEL OF oPanelDiscado1 WHEN (.T.) CENTER		 
	@ aPosObj2[01,01],aPosObj2[01,02]+220 	BUTTON oDiscGpBtApp PROMPT " ... " SIZE 10,10 OF oPanelDiscado1 PIXEL ACTION oCfgTef:oDiscado:cGPAppPath:=Self:GetAppPath()
	
	
	@ aPosObj2[03,01],aPosObj2[03,02]  		SAY STR0020 PIXEL SIZE 55,9 OF oPanelDiscado1 //"Diretório de envio:"
	@ aPosObj2[03,01],aPosObj2[03,02]+60 	GET oDiscGpTx VAR oCfgTef:oDiscado:cGPDirTx SIZE 160,08 PIXEL OF oPanelDiscado1 WHEN (Desbloqueia) CENTER		 	
	@ aPosObj2[03,01],aPosObj2[03,02]+220 	BUTTON oDiscGpBtTx PROMPT " ... " SIZE 10,10 OF oPanelDiscado1 PIXEL ACTION oCfgTef:oDiscado:cGPDirTx:=Self:GetDirectory()
	
	@ aPosObj2[05,01],aPosObj2[05,02]  		SAY STR0021 PIXEL SIZE 55,9 OF oPanelDiscado1 //"Diretório de resposta:"
	@ aPosObj2[05,01],aPosObj2[05,02]+60 	GET oDiscGpRx VAR oCfgTef:oDiscado:cGPDirRx SIZE 160,08 PIXEL OF oPanelDiscado1 ON CHANGE oDiscnVias:Refresh() WHEN (Desbloqueia)  CENTER		 			
	@ aPosObj2[05,01],aPosObj2[05,02]+220 	BUTTON oDiscGpBtRx PROMPT " ... " SIZE 10,10 OF oPanelDiscado1 PIXEL ACTION oCfgTef:oDiscado:cGPDirRx:=Self:GetDirectory()  
	
	@ aPosObj2[07,01] -6,aPosObj2[07,02] + 4  	SAY STR0010 PIXEL SIZE 55,9 OF oPanelDiscado1 	//"Cartão Crédito/ Débito"
	@ aPosObj2[09,01] -7,aPosObj2[09,02] + 4	CHECKBOX oDiscGPCCCDHab VAR oCfgTef:oDiscado:lGPCCCD 			PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelDiscado1 ON CHANGE IIF( oCfgTef:oDiscado:lGPCCCD  .OR. oCfgTef:oDiscado:lGPCheque,oDiscnVias:Enable(), oDiscnVias:Disable()  )  WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef) .OR. Self:DirecaoHb(oCfgTef) .Or. Self:PayHubHb(oCfgTef))    //"Habilitado"
	
	@ aPosObj2[07,01] -6,aPosObj2[11,02] + 90  SAY STR0011 PIXEL SIZE 55,9 OF oPanelDiscado1 	//"Cheque"
	@ aPosObj2[09,01] -7,aPosObj2[13,02] + 90 + 4 CHECKBOX oDiscGPChequeHab VAR oCfgTef:oDiscado:lGPCheque 	PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelDiscado1 ON CHANGE IIF( oCfgTef:oDiscado:lGPCCCD  .OR. oCfgTef:oDiscado:lGPCheque,oDiscnVias:Enable(), oDiscnVias:Disable()  ) WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef) .OR. Self:DirecaoHb(oCfgTef))    //"Habilitado"

	@ aPosObj2[07,01] -6,aPosObj2[13,02] + 90 + 4 + 60 SAY "Número de Vias" PIXEL SIZE 55,9 OF oPanelDiscado1 	//"Numero de Vias"
	@ aPosObj2[09,01] -7,aPosObj2[13,02] + 90 + 4 + 60 GET oDiscnVias VAR oCfgTef:oDiscado:nVias 	SiZE 20,08 PIXEL OF oPanelDiscado1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef) .OR. Self:DirecaoHb(oCfgTef)) .AND. ( oCfgTef:oDiscado:lGPCCCD  .OR. oCfgTef:oDiscado:lGPCheque )  //"Habilitado"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2.2. HiperCard         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aObjects := {}                      
	AAdd( aObjects, { 460, 090, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
 	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
 	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  

	
	
	aInfo 	:= { aPosObjFolder[1,1]-13, aPosObjFolder[1,2], aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 	
	
	oPanelDiscado2 := tPanel():New(nUltLin,aPosObj[1,2]+6, STR0022,		oFolderDiscado,,.F.,,CLR_BLACK,,aPosObj[1,4],aPosObj[1,3], .T.) //"Hipercard"
	nUltLin += aPosObj[1,3] - 30           
	aObjects := {} 

	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 010, .F., .F., .F. } )  
	
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  
	AAdd( aObjects, { 005, 010, .F., .F., .F. } )
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )

	aInfo 	:= { aPosObjFolder[1,1], aPosObjFolder[1,2]+5, aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 	
	
	aPosObj2[01,02] += 4
	aPosObj2[03,02] += 4
	aPosObj2[05,02] += 4
	aPosObj2[07,02] += 4
	aPosObj2[09,02] += 4  
	aPosObj2[10,02] += 4
		
	@ aPosObj2[01,01] -05 ,aPosObj2[01,02]  	SAY STR0019 PIXEL SIZE 55,9 OF oPanelDiscado2 //"Caminho da aplicação:"
	@ aPosObj2[01,01] -05 ,aPosObj2[01,02]+60 	GET oHIPCDApp VAR oCfgTef:oDiscado:cHiperCDAppPath SIZE 160,08 PIXEL OF oPanelDiscado2 WHEN (Desbloqueia) CENTER		 
	@ aPosObj2[01,01] -05 ,aPosObj2[01,02]+220 	BUTTON oHIPCDBtApp PROMPT " ... " SIZE 10,10 OF oPanelDiscado2 PIXEL ACTION oCfgTef:oDiscado:cHiperCDAppPath:=Self:GetAppPath()
	
	@ aPosObj2[03,01] -05 ,aPosObj2[03,02]  	SAY STR0020 PIXEL SIZE 55,9 OF oPanelDiscado2 //"Diretório de envio:"
	@ aPosObj2[03,01] -05 ,aPosObj2[03,02]+60 	GET oHIPCDTx VAR oCfgTef:oDiscado:cHiperCDDirTx SIZE 160,08 PIXEL OF oPanelDiscado2 WHEN (Desbloqueia) CENTER	
	@ aPosObj2[03,01] -05 ,aPosObj2[03,02]+220 BUTTON oHIPCDBtTx PROMPT " ... " SIZE 10,10 OF oPanelDiscado2 PIXEL ACTION oCfgTef:oDiscado:cHiperCDDirTx:=Self:GetDirectory()
	
	@ aPosObj2[05,01] -05 ,aPosObj2[05,02]  	SAY STR0021 PIXEL SIZE 55,9 OF oPanelDiscado2 //"Diretório de resposta:"
	@ aPosObj2[05,01] -05 ,aPosObj2[05,02]+60 	GET oHIPCDRx VAR oCfgTef:oDiscado:cHiperCDDirRx SIZE 160,08 PIXEL OF oPanelDiscado2 WHEN (Desbloqueia) CENTER		 			
	@ aPosObj2[05,01] -05 ,aPosObj2[05,02]+220 	BUTTON oHIPCDBtRx PROMPT " ... " SIZE 10,10 OF oPanelDiscado2 PIXEL ACTION oCfgTef:oDiscado:cHiperCDDirRx:=Self:GetDirectory()
	
	@ aPosObj2[07,01] -13 ,aPosObj2[07,02]  	SAY STR0010 PIXEL SIZE 55,9 OF oPanelDiscado2 	//"Cartão Crédito/ Débito"
	@ aPosObj2[09,01] -15 ,aPosObj2[09,02]	 	CHECKBOX oHIPCDCCCDHab VAR oCfgTef:oDiscado:lHiperCDCCCD PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelDiscado2  ON CHANGE IIF( oCfgTef:oDiscado:lHiperCDCCCD  ,oHIPnVias:Enable(), oHIPnVias:Disable()  ) WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef)) //"Habilitado"

	@ aPosObj2[07,01] -13,aPosObj2[09,02]+60 SAY "Número de Vias" PIXEL SIZE 55,9 OF oPanelDiscado2 	//"Numero de Vias"
	@ aPosObj2[09,01] -15,aPosObj2[09,02]+60 GET oHIPnVias VAR oCfgTef:oDiscado:nHIPERVias 	SiZE 20,08 PIXEL OF oPanelDiscado2 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef))   .AND. oCfgTef:oDiscado:lHiperCDCCCD   //"Habilitado"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2.3. TecBan            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	
	aObjects := {}                      
	AAdd( aObjects, { 460, 090, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
	AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
	AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
 
	aInfo 	:= { aPosObjFolder[1,1]-13, aPosObjFolder[1,2], aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj	:= MsObjSize( aInfo, aObjects )	 	 				
	  
	oPanelDiscado3 := tPanel():New(nUltLin,aPosObj[1,2]+6, STR0023,			oFolderDiscado,,.F.,,CLR_BLACK,,aPosObj[1,4],aPosObj[1,3], .T.) //"Tecban"
	  
	
	aObjects := {} 
	AAdd( aObjects, { 020, 002, .F., .F., .F. } )  //1
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  //2
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //3
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  //4
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //5
	AAdd( aObjects, { 001, 010, .F., .F., .F. } )  //6
	
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //7
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  //8
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //9
	AAdd( aObjects, { 005, 010, .F., .F., .F. } )

	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //10
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  //11
	AAdd( aObjects, { 010, 002, .F., .F., .F. } )  //12
	AAdd( aObjects, { 010, 010, .F., .F., .F. } ) //13
	AAdd( aObjects, { 001, 002, .F., .F., .F. } ) //14	
	AAdd( aObjects, { 010, 002, .F., .F., .F. } ) //15  

	aInfo 	:= { aPosObjFolder[1,1], aPosObjFolder[1,2]+5, aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 	
	
	aPosObj2[01,02] += 4 
	aPosObj2[03,02] += 4
	aPosObj2[05,02] += 4
	aPosObj2[07,02] += 4
	aPosObj2[09,02] += 4
	aPosObj2[11,02] += 4
		
	@ aPosObj2[01,01] -5 ,aPosObj2[01,02]  	SAY STR0019 PIXEL SIZE 55,9 OF oPanelDiscado3 //"Caminho da aplicação:"
	@ aPosObj2[01,01] -5 ,aPosObj2[01,02]+60 	GET oTecBanApp VAR oCfgTef:oDiscado:cTecBanAppPath SIZE 160,08 PIXEL OF oPanelDiscado3 WHEN (Desbloqueia) CENTER		 
	@ aPosObj2[01,01] -5 ,aPosObj2[01,02]+220 	BUTTON oTecBanBtApp PROMPT " ... " SIZE 10,10 OF oPanelDiscado3 PIXEL ACTION oCfgTef:oDiscado:cTecBanAppPath:=Self:GetAppPath()
	
	@ aPosObj2[03,01] -5 ,aPosObj2[03,02]  	SAY STR0020 PIXEL SIZE 55,9 OF oPanelDiscado3 //"Diretório de envio:"
	@ aPosObj2[03,01] -5 ,aPosObj2[03,02]+60 	GET oTecBanTx VAR oCfgTef:oDiscado:cTecBanDirTx SIZE 160,08 PIXEL OF oPanelDiscado3 WHEN (Desbloqueia) CENTER		 	
	@ aPosObj2[03,01] -5 ,aPosObj2[03,02]+220 	BUTTON oTecBanBtTx PROMPT " ... " SIZE 10,10 OF oPanelDiscado3 PIXEL ACTION oCfgTef:oDiscado:cTecBanDirTx:=Self:GetDirectory()
	
	@ aPosObj2[05,01] -5 ,aPosObj2[05,02]  	SAY STR0021 PIXEL SIZE 55,9 OF oPanelDiscado3 //"Diretório de resposta:"
	@ aPosObj2[05,01] -5 ,aPosObj2[05,02]+60 	GET oTecBanRx VAR oCfgTef:oDiscado:cTecBanDirRx SIZE 160,08 PIXEL OF oPanelDiscado3 WHEN (Desbloqueia) CENTER		 			
	@ aPosObj2[05,01] -5 ,aPosObj2[05,02]+220 	BUTTON oTecBanBtRx PROMPT " ... " SIZE 10,10 OF oPanelDiscado3 PIXEL ACTION oCfgTef:oDiscado:cTecBanDirRx:=Self:GetDirectory()
	
	@ aPosObj2[07,01] -13 ,aPosObj2[07,02]  	SAY STR0010 PIXEL SIZE 55,9 OF oPanelDiscado3 	//"Cartão Crédito/ Débito"
	@ aPosObj2[09,01] -15 ,aPosObj2[09,02]	 	CHECKBOX oTecBanCCCDHab VAR oCfgTef:oDiscado:lTecBanCCCD PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelDiscado3 ON CHANGE  IIF( (oCfgTef:oDiscado:lTecBanCheque .OR. oCfgTef:oDiscado:lTecBanCCCD)  ,oTECnVias:Enable(), oTECnVias:Disable()  ) WHEN !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef)) //"Habilitado"
    
	@ aPosObj2[07,01] -13 ,aPosObj2[11,02]+90  	SAY STR0011 PIXEL SIZE 55,9 OF oPanelDiscado3 	//"Cheque"
	@ aPosObj2[09,01] -15 ,aPosObj2[13,02]+90 	CHECKBOX oTecBanChequeHab VAR oCfgTef:oDiscado:lTecBanCheque PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelDiscado3 ON CHANGE  IIF( (oCfgTef:oDiscado:lTecBanCheque .OR. oCfgTef:oDiscado:lTecBanCCCD)  ,oTECnVias:Enable(), oTECnVias:Disable()  ) WHEN !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef)) //"Habilitado"


	@ aPosObj2[07,01] -13,aPosObj2[13,02]+90+60 SAY "Número de Vias" PIXEL SIZE 55,9 OF oPanelDiscado3 	//"Numero de Vias"
	@ aPosObj2[09,01] -15,aPosObj2[13,02]+90+60 GET oTECnVias VAR oCfgTef:oDiscado:nTECVias 	SiZE 20,08 PIXEL OF oPanelDiscado3 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:PayGoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef)) .AND. (oCfgTef:oDiscado:lTecBanCheque .OR. oCfgTef:oDiscado:lTecBanCCCD)     //"Habilitado"

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³4.1. PayGo             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oPanelPayGo := tPanel():New(aPosObj[1,1],aPosObj[1,2] + 6, STR0024,			oFolderPayGo,,.F.,,CLR_BLACK,,aPosObj[1,4],aPosObj[1,3], .T.) //"PayGo"
	  
	aObjects := {} 
          
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 010, .F., .F., .F. } )  
	
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 005, 010, .F., .F., .F. } )

	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 001, 001, .F., .F., .F. } )  
	AAdd( aObjects, { 002, 002, .F., .F., .F. } )  
	AAdd( aObjects, { 005, 010, .F., .F., .F. } )	

	aInfo 	:= { aPosObjFolder[1,1], aPosObjFolder[1,2]+5, aPosObjFolder[1,3], aPosObjFolder[1,4], 3, 3 } 
	aPosObj2	:= MsObjSize( aInfo, aObjects )	 	
		
	aPosObj2[01,02]  += 4
	aPosObj2[03,02]  += 4
	aPosObj2[05,02]  += 4
	aPosObj2[07,02]  += 4
	aPosObj2[09,02]  += 4
		
		
	@ aPosObj2[01,01],aPosObj2[01,02]  		SAY STR0019 PIXEL SIZE 55,9 OF oPanelPayGo //"Caminho da aplicação:"
	@ aPosObj2[01,01],aPosObj2[01,02]+60 	GET oPayGoApp VAR oCfgTef:oPayGo:cAppPath SIZE 160,08 PIXEL OF oPanelPayGo WHEN (Desbloqueia) CENTER		 
	@ aPosObj2[01,01],aPosObj2[01,02]+220 	BUTTON oPayGoBtApp PROMPT " ... " SIZE 10,10 OF oPanelPayGo PIXEL ACTION oCfgTef:oPayGo:cAppPath:=Self:GetAppPath()
	
	@ aPosObj2[03,01],aPosObj2[03,02]  		SAY STR0020 PIXEL SIZE 55,9 OF oPanelPayGo //"Diretório de envio:"
	@ aPosObj2[03,01],aPosObj2[03,02]+60 	GET oPayGoTx VAR oCfgTef:oPayGo:cDirTx SIZE 160,08 PIXEL OF oPanelPayGo WHEN (Desbloqueia) CENTER		 	
	@ aPosObj2[03,01],aPosObj2[03,02]+220 	BUTTON oPayGoBtTx PROMPT " ... " SIZE 10,10 OF oPanelPayGo PIXEL ACTION oCfgTef:oPayGo:cDirTx:=Self:GetDirectory()
	
	@ aPosObj2[05,01],aPosObj2[05,02]  		SAY STR0021 PIXEL SIZE 55,9 OF oPanelPayGo //"Diretório de resposta:"
	@ aPosObj2[05,01],aPosObj2[05,02]+60 	GET oPayGoRx VAR oCfgTef:oPayGo:cDirRx SIZE 160,08 PIXEL OF oPanelPayGo WHEN (Desbloqueia) CENTER		 			
	@ aPosObj2[05,01],aPosObj2[05,02]+220 	BUTTON oPayGoBtRx PROMPT " ... " SIZE 10,10 OF oPanelPayGo PIXEL ACTION oCfgTef:oPayGo:cDirRx:=Self:GetDirectory()
	
	@ aPosObj2[07,01] -6,aPosObj2[07,02]  	   SAY STR0010 PIXEL SIZE 55,9 OF oPanelPayGo 	//"Cartão Crédito/ Débito"
	@ aPosObj2[09,01] -7,aPosObj2[09,02]	   CHECKBOX oPayGoCCCDHab VAR oCfgTef:oPayGo:lCCCD PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelPayGo WHEN !(Self:SiTefHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef).OR. Self:DirecaoHb(oCfgTef))    //"Habilitado"
    
	@ aPosObj2[07,01] -6,aPosObj2[11,02] + 90 	SAY STR0011 PIXEL SIZE 55,9 OF oPanelPayGo 	//"Cheque"
	@ aPosObj2[09,01] -7,aPosObj2[13,02] + 90 	CHECKBOX oPayGoChequeHab VAR oCfgTef:oPayGo:lCheque PROMPT STR0004 		PIXEL SIZE 55,9 OF oPanelPayGo WHEN !(Self:SiTefHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef) .OR. Self:DirecaoHb(oCfgTef) .Or. Self:PayGoHb(oCfgTef))    //"Habilitado"

	//----------------------------------------
	// 5. Criacao do Folder "Hub de Pagamento"
	//----------------------------------------
	If lUsePayHub
		aObjects := {}                      
		AAdd( aObjects, { 460, 050, .F., .F., .F. } )   
		AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
		AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
		AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
		AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
		AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
		AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
		AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
		AAdd( aObjects, { 460, 015, .F., .F., .F. } )   
		AAdd( aObjects, { 005, 005, .F., .F., .F. } )  
		AAdd( aObjects, { 460, 015, .F., .F., .F. } )  
	
		aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 

		aPosObj	:= MsObjSize( aInfo, aObjects )	 	 				
		
		//--------------------
		// 5.1. Configuracoes
		//--------------------
		oPanelPHub1 := tPanel():New(aPosObj[1,1], aPosObj[1,2], STR0006, oFolderPHub,,.F.,,CLR_BLACK,,aPosObj[1,4] + 50 ,aPosObj[1,3] + 50, .T.) //"Configurações"

		aObjects := {}                      
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )
		AAdd( aObjects, { 002, 001, .F., .F. } )
		AAdd( aObjects, { 005, 005, .F., .F. } )

		aInfo 		:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
		aPosObj2	:= MsObjSize( aInfo, aObjects )	 	

		@ aPosObj2[02,01],aPosObj2[02,02]  		SAY FWX3Titulo("MDG_PHCOMP") PIXEL SIZE 55,9 OF oPanelPHub1 //Código da Companhia
		@ aPosObj2[02,01],aPosObj2[02,02]+040 	GET oPHCodeComp VAR oCfgTef:oPaymentHub:cCodeComp SIZE 160,08 PIXEL OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHCodeComp:cSx1Hlp := "MDG_PHCOMP"

		@ aPosObj2[04,01],aPosObj2[04,02]  		SAY FWX3Titulo("MDG_PHTENA") PIXEL SIZE 55,9 OF oPanelPHub1 //Tenant
		@ aPosObj2[04,01],aPosObj2[04,02]+040 	GET oPHTenant VAR oCfgTef:oPaymentHub:cTenant SIZE 160,08 PIXEL OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHTenant:cSx1Hlp := "MDG_PHTENA"

		@ aPosObj2[06,01],aPosObj2[06,02]  		SAY FWX3Titulo("MDG_PHUSER") PIXEL SIZE 55,9   OF oPanelPHub1 //Usuário com o perfil ROAcessorUser
		@ aPosObj2[06,01],aPosObj2[06,02]+040 	GET oPHUserName VAR oCfgTef:oPaymentHub:cUserName SIZE 160,08 PIXEL OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHUserName:cSx1Hlp := "MDG_PHUSER"

		@ aPosObj2[08,01],aPosObj2[08,02]  		SAY FWX3Titulo("MDG_PHPSWD") PIXEL SIZE 55,9   OF oPanelPHub1 //Senha do usuário com o perfil ROAcessorUser
		@ aPosObj2[08,01],aPosObj2[08,02]+040 	GET oPHPassword VAR oCfgTef:oPaymentHub:cPassword SIZE 160,08 PIXEL PASSWORD OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHPassword:cSx1Hlp := "MDG_PHPSWD"

		@ aPosObj2[10,01],aPosObj2[10,02]  		SAY FWX3Titulo("MDG_PHCLID") PIXEL SIZE 55,9   OF oPanelPHub1 //Client ID
		@ aPosObj2[10,01],aPosObj2[10,02]+040 	GET oPHCliId VAR oCfgTef:oPaymentHub:cClientId SIZE 160,08 PIXEL OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHCliId:cSx1Hlp := "MDG_PHCLID"

		@ aPosObj2[12,01],aPosObj2[12,02]  		SAY FWX3Titulo("MDG_PHCLSR") PIXEL SIZE 55,9   OF oPanelPHub1 //Client Secret
		@ aPosObj2[12,01],aPosObj2[12,02]+040 	GET oPHCliSecret VAR oCfgTef:oPaymentHub:cClientSecret SIZE 160,08 PIXEL OF oPanelPHub1 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHCliSecret:cSx1Hlp := "MDG_PHCLSR"

		@ aPosObj2[14,01],aPosObj2[14,02]  		SAY FWX3Titulo("MDG_PHTERM") PIXEL SIZE 55,9 OF oPanelPHub1 //Terminal
		@ aPosObj2[14,01],aPosObj2[14,02]+040 	MSGET oPHIdPinPed VAR oCfgTef:oPaymentHub:cIdPinPed SIZE 160,08 PIXEL OF oPanelPHub1 F3 "TTEFPH" WHEN (oCfgTef:lAtivo .AND. !lViewOnly) CENTER
		oPHIdPinPed:cSx1Hlp := "MDG_PHTERM"
		

		//----------------------------
		// 5.2. Cartão Crédito/Débito
		//----------------------------
		oPanelPHub2 := tPanel():New(aPosObj[7,1],aPosObj[7,2], STR0010,	oFolderPHub,,.F.,,CLR_BLACK,,aPosObj[1,4]+50,aPosObj[1,3], .T.) 	//"Cartão Crédito/Débito"
		
		aObjects := {}                      
		AAdd( aObjects, { 002, 002, .F., .F. } )
		AAdd( aObjects, { 001, 001, .F., .F. } )

		aInfo 	:= { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 3, 3 } 
		aPosObj2	:= MsObjSize( aInfo, aObjects )	 		

		@ aPosObj2[02,01],aPosObj2[02,02]  	CHECKBOX oPHCCCDHab VAR oCfgTef:oPaymentHub:lCCCD PROMPT STR0004 PIXEL SIZE 55,9 OF oPanelPHub2 WHEN (oCfgTef:lAtivo .AND. !lViewOnly) .AND. !(Self:SiTefHb(oCfgTef) .OR. Self:DiscadoHb(oCfgTef) .OR. Self:DirecaoHb(oCfgTef) ) //"Habilitado"	
	EndIf

	If lCriaDLg 	
		ACTIVATE MSDIALOG oDlg CENTER ON INIT ( EnchoiceBar(oDlg,{||  If ( !Self:TefVl(oCfgTef, @lRet)   , Alert(Self:cMenssagem)  , oDlg:End()    ) },{|| lRet := .F. , oDlg:End()   }),IIf(nOpc==2,(Eval(bTefDisable),oTEFAtivo:Disable()),.T.)) 
    Else    	 				
    	 IIf(nOpc==2,(Eval(bTefDisable),oTEFAtivo:Disable()),.T.)
    EndIf
Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetAppPath    ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o aplicativo.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method GetAppPath() Class LJCCfgTef

	Local nVisibilidade := GETF_LOCALHARD // Somente exibe o diretório do cliente
	Local cAplic		:= ""

	cAplic := cGetFile(	STR0025 + " (*.exe)     | *.exe | ",; 	//"Todos os Executáveis"
					    STR0026 , 0,; 							//"Selecione um arquivo"
					    ,.T.,nVisibilidade, If(nVisibilidade==56, .F., .T.) )

Return cAplic    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetDirectory  ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o diretorio.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method GetDirectory() Class LJCCfgTef 			
	
	Local nVisibilidade := GETF_LOCALHARD + GETF_RETDIRECTORY // Somente exibe o diretório do cliente
	Local cAplic		:= "" // Titulo do arquivo

	cAplic := cGetFile(	STR0027 + " (*.*)     | *.* | ",; 	//"Todos os Arquivos"
					    STR0028 , 0,;	 					//"Selecione um arquivo"
					    ,.T.,nVisibilidade, If(nVisibilidade==56, .F., .T.) )

Return cAplic    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PayGoHb  		ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o diretorio.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method PayGoHb(oCfgTef) Class LJCCfgTef 
	
	Local lRet := .F.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil	 	// Objeto de controle de componente

	If oCfgTef:oPayGo:lCheque .OR. oCfgTef:oPayGo:lCCCD
		lRet := .T.
	EndIF
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DirecaoHb     ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o diretorio.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method DirecaoHb(oCfgTef) Class LJCCfgTef 
	
	Local lRet := .F.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil	 	// Objeto de controle de componente

	If oCfgTef:oDirecao:lCheque .OR. oCfgTef:oDirecao:lCCCD
		lRet := .T.
	EndIF
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiscadoHb		ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o diretorio.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method DiscadoHb(oCfgTef) Class LJCCfgTef  
	
	Local lRet := .F.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil 	// Objeto de controle de componente


	If 	oCfgTef:oDiscado:lGPCCCD .OR. oCfgTef:oDiscado:lGPCheque .OR.;
	 	oCfgTef:oDiscado:lHiperCDCCCD .OR. oCfgTef:oDiscado:lTecBanCCCD .OR.;
	 	oCfgTef:oDiscado:lTecBanCheque	
	 	
		lRet := .T.
	
	EndIF
	

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SiTefHb  		ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method SiTefHb(oCfgTef) Class LJCCfgTef  	

	Local lRet := .F.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil 	// Objeto de controle de componente

	If 	oCfgTef:oSitef:lCCCD .OR. oCfgTef:oSitef:lCheque .OR. oCfgTef:oSitef:lRC .OR. ;
		oCfgTef:oSitef:lCB .OR. oCfgTef:oSitef:lPBM
	
		lRet := .T.
	
	EndIF
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidCampo	ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method SiTefVl(oCfgTef) Class LJCCfgTef  	

	Local lValid := .T.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef		:= Nil	// Objeto de controle de componente

	
	If 	(Self:SiTefHb(oCfgTef)) 
		
		
		Do Case 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida IP     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case AllTrim(oCfgTef:oSitef:cIpAddress) == ''   // valida se Ip é vazio

				Self:cMenssagem	:= STR0029 //'SiTef - Campo Endereço Ip nao pode ser vazio'
				lValid := .F.
	
 			
 			Case !Self:oFunc:IsNumeric(AllTrim(oCfgTef:oSitef:cIpAddress),".","") // valida se o ip é valido
				
				Self:cMenssagem	:= STR0030 //'SiTef - Campo Endereço Ip invalido'
				lValid := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validação campo empresa                              ³
			//³Obs: Está usando mascara para implementar a validacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		Case !Len((Alltrim(oCfgTef:oSitef:cEmpresa)))   == 8  // Valida se empresa tem 8 caracteres

				Self:cMenssagem	:= STR0031 //'SiTef - Campo Empresa tem que ter obrigatoriamente 8 caracteres'
				lValid := .F.


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
			//³Validação campo Terminal                              ³
			//³Obs: Está usando mascara para implementar a validacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
 			Case Alltrim(oCfgTef:oSitef:cTerminal) == '' // Valida se terminal é vazia

				Self:cMenssagem	:= STR0032 //'SiTef - Campo Terminal nao pode ser vazio'
				lValid := .F.


 			Case !Len((Alltrim(oCfgTef:oSitef:cTerminal)))   == 8  // Valida se terminal é vazia

				Self:cMenssagem	:= STR0033 //'SiTef - Campo Terminal tem que ter obrigatoriamente 8 caracteres'
				lValid := .F.
		EndCase
			
	EndIF
	
Return lValid
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidCampo	ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method PayGoVl(oCfgTef) Class LJCCfgTef  	

	Local lValid := .T.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil	// Objeto de controle de componente
	
	If 	Self:PayGoHb(oCfgTef) .And. ( STFGetCfg("lMobile", .F.) == Nil .OR. !STFGetCfg("lMobile", .F.)) 
	
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida caminho da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case Trim(oCfgTef:oPayGo:cAppPath) == ''
				Self:cMenssagem	:= STR0034 //"PayGo - Campo Caminho da Aplicação nao pode ser vazio'
				lValid := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida campo de arquivo de Retorno³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case Trim(oCfgTef:oPayGo:cDirTx) == ''
			
				Self:cMenssagem	:= STR0035 //"PayGo - Campo Diretório de envio nao pode ser vazio'
				lValid := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida campo Caminho de resposta³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			Case Trim(oCfgTef:oPayGo:cDirRx) == ''
			
				Self:cMenssagem	:= STR0036 //"PayGo - Campo Diretório de reposta nao pode ser vazio'
				lValid := .F.
		EndCase
	EndIf
	

Return lValid


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiscadoVl  	ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method DiscadoVl(oCfgTef) Class LJCCfgTef  	

	Local lValid := .T.  	// Retorna se esta Habilitado ow nao
		
	Default oCfgTef	:= Nil	// Objeto de controle de componente
		
	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Discado(Visa/Amex/Redecard)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (oCfgTef:oDiscado:lGPCCCD .OR. oCfgTef:oDiscado:lGPCheque ) .AND. (Trim(oCfgTef:oDiscado:cGPAppPath) == '') 
			
			Self:cMenssagem	:= "Discado(Visa/Amex/RedecarD) - " + STR0037 //"Campo Caminho da Aplicação nao pode ser vazio'
			lValid := .F.
		Case (oCfgTef:oDiscado:lGPCCCD .OR. oCfgTef:oDiscado:lGPCheque ) .AND.  (Trim(oCfgTef:oDiscado:cGPDirTx) == '')
		
			Self:cMenssagem	:= "Discado(Visa/Amex/Redecar) - " +STR0038 //"Campo Diretório de envio nao pode ser vazio'
			lValid := .F.
		Case (oCfgTef:oDiscado:lGPCCCD .OR. oCfgTef:oDiscado:lGPCheque ) .AND. (Trim(oCfgTef:oDiscado:cGPDirRx) == '')
		
			Self:cMenssagem	:= "Discado(Visa/Amex/Redecar) - " + STR0039 //"Campo Diretório de reposta nao pode ser vazio'
			lValid := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida caminho da aplicacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (oCfgTef:oDiscado:lHiperCDCCCD)	.AND. (Trim(oCfgTef:oDiscado:cHiperCDAppPath ) == '')
			
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0037 //"Campo Caminho da Aplicação nao pode ser vazio'
			lValid := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida campo de arquivo de Retorno³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (oCfgTef:oDiscado:lHiperCDCCCD)	.AND. (Trim(oCfgTef:oDiscado:cHiperCDDirTx) == '')
		
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0038 //"Campo Diretório de envio nao pode ser vazio'
			lValid := .F.
		Case (oCfgTef:oDiscado:lHiperCDCCCD)	.AND. (Trim(oCfgTef:oDiscado:cHiperCDDirRx ) == '')
		
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0039 //"Campo Diretório de reposta nao pode ser vazio'
			lValid := .F.
		Case (oCfgTef:oDiscado:lTecBanCheque	.OR. oCfgTef:oDiscado:lTecBanCCCD) .AND. (Trim(oCfgTef:oDiscado:cTecBanAppPath ) == '')
			
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0037 //"Campo Caminho da Aplicação nao pode ser vazio'
			lValid := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida campo de arquivo de Retorno³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case (oCfgTef:oDiscado:lTecBanCheque	.OR. oCfgTef:oDiscado:lTecBanCCCD) .AND. (Trim(oCfgTef:oDiscado:cTecBanDirTx) == '')
		
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0038 //"Campo Diretório de envio nao pode ser vazio'
			lValid := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida campo Caminho de resposta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		Case (oCfgTef:oDiscado:lTecBanCheque	.OR. oCfgTef:oDiscado:lTecBanCCCD) .AND. (Trim(oCfgTef:oDiscado:cTecBanDirRx ) == '')
		
			Self:cMenssagem	:= "Discado(HiperCard) - " + STR0039 //"Campo Diretório de reposta nao pode ser vazio'
			lValid := .F.
	
	EndCase

Return lValid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TefVl     	ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±º          ³EXPC2                                                       º±±
±±º          ³Retorno                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method TefVl(oCfgTef, lRet) Class LJCCfgTef  	
	
	Default oCfgTef			:= Nil	// Objeto de controle de componente
	Default lRet            := .T.	// Retorno
	
	Self:cMenssagem := ''
	
	If !Self:SiTefVl(oCfgTef)
		lRet := .F.
	ElseIf !Self:PayGoVl(oCfgTef)
		lRet := .F.   
	ElseIf !Self:DirecaoVl(oCfgTef)
		lRet := .F.
	ElseIf !Self:DiscadoVl(oCfgTef)
	  	lRet := .F.
	ElseIf !Self:PayHubVl(oCfgTef)
	  	lRet := .F.
	Else
		lRet := .T.
	EndIF
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValSitefPbm  	ºAutor³Vendas CRM        º Data ³  06/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se a PBM esta habilitada e manipula os objetos       º±±
±±º          ³(Check Box) Epharma e Trn_Centre                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Method ValSitefPbm(oSitPBMEpha, oSitPBMTrn)  Class LJCCfgTef  	
    
    If Self:oSitef:lPBM
		oSitPBMEpha:lActive := .T.
		oSitPBMTrn:lActive := .T.
	Else
		Self:oSitef:lEpharma := .F.
		Self:oSitef:lTrnCentre := .F.
		oSitPBMEpha:lActive := .F.
		oSitPBMTrn:lActive 	:= .F.
		oSitPBMEpha:Refresh()
		oSitPBMTrn:Refresh()
    EndIf

Return Nil          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidCampo	ºAutor³Vendas CRM        º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se esta habilitado alguma funcionalidade do SiTef  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1                                                       º±±
±±º          ³Configuração Tef                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja1906a                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Method DirecaoVl(oCfgTef) Class LJCCfgTef  	

	Local lValid := .T.  	// Retorna se esta Habilitado ow nao
	
	Default oCfgTef	:= Nil	// Objeto de controle de componente
	
	If 	Self:DirecaoHb(oCfgTef)
	
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida caminho da aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case Trim(oCfgTef:oDirecao:cAppPath) == ''
				Self:cMenssagem	:= "Direção - Campo Caminho da Aplicação nao pode ser vazio" //"PayGo - Campo Caminho da Aplicação nao pode ser vazio'
				lValid := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida campo de arquivo de Retorno³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case Trim(oCfgTef:oDirecao:cDirTx) == ''
			
				Self:cMenssagem	:= "Direção - Campo Diretório de envio nao pode ser vazio" //"PayGo - Campo Diretório de envio nao pode ser vazio"
				lValid := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida campo Caminho de resposta³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			Case Trim(oCfgTef:oDirecao:cDirRx) == ''
			
				Self:cMenssagem	:= "Direcao - Campo Diretório de reposta nao pode ser vazio" //"PayGo - Campo Diretório de reposta nao pode ser vazio'
				lValid := .F.
		EndCase
	EndIf
	

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PayHubHb
Retorna se esta habilitado alguma funcionalidade do Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oCfgTef, Objeto, Objeto de representação da classe LJCCfgTef.

@return lRet, Lógico, Retorna se esta habilitado alguma funcionalidade do Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method PayHubHb(oCfgTef) Class LJCCfgTef 
	
	Local lRet := .F.
	
	Default oCfgTef	:= Nil	 	// Objeto de controle de componente

	If lUsePayHub
		If oCfgTef:oPaymentHub:lCCCD
			lRet := .T.
		EndIF
	EndIf
	
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PayHubVl
Valida configurações do Payment Hub, informadas pelo usuário.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oCfgTef, Objeto, Objeto de representação da classe LJCCfgTef.

@return lValid, Lógico, Retorna se a configuração está correta.
/*/
//-------------------------------------------------------------------------------------
Method PayHubVl(oCfgTef) Class LJCCfgTef  	

	Local lValid := .T.
	
	Default oCfgTef	:= Nil	// Objeto de controle de componente
	
	If lUsePayHub
		
		If 	Self:PayHubHb(oCfgTef)

			Do Case
				//-------------------------------------------
				// Valida se o campo Codigo da Companhia foi informado 
				//-------------------------------------------
				Case Trim(oCfgTef:oPaymentHub:cCodeComp) == ""
					Self:cMenssagem	:= STR0041 // "Deve ser informado o Código da Companhia"
					lValid := .F.
				
				//-------------------------------------------
				// Valida campo Tenant foi informado 
				//-------------------------------------------
				Case Trim(oCfgTef:oPaymentHub:cTenant) == ""
				
					Self:cMenssagem	:= STR0042 // "Deve ser informado o Tenant"
					lValid := .F.
				
				//-------------------------------------------
				// Valida campo Usuario foi informado 
				//-------------------------------------------
				Case Trim(oCfgTef:oPaymentHub:cUserName) == ""
				
					Self:cMenssagem	:= STR0043 // "Deve ser informado o Usuário"
					lValid := .F.
				
				//-------------------------------------------
				// Valida campo Senha foi informado 
				//-------------------------------------------		
				Case Trim(oCfgTef:oPaymentHub:cPassword) == ""
				
					Self:cMenssagem	:= STR0044 // "Deve ser informada a Senha"
					lValid := .F.

				//-------------------------------------------
				// Valida campo Client ID foi informado 
				//-------------------------------------------		
				Case Trim(oCfgTef:oPaymentHub:cClientId) == ""
				
					Self:cMenssagem	:= STR0045 // "Deve ser informado o Client ID"
					lValid := .F.

				//-------------------------------------------
				// Valida campo Client Secret foi informado 
				//-------------------------------------------		
				Case Trim(oCfgTef:oPaymentHub:cClientSecret) == ""
				
					Self:cMenssagem	:= STR0046 // "Deve ser informado o Client Secret"
					lValid := .F.
			EndCase

		EndIf

	EndIf

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPHSelTer
Consulta Especifica para seleção dos Terminais TEF do Payment Hub.

@type       Function
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param nOrigem, Numérico, Origem de onde está sendo chamado (1=Venda; 2=Consulta F3 Cadastro de estação)
@param oConfig, Objeto, Objeto contendo as configuracoes do Payment Hub
@param lMantemCfg, Lógico, Parametro por referência, para saber se Mantém Terminal TEF escolhido para utilizar nas próximas vendas
@param lVldTerm, Lógico, Indica se é apenas para validar se o terminal selecionado está ativo.
@param cTermSel, Caracter, Código do terminal selecionado.

@return lRet, Lógico, Retorna se foi selecionado o Terminal TEF.
/*/
//-------------------------------------------------------------------------------------
Function LjPHSelTer(nOrigem,oConfig,lMantemCfg,lVldTerm,cTermSel,lObrigat)
Local lRet 			:= .F.
Local aTerminal     := {}
Local lContinua 	:= .T.
Local oConfigTEF	:= Nil
Local cMsg			:= ""
Local lIsF3 		:= ValType(nOrigem) == "U"

Default lVldTerm 	:= .F.
Default lObrigat 	:= .F.
Default cTermSel 	:= ""

If lIsF3 //Chamado através do consula padrao F3
	nOrigem		:= 2 //2=Consulta F3 Cadastro de estação
	oConfigTEF	:= oCfgTef:oPaymentHub
Else
	oConfigTEF	:= oConfig
EndIf

//Valida se as informações obrigatorias estão alimentadas
If Empty(oConfigTEF:cCodeComp)
	cMsg += "Código da Companhia" + Chr(10)
EndIf

If Empty(oConfigTEF:cTenant)
	cMsg += "Tenant" + Chr(10)
EndIf

If Empty(oConfigTEF:cUserName)
	cMsg += "Usuário" + Chr(10)
EndIf

If Empty(oConfigTEF:cPassword)
	cMsg += "Senha" + Chr(10)
EndIf

If Empty(oConfigTEF:cClientId)
	cMsg += "Client ID" + Chr(10)
EndIf

If Empty(oConfigTEF:cClientSecret)
	cMsg += "Client Secret" + Chr(10)
EndIf

If !Empty(cMsg)
	cMsg :=  STR0047 + Chr(10) + Chr(13) + cMsg //"Não foi possível listar os terminais, pois o(s) seguinte(s) dado(s) deve(m) ser informado(s): "
	lContinua := .F.
	MsgAlert(cMsg)
EndIf

If lContinua

	If lVldTerm
		cMsg := STR0048 //"Verificando terminal..."
	Else
		cMsg := STR0049 // "Buscando terminais..."
	EndIf

	MsgRun( cMsg, STR0050, {|| aTerminal := LjPHShowTer(nOrigem,oConfigTEF,lVldTerm,cTermSel,lObrigat) } ) //"Aguarde"

	If !Empty(aTerminal)
		cTermTefPH := aTerminal[1]
		If Len(aTerminal) > 2
			lMantemCfg := aTerminal[3]
		EndIf

		If lIsF3
			oCfgTef:oPaymentHub:cIdPinPed := cTermTefPH
		EndIf
		lRet := .T.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPHShowTer
Exibe a tela para seleção do Terminal TEF do Payment Hub.

@type       Function
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param nOrigem, Numérico, Origem de onde está sendo chamado (1=Venda; 2=Consulta F3 Cadastro de estação)
@param oConfigTEF, Objeto, Objeto contendo as configuracoes do Payment Hub
@param lVldTerm, Lógico, Indica se é apenas para validar se o terminal selecionado está ativo.
@param cTermSel, Caracter, Código do terminal selecionado.

@return aRet, Array, Array com as informações do Terminal Selecionado.
/*/
//-------------------------------------------------------------------------------------
Function LjPHShowTer(nOrigem,oConfigTEF,lVldTerm,cTermSel,lObrigat)
Local aRet		 	:= {}
Local oTerminais    := Nil
Local nPosic	 	:= 0
Local lSeleciona 	:= .T.

Default lObrigat 	:= .F.

//Instacia a classe para comunicação com o Payment Hub
oTerminais := ListTerminalsPaymentHub():New(nOrigem					, oConfigTEF:cCodeComp	,;
											oConfigTEF:cTenant		, oConfigTEF:cUserName	,;
											oConfigTEF:cPassword	, oConfigTEF:cClientId	,;
											oConfigTEF:cClientSecret )

If ValType( oTerminais) == "O"

	If lVldTerm .And. !Empty(cTermSel)
		aRet 		:= oTerminais:GetTerminals() //Retorna todos os terminais ativos
		nPosic 		:= aScan(aRet,{|x| AllTrim(x[1]) == AllTrim(cTermSel) })
		
		If nPosic == 0
			MsgAlert(STR0051 + cTermSel + STR0052 ) // "O terminal " // " não está ativo. Deve ser selecionado um terminal que esteja ativo."
		Else
			lSeleciona := .F. //Nao abre a tela para seleção de Terminal, pois o terminal escolhido pelo caixa está ativo
			aRet := aRet[nPosic]
		EndIf
	EndIf

	If lSeleciona
		//Exite a tela para seleção dos terminais TEF que estão ligados e conectados no momento
		oTerminais:ShowScreen(lObrigat)

		//Resgata o Terminal que foi selecionado
		aRet := oTerminais:RetSelectdTerminal()
	EndIf
Else
	MsgAlert(STR0053) // "Não foi possível validar os terminais ativos."
EndIf

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPHGetTer
Retorna o Terminal TEF selecionado pela consulta especifica (TTEFPH).

@type       Function
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return cTermTefPH, Caracter, Retorna o Terminal TEF selecionado pela consulta especifica.
/*/
//-------------------------------------------------------------------------------------
Function LjPHGetTer()
Return cTermTefPH
