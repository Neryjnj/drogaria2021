#INCLUDE "PROTHEUS.CH"
#INCLUDE "DrocBancar.CH"
 
/*�������������������������������������������������������������������������������������������
���Fun��o	 �DroCBancar� Autor � Geronimo B. Alves                     � Data �29/04/2005���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Invoca o Correspondente Bancario                                           ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Venda assistida e Front Loja com Template Drogarias                        ���
�������������������������������������������������������������������������������������������*/

Template Function DroCBancar()
Local lRet := .T.

If !lCXAberto
	If lUsaDisplay
		MsgStop("O Caixa n�o est� aberto. N�o ser� poss�vel alterar o cliente","Aten��o")
	EndIf

	lRet := .F.
EndIf

If lRet .And. !lOcioso
	If lUsaDisplay
		MsgStop("Para carregar um correspondente bancario , � necess�rio Fechar a Venda ou Cancelar este Cupom Fiscal.", "Aten��o")
	Endif
	
	lRet := .F.
EndIf

If lRet
	oTEF:Operacoes( "CB" , {} )
EndIf

Return NIL