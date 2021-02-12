#Include 'Protheus.ch'
#Include "FWBrowse.ch"
#Include "DroVldApro.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroVlApr

Aprovação de Medicamentos sob Receita Médica para Anvisa

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	13/04/2017 
/*/
//------------------------------------------------------------------------------
Template Function DroVlApr()
Local oDlgSelIte			:= Nil
Local aColumns 				:= {}
Local cQuery      			:= ""
Local cAliasTmp				:= GetNextAlias()
Local aArea					:= GetArea()
Local aAreaSX3 				:= SX3->( GetArea() )
Local cColumns 				:= ""
Local aCampos  				:= {}
Local oBrowseUp 			:= nil
Local lRet					:= .T.
Local lRet2					:= .T.

//Campos necessários à aprovação do grid
aCampos    := {"LK9_NOME"	,;
				"LK9_TIPOID",;	//Ver Tabela
				"LK9_NUMID" ,;
				"LK9_ORGEXP",;
				"LK9_UFEMIS",;
				"LK9_NUMORC",;
				"LK9_NUMREC",;
				"LK9_TIPREC",;
	  			"LK9_TIPUSO",;	//1-Humano ou 2-Veterinário
				"LK9_DATARE",;
				"LK9_CODPRO",;
				"LK9_DESCRI",;
				"LK9_QUANT",;
				"LK9_NOMMED",;
				"LK9_NUMPRO",;
				"LK9_CONPRO",;
				"LK9_UFCONS",;
				"LK9_LOTE"  ,;
				"LK9_USVEND"}

//Login de verificação
If !DroRecLogin()
	lRet := .F.
EndIf

IF lRet
	//Montagem da Tela
	DbSelectArea('SX3')
	SX3->( DbSetOrder(1) )                //X3_ARQUIVO + X3_ORDEM
	SX3->( DbSeek("LK9") )
	While SX3->( !EoF() ) .AND. SX3->X3_ARQUIVO == "LK9"
	
	    If AScan(aCampos,AllTrim(SX3->X3_CAMPO)) > 0
	       //cria uma instancia da classe FWBrwColum
	       Aadd( aColumns, FWBrwColumn():New() )
	
	       //se for do tipo [D]ata, faz a conversao para o formato DD/MM/AAAA
	       cX3Campo := AllTrim(SX3->X3_CAMPO)
	       cColumns += (cX3Campo + ",")
	
	       If SX3->X3_TIPO == "D"
				Atail(aColumns):SetData( &("{||StoD(" + cX3Campo + ")}") )
	       Else
				Atail(aColumns):SetData( &("{||" + cX3Campo + "}") )
	       EndIf
	
	       Atail(aColumns):SetSize( SX3->X3_TAMANHO )
	       Atail(aColumns):SetDecimal( SX3->X3_DECIMAL )
	       Atail(aColumns):SetTitle( X3Titulo() )
	       Atail(aColumns):SetPicture( SX3->X3_PICTURE )
	       
			If SX3->X3_TIPO == "N"
				Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
			Else
				Atail(aColumns):SetAlign( CONTROL_ALIGN_LEFT )
			EndIf
	    EndIf
	    
	    SX3->( DbSkip() )
	End        
	RestArea(aAreaSX3)
	RestArea(aArea)
	
	//retira a ultima virgula dos campos da query
	cColumns := Substr(cColumns, 1, Len(cColumns)-1)
	
	cQuery := " SELECT "+cColumns+" FROM "+RetSqlName("LK9")+" LK9 WHERE LK9_FILIAL = '"+xFilial("LK9")+"' AND LK9_USVEND <> '' AND LK9_USAPRO = '' AND LK9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	
	DEFINE MSDIALOG oDlgSelIte TITLE STR0001 From 0,0 To 350+300,600+400 PIXEL //"Aprovação de Medicamentos - ANVISA"
	@ 010,010 SAY STR0002 OF oDlgSelIte COLOR CLR_HBLUE  PIXEL SIZE 250,9 //"Selecione o produto que deverá ser aprovado"
	@ 030,005 TO 130,295 LABEL "" OF oDlgSelIte PIXEL
	
	// Browser Vendas Superior
	oBrowseUp:= FWFormBrowse():New()
	oBrowseUp:SetOwner(oDlgSelIte)
	oBrowseUp:SetColumns( aColumns )
	oBrowseUp:SetDataQuery(.T.)
	oBrowseUp:SetQuery(cQuery)
	oBrowseUp:SetAlias( cAliasTmp )
	
	oBrowseUp:AddButton( OemTOAnsi(STR0004), {|| lRet := .T., DroRecAprovar(oDlgSelIte,LK9_NUMORC,LK9_CODPRO), LjMsgRun(STR0003,,{|| DroRecAtualiza(oBrowseUp,cQuery),CLR_HRED } )},, 2 ) //"Aprovar"		//"Aguarde, atualizando informações..."
	oBrowseUp:AddButton( OemTOAnsi(STR0005), {|| lRet := .T., Iif(DroRecSL1(LK9_NUMORC), lRet2 := ExecTemplate( "LJ7036", .F., .F.,{ LK9_NUMORC, "", "", 0,;	//LK9_DOC,LK9_SERIE
																  LK9_CODPRO	, LK9_QUANT } ),.T.), Iif(lRet2,LjMsgRun(STR0003,,{|| DroRecAtualiza(oBrowseUp,cQuery),CLR_HRED } ),.T.)},, 2 ) //"Alterar"	 //"Aguarde, atualizando informações..."
	oBrowseUp:AddButton( OemTOAnsi(STR0006), {|| lRet := .F., oDlgSelIte:End()},, 2 ) //"Cancelar"
	oBrowseUp:SetDescription( STR0001 )//"Aprovação de Medicamentos - ANVISA"
	oBrowseUp:DisableDetails()
	oBrowseUp:DisableReport()
	
	oBrowseUp:Activate()
	ACTIVATE MSDIALOG oDlgSelIte CENTER
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} DroRecAprovar

Gravo o nome do usuário farmaceutico em LK9_USAPRO

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	13/04/2017 
/*/
//------------------------------------------------------------------------------
Static Function DroRecAprovar(oModel,cNumOrc, cProd)

Local lRet		:= .F.			//Retorno

Default cNumOrc := ""
Default cProd	:= ""                  

If !Empty(cNumOrc) .AND. !Empty(cProd)
	//Gravação do usuário que aprovou a receita
	DbSelectArea("LK9")
	LK9->(DbSetOrder(6))	//LK9_FILIAL+LK9_NUMORC
	//Verifico o produto
	If LK9->(DbSeek(xFilial("LK9")+cNumOrc))
		While !(LK9->(EOF())) .AND. LK9->LK9_NUMORC = cNumOrc
			If LK9->LK9_CODPRO = cProd		//O motivo é que não há indice criado. Utilizei por Filial e número do orçamento. E não há ligação com itens, somente com Cód. Produto
				RecLock("LK9", .F.)
				REPLACE LK9->LK9_USAPRO  WITH cUsername		//Atualizo o nome do Farmaceutico
				LK9->(MsUnLock())
				lRet := .T.
			EndIf
			LK9->(DbSkip())
		EndDo
	EndIf
Else
	MsgAlert( STR0010 )			//"Conteúdo vazio. Somente irá aparecer se há orçamento preenchido e ao menos um item de medicamento controlado."

EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} DroRecAtualiza

Atualiza o primeiro Browser e objetos

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	13/04/2017 
/*/
//------------------------------------------------------------------------------
Static Function DroRecAtualiza(oBrowse, cQuery)

Local cAlias 	:= oBrowse:Alias()

Default cQuery := ""
    
If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf
  
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQuery )
oBrowse:SetAlias(cAlias)
oBrowse:Data():DeActivate()
		
oBrowse:Data():Activate()

oBrowse:Refresh(.T.)
           
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} DroRecLogin

Funcao que valida a autorizacao superior por Cartao ou Senha

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	18/04/2017 
/*/
//------------------------------------------------------------------------------
Static Function DroRecLogin()

Local cAtCodVen	:= __cUserID	//Código do usuário farmaceutico
Local cCodUsVend:= ""			//Variável auxiliar do usuário farmaceutico	
Local lRet := .T.
Local cArea	 := GetArea()

//Verifico se existe o índice 6 de LK9
DbSelectArea("SIX")		
DbSetOrder(1)                              // INDICE + ORDEM
If !SIX->(DbSeek("LK9" + "6"))
	MsgAlert( STR0012 )	//"Favor aplicar os updates U_UPDDRO05 e U_UPDDRO07 para atualizar as informações."
	lRet := .F.
EndIf

If lRet
	// Valida o usuario utilizado na tela
	If !LJProfile(42)  // permissao para manipular remedios controlados (template drogaria). Vermelho " " ou Amarelo "X" não passam. Somente Verde "S"
		lRet := .F. 
		MsgAlert(STR0011)	//"Usuário não é um Farmaceutico. Não poderá efetuar manutenção neste cadastro."
	ElseIf FWAuthUser(@cCodUsVend)		//Tela de Login e Senha
		If !(cAtCodVen == cCodUsVend)
			MsgAlert( STR0007 + CHR(13)+CHR(10)+;			//"O login do usuário deverá ser igual ao logado no Protheus."
					STR0008 + CHR(13)+CHR(10)+;				//"Para a aprovação da receita, digite o mesmo login e sua senha."
					STR0009 )								//"O login do usuário deverá ter privilégios de farmaceutico."
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( cArea )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroRecSL1

Deixa o SL1 ponteirado com o LK9 antes de extrair o T_DRORestAnvisa() dentro do ExecTemplate("LJ7036")

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	18/04/2017 
/*/
//------------------------------------------------------------------------------
Static Function DroRecSL1(cNumOrc)

Local cArea := nil
Local lRet := .F.

If !Empty(cNumOrc)
	cArea := GetArea()
	DbSelectArea("SL1")
	DbSetOrder(1)
	SL1->(DbSeek(xFilial("SL1")+cNumOrc))
	RestArea(cArea)
	lRet := .T.
Else
	MsgAlert(STR0010)		//"Conteúdo vazio. Somente irá aparecer se há orçamento preenchido e ao menos um item de medicamento controlado."
EndIf

Return lRet