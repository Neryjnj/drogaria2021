#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FRTA271I.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"
		
#DEFINE	 FRT_SEPARATOR		"---------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				1
#DEFINE AIT_COD			    	2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM				7
#DEFINE AIT_VALDESC		   		8
#DEFINE AIT_ALIQUOTA			9          
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM
#DEFINE AIT_IMPINCL             16                  // Verifica se o imposto esta incluido no valor do item

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha

Static cGetCliDir 
Static cProfStr1
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271IMsgTel³ Autor ³ Vendas Clientes       ³ Data ³13/07/2002³±±
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
Function Fr271IMsgTela( cMensagem )
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
±±³Programa  ³FR271ITotVen ³Autor ³Vendas Clientes     ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Calcula o total da venda nas diversas moedas cadastrada no    ³±±
±±³          ³sistema e armazena os valores em array.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271ITotVen(	nVlrTotal	, nMoedaCor	, nTaxaMoeda	, aTotVen	,; 
							aMoeda)

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
±±³Programa  ³FR271HExibTot³Autor ³Vendas Clientes     ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Exibe o total da venda nas diversas moedas cadastradas no     ³±±
±±³          ³sistema.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271HExibTotVen( aMoeda	, aSimbs, aTotVen, oMensagem,;
                           oFntMoeda, cMensagem )

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
±±³Programa  ³FR271ISimACol³Autor ³Vendas Clientes     ³ Data ³  23/07/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Simula o acols e aHeader para o calculo de impostos variaveis ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271ISimACols( cProduto	, nQuant	, nPreco	, cTes		,;
                         cCF		, cItem 	, lDel 		, aCols		,;
						 aHeader	)

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
±±³Programa  ³FR271ICDescLo³Autor ³Vendas Clientes     ³ Data ³  15/08/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Realiza o calculo do desconto no total da venda - Localicoes  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FR271ICDescLoc(ExpN1,ExpN2,ExpN3)                            ³±± 
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
Function FR271ICDescLoc(	nValorDesc	, nPercDesc	, nTmpJuros	, nTmpDesc	,;
							nVlrBruto	, nVlrMerc	, nMoedaCor	, nDecimais	,;
							aImpsSL1	, aImpsSL2	, aImpsProd	, lRecalImp	,; 
							aCols		, aHeader	, aDadosJur	, cItemCond	,;
							lCondNegF5	, cOrcam	, oVlrTotal	, nVlrTotal )


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
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nTotalAnt    := 0 
Local nVlrTotDesc  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes	  ³
//³Paises: Chile/Colombia - F1CHI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5        := GetRpoRelease ("R5") .AND. cPaisLoc$"CHI|COL" 	//Trava de Release
Local nVlMercAux	:= 0												//Valor da Mercadoria (Auxiliar)		
						                                                         
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

//Armazena os valores antes do recalculo  
If cPaisloc == "MEX"  
	nTotalAnt  := nVlrTotal + aDadosJur[9]
	nVlrMerc   += aDadosJur[9]  
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
		
		

		If lLocR5 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes                                ³
			//³Ao inicializar as variaveis fiscais, o valor da mercadoria ³
			//³deve desconsiderar os descontos.                           ³
			//³                                                           ³
			//³Paises: Chile/Colombia - F1CHI                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			nVlMercAux:= nVlrTotUN						
		Else
			
			If cPaisLoc == "MEX" .And. SuperGetMv("MV_DESCSAI", Nil, "1") == "2"
				nVlMercAux := nVlrTotUN 
			Else
				nVlMercAux := nVlrTotIT
			EndIf
		Endif
		
		MaFisAdd(aImpAnt[nX][1], aImpAnt[nX][2], nQtde, nVlrTotUN, nDescProIt, "", "",, 0, 0, 0, 0, nVlMercAux, 0)
		
	
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
			FR271HGeraImp(@aImposto,aImps[nI],nValImp,aImpAnt[nX][3][1][11],aImpAnt[nX][3][1][12],1,cIndImp,nDecimais)
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
		FR271ISimACols(aImpAnt[nX][1]	, nQtde				, nVlrUnitIt	, aImpAnt[nX][2]	,; 
					""					, aImpAnt[nX][4]	, Nil			, @aCols			,;
					@aHeader			)
	Else       
		//Eh criado aCols e aImpsSL2 com o item deletado para que permanecam
		//do tamanho original..
		Aadd(aImpsSL2, aClone(aImpAnt[nX]) )	
		FR271ISimACols(aImpAnt[nX][1]	, nQtde				, nVlrUnitIt	, aImpAnt[nX][2]	,; 
					""				, aImpAnt[nX][4]	, .T.			, @aCols			,;
					@aHeader		)
	EndIf
Next nX	                          

nVlrTotal := Round(nVlrTotal + nTotImp,nDecimais)

//Acerta o valor total bruto e o valor total da mercadoria...
nVlrBruto := nVlrTotal
nVlrMerc  := (nVlrTotal-nTotImp)

//Funcao para atulizar o arquivo SL2 -  Localizacoes
If Len(aSL2) > 0
	FR271HSL2GRV(aSL2,	cOrcam)
EndIf	

//Atualiza o array aDadosJur com o valor total do desconto
If cPaisloc == "MEX" 
    nVlrTotDesc   :=  nTotalAnt - nVlrTotal    
	aDadosJur[9]  :=  nVlrTotDesc
EndIf

If !lTouch
	oVlrTotal:Refresh()
Endif
			
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR271IChkB³ Autor ³Vendas Clientes        ³ Data ³18/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se as imagens FRONT, LOJAWIN e SEMFOTO estao no   ³±±
±±³          ³ repositorio de imagens                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          

Function FR271IChkBMP( oDlg )
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
±±³Funcao    ³ FR271IRec³ Autor ³Vendas Clientes        ³ Data ³07/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a chamada a funcao de Recebimentos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem TEF pendente no SITEF.             ³±±
±±³          ³ ExpA1 - Guarda a transacao TEF Pendente					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    

Function FR271IReceb(	oHora		, cHora			, oDoc			, cDoc			,;		
						oCupom		, cCupom		, nVlrPercIT	, nLastTotal	,;	
						nVlrTotal	, nLastItem		, nTotItens		, nVlrBruto		,;	
						oDesconto	, oTotItens		, oVlrTotal		, oFotoProd		,; 
						nMoedaCor	, cSimbCor		, oTemp3		, oTemp4		,; 
						oTemp5		, nTaxaMoeda	, oTaxaMoeda	, nMoedaCor		,; 
						cMoeda		, oMoedaCor		, cCodProd		, cProduto		,; 
						nTmpQuant	, nQuant		, cUnidade		, nVlrUnit		,; 
						nVlrItem	, oProduto		, oQuant		, oUnidade		,; 
						oVlrUnit	, oVlrItem		, oPgtos		, oPgtosSint	,; 
						aPgtos		, aPgtosSint	, cOrcam		, cPDV			,;
						lTefPendCS 	, aTefBKPCS		, oDlgFrt		, cCliente		,;
						cLojaCli	, cVendLoja		, lOcioso		, lRecebe		,;
						lLocked		, lCXAberto		, aTefDados		, dDataCN		,;
						nVlrFSD		, lDescIT		, nVlrDescTot	, nValIPI		,;
						aItens		, nVlrMerc		, lEsc			, aParcOrc		,;
						cItemCOrc	, aParcOrcOld	, aKeyFimVenda	, lAltVend		,;
						lImpNewIT	, lFechaCup		, aTpAdmsTmp	, cUsrSessionID	,;
						cContrato	, aCrdCliente	, aContratos	, aRecCrd		,;
						aTEFPend	, aBckTEFMult	, cCodConv		, cLojConv		,;
						cNumCartConv, uCliTPL		, uProdTPL		, lDescTotal	,; 
						lDescSE4	, aVidaLinkD	, aVidaLinkc 	, nVidaLink		,;
						cCdPgtoOrc	, cCdDescOrc	, nValTPis		, nValTCof		,; 
						nValTCsl	, lOrigOrcam	, lVerTEFPend	, nTotDedIcms	,;
						lImpOrc		, nVlrPercTot	, nVlrPercAcr	, nVlrAcreTot	,;
						nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	, nNumParcs		,;
						aMoeda		, aSimbs		, cRecCart		, cRecCPF		,; 
						cRecCont	, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen		, nTotalAcrs	, lRecalImp		,;
						aCols		, aHeader 		, aDadosJur		, aCProva		,;
						aFormCtrl	, nTroco		, nTroco2 		, lDescCond		,; 
						nDesconto	, aDadosCH		, lDiaFixo		, aTefMult		,;
						aTitulo		, lConfLJRec	, aTitImp		, aParcelas		,;
						oCodProd	, cItemCond		, lCondNegF5	, nTxJuros		,;
						nValorBase	, oTimer		, lResume		, oOnOffLine	,;
						nValIPIIT	, _aMult		, _aMultCanc	, nVlrDescIT	,;
						oFntMoeda	, lBscPrdON		, oPDV			, aICMS			,;
						lDescITReg	, cMensagem		, lAbreCup		, lSelTefManu)

Local nI 		   	:= 0				 					//	variavel do loop
Local lTEFPendRec  	:= .F.   							// Controla se tem transacao TEF jah realizada e pendente 
Local lTefMult	   	:= SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local aRecTEFMult  	:= {}
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local cTotRecNFis	:= "" 		// declaracao da variavel a ser utilizada na impressao do recebimento nao fiscal - LJGRVREC
Local nX			:= 0
Local aNccRecSel 	:= {}       //NCCs do cliente apresentadas na tela que poderao ser utilizadas como pagamento no recebimento de titulos
Local lLjIcmJr		:= cPaisLoc == "BRA" .And. GetRpoRelease("R5") .And. SuperGetMV("MV_LJICMJR",,.F.)
Local lEmitNFCe		:= ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe()

DEFAULT cMensagem 	:= ""
DEFAULT lAbreCup	:= .F.
Default lSelTefManu	:= .F.

If cGetCliDir == NIL
   cGetCliDir := GetClientDir()
EndIf   

If !lOcioso .OR. lRecebe
	Return(NIL)
EndIf             

If lEmitnfce .And. ExistFunc("Fr271aVlDt") .And. !Fr271aVlDt(.T.)
	MsgAlert(STR0033 + CRLF + STR0034)  // "A Data do dia é diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."	
	Return NIL
EndIf      

lConfLJRec	:= .F.
aTitImp 	:= {}			
aParcelas 	:= {}

aTitulo 	:= LJReceb(@cCliente, @cLojaCli, @cRecCart, @cRecCPF, @cRecCont, lOcioso)      

If aTitulo[1] <> 0
	lRecebe 	:=  .T.
    nVlrTotal 	:= 0
    
	cCupom := ""
	
	If ExistBlock("FRTCLICHE")
		aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
        For nX := 1 To Len(aFRTCliche)
        	oCupom:AppendText(aFRTCliche[nX])
        Next nX
	Else
		oCupom:AppendText((chr(10) + chr(13)))
		oCupom:AppendText((STR0002)+ chr(10) + chr(13))	// "        MICROSIGA SOFTWARE S.A.         "
		oCupom:AppendText((STR0003)+ chr(10) + chr(13))	// "    Av. Braz Leme, 1631 - São Paulo     "
		oCupom:AppendText((STR0004)+ chr(10) + chr(13))	// "          www.microsiga.com.br          "
	EndIf
	
	oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+StrZero(Val(cDoc)+1,TamSX3("L1_DOC")[1]))	+ chr(10) + chr(13)) // "  PDV:" "   COD:"
	oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
	oCupom:AppendText((STR0009) + chr(10) + chr(13))	// "          R E C E B I M E N T O         "
	oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
	oCupom:AppendText((chr(10) + chr(13))+ chr(10) + chr(13))
	oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
	
	For nI := 1 To Len(aTitulo[2])
		If aTitulo[2][nI][1]
			oCupom:AppendText((STR0010)+ chr(10) + chr(13))		// "Prefixo  Titulo     Parcela   Vencimento"
			oCupom:AppendText((aTitulo[2][nI][2]+Space(6)+aTitulo[2][nI][3]+Space(8)+aTitulo[2][nI][4]+Space(6)+DToC(aTitulo[2][nI][5])) + chr(10) + chr(13))
			oCupom:AppendText((STR0011+Transform(aTitulo[2][nI][ 6], PesqPict("SE1", "E1_VALOR", 15)))+ chr(10) + chr(13))	// "   Valor          = "
			oCupom:AppendText((STR0012+Transform(aTitulo[2][nI][ 7], PesqPict("SE1", "E1_MULTA", 15)))+ chr(10) + chr(13))	// "   Multa          + "
			oCupom:AppendText((STR0013+Transform(aTitulo[2][nI][ 8], PesqPict("SE1", "E1_JUROS", 15)))+ chr(10) + chr(13))	// "   Juros          + "
			If lLjIcmJr
				oCupom:AppendText((STR0032+Transform(aTitulo[2][nI][17], PesqPict("SE1", "E1_ACRESC", 15)))+ chr(10) + chr(13))	// "   Acrescimo      + "
			EndIf
			oCupom:AppendText((STR0014+Transform(aTitulo[2][nI][ 9], PesqPict("SE1", "E1_DESCONT", 15)))+ chr(10) + chr(13))	// "   Desconto       - "
			oCupom:AppendText((STR0015+Transform(aTitulo[2][nI][10], PesqPict("SE1", "E1_VALOR", 15)))+ chr(10) + chr(13))	// "   Valor Recebido = "
			oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
	
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

	If !lTouch
		oVlrTotal:Refresh()
	Endif

	aKeyFimVenda := FrtSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declara o conteudo vazio ao array para o uso na impressao do recebimento nao fiscal.³
	//³O array será devidamente preenchido na função FR271GEncerra                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aTitImp       := {}                                        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declara o conteudo da variavel para o uso na impressao do recebimento nao fiscal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cGetCliDir == NIL
		cGetCliDir := GetClientDir()
	EndIf
	If cProfStr1 == NIL
		cProfStr1 := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", cGetCliDir+"SIGALOJA.INI") 
	EndIf
	cTotRecNFis   := cProfStr1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a função para finalização da venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                            	
	aPgtos := FR271EFimVend(	@lTEFPendRec	, @aRecTEFMult	, Nil			, @oHora			,; 		
								@cHora			, @oDoc			, @cDoc			, @oCupom			,;		
								@cCupom			, @nVlrPercIT	, @nLastTotal	, @nVlrTotal		,;		
								@nLastItem		, @nTotItens	, @nVlrBruto	, @oDesconto		,;		
								@oTotItens		, @oVlrTotal	, @oFotoProd	, @nMoedaCor		,;		
								@cSimbCor		, @oTemp3		, @oTemp4		, @oTemp5			,;		
								@nTaxaMoeda		, @oTaxaMoeda	, @nMoedaCor	, @cMoeda			,;		
								@oMoedaCor		, @cCodProd		, @cProduto		, @nTmpQuant		,;		
								@nQuant			, @cUnidade		, @nVlrUnit		, @nVlrItem			,;		
								@oProduto		, @oQuant		, @oUnidade		, @oVlrUnit			,;		
								@oVlrItem		, /*LF7*/		, @oPgtos		, @oPgtosSint		,;
								@aPgtos			, @aPgtosSint	, @cOrcam		, @cPDV				,;
								lTefPendCS		, aTefBkpCS		, @oDlgFrt		, @cCliente			,;	
								@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe			,;
								@lLocked		, @lCXAberto	, @aTefDados	, @dDataCN			,;
								@nVlrFSD		, @lDescIT		, @nVlrDescTot	, @nValIPI			,;	
								@aItens			, @nVlrMerc		, @lEsc			, @aParcOrc			,;
								@cItemCOrc		, @aParcOrcOld	, @aKeyFimVenda	, @lAltVend			,;
								@lImpNewIT		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID	,;
								@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd			,;
								@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv			,;
								@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal		,; 
								@lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	, @nVidaLink		,;
								@cCdPgtoOrc		, @cCdDescOrc	, @nValTPis		, @nValTCof			,; 
								@nValTCsl		, @lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms		,;
								@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot		,;
								@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs		,;
								@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF			,; 
								@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd		,; 
								@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp		,;
								@aCols			, @aHeader 		, @aDadosJur	, @aCProva			,;
								@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond		,; 
								@nDesconto		, @aDadosCH		, @cItemCond	, @lCondNegF5		,;
								@nTxJuros		, @nValorBase	, @lDiaFixo		, @aTefMult 		,;
								@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas		,;
								@oCodProd		, /*@oMensagem*/, /*@oFntGet*/	, /*@cCodDep*/		,;
								/*@cNomeDEP*/	, /*@cTipoCli*/	, /*@cEntrega*/ , /*@aReserva*/		,;
								/*@lReserva*/	, /*@lAbreCup*/	, /*@nValor*/	, @oTimer			,;
								@lResume		, /*aValePre*/	, /*aRegTEF*/	, /*lRecarEfet*/	,;
								/*lCancItRec*/	, @oOnOffLine	, @nValIPIIT	, @_aMult			,;
								@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON		,;
								@oPDV			, @aICMS		, @lDescITReg	, /*cNumDAV*/		,;
								/*cCliCGC*/		, @cMensagem	, /*@cDocFo*/	, @aNccRecSel	,;
								@lSelTefManu)
																			
	If lConfLJRec
	    If lTefMult .AND. LEN(aRecTEFMult) > 0
	       aTEFMult  := AClone(aRecTEFMult)
	    EndIf
		If !LJGrvRec( @aPgtos	, lTEFPendRec	, aBckTEFMult	, @lVerTEFPend	,;
						@aTitImp, @nTroco       , aTitulo[2]       , cTotRecNFis 	,;
						aNccRecSel , lSelTefManu)
			oCupom:SetupdatesEnable(.F.)
			oCupom:AppendText((" ") + chr(10) + chr(13))
			oCupom:AppendText((STR0022) + chr(10) + chr(13))  //"Recebimento não efetuado."
			oCupom:AppendText((STR0023) + chr(10) + chr(13))  //"O servidor está fora do ar."
			oCupom:AppendText((" ") + chr(10) + chr(13))
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
		    oCupom:SetupdatesEnable(.T.)
		    oCupom:GoEnd()
		Endif
		aBckTEFMult  := {}
		lVerTEFPend  := .F.
		lConfLJRec	 := .F.	
	EndIf	
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FR271IVLD³ Autor ³Vendas Clientes        ³ Data ³03/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a data do Cheque para permitir pagamentos a vista   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271IVLDDTA( dData )
Local nRange := SuperGetMV("MV_LJCHVST", ,-1)
Local lRet   := .T.
If nRange >= 0 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento do cheque a vista                                     ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ Um cheque eh considerado a vista quando:                               ³
	//³             Data do cheque < dDataBase + SuperGetMV("MV_LJCHVST)       ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ Se o conteudo do parametro for -1, entao ele nao devera ser considerado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dData >= dDataBase+nRange
		MsgStop(STR0016)	//"Data acima do intervalo permitido."
		lRet := .F.
	Endif
Endif

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³FRT271IFRTºAutora ³Vendas Clientes     º Data ³  03/10/04   º±±
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
Function FRT271IFRTA271(	nMoedaCor	, cMoeda	, oMoedaCor	, nDecimais	,;
		  					oTaxaMoeda	, cSimbCor	, oTemp3	, oTemp4  	,;			
		  					oTemp5		, aItens	, aMoeda	, aSimbs)

FR271HTRCMoeda(	nMoedaCor	, cMoeda	, oMoedaCor	, nDecimais	,;
  			oTaxaMoeda	, cSimbCor	, oTemp3	, oTemp4  		,;			
  			oTemp5		, aItens	, aMoeda	, aSimbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR271IAddL³ Autor ³Vendas Clientes        ³ Data ³22/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a impressao visual do cupom das funcoes do Front.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271IAddLine(	cText	, nNumLines	, cPicture	, oCupom	,;
						lEsc,cCupom )
						
Local nNumPgdn := 13 // Define com quantas linhas poderá ser realizado um PGDN para selecinar uma opcao
Local cGet     := Space(3)

oCupom:AppendText( cText + chr(10) + chr(13))
nNumLines += 1

If nNumLines == nNumPgdn
	oCupom:AppendText((STR0017) + chr(10) + chr(13))	//"Tecle <ENTER> para continuar..."
	FRTGet(@cGet, cPicture, @lEsc)
	nNumLines := 0  
	cCupom :=""
	//oCupom:Del(Len(oCupom:aItems))
EndIf

Return cGet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271ITefD³Autora ³Vendas Clientes        ³ Data ³28/04/2004³±±
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
Function FR271ITefDig( aPgtos	, aCols )

Local nParcelas		:= Len(aPgtos)											// Quantidade de Parcelas do aPgtos
Local nCont			:= 0													// Contador do laço For
Local aHeadDig		:= {}													// Cabeçalho da Identificação
Local aColsDig		:= {}			                                        // Itens da digitação
Local aCampAlt      := {"DIG"}												// Campos a serema alterados no aColsDig

Local oDlgTefDig

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
	Frtx272T08( @aHeadDig	, @aColsDig	,  @aCampAlt	, @oDlgTefDig,;
				@aPgtos )
	
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271IDigC³Autora ³Vendas Clientes        ³ Data ³28/04/2004³±±
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

Function FR271IDigConf(nBotao, aPgtos)
Local lRet  := .F.        										// Retorno da funcao
Local nCont := 0												// Contador do laço
If nBotao = 1 								      				// Siginifica que o usuário teclou OK
	If Ascan( oGet:aCols , {|x| !Empty(x[6]) .AND. Len(Alltrim(x[6]))<4} ) > 0   	// Verifica se foram informados os 4 últimos dígitos
		MsgAlert(STR0018) //"Verifique se os digitos informados säo compostos por 4 numeros!"
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
	lRet := MsgNoYes(STR0019) //"Ao efetuar o cancelamento desta operacäo as parcelas de uma mesma ADM seräo consideradas em um unico cartäo. Tem certeza que deseja abandonar a digitacäo?"
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fr271IMont³ Autora³Vendas Clientes        ³ Data ³ 18/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Prepara a array sintetizada para exibição                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA701                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fr271IMontPgt(aPgtos	, nMoedaCor)
Local nFor 	 		:= 0
Local cCond  		:= ""
Local nValor 		:= 0
Local nParc	 		:= 0
Local lVisuSint  	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local cFormaId 		:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))
Local nPos	 		:= 0
Local aParcSint		:= {}
Local aSequencia	:= {}
Local cSimbMoeda	:= AllTrim(SuperGetMV("MV_SIMB1"))

DEFAULT aPgtos	  	:= {}				//Array para com as parcelas a sintetizar

If cGetCliDir == NIL
   cGetCliDir := GetClientDir()
EndIf   
   
If Len(aPgtos) > 0
	For nFor := 1 To Len(aPgtos)
		If (Alltrim(cCond) <> Alltrim(aPgtos[nFor][3])) .OR. ;
		   (Alltrim(cCond) == Alltrim(aPgtos[nFor][3])  .AND. Alltrim(aPgtos[nFor][12]) <> Alltrim(cFormaId) )
		    cCond  		:= Alltrim(aPgtos[nFor][3])
		    nValor 		:= aPgtos[nFor][2]
		    nParc  		:= 1
   		    cFormaId 	:= aPgtos[nFor][12]
	
	    	Aadd( aParcSint , { cCond , nParc , TransForm(nValor,PesqPict("SL4","L4_VALOR",,nMoedaCor)) , cFormaId, aPgtos[nFor][1], { , , , ,aPgtos[nFor][4]}  } )   
		Else
			nValor 	+= aPgtos[nFor][2]
			nParc  	+= 1
			nPos	:= Ascan(aParcSint, { |x| ( Alltrim(x[1]) == cCond .AND. Alltrim(x[4]) == Alltrim(cFormaId) ) })
			
			If nPos > 0
				aParcSint[nPos][3]	:= TransForm(nValor,PesqPict("SL4","L4_VALOR",,nMoedaCor))
				aParcSint[nPos][2]  := nParc
			EndIf	
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
If !(lUsaTEF .AND. cTipTEF == TEF_CLISITEF )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ No MultiTEF Discado ha situacao em que a data da parcela fica em branco, portanto nao executa aSort³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. FindFunction("L010GetGPAtivo") .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo())))
		aSort( aParcSint,,, {|x,y| Dtos(x[5])+x[1]+x[4] < Dtos(y[5])+y[1]+y[4] } ) //Data + Cond + Seq.
	EndIf
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
±±ºPrograma  ³Fr271IIDVaºAutora ³Vendas Clientes     º Data ³  11/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o dígito informado é correto para o controle de  º±±
±±º          ³ múltiplos cartões                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Function Fr271IIDValid(cForma	, cFormaID	, aPgtos)
Local lRet 	 := .T.

If Empty(cFormaId)
	MsgAlert(STR0020,STR0001) //"Informe o ID do Cartão para a operação TEF.","Atenção"
	lRet := .F.
ElseIf Ascan( aPgtos, {|x| Alltrim(x[3])==cForma .AND. Alltrim(x[12])==Alltrim(cFormaID) } ) > 0 
	MsgAlert(STR0021,STR0001) //"Cartão já informado para a operação TEF, utilize uma nova identificação.","Atenção")
	lRet := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271ICmp ºAutor  ³Vendas Clientes     º Data ³  14/03/05   º±±
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
Function FR271ICmpP( ax3, cCAlias, xOrc, nNumItem )

Local aArea := GetArea()                    // Area atual

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cCAlias)
While !Eof() .AND. X3_ARQUIVO == cCAlias
	If x3Uso(X3_USADO) .AND. cNivel >= x3_nivel
		If X3_PROPRI == "U"
			If nNumItem > 0
				Aadd(ax3,{X3_CAMPO, FR271CAField(xOrc, X3_CAMPO,nNumItem)})
			Else
				Aadd(ax3,{X3_CAMPO, FR271CAField(xOrc, X3_CAMPO)})
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
±±³Fun‡„o	 ³FR271ISeek³Autor  ³Vendas Clientes        ³ Data ³01/11/2005³±±
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
Function FR271ISeekParc( nX  ,aTEF )

Local nRet        := 0                   // Retorno da funcao com o indice da parcela no array aParcTEF
Local cMoeda      := ""                 // Forma de pagamento 
Local cAdm        := ""                 // Codigo da adminstradora financeira
Local lVisuSint  := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior

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
±±³Fun‡„o	 ³FR271INovo³Autor  ³Vendas Clientes        ³ Data ³01/11/2005³±±
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
Function FR271INovoPgto( nPosParcelas  	, oFimVenda		, oPgtos		, oPgtosSint	,;
						 aPgtos			, aPgtosSint	, aBckTEFMult	, nMoedaCor		,;
						 aFormCtrl		, aTefMult		, aParcelas 	, oPgtosAna		,;
						 nTxJuros		, aMoeda		, lVendaRapida	, nValorBase	,;
						 nTaxaMoeda)	            

Local nCtrl         := 0     	// Controla a re-ordenacao do array aParcelas com forma de pagto Dinheiro em primeiro e ajuste do array aFormCtrl
Local nX            := 0     	// Controle de loop
Local nY            := 0     	// Controle de loop
Local nPosParc      := 0     	// Posicao da parcela para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local nCount        := 0     	// Contador de parcelas de mesma forma de pagamento / Contador das parcelas excluidas do aFormCtrl
Local nOpca         := 2     	// Opcao selecionada na tela de agrupamento de parcelas
Local nIntervalo    := SuperGetMV("MV_LJINTER")  //Intervalo padrao entre as parcelas
Local cMoeda        := ""    	// Forma de pagamento para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local cAdm          := ""    	// Administradora financeira para atualizacao das parcelas dos arrays aTEFMult e aBckTEFMult 
Local lVisuSint  := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
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
Local cSimbCheq   := AllTrim(MVCHEQUE)

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
LojxDin(	aFormPagF5	, nVlrTotal		, NIL			, 0				,;
			0			, oFimVenda		, .F.  			, nVlrTotal		,;
  			.F.       	, @aDadosPag	, nPosParcelas	, .F.			,;
	    	@lConfirma	, @oPgtos		, @aPgtos		, @oPgtosAna	,;
	    	@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
	    	@cSimbCheq	, @nValorBase	, @nTaxaMoeda	)
		
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
			If IsMoney(aDadosPag[3]) .OR. MsgYesNo(STR0024)            //"Já existe uma parcela com esta forma de pagamento. Deseja agrupar?"
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
			
			//CHAMA A TELA DE AGRUPAMENTO DE PARCELAS
			nOpca := Frtx272T01( @cParcAgrup, @aParcForma) 
			
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
		aPgtosSint  := Fr271IMontPgt(@aPgtos	, @nMoedaCor)
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
±±ºPrograma  ³Fr271ICrdSºAutor  ³Vendas Clientes     º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa as variaveis staticas utilizadas pelo SIGACRD para   º±±
±±º          ³ efetuar a analise de credito                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONT LOJA                                                 º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fr271ICrdSet( cContrato	, aCrdCliente	,  aContratos	,aRecCrd)

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
±±ºPrograma  ³Fr271IDesVºAutor  ³Vendas Clientes     º Data ³  12/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o desconto de acordo com a senha do supervisor      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpN1 - Valor do Percentual de Desconto                    ³±±
±±³			 ³ ExpN2 -  Define de qual Get estah sendo chamada a funcao   ³±±
±±³          ³          1 = Porcentagem                                   ³±±
±±³          ³          2 = Valor                                         ³±±
±±³          ³ ExpN3 - Valor do Desconto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ ExpL1 - Valida ou nao o percentual de desconto             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FRONT LOJA                                                 º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fr271IDesVld( nPercDesc , nTipo , nVlrDesc,lDescITReg )

Local lRet	:= .T.			// Retorno da funcao
Local aDesc	:= { "V", 0 }	// Array com o desconto concedido

DEFAULT nPercDesc   := 0
DEFAULT nVlrDesc    := 0
DEFAULT nTipo       := 1
DEFAULT lDescITReg	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desconto negativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPercDesc < 0) .OR. (nVlrDesc < 0)
	HELP(' ',1,'FRT023')
	lRet	:= .F.
Else

	If lDescITReg
	
		If nTipo == 1 		//-- Chamado a partir do GET da porcentagem.
			If nPercDesc >= 0 .AND. nPercDesc > LjGetProfile("DESCPER") //Verifica permissao do supervisor³ ( 11 ,caixa,desconto,  ndescper)      
				aDesc := { "P", nPercDesc }
			EndIf	
		
			If nPercDesc > 0
				lRet := LJProfile(11, NIL, aDesc, nPercDesc,nVlrDesc)
			EndIf
	
		ElseIf nTipo == 2  //-- Chamado a partir do GET do valor.
			If nVlrDesc >= 0 .AND. nVlrDesc > LjGetProfile("DESCVAL") //Verifica permissao do supervisor³ ( 11 ,caixa,desconto,  ndescper)      
				aDesc := { "V", nVlrDesc }
			EndIf

			If nVlrDesc > 0
				lRet := LJProfile(11, NIL, aDesc, nPercDesc,nVlrDesc)
			EndIf
			
		Endif		
	
	EndIf

Endif
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fr271IValDesc³ Autor ³ Vendas Clientes      ³ Data ³ 06/06/2006 ³±±
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
Function Fr271IValDesc( nTipo		, nPerDesc, nVlrDesc , aItens ,;
						   nDecimais	)

Local lRet	:= .F.					// Retorno da funcao
Local aDesc	:= { "V", 0 }		// array que informa se esta validando Percentual ou Valor

DEFAULT aItens		:= {}			// Array com os itens da Venda
DEFAULT nDecimais   := 2			// Quantidade de casas decimais

If (nPerDesc >= 0) .OR. (nVlrDesc >= 0)  

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³				Valida o maximo permitido 					³//
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nPerDesc > 99.99 
		nPerDesc := 99.99
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de validacao determinado pelo parametro MV_LJTPDES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		aDesc := { "P", nPerDesc }
	ElseIf nTipo == 2
		aDesc := { "V", nVlrDesc }
	EndIf
    lRet := LJProfile(11, NIL, aDesc, nPerDesc, nVlrDesc, , , , , .T.)
EndIf

// Enviar mensagem para o display quanto a permissao do desconto
LjDescDisp(Iif(lRet, 1, 2))
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fr271IAtuValor³ Autor ³Vendas Clientes       ³ Data ³ 06/06/2006 ³±±
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

Function Fr271IAtuValor( nPerc , nPercDesc, nVlrTotal, nValorDesc )
Local nVlrDesc	 :=  0  // Valor do Desconto
 
If nValorDesc > 0 .And. nPercDesc > 0 
	If nPerc > 0
		nVlrDesc := Round( nVlrTotal * ( nPerc / 100 ), 2 )	
	Else
		nVlrDesc := Round( nValorDesc, 2 )	
	EndIf
Else
	nVlrDesc := Round( nVlrTotal * ( nPercDesc / 100 ), 2 )
Endif

Return (nVlrDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271ICxFeºAutor  ³Vendas Clientes     º Data ³  23/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Quando existir movimento de caixa (SLW), verifica se ja estaº±±
±±º          ³aberto, antes de fecha-lo e reabri-lo.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271ICxFecha(lCXAberto, nRecSLW, lHora)
Local cCaixa    := xNumCaixa() 
Local cPDV      := LJGetStation("LG_PDV") 
DEFAULT nRecSLW := 0
DEFAULT lHora	:= .T.

If AliasIndic("SLW")
	cPDV := cPDV + Space( TamSX3("LW_PDV")[1] - Len(cPDV) )
	DbSelectArea("SLW")
	SLW->(DbSetOrder(1))

	If SLW->(DBSeek(xFilial("SLW") + cPDV + cCaixa)) 
		While ! SLW->(EOF() ) .AND. SLW->(LW_FILIAL) == xFilial("SLW") .AND. SLW->(LW_PDV) == cPDV 
			If DATE() <> SLW->LW_DTABERT .And. VAZIO(SLW->(LW_DTFECHA)) 
				lHora := .F.
			Elseif VAZIO(SLW->(LW_DTFECHA))
                lCxAberto := .T.
                nRecSLW   := SLW->(Recno()) 
	        Endif
			SLW->(DbSkip())
		End
	Endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fr271ISelIºAutor  ³Vendas Clientes     º Data ³  20/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a Chamada Para a Selecao do Item a Ser Cancelado de     º±±
±±º          ³Acordo com o Tipo de Tela (Touch/Tradicional)               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaFRT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           

Function Fr271ISelItem( aItens		, lContinua	 , nCancItem	, cCancProd,;
					 	nCancQtde	, aCancItens , nQtdeNova	  )
Local oGrid
Local nFor    	:= 1   
Local aData   	:= {}                                                                      
Local aSelItem	:= {}
Local aSizes  	:= { 20,200 }
Local aHeader 	:= { "Cod.", "Descricao", "Qtde" }
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )

If ! Vazio(aItens) 
	For nFor := 1 to Len(aItens)
		If ! aItens[nFor][AIT_CANCELADO]
			aAdd(aData,{aItens[nFor][1],aItens[nFor][4],aItens[nFor][5]})
		Endif
	Next

	If ! Vazio(aData)
		If lTouch
			oGrid := TchGridObj():New( , , 350, 720, "Touch Grid Object", , , aHeader, aSizes, aData,  .F.,,)
			If oGrid:Activate()
				aSelItem:= oGrid:GetSelData()
				nCancItem := aSelItem[1][1]
				If ! Vazio(nCancItem)
					lContinua := .T.
				Endif
			EndIf
		Else
			Frtx272T02(	@aItens		, @lContinua	, @nCancItem	, @cCancProd,;
						@nCancQtde	, @aCancItens	, @nQtdeNova	  )
		Endif 
	Endif
Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271IEfCa³ Autor ³Vendas Clientes        ³ Data ³05/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o Cancelamento de um Item (F8)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr271IEfCanc(	oCupom   	, oVlrTotal		, nVlrTotal	, nVlrBruto		,;
						nMoedaCor	, nTotItens		, oTotItens	, oTmpQuant		,;
						nTmpQuant	, oCodProd		, cCodProd	, nTaxaMoeda	,;
						cOrcam		, lContinua		, nI		, cSupervisor	,;
						aItens		, _aMultCanc	, uCliTPL	, uProdTPL		,;
						nTotDedIcms	, aMoeda		, aImpsSL1	, aImpsSL2		,;
						aImpsProd	, aImpVarDup	, aTotVen	, aCols			,;
						aHeader		, nValor 		, cMVLJPREC	, aRegTEF		,;
						lRecarEfet	, lCancItRec	, nVlrMerc	)

Local cVlrItem
Local nRet
Local cRet         	:= ""
Local cCancProd    	:= Space(TamSX3("BI_DESC")[1])
Local nX,nY			:= 1
Local nE			:= 1
Local nMaxElem     	:= 1
Local _aItens
Local aCancItens   	:= {}
Local nQtdeNova    	:= 0
Local cCodigo
Local nDec 		   	:= TamSX3("L2_QUANT")[2]
Local lFRTCODB2t   	:= ExistTemplate("FRTCODB2")	// verifica se existe o PONTO DE ENTRADA FRTCODB2
Local lFRTCancelat 	:= ExistTemplate("FRTCancela")// verifica se existe o PONTO DE ENTRADA FRTCancela
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nCont         := 0                           // Variavel contador
Local lEmitNFCe		:= LjEmitNFCe()
Local aAuxICMSST	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes				³
//³Paises: Chile/Colombia - F1CHI			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5        := GetRpoRelease ("R5") .AND. cPaisLoc$"CHI|COL"

DEFAULT nValor		:= 0
DEFAULT cMVLJPREC	:= ""
DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT lCancItRec	:= .F.
DEFAULT nVlrMerc	:= 0

If cPaisLoc == "POR"
	If nCancItem <> 0
		AAdd(aCancItens,(nCancItem))
	EndIf
	_aItens  := FR271HCanP( @aCancItens	, @_aMultCanc )
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
		DbSeek(xFilial()+cOrcam+FR271BPegaIT(aItens[nI][AIT_ITEM]))
		aSL2 := {{"L2_SITUA",	"05"}}				// "05" - Solicitado o Cancelamento do Item
		FR271BGeraSL("SL2", aSL2)
		
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
		nRet := IFCancItem(nHdlECF, Str(aItens[nI][AIT_ITIMP],3),;
		cCodigo,;
		aItens[nI][AIT_DESCRI],;
		AllTrim(Str(aItens[nI][AIT_QUANT],7,nDec)),;
		AllTrim(Str(aItens[nI][AIT_VRUNIT],14,2)),;
		AllTrim(Str(aItens[nI][AIT_VALDESC],14,2)),;
		aItens[nI][AIT_ALIQUOTA],Nil,;
		aItens[nI][AIT_IMPINCL])
		If nRet == 0
			If LjGetOPBM() <> Nil .AND. aItens[nI][AIT_PBM]
				LjCancProdPBM( cCodigo, aItens[nI][AIT_QUANT] )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o valor da deducao de ICMS no cancelamento do item³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
				If SF4->F4_AGREG == "D"
					nTotDedIcms -= aItens[nI][AIT_DEDICMS]
				Endif
			Endif

			//antes de excluir o item, zeramos seus valores referentes a ICMS-ST e FECP do vetor estatico do LOJNFCE.PRW
			If lEmitNFCe .AND. FindFunction("LjSetICMST")
				//criamos o array dos impostos com valores zerados
				aAuxICMSST := Array(6)	//verificar o tamanho do array aICMSST quando for realizar manutenção
				AFill(aAuxICMSST, 0)

				//substituimos o array
				LjSetICMST( {SL2->L2_ITEM, aAuxICMSST}, 2 )

				//eliminamos o array da memoria
				aSize( aAuxICMSST, 0 )
				aAuxICMSST := Nil
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelar o Item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SL2", .F.)
			SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
			dbDelete()
			MsUnLock()
			
			aItens[nI][AIT_CANCELADO] := .T.								// Marca Como Cancelado
			nVlrTotal-= (aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
			nVlrBruto-= (aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
			nValor	 -= (aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
			If !aItens[nI][AIT_IMPINCL]
				If cPaisLoc == "MEX"
					nVlrMerc :=  aItens[nI][AIT_VRUNIT]
				EndIf					
			
				If lLocR5 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Release 11.5 - Localizacoes				³
					//³Subtrair do total de mercadorias o valor ³
					//³do item sem inclusao de impostos   		³
					//³Paises: Chile/Colombia - F1CHI			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrMerc -=  A410Arred((aItens[nI][AIT_VRUNIT]*aItens[nI][AIT_QUANT]),"L2_VRUNIT",nMoedaCor)
				EndIf
			Else
				nVlrMerc -=	(aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALDESC] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL])
			EndIf
			
			If !lTouch
				oVlrTotal:Refresh()
			Endif
			
			cVlrItem := Transform((aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI] + aItens[nI][AIT_VALSOL]), PesqPict("SL2","L2_VLRITEM",13,nMoedaCor))
			oCupom:AppendText(( "")+ chr(10) + chr(13))
			oCupom:AppendText(( STR0007+StrZero(aItens[nI][AIT_ITEM],3)+STR0008)+ chr(10) + chr(13))	// "I T E M  " "  C A N C E L A D O"
			oCupom:AppendText(( Space(19)+aItens[nI][AIT_ALIQUOTA]+"%"+cVlrItem )+ chr(10) + chr(13))
			oCupom:GoEnd()
			
			nTotItens--
			
			If !lTouch
				oTotItens:Refresh()
			EndIf
			
			If lRecarEfet
				aProdRcg   := StrToKarr(cMVLJPREC , "/")  
				nPosProdRc := Ascan(aProdRcg,{|x| AllTrim(x)  == AllTrim(aItens[nI][AIT_COD]) } )

				If nPosProdRc > 0
					oTef:FinalTrn(0)
					aRegTEF		:= {}
					lCancItRec	:= .F.
					FrtCanItRe(.F.)
					lRecarEfet	:= .F.
				EndIf
			EndIf
			
			If cPaisLoc <> "BRA"
				
				If lLocR5 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Release 11.5 - Localizacoes						³
					//³Abater valor total dos impostos do item excluido	³
					//³Paises: Chile/Colombia - F1CHI					³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					For nY := 1 To Len(aImpsSL2[nI][3])
						nE := Ascan( aImpsSL1,{|x| x[1] == aImpsSL2[nI][3][nY][1]})						
						aImpsSL1[ nE,3 ] -= aImpsSL2[nI][3][nY][4]	//Valor do imposto
						aImpsSL1[ nE,5 ] -= aImpsSL2[nI][3][nY][3]	//Base do imposto												
					Next nI 					
				Else	
					//Abate o valor dos impostos, referente ao item excluido,
					//do array aImpsSL1, para futura gravacao no arquivo SL1.
					For nCont := 1 To Len(aImpsSL2[nI][3])
						nE := Ascan( aImpsSL1,{|x| x[1] == aImpsSL2[nI][3][nCont][1]})
												
						aImpsSL1[ nE,3 ] -= aImpsSL2[nI][3][nCont][4]	//Valor do imposto no cabecalho
						aImpsSL1[ nE,5 ] -= aImpsSL2[nI][3][nCont][3]	//Base do imposto no cabecalho											
						
					Next nCont
				EndIf
				
				// Efetua a marcacaoo dos itens cancelados   
				For nCont := 1 to Len(aItens)    
					If aItens[nCont][AIT_CANCELADO]  
					
						nI := aItens[nCont][AIT_ITEM]	
						//Marca como cancelada a posicao referente no aImpsSL2
						aCols[nI][Len(aHeader)+1] := .T.
								
						//Marca como cancelada a posicao referente no aImpsSL2
						aImpsSL2[nI][5] := .T. 
								
						//Marca como cancelada a posicao referente no aImpsProd
						aImpsProd[nI][5] := .T. 
							
					EndIf	   
				Next nCont 
				
				FR271ITotVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda	, @aTotVen	,; 
							@aMoeda)
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
				ExecBlock("FRTCancela",.F.,.F.,{1,cSupervisor,aItens[nI][AIT_ITEM],uProdTPL})
			EndIf
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
Return

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271ITotP³ Autor ³Vendas Clientes        ³ Data ³02/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Total pago na venda                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271ITotPag(aPgtos)
Local nPago := 0
Local nI

	if ! Vazio( aPgtos )
		For nI := 1 to len( aPgtos )
	  		nPago += aPgtos[nI][2]
		Next nI
	EndIf

Return nPago
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271IQual³ Autor ³Vendas Clientes        ³ Data ³02/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Total pago na venda                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fr271IQualAdm(	aData	, aPgtos	, nI	, aTpAdmsTmp)

Local oGrid
Local aHeader   := { "Tipo", "Código", "Nome" }
Local aSizes    := { 15, 20, 150 }
Local aRetItems := { }
Local aRetData  := { }
Local cMensGrid	:= "CONVENIADAS - Valor: " + Ltrim(Transform(aPgtos[nI][2],"@E 999,999.99")) 

// Não encontrou nada
If Empty(aData)
	Aviso("Aviso",STR0025 + aPgtos[nI][3] + STR0026,{"OK"}) // Nao existem Administradoras do Tipo "Tipo Operadora" a serem apresentadas, verifique !
Else

	oGrid := TchGridObj():New( nil, nil, 350, 500, STR0027, cMensGrid , nil, aHeader, aSizes, aData, .F. , nil, nil, { "SAE", { "AE_TIPO", "AE_COD", "AE_DESC" } }, "FRTSELCONV"  ) // "Escolha a Administradora"
	
	If oGrid:Activate()
	
		aRetItems := oGrid:GetSelItems()
		aRetData  := oGrid:GetSelData()
		
		aRetData := AClone( aTpAdmsTmp[ aRetItems[1] ] )
		
	EndIf
	
EndIf
Return(aRetData)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271IValid ³ Autor ³Vendas Clientes      ³ Data ³27/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VErifica se o Cnpj eh valido                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr271IValid(cCNPJ	, aCNPJVLD)

Local lRet          := .F.                   // Valida se pode atualizar preco

If Len(aCNPJVLD) == 0
	AAdd( aCNPJVLD, {"47427653001197", CTOD("30/04/2007")}) // empresa Teste
	AAdd( aCNPJVLD, {"53946208000164", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"53946208000245", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"17314329000120", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"17314329000391", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"17431432900553", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"17314329000634", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07242417000100", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07242417000290", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07242417000371", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"02440495000103", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"02440495000286", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"02440495000367", CTOD("30/04/2007")}) 
	AAdd( aCNPJVLD, {"02440495000448", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07399658000167", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07399658000248", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"60946324000149", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"03935377000120", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"07397962000175", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"00322439000130", CTOD("30/04/2007")})
	AAdd( aCNPJVLD, {"05587491000132", CTOD("30/04/2007")})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida pelo CNPJ e pela data limite³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Ascan(aCNPJVLD,{|x| AllTrim(x[1]) == AllTrim(cCNPJ) .AND. DTOS(dDatabase) <= DTOS(x[2])}) > 0 

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr271ICancITºAutor  ³Vendas Cliente      º Data ³  04/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida cancelamento do item não permitindo caso seja         º±±
±±º          ³ de orcamento importado do Venda Assistida.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr271ICancIT(lContinua, nCancItem)
Local aSavAreaL2 := SL2->(GetArea())    													//Area atual
Local lRet		 := .F.																		//Retorno da funcao
Local cItem		 := FRTPegaIT(nCancItem)													//Item
Local cNumOrig	 := GetAdvFVal("SL2","L2_NUMORIG",xFilial("SL2")+SL1->L1_NUM+cItem,1,"")	//Numero de origem
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lR5			:= GetRpoRelease ("R5")
Local lLjcFid	 	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() .AND. lR5				//Indica se a recarga de cartao fidelidade esta ativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
//³ Release 11.5 - Cartao fidelidade	  		  |
//³ Reinicializa variaveIs de cartao fidelidade	  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
If lLjcFid
	If FA271aGrcf ()
		LaFunhDelS ()
		FA271aSrcf (.F.)
		Fa271aSpfw (.F.)
	EndIf	
EndIf	                


If lContinua
	If !Empty(cNumOrig)
		MsgAlert(STR0028+cNumOrig,STR0001)	//"O item não podera ser cancelado no FrontLoja, favor realizar manutenções no Venda Assistida. Orc: ","Atenção"
		lRet := .T.
	EndIf
EndIf

RestArea(aSavAreaL2)						

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr271ITSIDºAutora ³Vendas Clientes     º Data ³  20/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o dígito informado é correto para o controle de  º±±
±±º          ³ múltiplos cartões para a interface Touch Screen.           º±±
±±º          ³ Motivo da criacao da funcao: Devido interacao com o tecladoº±±
±±º          ³ virtual utilizar variavel numerica para insercao de somenteº±±
±±º          ³ numeros, impossibilitou validar o campo por ser string.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
Function Fr271ITSIDValid(cForma, nFormaID, aPgtos, cFormaID)
Local lRet := .T.	// Retorno da funcao

// Chamada da funcao padrao de validação do FormaID
If Fr271IIDValid(cForma, AllTrim(Str(nFormaId)), aPgtos)
	cFormaID := AllTrim(Str(nFormaId))
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FR271IRec³ Autor ³Vendas Clientes        ³ Data ³07/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a chamada a funcao de Recarga de Ceular - Direcao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem TEF pendente no SITEF.             ³±±
±±³          ³ ExpA1 - Guarda a transacao TEF Pendente					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    

Function FR271IRCel(	oHora		, cHora			, oDoc			, cDoc			,;		
						oCupom		, cCupom		, nVlrPercIT	, nLastTotal	,;	
						nVlrTotal	, nLastItem		, nTotItens		, nVlrBruto		,;	
						oDesconto	, oTotItens		, oVlrTotal		, oFotoProd		,; 
						nMoedaCor	, cSimbCor		, oTemp3		, oTemp4		,; 
						oTemp5		, nTaxaMoeda	, oTaxaMoeda	, nMoedaCor		,; 
						cMoeda		, oMoedaCor		, cCodProd		, cProduto		,; 
						nTmpQuant	, nQuant		, cUnidade		, nVlrUnit		,; 
						nVlrItem	, oProduto		, oQuant		, oUnidade		,; 
						oVlrUnit	, oVlrItem		, oPgtos		, oPgtosSint	,; 
						aPgtos		, aPgtosSint	, cOrcam		, cPDV			,;
						lTefPendCS 	, aTefBKPCS		, oDlgFrt		, cCliente		,;
						cLojaCli	, cVendLoja		, lOcioso		, lRecebe		,;
						lLocked		, lCXAberto		, aTefDados		, dDataCN		,;
						nVlrFSD		, lDescIT		, nVlrDescTot	, nValIPI		,;
						aItens		, nVlrMerc		, lEsc			, aParcOrc		,;
						cItemCOrc	, aParcOrcOld	, aKeyFimVenda	, lAltVend		,;
						lImpNewIT	, lFechaCup		, aTpAdmsTmp	, cUsrSessionID	,;
						cContrato	, aCrdCliente	, aContratos	, aRecCrd		,;
						aTEFPend	, aBckTEFMult	, cCodConv		, cLojConv		,;
						cNumCartConv, uCliTPL		, uProdTPL		, lDescTotal	,; 
						lDescSE4	, aVidaLinkD	, aVidaLinkc 	, nVidaLink		,;
						cCdPgtoOrc	, cCdDescOrc	, nValTPis		, nValTCof		,; 
						nValTCsl	, lOrigOrcam	, lVerTEFPend	, nTotDedIcms	,;
						lImpOrc		, nVlrPercTot	, nVlrPercAcr	, nVlrAcreTot	,;
						nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	, nNumParcs		,;
						aMoeda		, aSimbs		, cRecCart		, cRecCPF		,; 
						cRecCont	, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen		, nTotalAcrs	, lRecalImp		,;
						aCols		, aHeader 		, aDadosJur		, aCProva		,;
						aFormCtrl	, nTroco		, nTroco2 		, lDescCond		,; 
						nDesconto	, aDadosCH		, lDiaFixo		, aTefMult		,;
						aTitulo		, lConfLJRec	, aTitImp		, aParcelas		,;
						oCodProd	, cItemCond		, lCondNegF5	, nTxJuros		,;
						nValorBase	, oTimer		, lResume		, oOnOffLine	,;
						nValIPIIT	, _aMult		, _aMultCanc	, nVlrDescIT	,;
						oFntMoeda	, lBscPrdON		, oPDV			, aICMS			,;
						lDescITReg	, cMensagem		, lAbreCup)
							
							
Local lTEFPendRec  	:= .T.   							// Controla se tem transacao TEF jah realizada e pendente 
Local lTefMult	   	:= SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local aRecTEFMult  	:= {}                               //Array MultiTEF
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. ) //Tela Touch
Local cTotRCelNFis	:= "" 		// declaracao da variavel a ser utilizada na impressao do recebimento nao fiscal - LJGRVREC
Local nX			:= 0		//Array contador
Local aNccRecSel 	:= {}       //NCCs do cliente apresentadas na tela que poderao ser utilizadas como pagamento no recebimento de titulos
Local lSucesso		:= .F. 		//Recarga Realizada com sucesso
Local oWSFinaCel	:= Nil		//Objeto da Recarga        
Local aDadosTrn		:= {}		//Dados da transacao

DEFAULT cMensagem 	:= ""
DEFAULT lAbreCup	:= .F.

If cGetCliDir == NIL
   cGetCliDir := GetClientDir()
EndIf   

If !lOcioso .OR. lRecebe
	Return(NIL)
EndIf             

lConfLJRec	:= .F.
aTitImp 	:= {}			
aParcelas 	:= {}

If FindFunction("L010TRCl")  

	oWsFinaCel		:= WSLJFINACEL():New()
	oWsFinaCel:_URL 	:= "http://"+Alltrim(LJGetStation("WSSRV"))+"/LJFINACEL.apw" 

	lSucesso := L010TRCl(oWsFinaCel, @aDadosTrn) //Precisa salvar a imagem do comprovante na última posicao do array
	//Valida se a operação foi realizada com sucesso
     

	If lSucesso
		lRecebe 	:=  .T.
	    nVlrTotal 	:= 0
	    
		cCupom := ""
		
		If ExistBlock("FRTCLICHE")
			aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
	        For nX := 1 To Len(aFRTCliche)
	        	oCupom:AppendText(aFRTCliche[nX])
	        Next nX
		Else
			oCupom:AppendText((chr(10) + chr(13)))
			oCupom:AppendText((STR0002)+ chr(10) + chr(13))	// "        MICROSIGA SOFTWARE S.A.         "
			oCupom:AppendText((STR0003)+ chr(10) + chr(13))	// "    Av. Braz Leme, 1631 - São Paulo     "
			oCupom:AppendText((STR0004)+ chr(10) + chr(13))	// "          www.microsiga.com.br          "
		EndIf
		
		oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0005+PadR(cPDV,4)+STR0006+StrZero(Val(cDoc)+1,TamSX3("L1_DOC")[1]))	+ chr(10) + chr(13)) // "  PDV:" "   COD:"
		oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
		oCupom:AppendText((STR0029) + chr(10) + chr(13))	// "            RECARGA DE CELULAR          "
		oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
		nVlrTotal := aDadosTrn[13] //tOTAL DA RECARGA  
		oCupom:AppendText((STR0011+Transform(nVlrTotal, PesqPict("SE1", "E1_VALOR", 15)))+ chr(10) + chr(13))	// "   Valor          = "
		oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
		
		nVlrBruto 	:= nVlrTotal
		
		aParcOrc 	:= {}
		aParcOrcOld := {}
	
		nVlrDescTot	:= 0														// VALOR DO DESCONTO
		nVlrPercTot	:= 0														// PERCENTUAL DE DESCONTO
		nVlrAcreTot	:= 0														// VALOR DO ACRESCIMO
		nVlrPercAcr := 0														// PERCENTUAL DO ACRESCIMO
		nVlrDescCPg	:= 0														// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)
	
		If !lTouch
			oVlrTotal:Refresh()
		Endif
	
		aKeyFimVenda := FrtSetKey()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Declara o conteudo vazio ao array para o uso na impressao do recebimento nao fiscal.³
		//³O array será devidamente preenchido na função FR271GEncerra                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aTitImp       := {}                                        
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Declara o conteudo da variavel para o uso na impressao do recebimento nao fiscal.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cGetCliDir == NIL
			cGetCliDir := GetClientDir()
		EndIf
		If cProfStr1 == NIL
			cProfStr1 := GetPvProfString("recarga celular", "Totalizador", "01", cGetCliDir+"SIGALOJA.INI") 
		EndIf
		cTotRCelNFis   := cProfStr1
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a função para finalização da venda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                            	
		aPgtos := FR271EFimVend(	@lTEFPendRec	, @aRecTEFMult	, Nil			, @oHora			,; 		
									@cHora			, @oDoc			, @cDoc			, @oCupom			,;		
									@cCupom			, @nVlrPercIT	, @nLastTotal	, @nVlrTotal		,;		
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oDesconto		,;		
									@oTotItens		, @oVlrTotal	, @oFotoProd	, @nMoedaCor		,;		
									@cSimbCor		, @oTemp3		, @oTemp4		, @oTemp5			,;		
									@nTaxaMoeda		, @oTaxaMoeda	, @nMoedaCor	, @cMoeda			,;		
									@oMoedaCor		, @cCodProd		, @cProduto		, @nTmpQuant		,;		
									@nQuant			, @cUnidade		, @nVlrUnit		, @nVlrItem			,;		
									@oProduto		, @oQuant		, @oUnidade		, @oVlrUnit			,;		
									@oVlrItem		, /*LF7*/		, @oPgtos		, @oPgtosSint		,;
									@aPgtos			, @aPgtosSint	, @cOrcam		, @cPDV				,;
									lTefPendCS		, aTefBkpCS		, @oDlgFrt		, @cCliente			,;	
									@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe			,;
									@lLocked		, @lCXAberto	, @aTefDados	, @dDataCN			,;
									@nVlrFSD		, @lDescIT		, @nVlrDescTot	, @nValIPI			,;	
									@aItens			, @nVlrMerc		, @lEsc			, @aParcOrc			,;
									@cItemCOrc		, @aParcOrcOld	, @aKeyFimVenda	, @lAltVend			,;
									@lImpNewIT		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID	,;
									@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd			,;
									@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv			,;
									@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal		,; 
									@lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	, @nVidaLink		,;
									@cCdPgtoOrc		, @cCdDescOrc	, @nValTPis		, @nValTCof			,; 
									@nValTCsl		, @lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms		,;
									@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot		,;
									@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs		,;
									@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF			,; 
									@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd		,; 
									@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp		,;
									@aCols			, @aHeader 		, @aDadosJur	, @aCProva			,;
									@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond		,; 
									@nDesconto		, @aDadosCH		, @cItemCond	, @lCondNegF5		,;
									@nTxJuros		, @nValorBase	, @lDiaFixo		, @aTefMult 		,;
									@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas		,;
									@oCodProd		, /*@oMensagem*/, /*@oFntGet*/	, /*@cCodDep*/		,;
									/*@cNomeDEP*/	, /*@cTipoCli*/	, /*@cEntrega*/ , /*@aReserva*/		,;
									/*@lReserva*/	, /*@lAbreCup*/	, /*@nValor*/	, @oTimer			,;
									@lResume		, /*aValePre*/	, /*aRegTEF*/	, /*lRecarEfet*/	,;
									/*lCancItRec*/	, @oOnOffLine	, @nValIPIIT	, @_aMult			,;
									@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON		,;
									@oPDV			, @aICMS		, @lDescITReg	, /*cNumDAV*/		,;
									/*cCliCGC*/		, @cMensagem	, /*@cDocFo*/	, @aNccRecSel  		,;
									@lSelTefManu)
		If lConfLJRec   
		
		    If lTefMult .AND. LEN(aRecTEFMult) > 0
		       aTEFMult  := AClone(aRecTEFMult)
		    EndIf   
		    
		    nVlrTotal := aPgtos[1][2]

			If ! L010RCGr("009"		, nVlrTotal		, aDadosTrn		, @oWsFinaCel	,;
							aPgtos	 	, @nTroco       , cTotRCelNFis 	, aTEFMult,;
							.T.			, lTEFMult)  
			    //Funcção que verifica a impressão do comprovante de recarga e que gera o envio dos títulos para a retaguarda

				oCupom:SetupdatesEnable(.F.)
				oCupom:AppendText((" ") + chr(10) + chr(13))
				oCupom:AppendText((STR0030) + chr(10) + chr(13))  //"Recarga de Celular não efetuada"
				oCupom:AppendText((STR0031) + chr(10) + chr(13))  //"Houveram problemas na impressão do comprovante e/o gravação dos títulos"
				oCupom:AppendText((" ") + chr(10) + chr(13))
				oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			    oCupom:SetupdatesEnable(.T.)
			    oCupom:GoEnd()
			Endif

			aBckTEFMult  := {}
			lVerTEFPend  := .F.
		Else
				LOJA010T( "F"   ,"D"   ,NIL   ,NIL   ,;	//Antigamente esta função nao retornava verdadeiro ou falso
			         	NIL   ,NIL   ,NIL   ,NIL   )
			
         EndIf
	EndIf
	
	FreeObj(oWsFinaCel)
	oWsFinaCel := NIL
EndIf

Return NIL
