#INCLUDE "LOJXCARTAO.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 

Function ___LOJXCARTAO
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LOJXCARTAOºAutor  ³Thiago Honorato	 º Data ³  FEV/2006   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WEBSERVICES que busca a numeracao de cartao do cliente      º±±
±±º          ³do tipo CONVENIADO                                          º±±
±±º          ³Tambem eh verificado o STATUS do cartao e se o LIMITE DE    º±±
±±º          ³CREDITO estah igual a zero                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºWSMETHOD  ³PesqCartaoºAutor  ³Andre / Thiago      º Data ³  03/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TPLDRO                                                     º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º Progr.   ³ Data     BOPS   Descricao								  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºA.Veiga   ³14/03/06³Drog. ³Alteracao da estrutura do WebService para   º±±
±±º          ³        ³Moder-³considerar as mensagens de cartao "Ativo"   º±±
±±º          ³        ³na    ³ou nao para a venda. Se o cartao estiver    º±±
±±º          ³        ³      ³bloqueado, permite continuar a venda mas    º±±
±±º          ³        ³      ³no final o pagamento nao podera ser feito   º±±
±±º          ³        ³      ³atraves de financiamento.                   º±±
±±ºThiago H. ³04/05/06³97894 ³Alterado o parametro WSSEND de NUMCART p/   º±±
±±º          ³        ³      ³RetCart                                     º±±
±±º          ³        ³      ³NUMCART eh do tipo string                   º±±
±±º          ³        ³      ³Retcart eh do tipo estrutura (array)        º±±
±±ºThiago H. ³13/03/07³121164³Alterado de Static Function para somente    º±±
±±º          ³        ³      ³Function a funcao LjPesqCar()               º±±
±±º          ³        ³      ³Com isso a mesma podera ser chamada         º±±
±±º          ³        ³      ³por outros programas.                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD PesqCartao WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli WSSEND RetCart WSSERVICE LJPESQCART
Local lRet := .T.
Local aRet

//³Verifica a validade e integridade do ID de login do usuario
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
Local cMsg 			:= "" 				// Mensagem para o usuário
Local cNumeroCart	:= ""				// Numero do cartao
Local aNumeroCart	:= {}				// Array com os numeros de cartao do cliente cadastrado no MA6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a variavel com o limite de credito do cliente                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLimite := Posicione("SA1",1,cFilCli+cCodCli+cLojaCli,"A1_LC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aRet  - Template Drogaria                 ³
//³-------------------------------------------------------------³
//³-    aRet[1]  =  .F. = bloqueia a venda                      ³
//³-                .T. = nao bloqueia a venda                  ³
//³-    aRet[2]  =  numero do cartao                            ³
//³-    aRet[3]  =  Titulo da janela de aviso                   ³
//³-    aRet[4]  =  Mensagem da janela de aviso                 ³
//³-------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MA6")
dbSetOrder(2)
If MsSeek(cFilCli+cCodCli+cLojaCli)
	Do While !Eof() .AND. cFilCli+cCodCli+cLojaCli == MA6_FILIAL + MA6_CODCLI + MA6_LOJA
		If !Empty(MA6->MA6_CODDEP)
			DbSkip()
			Loop
		EndIf   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o cartao estiver 'ativo' e o numero do cartao estiver preenchido  ³
		//³ libera a venda.                                                      ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Se o cartao estiver 'bloqueado' mostra msg para o usuario que o      ³
		//³ cartao esta bloqueado mas libera a venda para ser finalizada com     ³
		//³ outra forma de pagamento.                                            ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Se o cartao estiver 'cancelado' mostra a msg mas bloqueia a venda    ³
		//³ para este cliente. Caso o cliente queira continuar a compra ele      ³
		//³ nao sera' identificado, isto e', sera' feita a venda para o cliente  ³
		//³ padrao.                                                              ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Em qualquer um dos casos se nao houver limite no cartao, o operador  ³
		//³ do caixa sera' informado disto sem influenciar no bloqueio da venda  ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ Status MA6_SITUA                                                     ³
		//³ "1" - Ativo                                                          ³
		//³ "2" - Bloqueado                                                      ³
		//³ "3" - Cancelado                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual o numero do cartao do cliente                          ³
//³ Verifica se tem algum ATIVO, se nao, verifica se tem algum bloqueado ³
//³ se nao, verifica o cancelado                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se ira' bloquear a venda ou nao                               ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Obs.: A venda sera' liberada se o cartao estiver ativo ou bloqueado. ³
//³ - No caso de cartao cancelado, a venda sera' bloqueada para o cliente³
//³ em referencia.                                                       ³
//³ - Se o cartao estiver bloqueado, libera a venda para o cliente ter   ³
//³ direito aos descontos do seu plano de fidelidade mas nao podera'     ³
//³ comprar no financiamento                                             ³
//³                                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBloqVenda := .F.
If lCartAtivo
	lBloqVenda := .F.
ElseIf lCartBloq
	lBloqVenda := .F.
ElseIf lCartCanc
	lBloqVenda := .T.
Endif

If !lBloqVenda
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o cartao estiver bloqueado, mostra msg para o usuario.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCartAtivo
		If nLimite == 0
			cMsg	:= STR0008 // "Cliente sem limite de crédito. Não será permitido o fechamento da venda através de financiamento."
		Endif
	ElseIf lCartBloq
		If nLimite == 0
			cMsg	:= STR0007 // "Cartão bloqueado e cliente sem limite de crédito. Não será permitido o fechamento da venda através de financiamento."
		Else
			cMsg  	:= STR0005 // "Cartão bloqueado. Não será permitido o fechamento da venda através de financiamento."
		Endif
	Endif
	
    aRet  := {	.T.,;
    			cNumeroCart,;
    			STR0006,;			// "Atenção"
    			cMsg }   
Else
	aRet[1] := .F.
	aRet[2] := ""
	aRet[3] := STR0006				// "Atenção"
	aRet[4] := STR0002 				// "Cartão cancelado. Favor encaminhar o cliente ao Departamento de Crédito."
	
EndIf

// Restaura area original
RestArea(aAreaAtu)

Return aRet