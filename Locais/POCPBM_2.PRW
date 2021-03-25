#include "TOTVS.CH"

#DEFINE _CLISITEF "4" //4=CliSitef

Static cCodEmp   := "99" //Empresa
Static cCodFil   := "01" //Filial
Static cEnvMod   := "FRT" //Front Loja
Static aTables   := {"SLG","MDG"}
Static cIPSiTEF  := "127.0.0.1"
Static cCodLoja  := "00000000"
Static cNumTerm  := "MS000200"
Static cCNPJEstb := "53113791000122"
Static cCNPJTOTVS:= "53113791000122"
Static cParamAdic:= "[ParmsClient=1=" + cCNPJEstb + ";2=" + cCNPJTOTVS + "]" // 1=CNPJ do estabelecimento 2=CNPJ da Software House

Static nRedeDestino     := 62
Static nFuncaoSitef     := 240
Static nOffSetCartao    := 0
Static cDadosTx         := "27"+Chr(0)+"1"+Chr(0)+"12345"
Static nTamDadosTx      := 10
Static cDadosRx 	    := Space(10000)
Static nTamMaxDadosRx	:= Len(cDadosRx)
Static nCodigoResposta  := 0
Static nTempoEsperaRx   := 30
Static cCupomFiscal     := "102030" //Codigo qualquer aleatório, cupom fiscal
Static cDataFiscal      := dtos(date())
Static cHorario         := StrTran(Time(),":","")
Static cOperador        := "2" //PDV
Static nTipoTransacao   := 1 //Tipo de documento utilizado no PBM:  0=ECF, 1=NFC-e, 2=SAT

/*
 POC para analisar o funcionamento da comunicação com o TEF (Software Express) 
 utilizando o módulo de PBM (Programas de Benefício em Medicamentos)
*/
User Function POCPBM_2()
Local oDlg      := Nil
Local oTButton1 := Nil
Local oTButton2 := Nil

RpcSetType(3)
RpcSetEnv(cCodEmp, cCodFil,,,cEnvMod,,aTables)
__cInterNet := Nil //Força essa variavel para nao entrar em modo automatico(IsBlind())
lMsFinalAuto := .F.
lMsHelpAuto  := .F.

//Inclui a estrutura e informações da tabela SLZ referente ao PBM.
IncSLZ()

//Inicializa as funcoes e variaveis (Private / Public) padrões do módulo do LOJA
OpenLoja()

DEFINE MSDIALOG oDlg TITLE "POC PBM" FROM 0,0 TO 15,41

TSay():Create(oDlg,{||'Utilizando a DLL AUTOCOM.DLL'},05,01,,,,,,.T.,,,200,20)
oTButton1 := TButton():New( 015, 010, "Funcionando",oDlg,{|| (PBMAutoCom(), oDlg:End()) }, 100,20,,,.F.,.T.,.F.,,.F.,,,.F. )

TSay():Create(oDlg,{||'Utilizando a DLL TOTVSAPI.DLL'},60,01,,,,,,.T.,,,200,20)
oTButton2 := TButton():New( 070, 010, "Com Problema",oDlg,{|| (PBMTotvsApi(), oDlg:End()) }, 100,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlg CENTERED

RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões

Return 

//*********************************************************************/
// Chamada de comunicação com a DLL Autocom.dll (Funcionando) 
//*********************************************************************/
Static Function PBMAutoCom()
Local oPBM      := NIL
Local cOperador := ""
Local cNumCup   := ""
Local cTpDoc    := ""

//Variável Private "cEstacao" é criada na camada de FRAME ao iniciar o ENVIRONMENT
//Vamos simular aqui o acesso pela estação "002", para considerar as configurações que estão na tabela SLG
cEstacao    := "002"

//Seta o Parâmetro para indicar que está usando o TEF 1.0, e não TEF 2.0
DbSelectArea("SX6")
SX6->(dbSetOrder(1)) //X6_FIL+X6_VAR
If SX6->(dbSeek(Space(Len(SX6->X6_FIL))+"MV_LJTEF20"))
    RecLock("SX6", .F.)
    SX6->X6_CONTEUD := ".F."
    SX6->(MsUnLock())
EndIf

//Inclui as configurações da estação
IncEstacao()

cOperador   := STFGetStation("PDV")
cNumCup     := "102030" //Número qualquer aleatório representando o número do cupom fiscal
cTpDoc      := "1"      //Tipo de documento utilizado no PBM:  0=ECF, 1=NFC-e, 2=SAT

//--------------------------------
// Instacia a Classe do TEF 1.0
//--------------------------------
oTEF 	:= LJTEFAbre() //Prepara o objeto TEF e carrega as variáveis necessárias para a utilização do TEF
lUsaTef := oTef:lAtivo //Indica se a abertura de terminal foi processada com sucesso

oPBM := LjCPbm():Pbm()

//Seleciona a PBM
If !oPBM:SelecPbm()
    oPBM := Nil
Else
    //Inicializa a venda PBM
    If !oPBM:IniciaVend( cNumCup, cOperador, cTpDoc )
        oPBM := Nil
        MsgStop("Falha na Comunicação realizada com PBM." + Chr(13)+Chr(13) + "DLL Autocom.dll")
    Else
        MsgAlert("Sucesso na Comunicação realizada com PBM." + Chr(13)+Chr(13) + "DLL Autocom.dll")
    EndIf
EndIf

Return

//*********************************************************************/
// Chamada de comunicação com a DLL Totvsapi.dll (Com Problema) 
//*********************************************************************/
Static Function PBMTotvsApi()
Local oPBM      := NIL
Local oTEF20    := NIL
Local oDados    := NIL
Local cOperador := ""
Local cNumCup   := ""
Local cTpDoc    := ""

//Variável Private "cEstacao" é criada na camada de FRAME ao iniciar o ENVIRONMENT
//Vamos simular aqui o acesso pela estação "001", para considerar as configurações que estão nas tabelas SLG e MDG.
cEstacao    := "001"

//Seta o Parâmetro para indicar que está usando TEF 2.0
DbSelectArea("SX6")
SX6->(dbSetOrder(1)) //X6_FIL+X6_VAR
If SX6->(dbSeek(Space(Len(SX6->X6_FIL))+"MV_LJTEF20"))
    RecLock("SX6", .F.)
    SX6->X6_CONTEUD := ".T."
    SX6->(MsUnLock())
EndIf

//Inclui as configurações da estação
IncEstacao()

cOperador   := STFGetStation("PDV")
cNumCup     := "102030" //Número qualquer aleatório representando o número do cupom fiscal
cTpDoc      := "1"      //Tipo de documento utilizado no PBM:  0=ECF, 1=NFC-e, 2=SAT

//--------------------------------
// Instacia a Classe do TEF 2.0
//--------------------------------
oTEF20 := LJC_TEF():New(cEstacao, .F.) 
STBSetTef(oTEF20)

oPBM := oTEF20:Pbm()

oDados := LJCDadosTransacaoPBM():New(0,cNumCup,Date(),Time(),,,cTpDoc,cOperador)

If oPBM:SelecPBM()
    oRetorno := oPBM:IniciaVend(oDados)
EndIf

Return

//*************************************************************************/
//Inclui as configurações da estação, caso não exista na base de dados.
//*************************************************************************/
Static Function IncEstacao()
Local lAppend  := .F.

//Quanto é utilizado o TEF 1.0, utiliza a DLL Autocom.dll e apenas as configurações da tabela SLG para carregar o objeto do TEF
//Quando é utilizado TEF 2.0, utiliza a DLL TotvsApi.dll e as configurações da tabela MDG para para carregar o objeto do TEF 2.0

//Inclui/Atualiza as Configurações da Estação na tabela SLG
DbSelectArea("SLG")
SLG->(DbSetOrder(1)) //LG_FILIAL+LG_CODIGO
lAppend := SLG->( !DbSeek(xFilial("SLG")+cEstacao) )
RecLock("SLG", lAppend)
SLG->LG_FILIAL  := xFilial("SLG")
SLG->LG_CODIGO  := cEstacao
SLG->LG_NOME    := "ESTACAO TESTE " + cEstacao
SLG->LG_REDES   := "000"
SLG->LG_IMPTEF  := "N"
SLG->LG_IMPTEFC := "N"
SLG->LG_TIPTEF  := "6" //6=SITEF
SLG->LG_TEFCONS := "NNNNNNNN"
SLG->LG_TEFCONS := "NNNNNNNN"
SLG->LG_PDV     := cEstacao
SLG->LG_IPSITEF := cIPSiTEF
SLG->LG_LARGCOL := 40
SLG->LG_NFCE    := .T.
SLG->LG_USESAT  := .F.
SLG->LG_ISPOS   := "2"
SLG->(MsUnLock())


//Verifica se está usando o TEF 2.0 (DLL TotvsApi.dll), para incluir/atualizar registro também na tabela MDG.
If SuperGetMv("MV_LJTEF20",,.F.)
    DbSelectArea("MDG")
    MDG->(DbSetOrder(1)) //MDG_FILIAL+MDG_CODEST
    lAppend := MDG->( !DbSeek(xFilial("MDG")+cEstacao) )
    RecLock("MDG", lAppend)
    MDG->MDG_FILIAL := xFilial("MDG")
    MDG->MDG_CODEST := "001"
    MDG->MDG_IPSIT  := cIPSiTEF
    MDG->MDG_EMPSIT := "00000000"
    MDG->MDG_TERSIT := "MS000100"
    MDG->MDG_CARSIT := "1"
    MDG->MDG_CHQSIT := "2"
    MDG->MDG_RCSIT  := "1"
    MDG->MDG_CBSIT  := "2"
    MDG->MDG_PBMSIT := "1"
    MDG->MDG_TPCBSI := ""
    MDG->MDG_GPAPL  := ""
    MDG->MDG_GPTX   := ""
    MDG->MDG_GPRX   := ""
    MDG->MDG_CARGP  := "2"
    MDG->MDG_CHQGP  := "2"
    MDG->MDG_TECAPL := ""
    MDG->MDG_TECTX  := ""
    MDG->MDG_TECRX  := ""
    MDG->MDG_CARTEC := "2"
    MDG->MDG_CHQTEC := "2"
    MDG->MDG_HIPAPL := ""
    MDG->MDG_HIPTX  := ""
    MDG->MDG_HIPRX  := ""
    MDG->MDG_CARHIP := "2"
    MDG->MDG_PAYAPL := ""
    MDG->MDG_PAYTX  := ""
    MDG->MDG_PAYRX  := ""
    MDG->MDG_CARPAY := "2"
    MDG->MDG_CHQPAY := "2"
    MDG->MDG_TEFATV := "1"
    MDG->MDG_EPHARM := "1"
    MDG->MDG_TRNCEN := "1"
    MDG->MDG_DIRAPL := ""
    MDG->MDG_DIRTX  := ""
    MDG->MDG_DIRRX  := ""
    MDG->MDG_CARDIR := "2"
    MDG->MDG_CHQDIR := "2"
    MDG->MDG_CIELOP := "2"
    MDG->(MsUnLock())
EndIf

Return


//*************************************************************************/
//Inclui a estrutura e informações da tabela SLZ referente ao PBM.
//*************************************************************************/
Static Function IncSLZ()
Local lAppend   := .F.
Local nX2_TAMFIL:= 0
Local nX2_TAMUN := 0
Local nX2_TAMEMP:= 0
Local cUsadoNao	:= ""
Local cReservNao:= ""
Local cUsadoKey	:= ""
Local cReservKey:= ""
Local nI        := 0
Local nX        := 0
Local aSX3      := {}
Local aEstru := {   "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
                    "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
                    "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
                    "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
                    "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
                    "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"  }

//Se nao existir a estrutura da tabela SLZ, inclui nos dicionários SX2, SX3, SIX
If !AliasInDic("SLZ")
    DbSelectArea("SX3")
    SX3->( dbSetOrder(2) ) //X3_CAMPO
    SX3->( dbSeek( "A1_FILIAL" ) )
    cUsadoNao	:= SX3->X3_USADO
    cReservNao	:= SX3->X3_RESERV

    SX3->( dbSeek( "A1_COD" ) )
    cUsadoKey	:= SX3->X3_USADO
    cReservKey	:= SX3->X3_RESERV

    DbSelectArea("SX2")
    SX2->(DbSetOrder(1)) //X2_CHAVE
    If SX2->(DbSeek("SA1"))
        nX2_TAMFIL:= SX2->X2_TAMFIL
        nX2_TAMUN := SX2->X2_TAMUN
        nX2_TAMEMP:= SX2->X2_TAMEMP
    EndIf
    
    //------------------------
    //Estrutura da tabela SLZ
    //------------------------
    RecLock("SX2", .T.)
    SX2->X2_CHAVE   := "SLZ"
    SX2->X2_CHAVE   := "SLZ"
    SX2->X2_ARQUIVO := "SLZ"+cEmpAnt+"0"
    SX2->X2_NOME    := "PBM"
    SX2->X2_MODO    := "C"
    SX2->X2_MODOUN  := "E"
    SX2->X2_MODOEMP := "E"
    SX2->X2_UNICO   := "LZ_COD"
    SX2->X2_PYME    := "S"
    SX2->X2_DISPLAY := "LZ_COD+LZ_DESC+LZ_FUNCAO"
    SX2->X2_POSLGT  := "1"
    SX2->X2_CLOB    := "2"
    SX2->X2_AUTREC  := "2"
    SX2->X2_TAMFIL  := nX2_TAMFIL
    SX2->X2_TAMUN   := nX2_TAMUN
    SX2->X2_TAMEMP  := nX2_TAMEMP
    SX2->(MsUnLock())

    //---------------------
    //Campos da tabela SLZ
    //---------------------
    aAdd( aSX3, { ;
        'SLZ'                                                                   	, ; //X3_ARQUIVO
        "01"                                                                      	, ; //X3_ORDEM
        'LZ_FILIAL'      	                                                 		, ; //X3_CAMPO
        'C'                                                                     	, ; //X3_TIPO
        Len(cFilAnt)		                                                  		, ; //X3_TAMANHO
        0                                                                       	, ; //X3_DECIMAL
        "Filial"          	              	                          		    	, ; //X3_TITULO
        "Filial"	    	    	       	                          			   	, ; //X3_TITSPA 
        "Filial" 	            	                               			       	, ; //X3_TITENG
        "Filial"      				                   			                    , ; //X3_DESCRIC
        "Filial" 	    		           			                                , ; //X3_DESCSPA
        "Filial"      					                                            , ; //X3_DESCENG
        ''          		                                                     	, ; //X3_PICTURE
        ''                                                                      	, ; //X3_VALID
        cUsadoNao  																	, ;	//X3_USADO
        ''                                                                      	, ; //X3_RELACAO
        ''                                                                      	, ; //X3_F3
        0                                                                       	, ; //X3_NIVEL
        cReservNao 			                                                		, ; //X3_RESERV
        ''                                                                      	, ; //X3_CHECK
        ''                                                                      	, ; //X3_TRIGGER
        'S'	                                                                     	, ; //X3_PROPRI
        'N'                                                                     	, ; //X3_BROWSE
        'V'                                                                     	, ; //X3_VISUAL
        'R'                                                                     	, ; //X3_CONTEXT
        ''                                                                      	, ; //X3_OBRIGAT
        ''                                                                      	, ; //X3_VLDUSER
        ''                                                                      	, ; //X3_CBOX
        ''                                                                      	, ; //X3_CBOXSPA
        ''                                                                      	, ; //X3_CBOXENG
        ''                                                                      	, ; //X3_PICTVAR
        ''                                                                      	, ; //X3_WHEN
        ''                                                                      	, ; //X3_INIBRW
        '033'                                                                      	, ; //X3_GRPSXG
        ''                                                                      	, ; //X3_FOLDER
        'S'                                                                      	} ) //X3_PYME

    aAdd( aSX3, { ;
        'SLZ'                                                                   	, ; //X3_ARQUIVO
        "02"                                                                      	, ; //X3_ORDEM
        'LZ_COD'      	                                                 	    	, ; //X3_CAMPO
        'C'                                                                        	, ; //X3_TIPO
        2               	                                                  		, ; //X3_TAMANHO
        0                                                                       	, ; //X3_DECIMAL
        "Codigo"          	              	                          		    	, ; //X3_TITULO
        "Codigo"	    	    	       	                          			   	, ; //X3_TITSPA 
        "Codigo" 	            	                               			       	, ; //X3_TITENG
        "Codigo da PBM"      		                   			                    , ; //X3_DESCRIC
        "Codigo da PBM" 	 	           			                                , ; //X3_DESCSPA
        "Codigo da PBM"      			                                            , ; //X3_DESCENG
        ''          		                                                     	, ; //X3_PICTURE
        ''                                                                      	, ; //X3_VALID
        cUsadoKey  																	, ;	//X3_USADO
        ''                                                                      	, ; //X3_RELACAO
        ''                                                                      	, ; //X3_F3
        0                                                                       	, ; //X3_NIVEL
        cReservKey 			                                                		, ; //X3_RESERV
        ''                                                                      	, ; //X3_CHECK
        ''                                                                      	, ; //X3_TRIGGER
        'S'	                                                                     	, ; //X3_PROPRI
        'S'                                                                     	, ; //X3_BROWSE
        'A'                                                                     	, ; //X3_VISUAL
        'R'                                                                     	, ; //X3_CONTEXT
        ''                                                                      	, ; //X3_OBRIGAT
        ''                                                                      	, ; //X3_VLDUSER
        ''                                                                      	, ; //X3_CBOX
        ''                                                                      	, ; //X3_CBOXSPA
        ''                                                                      	, ; //X3_CBOXENG
        ''                                                                      	, ; //X3_PICTVAR
        ''                                                                      	, ; //X3_WHEN
        ''                                                                      	, ; //X3_INIBRW
        ''                                                                      	, ; //X3_GRPSXG
        ''                                                                      	, ; //X3_FOLDER
        'S'                                                                      	} ) //X3_PYME


    aAdd( aSX3, { ;
        'SLZ'                                                                   	, ; //X3_ARQUIVO
        "03"                                                                      	, ; //X3_ORDEM
        'LZ_DESC'      	                                                 	    	, ; //X3_CAMPO
        'C'                                                                        	, ; //X3_TIPO
        50               	                                                  		, ; //X3_TAMANHO
        0                                                                       	, ; //X3_DECIMAL
        "Descricao"        	              	                          		    	, ; //X3_TITULO
        "Descricao"	    	    	       	                          			   	, ; //X3_TITSPA 
        "Descricao" 	            	                               			   	, ; //X3_TITENG
        "Descricao da PBM"     		                   			                    , ; //X3_DESCRIC
        "Descricao da PBM" 	 	           			                                , ; //X3_DESCSPA
        "Descricao da PBM"      			                                        , ; //X3_DESCENG
        ''          		                                                     	, ; //X3_PICTURE
        ''                                                                      	, ; //X3_VALID
        cUsadoKey  																	, ;	//X3_USADO
        ''                                                                      	, ; //X3_RELACAO
        ''                                                                      	, ; //X3_F3
        0                                                                       	, ; //X3_NIVEL
        cReservKey 			                                                		, ; //X3_RESERV
        ''                                                                      	, ; //X3_CHECK
        ''                                                                      	, ; //X3_TRIGGER
        'S'	                                                                     	, ; //X3_PROPRI
        'S'                                                                     	, ; //X3_BROWSE
        'A'                                                                     	, ; //X3_VISUAL
        'R'                                                                     	, ; //X3_CONTEXT
        ''                                                                      	, ; //X3_OBRIGAT
        ''                                                                      	, ; //X3_VLDUSER
        ''                                                                      	, ; //X3_CBOX
        ''                                                                      	, ; //X3_CBOXSPA
        ''                                                                      	, ; //X3_CBOXENG
        ''                                                                      	, ; //X3_PICTVAR
        ''                                                                      	, ; //X3_WHEN
        ''                                                                      	, ; //X3_INIBRW
        ''                                                                      	, ; //X3_GRPSXG
        ''                                                                      	, ; //X3_FOLDER
        'S'                                                                      	} ) //X3_PYME


    aAdd( aSX3, { ;
        'SLZ'                                                                   	, ; //X3_ARQUIVO
        "04"                                                                      	, ; //X3_ORDEM
        'LZ_FUNCAO'    	                                                 	    	, ; //X3_CAMPO
        'C'                                                                        	, ; //X3_TIPO
        50               	                                                  		, ; //X3_TAMANHO
        0                                                                       	, ; //X3_DECIMAL
        "Funcao"        	              	                          		    	, ; //X3_TITULO
        "Funcao"	    	    	       	                          			   	, ; //X3_TITSPA 
        "Funcao" 	            	                               			       	, ; //X3_TITENG
        "Funcao da PBM"     		                   			                    , ; //X3_DESCRIC
        "Funcao da PBM" 	 	           			                                , ; //X3_DESCSPA
        "Funcao da PBM"      			                                            , ; //X3_DESCENG
        ''          		                                                     	, ; //X3_PICTURE
        ''                                                                      	, ; //X3_VALID
        cUsadoKey  																	, ;	//X3_USADO
        ''                                                                      	, ; //X3_RELACAO
        ''                                                                      	, ; //X3_F3
        0                                                                       	, ; //X3_NIVEL
        cReservKey 			                                                		, ; //X3_RESERV
        ''                                                                      	, ; //X3_CHECK
        ''                                                                      	, ; //X3_TRIGGER
        'S'	                                                                     	, ; //X3_PROPRI
        'S'                                                                     	, ; //X3_BROWSE
        'A'                                                                     	, ; //X3_VISUAL
        'R'                                                                     	, ; //X3_CONTEXT
        ''                                                                      	, ; //X3_OBRIGAT
        ''                                                                      	, ; //X3_VLDUSER
        ''                                                                      	, ; //X3_CBOX
        ''                                                                      	, ; //X3_CBOXSPA
        ''                                                                      	, ; //X3_CBOXENG
        ''                                                                      	, ; //X3_PICTVAR
        ''                                                                      	, ; //X3_WHEN
        ''                                                                      	, ; //X3_INIBRW
        ''                                                                      	, ; //X3_GRPSXG
        ''                                                                      	, ; //X3_FOLDER
        'S'                                                                      	} ) //X3_PYME


    dbSelectArea("SX3")
    SX3->(dbSetOrder(2)) //X3_CAMPO

    For nI := 1 To Len(aSX3)
        
        If !Empty(aSX3[nI][1])
            
            SX3->(dbSetOrder(2)) //X3_CAMPO
            
            If !SX3->(dbSeek(aSX3[nI,3]))
                lAppend := .T. //Se nao existir, inclui o campo
            Else
                aSX3[nI,2] := SX3->X3_ORDEM
                lAppend := .F. //Se existir, altera o campo
            EndIf
            
            RecLock("SX3",lAppend)
            For nX := 1 To Len(aSX3[nI])
                If SX3->(FieldPos(aEstru[nX])) > 0
                    FieldPut(FieldPos(aEstru[nX]),aSX3[nI,nX])
                EndIf
            Next nX
            dbCommit()
            MsUnLock()
        EndIf
        
    Next nI

    //------------------------
    //Indice da tabela SLZ  
    //------------------------
    RecLock("SIX", .T.)
    SIX->INDICE     := "SLZ"
    SIX->ORDEM      := "1"
    SIX->CHAVE      := "LZ_FILIAL+LZ_COD"
    SIX->DESCRICAO  := "Codigo"
    SIX->PROPRI     := "S"
    SIX->SHOWPESQ   := "S"
    SIX->IX_VIRTUAL := "2"
    SIX->IX_VIRCUST := "3"
    SIX->(MsUnLock())

EndIf

//Alimenta a tabela SLZ, caso não tenha dados
DbSelectArea("SLZ")
SLZ->(DbSetOrder(1)) //LZ_FILIAL+LZ_COD
SLZ->(DbGoTop())
If SLZ->(EOF())
    RecLock("SLZ", .T.)
    SLZ->LZ_FILIAL  := xFilial("SLZ")
    SLZ->LZ_COD     := "1"
    SLZ->LZ_DESC    := "EPHARMA"
    SLZ->LZ_FUNCAO  := "LJCEPHARMA():EPHARMA()"
    SLZ->(MsUnLock())

    RecLock("SLZ", .T.)
    SLZ->LZ_FILIAL  := xFilial("SLZ")
    SLZ->LZ_COD     := "2"
    SLZ->LZ_DESC    := "TRNCENTRE"
    SLZ->LZ_FUNCAO  := "LJCTRNCENTRE():TRNCENTRE()"
    SLZ->(MsUnLock())
EndIf

Return