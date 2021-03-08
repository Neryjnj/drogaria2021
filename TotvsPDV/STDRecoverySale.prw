#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "STDRecoverySale.ch"   

Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

Function STDRecoverySale()

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STDRSGetSale
Busca venda a ser Recuperada

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSale[1]				Retorna Cabeçalho da Venda (SL1)
@return  aSale[2]				Retorna Itens da Venda (SL2)
@return  aSale[3]				Retorna Formas de Pagamento da venda (SL4)
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDRSGetSale()

Local aArea		:= GetArea()			// Guarda alias corrente
Local aSale		:= {}					// Retorno da funcao
Local aSL1		:= {}					// SL1
Local aSL2		:= {}					// SL2
Local aItens	:= {}					// Itens
Local aSL4		:= {}					// SL4
Local aPay		:= {}					// Pagamentos
Local nI		:= 0					// Contador
Local nItem		:= 0  					// Variavel para Contorle de itens (Numerico)
Local cItem		:= ""					// Variavel para Contorle de itens (Caracter)
Local aFRTResume:= {}

// Detectar Registros Nao Finalizados
DbSelectArea("SL1")
SL1->(DbSetOrder(1))// L1_FILIAL+L1_NUM
SL1->(Dbgoto(SL1->(LASTREC())))

While !SL1->(BOF()) .AND. !(xFilial("SL1") == SL1->L1_FILIAL) 	
	SL1->(dbSkip(-1))
EndDo

If !SL1->(BOF()) .AND. !SL1->(EOF()) .AND. SL1->L1_SITUA >= "01" .AND. SL1->L1_SITUA <= "99" .AND. SL1->L1_SITUA <>  '07'
	// aSL1 := DbStruct()
	For nI := 1 To fCount()
		AADD( aSL1 , { SL1->(FieldName(nI)) , &(SL1->(FieldName(nI))) } )
	Next nI 
	
    //Verifica se usa o Template de Drogaria
    If ExistFunc("LJIsDro") .And. LJIsDro()
        If ExistTemplate("FRTRESUME")
            aFRTResume := ExecTemplate( "FRTRESUME", .F., .F. )
            If ValType(aFRTResume) == "A" .AND. Len(aFRTResume) >= 1 .And. ExistFunc("STBDroVars")
                //Seta o (Código do Plano) na variável estática usada nos Fontes do Template de Drogaria
                STBDroVars(.F., .T., aFRTResume[1], Nil)
            EndIf
        EndIf
    EndIf

	DbSelectArea("SL2")
	DbSetOrder(1)//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	If DbSeek(xFilial("SL2")+SL1->L1_NUM)
		While !EOF() .AND. (xFilial("SL2") == SL1->L1_FILIAL) .AND. (SL2->L2_NUM == SL1->L1_NUM)
			
			// -- Reorganizo Item da tabela SL2

			nItem ++
			cItem := AllTrim(Str(nItem))

			If Len(cItem) == 1
				cItem := '0' + cItem
			EndIf		

			If nItem > 99
				cItem := STBPegaIT(nItem)
			EndIf

			If !( cItem == SL2->L2_ITEM )		
				RecLock("SL2",.F.)
					SL2->L2_ITEM := cItem
				SL2->(MsUnLock())
			EndIf  

			For nI := 1 To fCount()
				AADD( aItens , { SL2->(FieldName(nI)) , &(SL2->(FieldName(nI))) } )
			Next nI
			
			AADD( aSL2 , aItens )
			aItens := {}
			SL2->(DbSkip())
		EndDo
		
	EndIf
	
	DbSelectArea("SL4")
	DbSetOrder(1)//L4_FILIAL+L4_NUM+L4_ORIGEM
	If DbSeek(xFilial("SL4")+SL1->L1_NUM)
		While !EOF() .AND. (xFilial("SL4") == SL1->L1_FILIAL) .AND. (SL4->L4_NUM == SL1->L1_NUM)
			For nI := 1 To fCount()
				AADD( aPay , { SL4->(FieldName(nI)) , &(SL4->(FieldName(nI))) } )
			Next nI
			AADD( aSL4 , aPay )
			aPay := {}
			SL4->(DbSkip())
		EndDo
	EndIf
	
EndIf

If !Empty(aSL1)
	AADD(aSale , aSL1)
	AADD(aSale , aSL2)
	AADD(aSale , aSL4)
EndIf
	
RestArea(aArea)

Return aSale

//-------------------------------------------------------------------
/*{Protheus.doc} STDRSSameCash
Verifica se o caixa logado eh o mesmo caixa aberto

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se o caixa logado eh o mesmo caixa aberto
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDRSSameCash()

Local lRet			:= .T.								// Retorno funcao
Local aArea			:= GetArea()						// Armazena area corretne
Local aAreaSLI		:= SLI->(GetArea())					// Armazena area SLI
Local cEstacao 		:= AllTrim(STFGetStat("CODIGO"))	// Estacao

DbSelectArea("SLI")
DbSetOrder(1) // LI_FILIAL + LI_ESTACAO + LI_TIPO
If SLI->(DbSeek(xFilial("SLI") + PadR(cEstacao,TamSX3("LI_ESTACAO")[1]) + "OPE"))
	If !(Empty(SLI->LI_MSG))
		If (AllTrim(SLI->LI_USUARIO) <> AllTrim(cUserName))
			lRet := .F.      		
			STFMessage("STRecoverySale","STOP","Existe um cupom do caixa: " + (AllTrim(SLI->LI_USUARIO)) + " " + ; //"Existe um cupom do caixa: "
			"para ser recuperado. Acesse o sistema com esse caixa para concluir a operacao") //"para ser recuperado. Acesse o sistema com esse caixa para concluir a operacao"
			STFShowMessage("STRecoverySale")
		EndIf
	EndIf
EndIf

RestArea(aAreaSLI)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSatRecovery
@description	Função responsável por realizar toda a recuperaçao 
				da venda SAT no TOTVSPDV

@author			Verejo
@since			07/12/2016
@version		11.80
@return			lRet -> Sempre verdadeiro (ja preparado para futuras 
				implementações)
/*/
//-------------------------------------------------------------------
Function STDSatRecovery(lFinCnc)
Local lRet			:= .T.
Local aAreaSL1 	:= {}
Local aAreaSL2 	:= {}
Local aAreaSL4 	:= {}
Local aCpAreaSL1:= {}
Local aCpAreaSL2:= {}
Local aRetSitC	:= {}
Local aValidCancel:= {}
Local aAux		:= Array(2)
Local cNFisCanc	:= ""
Local cMsg		:= ""

Default lFinCnc := .F.

If ExistFunc("SATValidCanc")
	If !lFinCnc .And. SATValidCanc()

		LjGrvLog( "SAT", "Duplicando a venda para cancelamento no SAT e processamento do livro fiscal referente a venda cancelada.")
		LjGrvLog( "SAT", "Venda original: " + SL1->L1_NUM)

		//Guarda posição do orçamento original
		aAreaSL1 	:= SL1->(GetArea())
		aAreaSL2 	:= SL2->(GetArea())
		aAreaSL4 	:= SL4->(GetArea())

		STDDblOrc() //copia orçamento
		LjGrvLog( "SAT", "Venda copia numero: " + SL1->L1_NUM)

		//Guarda posição do orçamento novo (cópia)
		aCpAreaSL1	:= SL1->(GetArea())
		aCpAreaSL2	:= SL2->(GetArea())

		//Retorna posição do orçamento original			
		RestArea(aAreaSL4)
		RestArea(aAreaSL2)
		RestArea(aAreaSL1)

		LjGrvLog( "SAT", "Cancelando a venda original: " + SL1->L1_NUM)
		LJSatUltimo(.T.)

		//Retorna posição do orçamento novo (cópia)
		RestArea(aCpAreaSL2)
		RestArea(aCpAreaSL1)
		LjGrvLog( "SAT", "posicionando na nova venda (copia) para finalização correta: " + SL1->L1_NUM)
	ElseIf lFinCnc .And. ExistFunc("LjSaCtrCnc")
	
		//Cn=Transacao de cancelamento ficou pendente em algum ponto
		aRetSitC:= LjSaTraCtr(LjSaCtrCnc(.F.,.F.,.T.,.F.,""))
		LjGrvLog( "SAT", "Finalizando cancelamento que foi interrompido")

		//Guarda posição do orçamento original
		aAreaSL1 	:= SL1->(GetArea())
		aAreaSL2 	:= SL2->(GetArea())
		aAreaSL4 	:= SL4->(GetArea())

		SL1->( DbSetOrder(2) )	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		If SL1->( DbSeek(aRetSitC[2] + STFGetStation("SERIE") + aRetSitC[4] + aRetSitC[3]) )
			If LjSatFinCnc(.F.)
				//" Venda referente ao orçamento #" + " cancelada no Equipamento de SAT está pendente de cancelamento no Protheus " + " Será realizado o cancelamento dessa venda!"
				MsgAlert(STR0001 + AllTrim(SL1->L1_NUM) + StrTran(STR0002, "SAT", cSiglaSat) + CHR(13) + STR0003)
								
				//Gera cancelamento SAT
				lRet := LJSatxCanc(.F.,@cNFisCanc)
				
				If lRet
					aValidCancel	:= STBCSCanCancel(StrZero(Val(aRetSitC[4]),6))
					If aValidCancel[1]
						STISetCancel( aValidCancel )
						aAux[1] := ""
						aAux[2] := ""
						lRet := STWCSFinalized(aValidCancel[3] , aValidCancel[4] , aValidCancel[5], @aAux[1], @aAux[2], cNFisCanc )
						
						If lRet
							LjSatAjTab(.F.,	.F.	,.T.,cNFisCanc,"",NIL)
						EndIf
					EndIf
					LjSatFinCnc(.T.) //apaga a sessão					
				Else
					cMsg := cSiglaSat + " - Venda já cancelada ou excedeu o período de 30 minutos." //"SAT - Venda já cancelada ou excedeu o período de 30 minutos."
					LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento
				EndIf
			Else
				cMsg :=  cSiglaSat + " - Recuperação de cancelamento não encontrado na sessão "
			EndIf
		Else
			lRet := .F.
			cMsg :=  cSiglaSat + " - Venda não encontrada." //"SAT - Venda não encontrada."
		EndIf
		
		//Retorna posição do orçamento original			
		RestArea(aAreaSL4)
		RestArea(aAreaSL2)
		RestArea(aAreaSL1)
		
		If lRet
			LjGrvLog( "SAT", "Cancelamento Finalizado")
	
			If !Empty(cMsg)
				LjGrvLog("SAT",cMsg)
			EndIf
			LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento
		EndIf		
	Else
		//Exclui a SL4 da venda, pois será gerado ao ser finalizada.
		STDRecovSL4()
	EndIf
Else
	LjGrvLog( "SAT", "AVISO: Atualizar fonte LOJSAT.PRW para a correta recuperação da venda.")
	LJSatUltimo(.T.)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDDblOrc
@description	Duplica Orcamento
@author			Verejo
@since			07/12/2016
@version		11.80
@obs			Não foi duplicado o SL4 pois no momento da finalização
				ja são gerados os registros conforme selecionado na venda
/*/
//-------------------------------------------------------------------
Function STDDblOrc() 

Local aStruSL1	:= {} //Estrutura inteira do dicionario da SL1
Local aDadosSL1	:= {} //Conteudo dos campos da SL1
Local aStruSL2	:= {} //Estrutura inteira do dicionario da SL2
Local aDadosSL2	:= {} //Conteudo dos campos da SL2
Local nX			:= 0  //contador
Local cNewNum		:= "" //numero do orçamento
Local nPos			:= 0  //posicao para recuperar valor de uma campo da busca do aScan
Local nLinha		:= 0  //numero de registros adicionados para cada estrutura da SL2 , SL4
Local nSaveSx8 	:= GetSx8Len() // Numeracao do SX8
Local nRegNumOrig	:= SL1->(RECNO())	//numero do orçamento original a ser copiado
Local cMay 		:= ""
Local nTent 		:= 0

SL1->(DBSetOrder(1))//L1_FILIAL + L1_NUM

cNewNum := CriaVar("L1_NUM") //Nova numeração

// Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
cMay := Alltrim(xFilial("SL1"))+cNewNum
FreeUsedCode() //libera codigos de correlativos reservados pela MayIUseCode()

// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
While SL1->(DbSeek(xFilial("SL1")+cNewNum)) .OR. !MayIUseCode(cMay)
	If ++nTent > 20
		Final(STR0004) //#"Impossivel gerar numero sequencial de orcamento correto."
	Endif
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	End
	cNewNum := CriaVar("L1_NUM")
	FreeUsedCode()
	cMay := Alltrim(xFilial("SL1"))+cNewNum
End
While (GetSX8Len() > nSaveSx8)
	ConfirmSX8()
End

//Reposiciona na venda original
SL1->(DBGOTO(nRegNumOrig))

aStruSL1:= SL1->(dbStruct())
aStruSL2:= SL2->(dbStruct())

//****SL1****
For nX := 1 To Len(aStruSL1)
	aAdd(aDadosSL1, { aStruSL1[nX][1], &("SL1->"+aStruSL1[nX][1]) } )
Next nX
nPos := aScan(aDadosSL1, {|x| x[1] == "L1_NUM"} )
aDadosSL1[nPos][2] := cNewNum

//****SL2****
SL2->(DbSetOrder(1)) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
While !SL2->(EOF()) .And. xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM
	aAdd(aDadosSL2,{})
	nLinha := Len(aDadosSL2)
	For nX := 1 To Len(aStruSL2)
		aAdd(aDadosSL2[nLinha], { aStruSL2[nX][1], &("SL2->"+aStruSL2[nX][1]) } )
	Next nX

	nPos := aScan(aDadosSL2[nLinha], {|x| x[1] == "L2_NUM"} )
	aDadosSL2[nLinha][nPos][2] := cNewNum

	SL2->(DbSkip())
EndDo

//Cria o orçamento novo
STFSaveTab("SL1",aDadosSL1,.T.)

For nX := 1 To Len(aDadosSL2)
	STFSaveTab("SL2",aDadosSL2[nX],.T.)
Next nX

SL1->(DBSetOrder(1)) //L1_FILIAL + L1_NUM
SL1->(DBSeek(xFilial("SL1")+cNewNum))
SL2->(DBSetOrder(2)) //L2_FILIAL + L2_NUM
SL2->(DBSeek(xFilial("SL2")+cNewNum))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecovSL4
@description	Limpa o SL4 gravado para venda recuperada
@author			Verejo
@since			07/12/2016
@version		11.80
/*/
//-------------------------------------------------------------------
Static Function STDRecovSL4()
Local cSL4Fil := xFilial("SL4") 

SL4->(DbSetOrder(1)) // L4_FILIAL + L4_NUM
SL4->(DbSeek( cSL4Fil + SL1->L1_NUM))
While !SL4->(EOF()) .And. SL4->(L4_FILIAL + L4_NUM) == cSL4Fil + SL1->L1_NUM
	If SL4->(Reclock("SL4", .F.))
		SL4->(DBDelete())
	EndIf
	SL4->(DBSkip())
End
Return Nil
