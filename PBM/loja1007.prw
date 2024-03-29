#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1007.CH"
#INCLUDE "DEFTEF.CH"
  
//旼컴컴컴컴컴컴컴��
//쿟ipo de operacao�
//읕컴컴컴컴컴컴컴��
#DEFINE	VENDA 	1
#DEFINE CANCEL 	2

User Function LOJA1007 ; Return  // "dummy" function - Internal Use

/*---------------------------------------------------------------------------
굇튡rograma  쿗JCPBM    튍utor  쿣endas Clientes     � Data �  03/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎ria a classe LJCPBM                                        볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Class LJCPBM

	Data oPbm														// Obejeto PBM
	Data oSlz														// Objeto do arquivo
	Data oTelaPBM													// Objeto tela
	Data nTpOpera													//Tipo da operacao 1-Venda 2-Cancelamento
	
	Method PBM()													// Metodo construtor
	Method IniciaVend( cCupom, cOperador, cTpDoc )					// Inica a venda com o PBM
	Method VendProd( cCodBarra, nQtde, nPrUnit, nPercDesc, ;		// Realiza a venda do produto
					 lItemPbm, lPrioPbm )
	Method CancProd( cCodBarra, nQtde)								// Cancela o produto da PBM
	Method FinalVend(cDoc, cSerie, cKeyDoc)												// Finaliza a venda
	Method BuscaRel()												// Busca relatoria para impress�o
	Method BuscaSubs()												// Verifica se tem subsidio
	Method ConfProd( cCodBarra, nQtde, lOk)			// Confirma os produtos vendidos
	Method ConfVend(lConfirma)										// Confirma a venda na PBM
	Method CancPBM()												//Cancela a transacao total da PBM		
	Method SelecPbm(cNomePBM,lCancela)												//Metodo que ira selecionar a PBM
	Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador,aVDLink)
	Method VDLinkProd(aVDLink)
	Method VDLinkVenda(cCodAut,nCupom,dData,cHora,cOperador,aVDLink)
	Method VDLinkCanc(lCancTotal,nCupom,dData,cHora,cOperador,aVDLink)
	Method PharmSCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink)
	Method FuncCrCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink)
	
	//Metodos internos
	Method CarregaCBO()												// Carrega as informacoes do arquivo SLZ
	Method ExecutaPBM(cCupom, cOperador)							// Retorna a PBM selecionada na tela
	Method GetTpOpera()												//Retorna o tipo de operacao selecionado
	
EndClass
        
/*---------------------------------------------------------------------------
굇튡rograma  쿛BM       튍utor  쿣endas Clientes     � Data �  03/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Construtor do Classe LJCPBM                                볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method PBM() Class LJCPBM

::oPbm 		:= Nil			// Objeto a ser criado
::oSlz    	:= Nil			// Inicializacao do Objeto
::oTelaPBM	:= Nil			// Objeto da Tela
::nTpOpera	:= 0
	
Return Self


/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿔niciaVend튍utor  쿘icrosiga           � Data �  03/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Inicia o metodo do processo de venda                       볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametro � 1.ExpC1 - Numero do cupom Fiscal                           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   � Logico                                                     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method IniciaVend( cCupom, cOperador, cTpDoc ) Class LJCPBM
	
Local lRet 		:= .F.		//Retorno do Metodo

lRet := ::oPbm:IniciaVend(cCupom, cOperador, cTpDoc)

//Seta o tipo de operacao como venda
::nTpOpera := VENDA
	
Return lRet                                                        

/*---------------------------------------------------------------------------
굇튡rograma  쿣endProd  튍utor  쿣endas Clientes        � Data �  09/04/07볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Realiza a venda do Produto                                 볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� 1.ExpC1 - Codigo de barras do produto                      볍�
굇�          � 2.ExpN1 - Quantidade do produto                            볍�
굇�          � 3.ExpN2 - Preco do produto                                 볍�
굇�          � 4.ExpN3 - Percentual de desconto do produto                볍�
굇�          � 5.ExpL1 - Se o item foi enviado para pbm                   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method VendProd( cCodBarra, nQtde, nPrUnit, nPercDesc, ;
				 lItemPbm, lPrioPbm ) Class LJCPBM
Local lRet := .T.
lRet := ::oPbm:VendProd( cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm, lPrioPbm )

Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿎ancProd  튍utor  쿣endas Clientes     � Data �  09/04/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Realiza o cancelamento dos produtos vendidos no PBM        볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� 1.ExpC1 (cCodBarra)- Codigo de barras do produto           볍�
굇�          � 2.ExpN1 (nQtde)	- Quantidade do produto                   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method CancProd( cCodBarra, nQtde ) Class LJCPBM

Local lRet	 := .T.		//Retorno da funcao

lRet := ::oPbm:CancProd( cCodBarra, nQtde )

Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿑inalVend 튍utor  쿣endas Clientes     � Data �  09/04/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Finaliza a venda no PBM                                    볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCPBM
Local lRet := .T.		//Retorno da funcao

lRet := ::oPbm:FinalVend(cDoc, cSerie, cKeyDoc)

Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿍uscaRel  튍utor  쿣endas Clientes     � Data �  04/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Retorna o relatorio a ser impresso, na finaliza豫o da ven- 볍�
굇�          � da no processo da PBM                                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method BuscaRel() Class LJCPBM
	
	Local aRet := {}		// Retono da funcao
	
	aRet := ::oPbm:BuscaRel()

Return aRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿍uscaSubs 튍utor  쿣endas Clientes     � Data �  04/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Busca o subsidio, caso haja                                볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method BuscaSubs() Class LJCPBM

	Local nRetVal := 0		// Retorna o valor do subisidio, caso haja
	
	nRetVal := ::oPbm:BuscaSubs()
	
Return nRetVal

/*---------------------------------------------------------------------------
굇튡rograma  쿎onfProd  튍utor  쿣endas Clientes     � Data �  04/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Confirma os produtos vendidos na PBM                       볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method ConfProd( cCodBarra, nQtde, lOk ) Class LJCPBM

	Local lRet := .T.		// Retorno da funcao
	
	lRet := ::oPbm:ConfProd(cCodBarra, nQtde, lOk)
	
Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿎onfVend  튍utor  쿣endas Clientes     � Data �  04/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Confirma a venda na PBM                                    볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA/FRONTLOJA                                         볍�
---------------------------------------------------------------------------*/
Method ConfVend(lConfirma) Class LJCPBM
Local lRet := .T.

If ::oPbm:oSitefPbm:oClisitef <> Nil //TOTVSPDV
	::oPbm:oSitefPbm:oClisitef:oTransacao := ::oPbm:oDadosTran
	If !Empty(AllTrim(::oPbm:oSitefPbm:oClisitef:oTransacao:cCupomFisc))
		::oPbm:oSitefPbm:oClisitef:oTransacao:nCupom := Val(::oPbm:oSitefPbm:oClisitef:oTransacao:cCupomFisc)
	EndIf
	::oPbm:oSitefPbm:oClisitef:oTransacao:cHora := ::oPbm:oSitefPbm:oClisitef:oTransacao:cHorario
	::oPbm:oSitefPbm:oClisitef:oTransacao:dData := SToD(::oPbm:oSitefPbm:oClisitef:oTransacao:cDataFisc)
EndIf
::oPbm:ConfVend(lConfirma)

Return lRet

/*---------------------------------------------------------------------------
굇튡rograma  쿎ARREGACBO튍utor  쿣endas Clientes     � Data �  17/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Carrega a combo com as informacoes do arquivo SLZ          볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
---------------------------------------------------------------------------*/
Method CarregaCBO() Class LJCPBM
	
	Local nI 			:= 0		// Variavel do FOR
	Local aComboPbm     := {}		// Array que contera todas as PBMS
	
	::oSlz := LJCCarregaSLZ():CarregaSLZ()
	::oSlz:LeArqSLZ()
	
	For nI := 1 To Len( ::oSlz:aDadosSLZ )
		
		AADD( aComboPbm, ::oSlz:aDadosSLZ[nI]:cNome )
		
	Next

Return aComboPbm

/*---------------------------------------------------------------------------
굇튡rograma  쿐xecutaPBM튍utor  쿘icrosiga           � Data �  09/17/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Retorna a PBM selecionada na tela.                         볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
---------------------------------------------------------------------------*/
Method ExecutaPBM(cCupom, cOperador) Class LJCPBM
	
	Local cSelec	:= ""		// PBM Selecionada
	Local nPos		:= 0		// Posicao do array
	Local cFuncao	:= ""		// Funcao a ser executada
	Local lRet		:= .F.		// Retorno da funcao
	
	::oTelaPBM:Show()
	
	If ::oTelaPBM:lCancelado == .F.
		cSelec 	:= ::oTelaPBM:cRetSelect
        nPos 	:= aScan( ::oSlz:aDadosSLZ, { |x| Alltrim(x:cNome) == Alltrim(cSelec) }	)
        If nPos > 0
	        cFuncao := ::oSlz:aDadosSLZ[nPos]:cFuncao
	        ::oPbm 	:= &(cFuncao)
	        lRet := .T.
		EndIf
	EndIf

Return lRet

/*---------------------------------------------------------------------------
굇튝etodo    쿎ancPBM   튍utor  쿣endas Clientes     � Data �  21/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎ancela a transacao da PBM.                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
---------------------------------------------------------------------------*/
Method CancPBM() Class LJCPBM
Local lRetorno := .F.		//Variavel de retorno do metodo 	

lRetorno := ::oPbm:CancPBM()

//Seta o tipo de operacao como cancelamento
::nTpOpera := CANCEL

Return lRetorno

/*---------------------------------------------------------------------------
굇튝etodo    쿞elecPbm  튍utor  쿣endas Clientes     � Data �  21/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿞eleciona a PBM.                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿗ogico                                                      볍�
---------------------------------------------------------------------------*/
Method SelecPbm(cNomePBM,lCancela) Class LJCPBM
Local lRet 		:= .F.		//Retorno do Metodo
Local aComboPbm	:= {}		//Combo da PBM
Local aAux		:= {}
Local nX		:= 0

Default lCancela := NIL

aComboPbm := ::CarregaCBO()

If ValType(lCancela) == "L" .And. lCancela
	For nX := 1 to Len(aComboPbm)
		If aComboPbm[nX] $ (_EPHARMA + "|" + _TRNCENTRE)
			Aadd(aAux,aComboPbm[nX])
		EndIf
	Next nX
	aComboPbm := IIF(Len(aAux) > 0, aAux,aComboPbm)
EndIf

If Len( aComboPbm ) > 0
	::oTelaPBM := LJCTelaSelecao():TelaSelec( aComboPbm, STR0003, STR0002  )
	lRet := ::ExecutaPBM()
EndIf

Return lRet

/*---------------------------------------------------------------------------
굇튝etodo    쿒etTpOpera튍utor  쿣endas Clientes     � Data �  26/11/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em retornar o tipo de operacao selecionado.     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿙umerico                                                    볍�
---------------------------------------------------------------------------*/
Method GetTpOpera() Class LJCPBM
Return ::nTpOpera

/*/{Protheus.doc} VDLinkCons
	Executa consulta do Vida Link
	@type  Metodo
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return lRet, logico, executado com sucesso ?
/*/
Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador,aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador,aVDLink)

Return lRet

/*/{Protheus.doc} VDLinkProd
	Validacao Produto VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return lRet, logico, executado com sucesso ?
/*/
Method VDLinkProd(aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:VDLinkProd(aVDLink)

Return lRet

/*/{Protheus.doc} VDLinkVenda
	Validacao Produto VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return lRet, logico, executado com sucesso ?
/*/
Method VDLinkVenda(cCodAut,nCupom,dData,cHora,cOperador,aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:VDLinkVenda(cCodAut,nCupom,dData,cHora,cOperador,aVDLink)

Return lRet

/*/{Protheus.doc} VDLinkCanc
	Cancelamento de Venda Vidalink
	@type  Class
	@author Julio.Nery
	@since 29/04/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCanc(lCancTotal,nCupom,dData,cHora,cOperador,aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:VDLinkVenda(lCancTotal,nCupom,dData,cHora,cOperador,aVDLink)

Return lRet

/*/{Protheus.doc} PharmSCons
	Executa consulta do PharmaSystem
	@type  Metodo
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method PharmSCons(nFuncao	, nValor	, cCupom	, dData	,;
				  cHora	, cOperador	, cRestri, aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:PharmSCons(nFuncao, nValor, cCupom, dData, cHora, cOperador, cRestri, aVDLink)

Return lRet

/*/{Protheus.doc} FuncCrCons
	Executa consulta do Funcional Card
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method FuncCrCons(nFuncao	, nValor	, cCupom	, dData	,;
				  cHora	, cOperador	, cRestri, aVDLink) Class LJCPBM
Local lRet := .F.

lRet := ::oPBM:FuncCrCons(nFuncao, nValor, cCupom, dData, cHora, cOperador, cRestri, aVDLink)

Return lRet