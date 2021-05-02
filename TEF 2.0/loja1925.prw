#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1925.CH"

Function LOJA1925 ; Return                     

/*---------------------------------------------------------------------------
���Programa  �LJCClisitefPbm �Autor  �VENDAS CRM     � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao com Pbm							  ��� 
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
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
	Method FinalVend(cDoc, cSerie, cKeyDoc)
	Method BuscaSubs()
	Method ConfProd()
	Method ConfVend()
	Method CancPbm()
	Method BuscaRel()
	Method SelecPbm(cNomePBM,lCancela)
	Method Confirmar()
	Method Desfazer()
 	Method IniciouVen()
	Method VDLinkCons(oDadosTran)
	Method VDLinkProd(oDadosTran)
	Method VDLinkVenda(oDadosTran)
	Method VDLinkCanc(oDadosTran)
	Method PharmSCons(oDadosTran)
	Method FuncCrCons(oDadosTran)
      
EndClass       

/*---------------------------------------------------------------------------
���Programa  �New          �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method New(oCliSitef, oPbms) Class LJCClisitefPbm 

   	_Super:New()
   	
   	::oConfPbms := oPbms
   	
   	::oPbm := LJCPbm():Pbm()
   	
   	::oTransSitef := LJCTransClisitef():New(oCliSitef)  

Return Self      

/*---------------------------------------------------------------------------
���Programa  �IniciaVend   �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda com cart�o de credito a vista.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
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
���Programa  �VendProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda no produto na PBM			                          ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
���          � 3.ExpN2 - Preco do produto                                 ���
���          � 4.ExpN3 - Percentual de desconto do produto                ���
���          � 5.ExpL1 - Se o item foi enviado para pbm                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, lItemPbm, lPrioPBM) Class LJCClisitefPbm
Local lRetorno := .F.						//Retorno do metodo

lRetorno := ::oPbm:VendProd(cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm, lPrioPBM)
	
Return lRetorno

/*---------------------------------------------------------------------------
���Programa  |CancProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cancela o produto na PBM			                          ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method CancProd(cCodBarra, nQtde) Class LJCClisitefPbm  
	
	Local lRetorno := .F.						//Retorno do metodo
	
	lRetorno := ::oPbm:CancProd(cCodBarra, nQtde)
	
Return lRetorno

/*---------------------------------------------------------------------------
���Programa  |FinalVend    �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Finaliza venda PBM				                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method FinalVend(cDoc, cSerie, cKeyDoc) Class LJCClisitefPbm
Local lRetorno := .F.		//Verifica se a transacao foi finalizada

lRetorno := ::oPbm:FinalVend(cDoc, cSerie, cKeyDoc)

Return lRetorno

/*---------------------------------------------------------------------------
���Programa  |BuscaSubs    �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca o valor do subsidio				                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method BuscaSubs() Class LJCClisitefPbm  
Local nRetorno := 0						//Retorno do metodo
nRetorno := ::oPbm:BuscaSubs()
Return nRetorno
   
/*---------------------------------------------------------------------------
���Programa  |ConfProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirma o produto vendido no ECF                           ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
���          � 3.ExpL1 - Se o produto foi vendido ou nao.                 ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
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
	@param lConfirma, l�gico, confirma a venda PBM ?
	@return lRetorno, l�gico, retorno 
/*/
Method ConfVend(lConfirma) Class LJCClisitefPbm
Local lRetorno := .F.

lRetorno := ::oPBM:ConfVend(lConfirma)
Return lRetorno

/*---------------------------------------------------------------------------
���Programa  |CancPbm      �Autor  �Vendas CRM       � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua o cancelamento da PBM		                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method CancPbm(oDadosTran) Class LJCClisitefPbm 
Local lRetorno := .F.						//Verifica se a transacao foi cancelada

lRetorno := ::oPbm:CancPbm()
		
Return lRetorno

/*/{Protheus.doc} BuscaRel
	Relatorio de impress�o da PBM
	@type  Metodo
	@author Julio.Nery
	@since 16/04/2021
	@version 12
	@param nenhum
	@return lRetorno, string, execu��o com sucesso ?
/*/
Method BuscaRel() Class LJCClisitefPbm
Local aComprov := {}

aComprov := ::oPBM:BuscaRel()

Return aComprov

/*---------------------------------------------------------------------------
���Programa  |SelecPbm     �Autor  �Vendas CRM       � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Seleciona a PBM					                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method SelecPbm(cNomePBM,lCancela) Class LJCClisitefPbm 
	
	Local lRetorno 	:= .F.			//Retorno do metodo
	Local oTelaPBM	:= Nil			//Tela da PBM
	Local aComboPbm	:= {}
	Local aAux		:= {}
	Local nX		:= 0

	Default cNomePBM:= ""
	Default lCancela:= NIL

	If ::oConfPbms:Count() > 0
		aComboPbm := ::oConfPbms:ToArray()
		//Para o Cancelamento somente Epharma e TRNCentre, devido a arquitetura das PBM's (legado)
		If ValType(lCancela) == "L" .And. lCancela
			For nX := 1 to Len(aComboPbm)
				If aComboPbm[nX] $ (_EPHARMA + "|" + _TRNCENTRE)
					Aadd(aAux,aComboPbm[nX])
				EndIf
			Next nX
			aComboPbm := IIf(Len(aAux)>0, aAux, ::oConfPbms:ToArray())
		Else
			//Conforme pr�-requisito de desenvolvimento: Nessa etapa do 
			//Projeto para o TotvsPDV n�o ser� utilizado o PharmaSystem
			//pois o cliente n�o utiliza. Para funcionamento remover e verificar outros 
			//pontos que possivelmente n�o foram desenvolvidas para essa PBM
			For nX := 1 to Len(aComboPbm)
				If !(aComboPbm[nX] == _PHARMASYS)
					Aadd(aAux,aComboPbm[nX])
				EndIf
			Next nX
			aComboPbm := aAux
		EndIf
		
		oTelaPBM := LJCTelaSelecao():TelaSelec(aComboPbm, STR0001, STR0002)//"PBM";"Selecione a PBM"
		
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
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  01/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar a operacao de PBM.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method Confirmar() Class LJCClisitefPbm 
	
	//Confirma a transacao
   	::oTransSitef:Confirmar(::oTrans)     

	//Inicializa a colecao de transacoes
	::InicTrans()
    
	::oPbm:oPbm := Nil

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  01/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz a operacao de PBM.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer() Class LJCClisitefPbm 

	//Desfaz a transacao
   	::oTransSitef:Desfazer(::oTrans)     
   	
	//Inicializa a colecao de transacoes
	::InicTrans()
	
	::oPbm:oPbm := Nil
   	
Return Nil

/*---------------------------------------------------------------------------
���Programa  |IniciouVen   �Autor  �Vendas CRM       � Data �  06/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna se a venda PBM foi inicializada                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
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

/*/{Protheus.doc} VDLinkCanc
	Cancelamento da venda VidaLink
	@type  Metodo
	@author Julio.Nery
	@since 29/04/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCanc(oDadosTran) Class LJCClisitefPbm

lRetorno := ::oPbm:VDLinkCanc(oDadosTran:lCancTotal,oDadosTran:nCupom,oDadosTran:dData,;
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