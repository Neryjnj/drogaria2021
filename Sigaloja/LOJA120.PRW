#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA120.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

Static aColsEx := {}
Static oGetSang := Nil
Static lEncript := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ loja120  ³ Autor ³ Vendas Clientes       ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Personalizacao do Perfil/ do caixa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA120()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Configura o perfil do caixa                           ³
//³    4 - Replica as informacoes do caixa para outro caixa      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0004 // Configuracao do Usuario

DbSelectArea("SLF")
DbSetOrder(1)
MsSeek(xFilial("SLF"))
mBrowse( 6, 1,22,75,"SLF")

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina:= { 		{STR0001, "AxPesqui", 0, 1 , , .F.},;   // Pesquisar
						{STR0002, "AxVisual", 0, 2 , , .T.},;   // Visualizar
						{STR0078, "A120CFG(.F.)" , 0, 2 , , .T.},;   // Alterar
						{STR0025, "LJXRPL"  , 0, 2 , , .T.} }   // Replicar ->Funcao Generica no LOJXFUNA.PRX

Return(ARotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ120CFG ³ Autor ³ Vendas Clientes       ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Interface dos Folder de Perfil e Permisao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a120CFG(lWizard,cCodUser)

//Objetos Dialog Principal
Local oDlg
Local oDlgPsw
Local oFrontLoja
Local oMultimidia
Local oAllAcesso
Local oLogErro
Local oLogConf
Local oLogMonit
Local oLogRec
Local oDescPer
Local oDescVal   
Local oCaixa 
Local oLimit1
Local oLimit2
Local oTotPerDesc
Local oTotValDesc   
Local oRadOpDesc

Local lFrontLoja	:= .T.				  				// Acionamento automatico Front Loja
Local lMultimidia	:= .F.				  				// Acionamento automatico Multimidia
Local lAllAcesso	:= .T.				  				// Todos os acessos
Local lLogErro		:= .F.				  				// Log Erro
Local lLogConf		:= .T.				  				// Confirmacao exclusao
Local lLogMonit		:= .T.				  				// Monitoramento
Local lLogRec		:= .T.				   				// Recuperacao
Local lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)	// Integra com cenario de vendas

Local nDescPer		:= 0					// Percentual Desconto
Local nDescVal		:= 0					// Valor Desconto
Local nBoxC1		:= 10					// Posicao Tela
Local nBoxC2		:= 213					// Posicao Tela
Local nOpDesc		:= 2

Local aAcesso		:= {}					// Array com os acessos
Local aRadOpDesc 	:= {STR0108, STR0109} 	// "Prioriza a regra de descontos" //"Prioriza configuração do caixa"

Local oTpVal								// Objeto para o tipo de validacao
Local cTpVal		:= ""					// Variavel selecionada no combo
Local aTpVal		:= {}					// Tipos de Validacoes de senha
Local cLF_TPVAL 	:= ""	                // Conteudo do Campo LF_TPVAL

Local oNumCart								// Objeto para o numero do cartao
Local cNumCart		:= ""																		// Campo LF_NUMCART
Local aPpVal	  	:= RetSx3Box( Posicione("SX3", 2, PadR("LF_TPVAL",10), "X3CBox()" ),,, 1 )	// Propriedades do campo LF_TPVAL
Local lCLocR5		:= cPaisLoc$"CHI|COL"														// Localização chile e colombia 

// Verifica se os campos para validacao de máximo de permissão de desconto para o Total foram criados. OBS: Adicionado inicio R 11.8
Local nTotPerDesc	:= 0							// Máximo percentual permitido para desconto no total
Local nTotValDesc	:= 0							// Máximo Valor permitido paraq desconto no total

//usados somente se a Integracao Protheus x SIAC esta ativa
Local lIntSiac		:= SuperGetMV("MV_SCINTEG",,.F.)// Indica se a integracao Protheus x SIAC esta ativa
Local oOpSiac		:= Nil							// Contem o objeto Get do codigo de operador SIAC
Local cOpSiac		:= ""							// Contem o valor digitado no Get(oOpSiac)
Local cCRFUser		:= Space(5)						// Para usuário que será farmaceutico, informar o CRF
Local cCPFUser		:= Space(14)					// Para usuário qualquer usuário caixa, informar o CRF
Local aForms 		:= STDFormsPay()				// Forma de pagamento da tabela 24 da SX5
Local nI 			:= 0							// Contador
Local aCab 			:= {}							// Array do cabeçalho da getDados
Local aHeader 		:= {}							// aHeader da GetDados		
Local oSay 			:= Nil							// Say da aba Controle de Sangria
Local oCopy 		:= Nil							// ComboBox para copia do Caixa
Local aCxSLF 		:= {}							// Array com todos os caixas
Local cCmbCopy 		:= ""    						// Campo da copia do Caixa
Local aCaixa		:= {}     						// Array com os Caixas 
Local oBtnCPPed 	:= Nil							// Objeto Botão de comunicação com PinPad 
Local lPOS  		:= STFIsPOS() 					//Indica se é TOTVS PDV
Local cBkpCart		:= ""							// Backup com numero do cartão

DEFAULT lWizard 	:= .F.
DEFAULT cCodUser 	:= ""

If lWizard
	// Se a rotina for executada diferente da rotina LOJA120, sempre apresentará o Wizard
	// Efetua o posicionamento das tabelas
	DbSelectArea("SLF")
	DbSetOrder(1)
	dbSeek(xFilial("SLF")+cCodUser)
	// Alimenta as variaveis
	cCodUser  := SLF->LF_COD			//Codigo do usuario
	nBoxC1		:= 10					//Posicao Tela especifico para o Wizard via configurador 
	nBoxC2		:= 280					//Posicao Tela especifico para o Wizard via configurador
Else
	cCodUser	:= SLF->LF_COD			//Codigo do usuario
Endif

// Alimenta o array aTpVal
aEval( aPpVal, {|x| If(!Empty(x[3]), AAdd(aTpVal, x[3]), NIL) } )

DbSelectArea("SA6")
DbSetOrder(1)
dbseek(xFilial("SA6")+cCodUser)
cUser       := SA6->A6_NOME
nDescPer    := SLF->LF_DESCPER
nDescVal    := SLF->LF_DESCVAL
lLogErro    := Subs(SLF->LF_LOGERRO,1,1) == "S"
lLogConf    := Subs(SLF->LF_LOGERRO,2,1) == "S"
lLogMonit   := Subs(SLF->LF_LOGERRO,3,1) == "S"
lLogRec     := Subs(SLF->LF_LOGERRO,4,1) == "S"
lFrontLoja  := (SLF->LF_FRTAUTO=="S")
lMultimidia := (SLF->LF_MULTIMI=="S")
nTotPerDesc	:= SLF->LF_TOTDESP
nTotValDesc	:= SLF->LF_TOTDESV

//³Carrega a opcao de desconto selecionada para o caixa:      
//³1-Prioriza o desconto do caixa                             
//³2-Prioriza o desconto da regra de descontos (quando houver)
If lCenVenda .AND. SLF->LF_OPCDESC > 0
	nOpDesc	:= SLF->LF_OPCDESC
EndIf

cLF_TPVAL	:= SLF->LF_TPVAL
cNumCart	:= IIF(Empty(SLF->LF_NUMCART),Space(TamSX3("LF_NUMCART")[1]),SLF->LF_NUMCART) 
cBkpCart	:= cNumCart

If !cLF_TPVAL $ "123"
	cLF_TPVAL := "1"
EndIf

If !Empty(cLF_TPVAL)
	LJ120Val(.T., @cTpVal, @cLF_TPVAL, aPpVal)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se a integracao Protheus x SIAC estiver ativa,        ³
//³alimenta a variavel com o conteudo do campo LF_CODSIAC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntSiac
	cOpSiac := SLF->LF_CODSIAC
EndIf

If lWizard // Proveniente do Configurador segue a tela do Wizard.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definição principal da tela do Wizard do caixa  	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DEFINE WIZARD oDlgPsw TITLE STR0006 HEADER STR0006 MESSAGE STR0006	TEXT " "; // Configuracao do Caixa
	FINISH {|| .T. } NOFIRSTPANEL	PANEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 1 )  -  Configuração do Caixa         	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oDlgPsw:GetPanel(1)
	
	@ 005,nBoxC1 TO 50,nBoxC2 PROMPT STR0004 OF oDlgPsw:GetPanel(1) PIXEL   // Caixa
	
	@ 015,015  SAY  STR0008		    	OF oDlgPsw:GetPanel(1) PIXEL // Codigo
	@ 030,015  MSGET  oCodUser VAR cCodUser SIZE 20,9 of oDlgPsw:GetPanel(1) PIXEL READONLY
	@ 015,085  SAY  STR0009				OF oDlgPsw:GetPanel(1) PIXEL // Nome
	@ 030,085  MSGET  oUser VAR cUser      SIZE 140,9 of oDlgPsw:GetPanel(1) PIXEL READONLY

	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		@ 0055,nBoxC1 TO 125,nBoxC2 PROMPT STR0161 OF oDlgPsw:GetPanel(1) PIXEL   //"Farmaceutico/Operador"		
		@ 070,015  SAY  STR0162   	OF oDlgPsw:GetPanel(1) PIXEL //"CRF (Registro Farmaceutico)" 
		@ 080,015  MSGET  oCRFUser VAR cCRFUser SIZE 50,9 of oDlgPsw:GetPanel(1) PIXEL //READONLY
		//@ 065,085  SAY  "Responsável técnico "				OF oDlgPsw:GetPanel(1) PIXEL // Nome
		//@ 080,085  MSGET  oUser VAR cUser      SIZE 140,9 of oDlgPsw:GetPanel(1) PIXEL READONLY
	
		@ 100,015  SAY  "CPF"+Space(23)   	OF oDlgPsw:GetPanel(1) PIXEL 
		@ 110,015  MSGET  oCpfUser VAR cCPFUser PICTURE PesqPict("SA2","A2_CPFIRP ") SIZE 50,9 of oDlgPsw:GetPanel(1) PIXEL //READONLY
	EndIf	
	
	oCodUser:Disable() 	// Desabilita a edição das Get
	oUser:Disable()		// Desabilita a edição das Get
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 2 )  -  Perfil							³
	//³ Descontos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Criação do 2º - Painel
	nAtAux := At("&", STR0010)
	CREATE PANEL oDlgPsw  HEADER SubStr(STR0010,1,nAtAux-1) + SubStr(STR0010,nAtAux+1,Len(STR0010)) ;  	//"Perfil do caixa"
	MESSAGE STR0012 ; 					//"Descontos "
	BACK {|| .T. } ;
	FINISH {|| .F.} PANEL
	
	oDlgPsw:GetPanel(2)
	// Box que abrirá o grupo de descontos
	@005,nBoxC1 TO 50,nBoxC2 PROMPT STR0012 OF oDlgPsw:GetPanel(2) PIXEL   // Descontos	 
	    
	/// Maximo Permissao desconto no Item
	@20,15 SAY "Desc. Item %" OF oDlgPsw:GetPanel(2) PIXEL                // RONDON --> Cadastrar STR
	@19,55 MSGET oDescPer VAR nDescPer PICTURE "99.99" VALID (nDescPer < 100 .AND. nDescPer >= 0) ;
	PIXEL SIZE 15,9 OF oDlgPsw:GetPanel(2)		
	
	@35,15 SAY "Desc. Item " + SuperGetMv("MV_SIMB1") OF oDlgPsw:GetPanel(2) PIXEL	// RONDON --> Cadastrar STR
	@34,55 MSGET oDescVal VAR nDescVal PICTURE PesqPict("SLF","LF_DESCVAL") VALID nDescVal >= 0 ;
	WHEN nOpDesc == 2 PIXEL SIZE 50,9 OF oDlgPsw:GetPanel(2) 
	
	// Maximo Permissao desconto no Total		
	@20,125 SAY "Desc. Total " + "%" OF oDlgPsw:GetPanel(2) PIXEL                // RONDON --> Cadastrar STR
	@19,175 MSGET oTotPerDesc VAR nTotPerDesc PICTURE "99.99" VALID (nTotPerDesc < 100 .AND. nTotPerDesc >= 0) ;
	PIXEL SIZE 15,9 OF oDlgPsw:GetPanel(2)		

	@35,125 SAY "Desc. Total " + SuperGetMv("MV_SIMB1") OF oDlgPsw:GetPanel(2) PIXEL	// RONDON --> Cadastrar STR
	@34,175 MSGET oTotValDesc VAR nTotValDesc PICTURE PesqPict("SLF","LF_DESCVAL") VALID nTotValDesc >= 0 ;
	PIXEL SIZE 50,9 OF oDlgPsw:GetPanel(2)
	
	If lCenVenda
	
		@055,nBoxC1 TO 105,nBoxC2 PROMPT STR0110 OF oDlgPsw:GetPanel(2) PIXEL //"Opção de desconto"

		@70,15 RADIO oRadOpDesc VAR nOpDesc ITEMS aRadOpDesc[1],aRadOpDesc[2] SIZE 90,8 PIXEL OF oDlgPsw:GetPanel(2);
	         ON CHANGE	(Iif(nOpDesc==1,;
	         	   			(oDescVal:Disable(),oDescPer:Disable()),;
	         	  			(oDescVal:Enable(),oDescPer:Enable())),;
	         	   		(oDescVal:Refresh(),oDescPer:Refresh()))
	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 3 )  -  Perfil							³
	//³ Monitoramento  Erros com Logs                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Criação do 3º - Painel
	CREATE PANEL oDlgPsw  HEADER SubStr(STR0010,1,nAtAux-1) + SubStr(STR0010,nAtAux+1,Len(STR0010)) ;  	//"Perfil do caixa"
	MESSAGE STR0015 ; 					//"Monitoramento - Erros com Log's"
	BACK {|| .T. } ;
	FINISH {|| .F.} PANEL
	
	oDlgPsw:GetPanel(3)
	// Box que abrirá o grupo de Log desejaveis na configuração
	@ 005,nBoxC1 TO 80,nBoxC2 PROMPT STR0015 OF oDlgPsw:GetPanel(3) PIXEL	// Log's
	
	@ 020,20 CHECKBOX oLogErro VAR lLogErro PROMPT STR0016 SIZE 120, 09 ; // Erros
	OF oDlgPsw:GetPanel(3) PIXEL ;
	ON CHANGE {|| lj0120Muda(lLogErro,@oLogConf,@oLogMonit,@oLogRec)}
	
	@ 035,30 CHECKBOX oLogConf VAR lLogConf PROMPT STR0017 SIZE 120, 09 ;   // Confirmação para apagar Registros
	OF oDlgPsw:GetPanel(3) PIXEL WHEN lLogErro
	
	@ 050,30 CHECKBOX oLogMonit VAR lLogMonit PROMPT STR0018 SIZE 120, 09 PIXEL ;  // Monitoramento
	OF oDlgPsw:GetPanel(3) PIXEL WHEN lLogErro
	
	@ 065,30 CHECKBOX oLogRec VAR lLogRec PROMPT STR0019 SIZE 120, 09 PIXEL;  // Recuperação
	OF oDlgPsw:GetPanel(3) PIXEL WHEN lLogErro
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 4 )  -  Perfil							³
	//³ Front Loja              							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Criação do 4º - Painel
	CREATE PANEL oDlgPsw  HEADER SubStr(STR0010,1,nAtAux-1) + SubStr(STR0010,nAtAux+1,Len(STR0010)) ;  	//"Perfil do caixa"
	MESSAGE STR0020 ; 					//"Front Loja
	BACK {|| .T. } ;
	FINISH {|| .F.} PANEL
	
	oDlgPsw:GetPanel(4)
	// Box para o Front Loja
	@ 005,nBoxC1 TO 50,nBoxC2 PROMPT STR0020 OF oDlgPsw:GetPanel(4) PIXEL // Front Loja
	
	@ 020,15 CHECKBOX oFrontLoja VAR lFrontLoja PROMPT STR0021 SIZE 120, 09 OF oDlgPsw:GetPanel(4) PIXEL ; // Front Loja Automatico
	ON CHANGE {|| If(lMultimidia, lMultimidia := .F.,.T.), oMultimidia:Refresh()}
	
	@ 035,15 CHECKBOX oMultimidia VAR lMultimidia PROMPT STR0055 SIZE 130, 09 OF oDlgPsw:GetPanel(4) PIXEL ; // Front Loja Automatico
	ON CHANGE {|| If(lFrontLoja, lFrontLoja := .F.,.T.), oFrontLoja:Refresh()}
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 5 )  -  Permissões  						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAtAux := At("&", STR0011)
	CREATE PANEL oDlgPsw  HEADER SubStr(STR0011,1,nAtAux-1) + SubStr(STR0011,nAtAux+1,Len(STR0011)) ;  	//"Permissões"
	MESSAGE STR0011 ; 					//"Permissões"
	BACK {|| .T. } ;
	FINISH {|| .F.} PANEL
	
	oDlgPsw:GetPanel(5)
	
	aAcesso := Lj120Acesso(aAcesso,SLF->LF_ACESSO,@lAllAcesso)
	
	oSim   := LoadBitmap(GetResources(), "BR_VERDE")
	oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")
	oSuper := LoadBitmap(GetResources(), "BR_AMARELO")
	
	@05,10 LISTBOX oAcesso FIELDS HEADER "", STR0022 FIELDSIZES 14,170,15 SIZE 270,095 PIXEL OF oDlgPsw:GetPanel(5) // Processos / Sup
	oAcesso:SetArray(aAcesso)
	oAcesso:bLine := {|| {If(aAcesso[oAcesso:nAt,1]=="S",oSim,If(aAcesso[oAcesso:nAt,1]=="N",oNao,oSuper)),;
	aAcesso[oAcesso:nAt,2]}}
	If lCLocR5
		oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:= If (aAcesso[oAcesso:nAt,4]== 3 .OR. aAcesso[oAcesso:nAt,4]== 28,aAcesso[oAcesso:nAt,1] := VAlLocR5(aAcesso[oAcesso:nAt,1],aAcesso[oAcesso:nAt,4]),;
		If(aAcesso[oAcesso:nAt,1]=="S","N",If(aAcesso[oAcesso:nAt,1]=="N","X","S"))),;
		oAcesso:DrawSelect(),;
		lAllAcesso:=.T.,;
		AEval(aAcesso, {|aLinha| lAllAcesso:=If(lAllAcesso.And.aLinha[1]=="S",.T.,.F.)}),;
		oAllAcesso:Refresh()}
	Else    
		oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:=If(aAcesso[oAcesso:nAt,1]=="S","N",If(aAcesso[oAcesso:nAt,1]=="N","X","S")),;
		oAcesso:DrawSelect(),;
		lAllAcesso:=.T.,;
		AEval(aAcesso, {|aLinha| lAllAcesso:=If(lAllAcesso.And.aLinha[1]=="S",.T.,.F.)}),;
		oAllAcesso:Refresh()}
	EndIf
	
	@120,10 CHECKBOX oAllAcesso VAR lAllAcesso PROMPT STR0023 SIZE 80, 09 PIXEL ; // Todos acessos
	ON CLICK  (MarkAll(lAllAcesso,@aAcesso ),oAcesso:Refresh()) ;
	OF oDlgPsw:GetPanel(5)

	@107,100 BITMAP NAME "BR_VERDE"		SIZE 7,7 OF oDlgPsw:GetPanel(5) PIXEL NO BORDER
	@115,100 BITMAP NAME "BR_VERMELHO"	SIZE 7,7 OF oDlgPsw:GetPanel(5) PIXEL NO BORDER
	@123,100 BITMAP NAME "BR_AMARELO"	SIZE 7,7 OF oDlgPsw:GetPanel(5) PIXEL NO BORDER
	@107,110 SAY STR0049 OF oDlgPsw:GetPanel(5) PIXEL SIZE 100,7	// "Acesso Liberado"
	@115,110 SAY STR0050 OF oDlgPsw:GetPanel(5) PIXEL SIZE 100,7	// "Acesso Negado"
	@123,110 SAY STR0051 OF oDlgPsw:GetPanel(5) PIXEL SIZE 100,7	// "Liberado Mediante Autorização Superior"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel  ( 6 )  -  Validações permissões  			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oDlgPsw  HEADER STR0099 ;  	//"Permissões"
	MESSAGE STR0099 ; 				  			//"Permissões"
	BACK {|| .T. } ;
	FINISH {|| .T. } PANEL
	
	oDlgPsw:GetPanel(6)
	
	@ 005,nBoxC1 TO 050,nBoxC2 PROMPT STR0099 PIXEL OF oDlgPsw:GetPanel(6)		// Autorizacao Superior
	
	@ 20,15 SAY STR0100 PIXEL SIZE 50,9 OF oDlgPsw:GetPanel(6)						// "Tipo Validacao"
	@ 19,60 COMBOBOX oTpVal VAR cTpVal ITEMS aTpVal PIXEL SIZE 40,9 ;
	ON CHANGE LJ120Val(.F., @cTpVal, @cLF_TPVAL, aPpVal) OF oDlgPsw:GetPanel(6)
	
	@ 37,15 SAY STR0101 PIXEL SIZE 50,9 OF oDlgPsw:GetPanel(6)						// "Cartao Superior"
	//Busca Senha do Cartão Obs:Não é necessario Tratar  TOTVS PDV pois a criação de usuario esta bloqueada no PDV	
	oBtnCPPed := TButton():New(34,130,STR0172,oDlgPsw:GetPanel(6),{|| cNumCart := LjGetCart(0)},50,13,,,,.T.,,,,)//##"Ler PinPad"##	
																																		
	@ 36,60 MSGET oNumCart  VAR cNumCart PASSWORD ;
	PIXEL SIZE 65,9 OF oDlgPsw:GetPanel(6)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Painel (7) Cadastro para limite de sangria
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	CREATE PANEL oDlgPsw  HEADER STR0150; //Cadastro de Limites para Sangria
	MESSAGE STR0151 ; 					//"Sangria"
	BACK {|| .T. } ;
	FINISH {|| .T. } PANEL
	
		// Pego todos os caixas exceto o que esta sendo alterado
	DbSelectArea("SLF")
	DbSetOrder(1)
	
	cCodigo := SLF->LF_COD	
	
	
	Aadd(  aCxSLF,"")
	SLF->(dbGoTop())
	While !EOF() 
		If cCodigo <> SLF->LF_COD
			Aadd(  aCxSLF,SLF->LF_COD)
		EndIf
		DbSkip() 
	End

	
	//copiar valores de limite de sangria
	oSay := TSay():New(123,10,{||STR0152},oDlgPsw:GetPanel(7),,,,,,.T.,CLR_RED,CLR_WHITE,90,20) //"Copiar limite de sangria do Caixa:"
	@122,96 COMBOBOX oCopy VAR cCmbCopy ITEMS aCxSLF PIXEL SIZE 40,9 ON CHANGE Lj120AltGet(cCmbCopy) OF oDlgPsw:GetPanel(7)	
	
	oDlgPsw:GetPanel(7)
	
	LJ120Sang(lWizard, oDlgPsw, cCodUser)
	ACTIVATE WIZARD oDlgPsw CENTERED  WHEN {||.T.};
		VALID {|| LJ120OK(	aAcesso		,	lLogErro		,	lLogConf		,	lLogMonit	,;
				   			lLogRec		,	lFrontLoja		,	SA6->A6_COD		,	nDescPer	,;
							nDescVal	,	lMultimidia		,	cLF_TPVAL		,	cNumCart	,;
							nOpDesc		,	Nil				,	Nil				,	nTotPerDesc	,;
							nTotValDesc	)}

Else // Tela do Caixa no modulo do Sigaloja
	
	DEFINE MSDIALOG oDlgPsw TITLE STR0006 FROM 0,0 TO 540,460 OF oDlg PIXEL // Configuracao do Caixa
	
	@05,05 TO 45,225 PROMPT STR0007 PIXEL                                   // Caixa
	@13,10 SAY STR0008 PIXEL                                                // Codigo
	@13,35 GET cCodUser PIXEL SIZE 20,9 WHEN .F.
	
	@28,10 SAY STR0009 PIXEL                                                // Nome
	@28,35 GET cUser PIXEL SIZE 140,9 WHEN .F.
	
	//se ativo, adiciona um Get na tela de configuracao de caixa do SIGALOJA
	If lIntSiac
		@ 013,085 SAY STR0139 PIXEL //Operador SIAC
		@ 013,125 MSGET oOpSiac VAR cOpSiac SIZE 20,9 PIXEL
	EndIf

	@50,05 FOLDER oFolder OF oDlgPsw PROMPTS STR0010,STR0011, STR0098, STR0153 PIXEL SIZE 220,190 // Perfil, Permissao, Validacao, Limite Sangria 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 1 - Perfil											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@05,nBoxC1 TO 75,nBoxC2 PROMPT STR0012 PIXEL OF oFolder:aDialogs[1]    // Descontos
	
	// Máximo permissao ITEM
	@14,14 SAY "Desc. Item %" PIXEL SIZE 50,9 OF oFolder:aDialogs[1] // RONDON --> Cadastrar STR
	@13,55 MSGET oDescPer VAR nDescPer PICTURE "99.99" VALID (nDescPer<100 .AND. nDescPer>=0) PIXEL SIZE 15,9 OF oFolder:aDialogs[1]
	
	@29,14 SAY "Desc. Item " + SuperGetMv("MV_SIMB1") PIXEL SIZE 50,9 OF oFolder:aDialogs[1]        // RONDON --> Cadastrar STR
	@28,55 MSGET oDescVal VAR nDescVal PICTURE PesqPict("SLF","LF_DESCVAL") VALID nDescVal>=0 PIXEL SIZE 50,9 OF oFolder:aDialogs[1]
	
	// Máximo Permissão TOTAL                 		
	@43,14 SAY "Desc. Total " + "%" PIXEL SIZE 50,9 OF oFolder:aDialogs[1]              // RONDON --> Cadastrar STR
	@44,55 MSGET oTotPerDesc VAR nTotPerDesc PICTURE "99.99" VALID (nTotPerDesc < 100 .AND. nTotPerDesc >=0 ) PIXEL SIZE 15,9 OF oFolder:aDialogs[1]

	@59,14 SAY "Desc. Total " + SuperGetMv("MV_SIMB1") PIXEL SIZE 50,9 OF oFolder:aDialogs[1]              // RONDON --> Cadastrar STR
	@60,55 MSGET oTotValDes VAR nTotValDesc PICTURE PesqPict("SLF","LF_DESCVAL") VALID nTotValDesc>=0 PIXEL SIZE 50,9 OF oFolder:aDialogs[1]
	
	If lCenVenda
		@20,115 RADIO oRadOpDesc VAR nOpDesc ITEMS aRadOpDesc[1],aRadOpDesc[2] SIZE 90,8 PIXEL OF oFolder:aDialogs[1];
	         ON CHANGE	(Iif(nOpDesc==1,;
	         	   			(oDescVal:Disable(),oDescPer:Disable()),;
	         	  			(oDescVal:Enable(),oDescPer:Enable())),;
	         	   		(oDescVal:Refresh(),oDescPer:Refresh()))
	EndIf
	
	@82,nBoxC1 TO 135,nBoxC2 PROMPT STR0015 PIXEL OF oFolder:aDialogs[1]     // Log's
	
	@92,10 CHECKBOX oLogErro VAR lLogErro PROMPT STR0016 SIZE 120, 09 PIXEL;  // Erros
	OF oFolder:aDialogs[1];
	ON CHANGE {|| lj0120Muda(lLogErro,@oLogConf,@oLogMonit,@oLogRec)}
	
	@102,20 CHECKBOX oLogConf VAR lLogConf PROMPT STR0017 SIZE 120, 09 PIXEL ;  // Confirmacao para Apagar Registros
	OF oFolder:aDialogs[1];
	WHEN lLogErro
	
	@112,20 CHECKBOX oLogMonit VAR lLogMonit PROMPT STR0018 SIZE 120, 09 PIXEL ; // Monitoramento
	OF oFolder:aDialogs[1];
	WHEN lLogErro
	
	@122,20 CHECKBOX oLogRec VAR lLogRec PROMPT STR0019 SIZE 120, 09 PIXEL ;     // Recuperacao
	OF oFolder:aDialogs[1];
	WHEN lLogErro
	
	@137,nBoxC1 TO 167,nBoxC2 PROMPT STR0020 PIXEL OF oFolder:aDialogs[1]       // Front Loja
	@145,10 CHECKBOX oFrontLoja VAR lFrontLoja PROMPT STR0021 SIZE 120, 09 PIXEL ; // Front-Loja Automatico
	OF oFolder:aDialogs[1];
	ON CHANGE {|| If(lMultimidia, lMultimidia := .F.,.T.), oMultimidia:Refresh()}
	
	@153,10 CHECKBOX oMultimidia VAR lMultimidia PROMPT STR0055 SIZE 130, 09 PIXEL ; // Front-Loja Automatico
	OF oFolder:aDialogs[1];
	ON CHANGE {|| If(lFrontLoja, lFrontLoja := .F.,.T.), oFrontLoja:Refresh()}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 2 - Permisao									        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAcesso := Lj120Acesso(aAcesso,SLF->LF_ACESSO,@lAllAcesso)
	
	oSim   := LoadBitmap(GetResources(), "BR_VERDE")
	oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")
	oSuper := LoadBitmap(GetResources(), "BR_AMARELO")
	
	@05,10 LISTBOX oAcesso FIELDS HEADER "", STR0022 FIELDSIZES 14,170,15 SIZE 200,100 PIXEL OF oFolder:aDialogs[2] // Processos / Sup
	oAcesso:SetArray(aAcesso)
	oAcesso:bLine := {|| {If(aAcesso[oAcesso:nAt,1]=="S",oSim,If(aAcesso[oAcesso:nAt,1]=="N",oNao,oSuper)),;
	aAcesso[oAcesso:nAt,2]}}
	If lCLocR5
		oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:= If (aAcesso[oAcesso:nAt,4]== 3 .OR. aAcesso[oAcesso:nAt,4]== 28,aAcesso[oAcesso:nAt,1] := VAlLocR5(aAcesso[oAcesso:nAt,1],aAcesso[oAcesso:nAt,4]),;
		If(aAcesso[oAcesso:nAt,1]=="S","N",If(aAcesso[oAcesso:nAt,1]=="N","X","S"))),;
		oAcesso:DrawSelect(),;
		lAllAcesso:=.T.,;
		AEval(aAcesso, {|aLinha| lAllAcesso:=If(lAllAcesso.And.aLinha[1]=="S",.T.,.F.)}),;
		oAllAcesso:Refresh()}
	Else    
		oAcesso:bLDblClick := {|| aAcesso[oAcesso:nAt,1]:=If(aAcesso[oAcesso:nAt,1]=="S","N",If(aAcesso[oAcesso:nAt,1]=="N","X","S")),;
		oAcesso:DrawSelect(),;
		lAllAcesso:=.T.,;
		AEval(aAcesso, {|aLinha| lAllAcesso:=If(lAllAcesso.And.aLinha[1]=="S",.T.,.F.)}),;
		oAllAcesso:Refresh()}
	EndIf
	
	@120,10 CHECKBOX oAllAcesso VAR lAllAcesso PROMPT STR0023 SIZE 80, 09 PIXEL ; // Todos acessos
	ON CLICK  (MarkAll(lAllAcesso,@aAcesso ),oAcesso:Refresh()) ;
	OF oFolder:aDialogs[2]
	
	@107,100 BITMAP NAME "BR_VERDE"		SIZE 7,7 OF oFolder:aDialogs[2] PIXEL NO BORDER
	@115,100 BITMAP NAME "BR_VERMELHO"	SIZE 7,7 OF oFolder:aDialogs[2] PIXEL NO BORDER
	@123,100 BITMAP NAME "BR_AMARELO"	SIZE 7,7 OF oFolder:aDialogs[2] PIXEL NO BORDER
	@107,110 SAY STR0049 OF oFolder:aDialogs[2] PIXEL SIZE 100,7	// "Acesso Liberado"
	@115,110 SAY STR0050 OF oFolder:aDialogs[2] PIXEL SIZE 100,7	// "Acesso Negado"
	@123,110 SAY STR0051 OF oFolder:aDialogs[2] PIXEL SIZE 100,7	// "Liberado Mediante Autorização Superior"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 3 - Validacao									    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@05,nBoxC1 TO 45,nBoxC2 PROMPT STR0099 PIXEL OF oFolder:aDialogs[3]				// Autorizacao Superior
	
	@14,10 SAY STR0100 PIXEL SIZE 50,9 OF oFolder:aDialogs[3]						// "Tipo Validacao"
	@13,55 COMBOBOX oTpVal VAR cTpVal ITEMS aTpVal PIXEL SIZE 40,9 ON CHANGE LJ120Val(.F., @cTpVal, @cLF_TPVAL, aPpVal) OF oFolder:aDialogs[3]
	
	@29,10 SAY STR0101 PIXEL SIZE 50,9 OF oFolder:aDialogs[3]						// "Cartao Superior"
	
	If !lPOS
		oBtnCPPed := TButton():New(28,130,STR0172,oFolder:aDialogs[3],{|| cBkpCart := cNumCart, cNumCart := LjGetCart(0), Iif(Empty(cNumCart),cNumCart := cBkpCart,Nil) },50,13,,,,.T.,,,,)//##"Ler PinPad"##	//Busca Senha do Cartão		
	EndIf 
	
	@28,55 MSGET oNumCart VAR cNumCart PASSWORD PIXEL SIZE 65,9 OF oFolder:aDialogs[3]

	// Pego todos os caixas exceto o que esta sendo alterado
	DbSelectArea("SLF")
	DbSetOrder(1)
	
	cCodigo := SLF->LF_COD	
	
	SLF->(dbGoTop())
	Aadd(  aCxSLF,"")
	While !EOF() 
		If cCodigo <> SLF->LF_COD
			Aadd(  aCxSLF,SLF->LF_COD)
		EndIf
		DbSkip() 
	End

	
	// copiar valores de limite de sangria
	oSay := TSay():New(156,05,{||STR0152},oFolder:aDialogs[4],,,,,,.T.,CLR_RED,CLR_WHITE,90,20) //"Copiar limite de sangria do Caixa:"
	@155,90 COMBOBOX oCopy VAR cCmbCopy ITEMS aCxSLF PIXEL SIZE 40,9 ON CHANGE Lj120AltGet(cCmbCopy) OF oFolder:aDialogs[4]
	
	DEFINE SBUTTON FROM	242,168 TYPE 1 ENABLE OF oDlgPsw;
		ACTION ( LJ120OK(	aAcesso		,	lLogErro	, lLogConf		, lLogMonit		,;
							lLogRec		,	lFrontLoja	, SA6->A6_COD	, nDescPer		,;
							nDescVal	,	lMultimidia	, cLF_TPVAL		, cNumCart		,;
							nOpDesc		,	lIntSiac	, cOpSiac	  	, nTotPerDesc	,;
							nTotValDesc , 				, cBkpCart		)				,;
	oDlgPsw:End())
	
	DEFINE SBUTTON FROM 242,197 TYPE 2 ENABLE OF oDlgPsw ACTION oDlgPsw:End()
	
	LJ120Sang(.F., NIL, cCodUser) 
	ACTIVATE DIALOG oDlgPsw CENTERED
	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ120Permi ³ Autor ³ Vendas Clientes     ³ Data ³05/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o array de Permissoes                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj120Permi()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ120Permi()
Local lCrd 		:= .F.	//Verifica se tem integracao com o crd
Local lCLocR5	:= 	cPaisLoc$"CHI|COL"	//Localização chile e colombia 
//Verifica se a funcionalidade Lista de Presente esta ativa e aplicada
Local lUsaLstPre	:= SuperGetMV("MV_LJLSPRE",,.F.) .And. LjUpd78Ok()
//Verifica se o parâmetro de Integração com o Financial Service está habilidado
Local lUsaIntFS	:= SuperGetMV("MV_LJINTFS",,.F.) .And. LjUpd90Ok() //Verifica se o ambiente esta com os componentes atualizados para análise de credito
Local lSFinanc	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro

//  1 - Analise de credito   										Verificacao do caixa se tem analise de credito 				Tem analise de credito
//  2 - Usa TEF              										Caixa tem acesso a utilizar o sistema de TEF   				Usa TEF
//  3 - Usa Imp. Fiscal      										Caixa tem acesso a utilizar Impressora Fiscal  				Usa impressora fiscal
//  4 - Supervisão Caixa     										Acesso para abrir e fechar o caixa             				Abre/Fecha caixa
//  5 - Sangria/Troco        										Acesso para fazer sangria e entrada de troco   				Sangria e Entrada de troco
//  6 - Redução Z            										Acesso para fazer Redução Z                    				Redução Z
//  7 - Cancelamento Item    										Acesso para cancelar item                      				Cancelamento de Item
//  8 - Cancelamento Cupom   										Acesso para cancelar o cupom                   				Cancelamento de Cupom
//  9 - Alterar parcelas     										Acesso para alterar parcelas na venda balc„o   				Alterar parcelas
// 10 - Saida do Atendimento 										Acesso para sair da tela de Atendimento        				Sair do Atendimento
// 11 - Efetuar Descontos    										Acesso para efetuar descontos                  				Efetuar Descontos
// 12 - Funções FrontLoja    										Acesso para acessar a tecla de funções (F12)   				Acessar Funções FrontLoja
// 13 - Abertura de Gaveta   										Acesso para abrir Gaveta                       				Abrir Gaveta
// 14 - Atualizacao Geral Check-Out 								Acesso para realizar atualizacao geral no Check-Out 		Realizar Atualizacao Geral no Check-Out
// 15 - Libera financiamento 										Acesso para liberar financiamento              				Libera Financiamento
// 16 - Reabertura de Caixa  										Acesso para Reabrir o Caixa                    				Reabre Caixa
// 17 - Cancelamento TEF     										Acesso para Cancelar Transação TEF			   				Cancelamento TEF
// 19 - Libera Vale Compra   										Acesso para liberar vale compra                				Libera Vale Compra
// 20 - Cancelamento Automatico    									Acesso para Liberar Cancelamento Automatico 				Cancelamento Automatico
// 21 - Leitura X            										Acesso para fazer Leitura X                    				Leitura X
// 22 - Senha Superior se houver falha de conexão WebService na NCC	Acesso para Liberar sem Senha do Superior na NCC			Libera sem Senha Superior na NCC
// 23 - Inat. Vale-Presente  										Acesso para inativar Vale-Presente		    				Inativar vale-presente
// 24 - Reprocessamento na Reducao Z								Acesso para reprocessar orcamentos em aberto na Reducao Z	Reprocessamento de orcamentos na Reducao Z
// 25 - Fechamento simplificado		   								Acesso para efetuar o fechamento de caixa simplificado		Fechamento simplificado
// 26 - Alterar Numero do Formulario						        Acesso para Alterar Numero do Formulario					Alterar Numero do Formulario 
// 27 - Cancela Credito Lista
// 28 - Permite uso de vendas manuais					            Acesso para realizar venda sem impressao					Realiza venda sem a opção de imprimir
// 29 - Estorno de venda    Acesso para estonar uma venda 
// 30 - Imprime Ticket												Acesso a Impressora não fiscal para Australia				Impressora não fiscal para Australia
// 31 - Libera Análise de Crédito do FS Manualmente                 Acesso à rotina de aprovação da análise de crédito manual
// 32 - Aferição de Abastecimento	Acesso para Realizar Aferição (Template de Combustivel)	Acesso para Realizar Aferição (Template de Combustivel)
// 33 - Abre/Fecha Encerrantes	Acesso para permitir a abertura/fechamento de encerrantes e cadastro de LMC (Template de Combustiveis)
// 34 - Permite efetuar a Substituição da Placa Eletrônica ( Template de Combustiveis )
// 35 - Analise de Margem Minima 
// 36 - Libera recebimento de NCC em modo Offline
// 37 - Permissão para conferencia de fechamento de caixa
// 38 - Permissão para vender serviço financeiro
// 39 - Altera Forma de Pagamento									Acesso para alterar a forma de pagamento					Altera Forma de Pagamento
// 40 - Alterar a Taxa de juros e desconto Mult-Negociação.
// 41 - Limpa Formas de Pagamento -  TotvsPdv
// 42 - Farmaceutico                                                Caixa tem perfil farmaceutico
// 43 - Permissão para liberar orçamento eu uso
// 44 - Permissão para alterar as parcelas no TEF de um orçamento importado no TOTVS PDV
// 45 - Permite recebimento de titulo offline no TOTVS PDV

aPermissao:= {{ 1,STR0026,STR0027,STR0028,"N","XXX"},;
				{ 2,STR0029,STR0030,STR0029,"N","XXX"},;
				{ 3,STR0031,STR0032,STR0033,"N","XXX"},;
				{ 4,STR0034,STR0035,STR0036,"N","XXX"},;
				{ 5,STR0037,STR0038,STR0039,"N","XXX"},;
				{ 6,STR0040,STR0041,STR0042,"N","XXX"},;
				{ 7,STR0043,STR0044,STR0045,"N","XXX"},;
				{ 8,STR0046,STR0047,STR0048,"N","XXX"},;
				{ 9,STR0052,STR0053,STR0054,"N","XXX"},;
				{10,STR0069,STR0070,STR0071,"N","FRT"},;
				{11,STR0072,STR0073,STR0074,"N","XXX"},;
				{12,STR0063,STR0064,STR0065,"N","FRT"},;
				{13,STR0066,STR0067,STR0068,"N","XXX"},;
				{14,STR0075,STR0076,STR0077,"N","FRT"}}
If CRDXINT()
	AAdd(aPermissao,{15,STR0079,STR0080,STR0081,"N","XXX"})
	lCrd := .T.
Endif
AAdd(aPermissao, {16,STR0082,STR0083,STR0084,"N","XXX"})
AAdd(aPermissao, {17,STR0176,STR0177,STR0178,"N","XXX"}) // "Rotinas TEF Gerenciais" - "Acesso a Rotinas TEF Gerenciais" - "TEF Gerenciais" 

If lCrd
	AAdd(aPermissao, {19,STR0091,STR0092,STR0093,"N","XXX"})
Endif
aAdd(aPermissao,{21,STR0096,STR0097,STR0096,"N","XXX"}) 	//##Leitura X, Acesso para Leitura X, Leitura X
aAdd(aPermissao,{22,STR0102,STR0103,STR0104,"N","FRT"})  	//##"Senha Superior se houver falha de conexão WebService na NCC"##"Acesso para Liberar sem Senha do Superior na NCC"##"Libera sem Senha Superior na NCC"
aAdd(aPermissao,{23,STR0105,STR0106,STR0107,"N","XXX"})	//##"Inat. Vale-Presente"##"Acesso para inativar Vale-Presente"##"Inativar vale-presente"
aAdd(aPermissao,{24,STR0111,STR0112,STR0113,"N","XXX"})	//Exec. Reduçãoo Z sem reprocessamento - Permitir Redução Z sem reprocessar orçamentos em aberto no PDV - Executar Redução Z sem reprocessamento
aAdd(aPermissao,{25,STR0114,STR0115,STR0116,"N","XXX"})	//Fechamento simplificado - Acesso para efetuar o fechamento de caixa simplificado - Fechamento simplificado

//Verifica se a rotina de Lista de Presentes esta aplicada
If lUsaLstPre
	aAdd(aPermissao,{27,STR0120,STR0121,STR0122,"N","XXX"})   ////// "Cancela Credito Lista","Acesso a Cancelamento de Credito da Lista de Presentes","Cancela Credito Lista"
EndIf

//Release 11.5 - Localizacoes 	
//Paises: Chile/Colombia -F1CHI
If lCLocR5
	aAdd(aPermissao,{26,STR0123,STR0124,STR0123,"N","XXX"})//"Alterar Numero do Formulario"#"Acesso para Alterar Numero do Formulario"
	aAdd(aPermissao,{28,STR0125,STR0126,STR0127,"N","XXX"})//"Vendas Manuais"#"Acesso para vendas manuais (sem impressão)"
EndIf

aAdd(aPermissao,{29,STR0117,STR0118,STR0119,"N","XXX"})   //29 - Estorno de venda-Acesso para estonar uma venda-Estorno de venda

If INFLocaliz()
	aAdd(aPermissao,{30,STR0130,STR0131,STR0132,"N","XXX"})   //30 - Imprime Comprovante de Venda
EndIf   

If lUsaIntFS
	aAdd(aPermissao,{31,STR0133,STR0134,STR0133,"N","XXX"})   //31 - "Liberação Manual da Análise de Crédito"#"Liberação Manual da Análise de Crédito do Financial Service"#"Liberação Manual da Análise de Crédito"
EndIf

If HasTemplate("PCL")
	aAdd(aPermissao,{32,STR0135,STR0136,STR0136,"N","XXX"}) //"Aferição de Abastecimento" , "Aferição (Template de Combustivel)"
	aAdd(aPermissao,{33,STR0137,STR0138,STR0138,"N","XXX"}) //"Encerrantes e L.M.C.", "Encerrantes/L.M.C (Template de Combustível)"
	aAdd(aPermissao,{34,STR0140,STR0141,STR0141,"N","XXX"})	//"Substituição da Placa Eletrônica","Substituição da Placa Eletrônica (Template de Combustível)"
EndIf

aAdd(aPermissao,{35,STR0142,STR0142,STR0142,"N","XXX"})	//"Libera Venda abaixo da Margem Minima"

If SuperGetMv("MV_LJNCCBC", , "0" ) <> "0"
	aAdd(aPermissao,{36,STR0147,STR0147,STR0147,"N","XXX"})	//"Libera recebimento de NCC em modo Offline"
EndIf

AAdd(aPermissao, {37,STR0144,STR0146,STR0145,"N","XXX"}) //#"Conferência de caixa" ##STR0146 ###"Permissão para conferência de caixa."

If lSFinanc
	aAdd(aPermissao, {38,STR0148,STR0149,STR0148,"N","XXX"}) 	//#"Serviço Financeiro" ##"Permissão para vender serviço financeiro."	
EndIf

aAdd(aPermissao, {39,STR0155,STR0156,STR0155,"N","XXX"}) 	//#"Alterar forma de pagamento" ##"Acesso para alterar forma de pagamento"

If SuperGetMv("MV_LJMNPER", , .F. ) 
	aAdd(aPermissao, {40,STR0159,STR0159,STR0159,"N","XXX"}) 	//#"Alterar a Taxa de juros e desconto Mult-Negociação."
EndIf	
aAdd(aPermissao, {41,STR0160,STR0160,STR0160,"N","XXX"}) 	//#"Alterar Formas de Pagamento-TotvsPdv."

If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
	aAdd(aPermissao, {42,STR0157,STR0158,STR0158,"N","XXX"}) 	//#"Farmaceutico" ##"Permissão para movimentar produtos controlados(Template de Drogaria)"
EndIf
aAdd(aPermissao, {43,STR0163,STR0163,STR0163,"N","XXX"})    //#"Permissão para liberar orçamento eu uso no Venda Assistida"
aAdd(aPermissao, {44,STR0164,STR0164,STR0164,"N","XXX"})	//"Altera Parcelas(TEF) de um orçamento importado no TOTVS PDV"
aAdd(aPermissao, {45,STR0174,STR0174,STR0174,"N","XXX"})	//"Permite o recebimento de titulos offline no TOTVS PDV"
aAdd(aPermissao, {46,STR0175,STR0175,STR0175,"S","XXX"})	//"Permite visualizar saldo estoque outras lojas na Pesquisa do VA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MUITO CUIDADO, ao Criar Permissoes.                     ³
//³ Deve-se Usar a Mesma Sequencia Para Todas as Versoes.   ³
//³ Neste Caso, Pule os Numeros. A Permissao Numero X, Deve ³
//³ Ser a Mesma Para a 5.08, 6.09 e Versoes Posteriores...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aPermissao

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ120Acesso³ Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o array de acesso do Modulo do LOJ                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj120Acesso(aAcesso,cAcessoUser,lAllAcesso)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aAcesso    - Array dos acessos                             ³±±
±±³          ³ cAcessoUser- String de flags dos acessos do Usuario        ³±±
±±³          ³ lAllAcesso - Flag para setar todos os acesso do sistema    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj120Acesso(aAcesso, cAcessoUser, lAllAcesso)
Local aPermissao := LJ120Permi()
Local lCLocR5	:= 	cPaisLoc$"CHI|COL"													//Localização chile e colombia 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Geracao do vetor de acesso com as permissoes do usuário   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAllAcesso:=.T.
aAcesso := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para Colombia e Chile os perfis 3 e 28 serão iniciados com "N"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCLocR5
	AEval(aPermissao, {|aLinha| If(aLinha[6]==Subs(Trim(cModulo),1,3) .OR. aLinha[6]=="XXX",;
								AAdd(aAcesso,{If(Subs(cAcessoUser,aLinha[1],1)==" ",If(aLinha[1] <> 16,If(aLinha[1]== 3 .OR. aLinha[1]== 28,"N","X"),"S"),;
								Subs(cAcessoUser,aLinha[1],1)), aLinha[4], Subs(aLinha[5],1,1), aLinha[1]}),.t.),;
								lAllAcesso:=if(lAllAcesso .AND. Subs(cAcessoUser,aLinha[1],1) == "S",.T.,.F.) })
Else
	AEval(aPermissao, {|aLinha| If(aLinha[6]==Subs(Trim(cModulo),1,3) .OR. aLinha[6]=="XXX",;
								AAdd(aAcesso,{If(Subs(cAcessoUser,aLinha[1],1)==" ",If(aLinha[1] <> 16,"X","S"),Subs(cAcessoUser,aLinha[1],1)),;
								aLinha[4], Subs(aLinha[5],1,1), aLinha[1]}),.t.),;
								lAllAcesso:=if(lAllAcesso .AND. Subs(cAcessoUser,aLinha[1],1) == "S",.T.,.F.) })
EndIf

Return aAcesso
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ120OK    ³ Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o Perfil e o acesso do usuario selecionado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ120OK(aAcesso,lLogErro,lLogConf,lLogMonit,lLogRec,;      ³±±
±±³          ³         lFrontLoja,cCodUser,nDescPer,nDescVal)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aAcesso  - Array dos acessos                               ³±±
±±³          ³            aAcesso[1,1] - Flag de Permissao                ³±±
±±³          ³            aAcesso[1,2] - Descricao do acesso              ³±±
±±³          ³            aAcesso[1,3] - Flag se Solicita senha Superior  ³±±
±±³          ³ lLogErro   - Flag Log de Erros                             ³±±
±±³          ³ lLojConf   - Flag Log de confirmacao para apagar registros ³±±
±±³          ³ lLogMonit  - Flag para passo a passo do processo de venda  ³±±
±±³          ³ lLogRec    - Flag para recuperacao do status de venda      ³±±
±±³          ³ lFrontLoja - Flag para acesso automatico tela de venda     ³±±
±±³          ³ cCodUser   - Codigo do caixa selecionado                   ³±±
±±³          ³ nDescPer   - Desconto em percentual configurado ao caixa   ³±±
±±³          ³ nDescVal   - Desconto em Valor configurado ao caixa        ³±±
±±³          ³ lMultimidia- Flag para acesso automatico da consulta multim³±±
±±³          ³ cTpVal     - Tipo de Validacao para o desconto             ³±±
±±³          ³ cNumCart   - Numero do Cartao do Superior                  ³±±
±±³          ³ aSang   	  - array de sangria para rotinas automaticas     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ120OK(	aAcesso		, lLogErro		, lLogConf	, lLogMonit		,;
					lLogRec		, lFrontLoja	, cCodUser	, nDescPer		,;
					nDescVal	, lMultimidia	, cLF_TPVAL	, cNumCart		,;
					nOpcDesc	, lIntSiac		, cOpSiac	, nTotPerDesc	,;
					nTotValDesc	, aSang			, cBkpCart	)

Local cAcessoUser	:=repli("N",9)+SPace(191)
local nI
Local oProcessOff	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
Local nX			:= 0		// contador
Local lLimSang      := SuperGetMV( "MV_LJLISAN",, .F.) // Utiliza controle para limite de sangria
Local lIntegDef		:= FWHasEAI("LOJA120",.T.,,.T.)//Integração EAI ativa para envio
Local aRetInt 		:= {} //Retorno integração 
Local cMsgRet		:= "" //Mensagem retorno Integração

Default lIntSiac 	:= .F.
Default cOpSiac		:= ""
Default nTotPerDesc	:= 0
Default nTotValDesc	:= 0 
Default aSang		:= {}
Default cBkpCart	:= ""

If !lEncript .AND. !Empty(cNumCart) .AND. cNumCart <> cBkpCart
	cNumCart := LjEncript(0,cNumCart)
	lEncript := .F.
EndIf 

For nI := 1 To Len(aAcesso)
	// Monta a variavel de acesso do Caixa, onde os flags
	// S -> Tem Permisao
	// N -> Nao Tem Permisao, mas caso LH_SENHA="S", Grava ""x"
	// X -> Solicita senha de pessoa que tem acesso, somente um nivel
	cAcessoUser := Stuff(cAcessoUser,aAcesso[nI,4],1,aAcesso[nI,1])
Next nI

cLog := If(!lLogErro, "N", "S")
cLog += If(!lLogErro, "N", If(lLogConf , "S", "N") )
cLog += If(!lLogErro, "N", If(lLogMonit, "S", "N") )
cLog += If(!lLogErro, "N", If(lLogRec  , "S", "N") )

DbSelectArea("SLF")
SLF->( DbSetOrder(1) )	//LF_FILIAL + LF_COD
If SLF->( DbSeek(xFilial("SLF") + cCodUser) )
	Reclock( "SLF", .F. )
	cTipo := "UPDATE"
Else
	Reclock( "SLF", .T. )
	cTipo := "INSERT"
EndIf

REPLACE LF_ACESSO    WITH cAcessoUser
REPLACE LF_FILIAL    WITH xFilial()
REPLACE LF_COD       WITH cCodUser
REPLACE LF_LOGERRO   WITH cLog
REPLACE LF_FRTAUTO   WITH If(!lFrontLoja,"N","S")
REPLACE LF_MULTIMI   WITH If(!lMultimidia,"N","S")
REPLACE LF_DESCPER   WITH nDescPer
REPLACE LF_DESCVAL   WITH nDescVal
REPLACE LF_TOTDESP   WITH nTotPerDesc
REPLACE LF_TOTDESV   WITH nTotValDesc
REPLACE SLF->LF_TPVAL	 WITH cLF_TPVAL

If  AliasIndic("MGW") .AND. (lLimSang .Or. Len(aSang) > 0 )
	// Grava MGW  
	If Len(aSang) > 0
	   aColsEx := aSang 
	Else
		aColsEx := oGetSang:aCols
	EndIf	

	cCodUser	:= SLF->LF_COD

	For nX := 1 To Len(aColsEx)
		DbSelectArea("MGW")
		MGW->( DbSetOrder(1) ) //MGW_FILIAL+MGW_CAIXA+MGW_FPAGTO 
		If DbSeek (xFilial("MGW")+ cCodUser + aColsEx[nX][1] )	 
			Reclock ("MGW", .F.) // Atualiza
			Replace MGW_LIM1 WITH aColsEx[nX][2]
			Replace MGW_LIM2 WITH aColsEx[nX][3]
		Else
			Reclock ("MGW", .T.) // Inclui
			Replace MGW_FILIAL With xFilial("MGW")
			Replace MGW_CAIXA With cCodUser
			Replace MGW_FPAGTO WITH aColsEx[nX][1]
			Replace MGW_LIM1 WITH aColsEx[nX][2]
			Replace MGW_LIM2 WITH aColsEx[nX][3]		
		EndIf	
	Next nX
	
	Msunlock("MGW")

	// Limpa após inclusao
	aColsEx := {}
EndIf

REPLACE SLF->LF_NUMCART   	WITH cNumCart 
REPLACE SLF->LF_OPCDESC		WITH nOpcDesc

//se a integracao Protheus x SIAC estiver ativa, gravamos o campos LF_CODSIAC
If lIntSiac
	REPLACE SLF->LF_CODSIAC WITH cOpSiac
EndIf

SLF->( MsUnlock() )

//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("016")
	//Insere os dados do processo (registro da tabela)
	oProcessOff:Inserir("SLF", xFilial("SLF") + SLF->LF_COD, 1, cTipo)	
	//Processa os dados 
	oProcessOff:Processar()	
EndIf

If cCodUser == xNumCaixa()
	cStrAcesso := cAcessoUser
	lFiscal:=LJProFile(3)
	lUsaTef:=LJProFile(2)
EndIf

If lIntegDef 
	Altera := .T.
	aRetInt := FwIntegDef("LOJA120",,,, "LOJA120")

	If Valtype(aRetInt) == "A" .And. Len(aRetInt) >= 2 .And. !aRetInt[1]
		If !Empty(AllTrim(aRetInt[2]))
			cMsgRet := AllTrim(aRetInt[2]) +chr(13)+chr(13)
		EndIf
		cMsgRet += STR0165 //"Maiores detalhes no monitor EAI."
		Aviso(STR0166,cMsgRet,{"Ok"},3)//"EAI: Erro de integração"
	EndIf
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MarkAll    ³ Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e desmarca todos as permissoes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MarkAll(lAll,aAcesso)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lAll  - Flag de status do CHECKBOX                         ³±±
±±³          ³ aAcesso  - Array dos acessos                               ³±±
±±³          ³            aAcesso[1,1] - Flag de Permisao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarkAll(lAll, aAcesso)

Local nX
Local lCLocR5	:= 	cPaisLoc$"CHI|COL"													//Localização chile e colombia 

For nX := 1 To Len(aAcesso)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - localização Colombia                                                                             ³
//³Para Colombia e Chile não se usa impressora fiscal                                                              ³
//³quando selecionado All na criação de usuario não seleciona o as permissões "Usuario es caixa" e "Vendas manuais"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCLocR5
		If aAcesso[nX][4] == 3 .OR. aAcesso[nX][4] == 28
			aAcesso[nX][1] := "N"
		Else
			aAcesso[nX][1] := If(lAll,"S","N")
		EndIf
	Else                                   
		aAcesso[nX][1] := If(lAll,"S","N")
	EndIf
Next nX

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ lj0120Muda | Autor ³ Vendas Clientes     ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita e desabilira os CHECKBOX do log de erros qdo o    ³±±
±±³          ³ usuario nao utilisa-lo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj0120Muda(lLogErro,oLogConf,oLogMonit,oLogRec)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lLogErro   - Flag Log de Erros                             ³±±
±±³          ³ oLogConf   - Objeto do Flag Log de confirmacao para apagar ³±±
±±³          ³              registros                                     ³±±
±±³          ³ oLogMonit  - Objeto do Flag para passo a passo do processo ³±±
±±³          ³              de venda                                      ³±±
±±³          ³ oLogRec    - oBjeto do Flag para recuperacao do status de  ³±±
±±³          ³              venda                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function lj0120Muda( lLogErro, oLogConf, oLogMonit, oLogRec )

If llogErro
	oLogConf :Enable()
	oLogMonit:Enable()
	oLogRec  :Enable()
Else
	oLogConf :Disable()
	oLogMonit:Disable()
	oLogRec  :Disable()
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ120Val  ºAutor  ³Vendas Clientes     º Data ³  27/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a validacao do valor selecionado no ComboBox        º±±
±±º          ³ "Tipo de Validacao"                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ120Val(lCarrega, cTpVal, cLF_TPVAL, aPpVal)
Local nPosVal := 0

If lCarrega
	nPosVal := Ascan( aPpVal, { |x| cLF_TPVAL == x[2] } )
	If nPosVal > 0
		cTpVal :=  AllTrim(aPpVal[nPosVal][3])
	EndIf
Else
	nPosVal := Ascan( aPpVal, { |x| AllTrim(cTpVal) == AllTrim(x[3]) } )
	If nPosVal > 0
		cLF_TPVAL := AllTrim(Str(nPosVal))
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Lj120VWiz ºAutor  ³ Vendas Clientes    º Data ³  14/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Identifica a versao do fonte                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Versao do fonte para execução do Wizard do Caixa			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LojXFunA()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj120VWiz()

Local nRet := 0    		//	Armazena o controle da Versão do fonte para o wizard do caixa
	
nRet :=	20071214 		// 14, Dezembro de 2007

Return (nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ValLocR5   ³ Autor ³ Vendas Clientes     ³ Data ³10/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe Mensagem quando opcoes forem selecionadas            ³±±
±±³			 ³ para colombia/chile				       					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValLocR5(cPermi,nPerfil)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cPermi - Valor da permissão "S","X","N"					  ³±±
±±³			 ³  nPerfil	- Qual perfil esta com a permissao				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  cRet - Novo valor da permissão "S","X","N" 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA/FRONTLOJA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VAlLocR5(cPermi,nPerfil)

Local cRet 		:= Nil 															// Variavel de retorno da Função
Local lCLocR5	:= cPaisLoc$"CHI|COL"				//Localização chile e colombia 

Default cPermi 	:= Nil         
Default nPerfil	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a permissão for diferente de "S", apresentara mensagem de confirmação para ativação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPermi <> "S"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nPerfil = 3 - Usuario é caixa (Fiscal)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPerfil == 3
		If MsgYesNo(STR0128)//"Usuario Caixa para esse pais nao usa impressora fiscal  ...deseja continuar?"
			cRet := "S"
		Else 
			cRet := "N"         		
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³nPerfil = 28 - Vendas Manuais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MsgYesNo(STR0129)//"Permissão exclusiva para Venda Manual, esse usuario não será um caixa normal  ...deseja continuar?"
			cRet := "S"
		Else 
			cRet := "N"
		EndIf
	EndIf
Else
	cRet := "N"
EndIf	           


Return cRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LJ120Sang  ³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ GetDados para Limite de Sangria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil													           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//------------------------------------------------
Static Function LJ120Sang(lWizard,oDlgPsw,cCodUser)
//------------------------------------------------
Local nX			:= 0 				// Contador da SX3
Local nI			:= 0 				// Contador das formas de pagamento
Local aHeaderEx 	:= {} 				// Colunas da GetDados
Local aForms		:= STDFormsPay()	// Todas as formas de pagamento da tabela 24 da SX5
Local aCpo      	:= {"MGW_FPAGTO","MGW_LIM1","MGW_LIM2"}	// Colunas da GetDados
Local aAlter  		:= {"MGW_LIM1","MGW_LIM2"} 				// Campos que podem ser alterados
Local cLinhaOk		:= "LJ120SLOk"							// Função que valida a Linha da GetDados
Local aArea			:= GetArea()							// Area corrente

Default lWizard		:= .F.	// Se é Wizard
Default oDlgPsw		:= Nil	// Objeto do Wizard
Default cCodUser	:= ""	// Codigo do Caixa

dbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to Len(aCpo)
	If SX3->( DbSeek(aCpo[nX]) )
		Aadd( aHeaderEx,{	AllTrim(X3Titulo()),;
							SX3->X3_CAMPO	,;
							SX3->X3_PICTURE	,;
							SX3->X3_TAMANHO	,;
							SX3->X3_DECIMAL	,;
							SX3->X3_VALID	,;
							SX3->X3_USADO	,;
							SX3->X3_TIPO	,;
							SX3->X3_F3 		,;
							SX3->X3_CONTEXT	,;
							SX3->X3_CBOX	,;
							SX3->X3_RELACAO	})
	Endif
Next nX

DbSelectArea("SLF")
SLF->( DbSetOrder(1) )

If SLF->( dbSeek(xFilial("SLF")+cCodUser) )
	cCodUser := SLF->LF_COD

	If AliasIndic("MGW")
		DbSelectArea("MGW")
		MGW->( DbSetOrder(1) )	//MGW_FILIAL+MGW_CAIXA+MGW_FPAGTO

		aColsEx := {} // zera o array do Acols da GetDados

		For nI := 1 to Len(aForms)
			If MGW->( DbSeek(xFilial("MGW")+ cCodUser + aForms[nI][1]) )
				aAdd( aColsEx, {MGW->MGW_FPAGTO, MGW->MGW_LIM1, MGW->MGW_LIM2, .F.} )
			Else
				aAdd( aColsEx, {aForms[nI][1], 0, 0,.F.} )
			Endif
		Next nI

		// Ordena as formas de pagamento para Dinheiro e Cheque no começo
		aSort(aColsEx, , , { | x,y | Alltrim(x[1]) $ "R$|CH" } )

		If lWizard
			oGetSang := MsNewGetDados():New( 05, 05, 115, 295,GD_UPDATE, cLinhaOk, "AllwaysTrue", "+Field1+Field2", aAlter,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgPsw:GetPanel(7), aHeaderEx, aColsEx)
		Else
			oGetSang := MsNewGetDados():New( 05, 05, 150, 213,GD_UPDATE, cLinhaOk, "AllwaysTrue", "+Field1+Field2", aAlter,, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder:aDialogs[4], aHeaderEx, aColsEx)
		EndIf
	EndIf
EndIf

aColsEx := {} // zera o array do aCols da GetDados

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LJ120SLOk  ³ Autor ³ Vendas Clientes    ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a linha da GetDados		                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil													           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ120SLOk()

Local lRet := .T.	// retorno da função
Local nI := 0		// contador do acols

For nI := 1 to Len(oGetSang:aCols) 
	If	oGetSang:aCols[nI][3] < 0 .OR. oGetSang:aCols[nI][2] < 0
		MsgAlert(STR0154) //"Não é permitido valores Negativos"
		lRet := .F.
	EndIf
Next nI

Return lRet

// altera get dados
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LJ120AltGet  ³ Autor ³ Vendas Clientes    ³ Data ³02/02/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Altera GetDados de acordo com o Caixa selecionado para copia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil													           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ120AltGet(cCmbCopy)

Local aArea      	:= GetArea()		// Area corrente
Local aForms		:= STDFormsPay()	// Todas as formas de pagamento da tabela 24 da SX5
Local nI			:= 0 				// contador do caixa selecionado
Local nX			:= 0 				// contador do registro vazio

Default cCmbCopy 	:= "" 				// Caixa a ser copiado os valores da sangria

DbSelectArea("SLF")
SLF->( DbSetOrder(1) )

aColsEx := {} // zera o array do Acols da GetDados

If AliasIndic("MGW") .AND. !Empty(cCmbCopy)
	If SLF->( DbSeek(xFilial("SLF") + cCmbCopy) )
		DbSelectArea("MGW")
		MGW->( DbSetOrder(1) )	//MGW_FILIAL+MGW_CAIXA+MGW_FPAGTO
		For nI := 1 to Len(aForms)
			If MGW->( DbSeek (xFilial("MGW")+ cCmbCopy + aForms[nI][1]) )
				aAdd(aColsEx, {MGW->MGW_FPAGTO, MGW->MGW_LIM1 , MGW->MGW_LIM2 ,.F. }	)			
			EndIf
		Next nI
	EndIf
Else
	aColsEx := {} // zera o array do Acols da GetDados
	For nX := 1 to Len(aForms)		
		aAdd(aColsEx, {aForms[nX][1], 0 , 0 ,.F. }	)
	Next nX
EndIf

// Ordena as formas de pagamento para Dinheiro e Cheque no começo
aSort(aColsEx, , , { | x,y | Alltrim(x[1]) $ "R$|CH" } )

// Só atualiza a GetDados se o Array estiver preenchido
If Len(aColsEx) > 0 
	oGetSang:SetArray(aColsEx)
	oGetSang:GoTop()
EndIf

RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de integracao com o adapter EAI para envio e recebimento de
operadores de caixa utilizando o conceito de mensagem unica.
@type function
@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 21/05/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
		aRet[3] - (caracter) Nome da Mensagem 
/*/
//-------------------------------------------------------------------
Static Function IntegDef(xEnt   , nTypeTrans, cTypeMessage, cVersion, cTransaction,;
                         lEaiObj)

	Local aRet      := {}
	
	Default lEaiObj := .F.

	If lEaiObj
		aRet:= MsuEaiObj(xEnt, nTypeTrans, cTypeMessage)
	Else
		aRet:= LOJI120(xEnt, nTypeTrans, cTypeMessage)
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MsuEaiObj() 
Mensagem única de integração do Operador\Caixa utilizando objeto FWEaiObj
Classe CashierOperatorAdapter esta no fonte LOJI120O

@param oEaiObj		- Objeto FWEaiObj recebido via msg unica
@param nTypeTrans 	- Determina se e uma mensagem a ser enviada/recebida (TRANS_SEND ou TRANS_RECEIVE)	
@param cTypeMessage	- Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)

@author  Rafael Tenorio da Costa
@since   05/12/18
/*/
//-------------------------------------------------------------------
Static Function MsuEaiObj(oEaiObj, nTypeTrans, cTypeMessage)

	Local aRet		:= {}
	Local oCashOper := CashierOperatorAdapter():New(oEaiObj)

	If nTypeTrans == TRANS_RECEIVE

		Do Case

			Case cTypeMessage == EAI_MESSAGE_BUSINESS
				oCashOper:ReceiveBusiness()
				aRet := {oCashOper:GetOk(), oCashOper:GetEaiObjSnd() , oCashOper:GetMsgName()}

			Case cTypeMessage == EAI_MESSAGE_RESPONSE
				oCashOper:ReceiveResponse()
				aRet := {oCashOper:GetOk(), oCashOper:GetEaiObjSnd(), oCashOper:GetMsgName()}			

			Case cTypeMessage == EAI_MESSAGE_WHOIS
				aRet := {oCashOper:GetOk(), oCashOper:GetVersion()	 , oCashOper:GetMsgName()}

		EndCase

	ElseIf nTypeTrans == TRANS_SEND

		oCashOper:SendBusiness()
		aRet:={oCashOper:GetOk(), oCashOper:GetEaiObjSnd(), oCashOper:GetMsgName()}	

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetCart
Funcao responsavem por realizar a cominicação com Pinpad devolvendo criptografada ou não a trilha do cartão

@type function
@param nEncript, Numérico, Determina a ação da função aonde:
0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String

@author Lucas Novais (lnovias)
@version P12
@since 27/11/2018
@return cNumCart, Retorna o numero do cartão criptografado ou 
apenas o numero do cartão dependendo do parametro recebido pelo nEncript
/*/
//-------------------------------------------------------------------

Function LjGetCart(nEncript)

Local cNumCart := ""										//Numero do Cartão retornado pelo PinPad
Local nHandle := -1											//Variavel de controle de retorno da DLL
Local cTrilha1 := Space(150)								//Variavel Obrigatoria para a DLL
Local cTrilha2 := Space(150)								//Variavel Obrigatoria para a DLL
Local lTentativa := .T.										//Variavel para controle de tentativas.
Local lCliSitef	:= LjGetStation("TIPTEF") == TEF_CLISITEF	//Tipo do Tef

Default nEncript := 1 										//Tipo de tratamento a ser feito, aonde: 0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String
	
If lCliSitef 
	
	/*/	Verifica se o Pinpad esta configurado. /*/
	If oAutocom:SIT_VERPIN() == 1
		
		/*/ Le o cartao do superior, e verifica se confere
		com o cartao cadastrado no SLF. /*/
		
		While lTentativa
				
			LjMsgrun(STR0168,, {|| nHandle := oAutocom:SIT_LECART(STR0167, @cTrilha1, @cTrilha2) } ) //"Passe o cartão superior no PinPad." ### "Passe o Cartao"
			
			If nHandle == 0
				lTentativa 	:= .F.
				cNumCart 	:= oAutocom:cBuffer
				cNumCart 	:= LjEncript(nEncript,cNumCart)
			Else 
				If MsgYesNo(STR0169)//"Não foi possivel receber a senha do usuario pelo PinPad, deseja tentar novamente?"
					lTentativa := .T.
				Else
					lTentativa := .F.
				EndIf
			EndIf
		End

	Else
		MsgAlert( STR0170 + Chr(10) + STR0171) //"Pinpad não configurado. Verifique a conexão do PinPad" ### " ou Configure o tipo de validação do usuário no Perfil de Caixas"
	EndIf
Else
	MsgAlert(STR0173) //"Verifique sua configuração do TEF, funcionalidade apenas disponivel para CLISITEF"
EndIf

Return cNumCart

//-------------------------------------------------------------------
/*/{Protheus.doc} LjEncript
Funcao responsavem por criptografar ou descriptografar a senha recebida pelo Pinpad.

@type function
@param cNumCart, Caracter, Recebe o numero do cartão enviado pelo PinPad
@param nEncript, Numérico, Determina a ação da função aonde:
0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String

@author Lucas Novais (lnovias)
@version P12
@since 27/11/2018
@return cRet, Retorna o numero do cartão criptografado ou 
apenas o numero do cartão dependendo do parametro recebido pelo nEncript
/*/
//-------------------------------------------------------------------

Function LjEncript(nEncript,cNumCart)

Local cRet 		:= ""
Local nX 		:= 1
Local cPosCart 	:= ""

Default nEncript := 1		//Tipo de tratamento a ser feito, aonde: 0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String
Default cNumCart := ""		//Numero do Cartão a ser tratado.

If nEncript == 0
	lEncript := .T.
EndIf

If !Empty(cNumCart) 
	/*/ Removo apenas caso não seja descripty /*/
	If (nEncript == 0 .OR. nEncript == 2 )

		cNumCart := StrTran(cNumCart,STR0167) //"Passe o Cartao"
		
		/*/ Tratamento para Remover caracter "estranhos" passados pelo PinPad /*/
		For nX := 1 to len(cNumCart)
			cPosCart := SubStr(cNumCart,nX,1)
			If cPosCart $ "0123456789qwertyuiopasdfghjklçzxcvbnmQWERTYUIOPASDFGHJKLÇZXCVBNM"
				cRet += cPosCart
			EndIf
		Next
	Else
		cRet := cNumCart
	EndIf  

	If nEncript <> 2
		cRet :=  Encript(AllTrim(cRet),nEncript)
	EndIf
EndIf 

Return cRet

