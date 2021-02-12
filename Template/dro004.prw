#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "DRO004.CH"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
  
#XTRANSLATE bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#XCOMMAND DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    	 <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
	  [  <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

User Function DRO004 ; Return  // "dummy" function - Internal Use 

/*����������������������������������������������������������������������������������
���Classe    �DROWizardAnvisa  �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em capturar as informacoes para geracao do XML  ���
���			 �atraves de um wizard.												 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
����������������������������������������������������������������������������������*/
Class DROWizardAnvisa 

	Data dDtInicio											//Data inicial
	Data dDtFim                                            	//Data final
	Data cCpf												//Cpf do transmissor
	Data cPath												//Caminho onde sera gravado o arquivo
	Data lCancelado											//Informa se o wizard foi cancelado
		
	Method WizardAnv()										//Metodo construtor
	Method Show()											//Metodo que ira iniciar o wizard
	Method ValidaData()    									//Metodo que ira validar as data informadas
	Method ValidaCpf()										//Metodo que ira validar o Cpf informado
	Method ValidaPath()										//Metodo que ira validar o caminho onde sera gravado o arquivo
	Method GetCancel()										//Metodo que ira retornar se o wizard foi cancelado
	Method GetDtIni()                                     	//Metodo que ira retornar a data inicio
	Method GetDtFim()                                     	//Metodo que ira retornar a data fim
	Method GetPath()										//Metodo que ira retornar o caminho onde sera gravado o arquivo
	Method GetCpf()											//Metodo que ira retornar o CPF
		
EndClass

/*������������������������������������������������������������������������������������
���Classe    �DroWizardAnvisaInv     �Autor  �Vendas Clientes     � Data �  06/03/13���
�����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                            ���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		     ���
���������������������������������������������������������������������������������������*/
Class DroWizardAnvisaInv From  DROWizardAnvisa

	Method New() Constructor												//Metodo que ira iniciar o wizard

EndClass 
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  06/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJC_DadosCDes. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �          			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class DroWizardAnvisaInv

	_Super:WizardAnv()

Return()


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �WizardAnv        �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe WizardAnvisa.						     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method WizardAnv() Class DROWizardAnvisa 

	::dDtInicio 	:= Nil 
	::dDtFim    	:= Nil
	::cCpf      	:= Space(11)
	::cPath     	:= ""
	::lCancelado	:= .T.

Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Show             �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em iniciar o wizard.       				     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Show() Class DROWizardAnvisa 
	
	Local oWizard 	:= Nil   						//Objeto do wizard
	Local oPanel 	:= Nil							//Objeto dos paineis do wizard    
	Local oGrupo	:= Nil							//Objeto dos grupos criados nos paineis    
	Local oGet		:= Nil							//Objeto TGet
	Local lInv		:= IsInCallStack("T_DROInvWizard") // se eh geracao de inventario	
	//set date brit
	//set epoch to 1911
	
	::dDtInicio := CTOD("  /  /    ") 
	::dDtFim    := CTOD("  /  /    ")
	
   	//Criando objeto Wizard
	DEFINE WIZARD oWizard TITLE STR0001 ; //"Gera��o XML Anvisa SNGPC"
	HEADER STR0002 ; //"Wizard da gera��o do XML:"
	MESSAGE "" TEXT ;
	NEXT {|| .T.} FINISH {|| .T.} PANEL
	
	//Criando painel para capturar a data inicial e final
	CREATE PANEL oWizard HEADER STR0003 ; //"Dados para gera��o do XML"
	MESSAGE IIF(lInv,"",STR0004) ; //"Informe a data inicial e final:"
	BACK {|| .T. }	NEXT {|| IIF(lInv,.T.,::ValidaData())} FINISH {|| .T. } PANEL

	If !lInv  	
	
		oPanel := oWizard:GetPanel(2)
 
		oGrupo := TGroup():New(5,2,135,287,STR0005,oPanel,,,.T.) //"Intervalo de Data:"
		
		bValid   := {|| .T.}
		TSay():New(15,08,{|| STR0006},oPanel,,,,,,.T.) //"Data inicial"
		oGet := TGet():New(14,70,bSETGET(::dDtInicio),oPanel,50,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
		
		bValid   := {|| .T.}
		TSay():New(35,08,{|| STR0007},oPanel,,,,,,.T.) //"Data final"
		oGet := TGet():New(34,70,bSETGET(::dDtFim),oPanel,50,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)
	Else
		::dDtInicio	:= Date() 
		::dDtFim	:= Date()		
	EndIf
	
	//Criando painel para capturar o CPF do transmissor
	CREATE PANEL oWizard HEADER STR0003 ; //"Dados para gera��o do XML"
	MESSAGE STR0010 ; //"Informe o CPF do transmissor:"
	BACK {|| .T. } NEXT {|| ::ValidaCpf()} FINISH {|| .T.} PANEL         
  		
	oPanel := oWizard:GetPanel(3)
	
	oGrupo := TGroup():New(5,2,135,287,STR0011,oPanel,,,.T.) //"CPF Transmissor:"
	
	bValid   := {|| .T.}
	TSay():New(15,08,{|| "CPF"},oPanel,,,,,,.T.)
	oGet := TGet():New(14,70,bSETGET(::cCpf),oPanel,80,10,"@R 999.999.999-99",bValid,,,,,,.T.,,,,,,,.F.,,"LKB2",)
	
	//Criando painel para capturar o caminho onde sera gravado o arquivo
	CREATE PANEL oWizard HEADER STR0003 ; //"Dados para gera��o do XML"
	MESSAGE STR0016 ; //"Escolha o caminho do arquivo:"
	BACK {|| .T. } NEXT {|| .T.} FINISH {|| ::ValidaPath()} PANEL  
	
	oPanel := oWizard:GetPanel(4)
	
	oGrupo := TGroup():New(5,2,135,287,STR0017,oPanel,,,.T.) //"Caminho de Gera��o do XML:"
      
	oGet1 := TGet():New(14,8, bSETGET(::cPath),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
	SButton():New(14,120,14,{|| ::cPath := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo.",0,,.T.,GETF_RETDIRECTORY + GETF_LOCALHARD )},oPanel)

	ACTIVATE WIZARD oWizard CENTER

Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ValidaData       �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em validar as datas informadas.			     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ValidaData() Class DROWizardAnvisa 
	
	Local lRetorno := .T.				//Variavel de retorno do metodo
	
	//Verifica se as data foram informadas
	If Empty(::dDtInicio)
		MsgAlert(STR0008)//"Informar a data inicial"
		lRetorno := .F.
	ElseIf Empty(::dDtFim)
		MsgAlert(STR0009)//"Informar a data final"
		lRetorno := .F.
	ElseIf ::dDtFim < ::dDtInicio
		MsgAlert(STR0013)//"Data final deve ser igual ou posterior � data inicial"
		lRetorno := .F.	
	ElseIf ::dDtFim >= Date()
		MsgAlert(STR0014)//"Data final tem que ser anterior ao dia atual"
		lRetorno := .F.	
	ElseIf ::dDtFim > (::dDtInicio + 6)
		MsgAlert(STR0015)//"Data final n�o pode ser superior a 7 dias da data inicial"
		lRetorno := .F.	
	Endif	
	  
Return lRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ValidaCpf        �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em validar a CPF.              			     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ValidaCpf() Class DROWizardAnvisa 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	
	If Empty(::cCpf) .OR. ::cCpf == ""
		MsgAlert(STR0012)//"Informar o CPF do transmissor"
		lRetorno := .F.
	Else 
		If T_DroCPF(::cCpf)
			dbSelectArea("LKB") //Farmaceutico
			LKb->(dbSetOrder(1))
			If LKb->(dbSeek(xFilial("LKB") + ::cCpf ))
				If LKb->LKB_RESPON <> "1" // Responsavel Sim = 1
					MsgAlert("Transmissor n�o � respons�vel para enviar XML") //"Transmissor n�o � respons�vel para enviar XML"
					lRetorno := .F.
				EndIf
			Else
				MsgAlert("CPF do transmissor inv�lido")//"CPF do transmissor inv�lido"
				lRetorno := .F.
			EndIf
		Else
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ValidaPath       �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em validar o caminho do arquivo.  			     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ValidaPath() Class DROWizardAnvisa 
	
	Local lRetorno 	:= .T. 				//Variavel de retorno do metodo
	
	If Empty(::cPath)
		MsgAlert(STR0018) //"Escolha o caminho do arquivo"
		lRetorno := .F.
	Else
		::lCancelado := .F.
	EndIf

Return lRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetCancel        �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se o wizard foi cancelado.		     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetCancel() Class DROWizardAnvisa 
Return ::lCancelado
					
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetDtIni         �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar a data inicio.         		     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Date  														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetDtIni() Class DROWizardAnvisa 
Return ::dDtInicio

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetDtFim         �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar a data final.           		     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Date  														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetDtFim() Class DROWizardAnvisa 
Return ::dDtFim

/*����������������������������������������������������������������������������������
���Metodo    �GetPath          �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho onde sera gravado o arq.  ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String  														     ���
����������������������������������������������������������������������������������*/
Method GetPath() Class DROWizardAnvisa 
Return ::cPath

/*����������������������������������������������������������������������������������
���Metodo    �GetCpf           �Autor  �Vendas Clientes     � Data �  31/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o CPF.                  		     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico 														     ���
����������������������������������������������������������������������������������*/
Method GetCpf() Class DROWizardAnvisa 
Return ::cCpf

/*����������������������������������������������������������������������������������
���Metodo    �DroRespon        �Autor  �Vendas Clientes     � Data �  31/10/15   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o Responsavel, utilizado na        ͹��
���           consulta LK2B2                                         		     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja                                                   		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico 														     ���
����������������������������������������������������������������������������������*/
Function DroRespon() 
Local cEAN 		:=  "1"
Local cConsulta := "LKB->LKB_RESPON == '" + cEAN + "'"
Local xRet		:= NIL 

xRet := &(cConsulta)

Return xRet
