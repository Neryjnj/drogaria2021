#INCLUDE "MSOBJECT.CH"
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConstantes referente aos servicos utilizadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCServico   บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel por armazenar todos os servicos retornados do      บฑฑ
ฑฑบ          ณsitef.													     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณServico   บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCServicos.							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Servico() Class LJCServico

	//Estancia o objeto LJCServicos
	::oServicos := LJCServicos():Servicos()

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณProcServ  บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEste metodo ira processar e armazenar os servicos retornadosบฑฑ
ฑฑบ			 ณpelo sitef.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cDadosServ) - String com os servicos.			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAchouServ บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo interno que ira separar o servico.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cServicos) - String com os servicos.			  บฑฑ
ฑฑบ			 ณExpN1 (2 - nTamanho)  - Tamanho dos dados retornados no     บฑฑ
ฑฑบ			 ณ			              servico.							  บฑฑ
ฑฑบ			 ณExpC2 (3 - cServEspec)- Os dados retornado no servico.	  บฑฑ
ฑฑบ			 ณExpN2 (4 - nPosicao)  - Posicao na string de servicos.	  บฑฑ
ฑฑบ			 ณExpC3 (5 - cTpServ)  	- Tipo do servico.	  				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetServs  บAutor  ณVendas Clientes     บ Data ณ  04/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar uma colecao de servicos.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									    			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetServs() Class LJCServico
Return ::oServicos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณTamServX  บAutor  ณVendas Clientes     บ Data ณ  04/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o tamanho do servico X.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 (1 - nByte1) - Valor em decimal do byte1.			  บฑฑ
ฑฑบ			 ณExpN2 (2 - nByte2) - Valor em decimal do byte2.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico									    			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TamServX(nByte1, nByte2) Class LJCServico
	
	Local cHexa1 	:= ""									//Valor em hexadecimal do byte1
	Local cHexa2 	:= ""									//Valor em hexadecimal do byte2
	Local oGlobal 	:= Nil									//Objeto LJCGlobal
	Local cHexa		:= ""									//Byte2 mai byte1 em hexadecimal
	Local nFator	:= 4096									//fator utilizado para calcular o tamanho
	Local nCount	:= 0									//Variavel auxiliar contador
	Local nRetorno	:= 0									//Retorno do metodo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExemplo para calcular o tamanho do servico               ณ
//ณbyte1 em hexa = "B8"                                     ณ
//ณbyte2 em hexa = "00"                                     ณ
//ณ                                                         ณ
//ณInverte os bytes                                         ณ
//ณ00B8                                                     ณ
//ณFazer a conta abaixo convertendo byte a byte para decimalณ
//ณ(0 x 4096) + (0 x 256) + (B x 16) + (8 x 1)              ณ
//ณ(0 x 4096) + (0 x 256) + (11 x 16) + (8 x 1) = 184       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
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