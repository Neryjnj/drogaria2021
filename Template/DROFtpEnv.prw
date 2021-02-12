
#Define CTRL Chr(13)+Chr(10)
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDROFtpEnv บAutor  ณGeronimo B. Alves   บ Data ณ  14/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe parametros do Ftp e do arquivoo estabelece a conexaoบฑฑ
ฑฑบ          ณ e envia o arquivo        	                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DROFtpEnv(_cServ,_nPort,_cUser,_cPass,_cDirOri,_cArqOri,_cDirDst,_cArqDst,_cEmlDst,_cEmlTit,_cEmlArq, _cQuote)
Local cQuote		:= If(_cQuote <> Nil, _cQuote, '')
Local _nArq			:= 0
Local _nContUpload	:= 0
Local _nArqErr		:= 0
Local _lOkUpLoad	:= .F.

Private cDirStart	:= GetSrvProfString("STARTPATH","")      //Path onde serah gravado o arquivo de envio
Private cArqLogEnv	:= cDirStart+"PcEnvioEDI.log"  //Grava o arquivo de log de erro no diretorio cStartPath
Private lOk := .T.

IF EMPTY(_cServ)
	RETURN .F.
ENDIF

IF EMPTY(_cEmlTit)
	_cEmlTit := ""
ENDIF

IF VALTYPE(_cArqOri) == "C"
	_aArqOri := {_cArqOri}
ELSE
	_aArqOri := _cArqOri
ENDIF

_aArqErr := {}
FOR _nArq := 1 TO LEN(_aArqOri)
	_cArqOri := _aArqOri[_nArq]
	IF !FILE(_cArqOri) .and. !FILE(_cDirOri+_cArqOri)
		AADD(_aArqErr,"Falha no Arquivo Origem "+_cArqOri)
	ENDIF
NEXT _nArq
IF LEN(_aArqErr) > 0
	_cMsgErr := _cEmlTit + " - Falha Envio FTP - Arq Origem"
	T_EDIGrvLog(_cMsgErr, cArqLogEnv)	
	T_EnviaMail(cDirStart ,;
	_cEmlArq,;
	_cEmlDst,;
	_cMsgErr,;
	_aArqErr)
	lOk := .f.
ELSE
	FTPDISCONNECT()
	_lFtpConect := .t.
	MsgRun("Aguarde. Conectando com servidor ftp p/ envio do EDI " ,,{|| _lFtpConect := FTPCONNECT(_cServ,_nPort,_cUser,_cPass)  })
	if ! _lFtpConect
		_cMsgErr := _cEmlTit + " - Falha Envio FTP - Conexใo Servidor"
		T_EDIGrvLog(_cMsgErr, cArqLogEnv)	
		T_EnviaMail(cDirStart,;
		_cEmlArq,;
		_cEmlDst,;
		_cMsgErr,;
		{_cMsgErr,+;
		"Server FTP: "+_cServ,;
		"Porta     : "+STRZERO(_nPort,4),;
		"Usuแrio   : "+_cUser,;
		"Senha     : Verificar parโmetro Microsiga"})
		lOk := .f.
	ELSE
		IF (If (!Empty(_cDirDst),!FTPDIRCHANGE(_cDirDst),.f.))
			_cMsgErr := _cEmlTit + " - Falha Envio FTP - Caminho Destino"
			T_EDIGrvLog(_cMsgErr, cArqLogEnv)	
			T_EnviaMail(cDirStart,;
			_cEmlArq,;
			_cEmlDst,;
			_cMsgErr,;
			{_cMsgErr,;
			"Server FTP: "+_cServ,;
			"Porta     : "+STRZERO(_nPort,4),;
			"Usuแrio   : "+_cUser,;
			"Senha     : Verificar parโmetro Microsiga",;
			"Caminho   : "+_cDirDst})
			lOk := .f.
		ELSE
			_cArqParam := _cArqDst
			FOR _nArq := 1 TO LEN(_aArqOri)
				_cArqOri := _aArqOri[_nArq]
				IF EMPTY(_cArqParam)
					_cArqDst := _cArqOri
				ELSE
					_cArqDst := _cArqParam
				ENDIF
				_lOkUpLoad := .F.
				
				//Executa o comando quote em ftpดs para mainframes
				//Giorgi - 08/09/04
				If !Empty(cQuote)
					FtpQuote(cQuote)
				EndIf
				
				FOR _nContUpload := 1 to 10
					MsgRun("Aguarde. Tentativa  ("+ALLTRIM(STR(_nContUpload))+") FtpUpload do arq "+_cArqDst,,{||_lOkUpLoad := FTPUPLOAD(_cDirOri +_cArqOri , _cArqDst) })
					//_lOkUpload := FTPUPLOAD(_cDirOri +_cArqOri , _cArqDst)
					IF _lOkUpLoad
						EXIT
					ENDIF
				NEXT _nContUpload
				IF !_lOkUpLoad
					_cMsgErr := _cEmlTit + " - Falha Envio FTP - Na C๓pia para Servidor"
					T_EDIGrvLog(_cMsgErr, cArqLogEnv)	
					_aMsgErr := ;
					{_cMsgErr,+;
					"Server FTP: "+_cServ,;
					"Porta     : "+STRZERO(_nPort,4),;
					"Usuแrio   : "+_cUser,;
					"Senha     : Verificar parโmetro Microsiga",;
					"Caminho   : "+_cDirDst}
					AADD(_aMsgErr,"Arquivos processados: ")
					FOR _nArqErr := 1 TO LEN(_aArqOri)
						IF _nArqErr >= _nArq
							_cArqDst := _aArqOri[_nArqErr]
							AADD(_aMsgErr,"   Falha na Copia  "+_cArqDst)
						ELSE
							IF FTPERASE(_aArqOri[_nArqErr])
								_cArqDst := _aArqOri[_nArqErr]
								AADD(_aMsgErr,"   Copiado/Apagado "+_cArqDst)
							ELSE
								_cArqDst := _aArqOri[_nArqErr]
								AADD(_aMsgErr,"   Copiado         "+_cArqDst)
							ENDIF
						ENDIF
					NEXT _nArqErr

					T_EnviaMail(cDirStart,;
					_cEmlArq,;
					_cEmlDst,;
					_cMsgErr,;
					_aMsgErr)
					lOk := .f.
					EXIT
				ENDIF
			NEXT _nArq
		ENDIF
	ENDIF
	FTPDISCONNECT()
ENDIF

if ! lOk  // Houve problema na transmissao pelo FTP
	_cDataHora := "SemFtp" + dtos(date()) + subs(Time(),1,2) + subs(Time(),4,2) + subs(Time(),7,2) + "_"
	if __CopyFile( _cDirOri+_cArqOri , _cDirOri+ _cDataHora + _cArqOri )
		_cMsgErr := "Problemas no FTP. Arquivo " + _cDirOri+_cArqOri + " copiado para " + _cDirOri+ _cDataHora + _cArqOri
	else
		_cMsgErr := "Problemas no FTP. Nao consegui copiar arquivo " + _cDirOri+_cArqOri + " para " + _cDirOri+ _cDataHora + _cArqOri
	endif
	T_EDIGrvLog(_cMsgErr, cArqLogEnv)	
Endif

RETURN lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณEnviaMail บAutor  ณGeronimo B. Alves   บ Data ณ  14/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe parametros do e cria arquivo texto no formato de    บฑฑ
ฑฑบ          ณ email para envio posterior                                 บฑฑ
ฑฑบ          ณ Obs. No momento esta desabilitada o seu uso                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template FUNCTION EnviaMail(_cEmlDir,_cEmlArq,_cDestinat,_cSubject,_aTxtMail)
// Essa fun็ใo necessita de um procedimento agendado no Schedule do Servidor protheus
// para executar autometicamente por isto e por estar fora do escopo esta temporariamente desabilitada.
Local _nLinMail := 0

cEmlGrv := _cEmlDir+_cEmlArq
nHldEml := FCREATE(cEmlGrv+".TXT",0)
GravaBin(nHldEml,"From: Protheus"+CTRL,.f.)
GravaBin(nHldEml,"To: "+_cDestinat+CTRL,.f.)
GravaBin(nHldEml,"Subject: "+_cSubject+CTRL,.f.)
GravaBin(nHldEml,"Body:"+CTRL,.f.)
GravaBin(nHldEml,"."+CTRL,.f.)
FOR _nLinMail := 1 TO LEN(_aTxtMail)
	GravaBin(nHldEml,_aTxtMail[_nLinMail]+CTRL,.f.)
NEXT _nLinMail

FCLOSE(nHldEml)

RETURN NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณGravaBin  บAutor  ณGeronimo B. Alves   บ Data ณ  14/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe parametros e grava linha no arquivo texto           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function GravaBin(nHld,cStr,lTela)
Local lRet := .T.

If fWrite(nHld,cStr,Len(cStr)) != Len(cStr)
	if lTela
		MsgBox("Ocorreu um erro na gravacao do arquivo " + cEmlGrv )
	else
		ConOut('Ocorreu um erro na gravacao do arquivo ' + cEmlGrv )
	Endif
	lRet :=  .F.
Endif

Return lRet

//--------------------------------------------------------------------------------
//Email do S้rgio = sergiorodri@microsiga.com.br  ;  srodrigues@microsiga.com.br
//FTP: ftp.microsiga.com.br
//user: fabexpress
//Password: fabe6217
//Dir. Virtual: fabexpress
//--------------------------------------------------------------------------------
//Template Function TstFtpEnv()
//Local _cArqDst := _cEmlDst := _cEmlTit := _cEmlArq := _cQuote := ""
//Private lTela := .T.
//Private cDirStart	:= GetSrvProfString("STARTPATH","")      //Path onde serah gravado o arquivo de envio
//Private cArqLogEnv	:= cDirStart+"PcEnvioEDI.log"  //Grava o arquivo de log de erro no diretorio cStartPath
//if T_DROFtpEnv( "ftp.microsiga.com.br" ,21, "fabexpress","fabe6217",cDirStart,"SXE.DBF","/fabexpress",_cArqDst,_cEmlDst,_cEmlTit,_cEmlArq, _cQuote)
//	msgstop("OK")
//Else
//	msgstop("E R R O")
//Endif
//Return

