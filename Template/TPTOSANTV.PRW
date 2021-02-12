#Include "Protheus.ch"

Static cUsrSessionID  	// Id para autenticação no WebServer - Front   .
Static cSenha := "******"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³TPtosAntV ºAutor  ³Thiago Honorato     º Data ³  DEZ/2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que busca a pontuacao do Cliente anterior a venda.  º±±
±±º          ³ Esta funcao sera chamada no momento em que o Cliente eh    º±±
±±º          ³ escolhido.												  º±±
±±º          ³ Eh chamada no											  º±±
±±º          ³ PROGRAMA TPLDROPE.prw  									  º±±
±±º          ³ FUNCAO   FRT010CL 			  							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template - DRO  - SIGAFRT   					              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function TPtosAntV()
Local oSvcP			
Local cSvcError     := ""
Local cSoapFCode    := ""
Local cSoapFDescr   := ""
Local lRet          := .T.  
Local lWsGetPtos    := .T.
Local nPontos		:= 0   

oSvc      := WSLJPESQPONTOS():New()//cria uma estancia da classe do WebService WSLJPESQPONTOS
oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJPESQPONTOS.apw"

If cUsrSessionID == Nil
	LJMsgRun( "Aguarde... Efetuando login no servidor ...",, {|| cUsrSessionID := WSCrdLogin( Substr(cUsuario,7,15), cSenha ) } )
EndIf

While lWsGetPtos
	LJMsgRun("Aguarde... Atualizando Pontos Referentes ao Plano de Fidelidade...",, {|| lRet := oSvc:GetPontos(cUsrSessionID,xFilial("SA1"),SA1->A1_COD,SA1->A1_LOJA) })
	If !lRet
		cSvcError   := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			
			// Se necessario efetua outro login antes de chamar o metodo GetPontos novamente
			If cSoapFCode $ "-1,-2,-3"
				LJMsgRun( "Aguarde... Efetuando login no servidor ...",, {|| cUsrSessionID := WSCrdLogin( Substr(cUsuario,7,15), cSenha ) } )
				lWsGetPtos := .T.
			Else
				MsgStop(cSoapFDescr, "Error " + cSoapFCode)
				lWsGetPtos := .F.	// Nao chama o metodo GetPontos novamente
			Endif
		Else
			MsgStop("Sem comunicação com o WebService!","Atenção.")
			lWsGetPtos := .F. // Nao chama o metodo GetPontos novamente
		EndIf
	Else
		nPontos    := oSVC:nGETPONTOSRESULT
		lWsGetPtos := .F. // Nao chama o metodo GetPontos novamente
	EndIf
End

Return nPontos