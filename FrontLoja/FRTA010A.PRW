#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA010A.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"

#DEFINE	FRT_SEPARATOR		"----------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				 1
#DEFINE AIT_COD			   		 2
#DEFINE AIT_CODBAR				 3
#DEFINE AIT_DESCRI				 4
#DEFINE AIT_QUANT				 5
#DEFINE AIT_VRUNIT				 6
#DEFINE AIT_VLRITEM		   		 7
#DEFINE AIT_VALDESC		   		 8
#DEFINE AIT_ALIQUOTA			 9
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_IDANVISA   			14          // Identificacao do campo ANVISA

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DIFINES criados pelo equipe de Templates³
//³Usado no Template de Drogaria.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE VDLNK_CABEC_CODCLI	 1
#DEFINE VDLNK_CABEC_LOJA	 2
#DEFINE VDLNK_INDICEPRODU	 1
#DEFINE VDLNK_CODIGOEAN  	 2
#DEFINE VDLNK_QUANTIDADE 	 3
#DEFINE VDLNK_PRECO      	 4
#DEFINE VDLNK_AUTORIZACAO   1
#DEFINE VDLNK_DETALHE    	 2
#DEFINE VDLNK_TOTALVENDA  	 3
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTA010  ³ Autor ³ Venda Clientes        ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Vendas - FrontLoja										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA010()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          	
Static oDoc  					// Objeto para mostrar o numero do documento	
Static oHora 					// Objeto para mostrar a hora
Static oPDV  					// Objeto para mostrar o numero do PDV
Static cDoc 					// Armazena o numero do documento
Static cHora  					// Armazena a hora atual do sistema	
Static cPDV    					// Armazena o numero do PDV
Static cOrcam   				// Armazena o numero do orcamento
Static oTimer					// Objeto que controla o Refresh da tela
Static oOnOffLine
Static oProduto   				// Objeto para mostrar o codigo do produto
Static oQuant    				// Objeto para mostrar a quantidade
Static oUnidade
Static oTmpQuant 			
Static oVlrUnit  			    // Objeto para mostrar Valor Unitario
Static oVlrItem     		    // Objeto para mostar o Valor do Item
Static oTotItens                // Objeto para mostar Total dos Itens
Static oVlrTotal    			// Objeto para mostar o valor total
Static oFotoProd        		// Objeto para mostar a foto do produto
Static oDesconto   				// Objeto para mostar o desconto
Static cProduto    				// Armazena o codigo do produto
Static nQuant  					// Armazena a quantidade
Static cUnidade  				// Armazena a unidade do produto
Static nTmpQuant
Static nVlrUnit					// Armazena Valor unitario
Static nVlrItem					// Armazena Valor do Item
Static nTotItens				// Armazena total dos Itens
Static nVlrTotal     			// Armazena o valor total
Static nVlrDescIT       		// Armazena o valor de desconto do item
Static nVlrPercIT				// Armazena o percentual de desconto do item
Static nValIPI  				// Armazena Valor do IPI
Static nValIPIIT
Static oCodProd 				// Objeto para mostrar codigo do produto
Static oCupom					// Objeto para mostrar Numero do cupom
Static cCodProd					// Armazena o codigo do produto
Static cCodBar					// Armazena o numero do codigo de barras
Static cBCONTA
Static cCupom  					// Armazena o numero do cupom fiscal
Static aItens
Static aICMS
Static oFntCupom
Static oFntInf
Static oFntGet
Static oFntQuant
Static oFntTotal
Static oFntLoc
Static oFntMoeda
Static nVlrBruto 				// Armazena o valor bruto da venda	
Static nLastTotal
Static nLastItem				// Armazena o codigo do ultimo item
Static nVlrMerc										
Static _aMult		:= {}
Static _aMultCanc	:= {}
Static nTamCodProd
Static lOrc			:= .F.
Static lEsc 		:= .F.
Static aParcOrc		:= {}
Static cItemCOrc
Static aParcOrcOld  := {}
Static aKeyFimVenda := {}
Static nHdlOPE
Static lExitNow		:= .F.								// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
Static lAltVend		:= .F.
Static lImpNewIT	:= .F.								// Indica se foi adicionado um novo item ao orcamento
Static lFechaCup 	:= .T.								// Indica se houve algum erro no fechamento do CF
Static cUsrSessionID:= ""								// Variavel para login na transacao Web Service
Static cContrato 	                					// Numero do contrato da transacao de credito
Static lMV_LJSLFin  := SuperGetMV("MV_LJSLFIN", ,.T.)
Static aCrdCliente  := {"",""}     						// Informacao do cliente p/Private Label [1]-CNPJ/CPF [2]-Numero do Cartao Private Label 
Static aContratos   := {}          						// Numero de contrato gerado pela venda. Utilizado nos casos em que deve cancelar o contrato pendente 
Static aRecCrd		:= {}								// Guarda as parcelas de financiamento para impressao do comprovante de recebimento	
Static aTEFPend     	            					// Parcelas que estao pendentes no TEF multiplas transacoes. Esta situacao ocorre quando a segunda eh rejeitada, por ex.   
Static aBckTEFMult                  					// Transacoes TEF pendentes que devem ser confirmadas. Utilizado quando a segunda transacao TEF eh rejeitada, por ex. Espelho do array aTEFMult
Static lDescTotal	:= .F.								// Valida de foi dado desconto no total do cupom, caso seja concomitante
Static lDescSE4		:= .F.								// Valida de foi dado desconto na condicao de pagamento
Static lVerTEFPend  := .F.         						// Controla se deve verificar se ha transacao TEF pendente ao final da venda
Static nTotDedIcms  := 0                                // Total de deducao do ICMS
Static lImpOrc		:= .F.                              // Controla se o orcamento foi importado da Retaguarda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aTEFPend          ³
//³[1] Forma de pagamento(CC, CD)       ³
//³[2] ID + Administradora              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                O B S E R V A C A O                                              //
//*****************************************************************************************************************//
// - A variável uCliTPL foi criada para ser utilizada pela equipe de Templates. Ela poderá receber, como retorno   //
// da Template Function "FRT010CL", qualquer tipo de valor. O tratamento da variável deverá ser realizado          //
// nas rotinas específicas do depto. de Templates.                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static uCliTPL      
Static uProdTPL	//armazena informacoes referente aos produtos que estao sendo vendidos.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Static de Templates. Codigo e loja do conveniado, utilizadas para implementacao de convenio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cCodConv     := ""	// codigo do cliente conveniado
Static cLojConv     := ""	// loja do conveniado
Static cNumCartConv := ""	// numeracao do cartao do cliente conveniado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Static de uso do Template Drogaria ³
//³Usada nas rotinas relacionadas a VIDALINK.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aVidaLinkD	:= {}						//array de detalhe (produto,qtde,preco) com o orcamento gerado no PBM VidaLink
Static aVidaLinkc	:= {}						//array cabecalhoe (Cliente,loja,etc) do orcamento gerado no PBM VidaLink
Static nVidaLink	:= 0 						//Indica se Itens veio do VidaLink. 0=Nao usa VidalInk. 1=Gravando VidaLink. 2=Gravou VidaLink
Static nValTPis		:= 0						// Valor total do PIS
Static nValTCof		:= 0						// Valor total do COFINS
Static nValTCsl		:= 0						// Valor total do CSLL
Static lOrigOrcam	:= .F.						// Origem da Condicao de Pagamento
Static cCdPgtoOrc   := ""						// Condicao de pagamento
Static cCdDescOrc   := ""						// Descricao condicao de pagamento

Function FRTA010( lFRTAuto )

Local oLogoEmp
Local aCupom		:= {"","","","","","","","","","","","","","","","","",""}
Local nTamSXG
Local nRPCInt
Local aKeyAux 		:= {}
Local cCaixa
Local oTemp1											// Variavel Para Utilizar Fundo Sem Transparencia
Local oTemp2											// Variavel Para Utilizar Fundo Sem Transparencia
Local lFrtGetPr		:= ExistBlock("FRTGETPR")		  	// Ponto de Entrada no bLostFocus do Get do Produto
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local nX												// Contador de For
Local nMVAUTOCOM										// Parametro MV_AUTOCOM
Local cNCartao      := ""								// Numeracao do Cartao do cliente
Local cCodDEP  		:= ""								// Codigo do DPEPENDENTE
Local cNomeDEP 		:= ""		   						// Nome de DEPENDENTE
Local lTefPendCS  	:= .F.								// Controla se existe TEF Pendente da CLISITEF
Local aTefBKPCS     := {}								// Guarda a transacao TEF Pendente da CLISITEF
Local nTB1COD	    := TamSX3("BI_COD")[1]				// Tamanho do campo B1_COD
Local cDigQtde	   	:= Alltrim(SuperGetMV("MV_FRTDIGQ",,"")) 	//Digito separador de quantidade x produto
Local nTL2QUANT	    := TamSX3("L2_QUANT")[1]		  			// Tamanho do campo B1_COD

DEFAULT lFRTAuto	:= .F.

// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If !AmIIn(12,23,72)
	Return(.F.)
EndIf

Private cImpressora
Private cPorta
Private cCliente 
Private cLojaCli
Private cVendLoja

Private oDlgFRT
Private oMensagem
Private	cMensagem   := STR0001	// "   Protheus Front Loja"
Private lF7			:= .F.
Private _lOK		:= .F.
Private lResume		:= .F.											// Retomar a Venda do Ponto em Que Parou???
Private lOcioso		:= .T.											// Nao Esta fazendo NENHUMA VENDA. (Nenhum Cupom Aberto)
Private lRecebe     := .F.											// Esta realizando Recebimento de Parcelas
Private lLocked		:= .F.											// Solicitado Travamento Pelo Server. (CARGA)
Private lCXAberto	:= .F.											// Caixa Esta FECHADO
Private lDescIT		:= .T.											// Indica se o item atual JA TEVE DESCONTO
Private lDescITReg	:= .F.											// Indica se permite desconto apos o registro do item
Private aDadosVen	:= {{"",0}}
Private aDadosSan	:= {{"",0}}
Private aTefDados	:= {}
Private cSimbCheq   := AllTrim(MVCHEQUE)
Private dDataCN	    := dDataBase  // Data utilizada como referencia durante utilizacao da Condicao Negociada
Private nVlrFSD     := 0
Private nVlrDescTot	:= 0											// VALOR DO DESCONTO
Private nVlrPercTot	:= 0											// PERCENTUAL DE DESCONTO
Private nVlrPercAcr	:= 0											// PERCENTUAL DE ACRESCIMO
Private nVlrAcreTot	:= 0											// VALOR DO ACRESCIMO
Private nVlrDescCPg	:= 0											// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)
Private nNumParcs   := 0                                            // NUMERO DE PARCELAS
Private nVlrPercOri := 0                                            // PERCENTUAL DE DESCONTO ORIGINAL
Private nQtdeItOri  := 0											// QTDE ORIGINAL DE ITENS DA VENDA       
Private lTTefAberto := .F.

//Variaveis criadas pelo Depto de Localizacoes
Private aMoeda     := {}
Private aSimbs     := {}
Private cMoeda     := ""
Private cSimbCor   := AllTrim(SuperGetMV("MV_SIMB1"))
Private nMoedaCor  := 1
Private nDecimais  := MsDecimais(nMoedaCor)
Private nTaxaMoeda := 1
Private oMoedaCor
Private oTaxaMoeda
Private oTemp3
Private oTemp4
Private oTemp5
Private lBalanca
//Estas variaveis contem, respectivamente, o numero do cartao, cpf ou contrato, informados na tela de recebimentos
//no LOJXREC.
Private cRecCart   := ""
Private cRecCPF    := ""
Private cRecCont   := ""

Private lVisuSint  := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Private aNCCItens  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel utilizada para a nova DLL Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public oAutocom

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta os Helps.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaHelp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao que cria o objeto oAutocom         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaAutocom()             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica compatibilidade entre o campo L4_FORMAID e MV_TEFMULT. Se o parametro estiver .T., o campo deve existir |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTefMult .AND. !lVisuSint
   CriaAutocom()
   //"Há uma incompatibilidade na funcionalidade Múltiplas Transações TEF."		
   //"Com o parâmetro MV_TEFMULT habilitado, o campo L4_FORMAID deve estar criado no dicionário de dados."
   //"Verifique com o Administrador do sistema para desabilitar o parâmetro ou criar o campo."		
   MsgStop(STR0304 + CRLF + STR0305 + CRLF + STR0306)
   Return (.F.)
EndIf

If cPaisLoc <> "BRA"
	/////////////////////////////////////////////////////////////////////////////////
	//O array aDadosJur armazena os resultados do calculo dos juros ou desconto    //
	//financeiro sendo que o mesmo eh valorizado na funcao Lj010RecVB, que se      //
	//encontra no Loja010c.prw                                                     //
    /////////////////////////////////////////////////////////////////////////////////
	//Descricao do Array                                                           //
	//aDadosJur[1] => Total do acrescimo                                           //
	//aDadosJur[2] => Valor Liquido da Venda                                       //
	//aDadosJur[3] => Valor Base da Venda                                          //
	//aDadosJur[4] => Valor total dos impostos                                     //
	//aDadosJur[5] => Total de desconto                                            //
	//aDadosJur[6] => Valor anterior do imposto                                    //
	//aDadosJur[7] => Taxa de juros			                                       // 
	//aDadosJur[8] => Percentual de desconto                                       //	 
	//aDadosJur[9] => Valor do desconto financeiro                                 //	
	/////////////////////////////////////////////////////////////////////////////////	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      Descric„o do array aImpsSL1          ³
	//ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³Posicao³ Descric„o						  ³
	//ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³  1	  ³ Codigo do imposto                 ³
	//³  2	  ³ Campo do valor do imposto no SL1  ³
	//³  3	  ³ Valor do imposto                  ³
	//³  4	  ³ Campo da base do imposto no SL1   ³
	//³  5	  ³ Base do imposto                   ³
	//³  6	  ³ Imposto incrementa na NF          ³
	//³  7	  ³ Aliquota do imposto               ³
	//ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      Descric„o do array aImpsSL2           ³
	//ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³Posicao ³ Descric„o						   ³
	//ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³   1	   ³ Codigo do produto                 ³
	//³   2	   ³ TES                               ³
	//³   3,1  ³ Codigo do imposto                 ³
	//³   3,2  ³ Aliquota do imposto               ³
	//³   3,3  ³ Base do imposto                   ³
	//³   3,4  ³ Valor do imposto                  ³
	//³   3,5  ³ Soma na dupl/Soma na NF/Cred.custo³
	//³   3,6  ³ Cpo grav. valor do imposto no item³
	//³   3,7  ³ Cpo grav. base do imposto no item ³
	//³   3,8  ³ Cpo grav. valor do imposto no cab.³
	//³   3,9  ³ Cpo grav. base do imposto no cab. ³
	//³   3,10 ³ {1,-1,0}                          ³
	//³   3,11 ³ Quantidade                        ³
	//³   3,12 ³ Valor unitario                    ³
	//³   4	   ³ Item                              ³
	//³   5	   ³ Registro cancelado                ³
	//³   6	   ³ Quantidade                        ³
	//³   7	   ³ Valor unitario                    ³
	//ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      Descric„o do array aTotVen           ³
	//ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³Posicao³ Descric„o						  ³
	//ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³  1	  ³ Ordem da moeda                    ³
	//³  2	  ³ Nome da moeda                     ³
	//³  3	  ³ Valor da venda em n moedas        ³
	//³  4	  ³ Deve calcular em outra moeda      ³
	//ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	Private lTroca 	 := .F.
	Private lValTot  := SuperGetMV("MV_VALTOTA")  	//Verifica se valida ou nao o total da fatura com o que foi pago
	Private lRecalImp:= .F.                  		//Verifica se foi recalculado os impostos devido 
	                                         		//a um desconto ou acrescimo

	Private aImpsSL1  := {}
	Private aImpsSL2  := {}
	Private aImpsProd := {}   //Array original com as mesmas informacoes do aImpsSL2. Usado para os recalculos. 
	Private aImpVarDup:= {}
	Private aTotVen   := {}
	Private aCols     := {}
	Private aHeader   := {}
	Private aDadosJur := {0,0,0,0,0,0,0,0,0}
	Private aCProva   := {}    

	Private cCalcImpV:= SuperGetMV("MV_GERIMPV")

	Private nTotalAcrs := 0	

	Private bQtdLostFoc := {|| Nil}	
	Private bCodLostFoc := {|| Nil}
	Private bCodGotFoc  := {|| Nil}                  
	
	For nX := 1 To MoedFin()             
		If(!(Empty(SuperGetMV("MV_MOEDA"+STR(nX,1),.F.,"") ) ) )	    
	    	LjCriaSimb(nX)
	     	AAdd(aMoeda,SuperGetMV("MV_MOEDA"+Ltrim(Str(nX))))			   
	     	AAdd(aSimbs,SuperGetMV("MV_SIMB"+Ltrim(Str(nX))))
	     	If (nX <> nMoedaCor) .AND. (RecMoeda(dDataBase,nX) > 0)
	     		AAdd(aTotVen,{nX,SuperGetMV("MV_MOEDA"+Ltrim(Str(nX))),0,.F.})
	     	EndIf			   
	  	EndIf
   	Next nX
EndIf   

FRTChkModo()														// Realiza a Checagem do Modo do SB1 e SBI

xNumCaixa()
DbSelectArea("SLF")
DbSetOrder(1)
DbSeek(xFilial("SLF")+SA6->A6_COD)
cStrAcesso := LF_ACESSO
If Empty(cEstacao)
	Help(" ",1,"NOESTACAO")
	cEstacao := "001"
EndIf
DbSelectArea("SLG")
If !DbSeek(xFilial("SLG")+cEstacao)
	Help(" ",1,"NOESTACAO")
EndIf
cImpressora	:= LjGetStation("IMPFISC")
cPorta		:= LjGetStation("PORTIF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Se Foi Chamado Pelo SIGAFRT.PRW. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTAuto

	If ! (LjGetProfile("FRTAUTO") == "S")

		If LjGetProfile("MULTIMI") == "S"
			LJ060Vis("SBI", 0)
		EndIf

		Return(NIL)

	EndIf

EndIf
lFRTAuto := (LjGetProfile("FRTAUTO") == "S")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Usuario no SA6 e Verifica Permissao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjxDChkVenda(.F.)
	If lFRTAuto										// Entrada Automatica, Saida Automatica.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza o Job FRTA020, Quando For TwoTier ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    FRT2Tier()
	EndIf
	Return(NIL)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Permissao "Usa Imp. Fiscal" - #3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFiscal := LJProfile(3)
If !lFiscal
	HELP(" ",1,"FRT002")	// "Usuário sem permissão para usar impressora fiscal.", "Atenção"
	If lFRTAuto										// Entrada Automatica, Saida Automatica.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza o Job FRTA020, Quando For TwoTier ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    FRT2Tier()
	EndIf
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se M0_ESTCOB esta preenchido para a validacao referente a legislacao  |
//| de acordo com cada estado 													   | 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(SM0->M0_ESTCOB)
   //"Foi detectado que o campo referente ao estado de cobranca(M0_ESTCOB) nao esta configurado."
   //"Solicite ao Administrador para configurar o arquivo sigamat.emp."
   MsgStop(STR0321 + chr(13) + chr(10) + STR0322)
   Return (NIL)      
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o repositorio de imagens esta ok. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJMsgRun(STR0215,, {|oDlg| FRTChkBMP(oDlg)})	// "Aguarde. Verificando repositório de imagens..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Leitor de CMC7 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaCmc7:= !Empty(LJGetStation("CMC7")) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Impressora de Cheque  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaCH	:= !Empty(LJGetStation("IMPCHQ"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Gaveta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lGaveta	:= !Empty(LjGetStation('GAVETA'))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Leitor Optico Serial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaLeitor := !Empty(LjGetStation('OPTICO'))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Balanca Serial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBalanca := SLG->(FieldPos("LG_PORTBAL")) > 0 .AND. !Empty(LjGetStation('BALANCA')+LjGetStation('PORTBAL'))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display Torre ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lUsaDispTor := !Empty(LjGetStation("DISPTOR"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Intervalo Para Verificacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRPCInt := LjGetStation("RPCINT")
nRPCInt := If(nRPCInt=0, 5, nRPCInt)

cDoc		:= Space(TamSX3("L1_DOC")[1])
cHora		:= Left(Time(),TamSX3("L1_HORA")[1])
cPDV		:= "    "
cProduto	:= Space(TamSX3("BI_DESC")[1])
nQuant		:= 1
nTmpQuant	:= 1
cUnidade	:= "UN"
nVlrUnit	:= 0
nVlrItem	:= 0
nTotItens	:= 0
nVlrTotal	:= 0
nVlrBruto	:= 0
nValIPI		:= 0
nLastTotal	:= 0
nLastItem	:= 0
If CrdxInt()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FrtSetCrd()
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usa Recebimento de Conta no FrontLoja. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJUSARC")
	nTamCodProd := TamSX3("L2_BCONTA")[1]
ElseIf !Empty(cDigQtde)
	nTamCodProd := nTB1COD + nTL2QUANT
Else
	nTamCodProd := nTB1COD
EndIf
cCodProd	:= Space(nTamCodProd)
cCupom		:= ""
aItens		:= {}
aTEFPend    := {}
aBckTEFMult := {}
nVlrMerc    := 0
lVerTEFPend := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define cliente com o padrao do parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Vendedor como o padrao definido no parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamSX3  := Len(SA3->A3_COD)
cVendLoja:= Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSX3),nTamSX3)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera os valores de desconto                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrDescIT := 0
nVlrPercIT := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o Sist.para trabalhar com TEF                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTefOk  := .F.
lUsaTef := LJProFile(2) 
cTipTEF := LjGetStation("TIPTEF")   

If lUsaTEF .AND. cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF
    CriaAutocom()
	If cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF
		aPinPad:=LJGetStation({"PINPAD","PORTPAD"})
		nHdlPinPad:=PinPadAbr(aPinPad[1],aPinPad[2])
	EndIf
	If cTipTEF == TEF_CLISITEF
	    CriaAutocom()
		If SLG->(FieldPos("LG_IPSITEF")) == 0
			// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
			MsgStop(STR0295+"LG_IPSITEF.", STR0003)
			lUsaTEF := .F.
		EndIf
		If SL4->(FieldPos("L4_FORMAID")) == 0
			// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
			MsgStop(STR0295+"L4_FORMAID.", STR0003)
			lUsaTEF := .F.
		EndIf
		If !lUsaTEF .OR. ChkAutocom() == DLL_SIGALOJA	// Verifica o parametro MV_AUTOCOM
			// "Para utilizar o TEF na modalidade CliSiTEF, é necessário configurar corretamente o " "Atenção"
			MsgStop(STR0295+" MV_AUTOCOM.", STR0003)
			lUsaTEF := .F.
		Else
			oTEF 	:= LJTEFAbre()	    				//Prepara o objeto TEF e carrega as variáveis necessárias para a utilização do TEF
			lUsaTef := oTef:lAtivo						//Indica se a abertura de terminal foi processada com sucesso
		EndIf				
	Else
		lUsaTef :=LOJA010T( "A"    ,NIL    ,NIL    ,NIL    ,;
		                     NIL   ,NIL    ,NIL    ,NIL    )
		CriaAutocom()
	EndIf		
Else
	lUsaTef := .F.
EndIf

DEFINE MSDIALOG oDlgFRT FROM 0,0 TO 453,637 PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) ;
	COLOR CLR_WHITE,CLR_GRAY
	oDlgFRT:bGotFocus := {|| oCodProd:SetFocus()}

	DEFINE TIMER oTimer INTERVAL nRPCInt*1000 ACTION FRTTimer() OF oDlgFRT

	If GetRemoteType() <> REMOTE_LINUX	   				// Caso a plataforma seja Windows mantem o tamanho da Fonte do Cupom da Tela.
	
		DEFINE FONT oFntCupom	NAME "Courier New"	   	SIZE 7,19			// Cupom Fiscal
		DEFINE FONT oFntMoeda   NAME "Courier New"     	SIZE 8,16 BOLD      // Total da venda em varias moedas
		DEFINE FONT oFntInf		NAME "Arial" 			SIZE 8,16 BOLD		// Doc., Data, Hora, Loja, PDV
		DEFINE FONT oFntGet		NAME "Arial" 			SIZE 14,38			// Produto, Preco
		DEFINE FONT oFntQuant	NAME "Arial" 			SIZE 10,25			// Quant.
		DEFINE FONT oFntTotal	NAME "Arial" 			SIZE 19,60 BOLD		// Valor Total
		DEFINE FONT oFntLoc		NAME "Arial" 			SIZE 6,13           // Doc.(Localizacoes)
		
     Else                                                // Caso a plataforma seja Linux diminui o tamanho da Fonte do Cupom da Tela.
     	
		DEFINE FONT oFntCupom	NAME "Courier New"	   	SIZE 3,15			// Cupom Fiscal
		DEFINE FONT oFntMoeda   NAME "Courier New"     	SIZE 4,12 BOLD      // Total da venda em varias moedas
		DEFINE FONT oFntInf		NAME "Arial" 			SIZE 4,12 BOLD		// Doc., Data, Hora, Loja, PDV
		DEFINE FONT oFntGet		NAME "Arial" 			SIZE 10,34			// Produto, Preco
		DEFINE FONT oFntQuant	NAME "Arial" 			SIZE 6,21			// Quant.
		DEFINE FONT oFntTotal	NAME "Arial" 			SIZE 15,56 BOLD		// Valor Total
		DEFINE FONT oFntLoc		NAME "Arial" 			SIZE 2,9           // Doc.(Localizacoes)
	
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Espaco Reservado ao Logotipo da Empresa
	@ 0, 0 REPOSITORY oLogoEmp SIZE 160,80 PIXEL NO BORDER OF oDlgFRT
	ShowBitMap(oLogoEmp,"LOGOFRONT")

	// Quantidade x Preco
	@ 110,  3 TO 135, 160 LABEL STR0006 PIXEL	// "Quantidade x Preco"
	@ 115,  5 SAY oTemp1   VAR "" PIXEL SIZE 154,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp1:lTransparent := .F.
	@ 120,  5 SAY oQuant   VAR nQuant   FONT oFntQuant PIXEL RIGHT SIZE 49,13 COLOR CLR_WHITE,CLR_BLACK ;
				  PICTURE PesqPictQt("L2_QUANT",7)
	oQuant:lTransparent := .F.
	@ 115, 54 SAY oUnidade VAR cUnidade PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oUnidade:lTransparent := .F.
	@ 115, 64 SAY oTemp2   VAR "x" FONT oFntGet PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp2:lTransparent := .F.
	@ 115, 74 SAY oTemp3 VAR cSimbCor PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp3:lTransparent := .F.
	@ 115, 84 SAY oVlrUnit VAR Transform(nVlrUnit,PesqPict("SBI", "BI_PRV",10,nMoedaCor));
	FONT oFntGet PIXEL RIGHT SIZE  75,18 COLOR CLR_WHITE,CLR_BLACK
	oVlrUnit:lTransparent := .F.

	// Get Quantidade
	@ 15,170 MSGET oTmpQuant VAR nTmpQuant FONT oFntQuant PIXEL SIZE  50,17 COLOR CLR_WHITE,CLR_BLACK ;
					PICTURE PesqPictQt("L2_QUANT",7) NOBORDER
					oTmpQuant:cSx1Hlp:="L2_QUANT"
	oTmpQuant:Disable()
	
	// "A quantidade deve ser um valor maior que 0." ### "Atenção"
	oTmpQuant:bLostFocus := {|| lF7:=.F., If(nTmpQuant>0,(nQuant:=nTmpQuant, If (lUsaDisplay, ;
			 					DisplayEnv(StatDisplay(), "1E" + STR0138 + Str(nTmpQuant,5,2) ), )),;
			 					(HELP(' ',1,'FRT045'),nTmpQuant:=1)),;
								oQuant:Refresh(), oTmpQuant:nTop:=30, oTmpQuant:nLeft:=340,;
								oTmpQuant:Disable(), oTmpQuant:Refresh()} 
	If cPaisLoc == "POR"
		bQtdLostFoc := oTmpQuant:bLostFocus
	EndIf

	// Produto
	@  80,  3 TO 105, 160 LABEL STR0005 PIXEL	// "Produto"
	@  85,  5 SAY oProduto VAR cProduto FONT oFntGet PIXEL SIZE 154,18 COLOR CLR_WHITE,CLR_BLACK
	oProduto:lTransparent := .F.
	@ 221, 78 MSGET oCodProd VAR cCodProd FONT oFntGet PIXEL SIZE 84,17 COLOR CLR_WHITE,CLR_BLACK ;
					PICTURE PesqPict("SBI","BI_COD",15) F3 "FRT" NOBORDER
					oCodProd:cSx1Hlp:="L2_PRODUTO"

    If cPaisLoc == "BRA"
		oCodProd:bLostFocus := {|| If(!_lOK.AND.!Empty(cCodProd),(_lOK:=.T.,aKeyAux:=FrtSetKey(),FRTProdOk(,,,.T.),FRTInitIt(.T.),If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "2E"+ STR0254 + cCodProd), DisplayEnv(StatDisplay(), "1E"+ " ")),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),), }					// "Codigo do Produto: "									 
	Else   
        oCodProd:bLostFocus := {|| If(!_lOK .AND. !Empty(cCodProd),(_lOK:=.T.,aKeyAux:=FrtSetKey(),If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),FRTProdOk(,,,.T.),If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),FrtSetKey(aKeyAux),_lOK:=.F.),)}	
    EndIf
	oCodProd:bGotFocus  := {|| If(lUsaLeitor , LeitorFoco(nHdlLeitor,.T.), nil), ;
							   If(lUsaDisplay, ; 
							      Eval( { || DisplayEnv(StatDisplay(), "2E"+ STR0254), ;
							                 If(lCXAberto .AND. !Empty(cCodProd),DisplayEnv(StatDisplay(), "1E" + Substr(cProduto,1,10) + " " + ;
								             Str(nQuant,5,2) + " " + Str(nVlrUnit,10,2) + " " + Str(nVlrItem,10,2) ), Nil) } ), nil ),;
							      FRTInitIt() }
	
	If cPaisLoc == "POR"
		bCodLostFoc := oCodProd:bLostFocus
		bCodGotFoc  := oCodProd:bGotFocus
	EndIf

	// Total do Item
	@ 140,  3 TO 165, 160 LABEL STR0007 PIXEL	// "Total do Item"
	@ 145,  5 SAY oTemp4 VAR cSimbCor FONT oFntInf PIXEL SIZE 15,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp4:lTransparent := .F.
	@ 145, 20 SAY oVlrItem VAR Transform(nVlrItem,PesqPict("SL2", "L2_VLRITEM",11,nMoedaCor));
	FONT oFntGet PIXEL RIGHT SIZE 139,18 COLOR CLR_WHITE,CLR_BLACK
	oVlrItem:lTransparent := .F.

	// Foto do Produto
	@ 169, 3 REPOSITORY oFotoProd SIZE 70,70 PIXEL NO BORDER OF oDlgFRT
	oFotoProd:SetColor(GetSysColor(15),GetSysColor(15))
	oFotoProd:lStretch := .T.
	oFotoProd:lVisible := .T.
	ShowBitMap(oFotoProd,"LOJAWIN")

	// Informacoes
	@ 168, 78 TO 215, 160 PIXEL
	@ 172, 151 BITMAP oOnOffLine RESOURCE IIf(!FRTSemaStat("CON", cEstacao),"FRTOFFLINE","FRTONLINE") ;
								 	PIXEL SIZE 16,16 NOBORDER OF oDlgFRT

	@ 173,  82 SAY STR0008			PIXEL SIZE 30,8		// "Documento:"
	@ 181,  82 SAY STR0009			PIXEL SIZE 18,8		// "Data:"
	@ 189,  82 SAY STR0010			PIXEL SIZE 15,8		// "Hora:"
	@ 197,  82 SAY STR0011			PIXEL SIZE 22,8		// "Filial:"
	@ 197, 120 SAY STR0012			PIXEL SIZE 13,8		// "PDV:"
	@ 205,  82 SAY STR0058			PIXEL SIZE 30,8		// "Usuário:"
	If cPaisLoc == "BRA"
	   @ 173, 115 SAY oDoc VAR cDoc	PIXEL SIZE 35,8 FONT oFntInf
	Else 
	   @ 174, 112 SAY oDoc VAR cDoc	PIXEL SIZE 45,8 FONT oFntLoc  //Para suportar ate 12 caracteres na tela	  
	EndIf
	@ 181, 100 SAY DToC(dDataBase)	PIXEL SIZE 50,8 FONT oFntInf
	@ 189, 100 SAY oHora VAR cHora	PIXEL SIZE 50,8 FONT oFntInf
	@ 197, 107 SAY cFilAnt			PIXEL SIZE 12,8 FONT oFntInf
	@ 197, 134 SAY oPDV VAR cPDV	PIXEL SIZE 25,8 FONT oFntInf
	cCaixa := AllTrim(cUserName)+" - "+xNumCaixa()
	@ 205, 107 SAY cCaixa			PIXEL SIZE 52,8

	// Cupom Fiscal
	If cPaisLoc == "BRA"
		@ 1, 165 LISTBOX oCupom VAR cCupom SIZE 152,164 PIXEL FONT oFntCupom	ITEMS aCupom OF oDlgFRT
	Else
		@ 1, 165 LISTBOX oCupom VAR cCupom SIZE 152,134 PIXEL FONT oFntCupom	ITEMS aCupom OF oDlgFRT
	EndIf
	oCupom:bGotFocus  := {|| oCodProd:SetFocus()}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Moeda/Taxa          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		@ 140, 165 TO 165, 318 LABEL STR0149 PIXEL  // Moeda da Venda
                                                        
  		cMoeda := aMoeda[Int(nMoedaCor)]
		@ 145,169 SAY STR0145 SIZE 22, 07 OF oDlgFRT PIXEL         //"Moeda"
		@ 152,169 SAY oMoedaCor VAR cMoeda SIZE 50,07 FONT oFntInf OF oDlgFRT PIXEL
		
		@ 145,237 SAY STR0146 SIZE 22, 07 OF oDlgFRT PIXEL    //"Taxa"
		@ 152,237 SAY oTaxaMoeda VAR nTaxaMoeda Picture PesqPict("SL1","L1_TXMOEDA") SIZE 50,07 FONT oFntInf OF oDlgFRT PIXEL
	EndIf

	// Total Parcial
	@ 168, 165 TO 215, 318 LABEL STR0013 PIXEL	// "Total Parcial"
	@ 173, 169 SAY STR0014 PIXEL SIZE 42,8		// "Numero de Itens:"
	@ 173, 215 SAY oTotItens VAR nTotItens FONT oFntInf   PIXEL SIZE 20,33
	@ 173, 258 SAY STR0015 PIXEL SIZE 32,8		// "Desconto:"
	@ 173, 285 SAY oDesconto VAR nVlrPercIT FONT oFntInf  PIXEL RIGHT SIZE 32,8 PICTURE "@R 99.99%"
	@ 180, 167 SAY oTemp5 VAR cSimbCor FONT oFntInf PIXEL SIZE 15,33 COLOR CLR_WHITE,CLR_BLACK
	oTemp5:lTransparent := .F.
	@ 180, 182 SAY oVlrTotal VAR Transform(nVlrTotal,PesqPict("SL1", "L1_VLRTOT",15,nMoedaCor));
	FONT oFntTotal PIXEL RIGHT SIZE 135,33 COLOR CLR_WHITE,CLR_BLACK
	oVlrTotal:lTransparent := .F.

	// Area de Mensagens
	@ 221, 166 SAY oMensagem VAR cMensagem FONT oFntGet PIXEL SIZE 332,18 COLOR CLR_WHITE,CLR_BLACK
	oMensagem:lTransparent := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Teclas de Atalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FRTSetKey({	{|| FRTAbreCX()},;																		// F4  - Abre Caixa
				{|| FRTFechaCX()},;																		// F5  - Fecha Caixa
				{|| FRTDescIT()},;																		// F6  - Desconto no Item
				{|| lF7:=.T., FRTInitIT(), FRTEditQtd()},;												// F7  - Altera Quantidade
				{|| FRTCancIT()},;																	  	// F8  - Cancelamento do Item
				{|| FRTFimVend( NIL, NIL, cNCartao, @lTefPendCS	,@aTefBKPCS, @cCodDEP, @cNomeDEP )},; 	// F9  - Finaliza Venda (Sub-Total)
				{|| FRTAltCli( @cNCartao, @cCodDEP, @cNomeDEP )},;									   	// F10 - Alteracao de Clientes
				{|| FRTAltVend()},;																		// F11 - Alteracao de Vendedores
				{|| FRTFuncoes( @lTefPendCS, @aTefBKPCS )},;											// F12 - Funcoes Diversas (Funcao)
				,,,,,,,,,,,,,,,,,,,;
				{|| If(ExistBlock("FRTCTRLT"),ExecBlock("FRTCTRLT",.F.,.F.),)},;
				{|| If(ExistBlock("FRTCTRLU"),ExecBlock("FRTCTRLU",.F.,.F.),)},;
				{|| If(ExistBlock("FRTCTRLV"),ExecBlock("FRTCTRLV",.F.,.F.),)},;
				{|| If(ExistBlock("FRTCTRLW"),ExecBlock("FRTCTRLW",.F.,.F.),)},;
				,;
				,;
				{|| FRTLoadOrc()} })									// CTRL+Z - Carregamento de Orcamentos
// "Aguarde. Abrindo a Impressora Fiscal " ### "..."

oDlgFRT:bStart := { || LJMsgRun(STR0056 + AllTrim(cImpressora) + "...",, { || FRTStart() }), ;
                       iIf( lUsaDisplay, ( DisplayEnv(StatDisplay(), "2E" + STR0254), DisplayEnv(StatDisplay(), "1E ") ), Nil ), ;
                       iIf( lExitNow, oDlgFRT:End(), Nil ) } 	

ACTIVATE MSDIALOG oDlgFRT VALID FRTConfExit()

FRTSetKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o Caixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCXAberto
	cx_abre_fecha(SA6->A6_COD, "F")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento da Impressora Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHdlECF <> -1
	IFFechar(nHdlECF, cPorta)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento da Impressora de Cheque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaCH
	CHFechar( nHdlCH, LJGetStation("PORTCHQ") )
EndIf

If lUsaTEF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fecha arquivo de controle de numeracao TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    L010ClTermTef()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do CMC7 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaCMC7
    CMC7Fec(nHdlCMC7, AllTrim(LJGetStation("PORTMC7")) )
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Leitor Optico Serial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaLeitor
    LeitorFec(nHdlLeitor,LJGetStation("PORTOPT"))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento da Balanca Serial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If StatBalanca()[1]
    BalancaFec(StatBalanca()[2],LJGetStation("PORTBAL"))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento da Gaveta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGaveta .AND. !Empty(LJGetStation("PORTGAV")) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
    GavetaFec(nHdlGaveta,LJGetStation("PORTGAV"))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaDisplay
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Finalizacao no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDisplay(2)
    DisplayFec(StatDisplay(), AllTrim(LJGetStation("PORTDIS")) )
EndIf   

If lUsaDispTor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Finalizacao no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDispTor(2)
    DispTorFec(StatDispTor(), AllTrim(LJGetStation("PORTTOR")) )
EndIf 

If lFRTAuto										// Entrada Automatica, Saida Automatica.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o Job FRTA020, Quando For TwoTier ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    FRT2Tier()
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRT2Tier ³ Autor ³ Vendas Clientes       ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                     					        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA010()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT2Tier
If AllTrim(GetPvProfString("Config", "TwoTier", "0", GetClientDir()+Left(GetAdv97(),3)+"RMT.INI")) == "1"
	FRTGeraSLI(Space(4), Space(3), "ENDTHREAD", "SOBREPOE")
	LjMsgRun(STR0159,, {|| FRTWait2T()})	// "Aguarde, finalizando conexão com o Servidor..."
EndIf
FRTCloseServices()

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTWait2T ³ Autor ³ Vendas Clientes       ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                     					        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA010()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTWait2T
Local nTimeOut := 30                                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao realizar PMC no DbSeek³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SLI->(DbSeek(xFilial("SLI")+"       "))
	While .T. .AND. nTimeOut>0
		If SLI->(DbSeek(xFilial("SLI")+"       "))
			If Left(SLI->LI_MSG,2)=="OK"
				Exit
			EndIf
		Else
			Exit
		EndIf
		Sleep(1000)
		nTimeOut--
	End
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTHora   ³ Autor ³ Vendas Clientes       ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a Hora e eventualmente o Numero do Cupom		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTHora( lDoc, lConsulta )
Local aParam := {}                      

DEFAULT lDoc 	  := .F.                   
DEFAULT lConsulta := .T.

cHora := Left( Time(), TamSX3("L1_HORA")[1] )
oHora:Refresh()
If lDoc .AND. nHdlECF <> -1
	If IFPegCupom(nHdlECF, @cDoc) == 0		// Pega o Numero do Cupom
		If ExistBlock("FRTNUMCF")
			AaDD(aParam, cDoc) //numero original do cupom fiscal 
			AaDD(aParam, lConsulta) //indica se e leitura ou gravacao
			cDoc := ExecBlock("FRTNUMCF",.F.,.F.,aParam) //numero com 6 digitos 
		EndIf
		cDoc := PadR(cDoc, Len(SL1->L1_DOC))
		oDoc:Refresh()
	EndIf
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTResume ³ Autor ³ Vendas Clientes       ³ Data ³09/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retomar a Venda do Ponto Que Parou						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Static Function FRTResume
Local nI												// Contador
Local cAlias	 	:= Alias() 							// Alias
Local nOrder	 	:= SL1->(IndexOrd())				// Ordem
Local nRecno	 	:= 0								// Recno
Local aCupom											// Cupom
Local cRet		 	:= " "								// Retorno da funcao
Local cTemp		 	:= ""     							// Temporario
//Variaveis utilizadas no calculo dos impostos variaveis - Localizacoes
Local aImposto   	:= {}								// Impostos
Local aImps      	:= {}								// Impostos
Local nValImp    	:= 0								// Valor impostos
Local nTotImp    	:= 0								// Total de impostos
Local nVlrItem   	:= 0								// Valor do item
Local nDescUni   	:= 0								// Desconto
Local nVlIcmRet  	:= 0 							// Valor do ICM Retido para ser somado junto ao item
Local cVlIcmRet  	:= 0 							// Valor do ICM Retido para ser impresso no cupom fiscal 

Local lFRTCODB2t 	:= ExistTemplate( "FRTCODB2" )	// Verifica se existe o ponto de entrada de template FRTCODB2
Local lFRTCODB3t 	:= ExistTemplate( "FRTCODB3" )	// Verifica se existe o ponto de entrada de template FRTCODB3
Local lT_FrtResume	:= ExistTemplate( "FRTRESUME" )	// Verifica se existe o ponto de entrada de template FRTRESUME
Local aRetTplResume := {}							// Retorno do template function FRTRESUME
Local nDedIcmsIt    := 0                            // Valor da deducao do ICMS de um item da venda
Local nTB1COD	    := TamSX3("BI_COD")[1]				// Tamanho do campo B1_COD
Local nTB1CODBAR    := TamSX3("BI_CODBAR")[1] 			// Tamanho do campo B1_CODBAR
Local cCliCGC		:= ""								// CGC do cliente da Venda
Local nCodANVISA	:= 0	      						// ID de Identificacao de produto controlado. (ANVISA)
Local cProdLocal   	:= ""								// Codigo ou codigo de barras do produto
Local cMvCodBar	   	:= SuperGetMv("MV_CODBAR",,"N")		// Variavel com parametro para impressao do codigo de barras no cupom
          
Private nItem := 0

lResume := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Detectar Registros Nao Finalizados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
DbSetOrder(9)
DbSeek(xFilial("SL1")+"01", .T.)
If !EOF() .AND. L1_SITUA >= "01" .AND. L1_SITUA <= "99"
	lResume := .T.
	If cPaisLoc <> "BRA"
		nMoedaCor := SL1->L1_MOEDA
		cMoeda    := AllTrim(SuperGetMV("MV_MOEDA"+Str(nMoedaCor,1)))
		oMoedaCor:Refresh()
		
		nTaxaMoeda := SL1->L1_TXMOEDA
		oTaxaMoeda:Refresh()

		cSimbCor := AllTrim(SuperGetMV("MV_SIMB"+Str(nMoedaCor,1)))
		oTemp3:Refresh()
	EndIf
EndIf   
IF lResume .AND.;
	SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE")) .AND. ;
	! Empty(SLI->LI_MSG) .AND.;
	! SLI->LI_USUARIO == cUserName
	// Existe um cupom do caixa:
	// para ser recuperado. Acesse o sistema com esse caixa para concluir a operacao
	MsgInfo(STR0140+AllTrim(SLI->LI_USUARIO)+STR0141)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o Job FRTA020, Quando For TwoTier ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    FRT2Tier()
ENDIF

If lResume
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o cadastro de clientes. Faz isto fora do laco no SL2 para fazer  ³
	//³ uma unica vez.                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(SL1->L1_CLIENTE+SL1->L1_LOJA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define cliente com o padrao do parametro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTamSXG   := TamSXG("001")[1]	// Grupo de Cliente
		cCliente  := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
		nTamSXG   := TamSXG("002")[1]	// Grupo de Loja
		cLojaCli  := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
		nTamSXG   := Len(SA3->A3_COD)
		cVendLoja := Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSXG),nTamSXG)				
	Else
		cCliente  := SL1->L1_CLIENTE
		cLojaCli  := SL1->L1_LOJA
		cVendLoja := SL1->L1_VEND		
	Endif
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para tratamento do cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lT_FrtResume
		aRetTplResume := ExecTemplate( "FRTRESUME", .F., .F., { cCliente, cLojaCli } )
		If ValType( aRetTplResume ) == "A" .AND. Len( aRetTplResume ) >= 1
			uCliTpl	:= aRetTplResume[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a aCrdCliente com as informacoes do cliente para nao ser soli-³
			//³ citada novamente na finalizacao da venda.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCrdCliente[1] := SA1->A1_CGC
		Endif
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Detectar Troca de ECF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lResume .AND. L1_PDV <> cPDV
	//	"Foi detectada a troca do ECF " ### " pelo ECF " ### ". Os items impressos no outro ECF deverão ser cancelados. "
	//	"Caso deseje reimprimir o cupom clique em OK, caso contrário, este cupom será cancelado.", "Atenção"
	If MsgYesNo(STR0016 + AllTrim(L1_PDV) + STR0017 + AllTrim(cPDV) + STR0018 + STR0019, STR0003)
		nRet := IFStatus(nHdlECF, "8", @cRet)	  			// Verifica Reducao Z
		If nRet == 10
			// "Não foi feita a Redução Z neste ECF. O cupom na base de dados será cancelado.", "Atenção"
			HELP(' ',1,'FRT005')
			FRTCancela()
			lResume := .F.
		ElseIf nRet == 0
			nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
			If nRet == 7
				// "Existe um cupom em aberto neste ECF. O cupom na base de dados será cancelado.", "Atenção"
				HELP(" ",1,"FRT003")
				FRTCancela()
				lResume := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finaliza o Job FRTA020, Quando For TwoTier ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    FRT2Tier()
			ElseIf nRet == 0
				nRet := IFAbreCup(nHdlECF,@cCliCGC)
				lFechaCup := .T.

				If nRet <> 0
					// "Não foi possível realizar a abertura do cupom. O cupom na base de dados será cancelado.", "Atenção"
			   		HELP(" ",1,"FRT004")
					FRTCancela()
					lResume := .F.
				Else
					DbSelectArea("SL2")
					DbSetOrder(1)
					DbSeek(xFilial("SL2")+SL1->L1_NUM)
					While L2_FILIAL+L2_NUM == xFilial("SL2")+SL1->L1_NUM
						SBI->(DbSeek(xFilial("SBI")+SL2->L2_PRODUTO))
						cCodProd := SBI->BI_COD
						cCodBar  := SBI->BI_CODBAR
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAux := {FRTLastIT()+1, cCodProd, cCodBar, "", "", "", "", "", "", "", .F.}
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existe a chamado do Ponto de Entrada³
						//³criado pela equipe de Templates                 ³
						//³Template Drogaria                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFRTCODB2t
							aAdd(aAux,uProdTPL)
							aAdd(aAux,uCliTPL)
							
							aAux := ExecTemplate( "FRTCODB2", .F., .F., { aAux, uProdTPL, uCliTPL } )
							cCodProd := Padr( aAux[2], nTB1COD )				
							cCodBar  := Padr( aAux[3], nTB1CODBAR )				
							If ValType( aAux[13] ) == "A"
								uProdTPL := aClone( aAux[13] )
							Else
								uProdTPL := aAux[13]
							Endif
							If ValType( aAux[14] ) == "A"
								uCliTPL  := aClone( aAux[14] )
							Else
								uCliTPL  := aAux[14]
							Endif
						EndIf
						If ExistBlock("FRTCODB2")
							aAux := ExecBlock("FRTCODB2",.F.,.F.,aAux)
							cCodProd := Padr(aAux[2],nTB1COD)
							cCodBar  := Padr(aAux[3],nTB1CODBAR)
						EndIf

						//Realiza o acerto do Arquivo SL2 caso a venda possua desconto
						//no total ou acrescimo...		
						If (cPaisLoc <> "BRA") .AND. ((L2_VLRITEM < L2_PRCTAB) .OR. (L2_VLRITEM > L2_PRCTAB))
							nVlrItem := ((L2_PRCTAB*L2_QUANT)-L2_VALDESC)
							nDescUni := Round(L2_VALDESC/L2_QUANT,nDecimais)
											
							aSL2 := {	{"L2_DESCPRO",	0},;
							         	{"L2_VLRITEM", nVlrItem},;
							         	{"L2_VRUNIT" , nVlrItem/L2_QUANT}}
							         	
							FRTGeraSL("SL2", aSL2, .F.)
						EndIf

						MaFisIni(	SA1->A1_COD,	SA1->A1_LOJA,	"C",	"S",;
									SA1->A1_TIPO,	NIL,			NIL,	.F.,;
									"SBI",			NIL,			"01",	NIL,;
									NIL,			NIL,			NIL,	NIL,;
									NIL,			NIL,			.F.)
						MaFisAdd(	cCodProd,		L2_TES,		L2_QUANT,		L2_VRUNIT,;
									IIf(cPaisLoc=="BRA", L2_VALDESC, 0),		"",			"",				nil,;
									0,				0,			0,				0,;
									L2_VLRITEM,		0)
						SF4->(DbSeek(xFilial("SF4")+MaFisRet(1,"IT_TES")))
						nDedIcmsIt  := 0
						If cPaisLoc == "BRA"
							If SF4->F4_ISS == "S"
								cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
							Else
								If SBI->BI_PICMRET > 0  .AND. SA1->A1_TIPO $ SuperGetMV("MV_TPSOLCF") .AND. SF4->F4_BSICMST <> 100
									cAliquota := "F"
								ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
									cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
								Elseif SF4->F4_LFICM == "I"
									cAliquota := "I"					// Isento
									If SF4->F4_AGREG == "D"            // Deducao de ICMS  
									   nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
									   nTotDedIcms += nDedIcmsIt																		
									Endif   
								Elseif SF4->F4_LFICM == "N"
									cAliquota := "N"					// N„o sujeito a ICMS
								Else
									cAliquota := "T" + Str(MaFisRet(1,"IT_ALIQICM"),5,2)
								Endif
							Endif
						Else
							nTotImp  := 0
					 	    aImps    := TesImpInf(MaFisRet(1,"IT_TES"))
						    Aadd(aImpsSL2,{cCodProd,MaFisRet(1,"IT_TES"),{}})
						    For nI := 1 to Len(aImps)                                                 
						    	If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
						        	AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
						     		nE := Len(aImpsSL1)
						       	EndIf   
						       	cIndImp  := Substr(aImps[nI][2],10,1)               
						       	cCampoVal:= "IT_VALIV"+cIndImp		    
						       	cCampoAlq:= "IT_ALIQIV"+cIndImp	 
						       	nValImp  := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
							   	FRTGeraImp(@aImposto,aImps[nI],nValImp,L2_QUANT,L2_VRUNIT,1,cIndImp)			   
							   	AAdd(aImpsSL2[Len(aImpsSL2)][3],aClone(aImposto))
							   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
							   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
							   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
						    Next nI
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_ITEM)				
           					AAdd(aImpsSL2[Len(aImpsSL2)],.F.)				   	           					      
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_QUANT)				
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_VRUNIT)				   	           					                 					
   							nVlrMerc  += (L2_VRUNIT * L2_QUANT)
				            nVlrItem  := ((L2_VRUNIT * L2_QUANT)+nTotImp)
						    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
							FrtTotVen()
							FRTSimACols(cCodProd,L2_QUANT,L2_VRUNIT,L2_TES,L2_CF,L2_ITEM)
							AAdd(aImpsProd,aClone(aImpsSL2[Len(aImpsSL2)]))
						Endif   
						MaFisEnd()

						nDec := TamSX3("L2_QUANT")[2]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ P.E. Para Tratamento dos Dados Que Serao Impressos no Cupom. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPaisLoc == "BRA"
							aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem + L2_VALDESC, .F., "", 0, SBI->BI_UM}
						Else
							aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem , .F., "", 0, SBI->BI_UM}
						EndIf   
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existe a chamado do Ponto de Entrada³
						//³criado pela equipe de Templates                 ³
						//³Template Drogaria                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFRTCODB3t
							If cPaisLoc == "BRA"
								aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem + L2_VALDESC, .F., "", 0, SBI->BI_UM,uProdTPL,uCliTPL}
							Else
								aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem , .F., "", 0, SBI->BI_UM,uProdTPL,uCliTPL}
							EndIf							
							aAux := ExecTemplate("FRTCODB3",.F.,.F.,{aAux,uProdTPL,uCliTPL})
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³valorizando variaveis do tipo STATIC³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
							If ValType( aAux[13] ) == "A"
								uProdTPL := aClone(aAux[13])
							Else
								uProdTPL := aAux[13]
							Endif
							
							If ValType( aAux[14] ) == "A"
								uCliTPL  := aClone(aAux[14])
							Else
								uCliTPL  := aAux[14]
							Endif
							
						EndIf
						If ExistBlock("FRTCODB3")
							aAux := ExecBlock("FRTCODB3",.F.,.F.,aAux)
						EndIf

						If cMvCodBar == "S" .AND. !Empty(aAux[2])
			            	cProdLocal := aAux[2]
			   			Else
			   				cProdLocal := aAux[1]
			   			EndIf
                        
						nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(cProdLocal),13),cProdLocal), aAux[3], AllTrim(Str(aAux[4],7,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
										  AllTrim(Str(aAux[6],14,2)), aAux[7],AllTrim(Str(aAux[8],14,2)), aAux[12])
						If nRet <> 0
							// "Não foi possível reimprimir o cupom. O cupom na base de dados será cancelado.", "Atenção"
							HELP(' ',1,'FRT006')
							FRTCancela()
							lResume := .F.
        				EndIf
						dbSkip()
					End
					cCodProd := Space(nTB1COD)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualizando o SL1 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSL1 := {	{	"L1_EMISSAO", 	dDataBase				}, ;
							 	{	"L1_DTLIM"	,	dDataBase				}, ;
							 	{	"L1_EMISNF"	,	dDataBase				}, ;
							 	{	"L1_DOC"	,	cDoc					}, ;
							 	{	"L1_NUMCFIS",	cDoc					}, ;
							 	{	"L1_SERIE"	,	LJGetStation("SERIE")	}, ;
							 	{	"L1_PDV"	,	cPDV					}, ;
							 	{	"L1_OPERADO",	xNumCaixa()				}, ;
							 	{	"L1_VEND"	,	cVendLoja				}, ;							 	
							 	{	"L1_HORA"	,	cHora					} }

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o campo L1_CGCCLI caso trabalhe com ³
					//³Nota Fiscal Paulista                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If LjAnalisaLeg(30)[1]
						If SL1->(FieldPos("L1_CGCCLI")) > 0					
							Aadd(aSL1,{ "L1_CGCCLI" , cCliCGC } )
						EndIf
    				EndIf

					FRTGeraSL("SL1", aSL1, .F.)
					DbSeek(xFilial("SL2")+SL1->L1_NUM)
					While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !EOF()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualizando o SL2 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aSL2 := {	{	"L2_DOC"	, SL1->L1_DOC     }, ;
									{	"L2_SERIE"	, SL1->L1_SERIE   }, ;
								 	{	"L2_PDV"	, SL1->L1_PDV     }, ;
								 	{	"L2_EMISSAO", SL1->L1_EMISSAO } }
						FRTGeraSL("SL2", aSL2, .F.)
						dbSkip()
					End
				EndIf
			EndIf
		EndIf
 	Else
		FRTCancela()
		lResume := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Detectar Cupom Aberto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lResume
	nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
	If nRet <> 7
		// "O ECF não está com o cupom aberto. Este cupom será cancelado.", "Atenção"
		HELP(' ',1,'FRT007')
		FRTCancela()
		lResume := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar a Situacao do Cupom ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lResume
	If SL1->L1_SITUA == "01"								// "01" - Abertura do Cupom Nao Impressa
		nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
		If nRet <> 7
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelar a Abertura do Cupom ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTCancela(.T., .F., .F.)					// Deleta Somente o SL1
			lResume := .F.
		EndIf
	ElseIf SL1->L1_SITUA == "07"							// "07" - Solicitado o Cancelamento do Cupom
		// "Foi solicitado o Cancelamento do Cupom Fiscal. Ele foi realmente cancelado?", "Atenção"
		If MsgYesNo(STR0025, STR0003)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega os dados do SL1 antes de deleta-lo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLiMsg := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV
			FRTCancela()
			FRTGeraSLI("    ", "CAN", cLiMsg, "NOVO")		// Envia Para o Server Caso Tenha Sido Baixado
			lResume := .F.
		Else												// Volta ao normal
			FRTCancela(.F., .F., .T.)						// Deleta Somente o SL4
			aSL1 := {{"L1_SITUA",	"04"}}					// "04" - Impresso o Item
			FRTGeraSL("SL1", aSL1)
			lResume := .T.
		EndIf
	ElseIf SL1->L1_SITUA == "09"							// "09" - Encerrado SL1 (Nao gerado SL4)
		FRTRollB04()
		lResume := .T.
	ElseIf SL1->L1_SITUA == "10"							// "10" - Encerrado a Venda
		// "Foi solicitado o Fechamento do Cupom Fiscal. Ele foi realmente finalizado?", "Atenção"
		If MsgYesNo(STR0026, STR0003)
			aSL1 := {{"L1_SITUA",	"00"}}					// "00" - Venda Efetuada com Sucesso
			FRTGeraSL("SL1", aSL1)
		Else
			FRTRollB04()
			lResume := .T.
		EndIf
	EndIf
	If lResume
		lOcioso := .F.											// Abriu um Cupom

		aCupom := {	"",	"", "", "", "", ;
					"", "", "", "", "", ;
					"",	"",	"",	"",	"", ;
					"",	"",	""	}

		If ExistBlock("FRTCLICHE")
			aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
			AEval(aFRTCliche, {|x| AAdd(aCupom, Left(x,40))})
		Else
			AAdd(aCupom, "")
			AAdd(aCupom, STR0027)	// "        MICROSIGA SOFTWARE S.A.         "
			AAdd(aCupom, STR0028)	// "    Av. Braz Leme, 1399 - São Paulo     "
			AAdd(aCupom, STR0029)	// "          www.microsiga.com.br          "
		EndIf
		AAdd(aCupom, DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+cDoc)	// "  PDV:" "   COD:"
		AAdd(aCupom, FRT_SEPARATOR)
		AAdd(aCupom, PADC(STR0032,40))	// "        C U P O M   F I S C A L         "
		AAdd(aCupom, "")
		AAdd(aCupom, STR0033)	// "ITEM   CÓDIGO           DESCRIÇãO       "
		AAdd(aCupom, (STR0034  + "("+cSimbCor+")"))           // "      QTDxUNITARIO    ST     VALOR( SIMBOLO ) "
		AAdd(aCupom, FRT_SEPARATOR)

		aItens := {}
		cOrcam := SL1->L1_NUM

		If SL1->L1_SITUA == "01"								// "01" - Abertura do Cupom Nao Impressa
			aSL1 := { 	{"L1_NUMCFIS"	,	cDoc }, ;
						{"L1_DOC"		, 	cDoc }, ;
					 	{"L1_SITUA"		,	"02" } }			// "02" - Impresso a Abertura do Cupom
			FRTGeraSL("SL1", aSL1)
		EndIf

		SBI->(DbSetOrder(1))
		DbSelectArea("SL2")
		DbSetOrder(1)	
		DbSeek(xFilial("SL2")+cOrcam)
		While L2_FILIAL+L2_NUM == xFilial("SL2")+cOrcam
			If SL2->L2_SITUA == "03"							// "03" - Item Nao Impresso
				// "Foi solicitado a impressão do item " ### ". Ele foi realmente impresso?", "Atenção"
				If MsgYesNo(STR0035+StrZero(FRTPegaIT(L2_ITEM),3,0)+STR0036, STR0003)
					aSL2 := {{"L2_SITUA",	"04"}}				// "04" - Impresso o Item
					FRTGeraSL("SL2", aSL2)
					aSL1 := {{"L1_SITUA",	"04"}}				// "04" - Impresso o Item
					FRTGeraSL("SL1", aSL1)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar o Item ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SL2")
					RecLock("SL2", .F.)
					dbDelete()
					MsUnLock()
					dbSkip()
					Loop
				EndIf
			ElseIf SL2->L2_SITUA == "05"						// "05" - Solicitado o Cancelamento do Item
				// "Foi solicitado o cancelamento do item " ### ". Ele foi realmente cancelado?", "Atenção"
				If MsgYesNo(STR0037+StrZero(FRTPegaIT(L2_ITEM),3,0)+STR0038, STR0003)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar o Item ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SL2")
					RecLock("SL2", .F.)
					dbDelete()
					MsUnLock()
					dbSkip()
					Loop
				Else
					aSL2 := {{"L2_SITUA",	"04"}}				// "04" - Impresso o Item
					FRTGeraSL("SL2", aSL2)
					aSL1 := {{"L1_SITUA",	"04"}}				// "04" - Impresso o Item
					FRTGeraSL("SL1", aSL1)
				EndIf
			EndIf
			SBI->(DbSeek(xFilial("SBI")+SL2->L2_PRODUTO))
			cCodProd := SBI->BI_COD
			cCodBar  := SBI->BI_CODBAR

			//Realiza o acerto do Arquivo SL2 caso a venda possua desconto
			//no total ou acrescimo...		
			If (cPaisLoc <> "BRA") .AND. ((L2_VLRITEM < L2_PRCTAB) .OR. (L2_VLRITEM > L2_PRCTAB))
				nVlrItem := ((L2_PRCTAB*L2_QUANT)-L2_VALDESC)
				nDescUni := Round(L2_VALDESC/L2_QUANT,nDecimais)
								
				aSL2 := {	{"L2_DESCPRO",	0},;
				         	{"L2_VLRITEM", nVlrItem},;
				         	{"L2_VRUNIT" , nVlrItem/L2_QUANT}}
				         	
				FRTGeraSL("SL2", aSL2, .F.)
			EndIf

			MaFisIni(	SA1->A1_COD,	SA1->A1_LOJA,	"C",	"S",;
						SA1->A1_TIPO,	nil,			nil,	.F.,;
						"SBI",			nil,			"01",	NIL,;
						NIL,			NIL,			NIL,	NIL,;
						NIL,			NIL,			.F.)
			MaFisAdd(	cCodProd,		L2_TES,		L2_QUANT,		L2_VRUNIT,;
						IIf(cPaisLoc=="BRA", L2_VALDESC, 0),		"",			"",				nil,;
						0,				0,			0,				0,;
						L2_VLRITEM,		0)
			nVlIcmRet := MaFisRet(1,"IT_VALSOL") // ICMS Retido
			
			SF4->(DbSeek(xFilial("SF4")+MaFisRet(1,"IT_TES")))
			nDedIcmsIt  := 0
			
			If cPaisLoc == "BRA"
				If SF4->F4_ISS == "S"
					cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
				Else
					If SBI->BI_PICMRET > 0 .AND. SA1->A1_TIPO $ SuperGetMV("MV_TPSOLCF") .AND. SF4->F4_BSICMST <> 100
						cAliquota := "F"
					ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
						cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
					Elseif SF4->F4_LFICM == "I"
						cAliquota := "I"					// Isento
						If SF4->F4_AGREG == "D"            // Deducao de ICMS
					       nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
					       nTotDedIcms += nDedIcmsIt																					
					    Endif   
					Elseif SF4->F4_LFICM == "N"
						cAliquota := "N"					// N„o sujeito a ICMS
					Else
						cAliquota := "T" + Str(MaFisRet(1,"IT_ALIQICM"),5,2)
					Endif
				Endif
			Else
				nTotImp  := 0
		 	    aImps    := TesImpInf(MaFisRet(1,"IT_TES"))
			    Aadd(aImpsSL2,{cCodProd,MaFisRet(1,"IT_TES"),{}})
			    For nI := 1 to Len(aImps)                                                 
			    	If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
			        	AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
			          	nE := Len(aImpsSL1)
			       	EndIf   
			       	cIndImp  := Substr(aImps[nI][2],10,1)               
			       	cCampoVal:= "IT_VALIV"+cIndImp		    
			       	cCampoAlq:= "IT_ALIQIV"+cIndImp	 
			       	nValImp  := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
				   	FRTGeraImp(@aImposto,aImps[nI],nValImp,L2_QUANT,L2_VRUNIT,1,cIndImp)			   
				   	AAdd(aImpsSL2[Len(aImpsSL2)][3],aClone(aImposto))
				   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
				   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
				   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
			    Next nI      
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_ITEM)				
	           	AAdd(aImpsSL2[Len(aImpsSL2)],.F.)						           	
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_QUANT)				
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_VRUNIT)						           		           	
   				nVlrMerc  += (L2_VRUNIT * L2_QUANT)
	            nVlrItem  := ((L2_VRUNIT * L2_QUANT)+nTotImp)
			    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
			Endif
			MaFisEnd()

			If SF4->F4_INCSOL == 'S' 
				nVlrTotal	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + nVlIcmRet,nVlrItem)
				nVlrBruto	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + nVlIcmRet,nVlrItem)
				cVlIcmRet  := Transform(nVlIcmRet,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
			Else
				nVlrTotal	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI,nVlrItem)
				nVlrBruto	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI,nVlrItem)
				cVlIcmRet  	:= Transform(0,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
			End
			nItem		:= FRTPegaIT(L2_ITEM)
			nTotItens++
			cQuant     := PadL(Trans(L2_QUANT, If(L2_QUANT-Int(L2_QUANT)==0, "999999999", PesqPictQt("L2_QUANT",9))),9)
			cVlrUnit   := PadR(AllTrim(Trans(L2_VRUNIT+If(cPaisLoc<>"BRA",(nTotImp/L2_QUANT),0),PesqPict("SBI", "BI_PRV",9,nMoedaCor))),9)
			cVlrItem   := Transform(If(cPaisLoc=="BRA",L2_VLRITEM+L2_VALIPI,nVlrItem),PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))
		    cVlrPercIT := Transform(L2_DESC,"@R 99.99%")
			cValIPIIT  := Transform(L2_VALIPI,PesqPict("SL2", "L2_VALIPI" , 13,nMoedaCor))
			nCodANVISA := nItem
			
			//Executa a funcao para calculo do total da venda em diversas moedas e
			//simula um aCols...
			If cPaisLoc <> "BRA"
				FrtTotVen()
				FRTSimACols(cCodProd,L2_QUANT,L2_VRUNIT,SF4->F4_CODIGO,SF4->F4_CF,L2_ITEM)
				AAdd(aImpsProd,aClone(aImpsSL2[Len(aImpsSL2)]))
			EndIf	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAux := {	nItem 		, cCodProd	, cCodBar	, L2_DESCRI	, ;
						cQuant		, cVlrUnit	, cAliquota	, cVlrItem	, ;
						cVlrPercIT	, cValIPIIT	, .F.		, cVlIcmRet	}
			If lFRTCODB2t
				aAdd(aAux,uProdTPL)
				aAdd(aAux,uCliTPL)				
				
				aAux := ExecTemplate( "FRTCODB2", .F., .F., { aAux, uProdTPL, uCliTPL } )
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)       
				If ValType( aAux[13] ) == "A"
					uProdTPL := aClone( aAux[13] )
				Else
					uProdTPL := aAux[13]
				Endif
				If ValType( aAux[14] ) == "A"
					uCliTPL  := aClone( aAux[14] )
				Else
					uCliTPL  := aAux[14]
				Endif
			EndIf
			If ExistBlock("FRTCODB2")
				aAux := ExecBlock("FRTCODB2",.F.,.F.,aAux)
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)
			EndIf
			AAdd(aItens, { nItem      , cCodProd  , cCodBar    , L2_DESCRI  ,;
			               L2_QUANT   , L2_VRUNIT , L2_VLRITEM , L2_VALDESC  ,;
			               cAliquota  , L2_VALIPI , .F.        , If (SF4->F4_INCSOL == 'S',nVlIcmRet,0),;
		                   nDedIcmsIt , nCodANVISA })

			If cMvCodBar == "S" .AND. !Empty(aAux[3])
            	cProdLocal := aAux[3]
   			Else
   				cProdLocal := aAux[2]
   			EndIf		                   

			AAdd(aCupom, StrZero(aAux[1],3)+" "+Left(cProdLocal,13)+" "+Left(aAux[4],21) )
			
			If cPaisLoc == "BRA"
				AAdd(aCupom, aAux[5]+"x"+aAux[6]+PadR(aAux[7],6)+"%"+aAux[8] )
			Else
				AAdd(aCupom, aAux[5]+"x"+aAux[6]+Space(06)+aAux[8] )       
			EndIf
			If L2_DESC > 0 
				AAdd(aCupom, STR0039+aAux[9])	// "Desconto de :  "
			Endif
			If L2_VALIPI > 0 
				AAdd(aCupom, "IPI: "+aAux[10])
			Endif
			If nVlIcmRet > 0 .AND. SF4->F4_INCSOL == 'S'  
				AAdd(aCupom, "ICMS Retido: "+aAux[12])
			EndIf

			nRecno := Recno()
			
			dbSkip()
		End
		If nRecno > 0
			dbGoTo(nRecno)
			cProduto := SBI->BI_DESC
			cUnidade := SL2->L2_UM
			nQuant   := SL2->L2_QUANT
			nVlrUnit := SL2->L2_VRUNIT
			nVlrItem := If(cPaisLoc=="BRA",SL2->L2_VLRITEM + SL2->L2_VALIPI + nVlIcmRet,nVlrItem)
			If Empty(SBI->BI_BITMAP)
				ShowBitMap(oFotoProd, "LOJAWIN")
			Else
				ShowBitMap(oFotoProd, AllTrim(SBI->BI_BITMAP))
			EndIf
			oProduto:Refresh()
			oUnidade:Refresh()
			oQuant:Refresh()
			oVlrUnit:Refresh()
			oVlrItem:Refresh()
			oVlrTotal:Refresh()
			oTotItens:Refresh()
			oDesconto:Refresh()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IFStatus(nHdlECF, "12", @cRet) == 0
			IFNumItem(nHdlECF, @cTemp)
			If Val(cTemp) == nTotItens
				IFSubTotal(nHdlECF, @cTemp)
				If Val(cTemp)/100 <> nVlrTotal
					// "Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Atenção"
					HELP(' ',1,'FRT008')
				EndIf
			Else
				// "Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Atenção"
				HELP(' ',1,'FRT008')
			EndIf
		EndIf
		cCodProd := Space(nTB1COD)
		oCupom:SetArray(aCupom)
		oCupom:GoBottom()
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Como nao houve retomada, verifica Reducao Z ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IFStatus(nHdlECF, "8", @cRet) == 10			  			// Verifica Reducao Z
		// "Não foi realizado o Fechamento do ECF no dia anterior. Deseja realizá-lo agora?", "Atenção"
		If MsgYesNo(STR0040, STR0003)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Permissao "Redução Z" - #6 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LJProFile(6)
				lRet := LojA160()
				If !lRet 
					// "Não foi possível realizar o Fechamento do ECF. O Sistema será finalizado." ###, "Atenção"
					MsgStop(STR0041, STR0003)
					// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
					lExitNow := .T.
					Return(NIL)
				Else
					nRet := IFAbrECF(nHdlECF)
					If nRet <> 0
						// "Não foi possível realizar a Abertura do ECF. O Sistema será finalizado. Erro: " ###, "Atenção"
						MsgStop(STR0042+Str(nRet,2,0), STR0003)
						// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
						lExitNow := .T.
						Return(NIL)
					EndIf
				EndIf
			Else
				// "Usuário sem permissão para fechar o ECF. O sistema será finalizado.", "Atenção"
				HELP(' ',1,'FRT009')
				// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
				lExitNow := .T.
				Return(NIL)
			EndIf
		Else
			// "É necessário fechar o ECF no dia anterior. O sistema será finalizado.", "Atenção"
			HELP(' ',1,'FRT010')
			// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
			lExitNow := .T.
			Return(NIL)
		EndIf
	EndIf
EndIf
SL1->(DbSetOrder(nOrder))
DbSelectArea(cAlias)

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTProdOK ³ Autor ³ Vendas Clientes       ³ Data ³14/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a Validacao do Produto e Registra o Item			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                         
Function FRTProdOK( cOrc, nNumItem, cChkProduto, lF3 )
Local lRet			:= .F.
Local nRet        	:= Nil
Local cRet			:= ""
Local lFoco			:= .F.
Local cAliquota		:= Nil
Local cTES			:= Nil
Local cCF			:= Nil
Local cQuant		:= Nil
Local cVlrUnit		:= Nil
Local cVlrItem		:= Nil
Local nDec			:= Nil
Local aSL1			:= Nil
Local aSL2			:= Nil
Local cFRTCodB		:= Nil
Local aTmpProd		:= Nil
Local nMaxElem		:= 1
Local nX			:= Nil
Local nI			:= Nil
Local nE        	:= Nil
Local nY			:= Nil
Local cIndImp 		:= Nil
Local cCampoVal		:= ""
Local cCampoAlq		:= ""
Local aImps			:= {}
Local aImposto		:= {}
Local nValImp		:= 0
Local nTotImp		:= 0          
Local cLocal     	:= Nil
Local cTabela		:= Nil
Local oDlgErro		:= Nil
Local oFntErro		:= Nil
Local lLeitor		:= .F.
Local nMoedaTab		:= 1 											// Moeda da tabela de preco - Localizacoes
Local nDecPDesc		:= TAMSX3("L2_DESC")[2]							// Qtde de casas decimais do % de Desconto
Local nTent			:= 0
Local nPercITOld	:= Nil
Local nDescITOld	:= Nil
Local nVlIcmRet    	:= 0 											// Valor do ICM Retido para ser somado junto ao item
Local cVlIcmRet    	:= 0 											// Valor do ICM Retido para ser impresso no cupom fiscal 
Local nSaveSx8 	   	:= GetSx8Len()
Local lStatusImp13 	:= .F.	   										// Status 13 do ECF. Indica se o ECF arredonda (.T.) ou trunca (.F.) o valor total
Local aFRTKit	   	:= {}		   									// P.E. FRTKIT - Para Registrar Varios Produtos de uma vez (KIT)
Local nTamSXG      	:= 0                                    		
Local nTamItem     	:= 0           									// Tamanho do campo de item  
Local lConsulta    	:= .T.
Local lFRTProdOKt  	:= ExistTemplate("FRTProdOK")					// verifica se existe o PONTO DE ENTRADA FRTProdOK
Local lFRTKITt	   	:= ExistTemplate("FRTKIT")  					// verifica se existe o PONTO DE ENTRADA FRTKIT
Local lFRTDescITt  	:= ExistTemplate("FRTDescIT")					// verifica se existe o PONTO DE ENTRADA FRTDescIT
Local lFRTCODB2t   	:= ExistTemplate("FRTCODB2")					// verifica se existe o PONTO DE ENTRADA FRTCODB2
Local lFRTCODB3t   	:= ExistTemplate("FRTCODB3")			 		// verifica se existe o PONTO DE ENTRADA FRTCODB3
Local nDedIcmsIt   	:= 0                        			 		// Valor da deducao do ICMS de um item da venda
Local nTB1COD	   	:= TamSX3("BI_COD")[1]	  						// Tamanho do campo B1_COD
Local nTB1CODBAR   	:= TamSX3("BI_CODBAR")[1] 						// Tamanho do campo B1_CODBAR
Local lEntra		:= .T.	   				 						// Verifica se entra no alerta para aliquota nao cadastrada
Local nValPis		:= 0					  						// Valor do PIS por item
Local nValCof		:= 0					  						// Valor do COFINS por item
Local nValCsl		:= 0					 						// Valor do CSLL por item
Local nBasePS2		:= 0					  						// Valor da Base do PIS
Local nValPS2		:= 0					 						// Valor do PIS
Local nAliqPS2		:= 0					 						// Aliquota do PIS
Local nBaseCF2		:= 0					 						// Valor da Base do Cofins
Local nValCF2		:= 0					  						// Valor do Cofins
Local nAliqCF2		:= 0					   						// Aliquota do Cofins
Local cFormDesc  	:= SuperGetMV("MV_LJFORMD",.F.,"1" )			// Tipo de validacao do desconto (valor ou % / valor e %)
Local aDesc			:= { "V", 0 }									// Controle de descontos aplicados ao item para validacao
Local nPerDesc		:= 0											// Percentual de desconto (utilizado somente para validar desconto)
Local cCliCGC		:= ""											// CGC do cliente
Local nCodANVISA	:= 0	    						// ID de Identificacao de produto controlado. (ANVISA)
Local lCancANVISA	:= .F.								// Verifica se a tela da ANVISA foi cancelada
Local lZeraDesc     := SuperGetMV("MV_FTZRDES", ,.F.)				// Define se sera zerado o desconto no final da inclusao de cada item								// Verifica se a tela da ANVISA foi cancelada
Local cTesInt	    := ""											// Codigo do Tes de saida
Local cProdLocal   := ""											// Codigo ou codigo de barras do produto
Local cMvCodBar	   := SuperGetMv("MV_CODBAR",,"N")					// Variavel com parametro para impressao do codigo de barras no cupom
                                                            	
Private cCodProBal := SubStr(cCodProd,2,6)
Private cInfProBal := SubStr(cCodProd,8,5)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A variavel criada abaixo contem o codigo original do produto, e sera usada       ³
//³para verificar se o produto esta no padrao EAN-13. Foi criada como Private para  ³
//³tornar possivel o seu uso nos seguintes P.E.: FRTProdOK,FRTCODB1,FRTKIT,			³
//³FRTQUANT,FRTECF13,FRTDescIT,FRTCLICHE,FRTCODB2 e FRTCODB3                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCodProIni := cCodProd

DEFAULT cChkProduto := ""
DEFAULT lF3         := .F. //Se o produto foi inserido via F3, obtenho a variavel True para o
						   //controle da condicao de pagamento negociada abaixo (caso de orcamento)

If lRecebe
	Return(NIL)
EndIf

If ! CheckCaixa(@lCXAberto, @lUsaDisplay )							// Verifica se o Caixa Esta Aberto
	Return(.T.)								// E exibe Mensagem Caso Esteja Fechado
EndIf

If !lFechaCup 
	//"Erro no fechamento do cupom"
	//"É Necessário FECHAR a Venda ou CANCELAR este Cupom Fiscal."
	Aviso( STR0227 , STR0050 , {'&OK'})
	Return(.F.)
EndIf

// Verifica data e hora para registro de cada item.
// Requisito para Alagoas
If LjAnalisaLeg(31)[1]
   If !CheckIFData()
      Return( .F. )
   EndIf
Endif
If ValType(cOrc) == "C" .AND. Len(cOrc) > 0
	nVlrPercIt := 0
	nVlrDescIt := 0
	lOrc := .T.
	lImpOrc  := .T.
	cCodProd := FRTAField(cOrc, "L2_PRODUTO", nNumItem)
	cCliente := FRTAField(cOrc, "L1_CLIENTE")
	cLojaCli := FRTAField(cOrc, "L1_LOJA")
EndIf

If nVidaLink = 1  // Gravando VidaLink
	lOrc := .F.
	cCodProd := Posicione("SB1",5,xFilial("SB1")+ aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_CODIGOEAN ]  ,"B1_COD")  //Com o codigo de barra (EAN) pego o cod.prod.
	cCliente := aVidaLinkc[VDLNK_CABEC_CODCLI]
	cLojaCli := aVidaLinkc[VDLNK_CABEC_LOJA]
EndIf
If !Empty(cChkProduto)
	cCodProd := cChkProduto
Endif

If Empty(cCodProd)
	Return(.T.)
Else
	// lLeitor Identifica se o Codigo de Barras foi originado pelo Leitor Serial.
	// Utilizar o PE FRTCodB2 para manipular esta informacao.
	nI := At("|", cCodProd)
	If nI > 0
		cCodProd := PadR(Stuff(cCodProd, nI, 1, ""), nTB1COD)
		lLeitor := .T.
	EndIf
EndIf

nRet := IFStatus(nHdlECF, "9", @cRet)		// Verifico o Status do ECF
If nRet <> 0
	FRTTimer()
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	Return(.T.)
EndIf

If lGaveta
   While !lFoco       
      lFoco := .T.
	  If SLG->LG_GAVSTAT
		If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
			If GavetaStat(nHdlGaveta, LJGetStation("PORTGAV")) == 1
				lFoco := .F.				
			EndIf
		Else
			// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
			If IFStatus(nHdlECF, "14", "") == 1
				lFoco := .F.				
			EndIf
		EndIf
		If !lFoco
			// Desativa foco do Leitor se a gaveta estiver aberta 
			If lUsaLeitor
				LeitorFoco(nHdlLeitor,.F.)			
			EndIf
			// "Não é possível realizar vendas com a gaveta aberta. Favor fechá-la.", "Atenção"
				HELP(' ',1,'FRT012')
		EndIf			
	  Endif
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Validacao do "Recebimento de Conta" Deve Ser Realizada ³
//³ Dentro do PE "FRTProdOK".                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBCONTA := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa chamada do Template  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTProdOKt 
	aTmpProd := ExecTemplate("FRTProdOK",.F.,.F.,{cCodProd, nQuant})
	If ValType(aTmpProd) == "A"
		If Len(aTmpProd) >= 1
			If ValType(aTmpProd[1])== "C"
				cCodProd := Padr(aTmpProd[1],nTB1COD)
			EndIf
		EndIf
		If Len(aTmpProd) >= 2
			If ValType(aTmpProd[2])== "C"
				cBCONTA := PadR(aTmpProd[2],TamSX3("L2_BCONTA")[1])
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o Retorno do FRTProdOK Nao Seja Array,      ³
		//³ Eh Interpretado Que Devera Abandonar a Validacao ³
		//³ Voltando Para o Get.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Return(.T.)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE Generico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTProdOK")
	aTmpProd := ExecBlock("FRTProdOK",.F.,.F.,{cCodProd, nQuant})
	If ValType(aTmpProd) == "A"
		If Len(aTmpProd) >= 1
			If ValType(aTmpProd[1])== "C"
				cCodProd := Padr(aTmpProd[1],nTB1COD)
			EndIf
		EndIf
		If Len(aTmpProd) >= 2
			If ValType(aTmpProd[2])== "C"
				cBCONTA := PadR(aTmpProd[2],TamSX3("L2_BCONTA")[1])
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o Retorno do FRTProdOK Nao Seja Array,      ³
		//³ Eh Interpretado Que Devera Abandonar a Validacao ³
		//³ Voltando Para o Get.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Return(.T.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso for inserido mais um produto para um orcamento     ³
//³carregado no Front, (via F3) utilizar a seguinte regra: ³
//³                                                        ³
//³- Se for condicao de pagamento Negociada, limpar a array³
//³de condicao de pagamento (orcamento) para que na finali-³
//³zacao, seje informado novamente;                        ³
//³                                                        ³
//³16/09/2002 - Fernando Salvatori                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lF3 .AND. Len( aParcOrc ) > 0
	If cItemCOrc == "CN"
		aParcOrc    := {}		// Limpando parcelas 
		aParcOrcOld := {}
		cItemCOrc   := ""		// Limpando condicao de pagamento
	EndIf
	lImpNewIT   := .T.	 		// Indica se foi adicionado um novo item ao orcamento
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cCodProd = SBI->BI_COD    ³
//³ cCodBar  = SBI->BI_CODBAR ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodBar := cCodProd

lAchou := LJSB1SLK(@cCodProd,@nTmpQuant,.T.)
If ! lAchou
	If ExistBlock("FRTCODB1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o RDMake nao retornar "" deve estar posicionado no SBI correspondente. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFRTCodB := ExecBlock("FRTCODB1",.F.,.F.,{cCodProd})
		If !Empty(cFRTCodB)
			lAchou	:= .T.
			cCodProd	:= SBI->BI_COD
		EndIf
	EndIf
EndIf
If lAchou
	If ExistCPO("SBI", cCodProd)
		If ! SLK->(DbSeek(xFilial("SLK")+cCodBar))
			cCodBar	:= If(Empty(SBI->BI_CODBAR),cCodProd,SBI->BI_CODBAR)
		EndIF
		cCodProd	:= SBI->BI_COD
		cProduto	:= SBI->BI_DESC
		cUnidade	:= SBI->BI_UM
		// Se for alterado algum tratamento referente as variaveis setadas abaixo,
		// nao esquecer de revisar o PE FRTKIT (logo abaixo)
		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. nMoedaCor == 1)
			If lOrc
				nVlrUnit := FRTAField(cOrc, "L2_PRCTAB", nNumItem)
			Else
				If nVidaLink = 1  // Gravando VidaLink
					nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
				Else
					nVlrUnit := SBI->BI_PRV
				Endif
			EndIf
		Else
			If lOrc		
				nVlrUnit := Round(xMoeda(FRTAField(cOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
			Else                             
				If cPaisLoc == "BRA"
					nMoedaTab := 1
				Else
					nMoedaTab := SBI->BI_MOEDA
				EndIf
				If nVidaLink = 1  // Gravando VidaLink
					nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
				Else
					nVlrUnit := Round(xMoeda(SBI->BI_PRV,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
				Endif
			EndIf
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se a balanca trabalha por preco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto esta no padrao EAN-13 			   ³
		//³e se o primeiro digito eh 2 (padrao balanca)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
			nTmpQuant := Round(Val(cInfProBal)/100 / nVlrUnit,3)		// A Balanca Utiliza 3 Decimais!!!
		EndIf
		If lOrc
			nTmpQuant := FRTAField(cOrc, "L2_QUANT", nNumItem)
		EndIf
		If nVidaLink = 1  // Gravando VidaLink
			nTmpQuant := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_QUANTIDADE ]
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao especifica para atender a legislacao do SEFAZ ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjAnalisaLeg(12)[1]
			nVlrPercIT := 0
			nVlrDescIT := 0
		EndIf
	
		nValorReal := nVlrUnit  
		If cPaisloc="POR"           
			nMaxElem   := If( SBI->BI_MULT > 1, nQuant, 1) 
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se e' KIT de Produtos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFRTKit := LjInfoKit(cCodProd)							//Localizado no programa LOJXFUND.prw
		If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
			nMaxElem := Len(aFRTKit)
		Else
			aFRTKit := {}
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. Para Registrar Varios Produtos de uma vez (KIT) ³
		//³ Retorno: Array bidimensional com BI_COD e L2_QUANT   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFRTKITt
			aFRTKit := ExecTemplate("FRTKIT",.F.,.F.,{cCodProd,nTmpQuant})
			If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
				nMaxElem := Len(aFRTKit)
			Else
				aFRTKit := {}
			EndIf
		EndIf
		If ExistBlock("FRTKIT")
			aFRTKit := ExecBlock("FRTKIT",.F.,.F.,{cCodProd,nTmpQuant})
			If ValType(aFRTKit) == "A" .AND. Len(aFRTKit) >= 2
				nMaxElem := Len(aFRTKit)
			Else
				aFRTKit := {}
			EndIf
		EndIf
	
		For nX := 1 TO nMaxElem
			If Len(aFRTKit) > 0		
				If ! SBI->(DbSeek(xFilial("SBI")+aFRTKit[nX][1]))
					Loop
				EndIf
				nTmpQuant	:= aFRTKit[nX][2]
				cCodProd	:= SBI->BI_COD
				cProduto	:= SBI->BI_DESC
				cUnidade	:= SBI->BI_UM
				If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. nMoedaCor == 1)
					If lOrc
						nVlrUnit := FRTAField(cOrc, "L2_PRCTAB", nNumItem)
					Else
						If nVidaLink = 1  // Gravando VidaLink
							nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
						Else
							nVlrUnit := SBI->BI_PRV
						Endif
					EndIf
				Else
					If lOrc		
						nVlrUnit := Round(xMoeda(FRTAField(cOrc, "L2_PRCTAB", nNumItem),1,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					Else
						If nVidaLink = 1  // Gravando VidaLink
							nVlrUnit := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_PRECO ]
						Else
							nMoedaTab:= If(SBI->(FieldPos("BI_MOEDA"))>0,SBI->BI_MOEDA,1)
							nVlrUnit := Round(xMoeda(SBI->BI_PRV,nMoedaTab,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
						Endif
					EndIf
				EndIf		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a balanca trabalha por preco ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o produto esta no padrao EAN-13 			   ³
				//³e se o primeiro digito eh 2 (padrao balanca)            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
					nTmpQuant := Round(Val(cInfProBal)/100 / nVlrUnit,3)		// A Balanca Utiliza 3 Decimais!!!
				EndIf
				If lOrc
					nTmpQuant := FRTAField(cOrc, "L2_QUANT", nNumItem)
				EndIf
				If nVidaLink = 1  // Gravando VidaLink
					nTmpQuant := aVidaLinkD[VDLNK_DETALHE, nNumItem, VDLNK_QUANTIDADE ]
				EndIf			
			EndIf
	
			If cPaisloc == "POR"           
				If SBI->BI_MULT > 1
					aAux := FRTProdMult(nValorReal,Len(aItens)+1,nMaxElem)
					nTmpQuant := 1
					nVlrUnit  := Val( Str(aAux[2],10,2) )
					If Len(aAux) == 3
						cCodProd	:= aAux[3]
					EndIf
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Modificar a Quantidade e Valor Unitario ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTQUANT")
				aAux := ExecBlock("FRTQUANT",.F.,.F.,{nTmpQuant,nVlrUnit,nQuant,cBCONTA,nVlrTotal,cCodProIni})
				If ValType(aAux) == "A" .AND. Len(aAux) >= 2
					nTmpQuant := aAux[1]
					nVlrUnit  := aAux[2]
					If Len(aAux) == 3 
						cCodProd	:= aAux[3]
					Endif
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso o Retorno do FRTQuant Nao Seja Array,       ³
					//³ Eh Interpretado Que Devera Abandonar a Validacao ³
					//³ Voltando Para o Get.                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Return(.T.)
				EndIf
			EndIf
		
			SBI->(DbSetOrder(1))
			SBI->(DbSeek(xFilial("SBI")+cCodProd))
			
			cCodBar		:= If(Empty(SBI->BI_CODBAR),cCodProd,SBI->BI_CODBAR)
			cProduto	:= SBI->BI_DESC
			cUnidade	:= SBI->BI_UM
		
			nQuant		:= nTmpQuant
			               
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para indicar se o ECF faz o arredondamento (.T.) ou ³
			//³ truncamento (.F.) dos valores.                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTECF13")
			    lStatusImp13 := ExecBlock("FRTECF13",.F.,.F.,{cCodProd, nVlrUnit, nQuant})
			Else
				lStatusImp13 := (IFStatus(nHdlECF, "13", @cRet) == 0)		// Indica se arredonda (.T.) ou trunca (.F.) os valores
			Endif
			
			If !lStatusImp13  // Se o ECF Nao Tem Arredondamento
			    nVlrItem := NoRound(nQuant * nVlrUnit,nDecimais)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a balanca trabalha por preco ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o produto esta no padrao EAN-13 			   ³
				//³e se o primeiro digito eh 2 (padrao balanca)            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SBI->BI_BALANCA == "1" .AND. Len(Alltrim(cCodProIni)) == 13 .AND. Substr(cCodProIni,1,1) == "2"
					If nVlrItem <> Val(cInfProBal) / 100									// Se o calculo der diferenca,
						If NoRound((nQuant+.001)*nVlrUnit,2) == Val(cInfProBal)/100		// Tenta com UM grama a mais
							nQuant += .001													// Para que o valor do item seja
							nVlrItem := NoRound(nQuant * nVlrUnit, 2)						// o mesmo do codigo de barra.
						EndIf
					EndIf
				EndIf
			Else
			   nVlrItem:= A410Arred(nQuant * nVlrUnit,"D2_TOTAL")
			EndIf
			If lOrc
				nVlrPercIT	:= Round(FRTAField(cOrc, "L2_DESC", nNumItem), nDecPDesc)
			EndIf
			If nVidaLink = 1  // Gravando VidaLink
				nVlrPercIT	:= 0
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o percentual de desconto no caso de ter sido    ³
			//³digitado apenas o valor do desconto e nao o percentual  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrPercIT == 0 .AND. nVlrDescIT > 0
	   			nVlrPercIT 	:= (nVlrDescIT/nVlrItem) * 100
	   		EndIf
		
			If IFStatus(nHdlECF, "13", @cRet) <> 0// Se o ECF Nao Tem Arredondamento
				nVlrDescIT	:= NoRound(nVlrItem * (nVlrPercIT/100),nDecimais)
			Else
				nVlrDescIT	:= Round(nVlrItem * (nVlrPercIT/100),nDecimais)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PE para controlar o Desconto no Item. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFRTDescITt
				nPercITOld := nVlrPercIT			// Variavel que retorna o valor anterior
				nDescITOld := nVlrDescIT			// Variavel que retorna o valor anterior
				aRet := ExecTemplate("FRTDescIT",.F.,.F.,{ cCodProd, nVlrPercIT, nVlrDescIT, nVlrItem,;
														    uProdTPL, uCliTPL   , nQuant, nVlrUnit } )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Nesse caso, o desconto ja vem aplicado do orcamento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lImpOrc
					nVlrPercIT  := aRet[1]
					nVlrDescIT  := aRet[2]
				Endif

				uProdTPL    := aClone(aRet[3])
				
				If lImpOrc
					cCodPlano := FRTAField(cOrc, "L1_CPLFIDE")
				
					uCliTPL := Posicione("MHG",1,xFilial("MHG")+cCodPlano,"MHG_CODREG")
				Else
					uCliTPL := aRet[4]
				Endif   
				
				lCancANVISA := aRet[5]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a tela da ANVISA tenha sido cancelada,³
				//³o item nao pode ser registrado.            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCancANVISA 
					nVlrPercIT  := 0
					nVlrDescIT  := 0
					Return(.T.)
				Endif
			EndIf
			If ExistBlock("FRTDescIT")
				nPercITOld := nVlrPercIT			// Variavel que retorna o valor anterior
				nDescITOld := nVlrDescIT			// Variavel que retorna o valor anterior
				aRet := ExecBlock("FRTDescIT",.F.,.F.,{cCodProd, nVlrPercIT, nVlrDescIT, nVlrItem})
				nVlrPercIT := aRet[1]
				nVlrDescIT := aRet[2]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao da permissao do caixa para conceder descontos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cFormDesc == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Porcentagem³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
				If nVlrPercIT<>0             
					aDesc := { "P", nVlrPercIT }
				//ÚÄÄÄÄÄ¿
				//³Valor³
				//ÀÄÄÄÄÄÙ
				ElseIf nVlrDescIT<>0        
					aDesc := { "V", nVlrDescIT }
				EndIf	
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o percentual de desconto apenas para verificacao³
			//³da permissao do caixa, quando o valor foi informado e o ³
			//³percentual estiver como 0                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrDescIt > 0 .AND. nVlrPercIt == 0
				nPerDesc := (nVlrDescIt / nVlrItem) * 100
			Else
				nPerDesc := nVlrPercIT
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera o desconto se o valor do mesmo supera o   ³
			//³ valor do item a ser registrado.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrDescIt >= nVlrItem
				MsgAlert(STR0332,STR0003) //"O desconto será desconsiderado pois é maior ou igual ao valor do item.","Atenção"
		
				nPerDesc   := 0
				nVlrPercIT := 0
				nVlrDescIT := 0
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao do desconto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .AND. !lImpOrc    
				If !LJProfile(11, Nil, aDesc, nPerDesc, nVlrDescIT)
					If !(MsgYesNo(STR0333))			//"Deseja zerar o desconto e prosseguir na venda?"
						Return (lRet)
					Else
						nPerDesc 	:= 0
						nVlrPercIt 	:= 0
						nVlrDescIT 	:= 0
					EndIf
				Endif	
			Endif
			
			nVlrItem := nVlrItem - nVlrDescIT
			MaFisIni(	SA1->A1_COD,	SA1->A1_LOJA,	"C",	"S",;
						SA1->A1_TIPO,	NIL,			NIL,	.F.,;
						"SBI",			NIL,			"01",	NIL,;
						NIL,			NIL,			NIL,	NIL,;
						NIL,			NIL,			.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro da funcao MaTesInt               ³
			//³ExpN1 = Documento de 1-Entrada / 2-Saida   ³
			//³ExpC1 = Tipo de Operacao Tabela "DF" do SX5³
			//³ExpC2 = Codigo do Cliente ou Fornecedor    ³
			//³ExpC3 = Codigo do gracao E-Entrada         ³
			//³ExpC4 = Tipo de Operacao E-Entrada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTesInt := MaTesInt( 2	,"01"		,cCliente, cLojaCli,;
								 "C",SBI->BI_COD,NIL)						
			If !Empty(cTesInt)
				cBI_TS := cTesInt
			Else
				cBI_TS := If(Empty(SBI->BI_TS), SuperGetMV("MV_TESSAI"), SBI->BI_TS)
			Endif
			If lOrc
				cBI_TS := FRTAField(cOrc, "L2_TES", nNumItem)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O valor do desconto eh somado ao Total do Produto, ³
			//³pois o desconto ja eh tratado pela funcao fiscal.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAdd(	SBI->BI_COD,	cBI_TS,		nQuant,		nVlrUnit,;
						IIf(cPaisLoc=="BRA", nVlrDescIt, 0),	"",		"",		0,;
						0,		0,		0,		0,;
						nVlrItem + IIf(cPaisLoc=="BRA", nVlrDescIt, 0),	0)
			cTES      := MaFisRet(1, "IT_TES"    )
			cCF       := MaFisRet(1, "IT_CF"     )
			nVlIcmRet := MaFisRet(1, "IT_VALSOL" )
			If lOrc
				cCF := FRTAField(cOrc, "L2_CF", nNumItem)
			EndIf
			nValIPIIT := MaFisRet(1, "IT_VALIPI")
			SF4->(DbSeek(xFilial("SF4")+cTES))
			If cPaisLoc == "BRA"
				If SF4->F4_ISS == "S"
					cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
				Else
					If SBI->BI_PICMRET > 0 .AND. SA1->A1_TIPO $ SuperGetMV("MV_TPSOLCF") .AND. SF4->F4_BSICMST <> 100
						cAliquota := "F"
					ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
						cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
					Elseif SF4->F4_LFICM == "I"
						cAliquota := "I"					// Isento
					    If SF4->F4_AGREG == "D"            // Deducao de ICMS                 
						   nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
						   nTotDedIcms += nDedIcmsIt
				        Endif
					Elseif SF4->F4_LFICM == "N"
						cAliquota := "N"					// N„o sujeito a ICMS					
					Else
						cAliquota := "T" + Str(MaFisRet(1,"IT_ALIQICM"),5,2)
					Endif
				EndIf
				nValPis := MaFisRet(1,"IT_VALPIS")
				nValCof := MaFisRet(1,"IT_VALCOF")
				nValCsl := MaFisRet(1,"IT_VALCSL")
				nBasePS2:= MaFisRet(1,"IT_BASEPS2")
				nValPS2	:= MaFisRet(1,"IT_VALPS2")
				nAliqPS2:= MaFisRet(1,"IT_ALIQPS2")
				nBaseCF2:= MaFisRet(1,"IT_BASECF2")
				nValCF2	:= MaFisRet(1,"IT_VALCF2")
				nAliqCF2:= MaFisRet(1,"IT_ALIQCF2")
			Else  
				If !Empty(cTES) .AND. ((nVlrUnit > 0) .OR. (nVlrItem > 0) .OR. (nQuant > 0))
	   				nVlrMerc += nVlrItem
			 	    aImps    := TesImpInf(cTES)
				    Aadd(aImpsSL2,{SBI->BI_COD,cTES,{}})
				    For nI := 1 to Len(aImps)                                                 
				       If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
				          AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
				          nE := Len(aImpsSL1)
				       EndIf   
				       cIndImp  := Substr(aImps[nI][2],10,1)               
				       cCampoVal   := "IT_VALIV"+cIndImp		    
				       cCampoAlq   := "IT_ALIQIV"+cIndImp	 
				       nValImp     := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
					   FRTGeraImp(@aImposto,aImps[nI],nValImp,nQuant,nVlrUnit,1,cIndImp)			   
					   AAdd(aImpsSL2[len(aImpsSL2)][3],aClone(aImposto))
					   nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
					   aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
					   aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
				    Next nI
				    nTamItem  := TamSX3("L2_ITEM")[1]  
	                AAdd(aImpsSL2[Len(aImpsSL2)],Space(nTamItem))				
	           		AAdd(aImpsSL2[Len(aImpsSL2)],.F.)				   	           					      
					nVlrUnit  := Round(nVlrItem/nQuant,nDecimais)
		            nVlrItem  += nTotImp
				    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
	           		AAdd(aImpsSL2[Len(aImpsSL2)],nQuant)				   	           					                 		
	           		AAdd(aImpsSL2[Len(aImpsSL2)],nVlrUnit)				   	           					                 		           					    
				EndIf
			EndIf
			MaFisEnd()
		
			If Empty(cTES)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FRTDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
				// "TES de Saída " ### " Inválida. Operação não efetuada.", "Atenção"
				MsgStop(STR0107+cTES+STR0108, STR0003)
				Return(.T.)
			EndIf
			If 'SCHALTER' $ LjGetStation( 'IMPFISC' ) 
				If Left(cAliquota,1) == "T" .AND. (AScan(aICMS, {|x| x[1]==StrTran( cAliquota,'.',',' ) })=0) 
					lEntra := .F.
			    EndIf
			Else
			    If Left(cAliquota,1) == "T" .AND. (AScan(aICMS, {|x| x[1]==Val(Substr(cAliquota,2))})=0)
					lEntra := .F.
				Endif
			Endif			
				
			If !lEntra	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FRTDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
				// "Aliquota " ### " não cadastrada no ECF. Operação não efetuada.", "Atenção"
				MsgStop(STR0046+cAliquota+STR0047, STR0003)
				Return(.T.)
			Endif	
	
			If nVlrUnit==0 .OR. nVlrItem==0 .OR. nQuant==0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FRTDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld			// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld			// Variavel que retorna o valor anterior
				EndIf
				
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1C" + Upper(STR0255) )         //"Produto com quantidade ou preco nulo"
					DisplayEnv(StatDisplay(), "2C" + STR0256)         //"PRESSIONE <ESC>"
				EndIf			
				HELP(' ',1,'FRT013')    // "Produto com o valor unitário nulo ou a quantidade nula." ### "Atenção"
				
				//Realiza o acerto do array de impostos para que nao ocorra a gravacao
				//de impostos com valor zero no arquivo SL2...
				If cPaisLoc <> "BRA"
					ADel(aImpsSL2, Len(aImpsSL2))
					ASize(aImpsSL2, Len(aImpsSL2)-1)							
				EndIf
				Return(.T.)
			EndIf
		
			If SF4->F4_INCSOL == 'S' 
				nVlrTotal	+= (nVlrItem + nValIPIIT + nVlIcmRet)
				nVlrBruto	+= (nVlrItem + nValIPIIT + nVlIcmRet)
			Else
				nVlrTotal	+= (nVlrItem + nValIPIIT )
				nVlrBruto	+= (nVlrItem + nValIPIIT )
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula os impostos de IPI, PIS, COFINS e CSLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValIPI		+= nValIPI
			nValTPis	:= nValTPis + nValPis
			nValTCof	:= nValTCof + nValCof
			nValTCsl	:= nValTCsl + nValCsl
			
			nTotItens++
		
			cFotoProd := If(Empty(SBI->BI_BITMAP), "LOJAWIN", AllTrim(SBI->BI_BITMAP))
			If oFotoProd:cBMPFile <> cFotoProd
				ShowBitMap(oFotoProd, cFotoProd)
			EndIf
		
			oProduto:Refresh()
			oQuant:Refresh()
			oVlrUnit:Refresh()
			oVlrItem:Refresh()
			oTotItens:Refresh()
			oVlrTotal:Refresh()
			oDesconto:Refresh()
		
			If Len(aItens) == 0 .AND. lOcioso
		
				oTimer:DeActivate()				// Desabilita o Timer Temporariamente Para nao Atrapalhar o Processo
		
				lOcioso  := .F.															// Abriu um Cupom
				aParcOrc := {}
				aParcOrcOld := {}
				aTEFPend := {} 			
				aBckTEFMult := {}
	
				nVlrDescTot	:= 0														// VALOR DO DESCONTO
				nVlrPercTot	:= 0														// PERCENTUAL DE DESCONTO
				nVlrAcreTot	:= 0														// VALOR DO ACRESCIMO
				nVlrPercAcr := 0														// PERCENTUAL DO ACRESCIMO
				nVlrDescCPg	:= 0														// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)			
	
				lDescTotal	:= .F.														// Inicializa a variavel do desconto no total do cupom, caso seja concomitante
				lDescSE4	:= .F.														// Inicializa a variavel do desconto na condicao de pagamento
				lVerTEFPend := .F.
	
				If !lAltVend
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define o Vendedor como o padrao definido no parametro ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTamSX3  := Len(SA3->A3_COD)
					cVendLoja:= Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSX3),nTamSX3)
				EndIf
				If lOrc
					cVendLoja := FRTAField(cOrc, "L1_VEND")
				EndIf
		
				oCupom:SetArray(	{ 	"", "", "", "", ;
										"", "", "", "", ;
										"", "", "", "", ;
										"", "", "", "", ;
										"", "" }	)
				If ExistBlock("FRTCLICHE")
					aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
					AEval(aFRTCliche, {|x| oCupom:Add(Left(x,40))})
				Else
					oCupom:Add("")
					oCupom:Add(STR0027)	// "        MICROSIGA SOFTWARE S.A.         "
					oCupom:Add(STR0028)	// "    Av. Braz Leme, 1399 - São Paulo     "
					oCupom:Add(STR0029)	// "          www.microsiga.com.br          "
				EndIf
				oCupom:Add(DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+StrZero(Val(cDoc)+1,TamSX3("L1_DOC")[1]))	// "  PDV:" "   COD:"
				oCupom:Add(FRT_SEPARATOR)
				oCupom:Add(PADC(STR0032,40))	// "        C U P O M   F I S C A L         "
				oCupom:Add("")
				oCupom:Add(STR0033)	// "ITEM   CÓDIGO           DESCRIÇãO       "
				oCupom:Add(STR0034 + "("+cSimbCor+")")          // "      QTDxUNITARIO    ST     VALOR( SIMBOLO ) "
				oCupom:Add(FRT_SEPARATOR)
				oCupom:GoBottom()
		
				cOrcam := CriaVar("L1_NUM")
		
				// Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
				cMay := Alltrim(xFilial("SL1"))+cOrcam
				FreeUsedCode()
				SL1->(DbSetOrder(1))
				// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
				nTent := 0
				While SL1->(DbSeek(xFilial("SL1")+cOrcam)) .OR. !MayIUseCode(cMay)
					if ++nTent > 20
						// "Impossivel gerar numero sequencial de orcamento correto."
						Final(STR0190)
					Endif
					While (GetSX8Len() > nSaveSx8)
						ConfirmSx8()
					End
					cOrcam    := CriaVar("L1_NUM")
					FreeUsedCode()
					cMay := Alltrim(xFilial("SL1"))+cOrcam
				End
				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Abertura do Cupom - Cria o SL1 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Se o cliente estiver vazio, coloca o cliente padrão
				If Empty(cCliente)
					nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
					cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
				EndIf
				
				If Empty(cLojaCli)
					nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
					cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
				EndIf 
				
				If Empty(cVendLoja)
					nTamSXG   := Len(SA3->A3_COD)
					cVendLoja := Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSXG),nTamSXG)				
				Endif
				
								
				aSL1 := {	{"L1_FILIAL"	, xFilial("SL1") 		}, ;
						  	{"L1_NUM"		, cOrcam				}, ;
						 	{"L1_EMISSAO"	, dDataBase				}, ;
						 	{"L1_DTLIM"		, dDataBase				}, ;
						 	{"L1_EMISNF"	, dDataBase				}, ;
						 	{"L1_SERIE"		, LJGetStation("SERIE")	}, ;
						 	{"L1_PDV"		, cPDV					}, ;
						 	{"L1_OPERADO"	, xNumCaixa()			}, ;
						 	{"L1_HORA"		, cHora					}, ;
						 	{"L1_CLIENTE"	, cCliente 				}, ;
						 	{"L1_LOJA"		, cLojaCli 				}, ;
						 	{"L1_VEND"		, cVendLoja				}, ;						 	
						 	{"L1_SITUA"		, "01"					}  }	// "01" - Abertura do Cupom Nao Impressa
				If lOrc
					AAdd(aSL1,{"L1_OPERACA", "C"})
					AAdd(aSL1,{"L1_NUMORIG", FRTAField(cOrc, "L1_NUM")})
				EndIf
				If cPaisLoc <> "BRA"
					Aadd(aSL1,{"L1_MOEDA"  ,nMoedaCor})	
					Aadd(aSL1,{"L1_TXMOEDA",nTaxaMoeda})
				EndIf	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Função para varrer os campos de usuario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOrc
					FRTCmpP(aSL1,"SL1",cOrc,0)
				Endif
				FRTGeraSL("SL1", aSL1, .T.)
				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
		       
				IFPegPDV(nHdlECF, @cPDV)
				
				If ! AllTrim(cPDV) == AllTrim(LJGetStation("PDV"))
					// "O Número de PDV do equipamento é diferente do cadastrado na estação." ### "Atenção"
					HELP(' ',1,'FRT019')
					// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
			     	nRet := 1
			    Else			
					nRet := IFAbreCup(nHdlECF,@cCliCGC)
					lFechaCup := .T.			
				Endif	
				
				If nRet <> 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar a Abertura do Cupom ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTCancela(.T., .F., .F.)					// Deleta Somente o SL1
		
					HELP(" ",1,"FRT001")	// "Não foi possível realizar a abertura do cupom fiscal. Operação não efetuada."
					lOcioso := .T.															// Cancelei a Abertura do Cupom
					oCupom:SetArray( { 	"", "", "", "", ;
										"", "", "", "", ;
										"", "", "", "", ;
										"", "", "", "", ;
										"", "" } )
					nVlrMerc := 0
					nTotItens:= 0
					nVlrTotal:= 0
					nVlrBruto:= 0
					nValIPI  := 0
	
					If CrdxInt()
	  					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					 	FrtSetCrd()
					EndIf   								
	
					oTotItens:Refresh()
					oVlrTotal:Refresh()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicializa as variáveis de Templates                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					uCliTPL := Nil     
					uProdTPL:= Nil
					cCodConv:= "" 
					cLojConv:= "" 
					cNumCartConv := ""
					FRTInitIT(.T.)
					If oFotoProd:cBMPFile <> "LOJAWIN"
						ShowBitMap(oFotoProd, "LOJAWIN")
					EndIf
					oTimer:Activate()							// Habilita o Timer Novamente
					Return(lRet)
				EndIf
		
				lConsulta := .F.	
				FRTHora(.T., lConsulta)								// Atualiza a Hora e o Numero do Cupom
				aSL1 := {	{"L1_NUMCFIS"	, cDoc },;
						 	{"L1_DOC"		, cDoc },;
						 	{"L1_SITUA"		, "02" }}					// "02" - Impresso a Abertura do Cupom

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o campo L1_CGCCLI caso trabalhe com ³
				//³Nota Fiscal Paulista                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If LjAnalisaLeg(30)[1]
					If SL1->(FieldPos("L1_CGCCLI")) > 0					
						Aadd(aSL1,{ "L1_CGCCLI" , cCliCGC } )
					EndIf
    			EndIf

				FRTGeraSL("SL1", aSL1)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Informar a Retaguarda o Status Atual do Check-Out. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTGeraSLI(cEstacao	, 	"CON"		,	"V|"	+ 	Alltrim(cPDV) 					+ ;
							"|" 	+ AllTrim(cDoc)	+	"|"		+	AllTrim(Str(nVlrTotal,14,2)	)	+ ;
							"|"		+ AllTrim(Str(nTotItens))	, 	"SOBREPOE")
		
				oTimer:Activate()								// Habilita o Timer Novamente
		
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Situacoes do _SITUA                              ³
			//³ "  " - Base Errada, Registro Ignorado.           ³
			//³ "00" - Venda Efetuada com Sucesso                ³ 
			//³ "01" - Abertura do Cupom Nao Impressa            ³
			//³ "02" - Impresso a Abertura do Cupom              ³
			//³ "03" - Item Nao Impresso                         ³
			//³ "04" - Impresso o Item                           ³
			//³ "05" - Solicitado o Cancelamento do Item         ³
			//³ "06" - Item Cancelado                            ³
			//³ "07" - Solicitado o Cancelamento do Cupom        ³
			//³ "08" - Cupom Cancelado                           ³
			//³ "09" - Encerrado SL1 (Nao gerado SL4)            ³
			//³ "10" - Encerrado a Venda                         ³
			//³        Pode nao ter sido impresso o cupom        ³
			//³ "TX" - Foi Enviado ao Server                     ³
			//³ "RX" - Foi Recebido Pelo Server                  ³
			//³ "OK" - Foi Processado no Server                  ³
			//³        Enviar um OK ao Client que foi Processado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio - Tam - Descricao                    ³
			//³      1 -   3 - Item                         ³
			//³      5 -  13 - Codigo do Produto            ³
			//³     19 -  21 - Descricao do Produto         ³
			//³      1 -   9 - Quantidade                   ³
			//³     10 -   1 - Multiplicador ("x")          ³
			//³     11 -   9 - Valor Unitario               ³
			//³     20 -   6 - Aliquota de ICM              ³
			//³     26 -   1 - Simbolo de Porcentagem ("%") ³
			//³     27 -  13 - Valor Total do Item          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuant     := PadL(Trans(nQuant, If(nQuant-Int(nQuant)==0, "999999999", PesqPictQt("L2_QUANT",9))),9)
			cVlrUnit   := PadR(AllTrim(Trans(nVlrUnit+If(cPaisLoc<>"BRA",(nTotImp/nQuant),0),PesqPict("SBI", "BI_PRV",9,nMoedaCor))),9)
			cVlrItem   := Transform(nVlrItem,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))
		    cVlrPercIT := Transform(nVlrPercIT,"@R 99.99%")
			cValIPIIT  := Transform(nValIPIIT,PesqPict("SL2", "L2_VALIPI", 13,nMoedaCor))
			cVlIcmRet  := Transform(nVlIcmRet,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAux := { 	FRTLastIT()+1	, cCodProd	, cCodBar	, cProduto, ;
						cQuant        	, cVlrUnit	, cAliquota	, cVlrItem, ;
						cVlrPercIT		, cValIPIIT	, lLeitor	, cVlIcmRet }
			If lFRTCODB2t
				aAdd(aAux,uProdTPL)	
				aAdd(aAux,uCliTPL)	
				
				aAux := ExecTemplate( "FRTCODB2",	.F.,	.F.,	{aAux, uProdTPL, uCliTPL } )
				cCodProd := Padr(aAux[2], nTB1COD)
				cCodBar  := Padr(aAux[3], nTB1CODBAR)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³valorizando variaveis do tipo STATIC³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType( aAux[13] ) == "A"
					uProdTPL := aClone(aAux[13])
				Else
					uProdTPL := aAux[13]
				Endif
				If ValType( aAux[14] ) == "A"
					uCliTPL  := aClone(aAux[14])
				Else
					uCliTPL  := aAux[14]
				Endif
			EndIf
			If ExistBlock("FRTCODB2")
				aAux := ExecBlock( "FRTCODB2", .F., .F., aAux )
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)
			EndIf
			nCodANVISA := FRTLastIT()+1
			// Montar aItens (Ultimo Elemento eh Cancelado)
			AAdd(aItens, { FRTLastIT()+1, cCodProd , cCodBar , cProduto								, ;
			               nQuant        , nVlrUnit , nVlrItem, nVlrDescIT								, ;
			               cAliquota     , nValIPIIT, .F.     , IIf(SF4->F4_INCSOL == 'S',nVlIcmRet,0)	, ;
			               nDedIcmsIt    , nCodANVISA   } )
		
			If cMvCodBar == "S" .AND. !Empty(aAux[3])
            	cProdLocal := aAux[3]
   			Else
   				cProdLocal := aAux[2]
   			EndIf

			oCupom:Add( StrZero(aAux[1],3)+" "+Left(cProdLocal,13)+" "+Left(aAux[4],21) )
			If cPaisLoc == "BRA"
				oCupom:Add( aAux[5]+"x"+aAux[6]+PadR(aAux[7],6)+"%"+aAux[8] )
			Else       
				oCupom:Add( aAux[5]+"x"+aAux[6]+Space(06)+aAux[8] )
			EndIf
			If nVlrPercIT > 0 
				oCupom:Add(STR0039+aAux[9])  // "Desconto de :  "
			Endif
			If nValIPIIT > 0 
				oCupom:Add( "IPI: " + aAux[10] )
			Endif
			If nVlIcmRet > 0 .AND. SF4->F4_INCSOL == 'S' 		
				oCupom:Add( "ICMS Retido: " + aAux[12] )
			Endif
			oCupom:GoBottom()
	
			cLocal  := SBI->BI_LOCPAD
			cTabela := SBI->BI_TABELA
			If lOrc
				cLocal  := FRTAField(cOrc, "L2_LOCAL",  nNumItem)
				cTabela := FRTAField(cOrc, "L2_TABELA", nNumItem)
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Registrando o Item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSL2 := {	{"L2_FILIAL"	,	xFilial("SL2")	},;
					 	{"L2_NUM"		,	cOrcam			},;
					 	{"L2_PRODUTO"	,	cCodProd		},;
					 	{"L2_ITEM"		,	FRTPegaIT(FRTLastIT())	},;
					 	{"L2_DESCRI"	,	cProduto		},;
					 	{"L2_QUANT"		,	nQuant			},;
					 	{"L2_VRUNIT"	,	nVlrUnit - If(cPaisLoc=="BRA",(nVlrDescIT / nQuant),0)},; 	// Para paises diferentes de Brasil o valor 
					 	{"L2_VLRITEM"	,	nVlrItem		},;                                        	// unitario ja foi acertado para a impressao   
		 			 	{"L2_DESC"		,	nVlrPercIT		},;                                         // correta no cupom.
					 	{"L2_VALDESC"	,	nVlrDescIT		},;
					 	{"L2_VALIPI"	,	nValIPIIT		},;
					 	{"L2_UM"		,	cUnidade		},;
					 	{"L2_VENDIDO"	,	"S"				},;
					 	{"L2_LOCAL"		,	cLocal			},;
					 	{"L2_TES"		,	cTES			},;
					 	{"L2_CF"		,	cCF				},;
					 	{"L2_DOC"		,	SL1->L1_DOC		},;
					 	{"L2_SERIE"		,	SL1->L1_SERIE	},;
					 	{"L2_PDV"		,	SL1->L1_PDV		},;
					 	{"L2_VEND"		,	If(lOrc,FRTAField(cOrc,"L2_VEND",nNumItem),cVendLoja)},;
					 	{"L2_TABELA"	,	cTabela			},;
					 	{"L2_EMISSAO"	,	SL1->L1_EMISSAO	},;
					 	{"L2_GRADE"		,	"N"            	},;
					 	{"L2_BCONTA"	,	cBCONTA  		},;				// Recebimento de Conta
					 	{"L2_SITUA"		,	"03"   			} }				// "03" - Item Nao Impresso
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Função para varrer os campos de usuario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOrc
				FRTCmpP(aSL2, "SL2", cOrc, nNumItem)
			Endif
		    
		    If cPaisLoc <> "BRA"  
				//Encontra no aImpsSL2 a posicao correspondente ao item da venda...
		    	nI :=  Len(aItens)
		    	
		        For nY := 1 to Len(aImpsSL2[nI][3])
		        	Aadd(aSL2,{aImpsSL2[nI][3][nY][6],aImpsSL2[nI][3][nY][4]})   //Valor do imposto
	                Aadd(aSL2,{aImpsSL2[nI][3][nY][7],aImpsSL2[nI][3][nY][3]})   //Base do imposto         
	                Aadd(aSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nY][7],10,1),aImpsSL2[nI][3][nY][2]})   //Aliquota do imposto                           
					//Eh abatido o valor dos impostos pois o item foi gravado com base
					//na variavel nVlrItem, que teve os impostos somadas para a
					//exibicao do total na tela...
					If SubStr(aImpsSL2[nI][03][nY][05],2,1) == "1"
						aSL2[Ascan(aSL2,{|x| Trim(x[1]) == "L2_VLRITEM"})][2] -= aImpsSL2[nI][3][nY][4]
					EndIf 
	            Next nY   
	
	           	aImpsSL2[nI][4]  := aSL2[4][2]
	           	aImpsSL2[nI][5]  := .F.           
	           	aImpsSL2[nI][6]  := nQuant				
	           	aImpsSL2[nI][7]  := nVlrUnit				   	           					                 					           	           	
			   	Aadd(aSL2,{"L2_PRCTAB",	nVlrUnit+(nVlrDescIT / nQuant)})
			   	
				FrtTotVen()
				FRTSimACols(	cCodProd,	nQuant			,	nVlrUnit,	cTES,	;
								cCF     ,   aSL2[Ascan(aSL2,{|x| Trim(x[1])=="L2_ITEM"})][2])
				AAdd(	aImpsProd,	aClone(aImpsSL2[nI] ) )
			Else
				Aadd( aSL2, {"L2_PRCTAB",	nVlrUnit} )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava o valor do PIS, Cofins e CSLL somente se o campo existir³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SL2->( FieldPos( "L2_VALPIS" ) ) > 0 
					Aadd( aSL2, {"L2_VALPIS",	nValPis	} )
					Aadd( aSL2,	{"L2_VALCOFI",	nValCof	} )
					Aadd( aSL2,	{"L2_VALCSLL",	nValCsl	} )
					Aadd( aSL2,	{"L2_BASEPS2",	nBasePS2} )
					Aadd( aSL2,	{"L2_VALPS2",	nValPS2 } )
					Aadd( aSL2,	{"L2_ALIQPS2",	nAliqPS2} )
					Aadd( aSL2,	{"L2_BASECF2",	nBaseCF2} )
					Aadd( aSL2,	{"L2_VALCF2",	nValCF2 } )
					Aadd( aSL2,	{"L2_ALIQCF2",	nAliqCF2} )
				Endif
	        EndIf
					 
	        If SL2->( FieldPos("L2_ITEMSD1")) > 0
				Aadd( aSL2,	{"L2_ITEMSD1",	"000000"} )	        	
	        EndIf

			FRTGeraSL("SL2", aSL2, .T. 	)
			aSL1 := {{"L1_SITUA" ,	"03"} }	// "03" - Item Nao Impresso
			FRTGeraSL( "SL1", aSL1 )
			nDec := TamSX3("L2_QUANT")[2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Tratamento dos Dados Que Serao Impressos no Cupom. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				If SF4->F4_INCSOL == 'S' 			
					aAux := {	cCodProd, cCodBar, cProduto, nQuant, ;
								nVlrUnit + (nValIPIIT / nQuant) + (nVlIcmRet / nQuant), nVlrDescIT, cAliquota, ;
								nVlrItem + nVlrDescIT + nValIPIIT + nVlIcmRet, lOrc, cOrc, nNumItem, ;
								cUnidade	}
				Else
					aAux := {	cCodProd, cCodBar, cProduto, nQuant, ;
								nVlrUnit + (nValIPIIT / nQuant) , nVlrDescIT, cAliquota, nVlrItem + nVlrDescIT + nValIPIIT, ;
								lOrc, cOrc, nNumItem, cUnidade	}
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para controlar o Desconto no Item. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("FRTDescIT") .OR. lFRTDescITt
					nVlrPercIT := nPercITOld		// Variavel que retorna o valor anterior
					nVlrDescIT := nDescITOld		// Variavel que retorna o valor anterior
				EndIf
			Else
				aAux := {	cCodProd	, cCodBar	, cProduto	, nQuant	, ;
							nVlrUnit	, nVlrDescIT, cAliquota	, nVlrItem 	, ;
							lOrc		, cOrc		, nNumItem	, cUnidade	}
	            nVlrDescIT  := 0  //Zerar o desconto a cada item
	            nVlrPercIT  := 0
			EndIf  
			If lFRTCODB3t
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adicionando Variaveis STATIC no final do array          ³
				//³para que as mesmas possam ser tratadas nas EXECTEMPLATES³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aAux,uProdTPL)
				aAdd(aAux,uCliTPL)
								
				aAux := ExecTemplate("FRTCODB3",.F.,.F.,{aAux,uProdTPL,uCliTPL})
	            uProdTPL := aClone(aAux[13])			
	            uCliTPL  := aAux[14]			
			EndIf   
			If ExistBlock("FRTCODB3")
				aAux := ExecBlock("FRTCODB3",.F.,.F.,aAux)
			EndIf
			If lUsaDisplay
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibir Mensagem de Registro de Items no Display ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgDisplay(5, aAux)                                 
			
			EndIf
			
			If lUsaDispTor
				MsgDispTor(5, aAux)		
			Endif
				
			If cMvCodBar == "S" .AND. !Empty(aAux[2])
            	cProdLocal := aAux[2]
   			Else
   				cProdLocal := aAux[1]
   			EndIf
			
			nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(cProdLocal),13),cProdLocal), aAux[3], AllTrim(Str(aAux[4],7,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
							  AllTrim(Str(aAux[6],14,2)), aAux[7],Alltrim(Str(aAux[8],14,2)), aAux[12])
			If nRet <> 0
				// "Não foi possível registrar o item. Operação não efetuada!!!", "Atenção"
				HELP(' ',1,'FRT014')
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar o Item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SL2")
				RecLock("SL2", .F.)
				dbDelete()
				MsUnLock()
				If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))               
				    If T_DroVerCont( cCodProd )				
						T_DroDelANVISA( .F., aItens[Len(aItens)][AIT_IDANVISA] )
					Endif	
				Endif
				oCupom:Del(Len(oCupom:aItems))
				oCupom:Del(Len(oCupom:aItems))
				nVlrTotal -= (aItens[Len(aItens)][AIT_VLRITEM] + aItens[Len(aItens)][AIT_VALIPI] + aItens[Len(aItens)][AIT_VALSOL])
				nVlrBruto -= (aItens[Len(aItens)][AIT_VLRITEM] + aItens[Len(aItens)][AIT_VALIPI] + aItens[Len(aItens)][AIT_VALSOL])
				ASize(aItens, Len(aItens)-1)
				nTotItens--
	                                           
				//Realiza o acerto em todos os arrays para evitar a gravacao errada 
				//dos campos de impostos e do valor total do item...
				If cPaisLoc <> "BRA"
					FrtTotVen()
	
					//Exclui item do aCols
					Asize(aCols,(Len(aCols)-1))                        		
							
					//Exclui item do aImpsProd
					Asize(aImpsProd,(Len(aImpsProd)-1))                        								
					
					//Abate o valor dos impostos, referente ao item excluido, 
					//do array aImpsSL1, para futura gravacao no arquivo SL1.
		   			For nI := 1 To Len(aImpsSL2[Len(aImpsSL2)][3])
		   				nE := Ascan( aImpsSL1,{|x| x[1] == aImpsSL2[Len(aImpsSL2)][3][nI][1]})
		   				aImpsSL1[ nE,3 ] -= aImpsSL2[Len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
		   				aImpsSL1[ nE,5 ] -= aImpsSL2[Len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   						
					Next nI
					
					//Exclui item do aImpsSL2
					Asize(aImpsSL2,(Len(aImpsSL2)-1))                        												
				EndIf
			Else
				// Indica que o o item atual AINDA NAO TEVE DESCONTO
				lDescIT := .F.
				aSL2 := {	{	"L2_DOC"	,	cDoc	}, ;
						 	{	"L2_SITUA"	,	"04"	}	} 	// "04" - Impresso o Item
				FRTGeraSL("SL2", aSL2)
				If nTotItens == 1
					aSL1 := { { "L1_SITUA", "04" } }			// "04" - Impresso o Item
					FRTGeraSL("SL1", aSL1)
		    	EndIf
		
				cCupom := oCupom:aItems[Len(oCupom:aItems)-1]
				nTmpQuant := 1    
				If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
				    If T_DroVerCont( cCodProd )
						T_DroAltANVISA( cCodProd, nQuant, cDoc, LJGetStation("SERIE"),;
	     								nCodANVISA  )
					Endif
				Endif	
			EndIf
		Next nX
	EndIf
Else
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + Upper(STR0049) )	// "Produto não cadastrado!!!"
		DisplayEnv(StatDisplay(), "2C" + STR0256 )     //"PRESSIONE <ESC>
		cCodProd := ""
	EndIf

	Tone(3000,1)
	DEFINE FONT oFntErro NAME "Arial" SIZE 6,14 BOLD
	DEFINE DIALOG oDlgErro FROM 0,0 TO 3, Len( STR0049 ) + 8 ;	// "Produto não cadastrado!!!"
		STYLE nOr( DS_MODALFRAME, WS_POPUP ) TITLE STR0003		// "Atenção"
	oDlgErro:SetFont(oFntErro)
	@  2,0 SAY xPadc(STR0049, oDlgErro:nRight - oDlgErro:nLeft) OF oDlgErro PIXEL
	@ 12,0 SAY xPadc(AllTrim(cCodProd), oDlgErro:nRight - oDlgErro:nLeft) OF oDlgErro PIXEL
	ACTIVATE MSDIALOG oDlgErro CENTERED
EndIf

If lZeraDesc 
	nVlrDescIT := 0 
	nVlrPercIT := 0
EndIf
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTInitIT ³ Autor ³ Vendas Clientes       ³ Data ³15/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa os Objetos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTInitIT( lForced )
DEFAULT lForced := .F.
cCodProd := Space(nTamCodProd)
If lF7 .OR. lForced
	cProduto := ""
	nTmpQuant:= 1
	nQuant   := 1
	cUnidade := "UN"
	nVlrUnit := 0
	nVlrItem := 0
	oProduto:Refresh()
	oQuant:Refresh()
	oUnidade:Refresh()
	oVlrUnit:Refresh()
	oVlrItem:Refresh()
	oDesconto:Refresh()
EndIf                              

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTConfExi³ Autor ³ Vendas Clientes       ³ Data ³16/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirmacao da Saida da Venda                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTConfExit
Local lRet:=.F.
If lExitNow .OR. lRecebe
	lRet := .T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	If lCXAberto
		If !lOcioso
			HELP(' ',1,'FRT015')	// "É Necessário FECHAR a Venda ou CANCELAR este Cupom Fiscal.", "Atenção"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Permissao "Saida do Atendimento" - #10 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LJProFile(10)
	  			If lUsaDisplay
   					DisplayEnv(StatDisplay(), "1C" + Upper(STR0003) )         
   			 		DisplayEnv(StatDisplay(), "2C" + STR0051)
				EndIf
				lRet := MsgYesNo(STR0051, STR0003)	// "Deseja sair da rotina de venda?", "Aneção"
				If lRet
					FClose(nHdlOPE)
				Else
		  			If lUsaDisplay
						DisplayEnv(StatDisplay(), "2E"+ STR0254)
						DisplayEnv(StatDisplay(), "1E"+ " ")
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If !lOcioso
			HELP(' ',1,'FRT016')	// "Houve a retomada da Venda. Abra o Caixa e FECHE ou CANCELE este Cupom Fiscal.", "Atenção"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Permissao "Saida do Atendimento" - #10 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LJProFile(10)
				lRet := .T.				// Se o Caixa Nao Estiver Aberto, E Nao Houve FRTResume,
			EndIf						// Saida Automatica
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTStart  ³ Autor ³ Vendas Clientes       ³ Data ³07/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializacao do PDV                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTStart
Local 	nRet 
Local 	cRet		:=" " 
Local 	aKey
Local 	aAux
Local 	nSaveSx8 	:= GetSx8Len()
Local	lMvLjPdvPa  := FindFunction("LjxBGetPaf") .And. LjxBGetPaf()[2] //Indica se é PDV


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

oTimer:DeActivate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Gaveta Serial         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"GAVETA","PORTGAV"})
If lGaveta .AND. !Empty(aAux[2]) .AND. (LJGetStation("PORTIF") <> aAux[2])
	nHdlGaveta := GavetaAbr(aAux[1], aAux[2])
	If nHdlGaveta == -1
		// "Erro ao conectar com a Gaveta Serial " ### " na porta " ###, "Atenção"
		MsgStop(STR0124+AllTrim(aAux[1])+STR0125+aAux[2]+".", STR0003)
		lGaveta := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do Leitor Optico Serial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"OPTICO","PORTOPT"})
If lUsaLeitor .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
	nHdlLeitor := LeitorAbr(aAux[1], aAux[2],'T')
	If nHdlLeitor == -1
		// "Erro ao conectar com o Leitor Optico Serial " ### " na porta " ###, "Atenção"
		MsgStop(STR0122 + AllTrim(aAux[1]) + STR0123+aAux[2] + ".", STR0003 )
		lUsaLeitor := .F.
	EndIf
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Balanca              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If SLG->( FieldPos("LG_PORTBAL")) > 0
	aAux := LJGetStation({"BALANCA","PORTBAL"})
	If lBalanca .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
		nHdl := BalancaAbr(aAux[1], aAux[2],'T')
		If nHdl == -1
			// "Erro ao conectar com a Balanca Serial " ### " na porta " ###, "Atenção"
			MsgStop(STR0287 + AllTrim(aAux[1]) + STR0123+aAux[2] + ".", STR0003 )//"Erro ao conectar com a Balanca Serial "
			lBalanca := .F.
		EndIf
		StatBalanca(nHdl)
	EndIf   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"DISPLAY","PORTDIS"})
If lUsaDisplay .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
	StatDisplay (DisplayAbr(aAux[1], aAux[2]))
	If StatDisplay() == -1
		// "Erro ao conectar com o Display " ### " na porta " ###, "Atenção"
		MsgStop( STR0126 + AllTrim(aAux[1]) + STR0127 + aAux[2] + ".", STR0003 )
		lUsaDisplay := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibir Mensagem de Inicializacao no Display ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgDisplay(1)
	EndIf
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do Display Torre ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"DISPTOR","PORTTOR"})
If lUsaDispTor .AND. !Empty(aAux[1]) .AND. !Empty(aAux[2])
	StatDispTor (DispTorAbr(aAux[1], aAux[2]))
	If StatDispTor() == -1
		// "Erro ao conectar com o Display " ### " na porta " ###, "Atenção"
		MsgStop( STR0126 + AllTrim(aAux[1]) + STR0127 + aAux[2] + ".", STR0003 )
		lUsaDispTor := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibir Mensagem de Inicializacao no Display ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgDispTor(1)
	EndIf
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   
//³ Abertura do CMC7 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"CMC7", "PORTMC7"})
If lUsaCMC7
	If Empty(aAux[1])
		lUsaCMC7 := .F.
	Else
	    nHdlCMC7:= CMC7Abr(aAux[1], aAux[2]) 
		If nHdlCMC7 == -1
			// "Erro ao conectar com o Leitor de CMC7 " ### " na porta " ###, "Atenção"
			MsgStop( STR0118 + AllTrim(aAux[1]) + STR0119+aAux[2] + ".", STR0003 )
			lUsaCMC7 := .F.
		EndIf
	EndIf
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Impressora de Cheque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := LJGetStation({"IMPCHQ", "PORTCHQ"})
If lUsaCH
	If Empty(aAux[1])
		lUsaCH := .F.
	Else
		nHdlCH := CHAbrir( aAux[1], aAux[2] )
	    If nHdlCH < 0
			// "Erro ao conectar com a Impressora de Cheque " ### " na porta " ###, "Atenção"
			MsgStop(STR0120+AllTrim(aAux[1])+STR0121+aAux[2]+".", STR0003)
			lUsaCH := .F.
	    Endif
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura da Impressora Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlECF := IFAbrir(cImpressora, cPorta)
If nHdlECF == -1
	// "Erro ao conectar com a Impressora Fiscal " ### " na porta ", "Atenção"
	MsgStop(STR0053+AllTrim(cImpressora)+STR0054+cPorta+".", STR0003)
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
EndIf

If !LjVldSerie()
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
EndIf

nRet := IFAbrECF(nHdlECF)
If nRet <> 0
	// "Não consegui abrir o ECF. É possível que esteja desligado. Erro: " ###, "Atenção"
	MsgStop(STR0055+Str(nRet,2,0), STR0003)
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Generico Apos a Abertura do ECF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTAbrECF")
	ExecBlock("FRTAbrECF",.F.,.F.,{nHdlECF,cImpressora,cPorta})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compara a data do ECF com a data do Sistema. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IFStatus(nHdlECF, "2", @cRet)
If dDataBase <> CToD(cRet)
	// "A data do ECF é diferente da data do Sistema." ### "Atenção"
	HELP(' ',1,'FRT017')
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
Else
	If LjAnalisaLeg(3)[1]
		If ! VerifHora()
			LjMsgLeg(LjAnalisaLeg(3))
			/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Março de 2013),
				para PAF-ECF admite-se somente uma tolerância em minutos entre a hora do Sistema e a hora do ECF,
				limitada a uma hora, desde que na mesma data." */
			If lMvLjPdvPa
				Help(' ',1,STR0003,Nil,STR0335,3,1) //"Atenção"
			Else
				HELP(' ',1,'FRT018') //"Hora do Sistema diferente da hora do ECF."
			EndIf
			// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
			lExitNow := .T.
			Return(NIL)     
		EndIf                  			
	EndIf		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o CNPJ cadastrado na impressora, eh o mesmo do SIGAMAT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal
	If !LjEcfIFCNPJ()
		lExitNow := .T.
		Return (NIL)
	EndIf
EndIf

aICMS := LJSetAliq()
FRTHora(.T.)					// Atualiza a Hora e o Numero do Cupom
IFPegPDV(nHdlECF, @cPDV)		// Numero do PDV
If ! AllTrim(cPDV) == AllTrim(LJGetStation("PDV"))
	// "O Número de PDV do equipamento é diferente do cadastrado na estação." ### "Atenção"
	HELP(' ',1,'FRT019')
	// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
	lExitNow := .T.
	Return(NIL)
EndIf
cPDV := PadR(cPDV, Len(SL1->L1_PDV))
oPDV:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o ECF permite desconto apos registrar o item (0=Permite) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDescITReg := (IFStatus(nHdlECF, "15", "") == 0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se utiliza troca de serie automatica quando o COO for reinicializado.³
//³Emite aviso para rodar a rotina de reserva de series.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJNSrDisp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando a Retomada da Ultima Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun( STR0312, "", { || FRTResume() } )		// "Aguarde ... verificando situação do PDV ..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inserido a CriaVar e a RollBacSX8, Pois o GetSXENum Contido na        ³
//³ Inicializacao do L1_NUM, Na Primeira Execucao Cria um Indice.         ³
//³                                                                       ³
//³ Inserido as Funcoes Fiscais, Pois na Primeira Execucao Leva-se Muito  ³
//³ Tempo na Inicializacao dos Arrays Estaticos.                          ³
//³                                                                       ³
//³ Estas Linhas Devem Ser Retiradas Quando Esses Problemas Forem         ³
//³ Solucionados.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaVar("L1_NUM")
While (GetSX8Len() > nSaveSx8)
	RollBackSx8()
End        

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek( xFilial("SA1") + cCliente + cLojaCli )
	MaFisIni(	SA1->A1_COD	,	SA1->A1_LOJA	,	"C"	, 	"S"	,;
				SA1->A1_TIPO,	NIL				,	NIL	, 	.F.	,;
				"SBI"		,	NIL				,	"01",	NIL	,;
				NIL			,	NIL				,	NIL	,	NIL	,;
				NIL			,	NIL				,	.F.	)
    DbSelectArea("SBI")
    DbSetOrder(1)
    If DbSeek( xFilial("SBI") )
    	MaFisAdd(SBI->BI_COD, SuperGetMV("MV_TESSAI"), 1, 1, 0, "", "",, 0, 0, 0, 0, 1, 0)
	Endif
	MaFisEnd()
Endif

oTimer:Activate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAbreCX ³ Autor ³ Vendas Clientes       ³ Data ³19/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abertura do Caixa (F4)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTAbreCX
Local aKey
Local cSupervisor := Space(15)
Local cString     := ""
Local nRet		  := 0	

If ! lCXAberto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()

    If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C"+ STR0057 )  //"A B E R T U R A   D E   C A I X A"
	End

	If LJ260Abre(,,,@cSupervisor, .T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar se Houve Troca de Operador ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE"))
		If Empty(SLI->LI_MSG)
			oCupom:Add("")
			oCupom:Add(FRT_SEPARATOR)
			oCupom:Add(PADC(STR0057,40))	// "   A B E R T U R A   D E   C A I X A    "
			oCupom:Add("")
			oCupom:Add(STR0058+cUserName+STR0059+xNumCaixa())	// "Usuário: " " Caixa: "
			oCupom:Add(DToC(dDatabase)+" "+Time()+Space(13)+STR0030+PadR(cPDV,4))
			oCupom:Add(FRT_SEPARATOR)
			oCupom:GoBottom()
			cCupom := oCupom:aItems[Len(oCupom:aItems)-1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Para Impressao do Relatorio de Abertura ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("FRTABRCX")
				cString := ExecBlock("FRTABRCX", .F., .F., {cSupervisor})
			EndIf
			If Len(cString) > 0
				nRet := IFStatus(nHdlECF, "5", "")				// Verifica Cupom Fechado
				If (nRet == 0 .AND. IFRelGer(nHdlECF, cString) == 0) .OR. (nRet == 7)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Informar que Houve Troca de Operador ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTGeraSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
					If !FRTSemaforo("OPE", cEstacao, @nHdlOPE)
						// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
						HELP(' ',1,'FRT020')
					EndIf
					lCXAberto := .T.
				Else
					// "Não foi possível realizar a Abertura do Caixa. Erro na impressão do comprovante.", "Atenção"
					HELP(' ',1,'FRT021')
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Informar que Houve Troca de Operador ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTGeraSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
				If !FRTSemaforo("OPE", cEstacao, @nHdlOPE)
					// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
					HELP(' ',1,'FRT020')
				EndIf
				lCXAberto := .T.
			EndIf
		Else
			If SLI->LI_USUARIO == cUserName
				oCupom:Add("")
				oCupom:Add(FRT_SEPARATOR)
				oCupom:Add(PADC(STR0057,40))	// "   A B E R T U R A   D E   C A I X A    "
				oCupom:Add("")
				oCupom:Add(STR0058+cUserName+STR0059+xNumCaixa())	// "Usuário: " " Caixa: "
				oCupom:Add(DToC(dDatabase)+" "+Time()+Space(13)+STR0030+PadR(cPDV,4))
				oCupom:Add(FRT_SEPARATOR)
				oCupom:GoBottom()
				FRTGeraSLI(cEstacao, "OPE", If(Empty(cSupervisor),cUserName,cSupervisor), "SOBREPOE")
				If !FRTSemaforo("OPE", cEstacao, @nHdlOPE)
					// "Não foi possível inicializar o semáforo de Abertura de Caixa. Verifique se não existe outra conexão do Front Loja." ### "Atenção"
					HELP(' ',1,'FRT020')
				EndIf
				lCXAberto := .T.
			Else
				// "O usuário " ### " não fechou o caixa. Favor iniciar com este usuário e fechar o caixa.", "Atenção"
				MsgStop(STR0061+AllTrim(SLI->LI_USUARIO)+STR0062, STR0003)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibir Mensagem de Caixa Disponivel no Display ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCXAberto
			MsgDisplay(3)
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "2E"+ STR0254)
					DisplayEnv(StatDisplay(), "1E"+ " ")
		   		End
		   	If lUsaDispTor  
		   		MsgDispTor(3)
		   		DispTorEnv(StatDispTor(), STR0254)
				DispTorEnv(StatDispTor(), " ")	 
			EndIf		
		EndIf
	Else
	    If lUsaDisplay
			DisplayEnv(StatDisplay(), "2E"+ STR0254)
			DisplayEnv(StatDisplay(), "1E"+ " ")
		End	     
	    If lUsaDispTor
			DispTorEnv(StatDispTor(), STR0254)
			DispTorEnv(StatDispTor(), " ")
		End	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTFechaCX³ Autor ³ Vendas Clientes       ³ Data ³19/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento do Caixa (F5)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTFechaCX
Local aKey
Local cSupervisor:=Space(15)
Local lAutoriza
If lCXAberto .AND. (lOcioso .OR. !lRecebe)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Supervisao Caixa" - #4 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C"+ STR0064 )  //" F E C H A M E N T O   D O   C A I X A  "
	End
	lAutoriza := LJProFile(4,@cSupervisor)
	If lAutoriza
		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "2C"+ STR0063 )  //"Confirma o Fechamento deste Caixa?"
 		End
		If MsgYesNo(STR0063, STR0003)	// "Confirma o Fechamento deste Caixa?", "Atenção"
			oCupom:Add("")
			oCupom:Add(FRT_SEPARATOR)
			oCupom:Add(STR0064)	// " F E C H A M E N T O   D O   C A I X A  "
			oCupom:Add("")
			oCupom:Add(STR0058+cUserName+STR0059+xNumCaixa())	// "Usuário: " " Caixa: "
			oCupom:Add(DToC(dDatabase)+" "+Time()+Space(13)+STR0030+PadR(cPDV,4))
			oCupom:Add(FRT_SEPARATOR)
			oCupom:GoBottom()
			cCupom := oCupom:aItems[Len(oCupom:aItems)-1]
			cx_abre_fecha(SA6->A6_COD, "F")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informar que Houve Troca de Operador ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTGeraSLI(cEstacao, "OPE", "", "SOBREPOE")
			FClose(nHdlOPE)
			lCXAberto := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibir Mensagem de Caixa Fechado no Display ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(4)
		Else
			If lUsaDisplay
				DisplayEnv(StatDisplay(), "2E"+ STR0254)
				DisplayEnv(StatDisplay(), "1E"+ " ")
	   		End
		EndIf
	Else
		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "2C"+ STR0260)  //"Usuário sem permissão para fechar caixa"
 		End

		HELP(' ',1,'FRT022')	// "Usuário sem permissão para fechar o caixa.", "Atenção"   

		If lUsaDisplay
			DisplayEnv(StatDisplay(), "2E"+ STR0254)
			DisplayEnv(StatDisplay(), "1E"+ " ")
	   	End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTDescIT ³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Desconto no Total do Item (F6)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Valor Percentual do desconto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTDescIT()
Local oDlgDescItem							// Objeto da tela de desconto do item
Local oPercDesc								// Objeto de Get do desconto digitado pelo usuario
Local nPercDesc	:= 0						// Conteudo do percentual de desconto
Local aKey		:= {}						// Array com as setkeys definidas
Local lConfDesc	:=.F.						// Valida se o desconto foi confirmado pelo botao OK
Local oValorDesc							// objeto de Get do Valor do Desconto
Local nValorDesc:= 0						// Conteudo do Valor concedido de desconto

If lRecebe
	Return(NIL)
EndIf

If CheckCaixa(@lCXAberto, @lUsaDisplay )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica se o item atual JA TEVE DESCONTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDescIT .OR. ( lDescIT .AND. !lDescITReg )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Permissao "Efetuar Descontos" - #11 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgDescItem FROM  1,1 TO 130,300 TITLE STR0066 PIXEL	// "Desconto no total do item"
			@ 6, 04 BITMAP RESOURCE "DISCOUNT" OF oDlgDescItem PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
			@ 04, 40 TO 28, 110 LABEL STR0067 OF oDlgDescItem  PIXEL	// "% Desconto"
			@ 04, 90 TO 28, 160 LABEL STR0330 OF oDlgDescItem  PIXEL	// "Valor do Desconto"

			@ 13, 45 MSGET oPercDesc VAR nPercDesc SIZE 40, 10 OF oDlgDescItem PICTURE "@E 99.99" RIGHT PIXEL ;
					VALID FrtVldDes( nPercDesc , nValorDesc , 1)

			@ 13, 95 MSGET oValorDesc VAR nValorDesc SIZE 40, 10 OF oDlgDescItem PICTURE "@E 999,999.99" RIGHT PIXEL ;
					VALID FrtVldDes( nPercDesc , nValorDesc , 2)					
	
			DEFINE SBUTTON FROM 38, 50 TYPE 1 ENABLE OF oDlgDescItem ;
				ACTION ( lConfDesc := .T., oDlgDescItem:End() ) PIXEL

			DEFINE SBUTTON FROM 38, 85 TYPE 2 ENABLE OF oDlgDescItem ;
				ACTION ( lConfDesc := .F., oDlgDescItem:End() ) PIXEL

		ACTIVATE MSDIALOG oDlgDescItem CENTERED

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirmou desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConfDesc .AND. (nPercDesc > 0 .OR. nValorDesc > 0) .AND. lDescITReg
			If nPercDesc == 0
				nPercDesc := (nValorDesc/SL2->L2_VLRITEM) * 100
			EndIf		
			nVlrPercIT	:= nPercDesc
			nVlrDescIT	:= Round( SL2->L2_VLRITEM * ( nVlrPercIT / 100 ), nDecimais )
			nRet		:= IFRegItem( nHdlECF, "", "", "", "", AllTrim( Str( nVlrDescIT,14,TamSX3("BI_PRV")[2] ) ), "", "" )

			If nRet <> 0
				HELP(' ',1,'FRT024')	//"Não foi possível registrar o desconto no item. Operação não efetuada.", "Atenção"
				nVlrPercIT	:= 0
				nVlrDescIT	:= 0
			Else
				oCupom:Add( STR0039 + Trans( nVlrPercIT,"@R 99.99%" ) )  // "Desconto de :  "
				aItens[Len(aItens)][6]	:= ( SL2->L2_VLRITEM-nVlrDescIT ) / SL2->L2_QUANT
				aItens[Len(aItens)][7]	:= ( SL2->L2_VLRITEM-nVlrDescIT )
				aItens[Len(aItens)][8]	:= nVlrDescIT

				FRTGeraSL("SL2", {{"L2_DESC",		nVlrPercIT },;
								  {"L2_VALDESC",	nVlrDescIT },;
								  {"L2_VLRITEM",	( SL2->L2_VLRITEM - nVlrDescIT ) },;
								  {"L2_VRUNIT",		( SL2->L2_VLRITEM - nVlrDescIT ) / SL2->L2_QUANT } } )

				nVlrTotal -= nVlrDescIT
				nVlrBruto -= nVlrDescIT
				lDescIT := .T.
			EndIf

		ElseIf lConfDesc .AND. !lDescITReg
			nVlrPercIT := nPercDesc
			nVlrDescIT := nValorDesc			
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	oDesconto:Refresh()
EndIf

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTEditQtd³ Autor ³ Vendas Clientes       ³ Data ³15/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a Quantidade do Item (F7)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTEditQtd()
If lRecebe
	Return(NIL)
EndIf

If ! CheckCaixa(@lCXAberto, @lUsaDisplay )								// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
Else
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1E" + STR0257 )         //"Quantidade: "
	EndIf	
	oTmpQuant:Enable()
	oTmpQuant:nTop  := 230
	oTmpQuant:nLeft := 10
	oTmpQuant:Refresh()
	oTmpQuant:SetFocus()
EndIf      
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTCancIT³ Autor ³ Vendas Clientes       ³ Data ³05/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o Cancelamento de um Item (F8)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTCancIT()
Local cVlrItem
Local nRet
Local cRet         := ""
Local cSupervisor  := Space(15)
Local oCancItem
Local oCancQtde 
Local oCancProd
Local nCancItem    := 0
Local cCancProd    := Space(TamSX3("BI_DESC")[1])
Local nCancQtde    := 0
Local lContinua    := .F.
Local cQualItem    := Space(10)
Local aKey
Local nX
Local nI
Local nE
Local nY
Local nMaxElem     := 1
Local _aItens
Local aCancItens   := {}
Local nQtdeNova    := 0
Local cCodigo
Local nDec 		   := TamSX3("L2_QUANT")[2]

Local lFRTCODB2t   := ExistTemplate("FRTCODB2")	// verifica se existe o PONTO DE ENTRADA FRTCODB2
Local lFRTCancelat := ExistTemplate("FRTCancela")// verifica se existe o PONTO DE ENTRADA FRTCancela

If lRecebe
	Return(NIL)
EndIf

If !CheckCaixa(@lCXAberto, @lUsaDisplay ) .OR. Len(aItens)=0			// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Cancelamento Item" - #7 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LJProfile(7, @cSupervisor)						// Verifica Permissao

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se é possivel cancelar todos ou o ultimo item            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := IfStatus(nHdlECF, "4", @cQualItem)
		
		nCancItem := FRTLastIT()
		If Upper(AllTrim(cQualItem))=="TODOS"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pergunta qual o item a cancelar                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "POR"
			   If ExistBlock("FRTCODBR")
                  nI := ExecBlock("FRTCODBR",.F.,.F.,{aItens})
                  If nI <> 0
                     lContinua:=.T.
                  EndIf   
			   Else
     			   DEFINE MSDIALOG oDlgCancela FROM 0,0 TO 100,200 OF GetWndDefault() TITLE STR0129 PIXEL	//"Cancelamento de Item"
			       @ 10,10 SAY STR0130 PIXEL	//"Nº do Item"
			       // AIT_ITEM e AIT_CANCELADO Estao Dentro do CodeBlock Abaixo...
			       @ 10,50 MSGET oCancItem VAR nCancItem PIXEL SIZE 20,08 PICTURE "@E 99999" VALID ((nI := AScan(aItens, {|x| x[1]=nCancItem .AND. !x[11]}))>0)
  				   oCancItem:cSx1Hlp:="L2_ITEM"
			
			       DEFINE SBUTTON FROM 30, 30 TYPE 1 ACTION (lContinua:=.T.,oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
			       DEFINE SBUTTON FROM 30, 60 TYPE 2 ACTION (oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
			       ACTIVATE MSDIALOG oDlgCancela CENTERED
		      EndIf    
			Else       
				DEFINE MSDIALOG oDlgCancela FROM 0,0 TO 180,300 OF GetWndDefault() TITLE STR0129 PIXEL	//"Cancelamento de Item"
				@ 10,10 SAY STR0130 PIXEL	//"Nº do Item"
				@ 10,60 MSGET oCancItem VAR nCancItem PIXEL SIZE 20,08 PICTURE "@E 99999" ;
				VALID  (((nI := AScan(aItens, {|x| x[AIT_ITEM]=nCancItem .AND. !x[AIT_CANCELADO]})) >0) .OR. (nCancItem == 0))
				oCancItem:cSx1Hlp:="L2_ITEM"

				@ 30,10 SAY STR0005 PIXEL //"Produto"	
				@ 30,60 MSGET oCancProd VAR cCancProd PIXEL SIZE 60,08 PICTURE PesqPict("SBI","BI_COD",15) F3 "FRT" ;
				VALID (((nI := AScan(aItens, {|x| Trim(x[AIT_COD])=Trim(cCancProd) .AND. !x[AIT_CANCELADO]})) > 0) .OR.;
				       ((nI := AScan(aItens, {|x| Trim(x[AIT_CODBAR])=Trim(cCancProd) .AND. !x[AIT_CANCELADO]})) > 0)) ;
				WHEN (nCancItem == 0)
				oCancProd:cSx1Hlp:="L2_PRODUTO"
				
				@ 50,10 SAY STR0163 PIXEL	//"Qtde. a Cancelar"
				@ 50,60 MSGET oCancQtde VAR nCancQtde PIXEL SIZE 20,08 PICTURE PesqPictQt("L2_QUANT",7) ; 
				VALID FrtSomaIt(cCancProd,nCancQtde,@aCancItens,@nQtdeNova) ;
				WHEN (nCancItem == 0 .AND. !(FrtPesqMult(cCancProd,@aCancItens,@nCancQtde)))
				oCancQtde:cSx1Hlp:="L2_QUANT"

				DEFINE SBUTTON FROM 70, 30 TYPE 1 ACTION (lContinua:=.T.,oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
				DEFINE SBUTTON FROM 70, 60 TYPE 2 ACTION (oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
			    ACTIVATE MSDIALOG oDlgCancela CENTERED
			EndIf
			
			
		Else
			If nCancItem>0 .AND. !aItens[nCancItem][AIT_CANCELADO]
				lContinua := MsgYesNo(STR0131,STR0129) // "Somente poderá ser cancelado o último item. Confirma o cancelamento ?"|"Cancelamento de Item"
				nI := nCancItem
			EndIf
		Endif
		
        If cPaisLoc == "POR"
			If nCancItem <> 0
				AAdd(aCancItens,(nCancItem))
			EndIf			
			_aItens  := CancProdMult( aCancItens )
			nMaxElem := if(Len(_aItens)>1,Len(_aItens),If(Len(aCancItens)>1,Len(aCancItens),1))
		EndIf

		For nx:= 1 To nMaxElem
			If cPaisloc == "POR"
			    If nMaxElem > 1
					nI := aScan(aItens,{|x| x[1]==If(!Empty(_aItens),_aItens[nx],aCancItens[nx])})
	  			Else
	 				If nCancItem <> 0
	 					nI := aScan(aItens,{|x| x[1]==nCancItem})
	 				Else
						nI := If(!Empty(aCancItens),aScan(aItens,{|x| x[1]==aCancItens[nx]}),0)
					EndIf	 					
	  			EndIf
	  			If (nI == 0) .OR. Empty(aItens)
	  			 	Exit
	  			Endif
			EndIf
			If lContinua .AND. nI <> 0 .AND. !aItens[nI][AIT_CANCELADO]			// Se Existe Itens a Cancelar
				nRet := IFStatus(nHdlECF, "9", @cRet)							// Verifico o Status do ECF
				If nRet <> 0
					HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os SetKey's do Fechamento da Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTSetKey(aKey)
					Return(NIL)
				EndIf

				DbSelectArea("SL2")
				DbSetOrder(1)
				DbSeek(xFilial("SL2")+cOrcam+FRTPegaIT(aItens[nI][AIT_ITEM]))
				aSL2 := {{"L2_SITUA",	"05"}}				// "05" - Solicitado o Cancelamento do Item
				FRTGeraSL("SL2", aSL2)
	
				cCodigo := aItens[nI][AIT_CODBAR]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAux := {aItens[nI][AIT_ITEM], aItens[nI][AIT_COD], cCodigo, "", "", "", "", "", "", "", .F.,aItens[nI][AIT_VALSOL]}
				If lFRTCODB2t
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adicionando Variaveis STATIC no final do array          ³
					//³para que as mesmas possam ser tratadas nas EXECTEMPLATES³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aAux,uProdTPL)
					aAdd(aAux,uCliTPL)					

					aAux := ExecTemplate("FRTCODB2",.F.,.F.,{aAux,uProdTPL,uCliTPL})
					cCodigo := Padr(aAux[3],TamSX3("BI_CODBAR")[1])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³valorizando variaveis do tipo STATIC³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ValType( aAux[13] ) == "A"
						uProdTPL := aClone(aAux[13])
					Else
						uProdTPL := aAux[13]
					Endif
					If ValType( aAux[14] ) == "A"
						uCliTPL  := aClone(aAux[14])
					Else
						uCliTPL  := aAux[14]
					Endif
				EndIf
				If ExistBlock("FRTCODB2")
					aAux := ExecBlock("FRTCODB2",.F.,.F.,aAux)
					cCodigo := Padr(aAux[3],TamSX3("BI_CODBAR")[1])
				EndIf
				MsgDisplay(9,{Str(aItens[nI][AIT_ITEM],3), cCodigo, aItens[nI][AIT_DESCRI], aItens[nI][AIT_QUANT],;
					aItens[nI][AIT_VRUNIT], aItens[nI][AIT_VALDESC], aItens[nI][AIT_ALIQUOTA]})
					
				If lUsaDispTor
					MsgDispTor( 9,{Str(aItens[nI][AIT_ITEM],3), cCodigo, aItens[nI][AIT_DESCRI], aItens[nI][AIT_QUANT],;
				   					aItens[nI][AIT_VRUNIT], aItens[nI][AIT_VALDESC], aItens[nI][AIT_ALIQUOTA]})   	
				EndIf   					
					
				nRet := IFCancItem(nHdlECF, Str(aItens[nI][AIT_ITEM],3),;
											cCodigo,;
											aItens[nI][AIT_DESCRI],;
											AllTrim(Str(aItens[nI][AIT_QUANT],7,nDec)),;
											AllTrim(Str(aItens[nI][AIT_VRUNIT],14,2)),;
											AllTrim(Str(aItens[nI][AIT_VALDESC],14,2)),;
											aItens[nI][AIT_ALIQUOTA])
				If nRet == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o valor da deducao de ICMS no cancelamento do item³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    SF4->(DbSetOrder(1))
				    If SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
				       If SF4->F4_AGREG == "D"
					      nTotDedIcms -= aItens[nI][AIT_DEDICMS]
					   Endif   
				    Endif	  
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar o Item ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("SL2", .F.)
					dbDelete()
					MsUnLock()
	
					aItens[nI][AIT_CANCELADO] := .T.								// Marca Como Cancelado
					nVlrTotal-= (aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
					nVlrBruto-= (aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
					oVlrTotal:Refresh()
	
					cVlrItem := Transform((aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL]), PesqPict("SL2","L2_VLRITEM",13,nMoedaCor))
					oCupom:Add( "")
					oCupom:Add( STR0068+StrZero(aItens[nI][AIT_ITEM],3)+STR0069)	// "I T E M  " "  C A N C E L A D O"
					oCupom:Add( Space(19)+aItens[nI][AIT_ALIQUOTA]+"%"+cVlrItem )
					oCupom:GoBottom()
					cCupom := oCupom:aItems[Len(oCupom:aItems)-1]
	
					nTotItens--
					oTotItens:Refresh()
					
					If cPaisLoc <> "BRA"                
						//Abate o valor dos impostos, referente ao item excluido, 
						//do array aImpsSL1, para futura gravacao no arquivo SL1.
		       			For nY := 1 To Len(aImpsSL2[nI][3])
		       				nE := Ascan( aImpsSL1,{|x| x[1] == aImpsSL2[nI][3][nY][1]})
			   				aImpsSL1[ nE,3 ] -= aImpsSL2[nI][3][nY][4]	//Valor do imposto no cabecalho		   			   
			   				aImpsSL1[ nE,5 ] -= aImpsSL2[nI][3][nY][3]	//Base do imposto no cabecalho		   			   		   						
						Next nY

						//Marca como cancelada a posicao referente no aImpsSL2
						aCols[nI][Len(aHeader)+1] := .T.
					
						//Marca como cancelada a posicao referente no aImpsSL2
						aImpsSL2[nI][5] := .T.
						                      
						//Marca como cancelada a posicao referente no aImpsProd
						aImpsProd[nI][5] := .T.
						
						FrtTotVen()
					EndIf
	                
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ P.E. Apos o Cancelamento        ³
					//³ Tipo      : 1 - Item            ³
					//³             2 - Cupom           ³
					//³ Supervisor: Senha que autorizou ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFRTCancelat
						uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{1,cSupervisor,aItens[nI][AIT_ITEM],uProdTPL})
					EndIf
					If ExistBlock("FRTCancela")
						ExecBlock("FRTCancela",.F.,.F.,{1,cSupervisor})
					EndIf   
					If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
					    If T_DroVerCont( aItens[nI][AIT_COD] )
							T_DroDelANVISA( .F., aItens[nI][AIT_IDANVISA] )
						Endif	
					Endif					
				EndIf
			EndIf
		Next nx
		//Lanca o item com a nova quantidade
		If (lContinua .AND. (cPaisLoc == "POR") .AND. (nQtdeNova > 0))
			//Atualiza a nova quantidade...
			nTmpQuant := nQtdeNova
			oTmpQuant:Enable()
			oTmpQuant:Refresh()
			Eval(bQtdLostFoc)
					                               
			//Informa o codigo do produto...
			cCodProd  := cCancProd
			oCodProd:Refresh()
			Eval(bCodLostFoc)
			Eval(bCodGotFoc)  
			oCodProd:SetFocus()
				
			oTotItens:Refresh()
		EndIf
	Else
		HELP(' ',1,'FRT026')	// "Usuário sem permissão para cancelar itens.", "Atenção"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTFimVend³ Autor ³ Vendas Clientes       ³ Data ³10/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finalizacao da Venda (F9) (Sub-Total)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem transacao TEF realizada mas penden-³±±
±±³			 ³ te no servidor SiTEF que precisa ser confirmada, utilizado ³±±
±±³			 ³ no recebimento de titulos								  ³±±
±±³			 ³ ExpA2 - Array que recupera os dados de TEF multiplas tran- ³±±
±±³			 ³ sacoes no recebimento de titulos							  ³±± 
±±³			 ³ ExpC3 - Numeracao do cartao fidelidade 					  ³±±
±±³          ³ ExpL4 - Controle de multiplas transacoes TEF       	      ³±±
±±³          ³ ExpA5 - Guarda a ultima transacao TEF					  ³±±
±±³          ³ ExpC6 - Codigo do DEPENDENTE           					  ³±±
±±³          ³ ExpC7 - Nome do DEPENDENTE              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                          
Static Function FRTFimVend( lTEFPendRec, aRecTEFMult, cNCartao, lTefPendCS, ;
							aTefBKPCS  , cCodDEP    , cNomeDEP )

Local nX
Local nK
Local nI
Local nZ
Local oFimVenda
Local aKey
Local aSetKey
Local bKey
Local aSL1Datas 	 := {}
Local cRet			 := ""
Local nPosSimb       :=0
Local nTotImp        := 0
Local aSL2           := {}
Local aCondicoes	 := ljxDCondP()
Local cItemForma
Local aFormPag 
Local aFormPagF5
Local nTmpJuros		 := 0							     //Juros
Local nAux           := 0                        	     //Var Auxiliar do sistema
Local lAltParc		 := .T.
Local lEncerra       := .F.
Local nVlrTotBkp     := nVlrTotal
Local nVlrBrutoBkp   := nVlrBruto
Local nVlrMercBkp    := nVlrMerc
Local nTmpDesc       := 0                        	     //Desconto Financeiro - Localizacoes
Local aCondRecalc    := {} 							     //Var utilizada para recalculo das condicoes de pagamento
Local aAreaSFB       := {}
Local lFrtAltPg 	 := ExistBlock("FRTALTPG")
Local lTFrtAltPg 	 := ExistTemplate("FRTALTPG")
Local cMVLJTPPAG	 := SuperGetMV("MV_LJTPPAG", ,"") 	//Controle dos tipos de formas de pagto possiveis para recebimento dos titulos
Local lTefMult		 := SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local cFormaId		 := If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))
Local lHomol		 := .F.                              //Uso interno da Microsiga 
													    //Ponto de entrada exclusivo para o processo de homologação
Local bPgtosDblClick 		  

Local lVerEmpres     := Lj950Acres(SM0->M0_CGC)		// Verifica as filiais da trabalharam com acrescimento separado								
Local nImpSegVia	 := SuperGetMV("MV_FRTQTTK", ,0)	// Identifica a quantidade de Copias do Ticket

Private aFormCtrl	 := {}							//Controle das Formas de Pagamento Solicitadas
Private nTroco		 := 0							//Valor do Troco. Caso seja colocado um valor a maior em dinheiro,
													//O restante sera repassado ao nTroco, pulando a GetTroco().
Private nTroco2		 := 0							//Armazena o valor do troco que devera ser gravado em L1_TROCO1,
													//Para geracao de movimentacao bancaria local e na retaguarda
Private lDescCond	 := .F.
Private nDesconto	 := 0
Private oPgtos										//Objeto exibido de forma de oagamento analítica
Private oPgtosSint									//Objeto com exibicao da forma de pagamento sintetizada
Private aPgtos		 := {}							//Array do objeto oPgtos	
Private aPgtosSint	 := {}							//Array do objeto oPgtosSint
Private aDadosCH
Private lVendaRapida := .T.
Private cItemCond	 := "CN"
Private lCondNegF5   := .F.
Private lDescEspec   := .F.							//Desconto Especial e o "Chorinho" No final da compra.
													//Indica que o desconto deve ser rateado nas parcelas, pois o
													//valor final foi "descoberto" apos selecionar a Condicao de Pagto.
Private nTxJuros	 := 0
Private nValorBase	 := 0
Private bPesqSimb    := {|| }
Private	bSmbMoeda    := {|| }
Private	bDscMoeda    := {|| }

DEFAULT lTEFPendRec  := .F.
DEFAULT aRecTEFMult  := {}
DEFAULT cNCartao	 := "" 							//Numeracao do cartao fidelidade
DEFAULT cCodDEP		:= ""							//Codigo do DEPENDENTE 
DEFAULT cNomeDEP    := ""							//Nomde do DEPENDENTE

If FindFunction("U_LJHOMTEF") .AND. LjMSSM0(SM0->M0_CGC)
   lHomol := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o caixa nao estiver aberto nao permite utilizar tecla de funcao F9³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCxAberto
	HELP("",1,'FRT029')
	Return(aPgtos)
Endif

If Len(aItens) == 0 .AND. !lRecebe
	Return(aPgtos) 
Endif	                       

//Funcao que faz a atualizacao do database.
If !LjECFxData()
	Return(aPgtos)
EndIf

If !lRecebe
	aSL1Datas := {{"L1_EMISSAO", dDataBase},;
			      {"L1_DTLIM",	 dDataBase},;
			      {"L1_EMISNF",	 dDataBase}}
			 
	FRTGeraSL("SL1", aSL1Datas, .F.)
Endif

If !CheckCaixa(@lCXAberto, @lUsaDisplay )								// Verifica se o Caixa Esta Aberto
	Return(aPgtos)								// E exibe Mensagem Caso Esteja Fechado
EndIf

If lRecebe
	aKey := FrtSetKey()
Else
	If Len(aItens)==0 .OR. (Len(aItens)==1 .AND. aItens[1][AIT_CANCELADO])
		Return(aPgtos)
	EndIf

	If IFStatus(nHdlECF, "10", @cRet) <> 0		// Verifica se todos os itens foram impressos.
		Return(aPgtos)
	EndIf

	aKey := FrtSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IFStatus(nHdlECF, "12", @cRet) == 0
		IFNumItem(nHdlECF, @cRet)
		If Val(cRet) == nTotItens
			IFSubTotal(nHdlECF, @cRet)

			If Val(cRet)/100 <> nVlrTotal				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, ³
				//³cancele o Cupom Fiscal.", "Atenção"                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				HELP(' ',1,'FRT027')
				FrtSetKey(aKey)
				Return(aPgtos)
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³"Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Atenção"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HELP(' ',1,'FRT027')
			FrtSetKey(aKey)
			Return(aPgtos)
		EndIf
	EndIf

	If cPaisLoc == "BRA"
		oCupom:Add(STR0071+Trans(nVlrTotal,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)))  //"     S U B T O T A L      "
	Else 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So aplica o desconto ou o acrescimo caso a quantidade itens da venda³
		//³seja igual a quantidade de itens do orcamento original.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nQtdeItOri == Len(aItens)

			If (nVlrPercOri > 0) .AND. (nVlrPercOri == nVlrPercTot)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄL¿
				//³Caso exista desconto no total da venda e desconto financeiro eh ³
				//³necessario informar apenas o desconto do total da venda, pois o ³
				//³desconto financeiro sera calculado no calculo da condicao de    ³
				//³pagamento.                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄLÙ
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+cItemCOrc))
				If !Empty(SE4->E4_DESCFIN)
					nVlrPercTot -= SE4->E4_DESCFIN
					nAux        := (nVlrMerc * nVlrPercTot) / 100
				Else
					nAux        :=	nVlrDescTot			
				EndIf
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a funcao para o calculo do desconto no total da venda - Localizacoes³
				//³"Fazendo o calculo do desconto e o recalculo dos impostos..."             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJMsgRun(STR0182,,{|| FRTCDescLoc(nAux,nVlrPercTot,nVlrPercAcr,0)})
				nAux := 0
				
				oCupom:Add(FRT_SEPARATOR)
				oCupom:Add(PadL(STR0089,40))	// "Desconto no total do cupom"
				oCupom:Add(PadL(STR0090,40))	// "Valor / Percentual"
				oCupom:Add(PadL(Trans(nVlrDescTot,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nVlrPercTot,"@E 99.99")+"%",40))
				oCupom:Add(FRT_SEPARATOR)
			EndIf
		EndIf	
		AEval(aImpsSL1,{|x,y| nTotImp += aImpsSL1[y][3]})
		oCupom:Add(FRT_SEPARATOR)
		oCupom:Add(STR0071+Trans(nVlrTotal-nTotImp,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)))  //"     S U B T O T A L      "	
		aAreaSFB := SFB->(GetArea())
		SFB->(DbSetOrder(1))
		For nI := 1 To Len(aImpsSL1)  //Impressao dos impostos no cupom
			SFB->(DbSeek(xFilial("SFB")+aImpsSL1[nI][1]))
			oCupom:Add(Space(05)+SubStr(SFB->FB_DESCR,1,10)+Space(11)+Trans(aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor)))
		Next nI
		RestArea(aAreaSFB)
		nTotImp := 0
	EndIf	
	oCupom:GoBottom()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Sub-Total no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDisplay(6, {nVlrTotal})
	
	If lUsaDispTor             
		MsgDispTor(6, {nVlrTotal}) 
	EndIf	
		
	
If lUsaDisplay                   
	FRT010VlPar(nVlrTotal)
	DisplayEnv(StatDisplay(), "2C" + Upper(STR0259) )         //"Escolha a(s) forma(s) de pagamento"	
EndIf			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se o usuario possuir permissao de "Acesso Condicao Negociada". ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(cAcesso,35,1) == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permitir Condicao Negociada Igual a Venda Balcao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCondicoes, "999 - "+STR0192) //"Condição Negoc."
	EndIf
EndIf

// Formas de Pagamento Disponiveis (R$, CH e SAE's cadastrados)
MonFormPag(@aFormPag)

// Formas de Pagamento Para o F5 (Selecionando Condicao de Pagamento)
aFormPagF5 := {}
DbSelectArea( "SX5" )
DbSeek( cFilial+"24" )
While !Eof() .AND. cFilial==X5_FILIAL .AND. X5_TABELA = "24"
	DbSelectArea("SAE")
	DbSetOrder(1)
	DbSeek(xFilial("SAE"))
	If Alltrim(SX5->X5_CHAVE) == SuperGetMV("MV_SIMB1") .OR. Alltrim(SX5->X5_CHAVE) == cSimbCheq
		Aadd(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
	Else
		While xFilial("SAE") == SAE->AE_FILIAL .AND. !Eof()
			If Alltrim(SX5->X5_CHAVE) == AllTrim(SAE->AE_TIPO)
				Aadd(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
				Exit
			EndIf
			dbSkip()
		End
	EndIf
	DbSelectArea("SX5")
	dbSkip()
End

//Caso o pais seja diferente de Brasil é necessário incluir todas as moedas      
If cPaisLoc <> "BRA"
	For nI := 2 To MoedFin()
		SX5->(DbSeek(xFilial("SX5")+"24"+SuperGetMV("MV_SIMB"+Str(nI,1))))
		AAdd(aFormPag, {AllTrim(X5Descri()), SuperGetMV("MV_SIMB"+Str(nI,1)), AllTrim(X5Descri()),"   "})
	Next nI
EndIf                    

If !lRecebe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando for importado um orcamento, caso tenha desconto no total    ³
	//³ do cupom, este desconto e considerado quando vai finalizar a venda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		If nVlrDescTot > 0 .OR. nTotDedIcms > 0
			If Len(aParcOrc) <= 0
				nVlrTotal := nVlrBruto - nVlrDescTot - nTotDedIcms
			EndIf
			oVlrTotal:Refresh()

			oCupom:Add(FRT_SEPARATOR)
			oCupom:Add(PadL(STR0089,40))	// "Desconto no total do cupom"
			oCupom:Add(PadL(STR0090,40))	// "Valor / Percentual"
			oCupom:Add(PadL(Trans(nVlrDescTot + nTotDedIcms,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nVlrPercTot,"@E 99.99")+"%",40))
			oCupom:Add(FRT_SEPARATOR)
		EndIf
	Else     
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So aplica o acrescimo caso a quantidade itens da venda ³
		//³seja igual a quantidade de itens do orcamento original.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If nQtdeItOri == Len(aItens)
		
			If nVlrPercAcr > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a funcao para o calculo do acrescimo no total da venda - Localizacoes³
				//³"Fazendo o calculo do acrescimo/desconto e o recalculo dos impostos..."    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				LJMsgRun(STR0183,,{|| nVlrTotal += LjxDRecVB(	@nVlrTotal ,;
																nVlrPercAcr,;
																0          ,;
																nVlrPercTot,;
																@nVlrTotal ,;
																0          ,;
																1          ,;
																nNumParcs  ,;
																0)})
				nTmpJuros := nVlrPercAcr
				nVlrTotal += aDadosJur[1]

				oVlrTotal:Refresh()
			EndIf
		EndIf
	EndIf
	If Len(aParcOrc) > 0
		cItemCond := AllTrim(cItemCOrc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Sempre recalcula o valor total para embutir o acrescimo/desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrTotal := 0
		aEval(aParcOrc,{|x| nVlrTotal += x[2]})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso for inserido mais um produto para um orcamento     ³
		//³carregado no Front, utilizar a seguinte regra:          ³
		//³                                                        ³
		//³- Se for outra condicao qualquer, refazer as parcelas do³
		//³orcamento.                                              ³
		//³- Condicao de pagamento negociada processa normalmente, ³
		//³pois sua validacao esta na funcao FRTProdOk             ³
		//³                                                        ³
		//³16/09/2002 - Fernando Salvatori                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cItemCOrc <> "CN" .AND. lImpNewIT
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+cItemCond))

			aCondRecalc := AClone(LJ7CalcPgt( nVlrBruto - nVlrDescTot - nTotDedIcms ,cItemCond  ,NIL      ,NIL  ,;
			                                   @nTmpJuros                            ,@nTmpDesc ,nMoedaCor ))	
			nVlrTotal   := 0
			aEval(aParcOrc,{|ExpA1| ExpA1[2] := aCondRecalc[nAux+=1][2] })
			aEval(aCondRecalc,{|x| nVlrTotal += x[2]})
		
			nVlrAcreTot := 0
			If SE4->E4_ACRSFIN > 0		// Valor do acrescimo financeiro
				nVlrAcreTot	:= nVlrTotal - nVlrBruto + nVlrDescTot
			EndIf
			nVlrDescCPg := 0
			If SE4->E4_DESCFIN > 0		// Valor do desconto financeiro
				nVlrDescCPg := nVlrBruto - (nVlrTotal + nVlrDescTot + nTotDedIcms)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A 12º posição do cartão poderá conter os 4 últimos dígitos ou o ID do cartão para as múltiplas transações TEF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lVisuSint
		   aEval(aParcOrc,{|x| Aadd(x,cFormaID)})
		Else
		   aEval(aParcOrc,{|x| Aadd(x,Space(04))})			
		EndIf			   
		
		aPgtos := aClone( aParcOrc )

		//Atualizacao do valor total	
		oVlrTotal:Refresh()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  aSetKey := { {|| If(ExistBlock("FRTF4ENC"),ExecBlock('FRTF4ENC ',.F.,.F.,{aFormPag}),)},;					// F4
			{|| lAltParc:=.F., FRTCondPag(aCondicoes, @cItemForma, @nTmpJuros,;
			 	@aPgtos, oPgtos,,,@nTmpDesc),;
				lAltParc :=.T.},;													// F5  - Alterar Condicao de Pagamento
			{|| lAltParc:=.F., FRTDescTot(@nTmpJuros,@nTmpDesc),;
				lAltParc:=.T.},;													// F6  - Desconto no Total da Venda
			,;
			,;																		// F8
			{|| lAltParc:=.F., aKeyFimVenda := FrtSetKey(),;
			    If(FRTEncerra(aFormPag  ,cItemForma	,nTmpJuros    ,@lEncerra   	,;
			                  nTmpDesc  ,oFimVenda	,@lTEFPendRec ,@aRecTEFMult	,;
			                  cNCartao	,@lTefPendCS,@aTefBKPCS   ,@cCodDEP    ,;
			                  @cNomeDEP	),;
				   (IIf(LEN(aRecTEFMult) > 0, aTEFMult := AClone(aRecTEFMult),NIL),;
				    lAltParc:=.T.,oFimVenda:End()),),;
				FrtSetKey(aKeyFimVenda), lAltParc:=.T.},;					        // F9  - Encerra a Venda
			{|| lAltParc:=.F., FRTAltCli(), lAltParc:=.T.},;						// F10 - Alteracao de Clientes
			{|| lAltParc:=.F., FRTAltVend(), lAltParc:=.T.},;						// F11 - Alteracao de Vendedores
			{|| lAltParc:=.F., If(FRTFuncoes( @lTefPendCS, @aTefBKPCS ),(lAltParc:=.T.,oFimVenda:End()),),;
				lAltParc:=.T.} }													// F12 - Funcoes Diversas (Funcao)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Tecla CTRL+A Sempre Sera Dinheiro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FRTALTPG - Utilizado para omitir as formas de pagamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)][1], aFormPag[Len(aFormPag)][2],}),.T.) .AND.;
		   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)][1], aFormPag[Len(aFormPag)][2],}),.T.))
				bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)][1]+"', '"+aFormPag[Len(aFormPag)][2]+"' )}")
			Else
				bKey := Nil
			EndIf                                                                                                          
  	Else
		// Validar as formas de pagamentos validas atraves do parametro MV_LJTPPAG
		If lRecebe 
			IF aFormPag[Len(aFormPag)][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
				bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)][1]+"', '"+aFormPag[Len(aFormPag)][2]+"' )}")
			Else
				bKey := Nil
			Endif
		Else  
			bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)][1]+"', '"+aFormPag[Len(aFormPag)][2]+"' )}")
		EndIf  
	EndIf
Else
  	bPesqSimb := {|| nPosSimb := Iif(!Empty(aPgtos) .AND. IsMoney(aPgtos[oPgtos:nAt][3]),Ascan( aFormPag,{|x| Trim(x[2]) == aPgtos[oPgtos:nAt][3]}),Ascan( aFormPag,{|x| Trim(x[2]) == cSimbCor}))}
	bDscMoeda := {|| aFormPag[Eval(bPesqSimb)][1]}
	bSmbMoeda := {|| aFormPag[Eval(bPesqSimb)][2]}
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{Eval(bDscMoeda), Eval(bSmbMoeda)}),.T.) .AND.;
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{Eval(bDscMoeda), Eval(bSmbMoeda),}),.T.))
			bKey      := &("{|| FRTFormPag(aFormPag, Eval(bDscMoeda), Eval(bSmbMoeda) )}") 
		Else
			bKey := Nil
		EndIf
	Else
		bKey      := &("{|| FRTFormPag(aFormPag, Eval(bDscMoeda), Eval(bSmbMoeda) )}")
	EndIf	
EndIf
AAdd(aSetKey, bKey)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Tecla CTRL+B Sempre Sera Cheque   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)-1][1], aFormPag[Len(aFormPag)-1][2],}),.T.) .AND.; 
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)-1][1], aFormPag[Len(aFormPag)-1][2],}),.T.))
			bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)-1][1]+"', '"+aFormPag[Len(aFormPag)-1][2]+"' )}")
		Else
			bKey := Nil
		EndIf
	Else
		// Validar as formas de pagamentos validas atraves do parametro MV_LJTPPAG
		If lRecebe  
			If aFormPag[Len(aFormPag)-1][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)  
				bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)-1][1]+"', '"+aFormPag[Len(aFormPag)-1][2]+"' )}")	
			Else  
				bKey := Nil
			EndIf  
		Else  
			bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[Len(aFormPag)-1][1]+"', '"+aFormPag[Len(aFormPag)-1][2]+"' )}")  
		EndIf  
	EndIf
Else                         
	nPosSimb := Ascan( aFormPag,{|x| Trim(x[2]) == cSimbCheq})
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nPosSimb][1], aFormPag[nPosSimb][2],}),.T.) .AND.; 
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nPosSimb][1], aFormPag[nPosSimb][2],}),.T.))
			bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nPosSimb][1]+"', '"+aFormPag[nPosSimb][2]+"' )}")
		Else
			bKey := Nil
		EndIf
	Else 
			bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nPosSimb][1]+"', '"+aFormPag[nPosSimb][2]+"' )}")	
	EndIf
EndIf
AAdd(aSetKey, bKey)
For nZ := Asc("C") To Asc("Y")
   For nI := 1 To Len(aFormPag)-2
      If Left(aFormPag[nI][4],1) == Chr(nZ)
		If lFrtAltPg .OR. lTFrtAltPg
			If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{,,Chr(nZ)}),.T.) .AND.;
				Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{,,Chr(nZ)}),.T.))
				bKey := &("{|| FRTFormPag(aFormPag,,,'"+Chr(nZ)+"')}")
			 	AAdd(aSetKey, bKey)
			 	Exit
			EndIf
		Else
			If lRecebe
				If aFormPag[Len(aFormPag)][1] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
		    		bKey := &("{|| FRTFormPag(aFormPag,,,'"+Chr(nZ)+"')}")
					AAdd(aSetKey, bKey)
				EndIF  
			Else  
				bKey := &("{|| FRTFormPag(aFormPag,,,'"+Chr(nZ)+"')}")   
				AAdd(aSetKey, bKey)  
			EndIF  
			Exit
		EndIf	
      EndIf
   Next nI
Next nZ
If cPaisLoc == "BRA"
	For nI := 1 To Len(aFormPag)-2
		If Empty(aFormPag[nI][4])
			If lFrtAltPg .OR. lTFrtAltPg
				If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],}),.T.) .AND.;
				   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],}),.T.))
					bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"' )}")
					AAdd(aSetKey, bKey)
				EndIf
			Else
				If lRecebe  
					If aFormPag[nI][1] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)  
						bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"' )}")
						AAdd(aSetKey, bKey)
					EndIf  
				Else   
					bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"' )}")   
					AAdd(aSetKey, bKey)   
				EndIf  
			EndIF
		EndIf
	Next nI
Else
	nPosSimb := (Ascan( aFormPag,{|x| Trim(x[2]) == SuperGetMV("MV_SIMB1")})-2)
	For nI := 1 To nPosSimb
		If Empty(aFormPag[nI][4])	
			If lFrtAltPg .OR. lTFrtAltPg
				If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],}),.T.) .AND.;	
				   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],}),.T.))
				   bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"' )}")
				   AAdd(aSetKey, bKey)                                       
				EndIf
			Else
			   bKey := &("{|| FRTFormPag(aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"' )}")
			   AAdd(aSetKey, bKey)                                       
			EndIf
		EndIf   
	Next nI
EndIf
FRTSetKey(aSetKey)

DEFINE MSDIALOG oFimVenda FROM 160,0 TO 305,320 PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) COLOR CLR_WHITE,CLR_GRAY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os comandos abaixo foram colocados devido a um erro no ADVPL.          ³
	//³ "Preprocessor Table Overflow". Foi suprimido o Include do TCBROWSE.CH. ³
	//³ Os comandos originais devem ser mantidos para manutencao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPgtos:=TCBrowse():New(3, 3, 157, 82,,,,,,,,,{|nRow,nCol,nFlags|If(lAltParc,;
						(If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),FRT010Par(nVlrTotal),;
						LojxDin(aFormPagF5	,nVlrTotal		, NIL			,0				,;
								0			, oFimVenda		, .F.			,nVlrTotal		,;
								NIL			, NIL 			, NIL 			, NIL 			,;
								NIL			, @oPgtos		, @aPgtos		, @oPgtosAna	,;
								@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
								@cSimbCheq	, @nValorBase	, @nTaxaMoeda	, cCliente		,;
								cLojaCli	, NIL			, oDlgFrt		)),;
								oPgtos:Refresh()),)},,,,,,, .F.,, .T.,, .F., )
	oPgtos:SetArray( aPgtos )
	oPgtos:AddColumn(TCColumn():New(STR0073, {|| If(Len(aPgtos)>=oPgtos:nAt,aPgtos[oPgtos:nAt,1],'')},,,, "LEFT", 35, .F., .F.,,,, .F., ) )  //"Data"
	oPgtos:AddColumn(TCColumn():New(STR0074, {|| If(Len(aPgtos)>=oPgtos:nAt,Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  	//"Valor"
	oPgtos:AddColumn(TCColumn():New(STR0075, {|| If(Len(aPgtos)>=oPgtos:nAt,aPgtos[oPgtos:nAt,3]+IIf(ValType(aPgtos[oPgtos:nAt,4])=="C",Substr(aPgtos[oPgtos:nAt,4],4),''),'')},,,, "LEFT", 60, .F., .F.,,,, .F., ) )  				//"Forma de Pagamento"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibir o valor do acrescimo separado da parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVerEmpres
		//"Acrs.Fin"
		oPgtos:AddColumn(TCColumn():New(STR0314,{|| If(Len(aPgtos)>=oPgtos:nAt,Transform(aPgtos[oPgtos:nAt,13],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  //"Acrescimo"	
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao da 12 posicao para a digitacao dos digitos do cartao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult
	   oPgtos:AddColumn(TCColumn():New(STR0278, {|| aPgtos[oPgtos:nAt,12] },,,, "LEFT", 60, .F., .F.,,,, .F., ) ) //"Dígitos Cartão"
	EndIf
	If cPaisLoc <> "BRA"
		oPgtos:AddColumn(TCColumn():New(STR0145, {|| Transform(aPgtos[oPgtos:nAt,11],PesqPict("SL1","L1_MOEDA",02))},,,, "LEFT", 35, .F., .F.,,,, .F., ) )  //"Moeda"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Evita erro ao pressionar a tecla <Enter> e o array aPgtos estiver com conteúdo nulo...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		If Empty(aPgtos)
			oPgtos:Disable()
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utiliza o novo tipo de visualização de parcelas sintetizado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVisuSint

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se ao carregar o orcamento estiver utilizando a forma de visualizacao sintetizada   ³
		//³atualiza com o array aPgtos que ja foi atualizado ao carregar o orcamento c/ F12-21 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aParcOrc) > 0 .AND. Len(aPgtos) > 0 .AND. Len(aPgtosSint) == 0
			aPgtosSint:= FrtMontPgt(aPgtos)
		Endif	
					
		oPgtosSint:= TCBrowse():New(3, 3, 157, 82,,,,,,,,,bPgtosDblClick,,,,,,, .F.,, .T.,, .F., )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do array aPgtosSint                                ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ [1] - Forma de Pagamento                                     ³
		//³ [2] - Qtde de Parcelas da forma de pagto                     ³
		//³ [3] - Valor total desta forma de pagamento                   ³
		//| [4] - Sequencia para controle de múltiplas transaçõies		 |
		//³ [5] - Data da primeira parcela                               ³	
		//³ [6] - Codigo da Administradora financeira                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPgtosSint:SetArray(aPgtosSint)
		
		oPgtosSint:AddColumn(TCColumn():New(STR0073, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,5],'')} ,,,, "LEFT" , 25, .F., .F.,,,, .F., ) )  //"Data"
		oPgtosSint:AddColumn(TCColumn():New(STR0291, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,1],'')} ,,,, "LEFT" , 20, .F., .F.,,,, .F., ) )  //"Forma"
		oPgtosSint:AddColumn(TCColumn():New(STR0074, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,3],'')} ,,,, "RIGHT", 50, .F., .F.,,,, .F., ) )  //"Valor"
		oPgtosSint:AddColumn(TCColumn():New(STR0207, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,2],'')} ,,,, "RIGHT", If(lUsaTef .AND. lTefMult,25,55) , .F., .F.,,,, .F., ) )  //"Parcelas"
		//Só inserir a coluna ID Cartão quando o cliente trabalhar com múltiplas transações TEF
		If lUsaTef .AND. lTefMult
			oPgtosSint:AddColumn(TCColumn():New(STR0288, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,4],'')},,,,  "RIGHT", 30, .F., .F.,,,, .F., ) ) //"ID Cartão"
		EndIf

		//Durante a homologação o sistema não deve permitir entrar na tela de detalhe da forma de pagamento devido a exibição do parcelamento
		If !lHomol
			oPgtosSint:bLDblClick := {|| FrtAltPgSi(oPgtosSint:nAt, 	lAltParc,	aFormPagF5,	oFimVenda, ;
													aTefBKPCS) }
		EndIf
	
		// Evita erro ao pressionar a tecla <Enter> e o array aPgtos estiver com conteúdo nulo...
		If Empty(aPgtosSint)
			oPgtosSint:Disable()
		Else
			oPgtosSint:SetFocus()
		EndIf
		
	EndIf								 

	
ACTIVATE MSDIALOG oFimVenda VALID FRTVldFimV(	lAltParc, lEncerra, nVlrDescTot, @lTefPendCS, ;
												@aTefBKPCS	) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi alterado a forma de pagamento de um orcamento importado da Venda Balcao, ³
//³ ao abandonar a finalizacao da venda, recupera os valores.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aParcOrcOld) > 0
	aParcOrc := aParcOrcOld
	aParcOrcOld := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o acerto dos arquivos, caso o usuario nao confirme o ³
//³encerramento da venda...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lEncerra .AND. (cPaisLoc <> "BRA")
	If lRecalImp
		aCols    := {}
		aImpsSL1 := {}
		For nI := 1 to Len(aImpsProd)
			If !aImpsProd[nI][5]
		 		aProdSL2 := {}
				For nX := 1 To Len(aImpsProd[nI][03])                                                 
			    	If (nE := Ascan(aImpsSL1,{|x| x[1] == aImpsProd[nI][3][nX][1]})) == 0
			    	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valorizo o array aImpsSL1 com base no array aImpsProd que³
						//³possui os dados originais da venda...                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        	AAdd(aImpsSL1,{aImpsProd[nI][3][nX][1],aImpsProd[nI][3][nX][8],0,;
			        	               aImpsProd[nI][3][nX][9],0,SubStr(aImpsProd[nI][3][nX][5],2,1),;
			        	               aImpsProd[nI][3][nX][4]})		    		    
			     		nE := Len(aImpsSL1)
			       	EndIf   
				   	aImpsSL1[ nE,3 ] += aImpsProd[nI][3][nX][4]	//Valor do imposto no cabecalho		   			   
				   	aImpsSL1[ nE,5 ] += aImpsProd[nI][3][nX][3]	//Base do imposto no cabecalho		   			   		   
			       	nValImp  := aImpsProd[nI][3][nX][4]
				   	aImposto := aClone(aImpsProd[nI][03][nX])
					nTotImp  += (nValImp * aImposto[10][Val(Subs(aImposto[5],2,1))])			   
		    	Next nX                         
		    	aImpsSL2[nI] := aClone(aImpsProd[nI])
				
				aProdSL2 := {{"L2_VRUNIT" , aImpsProd[nI][3][1][12]},;
				             {"L2_VLRITEM", aImpsProd[nI][3][1][11]*aImpsProd[nI][3][1][12]},;
				             {"L2_DESCPRO", 0},;
				             {"L2_ITEM"   , aImpsProd[nI][4]}}
		    	
		  		For nK := 1 to Len(aImpsSL2[nI][3])
		       		Aadd(aProdSL2,{aImpsSL2[nI][3][nK][6],aImpsSL2[nI][3][nK][4]})   //Valor do imposto
		       		Aadd(aProdSL2,{aImpsSL2[nI][3][nK][7],aImpsSL2[nI][3][nK][3]})   //Base do imposto         
		       		Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nK][7],10,1),aImpsSL2[nI][3][nK][2]})   //Aliquota do imposto                           
		   		Next nK   
				AAdd(aSL2,aClone(aProdSL2))
		   		FRTSimACols(aImpsProd[nI][1],aImpsProd[nI][3][1][11],;
		   		            aImpsProd[nI][3][1][12],aImpsProd[nI][2],"",;
		   		            aImpsProd[nI][4])
		   	Else  
		   		FRTSimACols(aImpsProd[nI][1],aImpsProd[nI][3][1][11],;
		   					aImpsProd[nI][3][1][12],aImpsProd[nI][2],"",;
		   					aImpsProd[nI][4],.T.)	   	
		   	EndIf	            
	    Next nI                        
		FRTGravaSL2(aSL2)
		
		//Retorna os totais originais...	
		nVlrTotal 	:= nVlrTotBkp
		nVlrBruto 	:= nVlrBrutoBkp
		nVlrMerc  	:= nVlrMercBkp     
		lRecalImp := .F.
		
		//Zera o array aDadosJur
		AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })
	EndIf
	aCProva := {}
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento realizado para TEF pendente, utilizando a CLISITEF.³
	//³Caso o usuario abandone a tela de forma de pagamento e exista ³
	//³uma transacao TEF Pendente, mando uma nao confirmacao.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTefPendCS
		lTefPendCS := .F.
		aTefBKPCS  := {}
		oTEF:FinalTrn(0)
	EndIf
EndIf

nVlrTotal := nVlrBruto
oVlrTotal:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
If lUsaDisplay
	DisplayEnv(StatDisplay(), "2E"+ STR0254)
	DisplayEnv(StatDisplay(), "1E"+ " ")
End    

If ( nImpSegVia > 0 ) .AND. ( cPaisLoc <> "BRA" )
    FrtImpVia2( nImpSegVia )
EndIf    

Return(aPgtos)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTVldFimV³ Autor ³ Vendas Clientes       ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                     					        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA010()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTVldFimV( lAltParc, lEncerra, nVlrDescTot, lTefPendCS, ;
							aTefBKPCS )
Local lRet
If lRecebe
	// "Confirma o cancelamento do(s) recebimento(s) em andamento?", "Atenção"
	If MsgYesNo(STR0237, STR0003)
		lRecebe := .F.
		aItens	:= {}
		aPgtos	:= {}
		aTEFPend:= {}		
		aBckTEFMult := {}
		lOcioso	:= .T.
		lVerTEFPend  := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera o valor e o percentual de desconto do item       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrPercIT := 0
		nVlrDescIT := 0 
		nLastTotal:= nVlrTotal
		nLastItem := nTotItens
		nTotItens := 0
		nVlrTotal := 0
		nVlrBruto := 0
		nVlrMerc  := 0
		nTotDedIcms  := 0		
		lImpOrc   := .F.  
		oDesconto:Refresh()
		oTotItens:Refresh()
		oVlrTotal:Refresh()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reinicializa as variáveis de Templates                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		uCliTPL := Nil     
		uProdTPL:= Nil
		cCodConv:= "" 		
		cLojConv:= ""
		cNumCartConv := ""
		FRTInitIT(.T.)
		FRTHora(.T.)
		If oFotoProd:cBMPFile <> "LOJAWIN"
			ShowBitMap(oFotoProd,"LOJAWIN")
		EndIf

		lRet := .T.
	Else
		lRet := .F.
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		If lOcioso
			lRet := .T.
		Else
			If nVlrDescTot > 0 .OR. Len(aPgtos) > 0
				lRet := .F.
			Else
				lRet := lAltParc
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄL¿
		//³Caso a impressão do desconto seja concomitante, não será zerado.³
		//³Por isso a chamada da LJAnalisaLeg(14)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄLÙ	
		If (!lEncerra) .AND. (nVlrDescTot > 0) .AND. (!LjAnalisaLeg( 14 )[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o operador volte para a tela de lançamento de itens (tecle ESC), ³
			//³o desconto no total será zerado. 									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTDescTot( 0,0,.F.)
		EndIf
		lRet := lAltParc
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento realizado para TEF pendente, utilizando a CLISITEF.³
//³Caso o usuario abandone a tela de forma de pagamento e exista ³
//³uma transacao TEF Pendente, mando uma nao confirmacao.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTefPendCS
	lTefPendCS := .F.
	aTefBKPCS  := {}
	oTEF:FinalTrn(0)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAltCli ³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao do Cliente	(F10)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numeracao do cartao fidelidade 					  ³±±
±±³          ³ ExpC2 - Codigo do DEPENDENTE           	 				  ³±±
±±³          ³ ExpC3 - Nome do DEPENDENTE             					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTAltCli( cNCartao, cCodDEP, cNomeDEP )
Local cCliFrt 		:= cCliente
Local cLojFrt 		:= cLojaCli
Local cNomeCli 		:= Subst(Posicione("SA1",1,xFilial("SA1")+cCliente+cLojaCli,"A1_NOME"),1,30)
Local aRetCart      := {}                       // Contem o tipo e numero do documento do cliente da venda
Local lCliente 		:= .T.                      // Indica se o cliente foi encontrado na base
Local aCliente      := {}                       // Dados do cliente, utilizado para comparacao com a base local do PDV
Local nPosCli		:= 0	                    // Posicao do campo A1_COD no array a clientes
Local nPosLoja		:= 0	                    // Posicao do campo A1_LOJA no array a clientes
Local lNovoCliente 	:= .T.	                    // Variavel que indica se cria ou nao um novo registro no SA1
Local nX			:= 0 						// Variavel para controle de looping
Local aRegsSA1		:= {}						// Utilizada no WSCrdConscli para trazer o cliente para o PDV
Local aDadosCli     := {}						// Contem numero do cartao, CNPJ/CPF, codigo e loja do cliente selecionado
Local lRet          := .T.						// Define se prossegue a operacao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis do Template de Drogaria						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodMA6		:= ""   					// codigo do cliente no cadastro de cartoes
Local cLojaMA6 		:= ""   					// loja do cliente no cadastro de cartoes  

Local aVarTemplate  := {}						// Array que contera valores de Variaveis do tipo 'STATIC'
Local lFRT010CLt    := ExistTemplate("FRT010CL")// verifica se existe o PONTO DE ENTRADA FRT010CL
Local lAlteraCli    := .T.                      //Controla se pode alterar cliente
DEFAULT cNCartao	:= ""						// Numeracao do Cartao do cliente
DEFAULT cCodDEP		:= ""						// Codigo do DEPENDENTE 
DEFAULT cNomeDEP    := ""						// Nomde do DEPENDENTE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aVarTemplate  - Template Drogaria                 ³
//³---------------------------------------------------------------------³
//³-    aVarTemplate[1]  =  codigo do cliente                           ³
//³-    aVarTemplate[2]  =  loja                                        ³
//³-    aVarTemplate[3]  =  numero do cartao                            ³
//| 																	|	
//|- Eh passado como referencia na funcao  CrdIdentCli 				    |
//³---------------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRecebe
	Return(NIL)
EndIf

If lCxAberto
    //Verifica se ja foram registrados itens na venda, mesmo que estejam cancelados nao permite alterar o cliente
	If lOcioso .AND. LEN(aItens) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o Front tem integracao com o Sistema de Credito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdxInt()		
            aDadosCli     := {Space(TamSX3("MA6_NUM")[1]),;    //Numero do cartao
                  			   Space(TamSX3("A1_CGC")[1]),;     //CNPJ/CPF do cliente
                  			   Space(TamSX3("A1_COD")[1]),;     //Codigo do cliente
                  			   Space(TamSX3("A1_LOJA")[1])}     //Loja do cliente		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carregando o array que sera utilizado em outras funcoes³
			//³do Template Drogaria                                   ³
			//³11/01/2006.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aVarTemplate := { cCodConv, cLojconv, cNumCartConv }

			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Identificacao do cliente pelo cartao ou CNPJ/CPF           ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		     		
			lRet  := CrdIdentCli(  @aRetCart  	,@aDadosCli  	,@lCliente  ,.T.  	 ,;
			                       @aCliente	,@aVarTemplate	,Nil		,@cCodDEP,;
			                       @cNomeDEP )	//adicionado cCodDEP e cNomeDEP                    			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valorizando as variaveis do tipo "STATIC" criadas pela equipe³
			//³de Templates.                                                ³
			//³Template Drogaria                                            ³
			//³11/01/2006.                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodConv 	 := aVarTemplate[1]				                       
			cLojconv 	 := aVarTemplate[2]
			cNumCArtConv := aVarTemplate[3]						

            If lRet			
				aCrdCliente[1] 	:= aDadosCli[2]  //CNPJ/CPF
				aCrdCliente[2] 	:= aDadosCli[1]  //Numero do cartao	 		   
				cNCartao		:= aCrdCliente[2] //Numero do cartao  	
			   
				If !lCliente                
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Assume o cliente que foi pesquisado na retaguarda pela funcao        ³
					//³ CrdIdentCli()                                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCliente := aDadosCli[3]
					cLojaCli := aDadosCli[4]
				Else  
					cCliente := SuperGetMv( "MV_CLIPAD" )
					cLojaCli := SuperGetMV( "MV_LOJAPAD" ) 
				EndIf
			Else  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Corrigi o problema no qual o usuario pressione a tecla F10 ³
				//³por engano apos ja' ter realizado a identificacao de um    ³
				//³determinado cliente.                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCliente+cLojaCli <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD")
					If !MsgYesNo(STR0325 + RTrim(cNomeCli) + STR0326 + CHR(13)+ CHR(10)+; //"Deseja continuar a venda utilizando o cliente" ## " ?"
					             STR0327)//"Escolhendo a opção NÃO, a venda será efetuada para o CLIENTE PADRÃO."
						cCliente 	   	:= SuperGetMV( "MV_CLIPAD" )
						cLojaCli 	   	:= SuperGetMV( "MV_LOJAPAD" )
						uCliTPL  	   	:= ""
						aCrdCliente[1] 	:=  Space(TamSX3("A1_CGC")[1])  //CNPJ/CPF do cliente
 						aCrdCliente[2] 	:=  Space(TamSX3("MA6_NUM")[1]) //Numero do cartao
					Endif				
				Endif
			EndIf
		EndIf
		
		If lCliente .AND. lRet
			DEFINE FONT oFnt2 NAME "Arial" SIZE 11.5,22 BOLD
			DEFINE MSDIALOG oDlgAltCli FROM  47,130 TO 200,550 TITLE STR0076 PIXEL	// "Alteração de Cliente"
			@ 04, 05 TO 28, 85 LABEL STR0077 OF oDlgAltCli	PIXEL	// "Cod.Cliente / Loja"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³P.E. para nao permitir a escolha de um cliente de acordo com a regra de negocio do cliente - FRT010BL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ 13, 15 MSGET oCliFrt VAR cCliFrt SIZE 40, 10 OF oDlgAltCli F3 "FCL" PIXEL VALID ( ExistCpo("SA1",cCliFrt+cLojFrt), IIF( ExistBlock( "FRT010BL" ), ExecBlock( "FRT010BL", .F., .F., { cCliFrt + cLojFrt } ), NIL ) )
			oCliFrt:cSx1Hlp:="A1_COD"
 			@ 13, 60 MSGET oLojFrt VAR cLojFrt SIZE 15, 10 OF oDlgAltCli PIXEL	VALID ( ExistCpo("SA1",cCliFrt+cLojFrt), IIF( ExistBlock( "FRT010BL" ), ExecBlock( "FRT010BL", .F., .F., { cCliFrt + cLojFrt } ), NIL ) )
			oLojFrt:cSx1Hlp:="A1_LOJA"	
			
			@ 30, 05 TO 54, 210 LABEL STR0078 OF oDlgAltCli PIXEL	// "Nome do Cliente"
			@ 39, 15 MSGET oNomeCli VAR cNomeCli WHEN .F. PIXEL 
	
			oCliFrt:bLostFocus := { || cNomeCli := Subst(Posicione("SA1",1,xFilial("SA1")+cCliFrt+cLojFrt,"A1_NOME"),1,30), oNomeCli:Refresh() }
			oLojFrt:bLostFocus := { || cNomeCli := Subst(Posicione("SA1",1,xFilial("SA1")+cCliFrt+cLojFrt,"A1_NOME"),1,30), oLojFrt:Refresh() }
	
			DEFINE SBUTTON FROM 60, 135 oButton2 TYPE 1 ENABLE OF oDlgAltCli ;
			ACTION (cCliente := cCliFrt, cLojaCli := cLojFrt, oDlgAltCli:End()) PIXEL
		
			DEFINE SBUTTON FROM 60, 170 oButton3 TYPE 2 ENABLE OF oDlgAltCli ;
			ACTION (oDlgAltCli:End()) PIXEL
	
			ACTIVATE MSDIALOG oDlgAltCli CENTERED
		Endif			
	Else
	    lAlteraCli  := .F.	    
		HELP(' ',1,'FRT028')	// "Não é possível alterar o Cliente durante a venda.", "Atenção"
	EndIf
Else
	HELP(' ',1,'FRT029')	// "O Caixa não está aberto. Não será possível alterar o cliente.", "Atenção"     
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + SubStr(STR0080,1,23) )         //"O Caixa não está aberto.
		DisplayEnv(StatDisplay(), "2C" + SubStr(STR0080,26,35) )         //"Não será possível alterar o cliente" 
	EndIf			

EndIf
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o cadastro de clientes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SA1" )
DbSetOrder( 1 )
DbSeek( xFilial( "SA1" ) + cCliente + cLojaCli )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada "FRT010CL" para templates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRT010CLt .AND. lRet .AND. lAlteraCli
	// O template poderá retornar qualquer tipo de váriavel...
	aRetCli := ExecTemplate( "FRT010CL", .F., .F., { aRetCart, uCliTpl, cCodConv, cLojConv, cNumCartConv } )
	If ValType( aRetCli ) == "A" .AND. Len( aRetCli ) <> 2
	// Se nao satisfazer a condicao sai da tela.	
		If !aRetCli[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se voltar com a matriz vazia foi o cancelamento da tela de planos de fidelizacao ³
			//³ posiciona no cliente e loja padrao                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "SA1" )
			DbSetOrder( 1 )	 	
			cCliente := SuperGetMV( "MV_CLIPAD" )
			cLojaCli := SuperGetMV( "MV_LOJAPAD" )	 
			Return(Nil)
		EndIf                                
		uCliTpl  	 := aRetCli[2]
	    cCodConv 	 := aRetCli[3]
 		cLojConv 	 := aRetCli[4]
 		cNumCartConv := aRetCli[5]		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso a numeracao do cartão esteja em branco,  alimenta com o         ³
		//³conteudo do posicao 5 do array aRetCli.                              ³
		//³Isso ira acontecer caso a escolha do cliente seja diferente da opcao ³
		//³"Nao Magnetico".                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		If Empty(cNCartao) 
	 		cNCartao	 := aRetCli[5]			 
 		Endif
	EndIf
Endif        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada "FRT010CL"                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRT010CL")
	ExecBlock("FRT010CL")
Endif

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAltVend³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao do Vendedor (F11)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTAltVend
Local oDlgVend
Local oVendedor
Local oNomeVend
Local cVendedor := cVendLoja
Local cNomeVend := Subst(Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME"),1,30)

If lRecebe
	Return(NIL)
EndIf

If lCxAberto
    //Verifica se ja foram registrados itens na venda, mesmo que estejam cancelados nao permite alterar o vendedor    
	If lOcioso .AND. LEN(aItens) == 0
		DEFINE FONT oFnt2 NAME "Arial" SIZE 11.5,22 BOLD
		DEFINE MSDIALOG oDlgVend FROM  47,130 TO 200,550 TITLE STR0175 PIXEL	// "Alteração de Vendedor"
		@ 04, 05 TO 28, 70 LABEL STR0176 OF oDlgVend	PIXEL	// "Código do Vendedor"
		@ 13, 15 MSGET oVendedor VAR cVendedor SIZE 40, 10 OF oDlgVend F3 "SA3" PIXEL VALID ExistCpo("SA3",cVendedor)
		oVendedor:cSx1Hlp:="A3_COD"

		@ 30, 05 TO 54, 210 LABEL STR0177 OF oDlgVend PIXEL	// "Nome do Vendedor"
		@ 39, 15 MSGET oNomeVend VAR cNomeVend WHEN .F. PIXEL 

		oVendedor:bLostFocus := { || cNomeVend := Subst(Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME"),1,30), oNomeVend:Refresh() }

		DEFINE SBUTTON FROM 60, 135 oButton2 TYPE 1 ENABLE OF oDlgVend ;
		ACTION (lAltVend:=.T., cVendLoja := cVendedor, oDlgVend:End()) PIXEL
	
		DEFINE SBUTTON FROM 60, 170 oButton3 TYPE 2 ENABLE OF oDlgVend ;
		ACTION (oDlgVend:End()) PIXEL

		ACTIVATE MSDIALOG oDlgVend CENTERED
	Else
		HELP(' ',1,'FRT030')	// "Não é possível alterar o Vendedor durante a venda.", "Atenção"
	EndIf
Else
	HELP(' ',1,'FRT031')	// "O Caixa não está aberto. Não será possível alterar o Vendedor.", "Atenção"
EndIf

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTFuncoes³ Autor ³ Vendas Clientes       ³ Data ³19/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Execucao de Funcoes (F12)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem TEF pendente no SITEF.             ³±±
±±³          ³ ExpA1 - Guarda a transacao TEF Pendente					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTFuncoes(lTefPendCS, aTefBKPCS)
Local nI
Local aFuncoes
Local nLen
Local nOldLen		:= Len(oCupom:aItems)
Local cOldcCupom	:= cCupom
Local cRet			:= Space(200)
Local aKey
Local uRet 
Local lRet	 		:= .F.
Local cFuncao		:= "  "
Local nNumLinesCup 	:= 0

Local lFRTFUNCOESt := ExistTemplate("FRTFUNCOES")// verifica se existe o PONTO DE ENTRADA FRTFUNCOES 

If ! CheckCaixa(@lCXAberto, @lUsaDisplay )								// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao de permissao do caixa para as Funcoes FrontLoja   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LJProfile(12 , NIL, NIL, NIL,;
			 NIL, .T., NIL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	
	// Numero / Nome / Execucao / Retorno
	aFuncoes := {}
	aadd(aFuncoes,{"01", STR0081,"If(lOcioso,IFAbrECF(nHdlECF),)",                      {|x| .F.}})	// "Abrir ECF"
		aadd(aFuncoes,{"02", STR0082,"If(lOcioso .AND. LJProfile(6),(FRTReducao(),0),999)",	{|x| (x==999).OR.(x==0)}})// "Fechar ECF (Redução Z)"
		aadd(aFuncoes,{"--", "",     "",                                                  	{|x| .F.}})
		aadd(aFuncoes,{"03", STR0083,"FRTCancCup(), FrtAtuCli(), FrtSetCrd()", 	{|x|  x }})// "Cancelar Cupom"
		aadd(aFuncoes,{"--", "",     "",                                                   	{|x| .F.}})
		aadd(aFuncoes,{"04", STR0084,"If(lOcioso,(IFLeituraX(nHdlECF),FRTHora(.T.)),)",    	{|x| .F.}})// "Leitura X"
		aadd(aFuncoes,{"--", "",     "",                                                   	{|x| .F.}})
		aadd(aFuncoes,{"05", If(cPaisLoc $ "POR|EUA",STR0137,STR0085),"FRTA050(1)",			{|x| .F.}})// "Sangria"
		aadd(aFuncoes,{"06", STR0086,"FRTA050(2)",                                         	{|x| .F.}})// "Entrada de Troco"
		aadd(aFuncoes,{"--", "",     "",                                                   	{|x| .F.}})
		aadd(aFuncoes,{"07", STR0128,"LJ060VIS('SBI',0,2)", 							   	{|x| .F.}})// "Consulta de Produto"
		If lUsaTef
			aadd(aFuncoes,{"--", "",     "",                          						{|x| .F.}})
			If cTipTef == TEF_CLISITEF
				aadd(aFuncoes,{"09",STR0294,"LJRotTEF()",                 					{|x| .F.}})// "TEF - Gerenciais"
			Else
				aadd(aFuncoes,{"08",STR0134,"LOJA012T()",                 					{|x| .F.}})// "Consulta TEF"
				aadd(aFuncoes,{"09",STR0135,"LOJA019T()",                 					{|x| .F.}})// "Funções ADM"
				aadd(aFuncoes,{"11",STR0139,"LOJA011T()",                 					{|x| .F.}})// "Cancela Tr. TEF"
				aadd(aFuncoes,{"30",STR0276,"LOJA024T()",                 					{|x| .F.}})// "Reimpressão TEF (Visa)"
				aadd(aFuncoes,{"31",STR0277,"LOJA013S()",                 					{|x| .F.}})// "Reimpressão TEF (Outros)"
			EndIf
			aadd(aFuncoes,{"--", "",     "",                          						{|x| .F.}})	
		EndIf
		AAdd(aFuncoes,{"12", STR0142,"If(LjProfile(13) .AND. !Empty(LJGetStation('GAVETA')),IFGaveta(nHdlECF),)", {|x| .F.}})// Abrir Gaveta
		If cPaisLoc <> "BRA"
			aadd(aFuncoes,{"--", "",     "",             									{|x| .F.}})
			aadd(aFuncoes,{"13", STR0147,"FRTCalcVen()", 									{|x| .F.}})// "Totais da Venda - Diversas Moedas"
			If SuperGetMV("MV_TRCMOED")
				aadd(aFuncoes,{"14", STR0150,"FRTrcMoeda()", 								{|x| .F.}})// "Troca da Moeda da Venda"
				aadd(aFuncoes,{"--", "",     "",             								{|x| .F.}})
			EndIf
		EndIf
		AAdd(aFuncoes,{"15", STR0167,"If(lOcioso, LOJA180(),)", 							{|x| .F.}})// "Leitura da Memoria Fiscal"
		AAdd(aFuncoes,{"16", STR0226,"If(lOcioso, LJ200Inc(),)", 							{|x| .F.}})// "Resumo da Redução Z"
		AAdd(aFuncoes,{"17", STR0228,"FRTReceb( @lTefPendCS	, @aTefBKPCS )", 				{|x| .F.}})// "Recebimentos"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se estah integrado com o Sistema de credito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdxInt() 
			aadd(aFuncoes,{"--", "",     "",             									{|x| .F.}})
			AAdd(aFuncoes,{"18", STR0247,"CrdAExtrato( 1 )", 								{|x| .F.}})// "Extrato das parcelas"
			AAdd(aFuncoes,{"19", STR0248,"CrdAExtrato( 2 )", 								{|x| .F.}})// "Consulta limite de crédito"
			AAdd(aFuncoes,{"20", STR0249,"CrdxFila()",										{|x| .F.}})// "Medir tempo de fila"
			AAdd(aFuncoes,{"21", "Enviar para Crédito","MontaOrcam(SL1->L1_NUM),FrtAtuCli(),FrtSetCrd()",	{|x| x }})
		Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para chamar a funcao do Corresp.Bancario e PBM no FrontLoja³
	//³Retona as posicoes 22 - Correspondente Bancario                    		   ³
	//³Retona as posicoes 23 - PBM - Vidalink                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFRTFUNCOESt
		aFuncoes := ExecTemplate("FRTFUNCOES",.F.,.F.,{aFuncoes})
	EndIf
	If ExistBlock("FRTFUNCOES")
		aFuncoes := ExecBlock("FRTFUNCOES",.F.,.F.,aFuncoes)
	EndIf
	
	If !Empty(aFuncoes)
	
		FRTAddLine( FRT_SEPARATOR, @nNumLinesCup, "99" )
		FRTAddLine( "", @nNumLinesCup, "99" )
		FRTAddLine( STR0087, @nNumLinesCup, "99" )	// "Entre com o código da rotina desejada:"
		FRTAddLine( "", @nNumLinesCup, "99" )
		
		For nI := 1 to Len( aFuncoes )
			If aFuncoes[nI][1] == "--"
				cFuncao := FRTAddLine( Replicate("-",40), @nNumLinesCup, "99" )
			Else
				cFuncao := FRTAddLine( aFuncoes[nI][1]+" - "+aFuncoes[nI][2], @nNumLinesCup, "99" )
			EndIf
			
			If !Empty( cFuncao ) .OR. lEsc
				Exit
			EndIf
		Next nI
	
		If Empty( cFuncao ) .AND. ! lEsc
			FrtGet(@cFuncao, "99", @lEsc)
		EndIf       
		
		lEsc := .F.
	
		nLen := Len(oCupom:aItems)
		
		For nI := nLen To nOldLen+1 Step -1
			oCupom:Del(nI)
		Next nI
		oCupom:GoTop()
		oCupom:GoBottom()
		cCupom := cOldcCupom
	
		If (nI := AScan(aFuncoes, {|x| x[1]==AllTrim(cFuncao)})) > 0
			bCmd := &('{ |nHdlECF, cRet| ' + aFuncoes[nI][3] + ' }')
			If lUsaDisplay    
				DisplayEnv(StatDisplay(), "1C" + STR0261 )         	//"FUNCOES FRONT LOJA"		
				If cFuncao == "03"
					DisplayEnv(StatDisplay(), "2C" + STR0262 )        //"Cancelando Cupom"
				ElseIf cFuncao == "04"
					DisplayEnv(StatDisplay(), "2C" + STR0263 )        //"Emitindo Leitura X"
				ElseIf cFuncao == "07"
					DisplayEnv(StatDisplay(), "2C" + STR0264 )        //"Consulta Produto"
				ElseIf cFuncao == "11"
					DisplayEnv(StatDisplay(), "2C" + STR0265 )     	//"Cancelamento Tr. TEF"
				ElseIf cFuncao == "12"
					DisplayEnv(StatDisplay(), "2C" + STR0266 )        //"Abrir Gaveta"			
				ElseIf cFuncao == "15"
					DisplayEnv(StatDisplay(), "2C" + STR0267 )		//"Leitura da Memoria Fiscal"			
				EndIf   
			EndIf	
			uRet := Eval( bCmd, nHdlECF, @cRet )								// Execucao
			lRet := Eval( aFuncoes[nI][4], uRet )								// Retorno
			If lUsaDisplay    
				DisplayEnv(StatDisplay(), "1C" + STR0261 )         	//"FUNCOES FRONT LOJA"		
				DisplayEnv(StatDisplay(), "2C" + "" )         
			EndIf	
		EndIf
	    If ExistBlock("FRTFUNCSAI")
		   ExecBlock("FRTFUNCSAI",.F.,.F.)
	    EndIf	
	EndIf
	
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "2E"+ STR0254)
		DisplayEnv(StatDisplay(), "1E"+ " ")
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)	
EndIf
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTFormPag³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao das Formas de Pagamento da Parcela Atual (CTRL)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTFormPag( aFormPag, cDesc, cForma, cGrupo )
Local oFormPag 
Local nOpc := 2
Local nCtrl
Local nI
Local nValParc
Local nDif
Local nDel
Local cAdm
Local nValMax
Local aKey
Local oData
Local oNumParc
Local oTXJuros
Local oIntervalo
Local oValor
Local oFont
Local oMoeda
Local dData
Local nNumParc
Local nTXJuros
Local nIntervalo
Local nValor
Local cMoedaVen
Local nPosMoeda		:= nMoedaCor
Local nTamMoed1 	:= 0
Local nTamMoed2 	:= 0
Local nPosDesc  	:= 0
Local nLen
Local nOldLen	    := Len(oCupom:aItems)
Local cFuncao		:= "  "
Local cOldcCupom    := cCupom
Local cDescParcelas := ""
Local aCheques
Local aMultMoeda 	:= {}
Local cSimbMoeda 	:= ""
Local aFormCtrlBkp 	:= {}
Local nValAux    	:= 0
Local nMvFrtDesc 	:= SuperGetMV("MV_FRTDESC")						// 1=Considera desconto; 2=Desconsidera o desconto; 3=Pergunta
Local lFrtFormPag   := ExistBlock( "FRTFORMPAG" )
Local aRetFormPag   := {.T.,"","",CtoD(""),0,0,0,0}
Local nVlrAux       := 0
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)			 // Identifica se o cliente utiliza múltiplas transações TEF
Local lDifCart      := .F. , oDifCart                           // Identifica se o cliente utiliza o mesmo carão para todas as parcelas de uma determinada ADM
Local nLinha		:= 35										// Controle de posicionamento dos objetos na tela
Local nColuna		:= If(lUsaTef .AND. lTefMult,20,0)			// Tamanho da Dialog
Local lUsaAdm       := .T.
Local cVinculado	:= "0"
Local cFormaId		:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	//Inicializa ID Cartao para multi-tef
Local oCart																		//Objeto que armazena o ID cartao
Local aAreaSAE		:= {}										//Guarda a Area do SAE

DEFAULT cGrupo 		:= ""

If lVisuSint .AND. Len(aPgtos) == 0	.AND. lTefMult				// Caso seja a primeira parcela a ser lancada
	cFormaID := "1"												// Automaticamente atribui "1" como ID do cartao.
EndIf

If lFrtFormPag                                             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicoes da array aRetFormPag                                               ³
	//³                                                                            ³
	//³1 - Logico - Define se deve ou não, exibir a janela com os valores desejados³
	//³2 - Caracter - Forma de pagamento                                           ³
	//³3 - Caracter - Descricao da forma de pagamento                              ³
	//³4 - Date - Data do vencimento da parcela                                    ³
	//³5 - Numerio - Numero de parcelas                                            ³
	//³6 - Numerico - Taxa de juros                                                ³
	//³7 - Numerico - Numero de intervalos                                         ³
	//³8 - Numerico - Valor da parcela                                             ³
	//³9 - Caracter - ID Cartão			                                           ³
	//³10- Numerico - Valor do Desconto a ser aplicado no total do Cupom Fiscal    ³
	//³11- Numerico - Valor total do Cupom Fiscal    							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetFormPag := ExecBlock( "FRTFORMPAG" , .F., .F., {aFormPag, cDesc, cForma, cGrupo, nVlrTotal, nVlrDescTot} )
	cForma     := aRetFormPag[2]
	cDesc      := aRetFormPag[3]
	dData      := aRetFormPag[4]
	nNumParc   := aRetFormPag[5]
	nTXJuros   := aRetFormPag[6]
	nIntervalo := aRetFormPag[7]
	nValor	   := aRetFormPag[8]
	cFormaId   := If(lVisuSint,If(Len(aRetFormPag)>8,aRetFormPag[9]," "),cFormaID)
	If Len(aRetFormPag) > 9
	    nVlrDescTot:= aRetFormPag[10]
	EndIf    
	If Len(aRetFormPag) > 10			
	   nVlrTotal  := aRetFormPag[11]
	   oVlrTotal:Refresh()
	EndIf   
	
	If nValor > nVlrTotal
		If !( SL1->(FieldPos("L1_TROCO1")) > 0 .AND. SuperGetMV("MV_LJTROCO", ,.F.) )
			nValor := nVlrTotal
		Endif
	EndIf
	
	If cForma == SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda))) .AND. dData > dDataBase
		dData := dDataBase
	EndIf
EndIf

If ! (cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0)
	// "Alteração das formas de pagamento"
	// "As formas de pagamento selecionadas no orçamento serão ignoradas, prevalecendo as novas formas a serem escolhidas."
	If Aviso(STR0211, STR0212, {"&Ok", STR0213}) == 1		// "&Cancelar"
		cItemCond  	:= "CN"
		lCondNegF5 	:= .F.
		aParcOrcOld := aParcOrc
		aParcOrc   	:= {}
		aPgtos     	:= {}

		oPgtos:SetArray(aPgtos)
		If lVisuSint
			aPgtosSint:=FrtMontPgt(aPgtos)
			oPgtosSint:SetArray( aPgtosSint )
			oPgtosSint:Refresh()
		EndIf

		nVlrAcreTot := 0			// Zera o Acrescimo Financeiro
		nVlrPercAcr := 0			// Zera o percentual de Acrescimo Financeiro
		nVlrDescCPg := 0			// Zera o Desconto Financeiro

		If nVlrTotal < nVlrBruto	// Checa se considera ou não o desconto
			If nMvFrtDesc == 3
				nMvFrtDesc := If(MsgYesNo(STR0245),1,2) //"Foi informado um desconto no orçamento original. Continua considerando esse desconto ?"
			Endif
			If nMvFrtDesc == 2	// Desconsidera o desconto informado anteriormente
				nVlrTotal := nVlrBruto
			Endif
		Else
			nVlrTotal := nVlrBruto
		Endif
		oVlrTotal :Refresh()		
	Else
		Return(.T.)
	EndIf
EndIf

If !Empty(cGrupo)

	// Verifica se o grupo escolhido pertence a forma de pagamento CC/CD, 
	// se pertencer tem que verificar o parâmetro MV_LJSLFIN, caso contrário pede a tela para
	// escolha das financiadoras

	If ( nI := AScan(aFormPag, { |x| Left(x[4], 1) == cGrupo })) > 0
		lUsaAdm := Iif( aFormPag[nI,02] $ _FORMATEF , lMV_LJSLFin, .T. )
	EndIf

	If lUsaAdm
	
		oCupom:Add(FRT_SEPARATOR)
		oCupom:Add("")
		oCupom:Add(STR0210)	//"Selecione a Adm. Financeira:"
		oCupom:Add("")
		AEval(aFormPag, {|x| If(Left(x[4],1)==cGrupo,oCupom:Add(Substr(x[4],2)+" - "+x[1]),)})
		FrtGet(@cFuncao, "99")
	
	EndIf

	nLen := Len(oCupom:aItems)
	For nI := nLen To nOldLen+1 Step -1
		oCupom:Del(nI)
	Next nI
	oCupom:GoTop()
	oCupom:GoBottom()
	cCupom := cOldcCupom
	            
	// O parâmetro de escolha de administradora esta como falso, pega qq função. Pois no
	// final da venda o sistema irá alterar para o cartão passado no TEF automaticamente.
	If ! lUsaAdm
		nI := AScan(aFormPag, { |x| Left(x[4], 1) == cGrupo })
	Else
	    nI := AScan(aFormPag, { |x| x[4] == ( cGrupo + cFuncao ) })
	EndIf

	If nI > 0
		cDesc  := Iif( ! lUsaAdm, " ", aFormPag[nI][1] )
		cForma := aFormPag[nI][2]
	Else
		Return(.T.)
	EndIf

EndIf

//"Quantidade de Vales"###"Parcelas"###"Cartoes"
cDescParcelas  	:= If(cForma="VA",STR0144,STR0207+IIf(cPaisLoc<>"BRA",If(cForma$_FORMATEF,STR0173,""),""))	
nValMax			:= nVlrTotal 

If cPaisLoc == "BRA"
   AEval(aFormCtrl, {|x| nValMax -= x[7]})
Else    
   AEval(aFormCtrl, {|x| nValMax -= Round(xMoeda(x[7],x[8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)})
   aFormCtrlBkp := aClone(aFormCtrl)
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for visualizaçao sintetizada utilizar o novo controle pelo ID do Cartão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. lUsaTef .AND. lTefMult .AND. cForma $ _FORMATEF
	nCtrl := AScan(aFormCtrl, {|x| x[1] == cForma .AND. x[9] == cFormaID} )
Else
	nCtrl := AScan(aFormCtrl, {|x| ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (x[1] == cForma)) .OR. ((x[1] == cForma) .AND. (x[2] == cDesc))})
EndIf	

If (nCtrl > 0 .AND. !LjAnalisaLeg(13)[1])
	If !lFrtFormPag
		dData 		:= aFormCtrl[nCtrl][3]
		nNumParc	:= aFormCtrl[nCtrl][4]
		nTXJuros	:= aFormCtrl[nCtrl][5]
		nIntervalo	:= aFormCtrl[nCtrl][6]
		nValor		:= aFormCtrl[nCtrl][7]
	EndIf
	nValMax		:= nValor + nValMax
	If cPaisLoc <> "BRA"
	    nValMax		:= Iif(aFormCtrl[nCtrl][8]<>nMoedaCor,Round(xMoeda(nValor,aFormCtrl[nCtrl][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais),nValor) + nValMax	
		nPosMoeda := aFormCtrl[nCtrl][8]
		cMoedaVen := aMoeda[nPosMoeda]
		cSimbMoeda:= SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda)))
		aCProva[nCtrl][1] := nValor
		aCProva[nCtrl][2] := nPosMoeda
		aCProva[nCtrl][3] := nValor
		aCProva[nCtrl][4] := cMoedaVen
		aCProva[nCtrl][5] := .F.
	EndIf
Else
	nCtrl 		:= 0
	If !lFrtFormPag
		If cForma $ "CC|VA|CO|CD|FI"

			aAreaSAE	:= GetArea("SAE")
			DbSelectArea("SAE")
			DbSetOrder(1)
			DbSeek(xFilial("SAE"),.T.)

			While !EOF() .AND. xFilial("SAE") == SAE->AE_FILIAL
				If AllTrim(SAE->AE_DESC) == cDesc
					dData	:= LJCalcVenc(.T., dDatabase)
					Exit
				EndIf
				dbSkip()
			End
			RestArea(aAreaSAE)
			If Empty(dData)
				dData := dDataBase
			EndIf
		Else
			dData	:= dDataBase
		EndIf
		nNumParc	:= 1
		nTXJuros	:= 0
		nIntervalo	:= SuperGetMV("MV_LJINTER")  //Define o intervalo(em dias) DEFAULT entre as parcelas
		nValor		:= nValMax
	EndIf
	If cPaisLoc <> "BRA"
		nPosMoeda := Int(nMoedaCor)
		cMoedaVen := aMoeda[nPosMoeda]
		cSimbMoeda:= SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda)))
		AAdd(aCProva,{nValor,nPosMoeda,nValor,cMoedaVen,.F.})
	EndIf
EndIf

If lFrtFormPag .AND. !Empty( aPgtos )
	nVlrAux := 0
	AEval( aPgtos,{|ExpA1| nVlrAux += ExpA1[2]} )
	If nVlrAux >= nVlrTotal
		// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
		HELP(' ',1,'FRT032')
		Return(.T.)
	EndIf		
EndIf

If nValor = 0
	// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
	HELP(' ',1,'FRT032')
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If Len(aMoeda) > 0
   nTamMoed1 := 20
   nTamMoed2 := 10   
EndIf             

If aRetFormPag[1]
	If cPaisLoc $ "POR|EUA" .AND. cForma == cSimbCheq
		DEFINE MSDIALOG oFormPag FROM 1,1 TO 160,260 TITLE STR0075 PIXEL OF GetWndDefault()		// "Forma de Pagamento"
	
		DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9 BOLD
	
		@ 10, 10 SAY cForma + " - " + cDesc SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL
	
		@ 25, 10 SAY STR0110	SIZE 50,10 OF oFormPag PIXEL	// "Data"
		@ 25, 70 MSGET oData	VAR dData		SIZE 50,10 OF oFormPag PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")
		oData:cSx1Hlp:="L4_DATA"
	    
	    @ 40, 10 SAY STR0114	SIZE 50,10 OF oFormPag PIXEL	// "Valor"
	    @ 40, 70 MSGET oValor	VAR nValor	   	PICTURE PesqPict("SL1","L1_VLRTOT",15) SIZE 50,10 OF oFormPag PIXEL VALID (nValor >=0)
	    oValor:cSx1Hlp:="L4_VALOR"
	    
		DEFINE SBUTTON FROM 60,63 TYPE 1 ENABLE ACTION (nOpc:=1, oFormPag:End()) OF oFormPag
		DEFINE SBUTTON FROM 60,93 TYPE 2 ENABLE ACTION oFormPag:End() OF oFormPag
	Else
	    DEFINE MSDIALOG oFormPag FROM 1,1 TO 240+nColuna+nTamMoed1,260 TITLE STR0075 PIXEL OF GetWndDefault()	// "Forma de Pagamento"	
	
		DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9 BOLD
		@ 07, 10 SAY cForma +  Iif( lUsaAdm, " - " + cDesc, " " ) SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL
	
		@ 20, 10 SAY STR0110	SIZE 50,10 OF oFormPag PIXEL	//"Data"
	
		If lRecebe .AND. cForma == cSimbCheq    				//Para ser ativado somente na Fidelizaçao e recebimento de Cheque
			@ 20, 70 MSGET oData VAR dData	SIZE 50,10 OF oFormPag PIXEL WHEN  !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA") ;
			Valid FRTVLDDTA(dData)
			oData:cSx1Hlp:="L4_DATA"
		Else
			@ 20, 70 MSGET oData VAR dData	SIZE 50,10 OF oFormPag PIXEL WHEN  !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA") ;
			Valid dData >= dDataBase .AND. !Empty(dData)
			oData:cSx1Hlp:="L4_DATA"
	    Endif

	   If Alltrim(cForma)$_FORMATEF .AND. lVisuSint .AND. lUsaTef .AND. lTefMult
	   	   @ nLinha, 10  Say STR0288 SIZE 55,15 OF oFormPag PIXEL	//"ID Cartão"
  		   @ nLinha, 70  MSGET oCart VAR cFormaId RIGHT SIZE 15,10 PICTURE PesqPict("SL4","L4_FORMAID") OF oFormPag PIXEL ;
			   		     VALID FrtValidID(cForma,@cFormaId)
			nLinha += 15
			oCart:cSx1Hlp:="L4_FORMAID"
	   EndIf

		If !IsMoney(cForma)
			@ nLinha, 10 SAY cDescParcelas	SIZE 55,15 OF oFormPag PIXEL
			@ nLinha, 70 MSGET oNumParc		VAR nNumParc	PICTURE "@E 999" SIZE 50,10 OF oFormPag PIXEL VALID nNumParc > 0
			nLinha += 15			  		   		    
		    oNumParc:cSx1Hlp:="L1_PARCELA"
		EndIf
	
		If nNumParc>1 .AND. !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA" .OR. Alltrim(cForma)$_FORMATEF)
			@ nLinha, 10 SAY STR0112	SIZE 50,10 OF oFormPag PIXEL	// "Taxa de Juros"
			@ nLinha, 70 MSGET oTXJuros	VAR nTXJuros PICTURE "@R 99.99%" SIZE 50,10 OF oFormPag PIXEL VALID ( If (nTxJuros >=0, .T. , (MsgStop(STR0246),.F.)))
			nLinha += 15
		    oTXJuros:cSx1Hlp:="L1_JUROS"
		
			@ nLinha, 10 SAY STR0113	SIZE 50,10 OF oFormPag PIXEL	// "Intervalo"
			@ nLinha, 70 MSGET oIntervalo	VAR nIntervalo	PICTURE "@E 999" SIZE 50,10 OF oFormPag PIXEL 
			nLinha += 15
			oIntervalo:cSx1Hlp:="L1_INTERV"
		EndIf			
	
		@ nLinha, 10 SAY STR0114	SIZE 50,10 OF oFormPag PIXEL	// "Valor"
		@ nLinha, 70 MSGET oValor		VAR nValor	   	PICTURE PesqPict("SL1","L1_VLRTOT",15) SIZE 50,10 OF oFormPag PIXEL ;
			VALID ( IIf (nValor >=0, (If(cPaisLoc == "BRA",If(IsMoney(cForma),.T.,IIf((SuperGetMV("MV_LJTROCO", ,.F.) .AND. ;
			SL1->(FieldPos("L1_TROCO1"))>0),.T.,If(ExistBlock("FRTVMax"),ExecBlock("FRTVMax",.F.,.F.,{ cForma ,cDesc ,nValor ,nValMax }),nValor <= nValMax))),.T.)), ;
			(MsgStop(STR0246),.F.)))  //"Näo e permitido valor negativo nesse campo."
			
		nLinha += 15
	    oValor:cSx1Hlp:="L4_VALOR"
	
		// Se For Brasil e a forma For "R$" permite colocar um valor a maior,
		// e este valor excedente sera considerado como troco, pulando a funcao GetTroco().
		// Qualquer outra forma, segue a regra "nValor <= nValMax" ou o PE FRTVMax
	
		If cPaisLoc <> "BRA"
			@nLinha,010 SAY STR0145	SIZE 50,10 OF oFormPag PIXEL	// "Moeda"
			@nLinha,070 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ON CHANGE (nPosMoeda:=oMoeda:nAt,cSimbMoeda:=SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda))));
			SIZE 50,10 PIXEL OF oFormPag
			nLinha += 15
		EndIf
		
		// Determina se irá ter que digitar os dígitos do cartão para múltiplas transações TEF
		If !lVisuSint .AND. lUsaTef .AND. lTefMult
			@ nLinha, 10 CHECKBOX oDifCart VAR lDifCart PROMPT STR0279 ; //"Parcelar com diferentes cartões da ADM"
						 SIZE 120,07 OF oDifCart PIXEL WHEN (nNumParc>1 .AND. cForma $ _FORMATEF )
			nLinha += 15			  		   		    
		EndIf			

		DEFINE SBUTTON FROM nLinha+5+nTamMoed2,63 TYPE 1 ENABLE ACTION ( Frt010PgPE(	cForma		, cDesc			, dData		, nNumParc	, ;
																					 	nTXJuros	, nIntervalo	, @nValor	, cMoedaVen 	),;
																					 	nOpc := 1	, oFormPag:End()) OF oFormPag
		DEFINE SBUTTON FROM nLinha+5+nTamMoed2,93 TYPE 2 ENABLE ACTION oFormPag:End() OF oFormPag

		//Foi criado depois dos botoes para que fique mais "funcional" para o usuario...
		If cPaisLoc <> "BRA" .AND. Len(aMoeda) > 1
			//Conversao de valores
			@ 03,70 BUTTON STR0220 SIZE 60,12 ACTION (LjxDRetVConv( @cMoedaVen	,@oMoeda	,@nValor,@oValor,;
																	aMoeda		,@aMultMoeda,"FRONT","1"	,;
																	@cSimbMoeda	,oDlgFRT )) OF oFormPag PIXEL //"Conversao de Valores"
		EndIf
		
	EndIf
	
	ACTIVATE MSDIALOG oFormPag CENTER
Else
	nOpc := 1
EndIf

If nOpc == 1
	If cPaisLoc <> "BRA" .AND. IsMoney(cForma) .AND. cForma <> cSimbMoeda .AND. !Empty(aFormCtrl)
		If !MsgYesno(STR0221) //"E uma conversao para outra moeda?"
			nValAux	:= nVlrTotal			
			AEval(aFormCtrl, {|x| nValAux -= Round(xMoeda(x[7],x[8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)})			

			If nValAux <= 0
				// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
				HELP(' ',1,'FRT032')

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura os SetKey's do Fechamento da Venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTSetKey(aKey)
				Return(.T.)
			EndIf
			
			cForma := cSimbMoeda
			nCtrl  := 0
		EndIf			
	ElseIf cPaisLoc <> "BRA" .AND. IsMoney(cForma) .AND. Empty(aFormCtrl)
		cForma := cSimbMoeda	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificando se o operador digitou o ID do cartão para processar a operação TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cPaisLoc == "BRA" .AND. Alltrim(cForma)$_FORMATEF .AND. lVisuSint .AND. lUsaTef .AND. lTefMult .AND. Empty(cFormaId)
		MsgAlert(STR0289,STR0003) //"Informe o ID do Cartão para a operação TEF.","Atenção"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.T.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a forma de pagamento for em Vale, e a quantidade       ³
	//³de vales for maior que 1, o Valor total, é o valor do vale³
	//³multiplicado pela quantidade de vales                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cForma == "VA"
		nValor 		:= nValor * nNumParc
		nNumParc 	:= 1
	EndIf

	If cPaisLoc == "BRA" .AND. IsMoney(cForma) .AND. nValor > nValMax
		nTroco := nValor - nValMax
		nValor := nValMax
	EndIf

	If cPaisLoc == "BRA" .AND. !IsMoney(cForma) .AND. ((nValor > nValMax .AND. ExistBlock("FRTVMax")) .OR. ;
	                                                    (SL1->(FieldPos("L1_TROCO1")) > 0 .AND. ;
	                                                     SuperGetMV("MV_LJTROCO", ,.F.)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o calculo do Troco, se o o valor total da venda³
		//³for maior que o valor maximo permitido                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValor > nValMax
			nTroco := nTroco2 := nValor - nValMax
		EndIf
		If SL1->(FieldPos("L1_TROCO1")) <= 0 .OR. !SuperGetMV("MV_LJTROCO", ,.F.)
			nValor := nValMax
		EndIf
	EndIf

	If cForma ="VA"
		If !( SL1->(FieldPos("L1_TROCO1")) > 0 .AND. SuperGetMV("MV_LJTROCO", ,.F.) )
			nValor   := Min(nValor * nNumParc, nValMax)
			nNumParc := 1
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O parametro MV_LJPAGTO retorna um valor inteiro. Pode ser      ³
		//³1 que irá indicar que a descrição da forma de pagto será a da  ³
		//³tabela 24 do SX5 ou 2, que será do cadastro de administradoras ³
		//³(SAE).                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (IsMoney(cForma) .OR. cForma == cSimbCheq) .OR. SuperGetMV("MV_LJPAGTO")==1
			nI := AScan(aFormPag, {|x| x[2]==cForma})
		Else
			nI := AScan(aFormPag, {|x| PadR(x[1],30)==PadR(cDesc,30)})
		EndIf
		If cPaisLoc == "BRA" .AND. IsMoney(cForma)
			cFormaPagto := aFormPag[nI][If(SuperGetMV("MV_LJPAGTO")==1,3,1)] + '|' + AllTrim(Str(nValor+nTroco,14,2))
		Else
			cFormaPagto := aFormPag[nI][If(SuperGetMV("MV_LJPAGTO")==1,3,1)] + '|' + AllTrim(Str(nValor,14,2))
		EndIf		

		// Indica que sera emitido um cupom vinculado ao cupom fiscal emitido.
		// Especifico para impressora Urano versao 3.00
		If lUsaTef .AND. (cForma $ _FORMATEF+";"+cSimbCheq) .AND. (nValor > 0) .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF
			cVinculado := "1"
		EndIf

		nRet := IFPagto(nHdlECF, cFormaPagto, cVinculado, nValor)
		If nRet <> 0
			// "Não foi possível registrar a forma de pagamento "###". Operação não efetuada.", "Atenção"
			MsgStop(STR0193+cDesc+STR0194, STR0003)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			Return(.T.)
		EndIf	
	EndIf

	// Inicializando o aPgtos ou deletando a forma de pagamento já cadastrada
	If Len(aPgtos)=0
		aPgtos := {}
	Else
		nDel := 0
		For nI := 1 To Len(aPgtos)
			If ValType(aPgtos[nI]) == "A"
				If lVisuSint	//Considerar também o Id do Cartão qdo Multi-TEF
					If ( ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
						 (aPgtos[nI][3] == cForma .AND. !cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )    .OR.  ;
					     (aPgtos[nI][3] == cForma .AND.  cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) ) .AND. AllTrim(aPgtos[nI][12]) == Alltrim(cFormaID) ) .AND. ;
					     !LjAnalisaLeg(13)[1]
						ADel(aPgtos, nI)
						nDel++
						nI--
					EndIf
				Else			//Mantém a verificação padrão
					If (((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
						(aPgtos[nI][3] == cForma) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )) .AND. !LjAnalisaLeg(13)[1]
						ADel(aPgtos, nI)
						nDel++
						nI--
					EndIf
				EndIf
			EndIf
		Next nI
		If nDel > 0
			ASize(aPgtos, Len(aPgtos)-nDel)
		EndIf
	EndIf

	If nValor = 0
		If nCtrl > 0
			ADel(aFormCtrl, nCtrl)
			ASize(aFormCtrl, Len(aFormCtrl)-1)
		EndIf
	Else
		If nCtrl > 0
			aFormCtrl[nCtrl][3] := dData
			aFormCtrl[nCtrl][4] := nNumParc
			aFormCtrl[nCtrl][5] := nTXJuros
			aFormCtrl[nCtrl][6] := nIntervalo
			aFormCtrl[nCtrl][7] := nValor
			aFormCtrl[nCtrl][9] := cFormaID
			If cPaisLoc <> "BRA"
				aFormCtrl[nCtrl][8] := nPosMoeda
				If IsMoney(cForma)
					aFormCtrl[nCtrl][1] := aSimbs[nPosMoeda]
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == aSimbs[nPosMoeda]})	
					If nPosDesc > 0
			           aFormCtrl[nCtrl][2] := aFormPag[nPosDesc][1]
			        EndIf   
				EndIf
				nValAux	:= nVlrTotal
				For nI := 1 To Len(aFormCtrl)
					If nI <> nCtrl
						nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					EndIf
				Next nI
				nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))

			    //Acerta os dados do array aCProva...
				aCProva[nCtrl][1] := nValor
				aCProva[nCtrl][2] := nPosMoeda
				aCProva[nCtrl][3] := nValAux
				aCProva[nCtrl][4] := aMoeda[nPosMoeda]
				aCProva[nCtrl][5] := (aCProva[nCtrl][1] < aCProva[nCtrl][3])
			EndIf
		Else
			If cPaisLoc == "BRA"
				AAdd(aFormCtrl, {cForma, cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, NIL , cFormaID} )
			Else                                                                    
				If IsMoney(cForma)                                                              
				    nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == aSimbs[nPosMoeda]})	
				ElseIf Trim(cForma) == "CH"
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == cForma })
				Else
					//Qdo a forma de pgto eh diferente de cheque ou dinheiro eh necessario
					//pesquisar tambem o nome da administradora...
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[1])==cDesc .AND. Trim(x[2])==cForma })					
				EndIf              
				If nPosDesc > 0
			       cDesc := aFormPag[nPosDesc][1]
			    EndIf   			
				If !(IsMoney(cForma))
					AAdd(aFormCtrl, {cForma, cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, nPosMoeda, cFormaID} )
    			Else
					AAdd(aFormCtrl, {AllTrim(aSimbs[nPosMoeda]), cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, nPosMoeda, cFormaID})
    			EndIf     
    			
				nValAux	:= nVlrTotal
				For nI := 1 To Len(aFormCtrl)-1
					nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
				Next nI             
				
				nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))
    			If Len(aCProva) == Len(aFormCtrl)
				    //Acerta os dados do array aCProva...
					aCProva[Len(aCProva)][1] := nValor
					aCProva[Len(aCProva)][2] := nPosMoeda
					aCProva[Len(aCProva)][3] := nValAux
					aCProva[Len(aCProva)][4] := aMoeda[nPosMoeda]
					aCProva[Len(aCProva)][5] := (aCProva[Len(aCProva)][1] < aCProva[Len(aCProva)][3])
				Else
					AAdd(aCProva,{nValor,nPosMoeda,nValAux,cMoedaVen,(nValor < nValAux)})		
				EndIf
			EndIf
		EndIf
		If cPaisLoc == "BRA"
			nValParc := NoRound(nValor/nNumParc, 2)
		Else
			If nNumParc > 1
				nValParc:= Round(nValor/nNumParc,MsDecimais(nPosMoeda))
			Else
				nValParc:= Round(nValor,MsDecimais(nPosMoeda))
			EndIf
		EndIf		
		nDif	:= Round(nValor - (nValParc * nNumParc),nDecimais)
		cAdm	:= ""
		If !(IsMoney(cForma) .OR. cForma == cSimbCheq)
			SAE->(dbGoTop())
			While ! SAE->(EOF()) .AND. xFilial("SAE") == SAE->AE_FILIAL
				If AllTrim(SAE->AE_DESC) == cDesc
					cAdm := SAE->AE_COD + " - " + SAE->AE_DESC
					Exit
				EndIf
				SAE->(dbSkip())
			End
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄD¿
		//³Incluida a 13 posicao como logica, para armazenar       ³
		//³o acrescimo financeiro separado, caso seja parametrizado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDÙ
		For nI := 1 To nNumParc
			If cPaisLoc == "BRA"
				AAdd(aPgtos, {dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, cForma, cAdm, "", "", "", "", "", .F., nPosMoeda , If(lVisuSint,cFormaID,Space(04)), 0})
			Else
				If !(IsMoney(cForma))
					AAdd(aPgtos, {dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, cForma, cAdm, "", "", "", "", "", .F., nPosMoeda , If(lVisuSint,cFormaID,Space(04)), 0 })
				Else
					AAdd(aPgtos, {dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, AllTrim(aSimbs[nPosMoeda]), cAdm, "", "", "", "", "", .F., nPosMoeda, If(lVisuSint,cFormaID,Space(04)), 0 })
				EndIf				
			EndIf				
		Next nI
		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. Len(aPgtos) == 1)
			aPgtos[Len(aPgtos)][2] += nDif
		Else
			aPgtos[Len(aPgtos)][2] := Round(aPgtos[Len(aPgtos)][2]+nDif,nDecimais)
		EndIf		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A Forma $ sempre sera a primeira!!!  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nCtrl:=AScan(aPgtos, {|x| x[3] == cSimbCor})) > 1
		AAdd(aPgtos, {})
		AIns(aPgtos, 1)
		nCtrl++
		aPgtos[1] := aPgtos[nCtrl]
		ADel(aPgtos, nCtrl)
		ASize(aPgtos, Len(aPgtos)-1)
	EndIf   
	
	If nTroco > 0
		oCupom:Add(STR0103+Transform(nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "          TROCO          "
	EndIf
	
	If lUsaDisplay                   
		If !FRT010VlPar(nVlrTotal)
	   		DisplayEnv(StatDisplay(), "2E" + Upper(STR0268) + Upper(cDesc) + ": " + Str(nValor,8,2) )         //"Valor Em ###:"	
		EndIf	   		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se utiliza múltiplas transações Tef e selecionou a opção de parcelar |
	//| em <>s cartoes solicitar os 4 ultimos de cada cartao                 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVisuSint .AND. lUsaTef .AND. lTefMult .AND. lDifCart
	   FRTTefDig(aPgtos)
	EndIf
	
	oPgtos:SetArray(aPgtos)
	oPgtos:Refresh()
	
	If lVisuSint
		aPgtosSint:=FrtMontPgt(aPgtos)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		If cForma == cSimbCheq
			aCheques := {}
			aParcelas := AClone(aPgtos)
			For nI := 1 to Len(aParcelas)
				If AllTrim(aParcelas[nI][3]) == cSimbCheq
					AAdd(aCheques,{aParcelas[nI][1], aParcelas[nI][2], aParcelas[nI][3],;
								   aParcelas[nI][4], aParcelas[nI][5], aParcelas[nI][6],;
								   aParcelas[nI][7], aParcelas[nI][8], aParcelas[nI][9]})
				EndIf
			Next nI

			If SuperGetMV("MV_INFCHEQ")
				aDadosCh := LjxDGetCh(GetWndDefault(), cDoc, aCheques, cCliente, ; 
										cLojaCli	, @aParcelas	, @lUsaDisplay)
			EndIf
		EndIf
	EndIf
Else        
	//Caso o usuario nao confirme a parcela apaga os valores da tabela de
	//contra-prova...
	If cPaisLoc <> "BRA" .AND. Empty(aFormCtrl)
		ADel(aCProva, Len(aCProva))
		ASize(aCProva, Len(aCProva)-1)		
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
// Caso o array aPgtos esteja valorizado permite que o objeto oPgtos seja 
// editado pelo usuario, caso contrario desabilita o objeto...
If !Empty(aPgtos)
	oPgtos:Enable()
	If lVisuSint
		oPgtosSint:Enable()
		oPgtosSint:SetFocus()
	EndIf
Else
	If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		oPgtos:Disable()
		If lVisuSint
			oPgtosSint:Disable()
			oPgtosSint:SetFocus()
		EndIf
	EndIf
EndIf

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTDescTot³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Desconto no Total da Venda (F6)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTDescTot( nTmpJuros, nTmpDesc, lExTela )
Local oDlgDescTot						// Objeto da janela do desconto
Local oValorDesc						// Objeto do get do valor do desconto
Local oPercDesc							// Objeto do get do percentual do desconto
Local oBtn1								// Objeto do botao OK
Local oBtn2								// Objeto do botao Cancelar
Local nValorDesc	:= 0				// Variavel que contem o valor do desconto
Local nPercDesc		:= 0				// Variavel que contem o percentual do desconto
Local aKey			:= {}				// SetKey's do Fechamento da Venda
Local nOpc			:= 0				// Variavel que determina qual botao foi escolhido da dialog do desconto
Local nI			:= 0				// Utilizada em loop
Local nTotImp 		:= 0				// Total de impostos
Local lImpsDisc 	:= .F. 				// Determina se existe algum impostos discriminado na venda - Localizacoes
Local nVlrAux 		:= 0				// Localizacoes
Local nVlrMercAux	:= 0				// Localizacoes
Local aRet        	:= {}				// Utilizada para o recalculo das parcelas
Local cFormaId		:= " "				// Id utilizado como identificador das parcelas
Local nPerc			:= 0 				// Valor do Desconto sem a funcao Round()
Local cTipoDesc     := SuperGetMV("MV_LJTIPOD",.F.,"1")    // Tipo do Desconto
Local nDifOrc       := 0                // Valor de desconto ja aplicado no orcamento
Local nPercBkp 		:= 0				// Percentual backup do desconto
Local nParcDesc     := 0                // Desconto nas parcelas
Local nLastPDesc    := 0                // Desconto na ultima parcela
Local nVlrPercBkp	:= 0 				// Valor Backup do desconto

DEFAULT lExTela		:= .T.

Private aRetNeg 	:= {} 				// Localizacoes
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for chamada da rotina de recebimento, retorna sem fazer nada      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao das variaveis                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFormaId	:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum imposto discriminado na venda               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"  
	aEval(aItens,{|x| nVlrAux += Round(x[5]*x[6],nDecimais)})
	nVlrMercAux := If( cItemCond=="CN" .AND. !lCondNegF5,nVlrAux,nVlrMerc ) + aDadosJur[1] - aDadosJur[9]

	For nI := 1 To Len( aImpsSL1 )
		If aImpsSL1[nI][6] <> "3"
			lImpsDisc := .T.			
			Exit
		EndIf
	Next nI

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Setkey's do fechamento da venda                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta mensagem so aparece na forma padrao de selecao de parcelas(CTRL+?)³
//³Caso seja selecionada Condicao de Pagamento ou Condicao Negociada,     ³
//³Aparece o "Chorinho", que eh rateado.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cItemCond=="CN" .AND. !lCondNegF5 .AND. Len( aPgtos ) > 0 ) .OR. ( lImpsDisc .AND. Len( aPgtos ) > 0 )
	If MsgYesNo(STR0115, STR0003) // "Já foram definidas Formas de Pagamento para esta venda. Se optar pelo Desconto no Total do Cupom, será necessário definí-las novamente. Continua?"
		aPgtos   := {}
		aFormCtrl := {}
		oPgtos:SetArray( aPgtos )
		oPgtos:Refresh()

		If lVisuSint
			aPgtosSint:=FrtMontPgt( aPgtos )
			oPgtosSint:SetArray( aPgtosSint )
			oPgtosSint:Refresh()
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey( aKey )
		Return( NIL )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE para controlar o Desconto no Total. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTDescTOT")
	If ! ExecBlock("FRTDescTOT",.F.,.F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey( aKey )
		Return( NIL )
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de importação de Orcamento        ³
//³faz o carregamento do desconto ja efetuado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpOrc .AND. (nVlrDescTot > 0 .AND. nVlrPercTot > 0)
	nValorDesc:= nVlrDescTot
	nPercDesc := nVlrPercTot
EndIf

nPercBkp := nVlrPercTot
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o desconto no total do item pode ser concedido, de acordo com os estados que entram na Lei|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ( LjAnalisaLeg( 14 )[1] .AND. !lDescTotal .AND. !lDescSE4 ) .OR.;
   	   ! ( LjAnalisaLeg( 14 )[1] ) )

	If lExTela
		DEFINE MSDIALOG oDlgDescTot FROM  47,130 TO 160,370 TITLE STR0089 PIXEL	// "Desconto no total do cupom"
		
		@ 06, 04 BITMAP RESOURCE "DISCOUNT" OF oDlgDescTot PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
		@ 04, 40 TO 28, 120 LABEL STR0090 OF oDlgDescTot PIXEL	// "Valor / Percentual"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o get do valor do desconto e define o valid para chamar a mesma³
		//³ funcao da venda assitida para verificar a permissao de desconto do   ³
		//³ usuario                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 13, 45 MSGET oValorDesc VAR nValorDesc SIZE 40, 10 OF oDlgDescTot Picture PesqPict("SL1","L1_VLRTOT",10,nMoedaCor) RIGHT PIXEL ;
                         VALID (If(nValorDesc<0,HELP(' ',1,'FRT023'),),.T.) .AND.; 
                               (nValorDesc >= 0 .AND. nValorDesc < nVlrBruto) 
                               
		oValorDesc:cSx1Hlp:="L1_DESCONT"

		If cPaisLoc == "BRA"
			oValorDesc:bLostFocus := {|| nVlrPercBkp:= nPercDesc := Round( 100 - ( ( ( (nVlrBruto - nTotDedIcms) - nValorDesc) / (nVlrBruto - nTotDedIcms) ) * 100 ),2 ), oPercDesc:Refresh(),;
										 nPerc 		:= 100 -   (( (nVlrBruto - nTotDedIcms) - nValorDesc) / (nVlrBruto - nTotDedIcms)) * 100, IIf(nPercDesc > 0,oBtn1:SetFocus(),oPercDesc:SetFocus()) }
		Else
			oValorDesc:bLostFocus := {|| nPercDesc := Round( 100 - ( ( ( nVlrMercAux - nValorDesc ) / nVlrMercAux ) * 100 ),2 ), oPercDesc:Refresh(), IIf(nPercDesc > 0,oBtn1:SetFocus(),oPercDesc:SetFocus()) }
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o get do % do desconto e define o valid para chamar a mesma    ³
		//³ funcao da venda assitida para verificar a permissao de desconto do   ³
		//³ usuario                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 13, 90 MSGET oPercDesc  VAR nPercDesc  SIZE 16, 10 OF oDlgDescTot PICTURE "@E 99.99" PIXEL ;
                         VALID ( If( nPercDesc < 0, HELP(' ',1,'FRT023'),),.T.) .AND.;
                               ( nPercDesc  >= 0 )
                               
		oPercDesc:cSx1Hlp:="NDESPERTOT"    	

		If cPaisLoc == "BRA"
			oPercDesc:bLostFocus := {|| IIf( nVlrPercBkp <> nPercDesc , nPerc := nPercDesc,.T.),;
									nValorDesc := FrtAtuValor( nPerc, nPercDesc, nVlrTotal, nValorDesc), oValorDesc:Refresh() }
		Else
			oPercDesc:bLostFocus := {|| nValorDesc := Round( nVlrMercAux * ( nPercDesc / 100 ), nDecimais ), oValorDesc:Refresh() }
		EndIf

		DEFINE SBUTTON oBtn1 FROM 38, 50 TYPE 1 ENABLE OF oDlgDescTot PIXEL ;
			ACTION ( nOpc := 1,oDlgDescTot:End() )
	
		DEFINE SBUTTON oBtn2 FROM 38, 85 TYPE 2 ENABLE OF oDlgDescTot PIXEL ;
			ACTION ( nOpc := 0,oDlgDescTot:End() )

		ACTIVATE MSDIALOG oDlgDescTot ;
		VALID FrtValDesc(Val(cTipoDesc), nPercDesc, nValorDesc);
		CENTERED
	EndIf                                     
	
	If nOpc == 1 .OR. !lExTela
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao especifica para atender a legislacao do SEFAZ              ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Para o estado de MG nao eh necessario este passo, mas por impedimento³
		//³ tecnico este passo deverah ser realizado (Nao eh possivel registrar  ³
		//³ desconto depois da forma de pagamento)                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjAnalisaLeg(14)[1]
			If nValorDesc > 0                                             
				nRet := IFDescTot(nHdlECF, AllTrim(Str(nValorDesc,14,2)))
				If nRet <> 0				
					HELP(' ',1,'FRT033')	// "Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada.", "Atenção"
					nOpc := 0
				Else
					oCupom:Add(FRT_SEPARATOR)
					oCupom:Add(PadL(STR0089,40))	// "Desconto no total do cupom"
					oCupom:Add(PadL(STR0090,40))	// "Valor / Percentual"
					oCupom:Add(PadL(Trans(nValorDesc,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nPercDesc,"@E 99.99")+"%",40))
					oCupom:Add(FRT_SEPARATOR)
					lDescTotal := .T.				// Seta que o desconto no total da venda foi concedido
				EndIf
			EndIf
		Else
			If nValorDesc == 0  
				oCupom:Add(FRT_SEPARATOR)
				oCupom:Add(STR0091)	// "Desconto no total do cupom : CANCELADO"
				oCupom:Add(FRT_SEPARATOR)
			Else
				oCupom:Add(FRT_SEPARATOR)
				oCupom:Add(PadL(STR0089,40))	// "Desconto no total do cupom"
				oCupom:Add(PadL(STR0090,40))	// "Valor / Percentual"
				oCupom:Add(PadL(Trans(nValorDesc,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nPercDesc,"@E 99.99")+"%",40))
				oCupom:Add(FRT_SEPARATOR)
			EndIf
		EndIf

		If nOpc == 1 .OR. !lExTela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso seja Desconto Especial ("Chorinho"), este sera rateado nas parcelas  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cItemCond=="CN" .AND. !lCondNegF5) .OR. lImpsDisc
				lDescEspec := .F.
				nVlrDescTot	:= nValorDesc
				nVlrPercTot	:= nPercDesc
				If cPaisLoc == "BRA"
					nVlrTotal := (nVlrBruto - nTotDedIcms) - nVlrDescTot
				Else
					//"Fazendo o calculo do desconto e o recalculo dos impostos..."
					LJMsgRun(STR0182,,{|| FRTCDescLoc(nValorDesc,nPercDesc,nTmpJuros,nTmpDesc)})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Realiza o recalculo das parcelas...                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCondNegF5
						FRTCondNeg()
						If Len(aRetNeg)>0
							nTXJuros   := aRetNeg[6][1]
							aRet := AClone(LJ7CalcPgt(nVlrTotal, cItemCond, {aRetNeg[1][1], aRetNeg[4][1], aRetNeg[5][1], aRetNeg[6][1], aRetNeg[7][1], aRetNeg[8][1], .F.},, @nTmpJuros, @nTmpDesc, nMoedaCor))
					  	EndIf
					ElseIf !(cItemCond $ "CN")
						aRet := AClone(LJ7CalcPgt(nVlrTotal, cItemCond,,, @nTmpJuros, @nTmpDesc, nMoedaCor))	
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso tenha acrescimo ou desconto financeiro eh necessario         ³
					//³ recalcular o valor total da venda...                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If Len(aRet) > 0 						
						If (nTmpJuros > 0) .OR. (nTmpDesc > 0)
							nVlrTotal := ((nVlrTotal-aDadosJur[6]) + (aDadosJur[4]+aDadosJur[1]-aDadosJur[9]))
						EndIf
						For nI := 1 to Len(aRet)
							cFormaID := If(AllTrim(aRet[nI][3])$_FORMATEF,"1",cFormaId)
							AAdd( aPgtos, { aRet[nI][1], NoRound(aRet[nI][2],nDecimais), AllTrim(aRet[nI][3]), "", "", "", "", "", "", .F., nMoedaCor, If(lVisuSint,cFormaID,Space(04)),0 })
						Next nI
					EndIf
					oPgtos:SetArray(aPgtos)
					oPgtos:Refresh()
					
					If lVisuSint
						aPgtosSint:=FrtMontPgt(aPgtos)
						oPgtosSint:SetArray( aPgtosSint )
						oPgtosSint:Refresh()
					EndIf
									
				EndIf
			Else
				lDescEspec  := .T.
				nVlrDescTot	:= nValorDesc
				nVlrPercTot	:= nPercDesc
				If cPaisLoc == "BRA"
					nVlrTotal	:= (nVlrBruto - nTotDedIcms) - nVlrDescTot
				Else
					//"Fazendo o calculo do desconto e o recalculo dos impostos..."
					LJMsgRun(STR0182,,{|| FRTCDescLoc(nValorDesc,nPercDesc,nTmpJuros,nTmpDesc)})
				EndIf
				nParcDesc   := NoRound(nValorDesc / Len(aPgtos), nDecimais)				// Desconto nas parcelas
				nLastPDesc  := nParcDesc + (nValorDesc - (nParcDesc * Len(aPgtos)))		// Desconto e Rateio na Ultima
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcular a diferenca do desconto ja que e' permitido dar mais de  ³
				//³ um desconto quando for um orcamento e nao for condicao negociada. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lImpOrc
					nDifOrc		:= NoRound( nVlrBruto * nPercBkp / 100, nDecimais )
					nParcDesc   := 0
					nLastPDesc  := 0
					If nVlrPercTot <> nPercBkp
						nParcDesc   := NoRound(nValorDesc / Len(aPgtos), nDecimais)				// Desconto nas parcelas
						nLastPDesc  := nParcDesc + (nValorDesc - (nParcDesc * Len(aPgtos)))		// Desconto e Rateio na Ultima
						nParcDesc   := nParcDesc - nDifOrc
					EndIf
				Else
					nParcDesc   := NoRound(nValorDesc / Len(aPgtos), nDecimais)				// Desconto nas parcelas
					nLastPDesc  := nParcDesc + (nValorDesc - (nParcDesc * Len(aPgtos)))		// Desconto e Rateio na Ultima
				EndIf
				For nI := 1 To Max(Len(aPgtos)-1, 1)
					aPgtos[nI][2] -= nParcDesc					
				Next nI
				If Len( aPgtos ) > 1
					aPgtos[Len(aPgtos)][2] -= nLastPDesc
				EndIf 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza a visualizacao na tela³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lVisuSint
					aPgtosSint:=FrtMontPgt(aPgtos)
					oPgtosSint:SetArray( aPgtosSint )
					oPgtosSint:Refresh()
				EndIf
			EndIf
			If cPaisLoc <> "BRA"  //Reimprime os impostos devido ao desconto
				AEval(aImpsSL1,{|x,y| nTotImp += aImpsSL1[y][3]})
				oCupom:Add( STR0071 + Trans( nVlrTotal - nTotImp, PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor ) ) )  //"     S U B T O T A L      "	

				SFB->( DbSetOrder(1) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reimpressao dos impostos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 To Len( aImpsSL1 )
					SFB->( DbSeek( xFilial( "SFB" ) + aImpsSL1[nI][1] ) )
					oCupom:Add( Space(05) + SubStr( SFB->FB_DESCR,1,10 ) + Space(11) + Trans( aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor ) ) )
				Next nI
			EndIf			

			If lUsaDisplay                   
				FRT010VlPar( nVlrTotal )
				DisplayEnv(StatDisplay(), "2C" + Upper( STR0259 ) )         //"Escolha a(s) forma(s) de pagamento"	
			EndIf
		        
			oVlrTotal:Refresh()
		EndIf
	EndIf
Else
	MsgAlert(STR0297,STR0003) //""Já existe desconto na condição de pagamento, não será permitida inclusão de novo desconto no total da venda".","Atenção"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCancCup³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelar o Cupom Fiscal (F8)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTCancCup( lCancTef, lVAssist )

Local nRet    		:= 0
Local cRet			:= ""
Local nX			:= 0
Local cNumCup		:= Space(TamSX3("L1_DOC")[1])
Local cPDV  		:= Space(TamSX3("L1_PDV")[1])
Local aSL1
Local cLiMsg
Local cSupervisor	:= Space(15)
Local lEstVend  	:= AliasInDic("MBZ") .And. (SL1->(FieldPos("L1_STATUES")) > 0)    ////  estorno de venda 
Local aAliasMBZ 	:= nil //WorkArea da Tabela MBZ
Local oEstorno 		:= nil //Objeto do estorno de venda

//Localizacoes
Local oDlgCancCup
Local oNumCup
Local lCancCup 		:= .F.
Local lInfCup  		:= .T.
Local nOrdSL1  		:= SL1->(IndexOrd())
Local aRet     		:= {}
Local lRet     		:= .T.   						// .T. - Erro no cancelamento do cupom, .F. - Cancelamento com sucesso
Local lReturn  		:= .F.
Local aDadosCrd		:= {}							// Dados do cliente para o web service
                                   
Local lFRTCancelat  := ExistTemplate("FRTCancela")	// verifica se existe o PONTO DE ENTRADA FRTCancela 
Local xRet                                          // Retorno do PE FRTCANCCF 
Local lFrtCancCF    := ExistBlock("FRTCANCCF")     // Verifica se existe o ponto de entrada FRTCancCF 
Local lCaixaAb      := .F.                         //Se o Caixa está aberto

DEFAULT lCancTef	:= .F.              
DEFAULT lVAssist	:= .F.              

If Type("lCXAberto") == "L"
	lCaixaAb      := lCXAberto
EndIf

If CheckCaixa(lCaixaAb, @lUsaDisplay, lVAssist )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Cancelamento Cupom" - #8 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCancTef .OR. LJProfile(8,@cSupervisor)
		nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Aberto
		If	nRet == 7 .OR. lCancTef
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o cupom está aberto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// "Venda em andamento. Realiza o CANCELAMENTO deste Cupom Fiscal?", "Atenção"
			If lCancTef .OR. MsgYesNo(STR0092, STR0003)
				nRet := IFStatus(nHdlECF, "9", @cRet)			// Verifico o Status do ECF
				If nRet <> 0
					If !lCancTef
						HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura os SetKey's do Fechamento da Venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FRTSetKey(aKey)
					Else 
						HELP(' ',1,'FRT034')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"						
																	// "É necessário efetuar Nota de Devolução."						
					EndIf
					Return(lRet)
				EndIf

				aSL1 := {{"L1_SITUA",	"07"}}				// "07" - Solicitado o Cancelamento do Cupom
				FRTGeraSL("SL1", aSL1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Qdo o pais for igual a Mexico eh necessario informar ³
				//³ o numero do documento que esta sendo cancelado.      ³
				//³                                                      ³
				//³ BOPS: 141 597                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "MEX"
					cSupervisor := cSupervisor + "/ " + cDoc
				EndIf

				nRet := IFCancCup(nHdlECF, cSupervisor)
				If lCancTef .AND. nRet == 1			
	   				lReturn := .T.
				EndIf
		
				If nRet == 0
					lFechaCup := .T.
				EndIf     
				
				If lFechaCup
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso exista Integracao com o SIGACRD e houve analise de credito, cancela o contrato dependendo do   ³
					//³ status, desde que seja diferente de 4 - fila de crediario										    ³					
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					If CrdXInt() .AND. !Empty(cContrato)  

						If Empty(cUsrSessionID)
							LJMsgRun("Aguarde... Efetuando login no servidor ...",, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) 
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa um webservice para saber qual o status da analise de credito ³
						//³do cliente. Se for diferente de 4 (fila de crediario) pode cancelar  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oObj:=WSCRDSTATUS():New()
						oObj:_URL			:= "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
						oObj:cCodCli		:= cCliente
						oObj:cLoja			:= cLojaCli
						oObj:cUsrSessionID	:= cUsrSessionID
						
						If oObj:GetStatus()
							If oObj:OWSGETSTATUSRESULT:CSITUACAO <> "4"	// Fila de crediario
		                        aDadosCrd := {}
								aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
								aAdd( aDadosCrd, aCrdCliente[1] )		// CPF
								
								// Faz o desfazimento da transacao de credito
								aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,If(Empty(SL1->L1_CONTRA),cContrato,SL1->L1_CONTRA)  ,;
								                      .T.   ,NIL         ,NIL )		
							Endif	
						Else
							Conout(GetWSCError())
						Endif																						
							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa as variaveis staticas de controle da analise de credito³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FrtSetCrd()

					EndIf
				EndIf
		
				If nRet == 0 .OR. lCancTef
					FRTCancela()
                    
					IFPegPDV(nHdlECF, @cPDV)
					lOcioso := .T.
					oCupom:Add("")
					oCupom:Add("")
					oCupom:Add(STR0093)	// "         CUPOM FISCAL CANCELADO         "
					oCupom:Add("")
					oCupom:Add("")
					oCupom:Add(DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+cDoc)	// "  PDV:" "   COD:"
					oCupom:Add("")
					oCupom:Add("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
					oCupom:GoBottom()
					cCupom := oCupom:aItems[Len(oCupom:aItems)-2]

					aItens	:= {}
					aPgtos	:= {}
					aTEFPend:= {}
					aBckTEFMult := {}
					lOcioso	:= .T.
					lVerTEFPend  := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Zera o valor e o percentual de desconto do item       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrPercIT := 0
					nVlrDescIT := 0 
					nLastTotal:= nVlrTotal
					nLastItem := nTotItens
					nTotItens := 0
					nVlrTotal := 0
					nVlrBruto := 0
					nVlrMerc  := 0
					nTotDedIcms  := 0
					lImpOrc   := .F.  					
					oDesconto:Refresh()
					oTotItens:Refresh()
					oVlrTotal:Refresh()
					nVidaLink := 99
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicializa as variáveis de Templates                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					uCliTPL := Nil     
					uProdTPL:= Nil
		            cCodConv:= "" 		
		            cLojConv:= ""
					cNumCartConv := ""
					FRTInitIT(.T.)
					FRTHora(.T.)
					If oFotoProd:cBMPFile <> "LOJAWIN"
						ShowBitMap(oFotoProd,"LOJAWIN")
					EndIf

					//Restaura as variaveis referentes a moeda para a moeda 1
					If cPaisLoc <> "BRA"
						If nMoedaCor <> 1
							cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
							oTemp3:Refresh()
							oTemp4:Refresh()
							oTemp5:Refresh()

							nTaxaMoeda := 1
							oTaxaMoeda:Refresh()
				
							nMoedaCor := 1
							cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
							oMoedaCor:Refresh() 
						EndIf               

						//Restaura a exibicao da mensagem padrao...
						AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
						oMensagem:cCaption := STR0001  //"   Protheus Front Loja"
						oMensagem:cTitle   := STR0001  //"   Protheus Front Loja"
						oMensagem:oFont    := oFntGet
						oMensagem:Refresh()

						aImpsSL1    := {}
						aImpsSL2    := {}
						aImpVarDup  := {}
						aImpsProd   := {}
						aCols       := {}
						aHeader     := {}
						aCProva     := {}
						aDadosJur   := {  0, 0, 0, 0, ;
						 				  0, 0, 0, 0, ;
										  0 }
						nVlrFSD     := 0
						nTotalAcrs  := 0
						nVlrDescTot	:= 0											
						nVlrPercTot	:= 0											
						nVlrPercAcr	:= 0											
						nNumParcs   := 0                                            
						nVlrPercOri := 0              
						nQtdeItOri  := 0                              
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ P.E. Apos o Cancelamento        ³
					//³ Tipo      : 1 - Item            ³
					//³             2 - Cupom           ³
					//³ Supervisor: Senha que autorizou ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFRTCancelat
						uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{2,cSupervisor,,uProdTPL})
					EndIf
					If ExistBlock("FRTCancela")
						ExecBlock("FRTCancela",.F.,.F.,{2,cSupervisor})
					EndIf
					If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))               
						T_DroDelANVISA( .T., NIL )
					Endif
					Return If(lCancTef, lReturn, .T.)
				Else
					HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os SetKey's do Fechamento da Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTSetKey(aKey)
					Return(lRet)
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o cupom está fechado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := IFPegCupom( nHdlECF,@cNumCup )
			If nRet <> 0
				HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura os SetKey's do Fechamento da Venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTSetKey(aKey)
				Return(lRet)
			Else
				If lFrtCancCF
					xRet := ExecBlock("FRTCANCCF",.F.,.F.,{cNumCup}) 
					If ValType(xRet) == "C"
					   cNumCup  := xRet
					Endif
				Endif			       	
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para o Mexico eh necessario um tratamento especial no cancelamento do cupom, ³
			//³pois pode ser que o cupom cancelado nao seja o ultimo emitido pelo ECF       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "MEX"
				IFPegPDV(nHdlECF, @cPDV)
				cPDV := PadR(AllTrim(cPDV),TamSx3("L1_PDV")[1]," ")
                
				SL1->(DbSetOrder(8))

				If Val(cNumCup) > 0 .AND. SL1->(DbSeek(xFilial("SL1")+cPDV+cNumCup))
					lInfCup := !MsgYesNo(STR0185+cNumCup+")") //"O cupom a ser cancelado e o ultimo cupom emitido (Numero: "
				EndIf
				
				If lInfCup	
					cNumCup := Replicate("0",TAMSX3("L1_DOC")[1])
					
					DEFINE MSDIALOG oDlgCancCup FROM  47,130 TO 160,300 TITLE STR0186 PIXEL	//"Cancelamento de Cupom"
					@ 04, 02 TO 28, 80 LABEL STR0187 OF oDlgCancCup  PIXEL	//"Numero do Cupom"
			
					@ 13, 06 MSGET oNumCup VAR cNumCup SIZE 70, 10 OF oDlgCancCup PICTURE PesqPictQt("L1_DOC") RIGHT PIXEL ;
					VALID (!Empty(cNumCup) .AND. (Val(cNumCup) > 0))	
					oNumCup:cSx1Hlp:="L1_DOC"    	
				
					DEFINE SBUTTON FROM 38, 15 TYPE 1 ENABLE OF oDlgCancCup ;
					ACTION (lCancCup := .T.,oDlgCancCup:End()) PIXEL
				
					DEFINE SBUTTON FROM 38, 50 TYPE 2 ENABLE OF oDlgCancCup ;
					ACTION (lCancCup := .F.,oDlgCancCup:End()) PIXEL
			
					ACTIVATE MSDIALOG oDlgCancCup CENTERED
					
					If lCancCup
						cNumCup := Padl(AllTrim(cNumCup),TamSx3("L1_DOC")[1],"0")
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura os SetKey's do Fechamento da Venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FRTSetKey(aKey)
                    	Return(lRet)
					EndIf
				EndIf
			EndIf		

			DbSelectArea("SL1")
			DbSetOrder(1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o SL1 na ultima venda          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "MEX"
	            SL1->(dbGoTop())
				If SL1->L1_DOC <> cNumCup
					dbGoBottom()
				Endif
			Else
				SL1->(DbSetOrder(8))
				SL1->(DbSeek(xFilial("SL1")+cPDV+cNumCup))
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o cupom da ultima venda não for o mesmo do ECF nao faz o cancelamento     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cNumCup <> SL1->L1_DOC .AND. cPaisLoc <> "MEX"
				// "O último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom.", "Atenção"
				HELP(' ',1,'FRT035')
				lRet := .F.
			Else
				// "Realiza o CANCELAMENTO do Cupom Fiscal nº " ### " ?", "Atenção"
				lRet := MsgYesNo(STR0096+cNumCup+STR0097, STR0003)
	        Endif
				/*BEGINDOC
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a venda não foi estornada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ENDDOC*/
				
				If lEstVend     
					aAreaMBZ := MBZ->(GetArea())
					MBZ->(DbSetOrder(1))
					If MBZ->( DbSeek(xFilial("MBZ") + PadR(SL1->L1_DOC,TamSX3("MBZ_CUPOM")[1]) + PadR(SL1->L1_SERIE,TamSX3("MBZ_SERIE")[1])))
						MsgAlert( STR0334)//"Ja foi realizado o estorno desse cupom."
						lRet := .F.
					    RestArea(aAreaMBZ)

						Return(lRet)  
					Else
						
						/*BEGINDOC
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Instancia o objeto estorno, a fim de verificar se a venda foi estornada por outro PDV³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ENDDOC*/
						oEstorno := LjClEstVen():New(nil,xNumCaixa(), nil, dDataBase,0, .F.)  
						oEstorno:lJob := .T.
						oEstorno:BuscaOrcamento(SL1->L1_DOC, SL1->L1_SERIE)
						If !Empty(oEstorno:cOrc_StatuEs) 
							MsgAlert( STR0334)//"Ja foi realizado o estorno  desse Cupom."
							lRet := .F.	
							Return(lRet)  	
						Endif

		           EndIf 
		           RestArea(aAreaMBZ)
				Endif

			//So permite a exclusao caso o cupom NAO PERTECENCA a uma factura global...                        
			If lRet
				LJMsgRun(STR0216,,{|| aRet:=FRTMyCall("FRTPGlobal", {"SF2","SD2"}, SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_CLIENTE, SL1->L1_LOJA)}) //"Verificando se o cupom pertence a uma nota fiscal global..."
				If AllTrim(aRet[1]) <> "ERRO"

					If AllTrim(aRet[1]) == "EOF"
						MsgAlert( STR0217 ) //"O cupom nao podera ser cancelado porque nao foi encontrado no BackOffice"

					ElseIf AllTrim(aRet[1]) == "GLOBAL"
						MsgAlert( STR0218 ) //"O cupom nao podera ser cancelado porque pertence a uma Nota Fiscal Global"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se a venda jah gerou uma NF s/ cupom fiscal³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf AllTrim(aRet[1]) == "NFCUPOM"
						MsgAlert( STR0315 ) //"O cupom nao podera ser cancelado porque foi gerada uma Nota Fiscal sobre cupom"

					ElseIf AllTrim(aRet[1]) == "QTDEDEV"
						MsgAlert( STR0328 ) //"Cupom não poderá ser cancelado, porque foi realizado devolução de um ou mais itens desta venda."

					EndIf

					lRet := aRet[2]

				Else
					lRet := MsgYesno(STR0219+SL1->L1_DOC+" ?") //"A conexao com o servidor de BackOffice por alguma razao se encontra interrompida. Esse cupom pode pertencer a uma Nota Fiscal. Assim mesmo deseja cancelar o cupom de numero "
				EndIf
			EndIf

			If lRet
				aSL1 := {{"L1_SITUA",	"07"}}				// "07" - Solicitado o Cancelamento do Cupom
				FRTGeraSL("SL1", aSL1)
				     
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Qdo o pais for igual a Mexico eh necessario informar o numero do cupom que esta   ³
				//³sendo cancelado, pois pode ser que nao se trate do ultimo cupom emitido pelo ECF. ³
				//³O tratamento da variavel cSupervisor sera realizado dentro da Dll fiscal.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "MEX"
					cSupervisor := cSupervisor+"/ "+cNumCup
				EndIf
										
				nRet := IFCancCup(nHdlECF, cSupervisor)
				If nRet == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso exista Integracao com o SIGACRD, cancela o Credito em aberto     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					If CrdXInt()
						aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
						aAdd( aDadosCrd, aCrdCliente[1] )		// CNPJ/CPF
						// Faz o desfazimento da transacao de credito						
						CrdxVenda( "3"   ,aDadosCrd  ,If(Empty(SL1->L1_CONTRA),cContrato,SL1->L1_CONTRA),.T.   ,;
						           NIL   ,NIL )		                                                               
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa as variaveis staticas de controle da analise de credito³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FrtSetCrd()
           
					EndIf
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Pega os dados do SL1 antes de deleta-lo ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cLiMsg := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV

					FRTCancela()
				
					FRTHora(.T.)
					lFechaCup := .T.		
					lOcioso   := .T.
					oCupom:Add("")
					oCupom:Add("")
					oCupom:Add(STR0093)	// "         CUPOM FISCAL CANCELADO         "
					oCupom:Add("")
					oCupom:Add("")
					oCupom:Add(DToC(dDatabase)+" "+Time()+STR0030+PadR(SL1->L1_PDV,4)+STR0031+SL1->L1_DOC)	// "  PDV:" "   COD:"
					oCupom:Add("")
					oCupom:Add("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
					oCupom:GoBottom()
					cCupom := oCupom:aItems[Len(oCupom:aItems)-2]

					aItens	:= {}
					aPgtos	:= {}
					aTEFPend:= {}					
					aBckTEFMult := {}
					lOcioso	:= .T.
					lVerTEFPend  := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Zera o valor e o percentual de desconto do item       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrPercIT := 0
					nVlrDescIT := 0 
					nLastTotal:= nVlrTotal
					nLastItem := nTotItens
					nTotItens := 0
					nVlrTotal := 0
					nVlrBruto := 0
					nVlrMerc  := 0
					nTotDedIcms  := 0
					lImpOrc   := .F.  					
					oDesconto:Refresh()
					oTotItens:Refresh()
					oVlrTotal:Refresh()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicializa as variáveis de Templates                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					uCliTPL := Nil     
					uProdTPL:= Nil
		            cCodConv:= "" 		
		            cLojConv:= ""
					cNumCartConv := ""
					FRTInitIT(.T.)
					FRTHora(.T.)
					If oFotoProd:cBMPFile <> "LOJAWIN"
						ShowBitMap(oFotoProd,"LOJAWIN")
					EndIf

					//Restaura as variaveis referentes a moeda para a moeda 1
					If cPaisLoc <> "BRA"
						If nMoedaCor <> 1
							cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
							oTemp3:Refresh()
							oTemp4:Refresh()
							oTemp5:Refresh()

							nTaxaMoeda := 1
							oTaxaMoeda:Refresh()
				
							nMoedaCor := 1
							cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
							oMoedaCor:Refresh() 
						EndIf               

						//Restaura a exibicao da mensagem padrao...
						AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
						oMensagem:cCaption := STR0001  //"   Protheus Front Loja"
						oMensagem:cTitle   := STR0001  //"   Protheus Front Loja"
						oMensagem:oFont    := oFntGet
						oMensagem:Refresh()

						aImpsSL1    := {}
						aImpsSL2    := {}
						aImpVarDup  := {}
						aImpsProd   := {}
						aCols       := {}
						aHeader     := {}
						aCProva     := {}
						aDadosJur   := {0,0,0,0,0,0,0,0,0}
						nVlrFSD     := 0
						nTotalAcrs  := 0
						nVlrDescTot	:= 0											
						nVlrPercTot	:= 0											
						nVlrPercAcr	:= 0											
						nNumParcs   := 0                                            
						nVlrPercOri := 0              
						nQtdeItOri  := 0                              
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera o SLI Independente de Ter Sido Cancelado ou Nao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTGeraSLI("    ", "CAN", cLiMsg, "NOVO")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ P.E. Apos o Cancelamento        ³
					//³ Tipo      : 1 - Item            ³
					//³             2 - Cupom           ³
					//³ Supervisor: Senha que autorizou ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFRTCancelat
						uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{2,cSupervisor,,uProdTPL})
					EndIf
					If ExistBlock("FRTCancela")
						ExecBlock("FRTCancela",.F.,.F.,{2,cSupervisor})
					EndIf 
					If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))               
						T_DroDelANVISA( .T., NIL )
					Endif

				Else
					aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
					FRTGeraSL("SL1", aSL1)
					// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado."
					MsgStop(STR0098+cNumCup+STR0099)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os SetKey's do Fechamento da Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTSetKey(aKey)
					Return(lRet)
				Endif
			EndIf
			SL1->(DbSetOrder(nOrdSL1))
		EndIf
	Else
		// "Usuário sem permissão para cancelar Cupom Fiscal.", "Atenção"
		HELP(' ',1,'FRT036')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTEncerra³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finalizacao da Venda (F9) (Total)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1  - Total por forma de pagamento  					  ³±±
±±³          ³ ExpC2  - Forma de pagamento             					  ³±±
±±³          ³ ExpN3  - Valor juros financeiro       					  ³±±
±±³          ³ ExpL4  - Controla se encerra o Cupom    					  ³±±
±±³          ³ ExpN5  - Valor do desconto financeiro   					  ³±±
±±³          ³ ExpO6  - Objeto da tela de parcelas   					  ³±±
±±³          ³ ExpL7  - Controle se operacao TEF esta pendente   		  ³±±
±±³          ³ ExpA8  - Controle de multiplas transacoes TEF       	      ³±±
±±³          ³ ExpC9  - Numeracao do cartao fidelidade 	    			  ³±±
±±³          ³ ExpL10 - Controle de multiplas transacoes TEF       	      ³±±
±±³          ³ ExpA11 - Guarda a ultima transacao TEF					  ³±±
±±³          ³ ExpC12 - Codigo do DEPENDENTE           	    			  ³±±
±±³          ³ ExpC13 - Nome do DEPENDENTE                  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTEncerra( aFormPag	,cItemForma	,nTmpJuros    ,lEncerra    ,;
                            nTmpDesc	,oFimVenda	,lTEFPendRec  ,aRecTEFMult ,;
                            cNCartao	,lTefPendCS	,aTefBKPCS 	  ,cCodDEP     ,;
                            cNomeDEP )
	
Local aTotForm
Local uRet
Local nRet
Local cRet			 := ""
Local aSL1
Local aSL4
Local nTamSXG
Local lCartao 		 := .F. 
Local lRet    		 := .F.
Local lImpDesc 		 := .F.
Local nI 
Local nJ
Local nX
Local nY
Local nValRec        := 0
Local nPos           := 0
Local aAux           := {}
Local aKey			 := {}
Local aTroco         := {}
Local cMensagem
Local aTpAdms        := {}  
Local aAreaSAE       := {}
Local lTrocoPad      := .F.
Local aAreaSFB       := {}
Local nTotImp        := 0
Local lSubTot        := .F.
Local aCheques
Local nPosAdm        := 0
Local lRetTef		 := .F.
Local aDadosCrd 	 := {}                                       // Dados do cliente para o web service da analise de credito
Local aParcCrd		 := {}                                       // Parcelas do SIGACRD
Local aProdCrd       := {}                                       // Produtos da venda para integracao com SIGACRD
Local aCrdAdm 		 := {}										// Relacao das administradoras (SAE)
Local aRetCrd		 := { 0, 0, 0, "" }                         // Retorno da integracao com SIGACRD
Local lTransCrd		 := .F.										// Indicacao da transacao de credito com sucesso ou nao
Local aTmpCliCrd     := {}
Local nMv_LjChVst	 := SuperGetMV("MV_LJCHVST", ,-1)				// Quantos dias considera um cheque a vista. Se for -1 nao trata o parametro
Local cTotRecNFis    := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI")
Local lTefMult		 := SuperGetMV("MV_TEFMULT", ,.F.)		// Identifica se o cliente utiliza múltiplas transações TEF
Local cAdminis		 := ""									// Administradora a ser conferida 
Local lErrCupTEF     := .F.									// Erro na impressao do cupom
Local lForcada		 := .F.									// Indica se a venda foi off-line ou on-line. SIGACRD.
Local cVinculado	 := "0"									// Se eh venda com vinculado
Local cRespForcada   := ""                                	// Responsavel pela venda forcada
Local cMV_TEFPEND    := SuperGetMV("MV_TEFPEND",,"0")    	// Define o tratamento a ser realizado quando uma ou mais transacoes TEF ficam pendentes
                                                          	// "0" - cancela a transacao
                                                          	// "1" - permite modificar a parcela rejeitada
                                                          	// "2" - pergunta
Local aRetPR         := {}
Local aParcVda       := {}                                 	// Parcelas da venda - integracao com SIGACRD
Local nPosCli		 := 0									// posicao do campo A1_COD no array a clientes
Local nPosLoja		 := 0									// posicao do campo A1_LOJA no array a clientes
Local lNovoCliente	 := .T.									// Variavel que indica se cria ou nao um novo registro no SA1
Local lCheque        := .F.                                	// Indica se a parcela eh cheque
Local nPosTEF		 := 0									// Posicao da primeira parcela referente ao TEF
Local nVlrEntrada	 := 0									// Valor de entrada no parcelamento do TEF
Local nCont			 := 0									// Contador de For
Local nTpVenda       := 1                                    // 1-Venda Normal 2-Venda forcada
Local nMoedaParc     := 1                                    // Moeda da parcela 
Local nPosTEFDados   := 0 									// Posicao correspondente do registro do array aTEFMult no array aParcTEF
Local nPosParcelas   := 0                                	// Posicao correspondente da parcela TEF no array aParcelas
Local nNumParc       := 0                                 	// Posicao da parcela correspondente no array aParcelas 
Local lTrocoAux		 := .T.									// Se existe troco
Local lCancelaTEF    := .T.									// Controla se deve cancelar todas as transacoes TEF se alguma transacao foi reprovada
Local lTemTEFPend    := .F.                                	// Controla se tem transacao TEF jah realizada e pendente 
Local lAbandonaTEF   := .F.  								// Controla se foi selecionada a opcao para nao prosseguir com a operacao TEF
Local aBckParcTEF    := {}                               	// Backup do array aParcTEF
Local aRegsSA1		 := {}									// Utilizada no WSCrdConscli para trazer o cliente para o PDV

Local lDroVLVent	 := ExistTemplate("DroVLVen")			// verifica se existe o PONTO DE ENTRADA DroVLVen
Local lDroVLImpt	 := ExistTemplate("DroVLImp")			// verifica se existe o PONTO DE ENTRADA DroVLImp
Local lFRTEntregt	 := ExistTemplate('FRTEntreg')			// verifica se existe o PONTO DE ENTRADA FRTEntreg
Local nPosFormPg     := 0									// Guarda o valor do comando ascan
Local nZ             := 0									// Variavel utilizada para posicionar aMultTef
Local nTotDescont    := 0                            		// Total do desconto(cond. pagto + desc. total + ded. ICMS)
Local lCpoAcres		 := .F.									// Verifica campo do SE4
Local lVerEmpres     := Lj950Acres(SM0->M0_CGC)				// Verifica as filiais da trabalharam com acrescimento separado
Local lExecVenda	 := .T.									// Se executa o final da venda com orcamento
Local lSemRede		 := .F.									// Variavel que retorna se a rede selecioda no TEF existe na base
Local nLjpagto       := SuperGetMV("MV_LJPAGTO")			// Parametro que retorna como deve aparecer a forma de pagamento.
Local nTotAcres		 := 0									// Total de Acrescimo
Local cIdCartao      := ""									// Identificacao do cartao
Local lTefManual    := .F.                         // Controla se TEF sera feito no P.O.S.
Local lMVTELAFIN	 := SuperGetMV("MV_TELAFIN",,.T.)      // Define de onde pega a ADM financeira
Local nValMerc		 := 0									// Valor das Mercadorias
Local nDescTot		 := 0									// Valor do Desconto sobre o Total
Local nDescItens	 := 0									// Valor do Desconto sobre os itens
Local nValAcres		 := 0									// Valor do Acrescimo
Local nPosCpo		 := 0									// Posicao do Campo no Array aSL1F
Local cSeqTrans		 := cOrcam								// Sequencia da transacao TEF
Local cNumCupFis	 := Space(TamSX3("L1_DOC")[1])			// Tamanho do campo L1_NUMCFIS
Local lCancCup		 := .F.									// Indica se deverá cancelar o Cupom Fiscal em caso de erro no Fechamento da Venda
Local cItemAjuste	 := 0									// Variavel Utilizada no Ajuste do Contador de Itens da SL2

Private aTefMult 	 := {}									// Nova array utilizada nas multiplas transações
Private nDinheiro	 := 0
Private lDinheiro	 := .F.
Private nCheques	 := 0
Private nCartao		 := 0
Private nFinanciado	 := 0
Private nConvenio	 := 0
Private nVales		 := 0
Private nValorDebi	 := 0
Private nOutros		 := 0
Private lCheck		 := .T.										// Usada na Lj220GetCH
Private cForma
Private nDinMoedaCor := 0

//Variaveis utilizadas na consulta do TEF
Private cCartao     := Space(3)
Private cOrcamen    := cOrcam

DEFAULT lTEFPendRec := .F.                                 // Controla se tem transacao TEF jah realizada e pendente 
DEFAULT aRecTEFMult := {}                                                
DEFAULT cCodDEP     := ""									// Codigo do dependente
DEFAULT cNomeDep    := ""               					// Nome do dependente

If (nVlrTotal+nTroco) <= 0
	Return (.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()
lCancelaTEF   := IIf(lTEFMult,(cMV_TEFPEND == "0"),.T.)    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a origem do orcamento for financiada³
//³(dentro dos CNPJS cadastrados no LOJA950),      ³
//³eh necessario preparar a condicao novamente.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOrigOrcam
     For nI := 1 To Len(aPgtos)
		If AllTrim(aPgtos[nI][3]) == "FI" .AND. (aPgtos[nI][13] == 0 .OR. Empty(aPgtos[nI][13]))     	
			lExecVenda := .F.		        
		EndIf
	Next nI
	lOrigOrcam := .F.
	If !lExecVenda	                                      
		//"Este orçamento possui condição de pagamento com acréscimo financeiro, porém, não calculado. Por favor, confirme novamente a condição, pressionando <ESC>, <F9> e <F5>"
		//"Condicao de Pgamento : "
		MsgAlert(STR0316 + Chr(10) + STR0318 + AllTrim(cCdPgtoOrc) + " (" + Alltrim(cCdDescOrc) + ")",STR0003)
		Return .F.	
	EndIf
EndIf

If !lRecebe
	//Verifica se existe alguma forma de pgto que possui administradora porem a mesma nao foi informada nas parcelas geradas para pagamento
	For nI := 1 To Len(aPgtos)                             
		//Caso seja cheque ou dinheiro a verificação não precisa ser efetuada
		If IsMoney(aPgtos[nI][03]) .OR. (aPgtos[nI][03] $ IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE) ) .OR. (aPgtos[nI][03] == "CR")
			Loop
		Else                                                              
			//Monta array com os tipos de administradoras existentes no cadastro de administradoras financeiras
			If Empty(aTpAdms)
				aAreaSAE := SAE->(GetArea())
				SAE->(DbSetOrder(1))
				SAE->(DbSeek(xFilial("SAE")))
				While SAE->(!Eof()) .AND. (SAE->AE_FILIAL == xFilial("SAE"))
					If aScan(aTpAdms,{|x| Trim(x[1])==Trim(SAE->AE_TIPO)}) == 0
						AAdd(aTpAdms, {SAE->AE_TIPO, SAE->AE_COD + " - " + SAE->AE_DESC} )
					EndIf
					SAE->(dbSkip())
				End
				RestArea(aAreaSAE)
			EndIf
			//Verifica se a administradora nao foi informada
			nPosAdm := Ascan(aTpAdms,{|x| Trim(x[1])==Trim(aPgtos[nI][03])})
			If Len(aTpAdms) == 0 .OR. nPosAdm == 0
				lRet := .F.                       			    
				//"E necessário que haja ao menos uma administradora financeira cadastrada para a forma de pagamento selecionada.", "Atenção"
				HELP(' ',1,'FRT038')
            ElseIf Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03]) $ _FORMATEF .AND. lUsaTef
				//Adiciono a primeira forma cadastrada nos casos de TEF pois o sistema altera automaticamente na leitura do cartão
				aPgtos[nI][04] := aTpAdms[nPosAdm][2]
				lRet := .T.				
            ElseIf (Empty(aPgtos[nI][04]) .AND. !Alltrim(aPgtos[nI,03]) $ _FORMATEF) .OR. ;
            		(Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03]) $ _FORMATEF .AND. !lUsaTef)
				lRet := .F.            		
				//"Por favor, selecione uma administradora financeira valida antes de encerrar a venda.", "Atenção"
				HELP(' ',1,'FRT037')
			Else
				lRet := .T.
			EndIf
		EndIf
		If !lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			Return(.F.)
		EndIf
	Next nI
EndIf

If !FRT010VlPar(nVlrTotal)
	//Verifica se o valor total das parcelas nao ficou inferior ao total da venda
	//devido a uma diferenca de "cambio", no momento de converter o valor da parcela
	//para todas as moedas...
	If cPaisLoc <> "BRA" .AND. Len(aPgtos) > 0
		lRet := ((nPos := aScan(aCProva,{|x| x[5]})) == 0)
		If !lRet
			MsgAlert(STR0222+aCProva[nPos][4]+STR0223)	//"O valor em "+aCProva[nPos][4]+" esta incorreto. Depois de acertar o valor tente finalizar a venda."			
		    FRTSetKey(aKey)
		    Return(.F.)			
        EndIf
    Else
    	lRet := .F.
    EndIf
        
	If !lRet
		// "A soma do valor das parcelas está menor que o valor total da venda.", "Atenção"
		HELP(' ',1,'FRT039')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.F.)
	EndIf
EndIf

// Ponto de Entrada para a finalização da venda
If ExistBlock("FRTFINVEN")

	aRetPE := ExecBlock("FRTFINVEN", .F., .F., {nTotDedIcms, aItens, cCliente, cLojaCli,;
																 aPgtos })

	If !aRetPE[01]
		FRTSetKey(aKey)
		Return .F.
	EndIf
	
	If Len(aRetPE) > 1 .AND. ValType(aRetPE[02]) == "N" .AND. aRetPE[02] > 0

		// Soma o valor do segundo retorno para o valor total da venda e dá um refresh no objeto.
		nVlrTotal += aRetPE[02]
		oVlrTotal:Refresh()
		
		// dá um refresh nas formas de pagamento.
		oPgtos:Refresh()

	EndIf

EndIf

nRet := IFStatus(nHdlECF, "9", @cRet)		// Verifico o Status do ECF
If nRet <> 0
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

aTotForm := Array(Len(aFormPag))
AFill(aTotForm, 0)
For nI := 1 To Len(aPgtos)
	cForma := aPgtos[nI][3]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O parametro MV_LJPAGTO retorna um valor inteiro. Pode ser      ³
	//³1 que irá indicar que a descrição da forma de pagto será a da  ³
	//³tabela 24 do SX5 ou 2, que será do cadastro de administradoras ³
	//³(SAE).                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (IsMoney(cForma) .OR. cForma == cSimbCheq) .OR. nLjpagto==1
		aTotForm[AScan(aFormPag, {|x| x[2]==cForma})] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
		                                                         nMoedaCor,dDataBase,;
		                                                         nDecimais+1,,nTaxaMoeda),nDecimais)
	Else
	
		If ( cForma $ _FORMATEF .AND. ! lMV_LJSLFIN )
		
			// Se o parâmetro for falso, joga tudo na primeira forma de pagamento que ele achou (CC/CD)
			aTotForm[aScan(aFormPag, { |x| x[2] == aPgtos[nI,03] })] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
                                                                             nMoedaCor,dDataBase,;
                                                                             nDecimais+1,,nTaxaMoeda),nDecimais)
		Else
			aTotForm[AScan(aFormPag, {|x| PadR(x[1],30)==PadR(Substr(aPgtos[nI][4],7),30)})] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
			                                                                                             nMoedaCor,dDataBase,;
			                                                                                             nDecimais+1,,nTaxaMoeda),nDecimais)
		EndIf

	EndIf
	
Next nI
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aParcelas (ARRAY com as formas e parcelas de pagto)³
//³ 01 - Data de Pagamento 							   ³
//³ 02 - Valor 										   ³
//³ 03 - Forma de Pgto (R$,CC)						   ³
//³ 04 - Administradora 	ou Banco				   ³
//³ 05 - Numero do Cartao 	ou Cheque				   ³
//³ 06 - Agencia do Cheque	 						   ³
//³ 07 - Conta do Cheque 							   ³
//³ 08 - Rg do Cheque 						   		   ³
//³ 09 - Telefone do Cheque 						   ³
//³ 10 - Valor lógico   					  	       ³
//³ 11 - Moeda da parcela (Localizações)   	           ³
//| 12 - Digitos do cartao para TEFMULT                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array PRIVATE aParcelas com as parcelas a pagar aForma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aParcelas  := AClone(aPgtos)
nParcelas  := Len(aPgtos)
aCheques   := {}
aTEFCH     := {}
aTEFCC     := {}
aTEFCD     := {}
lGetCheque := .F.
nEntrada   := 0
lVoltar    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibir o valor do acrescimo separado da parcela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVerEmpres
	For nX := 1 to Len(aParcelas)
		If aParcelas[nX][13] > 0 .AND. aParcelas[nX][3] <> "FI"
			If aParcelas[nX][1] <> dDataBase
				MsgAlert(STR0313) 	//"Nao sera possivel retirar os juros de uma parcela diferente de financiamento."
				FRTSetKey(aKey)
				Return(.F.)
			EndIf
		Endif
	Next nX
Endif			

For nJ := 1 to Len(aParcelas)
	If aParcelas[nJ][3] == cSimbCheq
		If !lGetCheque																				// Processa somente uma vez,
			lGetCheque := .T.																		// Pegando todos os Cheques
			For nI := 1 to Len(aParcelas)
				If AllTrim(aParcelas[nI][3]) == cSimbCheq
					AAdd(aCheques,{aParcelas[nI][1], aParcelas[nI][2], aParcelas[nI][3],;
								   aParcelas[nI][4], aParcelas[nI][5], aParcelas[nI][6],;
								   aParcelas[nI][7], aParcelas[nI][8], aParcelas[nI][9]})
				EndIf
			Next nI
			If SuperGetMV("MV_INFCHEQ")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alteracao especifica para atender a legislacao do SEFAZ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !LjAnalisaLeg(4)[1]
					aDadosCh := LjxDGetCh(GetWndDefault(), cDoc, aCheques, cCliente, ; 
											cLojaCli	, @aParcelas	, @lUsaDisplay)
				EndIf
				If !aDadosCh[1][1]  // Caso esta posicao estiver falsa da um loop
				    If LjAnalisaLeg(4)[1]
						aDadosCh := LjxDGetCh(GetWndDefault(), cDoc, aCheques, cCliente, ; 
										cLojaCli	, @aParcelas	, @lUsaDisplay)
					EndIf
					lVoltar := .T.	// Controla a volta para atela anterior
					Exit
				EndIf
				If (aPgtos[nJ][3] == "CH") .AND. (Len(aDadosCh) > 0)
					aPgtos[nJ][4] := {}
					AAdd(aPgtos[nJ][4],aParcelas[nJ][2]) //1 - Valor
					AAdd(aPgtos[nJ][4],aParcelas[nJ][1]) //2 - Data
					AAdd(aPgtos[nJ][4],"")				//3 - 
					AAdd(aPgtos[nJ][4],aDadosCh[1][2])	//4 - Banco
					AAdd(aPgtos[nJ][4],aDadosCh[1][4])	//5 - Agencia
					AAdd(aPgtos[nJ][4],aDadosCh[1][5])	//6 - Conta
					AAdd(aPgtos[nJ][4],aDadosCh[1][3])	//7 - Numero
					AAdd(aPgtos[nJ][4],aDadosCh[1][9])	//8 - Compensacao
					AAdd(aPgtos[nJ][4],aDadosCh[1][6])	//9 - RG
					AAdd(aPgtos[nJ][4],aDadosCh[1][7])	//10 - Telefone
					AAdd(aPgtos[nJ][4],"")				//11 - 
					AAdd(aPgtos[nJ][4],aDadosCh[1][8])	//12 - Chq Terceiro   
				Else
					aPgtos[nJ][4] := {}
					AAdd(aPgtos[nJ][4],aParcelas[nJ][2]) //1 - Valor
					AAdd(aPgtos[nJ][4],aParcelas[nJ][1]) //2 - Data
					AAdd(aPgtos[nJ][4],"")				//3 - 
					AAdd(aPgtos[nJ][4],"")				//4 - Banco
					AAdd(aPgtos[nJ][4],"")				//5 - Agencia
					AAdd(aPgtos[nJ][4],"")				//6 - Conta
					AAdd(aPgtos[nJ][4],"")				//7 - Numero
					AAdd(aPgtos[nJ][4],"")				//8 - Compensacao
					AAdd(aPgtos[nJ][4],"")				//9 - RG
					AAdd(aPgtos[nJ][4],"")				//10 - Telefone
					AAdd(aPgtos[nJ][4],"")				//11 - 
					AAdd(aPgtos[nJ][4],"")				//12 - Chq Terceiro   		
				EndIf
				nCh := 1
				For nI := 1 to Len(aParcelas)
					If aParcelas[nI][3] == cSimbCheq
						aParcelas[nI][4] := aDadosCh[nCh][2]	// Repassa o aParcelas
						aParcelas[nI][5] := aDadosCh[nCh][3]	// com os dados do cheque.
						aParcelas[nI][6] := aDadosCh[nCh][4]
						aParcelas[nI][7] := aDadosCh[nCh][5]
						aParcelas[nI][8] := aDadosCh[nCh][6]
						aParcelas[nI][9] := aDadosCh[nCh][7]
						nCh ++
					EndIf
				Next nI
			Else
				aPgtos[nJ][4] := {}
				AAdd(aPgtos[nJ][4],aParcelas[nJ][2]) //1 - Valor
				AAdd(aPgtos[nJ][4],aParcelas[nJ][1]) //2 - Data
				AAdd(aPgtos[nJ][4],"")				//3 - 
				AAdd(aPgtos[nJ][4],"")				//4 - Banco
				AAdd(aPgtos[nJ][4],"")				//5 - Agencia
				AAdd(aPgtos[nJ][4],"")				//6 - Conta
				AAdd(aPgtos[nJ][4],"")				//7 - Numero
				AAdd(aPgtos[nJ][4],"")				//8 - Compensacao
				AAdd(aPgtos[nJ][4],"")				//9 - RG
				AAdd(aPgtos[nJ][4],"")				//10 - Telefone
				AAdd(aPgtos[nJ][4],"")				//11 - 
				AAdd(aPgtos[nJ][4],.F.)				//12 - Chq Terceiro   			
			EndIf
		EndIf
		nCheques += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		AAdd(aTefCH,aParcelas[nJ])													// TEF Cheque
	ElseIf aParcelas[nJ][3] == "CC"
		nCartao += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		AAdd(aTefCC,aParcelas[nJ])													// TEF Cartao de Credito
	ElseIf aParcelas[nJ][3] == "CO"
		nConvenio += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	ElseIf aParcelas[nJ][3] == "VA"
		nVales += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	ElseIf IsMoney(aParcelas[nJ][3])
		nDinheiro += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		lDinheiro := .T.
		If (cPaisLoc <> "BRA") .AND. (aParcelas[nJ][11] == nMoedaCor)
			lTrocoPad   := .T.
			nDinMoedaCor += aParcelas[nJ][2]
		EndIf
	ElseIf aParcelas[nJ][3] == "FI"
		nFinanciado += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		If aScan( aCrdAdm, Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]) ) == 0
			SAE->(DbSetOrder(1))
			If SAE->(DbSeek( xFilial("SAE")+Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]) ))
				If SAE->(FieldPos("AE_PLABEL")) > 0
				If SAE->AE_PLABEL == "1"
					aAdd( aCrdAdm, { Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]),;
									 Substr(aParcelas[nJ][4], AT("-",aParcelas[nJ][4])+2,Len(aParcelas[nJ][4])) } )
					Endif
				Endif
			Endif
		Endif
	ElseIf aParcelas[nJ][3] == "CD"
		nValorDebi += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		aAdd(aTefCD,aParcelas[nJ])													// TEF Cartao de Debito
	Else
		nOutros += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
	If aParcelas[nJ][1] == dDatabase .AND. !(aParcelas[nJ][3] $ SuperGetMV("MV_ENTEXCE"))
		nEntrada += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
Next nJ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se escolheu voltar na getcheques ³
//³ retornar a tela anterior                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVoltar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se estah integrado com o sistema de credito SIGACRD       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa a indicacao do cliente caso a venda tenha sido rejeitada para o   ³
	//³caso de utilizar outro cartao na finalizacao da venda                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVerEmpres .AND. Fieldpos("E4_AGRACRS") > 0
		DbSelectArea("SE4") 
		DbSetOrder(1)
		If DbSeek(xFilial("SE4") + cItemCond)
			If SE4->E4_AGRACRS == "2"
				lCpoAcres := .T.
			EndIf
		EndIf
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta os dados com as a venda para o sistema de credito fazer a³
	//³checagem do credito e a liberacao da venda                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParcCrd := {}
	For nI := 1 To Len(aParcelas)
	   lCheque     := AllTrim(aParcelas[nI][3])=="CH"
	   nMoedaParc  := IIf(cPaisLoc == "BRA", 1, aParcelas[nI][11])	
	   Aadd(aParcVda,{aParcelas[nI][1],;                									  	// Data de vencimento
		              IIf(!lCpoAcres,aParcelas[nI][2],aParcelas[nI][2]+aParcelas[nI][13]),;	// Valor da parcela
		     		  aParcelas[nI][3],;                										// Forma de pagamento
		     		  aParcelas[nI][4],;                										// Codigo da administradora ou numero do banco
		     		  aParcelas[nI][5],;                										// Numero do cartao ou cheque
		              IIf(lCheque,aPgtos[nI][6],""),;  										// Agencia do cheque
			 		  IIf(lCheque,aPgtos[nI][7],""),;  										// Conta do cheque
			 		  IIf(lCheque,aPgtos[nI][8],""),;  										// RG do cheque
			 		  IIf(lCheque,aPgtos[nI][9],""),;  										// Telefone do portador do cheque
		     		  .F.,;                             										// 
			 		  nMoedaParc })	                    										// Moeda da parcela		     		  		     		  
		If lCpoAcres
			nTotAcres += aParcelas[nI][13]			
		Endif
	Next nI
	
	aProdCrd := {}

	SL2->( DbSetOrder( 1 ))
	SL2->( DbSeek( xFilial("SL2") + cOrcam) )
	While SL2->( !Eof() ) .AND. SL2->(xFilial("SL2") + cOrcam == L2_FILIAL+L2_NUM )
		AAdd( aProdCrd, { SL2->L2_ITEM,;      //Item do Produto
		                  SL2->L2_PRODUTO,;   //Codigo do Produto
		                  SL2->L2_DESCRI,;    //Descricao do Produto
		                  SL2->L2_QUANT,;     //Quantidade de pecas vendidas
		                  SL2->L2_VRUNIT,;    //Valor unitario do produto
		                  SL2->L2_VLRITEM} )  //Valor total da venda do item
	
		SL2->( dbSkip() )
		Loop
	End

	If Len(aParcVda) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura da array aDadosCrd                                   ³
		//³[1] - Numero do cartao                                         ³
		//³[2] - Numero do CPF                                            ³
		//³[3] - Valor da venda (valor liquido)                           ³
		//³[4] - Juros da venda (%)                                       ³
		//³[5] - Numeros de parcelas                                      ³
		//³[6] - Venda forcada (1-Venda Normal 2-Venda forcada)           ³
		//³[7] - Responsavel pela venda forcada                           ³
		//³[8] - Array com as parcelas para o financiamento               ³
		//³      [1] - Data de vencto                                     ³
		//³      [2] - Valor da parcela                                   ³
		//³      [3] - Forma de pagto                                     ³
		//³      [4] - Administradora financeira                          ³
		//³[9] - Loja que solicitou a transacao                           ³
		//³[10] - Numero do PDV que solicitou a transacao                 ³
		//³[11] - Caixa que solicitou a transacao                         ³
		//³[12] - Numero do Orcamento selecionado                         ³
		//³[13] - Produtos contido na venda atual.                        ³		
		//³      [1] - Item do produto                                    ³
		//³      [2] - Codigo do produto                                  ³
		//³      [3] - Descricao do produto                               ³
		//³      [4] - Quantidade de pecas                                ³
		//³      [5] - Valor unitario do produto                          ³		
		//³      [6] - Valor total do item do produto                     ³	    
		//³[14] - Parcelas de uma venda.                                  ³				
		//³      [1] - Data de vencto                                     ³
		//³      [2] - Valor da parcela                                   ³
		//³      [3] - Forma de pagto                                     ³
		//³      [4] - Administradora                                     ³
		//³      [5] - Numero do cartao / cheque                          ³
		//³      [6] - Agencia - Cheque                                   ³
		//³      [7] - Conta - Cheque                                     ³
		//³      [8] - Rg - Cheque                                        ³
		//³      [9] - Telefone - Cheque                                  ³
		//³      [10] - Valor logico                                      ³
		//³      [11] - Moeda da parcela (localizacoes)                   ³
		//³[15] - Filial do Caixa que esta sendo utilizado.               ³
		//³[16] - Codigo do cliente                                       ³				
		//³[17] - Loja do cliente                                         ³				
		//³[18] - Nome do usuario                                         ³				
		//³[19] - Condicao de Pagamento                                   ³				
		//³[20] - Modulo que chamou a avaliacao de credito                ³				
		//³[21] - Codigo do vendedor                                      ³						
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosCrd := {}
		aAdd( aDadosCrd, aCrdCliente[2] )													// 01 Numero do cartao
		aAdd( aDadosCrd, aCrdCliente[1] )													// 02 CNPJ/CPF
		aAdd( aDadosCrd, nVlrTotal+ nTotAcres )												// 03 Valor da venda
		aAdd( aDadosCrd, (nVlrAcreTot * 100 / (nVlrTotal-nVlrAcreTot)) )					// 04 Juros da venda
		aAdd( aDadosCrd, Len(aParcVda) )													// 05 Numero de parcelas
		aAdd( aDadosCrd, nTpVenda )															// 06 Venda forcada
		aAdd( aDadosCrd, cRespForcada )														// 07 Responsavel pela venda forcada
		aAdd( aDadosCrd, aClone(aParcCrd) )													// 08 Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
		aAdd( aDadosCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  )	// 09 Loja da venda
		aAdd( aDadosCrd, LjGetStation("LG_PDV"))											// 10 PDV
		aAdd( aDadosCrd, xNumCaixa() )														// 11 Caixa
		aAdd( aDadosCrd, cOrcam )															// 12 Num. do orcamento
		aAdd( aDadosCrd, aClone(aProdCrd) )													// 13 Produtos selecionados numa venda
		aAdd( aDadosCrd, aClone(aParcVda) )													// 14 Parcelas de uma venda
		aAdd( aDadosCrd, FWGETCODFILIAL )													// 15 Filial do Caixa que esta sendo utilizado 	
		aAdd( aDadosCrd, cCliente )															// 16 Codigo do cliente
		aAdd( aDadosCrd, cLojaCli )															// 17 Loja do cliente  
		aAdd( aDadosCrd, cUserName )														// 18 Nome do usuario		
		aAdd( aDadosCrd, cItemCond )												  		// 19 Condicao de Pagamento
		aAdd( aDadosCrd, "FRT"     )												  		// 20 Modulo chamador		
		aAdd( aDadosCrd, cVendLoja )												  		// 21 Codigo do vendedor
	    
		aRetCrd := aClone(CrdxVenda( "1"   	,@aDadosCrd  	, Nil   , .T.  ,;
		                              Nil   ,"43" 			, Nil	, @aRecCrd))
		
		//Verifica se eh venda financiada
		If Len(aDadosCrd[8]) > 0
           //O array recebe as parcelas que foram financiadas
		   aParcCrd:= aClone(aDadosCrd[8])
		   If !aRetCrd[5]
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³A liberacao do credito foi confirmada                                   ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  lVoltar 	  := .F.
			  lTransCrd   := .T.
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³Alimenta as variaveis referente aos dados do cliente                    ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  // Verifica se a venda foi off-line 
			  If aRetCrd[1] == 2 
				 lForcada   := .T.
				 If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
					 If Empty(cCliente + cLojaCli)
						 cCliente	:= SuperGetMV("MV_CLIPAD")		
						 cLojaCli	:= SuperGetMV("MV_LOJAPAD")		
					 Endif
				 Else
				 	cCliente	:= SuperGetMV("MV_CLIPAD")		
				 	cLojaCli	:= SuperGetMV("MV_LOJAPAD")									  			 
				 Endif
			  Else
				 cCliente	:= aDadosCrd[16]
				 cLojaCli	:= aDadosCrd[17]
			  EndIf
		   Else
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³A liberacao do credito nao foi confirmada                               ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		      cCliente	   := aDadosCrd[16]
			  cLojaCli	   := aDadosCrd[17]
			  lVoltar 	   := .T.
			  lTransCrd    := .F.
		   EndIf

		   //[1]-CPF [2]-Numero do Cartao Private Label
		   aCrdCliente[1]  := aDadosCrd[2]  		
		   aCrdCliente[2]  := aDadosCrd[1]  				
		   cContrato 	   := aRetCrd[4]		
		   If !Empty(cContrato) .AND. Ascan(aContratos,{|x| Trim(x) == Trim(cContrato)}) == 0
		      Aadd(aContratos,cContrato)
		   EndIf
		Else
			cContrato    := Space(TamSx3("MAH_CONTRA")[1])		   
		EndIf   
	EndIf	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a transacao TEF                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lUsaTef .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF) .AND. ;
    (!CrdxInt() .OR. (CrdxInt() .AND. (aRetCrd[1] == 0 .OR. aRetCrd[1] == 2)))
	lTefOk 		:= .F.
	lRet   		:= (nRet = 0)
	aParcTef 	:= {}
	
	//ATENCAO VERIFICAR O SIGACRD
	If cTipTef == TEF_CLISITEF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponte de Entrada de Templates para a rotina do PBM Vidalink.  ³
	//³Informa ao VidaLink os produto e quantidades vendidas.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDroVLVent
			aRet := ExecTemplate("DroVLVen",.F.,.F.,{nVidaLink,aVidaLinkC,aVidaLinkD})
			nVidaLink  := aRet[1]    
			aVidaLinkC := aClone(aRet[2])                          
			aVidaLinkD := aClone(aRet[3])    
		EndIf
		//Pegando os dados totalizados de cartões a serem enviados para a transacao TEF
		For nJ := 1 To Len(aPgtosSint)
			If AllTrim(aPgtosSint[nJ][1]) $ _FORMATEF

				//Verica o valor da primeira parcela a ser enviada para a transação TEF
				nPosTEF 	:= Ascan(aParcelas,{|x| AllTrim(x[3])+AllTrim(x[12]) == AllTrim(aPgtosSint[nJ][1])+AllTrim(aPgtosSint[nJ][4]) } )
				nVlrEntrada := If(nPosTEF>0,aParcelas[nPosTEF][2],0)

		        Aadd(aParcTEF,{ aPgtosSint[nJ][5],;											//Data
			        		    Val(StrTran(StrTran(aPgtosSint[nJ][3],",",""),".",""))/100,;	//Valor
			        		    aPgtosSint[nJ][1],;											//Forma
			        		    aPgtosSint[nJ][4],;											//ID para identificação da forma de pagamento na operação TEF
			        		    aPgtosSint[nJ][2],;											//Qtde de Parcelas
								nVlrEntrada,;												//Valor Entrada
			        		    {Space(03),Space(3),Space(04),Space(10),Space(07),Space(15),Space(15)}})//Dados do Cheque
				lCartao := .T.
			EndIf
		Next nJ
		//Se a estação utilizar consulta de cheques pegar os dados analíticos de todos os cheques a serem consultados
		If At("S",LjGetStation("TEFCONS")) <> 0	
			For nJ := 1 To Len(aParcelas)
				If AllTrim(aParcelas[nJ][3]) == cSimbCheq
			        Aadd(aParcTEF,{ aParcelas[nJ][1],;										//Data
				        		    aParcelas[nJ][2],;										//Valor
				        		    aParcelas[nJ][3],;										//Forma
				        		    aParcelas[nJ][12],;										//ID para identificação da forma de pagamento na operação TEF
									1,;														//Qtde de parcelas
									0,;
		    	    		    	{Space(03),aParcelas[nJ][4],aParcelas[nJ][6],aParcelas[nJ][7],aParcelas[nJ][5],Space(15),Space(15)}})	//Dados do Cheque
					lCartao := .T.
				EndIf		    	    		    	
			Next nJ
	    EndIf
	Else
		For nJ := 1 To Len(aParcelas)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver integracao com o SigaCrd verifica se a parcela jah foi enviada ³
			//³ para o financiamento (se estah no array aParcCrd)                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CrdXInt()
				If aScan( aParcCrd, {|x| x[1]==aParcelas[nJ][1] .AND. x[2]==aParcelas[nJ][2] .AND. x[3]==aParcelas[nJ][3] .AND. x[4]==aParcelas[nJ][4] } ) == 0
					If AllTrim(aParcelas[nJ][3]) $ _FORMATEF .OR. (AllTrim(aParcelas[nJ][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS")) <> 0)
						If lUsaTef .AND. lTefMult
							If Alltrim(aParcelas[nJ][3]) == cSimbCheq
								Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][5], aParcelas[nJ][4], aParcelas[nJ][6], aParcelas[nJ][7], nJ})
												//Data Pgto     , Valor          , Forma          , Nº do Cheque   , Banco    	   , Agencia        , Conta          ,Posição no array aParcelas
							Else
								Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][4], nJ, aParcelas[nJ][12] })
												//Data Pgto     , Valor          , Forma          , Adm ou Banco   , Posicao , ID para TEFMULT
												//																	  array
							EndIf
						Else
							aadd(aParcTef,aParcelas[nJ])
						EndIf
						lCartao := .T.
					EndIf
				Endif
			Else
				If AllTrim(aParcelas[nJ][3]) $ _FORMATEF .OR. (AllTrim(aParcelas[nJ][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS"))<>0)
					If lUsaTef .AND. lTefMult
						If Alltrim(aParcelas[nJ][3]) == cSimbCheq
							Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][5], aParcelas[nJ][4], aParcelas[nJ][6], aParcelas[nJ][7], nJ})
							               //Data Pgto     , Valor           , Forma           , Nº do Cheque    , Banco    	   , Agencia        , Conta          ,Posição no array aParcelas
						Else
							Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][4], nJ, aParcelas[nJ][12] })
										  //Data Pgto       , Valor          , Forma           , Adm ou Banco   , Posicao , ID para TEFMULT
										  //																	   array
						EndIf
					Else
						Aadd(aParcTef,aParcelas[nJ])
					EndIf
					lCartao := .T.
				EndIf
			Endif
		Next nJ
	EndIf
	
	If lUsaTef .AND. lCartao
		
		If cTipTef == TEF_CLISITEF
			oTEF:Operacoes( "V", 		aParcTef, 		@lTEFPendCS, 	@aTefBKPCS,;
						    cSeqTrans, 	@aFormCtrl,		@aPgtos,		@aPgtosSint, ;
							@oPgtos, 	@oPgtosSint	)
						    
			LJTEFConfRW( GetClientDir() + "CLISITEF."+StrZero(oTEF:nIDTermina,3), .T., oTEF:cCupom, oTEF:cData,;
						 oTEF:cHora )

				lTefOk	:= oTef:lTefOk
				lRet	:= oTef:lTefOk

			If !lTefMult
				lTefPendCS 	:= lTefOK
			EndIf
			If lTefOk
				If !lMVTELAFIN
					// Ordenado por ID
					Asort(aPgtos,,,{ |x,y| X[12] < Y[12]})
					nI := 1
					For nX := 1 To Len(oTef:aRetCartao)
						If !Empty(oTef:aRetCartao[nX]:cHoraTrans)
							cAdminis := LJ7ConfAdm( aPgtos[nI][4], oTef:aRetCartao[nX]:cDescAdm, @lSemrede )
							If Empty( cAdminis )
								HELP( " ", 1, "SEMINSTITU" )
								// ### "Administradora: " ### ". Efetue o cadastro da Administradora no arquivo SAE e salve esta venda como Orçamento."
								MsgInfo(STR0319 + TRIM(oTef:aRetCartao[nX]:cDescAdm) + STR0320)
								lVldTef := .T.
							Else
								cIdCartao := aPgtos[nI][12]
								While nI <= Len(aPgtos) .AND. aPgtos[nI][12] == cIdCartao .AND. aPgtos[nI][3] $ _FORMATEF
									aPgtos[nI][4]:= cAdminis
									++nI                    
								End
							Endif
						EndIf
					Next nX
					// Volto a ordem que estava anteriormente
					Asort(aPgtos,,,{ |x,y| X[3] > Y[3]})
					If lSemRede
						oTEF:FinalTrn(0)
					EndIf
				EndIf
				If !lTefMult
					If lSemRede .AND. lTefPendCS
						lTefPendCS := .F.
						aTefBKP := {}
						lVoltar := .T.
					EndIf
				Else
					lVoltar := lSemRede
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui do array aParcTEF as transacoes que jah foram realizadas e estao   ³
			//³ pendentes no servidor TEF, procedimento adotado quando rejeita a segunda  ³
			//³ transacao TEF  															  ³			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			lTemTEFPend  := .F.	
			If lTefMult .AND. cMV_TEFPEND $ "1|2"
			   aBckParcTEF  := AClone(aParcTEF)
		       For nX := 1 to LEN(aTEFPend)
		          nPosTEFDados  := FRTSeekParc( nX  ,aTEFPend )
			      If nPosTEFDados > 0
			         ADEL(aParcTef, nPosTEFDados)         
			         ASIZE(aParcTef, LEN(aParcTef) - 1)
			         lTemTEFPend  := .T.
		          EndIf
		       Next nX
		    EndIf 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		      
			//³ Chama a funcao LOJA010T apenas se houver transacao que ainda nao foi rea- ³						
			//³ lizada. Se MV_TEFPEND = "0", entra nesta condicao porque lTemTEFPend = .F.³									
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				    
		    If !lTemTEFPend .OR. LEN(aParcTEF) > 0
			   lTefOk := LOJA010T(	"V"	, NIL, aParcTef    	, NIL         	, ;
			   						NIL	, NIL, @lTemTEFPend	, @lAbandonaTEF	, ;
			                       	Nil , Nil, Nil			, @lSemRede  )
			   
			   // Se tiver Tef pendente segue normalmente, 
			   // isso significa que conseguiu fazer a primeira transação.
               lRet := lTemTEFPend
				
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³Acrescentar a transacao anteriomente aprovada no array aTEFMult³
			   //³para que seja confirmada posteriormente. Deve ser colocado na  ³
			   //³ordem em que foi realizada a transacao						 ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   If lTefOk .AND. lTemTEFPend .AND. lTefMult
			      For nX := 1 to LEN(aBckTEFMult)
	                 aAdd(aTEFMult,{})
					 aIns(aTEFMult,nX)
					 aTEFMult[nX] := Array(11)					 
					 For nY := 1 to LEN(aBckTEFMult[nX])
					    If ValType(aBckTEFMult[nX][nY]) <> "A"
					       aTEFMult[nX][nY] := aBckTEFMult[nX][nY]
					    Else 
					       aTEFMult[nX][nY] := AClone(aBckTEFMult[nX][nY])
					    EndIf   
					 Next nY
			      Next nX                     
			   EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		      
			//³ Se ha transacao TEF pendente(lTemTEFPend = .T.) e a transacao reprovada   ³						
			//³ foi substituida por uma parcela que nao use TEF(dinheiro, cheque etc.)    ³									
			//³ volta o backup em aTefMult e aParcTEF para que a transacao aprovada seja  ³												
			//³ confirmada																  ³															
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				    			   
			ElseIf lTefMult .AND. cMV_TEFPEND $ "1|2"
			   lTefOk  := .T.   
			   aTEFMult  := AClone(aBckTEFMult)
			   aParcTEF  := AClone(aBckParcTEF)
			EndIf   
		EndIf
		
		If !Valtype(lTefOk ) == "L"
			lTefOk := .F.
		ElseIf !lTefOk
			If cTipTef <> TEF_CLISITEF
			
				If cMV_TEFPEND $ "1|2"
					//Foi colocado um parâmetro para determinar se o cliente utiliza ou não esta pergunta
					If !SuperGetMV("MV_TEFMANU", ,.T.)
						lRet 	:= .F.
					Else
						If lSemrede
							lRet := .F.
						Else
							//"Continua Manualmente?"
							If ( lRet := LojaOk(STR0152) )
								lCancelaTEF  := .F.
								lVerTEFPend  := .T.
							EndIf
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Permite a selecao de nova forma de pagamento ou cancela todas caso alguma³
				//³transacao TEF tenha sido reprovada                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lTefMult .AND. cMV_TEFPEND $ "1|2" .AND. !lAbandonaTEF .AND. lTemTEFPend 	//1 = Digita nova forma de pagamento; 2 = Pergunta ao Caixa 
			        If IIf(cMV_TEFPEND == "2",Aviso(STR0003,STR0299 + CRLF + ; 				//"Atenção", "Selecione a opção desejada:"		 
			                                        STR0300 + CRLF + ;							//"Modificar - altera a parcela atual"
			                                        STR0301,;									//"Cancelar - cancela todas as transações TEF desta venda"                                 
			                                        {STR0302,STR0303}) == 1,.T.)				//"Modificar", "Cancelar" 

			           lCancelaTEF  := .F.
			           lVerTEFPend  := .T.
			           For nX := 1 to Len(aTEFMult)
			              nPosTEFDados  := 0			              
						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  //³[8] - Resultado da transacao -> Verifica se foi reprovada³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			              If !aTEFMult[nX][8]
			                 nPosTEFDados  := FRTSeekParc( nX  ,aTEFMult )
			                 If nPosTEFDados > 0
			                    nPosParcelas  := 0
			                    If LEN(aParcTEF[nPosTEFDados]) == 6       //Cartao
			                       nPosParcelas  := aParcTEF[nPosTEFDados][5]  //Posicao no array aParcelas 
			                    ElseIf LEN(aParcTEF[nPosTEFDados]) == 8   //Cheque
			                       nPosParcelas  := aParcTEF[nPosTEFDados][8]  //Posicao no array aParcelas
			                    EndIf
			                    If nPosParcelas > 0
			                    	If !lRet
				                    	FRTNovoPgto( nPosParcelas, oFimVenda )
				                    EndIf
			                       Exit
			                    EndIf
			                 EndIf
			              Else
						     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						     //³Alimenta com as transacoes realizadas mas pendentes, que devem ser confirmadas posteriormente³
						     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						     If Ascan(aTEFPend,{|x| x[1] == aTEFMult[nX][1] .AND. x[2] == aTEFMult[nX][2]}) == 0
			                    AADD(aTEFPend,{aTEFMult[nX][1], aTEFMult[nX][2]})
			                    			                    			                                                    
			                    AADD(aBckTEFMult,{aTEFMult[nX][1], aTEFMult[nX][2], aTEFMult[nX][3], ;
			                                      aTEFMult[nX][4], aTEFMult[nX][5], aTEFMult[nX][6], ;
			                                      aTEFMult[nX][7], aTEFMult[nX][8], aTEFMult[nX][9], ;
			                                      aTEFMult[nX][10], aTEFMult[nX][11] })
			                 EndIf                        
			              EndIf
			           Next nX
			        Else
			           lCancelaTEF   := .T.
			        EndIf
			    EndIf    
			    If lCancelaTEF
					//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
					If TEF_lEnvDF()
						If LOJA010T("F"   ,"D"   ,NIL   ,NIL   ,;
						            NIL   ,NIL   ,NIL   ,NIL   )
							MsgAlert(STR0274) 	//"Transação TEF cancelada!"
						EndIf
						//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
					ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. lTefMult
						If LOJA010T("F"    ,"N"   ,NIL   ,NIL   ,;	//Antigamente esta função nao retornava verdadeiro ou falso
						             NIL   ,NIL   ,NIL   ,NIL   ) 
							MsgAlert(STR0274) 	//"Transação TEF cancelada!"
						EndIf
					EndIf
			    EndIf
			Endif
		EndIf
		
		If !lTefOk
			If cMV_TEFPEND == "0" .AND. cTipTEF <> TEF_CLISITEF
				//Foi colocado um parâmetro para determinar se o cliente utiliza ou não esta pergunta
				If !SuperGetMV("MV_TEFMANU", ,.T.)
					lRet 	:= .F.
				Else
					If lSemRede
						lRet := .F.
					Else
						//"Continua Manualmente?"
						lRet := LojaOk(STR0152)
						lTefManual := lRet						
					EndIf
				EndIf
			Else
				If cTipTef <> TEF_CLISITEF
					lTefOk := .T.
				EndIf
			EndIf

			If lUsaDisplay
				If lRet
					DisplayEnv(StatDisplay(), "1C" + STR0269 )         //"Encerrando Venda"
					DisplayEnv(StatDisplay(), "2C" + " ")
				Else
					DisplayEnv(StatDisplay(), "1E"  + STR0258 + Str(nVlrTotal,8,2) + " " + STR0270 + " 0,00"  )         //"Total: "    ""Saldo: ""
					DisplayEnv(StatDisplay(), "2C"  + STR0271 )         //"PRESSIONE <F9> P/ FECHAR A VENDA"
				EndIf
			EndIf
			lVoltar := !lRet
		EndIf
	EndIf
EndIf

If lVoltar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

//O tratamento de troco, para paises outros paise, é realizado através da
//função LjCalcTrc, pois devem ser consideradas múltiplas moedas
If (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC",,.F.)
	//PE que retorna para quais formas de pagamento pode ser gerado troco. 
 	If ExistBlock("FORMSTRC")
		aAux := ExecBlock("FORMSTRC",.F.,.F.)
	Else
		//Caso nao exista o PE FORMSTRC podera ser gerado troco para todas 
		//as moedas mais cheque
	    aAux := {SuperGetMV("MV_SIMB1")}
	    For nI := 2 To MoedFin()
	    	Aadd(aAux,(SuperGetMV("MV_SIMB"+STR(nI,1),.F.,"") ) ) 
	    Next nI
	   	Aadd(aAux,cSimbCheq)
	EndIf
	
	For nI := 1 To Len(aParcelas)
		If Ascan(aAux,{|x| Trim(x) == Trim(aParcelas[nI][3])}) > 0
			nValRec += Round(xMoeda(aParcelas[nI][2],aParcelas[nI][11],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
		EndIf
	Next nI              
	//So executa a rotina de troco localizada caso tenha ocorrido recebimento em
	//alguma forma valida para calculo do troco...
	If nValRec > 0               
	   //Se apenas uma moeda esta ativa e o parametro MV_LJTRAUT esta setado para .T.
	   //preenche o troco automaticamente sem mostrar a tela de troco ao usuario
	   If Len(aMoeda) == 1 .AND. SuperGetMV("MV_LJTRAUT",,.T.)  
	      nTroco 	:= Round(Abs(nValRec-nVlrBruto),nDecimais) 
	      lTrocoPad := If(nTroco > 0,.F.,lTrocoPad)
	      aTroco 	:= {{nTroco,nTroco,0,nMoedaCor}}
	   Else
		  aTroco := LjCalcTrc("FRONT",nValRec,nVlrBruto		,NIL 	,;
		  						NIL		, NIL	, NIL 		,aDadosJur)
	      If ValType(aTroco) == "L"
		     If !aTroco
			    If lDinheiro
				   nDinheiro := 0
			    Else
				   nVales:= 0
			    EndIf
	
			    cRetorno := ' '
			    If IFStatus(nHdlECF, '5', @cRetorno ) == 7	// Verifica se tem cupom aberto.
				   lVoltar := .T.
			    EndIf
		     EndIf
	      Else
		     AEval(aTroco,{|x,y| nTroco += xMoeda(	aTroco[y][02],	aTroco[y][04],	nMoedaCor,	dDataBase,;
		     										MsDecimais(	aTroco[y][04])+1	,	,nTaxaMoeda)})
		     nTroco		:= Round(nTroco,nDecimais)
		     nEntrada	-= nTroco
             If nTroco > 0
             	lTrocoPad := .F.
             EndIf
	      EndIf		  
	   EndIf	  
	Else
	   For nI := 1 To MoedFin() 
		  AAdd(aTroco,{0,0,0,nI})	
	   Next nI
	   nTroco  := 0
	EndIf    
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houver integracao com o CRD e a venda tiver sido bloqueada,³ 
//³ volta para a tela da venda, sem finalizar.		    		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()
	If !lTransCrd .AND. lVoltar
		FRTSetKey(aKey)
		Return(.F.)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha escolhido Dinheiro Solicita a digitacao do Troco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lDinheiro .OR. nVales > 0) .AND. nTroco == 0 .AND. Iif(cPaisLoc <> "BRA",lTrocoPad .AND. ValType(aTroco) <> "L",.T.)

	uRet := LjxDGetTroco(	GetWndDefault(), lDinheiro , nDinMoedaCor	, @nDinheiro	,;
							@nVales		   , nTroco	 )
	
	If ValType(uRet) == "L"
		If !uRet
			If lDinheiro
				nDinheiro := 0
			Else
				nVales:= 0
			EndIf
	
			cRetorno := ' '
			If IFStatus(nHdlECF, '5', @cRetorno ) == 7 	.OR. lRecebe// Verifica se tem cupom aberto.
				lVoltar := .T.
			EndIf
		EndIf
	Else
		nTroco   := uRet
	EndIf
EndIf

If lVoltar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso possua Troco, eh adicionado ao valor da respectiva moeda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	lTrocoAux := lTrocoPad
Else
	lTrocoAux := .T.
Endif	

If (cPaisLoc == "BRA") .OR. !(SuperGetMV("MV_LJTRLOC",,.F.)) .OR. lTrocoAux
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le as formas de pagamento da venda efetuada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To Len(aFormPag)
		If aTotForm[nCont] > 0
			If aFormPag[nCont][2] == cSimbCor	// Dinheiro
				aTotForm[nCont] += nTroco                 
			ElseIf aFormPag[nCont][2] == "VA" // Vales
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A agregacao do troco ao valor total da condicao de pagamento³
				//³so podera ser feita caso seja diferente de Dinheiro, o campo³
				//³L1_TROCO1 nao esteja cadastro na base de dados e o          ³
				//³parametro MV_LJTROCO esteja com F (false)                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lDinheiro .AND. !( SL1->( FieldPos( "L1_TROCO1" ) ) > 0 .AND. SuperGetMV( "MV_LJTROCO", ,.F. ) )
					aTotForm[nCont] += nTroco
				Endif
			Endif
		Endif
	Next nCont
Endif

If oFotoProd:cBMPFile <> "LOJAWIN"
	ShowBitMap(oFotoProd,"LOJAWIN")
Endif

If nVlrTotal > nVlrBruto
	oCupom:Add(STR0188+Trans(If(cPaisLoc=="BRA",nVlrTotal-nVlrBruto,aDadosJur[1]),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "     A C R E S C I M O   "
	lSubTot := .T.
ElseIf nVlrTotal < nVlrBruto
	oCupom:Add(STR0189+Trans(If(cPaisLoc=="BRA",nVlrBruto-nVlrTotal,aDadosJur[9]),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "     D E S C O N T O     "
	lSubTot := .T.
EndIf

If lSubTot .AND. (cPaisLoc <> "BRA")
	AEval(aImpsSL1,{|x,y| nTotImp += aImpsSl1[y][3]})
	oCupom:Add(FRT_SEPARATOR)
	oCupom:Add(STR0071+Trans(nVlrTotal-nTotImp,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)))  //"     S U B T O T A L      "	
	aAreaSFB := SFB->(GetArea())
	SFB->(DbSetOrder(1))
	For nI := 1 To Len(aImpsSL1)
		SFB->(DbSeek(xFilial("SFB")+aImpsSL1[nI][1]))
		oCupom:Add(Space(05)+SubStr(SFB->FB_DESCR,1,10)+Space(11)+Trans(aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor)))
	Next nI
	RestArea(aAreaSFB)
	nTotImp := 0
EndIf
oCupom:Add(FRT_SEPARATOR)
oCupom:Add(STR0101+Trans(nVlrTotal,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "     T O T A L           "

nX := 0
For nI := 1 To Len(aFormPag)
	If aTotForm[nI] > 0
		If cTipTef == TEF_CLISITEF
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
				oCupom:Add("     "+PadR(aFormPag[nI, 3], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
			Else
				++nX
				If nLjpagto==1
					oCupom:Add("     "+PadR(AllTrim(Upper(RetDescri(oTef:aRetCartao[nX]:cForma))) ,20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))	
			    Else
					oCupom:Add("     "+PadR(oTef:aRetCartao[nX]:cDescadm, 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
				EndIf
			EndIf
		Else
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
				oCupom:Add("     "+PadR(aFormPag[nI, 3], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
			Else
				++nX
				If nLjpagto==1
					oCupom:Add("     "+PadR(Upper(aFormPag[nI][3]),20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
				Else
					If lTefMult
						oCupom:Add("     "+PadR(aTefMult[nI][7][1][8], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
					Else
						oCupom:Add("     "+PadR(aTefDados[nI, 8], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor)))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nI
oCupom:Add("")
If (cPaisLoc == "BRA") .OR. Iif(cPaisLoc <> "BRA",lTrocoPad,.T.)
	oCupom:Add(STR0102+Trans(nVlrTotal+nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "     VALOR RECEBIDO      "
ElseIf (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC",,.F.) 
	nPos := AScan(aTroco, {|x| x[4]==nMoedaCor})
	oCupom:Add(STR0102+Trans(nVlrTotal+aTroco[nPos][01],PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "     VALOR RECEBIDO      "
EndIf

If nTroco > 0 
	oCupom:Add(STR0103+Transform(nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	// "          TROCO          "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Troco no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDisplay(7, {nTroco})
	
	If lUsaDispTor
		MsgDispTor(7, {nTroco}) 		
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
//³possibilita ao usuario montar um parametro o qual seja executada  ³
//³uma condicional.                                                  ³
//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
//³erro na base de clientes ja implantada.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem := AllTrim(SuperGetMV("MV_LJFISMS"))
If Empty(cMensagem)
	cMensagem := Rtrim(SLG->LG_MSGCUP)
EndIf 
cMensagem := If( Substr(cMensagem,1,1)=="&", &(Substr(cMensagem,2,Len(cMensagem))), cMensagem )
aMensagem:=FrtMsgTela(cMensagem)
oCupom:Add("")
oCupom:Add("")
For nI := 1 to Len(aMensagem)
    oCupom:Add(aMensagem[nI])
Next nI    
oCupom:Add("")
oCupom:Add(DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+cDoc)	// "  PDV:" "   COD:"
oCupom:Add("")
oCupom:Add("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
oCupom:GoBottom()
cCupom := oCupom:aItems[Len(oCupom:aItems)-2]

nX := 0
cFormaPagto := ""
For nI := 1 To Len(aFormPag)
	If aTotForm[nI] > 0
		If cTipTef == TEF_CLISITEF
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF)  .OR. !lTefOk .OR. !lUsaTef
				cFormaPagto += aFormPag[nI, 3] + "|" + AllTrim(Str(aTotForm[nI],14,2)) + '|'
            Else
				++nX
				If nLjpagto==1
					cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
				Else
					cFormaPagto += oTef:aRetCartao[nX]:cDescadm + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
				EndIf
			EndIf
		Else
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
				cFormaPagto += aFormPag[nI, 3] + "|" + AllTrim(Str(aTotForm[nI],14,2)) + '|'
		    Else
				++nX
				If nLjpagto==1
					cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
				Else
					If lTefMult
						cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
					Else
						cFormaPagto += aTefDados[nI, 8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

nRet := IFStatus(nHdlECF, "9", @cRet)		// Verifico o Status do ECF

If nRet <> 0
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

If !lRecebe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Cliente escolhido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+cCliente+cLojaCli)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Vendedor escolhido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+cVendLoja)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Encerramento do Cupom - Finaliza o SL1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSL1 := {{"L1_VEND"		,	SA3->A3_COD		}, ;
			 {"L1_COMIS"	,	SA3->A3_COMIS	}, ;
			 {"L1_VEND2"	,	SA3->A3_GEREN	}, ;
			 {"L1_VEND3"	,	SA3->A3_SUPER	}, ;
			 {"L1_CLIENTE"	,	SA1->A1_COD		}, ;
			 {"L1_TIPOCLI"	, 	SA1->A1_TIPO	}, ;
			 {"L1_LOJA"		,	SA1->A1_LOJA	}, ;
			 {"L1_TIPO"		,	"V"				}, ;
			 {"L1_HORA"		,	cHora			}, ;
			 {"L1_VLRTOT"	,	nVlrBruto		}, ;
			 {"L1_DESCONT"	,	nVlrDescTot		}, ;
			 {"L1_VLRLIQ"	,	nVlrTotal		}, ;
			 {"L1_VALBRUT"	,	nVlrTotal		}, ;
			 {"L1_VALMERC"	,	nVlrBruto		}, ;
			 {"L1_DESCNF"	,	nVlrPercTot		}, ;
			 {"L1_DINHEIR"	,	nDinheiro		}, ;
			 {"L1_CHEQUES"	,	nCheques		}, ;
			 {"L1_CARTAO"	,	nCartao			}, ;
			 {"L1_CONVENI"	,	nConvenio		}, ;
			 {"L1_VALES"	,	nVales			}, ;
			 {"L1_FINANC"	,	nFinanciado		}, ;
			 {"L1_VLRDEBI"	,	nValorDebi		}, ;
			 {"L1_OUTROS"	,	nOutros			}, ;
			 {"L1_ENTRADA"	,	nEntrada		}, ;
			 {"L1_JUROS"	,	nTmpJuros		}, ;
			 {"L1_PARCELA"	,	nParcelas		}, ;
			 {"L1_TXDESC"	,	0				}, ;
			 {"L1_CONDPG"	,	cItemCond		}, ;
			 {"L1_INTERV"	,	If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),If(Len(aFormCtrl)>1,aFormCtrl[2][6],0),0)},;
	         {"L1_CREDITO"	, 0					}, ;
	         {"L1_CONFVEN"	,	"SSSSSSSSNSSS"	}, ;
			 {"L1_IMPRIME"	,	"1S"			}, ;
			 {"L1_SITUA"	,	"09"}}						// "09" - Encerrado SL1 (Nao gerado SL4)    
    		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetuando gravação dos dados do TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefOk

		Aadd(aSL1,{"L1_VENDTEF","S"})

		If cTipTef == TEF_CLISITEF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a alteracao das datas e conf. de ADM informadas durante o processamento do TEF		           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjTEFAceParc( @aParcelas )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gerando os dados do TEF para a tabela SL1													   		   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSL1 := LjTEFGeraSL(aSL1,"SL1")

		Else
			Aadd(aSL1,{"L1_FORMPG"	, FrtAtuFORMPG(cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
												   aPgtos) })
			Aadd(aSL1,{"L1_DATATEF"	, aTefDados[1][2]})
			Aadd(aSL1,{"L1_HORATEF"	, aTefDados[1][3]})
			Aadd(aSL1,{"L1_DOCTEF"	, aTefDados[1][4]})
			Aadd(aSL1,{"L1_AUTORIZ"	, aTefDados[1][5]})
			Aadd(aSL1,{"L1_INSTITU"	, aTefDados[1][8]})
			Aadd(aSL1,{"L1_DOCCANC"	, aTefDados[1][6]})
			Aadd(aSL1,{"L1_HORCANC"	, aTefDados[1][7]})
			Aadd(aSL1,{"L1_NSUTEF"	, aTefDados[1][9]})
			Aadd(aSL1,{"L1_TIPCART"	, aTefDados[1][10]})
			If SL1->(FieldPos("L1_PARCTEF"))>0
				//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
				Aadd(aSL1,{"L1_PARCTEF"	, aTefDados[1][16]+aTefDados[1][17]})
			EndIf
		EndIf
	EndIf
			 
	If CrdXInt() 
	   If SL1->(FieldPos("L1_FORCADA")) > 0
		  // Controlar se a venda foi off-line (1) ou uma venda on-line (2) - WebService
		  If lForcada
			 aAdd( aSL1, {"L1_FORCADA", "1" } )
			 If SL1->(FieldPos("L1_CGCCART")) > 0 
				// Grava no campo L1_CGCCART o Numero do CGC/CPF ou Numero do Cartao do Cliente, o que tiver sido 
				// informado.  
				AADD( aSL1, {"L1_CGCCART", If(!Empty(aDadosCrd[1]), aDadosCrd[1], aDadosCrd[2]) } )
			 Else
				MsgStop("Falta criar o campo L1_CGCCART (Caracter, Tamanho de 16). Informe ao administrador do sistema.")				
			 Endif
		  Else
			 aAdd( aSL1, {"L1_FORCADA", "2" } )
		  Endif
	   Else
          MsgStop("Falta criar o campo L1_FORCADA (Caracter, Tamanho de 1). Informe ao administrador do sistema.")					   	  
	   Endif	  
	   If SL1->(FieldPos("L1_CONTRA")) > 0 
		  aAdd( aSL1, {"L1_CONTRA", cContrato } )
	   Else		
	      MsgStop("Falta criar o campo L1_CONTRA (Caracter, Tamanho de 10). Informe ao administrador do sistema.")
	   Endif		  
	Endif
				 
	If cPaisLoc <> "BRA"           
		//Realiza a gravacao do troco em sua respectiva moeda...
		For nI := 1 TO Len(aTroco)
			If (aScan(aTroco,{|x| x[4]==nI}) > 0)
				nPos := AScan(aTroco,{|x| x[4]==nI})
		     	Aadd(aSL1,{"L1_TROCO"+Alltrim(STR(nI)),aTroco[nPos][2]}) //Valor do Troco
			EndIf
		Next nI
		
		For nI := 1 to Len(aImpsSL1)
	    	Aadd(aSL1,{aImpsSL1[nI][2],aImpsSL1[nI][3]})   //Valor do imposto
	    	Aadd(aSL1,{aImpsSL1[nI][4],aImpsSL1[nI][5]})   //Base do imposto               
	
			//Acerta o valor liquido abatendo o valor dos impostos...
	      	If aImpsSL1[nI][06] == "1"
				aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})][2] -= aImpsSL1[nI][3]
		  	EndIf                                                
	  	Next nI   
	
		//Acerta o valor da mercadoria com base no valor liquido da venda...
		aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALMERC"})][2] := aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})][2]
	    
		//Caso tenha juros ou desconto financeiro eh necessario somar ao 
		//valor total e ao valor bruto da venda os impostos...
	  	If (nTmpJuros > 0) .OR. (nTmpDesc > 0)
	    	aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRTOT"})][2] := nVlrTotal
	   	  	aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALBRUT"})][2]:= nVlrTotal
	  	EndIf           
	Else 
        //Para o caso do Brasil, existe apenas a gravacao do Troco em 1 moeda
		If SL1->(FieldPos("L1_TROCO1")) > 0 .AND. nTroco2 > 0
			AAdd( aSL1, {"L1_TROCO1", nTroco2 } )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se existir o campo do PIS, tem tratamento para os impostos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->( FieldPos( "L1_VALPIS" ) ) > 0 
			AAdd( aSL1, {"L1_VALPIS" , nValTPis } )
			AAdd( aSL1, {"L1_VALCOFI", nValTCof } )
			AAdd( aSL1, {"L1_VALCSLL", nValTCsl } )
		Endif
	EndIf
	
	//No caso de localizacoes os tratamentos referentes a acrescimo ou 
	//desconto ja foram realizados anteriormente, no recalculo dos 
	//impostos variaveis...
	If cPaisLoc == "BRA"
		// Caso houve acrescimo pela condicao de pagamento
		nAcres := (nVlrTotal + nVlrDescTot - nVlrBruto) / nVlrBruto
		If nAcres > 0
			nDiffIT := 0
			SL2->(DbSetOrder(1))
			For nI := 1 To Len(aItens)
				If !aItens[nI][AIT_CANCELADO]
					If nI == Len(aItens)
						nAcresIT := nVlrTotal + nVlrDescTot - nDiffIT
					Else
						nAcresIT := NoRound(aItens[nI][AIT_VLRITEM] * (1 + nAcres), nDecimais)
					EndIf
					aItens[nI][AIT_VLRITEM] := nAcresIT
					nDiffIT += nAcresIT
					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FRTPegaIT(aItens[nI][AIT_ITEM])))
					aSL2 := {{"L2_VRUNIT",	aItens[nI][AIT_VLRITEM]/aItens[nI][AIT_QUANT]},;
							 {"L2_VLRITEM",	aItens[nI][AIT_VLRITEM]}}
					FRTGeraSL("SL2", aSL2, .F.)
				EndIf
			Next nI
		EndIf
		
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se Houver Desconto no Total, o Mesmo Devera Ser Aplicado nos Itens, ³
		//³ Mantendo a Compatibilidade com a Venda Balcao.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		If nVlrDescTot+nVlrDescCPg > 0
			nDiffIT := 0
			SL2->(DbSetOrder(1))
			For nI := 1 To Len(aItens)
				If !aItens[nI][AIT_CANCELADO]
					If aItens[nI][AIT_VALIPI] > 0
						nPercIPI := aItens[nI][AIT_VALIPI] / aItens[nI][AIT_VLRITEM]
					Else
						nPercIPI := 0
					EndIf
					If nAcres>0
						nDescIT  := NoRound(nVlrDescTot * (aItens[nI][AIT_VLRITEM] / nVlrTotal+nVlrDescTot), nDecimais)
					Else
						nDescIT  := NoRound(nVlrDescTot * (aItens[nI][AIT_VLRITEM] / nVlrBruto), nDecimais)
					EndIf
					nVlrIT   := aItens[nI][AIT_VLRITEM] - nDescIT
					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FRTPegaIT(aItens[nI][AIT_ITEM])))
					aSL2 := {{"L2_VRUNIT",	nVlrIT/aItens[nI][AIT_QUANT]},;
							 {"L2_VLRITEM",	nVlrIT},;
							 {"L2_DESCPRO", nDescIT},;
							 {"L2_VALIPI",	NoRound(nVlrIT * nPercIPI, 2)}}
					FRTGeraSL("SL2", aSL2, .F.)
					nDiffIT  += SL2->L2_DESCPRO
				EndIf
			Next nI
		
			nDiffIT := nVlrDescTot+nVlrDescCPg - nDiffIT
			SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
			While ! nDiffIT == 0 .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. ! EOF()
				Reclock( "SL2" ,.F.)
				If NoRound((SL2->L2_VLRITEM - nDiffIT) / SL2->L2_QUANT, 2) < 1/10**nDecimais
					// Se o valor do item e' pequeno faz o ajuste deixando 1 centavo no VrUnit
					SL2->L2_VRUNIT := 1/10**nDecimais
					// Subtrai da variavel somente a diferenca que sera ajustada aqui.
					nDiffIT -= (SL2->L2_VLRITEM - (L2_VRUNIT * L2_QUANT))
					// Adiciona ao desconto proporcional a diferenca que foi utilizada aqui.
					If nVlrDescTot <> 0
						SL2->L2_DESCPRO += (SL2->L2_VLRITEM - (SL2->L2_VRUNIT * SL2->L2_QUANT))
					EndIf
					// Recalcula o valor total do item de acordo com o VrUnit*Qtd
					SL2->L2_VLRITEM := (SL2->L2_VRUNIT * SL2->L2_QUANT)
				Else
					// Se o valor do item permite entao faz o ajuste total
					// Soma a diferenca no desconto desse item porque o ajuste sera feito aqui
					If nVlrDescTot <> 0
						SL2->L2_DESCPRO += nDiffIT
					EndIf
					// Se aumentou o desconto entao diminui o valor do item na mesma proporcao
					SL2->L2_VLRITEM -= nDiffIT
					// Recalcula o valor unitario do item de acordo com o VrTotItem/Qtd
					SL2->L2_VRUNIT  := NoRound(SL2->L2_VLRITEM / SL2->L2_QUANT, 4)
					// Como toda a diferenca foi utilizada entao zera a variavel para sair do laco (while).
					nDiffIT := 0
				EndIf
				MsUnlock()
				dbSkip()
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajuste da gravacao dos dados do SL1 para a venda                                       ³
		//³                                                                                        ³
		//³ Exemplo de gravavao dos campos                                                         ³
		//³ Venda de 1 item de R$100,00 com:                                                       ³
		//³                          L1_VLRTOT   L1_DESCONT   L1_VLRLIQ   L1_VALBRUT   L1_VALMERC  ³
		//³ Acresc.financ de 10%        100.00         0.00      110.00      110.00       100.00   ³
		//³ Descon.financ de 10%        100.00        10.00       90.00       90.00       100.00   ³
		//³ Descon.total  de 10%         90.00        10.00       90.00       90.00       100.00   ³
		//³ Descon.item   de 10%         90.00         0.00       90.00       90.00       100.00   ³
		//³	                                                                                       ³
		//³ Obs.1: A gravacao dos campos tem como base a gravacao da Venda Balcao para mantermos   ³
		//³ o legado das customizacoes.                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Calculo do Acrescimo
		nValAcres := nVlrTotal + nVlrDescTot - nVlrBruto
        If nValAcres < 0
        	nValAcres := 0
        EndIf

		For nI := 1 to Len(aItens)
			//Posiciona no Item da Venda
			SL2->(DbSetOrder(1))
			SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM + FRTPegaIT(aItens[nI][AIT_ITEM])))

			//Acumula o Valor Total da Mercadoria, para ajuste no SL1
			nValMerc   += A410Arred( (SL2->L2_PRCTAB * SL2->L2_QUANT),"D2_TOTAL")
			nDescTot   += SL2->L2_DESCPRO
			nDescItens += SL2->L2_VALDESC
		Next nI

		If nAcres > 0
			nPosCpo := Ascan(aSL1, { |x| AllTrim(x[1]) == "L1_JUROS" })
			If nPosCpo > 0
				aSL1[nPosCpo][2] := nAcres * 100
			EndIf
		EndIf
		
		nPosCpo	:= Ascan(aSL1, { |x| AllTrim(x[1]) == "L1_VALMERC" })
		If nPosCpo > 0
			aSL1[nPosCpo][2] := nValMerc
		EndIf

		nPosCpo	:= Ascan(aSL1, { |x| AllTrim(x[1]) == "L1_VLRTOT" })
		If nPosCpo > 0
			aSL1[nPosCpo][2] := nValMerc - nDescItens - nDescTot
		EndIf

		nPosCpo	:= Ascan(aSL1, { |x| AllTrim(x[1]) == "L1_VALBRUT" })
		If nPosCpo > 0
			aSL1[nPosCpo][2] := nValMerc + nValAcres - nVlrDescCPg - nDescTot - nDescItens
		EndIf

		nPosCpo	:= Ascan(aSL1, { |x| AllTrim(x[1]) == "L1_VLRLIQ" })
		If nPosCpo > 0
			aSL1[nPosCpo][2] := nValMerc + nValAcres - nVlrDescCPg - nDescTot - nDescItens
		EndIf
	EndIf
			 
	FRTGeraSL("SL1", aSL1, .F.)
	
	For nI := 1 To Len(aParcelas)
		aSL4 := {	{ "L4_FILIAL"	,	xFilial("SL4")		}, ;
				 	{ "L4_NUM"     	,	SL1->L1_NUM			}, ;
				 	{ "L4_DATA"		,	aParcelas[nI][ 1]	}, ;
				 	{ "L4_VALOR"	,	aParcelas[nI][ 2]	}, ;
				 	{ "L4_FORMA"	,	aParcelas[nI][ 3]	}, ;
				 	{ "L4_ADMINIS"	,	aParcelas[nI][ 4]	}, ;
				 	{ "L4_NUMCART"	,	aParcelas[nI][ 5]	}, ;
					{ "L4_AGENCIA"	,	aParcelas[nI][ 6]	}, ;
				 	{ "L4_CONTA"	,	aParcelas[nI][ 7]	}, ;
				 	{ "L4_RG"		,	aParcelas[nI][ 8]	}, ;
				 	{ "L4_TELEFON"	,	aParcelas[nI][ 9]	}, ;
				 	{ "L4_TERCEIR"	,	aParcelas[nI][10]	}, ;
				 	{ "L4_OBS"		,	""}	}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se estivermos utilizando múltiplas transações Tef, deveremos gravar³
		//³todos os retornos.                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaTef .AND. ( lTefOk .OR. Len( aTefBKPCS ) > 0 ) .AND. aParcelas[nI][3] $ _FORMATEF

			If cTipTEF == TEF_CLISITEF

				If Empty(cAdminis)
					cAdminis := aParcelas[nI][4]
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gerando os dados do TEF para a tabela SL4													   		   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSL4 := LjTEFGeraSL( 	aSL4				,"SL4"				, aParcelas[nI][1], aParcelas[nI][3], ;
										aParcelas[nI][12]	,aParcelas[nI][4]	, aParcelas[nI][6], aParcelas[nI][5], ;
										aParcelas[nI][4]	,nI 				, @cAdminis )

			Else
				If lTefMult
					If (nPos := AScan(aTefMult,{|x| AScan(x[10],StrZero(nI,2))>0 })) <> 0
						If Len(aTefMult[nPos][7]) > 0
							aTefDados := aClone(aTefMult[nPos][7])
							aAdd( aSL4, { "L4_VENDTEF","S"})
							aAdd( aSL4, { "L4_DATATEF",aTefDados[1][2]})
							aAdd( aSL4, { "L4_HORATEF",aTefDados[1][3]})
							aAdd( aSL4, { "L4_DOCTEF" ,aTefDados[1][4]})
							aAdd( aSL4, { "L4_AUTORIZ",aTefDados[1][5]})
							aAdd( aSL4, { "L4_INSTITU",aTefDados[1][8]})
							aAdd( aSL4, { "L4_DOCCANC",aTefDados[1][6]})
							aAdd( aSL4, { "L4_DATCANC",aTefDados[1][12]})
							aAdd( aSL4, { "L4_HORCANC",aTefDados[1][7]})
							aAdd( aSL4, { "L4_NSUTEF" ,aTefDados[1][9]})
							aAdd( aSL4, { "L4_TIPCART",aTefDados[1][10]})
							If Empty(aTefDados[1][15])
								aAdd( aSL4, { "L4_FORMPG",If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),If(Len(aFormCtrl)>1,aFormCtrl[2][1],aFormCtrl[1][1]),aPgtos[1][3]) })
							Else
								aAdd( aSL4, { "L4_FORMPG",aTefDados[1][15]})
							EndIf
						EndIf
					EndIf
					If cTipTef <> TEF_CLISITEF .AND. !lMVTELAFIN
						cAdminis := LJ7ConfAdm( aParcelas[nI][ 4], aTefDados[1][8], @lSemRede)
						If !Empty(cAdminis)
							aSL4[6][2] := cAdminis
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibir o valor do acrescimo separado da parcela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lVerEmpres
	    	If SL4->(FieldPos("L4_ACRSFIN")) > 0
				aAdd( aSL4, { "L4_ACRSFIN",aParcelas[nI][13]})
			Endif
		Endif
		
		If cPaisLoc <> "BRA"
		   Aadd(aSL4,{"L4_MOEDA",aParcelas[nI][11]})
		EndIf
		If ExistBlock("FRTGRSL4")
			aSL4 := ExecBlock("FRTGRSL4",.F.,.F.,{aSL4,nI})
		EndIf
		FRTGeraSL("SL4", aSL4, .T.)
	Next nI
	aSL1 := {{"L1_SITUA",	"10"}}						// "10" - Encerrado a Venda
	FRTGeraSL("SL1", aSL1, .F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjAnalisaLeg(4)[1]
		If lGaveta
			If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
				GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
			Else
				IFGaveta(nHdlECF)
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha desconto ou desconto financeiro no total do cupom             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotDescont := nVlrDescCPg + nVlrDescTot + nTotDedIcms
	If nTotDescont > 0
		lImpDesc := .T.
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe acrescimo financeiro. Caso exista subtrai do desconto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If nVlrAcreTot > 0
            	If nVlrAcreTot > nTotDescont
            		nVlrAcreTot -= nTotDescont
            		lImpDesc := .F.
            		nRet	 := 0
            	Else
            		nTotDescont -= nVlrAcreTot	
            	EndIf
            EndIf
                                                      
            If lImpDesc
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alteracao especifica para atender a legislacao do SEFAZ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LjAnalisaLeg(14)[1]
					If nVlrDescCPg > 0 .AND. cItemCond<>"CN" .OR. (cItemCond=="CN" .AND. lCondNegF5)
						nRet := IFDescTot(nHdlECF, AllTrim(Str(nVlrDescCPg,14,2)))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para orcamentos importados com descontos e que nao foram alterados e nem³
					//³impressos , pois o usuario nao efetuou o desconto pela tecla (F6)     			  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  	ElseIf lImpOrc .AND. ( nVlrDescTot > 0 ) .AND. !lDescTotal
						nRet := IFDescTot(nHdlECF, AllTrim(Str(nVlrDescTot,14,2)))	
					EndIf
				Else
					nRet := IFDescTot(nHdlECF, AllTrim(Str(nTotDescont,14,2)))
				EndIf
			EndIf
		Else
			nRet := IFDescTot(nHdlECF, AllTrim(Str(aDadosJur[9],TAMSX3("L1_VLRTOT")[1],TAMSX3("L1_VLRTOT")[2])))		
		EndIf
		If nRet <> 0
			// "Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada.", "Atenção"
			HELP(' ',1,'FRT033')
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha acrescimo no total do cupom                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Somente condicoes de pagamento do SE4 ou Orcamentos Importados da Retaguarda tem acrescimo
	If nVlrAcreTot > 0 .AND. (cItemCond<>"CN" .OR. (cItemCond=="CN" .AND. lCondNegF5) .OR. lImpOrc)
		If cPaisLoc == "BRA"
			If !lImpDesc
				nRet := IFAcresTot( nHdlECF, Str(nVlrAcreTot,14,2) )
			Else
				nRet := 0
			EndIf
		Else
			nRet := IFAcresTot( nHdlECF, Str(aDadosJur[1],TAMSX3("L1_VLRTOT")[1],TAMSX3("L1_VLRTOT")[2]) )
		EndIf
		If nRet <> 0
			// "Não foi possível registrar o Acréscimo no Total do Cupom. Operação não efetuada."
			HELP(' ',1,'FRT040')
		EndIf
	EndIf
	
	lEncerra := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ. Exclusivo para o ³
	//³ estado do Amazonas                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1] .AND. cItemCond=="CN" .AND. !lCondNegF5 
		nRet := 0
	Else
		// Indica que sera emitido um cupom vinculado ao cupom fiscal emitido.
		// Especifico para impressora Urano versao 3.00
		If lUsaTef .AND. lTefOk .AND. (nCartao + nValorDebi + nCheques) > 0 .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF // Sem Client / Com Client / Discado
			cVinculado := "1"
		EndIf
		nRet := IFPagto(nHdlECF, cFormaPagto, cVinculado, nVlrTotal)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a troca automatica da serie do checkout de acordo com a tabela SL6.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjAltSerie( cEstacao, cDoc )

	If lUsaTef .AND. cTipTef == TEF_CLISITEF .AND. lCartao
		If oTef:CupomReduz()
			If !Empty(oTef:cCupomRedu)
				cMensagem := oTef:cCupomRedu + CHR(10) +  cMensagem
			EndIf
		EndIf
	EndIf
	If nRet == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
		//³possibilita ao usuario montar um parametro o qual seja executada  ³
		//³uma condicional.                                                  ³
		//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
		//³erro na base de clientes ja implantada.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := IFFechaCup(nHdlECF, cMensagem )
		If nRet == 0
			lEncerra := .T.
			lFechaCup := .T.		
			If lUsaDisplay                   
				DisplayEnv(StatDisplay(), "1C"  + STR0272 )         //"Venda Finalizada."
				DisplayEnv(StatDisplay(), "2C"  + " " )        	
			EndIf  
		Else
			// "Não foi possível realizar o fechamento do cupom fiscal. Operação não efetuada." ### "Atenção"
			HELP(' ',1,'FRT041')
			lFechaCup := .F.
			lCancCup  := .T.
		EndIf
	Else
		// "Não foi possível registrar as formas de pagamento. Operação não efetuada."
		HELP(' ',1,'FRT042')
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do ECF                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := (nRet == 0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a confirmacao ou desfazimento da transacao TEF                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF
		If lTefOk .OR. Len( aTefBKPCS ) > 0													// Transação preparada para ser finalizada 
			If cTipTef == TEF_CLISITEF														// Se é CLISITEF
				If lRet 																	// Fechamento do cupom Fiscal efetuado com sucesso
					oTEF:ImpCupTef(nVlrTotal)														// Imprime Cupom TEF
					lErrCupTEF 	:= !oTef:lImprimiu											// Se houve erro ao imprimir o Cupom TEF
					lTefOk 		:= oTEF:lTefOk												// Se a transação TEF está OK
					If lErrCupTEF															// Se houve erro na impressão do Comprovante TEF, tenta cancelar o Cupom Fiscal
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)							// Pega o número do COO da impressora
						IF nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	// Se conseguiu pegar o número do COO e ele não foi incrementado
							lRetTef := FrtCancCup(.T.)										// Tenta cancelar o Cupom Fiscal
							If !lRetTef														// Consegui cancelar o Cupom Fiscal
								Help(' ',1,'FRT046') 										// "Transação TEF cancelada devido à falha ao imprimir o comprovante TEF. O cupom fiscal será cancelado, pois o número seqüencial do Emissor do Cupom Fiscal não foi incrementado."
							EndIf
						Else
							lRetTef := .T. 													// Será necessário reter o Cupom, pois o COO não é o mesmo da Venda.
						EndIf
					Else
						lTemTEFPend := .F.
						aTefBKP     := {}																			// Zera as variaveis de consulta dados cadastrais
					EndIf
				Else 																		// Ocorreu um erro no registro do pagamento do ECF, ou na finalização da Venda
					oTEF:FinalTrn(0) 				//Finaliza a TRN com parametro confirma = 1
					IF lCancCup																// Deverá ser cancelado o Cupom Fiscal pois ocorreu um erro no comando do Fechamento do Cupom Fiscal
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)							// Pego o número do cupom atual
						IF nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	// Se conseguiu pegar o número do COO e ele não foi incrementado
							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso. 
							FrtCancCup(.T.)             									// O cupom será cancelado."
						EndIf
					Else 																	// Ocorreu um erro ao registrar o pagamento no ECF. Não é preciso cancelar o Cupom, apenas deve-se retornar a Venda
						Help(' ',1,'FRT047')												// "Transação TEF cancelada devido a impossibilidade de registrar a forma de pagamento no ECF."
																							// "Por favor, realize novamente a operação TEF, ou escolha uma nova forma de pagamento."
					Endif	
				EndIf
			Else 																			// TEF diferente de CLISITEF
				If lRet 																	// Fechamento do cupom Fiscal efetuado com sucesso
					lTefOk := LOJA010T( "I"  ,"V"  ,NIL         ,NIL  ,;
										NIL	,NIL	,lTemTEFPend	,NIL	)				// Efetua transação TEF
					If !lTefOk
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)
						IF nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	// Se conseguiu pegar o número do COO e ele não foi incrementado
							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso. O cupom será cancelado."
						lErrCupTEF := .T.			// Indica que houve erro na Transacao TEF
							lRetTef		:= FrtCancCup(.T.)									// Tenta cancelar o Cupom Fiscal
							If lRetTef														// Não consegui cancelar o Cupom Fiscal
								Help(' ',1,'FRT034')										// "Erro com a Impressora Fiscal. Operação não efetuada.", "É necessário efetuar Nota de Devolução."
								lErrCupTEF := .T.											// Seta que há erro na impressão do Cupom TEF
							EndIf
						Else
							lRetTef := .T.													// Será necessário reter o Cupom, pois o COO não é o mesmo da Venda.
							lErrCupTEF := .T.												// Seta que há erro na impressão do Cupom TEF
						EndIf
					EndIf
				Else 																		// Ocorreu um erro ou registro do pagamento do ECF, ou na finalização da Venda
					lTefOk := LOJA010T( "F"    ,"N"   ,NIL   ,NIL   ,;
										NIL	,NIL	,NIL	,NIL	)						// Efetua transação TEF
					IF lCancCup 															// Deverá ser cancelado o Cupom Fiscal pois ocorreu um erro no comando do Fechamento do Cupom Fiscal
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)							// Pego o número do cupom atual
						IF nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	// Se conseguiu pegar o número do COO e ele não foi incrementado
							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso. O cupom será cancelado."
							FrtCancCup(.T.)													// Tenta cancelar o Cupom Fiscal
						Endif
					Else 																	// Ocorreu um erro ao registrar o pagamento no ECF. Não é preciso cancelar o Cupom, apenas deve-se retornar a Venda
						Help(' ',1,'FRT048')												// "Transação TEF cancelada devido à falha ao registrar a forma de pagamento no ECF."
																							// "Por favor, realize novamente a operação TEF, ou escolha uma nova forma de pagamento."
					Endif
				EndIf
			EndIf
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Se houver alguma transacao TEF pendente, deve cancelar no SiTef³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    ElseIf lVerTEFPend .AND. lTefMult .AND. cMV_TEFPEND $ "1|2"
	    	aTefMult  := AClone(aBckTEFMult)
	    	If LEN(aTefMult) > 0
		    	//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
				If TEF_lEnvDF()
			    	If LOJA010T( "F"   ,"D"   ,NIL   ,NIL   ,;
			        	          NIL   ,NIL   ,NIL   ,NIL   )
				    	MsgAlert(STR0274) 	//"Transação TEF cancelada!"
				 	EndIf
				 	//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
		      	ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. lTefMult
					If LOJA010T( "F"   ,"N"   ,NIL   ,NIL   ,;	//Antigamente esta função nao retornava verdadeiro ou falso
				    		      NIL   ,NIL   ,NIL   ,NIL   )
				    	MsgAlert(STR0274) 	//"Transação TEF cancelada!"
		         	EndIf
		      	EndIf	
	      	EndIf
	      	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
			// Como não houve uma impressão do Comprovante TEF, pode ser cancelado normalmente           ³									 ³  
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCancCup
				Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
				FrtCancCup(.T.)
			Endif 
	    Else // Usuário esta habilitado para usar o TEF, mas a Venda envolve outra modalidade de pagamento
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Ponte de Entrada de Templates para a rotina do PBM Vidalink.                           ³
	    //³Imprime comprov. venda Vidalink. Comando oTEF:ImpCupTef().Se nao existir pagto c/TEF   ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		If lDroVLImpt
				aRet := ExecTemplate("DroVLImp",.F.,.F.,{nVidaLink})
				nVidaLink := aRet[1]
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
		//³Como não houve uma impressão do Comprovante TEF, pode ser cancelado normalmente           ³									 ³  
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCancCup
				Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
				FrtCancCup(.T.)
			Endif 
	   EndIf
	Else // Usuário não é TEF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
		//³ para caixas que não utilizam TEF                     									 ³  
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCancCup
			Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
			FrtCancCup(.T.)
		Endif
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a confirmacao ou desfazimento da transacao de credito (SIGACRD)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CrdXInt() 
	   If !Empty(cContrato)
          If lTransCrd
			 aTmpCliCrd := {}
			 aAdd( aTmpCliCrd, aCrdCliente[2] )     // Numero do cartao
			 aAdd( aTmpCliCrd, aCrdCliente[1] )		// CPF
			 aAdd( aTmpCliCrd, nVlrTotal )			// Valor da venda			
			 aAdd( aTmpCliCrd, (nVlrAcreTot * 100 / (nVlrTotal-nVlrAcreTot)) )	// Juros da venda
			 aAdd( aTmpCliCrd, Len(aParcCrd) )		// Numero de parcelas
			 aAdd( aTmpCliCrd, 1 )					// Venda forcada
			 aAdd( aTmpCliCrd, "" )					// Responsavel pela venda forcada
			 aAdd( aTmpCliCrd, aClone(aParcCrd) )		// Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
			 aAdd( aTmpCliCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  )		// Loja da venda
			 aAdd( aTmpCliCrd, SL1->L1_PDV )			// PDV
			 aAdd( aTmpCliCrd, xNumCaixa() )			// Caixa
			 aAdd( aTmpCliCrd, cOrcam )              // Num. do orcamento
			 aAdd( aTmpCliCrd, aClone(aProdCrd))     // Produtos selecionados numa venda
			 aAdd( aTmpCliCrd, aClone(aPgtos)  )     // Parcelas de uma venda
	         aAdd( aTmpCliCrd, FWGETCODFILIAL  )     // Filial do Caixa que esta sendo utilizado
	         aAdd( aTmpCliCrd, SL1->L1_CLIENTE )     // Cliente
	         aAdd( aTmpCliCrd, SL1->L1_LOJA    )     // Loja			
			
			 If !( lRet ) .OR. ((lUsaTef .AND. lCartao .AND. !lTefOk) .AND. aScan(aPgtos,{|x| Alltrim(x[3])$"CD,CC" })>0 )
			    // Faz o desfazimento da transacao de credito
			    aRetCrd := CrdxVenda( "3"   ,aTmpCliCrd   ,cContrato   ,.T.   ,;
			                           NIL  ,NIL )		
			 Else
			    // Confirma a transacao de credito
			    aRetCrd := CrdxVenda( "2" 	 ,aTmpCliCrd   	,cContrato  ,.T.   ,;
			                          Nil  	 ,Nil			,Nil		,aRecCrd)
			 EndIf
	      Else
             aDadosCrd := {}
		     aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
		     aAdd( aDadosCrd, aCrdCliente[1] )		// CPF	
			 // Faz o desfazimento da transacao de credito		     
		     aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,cContrato   ,.T.   ,;
		                            NIL  ,NIL )		
	      EndIf			
	   ElseIf lForcada
	      CrdCpvFin()   
	   EndIf   
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Se tiver algum contrato pendente gerado na venda atual, cancela   ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	      
	   If Len(aContratos) > 0
	      aDadosCrd := {}
		  aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
		  aAdd( aDadosCrd, aCrdCliente[1] )		    // CPF	
	      For nI := 1 to Len(aContratos)	   
	         If aContratos[nI] == cContrato        //Ignora se for o contrato da propria venda
	            Loop   
	         EndIf
		     aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,aContratos[nI]   ,.T.   ,;
		                            NIL   ,NIL )		
	      Next nI
	   EndIf   
	EndIf

	// (Encerrou o cupom)
	If lEncerra
		// (Erro no Cupom TEF)
		If lErrCupTEF
			// (Nao conseguiu cancelar o cupom fiscal)
			If lRetTef
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso ocorra erro na transacao TEF, continua a gravacao do cupom, ³
				//³ pois o mesmo nao pode ser cancelado no ECF.                      ³
				//³ Neste caso sera necessario realizar uma NOTA DE DEVOLUCAO.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSL1 := {{"L1_SITUA"	, "00"	}, ;						// "00" - Venda Efetuada Com Sucesso
						 {"L1_STATUS"	, "T"	}, ; 						// Indica que houve erro na Transacao TEF
			    	     {"L1_VENDTEF"	, "N"	}, ;
						 {"L1_FORMPG"	, FrtAtuFORMPG(cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
												       aPgtos) }, ;
			    	     {"L1_DATATEF"	, ""	}, ;
			    	     {"L1_HORATEF"	, ""	}, ;
				         {"L1_DOCTEF"	, ""	}, ;
				         {"L1_AUTORIZ"	, ""	}, ;
		    		     {"L1_INSTITU"	, ""	}, ;
			        	 {"L1_DOCCANC"	, ""	}, ;
				         {"L1_DATCANC"	, ""	}, ;
				         {"L1_HORCANC"	, ""	}, ;
		    		     {"L1_NSUTEF"	, ""	}, ;
	    	    		 {"L1_TIPCART"	, ""	} }
				FRTGeraSL("SL1", aSL1, .F.)
			EndIf
		Else
			// Ajusta a sequancia dos itens na SL2
		    DbSelectArea("SL2")
		    DbSetOrder(1)
		    If DbSeek(xFilial("SL2") + SL1->L1_NUM)
				cItemAjuste := "00"
		    	While !Eof() .AND. SL2->L2_FILIAL+SL2->L2_NUM == SL1->L1_FILIAL+SL1->L1_NUM
					cItemAjuste := Soma1(cItemAjuste)
					aSL2 := {{"L2_ITEM", cItemAjuste}}			
					FRTGeraSL("SL2", aSL2, .F.)	
					SL2->(DbSkip())	           
		   		End
		    Endif
			aSL1 := {{"L1_SITUA", "00"}}						// "00" - Venda Efetuada Com Sucesso
			FRTGeraSL("SL1", aSL1, .F.)
		EndIf

		// (Nao teve Erro no Cupom TEF) .OR. ((Erro no Cupom TEF) .AND. (nao conseguiu cancelar o cupom fiscal))
		If !lErrCupTEF .OR. (lErrCupTEF .AND. lRetTEF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a Impressao do Cheque. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(LjGetStation("IMPCHQ")) .AND. !Empty(LjGetStation("PORTCHQ"))
				FRTImpCH()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Template Function apos o fechamento do cupom fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	If lFRTEntregt
				ExecTemplate('FRTEntreg', .F., .F., { cNCartao, cCodDEP, cNomeDEP, aPgtos })
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizando os valores da variaveis³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			cCodDEP  := ""
			cNomeDEP := ""                                       

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada após o fechamento do cupom fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	If ExistBlock("FRTEntreg") 
				ExecBlock("FRTEntreg", .F., .F., { aCrdCliente, cCodDEP, cNomeDEP, aPgtos })
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alteracao especifica para atender a legislacao do SEFAZ ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LjAnalisaLeg(4)[1]
				If lGaveta
					If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
						GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
					Else
						IFGaveta(nHdlECF)
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informar a Retaguarda o Status Atual do Check-Out. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTGeraSLI(cEstacao, "CON", " |" + Alltrim(cPDV) + ;
						"|"    + AllTrim(cDoc) + "|" + 	AllTrim(Str(nVlrTotal,14,2))+;
						"|"    + AllTrim(Str(nTotItens)), "SOBREPOE" )

			aKey := Frt010Lock( aKey )			

			Frt010Refr() // Atualiza variáveis Staticas
	
			FRTInitIT(.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibir Mensagem de Finalizacao do Cupom no Display ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(8)
			If lUsaDispTor
				MsgDispTor( 8 )
			EndIf	
				
		EndIf
	ElseIf lCancCup // Cupom Fiscal Cancelado, venda deletada
	
		aKey := Frt010Lock( aKey ) // Libera variável lLocked			
			
		Frt010Refr() // Atualiza variáveis Staticas
			
		FRTInitIT(.T.) //Inicializa Objetos
	
	Else
		FRTRollB04()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.F.)
	EndIf
Else
	If !Empty(cRecCart) .OR. !Empty(cRecCPF) .OR. !Empty(cRecCont)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Puxa o cadastro do cliente do servidor                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegsSA1 := aClone( WSCrdConsCli( cRecCart, cRecCPF, cRecCont ) )
		
		For nX := 1 to Len( aRegsSA1 )
		
			aCliente := aClone( aRegsSA1[nX] )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Se Registro do SA1 no front nao existir ou conteudo de algum campo for diferente da retaguarda atualiza registro |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CrdSa1Alte( aCliente )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Checa se a chave primaria jah existe no check-out          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCli 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_COD" } )
				nPosLoja := aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_LOJA" } )
				If nPosCli <> 0 .AND. nPosLoja <> 0						
					cCliente 	:= aCliente[nPosCli][2]
					cLojaCli	:= aCliente[nPosLoja][2]
					lCliente 	:= .F.						// Não chama a tela padrão para selecionar o cliente
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz a gravacao do cadastro do cliente no check-out         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
					lNovoCliente := .T.
					DbSelectArea("SA1")
					DbSetOrder(1)	// Filial + Cod + Loja
					If DbSeek(xFilial("SA1")+cCliente+cLojaCli)
						lNovoCliente := .F.
					Endif
					FrtGeraSL( "SA1", aCliente, lNovoCliente )	// Grava o cadastro do cliente na estacao
					cCliente := SA1->A1_COD
					cLojaCli := SA1->A1_LOJA
				Endif
			Endif
		Next nX
	Endif
	
	// Atribuicao do valor ao array para a impressao do recebimento nao fiscal na rotina LJGRVREC
	// Esta variavel é declarada como private na rotina FRTRECEB
	aTitImp := aClone(aTitulo)

    lTEFPendRec  := lTemTEFPend
    If LEN(aTEFMult) > 0
       aRecTEFMult  := AClone(aTEFMult)
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define cliente com o padrao do parametro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
	cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
	nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
	cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

	aItens	 := {}
	aTEFPend := {}	
	lOcioso	 := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera o valor e o percentual de desconto do item       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAltVend   := .F.
	nVlrPercIT := 0
	nVlrDescIT := 0 
	nLastTotal := nVlrTotal
	nLastItem  := nTotItens
	nTotItens  := 0
	nVlrTotal  := 0
	nValIPI    := 0
	nVlrBruto  := 0
	nVlrMerc   := 0
	oDesconto:Refresh()
	oTotItens:Refresh()
	oVlrTotal:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reinicializa as variáveis de Templates                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	uCliTPL := Nil     
	uProdTPL:= Nil
	cCodConv:= "" 		
	cLojConv:= ""
    cNumCartConv := ""
	FRTInitIT(.T.)

    //Quando tem operacao TEF, verifica se foi realizada com sucesso
	If lUsaTef .AND. lCartao 
	   lConfLJRec := (lTefOk .OR. lTefManual)
	Else
	   lConfLJRec := .T.
	EndIf   
	lRecebe    := .F.
	lEncerra   := .T.

EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(), "2E"+ STR0254)
	DisplayEnv(StatDisplay(), "1E"+ " ")
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()
	FrtSetCrd()
Endif

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTRollB04³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Roll-Back para a Situacao 04                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTRollB04
FRTCancela(.F., .F., .T.)					// Deleta Somente o SL4
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Como nao conseguiu gerar o SL4, Volta a Situacao "04" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSL1 := {	{"L1_VEND"		, ""	}, ;
		 	{"L1_COMIS"		, 0		}, ;
		 	{"L1_VEND2"		, ""	}, ;
		 	{"L1_VEND3"		, ""	}, ;
		 	{"L1_CLIENTE"	, ""	}, ;
		 	{"L1_TIPOCLI"	, ""	}, ;
		 	{"L1_LOJA"		, ""	}, ;
		 	{"L1_TIPO"		, ""	}, ;
		 	{"L1_VLRTOT"	, 0		}, ;
		 	{"L1_DESCONT"	, 0 	}, ;
		 	{"L1_VLRLIQ"	, 0		}, ;
		 	{"L1_VALBRUT"	, 0		}, ;
		 	{"L1_VALMERC"	, 0		}, ;
		 	{"L1_DESCNF"	, 0		}, ;
		 	{"L1_DINHEIR"	, 0		}, ;
		 	{"L1_CHEQUES"	, 0		}, ;
		 	{"L1_CARTAO"	, 0		}, ;
		 	{"L1_CONVENI"	, 0		}, ;  
		 	{"L1_VALES"		, 0		}, ;
		 	{"L1_FINANC"	, 0		}, ;
		 	{"L1_VLRDEBI"	, 0		}, ;
		 	{"L1_OUTROS"	, 0		}, ;
		 	{"L1_ENTRADA"	, 0		}, ;
		 	{"L1_JUROS"		, 0		}, ;
		 	{"L1_PARCELA"	, 0		}, ;
		 	{"L1_TXDESC"	, 0		}, ;
		 	{"L1_CONDPG"	, ""	}, ;
		 	{"L1_FORMPG"	, ""	}, ;
		 	{"L1_CREDITO"	, 0		}, ;
		 	{"L1_SITUA"		, "04"	} }					// "04" - Impresso o Item
FRTGeraSL("SL1", aSL1, .F.)

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTImpCH  ³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Roll-Back para a Situacao 04                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FRTImpCH()
Local nI      := 0
Local lTemCH  :=.F.
Local cObs    := ""
Local cVerso  := ""

If ( Type("aParcelas") <> "U" .AND. Len(aParcelas) > 0)

	For nI := 1 To Len(aParcelas)
		If AllTrim(aParcelas[nI][3]) == cSimbCheq
			lTemCH := .T.
			Exit
		EndIf
	Next nI
		
	If lTemCH
		For nI := 1 To Len(aParcelas)
			If AllTrim(aParcelas[nI][3]) == cSimbCheq
				cBanco   := Substr(aParcelas[nI][4],1,3)
				cFavorec := SM0->M0_NOME
				cCidade  := Left(SM0->M0_CIDCOB,15)
				cCidade  := If(Empty(cCidade), "Sao Paulo", cCidade)
				nValor   := aParcelas[nI][2]
				IF SuperGetMV("MV_DATCHE") == "E"
					dEmissao := dDataBase
				Else
					dEmissao := aParcelas[nI][1]
				EndIf
				cCheque  := aParcelas[nI][5]
				cAgencia := aParcelas[nI][6]
				cConta   := aParcelas[nI][7]
				LjImpCheque(cBanco, cAgencia, cConta, cCheque, @nValor, @cFavorec, @cCidade, @dEmissao, @cObs, @cVerso, .F.)
			Endif
		Next nI
	EndIf
Endif
	
Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTTimer ³ Autor ³ Vendas Clientes       ³ Data ³25/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Evento de Timer para atualizar a Hora e verificar SLI.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTTimer
Local aKey
Local nHdlERR
Local nCancelar
Local nItem
Local cVlrItem
Local aCancelar
Local cLidos
Local nI // variavel do loop
FRTHora()

//Atualiza na tela o valor da venda nas diversas moedas do sistema...
If cPaisLoc <> "BRA"
	FRTExibTotVen()
EndIf           
IpcGo(WAITID)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando Estiver Conectado, Informar o Status Atual. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSLI(cEstacao, "CON", If(lOcioso," ","V")+"|"+;
							Alltrim(cPDV)+"|"+;
							AllTrim(cDoc)+"|"+;
							AllTrim(Str(If(lOcioso,nLastTotal,nVlrTotal),14,2))+"|"+;
							AllTrim(Str(If(lOcioso, nLastItem, nTotItens))), "SOBREPOE")

If SLI->(DbSeek(xFilial("SLI")+"    LCK")) .AND. Left(SLI->LI_MSG,3) == "END"
	lLocked := .T.
	If lOcioso
		oTimer:Deactivate()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aKey := FRTSetKey()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTLocked()
		lLocked := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		oTimer:Activate()
	EndIf
Else
	If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"MSG")) .AND. !Empty(SLI->LI_MSG)
		// "Mensagem do FRTMonitor"
		MsgInfo(AllTrim(SLI->LI_MSG), STR0133)
		FRTGeraSLI(cEstacao, "MSG", "", "SOBREPOE")
	EndIf
	If lOcioso
		If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM")) .AND. Left(SLI->LI_MSG,11)=="CLOSE FILES"
			oTimer:Deactivate()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aKey := FRTSetKey()
			LjMsgRun(STR0164,, {|| FRTAtua()})	// "Aguarde. Inciando processo de atualização de todas as tabelas no Check-Out..."
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			oTimer:Activate()
		ElseIf SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"PSS")) .AND. Left(SLI->LI_MSG,9)=="CLOSE SPF"
			oTimer:Deactivate()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aKey := FRTSetKey()
			LjMsgRun(STR0180,, {|| FRTAtuSPF()})	// "Aguarde. Atualizando senhas de usuário..."
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			oTimer:Activate()
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checar se a Thread Esta Conectada ao Server ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FRTSemaStat("CON", cEstacao)
		oOnOffLine:SetBMP("FRTONLINE")
	Else
		oOnOffLine:SetBMP("FRTOFFLINE")
	EndIf
EndIf
If File(GetClientDir()+"DREGIS.ERR")
	nHdlERR := -1
	aCancelar := {}
	While nHdlERR == -1
		nHdlERR := FOpen(GetClientDir()+"DREGIS.ERR", 0+16)	// Read + Exclusive
	End
	nCancelar := (FSeek(nHdlERR, 0, 2) / 11)
    FSeek(nHdlERR, 0)
	For nI := 1 To nCancelar
		cLidos := FReadStr(nHdlERR, 11)
		AAdd(aCancelar, {Left(cLidos,6), FRTPegaIT(Val(Substr(cLidos,7,3)))})
	Next nI
	FClose(nHdlERR)
	FErase(GetClientDir()+"DREGIS.ERR")

	For nI := 1 To nCancelar
		DbSelectArea("SL1")
		DbSetOrder(8)
		If DbSeek(xFilial("SL1")+cPDV+aCancelar[nI][1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelar o Item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL2")
			DbSetOrder(1)
			If DbSeek(xFilial("SL2")+SL1->L1_NUM+aCancelar[nI][2])
				RecLock("SL2", .F.)
				dbDelete()
				MsUnLock()

				// AIT_ITEM Esta no CodeBlock Abaixo...
				nItem := AScan(aItens, {|x| x[1] == Val(aCancelar[nI][2])})
				aItens[nItem][AIT_CANCELADO] := .T.								// Marca Como Cancelado
				nVlrTotal-= aItens[nItem][AIT_VLRITEM]
				nVlrBruto-= aItens[nItem][AIT_VLRITEM]
				oVlrTotal:Refresh()

				cVlrItem := Trans(aItens[nItem][AIT_VLRITEM], PesqPict("SL2","L2_VLRITEM",13,nMoedaCor))
				oCupom:Add( "ITEM "+StrZero(nItem,3)+" NAO REGISTRADO")	// "ITEM " " NAO REGISTRADO"
				oCupom:Add( Space(19)+aItens[nItem][AIT_ALIQUOTA]+"%"+cVlrItem )
				oCupom:GoBottom()

				nTotItens--
				oTotItens:Refresh()
			EndIf
		EndIf
	Next nI
EndIf
If cPaisLoc <> "BRA" .AND. SLI->(DbSeek(xFilial("SLI")+"    SM2")) .AND. Left(SLI->LI_MSG,8) == "ATUALIZA"
	lLocked := .T.
	If lOcioso
		oTimer:Deactivate()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aKey := FRTSetKey()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FrtSetMoeda()
        FRTGeraSLI("    ", "SM2", "", "SOBREPOE")		
		lLocked := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		oTimer:Activate()
	EndIf
EndIf	

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTLocked ³ Autor ³ Vendas Clientes       ³ Data ³24/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Destravar Usuario Para Atualizacao da Base de Dados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTLocked

Conout(STR0104)// "Aguarde. Atualizando a base de dados..."

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTAtua  ³ Autor ³ Vendas Clientes       ³ Data ³05/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha as tabelas para o FRTA020 atualizar as tabelas.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTAtua
Local aFiles := FRTArquivos()
Local nI	 := 0 				// variavel do loop

For nI := 1 To Len(aFiles)										// Fecha as tabelas
	&(aFiles[nI]+"->(dbCloseArea())")
Next nI
FRTGeraSLI(cEstacao, "COM", "CLOSE OK", "SOBREPOE")				// Envia ao FRTA020 que fechou as tabelas
While .T.
	SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM"))		// Aguarda o FRTA020 atualizar a tabela
	If Left(SLI->LI_MSG,10)=="OPEN FILES"
		Exit
	EndIf
	Sleep(1000)
End
For nI := 1 To Len(aFiles)										// Reabre as tabelas
	ChkFile(aFiles[nI])
Next nI
FRTGeraSLI(cEstacao, "COM", "", "SOBREPOE")						// Finaliza o processo

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAtuSPF ³ Autor ³ Vendas Clientes       ³ Data ³23/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza as senhas do usuario (SIGAPSS.SPF)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTAtuSPF

SPF_Close("SIGAPSS.SPF")
FRTGeraSLI(cEstacao, "PSS", "SPF CLOSED", "SOBREPOE")			// Envia ao FRTA020 que fechou o SIGAPSS.SPF
While .T.
	SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"PSS"))		// Aguarda o FRTA020 atualizar a tabela
	If Left(SLI->LI_MSG,6)=="SPF OK"
		Exit
	EndIf
	Sleep(1000)
End
FRTGeraSLI(cEstacao, "PSS", "", "SOBREPOE")

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT010PAR ºAutor  ³Venda Clientes      º Data ³  26/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua alteração no valor e data das parcelas               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT010Par( nVlrTotal )
Local nLinha		:= If(lVisuSint .AND. Type("oPgtosAna") == "O", oPgtosAna:nAt, oPgtos:nAt)
Local cForma
Local cDesc
Local dDataParc
Local nValParc 
Local cMoedaVen 
Local oDataParc
Local oValParc
Local oMoeda
Local aKey
Local nOpc			:= 0
Local cTitle
Local nI 			:= 0	//variavel de loop
Local nValMax		:= 0 
Local nNumParc		:= 0
Local nPosMoeda
Local nTamParc1 	:= 0
Local nTamParc2 	:= 0
Local nValParcAux 	:= 0
Local lTefMult 		:= SuperGetMV("MV_TEFMULT", ,.F.)				// Identifica se o cliente utiliza múltiplas transações TEF
Local cDigCart 		:= "" , oDigCart							// Dígitos do Cartão
Local nLinDig  		:= 0                   						// Linha onde se começa as mudanças de posição por parâmetros					
Local nJanDig  		:= Iif(lUsaTef .AND. lTefMult,30,0)   		// Aumento o tamanho da Dialog se for utilizar o TEF
Local nValAux  		:= 0
Local aSE4 	   		:= {}										// Array com os dados para simular o SE4 na funcao condicoes
Local aDatas    	:= {}                                    	// Array com próximas condições de pagamento
Local cFormAtu  	:= ""										// Guarda a forma de pagamento para recalculo das datas
Local cDigAtu   	:= ""										// Guarda o digito para recalculo das datas
Local nDias			:= 0										// Controle de dias para montar a string de cond.pgto
Local nIntervalo	:= 0										// Calculo do intervalo das parcelas
Local cE4Cond		:= ""										// String para armazenar o Cond.Pagto
Local dDataAnt		:= aPgtos[nLinha][1]						// Guardo a última data para recalculo das proximas
Local nFor			:= 0

dDataParc	:= aPgtos[nLinha][1]
nValParc	:= aPgtos[nLinha][2]
cForma		:= aPgtos[nLinha][3]
cDesc		:= Right(aPgtos[nLinha][4],30)

If !lVisuSint	//Confere os 4 últimos dígitos
	cDigCart 	:= If(lUsaTef .AND. lTefMult, Alltrim(aPgtos[nLinha][12]), Space(04))
Else			//Confere o ID do cartão
	cDigCart 	:= If(lUsaTef .AND. lTefMult, Alltrim(aPgtos[nLinha][12]), Space(TamSX3("L4_FORMAID")[1]) )
EndIf	

If cPaisLoc <> "BRA"
	cMoedaVen := &("MV_MOEDA"+STR(aPgtos[nLinha][11],1))
	nPosMoeda := aPgtos[nLinha][11]
EndIf	

If IsMoney(cForma) .OR. cForma=="VA"
	// "Para alterar a Forma " ### ", pressione a tecla correspondente."
	MsgStop(STR0116+AllTrim(If(Empty(cDesc),cForma,cDesc))+STR0117, STR0003)
	Return(NIL)
EndIf

For nI := nLinha To Len(aPgtos)
	If lVisuSint	//Considerar tbm o ID do Cartão qdo Multi-TEF
		If ( ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
			 (aPgtos[nI][3] == cForma .AND. !cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )    .OR.  ;
		     (aPgtos[nI][3] == cForma .AND.  cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) ) .AND. AllTrim(aPgtos[nI][12]) == Alltrim(cDigCart) )
			nNumParc++
			nValMax +=  Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDataBase,;
		                nDecimais+1,,nTaxaMoeda),nDecimais)
			If nNumParc == 2
			   nDias := aPgtos[nI][1] - dDataParc
			EndIf
        EndIf
	Else			//Mantém a verificação padrão
		If ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
		   ((aPgtos[nI][3] == cForma) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == AllTrim(cDesc)))
			nNumParc++
			nValMax +=  Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDataBase,;
		                nDecimais+1,,nTaxaMoeda),nDecimais)
			If nNumParc == 2
			   nDias := aPgtos[nI][1] - dDataParc
			EndIf
		EndIf
	EndIf		
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desativa as teclas de funcoes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta tela de dialogo para pegar o valor da parcela     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle := If(Empty(aPgtos[nLinha][4]), aPgtos[nLinha][3], aPgtos[nLinha][4])
If Len(aMoeda) > 0
   nTamParc1  := 30
   nTamParc2 := 15
EndIf
DEFINE MSDIALOG oDlgParcela FROM 0,0 TO 110+nTamParc1+nJanDig,260 TITLE STR0105+cTitle PIXEL OF GetWndDefault()		//"Forma de Pagto "

@ 10,10 SAY STR0110 PIXEL	// "Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o tratamento do cheque a vista                                     ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Um cheque eh considerado a vista quando:                               ³
//³             Data do cheque < dDataBase + SuperGetMV("MV_LJCHVST)            ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Se o conteudo do parametro for -1, entao ele nao devera ser considerado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe .AND. cTitle = cSimbCheq
	@ 10,70 MSGET oDataParc VAR dDataParc SIZE 50,10 RIGHT VALID (dDataParc >= dDataBase .AND. FrtVldDta(dDataParc)) OF oDlgParcela PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")
	oDataParc:cSx1Hlp:="L4_DATA"    	
Else	
	@ 10,70 MSGET oDataParc VAR dDataParc SIZE 50,10 RIGHT VALID (dDataParc >= dDataBase) OF oDlgParcela PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA") ;
	Valid dDataParc >= dDataBase .AND. !Empty(dDataParc)	
	oDataParc:cSx1Hlp:="L4_DATA"    	
Endif

@ 25,10 SAY STR0106 PIXEL	// "Valor"
@ 25,70 MSGET oValParc VAR nValParc SIZE 50,10 RIGHT PICTURE PesqPict("SL1","L1_VLRTOT",15) VALID (nValParc>=(nNumParc*0.01) .AND. Iif(cPaisLoc=="BRA",nValParc<=(nValMax-(nNumParc*0.01)),.T.)) OF oDlgParcela PIXEL ;
WHEN Iif(cPaisLoc=="BRA",(nLinha <> nLinha+(nNumParc-1)),.T.)
cSx1Hlp:="L4_VALOR"

If cPaisLoc <> "BRA"
	@ 40,10 SAY STR0145 PIXEL	// "Moeda"
	@ 40,70 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ON CHANGE (nPosMoeda:=oMoeda:nAt) SIZE 50,10 PIXEL OF oDlgParcela
EndIf
	
If lVisuSint
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cliente utilizar multiplas transações TEF vou exibir o ID do cartão      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult .AND. cForma $ _FORMATEF
		@ 40+nLinDig,10 SAY STR0288 PIXEL //"ID do Cartão"
	    @ 40+nLinDig,70 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE PesqPict("SL4","L4_FORMAID") OF oDlgParcela PIXEL WHEN .F.
		nLinDig := nLinDig + 15
		oDigCart:cSx1Hlp:="L4_FORMAID"
	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cliente utilizar multiplas transações TEF vou exibir os dígitos do cartão³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult .AND. cForma $ _FORMATEF
		@ 40+nLinDig,10 SAY STR0278 PIXEL //"Dígitos Cartão"
	    @ 40+nLinDig,70 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE "9999" OF oDlgParcela PIXEL WHEN .F.
		nLinDig := nLinDig + 15
	EndIf
EndIf

DEFINE SBUTTON FROM 40+nLinDig+nTamParc2,63 TYPE 1 ENABLE ACTION (nOpc:=1, oDlgParcela:End()) OF oDlgParcela
DEFINE SBUTTON FROM 40+nLinDig+nTamParc2,93 TYPE 2 ENABLE ACTION oDlgParcela:End() OF oDlgParcela

ACTIVATE DIALOG oDlgParcela CENTERED

If nOpc == 1
	aPgtos[nLinha][1] := dDataParc
	aPgtos[nLinha][2] := nValParc
	If cPaisLoc <> "BRA"
		aPgtos[nLinha][11] := nPosMoeda
	EndIf
	If lUsaTef .AND. lTefMult .AND. !Empty(cDigCart)
		aPgtos[nLinha][12] := cDigCart
	EndIf
	If cPaisLoc == "BRA"
		If nNumParc > 1
			nValParcela	:= NoRound((nValMax-nValParc)/(nNumParc-1), 2)
			nDif		:= (nValMax-nValParc) - (nValParcela * (nNumParc-1))
			For nI := nLinha+1 To nLinha+(nNumParc-1)
				aPgtos[nI][2] := nValParcela
			Next nI
			aPgtos[nLinha+(nNumParc-1)][2] += nDif
		EndIf
	Else
		If nNumParc > 1
			//Converte o valor da parcela para a moeda corrente.
			nValParcAux := Round(xMoeda(nValParc,nPosMoeda,nMoedaCor,dDataBase,;
			                     nDecimais+1,,nTaxaMoeda),nDecimais)      
			
			//Realiza o calculo de qual vai ser o valor das parcelas.                     
			nValParcela	:= Round((nValMax-nValParcAux)/(nNumParc-1), MsDecimais(nPosMoeda))
			nDif		:= (nValMax-nValParcAux) - (nValParcela * (nNumParc-1))
			
			//Converte o valor da diferenca para a moeda da parcela a 
			//qual ela sera somada.
			nDif        := Round(xMoeda(nDif,nMoedaCor,aPgtos[nLinha+(nNumParc-1)][11],dDataBase,;
			                     MsDecimais(aPgtos[nLinha+(nNumParc-1)][11])+1,nTaxaMoeda),;
			                     MsDecimais(aPgtos[nLinha+(nNumParc-1)][11]))
												                     
			For nI := nLinha+1 To nLinha+(nNumParc-1)
				aPgtos[nI][2] := nValParcela
			Next nI
			aPgtos[nLinha+(nNumParc-1)][2] += nDif
		EndIf	
		nCtrl   := AScan(aFormCtrl, {|x| ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (x[1] == cForma)) .OR. ((x[1] == cForma) .AND. (x[2] == AllTrim(cDesc))) })
		nValAux	:= nVlrTotal
		For nI := 1 To Len(aFormCtrl)
			If nI <> nCtrl
				nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
			EndIf
		Next nI
		nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))

	    //Acerta os dados do array aCProva...
		aCProva[nCtrl][1] := nValParc
		aCProva[nCtrl][2] := nPosMoeda
		aCProva[nCtrl][3] := nValAux
		aCProva[nCtrl][4] := aMoeda[nPosMoeda]
		aCProva[nCtrl][5] := (aCProva[nCtrl][1] < aCProva[nCtrl][3])		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcular datas de Vencimento para as próximas parcelas se houve alteração   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNumParc > 1 .AND. nDias > 0
		For nI := 1 To nNumParc
			If nI == 1
			   nIntervalo := 0
			Else
				nIntervalo += nDias		
			EndIf
			cE4Cond := cE4Cond + StrTran(Str(nIntervalo,3)," ","0") + Iif( nI == nNumParc, "" , "," )
		Next nI
	EndIf

   	If  Len(aPgtos) > 0	.AND. !Empty(cE4Cond) .AND. aPgtos[nLinha][3] $ _FORMATEF .AND. ;
   	    aPgtos[nLinha][1] <> dDataAnt
		aSE4  	:= { 	"CN"	, cE4Cond, "1", "D ", ;
						" "		, " " }
   	    aDatas  := Condicao(nVlrTotal, NIL, NIL, dDataParc, ;
   	    					NIL, NIL, aSE4, NIL )
		cFormAtu:= aPgtos[nLinha][3]
		cDigAtu := aPgtos[nLinha][12]
   		For nFor:= nLinha To Len(aPgtos)
			If (cFormAtu <> aPgtos[nFor][3]) .OR. (Alltrim(cDigAtu)<>Alltrim(aPgtos[nFor][12]))
				Exit
			Else
				aPgtos[nFor][1]    := aDatas[nFor][1]
			EndIf
   		Next nFor
   	EndIf

	oPgtos:SetArray(aPgtos)
	oPgtos:Refresh()
	
	If lVisuSint
		aPgtosSint:=FrtMontPgt(aPgtos)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf
	
EndIf
FRTSetKey(aKey)

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT010VlParºAutor ³Venda Clientes      º Data ³  26/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao dos valores (formas de pagamento) antes     º±±
±±º          ³de fechar a venda.                                          º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT010VlPar( nVlrTotal )
Local nValAux := 0
Local nI	  := 0		//variavel do loop
Local lRet    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o valor total no aPgtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aPgtos)
	If cPaisLoc == "BRA"
		nValAux += aPgtos[nI][2]
	Else                 
		nValAux += Round(xMoeda(aPgtos[nI][2],Int(aPgtos[nI][11]),nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	EndIf
Next nI
If cPaisLoc == "BRA"
	If nValAux < Round(nVlrTotal,nDecimais)
  		If lUsaDisplay                   
  			DisplayEnv(StatDisplay(), "1E"  + STR0258 + Str(nVlrTotal,8,2) + " " + STR0270 + Str(nVlrTotal - nValAux,8,2) )         //"Total: "    ""Saldo: ""	
		EndIf				
		lRet := .F.
	Else 
  		If lUsaDisplay     
  			DisplayEnv(StatDisplay(), "1E"  + STR0258 + Str(nVlrTotal,8,2) + " " + STR0270 + Str(nVlrTotal - nValAux,8,2) )         //"Total: "    ""Saldo: ""	  		              
  			DisplayEnv(StatDisplay(), "2C"  + STR0271 )         //"	
		EndIf					
	Endif
Else 
	If (nValAux < Round(nVlrTotal,nDecimais)) .AND. (Round(nVlrTotal-nValAux,nDecimais) > (1/(10**nDecimais)))
		lRet := .F.	
	EndIf
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTProdMulºAutor  ³Venda Clientes      º Data ³  06/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso o produto tenha multiplos. Será Efetuado um calculo   º±±
±±º          ³ para obtenção de um novo preco unitario de venda.          º±±
±±º          ³ Exemplo: Se o produto foi configurado com BI_MULT igual a 3º±±
±±º          ³ e o seu preço unitário eh: 10,00. O preço "rateado" será:  º±±
±±º          ³ 1o. Item custara: 3,34                                     º±±
±±º          ³ 2o. Item custara: 3,33                                     º±±
±±º          ³ 3o. Item custara: 3,33                                     º±±
±±º          ³ Observe que o resto foi adicionado ao 1o. Item...          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTProdMult( _nVlrUnit, _nItem, _nMaxElem )

Static _depto         
Static _nId
Static _nTotQtde := 0

Local _nMod
Local _nPos
Local _aRetorno
Local cCodProd
Local _lContinua
Local _nTmpQuant := 1
Local lItem

cCodProd   := SBI->BI_COD
_lContinua := .T.
lItem := If(_nItem =1,.T.,.F.)
If lItem
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for o 1o.Item... Zera a Quantidade.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _nId = Nil
	   _nId := 1
	EndIf
    If Len(_aMult)>0
       _aMult := {} 
    EndIf
    If Len(_aMultCanc)>0
       _aMultCanc := {}
    EndIf
EndIf

If _lContinua
	If _nVlrUnit > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto jah existe no array (aMult)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nPos := 0
		If Len(_aMult) > 0
			_nPos := Ascan(_aMult,{ |x| x[1] == SBI->BI_COD .AND. x[3] = _nId })
		Else
			_nId := 1
		EndIf

		If _nPos == 0
			aadd(_aMult,{ SBI->BI_COD , 0 , _nId })
			_nPos	:= Len(_aMult)
		EndIf
		AAdd(_aMultCanc,{ SBI->BI_COD , 0 , _nId, _nItem })

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua o cálculo para os Itens múltiplos...                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		_aMult[_nPos][2] += _nTmpQuant
		_nTotQtde        += _nTmpQuant
		_nVlr2           := (_nVlrUnit * _nTmpQuant)
		_nMod            := Mod(_nVlr2, SBI->BI_MULT)

		If Mod(_nvlr2*100,SBI->BI_MULT) >= _aMult[_nPos][2]
			_nVlrUnit := NoRound(_nVlr2/SBI->BI_MULT) + 0.01
		Else
			_nVlrUnit := NoRound(_nVlr2/SBI->BI_MULT)
        EndIf

		If _aMult[_nPos][2] = SBI->BI_MULT
			_aMult[_nPos][2] := 0
			_nId++
		EndIf

		_aRetorno := {1,_nVlrUnit,cCodProd}
		SBI->(DbSeek(XFilial("SBI")+cCodProd))
		
		If (_nTotQtde == _nMaxElem)
			_nTotQtde := 0
			If (_aMult[_nPos][2] <> SBI->BI_MULT)
				_nId++
			EndIf
		EndIf									
	Else
		_aRetorno := {}
	Endif
Else
	_aRetorno := {}	
Endif

Return(_aRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CancProdMuºAutor  ³Venda Clientes      º Data ³  06/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso o produto tenha multiplos. Será adicionado ao array   º±±
±±º          ³ _aMultCanc os dados do Item vendido com um Identificador.  º±±
±±º          ³ Pois bem, esta função, tem como objetivo, localizar os     º±±
±±º          ³ Itens que possuam o mesmo identificador.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CancProdMult( aCancItens )
Local _nPos    := 0
Local _nId     := 0
Local aRetorno := {}
Local ny			//variavel do loop

If Len(_aMultCanc) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza os Itens Múltiplos com o mesmo Identificador...    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 To Len(aCancItens)
		_nPos := Ascan(_aMultCanc,{ |x| x[4] = aCancItens[nY] })
		If _nPos <> 0
	 		_nId := _aMultCanc[_nPos][3]
			aEval(_aMultCanc,{|x,y| if(_aMultCanc[y][3] = _nId,aAdd(aRetorno,_aMultCanc[y][4]),'')})
		EndIf
	Next nY
EndIf

Return(aRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTLastIT ³ Autor ³ Vendas Clientes       ³ Data ³06/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o Numero do Ultimo Item do Cupom.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTLastIT
Local nRet := 0		// retorno da funcao

If Len(aItens) > 0
	nRet := ATail(aItens)[AIT_ITEM]
EndIf

Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTGeraImpºAutor  ³Venda Clientes      º Data ³  01/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array com os dados dos impostos incidentes em um    º±±
±±º          ³ determinado produto                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTGeraImp( aImposto, aInfo, nValImp, nQuant, ;
					 nVlrUnit, nX   , cIndImp )

Local cCpoVlrItem := ""
Local cCpoBaseIte := ""
Local cCpoVlrCab  := ""
Local cCpoBaseCab := ""
Local cCpoBas     := "IT_BASEIV"+cIndImp	 
Local nValBas     := Round(MaFisRet(nX,cCpoBas),nDecimais)		       	    		       

cCpoVlrItem := "L2_"+Subs(aInfo[2],4,7)   //Campo de gravacao do valor do imposto no item
cCpoBaseIte := "L2_"+Subs(aInfo[7],4,7)   //Campo de gravacao da base do imposto no item
cCpoVlrCab  := "L1_"+Subs(aInfo[6],4,7)   //Campo de gravacao do valor do imposto no cabecalho
cCpoBaseCab := "L1_"+Subs(aInfo[8],4,7)   //Campo de gravacao da base do imposto no cabecalho

aImposto := {}                   //Limpa o array para que armazene somente os 
							      //dados do imposto que está sendo calculado

AAdd( aImposto, aInfo[1] )       //Codigo do imposto
AAdd( aImposto, aInfo[9] )       //Aliquota do imposto  
AAdd( aImposto, nValBas )        //Base do Imposto
AAdd( aImposto, nValImp  )                         //Valor do imposto
AAdd( aImposto, aInfo[4] + aInfo[3] + aInfo[5] )   //FC_INCDUPL/FC_INCNOTA/FC_CREDITA
AAdd( aImposto, cCpoVlrItem )
AAdd( aImposto, cCpoBaseIte )
AAdd( aImposto, cCpoVlrCab )
AAdd( aImposto, cCpoBaseCab )
AAdd( aImposto, {1,-1,0} )                
AAdd( aImposto, nQuant )  
AAdd( aImposto, nVlrUnit )

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCalcVen³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe o total da venda em todas as moedas do sistema.      ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FRTCalcVen

Local aPreco    := {}
Local aLabel    := {}
Local nValMoeda := 0
Local nX        := 0
Local nDecs	    := 0
Local oFnt
Local oFnt1
Local oDlg

For nX	:=	1 To MoedFin()
	If(!(Empty(&("MV_MOEDA"+STR(nX,1)))))
		AAdd(aLabel,STR0148+AllTrim(&("MV_MOEDA"+STR(nX,1)))+":")  //"Total em "
	Endif
Next nX

For nX := 1 To Len(aLabel)
	nDecs := MsDecimais(nX)	
	nValMoeda  := Round(xMoeda(nVlrTotal,nMoedaCor,nX,dDatabase,nDecs+1,nTaxaMoeda),nDecs)
   	AADD(aPreco,nValMoeda)
Next nX     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFnt  NAME "Arial" SIZE 15,15 BOLD 
DEFINE FONT oFnt1 NAME "Arial" SIZE 11,13 BOLD ITALIC

DEFINE MSDIALOG oDlg FROM 190,420 TO 470,930 TITLE STR0147 PIXEL OF GetWndDefault();  //"Totais da Venda-Diversas Moedas"
       STYLE nOr(WS_VISIBLE, WS_POPUP) COLOR CLR_WHITE,CLR_GRAY

@ 000,001 TO 150,255 OF oDlg PIXEL  
   
@  010,05 Say aLabel[1] Size 140,15 OF oDlg Font oFnt Pixel
If Len(aLabel) >= 2
   @  040,05 Say aLabel[2] Size 140,15 OF oDlg Font oFnt Pixel
EndIf   
If Len(aLabel) >= 3
   @  070,05 Say aLabel[3] Size 140,15 OF oDlg Font oFnt Pixel
EndIf
If Len(aLabel) >= 4
   @  100,05 Say aLabel[4] Size 140,15 OF oDlg Font oFnt Pixel
EndIf   
If Len(aLabel) >= 5
   @  130,05 Say aLabel[5] Size 140,15 OF oDlg Font oFnt Pixel
EndIf   

@  010,170 Say aPreco[01] Picture PesqPict("SL1", "L1_VLRTOT",15,1) Size 70,15 OF oDlg Font oFnt1 Pixel
If Len(aPreco) >= 2
   @  040,170 Say aPreco[02] Picture PesqPict("SL1", "L1_VLRTOT",15,2) Size 70,15 OF oDlg Font oFnt1 Pixel
EndIf   
If Len(aPreco) >= 3
   @  070,170 Say aPreco[03] Picture PesqPict("SL1", "L1_VLRTOT",15,3) Size 70,15 OF oDlg Font oFnt1 Pixel
EndIf   
If Len(aPreco) >= 4
   @  100,170 Say aPreco[04] Picture PesqPict("SL1", "L1_VLRTOT",15,4) Size 70,15 OF oDlg Font oFnt1 Pixel
EndIf
If Len(aPreco) >= 5   
   @  130,170 Say aPreco[05] Picture PesqPict("SL1", "L1_VLRTOT",15,5) Size 70,15 OF oDlg Font oFnt1 Pixel
EndIf   
	
ACTIVATE DIALOG oDlg CENTERED

Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTrcMoeda³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite ao usuario trocar a moeda padrao da venda.         ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FRTrcMoeda

Local oDlgTrcMoeda
Local nOpc      := 0
Local oMoeda
Local cMoedaVen
Local nPosMoeda := 1
Local oTaxaVen
Local nTaxaVen  := 1

If !Empty(aItens)
	HELP(' ',1,'FRT044') // "A moeda não pode ser alterada, pois ja foi realizada venda."
	Return NIL
Else
	DEFINE MSDIALOG oDlgTrcMoeda FROM 0,0 TO 120,260 TITLE STR0150 PIXEL OF GetWndDefault()	// "Forma de Pagto "
		
	@ 10,10 SAY STR0145 PIXEL	// "Moeda"
	@ 10,70 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ;
	        ON CHANGE (nTaxaVen:=RecMoeda(dDataBase,oMoeda:nAt),nPosMoeda:=oMoeda:nAt,;
	        oTaxaVen:SetFocus()) Valid(nTaxaVen > 0) SIZE 50,10 OF oDlgTrcMoeda PIXEL
		   
	@ 25,10 SAY STR0146 PIXEL	// "Taxa"
	@ 25,70 MSGET oTaxaVen VAR nTaxaVen SIZE 50,10 PICTURE  PesqPict("SL1","L1_TXMOEDA");
    OF oDlgTrcMoeda PIXEL 
		
	DEFINE SBUTTON FROM 45,63 TYPE 1 ENABLE ACTION (nOpc:=1,oDlgTrcMoeda:End()) OF oDlgTrcMoeda
	DEFINE SBUTTON FROM 45,93 TYPE 2 ENABLE ACTION oDlgTrcMoeda:End() OF oDlgTrcMoeda
		
	ACTIVATE DIALOG oDlgTrcMoeda CENTERED
	
	If nOpc == 1           
		nMoedaCor := nPosMoeda
		cMoeda    := cMoedaVen
		oMoedaCor:Refresh()

		nDecimais := MsDecimais(nMoedaCor)
		                   
		If nPosMoeda == 1
			nTaxaMoeda := 1
		Else
			nTaxaMoeda := nTaxaVen
		EndIf
		oTaxaMoeda:Refresh()

		cSimbCor  := AllTrim(SuperGetMV("MV_SIMB"+Str(nPosMoeda,1)))
		oTemp3:Refresh() 
		oTemp4:Refresh()		
		oTemp5:Refresh()		
	EndIf
EndIf
	
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTGravaSL2  ³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o arquivo SL2 quando eh atribuido um                 ´±±
±±³          ³ desconto no total da venda.                                   ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
                                                                    
Function FRTGravaSL2( aSL2 )
           
Local nI		:= 0													// Contador de For
Local nX		:= 0													// Contador de For
Local nIndSL2   := 0													// Indice SL2
Local nRegSL2	:= 0													// Registro SL2
Local nPosItem  := aScan(aSL2[Len(aSL2)],{|x| Trim(x[1])=="L2_ITEM"})	// Posicao Item

DbSelectArea("SL2")
nIndSL2 := IndexOrd()
nRegSL2 := RecNo()
DbSetOrder(1)
For nI := 1 To Len(aSL2)
	DbSeek(xFilial("SL2")+cOrcam+aSL2[nI][nPosItem][2])
	RecLock("SL2",.F.)  
	For nX := 1 To Len(aSL2[nI])  
		FieldPut(FieldPos(aSL2[nI][nX][1]), aSL2[nI][nX][2])	
    Next nX
	dbCommit()
	MsUnLock()                     
Next nI
DbSetOrder(nIndSL2)
dbGoTo(nRegSL2)         

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTCarregaºAutor  ³Venda Clientes       º Data ³  31/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar e carregar o orcamento selecionado.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpO1: Objeto DIALOG                                        º±±
±±º          ³ ExpC2: Numero do Orcamento                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTCarrega( oDlg, cNumOrc )

Local cRet		 := ""								// Retorno de String
Local cOrc 		 := ""								// Orcamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parametro MV_LJDTORC definira o ajuste das datas do orcamento, sendo:    ³
//³ "N" - Nunca Ajusta as datas, ou seja, sempre a que foi gravada             ³
//³ "S" - Sempre Ajusta as datas, ou seja, Atualiza a data baseado no dia atual³
//³ "P" - Pergunta, ou seja, fara uma pergunta se deseja ajustar as datas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cLJDTORC 	 := SuperGetMV( "MV_LJDTORC" )		// Conteudo do parametro MV_LJDTORC
Local cCliente	 := ""								// Codigo do Cliente
Local cLoja		 := ""								// Loja do Cliente
Local nI		 := ""								// Variavel do loop	//Variavel de apoio
Local nValor 	 := 0								// Valor
Local aRet       := {}								// Array de retorno
Local lLJDTORC 	 := .F.								// Logico do Mv_LjdTorc
Local dDataParc										// Data de parcelamento
Local cCondPgto  :=""								// Codigo da condicao de pagamento gravada no orcamento
Local lRet 		 := .F.								// Controla o retorno da pergunta de confirmacao da importacao do orcamento 
Local lVerEmpres := Lj950Acres(SM0->M0_CGC)			// Verifica as filiais da trabalharam com acrescimento separado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver na rotina de recebimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe
	Return(NIL)
EndIf

If nVidaLink == 1  // Gravando VidaLink
	cRet := "OK"
	aRet := {"OK", "", { {"A1_COD", aVidaLinkC[VDLNK_CABEC_CODCLI] }, {"A1_LOJA", aVidaLinkC[VDLNK_CABEC_LOJA] } } }		//No orcamento eh retornado algo como:  aRet := {"OK", cSL1+cSL2+cSL4, aSA1}
Else
	//"Aguarde. Carregando o orcamento "
	LJMsgRun( STR0153 + cNumOrc + "...", NIL, { || aRet := FRTMyCall( "FRTRPCLoad", { "SA1", "SL1", "SL2", "SL4" }, cNumOrc ) } )
	
	cRet := aRet[1]
	cOrc := aRet[2]
	cRet := Trim( cRet )
Endif

If Left( cRet, 2 ) == "OK"
	If nVidaLink <> 1
		lRet := MsgYesNo(STR0154+cNumOrc+"?", STR0003) // "Confirma o carregamento do Orçamento " ### "?", "Atenção"
	Else
		lRet := .T.
	Endif
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a gravacao do SA1 caso nao exista ou algum campo foi alterado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aRet[3] ) > 0
			If ( nI := AScan( aRet[3], { |x| x[1] == "A1_COD" } ) ) > 0
				cCliente 	:= aRet[3][nI][2]
				nI			:= AScan( aRet[3], { |x| x[1] == "A1_LOJA" } )
				cLoja 		:= IIF( nI == 0, Space( Len( SA1->A1_LOJA ) ), aRet[3][nI][2] )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se Registro do SA1 no front nao existir ou conteudo de algum campo for diferente da retaguarda atualiza registro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lNovoCliente := IIF( SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) ), .F. , .T. )

				If CrdSa1Alte( aRet[3] )
					FRTGeraSL( "SA1", aRet[3], lNovoCliente )
				EndIf
			EndIf
		EndIf		
		If nVidaLink <> 1
			For nI := 1 To FRTQtdSL2( cOrc )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Registra Todos os Items³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTProdOK( cOrc, nI, NIL, .F. )
				nQtdeItOri++
			Next  nI
		Else
			For nI := 1 To LEN(aVidaLinkD[VDLNK_DETALHE])
				cCodProd := aVidaLinkD[ VDLNK_DETALHE, nI, VDLNK_CODIGOEAN ]
				FRTProdOK( NIL, nI, NIL, .F. )					// Registra todos os itens do VidaLink não passo cOrc
				nQtdeItOri++
			Next nI
		Endif
		
		nVlrDescIt 	:= 0
		nVlrPercIt 	:= 0
		_lOk 		:= .F.
		lOrc 		:= .F.
		cCondPgto	:= FRTAField( cOrc, "L1_CONDPG" )
		
		If lVerEmpres
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica existe a condicao de pagamento com ³
			//³acrescimo financeiro separado.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SE4")
			DbSetOrder(1)
			If DbSeek(xFilial("SE4") + cCondPgto)
				If (SE4->E4_ACRSFIN > 0) .AND. (AllTrim(SE4->E4_FORMA) == "FI")
					If 	(FieldPos("E4_AGRACRS") > 0 .AND. SE4->E4_AGRACRS == "2") .AND. ;
						(FieldPos("E4_LIMACRS") > 0 .AND. SE4->E4_LIMACRS > 0)
						lOrigOrcam := .T.
						cCdPgtoOrc := cCondPgto
						cCdDescOrc := SE4->E4_DESCRI
				  		//"Este orçamento possui condição de pagamento com acréscimo financeiro, porém, não calculado. Carregue novamente o orçamento : "
				  		MsgAlert(STR0317 + AllTrim(cCdPgtoOrc) + " (" + Alltrim(cCdDescOrc) + ")")
				    EndIf	
				EndIf
		    EndIf
		EndIf
		
		FRTInitIT( .T. )
		FErase( Substr( cRet, 3, 8 ) )
		If nVidaLink <> 1
			If ( FRTAField( cOrc, "L1_CONDPG" ) == "CN" ) .OR. ( SE4->( DbSeek( xFilial( "SE4" ) + FRTAField( cOrc, "L1_CONDPG" ) ) ) )
				aParcOrc := {}
				cLJDTORC := IIF( FRTAField( cOrc, "L1_EMISSAO" ) == dDataBase, "N", cLJDTORC )
	
				If cCondPgto <> "CN" .AND. cLJDTORC $ "SP" //SL1->L1_CONDPG <> "CN" .AND. cLJDTORC $ "SP"
					lLJDTORC := .T.
	
					If cLJDTORC == "P"
						lLJDTORC := MsgYesNo( STR0172, STR0003 )  // "Deseja ajustar as datas das parcelas do orcamento, com base na data de hoje?", "Atenção"
					EndIf
				EndIf
	
				For nI := 1 To FRTQtdSL4( cOrc )
					If lLJDTORC
						dDataParc := dDataBase + ( FRTAField( cOrc, "L4_DATA", nI ) - FRTAField( cOrc, "L1_EMISSAO" ) )
					Else
						dDataParc := FRTAField( cOrc, "L4_DATA", nI )
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Soma todas as parcelas para identificar Acrescimo³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValor += FRTAField( cOrc, "L4_VALOR", nI )
	
					AAdd( aParcOrc, { 	dDataParc									,;
										FRTAField( cOrc, "L4_VALOR", nI )			,;
										AllTrim( FRTAField( cOrc, "L4_FORMA", nI ) )	,;
										FRTAField( cOrc, "L4_ADMINIS", nI )			,;
										FRTAField( cOrc, "L4_NUMCART", nI )			,;
										FRTAField( cOrc, "L4_AGENCIA", nI )			,;
										FRTAField( cOrc, "L4_CONTA", nI )			,;
										FRTAField( cOrc, "L4_RG", nI )				,;
										FRTAField( cOrc, "L4_TELEFON", nI )			,;
										FRTAField( cOrc, "L4_TERCEIR", nI )			,;
										IIF( cPaisLoc <> "BRA", FRTAField( cOrc, "L4_MOEDA", nI ), 1 ), " ",;
										IIF(lVerEmpres,IIF(SL4->(FieldPos("L4_ACRSFIN")) > 0,;
										FRTAField( cOrc, "L4_ACRSFIN", nI),0),0) } )
				Next nI
	
				cItemCOrc   := FRTAField( cOrc, "L1_CONDPG" )					// CONDICAO DE PAGAMENTO
				nVlrDescTot	:= FRTAField( cOrc, "L1_DESCONT" )					// VALOR DO DESCONTO
				nVlrPercTot	:= FRTAField( cOrc, "L1_DESCNF" )					// PERCENTUAL DE DESCONTO
				nVlrPercAcr := FRTAField( cOrc, "L1_JUROS" )					// PERCENTUAL DE ACRESCIMO
	
				If nValor + nVlrDescTot + nTotDedIcms > nVlrBruto
					nVlrAcreTot := nValor + nVlrDescTot + nTotDedIcms - nVlrBruto				// VALOR DO ACRESCIMO
				ElseIf nValor + nVlrDescTot + nTotDedIcms < nVlrBruto
					nVlrDescCPg := nVlrBruto - nValor - nVlrDescTot - nTotDedIcms				// VALOR DO DESCONTO FINANCEIRO
				EndIf
	
				nNumParcs   := FRTAField( cOrc, "L1_PARCELA" )					// NUMERO DE PARCELAS
				nVlrPercOri := nVlrPercTot                                      // PERCENTUAL DE DESCONTO ORIGINAL
				lImpNewIT   := .F.												// Indica se foi adicionado um novo item ao orcamento
			Else                
				Help( " ", 1, "EF_CARGA" )
			EndIf
		Else
			aParcOrc := {}
			cLJDTORC := dDataBase
			lLJDTORC := .T.
			
			nValTot		:= aVidaLinkD[VDLNK_TOTALVENDA]
			cCond		:= SPACE(3)
			nValIpi		:= 0
			dData0		:= ddatabase
			nValSolid	:= 0
			aImpVar		:= {}
			aE4			:= {"", "", "", "", "", ""  }
			nAcrescimo	:= 0
			
			DbSelectArea("SE4")
			DbSetOrder(1)
			DbSeek(xFilial("SE4")+cCond)
			
			aE4[1]	:= SE4->E4_CODIGO
			aE4[2]	:= SE4->E4_COND
			aE4[3]	:= SE4->E4_TIPO
			aE4[4]	:= SE4->E4_DDD
			aE4[5]	:= SE4->E4_IPI
			aE4[6]	:= SE4->E4_SOLID
			
			aVdLnkPar	:= Condicao( aVidaLinkD[VDLNK_TOTALVENDA] , SE4->E4_COND, nValIpi, dData0, nValSolid,,,nAcrescimo)
			
			For nI := 1 To LEN(aVdLnkPar)
				dDataParc := aVdLnkPar[nI,1]
				nValor += aVdLnkPar[nI,2]			// Soma todas as parcelas para identificar Acrescimo
				
				// Elementos do array aParcOrc  Data da Parcela, L4_VALOR, L4_FORMA, L4_ADMINIS,L4_NUMCART, L4_AGENCIA, L4_CONTA, L4_RG, L4_TELEFON, L4_TERCEIR, L4_MOEDA, " "
				cFormaPagto := If( !Empty(SuperGetMV("MV_FORMPAD")),SuperGetMV("MV_FORMPAD"),SuperGetMV("MV_SIMB1"))
				AAdd(aParcOrc, {dDataParc,;				// Data
								aVdLnkPar[nI,2],;		// Valor
								"cFormaPagto" ,;		// Forma
								" ",;					// Administradora
								" ",;					// Num Cartao
								" ",;					// Agencia
								" ",;					// Conta
								" ",;					// RG
								" ",;					// Telefone
								"F",;					// Terceiro
								1  ,;					// Moeda
								" ",;					// Digitos do cartao para TEFMULT
								0 } )					// Conceito de acrescimo financeiro separado
				
			Next nI
			cItemCOrc   := SE4->E4_CODIGO
			nVlrDescTot	:= 0					// VALOR DO DESCONTO
			nVlrPercTot	:= 0 					// PERCENTUAL DE DESCONTO
			nVlrPercAcr := 0 					// PERCENTUAL DE ACRESCIMO
			nVlrAcreTot := 0					// VALOR DO ACRESCIMO
			nVlrDescCPg := 0 					// VALOR DO DESCONTO FINANCEIRO
			nNumParcs   := len(aVdLnkPar)		// NUMERO DE PARCELAS
			nVlrPercOri := 0					// PERCENTUAL DE DESCONTO ORIGINAL
			lImpNewIT   := .F.					// Indica se foi adicionado um novo item ao orcamento
		EndIf
	EndIf

	oDlg:End()
	If nVidaLink <> 1
		oDlg:End()		// Fecha janela orcamento
	Else
		nVidaLink := 2	// Jah Gravado VidaLink
	Endif
ElseIf Left( cRet, 8 ) == "EXPIRADO"
	Help( " ", 1, "DTVALIDADE" )
ElseIf Left( cRet, 7 ) == "VENDIDO"
	Help( " ", 1, "VENDIDO" )
ElseIf Left( cRet, 8 ) == "NOTFOUND"
	// "O Orçamento " ### " não foi encontrado na Retaguarda.", "Atenção"
	MsgStop( STR0155 + cNumOrc + STR0156, STR0003 )
Else
	// "Erro ao carregar o Orçamento " ### ". Tente novamente.", "Atenção"
	MsgStop(STR0157 + cNumOrc + STR0158, STR0003 )
EndIf

Return (NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCondPag³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao da Condicao de Pagamento (F5)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTCondPag( aCondicoes	, cItemForma, nTmpJuros	, aPgtos	, ;
					 oPgtos		, oFormPag	, cFormPag	, nTmpDesc 		)

Local cLine																		
Local nOldLen 		 := Len(oCupom:aItems)										// Cupom
Local nLen														
Local nI 			 := 0 														// variavel do loop						
Local nMidItem 		 := Round(Len(aCondicoes)/2,0)								// Item 
Local cTmpCondPag	 := "   "													// Armazena temporario
Local aKey																		// Chaves
Local aRet 			 := {}														// Array com as informacoes da Forma de Pagamento.
Local nPerDescFi																// Percentual do desconto financeiro 
Local nPerAcreFi																// Percentual do acrescimo financeiro
Local cCondPag 		 := ""														// Condicao de Pagamento
Local lFrtCondPag 	 := ExistBlock( "FRTCONDPAG" ) 								// Se existe Ponto de Entrada
Local lTFrtCondPag   := ExistTemplate("FRTCONDPAG")  							// Verifica se existe o PONTO DE ENTRADA FRTCONDPAG
Local lTefMult	  	 := SuperGetMV("MV_TEFMULT", ,.F.)							// Identifica se o cliente utiliza múltiplas transações TEF
Local cFormaId	  	 := If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	// Espaco do L4_FORMAID
Local nNumLinesCup   := 0
Local nTotGeral      := 0                            // Total geral usado para calcular o valor do acrescimo financeiro     

Private aRetNeg
Private lDiaFixo

If lRecebe
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracao especifica para atender a legislacao do SEFAZ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjAnalisaLeg(13)[1] .AND. Len(aFormCtrl) > 0
	// Nestes estados a legislacao nao permite este procedimento.
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao deste recurso.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTFrtCondPag
	cCondPag := ExecTemplate( "FRTCONDPAG", .F., .F.,{ uCliTPL } )
EndIf
If lFrtCondPag
	cCondPag := ExecBlock( "FRTCONDPAG", .F., .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If !lFrtCondPag .AND. !lTFrtCondPag

	FRTAddLine( FRT_SEPARATOR, @nNumLinesCup, "999" )
	FRTAddLine( "", @nNumLinesCup, "999" )
	FRTAddLine( STR0088, @nNumLinesCup, "999" )	// "         CONDIÇÕES DE PAGAMENTO         "
	FRTAddLine( "", @nNumLinesCup, "999" )

	For nI := 1 To nMidItem
		cLine := Left(aCondicoes[nI],19)+"  "
		If nMidItem + nI <= Len(aCondicoes)
			cLine += Left(aCondicoes[nMidItem + nI],19)
		EndIf
		cTmpCondPag := FRTAddLine( cLine, @nNumLinesCup, "999" )

		If !Empty(cTmpCondPag) .OR. lEsc
			Exit
		EndIf
	Next nI

	If Empty(cTmpCondPag) .AND. ! lEsc
		FrtGet(@cTmpCondPag, "999", @lEsc)
	EndIf       
	
	lEsc := .F.	                 
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "2C" + Upper(STR0273)	)   //"Escolha a condicao de pagamento"
	EndIf

Else
	cTmpCondPag := cCondPag
EndIf

If (nI := AScan(aCondicoes,{|x| cTmpCondPag == Left(x,3)})) > 0
	// Condicao Negociada
	If cTmpCondPag == "999"
		lCondNegF5 := .T.
		FRTCondNeg()
		If Len(aRetNeg)>0
			cItemCond := "CN"
			nTXJuros   := aRetNeg[6][1]
			aRet := AClone(LJ7CalcPgt(nVlrBruto - If(cPaisLoc=="BRA",nVlrDescTot + nTotDedIcms,0), cItemCond, {aRetNeg[1][1], aRetNeg[4][1], aRetNeg[5][1], aRetNeg[6][1], aRetNeg[7][1], aRetNeg[8][1], .F.},, @nTmpJuros, @nTmpDesc, nMoedaCor, ,@lDiaFixo))
		EndIf
		If !Empty( aRetNeg )
			nPerAcreFi := aRetNeg[6][1]		// Percentual de acrescimo financeiro
			nPerDescFi := 0					// Percentual de desconto financeiro
		Else
			nPerAcreFi := 0
			nPerDescFi := 0
		EndIf
	Else
		lCondNegF5 := .F.
		cItemCond  := cTmpCondPag
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+cItemCond))
		cItemForma := If(!Empty(SE4->E4_FORMA),SubStr(SE4->E4_FORMA,1,2),If(!Empty(SuperGetMV("MV_FORMPAD")),SuperGetMV("MV_FORMPAD"),SuperGetMV("MV_SIMB1")))
		nTmpDesc   := SE4->E4_DESCFIN
		aRet := AClone(LJ7CalcPgt(nVlrBruto - If(cPaisLoc=="BRA",nVlrDescTot + nTotDedIcms,0), cItemCond,,, @nTmpJuros, @nTmpDesc,nMoedaCor))
		nTXJuros   := nTmpJuros
		nPerAcreFi := SE4->E4_ACRSFIN		// Percentual de acrescimo financeiro
		nPerDescFi := SE4->E4_DESCFIN		// Percentual de desconto financeiro
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para entrar na rotina:                                                                    ³
	//³- Valida se existe elementos no array                                                     ³
	//³- Valida se o estado do M0_ESTCOB está dentro da lei, se existe desconto no total da venda³
	//³e a condição de pagamento não trata juros nem desconto                                    ³
	//³- Valida se o estado do M0_ESTCOB nao estah dentro da lei                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Len( aRet ) > 0		.AND.;			//Valida se tem dados no array
		( ( LjAnalisaLeg( 14 )[1] .AND. lDescTotal .AND. ( nPerAcreFi == 0 .AND. nPerDescFi == 0 ) ) ) .OR.;
		( ( LjAnalisaLeg( 14 )[1] .AND. !lDescTotal ) ) .OR.;
		! ( LjAnalisaLeg( 14 )[1] )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se tem desconto ou juros³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPerAcreFi > 0 .OR. nPerDescFi > 0
			lDescSE4	:= .T.
		Else
			lDescSE4	:= .F.
        Endif

		aPgtos := {} 			//Zera o array aPgtos para gravar o novo calculo
		nVlrTotal := 0
		For nI := 1 to Len(aRet)
			nVlrTotal += aRet[nI][2]
			cFormaID := If(AllTrim(aRet[nI][3])$_FORMATEF,"1",cFormaId)
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exibir o valor do acrescimo separado da parcela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			AAdd( aPgtos, { aRet[nI][1]	, NoRound(aRet[nI][2],nDecimais), AllTrim(aRet[nI][3])	, "", "", "", "", "", "", .F., nMoedaCor, If(lVisuSint,cFormaID,Space(04)), aRet[nI][8]})
		Next nI
		nVlrTotal := NoRound(nVlrTotal,nDecimais)
		nTotGeral := nVlrTotal + nTotDedIcms
		nVlrAcreTot := 0
		If nPerAcreFi > 0		//Valor do acrescimo financeiro
			nVlrAcreTot	:= nTotGeral - nVlrBruto + nVlrDescTot
		EndIf
		nVlrDescCPg := 0
		If nPerDescFi > 0		//Valor do desconto financeiro
			nVlrDescCPg := nVlrBruto - (nVlrTotal + nVlrDescTot + nTotDedIcms)
		Endif
		
		If ExistBlock("FRTPGTODP")
			ExecBlock("FRTPGTODP", .F., .F., { cTmpCondPag })
		EndIf

		oPgtos:SetArray(aPgtos)
		oPgtos:Refresh()
		oVlrTotal:Refresh()
		
		If lVisuSint
			aPgtosSint:=FrtMontPgt(aPgtos)
			oPgtosSint:SetArray( aPgtosSint )
			oPgtosSint:Refresh()
		EndIf
	Else
		MsgAlert(STR0298,STR0003) //"Escolha uma condição de pagamento que não tenha desconto ou acréscimo, pois já foi dado desconto no total da venda","Atenção"
	EndIf
EndIf

If !lFrtCondPag
	nLen := Len(oCupom:aItems)
	For nI := nLen To nOldLen+1 Step -1
		oCupom:Del(nI)
	Next nI
EndIf

If lUsaDisplay     
	DisplayEnv(StatDisplay(), "1E"  + STR0258 + Str(nVlrTotal,8,2) + " " + STR0270 +" 0,00"  )         //"Total: "    ""Saldo: ""	  		              
 	DisplayEnv(StatDisplay(), "2C"  + STR0271 )         //"	
EndIf					

oCupom:GoTop()
oCupom:GoBottom()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

// Caso o array aPgtos esteja valorizado permite que o objeto oPgtos seja 
// editado pelo usuario, caso contrario desabilita o objeto...
If !Empty(aPgtos)
	oPgtos:Enable()
	If lVisuSint
		oPgtosSint:Enable()
		If !lFrtCondPag
			oPgtosSint:SetFocus()
		EndIf
	EndIf
Else
    If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
    	oPgtos:Disable()
		If lVisuSint
			oPgtosSint:Disable()
		EndIf
	EndIf
EndIf

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCondNeg³ Autor ³ Vendas Clientes       ³ Data ³22/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo da Condicao Negociada "CN"                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTCondNeg
Local nI := 0 //variavel do loop
Local oDlgCN
Local lOk
Local oUsaAdmFin
Local lUsaAdmFin
Local oComboAdm
Local cComboAdm
Local oTipoJur
Local nTipoJur
Local oVlrBase
Local oDataNeg
Local oEntNeg
Local nEntNeg
Local oTxJNeg
Local nTxJNeg
Local oParNeg
Local nParNeg
Local oIntNeg
Local nIntNeg 
Local oChkDiaFixo
Local oIntDVenc
Local aComboAdm  := Lj010LerCart("FI",.T.)
Local aLbxFator  := {}

If lDiaFixo == NIL
	lDiaFixo := .F.
EndIf

nValorBase := nVlrBruto - nTotDedIcms 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Administradora padr„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cComboAdm := aComboAdm[1]
Aadd(aLbxFator, { "  /  /  " , "" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Valor da Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nEntrada := 0
For nI := 1 To Len(aPgtos)
	If aPgtos[nI][1] == dDatabase .AND. !(aPgtos[nI][3] $ SuperGetMV("MV_ENTEXCE"))
		nEntrada += xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
Next nI

aRetNeg := {{1, "1100"},;
			{.F., "1"},;
			{cComboAdm, "1"},;
			{If(Len(aPgtos)>0,aPgtos[1][1],dDataBase), "1"},;
			{nEntrada, "1"},;
			{nTxJuros, "1"},;
			{Len(aPgtos), "1"},;
			{If(Len(aPgtos)>1,aPgtos[2][1]-aPgtos[1][1],1), "1"}}

If ExistBlock("L10RETNG")
	aRetNeg := ExecBlock("L10RETNG",.F.,.F.,{aRetNeg})
EndIf

nTipoJur   := aRetNeg[1][1]
lUsaAdmFin := aRetNeg[2][1]
cComboAdm  := aRetNeg[3][1]
dDataCN    := aRetNeg[4][1]
nEntNeg    := aRetNeg[5][1]
nTxJNeg    := aRetNeg[6][1]
nParNeg    := aRetNeg[7][1]
nIntNeg    := aRetNeg[8][1]

nParNeg := If( nEntNeg < nValorBase .AND. nParNeg == 0, 1, nParNeg )

If (ExistBlock("L10NEGOC"))
	ExecBlock("L10NEGOC",.F.,.F.)
EndIf

If Len(aRetNeg) <= 8 .OR. aRetNeg[09][01]

	DEFINE MSDIALOG oDlgCN FROM 33,33 TO 315,540 TITLE STR0195 PIXEL OF GetWndDefault() //"Condição Negociada"
	
		@ 01, 03 TO  55,120 LABEL STR0196 OF oDlgCN PIXEL //"Cálculo de Juros"
		@ 60, 03 TO 123,120 LABEL STR0197 OF oDlgCN PIXEL //"Administradora"
		@ 01,124 TO 123,250 LABEL STR0198 OF oDlgCN PIXEL //"Dados do Pagamento"
	
		// Utilizar Financiadora
		@ 70, 20 CHECKBOX oUsaAdmFin VAR lUsaAdmFin PROMPT STR0199 SIZE 60,07 OF oDlgCN PIXEL; //"Utilizar Financiadora"
			     ON CHANGE LjxDCalcFator(oDlgCN,@aLbxFator,oLbxFator,lUsaAdmFin,cComboAdm,cCondicao) When .F.
		// Nome da administradora
		@ 80, 20 MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aComboAdm SIZE 75,07;
			     OF oDlgCN PIXEL When lUsaAdmFin
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Radio para a escolha do tipo de juros ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			@ 09, 07 RADIO oTipoJur VAR nTipoJur 3D SIZE 40,10 PROMPT;
				     STR0200, STR0201, STR0202, STR0208 OF oDlgCN PIXEL //"Simples"###"Série Pgtos."###"Price"###"SAC"
			oTipoJur:Enable(1)	// Simples
			oTipoJur:Enable(2)	// Serie Pgtos
			oTipoJur:Enable(3)	// Price
			oTipoJur:Disable(4)	// SAC
		Else
			@ 09, 07 RADIO oTipoJur VAR nTipoJur 3D SIZE 40,10 PROMPT;
			         STR0200, STR0201 OF oDlgCN PIXEL //"Simples"###"Série Pgtos."
			oTipoJur:Enable(1)	// Simples
			oTipoJur:Enable(2)	// Serie Pgtos
		EndIf
	
		@ 07,128 TO  27,246 OF oDlgCN PIXEL
		@ 15,131 SAY STR0203 SIZE 30,07 OF oDlgCN PIXEL //"Valor Base"
		@ 15,176 SAY oVlrBase VAR nValorBase SIZE 68,07 OF oDlgCN PIXEL PICTURE "@E 9,999,999.99" RIGHT COLOR CLR_HBLUE
	
		//Primeira Parcela
		If aRetNeg[4][2]<>'2'
		   @ 35,131 SAY STR0204 SIZE 50,07 OF oDlgCN PIXEL //"Primeira parcela"
		   @ 35,176 MSGET oDataNeg VAR dDataCN SIZE 40,07 OF oDlgCN PIXEL ;
				PICTURE "99/99/99" Valid !Empty(dDataCN) .AND. dDataCN >= dDataBase ;
				WHEN aRetNeg[4][2]<>'0'
				oDataNeg:cSx1Hlp:="DDATACN"    	
		EndIf
	
		//Entrada
		If aRetNeg[5][2]<>'2'
		   @ 50,131 SAY STR0205 SIZE 30,07 OF oDlgCN PIXEL //"Entrada"
		   @ 50,176 MSGET oEntNeg VAR nEntNeg SIZE 60,07 OF oDlgCN PIXEL PICTURE "@E 9,999,999.99" RIGHT;
				VALID (ljxDFirst(nValorBase,nEntNeg,nEntNeg-nValorBase,nParNeg,@nParNeg,oParNeg,oEntNeg),(If (nEntNeg >=0,.T.,(MsgStop(STR0246),.F.))),(if(nEntNeg < nValorBase .AND. nParNeg == 0,(nParNeg := 1,.T.),.T.))) ; //"Näo e permitido valor negativo nesse campo."
				WHEN aRetNeg[5][2]<>'0'
				oEntNeg:cSx1Hlp:="L1_ENTRADA"    	
		EndIf  
	
		// Taxa Juros
		If aRetNeg[6][2]<>'2'
		   @ 65,131 SAY STR0206 SIZE 30,07 OF oDlgCN PIXEL //"Taxa Juros"
		   @ 65,176 MSGET oTxJNeg VAR nTxJNeg SIZE 20,07 OF oDlgCN PIXEL PICTURE "@E 999.99" RIGHT ;
				VALID (If (nTxJNeg >=0,.T.,(MsgStop(STR0246),.F.))) ; //"Näo e permitido valor negativo nesse campo."
				WHEN !lUsaAdmFin .AND. aRetNeg[6][2]<>'0'
				oTxJNeg:cSx1Hlp:="L1_JUROS"    	
		EndIf
	
		// Parcelas
		If aRetNeg[7][2]<>'2'
		   @ 80,131 SAY STR0207 SIZE 30,07 OF oDlgCN PIXEL //"Parcelas"
		   @ 80,176 MSGET oParNeg VAR nParNeg SIZE 13,07 OF oDlgCN PIXEL PICTURE "@E 99" RIGHT ;
				VALID If(nEntNeg < nValorBase, nParNeg >= 1,.T.) ;
				WHEN (nEntNeg < nValorBase).AND.aRetNeg[7][2]<>'0'
				oParNeg:cSx1Hlp:="L1_PARCELA"    	
		EndIf   
	
		// Intervalo  // Dia Vencimento
		If aRetNeg[8][2]<>'2'
		   @ 95,131 SAY oIntDVenc VAR If(lDiaFixo, STR0285,STR0113) SIZE 40,07 OF oDlgCN PIXEL //"Intervalo"
		   @ 95,176 MSGET oIntNeg VAR nIntNeg SIZE 13,07 OF oDlgCN PIXEL PICTURE "999" ;
				VALID (nIntNeg > 0) WHEN aRetNeg[8][2]<>'0'
				oIntNeg:cSx1Hlp:="L1_INTERV"    	
		EndIf   
	
		If SL1->(FieldPos("L1_DIAFIXO"))>0	
			@ 110, 131 CHECKBOX oChkDiaFixo VAR lDiaFixo PROMPT STR0286 SIZE 30,07;   //"Dia Fixo" 
			ON CHANGE (If (lDiaFixo,nIntNeg:=Day(dDataBase),nIntNeg := 1), oIntDVenc:Refresh(), oIntNeg:Refresh())
		EndIf
	
		DEFINE SBUTTON FROM 125,194 TYPE 1 ENABLE OF oDlgCN;
			ACTION (lOk:=.T., oDlgCN:End())
	
		DEFINE SBUTTON FROM 125,223 TYPE 2 ENABLE OF oDlgCN;
			ACTION (lOk:=.F., oDlgCN:End())
	
	ACTIVATE MSDIALOG oDlgCN CENTERED

Else

	// Se não entrou no IF, então o PE esta configurado para não mostrar a janela de Cond. Negociada
	// a variavel lOK fica como .T.
	lOk := .T.
		
EndIf

If lOk
	aRetNeg[1][1] := nTipoJur
	aRetNeg[2][1] := lUsaAdmFin
	aRetNeg[3][1] := cComboAdm
	aRetNeg[4][1] := dDataCN
	aRetNeg[5][1] := nEntNeg
	aRetNeg[6][1] := nTxJNeg
	aRetNeg[7][1] := nParNeg
	aRetNeg[8][1] := nIntNeg
Else
	aRetNeg := {}
EndIf

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtSomaIt ³ Autor ³ Vendas Clientes       ³ Data ³08/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a qtde. informada para cancelamento eh valida  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtSomaIt(ExpC1,ExpN2,ExpA3,ExpN4)                         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 => Codigo do Produto a ser cancelado                 ³±± 
±±³          ³ ExpN2 => Qtde. informada para cancelamento                 ³±± 
±±³          ³ ExpA3 => Array que contem os itens que serao cancelados    ³±± 
±±³          ³ ExpN4 => Qtde. do novo item que sera registrado na venda   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FrtSomaIt( cCancProd, nCancQtde, aCancItens, nQtdeNova )

Local lRet      := .F.
Local aItensAux := aClone(aItens)
Local nPos      := 0
Local nColuna   := AIT_COD
Local nI        := 0
Local nQtdeAux  := 0

//Ordena o array pelo codigo do produto  e item
Asort(aItensAux,,,{ |x,y| UPPER(x[AIT_COD])+StrZero(x[AIT_ITEM],3) < UPPER(y[AIT_COD])+StrZero(y[AIT_ITEM],3)})

//Verifica se o produto informado esta presente na venda
nPos := aScan(aItensAux,{ |x| Trim(x[AIT_COD])=Trim(cCancProd)})
If nPos == 0
	nPos    := aScan(aItensAux,{ |x| Trim(x[AIT_CODBAR])=Trim(cCancProd)})
	nColuna := AIT_CODBAR
EndIf

If nPos <> 0
	aCancItens := {}
	For nI := nPos To Len(aItensAux)
		If !aItensAux[nI][AIT_CANCELADO]
			If (AllTrim(aItensAux[nI][nColuna]) == AllTrim(cCancProd))
				nQtdeAux += aItensAux[nI][AIT_QUANT]
				AAdd(aCancItens,(aItensAux[nI][AIT_ITEM]))
				If nQtdeAux >= nCancQtde
					Exit
				EndIf
			Else
				Exit
			EndIf
		EndIf
	Next nI          
	//Verifica se a qtde a cancelar eh valida, caso seja calcula a quantidade do novo
	//item a ser informado na venda.
	lRet := Iif(nQtdeAux<nCancQtde .OR. nCancQtde==0,.F.,.T.)
	If !lRet
		aCancItens := {}
		Help("",1,"QTDEINV","",STR0162,1) //"A qtde. informada para cancelamento e invalida"
	Else
		nQtdeNova := nQtdeAux - nCancQtde
		lRet := .T.
	EndIf
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtPesqMult ³ Autor ³ Vendas Clientes       ³ Data ³08/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o produto eh um produto com multiplos. Caso seja ³±± 
±±³          ³ determina quais itens da venda sao multiplos e tambem nao    ³±± 
±±³          ³ nao permite que o usuario informe a qtde de itens que serao  ³±± 
±±³          ³ cancelados.                                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtPesqMult(ExpC1,ExpA2,ExpN3)                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 => Codigo do Produto a ser cancelado                   ³±± 
±±³          ³ ExpA2 => Array que contem os itens que serao cancelados      ³±± 
±±³          ³ ExpN3 => Qtde. informada para cancelamento                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FrtPesqMult( cCancProd, aCancItens, nCancQtde )
Local nI
Local lRet      := .F.
Local aItensAux := aClone(aItens)
Local nPos      := 0 
Local cCodProd  := ""
Local nColuna   := AIT_COD
Local aAreaSBI  := SBI->(GetArea())
Local aAreaAtu  := GetArea()

If !Empty(cCancProd)
	//Ordena o array pelo codigo do produto e item
	Asort(aItensAux,,,{ |x,y| UPPER(x[AIT_COD])+StrZero(x[AIT_ITEM],3) < UPPER(y[AIT_COD])+StrZero(y[AIT_ITEM],3)})
	
	//Verifica se o produto informado esta presente na venda
	nPos := aScan(aItensAux,{ |x| Trim(x[nColuna])=Trim(cCancProd)})
	If nPos == 0
		nColuna := AIT_CODBAR
		nPos    := aScan(aItensAux,{ |x| Trim(x[nColuna])=Trim(cCancProd)})
		cCodProd:= Iif(nPos>0,aItensAux[nPos][AIT_COD],cCodProd)
	Else
		cCodProd:= cCancProd
	EndIf  
	
	//Verifica se o produto eh um produto multiplo...	
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+cCodProd)
	If BI_MULT > 1
		lRet := .T.
	EndIf
	RestArea(aAreaSBI)
	RestArea(aAreaAtu)

	//Caso seja um produto multiplo verifica quais os itens 
	//que devem ser cancelados...		           
	If (nPos > 0) .AND. lRet
		aCancItens := {}
		nCancQtde  := 0
		For nI := nPos To Len(aItensAux)
			If !aItensAux[nI][AIT_CANCELADO]
				If (AllTrim(aItensAux[nI][nColuna]) == AllTrim(cCancProd))
					nCancQtde += aItensAux[nI][AIT_QUANT]
					AAdd(aCancItens,(aItensAux[nI][AIT_ITEM]))
				Else
					Exit
				EndIf
			EndIf
		Next nI          
	EndIf
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtMsgTela  ³ Autor ³ Vendas Clientes       ³ Data ³13/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar np array de 40 posicoes todas as linhas a ser impresso³±± 
±±³          ³  no rodape da  funcao fechameno do cupom fiscal bem como na  ³±± 
±±³          ³  tela do venda                                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtPesqMult(ExpC1)                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 => Mensagem a ser impressa                             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FrtMsgTela( cMensagem )
Local cLinha
Local aMsg	 := {}
Local nX        

If Empty(cMensagem)
   aadd(aMsg,space(40))
Else
  //( Trim(mensagem)<>'' )
  While !Empty(cMensagem)
      cLinha := ''
      // Laço para pegar 40 caracter do Texto
      For nX:= 1 to 40 
         // Caso encontre um CHR(10) (Line Feed) imprime a linha
         If Subs(cMensagem,nX,1) = Chr(10)  .OR. Subs(cMensagem,nX,1) = Chr(13)
            Exit
         Else
            cLinha +=Subs(cMensagem,nX,1)
         EndIf
      Next nX
      aadd(aMsg,Subs(cLinha+space(40),1,40))
      cMensagem := Subs(cMensagem,nX,Len(cMensagem))
      // As vezes os caracter de chr(10) vem antes do CHR(13) e vice versa
      If Subs(cMensagem,1,1) = Chr(10)  .OR. Subs(cMensagem,1,1) = Chr(13)
         cMensagem := Subs(cMensagem,2,Len(cMensagem))
      EndIf   
      If Subs(cMensagem,1,1) = Chr(10)  .OR. Subs(cMensagem,1,1) = Chr(13)
         cMensagem := Subs(cMensagem,2,Len(cMensagem))
      EndIf   
  End
EndIf  

Return aMsg
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRTTotVen    ³Autor ³Venda Clientes      ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Calcula o total da venda nas diversas moedas cadastrada no    ³±±
±±³          ³sistema e armazena os valores em array.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTTotVen()

Local nI    := 0       
Local nPosM := 0

For nI := 1 To Len(aTotVen)
	nPosM := aScan(aMoeda,{|x| Trim(x)==Trim(aTotVen[nI][02])})
	aTotVen[nI][3] := Round(xMoeda(nVlrTotal,nMoedaCor,nPosM,dDataBase,MsDecimais(nPosM)+1,nTaxaMoeda),MsDecimais(nPosM))
Next nI

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRTExibTotVen³Autor ³Venda Clientes      ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Exibe o total da venda nas diversas moedas cadastradas no     ³±±
±±³          ³sistema.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTExibTotVen()

Local nI        := 0
Local nPosMoeda := 0
Local nCont     := 0
Local nPos      := aScan(aTotVen,{|x| x[3]>0})            

If nPos > 0
	cMensagem := ""
	nPos      := If(aScan(aTotVen,{|x| x[4]})==0,1,aScan(aTotVen,{|x| x[4]}))            
	nCont     := If(nPos+1>Len(aTotVen),Len(aTotVen),nPos+1)
	For nI := nPos To nCont
		nPosMoeda := aScan(aMoeda,{|x| Trim(x)==Trim(aTotVen[nI][02])})
		cVlrTotal := Transform(aTotVen[nI][03],PesqPict("SL1","L1_VLRTOT",TAMSX3("L1_VLRTOT")[1],nPosMoeda))
		cMensagem += aMoeda[nPosMoeda]+Replicate(".",20-Len(aMoeda[nPosMoeda]))+": "+AllTrim(cVlrTotal)+Chr(13)  
	Next nI
	
	aTotVen[nPos][4] := .F.	
	If ((nPos+2) > Len(aTotVen))
		aTotVen[1][4] := .T.
	Else                          
		aTotVen[nPos+2][4] := .T.
	EndIf	
	oMensagem:oFont:= oFntMoeda
	oMensagem:Refresh()
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRTSimACols  ³Autor ³Venda Clientes      ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Simula o acols e aHeader para o calculo de impostos variaveis ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTSimACols( cProduto, nQuant, nPreco, cTes,;
                             cCF     , cItem , lDel  )
Local aAreaAtu := GetArea()
Local aAreaSX3 := {}
	
If Len(aHeader) == 0
	//Criar o aheader so com os campos necesarios para o calculo de impostos
	DbSelectArea("SX3")
	aAreaSX3 := GetArea()
	DbSetOrder(2)
	DbSeek("L2_PRODUTO")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	DbSeek("L2_TES")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	DbSeek("L2_CF")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	DbSeek("L2_QUANT")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	DbSeek("L2_VRUNIT")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	DbSeek("L2_VLRITEM")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } ) 
	DbSeek("L2_ITEM")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } ) 
	DbSeek("L2_DESCPRO")
	AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
					X3_TAMANHO, X3_DECIMAL, X3_VALID,;
					X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
					X3_CONTEXT } )
	If DbSeek("L2_NIT")
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
						X3_TAMANHO, X3_DECIMAL, X3_VALID,;
						X3_USADO  , X3_TIPO   , X3_ARQUIVO,;
						X3_CONTEXT } )
	Endif
	RestArea(aAreaSX3)
Endif
	
AAdd(aCols,Array(Len(aHeader)+1))
aCols[Len(aCols)][1]	:=	cProduto
aCols[Len(aCols)][2]	:=	cTes
aCols[Len(aCols)][3]	:=	SF4->F4_CF
aCols[Len(aCols)][4]	:=	nQuant
aCols[Len(aCols)][5]	:=	nPreco
aCols[Len(aCols)][6]	:=	nQuant * nPreco 
aCols[Len(aCols)][7]	:=	cItem 
aCols[Len(aCols)][8]	:=	0
If Len(aCols[Len(aCols)]) > 8
	aCols[Len(aCols)][9]	:=	""
EndIf
aCols[Len(aCols)][Len(aHeader)+1]	:=	If(lDel <> Nil,lDel,.F.)

RestArea(aAreaAtu)
	
Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRTCDescLoc  ³Autor ³Venda Clientes      ³ Data ³  15/08/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Realiza o calculo do desconto no total da venda - Localicoes  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRTCDescLoc(ExpN1,ExpN2,ExpN3)                               ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 => Valor do desconto                                   ³±±  
±±³          ³ ExpN2 => Percentual de desconto                              ³±± 
±±³          ³ ExpN3 => Percentual de acrescimo                             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTCDescLoc( nValorDesc, nPercDesc, nTmpJuros, nTmpDesc )

Local aImpAnt    := {}
Local aImposto   := {}
Local aProdSL2   := {}
Local aSL2       := {}
Local nSomPerVen := 0
Local nPerVend   := 0
Local nDescProIt := 0
Local nVlrTotIT  := 0
Local nVlrTotUN  := 0 
Local nX		 := 0
Local nI		 := 0
Local nE		 := 0
Local nLin		 := 0
Local nK		 := 0
Local nValImp	 := 0
Local nTotImp	 := 0
Local cCampoVal  := ""
Local cCampoAlq	 := ""
Local cIndImp	 := ""
Local nQtde      := 0
Local nVlrUnitIt := 0
Local lTemImps   := .F.
	                                                         
//Eh utilizado o array aImpsProd pois ele possui as informacoes
//originais sem acrescimo ou desconto.
aImpAnt := If(cItemCond == "CN" .AND. !lCondNegF5,aClone(aImpsProd),aClone(aImpsSL2))
If (nTmpJuros > 0) .OR. (nTmpDesc > 0)
	If cItemCond == "CN" .AND. !lCondNegF5
		For nX := 1 To Len(aCols)
			If !aCols[nX][Len(aHeader)+1]
				nPos := aScan(aImpAnt,{|x| Trim(x[01])==Trim(aCols[nX][01])})
				For nK := 1 To Len(aImpAnt[nPos][03])
					aImpAnt[nPos][03][nK][03] := aCols[nX][06] 
					aImpAnt[nPos][03][nK][12] := aCols[nX][05]
				Next nK
			EndIf
		Next nX
	Else                                                              
		//Aplica o acrescimo no total da mercadoria
		If nTmpJuros > 0
			nVlrMerc += aDadosJur[1]
		EndIf
		
		//Aplica o desconto financeiro no total da mercadoria
		If nTmpDesc > 0
			nVlrMerc -= aDadosJur[9]
		EndIf
	EndIf
EndIf 

//Inicializa os arrays para o recalculo dos impostos...
aImpsSL1 := {}
aImpsSL2 := {}
aCols    := {}	
aSL2     := {}
nVlrTotal:= 0 
nVlrBruto:= 0                                         

//Realiza o calculo do desconto e o recalculo dos impostos...
For nX := 1 To Len(aImpAnt)   
    nQtde        := aImpAnt[nX][6]
	nVlrUnitIt   := aImpAnt[nX][7]

	If !aImpAnt[nX][5] 
		lRecalImp:= .T. //Determina que ocorreu calculo de desconto...
		aProdSL2 := {}
		aImps    := {}
		
		//Armazena o valor unitario original, para calculo do imposto
		nVlrTotUN := Round(nQtde * nVlrUnitIt,nDecimais)
		
		//Verifica quanto esse item corresponde no total da venda
		nPerVend := ((nQtde * nVlrUnitIt) * 100) / nVlrMerc
		//Realiza esse calculo para evitar que o desconto nao seja dado na
		//sua totalidade
		nSomPerVen += nPerVend
		If nX == Len(aImpAnt) .AND. nSomPerVen <> 100
			nPerVend += Iif(nSomPerVen < 100,(100-nSomPerVen),-1*(nSomPerVen-100))
		EndIf
		  
		//Calcula a proporcao do desconto	                        
		nDescProIt := Round((nValorDesc * nPerVend) / 100,nDecimais)

		//Calcula o novo valor do item
		nVlrTotIT := Round((nQtde * nVlrUnitIt) - nDescProIt,nDecimais)

		//Calcula o novo valor unitario considerando o desconto proporcional
        nVlrUnitIt  := Round(nVlrUnitIt - (nDescProIt / nQtde),nDecimais)
        If lTemImps
		   aImpAnt[nX][3][1][12] := nVlrUnitIt
        EndIf
        
		//Acumula o valor total
		nVlrTotal += nVlrTotIT
		nVlrBruto := nVlrTotal
	
		MaFisIni(	SA1->A1_COD	,	SA1->A1_LOJA	,	"C"	, 	"S"	,;
				 	SA1->A1_TIPO,	NIL				,	NIL	, 	.F.	,;
				 	"SBI"		,	NIL				,	"01",	NIL	,;
				 	NIL			,	NIL				,	NIL	,	NIL	,;
				 	NIL			,	NIL				,	.F.	)
		MaFisAdd(aImpAnt[nX][1], aImpAnt[nX][2], nQtde, nVlrTotUN, 0 , "", "", nil, 0, 0, 0, 0, nVlrTotIT, 0)
		aImps := TesImpInf(aImpAnt[nX][2])
		Aadd(aImpsSL2,{aImpAnt[nX][1],aImpAnt[nX][2],{}})
		For nI := 1 to Len(aImps)                                                 
			If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
				Aadd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
			    nE := Len(aImpsSL1)
			EndIf   
			cIndImp     := Substr(aImps[nI][2],10,1)               
			cCampoVal   := "IT_VALIV"+cIndImp		    
			cCampoAlq   := "IT_ALIQIV"+cIndImp	 
			nValImp     := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
			FRTGeraImp(@aImposto,aImps[nI],nValImp,aImpAnt[nX][3][1][11],aImpAnt[nX][3][1][12],1,cIndImp)			   
			AAdd(aImpsSL2[len(aImpsSL2)][3],aClone(aImposto))
			nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
			aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
			aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
		Next nI         
		MaFisEnd() 
		
		Aadd(aImpsSL2[Len(aImpsSL2)],aImpAnt[nX][4])
		Aadd(aImpsSL2[Len(aImpsSL2)],.F.)	
		Aadd(aImpsSL2[Len(aImpsSL2)],aImpAnt[nX][6])
		Aadd(aImpsSL2[Len(aImpsSL2)],nVlrUnitIt)			
		aProdSL2 := {	{"L2_VRUNIT" , nVlrUnitIt},;
		             	{"L2_VLRITEM", nVlrTotIT},;
						{"L2_DESCPRO", nDescProIt},;
						{"L2_ITEM"   , aImpAnt[nX][4]}}
	
		nLin := Len(aImpsSL2)
		For nK := 1 to Len(aImpsSL2[nLin][3])
			Aadd(aProdSL2,{aImpsSL2[nLin][3][nK][6],aImpsSL2[nLin][3][nK][4]})   //Valor do imposto
	        Aadd(aProdSL2,{aImpsSL2[nLin][3][nK][7],aImpsSL2[nLin][3][nK][3]})   //Base do imposto         
	        Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nLin][3][nK][7],10,1),aImpsSL2[nLin][3][nK][2]})   //Aliquota do imposto                           
	    Next nK                     
	    
		AAdd(aSL2,aClone(aProdSL2))
		FRTSimACols(aImpAnt[nX][1], nQtde, nVlrUnitIt,;
		            aImpAnt[nX][2], "", aImpAnt[nX][4])
	Else       
		//Eh criado aCols e aImpsSL2 com o item deletado para que permanecam
		//do tamanho original..
		Aadd(aImpsSL2, aClone(aImpAnt[nX]) )	
		FRTSimACols(aImpAnt[nX][1], nQtde, nVlrUnitIt,;
		            aImpAnt[nX][2], "", aImpAnt[nX][4], .T.)
	EndIf
Next nX	                          

nVlrTotal := Round(nVlrTotal + nTotImp,nDecimais)

//Acerta o valor total bruto e o valor total da mercadoria...
nVlrBruto := nVlrTotal
nVlrMerc  := (nVlrTotal-nTotImp)

//Funcao para atulizar o arquivo SL2 -  Localizacoes
FRTGravaSL2(aSL2)

oVlrTotal:Refresh()
			
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTChkBMP³ Autor ³ Vendas Clientes       ³ Data ³18/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se as imagens FRONT, LOJAWIN e SEMFOTO estao no   ³±±
±±³          ³ repositorio de imagens                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTChkBMP( oDlg )
Local oBMP
Local nI 	   := 0		//variavel do loop
Local lFront   :=.F.
Local lSemFoto :=.F.
Local lLojaWin :=.F.

@ 0,0 REPOSITORY oBMP SIZE 1,1 OF oDlg
For nI := 1 To oBMP:RecordCount()
	If AllTrim(oBMP:EntryName(nI)) == "LOGOFRONT"
		lFront := .T.
	ElseIf AllTrim(oBMP:EntryName(nI)) == "SEMFOTO"
		lSemFoto := .T.
	ElseIf AllTrim(oBMP:EntryName(nI)) == "LOJAWIN"
		lLojaWin := .T.
	EndIf
Next nI
If !lFront
	If File("logofront.jpg")
		oBMP:InsertBMP("logofront.jpg")
	EndIf
EndIf
If !lSemFoto
	If File("semfoto.jpg")
		oBMP:InsertBMP("semfoto.jpg")
	EndIf
EndIf
If !lLojaWin
	If File("lojawin.jpg")
		oBMP:InsertBMP("lojawin.jpg")
	EndIf
EndIf   

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTRecebe³ Autor ³ Vendas Clientes       ³ Data ³07/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a chamada a funcao de Recebimentos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem TEF pendente no SITEF.             ³±±
±±³          ³ ExpA1 - Guarda a transacao TEF Pendente					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTReceb( lTefPendCS, aTefBKPCS )
Local nI 		   := 0				 //	variavel do loop
Local lTEFPendRec  := .F.   // Controla se tem transacao TEF jah realizada e pendente 
Local lTefMult	   := SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local aRecTEFMult  := {}
Local nEspaco	   := 0									// Espaco entre o prefixo e o titulo no cupom exibido na tela

Private aTitulo
Private lConfLJRec := .F.
Private aPgtos     := {}
Private aParcelas  := {}
Private aTitImp 			// declaracao do array responsavel por armazenar as informacoes necessarias para a impressao do recebimento nao fiscal - LJGRVREC
Private cTotRecNFis 		// declaracao da variavel a ser utilizada na impressao do recebimento nao fiscal - LJGRVREC

If !lOcioso .OR. lRecebe
	Return(NIL)
EndIf

aTitulo := LJReceb()      

If aTitulo[1] <> 0
	lRecebe 	:=  .T.
    nVlrTotal 	:= 0
    
	oCupom:SetArray( {	"", "", "", "", ;
						"", "", "", "", ;
						"", "", "", "", ;
						"", "", "", "", ;
						"", "" } )
	
	If ExistBlock("FRTCLICHE")
		aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
		AEval(aFRTCliche, {|x| oCupom:Add(Left(x,40))})
	Else
		oCupom:Add("")
		oCupom:Add(STR0027)	// "        MICROSIGA SOFTWARE S.A.         "
		oCupom:Add(STR0028)	// "    Av. Braz Leme, 1631 - São Paulo     "
		oCupom:Add(STR0029)	// "          www.microsiga.com.br          "
	EndIf
	
	oCupom:Add(DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+StrZero(Val(cDoc)+1,TamSX3("L1_DOC")[1]))	// "  PDV:" "   COD:"
	oCupom:Add(FRT_SEPARATOR)
	oCupom:Add(STR0229)	// "          R E C E B I M E N T O         "
	oCupom:Add(FRT_SEPARATOR)
	oCupom:Add("")
	oCupom:Add(FRT_SEPARATOR)
	
	nEspaco := ( 6 - (TamSx3("E1_NUM")[1] - 6 ))
	
	For nI := 1 To Len(aTitulo[2])
		If aTitulo[2][nI][1]
			oCupom:Add(STR0230)		// "Prefixo  Titulo     Parcela   Vencimento"
			oCupom:Add(aTitulo[2][nI][2]+Space(6)+aTitulo[2][nI][3]+Space(8)+aTitulo[2][nI][4]+Space(6-nEspaco)+DToC(aTitulo[2][nI][5]))
			oCupom:Add(STR0231+Transform(aTitulo[2][nI][ 6], PesqPict("SE1", "E1_VALOR", 15)))	// "   Valor          = "
			oCupom:Add(STR0232+Transform(aTitulo[2][nI][ 7], PesqPict("SE1", "E1_MULTA", 15)))	// "   Multa          + "
			oCupom:Add(STR0233+Transform(aTitulo[2][nI][ 8], PesqPict("SE1", "E1_JUROS", 15)))	// "   Juros          + "
			oCupom:Add(STR0234+Transform(aTitulo[2][nI][ 9], PesqPict("SE1", "E1_DESCONT", 15)))	// "   Desconto       - "
			oCupom:Add(STR0235+Transform(aTitulo[2][nI][10], PesqPict("SE1", "E1_VALOR", 15)))	// "   Valor Recebido = "
			oCupom:Add(FRT_SEPARATOR)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena o valor recebido em nVlrTotal para permitir o pagamento parcial do título³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrTotal += aTitulo[2][nI][10]
			
		EndIf
	Next nI
	nVlrBruto 	:= nVlrTotal
	
	aParcOrc 	:= {}
	aParcOrcOld := {}

	nVlrDescTot	:= 0														// VALOR DO DESCONTO
	nVlrPercTot	:= 0														// PERCENTUAL DE DESCONTO
	nVlrAcreTot	:= 0														// VALOR DO ACRESCIMO
	nVlrPercAcr := 0														// PERCENTUAL DO ACRESCIMO
	nVlrDescCPg	:= 0														// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)

	oVlrTotal:Refresh()

	aKeyFimVenda := FrtSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declara o conteudo vazio ao array para o uso na impressao do recebimento nao fiscal.³
	//³O array será devidamente preenchido na função FRTEncerra                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aTitImp       := {}                                        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declara o conteudo da variavel para o uso na impressao do recebimento nao fiscal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTotRecNFis   := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI") 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a função para finalização da venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPgtos := FRTFimVend( @lTEFPendRec, @aRecTEFMult, Nil, @lTefPendCS, @aTefBKPCS )

	If lConfLJRec
	    If lTefMult .AND. LEN(aRecTEFMult) > 0
	       aTEFMult  := AClone(aRecTEFMult)
	    EndIf
		If !LJGrvRec( aPgtos   ,lTEFPendRec  ,aBckTEFMult  , lVerTEFPend )
			oCupom:Add(" ") 
			oCupom:Add(STR0323)   //"Recebimento não efetuado."
			oCupom:Add(STR0324)   //"O servidor está fora do ar."
			oCupom:Add(" ") 
			oCupom:Add(FRT_SEPARATOR)
			oCupom:GoBottom()
		Endif
		aBckTEFMult  := {}
		lVerTEFPend  := .F.
	EndIf	
EndIf

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTVLDDTA³ Autor ³ Vendas Clientes       ³ Data ³03/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a data do Cheque para permitir pagamentos a vista   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTVLDDTA( dData )
Local nRange := SuperGetMV("MV_LJCHVST", ,-1)
Local lRet   := .T.

If nRange >= 0 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento do cheque a vista                                     ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ Um cheque eh considerado a vista quando:                               ³
	//³             Data do cheque < dDataBase + SuperGetMV("MV_LJCHVST)            ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ Se o conteudo do parametro for -1, entao ele nao devera ser considerado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dData >= dDataBase+nRange
		MsgStop(STR0252)	//"Data acima do intervalo permitido."
		lRet := .F.
	Endif
Endif

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³FRTA010A  ºAutora ³Venda Clientes      º Data ³  03/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa tem por objetivo efetuar as chamadas de fun- º±±
±±º          ³ ções estáticas, evitando warnings na compilação:           º±±
±±º          ³ W0010 Statict Function never called                        º±±
±±º          ³ Normalmente este problema acontece qdo as chamadas são     º±±
±±º          ³ provenientes de macros.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA010A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function __FRTA010A()
FRTrcMoeda()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FrtAddLine³ Autor ³ Vendas Clientes       ³ Data ³22/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a impressao visual do cupom das funcoes do Front.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTAddLine( cText, nNumLines, cPicture )
Local nNumPgdn := 16 // Define com quantas linhas poderá ser realizado um PGDN para selecinar uma opcao
Local cGet     := Space(3)

oCupom:Add(cText)
nNumLines += 1

If nNumLines == nNumPgdn
	oCupom:Add(STR0253)	//"Tecle <ENTER> para continuar..."
	FRTGet(@cGet, cPicture, @lEsc)
	nNumLines := 0
	oCupom:Del(Len(oCupom:aItems))
EndIf

Return cGet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTTefDig ³Autora ³Venda Clientes         ³ Data ³28/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe uma tela para que o usuário digite os 4 ultimos      ³±±
±±|          | digitos do cartao, pois nas multiplas transacoes Tef       ³±±
±±|          | precisaremos diferenciá-los                                ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTTefDig( aPgtos )
Local nParcelas		:= Len(aPgtos)											// Quantidade de Parcelas do aPgtos
Local nCont			:= 0													// Contador do laço For
Local aHeadDig		:= {}													// Cabeçalho da Identificação
Local aColsDig		:= {}			                                        // Itens da digitação
Local aCampAlt      := {"DIG"}												// Campos a serema alterados no aColsDig
Local oFontMens		:= TFont():New( "Arial",06,14,,.T.)						// Fonte da mensagem de alerta

Private oDlgTefDig

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿ 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aPgtos      ³ 	//³aColsDig                 ³
//³1 - Data    ³ 	//|1 - Indice da aPgtos     |
//³2 - Valor   ³	//|2 - Data                 |
//³3 - Forma   ³	//³3 - Valor                ³
//³4 - cAdm    ³	//³4 - Condicao de Pagamento³
//³...         ³	//³5 - Administradora       ³
//³12 - Digitos³	//³6 - Digitos              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ	//|7 - Indicador de Delecao |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nParcelas > 0 .AND. Ascan( aPgtos , {|x| x[3] $ _FORMATEF } ) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criando estrutura do aHeadDig ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aHeadDig,{"Cod.   ","IND","99"   			   ,2  				 		,0,".T.","û","N","","V",NIL})
	Aadd(aHeadDig,{"Data   ","DAT","@D"   			   ,TamSx3("L4_DATA")[1]	,0,".T.","û","D","","V",NIL})
	Aadd(aHeadDig,{"Valor  ","VAL","@E 99,999.99" 	   ,9  						,2,".T.","û","C","","V",NIL})
	Aadd(aHeadDig,{"Cond.  ","CON","@!"   			   ,2  				 		,0,".T.","û","C","","V",NIL})
	Aadd(aHeadDig,{"ADM    ","ADM","@!"   			   ,TamSx3("AE_DESC")[1]+10	,0,".T.","û","C","","V",NIL})
	Aadd(aHeadDig,{"Dígitos","DIG","9999" 			   ,4  				 		,0,".T.","û","C","","V",NIL})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carregando Dados do aPgtos   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To nParcelas
		If aPgtos[nCont][3] $ _FORMATEF
			Aadd(aColsDig,{nCont,aPgtos[nCont][1],aPgtos[nCont][2],aPgtos[nCont][3],aPgtos[nCont][4],aPgtos[nCont][12],.F.})
		EndIf
	Next nCont
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definindo a Tela dos Digitos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE DIALOG oDlgTefDig TITLE STR0280 FROM 15,0 TO 26,76 STYLE DS_MODALFRAME 	//"Identifique os Cartões para a Múltipla-Transação TEF"
	oGet:=MsNewGetDados():New(001,001,065,300,GD_INSERT+GD_UPDATE,/*[cLinhaOk]*/,/*[cTudoOk]*/,/*[cIniCpos]*/,aCampAlt,/*[lVazio]*/,Len(aColsDig),/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgTefDig,aHeadDig,aColsDig)
	@ 067,005 SAY STR0281 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 		//"Informe os 4 ultimos digitos de cada cartäo a ser diferenciado."
	@ 074,005 SAY STR0284 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 		//"Parcelas com dígitos em branco serão consideradas em um mesmo cartão!"
	oGet:oBrowse:nFreeze:=5
	
	DEFINE SBUTTON FROM 068,242 TYPE 1 ENABLE OF oDlgTefDig ACTION (Iif(FRTConfDig(1),oDlgTefDig:End(),NIL)) PIXEL
	DEFINE SBUTTON FROM 068,272 TYPE 2 ENABLE OF oDlgTefDig ACTION (Iif(FRTConfDig(2),oDlgTefDig:End(),NIL)) PIXEL
	
	ACTIVATE DIALOG oDlgTefDig CENTERED
	
EndIf

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTConfDig³Autora ³Venda Clientes         ³ Data ³28/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confere se o usuário digitou todos os dígitos dos cartões  ³±±
±±|          | para efetuar a multipla transacao TEF                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTConfDig( nBotao )
Local lRet  := .F.        										// Retorno da funcao
Local nCont := 0												// Contador do laço

If nBotao = 1 								      				// Siginifica que o usuário teclou OK
	If Ascan( oGet:aCols , {|x| !Empty(x[6]) .AND. Len(Alltrim(x[6]))<4} ) > 0   	// Verifica se foram informados os 4 últimos dígitos
		MsgAlert(STR0282) //"Verifique se os digitos informados säo compostos por 4 numeros!"
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Vou atualizar a array aPgtos com os 4 digitos do cartao           ³
	//³desta forma na transacao Tef os dados serao agrupados corretamente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		nDig:=Len(oGet:aCols)
		For nCont := 1 To nDig
			aPgtos[oGet:aCols[nCont][1]][12]:=oGet:aCols[nCont][6]
		Next nCont
	EndIf
Else 													// Significa que o usuário cancelou a operação
	lRet := MsgNoYes(STR0283) //"Ao efetuar o cancelamento desta operacäo as parcelas de uma mesma ADM seräo consideradas em um unico cartäo. Tem certeza que deseja abandonar a digitacäo?"
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FRTefConfAdm³ Autor ³ Vendas Clientes     ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a descricao da adiministrado de cartos em uma     ³±±
±±³          ³ transacao TEF, qdo selecionada uma ADM <> da utilizada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FRTA010A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTefConfAdm( cAdmUti, cAdmRet )
Local aArea   := GetArea()											//Area atual de trabalho
Local nTamSX3 := TamSX3("L4_ADMINIS")[1]							//Tamanho do campo no X3
Local cAdmVer := cAdmUti											//Administradora a ser gravada no SL4
Local nPos	  := At(" - ",cAdmUti) + 3								//Inicio do posicionamento da desc. da Adm
Local lAchou  := .F.

cAdmVer := Alltrim(Upper(Substr(cAdmUti,nPos,nTamSX3-nPos)))		//Adm digitada pelo operador e tratada para a retirada do codigo
cAdmRet := Alltrim(Upper(cAdmRet))									//Adm identificada pela transacao TEF

If cAdmVer <> cAdmRet
	DbSelectArea("SAE")
	DbGoTop()
	While !Eof() .AND. AE_FILIAL == xFilial("SAE")
		If cAdmRet == Alltrim(Upper(SAE->AE_DESC))
			cAdmVer := SAE->AE_COD + " - " + Alltrim(Upper(SAE->AE_DESC))
			lAchou  := .T.
			Exit
		EndIf
		DbSkip()
	End
EndIf                     
If !lAchou
	cAdmVer := cAdmUti
EndIf

RestArea(aArea)

Return(cAdmVer)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FrtMontPgt³ Autor ³ Vendas Clientes       ³ Data ³ 18/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prepara a array sintetizada para exibição                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA701                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FrtMontPgt( aParc )
Local nFor 	 		:= 0
Local cCond  		:= ""
Local nValor 		:= 0
Local nParc	 		:= 0
Local cFormaId 		:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))
Local nPos	 		:= 0
Local aParcSint		:= {}
Local aSequencia	:= {}
Local cSimbMoeda	:= AllTrim(SuperGetMV("MV_SIMB1"))

DEFAULT aParc	  	:= {}				//Array para com as parcelas a sintetizar

If Len(aParc) > 0
	For nFor := 1 To Len(aParc)
		If (Alltrim(cCond) <> Alltrim(aParc[nFor][3])) .OR. ;
		   (Alltrim(cCond) == Alltrim(aParc[nFor][3])  .AND. Alltrim(aParc[nFor][12]) <> Alltrim(cFormaId) )
		    cCond  		:= Alltrim(aParc[nFor][3])
		    nValor 		:= aParc[nFor][2]
		    nParc  		:= 1
   		    cFormaId 	:= aParc[nFor][12]
	
	    	Aadd( aParcSint , { cCond , nParc , TransForm(nValor,PesqPict("SL4","L4_VALOR",,nMoedaCor)) , cFormaId, aParc[nFor][1], {}  } )
		Else
			nValor 	+= aParc[nFor][2]
			nParc  	+= 1
			nPos	:= Ascan(aParcSint, { |x| ( Alltrim(x[1]) == cCond .AND. Alltrim(x[4]) == Alltrim(cFormaId) ) })
						
			aParcSint[nPos][3]	:= TransForm(nValor,PesqPict("SL4","L4_VALOR",,nMoedaCor))
			aParcSint[nPos][2]  := nParc
		EndIf
    	Aadd( aSequencia , {nFor , cCond , nValor, cFormaId} )
	Next nFor

	//Atualizando a sequencia para a array apgtos
	For nFor := 1 To Len(aPgtos)
		nPos := Ascan(aSequencia,{|x| x[1] == nFor})
		If nPos > 0
			aPgtos[nFor][12] := aSequencia[nPos][4]
		EndIf
	Next nFor
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se tem TEF pendente, se tiver não organiza por data  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTEF .AND. cTipTEF == TEF_CLISITEF 
	If !File(GetClientDir() + "CLISITEF."+StrZero(oTEF:nIDTermina,3))
		aSort( aParcSint,,, {|x,y| Dtos(x[5])+x[1]+x[4] < Dtos(y[5])+y[1]+y[4] } ) //Data + Cond + Seq.
	EndIf	
Else
	aSort( aParcSint,,, {|x,y| Dtos(x[5])+x[1]+x[4] < Dtos(y[5])+y[1]+y[4] } ) //Data + Cond + Seq.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Forma $ sempre sera a primeira!!!  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := Ascan(aParcSint, {|x| x[1] == cSimbMoeda})) > 1
	aAdd(aParcSint,{})
	aIns(aParcSint,1)
	nPos++
	aParcSint[1] := aParcSint[nPos]
	aDel(aParcSint, nPos)
	aSize(aParcSint,Len(aParcSint)-1)
EndIf

Return(aParcSint)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FrtAltPgSiºAutor  ³Venda Clientes      º Data ³  10/18/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara a array apgtos para ser tratada a partir de uma novaº±±
±±º          ³tela, pois na principal será exibida a Sintetizada.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtAltPgSi( nLinha, lAltParc, aFormPagF5, oFimVenda, ;
					 aTefBKPCS )
Local lContinua	  := .T.							//Laço para o controle da abertura de tela
Local lConfirma   := .F.							//Indica se o operador confirmou a alteração das parcelas
Local nPos		  := 0								//Identifica a posição da informação na Array
Local lTefMult	  := SuperGetMV("MV_TEFMULT", ,.F.)//Identifica se o cliente utiliza múltiplas transações TEF
Local oDlgPgtoSin									//Objeto para tratamento da janela   
Local aKey												// Chave
Local lVerEmpres  := Lj950Acres(SM0->M0_CGC)		// Verifica as filiais da trabalharam com acrescimento separado

Private oPgtosAna									//Cópia do Objeto oPgtos que será aberto em outra tela

DEFAULT nLinha 	  := 0

aKey := FRTSetKey()          
          
While lContinua

	lConfirma := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria interface com o usuario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPgtoSin TITLE STR0292 FROM 0,0 TO 16,52 OF oDlgFrt //"Detalhes da Forma de Pagamento"
	
	DEFINE SBUTTON FROM 107,175	TYPE 1 ACTION (lConfirma := .T. , oDlgPgtoSin:End()) ENABLE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os comandos abaixo foram colocados devido a um erro no ADVPL.          ³
	//³ "Preprocessor Table Overflow". Foi suprimido o Include do TCBROWSE.CH. ³
	//³ Os comandos originais devem ser mantidos para manutencao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPgtosAna:=TCBrowse():New(3, 3, 200, 100,,,,,,,,,;
				{|nRow,nCol,nFlags|If(lAltParc,(If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),;
				FRT010Par(nVlrTotal),LojxDin( aFormPagF5	, nVlrTotal 	, NIL 			, 0 			,;
												0			, oFimVenda		, .F.			,nVlrTotal		,;
												NIL			, NIL 			, NIL 			, NIL 			,;
												NIL			, @oPgtos		, @aPgtos		, @oPgtosAna	,;
												@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
												@cSimbCheq	, @nValorBase	, @nTaxaMoeda	, cCliente		,;
												cLojaCli 	, NIL			, oDlgFrt		, aTefBKPCS )),;
				oPgtosAna:Refresh()),)},,,,,,, .F.,, .T.,, .F., )
	oPgtosAna:SetArray( aPgtos )

	nPos := Ascan(aPgtos, { |x| ( Alltrim(x[3]) == Alltrim(aPgtosSint[oPgtosSint:nAt][1]) .AND. Alltrim(x[12]) == Alltrim(aPgtosSint[oPgtosSint:nAt][4]) ) })
	oPgtosAna:nAt := Iif(nPos>0,nPos,1)
	oPgtosAna:Refresh()
	oPgtosAna:SetFocus()

	oPgtosAna:AddColumn(TCColumn():New(STR0073, {|| aPgtos[oPgtosAna:nAt,1]},,,,"LEFT",25,.F.,.F.,,,,.F.,) )  												//"Data"
	oPgtosAna:AddColumn(TCColumn():New(STR0075, {|| aPgtos[oPgtosAna:nAt,3]+IIf((ALLTRIM(aPgtos[oPgtosAna:nAt,3])<>cSimbCheq) .AND. (ValType(aPgtos[oPgtosAna:nAt,4])=="C"),Substr(aPgtos[oPgtosAna:nAt,4],4),'')},,,,"LEFT",60,.F.,.F.,,,, .F.,) )  			//"Forma de Pagamento"
	oPgtosAna:AddColumn(TCColumn():New(STR0074, {|| Transform(aPgtos[oPgtosAna:nAt,2],PesqPict("SL4","L4_VALOR",15))},,,,"RIGHT",50,.F., .F.,,,, .F., ) )  	//"Valor"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibir o valor do acrescimo separado da parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lVerEmpres
		//"Acrs.Fin"
		oPgtosAna:AddColumn(TCColumn():New(STR0314,{|| If(Len(aPgtos)>=oPgtosAna:nAt,Transform(aPgtos[oPgtosAna:nAt,13],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  //"Acrescimo"	
	Endif
	
	//Só exibir o ID para múltiplas transações TEF
	If lUsaTef .AND. lTefMult
	   oPgtosAna:AddColumn(TCColumn():New(STR0288, {|| aPgtos[oPgtosAna:nAt,12]},,,,"RIGHT",30,.F.,.F.,,,,.F., ) ) //"ID Cartão"
	EndIf

	ACTIVATE MSDIALOG oDlgPgtoSin CENTERED
	
	If lConfirma
		aPgtosSint:=FrtMontPgt(aPgtos)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
		lContinua := .F.
	Endif
End

FRTSetKey(aKey)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FrtValidIdºAutora ³Venda Clientes      º Data ³  11/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o dígito informado é correto para o controle de  º±±
±±º          ³ múltiplos cartões                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Static Function FrtValidID( cForma, cFormaID )
Local lRet 	 := .T.

If Empty(cFormaId)
	MsgAlert(STR0289,STR0003) //"Informe o ID do Cartão para a operação TEF.","Atenção"
	lRet := .F.
ElseIf Ascan( aPgtos, {|x| Alltrim(x[3])==cForma .AND. Alltrim(x[12])==Alltrim(cFormaID) } ) > 0 
	MsgAlert(STR0290,STR0003) //"Cartão já informado para a operação TEF, utilize uma nova identificação.","Atenção")
	lRet := .F.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FRTCMPP   ºAutor  ³Venda Clientes      º Data ³  14/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica todos os campos que sao de usuario                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ax3: Array com os dados do aSl1 ou aSl2                    º±±
±±º          ³ cCAlias: Alias definindo se e o SL1 ou SL2 utilizado       º±±
±±º          ³ cOrc: String com as informacoes do orcamento               º±±
±±º          ³ nNumItem: Numero do item caso seja o alias SL2             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	FRTCmpP( ax3, cCAlias, cOrc, nNumItem )

Local aArea := GetArea()                    // Area atual

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cCAlias)
While !Eof() .AND. X3_ARQUIVO == cCAlias
	If x3Uso(X3_USADO) .AND. cNivel >= x3_nivel
		If X3_PROPRI == "U"
			If nNumItem > 0
				Aadd(ax3,{X3_CAMPO, FRTAField(cOrc, X3_CAMPO,nNumItem)})
			Else
				Aadd(ax3,{X3_CAMPO, FRTAField(cOrc, X3_CAMPO)})
			Endif
		Endif
	Endif
	dbSkip()
End
RestArea(aArea)

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTSeekPar³Autor  ³Venda Clientes         ³ Data ³01/11/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca no array aParcTEF a parcela que corresponde a parcela ³±±
±±|          |passada como parametro. Valida pela forma de pagamento e ID ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN3 := FRTSeekParc( ExpN1, ExpA2 )                        ³±±
±±³			 ³ExpN1 - Indice da parcela gravada no array ExpA2            ³±±
±±³			 ³ExpA2 - Array onde esta gravada a chave(forma de pagto.+ID) ³±±
±±³			 ³de busca													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpN3 - Posicao da chave solicitada no array aParcTEF       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTSeekParc( nX  ,aTEF )

Local nRet        := 0                   // Retorno da funcao com o indice da parcela no array aParcTEF
Local cMoeda      := ""                 // Forma de pagamento 
Local cAdm        := ""                 // Codigo da adminstradora financeira

If LEN(aTEF) >= nX
   cMoeda      := ALLTRIM(aTEF[nX][1])
   cAdm        := ALLTRIM(aTEF[nX][2])   
   If cMoeda==AllTrim(MVCHEQUE)
      // Banco+Agencia+Conta   
      nRet   := Ascan(aParcTEF,{|x| ALLTRIM(x[3]) == cMoeda .AND. ALLTRIM(x[5])+ALLTRIM(x[6])+ALLTRIM(x[7]) == ALLTRIM(UPPER(cAdm))})   
   Else
      If lVisuSint
	     // ID Cartao+Administradora	      					      
	     nRet   := Ascan(aParcTEF,{|x| ALLTRIM(x[3])==cMoeda .AND. ;
	               ALLTRIM(x[6])+SPACE(4-LEN(ALLTRIM(x[6])))+' - '+ALLTRIM(SUBSTR(x[4],7)) == ALLTRIM(UPPER(cAdm))})      
      Else
   	     // Digitos do Cartao+Administradora	  
	     nRet   := Ascan(aParcTEF,{|x| ALLTRIM(x[3])==cMoeda .AND. ;
	               STRZERO(VAL(x[6]),4)+' - '+ALLTRIM(SUBSTR(x[4],7))==ALLTRIM(UPPER(cAdm))})	  
      EndIf						
   EndIf
EndIf

Return (nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTNovoPgt³Autor  ³Venda Clientes         ³ Data ³01/11/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Permitir a selecao de outra forma de pagamento quando uma   ³±±
±±|          |transacao TEF nao eh aprovada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³FRTNovoPgto( ExpN1, ExpO2 )		                          ³±±
±±³			 ³ExpN1 - posicao da parcela a ser modificada				  ³±±
±±³			 ³ExpO2 - objeto da tela de finalizacao da venda			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTNovoPgto( nPosParcelas  ,oFimVenda )            

Local nCtrl         := 0     	// Controla a re-ordenacao do array aParcelas com forma de pagto Dinheiro em primeiro e ajuste do array aFormCtrl
Local nX            := 0     	// Controle de loop
Local nY            := 0     	// Controle de loop
Local nPosParc      := 0     	// Posicao da parcela para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local nCount        := 0     	// Contador de parcelas de mesma forma de pagamento / Contador das parcelas excluidas do aFormCtrl
Local nOpca         := 2     	// Opcao selecionada na tela de agrupamento de parcelas
Local nIntervalo    := SuperGetMV("MV_LJINTER")  //Intervalo padrao entre as parcelas
Local cMoeda        := ""    	// Forma de pagamento para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local cAdm          := ""    	// Administradora financeira para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local cFormaID		:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))   //ID de identificacao do cartao
Local cFormaIDCtrl  := cFormaID //ID de identificacao do cartao para busca no array aFormCtrl
Local cFormaAtu     := ""    	// Forma de pagamento alterada
Local cDescriAdm    := ""    	// Descricao da Administradora para busca no array aFormCtrl
Local cParcAgrup    := Space(2)	// Parcela que ira ser agrupada com a parcela modificada
Local cDescriPag    := ""     	//Descricao da forma de pagamento ou nome da Administradora para atualizacao do aFormCtrl 
Local lAgrupa       := .F.   	// Controla se pode agrupar a parcela modificada com outra parcela da venda
Local lParcAgrup    := .F.	  	// Determina se a parcela modificada foi agrupada a outra parcela 	  
Local lConfirma     := .F.	  	// Controla se confirmou a modificacao da parcela reprovada
Local aFormPagF5    := {}    	// Formas de pagamento da tabela 24
Local aDadosPag     := {}    	// Dados atualizados pelo Caixa
Local aParcForma    := {}    	// Parcelas com a mesma forma de pagamento daquela que foi alterada 
Local aBckParc      := {}    	// Backup do array aParcelas antes da alteracao para atualizacao do array aFormCtrl
Local dDataVenc              	// Data de vencimento usada na atualizacao do array aFormCtrl
Local oDlgParc               	// Objeto do Dialog com as parcelas nas quais se pode agrupar a parcela modificada
Local oButAgrup              	// Objeto do button para agrupar 
Local oButNaoAgrup			 	// Objeto do button para nao agrupar
Local oComboParc			 	// Objeto do combo box com as parcelas que pode agrupar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array com as formas de pagamento cadastradas na tabela 24 para modificar a parcela reprovada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SX5" )
DbSeek( xFilial("SX5")+"24" )
While !Eof() .AND. xFilial("SX5")==X5_FILIAL .AND. X5_TABELA == "24"
	DbSelectArea("SAE")
	DbSetOrder(1)
	DbSeek(xFilial("SAE"))
	If IsMoney(SX5->X5_CHAVE) .OR. Alltrim(SX5->X5_CHAVE) == cSimbCheq
		AADD(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
	Else
		While xFilial("SAE") == SAE->AE_FILIAL .AND. !Eof()
			If Alltrim(SX5->X5_CHAVE) == AllTrim(SAE->AE_TIPO)
				AADD(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
				Exit
			EndIf
			dbSkip()
		End
	EndIf
	DbSelectArea("SX5")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chaves utilizadas na busca do pagamento no array aFormCtrl para compatibilizacao com aParcelas e aPgtos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aBckParc,aParcelas[nPosParcelas][3])     //Forma de pagamento
AADD(aBckParc,aParcelas[nPosParcelas][12])    //ID do cartao
AADD(aBckParc,aParcelas[nPosParcelas][4])     //Administradora
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface que solicita nova forma de pagamento (LOJXFUNA)	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LojxDin(	aFormPagF5	, nVlrTotal		, NIL			, 0				, ;
			0			, oFimVenda		, .F.  			, nVlrTotal		, ;
  			.F.       	, @aDadosPag	, nPosParcelas	, .F.			, ;
	    	@lConfirma	, @oPgtos		, @aPgtos		, @oPgtosAna	, ;
			@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	, ;
			@cSimbCheq	, @nValorBase	, @nTaxaMoeda	, cCliente		, ;
			cLojaCli 	, NIL			, oDlgFrt		)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Caixa confirmou a modificacao da parcela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lConfirma
	aParcelas[nPosParcelas][1]   := aDadosPag[1]   //Data de vencimento
	aParcelas[nPosParcelas][3]   := aDadosPag[3]   //Forma de pagamento
	aParcelas[nPosParcelas][4]   := aDadosPag[4]   //Administradora ou Banco
	aParcelas[nPosParcelas][12]  := aDadosPag[5]   //ID ou digitos do cartao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se pode agrupar a parcela modificada com outras parcelas da venda.   ³
	//³Por exemplo, o cliente, ao ter o cartao 1 reprovado, pode optar por pagar tudo³
	//³com o cartao 2. Isso so eh possivel se a transacao TEF do cartao 2 ainda nao  ³
	//³foi realizada. Pode agrupar tambem com Dinheiro, cheque etc.				     ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to LEN(aParcelas)
		If ALLTRIM(aDadosPag[3]) == ALLTRIM(aParcelas[nX][3])			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for CC ou CD e selecionada a mesma administradora de outra parcela,   ³
			//³deve verificar se esta parcela ja foi processada no TEF. Se foi, nao pode³
			//³agrupar pois a transacao ja esta no servidor TEF                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(aDadosPag[3])$_FORMATEF .AND. ALLTRIM(aDadosPag[4]) == ALLTRIM(aParcelas[nX][4])
				lAgrupa  := (nX > nPosParcelas)    // Se lAgrupa = .T. significa que pode agrupar porque a transacao TEF ainda nao foi realizada
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazenar as parcelas nas quais se pode agrupar.  ³
				//³Nao considerar se for a propria parcela modificada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAgrupa .AND. nX <> nPosParcelas
					nCount++
					AADD(aParcForma,StrZero(nX,2))
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for cheque deve considerar a data de vencimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf IsMoney(aDadosPag[3]) .OR. (ALLTRIM(aDadosPag[3]) == cSimbCheq .AND. aDadosPag[1] == aParcelas[nX][1])
				If nX <> nPosParcelas
					lAgrupa   := .T.
					nCount++
					AADD(aParcForma,StrZero(nX,2))
				EndIf
			EndIf
		EndIf
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrupa as parcelas caso tenham a mesma forma de pagamento, data de vencimento(cheque) ou administradora(cartao) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAgrupa .AND. LEN(aParcForma) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pode agrupar com uma forma de pagamento. Pergunta ao Caixa se confirma agrupamento das parcelas ³
		//³Se modificou para Dinheiro, agrupa sem perguntar												   ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If nCount == 1
			If IsMoney(aDadosPag[3]) .OR. MsgYesNo(STR0307)            //"Já existe uma parcela com esta forma de pagamento. Deseja agrupar?"
				aParcelas[Val(aParcForma[1])][2] += aDadosPag[2]      //Soma o valor da parcela reprovada com a parcela na qual sera agrupada
				cFormaIDCtrl  := aParcelas[Val(aParcForma[1])][12]
				ADel(aParcelas, nPosParcelas)                          //Exclui do aParcelas a parcela reprovada uma 
				ASize(aParcelas, LEN(aParcelas)-1)                    //vez que foi agrupada a outra  
				lParcAgrup  := .T.
				cParcAgrup  := aParcForma[1]
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se puder agrupar em mais de uma parcela de acordo com a nova forma de pagamento selecionada, permite escolher³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf nCount > 1
			DEFINE MSDIALOG oDlgParc FROM  37,80 TO 190,393 TITLE STR0308 PIXEL	  //"Agrupamento de Parcelas"
			
			@ 04, 05 TO 55, 153 LABEL STR0207 OF oDlgParc	PIXEL	              //"Parcelas"
			@ 12, 10 SAY STR0309 SIZE 200, 10 OF oDlgParc PIXEL                  //"Existe mais de uma parcela com esta forma de pagamento."
			@ 20, 10 SAY STR0310 SIZE 250, 10 OF oDlgParc PIXEL  	              //"Se deseja agrupar, selecione em qual parcela e confirme."
			@ 28, 10 SAY STR0311 SIZE 250, 10 OF oDlgParc PIXEL  	  		      //"Caso contrario, selecione Cancelar."
			
			@ 40, 10 COMBOBOX oComboParc VAR cParcAgrup ITEMS aParcForma SIZE 25,07;
			OF oDlgParc PIXEL
			
			DEFINE SBUTTON FROM 57, 090 oButAgrup TYPE 1 ENABLE OF oDlgParc ;
			ACTION (nOpca := 1, oDlgParc:End()) PIXEL
			
			DEFINE SBUTTON FROM 57, 120 oButNaoAgrup TYPE 2 ENABLE OF oDlgParc ;
			ACTION (nOpca := 2, oDlgParc:End()) PIXEL
			
			ACTIVATE DIALOG oDlgParc CENTERED
			
			If nOpca == 1
				aParcelas[Val(cParcAgrup)][2] += aParcelas[nPosParcelas][2]  //Soma o valor da parcela reprovada com a parcela na qual sera agrupada
				cFormaIDCtrl  := aParcelas[Val(cParcAgrup)][12]
				ADel(aParcelas, nPosParcelas)								  //Exclui do aParcelas a parcela reprovada uma 
				ASize(aParcelas, LEN(aParcelas)-1)                           //vez que foi agrupada a outra  
				lParcAgrup  := .T.
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Re-ordena aParcelas de forma que Dinheiro seja sempre a primeira parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nCtrl  := AScan(aParcelas, {|x| x[3] == cSimbCor})) > 1
		AAdd(aParcelas, {})
		AIns(aParcelas, 1)
		nCtrl++
		aParcelas[1] := aParcelas[nCtrl]
		ADel(aParcelas, nCtrl)
		ASize(aParcelas, Len(aParcelas)-1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza as parcelas dos arrays aTEFMult e aBckTEFMult correspondentes no aPgtos, uma vez que        ³
		//³Dinheiro vai para a primeira posicao. O numero da parcela esta na posicao 10 do array                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 to Len(aParcelas)
			If !IsMoney(aParcelas[nY][3])
				If AllTrim(aParcelas[nY][3]) $ _FORMATEF .OR. (AllTrim(aParcelas[nY][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS")) <> 0)
					cMoeda    := Alltrim(aParcelas[nY][3])
					If Alltrim(aParcelas[nY][3]) == cSimbCheq
						cAdm   := AllTrim(aParcelas[nY][4])+AllTrim(aParcelas[nY][6])+AllTrim(aParcelas[nY][7])
					ElseIf lVisuSint
						cAdm   := Alltrim(aParcelas[nY][12])+Space(4-Len(AllTrim(aParcelas[nY][12])))+' - '+AllTrim(Substr(aParcelas[nY][4],7))
					Else
						cAdm   := StrZero(Val(aParcelas[nY][12]),4)+' - '+AllTrim(Substr(aParcelas[nY][4],7))
					EndIf
					nPosParc := Ascan(aTefMult,{|x| x[1] == cMoeda .AND. Alltrim(Upper(x[2]))==Alltrim(Upper(cAdm))})
					If nPosParc > 0
						If aTefMult[nPosParc][8]
							For nX := 1 to Len(aTefMult[nPosParc][10])
								aTefMult[nPosParc][10][nX]  := STRZERO(VAL(aTefMult[nPosParc][10][nX]) + 1,2)
							Next nX
						EndIf
					Else
						nPosParc := Ascan(aBckTefMult,{|x| x[1] == cMoeda .AND. Alltrim(Upper(x[2]))==Alltrim(Upper(cAdm))})
						If nPosParc > 0
							If aBckTefMult[nPosParc][8]
								For nX := 1 to Len(aBckTefMult[nPosParc][10])
									aBckTefMult[nPosParc][10][nX]  := STRZERO(VAL(aBckTefMult[nPosParc][10][nX]) + 1,2)
								Next nX
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next nY
	EndIf
	aPgtos  := AClone(aParcelas)
	oPgtos:SetArray( aPgtos )
	oPgtos:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o array aPgtosSint de acordo com o aPgtos atualizado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lVisuSint
		aPgtosSint  := FrtMontPgt(aPgtos)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o array aFormCtrl para compatibilizar com os arrays aParcelas e aPgtos³
	//³aFormCtrl eh preenchido quando o Caixa seleciona as parcelas pela tecla CTRL   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LEN(aFormCtrl) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera os dados da parcela reprovada antes da modificacao para busca no array aFormCtrl  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFormaAtu  := ALLTRIM(aBckParc[1])    //Forma de pagamento
		cFormaID   := aBckParc[2]             //ID do cartao
		cDescriAdm := ALLTRIM(aBckParc[3])    //Descricao da administradora
		nCtrl      := AScan(aFormCtrl, {|x| x[1] == cFormaAtu .AND. x[9] == cFormaID} ) //Busca a parcela correspondente no array aFormCtrl
		If nCtrl > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A parcela foi agrupada a outra parcela, logo deve ser excluida do array aFormCtrl³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lParcAgrup
				ADel(aFormCtrl,nCtrl)
				ASize(aFormCtrl,LEN(aFormCtrl) - 1)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o valor da parcela em aFormCtrl para a qual foi agrupada  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFormaAtu   := ALLTRIM(aDadosPag[3])
				If IsMoney(aDadosPag[3])
					If SX5->(DbSeek(xFilial("SX5")+"24"+SuperGetMV("MV_SIMB1")))
						cDescriPag  := AllTrim(X5Descri())
					EndIf
				ElseIf aDadosPag[3] == cSimbCheq
					If SX5->(DbSeek(xFilial("SX5")+"24CH"))
						cDescriPag  := AllTrim(X5Descri())
					EndIf
				Else
					DbSelectArea("SAE")
					DbSetOrder(1)
					If DbSeek(xFilial("SAE")+SUBSTR(aDadosPag[4],1,3))
						cDescriPag  := ALLTRIM(SAE->AE_DESC)
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for CC ou CD, busca pelo ID. Se for cheque ou dinheiro, busca pela descricao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lVisuSint .AND. cFormaAtu $ _FORMATEF
					nCtrl     := AScan(aFormCtrl, {|x| ALLTRIM(x[1]) == cFormaAtu .AND. x[9] == cFormaIDCtrl} )
				Else
					nCtrl     := AScan(aFormCtrl, {|x| ((IsMoney(cFormaAtu) .OR. cFormaAtu == cSimbCheq) .AND. (ALLTRIM(x[1]) == cFormaAtu)) .OR. ;
					((ALLTRIM(x[1]) == cFormaAtu) .AND. (ALLTRIM(x[2]) == cDescriPag))})
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ja existe um registro correspondente em aFormCtrl soma o valor da parcela modificada e³
				//³incrementa a quantidade de parcelas													    ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nCtrl > 0
					aFormCtrl[nCtrl][4]++
					aFormCtrl[nCtrl][7] += aDadosPag[2]
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A parcela foi modificada(nao agrupada), logo deve atualizar o array aFormCtrl na posicao ³
			//³correspondente																			³			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se mudou a forma de pagamento ou administradora, deve atualizar(subtrair) o valor em aFormCtrl. 	³
				//³Se resultar zero, deve excluir o registro do aFormCtrl									        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cFormaAtu <> aDadosPag[3] .OR. cDescriAdm <> aDadosPag[4]
					aFormCtrl[nCtrl][7] := aFormCtrl[nCtrl][7] - aDadosPag[2]
					If aFormCtrl[nCtrl][7] == 0
						ADel(aFormCtrl,nCtrl)
						ASize(aFormCtrl,LEN(aFormCtrl) - 1)
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza(soma) o valor em aFormCtrl caso exista um registro correspondente com a mesma   ³
				//³forma de pagamento e Administradora. Se nao existir, cria um novo registro em aFormCtrl  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFormaAtu   := ALLTRIM(aDadosPag[3])
				cFormaID    := aDadosPag[5]
				If IsMoney(aDadosPag[3])
					If SX5->(DbSeek(xFilial("SX5")+"24"+SuperGetMV("MV_SIMB1")))
						cDescriPag  := AllTrim(X5Descri())
					EndIf
				ElseIf aDadosPag[3] == cSimbCheq
					If SX5->(DbSeek(xFilial("SX5")+"24CH"))
						cDescriPag  := AllTrim(X5Descri())
					EndIf
				Else
					DbSelectArea("SAE")
					DbSetOrder(1)
					If DbSeek(xFilial("SAE")+SUBSTR(aDadosPag[4],1,3))
						cDescriPag  := ALLTRIM(SAE->AE_DESC)
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for CC ou CD, busca pelo ID. Se for cheque ou dinheiro, busca pela descricao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If lVisuSint .AND. cFormaAtu $ _FORMATEF
					nCtrl     := AScan(aFormCtrl, {|x| ALLTRIM(x[1]) == cFormaAtu .AND. x[9] == cFormaID} )
				Else
					nCtrl     := AScan(aFormCtrl, {|x| ((IsMoney(cFormaAtu) .OR. cFormaAtu == cSimbCheq) .AND. ;
					                                     (ALLTRIM(x[1]) == cFormaAtu)) .OR. ;
					                                     ((ALLTRIM(x[1]) == cFormaAtu) .AND. (ALLTRIM(x[2]) == cDescriPag))})
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ja existe um registro correspondente em aFormCtrl soma o valor da parcela modificada  ³
				//³e incrementa a quantidade de parcelas. Caso contrario, cria um novo registro			    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nCtrl > 0
					aFormCtrl[nCtrl][4]++                       
					aFormCtrl[nCtrl][7] += aDadosPag[2]
				Else
					//               Forma          Descricao  Data Vencto  Parc 
					//                  Jur         Intervalo      Valor      ID					
					AAdd(aFormCtrl, {cFormaAtu   , cDescriPag, aDadosPag[1], 1  ,;
					                     0       , nIntervalo, aDadosPag[2], NIL ,;
					                 aDadosPag[5]} )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FrtSetCrd ºAutor  ³Venda Clientes      º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa as variaveis staticas utilizadas pelo SIGACRD para   º±±
±±º          ³ efetuar a analise de credito                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONT LOJA                                                 º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtSetCrd()

Local lRet	:= .T.                // Retorno da funcao

aCrdCliente	:= {"",""}
cContrato   := Space(TamSx3("MAH_CONTRA")[1])
aContratos  := {}
aRecCrd		:= {}

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FrtVldDes ºAutor  ³Venda Clientes      º Data ³  12/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o desconto de acordo com a senha do supervisor      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpN1 - Valor do Percentual de Desconto                    ³±±
±±³          ³ ExpN2 - Valor do Desconto                                  ³±±
±±³			 ³ ExpN3 -  Define de qual Get estah sendo chamada a funcao   ³±±
±±³          ³          1 = Porcentagem                                   ³±±
±±³          ³          2 = Valor                                         ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONT LOJA                                                 º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FrtVldDes( nPercDesc , nVlrDesc ,nTipo )

Local lRet	:= .T.			// Retorno da funcao
Local aDesc	:= { "V", 0 }	// Array com o desconto concedido

DEFAULT nPercDesc   := 0
DEFAULT nVlrDesc    := 0
DEFAULT nTipo       := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desconto negativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPercDesc < 0) .OR. (nVlrDesc < 0)
	HELP(' ',1,'FRT023')
	lRet	:= .F.
Else
	If LJProfile( 11 )
		If nTipo == 1 		//-- Chamado a partir do GET da porcentagem.
			If nPercDesc >= 0 .AND. nPercDesc > LjGetProfile("DESCPER") //Verifica permissao do supervisor³ ( 11 ,caixa,desconto,  ndescper)      
				aDesc := { "P", nPercDesc }
			EndIf	
		ElseIf nTipo == 2  //-- Chamado a partir do GET do valor.
			If nVlrDesc >= 0 .AND. nVlrDesc > LjGetProfile("DESCVAL") //Verifica permissao do supervisor³ ( 11 ,caixa,desconto,  ndescper)      
				aDesc := { "V", nVlrDesc }
			EndIf
		Endif		
		lRet := LJProfile(11, NIL, aDesc, nPercDesc,nVlrDesc)
	Else             
	HELP(' ',1,'FRT025')			// "Usuário Sem Permissão Para Efetuar Descontos.", "Atenção"
	lRet	:= .F.
	Endif
Endif
Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FrtValDesc   ³ Autor ³ Vendas Clientes      ³ Data ³ 06/06/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o vendedor pode dar desconto, caso contrario pede a ³±±
±±³          ³ senha do supervisor para liberacao do desconto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -  Define de qual Get estah sendo chamada a funcao        ³±±
±±³          ³          1 = Porcentagem                                        ³±±
±±³          ³          2 = Valor                                              ³±±
±±³          ³ ExpN2 - Valor do Percentual de Desconto                         ³±±
±±³          ³ ExpN3 - Valor do Desconto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ ExpL1 - Valida ou nao o percentual de desconto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaFrt                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtValDesc( nTipo, nPerDesc, nVlrDesc )

Local lRet  := .F. 	// Retorno da funcao
Local aDesc := {}  	// array que informa se esta validando Percentual ou Valor
Local nX	:= 0	// Contador do For

If (nPerDesc >= 0) .OR. (nVlrDesc >= 0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Considera os descontos efetuados no aItens qdo realizado³
	//³no total                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aItens ) > 0 
		For nX := 1 To Len( aItens )
			If !aItens[nX][AIT_CANCELADO]
				nVlrDesc += aItens[nX][AIT_VALDESC]
				nPerDesc +=	Round((aItens[nX][AIT_VALDESC]*100 ) / aItens[nX][AIT_VRUNIT] ,nDecimais) 
			EndIf	
	    Next nX
   	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Com a soma dos percentuais , valida o maximo permitido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If nPerDesc > 99.99 
			nPerDesc := 99.99
		EndIf	
	EndIf     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de validacao determinado pelo parametro MV_LJTPDES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		aDesc := { "P", nPerDesc }
	ElseIf nTipo == 2
		aDesc := { "V", nVlrDesc }
	EndIf
    lRet := LJProfile(11, NIL, aDesc, nPerDesc, nVlrDesc)
EndIf

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FrtAtuValor  ³ Autor ³ Vendas Clientes      ³ Data ³ 06/06/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o vendedor pode dar desconto, caso contrario pede a ³±±
±±³          ³ senha do supervisor para liberacao do desconto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Vslor do Percentual de desconto sem o uso da funcao     ³±±
±±³          ³         Round()                                                 ³±±
±±³          ³ ExpN2 - Valor do Percentual de Desconto                         ³±±
±±³          ³ ExpN3 - Valor do Total da Venda                                 ³±±
±±³          ³ ExpN4 - Valor do Desconto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ ExpN1 - Valor do Desconto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaFrt                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtAtuValor( nPerc , nPercDesc, nVlrTotal, nValorDesc )
Local nVlrDesc	 :=  0  // Valor do Desconto
 
If nValorDesc > 0 
	nVlrDesc := Round( nVlrTotal * ( nPerc / 100 ), 2 )	
Else
	nVlrDesc := Round( nVlrTotal * ( nPercDesc / 100 ), 2 )
Endif

Return (nVlrDesc)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FrtAtuCli    ³ Autor ³ Vendas Clientes      ³ Data ³ 29/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa as variaveis cCliente e cLojaCli apos o cancelamento ³±±
±±³          ³ do cupom                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ lRet = .T.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaFrt                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtAtuCli()
Local lRet 		:= .T.				// Retorno da funcao
Local nTamSXG  	:= 0 				// Rotorno do tamanho do campo

nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

Return ( lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Frt010Lock   ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Lock.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com os detalhes das teclas de atalho              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Array com os detalhes das teclas de atalho               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt010Lock( aKey )

If lLocked
	oTimer:Deactivate()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTLocked()
	lLocked := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	oTimer:Activate()
EndIf

Return (aKey)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Frt010Refr   ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reinicializa as variáveis Staticas e Privates, preparando assim ³±± 
±±³          ³ para a próxima Venda.                             			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codido da condicao de pagamento                          ³±±
±±³          ³ExpL2 - .T. / .F.                                                ³±±
±±³          ³ExpA3 - Array com as parcelas                                    ³±±
±±³          ³ExpA4 - Controle das Formas de Pagamento Solicitadas             ³±±
±±³          ³ExpA5 - Informacoes do pagamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor que servira para o campo L1_FORMPG                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
          
Static Function Frt010Refr()

Local nTamSXG	:= 0
Local nCount	:= 0		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define cliente com o padrao do parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

aItens	 := {} 
aTEFPend := {}						
aBckTEFMult := {}
lOcioso	:= .T.
lVerTEFPend  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera o valor e o percentual de desconto do item       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAltVend   := .F.
nVlrPercIT := 0
nVlrDescIT := 0 
nLastTotal := nVlrTotal
nLastItem  := nTotItens
nTotItens  := 0
nVlrTotal  := 0
nValIPI    := 0
nVlrBruto  := 0
nVlrMerc   := 0
nTotDedIcms  := 0				
lImpOrc    := .F.
oDesconto:Refresh()
oTotItens:Refresh()
oVlrTotal:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa as variáveis de Templates                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
uCliTPL := Nil     
uProdTPL:= Nil
cCodConv:= "" 		
cLojConv:= ""
cNumCartConv := ""
//Restaura as variaveis referentes a moeda para a moeda 1
If cPaisLoc <> "BRA" 
	If nMoedaCor <> 1
		cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
		oTemp3:Refresh()
		oTemp4:Refresh()
		oTemp5:Refresh()

		nTaxaMoeda := 1
		oTaxaMoeda:Refresh()

		nMoedaCor := 1
		cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
		oMoedaCor:Refresh() 
	EndIf               

	//Realiza a gravacao da saida do troco, no arquivo SE5, na base local.
	//Isso foi realizado devido o fato de o usuario querer utilizar a consulta
	//de saldo de caixa no Front. So sera feita a gravacao do SE5 local
	//caso esteja sendo utilizado o troco localizado.                                       
	If SuperGetMV("MV_LJTRLOC",,.F.)
		For nCount := 1 To MoedFin()
			AtuaTroco(&("SL1->L1_TROCO"+Alltrim(Str(nCount))),nCount)
		Next nCount
	EndIf

	//Restaura a exibicao da mensagem padrao...
	AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
	oMensagem:cCaption := STR0001   //"   Protheus Front Loja"
	oMensagem:cTitle   := STR0001   //"   Protheus Front Loja"
	oMensagem:oFont    := oFntGet
	oMensagem:Refresh()

	aImpsSL1    := {}
	aImpsSL2    := {}
	aImpVarDup  := {}
	aImpsProd   := {}
	aCols       := {}
	aHeader     := {}
	aCProva     := {}
	aDadosJur   := {0,0,0,0,0,0,0,0,0}
	nVlrFSD     := 0
	nTotalAcrs  := 0
	nVlrDescTot	:= 0											
	nVlrPercTot	:= 0											
	nVlrPercAcr	:= 0											
	nNumParcs   := 0                                            
	nVlrPercOri := 0              
	nQtdeItOri  := 0                              
Else    
	//Realiza a gravacao da saida do troco, no arquivo SE5, na base local.
	//Isso foi realizado devido o fato de o usuario querer utilizar a consulta
	//de saldo de caixa no Front. So sera feita a gravacao do SE5 local
	//caso esteja sendo utilizado o troco
	If SL1->(FieldPos("L1_TROCO1")) > 0 .AND. SL1->L1_TROCO1 > 0
		AtuaTroco( SL1->L1_TROCO1 , 1 )
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AjustaSX1    ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta os Helps.                                                ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHelp()
Local aHlpP	:= {}		// Texto em português
Local aHlpE	:= {}		// Texto em inglês
Local aHlpS := {}		// Texto em castelhano

// Help FRT046
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transação TEF cancelada devido à " 		)
aAdd (aHlpP, "falha ao imprimir o comprovante " 		)
aAdd (aHlpP, "TEF. O cupom fiscal será cancelado, " 	)
aAdd (aHlpP, "pois o número seqüencial do Emissor " 	)	
aAdd (aHlpP, "do Cupom Fiscal não foi incrementado." 	)
aAdd (aHlpE, "EFT transaction cancelled due to " 		)	
aAdd (aHlpE, "failure when printing EFT voucher. " 		)
aAdd (aHlpE, "The tax coupon will be  cancelled " 		)
aAdd (aHlpE, "because the sequentialnumber of the " 	)	
aAdd (aHlpE, "tax coupon printer (ECF) was not " 		)
aAdd (aHlpE, "increased." 								)
aAdd (aHlpS, "Transaccion TEF anulada debido a falla" 	)
aAdd (aHlpS, "al imprimir comprobante TEF." 			)
aAdd (aHlpS, "Se anulara el cupon fiscal porque el " 	)
aAdd (aHlpS, "numero secuencial del emisor " 			)	
aAdd (aHlpS, "de cupon fiscal no aumento." 				)

PutHelp("PFRT046", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "" )
aAdd (aHlpE, "" )
aAdd (aHlpS, "" )
PutHelp("SFRT046", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT047
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transação TEF cancelada devido à " 		)
aAdd (aHlpP, "impossibilidade de registrar a forma " 	)
aAdd (aHlpP, "de pagamento no ECF." 					)
aAdd (aHlpE, "EFT transaction cancelled due to the "	)
aAdd (aHlpE, "impossibility to register payment " 		)
aAdd (aHlpE, "mode in ECF (tax coupon printer)." 		)
aAdd (aHlpS, "Transaccion TEF anulada debido a " 		)
aAdd (aHlpS, "imposibilidad de registrar la forma " 	)
aAdd (aHlpS, "de pago en el ECF." 						)
PutHelp("PFRT047", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Por favor, realize novamente a operação "	)
aAdd (aHlpP, "TEF, ou escolha uma nova forma de " 		)
aAdd (aHlpP, "pagamento." 								)
aAdd (aHlpE, "Please, execute the EFT transaction " 	)
aAdd (aHlpE, "again or select a new payment mode."		)
aAdd (aHlpS, "Por favor, efectue la operacion TEF " 	)
aAdd (aHlpS, "nuevamente o seleccione una nueva " 		)
aAdd (aHlpS, "forma de pago." 							)
PutHelp("SFRT047", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT048
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transação TEF cancelada devido à falha "		)
aAdd (aHlpP, "ao registrar a forma de pagamento no ECF."	)
aAdd (aHlpE, "ETF cancelled due to failure when "			)
aAdd (aHlpE, "registereing payment mode in ECF "			)
aAdd (aHlpE, "(tax coupon printer).	"						)
aAdd (aHlpS, "Transaccion TEF anulada debido a falla" 		)
aAdd (aHlpS, "al registrar la forma de pago en el  ECF."	)
PutHelp("PFRT048", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Por favor, realize novamente a operação " 	)
aAdd (aHlpP, "TEF, ou escolha uma nova forma de pagamento." )
aAdd (aHlpE, "Please, execute the EFT transaction " 		)
aAdd (aHlpE, "again or select a new payment mode."			)
aAdd (aHlpS, "Por favor, efectue la operacion TEF " 		)
aAdd (aHlpS, "nuevamente o seleccione uma nueva " 			)
aAdd (aHlpS, "forma de pago." 								)
PutHelp("SFRT048", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT049
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "O cupom fiscal será cancelado devido " 		)
aAdd (aHlpP, "ao erro na finalização da venda." 			)
aAdd (aHlpE, "The tax coupon will be cancelled due " 		)
aAdd (aHlpE, "to error finishing the sale." 				)
aAdd (aHlpS, "Se cancelara el cupon fiscal debido "			)
aAdd (aHlpS, "a error al finalizar la venta." 				)
PutHelp("PFRT049", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "" )	// ""
aAdd (aHlpE, "" )	// ""
aAdd (aHlpS, "" )	// ""
PutHelp("SFRT049", aHlpP, aHlpE, aHlpS, .T. )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FrtAtuFORMPG ³ Autor ³ Vendas Clientes      ³ Data ³ 15/10/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do campo L1_FORMPG                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codido da condicao de pagamento                          ³±±
±±³          ³ExpL2 - .T. / .F.                                                ³±±
±±³          ³ExpA3 - Array com as parcelas                                    ³±±
±±³          ³ExpA4 - Controle das Formas de Pagamento Solicitadas             ³±±
±±³          ³ExpA5 - Informacoes do pagamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor que servira para o campo L1_FORMPG                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtAtuFORMPG( cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
					   aPgtos )
Local cRet := ""	//Retorno da funcao

If cItemCond == "CN" .AND. !lCondNegF5 .AND. Len(aParcOrc) == 0
	If Len(aFormCtrl) > 1 
		cRet := aFormCtrl[2][1]
	Else
		If Len(aFormCtrl) > 0
			cRet := aFormCtrl[1][1]	 	
		Endif
	Endif
Else
	If Len(aPgtos) > 0
		cRet := aPgtos[1][3]
	Endif	
Endif

Return ( cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTAPGPE  ºAutor  ³Vendas Clientes     º Data ³  14/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe o ponto de entrada.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt010PgPE(	cForma	, cDesc		, dData		, nNumParc	,;
							nTXJuros, nIntervalo, nValor	, cMoedaVen )

Local xRet			// Retorno do ponto de entrada
DEFAULT cMoedaVen	:= ""		// Moeda da venda

If ExistBlock("FRTFPag")
	xRet := ExecBlock(	"FRTFPag"	, .F.	, .F.		, {cForma	, ;
						cDesc		, dData	, nNumParc	, nTXJuros	, ;
						nIntervalo	, nValor, cMoedaVen } )
EndIf

If ValType( xRet ) == "N"
	nValor := xRet
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FrtImpVia2³ Autor ³ Venda Clientes        ³ Data ³24/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressão da Segunda Via do Ticket de Venda				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtImpVia2(ExpN1)                   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Quantidade de Copias                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtImpVia2( nQtd )

Local lFrtSegVia  := FindFunction( "U_FRTSegVia()" )	// Verifica se o ponto de entrada FrtSegVia existe
Local lCabecalho  := .T.                           		// Controle de linhas em branco no cabecalho
Local aSegVia2    := {}                           		// Array para acumular as linhas do Ticket
Local cSegVia     := ""									// Variavel para acumular os dados do Ticket  
Local xRet     											// Variavel para controle do Ponto de Entrada
Local nX		  := 0                              	// Variavel para o FOR

AAdd( aSegVia2, STR0329 )								//"       F A C T U R A   C O P I A"    
For nX := 1 to Len(oCupom:aItems)-1   
	If ( !lCabecalho ) .OR. ( AllTrim(oCupom:aItems[nX]) <> "" )
		AAdd( aSegVia2,  oCupom:aItems[nX] )    
		lCabecalho := .F.
	EndIf
Next nX                                   
If lFrtSegVia
	xRet := U_FRTSegVia(aSegVia2)
	If ValType(xRet) == "A" 
	   aSegVia2  := AClone(xRet)
	EndIf
EndIf
For nX := 1 to Len( aSegVia2 )  
	cSegVia += aSegVia2[nX] + Chr(10)
Next nX                 

IfTxtNFis( nHdlECF, cSegVia, nQtd )
	
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FRTReducao³ Autor ³ Venda Clientes        ³ Data ³24/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressão da Reducao Z									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL							                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja (F12 + 02)                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTReducao()

If MsgNoYes(STR0331)		//"Confirma REDUCAO Z ?"
	LJ160Leitura()
Endif
 
Return .T.
