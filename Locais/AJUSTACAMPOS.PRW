#INCLUDE "Protheus.ch"
#INCLUDE "UpdLoj90.ch"

Static cRotina		:= "AJUSTACAMPOS"
Static nTamDiv		:= 125
Static cLastAlias   := ""
Static cLastOrdSX3  := ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AJUSTACAMPOS  บAutor  ณVendas Clientes       บ Data ณ  29/08/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para ajuste de Dicionarios.                             บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AJUSTACAMPOS()

	Local lRet      := .T.
	Local aArq      := {}

	Private oMainWnd

	//Desligar refresh no lock do TOP
	#IFDEF TOP
		TCInternal(5,'*OFF')
	#ENDIF

	Set Deleted On
	//Interface para viabilizar o emprego da barra de progressao e da funcao Aviso

	DEFINE WINDOW oMainWnd FROM 0,0 TO 01,1 TITLE OemToAnsi(STR0001) //"Ajustes de dicionแrio"

	ACTIVATE WINDOW oMainWnd ICONIZED ON INIT (lRet := PergProc(),oMainWnd:End())

	If 	!lRet
		Return NIL
	EndIf

	Processa({|| ProcAtua( @aArq )},cRotina,STR0002,.F.) //"Processando ajustes..."

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPergProc   บAutor  ณVendas Clientes       บ Data ณ  26/12/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PergProc()

	Local lRet      := .T.
	Local cMens     := ""

	cMens := STR0003 + CRLF //"Aten็ใo!"
	cMens += STR0004 + CRLF //"Esta rotina irแ atualizar os dicionแrios de dados para a utiliza็ใo de "
	cMens += STR0229 + CRLF //"novas funcionalidades."
	cMens += STR0006 + CRLF //"Importante : "
	cMens += STR0007        //"1. Nใo devem existir usuแrios utilizando o sistema durante a "
	cMens += STR0008 + CRLF //"atualiza็ใo!"
	cMens += STR0009 + CRLF //"2. อndices customizados que estejam em conflito com ํndices que "
	cMens += STR0010 + CRLF //"serใo criados, se possuirem nickname serใo deslocados, caso "
	cMens += STR0011 //"contrแrio serใo sobreescritos."

	If Aviso(STR0001 ,cMens,{STR0013,STR0014},3) <> 1 //"Ajustes de dicionแrio"###"Confirmar"###"Cancelar"
		Return !lRet
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcAtua   บAutor  ณVendas Clientes       บ Data ณ  26/12/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processar as atualizacoes                          บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcAtua( aArq )

	Local lRet      := .T.
    Local _cEmp     := "" //"99"
    Local _cFil     := "" //"01"
	Local nX        := 0
	Local cLOG      := ""
	Local cTipoArq  := STR0015 //"Arquivos Texto (*.TXT) |*.txt|"
	Local oTela	    := nil
	Local oMemo     := nil
	Local oFont     := nil
    Local lOk       := .F.

	Private nEtapas	:= 7

    While !lOk
        _cEmp := AllTrim(FWInputBox("Digite o c๓digo do Grupo de Empresa:", "99"))
        If Len(_cEmp) <> 2
            MsgAlert("C๓digo de Grupo de Empresa digitado estแ incorreto.")
        Else
            lOk := .T.
        EndIf
    End

    lOk := .F.
    While !lOk
        _cFil := AllTrim(FWInputBox("Digite o c๓digo da Filial:", "01"))
        _cFil := PadR(_cFil,FWSizeFilial())
        lOk := .T.
    End

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcessamento dos ajustes  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcRegua(1)

	IncProc(STR0016) //"Processando ajustes (iniciando)"

    RpcSetType(3)
    RpcSetEnv(_cEmp,_cFil,,,"FRT")
    ProcRegua(nEtapas)
    
    IncProc(STR0018)  //"Ajustando o SX3"
    cLOG += ProcAjSX3( @aArq )

    //Atualizar as estruturas consolidadas
    If Len(aArq) <> 0

        __SetX31Mode(.F.)
        
        For nX := 1 To Len(aArq)
            IncProc(STR0019 + aArq[nX] + "]") //"Atualizando estruturas [" ### "]"
            If Select(aArq[nX]) > 0
                
                dbSelectArea(aArq[nX])
                dbCloseArea()
                
            EndIf
            
            X31UpdTable(aArq[nX])
        
            If __GetX31Error()
                
                Alert(__GetX31Trace())
                Aviso(STR0003, STR0020 + aArq[nX] + "." + STR0021,{ STR0022 },2) //"Aten็ใo!"###"Ocorreu um erro desconhecido durante a atualiza็ใo da tabela "###". Verifique a integridade do dicionario e da tabela."###"Continuar"
                cLOG += STR0023 + aArq[nX] + CRLF //"Ocorreu um erro durante a atualizacao da estrutura da tabela : " ###
                
            EndIf
            
        Next nX
    EndIf	

	cLOG := STR0024 + CRLF + IIF(Empty(cLOG),Replicate("-",nTamDiv) + CRLF + STR0025,cLOG) //"LOG DA ATUALIZAวรO: "###"NENHUM AJUSTE EFETUADO"

	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12

	DEFINE MSDIALOG oTela TITLE STR0026 FROM 3,0 to 500,658 PIXEL //"Ajustes concluํdos"

	@05,05 GET oMemo VAR cLOG MEMO SIZE 320,230 OF oTela PIXEL

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont := oFont

	DEFINE SBUTTON  FROM 237,300 TYPE 1 ACTION oTela:End() ENABLE OF oTela PIXEL

	DEFINE SBUTTON  FROM 237,265 TYPE 13 ACTION (cArqLOG := cGetFile(cTipoArq,""),IIF(Empty(cArqLOG),.T.,MemoWrite(cArqLOG,cLOG))) ENABLE OF oTela PIXEL

	ACTIVATE MSDIALOG oTela CENTER

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFormataHelpบAutor  ณVendas Clientes       บ Data ณ  13/08/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para formatar uma string em uma array respeitando       บฑฑ
ฑฑบ          ณum tamanho maximo para visualizacao de help de campo           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FormataHelp(cTexto,nLimite)

	Local aRet      := {}
	Local nI        := 0
	Local nTam      := 0
	Local nCont     := 1
	Local nPos      := 0
	Local cVogais   := "AEIOUมษอำฺยสฮิÛภศฬาูรีฤหฯึÜ"
	Local cConsoa   := "BCDFGHJKLMNPQRSTVXWYZวั"
	Local cPontua   := "(){}[]:.,;"
	Local cNum      := "0123456789"
	Local cEspaco   := " " + Chr(13) + Chr(10)
	Local lPontua   := .F.
	Local lUltVog   := .F.
	Local lEncVoc   := .F.
	Local lEncCon   := .F.
	Local lTritongo := .F.
	Local lEspaco   := .F.
	Local lConEsp   := .F.
	Local lPalDuas  := .F.
	Local lPalTres  := .F. 
	Local nLinMax	:= 40 //Limite maximo
	

	Default cTexto 	:= ""
	Default nLimite	:= 35

	If Empty(cTexto)
		Return aRet
	EndIf

	cTexto	:= AllTrim(cTexto)
	nTam 	:= Len(cTexto)
	aRet	:= Array(1)
	nPos	:= Len(aRet)

	If nTam > nLimite
		
		aRet[nPos] := ""
		
		For nI := 1 to nTam 
			
			If nI > 1
				
				lPontua := Upper(Substr(cTexto,nI,1)) $ (cPontua + cNum)
				lUltVog	:= Upper(Right(aRet[nPos],1)) $ cVogais
				lEncVoc	:= Upper(Substr(cTexto,nI,1)) $ cVogais .AND. lUltVog
				lEncCon	:= Upper(Substr(cTexto,nI,1)) $ cConsoa .AND. Upper(Substr(cTexto,nI + 1,1)) $ cConsoa
				
				If lEncCon
					
					If Upper(Substr(cTexto,nI + 2,1)) $ "LR"
						
						lTritongo := .T.
					Else
						
						lTritongo := .F.
					EndIf
				Else
				
					lTritongo := .F.
				EndIf
				
				lEspaco	:= Upper(Substr(cTexto,nI,1)) $ cEspaco
				lConEsp	:= Upper(Substr(cTexto,nI,1)) $ cConsoa .AND. Upper(Substr(cTexto,nI + 1,1)) $ cEspaco 
				
				//Palavra duas letras, que nao deve ser quebrada
				If nI > 2
					
					lPalDuas := Upper(Substr(cTexto,nI - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,nI,1)) $ (cConsoa + cVogais) .AND. ;
								Upper(Substr(cTexto,nI + 2,1)) $ (cEspaco + cPontua)
				Else
					
					lPalDuas := .F.
				EndIf			
				
				//Palavra tres letras, que nao deve ser quebrada
				If !lPalDuas .AND. nI > 2
					
					lPalTres := Upper(Substr(cTexto,nI - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,nI,1)) $ (cConsoa + cVogais) .AND. ;
								Upper(Substr(cTexto,nI + 1,1)) $ (cConsoa + cVogais) .AND. Upper(Substr(cTexto,nI + 2,1)) $ (cEspaco + cPontua)
				Else
				
					lPalTres := .F.
				EndIf
				
				If nCont > nLimite .AND. ((!lPontua .AND. lUltVog .AND. !lEncVoc .AND. (!lEncCon .OR. lTritongo) .AND. !lConEsp .AND. ;
											!lPalDuas .AND. !lPalTres) .OR. (lEspaco))
					nCont := 0
					
					//Se nao for o ultimo caracter
					If nI < nTam
					
						//Se o caracter processado for uma consoante ou vogal e nao for um tritongo inserir o separador
						If Upper(Substr(cTexto,nI,1)) $ (cVogais + cConsoa)
						
							If lTritongo
							
								aRet[nPos] += Substr(cTexto,nI,1) + "-"
							Else
							
								aRet[nPos] += "-"
							EndIf
							
						EndIf
						
					EndIf
					
					aAdd(aRet,"")
					nPos := Len(aRet)
					
				Else
				
					//Negar o tritongo, pois nao havera necessidade de quebra e a letra precisa ser adicionada
					lTritongo := .F.
				EndIf
				
			EndIf
			
			If !lTritongo
			
				//Se for o ๚ltimo caractere trunca de qualquer maneira				
				If Len(aRet[nPos]) == nLinMax .AND. !lEspaco //nao pode adicionar mais nada trunca
					nCont := 0
					aAdd(aRet,"")
					nPos := Len(aRet)				
				EndIf
				aRet[nPos] += Substr(cTexto,nI,1)
			EndIf
			nCont++
			
		Next nI
		
		For nI := 1 to Len(aRet)
			
			aRet[nI] := LTrim(aRet[nI])
		Next nI	
	Else
		
		aRet[nPos] := cTexto
	EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcAjSX3  บAutor  ณVendas Clientes       บ Data ณ  13/08/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para processar as atualizacoes no SX3                   บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcAjSX3( aArq )
Local cRet      := ""
Local aSX3      := {}
Local aEstru    := {}
Local nI        := 0
Local nX        := 0
Local lAppend 	:= .T.
Local cOrdem    := ""

aEstru := { "X3_ARQUIVO" , "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"  }


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Obtendo valores para USADO e RESERV           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->( dbSetOrder(2) ) //X3_CAMPO
SX3->( dbSeek( "A1_COD" ) )
cUsadoKey	:= SX3->X3_USADO
cReservKey	:= SX3->X3_RESERV

SX3->( dbSeek( "A1_NOME" ) )
cUsadoObr	:= SX3->X3_USADO
cReservObr	:= SX3->X3_RESERV

SX3->( dbSeek( "A1_INSCRM" ) )
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV

SX3->( dbSeek( "A1_FILIAL" ) )
cUsadoNao	:= SX3->X3_USADO
cReservNao	:= SX3->X3_RESERV

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_DIRLAYE'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Dir Lay Env"         	              	                          			, ; //X3_TITULO
    "Dir Lay Env"    	    	       	                          			   	, ; //X3_TITSPA 
    "Dir Lay Env" 	            	                               			   	, ; //X3_TITENG
    "Diretorio Layout Envio"    			                   			        , ; //X3_DESCRIC
    "Diretorio Layout Envio"    		           			                    , ; //X3_DESCSPA
    "Diretorio Layout Envio"					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME
aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_DIREDIE'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Dir EDI Env"         	              	                          			, ; //X3_TITULO
    "Dir EDI Env"    	    	       	                          			   	, ; //X3_TITSPA 
    "Dir EDI Env" 	            	                               			   	, ; //X3_TITENG
    "Diretorio do EDI de Envio"    			                   			        , ; //X3_DESCRIC
    "Diretorio do EDI de Envio"    		           			                    , ; //X3_DESCSPA
    "Diretorio do EDI de Envio"					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_LAYOUTE'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    20					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Layuot Env."         	              	                          			, ; //X3_TITULO
    "Layuot Env."     	    	       	                          			   	, ; //X3_TITSPA 
    "Layuot Env." 	            	                               			   	, ; //X3_TITENG
    "Layout envio Ped. Compras" 	                           			        , ; //X3_DESCRIC
    "Layout envio Ped. Compras"       	           			                    , ; //X3_DESCSPA
    "Layout envio Ped. Compras" 				                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    'M->A2_FABRICA == "N" .Or. M->A2_FABRICA == "2"'                         	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME
   
aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_ARQEDI'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    20					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Arquivo Env."         	              	                          			, ; //X3_TITULO
    "Arquivo Env."    	    	       	                          			   	, ; //X3_TITSPA 
    "Arquivo Env." 	            	                               			   	, ; //X3_TITENG
    "Arquivo de Envio"	        			                   			        , ; //X3_DESCRIC
    "Arquivo de Envio"   	    		           			                    , ; //X3_DESCSPA
    "Arquivo de Envio"      					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    'M->A2_FABRICA == "N" .Or. M->A2_FABRICA == "2"'                           	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_DIRLAYR'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Dir Lay Ret"         	              	                          			, ; //X3_TITULO
    "Dir Lay Ret"    	    	       	                          			   	, ; //X3_TITSPA 
    "Dir Lay Ret" 	            	                               			   	, ; //X3_TITENG
    "Diretorio layout ret."    	    		                   			        , ; //X3_DESCRIC
    "Diretorio layout ret."        		           			                    , ; //X3_DESCSPA
    "Diretorio layout ret." 					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_DIREDIR'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Dir EDI Ret"         	              	                          			, ; //X3_TITULO
    "Dir EDI Ret"    	    	       	                          			   	, ; //X3_TITSPA 
    "Dir EDI Ret" 	            	                               			   	, ; //X3_TITENG
    "Diretorio do EDI de Ret."    			                   			        , ; //X3_DESCRIC
    "Diretorio do EDI de Ret."    		           			                    , ; //X3_DESCSPA
    "Diretorio do EDI de Ret."					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A2_FABRICA", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A2_FABRICA", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_LAYOUTR'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    20					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Layout Ret."         	              	                          			, ; //X3_TITULO
    "Layout Ret."     	    	       	                          			   	, ; //X3_TITSPA 
    "Layout Ret." 	            	                               			   	, ; //X3_TITENG
    "Layout ret. Ped. Compras" 	                               			        , ; //X3_DESCRIC
    "Layout ret. Ped. Compras"         	           			                    , ; //X3_DESCSPA
    "Layout ret. Ped. Compras"   				                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                       	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_ARQEDIR'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Arquivo Ret."         	              	                          			, ; //X3_TITULO
    "Arquivo Ret."    	    	       	                          			   	, ; //X3_TITSPA 
    "Arquivo Ret." 	            	                               			   	, ; //X3_TITENG
    "Arquivo de retorno"        			                   			        , ; //X3_DESCRIC
    "Arquivo de retorno"   	    		           			                    , ; //X3_DESCSPA
    "Arquivo de retorno"      					                                , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPSERV'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    51					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Server FTP"         	              	                          			, ; //X3_TITULO
    "Server FTP"     	    	       	                          			   	, ; //X3_TITSPA 
    "Server FTP" 	            	                               			   	, ; //X3_TITENG
    "Endereco do Servidor FTP" 	    		                   			        , ; //X3_DESCRIC
    "Endereco do Servidor FTP"     		           			                    , ; //X3_DESCSPA
    "Endereco do Servidor FTP" 					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPPORT'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    7					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Porta FTP"         	              	                          			, ; //X3_TITULO
    "Porta FTP"     	    	       	                          			   	, ; //X3_TITSPA 
    "Porta FTP" 	            	                               			   	, ; //X3_TITENG
    "Porta do Server do FTP" 	    		                   			        , ; //X3_DESCRIC
    "Porta do Server do FTP"     		           			                    , ; //X3_DESCSPA
    "Porta do Server do FTP" 					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPUSER'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    16					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Usuario FTP"         	              	                          			, ; //X3_TITULO
    "Usuario FTP"     	    	       	                          			   	, ; //X3_TITSPA 
    "Usuario FTP" 	            	                               			   	, ; //X3_TITENG
    "Usuario do FTP" 	    		                           			        , ; //X3_DESCRIC
    "Usuario do FTP"     	        	           			                    , ; //X3_DESCSPA
    "Usuario do FTP"        					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPPASS'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    11					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Senha FTP"         	              	                          			, ; //X3_TITULO
    "Senha FTP"     	    	       	                          			   	, ; //X3_TITSPA 
    "Senha FTP" 	            	                               			   	, ; //X3_TITENG
    "Senha do Usuario do FTP" 	    		                   			        , ; //X3_DESCRIC
    "Senha do Usuario do FTP"     		           			                    , ; //X3_DESCSPA
    "Senha do Usuario do FTP" 					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPDIRD'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    51					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Diretor. FTP"         	              	                          			, ; //X3_TITULO
    "Diretor. FTP"    	    	       	                          			   	, ; //X3_TITSPA 
    "Diretor. FTP" 	            	                               			   	, ; //X3_TITENG
    "Diretorio destino no FTP" 	    		                   			        , ; //X3_DESCRIC
    "Diretorio destino no FTP"     		           			                    , ; //X3_DESCSPA
    "Diretorio destino no FTP" 					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SA2'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'A2_FTPARQD'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    21					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Arq. Des.FTP"         	              	                          			, ; //X3_TITULO
    "Arq. Des.FTP"    	    	       	                          			   	, ; //X3_TITSPA 
    "Arq. Des.FTP" 	            	                               			   	, ; //X3_TITENG
    "Nome Arquivo Destino FTP" 	    		                   			        , ; //X3_DESCRIC
    "Nome Arquivo Destino FTP"     		           			                    , ; //X3_DESCSPA
    "Nome Arquivo Destino FTP" 					                                , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '7'                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SC7'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'C7_ENVIAR'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Enviar EDI ?"         	              	                          			, ; //X3_TITULO
    "Enviar EDI ?"    	    	       	                          			   	, ; //X3_TITSPA 
    "Enviar EDI ?" 	            	                               			   	, ; //X3_TITENG
    "Enviar EDI ?" 	    		                               			        , ; //X3_DESCRIC
    "Enviar EDI ?"     	        	               			                    , ; //X3_DESCSPA
    "Enviar EDI ?"      					                                    , ; //X3_DESCENG
    '@!'          		                                                     	, ; //X3_PICTURE
    'Pertence("12")'                                                           	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    '"2"'                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Sim;2=Nao'                                                             	, ; //X3_CBOX
    '1=Sim;2=Nao'                                                             	, ; //X3_CBOXSPA
    '1=Sim;2=Nao'                                                              	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SC7'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'C7_FORNEDI'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    6					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Fornec. Orig"         	              	                          			, ; //X3_TITULO
    "Fornec. Orig"    	    	       	                          			   	, ; //X3_TITSPA 
    "Fornec. Orig" 	            	                               			   	, ; //X3_TITENG
    "Fornecedor Original do PC"                               			        , ; //X3_DESCRIC
    "Fornecedor Original do PC"    	               			                    , ; //X3_DESCSPA
    "Fornecedor Original do PC" 			                                    , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                         	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                       	, ; //X3_CBOX
    ''                                                                         	, ; //X3_CBOXSPA
    ''                                                                        	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SC7'                                                                   	, ; //X3_ARQUIVO
    cOrdem                                                                   	, ; //X3_ORDEM
    'C7_LOJAEDI'      	                                                 		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    2					                                                  		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Loja EDI"             	              	                          			, ; //X3_TITULO
    "Loja EDI"        	    	       	                          			   	, ; //X3_TITSPA 
    "Loja EDI"   	            	                               			   	, ; //X3_TITENG
    "Loja do Forn. no EDI"                                   			        , ; //X3_DESCRIC
    "Loja do Forn. no EDI"        	               			                    , ; //X3_DESCSPA
    "Loja do Forn. no EDI"   	    		                                    , ; //X3_DESCENG
    ''          		                                                     	, ; //X3_PICTURE
    ''                                                                         	, ; //X3_VALID
	RetSX3Prop("A1_TPCONVE", "X3_USADO")										, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    RetSX3Prop("A1_TPCONVE", "X3_RESERV")                                  		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                       	, ; //X3_CBOX
    ''                                                                         	, ; //X3_CBOXSPA
    ''                                                                        	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                        	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    ''                                                                      	} ) //X3_PYME

//======================================================================
//
//      AJUSTES DE CAMPOS EXISTENTES
//
//======================================================================

/*
DbSelectArea("SX3")
SX3->(DbSetOrder(2)) //X3_CAMPO

//
// Campos Tabela MAC
//
SX3->(DbSeek("MAC_CODDEP"))
aAdd( aSX3, { ;
    SX3->X3_ORDEM                                                              	, ; //X3_ARQUIVO
    SX3->X3_ORDEM                                                             	, ; //X3_ORDEM
    SX3->X3_CAMPO      	                                                 		, ; //X3_CAMPO
    SX3->X3_TIPO                                                               	, ; //X3_TIPO
    SX3->X3_TAMANHO					                                            , ; //X3_TAMANHO
    SX3->X3_DECIMAL                                                            	, ; //X3_DECIMAL
    SX3->X3_TITULO         	              	                          			, ; //X3_TITULO
    SX3->X3_TITSPA    	    	       	                          			   	, ; //X3_TITSPA 
    SX3->X3_TITENG 	            	                               			   	, ; //X3_TITENG
    SX3->X3_DESCRIC    			    	                   		    	        , ; //X3_DESCRIC
    SX3->X3_DESCSPA         		           			                        , ; //X3_DESCSPA
    SX3->X3_DESCENG        					                                    , ; //X3_DESCENG
    SX3->X3_PICTURE            		                                           	, ; //X3_PICTURE
    'PERTENCE("123") .AND. T_CRDBLOQCART()'                                    	, ; //X3_VALID
	SX3->X3_USADO  																, ;	//X3_USADO
    SX3->X3_RELACAO                                                           	, ; //X3_RELACAO
    SX3->X3_F3                                                                 	, ; //X3_F3
    SX3->X3_NIVEL                                                             	, ; //X3_NIVEL
    SX3->X3_RESERV 			                                               		, ; //X3_RESERV
    SX3->X3_CHECK                                                              	, ; //X3_CHECK
    SX3->X3_TRIGGER                                                            	, ; //X3_TRIGGER
    SX3->X3_PROPRI                                                            	, ; //X3_PROPRI
    SX3->X3_BROWSE                                                             	, ; //X3_BROWSE
    SX3->X3_VISUAL                                                             	, ; //X3_VISUAL
    SX3->X3_CONTEXT                                                           	, ; //X3_CONTEXT
    SX3->X3_OBRIGAT                                                            	, ; //X3_OBRIGAT
    SX3->X3_VLDUSER                                                            	, ; //X3_VLDUSER
    SX3->X3_CBOX                                                              	, ; //X3_CBOX
    SX3->X3_CBOXSPA                                                          	, ; //X3_CBOXSPA
    SX3->X3_CBOXENG                                                            	, ; //X3_CBOXENG
    SX3->X3_PICTVAR                                                            	, ; //X3_PICTVAR
    SX3->X3_WHEN                                                              	, ; //X3_WHEN
    SX3->X3_INIBRW                                                            	, ; //X3_INIBRW
    SX3->X3_GRPSXG                                                             	, ; //X3_GRPSXG
    SX3->X3_FOLDER                                                             	, ; //X3_FOLDER
    SX3->X3_PYME                                                               	} ) //X3_PYME
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessamento dos campos no SX3   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcRegua(Len(aSX3))
dbSelectArea("SX3")
SX3->(dbSetOrder(2)) //X3_CAMPO

For nI := 1 To Len(aSX3)
	
	IncProc()
	
	If !Empty(aSX3[nI][1])

		SX3->(dbSetOrder(2)) //X3_CAMPO
		
		If !SX3->(dbSeek(PadR(aSX3[nI,3],10)))
			lAppend := .T.
            cOrdem  := RetSX3Ord(aSX3[nI][1])
			cRet += STR0051 + aSX3[nI][3] + CRLF //"- Inclusใo do campo : "
		Else
			cOrdem  := SX3->X3_ORDEM
			lAppend := .F.
			cRet += "- " + STR0219 + ": " + aSX3[nI][3] + CRLF //"- "###"Ajuste no campo"###": "
		EndIf

        aSX3[nI,2] := cOrdem
		
		If aScan(aArq,{|x| AllTrim(x) == AllTrim(aSX3[nI,1])}) == 0
			aAdd(aArq,aSX3[nI,1])
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

If !Empty(cRet)
	cRet := Replicate("-",nTamDiv) + CRLF + STR0052 + CRLF + cRet //"AJUSTES NO SX3 : "
EndIf

Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RetSX3Prop
Retora o conte๚do de uma determinada propriedade do SX3 de um determinado campo.

@author  Alberto Deviciente
@since   03/07/2021
@version P12

@param 	 cTabela, Caracter, Alias da tabela

@return  cOrdem, Caracter, Pr๓xima ordem para uso no SX3 para o Alias em questใo.
/*/
//-------------------------------------------------------------------------------
Static Function RetSX3Prop(cCampo, cProprieda)
Local uRet      := Nil
Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())

DbSelectArea("SX3")
SX3->( dbSetOrder(2) ) //X3_CAMPO
If SX3->( dbSeek( PadR(cCampo,10) ) )
    uRet := &("SX3->"+cProprieda)
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return uRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RetSX3Ord
Retorna a pr๓xima ORDEM (X3_ORDEM) do campo no dicionแrio de dados.

@author  Alberto Deviciente
@since   03/07/2021
@version P12

@param 	 cTabela, Caracter, Alias da tabela

@return  cOrdem, Caracter, Pr๓xima ordem para uso no SX3 para o Alias em questใo.
/*/
//-------------------------------------------------------------------------------
Static Function RetSX3Ord(cTabela)
Local cOrdem	:= "00"
Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())

If cLastAlias <> cTabela
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
    SX3->(DbSeek(cTabela))
    While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cTabela
        cOrdem  := SX3->X3_ORDEM
        SX3->(DbSkip())
    End
Else
    cOrdem := cLastOrdSX3
EndIf

cOrdem  := Soma1(cOrdem)

RestArea(aAreaSX3)
RestArea(aArea)

cLastOrdSX3 := cOrdem

Return cOrdem