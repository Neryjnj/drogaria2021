#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBIMPORTSALE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "STPOS.CH"

Static aCmpsImpL1 := STBImpSFld("SL1")	//Relcacao de campos PADRAO da tabela SL1 utilizaos na importacao de orcamento
Static aCmpsImpL2 := STBImpSFld("SL2")	//Relcacao de campos PADRAO da tabela SL2 utilizaos na importacao de orcamento
Static aCmpsImpL4 := STBImpSFld("SL4")	//Relcacao de campos PADRAO da tabela SL4 utilizaos na importacao de orcamento

Static aSL4Bkp := {} 					//Backup da SL4 importada

Static lPerguntouCPF		:= .F.		//Se por acaso fez a pergunta "Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?" uma vez - STR0007 
Static lRetCPF				:= .F.		//Opção escolhida após a pergunta "Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?" - STR0007 - .T. (Sim) ou .F. (Não)

Static nDescImp				:= 0 
//-------------------------------------------------------------------
/*/{Protheus.doc} STBISSearchOptions
Busca Opções de orcamento em outro ambiente

@param1   nOption				Opcao de busca
@param2   cField				Campo utilizado para busca
@param3   cFieldAssigned		Conteúdo do campo para busca
@param4   lSearchAll			Define se perquisa todos ( Redução Z do PAF )
@param5   aFieldsAdd			Campos adicionais a serem buscados
@param6   dDataMov				Data do movimento a realizar a Busca PAFECF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]				lUserSelect 	- Retorna se deve ser selecionada opção de orçamento
@return  aRet[2]				aOptionSales	- Array com as opções de orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBISSearchOptions( 	nOption 	 , cField , cFieldAssigned , lSearchAll , ;
									aFieldsAdd , dDataMov	)
									
Local lUserSelect		:= .F.			// Define se usuário deve selecionar orçamento
Local aOptionSales		:= {}			// Opções de orçamento buscadas da retaguarda
Local lContinue			:= .T.			// Fluxo lógico função
Local ni 				:= 1			// Variavel de loop
Local cNomeCli			:= ""			// Nome do cliente
Local nVlrTot			:= 0			// Valor do orçamento importado

Default nOption				:= 0
Default cField				:= ""
Default cFieldAssigned		:= ""
Default lSearchAll			:= .F.
Default aFieldsAdd			:= {}
Default dDataMov				:= dDataBase


/*/
	OBS: Para pesquisa pelo campo, a premissa eh que eh pesquisa de usuário, sendo assim nao contempla Redução Z do PAF (LOJA160)
	Para comtemplar, deve ser passado parâmetro TODOS ou DATA
/*/

LjGrvLog("Importa_Orcamento:STBISSearchOptions","nOption :", nOption)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","cField  :", cField)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","cFieldAssigned:  ", cFieldAssigned)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","aFieldsAdd:      ", aFieldsAdd)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","lSearchAll:      ", lSearchAll)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","aFieldsAdd:      ", aFieldsAdd)
LjGrvLog("Importa_Orcamento:STBISSearchOptions","dDataMov:        ", dDataMov)

Do Case

	Case nOption == 1		// Pelo campo

		/*/
			Para Pesquisa por numeração, chamar importação direto
		/*/
		If cField == "L1_NUM" .OR. cField == "L1_NUMORC"
		
			LjGrvLog("Importa_Orcamento:STBISSearchOptions","Chama rotina remoto: STBISGetOp")
			lContinue := STBRemoteExecute( 	"STBISGetOp" 																, ;
												{ nOption , cField , cFieldAssigned , Nil , Nil , aFieldsAdd } 	, ;
												NIL 																		, ;
												.F.																			, ;
												@aOptionSales																)
												
			LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno lContinue    :", lContinue)
			If !lContinue
				LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno aOptionSales :", aOptionSales)
			EndIf
			
			 // Percorre array para pegar os dados do cliente e valor para apresentar na tela de importação
			 While ni <= LEN(aOptionSales)
			 
			 	If StrZero(Val(cFieldAssigned),TamSX3(cField)[1]) == aOptionSales[ni][1]
			 		cNomeCli := aOptionSales[ni][3]
			 		//"Atribuindo ao Valor total da venda o valor do acréscimo e do desconto((L1_VLRTOT + L1_VLRJUR) - L1_DESCONT) "
					nVlrTot  := STBArred( aOptionSales[ni][4] )

			 	EndIf	 	
			 	ni++
			 EndDo		 

			lUserSelect := .F. // Nao precisa de seleção	
			
		/*/
			Para Pesquisa por cliente ou por algum outro campo do SL1, pode existir mais de 1 orcamento, pesquisar opções e depois importar
		/*/
		ElseIf Subst( cField, 1, 2 ) == "A1" .OR. Subst( cField, 1, 2 ) == "L1"
		
			LjGrvLog("Importa_Orcamento:STBISSearchOptions","Chama rotina remoto: STBISGetOp")
			lContinue := STBRemoteExecute( 	"STBISGetOp" 																, ;
												{ nOption , cField , cFieldAssigned , Nil , Nil , aFieldsAdd } 	, ;
												NIL 																		, ;
												.F.																			, ;
												@aOptionSales																)
			
			LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno lContinue    :", lContinue)
			
			If !lContinue
				LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno aOptionSales :", aOptionSales)
				STFMessage("STImportSale","STOP", STR0001) //"Não foi possível estabelecer conexão."
				STFShowMessage("STImportSale")
				LjGrvLog("Importa_Orcamento:STBISSearchOptions", STR0001)	//"Não foi possível estabelecer conexão."
			EndIf
			
			If lContinue
				  
		
				If Len(aOptionSales) == 0
				
					/*/
						Mensagem
					/*/
					If Subst( cField, 1, 2 ) == "A1"
						STFMessage("STImportSale","STOP",STR0002) //"Nao foi encontrado orcamento em aberto para este cliente"
						LjGrvLog("Importa_Orcamento:STBISSearchOptions", STR0002)	//"Nao foi encontrado orcamento em aberto para este cliente"
					Else
						STFMessage("STImportSale","STOP",STR0003) //"Nao foi encontrado orcamento em aberto"
						LjGrvLog("Importa_Orcamento:STBISSearchOptions", STR0003)	//"Nao foi encontrado orcamento em aberto"
					EndIf
					
					STFShowMessage("STImportSale")				
					lContinue := .F.
				EndIf
			EndIf
			
			If lContinue			
				If Len(aOptionSales) > 1					
					lUserSelect := .T. // Indica que devem ser selecionados os orçamentos a importar											
				Else
					If cField $ "A1_CGC/L1_NUM/L1_NUMORC"
						lUserSelect := .F. // Retornou apenas 1 orçamento, importar direto, sem seleção
					Else
						lUserSelect := .T.
					EndIf
				EndIf				
			EndIf
			
		EndIf	
		
	Case nOption == 2	.OR. nOption == 3 	// 2 - Todos ; 3 - Data
		
		/*/
			Buscar opcoes de orcamentos
		/*/
		LjGrvLog("Importa_Orcamento:STBISSearchOptions","Chama rotina remoto: STBISGetOp")
		lContinue := STBRemoteExecute(	"STBISGetOp"																						, ;
											{ nOption , NIL , NIL , STFGetCfg("lPafEcf") , lSearchAll , aFieldsAdd ,dDataMov } 	, ;
											NIL																									, ;
											 .F. 																								, ;
											 @aOptionSales 																					)

		LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno lContinue    :", lContinue)
		If lContinue 
			While ni <= LEN(aOptionSales)
				//"Atribuindo ao Valor total da venda o valor do acréscimo e do desconto((L1_VLRTOT + L1_VLRJUR) - L1_DESCONT) "
				nVlrTot  := STBArred( aOptionSales[ni][4] )
				aOptionSales[ni][4]	:= nVlrTot	 	
				ni++
			EndDo	
		EndIF
		
		If !lContinue
			LjGrvLog("Importa_Orcamento:STBISSearchOptions","Parâmetro de retorno aOptionSales :", aOptionSales)
			STFMessage("STImportSale","STOP",STR0001) //"Nao foi possivel estabelecer conexão."
			STFShowMessage("STImportSale")	
			LjGrvLog("Importa_Orcamento:STBISSearchOptions", STR0001)	//"Não foi possível estabelecer conexão."
		EndIf
		
		If lContinue
			If ValType(aOptionSales) <> "A" .OR. Len(aOptionSales) == 0
				STFMessage("STImportSale","STOP", STR0003 ) //"Nao foi encontrado orcamento em aberto"
				STFShowMessage("STImportSale")	
				LjGrvLog("Importa_Orcamento:STBISSearchOptions", STR0003)	//"Nao foi encontrado orcamento em aberto"
				aOptionSales := {}
				lContinue := .F.	
			EndIf
		EndIf	
												
		lUserSelect := .T. // Indica que orçamento precisa ser selecionado														
		
EndCase

aRet := { lUserSelect , aOptionSales }
If Len(aRet) = 0
	LjGrvLog("Importa_Orcamento:STBISSearchOptions", "Parâmetro de retorno aRet : Conteúdo vazio." )
EndIf

Return aRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISGetOptions
Busca de opções orcamentos a serem importados

@param   nOption				Opcao de busca
@param   cField				Campo utilizado para busca
@param   cFieldAssigned		Conteúdo do campo para busca
@param   lIsPafPdv		Indica se o PDV que solicitou eh PAF
@param   lSearchAll		Indica se pesquisa
@param   aFieldsAdd			Campos adicionais a serem buscados
@param   dDataMov				Data do movimento a realizar a Busca PAFECF 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aOptions				Retorna opções de orcamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBISGetOptions( 	nOption 		, cField 		, cFieldAssigned , lIsPafPdv		, ;
								lSearchAll		, aFieldsAdd	, dDataMov								)
										
Local aOptions				:= {}				// Retorno funcao

Default nOption				:= 0
Default cField				:= ""
Default cFieldAssigned		:= ""
Default lSearchAll			:= .F.
Default aFieldsAdd			:= {}
Default dDataMov				:= dDataBase

LjGrvLog("Importa_Orcamento:STBISGetOptions","Comunicação OK")
LjGrvLog("Importa_Orcamento:STBISGetOptions","nOption :", nOption)
LjGrvLog("Importa_Orcamento:STBISGetOptions","cField  :", cField)
LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro cFieldAssigned: ", cFieldAssigned)
LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro lIsPafPdv:      ", lIsPafPdv)
LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro lSearchAll:  	", lSearchAll)
LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro aFieldsAdd: 	", aFieldsAdd)
LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro dDataMov: 		", dDataMov)

Do Case

	Case nOption == 1 // Busca Pelo Campo

		If !Empty(cField) .AND. !Empty(cFieldAssigned)
			
			If Subst( cField, 1, 2 ) == "A1" .OR. Subst( cField, 1, 2 ) == "L1"
			
				LjGrvLog("Importa_Orcamento:STBISGetOptions","Chama rotina: STDISGetFieldOptions")
				aOptions := STDISGetFieldOptions( cField , cFieldAssigned , aFieldsAdd )
		
			EndIf
		
		EndIf
		
	Case nOption == 2 .OR. nOption == 3
		
		LjGrvLog("Importa_Orcamento:STBISGetOptions","Chama rotina: STDISGetOptions")
		aOptions := STDISGetOptions( nOption , lIsPafPdv , lSearchAll , aFieldsAdd , dDataMov )
		
EndCase

If Len(aOptions) = 0
	LjGrvLog("Importa_Orcamento:STBISGetOptions","Parâmetro de retorno aOptions: Conteúdo vazio.")
EndIf

Return aOptions


//-------------------------------------------------------------------
/*/{Protheus.doc} STBImportRemote
Busca do Orcamento em outro ambiente

@param   cField				Campo utilizado para busca
@param   cFieldAssigned		Conteúdo do campo para busca
@param   lValDate				Indica se valida data de vencimento do orcamento
@Param 	lPafEcf				Usa PAfecf
@Param   lGetOrcExpired     Pega orcamentos expirados PafECF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSale			
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBImportRemote( 	cField 		, cFieldAssigned , lValDate , lPafEcf , ;
								lGetOrcExpired ) 

Local aArea			:= GetArea()	// Armazena alias corrente
Local aSale			:= {}			// Retorno da funcao
Local aSL1			:= {}			// Armazena SL1
Local aSL2			:= {}			// Armazena SL2
Local aSL4			:= {}			// Armazena SL4
Local lContinue		:= .T.			// Fluxo lógico funcao
Local cPAFType		:= ""			// Se DAV ("D") ou PRE-VENDA ("P")
Local cSL1Status	:= ""			// Armazena STATUS
Local nI			:= 0			// Contador
Local nL1_NUM		:= 0			// Armazena posicao do L1_NUM
Local aRetCred      := {}			// Array com as informações  da Avaliação de Crédito 
Local cCredLj   	:= SuperGetMV( "MV_CREDLJ",,"N")// Indica se deve ser feita a Análise de Crédito do Cliente 
Local lSTVLDIMP     := ExistBlock("STVLDIMP") 
Local lSL1Locked	:= .F. 			

Default cField			:= ""
Default cFieldAssigned	:= ""
Default lValDate			:= .T.
Default lPafEcf			:= .F.    
Default lGetOrcExpired	:= .F.

ParamType 0 Var 	cField 			As Character	Default ""	
ParamType 1 Var  	cFieldAssigned	As Character	Default ""
ParamType 2 Var 	lValDate 			As Logical		Default .T.

lContinue := !Empty(cField) .AND. !Empty(cFieldAssigned)      

LjGrvLog("Importa_Orcamento:STBImportRemote","Comunicação OK")
LjGrvLog( " 01 - Importação do PDV", "Campo " + cField + ", cFieldAssigned = " + cFieldAssigned, Nil )

If !lContinue
	AADD( aSale , "NOTFOUND" )
EndIf

If lContinue
	Do Case
		Case cField == "L1_NUM"
			LjGrvLog( " 02  - Importação do PDV", "aSale", Nil )	
			LjGrvLog("Importa_Orcamento:STBImportRemote","Chama rotina: STDISSL1Get")
			aSL1 := STDISSL1Get( cFieldAssigned, @lSL1Locked )
			
			If Len(aSL1) == 0
				lContinue := .F.
				AADD( aSale , "NOTFOUND" )
				LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSL1: Conteúdo vazio")
			EndIf
					
		Case cField == "L1_NUMORC"
		
			If SuperGetMv("MV_LJPRVEN",,.T.)
				cPAFType := "P"
			Else
				cPAFType := "D"
			EndIf
			
			LjGrvLog("Importa_Orcamento:STBImportRemote","Chama rotina: STDISPafSL1Get, cPafType = ", cPafType)
			aSL1 := STDISPafSL1Get( cFieldAssigned , cPAFType )
			
			LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSL1: ", aSL1)
			
			If Len(aSL1) == 0
				lContinue := .F.
				AADD( aSale , "NOTFOUND" )
				LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSL1: Conteúdo vazio")
			EndIf
			
		Otherwise
			
			lContinue := .F.
				
	EndCase
			
		If lContinue
		
			/*/
				Validacoes
			/*/
			LjGrvLog("Importa_Orcamento:STBImportRemote","Monta SL1")
			LjGrvLog("Importa_Orcamento:STBImportRemote","Chama rotina: STBISValSL1")
			
			cSL1Status := STBISValSL1( aSL1 , lValDate ) 
			
			LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno cSL1Status: ", cSL1Status)
			      
			//Verifica se esta solicitando orcamentos vencidos
			If cSL1Status == "EXPIRADO" .AND. lGetOrcExpired
				lContinue 	:= .T.  
				cSL1Status 	:= ""
			ElseIf !Empty(cSL1Status)
				AADD( aSale , cSL1Status ) 
				lContinue := .F.
				LjGrvLog("Importa_Orcamento:STBImportRemote","Adicionado conteúdo de cSL1Status em aSale e não irá continuar.")
			EndIf
			
			If lContinue
				nL1_NUM := AScan( aSL1 , { |x| x[1] == "L1_NUM" } ) // Armazena posicao L1_NUM
			EndIf
				
			LjGrvLog("Importa_Orcamento:STBImportRemote","Posição L1_NUM: ", nL1_NUM)
			
			/*/
				Monta SL2
			/*/
			If lContinue
			
				LjGrvLog("Importa_Orcamento:STBImportRemote","Monta SL2")
				LjGrvLog("Importa_Orcamento:STBImportRemote","Chama rotina: STDISSL2Get")
				LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro aSL1[nL1_NUM][2]: ", aSL1[nL1_NUM][2])
				LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro lPafEcf: ", lPafEcf)
				
				aSL2 := STDISSL2Get( aSL1[nL1_NUM][2] , lPafEcf )
								
				/*/
					Valida estoque
				/*/
				If !( STBISValStock( aSL2 ) )
					lContinue := .F.
					AADD( aSale , "SEMESTOQUE" )						
					LjGrvLog("Importa_Orcamento:STBImportRemote","Adicionado SEMESTOQUE em aSale e não irá continuar: aSL2 vazio.")
					
				EndIf

			EndIf
			
			/*/
				Monta SL4
			/*/
			If lContinue
			
				LjGrvLog("Importa_Orcamento:STBImportRemote","Monta SL4")
				LjGrvLog("Importa_Orcamento:STBImportRemote","Chama rotina: STDISSL4Get")
				LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro aSL1[nL1_NUM][2]: ", aSL1[nL1_NUM][2])

				aSL4 := STDISSL4Get( aSL1[nL1_NUM][2] )

				If Len(aSL4) = 0
					LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSL4: Conteúdo vazio.")
				EndIf
				
			EndIf
			
			/*/
			AVALIA CREDITO DO CLIENTE
			/*/
			If cCredLj == "S"
				aRetCred  := STBISValCred(2, aSL1 , aSL2 , aSL4)//2 - Salvar como Venda
				If !aRetCred[1]
					
					AADD( aSale , "SEMCREDITO" )
					lContinue := aRetCred[1]
				Endif
			Endif	
			
			If lSTVLDIMP
				LjGrvLog("Importa_Orcamento:STBImportRemote","Antes da chamada do Ponto de Entrada: STVLDIMP",lContinue)
				lContinue := ExecBlock( "STVLDIMP",.F.,.F.,{aSL1,aSL2,aSL4})
				LjGrvLog("Importa_Orcamento:STBImportRemote","Depois da chamada do Ponto de Entrada: STVLDIMP",lContinue)
				If !lContinue
					AADD( aSale , "BLOCKPE" )
				EndIf 
			EndIf 	
			/*/
				Tratamento do retorno
			/*/
			If lContinue	// Indica que deve ser retornado o orcamento (tudo certo)
				If Len(aSale) == 0 // Nenhum STATUS atribuído
					If lSL1Locked
						AADD( aSale , "SL1LOCK" )
					Else 
						AADD( aSale , "OK" )
					Endif 
					AADD( aSale , { aSL1 , aSL2 , aSL4  } )					
				Else
					AADD( aSale , { aSL1 , aSL2 , aSL4  } )
				EndIf 
			Else
				If Len(aSale) == 0
					AADD( aSale , "ERROR" )
					LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSale: Conteúdo vazio. (ERROR)")
				EndIf
			EndIf			
						
		EndIf
EndIf

If Len(aSale) = 0
	LjGrvLog("Importa_Orcamento:STBImportRemote","Parâmetro de retorno aSale: Conteúdo vazio.")
EndIf

Return aSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISValSL1
Valida orcamento a ser importado

@param   aSL1					Array com a estrutura do SL1. Bidimencional: Campo, Valor
@param   lValDate				Indica se valida a data limite
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cStatus				Retorna oStatus do orcamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISValSL1( aSL1 , lValDate )

Local cStatus				:= "" 		//Status
Local dL1_DTLIM 			:= cToD("  /  /  ")

Default aSL1				:= {}
Default lValDate			:= .T.

ParamType 0 Var 	aSL1 			As Array		Default {}
ParamType 1 Var 	lValDate		As Logical		Default .T.	

If Len(aSL1) > 0
	
	dL1_DTLIM := aSL1[AScan( aSL1 , { |x| x[1] == "L1_DTLIM" } )][2]
	If ValType(dL1_DTLIM) == "C"
		dL1_DTLIM := SToD( dL1_DTLIM )
	EndIf
	
	Do Case
		Case !Empty(AllTrim(aSL1[AScan( aSL1 , { |x| x[1] == "L1_DOC"  } )][2])) .OR. !Empty(AllTrim(aSL1[AScan( aSL1 , { |x| x[1] == "L1_DOCPED" } )][2]))
			
			cStatus := "VENDIDO"
			
		
		Case !STBVldImp(aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" } )][2])	// Arquivo de controle de orcamento
			//Esta validacao tem que vir sempre antes da validacao do orcamento expirado Expirado
			cStatus := "JAIMPORTADO" 	
			
		Case lValDate .AND. ( dL1_DTLIM  < dDataBase )
		
			cStatus := "EXPIRADO"
			
			
	EndCase
	
EndIf

LjGrvLog("Importa_Orcamento:STBISValSL1","Parâmetro de retorno cStatus: ", cStatus)

Return cStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldImp
Valida se o arquivo referente ao orcamento importado ja existe

@param   cNumOrc				numero do orçamento
@author  Varejo
@version P11.8
@since   29/03/2013
@return  lRet				Retorna Validacao
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STBVldImp( cNumOrc )	  
 
Local lRet      := .T.                         	//Retorno da funcao. Se .T. nao foi importado ainda
Local cPatchOrc 	:= ""    								//Arquivo do orcamento importado 
Local cArqTemp  	:= ""					          	//Arquivo para testar se existe a pasta "\AUTOCOM\IMP" + cEmpAnt + cFilAnt
Local nHandle   	:= 0 			                  	//Handle do arquivo
Local cDirLog  	:= ""									// Diretorio para o LOG

cDirLog  := "\AUTOCOM\IMP" + StrTran(cEmpAnt + cFilAnt ," ","")+ "\"

cPatchOrc 	:= cDirLog + cNumOrc + ".TXT"
cArqTemp  	:= cDirLog + "TEMP.TMP"  

If !File( cArqTemp )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\IMP" + cEmpAnt + cFilAnt )
	nHandle := FCreate( cArqTemp )
	FClose( nHandle )	
Endif

If File( cPatchOrc )
   lRet  := .F.
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCtrImpOrc
Cria arquivo de controle no server para saber se orcamento 
ja foi importado. O objetivo e nao permitir importar mais de uma vez	

@param   cNumOrc				numero do orçamento
@param   lVerifica 		   Controla se faz apenas a verificacao da existencia do arquivo na Retaguarda
@author  Varejo
@version P11.8
@since   29/03/2013
@return  lRet				Retorna Validacao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCtrImpOrc(cNumOrc, cPDV , lVerifica, lTotvsPdv, lValidRet)

Local aRet      	:= {}                	//Retorna numero dos orcamentos que nao gravaram o arquivo (erro)   
Local nX        	:= 0                 	//Controle de loop
Local cCRLF	    	:= Chr(13) + Chr(10) 	//Controle de linha
Local cMsg      	:= ""                	//Mensagem dos orcamentos com erro na criacao do arquivo na RET
Local lRet  			:= .T.						//Retorno
Local lContinua  	:= .F.						//Controle de execucao
Local aOrcsImp		:= {}						//Array de orcamentos a confirmar

Default cNumOrc  	:= ""						//Numero do Orcamento para criar arquivo de conttole	
Default cPDV  		:= ""						//Numero do PDV gravado no SL2->L2_PDV
Default lVerifica := .F. 					//Controla se faz apenas a verificacao da existencia do arquivo na Retaguarda
Default lTotvsPdv	:= .F.						//E totvs pdv?
Default lValidRet   := .F.                  //Validar arquivo .RET na Retaguarda

If !Empty(cNumOrc) 
	
	AADD(aOrcsImp , { cNumOrc , cPDV } )
	
	//Atualizando status do orcamento
	LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Chama rotina remoto: FR271HArq")
	LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Parâmetro aOrcsImp:  ",aOrcsImp)
	LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Parâmetro lVerifica: ",lVerifica)
	LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Parâmetro lTotvsPdv: ",lTotvsPdv)
	lContinua := STBRemoteExecute( "FR271HArq" , { aOrcsImp , lVerifica, Nil, lTotvsPdv, lValidRet }, Nil, .F. , @aRet )
	LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Parâmetro de retorno lContinua: ",lContinua)
	If !lContinua
		LjGrvLog("Importa_Orcamento:STBCtrImpOrc","Parâmetro de retorno aRet: ",aRet)
	EndIf
	
	If lContinua
	
		If ValType(aRet) <> "A"
			aRet := {}	//Volta array pra nao dar erro
			CONOUT("ERRO NO RETORNO DA CONEXÃO ARQUIVO DE CONTROLE ORCAMENTO. STBCtrImpOrc: ")
			CONOUT(cNumOrc + cPDV)
			LjGrvLog("Importa_Orcamento:STBCtrImpOrc","ERRO NO RETORNO DA CONEXÃO ARQUIVO DE CONTROLE ORCAMENTO. STBCtrImpOrc: ", cNumOrc + cPDV)
			If lVerifica
				CONOUT("lVerifica = .T.")
			Else
				CONOUT("lVerifica = .F.")
			EndIf
			If lTotvsPdv
				CONOUT("lTotvsPdv = .T.")
			Else
				CONOUT("lTotvsPdv = .F.")
			EndIf
		EndIf
	
	    If !lValidRet .And. !lVerifica
	       //Se foi criado arquivo .TXT, apaga o arquivo .RET
	       //Todo controle passa para o arquivo .TXT
	       STBRemoteExecute( "FR271HArq" , { aOrcsImp , lVerifica, .T., lTotvsPdv, .T. }, Nil, .F. , @aRet )
	       
	       If ValType(aRet) <> "A"
               aRet := {}  //Volta array pra nao dar erro
           EndIf
	    EndIf
	EndIf
	
EndIf             

//Apresenta mensagem se houve erro na criacao do arquivo de algum orcamento importado
If lContinua .AND. Len(aRet) > 0 .AND. !lTotvsPdv

    For nX := 1 to Len(aRet)    
       cMsg += aRet[nX] + "\" 
    Next nX
    cMsg  := Substr(cMsg, 1, Len(cMsg) - 1)
    
    lRet := .F.
    
    If lVerifica
    	STFMessage("STBIMPORTSALE","POPUP", STR0004)	//"Não é possível finalizar a venda, este orçamento já foi finalizado por outro PDV."
		STFShowMessage("STBIMPORTSALE")
		LjGrvLog("Importa_Orcamento:STBCtrImpOrc", STR0004)	//"Não é possível finalizar a venda, este orçamento já foi finalizado por outro PDV."
    Else
    	STFMessage("STBIMPORTSALE","POPUP", STR0005 + cCRLF + ;//Nao foi possivel criar um ou mais arquivos referentes a importacao do orcamento."
	             								STR0006 + cMsg)	//"Orcamentos: "
		STFShowMessage("STBIMPORTSALE")
		LjGrvLog("Importa_Orcamento:STBCtrImpOrc", STR0005 + " - " + STR0006 + cMsg)	//Nao foi possivel criar um ou mais arquivos referentes a importacao do orcamento."###"Orcamentos: "
    EndIf
    
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISValStock
Valida estoque na importaçao de orçamento

@param   aSL2					Array com a estrutura do SL2. Bidimencional: Campo, Valor
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna a validacao do estoque dos itens
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISValStock( aSL2 )

Local aArea 				:= GetArea()		// Armazena alias corrente
Local lRet				:= .T.				// Retorno da funcao
Local nI					:= 0 				// Contador
Local nX					:= 0				// Contador
Local nL2_RESERVA		:= 0	   			// Posição da reserva no array
Local aItensConsult		:= {}	   			// Itens a consultar estoque
Local lValThisItem		:= .F.		   		// Define se avalia estoque para esse item
Local lItemIncluded		:= .F.		   		// Define se o item ja foi incluido no array
Local nL2_ENTREGA 		:= 0 	   			// Posição do campo L2_ENTREGA no array 


Default aSL2				:= {}

ParamType 0 Var 	aSL2 			As Array		Default {}

If Len(aSL2) > 0
	If SuperGetMV( "MV_LJESTOR"	, , .F. ) .AND. ( SuperGetMV( "MV_ESTNEG" , , "S" ) == "N" )  
	
		nL2_RESERVA := AScan( aSL2[1] , { |x| x[1] == "L2_RESERVA"	} 	)	
		nL2_ENTREGA := AScan( aSL2[1] , { |x| x[1] == "L2_ENTREGA"	} 	)	
		//		Armazena os produtos a serem avaliados estoque
		For nI := 1 To Len(aSL2)
		       
			lValThisItem := .F.
			
			If Empty(aSL2[nI][nL2_RESERVA][2]) .AND. !aSL2[nI][nL2_ENTREGA][2] == "5" //pedido entrega sem reserva não valida estoque
			   
			   lValThisItem 	:= .T.
			    
				lItemIncluded	:= .F.
				
				For nX := 1 To Len(aItensConsult)
			   
			   	   If  			AllTrim(aItensConsult[nX][1]) == AllTrim(aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_PRODUTO"		} 	)][2]) 	;
			   	   		.AND.	AllTrim(aItensConsult[nX][2]) == AllTrim(aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_LOCAL"		} 	)][2])	
			   	       	
			   	       	lItemIncluded	:= .T.
			   	   		nItemIncluded 	:= nX
			   	   		Exit     
			   	   
			   	   EndIf		      
			   
			   Next nX	   
			   
			EndIf
			
			If lValThisItem
			
				If lItemIncluded 
				
					aItensConsult[nItemIncluded][4] += aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_QUANT"	} 	)][2]
				
				Else 
	
					AADD( aItensConsult	,	{															   			;
											aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_PRODUTO"	} 	)][2]	,	;
											aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_LOCAL"		} 	)][2]	,	;
											aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_TES"		} 	)][2]	,	;
											aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_QUANT"		} 	)][2]	} 	)	
											
				EndIf
			
			EndIf	     
		
		Next nI
		
		// Avaliar estoque
		For nI := 1 To Len(aItensConsult)
		     
			DbSelectArea("SF4")
			DbSetOrder(1)
			If DbSeek( xFilial("SF4") + aItensConsult[nI][3] )
				If SF4->F4_ESTOQUE == "S"
				
					// Valida SB2
					DbSelectArea("SB2")
					DbSetOrder(1)
	
					If DbSeek( xFilial("SB2") + aItensConsult[nI][1] + aItensConsult[nI][2] )
	
						If ((SB2->B2_QATU - SB2->B2_RESERVA) <= 0) .OR. ((SB2->B2_QATU - SB2->B2_RESERVA) < aItensConsult[nI][4]) 
						
							lRet := .F.
							Exit
							
						EndIf   
						
					Else
						lRet := .F.
					EndIf
					
				EndIf
			EndIf
			
		Next nI	
		
	Else
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)

LjGrvLog("Importa_Orcamento:STBISValStock", "Parâmetro de retorno lRet: ",lRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBImportSale
Adiciona as informações do orçamento na estrutura da venda

@param1   aSale					Array com a estrutura do orçamento: L1, L2 e L4
@Param2   lCancel				Cancela orcamento apos importar Pafecf  
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se importou orçamento com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBImportSale( aSale , lCancel )
Local lRet				:= .T.				// Retorno da função
Local lCpfRet			:= .F.				// Retorno da função STWInfoCNPJ()
Local aSL1				:= {}				// Cabeçalho
Local aSL2				:= {}				// Itens
Local aSL4				:= {}				// Pagamentos
Local aItem             := {}				// Informacoes do item
Local nTotalSale		:= 0				// Valor total da venda
Local oTotal 			:= STFGetTot()		// Recebe o Objeto total
Local cCliCode			:= ""				// Codigo Cliente
Local cCliStore			:= ""				// Loja Cliente
Local cCliType			:= ""				// Tipo do cliente	
Local cNumOrig			:= ""				// Numeração do orçamento original vindo da retaguarda
Local nI				:= 0				// Contador
Local nX				:= 0
Local nY				:= 0				// Contador 
Local nNextItem			:= 0				// Próximo item 
Local lItemFiscal 		:= .T.				// Indica se o Item eh fiscal, vai para o cupom fiscal
Local lItemRegister		:= .T.				// Indica se registrou o item
Local nL2_PRODUTO		:= 0				// Posição
Local nL2_VALDESC		:= 0				// Posição
Local nL2_TES			:= 0				// Posição
Local nL2_PRCTAB		:= 0				// Posição
Local nL2_QUANT			:= 0				// Posição
Local nL2_CODBAR		:= 0				// Posição
Local nL2_ITEMGAR		:= 0				// Posição L2_ITEMGAR
Local nL2_KIT			:= ""				// Posição Código do kit de produto utilizado
Local oCliModel			:= NIL				//Model do Cliente
Local lIsRetPost		:= .F. 				// Identifica se é finalizacao de venda de orcamento somente com itens de "RETIRA POSTERIOR", para imprimir o Cupom  Fiscal e Finalizar. 
Local cFilRes			:= "" 				// Filial do Orcamento da reserva
Local cOrcRes			:= "" 				// Codigo do Orcamento da reserva
Local cPedRes			:= ""				// Codigo do Pedido da reserva
Local lFinServ			:= SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local aAcres			:= {} 				// array que contera os valoresde acrescimo na importacao  
Local cCondPg			:= ""
Local lStImpSale      	:= ExistBlock("STIMPSALE")
Local xStImpSale							// Retorno do ponto de entrada STIMPSALE (pode ser Logico ou Array)
Local lStImpField		:= ExistBlock( "STIMPFIELD") // PE para importação de campos customizados da SL1 e SL2 
Local aStImpField		:= {}				// Retorno do ponto de entrada STIMPFIELD
Local aSL1PE			:= {}				// campos customizados da tabela SL1
Local aSL2PE			:= {}				// campos customizados da tabela SL2
Local nPos				:= 0
Local lRegistrou		:= .F.
Local cVendedor 		:= ""
Local cCodProdReg		:= ""							//Codigo do produto a ser registrado (codigo ou codigo de barras)
Local oVendModel		:= Nil
Local cCodItemGar		:= ""							//Código do Item de Garantia Vinculada
Local lInfoCNPJ			:= .F.							//Verifica se deverá enviar o CNPJ na abertura do cupom, valida parametro MV_LJDCCLI para permitir alterar CNPJ de orcamento importado
Local nCallCPF			:= SuperGetMV("MV_LJDCCLI",,0)	//O momento onde será mostrado o CPF na tela
Local nScanJuros		:= 0 							//Variavel de controle para o  aScan
Local nScanVLJur		:= 0 							//Variavel de controle para o  aScan
Local nDescTot			:= 0							//Valor de Desconto Total do Orcamento
Local nPercDesc			:= 0							//Percentual de Desconto Total do Orcamento
Local nTotOrc 			:= 0							//Valor Total do Orcamento
Local aDiscount			:= {} 							//Array com Valor e Percentual de Desconto concedido no Total do Orcamento
Local nDescProp			:= 0							//Valor do Desconto Proporcionalizado no item
Local nDecDesc 			:= TamSX3("L2_VALDESC")[2]		//Qtde de Casas decimais desconto no item
Local nVlrDescIt		:= 0							//Valor do desconto no Item
Local nDesTotProp		:= 0
Local lImportSale		:= .T.
Local lZeraPay 			:= .F.							// Indica se é para zerar os pagamentos
Local lPosCrd			:=	CrdxInt(.F.,.F.) .AND. ExistFunc("STBSetCrdIdent")	// Ativa Integração TOTVSPDV x SIGACRD
Local cCgcCart			:= ""							// Cartão para SIGACRD
Local cIndPres			:= ""
Local cTransp			:= ""
Local nPosL1INDP		:= 0							// Posição do campo L1_INDPRES no array aSL1[] , caso não existir o campo na RET não terá essa posição. 
Local cMatricula 		:= ""							//Matricula do cliente no caso de Convênio (Template Drogaria)

Default aSale			:= {}

/*/
	Valida se o orçamento passado contém cabeçalho, itens e pagamento
/*/
lRet := Len(aSale) > 0 .AND. Len(aSale[1]) > 0 .AND. Len(aSale[2]) > 0 .AND. Len(aSale[3]) > 0
If lRet
	aSL1 := aSale[1]
	aSL2 := aSale[2]
	aSL4 := aSale[3]
	
	//Faço Backup para uso posteriormente na finalização do pagamento
	aSL4Bkp := aSL4 
	
	nTotOrc 	:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_VLRTOT" } )][2] + aSL1[AScan( aSL1 , { |x| x[1] == "L1_DESCONT"} )][2]
	nDescTot 	:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_DESCONT"} )][2] + aSL1[AScan( aSL1 , { |x| x[1] == "L1_DESCFIN" } )][2] 
	nDesTotProp := nDescTot

	aDiscount	:= STBDiscConvert( nDescTot , "V" , nTotOrc )
	nDescTot	:= aDiscount[1]
	nPercDesc	:= aDiscount[2]

	nTotalSale 	:= oTotal:GetValue("L1_VLRTOT") + nTotOrc
	
	STBSetDscImp(STBGetDscImp() + nDescTot )

	LjGrvLog("Importa_Orcamento:STBImportSale","Valor total do orçamento:"+cValToChar(nTotalSale))
Else
	LjGrvLog("Importa_Orcamento:STBImportSale",">>> NC <<< Nao contem dados completos. aSale:",aSale)
EndIf

/*/
	STIMPSALE - Ponto de Entrada para validar a importação do orçamento
/*/
If lStImpSale
	
	LjGrvLog("Importa_Orcamento:STBImportSale","Antes da chamada do Ponto de Entrada: STIMPSALE", {aSL1,aSL2,aSL4})
	xStImpSale := ExecBlock( "STIMPSALE",.F.,.F.,{aSL1,aSL2,aSL4})
	LjGrvLog("Importa_Orcamento:STBImportSale","Apos a chamada do Ponto de Entrada: STIMPSALE", xStImpSale)
	If ValType(xStImpSale) == "L"
		lRet := xStImpSale		

	ElseIf ValType(xStImpSale) == "A"	
		Aviso(	"STIMPSALE", "O ponto de entrada STIMPSALE será descontinuado para importação de campos customizados no orçamento." +;
				"Por favor, utilize o ponto de entrada STIMPFIELD para esse propósito." ,;				
				{"OK"}, 3 )

		If Len(xStImpSale) > 2
			lRet 	:= xStImpSale[1]
			aSL1PE  := xStImpSale[2]
			aSL2PE  := xStImpSale[3]
		EndIf	
	EndIf
EndIf

/*/
	STIMPFIELD - Ponto de Entrada para permitir a importação de campos adicionais
/*/
If lStImpField
	
	aStImpField := ExecBlock( "STIMPFIELD", .F., .F.)
	If ValType(aStImpField) == "A"

		//organizamos o vetor para que os campos sejam sequenciais (L1 > L2)
		aSort(aStImpField)

		For nI := 1 To Len(aStImpField)
			If SubStr(aStImpField[nI], 1, 2) == "L1"
				nPos := AScan( aSL1 , {|x| x[1] == aStImpField[nI]} )
				If nPos > 0
					Aadd( aSL1PE, aSL1[nPos] )
				EndIf
			EndIf
		Next

	EndIf
EndIf

	
/*/
	Chamada Atualiza Cliente Venda
/*/
If lRet

	cCliCode	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_CLIENTE"} )][2]
	cCliStore	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_LOJA" 	} )][2]
	cCliType	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_TIPOCLI"} )][2]
	cFilRes 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_FILRES"	} )][2]
	cOrcRes 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_ORCRES"	} )][2]
	cPedRes 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_PEDRES"	} )][2]
	cCondPg		:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_CONDPG"	} )][2]
	cVendedor	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_VEND"	} )][2]
	cNumOrig 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_NUM" 	} )][2]
	cCgcCart 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_CGCCART"} )][2]
	nPosL1INDP := AScan(aSL1, { |x| x[1] == "L1_INDPRES"})
	If  nPosL1INDP > 0
		cIndPres := aSL1[nPosL1INDP][2]
	Endif 
	cTransp 	:= aSL1[AScan( aSL1 	, { |x| x[1] == "L1_TRANSP"} )][2]
	
	lIsRetPost	:= Empty(cPedRes) .And. !Empty(cOrcRes)  
	oCliModel := STWCustomerSelection(cCliCode+cCliStore,cNumOrig)
	
	LjGrvLog( "Importa_Orcamento:STBImportSale","cCliCode/cCliStore:", cCliCode+"/"+cCliStore)

	STDSPBasket( "SL1" , "L1_CLIENTE" 	, cCliCode 	)
	STDSPBasket( "SL1" , "L1_LOJA" 		, cCliStore	)
	STDSPBasket( "SL1" , "L1_TIPOCLI"	, cCliType	)
	STDSPBasket( "SL1" , "L1_CONDPG"	, cCondPg	)
	STDSPBasket( "SL1" , "L1_CGCCART"	, cCgcCart	)
	STDSPBasket( "SL1" , "L1_INDPRES"	, cIndPres	)
	STDSPBasket( "SL1" , "L1_TRANSP"	, cTransp	)
	
	/* Setando vendedor na importação */	
	oVendModel := STWSalesmanSelection(cVendedor)
	STDSPBasket("SL1","L1_VEND"	,oVendModel:GetValue("SA3MASTER","A3_COD"))
	STDSPBasket("SL1","L1_COMIS",STDGComission( oVendModel:GetValue("SA3MASTER","A3_COD") ))

	If lIsRetPost
		STDSPBasket( "SL1" , "L1_FILRES" , cFilRes 	)
		STDSPBasket( "SL1" , "L1_ORCRES" , cOrcRes 	)
		STDSPBasket( "SL1" , "L1_TIPO"   , aSL1[AScan( aSL1,	{ |x| x[1] == "L1_TIPO" } )][2] )
	EndIf
	
	cCliente  	:= oCliModel:GetValue("SA1MASTER", "A1_COD"	)
	cLojaCli  	:= oCliModel:GetValue("SA1MASTER", "A1_LOJA")
	cNomeCli	:= oCliModel:GetValue("SA1MASTER", "A1_NOME")
	cEndCli  	:= oCliModel:GetValue("SA1MASTER", "A1_END"	)
	cCgcCli		:= oCliModel:GetValue("SA1MASTER", "A1_CGC"	)
	
	If lPosCrd		//Integração TOTVSPDV x SIGACRD
		If ExistFunc("LJIsDro") .And. LJIsDro() //Verifica se usa o Template de Drogaria
			cMatricula	:= oCliModel:GetValue("SA1MASTER", "A1_MATRICU")
		EndIf
		STBSetCrdIdent(cCgcCart, cCgcCli, cCliente, cLojaCli, cMatricula)
	EndIf

	If !lCancel	
		If (nCallCPF = 2 .OR. nCallCPF = 3)
			STDSPBasket("SL1","L1_CGCCLI",cCGCCli)
		ElseIf (nCallCPF = 0 .OR. nCallCPF = 1)
			/*Quando MV_LJDCCLI = 0 ou 1, verificar se possui CPF, se não possuir, 
			limpar os campos cNomeCli e cEndCli. Motivo: Quando lInfoCNPJ = .T., 
			esta abrindo o cupom com Nome/end mesmo quando nao possui o CPF, 
			com isso impacta na finalizacao da venda onde nao eh possuivel informar o CPF 	  */
			If !Empty(AllTrim(cCgcCli))
				If Iif(GetApoInfo("STFRESTART.PRW")[4] >= Ctod("22/02/2019"), !STBGetPgtCPF(), .T.)
					STFMessage(ProcName(0),"YESNO", STR0007) //"Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?"
					lCpfRet	:= STFShowMessage(ProcName(0))
					STBSetCpfRet(lCpfRet)
					STBSetPgtCPF(.T.)
				Else
					lCpfRet := STBGetCpfRet()
				EndIf
				
				If !lCpfRet
					cCgcCli := ""
					cNomeCli:= ""
					cEndCli	:= ""				
				EndIf
				
				//Quando eu tenho emissão de NFC-e preciso deste campo
				STDSPBasket("SL1","L1_CGCCLI",cCGCCli)
			Else		//Se não possuir, limpar os campos cNomeCli e cEndCli. 
						//Motivo: Quando lInfoCNPJ = .T., está abrindo o cupom com Nome/end mesmo quando não possui o CPF, com isso impacta na finalização da venda onde não é possível informar o CPF
				cNomeCli:= ""
				cEndCli	:= ""				
			EndIf
			//Procedimento de impressão de CPF antes dos itens 
			LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STD7CPFOverReceipt")
			STD7CPFOverReceipt(cCgcCli,cNomeCli,cEndCli)		
			LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STI7InfCPF")
			STI7InfCPF(.T.)
		EndIf
	Else		//lCancel
		LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STICGCConfirm")
		STICGCConfirm(@cCgcCli, cNomeCli, cEndCli, .T. , .F. )
	EndIf
EndIf

If lRet
	// Armazena numeração original da retaguarda
	STDSPBasket( "SL1" , "L1_NUMORIG"	, cNumOrig )
	
	If STFGetCfg("lPafEcf")
		//Grava Numero do Orcamento
		STDSPBasket( "SL1" , "L1_NUMORC"	, aSL1[AScan( aSL1,	{ |x| x[1] == "L1_NUMORC"} )][2] )		
		STDSPBasket( "SL1" , "L1_TPORC"		, aSL1[AScan( aSL1, { |x| x[1] == "L1_TPORC" } )][2] )
		STDSPBasket( "SL1" , "L1_COODAV"	, aSL1[AScan( aSL1, { |x| x[1] == "L1_COODAV"} )][2] )		
	EndIf
EndIf

// Atualiza os campos customizados
If Len(aSL1PE) > 0 
	For nI := 1 To Len(aSL1PE)
		STDSPBasket( "SL1" , aSL1PE[nI][1] , aSL1PE[nI][2])
	Next nI
EndIf

If SuperGetMv("MV_LJITCHK",,0) == 1 .AND. ExistFunc("STIItemChk")
	lRet := STIItemChk(@aSL2, @lZeraPay)
EndIf

/*/
	Adicionar os Itens na Venda
/*/
If lRet
	/*/
		Armazena posições
	/*/
	nL2_PRODUTO	:= AScan( aSL2[1] , { |x| x[1] == "L2_PRODUTO"	} 	)
	nL2_VALDESC	:= AScan( aSL2[1] , { |x| x[1] == "L2_VALDESC"	} 	)
	nL2_TES		:= AScan( aSL2[1] , { |x| x[1] == "L2_TES"		} 	)
	nL2_PRCTAB	:= AScan( aSL2[1] , { |x| x[1] == "L2_PRCTAB"	} 	)
	nL2_QUANT	:= AScan( aSL2[1] , { |x| x[1] == "L2_QUANT"	} 	)
	nL2_CODBAR 	:= AScan( aSL2[1] , { |x| x[1] == "L2_CODBAR"	} 	)
	nL2_ITEMGAR := AScan( aSL2[1] , { |x| x[1] == "L2_ITEMGAR"	} 	)
	nL2_KIT		:= AScan( aSL2[1] , { |x| x[1] == "L2_KIT"		} 	)
	
	LjGrvLog("Importa_Orcamento:STBImportSale","Inicia For de Items SL2. Qtde de Itens:"+cValToChar(Len(aSL2)))

  	For nI := 1 To Len(aSL2)			
		
		// Seta quantidade
  		STBSetQuant( aSL2[nI][nL2_QUANT][2] )				
		
		nNextItem := STDPBLength("SL2") + 1

		For nY := 1 To Len(aStImpField)
			If SubStr(aStImpField[nY], 1, 2) == "L2"
				nPos := AScan( aSL2[nI] , {|x| x[1] == aStImpField[nY]} )
				If nPos > 0
					Aadd( aSL2PE, aSL2[nI][nPos] )
				EndIf
			EndIf
		Next
		
		//------------------------------------------------------------------------------------------------------------------------------
		// Trata o Desconto no Total do Orcamento
		// Orçamento com desconto no total importado passa a ter o valor do desconto rateado entre os itens, ou seja, 
		// o sistema registra o item do orçamento já com o desconto no total, como se fosse um desconto no item
		// Caso na telka de conferência seja cancelado algum item os descontos concedidos no total na Retaguarda serão desconsiderados
		//------------------------------------------------------------------------------------------------------------------------------
		If !lZeraPay
			nVlrDescIt 	:= aSL2[nI][nL2_VALDESC][2]
			nDescProp 	:= ((aSL2[nI][nL2_QUANT][2] * aSL2[nI][nL2_PRCTAB][2]) - nVlrDescIt) * ( nPercDesc / 100 )
			nDescProp 	:= STBRound( nDescProp, nDecDesc )
			nDesTotProp -= nDescProp
		Else
			nVlrDescIt 	:= 0
			nDescProp 	:= 0
			nDescProp 	:= 0
			nDesTotProp := 0
		EndIf

		//Caso seja o ultimo item do Orcamento Importado verifica se nao houve resido(sobra) no rateio
		If nI == Len(aSL2)
			If Abs(nDesTotProp) > 0
				nDescProp  += nDesTotProp
			EndIf
		EndIf

		//Inclui como desconto no item, o valor de desconto total vindo do Orcamento que foi importado.
		aSL2[nI][nL2_VALDESC][2] := aSL2[nI][nL2_VALDESC][2] + nDescProp
		
		// Verifica se o item é fiscal
		LjGrvLog("Importa_Orcamento:STBImportSale","Verifica se item é fiscal")
  		lItemFiscal := lIsRetPost .Or. STBISIsFiscal( aSL2[nI] )
  		LjGrvLog("Importa_Orcamento:STBImportSale","Verifica se item é fiscal. Retorno(lItemFiscal):",lItemFiscal)
  		
  		//Validacao Garantia Estendida e Serviço Financeiro
  		If (ExistFunc("STBIsGarEst") .AND. STBIsGarEst(aSL2[nI][nL2_PRODUTO][2])) .OR.;
  					(lFinServ .AND. STBIsFinService(aSL2[nI][nL2_PRODUTO][2]))
			lItemFiscal := .F.
  		EndIf
  		
  		/*/
			Busca item na base de dados
		/*/
		aItem	:= STWFindItem( aSL2[nI][nL2_PRODUTO][2] )
		
		// Caso nao encontre o item na base de dados, sera feito seu cadastro
		If !aItem[ITEM_ENCONTRADO]
			LjGrvLog("Importa_Orcamento:STBImportSale","Item Nao encontrado na base, chama rotina: STBUpdProducts")
			STBUpdProducts( aSL2[nI][nL2_PRODUTO][2] )
		EndIf
		
		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Item 01" + Str(nNextItem) )
		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Codigo " + aSL2[nI][nL2_PRODUTO][2] )
		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Preco " + Alltrim(Str(aSL2[nI][nL2_PRCTAB][2])) )
		
		If nL2_CODBAR > 0 .And. !Empty(aSL2[nI][nL2_CODBAR][2])
			cCodProdReg := aSL2[nI][nL2_CODBAR][2]
			LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Codigo de barras:" + Alltrim(cCodProdReg) )
		Else
			cCodProdReg := aSL2[nI][nL2_PRODUTO][2]
		EndIf

		//Verificar se há item de código de garantia do produto
		If nL2_ITEMGAR > 0 .And. !Empty(aSL2[nI][nL2_ITEMGAR][2])
			cCodItemGar := aSL2[nI][nL2_ITEMGAR][2]
		EndIf

		While !lRegistrou

			LjGrvLog("Importa_Orcamento:STBImportSale",	"Registro do Item Importado - Inicio "+; 
																"Item:"+cValToChar(nNextItem)+;
																";Cliente:"+cCliCode+;
																";Loja:"+cCliStore+;
																";Codigo:"+cCodProdReg+;
																";ValorDesconto:"+cValToChar(aSL2[nI][nL2_VALDESC][2])+;
																";TES:"+cValToChar(aSL2[nI][nL2_TES][2])+;
																";PrecoTab:"+cValToChar(aSL2[nI][nL2_PRCTAB][2]))

			// Registra Item
	   		lItemRegister := STWItemReg( 	nNextItem					, ;		// Item
   											cCodProdReg					, ;		// Codigo Prod
   											cCliCode 					, ;		// Codigo Cli
   											cCliStore					, ;		// Loja Cli
											1 							, ;		// Moeda
											aSL2[nI][nL2_VALDESC][2]	, ;		// Valor desconto
						 					"V"							, ;		// Tipo desconto ( Percentual ou Valor )
						 					NIL							, ;		// Item adicional?
				  							aSL2[nI][nL2_TES][2] 		, ;		// TES
				  							cCliType 					, ;		// Tipo do cliente (A1_TIPO)
				  							lItemFiscal 				, ;		// Registra item no cupom fiscal?
				  							aSL2[nI][nL2_PRCTAB][2] 	, ;		// Preço
					  						"IMP"						, ;		// Indica que é importação de orçamento
					  						lInfoCNPJ					, ;		// Se deve imprimir o CNPJ, informacao sera passada na abertura do cupom  
					  						,,,,,,,,					, ;		// lRecovery,nSecItem,lServFinal,lProdBonif,lListProd,cCodList,cCodListIt,cCodMens,cEntrega
				  							cCodItemGar,,  				, ;		// Código do item de produto garantia vinculado, Id do item Relacionado, Vale Presente		
											aSL2[nI][nL2_KIT][2])  				// Código do kit utilizado para lançar o item
				
			If !lItemRegister 
				If !MSGYESNO( STR0008, STR0009 )	//"Erro ao registrar o item, deseja tentar novamente?"###"ERRO"
					lRet := .F.
					lRegistrou	:= .T.
				EndIf	
			Else
				lRegistrou	:= .T.
			EndIf	
				
		EndDo	
		
		lRegistrou := .F.
		
		If !lRet
			Exit //Caso ocorra algum erro ao registrar o item não é necessário executar os passos seguintes
		EndIf
			
		LjGrvLog( "ORCAMENTO PDV 2 : " + STDGPBasket('SL1','L1_NUM'), "Codigo " + aSL2[nI][nL2_PRODUTO][2] )
		
		// Numero do orcamento da retaguarda..
		aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_NUMORIG"	} 	)][2] := cNumOrig

		LjGrvLog( "ORCAMENTO PDV 3 : " + STDGPBasket('SL1','L1_NUM'), "cNumOrig " + cNumOrig )

		
		/*/
			Atualiza Cesta
		/*/
		STBISL2Refresh( aSL2[nI] , nNextItem )

		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Item 02" + Str(nNextItem) )

		
		// Atualiza os campos customizados
		If Len(aSL2PE) > 0 
			LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "Tamanho do aSL2PE " + Str(Len(aSL2PE))  )
			For nX := 1 To Len(aSL2PE)
				STDSPBasket( "SL2", aSL2PE[nX][1], aSL2PE[nX][2], nNextItem )
			Next
		EndIf

		//	Atualiza Banco de Dados
		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "=====inicio grava item (Import)======" + aSL2[nI][nL2_PRODUTO][2] )
		STDSaveSale(nNextItem)
		LjGrvLog( "ORCAMENTO PDV: " + STDGPBasket('SL1','L1_NUM'), "=====Fim grava item (Import) ======")
	   	
	   	/*/
	   		PAF-ECF: Verifica se item foi cancelado na Retaguarda enquanto Orcamento, 
	   		para realizar o cancelamento logo apos a impressao do Item no ECF					
	   	/*/	   	
	   	If STFGetCfg("lPafEcf") .AND. aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_VENDIDO"	} 	)][2] == "N"			
			/*/
				Realiza Cancelamento do Item
			/*/	   	
			LjGrvLog("Importa_Orcamento:STBImportSale",">>> NC <<< Cancela Item") 	
			STWLastCancel(lImportSale)
	   	EndIf
	   	
  	Next nI  

EndIf
	
/*/
	Atualiza campos do cabeçalho
/*/
If lRet
	
	/*/
		Indica que já importou algum orçamento. Para multi-orçamentos, varrer o L2
	/*/
	aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUMORIG" } )][2] := cNumOrig
	
	aSL1[AScan( aSL1 , { |x| x[1] == "L1_OPERACA" } )][2] := "C"  // Nao sei pq mas deixei, quem souber fala aí
	
 	LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STBISL1Refresh") 
 	STBISL1Refresh( aSL1 )
 	
	/*/
		Chamada componente de frete
	/*/
	LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STWAddFreight") 
	STWAddFreight(aSL2)
	
 	/*/
 		Chamada Acrescimo Financeiro
 	/*/
 	nScanJuros := AScan( aSL1 , { |x| x[1] == "L1_JUROS" } ) 	
 	
 	If SL1->(ColumnPos("L1_VLRJUR")) > 0 		
	 	
	 	nScanVLJur := AScan( aSL1 , { |x| x[1] == "L1_VLRJUR" } )
	 	If nScanVLJur > 0 	 	
	 	 	STFSetTot( "L1_VLRJUR" , aSL1[nScanVLJur][2])
	 	 	STDSPBasket("SL1","L1_VLRJUR",STDGPBasket('SL1','L1_VLRJUR') + aSL1[nScanVLJur][2]) 		
	 	Else
	 		STFSetTot( "L1_VLRJUR",0)
	 		STDSPBasket("SL1","L1_VLRJUR",0)	
		EndIf
				
		AADD ( aAcres , STDGPBasket("SL1","L1_VLRJUR"))
		AADD ( aAcres , aSL1[nScanJuros][2]) 
													
	Else
		/*/
		Calcula o valor do acrescimo (Legado)
		A função abaixo irá retornar o valor correto apenas para juros simples ou multi-negociação
		Caso seja Condição negociada (juros composto ou Price) o valor total da venda não irá bater com o Total da SL4
		/*/				
		aAcres := STBDiscConvert( aSL1[nScanJuros][2] , 'P' )
		LjGrvLog("Importa_Orcamento:STBImportSale","O campo L1_VLRJUR não existe na sua base de dados, a falta do campo afetará o cálculo do total da venda.")
	EndIf
	
	If aAcres[1] > 0		//Caso houver acréscimo
		STBConfJur(@aAcres[1],STDGPBasket( "SL1" , "L1_VLRTOT" ),aSL4)
	EndIf
	
	LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STWAddIncrease")
	STWAddIncrease( aAcres[1]  , aSL1[nScanJuros][2] )

	/*/
		Atualiza Totalizador
	/*/
	LjGrvLog("Importa_Orcamento:STBImportSale","Chama rotina: STFRefTot")
	STFRefTot()
	
EndIf



/* Atualiza SL4 */
//Desabilitei a linha abaixo porque o pagamento na cesta de vendas 'e inserido dentro da funcao STIUpdBask
//que 'e chamada quando finaliza a venda pela funcao STBConfPay()
//STBISL4Refresh( aSL4 )     		

LjGrvLog("Importa_Orcamento:STBImportSale","Parâmetro de retorno lRet: ", lRet)

Return lRet
      

//-------------------------------------------------------------------
/*/{Protheus.doc} STBISL4Refresh
Atualiza Item cesta

@param   aSL4				Array com a estrutura da Forma de Pagamento(SL4)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISL4Refresh( aSL4 )

Local nI	   				:= 0		 		   						// Contador
Local nJ					:= 0				   						// Contador
Local oModelCesta		:= STDGPBModel() 	   						// Model Cesta
Local oModelSL4			:= oModelCesta:GetModel("SL4DETAIL")  	// Model Formas de Pagamento

/*/
	TODO: ajustar data das parcelas de acordo com o parâmetro MV_LJDTORC acima
/*/

For nI := 1 To Len(aSL4)

	If oModelSL4:Length() < nI
		oModelSL4:AddLine(.T.)
	EndIf
	
	oModelSL4:GoLine(nI)                                  
	
	/*/
		Sincroniza valores
	/*/	    
	For nJ := 1 To Len(aSL4[nI])
		
		Do Case 
			
			Case aSL4[nI][nJ][1] == "L4_FILIAL"
			
				oModelSL4:SetValue( "L4_FILIAL"	, STDGPBasket( "SL1" , "L1_FILIAL"	)  ) 			
			
	   		Case aSL4[nI][nJ][1] == "L4_NUM"      
	   		
	   			oModelSL4:SetValue( "L4_NUM"	, STDGPBasket( "SL1" , "L1_NUM"		)  ) 
		       
			Case aSL4[nI][nJ][1] == "R_E_C_N_O_" .OR. aSL4[nI][nJ][1] == "R_E_C_D_E_L_"
			  
			
			Otherwise
			
				oModelSL4:SetValue( aSL4[nI][nJ][1] , aSL4[nI][nJ][2]  ) 		
			
		EndCase
	
	Next nJ		 
		
Next nI	

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISL2Refresh
Atualiza Item cesta

@param   aSL2				Array com a estrutura do Item(SL2)
@param   nLine				Linha do Item
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISL2Refresh( aSL2 , nLine )

Local lStImpField   := ExistBlock("STIMPFIELD")
Local aStImpField	:= {}
Local nI			:= 0
Local aFieldsNot	:= {} // Campos que nao devem receber a informacao da retaguarda, pois serao alimentados no Totvs PDV
Local aTipoSx3	:= {}	//Tipo do campo no dicionario de dados
Local oModel 		:= STDGPBModel()	//Model

Default aSL2		:= {}		// Array SL2
Default nLine		:= 0		// Numero da linha

aAdd( aFieldsNot, PadR( "L2_FILIAL"	, 10) )
aAdd( aFieldsNot, PadR( "L2_NUM"	, 10) )
aAdd( aFieldsNot, PadR( "L2_VENDIDO", 10) )

If Len(aSL2) > 0 .AND. nLine > 0

	//Garante que está posicionado no item correto
	oModel:GetModel("SL2DETAIL"):GoLine(nLine)

	//Seta as infomacoes da tabela SL2 do orcamento importado da Retaguarda
	For nI := 1 To Len(aSL2)
		If aScan( aFieldsNot, PadR( aSL2[nI][1], 10) ) == 0
			If AllTrim(aSL2[nI][1]) <> "R_E_C_N_O_" .AND. AllTrim(aSL2[nI][1]) <> "R_E_C_D_E_L_"   .AND. "L2_ITEM" <> UPPER(AllTrim(aSL2[nI][1])) 
				
				//Verifica o tipo do campo no dicionario SX3 - caso retorne um array vazio é pq o campo so existe na retaguarda.
				aTipoSx3 := TamSX3(aSL2[nI][1])
				If Len(aTipoSx3) == 0
					LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Campo '"+aSL2[nI][1]+"' não localizado na base local (PDV)")
				EndIf
			   If Len(aTipoSx3) > 0 .AND. aTipoSx3[3] == "D" .AND. Len(aSL2[nI]) > 1 .AND. ValType(aSL2[nI][2]) == "C"
					aSL2[nI][2] := sTOd(aSL2[nI][2])
					LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Tipo de dado ajustado " + aSL2[nI][1])
				EndIf
				
				STDSPBasket( "SL2", aSL2[nI][1], aSL2[nI][2], nLine )
				
			EndIf	
			
		EndIf
	Next
	
	If !Empty( aSL2[AScan( aSL2 , { |x| x[1] == "L2_VENDIDO"	} 	)][2] )
		STDSPBasket( "SL2" , "L2_VENDIDO" 	, aSL2[AScan( aSL2 , { |x| x[1] == "L2_VENDIDO"	} 	)][2]	, nLine )
	EndIf
	
	/*
 		STIMPFIELD - Ponto de Entrada para permitir a importação de campos adicionais
 	*/
	If lStImpField
		aStImpField := ExecBlock( "STIMPFIELD",.F.,.F.)
		If ValType(aStImpField) <> "A"
			aStImpField := {}
		EndIf

		//organiza o vetor para que os campos sejam sequenciais (L1 > L2)
		ASort(aStImpField)

		For nI := 1 To Len(aStImpField)

			If SubStr(aStImpField[nI], 1, 2) == "L2"
				nPos := Ascan( aSL2, {|x| x[1] == aStImpField[nI]} )
				If nPos > 0 .AND. UPPER(AllTrim(aSL2[nPos][1] )) <> "L2_ITEM"
					STDSPBasket( "SL2", aSL2[nPos][1], aSL2[nPos][2], nLine )
				EndIf
			EndIf
		Next

	EndIf
Else
	LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Item nao sera atualizado  ")
EndIf
				
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISL2Refresh
Atualiza cabeçalho cesta

@param   aSL1					Array com a estrutura do Item(SL2)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISL1Refresh( aSL1 )

Local aRefreshFields		:= {}				// Array com os campos a atualizar
Local nI 					:= 0				// Contador
Local x
Local nCampo				:= 0				//posição do campo

Default aSL1			:= {}

ParamType 0 Var 	aSL1 			As Array		Default {}

If Len(aSL1) > 0

	AADD( aRefreshFields , "L1_OPERACA" 	)
	AADD( aRefreshFields , "L1_MIDIA" 		)
	AADD( aRefreshFields , "L1_NUMORIG" 	)
	AADD( aRefreshFields , "L1_JUROS" 		)
	AADD( aRefreshFields , "L1_NUMATEN" 	)  //Campo TMK
	
	/*/
		Campos referentes a Frete / Transporte
	/*/
	AADD( aRefreshFields , "L1_TRANSP" 	)
	AADD( aRefreshFields , "L1_ENDCOB" 	)
	AADD( aRefreshFields , "L1_BAIRROC" 	)
	AADD( aRefreshFields , "L1_MUNC" 		)
	AADD( aRefreshFields , "L1_CEPC" 		)
	AADD( aRefreshFields , "L1_ESTC" 		)
	AADD( aRefreshFields , "L1_ENDENT" 	)
	AADD( aRefreshFields , "L1_BAIRROE" 	)
	AADD( aRefreshFields , "L1_MUNE" 		)
	AADD( aRefreshFields , "L1_CEPE" 		)
	AADD( aRefreshFields , "L1_ESTE" 		)
	
	If SL1->(ColumnPos('L1_VEICUL1')) > 0 
		AADD( aRefreshFields , "L1_VEICUL1" 	)
	EndIf
	/*/
		Campos referentes a Frete / Dados Complementares
	/*/	
	AADD( aRefreshFields , "L1_VOLUME" 	)
	AADD( aRefreshFields , "L1_ESPECIE" 	)
	AADD( aRefreshFields , "L1_MARCA" 		)
	AADD( aRefreshFields , "L1_NUMERO" 	)
	AADD( aRefreshFields , "L1_PLIQUI" 	)
	AADD( aRefreshFields , "L1_PBRUTO" 	)
	AADD( aRefreshFields , "L1_PLACA" 		)
	AADD( aRefreshFields , "L1_UFPLACA" 	)
	/*/
		Campos referente a Frete / Valores
	/*/
	AADD( aRefreshFields , "L1_TPFRET" 	)
	AADD( aRefreshFields , "L1_FRETE" 		)
	AADD( aRefreshFields , "L1_SEGURO" 	)
	AADD( aRefreshFields , "L1_DESPESA" 	)
	
	/*/
		Campos referentes a Comissao/Vendedor
	/*/
	AADD( aRefreshFields , "L1_VEND" 	)
	AADD( aRefreshFields , "L1_COMIS" 	)
	
	/*/
		Campos referentes a Impostos
	/*/
	AADD( aRefreshFields , "L1_VALICM" 	)
	AADD( aRefreshFields , "L1_VALISS" 	)
	AADD( aRefreshFields , "L1_VALIPI" 	)
	
	/*/
		Atualiza os campos na cesta
	/*/
	For nI := 1 To Len(aRefreshFields)
		
		nCampo := AScan( aSL1 , { |x| x[1] == aRefreshFields[nI]	} 	)   // valida se o campo existe no array aSL1
		
		//Caso o campo não exista no array com os valores ele não prossegue
		If nCampo > 0
		
			STDSPBasket( "SL1" , aRefreshFields[nI] , aSL1[nCampo][2] )
		
		EndIf
		
	Next nI

EndIf
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISIsFiscal
Verifica se o Item é ou nçao item fiscal

@param   aSL2					Array com a estrutura do Item(SL2)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lItemFiscal			Retorna se o Item é fiscal
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISIsFiscal( aSL2 )

Local lItemFiscal		:= .F.		// Retorna se o item eh fiscal(vai para o cupom fiscal), ou nao fiscal(Cupom nao fiscal)
Local lContinue		:= .T.		// Fluxo logico função

/*/
	1)
	Fiscal Se:
		- Usa impressora fiscal
	Não Fiscal se:
		- Não Usa Impressora Fiscal
	
	1.1)
	Se usa Impressora Fiscal
	Não Fiscal se: 
		A) Possui reserva e Entrega <> "2" - (Retira)	
		B) Item de Lista de Presente - desabilitado
		C) Item de Garantia Estendida
		
/*/


If Len(aSL2) > 0
	lContinue := .T.
Else
	lContinue := .F.
EndIf
	
If lContinue
		
	Do Case
	
		/*/
			A) Possui reserva
		/*/
		Case 	!Empty( 	aSL2[AScan( aSL2 , { |x| x[1] == "L2_RESERVA"	} 	)][2] ) .AND.		;
							aSL2[AScan( aSL2 , { |x| x[1] == "L2_ENTREGA"	} 	)][2] <> "2"		//2 - RETIRA
		
			lItemFiscal := .F.
			LjGrvLog("Importa_Orcamento:STBISIsFiscal","A) Possui reserva")
							
		/*/
			B) Item de Lista de Presente
		/*/			
		Case .F.  
		
			/*/
				!Empty( aSL2[AScan( aSL2 , { |x| x[1] == "L2_CODLPRE"	} 	)][2] ) // Indica que veio de lista de presentes -> Não Fiscal
				Atualmente esse verificação não eh utilizada, pois os itens de lista caem na verificaçao A
			/*/
			
			/*/
				OBS: Originalmente, os orçamentos de lista de presente vem com L2_RESERVA preenchido com "S"(Mesmo sem Reserva, 
				com lista tipo crédito), caindo no item A para que sejam destinados ao cupom nao fiscal, para implementação dessa
				verificação deve ser alterada a gravação da retaguarda posteriormente.
				Lista de Presentes pode haver itens do tipo Retira que gera cupom fiscal
			/*/
				
			/*lItemFiscal := .F.  */
		
		/*/
			C) Item de Garantia Estendida
		/*/
		Case .F.
		
			/*/
				OBS: Garantia Estendida nao irá sair mais nesta versão(maio 2012), ficará pra mais tarde
			/*/
		
		/*/
			D) Item de Servico
			Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS), parametro MV_LJPRDSV
		/*/
		Case SuperGetMv("MV_LJPRDSV",.F.,.F.) .And. LjIsTesISS( aSL2[AScan( aSL2 , { |x| x[1] == "L2_NUM"} )][2], aSL2[AScan( aSL2 , { |x| x[1] == "L2_TES"} )][2] ) 
			
			lItemFiscal := .F.
			LjGrvLog("Importa_Orcamento:STBISIsFiscal","D) Item de Serviço")
					 
		/*/
			E) Item ENTREGA C/ PEDIDO S/ RESERVA
		/*/
		Case Empty(aSL2[AScan(aSL2, {|x|x[1] == "L2_RESERVA"} )][2]) .AND. ;
					aSL2[AScan(aSL2, {|x|x[1] == "L2_ENTREGA"} )][2] == "5" // 5- ENTREGA C/ PEDIDO S/ RESERVA		
		
			lItemFiscal := .F.
			LjGrvLog("Importa_Orcamento:STBISIsFiscal","E) Item ENTREGA C/ PEDIDO S/ RESERVA")
							


		Otherwise
			
			lItemFiscal := .T.
			
	EndCase 
EndIf

LjGrvLog("Importa_Orcamento:STBISIsFiscal","Parâmetro de retorno lItemFiscal: ", lItemFiscal)

Return lItemFiscal


//-------------------------------------------------------------------
/*/{Protheus.doc} STBISCanImport
Valida se pode importar multiplos orçamentos

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se pode importar orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBISMultSales()

Local lRet		:= .T.		// Retorno função
	
/*/
	Se ja tem L1_NUMORIG quer dizer que algum orçamento ja foi importado		
/*/	
If !( Empty(STDGPBasket("SL1","L1_NUMORIG")) )

	If STFGetCfg("lPafEcf") .OR. !( SuperGetMv( "MV_LJMLTOR" , NIl , .T. ) )
	
		lRet := .F.
		
	EndIf

EndIf

LjGrvLog("Importa_Orcamento:STBISMultSales","Parâmetro de retorno lRet: ", lRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBFormatOrcs
Formata os orcamento para inclusao das formas de pagamento

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBFormatOrcs()

Local aOrc			:= STIGetOrc()		//Orcamento que foi importado
Local aRet			:= Array(5,6)		//Retorno da funcao 1o - R$; 2o - CD|FI; 3o - CC; 4o - CH;5o em diante - Outras genericas
Local nI			:= 0				//Variavel de loop
Local nValCash		:= 0				//Valor do dinheiro
Local nValCc		:= 0				//Valor do credito
Local nValCh		:= 0				//Valor dos cheques
Local nValCd		:= 0				//Valor do debito
Local nValFi		:= 0				//Valor do financiado
Local cData			:= ""				//Data do pagamento
Local nParcCh		:= 0				//Parcelas do cheque
Local nParcCc		:= 0				//Parcelas do cartao credito
Local nParcCd		:= 0				//Parcelas do cartao debito
Local nParcFi		:= 0				//Parcelas do financiado
Local cFormaPg		:= ""				//Forma de pagamento da importação
Local nValForm		:= 0				//Valor de formas de pagamentos
Local nParcForm		:= 0				//Valor de parcelas de pagamento
Local nPos			:= 0				//Posição do elemento do array
Local cMvCondPad	:= SuperGetMv('MV_CONDPAD',.F.,'')	//Condicao de pagamento padrao
Local cMvSimb1		:= SuperGetMV("MV_SIMB1")				// Simbolo da moeda da venda (parcela em dinheiro)
Local aCondicoes	:= STDCondPg()					//Recebe as condicoes de pagamento
Local nX			:= 0								//Variável de loop
Local nJ			:= 0
Local lImpPgtOrc	:= ExistFunc("STBSFormImp")	//Se importa as formas de pgto de orçamento original
Local nPosCred		:= 0							// Posicao do campo L1_CREDITO 
Local nCredito		:= 0							// Valor total do credito utilizado no orçamento
Local cFormaId		:= ""
Local cIdCCAnt      := "."                              // Se MV_TEFMULT .F. ele retorna L4_FORMAID vazio
Local cIdCDAnt      := "."                              // Se MV_TEFMULT .F. ele retorna L4_FORMAID vazio
Local nContCC		:= 0
Local nContCD		:= 0
Local aPagCC		:= {}
Local aPagCD		:= {}
Local nPosForma		:= 0 //Posicao da Forma
Local nPosFrmId		:= 0 //Posicao da Forma ID
Local nPosData		:= 0 //Posicao da data
Local nParcCo       := 0 //Parcelas do convenio

For nJ := 1 To Len(aOrc)

	If Len(aOrc[nJ][3]) > 0
		nPosForma		:= aScan(aOrc[nJ][3][1], { |x| x[1] == "L4_FORMA"})  //Posicao da Forma
		nPosFrmId		:= aScan(aOrc[nJ][3][1], { |x| x[1] == "L4_FORMAID"}) //Posicao da Forma ID
		nPosData		:= aScan(aOrc[nJ][3][1], { |x| x[1] == "L4_DATA"}) //Posicao da Forma ID
		
		If nPosForma > 0 .AND. nPosFrmId > 0 .AND. nPosData > 0
			ASort(aOrc[nJ][3] ,,, { |x, y| x[nPosForma,2]+ x[nPosFrmId,2]+x[nPosData,2] <  y[nPosForma,2]+y[nPosFrmId,2]+y[nPosData,2]  } )			
		EndIf
	EndIf
	
	For nI := 1 To Len(aOrc[nJ][3])

		If Empty(cMvCondPad) //Tratamento para nao trazer o valor do pagamento da importação
			Exit
		EndIf

		cFormaPg := AllTrim(aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMA"})][2])
	
		Do Case
			Case cFormaPg == 'R$'
				nValCash 	+= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				
				aRet[1][1] := nValCash
				If Empty(aRet[1][2])
					aRet[1][2] := cData
				EndIf
				aRet[1][3] := 'R$'
					
			Case cFormaPg == 'CH'
			
				nValForm	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				nValCh		+= nValForm
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				cFormaId	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2] 				
				nParcCh	+= 1
				
				aRet[4][1] := nValCh
				If Empty(aRet[4][2])
					aRet[4][2] := cData
				EndIf
				aRet[4][3] := 'CH'
				aRet[4][4] := nParcCh
					
				//Tratamento para guardar as informações dos pagamentos em CH
				//do orçamento importado, para que seus valores sejam mantidos no PDV.
				If lImpPgtOrc
					STBSFormImp({cFormaPg,nValForm,cData,nParcCh,cFormaId})
				EndIf
					
			Case cFormaPg == 'CC'
			
				nValForm	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				cFormaId	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2]
				
				If cFormaId <> cIdCCAnt  
					AAdd(aPagCC, Array(6)) 
					nValCc	:= nValForm
					cIdCCAnt:= cFormaId
					nParcCc := 1
					nContCC	+= 1
				ElseIf cFormaId == cIdCCAnt
					nValCc	+= nValForm
					nParcCc	+= 1
				EndIf
				
				aPagCC[nContCC][1] := nValCc
				
				If Empty(aPagCC[nContCC][2])
					aPagCC[nContCC][2] := cData
				EndIf
				
				aPagCC[nContCC][3] := 'CC'
				aPagCC[nContCC][4] := nParcCc
				
				aRet[3] := aPagCC
				
				//Tratamento para guardar as informações dos pagamentos em CC
				//do orçamento importado, para que seus valores sejam mantidos no PDV.
				If lImpPgtOrc
					STBSFormImp({cFormaPg,nValForm,cData,nParcCc,cFormaId})
				EndIf
										
			Case cFormaPg == 'CD'
	
				nValForm	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				cFormaId	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2]
				
				If cFormaId <> cIdCDAnt
					AAdd(aPagCD, Array(6)) 
					nValCd	:= nValForm
					cIdCDAnt:= cFormaId
					nParcCd := 1
					nContCD	+= 1
				ElseIf cFormaId == cIdCDAnt
					nValCd	+= nValForm
					nParcCd	+= 1
				EndIf
				
				aPagCD[nContCD][1] := nValCd
				
				If Empty(aPagCD[nContCD][2])
					aPagCD[nContCD][2] := cData
				EndIf
				
				aPagCD[nContCD][3] := 'CD'
				aPagCD[nContCD][4] := nParcCd
				
				aRet[2] := aPagCD
				
				//Tratamento para guardar as informações dos pagamentos em CD
				//do orçamento importado, para que seus valores sejam mantidos no PDV.
				If lImpPgtOrc
					STBSFormImp({cFormaPg,nValForm,cData,nParcCd,cFormaId})
				EndIf

			Case cFormaPg == 'FI'
	
				nValForm	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				nValFi		+= nValForm
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				cFormaId	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2] 
				nParcFi	+= 1
	
				aRet[5][1] := nValFi
				If Empty(aRet[5][2])
					aRet[5][2] := cData
				EndIf
				aRet[5][3] := 'FI'
				aRet[5][4] := nParcFi
	
				//Tratamento para guardar as informações dos pagamentos em FI
				//do orçamento importado, para que seus valores sejam mantidos no PDV.
				If lImpPgtOrc
					STBSFormImp({cFormaPg,nValForm,cData,nParcFi,cFormaId})
				EndIf
	
			OtherWise
	
				//Tratamento para formas de pagamentos genericas (diferentes das citadas acima) ou
				//formas de pagamento criadas pelo usuario.
				nValForm	:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_VALOR"})][2]
				cData		:= aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_DATA"})][2]
				nParcForm	:= 1
	
				//Se foi pago com NCC na venda assistida e gravou como orçamento (sendo que não há nada no SL4), ler o SL1.
				//Caso a pessoa não escolheu nenhum NCC e resolveu ir para a forma de pagamento,
				// passará por aqui e aplicará o default como que está em MV_CONDPAD. 
				//Pesquisando em SE4->E4_CODIGO com o valor MV_CONDPAD, obtenho o SE4->E4_FORMA.
				nPosCred := aScan(aOrc[nJ][1], { |x| x[1] == "L1_CREDITO"})
				If nPosCred > 0
					nCredito := aOrc[nJ][1][nPosCred][2]
				EndIf	
								
				If Len(aOrc[nJ][3]) = 1 .AND. nCredito > 0
					// Farei a correspondência cMvCondPad (E4_CODIGO) com a E4_FORMA. O resultado será o cFormaPg. Ex: 001=R$,002=CH...
					If (nX := aScan(aCondicoes,{|x| Alltrim(x[1]) == Alltrim(cMvCondPad) })) > 0		
						cFormaPg := Substr(aCondicoes[nX][3],1,2)
					Else
						cFormaPg := "CH" //Default conforme regras da função STBChkTpCP() em STBPayCdPg.prw
					EndIf
					nValForm	:= nCredito
					cData		:= aOrc[nJ][1][aScan(aOrc[nJ][1], { |x| x[1] == "L1_EMISSAO"})][2]
					nParcForm	:= IIF(cFormaPg == cMvSimb1, 0, 1)  // Se dinheiro, não há parcela.
				EndIf
				
				If !Empty(cFormaPg)  .AND. nValForm > 0
					If (nPos := aScan(aRet, {|x| UPPER(AllTrim(x[3])) == cFormaPg}, 6)) > 0 //Caso seja a mesma forma de pagto 
						aRet[nPos][1] += nValForm
						aRet[nPos][4] += nParcForm
		
					Else
						aAdd(aRet, Array(6))
						nPos := Len(aRet)
		
						aRet[nPos][1] := nValForm
						If Empty(aRet[nPos][2])
							aRet[nPos][2] := cData
						EndIf
						aRet[nPos][3] := cFormaPg
						aRet[nPos][4] := nParcForm				
						
					EndIf
					//Tratamento para guardar as informações dos pagamentos em CH
					//do orçamento importado, para que seus valores sejam mantidos no PDV.
					If lImpPgtOrc .AND. !(cFormaPg == 'CO')
						STBSFormImp({cFormaPg,nValForm,cData,aRet[nPos][4],aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2]})
					EndIf	
				EndIf

				If lImpPgtOrc .AND. cFormaPg == 'CO'
					nParcCo += 1
					STBSFormImp({cFormaPg,nValForm,cData,nParcCo,aOrc[nJ][3][nI][aScan(aOrc[nJ][3][nI], { |x| x[1] == "L4_FORMAID"})][2]}) 
				EndIf
	
		EndCase
	
	Next nI
Next nJ

If Len(aRet) = 0
	LjGrvLog("Importa_Orcamento:STBFormatOrcs","Parâmetro de retorno aRet: Conteúdo vazio")
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBImpProduct
Importa as informacoes do produto da retaguarda, para posteriormente cadastra-lo na base local

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBUpdProducts( cProdCode )
Local aProduct    := {}		// -- Array com retorno da função STDIMPPROD
Local aFieldsProd := {}		// -- Campos que serão trazidos para a gravação no PDV
Local lRet        := .F.	// -- Retorno da função
Local aRetPE	  := {}		// -- Retorno do P.E STSELFIELD
Local nI		  := 0		// -- Variavel para For

DEFAULT cProdCode := ""

Aadd(aFieldsProd,"B1_FILIAL")
Aadd(aFieldsProd,"B1_COD")
Aadd(aFieldsProd,"B1_DESC")
Aadd(aFieldsProd,"B1_TIPO")
Aadd(aFieldsProd,"B1_UM")
Aadd(aFieldsProd,"B1_LOCPAD")
Aadd(aFieldsProd,"B1_CODBAR")
Aadd(aFieldsProd,"B1_GRUPO")
Aadd(aFieldsProd,"B1_BITMAP")
Aadd(aFieldsProd,"B1_BALANCA")
Aadd(aFieldsProd,"B1_POSIPI")
Aadd(aFieldsProd,"B1_ORIGEM")	
Aadd(aFieldsProd,"B1_CEST")
Aadd(aFieldsProd,"B1_GRTRIB")

//Ponto de entrada para retornar campos adicionais no aCamposBusca
If ExistBlock("STSELFIELD")
	aRetPE := ExecBlock("STSELFIELD",.F.,.F.,{"SB1"})
EndIf

For nI := 1 To Len(aRetPE)
	/*Remover IF abaixo em 07/2020 -- Proteção, Agora o ponto de entrada é usado em mais de um ponto, 
	anteriormente esse ponto de entrada era usado apenas no fonte STBCostumerSelection 
	incluindo novos campos na tabela SA1.*/
	If SubStr(aRetPE[nI],1,3) == "B1_" .Or. SubStr(aRetPE[nI],1,3) == "b1_" 
		aAdd(aFieldsProd, aRetPE[nI])
	EndIf 
Next nI

LjGrvLog("Importa_Orcamento:STBUpdProducts","Chama rotina remoto: STDIMPPROD")
LjGrvLog("Importa_Orcamento:STBUpdProducts","Parâmetro cProdCode:       ", cProdCode)
LjGrvLog("Importa_Orcamento:STBUpdProducts","Parâmetro aFieldsProd      ", aFieldsProd)

lRet := STBRemoteExecute( "STDIMPPROD", { cProdCode, aFieldsProd }, Nil, .F. , @aProduct )

LjGrvLog("Importa_Orcamento:STBUpdProducts","Parâmetro de retorno aProduct:", aProduct)

If lRet .AND. ValType( aProduct ) == "A" .AND. Len( aProduct ) > 0
	LjGrvLog("Importa_Orcamento:STBUpdProducts","Chama rotina : STBIncProducts")
	STBIncProducts( aProduct )
Else
	lRet := .F.
EndIf

LjGrvLog("Importa_Orcamento:STBUpdProducts","Parâmetro de retorno lRet    :", lRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIncProducts
Importa as informacoes do produto da retaguarda, para posteriormente cadastra-lo na base local

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBIncProducts( aProduct )
Local nX := 0

DbSelectArea("SB1")
SB1->(DbSetOrder())
Begin Transaction

	RecLock("SB1",.T.)
	For nX := 1 To Len(aProduct)
		Replace &("SB1->"+aProduct[nX,1]) With aProduct[nX,2]
	Next nX
	SB1->(MsUnlock())
	
End Transaction

LjGrvLog("Importa_Orcamento:STBIncProducts","Campos gravados na tabela SB1:", nX)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STBISRetPos
Verifica se é orcamento (com itens de RETIRA POSTERIOR) apenas para finalizacao (impressao do Cupom Fiscal)

@param   aSL1			Array com a estrutura do Cabecalho do Orcamento (SL1)
@author  Varejo
@version P11.8
@since   20/02/2015
@return  lRet			Retorna se é orcamento (com itens de RETIRA POSTERIOR) apenas para finalizacao (impressao do Cupom Fiscal)
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBISRetPos( aSL1 )

Local lRet					:= .F.		// Retorna se é orcamento (com itens de RETIRA POSTERIOR) apenas para finalizacao (impressao do Cupom Fiscal)
Local nL1_ORCRES 			:= 0
Local nL1_PEDRES 			:= 0

nL1_ORCRES := AScan( aSL1, { |x| x[1] == "L1_ORCRES"	} )
nL1_PEDRES := AScan( aSL1, { |x| x[1] == "L1_PEDRES"	} )

If nL1_ORCRES > 0 .And. nL1_PEDRES > 0
	If Empty(aSL1[nL1_PEDRES][2]) .And. !Empty(aSL1[nL1_ORCRES][2]) 
		lRet := .T.
	EndIf
EndIf

LjGrvLog("Importa_Orcamento:STBIsRetPos","Parâmetro de retorno lRet    :", lRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBISL4ADD
Adiciona itens da forma de pagamento do orcamento filho importado (com somente itens retira posterior)

@param   aSL4				Array com a estrutura da Forma de Pagamento(SL4)
@author  Varejo
@version P11.8
@since   24/02/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBISL4ADD( aSL4 )

Local nI	   				:= 0		 		   						// Contador
Local oModelCesta			:= STDGPBModel() 	   							// Model Cesta
Local oModelSL4			:= oModelCesta:GetModel("SL4DETAIL")  	// Model Formas de Pagamento
Local cFormaPG 			:= ""
Local nValorPG 			:= 0
Local lRet					:= .T.										//retorno se add todos pagamentos
Local lAddPay				:= .T.										//controle se add cada pagamentos

For nI := 1 To Len(aSL4)
	
	cFormaPG := aSL4[nI][AScan( aSL4[nI] , { |x| x[1] == "L4_FORMA"   } )][2]
	nValorPG := aSL4[nI][AScan( aSL4[nI] , { |x| x[1] == "L4_VALOR"   } )][2]
	
	lAddPay := STIAddPay(AllTrim(cFormaPG), Nil, 1, Nil, Nil, nValorPG)
	lRet    := lRet .AND. lAddPay
		
Next nI	

LjGrvLog("Importa_Orcamento:STBIsL4ADD","Parâmetro de retorno lRet    :", lRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBISFinPos
Importa, finaliza orcamento filho que contem apenas itens "Retira Posterior", imprimindo o Cupom Fiscal.

@param   aSale				Array com a estrutura SL1, SL1 e SL4
@author  Varejo
@version P11.8
@since   24/02/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBISFinPos(aSale)

Local aSL4				:= aSale[3]				// Pagamentos
Local oMdl 			:= Nil						// Model Pgto
Local oModelPay 		:= Nil						// Model Pgto
Local oModelParc		:= Nil						// Model Pgto

LjGrvLog("Importa_Orcamento:STBISFinPos","Chama rotina: STBImportSale(aSale,.F.)")
LjGrvLog("Importa_Orcamento:STBISFinPos","Parâmetro aSale : ", aSale)
STBImportSale( aSale , .F. )
oMdl := ModelPayme()

oModelPay := oMdl:GetModel('PARCELAS')
oModelPay:Activate()
oModelPay:ClearData()
oModelPay:InitLine()

oModelParc := oMdl:GetModel('APAYMENTS')
oModelParc:Activate()
oModelParc:ClearData()
oModelParc:InitLine()

//Adiciona itens da forma de pagamento do orcamento filho importado (com somente itens retira posterior)
If STBISL4ADD( aSL4 )
	LjGrvLog("Importa_Orcamento:STBISFinPos","Chama rotina: STIConfPay(.T.)")
	STIConfPay(.T.)
Else
	STFMessage("STBISFinPos","POPUP", STR0010 ) //"Pagamento Inválido. A Venda será Cancelada" 
	STFShowMessage("STBISFinPos")
	LjGrvLog("Importa_Orcamento:STBISFinPos","Chama rotina: STWCancelSale(.T.)")
	STWCancelSale( .T. ) //Cancela Venda Atual
	LjGrvLog("Importa_Orcamento:STBISFinPos","Chama rotina: STIRegItemInterface")
	STIRegItemInterface()
EndIf
 
Return

//--------------------------------------------------------
/*/{Protheus.doc} STBIsImpOrc
Retornar se é importação de Orçamento ou nao

@param   
@author  Varejo
@version P11.8
@since   27/08/2015
@return  
/*/
//--------------------------------------------------------
Function STBIsImpOrc()
//Se ja tem L1_NUMORIG quer dizer que algum orçamento ja foi importado		
Return (!(Empty(STDGPBasket("SL1","L1_NUMORIG"))))

//--------------------------------------------------------
/*/{Protheus.doc} STBImpGFld
Resgata a relacao de campos utilizados na importacao de orcamento.

@param   
@author  Varejo
@version P11.8
@since   13/01/2016
@return  
/*/
//--------------------------------------------------------
Function STBImpGFld(cTable)
Local aRetFields := {}

Do Case

	Case cTable == "SL1" //Campos da tabela SL1
		
		aRetFields := aCmpsImpL1
			
	Case cTable == "SL2" //Campos da tabela SL2
		
		aRetFields := aCmpsImpL2
			
	Case cTable == "SL4" //Campos da tabela SL4
		
		aRetFields := aCmpsImpL4

EndCase

Return aRetFields

//--------------------------------------------------------
/*/{Protheus.doc} STBImpSFld
Define a relacao de campos utilizados na importacao de orcamento.

@param   
@author  Varejo
@version P11.8
@since   13/01/2016
@return  
/*/
//--------------------------------------------------------
Function STBImpSFld(cTable)
Local aRetFields 	:= {}
Local aStImpField	:= {}
Local nI 			:= 0
Local aStructCmp	:= {}
Local cMVCODBAR	:= IIf(SuperGetMv("MV_CODBAR",,"N") == "S", .T., .F.)		// Indica se imprime codigo de barras no cupom ao inves do codigo do produto

//Ponto de Entrada para permitir a importação de campos adicionais
If ExistBlock( "STIMPFIELD" )
	aStImpField := ExecBlock( "STIMPFIELD",.F.,.F.)
	If ValType(aStImpField) <> "A"
		aStImpField := {}
	EndIf
	
	//Organizamos o vetor para que os campos sejam sequenciais (L1 > L2)
	aSort(aStImpField)
EndIf


Do Case

	Case cTable == "SL1" //Campos da tabela SL1
		
		//---------------------------------------------------------------------------
		//Campos Padrao do sistema que serao considerados na importacao de orcamento
		//---------------------------------------------------------------------------
		aAdd( aRetFields, "L1_NUM" 		)
		aAdd( aRetFields, "L1_VLRTOT" 	)
		aAdd( aRetFields, "L1_CLIENTE" 	)
		aAdd( aRetFields, "L1_LOJA" 	)
		aAdd( aRetFields, "L1_TIPOCLI" 	)
		aAdd( aRetFields, "L1_FILRES" 	)
		aAdd( aRetFields, "L1_ORCRES" 	)
		aAdd( aRetFields, "L1_PEDRES" 	)
		aAdd( aRetFields, "L1_CONDPG" 	)
		aAdd( aRetFields, "L1_TIPO" 	)
		aAdd( aRetFields, "L1_NUMORC" 	)
		aAdd( aRetFields, "L1_COODAV" 	)
		aAdd( aRetFields, "L1_NUMORIG" 	)
		aAdd( aRetFields, "L1_OPERACA" 	)
		aAdd( aRetFields, "L1_DESCONT" 	)
		aAdd( aRetFields, "L1_JUROS" 	)
		aAdd( aRetFields, "L1_MIDIA" 	)
		aAdd( aRetFields, "L1_NUMATEN" 	)
		aAdd( aRetFields, "L1_TRANSP" 	)
		aAdd( aRetFields, "L1_ENDCOB" 	)
		aAdd( aRetFields, "L1_BAIRROC" 	)
		aAdd( aRetFields, "L1_MUNC" 	)
		aAdd( aRetFields, "L1_CEPC" 	)
		aAdd( aRetFields, "L1_ESTC" 	)
		aAdd( aRetFields, "L1_ENDENT" 	)
		aAdd( aRetFields, "L1_BAIRROE" 	)
		aAdd( aRetFields, "L1_MUNE" 	)
		aAdd( aRetFields, "L1_CEPE" 	)
		aAdd( aRetFields, "L1_ESTE" 	)
		aAdd( aRetFields, "L1_VOLUME" 	)
		aAdd( aRetFields, "L1_ESPECIE" 	)
		aAdd( aRetFields, "L1_MARCA" 	)
		aAdd( aRetFields, "L1_NUMERO" 	)
		aAdd( aRetFields, "L1_PLIQUI" 	)
		aAdd( aRetFields, "L1_PBRUTO" 	)
		aAdd( aRetFields, "L1_PLACA" 	)
		aAdd( aRetFields, "L1_UFPLACA" 	)
		aAdd( aRetFields, "L1_TPFRET" 	)
		aAdd( aRetFields, "L1_FRETE" 	)
		aAdd( aRetFields, "L1_SEGURO" 	)
		aAdd( aRetFields, "L1_DESPESA" 	)
		aAdd( aRetFields, "L1_VEND" 	)
		aAdd( aRetFields, "L1_COMIS" 	)
		aAdd( aRetFields, "L1_VALICM" 	)
		aAdd( aRetFields, "L1_VALISS" 	)
		aAdd( aRetFields, "L1_VALIPI" 	)
		aAdd( aRetFields, "L1_DOC" 		)
		aAdd( aRetFields, "L1_DOCPED" 	)
		aAdd( aRetFields, "L1_DTLIM" 	)
		aAdd( aRetFields, "L1_TPORC" 	)
		aAdd( aRetFields, "L1_DESCFIN" 	)
		If SL1->(ColumnPos("L1_VLRJUR")) > 0
			aAdd( aRetFields, "L1_VLRJUR" 	)
		Endif
		aAdd( aRetFields, "L1_CGCCART" 	)
		If SL1->(ColumnPos("L1_INDPRES")) > 0
			aAdd( aRetFields, "L1_INDPRES" 	)
		Endif
		//---------------------------------------------------------------------------
		//Campos Adicionais que serao considerados na importacao de orcamento
		// definidos no Ponto de Entrada "STIMPFIELD".
		//---------------------------------------------------------------------------
		For nI := 1 To Len(aStImpField)
			If SubStr(aStImpField[nI], 1, 2) == "L1"
				If SL1->(FieldPos(aStImpField[nI])) > 0 //Verifica se o campos existe
					aAdd( aRetFields, aStImpField[nI] )
				EndIf
			EndIf
		Next
		
	Case cTable == "SL2" //Campos da tabela SL2
		
		//---------------------------------------------------------------------------
		//Campos Padrao do sistema que serao considerados na importacao de orcamento
		//---------------------------------------------------------------------------
		aAdd( aRetFields, "L2_NUM" 		)
		aAdd( aRetFields, "L2_PRODUTO" 	)
		aAdd( aRetFields, "L2_QUANT" 	)
		aAdd( aRetFields, "L2_PRCTAB" 	)
		aAdd( aRetFields, "L2_VALDESC" 	)
		aAdd( aRetFields, "L2_TES"	 	)
		aAdd( aRetFields, "L2_NUMORIG" 	)
		aAdd( aRetFields, "L2_RESERVA" 	)
		aAdd( aRetFields, "L2_ENTREGA" 	)
		aAdd( aRetFields, "L2_LOJARES" 	)
		aAdd( aRetFields, "L2_TURNO" 	)
		aAdd( aRetFields, "L2_CODLAN" 	)
		aAdd( aRetFields, "L2_LOCAL" 	)
		aAdd( aRetFields, "L2_TABELA" 	)
		aAdd( aRetFields, "L2_GARANT" 	)
		aAdd( aRetFields, "L2_NSERIE" 	)
		aAdd( aRetFields, "L2_VEND" 	)
		aAdd( aRetFields, "L2_VENDIDO" 	)
		aAdd( aRetFields, "L2_CODLPRE" 	)
		aAdd( aRetFields, "L2_ITLPRE" 	)
		aAdd( aRetFields, "L2_MSMLPRE" 	)
		aAdd( aRetFields, "L2_REMLPRE" 	)
		aAdd( aRetFields, "L2_CODCONT" 	)
		aAdd( aRetFields, "L2_VALFRE" 	)
		aAdd( aRetFields, "L2_SEGURO" 	)
		aAdd( aRetFields, "L2_DESPESA" 	)
		aAdd( aRetFields, "L2_FDTENTR" 	)
		aAdd( aRetFields, "L2_FDTMONT" 	)
		aAdd( aRetFields, "L2_CF" 		)
		If SL2->( ColumnPos("L2_ITEMCOB") ) > 0
			aAdd( aRetFields, "L2_ITEMCOB"	)	//Servico Financeiro Vinculado a qual item 
		EndIf
		If SL2->( ColumnPos("L2_PRDCOBE") ) > 0
			aAdd( aRetFields, "L2_PRDCOBE"	)	//Código do Produto Cobertura
		EndIf
		If SL2->( ColumnPos("L2_INDPAR") ) > 0
			aAdd( aRetFields, "L2_INDPAR" ) //Comissão Parceiros que indicam a loja
		EndIf
		If cMVCODBAR
			aAdd( aRetFields, "L2_CODBAR"	)
		EndIf	
		If SL2->( ColumnPos("L2_ITEMGAR") ) > 0		//Número do item vinculado ao produto garantia
			aAdd( aRetFields, "L2_ITEMGAR" 	)
		EndIf
		If SL2->( ColumnPos("L2_VLGAPRO") ) > 0		//Validade da garantia
			aAdd( aRetFields, "L2_VLGAPRO" 	)
		EndIf
		aAdd( aRetFields, "L2_LOTECTL" )
		aAdd( aRetFields, "L2_NLOTE" )
		aAdd( aRetFields, "L2_LOCALIZ" )
		aAdd( aRetFields, "L2_KIT" ) // Código do kit do produto
		
		//---------------------------------------------------------------------------
		//Campos Adicionais que serao considerados na importacao de orcamento
		// definidos no Ponto de Entrada "STIMPFIELD".
		//---------------------------------------------------------------------------
		For nI := 1 To Len(aStImpField)
			If SubStr(aStImpField[nI], 1, 2) == "L2"
				If SL2->(FieldPos(aStImpField[nI])) > 0 //Verifica se o campos existe
					aAdd( aRetFields, aStImpField[nI] )
				EndIf
			EndIf
		Next
		
	Case cTable == "SL4" //Campos da tabela SL4
		
		//TO DO
		
EndCase

//Atualiza o array de campos, incluindo a estrutura para cada campo
For nI := 1 To Len(aRetFields)
	aStructCmp := TamSX3(aRetFields[nI])
					// Nome          , Tipo        , Tamanho    , Decimais
	aRetFields[nI] := {aRetFields[nI],aStructCmp[3],aStructCmp[1],aStructCmp[2]}
Next

Return aRetFields


//--------------------------------------------------------
/*/{Protheus.doc} STBConfJur
O valor total em L1_VLRTOT vezes a porcentagem dos juros L1_JUROS pode não coincidir com o valor acordado na Venda Assistida, que é a soma dos valores da SL4. 
Então estabeleci uma margem de 0.25 para deixar igual à soma da SL4, pois interfere na confirmação da forma de pagamento importada pela Retaguarda 
(troco de centavos ou falta de centavos) e no cálculo de troco do SAT.
@param nValJuros	Valor do Juros
@param nValTotal	Valor total do cupom sem acrescimos	
@param aSL4  	
@author  Lucas Novais
@version P12.1.14
@since   22/05/2017
@return  
/*/
//--------------------------------------------------------
Static Function	STBConfJur(nValJuros,nValTotal,aSL4)

Local nDif 		:= 0	//Resultado
Local nX		:= 0	//Contador
Local nTotSL4 	:= 0	//Soma da forma de pagamento

//Análise de SL4, considerando somente o L4_NUM selecionado
nScan := AScan( aSL4[1] , { |x| x[1] == "L4_VALOR" } )
For nX := 1 to Len(aSL4)
	If nScan > 0
		nTotSL4 += aSL4[nX,nScan,2]
	EndIf
Next

nDif := nTotSL4 - (nValJuros + nValTotal)

If Abs(nDif) <= 0.25
	nValJuros := nValJuros + nDif
EndIf

Return nil

//--------------------------------------------------------
/*/{Protheus.doc} STBLMPaSl4
Limpa o conteudo da vareavel aSL4Bkp

@author  Lucas Novais
@version P12.1.17
@since   17/10/2017
@return  
/*/
//--------------------------------------------------------
Function STBLMPaSl4()
aSL4Bkp := {}
Return 

//--------------------------------------------------------
/*/{Protheus.doc} STBConfJur
retorna o conteudo da vareavel aSL4Bkp
	
@author  Lucas Novais
@version P12.1.17
@since   17/10/2017
@return aSL4Bkp 
/*/
//--------------------------------------------------------
Function STBGetaSL4()

Return aSL4Bkp

//-------------------------------------------------------------------
/*/{Protheus.doc} STBISValCred
Valida Credito na importaçao de orçamento

@param   ntipo := Indica se a Funcao foi chamada via: 1 - Salvar Orcamento, 2 - Salvar como Venda, 3 - Salvar como Pedido
		 aSL1  := Array com a estrutura do SL1. Bidimencional: Campo, Valor
		 aSL2  := Array com a estrutura do SL2. Bidimencional: Campo, Valor
		 aSL4  := Array com a estrutura do SL4. Multimensional 
		 .T.   := Indica que é chamda do Totvspdv
@author  Varejo - Alan Oliveira
@version P12.1.17
@since   10.01.18
@return  lRet				Retorna a validacao de Credito
/*/
//-------------------------------------------------------------------
Static Function STBISValCred(ntipo,aSL1 , aSL2 , aSL4)

Local aArea 			:= GetArea()		// Armazena alias corrente
Local aRet              := {}

aRet := LJ7AvalCred(ntipo,aSL1 , aSL2 , aSL4, .T.)

RestArea(aArea)

Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} STBGetPgtCPF
Lê o conteúdo da variável lPerguntouCPF
lPerguntouCPF: Se por acaso fez a pergunta "Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?" uma vez - STR0007 

@author  Marisa Cruz
@version P12.1.23
@since   06/02/2019
@return  lPerguntouCPF  
/*/
//--------------------------------------------------------
Function STBGetPgtCPF()

Return (lPerguntouCPF) 


//--------------------------------------------------------
/*/{Protheus.doc} STBSetPgtCPF
Atribui o conteudo da variável lPerguntouCPF

@author  Marisa Cruz
@version P12.1.23
@since   06/02/2019
@return  
/*/
//--------------------------------------------------------
Function STBSetPgtCPF(lVar)

Default lVar := .F.

lPerguntouCPF := lVar

Return nil

//--------------------------------------------------------
/*/{Protheus.doc} STBGetCPFRet
Lê o conteúdo da variável lRetCpf
lRetCPF: Opção escolhida após a pergunta "Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?" - STR0007 - .T. (Sim) ou .F. (Não) 

@author  Marisa Cruz
@version P12.1.23
@since   06/02/2019
@return  lRetCpf  
/*/
//--------------------------------------------------------
Function STBGetCPFRet()

Return lRetCpf

//--------------------------------------------------------
/*/{Protheus.doc} STBSetCPFRet
Atribui o conteudo da variável lRetCpf
lRetCPF: Opção escolhida após a pergunta "Deseja Imprimir CPF/CNPJ no Comprovante da Venda ?" - STR0007 - .T. (Sim) ou .F. (Não) 

@author  Marisa Cruz
@version P12.1.23
@since   06/02/2019
@return  NIL
/*/
//--------------------------------------------------------
Function STBSetCPFRet(lVar)

Default lVar := .F.

lRetCPF := lVar

Return nil

//--------------------------------------------------------
/*/{Protheus.doc} STBGetDscImp
Lê o conteúdo da variável nDescImp
nDescImp: Armazena o valor de desconto do total da venda dos orçamentos importados

@param nenhum
@author  Varejo
@version P12
@since   14/11/2019
@return  nDescImp, numerico
/*/
//--------------------------------------------------------
Function STBGetDscImp()

Return nDescImp 

//--------------------------------------------------------
/*/{Protheus.doc} STBSetDscImp
Atribui o conteudo da variável nDescImp

@param nenhum
@author  Varejo
@version P12
@since   14/11/2019
@return  NIL
/*/
//--------------------------------------------------------
Function STBSetDscImp(nVal)

Default nVal := 0

nDescImp := nVal

Return nil

