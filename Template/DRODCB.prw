#include "totvs.ch"
#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DRODCB
Funcao responsavel em realizar a importação de registros do DCB.
O arquivo precisa ser no formato csv e possuir tres colunas.
@author  michael.gabriel
@since   06/10/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------

Template Function DRODCB()
Local cTarget   := ""
Local lRet      := .F.
Local aLinhas   := {}
Local oProcess  := Nil

/*  SELECAO DO ARQUIVO */
cTarget := cGetFile( "Arquivos CSV (*.csv) |*.csv|", "Selecione o arquivo a ser importado", 1, 'C:\', .F., GETF_LOCALHARD, .T., .T. )

If !Empty(cTarget)
    //verifica se o arquivo esta acessivel
    lRet := File(cTarget)

    If lRet
		oProcess := MsNewProcess():New( { || lRet := DROReadDCB(oProcess, cTarget) } , 'Importação do D.C.B.' , 'Aguarde...' , .F. )
		oProcess:Activate()
    Else
        MsgStop("O arquivo " + cTarget + " não está acessivel." + CRLF + "A importação do arquivo será cancelada", "[AEST901] - ATENCAO")
    EndIf
EndIf

If lRet
    MsgInfo( "Importação do arquivo realizada com sucesso!" )
EndIf

// destruimos o array da memoria
aSize( aLinhas, 0 )
aLinhas := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DRODCB
Funcao responsavel em fazer a leitura do arquivo .csv
@author  michael.gabriel
@since   06/10/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function DROReadDCB(oProcess,cTarget)

Local nHandle   := 0
Local lRet      := .T.
Local nBarra    := 0
Local nI		:= 0
Local nX		:= 0
Local cLinha    := ""
Local nTotalReg := 0
Local aLinhas   := {}
Local aAux      := {}

Default oProcess:= Nil
Default cTarget := ""

// faz a abertura do arquivo
nHandle := FT_FUse( cTarget )

If nHandle >= 0

    // obtem a quantidade de registros posicionando no ultimo
    nTotalReg := FT_FLastRec()

    // volta para a primeira linha do arquivo
    FT_FGoTop()

    /* Se a quantidade for menor que 10, atribuimos 1 a barra de progresso,
    pois assim, a barra só será incrementada no processamento */
    
    nBarra := nTotalReg / 10
    If nBarra < 1
        nBarra := 1
    EndIf

	//atribui o valor maximo da primeira barra de progresso (2 etapas + 1 para inicializacao da barra)
	oProcess:SetRegua1( 3 ) 
	oProcess:IncRegua1()

	//faz o incremento da primeira  barra
	oProcess:IncRegua1( 'Realizando a leitura do arquivo.' )
	
	//atribui o valor maximo da segunda barra de progresso
	oProcess:SetRegua2( nBarra )

    If nTotalReg > 0

		For nI := 1 to nTotalReg
		
			// obtem o conteudo da linha
			cLinha := LjRmvChEs(FT_FReadLN())

			// separa o conteudo da linha e o adiciona no array
            aAux := StrTokArr(cLinha,";")
            if Len(aAux) >= 3
                For nX := 1 to 3
                    aAux[nX] := Upper( AllTrim(aAux[nX]) )
                Next
                Aadd( aLinhas, aClone(aAux) )
            else
                LjGrvLog("IMPORTACAO_DCB", "Esses registros nao foram importados",aAux)
            endif			

			// somente incrementamos a regua a cada 10 registros por motivo de performance
			If nI % 10 = 0
				oProcess:IncRegua2( cValToChar(nI) + "/" + cValToChar(nTotalReg) )
			EndIf

			FT_FSkip()		
		Next
		
		/*
		GRAVACAO NA TABELA LKD
		*/
		lRet := DROImpDCB(oProcess, aLinhas)
	Else
		MsgInfo("Não há nenhuma informação a ser importada.")
	EndIf

    // realiza o fechamento do arquivo
    FT_FUse()
Else
    MsgStop("Não foi possível abrir o arquivo " + cTarget + CRLF + "A importação do arquivo será cancelada", "ATENCAO")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DRODCB
Funcao responsavel em gravar os registros lidos do arquivo .csv
@author  michael.gabriel
@since   06/10/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DROImpDCB( oProcess, aLinhas )

Local cCodDCB   := ""
Local nTamCampo := 0
Local nTotalReg := 0
Local nBarra    := 0
Local nI        := 0
Local lRet      := .T.

Default oProcess:= Nil
Default aLinhas := {}

DbSelectArea("LKD")
LKD->( DbSetOrder(1) )

nTamCampo := TamSX3("LKD_CODDCB")[1]

/*	
Se a quantidade for menor que 10, atribuimos 1 a barra de progresso,
pois assim, a barra só será incrementada no processamento.
*/
nTotalReg := Len(aLinhas)

nBarra := nTotalReg/10
If nBarra < 1
	nBarra := 1
EndIf

//incrementa a primeira barra de progresso (etapa final)
oProcess:IncRegua1("Realizando a importação do arquivo")

//atribui o valor maximo da segunda barra de progresso
oProcess:SetRegua2( nBarra )

For nI := 1 to nTotalReg    
    // Codigo do DCB ja estruturado para o DbSeek
    cCodDCB := PadR( Upper(AllTrim(aLinhas[nI][1])), nTamCampo )
    
    // se o Codigo DCB nao existir, inclui o registro
    If !LKD->( DbSeek( xFilial("LKD") + cCodDCB) )
        lRet := RecLock("LKD", .T.)
        If lRet
            Replace LKD->LKD_FILIAL with xFilial("LKD")
            Replace LKD->LKD_CODDCB with cCodDCB
            Replace LKD->LKD_DSCDCB with Upper( AllTrim(aLinhas[nI][2]) )
            Replace LKD->LKD_NUMCAS with Upper( AllTrim(aLinhas[nI][3]) )
            LKD->( MsUnlock() )
        Else
            Exit
        EndIf
    EndIf

    If nI % 10 = 0
        //incrementa a segunda barra de progresso
		oProcess:IncRegua2( cValToChar(nI) + "/" + cValToChar(nTotalReg) )
    EndIf

Next

Return lRet