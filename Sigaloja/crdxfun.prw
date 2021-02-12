#INCLUDE "CRDXFUN.CH"
#INCLUDE "PROTHEUS.CH"                        
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"                                                
#INCLUDE "CRDDEF.CH"                      
#INCLUDE "AUTODEF.CH"                                                   
#INCLUDE "TCBROWSE.CH"
         
#DEFINE TENTATIVAS   SuperGetMv("MV_CRDTWS",,10)                  //Numero maximo de tentativas para login via WS
#DEFINE CTRL CHR(13)+CHR(10)
/*                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º CRDXFUN  ³Desc. ³ Funcoes genericas para o modulo SIGACRD             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    PARA QUALQUER ALTERACAO, FAVOR COMUNICAR O RESPONSAVEL DO MODULO   º±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static cUsrSessionID := ""   // Variavel para login na transacao Web Service
Static aList         := {}   // Cache para as tabelas selecionadas para consulta
Static lSenhaOk		 := .F.	 // Variavel para controle de solicitacao de senhas na alteracao do Limite de Credito.
Static cSenha		 := "******"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AbreCRD   ºAutor  ³Vendas Clientes     º Data ³ 10/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a abertura dos componentes necessarios para o SIGACRD  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDXFUN - Abertura do arquivo MA0 e modulo SIGACRD apenas  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:      ³ A funcao abaixo foi desenvolvida para utilizar as configu- º±±
±±º          ³ racoes de equipamento de automacoa comercial, sem que seja º±±
±±º          ³ necessario configurar exatamente um CAIXA conforme necessi-º±±
±±º          ³ ta o modulo de SIGALOJA.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AbreCRD()
Local cImpressora	:= LJGetStation("IMPFISC")
Local cPorta		:= LJGetStation("PORTIF")
Local aPinPad		:= {}
Local aCMC7			:= {}
Local aLeitor		:= {}
Local aImpCupom		:= {}
Local aDisplay      := {}
Local nRet 			:= 0
Local cNumPdv       := Space(TamSX3("LG_PDV")[1])
Local cData			:= Space(8)
Local dData	        := CtoD( "" )
Local aArea         := GetArea()
Local lMvLjPdvPa	:= FindFunction("LjxBGetPaf") .And. LjxBGetPaf()[2] //Indica se é PDV

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³					ATENCAO !!!                                   ³
//³Qualquer nova variavel PUBLIC precisa ser criada tambem no     ³
//³CALL CENTER e outros modulos que usam o TEF da Software Express³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public lTTEFAberto									//Verifica se existe TEF aberto, eh utilizada na funcao LOJA010T
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Utilizar a abertura dos componentes do SIGACRD apenas se o modulo for CRD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 55                

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indico a funcao de saida.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetOnExit( "FechaCRD" ,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao seja informado a estacao, nao abrir os equipamentos.            ³
	//³A regra que o SIGALOJA adota é que, para o caso do usuario nao informar  ³
	//³a estacao, assumir automaticamente a estacao 001, mas como o modulo CRD  ³
	//³nao utiliza todos os equipamentos de automacao comercial, ficou acordado ³
	//³em obrigar o usuario a configurar uma estacao para o CRD                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Empty( cEstacao ) .OR. RetCodUsr() == "000000" .OR. Type("oAutocom") == "U"			
	
		CRDZERAVAR(	@lUsaCmc7	, @lUsaCH	, @lUsaLeitor	, @lUsaDisplay	, ; 
					@lImpCup	, @cTipTEF	, @lFiscal		, @lGaveta		, ;
					@ltTefAberto, @lUsaTef	)		
		Return Nil
	Endif
      
	DbSeek( xFilial( "SLG" ) + cEstacao )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configuro as variaveis publicas do sistema.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsaCmc7	:= !Empty(LJGetStation("CMC7"))
	lUsaCH		:= !Empty(LJGetStation("IMPCHQ"))
	lUsaLeitor	:= !Empty(LjGetStation("OPTICO"))
	lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
	lImpCup		:= !Empty(LjGetStation("IMPCUP"))
	cTipTEF		:= LjGetStation("TIPTEF")
	lFiscal     := !Empty( cImpressora )
	lGaveta		:= !Empty(LjGetStation("GAVETA"))
	ltTefAberto := .F.
	lUsaTef		:= .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variavel que indica se o sistema utiliza TEF                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipTEF <> "1"
		lUsaTef := .T.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - SmartClient HTML									³
	//³Verificar se eh usuario fiscal e/ou tem permissao para usar TEF	³
	//³Neste caso, o modulo sera encerrado								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction ("LjChkHtml")
		If LjChkHtml ()										
			If lFiscal 	
				Final(STR0137)//"Módulo indisponível para usuário fiscal"		
			ElseIf lUsaTef
				Final(STR0138)//"Módulo indisponível para usuário com permissão TEF."					
			EndIf
		EndIf                    
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura da gaveta caso esteja configurado.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGaveta .AND. LJGetStation("PORTIF")<>LJGetStation("PORTGAV") .AND. nHdlGaveta == -1
		nHdlGaveta := GavetaAbr(LJGetStation("GAVETA"),LJGetStation("PORTGAV"))
		If nHdlGaveta < 0
			lGaveta := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se utiliza Leitor Optico via serial                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLeitor:=LJGetStation({"OPTICO","PORTOPT"})
	If lUsaLeitor .AND. !Empty(aLeitor[1]).AND. !Empty(aLeitor[2]) .AND. nHdlLeitor == -1
		nHdlLeitor := LeitorAbr(aLeitor[1],aLeitor[2],"F")
		If nHdlLeitor < 0
			lLeitor := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura do Display                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDisplay := LJGetStation({"DISPLAY","PORTDIS"})
	If lUsaDisplay .AND. !Empty(aDisplay[1]) .AND. !Empty(aDisplay[2]) .AND. nHdlDisplay == -1
		nHdlDisplay := DisplayAbr(aDisplay[1], aDisplay[2])
		If nHdlDisplay < 0
			lUsaDisplay := .F.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exibir mensagem de inicializacao do Display                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(1)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura do Leitor CMC7                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaCmc7 .AND. ! ExistBlock("LJCMC7") .AND. nHdlCMC7 == -1
		aCMC7    := LJGetStation({"CMC7","PORTMC7"})
		nHdlCMC7 := CMC7Abr(aCMC7[1],aCMC7[2])
		If nHdlCMC7 < 0
			MsgStop( STR0001 ) //"Falha na comunicação com o Leitor de CMC7."
			lUsaCmc7 := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura da impressora de cheque.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaCH .AND. !Empty(LJGetStation("PORTCHQ")) .AND. nHdlCH == -1
		nHdlCH := CHAbrir( LJGetStation("IMPCHQ"), LJGetStation("PORTCHQ") )
		If nHdlCH < 0
			MsgStop( STR0002 ) //"Falha na comunicação com a Impressora de Cheque."
			lUsaCH := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura da impressora fiscal.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFiscal .AND. nHdlECF == -1
		nHdlECF := IFAbrir( cImpressora,cPorta )
		nRet    := IfAbrECF( nHdlECF )
		If nRet <> 0
			Final( STR0003 ) //"Falha na comunicação com o ECF"
		Else
			IFPegPDV(nHdlECF, @cNumPdv)
			If ! AllTrim(cNumPdv) == AllTrim(LJGetStation("PDV"))
				Final( STR0004 ) //"O Número de PDV do equipamento é diferente do cadastrado na estação."
			Endif
			If LjAnalisaLeg(3)[1]
				IfStatus(nHdlEcf,'2',@cData)
				dData := Date()
				If ! CtoD(cData) == dData
					Final( STR0005	 ) //"Data do Sistema diferente da data do ECF."
				Endif
				If ! VerifHora()
					If lMvLjPdvPa
						/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Março de 2013),
							para PAF-ECF admite-se somente uma tolerância em minutos entre a hora do Sistema e a hora do ECF,
							limitada a uma hora, desde que na mesma data." */
						Final( STR0139 ) 
					Else
						Final( STR0006 ) //"Hora do Sistema diferente da hora do ECF."
					EndIf
				Endif
			Endif
		Endif
		If Empty(LjGetStation("SERIE"))
			Final( STR0007 ) //"O Número de Série desta estação está em branco."
		Endif
		LjVldSerie()
	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faco a abertura do TEF.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTEF
		If cTipTEF $ "2;3;4" // Sem Client / Com Client / Discado
			Private aTefDados := {}
			If cTipTEF == "2" .AND. nHdlPinPad == -1
				aPinPad    := LJGetStation({"PINPAD","PORTPAD"})
				nHdlPinPad := PinPadAbr(aPinPad[1],aPinPad[2])
			Endif
			Loja010T( "A" )
		Elseif cTipTEF $ "DEDICADO;DISCADO;LOTE"
			MsgStop( STR0008 ) //"Atualize os dados sobre TEF no cadastro de estações."
			lUsaTEF := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se utiliza Impressora de cupom via serial                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If "COM" $ Upper(LjGetStation("PORTICP")) .AND. nHdlCupom == -1
		aImpCupom := LjGetStation({"IMPCUP","PORTICP"})
		nHdlCupom := ImpCupAbr(aImpCupom[1],aImpCupom[2])
		If nHdlCupom < 0
			lImpCup := .F.
		Endif
	Endif
Endif
	
RestArea( aArea )  //Retorno da area do sistema

Return Nil		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FechaCRD  ºAutor  ³Vendas Clientes     º Data ³ 10/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o fechamento dos componentes do SIGACRD                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDXFUN - Abertura do arquivo MA0 e modulo SIGACRD apenas  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FechaCRD()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Como os componentes sao semelhantes ao do SIGALOJA, sera utilizado a Fun-³
//³cao padrao do SIGALOJA para fechamento dos componentes.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LjCloseDevices()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdxInt   ºAutor  ³Vendas Clientes     º Data ³  11/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se hah integracao com o sistema de credito(SIGACRD)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdxInt( lRec, lChkWs )

Local lRet := .T.                   	//Ha integracao com SIGACRD
Local lR5  := GetRpoRelease() >= "R5"   // Indica se o release e 11.5

DEFAULT lRec 	:= .F.					//Verifica se ira' executar a analise de credito apos o Recebimento de titulos
Default lChkWs 	:= .T.					//Verifica se foi digitado WebService no Cadastro de Estações

If Type("lRecebe") == "L" .AND. lRecebe .AND. !lRec 
	If lR5 .And. SuperGetMv("MV_LJCFID",,.F.) 
		lRet := .T.
	Else		
		lRet := .F.
	Endif	
Endif

If lRet .AND. SLG->( FieldPos( "LG_CRDXINT" ) ) > 0
	If LJGetStation("CRDXINT") <> "1"
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao exista o campo, nao deve-se utilizar WebServices.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lChkWs .AND. ( SLG->( FieldPos("LG_WSSRV") ) <= 0 .OR. Empty(LJGetStation("WSSRV")) )
    //"E necessário criar ou preencher o campo LG_WSSRV com o IP e/ou porta do Web Service."###"Configuração de Web Service"
	MsgStop(STR0018,STR0019) 
	lRet := .F.
Endif          
                            
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdAExtratoºAutor ³Vendas Clientes     º Data ³  11/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a consulta do extrato do cliente no sistema de credito  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³void  CrdAExtrat( nEXP1, cEXP2, cEXP3 )                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nEXP1 - Opcao de pesquisa                                   º±±
±±º          ³        1 - Extrato das parcelas em aberto                  º±±
±±º          ³        2 - Consulta Limite de crédito                      º±±
±±º          ³cEXP2 - Numero do CPF do cliente                            º±±
±±º          ³cEXP3 - Numero do cartao do cliente                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico / Integracao com o sistema de Credito              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdAExtrato( nOpcao, cCPF, cCartao )
Local aExtrato		:= {}					// Variavel com o conteudo do extrato
Local aRetCart		:= {}					// Retorno do tipo do cartao
Local lRet 			:= .T.
Local lWSExtrato 	:= .T.
Local nX			:= 0					// Variavel para controle de looping
Local aRegsSA1		:= {}					// Registros do SA1 que serao levados para o PDV
Local cCliente		:= ""					// Codigo do cliente
Local cLojaCli		:= "" 					// Codigo da loja
Local lNovoCliente	:= .F.					// Identifica se e um novo cliente ou nao
Local aCliente		:= {}					// Array com os registro(s) do(s) cliente(s) que vieram da retaguarda
Local aRetCli		:= {}					// Array com retorno da escolha do cliente
Local nPosTmp		:= 0					// Variavel para pesquisa em array
Local lContinua		:= .T. 					// Continua ou nao a operacao
Local cMatricula 	:= "" 					// Codigo da matricula para quando existir o TPL Drogaria

Local oSvc
Local cSoapFCode
Local cSoapFDescr

DEFAULT nOpcao      := 1
DEFAULT cCPF 	    := Space(11)			// Forca sempre para pegar o CPF pois os clientes do credito sao pessoas fisicas
DEFAULT cCartao     := Space( TamSX3("MA6_NUM")[1] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao foi passada as informacoes do cliente abre a tela para solicitar   ³
//³os dados ao usuario                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cCPF ) .AND. Empty( cCartao )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aRetCart[1] ->Retorna o tipo do cartao                 ³
	//³             1 - Magnetico                             ³
	//³             2 - Não Magnético                         ³
	//³             3 - CPF                                   ³
	//³             4 - Abandona                              ³
	//³             5 - Codigo da Matricula se existir o      ³
	//³                 template de Drogaria                  ³
	//³aRetCart[2] -> Retorna o numero do cartao ou do CPF    ³
	//³             1,2 -> Numero do cartão                   ³
	//³             3 -> numero do cpf                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aRetCart := aClone( L010TCart() )
	If ( aRetCart[1] == 4 ) .OR. ( Empty( aRetCart[2] ) )
		Return Nil		
	ElseIf aRetCart[1] == 1 .OR. aRetCart[1] == 2
		cCartao	:= aRetCart[2]		
	ElseIf aRetCart[1] == 3
		cCPF	:= aRetCart[2]		 
	ElseIf HasTemplate( "DRO" ) .AND. aRetCart[1] == 5
		cMatricula 	:= aRetCart[2]
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cUsrSessionID)
	LJMsgRun(STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa o cliente na retaguarda para verificar se existe mais de 1 ³
//³ cliente com o mesmo CPF ou se houve alteracao no cliente            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRegsSA1 := CRDCliR2Pdv( cCartao, cCPF, cMatricula )
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se foi encontrado mais de um cliente. Mostra uma tela para o usuario ³
//³ escolher qual o cliente ele quer pesquisar. Se houver apenas 1 registro     ³
//³ verifica se a variavel esta' com conteudo e define as variaveis cCliente e  ³
//³ cLojaCli.                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aRegsSA1 ) >= 2
	aRetCli := CRDxTelaCl( aRegsSA1 )
	If ValType( aRetCli ) == "A" .AND. Len( aRetCli ) >= 2
		cCliente 	:= aRetCli[1]
		cLojaCli 	:= aRetCli[2] 
		lContinua	:= .T.
	Else
		lContinua := .F.
	Endif
ElseIf Len( aRegsSA1 ) == 1
	nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )
	If nPosTmp > 0
		cCliente := aRegsSA1[1][nPosTmp][2]
	Endif
	nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
	If nPosTmp > 0
		cLojaCli := aRegsSA1[1][nPosTmp][2]
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrou o cliente nao continua o processamento         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCliente := ""
	cLojaCli := ""
	lContinua := .F.
Endif

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a transacao WebService para pegar as informacoes dos titulos do    ³
	//³cliente                                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcao == 1	// Consulta Extrato
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a transacao Web Service para o extrato das parcelas. Faz o tratamen-³
		//³to se a transacao ainda estah ativa, caso contrario, faz novo login e     ³
		//³chama o metodo GetExtrato novamente                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSvc := WSCRDEXTRATO():New()
		
		//*** Fazer o tratamento para mudar o caminho
		oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDEXTRATO.apw"
		
		lWSExtrato := .T.
		While lWSExtrato
		    //"Aguarde... Pesquisando as parcelas ..."
			MsgRun( STR0040, "", {|| lRet := oSvc:GETEXTRATO( cUsrSessionID, cCartao, cCPF, cCliente, cLojaCli ) } ) 
			If !lRet
				cSvcError := GetWSCError()
				If Left(cSvcError,9) == "WSCERR048"					
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					
					// Se necessario efetua outro login antes de chamar o metodo GetExtrato novamente
					If cSoapFCode $ "-1,-2,-3"
						LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
						lWSExtrato := .T.
					Else
						MsgStop(cSoapFDescr, "Error " + cSoapFCode)	
						lWSExtrato := .F.	// Nao chama o metodo GetExtrato novamente
					Endif					
				Else               
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³"Sem comunicação com o WebService!","Atenção."³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsgStop(STR0078, STR0079)
					lWSExtrato := .F. // Nao chama o metodo GetExtrato novamente
				Endif
			Else
				For nX := 1 to Len(oSvc:oWSGETEXTRATORESULT:oWSWSEXTRATO)
					aAdd( aExtrato, oSvc:oWSGETEXTRATORESULT:oWSWSEXTRATO[nX]:cLINHA )
				Next nX
				lWSExtrato := .F.	// Nao chama o metodo GetExtrato novamente
			Endif
		End		
	ElseIf nOpcao == 2		// Consulta limite de credito		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a transacao Web Service para o limite de credito.    Faz o tratamen-³
		//³to se a transacao ainda estah ativa, caso contrario, faz novo login e     ³
		//³chama o metodo GetLimite novamente                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSvc := WSCRDLIMITE():New()
		
		//*** Fazer o tratamento para mudar o caminho
		oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDLIMITE.apw"
		
		lWSLimite := .T.
		While lWSLimite
			MsgRun( STR0040, "", {|| lRet := oSvc:GETLIMITE( cUsrSessionID, cCartao, cCPF, cCliente, cLojaCli ) } ) //"Aguarde... Pesquisando as parcelas ..."
			If !lRet
				cSvcError := GetWSCError()
				If Left(cSvcError,9) == "WSCERR048"					
					cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
					
					// Se necessario efetua outro login antes de chamar o metodo GetLimite novamente
					If cSoapFCode $ "-1,-2,-3"
						LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) // "Aguarde... Efetuando login no servidor ..."
						lWSLimite := .T.
					Else
						MsgStop(cSoapFDescr, "Error " + cSoapFCode)
						lWSLimite := .F.	// Nao chama o metodo GetLimite novamente
					Endif					
				Else                                                       
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³"Sem comunicação com o WebService!","Atenção."³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsgStop(STR0078, STR0079)
					lWSLimite := .F. // Nao chama o metodo GetLimite novamente
				Endif
			Else
				For nX := 1 to Len(oSvc:oWSGETLIMITERESULT:oWSWSLIMITE)
					aAdd( aExtrato, oSvc:oWSGETLIMITERESULT:oWSWSLIMITE[nX]:cLINHA )
				Next nX
				lWSLimite := .F.	// Nao chama o metodo GetLimite novamente
			Endif
		End
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra o extrato na tela com a opcao de impressao no ECF                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( aExtrato )
		CrdAImpEx( aExtrato )
	Endif
	
	If ExistBlock("CRDCON")
		ExecBlock("CRDCON",.F.,.F.,{cCPF, cCartao})
	Endif		
Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdAImpEx ºAutor  ³Vendas Clientes     º Data ³  13/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra o extrato na tela possibilitando a impressao no ECF  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdAImpEx( aExtrato )
Local lImprime 		:= .F.
Local cTexto 		:= ""
Local cExtrato		:= ""
Local nX			:= 0
Local oExtrato
Local oFntExtrato
Local oDlgRes

If GetRemoteType() <> REMOTE_LINUX	   				// Caso a plataforma seja Windows mantem o tamanho da Fonte do Cupom da Tela.
	DEFINE FONT oFntExtrato	NAME "Courier New"	   	SIZE 7,19
Else                                                // Caso a plataforma seja Linux diminui o tamanho da Fonte do Cupom da Tela.
	DEFINE FONT oFntExtrato	NAME "Courier New"	   	SIZE 3,15
Endif

If !Empty(aExtrato) .AND. ValType(aExtrato) == "A"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra as informacoes na tela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgRes FROM 0,0 TO 360,351 TITLE "" PIXEL

	DEFINE SBUTTON FROM 164,115 TYPE 06 ACTION (lImprime := .T., oDlgRes:End()) ENABLE WHEN CrdCupAberto()
	DEFINE SBUTTON FROM 164,145 TYPE 01 ACTION (oDlgRes:End()) ENABLE
	
	@ 1, 1 LISTBOX oExtrato VAR cExtrato SIZE 174,160 PIXEL FONT oFntExtrato ITEMS aExtrato OF oDlgRes
	oExtrato:SetArray( aExtrato )
	
	ACTIVATE MSDIALOG oDlgRes CENTERED
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for imprimir, verifica se o usuario eh fiscal                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImprime .AND. lFiscal
	For nX := 1 to Len( aExtrato )
		cTexto += aExtrato[nX] + Chr(10)
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a funcao de impressao de relatorio gerencial                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "CRD002" )
		ExecBlock( "CRD002", .F., .F., cTexto )
	Else
		nRet := IFRelGer( nHdlECF, cTexto, 1)
	Endif
Endif

Return Nil
     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdCupAberºAutor  ³Vendas Clientes     º Data ³ 12/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao para habilitar o botao de Impressao.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACRD                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Function CrdCupAberto()
Local lRet     := lFiscal                     
Local cRetorno := ""
Local nRet     := 0

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se o cupom fiscal esta aberto.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := IFStatus( nHdlECF, '5', @cRetorno )
	If nRet == 7
		lRet := .F.
	Else
		If L010AskImp(.F.,nRet)
			lRet := .F.
		Endif
	Endif	
Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdTitAbertoºAutor³Vendas Clientes     º Data ³  17/07/03    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor dos titulos em aberto para um determinado    º±±
±±º          ³cliente.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³nExp1 := CrdTitAberto( cExp2, cExp3, nExp4, cExp5, aExp6 ,   º±±
±±º          ³                       aExp7)							       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp2 - Codigo do cliente                                    º±±
±±º          ³cExp3 - Loja do cliente                                      º±±
±±º          ³nExp4 - Tipo da consulta [OPCIONAL]                          º±±
±±º          ³        1 - Saldo do mes                                     º±±
±±º          ³        2 - Saldo Total                                      º±±
±±º          ³cExp5 - Periodo da consulta (AAAAMM) [OPCIONAL]              º±±
±±º          ³aExp6 - Saldos por mes                                       º±±
±±º          ³aExp7 - NCCs pendentes do cliente avaliado                   º±±
±±º          ³nExp8 - Valor de NCC em aberto do cliente                    º±± 	
±±º          ³lExp9 - Indica se foi chamado da analise de credito          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³nExp1 - Valor das parcelas em aberto                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³Se nao for informado o tipo da consulta 1 ou 2 a funcao      º±±
±±º          ³irah checar o tipo de endividamento do cliente. Exemplo: se  º±±
±±º          ³o endividamento for mensal o resultado serah a somatoria das º±±
±±º          ³parcelas do mes informado no 4o parametro.Se o endividamento º±±
±±º          ³for global o 4o parametro eh descartado e a somatoria sera   º±±
±±º          ³de todas as parcelas em aberto.                              º±±
±±º          ³                                                             º±±
±±º          ³Caso o 4o parametro nao seja informado, o periodo considera- º±±
±±º          ³do serah o referente a dDatabase.                            º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaCRD                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdTitAberto( cCliente    , cLoja    , nTipo  , cPeriodo, ;
                       aSaldoMeses ,aNCCVenda , nTotNCC, lCRM010)

 
Local nValor		:= 0                            
Local nValorMAL		:= 0
Local nValorSE1		:= 0  
Local nX			:= 0
Local nI			:= 0									// Variavel para o For
Local nValorNCC     := 0                                   	// Valor das NCCS em aberto
Local nTamE1_NUMCRD := TamSx3("E1_NUMCRD")[1]             	// Tamanho do campo E1_NUMCRD

Local aLjFilWS    	:= StrToKArr(SuperGetMV("MV_LJFILWS"), ",")
Local lMAHExc     	
Local lMALExc     	
Local lSE1Exc		
Local lUsaQuery     := .F.
Local lAchou        := .T.

Local cStrMAH     	:= ""
Local cStrMAL     	:= ""
Local cSubString    := ""
Local cMVCRDTPLC	:= SuperGetMV("MV_CRDTPLC",,"FI")		// Tipos dos titulos que entrarao na soma dos titulos em aberto para abater do limite do cliente
Local cMV_CRDTIT	:= SuperGetMV("MV_CRDTIT",,"1")		    // Controla se deve considerar apenas os titulos jah avaliados pelo SIGACRD(E1_NUMCRD preenchido) ou todos 
Local cAliasTrb                                             // Alias da area de trabalho
Local cMVCRNEG      := MV_CRNEG                            	// Conteudo do parametro MV_CRNEG
Local aMVCRNEG      := {} 		                            // Array para manipular o parametro MV_CRNEG
Local aMVCRDTPLC	:= {} 		                           	// Array para manipular a variavel cMVCRDTPLC
Local aStru         := {}                                  	// Estrutura do campo SE1 e MAL para TCSetField
Local nMVLjChVst	:= SuperGetMV("MV_LJCHVST",,-1)		// Quantos dias considera um cheque a vista. Se for -1 nao trata o parametro
Local nRecnoSE1     := 0                                   	// Recno do SE1 para verificar se a NCC foi selecionada para compensacao
Local nPosRecno     := 0                                   	// Posicao do registro da NCC no SE1
Local aFilSE1 		:= {}									// Guarda as filiais em que o cliente possui titulos
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)				// Verifica as filiais da trabalharam com acrescimento separado
Local cSepRec       := If("|"$MVRECANT,"|",",")            // Tratamento para recebimento antecipado
Local lR5			:= GetRpoRelease("R5")					// Indica se o release e 11.5
Local lPosCrd		:= IsInCallStack("FWHOSTCONNECT") 	//Integração TotvsPDV x SIGACRD, como é retaguarda estou lendo se utilizou STBRemoteExecute no PDV através do FWHostConnect (Se FrontLoja, é __WSCONNECT). OBS: NÃO DEPENDO DE CONFIGURAR INTEGRAÇÃO SIGACRD NA RETAGUARDA. 

DEFAULT aSaldoMeses  := {}
DEFAULT nTipo 		 := 0
DEFAULT cPeriodo	 := Substr(Dtos(dDatabase),1,6)
DEFAULT aNCCVenda    := {}                                 	// Array com as NCCs pendentes do cliente. O valor da NCC deve ser abatido da soma dos titulos em aberto  
DEFAULT nTotNCC		 := 0									// Retorno do valor de NCC em aberto do cliente	
DEFAULT lCRM010		 := .F.

#IFDEF TOP          
	If AllTrim(TcSrvType()) <> "AS/400"
		lUsaQuery := .T.
	Endif
#Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout("CRDXFUN.CrdTitAberto.INICIO")

lMAHExc	:= FWModeAccess("MAH",3) = "E"
lMALExc	:= FWModeAccess("MAL",3) = "E"
lSE1Exc	:= FWModeAccess("SE1",3) = "E"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a select area somente para o Protheus abrir os arquivos³
//³ no caso de WebService                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSelectArea("MAL")
DbSelectArea("MAH")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o arquivo MA7                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( Upper( Trim( FunName() ) ) $ "CRDA080/CRDA010/CRDA180") //No programa de Liberacao, o MA7 ja e posicionado
	DbSelectArea("MA7")
	DbSetOrder(1)	//  FILIAL + CODCLI + LOJA
	lAchou := DbSeek(xFilial("MA7")+cCliente+cLoja)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica como serao pesquisado os titulos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchou
	If nTipo == 0
		nTipo = 2	// pega o saldo de todas as parcelas
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a pesquisa do valor em aberto                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lUsaQuery	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta a variavel cMVCRDTPLC para incluir na Query           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aMVCRDTPLC := StrToKArr( cMVCRDTPLC, "," )
		cMVCRDTPLC := "("
		aEval( aMVCRDTPLC, { |x| cMVCRDTPLC += "'" + x + "'," } )
		cMVCRDTPLC := Substr(cMVCRDTPLC,1,Len(cMVCRDTPLC)-1) + ")"      
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche array de estruturas para TCSetField 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
	    aStru    := {}
	    CrdCriaStru("MAL"   ,@aStru)
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata as diferencas para Oracle e Informix                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !( AllTrim( Upper( TcGetDb() ) ) $ "ORACLE_INFORMIX" )
			cSubstring := "SUBSTRING"
		Else
			cSubstring := "SUBSTR"
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona as parcelas no MAL dos contratos efetuados		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT "
		cQuery += "'MAL' AS ALIAS, "+cSubstring + "( MAL.MAL_VENCTO,1,6 ) AS VENCTO, (SUM(MAL.MAL_SALDO)) AS SALDO "
		cQuery += "FROM " + RetSQLName("MAL") + " MAL, " + RetSQLName("MAH") + " MAH "
		cQuery += "WHERE "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as filiais de acordo com o modo de abertura           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMAHExc
			cQuery += "MAH.MAH_FILIAL >= '" + aLJFilWS[1] + "' AND "
			cQuery += "MAH.MAH_FILIAL <= '" + aLJFilWS[2] + "' AND "
		Else
			cQuery += "MAH.MAH_FILIAL = '" + xFilial("MAH") + "' AND "
		Endif		

		If lMALExc
			cQuery += "MAL.MAL_FILIAL >= '" + aLJFilWS[1] + "' AND "
			cQuery += "MAL.MAL_FILIAL <= '" + aLJFilWS[2] + "' AND "
		Else
			cQuery += "MAL.MAL_FILIAL = '" + xFilial("MAL") + "' AND "
		Endif		

		cQuery += "MAL.MAL_SALDO > 0 AND "         
		cQuery += "MAL.MAL_CONTRA = MAH.MAH_CONTRA AND "
		cQuery += "MAL.MAL_FILIAL = MAH.MAH_FILIAL AND "
		cQuery += "MAH.MAH_CODCLI = '" + cCliente + "' AND "
		cQuery += "MAH.MAH_LOJA = '" + cLoja + "' AND "
		cQuery += "MAH.MAH_TRANS = '1' AND "         //Contratos OK
		
		If nTipo == 1 	// pega soh as parcelas do mes
			cQuery += cSubstring + "( MAL.MAL_VENCTO,1,6 ) = '" + Substr( Dtos(dDatabase),1,6 ) + "' AND "
		Endif
		
		cQuery += "MAH.D_E_L_E_T_ <> '*' AND "
		cQuery += "MAL.D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY "+cSubstring + "( MAL.MAL_VENCTO,1,6 )"
      
		cQuery := ChangeQuery(cQuery)
		MemoWrite("CRDXTITAB1.SQL",cQuery)
		
		cAliasTrb := GetNextAlias()
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)

	    For nX := 1 To Len(aStru)
		   TcSetField(cAliasTRB,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    Next nX
		
		nValor := 0
		DbSelectArea(cAliasTrb)
		DbGoTop()    
		aSaldoMeses := {}
		While !Eof()
			CrdGuardaMes(&(cAliasTrb+"->SALDO")  ,SubStr(&(cAliasTrb+"->VENCTO"),1,6)  ,@aSaldoMeses)
			nValor += &(cAliasTrb+"->SALDO")
			DbSkip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAliasTrb)
		dbCloseArea()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona os titulos em aberto do cliente analisado			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche array de estruturas para TCSetField 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
	    aStru    := {}
	    CrdCriaStru("SE1"   ,@aStru)	    
		
		cQuery := "SELECT "
		cQuery += "'SE1' AS ALIAS, "
		cQuery += cSubstring + "( SE1.E1_VENCTO,1,6 ) AS VENCTO, "
		cQuery += "(SUM(SE1.E1_SALDO)) AS SALDO, "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³INCLUIR O ACRESCIMO FINANCEIRO NA COMPOSICAO  DO SALDO DOS TITULOS EM ABERTO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")	
			cQuery += "(SUM(SE1.E1_ACRESC)) AS ACRESC, "
		Endif  
		
		cQuery += "SE1.E1_TIPO AS TIPO, "		
		cQuery += "SE1.E1_VENCTO AS DTVENCTO "				 //Data de vencimento completa
		cQuery += "FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += "WHERE "

		If lSE1Exc
			cQuery += "SE1.E1_FILIAL >= '" + aLJFilWS[1] + "' AND "
			cQuery += "SE1.E1_FILIAL <= '" + aLJFilWS[2] + "' AND "
		Else
			cQuery += "SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND "
		Endif		

		cQuery += "SE1.E1_CLIENTE = '" + cCliente + "' AND "
		cQuery += "SE1.E1_LOJA = '" + cLoja + "' AND "
		cQuery += "SE1.E1_SALDO > 0 AND "
		cQuery += "LTRIM(RTRIM(SE1.E1_TIPO)) IN " + cMVCRDTPLC + " AND "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se deve considerar apenas os titulos ja avaliados pelo SIGACRD    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    		
		If cMV_CRDTIT == "1"
		   cQuery += "SE1.E1_NUMCRD <> '"+Space(nTamE1_NUMCRD)+"' AND "	//Trazer soh titulos com num. de contrato (SIGACRD)
		Endif   
				
		If nTipo == 1 	// pega soh as parcelas do mes
			cQuery += cSubstring + "( SE1.E1_VENCTO,1,6 ) = '" + Substr( Dtos(dDatabase),1,6 ) + "' AND "
		Endif		
		cQuery += "SE1.D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY "+cSubstring + "( SE1.E1_VENCTO,1,6 ), SE1.E1_VENCTO, SE1.E1_TIPO "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o tratamento/compatibilidade com o Top Connect    		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := ChangeQuery(cQuery)
		MemoWrite("CRDXTITAB2.SQL",cQuery)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega uma sequencia de alias para o temporario.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasTrb := GetNextAlias()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o ALIAS do arquivo temporario                     		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)

	    For nX := 1 To Len(aStru)
		   TcSetField(cAliasTRB,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o valor dos titulos em aberto                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAliasTrb)
		DbGoTop()
		While !Eof()
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Se for cheque, deve considerar MV_LJCHVST					 ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
			If IIf(Alltrim(&(cAliasTrb+"->TIPO")) == Alltrim(MVCHEQUE),(nMVLjChVst == -1 .OR. &(cAliasTrb+"->DTVENCTO") >= dDataBase + nMVLjChVst),.T.)		
			   
			   CrdGuardaMes(&(cAliasTrb+"->SALDO")  ,SubStr(&(cAliasTrb+"->VENCTO"),1,6)  ,@aSaldoMeses)
			   nValor += &(cAliasTrb+"->SALDO")
		   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³INCLUIR O ACRESCIMO FINANCEIRO NA COMPOSICAO  DO SALDO DOS TITULOS EM ABERTO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")    
					nValor += &(cAliasTrb+"->ACRESC")
				Endif		
			Endif
			DbSkip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAliasTrb)
		dbCloseArea()		

		IF !lPosCrd	//Se não for Integração TOTVSPDV x SIGACRD, continua descontando o NCC somente no pop-up da Análise de Crédito.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta a variavel cMVCRNEG para incluir na Query             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aMVCRNEG := StrToKArr( cMVCRNEG, "," )
			cMVCRNEG := "("
			aEval( aMVCRNEG, { |x| cMVCRNEG += "'" + x + "'," } )
			cMVCRNEG := Substr(cMVCRNEG,1,Len(cMVCRNEG)-1) + ")"      
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona notas de credito para abater do saldo de titulos em aberto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cQuery := "SELECT "
			cQuery += "SE1.R_E_C_N_O_ AS SE1RECNO, "		
			cQuery += "SE1.E1_SALDO AS SALDO, "
			cQuery += "SE1.E1_VENCTO AS DTVENCTO "				 
			cQuery += "FROM " + RetSQLName("SE1") + " SE1 "
			cQuery += "WHERE "
	
			If lSE1Exc
				cQuery += "SE1.E1_FILIAL >= '" + aLJFilWS[1] + "' AND "
				cQuery += "SE1.E1_FILIAL <= '" + aLJFilWS[2] + "' AND "
			Else
				cQuery += "SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND "
			Endif		
	
			cQuery += "SE1.E1_CLIENTE = '" + cCliente + "' AND "
			cQuery += "SE1.E1_LOJA = '" + cLoja + "' AND "
			cQuery += "SE1.E1_SALDO > 0 AND "
			cQuery += "( LTRIM(RTRIM(SE1.E1_TIPO)) IN " + cMVCRNEG + " "
			cQuery += " OR SE1.E1_TIPO IN " + FormatIn(MVRECANT,cSepRec)  + " ) AND "						
			If nTipo == 1 	// pega soh as parcelas do mes
				cQuery += cSubstring + "( SE1.E1_VENCTO,1,6 ) = '" + Substr( Dtos(dDatabase),1,6 ) + "' AND "
			Endif		
			cQuery += "SE1.D_E_L_E_T_ <> '*' "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o tratamento/compatibilidade com o Top Connect    		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := ChangeQuery(cQuery)
			MemoWrite("CRDXTITAB3.SQL",cQuery)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega uma sequencia de alias para o temporario.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAliasTrb := GetNextAlias()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o ALIAS do arquivo temporario                     		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
	
		    For nX := 1 To Len(aStru)
			   TcSetField(cAliasTRB,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
		    Next nX
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega o valor das NCCs em aberto                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(cAliasTrb)
			DbGoTop()
			nValorNCC  	:= 0
			nTotNCC 	:= 0	
			While !Eof()		   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a rotina tenha sido chamado pelo analista de credito,³
				//³o valor de NCCs e mostrado separadamente e nao deve ser   ³
				//³abatido das parcelas em aberto                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCRM010
		        	nTotNCC += &(cAliasTrb+"->SALDO")
				Else	
				   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   	//³Se a NCC foi selecionada para compensacao nao deve abater do  ³
				   	//³saldo em aberto do cliente									³		   
				   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					If LEN(aNCCVenda) > 0
				    	nRecnoSE1  := &(cAliasTrb+"->SE1RECNO")      
				      	nPosRecno  := Ascan(aNCCVenda,{|x| x[5] == nRecnoSE1})
				      	If nPosRecno > 0 .AND. aNCCVenda[nPosRecno][1]
				        	DbSkip()
				         	Loop   
				      	Endif
				   	Endif   
			   		nValorNCC += &(cAliasTrb+"->SALDO")
				Endif
			   	DbSkip()
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha a area de trabalho                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(cAliasTrb)		
			dbCloseArea()		   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abate o valor das NCCs do saldo de titulos em aberto		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			nValor  := nValor  - nValorNCC
		EndIf
		
		Conout("1. CRDXFUN CrdtitAberto, nValor " + ALLTRIM(STR(nValor)))
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona os arquivos                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MAL->(DbSetOrder(1))	// FILIAL + CONTRA
		
		DbSelectArea("MAH")
		DbSetOrder( 2 ) 	   // FILIAL + CODCLI + LOJA + CONTRA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as filiais de acordo com o modo de abertura           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMAHExc
			DbSeek(aLJFilWS[1]+cCliente+cLoja)
			cStrMAH := {||!Eof() .AND. (MAH->MAH_FILIAL >= aLJFilWS[1] .AND.;
						    MAH->MAH_FILIAL <= aLJFilWS[2]) .AND.;
						    MAH->MAH_CODCLI+MAH->MAH_LOJA == cCliente+cLoja }
		Else
		    DbSeek(xFilial("MAH")+cCliente+cLoja)
			cStrMAH := {||!Eof() .AND. MAH->MAH_FILIAL+MAH->MAH_CODCLI+MAH->MAH_LOJA == xFilial('MAH')+cCliente+cLoja }
		Endif

		nValorMal := 0
		nValorSE1 := 0
		nValorNCC := 0
	    While Eval(cStrMAH)
			If Val(MAH->MAH_TRANS) == TRANS_OK
				DbSelectArea("MAL")

				If lMALExc
					DbSeek(aLJFilWS[1]+MAH->MAH_CONTRA)
					cStrMAL := {||!Eof().AND. (MAL->MAL_FILIAL >= aLJFilWS[1] .AND.;
					 				MAL->MAL_FILIAL <= aLJFilWS[2]) .AND.;
					 				MAL->MAL_CONTRA == MAH->MAH_CONTRA }
				Else
				    DbSeek(xFilial("MAH")+MAH->MAH_CONTRA)
					cStrMAL := {||!Eof().AND. MAL->MAL_FILIAL+MAL->MAL_CONTRA == xFilial("MAL")+MAH->MAH_CONTRA }
				Endif

				While Eval(cStrMAL)

					If (nTipo == 2) .OR. (nTipo == 1 .AND. Substr(Dtos(MAL->MAL_VENCTO),1,6) <= cPeriodo)
						CrdGuardaMes(MAL->MAL_SALDO  ,SubStr(DtoS(MAL->MAL_VENCTO),1,6)  ,@aSaldoMeses)
						nValorMAL += MAL->MAL_SALDO
					Endif
					DbSkip()
				End
			Endif			
			DbSelectArea("MAH")
			DbSkip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a somatoria do SE1 e pesquisa se o cliente possui titulos em aberto em todas as filiais  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(2)		// Filial + Cliente + Loja + Prefixo + Num + Parcela + Tipo		
		If lSE1Exc                                
			DbSelectArea("SM0")
			DbGoTop()
			While !Eof()
				If M0_CODIGO <> cEmpAnt
					DbSkip()
					Loop
				Endif
				If FWGETCODFILIAL < aLJFilWS[1] .OR. FWGETCODFILIAL > aLJFilWS[2]
					DbSkip()
					Loop
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza no array apenas as filiais em que o cliente possui titulos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE1")
				DbSetOrder(2)
				If DbSeek(FWGETCODFILIAL+cCliente+cLoja)
					Aadd(aFilSE1, FWGETCODFILIAL)
				Endif        

				DbSelectArea("SM0")
				DbSkip()				
			End		
		Else           
			Aadd(aFilSE1, xFilial("SE1"))
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Compoe o saldo de titulos em aberto de acordo com as filiais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len(aFilSE1)
			DbSelectArea("SE1")
			DbSetOrder(2)
			DbSeek(aFilSE1[nI]+cCliente+cLoja)
			While (SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA) == (aFilSE1[nI] + cCliente + cLoja)
			
				If SE1->E1_SALDO == 0
				   DbSkip()
				   Loop 
				Endif  
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona notas de credito para abater do saldo de titulos em aberto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				If ALLTRIM(SE1->E1_TIPO) $ MV_CRNEG
					If !lPosCrd		//Se não for Integração TOTVSPDV x SIGACRD, continua descontando o NCC somente no pop-up da Análise de Crédito.
					   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					   //³Considera apenas as parcelas do mes³
					   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					   If nTipo == 1
					      If SUBSTR(SE1->E1_VENCTO,1,6) <> SUBSTR(DTOS(dDatabase),1,6)
					         DbSkip()
					         Loop
					      Endif                                                          
					   Endif                     
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a rotina tenha sido chamado pelo analista de credito,³
						//³o valor de NCCs e mostrado separadamente e nao deve ser   ³
						//³abatido das parcelas em aberto                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCRM010
				  			nTotNCC += SE1->E1_SALDO
						Else			                             
					 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se a NCC foi selecionada para compensacao nao deve abater do  ³
							//³saldo em aberto do cliente									 ³		   
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
							If LEN(aNCCVenda) > 0
						 		nRecnoSE1  := SE1->(Recno())
						   		nPosRecno  := Ascan(aNCCVenda,{|x| x[5] == nRecnoSE1})
								If nPosRecno > 0 .AND. aNCCVenda[nPosRecno][1]
						        	DbSkip()
						  			Loop 
						  		Endif  
							Endif
					        nValorNCC  += SE1->E1_SALDO
						Endif   
					EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o saldo do titulo eh maior que zero;                               ³
				//³ se o tipo do titulo está contido no parametro MV_CRDTPLC;                      ³
				//³ se for titulo em cheque se eh pre-datado.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf ALLTRIM(SE1->E1_TIPO) $ cMVCRDTPLC .AND. IIf(ALLTRIM(SE1->E1_TIPO) == ALLTRIM(MVCHEQUE) .AND. ;
				    nMVLjChVst > -1,(SE1->E1_VENCTO >= dDataBase + nMVLjChVst),.T.)			   
				    
					If IIf(cMV_CRDTIT == "1",SE1->E1_NUMCRD <> Space(nTamE1_NUMCRD),.T.) 
						If (nTipo == 2) .OR. (nTipo == 1 .AND. Substr(Dtos(MAL->MAL_VENCTO),1,6) <= cPeriodo)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³INCLUIR O ACRESCIMO FINANCEIRO NA COMPOSICAO  DO SALDO DOS TITULOS EM ABERTO ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")   
								CrdGuardaMes(SE1->E1_SALDO+SE1->E1_ACRESC,SubStr(DtoS(SE1->E1_VENCTO),1,6)  ,@aSaldoMeses)                                     
								nValorSE1 += SE1->E1_SALDO + SE1->E1_ACRESC                    
							Else
								CrdGuardaMes(SE1->E1_SALDO  ,SubStr(DtoS(SE1->E1_VENCTO),1,6)  ,@aSaldoMeses)
								nValorSE1 += SE1->E1_SALDO                                      
							Endif							
						Endif
					Endif
				Endif
				
				DbSelectArea("SE1")
				DbSkip()
			End
		Next nI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma os valores dos titulos em aberto para o cliente         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		nValor := (nValorMAL + nValorSE1) - nValorNCC
	Endif	
Endif

Conout("2.CRDXFUN - CrdTitAberto - Valor dos titulos em aberto do cliente : " +;
		If( Empty(cCliente), "", cCliente) + "/" +;
		If( Empty(cLoja), "", cLoja) +;
		" Valor: "+ ALLTRIM(Str(nValor)))    

Return (nValor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³WSCrdLoginºAutor  ³Vendas Clientes     º Data ³  23/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o login para fazer as transacoes Web Service            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³cExp1 := WSCrdLogin( cExp2, cExp3 )                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cExp1 - ID do usuario, que ira validar toda transacao Web   º±±
±±º          ³        Service                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp2 - Nome do usuario (cadastrado no Protheus)            º±±
±±º          ³cExp3 - Senha  (cadastrada no Protheus)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WSCrdLogin( cUser, cPassword )

Local cUsrID		:= ""				//Id do Usuario
Local oSvcLogin							//Objeto WS - WSCRDLOGIN

Default cPassword := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao do objeto WS - WSCRDLOGIN³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvcLogin 				:= WSCRDLOGIN():New()
oSvcLogin:_URL 			:= "http://" + AllTrim( LJGetStation( "WSSRV" ) ) + "/CRDLOGIN.apw"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros do metodo SESSIONLOGIN³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(cPassword)
	cPassword := cSenha
EndIf
oSvcLogin:cUSRNAME 		:= cUser
oSvcLogin:cUSRPASSWORD 	:= Encript( cPassword, 0 )

If oSvcLogin:SESSIONLOGIN()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do Metodo SESSIONLOGIN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cUsrID := oSvcLogin:cSESSIONLOGINRESULT	
Else
	CRDRetErroWS( GetWsCError(), GetWsCError( 3 ) )
Endif

Return cUsrID

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdUpdUserºAutor  ³Vendas Clientes     º Data ³ 25/07/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a atualizacao da variavel cUsrSessionID para evitar queº±±
±±º          ³ seja feito 2 processamentos para LOG do ID                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdUpdUser( cUser )

//Atualizacao da variavel estatica para LOG
cUsrSessionID := cUser

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CRDConsTEFºAutor  ³Vendas Clientes     º Data ³ 07/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as variaveis necessarias para consulta ao TEF para  º±±
±±º          ³SPC e SERASA                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GENERICO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDConsTEF()
Local lRet          := .T. //Retorno da Funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao para consulta TEF.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOJA012T(.F.)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CA095ListCºAutor  ³Vendas Clientes     º Data ³  24/06/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para selecionar campos para retorno.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDListCpos( cTabela, aCampos )
Local nX := 0                     //Contador do sistema
Local oDlgCons                    //Dialog da Listbox
Local oListBox                    //Objeto da listbox
Local aListCpos := {}             //Array da ListBox
Local nPosAlias := 0              //Posicao do campo de Alias
Local oOk := LoadBitmap(GetResources(), "LBOK")   //Desenho do Checked
Local oNo := LoadBitmap(GetResources(), "LBNO")   //Desenho do Not Checked
Local oCheckBox
Local lCheckBox := .F.            //Selecionar todos os campos do ListBox
Local aRet      := {}
Local lOk       := .F.            //Confirmacao da tela

DEFAULT cTabela := ""
DEFAULT aCampos := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao faco a montagem da estrutura para o caso da tabela estiver em branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cTabela )
	Return aRet
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a Array estatica aList esteja em branco, faz o preenchimento, esta ³
//³ Array tem por objetivo, fazer o <Cache> dos campos da tabela MA6.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( aList )
	DbSelectArea( "SX3" )
	DbSetOrder( 1 )
	DbSeek( cTabela )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem da estrutura da tabela selecionada                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Eof() .AND. X3_ARQUIVO == cTabela
		If X3USO( X3_USADO )
			AAdd( aListCpos,{.F.,X3_TITULO,X3_CAMPO,X3_TAMANHO,X3_DECIMAL} )
			If aScan( aCampos,{| ExpA1 | PadR(ExpA1,10) == aListCpos[Len(aListCpos)][3] } ) > 0
				aListCpos[Len(aListCpos)][1] := .T.
			Else                                   
				aListCpos[Len(aListCpos)][1] := .F.
			Endif
		Endif              
		
		DbSkip()
	End
	
	If Empty( aListCpos )
		MsgStop( STR0022, STR0023 ) //"Não existe campos em uso da tabela selecionada!"###"Atenção"
		Return aRet 
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guardo a estrutura em Cache.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aList, {cTabela,aListCpos})
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a estrutura existe em cache, retiro a mesma, caso contrario, monto e ³
	//³ depois guardo em cache.                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosAlias := aScan( aList,{|ExpA1| ExpA1[1] == cTabela})
	If nPosAlias > 0
		aListCpos := aClone( aList[nPosAlias][2] )
		
		For nX := 1 to Len( aListCpos )
			If aScan( aCampos,{| ExpA1 | PadR(ExpA1,10) == aListCpos[nX][3] } ) > 0
				aListCpos[nX][1] := .T.
			Else
				aListCpos[nX][1] := .F.
			Endif
		Next nX
		
	Else
		DbSelectArea( "SX3" )
		DbSetOrder( 1 )
		DbSeek( cTabela )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem da estrutura do MA6                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() .AND. X3_ARQUIVO == cTabela
			If X3USO( X3_USADO )
				AAdd( aListCpos,{.F.,X3_TITULO,X3_CAMPO,X3_TAMANHO,X3_DECIMAL} )
				If aScan( aCampos,{| ExpA1 | PadR(ExpA1,10) == aListCpos[Len(aListCpos)][3] } ) > 0
					aListCpos[Len(aListCpos)][1] := .T.
				Else
					aListCpos[Len(aListCpos)][1] := .F.
				Endif
			Endif
			
			DbSkip()
		End
		
		If Empty( aListCpos )
			MsgStop( STR0022, STR0023 ) //"Não existe campos em uso da tabela selecionada!"###"Atenção"
			Return aRet 
		Endif			

		AAdd( aList, {cTabela,aListCpos})
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Tela.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgCons TITLE STR0024 FROM 9,0 TO 32,52 OF oMainWnd //"Estrutura de arquivo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ .5,.7 LISTBOX oListBox VAR cListBox Fields HEADER "",STR0025,STR0026,STR0027,STR0028 SIZE 155,145 //"Nome"###"Título"###"Tamanho"###"Decimais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a configuracao da ListBox.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListBox:SetArray(aListCpos)
oListBox:bLine      := { || { IIf(aListCpos[oListBox:nAt][1],oOk,oNo),aListCpos[oListBox:nAt,2],aListCpos[oListBox:nAt,3],aListCpos[oListBox:nAt,4],aListCpos[oListBox:nAt,5]} }
oListBox:bLDblClick := {|| aListCpos[oListBox:nAt][1] := !aListCpos[oListBox:nAt][1],oListBox:Refresh(),lCheckBox := .F.,oCheckBox:Refresh() }

@ 160,6 CHECKBOX oCheckBox VAR lCheckBox PROMPT STR0029 SIZE 60,7 OF oDlgCons ON CHANGE ; //"Inverter Todos"
( aEval(aListCpos,{ |ExpA1| ExpA1[1] := !ExpA1[1] }),oListBox:Refresh() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao de saida.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 004,170 TYPE 1 ACTION (lOk := .T., oDlgCons:End()) ENABLE OF oDlgCons
DEFINE SBUTTON FROM 020,170 TYPE 2 ACTION (lOk := .F., oDlgCons:End()) ENABLE OF oDlgCons

ACTIVATE MSDIALOG oDlgCons CENTERED

If lOk
	For nX := 1 to Len( aListCpos )
		If aListCpos[nX][1]
			AAdd( aRet, aListCpos[nX][3] )
		Endif
	Next nX	
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdxFila  ºAutor  ³Vendas Clientes     º Data ³ 26/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de tempo de fila da venda                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdxFila()
Local lRet         := .F.                  //Retorno da funcao
Local oDlgFila                             //Dialogo principal da fila
Local cEst         := ""                   //Estacao
Local oEst                                 //Objeto Estacao
Local cOper                                //Operador
Local oOper                                //Objeto Operador
Local oData                                //Objeto Data
Local cHoraChegada := Space(5)             //Hora de Chegada
Local oHoraChegada                         //Objeto Hora
Local oHoraAtend                           //Hora Atendimento
Local cHoraAtend   := SubStr(Time(),1,5)   //Hora do atendimento
Local lOk          := .F.                  //Confirmacao da tela
Local cTempo       := ""                   //Titulo do Tempo de fila
Local nPosicao	:= 000					    //Posição/Fila	

cEst  := SLG->LG_CODIGO + " - " + SLG->LG_NOME
cOper := cUserName

DEFINE MSDIALOG oDlgFila TITLE STR0030 FROM 0,0 TO 230,370 PIXEL //"Controle de tempo de Fila"

@ 05,05 TO 055,179 PIXEL OF oDlgFila
@ 58,05 TO 090,179 PIXEL OF oDlgFila

@ 10,10 SAY STR0031 SIZE 80,10 PIXEL //"Estação: "
@ 10,40 MSGET oEst VAR cEst SIZE 120,10 PIXEL WHEN .F.

@ 25,10 SAY STR0032 SIZE 80,10 PIXEL //"Operador: "
@ 25,40 MSGET oOper VAR cOper SIZE 60,10 PIXEL WHEN .F.

@ 40,10 SAY STR0033 SIZE 80,10 PIXEL //"Data: "
@ 40,40 MSGET oData VAR dDataBase SIZE 60,10 PIXEL WHEN .F.

@ 63,10 SAY STR0034 SIZE 80,10 PIXEL //"Hora Cheg: "
@ 63,45 MSGET oHoraChegada VAR cHoraChegada PICTURE "99:99" SIZE 30,10 ;
VALID CrdVldHora(@cTempo,cHoraAtend,@cHoraChegada) PIXEL

@63,88 SAY STR0052 SIZE 80,10 PIXEL //"Posição/Fila: "
@63,123 MSGET oPosicao VAR nPosicao PICTURE "999" SIZE 30,10 PIXEL

@ 77,88 SAY STR0035 SIZE 80,10 PIXEL //"Hora Atend: "
@ 77,123 MSGET oHoraAtend VAR cHoraAtend SIZE 30,10 PIXEL WHEN .F.

@ 77,10 SAY STR0036+ cTempo + STR0037 SIZE 80,10 PIXEL //"Tempo de Fila: "###" Minuto(s)"

DEFINE SBUTTON FROM 95, 120 TYPE 1 ACTION (lOk := .T.,oDlgFila:End()) ENABLE PIXEL OF oDlgFila
DEFINE SBUTTON FROM 95, 150 TYPE 2 ACTION (lOk := .F.,oDlgFila:End()) ENABLE PIXEL OF oDlgFila

ACTIVATE MSDIALOG oDlgFila CENTERED

If lOK
	CrdFilaGrv(cEst,cOper,dDataBase,cHoraChegada,cHoraAtend,nPosicao)
Endif

Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdVldHoraºAutor  ³Vendas Clientes     º Data ³ 27/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a inconsistencia e calculo da hora.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDXFUN - CrdxFila                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdVldHora( cTempo, cHoraAtend, cHoraChegada )

Local nTempo := 0

If ( Val(SubStr( cHoraChegada,1,2 )) > 23 .OR. Val(SubStr( cHoraChegada,4,2 )) > 59 ) .OR. ;
	Empty( StrTran( cHoraChegada,":") ) .OR. Len( AllTrim(StrTran( cHoraChegada,":")) ) <> 4 .OR. ;
	StrTran( cHoraChegada,":") < "0000" .OR. StrTran( cHoraChegada,":") > "9999"
	
	MsgStop( STR0038 , STR0023 ) //"Hora inválida!"###"Atenção"
	Return .F.
Endif

nTempo  := Abs( SubtHoras(dDataBase,cHoraChegada,dDataBase,cHoraAtend) )
cTempo  := IntToHora(nTempo,2)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdFilaGrvºAutor  ³Vendas Clientes     º Data ³ 27/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a execucao do WebService do tempo de fila e tambem     º±±
±±º          ³ a gravacao das informacoes (Arquivo MA3)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDXFUN - CrdxFila                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdFilaGrv( cEst      , cOper, dDtFila, cHoraChegada,;
                            cHoraAtend, nPosicao )

Local lWsFila     := .T.
Local lRet        := .F.
Local cSvcError   := "" 
Local cSoapFCode  := ""
Local cSoapFDescr := ""
Local cFila       := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cUsrSessionID)
	LJMsgRun(STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
Endif

oSvc := WSCRDFILA():New()

//*** Fazer o tratamento para mudar o caminho
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDFILA.apw"  

lWSFila := .T.
While lWSFila
    //"Aguarde... Efetuando a gravacao dos dados da fila ..."
	LJMsgRun( STR0041,, {|| lRet := oSvc:GETFILA( cUsrSessionID ,SubStr(cEst,1,3) ,cOper ,dDtFila  ,;
	                                               cHoraChegada  ,cHoraAtend        ,""    ,nPosicao )}) 
	If !lRet
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"		
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			
			// Se necessario efetua outro login antes de chamar o metodo GetFila novamente
			If cSoapFCode $ "-1,-2,-3"
				LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
				lWSFila := .T.
			Else
				MsgStop(cSoapFDescr, "Error " + cSoapFCode)
				lWSFila := .F.	// Nao chama o metodo GetFila novamente
			Endif			
		Else        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³"Sem comunicação com o WebService!","Atenção."³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(STR0078, STR0079)	
			lWSFila := .F. // Nao chama o metodo GetFila novamente
		Endif
	Else
 		cFila := oSvc:cGETFILARESULT
		lWSFila := .F.	// Nao chama o metodo GetFila novamente
	Endif
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdxVenda ºAutor  ³Vendas Clientes     º Data ³  19/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Realiza a transacao de venda integrada ao SIGACRD           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³aExp1 := CrdxVenda(cExp2,aExp3,cExp4,lExp5,lExp6,cExp7,     º±±
±±º          ³lExp8 												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp2 := Tipo da transacao                                  º±±
±±º          ³         "1" - Transacao de venda                           º±±
±±º          ³         "2" - Transacao de impressao e confirmacao         º±±
±±º          ³         "3" - Transacao de desfazimento da venda           º±±
±±º          ³aExp3 := Array (vide comentario abaixo)                     º±±
±±º          ³cExp4 := Numero do contrato de financiamento                º±±
±±º          ³lExp5 := Determina se eh Front Loja(tratamento especifico)  º±±
±±º          ³lExp6 := Determina se envia para o Crediario quando bloqueiaº±±
±±º          ³cExp7 := Verifica se deve realizar analise de credito, consiº±±
±±º          ³dera o modulo e o processo(operacao)						  º±±
±±º          ³lExp8 := Determina se eh modo de consulta de credito 	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array contendo:                                             º±±
±±º          ³aRet[1] - Retorno da Funcao                                 º±± 
±±º          ³              0 - Aprovado                                  º±±
±±º          ³              1 - Nao aprovado                              º±±
±±º          ³              2 - Aprovado Off-line                         º±±
±±º          ³              3 - Rejeitado                                 º±±
±±º          ³              4 - Fila crediario                            º±±
±±º          ³aRet[2] - Valor do limite de credito do cliente             º±±
±±º          ³aRet[3] - Valor dos titulos em aberto do cliente            º±±
±±º          ³aRet[4] - Numero do contrato de credito                     º±±
±±º          ³aRet[5] - Indica se a venda foi rejeitada                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdxVenda( cTransacao  ,aDadosCrd   ,cContr    ,lFront    , ;
                    lEnvCred    ,cModOper    ,lModoCons ,aRecCRD   , ;
                    lRecebimento )
Local aParcCrd		:= {}                       				// Parcelas do financiamento
Local aProdCrd      := {}                       				// Produtos da venda
Local aParcVda      := {}                       				// Parcelas da venda
Local aRet 			:= { 1, 0, 0, "", .T. }    				// Retorno da funcao
Local aRetCart      := {}                       				// Contem o tipo e numero do documento do cliente da venda
Local aRetCRD		:= { 1, "", "", {}, 1 }    				// Retorno da funcao WSCRD010
Local aCrdAdm       := {}                       				// Relacao das administradoras (SAE)
Local aDadosCli     := {}                       				// Contem numero do cartao, CNPJ/CPF, codigo e loja do cliente selecionado
Local aCliente      := {}                       				// Dados do cliente, utilizado para comparacao com a base local do PDV
Local lWSVenda		:= .F.                      				// Controle da chamada do metodo GetVenda
Local lConnect		:= .T.                      				// Verifica conexao do WS
Local lCliente 		:= .T.                      				// Determina se o cliente foi encontrado na base
Local lForcada		:= .F.                      				// Indica se a venda foi liberada sem realizar a analise de credito
Local lLCTemporario := .T. 										// Indica se eh para limpar os dados de limite temporario do MA7
Local lRet          := .T.                      				// Define se prossegue a operacao
Local lContinua     := .T.                      				// Controla se prossegue a operacao 
Local cSvcError     := ""                       				// Codigo do erro da conexao WS
Local cSoapFCode    := ""                       				// Codigo do erro da conexao WS
Local cSoapFDescr   := ""                       				// Descricao do erro da conexao WS
Local cTicket 		:= ""										// Contem o texto do comprovante de financiamento para ser impresso no ECF
Local cMsgBloque    := "Aguarde ..."            				// Mensagem de bloqueio de credito
Local cMsgStatus	:= ""										// Mensagem com o status de bloqueio, consultado na retaguarda
Local cMV_FORMCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI")  		// Formas de pagamento que devem ter analise de credito
Local cMV_CRDAVAL   := SuperGetMV("MV_CRDAVAL",,"13|22|43")  	// Parametro que define os modulos e processos que tem analise de credito
Local cNomeClie     := ""                       				// Nome do cliente para solicitar a confirmacao
Local nX, nI                                     				// Variavel de loop 
Local nCount        := 0				         				// Quantidade de parcelas do financiamento
Local nMv_LjChVst   := SuperGetMV("MV_LJCHVST",,-1)	 			// Quantos dias considera um cheque a vista. Se for -1 nao trata o parametro
Local nTamCodSAE    := TamSx3("AE_COD")[1]      				// Tamanho do campo AE_COD
Local oMsgBloque                                 				// Objeto da mensagem de venda bloqueada
Local oTimer                                     				// Objeto do timer da tela de bloqueio
Local oFnt                                       				// Objeto do fonte
Local bRefresh      := {|| Nil }                				// Refresh para o Timer
Local lCrdOffLine   := ExistBlock("CRDOFFLINE")					// Verifica se existe o ponto de entrada.
Local xRet														// Retorno do ponto de entrada "CRDOFFLINE"
Local nDiasPagto	:= 0										// Condicao de Pato do SE4
Local nL1ValTot		:= 0										// Valor Total do SE1
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)					// Verifica as filiais da trabalharam com acrescimento separado								
Local nAcrsFin		:= 0										// Valor do acrescimento financiamento
Local nValorL4		:= 0										// Valor da parcela de financiamento
Local cCliVip		:= ""										// Cliente VIP?
Local lR5			:= GetRpoRelease("R5")						// Indica se o release e 11.5
Local uResult		:= NIL										// Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= STFIsPOS() .And. CrdxInt(.F.,.F.)		// Integração TotvsPDV x SIGACRD
Local cMsg			:= ""										// Mensagem para tentar novamente quando há falha de conexão ou erro se lPosCrd

DEFAULT lFront      := .F.
DEFAULT lEnvCred	:= .T.
DEFAULT cModOper    := "XX"
DEFAULT lModoCons 	:= .F.
DEFAULT lRecebimento := .F.
DEFAULT aRecCRD     := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura da array aDadosCrd                                   ³
//³[1] - Numero do cartao                                         ³
//³[2] - Numero do CPF                                            ³
//³[3] - Valor da venda (valor liquido)                           ³
//³[4] - Juros da venda (%)                                       ³
//³[5] - Numeros de parcelas                                      ³
//³[6] - Venda forcada (1-Venda Normal 2-Venda forcada)           ³
//³[7] - Responsavel pela venda forcada                           ³
//³[8] - Array com as parcelas para o financiamento               ³
//³      [1] - Data de vencto                                     ³
//³      [2] - Valor da parcela                                   ³
//³      [3] - Forma de pagto                                     ³
//³      [4] - Administradora financeira                          ³
//³[9] - Loja que solicitou a transacao                           ³
//³[10] - Numero do PDV que solicitou a transacao                 ³
//³[11] - Caixa que solicitou a transacao                         ³
//³[12] - Numero do Orcamento selecionado                         ³
//³[13] - Produtos contido na venda atual.                        ³		
//³      [1] - Item do produto                                    ³
//³      [2] - Codigo do produto                                  ³
//³      [3] - Descricao do produto                               ³
//³      [4] - Quantidade de pecas                                ³
//³      [5] - Valor unitario do produto                          ³		
//³      [6] - Valor total do item do produto                     ³	    
//³[14] - Parcelas de uma venda.                                  ³				
//³      [1] - Data de vencto                                     ³
//³      [2] - Valor da parcela                                   ³
//³      [3] - Forma de pagto                                     ³
//³      [4] - Administradora                                     ³
//³      [5] - Numero do cartao / cheque                          ³
//³      [6] - Agencia - Cheque                                   ³
//³      [7] - Conta - Cheque                                     ³
//³      [8] - Rg - Cheque                                        ³
//³      [9] - Telefone - Cheque                                  ³
//³      [10] - Valor logico                                      ³
//³      [11] - Moeda da parcela (Localizacoes)                   ³																
//³[15] - Filial do Caixa que esta sendo utilizado.               ³
//³[16] - Codigo do cliente                                       ³				
//³[17] - Loja do cliente                                         ³				
//³[18] - Nome do usuario                                         ³				
//³[19] - Condicao de pagamento                                   ³				
//³[20] - Modulo chamador                                         ³				
//³		  LOJ - SIGALOJA										  ³				
//³		  FRT - FRONTLOJA										  ³				
//³		  TMK - TELEMARKETING									  ³				
//³[21] - Codigo do vendedor                                      ³				
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout("3.CRDXFUN-> CrdxVenda -> INICIO")

If cTransacao == "1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cliente eh VIP. Se for, nao realiza a analise ³
	//³credito                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA1->( FieldPos( "A1_CLIVIP" ) ) > 0
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1") + aDadosCrd[16] + aDadosCrd[17])
			cCliVip := SA1->A1_CLIVIP
		EndIf
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o modulo e o processo(operacao) estao habilitados³
	//³via parametro MV_CRDAVAL para realizar a analise de credito  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!(cModOper $ cMV_CRDAVAL) .AND. cModOper <> "XX") .OR. cCliVip == "1"
	
		Conout("4.CRDXFUN-> CrdxVenda -> Contrato: " +;
					If( Empty(cContr), "", cContr) + ;    
					" cModOper: " + If(Empty(cModOper),"",cModOper) + ;
					" Nao e necessario realizar a avaliacao de credito ");
	
	   	//Nao e necessario realizar a avaliacao de credito
	   	aRet  := {	0,;      //Aprovado
		           	0,;      //Valor do limite de credito
		          	0,;      //Valor dos titulos em aberto
		          	cContr,; //Numero do contrato
		          	.F. }    //Venda rejeitada?
		Return (aRet)	          
	Endif	          	
	If ValType(aDadosCrd[8]) == "A" .AND. ValType(aDadosCrd[13]) == "A" .AND. ValType(aDadosCrd[14]) == "A"
		aParcCrd := aClone(aDadosCrd[8])
		aProdCrd := aClone(aDadosCrd[13])
		aParcVda := aClone(aDadosCrd[14])
	Else                                                                 
		Conout("5.CRDXFUN-> CrdxVenda -> Contrato: " + If( Empty(cContr), "", cContr) + ;    
				" Nao foi possivel enviar parametros para a transacao ")
		
		MsgStop(STR0039) //"Erro ao enviar os parâmetros para a transação de crédito."
		lRet    := .F.
	Endif
	DbSelectArea("SAE")
	DbSetOrder(1)
	For nI := 1 To Len(aParcVda)
		If AllTrim(aParcVda[nI][3]) $ cMV_FORMCRD
	    	If Empty(aParcVda[nI][4])
	         
	        	Conout("6.CRDXFUN-> CrdxVenda -> " +;
	         		"Orcamento  : "  + If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) +;
	         		" Cod.Cliente: " + If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) +;          		         
	         		" Contrato : "   + If( Empty(cContr), "", cContr ) +;  
	         		"  Validacao: Empty(aParcVda[nI][4] (parcela nula)" )
	         	Loop
	      	Endif 
			If aScan( aCrdAdm, {|x| x[1] == Substr(aParcVda[nI][4],1,nTamCodSAE) } ) == 0
			
				If DbSeek(xFilial("SAE")+Substr(aParcVda[nI][4],1,nTamCodSAE))
			
			    	If SAE->(FieldPos("AE_PLABEL")) > 0
			
				   		If SAE->AE_PLABEL == "1"
				      		aAdd( aCrdAdm, { Substr(aParcVda[nI][4],1,nTamCodSAE),;    //Codigo da Administradora    
					        	Substr(aParcVda[nI][4], AT("-",aParcVda[nI][4])+2,Len(aParcVda[nI][4])) } )   //Descricao da administradora

	         		  		Conout("7.CRDXFUN-> CrdxVenda -> " +;
	         		 			"Orcamento  : "  + If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) +;
	         					" Cod.Cliente: " + If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) +;          		         
	         					" Contrato : "   + If( Empty(cContr), "", cContr ) +;  
	         					" Administradora: " +If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] ) +;  
	         					" Validacao: Entrou np AE_PLABEL = 1" )
				      

				   		Else                                                                        
  	         	      		Conout("8.CRDXFUN-> CrdxVenda -> " +;
	         		 		 	"Orcamento  : "  + If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) +;
	         					" Cod.Cliente: " + If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) +;          		         
	         					" Contrato : "   + If( Empty(cContr), "", cContr ) +;  
	         					" Administradora: " +If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] ) +;  
	         					" Validacao: SAE_PLABEL = " + If( Empty(SAE->AE_PLABEL), "", SAE->AE_PLABEL) )			      
				   		Endif
					Else
 	         	    	Conout("9.CRDXFUN-> CrdxVenda -> " +;
	         		 		 	"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
	         					" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
	         					" Contrato : "   	+ If( Empty(cContr), "", cContr ) 							+;  
	         					" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] ) 		+;  
	         					" Validacao: SAE_PLABEL = " + If( Empty(SAE->AE_PLABEL), "", SAE->AE_PLABEL) )
				
					Endif
			 	Else                                                                                                             
			 		Conout("10.CRDXFUN-> CrdxVenda -> " 													+;
	         			"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
	         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
	         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
	         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] )       	+;  
	         			" Validacao: SAE_PLABEL = " + If( Empty(SAE->AE_PLABEL), "", SAE->AE_PLABEL)	+;
	         			" Nao encontrou a administradora no SAE" ) 			      
			    
			 	Endif                                                                          
			Else
		  		Conout("11.CRDXFUN-> CrdxVenda -> " 														+;
	         		 	"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
	         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
	         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
	         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] )       	+;  
	         			" Nao encontrou a administradora em aCrdAdm" )	     
		  	Endif
		Else        
    		Conout("12.CRDXFUN-> CrdxVenda -> " 														+;
         		 	"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4] )       	+;   
         			" FORMCRD : " 		+ If( Empty(aParcVda[nI][3]), "", aParcVda[nI][3] )       	+;  
         			" Validacao: ParcVda[nI][3] $ cMV_FORMCRD " )	     
	   	Endif
	Next nI
	   
	If Len(aParcCrd) == 0
	
		Conout("13.CRDXFUN - CrdXVenda - LEN(aCrdAdm) == 0;  " +;
			 	"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
         		" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
         		" Contrato : "   	+ If( Empty(cContr), "", cContr ))
				
		nCount  := 0				
		
	    For nI := 1 To Len(aParcVda)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³ Considera para o financiamento do Sigacrd as parcelas com administrado-³
		   	//³ ra financeira com Private Label (AE_PLABEL = 1-Sim) ou cheques a vista.³
		   	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		   	//³ Um cheque eh considerado a vista quando:                               ³
		   	//³             Data do cheque < dDataBase + SuperGetMV("MV_LJCHVST)            ³
		   	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		   	//³ Se o conteudo do parametro for -1, entao ele nao devera ser considerado³
		   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	nPosAdm := aScan( aCrdAdm, {|x| Substr(x[1],1,nTamCodSAE) == Substr(aParcVda[nI][4],1,nTamCodSAE) } )
		   	
		   	Conout("14.CRDXFUN - CrdXVenda - " +;
					"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4]) 		+;
         			" Validacao: nPosAdm = " + Alltrim(STR(nPosAdm)) )
		   
		   
			If nPosAdm > 0 .OR.	(Alltrim(Upper(MVCHEQUE))$cMV_FORMCRD .AND. ;
		    					((Alltrim(Upper(aParcVda[nI][3])) == Alltrim(Upper(MVCHEQUE)) .AND.;
		    	 				( nMv_LjChVst==-1 .OR. aParcVda[nI][1] >= dDataBase+nMv_LjChVst))))
		      
				aAdd( aParcCrd, { 	aParcVda[nI][1],;		    // Data de vencto
			                    	aParcVda[nI][2],;		    // Valor da parcela
			                    	aParcVda[nI][3],;		    // Forma de pagto
			                    	aParcVda[nI][4] } )	        // Administradora Financeira
		      	nCount  := nCount + 1 	                    
		      	
				Conout("15.CRDXFUN - CrdXVenda - " +;
					"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4]) ) 	
         			
         		Conout(" aParcCrd[" + Alltrim(STR(nI)) + "][1] = " +;
         				If( Empty(aParcVda[nI][1]), "", DTOC(aParcVda[nI][1])) )
         		Conout(" aParcCrd[" + Alltrim(STR(nI)) + "][2] = " +;
         				If( Empty(aParcVda[nI][2]), "", Alltrim(STR(aParcVda[nI][2]))) )
     			Conout(" aParcCrd[" + Alltrim(STR(nI)) + "][3] = " +;
         				If( Empty(aParcVda[nI][3]), "", aParcVda[nI][3]) )
         		
		 	Else                                                                                      
		 		Conout("16.CRDXFUN - CrdXVenda - " +;
					"Orcamento  : "  	+ If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) 			+;
         			" Cod.Cliente: " 	+ If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) 			+;          		         
         			" Contrato : "   	+ If( Empty(cContr), "", cContr )                          	+;  
         			" Administradora: " + If( Empty(aParcVda[nI][4]), "", aParcVda[nI][4]) 		+;
		 	        " Forma de Pgto: "  + Alltrim(Upper(aParcVda[nI][3])) )
		  	
		   	Endif
	    Next nI				
	    
	    If LEN(aParcCrd) == 0 .AND. LEN(aDadosCrd) > 0 
	    	Conout("17.CRDXFUN - CrdXVenda - LEN(aParcCrd) == 0 do Orcamento " +;
	    		If( Empty(aDadosCrd[12]), "", aDadosCrd[12] ) )   
	    Endif
	    aDadosCrd[5]  := nCount  
	    aDadosCrd[8]  := AClone(aParcCrd) 	     
	    //Array com as parcelas do financiamento que sera utilizado na impressao do comprovante
	    aRecCRD       := AClone(aParcCrd) 	     
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a transacao de venda                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If cTransacao == "1" 
	   If Len(aParcCrd) > 0
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³Checa se o cliente jah foi identificado no inicio da venda     ³
		  //³caso contrario pede a informacao agora para detectar se foi    ³
		  //³pagamento/financiamento via Private Label                      ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  If Empty( aDadosCrd[1] + aDadosCrd[2] )
             aDadosCli     := {Space(TamSX3("MA6_NUM")[1]),;    //Numero do cartao
                  			   Space(TamSX3("A1_CGC")[1]),;     //CNPJ/CPF do cliente
                  			   Space(TamSX3("A1_COD")[1]),;     //Codigo do cliente
                  			   Space(TamSX3("A1_LOJA")[1])}     //Loja do cliente
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Identificacao do cliente pelo cartao ou CNPJ/CPF           ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		     			 
			 lRet  := CrdIdentCli(  @aRetCart  	,@aDadosCli  ,@lCliente  ,lFront  ,;
			                        @aCliente  	, Nil        ,@lConnect  )
			                        
			 lContinua  := lRet .AND. IIf(lFront,.T.,!lCliente)                        
			 If lContinua            
			 	
			 	Conout("18.CRDXFUN - CrdXVenda - Cartao+CNPJ+CodCli+Loja " +;
			 				If(Empty(aDadosCli[1]), "", aDadosCli[1]) + " / " +; 
			 				If(Empty(aDadosCli[2]), "", aDadosCli[2]) + " / " +; 
			 				If(Empty(aDadosCli[3]), "", aDadosCli[3]) + " / " +;
			 				If(Empty(aDadosCli[4]), "", aDadosCli[4]) )   
			 
			    aDadosCrd[1]   := aDadosCli[1]   //Numero do cartao 
			    aDadosCrd[2]   := aDadosCli[2]   //CNPJ/CPF
			    aDadosCrd[16]  := aDadosCli[3]   //Codigo do cliente
			    aDadosCrd[17]  := aDadosCli[4]	  //Loja do cliente		    			    			    
			 Else     

			 	Conout("19. CRDXFUN - CrdXVenda - Cartao+CNPJ+CodCli+Loja " +;
			 				If( Empty(aDadosCrd[1]), "", aDadosCrd[1]) + " / " +;
			 				If( Empty(aDadosCrd[2]), "", aDadosCrd[2]) + " / " +; 
			 				If( Empty(aDadosCrd[16]), "", aDadosCrd[16]) + " / " +;
			 				If( Empty(aDadosCrd[17]), "", aDadosCrd[17]) +;
			 				" Cliente nao identificado" )   

			    aRet  := { 1, 0, 0, "", .T. }	                      
			 Endif				                      
	      Endif
			                           
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³Quando nao conectar no webservice, significa que venda sera forcada³
		  //³nao vai prosseguir com a avaliacao de credito.                     ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		  If !lConnect
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao conseguiu conectar com o WebService, emite a mensagem³
			//³onde o caixa pode optar por aprovar a venda off-line        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//"Não foi possível a fazer a conexão com o servidor." 
			//"Em caso de liberacao, deseja aprovar a venda na forma Off_line ?" 		  
			If MsgNoYes(STR0057 + chr(13) + STR0058) 
				aDadosCrd[1]   := aDadosCli[1]   //Numero do cartao 
			    aDadosCrd[2]   := aDadosCli[2]   //CNPJ/CPF
 		  	    aRet  := { 2, 0, 0, "", .F. }
				If lCrdOffLine
				   xRet := ExecBlock("CRDOFFLINE")
				   If ValType(xRet) == "L"
				      If !xRet
				 	     aRet := { 1, 0, 0, "", .T. }
				 	  Endif
				   Endif
				Endif				                             		  	     		  	    
 		  	 Else
 		  	    aRet  := { 1, 0, 0, "", .T. }	                      
 		  	 Endif    
 		  Endif	
 		  
	      If lContinua                                                           
	      
	      	 Conout("20.CRDXFUN - CrdXVenda - Analise de credito do " +;
	      				" Contrato : " + If( Empty(cContr), "", cContr ) +;
	      				" Cartao+CNPJ+CodCli+Loja " +;
	      				If( Empty(aDadosCrd[1]), "", aDadosCrd[1] ) + " / " +;
	      				If( Empty(aDadosCrd[2]), "", aDadosCrd[2] ) + " / " +; 
	      				If( Empty(aDadosCrd[16]), "", aDadosCrd[16] ) + " / " +; 
	      				If( Empty(aDadosCrd[17]), "", aDadosCrd[17] ) )   
	      
	      
	         aRet  := AClone(CRDAvalCred(  @aDadosCrd  ,lCliente   ,aParcCrd  ,aProdCrd  ,;
				                            aParcVda    ,aRetCart  ,lFront     ,aCliente  ,;
				                            cContr    	,lEnvCred  ,lModoCons  , lRecebimento))			 	      
			 If Len(aRet) > 0 
			 	If aRet[1] == 2 .AND. lCrdOffLine
			 		xRet := ExecBlock("CRDOFFLINE")
			 		If ValType(xRet) == "L"
			 			If !xRet
			 				aRet := { 1, 0, 0, "", .T. }
			 			Endif
			 		Endif
			 	Endif
			 Endif
		  Else
		     Conout("21.CRDXFUN - CrdXVenda - Nao entrou na funcao CRDAvalCred " +;
	      				" Contrato : " + If( Empty(cContr), "", cContr ) +;
	      				" Validacao: lContinua = .F. ")
	      Endif			                            
	   Else  
	      	Conout("22.CRDXFUN - CrdXVenda - Analise de credito do " +;
      				" Contrato : " + If( Empty(cContr), "", cContr ) +;
      				" Cartao+CNPJ+CodCli+Loja " +;
      				If( Empty(aDadosCrd[1])		, "", aDadosCrd[1] ) 	+ " / " +;
      				If( Empty(aDadosCrd[2])		, "", aDadosCrd[2] ) 	+ " / " +; 
      				If( Empty(aDadosCrd[16])	, "", aDadosCrd[16] ) 	+ " / " +; 
      				If( Empty(aDadosCrd[17])	, "", aDadosCrd[17] ) 	+;  
					" Len(aParcCrd <=0) Nao precisa analisar o credito " )   
	   
	   
	      //Nao e necessario realizar a avaliacao de credito
	      aRet  := { 0,;      //Aprovado
	                 0,;      //Valor do limite de credito
	                 0,;      //Valor dos titulos em aberto
	                 "",;     //Numero do contrato
	                 .F. }    //Venda rejeitada?
	   Endif    
	ElseIf cTransacao == "2"	
	   If !lPosCrd		//Via WS
		   oSvc := WSCRDVENDA():New()
			
		   oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"  	
		   
		   nI := 1	
		   While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
		      LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."		  	      
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  CrdUpdUser( cUsrSessionID ) 
			  nI++		  
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³1 segundo para nova checagem de login ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  Sleep(1000)
		   End
		EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Entra na condicao se o CNPJ da empresa ³
	   //³estiver no LOJA950. Ou se usar conceito³     
   	   //³de acrescimo separado "MV_LJICMJR" =.T.³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lVerEmpres .OR. (( lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")  .AND. ;    
	       SE4->(FieldPos("E4_LIMACRS") > 0) .AND. SL4->(FieldPos("L4_ACRSFIN") > 0))
		   DbSelectArea("SE4")
		   DbSetOrder(1)
		   If DbSeek(xFilial("SE4") + SL1->L1_CONDPG)
	         nDiasPagto	:= SE4->E4_LIMACRS
 	       Endif
		   
		   DbSelectArea("SL4")
		   DbSetOrder(1)			
		   If DbSeek(xFilial("SL4") + SL1->L1_NUM)
		      If Alltrim(SL4->L4_FORMA) == "FI"
			      nValorL4 := SL4->L4_VALOR
			      nAcrsFin := SL4->L4_ACRSFIN		      
		      Endif 
		      While !EOF() .AND. (xFilial("SL4") == SL1->L1_FILIAL .AND. SL4->L4_NUM == SL1->L1_NUM)
		          If Alltrim(SL4->L4_FORMA) == "FI"
	                  If SL4->L4_VALOR > nValorL4
	                     nValorL4 := SL4->L4_VALOR
	                     nAcrsFin := SL4->L4_ACRSFIN
	                  Endif
					  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  //³Valor total financiado sem acrescimo³
					  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				      nL1ValTot += NoRound(SL4->L4_VALOR)
			      Endif
				  DbSkip()
				  Loop		      
			  End
           Endif
	   ElseIf lVerEmpres .OR. ( (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")  .AND. ;
	       SL4->(FieldPos("L4_ACRSFIN") > 0) )
           nDiasPagto	:= 0	
		   
		   DbSelectArea("SL4")
		   DbSetOrder(1)			
		   If DbSeek(xFilial("SL4") + SL1->L1_NUM)
		      If Alltrim(SL4->L4_FORMA) == "FI"
			      nValorL4 := SL4->L4_VALOR
			      nAcrsFin := SL4->L4_ACRSFIN		      
		      Endif 
		      While !EOF() .AND. (xFilial("SL4") == SL1->L1_FILIAL .AND. SL4->L4_NUM == SL1->L1_NUM)
		          If Alltrim(SL4->L4_FORMA) == "FI"
	                  If SL4->L4_VALOR > nValorL4
	                     nValorL4 := SL4->L4_VALOR
	                     nAcrsFin := SL4->L4_ACRSFIN
	                  Endif
					  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  //³Valor total financiado sem acrescimo³
					  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				      nL1ValTot += NoRound(SL4->L4_VALOR)
			      Endif
				  DbSkip()
				  Loop		      
			  End
           Endif
	   Endif	
	   
	   Conout("95.CRDXVENDA - nL1ValTot -> " + Alltrim(STR(nL1ValTot)) )	   
	   
	   lWSVenda := .T.
	   While lWSVenda
	      //"Aguarde... Efetuando a confirmacao da transação de crédito ..."
	      If lPosCrd			//Integração TOTVSPDV X SIGACRD
			lConnect := .F.
			If STBRemoteExecute("WsCrd012" ,{cContr  ,aDadosCrd[1]	,aDadosCrd[2],	nL1ValTot,;
								nDiasPagto,	nAcrsFin,	nValorL4},;
								 NIL,.T.	,@uResult)	//Ver se aDadosCrd[3] é o mesmo que  
				
				If Valtype(uResult) = "A" .AND. Len(uResult)>=4 .AND. Len(uResult[4])>=4  //Se não vier array completo, não conectou completamente
					lConnect := .T.
				EndIf
				
			EndIf
	      Else
		      LJMsgRun( STR0044,, {|| lConnect := oSvc:CONFIRMAVENDA( cUsrSessionID , cContr	  , aDadosCRD[1], aDadosCRD[2] ,;
		      															nL1ValTot	 , nDiasPagto , nAcrsFin    , nValorL4 )} )
		  EndIf 
		  If !lConnect
		  	If lPosCrd			//Se TOTVSPDV X SIGACRD
				LjGrvLog("CRDXFUN","Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD012 - ConfirmaVenda NÃO CONECTADO")
				lWSVenda := MsgYesNo( "WSCRD012" + CRLF + STR0045 + CRLF + STR0140 ) //"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
				   										//"Tentar novamente ?"
		  	Else				//Via WS
			     cSvcError := GetWSCError()
			     If Left(cSvcError,9) == "WSCERR044"		// "Nao foi possivel post em http:// ..."			
				    If !lForcada 
					   MsgStop( STR0045 ) //"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
					Endif				
					lWSVenda 	:= .F. // Nao chama o metodo GetVenda novamente 									
		         ElseIf Left(cSvcError,9) == "WSCERR048"				
				    cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
					cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
						
					// Se necessario efetua outro login antes de chamar o metodo ConfirmaVenda novamente
					If cSoapFCode $ "-1,-2,-3"
					   //"Aguarde... Efetuando login no servidor ..."
					   LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
					   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
					   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				      
					   CrdUpdUser( cUsrSessionID ) 
					   lWSVenda := .T.
					Else
					   MsgStop(cSoapFDescr, "Error " + cSoapFCode)
					   lWSVenda := .F.	
					Endif
		         Else				
					lWSVenda := .F. 
				EndIf					
	         Endif
			
			 If !lWSVenda
				CrdCpvFin() // Impressao do Comprovante de Financiamento		
			 Endif
		  Else		//Conectado				
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Alimenta as variaveis de retorno                            ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    				
			 If Empty(Iif(lPosCrd,uResult[2],oSvc:oWSCONFIRMAVENDARESULT:cTITULO))	//Conectou com êxito, se uResult[2] ou cTitulo preenchido, retornou com erro.
			    cTicket := ""
				aRet 	:= Array(2)
				aRet[1]	:= 0
				If lPosCrd		//Integração TOTVSPDV X SIGACRD
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD012 - ConfirmaVenda conectou com êxito!")
					aRet[2]	:= Array(len(uResult[4]))
					
					For nX := 1 to len(uResult[4])
					   aRet[2][nX]	:= uResult[4][nX]
					   cTicket 	    += uResult[4][nX] + Chr(10)
					Next nX
				Else
					aRet[2]	:= Array(len(oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE))
					
					For nX := 1 to len(oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE)
					   aRet[2][nX]	:= oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE[nX]:cLINHA
					   cTicket 	    += oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE[nX]:cLINHA + Chr(10)
					Next nX
				EndIf     

				CrdImprComp(cTicket, aDadosCrd)
				lWSVenda := .F.	
				
			 Else			//Conectou, porém retornou com erros
			    If lPosCrd	//Integracao TOTVSPDV X SIGACRD
					cMsg := uResult[2] + CRLF + uResult[3]

					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD012 - ConfirmaVenda Conectado mas RETORNOU COM ERRO", {uResult[2],uResult[3]})
					If MsgYesNo( "WSCRD012" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
						lWSVenda := .T.
						Sleep( 5000 )		//5 segundos para nova checagem
					Else
						lWSVenda:= .F. // Nao chama o metodo GetVenda novamente
						LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD012 - ConfirmaVenda - Procedimento encerrado pelo usuário !")
						ConOut("WSCRD012 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
					EndIf 									
					        
			    Else	//Via WS
				    MsgStop(oSvc:oWSCONFIRMAVENDARESULT:cMENSAGEM, ;
					        oSvc:oWSCONFIRMAVENDARESULT:cTITULO)
					lWSVenda := .F.	
				EndIf								
			 Endif				
		  Endif
	   End
	ElseIf cTransacao == "3"   //Cancelamento
	   
	   If !lPosCrd		//Via WS
		   oSvc := WSCRDVENDA():New()
		
		   //*** Fazer o tratamento para mudar o caminho
		   oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"  
			
		   nI  := 1
		   While Empty(cUsrSessionID) .AND. nI <= TENTATIVAS
		      //"Aguarde... Efetuando login no servidor ..."
			  LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				      
			  CrdUpdUser( cUsrSessionID ) 
			  nI++
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³1 segundo para nova checagem de login ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  Sleep(1000)				      
		   End
		EndIf   
	   // Quando o cupom era cancelado a partir do MontaOrcam e o crediário já tinha liberado a venda,
	   // ele limpava os status gravados no MA7. Fazendo com que a venda fosse bloqueada novamente.
	   lLCTemporario := !(IsInCallStack("MontaOrcam"))
	   lWSVenda := .T.
	   While lWSVenda
	      //"Aguarde ... cancelando o contrato ..."
	      If lPosCrd			//Integração TOTVSPDV x SIGACRD
			lConnect := .F.
			If STBRemoteExecute("WsCrd011" ,{cContr, aDadosCrd[2], aDadosCrd[1], lLCTemporario}, NIL,.T.	,@uResult)  
				If Valtype(uResult) = "A" .AND. Len(uResult)>=4
					lConnect := .T.
				EndIf
			EndIf
	      Else
		      LJMsgRun( STR0046,, {|| lConnect := oSvc:CANCELAVENDA( cUsrSessionID, cContr, aDadosCrd[2], aDadosCrd[1], lLCTemporario )} )
		  EndIf 
		  If !lConnect
		     cSvcError := GetWSCError()
		     If Left(cSvcError,9) == "WSCERR044"		// "Nao foi possivel post em http:// ..."
			    If !lForcada 			
				   MsgStop( STR0045 ) //"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
				Endif
				lWSVenda 	:= .F. // Nao chama o metodo GetVenda novamente 									
		     ElseIf Left(cSvcError,9) == "WSCERR048"				
			    cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))					
				// Se necessario efetua outro login antes de chamar o metodo ConfirmaVenda novamente
			    If cSoapFCode $ "-1,-2,-3"
				   //"Aguarde... Efetuando login no servidor ..."
				   LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				      
				   CrdUpdUser( cUsrSessionID ) 
				   lWSVenda := .T.
				Else
				   MsgStop(cSoapFDescr, "Error " + cSoapFCode)
				   lWSVenda := .F.	// Nao chama o metodo ConfirmaVenda novamente 
				Endif					
		     Else	   
		     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³"Sem comunicação com o WebService!","Atenção."³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgStop(STR0078, STR0079)			
				lWSVenda := .F. // Nao chama o metodo ConfirmaVenda novamente 					
		     Endif				
		  Else			//Conectado	
			 If Empty(Iif(lPosCrd,uResult[2],oSvc:oWSCONFIRMAVENDARESULT:cTITULO))	//Conectado, uResult[2] ou cTitulo em Branco retornou sem erros de msg
				aRet 	:= Array(2)
				aRet[1]	:= 0
				If lPosCrd		//Integração TOTVSPDV x SIGACRD
					aRet[2]	:= Array(len(uResult[4]))
					
					For nX := 1 to len(uResult[4])
					   aRet[2][nX]	:= uResult[4][nX]
					   cTicket 	    += uResult[4][nX] + Chr(10)
					Next nX
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD011 - CancelaVenda - Conectado com êxito !")
				Else		//Via WS
					If !Empty(oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE)                                  
					   aRet[2]	:= Array(Len(oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE))					
					   For nX := 1 to Len(oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE)
					      aRet[2][nX]	:= oSvc:oWSCONFIRMAVENDARESULT:oWSCOMPROVANTE:oWSWSCOMPROVANTE[nX]:cLINHA
					   Next nX	
					Endif			
				EndIf     
				lWSVenda := .F.	
				
			 Else			//Conectou, porém retornou com erros
			    If lPosCrd	//Integração TOTVSPDV x SIGACRD
					cMsg := uResult[2] + CRLF + uResult[3]

					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD011 - CancelaVenda Conectado mas RETORNOU COM ERRO", {uResult[2],uResult[3]})
					If MsgYesNo( "WSCRD011" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
						lWSVenda := .T.
						Sleep( 5000 )		//5 segundos para nova checagem
					Else
						lWSVenda:= .F. // Nao chama o metodo GetVenda novamente
						LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContr) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD011 - CancelaVenda - Procedimento encerrado pelo usuário !")
						ConOut("WSCRD011 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
					EndIf 									
					        
			    Else	//Via WS
				    MsgStop(oSvc:oWSCONFIRMAVENDARESULT:cMENSAGEM, ;
					        oSvc:oWSCONFIRMAVENDARESULT:cTITULO)
					lWSVenda := .F.	
				EndIf								
			 Endif				
		  Endif
	   End	
	Endif   
Endif

Return (aRet)    
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdXCancVendaºAutor³Vendas Clientes    º Data ³ 15/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que faz o cancelamento da venda/limite do cliente   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdXCancVenda( cContr )
Local lRet       	:= .F.		   //Retorno da funcao
Local lWSEstorno 	:= .T.		   //Retorno do WebService
Local oSvc						   //Objeto para WebService
Local cSoapFCode  	:= ""		   //Retorno WebService
Local cSoapFDescr 	:= ""		   //Retorno WebService
Local nI                           //Controle do numero de tentativas de login via WS

DEFAULT cContr	    := Space(TamSx3("MAH->MAH_CONTRA")[1])

nI := 1
While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
	LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CrdUpdUser( cUsrSessionID )
	nI++
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1 segundo para nova checagem de login ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Sleep(1000)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a transacao Web Service para o limite de credito.    Faz o tratamen-³
//³to se a transacao ainda estah ativa, caso contrario, faz novo login e     ³
//³chama o metodo GetEstorno Novamente                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc := WSCRDVENDA():New()
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"

While lWSEstorno
	LJMsgRun( STR0046,, {|| lRet := oSvc:CANCELAVENDA( cUsrSessionID, cContr ) } ) //"Aguarde ... cancelando o contrato ..."
	If !lRet
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"			
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			
			// Se necessario efetua outro login antes de chamar o metodo GetLimite novamente
			If cSoapFCode $ "-1,-2,-3"
			   //"Aguarde... Efetuando login no servidor ..."
			   LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		       //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				      
			   CrdUpdUser( cUsrSessionID ) 
			   lWSEstorno := .T.
			Else
				MsgStop(cSoapFDescr, "Error " + cSoapFCode)
				lWSEstorno := .F.	// Nao chama o metodo GetLimite novamente
			Endif			
		Else
			MsgStop(STR0078,STR0079) //"Sem comunicação com o WebService!"###"Atenção."
			lWSEstorno := .F. // Nao chama o metodo GetLimite novamente
		Endif
	Else
		lRet := oSvc:lESTORNAVENDARESULT
		lWSEstorno := .F.	// Nao chama o metodo GetLimite novamente
	Endif
End

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WSCrdConsCliºAutor³Vendas Clientes     º Data ³ 23/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a consulta dos dados do cliente no servidor             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WSCrdConsCli( cCartao   , cCPF   , cContrato, lConnect, ;
                       cMatricula, cCodDEP, cNomeDep, cCodCli, cLojCli, cTipoCli)
Local aRet			:= {}
Local aCliente		:= {}
Local lWSCliente 	:= .T.
Local lRet			:= .F.
Local nX 			:= 0				// Controle de looping da rotina
Local nY 			:= 0				// Controle de looping da rotina
Local nI            := 0              	// Controle do numero de tentativas de login via WS
Local xConteudo
Local oSvc
Local cSvcError 	:= ""
Local cSoapFCode	:= ""
Local cSoapFDescr 	:= ""
Local lAmbOffLn	 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline
Local uResult		:= NIL									// Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= STFIsPOS() .And. CrdxInt(.F.,.F.)	//Integração TotvsPDV x SIGACRD
Local lSuccess		:= .F.

DEFAULT cContrato 	:= ""               // Numero do contrato
DEFAULT lConnect	:= .T.				// Identifica se conseguiu conectar no WS
DEFAULT cMatricula 	:= ""				// Codigo da matricula do cliente no caso de existir template Drogaria
DEFAULT cCodDEP     := ""				// Codigo do dependente
DEFAULT cNomeDep    := ""               // Nome do dependente
DEFAULT cCodCli     := ""				// Codigo do Cliente
DEFAULT cLojCli     := ""				// Loja do Cliente
DEFAULT cTipoCli    := ""       		// Tipo do Cliente


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o modulo for FrontLoja, busca as informacoes atraves de WebService, ³
//³ caso contrario, pesquisa direto na base                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPosCrd		//Integração TOTVSPDV x SIGACRD

	// Chama a função sem passar pelo WebService por estar consultando
	// a base local
	lConnect := .F.
	While nI <= TENTATIVAS .AND. lWSCliente .AND. !lSuccess                                               
		If STBRemoteExecute("WsCrd013" ,{cCartao, cCPF, cContrato, cMatricula, cCodCli, cLojCli, cTipoCli}, NIL,.T.	,@uResult)
			
			If Valtype(uResult) = "A" .AND. Len(uResult)>=5 .AND. Len(uResult[5])>=2  //Se não vier array completo, não conectou completamente
				lConnect := .T.
				If uResult[1] = 0 		//Gravação MA7 com êxito
					lSuccess := .T.		//O procedimento de gravação da tabela MA7 é realizado dentro da função WSCRD113().
					aRet := uResult
					aRet := aClone( aRet[4] )		//Retorno do código do Cliente
				EndIf
				If lConnect .AND. lSuccess
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ", Cliente " + Alltrim(cCodCli) + "/" + Alltrim(cLojCli) + ": WSCRD013 - ConsultaCliente conectado com sucesso!")
				EndIf
			EndIf
			
		EndIf
	
		nI++
		If (!lConnect .OR. !lSuccess) .AND. nI <= TENTATIVAS
		
			If !lConnect
				cMsg := STR0045				//"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ", Cliente " + Alltrim(cCodCli) + "/" + Alltrim(cLojCli) + ": WSCRD013 - ConsultaCliente NÃO CONECTADO")
			ElseIf !lSuccess
				cMsg := uResult[2] + CRLF + uResult[3]
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ", Cliente " + Alltrim(cCodCli) + "/" + Alltrim(cLojCli) + ": WSCRD013 - ConsultaCliente Conectado mas RETORNOU COM ERRO", {uResult[2],uResult[3]})
			EndIf
			If MsgYesNo( "WSCRD013" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
			   lWSCliente := .T.
				Sleep( 5000 )		//5 segundos para nova checagem
			   
			Else
				lWSCliente := .F. // Nao chama o metodo GetVenda novamente
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ", Cliente " + Alltrim(cCodCli) + "/" + Alltrim(cLojCli) + ": WSCRD013 - ConsultaCliente - Procedimento encerrado pelo usuário !")
				ConOut("WSCRD013 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
			EndIf 									
	
		ElseIf !lConnect .AND. nI > TENTATIVAS
			LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ", Cliente " + Alltrim(cCodCli) + "/" + Alltrim(cLojCli) + ": WSCRD013 - ConsultaCliente - Todas as tentativas esgotadas !")
			ConOut("WSCRD013 - " + STR0141)		//"Erro: Todas as tentativas de conexão esgotadas !"
		EndIf
	EndDo

	If lSuccess .AND. !Empty(uResult[5][1]) .AND. !Empty(uResult[5][2])		//cCodDep e cNomeDep são parâmetros de referência e devem ser alterados aqui. 
		cCodDep		:= uResult[5][1]
		cNomeDep	:= uResult[5][2]
	EndIf
	
ElseIf (nModulo == 23 .AND. CrdxInt()) .OR. ( nModulo == 12 .AND. lAmbOffLn .AND. CrdxInt())		//Via WS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao encontrou o cliente na base local, procura no server³
	//³e traz para a base local                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nI := 1
	While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
		LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CrdUpdUser( cUsrSessionID )
		nI++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³1 segundo para nova checagem de login ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(1000)
	End

	oSvc := WSCRDVENDA():New()
	oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"
	lWSCliente := .T.
	
	While lWSCliente
	   //"Aguarde ... Pesquisando dados do cliente no servidor ..."
		MsgRun( STR0048, "", {|| lRet := oSvc:CONSULTACLIENTE( cUsrSessionID, cCartao, cCPF, cContrato, cMatricula ) } )
		If !lRet
			cSvcError := GetWSCError()
			lConnect	:= .F.
			If Left(cSvcError,9) == "WSCERR048"		
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				
				// Se necessario efetua outro login antes de chamar o metodo GetCartao novamente
				If cSoapFCode $ "-1,-2,-3"
					LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
					lWSCliente := .T.	// Chama o metodo GetCartao novamente
				Else
					MsgStop(cSoapFDescr, "Error " + cSoapFCode)
					lWSCliente := .F.	// Nao chama o metodo GetCartao novamente
				Endif			
			Else
				lWSCliente := .F. // Nao chama o metodo GetCartao novamente
			Endif
		Else
			cSoapFCode := Nil
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a gravacao do cadastro do cliente com base no array    ³
			//³passado por webservice                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If Empty( oSvc:oWSCONSULTACLIENTERESULT:cTITULO )
	        	For nY := 1 to LEN( oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1 )
	        		aCliente := {}
					For nX := 1 to LEN( oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1 )
						xConteudo := Nil
						If oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cTIPO == "C" 
							xConteudo := oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cCONTEUDO
						ElseIf oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cTIPO == "N"
							xConteudo := Val(oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cCONTEUDO)
						ElseIf oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cTIPO == "D"
							xConteudo := CtoD(oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cCONTEUDO)
						Endif
						If xConteudo <> Nil
							aAdd( aCliente, { oSvc:oWSCONSULTACLIENTERESULT:oWSDADOSSA1:oWSWSDADOSSA1[nY]:oWSCamposSA1:oWSWSCamposSA1[nX]:cCAMPO, xConteudo } )
						Endif
					Next nX	
					aAdd( aRet, aClone( aCliente ) )
				Next nY                                      
				If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualizando informacoes do DEPENDENTE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(oSvc:oWSCONSULTACLIENTERESULT:cCODDEP) .AND. !Empty(oSvc:oWSCONSULTACLIENTERESULT:cNOMEDEP)
						cCodDEP  := oSvc:oWSCONSULTACLIENTERESULT:cCODDEP
						cNomeDep := oSvc:oWSCONSULTACLIENTERESULT:cNOMEDEP
					Endif
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando um CPF não cadastrado era informado a rotina estava considerando³
				//³como se o webService não tivesse sido conectado.                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(cSoapFCode) == "U"
					MsgStop(oSvc:oWSCONSULTACLIENTERESULT:cMENSAGEM, oSvc:oWSCONSULTACLIENTERESULT:cTITULO)
				Endif
			Endif			
			lWSCliente := .F. 	// Nao chama o metodo GetCartao novamente
		Endif
	End

Else		//Retaguarda acessando a própria retaguarda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a função sem passar pelo WebService por estar consultando ³
	//³ a base local                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := WSCRD013( cCartao, cCPF, cContrato, cMatricula, cCodCli, cLojCli, cTipoCli )
	lConnect := (aRet[1])=0
	aRet := aClone( aRet[4] )

Endif

	
Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdxImp     ºAutor³Vendas Clientes     º Data ³ 25/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a impressao do contrato de financiamento                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdxImpDoc( cArqDot, nVias, aDados )

Local hWord
Local cPath		:= GetNewPar("MV_DIRACA", "\SIGAMAT\")
Local nInd		:= 0  

DEFAULT aDados 	:= {}
DEFAULT nVias 	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - SmartClient HTML³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction ("LjChkHtml")
	If LjChkHtml()
		FwAvisoHtml()
		Return
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a existencia do arquivo a ser impresso                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cPath + cArqDot ) // Verifica a existencia do DOT no ROOTPATH Protheus / Servidor	
	MsgStop( "Arquivo " + cPath + cArqDot+ " não encontrado!", ProcName())
	Return Nil		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a passagem de parametros                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aDados) <> "A"
	MsgStop(STR0050, ProcName()) //"Erro nã passagem de parâmetros. Contate o administrador do sistema."
	Return Nil
Endif

If Empty( aDados )
	Return Nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando link de comunicacao com o word                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
hWord := OLE_CreateLink()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe ou oculta a janela principal da aplicacao Word                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetProperty( hWord, oleWdVisible, .T. )	

If hWord == "-1"
	MsgBox(STR0051, ProcName()) //"Impossível estabelecer comunicação com o Microsoft Word."
Endif
		
//Local HandleWord (onde sera criado o arquivo local)
MontaDir("C:\")
		
// Caso encontre arquivo ja gerado na estacao
//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
If File( Alltrim( "C:\" + cArqDot ) )
	Ferase( Alltrim( "C:\" + cArqDot ) )
Endif
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia do Server para o Remote, eh necessario para que o wordview e o   ³
//³ proprio word possam preparar o arquivo para impressao e ou visualizacao³
//³ Copia o DOT que esta no ROOTPATH Protheus para o PATH da estacao,      ³
//³ por exemplo C:\WORDTMP                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CpyS2T( cPath+cArqDot, "C:\", .T. )
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerando novo documento do Word na estacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_NewFile( hWord, Alltrim( "C:\"+cArqDot ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deixa a janela do documento visivel ou nao. .T. ou .F. (opcional)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetProperty( hWord, oleWdVisible, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa ou desativa impressao em segundo plano. (opcional)              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetProperty( hWord, oleWdPrintBack, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Essa eh a parte mais importante.                                      ³
//³ Gerando variaveis do documento                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 to Len( aDados )
	OLE_SetDocumentVar(hWord, aDados[nInd,1], aDados[nInd,2] )
Next nInd
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizando a exibicao das variaveis do documento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_UpdateFields(hWord)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o documento.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_PrintFile( hWord, "ALL",,, nVias )
Sleep(2000)	// Espera 2 segundos pra dar tempo de imprimir.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o documento.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_CloseFile( hWord )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha a comunicacao com o Word.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_CloseLink( hWord )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga o arquivo de trabalho                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File( Alltrim( "C:\" + cArqDot ) )
	Ferase( Alltrim( "C:\" + cArqDot ) )
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaOrcam	 ºAutor³Vendas Clientes   º Data ³ 04/02/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Empacota os dados de orcamento do front loja e inclui um no º±±
±±º          ³no orcamento na Retaguarda, guardando o numero do orcamento º±±
±±º          ³atual no campo L1_NUMORIG na retaguarda					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaOrcam( CORCAM			, cCliente		, cLojaCli		, cVendLoja		, cItemCond	,;
					 aTefDados		, aPgtos		, lCondNegF5	, oHora		    , cHora	  	,;
					 oDoc			, cDoc			, oCupom		, cCupom		, nVlrPercIT,;
					 nLastTotal		, nVlrTotal		, nLastItem		, nTotItens		,;
					 nVlrBruto		, oDesconto		, oTotItens		, oVlrTotal		,;
					 oFotoProd		, nMoedaCor		, cSimbCor		, oTemp3		,;
					 oTemp4			, oTemp5		, nTaxaMoeda	, oTaxaMoeda	,;
					 nMoedaCor		, cMoeda		, oMoedaCor		, cCodProd		,;
					 cProduto		, nTmpQuant		, nQuant		, cUnidade		,;
					 nVlrUnit		, nVlrItem		, oProduto		, oQuant		,;
					 oUnidade		, oVlrUnit		, oVlrItem		, lF7			,;
					 cCliente		, cLojaCli		, lOcioso		, nVlrFSD		,;
					 nVlrDescTot	, aItens		, nVlrMerc		, lFechaCup		,;
					 cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
					 aRecCrd		, aTEFPend		, aBckTEFMult	, cCodConv		,;
					 cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
					 aVidaLinkD		, aVidaLinkc	, nVidaLink		, lVerTEFPend	,;
					 nTotDedIcms	, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,;
					 nVlrPercOri	, nQtdeItOri	, nNumParcs		, aImpsSL1		,;
					 aImpsSL2		, aImpsProd		, aImpVarDup	, aTotVen		,;
					 nTotalAcrs		, aCols			, aHeader		, aDadosJur		,;
					 aCProva		, lCXAberto		, oMensagem		, oFntGet 		,;
					 cTipoCli		, lAbreCup		, lReserva		, aReserva		,;
					 nValor			, aRegTEF		, lRecarEfet	, nHdlECF		,;
					 aFormCtrl      )

Local nX         := 0              
Local nY         := 0
Local lWSOrcam   :=.T.											//Verifica se chama a rotina novamente
Local lRet       := .T.                                         //Retorno da Funcao
Local lContinua  := .T.

If ValType(cItemCond) <> "C" .OR. ValType(aPgtos) <> "A" .OR. Len(aPgtos) == 0
	MsgStop( STR0080, STR0023 ) //"Para geração de orçamento, é necessário que seja definida as formas de pagamento via <F9>!"###"Atenção"
	lContinua := .F.
Endif
                     
If lContinua

	//Ativa o servico que esta no fonte WSCRD120
	oSvc := WSCRDORCAMENTO():New()
	oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDORCAMENTO.apw"
			                                                
	oSvc:oWSWSDADOSORC:oWSCABEC			:= CRDORCAMENTO_CABECSTRUCT():NEW()
	oSvc:oWSWSDADOSORC:oWSITEM			:= CRDORCAMENTO_ARRAYOFITEMSTRUCT():NEW()
	oSvc:oWSWSDADOSORC:oWSPARCELAS		:= CRDORCAMENTO_ARRAYOFPARCSTRUCT():NEW()
	
	//CABECALHO
	DbSelectArea( "SL1" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "SL1" ) + cOrcam )
		
		oSvc:oWSWSDADOSORC:oWSCABEC:cFILIAL		:= xFilial("SL1")
		oSvc:oWSWSDADOSORC:oWSCABEC:cOrcamento	:= SL1->L1_NUM
		oSvc:oWSWSDADOSORC:oWSCABEC:cCliente	:= cCliente
		oSvc:oWSWSDADOSORC:oWSCABEC:cLoja		:= cLojaCli
		oSvc:oWSWSDADOSORC:oWSCABEC:cVendedor	:= cVendLoja
		oSvc:oWSWSDADOSORC:oWSCABEC:cOperado	:= SL1->L1_OPERADO
		oSvc:oWSWSDADOSORC:oWSCABEC:cSitua		:= Space(TamSx3("L1_SITUA")[1])
		oSvc:oWSWSDADOSORC:oWSCABEC:cCondpg		:= cItemCond
		oSvc:oWSWSDADOSORC:oWSCABEC:cFormpg		:= If( lUsaTef .AND. lTefOk .AND. !empty(aTefDados[1][15]), aTefDados[1][15], If((cItemCond=="CN" .AND. !lCondNegF5 .AND. len(aPgtos)==0),If(Len(aFormCtrl)>1,aFormCtrl[2][1],aFormCtrl[1][1]),aPgtos[1][3]))
		oSvc:oWSWSDADOSORC:oWSCABEC:nParcela	:= len(aPgtos)
		oSvc:oWSWSDADOSORC:oWSCABEC:dDtLim		:= dDatabase
		
	Endif
	
	
	// ITEM
	
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "SL2" ) + cOrcam )
	 
		While !Eof() .AND. L2_FILIAL + L2_NUM == xFilial( "SL2" ) + cOrcam
		aadd( oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT		,  CRDORCAMENTO_ITEMSTRUCT():NEW() )	
		   nX:=LEN(OSVC:OWSWSDADOSORC:OWSITEM:OWSITEMSTRUCT) 
	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cFILIAL 		:= xFilial("SL2")
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cOrcamento  	:= SL2->L2_NUM
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cProduto		:= SL2->L2_PRODUTO	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cDescProd		:= SL2->L2_DESCRI
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cItem			:= SL2->L2_ITEM
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nQuant			:= SL2->L2_QUANT	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nVlrUni		:= SL2->L2_VRUNIT
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nVlrItem		:= SL2->L2_VLRITEM
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nPrcTab		:= SL2->L2_PRCTAB	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nDesc			:= SL2->L2_DESC
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:nVlrDesc		:= SL2->L2_VALDESC		
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cSerie			:= SL2->L2_SERIE	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cPDV			:= SL2->L2_PDV	
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cSitua			:= Space(TamSx3("L2_SITUA")[1])
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cTES			:= SL2->L2_TES
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cCF			:= SL2->L2_CF
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cTabela		:= SL2->L2_TABELA
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cArmazem		:= Posicione("SBI",1,xFilial("SBI")+SL2->L2_PRODUTO,"SBI->BI_LOCPAD")
			oSvc:oWSWSDADOSORC:oWSITEM:oWSITEMSTRUCT[nX]:cUnidMedida	:= Posicione("SBI",1,xFilial("SBI")+SL2->L2_PRODUTO,"SBI->BI_UM")
		
			DbSkip()
		End
	Endif
	
	// PARCELAS
	
	For nY := 1 to len(aPgtos) 
		aadd( oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT		,  CRDORCAMENTO_PARCSTRUCT():NEW() )	
			oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT[nY]:cFILIAL 		:= xFilial("SL2")
			oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT[nY]:cOrcamento  	:= SL1->L1_NUM
			oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT[nY]:dDataparc		:= aPgtos[nY][1]
			oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT[nY]:nValor			:= aPgtos[nY][2]		
			oSvc:oWSWSDADOSORC:oWSPARCELAS:oWSPARCSTRUCT[nY]:cForma			:= aPgtos[nY][3]
	
	Next nY	
	
	
	lWSOrcam := .T.
	While lWSOrcam
		LJMsgRun( STR0053,, {|| lRet := oSvc:Orcamento( cUsrSessionID ) } ) //"Aguarde... Incluindo orçamento na Retaguarda"
		If !lRet
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
				
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				
				// Se necessario efetua outro login antes de chamar o metodo novamente
				If cSoapFCode $ "-1,-2,-3"
					LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
					lWSOrcam := .T.
				Else
					MsgStop(cSoapFDescr, "Error " + cSoapFCode)
					//MsgStop("Sem comunicação com o WebService!","Atenção.")
					lWSOrcam := .F.	// Nao chama o metodo novamente
				Endif
				
			Else
				//MsgStop(GetWSCError(), STR0047) //"FALHA INTERNA" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³"Sem comunicação com o WebService!","Atenção."³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgStop(STR0078, STR0079)
				lWSOrcam := .F. // Nao chama o metodo  novamente
			Endif
		Else
		
			cMsgOrc := oSvc:cORCAMENTORESULT
			lWSOrcam := .F.	// Nao chama o metodo novamente
			 
			// Permitir a impressao do orcamento
			If MsgYesNo(cMsgOrc + chr(13) + STR0059) //"Deseja imprimi-lo?"
				If ExistBlock("LJIMPORC")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz o cancelamento do cupom fiscal                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					FR271FCancCup(	.F.				, @oHora		, @cHora		, @oDoc			,;
									@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
									@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
									@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
									@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
									@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
									@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
									@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
									@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
									@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
									@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
									@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
									@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
									@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
									@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
									@aVidaLinkD		, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,;
									@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@nTotalAcrs		, @aCols		, @aHeader		, @aDadosJur	,;
									@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
									@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,;
									@nValor			, @aRegTEF		, @lRecarEfet )
													

					If CRDCUPABERTO()
						Execblock("LJIMPORC", .F., .F., {nHdlECF})
					Endif
				Else                         
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz o cancelamento do cupom fiscal                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					FR271FCancCup(	.F.				, @oHora		, @cHora		, @oDoc			,;
									@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
									@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
									@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
									@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
									@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
									@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
									@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
									@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
									@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
									@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
									@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
									@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
									@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
									@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
									@aVidaLinkD		, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,;
									@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@nTotalAcrs		, @aCols		, @aHeader		, @aDadosJur	,;
									@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
									@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,;
									@nValor			, @aRegTEF		, @lRecarEfet )

					
					If CRDCUPABERTO()
						IFRelGer(nHdlECF, STR0060 + " [" + SubStr(cMsgOrc, 11, 6) + "]", 1) //"Orcamento nr.:"
					Endif
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz o cancelamento do cupom fiscal                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				FR271FCancCup(	.F.				, @oHora		, @cHora		, @oDoc			,;
								@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
								@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
								@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
								@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
								@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
								@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
								@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
								@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
								@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
								@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
								@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
								@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
								@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
								@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
								@aVidaLinkD		, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,;
								@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
								@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
								@nTotalAcrs		, @aCols		, @aHeader		, @aDadosJur	,;
								@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
								@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,;
								@nValor			, @aRegTEF		, @lRecarEfet )
				
				
			Endif
			
		Endif
	End
Endif
		
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdCredCliºAutor  ³Vendas Clientes     º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o cliente tem ou nao limite disponivel para a   º±±
±±º          ³compra                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³lExp1 := CrdCredCli(cExp2,cExp3,nExp4,aExp5,nExp6,dExp7,    º±±
±±º          ³                    aExp8)                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lExp1 - Logico. Indica se o cliente tem ou nao credito para º±±
±±º          ³        confirmar a operacao                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp2 - Codigo do cliente                                   º±±
±±º          ³cExp3 - Loja do cliente                                     º±±
±±º          ³nExp4 - Valor a financiar                                   º±±
±±º          ³aExp5 - Dados da venda                                      º±±
±±º          ³nExp6 - Valor dos titulos em aberto                         º±±
±±º          ³dExp7 - Data de vencimento de LC							  º±±
±±º          ³aExp8 - NCCs pendentes do cliente avaliado		          º±±    
±±º          ³aExp9 - Verifica se bloqueio por passagem de risco          º±±    
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdCredCli( cCliente  , cLoja    , nValorFin, aDadosCrd, ;
                     nTitAberto, dDtVencLC, aNCCVenda, lPassagem )

Local lRet       := .T.              		//Define o prosseguimento da operacao 
Local nLCSA1     := 0						//Limite de credito cadastrado no SA1	
Local nLCMA7     := 0           			//Limite de credito extra
Local nX         := 0 						//Contador
Local nY         := 0						//Contador
Local nPos       := 0						//Posicao do saldo dentro do array
Local nLimite    := 0
Local nValAbr    := 0
Local nTole      := SuperGetMV("MV_CRDTOLE",,0)		//Variavel para armazenar o valor de tolerancia para liberacao automatica do credito
Local aSaldoMeses:= {}                       		//Saldos dos titulos em aberto por mes
Local nMvCrdBloq := SuperGetMv("MV_CRDBLOQ",,0)		// Define o tipo de bloqueio manual a ser realizado 1)Nro de dias 2) por nro de compras(ainda nao implementado)
Local nMvNumBloq := SuperGetMv("MV_NUMBLOQ",,0)		// Se o nro de dias entre a ultima compra e a atual for menor ou igual a este deve bloquear
Local nNroDias	 := 0								// Nro de dias entre a ultima compra e a compra atual

DEFAULT aDadosCrd   := {}
DEFAULT aNCCVenda   := {}               	// Array com as NCCs pendentes do cliente. O valor da NCC deve ser abatido da soma dos titulos em aberto  

Conout("23. CRDXFUN INICIO da CrdCredCli")

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1")+cCliente+cLoja)
   	
   	nLCSA1    	:= SA1->A1_LC
	dDtVencLC	:= SA1->A1_VENCLC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se faz o bloqueio por Numero de passagem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If nMvCrdBloq > 0     
		//Bloqueia por Numero de dias de passagem entre a ultima compra e a compra atual
		If nMvCrdBloq == 1                                                              
			If !Empty(SA1->A1_ULTCOM)
				nNroDias := ( dDatabase - SA1->A1_ULTCOM   ) 
				//Se o nro de dias for menor ou igual ao nro de dias configurado para bloqueio faz o bloqueio da venda
				If nNroDias <= nMvNumBloq 
					lPassagem := .T.
					Conout("24b. CRDXFUN - CrdCredCli - Bloquei efetuado pelo parametro MV_NUMBLOQ " )
					lRet := .F.		
				Endif
			Endif	
		Endif
	Endif
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//³Validacao da data de vencimento do limite de credito(A1_VENCLC)³
	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SA1->A1_VENCLC)
	   		lRet := .F.                           
	   	  	Conout("24a. CRDXFUN - CrdCredCli - Data de Limite de credito esta nula " )
	   	ElseIf SA1->A1_VENCLC < dDatabase
	    	Conout("24. CRDXFUN - CrdCredCli - " +;
	      			"Data de LC vencida " + If(Empty(SA1->A1_VENCLC),"", DTOC(SA1->A1_VENCLC)) + ;
	             	" Cliente " + cCliente+cLoja)      
	      	lRet       := .F.    
	   	Endif    
	Endif
Else
	Conout("25. CRDXFUN - CrdCredCli, nao achou cliente no SA1 " + cCliente + cLoja)   
Endif

If lRet
	DbSelectArea("MA7")
	DbSetOrder(1)
	If DbSeek(xFilial("MA7")+cCliente+cLoja)
		nLCMA7  := MA7->MA7_LC
	Endif

    Conout("26. CRDXFUN - CrdCredCli, chama CrdTitAberto, nLCMA7 " + ALLTRIM(STR(nLCMA7)))   	
    
	nTitAberto := CrdTitAberto( cCliente     ,cLoja    ,NIL    ,NIL    ,;
	                            @aSaldoMeses ,aNCCVenda )
	
	If MA7->MA7_TPCRED <> "1"
		lRet := ((nLCSA1 + nLCMA7 + nTole) >= ( nTitAberto + nValorFin ))  //Endividamento global		
        Conout("27. CRDXFUN - CrdCredCli, (nLCSA1 + nLCMA7 + nTole) " +;
        		 ALLTRIM(STR((nLCSA1 + nLCMA7 + nTole))) + ;
               	" nTitAberto + nValorFin " + ALLTRIM(STR(nTitAberto + nValorFin)) +;
               	"MA7_CONTRA " + MA7->MA7_CONTRA)   			
	Else
		If Len( aSaldoMeses ) > 0
			For nX := 1 to Len( aSaldoMeses )
				Conout("96. CRDXFUN - aSaldoMes[" + STR(nX) +"][1]" + Alltrim(STR(aSaldoMeses[nX][1])) )
				Conout("97. CRDXFUN - aSaldoMes[" + STR(nX) +"][2]" + aSaldoMeses[nX][2] )
				For nY := 1 to Len( aDadosCrd[8] )
					nPos := aScan( aSaldoMeses, {|x| x[2] == AllTrim(Str(Year(aDadosCrd[8][nY][1])))+AllTrim(StrZero(Month(aDadosCrd[8][nY][1]),2,0))  })
					Conout("98. CRDXFUN - aSaldoMes(nLCSA1 + nLCMA7 + nTole) " +;
        		 			ALLTRIM(STR( nLCSA1 + nLCMA7 + nTole) ) + ">=" +;
        		 			ALLTRIM(STR(aDadosCrd[8][nY][2] + IIf(nPos>0,aSaldoMeses[nPos][1],0))) )
					lRet := ((nLCSA1 + nLCMA7 + nTole) >= ( aDadosCrd[8][nY][2] + IIf(nPos>0,aSaldoMeses[nPos][1],0) ))
					If !lRet
						Conout("99. CRDXFUN - nValorFin := " + Alltrim(STR(aDadosCrd[8][nY][2])) )
						nValorFin := aDadosCrd[8][nY][2]
						Exit
					Endif
				Next nY
			Next nX               
		Else
			For nY := 1 to Len( aDadosCrd[8] )
				Conout("100. CRDXFUN - aDadosCRD (nLCSA1 + nLCMA7 + nTole) " +;
        		 		ALLTRIM(STR( nLCSA1 + nLCMA7 + nTole) ) + ">=" +;
        		 		ALLTRIM(STR(aDadosCrd[8][nY][2])) )
				lRet := ((nLCSA1 + nLCMA7 + nTole) >= ( aDadosCrd[8][nY][2] ))
				If !lRet                                
					Conout("101. CRDXFUN - nValorFin := " + ALLTRIM(STR(aDadosCrd[8][nY][2])) )
					nValorFin := aDadosCrd[8][nY][2]
					Exit
				Endif                              
			Next nY                             
		Endif                                
	Endif                         
Else                                  
                               
	DbSelectArea("MA7")
	DbSetOrder(1)
	If DbSeek(xFilial("MA7")+cCliente+cLoja)
	
   		If MA7->MA7_TPCRED == "1"	//Limite Mensal
			For nY := 1 to Len(aDadosCrd[8]) 			
				If !Empty(aDadosCrd[8][nY][2])	//Pega o valor da parcela financiada
					nValorFin := aDadosCrd[8][nY][2]
					exit
				Endif			
			Next nY
		Endif                               
		
	Endif
Endif

Return (lRet)
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdGuardaMºAutor  ³Vendas Clientes     º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Armazena os saldos dos titulos agrupados por mes            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdGuardaMes(ExpN1,ExpC2,ExpA3)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com total do saldo por mes          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Valor a ser gravado ou somado no array              º±±
±±º          ³ExpC2 - Mes                                                 º±±
±±º          ³ExpA3 - Array de retorno com o saldo agrupado por mes       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdGuardaMes( nValor, cMes, aSaldoMeses )
Local nPos := 0

If Empty(aSaldoMeses)
	AAdd( aSaldoMeses,{nValor,cMes})
Else
	If ( nPos := aScan( aSaldoMeses,{|x| x[2] == cMes} )) > 0
		aSaldoMeses[nPos][1] += nValor
	Else
		AAdd( aSaldoMeses,{nValor,cMes})
	Endif
Endif

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma       ³CrdCpvFin ºAutor  ³Vendas Clientes     º Data ³  06/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.          ³ Executa a Impressao do Comprovante de Financiamento quando º±±
±±º               ³ a Retaguarda estiver inacessivel (AD Off-Line).            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso            ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdCpvFin()
Local aComprov 	    := {}                            			// Array com os dados a serem impressos no comprovante de recebimento
Local cNome			:= ""                            			// Nome do cliente a ser impresso
Local cMvSimb1		:= SuperGetMV("MV_SIMB1")        			// Simbolo da moeda principal 
Local cTicket		:= ""                            			// Texto nao-fiscal enviado ao ECF
Local cImpressora   := ""                            			// Tipo de impressao:"1"-Nao imprime;"2"-Fiscal;"3"-Via Word
Local cMvCrdDoc1 	:= SuperGetMV("MV_CRDDOC1",,"CRDDOC1.DOT")	// Documento word (.dot) que contem o comprovante de financiamento
Local cMV_FORMCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI")  		//Formas de pagamento que devem ter analise de credito
Local nX			:= 0                             			// Controle de loop
Local nVias			:= 0                             			// Numero de vias a serem impressas
Local aArea			:= GetArea()                     			// Area atual
Local nQtdParcel    := 0                             			// Quantidade de parcelas do recebimento
Local nVlrParcel    := 0                             			// Valor das parcelas do recebimento
Local nRange		:= SuperGetMV("MV_LJCHVST",NIL,-1)  		// Controla quantidade de dias para o cheque ser considerado a vista
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)					// Verifica as filiais da trabalharam com acrescimento separado								
Local nDiasPagto	:= 0										// Dias da condicao de pagamento
Local nValorL4 		:= 0										// Maior valor da parcela
Local nAcrsFin 		:= 0   										// % de acrescimo financeiro
Local lSoma			:= .F.										// Variavel utilizada para somar valores em acrescimo financeiro
Local nL4ValTot		:= 0										// Valor total financiado
Local lR5			:= GetRpoRelease("R5")						// Indica se o release e 11.5

// Verifica se o cadastro do cliente existe localmente na base de dados do Caixa
DbSelectArea("SA1")
If	DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA)
	cNome := SA1->A1_NREDUZ
Endif

DbSelectArea("SL4")
DbSetOrder(1)
If	DbSeek(xFilial("SL4")+SL1->L1_NUM)
	If (lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")) .AND. ;         
	    SE4->(FieldPos("E4_LIMACRS") > 0) .AND. SL4->(FieldPos("L4_ACRSFIN") > 0)		
		
		If Alltrim(SL4->L4_FORMA) == "FI"
			nValorL4 := SL4->L4_VALOR
			nAcrsFin := SL4->L4_ACRSFIN		      
		Endif     
	Endif
	While ! SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM	
	    lSoma := .F.
		IF Alltrim(SL4->L4_FORMA) $ cMV_FORMCRD
			
		    
		    If Alltrim(SL4->L4_FORMA) == "CH"		
			    //Se for cheque a prazo tambem conta como parcela
			    If nRange >= 0
				   If SL4->L4_DATA >= dDataBase+nRange
					  nQtdParcel ++
					  nVlrParcel += SL4->L4_VALOR
					  lSoma := .T.
				   Endif
			   Endif						    
			ElseIf SAE->(DbSeek(xFilial("SAE")+Left(SL4->L4_ADMINIS,TamSx3("AE_COD")[1])))
				If SAE->AE_PLABEL == "1" 
					nQtdParcel ++
					nVlrParcel += SL4->L4_VALOR
					lSoma := .T.
				Endif
			ElseIf SL4->L4_FORMA == "FI"
				nQtdParcel ++
				nVlrParcel += SL4->L4_VALOR
				lSoma := .T.
			Endif   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alteracao para enviar os parametros corretos para alteracao de comprovante   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSoma .AND. (lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")) .AND. ;    
			   SE4->(FieldPos("E4_LIMACRS") > 0) .AND. SL4->(FieldPos("L4_ACRSFIN") > 0)
			 								
				
				If Alltrim(SL4->L4_FORMA) == "FI"
					If SL4->L4_VALOR > nValorL4
	   					nValorL4 := SL4->L4_VALOR
	            		nAcrsFin := SL4->L4_ACRSFIN
	            		Conout("90. CRDXFUN - nValorL4 " + Alltrim(STR(nValorL4)) ) 
	            		Conout("91. CRDXFUN - nAcrsFin " + Alltrim(STR(nAcrsFin)) )
	            		
	   				Endif
					nL4ValTot += NoRound(SL4->L4_VALOR)
				Endif   				
		   		DbSelectArea("SE4")
		   		DbSetOrder(1)
		   		If DbSeek(xFilial("SE4") + SL1->L1_CONDPG)
	         		nDiasPagto	:= SE4->E4_LIMACRS
 	       		Endif
			ElseIf lSoma .AND. (lVerEmpres .OR. (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")) .AND. ;    
			   SL4->(FieldPos("L4_ACRSFIN") > 0)
			 								
				If Alltrim(SL4->L4_FORMA) == "FI"
					If SL4->L4_VALOR > nValorL4
	   					nValorL4 := SL4->L4_VALOR
	            		nAcrsFin := SL4->L4_ACRSFIN
	            		Conout("90. CRDXFUN - nValorL4 " + Alltrim(STR(nValorL4)) ) 
	            		Conout("91. CRDXFUN - nAcrsFin " + Alltrim(STR(nAcrsFin)) )
	            		
	   				Endif
					nL4ValTot += NoRound(SL4->L4_VALOR)
				Endif   				
	   			nDiasPagto	:= 0	
	   		Endif			
		Endif
		 
		If !Empty(nVlrParcel)
			Conout("102. CRDXFUN - nVlrParcel " + Alltrim(STR(nVlrParcel)) ) 
		Endif
		
		SL4->(DbSkip())
	End

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Confirguracao do comprovante de credito                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aComprov, "" )
aAdd( aComprov, "" )
aAdd( aComprov, STR0061 )													//"       C O M P R O V A N T E   D E  "
aAdd( aComprov, STR0062 ) 													//"        F I N A N C I A M E N T O 	"
aAdd( aComprov, "" )
aAdd( aComprov, STR0063 )													//"          ** VENDA OFF-LINE **		"
aAdd( aComprov, "" )
aAdd( aComprov, STR0064 + Dtoc(SL1->L1_EMISSAO) + STR0065 + SL1->L1_HORA ) 		//"Data: "###" Hora: "
aAdd( aComprov, STR0066 + SM0->M0_CODIGO + "-" + FWGETCODFILIAL + "-" + Alltrim(SM0->M0_NOME) )	//"Estabel.: "
aAdd( aComprov, STR0067 + Alltrim(SLG->LG_PDV) ) 					//"PDV:  "

If !Empty(cNome)
	aAdd( aComprov, STR0068 + cNome ) 									//"Cliente : "
Endif

// Imprimir o CPF do cliente
If !Empty(SL1->L1_CGCCART) 
	If Len(ALLTRIM(SL1->L1_CGCCART)) <= 14
		aAdd( aComprov, STR0069 + SL1->L1_CGCCART ) 					//"Cpf     : " 
	Else
		// Imprimir o codigo do Cartao do cliente
		aAdd( aComprov, STR0070 + SL1->L1_CGCCART ) 					//"Cartao  : "
	Endif
Endif
			
aAdd( aComprov, STR0072 + StrZero( nQtdParcel ,2,0) ) 		//"Parcelas: "
aAdd( aComprov, STR0073 + cMVSimb1 + Alltrim(Transform(nVlrParcel ,"@E 999,999,999.99")) ) 	//"Valor   : "
aAdd( aComprov, "" )
aAdd( aComprov, STR0074 )													//"         Confirmo que pagarei "
aAdd( aComprov, STR0075 )													//"          a importancia acima "
aAdd( aComprov, "" )
aAdd( aComprov, "" )
aAdd( aComprov, "----------------------------------------" )
aAdd( aComprov, STR0076 ) 													//"              Assinatura " 
		
If ExistBlock("CRD010C")
	aComprov := ExecBlock("CRD010C",.F.,.F.,{aComprov, nL4ValTot, nDiasPagto, nQtdParcel, nValorL4, nAcrsFin})
ElseIf (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA" .AND. FindFunction("LjxCrdCf"))   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalhar com o conceito de acrescimo separado, ³
	//³altera mensagem do comprovante de financiamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aComprov := LjxCrdCf(aComprov, nL4ValTot, nDiasPagto, nQtdParcel, nValorL4, nAcrsFin)	
Endif
aAdd( aComprov, "" )
aAdd( aComprov, Replicate( "=", 40 ) )
    
For nX := 1 to Len(aComprov)
	 cTicket += aComprov[nX] + Chr(10)
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a impressao do comprovante de financiamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SLG->(FieldPos("LG_CRDVIAS")) > 0
	nVias := LjGetStation("CRDVIAS")
Else
	nVias := 1		// Traz uma via por Default
Endif
				                                
If nVias > 0
	If SLG->(FieldPos("LG_CRDIMP")) > 0
		cImpressora := LJGetStation("CRDIMP")
	Else
		cImpressora := "2" 	// Traz a impressora fiscal por Default
	Endif
			
	If cImpressora == "2" 	// Fiscal
		nRetECF := IFAbrCNFis( nHdlECF, Tabela("24",Alltrim(SL1->L1_FORMPG),.F.), Str(SL1->L1_VLRLIQ,14,2), "01" )
		If nRetECF == 0
			nRetECF := IFTxtNFis( nHdlECF, cTicket, nVias )
			If nRetECF == 0
				IFFchCNFis( nHdlECF )
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se não conseguir imprimir um cupom nao fiscal, manda um     ³
			//³Relatorio Gerencial para o ECF  (Alguns ECF, por exemplo a  ³
			//³Sweda, não permite que seja vinculado um cupom nao fiscal   ³
			//³a um outro cupom nao fiscal)                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRetECF := IFRelGer( nHdlECF, cTicket, nVias )
			If nRetECF <> 0
				// "Não foi possível imprimir o comprovante de financiamento. Verifique o ECF e solicite a re-impressão."
				MsgStop(STR0049)
			Endif
		Endif
	ElseIF cImpressora == "3"	// Impressao via Word 
		CrdxImpDoc( cMvCrdDoc1, nVias, {{"CRD_TICKET",StrTran(cTicket,Chr(10),Chr(13))}} )
	Endif
Endif

RestArea( aArea )  //Restauro a area original

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdSa1AlteºAutor  ³Vendas Clientes      º Data ³  19/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna .T. se conteudo de algum campo do SA1 da retaguarda º±±
±±º          ³ estiver diferente do front.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1: Array com os campos do cliente a ser pesquisado na   º±±
±±º          ³        base do checkout                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdSa1Alte( aCliente )
Local aArea			:= GetArea()					//Area Atual
Local nPosCli										//Posicao do codigo do cliente no array aCliente
Local nPosLoja										//Posicao da loja do cliente no array aCliente
Local nI											//Variavel de apoio
Local nTamCliente	:= Len( aCliente )				//Tamanho do array aCliente
Local lCrdSa1Alte	:= .F.							//Variavel de apoio para alteraco do SA1

If ValType( aCliente ) == "A" .AND. Len( aCliente ) > 1
	SA1->( DbSetOrder( 1 ) )

	nPosCli	    := AScan( aCliente, { |x| Trim( x[1] ) == "A1_COD" } ) 	//Posicao do campo codigo do cliente
	nPosLoja	:= AScan( aCliente, { |x| Trim( x[1] ) == "A1_LOJA" } )	//Posicao do campo Loja do cliente
	
	If SA1->( DbSeek( xFilial( "SA1" ) + aCliente[nPosCli][2] + aCliente[nPosLoja][2] ) )
		For nI := 1 To nTamCliente	
			//Tratamento para campos do tipo data e com ano inferior a 1950 devido inconsistencia da informacao do WebService
			//Demais situacoes nao necessita tratamento					
			If Valtype(aCliente[nI][2]) == "D" .AND. Year(SA1->( FieldGet( FieldPos( aCliente[nI][1] ) ) ) ) < 1950 			
				If Subs( DToS( SA1->( FieldGet( FieldPos( aCliente[nI][1] ) ) ) ), 3, 8 ) <> Subs( DToS( aCliente[nI][2] ), 3, 8 )
					lCrdSa1Alte := .T.
	
					Exit
				EndIf 
			Else 
				If SA1->( FieldGet( FieldPos( aCliente[nI][1] ) ) ) <> aCliente[nI][2]
					lCrdSa1Alte := .T.
	
					Exit
				EndIf
			EndIf
		Next nI			
	Else
		lCrdSa1Alte := .T.
	Endif
Endif

RestArea( aArea )  //Retorno da area do sistema

Return ( lCrdSa1Alte )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CRDAvalCreºAutor  ³Vendas Clientes     º Data ³  19/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Chama WS para avaliar o credito do cliente                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CRDAvalCred(ExpA1, ExpL2, ExpA3, ExpA4, ExpA5, ExpA6, ExpL7 º±±
±±º          ³ExpA8, ExpC9, ExpL10, ExpL11)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - array com dados da analise de credito               º±±
±±º          ³ExpL2 - determina se o cliente foi encontrado na base       º±±
±±º          ³ExpA3 - parcelas do financiamento                           º±±
±±º          ³ExpA4 - produtos da venda                                   º±±
±±º          ³ExpA5 - parcelas da venda                                   º±±
±±º          ³ExpA6 - tipo e numero do documento(CNPJ ou CPF)/cartao      º±±
±±º          ³ExpL7 - determina se foi chamado do Front Loja              º±±
±±º          ³ExpA8 - array contendo os dados do cliente usado para compa-º±±
±±º          ³tibilizar a base local do PDV com a retaguarda		      º±±
±±º          ³ExpC9 - Numero do contrato								  º±±
±±º          ³ExpL10- Determina se envia para o Crediario				  º±±
±±º          ³ExpL11- Determina se eh modo de consulta de credito 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array contendo:                                             º±±
±±º          ³aRet[1] - Retorno da Funcao                                 º±± 
±±º          ³              0 - Aprovado                                  º±±
±±º          ³              1 - Nao aprovado                              º±±
±±º          ³              2 - Aprovado Off-line                         º±±
±±º          ³              3 - Rejeitado                                 º±±
±±º          ³              4 - Fila crediario                            º±±
±±º          ³aRet[2] - Valor do limite de credito do cliente             º±±
±±º          ³aRet[3] - Valor dos titulos em aberto do cliente            º±±
±±º          ³aRet[4] - Numero do contrato de credito                     º±±
±±º          ³aRet[5] - Indica se a venda foi rejeitada                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDAvalCred(aDadosCrd, lCliente, aParcCrd , aProdCrd,;
                     aParcVda , aRetCart, lFront   , aCliente,;
                     cContrato  ,lEnvCred  ,lModoCons ,lRecebimento)

Local aRet 			:= { 1, 0, 0, "", .T. }    		// Retorno da funcao
Local aNCCVenda     := IIf(Type("aNCCItens")<>"U",AClone(aNCCItens),{})
Local nPosCli		:= 0								// Posicao do campo A1_COD no array aCliente
Local nPosLoja		:= 0								// Posicao do campo A1_LOJA no array aCliente
Local nX        	:= 0                           		// Variavel de loop
Local nI           	:= 0                           		// Controle do numero de tentativas de login via WS
Local lNovoCliente 	:= .T.								// Indica se cria ou nao um novo registro no SA1
Local lForcada		:= .F.                     			// Indica se a venda foi liberada sem realizar a analise de credito
Local lWSVenda		:= .F.                     			// Controle da chamada do metodo GetVenda
Local lConnect		:= .F.                     			// Verifica conexao do WS
Local lRet          := .T.                     			// Controla se prossegue a operacao
Local lFecha		:= .T.								// Fecha tela de status
Local lRespCred		:= .F.								// Resposta do Crediario
Local lVendaDesbloq := .F.
Local cSvcError     := ""                       		// Codigo do erro da conexao WS
Local cSoapFCode    := ""                       		// Codigo do erro da conexao WS
Local cSoapFDescr   := ""                       		// Descircao do erro da conexao WS
Local cMsgBloque    := "Aguarde ..."            		// Mensagem de bloqueio de credito
Local cMsgStatus	:= Space(150)			    		// Mensagem com o status de bloqueio, consultado na retaguarda
Local bRefresh      := {|| Nil }                		// Refresh para o Timer
Local oTimer                                    		// Objeto do Timer
Local oFnt                                      		// Objeto do fonte
Local oDlgBloq                                 			// Objeto da caixa de dialogo de venda bloqueada
Local oMsgBloque                                		// Objeto da mensagem de bloqueio de credito
Local oMsgStatus                               			// Objeto da mensagem de status de credito
Local cMsgAguarde	:= GetNewPar( "MV_CRDMSG", STR0091)	// Mensagem de aguardo da resposta da analise de credito ###"Obrigado por comprar conosco... Aguarde um momento..."
Local cMsgAdic		:= "" 								// Mensagem adicional a ser exibida ao usuario no checkout retornada via Ponto de Entrada 
Local oMsgAdic                                 			// Objeto da mensagem adicional
Local cContrat		:= ""								// Numeracao do cartao
Local nMvCRDStat:= SuperGetMV("MV_CRDSTAT",,1)			//Retorna se a busca do status vai ser via RPC ou Web Service
Local uResult		:= NIL								// Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= ExistFunc("STFIsPOS") .AND.  STFIsPOS() .And. CrdxInt(.F.,.F.)	//Integração TotvsPDV x SIGACRD

DEFAULT lRecebimento := .F.

If lFront 
	Conout("28.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" lFront = .T. " )
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //| Busca os dados do cliente para comparar base da retaguarda com PDV    |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Len(aCliente) == 0
	  Conout("29.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" Len(aCliente) == 0 " )
      aCliente  := aClone(WSCrdConsCli( aDadosCrd[1], aDadosCrd[2] ))
   Endif   
   If !lCliente  //Se cliente ja existir comparo todos os campos para verificar se algum foi modificado
   		Conout("30.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" lCliente = .F.; Chama a funcao CRDSa1Alte( aCliente ) " )
      lCliente := CrdSa1Alte(aCliente)	
      If lCliente  //Na base local é includo cliente se ainda nao existir, ou atualizado caso alterado algum campo na retaguarda
      		Conout("31.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" lCliente = .T.  retorno da funcao CrdSa1Alte " )
	     If !Empty( aCliente ) .AND. ValType( aCliente ) == "A" 
				Conout("32.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" !Empty( aCliente ) " )
		    If Len( aCliente) == 1
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Se não encontrar o cliente limpa a variavel para o sistema solicitar  ³
			   //³ o cliente na FrtEncerra                                               ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  				Conout("33.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" Len( aCliente ) == 1 Solicita cliente novamente  lRet = .F. " )
			   lRet   := .F.
		    Endif																																				
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Checa se a chave primaria jah existe no check-out          ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If lRet
   				Conout("34.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					"  lRet = .T. " )
			   nPosCli 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_COD" } )
			   nPosLoja 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_LOJA" } )
			   If nPosCli <> 0 .AND. nPosLoja <> 0
   	  				Conout("35.CRDXFUN - CRDAvalCred -> Contrato: " +;
						If( Empty(cContrato), "", cContrato) +;
						" Achou cliente e Loja em aCliente " )
				  aDadosCrd[16]  := aCliente[nPosCli][2]
				  aDadosCrd[17]  := aCliente[nPosLoja][2]
				  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  //³Faz a gravacao do cadastro do cliente no check-out         ³
				  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  lCliente 		:= .F.		// Não chama a tela padrão para selecionar o cliente
				  lNovoCliente 	:= .T.
				  DbSelectArea("SA1")
				  DbSetOrder(1)
				  If DbSeek(xFilial("SA1")+aDadosCrd[16]+aDadosCrd[17])
  	 				  Conout("36.CRDXFUN - CRDAvalCred -> Contrato: " +;
					    	If( Empty(cContrato), "", cContrato) +;
							" Novo cliente = .F. " )
					 lNovoCliente := .F.
				  Endif
				  FrtGeraSL( "SA1", aCliente, lNovoCliente )
				  aDadosCrd[2] := SA1->A1_CGC
			   Else
					Conout("37.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" Nao achou cliente " )
				  lRet   := .F.
			   Endif
			Endif
		 Else  
			Conout("38.CRDXFUN - CRDAvalCred -> Contrato: " +;
				If( Empty(cContrato), "", cContrato) +;
				" Empty(aCliente) " )
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Quando o sistema estiver off line, o caixa nao pode utilizar a opcao de Cartao Magnetico,³
		    //³devendo utilizar "Nao Magnetico" ou "CPF".                                               ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If aRetCart[1] == 1 // Cartao Magnetico
				Conout("39.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" Cartao magnetico nao permitido em oper off-line " )
			   lRet   := .F.
		    Else
			   If MsgNoYes(STR0057 + chr(13) + STR0058) //"Não foi possível a fazer a conexão com o servidor." //"Em caso de liberacao, deseja aprovar a venda na forma Off_line ?"
					Conout("40.CRDXFUN - CRDAvalCred -> Contrato: " +;
						If( Empty(cContrato), "", cContrato) +;
						" nao foi possivel conectar com o servidor, aprovacao off-line " )
				  aRet[1]   := 2
				  aRet[2]   := 0
				  aRet[3]   := 0
				  aRet[4]   := ""
				  aRet[5]   := .F.
				  lForcada  := .T.
			   Else
					Conout("41.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" nao foi possivel conectar com servidor nao aprovado off-line " )
				  lRet   := .F.
			   Endif
			Endif   
		 Endif
	  Else
			Conout("42.CRDXFUN - CRDAvalCred -> Contrato: " +;
				If( Empty(cContrato), "", cContrato) +;
				" lCliente = .F. " )
	  Endif	 
   Else
			Conout("43.CRDXFUN - CRDAvalCred -> Contrato: " +;
				If( Empty(cContrato), "", cContrato) +;
				" !lCliente " )
   Endif
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se os parametros da venda foram informados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !Empty(aParcCrd)
		Conout("44.CRDXFUN - CRDAvalCred -> Contrato: " +;
		If( Empty(cContrato), "", cContrato) +;
		" Valida se os parametros da venda foram informados " )
	
	If !lPosCrd		//Via WS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a transacao Web Service para o transacao de venda.   Faz o tratamen-³
	//³to se a transacao ainda estah ativa, caso contrario, faz novo login e     ³
	//³chama o metodo GetVenda novamente                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSvc := WSCRDVENDA():New()
		oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"
		oSvc:oWSWSENTRADAVENDA:cCARTAO 				:= aDadosCrd[1] 	// Numero do cartao
		oSvc:oWSWSENTRADAVENDA:cCPF 				:= aDadosCrd[2] 	// CPF
		oSvc:oWSWSENTRADAVENDA:nVLRTOTAL 			:= aDadosCrd[3] 	// Valor da venda
		oSvc:oWSWSENTRADAVENDA:nJUROS 				:= aDadosCrd[4] 	// Juros da venda
		oSvc:oWSWSENTRADAVENDA:nNUMPARCELAS 		:= aDadosCrd[5] 	// Numero de parcelas
		oSvc:oWSWSENTRADAVENDA:nVENDAFORCADA 		:= aDadosCrd[6] 	// Venda forcada
		oSvc:oWSWSENTRADAVENDA:cRESPVENDAFORCADA 	:= aDadosCrd[7]		// Responsavel pela venda forcada
		oSvc:oWSWSENTRADAVENDA:cLOJA 				:= aDadosCrd[9]		// Loja
		oSvc:oWSWSENTRADAVENDA:cPDV 				:= aDadosCrd[10]	// PDV
		oSvc:oWSWSENTRADAVENDA:cCAIXA 				:= aDadosCrd[11]	// Caixa
		oSvc:oWSWSENTRADAVENDA:cORCAMENTO         	:= aDadosCrd[12]	// Orcamento	
		oSvc:oWSWSENTRADAVENDA:cUSUARIO 			:= aDadosCrd[18]	// Nome do usuario
		oSvc:oWSWSENTRADAVENDA:cCONDPAG				:= aDadosCrd[19]	// Condicao de pagamento
		oSvc:oWSWSENTRADAVENDA:cMODULOCHAM			:= aDadosCrd[20]	// Modulo chamador
		oSvc:oWSWSENTRADAVENDA:cVEND				:= aDadosCrd[21]	// Codigo do vendedor
		oSvc:oWSWSENTRADAVENDA:oWSDADPARCELAS		:= CRDVENDA_ARRAYOFWSDADPARCELA():New()
		
		For nX := 1 to Len( aParcCrd )
			aAdd( oSvc:oWSWSENTRADAVENDA:oWSDADPARCELAS:oWSWSDADPARCELA , CRDVENDA_WSDADPARCELA():NEW() )
			oSvc:oWSWSENTRADAVENDA:oWSDADPARCELAS:oWSWSDADPARCELA[nX]:dVENCTO		:= aParcCrd[nX][1]
			oSvc:oWSWSENTRADAVENDA:oWSDADPARCELAS:oWSWSDADPARCELA[nX]:nVALORPARCELA	:= aParcCrd[nX][2]
			oSvc:oWSWSENTRADAVENDA:oWSDADPARCELAS:oWSWSDADPARCELA[nX]:cFORMAPGTO	:= aParcCrd[nX][3]
		Next nX
		
		oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS		:= CRDVENDA_ARRAYOFWSDADPRODUTO():New()
		
		For nX := 1 to Len( aProdCrd )
			aAdd( oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO , CRDVENDA_WSDADPRODUTO():NEW() )		
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:cITEM   	   := aProdCrd[nX][1]
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:cPRODUTO    := aProdCrd[nX][2]
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:cDESCRICAO  := aProdCrd[nX][3]
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:nQUANTIDADE := aProdCrd[nX][4]
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:nVUNITARIO  := aProdCrd[nX][5]
			oSvc:oWSWSENTRADAVENDA:oWSDADPRODUTOS:oWSWSDADPRODUTO[nX]:nVTOTAL     := aProdCrd[nX][6]
		Next nX
		
		oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4 := CRDVENDA_ARRAYOFWSDADOSSL4():New()
		
		For nX := 1 to Len( aParcVda )
			aAdd( oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4 , CRDVENDA_WSDADOSSL4():NEW() )
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:dVENCTO        := aParcVda[nX][1]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:nVALORPARCELA  := aParcVda[nX][2]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cFORMAPGTO     := aParcVda[nX][3]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cADMINIST      := aParcVda[nX][4]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cNUMCH         := aParcVda[nX][5]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cAGENCIACH     := aParcVda[nX][6]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cCONTACH       := aParcVda[nX][7]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cRGCH          := aParcVda[nX][8]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:cTELEFONECH    := aParcVda[nX][9]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:lVALOR         := aParcVda[nX][10]
			oSvc:oWSWSENTRADAVENDA:oWSDADOSSL4:oWSWSDADOSSL4[nX]:nMOEDA         := aParcVda[nX][11]
		Next nX
		
		oSvc:oWSWSENTRADAVENDA:cFILCRE  	:= cFilAnt 			// Venda forcada
		oSvc:oWSWSENTRADAVENDA:cCODCLI  	:= aDadosCrd[16]	// Codigo do cliente
		oSvc:oWSWSENTRADAVENDA:cLOJCLI  	:= aDadosCrd[17]	// Loja do cliente
		oSvc:oWSWSENTRADAVENDA:cUsuario 	:= aDadosCrd[18]	// Nome do Usuario
		oSvc:oWSWSENTRADAVENDA:cCONDPAG		:= aDadosCrd[19]	// Condicao de pagamento
		oSvc:oWSWSENTRADAVENDA:cMODULOCHAM 	:= aDadosCrd[20]	// Modulo chamador	
		oSvc:oWSWSENTRADAVENDA:cVEND		:= aDadosCrd[21]	// Codigo do vendedor
			
	    If LEN(aNCCVenda) > 0		
			Conout("45.CRDXFUN - CRDAvalCred -> Contrato: " +;
					If( Empty(cContrato), "", cContrato) +;
					" aNCCVenda > 0 " )
		    oSvc:oWSWSDADOSNCC:oWSDADOSNCC		:= CRDVENDA_ARRAYOFWSITENSNCC():New()    
			For nX := 1 to Len( aNCCVenda )
			   aAdd( oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC , CRDVENDA_WSITENSNCC():NEW() )
			   oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC[nX]:lMARCADO 	:= aNCCVenda[nX][1]
			   oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC[nX]:nSALDO   	:= aNCCVenda[nX][2]
			   oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC[nX]:cNUMERO  	:= aNCCVenda[nX][3]
			   oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC[nX]:dDTEMIS  	:= aNCCVenda[nX][4]         
			   oSvc:oWSWSDADOSNCC:oWSDADOSNCC:oWSWSITENSNCC[nX]:nSE1RECNO	:= aNCCVenda[nX][5]
			Next nX
		Endif
    
		nI := 1	
		While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aguarde... Efetuando login no servidor ...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 		  	      
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
		   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	CrdUpdUser( cUsrSessionID ) 
		   	nI++		  
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³1 segundo para nova checagem de login ³
		   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	Sleep(1000)
		End
	
	EndIf
	lWSVenda := .T.

	While lWSVenda
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//|  "Aguarde... Efetuando a consulta de crédito ..."      |
	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lPosCrd)		//Integração TOTVSPDV x SIGACRD
			lConnect := .F.
			If STBRemoteExecute("WsCrd010" ,{aDadosCrd  ,cContrato  ,lEnvCred  ,lModoCons, aNCCVenda  ,lRecebimento}, NIL,.T.	,@uResult)
				
				lConnect := .T.
				If Valtype(uResult) = "A" .AND. Len(uResult)>=4 .AND. Len(uResult[4])>=4
					nLiberado 	:= uResult[4][4]
					cMsgBloque 	:= uResult[3]
					nMotivo		:= uResult[1]
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD010 - GetVenda conectou com êxito!")
				Else
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD010 - GetVenda conectou, mas não recebeu os dados da análise!")
				EndIf
			Else
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + ": WSCRD010 - GetVenda - ERRO NA CONEXÃO")
			EndIf
			
		Else	//Via WS
			LJMsgRun( STR0042,, { || lConnect := oSvc:GETVENDA( cUsrSessionID, NIL, cContrato, lEnvCred, lModoCons, NIL, lRecebimento ) } )
		EndIf 

		If !lConnect
			Conout("46.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" Nao foi possivel Conectar " )
					
			If lPosCrd		// Integração TOTVSPDV x SIGACRD		
			
				cMsg := STR0045				//"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + " WSCRD010 - GetVenda NÃO CONECTADO")
				If MsgYesNo( "WSCRD010" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
				   lWSVenda := .T.
					Sleep( 5000 )		//5 segundos para nova checagem
				   
				Else
					lWSVenda:= .F. // Nao chama o metodo GetVenda novamente
					LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrato) + ": " + Alltrim(aDadosCrd[1]) + " - " + Alltrim(aDadosCrd[2]) + " WSCRD010 - GetVenda - Procedimento encerrado pelo usuário !")
					ConOut("WSCRD010 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
				EndIf 									
		
			Else		//Via WS
				cSvcError := GetWSCError()
	
				Conout( "70.CRDXFUN - " +;
						" Usuario: " + cUserName +;
						" cSvcError := " + cSvcError )
			EndIf
			
			If !lPosCrd .AND. Left( cSvcError, 9 ) == "WSCERR044"		// "Nao foi possivel post em http:// ..."		//Via WS
				Conout("47.CRDXFUN - CRDAvalCred -> " +;
				" Usuario: " + cUserName +;
				" Contrato: " + 	If( Empty(cContrato), "", cContrato) +;
				" cSvcError == WSCERRO44 - Nao foi possivel post em http " )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a mensagem referente ao Ad Off-Line já apareceu anteriormente.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lForcada
					Conout("48.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" lForcada = F " )
					If MsgNoYes( STR0057 + CHR( 13 ) + STR0058 ) //"Não foi possível a fazer a conexão com o servidor." //"Em caso de liberacao, deseja aprovar a venda na forma Off_line ?"
						Conout("49.CRDXFUN - CRDAvalCred -> " +;
							" Usuario: " + cUserName +;
							" Contrato: " + If( Empty(cContrato), "", cContrato) +;
							" Nao foi possivel conectar com o servidor - APROVOU off-line " )
						aRet[1]	:= 2
						aRet[2]	:= 0
						aRet[3]	:= 0
						aRet[4]	:= ""
						aRet[5]	:= .F.
						lForcada:= .T.
					Else
						Conout("50.CRDXFUN - CRDAvalCred -> " +;
							" Usuario: " + cUserName +;
							" Contrato: " + If( Empty(cContrato), "", cContrato) +;
							" Nao foi possivel conectar com o servidor - NAO aprovou off-line " )
					Endif
				Else
					Conout("51.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" lForcada = T " )
				Endif

				lWSVenda 	:= .F. 
			ElseIf !lPosCrd .AND. Left( cSvcError, 9 ) == "WSCERR048"				//Via WS
				Conout("52.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" cSvcError == WSCERRO48 " )
				
				cSoapFCode  := Alltrim( Substr( GetWSCError( 3 ), 1, At( ":", GetWSCError( 3 ) ) - 1 ) )
				cSoapFDescr := Alltrim( Substr( GetWSCError( 3 ), At( ":", GetWSCError( 3 ) ) + 1, Len( GetWSCError( 3 ) ) ) )
				
				Conout("71.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" cSoapFCode : " + cSoapFCode +;
					" cSoapFDescr: " + cSoapFDescr )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se necessario efetua outro login antes de chamar o metodo GetVenda novamente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cSoapFCode $ "-1,-2,-3"
					Conout("53.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" Se necessario efetua outro login.. cSoapFCod $ -1, -2, -3 " )
					LJMsgRun( STR0020,, { || cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
					CrdUpdUser( cUsrSessionID ) //Atualizacao da ID para o CRDXFUN (evitar reprocessamento)
					lWSVenda := .T.
				Else
					Conout("54.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" cSoapFCod Nao pertence a -1, -2, -3 " )
					lWSVenda := .F.
				Endif				
			Else	//Via WS //Integração TOTVSPDV x SIGACRD				
				Conout("55.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
					" lWSVenda = .F. " )
				lWSVenda := .F. 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a mensagem referente ao Ad Off-Line já apareceu anteriormente.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lForcada
					Conout("56.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" IF !lForcada " )
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³"Não foi possível a fazer a conexão com o servidor."              ³
					//³"Em caso de liberacao, deseja aprovar a venda na forma Off_line ?"³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If MsgNoYes( STR0057 + CHR( 13 ) + STR0058 ) 
						Conout("57.CRDXFUN - CRDAvalCred -> " +;
							" Usuario: " + cUserName +;
							" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
							" Aprovacao OFF-LINE " )
						aRet[1]	:= 2
						aRet[2]	:= 0
						aRet[3]	:= 0
						aRet[4]	:= ""
						aRet[5]	:= .F.
						lForcada:= .T.
					Else
						Conout("58.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" Nao aprovou OFF-LINE " )
					Endif
				Endif
			Endif			
		Else		//Conectado			
			Conout("59.CRDXFUN - CRDAvalCred -> " +;
				" Usuario: " + cUserName +;
				" Contrato: " + If( Empty(cContrato), "", cContrato) +;
				" lConnect = T " )
				
			If lPosCrd	//Integração TOTVSPDV x SIGACRD
				nLiberado := uResult[4][4]
			Else		//Via WS
				nLiberado := oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nLIBERADO
			EndIf
			
			If ValType( nLiberado ) == "N"
				Conout("72.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" nLiberado : " + ALLTRIM(STR(nLiberado)) )
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reseta a variavel Global todas as vezes que o cliente estiver liberado para efetuar a compra³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nLiberado == 0
					Conout("60.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" Reseta a variavel global todas as vezes q o cliente estiver liberado " )

					If nMvCRDStat == 1					
						PutGlbVars( aDadosCrd[16] + aDadosCrd[17], NIL )
					EndIf	
				Endif
           	Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Define a rotina time para ser ativada para o cliente  								³
			//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³Verifico o retorno da consulta Web Services.          								³
			//³Caso seja bloqueada a venda uma interface sera aberta para aguardar o retorno        ³
			//³da analise de credito.																³
			//³Caso a consulta retorno um outro status, referente a validacao de outro item, sera   ³
			//³apenas exibido a msg																	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( nLiberado ) == "N" .AND. nLiberado <> 0
				Conout("61.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" Chama o metodo GETVENDA " +;
					" nLiberado : " + ALLTRIM(STR(nLiberado)) )
				
				If lPosCrd	//Integração TOTVSPDV x SIGACRD
					cMsgBloque 	:= uResult[3]
					nMotivo		:= uResult[1]
				Else		//Via WS
					cMsgBloque 	:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:cMENSAGEM
					nMotivo		:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nMOTIVO
				EndIf
				
				Conout("61.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" cMsgBloque: " + cMsgBloque +;
					" nMotivo : " + ALLTRIM(STR(nMotivo)) )				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando cliente for enviado para a fila de crediario, nao mostrar a tela, ³
				//³apenas um alert pois significa que ele devera se encaminhar ao crediario.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( nMotivo == 8 .AND. nLiberado <> 3 )
				
					Conout("62.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
						" Motivo == 8 E nLiberado <> 3  " )
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a Session do Usuario e grava as informacoes do caixa na retaguarda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If CrdBloqueStatus( aDadosCrd[16], aDadosCrd[17], lFront  )
						Conout("63.CRDXFUN - CRDAvalCred -> " +;
							" Usuario: " + cUserName +;
							"Contrato: " + 	If( Empty(cContrato), "", cContrato) +;
							" Verifica Session do Usuario e grava as inf> na retaguarda " )
						If lPosCrd
							cContrat 	:= uResult[4][3]
						Else
							cContrat 	:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:cContrato
						EndIf
						DEFINE MSDIALOG oDlgVenda FROM 0, 0 TO 180, 550 TITLE STR0089 PIXEL STYLE DS_MODALFRAME 		//"Análise de Crédito" 
						
							@005, 005 GROUP oGrpStatus TO 55, 270 LABEL STR0090 OF oDlgVenda PIXEL 	//"Status Parcial" 
							@015, 010 SAY oMsgBloque VAR cMsgBloque FONT oFnt PIXEL SIZE 260,32

							@047, 010 SAY oMsgAdic VAR cMsgAdic FONT oFnt PIXEL SIZE 260,08
														
							oMsgBloque:SetColor( CLR_BLACK, GetSysColor( 15 ) )

							@055, 005 GROUP oGrpLegenda TO 75, 270 LABEL STR0092 OF oDlgVenda PIXEL	//"Legenda"
						    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Em Analise                                                                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							@062, 030 SAY oLegenda VAR STR0093 FONT oFnt PIXEL	
							oLegenda:SetColor( CLR_BLACK, GetSysColor( 15 ) )       
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Liberado                                                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							@062, 080 SAY oLegenda VAR STR0094 FONT oFnt PIXEL 	
							oLegenda:SetColor( CLR_GREEN, GetSysColor( 15 ) )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Rejeitado                                                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							@062, 120 SAY oLegenda VAR STR0095 FONT oFnt PIXEL	
							oLegenda:SetColor( CLR_HRED, GetSysColor( 15 ) )  
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Encaminhar ao Crediario                                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							@062, 160 SAY oLegenda VAR STR0096 FONT oFnt PIXEL 	
							oLegenda:SetColor( CLR_HBLUE, GetSysColor( 15 ) )                                
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Botao OK                                                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
							@077, 030 	BUTTON STR0102 SIZE 60, 13 OF oDlgVenda PIXEL; 
										ACTION ( lFecha := .T., oDlgVenda:End() ) WHEN ( lRespCred ) MESSAGE STR0097 //"Retornar à Venda"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verificar Status da AnAlise de Credito                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
							@077, 100 	BUTTON STR0103 SIZE 60, 13 OF oDlgVenda PIXEL; //"Resposta do crediário"
										ACTION ( LjMsgRun( cMsgAguarde,,;
										{ || CRDConsStatus(	aDadosCrd[16]	, aDadosCrd[17]	, @cMsgStatus	, oMsgBloque	,;
															@cMsgAdic		, @oMsgAdic		, @lRespCred	, @lVendaDesbloq );
										} ), MsgInfo( cMsgStatus, STR0023 ) ) WHEN ( .T. .AND. !lRespCred ) MESSAGE STR0099 //"Verificar Status da Análise de Crédito"
					                    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Botao Retornar a Venda                                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
							@077, 170 	BUTTON STR0104 SIZE 60, 13 OF oDlgVenda PIXEL;
								 		ACTION (	IIf(lFecha := CrdLocMA7(cUsrSessionID, aDadosCrd[16], aDadosCrd[17], cContrat),;
								 		 			oDlgVenda:End(), NIL) ) ;
										WHEN ( !lRespCred ) MESSAGE STR0097 //"Retornar à Venda"
							
						ACTIVATE MSDIALOG oDlgVenda VALID lFecha CENTERED
					Endif
				Else
					If !lRecebimento
						Conout("64.CRDXFUN - CRDAvalCred -> " +;
							" Usuario: " + cUserName +;
							" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
							" Mostra mensagem na tela " )
						MsgStop( cMsgBloque, STR0023 )//"Atenção"
					Endif
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorno do WebService                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Iif(lPosCrd, Valtype(uResult[4][4]), ValType(oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nLIBERADO)) == "N"
				Conout("65.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" Retorno do WEBSERVICE nLiberado== N " )
				If lPosCrd		//Integração TOTVSPDV x SIGACRD
					aRet[1] := uResult[4][4]
				Else			//Via WS
					aRet[1] := oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nLIBERADO
				EndIf
				//Venda desbloqueada pelo Crediario
				If lVendaDesbloq .AND. aRet[1] == 1
					Conout("73.CRDXFUN - CRDAvalCred -> " +;
						" Usuario: " + cUserName +;
						" Contrato: " + If( Empty(cContrato), "", cContrato) +;
						" Venda desbloqueada aRet[1]=1 " +;
						" lVendaDesbloq = .T. " )
				   aRet[1]  := 0
				Else
					Conout("74.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " + If( Empty(cContrato), "", cContrato) +;
					" aRet[1] : " + ALLTRIM(STR(aRet[1])) +;
					" lVendaDesbloq = " + If( lVendaDesbloq, ".T.", ".F.") )
				Endif
			Else
				Conout("66.CRDXFUN - CRDAvalCred -> " +;
					" Usuario: " + cUserName +;
					" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
					" Retorno do WEBSERVICE <> N " )
				aRet[1] := 1
			Endif
			If lPosCrd		//Integração TOTVSPDV x SIGACRD
				aRet[2]		:= uResult[4][1]
				aRet[3]		:= uResult[4][2]
				aRet[4]		:= uResult[4][3]
			Else			//Via WS
				aRet[2]		:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nLC
				aRet[3]		:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:nTITABERTO
				aRet[4]		:= oSvc:oWSGETVENDARESULT:oWSWSVENDA[1]:cCONTRATO
			EndIf
			aRet[5]		:= !(aRet[1] == 0 .OR. aRet[1] == 2)    
			lWSVenda 	:= .F.	
			
			Conout("75.CRDXFUN - CRDAvalCred -> " +;
				" Usuario: " + cUserName +;
				" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
				" Conteudo do aRet: " +;                  
				" aRet[1] : " + If( Valtype(aRet[1]) == "N", ALLTRIM(STR(aRet[1])), "") +; 
				" aRet[2] : " + If( Valtype(aRet[2]) == "N", ALLTRIM(STR(aRet[2])), "") +; 
				" aRet[3] : " + If( Valtype(aRet[3]) == "N", ALLTRIM(STR(aRet[3])), "") +; 
				" aRet[4] : " + If( Empty( aRet[4] ), "", aRet[4]) )
		Endif		
	End	
	If lForcada                
		Conout("67.CRDXFUN - CRDAvalCred -> " +;
				" Usuario: " + cUserName +;
				" Contrato: " +	If( Empty(cContrato), "", cContrato) +;
				" Venda forcada " )
		aRet[1] := 2          
		aRet[2] := 0          
		aRet[3] := 0          
		aRet[4] := ""         
		aRet[5] := .F.
	Endif
Endif

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CRDImprComºAutor  ³Vendas Clientes     º Data ³  25/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Faz a impressao do comprovante de financiamento             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CRDImprComp(ExpC1, ExpA2)                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - conteudo do ticket a ser impresso                   º±±
±±º          ³ExpA2 - array com informacoes da analise de credito         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDImprComp( cTicket, aDadosCrd )
Local nVias 		:= 0						// Quantidade de vias do comprovante de financiamento para impressao
Local nRetECF		:= 0						// Retorno do ECF
Local cImpressora	:= ""						// Indica qual a impressora para a impressão do comprovante de financiamento
Local cMvCrdDoc1 	:= SuperGetMV("MV_CRDDOC1",,"CRDDOC1.DOT")	// Documento word (.dot) que contem o comprovante de financiamento
Local lDadosCrd     := .F.                     // Verifica o tamanho do Array para enviar os comandos para o Ecf.
Local lTefUsado     := If ((AScan( aDadosCrd[14], {|x| x[3] == "CC"} ) > 0 .OR. AScan( aDadosCrd[14], {|x| x[3] == "CD"} ) > 0) ;
                            .AND. lUsaTef, .T.,.F.) // Verifica se foi usado Tef por causa do comprovante Vinculado. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - SmartClient HTML³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction ("LjChkHtml")
	If LjChkHtml()
		FwAvisoHtml()
		Return
	EndIf
EndIf
If SLG->(FieldPos("LG_CRDVIAS")) > 0
   nVias := LjGetStation("CRDVIAS")
Else
   nVias := 1		// Traz uma via por Default
Endif
					                                
If nVias > 0
   If SLG->(FieldPos("LG_CRDIMP")) > 0
      cImpressora := LJGetStation("CRDIMP")
   Else
      cImpressora := "2" 	// Traz a impressora fiscal por Default
   Endif						
   If cImpressora == "2" 	// Fiscal				    		
   	  If Len(aDadosCrd[8]) > 0 .AND. Len(aDadosCrd[8][1]) >= 3	 .AND. !lTefUsado
      	 nRetECF := IFAbrCNFis( nHdlECF  ,Tabela("24",Alltrim(aDadosCrd[8][1][3]),.F.)  ,Str(aDadosCrd[8][1][2],14,2)  ,"01" )

		  If nRetECF == 0
		     nRetECF := IFTxtNFis( nHdlECF  ,cTicket  ,nVias )
			 If nRetECF == 0
		    	IFFchCNFis( nHdlECF )
			 Endif
		  Else
		 	lDadosCrd     := .T. 
		 EndIf 	
	  Else
	  	lDadosCrd     := .T.
	  EndIf       
	  
	  If lDadosCrd		  
	     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³Se não conseguir imprimir um cupom nao fiscal, manda um     ³
		 //³Relatorio Gerencial para o ECF  (Alguns ECF, por exemplo a  ³
		 //³Sweda, não permite que seja vinculado um cupom nao fiscal   ³
		 //³a um outro cupom nao fiscal)                                ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         nRetECF := IFRelGer( nHdlECF  ,cTicket  ,nVias )
		 If nRetECF <> 0
		    // "Não foi possível imprimir o comprovante de financiamento. Verifique o ECF e solicite a re-impressão."
			MsgStop(STR0049)
		 Endif
      Endif							
   ElseIf cImpressora == "3"	// Impressao via Word 					    		              
      CrdxImpDoc( cMvCrdDoc1  ,nVias  ,{{"CRD_TICKET",StrTran(cTicket,Chr(10),Chr(13))}} )			    			
   Endif
Endif					

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdInfClieºAutor  ³Vendas Clientes     º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Busca o CNPJ/CPF e numero do cartao do cliente              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdInfClie(ExpC1, ExpC2)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do cliente                                   º±±
±±º          ³ExpC2 - Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array contendo                                              º±±
±±º          ³ 1 - CNPJ/CPF                                               º±±
±±º          ³ 2 - Numero do cartao ativo                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdInfClie( cCodClie, cLoja )
Local lConnect		:= .F.                  // Controla se houuve conexao via WS
Local lWSStatus	    := .T.                  // Controla se o WS deve ser chamado novamente
Local nI                                    // Controle do numero de tentativas de login via WS
Local aRet          := {"",""}             // Retorno da funcao com CNPJ/CPF e/ou numero do cartao
Local cSoapFCode                            // Codigo de erro do WS
Local cSoapFDescr                           // Descricao de erro do WS
Local oSvcStatus                            // Objeto do status

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvcStatus := WSCRDSTATUS():New()
oSvcStatus:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
	
nI := 1	
While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
   LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."		  	      
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   CrdUpdUser( cUsrSessionID ) 
   nI++		  
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³1 segundo para nova checagem de login ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Sleep(1000)
End	
	   
While lWSStatus
   //"Espere... Consultando dados do cliente ..."    	    
   LJMsgRun( STR0085,, {|| lConnect   := oSvcStatus:GETINFCLI( cUsrSessionID, cCodClie, cLoja ) } ) 
   If !lConnect
      cSvcError := GetWSCError()
	  If Left(cSvcError,9) == "WSCERR044"		// "Nao foi possivel post em http:// ..."
	     MsgStop( STR0043 )                     // "Não foi possível estabelecer conexão com o servidor."
		 lWSStatus 	:= .F.                      // Nao chama o metodo GetVenda novamente				
	  ElseIf Left(cSvcError,9) == "WSCERR048"				
	     cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		 cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))				
		 // Se necessario efetua outro login antes de chamar o metodo GetVenda novamente
		 If cSoapFCode $ "-1,-2,-3"
		    LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
			CrdUpdUser( cUsrSessionID ) //Atualizacao da ID para o CRDXFUN (evitar reprocessamento)
			lWSStatus := .T.
		 Else					
		    MsgStop(cSoapFDescr, "Error " + cSoapFCode)
			lWSStatus := .F.
		 Endif				
      Else				
		 MsgStop(STR0078,STR0079)    //"Sem comunicação com o WebService!"###"Atenção."
		 lWSStatus := .F.            // Nao chama o metodo GetVenda novamente				
	  Endif
   Else			
      aRet        := {oSvcStatus:oWSGETINFCLIRESULT:cCNPJCPF,oSvcStatus:oWSGETINFCLIRESULT:cNumCart}
	  lWSStatus   := .F.	             // Nao chama o metodo GetVenda novamente
   Endif
End

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDxCancelºAutor  ³Vendas Clientes     º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desfaz a operacao de credito caso ocorra algum erro na tran-º±±
±±º          ³sacao                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ CRDxCancel(ExpC1, ExpC2) 								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Codigo do cliente                                   º±±
±±º          ³ ExpC2: Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico. Retorna se cancelamento efetuado com sucesso       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDxCancel( cCodClie, cLoja )
Local cContrato   := ""              // Numero do contrato a ser cancelado
Local aRetCrd     := {}              // Indica se cancelamento foi realizado com sucesso
Local aDadosCrd   := {"",""}         // Dados do cliente [1]-numero do cartao [2]-CNPJ/CPF para integracao com CrdxVenda
Local aCrdCliente := {"",""}         // Dados do cliente [1]-CNPJ/CPF [2]-numero do cartao 
Local lRet        := .T.             // Indica se cancelamento foi realizado com sucesso
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desfaz a transacao de credito  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If CrdxInt(.F.,.F.) 		
   aCrdCliente   := AClone(CrdInfClie(cCodClie, cLoja))
   If !Empty(aCrdCliente[1]) .OR. !Empty(aCrdCliente[2])
      DbSelectArea("MA7")
      DbSetOrder(1)
      If DbSeek(xFilial("MA7")+cCodClie+cLoja) .AND. !Empty(MA7->MA7_CONTRA)
         cContrato    := MA7->MA7_CONTRA		   
         aDadosCrd[1] := aCrdCliente[2]  //Numero do cartao
         aDadosCrd[2] := aCrdCliente[1]  //CNPJ/CPF        
	     aRetCrd      := aClone(CrdxVenda( "3"  ,aDadosCrd  ,cContrato  ,NIL   ,;
	                                        NIL  ,NIL ))	    
	     If Len(aRetCrd) >= 1
	        lRet  := aRetCrd[1] == 0  //Transacao OK
	     Endif
	  Endif   
   Endif   
Endif   

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdIdentClºAutor  ³Vendas Clientes     º Data ³  14/06/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Identificacao do cliente atraves do numero do cartao ou CNPJ º±±
±±º          ³CPF                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdIdentCli(ExpA1, ExpA2, ExpL3, ExpL4, ExpA5, ExpC6)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array contendo                                       º±±
±±º          ³		1 - tipo de documento ( 1= cartao magnetico;		   º±±
±±º          ³								2= cartao nao-magnetico;       º±±
±±º          ³								3= CNPJ/CPF;				   º±±
±±º          ³								4= Abandona)                   º±±
±±º          ³		2 - numero do documento apresentado                    º±±
±±º          ³ExpA2 - Array contendo                                       º±±
±±º          ³		1 - numero do cartao                                   º±±
±±º          ³		2 - CNPJ/CPF 										   º±±
±±º          ³		3 - codigo do cliente     							   º±±
±±º          ³		4 - loja do cliente     						       º±±
±±º          ³ExpL3 - Indica se o cliente nao foi encontrado na base       º±±
±±º          ³		.F. - cliente encontrado na base                       º±±
±±º          ³		.T. - cliente nao encontrado na base                   º±±
±±º          ³ExpL4 - Indica se chamado do Front Loja, tratamento especi-  º±±
±±º          ³co para base local                                           º±±
±±º          ³ExpA5 - Array contendo o nome dos campos e seu conteudo do   º±±
±±º          ³cliente selecionado                                          º±±
±±º          ³ExpA6 - Informacoes de variaveis do tipo static (templates)  º±±
±±º          ³ExpL7 - Indica se conseguiu conectar no WS.                  º±±
±±º          ³ExpC8 - Codigo do DEPENDENTE                                 º±±
±±º          ³ExpC9 - Nome do DEPENDENTE                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico. Retorna se prossegue operacao 					   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de venda                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdIdentCli( aRetCart,	aDadosCli  	, lCliente, lFront,;
                      aCliente,	aVarTemplate, lConnect, cCodDEP ,;
                      cNomeDEP )			                      			

Local lRet          := .T.                      // Retorno da funcao - .F.=opcao Abandona ou retorno incorreto do WS 
Local aRetInfClie   := {}                       // Contem CNPJ/CPF e numero do cartao ativo do cliente
Local nPosCli		:= 0	                    // Posicao do campo A1_COD no array aCliente
Local nPosLoja		:= 0	                    // Posicao do campo A1_LOJA no array aCliente
Local cNomeClie     := ""                       // Nome do cliente selecionado
Local cCRLF    	    := Chr(13) + Chr(10)        // Pula linha 
Local cCpfDefault	:= ""						// Retorno esperado do P.E. CRD???? para alimentar o CPF com um valor Default
Local cMatricula 	:= "" 						// Codigo da matricula quando houver template drogaria
Local cCliente		:= ""						// Codigo do cliente 
Local cLojaCli		:= ""						// Codigo da loja 
Local lOnLine       := .T.

DEFAULT aCliente    := {}

DEFAULT cCodDEP 	:= ""						// Codigo do DEPENDENTE	
DEFAULT cNomeDEP    := ""                   	// Nome do DEPENDENTE
DEFAULT aVarTemplate:= {"","",""}				// Array que contera valores de Variaveis do tipo 'STATIC'			
DEFAULT lConnect	:= .T.                     	// Identifica se conseguiu conectar no WS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aVarTemplate  - Template Drogaria                 ³
//³---------------------------------------------------------------------³
//³-    aVarTemplate[1]  =  codigo do cliente                           ³
//³-    aVarTemplate[2]  =  loja                                        ³
//³-    aVarTemplate[3]  =  numero do cartao                            ³
//³---------------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o P.E. para carregar o valor Default do CPF/CNPJ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "CRD004" ) 
	cCpfDefault := ExecBlock( "CRD004", .F., .F. )
Endif

If ( IsInCallStack("TMKA271") .OR. IsInCallStack("CRDXVENDA") ) .AND. Empty(cCpfDefault)
	cCpfDefault := SA1->A1_CGC
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aRetCart[1] ->Retorna o tipo do cartao                     ³
//³         1 - Magnetico                                     ³
//³         2 - Não Magnético                                 ³
//³         3 - CNPJ/CPF                                      ³
//³         4 - Abandona                                      ³
//³         4 - Matricula. Para quando houver template de     ³
//³             drogaria.                                     ³
//³                                                           ³
//³aRetCart[2] -> Retorna o numero do cartao ou do CPF        ³
//³         1,2 -> Numero do cartão                           ³
//³         3 -> numero do CNPJ/CPF                           ³
//³         5 -> codigo da matricula para quando houver       ³
//³              template de drogaria                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetCart := aClone( L010TCart( Nil, cCpfDefault, @aVarTemplate ) )
If ( aRetCart[1] == 4 ) .OR. ( Empty( aRetCart[2] ) )
	lRet			:= .F.
ElseIf aRetCart[1] == 1 .OR. aRetCart[1] == 2
	aDadosCli[2]	:= ""             //CPF
	aDadosCli[1]	:= aRetCart[2]    //Numero do cartao
ElseIf aRetCart[1] == 3
	aDadosCli[2]	:= aRetCart[2]     //CPF
	aDadosCli[1]	:= ""              //Numero do cartao
ElseIf (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .AND. aRetCart[1] == 5
	cMatricula		:= aRetCart[2]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O retorno se o cliente foi encontrado eh feito atraves da  ³
//³variavel lCliente. Se .T., cliente nao encontrado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa o cliente na retaguarda para verificar se existe mais de 1 ³
	//³ cliente com o mesmo CPF ou se houve alteracao no cliente            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegsSA1 := CRDCliR2Pdv( aDadosCli[1], aDadosCli[2], cMatricula, @lConnect,;
							 NIL		  , @cCodDEP	, @cNomeDep)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se foi encontrado mais de um cliente.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aRegsSA1 ) >= 2
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra uma tela para o usuario escolher qual o cliente ele quer pesquisar.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetCli		:= CRDxTelaCl( aRegsSA1 )
		If ValType( aRetCli ) == "A" .AND. Len( aRetCli ) >= 2
			cCliente 	:= aRetCli[1]
			cLojaCli 	:= aRetCli[2] 
			lRet		:= .T.
		Else
			lRet		:= .F.
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa qual o cliente foi selecionado no array aRegsSA1 para montar o array ³
		//³ aCliente so' com 1 registro                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosCli 	:= aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )
		nPosLoja	:= aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
		nX 			:= 1     

		While nX <= Len( aRegsSA1 )
			If aRegsSA1[nX][nPosCli][2] + aRegsSA1[nX][nPosLoja][2] == cCliente + cLojaCli
				aCliente 	:= aClone( aRegsSA1[nX] )
			Endif
			nX++
		End
		
	ElseIf Len( aRegsSA1 ) == 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se houver apenas 1 registro verifica se a array  esta' com conteudo e define as   ³
		//³ variaveis cCliente e cLojaCli.                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )
		If nPosTmp > 0
			cCliente := aRegsSA1[1][nPosTmp][2]
		Endif
		nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
		If nPosTmp > 0
			cLojaCli := aRegsSA1[1][nPosTmp][2]
		Endif
		If !Empty( cCliente + cLojaCli )
			aCliente := aClone( aRegsSA1[1] )
		Endif
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alteracao somente para o Template Drogaria.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a função sem passar pelo WebService por estar consultando ³
			//³ a base local                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRet := WSCRD013( aDadosCli[1], aDadosCli[2], "", cMatricula )
			aRet := aClone( aRet[4] )
			
			If Len( aRet ) >= 2                       
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Mostra uma tela para o usuario escolher qual o cliente ele quer pesquisar.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetCli		:= CRDxTelaCl( aRet )
				If ValType( aRetCli ) == "A" .AND. Len( aRetCli ) >= 2
					cCliente 	:= aRetCli[1]                          
					cLojaCli 	:= aRetCli[2] 
					lRet		:= .T.
				Else
					lRet		:= .F.
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pesquisa qual o cliente foi selecionado no array aRegsSA1 para montar o array ³
				//³ aCliente so' com 1 registro                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCli 	:= aScan( aRet[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )
				nPosLoja	:= aScan( aRet[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
				nX 			:= 1     
		
				While nX <= Len( aRet )
					If aRet[nX][nPosCli][2] + aRet[nX][nPosLoja][2] == cCliente + cLojaCli
						aCliente 	:= aClone( aRet[nX] )
					Endif
					nX++
				End			
			Elseif Len( aRet ) == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se houver apenas 1 registro verifica se a array  esta' com conteudo e define as   ³
				//³ variaveis cCliente e cLojaCli.                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosTmp := aScan( aRet[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )
				If nPosTmp > 0
					cCliente := aRet[1][nPosTmp][2]
				Endif
				nPosTmp := aScan( aRet[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
				If nPosTmp > 0
					cLojaCli := aRet[1][nPosTmp][2]                            
				Endif
				If !Empty( cCliente + cLojaCli )
					aCliente := aClone( aRet[1] )
				Endif  
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao encontrou o cliente nao continua o processamento         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCliente := ""
				cLojaCli := ""
				lRet := .F.
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrou o cliente nao continua o processamento         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCliente := ""
			cLojaCli := ""
			lRet := .F.
		Endif		
	Endif                    
	If lRet 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Com a busca do cliente na base da retaguarda, sempre que chegar aqui   ³
		//³ a rotina ja' esta' com o codigo do cliente e loja posicionado no array ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosCli 	:= aScan( aCliente, { |x| Alltrim( Upper( x[1] ) ) == "A1_COD" } )
		nPosLoja 	:= aScan( aCliente, { |x| Alltrim( Upper( x[1] ) ) == "A1_LOJA" } )

		DbSelectArea( "SA1" )
		DbSetOrder( 1 )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao permite utilizar um cliente diferente do cliente especificado³
		//³no cabecalho para o Televendas                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	IsInCallStack("TMKA271") .AND.;
			(M->UA_CLIENTE <> aCliente[nPosCli][2] .OR. M->UA_LOJA <> aCliente[nPosLoja][2])

			SA1->( DbSeek( xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA ) )
			MsgStop(STR0125) //"O cliente selecionado na consulta difere do cliente utilizado no cabecalho."
			lRet := .F.

		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o array com o codigo e loja do cliente para todas as rotinas de venda. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lRet .AND. SA1->( DbSeek( xFilial( "SA1" ) + aCliente[nPosCli][2] + aCliente[nPosLoja][2] ) )
			lCliente := .F.
			aDadosCli[3]	:= SA1->A1_COD
			aDadosCli[4]	:= SA1->A1_LOJA
			cNomeClie		:= IIf( Empty( SA1->A1_NREDUZ ), SA1->A1_NOME, SA1->A1_NREDUZ )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Usado a 5a Dimensao somente para o FrontLoja      ³
			//³(Template Drogaria - Rotina de Consulta de Precos)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aDadosCli) >= 5
				aDadosCli[5] := cNomeClie
			Endif	
		Endif

	Endif    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cartao digitado e' de um DEPEDENTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodDEP) .AND. !Empty(cNomeDep)
		cNomeClie :=  cNomeDep
	Endif   
	
	If lRet .AND. SA1->A1_MSBLQL == "1"
		Help(" ",1,"REGBLOQ")
		lRet := .F.
	EndIf
	
	If lRet .AND. !MsgYesNo( STR0086 + cCRLF + Trim( cNomeClie ) + "?" ) //"Confirma a selecao do cliente: "
		lRet  := .F.
	Endif

Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdStContrºAutor  ³Vendas Clientes     º Data ³  15/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Pesquisa o status do contrato                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpC1 := CrdStContr( ExpC2, ExpC3, ExpC4)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC2 = Numero do contrato                                  º±±
±±º          ³ExpC3 = Codigo do cliente                                   º±±
±±º          ³ExpC4 = Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1 = Status do contrato:                                 º±±
±±º          ³1 - OK                                                      º±± 
±±º          ³2 - Pendente        										  º±±
±±º          ³3 - Liberado 												  º±±
±±º          ³4 - Rejeitado                                               º±±
±±º          ³5 - Fila do crediario                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdStContr( cContrato, cCliente, cLoja )
Local lConnect		:= .F.
Local lWSStatus	    := .T.
Local nI                                    //Controle do numero de tentativas de login via WS
Local cStatus       := "" 
Local cSoapFCode
Local cSoapFDescr
Local oSvcStatus

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvcStatus := WSCRDSTATUS():New()
oSvcStatus:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
	
nI := 1	
While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
   LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."		  	      
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   CrdUpdUser( cUsrSessionID ) 
   nI++		  
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³1 segundo para nova checagem de login ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Sleep(1000)
End	
	   
While lWSStatus
   //"Aguarde... Consultando Status do Contrato ..."		
   LJMsgRun( STR0081,, {|| lConnect   := oSvcStatus:GETSTCONTR( cUsrSessionID, cContrato, cCliente, cLoja ) } ) 
   If !lConnect
      cSvcError := GetWSCError()
	  If Left(cSvcError,9) == "WSCERR044"		// "Nao foi possivel post em http:// ..."
	     MsgStop( STR0043 )                     // "Não foi possível estabelecer conexão com o servidor."
		 lWSStatus 	:= .F.                      // Nao chama o metodo GetVenda novamente				
	  ElseIf Left(cSvcError,9) == "WSCERR048"				
	     cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		 cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))				
		 // Se necessario efetua outro login antes de chamar o metodo GetVenda novamente
		 If cSoapFCode $ "-1,-2,-3"
		    LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
			CrdUpdUser( cUsrSessionID ) //Atualizacao da ID para o CRDXFUN (evitar reprocessamento)
			lWSStatus := .T.
		 Else					
		    MsgStop(cSoapFDescr, "Error " + cSoapFCode)
			lWSStatus := .F.
		 Endif				
      Else				
		 MsgStop(STR0078,STR0079)    //"Sem comunicação com o WebService!"###"Atenção."
		 lWSStatus := .F.            // Nao chama o metodo GetVenda novamente				
	  Endif
   Else			
      cStatus     := oSvcStatus:cGETSTCONTRRESULT
	  lWSStatus   := .F.	             // Nao chama o metodo GetVenda novamente
   Endif
End

Return (cStatus)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdAtuFinaºAutor  ³Vendas Clientes     º Data ³  18/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Atualiza o campo E1_NUMCRD e exclui os registros de parcelasº±±
±±º          ³de financiamento(MAL)                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdAtuFinan(ExpC1, ExpA2)                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Numero do contrato								  º±±
±±º          ³ExpA2 - Array contendo                                      º±±
±±º          ³[1] - Prefixo 				                              º±±
±±º          ³[2] - Numero  				                              º±±
±±º          ³[3] - Parcela         		                              º±±
±±º          ³[4] - Tipo             		                              º±±
±±º          ³[5] - Cod. Adm. Financeira+" - "+Nome da Adm.	              º±±
±±º          ³[6] - Vencimento   			                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Se gravacao realizada com sucesso				              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdAtuFinan(cNumContra   ,aDadosFin, _lScreen)
Local aArea         := GetArea()            // Area atual
Local aParcCrd      := {}                   // Parcelas do financiamento
Local nX            := 1                    // Variavel de controle do loop
Local lRet          := .T.                  // Controla o prosseguimento da operacao

DEFAULT _lScreen  := .T.

If CrdxInt(.F.,.F.)
	If Len(aDadosFin) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se as parcelas foram enviadas no formato correto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aDadosFin)
			If Len(aDadosFin[nX]) <> 6
				lRet  := .F.
				Exit
			Endif
		Next nX
		If lRet
			aParcCrd  := AClone(CrdAvalParc(aDadosFin))
			nX        := 1			
			If Len(aParcCrd) > 0
                If Empty(cNumContra) .OR. SE1->(FieldPos("E1_NUMCRD")) == 0			
                   lRet  := .F.
                Else
				   DbSelectArea("SE1")
				   DbSetOrder(1)
				   DbSeek(xFilial("SE1")+aParcCrd[nX][1]+aParcCrd[nX][2]+aParcCrd[nX][3]+aParcCrd[nX][4])
				   While !Eof() .AND. nX <= Len(aParcCrd) .AND. xFilial("SE1")+aParcCrd[nX][1]+aParcCrd[nX][2] == ;
				   		 SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM
					
					  If (aParcCrd[nX][4] <> SE1->E1_TIPO)
						 DbSkip()
						 Loop
					  Endif
					
					  RecLock("SE1",.F.)
					  REPLACE E1_NUMCRD   WITH   cNumContra
					  MsUnlock()
					
					  DbSkip()
					  nX++
				   End
				   DbSelectArea("MAL")
				   DbSetOrder(1)
				   DbSeek( xFilial("MAL")+cNumContra )
				   While !Eof() .AND. MAL->MAL_FILIAL+MAL->MAL_CONTRA == xFilial("MAL")+cNumContra
					  Reclock("MAL",.F.)
					  dbDelete()
					  MsUnlock()
					  DbSkip()
				   End
				Endif
			Endif
		Endif
	Endif	

    If !lRet
       If _lScreen 
	      //"Nao foi possivel atualizar os registros financeiros de integracao com SIGACRD."    	
	      //"Verifique se o contrato foi informado ou se existe o campo 'E1_NUMCRD' no dicionario de dados."	
	      MsgStop(STR0082+CHR(13)+CHR(10)+STR0083)  
       Else 
          ConOut(STR0082+CHR(13)+CHR(10)+STR0083)
       Endif   
    Endif	
Endif

RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdAvalParºAutor  ³Vendas Clientes     º Data ³  18/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Avalia as parcelas que devem ter analise de credito         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdAval(ExpA1)                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array contendo 								      º±±
±±º          ³[1] - Prefixo 				                              º±±
±±º          ³[2] - Numero  				                              º±±
±±º          ³[3] - Parcela         		                              º±±
±±º          ³[4] - Tipo             		                              º±±
±±º          ³[5] - Cod. Adm. Financeira+" - "+Nome da Adm.	              º±±
±±º          ³[6] - Vencimento   			                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Parcelas da analise de credito, mesma estrutura descrita    º±±
±±º          ³acima  													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdAvalParc( aDadosFin )
Local nPosAdm       :=  0                                  	// Posicao da Administradora financeira
Local nTamCodSAE    := TamSx3("AE_COD")[1]               	// Tamanho do campo AE_COD
Local nX                                                   	// Variavel de controle do loop 
Local nMv_LjChVst   := SuperGetMV("MV_LJCHVST",,-1)	      	// Quantos dias considera um cheque a vista. Se for -1 nao trata o parametro
Local aCrdAdm       := {}                                 	// Relacao das Administradoras financeiras
Local aParcCrd      := {}                                 	// Parcelas de financiamento
Local cMV_FORMCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI")	// Formas de pagamento que devem ter analise de credito
Local nTamE1_NUM	:= TamSX3("E1_NUM")[1]				  	// Tamanho do campo E1_NUM

DbSelectArea("SAE")
DbSetOrder(1)
For nX := 1 To Len(aDadosFin)
   If AllTrim(aDadosFin[nX][4]) $ cMV_FORMCRD
	  If Empty(aDadosFin[nX][5])
	     Loop
      Endif   
      If aScan( aCrdAdm, {|x| x[1] == Substr(aDadosFin[nX][5],1,nTamCodSAE) } ) == 0
	     If DbSeek(xFilial("SAE")+Substr(aDadosFin[nX][5],1,nTamCodSAE))
	        If SAE->(FieldPos("AE_PLABEL")) > 0
               If SAE->AE_PLABEL == "1"
			      AADD( aCrdAdm, { Substr(aDadosFin[nX][5],1,nTamCodSAE),;    //Codigo da Administradora    
			                       Substr(aDadosFin[nX][5], AT("-",aDadosFin[nX][5])+2,Len(aDadosFin[nX][5])) } )   //Descricao da administradora
			   Endif
		    Endif
	     Endif
      Endif

      nPosAdm := aScan( aCrdAdm, {|x| Substr(x[1],1,nTamCodSAE) == Substr(aDadosFin[nX][5],1,nTamCodSAE) } )
      If nPosAdm > 0 .OR. (Alltrim(Upper(MVCHEQUE))$cMV_FORMCRD .AND. ;
         ((Alltrim(Upper(aDadosFin[nX][4])) == Alltrim(Upper(MVCHEQUE)) .AND. ( nMv_LjChVst==-1 .OR. aDadosFin[nX][6] >= dDataBase+nMv_LjChVst))))
		      
         AADD( aParcCrd, { aDadosFin[nX][1],;		     			// Prefixo
			               PadR(aDadosFin[nX][2],nTamE1_NUM),;		// Numero			            
			               aDadosFin[nX][3],;		     			// Parcela
			               aDadosFin[nX][4],;           			// Tipo
			               aDadosFin[nX][5],;		     			// Cod. e nome da Adm. Financeira      			            
			               aDadosFin[nX][6] } )	         			// Vencimento
      Endif      
   Endif
Next nX

Return (aParcCrd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdGeraConºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera novo contrato quando venda forcada 					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdGeraContr(ExpN1, ExpC2, ExpC3)                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Valor total financiado 						      º±±
±±º          ³ExpC2 - Numero do PDV(SigaLoja)							  º±±
±±º          ³ExpC3 - Codigo do Caixa(SigaLoja)							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Numero do contrato gerado 					  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista      ³Manutencao Efetuada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º03/07/05  ³Andrea Farias ³BOPS 84524 - Substituicao do nome do Ponto   º±±
±±º          ³              ³de entrada MAHCONTR para CRDCONTR para padro-º±±
±±º          ³              ³nizacao.                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdGeraContr( nTotFinanc, cNumPDV, cCodCaixa )
Local aArea      := GetArea()                       // Area atual
Local cNumContra := Space(TamSX3("MAH_CONTRA")[1]) // Numero do novo contrato
Local nSaveSx8 	 := GetSx8Len()					    // Variavel para controle do semaforo

DEFAULT cNumPDV   := ""
DEFAULT cCodCaixa := ""

DbSelectArea("MAH")
If ExistBlock("CRDCONTR")
   cNumContra := ExecBlock("CRDCONTR",.F.,.F.)
Else
   cNumContra := GetSxeNum( "MAH", "MAH_CONTRA" )   
Endif                        

RecLock("MAH", .T.)					
REPLACE	MAH->MAH_FILIAL	WITH xFilial("MAH")
REPLACE	MAH->MAH_CONTRA	WITH cNumContra
REPLACE	MAH->MAH_CODCLI	WITH SA1->A1_COD
REPLACE	MAH->MAH_LOJA	WITH SA1->A1_LOJA
REPLACE	MAH->MAH_EMISSA	WITH dDatabase
REPLACE	MAH->MAH_DTTRN	WITH dDatabase
REPLACE	MAH->MAH_HRTRN	WITH Time()
REPLACE	MAH->MAH_USRTRN	WITH cUserName
REPLACE	MAH->MAH_LJTRN	WITH SM0->M0_CODIGO + "-" + FWGETCODFILIAL + "-" + Alltrim(SM0->M0_NOME)
REPLACE	MAH->MAH_PDVTRN	WITH cNumPDV
REPLACE	MAH->MAH_CXTRN	WITH cCodCaixa
REPLACE	MAH->MAH_TRANS	WITH Str(TRANS_OK,1)
REPLACE	MAH->MAH_STATUS	WITH Str(ST_OK,1)
REPLACE	MAH->MAH_VLRFIN	WITH nTotFinanc			
MsUnLock()

If __lSX8
   While (GetSX8Len() > nSaveSx8)
      ConfirmSX8()
   End
Endif	     	

RestArea(aArea)

Return (cNumContra)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdAtuPendºAutor  ³Vendas Clientes     º Data ³  20/06/05       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela contrato pendente que nao gerou orcamento nem venda     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdAtuPend(ExpC1, ExpN2, ExpA3)           				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - alias do arquivo de busca para verificar se o contra    º±±
±±º          ³to esta relacionado a algum documento. Ex: orcamento(SL1)       º±±
±±º          ³ExpN2 - indice utilizado na busca no arquivo 				      º±±
±±º          ³ExpA3 - contratos a serem verificados para cancelamento         º±±
±±º          ³Array contendo: 											      º±±
±±º          ³[1] - numero do contrato 									      º±±
±±º          ³[2] - codigo do cliente  									      º±±
±±º          ³[3] - loja do cliente  							    		  º±±
±±º          ³ExpL4 - indica se foi chamado da gravacao do documento(orca-    º±±
±±º          ³mento, pedido, NF)										      º±±
±±º          ³ExpL5 - define se pergunta se o contrato deve ou nao ser        º±±
±±º          ³cancelado													      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdAtuPend( cSeekAlias, nIndAlias, aNumContra, lGravaDoc,;
                     lPergunta )

Local aRetCrd     	:= {}                 	// Retorno da funcao de cancelamento de contrato
Local aArea       	:= GetArea()          	// Area atual
Local aAreaSL1      := SL1->(GetArea())   	// Area atual do SL1
Local nX                                  	// Controle do loop
Local lInicMA7    	:= .F.             		// Define se inicializa o registro do cliente no MA7
Local lRet			:= .T.					// Retorno da funcao

DEFAULT lGravaDoc 	:= .F.                    
DEFAULT lPergunta 	:= .F.

For nX  := 1 to Len(aNumContra)
	DbSelectArea("MAH")
 	DbSetOrder(1) 

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o contrato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If dbSeek(xFilial("MAH")+aNumContra[nX,1])    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se MAH_TRANS = OK OU CANCELADO OU MAH_STATUS = CREDIARIO Verifica outro contrato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If Val(MAH->MAH_TRANS) == TRANS_OK .OR. Val(MAH->MAH_TRANS) == TRANS_CANC .OR. Val(MAH->MAH_STATUS) == ST_CRED 
 			Loop
      	Endif
   	Endif   
	
	If !Empty(aNumContra[nX,1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O contrato nao deve ser cancelado na gravacao do documento(lGravaDoc) ³
 		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
		If !lGravaDoc 
			DbSelectArea(cSeekAlias)
	   		DbSetOrder(nIndAlias) 
	   		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o orcamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If !dbSeek(xFilial(cSeekAlias)+aNumContra[nX,1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³POSICIONAR NO MA7 E SE BLOQUE = REJEITADO OU BLOQUEADO												³
				//³Apaga o Contrato                                      												³
				//³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o cliente  ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 			DbSelectArea("MA7")                                       
	 			DbSetOrder(1)			
				If dbSeek(xFilial("MA7")+aNumContra[nX,2]+aNumContra[nX,3])
		   		
		   	    	Conout("82.CRDXFUN - CrdAtuPend - Procura MA7 " +;
							" Contrato: " + If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
							" Encontrou MA7 " )    
		   		
		   	 		If MA7->MA7_BLOQUE == Str(BLOQUEADO,1) .OR. MA7->MA7_BLOQUE == STR(REJEITADO,1) .OR. ; 	   		  	   
		   	 		   MA7->MA7_BLOQUE == Str(BLOQCONS,1)
			   			
			   	    		Conout("83.CRDXFUN - CrdAtuPend - Procura MA7 " +;
					    	" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
					     	" Deleta o contrato ")    
			   		 	          
			   	    	

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Deleta o Contrato para forcar nova avaliacao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   			aRetCrd     := aClone(CrdxVenda(	"3",	{"",""},	aNumContra[nX,1],	.F., ;
		                                        		 	NIL,	NIL))	                	           	
			   			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Inicializa o MA7³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   			lInicMA7    := .T.
			  
		         	ElseIf lPergunta
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Confirma o cancelamento do contrato de financiamento                                                ³
						//³O contrato deve ser cancelado se o cliente não for pagar sua compra de forma financiada (crediário).³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		            	If MsgYesNo(STR0106+aNumContra[nX,1]+"?"+CTRL+STR0107)
		         
		         	   		Conout("68.CRDXFUN - CrdAtuPend - Cancela o contrato " +;
					      			" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
						  			" Validacao: Usuario confirmou o cancelamento do contrato (MsgYesNo) +  -> CrdxVenda('3',....)")    
						
		               		aRetCrd     := aClone(CrdxVenda(	"3",	{"",""},	aNumContra[nX,1],	.F.,;
		                                             			NIL,	NIL))	                
		               		lInicMA7    := .T.                                 
		            	Endif
		         	Else
		      	   		Conout("69.CRDXFUN - CrdAtuPend - Cancela o contrato " +;
					   		" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
							" Validacao: l CrdxVenda('3',....)   ")    
		      
		      			aRetCrd     := aClone(CrdxVenda("3"   ,{"",""}   ,aNumContra[nX,1]  ,.F.    ,;
		                                          NIL  ,NIL))	                	                                             
		            	lInicMA7    := .T.                                 	                                          
		        	Endif
		        Else                                                   
		        	Conout("69.CRDXFUN - CrdAtuPend - Cancela o contrato " +;
		   			" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
					" Nao Encontrou MA7   ")    
				Endif                                                                                               
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³POSICIONAR NO MA7 E SE BLOQUE = REJEITADO OU BLOQUEADO												³
				//³Apaga o Contrato                                      												³
				//³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o cliente  ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				DbSelectArea("MA7")                                       
				DbSetOrder(1)
				If dbSeek(xFilial("MA7")+aNumContra[nX,2]+aNumContra[nX,3])
		   		
					Conout("84.CRDXFUN - CrdAtuPend - Procura MA7 " +;
							" Contrato: " + If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
							" Encontrou MA7 " )    
		   		
					If MA7->MA7_BLOQUE == STR(BLOQUEADO,1) .OR. MA7->MA7_BLOQUE == STR(REJEITADO,1) .OR. ; 	   		  	   
		   	 		   MA7->MA7_BLOQUE == Str(BLOQCONS,1) 	   		  	   
			   			
			   	    	Conout("85.CRDXFUN - CrdAtuPend - Procura MA7 " +;
					    		" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
					       		" Deleta o contrato ")    
			   		 	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Deleta o Contrato para forcar nova avaliacao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   			aRetCrd     := aClone(CrdxVenda(	"3",	{"",""},	aNumContra[nX,1],	.F., ;
		                                        		 	NIL,	NIL))	                	           	
	          		Endif	
				Endif    			
				lInicMA7  := .T.			
	   		Endif	                                                                                                          	   		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa o arquivo MA7 apos cancelamento do contrato ou confirmacao da transacao de credito 		³
			//³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o cliente  ³						
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                			
			If lInicMA7
			   	DbSelectArea("MA7")                                       
				DbSetOrder(1)
				If dbSeek(xFilial("MA7")+aNumContra[nX,2]+aNumContra[nX,3])
					CrdInicMA7()      
				Endif   
			Endif       	   		
		Else                    
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³POSICIONAR NO MA7 E SE BLOQUE = REJEITADO OU BLOQUEADO												³
		    //³Apaga o Contrato                                      												³
		    //³Nao aplicar Implementacao Continua para DbSeek porque em algumas situacoes nao encontrava o cliente  ³				
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			DbSelectArea("MA7")                                       
			DbSetOrder(1)
			If dbSeek(xFilial("MA7")+aNumContra[nX,2]+aNumContra[nX,3])
		   		
				Conout("86.CRDXFUN - CrdAtuPend - Procura MA7 " +;
						" Contrato: " + If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
						" Encontrou MA7 " )    
		   		
				If MA7->MA7_BLOQUE == STR(BLOQUEADO,1) .OR. MA7->MA7_BLOQUE == STR(REJEITADO,1) .OR. ; 	   		  	   
		   	 	   MA7->MA7_BLOQUE == Str(BLOQCONS,1) 	   		  	   
			   			
			    	Conout("87.CRDXFUN - CrdAtuPend - Procura MA7 " +;
				    		" Contrato: " +	If( Empty(aNumContra[nX,1]), "", aNumContra[nX,1]) +;
				       		" Deleta o contrato ")    
			   		 	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Deleta o Contrato para forcar nova avaliacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRetCrd     := aClone(CrdxVenda(	"3",	{"",""},	aNumContra[nX,1],	.F., ;
		                                        		 NIL,	NIL))	                	           	
		            CrdInicMA7()
	        	Endif	
			Endif    		
		Endif
	Endif
Next nX

SL1->(RestArea(aAreaSL1))
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdInicMA7ºAutor  ³Vendas Clientes     º Data ³  23/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa o cadastro de credito do cliente(MA7)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdIniciMA7()					 						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdInicMA7()                                                                                     
Local cMvCrdArq	:= SuperGetMV("MV_CRDARQ",,"\")		//Permite gravar os arquivos de parcelas e produtos em local determinado
									   				//pelo administrador do sistema.
Local lRet := .F. 									// indica se houve alteracao na tabela MA7 com sucesso

If allTrim(cMvCrdArq) == ""
	cMvCrdArq := "\"
EndIf                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o status do cliente no arquivo MA7	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File( cMvCrdArq + MA7->MA7_ARQPRO )  
   FErase( cMvCrdArq + MA7->MA7_ARQPRO )
Endif
If File( cMvCrdArq + MA7->MA7_ARQPAR )  
   FErase( cMvCrdArq + MA7->MA7_ARQPAR )
Endif   

If MA7->(RecLock("MA7",.F.))
	REPLACE	MA7->MA7_DATABL WITH Ctod(Space(TamSx3("MA7_DATABL")[1]))
	REPLACE	MA7->MA7_HORABL WITH Space(TamSx3("MA7_HORABL")[1])
	REPLACE	MA7->MA7_USRBL  WITH Space(TamSx3("MA7_USRBL")[1])
	REPLACE	MA7->MA7_MOTBL  WITH Space(TamSx3("MA7_MOTBL")[1])
	REPLACE	MA7->MA7_VLRBL  WITH 0
	REPLACE	MA7->MA7_BLOQUE WITH Space(TamSx3("MA7_BLOQUE")[1])
	REPLACE	MA7->MA7_DTHRDS WITH Space(TamSx3("MA7_DTHRDS")[1]) // campo de data e hora invertidos, utilizado na liberação de crédito
	REPLACE	MA7->MA7_LC     WITH 0
	REPLACE	MA7->MA7_ARQPRO WITH Space(TamSx3("MA7_ARQPRO")[1])
	REPLACE	MA7->MA7_ARQPAR WITH Space(TamSx3("MA7_ARQPAR")[1])
	REPLACE	MA7->MA7_CONTRA WITH Space(TamSx3("MA7_CONTRA")[1])
	If MA7->(FieldPos("MA7_NUMBLQ") > 0)
		REPLACE MA7->MA7_NUMBLQ WITH Space(TamSx3("MA7_NUMBLQ")[1])  //  	 --> Utilizado para emitir mensagem na tela do analista de credito.
	Endif
	MA7->(MsUnlock())
	
	MA7->(FkCommit())				
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdCriaStrºAutor  ³Vendas Clientes     º Data ³  25/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a array de estruturas para execucao do TCSetField      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdCriaStru(ExpC1, ExpA2)		 						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - alias do arquivo 								      º±±
±±º          ³ExpA2 - array com a estrutura dos campos 				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Array com as estruturas dos campos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDXFUN			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdCriaStru(cAliasStru, aStru)
Local aTam          := {}                                  // Array com o tamanho do campo E1_VENCTO para TCSetField

If cAliasStru == "MAL"
   aTam := TamSX3("MAL_SALDO")
   AAdd( aStru, {"SALDO","N",aTam[1],aTam[2]} )
Else
   aTam := TamSX3("E1_VENCTO")
   AAdd( aStru, {"DTVENCTO","D",aTam[1],aTam[2]} )

   aTam := TamSX3("E1_SALDO")
   AAdd( aStru, {"SALDO","N",aTam[1],aTam[2]} )
Endif

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdRestInfºAutor  ³Vendas Clientes     º Data ³  25/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Restaura o "backup" dos arquivos MA7, MAH e MAL se o usuarioº±±
±±º          ³nao confirmar a operacao de venda. Uma vez feita a analise  º±±
±±º          ³de credito, o sistema ja armazena os dados atualizados nes- º±±
±±º          ³tes arquivos antes da confirmacao da venda                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdRestInfCRD(ExpC1,ExpA2,ExpA3,ExpA4,ExpC5,ExpC6)          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Numero do contrato								  º±±
±±º          ³ExpA2 - Informacoes do MAH. Array contendo:                 º±±
±±º          ³[1] - Numero do contrato  								  º±±
±±º          ³[2] - Data de emissao     								  º±±
±±º          ³[3] - Data da transacao 									  º±±
±±º          ³[4] - Hora da transacao      								  º±±
±±º          ³[5] - PDV da transacao 									  º±±
±±º          ³[6] - Caixa da transacao      							  º±±
±±º          ³[7] - Loja da transacao 									  º±±
±±º          ³[8] - Valor financiado       								  º±±
±±º          ³ExpA3 - Informacoes do MAL. Array contendo                  º±±
±±º          ³[1] - Numero do contrato    							      º±±
±±º          ³[2] - Parcela     							              º±±
±±º          ³[3] - Vencimento do contrato    						      º±±
±±º          ³[4] - Valor da parcela 									  º±±
±±º          ³[5] - Saldo da parcela 									  º±±
±±º          ³ExpA4 - Informacoes do MA7. Array contendo                  º±±
±±º          ³[1] - Data do bloqueio    								  º±±
±±º          ³[2] - Hora do bloqueio    								  º±±
±±º          ³[3] - Usuario do bloqueio    							      º±±
±±º          ³[4] - Motivo do bloqueio    								  º±±
±±º          ³[5] - Valor do bloqueio    								  º±±
±±º          ³[6] - Status do bloqueio    								  º±±
±±º          ³[7] - Data Invertida     								      º±±
±±º          ³[8] - Valor do limite de credito							  º±±
±±º          ³[9] - Arquivo de produtos   								  º±±
±±º          ³[10] - Arquivo de parcelas   								  º±±
±±º          ³ExpC5 - Codigo do cliente                                   º±±
±±º          ³ExpC6 - Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdRestInfCRD(cNumContra  ,aInfMAH   ,aInfMAL   ,aInfMA7  ,;
                       cCodClie    ,cLoja)
Local lConnect		:= .F.                 	// Controla se houuve conexao via WS
Local lWSStatus	    := .T.                 	// Controla se o WS deve ser chamado novamente
Local nI                                   	// Controle do numero de tentativas de login via WS
Local nX                                   	// Controle de loop
Local cSoapFCode                           	// Codigo de erro do WS
Local cSoapFDescr                          	// Descricao de erro do WS
Local oSvc                                	// Objeto do status

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc := WSCRDVENDA():New()
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"  
oSvc:oWSWSINFMAH:cNumContrMAH	:= aInfMAH[1] 
oSvc:oWSWSINFMAH:dEMISSAO    	:= aInfMAH[2] 
oSvc:oWSWSINFMAH:dDTTRN 	 	:= aInfMAH[3]
oSvc:oWSWSINFMAH:cHRTRN 	 	:= aInfMAH[4]
oSvc:oWSWSINFMAH:cPDVTRN 	 	:= aInfMAH[5]
oSvc:oWSWSINFMAH:cCXTRN 	 	:= aInfMAH[6]
oSvc:oWSWSINFMAH:cLJTRN 	 	:= aInfMAH[7]
oSvc:oWSWSINFMAH:nVLRFIN 	 	:= aInfMAH[8]
oSvc:oWSWSINFMAH:oWSINFPARCMAL	:= CRDVENDA_ARRAYOFWSINFMAL():New()

For nX := 1 to Len( aInfMAL )
   aAdd( oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL , CRDVENDA_WSINFMAL():NEW() )
   oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL[nX]:cNUMCONTRMAL	:= aInfMAL[nX][1]
   oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL[nX]:cPARCEL   	:= aInfMAL[nX][2]
   oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL[nX]:dVENCTOMAL 	:= aInfMAL[nX][3]
   oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL[nX]:nVALORMAL  	:= aInfMAL[nX][4]         
   oSvc:oWSWSINFMAH:oWSINFPARCMAL:oWSWSINFMAL[nX]:nSALDOMAL  	:= aInfMAL[nX][5]
Next nX

oSvc:oWSWSINFMAH:dDATABLOQ	:= aInfMA7[1] 
oSvc:oWSWSINFMAH:cHORABLOQ	:= aInfMA7[2] 
oSvc:oWSWSINFMAH:cUSERBLOQ	:= aInfMA7[3]
oSvc:oWSWSINFMAH:cMOTBLOQ	:= aInfMA7[4]
oSvc:oWSWSINFMAH:nVLRBLOQ	:= aInfMA7[5]
oSvc:oWSWSINFMAH:cBLOQUEADO	:= aInfMA7[6]
oSvc:oWSWSINFMAH:cDTHRINV	:= aInfMA7[7]
oSvc:oWSWSINFMAH:nVLRLC 	:= aInfMA7[8]
oSvc:oWSWSINFMAH:cARQPROD	:= aInfMA7[9]
oSvc:oWSWSINFMAH:cARQPARC	:= aInfMA7[10]
	
nI := 1	
While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
   LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."		  	      
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   CrdUpdUser( cUsrSessionID ) 
   nI++		  
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³1 segundo para nova checagem de login ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Sleep(1000)
End	
	   
While lWSStatus 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Espere... Verificando integridade da base de dados ..."³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
   	LJMsgRun( STR0088,, {|| lConnect   := oSvc:RESTORECONTR( cUsrSessionID, cNumContra, cCodClie, cLoja ) } ) 
   
	If !lConnect
    	cSvcError := GetWSCError()
	  	If Left(cSvcError,9) == "WSCERR044"			// Nao foi possivel post em http:// ...
	    	MsgStop( STR0043 )                    	// Nao foi possível estabelecer conexão com o servidor.
		 	lWSStatus 	:= .F.                     	// Nao chama o metodo GetVenda novamente				
	  	ElseIf Left(cSvcError,9) == "WSCERR048"				
	    	cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		 	cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))				

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se necessario efetua outro login antes de chamar o metodo GetVenda novamente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		 	
		 	If cSoapFCode $ "-1,-2,-3"                                                                    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Aguarde... Efetuando login no servidor ...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 	LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizacao da ID para o CRDXFUN (evitar reprocessamento)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CrdUpdUser( cUsrSessionID ) 
				lWSStatus := .T.
		 	Else					
		    	MsgStop(cSoapFDescr, "Error " + cSoapFCode)
				lWSStatus := .F.
		 	Endif				
      	Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sem comunicação com o WebService!"###"Atenção.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(STR0078,STR0079)    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao chama o metodo GetVenda novamente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	lWSStatus := .F.            				
	  	Endif
	Else			                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nao chama o metodo GetVenda novamente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lWSStatus   := .F.	             
	Endif
End

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDRetErroºAutor  ³ Vendas Clientes    º Data ³  01/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade tratar o erro de WebServicesº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1: Erro Generico                                       º±±
±±º          ³ ExpC2: Erro Generico 3                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDRetErroWS( cWSCError0, cWSCError3 )
Local lRetorno := .T.				//Retorno da Funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³WSCERR044 - Não foi possível POST : URL [URP_POST]³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Left( cWSCError0, 9 ) == "WSCERR044"
	MsgStop( STR0105 )   //"Não foi possível estabelecer conexão com o servidor. Confirme esta tela e aguarde nova tentativa."
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³WSCERR048 - SOAP FAULT [FAULT_CODE] ( POST em <URL> ) : [FAULT_STRING]³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf Left( cWSCError0, 9 ) == "WSCERR048"
	cSoapFCode  := Alltrim( Substr( cWSCError3, 1, At ( ":", cWSCError3 ) - 1 ) )
	cSoapFDescr := Alltrim( Substr( cWSCError3, At( ":", cWSCError3 ) + 1, Len( cWSCError3 ) ) )
	
	MsgStop( cSoapFDescr, "Error " + cSoapFCode )

Else
	MsgStop( STR0078, STR0079 )  //"Sem comunicação com o WebService!", "Atenção."
Endif

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDBloqueSºAutor  ³ Vendas Clientes    º Data ³  16/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a Chamada do servico de consulta para verificar o      º±±
±±º          ³ status de bloqueio do cliente que está no caixa, aguardandoº±±
±±º          ³ liberacao .Retorna para o caixa o atual status do cliente. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1: Codigo do Cliente para avaliacao do crediario       º±±
±±º          ³ ExpC2: Loja do Cliente                                     º±±
±±º          ³ ExpL3: Se foi Chamado do Front Loja  				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDBloqueStatus( cCliente, cLoja , lFront )
Local nI			:= 1								//Variavel de apoio para o numero de tentativas de conexao
Local lRetorno		:= .T.								//Retorno da funcao de bloqueio de credito
Local oSvcStatus										//Objeto WS WSCRDSTATUS
Local cIPEstacao	:= ""
Local nPos 			:= 0
Local uResult		:= NIL											//Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= STFIsPOS() .And. CrdxInt(.F.,.F.)			//Integração TotvsPDV x SIGACRD
Local lConnect		:= .F.											//Conexão com STBRemoteExecute
Local lSuccess		:= .F.											//Retorno da função dentro do STBRemoteExecute
Local cMsg			:= ""
Local lWSVenda		:= .T.											//Controle de Pop-up, .F. cancelado pelo usuário

DEFAULT lFront 		:= .F.

If lPosCrd		//Integração TOTVSPDV x SIGACRD
	lConnect := .F.
	While nI <= TENTATIVAS .AND. lWSVenda .AND. !lSuccess                                               
		If STBRemoteExecute("WsCrd113" ,{cCliente, cLoja}, NIL,.T.	,@uResult)
			
			If Valtype(uResult) = "A" .AND. Len(uResult)>=4 .AND. Len(uResult[4])>=3  //Se não vier array completo, não conectou completamente
				lConnect := .T.
				lSuccess := (uResult[1]=0)	//O procedimento de gravação da tabela MA7 é realizado dentro da função WSCRD113(). 0 é êxito, 1 é erro.
				If lConnect .AND. lSuccess
					LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD113 - PutComputerData Conectado e gravado com êxito!")
				EndIf
			EndIf
			
		EndIf
	
		nI++
		If (!lConnect .OR. !lSuccess) .AND. nI <= TENTATIVAS
		
			If !lConnect
				cMsg := STR0045				//"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
				LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD113 - PutComputerData NÃO CONECTADO")
			ElseIf !lSuccess
				cMsg := uResult[2] + CRLF + uResult[3]
				LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD113 - PutComputerData Conectado mas RETORNOU COM ERRO", {uResult[2],uResult[3]})
			EndIf
			If MsgYesNo( "WSCRD113" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
			   lWSVenda := .T.
				Sleep( 5000 )		//5 segundos para nova checagem
			   
			Else
				lWSVenda:= .F. // Nao chama o metodo GetVenda novamente
				LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD113 - PutComputerData - Procedimento encerrado pelo usuário !")
				ConOut("WSCRD113 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
			EndIf 									
	
		ElseIf !lConnect .AND. nI > TENTATIVAS
			LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD113 - PutComputerData - Todas as tentativas esgotadas !")
			ConOut("WSCRD113 - " + STR0141)		//"Erro: Todas as tentativas de conexão esgotadas !"
		EndIf
	EndDo
	
Else	//Via WS

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do WebService WSCRDSTATUS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvcStatus 		:= WSCRDSTATUS():New()
	oSvcStatus:_URL	:= "http://" + AllTrim( LjGetStation( "WSSRV" ) ) + "/CRDSTATUS.apw"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario esta logado. Se nao estiver ja o conecta.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS                                                
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aguarde... Efetuando login no servidor ...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJMsgRun( STR0020,, { || cUsrSessionID := WSCRDLogin( cUserName, cSenha ) } ) 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao do ID para o CRDXFUN (evita reprocessamento)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CrdUpdUser( cUsrSessionID )
		nI++
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³5 segundos para nova re-checagem³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep( 5000 )
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do Metodo PUTCOMPUTERDATA³
	//³- cUSRSESSIONID                     ³
	//³- cCUSTOMERCODE                     ³
	//³- cUNITCUSTOMERCODE                 ³
	//³- oWSCOMPUTERDATA                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvcStatus:cUSRSESSIONID		:= cUsrSessionID
	oSvcStatus:cCUSTOMERCODE		:= cCliente
	oSvcStatus:cUNITCUSTOMERCODE	:= cLoja
	oSvcStatus:oWSCOMPUTERDATA		:= CRDSTATUS_COMPUTERDATAVIEW():New()
	
	cIPEstacao  := GetPvProfString( "SIGACRD", "IP", "", GetAdv97() )
	
	If Empty(cIPEstacao)
	   nPos 	:= At(":",LJGetStation("WSSRV") )  
	   If nPos == 0
	      nPos 	:= At("/",LJGetStation("WSSRV") )  
	   EndIf   
	   cIPEstacao := Substr(LJGetStation("WSSRV"),1,nPos-1)
	EndIf
	
	oSvcStatus:oWSCOMPUTERDATA:cENVIRONMENT	:= GetEnvServer()
	oSvcStatus:oWSCOMPUTERDATA:cPORT		:= GetPvProfString( "TCP", "Port", "", GetAdv97() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No Front nao sera atribuido valor ao objeto pois assumira ³
	//³ o valor default na funcao   PUTCOMPUTERDATA ()       	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lFront
		oSvcStatus:oWSCOMPUTERDATA:cNameOrIP    := cIPEstacao
	EndIf  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia os dados do caixa requisitante³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !oSvcStatus:PUTCOMPUTERDATA()
		lRetorno := .F.
		CRDRetErroWS( GetWSCError(), GetWSCError( 3 ) )
	Endif
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDConsStaºAutor  ³ Vendas Clientes    º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade consultar a posicao da      º±±
±±º          ³ avaliacao do crediario, utilizando uma variavel global que º±±
±±º          ³ sera preenchida via RPC pelo servidor de avaliadores.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1: Codigo do Cliente para avaliacao do crediario       º±±
±±º          ³ ExpC2: Loja do Cliente                                     º±±
±±º          ³ ExpC3: Status da avaliacao do crediario                    º±±
±±º          ³ ExpO4: Objeto contendo a Mensagem de bloqueio              º±±
±±º          ³ ExpL5: Flag de controle de saida da solicitacao            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDConsStatus( cCliente , cLoja, cMsgStatus, oMsgBloque, ;
						cMsgAdic , oMsgAdic	, lRespCred, lVendaDesbloq )

Local nTmpTime	:= 0									//Tempo de controle do Timeout
Local nTimeOut	:= GetNewPar( "MV_CRDTIME", 5000 )		//Tempo de Timeout
Local aRetRPC	:= {}									//Conteudo da variavel global contendo os dados da avaliacao do crediario
Local aArea		:= GetArea()							//Guarda a area atual
Local lRetorno 	:= .T.									//Retorno da Funcao
Local nMvCRDStat:= SuperGetMV("MV_CRDSTAT",,1)			//Retorna se a busca do status vai ser via RPC ou Web Service

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia o aguardo da resposta do RPC do servidor com o FrontLoja³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !KillApp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variavel global que sera setada pelo servidor RPC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If nMvCRDStat == 1	
		GetGlbVars( cCliente + cLoja, aRetRPC )
	Else
		aRetRPC := CRDGetStatus( cCliente, cLoja )
	EndIf

	If aRetRPC == Nil .Or. Len(aRetRPC) == 0 .OR. aRetRPC[1] == "1" .OR. Empty(aRetRPC[1])
		SysRefresh()
		nTmpTime += 1000
		Sleep( 1000 )

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descricao do status da avaliacao do crediario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsgStatus := CHR( 13 ) + CHR( 13 ) + aRetRPC[2]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao da cor da mensagem de retorno da avaliacao do crediario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Credito liberado para compra³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case aRetRPC[1] == "2"
				oMsgBloque:SetColor( CLR_GREEN, GetSysColor( 15 ) )
				lVendaDesbloq  := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Credito rejeitado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case aRetRPC[1] == "3"
				oMsgBloque:SetColor( CLR_HRED, GetSysColor( 15 ) )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encaminhar para o crediario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case aRetRPC[1] == "4"
				oMsgBloque:SetColor( CLR_HBLUE, GetSysColor( 15 ) )

			Otherwise
				oMsgBloque:SetColor( CLR_BLACK, GetSysColor( 15 ) )

		EndCase
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa a variavel Global³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If nMvCRDStat == 1		
			PutGlbVars( cCliente + cLoja, NIL )
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analise do Crediario concuido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRespCred := .T.
		
		Exit

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica Time-out³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTmpTime == nTimeOut
		SA1->( DbSetOrder( 1 ) )
		
		If SA1->( DbSeek( xFilial( "SA1" ) + PadR( cCliente, 6 ) + PadR( cLoja, 2 ) ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³"O tempo máximo de resposta para a análise de crédito para o cliente " ## " foi excedido. Por favor, tente novamente..." ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMsgStatus :=  STR0100 + cCliente + "/" + cLoja + " " + SA1->A1_NOME + STR0101  
		Endif
		
		Exit
	Endif
End

CursorArrow()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada que ira exibir mensagem adicional na tela de analise de credito existente no checkout³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CRD003")  
	cMsgAdic:= ExecBlock("CRD003",.F.,.F.,{cCliente,cLoja})
	If !Empty(cMsgAdic) .AND. Valtype("cMsgAdic") <> "C"
		cMsgAdic:= ""
	Endif
	oMsgAdic:Refresh()	
Endif
	
RestArea( aArea )
	
Return lRetorno    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdGetStatus ºAutor³Vendas Clientes    º Data ³ 24/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna o status da analise de credito		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdGetStatus(cCliente, cLojaCli)

Local aRet			:= {"",""}
Local lConnect		:= .F.
Local lWSStatus		:= .T.
Local cStatus		:= ""
Local nI			:= 0                                    //Controle do numero de tentativas de login via WS
Local cSoapFCode	:= ""
Local cSoapFDescr	:= ""

Local oSvcStatus	:= NIL
Local cSituacao		:= ""
Local cMsg			:= ""
Local uResult		:= NIL										// Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= STFIsPOS() .And. CrdxInt(.F.,.F.)		//Integração TotvsPDV x SIGACRD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o login no Web Service se necessario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lPosCrd		//Via WS
	oSvcStatus := WSCRDSTATUS():New()
	oSvcStatus:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
		
	nI := 1	
	While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS
	   LjMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."		  	      
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   CrdUpdUser( cUsrSessionID ) 
	   nI++		  
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³1 segundo para nova checagem de login ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Sleep(1000)
	End	
EndIf
	   
While lWSStatus
	//"Aguarde... Consultando Status do Contrato ..."
	If lPosCrd		//Integração TOTVSPDV x SIGACRD

		// Chama a função sem passar pelo WebService por estar consultando
		// a base local
		lConnect := .F.
		While nI <= TENTATIVAS .AND. lWSStatus .AND. !lConnect                                               
			If STBRemoteExecute("WsCrd110" ,{cCliente, cLojaCli}, NIL,.T.	,@uResult)
				
				If Valtype(uResult) = "A" .AND. Len(uResult)>=2  //Se não vier array completo, não conectou completamente
					lConnect 	:= .T.		//Se conectado, sempre retornará uResult com seu resultado, sem flag de .T. ou .F.
					cSituacao 	:= uResult[1]
					cMsg 		:= uResult[2]
					LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLojaCli) + ": WSCRD110 - GetStatus - Conectado com sucesso!")
				EndIf
			EndIf
		
			nI++
			If (!lConnect) .AND. nI <= TENTATIVAS
			
				If !lConnect
					cMsg := STR0045				//"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
					LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLojaCli) + ": WSCRD110 - GetStatus NÃO CONECTADO")
				EndIf
				If MsgYesNo( "WSCRD110" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
				   lWSStatus := .T.
					Sleep( 5000 )		//5 segundos para nova checagem
				   
				Else
					lWSStatus := .F. // Nao chama o metodo GetVenda novamente
					LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLojaCli) + ": WSCRD110 - GetStatus - Procedimento encerrado pelo usuário !")
					ConOut("WSCRD110 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
				EndIf 									
		
			ElseIf !lConnect .AND. nI > TENTATIVAS
				LjGrvLog("CRDXFUN", "Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLojaCli) + ": WSCRD110 - GetStatus - Todas as tentativas esgotadas !")
				ConOut("WSCRD110 - " + STR0141)		//"Erro: Todas as tentativas de conexão esgotadas !"
			EndIf
		EndDo
	
	Else	//Via WS		
		LJMsgRun( STR0081,, {|| lConnect   := oSvcStatus:GetStatus(cUsrSessionID, cCliente, cLojaCli) } )
		If lConnect
			cSituacao := oSvcStatus:OWSGETSTATUSRESULT:CSITUACAO
			cMsg	  := oSvcStatus:OWSGETSTATUSRESULT:CMENSAGEM
		EndIf 
	EndIf 
	If !lConnect
		If !lPosCrd		//Via WS		//o lPosCrd foi verificado anteriormente lá em cima
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR044"		// "Nao foi possivel post em http:// ..."
				MsgStop( STR0043 )                     // "Não foi possível estabelecer conexão com o servidor."
				lWSStatus 	:= .F.                      // Nao chama o metodo GetVenda novamente				
			ElseIf Left(cSvcError,9) == "WSCERR048"				
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))				
				// Se necessario efetua outro login antes de chamar o metodo GetVenda novamente
				If cSoapFCode $ "-1,-2,-3"
					LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
					CrdUpdUser( cUsrSessionID ) //Atualizacao da ID para o CRDXFUN (evitar reprocessamento)
					lWSStatus := .T.
				Else					
					MsgStop(cSoapFDescr, "Error " + cSoapFCode)
					lWSStatus := .F.
				Endif				
			Else				
				MsgStop(STR0078,STR0079)    //"Sem comunicação com o WebService!"###"Atenção."
				lWSStatus := .F.            // Nao chama o metodo GetVenda novamente				
			Endif
		EndIf
	Else			
		If cSituacao == "1"
			aRet[1]  := "1"
			aRet[2]  := STR0133		//"Crédito bloqueado. Aguarde Liberação..."
		ElseIf cSituacao  == "2"
		    aRet[1]  := "2" 
		    aRet[2]  := STR0134		//"Crédito Liberado para efetuar a compra."
		ElseIf cSituacao  == "3"
			aRet[1]  := "3" 
			aRet[2]  := STR0135		//"Crédito Rejeitado para efetuar compra."
		ElseIf cSituacao  == "4"
		    aRet[1]  := "4"	
		    aRet[2]  := STR0136		//"Crédito não liberado. Encaminhar o Cliente para o setor de Crediário."
		ElseIf cSituacao  == "5"
		    aRet[1]  := "5"	
		    aRet[2]  := STR0127		//"Cliente não encontrado."
		Endif
		lWSStatus   := .F.			// Nao chama o metodo GetVenda novamente
	Endif
End

Return	aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDGravaStºAutor  ³ Vendas Clientes    º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade gravar o status da avaliacaoº±±
±±º          ³ do crediario pelo servidor de avaliadores utilizando RPC.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1: Codigo do Cliente para avaliacao do crediario       º±±
±±º          ³ ExpC2: Loja do Cliente                                     º±±
±±º          ³ ExpC3: Status da avaliacao do crediario                    º±±
±±º          ³ ExpO4: Descricao do status da avaliacao do crediario       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDGravaStatus( cCliente, cLoja, cStatus, cMensagem )
Local lRetorno 	:= .T.					//Retorno da Funcao

conout( "***** CRDGravaStatus *****" )
conout( "Cliente: " + cCliente )
conout( "Loja: " + cLoja )
conout( "cStatus: " + cStatus )
conout( "cMensagem: " + cMensagem )
conout( "***************************" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o status da avaliacao do crediario pelo servidor de avaliadores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PutGlbVars( cCliente + cLoja, { cStatus, cMensagem } )

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CrdSenhaAdm ³ Autor ³Vendas Clientes      ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Solicita a digitacao da senha do Administrador		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³CrdSenhaAdm()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cadastro de pontos e vale compras						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function CrdSenhaAdm()
Local cSenhaLoja := ""                  // Senha digitada pelo usuario. Valida se eh a senha do Administrador. 
Local lPswSeek   := .F.					// Verifica se a senha foi encontrada
Local lRet       := .T.                // Retorno da funcao: senha administrador OK
Local nTent      := 0                   // Numero de tentativas

While .T.                     
	nTent++
	
	If ljGetsenha("", @cSenhaLoja)    
  		PswOrder(3)
		lPswSeek := PswSeek(cSenhaLoja)                                                    
	  
		If ( lPswSeek .AND. PswRet()[1][1] <> "000000" ) .OR. !lPswSeek   // Administrador
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Usuario/senha não autorizado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	MsgAlert(STR0108) 
         	If nTent == 3
            	lRet := .F.
				Exit
         	Endif		 
      	Else
        	lRet  := .T.
         	Exit   
	  	Endif 
	Else
		lRet := .F.
	  	Exit	  
	Endif	  
End

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXTELACLºAutor  ³Vendas Clientes     º Data ³  07/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para escolha do cliente quando existe 2 registro no    º±±
±±º          ³SA1 com a mesma ocorrencia, por exemplo 2 CPFs iguais       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aExp1 - Array contendo os registros do SA1 que serao levadosº±±
±±º          ³        para o PDV                                          º±±
±±º          ³        [1][1] - Nome do campo                              º±±
±±º          ³        [1][2] - Conteudo do campo                          º±±
±±º          ³        [1][3] - Tipo do campo                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³1 - CONSULTA EXTRATO                                        º±±
±±º          ³2 - CONSULTA LIMITE DE CREDITO                              º±±
±±º          ³3 - RECEBIMENTO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDxTelaCl( aRegsSA1 )
Local aRet 					:= {}											// Retorno da funcao
Local aSize1				:= MsAdvSize()									// Tamanho da tela
Local aPosObj1				:= {}											// Variavel para posicionamento dos objetos na tela
Local aInfo1				:= {}											// Variavel para posicionamento dos objetos na tela
Local aObjects1				:= {}											// Variavel para posicionamento dos objetos na tela
Local oDlgTelaCli															// Objeto da tela 
Local oTbrCli																// Objeto do TWBrowse
Local aFldSize				:= {}											// Tamanho dos campos que serao mostrados na enchoice
Local aCamposSA1			:= {}											// Campos que serao tratados na TWBROWSE
Local aTituloSA1			:= {}											// Titulo dos campos do SA1
Local oOk     				:= LoadBitMap(GetResources(), "LBTIK")			// Bitmap utilizado no Lisbox  (Marcado)
Local oNo     				:= LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Local oNever  				:= LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Local lMark					:= .F.											// Marca do MBrowse
Local nX					:= 0											// Variavel para looping
Local nY					:= 0											// Variavel para looping
Local aLinCli				:= {}											// Array com os dados do cliente para mostrar no TWBrowse
Local nPosTmp 				:= 0											// Posicao do array aCamposSA1
Local lOk					:= .F.											// Controle da dialog
Local cCodCliente			:= ""											// Codigo do cliente
Local cCodLoja 				:= ""											// Codigo da loja
Local bOkButton																// Bloco de codigo do botao Ok da enchoiceBar
Local bCancelButton															// Bloco de codigo do botao Cancel da enchoiceBar
Local lR5                   := GetRpoRelease("R5")                          // Indica se o release e 11.5
Local nTamTela1				:= 6											// Posicionamento da tela Ver11.5
Local nTamTela2				:= 2											// Posicionamento da tela Ver11.5
Local lMultSel				:= .F.											// Informa se pode selecionar multiplos clientes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao das coordenadas da tela em 60% do valor total do  ³
//³ tamanho do desktop para sempre ficar proporcional           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize1[1] := aSize1[1] * 0.60
aSize1[2] := aSize1[2] * 0.60
aSize1[3] := aSize1[3] * 0.60
aSize1[4] := aSize1[4] * 0.60
aSize1[5] := aSize1[5] * 0.60
aSize1[6] := aSize1[6] * 0.60
aSize1[7] := aSize1[7] * 0.60

aAdd( aObjects1, { 100, 100, .T., .T. } )
aInfo1 	 := { aSize1[ 1 ], aSize1[ 2 ], aSize1[ 3 ], aSize1[ 4 ], 0, 0 }
aPosObj1 := MsObjSize( aInfo1, aObjects1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos que serao mostrados na TWBrowse                                 ³
//³ Faz um tratamento expecífico para template DRO para mostrar a          ³
//³ matricula do cliente.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aCamposSA1, "A1_NOME" )
aAdd( aCamposSA1, "A1_COD" )
aAdd( aCamposSA1, "A1_LOJA" )
If HasTemplate( "DRO" )
	aAdd( aCamposSA1, "A1_MATRICU" )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina o tamanho e o titulo das colunas                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aFldSize, 10 )   		// Para a coluna fixa com a figura de "marcado"/"desmarcado"
aAdd( aTituloSA1, " " )		// Para a coluna fixa com a figura de "marcado"/"desmarcado"
For nX := 1 to Len( aCamposSA1 )
	aAdd( aFldSize, TamSx3( aCamposSA1[nX] )[1] * If( nX == 1, 2.5, 5.2 ) )
	aAdd( aTituloSA1, Posicione("SX3", 2, PadR( aCamposSA1[nX], 10 ), "X3_TITULO" ) )
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array que sera' mostrado no TWBrowse com as informacoes ³
//³ do cliente                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aRegsSA1 )
	aAdd( aLinCli, { -1 } )
	For nY := 1 to Len( aCamposSA1 )
		nPosTmp := aScan( aRegsSA1[nX], { |x| Alltrim( Upper ( x[1] ) ) == aCamposSA1[nY] } )
		If nPosTmp > 0
			aAdd( aLinCli[Len( aLinCli )], aRegsSA1[nX][nPosTmp][2] )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao encontrar o campo no array que voltou da retaguarda, alimenta ³
			//³ o array aLinCli com espacos em branco                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aLinCli[Len( aLinCli )], " " )
		Endif
	Next nY
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o bLine do TWBrowse                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLine := "{|| {"

For nX := 1 to Len( aLinCli[1] )
    If nX == 1
    	cLine += "If( aLinCli[oTbrCli:nAt,"+AllTrim(Str(nX))+"] == -1, oNo, oOk )"
    Else
    	cLine += "aLinCli[oTbrCli:nAt,"+AllTrim(Str(nX))+"]"
    Endif
    If nX < Len( aLinCli[1] )
    	cLine += ", "
    Endif
Next nX

cLine += "} }"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos botoes de Ok e Cancel da Enchoice           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bOkButton 		:= {|| If( VldCRDxTelaCl( aLinCli ), ( lOk := .T., oDlgTelaCli:End() ), Nil ) }     
bCancelButton	:= {|| lOk := .F.,oDlgTelaCli:End()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para selecao do cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgTelaCli TITLE STR0109 FROM (aSize1[7]*0.7),0 TO (aSize1[6]*0.7),aSize1[5] PIXEL // "Cliente"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LR5 = Verifica utilização da Versão 11.5                            ³
//³ Versão 11.5, realiza posicionamento do Objeto TWBrowse              ³
//³ sem adicionar valores adicionais aos arrais aPosObj.                ³
//³ Versão 11.0 Adiciona nTamTela1 := +6 no 1º Parametro e              ³
//³ Adiciona nTamTela2 := +2 no 3ºParametro.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lR5
	nTamTela1 := 0
	nTamTela2 := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se pode selecionar mais de um cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMultSel := SuperGetMV("MV_LJMLTRC",, .F.) .AND. IsInCallStack("LJRecPesq")

oTbrCli := TwBrowse():New(	aPosObj1[1][1]+nTamTela1,	aPosObj1[1][2],		aPosObj1[1][4]+nTamTela2,		aPosObj1[1][3]*0.7-11,;
							Nil,				        aTituloSA1,			aFldSize,						oDlgTelaCli,;
							Nil,						Nil,				Nil,							Nil,;
							Nil,						Nil,				Nil,							Nil,;
							Nil,						Nil,				Nil,							.F.,;
							Nil,						.T.,				Nil,							.F.,;
							Nil,						Nil,				Nil )
oTbrCli:lColDrag	:= .T.
oTbrCli:nFreeze		:= 1
oTbrCli:SetArray( aLinCli )
oTbrCli:bLine		:= &cLine
oTbrCli:bLDblClick	:= { || ChgMarkLb( oTbrCli, aLinCli, {|| .T. }, lMultSel ) }

ACTIVATE MSDIALOG oDlgTelaCli CENTERED ON INIT EnchoiceBar( oDlgTelaCli, bOkButton, bCancelButton, Nil, Nil )

If lOk
	For nX := 1 To Len( aLinCli )
		If aLinCli[nX][1] == 1
			nPosTmp 	:= aScan( aCamposSA1, Alltrim( Upper( "A1_COD" ) ) )
			cCodCliente := aLinCli[nX][nPosTmp+1]
			nPosTmp 	:= aScan( aCamposSA1, Alltrim( Upper( "A1_LOJA" ) ) )
			cCodLoja	:= aLinCli[nX][nPosTmp+1]
			
			aADD(aRet,{cCodCliente, cCodLoja})
			
			If !lMultSel
				aRet := {cCodCliente, cCodLoja}
				Exit
			Else
				aADD(aRet,{cCodCliente, cCodLoja})
			EndIf

		Endif
	Next nX
Else
	If !lMultSel
		aRet := {cCodCliente, cCodLoja}
	Else
		aADD(aRet,{cCodCliente, cCodLoja})
	EndIf

	aRet := { cCodCliente, cCodLoja }
	
Endif

Return aRet           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCRDxTelaClºAutor  ³Vendas Clientes  º Data ³  08/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do botao Ok na Enchoice bar da funcao CRDxTelaCl  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDxTelaCl                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCRDxTelaCl( aLinCli )
Local lRet 		:= .F.				// Retorno da funcao
Local nX		:= 0 				// Variavel de controle de looping

For nX := 1 To Len( aLinCli )
	If aLinCli[nX][1] == 1
		lRet := .T.
	Endif
Next nX    

If !lRet            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Escolha um cliente para confirmar esta operação, ou cancele.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgStop( STR0110 )
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDCliR2PdvºAutor ³Vendas Clientes     º Data ³  07/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa o cliente na retaguarda atraves de WebService e    º±±
±±º          ³grava o cliente no PDV (todo o registro) se ainda nao exis- º±±
±±º          ³tir no PDV.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp1 - Numero do cartao do cliente                         º±±
±±º          ³cExp2 - Numero do CPF do cliente                            º±±
±±º          ³cExp3 - Matricula do cliente (para o caso de TPL Drogaria)  º±±
±±º          ³lExp4 - Identifica se conseguiu conectar no WebService      º±±
±±º          ³cExp5 - Numero do contrato que contem os titulos            º±±
±±º          ³cExp6 - Codigo do DEPENDENTE                                º±±
±±º          ³cExp7 - Nome do DEPENDENTE                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com o registro do SA1                                 º±±
±±º          ³[x][x][1] - Campo do SA1                                    º±±
±±º          ³[x][x][1] - Valor do campo                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaCRD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDCliR2Pdv( cCartao, cCPF	  , cMatricula, lConnect, ;
					  cNum 	 , cCodDEP, cNomeDep, cCodCli, cLojCli, cTipoCli )
Local aRegsSA1		:= {}			// Array com varios registros do SA1 para retorno da funcao
Local aCliente 		:= {}			// Array com 1 registro do SA1     
Local nX			:= 0 			// Variavel para controle de looping
Local nPosCli		:= 0			// Posicao do campo do cliente no array aCliente
Local nPosLoja 		:= 0			// Posicao do campo loja do cliente 
Local lNovoCliente	:= .F.			// Indica se e' para incluir o cliente no SA1 do PDV ou apenas para atualizar
Local cCliente		:= "" 			// Codigo do cliente
Local cLojaCli		:= "" 			// Codigo da loja
Local lAmbOffLn	 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia as variaveis pois apenas uma delas pode ser enviada, dependendo       ³
//³ da funcao que for chamada e o que o usuario digitar para pesquisar o cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cCartao		:= ""						// Numeracao do cartao
DEFAULT cCPF		:= ""                      	// Numeracao do CPF
DEFAULT cMatricula	:= ""                      	// Numero da matricula
DEFAULT cNum		:= ""                    	// Numero do contrato
DEFAULT cCodDEP 	:= ""						// Codigo do DEPENDENTE	
DEFAULT cNomeDEP    := ""                   	// Nome do DEPENDENTE
DEFAULT cCodCli     := ""						// Codigo do Cliente
DEFAULT cLojCli     := ""						// Loja do Cliente
DEFAULT cTipoCli    := ""       				// Tipo do Cliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama o WebService WsCrdConsCli para consultar o SA1 na ³
//³ retaguarda e trazer para o PDV                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
aRegsSA1 := aClone( WSCrdConsCli( 	cCartao   , cCPF    , cNum     , @lConnect, ;
									cMatricula, @cCodDEP, @cNomeDep, cCodCli, cLojCli, cTipoCli ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a validacao do retorno da funcao WSCRDConsCli ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( aRegsSA1 ) <> "A"
	aRegsSA1 := {}
Endif

For nX := 1 to Len( aRegsSA1 )

	aCliente := aClone( aRegsSA1[nX] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se Registro do SA1 no front nao existir ou conteudo de algum campo for diferente da retaguarda atualiza registro |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nModulo == 23 .OR. (nModulo == 12 .AND. lAmbOffLn)) .AND. CrdSa1Alte( aCliente )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa se a chave primaria jah existe no check-out          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosCli 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_COD" } )
		nPosLoja 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_LOJA" } )
		If nPosCli <> 0 .AND. nPosLoja <> 0						
			cCliente 	:= aCliente[nPosCli][2]
			cLojaCli	:= aCliente[nPosLoja][2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a gravacao do cadastro do cliente no check-out         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
			lNovoCliente := .T.
			DbSelectArea("SA1")
			DbSetOrder(1)	// Filial + Cod + Loja
			If DbSeek( xFilial("SA1") + cCliente + cLojaCli )
				lNovoCliente := .F.
			Endif
			FrtGeraSL( "SA1", aCliente, lNovoCliente )	// Grava o cadastro do cliente na estacao
			cCliente := SA1->A1_COD
			cLojaCli := SA1->A1_LOJA
		Endif
	Endif
Next nX

Return (aRegsSA1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXVLDUSU ºAutor  ³Vendas Clientes     º Data ³  20/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de senha de usuario no momento de realizar:      º±±
±±º          ³ Desbloqueio do cartao                                      º±±
±±º          ³ Alteracao no limite de credito do cliente.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - X3_VALID (MA6_SITUA, A1_LC, A1_VENCLC)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Controla para qual campo serah realizada a validacaoº±±
±±º          ³        nTipo = 1 (Validacao a ser realizada para           º±±
±±º          ³                   Desbloqueios dos cartoes)                º±±
±±º          ³        nTipo = 2 (Validacao a ser realizada para alteracao º±±
±±º          ³                   do Limite de Credito do Cliente)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Verifica se pode ou nao tealizar as alteracoes.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDXVLDUSU( nTipo )
Local lRet 	  		:= .T.		// Retorno da funcao
Local lCartao 		:= .F.		// Verifica se a validacao eh para Desbloqueio dos cartoes
Local lCRDXProcCart := .F. 		// Verifica se a rotina esta' sendo chamada atraves da rotina de processamento de Cartoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao so' sera' realizada em caso de acesso a   ³
//³rotina automatica de cartoes CRDA250.prw            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo = 3
	lCRDXProcCart := .T.
	If __cUserId <> "000000"
		lRet := CRDXTelaSenha()
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao so' sera' realizada em caso de alteracao  ³
//³do cadastro de clientes.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCRDXProcCart
	If !INCLUI 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³nTipo = 1 (Validacao para desbloqueio dos cartoes   ³
		//³nTipo = 2 (Validacao para alteracao do limite de    ³
		//³           credito)                          	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo = 1 
			lCartao := .T.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³verifica se a validacao eh para Desbloqueio  ³
		//³dos cartoes.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCartao 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o campo Situacao esteja como CANCELADO, ³
			//³nao sera' possivel realizar qualquer tipo de ³
			//³alteracao.                                   ³
			//³oGetd6:aCols[n][3] = Situacao do Cartao      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oGetd6:aCols[n][3] = "3"
				MsgInfo(STR0111)	//"Cartoes CANCELADOS nao podem ser alterados!"
				lRet := .F.
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica casos em que esta' validando os     ³
		//³cartoes.                                     ³
		//³A senha sera' solicitada somente quando a    ³
		//³troca da Situacao do Cartao for:    			³
		//³.........................                    ³
		//³De         |  Para      |                    ³
		//³Bloqueado  |  Ativo     |                    ³
		//³Bloqueado  |  Cancelado |                    ³
		//|.........................                    ³
		//|Cartao com situacao CANCELADO nao sera'      ³
		//|permitido sofrer alteracoes                  ³
		//|Cartao com situacao ATIVO nao eh necessario  ³
		//|a solicitacao de senha.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .AND. lCartao .AND. oGetd6:aCols[n][3] <> "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o usuario logado eh Administrador³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If __cUserId <> "000000"
				lRet := CRDXTelaSenha()
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica casos em que esta' validando o      ³
		//³limite de credito do cliente                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .AND. !lCartao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o usuario logado eh Administrador³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If __cUserId <> "000000"
				If !lSenhaOk
					lRet := CRDXTelaSenha()
					If lRet
						lSenhaOk := .T.
					Endif	
				Endif	
			Endif
		Endif
	Endif
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXTelaSenhaºAutor  ³Vendas Clientes     º Data ³  20/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao da tela de validacao de senhas do usuario.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDXVLDUSU()                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Verifica se pode ou nao ralizar as alteracoes.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDXTelaSenha()
Local _cSenha		:= SPACE(20)	// Senha do usuario
Local _cNivelAdm	:= .F.			// Sinaliza usuario ADM
Local _cUsuario    	:= SPACE(25)	// Nome do usuario
Local _lQuit       	:= "N"			// Controle de loop
Local _lRet 	   	:= .F.			// Retorno da funcao

Local oDlgSenha						// Objeto da caixa de dialogo da senha
Local cBitMap		:= "LOGIN"		// Bitmap utilizado na caixa de dialogo


While _lQuit = "N"

	DEFINE DIALOG oDlgSenha TITLE STR0112 FROM 20, 20 TO 225,310 PIXEL //"Senhas"

	@ 0, 0 BITMAP oBmp1 RESNAME cBitMap oF oDlgSenha SIZE 50,140 NOBORDER WHEN .F. PIXEL
	  
	//Informacoes do caixa atual
	@ 05,55 SAY STR0132	PIXEL						                   // Usuário Atual:
	@ 15,55 MSGET cUserName WHEN .F. PIXEL SIZE 80,08
	                             
	@ 30,55 SAY STR0131 PIXEL							               // Usuário Administrador: 
	@ 40,55 MSGET oGetSup VAR _cUsuario WHEN .T. PIXEL SIZE 80,08
	
	@ 55,55 SAY STR0130 PIXEL                                          // Senha:
	@ 65,55 MSGET oGetSenha VAR _cSenha PASSWORD PIXEL SIZE 40,08 VALID CRDXVldSenha( _cSenha, @_cNivelAdm, @_cUsuario )
	
	DEFINE SBUTTON FROM 85,75  TYPE 1 ACTION ( IIF( !_lRet .OR. Empty(_cSenha), _lRet := CRDXAutoriza( _cNivelAdm, oDlgSenha, @_lQuit ), .T. ), oDlgSenha:End() ) ENABLE OF oDlgSenha
	DEFINE SBUTTON FROM 85,105 TYPE 2 ACTION ( _lRet := .F. , _lQuit := "S", oDlgSenha:End() ) ENABLE OF oDlgSenha
	
	ACTIVATE MSDIALOG oDlgSenha CENTERED ON INIT ( IIf( Type( "lUsaLeitor" ) == "L" .AND. lUsaLeitor, LeitorFoco( nHdlLeitor, .T. ), NIL ) )

End                                                     

Return( _lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXVldSenhaºAutor  ³Vendas Clientes     º Data ³  20/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida senha digitada                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDXVLDUSU()                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Senha do usuario.                                    º±±
±±º          ³Expc2 - Nivel de acesso do usuario.                          º±±
±±º          ³ExpL1 - Retorno da funcao CRDXVLSUSU()                       º±±
±±º          ³Expc2 - Nome do usuario                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDXVldSenha( _cSenha, _cNivelAdm, _cUsuario )
Local _aConfigUsu	:= {}	// Array com informacoes do usuario.
Local cIdUsuario	:= ""   // Id do usuário 

PswOrder(2)
PswSeek(AllTrim(_cUsuario))
    
If PswName(_cSenha)
	_aConfigUsu 	:= PswRet(NIL)
	_cUsuario		:= Left(_aConfigUsu[1,2],25)
	cIdUsuario		:= _aConfigUsu[1,1]
	_cNivelAdm		:= FwIsAdmin(cIdUsuario)
Else
	MsgInfo(STR0114)	//"Senha não cadastrada!"
	_lRet       := .F.
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXAutorizaºAutor  ³Vendas Clientes     º Data ³  20/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica Nivel de Acesso do usuario                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDXVLDUSU()                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Nivel de acesso do usuario.                          º±±
±±º          ³ExpO1 - Objeto da Tela                                       º±±
±±º          ³ExpL1 - Controle para a aparica da tela                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Verifica se pode ou nao ralizar as alteracoes.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDXAutoriza( _cNivelAdm, oDlgSenha, _lQuit )
Local _lRet := .T.		// Retorno da funcao
                  

If !_cNivelAdm 
	MsgAlert(STR0115)		//"Usuário sem permissão para esta rotina!"
	_lRet := .F.		
Endif

If _lRet
	_lQuit := "S"
	oDlgSenha:End()
Endif

Return(	_lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXSetaVar ºAutor  ³Vendas Clientes     º Data ³  20/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta a variavel do tipo Static para FALSE                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDA010                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDXSetaVar()

lSenhaOk := .F.

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdLocMA7   ºAutor  ³Vendas Clientes     º Data ³  01/12/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o MA7 esta locado pelo analista de credito      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDA010                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Sessao                                              º±±
±±º          ³ EXPC2 - Codigo do cliente                                   º±±
±±º          ³ EXPC3 - Loja do cliente                                     º±±
±±º          ³ EXPC4 - Numeracao do contrato                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPL1 - Retorno da funcao                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Function CrdLocMA7( cUsrSessionID, cCliente, cLoja, cContrat ) 
Local aArea         := GetArea()	//Salva a area de trabalhho
Local lRet       	:= .T.			//Retorno da funcao
Local lWSEstorno 	:= .T.			//Retorno do WebService
Local oSvc							//Objeto para WebService
Local cSoapFCode  	:= ""			//Retorno WebService
Local cSoapFDescr 	:= ""			//Retorno WebService
Local nI         	:= 1			//Controle do numero de tentativas de login via WS
Local lConnect		:= .F.			//Verifica se conectou no webservice
Local uResult		:= NIL										// Retorno da chamada da funcao na Retaguarda
Local lPosCrd		:= STFIsPOS() .And. CrdxInt(.F.,.F.)		//Integração TotvsPDV x SIGACRD
Local lWSAnalise	:= .T.

DEFAULT cContrat	:= ""			//Numeracao do contrato

If nModulo == 12 .OR. nModulo == 72 // SIGALOJA   //SIGAPHOTO
	//Pega o Numero do contrato no MA7
	DbSelectArea("MA7")
	DbSetOrder(1)
	If DbSeek(xFilial("MA7")+cCliente+cLoja)
		If !Empty(MA7->MA7_CONTRA)
			cContrat  := MA7->MA7_CONTRA
		Endif
	Endif
Endif

If !lPosCrd		//Via WS
	oSvc := WSCRDVENDA():New()
	
	oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDVENDA.apw"  	
	   
	While Empty( cUsrSessionID ) .AND. nI <= TENTATIVAS          
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|	Aguarde... Efetuando login no servidor ...             | 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		LJMsgRun( STR0020,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 		  	      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  	//³Atualizacao da ID para o CRDXFUN (evita reprocessamento)³
	  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	CrdUpdUser( cUsrSessionID ) 
	 	 nI++		  
	  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  	//³1 segundo para nova checagem de login ³
	  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	Sleep(1000)
	End
EndIf
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Efetuando a analise de credito                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPosCrd		//Integração TOTVSPDV x SIGACRD

	// Chama a função sem passar pelo WebService por estar consultando
	// a base local
	lConnect := .F.
	lRet := .F.
	While nI <= TENTATIVAS .AND. lWSAnalise .AND. !lConnect                                               
		If STBRemoteExecute("WsCrd017" ,{cContrat, cCliente, cLoja}, NIL,.T.	,@uResult)
			If Valtype(uResult) = "L" //Se não vier variável lógica, não conectou completamente
				lConnect := .T.
				lRet := uResult
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrat) + ", Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD017 - RetirarAnalise - Conectado com sucesso !")
			EndIf
		EndIf
	
		nI++
		If (!lConnect) .AND. nI <= TENTATIVAS
		
			cMsg := STR0045				//"Não foi possível estabelecer conexão com o servidor. A transação da venda não foi confirmada."
			LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrat) + ", Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD017 - RetirarAnalise NÃO CONECTADO")
			If MsgYesNo( "WSCRD017" + CRLF + cMsg + CRLF + STR0140 ) //"Tentar novamente ?"
			   lWSAnalise := .T.
				Sleep( 5000 )		//5 segundos para nova checagem
			Else
				lWSAnalise := .F. // Nao chama o metodo GetVenda novamente
				LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrat) + ", Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD017 - RetirarAnalise - Procedimento encerrado pelo usuário !")
				ConOut("WSCRD017 - " + STR0142)		//"Atenção: Procedimento encerrado pelo usuário !"
			EndIf 									
	
		ElseIf !lConnect .AND. nI > TENTATIVAS
			LjGrvLog("CRDXFUN", "Contrato " + Alltrim(cContrat) + ", Cliente " + Alltrim(cCliente) + "/" + Alltrim(cLoja) + ": WSCRD017 - RetirarAnalise - Todas as tentativas esgotadas !")
			ConOut("WSCRD017 - " + STR0141)		//"Erro: Todas as tentativas de conexão esgotadas !"
		EndIf
	EndDo

Else
	lConnect := oSvc:RETIRARANALISE( cUsrSessionID, cContrat, cCliente, cLoja  )
	lRet := oSvc:lRETIRARANALISERESULT       
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Caso haja algum problema de WS e retorne Nil , é assumido
//|  .F. em lret para forçar o caixa a verificar junto a 
//|  area de analise de credito a liberação do registro                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(lRet) == "U" 
	lRet := .F.
EndIf	

If !lRet
	MsgStop(STR0116) //Contrato sendo analisado pelo analista de credito.
Endif

RestArea( aArea )  //Retorno da area do sistema
               
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDZERAVAR  ºAutor  ³Vendas Clientes     º Data ³  12/04/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Zera as variaveis que controlam os perifericos              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACRD - CRDA010                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 - Usa leitor de CMC7                                  º±±
±±º          ³ ExpL2 - Usa leitor                                          º±±
±±º          ³ ExpL3 - Usa display                                         º±±
±±º          ³ ExpL4 - Imprime cupom                                       º±±
±±º          ³ ExpC1 - Tipo do TEF                                         º±±
±±º          ³ ExpL5 - Idenfica se a estacao esta preenchida               º±±
±±º          ³ ExpL6 - Usa gaveta                                          º±±
±±º          ³ ExpL7 - Tem TEF aberto                                      º±±
±±º          ³ ExpL8 - Usa TEF                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDZERAVAR(	lUsaCmc7	, lUsaCH	, lUsaLeitor, lUsaDisplay	, ; 
							lImpCup		, cTipTEF	, lFiscal	, lGaveta		, ;
							ltTefAberto , lUsaTef	)

lUsaCmc7	:= .F.
lUsaCH		:= .F.
lUsaLeitor	:= .F.
lUsaDisplay := .F.
lImpCup		:= .F.
cTipTEF		:= "1" //1=TEF Desligado.
lFiscal     := .F.
lGaveta		:= .F.
ltTefAberto := .F.
lUsaTef		:= .F.

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDXNumCart ºAutor  ³Vendas Clientes     º Data ³  27/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Traz as informacoes referente ao cliente                    	º±±
±±º          ³Numeracao, situacao                                         	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpL1 - Defini se e' Rotina de Recebimento de titulos ou nao  º±±
±±º          ³ExpC2 - Codigo do cliente                                     º±±
±±º          ³ExpC3 - Loja do cliente                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamada   ³LOJXREC - funcao LJGrvRec()      	                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Template Drogaria         	                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDXNumCart( lRecebimento, cCodSA1, cLojSA1 )
Local oSvc							// Objeto para WSCRDINFOCART
Local xRet		  					// Retorno da funcao
Local lWsPesqCart := .T.			// Controle para chamar o metodo ATUALIZACARTAO
Local lRetWS      := .T.			// Retorno do Web Services
Local cSvcError   := ""				// Controle de erro
Local cSoapFCode  := ""				// Codigo do erro retornado pelo WS
Local cSoapFDescr := ""				// Descricao do erro do WS

DEFAULT lRecebimento := .F.
DEFAULT cCodSA1		 := ""  	
DEFAULT cLojSA1      := ""


// Caso a estação não esteja configurada corretamente não realiza a pesquisa do cartao
If Empty(LJGetStation("WSSRV"))
	Aviso(STR0117, STR0118, {STR0102})//"Uso Indevido da função de Pesquisa de cartão" ##""É necessário preencher o campo LG_WSSRV com o IP e/ou porta do Web Service."" ## "Ok"
	xRet  := {.F.,""}
	Return (xRet)
EndIf

oSvc      := WSCRDINFOCART():New()
oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDINFOCART.apw"

If cUsrSessionID == Nil
	LJMsgRun( STR0119,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } )//"Aguarde... Efetuando login no servidor ..."
EndIf

While lWsPesqCart
	LJMsgRun(STR0120,, {|| lRetWS := oSvc:PESQCARTAO(cUsrSessionID,xFilial("SA1"),Iif(!Empty(cCodSA1),cCodSA1,SA1->A1_COD),Iif(!Empty(cLojSA1),cLojSA1,SA1->A1_LOJA), lRecebimento) })//"Aguarde... Pesquisando número do cartão do cliente..."
	If !lRetWS
		xRet  := {.F.,""}
		cSvcError   := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			// Se necessario efetua outro login antes de chamar o metodo PesqCart novamente
			If cSoapFCode $ STR0121 //"-1,-2,-3"
				LJMsgRun( STR0119,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
				lWsPesqCart := .T.
			Else
				MsgStop(cSoapFDescr, STR0122 + cSoapFCode) //"Error "
				lWsPesqCart := .F.	//Nao chama o metodo PesqCart novamente
			Endif
		Else
			MsgStop(STR0078,STR0079) //"Sem comunicação com o WebService!" ## "Atenção."
			lWsPesqCart := .F. //Nao chama o metodo PesqCart novamente
		EndIf
	Else
		If !Empty( oSvc:oWSPESQCARTAORESULT:oWSWSINFO1[1]:cMensagem ) .AND. !lRecebimento
			MsgInfo( oSvc:oWSPESQCARTAORESULT:oWSWSINFO1[1]:cMensagem )
		Endif
		If !lRecebimento
			xRet  := {.T.,oSvc:oWSPESQCARTAORESULT:oWSWSINFO1[1]:cCartao}
		Else 
			xRet  := {.T.,oSvc:oWSPESQCARTAORESULT:oWSWSINFO1[1]:cCartao, oSvc:oWSPESQCARTAORESULT:oWSWSINFO1[1]:cMensagem}
		Endif
		lWsPesqCart := .F. //Nao chama o metodo PesqCart novamente
	EndIf
End

Return ( xRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdxAtuMA6   ºAutor  ³Vendas Clientes     º Data ³  19/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que chama o metodo AtualizaCartao() para atualizar 	 º±±
±±º          ³os campos MA6_SITUA e MA6_MOTIVO.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do cliente    	                                 º±±
±±º          ³ExpC2 - Loja do cliente      	                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamada   ³LOJXREC - funcao LJGrvRec()    	                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Recebimento de titulo               	                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDXAtuMA6( cCod, cLoj )

Local oSvc							// Objeto para WSCRDINFOCART
Local lRet		  := .T.			// Retorno da funcao
Local lWsAtuCart  := .T.			// Controle para chamar o metodo ATUALIZACARTAO
Local lRetWS      := .T.			// Retorno do Web Services
Local cSvcError   := ""				// Controle de erro
Local cSoapFCode  := ""				// Codigo do erro retornado pelo WS
Local cSoapFDescr := ""				// Descricao do erro do WS

// Caso a estação não esteja configurada corretamente não realiza a pesquisa do cartao
If Empty(LJGetStation("WSSRV"))
	Aviso(STR0123, STR0118, {STR0102})//"Uso Indevido da função de Atualização da Situação dos cartões" ##"É necessário preencher o campo LG_WSSRV com o IP e/ou porta do Web Service." ## "Ok"
	lRet  := .F.
EndIf
If lRet
	oSvc      := WSCRDINFOCART():New()
	oSvc:_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDINFOCART.apw"
	
	If cUsrSessionID == Nil
		LJMsgRun( STR0119,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } )//"Aguarde... Efetuando login no servidor ..."
	EndIf
	
	While lWsAtuCart
		LJMsgRun(STR0124,, {|| lRetWS := oSvc:ATUALIZACARTAO	(cUsrSessionID, cCod, cLoj) })//"Aguarde... Efetuando atualização dos cartões"
		If !lRetWS
			lRet  := .F.
			cSvcError   := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
				cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
				cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
				// Se necessario efetua outro login antes de chamar o metodo Atualiza novamente
				If cSoapFCode $ STR0025 //"-1,-2,-3"
					LJMsgRun( STR0119,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde...Efetuando login no servidor"
					lWsAtuCart := .T.
				Else
					MsgStop(cSoapFDescr, "Error" + cSoapFCode) //"Error "
					lWsAtuCart := .F.	//Nao chama o metodo Atualiza novamente
				Endif
			Else
				MsgStop(STR0078,STR0079) //"Sem comunicação com o WebService!" ## "Atenção."
				lWsAtuCart := .F. //Nao chama o metodo Atualiza novamente
			EndIf
		Else
			If !Empty( oSvc:oWSATUALIZACARTAORESULT:oWSWSINFO2[1]:cMensagem )
				MsgInfo( oSvc:oWSATUALIZACARTAORESULT:oWSWSINFO2[1]:cMensagem )
			Endif
			lRet  := .T.
			lWsAtuCart := .F. //Nao chama o metodo Atualiza novamente
		EndIf
	End
Endif

Return ( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdXExecYMF  ºAutor  ³Vendas Clientes     º Data ³  11/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que executa o YMF para validacao da analise de credito. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cPolitica  - Politica a ser executada							 º±±
±±º          ³cTipo      - Tipo da politica									 º±±
±±º			 |cLayout    - Layout da politica                                º±±
±±º			 |cCodCli	 - Codigo do cliente	                             º±±
±±º			 |cLojCli	 - Loja do cliente	                                 º±±
±±º			 |nVlrTitAbe - Valor de titulos abertos de um cliente	         º±±
±±º			 |nVlrToleLi - Valor de tolerancia de limite                     º±±
±±º			 |nVlrFinanc - Valor Financiado                                  º±±
±±º			 |nVlrTitAtr - Valor de titulos em atrazos                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³oRet - Retorno do Intellector(Tools) YMF.					     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaCRD				               	                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdXExecYMF(cPolitica , cTipo     , cLayout   , cCodCli   ,; 
                     cLojCli   , nVlrTitAbe, nVlrToleLi, nVlrFinanc,;
                     nVlrTitAtr)

Local oYMF      := Nil 
Local oRet      := -2  						//Cliente nao encontrado  
Local oEntCli   := LJCEntCliente():New()
Local cValLC    := "0"
Local cVctoLC   := DTOS(dDataBase)

oEntCli:DadosSet("A1_COD", cCodCli)
oEntCli:DadosSet("A1_LOJA", cLojCli)

oCliente := oEntCli:Consultar(1)

If oCliente:Count() > 0

    If !Empty(oCliente:Elements(1):DadosGet("A1_LC"))       
    	cValLC := CVALTOCHAR(oCliente:Elements(1):DadosGet("A1_LC"))
    EndIf

    If !Empty(oCliente:Elements(1):DadosGet("A1_VENCLC"))
    	cVctoLC := DTOS(oCliente:Elements(1):DadosGet("A1_VENCLC"))
    EndIf

    oYMF := LJCYMF():New(cPolitica, cTipo, cLayout)  

    oYMF:oDadosEnv:cValorLimi := cValLC
	oYMF:oDadosEnv:cDataVenda := DTOS(dDatabase) 					
    oYMF:oDadosEnv:cDataVenc  := cVctoLC
    oYMF:oDadosEnv:cTitulosAb := CVALTOCHAR(nVlrTitAbe) 
    oYMF:oDadosEnv:cTolLimite := CVALTOCHAR(nVlrToleLi)
    oYMF:oDadosEnv:cValorFinc := CVALTOCHAR(nVlrFinanc)
    oYMF:oDadosEnv:cValorTitA := CVALTOCHAR(nVlrTitAtr) 
    oYMF:oDadosEnv:oCliente   := oCliente  

    oRet := oYMF:Executar()
EndIf  

Return oRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdXTratYMF  ºAutor  ³Vendas Clientes     º Data ³  11/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o Intellector para validar da analise de credito.		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oRetorno   - Retorno do Intellector (Tools).					 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRet - Com o retorno esperado pelo FrontLoja e TeleVenda.	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaCRD				               	                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdXTratYMF(oRetorno)

Local aRet := {} 

If ValType(oRetorno) == "N"    
	Do Case
		Case oRetorno == -2
			aRet := {1												 ,;	//01 Nao aprovado
					STR0126										     ,;	//02 Titulo da janela         //"Retorno Intellector (Tools)"
					STR0127											 ,; //03 Mensagem ao usuario 	  //"Cliente não encontrado."	
		   			{0												 ,;	//04,01 Limite de credito
		   			0												 ,;	//04,02 Titulos em aberto
		  			""												 ,; //04,03 Contrato
		       		1} }                            				  	//04,04 Bloquead
		OtherWise
			aRet := {1												 ,;	//01 Nao aprovado
					STR0126										     ,;	//02 Titulo da janela        //"Retorno Intellector (Tools)"
					STR0128											 ,;	//03 Mensagem ao usuario     //"Não foi possivel executar o Web Service do Intellector."
		   			{0												 ,;	//04,01 Limite de credito
		   			0												 ,;	//04,02 Titulos em aberto
		  			""												 ,; //04,03 Contrato
		       		1} }                            				  	//04,04 Bloquead
	EndCase   
Else
	If oRetorno:lAprovado  
		aRet := {0							,;	//01 Aprovado
				"" 							,;	//02 Titulo da janela
				""							,;	//03 Mensagem ao usuario
            	{oRetorno:nValLimite		,;	//04 Limite de credito
              	0							,;	//05 Titulos em aberto
              	""							,;	//06 Contrato
              	0 } }                         	//07 Liberado
	Else
		aRet := {1							,;	//01 Nao aprovado
				STR0129						,;	//02 Titulo da janela 			//"Credito não Aprovado."
				oRetorno:cMotBloq			,;	//03 Mensagem ao usuario
       			{oRetorno:nValLimite		,;	//04,01 Limite de credito
       			0							,;	//04,02 Titulos em aberto
       			""							,;  //04,03 Contrato
           		1} }                            //04,04 Bloquead	
	EndIf	
EndIf	

Return aRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CrdXTitAtr  ºAutor³Vendas Clientes     º Data ³  11/12/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor dos titulos em atrazo de um cliente.		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ cCliLoja: Cliente + Loja                                    º±±
±±³          ³ dData   : Data do Movimento a Receber - Default dDataBase   º±±
±±³          ³ nMoeda  : Moeda do Saldo Bancario - Defa 1                  º±±
±±³          ³ lMovSE5 : Se .T. considera o saldo do SE5 - Defa .T.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³nSaldo - Valor total em atraso.		'					   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaCRD                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CrdXTitAtr(cCliLoja,dData,nMoeda,lMovSE5)

Local aArea     := { Alias() , IndexOrd() , Recno() }
Local aAreaSE1  := { SE1->(IndexOrd()), SE1->(Recno()) }
Local bCondSE1
Local nSaldo    := 0
Local nTamCli   := len(Criavar("A1_COD"))
Local nTamLoja  := len(Criavar("A1_LOJA"))
Local cCliente  := SubStr(cCliLoja,1,nTamCli)
Local cLoja     := SubStr(cCliLoja,nTamCli+1,nTamLoja)
Local nSaldoTit := 0

// Quando eh chamada do Excel, estas variaveis estao em branco
IF Empty(MVABATIM) .Or.;
	Empty(MV_CRNEG) .Or.;
	Empty(MVRECANT)
	CriaTipos()
Endif
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Testa os parametros vindos do Excel                  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMoeda      := If(Empty(nMoeda),1,nMoeda)
dData       := If(Empty(dData),dDataBase,dData)
If ( ValType(nMoeda) == "C" )
	nMoeda      := Val(nMoeda)
EndIf
dData       := DataWindow(dData)
lMovSE5     := BoolWindow(lMovSe5)

dbSelectArea("SE1")
dbSetOrder(2)
dbSeek(xFilial()+cCliente+cLoja)
If ( !Empty(cLoja) )
	bCondSE1  := {|| !Eof() .And. xFilial() == SE1->E1_FILIAL .And.;
		cCliente == SE1->E1_CLIENTE .And.;
		cLoja    == SE1->E1_LOJA }
Else
	bCondSE1  := {|| !Eof() .And. xFilial() == SE1->E1_FILIAL .And.;
		cCliente == SE1->E1_CLIENTE }
EndIf
While ( Eval(bCondSe1) )
	If ( SE1->E1_EMISSAO <= dData .And. ;
			!SE1->E1_TIPO $ MVPROVIS+"/"+MVABATIM .And.;
			((!Empty(SE1->E1_FATURA).And.;
			Substr(SE1->E1_FATURA,1,6)=="NOTFAT" ) .Or.;
			(!Empty(SE1->E1_FATURA) .And.;
			Substr(SE1->E1_FATURA,1,6)!="NOTFAT" .And.;
			SE1->E1_DTFATUR > dData ) .Or.;
			Empty(SE1->E1_FATURA)) )
		If (!SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
			If ( !lMovSE5 )
				If SE1->E1_SALDO > 0 .AND. SE1->E1_VENCTO < dDatabase 
					nSaldo += xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dData)
					nSaldo -= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dData,SE1->E1_CLIENTE)
				Endif	
			Else
				If SE1->E1_VENCTO < dDatabase 
					nSaldoTit := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,nMoeda,,dData,SE1->E1_LOJA)
					If nSaldoTit > 0
						nSaldoTit -= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dData,SE1->E1_CLIENTE)
					Endif
					nSaldo += nSaldoTit
				EndIf
			EndIf
		Else   
			If SE1->E1_VENCTO < dDatabase 
				If ( !lMovSE5  )
					nSaldo -= SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,nMoeda,,dData,SE1->E1_LOJA)
				Else
					nSaldo -= xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dData)
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea("SE1")
	dbSkip()
EndDo
dbSelectArea("SE1")
dbSetOrder(aAreaSE1[1])
dbGoto(aAreaSE1[2])
dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoto(aArea[3])
Return	nSaldo





