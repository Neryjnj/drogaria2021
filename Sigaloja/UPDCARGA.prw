#INCLUDE "PROTHEUS.CH"
#INCLUDE "UPDCARGA.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

Static lSM0Open := .F.

/*---------------------------------------------------------------------------
ฑฑบ Programa | UPDCARGA บ Autor | TOTVS Protheus     บ Data |  14/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de update dos dicionแrios para compatibiliza็ใo     |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | UPDCARGA   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
---------------------------------------------------------------------------*/
User Function UPDCARGA( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := STR0001 //"FACILITADOR PARA CAMPOS DA CARGA"     
Local   cDesc1    := STR0002 //"Este processo deve ser executado em modo EXCLUSIVO, ou seja nใo podem haver outros"
Local   cDesc2    := STR0003 //"usuแrios  ou  jobs utilizando  o sistema.  ษ extremamente recomendแvel  que  se  fa็a um"
Local   cDesc3    := STR0004 //"BACKUP  dos DICIONมRIOS  e da  BASE DE DADOS antes desta atualiza็ใo, para que caso "
Local   cDesc4    := STR0005 //"Confirma a atualiza็ใo dos dicionแrios ?"
Local   cDesc5    := STR0006 //"ocorra eventuais falhas, esse backup seja ser restaurado." #13
Local   lOk       := .F. 
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( STR0006, cTitulo ) //"Confirma a atualiza็ใo dos dicionแrios ?"
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, STR0007, STR0012, .F. ) //"Atualizando"###"Aguarde, atualizando ..."
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( STR0008, "UPDCARGA" ) //"Atualiza็ใo Realizada."
					dbCloseAll()
				Else
					MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
					dbCloseAll()
				EndIf
			Else
				If lOk
					Final( STR0009 ) //"Atualiza็ใo Concluํda."
				Else
					Final( STR0010 ) //"Atualiza็ใo nใo Realizada."
				EndIf
			EndIf

		Else
			MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
		EndIf

	Else
		MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
	EndIf

EndIf

Return NIL

/*---------------------------------------------------------------------------
ฑฑบ Programa | FSTProc  บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da grava็ใo dos arquivos           |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
---------------------------------------------------------------------------*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := STR0011 + "(*.TXT)|*.txt|" //"Arquivos Texto"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL   

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()
      
	While !SM0->( EOF() )  
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
		   	aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
	   	
		EndIf
		SM0->( dbSkip() )
	End
   
	SM0->( dbCloseArea() )

	If lOpen
		
		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( STR0013 + aRecnoSM0[nI][2] + STR0014 ) //"Atualiza็ใo da empresa "###" nใo efetuada."
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL ,,,"FRT" )
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0015 + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF //"Empresa : "

			oProcess:SetRegua1( 8 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//|Atualiza o dicionแrio SX2         |
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( STR0016 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de arquivos"
			FSAtuSX2( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//|Atualiza o dicionแrio SX3         |
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FSAtuSX3( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//|Atualiza o dicionแrio SIX         |
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( STR0017 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de ํndices"
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( STR0018 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de dados"
			oProcess:IncRegua2( STR0019 ) //"Atualizando campos/ํndices"

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If ExistFunc(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( STR0020 + aArqUpd[nX] + STR0021, STR0022 ) //"Ocorreu um erro desconhecido durante a atualiza็ใo da tabela : "###". Verifique a integridade do dicionแrio e da tabela."###"ATENวรO"
					cTexto += STR0023 + aArqUpd[nX] + CRLF //"Ocorreu um erro desconhecido durante a atualiza็ใo da estrutura da tabela : "
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//|Atualiza o dicionแrio SX6         |
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( STR0024 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de parโmetros"
			FSAtuSX6( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//|Atualiza os helps                 |
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( STR0025 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Helps de Campo"
			FSAtuHlp( @cTexto )

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += STR0026 + CRLF //"LOG DA ATUALIZACAO DOS DICIONมRIOS"
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += STR0027 + CRLF //" Dados Ambiente"
			cAux += " --------------------"  + CRLF
			cAux += STR0028 + cEmpAnt + "/" + cFilAnt  + CRLF //" Empresa / Filial...: "
			cAux += STR0029 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Empresa.......: "
			cAux += STR0030 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Filial........: "
			cAux += STR0031 + DtoC( dDataBase )  + CRLF //" DataBase...........: "
			cAux += STR0032 + DtoC( Date() )  + " / " + Time()  + CRLF //" Data / Hora Inicio.: "
			cAux += STR0033 + GetEnvServer()  + CRLF //" Environment........: "
			cAux += STR0034 + GetSrvProfString( "StartPath", "" )  + CRLF //" StartPath..........: "
			cAux += STR0035 + GetSrvProfString( "RootPath" , "" )  + CRLF //" RootPath...........: "
			cAux += STR0036 + GetVersao(.T.)  + CRLF //" Versao.............: "
			cAux += STR0037 + __cUserId + " " +  cUserName + CRLF //" Usuario TOTVS .....: "
			cAux += STR0038 + GetComputerName() + CRLF //" Computer Name......: "

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += STR0039 + CRLF //" Dados Thread"
				cAux += " --------------------"  + CRLF
				cAux += STR0040 + aInfo[nPos][1] + CRLF //" Usuario da Rede....: "
				cAux += STR0041 + aInfo[nPos][2] + CRLF //" Estacao............: "
				cAux += STR0042 + aInfo[nPos][5] + CRLF //" Programa Inicial...: "
				cAux += STR0033 + aInfo[nPos][6] + CRLF //" Environment........: "
				cAux += STR0043 + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF //" Conexao............: "
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0044 + DtoC( Date() ) + " / " + Time()  + CRLF //" Data / Hora Final.: "
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title STR0045 From 3, 0 to 340, 417 Pixel //"Atualizacao concluida."

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet

/*---------------------------------------------------------------------------
ฑฑบ Programa | FSAtuSX2 บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SX2 - Arquivos      |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAtuSX2   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
---------------------------------------------------------------------------*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
Local nPos		:= 0
Local lNovo		:= .F.
Local cArqSx2 	:= ""

cTexto  += STR0046 + " SX2" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODOEMP", "X2_MODOUN", "X2_MODULO"}

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cArqSx2	:= RetSX2Arq("SA1",.F.) //Retorna o NOME DO ARQUIVO
cPath 	:= RetSX2Arq("SA1",.T.) //Retorna o PATH + NOME DO ARQUIVO
cPath 	:= Left(cPath,Len(cPath)-Len(cArqSx2)) //Retira o NOME DO ARQUIVO para manter apenas o PATH
cEmpr	:= Substr( cArqSx2, 4 )

//
// Tabela MBU
//
aAdd( aSX2, { ;
	'MBU'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MBU'+cEmpr																, ; //X2_ARQUIVO
	'GRUPOS DE TABELAS DA CARGA'											, ; //X2_NOME
	'GRUPOS DE TABELAS DA CARGA'											, ; //X2_NOMESPA
	'GRUPOS DE TABELAS DA CARGA'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MBU_FILIAL+MBU_CODIGO'													, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MBV
//
aAdd( aSX2, { ;
	'MBV'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MBV'+cEmpr																, ; //X2_ARQUIVO
	'TABELAS DA CARGA'														, ; //X2_NOME
	'TABELAS DA CARGA'														, ; //X2_NOMESPA
	'TABELAS DA CARGA'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MBV_FILIAL+MBV_CODGRP+MBV_TABELA'											, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MBW
//
aAdd( aSX2, { ;
	'MBW'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MBW'+cEmpr																, ; //X2_ARQUIVO
	'REGISTROS DA CARGA DA TABELA'											, ; //X2_NOME
	'REGISTROS DA CARGA DA TABELA'											, ; //X2_NOMESPA
	'REGISTROS DA CARGA DA TABELA'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MBW_FILIAL+MBW_CODGRP+MBW_TABELA'											, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MBX
//
aAdd( aSX2, { ;
	'MBX'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MBX'+cEmpr																, ; //X2_ARQUIVO
	'FILIAIS DA CARGA DA TABELA'											, ; //X2_NOME
	'FILIAIS DA CARGA DA TABELA'											, ; //X2_NOMESPA
	'FILIAIS DA CARGA DA TABELA'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL'									, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MBY
//
aAdd( aSX2, { ;
	'MBY'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MBY'+cEmpr																, ; //X2_ARQUIVO
	'STATUS DA CARGA'														, ; //X2_NOME
	'STATUS DA CARGA'														, ; //X2_NOMESPA
	'STATUS DA CARGA'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MBY_FILIAL+MBY_CODGRP'													, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MD3
//
aAdd( aSX2, { ;
	'MD3'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MD3'+cEmpr																, ; //X2_ARQUIVO
	'Configura็ใo de Comunica็ใo'											, ; //X2_NOME
	'Configurac. de Comunicac.'												, ; //X2_NOMESPA
	'Communication Configuration'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'MD3_FILIAL+MD3_CODAMB+MD3_TIPO'											, ; //X2_UNICO
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela MD4
//
aAdd( aSX2, { ;
	'MD4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MD4'+cEmpr																, ; //X2_ARQUIVO
	'Ambientes Replica็ใo'													, ; //X2_NOME
	'Entornos Copia'														, ; //X2_NOMESPA
	'Repl.Environments'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'MD4_FILIAL+MD4_CODIGO'													, ; //X2_UNICO
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO
	
	
//
// Tabela MDF
//
aAdd( aSX2, { ;
	'MDF'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'MDF'+cEmpr																, ; //X2_ARQUIVO
	'Controle Ordem Carga'													, ; //X2_NOME
	'Controle Ordem Carga'														, ; //X2_NOMESPA
	'Controle Ordem Carga'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'MDF_FILIAL+MDF_ORDEM'														, ; //X2_UNICO
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( STR0047 ) //"Atualizando Arquivos (SX2)..."
	lNovo := !SX2->( dbSeek( aSX2[nI][1] ) ) 

	If lNovo .And. !( aSX2[nI][1] $ cAlias )
		cAlias += aSX2[nI][1] + "/"
		cTexto += STR0048 + aSX2[nI][1] + CRLF //"Foi incluํda a tabela "
	EndIf

	RecLock( "SX2", lNovo )
	For nJ := 1 To Len( aSX2[nI] )
		nPos := ColumnPos( aEstrut[nJ] )
		If nPos > 0
			If lNovo .And. AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
				FieldPut( nPos, SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
			Else
				If lNovo .Or. (!lNovo .And. (AllTrim( aEstrut[nJ] ) $ "X2_UNICO/X2_ROTINA"))
					FieldPut( nPos, aSX2[nI][nJ] )
				EndIf
			EndIf
		EndIf
	Next nJ
	dbCommit()
	MsUnLock()
	
	If !lNovo
		TcInternal( 60, aSX2[nI][1] + cEmpAnt + "0" + "|" + aSX2[nI][1] + cEmpAnt + "0" + "_UNQ" )
		cTexto += STR0049 + aSX2[nI][1] + CRLF //"Foi alterada chave unica da tabela "
	EndIf

Next nI

cTexto += CRLF + STR0051 + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL

/*---------------------------------------------------------------------------
ฑฑบ Programa | FSAtuSX3 บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SX3 - Campos        |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAtuSX3   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
---------------------------------------------------------------------------*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local aTabelasLJ:= {}
Local aTabTplDRO:= {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
Local nCountTabLJ := 0
Local nTamCmpSXG:= 0
Local cCodGrpSXG:= ""

cTexto  += STR0046 + " SX3" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }

//
// Tabela MBU
//
aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MBU_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MBU_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Grp Tab'															, ; //X3_TITULO
	'Cod. Grp Tab'															, ; //X3_TITSPA
	'Cod. Grp Tab'															, ; //X3_TITENG
	'Codigo do grp de tabela'												, ; //X3_DESCRIC
	'Codigo do grp de tabela'												, ; //X3_DESCSPA
	'Codigo do grp de tabela'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MBU_NOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Grupo'															, ; //X3_TITULO
	'Nome Grupo'															, ; //X3_TITSPA
	'Nome Grupo'															, ; //X3_TITENG
	'Nome do grupo'															, ; //X3_DESCRIC
	'Nome do grupo'															, ; //X3_DESCSPA
	'Nome do grupo'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MBU_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao do grupo'													, ; //X3_DESCRIC
	'Descricao do grupo'													, ; //X3_DESCSPA
	'Descricao do grupo'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MBU_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Tipo'																	, ; //X3_TITENG
	'Tipo do Grupo'															, ; //X3_DESCRIC
	'Tipo do Grupo'															, ; //X3_DESCSPA
	'Tipo do Grupo'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'MBU_CODTPL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Templ.'															, ; //X3_TITULO
	'Cod. Templ.'															, ; //X3_TITSPA
	'Cod. Templ.'															, ; //X3_TITENG
	'Cod.Template'															, ; //X3_DESCRIC
	'Cod.Template'															, ; //X3_DESCSPA
	'Cod.Template'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'MBU_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'MBU_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'MBU_ORDEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem'																	, ; //X3_TITULO
	'Ordem'																	, ; //X3_TITSPA
	'Ordem'																	, ; //X3_TITENG
	'Ordem da carga'														, ; //X3_DESCRIC
	'Ordem da carga'														, ; //X3_DESCSPA
	'Ordem da carga'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBU'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'MBU_INTINC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Int / Inc'																, ; //X3_TITULO
	'Int / Inc'																, ; //X3_TITSPA
	'Int / Inc'																, ; //X3_TITENG
	'Inteira / Incremental'													, ; //X3_DESCRIC
	'Inteira / Incremental'													, ; //X3_DESCSPA
	'Inteira / Incremental'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela MBV
//
aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MBV_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MBV_CODGRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo Grupo'															, ; //X3_TITULO
	'Codigo Grupo'															, ; //X3_TITSPA
	'Codigo Grupo'															, ; //X3_TITENG
	'Codigo do Grupo'														, ; //X3_DESCRIC
	'Codigo do Grupo'														, ; //X3_DESCSPA
	'Codigo do Grupo'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MBV_TABELA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tabela'																, ; //X3_TITULO
	'Tabela'																, ; //X3_TITSPA
	'Tabela'																, ; //X3_TITENG
	'Tabela'																, ; //X3_DESCRIC
	'Tabela'																, ; //X3_DESCSPA
	'Tabela'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MBV_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Transf.'															, ; //X3_TITULO
	'Tipo Transf.'															, ; //X3_TITSPA
	'Tipo Transf.'															, ; //X3_TITENG
	'Tipo da Transferencia'													, ; //X3_DESCRIC
	'Tipo da Transferencia'													, ; //X3_DESCSPA
	'Tipo da Transferencia'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'Vazio() .Or. Pertence("123")'											, ; //X3_VLDUSER
	'1=Transferencia completa;2=Transferencia parcial;3=Transferencia especial'	, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MBV_FILTRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filtro'																, ; //X3_TITULO
	'Filtro'																, ; //X3_TITSPA
	'Filtro'																, ; //X3_TITENG
	'Filtro Tabela'															, ; //X3_DESCRIC
	'Filtro Tabela'															, ; //X3_DESCSPA
	'Filtro Tabela'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBV'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'MBV_QTDREG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtde Reg'																, ; //X3_TITULO
	'Qtde Reg'																, ; //X3_TITSPA
	'Qtde Reg'																, ; //X3_TITENG
	'Qtde registros'														, ; //X3_DESCRIC
	'Qtde registros'														, ; //X3_DESCSPA
	'Qtde registros'														, ; //X3_DESCENG
	'@E 9,999,999,999'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela MBW
//
aAdd( aSX3, { ;
	'MBW'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MBW_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBW'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MBW_CODGRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Grupo'															, ; //X3_TITULO
	'Cod. Grupo'															, ; //X3_TITSPA
	'Cod. Grupo'															, ; //X3_TITENG
	'Codido Grupo de Tabelas'												, ; //X3_DESCRIC
	'Codido Grupo de Tabelas'												, ; //X3_DESCSPA
	'Codido Grupo de Tabelas'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBW'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MBW_TABELA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tabela'															, ; //X3_TITULO
	'Cod. Tabela'															, ; //X3_TITSPA
	'Cod. Tabela'															, ; //X3_TITENG
	'Codigo Tabela'															, ; //X3_DESCRIC
	'Codigo Tabela'															, ; //X3_DESCSPA
	'Codigo Tabela'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBW'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MBW_INDICE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Indice Tab.'															, ; //X3_TITULO
	'Indice Tab.'															, ; //X3_TITSPA
	'Indice Tab.'															, ; //X3_TITENG
	'Indice Tabela'															, ; //X3_DESCRIC
	'Indice Tabela'															, ; //X3_DESCSPA
	'Indice Tabela'															, ; //X3_DESCENG
	'9'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBW'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MBW_SEEK'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seek Tab.'																, ; //X3_TITULO
	'Seek Tab.'																, ; //X3_TITSPA
	'Seek Tab.'																, ; //X3_TITENG
	'Seek Tabela'															, ; //X3_DESCRIC
	'Seek Tabela'															, ; //X3_DESCSPA
	'Seek Tabela'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela MBX
//
aAdd( aSX3, { ;
	'MBX'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MBX_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBX'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MBX_CODGRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo Grupo'															, ; //X3_TITULO
	'Codigo Grupo'															, ; //X3_TITSPA
	'Codigo Grupo'															, ; //X3_TITENG
	'Codigo do Grupo Tabelas'												, ; //X3_DESCRIC
	'Codigo do Grupo Tabelas'												, ; //X3_DESCSPA
	'Codigo do Grupo Tabelas'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBX'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MBX_TABELA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tabela'															, ; //X3_TITULO
	'Cod. Tabela'															, ; //X3_TITSPA
	'Cod. Tabela'															, ; //X3_TITENG
	'Codigo da Tabela'														, ; //X3_DESCRIC
	'Codigo da Tabela'														, ; //X3_DESCSPA
	'Codigo da Tabela'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBX'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MBX_FIL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial Carga'															, ; //X3_TITULO
	'Filial Carga'															, ; //X3_TITSPA
	'Filial Carga'															, ; //X3_TITENG
	'Filial Carga'															, ; //X3_DESCRIC
	'Filial Carga'															, ; //X3_DESCSPA
	'Filial Carga'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBX'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MBX_QTDREG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtd Reg'																, ; //X3_TITULO
	'Qtd Reg'																, ; //X3_TITSPA
	'Qtd Reg'																, ; //X3_TITENG
	'Qtde Registros'														, ; //X3_DESCRIC
	'Qtde Registros'														, ; //X3_DESCSPA
	'Qtde Registros'														, ; //X3_DESCENG
	'@E 9,999,999,999'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela MBY
//
aAdd( aSX3, { ;
	'MBY'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MBY_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBY'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MBY_CODGRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Carga'															, ; //X3_TITULO
	'Cod. Carga'															, ; //X3_TITSPA
	'Cod. Carga'															, ; //X3_TITENG
	'Codigo da Carga'														, ; //X3_DESCRIC
	'Codigo da Carga'														, ; //X3_DESCSPA
	'Codigo da Carga'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBY'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MBY_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBY'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MBY_ORDEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem da Car'															, ; //X3_TITULO
	'Ordem da Car'															, ; //X3_TITSPA
	'Ordem da Car'															, ; //X3_TITENG
	'Ordem da Carga'														, ; //X3_DESCRIC
	'Ordem da Carga'														, ; //X3_DESCSPA
	'Ordem da Carga'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MBY'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MBY_INTINC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Int/ inc'																, ; //X3_TITULO
	'Int/ inc'																, ; //X3_TITSPA
	'Int/ inc'																, ; //X3_TITENG
	'tipo da carga'															, ; //X3_DESCRIC
	'tipo da carga'															, ; //X3_DESCSPA
	'tipo da carga'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela MD3
//
aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MD3_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MD3_CODAMB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Ambiente'															, ; //X3_TITULO
	'Cod.Entorno'															, ; //X3_TITSPA
	'Envir.Code'															, ; //X3_TITENG
	'Codigo Ambiente'														, ; //X3_DESCRIC
	'Codigo Entorno'														, ; //X3_DESCSPA
	'Environment Code'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'MD4'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MD3_IP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Endereco IP'															, ; //X3_TITULO
	'Direccion IP'															, ; //X3_TITSPA
	'IP Address'															, ; //X3_TITENG
	'Endereco IP'															, ; //X3_DESCRIC
	'Direccion IP'															, ; //X3_DESCSPA
	'IP Address'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MD3_PORTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Porta Comun.'															, ; //X3_TITULO
	'Puerto Comun'															, ; //X3_TITSPA
	'Comm Port'																, ; //X3_TITENG
	'Porta de Comunicacao'													, ; //X3_DESCRIC
	'Puerta de Comunicacion'												, ; //X3_DESCSPA
	'Communic.Port'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'MD3_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descripcion'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descricao'																, ; //X3_DESCRIC
	'Descripcion'															, ; //X3_DESCSPA
	'Description'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'MD3_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Comunic'															, ; //X3_TITULO
	'Tipo Comunic'															, ; //X3_TITSPA
	'Commun. Tp.'															, ; //X3_TITENG
	'Tipo Comunica็ใo'														, ; //X3_DESCRIC
	'Tipo Comunicacion'														, ; //X3_DESCSPA
	'Communication Type'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'I=Integra็ใo;E=Conexใo Especํfica;R=RPC'								, ; //X3_CBOX
	'I=Integra็ใo;E=Conexใo Especํfica;R=RPC'								, ; //X3_CBOXSPA
	'I=Integra็ใo;E=Conexใo Especํfica;R=RPC'								, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'MD3_NOMAMB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome amb.'																, ; //X3_TITULO
	'Nomb entor.'															, ; //X3_TITSPA
	'Envir.Name'															, ; //X3_TITENG
	'Nome do ambiente'														, ; //X3_DESCRIC
	'Nomb del entorno'														, ; //X3_DESCSPA
	'Environment Name'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(150) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'MD3_EMP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Empresa'																, ; //X3_TITULO
	'Empresa'																, ; //X3_TITSPA
	'Company'																, ; //X3_TITENG
	'Empresa'																, ; //X3_DESCRIC
	'Empresa'																, ; //X3_DESCSPA
	'Company'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(128) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD3'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'MD3_FIL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(128) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

//
// Tabela MD4
//
aAdd( aSX3, { ;
	'MD4'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MD4_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD4'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'MD4_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Ambiente'															, ; //X3_TITULO
	'Cod Entorno'															, ; //X3_TITSPA
	'Envir.Code'															, ; //X3_TITENG
	'Codigo Ambiente'														, ; //X3_DESCRIC
	'Codigo Entorno'														, ; //X3_DESCSPA
	'Environment Code'														, ; //X3_DESCENG
	''																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD4'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'MD4_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descripcion'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descricao'																, ; //X3_DESCRIC
	'Descripcion'															, ; //X3_DESCSPA
	'Description'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(132) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MD4'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MD4_AMBPAI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Amb. Pai'																, ; //X3_TITULO
	'Ent. Princ.'															, ; //X3_TITSPA
	'Parent Envir'															, ; //X3_TITENG
	'Ambiente pai'															, ; //X3_DESCRIC
	'Entorno Principal'														, ; //X3_DESCSPA
	'Parent Environment'													, ; //X3_DESCENG
	''																, ; //X3_PICTURE
	'Vazio() .Or. ExistCPO( "MD4", M->MD4_AMBPAI )'							, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'MD4'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(150) + Chr(128)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME



//
// Tabela MDF
//
aAdd( aSX3, { ;
	'MDF'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'MDF_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'MDF'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'MDF_ORDEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem da Car'															, ; //X3_TITULO
	'Ordem da Car'															, ; //X3_TITSPA
	'Ordem da Car'															, ; //X3_TITENG
	'Ordem da Carga'														, ; //X3_DESCRIC
	'Ordem da Carga'														, ; //X3_DESCSPA
	'Ordem da Carga'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
//Adiciona campos MSEXP e HREXP para as tabelas padroes do Loja
//
aTabelasLJ := {	"SB1", "SB0", "SLH", "SBZ", "SM2", "SA1", "SA3", "SA6", "SAE", "SAF",;
				"SBI", "SB2", "SE4", "SED", "SF4", "SF7", "SFB", "SFC", "SFE", "SFF",;
				"SFP", "SFH", "SFZ", "SLF", "SLG", "SLK", "SFM", "ACO", "ACP", "DA0",;
				"DA1", "ACQ", "ACR", "SL6", "SL8", "SLD", "SL7", "SUG", "SUH", "SU1",;
				"MDE", "MBS", "MBT", "MEN", "MEK", "MEI", "MEJ", "MB2", "MB3", "MB4",;
				"MB5", "MB6", "MB7", "MB8", "CLK", "MEU", "MEV", "CC2", "AI0", "MBF",;
				"MBL", "MG7", "MG8", "MGB", "MGC", "MHI", "SLZ" }

If ExistFunc("LjIsDro") .And. LjIsDro()
	aTabTplDRO :=	{"MHA", "MHB", "MHC", "MHD", "MHE", "MHF", "MHG",; 
					"LIP", "LK9", "LEO", "LFX", "LHU", "LJU", "LJG",;
					"LHV", "LIO", "LJ2", "LHH", "LHG", "LKA", "LKB",;
					"LKD", "LFW", "LHF"}
	
	For nI := 1 to Len(aTabTplDRO)
        Aadd(aTabelasLJ,aTabTplDRO[nI])
    Next nI

	ConOut("Tabelas do Template de Drogaria terใo campos incluidos para a carga")
EndIf

For nCountTabLJ := 1 to Len(aTabelasLJ)
	FSAddMSEXP(@aSX3, aTabelasLJ[nCountTabLJ]) //adiciona campo MSEXP na tabela
	FSAddHREXP(@aSX3, aTabelasLJ[nCountTabLJ]) //adiciona campo HREXP na tabela
Next nCountTabLJ

//
// Atualizando dicionแrio
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			nTamCmpSXG := TamSXG(aSX3[nI][nPosSXG])[1]
			If aSX3[nI][nPosTam] <> nTamCmpSXG
				aSX3[nI][nPosTam] := nTamCmpSXG
				cTexto += STR0053 + aSX3[nI][nPosCpo] + STR0054 //"O tamanho do campo "###" nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( nTamCmpSXG ) ) + "]" + CRLF
				cTexto += STR0055 + SX3->X3_GRPSXG + "]" + CRLF + CRLF //"   por pertencer ao grupo de campos ["
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += STR0056 + aSX3[nI][nPosCpo] + CRLF //"Criado o campo "

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		cCodGrpSXG := SX3->X3_GRPSXG
		If !Empty( cCodGrpSXG ) .AND. cCodGrpSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( cCodGrpSXG ) )
				nTamCmpSXG := TamSXG(cCodGrpSXG)[1]
				If aSX3[nI][nPosTam] <> nTamCmpSXG
					aSX3[nI][nPosTam] := nTamCmpSXG
					cTexto +=  STR0053 + aSX3[nI][nPosCpo] + STR0054 //"O tamanho do campo "###" nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( nTamCmpSXG ) ) + "]"+ CRLF
					cTexto +=  STR0055 + cCodGrpSXG + "]" + CRLF + CRLF //"   por pertencer ao grupo de campos ["
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				cMsg := STR0058 + aSX3[nI][nPosCpo] + STR0059 + SX3->( FieldName( nJ ) ) + ; //"O campo "###" estแ com o "
				STR0060 + CRLF + ; //" com o conte๚do"
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
				STR0061 + CRLF + ; //"que serแ substituido pelo NOVO conte๚do"
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + ;
				STR0062 //"Deseja substituir ? "

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else//																									
					nOpcA := Aviso( STR0001, cMsg, { STR0063, STR0064, STR0065, STR0066 }, 3, STR0067 ) //"FACILITADOR PARA CAMPOS DA CARGA"  ###"Sim"###"Nใo"###"Sim p/Todos"###"Nใo p/Todos"###"Diferen็a de conte๚do - SX3"
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( STR0068 + CRLF + STR0069 ) //"Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SX3 e NรO MOSTRAR mais a tela de aviso."###"Confirma a a็ใo [Sim p/Todos] ?"
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( STR0070 + CRLF + STR0071 ) //"Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SX3 que esteja diferente da base e NรO MOSTRAR mais a tela de aviso."###"Confirma esta a็ใo [Nใo p/Todos]?"
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += STR0072 + aSX3[nI][nPosCpo] + CRLF //"Alterado o campo "
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + STR0073 + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF //" de ["
					cTexto += STR0074 + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF //"            para ["

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( STR0075 ) //"Atualizando Campos de Tabelas (SX3)..."

Next nI

cTexto += CRLF + STR0051 + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa | FSAtuSIX บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SIX - Indices       |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAtuSIX   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += STR0046 + " SIX" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela MBU
//
aAdd( aSIX, { ;
	'MBU'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MBU_FILIAL+MBU_CODIGO'													, ; //CHAVE
	'Cod. Grp Tab'															, ; //DESCRICAO
	'Cod. Grp Tab'															, ; //DESCSPA
	'Cod. Grp Tab'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'MBU'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'MBU_FILIAL+MBU_TIPO'													, ; //CHAVE
	'Tipo (Template ou Carga)'												, ; //DESCRICAO
	'Tipo (Template ou Carga)'												, ; //DESCSPA
	'Tipo (Template ou Carga)'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MBV
//
aAdd( aSIX, { ;
	'MBV'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MBV_FILIAL+MBV_CODGRP+MBV_TABELA'										, ; //CHAVE
	'Codigo Grupo+Tabela'													, ; //DESCRICAO
	'Codigo Grupo+Tabela'													, ; //DESCSPA
	'Codigo Grupo+Tabela'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MBW
//
aAdd( aSIX, { ;
	'MBW'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MBW_FILIAL+MBW_CODGRP+MBW_TABELA'										, ; //CHAVE
	'Cod. Grupo+Cod. Tabela'												, ; //DESCRICAO
	'Cod. Grupo+Cod. Tabela'												, ; //DESCSPA
	'Cod. Grupo+Cod. Tabela'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MBX
//
aAdd( aSIX, { ;
	'MBX'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL'									, ; //CHAVE
	'Codigo Grupo+Cod. Tabela + Filial'												, ; //DESCRICAO
	'Codigo Grupo+Cod. Tabela + Filial'												, ; //DESCSPA
	'Codigo Grupo+Cod. Tabela + Filial'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MBY
//
aAdd( aSIX, { ;
	'MBY'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MBY_FILIAL+MBY_CODGRP'													, ; //CHAVE
	'Filial + GrupoCarga'													, ; //DESCRICAO
	'Filial + GrupoCarga'													, ; //DESCSPA
	'Filial + GrupoCarga'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'MBY'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'MBY_FILIAL+MBY_INTINC+MBY_ORDEM+MBY_CODGRP'							, ; //CHAVE
	'Filial +int/inc + ordem + carga'										, ; //DESCRICAO
	'Filial +int/inc + ordem + carga'										, ; //DESCSPA
	'Filial +int/inc + ordem + carga'										, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MD3
//
aAdd( aSIX, { ;
	'MD3'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MD3_FILIAL+MD3_CODAMB+MD3_TIPO'										, ; //CHAVE
	'Cod.Ambiente + Tipo Comunic'											, ; //DESCRICAO
	'Cod.Entorno + Tipo Comunic'											, ; //DESCSPA
	'Envir.Code + Commun. Tp.'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela MD4
//
aAdd( aSIX, { ;
	'MD4'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MD4_FILIAL+MD4_CODIGO'													, ; //CHAVE
	'Cod.Ambiente'															, ; //DESCRICAO
	'Cod Entorno'															, ; //DESCSPA
	'Envir.Code'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ



//
// Tabela MDF
//
aAdd( aSIX, { ;
	'MDF'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MDF_FILIAL+MDF_ORDEM'													, ; //CHAVE
	'Filial + Ordem'													, ; //DESCRICAO
	'Filial + Ordem'													, ; //DESCSPA
	'Filial + Ordem'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( "SIX", .T. )
		lDelInd := .F.
		cTexto += STR0076 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF //"อndice criado "
	Else
		lAlt := .F.
		RecLock( "SIX", .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T. // Se for alteracao precisa apagar o indice do banco
			cTexto += STR0077 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF //"อndice alterado "
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, aSIX[nI][1] + cEmpAnt + "0" + "|" + aSIX[nI][1] + cEmpAnt + "0" + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( STR0078 ) //"Atualizando ํndices..."

Next nI

cTexto += CRLF + STR0051 + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa | FSAtuSX6 บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SX6 - Parโmetros    |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAtuSX6   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += STR0046 + " SX6" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJAMBIE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Determina o c๓digo de cada ambiente, nใo pode se'						, ; //X6_DESCRIC
	'Determina el codigo de cada entorno, no puede'							, ; //X6_DSCSPA
	'Determine if each environment code is not the'							, ; //X6_DSCENG
	'repetir para a mesma empresa e mesma filial.'							, ; //X6_DESC1
	'repetirse para la misma empresa y misma sucursal.'						, ; //X6_DSCSPA1
	'same company and branch.'												, ; //X6_DSCENG1
	'001 a 999'																, ; //X6_DESC2
	'001 a 999'																, ; //X6_DSCSPA2
	'from 001 to 999'														, ; //X6_DSCENG2
	''																	, ; //X6_CONTEUD
	''																	, ; //X6_CONTSPA
	''																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILAUT'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Determina se o carregamento de cargas express ira'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'iniciar automaticamente'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILJLO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se utilizarแ sistema de travas'										, ; //X6_DESCRIC
	'Se utilizarแ sistema de travas'										, ; //X6_DSCSPA
	'Se utilizarแ sistema de travas'										, ; //X6_DSCENG
	'nos Jobs FRTA020, LOJA1115 e'											, ; //X6_DESC1
	'nos Jobs FRTA020, LOJA1115 e'											, ; //X6_DSCSPA1
	'nos Jobs FRTA020, LOJA1115 e'											, ; //X6_DSCENG1
	'LJGrvBatch. (0=Nใo, 1=Sim)'											, ; //X6_DESC2
	'LJGrvBatch. (0=Nใo, 1=Sim)'											, ; //X6_DSCSPA2
	'LJGrvBatch. (0=Nใo, 1=Sim)'											, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLAC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se replicarแ as a็๕es nos dependentes.'								, ; //X6_DESCRIC
	'Se replicarแ as a็๕es nos dependentes.'								, ; //X6_DSCSPA
	'Se replicarแ as a็๕es nos dependentes.'								, ; //X6_DSCENG
	'(0=Nใo, 1=Sim)'														, ; //X6_DESC1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCSPA1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLBR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial utilizada no assistente de importa็ใo e'						, ; //X6_DESCRIC
	'Sucursal utilizada en el asistente de importacion'						, ; //X6_DSCSPA
	'Branch used in the wizard of import and'								, ; //X6_DSCENG
	'carga de dados.'														, ; //X6_DESC1
	'carga de datos.'														, ; //X6_DSCSPA1
	'data load.'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLCO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Empresa utilizada no assistente de importa็ใo e'						, ; //X6_DESCRIC
	'Empresa utilizada en el asistente de importacion y'					, ; //X6_DSCSPA
	'Company used in the wizard of import and'								, ; //X6_DSCENG
	'carga de dados.'														, ; //X6_DESC1
	'carga de datos.'														, ; //X6_DSCSPA1
	'data load.'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLDO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se farแ a baixa dos dados.'											, ; //X6_DESCRIC
	'Se farแ a baixa dos dados.'											, ; //X6_DSCSPA
	'Se farแ a baixa dos dados.'											, ; //X6_DSCENG
	'(0=Nใo, 1=Sim)'														, ; //X6_DESC1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCSPA1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do ambiente utilizado no assistente de'							, ; //X6_DESCRIC
	'Nombre del entorno utilizado en el asistente'							, ; //X6_DSCSPA
	'Name of environment used in the wizard of import'						, ; //X6_DSCENG
	'importa็ใo e carga de dados.'											, ; //X6_DESC1
	'importacion y carga de datos.'											, ; //X6_DSCSPA1
	'and data load.'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLIM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se fara a importacao dos dados. (0=Nao, 1=Sim)'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLIP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'IP utilizado no assistente de importacao e carga'						, ; //X6_DESCRIC
	'IP utilizado en el asistente de import y carga'						, ; //X6_DSCSPA
	'IP used in the wizard of import and'									, ; //X6_DSCENG
	'de dados.'																, ; //X6_DESC1
	'de datos.'																, ; //X6_DSCSPA1
	'data load.'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLKT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se derrubarแ os outros processos .'									, ; //X6_DESCRIC
	'Se derrubarแ os outros processos .'									, ; //X6_DSCSPA
	'Se derrubarแ os outros processos .'									, ; //X6_DSCENG
	'(0=Nใo, 1=Sim)'														, ; //X6_DESC1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCSPA1
	'(0=Nใo, 1=Sim)'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILLPO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Porta utilizada no assistente de importa็ใo'							, ; //X6_DESCRIC
	'Puerto utilizado en el asistente de importacion'						, ; //X6_DSCSPA
	'Port used in wizard of import and'										, ; //X6_DSCENG
	'e carga de dados.'														, ; //X6_DESC1
	'y carga de datos.'														, ; //X6_DSCSPA1
	'data load.'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILOLE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se abre ou nใo o assist๊nte de carregamento de car'					, ; //X6_DESCRIC
	'Se abre ou nใo o assist๊nte de carregamento de car'					, ; //X6_DSCSPA
	'Se abre ou nใo o assist๊nte de carregamento de car'					, ; //X6_DSCENG
	'na inicializa็ใo dos m๓dulos Front-Loja e Venda As'					, ; //X6_DESC1
	'na inicializa็ใo dos m๓dulos Front-Loja e Venda As'					, ; //X6_DSCSPA1
	'na inicializa็ใo dos m๓dulos Front-Loja e Venda As'					, ; //X6_DSCENG1
	'quando houver uma carga mais atual. (0=Nใo, 1=Sim)'					, ; //X6_DESC2
	'quando houver uma carga mais atual. (0=Nใo, 1=Sim)'					, ; //X6_DSCSPA2
	'quando houver uma carga mais atual. (0=Nใo, 1=Sim)'					, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILQTD'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Qtde limite de cargas incrementais ativas. Para ev'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'itar estouro de 1 MB no xml com a lista de cargas'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'transferido entre os ambientes'										, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'200'																	, ; //X6_CONTEUD
	'200'																	, ; //X6_CONTSPA
	'200'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILTPA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Caminho temporario onde sera armazenado os'							, ; //X6_DESCRIC
	'Camino temporal donde se almacenaran los'								, ; //X6_DSCSPA
	'Temporary path where load files'										, ; //X6_DSCENG
	'arquivos da carga.'													, ; //X6_DESC1
	'archivos de la carga.'													, ; //X6_DSCSPA1
	'will be stored.'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\Temp\'																, ; //X6_CONTEUD
	'\Temp\'																, ; //X6_CONTSPA
	'\Temp\'																, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILVLO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Se utilizarแ sistema de travas'										, ; //X6_DESCRIC
	'Se utilizarแ sistema de travas'										, ; //X6_DSCSPA
	'Se utilizarแ sistema de travas'										, ; //X6_DSCENG
	'na venda. (S๓ utilizar em sistema'										, ; //X6_DESC1
	'na venda. (S๓ utilizar em sistema'										, ; //X6_DSCSPA1
	'na venda. (S๓ utilizar em sistema'										, ; //X6_DSCENG1
	'de venda Stand-Alone) (0=Nใo, 1=Sim)'									, ; //X6_DESC2
	'de venda Stand-Alone) (0=Nใo, 1=Sim)'									, ; //X6_DSCSPA2
	'de venda Stand-Alone) (0=Nใo, 1=Sim)'									, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJGECSV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de arquivos de geracao de carga:0 -DBF/CTREE'										, ; //X6_DESCRIC
	'Tipos de archivos de generaci๓n de carga:0 -DBF'										, ; //X6_DSCSPA
	'generation files load type:0 -DBF/CTREE'										, ; //X6_DSCENG
	',1 - DBF/CTREE e CSV, 2 - CSV'										, ; //X6_DESC1
	'/CTREE, 1 - DBF/CTREE e CSV, 2 - CSV'										, ; //X6_DSCSPA1
	',1 - DBF/CTREE e CSV, 2 - CSV'										, ; //X6_DSCENG1
	''									, ; //X6_DESC2
	''									, ; //X6_DSCSPA2
	''									, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'0'																		, ; //X6_CONTSPA
	'0'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJILDRV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	STR0103																, ; //X6_DESCRIC //'Define o driver para gera็ใo da carga'
	STR0103																, ; //X6_DSCSPA
	STR0103																, ; //X6_DSCENG
	STR0104																, ; //X6_DESC1   //'caso nao informado assume a configura็ใo do sistema'	
	STR0104																, ; //X6_DSCSPA1
	STR0104		  														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += STR0079 + aSX6[nI][1] + aSX6[nI][2] + STR0080 + AllTrim( aSX6[nI][13] ) + "]"+ CRLF //"Foi incluํdo o parโmetro "###" Conte๚do ["
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( STR0081 ) //"Atualizando Arquivos (SX6)..."

Next nI

cTexto += CRLF + STR0051 + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa | FSAtuHlp บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao dos Helps de Campos    |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAtuHlp   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function FSAtuHlp( cTexto )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

cTexto  += STR0046 + " " + STR0082 + CRLF + CRLF //"Inicio da Atualizacao"###"Helps de Campos"


oProcess:IncRegua2( STR0083 ) //"Atualizando Helps de Campos ..."

//
// Helps Tabela MBU
//

aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_FILIAL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_FILIAL  " + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'C๓digo do grupo de tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_CODIGO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_CODIGO  " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Descricao do grupo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_DESCRI  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_DESCRI  " + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Tipo do grupo: 1 - Template / 2 - Carga' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_TIPO  " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'C๓digo do template que originou a carga' )
aAdd( aHlpPor, '(apenas quando o grupo de tabelas for do' )
aAdd( aHlpPor, 'tipo 2 - Carga)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_CODTPL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_CODTPL" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Data da gera็ใo da carga' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_DATA  " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Hora da gera็ใo da carga' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_HORA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_HORA  " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Ordem da carga. Sequ๊ncia utilizada' )
aAdd( aHlpPor, 'pelas cargas incrementais para garantir' )
aAdd( aHlpPor, 'a integridade nas atualiza็๕es de cargas' )
aAdd( aHlpPor, 'no ambiente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_ORDEM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_ORDEM " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Determina se a carga ้ inteira ou' )
aAdd( aHlpPor, 'incremental (1 = carga inteira, 2 =' )
aAdd( aHlpPor, 'carga incremental)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBU_INTINC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBU_INTINC" + CRLF //"Atualizado o Help do campo "

//
// Helps Tabela MBV
//

aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Grupo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_CODGRP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_CODGRP" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_TABELA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_TABELA" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Tipo da Transferencia. 1=Transferencia' )
aAdd( aHlpPor, ' completa; 2=Transferencia parcial; ')
aAdd( aHlpPor, ' 3=Transferencia especial' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_TIPO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_TIPO" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Filtro Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_FILTRO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_FILTRO" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de registros exportados' )
aAdd( aHlpPor, 'quando a tabela for do tipo parcial' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBV_QTDREG", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBV_QTDREG" + CRLF //"Atualizado o Help do campo "

//
// Helps Tabela MBW
//


aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBW_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBW_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Codigo Grupo de Tabelas' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBW_CODGRP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBW_CODGRP" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Codigo Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBW_TABELA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBW_TABELA" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Indice Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBW_INDICE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBW_INDICE" + CRLF //"Atualizado o Help do campo "



aHlpPor := {}
aAdd( aHlpPor, 'Seek Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBW_SEEK", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBW_SEEK" + CRLF //"Atualizado o Help do campo "


//
// Helps Tabela MBX
//

aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBX_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBX_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Grupo Tabelas' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBX_CODGRP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBX_CODGRP" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Tabela' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBX_TABELA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBX_TABELA" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Filial Carga' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBX_FIL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBX_FIL" + CRLF //"Atualizado o Help do campo "



aHlpPor := {}
aAdd( aHlpPor, 'Qtde de registros exportados' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBX_QTDREG", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBX_QTDREG" + CRLF //"Atualizado o Help do campo "

//
// Helps Tabela MBY
//

aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBY_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBY_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'C๓digo da carga' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBY_CODGRP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBY_CODGRP" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Status da carga no ambiente. 1 = baixada' )
aAdd( aHlpPor, '/ 2 = importada / Em branco = pendente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBY_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBY_STATUS" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Ordem da Carga. Sequ๊ncia utilizada nas' )
aAdd( aHlpPor, 'cargas incrementais para manter a' )
aAdd( aHlpPor, 'integridade das atualiza็๕es' )
aAdd( aHlpPor, 'incrementais.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBY_ORDEM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBY_ORDEM " + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Determina se a carga ้ inteira ou' )
aAdd( aHlpPor, 'incremental (1 = carga inteira, 2 =' )
aAdd( aHlpPor, 'carga incremental)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PMBY_INTINC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MBY_INTINC" + CRLF //"Atualizado o Help do campo "

//
// Helps Tabela MD3
//

aHlpPor := {}
aAdd( aHlpPor, 'Filial do sistema' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_FILIAL" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Nome do ambiente destino' )
aAdd( aHlpPor, ' na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_CODAMB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_CODAMB" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'IP  do ambiente destino' )
aAdd( aHlpPor, ' na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_IP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_IP" + CRLF //"Atualizado o Help do campo "

aHlpPor := {}
aAdd( aHlpPor, 'Porta  do ambiente destino' )
aAdd( aHlpPor, ' na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_PORTA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_PORTA" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Descri็ใo  do ambiente.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_CODAMB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_CODAMB" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Descri็ใo  do ambiente.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_DESCRI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_DESCRI" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Tipo de comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_TIPO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_TIPO" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Nome do ambiente destino na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_NOMAMB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_NOMAMB" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'C๓digo da empresa do ambiente destino' )
aAdd( aHlpPor, ' na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_EMP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_EMP" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'C๓digo da filial do ambiente destino' )
aAdd( aHlpPor, ' na comunica็ใo.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD3_FIL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD3_FIL" + CRLF //"Atualizado o Help do campo "



//
// Helps Tabela MD4
//


aHlpPor := {}
aAdd( aHlpPor, 'Filial do sistema' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD4_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD4_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'C๓digo do ambiente' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD4_CODIGO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD4_CODIGO" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Descri็ใo do ambiente' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD4_DESCRI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD4_DESCRI" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Ambiente que este ambiente depende.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMD4_AMBPAI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MD4_AMBPAI" + CRLF //"Atualizado o Help do campo "



//
// Helps Tabela MDF
//


aHlpPor := {}
aAdd( aHlpPor, 'Filial do sistema' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMDF_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MDF_FILIAL" + CRLF //"Atualizado o Help do campo "


aHlpPor := {}
aAdd( aHlpPor, 'Ordem de gera็ใo da carga.' )
HlpEng := {}
aHlpSpa := {}
PutHelp( "PMDF_ORDEM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += STR0084 + "MDF_ORDEM" + CRLF //"Atualizado o Help do campo "
cTexto += CRLF + STR0085 + " " + STR0082 + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"###"Helps de Campos"

Return {}

/*---------------------------------------------------------------------------
ฑฑบRotina    |ESCEMPRESAบAutor  | Ernani Forastieri  บ Data |  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao Generica para escolha de Empresa, montado pelo SM0_ บฑฑ
ฑฑบ          | Retorna vetor contendo as selecoes feitas.                 บฑฑ
ฑฑบ          | Se nao For marcada nenhuma o vetor volta vazio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
---------------------------------------------------------------------------*/
Static Function EscEmpresa()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Parametro  nTipo                           |
//| 1  - Monta com Todas Empresas/Filiais      |
//| 2  - Monta so com Empresas                 |
//| 3  - Monta so com Filiais de uma Empresa   |
//|                                            |
//| Parametro  aMarcadas                       |
//| Vetor com Empresas/Filiais pre marcadas    |
//|                                            |
//| Parametro  cEmpSel                         |
//| Empresa que sera usada para montar selecao |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"
Local   aMarcadas  := {}  
         
If !MyOpenSm0(.F.)
	Return aRet
EndIf

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := STR0086 //"Tela para M๚ltiplas Sele็๕es de Empresas/Filiais"

oDlg:cTitle   := STR0087 //"Selecione a(s) Empresa(s) para Atualiza็ใo"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", STR0088 Size 178, 095 Of oDlg Pixel //"Empresa"
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt STR0089   Message  Size 40, 007 Pixel Of oDlg; //"Todos"###"Marca / Desmarca Todos" // STR0090
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt STR0091  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Inverter"
Message STR0092 Of oDlg //"Inverter Sele็ใo"

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt STR0088 Size  40, 08 Of oDlg Pixel //"Empresa"
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message STR0093  Of oDlg //"Mแscara Empresa ( ?? )"
@ 123, 50 Button oButMarc Prompt STR0094    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Marcar"
Message STR0095    Of oDlg //"Marcar usando mแscara ( ?? )"
@ 123, 80 Button oButDMar Prompt STR0102 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Desmarcar"
Message STR0096 Of oDlg //"Desmarcar usando mแscara ( ?? )"

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop STR0097  Enable Of oDlg //"Confirma a Sele็ใo"
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop STR0098 Enable Of oDlg //"Abandona a Sele็ใo"
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    |MARCATODOSบAutor  | Ernani Forastieri  บ Data |  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao Auxiliar para marcar/desmarcar todos os itens do    บฑฑ
ฑฑบ          | ListBox ativo                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    |INVSELECAOบAutor  | Ernani Forastieri  บ Data |  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao Auxiliar para inverter selecao do ListBox Ativo     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    |RETSELECAOบAutor  | Ernani Forastieri  บ Data |  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao Auxiliar que monta o retorno com as selecoes        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    | MARCAMAS บAutor  | Ernani Forastieri  บ Data |  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao para marcar/desmarcar usando mascaras               บฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL

/*---------------------------------------------------------------------------
ฑฑบRotina    | VERTODOS บAutor  | Ernani Forastieri  บ Data |  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao | Funcao auxiliar para verificar se estao todos marcardos    บฑฑ
ฑฑบ          | ou nao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Generico                                                   บฑฑ
---------------------------------------------------------------------------*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL

/*---------------------------------------------------------------------------
ฑฑบ Programa | MyOpenSM0บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento abertura do SM0 modo exclusivo     |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       |ฑฑ
---------------------------------------------------------------------------*/
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

OpenSM0()

If !lSM0Open
	dbSelectArea( "SM0" )
    SM0->(dbGoTop())
    RpcSetType( 3 )
    RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL ,,, "FRT") //Uso essa fun็ใo para setar o cEmpAnt/cFilAnt
    lSM0Open := .T.
EndIf

For nLoop := 1 To 20
	dbSelectArea( "SM0" )
	If !Empty( Select( "SM0" ) ) .And. SoftLock("SM0")
		MsUnLockAll()
		lOpen := .T.
		Exit
	EndIf

	Sleep( 500 )
Next nLoop

If !lOpen
	MsgStop( STR0099 + ; //"Nใo foi possํvel a abertura da tabela "
	IIf( lShared, STR0100, STR0101 ), STR0022 ) //"de empresas (SM0)."###"de empresas (SM0) de forma exclusiva."###"ATENวรO"
EndIf

Return lOpen

/*---------------------------------------------------------------------------
ฑฑบPrograma| FSAddMSEXP บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SX2 - Arquivos      |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAddMSEXP   -      										  |ฑฑ
---------------------------------------------------------------------------*/
Static Function FSAddMSEXP( aSX3, cAlias )
Local cPrefixo := If(SubStr(cAlias,1,1) == "S", SubStr(cAlias,2,3), cAlias)

aAdd( aSX3, { ;
	cAlias																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	cPrefixo + '_MSEXP'														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ident.Exp.'															, ; //X3_TITULO
	'Ident.Exp.'															, ; //X3_TITSPA
	'Ident.Exp.'															, ; //X3_TITENG
	'Ident.Exp.Dados'														, ; //X3_DESCRIC
	'Ident.Exp.Dados'														, ; //X3_DESCSPA
	'Ident.Exp.Dados'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	
Return



/*
-----------------------------------------------------------------------------
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa | FSAddHREXP บ Autor | TOTVS Protheus     บ Data |  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao| Funcao de processamento da gravacao do SX2 - Arquivos      |ฑฑ
ฑฑบ          |                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ| Uso      | FSAddHREXP   -      |ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
-----------------------------------------------------------------------------
*/
Static Function FSAddHREXP( aSX3, cAlias )

Local cPrefixo := If(SubStr(cAlias,1,1) == "S", SubStr(cAlias,2,3), cAlias)

ConOut("Alias atual : " + cAlias)

aAdd( aSX3, { ;
	cAlias																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	cPrefixo + '_HREXP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Exp'																, ; //X3_TITULO
	'Hora Exp'																, ; //X3_TITSPA
	'Hora Exp'																, ; //X3_TITENG
	'Hora da Exportacao'													, ; //X3_DESCRIC
	'Hora da Exportacao'													, ; //X3_DESCSPA
	'Hora da Exportacao'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

Return

/////////////////////////////////////////////////////////////////////////////

