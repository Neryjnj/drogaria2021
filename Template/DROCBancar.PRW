#INCLUDE "PROTHEUS.CH"
#INCLUDE "DrocBancar.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DroCBancar³ Autor ³ Geronimo B. Alves                     ³ Data ³29/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Invoca o Correspondente Bancario                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Venda assistida e Front Loja com Template Drogarias                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Template Function DroCBancar()
Local lRet := .T.

If !lCXAberto
	If lUsaDisplay
		MsgStop("O Caixa não está aberto. Não será possível alterar o cliente","Atenção")
	EndIf

	lRet := .F.
EndIf

If lRet .And. !lOcioso
	If lUsaDisplay
		MsgStop("Para carregar um correspondente bancario , é necessário Fechar a Venda ou Cancelar este Cupom Fiscal.", "Atenção")
	Endif
	
	lRet := .F.
EndIf

If lRet
	oTEF:Operacoes( "CB" , {} )
EndIf

Return NIL