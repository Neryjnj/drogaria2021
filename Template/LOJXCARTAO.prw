#INCLUDE "LOJXCARTAO.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 

Function ___LOJXCARTAO
Return Nil

/*���������������������������������������������������������������������������
���Programa  �LOJXCARTAO�Autor  �Thiago Honorato	 � Data �  FEV/2006   ���
�������������������������������������������������������������������������͹��
���Desc.     �WEBSERVICES que busca a numeracao de cartao do cliente      ���
���          �do tipo CONVENIADO                                          ���
���          �Tambem eh verificado o STATUS do cartao e se o LIMITE DE    ���
���          �CREDITO estah igual a zero                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
WSSTRUCT WSPesqCart
	WSDATA Cartao		AS String
	WSDATA Mensagem		As String
ENDWSSTRUCT

WSSERVICE LJPESQCART
	WSDATA UsrSessionID	AS String
	WSDATA Filial       As String
	WSDATA CodCli       As String
	WSDATA LojaCli      As String	
	WSDATA NUMCART      As String
	WSDATA RetCart		As Array of WSPesqCart
	
	WSMETHOD PesqCartao
ENDWSSERVICE

/*���������������������������������������������������������������������������
���WSMETHOD  �PesqCartao�Autor  �Andre / Thiago      � Data �  03/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TPLDRO                                                     ���
�������������������������������������������������������������������������Ĺ��
��� Progr.   � Data     BOPS   Descricao								  ���
�������������������������������������������������������������������������Ĺ��
���A.Veiga   �14/03/06�Drog. �Alteracao da estrutura do WebService para   ���
���          �        �Moder-�considerar as mensagens de cartao "Ativo"   ���
���          �        �na    �ou nao para a venda. Se o cartao estiver    ���
���          �        �      �bloqueado, permite continuar a venda mas    ���
���          �        �      �no final o pagamento nao podera ser feito   ���
���          �        �      �atraves de financiamento.                   ���
���Thiago H. �04/05/06�97894 �Alterado o parametro WSSEND de NUMCART p/   ���
���          �        �      �RetCart                                     ���
���          �        �      �NUMCART eh do tipo string                   ���
���          �        �      �Retcart eh do tipo estrutura (array)        ���
���Thiago H. �13/03/07�121164�Alterado de Static Function para somente    ���
���          �        �      �Function a funcao LjPesqCar()               ���
���          �        �      �Com isso a mesma podera ser chamada         ���
���          �        �      �por outros programas.                       ���
���������������������������������������������������������������������������*/
WSMETHOD PesqCartao WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli WSSEND RetCart WSSERVICE LJPESQCART
Local lRet := .T.
Local aRet

//�Verifica a validade e integridade do ID de login do usuario
If !IsSessionVld( ::UsrSessionID )
	lRet := .F.
Endif

aRet := LjPesqCar(::Filial, ::CodCli, ::LojaCli)

If !aRet[1]
	SetSoapFault(aRet[3], aRet[4])
	lRet := .F.
Else
	::RetCart := Array( 1 )
	::RetCart[1]			:= WSClassNew( "WSPesqCart" )
	::RetCart[1]:Cartao 	:= aRet[2]
	::RetCart[1]:Mensagem 	:= aRet[4]
EndIf

Return lRet                                 
                                                      
//----------------------------------------------------------
/*/{Protheus.doc} LjPesqCar

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------            
Function LjPesqCar(cFilCli, cCodCli, cLojaCli)
Local aAreaAtu   	:= GetArea()
Local aRet       	:= Array(4)
Local nLimite    	:= 0 				// Traz o valor do LIMITE DE CREDITO do cliente
Local lBloqVenda	:= .T. 				// Indica se e' para bloquear a venda ou nao 
Local lCartAtivo	:= .F.				// Indica se tem cartao ativo 
Local lCartBloq		:= .F.				// Indica se tem cartao bloqueado
Local lCartCanc		:= .F. 				// Indica se tem cartao cancelado
Local cMsg 			:= "" 				// Mensagem para o usu�rio
Local cNumeroCart	:= ""				// Numero do cartao
Local aNumeroCart	:= {}				// Array com os numeros de cartao do cliente cadastrado no MA6

//����������������������������������������������������������������������Ŀ
//� Define a variavel com o limite de credito do cliente                 �
//������������������������������������������������������������������������
nLimite := Posicione("SA1",1,cFilCli+cCodCli+cLojaCli,"A1_LC")

//�������������������������������������������������������������Ŀ
//�Estrutura do array aRet  - Template Drogaria                 �
//�-------------------------------------------------------------�
//�-    aRet[1]  =  .F. = bloqueia a venda                      �
//�-                .T. = nao bloqueia a venda                  �
//�-    aRet[2]  =  numero do cartao                            �
//�-    aRet[3]  =  Titulo da janela de aviso                   �
//�-    aRet[4]  =  Mensagem da janela de aviso                 �
//�-------------------------------------------------------------�
//���������������������������������������������������������������
dbSelectArea("MA6")
dbSetOrder(2)
If MsSeek(cFilCli+cCodCli+cLojaCli)
	Do While !Eof() .AND. cFilCli+cCodCli+cLojaCli == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		If !Empty(MA6->MA6_CODDEP)
			DbSkip()
			Loop
		EndIf   
	
		//����������������������������������������������������������������������Ŀ
		//� Se o cartao estiver 'ativo' e o numero do cartao estiver preenchido  �
		//� libera a venda.                                                      �
		//����������������������������������������������������������������������ĳ
		//� Se o cartao estiver 'bloqueado' mostra msg para o usuario que o      �
		//� cartao esta bloqueado mas libera a venda para ser finalizada com     �
		//� outra forma de pagamento.                                            �
		//����������������������������������������������������������������������ĳ
		//� Se o cartao estiver 'cancelado' mostra a msg mas bloqueia a venda    �
		//� para este cliente. Caso o cliente queira continuar a compra ele      �
		//� nao sera' identificado, isto e', sera' feita a venda para o cliente  �
		//� padrao.                                                              �
		//����������������������������������������������������������������������ĳ
		//� Em qualquer um dos casos se nao houver limite no cartao, o operador  �
		//� do caixa sera' informado disto sem influenciar no bloqueio da venda  �
		//����������������������������������������������������������������������ĳ
		//� Status MA6_SITUA                                                     �
		//� "1" - Ativo                                                          �
		//� "2" - Bloqueado                                                      �
		//� "3" - Cancelado                                                      �
		//������������������������������������������������������������������������
		If ( MA6_SITUA == "1" .AND. !Empty(MA6_NUM) )
			lCartAtivo	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, "ATIVO" } )
		ElseIf ( MA6_SITUA == "2" .AND. !Empty(MA6_NUM) )
			lCartBloq	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, "BLOQUEADO" } )
		ElseIf ( MA6_SITUA == "3" .AND. !Empty(MA6_NUM) )
			lCartCanc	:= .T.
			aAdd( aNumeroCart, { MA6->MA6_NUM, "CANCELADO" } )
		EndIf
	            
	   	dbSkip()
	End
EndIf

//����������������������������������������������������������������������Ŀ
//� Verifica qual o numero do cartao do cliente                          �
//� Verifica se tem algum ATIVO, se nao, verifica se tem algum bloqueado �
//� se nao, verifica o cancelado                                         �
//������������������������������������������������������������������������
If lCartAtivo
	nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == "ATIVO" } )
	cNumeroCart := aNumeroCart[nPosTmp][1]
ElseIf lCartBloq
	nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == "BLOQUEADO" } )
	cNumeroCart := aNumeroCart[nPosTmp][1]
ElseIf lCartCanc
	nPosTmp		:= aScan( aNumeroCart, { |x| x[2] == "CANCELADO" } )
	cNumeroCart := aNumeroCart[nPosTmp][1]
Else 
	cNumeroCart := Space( TamSX3( "MA6_NUM" )[1] )
Endif

//����������������������������������������������������������������������Ŀ
//� Define se ira' bloquear a venda ou nao                               �
//����������������������������������������������������������������������ĳ
//� Obs.: A venda sera' liberada se o cartao estiver ativo ou bloqueado. �
//� - No caso de cartao cancelado, a venda sera' bloqueada para o cliente�
//� em referencia.                                                       �
//� - Se o cartao estiver bloqueado, libera a venda para o cliente ter   �
//� direito aos descontos do seu plano de fidelidade mas nao podera'     �
//� comprar no financiamento                                             �
//�                                                                      �
//������������������������������������������������������������������������
lBloqVenda := .F.
If lCartAtivo
	lBloqVenda := .F.
ElseIf lCartBloq
	lBloqVenda := .F.
ElseIf lCartCanc
	lBloqVenda := .T.
Endif

If !lBloqVenda
	//����������������������������������������������������������������������Ŀ
	//� Se o cartao estiver bloqueado, mostra msg para o usuario.            �
	//������������������������������������������������������������������������
	If lCartAtivo
		If nLimite == 0
			cMsg	:= STR0008 // "Cliente sem limite de cr�dito. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
		Endif
	ElseIf lCartBloq
		If nLimite == 0
			cMsg	:= STR0007 // "Cart�o bloqueado e cliente sem limite de cr�dito. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
		Else
			cMsg  	:= STR0005 // "Cart�o bloqueado. N�o ser� permitido o fechamento da venda atrav�s de financiamento."
		Endif
	Endif
	
    aRet  := {	.T.,;
    			cNumeroCart,;
    			STR0006,;			// "Aten��o"
    			cMsg }   
Else
	aRet[1] := .F.
	aRet[2] := ""
	aRet[3] := STR0006				// "Aten��o"
	aRet[4] := STR0002 				// "Cart�o cancelado. Favor encaminhar o cliente ao Departamento de Cr�dito."
	
EndIf

// Restaura area original
RestArea(aAreaAtu)

Return aRet