#INCLUDE "CRDA010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDDEF.CH"

// Uso da consulta de titulos baixados
// -----------------------------------
#DEFINE QTDETITULOS	1
#DEFINE MOEDATIT	2
#DEFINE VALORTIT	3
#DEFINE VALORREAIS	4
// -----------------------------------
                                    
Static nObjFAnt		:= 0
Static lMvLjIntFS 	:= GetRpoRelease("R5") .AND. SuperGetMV("MV_LJINTFS",,.F.) .AND. IIF(FindFunction("LjUpd90Ok"),LjUpd90Ok(),.F.) //Verifica parâmetro que verifica se o modulo sigaloja esta integrado com o Financial Services
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDA010   ºAutor  ³Frank Zwarg Fuga    º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro do cliente com dados relacionados ao perfil        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Analise de creditos                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMachima       ³04/07/05³081261³Validar se o indice 2 dos arquivos MA9, º±±
±±º              ³        ³      ³MAA, MAB, MAC e MAE foram criados. Uti- º±±
±±º              ³        ³      ³lizados estes indices para opcao de vi- º±±
±±º              ³        ³      ³sualizacao. Substituicao das strings fi-º±±
±±º              ³        ³      ³xas. Criacao do PE CRDLIBCR para customiº±±
±±º              ³        ³      ³zacao de botoes da toolbar. Mostrar a   º±±
±±º              ³        ³      ³data de LC na tela de bloqueio.         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Geronimo      ³Geronimo³FNC   ³ Para atender a integridade referencial º±±
±±³              ³        ³002793³ alterada a sequencia de gravacao de    º±±
±±³              ³        ³      ³ tabelas e tambem melhorado o uso das   º±±
±±³              ³        ³      ³ estrutura begin/endtranastion para     º±±
±±³              ³        ³      ³ elasenvolverem realmente uma transação º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMachima       ³17/10/05³087714³Acerto na consulta de credito dos valo- º±±
±±º				 ³		  ³		 ³res limite utilizado e disponivel quandoº±±
±±º				 ³		  ³		 ³o endividamento eh global(MA7_TPCRED=2) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºA.Veiga       ³29/03/06³Drog. ³Tratamento de campos de usuario no fol- º±±
±±º				 ³		  ³Moder-³der cartoes no cadastro do cliente.     º±±
±±º				 ³		  ³na    ³                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMachima       ³03/06/06³100947³Correcao para nao permitir que 2 ou maisº±±
±±º				 ³		  ³		 ³analistas avaliem o mesmo cliente		  º±±
±±º				 ³		  ³		 ³                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMarcio L      ³01/12/06³114487³Na exclusao de cliente verifica se o cliº±±
±±º				 ³		  ³		 ³ente sta cadastrado em algum arquivo    º±±
±±º				 ³		  ³		 ³relacionado.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q.    ³23/02/07³119542³Retirado ajuste de dicionário.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDanilo Calil  ³10/05/07³125879³Retirado o campo A1_USUARIO para ver10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºFelipe Raposo ³03/10/07³134017³Alterada a forma de controle de semaforoº±±
±±º              ³        ³      ³do arquivo SA1. Alem da tabela MAR, eh  º±±
±±º              ³        ³      ³utilizado um arquivo texto.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA010()

Private aRotina :=	MenuDef()

Private cCadastro := STR0006 //"Cadastro do cliente com dados relacionados ao perfil"

mBrowse( 06, 01, 22, 75, "SA1" )

Return                                    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local lCRDMenu		:= ExistBlock("CrdMenu")
	Local nCont     	:= 0                          // Contador de for
	Local aNewRotina	:= {}								// Retorno do PE para adicionar no aRotina
	Local aRotina	:= {{ STR0001	, "AxPesqui"	,0	,1	,0	,.F.}	,;	//"Pesquisar"
						{ STR0002	, "Crd010Man"	,0	,2	,0	,.T.}	,;	//"Visualizar"
						{ STR0003	, "Crd010Man"	,0	,3	,0	,.T.}	,;	//"Incluir"
						{ STR0004	, "Crd010Man"	,0	,4	,0	,.T.}	,;	//"Alterar"
						{ STR0005	, "Crd010Man"	,0	,0	,0	,.T.}	,;	//"Excluir"
						{ STR0141	,"Mata030Ref"	,0	,3	,0	,.T.}	}	//"Referencias"
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para acrescentar mais opcoes no aRotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lCRDMenu
	aNewRotina	:= ExecBlock("CrdMenu")
  	If ValType(aNewRotina) == "A"
  		For nCont := 1 To Len(aNewRotina)
	  		If Len(aNewRotina[nCont]) == 6	// Somente adiciona se o tamanho for compativel	a estrutura do aRotina
				aAdd(aRotina ,aNewRotina[nCont])
			EndIf
		Next nCont		  	
	EndIf
EndIf						

Return(aRotina)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010Man  ºAutor  ³Frank Zwarg Fuga    º Data ³  06/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao dos clientes com dados relacionados ao perfil.      º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR   ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna Caroline ³05/08/05³??????³Alterado indice do MA5, de pergunta paraº±±
±±º               ³        ³      ³questao                                 º±±
±±ºMarcos Roberto ³03/10/05³DELLA ³Alterado o titulo da tela quando for    º±±
±±º               ³        ³VIA   ³Visualizacao                            º±±
±±ºMarcos Roberto ³22/03/06³092433³Incluido query para fazer busca no MAI  º±±
±±º               ³        ³      ³e MA5                                   º±±
±±ºThiago Honorato|20/07/06³103678³Chama a funcao CRDXSetaVar() 		   º±±
±±º               ³        ³      ³(funcao que seta a variavel do tipo     º±±
±±º               ³        ³      ³Static criada em CRDXFUN)               º±±
±±ºConrado Q.     |05/02/07³115952³Montagem do aCols e aHeader adaptada    º±±
±±º               ³        ³      ³para a utilização do Walk-Thru          º±±
±±ºConrado Q      ³04/04/07³122711³Alterada a utilização da chamada        º±±
±±º               ³        ³      ³SubStr(cUsuario,7,15) por cUserName     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd010Man(cAlias, nReg, nOpcx, lConfirma)
Local oDlg
Local aSize   	:= {}
Local aInfo    	:= {}
Local aInfo1   	:= {}
Local aObjects 	:= {}
Local aPosObj  	:= {}
Local aObjectsT	:= {}                            
Local nOpcoes  	:= 0
Local nOpc     	:= 0
Local aCriaAcols:= {}
Local aMost    	:= {}                     
Local aStruct  	:= {}
Local cArqDbf  	:= CriaTrab(NIL,.F.)
Local cArqNtx  	:= ""
Local nX    	:= 0
Local nSaveSx8 	:= GetSx8Len()
Local cAlias2	:= ""
Local aRetReg   := {}
Local aRetCol   := {}
Local cCampo1 	:= ""
Local cCampo2  	:= ""
Local cCRLF    	:= Chr(13) + Chr(10)     	// Pula linha 
Local bValDelCar:= { || CRDValDelCar() } 
Local bValDelDep:= { || CRDValDelDep() }    
Local cX3_Valid := "" 							// Variavel utilizada para tratameto do valid dos campos

//---EnchoiceBar
Local aButtons 	:= {}

Local cMV_QUEST := SuperGetMV("MV_QUEST")	//Questionario ativo.    
Local cAliasMAI	:= "QRYMAI"					//Alias da tabela MAI 
Local cAliasMA5	:= "QRYMA5"					//Alias da tabela MA5
#IFDEF TOP
Local cQuery  	:= ""              			//Query
#ENDIF
Local aStruMAI	:= {}						//Estrutura da tabela MAI 
Local aStruMA5	:= {}						//Estrutura da tabela MA5
Local lQueryMAI	:= .F.						//Informa se utilizou a query na tabela MAI
Local lQueryMA5	:= .F.						//Informa se utilizou a query na tabela MA5
Local nRecMAR010:= 0                        //Recno do registro gerado no MAR pelo CRDA010
Local cSeek		:= ""
Local cWhile	:= ""
Local aNoFields	:= {}
Local nArqSem   := 0                        //Numero do arquivo temporario criado como semaforo.
Local cArqSem   := ""                       //Arquivo utilizado como semaforo do registro.
Local oTempTable:= Nil							//Objeto tabela temporaria

Default lConfirma := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o indice 2 dos arquivos MA9, MAA, MAB, MAC e MAE ³
//³existem no dicionario de dados. Estes indices sao utilizados ³
//³na busca destes dados pelo codigo do cliente                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Crd010VldInd()
   //"Favor criar o indice 2 nos arquivos MA9, MAA, MAB, MAC e MAE, formado pelos campos Filial+Cod. Cliente+Loja"    
   //"Entre em contato com o Administrador do Sistema."
   MsgAlert(STR0134 + cCRLF + STR0135)
   Return (.F.)
Endif

If nOpcx == 2
	cCadastro := STR0006 //"Cadastro do cliente com dados relacionados ao perfil
ElseIf nOpcx == 3
   aRotina[3][4] := 3
   cCadastro := STR0007   //"Cadastro do cliente com dados relacionados ao perfil - Incluir"
   INCLUI := .T.
ElseIf nOpcx == 4
   cCadastro := STR0020   //"Cadastro do cliente com dados relacionados ao perfil - Alteracao"
   ALTERA := .T.
   // Criacao de um semaforo a pedido da Dadalto
   If !Softlock(cAlias) .OR. !CRDSEMAFORO("CRDA010", Recno(), @nRecMAR010, @nArqSem,;
					@cArqSem)  
      SA1->(MsUnLock())
   	  Return
   Endif
Endif

// Titulos dos Folders pais
Private aTitles1 := { 	STR0008	,; //"Ficha cadastral"
                    	STR0009	,; //"Socio-Economico-Cultural"
                    	STR0010	,; //"Dependentes"
                    	STR0011	,; //"Cartoes"
                    	STR0012	}  //"Doc.Entregues"

// Titulos dos Folders da Ficha cadastral
Private aTitles2 := { 	STR0013	,; //"Compl.ficha"
                    	STR0014	,; //"Ref. trabalhos"
                    	STR0015	,; //"Ref. cartoes"
                    	STR0016	,; //"Ref. bancarias"
                    	STR0017 }  //"Ref. pessoais"

Private oFolder1	:= Nil 	// Folder principal
Private oFolder2	:= Nil 	// Folder da ficha cadastral
Private oEnchoice1	:= Nil 	// Cadastro do cliente padrao - SA1
Private oEnchoice2	:= Nil 	// Cadastro do complemento da ficha cadastral - MA7

Private aHeader	:= {} // Para montagem
Private aCols	:= {}
Private aHeader1:= {} // Referencias trabalhos
Private aCols1	:= {}
Private aColsR1	:= {}
Private oGetD1	:= Nil
Private aHeader2:= {} // Referencias cartoes
Private aCols2	:= {}
Private aColsR2	:= {}
Private oGetD2	:= Nil
Private aHeader3:= {} // Referencias bancarias
Private aCols3	:= {}
Private aColsR3	:= {}
Private oGetD3	:= Nil
Private aHeader4:= {} // Referencias pessoais
Private aCols4	:= {}
Private aColsR4	:= {}
Private oGetD4	:= Nil
Private aHeader5:= {} // Dependentes
Private aCols5	:= {}
Private aColsR5	:= {}
Private oGetD5	:= Nil
Private aHeader6:= {} // Cartoes
Private aCols6	:= {}
Private aColsR6	:= {}
Private oGetD6	:= Nil
Private aHeader7:= {} // Documentos entregues
Private aCols7	:= {}
Private aColsR7	:= {}
Private oGetD7	:= Nil
Private aHeader8:= {} // Dados Socio economico cultural
Private aCols8	:= {}
Private aColsR8	:= {}
Private oGetD8	:= Nil
Private lWhen	:= nOpcx = 3 .OR. nOpcx = 4 // Editando
Private aGets[0]
Private aGets1[0]
Private aGets2[0]
Private aTela[0][0]
Private aTela1[0][0]
Private aTela2[0][0]    
Private nOpcVal := nOpcx


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara a EnchoiceBar com os botoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons, {"HISTORIC" , {|| HABCOM()}     , STR0022 }) // Historico 
aAdd(aButtons, {"BUDGET"   , {|| CRM010_003()} , STR0023 }) // Titulos em aberto  
aAdd(aButtons, {"BUDGETY"  , {|| CRC010_014()} , STR0040 }) // Titulos pagos

If !( Upper( Trim( FunName() ) ) $ "CRDA080/CRDA180") //No programa de Liberacao, o MA7 ja e posicionado
	aAdd(aButtons, {"POSCLI"   , {|| CRM010_006(2)}, STR0031 })  // Analise de credito
Endif

aAdd(aButtons, {"PESQUISA" , {|| CRDConsTEF()} , STR0037 }) //Consulta TEF

If ExistBlock("CRDCRIABUT")
	aButtons := ExecBlock("CRDCRIABUT",.F.,.F.,{aButtons})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada de templates para gerar novo numero de cartao ³
//³quando o cartao e cancelado  	                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CRDCRIABUT")
	aButtons := ExecTemplate("CRDCRIABUT",.F.,.F.,{aButtons})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica as coordenadas para redimensionamento de x e y³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects,  { 1.50, 1.50, .T., .T. } )
aAdd( aObjects,  { 0.75, 0.75, .T., .T. } ) 
aAdd( aObjects,  { 7.00, 7.00, .T., .T. } ) 
aAdd( aObjects,  { 0.75, 0.75, .T., .T. } ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica o tamanho maximo dos objetos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjectsT, { 1.50, 1.50, .T., .T., .T. } )
aAdd( aObjectsT, { 0.10, 0.10, .T., .T., .T. } ) 
aAdd( aObjectsT, { 7.35, 7.35, .T., .T., .T. } ) 
aAdd( aObjectsT, { 1.05, 1.05, .T., .T., .T. } )

aSize     := MsAdvSize(.T.,.F.)

aInfo     := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
aInfo1    := { aSize[1], aSize[2], aSize[3], aSize[4], 4, 10 }

aPosObj   := MsObjSize( aInfo,  aObjects , .T., .F. )
aPosObjT  := MsObjSize( aInfo,  aObjectsT, .T., .F. )
aPosObj1  := MsObjSize( aInfo1, aObjects , .T., .F. )
aPosObjT1 := MsObjSize( aInfo1, aObjectsT, .T., .F. )

If nOpcx <> 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionar nos dados complementares quando nao for inclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea("MA7")
   DbSetOrder(1)
   DbSeek(xFilial("MA7")+SA1->A1_COD+SA1->A1_LOJA)

Endif

RegToMemory( "SA1", If(nOpcx==3, .T., .F. ), .F. )
RegToMemory( "MA7", If(nOpcx==3, .T., .F. ) )

DbSelectArea("SX3")
DbSetOrder(1)
For nX := 1 to 2
	cAlias2 := If(nX==1,"MA7","SA1")
   	DbSeek(cAlias2)
   	While !Eof() .AND. X3_ARQUIVO == cAlias2
    	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. X3_VISUAL == "V" .AND. X3_CONTEXT = "R"     
			_CPO := X3_CAMPO
			IF Empty( M->&_CPO )
				IF x3_tipo == "C"
					M->&_CPO := ALLTRIM(SX3->X3_RELACAO)
				ElseIf x3_tipo == "N"
					M->&_CPO := VAL(SX3->X3_RELACAO)
				ElseIf x3_tipo == "D"
					M->&_CPO := CTOD(SX3->X3_RELACAO)
				ElseIf nOpcx <> 2 .OR. nOpcx <> 5
					IF SX3->X3_RELACAO $ "T/t"
						M->&_CPO := .T.
					ELSE
						M->&_CPO := .F.
					Endif
				Endif
			Endif
		Endif             
    	dbSkip()
	End
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Referencia de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)

For nX := 1 to 2
   
   	cAlias2 := If(nX==1,"MA8","MAD")
   	DbSeek(cAlias2)

	While !Eof() .AND. X3_ARQUIVO == cAlias2

    	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .OR.; 
      			alltrim(X3_CAMPO) == "MA8_FILIAL" .OR.; 
      			alltrim(X3_CAMPO) == "MA8_CODCLI" .OR.;
         		alltrim(X3_CAMPO) == "MA8_LOJA" 
         		
			aAdd( aStruct, { X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL } )
      	
      	Endif
      	dbSkip()
	End
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos relativos ao Walk-Thru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aStruct, {"MA8_REC_WT","N",10,0} )
aAdd( aStruct, {"MA8_ALI_WT","C",3,0} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar a integridade do temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Criacao da tabela temporaria
oTempTable := LjCrTmpTbl("TRB", aStruct)

IndRegua("TRB",cArqDbf,"MA8_FILIAL+MA8_CODCLI+MA8_LOJA",,,STR0045)    //"Selecionando"

If !INCLUI

	DbSelectArea("MA8")
   	DbSetOrder(3)
   	DbSeek( xFilial("MA8") + SA1->A1_COD + SA1->A1_LOJA )
   
	While !Eof() .AND. MA8_FILIAL+MA8_CODCLI+MA8_LOJA ==;
      					xFilial("MA8")+SA1->A1_COD+SA1->A1_LOJA
   
		DbSelectArea("MAD")
      	DbSetOrder(1)
      	DbSeek( xFilial("MAD") + MA8->MA8_CODEND )
   
      	DbSelectArea("TRB")
      	RecLock("TRB",.T.)

      	For nX := 1 to Len(aStruct)
   
        	If substr(aStruct[nX][01],1,3) == "MA8"

            	cCampo1 := "TRB->"+aStruct[nX][01]
            	cCampo2 := "MA8->"+aStruct[nX][01]   

            	DbSelectArea("SX3")
				DbSetOrder(2) 
				DbSeek( aStruct[nX][01] )
				If X3_CONTEXT == "V"
					&(cCampo1) := Criavar(AllTrim(X3_CAMPO))
				ElseIf !IsHeadRec( aStruct[nX][01] ) .AND. !IsHeadAlias( aStruct[nX][01] )
	            	&(cCampo1) := &(cCampo2)
				Endif
         	Else
            	If !MAD->(EOF())
               		cCampo1 := "TRB->"+aStruct[nX][01]
               		cCampo2 := "MAD->"+aStruct[nX][01]   
	
	            	DbSelectArea("SX3")
					DbSetOrder(2) 
					DbSeek( aStruct[nX][01] )
					If  X3_CONTEXT == "V"               
						&(cCampo1) := Criavar(AllTrim(X3_CAMPO))					
					Else
    	           		&(cCampo1) := &(cCampo2)
        	    	Endif
            	Endif
         	Endif
      	Next nX
      	MsUnlock()
      	DbSelectArea("MA8")
      	dbSkip()
   	End
      
Endif

aHeader1   := {}

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aStruct)

   If aStruct[nX][01] <> "MA8_FILIAL" .AND.;
      aStruct[nX][01] <> "MA8_CODCLI" .AND.;
      aStruct[nX][01] <> "MA8_LOJA"   .AND.;
      aStruct[nX][01] <> "MA8_CODEND" .AND.;  
      aStruct[nX][01] <> "MAD_FILIAL" .AND.;      
      aStruct[nX][01] <> "MAD_CODCLI" .AND.;
      aStruct[nX][01] <> "MAD_LOJA"   .AND.;
      aStruct[nX][01] <> "MAD_CODEND"      

      DbSeek(aStruct[nX][01])

      If !Eof() .AND. X3USO(x3_usado) .AND. cNivel >= x3_nivel
      
         aAdd(aHeader1,{ 	TRIM(x3titulo())	, X3_CAMPO		, X3_PICTURE, X3_TAMANHO	,;
         					X3_DECIMAL			, X3_VALID		, X3_USADO	, X3_TIPO		,;
         					X3_F3				, X3_CONTEXT	, X3_CBOX	, X3_RELACAO	,;
         					".T." } )

      Endif
   
   Endif

   dbSkip()

Next nX    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona Codigo do Endereco na getdados (visual), para validar no momento da gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetOrder(2))
If SX3->(DbSeek( "MA8_CODEND" ))
	aAdd(aHeader1,{	TRIM(x3titulo())	,	SX3->X3_CAMPO	, 	SX3->X3_PICTURE	, SX3->X3_TAMANHO	,;
					SX3->X3_DECIMAL		,	SX3->X3_VALID	,	SX3->X3_USADO	, SX3->X3_TIPO		,;
					SX3->X3_F3			,	SX3->X3_CONTEXT	,	SX3->X3_CBOX	, SX3->X3_RELACAO	,;
					".F."} )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos relativos ao Walk-Thru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AdHeadRec( "MA8", aHeader1 )

If nOpcx == 3

	aRetCol := {}
   	aAdd(aRetCol, {})

   	For nX := 1 to Len(aHeader1)
   		If IsHeadRec( aHeader1[nX, 2] )
			aAdd(aRetCol[Len(aRetCol)], 0)   			   		
   		ElseIf IsHeadAlias( aHeader1[nX, 2] )
			aAdd(aRetCol[Len(aRetCol)], "MA8")   			
   		Else
	    	aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader1[nX, 2]))
	    EndIf
   	Next nX

   	aAdd(aRetCol[Len(aRetCol)], .F.)

Else             
  
  	aRetCol := {}
   	aRetReg := {}

   	DbSelectArea("TRB")
   	DbSetOrder(1)        
   	dbGotop()
   
   	While !Eof()        

    	aAdd(aRetCol, {})

      	For nX := 1 to Len(aHeader1)
      		If IsHeadRec( aHeader1[nX, 2] )
				aAdd(aRetCol[Len(aRetCol)], TRB->(Recno()))
      		ElseIf IsHeadAlias( aHeader1[nX, 2] )
				aAdd(aRetCol[Len(aRetCol)], "MA8")
      		Else
	        	aAdd(aRetCol[Len(aRetCol)], FieldGet(FieldPos(aHeader1[nX, 2])))
			EndIf
      	Next nX

      	aAdd(aRetCol[Len(aRetCol)], .F.)
      	aAdd(aRetReg, RecNo())

      	dbSkip()

   	End

Endif

DbSelectArea("SX3")
DbSetOrder(1)   
aCols1     := aRetCol
aColsR1    := aRetReg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Referencia cartoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MA9") + M->A1_COD + M->A1_LOJA
cWhile		:= "MA9->MA9_FILIAL+MA9->MA9_CODCLI+MA9->MA9_LOJA"
aNoFields	:= { "MA9_CODCLI", "MA9_LOJA" }

CRD010Monta( nOpcx, "MA9", cSeek, cWhile, aNoFields, aHeader2, aCols2, aColsR2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Referencia bancaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MAA") + M->A1_COD + M->A1_LOJA
cWhile		:= "MAA->MAA_FILIAL+MAA->MAA_CODCLI+MAA->MAA_LOJA"
aNoFields	:= { "MAA_CODCLI", "MAA_LOJA" }

CRD010Monta( nOpcx, "MAA", cSeek, cWhile, aNoFields, aHeader3, aCols3, aColsR3 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Referencia pessoal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MAB")+M->A1_COD + M->A1_LOJA
cWhile		:= "MAB->MAB_FILIAL + MAB->MAB_CODCLI + MAB->MAB_LOJA"
aNoFields	:= { "MAB_CODCLI", "MAB_LOJA" }

CRD010Monta( nOpcx, "MAB", cSeek, cWhile, aNoFields, aHeader4, aCols4, aColsR4 )

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dependentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MAC")+M->A1_COD + M->A1_LOJA
cWhile		:= "MAC->MAC_FILIAL + MAC->MAC_CODCLI + MAC->MAC_LOJA"
aNoFields	:= { "MAC_CODCLI", "MAC_LOJA" }

CRD010Monta( nOpcx, "MAC", cSeek, cWhile, aNoFields, aHeader5, aCols5, aColsR5 )

//ÚÄÄÄÄÄÄÄ¿
//³Cartões³
//ÀÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MA6")+M->A1_COD + M->A1_LOJA
cWhile		:= "MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA"
aNoFields	:= { "MA6_CODCLI", "MA6_LOJA" }

CRD010Monta( nOpcx, "MA6", cSeek, cWhile, aNoFields, aHeader6, aCols6, aColsR6 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir TPL de Drogaria chama a funcao de validacao do campo de ³
//³ situacao do cartao                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len( aHeader6 )
	cX3_Valid := aHeader6[nX][6]
	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		If Alltrim( aHeader6[nX][2] ) == "MA6_SITUA"
			aHeader6[nX][6] := cX3_Valid + If(!Empty(cX3_Valid),".AND.","") + "T_DroVldMA6C()"
		Endif
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
cSeek		:= xFilial("MAE")+M->A1_COD + M->A1_LOJA
cWhile		:= "MAE->MAE_FILIAL + MAE->MAE_CODCLI + MAE->MAE_LOJA"
aNoFields	:= { "MAE_CODCLI", "MAE_LOJA" }

CRD010Monta( nOpcx, "MAE", cSeek, cWhile, aNoFields, aHeader7, aCols7, aColsR7 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Socios-Economicos-Culturais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("MAI")

While !Eof() .AND. X3_ARQUIVO == "MAI"

   IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL

      If Alltrim(X3_CAMPO) == "MAI_CODCLI" .OR. Alltrim(X3_CAMPO) == "MAI_LOJA"

         dbSkip()
         Loop

      Endif

      aAdd(aHeader8,{ 	TRIM(x3titulo())	, X3_CAMPO, X3_PICTURE	, X3_TAMANHO,;
      					X3_DECIMAL			, X3_VALID, X3_USADO	, X3_TIPO	,;
      					X3_F3				, X3_CONTEXT			, X3_CBOX	,;
      					X3_RELACAO			, ".T."} )

   Endif

   dbSkip()

End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos relativos ao Walk-Thru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AdHeadRec( "MA5", aHeader8 )

If nOpcx == 3
	aRetCol := {}
	aRetReg := {}
  
	DbSelectArea("MA5")
	DbSetOrder(2) // filial + questionario + pergunta
                             
	#IFDEF TOP   
		If TcSrvType()<>"AS/400"   
			cAliasMA5 	:= "QRYMA5"     
	    	lQueryMA5	:= .T.
	    
		    cQuery := "SELECT * "
		    cQuery += " FROM "
		    cQuery += RetSqlName("MA5")+ " MA5 "
		    cQuery += " WHERE "
		    cQuery += "MA5_FILIAL = '" + xFilial( "MA5" ) 	+"' AND "
		    cQuery += "MA5_QUEST  = '" + cMV_QUEST       	+"' AND "  
		    cQuery += "MA5.D_E_L_E_T_ = ' ' "
		    
		    aStruMA5  := MA5->(dbStruct())
	    
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMA5,.F.,.T.)   
			
			For nX := 1 To Len(aStruMA5)
				If aStruMA5[nX,2]<>"C"
					TcSetField(cAliasMA5,aStruMA5[nX,1],aStruMA5[nX,2],aStruMA5[nX,3],aStruMA5[nX,4])
				EndIf
			Next nX
		Else		
	#ENDIF	
			lQueryMA5	 := .F.
			cAliasMA5 := "MA5"
			DbSeek( xFilial("MA5") + cMV_QUEST )
	#IFDEF TOP
		EndIf
	#ENDIF

	If Eof()
		aRetCol := {}
		aAdd(aRetCol, {})
		For nX := 1 to +Len(aHeader8)
	      	If IsHeadRec( aHeader8[nX, 2] )
	      		aAdd(aRetCol[Len(aRetCol)], 0)
	      	ElseIf IsHeadAlias( aHeader8[nX, 2] )
	      		aAdd(aRetCol[Len(aRetCol)], "MA5")      	
	      	Else
				aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))
			EndIf
		Next nX
		aAdd(aRetCol[Len(aRetCol)], .F.)
	Else                                
		While !Eof() .AND. (cAliasMA5)->MA5_FILIAL+(cAliasMA5)->MA5_QUEST == xFilial("MA5")+cMV_QUEST
			aAdd(aRetCol, {})            
			For nX := 1 to Len(aHeader8)
				If aHeader8[nX, 10] == "V"
					If IsHeadRec( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], (cAliasMA5)->(Recno()))
					ElseIf IsHeadAlias( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], "MA5")
					ElseIf Alltrim(aHeader8[nX, 2]) == "MAI_DESCPE"
						aAdd(aRetCol[Len(aRetCol)], (cAliasMA5)->MA5_DESCR)
					Else
						aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))            
					Endif
				Else    
					If IsHeadRec( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], (aAliasMA5)->(Recno()))
					ElseIf IsHeadAlias( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], "MA5")
					ElseIf alltrim(aHeader8[nX, 2]) == "MAI_PERG"
						aAdd(aRetCol[Len(aRetCol)], (cAliasMA5)->MA5_PERG)
					ElseIf alltrim(aHeader8[nX, 2]) == "MAI_QUEST"
						aAdd(aRetCol[Len(aRetCol)], SuperGetMV("MV_QUEST"))
					Else
						aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))            
					Endif               
				Endif	
			Next nX

			aAdd(aRetCol[Len(aRetCol)], .F.)
			aAdd(aRetReg, RecNo())

			dbSkip()
		End
	Endif

	If lQueryMA5
      DbSelectArea(cAliasMA5)
	  dbCloseArea()      
	  DbSelectArea("MA5")
	EndIf
	
	aCols8     := aRetCol
	aColsR8    := aRetReg
Else 
   	aRetCol := {}
   	aRetReg := {}
	
	DbSelectArea("MAI")
   	DbSetOrder(1)
   
	#IFDEF TOP   
		If TcSrvType()<>"AS/400"   
	    	cAliasMAI 	:= "QRYMAI"     
	    	lQueryMAI	:= .T.
	    
		    cQuery := "SELECT * "
		    cQuery += " FROM "
		    cQuery += RetSqlName("MAI")+ " MAI "
		    cQuery += " WHERE "
		    
		    cQuery += "MAI_FILIAL = '" + xFilial( "MAI" ) 	+"' AND "
		    cQuery += "MAI_CODCLI = '" + M->A1_COD        	+"' AND " 
		    cQuery += "MAI_LOJA   = '" + M->A1_LOJA       	+"' AND " 
		    cQuery += "MAI_QUEST  = '" + cMV_QUEST       	+"' AND "  
		    
		    cQuery += "MAI.D_E_L_E_T_ = ' ' "
		    
		    aStruMAI  := MAI->(dbStruct())
	    
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAI,.F.,.T.)   
			
			For nX := 1 To Len(aStruMAI)
				If aStruMAI[nX,2]<>"C"
					TcSetField(cAliasMAI,aStruMAI[nX,1],aStruMAI[nX,2],aStruMAI[nX,3],aStruMAI[nX,4])
				EndIf
			Next nX
		Else		
	#ENDIF	
			lQueryMAI	 := .F.
			cAliasMAI := "MAI"
			DbSeek( xFilial("MAI") + M->A1_COD + M->A1_LOJA+cMV_QUEST )                      
	#IFDEF TOP
		EndIf
	#ENDIF
	
	If Eof()          
		aRetCol := {}
		If nOpcx <> 4
			aAdd(aRetCol, {})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for alteracao e nao haja nenhuma ocorrencia dos dados socio-economicos³
			//³Criar somente uma linha no acols                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(aHeader8)
				If IsHeadRec( aHeader8[nX, 2] )
					aAdd(aRetCol[Len(aRetCol)], 0)
	      		ElseIf IsHeadAlias( aHeader8[nX, 2] )
	      			aAdd(aRetCol[Len(aRetCol)], "MA5")      	
				Else
					aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))
				EndIf
			Next nX
			aAdd(aRetCol[Len(aRetCol)], .F.)
		Else                                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for uma alteracao e caso haja ocorrencias dos dados socio-economicos³
			//³Criar o acols de acordo com as regras da inclusao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("MA5")
			DbSetOrder(2)
			DbSeek( xFilial("MA5") + SuperGetMV("MV_QUEST") )

			If Eof()
				aRetCol := {}
				aAdd(aRetCol, {})
				For nX := 1 To Len(aHeader8)
					If IsHeadRec( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], 0)
					ElseIf IsHeadAlias( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], "MA5")      	
					Else					            
						aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))
					EndIf
				Next nX
				aAdd(aRetCol[Len(aRetCol)], .F.)
			Else                                
				While !Eof() .AND. MA5_FILIAL+MA5_QUEST == xFilial("MA5")+SuperGetMV("MV_QUEST")
					aAdd(aRetCol, {})            
					For nX := 1 to Len(aHeader8)
						If aHeader8[nX, 10] == "V"
							If IsHeadRec( aHeader8[nX, 2] )
								aAdd(aRetCol[Len(aRetCol)], MA5->(Recno()))
							ElseIf IsHeadAlias( aHeader8[nX, 2] )
								aAdd(aRetCol[Len(aRetCol)], "MA5")      	
							ElseIf alltrim(aHeader8[nX, 2]) == "MAI_DESCPE"
	                        	aAdd(aRetCol[Len(aRetCol)], MA5->MA5_DESCR)
							Else
								aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))            
							Endif
						Else    
							If IsHeadRec( aHeader8[nX, 2] )
								aAdd(aRetCol[Len(aRetCol)], MA5->(Recno()))
							ElseIf IsHeadAlias( aHeader8[nX, 2] )
								aAdd(aRetCol[Len(aRetCol)], "MA5")      	
							ElseIf alltrim(aHeader8[nX, 2]) == "MAI_DESCPE"
								aAdd(aRetCol[Len(aRetCol)], MA5->MA5_DESCR)
							ElseIf alltrim(aHeader8[nX, 2]) == "MAI_PERG"
								aAdd(aRetCol[Len(aRetCol)], MA5->MA5_PERG)
							ElseIf alltrim(aHeader8[nX, 2]) == "MAI_QUEST"
								aAdd(aRetCol[Len(aRetCol)], SuperGetMV("MV_QUEST"))
							Else
								aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))            
							Endif               
						Endif	
					Next nX
 
					aAdd(aRetCol[Len(aRetCol)], .F.)
					aAdd(aRetReg, RecNo())
					dbSkip()
				End     
			Endif
		Endif
	Else
		While	!Eof() .AND.;
				(cAliasMAI)->MAI_FILIAL+(cAliasMAI)->MAI_CODCLI+(cAliasMAI)->MAI_LOJA+(cAliasMAI)->MAI_QUEST ==; 
				xFilial("MAI")+M->A1_COD+M->A1_LOJA+cMV_QUEST       	 
			aAdd(aRetCol, {})

			For nX := 1 to Len(aHeader8)
				If aHeader8[nX, 10] == "V"
					If IsHeadRec( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], MA5->(Recno()))
					ElseIf IsHeadAlias( aHeader8[nX, 2] )
						aAdd(aRetCol[Len(aRetCol)], "MA5")      	
					ElseIf aHeader8[nX, 2] == "MAI_DESCPE" 
						aAdd(aRetCol[Len(aRetCol)], posicione("MA5",2,xFilial("MA5")+;
							(cAliasMAI)->MAI_QUEST+(cAliasMAI)->MAI_PERG,"MA5_DESCR") ) 
					ElseIf aHeader8[nX, 2] == "MAI_DESCRE" .AND. !Empty("MAI_RESP")
						aAdd(aRetCol[Len(aRetCol)], posicione("MAJ",1,xFilial("MAJ")+;
							(cAliasMAI)->MAI_QUEST+(cAliasMAI)->MAI_PERG+(cAliasMAI)->MAI_RESP,"MAJ_DESCR") )
					Else
						aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeader8[nX, 2]))
					Endif
				Else    
					aAdd(aRetCol[Len(aRetCol)], &(aHeader8[nX, 2]) )
				Endif	
			Next nX
			aAdd(aRetCol[Len(aRetCol)], .F.)
			aAdd(aRetReg, RecNo())
			dbSkip()
		End
	Endif    

	aCols8     := aRetCol
	aColsR8    := aRetReg
   	
	If lQueryMAI	
		DbSelectArea(cAliasMAI)
		dbCloseArea()          	
		DbSelectArea("MAI")
	EndIf
Endif

                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criar o array com os campos que serao exibidos no complemento da ficha cadastral³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("MA7")

While X3_ARQUIVO == "MA7"

   If allTrim(X3_CAMPO) <> "MA7_FILIAL" .AND. alltrim(X3_CAMPO) <> "MA7_CODCLI" ;
      .AND. alltrim(X3_CAMPO) <> "MA7_LOJA" .AND. X3USO(X3_USADO) .AND. ;
      cNivel >= X3_NIVEL

      aAdd(aMost,X3_CAMPO)

   Endif

   dbSkip()

End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as Opcoes de Edicao das Getdados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcoes := If( lWhen, GD_INSERT + GD_DELETE + GD_UPDATE, 0 )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL                   
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criacao dos folders ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oFolder1 := TFolder():New( aPosObj[1,1], aPosObj[1,2],;
       aTitles1, {"HEADER"}, oDlg, , , , .T., .F., aPosObjT[4,3],;
       aPosObjT[4,4]+aPosObjT[3,4]+aPosObjT[2,4]+aPosObjT[1,4], )
       
       oFolder1:bSetOption := { |nFolder| nObjFAnt := IIf(nObjFAnt==0,1,nObjFAnt),CRC010_015(nFolder,oFolder1:nOption,nOpcx)} 
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao dos objetos a pasta ficha cadastral do folder³
		//³Enchoice da Ficha Cadastral                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oEnchoice1:=MsMGet():New("SA1" , nReg, nOpcx,,,,,;
       {01,03,aPosObj1[3,1]-5,aPosObjT1[3,3]+3},,,,,,oFolder1:aDialogs[1],,.F.,,)
       aGets1 := aclone(oEnchoice1:aGets)
       aTela1 := aclone(oEnchoice1:aTela)
       aGets := {}
       aTela := {}
                                                                                   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados - dados-socio-economicos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD8:= MSNEWGetDados():New(1, 3, aPosObj[3,3]-12,aPosObj[3,4]-4 ,;
       GD_UPDATE ,"CRM010_008('8','L') .AND. Crd010Ques(nOpcVal)" ,"CRM010_008('8','T')" , , , , , , , , oFolder1:aDialogs[2] ,aHeader8 ,aCols8)       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados - dependentes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD5:= MSNEWGetDados():New(1, 3, aPosObj[3,3]-12,aPosObj[3,4]-4 ,;
       nOpcoes ,"CRM010_008('5','L')" ,"CRM010_008('5','T')" , , , , , , , bValDelDep , oFolder1:aDialogs[3] ,aHeader5 ,aCols5)       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados - cartoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD6:= MSNEWGetDados():New(1, 3, aPosObj[3,3]-12,aPosObj[3,4]-4 ,;
       nOpcoes ,"CRM010_008('6','L') .AND. Crd010ValCar(nOpcVal)" ,"CRM010_008('6','T')" , , , , , , , bValDelCar , oFolder1:aDialogs[4] ,aHeader6 ,aCols6)       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados - documentos entregues³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD7:= MSNEWGetDados():New(1, 3, aPosObj[3,3]-12,aPosObj[3,4]-4 ,;
       nOpcoes ,"CRM010_008('7','L')" ,"CRM010_008('7','T')" , , , , , , , , oFolder1:aDialogs[5] ,aHeader7 ,aCols7)       

                                                                                   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem dos folders complementos da ficha cadastral³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oFolder2 := TFolder():New( aPosObj1[3,1], aPosObj1[3,2],;
       aTitles2, {"HEADER"}, oFolder1:aDialogs[1], , , , .T., .F.,;
       aPosObjT1[3,3],aPosObjT1[3,4], )
       oFolder2:bSetOption := { |nFolder| nObjFAnt := IIf(nObjFAnt==0,1,nObjFAnt),CRC010_017(nFolder,oFolder2:nOption,nOpcx)} 
      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Enchoice da pasta complemento da ficha cadastral      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oEnchoice2:=MsMGet():New("MA7" , nReg, nOpcx,,,,aMost,;
       {01,01,aPosObjT1[3,4]-13,aPosObjT1[3,3]-3},,,,,,oFolder2:aDialogs[1],,.T.,,)
       aGets2 := aclone(oEnchoice2:aGets)
       aTela2 := aclone(oEnchoice2:aTela)
       aGets := {}
       aTela := {}
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados da Referencia de trabalho - Pasta Ficha cadastral³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD1:= MSNEWGetDados():New(1, 1, aPosObjT1[3,4]-13,aPosObjT1[3,3]-3 ,;
       nOpcoes ,"CRM010_008('1','L')" ,"CRM010_008('1','T')" , , , , , , , , oFolder2:aDialogs[2] ,aHeader1 ,aCols1)
       

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados da Referencia cartoes     - Pasta Ficha cadastral³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD2:= MSNEWGetDados():New(1, 1, aPosObjT1[3,4]-13,aPosObjT1[3,3]-3 ,;
       nOpcoes ,"CRM010_008('2','L').AND.Crd010RefCar()" ,"CRM010_008('2','T')" , , , , , , , , oFolder2:aDialogs[3] ,aHeader2 ,aCols2)
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados da Referencia bancaria    - Pasta Ficha cadastral³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       oGetD3:= MSNEWGetDados():New(1, 1, aPosObjT1[3,4]-13,aPosObjT1[3,3]-3 ,;
       nOpcoes ,"CRM010_008('3','L')" ,"CRM010_008('3','T')" , , , , , , , , oFolder2:aDialogs[4] ,aHeader3 ,aCols3)
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GetDados da Referencia pessoal     - Pasta Ficha cadastral³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
       oGetD4:= MSNEWGetDados():New(1, 1, aPosObjT1[3,4]-13,aPosObjT1[3,3]-3 ,;
       nOpcoes ,"CRM010_008('4','L')" ,"CRM010_008('4','T')" , , , , , , , , oFolder2:aDialogs[5] ,aHeader4 ,aCols4)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecionamos o Alias SA1, por se tratar da tabela do folder principal e tambem por ser utilizada por varios mashups. |
//|*o Alias usado no Mashup deve estar selecionado no momento da chamada do EnchoiceBar									|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")

ACTIVATE MSDIALOG oDlg CENTERED;
         ON INIT ( EnchoiceBar( oDlg,	{|| If(CRM010_007(nOpcx),(nOpc:=1,oDlg:End()),.F.)},;
                                            {|| If(Crd010Aband(nOpcx),(nOpc:=0,oDlg:End()),.F.)} , .F., aButtons  ))
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso confirmada a operacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
            
	If CRA010_013(nOpcX)
	   Processa( {|| CRM010_002( nOpcx  ,nRecMAR010) }, STR0018, STR0019 ) //"Atualizando a base de dados."###"Aguarde..."
		While (GetSx8Len() > nSaveSx8 )
			ConfirmSx8()
		End
	   lConfirma := .T.
	Endif                           
Else	
	While (GetSx8Len() > nSaveSx8 )		
		RollBackSx8()	
	End		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desmarcar o registro do semaforo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4
	DbSelectArea("MAR")
	If nRecMAR010 > 0
		DbGoto(nRecMAR010)
		ConOut("4. CRDA010 - Exclui registro no MAR. Recno: " + MAR->MAR_REGIST +;
			" Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI +;
			" Usuario: " + cUserName +;
			" Cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
		RecLock("MAR",.F.,.T.)
		DbDelete()
		MsUnlock()
		SA1->(MsUnLock())
		WriteSx2("MAR")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha e apaga o arquivo temporario utilizado³
		//³como semaforo.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FClose(nArqSem)
		FErase(cArqSem)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deletar o temporario referente aos enderecos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If( ValType(oTempTable) == "O")
	oTempTable:Delete()
	FreeObj(oTempTable)
	oTempTable := Nil
EndIf

If nOpcx == 3
	aRotina[3][4] := 2
Endif                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Setando as variaveis do tipo STATIC no CRDXFUN |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CRDXSetaVar()


//Se confirmou a operacao, verifica Integracao
If nOpc == 1
	CRDAINTGFE( nOpcx )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_002ºAutor  ³Frank Zwarg Fuga    º Data ³  06/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para salvar as informacoes do cadastro de clientes   º±±
±±º          ³com os dados relacionados ao seu perfil.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Opcao 											  º±±
±±º			 ³ ExpN2 - Recno do MAR gerado pelo CRDA010 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista      ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea Farias ³03/07/05³085069³- Utilizar os indices (2) das tabelas   º±±
±±º              ³        ³      ³MAA, MAB, MAC e MAE no posicionamento   º±±
±±º              ³        ³      ³para exclusao.                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºHanna Caroline³11/08/05³084970³Incluido o codigo do endereco no aCols  º±±
±±º              ³        ³      ³da referencia de trabalho e efetuado o  º±±
±±º              ³        ³      ³tratamento da alteracao do cliente para º±±
±±º              ³        ³      ³duplicar o MA8 e MAD                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Geronimo      ³30/08/05³FN2793³Integridade Referencial. Separar grava- º±±
±±³              ³        ³      ³ cao do MA8 x MAD e correcoes no SX9    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºMarcos        ³15/09/05³DELLA ³Alteracao para verificar se existe o    º±±
±±³              ³        ³VIA   ³o MAD antes de fazer alteracao.         º±±
±±³Geronimo      ³23/09/05³086684³Melhorado tratamento do campo MAC_CODDEPº±±
±±³              ³        ³      ³Seu incremento ocorrera apenas no       º±±
±±³              ³        ³      ³momento da gravacao e nao na aCols.     º±±
±±³              ³        ³      ³Tornado possivel gravar um cliente com  º±±
±±³              ³        ³      ³getdados de dependentes vazias sem      º±±
±±³              ³        ³      ³precisar deletar a linha. A mesma faci- º±±
±±³              ³        ³      ³lidade foi implementada para o questio- º±±
±±³              ³        ³      ³nario socio economico desde que o       º±±
±±³              ³        ³      ³questionario padrao nao exista.         º±±
±±ºConrado Q     ³04/04/07³122711³Alterada a utilização da chamada        º±±
±±º              ³        ³      ³SubStr(cUsuario,7,15) por cUserName     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_002( nOpcx  ,nRecMAR010)
Local nX
Local nY                 
Local cCampo
Local nPosMaiPerg      
Local cMad_Codend

Local aTabelas		:= {}		//Tabelas para LOG
Local aArrayGD		:= {}		//Array contendo os GetDados
Local aCpoFixosGet	:= {}		//Array contendo os campos fixos que fazem a amarracao cabec x itens
Local aGravaMAD     := {}       //Array com os campos e conteudos correspondentes a serem gravados no arquivo MAD
Local nField		:= 0
Local nPosCodEnd	:= 0		//Posicao do Codigo do Endereco na GetDados

Local lPrime_MA8                //Controla se eh a gravacao inicial do arquivo MA8
Local lPrime_MAD				//Controla se eh a gravacao inicial do arquivo MAD
Local lIncluiReg                //Controla a inclusao do registro nos arquivos MA8 e MAD
Local nPMacCodDep				// Posicao do campo MAC_CODDEP no array da GetDados
Local nPMacCartao		   		// Possicao na array do Cartao adicional para dependente
Local nPMacDepNom				// Possicao na array do Nome do dependente
Local nPMacDepDTN				// Possicao na array do Data nascimento do dependente
Local nPMacDepGra				// Possicao na array do Grau de parentesco              

Local lAmbOffLn	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciono as tabelas e os indices para geracao dos LOGs                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aTabelas, {"SA1",1} )
aAdd( aTabelas, {"MA7",1} )
aAdd( aTabelas, {"MA8",1} )
aAdd( aTabelas, {"MA9",1} )
aAdd( aTabelas, {"MAA",1} )
aAdd( aTabelas, {"MAB",1} )
aAdd( aTabelas, {"MAI",1} )
aAdd( aTabelas, {"MAC",1} )
aAdd( aTabelas, {"MA6",2} )
aAdd( aTabelas, {"MAE",1} )
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciono o MsGetdados para LOG e seleciono os campos que sao chaves     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MA8_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MA8_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MA8",aHeader1,oGetD1:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MA9_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MA9_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MA9",aHeader2,oGetD2:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MAA_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MAA_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MAA",aHeader3,oGetD3:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MAB_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MAB_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MAB",aHeader4,oGetD4:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MAC_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MAC_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MAC",aHeader5,oGetD5:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MAI_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MAI_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MAI",aHeader8,oGetD8:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MA6_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MA6_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MA6",aHeader6,oGetD6:aCols,aCpoFixosGet} )
 
aCpoFixosGet := {}
aAdd( aCpoFixosGet , {"MAE_CODCLI",M->A1_COD} )
aAdd( aCpoFixosGet , {"MAE_LOJA",M->A1_LOJA} )
 
aAdd( aArrayGD, { "MAE",aHeader7,oGetD7:aCols,aCpoFixosGet} )
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executo a funcao que gera o LOG.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(10)

BEGIN TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incluir as informacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o cadastro de clientes padrao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	RecLock("SA1", .T.)

	For nField := 1 TO FCount()
		FieldPut(nField,M->&(FieldName(nField)))
	Next nField

	SA1->A1_FILIAL := xFilial("SA1")   
	MsUnlock()       
	If __lSX8
		ConfirmSX8()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->( FKCommit() ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao no Log de Alteracoes do Front Loja. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("FRTGeraSLH")
		FRTGeraSLH("SA1", "I")
	EndIf
	
	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o cadastro da ficha cadastral³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA7")
	RecLock("MA7", .T.)

	For nField := 1 TO FCount()
		FieldPut(nField,M->&(FieldName(nField)))
	Next nField

	REPLACE MA7->MA7_FILIAL With xFilial("MA7")
	REPLACE MA7->MA7_CODCLI With M->A1_COD
	REPLACE MA7->MA7_LOJA   With M->A1_LOJA
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA7->( FKCommit() ) 	
	IncProc()                     
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA8")                                   

	For nX := 1 to Len(oGetd1:aCols)

		If !oGetd1:aCols[nX][len(aHeader1)+1]      	

			IF ExistBlock("GRCODNUM")
				cMAD_CODEND := ExecBlock("GRCODNUM",.F.,.F.)
			ELSE
				cMAD_CODEND := GetSx8Num("MAD", "MAD_CODEND")
			Endif      
   		  
			lPrime_MA8 := .T.
			lPrime_MAD := .T.
			lIncluiReg := .T.
			DbSelectArea("MA8")                                   			
			DbSetOrder(1)
			For nY := 1 to Len(aHeader1)
				If Substr(aHeader1[nY][02],1,3) == "MA8"  	      
					
					IF lPrime_MA8
						RecLock("MA8", .T. )                       
						REPLACE MA8->MA8_FILIAL With xFilial("MA8")
						REPLACE MA8->MA8_CODCLI With M->A1_COD
						REPLACE MA8->MA8_LOJA   With M->A1_LOJA    
						REPLACE MA8->MA8_CODEND With cMAD_CODEND
						lPrime_MA8 := .F.
					ENDIF
			
					DbSelectArea("SX3")
					DbSetOrder(2) 
					DbSeek( aHeader1[nY][02] )
					DbSelectArea("MA8")				
					If SX3->X3_CONTEXT <> "V" .AND. SX3->X3_CAMPO <> "MA8_CODEND" .AND. !IsHeadRec(aHeader1[nY][02]) .AND. !IsHeadAlias(aHeader1[nY][02])
						cCampo := "MA8->"+aHeader1[nY][02]
						If !lIncluiReg
						   RecLock("MA8", .F. )                       						
						Endif						
						&(cCampo)   := oGetd1:aCols[nX][nY]	            	
						lIncluiReg  := .F.
					Endif
					DbSelectArea("MA8")
					MsUnlock()
				Endif
			Next nY
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MA8->( FKCommit() ) 	            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava no array aGravaMAD os nomes dos campos e seus conteudos ³
			//³correspondentes. Processo realizado para nao lidar com o SX3 e³			
			//³MAD simultaneamente na gravacao deste arquivo    			 ³						
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			aGravaMAD  := {}
			DbSelectArea("SX3")
			DbSetOrder(2) 			
			For nY := 1 to Len(aHeader1)
			   If Substr(aHeader1[nY][02],1,3) == "MAD"	         			
			      DbSeek( aHeader1[nY][02] )
			      If SX3->X3_CONTEXT <> "V" .AND. !IsHeadRec(aHeader1[nY][01]) .AND. !IsHeadAlias(aHeader1[nY][01])
			         aAdd(aGravaMAD,{"MAD->"+aHeader1[nY][02],oGetd1:aCols[nX][nY]})			      
			      Endif
			   Endif   
			Next nY   
			DbSelectArea("MAD")                                   			
			DbSetOrder(1)			
			For nY := 1 to Len(aGravaMAD)
			   If nY == 1
			      RecLock("MAD", .T. )
				  REPLACE MAD->MAD_CODEND With cMAD_CODEND
				  REPLACE MAD->MAD_FILIAL With xFilial("MAD")			   
				  MsUnlock()
			   Endif      
			   cCampo    := aGravaMAD[nY][1]
			   RecLock("MAD", .F. )   
			   &(cCampo) := aGravaMAD[nY][2]			   
			   MsUnlock()
			Next nY
			If __lSX8
				ConfirmSx8()
			Endif
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MAD->( FKCommit() ) 	

		Endif
		
	Next nX
	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA9")
	A610GravaCol(oGetd2:aCols, aHeader2, aColsR2, "MA9",;
	{|| MA9->MA9_CODCLI := M->A1_COD, MA9->MA9_LOJA := M->A1_LOJA, MA9->MA9_CODIGO := GetSXENum("MA9","MA9_CODIGO")} )       
	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA9->( FKCommit() ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias bancarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("MAA")
    A610GravaCol(oGetd3:aCols, aHeader3, aColsR3, "MAA",;
    {|| MAA->MAA_CODCLI := M->A1_COD, MAA->MAA_LOJA := M->A1_LOJA, MAA->MAA_CODIGO := GetSXENum("MAA","MAA_CODIGO")} )       
    IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAA->( FKCommit() ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias pes]soais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("MAB")
    A610GravaCol(oGetd4:aCols, aHeader4, aColsR4, "MAB",;
    {|| MAB->MAB_CODCLI := M->A1_COD, MAB->MAB_LOJA := M->A1_LOJA, MAB->MAB_CODIGO := GetSXENum("MAB","MAB_CODIGO")} )          
    IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAB->( FKCommit() ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - dados-socio-economicos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("MAI")                                   
   
    nPosMaiPerg := ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PERG"})
    oGetd8Del()

    For nX := 1 to Len(oGetd8:aCols)
		If !oGetd8:aCols[nX][len(aHeader8)+1] .AND. !Empty(oGetd8:aCols[nX][nPosMaiPerg])

	       RecLock("MAI", .T. )                       
	       REPLACE MAI->MAI_FILIAL With xFilial("MAI")
	       REPLACE MAI->MAI_CODCLI With M->A1_COD
	       REPLACE MAI->MAI_LOJA   With M->A1_LOJA    
	       REPLACE MAI->MAI_QUEST  With SuperGetMV("MV_QUEST")      
	       For nY := 1 to Len(aHeader8)
	          If aHeader8[nY][10] <> "V"
	             cCampo := "MAI->"+aHeader8[nY][02]
	             &(cCampo) := oGetd8:aCols[nX][nY]
	          Endif
   	       Next nY
	       MsUnlock()   	      
   	    Endif   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Descarrega o buffer para integridade referencial             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    MAI->( FKCommit() ) 	
    Next nX
    IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - dependentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nPMacCodDep := ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CODDEP"})
    nPMacCartao	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"})	// Cartao adicional para dependente
    nPMacDepNom	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPNOM"})	// Nome do dependente
    nPMacDepDTN	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPDTN"})	// Data nascimento do dependente
    nPMacDepGra	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPGRA"})	// Grau de parentesco

	
    For nX := 1 to Len(oGetd5:aCols)
       If !oGetd5:aCols[nX][LEN(aHeader5)+1]
    	If Empty(oGetd5:aCols[nX][nPMacCodDep])
			oGetd5:aCols[nX][nPMacCodDep] := GetSXENum("MAC","MAC_CODDEP")	//Se o MAC_CODDEP esta vazio alimenta-o
    	  Endif
    	Endif
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a Linha de dependente estiver toda em branco descarto-a                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     IF  empty( oGetd5:aCols[nX][nPMacCartao] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepNom] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepDTN] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepGra] )
	         
	         oGetd5:aCols[nX][len(aHeader5)+1] := .f.
	         
	     Endif    	    	
    Next nX

    DbSelectArea("MAC")
    A610GravaCol(oGetd5:aCols, aHeader5, aColsR5, "MAC",;
    {|| MAC->MAC_CODCLI := M->A1_COD, MAC->MAC_LOJA := M->A1_LOJA } )          
    IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAC->( FKCommit() ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("MA6")
    DbSetOrder(2)
    A610GravaCol(oGetd6:aCols, aHeader6, aColsR6, "MA6",;
    {|| MA6->MA6_CODCLI := M->A1_COD, MA6->MA6_LOJA := M->A1_LOJA} ) 
    If __lSX8
	   ConfirmSx8()         
    Endif
    IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava automaticamente os cartoes dos dependentes cadastrados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
	    CrdGrvAutMA6(M->A1_COD,M->A1_LOJA)
    Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA6->( FKCommit() ) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - documentos entregues³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("MAE")
    A610GravaCol(oGetd7:aCols, aHeader7, aColsR7, "MAE",;
    {|| MAE->MAE_CODCLI := M->A1_COD, MAE->MAE_LOJA := M->A1_LOJA, MAE->MAE_CODIGO := GetSXENum("MAE","MAE_CODIGO")} )          
    IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAE->( FKCommit() ) 	   
	
	AtualizaSYP(nOpcx)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Alterar as informacoes³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOpcx == 4

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Salva o cadastro de clientes padrao  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea("SA1") 
   DbSetOrder(1)
   DbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA)
   RecLock("SA1", .F.)

   For nField := 1 TO FCount()

      FieldPut(nField,M->&(FieldName(nField)))

   Next nField                           

   MsUnlock()
   IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->( FKCommit() ) 	   
                                                     
	AtualizaSYP(nOpcx)
                                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao no Log de Alteracoes do Front Loja. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("FRTGeraSLH")
		FRTGeraSLH("SA1", "A")
	EndIf
                                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva o cadastro da ficha cadastral³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea("MA7")       
   DbSetOrder(1)
   DbSeek(xFilial("MA7")+M->A1_COD+M->A1_LOJA)
   RecLock("MA7", If(EOF(),.T.,.F.))

   For nField := 1 TO FCount()

      FieldPut(nField,M->&(FieldName(nField)))

   Next nField
   
   MA7->MA7_FILIAL := xFilial("MA7")
   MA7->MA7_CODCLI := M->A1_COD
   MA7->MA7_LOJA := M->A1_LOJA

   MsUnlock()
   IncProc()                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MA7->( FKCommit() ) 	
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias de trabalho³
	//³Estornar as informacoes         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA8")
	DbSetOrder(3)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciono no arquivo mas nao critico se nao achar, pois, na inclusao posso não incluir referencias de trabalho ³
	//³e posteriormente querer informa-la na alteracao                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSeek( xFilial("MA8") + M->A1_COD + M->A1_LOJA )

	For nX := 1 to Len(oGetd1:aCols)

		nPosCodEnd	:= ascan(aHeader1,{|x| Trim(x[2]) == "MA8_CODEND"})	
		lIncluiReg  := .F.    //Controla o lock quando incluida nova referencia de trabalho

		If !oGetd1:aCols[nX][len(aHeader1)+1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se existe a Referencia de Trabalho na base de dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("MA8")
			DbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existir o item, efetua a alteracao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DbSeek( xFilial("MA8") + oGetd1:aCols[nX][nPosCodEnd] + M->A1_COD + M->A1_LOJA ) .AND. !Empty( oGetd1:aCols[nX][nPosCodEnd] )
				RecLock("MA8", .F. )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe o MAD. Caso não exista faz a inclusão do registro para evitar error.log            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				DbSelectArea("MAD")
				DbSetOrder(1)
				If DbSeek( xFilial("MAD") + oGetd1:aCols[nX][nPosCodEnd] )
					RecLock("MAD", .F. )
				Else
					RecLock("MAD", .T. )         
					REPLACE MAD->MAD_CODEND With oGetd1:aCols[nX][nPosCodEnd]
					REPLACE MAD->MAD_FILIAL With xFilial("MAD")
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao existir o item, efetua a inclusao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				IF ExistBlock("GRCODNUM")
					cMAD_CODEND := ExecBlock("GRCODNUM",.F.,.F.)
				ELSE
					cMAD_CODEND := GetSx8Num("MAD", "MAD_CODEND")
				Endif
				RecLock("MA8", .T. )
				REPLACE MA8->MA8_FILIAL With xFilial("MA8")
				REPLACE MA8->MA8_CODCLI With M->A1_COD
				REPLACE MA8->MA8_LOJA   With M->A1_LOJA    
				REPLACE MA8->MA8_CODEND With cMAD_CODEND
				MA8->( MsUnlock() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Descarrega o buffer para integridade referencial             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MA8->( FKCommit() ) 	
				
				RecLock("MAD", .T. )
				REPLACE MAD->MAD_CODEND With cMAD_CODEND
				REPLACE MAD->MAD_FILIAL With xFilial("MAD")
				MAD->( MsUnlock() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Descarrega o buffer para integridade referencial             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MAD->( FKCommit() ) 	
				lIncluiReg  := .T.
   			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando eh incluida nova referencia de trabalho deve dar lock no registro para alteracao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lIncluiReg
				RecLock("MA8", .F. )
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava conteudo da GetDados na Base de Dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			For nY := 1 to Len(aHeader1)
				If Substr(aHeader1[nY][02],1,3) == "MA8"
					DbSelectArea("SX3")
					DbSetOrder(2) 
					If DbSeek( aHeader1[nY][02] )
						DbSelectArea("MA8")
						If SX3->X3_CONTEXT <> "V" .AND. aHeader1[nY][02] <> "MA8_CODEND"
				            cCampo := "MA8->"+aHeader1[nY][02]
				            &(cCampo) := oGetd1:aCols[nX][nY]
				  		Endif
					Endif
				Endif
			Next nY
			MA8->( MsUnlock() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MA8->( FKCommit() ) 	

			If lIncluiReg
				RecLock("MAD", .F. )			
			Endif					
			For nY := 1 to Len(aHeader1)
				If Substr(aHeader1[nY][02],1,3) == "MAD"
					DbSelectArea("SX3")
					DbSetOrder(2) 
					If DbSeek( aHeader1[nY][02] )
				       DbSelectArea("MAD")      
					   If SX3->X3_CONTEXT <> "V"        
						  cCampo := "MAD->"+aHeader1[nY][02]                 
						  &(cCampo) := oGetd1:aCols[nX][nY]
					   Endif
				   Endif
			   Endif
		    Next nY
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Gera SXE e SXF, caso seja uma inclusao e destrava os registros³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If __lSX8
			   ConfirmSx8()
		    Endif
		    MAD->( MsUnlock() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    MAD->( FKCommit() ) 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o item estiver DELETADO, verifico se existe na base de dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			DbSelectArea("MA8")
			DbSetOrder(1)
			If DbSeek( xFilial("MA8") + oGetd1:aCols[nX][nPosCodEnd] + M->A1_COD + M->A1_LOJA )				
				RecLock("MA8", .F.)
				DbDelete()
				Msunlock()
			Endif				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MA8->( FKCommit() ) 	
			
			DbSelectArea("MAD")
			DbSetOrder(1)
			If DbSeek( xFilial("MAD") + oGetd1:aCols[nX][nPosCodEnd] )
				RecLock("MAD", .F.)
				DbDelete()
				Msunlock()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MAD->( FKCommit() ) 				
		Endif
	Next nX
	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   A610GravaCol(oGetd2:aCols, aHeader2, aColsR2, "MA9",;
   {|x| MA9->MA9_CODCLI := M->A1_COD, MA9->MA9_LOJA := M->A1_LOJA,;
        MA9->MA9_CODIGO := GetSXENum("MA9","MA9_CODIGO"), ConfirmSX8()} )
   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias bancarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   A610GravaCol(oGetd3:aCols, aHeader3, aColsR3, "MAA",;
   {|x| MAA->MAA_CODCLI := M->A1_COD, MAA->MAA_LOJA := M->A1_LOJA, ;
        MAA->MAA_CODIGO := GetSXENum("MAA","MAA_CODIGO"), ConfirmSX8()}, "MAA_BANCO" )
   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva as Referencias pessoais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   A610GravaCol(oGetd4:aCols, aHeader4, aColsR4, "MAB",;
   {|x| MAB->MAB_CODCLI := M->A1_COD, MAB->MAB_LOJA := M->A1_LOJA, ;
        MAB->MAB_CODIGO := GetSXENum("MAB","MAB_CODIGO"), ConfirmSX8()} )
   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - dados-socio-economicos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea("MAI")                                   
   DbSetOrder(1)
   DbSeek(xFilial("MAI")+M->A1_COD+M->A1_LOJA)
   While !Eof() .AND. MAI_FILIAL+MAI_CODCLI+MAI_LOJA == xFilial("MAI")+M->A1_COD+M->A1_LOJA
      RecLock("MAI",.F.,.T.)
      DbDelete()
      MsUnlock()
      WriteSx2()
      dbSkip()
   End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MAI->( FKCommit() ) 	
   
	nPosMaiPerg := ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PERG"})   
	oGetd8Del()

   For nX := 1 to Len(oGetd8:aCols)

	   If !oGetd8:aCols[nX][len(aHeader8)+1] .AND. !Empty(oGetd8:aCols[nX][nPosMaiPerg])

	      RecLock("MAI", .T. )                       
	      REPLACE MAI->MAI_FILIAL With xFilial("MAI")
	      REPLACE MAI->MAI_CODCLI With M->A1_COD
	      REPLACE MAI->MAI_LOJA   With M->A1_LOJA    
	      REPLACE MAI->MAI_QUEST  With SuperGetMV("MV_QUEST")
      
	      For nY := 1 to Len(aHeader8)

	         If aHeader8[nY][10] <> "V"

	            cCampo := "MAI->"+aHeader8[nY][02]
	            &(cCampo) := oGetd8:aCols[nX][nY]

	         Endif
   	      Next nY
          MsUnlock()   	      
   	   Endif   
   Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MAI->( FKCommit() ) 	

   
	#IFDEF TOP
		If TCGetDb() <> "POSTGRES"	.AND. TcSrvType() <> "AS/400"							
			cQuery := "DELETE FROM "+RetSqlName("MAI")+" " 
			cQuery += "WHERE MAI_FILIAL='"+xFilial("MAI")+"' AND "
			cQuery += "MAI_CODCLI = '" + MAI->MAI_CODCLI +"' AND "
			cQuery += "MAI_LOJA = '" + MAI->MAI_LOJA +"' AND "
			cQuery += " D_E_L_E_T_ = '*'"		  					
			TcSqlExec(cQuery)
		Endif
	#ENDIF

   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - dependentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nPMacCodDep := ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CODDEP"})
    nPMacCartao	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"})	// Cartao adicional para dependente
    nPMacDepNom	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPNOM"})	// Nome do dependente
    nPMacDepDTN	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPDTN"})	// Data nascimento do dependente
    nPMacDepGra	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPGRA"})	// Grau de parentesco

	
    For nX := 1 to Len(oGetd5:aCols)
       If !oGetd5:aCols[nX][LEN(aHeader5)+1]    
    	If Empty(oGetd5:aCols[nX][nPMacCodDep])
			oGetd5:aCols[nX][nPMacCodDep] := GetSXENum("MAC","MAC_CODDEP")	//Se o MAC_CODDEP esta vazio alimenta-o
    	  Endif
    	Endif
    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a Linha de dependente estiver toda em branco descarto-a                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     IF  empty( oGetd5:aCols[nX][nPMacCartao] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepNom] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepDTN] ) .AND. ;
	         empty( oGetd5:aCols[nX][nPMacDepGra] )
	         
	         oGetd5:aCols[nX][len(aHeader5)+1] := .F.
	         
	     Endif    	    	
    Next nX

   A610GravaCol(oGetd5:aCols, aHeader5, aColsR5, "MAC",;
   {|| MAC->MAC_CODCLI := M->A1_COD, MAC->MAC_LOJA := M->A1_LOJA } )             
   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - cartoes                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DbSelectArea("MA6")
   DbSetOrder(2)
   A610GravaCol(oGetd6:aCols, aHeader6, aColsR6, "MA6",;
   {|| MA6->MA6_CODCLI := M->A1_COD, MA6->MA6_LOJA := M->A1_LOJA} )          
   If __lSX8
      ConfirmSx8()
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava automaticamente os cartoes dos dependentes cadastrados ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
	   CrdGrvAutMA6(M->A1_COD,M->A1_LOJA)
   Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MA6->( FKCommit() ) 	
   IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - documentos entregues³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   A610GravaCol(oGetd7:aCols, aHeader7, aColsR7, "MAE",;
   {|x| MAE->MAE_CODCLI := M->A1_COD, MAE->MAE_LOJA := M->A1_LOJA, ;
        MAE->MAE_CODIGO := GetSXENum("MAE","MAE_CODIGO"), ConfirmSX8()} )
      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MAE->( FKCommit() ) 	
   IncProc()
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Excluir as informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nOpcx == 5			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui o cadastro da ficha cadastral³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA7")
	DbSetOrder(1)
	If DbSeek(xFilial("MA7")+M->A1_COD+M->A1_LOJA)
		RecLock("MA7", .F., .T.)
		DbDelete()
		MsUnlock()
		WriteSx2("MA7")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA7->( FKCommit() ) 	
	IncProc()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui as Referencias de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAD")
	DbSetOrder(1)
	DbSelectArea("MA8")
	DbSetOrder(3)
	If DbSeek( xFilial("MA8") + M->A1_COD + M->A1_LOJA )
	
		While !Eof() .AND. MA8_FILIAL + MA8_CODCLI + MA8_LOJA == ;
			xFilial("MA8") + M->A1_COD + M->A1_LOJA
			
			DbSelectArea("MAD")
			DbSeek(xFilial("MAD")+MA8->MA8_CODEND)					
			If MAD->( Found() )
				
				RecLock("MAD", .F., .T.)
				DbDelete()
				Msunlock()
				WriteSx2("MAD")
				
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MAD->( FKCommit() ) 	
			
			DbSelectArea("MA8")
			RecLock("MA8",.F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MA8")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Descarrega o buffer para integridade referencial             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MA8->( FKCommit() ) 	               
			MA8->( DbSkip() )			
		End
		IncProc()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui as Referencias cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA9")
	DbSetOrder(2)
	If DbSeek( xFilial("MA9") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MA9_FILIAL + MA9_CODCLI + MA9_LOJA == ;
			xFilial("MA9") + M->A1_COD + M->A1_LOJA
			
			RecLock("MA9",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MA9")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA9->( FKCommit() ) 	               
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui as Referencias bancarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAA")
	DbSetOrder(2)
	If DbSeek( xFilial("MAA") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MAA_FILIAL + MAA_CODCLI + MAA_LOJA == ;
			xFilial("MAA") + M->A1_COD + M->A1_LOJA
			
			RecLock("MAA",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MAA")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAA->( FKCommit() ) 	               
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui as Referencias pessoais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAB")
	DbSetOrder(2)
	If DbSeek( xFilial("MAB") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MAB_FILIAL + MAB_CODCLI + MAB_LOJA == ;
			xFilial("MAB") + M->A1_COD + M->A1_LOJA
			
			RecLock("MAB",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MAB")
			DbSkip()
			
		End
		IncProc()
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAB->( FKCommit() ) 	               

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui os dados-socio-economicos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAI")
	DbSetOrder(1)
	If DbSeek( xFilial("MAI") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MAI_FILIAL + MAI_CODCLI + MAI_LOJA == ;
			xFilial("MAI") + M->A1_COD + M->A1_LOJA
			
			RecLock("MAI",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MAI")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAI->( FKCommit() ) 	               
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui os dependentes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAC")
	DbSetOrder(2)
	If DbSeek( xFilial("MAC") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MAC_FILIAL + MAC_CODCLI + MAC_LOJA == ;
			xFilial("MAC") + M->A1_COD + M->A1_LOJA
			
			RecLock("MAC",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MAC")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAC->( FKCommit() ) 	               
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui os cartoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MA6")
	DbSetOrder(2)
	If DbSeek( xFilial("MA6") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MA6_FILIAL + MA6_CODCLI + MA6_LOJA == ;
			xFilial("MA6") + M->A1_COD + M->A1_LOJA
			
			RecLock("MA6",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MA6")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MA6->( FKCommit() ) 	               

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui os documentos entregues³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("MAE")
	DbSetOrder(2)
	If DbSeek( xFilial("MAE") + M->A1_COD + M->A1_LOJA )
		While !Eof() .AND. MAE_FILIAL + MAE_CODCLI + MAE_LOJA == ;
			xFilial("MAE") + M->A1_COD + M->A1_LOJA
			
			RecLock("MAE",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("MAE")
			DbSkip()
			
		End
		IncProc()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MAE->( FKCommit() ) 	               	


	AtualizaSYP(nOpcx)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui o cadastro de clientes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	RecLock("SA1", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("SA1")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descarrega o buffer para integridade referencial             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->( FKCommit() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao no Log de Alteracoes do Front Loja. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("FRTGeraSLH")
		FRTGeraSLH("SA1", "D")
	EndIf

	
	IncProc()		
Endif 

If lAmbOffLn .AND. !(nOpcx == 2)
	Crd10AltOk()
EndIf

END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<¿
//³Ponto de entrada no final da rotina de cadastro de clientes para tratar inclusão, alteração, e exclusão ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<Ù

If ExistBlock("CRD010PG")                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nOpcx			// 2 -> Visualizacao    // 3 -> Inclusao   	// 4 -> Alteracao     	// 5 -> Exclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock("CRD010PG",.F.,.F.,{nOpcx})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada de Templates no final da rotina de cadastro de clientes para tratar  ³
//³inclusão, alteracao, e exclusao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CRD010PG")                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nOpcx			// 2 -> Visualizacao    // 3 -> Inclusao   	// 4 -> Alteracao     	// 5 -> Exclusao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecTemplate("CRD010PG",.F.,.F.,{nOpcx})
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRM010_003³ Autor ³ Carlos E. Chigres     ³ Data ³ 26.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao dos Titulos em Aberto do Cliente              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Dadalto                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRM010_003()         

Processa( {|| CRDCRM16() }, STR0046, STR0047 )  //"Titulos em aberto."###"Gerando a consulta."

Return (NIL)
   
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CRM010_004  ³ Autor ³ Carlos E. Chigres     ³ Data ³ 26.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao Ampliada do Titulo em Aberto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Dadalto                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRM010_004()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis da Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAlias   := "SE1"
Local nReg     := 1
Local nOpc     := 2         
Local back_fil := cFilial

nReg := aPosSE1[nLine][1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de varias filiais devemos tratar a variavel cfilial para acessar a consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFilial <> aPosSE1[nLine][2] .AND. xFilial("SE1") <> Space(FWGETTAMFILIAL)
	cFilial := aPosSE1[nLine][2]
Endif

DbSelectArea( cAlias )
dbGoTo( nReg )

AxVisual( cAlias, nReg, nOpc )

cFilial := back_fil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HABCOM   ³ Autor ³ Frank Zwarg Fuga      ³ Data ³ 26.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao dos habitos de compras                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Dadalto                                       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista      ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q.    ³23/02/07³119542³- Retirado ajuste no dicionário.        º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HABCOM()
Local aSize     := MsAdvSize( .T., .T., 250 )
Local aObjects  := {}
Local aInfo	    := {}
Local aPosObj   := {}
Local cCodCli   := M->A1_COD
Local cLoja     := M->A1_LOJA
Local aAreaAtu  := GetArea()
Local cTitle    := STR0028 // Habitos de compras
Local oOk	    := LoadBitmap( GetResources(), "BR_VERDE" )
Local nOpca     := 0
Local aTitles1  := { STR0029, STR0041 } //"Aprovadas", "Bloqueadas"
Local oFolder1
Local aField1   := {}
Local aField2   := {}
Local aTitle1   := {}
Local aTitle2   := {}
Local oHabito     
Local nPonteiro
Local nX
Local cGrupo     
Local cData
Local aFili		 :={}
Local nFili		 := {}
Private aPosSF2 := {}
Private aTitul1   := {}
Private aTitul2   := {}


If INCLUI
   MsgStop(STR0048,STR0049) //"Rotina não disponível na inclusão."###"Atenção !"
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pergunta para definir o tipo de visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("DAC020", .T.)

	DbSelectArea("SM0")
	dbGotop()
    aAdd(aFili,{Space(FWGETTAMFILIAL),Space(15)})
	While !Eof()

		If M0_CODIGO <> cEmpAnt
			dbSkip()
			Loop
		Endif
	
		If FWGETCODFILIAL >= MV_PAR01 .AND. FWGETCODFILIAL <= MV_PAR02
			aAdd(aFili,{FWGETCODFILIAL,M0_FILIAL})
		Endif
			
		dbSkip()
	
	End
	
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A montagem de um "aHeader" para SE1 ³
	//³ tem o objetivo de automatizar a     ³
	//³ montagem dos campos do ListBox      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//---Este eh a primeira coluna do ListBox       
	
	If MV_PAR03 = 1 // Visualizar por grupo de produto
	
		aAdd(aField1, STR0050) //"Produto"
		aAdd(aField1, STR0051) //"Total"
		aAdd(aTitle1, STR0050) //"Produto"
		aAdd(aTitle1, STR0052) //"Vlr.Total"
		aAdd(aField2, STR0050) //"Produto"
		aAdd(aField2, STR0051) //"Total"
		aAdd(aTitle2, STR0050) //"Produto"
		aAdd(aTitle2, STR0052) //"Vlr.Total"
		
	Else  // Visualizar por data
	
		aAdd(aField1, STR0053) //"Data"
		aAdd(aField1, STR0050) //"Produto"
		aAdd(aField1, STR0051) //"Total"
		aAdd(aTitle1, STR0053) //"Data"
		aAdd(aTitle1, STR0050) //"Produto"
		aAdd(aTitle1, STR0052) //"Vlr.Total"
		aAdd(aField2, STR0053) //"Data"
		aAdd(aField2, STR0050) //"Produto"
		aAdd(aField2, STR0051) //"Total"
		aAdd(aTitle2, STR0053)  //"Data"
		aAdd(aTitle2, STR0050)  //"Produto"
		aAdd(aTitle2, STR0052) //"Vlr.Total"
	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Encontrando as compras     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Processa( {|| CRDCRM14(cCodcli,cLoja,aFili) }, STR0054, STR0047 ) //"Compras recusadas."###"Gerando a consulta."
	Processa( {|| CRDCRM15(cCodcli,cLoja,aFili) }, STR0055, STR0047 )  //"Compras efetuadas."###"Gerando a consulta."
	
	If MV_PAR03 = 2 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando a visualizacao for por data ordenar os array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSort(aTitul2,,,{|x,y| x[1]+x[2]<y[1]+y[2] })
		aSort(aTitul1,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
		
	Endif
	
	If Len(aTitul1) == 0
	
	   aAdd( aTitul1 , Array(Len(aField1)) )
	
	Endif
	
	If Len(aTitul2) == 0
	
	   aAdd( aTitul2 , Array(Len(aField2)) )
	
	Endif
	
	DEFINE MSDIALOG oDlgT FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cTitle PIXEL 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao dos folders ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   oFolder1 := TFolder():New( aPosObj[1,1], aPosObj[1,2],;
	   aTitles1, {"HEADER"}, oDlgT, , , , .T., .F., aPosObj[1,4],;
	   aPosObj[1,3] )
	
	   oHabito1 := TwBrowse():New( 1,1,aPosObj[1,4]-5,aPosObj[1,3]-55,,aTitle1,,;
	   oFolder1:aDialogs[1],,,,{|| nLine := oHabito1:nAt},,,,,,,,.F.,,.T.,,.F.,,,)
	   
	   oHabito1:SetArray(aTitul1)
	   oHabito1:bLine := { || aTitul1[oHabito1:nAt] }
	
       oHabito2 := TwBrowse():New( 1,1,aPosObj[1,4]-5,aPosObj[1,3]-55,,aTitle2,,;
	   oFolder1:aDialogs[2],,,,{|| nLine := oHabito2:nAt},,,,,,,,.F.,,.T.,,.F.,,,)
	   
	   oHabito2:SetArray(aTitul2)
	   oHabito2:bLine := { || aTitul2[oHabito2:nAt] }
	
	ACTIVATE MSDIALOG oDlgT CENTERED ON INIT EnchoiceBar( oDlgT, {|| nOpca:=1, oDlgT:End()},;
	         {|| nOpca:=0, oDlgT:End()} , .F. )                         
		
	DeleteObject( oDlgT )
	DeleteObject( oHabito )
	RestArea( aAreaAtu )

Endif	
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CRM010_005    ³ Autor ³Marcelo Iuspa      ³ Data ³ 08/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Generica para criacao de aCols                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CRM010_005                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA610                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_005(cAlias, aHeaLoc, cSeek, bWhil, bFor)
Local aRetCol := {} 
Local aRetReg := {}
Local nX	  := 0		// Controle de loop
Private n 	  := 1

cAlias := If(cAlias=Nil,Alias(),cAlias)
bWhil  := If(bWhil=Nil,{|| .T.},bWhil)
bFor   := If(bFor=Nil,{|| .T.},bFor)

If cSeek <> Nil
	DbSelectArea(cAlias)
	DbSetOrder(2)
	DbSeek(cSeek, .T.)

	While ! Eof() .AND. Eval(bWhil)

		If ! Eval(bFor)

			dbSkip()
			Loop

		Endif	

		aAdd(aRetCol, {})

		For nX := 1 to Len(aHeaLoc)

			If aHeaLoc[nX, 10] == "V"
				aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeaLoc[nX, 2]))
			Else
				aAdd(aRetCol[Len(aRetCol)], FieldGet(FieldPos(aHeaLoc[nX, 2])))
			Endif	

		Next nX

		aAdd(aRetCol[Len(aRetCol)], .F.)
		aAdd(aRetReg, RecNo())

		dbSkip()

	End

Endif

If Len(aRetCol) == 0

	aAdd(aRetCol, {})

	For nX := 1 to Len(aHeaLoc)

		aAdd(aRetCol[Len(aRetCol)], CriaVar(aHeaLoc[nX, 2]))

	Next nX

	aAdd(aRetCol[Len(aRetCol)], .F.)

Endif

Return({aRetCol, aRetReg})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CRM010_006³ Autor ³Viviane M. Fernandes   ³ Data ³05.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Liberação de crédito                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Rotina de visualização da análise de crédito/Pessoal		  ³±±
±±³          ³chamada do cadastro de cliente 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Tipo de operacao(vide documentacao abaixo) 		  ³±±
±±³			 ³ExpC2 - Codigo do cliente									  ³±±
±±³			 ³ExpC3 - Loja do cliente									  ³±±
±±³			 ³ExpN4 - Recno do MAR gerado pelo CRDA080/CRDA180		  	  ³±±
±±³			 ³ExpL5 - Indica se foi chamado da CRA080AVAL		  	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºAnalista      ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºMarcos  R.    ³22/09/05³DELLA ³Alteracao para trazer o combo de libera-º±±
±±º              ³        ³VIA   ³cao vazio, para forcar o usuario a      º±±
±±º              ³        ³      ³a escolher a opcao.                     º±±
±±ºMarcos  R.    ³10/02/05³093219³Inicializacao da variavel nRecnoMA7,paraº±±
±±º              ³        ³      ³evitar error.log quando o usuario cance-º±±
±±º              ³        ³      ³la a analise do cred na tela do monitor º±±
±±ºAndrea F.     ³22/02/06³094117³- Implementacao Continua: Indentacao do º±±
±±º              ³        ³      ³fonte e documentacao.                   º±±
±±º              ³        ³094117³- Corrigido o calculo dos valores do    º±±
±±º              ³        ³      ³limite do cliente, de acordo com o tipo º±±
±±º              ³        ³      ³de endividamento (mensal ou global).    º±±
±±ºNorbert Waage ³03/03/06³Dadalt³Alterado o calculo do valor excedente,  º±±
±±º              ³        ³      ³considerando somente valores mensais p/ º±±
±±º              ³        ³      ³clientes com endividamento mensal.      º±±
±±ºAndrea F.     ³08/03/06³094380³-Valor do limite de credito do cliente  º±±
±±º              ³        ³      ³sendo calculado como endividamento      º±±
±±º              ³        ³      ³global.                                 º±±
±±ºMarcos R.     ³29/03/06³095717³Incluido a funcao ABS no calculo da     º±±	 
±±º              ³        ³      ³variavel nVlLib pois se venda fosse	  º±±	 
±±º              ³        ³      ³reprovada por data de limite o valor    º±±	
±±º              ³        ³      ³ficava negativo.                        º±±
±±³Marcos Roberto³17/04/06³DELLA ³Incluido os parametro cliente e loja    ³±±
±±³              ³        ³VIA   ³para forcar a busca do mesmo cliente    ³±±
±±º              ³        ³      ³no SA1.                                 º±± 
±±³Marcos Roberto³12/07/06³102337³Melhoria na exibicao dos  valores para  º±±
±±º              ³        ³      ³analise de credito.                     º±±       
±±ºMarcos Roberto³21/11/06³107820³Inclusao do codigo do vendedor na tela  º±±
±±º              ³        ³      ³do analista de credito.                 º±±
±±³Marcos Roberto|25/11/06|Dadalto|Bloquear a venda por passagem de risco. ³±± 
±±º              ³        ³      ³                                        º±±	
±±ºMarcos Roberto|24/01/06|116324|Utilizacao da funcao CrdXTela para      º±±
±±º              ³        ³      ³calcular o tamanho da tela              º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function CRM010_006( nTipo  	, cCliente  ,cLojaCli  ,nRecnoMAR,; 
					lCra080Aval )                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nTipo 1 Consulta de classificacao do cliente, chamada do menu                             ³
//³		 2 Classificação chamada do registro do cliente na FICHA CADASTRAL                   ³
//³      3 Liberação para efetivação  (mesma tela do ntipo 1 com a opcao de liberar crédito) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oDlgAn
Local oCombo
Local aItems		:= {STR0042,STR0043}  //"SIM"###"NAO"
Local cCombo		:= aItems[2]

Local aSize			:= MsAdvSize( .F., .T., 280 )
Local aObjects		:= {} 		//Array de objetos
Local aInfo			:= {}    	//Utilizado pelo advsize
Local aPosObj		:= {}		//Array da posicao dos objetos na tela
Local aAnalise		:= {}		//Array que armazena a analise do perfil do cliente

Local bOk			:= {}		//botao OK			
Local bCancel		:= {}   	//botao cancelar
Local aButtons		:= {}   	//array com os botoes
Local oBold						//Fonte tamanho 14	
Local oBold1                   	//Fonte tamanho 16
Local oBold2                   	//Fonte	tamanho 11
Local oBold3                   	//Fonte	tamanho 10

//Utilizadas na leitura do arquivo texto (produto e forma de pagamento)
Local oEnchoice
Local aHeaderSL2 	:= {}		// Cabecalho da GetDados de produtos
Local aColsSL2   	:= {}    	// Itens do acols de produtos
Local aCols2SL4   	:= {}  		// Itens do acols da forma de pagamento
Local aHeaderSL4 	:= {}		// Cabecalho da get dados da forma de pagamento
Local oGetSL2					// Objeto da GetDados de produtos
Local oGetSL4         			// Objeto da GetDados forma de pagamento
Local cCondPg	 	:= ""		// Variavel com a condicao de pagamento da venda
Local cDescCond	 	:= ""		// Variavel com a descricao da condicao de pagamento da venda                                      

Local nLimCred  	:= 0   		//Valor do limite de credito
Local nBloqueio 	:= 0 		//Valor da compra
Local nPrestac  	:= 0		//Valor das prestacoes em aberto
Local nVlLib    	:= 0   		//Valor a ser liberado          
Local nExcedente	:= 0		//Valor excedente do limite de credito
Local cCodCli   	:= ""		//Codigo do cliente
Local cLoja     	:= ""		//Loja
Local nSele     	:= 0  		//Indica qual botao foi pressionado. 1) OK; 2) Cancelado
Local cLinha    	:= 0 		//retorna a linha do arquivo para leitura dos dados.
Local aColsSL4  	:= {}		//Array com as formas de pagamento
Local cResto    	:= ""		//Recebe como conteudo  as informacoes de cLinha
Local nCntFor   	:= 0		//Contador
Local nVlrParc		:= 0		//Valor da parcela
Local nPosMes   	:= 0		//Posicao do mes
Local nReg     		:= 0 		//Numero do registro
Local nTitAberto	:= 0		//Titulos em aberto
Local nDisponivel	:= 0 		//Valor disponivel
Local nX          	:= 0 		//Contador
Local nRecnoMA7    	:= 0       	// Recno do registro do MA7(cliente avaliado)
Local aSaldoMeses	:= {}		// Contem os saldos dos titulos em aberto agrupados por meses (Endividamento Mensal)
Local aFuncUser		:= {}      				// Funcoes do usuario chamados da toolbar
Local dDtVencLC     := Ctod("  /  /  ")  	// Data de vencimento do limite de credito
Local lLibera		:= .T.
Local cTipEndv      := "" 	               	// Determina o endividamento do cliente: "1"-mensal;"2"-global
Local nTotCred		:= 0					// Total do cliente ( Parcelas em aberto + valor finan) - Notas de credito
Local nTotNCC		:= 0					// Total de Notas de Credito
Local cVlNccArq     := ""					// Valor da NCC usada na venda - este valor vem do arquivo arqpar
Local cTpCred		:= ""					// Tipo de endividamento                               
Local cMsgBtn		:= STR0138				// Mensagem do botao Ok
Local cVend			:= ""					// Codigo do vendedor
Local cNreduz		:= ""					// Nome do vendedor 
Local cMsgBloq		:= ""					// Mensagem informando o motivo do bloqueio.
Local nNumBlq		:= 0					// Numero do bloqueio

Default cCliente	:= ""					//Codigo do cliente 
Default cLojaCli	:= ""                 	//Loja
Default nRecnoMAR   := 0                   	//Recno do MAR gerado pelo CRDA080/CRDA180
Default lCra080Aval:= .F.				   	// Indica se a rotina esta sendo chamada da rotina CRDA080AVAL

If INCLUI
	MsgStop(STR0048,STR0049) //"Rotina não disponível na inclusão."###"Atenção !"
	lLibera := .F.
Endif

If lLibera .AND. !SoftLock("MA7")
	lLibera := .F.
Endif              

If lCra080Aval
	cMsgBtn := STR0143
Endif

If lLibera

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se está no crediario e nao deixar reenviar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FunName() = "CRDA180"
		aItems := {STR0042,STR0043}					//"SIM"###"NAO"
		cCombo:= aItems[2]							//cCombo = Nao		
	Else
		aItems := {STR0042,STR0043,STR0044,"  "}  	//"SIM"###"NAO"###"CRED"
		cCombo:= aItems[4]							//cCombo = Vazio para forcar o usuario a escolher	
	Endif	    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retornar índice padrão para manter a funcionalidade de outras funcoes que utilizam o cadastro.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !Empty(cCliente) .AND. !Empty(cLojaCli)
		cCodcli  := cCliente
		cLoja    := cLojaCli
	Else
		cCodcli  := M->MA7_CODCLI
		cLoja    := M->MA7_LOJA
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³bloco de código para os botões³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o usuario clicar no botao ok e nao estiver escolhido nenhuma opcao,                     ³
	//³o sistema emite mensagem de aviso.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bOk     := {|| IIF(Empty(cCombo), Aviso( STR0049, cMsgBtn, {"Ok"} ) , ;
				(nSele := 1,;
				 CRA080_002(nTipo, 	M->A1_COD,	M->A1_LOJA,	nExcedente,;
				 			cCombo,	nPrestac),;         
				 oDlgAn:End()) )  }
				
	bCancel := {||(nSele := 2,oDlgAn:End())}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se a rotina está sendo chamada pela liberação de crédito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nTipo == 3 .OR. nTipo == 2  
		cVlNccArq	:= ""
		
		If nTipo == 3
	
			aAdd(aButtons,{"POSCLI"   , {|| CRC010_019(1, nRecnoMAR)}, STR0056, STR0060 })	 	//"Consultar Cadastro de Cliente", "CLIENTE"
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Informacoes do produto e forma de pagamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CRM010_012(	@aHeaderSL2	,;	// 01 Cabecalho dos produtos
						@aColsSL2	,; 	// 02 Acols produto
						@aHeaderSL4 ,;	// 03 Cabecalho da forma de pagamento
						@aCols2SL4	,;	// 04 Acols forma de pagamento
						@cCondPg	,;	// 05 Codigo da condicao de pagamento
						@cDescCond	,;	// 06 Descricao da condicao de pagamento
						@cVlNccArq	,;	// 07 Valor de NCC usada na venda
						@cVend)			// 08 Codigo do vendedor

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para customizacao da toolbar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock( "CRDLIBCR" )
			   aFuncUser := ExecBlock( "CRDLIBCR", .F., .F. )	
			   If ValType( aFuncUser ) == "A"    		
				  For nX := 1 to Len( aFuncUser )
				     aAdd( aButtons, aFuncUser[nX] )
				  Next nX
			   Endif
			Endif		
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica bloqueio do cliente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->MA7_BLOQUE $ "1/4"
				nBloqueio:= M->MA7_VLRBL       	//Valor da compra
			Else
				Msgstop(STR0057) 				//"Este cliente não necessita de desbloqueio"
				Return .T.
			Endif
			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena o codigo do vendedor                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cVend)
			DbSelectArea("SA3")
			DbSetOrder(1)
			If DbSeek(xFilial("SA3")+cVend)
		   		cNreduz  := SA3->A3_NREDUZ
			Endif
		Endif
		dbSelectarea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+cCodCli+cLoja )
			nLimCred  := SA1->A1_LC
			dDtVencLC := SA1->A1_VENCLC
		Endif
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o total das parcelas a receber em aberto (independente do endividamento)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPrestac := CrdTitAberto(	cCodCli		,;	//01 Codigo do cliente
									cLoja		,;	//02 Loja
									Nil			,;	//03 Tipo da consulta ( 1- Mensal 2- Total)
									Nil			,;	//04 Periodo da consulta AAAAMM 
									@aSaldoMeses,;	//05 Array com o saldo do mes
									Nil			,;	//06 Array com as NCCs usadas na venda
									@nTotNCC	,;	//07 Valor de NCC em aberto do cliente
									.T.			)	//08 Indica nao abater as NCCs da parcelas em aberto	
		If !Empty(cVlNccArq)	    
			nTotNCC	:= nTotNCC - VAL( cVlNccArq )
		Endif	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Endividamento global ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->MA7_TPCRED <> "1"  
		    nTitAberto  := nPrestac	
			cTpCred 	:= STR0161 		//Global
			DbSelectArea("MA7")
			DbSetOrder(1)
			If DbSeek(xFilial("MA7")+cCodCli+cLoja)		    		
			   	nRecnoMA7  	:= Recno()         
			   	If MA7->(FieldPos("MA7_NUMBLQ") > 0)
			   		If !Empty(MA7->MA7_NUMBLQ	)
			   			nNumBlq		:= Val(MA7->MA7_NUMBLQ	)
			   			cMsgBloq 	:= CRD010XMsg(nNumBlq)
			   		Endif
			   	Endif
			Endif   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Endividamento mensal	    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else					   
			cTpCred := STR0162	//Mensal
			If Len( aSaldoMeses ) > 0
				aSaldoMeses := aSort(aSaldoMeses,,,{|x,y| x[1]> y[1] })
				nTitAberto  := aSaldoMeses[1][1]
			Endif
			
	
			DbSelectArea("MA7")
			DbSetOrder(1)
			If DbSeek(xfilial("MA7")+cCodcli+cLoja)
				If MA7->(FieldPos("MA7_NUMBLQ") > 0)
			   		If !Empty(MA7->MA7_NUMBLQ	)
			   			nNumBlq	:= Val(MA7->MA7_NUMBLQ	)
			   			cMsgBloq 	:= CRD010XMsg(nNumBlq)
			   		Endif
			   	Endif
			Endif
	
			DbSelectArea( "MAL" )	
			DbSetOrder( 1 )
			DbSeek( xFilial( "MAL" ) + MA7->MA7_CONTRA )
			
			While !Eof() .AND. xFilial( "MAL" )+MA7->MA7_CONTRA == MAL_FILIAL+MAL_CONTRA
				aAdd(aColsSL4,Array(4) )
				aColsSL4[Len(aColsSL4)][1] := MAL_VENCTO
				aColsSL4[Len(aColsSL4)][2] := MAL_VALOR
				aColsSL4[Len(aColsSL4)][3] := ""
				aColsSL4[Len(aColsSL4)][4] := .F.									
				
				DbSkip()
			End			
		Endif                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor disponivel ate atingir o limite de credito. Calculado sobre o limite ja utilizado pelo cliente ³
		//³com relacao ao limite de credito(A1_LC)															    ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		nDisponivel := If(SA1->A1_LC-nTitAberto > 0, SA1->A1_LC-nTitAberto, 0)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³(valor das parcelas + valor bloqueado) - Limite de crédito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlLib   := (nPrestac + nBloqueio) - nLimCred
			 
		If nPrestac > nLimCred 
			nVlLib   := nVlLib - (nPrestac - nLimCred)
		Endif
		
		nVlLib := ABS( nVlLib )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor para analise de credito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotCred := (nPrestac + nBloqueio ) - nTotNCC
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz o calculo do valor excedente (o real valor que devera ser liberado para o cliente)³
		//³considerando o tipo de endividamento do cliente(Mensal ou geral)                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipEndv  := MA7->MA7_TPCRED
		If cTipEndv == "2" 	//Global
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Endividamento global ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nExcedente := IIf(nPrestac > nLimCred,(nPrestac-nLimCred)+nVlLib, nVlLib)

		ElseIf cTipEndv == "1" 	//Mensal		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Endividamento mensal                                        ³
			//³Obtem o valor da parcela do mes com o maior saldo de titulos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
			For nCntFor := 1 to Len(aColsSL4)
				If Len( aSaldoMeses ) > 0
					If (nPosMes := aScan(aSaldoMeses,{|x| x[2] == Left(DTOS(aColsSL4[nCntFor][1]),6) })) > 0 
						If (aColsSL4[nCntFor][2] + aSaldoMeses[nPosMes][1]) > nVlrParc
							nVlrParc  := aColsSL4[nCntFor][2] + aSaldoMeses[nPosMes][1]
						Endif 
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso nao encontre o mes no aSaldoMeses, continua procurando no     ³
						//³aColsSL4 se possui algum valor que seja maior que os meses apurados³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aColsSL4[nCntFor][2] > nVlrParc
							nVlrParc  := aColsSL4[nCntFor][2]
						Endif 
					Endif	
				Else
					If aColsSL4[nCntFor][2] > nVlrParc
						nVlrParc  := aColsSL4[nCntFor][2]
					Endif	
				Endif
			Next nCntFor
		
			nExcedente := IIf(nVlrParc > nLimCred,(nVlrParc - nLimCred), nVlrParc)
		
		EndIf
		
	Endif         
	
	aAnalise:=  CRC070_002(nTipo,cCodcli,cLoja)
	  

	If len(aAnalise ) > 0
		
		aAdd( aObjects, { 100, 100, .T., .T., .F. } )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 15 }
		aPosObj := MsObjSize( aInfo, aObjects)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ verifico a origem no nTipo (  2 - é chamado do cadastro de cliente, somente para consulta³
		//³                               3 - rotina de liberação de crédito, executado do menu      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo == 2
			cLabel:= STR0058 //"Análise do Cliente"
		Else
			cLabel:= STR0059 //"Liberação"
		Endif

		DEFINE FONT oBold	NAME "Arial" SIZE 0, -11 BOLD
		DEFINE FONT oBold1	NAME "Arial" SIZE 0, -11 BOLD 
		DEFINE FONT oBold2	NAME "Arial" SIZE 0, -11 BOLD
		DEFINE FONT oBold3	NAME "Arial" SIZE 0, -10 BOLD
		
		// Tela principal.	
		DEFINE MSDIALOG oDlgAn TITLE cLabel FROM CRDxTela(182), CRDxTela(137);
			TO CRDxTela(667 ), CRDxTela(906) PIXEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria as Groups do Sistema³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ CRDxTela(027),CRDxTela(002) TO CRDxTela(84),CRDxTela(151) LABEL "" PIXEL OF oDlgAn
		@ CRDxTela(027),CRDxTela(153) TO CRDxTela(154),CRDxTela(383) LABEL "" PIXEL OF oDlgAn // Group getdados.
		@ CRDxTela(086),CRDxTela(002) TO CRDxTela(154),CRDxTela(151) LABEL "" PIXEL OF oDlgAn
		@ CRDxTela(156),CRDxTela(002) TO CRDxTela(241),CRDxTela(151) LABEL "" PIXEL OF oDlgAn
		@ CRDxTela(156),CRDxTela(153) TO CRDxTela(241),CRDxTela(383) LABEL "" PIXEL OF oDlgAn // Group liberacao do credito.
		                		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Get dados de produtos e condicao de pagamento.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		oGetSL2 := MsNEWGetDados():New(	CRDxTela(032), CRDxTela(156)		,;	// 01, 02
										CRDxTela(085), CRDxTela(379)		,;	// 03, 04
										Nil									,;	// 05
										"AllWaysTrue"						,;	// 06
										"AllWaysTrue"						,;	// 07
										Nil									,;	// 08
										Nil									,;	// 09
										Nil									,;	// 10
										Nil									,;	// 11
										Nil									,;	// 12
										Nil									,;	// 13
										Nil									,;	// 14
										oDlgAn								,;	// 15
										aHeaderSL2 							,;	// 16
										aColsSL2							)	// 17

		@CRDxTela(088), CRDxTela(156) 	Say STR0139 + ": " + cCondPg + " - " + cDescCond;
			PIXEL OF oDlgAn FONT oBold 		// Condicao de pagamento.

		oGetSL4 := MsNEWGetDados():New(	CRDxTela(096), CRDxTela(156),;		// 01, 02
										CRDxTela(152), CRDxTela(379),;		// 03, 04
										Nil									,;	// 05
										"AllWaysTrue"						,;	// 06
										"AllWaysTrue"						,;	// 07
										Nil									,;	// 08
										Nil									,;	// 09
										Nil									,;	// 10
										Nil									,;	// 11
										Nil									,;	// 12
										Nil									,;	// 13
										Nil									,;	// 14
										oDlgAn								,;	// 15
										aHeaderSL4 							,;	// 16
										aCols2SL4							)	// 17
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cliente                                                                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(030), CRDxTela(005)	Say STR0092;
			Size CRDxTela(050),CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(030), CRDxTela(028)	Say M->A1_NOME;
			Size CRDxTela(122),CRDxTela(009) Of oDlgAn COLOR CLR_BLACK  Pixel FONT oBold3
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bairro                                                                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(040), CRDxTela(005) Say STR0144;
			Size CRDxTela(050), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(040), CRDxTela(028) Say M->A1_BAIRRO;
			Size CRDxTela(122), CRDxTela(009) Of oDlgAn COLOR CLR_BLACK  Pixel FONT oBold3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cidade / Estado                                                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(050), CRDxTela(005) Say STR0145;
			Size CRDxTela(050), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(050), CRDxTela(028) Say trim(M->A1_MUN) + " / " + M->A1_EST;
			Size CRDxTela(122), CRDxTela(009) Of oDlgAn COLOR CLR_BLACK  Pixel FONT oBold3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CEP                                                                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											                                            
		@CRDxTela(060), CRDxTela(005) Say STR0146;
			Size CRDxTela(050), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(060), CRDxTela(028) Say Transform(M->A1_CEP, PesqPict("SA1","A1_CEP"));
			Size CRDxTela(122), CRDxTela(009) Of oDlgAn Pixel FONT oBold3 COLOR CLR_BLACK

	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Telefone                                                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											 	
		@CRDxTela(070), CRDxTela(005) Say STR0147;
			Size CRDxTela(070), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(070), CRDxTela(033) Say M->A1_TEL;
			Size CRDxTela(122), CRDxTela(009) Of oDlgAn  Pixel COLOR CLR_BLACK FONT oBold3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Data Primeira Compra                                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(090), CRDxTela(005) Say STR0148;
			Size CRDxTela(070), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(090), CRDxTela(069) Say M->A1_PRICOM;
			Size CRDxTela(120), CRDxTela(009) Of oDlgAn Pixel FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Data Ultima Compra                                                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(100), CRDxTela(005) Say STR0149;
			Size CRDxTela(070), CRDxTela(009) Of oDlgAn Pixel
		@CRDxTela(100), CRDxTela(069) Say M->A1_ULTCOM;
			Size CRDxTela(120), CRDxTela(009) Of oDlgAn Pixel FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Media Atraso                                                                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											
		@CRDxTela(110), CRDxTela(005) Say STR0150;
			Size CRDxTela(070), CRDxTela(009)	Of oDlgAn Pixel
		@CRDxTela(110), CRDxTela(069) Say M->A1_METR;
			Size CRDxTela(120), CRDxTela(009)	Of oDlgAn  Pixel FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de endividamento                                                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                            
		@CRDxTela(120), CRDxTela(005) Say STR0151;
			Size CRDxTela(070), CRDxTela(009)	Of oDlgAn Pixel
		@CRDxTela(120), CRDxTela(069) Say cTpCred;
			Size CRDxTela(120), CRDxTela(009)	Of oDlgAn  Pixel FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Vendedor                                                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                            
		@CRDxTela(130), CRDxTela(005) Say STR0163;
			Size CRDxTela(040), CRDxTela(009)	Of oDlgAn Pixel
		@CRDxTela(130), CRDxTela(051) Say cVend + IIf(empty(cNreduz), "", " - " + cNreduz);
			Size CRDxTela(120), CRDxTela(009)	Of oDlgAn  Pixel FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movivo do Bloqueio:                                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MA7->(FieldPos("MA7_NUMBLQ") > 0)
			@CRDxTela(140), CRDxTela(005)	Say STR0164;
				Size CRDxTela(070), CRDxTela(009) Of oDlgAn Pixel
			@CRDxTela(140), CRDxTela(051)	Say cMsgBloq;
				Size CRDxTela(120), CRDxTela(009) Of oDlgAn  Pixel COLOR CLR_RED FONT oBold2
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Observacao                                                                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@CRDxTela(162), CRDxTela(005)	Say STR0152;
			Size CRDxTela(040), CRDxTela(009) OF oDlgAn Pixel
		@CRDxTela(172), CRDxTela(007)	Say MA7->MA7_MOTTRA;
			Size CRDxTela(114), CRDxTela(030) Of oDlgAn FONT oBold3 Pixel

	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Classificacao do cliente          							   	                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
		@CRDxTela(192), CRDxTela(005)	Say STR0153;
			Size CRDxTela(120), CRDxTela(009) PIXEL Of oDlgAn FONT oBold1
		@CRDxTela(201), CRDxTela(005)	Bitmap oBmp RESOURCE aAnalise[4];
			Size CRDxTela(150), CRDxTela(360) PIXEL Of oDlgAn NOBORDER
		@CRDxTela(207), CRDxTela(025)	Say aAnalise[3];
			Size CRDxTela(114), CRDxTela(009) PIXEL Of oDlgAn FONT oBold2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analise de Credito                                                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aAnalise[5])
			@CRDxTela(224), CRDxTela(005) BITMAP oBmp RESOURCE aAnalise[5];
				SIZE CRDxTela(050), CRDxTela(200) PIXEL Of oDlgAn NOBORDER
			@CRDxTela(224), CRDxTela(025)	SAY STR0031;
				SIZE CRDxTela(114), CRDxTela(009) PIXEL Of oDlgAn FONT oBold2
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analise de perfil                                                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aAnalise[6])
			@CRDxTela(231), CRDxTela(005) 	BITMAP oBmp RESOURCE aAnalise[6];
				SIZE CRDxTela(050), CRDxTela(30) PIXEL Of oDlgAn NOBORDER
			@CRDxTela(231), CRDxTela(025)	SAY STR0032;
				SIZE CRDxTela(114), CRDxTela(009) PIXEL Of oDlgAn FONT oBold2
		Endif

		If nTipo == 3 .OR. nTipo == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dt. Venc. Credito                                                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@CRDxTela(169), CRDxTela(155) Say STR0061;
				Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold OF oDlgAn
			@CRDxTela(168), CRDxTela(218) Say dDtVencLC;
				Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold OF oDlgAn RIGHT

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parcelas em aberto                                                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@CRDxTela(184), CRDxTela(155) Say STR0154;
				Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn
			@CRDxTela(184), CRDxTela(218) Say nPrestac PICTURE PesqPict("MAL","MAL_VALOR");
				Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn RIGHT

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limite de Credito                                                                                       ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@CRDxTela(168), CRDxTela(272) Say STR0155;
				Size CRDxTela(070), CRDxTela(009) COLOR CLR_BLUE FONT oBold1 PIXEL OF oDlgAn
			@CRDxTela(168), CRDxTela(333) Say nLimCred Picture PesqPict("SA1","A1_LC");
				Size CRDxTela(040), CRDxTela(009) COLOR CLR_BLUE FONT oBold1 PIXEL OF oDlgAn RIGHT

			If nTipo == 3                                                              				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Confirma a liberacao de credito                                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ CRDxTela(216), CRDxTela(272) Say STR0169;
					Size CRDxTela(090), CRDxTela(009) COLOR CLR_BLUE FONT oBold PIXEL OF oDlgAn
				oCombo := tComboBox():New(	CRDxTela(216),									;	//01
											CRDxTela(345),									;	//02                        
											{|u| IIf(Pcount()>0, cCombo := u, cCombo)},	;	//03
											aItems,											;	//04
											CRDxTela(028),									;	//05
											CRDxTela(010),									;	//06
											oDlgAn,											;	//07
											Nil,											;	//08
											Nil,											;	//09
											Nil,											;	//10
											Nil,											;	//11
											Nil,											;	//12
											.T.,											;	//13
											Nil,											;	//14
											Nil,											;	//15
											Nil,											;	//16
											Nil,											;	//17
											Nil,											;	//18
											Nil,											;	//19
											Nil,											;	//20
											Nil,											;	//21
											"cCombo")                                       	//22

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor Excedido do limite                                                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@CRDxTela(184), CRDxTela(272)	Say STR0156;
					Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold1 OF oDlgAn

				If cTipEndv == "2"  // Se for endividamento global.
					@CRDxTela(184), CRDxTela(333) Say max(nPrestac + nBloqueio - nLimCred ,0) Picture PesqPict("MAL","MAL_VALOR");
				   		Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold1 OF oDlgAn RIGHT
                ElseIf cTipEndv == "1"  // Se for endividamento mensal.
					@CRDxTela(184), CRDxTela(333) Say nExcedente Picture PesqPict("MAL","MAL_VALOR");
					 	Size CRDxTela(040), CRDxTela(009) COLOR CLR_BLACK PIXEL FONT oBold1 OF oDlgAn RIGHT
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor Financiado                                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 	@CRDxTela(200), CRDxTela(155) Say STR0157;
			 		Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn
				@CRDxTela(200), CRDxTela(218) Say nBloqueio Picture PesqPict("MAL","MAL_VALOR");
					Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold OF oDlgAn RIGHT

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor a Liberar                                                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@CRDxTela(200), CRDxTela(272)	Say STR0158;
					Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold1 PIXEL OF oDlgAn
				@CRDxTela(200), CRDxTela(333) 	Say nVlLib Picture PesqPict("MAL","MAL_VALOR");
					Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold1 OF oDlgAn RIGHT

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Notas de Credito                                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 
				@CRDxTela(216), CRDxTela(155) Say STR0159;
					Size CRDxTela(070), CRDxTela(009) COLOR CLR_BLUE FONT oBold PIXEL OF oDlgAn
                @CRDxTela(216), CRDxTela(218) Say nTotNCC Picture PesqPict("MAL","MAL_VALOR");
                	Size CRDxTela(040), CRDxTela(009) COLOR CLR_BLUE PIXEL FONT oBold OF oDlgAn RIGHT

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor para Analise de Credito                                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@CRDxTela(229), CRDxTela(155) Say STR0160;
					Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn
    			@CRDxTela(229), CRDxTela(218) Say nTotCred Picture PesqPict("MAL","MAL_VALOR");
    				Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn RIGHT

			ElseIf nTipo == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Limite Utilizado                                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 	@CRDxTela(200), CRDxTela(155) Say STR0067;
			 		Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn
				@CRDxTela(200), CRDxTela(218) Say nTitAberto Picture PesqPict("MAL","MAL_VALOR");
					Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold OF oDlgAn RIGHT

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Limite Disponivel                                                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
				@CRDxTela(216), CRDxTela(155) Say STR0068;
					Size CRDxTela(070), CRDxTela(009) COLOR CLR_RED FONT oBold PIXEL OF oDlgAn
				@CRDxTela(216), CRDxTela(218) Say nDisponivel Picture PesqPict("MAL","MAL_VALOR");
					Size CRDxTela(040), CRDxTela(009) COLOR CLR_RED PIXEL FONT oBold OF oDlgAn RIGHT
			Endif
		Endif

		ACTIVATE MSDIALOG oDlgAn CENTERED ON INIT (EnchoiceBar(oDlgAn,bOk,bCancel,,aButtons)) VALID (IIf(nSele == 0, nSele := 2, NIL))
	Else
		MsgStop(STR0069) //"Não há registros a serem analisados"
	Endif
	
	If nSele <> 0
	   DbSelectArea("MA7")
	   DbSetOrder(1)	   
	   If nRecnoMA7 > 0
	      DbGoto(nRecnoMA7)	      
	   Else
		  DbSeek(xFilial("MA7")+cCodCli+cLoja)		    	         
	   Endif   
	   MsUnlock()
	Endif
	
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_007ºAutor  ³Frank Zwarg Fuga    º Data ³  07/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se os campos obrigatorios foram preenchidos.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRD010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_007(nOpcx)
Local nX 				:= 0 
Local nY 				:= 0  
Local nPassos			:= 0
Local cAcols			:= ""
Local cAHeader			:= ""
Local cAux				:= "" 
Local cDocAux			:= "" 
Local cDocPasta			:= ""
Local nPos1				:= 0 
Local nPos2				:= 0 
Local nPos3				:= 0
Local lRet 				:= .T.  
Local lSem_Quest		:= .T.
Local lTemRegistro    	:= .F.    //Controla quando exclui todas as linhas do aCols de uma determinada referencia obrigatoria
Local cCampoCriticado	:= ""
Local nPMacCartao		   		// Possicao na array do Cartao adicional para dependente
Local nPMacDepNom				// Possicao na array do Nome do dependente
Local nPMacDepDTN				// Possicao na array do Data nascimento do dependente
Local nPMacDepGra				// Possicao na array do Grau de parentesco       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada templates para validar as informacoes do cadastro de Clientes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CRDGRAVA")                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nOpcx            ³
	//³ 2 -> Visualizacao³
	//³ 3 -> Inclusao    ³
	//³ 4 -> Alteracao   ³
	//³ 5 -> Exclusao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := ExecTemplate("CRDGRAVA",.F.,.F.,{nOpcx})
Endif                    

If ExistBlock("CRDGRAVA")                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nOpcx            ³
	//³ 2 -> Visualizacao³
	//³ 3 -> Inclusao    ³
	//³ 4 -> Alteracao   ³
	//³ 5 -> Exclusao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := ExecBlock("CRDGRAVA",.F.,.F.,{nOpcx})
Endif            

If !lRet
	Return lRet
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for Exclusao nao faz a validacao dos acols.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisar se existem ocorrencias no cadastro que controla a numeracao do contrato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := CRDDELCLI()
	Return lRet
Endif

If  !CRD10CGCOK(.T.)  
	lRet := .F.
	Return lRet
EndIf               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validar as enchoices³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Obrigatorio(aGets1, aTela1) .OR. !Obrigatorio(aGets2, aTela2)
   Return .F.
Endif          

MA5->( DbSetOrder(2) ) // filial + questionario + pergunta
lSem_Quest := ! ( MA5->( DbSeek( xFilial("MA5") + SuperGetMV("MV_QUEST") ) ) )//Se Quest. padrao existir critico digitacao, senao nao critico Questionario Socio Economico
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validar os acols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPassos := 1 to 8
	lTemRegistro  := .F.
	cAcols   := "oGetd" + AllTrim( Str( nPassos ) ) + ":aCols" 
	cAheader := "aHeader" + AllTrim( Str( nPassos ) )

	For nY := 1 to Len( &(cAcols) )

      If ! &(cAcols+"["+str(nY)+"]["+str(&('len('+caheader+')+1'))+"]")
         lTemRegistro  := .T.
         For nX := 1 to Len( &(cAheader) )      
      
            If X3OBRIGAT( &(caHeader+"["+str(nX)+"][02]") ) .AND.;
               Empty( &(cAcols+"["+str(nY)+"]["+str(nX)+"]") )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o questionario padrao nao existir, nao critico digitacao do Questionario Socio Economico³
					//³Os outros campos obrigatorios sao criticados sempre                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCampoCriticado := &( caHeader+"["+str(nX)+"][02]")
					If ! ( lSem_Quest .and. AllTrim(cCampoCriticado) == "MAI_RESP" )
						cAux := STR0071 + &(caHeader+"["+str(nX)+"][01]") +; //"Faltou o preenchimento do campo "
					    STR0072 + CRM010_009(Alltrim(str(nPassos))) //" localizado na pasta"
						
						msgstop(cAux)
						Return .F.
					Endif
      
				Endif

			Next nX
         
         // validacao de documentos com entrega obrigatoria
         If nPassos == 7
         
	         nPos1:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_CONTR"})	//posicao do campo controle de recebimento
	         nPos2:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_SITUA"})	//situacao do documento: 1=entregue;2=pendente
	         nPos3:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_DESCR"})	//Documento
         
		      IF &(cAcols+"["+str(nY)+"]["+str(npos1)+"]") == "1" .AND. &(cAcols+"["+str(nY)+"]["+str(npos2)+"]") == "2"

					If Empty(cDocAux)                
					
						cDocAux := STR0073 + &(cAcols+"["+str(nY)+"]["+str(npos3)+"]") //"O documento "
						cDocPasta := CRM010_009(Alltrim(str(nPassos)))
					Else							
					
						cDocAux += ", "+ &(cAcols+"["+str(nY)+"]["+str(npos3)+"]")
						
					Endif
						  	            
            Endif
               
         Endif
      
         // validacao da pasta de dependentes
         If nPassos == 5         
	         nPMacCartao	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"})	// Cartao adicional para dependente
	         nPMacDepNom	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPNOM"})	// Nome do dependente
	         nPMacDepDTN	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPDTN"})	// Data nascimento do dependente
	         nPMacDepGra	:= ascan(aHeader5,{|x| Trim(x[2]) == "MAC_DEPGRA"})	// Grau de parentesco


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifico a Linha de dependente esta toda preenchida (para gravacao) ou                     ³
				//³toda em branco (serah descartada)                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     IF  empty( &(cAcols+"["+str(nY)+"]["+str(nPMacCartao)+"]") ) .or. ;
		         empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepNom)+"]") ) .or. ;
		         empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepDTN)+"]") ) .or. ;
		         empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepGra)+"]") )

			     IF  !empty( &(cAcols+"["+str(nY)+"]["+str(nPMacCartao)+"]") ) .or. ;
			         !empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepNom)+"]") ) .or. ;
			         !empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepDTN)+"]") ) .or. ;
		    	     !empty( &(cAcols+"["+str(nY)+"]["+str(nPMacDepGra)+"]") )
		    	     
		    	     //"Preencha os campos Cartao, Nome, Data de nascimento e grau de parentesco na pasta Dependente."
	            	 MsgStop(STR0142)
	    	         Return .F.
	    	      Endif    	         
	    	      Endif    	         
              Endif
		Endif


   Next nY     
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Validar os casos em que a(s) linha(s) do aCols e(sao) deletadas  ³
   //³e nao ira gravar nenhum registro para campos obrigatorios		³		
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
   If !lTemRegistro
      For nY := 1 to Len( &(cAcols) )
         For nX := 1 to Len( &(cAheader) )      
            If X3OBRIGAT( &(caHeader+"["+str(nX)+"][02]"))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o questionario padrao nao existir, nao critico digitacao do Questionario Socio Economico³
				//³Os outros campos obrigatorios sao criticados sempre                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCampoCriticado := &( caHeader+"["+str(nX)+"][02]")
				If ! ( lSem_Quest .AND. AllTrim(cCampoCriticado) == "MAI_RESP" )
	               cAux := STR0071 + &(caHeader+"["+str(nX)+"][01]") +; //"Faltou o preenchimento do campo "
    	           STR0072 + CRM010_009(Alltrim(str(nPassos))) //" localizado na pasta"
               
        	       MsgStop(cAux)
      
            	   Return .F.
				Endif      
            Endif         
         Next nX
      Next nY
   Endif   
Next nPassos
          
If !Empty(cDocAux)
	cDocAux += 	STR0074 +; //" é de Entrega obrigatoria."
	STR0075 + cDocPasta //" Preenchimento na pasta "
               
	lRet := msgyesno(cDocAux,STR0076) //"Deseja continuar?"
Endif	

Return lRet 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_008ºAutor  ³Frank Zwarg Fuga    º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao das linhas das getdados.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cObj = identifica qual getdados esta sendo validada         º±±
±±º          ³cTipo = identifica se esta validando a linha ou todo acols  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CRM010_008(cObj, cTipo)
Local cAcols
Local cAheader
Local cAux
Local lRet := .T.  
Local nX := 0
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao validar se for na visualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcVal == 2
	Return .T.
Endif

If cObj == '8'
	MA5->( DbSetOrder(2) ) // filial + questionario + pergunta
	IF 	!MA5->( DbSeek( xFilial("MA5") + SuperGetMV("MV_QUEST") ) )	// Se o Questionario padrao existir critico a digitacao, 	
		Return .T.												// caso contrario nao critico Questionario Socio Economico
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponte de Entrada de Templates para						  ³
//³Validacao da linha da GetDados do cadastro de clientes(CRD)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CRDCAR")
	lRet := ExecTemplate("CRDCAR",.F.,.F.,{cObj, cTipo, nOpcVal,oGetd1:aCols,oGetd2:aCols,oGetd3:aCols,oGetd4:aCols,oGetd5:aCols,oGetd6:aCols,oGetd7:aCols,oGetd8:aCols,oGetd1:aHeader,oGetd2:aHeader,oGetd3:aHeader,oGetd4:aHeader,oGetd5:aHeader,oGetd6:aHeader,oGetd7:aHeader,oGetd8:aHeader })
Endif

If ExistBlock("CRDCAR")
	lRet := ExecBlock("CRDCAR",.F.,.F.,{cObj, cTipo, nOpcVal,oGetd1:aCols,oGetd2:aCols,oGetd3:aCols,oGetd4:aCols,oGetd5:aCols,oGetd6:aCols,oGetd7:aCols,oGetd8:aCols,oGetd1:aHeader,oGetd2:aHeader,oGetd3:aHeader,oGetd4:aHeader,oGetd5:aHeader,oGetd6:aHeader,oGetd7:aHeader,oGetd8:aHeader })
Endif

If lRet
	If cTipo == 'T'
		cAcols   := "oGetd" + cObj + ":aCols"
		cAheader := "aHeader" + cObj
		For nY := 1 to Len( &(cAcols) )
			If ! &(cAcols+"["+str(nY)+"]["+str(&('len('+caheader+')+1'))+"]")
				For nX := 1 to Len( &(cAheader) )
					If X3OBRIGAT( &(caHeader+"["+str(nX)+"][02]") ) .AND. Empty( &(cAcols+"["+str(nY)+"]["+str(nX)+"]") )
						cAux := STR0071 + &(caHeader+"["+str(nX)+"][01]") +; //"Faltou o preenchimento do campo "
						STR0072 + CRM010_009(cObj) //" localizado na pasta"
						MsgStop(cAux)
						Return .F.
					Endif
				Next nX
			Endif
		Next nY
	Else
		cAcols   := "oGetd" + cObj + ":aCols"
		cAheader := "aHeader" + cObj
		If ! &(cAcols+"["+str(n)+"]["+str(&('len('+caheader+')+1'))+"]")
			For nX := 1 to Len( &(cAheader) )
				If X3OBRIGAT( &(caHeader+"["+str(nX)+"][02]") ) .AND. Empty( &(cAcols+"["+str(n)+"]["+str(nX)+"]") )
					cAux := STR0071 + &(caHeader+"["+str(nX)+"][01]") +; //"Faltou o preenchimento do campo "
					STR0072 + CRM010_009(cObj) //" localizado na pasta"
					MsgStop(cAux)
					Return .F.
				Endif
			Next nX
		Endif
	Endif
Endif


Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_009ºAutor  ³Frank Zwarg Fuga    º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encontra a descricao do erro para validacoes dos acols.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cObj                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Function CRM010_009(cObj)
Local cAux := ""

If cObj == "1"
           
   cAux := STR0077 //" referencias de trabalho."
               
ElseIf cObj == "2"
               
   cAux := STR0078 //" referencias de cartoes."
               
ElseIf cObj == "3"      
               
   cAux := STR0079 //" referencias bancarias."
               
ElseIf cObj == "4"
               
   cAux := STR0080 //" referencias pessoais."
               
ElseIf cObj == "5"      
               
   cAux := STR0081 //" dependentes."
               
ElseIf cObj == "6"
               
   cAux := STR0082 //" cartoes."
               
ElseIf cObj == "7"
               
   cAux := STR0083 //" documentos entregues."
              
Else                      
               
   cAux := STR0084 //" dados-socio-economicos."
               
Endif                              

Return cAux




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_010ºAutor  ³Frank Zwarg Fuga    º Data ³  08/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna com dados do acols para filtro do SXB = MAJ         º±±
±±º          ³Este filtro interfere na pasta dados-socio-economicos       º±±
±±º          ³no campo resposta.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_010(nFiltro)     
// nFiltro == 1 retorna o questionario
// nFiltro == 2 retorna a pergunta
Local cRetorno  := ""
Local nPosQuest := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_QUEST"})  
Local nPosPerg  := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PERG"})

If nFiltro == 1 .AND. nPosQuest > 0
   cRetorno := oGetd8:aCols[n][nPosQuest]
ElseIf nPosPerg > 0                                                                      
   cRetorno := oGetd8:aCols[n][nPosPerg]
Endif

Return (cRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_011ºAutor  ³Frank Zwarg Fuga    º Data ³  08/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Critica a linha de getdados do Perfil Socio Economico       º±±
±±º          ³Este filtro interfere na pasta dados-socio-economicos       º±±
±±º          ³no campo resposta.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_011()
Local lRetorno   := .T.
Local lCrdQuest  := ExistBlock("CRDQUEST")
Local cArea      := GetArea()
Local nPosPonto  := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PONTO"})
Local nPosDescri := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_DESCRE"})
Local nPosQuest  := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_QUEST"})
Local nPosPerg   := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PERG"})
Local cQuest     
Local cPerg      
Local cResp      := &(ReadVar())

If nPosQuest > 0
   cQuest     := oGetd8:aCols[n][nPosQuest]
Endif
If nPosPerg > 0
   cPerg      := oGetd8:aCols[n][nPosPerg]
Endif
DbSelectArea("MAJ")
DbSetOrder(1) // Filial + Quest + Perg
DbSeek(xFilial("MAJ")+cQuest+cPerg+cResp)

If Eof()
   lRetorno := .F.
   MsgStop(STR0085,STR0049) //"Resposta não cadastrada."###"Atenção !"
Endif                                        

If nPosPonto > 0
   oGetd8:aCols[n][nPosPonto] := MAJ->MAJ_PONTO
Endif
If nPosDescri > 0   
   oGetd8:aCols[n][nPosDescri] := MAJ->MAJ_DESCR
Endif   

RestArea(cArea)
If lCrdQuest
   lRetorno  := ExecBlock("CRDQUEST",.F.,.F.,{lRetorno})
Endif
Return (lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDA010_011 ºAutor  ³Frank Zwarg Fuga    º Data ³  10/23/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Encontra o valor do limite do credito para a inclusao e      º±±
±±º          ³ para a alteracao quando neste caso o limite estiver zerado   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA010_011 
Local aArea 		:= GetArea()
Local cValorMacro := ""
Local nLimite 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cadastro da identificacao das lojas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLJ")
DbSetOrder(3)                        

DbSeek( xFilial("SLJ") + cEmpAnt + cFilAnt )

If Eof() .OR. Empty(LJ_CODREG)

	RestArea( aArea )
	Return 0
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Script para classificacao do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MAF")
DbSetOrder(1)                         

DbSeek( xFilial("MAF") + SLJ->LJ_CODREG )

If Eof()

	RestArea( aArea )
	Return 0
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executar a macro do usuario para encontrar o valor do limite de credito do cliente.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cValorMacro := ExecMacroInServer( MAF_REGRA )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validar se a macro executou de forma correta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SubStr( cValorMacro,1,1) == "N"
	nLimite := Val( SubStr( cValorMacro,2 ))
Else 
	MsgStop(STR0086+Chr(10)+Chr(10)+SubStr( cValorMacro,2),STR0049) //"Houve problemas na execução da regra."###"Atenção !"
	nLimite := 0
Endif		

RestArea( aArea )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o valor do limite de credito do usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return nLimite

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRM010_012ºAutor  ³Fernando Salvatori  º Data ³ 07/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe produtos para consulta do Check-Out para a Retaguarda º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam     ³ aExp1	 : Array com o cabecalho dos produtos             º±±
±±º          ³ aExp2	 : Array para o aCols de produtos                 º±±
±±º          ³ aExp3     : Array com o cabecalho da forma de pagto        º±±
±±º          ³ aExp4  	 : Array para o aCols forma de pagto              º±±
±±º          ³ cExp5	 : Codigo da condicao de pagto                    º±±
±±º          ³ cExp6   	 : Descricao da condicao de pagto                 º±±
±±º          ³ cExp7  	 : Valor de NCCs utilizado na venda               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna Caroline³22/09/05³DELLA ³No TXT foi recebida a condicao de paga- º±±
±±º              ³        ³VIA   ³mento para mostrar a descricao na tela  º±±
±±º              ³        ³      ³de produtos do CRD                      º±±
±±ºHenry         ³19/10/05³DELLA ³Alteracao da mensagem da  existencia dosº±±
±±º              ³        ³VIA   ³arquivos pois foi constatado que o operaº±±
±±º              ³        ³      ³dor cancelou a venda                    º±±
±±ºMarcos Roberto³25/07/06³102337³Alteracao para nao visulizar os dados   º±±
±±º              ³        ³      ³nesta funcao, e sim no painel de analiseº±±
±±ºMarcos Roberto³21/11/06³107820³Armazena o codigo do vendedor           º±± 
±±ºMarcos Roberto³21/12/06³114416³Considera o parametro MV_CRDARQ na lei- º±± 
±±º              ³        ³      ³tura dos arquivos de produtos e parcelasº±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRM010_012(aHeaderSL2,	aColsSL2,	aHeaderSL4,	aColsSL4,; 
					cCondPg, 	cDescCond,	cVlNccArq, 	cVend )

Local cLinha    := "" 					             //Armazena o conteudo da linha do arquivo texto
Local cResto    := ""					             //Acumula o restante da leitura da linha
Local cArqPro	:= ""					             //Variavel com o nome do arquivo dos itens dos produtos
Local cArqPar	:= ""					             //Variavel com o nome do arquivo parametros
Local lRet		:= .T.				                 //Retorno da funcao
Local cMvCrdArq	:= SuperGetMV("MV_CRDARQ",,"\")	     //Informar aqui o conteudo do parametro

cArqPro			:= cMvCrdArq + MA7->MA7_ARQPRO 		 //Arquivo com os produtos da venda
cArqPar			:= cMvCrdArq + MA7->MA7_ARQPAR		 //Arquivo com as parcelas da venda   

If allTrim(cMvCrdArq) == "" 
	cMvCrdArq := "\"
Endif                      

If !File( cArqPro ) .OR. !File( cArqPar )
	Aviso( STR0049, STR0087+MA7->MA7_ARQPRO+STR0088+MA7->MA7_ARQPAR+STR0089,{"Ok"}) //"Não foram encontrados os arquivos "###" e "###". Contate o Administrador do Sistema"###"Atenção"
	Return .F.
Endif

DbSelectArea( "SX3" )
DbSetOrder( 2 )

DbSeek( "L2_ITEM   " )
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L2_PRODUTO" )        
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L2_DESCRI " )        
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L2_QUANT  " )
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L2_VRUNIT " )
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L2_VLRITEM" )
aAdd( aHeaderSL2, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L4_DATA   " )
aAdd( aHeaderSL4, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L4_VALOR  " )
aAdd( aHeaderSL4, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSeek( "L4_FORMA  " )
aAdd( aHeaderSL4, {X3TITULO(),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT} )

DbSelectArea("SL2")
RegToMemory( "SL2", .F. )
DbSelectArea("SL4")
RegToMemory( "SL4", .F. )

DbSelectArea( "SA1" )
DbSetOrder( 1 )
DbSeek( xFilial( "SA1" ) + MA7->MA7_CODCLI + MA7->MA7_LOJA )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco a abertura do arquivo de produtos.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE( cArqPro )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avanco para a primeira linha.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FGOTOP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego todos os registros do TXT para o aCols.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !FT_FEOF()
	cLinha := FT_FREADLN() //Leitura da linha
	
	aAdd(aColsSL2,Array(7) )
	
	aColsSL2[Len(aColsSL2)][1] := SubStr( cLinha,1,AT(Chr(5),cLinha)-1 )
	cResto          := SubStr( cLinha,AT(Chr(5),cLinha)+1   )
	
	aColsSL2[Len(aColsSL2)][2] := SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	aColsSL2[Len(aColsSL2)][3] := SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	aColsSL2[Len(aColsSL2)][4] := Val(SubStr( cResto,1,AT(Chr(5),cResto)-1 ))
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	aColsSL2[Len(aColsSL2)][5] := Val(SubStr( cResto,1,AT(Chr(5),cResto)-1 ))
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	aColsSL2[Len(aColsSL2)][6] := Val(SubStr( cResto,1,AT(Chr(5),cResto)-1 ))
	aColsSL2[Len(aColsSL2)][7] := .F.
	
	FT_FSKIP()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco o fechamento do arquivo em uso.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco a abertura do arquivo de parcelas.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE( cArqPar )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avanco para a primeira linha.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FGOTOP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego todos os registros do TXT para o aCols.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !FT_FEOF()
	cLinha := FT_FREADLN() //Leitura da linha
	
	aAdd(aColsSL4,Array(4) )
	
	aColsSL4[Len(aColsSL4)][1] := CtoD(SubStr( cLinha,1,AT(Chr(5),cLinha)-1 ))
	cResto          := SubStr( cLinha,AT(Chr(5),cLinha)+1   )
	
	aColsSL4[Len(aColsSL4)][2] := Val(SubStr( cResto,1,AT(Chr(5),cResto)-1 ))
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	aColsSL4[Len(aColsSL4)][3] := SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o codigo da condicao de pagamento do TXT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondPg			:= SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	aColsSL4[Len(aColsSL4)][4] := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor de NCC Selecionada na venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVlNccArq 		:= SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	cResto          := SubStr( cResto,AT(Chr(5),cResto)+1   )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Codigo do vendedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVend 			:= SubStr( cResto,1,AT(Chr(5),cResto)-1 )
	
	FT_FSKIP()
End

SE4->( DbSetOrder ( 1 ) )

If SE4->( DbSeek ( xFilial ("SE4") + cCondPg ) )
	cDescCond	:= SE4->E4_DESCRI
ElseIf Empty( cCondPg )
	cCondPg		:= "CN"
	cDescCond	:= "Condicao Negociada"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco o fechamento do arquivo em uso.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE()	

Return lRet                            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRA010_013ºAutor  ³Fernando Salvatori  º Data ³ 03/11/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualizacao do valor do Limite de Credito                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRA010_013(nOpcX)

If M->A1_LC == 0 .AND. ( nOpcX == 3 .OR. nOpcX == 4 )
	M->A1_LC := CRDA010_011()
Endif

Return .T.         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRC010_014ºAutor  ³Viviane Fernandes   º Data ³ 06/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada para a consulta de títulos recebidos do cliente .  º±±
±±º          ³ O fonte de posicao de cliente foi adapatadao para que a    º±±
±±º          ³ consulta a titulos fosse por filiais   					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q.    ³23/02/07³119542³Retirado ajuste de dicionário.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRC010_014()

Local aParam	:= {}
Local aGet     := {"","","",""}
Local aAlias	:= {}	

Private nCasas := SuperGetMV("MV_CENT")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros 				  	³
//³ MV_PAR01		  // Emissao De           		        ³
//³ MV_PAR02		  // Emissao Ate                        ³
//³ MV_PAR03		  // Vencimento De                      ³
//³ MV_PAR04		  // Vencimento Ate                     ³
//³ MV_PAR05		  // Considera Provisorios              ³
//³ MV_PAR06		  // Do Prefixo                         ³
//³ MV_PAR07		  // At‚ Prefixo                        ³
//³ MV_PAR08        // Considera Faturados                  ³
//³ MV_PAR09        // Considera Liquidados                 ³
//³ MV_PAR10        // Pedidos c/Itens Bloq.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("DAC010",.T.) 

	aAdd(aParam,MV_PAR01)
	aAdd(aParam,MV_PAR02)
	aAdd(aParam,MV_PAR03)
	aAdd(aParam,MV_PAR04)
	aAdd(aParam,MV_PAR05)
	aAdd(aParam,MV_PAR06)
	aAdd(aParam,MV_PAR07)
	aAdd(aParam,MV_PAR08)
	aAdd(aParam,MV_PAR09)
	aAdd(aParam,MV_PAR10)
	aAdd(aParam,MV_PAR11)
	aAdd(aParam,MV_PAR12)
	aAdd(aParam,MV_PAR13)
	
	Processa( {|| TitRec(2,@aAlias,aParam,.T.,aGet) }, STR0093, STR0047 )  //"Titulos pagos."###"Gerando a consulta."
Endif
	
Return .T.
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TitRec    ºAutor  ³Viviane Fernandes   º Data ³  08/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adequaco do programa Fc010Brow do modulo financeiro   	  º±±
±±º          ³Para listar somente os titulos pagos pelo cliente           º±±
±±º          ³Habilitada parametros Filial De e Filial Ate para permitir  º±±
±±º          ³acessar demais filiais									  º±±
±±º          ³  														  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : nOpcao                                             ³±±
±±³          ³         [2] Titulos Recebidos                              ³±±
±±³          ³ ExpA2 : Alias a Serem Fechados.                            ³±±
±±³          ³ ExpA3 : [1] Data de Emissao Inicial                        ³±±
±±³          ³         [2] Data de Emissao Final                          ³±±
±±³          ³         [3] Vencimento Inicial                             ³±±
±±³          ³         [4] Vencimento Final                               ³±±
±±³          ³         [5] Considera Provisorios (1) Sim (2) Nao          ³±±
±±³          ³         [6] Prefixo Inicial                                ³±±
±±³          ³         [7] Prefixo Final                                  ³±±
±±³          ³         [8] Considera Faturados (1) Sim (2) Nao            ³±±
±±³          ³         [9] Considera Liquidados  (1) Sim (2) Nao          ³±±
±±³          ³         [10] Pedidos c/Itens Bloq  (1) Sim (2) Nao         ³±±
±±³          ³         [11]  Tit. Ger. pela Liqu  (1) Sim (2) Nao         ³±±
±±³          ³         [12] Filial De									  ³±±
±±³          ³         [13] Filial Ate									  ³±±
±±³          ³ ExpL4 : Indica se os dados devem ser exibidos              ³±±
±±³          ³ ExpL5 : Indica se os dados serao montados para o relatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TitRec(nBrowse,aAlias,aParam,lExibe,aGet,lRelat)

Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local aAreaSC9		:= SC9->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aStru			:= {}
Local aQuery		:= {}
Local aSay			:= {"","","","","","",""}
Local oGetDb		:= Nil
Local oScrPanel		:= Nil
Local oBold			:= Nil
Local oDlg			:= Nil
Local oBtn			:= Nil
Local bVisual		:= Nil
Local bWhile		:= Nil
Local bFiltro		:= Nil
Local cAlias		:= ""
Local cQuery    	:= ""
Local cQry			:= ""
Local cChave		:= ""
Local lQuery    	:= .F.
Local nCntFor   	:= 0
Local nSalped   	:= 0
Local nSalpedl  	:= 0
Local nSalpedb  	:= 0
Local nQtdPed   	:= 0
Local nTotAbat  	:= 0
Local cAnterior 	:= ""
Local nTaxaM		:= 0	
Local oDlgl			:= Nil
Local oCBXMoeda		:= Nil
Local nMoeda		:= Nil
Local cMoeda		:= Nil
Local aMoedas		:= Nil
Local nX			:= Nil
Local oCBX0tras		:= Nil
Local cOtras		:= Nil
Local aOtras		:= Nil
Local oTipo			:= Nil
Local nTipo			:= 1	
Local bTipo			:= Nil
Local oCheq			:= Nil
Local aTotRec		:= {{0,1,0,0}} // Totalizador de titulos a receber por por moeda
Local aTotPag		:= {{0,1,0,0}} // Totalizador de titulos recebidos por por moeda
Local nAscan 		:= Nil
Local cDbMs			:= Nil
Local nTotalRec 	:= 0
Local aSize     	:= MsAdvSize( .F. )

Local aPosObj1  	:= {}                 
Local aObjects  	:= {}                       
Local aCpos     	:= {}
Local cCheques		:=	IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)

Local aFili			:= {}
Local nFili			:= 0
Local nAtrasos  	:= 0	   
Local aTiposTit 	:= {}                     
Local cNumAnt		:= ""
Local cTpDocAnt		:= ""
Local cParcAnt		:= ""  
Local oTempTable 	:= Nil		//Objeto tabela temporaria

Private aHeader 	:= {}

Default lRelat		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do array com as filiais validas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aFili,{Space(FWGETTAMFILIAL),Space(15)})

DbSelectArea("SM0")
dbGotop()
While !Eof()
	If M0_CODIGO <> cEmpAnt
		dbSkip()
		Loop
	Endif
	
	If FWGETCODFILIAL >= aParam[12] .AND. FWGETCODFILIAL <= aParam[13]
		aAdd(aFili,{FWGETCODFILIAL,M0_FILIAL})
	Endif
		
	dbSkip()
End

aGet := {"","","","","","",""}

cCadastro := STR0094 //"Tit.Recebidos"
cAlias    := "FC010QRY02"
aSay[1]   := STR0095 //"Qtd.Pag."
aSay[2]   := STR0096 //"Principal"
aSay[3]   := STR0097 //"Vlr.Pagto"
aSay[4]   := STR0098 //"M.Atrasos"

bVisual   := {|| CRD010TP( (cAlias)->XX_RECNO, nBrowse, (cAlias)->E1_FILIAL  ) }

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Titulos Recebidos                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nBrowse == 2 )
		DbSelectArea("SX3")
		DbSetOrder(2)    

		DbSeek("E1_FILIAL")

		aAdd(aStru,{"XX_MOVBCO","C",4,0})
		aAdd(aHeader,{ "CANC"             , "XX_MOVBCO"    ,"@!"            ,4              ,0              ,SX3->X3_VALID ,SX3->X3_USADO,"C"         ,"SE1"          ,SX3->X3_CONTEXT } )
		
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E1_PREFIXO")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		DbSeek("E1_NUM")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		DbSeek("E1_PARCELA")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		DbSeek("E1_TIPO")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
		IF !lRelat
			DbSeek("E1_MOEDA")
			aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			DbSeek("E1_VALOR")
			aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif	
		
		DbSeek("E1_VLCRUZ")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
		For nCntFor := 1 To 4
			DbSeek(	If(nCntFor==1,	"E5_VLJUROS",;
						If(nCntFor==2,	"E5_VLMULTA",;
						If(nCntFor==3,	"E5_VLCORRE",;
											"E5_VLDESCO"))))
			aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Next nCntFor	
		
		DbSeek("E5_VALOR")
		aAdd(aHeader,{STR0099,"E1_PAGO",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,"V" } ) //"Pago" //"Pago"
		aAdd(aStru ,{"E1_PAGO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				
		IF !lRelat
			DbSeek("E1_VALOR")
			aAdd(aHeader,{ STR0100,"E1_VLMOED2",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } ) //"Vlr pago  moeda tit." //"Vlr pago  moeda tit."
			aAdd(aStru ,{"E1_VLMOED2",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			
			DbSeek("E5_VLMOED2")
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

			If cPaisLoc == "BRA"
				DbSeek("E5_TXMOEDA")
				aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
				aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			Endif
		Endif	

		DbSeek("E1_EMISSAO")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E1_VENCTO")
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		

		DbSeek("E1_VENCREA")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		DbSeek("E5_DATA")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		DbSeek("E5_DTDISPO")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E1_NATUREZ")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If !lRelat
			DbSeek("E1_NUMLIQ")
			aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		
		DbSeek("E5_BANCO")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E5_AGENCIA")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E5_CONTA")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E5_HISTOR")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		DbSeek("E5_MOTBX")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		If !lRelat
			DbSeek("E5_CNABOC")
			aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
			aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif

		DbSeek("E5_TIPODOC")
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})		


		aAdd(aHeader,{STR0101,"E1_ATR","99999",5,0,"","","N","","V" } ) //"Atraso" //"Atraso"
		aAdd(aStru ,{"E1_ATR","N",5,0})

		DbSeek("E1_VALJUR")
		aAdd(aHeader,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		aAdd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		aAdd(aQuery,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		aAdd(aStru,{"XX_RECNO","N",12,0})

		
		If cPaisLoc == "BRA"
			aAdd(aQuery,{"E1_TXMOEDA","N",17,4})
		Endif	

		SX3->(DbSetOrder(1))

		If ( Select(cAlias) ==	0 )
			aAdd(aStru,{"FLAG","L",01,0})
			
			//Criacao da tabela temporaria
			oTempTable := LjCrTmpTbl(cAlias, aStru, {"E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO",;
													"E1_FILIAL+E1_VENCREA"})

			(cAlias)->(DbSetOrder(1))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

			DbSelectArea("SE1")
			DbSetOrder(2)
			ProcRegua(Len(aFili))
			For nFili := 1 to len(aFili)
				   
					IncProc()
					DbSeek(aFili[nFili][1]+SA1->A1_COD+SA1->A1_LOJA)
					bWhile := {|| !Eof() .AND. SE1->E1_FILIAL == aFili[nfili][1] .AND.;
										SA1->A1_COD    == SE1->E1_CLIENTE .AND.;
										SA1->A1_LOJA   == SE1->E1_LOJA }
					bFiltro:= {|| 	SubStr(SE1->E1_TIPO,3,1)<>"-" .AND.;
										SE1->E1_EMISSAO >= aParam[1] .AND.;
										SE1->E1_EMISSAO <= aParam[2] .AND.;
										SE1->E1_VENCREA >= aParam[3] .AND.;
										SE1->E1_VENCREA <= aParam[4] .AND.;
										If(aParam[5]==2,SE1->E1_TIPO<>"PR ",.T.) .AND.;
										SE1->E1_PREFIXO >= aParam[6] .AND.;
										SE1->E1_PREFIXO <= aParam[7] .AND.;
										AllTrim(SE1->E1_TIPO) $ SuperGetMV("MV_CRDTPLC") .AND.;
										IIf(cPaisLoc == "BRA",.T.,!(SE1->E1_TIPO$cCheques)) .AND.;
										If(!Empty(SE1->E1_FATURA) .AND. Substr(SE1->E1_FATURA,1,6) <> "NOTFAT",aParam[8]==1, .T.).AND.;
										IIF(mv_par09 == 2, Empty(SE1->E1_NUMLIQ) .OR. (!Empty(SE1->E1_NUMLIQ) .AND. Empty(SE1->E1_TIPOLIQ)),.T.)}
										
					While ( Eval(bWhile) )
						If ( Eval(bFiltro) )
							DbSelectArea("SE5")
							DbSetOrder(4)
							DbSeek(aFili[nfili][1]+SE1->E1_NATUREZ+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
	
							While ( !Eof() .AND. SE5->E5_FILIAL == aFili[nFili][1] .AND.;
									SE1->E1_NATUREZ == SE5->E5_NATUREZ .AND.;
									SE1->E1_PREFIXO == SE5->E5_PREFIXO .AND.;
									SE1->E1_NUM == SE5->E5_NUMERO      .AND.;
									SE1->E1_PARCELA == SE5->E5_PARCELA .AND.;
									SE1->E1_TIPO == SE5->E5_TIPO )
	
								If ((!SE5->E5_TIPO $ "RA /PA /"+MV_CRNEG+"/"+MV_CPNEG) .AND. !TemBxCanc() .AND. ;
											SE5->E5_SITUACA <> "C" .AND. SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" .AND.;
											SE5->E5_MOTBX $ SuperGetMV("MV_CRDTPBX") .AND. ;
											( IIf(UPPER(SUBSTR(SE5->E5_HISTOR,1,4)) <> "LOJ-", .T.,;
											 ( ( SE1->E1_NUM == cNumAnt .AND. SE5->E5_TIPODOC == cTpDocAnt ) .OR. ( SE1->E1_NUM == cNumAnt .AND. SE1->E1_PARCELA <> cParcAnt  ) .OR. SE1->E1_NUM <> cNumAnt ) ) )  )
											 
									cNumAnt 	:= SE1->E1_NUM
									cTpDocAnt 	:= SE5->E5_TIPODOC
									cParcAnt 	:= SE1->E1_PARCELA
									
									RecLock(cAlias,.T.)
									For nCntFor := 1 To Len(aStru)
										Do Case
										Case ( AllTrim(aStru[nCntFor][1])=="XX_MOVBCO" )
											If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
												IF MovBcoBx(SE5->E5_MOTBX)
													(cAlias)->XX_MOVBCO := " "
												ELSE
													(cAlias)->XX_MOVBCO := "CANC"
												Endif
											Endif
										Case ( AllTrim(aStru[nCntFor][1])=="E1_PAGO" )
											If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
												(cAlias)->E1_PAGO += SE5->E5_VALOR
											Endif
										Case ( AllTrim(aStru[nCntFor][1])=="E1_VLMOED2" ) .AND. !lRelat
											If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" ) .AND. SE1->E1_MOEDA > 1
												(cAlias)->E1_VLMOED2 := If(SE1->E1_MOEDA > 1, SE5->E5_VLMOED2, SE5->E5_VALOR)
											Endif		
										Case ( AllTrim(aStru[nCntFor][1])=="E1_VLCRUZ" )
											If ( SE5->E5_TIPODOC $ "VL/BA/V2/CP/LJ/R$" )
												If cAnterior <> SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
													(cAlias)->E1_VLCRUZ := SE1->E1_VLCRUZ
													cAnterior := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
												Endif
											Endif	
										Case ( AllTrim(aStru[nCntFor][1])=="E1_ATR" )
											If SE5->E5_DATA > DataValida(SE1->E1_VENCTO,.T.)
												(cAlias)->E1_ATR := SE5->E5_DATA - SE1->E1_VENCTO
												IF MovBcoBx(SE5->E5_MOTBX)
													nAtrasos += SE5->E5_DATA - SE1->E1_VENCTO
												Endif
											Else
												(cAlias)->E1_ATR := SE5->E5_DATA - DataValida(SE1->E1_VENCTO,.T.)
												IF MovBcoBx(SE5->E5_MOTBX)
													nAtrasos += SE5->E5_DATA - DataValida(SE1->E1_VENCTO,.T.)
												Endif
											Endif
										Case cPaisLoc=="BRA" .AND. ( AllTrim(aStru[nCntFor][1])=="E5_TXMOEDA" ) .AND. !lRelat
			                     			If SE1->E1_MOEDA == 1
	        		             				(cAlias)->E5_TXMOEDA := 1
	            							Else
												If SE5->E5_TXMOEDA == 0 
													(cAlias)->E5_TXMOEDA := (SE5->E5_VALOR /SE5->E5_VLMOED2)
												Else
													(cAlias)->E5_TXMOEDA := SE5->E5_TXMOEDA
												Endif
											Endif
										Case ( AllTrim(aStru[nCntFor][1])=="XX_RECNO" )
											(cAlias)->XX_RECNO := SE5->(RecNo())
										Case ( "E5_"$AllTrim(aStru[nCntFor][1]) )
											(cAlias)->(FieldPut(nCntFor,SE5->(FieldGet(FieldPos(aStru[nCntFor][1])))))
										Case ( AllTrim(aStru[nCntFor][1])=="FLAG" )
										OtherWise
											(cAlias)->(FieldPut(nCntFor,SE1->(FieldGet(FieldPos(aStru[nCntFor][1])))))
										EndCase
									Next nCntFor
									(cAlias)->(MsUnLock())
								Endif
								DbSelectArea("SE5")
								dbSkip()
							End										
						Endif
						DbSelectArea("SE1")
						dbSkip()					
					End
			Next nFili	

			DbSelectArea(cAlias)
			DbSetOrder(2) //E1_FILIAL+DTOS(E1_VENCREA)

		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totais da Consulta                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aGet[1] := 0
		aGet[2] := 0
		aGet[3] := 0
		aGet[4] := 0
		aTotPag := {{0,1,0,0}} // Totalizador de titulos recebidos por moeda
		DbSelectArea(cAlias)
		dbGotop()
		CRDA010T(aGet,cAlias,aTotPag)  // Totais de Baixas
		If !lRelat
			nTotalRec:=0
			aEval(aTotPag,{|e| nTotalRec+=e[VALORREAIS]})
			aAdd(aTotPag,{"","","Total ====>>",nTotalRec}) //"Total ====>>"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Formata as colunas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aTotPag,{|e|	If(ValType(e[VALORTIT]) == "N"	, e[VALORTIT]		:= Transform(e[VALORTIT],Tm(e[VALORTIT],16,nCasas)),Nil),;
										If(ValType(e[VALORREAIS]) == "N"	, e[VALORREAIS]	:= Transform(e[VALORREAIS],Tm(e[VALORREAIS],16,nCasas)),Nil)})
		Endif              
		
		aGet[4] := nAtrasos / aGet[1] // encontrar a media de atrasos.
		
		aGet[1] := TransForm(aGet[1],Tm(aGet[1],16,0))
		aGet[2] := TransForm(aGet[2],Tm(aGet[2],16,nCasas))
		aGet[3] := TransForm(aGet[3],Tm(aGet[3],16,nCasas))
		aGet[4] := TransForm(aGet[4],"9999999999999999")

EndCase	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe os dados Gerados                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lExibe )
	DbSelectArea(cAlias)
	dbGotop()
	If ( !Eof() )
		
		aObjects := {} 
		aAdd( aObjects, { 100, 35,  .T., .F., .T. } )
		aAdd( aObjects, { 100, 100 , .T., .T. } )
		aAdd( aObjects, { 100, 50 , .T., .F. } )
		
		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj1 := MsObjSize( aInfo, aObjects) 
		
		DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD

		DEFINE MSDIALOG oDlg FROM	aSize[7],0 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL
		@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oScrPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlg LOWERED

		@ 04,004 SAY STR0102 SIZE 025,07          OF oScrPanel PIXEL //"Codigo" //"Codigo"
		@ 12,004 SAY SA1->A1_COD  SIZE 060,09  OF oScrPanel PIXEL FONT oBold

		@ 04,067 SAY STR0103 SIZE 020,07          OF oScrPanel PIXEL //"Loja" //"Loja"
		@ 12,067 SAY SA1->A1_LOJA SIZE 021,09 OF oScrPanel PIXEL FONT oBold

		@ 04,090 SAY STR0104 SIZE 025,07 OF oScrPanel PIXEL //"Nome" //"Nome"
		@ 12,090 SAY SA1->A1_NOME SIZE 165,09 OF oScrPanel PIXEL FONT oBold

		oGetDb:=MsGetDB():New(aPosObj1[2,1],aPosObj1[2,2],aPosObj1[2,3],aPosObj1[2,4],2,"",,,.F.,,,.F.,,cAlias,,,,,,.T.)
		oGetdb:lDeleta:=NIL
		DbSelectArea(cAlias)
		dbGotop()

		@ aPosObj1[3,1]+04,005 SAY aSay[1] SIZE 025,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+04,175 SAY aSay[2] SIZE 025,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+15,005 SAY aSay[3] SIZE 025,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+15,175 SAY aSay[4] SIZE 025,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+26,005 SAY aSay[5] SIZE 025,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+26,175 SAY aSay[6] SIZE 025,07 OF oDlg PIXEL

		@ aPosObj1[3,1]+04,045 SAY aGet[1] SIZE 060,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+04,215 SAY aGet[2] SIZE 060,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+15,045 SAY aGet[3] SIZE 060,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+15,215 SAY aGet[4] SIZE 060,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+26,045 SAY aGet[5] SIZE 060,07 OF oDlg PIXEL
		@ aPosObj1[3,1]+26,215 SAY aGet[6] SIZE 060,07 OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 04,aPosObj1[1,3]-If(nBrowse <= 2,60,30) TYPE  1  ENABLE OF oScrPanel ACTION ( oDlg:End() )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe o botao de distribuicao por moedas, apenas na consulta de titulos³
		//³em aberto e recebidos                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON oBtn 	FROM 19,aPosObj1[1,3]-If(nBrowse <= 2,60,30) TYPE 15 ENABLE OF oScrPanel
		
		oBtn:lAutDisable := .F.
		If ( bVisual <> Nil )
			oBtn:bAction := bVisual
		Else
			oBtn:SetDisable(.T.)
		Endif
		ACTIVATE MSDIALOG oDlg
	Else
		Help(" ",1,"REGNOIS")	
	Endif
	If nBrowse == 5
		If( ValType(oTempTable) == "O")
			oTempTable:Delete()
			FreeObj(oTempTable)
			oTempTable := Nil
		EndIf	
	Endif
Endif
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aAreaSF4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Select(cAlias) > 0
	Eval({|| Ferase((cAlias)->(GetDBExtension())) , Ferase((cAlias)->(OrdBagExt())) , (cAlias)->(dbCloseArea()) } )
EndIf

DbSelectArea("SA1")
RestArea(aArea)

Return(aHeader)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CRDA010T  ³ Autor ³ Frank Zwarg Fuga      ³ Data ³30.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Somat¢ria dos titulos recebidos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aGet - Array que guardar  o nro de titulos, valores princi- ³±±
±±³          ³       pais e valor da baixa                                ³±±
±±³          ³cAlias - Alias do arquivo tempor rio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CRDA010T(aGet,cAlias,aTotPag)

Local cTitAnt := ""
Local nAscan

While !(cAlias)->( Eof() )
	IF Empty(XX_MOVBCO)
		aGet[1]++

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Impressao do relatorio nao existe E1_MOEDA no temporario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAscan := Ascan(aTotPag,{|e| e[MOEDATIT] == E1_MOEDA})
		If nAscan = 0
			aAdd(aTotPag,{1,E1_MOEDA,If(E1_MOEDA>1,E1_VLMOED2,E1_PAGO),E1_PAGO})
		Else
			aTotPag[nAscan][QTDETITULOS]++
			aTotPag[nAscan][VALORTIT]		+= If(E1_MOEDA>1,E1_VLMOED2,E1_PAGO)
			aTotPag[nAscan][VALORREAIS]	+= E1_PAGO
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somo o valor do titulo apenas uma vez em caso de baixa parcial ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) <> cTitAnt
			aGet[2]+= E1_VLCRUZ
			cTitAnt := (cAlias)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		Endif
		aGet[3] += E1_PAGO
	Endif	
	
	dbSkip()	

End
Return (aGet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfuncao    ³CRC010_015ºAutor  ³Alexandre Circenis  º Data ³  03/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa a Mudanca entre os Folders Principais              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPriscila Prado³23/01/04³------³Adaptação da função para o SigaCrd      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRC010_015(nFolder,nAntigo,nOpcx)

Local lRet  := .T. 
Local aAcols
Local aAHeader
Local cAux
Local cDocAux
Local cDocPasta
Local cTitulo
Local nPos1
Local nPos2
Local nPos3
Local lPula := .F.                             
Local nX    := 0
Local nY    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao validar na visualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 2
	Return .T.
Endif

If ExistBlock("CRDVFD1")
	lRet := ExecBlock("CRDVFD1",.F.,.F.,{nAntigo,nOpcx})
Endif


If nAntigo = 1                                 
	If lRet:= Obrigatorio(aGets1,aTela1) .AND. CRD10CGCOK() //Incluida validação do CGC do Financial Service
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ a Enchoice estando OK validar os dados dos Folders secundarios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet :=  CRC010_018()
	Endif
	Return(lRet)
	
ElseIf nAntigo = 2
	aAcols   := oGetD8:aCols
	aAheader := oGetD8:aHeader
	aTitulo  := aTitles1
	IF 	!MA5->( DbSeek( xFilial("MA5") + SuperGetMV("MV_QUEST") ) )		// Se o Questionario padrao existir critico a digitacao, 	
		lpula := .T.												// caso contrario nao critico Questionario Socio Economico
	Endif
ElseIf nAntigo = 3
	aAcols   := oGetD5:aCols
	aAheader := oGetD5:aHeader
	aTitulo  := aTitles1
ElseIf nAntigo = 4
	aAcols   := oGetD6:aCols
	aAheader := oGetD6:aHeader
	aTitulo  := aTitles1
	lRet	 := oGetD6:TudoOk()	
	Return(lRet)	
ElseIf nAntigo = 5
	aAcols   := oGetD7:aCols
	aAheader := oGetD7:aHeader
	aTitulo  := aTitles1
	
	aCols7	 := aClone(aACols)
	
Else
	lpula := .T.
Endif

              
If !lPula
	For nY := 1 to Len( aAcols )
		
		If ! aAcols[nY][len(aAheader)+1]
			
			For nX := 1 to Len( aAheader )
				
				If X3OBRIGAT( aAHeader[nX][02] ) .AND.;
					Empty( aAcols[nY][nX] )
					
					cAux := STR0071 + aAHeader[nX][01]+; //"Faltou o preenchimento do campo "
					 STR0105 + aTitulo[nAntigo] //" localizado na pasta "
					
					msgstop(cAux)
					
					//      		   nFolder  := nAntigo
					lRet := .F.
					Return(lRet)
					
				Endif
				
			Next nX
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³validacao de documentos com entrega obrigatoria³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nAntigo == 7
				
				nPos1:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_CONTR"})	//posicao do campo controle de recebimento
				nPos2:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_SITUA"})	//situacao do documento: 1=entregue;2=pendente
				nPos3:= ascan(aHeader7,{|x| Trim(x[2]) == "MAE_DESCR"})	//Documento
				
				IF aAcols[nY][npos1] == "1" .AND. aAcols[nY][npos2] == "2"
					
					If Empty(cDocAux)
						
						cDocAux := STR0073 + aAcols[nY][npos3] //"O documento "
						cDocPasta := CRM010_009(Alltrim(str(nAntigo)))
					Else
						
						cDocAux += STR0106+ aAcols[nY][npos3] //", "
						
					Endif
					
				Endif
				
			Endif
			
		Endif
		
	Next nY
	
Endif

If !Empty(cDocAux)
	cDocAux += 	STR0074 +; //" é de Entrega obrigatoria."
	STR0075 + cDocPasta //" Preenchimento na pasta "
   	msgstop(cDocAux)
Endif	             

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfuncao    ³CRC010_017ºAutor  ³Alexandre Circenis  º Data ³  03/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa a Mudanca entre os Folders da primeira pasta       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPriscila Prado³23/01/04³------³Adaptação da função para o SigaCrd      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CRC010_017(nFolder,nAntigo,nOpcx)
Local lret := .T. 
Local aAcols
Local aAHeader
Local cAux, cDocAux, cDocPasta, aTitulo
Local nPos1, nPos2, nPos3
Local lpula := .F.                             
Local nX := 0
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao validar na visualizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 2
	Return .T.
Endif

If nAntigo = 1
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("MA7")
	While !Eof() .AND. X3_ARQUIVO == "MA7"
		If X3USO(X3_USADO) .AND. X3OBRIGAT(X3_CAMPO) .AND.  Empty(&('M->'+X3_CAMPO))
			cAux := STR0071 + X3_TITULO //"Faltou o preenchimento do campo "
			msgstop(cAux)
			Return(.F.)
		Endif
		dbSkip()
	End
	Return(.T.)
ElseIf nAntigo = 2
	aAcols   := oGetD1:aCols
	aAheader := oGetD1:aHeader
	aTitulo  := aTitles2
ElseIf nAntigo = 3
	aAcols   := oGetD2:aCols
	aAheader := oGetD2:aHeader
	aTitulo  := aTitles2
ElseIf nAntigo = 4
	aAcols   := oGetD3:aCols
	aAheader := oGetD3:aHeader
	aTitulo  := aTitles2
ElseIf nAntigo = 5
	aAcols   := oGetD4:aCols
	aAheader := oGetD4:aHeader
	aTitulo  := aTitles2
Else
	lpula := .T.
Endif
                 
If !lPula
	For nY := 1 to Len( aAcols )
	
		If ! aAcols[nY][len(aAheader)+1]
		
			For nX := 1 to Len( aAheader )
				
				If X3OBRIGAT( aAHeader[nX][02] ) .AND.;
					Empty( aAcols[nY][nX] )
					
					cAux := STR0071 + aAHeader[nX][01]+; //"Faltou o preenchimento do campo "
					 STR0105 + aTitulo[nAntigo]					 //" localizado na pasta "
					msgstop(cAux)
					lRet := .F.
					Return(lRet)
					
				Endif
				
			Next nX
			
		Endif
		
	Next nY
	
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfuncao    ³CRC010_018ºAutor  ³Alexandre Circenis  º Data ³  03/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida os Dados de todos os folders secundarios             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPriscila Prado³23/01/04³------³Adaptação da função para o SigaCrd      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CRC010_018()
Local nX	:= 0
Local lRet	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validar todos os Folders secundarios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(oFolder2:aDialogs)
	If !Crc010_017(nX, nX)
		lRet := .F.
	Endif
Next nX

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD10CABOKºAutor  ³Circenis            º Data ³  02/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³valida os dados do SA1 na mudanca dos folders               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CRD10CabOk(oEnchoice)
Local lRet:= .F.
                                         
lRet:= Obrigatorio(aGets1,aTela1)  .AND. CRD10CGCOK() //Incluida a validacao do financial services

If !lRet
	oEnchoice:oBox:SetFocus()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRA010_019ºAutor  ³Priscila Prado      º Data ³ 27/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada para a consulta de cadastro de cliente.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRC010_019( nOpxa  ,nRecnoMAR )

Local aAreaAtu := GetArea()
Local nReg     := 0
Local aCols2   := {}
Local nReg2    := 0        
Local lConfirma:= .F.

default nOpxa := 0

DbSelectArea("SA1")
DbSetOrder(1)

aCols2  := aClone(aRotina)
nReg2 	:= nReg
           
aRotina :=	{{ STR0001, "AxPesqui", 0, 1},; //"Pesquisar"
							{ STR0002 , "Crd010Man", 0, 2},; //"Visualizar"
					 		{ STR0003 , "Crd010Man", 0, 3},; //"Incluir"
					 		{ STR0004 , "Crd010Man", 0, 4},; //"Alterar"
					 		{ STR0005 , "Crd010Man", 0, 0}}  //"Excluir"


If DbSeek(xFilial("SA1")+MA7->MA7_CODCLI+MA7->MA7_LOJA)
	nReg := Recno()              
	If nOpxa == 1           
		Crd010Man( "SA1"  ,nReg  ,  4  ,@lConfirma)
	Else
		Crd010Man("SA1"   ,nReg  ,  2  )
	Endif
Else
	MsgAlert(STR0107) //"Cliente não encontrado!"
Endif

aRotina := aClone(aCols2)
nReg 	:= nReg2

RestArea( aAreaAtu )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CKMA8CPF  ºAutor  ³Geronimo B. Alves   º Data ³  09/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida digitacao do campo A1_cgc                            º±±
±±º          ³Nao pode existir na tabela MA8                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CKMA8CPF()

Local aAreaAtu := GetArea()
Local cCPF     := M->A1_CGC
Local lRet     := .T.

If Empty(cCPF)
	lRet := .F.
Endif

If lRet

	DbSelectArea("MA8")
	DbSetOrder(2)	// Filial + CPFconjugue
	DbSeek(xfilial("MA8")+cCPF)		
	While !Eof() .AND. MA8_CPFCON == cCpf
		If MA8_TIPO == "3"
			MsgAlert(STR0108 + MA8->MA8_CODCLI +"-" + MA8->MA8_LOJA ) //"CPF já cadastrado como dependente do cliente "
			lRet := .F.
			Exit
		Endif
		dbSkip()
	End
	
Endif
	
DbSelectArea("MA8")
DbSetOrder(3)

RestArea( aAreaAtu )

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRC010_CPFºAutor  ³Priscila Prado      º Data ³ 28/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o CPF do conjugue (campo MA8_CPFCON).                º±±
±±º          ³Nao pode existir na tabela SA1 e nem na variavel M->A1CGC   º±±
±±º          ³Na getdados nao pode existir CPFS repetidos.                º±±
±±º          ³Na Tabela MA8 nao pode ter sido cadastrado em outro cliente º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRC010_CPF()
Local aAreaAtu := GetArea()
Local cCPF     := &(ReadVar())
Local lRet     := .T.
Local nPosTipo := ascan(aHeader1,{|x| Trim(x[2]) == "MA8_TIPO"})
Local nPosCpf  := ascan(aHeader1,{|x| Trim(x[2]) == "MA8_CPFCON"})
Local nX 	   := 0

DbSelectArea("SA1")
DbSetOrder(3)       // Filial + CPF

If aCols[n][nPosTipo] == '3' .AND. !Empty(cCPF)
	DbSeek(xfilial("SA1")+cCPF)
	While !Eof() .AND. SA1->A1_CGC == cCPF
		IF SA1->A1_COD + SA1->A1_LOJA <> M->A1_COD+ M->A1_LOJA
			MsgAlert(STR0109 + SA1->A1_COD +"-" + SA1->A1_LOJA ) //"CPF já cadastrado no cliente "
			lRet := .F.
		Endif
		dbSkip()		
	End
	
	DbSelectArea("MA8")
	DbSetOrder(2)	// Filial + CPFconjugue
	DbSeek(xfilial("MA8")+cCPF)		
	While !Eof() .AND. MA8_CPFCON == cCpf
		If MA8_TIPO == "3"
			IF MA8->MA8_CODCLI + MA8->MA8_LOJA <> M->A1_COD+ M->A1_LOJA
				MsgAlert(STR0108 + MA8->MA8_CODCLI +"-" + MA8->MA8_LOJA ) //"CPF já cadastrado como dependente do cliente "
				lRet := .F.
			Endif
		Endif
		dbSkip()
	End             

	If cCpf == M->A1_CGC
		MsgStop(STR0110,STR0049) //"CPF do dependente igual ao CPF do cliente."###"Atenção !"
		lRet := .F.
	Endif	
	
	If FunName() = "CRDA010"
		_nContaCPF := 0
		For nX := 1 to Len(aCols)
			If aCols[nX][nPosTipo] == '3'
				IF IF(n == nx , &(ReadVar()) , aCols[nX][nPosCPF] ) == cCpf
					_nContaCPF++
					if _nContaCPF > 1
						MsgStop(STR0111,STR0049) //"CPF já informado nos dados do conjuge."###"Atenção !"
						lRet := .F.
						exit
					Endif
				Endif
			Endif
		Next nX
	Endif	
		
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSelectArea("MA8")
DbSetOrder(2)

RestArea( aAreaAtu )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRA_CPF   ºAutor  ³Frank Zwarg Fuga    º Data ³ 28/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o CPF do conjugue no SA1                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRA_CPF(cCpf)
Local aArea    := GetArea()
Local lRet     := .T.
Local nPosCPF
Local nPosTipo
Local nX              

If cCpf == NIL
	cCpf := &(ReadVar())
Endif 

DbSelectArea("MA8")
DbSetOrder(3)
DbSeek(xFilial("MA8")+M->A1_COD+M->A1_LOJA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisar se este CPF ja foi utilizado como conjuge³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .AND. MA8_FILIAL+MA8_CODCLI+MA8_LOJA == xFilial("MA8")+M->A1_COD+M->A1_LOJA
	If MA8_TIPO == "3"
		If MA8_CPFCON == cCpf
			MsgStop(STR0111,STR0049) //"CPF já informado nos dados do conjuge."###"Atenção !"
			lRet := .F.
		Endif
	Endif
	dbSkip()
End             

// Validar as variaveis de memoria para o caso do cadastro no CRDA010
// ------------------------------------------------------------------

If FunName() = "CRDA010"
	nPosTipo := ascan(aHeader1,{|x| Trim(x[2]) == "MA8_TIPO"})
	nPosCpf  := ascan(aHeader1,{|x| Trim(x[2]) == "MA8_CPFCON"})
	For nX := 1 to Len(aCols1)
		If aCols1[nX][nPosTipo] == '3'
			IF aCols1[nX][nPosCPF] == cCpf
				MsgStop(STR0111,STR0049) //"CPF já informado nos dados do conjuge."###"Atenção !"
				lRet := .F.
			Endif
		Endif
	Next nX
Endif

RestArea(aArea)        

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDVALCAR ºAutor  ³Frank Zwarg Fuga    º Data ³  02/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao para identificar se um cartao pode ou nao ser     º±±
±±º          ³cancelado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDVALCAR()

Local nMAE_CONTR  := ascan(aHeader7,{|x| Trim(x[2]) == "MAE_CONTR"})
Local nMAE_SITUA  := ascan(aHeader7,{|x| Trim(x[2]) == "MAE_SITUA"})
Local lRet 		  := .T.
Local nX          := 0	//controle de loop

For nX := 1 to Len(aCols7)
	If aCols7[nX][nMAE_CONTR] == "1" .AND. aCols7[nX][nMAE_SITUA] = "2"
		lRet := .F.
	Endif
Next nX

If !lRet
	MsgStop(STR0112,STR0113) //"Existem documentos pendentes."###"Cancelamento inválido!"
Endif

Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDVLDCAR ºAutor  ³Frank Zwarg Fuga    º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do CPF no momento da digitacao.                   º±±
±±º          ³Na getdados nao pode existir cartoes repetidos.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDVLDCAR()

Local cNumCart := &(ReadVar())
Local nPosCart := ascan(aHeader6,{|x| Trim(x[2]) == "MA6_NUM"})
Local nX  	   := 0		//controle de loop
Local lRetorno := .T.

For nX := 1 to Len(oGetd6:aCols)
	If nX <> N
		If cNumCart == oGetd6:aCols[nX][nPosCart]
			lRetorno := .F.
		Endif
	Endif
Next nX

If !lRetorno
	MsgStop(STR0114,STR0049) //"Numeração já informada."###"Atenção !"
Endif

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDValDelCºAutor  ³Frank Zwarg Fuga    º Data ³  06/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criticar as linhas deletadas do acols referente ao cadastro º±±
±±º          ³de cartoes                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDValDelCar()

Local lRet := .T.

If ExistBlock("CRDVDCA")
	lRet := ExecBlock("CRDVDCA",.F.,.F.)
Endif 

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDValDelDºAutor  ³Frank Zwarg Fuga    º Data ³  06/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criticar as linhas deletadas do acols referente ao cadastro º±±
±±º          ³de dependentes                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDValDelDep()

Local lRet := .T.

If ExistBlock("CRDVDDE")
	lRet := ExecBlock("CRDVDDE",.F.,.F.)
Endif                 

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDCRM14  ºAutor  ³Frank Zwarg Fuga    º Data ³  06/27/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica as compras recusadas do cliente.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDCRM14(cCodcli,cLoja,aFili)
Local nFili		:= 0		// controle de loop
Local cGrupo
Local nPonteiro                            
Local cData

ProcRegua(Len(aFili))

DbSelectArea("MAK")            
DbSetOrder(1)
DbSeek( xFilial("MAK") + cCodCli + cLoja)

While !Eof() .AND. MAK_FILIAL + MAK_CODCLI + MAK_LOJA == xFilial("MAK") + cCodCli + cLoja
	DbSelectArea("SB1")
	DbSetOrder(1)
	For nFili:= 1 to len(aFili)
		IncProc()
		If DbSeek(aFili[nFili][01]+MAK->MAK_CODPRO)
			DbSelectArea("SBM")      
			DbSetOrder(1)
			DbSeek(aFili[nFili][01]+SB1->B1_GRUPO)
			If Eof()
				cGrupo := STR0115 //"Grupo/Produtos nao definido"
			Else
				// Grupo de produtos
	 			cGrupo := BM_DESC
			Endif
			exit   
		Endif
	Next nFili       

	// Quando o laco termina pelo esgotamento do contador	
	If nFili > Len(aFili)
		cGrupo := STR0115 //"Grupo/Produtos nao definido"
	Endif
	If MV_PAR03 = 1
		nPonteiro := Ascan(aTitul2,{|aVal| aVal[1] == cGrupo})
		If nPonteiro == 0
	    	aAdd( aTitul2, {cGrupo, str(MAK->MAK_VALOR,16,2)} )
	   	Else
	    	aTitul2[nPonteiro][2] := str(Val(aTitul2[nPonteiro][2]) + MAK->MAK_VALOR,16,2)
   		Endif
	Else 
	   	cData := Dtoc(MAK->MAK_DATA)
		nPonteiro := Ascan(aTitul2,{|aVal| aVal[1] == cData .AND. AVal[2] = cGrupo})
	   	If nPonteiro == 0
		   	aAdd( aTitul2, {cData, cGrupo, str(MAK->MAK_VALOR,16,2)} )
	   	Else
    		aTitul2[nPonteiro][3] := str(Val(aTitul2[nPonteiro][3]) + MAK->MAK_VALOR,16,2)
	   	Endif
	Endif                            
	                 
	DbSelectArea( "MAK" )
	dbSkip()
End

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDCRM15  ºAutor  ³Frank Zwarg Fuga    º Data ³  06/27/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica as compras efetuadas do cliente.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDCRM15(cCodcli,cLoja,aFili)
Local nZ	:= 0	//controle de loop
Local nFili	:= 0	//controle de loop

DbSelectArea("SF2")
DbSetOrder(2)  

ProcRegua(len(aFili))             

For nFili := 1 to len(aFili)
	IncProc()
	DbSeek( aFili[nFili][01] + cCodCli + cLoja )	
	While !Eof() .AND. cCodCli == SF2->F2_CLIENTE .AND. cLoja == SF2->F2_LOJA                                     
	   DbSelectArea("SD2")
	   DbSetOrder(3)
	   DbSeek( aFili[nFili][01] + SF2->F2_DOC + SF2->F2_SERIE )
	   While !Eof() .AND. D2_FILIAL + D2_DOC + D2_SERIE == aFili[nFili][01] + SF2->F2_DOC + SF2->F2_SERIE     
			IF ( At( 'SB1E', cArqTab ) > 0 ) // SB1 exclusivo
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(aFili[nFili][01]+SD2->D2_COD)
			Else
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+SD2->D2_COD)
			Endif	
			// Grupo de produtos
			If !Eof()
				If ( At( 'SB1E', cArqTab ) > 0 ) // SB1 exclusivo
		      		DbSelectArea("SBM")      
					DbSetOrder(1)
					DbSeek(aFili[nFili][01]+SB1->B1_GRUPO)
				Else
		      		DbSelectArea("SBM")      
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+SB1->B1_GRUPO)	        
				Endif
			Endif	
			If Eof()
	        	cGrupo := STR0115 //"Grupo/Produtos nao definido"
			Else
	        	cGrupo := BM_DESC
			Endif
	 		If MV_PAR03 = 1                                   
				nPonteiro := Ascan(aTitul1,{|aVal| aVal[1] == cGrupo})
				If nPonteiro == 0
	        		aAdd( aTitul1, {cGrupo, str(SD2->D2_TOTAL,16,2)} )
				Else
	    	    	aTitul1[nPonteiro][2] := str(Val(aTitul1[nPonteiro][2]) + SD2->D2_TOTAL,16,2)
				Endif
			Else
	 			cData := Dtoc(SD2->D2_EMISSAO)
		    	nPonteiro := 0
		    	For nZ := 1 to Len(aTitul1)
		    		If aTitul1[nZ][01] == cData .AND. aTitul1[nZ][02] == cGrupo
		    			nPonteiro ++
		    			Exit
		    		Endif  
		    	Next nZ
				If nPonteiro == 0
	        		aAdd( aTitul1, {cData, cGrupo, str(SD2->D2_TOTAL,16,2)} )	
				Else	
	    	    	aTitul1[nZ][3] := str(Val(aTitul1[nZ][3]) + SD2->D2_TOTAL,16,2)	
				Endif				
			Endif	        
      	    DbSelectArea("SD2")
			dbSkip()	
	   End	
	   DbSelectArea("SF2")
	   dbSkip()	
	End               	
Next nFili

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDCRM16  ºAutor  ³Frank Zwarg Fuga    º Data ³  06/27/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica os titulos em abertos                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Interfaces de Venda                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista      ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q.    ³23/02/07³119542³- Retirado ajuste no dicionário.        º±±
±±ºHanna C.  	 |30/03/07|9.12  ³Bops 118469- Alterado o nome dos Bitmaps³±±
±±º        	 	 ³        |      ³definidos pela Engenharia p/ Protheus 10³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDCRM16()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tamanho da Dialog³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSize    := MsAdvSize( .T., .T., 250 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de dimensoes de objetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aObjects := {}
Local aInfo	   := {}
Local aPosObj  := {}

//ÚÄÄÄÄÄÄÄÄÄ¿
//³Genericas³
//ÀÄÄÄÄÄÄÄÄÄÙ
Local nCnt
Local nOpca    := 0
Local cCodCli  := M->A1_COD
Local cLoja    := M->A1_LOJA
Local cCampo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Resguarda ambiente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAtu := GetArea()
Local aAreaSE1 := SE1->( GetArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Variaveis do ListBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
Local aTitulos := {}
Local oTitulo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos e Titulos de Campos de SE1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFieldSE1 := {}
Local aTitleSE1 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coordenadas do ListBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLinBox
Local nColBox
Local nSize1
Local nSize2

//ÚÄÄÄÄÄÄ¿
//³Dialog³
//ÀÄÄÄÄÄÄÙ
Local oDlgT
Local aButtons := {}
Local cTitle := STR0025 // Titulos em aberto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir um Bitmap da Cor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oOk	 := LoadBitmap( GetResources(), "BR_VERDE" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo de Processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArquivo  
Local cFiltro :="" 
Local cChave       
Local aFilVal := {Space(FWGETTAMFILIAL)}
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento de SE1 - para a funcao de Enchoice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nLine
Private aPosSE1 := {}

If INCLUI
   MsgStop(STR0048,STR0049) //"Rotina não disponível na inclusão."###"Atenção !"
   Return
Endif                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os Parametros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("DAC030", .T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega botao da EnchoiceBar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aButtons , {"bmpvisual" , {|| CRM010_004() } , STR0026 } ) //Amplia titulo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      Dimensoes padroes         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estabelece as coordenadas do ListBox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinBox := aPosObj[1,1]
	nColBox := aPosObj[1,2]
	nSize1  := aPosObj[1,4]
	nSize2  := aPosObj[1,3] - 35
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A montagem de um "aHeader" para SE1 ³
	//³ tem o objetivo de automatizar a     ³
	//³ montagem dos campos do ListBox      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aFieldSE1, " " )
	aAdd(aTitleSE1, " " )
	aAdd(aFieldSE1, "E1_FILIAL" )
	aAdd(aTitleSE1, STR0116 ) //"Filial"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encontrar as filiais validas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SM0")
	dbGotop()
	
	While !Eof()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validar a empresa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M0_CODIGO <> cEmpAnt
			dbSkip()
			Loop
		Endif               

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validar a filial³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FWGETCODFILIAL < MV_PAR01 .OR. FWGETCODFILIAL > MV_PAR02
			dbSkip()
			Loop
		Endif
	     
		aAdd(aFilVal,FWGETCODFILIAL)
		dbSkip()
	
	End
	
	ProcRegua(Len(aFilVal)+1)             
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SE1")
	
	While !Eof() .AND.  (X3_ARQUIVO == "SE1")
	
	   If x3Uso(X3_USADO) .AND. (X3_BROWSE == "S")
	
	      aAdd(aFieldSE1, X3_CAMPO )
	      aAdd(aTitleSE1, Trim(X3_TITULO)  )
	
	   Endif
	
	   dbSkip()
	
	End
	
	IncProc()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento de Titulos   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aFilVal)
		DbSelectArea("SE1")
		DbSetOrder(2) // filial + cliente + loja + prefixo + num + parcela + tipo
		DbSeek( aFilVal[nX] + cCodCli + cLoja )
		While !Eof() .AND. E1_FILIAL+E1_CLIENTE+E1_LOJA == aFilVal[nX]+cCodCli+cLoja
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validar o status do titulo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If E1_STATUS <> " " .AND. E1_STATUS <> "A"
				dbSkip()
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validar o saldo do titulos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  SE1->E1_SALDO == 0
		      dbSkip()                                    
		      Loop
		   Endif                               
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente titulos informados no parametro MV_CRDTPLC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   If	!(AllTrim(SE1->E1_TIPO) $ SuperGetMV("MV_CRDTPLC"))
		      dbSkip()                                    
		      Loop
		   Endif
			aAdd( aTitulos , Array(Len(aFieldSE1)) )
			aAdd( aPosSE1  , {SE1->(RecNo()),SE1->E1_FILIAL} )
			For nCnt := 1 To Len( aFieldSE1 ) 
				If nCnt == 1
					aTitulos[Len(aTitulos)][nCnt] := oOk
				Else
					cCampo := "SE1->" + aFieldSE1[nCnt]
					aTitulos[Len(aTitulos)][nCnt] := &cCampo
				Endif
			Next nCnt
			dbSkip()
		End
		IncProc()		
	Next nX
	If Len( aTitulos ) == 0
	   MsgAlert(STR0027) // Nenhum titulo em aberto
	   RestArea( aAreaSE1 )
	   RestArea( aAreaAtu )
	   Return Nil
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresentacao do ListBox ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgT FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cTitle PIXEL 
	   oTitulo := TwBrowse():New( nLinBox,nColBox,nSize1,nSize2,,aTitleSE1,,oDlgT,,,,{|| nLine := oTitulo:nAt},,,,,,,,.F.,,.T.,,.F.,,,)
	   oTitulo:SetArray(aTitulos)
	   oTitulo:bLine := { || aTitulos[oTitulo:nAt] }
	ACTIVATE MSDIALOG oDlgT CENTERED ON INIT EnchoiceBar( oDlgT, {|| nOpca:=1, oDlgT:End()},;
	         {|| nOpca:=0, oDlgT:End()} , .F. , aButtons )                         
	         	
	DeleteObject( oTitulo )
	DeleteObject( oDlgT )
	RestArea( aAreaSE1 )
	RestArea( aAreaAtu )
Endif	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD010TP  ºAutor  ³Frank Zwarg Fuga    º Data ³  06/29/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizar os titulos pagos com varias filiais.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces ded Venda                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD010TP(nRecno, nBrowse, cFl)

Local aArea     := GetArea()
Local aAreaSE1  := SE1->(GetArea())
Local aAreaSE5  := SE5->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aSavAhead := If(Type("aHeader")=="A",aHeader,{})
Local aSavAcol  := If(Type("aCols")=="A",aCols,{})
Local nSavN     := If(Type("N")=="N",N,0)

If cFl <> cFilAnt
	cFilAnt := cFl
Endif

Do Case
Case ( nBrowse == 1 )
	SE1->(MsGoto(nRecno))
	SE1->(AxVisual("SE1",nRecNo,2))

Case ( nBrowse == 2 )
	SE5->(MsGoto(nRecno))
	SE5->(AxVisual("SE5",nRecNo,2))

Case ( nBrowse == 3 )
	SC5->(MsGoto(nRecno))		
	SC5->(a410Visual("SC5",nRecNo,2))

Case ( nBrowse == 4 )
	SF2->(MsGoto(nRecno))
	SF2->(Mc090Visual("SF2",nRecNo,2))
	
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aSavAHead
aCols   := aSavACol
N       := nSavN

RestArea(aAreaSC5)
RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retornar a filial original³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFl              

Return           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDSEMAFORºAutor  ³Frank Zwarg Fuga    º Data ³  09/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe algum usuario utilizando do mesmo regis-º±±
±±º          ³ tro.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Rotina que faz a chamada dessa funcao.             º±±
±±º			 ³ ExpN2 - RecNo do arquivo que sera travado.                 º±±
±±º			 ³ ExpN3 - Parametro passado por referencia para retornar o   º±±
±±º			 ³         RecNo do registro correspondente na tabela MAR.    º±±
±±º			 ³ ExpN4 - Parametro passado por referencia para retornar o   º±±
±±º			 ³         numero de referencia do arquivo de semaforo.       º±±
±±º			 ³ ExpC5 - Parametro passado por referencia para retornar o   º±±
±±º			 ³         nome do arquivo de semaforo.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºConrado Q ³04/04/07³10    ³BOPS 122711: Alterada a utilização da cham. º±±
±±º          ³        ³      ³SubStr(cUsuario,7,15) por cUserName         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDSEMAFORO(	cRotina,	nRegistro,	nRecMAR010,	nArqSem,;
						cArqSem)

Local aArea     := GetArea()               // Area atual.
Local cRegSem   := StrZero(nRegistro,10,0) // Registro que esta sendo travado.
Local lRet      := .T.                     // Indica se registro no MAR esta bloqueado por outro usuario.

DEFAULT nArqSem  := 0
DEFAULT cArqSem  := ""

DbSelectArea("MAR")
DbSetOrder(1)                 
cRotina := PadR(cRotina, Len(MAR->MAR_ROTINA))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esse semaforo sera controlado por um arquivo temporario alem de ser    ³
//³ controlado pela tabela MAR.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqSem := "SA1" + cRegSem + ".TMP"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³*** Nao substituir por MsSeek ***³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DbSeek(xFilial("MAR") + cRotina + cRegSem, .T.)
	RecLock("MAR",.T.)
	REPLACE MAR->MAR_FILIAL With xFilial("MAR")
	REPLACE MAR->MAR_ROTINA With cRotina
	REPLACE MAR->MAR_USUARI With cUserName
	REPLACE MAR->MAR_REGIST With cRegSem
	MsUnlock()
	nRecMAR010 := Recno()
	nArqSem    := MSFCreate(cArqSem)
	
	ConOut("1. CRDA010 - Inclui novo registro no MAR. Recno: " + MAR->MAR_REGIST + ;
	       " Rotina: " + MAR->MAR_ROTINA + " Usuario: " + MAR->MAR_USUARI + ;
	       " Cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA)		   	       	 		   	        	       
Else
	If File(cArqSem) .AND. FErase(cArqSem) < 0
		ConOut("2. CRDA010 - Encontrou registro no MAR. Recno: " + MAR->MAR_REGIST + ;
		" Rotina: " + MAR->MAR_ROTINA + " Usuario MAR: " + MAR->MAR_USUARI + ;
		" Usuario: " + cUserName + ;
		" Cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
		Alert(STR0131 + MAR->MAR_USUARI) //"Este registro está locado para o usuário: "
		lRet := .F.
	Else
		If MAR->MAR_USUARI <> cUserName
			RecLock("MAR", .F.)
			REPLACE MAR->MAR_USUARI With cUserName
			MsUnlock()
		Endif
		nRecMAR010 := MAR->(Recno())
		nArqSem := MSFCreate(cArqSem)
	Endif
Endif
RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C010Tplc  ºAutor  ³Kelly Christine     º Data ³  29/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna uma Matriz contendo os Tipos dos Titulos informa-  º±±
±±º          ³ dos no parametro MV_CRDTPLC.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Project Function C010TPLC()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATENCAO: Obrigatoriamente deve ser informado no parametro MV_CRDTPLC os tipos dos ³
//³titulos separados por virgulas. Ex.: FI,DP                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCrdTpLc 	:= AllTrim(SuperGetMV("MV_CRDTPLC"))
Local nX		:= 0   		//controle de loop
Local cAux		:= ""
Local aTiposTit := {}

For nX := 1 To Len(cCrdTpLc)
	If Substr(cCrdTpLc, nX, 1) == ","
		aAdd(aTiposTit, AllTrim(cAux))
		cAux := ""
	Else 
		cAux := cAux + Substr(cCrdTpLc, nX, 1)		
	Endif
Next nX
If Len(AllTrim(cAux)) > 0
	aAdd(aTiposTit, AllTrim(cAux))
Endif

Return(aTiposTit)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ    
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010AbanºAutor  ³Geronimo B. Alves   º Data ³  21/09/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pede confirmacao antes de abandonar a tela de Cadastro de  º±±
±±º          ³ Cliente                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA090                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³20/02/06³094117³- Utilizar a variavel nOpcx para identificarº±±
±±º          ³        ³      ³se esta em uma operacao de inclusao ou      º±±
±±º          ³        ³      ³alteracao de clientes.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Crd010Aband(nOpcx)

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Se estiver em uma operacao de inclusao ou alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpcx == 1 .OR. nOpcx == 4 
	lRet := MsgYesNo(STR0132 + Chr(13) + STR0133) //"Voce esta abandonando a tela de cadastro de cliente. "###"Deseja realmente abandonar as alterações efetuadas ? "
Endif                         

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010VldIºAutor  ³Fernando Machima    º Data ³  24/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se os indices de Codigo cliente + Loja nos arquivosº±±
±±º          ³MA9, MAA, MAB, MAC, MAE estao criados no dicionario de dadosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Crd010VldInd()			 						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Retorna se os indices existem no dicionario(SIX)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Crd010VldInd()

Local lRet      := .T.                                //Define se os indices foram criados 
Local nX        := 0                                   //Controle do loop
Local aArea     := GetArea()                          //Area atual
Local aArquivos := {"MA9","MAA","MAB","MAC","MAE"}   //Relacao dos alias que devem ser verificados

DbSelectArea("SIX")
For nX := 1 to Len(aArquivos)
   If !DbSeek(aArquivos[nX]+"2")
      lRet  := .F.
      Exit      
   Endif
Next nX   

RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010ValCar ºAutor  ³Henry Fila       º Data ³  18/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as linhas do acols dos cartoes                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Crd010ValCar(nOpcVal)		 						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd010ValCar(nOpcVal)

Local aArea         := GetArea()
Local nX			:= 0												//controle de loop
Local nPosCartao	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "MA6_NUM"})
Local nUsado        := Len(aHeader)
Local lRet			:= .T.

If nPosCartao > 0
	For nX := 1 to Len(aCols)
		If !aCols[nX][nUsado+1] .AND. !Empty(aCols[n][nPosCartao])
			If nX <> n
				If aCols[nX][nPosCartao] == aCols[n][nPosCartao]
					Help(" ", 1,"JAGRAVADO")
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Confere no MA6 se ja existe numero igual (exceto na alteração) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. !aCols[n][nUsado+1] .AND. !Empty(aCols[n][nPosCartao])
		MA6->(DbSetOrder(1))
		If MA6->( DbSeek(xFilial("MA6") + aCols[n][nPosCartao] ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Na alteracao nao mostrar a mensagem se o cod. cliente for o atual ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! ( nOpcVal == 4	 .AND. M->A1_COD+ M->A1_LOJA == MA6->MA6_CODCLI + MA6->MA6_LOJA )
				Help(" ", 1,"JAGRAVADO")
				lRet := .F.
			Endif
		Endif
	Endif
Endif
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010Ques   ºAutor  ³Geronimo B. Alvesº Data ³  31/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida as linhas do acols do Questionario Socio Economico  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Crd010Ques(nOpcVal)		 						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Numero da opcao 3=inclui, 4=altera , etc                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Bolenao                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd010Ques(nOpcVal)

Local nPosResposta	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "MAI_RESP"})
Local lRet			:= .T.

If nPosResposta > 0 .AND. X3OBRIGAT("MAI_RESP")
	If Empty( aCols[n][nPosResposta] )
	    //"Obrigatorio informar uma resposta para esta pergunta"###"Atenção !"
		MsgStop(STR0136,STR0049  )
		lRet := .F.
	Endif
Endif

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd010RefCar ºAutor  ³Henry Fila       º Data ³  18/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as linhas do acols de referencia dos cartoes         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Crd010RefCar()  			 						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd010RefCar()

Local nX			:= 0													//controle de loop
Local nPosCartao	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "MA9_CARTAO"})
Local nUsado        := Len(aHeader)
Local lRet			:= .T.

If nPosCartao > 0
	For nX := 1 to Len(aCols)                                
		If !aCols[nX][nUsado+1]	
			If nX <> n
				If aCols[nX][nPosCartao] == aCols[n][nPosCartao] 
					Help(" ", 1,"JAGRAVADO")
					lRet := .F.
					Exit
				Endif	
			Endif		 
		Endif	
	Next nX
Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³oGetd8Del  ºAutor  ³Geronimo B. Alves   º Data ³  23/09/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta linhas vazias da getdados do Perfil Socio Economico. º±±
±±º          ³Para facilitar interface c/ usuario; sistema permite sair daº±±
±±º          ³tela c/ linha em branco quando formulario nao estiver em usoº±±
±±º          ³Aqui deleto-as para nao irem para o banco de dados.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function oGetd8Del()
Local lRetorno   := .T.
Local cArea      := GetArea()
Local nPosPonto  := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PONTO"})
Local nPosDescri := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_DESCRE"})
Local nPosQuest  := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_QUEST"})
Local nPosPerg   := Ascan(aHeader8,{|x| Trim(x[2]) == "MAI_PERG"})
Local nI		 := 0													// controle de loop

For nI := 1 to len(oGetd8:aCols)
	If (nPosPonto > 0 .AND. Empty(oGetd8:aCols[nI][nPosPonto])) .OR. (nPosQuest > 0 .AND. Empty(oGetd8:aCols[nI][nPosQuest])) .OR. (nPosPerg > 0 .AND. Empty(oGetd8:aCols[nI][nPosPerg]))
		oGetd8:aCols[nI][LEN(aHeader8)+1] := .F.
	Endif
Next nI

RestArea(cArea)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CrdGrvAutMºAutor  ³Fernando Machima    º Data ³  07/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava novos cartoes no MA6 caso sejam inseridos novos depen-º±±
±±º			 ³dentes no arquivo MAC									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CrdGrvAutMA6(ExpC1, ExpC2)								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - codigo do cliente								  º±±
±±º			 ³ ExpC2 - loja do cliente								  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³Programador³  BOPS³ Manutencao Efetuada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³			 ³		³ 										  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CrdGrvAutMA6(cCodClie, cLojClie)

Local nX         := 0                                                  //Controle do loop
Local nPosCartao := ASCAN(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"}) //Posicao do campo que indica se dependente tem cartao
Local nPosNumCart:= ASCAN(aHeader5,{|x| Trim(x[2]) == "MAC_CART"})   //Posicao do campo do numero do cartao do dependente
Local nPosCodDep := ASCAN(aHeader5,{|x| Trim(x[2]) == "MAC_CODDEP"}) //Posicao do campo Codigo do dependente

If nPosNumCart > 0 .AND. nPosCartao > 0 .AND. nPosCodDep > 0
    DbSelectArea("MA6")
    DbSetOrder(1)
	For nX := 1 to Len(oGetd5:aCols)
		If !oGetd5:aCols[nX][LEN(aHeader5)+1]
			If !Empty(oGetd5:aCols[nX][nPosNumCart]) .AND. !Empty(oGetd5:aCols[nX][nPosCodDep]) .AND. ;
			   oGetd5:aCols[nX][nPosCartao] == "1"
			   
			   If !DbSeek(xFilial("MA6")+oGetd5:aCols[nX][nPosNumCart])      			   
			      RecLock("MA6",.T.)
			      REPLACE MA6->MA6_FILIAL With xFilial("MA6")			      
			      REPLACE MA6->MA6_CODCLI With cCodClie
			      REPLACE MA6->MA6_LOJA   With cLojClie			      
			      REPLACE MA6->MA6_NUM    With oGetd5:aCols[nX][nPosNumCart]
			      REPLACE MA6->MA6_CODDEP With oGetd5:aCols[nX][nPosCodDep]
			      REPLACE MA6->MA6_SITUA  With "1"			      //Ativo
			      REPLACE MA6->MA6_DTEVE  With dDatabase			      
			      MsUnlock()
			   Endif
			Endif
		Endif
	Next nX
Endif

Return (NIL)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD010XMsg ºAutor  ³Marcos R. Andrade   º Data ³  25/11/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna mesagem a ser exibida na tela de analise de credito º±±
±±º          ³informando o motivo do bloqueio.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³CRD010XMsg (ExpN1)	   							          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Numero da mensagem de bloqueio 				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Descricao da mensagem                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CRDA010                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function CRD010XMsg(nNumBlq)                             

Local cRet := ""	// Retorno da funcao
	    	                    
If nNumBlq == DTLIMNULA
	cRet := STR0165 	//"Data Limite de credito vazia"	
ElseIf nNumBlq == DTLIMVENC	
	cRet :=	 STR0166 	//"Data Limite de credito Vencida"                                       
ElseIf nNumBlq == LIMINSUF	
	cRet := STR0167 	//"Sem limite de credito."	
ElseIf nNumBlq == PASSAGEM			 	
   	cRet := STR0168 //"Risco de Passagem."
Endif
		
Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRDDELCLI ºAutor  ³Marcio Lopes        º Data ³  01/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se pode deletar o cliente selecionado			  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDDELCLI()

Local aFiliais 		:= {}				// Array das filiais
Local aSM0CodFil    := {}				// Codigo das filiais
Local nX 			:= 0				// Variavel do FOR
Local nRecnoSM0   	:= SM0->(RecNo())  // Guarda a posicao do SM0
Local cCod 			:= ""				// Código do Cliente
#IFDEF TOP
Local cQuery      	:= ""      			// Utilizacao na Query
#ENDIF
Local cInd        	:= ""				// Indice
Local cCondicao   	:= ""      			// Utilizacao na query
Local cKey        	:= ""				// Chave
Local lRet			:= .T.				// Retorno da Funcao
Local aArea			:= GetArea()		// Guarda a area do ambiente


dbSelectArea("SM0")
DBGoTop()
While !Eof()
	If SM0->M0_CODIGO == cEmpAnt
		aAdd(aSM0CodFil, FWGETCODFILIAL)
	Endif
	dbSkip()
End
dbGoto(nRecnoSM0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de deletar eu vou verificar se existe movimentacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCod := SA1->A1_COD + SA1->A1_LOJA
If lRet
	DbSelectArea("MAH")
	DbSetOrder(2)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
   
	If DbSeek(xFilial("MAH")+M->A1_COD+M->A1_LOJA)
 		MsgStop(STR0070,STR0049) //"Existe uma ocorrencia no cadastro dos contratos com este cliente."###"Atenção !"
		lRet := .F.
	Endif
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Orcamento no Televendas SUA               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SUA")
	dbSetOrder(6)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	nX := 1
	While nX <= Len(aFiliais) .AND. lRet
		If DBSeek(aFiliais[nX] + cCod)
	    	HELP(" ",1,"TMKNDELREL")
			lRet := .F.
			dbSelectArea("SA1")
			DbSetOrder(1)
			MsUnLock()
		EndIf
		++nX
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Atendimento no Telemarketing SUC          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("SUC")
	dbSetOrder(2)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	nX := 1
	While nX <= Len(aFiliais) .AND. lRet
 		If DBSeek(aFiliais[nX] + "SA1" + cCod)
        	HELP(" ",1,"TMKNDELREL")
			lRet := .F.
			dbSelectArea("SA1")
			DbSetOrder(1)
			MsUnLock()
		EndIf
		++nX
	End
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Pedido de Venda                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("SC5")
	dbSetOrder(3)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	nX := 1
	While nX <= Len(aFiliais) .AND. lRet
		DBSeek(aFiliais[nX] + SA1->A1_COD)
		While !Eof() .And. aFiliais[nX] + SA1->A1_COD == SC5->C5_FILIAL + SC5->C5_CLIENTE .AND. lRet
			If SA1->A1_LOJA == SC5->C5_LOJACLI .and. !(SC5->C5_TIPO $ "BD")
				HELP(" ",1,"MA030TEMPV",, "Filial " + aFiliais[nX], 3, 0)
				lRet := .F.
			EndIf
	
			If SA1->A1_LOJA == SC5->C5_LOJAENT .And. !SC5->C5_TIPO $ "DB"
				lRet := .F.
				HELP(" ",1,"MA030LOJEN",, "Filial " + aFiliais[nBusca], 3, 0)
			EndIf
			DbSkip()
		End
		++nX
	End			
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Contas a Receber deste cliente       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("SE1")      // Contas a receber
	DbSetOrder(2)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	nX := 1
	While nX <= Len(aFiliais) .AND. lRet
		If dbSeek(aFiliais[nX] + cCod)
			HELP(" ",1,"MA030TEMCR",, "Filial " + aFiliais[nX], 3, 0)
			lRet := .F.
		EndIf
		++nX
	End
EndIf	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Nota Fiscal de saida para este cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("SF2")
	dbSetOrder(2)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	nX := 1
	While nX <= Len(aFiliais) .AND. lRet
		dbSeek(aFiliais[nX] + cCod)
		While !Eof() .And. aFiliais[nX] + cCod == SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA .AND. lRet
			If !(SF2->F2_TIPO $ "BD")
				HELP(" ",1,"MA030TEMNF",, "Filial " + aFiliais[nX], 3, 0)
				dbSelectArea(cAlias)
				MsUnLock()
				lRet := .F.
			EndIf
			dbSkip()
		End
		++nX
	End
EndIf	

If lRet 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Base Instalada deste cliente       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AA3->( dbSetOrder( 1 ) ) 
	If AA3->( dbSeek( xFilial( "AA3" ) + cCod ) )
		Help( " ", 1, "MA030TEMBA" ) // "O cliente nao pode ser excluido pois existe base instalada para o mesmo !"
		lRet := .F. 
	EndIf 		
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe referencias cadastradas deste cliente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SAO") # 0 .AND. lRet
	dbSelectArea("SAO")      // Contas a receber
	DbSetOrder(1)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	While nX <= Len(aFiliais) .AND. lRet
		If dbSeek(aFiliais[nX] + cCod)
			HELP(" ",1,"MATA030REF",, "Filial " + aFiliais[nX], 3, 0)
			dbSelectArea(cAlias)
			MsUnLock()
			lRet := .F.
		EndIf
		++nX
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Pontos por setor                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("DA7")
	dbSetOrder(2)
	If !Empty(xFilial()) .and. Empty(xFilial("SA1"))
		aFiliais := aClone(aSM0CodFil)
	Else
		aFiliais := { xFilial() }
	EndIf
	If DbSeek(xFilial("DA7") + cCod)
		Help(" ",1,"NODELETA")
		lRet := .F.				
	Endif
Endif				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Time Service                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400" .AND. lRet
	
		DAF->( dbSetOrder( 1 ) ) 
	
		cQuery := "SELECT COUNT(*) QTDTIME "
		cQuery += " FROM " + RetSqlName("DAF")+ " DAF "
		cQuery += " WHERE "
		cQuery += " DAF_FILIAL = '"+xFilial("DAF")+"' AND "
		cQuery += " DAF_CODCLI = '"+SA1->A1_COD+"' AND "
		cQuery += " DAF_LOJA   = '"+SA1->A1_LOJA+"' AND "
		cQuery += " DAF.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
        If QRYVAL->QTDTIME > 0
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif	        	

		dbSelectArea("QRYVAL")
		dbCloseArea()
		dbSelectArea("DAF")
		
	Else
#ENDIF
	dbSelectArea("DAF")
	dbSetOrder(1)
	cInd := CriaTrab(NIL,.F.)

	cKey := IndexKey()
	cCondicao := 'DAF_FILIAL == "'+xFilial("DAF")+'" .And.'
	cCondicao += 'DAF_CODCLI == "'+SA1->A1_COD+'" .And.'		
	cCondicao += 'DAF_LOJA   == "'+SA1->A1_LOJA+'" '		

	IndRegua("DAF",cInd,cKey,,cCondicao) //"Selecionando Registros ..."
	nInd := RetIndex("DAF")

	#IFNDEF TOP
		dbSetIndex(cInd+OrdBagExT())
	#ENDIF   	
	dbSetOrder(nInd+1)
	dbGotop()

	If DAF->(!Eof())
 		Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
		lRet := .F.				
	Endif

	dbSelectArea("DAF")
	dbClearFilter()
	RetIndex("DAF")
	Ferase(cInd+OrdBagExt())
		
#IFDEF TOP
	Endif
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Regras de Entrega                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		DAD->( dbSetOrder( 1 ) )
	
		cQuery := "SELECT COUNT(*) QTDREGRA "
		cQuery += " FROM " + RetSqlName("DAD")+ " DAD "
		cQuery += " WHERE "
		cQuery += " DAD_FILIAL = '"+xFilial("DAD")+"' AND "
		cQuery += " DAD_CODCLI = '"+SA1->A1_COD+"' AND "
		cQuery += " DAD_LOJA   = '"+SA1->A1_LOJA+"' AND "
		cQuery += " DAD.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
        If QRYVAL->QTDREGRA > 0
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif	        	

		dbSelectArea("QRYVAL")
		dbCloseArea()
		dbSelectArea("DAD")

	Else
#ENDIF
		dbSelectArea("DAD")
		dbSetOrder(1)
		cInd := CriaTrab(NIL,.F.)

		cKey := IndexKey()
		cCondicao := 'DAD_FILIAL == "'+xFilial("DAD")+'" .And.'
		cCondicao += 'DAD_CODCLI == "'+SA1->A1_COD+'" .And.'		
		cCondicao += 'DAD_LOJA   == "'+SA1->A1_LOJA+'" '		

		IndRegua("DAD",cInd,cKey,,cCondicao) //"Selecionando Registros ..."
		nInd := RetIndex("DAD")

		#IFNDEF TOP
			dbSetIndex(cInd+OrdBagExT())
		#ENDIF   	
		dbSetOrder(nInd+1)
		dbGotop()

		If DAD->(!Eof())
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif

		dbSelectArea("DAD")
		dbClearFilter()
		RetIndex("DAD")
		Ferase(cInd+OrdBagExt())
		
#IFDEF TOP
	Endif
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Regras de bonificacao financeira      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		AI1->( dbSetOrder( 1 ) )
	
		cQuery := "SELECT COUNT(*) QTDREGRA "
		cQuery += "FROM " + RetSqlName("AI1")+ " AI1 "
		cQuery += "WHERE "
		cQuery += "AI1_FILIAL='"+xFilial("AI1")+"' AND "
		cQuery += "AI1_CODCLI='"+SA1->A1_COD   +"' AND "
		cQuery += "AI1_LOJA='"  +SA1->A1_LOJA  +"' AND "
		cQuery += "AI1.D_E_L_E_T_=' '"
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
		If QRYVAL->QTDREGRA > 0
			Help(" ",1,"NODELETA") //Nao e possivel excluir o cliente pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif	        	

		QRYVAL->( dbCloseArea() )   
		dbSelectArea( "SA1" )

	Else
#ENDIF

		AI1->( dbSetOrder( 2 ) ) 
		If AI1->( dbSeek( xFilial( "AI1" ) + SA1->A1_COD + SA1->A1_LOJA ) )
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif

#IFDEF TOP
	Endif
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Ordens de servicos                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		AB6->( dbSetOrder( 1 ) )
	
		cQuery := "SELECT COUNT(*) QTDORDENS "
		cQuery += "FROM " + RetSqlName("AB6")+ " AB6 "
		cQuery += "WHERE "
		cQuery += "AB6_FILIAL='"+xFilial("AB6")+"' AND "
		cQuery += "AB6_CODCLI='"+SA1->A1_COD   +"' AND "
		cQuery += "AB6_LOJA='"  +SA1->A1_LOJA  +"' AND "
		cQuery += "AB6.D_E_L_E_T_=' '"
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
		If QRYVAL->QTDORDENS > 0
			MsgStop(STR0034, STR0023) // "Este cliente possui uma ordem de serviço e não poderá ser excluído." // "Atenção!"
			lRet := .F.				
		Endif	        	

		QRYVAL->( dbCloseArea() )   
		dbSelectArea( "SA1" )

	Else
#ENDIF

		AB6->( dbSetOrder( 2 ) ) 
		If AB6->( dbSeek( xFilial( "AB6" ) + SA1->A1_COD + SA1->A1_LOJA ) )
			MsgStop(STR0034, STR0023) // "Este cliente possui uma ordem de serviço e não poderá ser excluído." // "Atenção!"
			lRet := .F.				
		Endif

#IFDEF TOP
	Endif
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem Chamados tecnicos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		AB1->( dbSetOrder( 1 ) )
	
		cQuery := "SELECT COUNT(*) QTDCHAMADOS "
		cQuery += "FROM " + RetSqlName("AB1")+ " AB1 "
		cQuery += "WHERE "
		cQuery += "AB1_FILIAL='"+xFilial("AB1")+"' AND "
		cQuery += "AB1_CODCLI='"+SA1->A1_COD   +"' AND "
		cQuery += "AB1_LOJA='"  +SA1->A1_LOJA  +"' AND "
		cQuery += "AB1.D_E_L_E_T_=' '"
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
		If QRYVAL->QTDCHAMADOS > 0
			MsgStop(STR0033, STR0023) // "Este cliente possui um chamado técnico e não poderá ser excluído." // "Atenção!"
			lRet := .F.				
		Endif	        	

		QRYVAL->( dbCloseArea() )   
		dbSelectArea( "SA1" )

	Else
#ENDIF

		AB1->( dbSetOrder( 2 ) ) 
		If AB1->( dbSeek( xFilial( "AB1" ) + SA1->A1_COD + SA1->A1_LOJA ) )
		   MsgStop(STR0033, STR0023) // "Este cliente possui um chamado técnico e não poderá ser excluído." // "Atenção!"
			lRet := .F.				
		Endif

#IFDEF TOP
	Endif
#ENDIF		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Nota de Entrada                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	
		SF1->( dbSetOrder( 1 ) )
	
		cQuery := "SELECT COUNT(*) QTDNFENT "
		cQuery += " FROM " + RetSqlName("SF1")+ " SF1 "
		cQuery += " WHERE "
		cQuery += " F1_FILIAL = '"+xFilial("SF1")+"' AND "
		cQuery += " F1_FORNECE = '"+SA1->A1_COD+"' AND "
		cQuery += " F1_LOJA   = '"+SA1->A1_LOJA+"' AND "
		cQuery += " (F1_TIPO   = 'B' OR "				
		cQuery += " F1_TIPO   = 'D') AND "								
		cQuery += " SF1.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
        If QRYVAL->QTDNFENT > 0
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif	        	

		dbSelectArea("QRYVAL")
		dbCloseArea()
		dbSelectArea("SF1")

	Else
#ENDIF

		dbSelectArea("SF1")
		dbSetOrder(1)
		cInd := CriaTrab(NIL,.F.)

		cKey := IndexKey()
		cCondicao := 'F1_FILIAL == "'+xFilial("SF1")+'" .And.'
		cCondicao += 'F1_FORNECE == "'+SA1->A1_COD+'" .And.'		
		cCondicao += 'F1_LOJA   == "'+SA1->A1_LOJA+'" .And.'		
		cCondicao += 'F1_TIPO   $ "DB" '		

		IndRegua("SF1",cInd,cKey,,cCondicao) //"Selecionando Registros ..."
		nInd := RetIndex("SF1")

		#IFNDEF TOP
			dbSetIndex(cInd+OrdBagExT())
		#ENDIF   	
		dbSetOrder(nInd+1)
		dbGotop()

		If SF1->(!Eof())
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif

		dbSelectArea("SF1")
		dbClearFilter()
		RetIndex("SF1")
		Ferase(cInd+OrdBagExt())
		
#IFDEF TOP
	Endif
#ENDIF		

RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³CRDxTela ³ Autores ³ Marcos Roberto Andrade ³ Data ³26/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRDxTela(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor.

If nHRes <= 640  // Resolucao 640 x 480 (so Ocean e Classic aceitam 640).
	nTam *= 0.8
ElseIf nHRes <= 800  // Resolucao 800 x 600.
	If Alltrim(GetTheme()) == "FLAT" .OR. SetMdiChild()
		nTam *= 0.88
	Endif
Else  // Resolucao 1024 x 768 e acima.
	nTam *= 1.28
Endif
Return Int(nTam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD010MontaºAutor  ³Conrado Q. Gomes    º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montagem do aHeader e do aCols através da FillGetDados.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA010                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR   ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º               ³        ³      ³                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRD010Monta( nOpc, cAlias, cSeek, cWhile, aNoFields, aNewHeader, aNewCols, aColsR )
	Local nRecno	:= 0	// Número dos registros existentes na aCols
	Local aSavHeader:= {}	// Backup do aHeader atual
	Local aSavCols	:= {}	// Backup do aCols atual
	Local nX		:= 0	// Contador
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz o backup do aHeader e do aCols.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If( Len( aHeader ) > 0	, aSavHeader	:= aClone( aHeader	)	, )
	If( Len( aCols ) > 0	, aSavCols		:= aClone( aCols )		, )
	aHeader	:= {}
	aCols	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta aHeader e aCols.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If INCLUI
		FillGetDados(	nOpc			,cAlias		,2				,/*cSeek*/		,;
						/*{||&cWhile}*/	,{|| .T. }	,aNoFields		,/*aYesFields*/	,; 
						/*lOnlyYes*/	,/*cQuery*/	,/*bMontCols*/	,.T.			)
	Else
		FillGetDados(	nOpc			,cAlias			,2				,cSeek				,;
		   				{|| &cWhile }	,{|| .T. }		,aNoFields		,/*aYesFields*/		,; 
		   				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/	,/*lEmpty*/			,;
		   				/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,/*bBeforeCols*/	)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o número dos registros adicionados no aCols.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCols )
		nRecno := aCols[ nX ][ aScan(aHeader, { |x| x[2] == cAlias + "_REC_WT" } ) ]
		If ( nRecno <> 0 )
			aAdd( aColsR, nRecno  )
		EndIf
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva aHeader e a aCols gerados nas variáveis passadas³
	//³pelo parâmetro.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNewHeader	:= aClone( aHeader )
	aNewCols	:= aClone( aCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura aHeader e aCols anterior.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If( Len(aSavHeader) > 0	, aHeader	:= aClone( aSavHeader )	, )
	If( Len(aSavCols) >0 	, aCols		:= aClone( aSavCols )	, )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma030AltOk³ Autor ³ Nunzio Autorino Junior³ Data ³ 31/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em enviar os dados do cliente para integracao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de clientes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd10AltOk()

Local cTipo 		:= ""											//Como os dados serao integrados no processo offline
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline

//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("007")
	
	//Determina o tipo de operacao
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	Else
		cTipo := "DELETE"
		
		//Considera os registros deletados
		SET DELETED OFF
	EndIf
	
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir("SA1", xFilial("SA1") + SA1->A1_COD + SA1->A1_LOJA, 1, cTipo)
		
		//Processa os dados
		oProcessOff:Processar()
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf

Return Nil  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CRD10CGCOK³ Autor ³ Vendas CRM            ³ Data ³ 24/2/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em validar o CGC do cliente se habilitada a in-³±±   
±±³          ³ tegracao com o financial services, exibindo uma mensagem   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CRD10CGCOK(Expl1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ [Expl1] - Exibe mensagem  - default .f.                    ³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de clientes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function CRD10CGCOK(lMsg)
Local aArea :=  GetArea()  //WorkArea Corrente
Local aAreaSX3 := nil  //WorkArea SX3
Local lRet := .T.     //Retorno da funcao

Default lMsg := .F. 

If  lMvLjIntFS .AND. nModulo == 12 .AND. (ValType("M->A1_CGC") == "U" .OR. Empty(M->A1_CGC))
	lRet := .F.
	If lMsg
		cTitulo := "A1_CGC"
	    aAreaSX3 := SX3->(GetArea())
	
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek( "A1_CGC" ) )
		   cTitulo := X3Titulo()
		EndIf
			
	 	RestArea(aAreaSX3)
	 	
		Msgstop( STR0071 + cTitulo +; //"Faltou o preenchimento do campo "
	            STR0072 + " " +  STR0008)  //" localizado na pasta""Ficha cadastral"	

	EndIf
EndIf 

RestArea(aArea)    

Return lRet  
           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CRDAINTGFE³ Autor ³ Vendas CRM            ³ Data ³ 24/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza chamada da integracao com SIGAGFE (Mata030)		  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CRDAINTGFE(Expl1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ [ExpN1] - Identifica Incluscao/Alteracao/Exclusao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de clientes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function CRDAINTGFE( nOpcx )

Local lIntGFE		:= SuperGetMv("MV_INTGFE",,.F.) 
Local lIntegDef		:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("MATA030",.T.,,.T.)
Local aStruModel	:= {}
Local aFieldValue 	:= {}

Default nOpcx 	:= 0

If lIntGFE .OR. lIntegDef
                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Chamada da função IntegDef()	utilizada no processo do MATA030³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
	If lIntegDef               
	 	FwIntegDef("MATA030")
	EndIf	
		   	
	If FindFunction("MaEnvEAI")		
		
		If nOpcx == 3 //Inclusao
			If lIntGFE
				aFieldValue := { { "A1_CLIFIL", { || A030CliFil(SA1->A1_CGC) } }}	
			EndIf	
					
			Aadd(aStruModel, { "SA1", "MATA030_SA1" , NIL, NIL, NIL, aFieldValue } )
			MaEnvEAI(,,4,"MATA030",aStruModel,,,,,,"MATA030" )		
		ElseIf nOpcx == 4 .OR. nOpcx == 5  //alteracao ou exclusao
			MaEnvEAI(,,nOpcx,"MATA030",{ { "SA1", "MATA030_SA1", NIL, NIL, NIL, NIL } },,,,,,"MATA030"  )		
		EndIf	
				
	EndIf	  
		
EndIf 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaSYP
Atualiza campo memo VM_OBS

@param   nOpcx				Opcao de inclusao/alteracao/exclusao
@author  Varejo
@version P11.8
@since   08/09/2015
@return  Nil
@obs     
@sample
/*/

Static Function AtualizaSYP(nOpcx)

Default nOpcx := 1       

If SA1->(FieldPos("A1_VM_OBS") > 0)
	
	If nOpcx == 3 .OR. nOpcx == 4  //Incluir ou Alterar   1
		nOpcx := 1 
	ElseIf nOpcx == 5	//Excluir
		nOpcx := 2
	EndIf
	
	MSMM(SA1->A1_OBS,TamSX3("A1_VM_OBS")[1],,M->A1_VM_OBS,nOpcx,,,"SA1","A1_OBS")	
	
EndIf
	
Return Nil


