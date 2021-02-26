#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STFPROFILE.CH"

/*/
	Defines para tratamento do Array aRet
/*/
#DEFINE RETACCESS	01
#DEFINE SUPNAME		02

Static lNoAccess := .F. //Indica se o não tem permissao (icone vermelho na SLF)

//-------------------------------------------------------------------
/*/{Protheus.doc} STFPROFILE
Function Desconto no Total da Venda

@param1   nAccess			Numero do Acesso Desejado conforme permissoes do caixa da Tabela SLF
@param2   cCash				Caixa a ser verificado
@param3   nPercDesc			Percentual de desconto a verificar permissao
@param4   nValueDesc		Valor do desconto a verificar permissao
@param5   cTypeDesc			Tipo de desconto. Se "I" - Item, se "T" - Total
@param6   lCashSup			Indica que o caixa passado por parâmetro já é o superior
@param7   lShowMessage		Indica se exibe mensagem caso acesso negado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[01]-Tem Permissao, 
@return  aRet[02]-Nome Superior(Se precisou de autorização do superior, retorna o próprio ID do usuário)
@obs     
@sample 
/*/
//-------------------------------------------------------------------
Function STFPROFILE( nAccess, cCash, nPercDesc, nValueDesc, cTypeDesc, lCashSup, lShowMessage, nTotSale )
            
Local	lRet			:= .F.					// Retorna se tem permissao
Local	aRet			:= {}					// Array de retornos
Local	cAllAccess		:= ""					// Conteudo do campo LF_ACESSO
Local	cAccess			:= ""					// Armazena o acesso da posicao solicitada
Local	aArea			:= GetArea()			// Armazena area
Local	aAreaSLF		:= SLF->(GetArea())		// Armazena Area SLF
Local	cFormDesc   	:= SuperGetMV("MV_LJFORMD",.F.,"1")  // Valida so por um ou pelos dois
Local	cTipoDesc   	:= SuperGetMV("MV_LJTIPOD",.F.,"1")  // Valida 1- pelo % 2- pelo val
Local	nVlMaxDisc		:= 0  					// Valor Maximo de desconto permitido

Default nAccess 		:= 0				
Default nPercDesc		:= 0				
Default nValueDesc		:= 0				
Default cCash			:= ""				
Default cTypeDesc		:= ""				
Default lCashSup		:= .F.
Default lShowMessage	:= .F.			
Default nTotSale		:= 0
	

If Empty( cCash ) 
	cCash := xNumCaixa()
EndIf

DbSelectArea("SLF")
SLF->( DbSetOrder(1) )
If SLF->( DbSeek(xFilial("SLF")+cCash) )

	cAllAccess := SLF->LF_ACESSO

	cAccess := SubStr( cAllAccess , nAccess , 1)

	// Sendo "N" eh status: Acesso Negado
	lRet := cAccess <> "N"
	
	If !lRet
		lNoAccess := .F.
	Else
		lNoAccess := .T.
	EndIf
	
Else

	lRet:= .F.
	STFMessage("STFPROFILE","STOP",STR0001) //"Caixa nao encontrado"
	
EndIf
	
// Nao sendo Acesso Negado
If lRet

	Do Case 
	
		Case Empty( cAccess )
		
			If nAccess == 15 .OR. nAccess == 45 // Reabertura de Caixa ou Recebimento de titulo offline
			
				lRet := .T.
				
			ElseIf !( lCashSup )
			
				// Funcao que valida a autorizacao superior por Cartao ou Senha
				aRet := STFWVLDSUP( 	nAccess 	, cCash , nPercDesc , nValueDesc 	, ;	
										cTypeDesc											) 
										
				lRet := aRet[RETACCESS]
				
			EndIf
			
		Case cAccess == "X" .AND. nAccess <> 3
		
			If !(lCashSup)
			
				// Funcao que valida a autorizacao superior por Cartao ou Senha
				aRet := STFWVLDSUP(	nAccess	, cCash , nPercDesc , nValueDesc 	, ;	
										cTypeDesc											)
										
				lRet:= aRet[RETACCESS] 
			EndIf
		
		Case cAccess == "X" .AND. nAccess == 3
		
			lRet := .F.
			
		Case cAccess == "S"
		
			If nAccess == 11 // Desconto
			
				If cTypeDesc == "I" // ITEM
				
					If cFormDesc == "1"  // Valida ou % ou Valor
						If cTipoDesc == "1"  // Valida %
							lRet := nPercDesc <= SLF->LF_DESCPER
						ElseIf cTipoDesc == "2" // Valida Valor
							lRet := nValueDesc <= SLF->LF_DESCVAL			   
						EndIf		
					ElseIf cFormDesc == "2"	// Valida os dois % e Valor
						lRet := ( nPercDesc <= SLF->LF_DESCPER ) .AND. ( nValueDesc <= SLF->LF_DESCVAL )
					EndIf
				
					If !lRet
						If !(lCashSup)
						
							// Funcao que valida a autorizacao superior por Cartao ou Senha
							aRet := STFWVLDSUP( 	nAccess	, cCash , nPercDesc , nValueDesc 	, ;	
													cTypeDesc											)
							lRet := aRet[RETACCESS]
							
						EndIf
					EndIf
					
				ElseIf cTypeDesc == "T" // TOTAL
				
					If cFormDesc == "1"  // Valida ou % ou Valor
						If cTipoDesc == "1"  // Valida %
							lRet := nPercDesc <= SLF->LF_TOTDESP

							If !lRet .AND. nTotSale > 0 .AND. nValueDesc > 0
								// Verifica se a diferença do valor esta dentro na margem permitida de 1 centavo
								nVlMaxDisc := nTotSale * ( SLF->LF_TOTDESP / 100 )
								If nValueDesc - nVlMaxDisc <= 0.01
									lRet := .T.
								EndIf
							EndIf

						ElseIf cTipoDesc == "2" // Valida Valor
							lRet := nValueDesc <= SLF->LF_TOTDESV			   
						EndIf		
					ElseIf cFormDesc == "2"	// Valida os dois % e Valor
						lRet := ( nPercDesc <= SLF->LF_TOTDESP ) .AND. ( nValueDesc <= SLF->LF_TOTDESV )
					EndIf
					
					If !lRet
						If !(lCashSup)
						
							// Funcao que valida a autorizacao superior por Cartao ou Senha
							aRet := STFWVLDSUP( 	nAccess	, cCash , nPercDesc , nValueDesc	, ;	
													cTypeDesc 											)
							lRet := aRet[RETACCESS]
							
						EndIf
					EndIf
					
				Else
				
					STFMessage( "STFPROFILE" , "STOP" , STR0002 ) //"Parâmetro inválido. Para permissao de desconto, passar parâmetro se TOTAL ou ITEM"
					lRet := .F.
					
				Endif
				
			Else
				lRet := .T.
			EndIf
			
	EndCase
	
EndIf
 
//-----                                                                                                                   
// TODO:
// Verificar nAccess 17 -  XX-> mesmo com "N"
// Ele faz um MsgAlert("Usuário sem autorização para efetuar Cancelamento Manual de TEF","Atenção") logo após verificar o "N".
// Suposição: Onde chama(LOJXTEF) nao passa .T. para mostrar mensagem, por isso dá msgalert. vEr com o TEF 2.0 como vai ser, pq no meu caso o default é .T. pra mostrar mensagem
//-----
 
If !lRet .AND. !IsInCallStack("LoadConfig")
   	STFMessage(	"STFPROFILE"	,	"STOP" , STR0003 + " " + STR0004 + cCash + 		; //"Acesso Negado." //	"O caixa "
 																		STR0005 + 	; //" não tem permissão para executar a seguinte operação: "
 																		STFWPermis( nAccess )[2]	)
EndIf
 																		
/*/
	Caso nao venha o aRet, nao precisou de superior. Apenas adiciona o retorno.
/*/	
If Len(aRet) <= 0
	AADD( aRet , lRet 		)
	AADD( aRet , cUserName 	)
	AADD( aRet , "" 		)
EndIf

If lShowMessage	
	STFShowMessage("STFPROFILE")
EndIf
				
RestArea(aAreaSLF)
RestArea(aArea)
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWVLDSUP
Validação do Usuário Superior

@param   nAccess				Numero do Acesso Desejado conforme permissoes do caixa da Tabela SLF
@param   cCash				Caixa a ser verificado
@param   nPercDesc			Percentual de desconto a verificar permissao
@param   nValueDesc			Valor do desconto a verificar permissao
@param   cTypeDesc			Tipo de desconto. Se "I" - Item, se "T" - Total
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[01]-Tem Permissao, 
@return  aRet[02]-Nome Superior(Se precisou de autorização ao superior, retorna o próprio ID so usuário)
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFWVLDSUP( 	nAccess		, cCash , nPercDesc , nValueDesc 	, ; 
						cTypeDesc 											)
	
Local lRet		   		:= .F.						// Retorna se tem permissao
Local aRet				:= {}						// Array de retorno.
Local aArea				:= GetArea()				// Area atual
Local aAreaSLF			:= SLF->(GetArea())			// Area SLF
Local aAreaSA6			:= SA6->(GetArea())			// Area SLF
Local cTypeVal			:= "1"						// Tipo de Validacao: 1-Senha, 2-Cartao, 3-Ambos				
Local cCardSup			:= ""						// Numero do Cartao do Superior 
Local cCodSup 			:= ""						// Codigo do Supervisor
Local aUsers			:= {}						// Usuarios superiores
Local aCodSup			:= LjRetSup(1,"",@aUsers)	// Codigos dos Caixas Superiores
Local cSuperSel			:= ""						// Nome do Superior selecionado (caso tenha mais de um)
Local cNumCart 			:= ""						// Numero do cartão recebido pelo PinPad
Local lRetRegra			:= .T.						// Retorno da politica de liberação do varejo
Local lUsaTef			:= STFGetCfg("lUsaTef")		// Controla se a estação esta configurada com TEf					
Local oTef				:= STBGetTEf()				// Armazena o Objeto do TEF

Default nAccess 		:= 0				
Default cCash			:= ""				
Default nPercDesc		:= 0				
Default nValueDesc		:= 0				
Default cTypeDesc		:= ""				
	
//Seleciona o superior do caixa. Se houver mais de 1 superior,
//o caixa seleciona qual superior fara a liberacao
cCodSup	:= LjSelSup( aCodSup , @cSuperSel, aUsers )

If lUsaTef .AND. GetApoInfo("LOJA1906.PRW")[4] >= CTOD("05/12/2018") .AND. ValType(oTef) == "O" .AND. ValType(oTef:oConfig:oComSitef) == "O" .AND. oTef:oConfig:oComSitef:verPinPad() == 1

	If !Empty(cCodSup)
		dbSelectArea("SLF")
		SLF->(dbSetOrder(1))	//Filial + Caixa
		If SLF->(dbSeek(xFilial("SLF") + cCodSup))
			If SLF->LF_TPVAL $ "23"
				cTypeVal		:= SLF->LF_TPVAL													// Guarda o Tipo de Validacao
				cCardSup		:= IIF(ExistFunc("LjEncript"),LjEncript(1,SLF->LF_NUMCART),"")		// Recupera o numero do Cartao cadastrado
			EndIf
		EndIf

		RestArea(aAreaSLF)

	EndIf

EndIf

If cTypeVal $ "23" //Tipo 2 - Cartão Magnetico, 3 - Cartão Magnetico e Senha
	
	//Comunica com o PinPad e recebe o numero do Cartão
	//Obs: Apenas comunicação com CliSitef
	cNumCart :=  STFGetCart(2)
	
	If cCardSup $ cNumCart
		// Chamada para validar o acesso do superior
		If lRetRegra := STFPROFILE( nAccess , cCodSup , nPercDesc , nValueDesc , cTypeDesc , .T. )[1]
		
			lRet := .T.
			
		EndIf

		If !lRetRegra .AND. STFGetCfg("lUsaDisplay")
			DisplayEnv(StatDisplay(), "1C"+ "Acesso Superior negado"  )  
		EndIf

	EndIf

EndIf

If ((!lRet .AND. cTypeVal == "3" ) .OR. cTypeVal == "1" ) .AND. lRetRegra //Tipo 1 - Senha, 3 - Cartão Magnetico e Senha
	//Me retorna o usuario autenticado
	If FWAuthSuper(, @cSuperSel)

		//Busco o Codigo do Caixa passando o usuario recebido
		cCodSup := POSICIONE("SA6",2,xFilial("SA6") + PADR(UPPER(cSuperSel),TamSX3("A6_NOME")[1]),"A6_COD")
		lRet    := STFPROFILE( nAccess , cCodSup , nPercDesc , nValueDesc , cTypeDesc , .T. )[1]

		If !lRet .AND. STFGetCfg("lUsaDisplay")
			DisplayEnv(StatDisplay(), "1C"+ "Acesso Superior negado"  )
		EndIf

	EndIf
EndIf

If !lRet
	STFMessage( ProcName(), "POPUP", STR0095 )//"Acesso do Superior negado, verifique permissões"
	STFShowMessage(ProcName())
EndIf

AADD( aRet , lRet )
AADD( aRet , cSuperSel ) 	// Caso seja negado acesso, nao retorna o nome do superior
AADD( aRet , cCodSup ) 		// Codigo do Supervisor

RestArea(aAreaSA6)	
RestArea(aAreaSLF)
RestArea(aArea)
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWPermis
Busca Descrição da Permissão de Acesso

@param   nAccess				Numero do Acesso Desejado conforme permissoes do caixa da Tabela SLF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet	Retorna Todos os registros ou apenas o solicitado
@obs      Se passado o acesso desejado o retorno será o registro do acesso. Caso não seja passado, o retorno será todos os registros.  
@sample
/*/
//-------------------------------------------------------------------
Function STFWPermis( nAccess )

Local aRet 		:= {}				// Retorno da função
Local lFinServ	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro

Default nAccess		:= 0				
	
ParamType 0 var  nAccess 		As Numeric		Default 0
	
AADD( aRet , {  1 , STR0006   					,	STR0007 				,	STR0008			} )     //"Verificacao do caixa se tem analise de credito" 
AADD( aRet , {  2 , STR0009              		,	STR0010   				,	STR0011			} )     //"Caixa tem acesso a utilizar o sistema de TEF"
AADD( aRet , {  3 , STR0012      				,	STR0013  				,	STR0014			} )     //"Caixa tem acesso a utilizar Impressora Fiscal"
AADD( aRet , {  4 , STR0015    					,	STR0016             	,	STR0017			} )     //"Acesso para abrir e fechar o caixa"
AADD( aRet , {  5 , STR0018        				,	STR0019   				,	STR0020			} )     //"Acesso para fazer sangria e entrada de troco"
AADD( aRet , {  6 , STR0021            			,	STR0022               	,	STR0023			} )     //"Acesso para fazer Redução Z"
AADD( aRet , {  7 , STR0024    					,	STR0025                	,	STR0026			} )     //"Acesso para cancelar item"
AADD( aRet , {  8 , STR0027   					,	STR0028                 ,   STR0029			} )     //"Acesso para cancelar o cupom" 
AADD( aRet , {  9 , STR0030     				,	STR0031   				,	STR0032			} )     //"Acesso para alterar parcelas na venda balc„o"
AADD( aRet , { 10 , STR0033 					,	STR0034        			,	STR0035			} )     //"Acesso para sair da tela de Atendimento"
AADD( aRet , { 11 , STR0036    					,	STR0037                 ,	STR0038			} )     //"Acesso para efetuar descontos"
AADD( aRet , { 12 , STR0039   					,	STR0040   				,	STR0041			} )     //"Acesso para acessar a tecla de funções (F12)"
AADD( aRet , { 13 , STR0042   					,	STR0043                 ,	STR0044			} )     //"Acesso para abrir Gaveta"
AADD( aRet , { 14 , STR0045 					,	STR0046  				,	STR0047	  		} )     //"Acesso para realizar atualizacao geral no Check-Out" 
AADD( aRet , { 15 , STR0048 					,	STR0049              	,	STR0050			} )     //"Acesso para liberar financiamento"
AADD( aRet , { 16 , STR0051  					,	STR0052                	,	STR0053			} )     //"Acesso para Reabrir o Caixa" 
AADD( aRet , { 17 , STR0054     				,	STR0055			   		,	STR0056			} )     //"Acesso para Cancelar Transação TEF"
AADD( aRet , { 19 , STR0057  					,	STR0058                	,	STR0059			} )     //"Acesso para liberar vale compra"
AADD( aRet , { 20 , STR0060    					,	STR0061 				,	STR0062			} )     //"Acesso para Liberar Cancelamento Automatico"
AADD( aRet , { 21 , STR0063            			,	STR0064      		  	,	STR0065			} )     //"Acesso para fazer Leitura X"
AADD( aRet , { 22 , STR0066	 					,	STR0067		   			,	STR0068			} )     //"Acesso para Liberar sem Senha do Superior na NCC"
AADD( aRet , { 23 , STR0069  					,	STR0070		    		,	STR0071			} )     //"Acesso para inativar Vale-Presente"
AADD( aRet , { 24 , STR0072						,	STR0073	   				,	STR0074			} )     //"Acesso para reprocessar orcamentos em aberto na Reducao Z"
AADD( aRet , { 25 , STR0075		   				,	STR0076					,	STR0077			} )     //"Acesso para efetuar o fechamento de caixa simplificado"
AADD( aRet , { 26 , STR0078						,	STR0079					,	STR0080			} )     //"Acesso para Alterar Numero do Formulario"
AADD( aRet , { 27 , STR0081						,	STR0082	   				,	STR0083			} )     //"Acesso a Cancelamento de Credito da Lista de Presentes"
AADD( aRet , { 28 , STR0084						,	STR0085					,	STR0086			} )     //"Acesso para realizar venda sem impressao"
AADD( aRet , { 29 , STR0087						,	STR0088					,	""				} )     //"Acesso para estonar uma venda"
AADD( aRet , { 30 , STR0089						,	STR0090					,	STR0091			} )     //"Acesso a Impressora não fiscal para Australia"
AADD( aRet , { 31 , STR0092						,	STR0093	 				,	""				} )     //"Acesso à rotina de aprovação da análise de crédito manual"

If lFinServ
	AADD( aRet , { 38 , STR0094					,STR0094,	""									} )   	//"Acesso a venda de serviço financeiro"
EndIf

AADD( aRet , { 41 , STR0096						,STR0096,	""									} )  	//"Acesso para limpar Formas de Pagamento - TotvsPdv"

If HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())
	aAdd(aRet, {42,"Acesso para movimentar produtos controlados(Template de Drogaria)",;
				"Acesso para movimentar produtos controlados(Template de Drogaria)",;
				"Acesso para movimentar produtos controlados(Template de Drogaria)",}) 	//#"Acesso para movimentar produtos controlados(Template de Drogaria)"
EndIf

aAdd( aRet , { 44 , STR0097						,STR0097					,	STR0097,		} )		//"Altera Parcelas(TEF) de um orçamento importado no TOTVS PDV"
aAdd( aRet , { 45 , STR0103						,STR0103					,	STR0103,		} )		//"Permite o recebimento de titulos offline no TOTVS PDV"

If ( nAccess > 0 ) .AND. aScan( aRet , { |x| x[1] == nAccess } ) > 0
	aRet := aRet[aScan( aRet , { |x| x[1] == nAccess } )] 
EndIf



Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFUseFiscalPrinter
Verifica se utiliza impressora fiscal

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lUse					Retorna se utiliza impressora fiscal
@obs     						  
@sample
/*/
//-------------------------------------------------------------------
Function STFUseFiscalPrinter()

Local lUse	:= .F.			// Retorna se utiliza impressora fiscal
Local aRet  := {}			// Array de retornos

/* 
	Importante esta rotina deve ser chamada após a abertura do perioférico na rotina OpenDevice
*/
 									 
If STFGetCfg("lUseECF")   
	aRet := STFFireEvent(	ProcName(0)																	,;		// Nome do processo
 									"STIsTaxPrinter"																,;		// Nome do evento
 									{"" } )	 
 									
	If (Len(aRet) > 0 .AND.  ValType(aRet[1]) == "L" .AND. aRet[1]) // Verifica permissão se usuário é caixa.
		lUse := .T.  
	Else 
		lUse := .F.
	EndiF 
	
Else
	lUse := .F.
EndIf

Return lUse 


//--------------------------------------------------------
/*/{Protheus.doc} STFUserProfInfo
Retorna informacoes do usuario

@param   	uCampos	 - Informa o campo ou os campos que deseja retornar o valor da SLG
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	uReturn - Retorna o valor do campo ou dos campos que foi solicitado na funcao
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFUserProfInfo(uCampos)

Local aArea			:= GetArea() 				//Salva area
Local uReturn		:= ""						//Retorno da funcao
Local nI			:= 0 						//Variavel de loop
Local xRet			:= ""						//Variavel que armazena o nome do campo
Local cUserPDV 		:= ""    					//Usuario
Local IsFly01		:= ExistFunc("ISFly01") .AND. ISFly01() //Versao Fly01?
Local lMobile 		:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile Pdv Mobile?

Default uCampos  	:= Nil

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Posiciona na SA6
xNumCaixa()	

//Versao Fly busca usuario especifico
If lMobile .AND. IsFly01
	cUserPDV := "USR"
Else
	cUserPDV := SA6->A6_COD	
EndIf
	
DbSelectArea("SLF")                                      
SLF->(DbSetOrder(1))//LF_FILIAL+LF_COD

If SLF->(DbSeek( xFilial("SLF")+ cUserPDV ))

	If ValType(uCampos) == "A"
	
		uReturn := {}
		
		For nI := 1 To Len(uCampos)
		
			xRet := FieldGet( FieldPos( If(! Left(uCampos[nI],3) == "LF_","LF_","") + uCampos[nI]))
			
			If ValType(xRet) == "C" 
				xRet := xRet
			EndIf
			
			AAdd(uReturn,xRet)
			
		Next nI			
	
	Else
		
		uReturn := FieldGet( FieldPos( If(! Left(uCampos,3) == "LF_","LF_","") + uCampos))		

		If Valtype(uReturn) == "C" 
			uReturn := uReturn
		EndIf
				
	EndIf
	
EndIf

RestArea(aArea)	
	
Return uReturn

//--------------------------------------------------------
/*/{Protheus.doc} STFAccess
Retorna se o usuario nao tem acesso

@param   	
@author  	bruno.almeida
@version 	P12
@since   	21/06/2018
@return  	lNoAccess - Se retornar .F. o usuario nao tem acesso
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFAccess()
Return lNoAccess 

//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetCart
Funcao responsavem por realizar a cominicação com Pinpad devolvendo criptografada ou não a trilha do cartão

@type function
@param nEncript, Numérico, Determina a ação da função aonde:
0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String

@author Lucas Novais (lnovias)
@version P12
@since 27/11/2018
@return cNumCart, Retorna o numero do cartão criptografado ou 
apenas o numero do cartão dependendo do parametro recebido pelo nEncript
/*/
//-------------------------------------------------------------------

Function STFGetCart(nEncript)

Local cNumCart 		:= ""										//Numero do Cartão retornado pelo PinPad
Local nHandle 		:= -1										//Variavel de controle de retorno da DLL
Local cTrilha1 		:= Space(150)								//Variavel Obrigatoria para a DLL
Local cTrilha2 		:= Space(150)								//Variavel Obrigatoria para a DLL
Local lTentativa 	:= .T.										//Variavel para controle de tentativas.
Local lUsaTef		:= STFGetCfg("lUsaTef")						//Indica se usa TEF
Local oTef			:= STBGetTEf()								//Retorna objeto Tef

Default nEncript := 1 											//Tipo de tratamento a ser feito, aonde: 0 Encript, Descripta, 1 incripta e  2  Apenas Limpa a String

	/*/	Verifica se o Pinpad esta configurado. /*/
If lUsaTef .AND. GetApoInfo("LOJA1906.PRW")[4] >= CTOD("05/12/2018") .AND. ValType(oTef:oConfig:oComSitef) == "O" .AND. oTef:oConfig:oComSitef:verPinPad() == 1
	
	/*/ Le o cartao do superior, e verifica se confere
	com o cartao cadastrado no SLF. /*/
	
	While lTentativa
			
		LjMsgrun(STR0098,, {|| nHandle := oTef:oConfig:oComSitef:LeCartao(STR0099, @cTrilha1, @cTrilha2) } ) //"Passe o cartão superior no PinPad." ### "Passe o Cartao"
		
		If nHandle == 0
			lTentativa 	:= .F.
			cNumCart 	:= cTrilha1 + cTrilha2
			cNumCart 	:= LjEncript(nEncript,cNumCart)
		Else 
			STFMessage("STFGetCart","YESNO",STR0100) //"Não foi possivel receber a senha do usuario pelo PinPad, deseja tentar novamente?"
			If STFShowMessage("STFGetCart")	
				lTentativa := .T.
			Else
				lTentativa := .F.
			EndIf
		EndIf
	End
ElseIf lUsaTef .AND. GetApoInfo("LOJA1906.PRW")[4] >= CTOD("05/12/2018") .AND. !ValType(oTef:oConfig:oComSitef) == "O"
	STFMessage("STFGetCart","ALERT", STR0102) //"Verifique sua configuração do TEF, funcionalidade apenas disponivel para CLISITEF"
	STFShowMessage("STFGetCart")	
Else
	STFMessage("STFGetCart","ALERT", STR0101) //"Sitef ou Pinpad não configurado. Verifique suas configurações de estação da aba TEF"
	STFShowMessage("STFGetCart")	
EndIf


Return cNumCart