#INCLUDE "MSOBJECT.CH"
  
//��������������������������������������������Ŀ
//�Constantes referente aos servicos utilizados�
//����������������������������������������������
#DEFINE _SERVICOH "H"
#DEFINE _SERVICOI "I"
#DEFINE _SERVICOD "D"
#DEFINE _SERVICON "N"
#DEFINE _SERVICOZ "Z"
#DEFINE _SERVICOA "A"
#DEFINE _SERVICOX "X"
#DEFINE _SERVICO_BAR "/"

User Function LOJA1026 ; Return  			// "dummy" function - Internal Use

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Classe    �LJCServico   �Autor  �Vendas Clientes     � Data �  04/09/07   ���
����������������������������������������������������������������������������͹��
���Desc.     �Responsavel por armazenar todos os servicos retornados do      ���
���          �sitef.													     ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Class LJCServico
    
	Data oServicos													//Objeto do tipo LJCServicos
	
	Method Servico()												//Metodo construtor
	Method ProcServ(cDadosServ)										//Metodo que ira processar os servicos
	Method AchouServ(cServicos, nTamanho, cServEspec, nPosicao, ;
					 cTpServ)    									//Metodo interno que ira separar o servico
	Method GetServs()												//Retorna o objeto oServicos
	Method TamServX()												//Calcula o tamanho retornado no servico X
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Servico   �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicos.							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros� 															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Servico() Class LJCServico

	//Estancia o objeto LJCServicos
	::oServicos := LJCServicos():Servicos()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProcServ  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Este metodo ira processar e armazenar os servicos retornados���
���			 �pelo sitef.												  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDadosServ) - String com os servicos.			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Method ProcServ(cDadosServ) Class LJCServico

    Local nCount					:= 0                     //Variavel de controle contador
    Local cTpServ		      		:= ""                    //Armazena o tipo do servico
    Local cDadosAUX				 	:= ""                    //Variavel auxiliar para guardar o conteudo de cada servico
    Local oServico     				:= Nil                   //Objeto que armazena o servico criado
    Local nTamanServ				:= 0                     //Armazena o tamanho dos dados retornado em cada servico
	Local lRetorno					:= .F.					 //Variavel de retorno do metodo    
    
    Begin Sequence
	    //Processa a string com todos os servicos retornados
	    For nCount := 1 to Len(cDadosServ) 
	    	
	    	cTpServ := Substr(cDadosServ, nCount + 1, 1)
	  		oServico := Nil
		        	
	    	Do Case
	    		
	    		Case cTpServ == _SERVICOH
	    			//Servico H
	    			::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	    			oServico := LJCServicoH():ServicoH(_SERVICOH)
	    		
	    		Case cTpServ == _SERVICOA
	    			//Servico A
	    			::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	    			oServico := LJCServicoA():ServicoA(_SERVICOA)
				Case cTpServ == _SERVICOD
					//Servico D
		 			::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	    			oServico := LJCServicoD():ServicoD(_SERVICOD)                      
	
				Case cTpServ == _SERVICON
					//Servico N
		 			::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	    			oServico := LJCServicoN():ServicoN(_SERVICON)                      
	    		Case cTpServ == _SERVICOI
 					@cDadosAUX := cDadosServ
	    			oServico := LJCServicoI():ServicoI(_SERVICOI, .T.) 	 
	    		Case cTpServ == _SERVICO_BAR
	 				//Servico I
	 				::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	 				@cDadosAUX := cDadosServ
	    			oServico := LJCServicoI():ServicoI(_SERVICO_BAR, .T.) 	    			
		    		
	    		Case cTpServ == _SERVICOX
	 				//Servico X
	 				::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
					oServico := LJCServicoX():ServicoX(_SERVICOX)                      
				Case cTpServ == _SERVICOZ
	    			//Servico Z
	    			::AchouServ(cDadosServ, @nTamanServ, @cDadosAUX, @nCount, cTpServ)
	    			oServico := LJCServicoZ():ServicoZ(_SERVICOZ)            
				OtherWise
					nCount++
	
	    	EndCase
	    	
	    	If  oServico != Nil
	    		//Trata o servico encontrado
	    		
	    		oServico:TratarServ(cDadosAUX, @nCount)
				//Adiciona o servico na colecao SERVICOS
				::oServicos:Add(cTpServ, oServico, .T.)
	    	else
	    		If cTpServ == Chr(0) .OR. Empty(cTpServ)
	    			Exit
	    		EndIf
	    	EndIf
	    Next

	    lRetorno := .T.

	Recover
		lRetorno := .F.
	End Sequence
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AchouServ �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo interno que ira separar o servico.					  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cServicos) - String com os servicos.			  ���
���			 �ExpN1 (2 - nTamanho)  - Tamanho dos dados retornados no     ���
���			 �			              servico.							  ���
���			 �ExpC2 (3 - cServEspec)- Os dados retornado no servico.	  ���
���			 �ExpN2 (4 - nPosicao)  - Posicao na string de servicos.	  ���
���			 �ExpC3 (5 - cTpServ)  	- Tipo do servico.	  				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Method AchouServ(cServicos, nTamanho, cServEspec, nPosicao, ;
				 cTpServ) Class LJCServico
	
	Local nTamByte1 := 0							//Tamanho do servicoX byte1
	Local nTamByte2 := 0                           	//Tamanho do servicoX byte2
	
	If cTpServ == _SERVICOX
		//Separa o byte 1 e 2 para obter o tamanho do servicoX
		nTamByte1 := Asc(SubStr(cServicos, nPosicao + 2 ,1))	
		nTamByte2 := Asc(SubStr(cServicos, nPosicao + 3 ,1))			
		//Calcula o tamanho do servicoX
		nTamanho := ::TamServX(nTamByte1, nTamByte2)
		//Separa o servico
		cServEspec := SubStr(cServicos, nPosicao + 4 , nTamanho)
		//Posiciona no proximo servico
		nPosicao := nPosicao + nTamanho + 3
	Else
		//Tamanho do servico
		nTamanho := Asc(SubStr(cServicos, nPosicao ,1))
		//Separa o servico
		cServEspec := SubStr(cServicos, nPosicao + 2 , nTamanho - 1)
		//Posiciona no proximo servico
		nPosicao := nPosicao + nTamanho
	EndIf
			
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetServs  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar uma colecao de servicos.	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									    			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetServs() Class LJCServico
Return ::oServicos

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TamServX  �Autor  �Vendas Clientes     � Data �  04/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o tamanho do servico X.	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nByte1) - Valor em decimal do byte1.			  ���
���			 �ExpN2 (2 - nByte2) - Valor em decimal do byte2.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico									    			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TamServX(nByte1, nByte2) Class LJCServico
	
	Local cHexa1 	:= ""									//Valor em hexadecimal do byte1
	Local cHexa2 	:= ""									//Valor em hexadecimal do byte2
	Local oGlobal 	:= Nil									//Objeto LJCGlobal
	Local cHexa		:= ""									//Byte2 mai byte1 em hexadecimal
	Local nFator	:= 4096									//fator utilizado para calcular o tamanho
	Local nCount	:= 0									//Variavel auxiliar contador
	Local nRetorno	:= 0									//Retorno do metodo

//�����������������������������������������������������������
//�Exemplo para calcular o tamanho do servico               �
//�byte1 em hexa = "B8"                                     �
//�byte2 em hexa = "00"                                     �
//�                                                         �
//�Inverte os bytes                                         �
//�00B8                                                     �
//�Fazer a conta abaixo convertendo byte a byte para decimal�
//�(0 x 4096) + (0 x 256) + (B x 16) + (8 x 1)              �
//�(0 x 4096) + (0 x 256) + (11 x 16) + (8 x 1) = 184       �
//�����������������������������������������������������������
	
	//Estancia o objeto LJCGlobal
	oGlobal := LJCGlobal():Global()
		
	//Converte o byte1 para hexadecimal
	If nByte1 == 0 
		cHexa1 := "00"
	Else
		cHexa1 := oGlobal:Funcoes():DecToHex(nByte1)
	EndIf
	
	//Converte o byte2 para hexadecimal
	If nByte2 == 0 
		cHexa2 := "00"
	Else
		cHexa2 := oGlobal:Funcoes():DecToHex(nByte2)
	EndIf
    
	//Concatena o byte2 com o byte1 em hexadecimal invertendo as posicoes
	cHexa := Padl(cHexa2, 2, "0") + Padl(cHexa1, 2, "0")
	
	//Calcula o tamanho do servico x
	For nCount := 1 To Len(cHexa)
		nRetorno += oGlobal:Funcoes():HexToDec(Substr(cHexa, nCount, 1)) * (nFator)
		nFator := (nFator / 16)
	Next
		
Return nRetorno