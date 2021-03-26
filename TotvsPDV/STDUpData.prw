#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STDUPDATA.CH"
#INCLUDE "TBICONN.CH"

STATIC _nMaxRegUp := 300

//===================================================
// 				Situacoes do _SITUA                             
//
// "  " - Base Errada, Registro Ignorado.          
// "00" - Venda Efetuada com Sucesso               
// "01" - Abertura do Cupom Nao Impressa           
// "02" - Impresso a Abertura do Cupom             
// "03" - Item Nao Impresso                        
// "04" - Impresso o Item                          
// "05" - Solicitado o Cancelamento do Item        
// "06" - Item Cancelado                           
// "07" - Solicitado o Cancelamento do Cupom  
// "08" - Cupom Cancelado                          
// "09" - Encerrado SL1 (Nao gerado SL4)           
// "10" - Encerrado a Venda                        
//        Pode nao ter sido impresso o cupom       
// "TX" - Foi Enviado ao Server (Pdv)
// "ER" - Erro ao envia ao server (Pdv)  
// "EP" - Erro de processamento da venda (Pdv)
// "RE" - Ja foi feita nova tentativa de subir  (Pdv)                      
// "RX" - Foi Recebido Pelo Server (Server)                 
// "OK" - Foi Processado no Server (Serevr)               
// "OR" - Venda Salva como Orcamento         
//        Enviar um OK ao Client que foi Processado 
// "CP" - Recebido pela Central de PDV
// "RY" - Cancelamento Nfc-e
// "CX" - Cancelamento enviado first
// "C0" - Cancelamento a enviar first
// "65" - Gravação das tabelas para transmissão da NFC-e
//---------------------------------------------------
//  Status da transmissão por NFCe Dll que não vão para retaguarda - interno TotvsPDV Mobile
// "D1" - NFCe Dll - Contingencia off-line - Envia NFCe em contingência e consulta Status da NFce para então enviar para retaguarda
// "D0" - NFCe Dll - Contingencia on-line - Consulta Status da NFce para então enviar para retaguarda
// "I8" - NFCe Dll - Inutilização não realizada - Tentar novamente - Se deu certo envia venda inutilizada para retaguarda
// "DC" - NFCe Dll - Cancelamento on line realizado de Nota não enviada - envia o cancelamento novamente
// "DX" - NFCe Dll - Cancelamento on line realizado de Nota enviada - consulta status da nfce antes de enviar a retaguarda
// "D7" - NFCe Dll - Cancelamento offline - não enviado - envia o cancelamento em contigencia e depois consulta o status
// "D8" - NFCe Dll - Cancelamento  on line não realizado de nota enviada - tenta realizar o cancelamento e consulta o status
// "D9" - NFCe - Cancelamento on line não realizado de nota NÃO enviada - tenta cancelar a nota e consulta o status
//===================================================


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSalesForUp
Realiza a gravacao da venda no BackOffice

@param cEstacaoIni			Codigo da estacao

@author  Varejo
@version P11.8
@since   09/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSalesForUp( cEstacaoIni )                      

Local aSL1			:= {}	//	array com dados da SL1
Local aSL2			:= {}	//	array com dados da SL2
Local aSL4			:= {}	//	array com dados da SL4
Local lEncontrou 	:= .T.	//	Se encontrou registro
Local nX	 		:= 1	//	Contador
Local cL1_NUM		:= "" 	// 	Numero da venda encontrada
Local lHasConnect	:= .T.	// Verifica se tem comunicacao

Default cEstacaoIni := "001"

cPdv := cEstacaoIni // Carrega numero do PDV		

while lEncontrou .AND. ( nX <= _nMaxRegUp )

	Sleep(1000)

	aSL1		:= {}	
	aSL2		:= {}
	aSL4		:= {}
	cL1_NUM	:= ""

	aSL1 := STDSL1Create(@lEncontrou, @cL1_NUM)	//Recebe o Número do Orçamento gerado

	If lEncontrou
		aSL2 :=  STDSL2Create(@lEncontrou, cL1_NUM) //Passa o Número do Orçamento gerado
	EndIf
	
	If lEncontrou
		aSL4 :=  STDSL4Create(@lEncontrou, cL1_NUM) //Passa o Numero do Orçamento gerado
	EndIf
	
	If lEncontrou
	
		lHasConnect := .T.	// Inicia sempre com a premissa que tem conexao 					  	
		STDUpdSaleLocal( aSL1 		, aSL2 , aSL4 , cEstacaoIni,;
						 cL1_NUM 	, @lHasConnect )
		If !lHasConnect
			Exit 
		EndIf	
	ElseIf Len(aSL1) > 0 .AND.  Len(aSL2) == 0 
		
		//Venda Incompleta sera marcada como 'ER'
		cL1_NUM	:= aSL1[AScan(aSL1,{|x|x[1]=="L1_NUM"})][2]
	
		DbSelectArea("SL1")
		DbSetOrder(1) //L1_FILIAL+L1_NUM
		If DbSeek( xFilial("SL1") + cL1_NUM ) 
		
			If RecLock( "SL1", .F. )
				REPLACE SL1->L1_SITUA	WITH "ER"
				DbCommit()
				MsUnLock()
				STDLogCons( STR0019 + cL1_NUM  + STR0020 )//"Venda: " ###  " Incompleta gravada como Erro"
			EndIf
		
		EndIf
		
		lEncontrou := .T. //Para Permanecer no laco no reinicio
			
	//PARA OS CASOS QUE NAO SE GRAVA O SL4 E NAO EH PAGTO COM NCC NAO DEVO SUBIR A VENDA 
	ElseIf Len(aSL1) > 0 .AND. Len(aSL2) > 0 .AND. Len(aSL4) == 0 
		//Venda Incompleta sera marcada como 'ER'
		cL1_NUM	:= aSL1[AScan(aSL1,{|x|x[1]=="L1_NUM"})][2]
	
		DbSelectArea("SL1")
		DbSetOrder(1) //L1_FILIAL+L1_NUM
		If DbSeek( xFilial("SL1") + cL1_NUM ) 		
			If SL1->L1_CREDITO > 0 				
				lEncontrou := .T.
			Else
				If RecLock( "SL1", .F. )
					REPLACE SL1->L1_SITUA	WITH "ER"
					DbCommit()
					MsUnLock()
					STDLogCons( STR0019 + cL1_NUM  + STR0020 )//"Venda: " ###  " Incompleta gravada como Erro"
				EndIf
		    EndIf		
		EndIf
		
		lEncontrou := .T. //Para Permanecer no laco no reinicio
			
	EndIf
	Sleep(1000)	
	
	nX++
	
EndDo

//Sinaliza as vendas para serem re-enviadas
SL1->(DbSetOrder(9)) //L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC   

// Procura registro com erro de envio
// Procura registros erro de processamento
SL1->(DbSeek(xFilial("SL1")+"RE"))

Do While SL1->(!Eof() .AND. L1_FILIAL +L1_SITUA == xFilial("SL1")+"RE")
		RecLock("SL1", .F.)
		SL1->L1_SITUA := "EP"
		SL1->(MsUnLock())
		SL1->(DbSkip())
		SL1->(DbSeek(xFilial("SL1")+"RE"))
EndDo

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSL1Create
Busca Vendas para subir ao BackOffice

@param lEncontrou		Indica se encontrou a venda - Variavel usada por referencia

@author  Varejo
@version P11.8
@since   09/01/2013
@return  aSL1		array com dados da SL1
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSL1Create( lEncontrou, cL1_NUM )  
  
Local aArea			:= GetArea()	// Armazena alias corrente
Local nCampos 		:= 0      		// Quantidade de campos do filtro atual
Local aSL1			:= {}     		// Array do Alias
Local i				:= 0			// Contador
Local lCentPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV 
Local lFirst		:= .F. 			//Integração First
Local cIntegration	:= "" 			//Tipo de Integração
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local cFieldName	:= ""			// Armazena o nome do campo

Default lEncontrou	:= .F.
Default cL1_NUM		:= ""

ParamType 0 var  	lEncontrou		As Logical	 Default 	.F.
ParamType 1 var 	cL1_NUM		As Character Default ""

lEncontrou := .F.

If ExistFunc("STFCfgIntegration")	
	cIntegration := STFCfgIntegration()
Endif

lFirst := cIntegration == "FIRST" 

DbSelectArea("SL1")
SL1->( DbSetOrder(9) )	//L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC   

// Procura registro com erro de envio
// Procura registros erro de processamento
If !lEncontrou
	lEncontrou := DbSeek(xFilial("SL1")+"EP")
EndIf

//Procura Vendas 
If !lEncontrou 
	If lCentPDV
		lEncontrou := SL1->( DbSeek(xFilial("SL1")+"CP") )
	Else 
		lEncontrou := SL1->( DbSeek(xFilial("SL1")+"00") )
	EndIf	
EndIf

If !lEncontrou .AND. lFirst
	lEncontrou := SL1->( DbSeek(xFilial("SL1")+"C0") )	//Cancelamento via first - reenvio
EndIf

//Verifica venda salva como orcamento 
If !lEncontrou .AND. lSaveOrc
	lEncontrou := SL1->( DbSeek(xFilial("SL1")+"OR") )	
EndIf

If lEncontrou
	cL1_NUM := SL1->L1_NUM
	
	nCampos := FCount() 	
	aSL1 	:= Array(nCampos)
	
	For i := 1 To nCampos		

		cFieldName := FieldName(i)

		/* Não manda o conteudo dos campos Log de Inclusao/Alteracao, pois senao 
		gera um erro na subida da venda por causa dos caracteres especiais.
 		Além disso,seu conteudo seria sobrescrito ao gravar na retaguarda */
		If cFieldName $ "L1_USERLGI|L1_USERLGA"
			aSL1[i] := { cFieldName, "" }
		ElseIf cFieldName $ "L1_CONTCDC" 
			If !Empty(FieldGet(i)) .AND. Type(FieldGet(i))== "N"
				aSL1[i] := { cFieldName,  PadL(Val(FieldGet(i)), TamSx3("L1_CONTCDC")[1],"0") }
			Else
				aSL1[i] := { cFieldName, FieldGet(i) } 
			EndIf
		Else
			aSL1[i] := { cFieldName, FieldGet(i) }
		EndIf

	Next i    
	
	// Salva origem da venda
	If SL1->L1_OPERACA != "C"
		aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2] := SL1->L1_NUM
	EndIf
	
	If lCentPDV //Para buscar o orcamento pelo DOC e Serie e evitar vendas "DU"
		aSL1[AScan(aSL1,{|x|x[1]=="L1_OPERACA"})][2] := ""    
	EndIf

	//Apaga Possiveis mensagens de erro gravada como Log
	//pois o campo será reaproveitado na retaguarda e devera estar vazio
	If SL1->(FieldPos("L1_ERGRVBT") > 0)		
		aSL1[AScan(aSL1,{|x|x[1]=="L1_ERGRVBT"})][2] := ""
	EndIf	

EndIf  

RestArea(aArea)

Return aSL1

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSL2Create
Busca Vendas para subir ao BackOffice

@param lEncontrou		Indica se encontrou a venda - Variavel usada por referencia

@author  Varejo
@version P11.8
@since   09/01/2013
@return  aSL2		array com dados da SL2
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSL2Create( lEncontrou, cL1_NUM)     

Local aArea			:= GetArea()	// Armazena alias corrente
Local nCampos 		:= 0			// Quantidade de campos do filtro atual
Local aSL2			:= {}			// Array do Alias
Local i				:= 0			// Contador
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local xValue

Default lEncontrou := .F.
Default cL1_NUM := ""

If !Empty(cL1_NUM)
	DbSelectArea("SL2")
	DbSetOrder(1)//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	If DbSeek(xFilial("SL2")+cL1_NUM)
	
		lEncontrou := .T.
		nCampos := FCount()
		aSL2 	:= {Array(nCampos)} 
		
		For i := 1 To nCampos	
			aSL2[1][i] := FieldName(i)	
		Next i
		
		While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cL1_NUM .AND. !EOF()
          
			//Traz registros deletados, porem so considera itens L2_VENDIDO = "S"
			If (SL2->L2_VENDIDO == "S" .AND. SL2->L2_SITUA <> "05") .OR. ; //  ignora Registros cancelados no orçamento
				(lSaveOrc .AND. Empty(SL2->L2_VENDIDO))	  //Se salva como orcamento sobe item  
			
				AAdd(aSL2, Array(FCount()))
				
				For i := 1 To nCampos  
					
					// O campo descricao pode ter caracter especial, nesse caso remove
					If aSL2[1][i] == "L2_DESCRI" .AND. ExistFunc("LjRmvAcent")
						xValue := LjRmvAcent( FieldGet(i) )
					// Busque a explicacao no comentario do trecho "L1_USERLGI|L1_USERLGA"					
					ElseIf aSL2[1][i] $ "L2_USERLGI|L2_USERLGA" 
						xValue := ""
					Else
						xValue := FieldGet(i)
					EndIf

					aSL2[Len(aSL2)][i] := xValue
				Next i				
			EndIf

			SL2->(DbSkip())	 				
		EndDo
	Else
		lEncontrou := .F.
	EndIf	
Else
	lEncontrou := .F.
EndIf

RestArea(aArea)

Return aSL2


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSL4Create
Busca Vendas para subir ao BackOffice

@param lEncontrou		Indica se encontrou a venda - Variavel usada por referencia

@author  Varejo
@version P11.8
@since   09/01/2013
@return  aSL4		array com dados da SL4
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSL4Create( lEncontrou, cL1_NUM )   

Local	aArea		:= GetArea()		// Armazena alias corrente
Local nCampos 	:= 0        // Quantidade de campos do filtro atual
Local aSL4		:= {}      	// Array do Alias
Local i			:= 0		// Contador

Default lEncontrou := .F.
Default cL1_NUM := ""

If !Empty(cL1_NUM)
	DbSelectArea("SL4")
	DbSetOrder(1) //L4_FILIAL+L4_NUM+L4_ORIGEM
	If DbSeek(xFilial()+cL1_NUM)
	
		lEncontrou := .T.
	
		nCampos := FCount()
		aSL4 := {Array(nCampos)}
			
		For i := 1 To nCampos
			aSL4[1][i] := FieldName(i)
		Next i
		
		While SL4->( !EOF() ) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cL1_NUM
			AAdd(aSL4, Array(nCampos))
			 
			For i := 1 To nCampos
				
				// Busque a explicacao no comentario do trecho "L1_USERLGI|L1_USERLGA"
				If aSL4[1][i] $ "L4_USERLGI|L4_USERLGA" 
					aSL4[Len(aSL4)][i] := ""
				Else
					aSL4[Len(aSL4)][i] := FieldGet(i)
				EndIf

			Next i     
					
			SL4->( DbSkip() )
		EndDo
		
	ElseIf SL1->L1_CREDITO > 0
		lEncontrou := .T.
	Else
		lEncontrou := .F.
	EndIf

Else
	lEncontrou := .F.
EndIf		

RestArea(aArea)

Return aSL4
 
//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpdSaleLocal
Gera valor dos campos do sl1 sl2 e sl4
Atualiza situacao das tabelas locais que ja subiram para o server

@param aSL1			Array da venda SL1
@param aSL2			Array da venda SL2
@param aSL4         Array da venda SL4
@param cEstacaoIni  Estacao

@author  Varejo
@version P11.8
@since   09/01/2013
@return  Nil
@obs   

Situacoes do cStatusNum : 
"OK|"+L1_NUM  	= Venda subiu com sucesso  
"BX|"+L1_NUM   	= Tentativa de duplicar. A venda ja consta no servidor
"ERRO" 			= Erro ao subir venda 
  
@sample
/*/
//-------------------------------------------------------------------
Function STDUpdSaleLocal( aSL1 		, aSL2 , aSL4 , cEstacaoIni, ;
						  cL1_NUM 	, lHasConnect)                                  

Local aArea				:= GetArea()	// Armazena alias corrente
Local cEstacao			:= ""       	// Estacao
Local aUpdSL1			:= {} 			// Array para Atualizacao da SL1
Local cStatusNum   		:= "" 			// 	Recebe Status + Numero da venda 
Local cNum		   		:= "" 			// 	Numero da venda da cStatusNum apos retirar caracteres especiais
Local cNumSaleConf  	:= "" 			// 	Recebe numero da venda confirmada no server
Local lContinua  		:= .F.			// Controle de execucao
Local lComCPDV			:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[2] , .F. ) // Usa comunicacao com a central 
Local lFirst			:= .F.
Local cIntegration		:= ""
Local cRotinaExec		:= ""
Local nCodRet			:= 0
Local lSaveOrc			:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local cDescError   		:= "" 			// 	Guarda descricao do erro do componente de comunicação  
Local lHostError		:= .F.			// Controla se houve erro na execucao do host

Default lHasConnect		:= .T.
Default aSL1 			:= {}
Default aSL2 			:= {} 
Default aSL4 			:= {}
Default cEstacaoIni 	:= ""
Default cL1_NUM			:= ""


/*
	Adicionado RecLock devido a um problema no cancelamento do cupom.											
	Apos incluir uma venda, e nao tiver dado tempo para a gravacao do pacote no server,
	o cancelamento	nao era feito no server, causando problemas de sincronizacao de base.
*/  

If ExistFunc("STFCfgIntegration")	
	cIntegration := STFCfgIntegration()
Endif

lFirst := cIntegration == "FIRST" .AND. ExistFunc("STDUpFirstSale")

//voltar a workarea sl1-> (9)

DbSelectArea( "SL1" )
If !Empty(cL1_NUM) .AND. !(AllTrim(cL1_NUM) == AllTrim(SL1->L1_NUM))
	SL1->( DbSetOrder(1) )
	SL1->( DbSeek(xFilial("SL1") + cL1_NUM) )
EndIf

If RecLock( "SL1", .F. )
	LjGrvLog( cL1_NUM, "Antes do envio da venda para a retaguarda" )
	LjGrvLog( cL1_NUM, "Num DOC da Venda "+SL1->L1_DOC )
	// Realizado comunicacao via componente de comunicacao para Gravar a venda
	If !lFirst
		If lComCPDV
			//Se usa a Central de PDV executa outra rotina para evitar erro no componente                              
			cRotinaExec := "_GeraL1L2L4"
		Else
			cRotinaExec := "GeraL1L2L4"
		EndIf
		lContinua := STBRemoteExecute(	cRotinaExec, { aSL1, aSL2, aSL4, cEstacaoIni}	, NIL			, .F. 		,;
								 		@cStatusNum, /*cType*/  						, /*cKeyOri*/	, @nCodRet	,;
								 		@cDescError)
	Else
		lContinua := STDUpFirstSale( aSL1, aSL2, aSL4, cEstacaoIni, @cStatusNum )
	EndIf	
	
	LjGrvLog( cL1_NUM, "Retorno logico do envio da venda",lContinua)
	LjGrvLog( cL1_NUM, "Retorno string do envio da venda",cStatusNum)
	LjGrvLog( cL1_NUM, "Codigo retorno da execucao na retaguarda",nCodRet)

	// Se retornar esses codigos siginifica que a retaguarda ta fora, provavelmente tava online (pq se nao nem chegaria aqui )
	// e depois perdeu, tratamos todos esses codigos, mais o correto é o frame nos retornar apenas -105 que eh significa
	// sem comu , porem vimos que para WS pode retornar tb -107 e -104 que esta errado, porem tratamos mesmo assim 
	lHasConnect := !(nCodRet == -105 .OR. nCodRet == -107 .OR. nCodRet == -104)  
	
	// Verifica erro de execucao por parte do host
	//-103 : Ocorreu um erro na execução da funcionalidade
	//-106 : 'Não foi possível deserializar os parametros (JSON)			
	lHostError := (nCodRet == -103 .OR. nCodRet == -106)  
	
	If ValType( cStatusNum ) == "C" .AND. lHasConnect .AND. !lHostError //tem comunic com a Ret e nao teve erro
		// Verifica se a venda subiu com Sucesso "OK"
		If Left( cStatusNum, 2 ) == "OK"
			cNum := Substr( cStatusNum, 4, 6 ) 
			If !Empty( cNum )
				// Realizado comunicacao via componente de comunicacao  
				// Confirma se a venda foi e criada retornando o numero da mesma
				If !lFirst .AND. !lSaveOrc 
					If lComCPDV
						cRotinaExec := "_ConfL1L2L4" //Se usa a Central de PDV executa outra rotina para evitar erro no componente
					Else
						cRotinaExec := "ConfL1L2L4"
					EndIf
					lContinua := STBRemoteExecute(cRotinaExec, { cNum , cEstacaoIni } , NIL, .F. , @cNumSaleConf )
				Else
					cNumSaleConf := cNum				
				EndIf		
			    
			   	LjGrvLog( cL1_NUM, "Ret da confirmacao da vend",lContinua)
				LjGrvLog( cL1_NUM, "Ret string da confirmacao da venda",cStatusNum)
			    //Restaura area anterior	
				RestArea(aArea)	
			    DbSelectArea( "SL1" )

			    If ValType( cNumSaleConf ) == "C"

			    	If cNum <> cNumSaleConf
						// Erro ao confirmar a gravacao do Orcamento "
						STDLogCons( STR0002 + SL1->L1_NUM + "." ) //"Erro ao confirmar a gravacao do Orcamento "
						LjGrvLog( SL1->L1_NUM,"Orc diferente "+cNum+" e cNumSaleConf "+cNumSaleConf)						
					Else 

						// Verifica se houve o cancelamento da Venda antes de mudar o _SITUA  
						// Se Houve, sera enviado o cancelamento via SLI
						If SL1->L1_STORC == "C" .AND. !lFirst
							aUpdSL1 :=	{	{ "L1_NUMORIG", cNumSaleConf	},;
											{ "L1_SITUA"	, "07" 			}	} // "07" - L1_SITUA padrao para Venda Cancelada
						Else  
							aUpdSL1 := { 	{ "L1_NUMORIG", cNumSaleConf 	}	, ;
									   		{ "L1_SITUA", IIF(!lFirst .OR. SL1->L1_SITUA <> "C0" ,"TX", "CX") 		} 	} // "TX" - Foi Enviado ao Server	/ "CX" - Cancelamento enviado ao server								   		
						EndIf

						aEval( aUpdSL1 , { |x| FieldPut( FieldPos( x[1] ), x[2] ) } ) 

						STDLogCons( STR0003 + SL1->L1_NUM + STR0004  ) //"Orcamento gravado com sucesso."
						LjGrvLog( SL1->L1_NUM,"Orcamento gravado com sucesso.")
					EndIf  
				EndIf
			EndIf
		Else
			If Left( cStatusNum, 2 ) == "BX"
				aUpdSL1 := { { "L1_SITUA", "DU" } } // "DU" - Orcamento duplicado no server
				aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
				LjGrvLog( SL1->L1_NUM, "Retorno DU na estacao")				
			ElseIf Left( cStatusNum, 2 ) == "ER" 
				LjGrvLog( SL1->L1_NUM, "Retornou erro no processamento da venda grava como ER. " + cStatusNum )
				aUpdSL1 := { { "L1_SITUA", "ER"} } // "ER" - Erro ao gravar no server
				If SL1->L1_SITUA <> "TX"
					aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
				Else
					LjGrvLog( SL1->L1_NUM, "Venda ja subiu - SL1->L1_SITUA:", SL1->L1_SITUA)	
				EndIf	
				If SL1->(FieldPos("L1_ERGRVBT") > 0)				
					aUpdSL1 := { { "L1_ERGRVBT", Left(cStatusNum,TamSX3("L1_ERGRVBT")[1]) } } // "ER" - Erro ao gravar no server
					aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
				EndIf	
			Else
				//Se tiver como EP siginifica que eh a segunda vez que da erro na subida, ai fica ER
				If SL1->L1_SITUA == "EP"
					LjGrvLog( SL1->L1_NUM, "Retorno inesperado novamente grava como ER")
					aUpdSL1 := { { "L1_SITUA", "ER"} } // "ER" - Erro ao gravar no server
				Else
					LjGrvLog( SL1->L1_NUM, "Retorno inesperado grava como RE")
					aUpdSL1 := { { "L1_SITUA", "RE"} } // "RE" - Erro ao gravar no server
				EndIf	
				aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
			EndIf
		EndIf
	Else
		// Se houve erro na execucao do host 
		If lHostError 
			aUpdSL1 := { { "L1_SITUA", "ER"} } // "ER" - Erro ao gravar no server
			LjGrvLog( SL1->L1_NUM, "Nao conseguiu gravar venda. Erro componente de comunicação",cStatusNum)
		 	aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
	 		If ValType(cDescError) == "C" .AND. SL1->(FieldPos("L1_ERGRVBT") > 0)				
				aUpdSL1 := { { "L1_ERGRVBT", Left(cDescError,TamSX3("L1_ERGRVBT")[1]) } } // "ER" - Erro ao gravar no server
				If SL1->L1_SITUA <> "TX"
					aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
				Else
					LjGrvLog( SL1->L1_NUM, "Venda ja subiu - SL1->L1_SITUA:", SL1->L1_SITUA)	
				EndIf	
			EndIf	
		ElseIf lHasConnect // Caso tenha conexao nesse momento e msm assim nao subiu grava como "ER"        
			If SL1->L1_SITUA == "EP"
				aUpdSL1 := { { "L1_SITUA", "ER"} } // "ER" - Erro ao gravar no server
				LjGrvLog( SL1->L1_NUM, "Nao conseguiu na segunda, grava ER",cStatusNum)
			Else
				LjGrvLog( SL1->L1_NUM, "Nao foi possivel gravar o Orcamento  no servidor  Será marcado para reprocessar.",cStatusNum)
				//Grava venda como RE (Reenviar) pois houve erro ao enviar ao server
				aUpdSL1 := { { "L1_SITUA", "RE" } } // "RE" - Erro ao enviar ao server
			EndIf	
			aEval( aUpdSL1, { |x| FieldPut( FieldPos( x[1] ), x[2] ) } )
		Else
			LjGrvLog( SL1->L1_NUM, "No momento de mandar a venda nao conseguiu conectar")
		EndIf	
	EndIf
Else
	STDLogCons( STR0011 + SL1->L1_NUM + "." ) //"Erro ao confirmar a gravacao do Orcamento"
EndIf

SL1->( DbCommit() )
SL1->( MsUnLock() )

RestArea(aArea)	

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDCancSales
Efetua a gravacao do cancelamento no server

@param cEstacaoIni		Codigo da estacao

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDCancSales( cEstacaoIni )

Local aArea			:= GetArea()// Armazena alias corrente
Local cOrcamentos	:= "" 		// Concatenacao de vendas canceladas                 
Local cNumOrig	 	:= "" 		// Numero de origem
Local nOrcs      	:= 1		// Numero orcamento
Local cEstacao   	:= ""		// Estacao
Local aOrcs		 	:= {}		// Array de orcamentos
Local aRet		 	:= {}		// Array de retorno
Local lContinua  	:= .F.		// Controle de execucao
Local lComCPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[2] , .F. ) // Usa comunicacao com a central 
Local cExecFunc		:= "STDCancRec"  //funçao de cancelamento a ser executada
Local aAuxLIMsg		:= []
Local cAuxSeek		:= ""
Local aSL1			:= {}
Local lSaveTabOk	:= .F.
Local aDupDel		:= {}		//Array de registros duplicados a deletar
Local lCentPDV      := IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV
Local aParam        := {}
Local nI			:= 0		//Variável auxiliar
Local cSerNf		:= "" //Serie nao fiscal
Local lUseSAT		:= LjGetStation("LG_USESAT")
Local lSerNFe		:= .F. 

Default cEstacaoIni := "001"

cEstacao   := Space(TamSX3("LI_ESTACAO")[1])

DbSelectArea("SLI")
SLI->(DbSetOrder( 1 )) //LI_FILIAL+LI_ESTACAO+LI_TIPO
If SLI->(DbSeek( xFilial("SLI") + cEstacao + "CAN" ))
	
	While !SLI->(EOF()) .AND. (SLI->LI_FILIAL + SLI->LI_ESTACAO + SLI->LI_TIPO) == (xFilial("SLI") + cEstacao + "CAN")  
		
		LjGrvLog("SUBIDA_CANCELAMENTO" ,"Inicio do processo de subida do cancelamento para Retaguarda SLI(LI_TIPO = CAN) -> LI_MSG:",SLI->LI_MSG)  
		
		If !Empty(SLI->LI_MSG)
		
			aAuxLIMsg := StrTokArr( RTrim(SLI->LI_MSG), "|" ) //L1_NUMORIG|L1_DOC|L1_PDV
			
			If Len(aAuxLIMsg) >= 3

				
				aAuxLIMsg[3] := PADR(aAuxLIMsg[3],TamSX3("L1_PDV")[1]) //Ajusta tamanho do conteudo do campo L1_PDV, quando armazenado na ultima posicao do campo LI_MSG, fica com tamanho total do campo. Nao pode ser tratado na gravacao, se adicionado "|" para limitar tamanho, quando convertido para array vai retornar que tem 4 posicoes 

				lSerNFe := Len(aAuxLIMsg) >= 5 .and. !Empty(aAuxLIMsg[5])
				
				if lSerNFe
					//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
					SL1->( DbSetOrder(2) )
					aAuxLIMsg[5] := PADR(aAuxLIMsg[5],TamSX3("L1_SERIE")[1])
					cAuxSeek := xFilial("SL1") + aAuxLIMsg[5] + aAuxLIMsg[2] + aAuxLIMsg[3]
				else
					//L1_FILIAL+L1_PDV+L1_DOC
					SL1->( DbSetOrder(8) )
					cAuxSeek := xFilial("SL1") + aAuxLIMsg[3] + aAuxLIMsg[2]
				endif
				
				LjGrvLog("SUBIDA_CANCELAMENTO" ,"SL1 sera posicionada para validar o status da venda(L1_SITUA). Busca por L1_FILIAL+L1_PDV+L1_DOC:",cAuxSeek)
				  								
				DbSelectArea("SL1")
				If !lUseSAT .AND. Len(aAuxLIMsg) >= 4 .AND. !Empty(aAuxLIMsg[4])
					//So entra no IF se for uma venda de vale credito, pois assim pesquisa na SL1 pelo campos L1_DOCPED e L1_SERPED

					cSerNf	:= PadR( STDGetSrNF(cEstacaoIni,"LG_SERNFIS"), SL1->(TamSx3("L1_SERPED"))[1] )

					SL1->(DbSetOrder(11)) //L1_FILIAL+L1_SERPED+L1_DOCPED					
					If SL1->(DbSeek( xFilial("SL1")+cSerNf+aAuxLIMsg[4] )) .AND. AllTrim(SL1->L1_PDV) == AllTrim(aAuxLIMsg[3])					
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Registro localizado na SL1. L1_DOCPED:",SL1->L1_DOCPED)									
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Registro localizado na SL1. L1_SITUA",SL1->L1_SITUA)
					Else
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao localizou o registro na SL1")
						SLI->( DbSkip() )
						Loop													
					EndIf
				Else

					If SL1->(DbSeek( cAuxSeek ))
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Registro localizado na SL1. L1_NUMORIG(Conteudo do campo L1_NUM da retaguarda que faz referencia a venda no PDV):",SL1->L1_NUMORIG)									
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Registro localizado na SL1. L1_SITUA",SL1->L1_SITUA)
					Else
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao localizou o registro na SL1")
						SLI->( DbSkip() )
						Loop							
					EndIf
				EndIf

				//Quando L1_SITUA = 00|CP , nao processa o cancelamento, aguarda processo de subida da venda
				If SL1->L1_SITUA $ "00|CP"
					LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Aguardando venda subir para a retaguarda(L1_SITUA=00|CP)",cAuxSeek)
					SLI->( DbSkip() )
					Loop
				EndIf
				
				If Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_DOCPED)
					//So entra no IF se for uma venda de vale credito
					//Se for uma venda de vale credito, o sistema so ira cancelar a venda na retaguarda se a venda ja foi processada pelo GrvBatch

					lContinua := STBRemoteExecute( "STDCONGRVB" , { aAuxLIMsg[3], aAuxLIMsg[2], .T., SL1->L1_SERPED, aAuxLIMsg[4] } , NIL, .F. , @aRet )
					If !(Len(aRet) >= 1 .AND. ValType(aRet[1]) == "L" .AND. aRet[1] == .T.)
						lContinua := .F.
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Aguardando Execucao de LjGrvBatch(L1_SITUA!=OK) na Retaguarda",cAuxSeek)
						SLI->( DbSkip() )
						Loop
					EndIf
				Else
					//Quando Central de PDV, e não subiu o LjGrvBatch na retaguarda, nao processa o cancelamento
					If lCentPDV
						lContinua := STBRemoteExecute( "STDCONGRVB" , { aAuxLIMsg[3], aAuxLIMsg[2], , , , iif(lSerNFe,aAuxLIMsg[5], Nil) } , NIL, .F. , @aRet )
						If !(Len(aRet) >= 1 .AND. ValType(aRet[1]) == "L" .AND. aRet[1] == .T.)
							lContinua := .F.
						EndIf
						If !lContinua
							LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Aguardando Execucao de LjGrvBatch(L1_SITUA!=OK) na Retaguarda",cAuxSeek)
							SLI->( DbSkip() )
							Loop
						EndIf
						//Atualização de L1_MSG:
						//Na central, o L1_NUMORIG inicialmente é o L1_NUM do PDV. Após o LjGrvBatch, o L1_NUMORIG passará a ser o L1_NUM da Retaguarda.
						If SL1->L1_NUMORIG <> aAuxLIMsg[1]
							nI := At( "|", SLI->LI_MSG )
							RecLock( "SLI", .F. )
							SLI->LI_MSG := SL1->L1_NUMORIG + Iif(nI > 0,Substr(SLI->LI_MSG,nI),"")
							SLI->( MsUnlock() )
							aAuxLIMsg[1] := SL1->L1_NUMORIG	//Restaura novamente
						EndIf				
					EndIf
				EndIf
				
				cNumOrig	:= aAuxLIMsg[1] //Subst(SLI->LI_MSG,1,TamSX3("L1_NUMORIG")[1])
		
				//Quando cancelamento ocorreu antes de subir a venda, nao possui NUMORIG na SLI, busca informacao da SL1
				If Empty(cNumOrig) 
					If !Empty(SL1->L1_NUMORIG) 
						cNumOrig := SL1->L1_NUMORIG
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Cancelamento ocorreu antes de subir a venda para retaguarda(SLI->LI_MSG sem NUMORIG). Atualizado NUMORIG com dados da SL1->L1_NUMORIG:",cNumOrig)
					Else
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Nao possui informacao NUMORIG para cancelamento na Retaguarda. Verifique o Registro da tabela SL1 do PDV. SL1->L1_NUM",SL1->L1_NUM)
						SLI->( DbSkip() )
						Loop
					EndIf										
				EndIf
			
			
				If cNumOrig $ cOrcamentos
					//Item duplicado sera deletado da SLI					 
					AADD(aDupDel,{SLI->(Recno()),cNumOrig,cAuxSeek} )
				Else
				
					If Empty(cOrcamentos)		
						cOrcamentos := cNumOrig
					Else
						cOrcamentos += "|" + cNumOrig	
					EndIf

					// Adiciona Recno na primeira posicao para atualizacao 
					// do SLI e Numero do Orcamento na Segunda posicao e a chave de pesquisa para atualizar SITUA quando subir
					AADD(aOrcs,{SLI->(Recno()),cNumOrig,cAuxSeek} )
					nOrcs++							
				EndIf
					
			EndIf
			
		Else
			LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Sem conteudo para identificar o cancelamento. Conteudo Esperado: L1_NUMORIG|L1_DOC|L1_PDV LI_MSG.SLI->LI_HORA:",LI_HORA)  	
		EndIf
		
		SLI->(DbSkip())
	EndDo		
	
	If nOrcs > 1     
	
		// Realizado comunicacao via componente de comunicacao  
		// Efetua a gravacao do cancelamento no server  
		If lComCPDV  
			//Se usa Central de Pdv Cancela a Venda primeiro na Central e a Central cancela na Retaguarda
			cExecFunc := "_STDCancRec"
		EndIf  
		
		If Len(aAuxLIMsg) > 3 .and. !Empty(aAuxLIMsg[4])
			lContinua := STBRemoteExecute( cExecFunc , { cOrcamentos, cEmpAnt, cFilAnt, aAuxLIMsg[4] } , NIL, .F. , @aRet )
		Else		
			lContinua := STBRemoteExecute( cExecFunc , { cOrcamentos, cEmpAnt, cFilAnt } , NIL, .F. , @aRet )
		EndIf	
		
		If 	lContinua .AND. (Len(aRet) > 0)
			                       				
			For nOrcs:=1 To Len(aOrcs)
			       
				//Verifica se foi cancelado
				If Ascan( aRet ,aOrcs[nOrcs][2]) > 0
				
					//Atualiza SL1->L1_SITUA para sinalizar que cancelamento foi realizado na retaguarda
					DbSelectArea("SL1")

					if lSerNFe
						SL1->( DbSetOrder(2) )		//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
					else
						SL1->( DbSetOrder(8) ) 		//L1_FILIAL+L1_PDV+L1_DOC
					endif

					If SL1->(DbSeek( aOrcs[nOrcs][3] )) .AND. SL1->L1_SITUA <> '00' 
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Atualizacao Status(L1_SITUA=07): Cancelado na Retaguarda",SL1->L1_NUM)									
						
						If lCentPDV
                            aSL1 := {{"L1_DOC", ""},{"L1_SERIE", ""},{"L1_SITUA" , "07"},{"L1_STORC" , "C"}}
                        Else
                            aSL1 := {{"L1_SITUA" , "07"},{"L1_STORC" , "C"}}
                        EndIf 
						
						lSaveTabOk := STFSaveTab( "SL1" , aSL1 )
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Atualizacao Status(L1_SITUA=07): Cancelado na Retaguarda (.T. ou .F.):",lSaveTabOk)
					Else
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao localizou o registro na SL1 para atualizacao de Status(L1_SITUA=07): Cancelado na Retaguarda",SL1->L1_NUM)
						lSaveTabOk := .F.
					EndIf				
			
					//Remove Registro de pedido de Cancelamento
					If lSaveTabOk
						SLI->(DbGoto(aOrcs[nOrcs][1]))          				
						RecLock("SLI",.F.)
						SLI->(DbDelete())
						SLI->(MsUnlock())	       
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Foi processado o cancelamento na retaguarda. L1_NUM(Retaguarda):",aOrcs[nOrcs][2])
						
						//Se CentralPdv e possui orcamento, limpa orcamento para reutilizacao
						If lCentPDV						   
                            If SL1->L1_SITUA = "07" .And. SL1->L1_STORC = "C" .And. SL1->L1_OPERACA == "C"
                                aParam := {SL1->L1_NUM, SL1->L1_PDV}
                                FR271HArq(aParam,, .T.)
                                MsExecAuto( {|a,b,c,d,e,f,g| LJ140EXC(a,b,c,d,e,f,g)}, "SL1", /*nReg*/, 5, /*aReserv*/, .T., SL1->L1_FILIAL, SL1->L1_NUM )
                            EndIf                            
						EndIf
					Else
						LjGrvLog("SUBIDA_CANCELAMENTO" ,"Foi processado o cancelamento na retaguarda, mas nao foi possivel atualiza SL1 do PDV.",aOrcs[nOrcs][2]) 
					EndIf
					
					STDLogCons(STR0003 + aOrcs[nOrcs][2] + STR0012)			 //" cancelado no server"
				Else 
					LjGrvLog("SUBIDA_CANCELAMENTO" ,"Não foi processado o cancelamento na retaguarda. L1_NUM(Retaguarda):",aOrcs[nOrcs][2])
					STDLogCons(STR0003 + aOrcs[nOrcs][2] + STR0013)			 //" aguardando processar a venda para realizar cancelamento no server."
				EndIf  
				
			Next nOrcs		
		
		Else
			LjGrvLog("SUBIDA_CANCELAMENTO" ,"Nao foi processado o cancelamento. Motivo: Nao foi possivel realizar a comunicacao com o Server da Retaguarda",cExecFunc)
			STDLogCons(STR0014) //"Erro de comunicacao com servidor"	
		EndIf
		
	Else
		LjGrvLog("SUBIDA_CANCELAMENTO" ,"Fim do processo de cancelamento. Nenhum registro foi enviado para cancelamento na Retaguarda.")		
	EndIf
	
	If Len(aDupDel) > 0 //Remove Registro de pedido de Cancelamento	duplicados
		
		For nOrcs := 1 To Len(aDupDel)
			SLI->(DbGoto(aDupDel[nOrcs][1]))          				
			RecLock("SLI",.F.)
			SLI->(DbDelete())
			SLI->(MsUnlock())	       
			LjGrvLog("SUBIDA_CANCELAMENTO" ,"Foi deletado item duplicado: ",aDupDel[nOrcs][2])			
		Next nOrcs
			
	EndIf	
	
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCancRec
Efetua a gravacao do cancelamento  

@param cEstacaoIni		Codigo da estacao

@param cRegistros 	String co registros a cancelar	
@param cEmp			codigo da Empresa
@param cFil			Codigo da Filial

@author  Varejo
@version P11.8
@since   16/01/2013
@return  aRetDados - Daods do cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCancRec( cRegistros, cEmp, cFil, cNFisCanc, cSerie )

Local aOrcs     	:= {}  // Array de orcamentos 
Local nCont     	:= 1	// Variavel de controle
Local nQuant    	:= 0  	// Qtd de orcamentos   
Local nRet      	:= 1	// Retorno 
Local aRetDados 	:= {}	// Array de retorno
Local lCentPDV		:= IIf( ExistFunc("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV
Local lAltEmp		:= .F.
Local aSM0			:= {}
Local cNumEmp		:= ""

Default cRegistros 	:= ""	// Registros a cancelar	
Default cEmp		:= ""	// codigo da Empresa
Default cFil		:= ""	// Codigo da Filial
Default cNFisCanc	:= ""	// DOC cancelamento SAT
Default cSerie      := ""

aOrcs  := StrToKarr(cRegistros,"|")
nQuant := Len(aOrcs)

LjGrvLog("STDCancRec","Registros a Cancelar", aOrcs)
LjGrvLog("STDCancRec","Doc(SAT) para cancelar", cNFisCanc)

//-- Ao utilizar com NF-e devido ao processo da parte do faturamento vem desposicionado ao ser chamado pela integracao 
if ( AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL) ) <> (cEmp + cFil)

	LjGrvLog("STDCancRec","Ajustando SM0, estava desposicionada!", cNFisCanc)
		
	lAltEmp := .T.

	aSM0 := SM0->( GetArea() )
	if !SM0->( DbSeek( cEmp + cFil ) )
		LjGrvLog("STDCancRec","SM0 Nao encontrada!", cNFisCanc)
		nQuant := 0 //-- Zero para não entrar no loop e sair da funcao
	endif

	cEmpAnt	:= SM0->M0_CODIGO
	cFilAnt := AllTrim(SM0->M0_CODFIL)
	cNumEmp := cEmpAnt + cFilAnt

endif

While nCont <= nQuant
    
    //Deixar antes do FRTExclusa
	If lCentPDV	// Eh Central de PDV 	
		//Se for central de PDV replica o cancelamento para a Retaguarda gerando SLI na Central
		If STDCSRequestCancel( aOrcs[nCont] )
			LjGrvLog("STDCancRec","Central de PDV recebeu o cancelamento(SLI)", aOrcs[nCont])
			nRet := 0
		Else
			LjGrvLog("STDCancRec","Central de PDV NAO recebeu o cancelamento(SLI)", aOrcs[nCont])
		EndIf
	Else
		nRet := FRTExclusa( aOrcs[nCont], cNFisCanc )
	EndIf
	                                             
	/* 
		Retornos: 	(0)Cancelou, 
					(2)Nao Existe 
					(3)Venda nao foi processada pelo GrvBatch
	*/
					
	If nRet == 0 .OR. nRet == 2 .OR. nRet == 3  	
		
		//Retorna Vendas Canceladas para atualizar SLI do PDV. 
		//Somente gera SLI quando envia a venda para no server, quando não localiza a venda limpa SLI para evitar looping infinito
		If nRet <> 3
			AADD( aRetDados,aOrcs[nCont] )
		EndIf

	EndIf
    
	nCont++
EndDo

LjGrvLog("STDCancRec","Retorno", nRet)
LjGrvLog("STDCancRec","Dados Retornados", aRetDados)

if lAltEmp
	RestArea(aSM0)

	cEmpAnt	:= cEmp
	cFilAnt := cFil
	cNumEmp := cEmpAnt + cFilAnt
endif

Return aRetDados 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLogCons
Enviado o Log para o Console

@param cMessage		Codigo da estacao

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDLogCons( cMessage )  

Default cMessage := ""

ParamType 0 Var 	cMessage 	As Character	Default 	""

Conout(cMessage)  
LjGrvLog("STDUpData", cMessage)  

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecEstSale
Grava o Estorno da Venda no server

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecEstSale() 

Local	aArea			:= GetArea()		// Armazena alias corrente
Local nI				:= 0				//Variavel de apoio
Local aMBZ			:= {}				//Array com os campos do MBZ
Local aRet			:= {}				//Retorno 
Local lRet			:= .T.				//Retorno 
Local cOrcAnt 		:= ""             	//orcamento anterior
Local nPos    		:= 0              	//Posição do array
Local aReg    		:= {}              	//REgistros da tabela MBZ
Local nReg    		:= 0              	//Registro anterior
Local cOrc    		:= ""             	//Orcamento
Local cCup 	  		:= ""             	//Cupom
Local cSerie  		:= ""             	//Serie
Local lContinua  	:= .F.				//Controle de execucao

DbSelectArea( "MBZ" )
DbSetOrder( 2 ) //MBZ_FILIAL + MBZ_SITUA + MBZ_CUPOM + MBZ_SERIE
DbSeek( xFilial() + "00" )


Do While MBZ_FILIAL + MBZ_SITUA == xFilial() + "00"


	If cOrcAnt <> (MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE)
   		STDLogCons( "STDRecEstSale" + MBZ->MBZ_NUM + STR0015 ; //" Enviando para o server Estorno da Venda do Orçamento - "
   				+MBZ->MBZ_CUPOM + "/" + MBZ->MBZ_SERIE )
	    cOrcAnt := MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE 
	    cOrc    := MBZ->MBZ_NUM
		cCup 	:= MBZ->MBZ_CUPOM
		cSerie  := MBZ->MBZ_SERIE
	EndIf 
	
	aMBZ := {} 
	aReg := {}
	nPos := 0
	
	Do While cOrcAnt ==  MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE
	
		aAdd(aMBZ, Array( FCount() ) )
	    nPos := nPos + 1
	    
	    
		For nI := 1 To FCount()
			aMBZ[nPos, nI] := { FieldName( nI ), FieldGet( nI ) }
		Next
		
	    aAdd(aReg, Recno())
    	
		MBZ->(DbSkip(1))
		
	EndDo  
	
	nReg := Recno()
	
	// Realizado comunicacao via componente de comunicacao  
	// Efetua a gravacao do cancelamento no server 
	lContinua := STBRemoteExecute( "GeraMBZ" , { "MBZ", aMBZ } , NIL, .F. , @aRet )
	
	If lContinua .AND. ValType( aRet ) == "A"  

		If Left( aRet[1], 2 ) == "OK"
		
			// Se recebeu retorno OK executa confirmacao
			lContinua := STBRemoteExecute( "ConfMBZ" , { aRet[2] } , NIL, .F. , @lRet ) 
			 
			STDLogCons(cAlias + STR0016) //" gravado no server."
			
			If lContinua .AND. lRet
				aMBZ := { { "MBZ_SITUA", "TX" } }					// "TX" - Foi Enviado ao Server
				For nI := 1 to Len(aReg)
					MBZ->(DbGoTo(aReg[nI]))
					STFSaveTab( "MBZ", aMBZ, .F. ) 
					STDLogCons(cAlias + STR0017 + cAlias+"_SITUA" + ": " + "OK" + " Recno: " + cValToChar(aRecnos[nI])) //" Atualizado. " ### " Recno: "          
				Next
			EndIf
		Else
			
			aMBZ := { { "MBZ_SITUA", Left( aRet[1], 2 ) } }					// "Erro" - Chave duplicada
			For nI := 1 to Len(aReg)
				MBZ->(DbGoTo(aReg[nI]))
				STFSaveTab( "MBZ", aMBZ, .F. )   
				STDLogCons(cAlias + STR0018 + cAlias+"_SITUA" + ": " + Left( aRet[1], 2 ) + " Recno: " + cValToChar(aRecnos[nI])) //" Não  Atualizado. " ### " Recno: "         
			Next		
		EndIf  
		
	Else
		STDLogCons(STR0014) //"Erro de comunicacao com servidor"
		Exit  		
	EndIf 
	

	DbGoTo(nReg)
	
EndDo

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecTabServer
Grava Alias no server

@Param   cAlias 	- Alias que sera usado
@Param   nOrder 	- Codigo de ordenacao
@Param   cChave 	- Campos de busca
@Param   cBusca 	- Conteudo de busca
@Param 	 cConfLocal 	- String de confirmacao de gravacao do campo Local	
@Param 	 cConfServer 	- String de confirmacao de gravacao do campo no server
@Param 	 cEstacaoIni 	- Estacao
@Param 	 cFunc		 	- Funcao a ser executado no server

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecTabServer(	cAlias 		, nOrder 		, cChave		, cBusca	,; 
								cConfLocal		, cConfServer	, cEstacaoIni	, cFunc	,;
								lDefault)   

Local aRecnos    	:= {}
Local nX      		:= 0		// Contador
Local lRetServer	:= .F.		// Retorno do Servidor
Local cNameField 	:= ""		// Nome do campo situa para o Alias atual
Local lRet		 	:= .F.		// Retorno
Local xRet		 	:= Nil		// Retorno
Local aData 	 	:= {}		// Array com dados a subir para o server
Local lContinua  	:= .F.		// Controle de execucao
Local nRecServer 	:= 0		// numero do Recno a ser confirmado no servidor 
Local aArea			:= GetArea()// Guarda area atual
Local nCont			:= 0 
Local cRetSrv	 	:= ""
Local cLogICpo		:= ""
Local cLogACpo		:= ""
Local lDecode		:= .T.
Local cXMLEPaf		:= ""
Local cXMLRPaf		:= ""
Local cCurrTab		:= ""
Local cFieldName	:= ""

Default 	cAlias 	 	:= ""
Default 	nOrder 	 	:= 0
Default 	cChave 	 	:= ""
Default 	cBusca 	 	:= ""
Default 	cConfLocal 	:= ""
Default 	cConfServer := ""
Default 	cEstacaoIni := ""
Default 	cFunc 	 	:= ""

// Formata campo NOMETABELA_SITUA
// Exemplo: Iniciando com "S": SL1->L1_SITUA, caso contrário MDZ->MDZ_SITUA
If Substr(Upper(cAlias), 1, 1) == "S"
	cCurrTab	:= AllTrim(Upper(Substr(cAlias, 2, 2)))
	cNameField	:= cCurrTab + "_SITUA"
	
	//Tratamento para os campos: _USERLGI, _USERLGA
	cLogICpo := cCurrTab + "_USERLGI"
	cLogACpo := cCurrTab + "_USERLGA"
	
	//XML do PAF
	cXMLEPaf := cCurrTab + "_XMLEPAF"
	cXMLRPaf := cCurrTab + "_XMLRPAF"
Else
	cCurrTab	:= AllTrim(Upper(cAlias))
	cNameField	:= cCurrTab + "_SITUA"
	
	//Tratamento para os campos: _USERGI, _USERGA
	cLogICpo := cCurrTab + "_USERGI"
	cLogACpo := cCurrTab + "_USERGA"
	
	//XML do PAF
	cXMLEPaf := cCurrTab + "_XMLEPA"
	cXMLRPaf := cCurrTab + "_XMLRPA"
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrder)  

If DbSeek(cBusca)

	nCampos := FCount() 

	While (cAlias)->(!Eof()) .AND. &(cChave) == cBusca .AND. nCont <= 300 
		
		nCont	 := nCont + 1
		cRetSrv := ""
		
		For nX := 1 To nCampos
			cFieldName := AllTrim( FieldName( nX ) )
			
			//Tratamento para os campos: _USERLGI, _USERLGA ou  _USERGI, _USERGA
			If cLogICpo == cFieldName  .Or. cLogACpo == cFieldName .Or.;
				cXMLRPaf == cFieldName .Or. cXMLEPaf == cFieldName

				AAdd( aData , { cFieldName, Encode64( FieldGet(nX)) })
			Else
				AAdd( aData , { cFieldName, FieldGet( nX ) } )
			EndIf
		   	 
		Next i     
        
		If Len(aData) > 0 
		    
		    LjGrvLog( "STDRecTabServer" , "Subir tabela: " + cAlias) 
		    Conout("STDRecTabServer - Subir tabela: " + cAlias) 
		    
			// Realizado comunicacao via componente de comunicacao  
			// Efetua a gravacao dos dados no server de acordo com o ALIAS
			Do Case 
				Case !Empty(cFunc) 	// Rotina especifica 
						lContinua := STBRemoteExecute( cFunc		, { aData } , NIL, .F. , @xRet )	
				Case cAlias == "SFI"	// Resumo Reducao Z
						lContinua := STBRemoteExecute( "GeraSFI"	, { aData, lDecode } , NIL, .F. , @xRet )	
				Case cAlias == "SE5"  // Movimentacao Bancaria			
						lContinua := STBRemoteExecute( "GeraE5"	, { aData, lDecode } , NIL, .F. , @xRet )	
				Case cAlias == "SLX"  // Movimentacao Bancaria			
						lContinua := STBRemoteExecute( "GeraSLX"	, { aData, lDecode } , NIL, .F. , @xRet )		
				Case cAlias == "SLW" // SLW = Movimento Processos de Venda 
						If Empty(DtoS(aData[aScan(aData,{|x| AllTrim(x[1]) == "LW_DTFECHA"})][2]))  
							// Faz abertura no server  
							lContinua := STBRemoteExecute( "FRT020ABR" ,  { aData,.T., lDecode } , NIL, .F. , @xRet )	
						Else
							// Faz fechamento no server 
							lContinua := STBRemoteExecute( "FRT020FCH" ,  { aData,,.T., lDecode } , NIL, .F. , @xRet )	
						EndIf					
				Case cAlias $ "MDZ|SLT|LHG|LK9" // MDZ = Movimento por ECF ||| SLT = Conferencia de Caixa (LHG e LK9, são tabelas do Template de Drogaria)
						lContinua := STBRemoteExecute( "GeraSZ" ,  { cAlias , aData , lDecode } , NIL, .F. , @xRet )	
				OtherWise				// Demais tabelas, rotina generica	
						lContinua := STBRemoteExecute( "STDRecXData" , { cAlias , aData, Nil , Nil , Nil, lDecode } , NIL, .F. , @xRet )			
			EndCase    
					
			//Trata o retorno xRet
			If lContinua .AND. ValType(xRet) == "A"   
				lRetServer := xRet[1] == "OK" 
				nRecServer := xRet[2]
				cRetSrv	 := xRet[1]
			ElseIf lContinua .AND. ValType(xRet) == "L" 
		   		lRetServer := xRet
			ElseIf lContinua
			 	cRetSrv	 := "ER"	   		
			EndIf
    
			If lContinua .AND. lRetServer	
				/*
				Quando PAF-ECF a MDZ retorna -1 para determinados registros que não podem ser gravados 
				duas vezes porém como é validado se nRecServer > 0, não é necessário tratar separadamente porem
				se feito alguma alteração tratar a MDZ como é feito no FRTA020 
				*/
				// Se precisa fazer confirmacao no servidor confirma de acordo com recno
				If nRecServer > 0
					lContinua := STBRemoteExecute( "STDConfRec" , { cAlias , nRecServer , cNameField , cConfServer } , NIL, .F. , @lRet )	
				EndIf	
				
				If lContinua
					STDLogCons(cAlias + STR0016) //" gravado no server."

		            If RecLock( cAlias, .F. )
			         	REPLACE &((cAlias)->(cNameField))	WITH cConfLocal
		   				&(cAlias)->(dbCommit())
			         	&(cAlias)->(MsUnlock())    
						STDLogCons(cAlias + STR0017 + cNameField + ": " + cConfLocal + " Recno: " + cValToChar(&(cAlias)->(Recno()) )) //" atualizado. -> Recno: "
			        EndIf
		        EndIf

			ElseIf lContinua
			
				If RecLock( cAlias, .F. )            		
		         	REPLACE &((cAlias)->(cNameField))	WITH cRetSrv
	   				&(cAlias)->(dbCommit())
		         	&(cAlias)->(MsUnlock())    
	
	        	EndIf 
			Else
				STDLogCons(STR0014 ) //"Erro de comunicacao com servidor"
			EndIf 
		
		EndIf
			
		aData := {}    
		lRetServer := .F.  
		nRecServer := 0	     
		
		/*
			Por garantia posiciona no registro anterior para depois
			ir para o primeiro, pois ao alterar um campo do indice
			os registros serao reordenados.
		*/        
		If lContinua
			&(cAlias)->(DbSkip(-1))
			&(cAlias)->(DbGoTop())
		Else
			&(cAlias)->(DbSkip())
		EndIf
	EndDo
EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecOpenClose
Grava Alias no server

@Param   cAlias 	- Alias que sera usado
@Param   nOrder 	- Codigo de ordenacao
@Param   cChave 	- Campos de busca
@Param   cBusca 	- Conteudo de busca
@Param 	 cConfLocal 	- String de confirmacao de gravacao do campo Local	
@Param 	 cConfServer 	- String de confirmacao de gravacao do campo no server
@Param 	 cEstacaoIni 	- Estacao

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecOpenClose(	cAlias 		, nOrder 		, cChave		, cBusca	,; 
								cConfLocal		, cConfServer	, cEstacaoIni				)       

Local aArea		:= GetArea()	// Armazena alias corrente
Local nX      	:= 0    		// Contador
Local lRetServer	:= .F.			// Retorno do Servidor
Local cNameField 	:= ""      	// Nome do campo situa para o Alias atual
Local lRet		 	:= .F.     	// Retorno
Local xRet		 	:= Nil			// Retorno
Local aData 	 	:= {}      	// Array de dados a serem gravados no server
Local lContinua  	:= .F.			// Controle de execucao
Local cLogICpo	:= ""
Local cLogACpo	:= ""
Local lDecode		:= .T.

Default 	cAlias 	 		:= ""
Default 	nOrder 	 		:= 0
Default 	cChave 	 		:= ""
Default 	cBusca 	 		:= ""
Default 	cConfLocal 	 	:= ""
Default 	cConfServer 		:= ""
Default 	cEstacaoIni 		:= ""

// Formata campo NOMETABELA_SITUA
// Exemplo: Iniciando com "S": SL1->L1_SITUA, caso contrário MDZ->MDZ_SITUA
If Substr(Upper(cAlias), 1, 1) == "S"
	cNameField := Substr(cAlias, 2, 2) + "_SITUA"
	
	//Tratamento para os campos: _USERLGI, _USERLGA
	cLogICpo := AllTrim(UPPER(Substr(cAlias, 2, 2)) + "_USERLGI")
	cLogACpo := AllTrim(UPPER(Substr(cAlias, 2, 2)) + "_USERLGA")        
Else
	cNameField := cAlias + "_SITUA"
	
	//Tratamento para os campos: _USERGI, _USERGA
	cLogICpo := AllTrim(UPPER(cAlias) + "_USERGI")
	cLogACpo := AllTrim(UPPER(cAlias) + "_USERGA")        
EndIf

//cAlias == "SLW"	// SLW = Movimento Processos de Venda
DbSelectArea(cAlias)
DbSetOrder(nOrder)
If DbSeek(cBusca)

	nCampos := FCount() 

	While &(cChave) == cBusca .AND. !EOF()

		For nX := 1 To nCampos   		
			//Tratamento para os campos: _USERLGI, _USERLGA ou  _USERGI, _USERGA
			If cLogICpo == FieldName( nX ) .Or. cLogACpo == FieldName( nX )
				AAdd( aData , { FieldName( nX ), Encode64( FieldGet(nX)) })
			Else
			   	AAdd( aData , { FieldName( nX ), FieldGet( nX ) } ) 
			EndIf
		Next i

		If Len(aData) > 0 
		    
			// Realizado comunicacao via componente de comunicacao  
			// Efetua a gravacao dos dados no server de acordo com o ALIAS
				
			If Empty(DtoS(aData[aScan(aData,{|x| AllTrim(x[1]) == "LW_DTFECHA"})][2]))  
				// Faz abertura no server  
				lContinua := STBRemoteExecute( "FRT020ABR" ,  { aData,.T., lDecode  } , NIL, .F. , @xRet )	
			Else
				// Faz fechamento no server 
				lContinua := STBRemoteExecute( "FRT020FCH" ,  { aData,,.T., lDecode } , NIL, .F. , @xRet )	
			EndIf
					
			//Trata o retorno xRet
			If lContinua .AND. ValType(xRet) == "L" 
		   		lRetServer := xRet
			EndIf
    
			If lContinua .AND. lRetServer	
				
				STDLogCons(cAlias + STR0016) //" gravado no server."
		        				
				//Atualiza campo XX_SITUA como enviado para o server. EX: "TX" "OK"
				If STFSaveTab(cAlias, {{cNameField, cConfLocal}})
					STDLogCons(cAlias + STR0017+ cNameField + ": " + cConfLocal + " Recno: " + cValToChar(&(cAlias)->(Recno()) )) //" atualizado. -> Recno: "         
				EndIf
		
			Else
				STDLogCons(STR0014 ) //"Erro de comunicacao com servidor"
			EndIf 
		
		EndIf
			
		aData := {} 
		lRetServer := .F.
		&(cAlias)->(DbSkip())
			
	EndDo
	
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecGenTabServer
Grava Alias generico no server

@Param   
@author  Varejo
@version P11.8
@since   08/02/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecGenTabServer()  

Local	aArea			:= GetArea()		// Armazena alias corrente
Local nX      		:= 0    	// Contador
Local lRetServer		:= .F.		// Retorno do Servidor
Local cNameField 	:= ""      	// Nome do campo situa para o Alias atual
Local lRet		 	:= .F.     	// Retorno
Local xRet		 	:= Nil		// Retorno
Local aData 	 		:= {}      	// Array com dados a subir para o server
Local lContinua  	:= .F.		// Controle de execucao
Local nRecServer 	:= 0		// numero do Recno a ser confirmado no servidor 
Local cAlias 	 		:= ""		// Alias que ira subir ao server
Local cFunc 	 		:= ""		// Funcao a ser executada no server 
Local cConfLocal		:= "TX"     // Texto para Confirmacao local
Local cConfServer	:= "RX"     // Texto para Confirmacao no server
Local cStatusError	:= "ER"     // Texto para Confirmacao no server
Local nCont			:= 0
Local lExistCli	:= .F.	//Cliente ja existe?
Local nIndice 		:= 0
Local cChave		:= ""
Local aFieldSA1 := {"A1_FILIAL", "A1_COD", "A1_LOJA", "A1_NOME", "A1_NREDUZ", "A1_CGC", "A1_END", "A1_EST", "A1_MUN", "A1_TIPO","A1_PESSOA"} //Campos atualizados no cadastro de clientes
Local lSTDEdtSA1	 	:= ExistBlock("STDEdtSA1")		//Ponto de entrada para edição do Cadastro de Clientes
Local aSTDEdtSA1	:= {} //Resultado do P.E para edição de clientes	
Local cFieldName	:= "" //Nome do campo
Local uValue		:= NIL //Valor do campo
Local cLogICpo 		:= ""// Nome do campo XX_USERLGI
Local cLogACpo 		:= "" // Nome do campo XX_USERLGA
Local nPosLGI 		:= 0 //Posicao do campo do campo XX_USERLGI
Local nPosLGA 		:= 0 //Posicao do campo do campo XX_USERLGA

CoNout('Entrou na funcao - STDRecGenTabServer')

DbSelectArea("SLI")
DbSetOrder(2)  //LI_FILIAL+LI_TIPO
If DbSeek(xFilial("SLI") + "UP")

	While SLI->(!EOF()) .AND. AllTrim(SLI->LI_TIPO) == "UP" .AND. nCont <= 20 
		lExistCli	:= .F.
		nIndice 		:= 0
		cChave		:= ""
		nCont := nCont + 1

		If !Empty(SLI->LI_ALIAS) .AND. SLI->LI_UPREC > 0
			CoNout('STDRecGenTabServer - Encontrou ' + SLI->LI_ALIAS + ' Recno: ' + AllTrim(Str(SLI->LI_UPREC)))		
				    
			cAlias := AllTrim(SLI->LI_ALIAS)
			// Formata campo NOMETABELA_SITUA   
			
			If Substr(Upper(cAlias), 1, 1) == "S"
				cNameField := Substr(cAlias, 2, 2) + "_SITUA"        
			Else
				cNameField := cAlias + "_SITUA"        
			EndIf
			 
			If !Empty(SLI->LI_FUNC) 
		   		cFunc := AllTrim(SLI->LI_FUNC)
			EndIf 
			 
			// Posiciona no registro a subir para o server 
			DbSelectArea(cAlias)
			&(cAlias)->(DbGoto(SLI->LI_UPREC)) 
			
			If &(cAlias)->(&(cNameField)) == "00"      

				If AllTrim(cAlias) == 'SA1'
					lContinua := STBRemoteExecute( "STDPesqCli" , { SA1->A1_FILIAL, SA1->A1_COD, SA1->A1_LOJA } , NIL, .F. , @lExistCli )
					If lContinua
						nIndice 		:= 1
						cChave		:= SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA
						
						If lSTDEdtSA1
							ConOut("STDRecGenTabServer - Executando o p.E. STDEdtSA1")
							aSTDEdtSA1 := ExecBlock("STDEdtSA1",.F.,.F.,{lExistCli})
							ConOut("STDRecGenTabServer - Executado o p.E. STDEdtSA1  - campos editado" + cValToChar(Len(aSTDEdtSA1)))							
						Else
							If lExistCli
								//Edição, carrega somente os campos que podem ser alterados
								aSTDEdtSA1 := aClone(aFieldSA1)
								ConOut("STDRecGenTabServer - Padrão campos alterados" + cValToChar(Len(aSTDEdtSA1)))							

							Else
								//Se for inclusão, atualiza o SA1 inteiro
								For nX := 1 To FCount()    		
								   	AAdd( aSTDEdtSA1 , FieldName( nX )  )
								Next nX
									ConOut("STDRecGenTabServer - Padrão campos Inseridos" + cValToChar(Len(aSTDEdtSA1)))	
							EndIf
						EndIf 
						
						For nX := 1 to Len(aSTDEdtSA1)
							cFieldName := aSTDEdtSA1[nX]
							uValue		:= FieldGet(FieldPos(cFieldName)) //Valor do campo
							AAdd( aData , {cFieldName , uValue  } ) 
						Next nX
							
					EndIf
				Else
					CoNout('STDRecGenTabServer - Encontrou o alias ' + cAlias + ', Recno: ' + AllTrim(Str(SLI->LI_UPREC)))	
					For nX := 1 To FCount()    		
						cFieldName := FieldName( nX )
						uValue		:= FieldGet( nX )
					   	AAdd( aData , { cFieldName, uValue } ) 
					Next i				
				EndIf
				
			ElseIf AllTrim(cAlias) == 'SA1'
	            //Apaga o registro ja processado da SLI
				If	RecLock("SLI",.F.)
					SLI->(DbDelete())
					SLI->(MsUnlock())    
				EndIf
				CoNout('STDRecGenTabServer - Nao estava como A1_SITUA == 00, entao foi excluido da SLI')
	        EndIf
	        
	        CoNout('STDRecGenTabServer - Array aData retornou ' + AllTrim(Str(Len(aData))))
			If Len(aData) > 0 
			    
				// Realizado comunicacao via componente de comunicacao  
				// Efetua a gravacao dos dados no server de acordo com o ALIAS
				If Empty(cFunc)
					//Formata campo NOMETABELA_USERLG?, Exemplo: Iniciando com "S": SLT->LT_USERLGI, caso contrário MDZ->MDZ_USERGI
					If Substr(Upper(cAlias), 1, 1) == "S"
						cLogICpo := Substr(cAlias, 2, 2) + "_USERLGI"
						cLogACpo := Substr(cAlias, 2, 2) + "_USERLGA"
					Else
						cLogICpo := cAlias + "_USERGI"
						cLogACpo := cAlias + "_USERGA"
					EndIf
					
					If (nPosLGI := AScan( aData, { |x| x[1] == cLogICpo } )) > 0
						aData[nPosLGI][2] := Encode64(aData[nPosLGI][2])
					EndIf
					
					If (nPosLGA := AScan( aData, { |x| x[1] == cLogACpo } )) > 0
						aData[nPosLGA][2] := Encode64(aData[nPosLGA][2])
					EndIf			

					// Rotina generica	
					lContinua := STBRemoteExecute( "STDRecXData" , { cAlias , aData, !lExistCli, nIndice, cChave, .T. } , NIL, .F. , @xRet )			
				Else	     
					// Executa pela rotina especificada
					lContinua := STBRemoteExecute( cFunc ,  { aData } , NIL, .F. , @xRet )
				EndIf	
					
				//Trata o retorno xRet
				If lContinua .AND. ValType(xRet) == "A"   
					lRetServer := xRet[1] == "OK" 
					nRecServer := xRet[2]
					CoNout('STDRecGenTabServer - Retorno do RemoteExecute Ok')
				ElseIf lContinua .AND. ValType(xRet) == "L" 
			   		lRetServer := xRet
			   		CoNout('STDRecGenTabServer - Retorno do xRet foi L')
				EndIf
	    
				If lContinua .AND. lRetServer	
					
					// Se precisa fazer confirmacao no servidor confirma de acordo com recno
					If nRecServer > 0
						lContinua := STBRemoteExecute( "STDConfRec" , { cAlias , nRecServer , cNameField , cConfServer } , NIL, .F. , @lRet )	
					EndIf	
					
					If lContinua
					
						STDLogCons(cAlias + STR0016) //" gravado no server."
						
	
			      		If RecLock( cAlias, .F. )
			            
				         	REPLACE &((cAlias)->(cNameField))	WITH cConfLocal
			   				&(cAlias)->(dbCommit())
				         	&(cAlias)->(MsUnlock())    
							STDLogCons(cAlias + STR0017 + cNameField + ": " + cConfLocal + " Recno: " + cValToChar(&(cAlias)->(Recno()) )) //" atualizado. -> Recno: "         
		                     
		                // Apaga o registro ja processado da SLI
							If	RecLock("SLI",.F.)
								SLI->(DbDelete())
								SLI->(MsUnlock())    
							EndIf
					
					Else
						CoNout('STDRecGenTabServer - Retorno da confirmacao (STDConfRec) .F.')
				    EndIf   
					
			      EndIf
	
				ElseIf lContinua .AND. !lRetServer
				
					STDLogCons(cAlias +  " Erro ao gravar no server. Alias: " + cAlias ) //" Erro ao gravar no server"
	
		      		If RecLock( cAlias, .F. )
		            
			         	REPLACE &((cAlias)->(cNameField))	WITH cStatusError
		   				&(cAlias)->(dbCommit())
			         	&(cAlias)->(MsUnlock())    
						     
	                // Apaga o registro ja processado da SLI
						If	RecLock("SLI",.F.)
							SLI->(DbDelete())
							SLI->(MsUnlock())    
						EndIf
						
			      EndIf  
				       			
				Else
					STDLogCons(STR0014 ) //"Erro de comunicacao com servidor"
				EndIf 
			
			EndIf
				
			aData := {}    
			lRetServer := .F.  
			nRecServer := 0	     
			cFunc := ""  
			cAlias := ""
			
		EndIf
	
		SLI->(DbSkip())
	
	End

EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDConfRec
Confirma a Gravacao dos dados recebidos

@Param cAlias 		- Alias 
@Param nRecno 		- Recno  
@Param cNameField	- Nome do campo a ser atualizado 
@Param cTextConf    - Texto de confirmacao a ser gravado no campo

@author  Varejo
@version P11.8
@since   17/01/2013
@return  lRet		Retona se executou corretamente a funcao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDConfRec( cAlias , nRecno , cNameField , cTextConf )   

Local lRet := .F.		// Retorno

Default cAlias 		:= ""
Default nRecno 		:= 0    
Default cNameField 	:= ""
Default cTextConf 	:= "RX"

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var 	nRecno 		As Numeric		Default 	0
ParamType 2 Var 	cNameField 		As Character	Default 	""
ParamType 3 Var 	cTextConf 		As Character	Default 	"RX"


&(cAlias)->(DbGoto(nRecno))
lRet := STFSaveTab(cAlias, {{cNameField, cTextConf}})			// "RX" "OK" - Foi Recebido Pelo Server

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} STDXRzArray
Gera um array do alias recebido e que esta com _SITUA = "00"

@Param cAlias 		- Alias que sera usado  
@Param nOrder 		- Codigo de ordenacao      
@Param cChave 		- Campos de busca          
@Param cBusca 		- Conteudo de busca			
@Param aRecnos 		- Recno dos registros selecionados			

@author  Varejo
@version P11.8
@since   17/01/2013
@return  aRet		array com dados do Alias
@obs     
@sample
/*/
//-------------------------------------------------------------------


Function STDXRzArray( 	cAlias , nOrder, cChave, cBusca ,;
							aRecnos			)

Local	aArea		:= GetArea()		// Armazena alias corrente
Local nCampos 	:= 0      	// Quantidade de campos do filtro atual
Local aRet		:= {}     	// Array do Alias
Local i			:= 0			// Contador

Default cAlias		:= 	""			// Alias que sera usado 
Default nOrder		:= 	0			// Codigo de ordenacao   
Default cChave		:= 	""			// Campos de busca 
Default cBusca		:= 	""			// Conteudo de busca	
Default aRecnos		:= 	{}			// Recno dos registros selecionados. Chamar por referencia       

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var 	nOrder 		As Numeric	Default 		0
ParamType 2 Var 	cChave 		As Character	Default 	""
ParamType 3 Var 	cBusca 		As Character	Default 	""
ParamType 4 Var  aRecnos 		As Array	Default 		{}


DbSelectArea(cAlias)
DbSetOrder(nOrder)
If DbSeek(cBusca)

	nCampos := FCount()  
    
	// Monta a primeira posicao do array com o nome dos campos
	aRet := { Array(nCampos) }    
	For i := 1 To nCampos
		aRet[1][i] := FieldName(i)
	Next i 

	While &(cChave) == cBusca .AND. !EOF()
		
		AAdd(aRet, Array(nCampos))

		For i := 1 To nCampos   
	
			// Monta as demais posicoes do array com o conteudo
		   	aRet[Len(aRet)][i] := FieldGet(i)
	   	
		Next i     
		
		//Adiciona Recnos para atualizacao do campo XX_SITUA 
		Aadd(aRecnos, &(cAlias)->(Recno()) )
		
		&(cAlias)->(DbSkip())

	EndDo
	
EndIf

RestArea(aArea)

Return aRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} STDXArray
Gera um array do alias recebido e que esta com _SITUA = "00"

@Param cAlias 		- Alias que sera usado  
@Param nOrder 		- Codigo de ordenacao      
@Param cChave 		- Campos de busca          
@Param cBusca 		- Conteudo de busca			
@Param aRecnos 		- Recno dos registros selecionados			

@author  Varejo
@version P11.8
@since   17/01/2013
@return  aRet		array com dados do Alias
@obs     
@sample
/*/
//-------------------------------------------------------------------


Function STDXArray( 	cAlias  , nOrder, cChave, cBusca ,;
							aRecnos , cFunction   		     	)

Local	aArea		:= GetArea()	// Armazena alias corrente
Local nCampos 	:= 0      	// Quantidade de campos do filtro atual
Local aRet		:= {}     	// Array do Alias
Local i			:= 0			// Contador

Default cAlias		:= 	""			// Alias que sera usado 
Default nOrder		:= 	0			// Codigo de ordenacao   
Default cChave		:= 	""			// Campos de busca 
Default cBusca		:= 	""			// Conteudo de busca	
Default aRecnos		:= 	{}			// Recno dos registros selecionados. Chamar por referencia 
Default cFunction  	:= ""			// Function    

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var 	nOrder 		As Numeric	Default 		0
ParamType 2 Var 	cChave 		As Character	Default 	""
ParamType 3 Var 	cBusca 		As Character	Default 	""
ParamType 4 Var  aRecnos 		As Array	Default 		{}
ParamType 5 Var 	cFunction 		As Character	Default 	""

DbSelectArea(cAlias)
DbSetOrder(nOrder)
If DbSeek(cBusca)

	nCampos := FCount() 

	While &(cChave) == cBusca .AND. !EOF()
		
		AAdd(aRet, Array(nCampos))
			
		For i := 1 To nCampos   
		
			// Monta as demais posicoes do array com o conteudo
			aRet[Len(aRet)][i] := { FieldName( i ), FieldGet( i ) }
		Next i     
		
		//Adiciona Recnos para atualizacao do campo XX_SITUA 
		Aadd(aRecnos, &(cAlias)->(Recno()) ) 
		
		&(cAlias)->(DbSkip())
			
	EndDo
	
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecXRzData
Grava dados da Reducao Z
@Param cAlias 		- Alias que sera usado  
@Param aData 		- Array com dados da reducao		
@author  Varejo
@version P11.8
@since   17/01/2013
@return  lRet		Se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecXRzData( cAlias , aData ) 

Local	aArea				:= GetArea()		// Armazena alias corrente
Local nI 			:= 0 			// Contador
Local nJ 			:= 0 			// Contador    
Local aRec      	:= {}		// Array para fazer garvacao dos dados   
Local cNameField 	:= ""     // Nome do campo situa para o Alias atual  
Local lRet			:= .F.		// Retorno

Default cAlias := ""
Default aData  := {}

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var  aData 		As Array	Default 		{}

// Formata campo NOMETABELA_SITUA, Exemplo:
// Iniciando com "S": L1_SITUA, caso contrario MDZ_SITUA
If Substr(Upper(cAlias), 1, 1) == "S"
	cNameField := Substr(cAlias, 2, 2) + "_SITUA"        
Else
	cNameField := cAlias + "_SITUA"        
EndIf

// Gera dados
For nI := 2 To Len( aData ) 

	aRec := Array(Len(aData[1])) 
	
	// Transforma o array recebido para o formato: [NOME]; [VALOR]
	// Pois e recebido em outro formato para diminuir o tamanho do arquivo
	For nJ := 1 To Len(aData[1])
		aRec[nJ] := {aData[1][nJ], aData[nI][nJ]}
	Next nJ  

	// "TX" - Foi Transferido Para o Server 	
	aRec[AScan(aRec, {|x|x[1]== cNameField })][2]	:= "TX"  
	
	lRet := STFSaveTab( cAlias , aRec, .T.)  
	
Next nI

RestArea(aArea)

Return lRet
           

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecXData
Grava dados da Reducao Z
@Param cAlias 		- Alias que sera usado  
@Param aData 		- Array com dados da reducao		
@author  Varejo
@version P11.8
@since   17/01/2013
@return  lRet		Se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecXData( cAlias , aData, lAppend , nIndice , cChave, lDecode) 

Local lRet			:= .F.		// Retorno
Local aArea		:= GetArea()
Local nPosLGI		:= 0		// Log de inclusao de usuario
Local nPosLGA		:= 0		// Log de alteração de usuario
Local cLogICpo	:= ""
Local cLogACpo	:= ""

Default cAlias := ""
Default aData  := {}
Default lAppend := .T. //Padrão, insere o registro
Default nIndice := 0
Default cChave := ""
Default lDecode := .F.

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var  aData 			As Array	Default 		{}
ParamType 2 Var  lAppend 		As Logical	 Default 	.T.
ParamType 3 Var  nIndice 		As Numeric	Default 0
ParamType 3 Var  cChave 			As Character	Default 	""

//Se não encontrou, insere o registro
If !lAppend .AND. nIndice > 0
	(cAlias)->(DbSetOrder(nIndice))
	lAppend := !(cAlias)->(DbSeek(cChave)) 
EndIf

If lDecode
	//Formata campo NOMETABELA_USERLG?, Exemplo: Iniciando com "S": SLT->LT_USERLGI, caso contrário MDZ->MDZ_USERGI
	If Substr(Upper(cAlias), 1, 1) == "S"
		cLogICpo := Substr(cAlias, 2, 2) + "_USERLGI"
		cLogACpo := Substr(cAlias, 2, 2) + "_USERLGA"
	Else
		cLogICpo := cAlias + "_USERGI"
		cLogACpo := cAlias + "_USERGA"
	EndIf
	
	If (nPosLGI := AScan( aData, { |x| x[1] == cLogICpo } )) > 0
		aData[nPosLGI][2] := Decode64(aData[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aData, { |x| x[1] == cLogACpo } )) > 0
		aData[nPosLGA][2] := Decode64(aData[nPosLGA][2])
	EndIf
EndIf

//Se  for atualizar, o registro deve estar  posicionado
lRet := STFSaveTab( cAlias , aData , lAppend)  


RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*
	Funcoes para execucao da subida da venda para central de PDV
	com componete de comunicao. pois o mesmo nao deixava habilitar a mesma 
	funcao para dois perfis diferentes
*/ 
//-------------------------------------------------------------------
Function _GeraL1L2L4( aSL1, aSL2, aSL4, cEstacao )
Return GeraL1L2L4( aSL1, aSL2, aSL4, cEstacao )

//-------------------------------------------------------------------
Function _ConfL1L2L4(cNum, cEstacao, lGravouOk) 	
Default lGravouOk := .F.
Return ConfL1L2L4(cNum, cEstacao, lGravouOk )    
 
//-------------------------------------------------------------------
Function _STDCancRec( cRegistros, cEmp, cFil ) 	
Return STDCancRec( cRegistros, cEmp, cFil )

//-------------------------------------------------------------------
Function _GeraMBZ(cAlias, aMBZREg) 	
Return GeraMBZ(cAlias, aMBZREg)

//-------------------------------------------------------------------
Function _ConfMBZ(aReg) 	
Return ConfMBZ(aReg) 

//-------------------------------------------------------------------
Function _GeraSFI( aSFI ) 	
Return GeraSFI( aSFI )

//-------------------------------------------------------------------
Function _GeraE5( aSE5 ) 	
Return GeraE5( aSE5 )

//-------------------------------------------------------------------
Function _GeraSLX( aSLX )	
Return GeraSLX( aSLX )
 
//-------------------------------------------------------------------
Function _FRT020ABR(aSLW,lFunc) 	
Return FRT020ABR(aSLW,lFunc)
 
//-------------------------------------------------------------------
Function _FRT020FCH(aSLW,aSLT,lFunc) 	
Return FRT020FCH(aSLW,aSLT,lFunc)

//-------------------------------------------------------------------
Function _GeraSZ(cAlias, aSZ) 	
Return GeraSZ(cAlias, aSZ)

//-------------------------------------------------------------------
Function _STDRecXData( cAlias , aData, lAppend , nIndice , cChave, lDecode ) 	
Return STDRecXData( cAlias , aData, lAppend , nIndice , cChave, lDecode)
 
//-------------------------------------------------------------------
Function _STDConfRec( cAlias , nRecno , cNameField , cTextConf ) 	
Return STDConfRec( cAlias , nRecno , cNameField , cTextConf )
//-------------------------------------------------------------------
/*/{Protheus.doc} STDGrvCli
Subida do cadastro de cliente da central para a retaguarda
@Param 
@author  Varejo
@version P11.8
@since   17/01/2013
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGrvCli() 

Local aArea			:= GetArea()	// Guarda area
Local aData 		:= {} 	//Armazena os campos com seus valores
Local nX			:= 0	//Variavel de loop
Local xRet			:= ''	//Variavel de retorno do deploy
Local lContinua		:= .F. //Confirmacao do deploy
Local lRetServer	:= .F.	//Retorno do server
Local lExistCli		:= .F.	//Cliente ja existe?
Local cFieldName	:= "" //Nome do Campo
Local uValue		:= "" //Valor do Campo
Local nPosCodCli    := 0 //Posicao que vai estar o cod do cliente no array aData
Local nPosCodLoj    := 0 //Posicao que vai estar o cod da loja no array aData

CoNout('Entrou na funcao de subida do cliente -> STDGrvCli')

DbSelectArea('SA1')
SA1->(DbSetOrder(12)) //A1_FILIAL+A1_SITUA

While  SA1->( DbSeek(xFilial("SA1")+"00"))  .AND. !EOF() 
 
	CoNout('Encontrou cliente para subir -> STDGrvCli')

	Sleep(5000)
	For nX := 1 To SA1->(FCount())  
		cFieldName := FieldName( nX )
		uValue := FieldGet( nX )
		If AllTrim(cFieldName ) == 'A1_SITUA'
			uValue :=  ''
		ElseIf AllTrim(FieldName( nX )) $ 'A1_USERLGI|A1_USERLGA'
			uValue :=  EnCode64(uValue) 
		EndIf 
		
		If cFieldName == 'A1_COD'
			nPosCodCli := nX
		ElseIf cFieldName == 'A1_LOJA'
			nPosCodLoj := nX
		EndIf

		AAdd( aData , { cFieldName , uValue } )
	Next nX


	If Len(aData) > 0
		lContinua := STBRemoteExecute( "STDPesqCli" , { xFilial("SA1"), aData[nPosCodCli][2], aData[nPosCodLoj][2] } , NIL, .F. , @lExistCli )
	EndIf
    
	CONOUT("STDPesqCli - Cliente: "+AllTochar(aData[1][2])+" - Loja: "+AllToChar(aData[2][2])+" - Retorno lExistCli: "+AllToChar(lExistCli))

	If lExistCli
		RecLock('SA1',.F.)
		SA1->A1_SITUA := 'DU'
		MsUnlock()	      
		CONOUT("CLIENTE JA EXISTE NA RETAGUARDA: "+AllToChar(SA1->A1_COD)+" - REGISTRO MARCADO COMO DU")
	EndIf
	
	If Len(aData) > 0 .AND. lContinua .AND. !lExistCli
		lContinua := STBRemoteExecute( "STDRecXData" , { 'SA1' , aData, /*lAppend*/ , /*nIndice*/ , /*cChave*/, .T.} , NIL, .F. , @xRet )
		
		//Trata o retorno xRet
		If lContinua .AND. ValType(xRet) == "A"   
			lRetServer := xRet[1] == "OK" 
			nRecServer := xRet[2]
		ElseIf lContinua .AND. ValType(xRet) == "L" 
	   		lRetServer := xRet
		EndIf		

		If lContinua .AND. lRetServer	
			RecLock('SA1',.F.)
			SA1->A1_SITUA := 'TX'
			MsUnlock()
		ElseIf lContinua .AND. !lRetServer	
			RecLock('SA1',.F.)
			SA1->A1_SITUA := 'ER'
			MsUnlock()	
		EndIf		
	EndIf
	
	nX := 1
	aData := {}
	SA1->(DbSkip())
	
EndDo

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STDPesqCli
Verifica se o cliente na existe na base da retaguarda
@Param 		cFil - Filial do cliente
@Param 		cCodCli - Codigo do cliente
@Param 		cCodLoja - Codigo da loja
@author  	Varejo
@version 	P11.8
@since   	17/01/2013
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPesqCli(cFil, cCodCli, cCodLoja)

Local lRet := .F.

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

cFil := PadR(cFil,TamSX3('A1_FILIAL')[1])
cCodCli := PadR(cCodCli,TamSX3('A1_COD')[1])
cCodLoja := PadR(cCodLoja,TamSX3('A1_LOJA')[1])

If SA1->(DbSeek(cFil + cCodCli + cCodLoja))
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDConGrvB
Verifica se foi executado LjGrvBatch na base da retaguarda
consultando se L1_SITUA = "OK"
Executo somente de Central de PDV e Ambiente Central

@Param 		cFil - Filial do cliente
@Param 		cCodCli - Codigo do cliente
@Param 		cCodLoja - Codigo da loja
@author  	Varejo
@version 	P12.1.17
@since   	01.06.2018
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDConGrvB( cPDV, cDoc, lDocNf, cSerPed, cDocPed, cSerie )
Local aAreaSL1		:= SL1->(GetArea())	// Guarda area
Local lRet			:= .F.			// Variável lógica
Local aRet			:= {}			// Retorno
Local lSeek			:= .F. //Armazena um logico para informar se encontrou a venda ou nao
Local cAuxSeek		:= ""

Default lDocNf := .F.
Default cSerPed := ""
Default cDocPed := ""
Default cSerie  := ""

DbSelectArea("SL1")

If !lDocNf
	if Empty(cSerie)
		SL1->( DbSetOrder(8) ) 		//L1_FILIAL+L1_PDV+L1_DOC
		cAuxSeek := xFilial("SL1") + cPDV + cDoc
	else
		SL1->( DbSetOrder(2) ) 		//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		cAuxSeek := xFilial("SL1") + cSerie + cDoc + cPDV
	endif

	If SL1->(DbSeek( cAuxSeek ))
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_PDV/L1_DOC:",SL1->L1_PDV+"/"+SL1->L1_SERIE+"/"+SL1->L1_DOC)
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_SITUA:",SL1->L1_SITUA)
		lSeek := .T.
	Else
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_PDV/L1_DOC não encontrada:",cPdv+"/"+cDoc)
	EndIf

Else

	SL1->(DbSetOrder(11)) //L1_FILIAL+L1_SERPED+L1_DOCPED

	If SL1->(DbSeek( xFilial("SL1")+cSerPed+cDocPed )) .AND. AllTrim(SL1->L1_PDV) == AllTrim(cPDV)
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_SERPED/L1_DOCPED:",cSerPed+"/"+cDocPed)
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_SITUA:",SL1->L1_SITUA)
		lSeek := .T.
	Else
		LjGrvLog("SUBIDA_CANCELAMENTO_RET" ,"SL1->L1_SERPED/L1_DOCPED não encontrada:",cSerPed+"/"+cDocPed)
	EndIf

EndIf

If lSeek .AND. (SL1->L1_SITUA $ "OK|X0|X1|X2|X3") //X0 a X3 inclusive, pois nada interfere em cancelamento NFC-e ou SAT
	lRet := .T.
EndIf

aAdd(aRet, lRet)
RestArea(aAreaSL1)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGetSrNF
Retorna o valor de algum campo da SLG

@Param 		cCodEst -> Codigo da estacao
@Param 		cCampo -> Campo da SLG que sera retornado
@author  	Bruno Almeida
@version 	P12
@since   	02/07/2019
@return  	cRet -> Retorno da funcao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDGetSrNF(cCodEst,cCampo)

Local cRet 		:= "" //Variavel de retorno
Local aAreaSLG 	:= SLG->(GetArea()) //Guarda a area da SLG
Local nPos		:= SLG->(FieldPos(cCampo)) //Verifica se o campo existe

Default cCodEst := ""

DbSelectArea("SLG")                                      
DbSetOrder(1)//LG_FILIAL+LG_CODIGO
If SLG->(DbSeek(xFilial("SLG")+cCodEst)) .AND. nPos > 0
	cRet := SLG->(FieldGet(nPos))
EndIf

RestArea(aAreaSLG)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpDro
Sobe para Retaguarda, informações das tabelas do Template de Drogaria.

@author  albertod
@version P12.1.27
@since   26/03/2021

@param  cPDV, Caractere, Código do PDV.

@return  Nil, Nulo
/*/
//-------------------------------------------------------------------
Function STDUpDro( cPDV )
Local aTables   := {}
Local nInd      := 0
Local cAliasTab := ""
Local nOrder    := 0
Local cChave    := 0
Local cBusca    := ""

If ExistTemplate("FRTGrvSZ")
	aTables := ExecTemplate("FRTGrvSZ",.F.,.F.,Nil)

    //Verifica se o array aTables foi retornado na nova estrutura pela template function FRTGrvSZ
    If Len(aTables) > 0 .And. Len(aTables[1]) > 2
        For nInd := 1 To Len(aTables)
            cAliasTab := aTables[nInd][1]   //Alias da tabela
            nOrder    := aTables[nInd][2]   //Indice da tabela referente ao campo _SITUA
            cChave    := aTables[nInd][3]   //Chave do indice
            cBusca    := aTables[nInd][4]   //Chave de Busca

            STDRecTabServer(cAliasTab, nOrder, cChave, cBusca, "OK", "OK", cPDV )
        Next nInd
    EndIf
EndIf

Return Nil