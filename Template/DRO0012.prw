#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³DROABCFarma³ Autor ³ Totvs                ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao da tabela de preco dos produtos fornecidos pela ³±±
±±³          ³ ABC Farma (http://www.abcfarma.org.br/)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Template Drogaria                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DROABCFarm()
Local oDlg
Local oBmt1
Local oBmt2
Local oBmt3
Local cPathArq := ""     // Caminho e arquivo 
Local cTipoArq := ""     // Tipo de Arquivo para o oBjeto 

If "CTREE" $ RealRDD()
	cPathArq := "\system\tabela.dtc" 
	cTipoArq := "|*.DTC|"
Else
	cPathArq := "\system\tabela.dbf"  
	cTipoArq :="|*.DBF|"
EndIf

Private cArqFonte  := PadR( cPathArq , 255 )
Private cTexto     := ""
Private cEnt		:= Chr( 13 ) + Chr( 10 )
Private oProcess

DEFINE MSDIALOG oDlg FROM 1,1 TO 110,335 TITLE "Importacao de Tabela de Precos" PIXEL
@ 12,10 SAY "Arquivo Fonte:"
@ 20,10 MSGET cArqFonte PICTURE "@!" SIZE 120,10 OF oDlg PIXEL
oBmt1 := SButton():New(20,130,14, {|| cArqFonte := cGetFile("Arquivos Fonte" + cTipoArq  ,"Escolha o arquivo Fonte.",0,"SERVIDOR",.T.) },,)

oBmt2 := SButton():New( 35, 095, 01, {|| ( oProcess:= MsNewProcess():New({|lEnd| UpdTabPrc()}),oProcess:Activate()), oDlg:End()},,)
oBmt3 := SButton():New( 35, 130, 02, {|| oDlg:End() },,)

ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ UpdTabPrc ³ Autor ³ Totvs                ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o preco de entrada/saida dos medicamentos.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Template Drogaria                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function UpdTabPrc()
Local aArea     := GetArea()
Local aStruct   := {}
Local aCampos   := {}
Local cCodBarra := ""
Local cCodPro   := ""
Local cCampoPCO := "MED_PCO1"		// Campo padrao das tabelas, ver explicacao abaixo
Local cCampoPAD := "MED_PCO" + AllTrim( Str( SuperGetMV( "MV_ICMPAD" ) ) ) 
Local cCampoPLA := "MED->MED_PLA" + AllTrim( Str( SuperGetMV( "MV_ICMPAD" ) ) )
Local nTotRegs  := 0
Local nRegs     := 0
Local lAppend   := .F.
Local lErro		:= .F.
Local cArqLog		:= ""
Local cFile		:= "" 				// Nome do arquivo, caso o usuario deseje salvar o log das operacoes
Local cMask		:= "Arquivos Texto (*.TXT) |*.txt|"
Local oMemo
Local oFont  
Local oDlg
Local lCenVenda	:= SuperGetMV( "MV_LJCNVDA" )
Local nValPrc		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo selecionado pelo usuario       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lErro := !ValidaArq( cArqFonte )
If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a tabela ABC Farma                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T.,, cArqFonte, "MED", .F., .F. ) 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa a barra de progresso o total de registros ³
	//³ na tabela ABC Farma                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbEval( {|x| nTotRegs++ },, {||MED->( !Eof() ) } )
	oProcess:SetRegua1( 2 )
	oProcess:SetRegua2( nTotRegs )

	// Protecao colocada, pois pelo que verifiquei com a Drogaria Bruno existem dois tipos de arquivos 
	// arquivo que vem com o campo MED_PCO1 e alguns que vem com a aliquota exemplo MED_PCO18
	// Nesse caso fizemos o tratamento para os dois campos , priorizando o PCO1 pq vimos que eh o mais comum
	If MED->(ColumnPos(cCampoPCO)) > 0
		cCampoPAD := ""
	ElseIf MED->(ColumnPos(cCampoPAD)) > 0 	
		cCampoPCO	:= ""
	Else
		cCampoPCO	:= ""
		cCampoPAD 	:= ""
	EndIf
	
	MED->( DbGoTop() )	
	While MED->( !Eof() )
		oProcess:SetRegua1( 2 )

	    nRegs++
		oProcess:IncRegua1( "Atualizando preco de saida" )
		oProcess:IncRegua2( "Importando " + StrZero( nRegs, 6 ) + "/" + StrZero( nTotRegs, 6 ) )

		cCodPro := ""
		If MED->MED_BARRA <> 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Localiza no SLK o codigo de barras conforme o DBF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodBarra := AllTrim( Str( MED->MED_BARRA ) )
	        
			DbSelectArea("SB1")
			DbSetOrder(5)
			If DbSeek( xFilial("SB1") + cCodBarra )
				cCodPro := SB1->B1_COD
			Else
				DbSelectArea("SLK")
				DbSetOrder(1)
				If DbSeek(xFilial( "SLK" ) + cCodBarra )
					cCodPro := SLK->LK_CODIGO
				EndIf
			Endif	
		EndIf
		If !Empty( cCodPro )
			DbSelectArea( "SB1" )
			DbSetOrder( 1 )
			If DbSeek( xFilial( "SB1" ) + cCodPro )
			
				nValPrc	:= 0	// Tratamento para pegar os dois precos , vide explicacao acima
				If !Empty(cCampoPCO)
					nValPrc := MED->(&cCampoPCO)
				ElseIf !Empty(cCampoPAD)
					nValPrc := MED->(&cCampoPAD)
				EndIf
				
				If 	nValPrc <> 0
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o preco de saida do medicamento ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea( "SB0" )
					DbSetOrder( 1 )
	
					lAppend := !DbSeek( xFilial( "SB0" ) + SB1->B1_COD )
					RecLock( "SB0", lAppend )
					REPLACE SB0->B0_FILIAL WITH xFilial( "SB0" )
					REPLACE SB0->B0_COD    WITH SB1->B1_COD
					REPLACE SB0->B0_PRV1   WITH nValPrc	
					SB0->(MsUnLock())
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Tabela de Preço				   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					If	lCenVenda .AND. !Empty( cCodPro )
						DbSelectArea("DA0")
						DA0->(DbSetOrder(2)) //DA0_FILIAL+DA0_ATIVO+DA0_DATDE+DA0_DATATE
						If DA0->(DbSeek(xFilial("DA0") + "1"))		
							While DA0->(!EOF()) .AND. (DA0_FILIAL == xFilial("DA0")) .AND. dDataBase >= DA0->DA0_DATDE .AND. (dDataBase <= DA0->DA0_DATATE .OR. EMPTY(DA0->DA0_DATATE)) .AND.;
							(SubStr(Time(),1,5) >= DA0->DA0_HORADE .AND. SubStr(Time(),1,5) <= DA0->DA0_HORATE)																	
								DbSelectArea( "DA1" )
								DA1->(DbSetOrder( 2 ))							
								If DA1->(DbSeek( xFilial( "DA1" ) + SB1->B1_COD ))
									While DA1->(!EOF()) .AND. DA1_FILIAL == xFilial( "DA1" ) .AND. DA1_CODPRO == SB1->B1_COD 
										RecLock( "DA1", .F. )
										REPLACE DA1->DA1_PRCVEN WITH nValPrc
										DA1->(MsUnLock())
										DA1->(DbSkip())				
									End
								EndIf																																													
								DA0->(DbSkip())					
							EndDo
						EndIf
					EndIf	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Localiza no SA5 todos os produtos para que ³
					//³ possamos encontrar a tab preco vigente do  ³
					//³ fornecedor.                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oProcess:IncRegua1( "Atualizando preco de entrada" )
					DbSelectArea( "SA5" )
					DbSetOrder( 3 ) // Produto+Fabricante+Loja
					If !DbSeek( xFilial( "SA5" ) + SB1->B1_COD )
						cTexto += "Nao exite amarracao do produto " + AllTrim( SB1->B1_COD ) + " com fornecedores!" + cEnt
						lErro := .T.
					EndIf
					
					While SA5->( !Eof() ) .AND. SA5->A5_FILIAL == xFilial( "SA5" ) .AND. SA5->A5_PRODUTO == SB1->B1_COD
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o preco de entrada do medicamento ³
						//³ conforme a tabela de preco vigente         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea( "AIA" )
						DbSetOrder( 1 ) // Fornecedor+Loja+TabPreco+CodProduto
						If DbSeek( xFilial( "AIA" ) + SA5->A5_FORNECE + SA5->A5_LOJA + SA5->A5_CODTAB )
							If DDATABASE <= AIA->AIA_DATATE
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza o preco de entrada do medicamento ³
								//³ conforme a tabela de preco vigente         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DbSelectArea( "AIB" )
								DbSetOrder( 2 ) // Fornecedor+Loja+TabPreco+CodProduto
								If DbSeek( xFilial( "AIB" ) + SA5->A5_FORNECE + SA5->A5_LOJA + SA5->A5_CODTAB + SB1->B1_COD )
									RecLock( "AIB", .F. )
									REPLACE AIB->AIB_PRCCOM WITH &cCampoPLA
									AIB->(MsUnLock())
								EndIf
							Else
								cTexto += "Tabela de Preco " + SA5->A5_CODTAB
								cTexto += " do fornecedor " + SA5->A5_FORNECE + "/" + SA5->A5_LOJA + " sem validade!"
								cTexto += cEnt
	
								lErro := .T.
							EndIf
						Else
							cTexto += "Tabela de Preco"
							cTexto += " nao encontrada para o fornecedor " + SA5->A5_FORNECE + "/" + SA5->A5_LOJA
							cTexto += cEnt
							
							lErro := .T.
						EndIf
	
						SA5->( DbSkip() )
					End
				EndIf	
			Else
				cTexto += "Produto nao cadastrado com o codigo: " + AllTrim( cCodPro ) + cEnt
				lErro := .T.
			EndIf
		Else
			cTexto += "Código de barras " + AllTrim( cCodBarra ) + " não cadastrado" + cEnt
			lErro := .T.        
	   	EndIf
		MED->( 	DbSkip() )
	End
	MED->( DbCloseArea() )
	RestArea( aArea )
EndIf

If lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta campo memo com log do processamento.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqLog := MemoWrite( CriaTrab( , .F. ) + ".LOG", "Log de Processamento" )
	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
	DEFINE MSDIALOG oDlg TITLE "Importacao Concluida!" From 3,0 to 340,417 PIXEL
	DEFINE SBUTTON  FROM 153,175 TYPE 01 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL

	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:bRClicked := {|| AllwaysTrue() }
	oMemo:oFont		:= oFont

	ACTIVATE MSDIALOG oDlg CENTER
EndIf   

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ValidaArq  ³ Autor ³ Totvs                ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consiste o arquivo informado pelo usuario.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValidaArq ( cArqFonte )                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Caminho exato do arquivo DBF                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Template Drogaria                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidaArq( cArqFonte )
Local lReturn    := .T.
Local cCampoAliq := "MED_PCO1"
Local cCampoPAD := "MED_PCO" + AllTrim( Str( SuperGetMV( "MV_ICMPAD" ) ) ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a  existencia do arquivo informado  pelo ³
//³ usuario                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cArqFonte )
	cTexto += "O arquivo fonte [" + RTrim( cArqFonte ) + "] nao existe!" + cEnt
	lReturn := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a tabela ABC Farma e verifica estrutura      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T.,, cArqFonte, "MED", .F., .F. ) 		
	
	If MED->(ColumnPos(cCampoAliq)) > 0
		If !( MED->(&cCampoAliq)  > 0 ) 
			cTexto += "Aliquota incorreta. Verifique se existe o campo MED_PCO1 na tabela ABC " + cEnt
			lReturn := .F.
		EndIf
	ElseIf MED->(ColumnPos(cCampoPAD)) > 0
		If !( MED->(&cCampoPAD)  > 0 ) 
			cTexto += "Aliquota incorreta. Verifique o parametro MV_ICMPAD!" + cEnt
			lReturn := .F.
		EndIf
	Else		
		Conout("Campo : "+cCampoAliq+" não está na tabela de importação." )
	EndIf	

	MED->( DbCloseArea() ) 
EndIf 

Return lReturn
