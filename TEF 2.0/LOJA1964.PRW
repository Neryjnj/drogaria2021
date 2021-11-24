#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "LOJA1964.CH"
#INCLUDE "AUTODEF.CH"  

Function LOJA1964 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCCupom         บAutorณVENDAS CRM     บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em armazenar os comprovantes das transacoes     บฑฑ 
ฑฑบ          ณtransacoes de tef.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCCupom
		
	Data oCupom
	Data oFormas //Formas de Pagamento do Cupom Fiscal
	
	Method New() 
	Method Inserir(	cTipo		, oViaCaixa	, oViaCliente	, cTipoTrans,;
					cTotalizador, cFormaPgto, nValor		, nVias		,;
					nTentativas	)
	Method CupomReduzido(lRemove, cMsgProm, cChave)										//Retorna o primeiro cupom reduzido e o exclui da Lista 
	Method RetornarCupons(cTipo, cTotalizador, cTipoTrans)								//Retorna o cupom conforme o Totalizador e o Tipo de Transacao   
	Method InserirFormas( cTipo		, cTotalizador	, cFormaPgto	, nValor		,;
						  cTipoTrans, nVlrSaque		, nVlrVndcDesc	, nVlrDescTEF	)	//Insere as formas de pagamento TEF
	Method RetornarFormas(cTipo, cTotalizador, cTipoTrans)								//Retorna as Formas de Pagamento TEF  
	Method Imprimir(lRelGer)															//Imprime os cupons TEF 
	Method RetornarCompr()																//Retorna os comprovantes a serem impressos
	Method ImprimirCompr(oComprov, oCupons, cTexto, lRelGer)							//Imprive o comprovante  
	Method VerificarImpressao(aRet, lReimprime )										//Verifica se a impressao foi realizada com sucesso e se deve ser realizada a reimpressใo
	Method TGVerificarImpressao(aRet, lReimprime, lRelGer ) 							//Rel. Gerencial Verifica se a impressao foi realizada com sucesso e se deve ser realizada a reimpressใo
	Method ReimpSenSup() 																//Verifica se ้ necessแrio a digita็ใo da senha do superior
	Method ImprimirTxtFisc(oCupons, cTexto)  
	Method RetornarTexto(oCupons)
	Method TGImprimirTxtFisc(oCupons, cTexto)
	Method ImpCpvTPdv()																	//Impressใo do comprovante para Totvs PDV
	Method ImpCpvLoja()																	//Impressใo do comprovante para SIGALOJA

EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LjCCupom                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(	) Class LJCCupom
	Self:oCupom :=  LJCList():New()  //Objeto do Tipo Lista
	Self:oFormas :=  LJCList():New()  //Objeto do Tipo Lista
  
Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInserir      บAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere um cupom Fiscal                      .               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Via da Caixa              						  บฑฑ
ฑฑบ          ณEXPC3  - Via do Cliente           						  บฑฑ   
ฑฑบ          ณEXPN4  - Tipo de Transa็ใo TEF          					  บฑฑ
ฑฑบ          ณEXPC5  - Totalizado Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC6  - Forma de Pagamento           					  บฑฑ
ฑฑบ          ณEXPN7  - Numero de Vias                  					  บฑฑ 
ฑฑบ          ณEXPN8  - Numero de Tentativas            					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Method Inserir(	cTipo			,	oViaCaixa	,	oViaCliente		,	cTipoTrans		,;
				cTotalizador	,	cFormaPgto	,	nValor			,	nVias			,;
				nTentativas		, 	nVlrSaque	,   nVlrVndcDesc 	, nVlrDescTEF		) Class LJCCupom  
				
	Local oCup := Nil
	
	Default cTipo 			:= "G"  	//Tipo do  Comprovante da Tansacao [ Gerencial]
	Default oViaCaixa 		:= NIL	  	//Via do Caixa
	Default oViaCliente 	:= NIL	  	//Via do Cliente
	Default cTipoTrans 		:= ""		//Tipo da Transacao 
	Default cTotalizador 	:= "01" 	//Totalizador do comprovante nใo Fiscal
	Default cFormaPgto 		:= ""  		//Forma de Pagamento
	Default nValor 			:= 0		//Valor do Pagamento 
	Default nVias 			:= 1        //Numero de Vias (2  Caixa + 1 Cliente)
	Default nTentativas 	:= 0 		//Numero de Tentativas de Impressใo  
	Default nVlrSaque		:=	0		//Valor do saque
	Default nVlrVndcDesc	:=	0		//Valor da venda com desconto TEF
	Default nVlrDescTEF		:=	0		//Valor do desconto do TEF   	  
				
				
	oCup := LJCCompr():New(	cTipo			,	oViaCaixa	,	oViaCliente	,	cTipoTrans	,;
							cTotalizador	,	cFormaPgto	,	nValor		,	nVias		,;
							nTentativas		) 

  
	Self:oCupom:Add(oCup)  
	
	//Insere as formas de pagamento 
	Self:InserirFormas(	cTipo		, cTotalizador 	, cFormaPgto	, nValor		, ;
						cTipoTrans	, nVlrSaque 	, nVlrVndcDesc 	, nVlrDescTEF	)

Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetornarCuponsบAutor  ณVendas CRM       บ Data ณ  08/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna as Formas de pagamento                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Totalizador Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC3  - Tipo de Transacao             					  บฑฑ
ฑฑบ			 ณ			C - Pagamento em cartao		    				  บฑฑ
ฑฑบ			 ณ			R - Recarga de Celular   			    		  บฑฑ
ฑฑบ			 ณ			B - Correspondente Bancแrio                       บฑฑ
ฑฑบ		     ณ          D - Pagamento Digital		                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetornarCupons(cTipo, cTotalizador, cTipoTrans) Class LJCCupom
       Local oRetorno := LJCList():New() //Retorno dos cupons
       Local nPos := 0                   //Posicao de busca do Cupom
       Local nTotal := 0                 //Total do Cupom
       
       nTotal := Self:oCupom:Count() 
       
       If nTotal > 0 .AND. ( nPos := Self:oCupom:Seek("cChave", cTipo + cTotalizador + cTipoTrans)  ) > 0
       		
       		//La็o para posicionar na forma de pagamento distinta
        		While nPos <= nTotal .AND.  ;
       		      Self:oCupom:Elements(nPos):cTipo + ;
       		      Self:oCupom:Elements(nPos):cTotalizador +;
       		      Self:oCupom:Elements(nPos):cTipoTrans == cTipo + cTotalizador + cTipoTrans 
       		      
       		      oRetorno:Add( Self:oCupom:Elements(nPos) ) 
       			  nPos++
       		End
       		

       EndIf

Return oRetorno 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCupomReduzidoบAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o cupom Reduzido Class LjCCupom                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPL1  - Remove cupom da lista de impressใo Defalt .F.      บฑฑ
ฑฑบ          ณEXPC2  - Mensagem Promocional do ECF    					  บฑฑ
ฑฑบ          ณEXPC3  - Chave de Busca do Cupom             	    		  บฑฑ
ฑฑบ			 ณ		   Tipo de comprovante + Totalizador + Tipo Transacao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CupomReduzido( lRemove, cMsgProm, cChave ) Class LJCCupom

	Local nPosVinc := 0 //Posicao do primeiro comprovante vinculado
	Local cRetorno 		:= ""									//Retorno do metodo 
	Local nCount 		:= 0										//Variavel auxiliar utilizada no for
	Local lCupomRed		:= SuperGetMV("MV_LJCUPRE",,.F.)        	//Verifica se o sitef esta parametrizado para cupom reduzido
	Local nLinhas		:= 0										//Numero de linhas retornados para impressao
	Local oViaCliente	:= ""										//Auxiliar para armazenar a via do cliente de cada transacao    
	Local cDelimit 		:= CHR(10)									//Delimitador    
	Local nLinhasCup	:= SuperGetMV("MV_LJCUPL",,8)           //Numero de Linhas do comprovante de fechamento
	Local nLinhasProm	:= 0                                     //Numero de Linhas da Mensagem Promocional
	Local lLoop			:= .T.                                   //Variแvel de controle de repeti็ใo
	Local cAux			:= ""                                    //Variแvel auxiliar
	
	Default lRemove := .F.
	Default cMsgProm := "" //Mensagem Promocional

	
	If Self:oCupom:Count() > 0
		nPosVinc := Self:oCupom:Seek("cChave", cChave)
	EndIf
	
	If lCupomRed .AND. nPosVinc > 0        

		oViaCliente := Self:oCupom:Elements(nPosVinc):oViaCliente
 			
		
			//Total de linhas dos cupons (Via Cliente) de todas as transacoes
		If oViaCliente <> NIl
		
			nLinhas := oViaCliente:Count() 
			
		
			For nCount := 1 to nLinhas
			
				cRetorno += oViaCliente:Elements(nCount) + cDelimit 
			
			Next nCont
			
			//Retira o delimitador do fim da string
			If Substr(cRetorno, Len(cRetorno), 1) == cDelimit
				cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 1)
			EndIf
			
        EndIf
		
		//Totaliza as vias da mensagem promocional
		If !Empty(cMsgProm)  
		
			//Retira o delimitador do inicio da string
			If Substr(cMsgProm, 1, 1) == cDelimit
				cMsgProm := Substr(cMsgProm, 2)
			EndIf
			
			//Retira o delimitador do fim da string
			If Substr(cMsgProm, Len(cMsgProm), 1) == cDelimit
				cMsgProm := Substr(cMsgProm, 1, Len(cMsgProm) - 1)
			EndIf
		
			//Conta as linhas da mensagem promocional
			While lLoop
			    //Procura o delimitador na string
				nPos := At(cDelimit, cMsgProm)
			    
			    //Verifica se encontrou o delimitador
				If nPos > 0 
					cAux := Substr(cMsgProm, 1, nPos-1)
					cMsgProm := Substr(cMsgProm, nPos + 1)
					
					If cAux != cDelimit .AND. cAux != CHR(13) 
						nLinhasProm += 1
					Endif
				Else
					nLinhasProm := 1
					lLoop := .F.
				EndIf
			End  
			 

		EndIf
		
		
		nLinhas += nLinhasProm

		
		//So retorna o cupom reduzido se o numero de linhas estiver entre 1 e 8, porque 8 linhas he
		//o limite da mensagem promocional impressa no rodape do cupom fiscal
		If nLinhas > nLinhasCup .Or. Empty(cRetorno)
			If nLinhasProm <= nLinhasCup
				cRetorno := cMsgProm
			Else
				cRetorno := ""
			EndIf
		Else
			cRetorno := cMsgProm + CHR(10) + cRetorno
			
			If lRemove
				//Somente remove se retornar o cupom reduzido
				//Self:oCupom:Remove(nPosVinc)
				Self:oCupons:Elements(nPosVinc):oViaCliente := NIL
			EndIf
		EndIf
		
		//Retira o delimitador do fim da string
		If Substr(cRetorno, Len(cRetorno), 1) == cDelimit
			cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 1)
		EndIf
	
	EndIf
		
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInserirFormasบAutor  ณVendas CRM       บ Data ณ  02/01/13  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere as Formas de pagamento                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Totalizador Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC3  - Forma de pagamento impressa no comprovante		  บฑฑ
ฑฑบ          ณEXPN4  - Valor do Pagamento								  บฑฑ
ฑฑบ          ณEXPC5  - Tipo de Transacao             					  บฑฑ
ฑฑบ			 ณ			C - Pagamento em cartao		    				  บฑฑ
ฑฑบ			 ณ			R - Recarga de Celular   			    		  บฑฑ
ฑฑบ			 ณ			B - Correspondente Bancแrio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method InserirFormas( 	cTipo		, cTotalizador	, 	cFormaPgto		, nValor			, ;
                     	cTipoTrans	, 	nVlrSaque	,	nVlrVndcDesc 	, nVlrDescTEF		) Class LJCCupom 
                       
    Local nPos := 0  //Localiza็ใo das Formas
    
	If Self:oFormas:Count() = 0 .OR. ;
		(nPos := Self:oFormas:Seek("cChave", cTipo+ cTotalizador + cTipoTrans + cFormaPgto)) = 0    
		
		Self:oFormas:Add( LjCFormas():New(		cTipo			, cTotalizador	, cFormaPgto	, nValor 		,;
												NIL				, cTipoTrans 	, NIL			, nVlrSaque		,;
												nVlrVndcDesc 	, nVlrDescTEF									)  )
	Else
		Self:oFormas:Elements(nPos):nValor 			+= nValor   
		Self:oFormas:Elements(nPos):nVlrSaque  		+= nVlrSaque
		Self:oFormas:Elements(nPos):nVlrVndcDesc 	+= nVlrVndcDesc
		Self:oFormas:Elements(nPos):nVlrDescTEF 	+= nVlrDescTEF
	EndIf
  
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetornarFormasบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna as Formas de pagamento                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Totalizador Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC3  - Tipo de Transacao             					  บฑฑ
ฑฑบ			 ณ			C - Pagamento em cartao		    				  บฑฑ
ฑฑบ			 ณ			R - Recarga de Celular   			    		  บฑฑ
ฑฑบ			 ณ			B - Correspondente Bancแrio                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetornarFormas( cTipo, cTotalizador, cTipoTrans	) Class LJCCupom
       Local oRetorno := LJCList():New()  //Retorno das formas
       Local nPos := 0                    //Localiza็ใo das formas
       Local nTotal := 0                  //total das Formas
       
       Self:oFormas:Sort( .T., , "{	|x,y| x:cTipo + x:cTotalizador +  x:cTipoTrans + x:cFormaPgto  < y:cTipo + y:cTotalizador + y:cTipoTrans + y:cFormaPgto  }")       
       
       nTotal := Self:oFormas:Count() 
       
       If nTotal > 0 .AND. ( nPos := Self:oFormas:Seek("cChave2", cTipo + cTotalizador + cTipoTrans)  ) > 0
       		     		
       		//La็o para posicionar na forma de pagamento igual
       		While nPos <= nTotal .AND. Self:oFormas:Elements(nPos):cTipo == cTipo .AND. ;
       			 Self:oFormas:Elements(nPos):cTotalizador == cTotalizador .AND. ;
       			 Self:oFormas:Elements(nPos):cTipoTrans == cTipoTrans 
       			oRetorno:Add( Self:oFormas:Elements(nPos) ) 
       			nPos++
       		End
       EndIf

Return oRetorno      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณRetornarCompr บAutor  ณVendas CRM       บ Data ณ  08/01/13  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os comprovantes a serem impressos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method RetornarCompr() Class LJCCupom
Local oRetorno	:= LJCList():New()     //Retorno dos comprovantes
Local nTotCup	:= Self:oCupom:Count()  //Total de comprovantes
Local nTotFormas:= Self:oFormas:Count()   //Total de formas
Local nConta 	:= 1                  //Contador de la็o de repeti็ใo
Local nTotForma	:= 0                  //total da forma de pagamento
Local cTipo		:= ""                     //tipo do comprovante
Local cTotalizador	:= ""              //totalizador
Local cTipoTrans	:= ""             //tipo de transacao
Local cFormaPgto	:= ""             //forma de pagamento a ser impressa
Local nTransAdm		:= 0			 //total de Transacoes administrativas
Local nVlrSaque		:= 0			//Valor do saque realizado
Local nVlrVndcDesc	:= 0			//Valor da venda com desconto TEF
Local nVlrDescTEF	:= 0			//Valor do Desconto TEF	
Local lTefManu		:= SuperGetMv('MV_TEFMANU',,.F.) //Se utiliza POS no lugar do TEF quando ocorrer algum problema	
Local nTotAjuste	:= 0

//Ordena As formas de Pagamentos, para depois agrupแ-las

If nTotCup > 0 
	If nTotFormas > 0
		Self:oFormas:Sort( .T., , "{	|x,y| x:cTipo + x:cTotalizador +  x:cTipoTrans + x:cFormaPgto  < y:cTipo + y:cTotalizador + y:cTipoTrans + y:cFormaPgto  }")       
	EndIf
	
	Do While  nConta <= nTotFormas   
		cTipo := Self:oFormas:Elements(nConta):cTipo
		cTotalizador := Self:oFormas:Elements(nConta):cTotalizador
		cTipoTrans	:= Self:oFormas:Elements(nConta):cTipoTrans    
		cFormaPgto	:= Self:oFormas:Elements(nConta):cFormaPgto  
		          
		nVlrSaque := Self:oFormas:Elements(nConta):nVlrSaque
		nVlrVndcDesc := Self:oFormas:Elements(nConta):nVlrVndcDesc
		nVlrDescTEF := Self:oFormas:Elements(nConta):nVlrDescTEF          
		nTotForma := 0  
		nTransAdm := 0        
	    Do While nConta <= nTotFormas .And. ;
				 cTipo  == Self:oFormas:Elements(nConta):cTipo .AND.;
				 cTotalizador == Self:oFormas:Elements(nConta):cTotalizador .AND. ;
				 cTipoTrans == 	Self:oFormas:Elements(nConta):cTipoTrans .AND. ;
				 cFormaPgto == Self:oFormas:Elements(nConta):cFormaPgto
			 
			 //Somente adiciona se localizou um cupom fiscal
			 If Self:oCupom:Seek("cChave", cTipo + cTotalizador + cTipoTrans) > 0
			 	nTotForma := Self:oFormas:Elements(nConta):nValor
			 	If Self:oFormas:Elements(nConta):nValor == 0 .AND. Self:oFormas:Elements(nConta):cTipoTrans == "A"
			 		nTransAdm++
			 	EndIf
			 EndIf 
			 nConta++
	    EndDo 
	    
	    If lTefManu 
	    	nTotAjuste := STBAdjustingPay(nTotForma,cFormaPgto)
	    	/*Tratativa para que em casos de venda com sucesso 
		    porem o parametro ativo ้ zerado o valor e nใo imprime o CCD*/
		    If nTotAjuste > 0
		    	nTotForma := nTotAjuste
		    EndIf
	    Endif
	    	
		If nTotForma > 0 .OR. nTransAdm > 0
			oRetorno:Add( LjCFormas():New(		cTipo			,	cTotalizador	,	cFormaPgto	, nTotForma ,;
											 	NIL				,	cTipoTrans		,	Nil			, nVlrSaque ,;
											 	nVlrVndcDesc 	, nVlrDescTEF		) )
		EndIf    
	
	EndDo
EndIf

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณImprimir     บAutor  ณVendas CRM       บ Data ณ  08/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime os comprovantes a serem impressos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method Imprimir(lRelGer,lSTDSatRecovery, lPagDigPix) Class LJCCupom
	Local oComprov		:=  0	//total de Comprovantes
	Local nC			:=  1	//Contador de Comprovantes
	Local oCupons		:= NIl	//Cupons Fiscais Vinculados a Forma de Pagamento
	Local lImprimiu		:= .T.	//Retorno da fun็ใo
	Local cTexto		:= ""
	Local lPOS		  	:= STFIsPOS()	// Pos?

	Default lRelGer			:= .F.
	Default lSTDSatRecovery := .F.
	Default lPagDigPix		:= .F.
	
	If lPOS
		STFMessage("TEF", "RUN", STR0006)  //"Aguarde a impressใo do comprovante TEF...."
		STFShowMessage("TEF")
	EndIf
	
	oComprov := Self:RetornarCompr()
	
	For nC := 1 To oComprov:Count() 
	
	    oCupons  := Self:RetornarCupons(oComprov:Elements(nC):cTipo, oComprov:Elements(nC):cTotalizador, oComprov:Elements(nC):cTipoTrans)
		cTexto	 := ""

		lImprimiu := Self:ImprimirCompr( oComprov:Elements(nC), oCupons, @cTexto, @lRelGer,lSTDSatRecovery)

		If lImprimiu .AND. (oComprov:aColecao[nC]:cFormaPgto $ "PD/PX/PIX/PAGTO DIGITAL" .OR. lPagDigPix)
			Exit
		ElseIf  oCupons:Count() >0 .AND. !lImprimiu
			lImprimiu := .F.    
			Exit
		EndIf

	Next nC   
	
	If oComprov:Count() > 0
		oCupons := FreeObj(oCupons) 
	EndIf
	oComprov := FreeObj(oComprov)
	
	Self:oCupom := NIL 
	Self:oFormas := NIL
	
	Self:oCupom :=  LJCList():New()  //Objeto do Tipo Lista
	Self:oFormas :=  LJCList():New()  //Objeto do Tipo Lista

	If lPOS
		STFMessage("SITEF", "ALERT", IIF( lImprimiu,"Impressใo realizada" , STR0003) ) //"Falha na impressใo do comprovante."
		STFShowMessage("SITEF")
	EndIf
	
Return lImprimiu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimirComprบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o comprovante                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1  - Objeto do comprovante    						  บฑฑ
ฑฑบ          ณEXPO2  - Objeto de cupons do comprovante 					  บฑฑ
ฑฑบ          ณEXPC2  - Texto de reimpressใo            					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImprimirCompr(oComprov, oCupons, cTexto, lRelGer, lSTDSatRecovery) Class LJCCupom
Local lImprimiu  	:= .F.			//Impressใo do comprovante com sucesso?
Local lPOS		  	:= STFIsPOS()	// Pos?

If lPOS
	lImprimiu := Self:ImpCpvTPdv(oComprov, oCupons, cTexto, lRelGer, lSTDSatRecovery)
Else
	LjMsgRun(STR0008 + " " + STR0001,,{ || lImprimiu := Self:ImpCpvLoja(oComprov, oCupons, cTexto, lRelGer, lSTDSatRecovery) })	//"Aguarde..." "Imprimindo comprovante..."
EndIf
	 
Return lImprimiu   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerificarImpressaoบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a reimpressใo                                           บฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1  - Retorno do ECF    		               		           บฑฑ
ฑฑบ          ณEXPL2  - Reimprime comprovante 				   		           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VerificarImpressao(aRet, lReimprime ) Class LjCCupom

	Local lImprime 		:= .T.      //Impressใo com sucesso?
	Local nOpt 			:= 2        //Op็ใo selecionada pelo usuแrio
	Local lTentaTiva 	:= .T.      //controle de tentativa

	DEFAULT lReimprime := .F.    //Reimprime o cupom?
	
	If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressใo  
	
		//Erro na Impressใo - Trata a mensagem
		lImprime := .F.

		While lTentaTiva 
							
			STFMessage("TEFImprime", "YESNO", STR0004 + " " + STR0005) //"Impressora nใo responde."#"Deseja imprimir novamente?"
			nOpt := If(STFShowMessage("TEFImprime"),2,0) 
			
			//2=SIM
			If nOpt == 2
			
				Sleep(1000)
				
				aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
										"STCloseNotFiscalReceipt"													,;		// Nome do evento
										{""} )  
			
				If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressใo				
					lTentaTiva := .T.
				Else
					lTentaTiva := .F.	
					lReimprime := .F.
				EndIf
			
			Else				
				lTentaTiva := .F.					
			EndIf	
	
		EndDo
										
					
		If nOpt == 2 .OR. !Self:ReimpSenSup()  //Superior nใo digitou senha para desfazer a transacao
			lReimprime := .T. 
			STFMessage("TEF", "RUN", STR0006)  // "Aguarde a impressใo do comprovante TEF...."
			STFShowMessage("TEF")
		EndIf

	Else
		If ValType(aRet) <> "A"
			STFMessage("TEFImprime", "ALERT", STR0007) //"Problemas com a Impressora Fiscal"
			STFShowMessage("TEFImprime") 				
		EndIf
	EndIf
	
Return lImprime 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTGVerificarImpressaoบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a reimpressใo  do Relatorio gerencial                   บฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1  - Retorno do ECF    		               		           บฑฑ
ฑฑบ          ณEXPL2  - Reimprime comprovante 				   		           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TGVerificarImpressao(aRet, lReimprime, lRelGer ) Class LjCCupom

	Local lImprime 		:= .T.      //Impressใo com sucesso?
	Local nOpt 			:= 2        //Op็ใo selecionada pelo usuแrio
	Local lTentaTiva 	:= .T.      //controle de tentativa

	DEFAULT lReimprime := .F.    	//Reimprime o cupom?
	DEFAULT lRelGer	  := .F.
	
	If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressใo  
	
		//Erro na Impressใo - Trata a mensagem
		lImprime := .F.
	
		While lTentaTiva 
								
				STFMessage("TEFImprime", "YESNO", STR0004 + " " + STR0005) //"Impressora nใo responde."#"Deseja imprimir novamente?"
				nOpt := If(STFShowMessage("TEFImprime"),2,0) 
				
				//2=SIM
				If nOpt == 2
				
					Sleep(1000)
				
					//Se for Homologacao do TEF chama a rotina de fechamento do relatorio gerencial
					//Pois so para homologacao aceita essa funcionalidade 
					If SuperGetMV("MV_LJHMTEF", ,.F.)
						
						aRet := 	STFFireEvent(	ProcName(0)					,;		// Nome do processo
													"STManagReportPrint"			,;
													{"FechaRelatorioGerencial"	,;
		 											1})
		 											 
					EndIf
					
					If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressใo				
						lTentaTiva := .T.
					Else
						lTentaTiva := .F.	
						lReimprime := .F.
						lRelGer := .T.
					EndIf
				
				Else				
					lTentaTiva := .F.					
				EndIf	
		
		EndDo							
				
		If nOpt == 2 .OR. !Self:ReimpSenSup()  //Superior nใo digitou senha para desfazer a transacao
			lReimprime := .T. 
			STFMessage("TEF", "RUN", STR0006) //"Aguarde a impressใo do comprovante TEF...."
			STFShowMessage("TEF")
		EndIf	
				

		
	Else
			If ValType(aRet) <> "A"
				STFMessage("TEFImprime", "ALERT", STR0007) //"Problemas com a Impressora Fiscal"
				STFShowMessage("TEFImprime") 				
			EndIf
	EndIf
	
Return lImprime 
                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReimpSenSup บAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a autoriza็ใo do superior, se necessแrio            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ReimpSenSup() Class LjCCupom

	Local lSenhaSup := SuperGetMV("MV_LJCSETE",,.F.)			// Defise se solcita senha para nใo confirmar TEF
	Local lRet		:= .T.										// Retorno da Funcao
	Local cCaixaSup	:= Space(20)								// Caixa superior
	Local cUserIDOld:= ""                                       //Usurio antigo (restArea)
	
	If lSenhaSup
	    //TO DO: VERIFICAR COMPONENTE DE GRAVACAO DE LOG DA VENDA
		//LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "Parametro MV_LJCSETEF esta habilitado. Usuario: " + cUserName )
	
		cUserIDOld := __cUserID
	
		lRet:= FWAuthSuper(@cCaixaSup)
	
	                                                                                    
		__cUserID := cUserIDOld
		PswOrder( 1 )
		PswSeek( __cUserID )
	//Else 
		// TO DO: Grava็ใo do Log
		//LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "Parametro MV_LJCSETEF NAO esta habilitado. Usuario: " + cUserName )
	
	EndIf
	Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetornarTextoบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o texto dos cupons                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1  - Objeto de cupons do comprovante   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RetornarTexto(oCupons) Class LjCCupom
	Local cTexto := ""                //Texto de Retorno
	Local nCupons := oCupons:Count()  //total de cupons
	Local nLinhasCup := 0             //Linhas do comprovante
	Local nConta2	:= 0              //Contador do Comprovante
	Local cDelimit := CHR(10)         //Delimitador
	Local nConta := 0                 //Contador de cupons
	Local lGuil		:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
	Local nSaltoLn	:= SuperGetMV("MV_FTTEFLI",, 1)		// Linha pula entre comprovante
	
	For nConta := 1 to  nCupons
		
		//Caso Tenha mais de um cartใo realizo o corte 
		If nConta > 1 .AND. lGuil
			cTexto += TAG_GUIL_INI+TAG_GUIL_FIM
		EndIf

		nLinhasCup := 0	
							
		If  Valtype(oCupons:Elements(nConta):oViaCliente) == "O"								 
			nLinhasCup := oCupons:Elements(nConta):oViaCliente:Count()   
			If nLinhasCup > 0
				cTexto += cDelimit + cDelimit
			EndIf
			For nConta2 := 1 To nLinhasCup
				cTexto += cDelimit + oCupons:Elements(nConta):oViaCliente:Elements(nConta2)
			Next
		EndIf   
		
		/* TRATAMENTO PARA CORTE DO CUPOM */
		For nConta2 := 1 to nSaltoLn
			cTexto += CRLF
		Next

		If lGuil
			cTexto += TAG_GUIL_INI+TAG_GUIL_FIM
		EndIf 
		
		nLinhasCup := 0
		
		If  ValType(oCupons:Elements(nConta):oViaCaixa) == "O"								 
	   		nLinhasCup := oCupons:Elements(nConta):oViaCaixa:Count() 
			If nLinhasCup > 0
				cTexto += cDelimit + cDelimit 
			EndIf
	
			For nConta2 := 1 to nLinhasCup							
			    	cTexto += cDelimit + oCupons:Elements(nConta):oViaCaixa:Elements(nConta2)   								    													
			Next nConta2  

		EndIf
				    
	Next nConta

	If lGuil
		cTexto += TAG_GUIL_INI+TAG_GUIL_FIM
	EndIf 
		
Return cTexto       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimirTxtFiscบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o conprovante nใo fiscal                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1  - Objeto de cupons do comprovante   				  บฑฑ
ฑฑบ          ณEXPC2  - Texto de impressใo            					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ImprimirTxtFisc(oCupons, cTexto) Class LjCCupom
	Local aRet := {0}  //Array de Retorno
	Local cRetorno := ""  //Retorno do Texto
	Local nCupons := oCupons:Count() //total de cupons
	Local nConta := 1  //Contador
	Local nConta2 := 0 //Contador2
	Local nConta3 := 0  //Contador3
	Local nMaxLinhas := 0  //Maximo de Linhas       
	Local cDelimit := CHR(10) //Delimitador
	Local nLinhas		:= 0	//Linhas enviadas
	
	//Na homologacao do TEf usar linhas = 3
	//pois eles exigem que nao se bufferize os comandos de impressao
	//nao usar linhas = a 1 pois nao imprime corretamente as quebras de linha
	If SuperGetMV("MV_LJHMTEF", ,.F.)
		nLinhas	:= 3
	Else 
		nLinhas := _LINHAS_POR_IMPRESSAO
	EndIf
	
	If nLinhas == 0   
	
		cTexto := Self:RetornarTexto(oCupons) 
		aRet := STFFireEvent(	ProcName(0)				,;		// Nome do processo
								"STTxtNotFiscalReceipt",;
								{cTexto,;
										 1})	   
	Else
	
		cTexto := ""
	
		Do While (Len(aRet) > 0 .And. aRet[1] == 0 ) .AND. nConta <= nCupons
								
			nConta2 := 1  		
			nLinhasCup := 0
			
			If  ValType(oCupons:Elements(nConta):oViaCliente) == "O" 
				nLinhasCup := oCupons:Elements(nConta):oViaCliente:Count() 
			EndIf
			
			If nLinhasCup > 0
				cRetorno := cDelimit + cDelimit
			EndIf 
			
			While nConta2 <= nLinhasCup .AND. (Len(aRet) > 0 .And. aRet[1] == 0 ) 
			    
			    nMaxLinhas := IIF(nLinhasCup < (nConta2 + nLinhas), (nLinhasCup - nConta2)+1 ,nLinhas)
			    For nConta3 := 1 to nMaxLinhas   
			    	cRetorno += cDelimit + oCupons:Elements(nConta):oViaCliente:Elements(nConta2)   	
			    	nConta2++
			    Next nConta3
			    		    
				aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
						"STTxtNotFiscalReceipt",;
						{cRetorno,;
						 1})
			
				If Len(aRet) == 0 .OR. aRet[1] <> 0 
					cTexto := ""
					Loop
					     
				EndIf
				cTexto += cRetorno 	   
				cRetorno := ""							
			End
								
		
			nConta2 := 1  
		
			If  Valtype(oCupons:Elements(nConta):oViaCaixa) == "O" 
				nLinhasCup := oCupons:Elements(nConta):oViaCaixa:Count() 
			EndIf
			
			If nLinhasCup > 0
				cRetorno := cDelimit + cDelimit
			EndIf
			
			Do While nConta2 <= nLinhasCup .AND. (Len(aRet) > 0 .And. aRet[1] == 0 )

			    nMaxLines := IIF(nLinhasCup < (nConta2 + nLinhas), (nLinhasCup - nConta2) + 1 ,nLinhas)
			    For nConta3 := 1 to nMaxLines   
			    	cRetorno += cDelimit + oCupons:Elements(nConta):oViaCaixa:Elements(nConta2)
			    	nConta2++
			    Next
			    
			    
				aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
						"STTxtNotFiscalReceipt",;
						{cRetorno,;
						 1})
			
				If Len(aRet) == 0 .OR. aRet[1] <> 0        
					cTexto := ""
					Loop
				EndIf 	     
				cTexto += cRetorno
				cRetorno :=""							
			End
			
		   nConta++
		   
		EndDo 
	
	EndIf
	
Return aRet       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTGImprimirTxtFiscบAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o conprovante nใo fiscal                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1  - Objeto de cupons do comprovante   				  บฑฑ
ฑฑบ          ณEXPC2  - Texto de impressใo            					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TGImprimirTxtFisc(oCupons, cTexto) Class LjCCupom

	Local aRet 			:= {0}  //Array de Retorno
	Local cRetorno 		:= ""  //Retorno do Texto
	Local nCupons 		:= oCupons:Count() //total de cupons
	Local nConta 		:= 1  //Contador
	Local nConta2 		:= 0 //Contador2
	Local nConta3 		:= 0  //Contador3
	Local nMaxLinhas 	:= 0  //Maximo de Linhas       
	Local cDelimit 		:= CHR(10) //Delimitador
	Local nLinhas		:= 0	//Linhas enviadas
	
	//Na homologacao do TEf usar linhas = 3
	//pois eles exigem que nao se bufferize os comandos de impressao
	//nao usar linhas = a 1 pois nao imprime corretamente as quebras de linha
	If SuperGetMV("MV_LJHMTEF", ,.F.)
		nLinhas	:= 3
	Else 
		nLinhas := _LINHAS_POR_IMPRESSAO
	EndIf

	If nLinhas == 0 
		cTexto := Self:RetornarTexto(oCupons) 
		
		
		aRet := STFFireEvent(	ProcName(0)																	,;		// Nome do processo
			  		"STManagReportPrint",;
					{cTexto,;
					1})  
	Else
	
		If Len(aRet) == 0 .OR. aRet[1] <> 0        
			cTexto := ""
		EndIf 	 
	
		Do While (Len(aRet) > 0 .And. aRet[1] == 0 ) .AND. nConta <= nCupons
								
			nConta2 := 1  		
			nLinhasCup := 0
			
			If  ValType(oCupons:Elements(nConta):oViaCliente) == "O"
				nLinhasCup := oCupons:Elements(nConta):oViaCliente:Count() 
			EndIf
			
			If nLinhasCup > 0
				cRetorno := cDelimit + cDelimit
			EndIf 
			
			While nConta2 <= nLinhasCup .AND. (Len(aRet) > 0 .And. aRet[1] == 0 ) 
			    			    
			    nMaxLinhas := IIF(nLinhasCup < (nConta2 + nLinhas), (nLinhasCup - nConta2)+1 ,nLinhas)
			    For nConta3 := 1 to nMaxLinhas   
			    	cRetorno += cDelimit + oCupons:Elements(nConta):oViaCliente:Elements(nConta2)   	
			    	nConta2++
			    Next nConta3
			    		    
				aRet := 	STFFireEvent(	ProcName(0)	,;		// Nome do processo
						"STManagReportPrint"			,;
						{cRetorno,;
						 1})
			
				If Len(aRet) == 0 .OR. aRet[1] <> 0 

					cTexto := ""
					Return aRet
					Loop
					     
				EndIf
				cTexto += cRetorno 	   
				cRetorno := ""							
			End
								
			//Inicia segundo comprovante
			nConta2 := 1  
		
			If  Valtype(oCupons:Elements(nConta):oViaCaixa) == "O" 
				nLinhasCup := oCupons:Elements(nConta):oViaCaixa:Count()
			EndIf
			
			If nLinhasCup > 0
				cRetorno := cDelimit + cDelimit
			EndIf
			
			Do While nConta2 <= nLinhasCup .AND. (Len(aRet) > 0 .And. aRet[1] == 0 )
	
			    //nMaxLines := IIF(nLinhasCup < (nConta2 + _LINHAS_POR_IMPRESSAO), (nLinhasCup - nConta2) + 1 ,_LINHAS_POR_IMPRESSAO)
			    nMaxLines := IIF(nLinhasCup < (nConta2 + nLinhas), (nLinhasCup - nConta2) + 1 ,nLinhas)
			    For nConta3 := 1 to nMaxLines   
			    	cRetorno += cDelimit + oCupons:Elements(nConta):oViaCaixa:Elements(nConta2)
			    	nConta2++
			    Next
			    
			    
				aRet := 	STFFireEvent(	ProcName(0)		,;		// Nome do processo
					   						"STManagReportPrint",;
					   						{cRetorno,;
						 					1})
			
				If Len(aRet) == 0 .OR. aRet[1] <> 0        
					cTexto := ""
					Return aRet
					Loop
				EndIf 	   
				  
				cTexto += cRetorno
				cRetorno :=""							
			End
			
		   nConta++
		   
		EndDo 
	
	EndIf
	
Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpCpvTPdv
Impressใo do comprovante para Totvs PDV

@type       Method
@author     Alberto Deviciente
@since      29/10/2020
@version    12.1.27

@param oComprov, Objeto, Objeto do comprovante 
@param oCupons, Objeto, Objeto de cupons do comprovante
@param cTexto, Caractere, Texto de impressใo
@param lRelGer, L๓gico, Indica se ้ impressใo de relat๓rio gerencial
@param lSTDSatRecovery, L๓gico, Indica se ้ recupera็ใo de venda SAT

@return lImprimiu, L๓gico, Indica se imprimiu com sucesso.
/*/
//-------------------------------------------------------------------------------------
Method ImpCpvTPdv(oComprov, oCupons, cTexto, lRelGer, lSTDSatRecovery) Class LJCCupom
	Local lContinua  	:= .F.	//Laco de continuidade do processo
	Local lReimprime 	:= .F.	//Indica็ใo de reimpressใo do comprovante 
	Local lImprimiu  	:= .F.	//Impressใo do comprovante com sucesso?
	Local aRet	     	:= {}	//Retorno do ECF
	Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
	Local nValorTotal	:= 0	//Total da venda
	Local oTotal		:= NIL
	Local oNewModel		:= NIL
	Local cFormaPagto	:= ""	//Forma de pagamento
	Local lIsReceipTit	:= .F. 	//ษ recebimento de titulos?
	Local lIsNotFiscal	:= .F.	//Possui item nao fiscal
	Local lMobile 		:= STFGetCfg("lMobile", .F.)	//Smart Client Mobile	
	Local lLJ7101		:= ExistBlock("LJ7101")
	Local aRetPE		:= {}							// retorno PE
	Local lCancel		:= .F.

	Default cTexto			:= ""
	Default lRelGer			:= .F.
	Default lSTDSatRecovery	:= .F.

	If !lSTDSatRecovery
		oTotal := STFGetTot()	// Totalizador
	Else
		oNewModel	:= STFEstrTot() 
		oTotal		:= oNewModel:GetModel("MasterStr")
	EndIf

	lMobile := ( ValType(lMobile) == "L" .AND. lMobile )

	If oComprov <> Nil .AND.  oCupons <> nil

		lIsReceipTit := STIGetRecTit()

	    lContinua := .T.
	    Do While lContinua  
	    	oComprov:nVezes := oComprov:nVezes + 1
			Do Case

				Case !STFGetCfg("lUseECF")

					If Empty(cTexto)
						cTexto := Self:RetornarTexto(oCupons) //Linha inicial do comprovante
					EndIf

					If !Empty(cTexto)

						If "CANCELAMENTO" $ cTexto
							lCancel := .T.
						EndIf

						If !lMobile

							lImprimiu := (STWPrintTextNotFiscal(cTexto) == 0)

							If lImprimiu .AND. lGuil .AND. !(oComprov:cFormaPgto $ "PD/PX/PIX/PAGTO DIGITAL") // Pagamento Digital e PIX jแ imprime as duas vias de uma vez
								cTexto := Replic(CHR(10)+CHR(13),6)
								cTexto += TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel								
								STWPrintTextNotFiscal(cTexto)
							EndIf	
							
							lContinua := .F. 	
						Else
							//bufferizar as linhas do comprovante e enviar conforme contador					
							aRet := Self:TGImprimirTxtFisc(oCupons, @cTexto, lMobile)	
							
							If !Self:TGVerificarImpressao(aRet, @lReimprime, @lRelGer, lMobile )  
								//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
								lContinua := .F.
				         	Else
				            	lImprimiu := .T.
								lContinua := .F.
							EndIf
						EndIf
					EndIf

				Case oComprov:cTipo == "V" .AND. oComprov:nVezes == 1
					//Abre cupom fiscal nใo vinculado

					/* Ajusta VALOR TOTAL e FORMA DE PAGAMENTO caso tenha algum produto nใo fiscal na venda */
					If (lIsNotFiscal := STBExistNItemFiscal()) .And. !lIsReceipTit .AND. oComprov:cTipoTrans <> "RNF" .AND. oComprov:cTipoTrans <> "B" 
						If oComprov:nValor <> oTotal:GetValue("L1_VLRLIQ") 
							nValorTotal := oTotal:GetValue("L1_VLRLIQ")
							cFormaPagto := STWFindTot()  
						Else
							nValorTotal := oComprov:nValor	
							cFormaPagto := oComprov:cFormaPgto
						EndIf
						oComprov:cTotalizador := GetPvProfString("Microsiga", "Pedido" , "01", GetClientDir()+"SIGALOJA.INI")
					Else
					 	//Recebimento de titulos
						If lIsReceipTit
							oReceiptTitle := STIRetObjTit()
							nValorTotal	:= oReceiptTitle:GetTotal() //Valor total dos recebimentos selecionados
							cFormaPagto	:= Iif(FindFunction("STWReceTotalizer"),STWReceTotalizer("FORMA"),"")  //forma de pagamento
							oComprov:cTotalizador := Iif(FindFunction("STWReceTotalizer"), STWReceTotalizer("Totalizadores"),"") //totalizador do recebimento					
						Else
							nValorTotal := oComprov:nValor	
							cFormaPagto := oComprov:cFormaPgto
						EndIf
					EndIf						

					If lIsReceipTit .Or. lIsNotFiscal .AND. oComprov:cTipoTrans <> "RNF" .AND. oComprov:cTipoTrans <> "B" 
						aRet := STFFireEvent(	ProcName(0)				,;
												"STReceiveNotFiscal"	,;
												{oComprov:cTotalizador	,;
												(nValorTotal + (oComprov:nVlrSaque - oComprov:nVlrDescTEF)) * IIF(STBFactor()[2] > 0, STBFactor()[2], 1),;
												cFormaPagto})
												
						If !Self:VerificarImpressao(aRet, @lReimprime ) 
							//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
							If lReimprime
			                    Loop
							Else
								lContinua := .F.
							EndIf
						EndIf 
					
					EndIf

					aRet := STFFireEvent(	ProcName(0)		,;
											"STOpenNotFiscalReceipt",;
											{cFormaPagto			,;
											Str( (nValorTotal + (oComprov:nVlrSaque - oComprov:nVlrDescTEF)) * IIF(STBFactor()[2] > 0, STBFactor()[2], 1),14,2),;  //totalizar nformas de pagamento
										 	oComprov:cTotalizador	,;
											cTexto					,;
											NIL})	

					If !Self:VerificarImpressao(aRet, @lReimprime ) 
						
						//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR						
						If lReimprime
		                    Loop
						Else
							lContinua := .F.
						EndIf
		                
					EndIf 
					
					If !lContinua
						Loop
					Endif
					
					//bufferizar as linhas do comprovante e enviar conforme contador   
					
					If "CANCELAMENTO" $ oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO[Len(oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO) ]
						lCancel := .T.
					EndIf					
					
					If lLJ7101 .And. !lCancel 
						aRetPE := ExecBlock( "LJ7101", .F., .F. )
						If Len(aRetPE) > 0 .And. ValType(aRetPE[1]) == "C"
							oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO[Len(oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO) ] += aRetPE[1]
						EndIf		
						If Len(aRetPE) > 1 .And. ValType(aRetPE[2]) == "C"
							oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO[Len(oCupons:ACOLECAO[1]:OVIACAIXA:ACOLECAO) ] += aRetPE[2]
						EndIf														
					EndIf						
					
					aRet := Self:ImprimirTxtFisc(oCupons, @cTexto)
					
					If !Self:VerificarImpressao(aRet, @lReimprime ) 
						
						//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR						
						If lReimprime
							Loop
		
						Else
							lContinua := .F. 
						EndIf						
		                
					EndIf 
					
					If !lContinua
						Loop
					Endif
					InKey(2)
			
					aRet := 	STFFireEvent(	ProcName(0)			,;		// Nome do processo
								  		"STCloseNotFiscalReceipt"	,;
										{})
										
					If !Self:VerificarImpressao(aRet, @lReimprime ) 
						//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
						
						If lReimprime
		                    Loop
						Else
							lContinua := .F. 
						EndIf
						
    			    Else 
			         	lImprimiu := .T.
						lContinua := .F. 
     				EndIf 
					
					If !lContinua
						Loop
					Endif
		
				Case oComprov:cTipo == "G" .OR. oComprov:nVezes > 1
		
					If Empty(cTexto)
						cTexto := Self:RetornarTexto(oCupons) //Linha inicial do comprovante
					EndIf
										
					If !Empty(cTexto) 
					
						//bufferizar as linhas do comprovante e enviar conforme contador					
						aRet := Self:TGImprimirTxtFisc(oCupons, @cTexto)	
						
						//Se for Homologacao do TEF chama a rotina de fechamento do relatorio gerencial
						//Pois so para homologacao aceita essa funcionalidade 
						If SuperGetMV("MV_LJHMTEF", ,.F.)	
							If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] == 0      
								aRet := 	STFFireEvent(	ProcName(0)					,;		// Nome do processo
															"STManagReportPrint"		,;
															{"FechaRelatorioGerencial"	,;
							 								1})						 	
							EndIf 	
						EndIf	 
						
						If !Self:TGVerificarImpressao(aRet, @lReimprime, @lRelGer )  
							//Erro de Impressao e pode reimprimir OU USUมRIO NรO TEM PERMISSรO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
							
							If lReimprime
								Loop
			
							Else
								lContinua := .F. 
							EndIf
							
			         	Else 
			            	lImprimiu := .T.
							lContinua := .F. 	
							lRelGer   := .T.						
						EndIf 
					
					Else
						//Protecao para evitar execucao do laco de forma infinita, quando forma 
						//de pagamento for CHEQUE e nao existir comprovante a ser impresso.
						If oComprov:cFormaPgto == "CHEQUE" .And. oComprov:nVezes > 10 //Tenta ate 10 vezes
							lImprimiu := .T.
							lContinua := .F. 	
							lRelGer   := .T.	
						EndIf
						
					EndIf
						
			EndCase

		End
	
	EndIf
	 
Return lImprimiu

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpCpvLoja
Impressใo do comprovante para o SIGALOJA.

@type       Method
@author     Alberto Deviciente
@since      29/10/2020
@version    12.1.27

@param oComprov, Objeto, Objeto do comprovante 
@param oCupons, Objeto, Objeto de cupons do comprovante
@param cTexto, Caractere, Texto de impressใo
@param lRelGer, L๓gico, Indica se ้ impressใo de relat๓rio gerencial
@param lSTDSatRecovery, L๓gico, Indica se ้ recupera็ใo de venda SAT

@return lImprimiu, L๓gico, Indica se imprimiu o comprovante com sucesso.
/*/
//-------------------------------------------------------------------------------------
Method ImpCpvLoja(oComprov, oCupons, cTexto, lRelGer, lSTDSatRecovery) Class LJCCupom
	Local lImprimiu  	:= .F.	//Imprimiu o comprovante com sucesso?
	Local lImpFiscal	:= IIF(ISBLIND(),.F.,Lj121IsFisc(LjGetStation("LG_IMPFISC"))) //Verifica se ้ impressora fiscal
	
	Default cTexto			:= ""
	Default lRelGer			:= .F.
	Default lSTDSatRecovery	:= .F.

	If oComprov <> Nil .AND. oCupons <> nil

		If Empty(cTexto)
			cTexto := Self:RetornarTexto(oCupons)
		EndIf
		
		If !Empty(cTexto)
			
			If lImpFiscal
				//-----------------------
				//Impressora Fiscal (ECF)
				//-----------------------
				lImprimiu := LjImpPDFis(cTexto, oComprov:nValor, oComprov:cFormaPgto, oComprov:cTotalizador, lRelGer )
			Else
				//-----------------------
				//Impressora Nao Fiscal
				//-----------------------
				lImprimiu := LjImpPDNFis(cTexto)
			EndIf

		EndIf

	EndIf
	 
Return lImprimiu