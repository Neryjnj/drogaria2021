#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1925.CH"

Function LOJA1925 ; Return                     

/*---------------------------------------------------------------------------
ฑฑบPrograma  ณLJCClisitefPbm บAutor  ณVENDAS CRM     บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para transacao com Pbm							  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Class LJCClisitefPbm From LJAPbm

	Data oTransSitef							//Objeto do tipo LJCTransClisitef
	Data oPbm									//Objeto do tipo LJCPbm
	Data oConfPbms								//Objeto do tipo LJCList com as configuracoes da PBM
	Data oDadosTran								//Objeto com os dados da transacao
	
	Method New()

	//Metodos da interface
	Method IniciaVend()
	Method VendProd()
	Method CancProd()
	Method FinalVend()
	Method BuscaSubs()
	Method ConfProd()
	Method ConfVend()
	Method CancPbm()
	Method BuscaRel()
	Method SelecPbm(cNomePBM)
	Method Confirmar()
	Method Desfazer()
 	Method IniciouVen()
	Method VDLinkCons(oDadosTran)
	Method VDLinkProd(oDadosTran)
	Method VDLinkVenda(oDadosTran)
	Method PharmSCons(oDadosTran)
	Method FuncCrCons(oDadosTran)
      
EndClass       

/*---------------------------------------------------------------------------
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method New(oCliSitef, oPbms) Class LJCClisitefPbm 

   	_Super:New()
   	
   	::oConfPbms := oPbms
   	
   	::oPbm := LJCPbm():Pbm()
   	
   	::oTransSitef := LJCTransClisitef():New(oCliSitef)  

Return Self      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณIniciaVend   บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVenda com cartใo de credito a vista.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method IniciaVend(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.						//Retorno do metodo

lRetorno := ::oPbm:IniciaVend(CVALTOCHAR(oDadosTran:nCupom), oDadosTran:cOperador, oDadosTran:cTpDoc)

If lRetorno
	//Os dados da transacao tem que ser armazenado no atributo oDadosTrans da classe e
	//os atributos dData e cHora precisam ser alterados com os dados gerados pela PBM
	::oDadosTran := oDadosTran
	::oDadosTran:dData := CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
	::oDadosTran:cHora := Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
Else
	::oPbm:oPbm := Nil
EndIf	

Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  ณVendProd     บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVenda no produto na PBM			                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1.ExpC1 - Codigo de barras do produto                      บฑฑ
ฑฑบ          ณ 2.ExpN1 - Quantidade do produto                            บฑฑ
ฑฑบ          ณ 3.ExpN2 - Preco do produto                                 บฑฑ
ฑฑบ          ณ 4.ExpN3 - Percentual de desconto do produto                บฑฑ
ฑฑบ          ณ 5.ExpL1 - Se o item foi enviado para pbm                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, lItemPbm, lPrioPBM) Class LJCClisitefPbm
Local lRetorno := .F.						//Retorno do metodo

lRetorno := ::oPbm:VendProd(cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm, lPrioPBM)
	
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  |CancProd     บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela o produto na PBM			                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1.ExpC1 - Codigo de barras do produto                      บฑฑ
ฑฑบ          ณ 2.ExpN1 - Quantidade do produto                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method CancProd(cCodBarra, nQtde) Class LJCClisitefPbm  
	
	Local lRetorno := .F.						//Retorno do metodo
	
	lRetorno := ::oPbm:CancProd(cCodBarra, nQtde)
	
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  |FinalVend    บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFinaliza venda PBM				                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method FinalVend() Class LJCClisitefPbm  
	
	Local lRetorno := .F.						//Verifica se a transacao foi finalizada
	Local oDadosTran := Nil						//Retorno do metodo
	
	lRetorno := ::oPbm:FinalVend()

Return oDadosTran

/*---------------------------------------------------------------------------
ฑฑบPrograma  |BuscaSubs    บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca o valor do subsidio				                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method BuscaSubs() Class LJCClisitefPbm  

	Local nRetorno := .F.						//Retorno do metodo
		
	nRetorno := ::oPbm:BuscaSubs()

Return ::oPbm:BuscaSubs()
   
/*---------------------------------------------------------------------------
ฑฑบPrograma  |ConfProd     บAutor  ณVendas CRM       บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirma o produto vendido no ECF                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1.ExpC1 - Codigo de barras do produto                      บฑฑ
ฑฑบ          ณ 2.ExpN1 - Quantidade do produto                            บฑฑ
ฑฑบ          ณ 3.ExpL1 - Se o produto foi vendido ou nao.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method ConfProd(cCodBarra, nQtde, lOK) Class LJCClisitefPbm
Local lRetorno := .F.						//Retorno do metodo
	
lRetorno := ::oPbm:ConfProd(cCodBarra, nQtde, lOK)

Return lRetorno

/*/{Protheus.doc} ConfVend
	Confirma Venda PBM?
	@type  Metodo
	@author Julio.Nery
	@since 16/04/2021
	@version 12
	@param lConfirma, l๓gico, confirma a venda PBM ?
	@return return, return_type, return_description
/*/
Method ConfVend(lConfirma) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPBM:ConfVend(lConfirma)
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  |CancPbm      บAutor  ณVendas CRM       บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o cancelamento da PBM		                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method CancPbm(oDadosTran) Class LJCClisitefPbm 

	Local lRetorno := .F.						//Verifica se a transacao foi cancelada
	Local oDadosTran := Nil						//Retorno do metodo
	
	lRetorno := ::oPbm:CancPbm()
	
	If lRetorno
		//Os dados da transacao tem que ser armazenado no atributo oDadosTrans da classe e
		//os atributos dData,cHora e nCupom precisam ser alterados com os dados gerados pela PBM
		
		::oDadosTran := oDadosTran
		::oDadosTran:dData 	:= CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
		::oDadosTran:cHora 	:= Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
		::oDadosTran:nCupom := Val(::oPbm:oPbm:cNumCupom)	
	EndIf	
		
Return oDadosTran

/*/{Protheus.doc} BuscaRel
	Relatorio de impressใo da PBM
	@type  Metodo
	@author Julio.Nery
	@since 16/04/2021
	@version 12
	@param nenhum
	@return lRetorno, string, execu็ใo com sucesso ?
/*/
Method BuscaRel() Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPBM:BuscaRel()
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  |SelecPbm     บAutor  ณVendas CRM       บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona a PBM					                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method SelecPbm(cNomePBM) Class LJCClisitefPbm 
	
	Local lRetorno 	:= .F.			//Retorno do metodo
	Local oTelaPBM	:= Nil			//Tela da PBM

	Default cNomePBM:= ""
	
	If ::oConfPbms:Count() > 0 

		oTelaPBM := LJCTelaSelecao():TelaSelec(::oConfPbms:ToArray(), STR0001, STR0002)//"PBM";"Selecione a PBM"
		
		oTelaPBM:Show()
	
		If !oTelaPBM:lCancelado

			cNomePBM := oTelaPBM:cRetSelect
			
			Do Case
				Case oTelaPBM:cRetSelect == _EPHARMA
                	::oPbm:oPbm := LJCEpharma():EPharma(::oTransSitef:oClisitef)
                	
				Case oTelaPBM:cRetSelect == _TRNCENTRE
					::oPbm:oPbm := LJCTrnCentre():TrnCentre(::oTransSitef:oClisitef)

				Case oTelaPBM:cRetSelect == _VIDALINK
					::oPbm:oPbm := LJCVDLINK():PVidaLink(::oTransSitef:oClisitef)
				
				Case oTelaPBM:cRetSelect == _PHARMASYS
					::oPbm:oPbm := LJCPharmSys():PharmaSystem(::oTransSitef:oClisitef)

				Case oTelaPBM:cRetSelect == _FUNCCARD
					::oPbm:oPbm := LJCFunCard():FuncCard(::oTransSitef:oClisitef)
			EndCase
			
			lRetorno := (::oPbm:oPbm <> Nil)

		EndIf
			
	EndIf
	
Return lRetorno

/*---------------------------------------------------------------------------
ฑฑบPrograma  |Confirmar    บAutor  ณVendas CRM       บ Data ณ  01/04/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirmar a operacao de PBM.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method Confirmar() Class LJCClisitefPbm 
	
	//Confirma a transacao
   	::oTransSitef:Confirmar(::oTrans)     

	//Inicializa a colecao de transacoes
	::InicTrans()
    
	::oPbm:oPbm := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |Desfazer     บAutor  ณVendas CRM       บ Data ณ  01/04/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDesfaz a operacao de PBM.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Desfazer() Class LJCClisitefPbm 

	//Desfaz a transacao
   	::oTransSitef:Desfazer(::oTrans)     
   	
	//Inicializa a colecao de transacoes
	::InicTrans()
	
	::oPbm:oPbm := Nil
   	
Return Nil

/*---------------------------------------------------------------------------
ฑฑบPrograma  |IniciouVen   บAutor  ณVendas CRM       บ Data ณ  06/04/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se a venda PBM foi inicializada                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method IniciouVen() Class LJCClisitefPbm
Local lIniciou := ::oPbm:oPbm <> Nil
Return lIniciou

/*/{Protheus.doc} VDLinkCons
	Executa consulta do Vida Link
	@type  Metodo
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCons(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPbm:VDLinkCons(oDadosTran:cCodAut,oDadosTran:cCodProd,oDadosTran:nCupom,oDadosTran:dData,;
							oDadosTran:cHora,oDadosTran:cOperador,oDadosTran:aVDLink)

If lRetorno
	//Os dados da transacao tem que ser armazenado no atributo oDadosTrans da classe e
	//os atributos dData e cHora precisam ser alterados com os dados gerados pela PBM
	::oDadosTran := oDadosTran
	::oDadosTran:dData := CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
	::oDadosTran:cHora := Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
Else
	::oPbm:oPbm := Nil
EndIf	

Return Nil

/*/{Protheus.doc} VDLinkProd
	Executa consulta do produto VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkProd(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPbm:VDLinkProd(oDadosTran:aVDLink)

If lRetorno
	::oDadosTran := oDadosTran
Else
	::oPbm:oPbm := Nil
EndIf

Return Nil

/*/{Protheus.doc} VDLinkVenda
	Executa venda do produto VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkVenda(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPbm:VDLinkVenda(oDadosTran:cCodAut,oDadosTran:nCupom,oDadosTran:dData,;
							oDadosTran:cHora,oDadosTran:cOperador,oDadosTran:aVDLink)

If lRetorno
	::oDadosTran := oDadosTran
	::oDadosTran:dData := CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
	::oDadosTran:cHora := Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
Else
	::oPbm:oPbm := Nil
EndIf	

Return Nil

/*/{Protheus.doc} PharmSCons
	Executa consulta do PharmSystem
	@type  Metodo
	@author Julio.Nery
	@since 26/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method PharmSCons(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPbm:PharmSCons(oDadosTran:nFuncSitef, oDadosTran:nValor, oDadosTran:cCupomFisc, oDadosTran:cDataFisc,;
							  oDadosTran:cHorario, oDadosTran:cOperador, oDadosTran:cRestri,oDadosTran:aVDLink)

If lRetorno
	::oDadosTran := oDadosTran
Else
	::oPbm:oPbm := Nil
EndIf

Return Nil

/*/{Protheus.doc} FuncCrCons
	Executa consulta do Funcional Card
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method FuncCrCons(oDadosTran) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPbm:FuncCrCons(oDadosTran:nFuncSitef, oDadosTran:nValor, oDadosTran:cCupomFisc, oDadosTran:cDataFisc,;
							  oDadosTran:cHorario, oDadosTran:cOperador, oDadosTran:cRestri,oDadosTran:aVDLink)

If lRetorno
	::oDadosTran := oDadosTran
Else
	::oPbm:oPbm := Nil
EndIf

Return NIL