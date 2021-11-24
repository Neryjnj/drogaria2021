#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBPAYGIFTV.CH"                       

Static oModelPgto := Nil 
//-------------------------------------------------------------------
/*/{Protheus.doc} STBValidVP
Valida se existe alguma inconsistencia do vale presente informado

@param   	cValPre - Valor vale presente
@author  	Varejo
@version 	P11.8
@since   	19/03/2013
@return	cMsg  - Mensagem	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValidVP( cValPre )

Local lContinue 		:= .F.		//Retorno da funcao RemoteExecute
Local uRet			:= Nil		//Retorno da funcao LjVldVP
Local cMsg			:= ""		//Mensagem caso haja inconsistencia do vale presente

Default cValPre := ""

ParamType 0 Var 	cValPre 	As Character	Default 	""

lContinue := STBRemoteExecute(	"LjVldVP"					,;
									{ "" , cValPre , 0 , 2 }	,;
									Nil							,;
									.F. 						,;
									@uRet			 			)

If lContinue
	cMsg := uRet
Else
	STFMessage("STBPayGiftV","STOP",STR0001) //"Nao foi possivel estabelecer conexão."
	STFShowMessage("STBPayGiftV")
EndIf

Return cMsg


//-------------------------------------------------------------------
/*/{Protheus.doc} STBValorVP
Valor do vale presente

@param   	cValPre - Valor vale presente 	
@author  	Varejo
@version 	P11.8
@since   	19/03/2013
@return	nValor  - Valor do vale presente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValorVP(cValPre)

Local lContinue 		:= .F.	//Retorno da funcao RemoteExecute
Local uRet			:= Nil	//Retorno da funcao LjVPValor
Local nValor			:= 0	//Valor do vale presente

Default cValPre := ""

ParamType 0 Var 	cValPre 	As Character	Default 	""

lContinue := STBRemoteExecute(	"LjVPValor"	,;
									{ cValPre }	,;
									Nil				,;
									.F. 			,;
									@uRet			)
									
If lContinue
	If ValType(uRet) == 'N'
		nValor := uRet
	EndIf
Else
	STFMessage("STBPayGiftV","STOP",STR0001) //"Nao foi possivel estabelecer conexão."
	STFShowMessage("STBPayGiftV")
EndIf
									
Return nValor


//-------------------------------------------------------------------
/*/{Protheus.doc} STBBaixaVP
Faz a baixa do vale presente na retaguarda

@param   	
@author  	Varejo
@version 	P11.8
@since   	20/03/2013
@return  	lRet - Retorna se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBBaixaVP()

Local lContinue 		:= .F.				//Retorno da funcao RemoteExecute
Local uRet				:= Nil				//Retorno da funcao LjGrRVP
Local nI				:= 1				//Variavel de loop
Local oMdlGrdVP 		:= STBGtMdlVP()		// VAriável para receber o valor do oMdlGrd

For nI := 1 To oMdlGrdVP:Length()
	
	oMdlGrdVP:GoLine(nI)
	
	If AllTrim(oMdlGrdVP:GetValue('L4_FORMA')) == 'VP'
	
		lContinue := STBRemoteExecute(	"LjGrRVP",;
											{ 	oMdlGrdVP:GetValue("L4_CODVP")	, STDGPBasket("SL1", "L1_OPERADO")	, STDGPBasket("SL1", "L1_DOC")	, STDGPBasket("SL1", "L1_ESTACAO"),;
												STDGPBasket("SL1", "L1_PDV")	, STDGPBasket("SL1", "L1_EMISNF")	, STDGPBasket("SL1", "L1_HORA")	, STDGPBasket("SL1", "L1_CLIENTE"),;
												STDGPBasket("SL1", "L1_LOJA")	, STDGPBasket("SL1", "L1_SERIE"), oMdlGrdVP:GetValue("L4_VALOR") },;
											Nil		,;
											.F. 	,;
											@uRet	)
	EndIf
										
Next nI

STBStMdlVP(Nil) 

Return lContinue


//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldVp
Valida se o vale presente já nao foi lancado na grid

@param   	oMdlDtl - Model de detalhes
@param   	cCodVp -  Codigo Vale presente
@author  	Varejo
@version 	P11.8
@since   	21/03/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldVp(oMdlDtl,cCodVp)

Local lRet 	:= .F.								//Variavel de retorno
Local nCont	:= 0								//Contador
Local nI		:= 0								//Variavel de loop

Default oMdlDtl 	:= Nil			
Default cCodVp	:= ""

ParamType 0 Var 	oMdlDtl 	As Object	Default Nil
ParamType 1 Var 	cCodVp 	As Character	Default 	""

For nI := 1 To oMdlDtl:Length()
	oMdlDtl:GoLine(nI)
	If Alltrim(oMdlDtl:GetValue('L4_COD')) == AllTrim(cCodVp)  
		nCont++
	EndIf 
Next nI

If nCont >= 1
	lRet := .F.
	STFMessage("STBPayGiftV","STOP",STR0002) //"Vale presente já foi informado"
	STFShowMessage("STBPayGiftV")
Else
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldValVp
Valida o valor dos vales informados

@param   	oMdlDtl - Model de detalhes 	
@author  	Varejo
@version 	P11.8
@since   	21/03/2013
@return  	lRet - Executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldValVp(oMdlDtl)

Local lRet			:= .F. 			//Variavel de retorno
Local nI			:= 0				//Variavel de loop
Local nValVps		:= 0				//Valor dos vales presentes
Local oTotal		:= STFGetTot()	//Recebe o objeto do model para recuperar os valores

For nI := 1 To oMdlDtl:Length()
	oMdlDtl:GoLine(nI)
	nValVps += oMdlDtl:GetValue('L4_VALOR') 
Next nI

If !SuperGetMv("MV_LJBXPAR",,.F.)

	If nValVps > oTotal:GetValue("L1_VLRTOT")
	
		lRet := .F.
		STFMessage("STBPayGiftV","STOP",STR0003 + AllTrim(Str(nValVps, 10, 2)); //"O valor dos vales presentes informados ("
					+ STR0004 + AllTrim(Str(oTotal:GetValue("L1_VLRTOT"), 10, 2)); //") é diferente do valor informado na forma de pagamento ("
					+ STR0005) //"). Corrija as informações antes de prosseguir."
		STFShowMessage("STBPayGiftV")
	Else
		lRet := .T.
	EndIf
	
Else	
	lRet := .T.	
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBStMdlVP
SET do objeto oMdlGrd na variável estática oModelPgto

@param   	oMdlGRd - Model da Grid de Pagamento 	
@author  	Varejo
@version 	P12.1.27
@author  	Caio Okamoto
@since   	03/11/2021
@return  	sem retorno
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBStMdlVP(oMdlGrdPg)
oModelPgto:= oMdlGrdPg
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGtMdlVP
GET do objeto oModelPgto (Model da Grid de Pagamento)

@param   	sem parametro
@author  	Varejo
@version 	P12.1.27
@author  	Caio Okamoto
@since   	03/11/2021
@return  	oModelPgto (Model da Grid de Pagamento)
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGtMdlVP()
Return oModelPgto