#Include "Rwmake.ch"    
#Include "Tbiconn.ch"
#Include "TopConn.ch"

//********************************************************//
// Rotina: AtlTPrc()                                      //
//------------------------ -------------------------------//
// Rotina para atualização da Tabela de Preçoes "SB0"     //
// a partir das Tabelas de Preços da Matriz e todas as    //
// suas Filiais                                           //
//********************************************************//
Template Function AtlTPrc()

If MsgBox("Confirma o lançamento dos preços?", "Lanc. de Preços", "YESNO")
	Processa({|| ProcAtlPrc(.F.)}, "Processando lançamento dos preços...")
	MsgAlert("Lançamento dos preços realizado com sucesso!")
EndIf
		
Return .T.

//********************************************************//
// Rotina (Job): AtlTPrcJ()                               //
//--------------------------------------------------------//
// Rotina para atualização da Tabela de Preçoes "SB0"     //
// a partir das Tabelas de Preços da Matriz e todas as    // 
// suas Filiais                                           //
//********************************************************//
Template Function AtlTPrcJ()

Local cEmp  := "99"
Local cFil  := "01"
Local nTime := 5000

 Prepare Environment Empresa cEmp Filial cFil Modulo "FAT" Tables "DA0", "DA1", "SB0"

 While !KillApp() //Enquanto o Protheus estiver em funcionamento
 
 	ProcAtlPrc(.T.)
    
	Sleep(nTime)          
	DbGoTop()
	
 EndDo

Return .T.

//////////////////////////////////////////////////////////////////
// Rotina: ProcAltPrc                                           //
//--------------------------------------------------------------//
// Rotina que processa a atualização da Tabela de Preçoes "SB0" //
// a partir das Tabelas de Preços da Matriz e todas as          //
// suas Filiais                                                 //
//////////////////////////////////////////////////////////////////
Static Function ProcAtlPrc(lJob)

	DBSelectArea("DA0")
	DbSetOrder(1)
	DbGotop()
	
	If !lJob
		ProcRegua(RecCount())
	EndIf
	
	While !EOF()
	
		If !lJob
			IncProc()
		EndIf
	            
	    If DA0->DA0_ATIVO = "1"
			If (DA0->DA0_DATDE <= ddatabase .And. ddatabase <= DA0->DA0_DATATE) .Or. (DA0->DA0_DATDE <= ddatabase .And. DTOC(DA0->DA0_DATATE) = "  /  /  ")
				If Substr(Time(),1,5) >= DA0->DA0_HORADE .And. Substr(Time(),1,5) <= DA0->DA0_HORATE
					DbSelectArea("DA1")                     
					DbSetorder(1)
					DbGoTop()
					If DbSeek(DA0->DA0_FILIAL+DA0->DA0_CODTAB)
						While !EOF() .And. DA1->DA1_FILIAL+DA1->DA1_CODTAB = DA0->DA0_FILIAL+DA0->DA0_CODTAB
							If DA1->DA1_ATIVO = "1"
								
								DbSelectArea("SB0")
								DbSetOrder(1)
								DbGoTop()
								If DbSeek(DA1->DA1_FILIAL+DA1->DA1_CODPRO)
									RecLock("SB0",.F.)
								Else
									RecLock("SB0",.T.)		
								EndIf
								
								SB0->B0_CODTAB := DA1->DA1_CODTAB
								SB0->B0_FILIAL := DA1->DA1_FILIAL
								SB0->B0_COD    := DA1->DA1_CODPRO
								SB0->B0_PRV1   := Round(DA1->DA1_PRCVEN,2)
								
								MsUnLock("SB0")
								
								DbSelectArea("DA1")
								
							EndIf
								
							DbSkip()
								
						EndDo
						
					Endif
					                            
					DbSelectArea("DA0")
					
					RecLock("DA0", .F.)
   	                DA0->DA0_ATIVO := "2"
 	                MsUnLock("DA0")
 	                
					DbSkip()	       
					Loop

				EndIf
			EndIf
		Endif
		
		DbSkip()
				
	EndDo
Return