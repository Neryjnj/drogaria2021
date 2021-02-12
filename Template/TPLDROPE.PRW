#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"    
#INCLUDE "AUTODEF.CH"
#INCLUDE "TPLDROPE.CH"  
 
Static nTotPontos				// Variavel que acumula o total de pontos da venda - Front
Static cCodRegra				// Armazena o c๓digo da regra da promo็ใo geral - Front
Static cUsrSessionID  			// Id para autentica็ใo no WebServer - Front
Static lPesqDescGer     		// Determina se a regra geral de desconto jแ foi pesquisada
Static lCupAberto       		// Determina que uma venda ainda estแ em andamento
Static nPtsA1           		// Ira receber uma da funcao cujo seu resultado eh obtido atraves do WEBSERVICE que traz a pontuacao do cliente antes de finalizar a venda
Static lJaChamouANVISA	:= .F.	// Verifica se a tela para informacoes da ANVISA ja' foi solicitada

//ฺฤฤฤฤฤฤฤฟ
//ณDEFINESณ
//ภฤฤฤฤฤฤฤู 
#DEFINE CTRL Chr(13)+Chr(10)	//Pula Linha
#DEFINE FORMPAG		"FI"		// Forma de pagamento

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDroVldPln บAutor  ณVendas Cliente      บ Data ณ  29/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPonto de Entrada para adicionar novas tabelas para a geracaoบฑฑ
ฑฑบ          ณda carga (Retaguarda para os PDVs)                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria - FRTA010A                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Array que contem as novas tabelas para a geracao   บฑฑ
ฑฑบ          ณ         da carga nas estacoes.                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtCarga()
Local aRet := ParamIxb[1]

If HasTemplate("DRO")
	//Inclui arquivos utilizados pelo Template de Drogaria
	AAdd(aRet, "ACO")	//Cabe็alho - Tabela de Pre็os
	AAdd(aRet, "ACP")	//Itens - Tabela de Pre็os
	AAdd(aRet, "MHG")	//Cabe็alho - Planos de Fideliza็ใo
	AAdd(aRet, "LHF")	//Itens - Planos de Fideliza็ใo
	AAdd(aRet, "MHD")	//Cabe็alho - Kit de Produtos
	AAdd(aRet, "MHE")	//Itens - Kit de Produtos
	AAdd(aRet, "MA6")  	//Cartoes
	AAdd(aRet, "MAC")  	//Dependentes
	AAdd(aRet, "LFX")  	//Configuracao Cartoes 
Endif

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtDescIT บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do valor do item considerando a Regra de Desconto  บฑฑ
ฑฑบ          ณ pre-configurada                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtDescIT()
Local cCodProd    		:= ParamIxb[1]
Local nDescPer    		:= 0
Local nPercGrp	  		:= 0
Local nValDesc    		:= ParamIxb[3]
Local nVlrItem 	  		:= ParamIxb[4]//preco registrado na venda
Local _uProdTPL	  		:= ParamIxb[5]//Variavel Static criada em FRTA010A	
Local _uCliTPL	  		:= ParamIxb[6]//Variavel Static criada em FRTA010A	
Local _nQuant 	  		:= ParamIxb[7]//Quantidade escolhida para a venda
Local _lImpOrc 	  		:= ParamIxb[10] //Se o or็amento foi importado da Retaguarda
Local _cDoc	 	  		:= Iif(Len(ParamIxb)>10,ParamIxb[11],"") //Doc
Local _cSerie 	  		:= Iif(Len(ParamIxb)>11,ParamIxb[12],"") //Serie
Local aAreaAtu    		:= GetArea()
Local aAreaACP    		:= {}
Local aAreaACO    		:= {}
Local aAreaMHG    		:= {}
Local nDecimais   		:= MsDecimais(1)
Local aRet        		:= {}
Local nPtosProd   		:= 0
Local nPtosGrp	  		:= 0
Local cCodGrp	  		:= ""  			// codigo do grupo de produtos
Local _cCodPlano  		:= ""  		// codigo do plano de fidelidade
Local lAchouProd  		:= .F. 			// achou o codigo do produto na regra de desconto ?
Local lACOPercentual	:= .F.		// Verifica se o valor do campo ACO_PERDES esta' maior que zero
Local lCancANVISA		:= .F.		// Verifica se a tela da ANVISA foi cancelada            
Local nDescObr			:= 0			// Valor do Desconto Obrigatorio            
Local lBIDescOrb		:= SBI->(ColumnPos("BI_DESCOBR") > 0)
Local lTPLDRO01			:= ExistFunc("U_TPLDRO01()")			//Verifica se a funcao esta' compilada no rpo
Local nAuxPDesc			:= 0								//Armazena o retorno do ponto de entrada TPLDRO01
Local cClient           := ""          //Armazena o codigo do cliente
Local cLojaCl           := ""          //Armazena a Loja do cliente
Local cClassTe			:= '' 
Local lVidaLink			:= Iif(Len(ParamIxb)>12,ParamIxb[13],.F.) //Registro pelo vidalink
Local cReceita			:= "" //C๓digo da Receita
Local cNomePac			:= "" //C๓digo do Paciente
Local nItem 			:= 0 //Item da receita
Local lInfoAnvisa		:= .F. //Informou a tela da Anvisa
Local lJaAnvisa			:= .F. //Ja chamou a tela da anvisa
Local _nPosItem			:= 0 //Item da Receita
Local cSupervisor		:= Space(25)
Local lPermTelAnv		:= .F.

If FunName() == "FRTA271"
	cClient := ParamIxb[8] 
	cLojaCl := ParamIxb[9]
Else	 
	cClient := cCliente
	cLojaCl := cLojaCli
Endif

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPegando o prece unitario do produto.                               ณ
//ณO preco verificado no momento do desconto sempre sera' o           ณ
//ณpreco unitario do produto e nao o preco vezes a quantidade de itensณ
//ณna venda.                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbselectArea("SBI")
DbSetOrder(1)
If DbSeek(xFilial("SBI")+cCodProd)
	nVlrItem 	 := SBI->BI_PRV    
	If lBIDescOrb  
		nDescObr := SBI->BI_DESCOBR
	EndIf
Endif

// Caso a variavel uCliTPL nใo exista aborta a execu็ใo da Template Function
If ValType(_uCliTPL) == "U"
	// Caso a variแvel _uProdTPL nใo exista, tipifica a variแvel como array
	If ValType(_uProdTPL) == "U"
		_uProdTPL := {}
	EndIf
	AAdd(_uProdTPL,{0,cCodProd,0,0,.F.})
	
	_uCliTPL := Space(TamSx3("MHG_CODIGO")[1])
EndIf

// Caso a variavel _uProdTPL nใo exista, tipifica a variแvel como array
If ValType(_uProdTPL) == "U"
	_uProdTPL := {}
EndIf

// Caso a variavel lCupAberto nใo exista, tipifica a variแvel como boleana e .T., determinando que
// existe uma venda em andamento.
If Type("lCupAberto") == "U" .OR. !lCupAberto
	lCupAberto := .T.
EndIf
                     
// Valoriza array com dados referentes ao desconto e aos pontos para o plano de fidelidade
AAdd(_uProdTPL,{0,cCodProd,0,0,.F.})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ|
//ณVenda realizada para cliente padrao.        ณ
//ณIra verificar se o CLIENTE PADRAO contem um ณ
//ณPlano de Fidelidade                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ|     
If Empty( _uCliTPL )
	DbselectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
	If (!Empty(SA1->A1_CODPLF1) .AND. (SA1->A1_SITUAP1 = "A"))
		_cCodPlano := SA1->A1_CODPLF1
		_uCliTPL    := Posicione("MHG",1,xFilial("MHG")+_cCodPlano,"MHG_CODREG")
	Endif
Endif

If !Empty(_uCliTPL)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica primeiro se o campo ACO_PERDES esta' com o valor maior que zero          ณ
	//ณcaso isso seja verdadeiro, usa o percentual de desconto deste campo para todos os ณ
	//ณprodutos escolhidos na venda.                                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbselectArea("ACO")
	DbSetOrder(1)
	If DbSeek(xFilial("ACO") + _uCliTPL)
		If	ACO->ACO_PERDES > 0
			nDescPer := ACO->ACO_PERDES
			lACOPercentual := .T.
		Endif
	Endif
	If !lACOPercentual
		DbselectArea("ACP")
		aAreaACP := GetArea()
		dbOrderNickName("ACPDRO1")
		If DbSeek(xFilial("ACP")+_uCliTPL+cCodProd)
			// Determina o % de desconto do produto
			nDescPer  := ACP->ACP_PERDES
			// Determina os pontos de fideliza็ใo do produto
			nPtosProd := ACP->ACP_PONTOS
			lAchouProd := .T.
		Else
			// Determina o % de desconto do produto
			nDescPer  := 0
			// Determina os pontos de fideliza็ใo do produto
			nPtosProd := 0
		Endif
	Endif	
EndIf    

If !lACOPercentual .AND. !lAchouProd                    
	DbselectArea("SBI")
	SBI->(DbSetOrder(1))
	SBI->(DbSeek(xFilial("SBI")+cCodProd))
	cCodGrp := BI_GRUPO                                      
	
	If Empty(cCodGrp)// caso nao exista grupo de produto associado ao produto
		// Determina o % de desconto do produto
		nPercGrp  := 0
		// Determina os pontos de fideliza็ใo do produto
		nPtosGrp  := 0
	Else                        
		DbselectArea("ACP")
		aAreaACP := GetArea()
		DbSetOrder(2)		
		If DbSeek(xFilial("ACP")+_uCliTPL +AllTrim(cCodGrp))
			If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
			   ( nVlrItem >= ACP->ACP_FAIXDE .AND. nVlrItem <= ACP->ACP_FAIATE )			
				// Determina o % de desconto do produto
				nPercGrp  := ACP->ACP_PERDES
				// Determina os pontos de fideliza็ใo do produto
				nPtosGrp := ACP->ACP_PONTOS				   	
			Endif   
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se existe o grupo pai                                   ณ
			//ณOBS: GRUPO PAI contem somente um digito, como por exemplo:       ณ
			//ณGRUPO MEDICAMENTOS = 1                                           ณ
			//ณ                                                                 ณ
			//ณGrupos que sao compostos por mais de um digito, eh definido como ณ
			//ณSUBGRUPO, como por exemplo:                                      ณ
			//ณGRUPO MEDICAMENTOS CONTROLADOS = 1C                              ณ
			//ณeh um SUBGRUPO do grupo "1"                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
			If DbSeek(xFilial("ACP")+_uCliTPL +AllTrim(Left(cCodGrp,1)))		
				If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
				   ( nVlrItem >= ACP->ACP_FAIXDE .AND. nVlrItem <= ACP->ACP_FAIATE )			
					// Determina o % de desconto do produto
					nPercGrp  := ACP->ACP_PERDES
					// Determina os pontos de fideliza็ใo do produto
					nPtosGrp := ACP->ACP_PONTOS				   	
				Endif   				
			Endif
		Endif
	Endif	
	If nDescPer == 0 .AND. nPercGrp > 0 // Verifica qual he o maior desconto (Grupo ou Produto)
		nDescPer  := nPercGrp
		nPtosProd := nPtosGrp
	Endif
	
	// Inicializa a variแvel
	If ValType(lPesqDescGer) == "U"
		lPesqDescGer := .F.
	EndIf
	
	If !lPesqDescGer
		DbselectArea("ACO")
		aAreaACO := GetArea()
		DbSetOrder(1)
		While !Eof()
			// Eh uma regra de desconto gen้rica
			DbselectArea("MHG")
			If Empty(aAreaMHG)
				aAreaMHG := GetArea()
			EndIf
			DbSetOrder(3)
			If !DbSeek(xFilial("MHG")+ACO->ACO_CODREG)
				DbselectArea("ACP")
				dbOrderNickName("ACPDRO1")
				If DbSeek(xFilial("ACP")+ACO->ACO_CODREG+cCodProd)
					If ACP->ACP_PERDES > nDescPer
						// Determina o % de desconto do produto
						nDescPer  := ACP->ACP_PERDES
						// Determina os pontos de fideliza็ใo do produto
						nPtosProd := ACP->ACP_PONTOS
					EndIf
				ElseIf !Empty(cCodGrp)
					DbselectArea("ACP")
					aAreaACP := GetArea()
					DbSetOrder(2)
					DbSeek(xFilial("ACP")+_uCliTPL+Left(cCodGrp,Len(cCodGrp)))
					While !Eof() .AND. xFilial("ACP")+_uCliTPL+Left(cCodGrp,Len(cCodGrp)) == ACP->ACP_FILIAL+ACP->ACP_CODREG+Left(ACP->ACP_GRUPO,Len(ACP->ACP_GRUPO))
						If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
							 ( nVlrItem >= ACP->ACP_FAIXDE .AND. nVlrItem <= ACP->ACP_FAIATE )
							// Determina o % de desconto do produto
							nPercGrp  := ACP->ACP_PERDES
							// Determina os pontos de fideliza็ใo do produto
							nPtosGrp  := ACP->ACP_PONTOS
						EndIf
						DbSkip()
					End
				EndIf
				If nPercGrp > nDescPer // Verifica qual he o maior desconto (Grupo ou Produto no Plano)
					nDescPer  := nPercGrp
					nPtosProd := nPtosGrp
				Endif			
				// Determina a Regra de Desconto Gen้rica
				cCodRegra := ACO->ACO_CODREG
				Exit
			EndIf
			DbselectArea("ACO")
			dbSkip()
		End
		// Variแvel Static que Determina que jแ foi pesquisada uma Regra de Desconto Gen้rica
		lPesqDescGer := .T.
	ElseIf lPesqDescGer .AND. (ValType(cCodRegra) <> "U")
		DbselectArea("ACP")
		dbOrderNickName("ACPDRO1")
		If DbSeek(xFilial("ACP")+cCodRegra+cCodProd)
			If ACP->ACP_PERDES > nDescPer
				// Determina o % de desconto do produto
				nDescPer  := ACP->ACP_PERDES
				// Determina os pontos de fideliza็ใo do produto
				nPtosProd := ACP->ACP_PONTOS
			EndIf
		ElseIf !Empty(cCodGrp)
			DbselectArea("ACP")
			aAreaACP := GetArea()
			DbSetOrder(2)
			DbSeek(xFilial("ACP")+_uCliTPL+Left(cCodGrp,Len(cCodGrp)))
			While !Eof() .AND. xFilial("ACP")+_uCliTPL+Left(cCodGrp,Len(cCodGrp)) == ACP->ACP_FILIAL+ACP->ACP_CODREG+Left(ACP->ACP_GRUPO,Len(ACP->ACP_GRUPO))
				If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
					 ( nVlrItem >= ACP->ACP_FAIXDE .AND. nVlrItem <= ACP->ACP_FAIATE )
					// Determina o % de desconto do produto
					nPercGrp  := ACP->ACP_PERDES
					// Determina os pontos de fideliza็ใo do produto
					nPtosGrp  := ACP->ACP_PONTOS
				EndIf
				DbSkip()
			End	
		EndIf
	EndIf        
Endif

If nDescObr > nDescPer
	 nDescPer := nDescObr
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para calculo do % de desconto a ser aplicadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTPLDRO01
	nAuxPDesc := U_TPLDRO01( cCodProd, nDescPer, _uCliTPL ) //Produto, % Desconto, Regra de Desconto
	If ValType(nAuxPDesc) == "N"
		nDescPer := nAuxPDesc
	Endif
Endif

nDescPer += ParamIxb[2]

// Calcula o valor do desconto
nValDesc += ( _nQuant * Round(nVlrItem * (nDescPer/100),nDecimais) )

// Calcula o novo valor do item
nVlrItem -= nValDesc

// Valoriza array com dados referentes ao desconto
_uProdTPL[Len(_uProdTPL)][3] := nDescPer

// So' considera os pontos caso o cliente e loja nใo sejam padr๕es
If cClient+cLojaCl == SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD")
	_uProdTPL[Len(_uProdTPL)][4] := 0
Else
	_uProdTPL[Len(_uProdTPL)][4] := nPtosProd
EndIf

// Realiza o cแlculo dos Pontos X R$
If !Empty(_uProdTPL[Len(_uProdTPL)][4])
	_uProdTPL[Len(_uProdTPL)][4] := (nVlrItem * _uProdTPL[Len(_uProdTPL)][4])
EndIf

// Valoriza array de retorno da Template Function
aAdd(aRet,nDescPer)
aAdd(aRet,nValDesc)
aAdd(aRet,aClone(_uProdTPL))
aAdd(aRet,_uCliTPL)

// Restaura แrea original do arquivo ACP
If !Empty(aAreaACP)
	RestArea(aAreaACP)
EndIf

// Restaura แrea original do arquivo ACO
If !Empty(aAreaACO)
	RestArea(aAreaACO)
EndIf

// Restaura แrea original do arquivo MHG
If !Empty(aAreaMHG)
	RestArea(aAreaMHG)
EndIf

// Restaura แrea original
RestArea(aAreaAtu)

/*
Verifica se o produto eh do tipo CONTROLADO e jแ nใo foi registrado pelo vidalink
*/
If T_DroVerCont( cCodProd ) .And. !lVidaLink
	
	lPermTelAnv := LjProfile(42,@cSupervisor)
	
	If lPermTelAnv
		/* Verifica se a tela de Controle da ANVISA ja' foi solicitada anteriormente
			e se nใo ้ importado da retaguarda. */

		/* verifica no array aAnvisa se tem dados digitados de algum remedio ja vendido anteriormente 
		 retirada a verificacao que havia acima, porque em um segundo medicamento , tem que informar todos os dados novamente.*/
		lJaChamouANVISA := .F. 
		lJaAnvisa := T_DroVERArray(_cDoc, _cSerie, @cReceita, @cNomePac, @_nPosItem)

		If lJaAnvisa .AND. ValType(_nPosItem) = "N" .AND. _nPosItem > 0
			lInfoAnvisa := MsgYesNo("Copiar as informa็๕es digitadas na receita: " + cReceita + "Paciente: " + cNomePac )
		EndIf
		
		If  !lJaChamouANVISA .AND. !_lImpOrc   
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณChamada a tela para acrescentar informacoesณ
			//ณdo medicamento controlado                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !T_DroVSNGPC( .F.		, .T.	,cClient	,cLojaCl	,;
							@cClassTe	,nItem	, 			,  lInfoAnvisa, ;
							lJaAnvisa, _nPosItem,lPermTelAnv)
				lCancANVISA := .T.	
			Endif	
			lJaChamouANVISA := .F.
		Else 
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAcrescenta informacoes do item no array temporario da ANVISAณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			T_DroAddANVISA( .F., NIL, .F. )
		Endif
	Else
		MsgStop("Usuแrio nใo tem permissใo para venda de medicamentos controlados")
		lCancANVISA := .T.
	EndIf
Endif

aAdd(aRet, lCancANVISA) 

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtCodB2  บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 					                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtCodB2()

Local aAreaAtu  := GetArea()
Local _aAux		:= aClone(ParamIxb[1])
Local _uProdTPL := aClone(ParamIxb[2])					// Variavel Static criada em FRTA010A
Local _uCliTPL  := ParamIxb[3]							// Variavel Static criada em FRTA010A

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

If (ValType(_uProdTPL) == "U") .OR. (ValType(_uProdTPL) == "A") .AND. (_aAux[1] > Len(_uProdTPL))
	If (ValType(_uProdTPL) == "U")
		_uProdTPL := {}
	EndIf
	
	DbselectArea("SL1")
	If ColumnPos("L1_CPLFIDE") > 0
		If ValType(_uCliTPL) == "U"
			_uCliTPL := SL1->L1_CPLFIDE
		EndIf
		
		DbselectArea("SL2")
		AAdd(_uProdTPL,{_aAux[1],_aAux[2],SL2->L2_DESC,SL2->L2_PONTOS,.F.})
		
		// Soma o total de pontos acumulados, at้ o momento, na venda
		If Len(_uProdTPL) == 1
			nTotPontos := 0
		EndIf
		
		If Len(_uProdTPL) > 0
			If ValType(nTotPontos) <> "N" // Converte o tipo caso nao seja numero
				nTotPontos := 0
			EndIf
			nTotPontos += _uProdTPL[Len(_uProdTPL)][4]
		Endif
	EndIf
	
	If ValType( _uProdTPL ) == "A"
		_aAux[13] := aClone(_uProdTPL)
	Else
		_aAux[13] := _uProdTPL
	Endif
	
	If ValType( _uCliTPL ) == "A"
		_aAux[14] := aClone(_uCliTPL)
	Else
		_aAux[14] := _uCliTPL
	Endif
	
	// Restaura a area original
	RestArea(aAreaAtu)
EndIf

Return _aAux

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtCodB3  บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  			                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtCodB3()

Local _aAux 	:= ParamIxb[1]
Local _uProdTPL := aClone(ParamIxb[2])	//Variavel Static criada em FRTA010A
Local _uCliTPL  := ParamIxb[3]			//Variavel Static criada em FRTA010A
Local aAreaAtu  := GetArea()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

// Valoriza o array, que possui dados referentes ao desconto no item e ao pontos do plano de fidelidade, com o
// n๚mero do item que estแ sendo registrado.
If (ValType(_uProdTPL) == "A") .AND. !Empty(_uProdTPL) .AND. (Val(SL2->L2_ITEM) == Len(_uProdTPL))
	_uProdTPL[Len(_uProdTPL)][1] := Val(SL2->L2_ITEM)
	
	If ValType(nTotPontos) <> "N" // Converte o tipo caso nao seja numero
		nTotPontos := 0
	EndIf
	
	// Soma o total de pontos acumulados, at้ o momento, na venda
	If Len(_uProdTPL) == 1
		nTotPontos := 0
	EndIf
	nTotPontos += _uProdTPL[Len(_uProdTPL)][4]
	
	// Realiza Grava็ใo do c๓digo do plano de fidelidade utilizado e dos pontos adquiridos
	DbselectArea("SL1")
	If (SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD")) .AND.;
		(ColumnPos("L1_CPLFIDE") > 0) .AND. (ColumnPos("L1_PONTOS") > 0)
		
		DbselectArea("SL1")
		RecLock("SL1",.F.)
		L1_CPLFIDE := _uCliTPL
		L1_PONTOS  := nTotPontos
		MsUnLock()
		
		// Realiza Grava็ใo dos pontos adquiridos por item vendido
		DbselectArea("SL2")
		RecLock("SL2",.F.)
		L2_PONTOS := _uProdTPL[Len(_uProdTPL)][4]
		MsUnLock()
	EndIf
	_aAux[13] := aClone(_uProdTPL)
	_aAux[14] := _uCliTPL	

	// Restaura a area original
	RestArea(aAreaAtu)
EndIf

Return _aAux

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtCancelaบAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  			                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtCancela()
Local _uProdTPL 	:= ParamIxb[4]

If HasTemplate("DRO")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ1 = Esta' cancelando um item da venda ณ
	//ณ2 = Esta' cancelando o cupom          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ParamIxb[1] == 2
		// Reinicializa variแveis 'static' para a pr๓xima venda.
		nTotPontos   	:= Nil
		cCodRegra    	:= Nil
		lPesqDescGer 	:= Nil
		lCupAberto   	:= .F.
		lJaChamouANVISA	:= .F.	
	EndIf
Endif
Return _uProdTPL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRT010CL  บAutor  บVendas Cliente        บ Data บ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Escolha do Plano de Fidelidade.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FRT010CL()
Local bOk															// Botao Ok da Enchoice Bar
Local bCancel														// Botao Cancel da Enchoice Bar
Local cRet				:= "" 										// Codigo do plano de fidelidade
Local lRet				:= .F.										// Controle para a escolha do cliente	
Local cSeek				:= '"' + xFilial("MHG") + '"'				// Chave de busca
Local cWhile			:= "!EOF() .AND. MHG_FILIAL==" + cSeek		// Complemento da chave de busca
Local cCodReg			:= ""										// Codigo da regra de desconto
Local cFilter 			:= "" 										// Filtro utilizado na locxgrid
Local aDadCart			:= ParamIxb[1]
Local _uCliTpl			:= ParamIxb[2]
Local cDtaVenCli		:= Space(08)								// Vencimento do limite de credito do cliente
Local aRet				:= {}										// Array para a montagem da tela de escolha de planos de fidelidade
Local aRetCar			:= {.T.,Nil}								// Retorno da funcao
Local aAreaSA1			:= {}										// Area SA1
Local aRetNumCart		:= {}										// Array que contem infirmacoes do cartao do cliente
Local _cCodConv			:= ParamIxb[3]								// Codigo do cliente
Local _cLojConv			:= ParamIxb[4]								// Loja do cliente
Local _cNumCartConv		:= ParamIxb[5]								// Numero do cartao  
Local lCxAbert          := .F.										// Recebe o parametro de Caixa Aberto
Local lOcios            := .F.                                     // Recebe o parametro para saber se fazendo venda 
local cClient           := ""                                       //Recebe o cliente  
Local cLojaCl           := ""                                        // Recebe o numero da loja
Local lConvenio			:= ValType(_cCodConv)     == "C" .AND.;
						   ValType(_cLojConv)     == "C" .AND.;
						   ValType(_cNumCartConv) == "C"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos para a criacao da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private	oDlg
Private oLbx
Private oLbxCli
Private oDlgCli
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.

If FunName() == "FRTA271"
	lCxAbert := ParamIxb[6] 
	lOcios   := ParamIxb[7]
Else
	lCxAbert := lCxAberto
	lOcios   := lOcioso	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do filtro da locxgrid                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilter := '((MHG_CODIGO == SA1->A1_CODPLF1 .AND. SA1->A1_SITUAP1 == "A") .OR. (MHG_CODIGO == SA1->A1_CODPLF2 .AND. SA1->A1_SITUAP2 == "A") .OR. ' +;
'(MHG_CODIGO == SA1->A1_CODPLF3 .AND. SA1->A1_SITUAP3 == "A") .OR. (MHG_CODIGO == SA1->A1_CODPLF4 .AND. SA1->A1_SITUAP4 == "A").OR. ' +;
'(MHG_CODIGO == SA1->A1_CODPLF5 .AND. SA1->A1_SITUAP5 == "A"))'

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se o caixa nao estiver aberto nao permite continuar ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lCxAbert
	aRetCar[1]  := .F.
	Return(aRetCar)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ A variavel 'lOcioso' (Private / Fonte Frta010a) determina se jแ existe venda em andamento ou nใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lOcios
	If ValType(_uCliTPL) <> "U"
		aRetCar[2] := _uCliTpl
	Else
		aRetCar[2] := cCodReg
	EndIf
	Return(aRetCar)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a data de vencimento do limite de credito ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cDtaVenCli := DtoS(SA1->A1_VENCLC)
cDtaVenCli := SubStr(cDtaVenCli,5,2)+SubStr(cDtaVenCli,3,2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida a data de vencimento do cartao do cliente ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If 	Len( aDadCart ) > 0 .AND. Len( aDadCart ) >= 3 .AND. !Empty( aDadCart[3] ) .AND. ( cDtaVenCli <> AllTrim( aDadCart[3] ) )
	MsgAlert(STR0013) //"Data de validade do cartใo invแlida. Informe uma data vแlida, ou um cartใo vแlido para que possa ser selecionado o cliente e dar continuidade na venda."
	If ValType( _uCliTPL ) <> "U"
		aRetCar[2] := _uCliTpl
	Else
		aRetCar[2] := cCodReg
	EndIf
	aRetCar[1] := .F.
	Return( aRetCar )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Salva a area de trabalho do SA1                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAreaSA1  := SA1->(GetArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara conveniados mostrar os planos de fidelidade da empresa de con-ณ
//ณvenio                                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SA1->A1_TPCONVE == "3"  //Conveniado                     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Busca os planos de fidelidade da empresa de convenio ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + SA1->A1_EMPCONV + SA1->A1_LOJCONV ) )
	lRet := .T.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara clientes normais mostrar os planos de fidelidade do mesmo     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SA1->A1_TPCONVE == "1"  //Normal
	lRet := .T.
EndIf

IF ( Empty( SA1->A1_CODPLF1 ) .AND. Empty( SA1->A1_CODPLF2 ) .AND. Empty( SA1->A1_CODPLF3 ) .AND. ;
	 Empty( SA1->A1_CODPLF4 ) .AND. Empty( SA1->A1_CODPLF5 ) )
	 
	cFilter:='MHG_TIPO=="2" .OR. MHG_TIPO=="3" '
	
EndIf

If lRet  
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define os blocos de codigo para os botoes "Ok" e "Cancel" da dialog ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	bOk		:= {|| lRet := .T.,oDlg:End()}
	bCancel	:= {|| lRet := .F.,oDlg:End()}
               
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Forca a variavel lRet como .F. para controlar tb้m se o usuario cancelou ณ
	//ณ a tela com ESC e nao no botao cancel.                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRet := .F.
	DEFINE MSDIALOG oDlg TITLE STR0014 FROM 5,30 TO 25,80 STYLE DS_MODALFRAME //"Plano de Fidelizacao"
	
	aRet	:= LocxGrid( "MHG", cWhile, cFilter, .T., ".F.", cSeek, 1, {"MHG_NOME","MHG_CODIGO"}, Nil )
	aCab	:= AClone(aRet[3])
	aLin	:= AClone(aRet[5])
	aTam	:= AClone(aRet[4])
	aCpo	:= AClone(aRet[1])
	
	oLbx := TwBrowse():New(		030,		000,		000,		000,;
								Nil,		aCab,		aTam,		oDlg,;
								Nil,		Nil,		Nil,		Nil,;
								Nil,		Nil,		Nil,		Nil,;
								Nil,		Nil,		Nil,		.F.,;
								Nil,		.T.,		Nil,		.F.,;
								Nil,		Nil,		Nil )
	oLbx:nHeight	:= (__DlgHeight(oDlg)*2) - 8
	oLbx:nWidth		:= __DlgWidth(oDlg)*2
	oLbx:lColDrag	:= .T.
	oLbx:nFreeze	:= 1
	oLbx:SetArray(aLin)
	oLbx:bLine		:= LocxBLin('oLbx',aCpo,.T.)
	oLbx:bLDblClick	:={ || ChgMarkLb(oLbx,aLin,{|| .T. },.F.) }
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Nao permite que o usuario saia da tela clicando "ESC"          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlg:lEscClose := .F. 
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, bOk, bCancel, Nil, Nil )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retornar a area porque para conveniado estava posicionado na empresa de convenio      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SA1->(RestArea(aAreaSA1))
Endif

If !lRet                             
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se nao confirmou o cliente, volta FALSO para voltar a selecao para o ณ
	//ณ cliente padrao.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aRetCar[1]  := .F.
Else
	aEval( aLin, { |x,y| If( aLin[y,1] == 1, cRet := Alltrim(aLin[y,3]), ) } )
	cCodReg := Posicione("MHG",1,xFilial("MHG")+cRet,"MHG_CODREG")
	aRetCar[2] := cCodReg
	nPtsA1  := T_TPTOSANTV()
	//Variaveis Private do programa FRTA010A, que armazena o codigo do cliente caso encontre duas ocorrencias de CPF no SA1
	//Somente atribui as variaveis se o CPF estiver duplicado
	If lConvenio
		_cCodConv   := SA1->A1_COD
		_cLojConv   := SA1->A1_LOJA
		If FunName() == "FRTA271"
			cClient     := SA1->A1_COD
			cLojaCl     := SA1->A1_LOJA
		Else
			cCliente    := SA1->A1_COD
			cLojaCli    := SA1->A1_LOJA 
		EndIf 	
		aRetNumCart := CRDXNumCart()	// localizado no programa CRDXFUN
		//Atribuir o numero do cartao porque eh uma chave unica
		//A variavel cNumCartConv serah utilizada em outras customizacoes para posicionar no registro do SA1 correto,
		//selecionado pelo usuario no inicio da venda
		If aRetNumCart[1]
			_cNumCartConv  := aRetNumCart[2]
		Else                       
			// Faz a busca na base local do PDV
			aRetNumCart := LjBuscaCartao(xFilial("SA1"), _cCodConv, _cLojConv) // Localizado no programa WSCRD130
			If aRetNumCart[1]          
				_cNumCartConv  := aRetNumCart[2]			         
			Else                                        
				If  nModulo = 23 // modulo FRONT-LOJA
					_cCodConv     := SuperGetmv("MV_CLIPAD") // codigo do cliente padrao
					_cLojConv     := SuperGetmv("MV_LOJAPAD")// loja do cliente padrao
					_cNumCartConv := ""//numero do cartao retorna branco, pois eh cliente padrao                 
					Posicione("SA1",1,xFilial("SA1")+_cCodConv+_cLojConv,"A1_CODPLF1")//plano de fidelidade
					If (!Empty(SA1->A1_CODPLF1) .AND. (SA1->A1_SITUAP1 = "A"))
						aRetCar[2] := Posicione("MHG",1,xFilial("MHG")+SA1->A1_CODPLF1,"MHG_CODREG")//plano de fidelidade
					Else
						aRetCar[2] := Space(TamSx3("A1_CODPLF1")[1])
					Endif
				Endif
			Endif
		EndIf
	Else
		aRetCar[2] := Space(TamSx3("A1_CODPLF1")[1])
	EndIf
EndIf
aAdd(aRetCar,_cCodConv)
aAdd(aRetCar,_cLojConv)
aAdd(aRetCar,_cNumCartConv)
If FunName() == "FRTA271"
	aAdd(aRetCar,cClient)
	aAdd(aRetCar,cLojaCl)
EndIf
Return aRetCar

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRTCONDPAGบAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Escolha da Condicao de Pagamento					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FRTCONDPAG()
Local bKCode  := SetKey(116)
Local cRet    := ""
Local lRet    := .F.
Local cSeek   := ""
Local cWhile  := ""
Local aAreaAtu:= GetArea()
Local cAlias  := ""
Local aCpos   := {}

Local  cCodPag  := ""
Local  nPosTip	:= 0	
Local  nPosOper := 0	
Local  cAtual	:= ""	
Local  cOpera	:= ""
Local  _uCliTPL := ParamIxb[1]
Local  cCliVenda:= AllTrim(ParamIxb[2])
Local  cLojVenda:= AllTrim(ParamIxb[3])
Local  aPos		:= {}
Local  oPanel
Local  lIsLHF	:= .F.
Local  nX := 0 //Variavel de Loop
Local  aCondsPg := {} //Array para receber os registros da condicao de pagamento

Private	oDlg, oLbx
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.
Private lInclui := .F.
Private aCols   := {{"A"}}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

// Eh necessario para que o usuario nao pressione a tecla F5 vแrias vezes em sequencia.
SetKey(VK_F5, {|| })

If ValType(_uCliTPL) == "C" .AND. !Empty(_uCliTPL)
	cSeek  := '"' + xFilial("LHF") + MHG->MHG_CODIGO + '"'
	cWhile := "!EOF() .AND. LHF_FILIAL+LHF_CODIGO ==" + cSeek
	cAlias := "LHF"
	aCpos  := {"LHF_CONDIC","LHF_DESCRI"}
	lIsLHF := .T.
Else
	cSeek  := '"' + xFilial("SE4") + '"'
	cWhile := '!EOF() .AND. E4_FILIAL ==' + cSeek
	cAlias := "SE4"
	aCpos  := {"E4_CODIGO","E4_DESCRI"}
EndIf

/*remo็ใo da condi็ใo FINANCIADO para o Cliente Padrใo*/
If (cCliVenda + cLojVenda) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD"))
	Conout("Cliente padrใo nใo pode efetuar venda financiada, sera bloqueada da tela")
	LjGrvLog( NIL, "Cliente padrใo nใo pode efetuar venda financiada, sera bloqueada da tela")

	If lIsLHF
		cWhile += ' .AND. (IIf( AllTrim(LHF_CONDIC) == "FI",Eval({|| DbSkip(),.T.}),.T.))'
	Else
		cWhile += ' .AND. (IIf( AllTrim(E4_FORMA) == "FI",Eval({|| DbSkip(),.T.}),.T.))'
	EndIf
EndIf

SetKey(15, {|| lRet := .T.,oDlg:End()} ) //Ctrl + O

DEFINE MSDIALOG oDlg TITLE STR0015 FROM 5,30 TO 25,80 //"Condicao de Pagamento"

aPos	:= PosDlg(oDlg)
oPanel	:= TPanel():New(01, 01, "", oDlg,,,,,, aPos[4], aPos[3]*0.95)

aRet	:= LocxGrid(cAlias,cWhile,,.T.,".F.",cSeek,1,aCpos,)
aCab	:= AClone(aRet[3])

//Remove as linhas em branco da tela de condicao de pagamento
For nX := 1 To Len(aRet[5])
	If !Empty(aRet[5][nX][3])
		aadd(aCondsPg,aRet[5][nX])
	EndIf
Next nX

aLin	:= aCondsPg
aTam	:= AClone(aRet[4])
aCpo	:= AClone(aRet[1])

oLbx := TwBrowse():New(030,000,000,000,,aCab,aTam,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx:nHeight	:= (__DlgHeight(oPanel)*2) - 34
oLbx:nWidth		:= __DlgWidth(oPanel)*2
oLbx:lColDrag	:= .T.
oLbx:nFreeze	:= 1
oLbx:SetArray(aLin)
oLbx:bLine		:= LocxBLin('oLbx',aCpo,.T.)
oLbx:bLDblClick	:={ || ChgMarkLb(oLbx,aLin,{|| .T. },.F.) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,) CENTERED

SetKey(15, {|| } ) //Limpa o Ctrl + O ao fechar a tela de condicao de pgto.

If lRet
	aEval( aLin, { |x,y| If( aLin[y,1] == 1, cRet := Alltrim(aLin[y,2]), ) } )
	If ValType(_uCliTPL) == "C" .AND. !Empty(_uCliTPL)
		cCodPag := Posicione("LHF",1,xFilial("LHF")+MHG->MHG_CODIGO+cRet,"LHF_CONDIC")
	Else
		cCodPag := Posicione("SE4",1,xFilial("SE4")+cRet,"E4_CODIGO")
	EndIf
EndIf

// Reativa a tecla F5
SetKey(VK_F5, bKCode)

Return cCodPag

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRTALTPG  บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Escolha da Condicao de Pagamento					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FRTALTPG()
Local _Ret := .T.         
Local lRet := .T.
Local cMVLJTPPAG := ""

If FunName() == "FRTA271"
	If Len(ParamIxb) > 3 .And. !Empty(ParamIxb[2]) .And. ParamIxb[3]
		cMVLJTPPAG := ParamIxb[4] //Parametro MV_LJTPPAG. Condicoes de pagamento validas no recebimento.
		_Ret    := ParamIxb[2] $ cMVLJTPPAG .Or. Empty(cMVLJTPPAG) //Controle dos tipos de formas de pagto possiveis para recebimento dos titulos
	ElseIf !(SuperGetMV("MV_LJLBFRM",,.F.))//Habilita altera็ใo de forma de pagamento, quando execu็ใo de Template(Ex:Drogarias) no FrontLoja(Sendo .T. = SIM e .F. = Nao).   Padrใo .F., pois assim utiliza-se F5 para alterar forma de pagamento
		_Ret    := ParamIxb[3] 	
	EndIf
Else
	_Ret    := lRecebe		
Endif
// O ponto sempre retornarแ falso pois as teclas Ctrl + A, Ctrl + B, ... Nunca poderใo ser utilizadas.
lRet := _Ret

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFRTGrvSZ  บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTabelas para gravacao na retaguarda						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA020			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function FRTGrvSZ()

Local aRet := {}

// Determina que o arquivo LHG serแ gravado na retarguada e posteriormente serแ atualizado no BackOffice.
AAdd(aRet,{"LHG",4})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConteudo do array aFilesTPL              ณ
//ณ                                         ณ
//ณ[1][1] - Nome do Alias                   ณ
//ณ[1][2] - Indice referente ao campo _SITUAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aRet, {"LK9", 3})		// Logs ANVISA

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ7003    บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ					  										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function LJ7003()
Local cItem := ParamIxb[2]
Local nItem	:= 0				//ID ANVISA
Local lRet  := .T.					

If ValType(cItem) == "C"
	nItem := Val(cItem)
Else
	nItem := cItem	
Endif

// Executa a template function TdRea011()
lRet := T_TdRea011(2) 	// Valida Delecao do Item

If T_DroLenANVISA() > 0
	T_DroDelANVISA( .F., nItem )	
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ7002    บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada executado no final da venda				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJ7002()
Local nTipo 	:= ParamIxb[1]
Local aArea 	:= GetArea()  
Local lGrvBatch := .F.

Local aFuncTpl  := {} 
Local lFtvdVer12:= LjFTVD() //Compatibiliza็ใo Venda Direta x Venda Assisitida

// Verifica se a chamada tem origem do GRVBatch
If Len(ParamIxb) >= 3
	lGrvBatch := (ParamIxb[3] == 2)
EndIf

// Pula a execucao da funcao caso a chamada seja do GrvBatch
If !lGrvBatch
	//nRotina(variavel private do Loja701)
	If SuperGetMv("MV_PLSATIV",.F.,.F.) .AND. nRotina <> 4 
		If SLQ->(ColumnPos("LQ_MATRIC")) > 0 .AND. SL1->(ColumnPos("L1_MATRIC")) > 0 
			SL1->(Reclock("SL1",.F.))
			SL1->L1_MATRIC := M->LQ_MATRIC
			SL1->(MsUnlock())
			SL1->(dbCommit())
	   	Endif
	Endif	
	//so e' executada quando nao for RECEBIMENTO
	If !lRecebe
		T_TdRea011(4, ParamIxb[1])	// Chama para reinicializar todas as variแveis estแticas
	Endif
Else
	/* Chama o ponto de entrada para carregar o array de medicamentos de um 
	  orcamento importado, caso tenha remedio controlado */
	If ExistTemplate( "LJ7016" ) .AND. !lFtvdVer12
		aFuncTpl := ExecTemplate( "LJ7016", .F., .F., {4,0} )
	EndIf
EndIf

/*Depois da gravacao Orcamento/Venda, chama
a funcao para a gravacao na tabela Logs ANVISA */
T_DroGrvANVISA(nTipo)

//Inicializa as variaveis do tipo STATIC
lJaChamouANVISA := .F.

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ7016    บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ					  										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJ7016()
Local nOpc	  := ParamIxb[1]	// (4 - Finalizacao da Venda)
Local nAtalho := ParamIxb[2]	// Controle das teclas de atalho da toolbar
Local aBotoes := {}				// Retorno da funcao	
Local aAtalho := {}				// Controle de atalhos da toolbar

// Executa a template function TdRea011()
T_TdRea011(6,,ParamIxb[1])	// Carregar variแveis estแticas, pois se trata de finaliza็ใo de venda

If nOpc == 4
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura as informacoes no array aANVISAณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	T_DroRestANVISA()
	lJaChamouANVISA := .T.	
Else
	lJaChamouANVISA	:= .F.	// Verifica se a tela para informacoes da ANVISA ja' foi solicitada	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inclui a opcao "SNGPC - ANVISA" no menu Outros 		        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nAtalho++
aAtalho  := Lj7Atalho(nAtalho)
AADD(aBotoes,{"SNGPC - ANVISA","SNGPC - ANVISA","",{||If(T_DroLenANVISA() > 0,T_DroVSNGPC( .T., .T. ),)},.F.,.T.,4, aAtalho}) //"Receitas"###"Receitas"
nAtalho++
aAtalho  := Lj7Atalho(nAtalho)
AADD(aBotoes,{STR0095,STR0095,"",{||T_DROCONSPRC() },.F.,.T.,4, aAtalho}) //"Consulta Precos-Multimidia"
Return aBotoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTPLDRO_PGTO บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ			      	  										    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function TPLDRO_PGTO()
// Sempre .F., pois nenhuma condi็ใo de pagamento pode ser carregada, com exce็ใo daquelas
// vแlidas para o cliente e seu respectivo plano de fidelidade.
Local lRet := .F.

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtKit    บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ					  										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtKit()

Local aRet     := {}
Local cCodProd := ParamIxb[1]
Local aAreaAtu := GetArea()
Local aAreaMHD := {}
Local aAreaMHE := {}

DbselectArea("MHD")
aAreaMHD := GetArea()
DbSetOrder(1)
If DbSeek(xFilial("MHD")+cCodProd)
	DbselectArea("MHE")
	If Empty(aAreaMHE)
		aAreaMHE := GetArea()
	EndIf
	DbSetOrder(1)
	DbSeek(xFilial("MHE")+MHD->MHD_PRODUT)
	While !Eof() .AND. (MHE->MHE_FILIAL+MHE->MHE_PRODUT == xFilial("MHE")+MHD->MHD_PRODUT)
		AAdd(aRet,{MHE->MHE_CODCOM,MHE->MHE_QUANT})
		dbSkip()
	End
EndIf

// Restaura แrea do arquivo MHE
If !Empty(aAreaMHE)
	RestArea(aAreaMHE)
EndIf

// Restaura แrea do arquivo MHD
RestArea(aAreaMHD)

// Restaura แrea original
RestArea(aAreaAtu)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDCAR    บAutor  ณVendas Cliente      บ Data ณ  08/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da linha da GetDados do cadastro de clientes(CRD) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณCRDA010                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CrdCar()

Local _lRet        := .T.       
Local _cObj        := ParamIxb[1]
Local _cTipo       := ParamIxb[2]  //"L" - por linha do aCols;"T"- total do aCols
Local _nEsc		   := ParamIxb[3] // 1- Pesquisa 2-Visualiza 3-Incluir 4-Alterar 5-Excluir
Local _nX    	   := 0
Local _nCout 	   := 0
Local _aColsCart   := ParamIxb[9]
Local _aHeaderCart := ParamIxb[17]
Local _nPosNum     := Ascan(_aHeaderCart,{|x| Trim(x[2]) == "MA6_NUM"})

//verificacao na pasta 'CARTOES'
If _nEsc = 3  .OR. _nEsc = 4
	If _cObj == "6" .AND. _cTipo == "T" 
		For _nX := 1 to Len(_aColsCart)
		If _aColsCart[_nX][Len(_aColsCart[_nX])]
			loop
		Endif
		If Empty(_aColsCart[_nx][_nPosNum])
			_nCout++ 
		EndIf
		Next _nX
		
		If _nCout > 1
			MsgAlert(STR0016) //"Exsitem mais de uma linha em branco na pasta de Cart๕es"
			_lRet := .F.			
		EndIf
		
	Endif
		
Endif

Return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDBloqCarบAutor  ณVendas Cliente      บ Data ณ  01/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtiva/Bloqueia o cartao do dependente no MA6 quando atualizaบฑฑ
ฑฑบ          ณo status do cartao no MAC                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณX3_VALID do campo MAC_CARTAO                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDBloqCart()

Local _nPosCodDep  := Ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CODDEP"})
Local _nPosCartao  := Ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"}) //1=Sim;2=Nao;3=Inativo
Local _nPosSitua   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_SITUA"})  //1=Ativo;2=Bloqueado;3=Cancelado
Local _nPosDepCart := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_CODDEP"})
Local _nPosNumCart := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_NUM"})
Local _nX

If _nPosCodDep > 0 .AND. _nPosCartao > 0 .AND. _nPosSitua > 0 .AND. _nPosNumCart > 0
	_cCodDep  := oGetD5:aCols[n][_nPosCodDep]
	_cCodCli  := M->A1_COD
	_cLoja    := M->A1_LOJA
	lFound    := .F.
	If !Empty(_cCodDep)
		For _nX := 1 to Len(oGetD6:aCols)
			If oGetD6:aCols[_nX][Len(oGetD6:aCols[_nX])]
				Loop
			EndIf
			If Empty(oGetD6:aCols[_nX][_nPosNumCart])
				Loop
			EndIf
			If oGetD5:aCols[n][_nPosCodDep] == oGetD6:aCols[_nX][_nPosDepCart]
				lFound  := .T.
				Exit
			EndIf
		Next _nX
		If lFound
			If M->MAC_CARTAO == "3"  //Inativo
				oGetD6:aCols[_nX][_nPosSitua]  := "2"  //Bloqueado
				oGetD6:Refresh()
			ElseIf M->MAC_CARTAO == "1"   //Sim
				oGetD6:aCols[_nX][_nPosSitua]  := "1"  //Ativo
				oGetD6:Refresh()
			EndIf
		EndIf
	EndIf
EndIf

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDCLI01  บAutor  ณVendas Cliente      บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no registro do SA1 antes de validar o credito.    บฑฑ
ฑฑบ          ณCriado para o convenio, onde eh possivel ter dois clientes  บฑฑ
ฑฑบ          ณ(conveniados) com o mesmo CPF                               บฑฑ
ฑฑบ          ณRetorna o numero do cartao por se tratar de chave unica     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณCRDXFUN                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDCLI01()

Local _aRet       := ParamIxb[1] 
Local _lConvenio  := Type("cCodConv")=='C' .AND. Type("cLojConv")=='C' .AND. !Empty(cCodConv) .AND. !Empty(cLojConv) ;
.AND. Type("cNumCartConv")=="C" .AND. !Empty(cNumCartConv)  //Verifica se as variaveis de convenio estao prrenchidas
//CPF
If !Empty(_aRet[2]) .AND. _lConvenio
	DbselectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+cCodConv+cLojConv)
	_aRet  := {cNumCartConv,_aRet[2]}
	cCliente  := SA1->A1_COD
	cLojaCli  := SA1->A1_LOJA
	//Posiciona no registro que havia sido anteriormente selecionado pelo Caixa no inicio da venda
EndIf

Return (_aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDCLI03  บAutor  ณVendas Cliente      บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no registro do SA1 para consulta dos dados do cli-บฑฑ
ฑฑบ          ณente e buscar no servidor caso nao encontre na base local.  บฑฑ
ฑฑบ          ณCriado para o convenio, onde eh possivel ter dois clientes  บฑฑ
ฑฑบ          ณ(conveniados) com o mesmo CPF                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณCRDXFUN                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDCLI03()

Local xRet        := .T.
Local _lConvenio  := Type("cCodConv")=="C" .AND. Type("cLojConv")=="C"
Local _cCartao    := ParamIxb[1]
Local _cCPF       := ParamIxb[2]

//Se o Caixa digitou o CPF, buscar o numero do cartao correspondente por ser chave unica
If Empty(_cCartao)
	//Se for CPF, deve buscar o numero do cartao que eh chave unica
	If _lConvenio
		xRet  := TPLTelaConv(_cCPF)
	EndIf
EndIf

Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDCLI04  บAutor  ณVendas Cliente      บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no registro do SA1 para consulta do extrato do cliบฑฑ
ฑฑบ          ณente.                                                       บฑฑ
ฑฑบ          ณCriado para o convenio, onde eh possivel ter dois clientes  บฑฑ
ฑฑบ          ณ(conveniados) com o mesmo CPF                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณCRDXFUN                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDCLI04()

Local xRet        := .T.
Local _lConvenio  := Type("cCodConv")=="C" .AND. Type("cLojConv")=="C"
Local _aDados     := ParamIxb[1]
Local _cCPF       := ""

//Se o Caixa digitou o CPF, buscar o numero do cartao correspondente por ser chave unica
If Len(_aDados) > 0
	//Se for CPF, deve buscar o numero do cartao que eh chave unica
	If _aDados[1] == 3  //CPF
		_cCPF	:= PadR(_aDados[2],TamSX3("A1_CGC")[1])
		If _lConvenio
			xRet  := TPLTelaConv(_cCPF)
		EndIf
	ElseIf _aDados[1] == 1 .OR. _aDados[1] == 2    //Numero do cartao
		xRet := .T.    //Se for cartao, retorna .T. para continuar o processo
	EndIf
EndIf

Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDCLI05  บAutor  ณVendas Cliente      บ Data ณ  16/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no registro do SA1 para consulta dos cartoes do   บฑฑ
ฑฑบ          ณcliente.                                                    บฑฑ
ฑฑบ          ณCriado para o convenio, onde eh possivel ter dois clientes  บฑฑ
ฑฑบ          ณ(conveniados) com o mesmo CPF                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณWSCRD070                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDCLI05()

Local xRet        := .T.
Local _lConvenio  := Type("cCodConv")=="C" .AND. Type("cLojConv")=="C"
Local _aDados     := ParamIxb[1]
Local _cCPF       := ""

//Se o Caixa digitou o CPF, buscar o numero do cartao correspondente por ser chave unica
If Len(_aDados) > 0
	//Se for CPF, deve buscar o numero do cartao que eh chave unica
	If _aDados[1] == 3  //CPF
		_cCPF	:= PadR(_aDados[2],TamSX3("A1_CGC")[1])
		If _lConvenio
			xRet  := TPLTelaConv(_cCPF)
		EndIf
	ElseIf _aDados[1] == 1 .OR. _aDados[1] == 2    //Numero do cartao
		xRet := .T.    //Se for cartao, retorna .T. para continuar o processo
	EndIf
EndIf

Return (xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTPLVldCNPJบAutor  ณVendas Cliente      บ Data ณ  20/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida apenas o CNPJ para o cadastro de clientes บฑฑ
ฑฑบ          ณO CPF pode se repetir para os casos de conveniados          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณX3_VALID do campo A1_CGC                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TPLVldCNPJ(cPessoa)

Local _lRet  := .T.

//Validar se CNPJ jah foi cadastrado para pessoa juridica
If Empty(cPessoa) .OR. cPessoa == "J"
	_lRet  := ExistChav("SA1",M->A1_CGC,3,"A1_CGC")
EndIf

Return _lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTPLTelaConบAutor  ณVendas Cliente      บ Data ณ  20/12/04     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณTela para selecao do cliente quando encontra dois CPFs        บฑฑ
ฑฑบ          ณiguais para os casos de conveniados                           บฑฑ
ฑฑบ          ณChama WS para buscar o numero do cartao, que e chave unica    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณTPLDROPE                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TPLTelaConv( _cCPF )

Local cCodCli    := ""	// Codigo do cliente			
Local cLojCli    := ""	// Loja do cliente	
Local cSeekSA1   := ""	// Chave de busca
Local cWhileSA1  := ""	// Complemento da chave de busca
Local cRetCli    := ""	// Codigo do cliente para a chave de busca
Local aAreaSA1   := {}	// Area SA1
Local aRetCli	 := {}	// Escolha do cliente quando existe dois CFP's iguais
Local lCPFDuplic := .F.	// Controle se existem dois registros com o mesmo CPF no SA1 para os casos de convenio(particular e conveniado)
Local lRet       := .T.	// Controla se escolheu o botao OK ou Cancela
Local xRet 				// Retorno da funcao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis auxiliares para a criacao da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aCabCli	 := {}	
Local aLinCli    := {}	
Local aCpoCli    := {}
Local aTamCli    := {}

Private	oLbxCli
Private oDlgCli
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.

DbselectArea( "SA1" )
DbSetOrder( 3 )	// Filial + CPF
If !DbSeek( xFilial("SA1") + _cCPF )
	xRet  := { .T., "" }
	Return( xRet )
EndIf

cCodCli    := SA1->A1_COD
cLojCli    := SA1->A1_LOJA
cSeekSA1   := '"' + xFilial("SA1")+ _cCPF + '"'
cWhileSA1  := "!EOF() .AND. A1_FILIAL+A1_CGC==" + cSeekSA1
aAreaSA1   := SA1->(GetArea())
lCPFDuplic := .F.
DbselectArea("SA1")
DbSetOrder(3)
//Verifica se existe mais de um cliente com o mesmo CPF
While !Eof() .AND. SA1->A1_FILIAL+SA1->A1_CGC == xFilial("SA1")+_cCPF .AND. !lCPFDuplic
	
	If SA1->A1_COD+SA1->A1_LOJA == cCodCli+cLojCli
		DbSkip()
		Loop
	EndIf
	
	lCPFDuplic := .T.
End
SA1->(RestArea(aAreaSA1))
//Existe mais de um cliente com o mesmo CPF(particular e conveniado)
If lCPFDuplic
	DEFINE MSDIALOG oDlgCli TITLE STR0017 FROM 5,30 TO 25,100 //"Clientes"
	
	aRetCli	:= LocxGrid("SA1",cWhileSA1,,.T.,".F.",cSeekSA1,3,{"A1_NOME","A1_COD","A1_LOJA","A1_MATRICU"},)
	aCabCli	:= AClone(aRetCli[3])
	aLinCli	:= AClone(aRetCli[5])
	aTamCli	:= AClone(aRetCli[4])
	aCpoCli	:= AClone(aRetCli[1])
	
	oLbxCli := TwBrowse():New(011,000,000,000,,aCabCli,aTamCli,oDlgCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbxCli:nHeight	:= (__DlgHeight(oDlgCli)*2) - 8
	oLbxCli:nWidth		:= __DlgWidth(oDlgCli)*2
	oLbxCli:lColDrag	:= .T.
	oLbxCli:nFreeze	:= 1
	oLbxCli:SetArray(aLinCli)
	oLbxCli:bLine		:= LocxBLin('oLbxCli',aCpoCli,.T.)
	oLbxCli:bLDblClick	:={ || ChgMarkLb(oLbxCli,aLinCli,{|| .T. },.F.) }
	
	ACTIVATE MSDIALOG oDlgCli ON INIT EnchoiceBar(oDlgCli,{|| lRet := .T.,oDlgCli:End()},{|| lRet := .F.,oDlgCli:End()},,)
	If lRet
		aEval( aLinCli, { |x,y| If( aLinCli[y,1] == 1, cRetCli := (aLinCli[y,3]+aLinCli[y,4]), ) } )
		Posicione("SA1",1,xFilial("SA1")+cRetCli,"A1_COD+A1_LOJA")
		//Variaveis Private do programa FRTA010A, que armazena o codigo do cliente caso encontre duas ocorrencias de CPF no SA1
		//Somente atribui as variaveis se o CPF estiver duplicado
		
		cCodConv  := SA1->A1_COD
		cLojConv  := SA1->A1_LOJA
		xRet      := CRDXNumCart()	// Localizado no programa CRDXFUN
	EndIf
Else
	xRet := .T.  //Se o CPF nao estiver duplicado, busca pelo CPF mesmo
EndIf

Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCRDTCart  บAutor  ณVendas Cliente      บ Data ณ  23/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para selecao do tipo de identificacao do cliente.      บฑฑ
ฑฑบ          ณChamado da tela do Front Loja. Acrescenta a opcao de matri- บฑฑ
ฑฑบ          ณcula para conveniados                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณLOJA010T                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function CRDTCart()

Local  _oDlg
Local  _nOpcao  := 2
Public _nEscolha := 2

If SuperGetmv("MV_INTEEMS") .OR. CrdxInt()
	If Empty( LjGetStation("PINPAD") )
		DEFINE MSDIALOG _oDlg TITLE STR0030 FROM 13,21 TO 18,78 OF GetWNDDEFAULT() //"Tipo de Cartใo"
		@ 10,005 BUTTON STR0031		SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=2,_oDlg:End() ) //"Nใo Magn้tico"
		@ 10,060 BUTTON STR0032 	SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=3,_oDlg:End() ) //"CPF"
		@ 10,115 BUTTON STR0033 	SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=5,_oDlg:End() ) //"Matrอcula"
		@ 10,170 BUTTON STR0034 	SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=4,_oDlg:End() ) //"Abandona"
		ACTIVATE MSDIALOG _oDlg CENTERED
	Else
		DEFINE MSDIALOG _oDlg TITLE "Tipo de Cartใo" FROM 13,21 TO 18,92 OF GetWNDDEFAULT()	//"Tipo de Cartใo"
		@ 10,005 BUTTON STR0035 	SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=1,_oDlg:End() ) //"Magn้tico"
		@ 10,060 BUTTON STR0031		SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=2,_oDlg:End() ) //"Nใo Magn้tico"
		@ 10,115 BUTTON STR0032    	SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=3,_oDlg:End() ) //"CPF"
		@ 10,170 BUTTON STR0033	    SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=5,_oDlg:End() ) //"Matrอcula"
		@ 10,225 BUTTON STR0034		SIZE 50,15 OF _oDlg PIXEL ACTION ( _nOpcao:=4,_oDlg:End() ) //"Abandona"
		ACTIVATE MSDIALOG _oDlg CENTERED
	Endif
EndIf

_nEscolha := _nOpcao 

Return _nOpcao

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCRDOpcao  บAutor  ณVendas Cliente      บ Data ณ  23/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para entrada do numero de matricula para identi- บฑฑ
ฑฑบ          ณcacao do conveniado                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function CRDOpcao()

Local _aRetorno  	:= {}
Local _aRetNumCart	:= {}
Local _nOpcao    	:= ParamIxb[1]
Local _aVarTemplate := ParamIxb[4]
Local _nSel		 	:= 0
Local _cMatricula	:= Space(TamSX3("A1_MATRICU")[1])
Local _lConvenio 	:= ValType(_aVarTemplate[1])=='C' .AND. ValType(_aVarTemplate[2])=='C'
Local _oDlg

Private	_oLbxCli, _oDlgCli
Private	oOk     	:= LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     	:= LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  	:= LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark		:= .F.

If _nOpcao == 4  //Abandona
	_aRetorno := {4,'',Space(08)}
Elseif _nOpcao == 5   //Matricula
	_nSel := 2
	//Criacao do Ponto de Entrada p/ verificar se o imite de credito esta iguala a zero
	DEFINE MSDIALOG _oDlg TITLE STR0036 FROM 13,21 TO 20,64 OF GetWNDDEFAULT() //"Consulta do conveniado"
	@ 06,12 SAY		STR0037	SIZE 130,10 OF _oDlg PIXEL //"Matrํcula para consulta:"
	@ 06,88 MSGET	_cMatricula SIZE 055,10 OF _oDlg PIXEL PICTURE "@!" VALID !Empty(_cMatricula)
	
	DEFINE SBUTTON FROM 35,090 TYPE 1 PIXEL ACTION ( _nSel:=1,_oDlg:End() ) ENABLE OF _oDlg
	DEFINE SBUTTON FROM 35,120 TYPE 2 PIXEL ACTION ( _nSel:=2,_oDlg:End() ) ENABLE OF _oDlg
	
	ACTIVATE MSDIALOG _oDlg CENTERED
EndIf

_aRetorno := { _nOpcao, _cMatricula }

Return _aRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtExibeMsg บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mensagem referente a pontuacao do cliente para ser impresso  บฑฑ
ฑฑบ          ณ no CUPOM NAO FISCAL                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                            บฑฑ
ฑฑบChamada   ณ Template FrtEntreg()                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtExibeMsg()
Local aAreaAtu    := GetArea()
Local cMsg        := "" //mensagem do CUPOM FISCAL
Local cCodCli     := ""	//codigo do cliente
Local cCodLoja    := "" //codigo da loja
Local nPtsVend    := 0  //pontuacao obtida na venda

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DbselectArea("SL1")
If (ColumnPos("L1_PONTOS") > 0) .AND. (SL1->L1_PONTOS >= 0)
	cCodCli  := SL1->L1_CLIENTE
	cCodLoja :=	SL1->L1_LOJA
	nPtsVend := SL1->L1_PONTOS
	If ValType(nPtsA1) <> "N"//Significa que nao utilizou o WebService
		DbselectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+cCodCli+cCodLoja)
			nPtsA1 := SA1->A1_PONTOS
		Endif	
	Endif	

	nPtsTot := Str(nPtsA1 + nPtsVend)//pontuacao do cliente anterior a venda (MAIS) a pontuacao da venda corrente

	cMsg := STR0038+Chr(10) //"PONTUACAO"
	cMsg += STR0039+ AllTrim(Str(nPtsA1))+Chr(10) //"Pontuacao anterior: "
	cMsg += STR0040+ AllTrim(Str(nPtsVend))+Chr(10) //"Pontos nessa compra: "
	cMsg += STR0041+ AllTrim(nPtsTot)+Chr(10) //"Pontuacao a confirmar: "
	
	nPtsA1  := NIL
	
Else
	cMsg := Rtrim(SLG->LG_MSGCUP)
EndIf

// Restaura a area original
RestArea(aAreaAtu)

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFrtEntreg   บAutor  ณVendas Cliente      บ Data ณ  10/17/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para impressao da mensagem do               บฑฑ
ฑฑบ          ณ CUPOM NAO FISCAL.                                            บฑฑ
ฑฑบ          ณ Realiza a gravacao do historico das movimentacoes dos        บฑฑ
ฑฑบ          ณ Clientes.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                            บฑฑ
ฑฑบChamada   ณ Template FrtEntreg()                                         บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function FrtEntreg()
Local oSvc          
Local aAreaAtu     := GetArea()
Local lRet         := .T.
Local cSvcError    := ""
Local cSoapFCode   := ""
Local cSoapFDescr  := ""
Local lWsGrvPtos   := .T.
Local aAreaSL1     := {}
                   
Local cCodCli      := "" 					//Codigo do Cliente
Local cNomeCli     := "" 					//Nome do Cliente
Local cMatCli 	   := ""					//Matricula do Cliente
Local cEndereco    := "" 					//Endereco do Cliente
Local cCPF_CGC     := "" 					//CPF do Cliente
Local cRG          := "" 					//RG do Cliente
Local cFechaDia    := "" 					//Dia do Fechamento
Local cVencDia     := "" 					//Dia do Vencimento
Local cCodEmp	   := ""					//Codigo da EMPRESA em que o Cliente eh conveniado
Local cNomeEmp     := "" 					//Nome da EMPRESA em que o Cliente eh conveniado
Local cVlrTot	   := "" 					//Valor total da venda
Local cAss         := STR0042 				//vai no Rodape do CUPOPM ##"Assinatura do cliente"
Local nPtsTot      := 0  					//pontuacao anterior mais a pontuacao obtida na venda
Local nCentroNome  := 0  					//posiciona no centro do CUPOM p/ a impressao do nome do cliente
Local nCentroAss   := 20 - (Len(cAss)/2)   // centraliza o local onde o cliente devera assinar no CUPOM

Local cCondicao    := ""
Local cTexto       := ""
Local nTotVenda    := 0  					//valor Total da venda

Local cTexPontos   := ""
Local aDados	   := {}					//array com a opcao de escolha do cliente e a numeracao do cartao
Local lAtivo	   := .F. 					// variavel que ira validar se achou cartao ATIVO ou NAO

Local cNumCartVend := ParamIxb[1]			// Numero do cartao para qual foi realizada a VENDA  
Local cCodDep 	   := ParamIxb[2]			// Codigo do DEPENDENTE
Local cNomeDep     := ParamIxb[3]			// Nome do DEPENDENTE
Local nI 		   := 0						// Controle de loop
Local nVlrTot      := 0						// Valor do total das parcelas com forma de pagamento 'FI'
Local cForm		   := ""					// sigla da Forma de Pagamento
Local nParcelas    := 0						// numero de parcelas que sera realizada a venda - impresso no CUPOM NAO FISCAL
Local aPgto        := {}                   // Grava o array de pagamentos
Local cTotalizNFis := GetPvProfString("Totalizadores", "DROFRTENT", "01", GetClientDir()+"SIGALOJA.INI" )
// Se nao existir o SIGALOJA.INI mantem sempre o totalizador "01" como default porque temos um legado que sempre utilizou desta forma

If FunName() == "FRTA271"
	aPgto := aclone(ParamIxb[4]) 	
	
Else
	aPgto := aclone(aPgtos)	
Endif

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

If FunName() == "FRTA010"   //Front Loja
	nTotVenda  := nDinheiro + nCheques + nCartao + nFinanciado + nConvenio + nVales + nValorDebi + nOutros
ElseIf FunName() == "LOJA701" .AND. Len(aTotais) > 0   //Venda Assistida
	nTotVenda  := aTotais[4, 2]
EndIf

If ( nModulo == 12 ) 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ12 = SIGALOJA   ณ
	//ณ23 = FRONT- LOJAณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aDados := T_GetDadosCart()//Metodo que traz a opcao de escolha do cliente e a numeracao do cartao
	_nEscolha   := aDados[1]
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se a variavel _nEscolha estiver como NULA, forca seu valor para "3" para que o ณ
//ณ cartao do cliente (MA6) seja posicionado novamente.                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type( "_nEscolha" ) = "U"
	_nEscolha := 3
Endif

// Realiza grava็ใo do hist๓rico de movimenta็ใo.
If (SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
	If _nEscolha = 3 .OR. _nEscolha = 5 // Escolha do cliente pelo CPF ou Numero de Matricula
		Posicione("MA6",2,xFilial("MA6")+SL1->L1_CLIENTE+SL1->L1_LOJA,"MA6_CODCLI+MA6_LOJA")
	   	While (!lAtivo .AND. SL1->L1_CLIENTE+SL1->L1_LOJA = MA6->MA6_CODCLI+MA6->MA6_LOJA ;
	   	      .AND. Empty(MA6->MA6_CODDEP))
		   	If  MA6->MA6_SITUA = "1"
			   	lAtivo := .T.
			Else
				MA6->(DbSkip())   	
		   	Endif   	
	   	End
	Endif
	DbselectArea("LHG")
	RecLock("LHG",.T.)
	LHG->LHG_FILIAL := xFilial("LHG")
	LHG->LHG_CODIGO := SL1->L1_CLIENTE
	LHG->LHG_LOJA   := SL1->L1_LOJA
	LHG->LHG_NOME   := Posicione("SA1",1,xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME")
	LHG->LHG_CARTAO := Posicione("MA6",2,xFilial("MA6")+SL1->L1_CLIENTE+SL1->L1_LOJA,"MA6_NUM")
	LHG->LHG_DATA   := SL1->L1_EMISSAO
	LHG->LHG_CUPFIS := SL1->L1_DOC
	LHG->LHG_SERIE  := SL1->L1_SERIE
	LHG->LHG_PONTOS := SL1->L1_PONTOS
	LHG->LHG_TIPMOV := "C"
	LHG->LHG_PDV    := SL1->L1_PDV
	LHG->LHG_SITUA  := "00"
	LHG->LHG_DTVALI := dDataBase + SuperGetmv("MV_VALPTOS",,90)
	LHG->LHG_HORA   := SL1->L1_HORA
	LHG->LHG_CODPLN := Posicione("MHG",3,xFilial("MHG")+SL1->L1_CPLFIDE,"MHG_CODIGO")//SL1->L1_CPLFIDE = Cod. Regra
	LHG->LHG_DESCPL := Posicione("MHG",1,xFilial("MHG")+LHG_CODPLN,"MHG_NOME")
       
	If !Empty(cCodDep) .AND. !Empty(cNomeDep)	//Verifica se a Venda foi feita para um DEPENDENTE
		LHG->LHG_CARDEP := cNumCartVend			//Numero do cartao do Dependente
		LHG->LHG_CODDEP := cCodDep	   			//Codigo do Dependente
		LHG->LHG_NOMDEP := cNomeDep				//Nome do Dependente		
	Else
		LHG->LHG_CARDEP := ""
		LHG->LHG_CODDEP := ""
		LHG->LHG_NOMDEP := ""
	Endif
	LHG->(MsUnLock())

	DbselectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
		cCodCli   	:= SA1->A1_COD
		cLojaCli  	:= SA1->A1_LOJA
		cNomeCli  	:= SA1->A1_NOME     //atribui o nome do cliente numa variavel
		cMatCli   	:= SA1->A1_MATRICU  //atribui a matricula do cliente numa variavel
		cEndereco 	:= SA1->A1_END      //atribui o endereco do cliente numa variavel
		cCPF_CGC  	:= SA1->A1_CGC      //atribui o CPF do cliente numa variavel
		cRG		  	:= SA1->A1_PFISICA  //atribui o RG do cliente numa variavel
		cFechaDia 	:= Posicione("LFX",1,xFilial("LFX")+SA1->A1_CONFIG,"LFX_FECH")//dia do Fechamento
		cVencDia  	:= Posicione("LFX",1,xFilial("LFX")+SA1->A1_CONFIG,"LFX_PAGTO")//dia do Vencimento
		nCentroNome	:= 20 - (Len(AllTrim(cNomeCli))/2)// centraliza o nome do Ciente na impressao do CUPOM

		If SA1->A1_TPCONVE = "3"//verificar se o cliente eh do tipo conveniado
			aAreaSA1  := SA1->(GetArea())
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+SA1->A1_EMPCONV + SA1->A1_LOJCONV))
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณFaz a somatoria das parcelas cuja a forma de pagamento igual a 'FI'     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nI := 1 to Len(aPgto) 
					If aPgto[nI][3] = FORMPAG	//Essa mensagem so sera exibida caso a Forma de Pagamento for do tipo FI - FINANCIADO
						cForm     := aPgto[nI][3]
						nVlrTot   += aPgto[nI][2]    
						nParcelas ++
				    Endif
				Next nI	
				If nVlrTot > 0
					cCodEmp  := SA1->A1_COD //atribui o Codigo da empresa em que o cliente eh conveniado.
					cNomeEmp := SA1->A1_NOME//atribui o Nome da empresa em que o cliente eh conveniado.
						
					cVlrTot := TransForm(nVlrTot,PesqPict("SL1","L1_VLRTOT"))//valor total da venda
					
					cTexto := STR0055+Alltrim(cFechaDia)+STR0056 + STR0057+Alltrim(cVencDia)+")" +Chr(10) //"Vencimentos: Fecha dia(" ## ")" ## "Vence dia("
					cTexto += AllTrim(cVlrTot)+Chr(10)
					
					cTexto += STR0058+Chr(10) //"Cliente: "
					cTexto += STR0059+AllTrim(cCodCli)+STR0060 + AllTrim(cNomeCli)+Chr(10) //"(" ## ")  "
					cTexto += STR0059+AllTrim(cCodEmp)+STR0060 + AllTrim(cNomeEmp)  + STR0070+AllTrim(cMatCli) +Chr(10) //"(" ## "  ID: "
					cTexto += STR0061+AllTrim(cEndereco)+Chr(10) //"Ender.  : "
					cTexto += STR0062+AllTrim(cCPF_CGC)+Chr(10)  //"CPF ....: "
					cTexto += STR0063+AllTrim(cRG)+Chr(10)       //"RG .....: "
					
					cTexto += STR0064+AllTrim(cNumCartVend)+Chr(10) //"CARTAO NO. "
					
					cTexto += +Chr(10)+STR0065+Space(2)+Replicate("-",30)+Chr(10) //"Ass."
					cTexto += STR0066+Chr(10)//"   AUTORIZO O DESCONTO EM FOLHA DE"
					cTexto += STR0067+Chr(10)//"     PAGAMENTO DA DIVIDA ACIMA."
					//Verifica se a Venda foi feita para um DEPENDENTE
					If !Empty(cCodDep) .AND. !Empty(cNomeDep) // variaveis criadas no programa FRTA010A.prw
						cTexto += STR0068+Chr(10) //"OBS: Compra realizada pelo DEPENDENTE"
						cTexto += STR0069+cNomeDep+Chr(10) //"     "
					Endif
				Endif	
			Endif
			RestArea(aAreaSA1)
		Elseif SA1->A1_TPCONVE = "1"         //verificar se o cliente eh do tipo Normal
			aAreaSA1  := SA1->(GetArea())
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณFaz a somatoria das parcelas cuja a forma de pagamento igual a 'FI'     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					For nI := 1 to Len(aPgto) 
						If aPgto[nI][3] = FORMPAG	//Essa mensagem so sera exibida caso a Forma de Pagamento for do tipo FI - FINANCIADO
							cForm   := aPgto[nI][3]						
							nVlrTot += aPgto[nI][2]
							nParcelas ++							
					    Endif	
					Next nI	
					
					If nVlrTot > 0
						cVlrTot := TransForm(nVlrTot,PesqPict("SL1","L1_VLRTOT"))//valor total da venda
					
						cTexto := STR0055+Alltrim(cFechaDia)+STR0056 + STR0057+Alltrim(cVencDia)+")" +Chr(10) //"Vencimentos: Fecha dia(" ## ")" ## "Vence dia("
						cTexto += AllTrim(cVlrTot)+Chr(10)
						
						cTexto += STR0058+Chr(10) //"Cliente: "
						cTexto += STR0059+AllTrim(cCodCli)+STR0060 + AllTrim(cNomeCli)+Chr(10) //"(" ## ")  "
						cTexto += STR0061+AllTrim(cEndereco)+Chr(10) //"Ender.  : "
						cTexto += STR0062+AllTrim(cCPF_CGC)+Chr(10)  //"CPF ....: "
						cTexto += STR0063+AllTrim(cRG)+Chr(10)       //"RG .....: "
						
						cTexto += STR0064+AllTrim(cNumCartVend)+Chr(10) //"CARTAO NO. "

				cTexto += +Chr(10)+STR0065+Space(2)+Replicate("-",30)+Chr(10) //"Ass."
				cTexto += STR0071+Chr(10) //"   RECONHECO  E PAGAREI A DIVIDA "
				cTexto += STR0072+Chr(10)+Chr(10) //"         AQUI APRESENTADA   "
				
				//Verifica se a Venda foi feita para um DEPENDENTE
				If !Empty(cCodDep) .AND. !Empty(cNomeDep) // variaveis criadas no programa FRTA010A.prw
					cTexto += STR0068+Chr(10) //"OBS: Compra realizada pelo DEPENDENTE"
					cTexto += STR0069+cNomeDep+Chr(10) //"     "
				Endif
			Endif	
			RestArea(aAreaSA1)			
		Endif
	Endif
	
	VarInfo("Mensagem do Cupom",cTexto)
	
	If !Empty(cTexto)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Pega a condicao cadastrada na tabela 24 do SX5 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Antes de subir este fonte devera' ser feito o trtatamento de todas as ณ
		//ณ formas de pagamento e nao apenas da forma posicionada (oPgtos:nAt),   ณ
		//ณ senao o usuario nao podera' finalizar a venda com mais de 1 forma de  ณ
		//ณ pagamento, como fazer a compra financiada, mas pagar a entrada em     ณ
		//ณ R$                                                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SX5->( DbSetOrder( 1 ) )
		If SX5->( DbSeek( xFilial("SX5") + "24" + cForm ) )
			cCondicao := X5Descri()
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ So' imprime o Cupom Nao-Fiscal caso a somatoriaณ
		//ณ das parcelas cuja forma de pagamento do tipo   ณ
		//ณ 'FI' seja maior que zero.                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		If nVlrTot > 0
			cVlrTot := StrTran(cVlrTot,".","") 	// Remover os pontos da casa da milhar, pois como tem o PesqPicture vem 1.234,56
			cVlrTot := StrTran(cVlrTot,",",".") // Nao manda a virgula para a impressora, pois senao ela pensa que eh parametro
			
			LJGrvLog(Nil, "Indice do totalizador Nao-Fiscal utilizado", cTotalizNFis)
			
			//Abre a chamada do cupom nao fiscal		
			IFAbrCNFis( nHdlEcf, cCondicao, cVlrTot, cTotalizNFis, "", nParcelas )

			//Imprime o texto do cupom nao fiscal e o numero de vias
			LjMsgRun(STR0073,, {|| IFTxtNFis( nHdlEcf, cTexto, 1 )})	// "... Agurade, imprimindo o CUPOM NรO-FISCAL ..."			
			//Fecha a chamada do cupom nao fiscal
			IFFchCNFis( nHdlEcf )
		Endif	
				
	EndIf
			
EndIf

RestArea(aAreaAtu)

// Reinicializa variแveis 'static' para a pr๓xima venda.
nTotPontos   	:= Nil
cCodRegra    	:= Nil
lPesqDescGer 	:= Nil
lCupAberto   	:= .F.
lJaChamouANVISA := .F.
                   

//Atualiza o numero do documento fiscal l1_doc

If ExistFunc("T_DroDocAnvisa")
	T_DroDocAnvisa(SL1->L1_DOC, SL1->L1_SERIE)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDepois de impresso o cupom, chama a funcaoณ
//ณpara a gravacao na tabela Logs ANVISA     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
T_DroGrvANVISA()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROPesqConบAutor  ณVendas Cliente      บ Data ณ  23/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se ha algum registro no SA1 com a matricula infor- บฑฑ
ฑฑบ          ณmada                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณTPLDROPE                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function DROPesqConv(_cMatricula)

Local _lRet  := .T.

If SuperGetMv("MV_PLSATIV",.F.,.F.)
	_lRet := T_PLSTMatr(@_cMatricula)[1]
Else
DbselectArea("SA1")
//DbSetOrder(8)
DbOrderNickName("SA1DRO1")//indice criado p/ o Template de Drogaria
_lRet  := DbSeek(xFilial("SA1")+_cMatricula)
If !_lRet
	MsgAlert(STR0074) //"Matrํcula nใo encontrada!"
	EndIf
EndIf

Return (_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDBloqDepบAutor  ณVendas Cliente      บ Data ณ  04/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtiva/Desativa o cartao do dependente no MAC quando atualizaบฑฑ
ฑฑบ          ณo status do cartao no MA6                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณX3_VALID do campo MA6_SITUA                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function CRDBloqDep()

Local _nPosCodDep  := Ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CODDEP"})
Local _nPosCartao  := Ascan(aHeader5,{|x| Trim(x[2]) == "MAC_CARTAO"}) //1=Sim;2=Nao;3=Inativo
Local _nPosSitua   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_SITUA"})  //1=Ativo;2=Bloqueado;3=Cancelado
Local _nPosDepCart := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_CODDEP"})
Local _nX

If _nPosDepCart > 0 .AND. _nPosCartao > 0 .AND. _nPosSitua > 0 .AND. _nPosCodDep > 0
	_cCodDep  := oGetD6:aCols[n][_nPosDepCart]
	_cCodCli  := M->A1_COD
	_cLoja    := M->A1_LOJA
	lFound    := .F.
	If !Empty(_cCodDep)
		For _nX := 1 to Len(oGetD5:aCols)
			If oGetD5:aCols[_nX][Len(oGetD5:aCols[_nX])]
				Loop
			EndIf
			If oGetD6:aCols[n][_nPosDepCart] == oGetD5:aCols[_nX][_nPosCodDep]
				lFound  := .T.
				Exit
			EndIf
		Next _nX
		If lFound
			If M->MA6_SITUA $ "2|3"  //Bloqueado,Cancelado
				oGetD5:aCols[_nX][_nPosCartao]  := "3"  //Inativo
				oGetD5:Refresh()
			ElseIf M->MA6_SITUA == "1"   //Ativo
				oGetD5:aCols[_nX][_nPosCartao]  := "1"  //Sim
				oGetD5:Refresh()
			EndIf
		EndIf
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDROVldCondบAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar se a condicao de pagamento digitada pertence ao pla-บฑฑ
ฑฑบ          ณno de fidelidade do conveniado                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณX3_VLDUSER do campo LQ_CONDPG                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DROVldCond(_cCondPg)

Local _lRet    := .T.
Local _aArea   := GetArea()
Local _aConds  := {}  //Array que armazena as condicoes de pagamento validas para o cliente
Local _cDescPlano  := ""

If !Empty(_cCondPg) .AND. !Empty(M->LQ_CPLFIDE)
	_cDescPlano  := Posicione("MHG",1,xFilial("MHG")+M->LQ_CPLFIDE,"MHG_NOME")
	//Condicoes de pagamento do plano de fidelidade
	LHF->(DbSetOrder(1))
	If LHF->(DbSeek(xFilial("LHF")+M->LQ_CPLFIDE))
		While !LHF->(Eof()) .AND. xFilial("LHF")+M->LQ_CPLFIDE == LHF->LHF_FILIAL+LHF->LHF_CODIGO
			If Ascan(_aConds,LHF->LHF_CONDIC) == 0
				Aadd(_aConds,LHF->LHF_CONDIC)
			EndIf
			
			LHF->(DbSkip())
		End
	EndIf
	If Len(_aConds) > 0
		_lRet  := Ascan(_aConds,_cCondPg) > 0
		If !_lRet
			MsgAlert(STR0075+_cDescPlano) //"A condi็ใo de pagamento selecionada nใo pertence ao plano de fidelidade "
		EndIf
	EndIf
EndIf

RestArea(_aArea)

Return _lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณGQREENTR()บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao DroEntANVISA() grava as informacoes do medicamentos  บฑฑ
ฑฑบ          ณcontrolados na tabela LK9 apos a confirmacao do documento deบฑฑ
ฑฑบ          ณentrada                                                     บฑฑ
ฑฑบ          ณFuncao DroPCusto() grava as informacoes referentes a menos eบฑฑ
ฑฑบ          ณmaior custo do produto apos a confirmacao do documento de   บฑฑ
ฑฑบ          ณentrada. Essas informacoes serao apresentadas na tela       บฑฑ
ฑฑบ          ณpre-pedido de compras na rotina de Cenral de Compras		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao da NF Entrada(MATA103)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function GQREENTR()

If HasTemplate("DRO")
	/*Grava informacoes referentes a medicamentos controlados*/
	T_DroEntANVISA(.F.)
	/*Grava informacoes do produto para pre-pedido de compras*/
	//T_DroPCusto()
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMT100GRV  บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecutado somente quando e' exculsao de algum documento de  บฑฑ
ฑฑบ          ณentrada                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao da NF Entrada(MATA103)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT100GRV()
Local lDeleta := ParamIxb[1]

If HasTemplate("DRO")
	If lDeleta
		T_DroEntANVISA( .T. )
	Endif
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCRD010PG  บAutor  ณVendas Cliente 	 บ Data ณ  03/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para atualizar o cadastro de Cartoes		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณApos a gravacao do Cliente                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/     
Template Function CRD010PG()
Local _cCodCli := ""
Local _cLojCli := ""
Local _aArea   := GetArea()
Local _nOpcao  := ParamIxb[1]
Local lFuncao  := .T.

If HasTemplate("DRO")
	_cCodCli := SA1->A1_COD
	_cLojCli := SA1->A1_LOJA
	
	If _nOpcao == 3 //Inclusao	
		T_DroGerTit(_cCodCli,_cLojCli)
	Endif
	
	If _nOpcao == 4  //Alteracao 
		DbselectArea("LIO")
		LIO->(DbSetOrder(1))
		DbselectArea("MA6")
		MA6->(DbSetOrder(2))
		
		If (_cCodCli+_cLojCli <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
			MA6->(DbSeek(xFilial("MA6")+_cCodCli+_cLojCli))
	        If  ((SA1->A1_TPCONVE = "1" .OR. SA1->A1_TPCONVE = "3") .AND. Empty(MA6->MA6_NUM) .AND. MA6->MA6_SITUA <> "3" )
				//chama a funcao para a geracao de numero de cartoes
				T_DroGerTit(_cCodCli,_cLojCli)
			Else
				While !Eof() .AND. xFilial("MA6")+_cCodCli+_cLojCli == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA
					If !Empty(MA6->MA6_NUM)					      // for diferente de Cancelado
						If LIO->(DbSeek(xFilial("LIO") + MA6->MA6_NUM))
							RecLock("LIO",.F.)
							LIO_STATUS := MA6->MA6_SITUA
							LIO->(MsUnLock())
						Endif
					Endif
					
					MA6->(DbSkip())
					Loop
					lFuncao := .F.
					If !lFuncao
						// depois de atribuir um numero de cartao para um determinado cliente
						// eh atualizado no cadastro de cartoes CODIGO DO CLIENTE, LOJA DO CLIENTE e CODIGO DO DEPENDENTE
						If LIO->(DbSeek(xFilial("LIO") + MA6->MA6_NUM))
							RecLock("LIO",.F.)
							LIO_CODCLI := _cCodCli
							LIO_LOJCLI := _cLojCli
							LIO_CODDEP := MA6->MA6_CODDEP
							LIO_STATUS := MA6->MA6_SITUA
							LIO->(MsUnLock())
							//Gera um cartao no LIO se o usuario gerou um novo numero para cartao cancelado por perda/furto ou desligamento da empresa
							//Esta geracao de cartao se dah atraves do botao de customizacao da EnchoiceBar
						Else
							RecLock("LIO",.T.)
							LIO->LIO_FILIAL := xFilial("LIO")
							LIO->LIO_CARTAO := MA6->MA6_NUM
							LIO->LIO_CODCLI := _cCodCli
							LIO->LIO_LOJCLI := _cLojCli
							LIO->LIO_CODDEP := MA6->MA6_CODDEP
							LIO->LIO_STATUS := MA6->MA6_SITUA
							LIO->(MsUnLock())
						Endif
					Endif
					MA6->(dbskip())
				End
			Endif
		Endif
	EndIf
	
	RestArea(_aArea)
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDroGerTit บAutor  ณVendas Cliente      บ Data ณ  10/13/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que cria o numero de cartao para Titulares           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ- Eh chamada apos a confirmacao do cliente.                 บฑฑ
ฑฑบ          ณ (Ponto de entrada CRD010PG)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DroGerTit( _cCodCli  , _cLojCli , lWizard  , lMA6     ,;
							  aConvCart, lProcCart, lNovoConv, nQtdeINC ) 
							  
Local cAliasSX5	   := "IL"//alias referente a Filiais Microsiga x Drogaria	 
Local cCodFil 	   := ""//
Local cNomeFil	   := ""
Local cLojDrogaria := "" 
Local cACFarma     := SuperGetmv("MV_ACFARMA")//parametro onde esta indicado o codigo ACFARMA
Local cUltCod	   := ""	
Local cNovoCod     := ""
Local cDigVerif    := ""
Local cAleatorio   := ""
Local cCartao	   := ""	
Local cNomeCli     := ""
Local lFirst 	   := .T.
Local lRet		   := .T. 
Local lMA6Situa	   := .F.	// Verifica se o campo MA6_SITUA esta' diferente de 3, CANCELADO.
Local aRet			:= {}
Local nIndMA6		:= 0

DEFAULT lWizard    := .F.
DEFAULT lMA6	   := .F.
DEFAULT aConvCart  := {}
DEFAULT lProcCart  := .F.
DEFAULT lNovoConv  := .F.

//verifica se eh cliente padrao
If ( _cCodCli + _cLojCli <> SuperGetmv("MV_CLIPAD") + SuperGetmv("MV_LOJAPAD") )
    If lWizard
       DbselectArea("SA1")
       SA1->(DbSetOrder(1))
       SA1->(DbSeek(xFilial("SA1") + _cCodCli + _cLojCli))
       lMA6Situa := .T.
    Else
       lMA6Situa := MA6->MA6_SITUA <> "3"
    Endif
       
	If ((SA1->A1_TPCONVE = "1" .OR. SA1->A1_TPCONVE = "3") .AND. lMA6Situa )
		SM0->(DbSeek(cEmpAnt))
		cCodFil  := SM0->M0_CODFIL
		cNomeFil := SM0->M0_FILIAL
		
		If SX5->(DbSeek(xFilial("SX5") + cAliasSX5 + cCodFil))//verifica se existe o Codigo da Filial dentro da tabela "IL" no SX5
			If !Empty(X5DESCRI())// verifica se a Descricao da Filial nao esta em branco
				cLojDrogaria := Alltrim(X5DESCRI())
			Else
				MsgAlert('Filial '+cNomeFil+'esta sem descricao na tabela X5.' )	
				lRet  := .F.
			Endif	
		Else
			MsgAlert('A Filial '+Alltrim(cNomeFil)+' nao esta configurado na tebela X5.')	
			lRet  := .F.	
		Endif 
		If lRet
			//Montando o numero do cartao
			DbselectArea("LIO")
			LIO->(DbSetOrder(1))
			
			BEGIN TRANSACTION   		
				lFirst := .T.
				If lFirst
					LIO->(DbSeek(xFilial("LIO")+cACFarma+cLojDrogaria+"ZZZZZZ",.T.))
					LIO->(DbSkip(-1))
					If Substr(LIO->LIO_CARTAO,1,3) == cACFarma .AND. cLojDrogaria == Substr(LIO->LIO_CARTAO,4,3) //Comparar se o Parametro permanece o mesmo
						cUltCod  := Substr(LIO->LIO_CARTAO,7,6)
					Else
						cUltCod  := "000000"
					Endif
					
					lFirst := .F.
					
					cNovoCod  := StrZero(Val(cUltCod)+1,6)
					cDigVerif := StrZero(Randomize(1,98),2)

					cCartao   := cACFarma+cLojDrogaria+cNovoCod+"01"+cDigVerif
					cUltCod   := cNovoCod 
				    
					//Verifica se o numero gerado jah existe na base de dados
					LIO->(DbSeek(xFilial("LIO")+cCartao))
					
					//Enquanto encontrar o numero do cartao gerado, executa o random
					While !LIO->(Eof()) .AND. LIO->(DbSeek(xFilial("LIO")+cCartao))
						cAleatorio  := StrZero(Randomize(1,98),2)
						cCartao     := Substr(cCartao,1,14)+cAleatorio		
						LIO->(DbSkip())
					End
					
				    cNomeCli := Posicione("SA1",1,xFilial("SA1")+_cCodCli+_cLojCli,"A1_NOME")
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica swe a rotina esta' sendo chamada pelo processo de importacao de conveniados ณ
					//ณlWizard = .T.                                                                        ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lWizard
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณlProcCart = .T. -> significa que o fleque para a geracao de      ณ
						//ณ                   cartoes esta' marcada.                        ณ
						//ณlNovoConv = .T. -> significa que o registro que esta' sendo      ณ
						//ณ                   processado e' uma INCLUSAO                    ณ
						//ณlMA6 = .T. -> significa que ja existe o registro do MA6 na       ณ
						//ณ                     base criado atraves da rotina de Importacao ณ
						//ณ                     de Conveniados                              ณ
						//ณlMA6 = .F. -> significa que nao existe o registro do MA6 na      ณ
						//ณ                     base.                                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If lProcCart .AND. lNovoConv
							DbselectArea("MA6")
							
							If lMA6
								RecLock("MA6",.F.)
							Else
								RecLock("MA6",.T.)
							Endif
							MA6->MA6_FILIAL  := xFilial("MA6")
							MA6->MA6_CODCLI  := _cCodCli
							MA6->MA6_LOJA 	 := _cLojCli
							MA6->MA6_DTEVE   := dDatabase
							MA6->MA6_MOTIVO  := "1"
							MA6->MA6_SITUA   := "2"
							MA6->MA6_NUM     := cCartao
							MA6->(MsUnLock())
							
							RecLock("LIO",.T.)
							LIO->LIO_FILIAL := xFilial("LIO")
							LIO->LIO_CARTAO := MA6->MA6_NUM
							LIO->LIO_CODCLI := _cCodCli
							LIO->LIO_LOJCLI := _cLojCli
							LIO->LIO_CODDEP := MA6->MA6_CODDEP
							LIO->LIO_STATUS := MA6->MA6_SITUA
							LIO->(MsUnLock())						
						Endif
					Else	
						If MsgYesNo(STR0076+Chr(10)+; 
									STR0077+cCartao+Chr(10)+;
									STR0078+Chr(10)+;
									cNomeCli) //"Confirma a gera็ใo do cartใo n๚mero" ## " " ## " para o cliente"
							
							DbselectArea("MA6")
							nIndMA6 := MA6->(IndexOrd()) //Guarda o indice atual 
							
					        MA6->(DbSetOrder(2))
					        If MA6->(DbSeek(xFilial("MA6") + _cCodCli + _cLojCli))
								RecLock("MA6",.F.)
							Else
								RecLock("MA6",.T.)	
					        Endif
							MA6->MA6_FILIAL  := xFilial("MA6")
							MA6->MA6_CODCLI  := _cCodCli
							MA6->MA6_LOJA 	 := _cLojCli
							MA6->MA6_DTEVE   := dDatabase
							MA6->MA6_MOTIVO  := "1"
							MA6->MA6_SITUA   := "2"
							MA6->MA6_NUM     := cCartao
							MA6->(MsUnLock())
							
							RecLock("LIO",.T.)
							LIO->LIO_FILIAL := xFilial("LIO")
							LIO->LIO_CARTAO := MA6->MA6_NUM
							LIO->LIO_CODCLI := _cCodCli
							LIO->LIO_LOJCLI := _cLojCli
							LIO->LIO_CODDEP := MA6->MA6_CODDEP
							LIO->LIO_STATUS := MA6->MA6_SITUA
							LIO->(MsUnLock())
							
							MA6->(DbSetOrder(nIndMA6)) //Retorna o indice da MA6
						Endif
					Endif						
				EndIf
			END TRANSACTION
		Endif
		
		If lWizard
			/* Atualiza o contador de clientes que 
			  estao sendo ALTERADOS ou INCLUIDOS na base */
			If !lNovoConv
				nQtdeALT ++
			Else
				nQtdeINC ++	
			Endif
			If lProcCart
				aAdd(aConvCart,{_cCodCli, _cLojCli, cNomeCli, cCartao, Iif(lNovoConv, "INCLUSรO","ALTERAวรO") })
			Else
				aAdd(aConvCart,{_cCodCli, _cLojCli, cNomeCli, "", Iif(lNovoConv, "INCLUSรO","ALTERAวรO") })					
			Endif
		Endif	
	Endif	
Endif

If lWizard
	aRet := aConvCart
Else
	aRet := NIL
Endif

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCRDCRIABUTบAutor  ณVendas Cliente      บ Data ณ  10/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para gerar novo numero de cartao quando    บฑฑ
ฑฑบ          ณcartao cancelado                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณEnchoiceBar do cadastro de clientes do CRD(CRDA010)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function CRDCRIABUT() 
Local _aButtons   := {}

If HasTemplate("DRO") 
	_aButtons   := ParamIxb[1]
	AAdd(_aButtons, {"AUTOM"  , {|| DRONewCart()} , STR0079 }) //"Novo cartใo"
EndIf

Return _aButtons

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDRONewCartบAutor  ณVendas Cliente      บ Data ณ  10/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada para gerar novo numero de cartao quando    บฑฑ
ฑฑบ          ณcartao cancelado                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณEnchoiceBar do cadastro de clientes do CRD(CRDA010)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DRONewCart()
Local _aColsCart   := AClone(oGetD6:aCols)
Local _aArea       := GetArea()
Local _nPosDtEnv   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_DTENV"})
Local _nPosDtEve   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_DTEVE"})
Local _nPosDep     := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_CODDEP"})
Local _nPosNum     := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_NUM"})
Local _nPosSitua   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_SITUA"})
Local _nPosMotivo  := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_MOTIVO"})
Local _nPosDtRec   := Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_DTREC"})
Local _nPosTmp     := 0 			// posicao de campos de usuario
Local _nX	       := 0 
Local _nLin        := oGetD6:nAT
Local _nNovaLinha  := 0
Local _nQtdCols    := 0
Local _cCartaoOld  := ""
Local _cCartaoNew  := ""
Local _cAleatorio  := ""
Local _cMensagem   := ""
Local _aCamposUsr  := {}    // tratamento de campos de usuario 
Local _cCodDep     := ""
Local _lTitular    := .F.   //Indica se o cartao deve ser gerado para o titular
Local cText 	   := STR0080+ CTRL + CTRL + ;
					  STR0081 //'Nใo ้ possํvel gerar um novo n๚mero de cartใo, pois o n๚mero atual nใo estแ preenchido.' ## 'Favor verificar.'
Local _lPodeIncluir := .T.  // Verifica se pode incluir um novo cartao

_cCodDep     := AllTrim(_aColsCart[_nLin][_nPosDep])
_lTitular    := Empty(_cCodDep)

If _nLin > 0 .AND. _nLin <= Len(_aColsCart)
	If Empty(_aColsCart[_nLin][_nPosNum])
		MsgAlert(cText)
		Return
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se existe algum cartao bloqueado ou ativo. Se existir, nao deixa ณ
	//ณ criar um novo cartao. Verifica so' as linhas que nao estao deletadas.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_lPodeIncluir := .T.
	For _nX := 1 to Len( _aColsCart )
		If !(_aColsCart[_nX][Len( _aColsCart[_nX] )])
		
				If Alltrim(_aColsCart[_nX][_nPosDep]) == Alltrim(_cCodDep) .AND. Alltrim( _aColsCart[_nX][_nPosSitua] ) $ "1|2"
					_lPodeIncluir := .F.
				Endif		
			
		Endif
	Next _nX
	
	//Permitir gerar cartao apenas para Cancelado por motivo de perda/furto ou desligamento da empresa
	//If _aColsCart[_nLin][_nPosSitua] == "3" .AND. _aColsCart[_nLin][_nPosMotivo] $ "2|4"
	If _lPodeIncluir
		_cCartaoOld  := _aColsCart[_nLin][_nPosNum]
		_cAleatorio  := StrZero(Randomize(1,98),2)
		_cCartaoNew  := Substr(_cCartaoOld,1,14)+_cAleatorio
		//Verifica se o numero gerado jah existe na base de dados
		DbselectArea("MA6")
		DbSetOrder(1)
		DbSeek(xFilial("MA6")+_cCartaoNew)
		//Enquanto encontrar o numero do cartao gerado, executa o random
		While !Eof() .AND. DbSeek(xFilial("MA6")+_cCartaoNew)
			_cAleatorio  := StrZero(Randomize(1,98),2)
			_cCartaoNew  := Substr(_cCartaoOld,1,14)+_cAleatorio
			
			DbSkip()
		End
		_cMensagem  := STR0082+_cCartaoNew //"Confirma a gera็ใo do cartใo n๚mero "
		_cMensagem  += IIf(_lTitular,STR0083,STR0084+_cCodDep+STR0085) //" para o titular?" ## " para o dependente " ## "?"
		If MsgYesNo(_cMensagem)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณA gravacao do novo cartao eh feita pela funcao A610GravaCol chamada do CRDA010ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			_nQtdCols   := Len(oGetD6:aCols[Len(oGetD6:aCols)])
			Aadd(oGetD6:aCols,Array(_nQtdCols))
			_nNovaLinha := Len(oGetD6:aCols)
			oGetD6:aCols[_nNovaLinha][_nPosDtEve] := dDatabase
			oGetD6:aCols[_nNovaLinha][_nPosDep]   := _cCodDep
			oGetD6:aCols[_nNovaLinha][_nPosNum]   := _cCartaoNew
			oGetD6:aCols[_nNovaLinha][_nPosSitua] := "2"      //Bloqueado
			oGetD6:aCols[_nNovaLinha][_nPosMotivo]:= "1"      //Cartao Novo
			oGetD6:aCols[_nNovaLinha][_nPosDtEnv] := Ctod("  /  /    ")
			oGetD6:aCols[_nNovaLinha][_nQtdCols]  := .F.
			If _nPosDtRec > 0  // Campo incluido para ser inicializado como protecao vide txt no TFS
				oGetD6:aCols[_nNovaLinha][_nPosDtRec] := Ctod("  /  /    ")
			EndIf	
			oGetD6:Refresh()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Faz o tratamento de campos de usuario                                        ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			SX3->( DbSetOrder(1) )
			SX3->( DbSeek( "MA6" ) )
			While !(SX3->( Eof() )) .AND. SX3->X3_ARQUIVO == "MA6"
				If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_PROPRI == "U"
					aAdd( _aCamposUsr, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
			    Endif 
				SX3->( dbSkip() )
			End
			
			If !Empty( _aCamposUsr )
			
				For _nX := 1 To Len( _aCamposUsr )
				
					_nPosTmp := Ascan(aHeader6,{|x| Upper( Trim( x[2] ) ) == Upper( Trim( _aCamposUsr[_nX][1] ) ) } )
					If _nPosTmp > 0
					    
					    If _aCamposUsr[_nX][2] == "C"
						    oGetD6:aCols[_nNovaLinha][_nPosTmp]  := Space(_aCamposUsr[_nX][3])
						ElseIf _aCamposUsr[_nX][2] == "N"
						    oGetD6:aCols[_nNovaLinha][_nPosTmp]  := 0
					    ElseIf _aCamposUsr[_nX][2] == "D"
						    oGetD6:aCols[_nNovaLinha][_nPosTmp]  := Ctod(Space(8))
						ElseIf _aCamposUsr[_nX][2] == "L"
						    oGetD6:aCols[_nNovaLinha][_nPosTmp]  := .F.
						Endif
 						
					Endif
					
				Next _nX			
				oGetD6:Refresh() 
				
			Endif	
			
		EndIf
	Else
		MsgAlert(STR0086+;
				 STR0087) //"O cartใo deve estar na situa็ใo Cancelado por motivo de perda/furto ou desligamento da empresa para " ## "que seja gerado um novo n๚mero."
	Endif
Else
	MsgAlert(STR0088) //"Posicione na linha do titular ou dependente para o qual deseja gerar um novo cartใo."
EndIf

RestArea(_aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณProgram   ณMTA120E   ณ Autor ณVendas Cliente         ณ Data ณ 09/03/05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPonto de entrada na exclusao do PC.                         ณฑฑ
ฑฑณ          ณEfetua tratamento para que campo B2_SALPEDI seja atualizado ณฑฑ
ฑฑณ          ณde forma correta na exclusao do PC com aglutinacao ou nใo deณฑฑ
ฑฑณ          ณfiliais.                                                    ณฑฑ
ฑฑณ          ณSua logica eh: baseada no arquivo LHU.                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณSempre retorna .T. para prosseguir na exclusใo              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณRecebe parametro nOpcA mas nใo o usa em seu processamento   ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MTA120E(nOpcA)
Local lRet		:= .t.
Local nRecSC7	:= recno()
Local aArea		:= GetArea()
Local _cNumPed	:= " "

DbselectArea("SB2")
SB2->(DbSetOrder(1))

DbselectArea("LHU")
LHU->(DbSetOrder(1))
LHU->(DbSeek(XFILIAL("LHU")+ CA120NUM))
_cNumPed	:= LHU->LHU_NUM
While !LHU->(eof()) .AND. _cNumPed == LHU->LHU_NUM

	// Ajusto o SALPEDI no arquivo SB2. o Saldo da  da Matriz (ou Filial Aglutinadora) serแ incrementado e o da filial da necessidade decrementado
	if SB2->(DbSeek( LHU->LHU_FILNEC + LHU->LHU_PRODUT + LHU->LHU_LOCAL  )) .AND. LHU->LHU_AGLUTI = "S"
		RecLock("SB2",.F.)
		SB2->B2_SALPEDI += LHU->LHU_SALPED
		SB2->(MsUnLock())
	endif
		
	RecLock("LHU",.F.)
	LHU->LHU_SALPED := 0    //  Zero campo indicando que pedido foi excluido e aumentando a seguran็a do processo
	LHU->(MsUnLock())
		
	LHU->(dbskip())
End

RestArea(aArea)
dbgoto(nRecSC7)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณGrvFiliaisบAutor  ณVendas Cliente      บ Data ณ  20/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para confirma็ใo da grava็ใo da c๓pia da tabela	  บฑฑ
ฑฑบ			 ณde pre็os para as Filiais   							      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณOM010LOK - Botao 'Ok'			    						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function GrvFiliais(oDlg)
/*Local nX := 0

For nX := 1 to Len(aCampos)
	If aCampos[nX][1] == "MARCA"
		cCodEmp := aCampos[nX][2]
		cCodFil := aCampos[nX][3]
		Reclock("DA0",.T.)
		MsUnLock()
	Endif
Next nX
Close(oDlg)
*/

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSD1100I   บAutor  ณVendas Cliente      บ Data ณ  20/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada para analise de precos a partir de uma     บฑฑ
ฑฑบ 		 ณNota Fiscal de Entrada. As diferen็as entre os precos de    บฑฑ
ฑฑบ			 ณcusto e o pre็os de venda deve ser armazenada, 			  บฑฑ
ฑฑบ 		 ณconsiderando o markup na tabela SB1.                        บฑฑ
ฑฑบ 		 ณOutra funcionalidade da rotina esta na geracao de etiquetas บฑฑ
ฑฑบ 		 ณde produtos gravandos as informacoes de cada item da        บฑฑ
ฑฑบ			 ณNF de entrada.											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria   Programa MATA103                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function SD1100I()
/*
Local aArea   := GetArea()
Local nPVEsp  := 0         // Pre็o de Venda Esperado = (Pre็o de Custo + Markup)

If SF1->F1_TIPO == "N"   // So analisa se a nota fiscal for Normal
	
	DbselectArea("SB1")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SB1") + SD1->D1_COD)
		
		nPVEsp := (SD1->D1_VUNIT + SB1->B1_MARKUP)
		
		// Se houver diferen็a (tanto para mais ou para menos)
		If (SB1->B1_PRV1 < nPVEsp) .OR. (SB1->B1_PRV1 > nPVEsp)
			DbselectArea("LJ2")
			DbSetOrder(2)
			
			If DbSeek(xFilial("LJ2") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + SD1->D1_COD)
				RecLock("LJ2", .F.)
			Else
				RecLock("LJ2", .T.)
			EndIf
			
			LJ2->LJ2_FILIAL := xFilial("LJ2")
			LJ2->LJ2_DOC    := SF1->F1_DOC
			LJ2->LJ2_SERIE  := SF1->F1_SERIE
			LJ2->LJ2_FORNEC := SF1->F1_FORNECE
			LJ2->LJ2_LOJA   := SF1->F1_LOJA
			LJ2->LJ2_EMISS  := SF1->F1_EMISSAO
			LJ2->LJ2_ITEM	:= SD1->D1_ITEM
			LJ2->LJ2_COD	:= SD1->D1_COD
			LJ2->LJ2_VUNIT	:= SD1->D1_VUNIT
			LJ2->LJ2_UM		:= SD1->D1_UM
			LJ2->LJ2_PRV1	:= SB1->B1_PRV1
			LJ2->LJ2_MARKUP	:= SB1->B1_MARKUP
			
			MsUnLock("LJ2")
		EndIf
	EndIf
	
	RestArea(aArea)
	
EndIf
*/
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMA103BUT  บAutor  ณVendas Cliente      บ Data ณ  20/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada alterado para inclusao de um botao   	  บฑฑ
ฑฑบ			 ณpara emissao de Etiquetas de Produtos a partir de uma 	  บฑฑ
ฑฑบ 		 ณNota Fiscal de Entrada  							          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria  Programa MATA103                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MA103BUT()
Local aBotoes := {}  
/*
If !INCLUI
	Aadd(aBotoes,{STR0089,{|| T_RelEtq(aCols)},STR0090}) //"RELATORIO" ## "Etiq. Produtos"
EndIf
*/
Return aBotoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMA120BUT  บAutor  ณVendas Cliente      บ Data ณ  20/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada alterado para inclusao de um botao   	  บฑฑ
ฑฑบ			 ณpara emissao de Etiquetas de Produtos a partir de um  	  บฑฑ
ฑฑบ 		 ณPedido de Compras     							          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria  Programa MATA120                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MA120BUT()
Local aBotoes := {}
/*
If !INCLUI
	Aadd(aBotoes,{STR0089,{|| T_RelEtq(aCols)},STR0090}) //"RELATORIO" ## "Etiq. Produtos"
EndIf
*/
Return aBotoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRTFUNCOESบAutor  ณVendas Cliente      บ Data ณ  02/2006	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para adicionar novas funccoes quando      บฑฑ 
ฑฑบ          ณ pressionado a tecla F12 no Front-Loja                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function FRTFuncoes()
Local _aFuncoes := ParamIxb[1]			//Conteudo o array aFuncoes

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIntervalo utilizado pelos templates:ณ
//ณ70 a 99                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If T_DroLenANVISA() > 0
	AAdd( _aFuncoes, { "70", "SNGPC - ANVISA", "T_DroVSNGPC( .T., .T. )", { |x| .F. } } ) //"SNGPC"
Endif

If cTipTef == TEF_CLISITEF .AND. lUsaTef .AND. HasTemplate("DRO")  
	AAdd( _aFuncoes, { "71", "PBM VidaLink"  				,"T_DroVLGet(1)"	, {|x|  .F. } } ) //"PBM VIDA LINK"
	AAdd( _aFuncoes, { "72", "PBM PharmaSystem"  			,"T_DroVLGet(541)"	, {|x|  .F. } } ) //"PBM PHARMASYSTEM"
	AAdd( _aFuncoes, { "73", "PBM Funcional Card"  			,"T_DroVLGet(560)"	, {|x|  .F. } } ) //"PBM Funcional Card"
EndIf

Return _aFuncoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณPrograma  ณ LJDEPSE1 ณ Autor ณVendas Cliente         ณ Data ณ JUL/2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPonto de entrada para a Gravacao do Cod. Dependete no       ณฑฑ
ฑฑณ          ณCONTAS A RECEBER(SE1)								          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJTPLSE1()
Local aArea     := GetArea()
Local aAreaSE1  := SE1->(GetArea()) 
Local lExistLHG := .T.		//Verifica se existe arquivo na tabela LHG
Local cMatric       := ""

//ChkTemplate("DRO")
//Posiciona sempre no ultimo historico de Pontucao para colher informacoes da ultima venda realizada
DbselectArea("LHG")
DbSetOrder(1)
DbSeek(xFilial("LHG") +"ZZZZZZ"+"ZZ",.T.)
DbSkip(-1)//Posiciona no ultmio registro

If Bof()
	lExistLHG := .F.
Endif

If lExistLHG
	// Gravacao das informacoes dos Dependente caso a venda seja realizada para o mesmo.
	DbselectArea("SE1")
	DbSetOrder(1)
	If DbSeek(xFilial("SE1")+LHG->LHG_SERIE+LHG->LHG_CUPFIS)
	    While !Eof() .AND. SE1->E1_PREFIXO = LHG->LHG_SERIE .AND. SE1->E1_NUM = LHG->LHG_CUPFIS
			RecLock("SE1",.F.)
			SE1->E1_CODDEP := LHG->LHG_CODDEP
			SE1->E1_NOMDEP := LHG->LHG_NOMDEP
			SE1->E1_CARDEP := LHG->LHG_CARDEP
			MsUnlock()
			DbSkip()
		End
	Endif        
Endif        

If SuperGetMv("MV_PLSATIV",.F.,.F.) 
	cMatric := IIf (Type("M->LQ_MATRIC") <> "U",Alltrim(M->LQ_MATRIC) ,Alltrim(SL1->L1_MATRIC))
	If !Empty(cMatric)
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC))
			While ! SE1->(Eof()) .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM ==;
										xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC
		        SE1->(RecLock("SE1",.F.))
				SE1->E1_CODINT  := Substr(cMatric,1,4)
				SE1->E1_CODEMP  := Substr(cMatric,5,4)
			  	SE1->E1_MATRIC  := Substr(cMatric,9,6)
			  	SE1->E1_TIPREG  := Substr(cMatric,15,2)
				SE1->(MsUnlock())
				SE1->(dbCommit()) 
				If SuperGetMv("MV_PLSDRO",.F.,.T.) .AND. Alltrim(SE1->E1_TIPO) == "PS"
					// cria o lan็amento d้btito PLS
					T_PLSGERCOB(cMatric) 
				    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		        	//ณ Baixa titulo no Contas a Receber                                           ณ 
		        	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		   		    T_PLSTBXDRO()
		   	    Endif
				SE1->(dbSkip())
			End
		Endif        
	Else       
		If SuperGetMv("MV_PLSDRO",.F.,.T.) .AND. Alltrim(SE1->E1_TIPO) == "PS"
			Aviso(STR0093,STR0094,{"Ok"},2)//"INTEGRAวรO PLS" ##"O Titulo estแ como Forma de Pagamento 'PS' Plano de Sa๚de, mas devido ao nใo Fornecimento da Matricula, nใo gerou cobran็a no PLS"
		Endif 
	Endif
Endif
RestArea(aArea)
SE1->(RestArea(aAreaSE1))

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSWEServ   บAutor  ณVendas Cliente      บ Data ณ  10/19/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para 'derrubar' o servico SWEDA           บฑฑ 
ฑฑบ          ณ caso ocorra algum erro de comunicacao                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function SWEServ() 
Conout("TPLFUN  SWEServ - Inicio - "+ Time() )

WinExec("swedakill.sh",0)   

Conout("TPLFUN  SWEServ - Final - "+ Time() )

Sleep(5000)		

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCRDVDCA   บAutor  ณVendas Cliente      บ Data ณ  04/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao na delecao da linha do aCols na aba dos cartoes   บฑฑ
ฑฑบ          ณMA6 no cadastro do cliente do SIGACRD                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTPL-DRO - CRDA010                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function CRDVDCA( lControlaLoop )
Local lRet				:= .T. 													// Retorno da funcao 
Local cChave			:= "" 													// Chave de busca
Local nPosSitua 		:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_SITUA"})		// Posicao do status do cartao 1=Ativo;2=Bloqueado;3=Cancelado
Local nPosDepCart		:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_CODDEP"})	// Posicao do codigo do dependente
Local nPosNumCart		:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_NUM"})		// Numero do cartao
Local nX				:= 0													// Variavel de looping

DEFAULT lControlaLoop	:= .T.													// Indica que ira' controlar as 2 vezes que o objeto chama a rotina na delecao da linha

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA variavel __lCRDVDCA foi criada devido a um bug na funcao de  ณ
//ณdelecao que estah sendo chamada 2 vezes.                       ณ
//ณQuando esta funcao eh chamada por dentro do fonte nao eh       ณ
//ณnecessario fazer o controle do lP7VlDev e esta variavel tem    ณ
//ณiniciar a funcao como False e sair da funcao como False        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static __lCRDVDCA	:= .F.
//ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

If !__lCRDVDCA

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ So' faz a validacao da recuperacao da linha para nao permitir 2      ณ
	//ณ linhas de cartoes ATIVO do mesmo cliente (titular ou dependente)     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oGetD6:aCols[oGetD6:nAT][Len( oGetD6:aCols[oGetD6:nAT] )]
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Determina qual a chave de busca para validar a delecao da linha      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cChave := 	Alltrim( oGetD6:aCols[oGetD6:nAT][nPosDepCart] ) + ;	// Codigo do dependente
					Alltrim( oGetD6:aCols[oGetD6:nAT][nPosSitua] )    		// Status do cartao
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz a validacao se pode deletar a linha. Se ja' tiver algum cartao   ณ
		//ณ para o mesmo cliente que esteja como cartao ATIVO, nao deixa deletar ณ
		//ณ a linha.                                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If oGetD6:aCols[oGetD6:nAT][nPosSitua] == "1" // Ativo
		               
			For nX := 1 To Len( oGetD6:aCols )
				If nX <> oGetD6:nAT               
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Verifica so' os registros que nao estao deletados                    ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !oGetD6:aCols[nX][Len( oGetD6:aCols[nX] )]
				
						If cChave == Alltrim( oGetD6:aCols[nX][nPosDepCart] ) + Alltrim( oGetD6:aCols[nX][nPosSitua] )
							MsgStop( STR0092 ) //"Jแ existe um cartใo ATIVO para este cliente. Este registro nใo poderแ ser recuperado."
							lRet := .F.
						Endif
					
					Endif
	        	Endif
			Next nX	
		
		Endif
		
	Endif
Endif
              
If lControlaLoop
	__lCRDVDCA := !__lCRDVDCA
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrtResume บAutor  ณVendas Cliente      บ Data ณ  15/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Posiciona o plano de fidelizacao do cliente no caso de     บฑฑ
ฑฑบ          ณ recuperacao da venda. Depois do cliente selecionado e      บฑฑ
ฑฑบ          ณ depois de alguns produtos vendidos se o remote cair,       บฑฑ
ฑฑบ          ณ na volta do FrontLoja e' necessario posicionar o plano     บฑฑ
ฑฑบ          ณ do cliente novamente.                                      บฑฑ
ฑฑบ          ณ Obs.: Quando estra neste ponto o SL1 ja' esta' posicionado.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRONTLOJA + TPL DRO                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function FrtResume()
Local aRet		:= Array( 1 )				// Retorno da funcao 
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Retorna o codigo da regra utilizado na venda e posiciona o arquivo   ณ
//ณ dos planos                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SL1->( ColumnPos("L1_CPLFIDE") ) > 0 .AND. !Empty( SL1->L1_CPLFIDE )
	aRet[1] := SL1->L1_CPLFIDE
	
	MHG->( DbSetOrder( 3 ) )	// MHG_FILIAL+MHG_CODREG+MHG_CODIGO+MHG_TIPO
	MHG->( DbSeek( xFilial( "MHG" ) + SL1->L1_CPLFIDE ) )
	MHG->( DbSetOrder( 1 ) )	// MHG_FILIAL+MHG_CODIGO+MHG_NOME
Endif
   
Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDROPesqSA5บAutor  ณVendas Cliente      บ Data ณ  13/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina para buscar o codigo interno Protheus quando se digi-บฑฑ
ฑฑบ          ณta um codigo de produto de fornecedor, baseado no arquivo   บฑฑ
ฑฑบ          ณSA5(Fornecedor x Produto)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณValid do campo D1_COD, rotina Recebimento de Materiais      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DROPesqSA5()
Local cCodProd                                     // Codigo do produto interno Protheus
Local cReadVar                                     // Nome do campo digitado 
Local cCodDig                                      // Codigo do produto digitado
Local lAchou    := .F.                             // Controla se foi encontrado codigo do produto no SA5
Local aArea     := GetArea()                       // Area atual
Local nPosProd  := 0 							   // Posicao do produto no AHeader
Local nTamSA5Prod := 0                            // Tamanho do campo A5_CODPRF

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o documento eh do tipo Normal e se a especie eh Nota Fiscal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FunName() == "MATA103" .AND. ALLTRIM(cTipo) == "N" .AND. (ALLTRIM(cEspecie) == "NF" .OR. ALLTRIM(cEspecie) == "NFE")
	
	cCodProd    := Space(TamSX3("B1_COD")[1])
	cReadVar    := ReadVar()
	nPosProd    := Ascan(aHeader,{|x| Trim(x[2]) == "D1_COD"})
	nTamSA5Prod := TamSX3("A5_CODPRF")[1]
	
	If Empty(cReadVar)
		cCodDig   := cCodProd
	Else
		cCodDig   := &(cReadVar)
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o produto esta cadastrado nos arquivos SB1 ou SLKณ
	//ณSe estiver, considera codigo de produto interno Protheus     ณ
	//ณSe nao estiver, verifica amarracao no arquivo SA5 			ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cCodDig)
		If SA5->(RecCount()) > 0      
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณComo os tamanhos dos campos D1_COD e A5_CODPRF sao diferentes,ณ
			//ณdeve adaptar para a pesquisa no arquivo SA5                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    		cCodDig  := PADR(cCodDig,nTamSA5Prod) 					
			DbselectArea("SA5")
			DbSetOrder(5)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณBusca por todos os produtos cadastrados no SA5 com o codigo digitado  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If DbSeek(xFilial("SA5")+cCodDig)
				While !EOF() .AND. xFilial("SA5")+cCodDig == SA5->A5_FILIAL+SA5->A5_CODPRF .AND. !lAchou
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se o produto encontrado eh do fornecedor selecionado na NF      ณ
					//ณSe corresponder, retorna o codigo do produto interno Protheus(cCodProd)  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If cA100For+cLoja == SA5->A5_FORNECE+SA5->A5_LOJA
						cCodProd   := SA5->A5_PRODUTO
						lAchou     := .T.
					Endif
					
					DbSkip()
				End
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe codigo encontrado, atualiza aCols e variavel de memoria           ณ
				//ณAs validacoes posteriores devem considerar o codigo interno Protheus ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lAchou
					If nPosProd > 0
						aCols[n][nPosProd]  := cCodProd
					Endif
					M->D1_COD           := cCodProd
					
					DbselectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+cCodProd)
				Endif
			Else
				LJSB1SLK(@cCodDig , NIL , .F.)	
			Endif
		Else
			LJSB1SLK(@cCodDig , NIL , .F.)	
		Endif
	Endif
	
	RestArea(aArea)
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ7036	บAutor  ณVendas Cliente	     บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPonto de entrada para veriricacao do produto digitado na    บฑฑ
ฑฑบ          ณtela da Venda Assistida                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณLOJA701A -  Funcao LJ7Prod      						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJ7036() 
Local lRet 			:= .T.				//Retorno da funcao
Local cNumOrc		:= ParamIxb[1]		//Numero do Orcamento
Local cNumDoc		:= ParamIxb[2]		//Numero do Documento
Local cNumSerie		:= ParamIxb[3]		//Serie
Local cItem			:= ParamIxb[4]		//Codigo do item
Local cCodProd		:= ParamIxb[5]		//Codigo do produto			
Local nQuant		:= ParamIxb[6]		//Quantidade
Local nTamANVISA 	:= 0				//Tamanho do array aANVISA        
Local nItem			:= 0				//ID ANVISA					
Local cClassTe		:= ''
Local cSupervisor	:= Space(25)
Local lPermTelAnv	:= .T.

If HasTemplate("DRO")
	If ValType(cItem) == "C"
		nItem := Val(cItem)
	Else
		nItem := cItem
	Endif
	
	If SB1->(ColumnPos("B1_SUSPVEN") > 0 )  .AND. SB1->B1_SUSPVEN == .T.
		MsgAlert(STR0096) 	//"Produto com a venda suspensa!  Verifique o cadastro de produtos "
		lRet :=	.F.
	EndIf
	
	lPermTelAnv := LjProfile(42,@cSupervisor)
	
	If !lPermTelAnv
		MsgStop("Usuแrio nใo tem permissใo para venda de medicamentos controlados")
		lRet := .F.
	EndIf
	
	If lRet
		If T_DroVerCont( cCodProd )
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se a tela de Controle da ANVISA ja' foi solicitada anteriormenteณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lJaChamouANVISA := .F. // colocada falso porque em todos os remedios controlados tem que chamar a tela de medicamentos
			If !lJaChamouANVISA
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณChamada a tela para acrescentar informacoesณ
				//ณdo medicamento controlado                  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If T_DroVSNGPC( .F.			, .T. 	, /**/		, /**/,;
								@cClassTe	, nItem	, cCodProd	, /**/,;
								/**/		, /**/	,lPermTelAnv)
					lJaChamouANVISA := Iif (cClassTe <> '' ,.T. , .F.)      	
					T_DroAtuANVISA( cNumOrc , cNumDoc, cNumSerie, nItem,;
									cCodProd, nQuant )	 								
				Else
					lRet := .F.	
				Endif	
			Else
				T_DroAtuANVISA( cNumOrc , cNumDoc, cNumSerie, nItem,;
								cCodProd, nQuant )
				T_DroAuxANVISA( .F., NIL, .F. )
				T_DroInfLote()
			Endif
		Else
			nTamANVISA := T_DroLenANVISA() 
			If nTamANVISA > 0
				If T_DroExisANVISA(nItem)	
					T_DroDelANVISA( .F., nItem )
				Endif
			Endif	
		Endif
	EndIf	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRTProSZ  บAutor  ณVendas Cliente	     บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPonto de entrada para exclusao dos registros da tabela LK9  บฑฑ
ฑฑบ          ณna RETAGUARDA quando um CUPOM FISCAL e' CANCELADO           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณLOJA140 - Funcao lj140ExcOrc							      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJ140DEL()
Local lJob := ParamIxb[1]

T_DROCancANVISA(NIL, lJob)		//Localizado no fonte DROVLDFUNCS.prw

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ140EXC  บAutor  ณVendas Cliente	     บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPonto de entrada para exclusao dos registros da tabela LK9  บฑฑ
ฑฑบ          ณna RETAGUARDA quando um CUPOM FISCAL e' CANCELADO           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณLOJA140 - Funcao lj140ExcOrc							      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function LJ140EXC()
Local lVendido := ParamIxb[1]

If HasTemplate("DRO")
	If !lVendido
		T_DROCancANVISA(.T.)		//Localizado no fonte DROVLDFUNCS.prw
	Endif
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณA010TOK   บAutor  ณVendas Cliente	     บ Data ณ  15/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPonto de entrada para verificar a confirmacao do cadastro   บฑฑ
ฑฑบ          ณdos medicamentos controlados.                               บฑฑ
ฑฑบ          ณSe B1_PSCOTR = 1 e B1_REGMS = '', emite uma mensagem ao     บฑฑ
ฑฑบ          ณusuario                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณCadastro de produtos									      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function A010TOK()                                         
Local lRetorno := .T.			   				//Retorno da funcao 
Local lPSICOTR := ColumnPos("B1_PSICOTR") > 0	//Verifica se o campo B1_PSICOTR
Local lREGMS   := ColumnPos("B1_REGMS"  ) > 0	//Verifica se o campo B1_REGMS

If lPSICOTR .AND. lREGMS
	If (M->B1_PSICOTR == "1" .AND. Empty(AllTrim(M->B1_REGMS)))
		lRetorno := .F.	
		MsgAlert("O campo 'Registro MS' deve ser preenchido.")
	Endif
Endif         

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT103IPC  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Template para tratar o % desconto a cada item do PC        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณDrogaria Moderna                                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT103IPC()
Local nPosProd := aScan( aHeader, {|x| AllTrim( x[2] ) == "D1_COD"     } )  // Produto
Local nPosDesc := aScan( aHeader, {|x| AllTrim( x[2] ) == "D1_DESC"    } )  // % de Desconto
Local nPosVal  := aScan( aHeader, {|x| AllTrim( x[2] ) == "D1_VALDESC" } )  // Valor de Desconto
Local nPosTot  := aScan( aHeader, {|x| AllTrim( x[2] ) == "D1_TOTAL"   } )  // Total do Item
Local nPosPC   := aScan( aHeader, {|x| AllTrim( x[2] ) == "D1_PEDIDO"  } )  // Nro do PC
Local nItem    := ParamIXB[1]                                                // Item em edicao no browser
Local nPDesc   := 0                                                          // % de Desconto do Item
Local cCodPro  := ""                                                         // Codigo do Produto      
Local lC7Bonus := SC7->(ColumnPos("C7_BONUS")) > 0                           //Campo existe no dicionแrio de dados?

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Aplicar  o  desconto se o  item atual  esta sendo ณ
//ณ carregado de um pedido de compra de bonificacao.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( aCols[ nItem ][ nPosPC ] ) .AND. lC7Bonus .AND. SC7->C7_BONUS == "1"
	cCodPro := aCols[ nItem ][ nPosProd ]
	nPDesc  := T_DRODescSA2( SC7->C7_FORNECE, SC7->C7_LOJA, cCodPro )
	
	aCols[nItem][nPosDesc] := nPDesc
	aCols[nItem][nPosVal ] := ( aCols[nItem][nPosTot] * nPDesc ) / 100
	MaFisAlt( "IT_DESCONTO", aCols[nItem][nPosVal], nItem )
	A103Trigger( "D1_VALDESC" )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT120BRW  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Template p/ bloquear alteracao/copia do PC de bonificacao  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณDrogaria Moderna                                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT120BRW()

aRotina[04] := { "Alterar", "TrataPC",	0, 4, 6 }
aRotina[06] := { "Copiar",  "TrataPC",	0, 4    }
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ TrataPC   ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Funcao para tratar  alterar ou copiar o PC                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณTrataPC( ExpC1, ExpN1, ExpN2 )                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 = Alias atual                                         ณฑฑ
ฑฑณ          ณExpN1 = Registro posicionado                                ณฑฑ
ฑฑณ          ณExpN2 = Opcao que esta chamando                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณDrogaria Moderna                                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TrataPC( cAlias, nReg, nOpcX )          

Local lC7Bonus := SC7->(ColumnPos("C7_BONUS")) > 0                            //Campo existe no dicionแrio de dados?

If lC7Bonus .AND. SC7->C7_BONUS == "1"
	MsgAlert( "Este Pedido de Compra nao podera ser alterado ou copiado por se tratar de uma bonificacao...", "Atencao" )
Else
	A120Pedido( cAlias, nReg, nOpcX, , nOpcX == 6 )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT120COR  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Sinalizacao do PC de bonificacao no browser                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ                      									  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT120COR()
Local aCores := ParamIXB[1]		//Array com as cores 
Local aAux   := {}				//Array auxiliar
Local nInc   := 0				//Controle de loop

aAdd( aAux, { 'C7_QUJE < C7_QUANT .AND. ColumnPos("C7_BONUS") > 0 .AND. C7_BONUS == "1"', "BR_MARRON" } )
For nInc := 1 To Len( aCores )
	aAdd( aAux, aCores[ nInc ] )
Next nInc

aCores := aClone( aAux )
	
Return aCores

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT120GRV  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Atualiza a variavel private cNumDoc                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ                      									  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT120GRV()
Local lExcluir := ParamIXB[4]

cNumDoc := ParamIXB[01]
	
If lExcluir
	T_DRODelLKC(cNumDoc)
EndIf
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT120LEG  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Ajusta o item na legenda                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ                      									  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT120LEG()
Local aLegUsr := ParamIXB[1]		//Array com as legendas

aAdd( aLegUsr, { "BR_MARRON", "Pedido por Bonificacao" } )

Return aLegUsr

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MTA177FOR ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Retorna o fornecedor/distribuidor com maior percentual de  ณฑฑ
ฑฑณ          ณ desconto para a geracao do pedido de compra.               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ                      									  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MTA177FOR()
Local cProd      := ParamIXB[3]   // Codigo dos Produtos 
Local aReturn    := {'','',''}
Local cQuery     := ""

cQuery += "SELECT A5_FORNECE,  "
cQuery += "A2_CGC, A5_LOJA, "
cQuery += "( sum( A5_DESCCOM ) + sum( A5_DESCFIN ) ) AS DESCONTO "
cQuery += "FROM " + RetSqlName( "SA5" ) + " "
cQuery += "LEFT JOIN " + RetSqlName( "SA2" ) + " ON A2_COD = A5_FORNECE "
cQuery += "WHERE " + RetSqlName( "SA5" ) + ".D_E_L_E_T_ = '' AND "
cQuery += "      " + RetSqlName( "SA2" ) + ".D_E_L_E_T_ = '' AND "
cQuery += "      A5_PRODUTO = '" + cProd + "' "   
cQuery += "GROUP BY A5_FORNECE, A2_CGC,A5_LOJA, A5_PRIOFOR "
cQuery += "ORDER BY DESCONTO DESC, A5_PRIOFOR  "

cAliasTrb := GetNextAlias()
cQuery    := ChangeQuery( cQuery )
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

If (cAliasTrb)->( !Eof() )
	aReturn[1] := ((cAliasTrb)->A2_CGC)
	aReturn[2] := ((cAliasTrb)->A5_FORNECE)
	aReturn[3] := ((cAliasTrb)->A5_LOJA)
EndIf
	
Return aReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ MT060GRV  ณ Autor ณ Totvs                ณ Data ณ 22/07/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Template para criacao do AIB vigente.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Drogaria Moderna                                           ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT060GRV()
Local cForn   := SA5->A5_FORNECE
Local cLoja   := SA5->A5_LOJA
Local cTabe   := SA5->A5_CODTAB
Local cProd   := SA5->A5_PRODUTO
Local nItem   := 0
Local lAppend := .F.

DbSelectArea( "AIA" )
AIA->(DbSetOrder( 1 ))
AIA->(DbSeek( xFilial( "AIA" ) + cForn + cLoja + cTabe ))

DbSelectArea( "AIB" )
AIB->(DbSetOrder( 2 ))

While AIA->( !Eof() ) .AND. xFilial( "AIA" ) == AIA->AIA_FILIAL .AND. cForn == AIA->AIA_CODFOR .AND. cLoja == AIA->AIA_LOJFOR .AND. cTabe == AIA->AIA_CODTAB
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se a tabela de preco esta dentro da validade     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AIA->AIA_DATATE <= DDATABASE

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Soma o numero do proximo item na tabela de preco          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nItem := 0
		AIB->(DbSeek( xFilial( "AIB" ) + cForn + cLoja + cTabe ))
		dbEval( {|x| nItem++ },, {|| AIB->AIB_FILIAL == xFilial( "AIB" ) .AND. AIB->AIB_CODFOR == cForn .AND. AIB->AIB_LOJFOR == cLoja .AND. AIB->AIB_CODTAB == cTabe } )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Acrescenta o produto na tabela em vigencia                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lAppend := !AIB->(DbSeek( xFilial( "AIB" ) + cForn + cLoja + cTabe + cProd ))
		If lAppend
			RecLock( "AIB", lAppend )
			REPLACE AIB->AIB_FILIAL WITH AIA->AIA_FILIAL
			REPLACE AIB->AIB_CODFOR WITH AIA->AIA_CODFOR
			REPLACE AIB->AIB_LOJFOR WITH AIA->AIA_LOJFOR
			REPLACE AIB->AIB_CODTAB WITH AIA->AIA_CODTAB
			REPLACE AIB->AIB_DATVIG WITH DDATABASE      
			REPLACE AIB->AIB_QTDLOT WITH 999999.99      
			REPLACE AIB->AIB_TPOPER WITH "4"
			REPLACE AIB->AIB_CODPRO WITH cProd
			REPLACE AIB->AIB_ITEM   WITH StrZero( ++nItem, 4 )
			AIB->(MsUnLock( "AIB" ))
		EndIf
	EndIf

	AIA->( DbSkip() )
End

Return  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMT340D3  บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecutado somente quando e' realizado o ajuste de inventarioบฑฑ
ฑฑบ          ณpelo MATA340                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao da SD3(MATA340)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT340D3()

If HasTemplate("DRO")
	T_DroEntANVISA( .F., "MT340D3")
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMT220GRV  บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecutado somente quando e' realizado a inclusao de saldo   บฑฑ
ฑฑบ          ณinicial pelo fonte mata220                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao de todos os arquivos    บฑฑ
              na funcao A220ATUSB2 em MATA220
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT220GRV()
Local cProd := Paramixb[3]  // codigo do produto

If HasTemplate("DRO")
	T_DroEntANVISA( .F., "MT220GRV",/* cCodLista*/ ,cProd )
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMA270TOK  บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecutado somente quando e' realizado a inclusao de saldo   บฑฑ
ฑฑบ          ณinicial pelo fonte mata220                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao de todos os arquivos    บฑฑ
              na funcao A220ATUSB2 em MATA220
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MA270TOK()

Local cProd := Paramixb[1]  // codigo do produto
Local lRet  := .T.
Local cCaixaSup := ""

//Verifica se usuario tem permissao de de farmaceuto para incluir registros
lRet := T_DroVERPerm(,@cCaixaSup)

If lRet  
	If SB7->(ColumnPos("B7_USVENDA")> 0) 
		M->B7_USVENDA := cUserName
	EndIf
	
	If SB7->(ColumnPos("B7_USAPRO")> 0)
		M->B7_USAPRO := cCaixaSup
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMT220TOK  บAutor  ณVendas Cliente      บ Data ณ  10/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecutado somente quando e' realizado a inclusao de saldo   บฑฑ
ฑฑบ          ณinicial pelo fonte mata220                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamada   ณPonto de entrada depois da gravacao de todos os arquivos    บฑฑ
              na funcao A220ATUSB2 em MATA220
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTemplate Drogaria                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function MT220TOK()
Local cProd		:= Paramixb[2]  // codigo do produto
Local lRet  	:= .T.
Local cCaixaSup := ""
 
//Verifica se usuario tem permissao de de farmaceuto para incluir registros
lRet := T_DroVERPerm(3,@cCaixaSup)

If lRet
	If SB9->(ColumnPos("B9_USVENDA")> 0) 
		M->B9_USVENDA := cUserName
	EndIf
	
	If SB9->(ColumnPos("B9_USAPRO")> 0)
		M->B9_USAPRO := cCaixaSup
	EndIf
EndIf 

Return lRet

//----------------------------------------------
/*/{Protheus.doc} MA020TOK
Valida o preenchimento dos campos da SA2 na Rotina MATA020

@owner  	Varejo
@author  	julio.nery
@version 	V12
@since   	27/2/2018 
/*/
//----------------------------------------------
Template Function MA020TOK()
Local lRet	:= TPLDrVlSA2()

Return lRet 

//----------------------------------------------
/*/{Protheus.doc} MA020Alt
Valida o preenchimento dos campos da SA2 na Rotina MATA020

@owner  	Varejo
@author  	julio.nery
@version 	V12
@since   	27/2/2018 
/*/
//---------------------------------------------
Template Function MA020Alt()
Local lRet	:= TPLDrVlSA2()

Return lRet

//---------------------------------------------
/*/{Protheus.doc} TPLDrVlSA2
Valida o preenchimento do campo A2_FABRICA 
que interfere no cadastro de Produtos

@owner  	Varejo
@author  	julio.nery
@version 	V12
@since   	27/2/2018 
/*/
//---------------------------------------------
Static Function TPLDrVlSA2()
Local cMensagem := ""
Local lRet		:= .T.

If HasTemplate("DRO") 
	If SA2->(ColumnPos("A2_FABRICA")) > 0
		If AllTrim(Upper(M->A2_FABRICA)) <> "S"
			cMensagem := "Aten็ใo . Campo A2_FABRICA nใo estแ preenchido com 'S' isso " +;
					"implica que o esse fornecedor nใo serแ mostrado no Cadastro de Produtos (LOJA110/MATA010)" 
		Else
			cMensagem := "Campo A2_FABRICA preenchido corretamente"
		EndIf
	Else
		cMensagem := " Campo A2_FABRICA nใo existe. Aplique novamente o Template"
	EndIf
	
	Conout(cMensagem)
	LjGrvLog( Nil ,cMensagem)
Endif

Return lRet