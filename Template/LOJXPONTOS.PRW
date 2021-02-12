#include "PROTHEUS.CH"
#include "APWEBSRV.CH" 

Function ___LJPESQPONTOS
Return Nil

WSSERVICE LJPESQPONTOS   
	WSDATA UsrSessionID	AS String
	WSDATA Filial       As String
	WSDATA CodCli       As String
	WSDATA LojaCli      As String	
	WSDATA PONTOS       As Integer
	
	WSMETHOD GetPontos                                   
ENDWSSERVICE

WSMETHOD GetPontos WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli WSSEND PONTOS WSSERVICE LJPESQPONTOS
Local lRet := .T.
Local aRet

//Verifica a validade e integridade do ID de login do usuario
If !IsSessionVld( ::UsrSessionID )
	lRet := .F.
Endif
 
aRet := LjPesqPtos(::Filial, ::CodCli, ::LojaCli)

If !aRet[1]
	SetSoapFault(aRet[3], aRet[4])
	lRet := .F.
Else
	::PONTOS := aRet[2]
EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------//            

WSSERVICE LJGRVPONTOS
	WSDATA UsrSessionID	AS String
	WSDATA Filial       As String
	WSDATA CodCli       As String
	WSDATA LojaCli 	    As String	         
	WSDATA Sinal 	    As String	         	
	WSDATA PONTOS	    As Integer
	WSDATA GRAVOU       As Boolean
	
	WSMETHOD GrvPontos                                   
ENDWSSERVICE


WSMETHOD GrvPontos WSRECEIVE UsrSessionID, Filial, CodCli, LojaCli, Sinal, PONTOS WSSEND GRAVOU WSSERVICE LJGRVPONTOS

Local aRet
                                           
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica a validade e integridade do ID de login do usuario         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !IsSessionVld( ::UsrSessionID )
	Return(.F.)
Endif

aRet := LjGrvPtos(::Filial, ::CodCli, ::LojaCli, ::Sinal, ::PONTOS)

If !aRet[1]
	SetSoapFault(aRet[2], aRet[3])
	Return(.F.)
Else
	::GRAVOU := aRet[1]
EndIf

Return .T.                                      
                                                      
//----------------------------------------------------------------------------------------------------------------//            
           
Static Function LjPesqPtos(cFilCli, cCodCli, cLojaCli)

Local aAreaAtu := GetArea()
Local aAreaSA1 := {}
Local aRet     := Array(4)

dbSelectArea("SA1")
aAreaSA1 := GetArea()
dbSetOrder(1)
If dbSeek(cFilCli+cCodCli+cLojaCli)
	aRet[1] := .T.
	aRet[2] := SA1->A1_PONTOS
Else              
	aRet[1] := .F.
	aRet[2] := 0
	aRet[3] := "Cliente / Loja nao encontrados na base de dados."	
	aRet[4] := "E necessario informar um codigo de cliente e loja validos para pesquisa dos pontos acumulados."	
EndIf

// Restaura area do aquivo SA1
RestArea(aAreaSA1)

// Restaura area original
RestArea(aAreaAtu)

Return(aRet)

//----------------------------------------------------------------------------------------------------------------//            
           
Static Function LjGrvPtos(cFilCli, cCodCli, cLojaCli, cSinal, nPontos)

Local aAreaAtu := GetArea()
Local aAreaSA1 := {}
Local aRet     := Array(3)

dbSelectArea("SA1")
aAreaSA1 := GetArea()
dbSetOrder(1)
If dbSeek(cFilCli+cCodCli+cLojaCli)
	RecLock("SA1",.F.)
	If AllTrim(cSinal) == "+"
		A1_PONTOS += nPontos
	Else 
		A1_PONTOS -= nPontos	
	EndIf
	MsUnLock()            
	aRet[1] := .T.	
Else              
	aRet[1] := .F.
	aRet[2] := "Cliente / Loja nao encontrados na base de dados."	
	aRet[3] := "E necessario informar um codigo de cliente e loja validos para pesquisa dos pontos acumulados."	
EndIf

// Restaura area do aquivo SA1
RestArea(aAreaSA1)

// Restaura area original
RestArea(aAreaAtu)

Return(aRet)
