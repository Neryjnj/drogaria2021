#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1031 ; Return  // "dummy" function - Internal Use

/*
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoXTelaComplementar�Autor  �Vendas Clientes     � Data �  04/09/07   ���
������������������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servicoX tela            ���
���			 �complementar.	 															   ���
������������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		           ���
������������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
*/
Class LJCServicoXTelaComplementar From LJAAbstrataServico

	Data oTelasComp									//Objeto que ira armazenar os dados das telas complementares
	
	Method XTelaCompl(cTipo)                   		//Metodo construtor
	Method TratarServ(cDados)                     	//Metodo que ira tratar os dados do servico
	Method BusTelComp()                          	//Metodo que ira retornar os dados das telas complementares

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �XTelaCompl�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoXTelaComplementar.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method XTelaCompl(cTipo) Class LJCServicoXTelaComplementar

	::cTpServ 		:= cTipo
	::oTelasComp 	:= Nil    

Return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratarServ�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira tratar os dados retornados no servico.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)   - String com os dados do servico.	  ���
���			 �ExpN1 (2 - nPosicao) - Posicao da string dos dados.		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarServ(cDados, nPosicao) Class LJCServicoXTelaComplementar

	Local oTelaCompl		:= Nil					//Objeto que ira armazenar cada tela complementar
	Local nPos	 			:= 1					//Posicao inicial da string cDados
	Local nQtdeCampo 		:= 0					//Quantidade de telas retornadas
	Local nCount 			:= 0					//Variavel de controle contador	
	
	::oTelasComp := LJCTelasComplementares():TelasCompl()
		
	::cTpDados := SubStr(cDados, nPos, 1)
	nPos ++

	nQtdeCampo := Val(SubStr(cDados, nPos, 2))
	nPos += 2
	
	For nCount := 1 To nQtdeCampo
	
		oTelaCompl := LJCTelaComplementar():TelaCompl()
		
		oTelaCompl:cTipoCampo := SubStr(cDados, nPos, 1)
		nPos += 1		
		
		oTelaCompl:nMinimo := Val(SubStr(cDados, nPos, 2))
		nPos += 2

		oTelaCompl:nMaximo := Val(SubStr(cDados, nPos, 2))
		nPos += 2

		oTelaCompl:cCampo := AllTrim(SubStr(cDados, nPos, 20))
		nPos += 20		

		::oTelasComp:Add("T" + AllTrim(Str(nCount)), oTelaCompl)
						
	Next
	
	::oTelasComp:cCapProdut := AllTrim(SubStr(cDados, nPos, 25))
	nPos += 25
				
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BusTelComp�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira retornar as telas complementares.	          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BusTelComp() Class LJCServicoXTelaComplementar
Return ::oTelasComp