#include "TOTVS.CH"

/*/{Protheus.doc} STBPbmMenu
    Chamada do Menu de PBM's
    @type  Function
    @author Julio.Nery
    @since 19/02/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STBPbmMenu()
Local oDlg := NIL

DEFINE MSDIALOG oDlg TITLE "Rotinas PBM" FROM 00,00 TO 240,200 OF GetWndDefault() PIXEL	//"Rotinas PBM"

	@ 10,10 BUTTON "Venda PBM"	SIZE 80,20 OF oDlg PIXEL ACTION ( STBOPbm() , oDlg:End() )	//"Venda PBM"
	@ 30,10 BUTTON "Cancelamento PBM" SIZE 80,20 OF oDlg PIXEL ACTION ( STBCancPbm(), oDlg:End() )	    //"Cancelamento PBM"
	@ 50,10 BUTTON "&Sair"	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )	        	    //"&Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} STBOPbm    
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Static Function STBOPbm()
Local cDoc 		:= ""						// Retorna o numero do cupom fiscal
Local cOperador := STFGetStation("PDV")		// Guada o codigo do pdv para passar para a PBM
Local cSerie	:= STFGetStation("SERIE")	// retorna a SERIE fiscal da estação
Local cTpDoc	:= "0" //tipo de documento utilizado no pbm = 0 - ecf, 1 - nfce, 2 -sat
Local nTamCupPBM:= 6 //Tamanho do cupom PBM
Local oPbm      := NIL

//////////// CONTINUAR DAQUI - 
//PARECE QUE TEM QUE IMPORTAR A SLZ

/* Busca o numero do documento fiscal */	
cDoc := STBPbmNDoc(nTamCupPBM, cSerie, .T.)

//Pega o numero do cupom
If !Empty(cDoc)

    //Estancia o objeto LjCPbm
    oPbm := LjCPbm():Pbm()

    //Seleciona a PBM
    If !oPbm:SelecPbm()
        oPbm := Nil
        STBIsVnPBM(.F.)
    Else
        If STFGetCfg("lUseSAT",.F.)
            cTpDoc := "2"
        ElseIf LjEmitNFCe()
            cTpDoc := "1"
        EndIf
                
        //Inicializa a venda PBM
        If oPbm:IniciaVend( cDoc, cOperador, cTpDoc )
            STFMessage("STBOPbm1","STOP", "Venda PBM" ) //"Venda PBM"
		    STFShowMessage("STBOPbm1")
            STBIsVnPBM(.T.)
        Else
            STBIsVnPBM(.F.)
            oPbm := Nil
        EndIf
    EndIf
EndIf

STFCleanInterfaceMessage()    
Return

/*/{Protheus.doc} STBCancPbm
    Cancelamento da PBM
    @type  Function
    @author user
    @since 19/02/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Static Function STBCancPbm()
Local oPbm := NIL

oPbm := LjCPbm():Pbm()

If oPbm <> Nil
    If oPbm:SelecPbm()
        STFMessage("STBCancPbm1", "STOP", "Cancela PBM" ) //"Cancela PBM"
		STFShowMessage("STBCancPbm1")
        
        If oPbm:CancPbm()
            oTef:ImpCupTef()
        EndIf
    EndIf
EndIf

oPbm := Nil
STBIsVnPBM(.F.)
STFCleanInterfaceMessage()
	
Return Nil

/*/{Protheus.doc} STBPbmNDoc
    Numeração da PBM
    @type  Function
    @author user
    @since 19/02/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Static Function STBPbmNDoc(nTamCupPBM, cSerie, lSomaCup)
Local aLastSat	:= {}
Local cDoc	    := ""

Default nTamCupPBM := 6
Default cSerie     := STFGetStation("SERIE")
Default lSomaCup   := .F.

If LjEmitNFCe()
	//retorna o conteúdo do campo X5_DESCRI	da tabela SX5
	If STFGetCfg("lUseSAT",.F.)
        aLastSat := LJSatNumSale()
        If Len(aLastSat) >= 1
            cDoc := aLastSat[01]
            cDoc := Right( cDoc, nTamCupPBM )
            //a transação PBM somente suporta 6 caracteres para o número do cupom fiscal
            cDoc := PADL( Val(cDoc) + IIF(lSomaCup,1, 0), nTamCupPBM, "0" )
        EndIf
	Else
		cDoc := Tabela('01', cSerie)
		//a transação PBM somente suporta 6 caracteres para o número do cupom fiscal
		cDoc := Right( cDoc, nTamCupPBM )
	EndIf	
Else		
	cDoc := STBCSNumPrinter()
	//+1 no numero retornado, pois ela retorna o ultimo numero utilizado
	cDoc := PADL( Val(cDoc)+ IIF(lSomaCup,1,0), nTamCupPBM, "0" )
EndIf
				
Return cDoc

/*/{Protheus.doc} STBIsVnPBM()
    Retorna se esta em uma venda PBM
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STBIsVnPBM(lSet)
Local lRet := .F.
Default lSet := .F.

Static lIsVndPBM := .F.

If ValType(lSet) == "L"
    lIsVndPBM := lSet
EndIf

lRet := lIsVndPBM
Return lRet