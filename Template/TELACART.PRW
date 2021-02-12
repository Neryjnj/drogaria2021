#include "Protheus.ch"

//-----------------------------------------------------------
/*/{Protheus.doc} TELACART()

@version 	P12
@since   	XX/XX/XXXX
@autor		varejo
/*/
//-----------------------------------------------------------
Template Function TELACART()
LOCAL nVal       := ""
LOCAL cData		 := ""		 		
LOCAL nTipCar    := 0 
LOCAL nOpd       := 0
LOCAL nContVld	 := 1	
Local nSel       
LOCAL ctDat_Venc := Space(8) 
LOCAL ctCgc_Cpf  := Space(11)
Local cCodCli    := ""
Local cLojCli    := ""
Local cSeekSA1   := ""
Local cWhileSA1  := ""
Local cRetCli    := ""
Local cMatricula := ""
LOCAL lRet		 := .F.
Local lRetCli    := .T.
LOCAL aArea      := GetArea()
Local aAreaSA1   := {}
Local aRetCli    := {} 
Local aCabCli	 := {}
Local aLinCli	 := {}
Local aTamCli	 := {}
Local aCpoCli	 := {}
Local lCPFDuplic := .F.  //Controle se existem dois registros com o mesmo CPF no SA1 para os casos de convenio(particular e conveniado)
Local cTitTela   := ""
Local nRecno     := 0

PRIVATE ctCartao := Space(16)
Private	oDlg, oLbx, oChk, oLbxCli, oDlgCli
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.

IF SuperGetMv("MV_PLSATIV",.F.,.F.) 
	cMatricula := Space(TamSX3("BA1_CODINT")[1]+TamSX3("BA1_CODEMP")[1]+TamSX3("BA1_MATRIC")[1]+;
						 TamSX3("BA1_TIPREG")[1]+TamSX3("BA1_DIGITO")[1])
Else
	cMatricula := Space(TamSX3("A1_MATRICU")[1])
Endif
                     
DEFINE MSDIALOG oDlg TITLE "Tipo de Cartão" FROM 13,21 TO 18,78 OF GetWNDDefault()
	@ 10,005 BUTTON "Não Magnético"	SIZE 50,15 OF oDlg PIXEL ACTION ( nTipCar:=2,oDlg:End() )
	@ 10,060 BUTTON "CPF"	    	SIZE 50,15 OF oDlg PIXEL ACTION ( nTipCar:=3,oDlg:End() )
	@ 10,115 BUTTON "Matrícula"		SIZE 50,15 OF oDlg PIXEL ACTION ( nTipCar:=5,oDlg:End() )
	@ 10,170 BUTTON "Abandona"		SIZE 50,15 OF oDlg PIXEL ACTION ( nTipCar:=4,oDlg:End() )
ACTIVATE MSDIALOG oDlg CENTERED

IF (nTipCar == 2)
	// Se tipo de cartao = nao magnetico, coletar o numero
	nOpd := 3
	DEFINE MSDIALOG oDlg TITLE "Dados do Cartão" FROM 13,21 TO 21,60 OF GetWNDDefault()
	@ .074,.1 TO 4,19
	@ 06,12 SAY		"Informe o número do cartão:"	SIZE 130,10 OF oDlg PIXEL
	@ 06,88 MSGET	ctCartao						SIZE 055,10 OF oDLG PIXEL PICTURE "9999999999999999" VALID VldGetCartao(nContVld) 
	@ 18,12 SAY		"Informe a validade:" 			SIZE 130, 10 OF oDlg PIXEL
	@ 18,88 MSGET	ctDat_Venc						SIZE 024,10 OF oDlg PIXEL PICTURE "@R 99/99" VALID L010ValidData( ctDat_Venc )
	DEFINE SBUTTON FROM 35,090 TYPE  1 PIXEL ACTION ( nOpd:=1,oDlg:End() ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 35,120 TYPE  2 PIXEL ACTION ( nOpd:=3,oDlg:End() ) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	
	IF nOpd == 1 // se o botao Ok foi clicado
		MA6->(dbSetOrder(1))
		IF !MA6->(dbSeek(xFilial("MA6") + ctCartao))
			Msgalert("Não existe nenhum cliente relacionada a este número de cartão.")
			lRet := .F.
		ELSE
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1") + MA6->MA6_CODCLI + MA6->MA6_LOJA))
			//cData := Left(DTOC(SA1->A1_VENCLC),2)+Rigth(DTOC(SA1->A1_VENCLC),2)
			nVal := DTOS(SA1->A1_VENCLC)//Converte a data para string
			cData := SUBSTR(nVal,5,2)+SUBSTR(nVal,3,2) //variavel para armazenar mes + ano
			IF (cData == ALLTRIM(ctDat_Venc))//verifica se a data digitada eh a mesma data que esta cadastrado no cadastro de cliente 
				nRecno := SA1->(Recno())
				lRet := .T.
			ELSE
				Aviso( "Atenção", "Data de validade do Cartão inválida! " +CHR(13)+;
								"Verifique o preenchimento do campo Venc. Lim. Cre(A1_VENCLC)", {"&Ok"})
				lRet := .F.	
			ENDIF
		ENDIF
	ENDIF
	
ELSEIF (nTipCar == 3) 
	// Obtém o número do Cartão, a partir do CPF
	nOpd := 2
	DEFINE MSDIALOG oDlg TITLE "Consulta do cartão" FROM 13,21 TO 20,64 OF GetWNDDefault()
	@ 06,12 SAY		"CPF para consulta:"	SIZE 130,10 OF oDlg PIXEL
	@ 06,88 MSGET	ctCgc_Cpf SIZE 055,10 OF oDLG PIXEL PICTURE "@R 999.999.999-99" VALID !EMPTY(ctCgc_Cpf)
	DEFINE SBUTTON FROM 35,090 TYPE 1 PIXEL ACTION ( nOpd:=1,oDlg:End() ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 35,120 TYPE 2 PIXEL ACTION ( nOpd:=2,oDlg:End() ) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpd == 1
		SA1->(dbSetOrder(3))
		IF !SA1->(dbSeek(xFilial("SA1") + ctCgc_Cpf))
			MsgAlert("Não existe nenhum cliente relacionado a este número de CPF.")
			lRet := .F.
		ELSE
           cCodCli    := SA1->A1_COD
           cLojCli    := SA1->A1_LOJA    
           ctCgc_Cpf  := PadR(ctCgc_Cpf,TamSX3("A1_CGC")[1])
           cSeekSA1   := '"' + xFilial("SA1")+ ctCgc_Cpf + '"'   
           cWhileSA1  := "!EOF() .And. A1_FILIAL+A1_CGC==" + cSeekSA1   
           aAreaSA1   := SA1->(GetArea())
           lCPFDuplic := .F.
           DbSelectArea("SA1")
           DbSetOrder(3) 
           //Verifica se existe mais de um cliente com o mesmo CPF
           While !Eof() .And. SA1->A1_FILIAL+SA1->A1_CGC == xFilial("SA1")+ctCgc_Cpf .And. !lCPFDuplic
   
              If SA1->A1_COD+SA1->A1_LOJA == cCodCli+cLojCli
                 DbSkip()
                 Loop
              EndIf   
      
              lCPFDuplic := .T. 
           End
           SA1->(RestArea(aAreaSA1))
           //Existe mais de um cliente com o mesmo CPF(particular e conveniado)
           If lCPFDuplic
		      DEFINE MSDIALOG oDlgCli TITLE "Clientes" FROM 5,30 TO 25,100

		      aRetCli	:= LocxGrid("SA1",cWhileSA1,,.T.,".F.",cSeekSA1,3,{"A1_NOME","A1_COD","A1_LOJA","A1_MATRICU"},)      
		      aCabCli	:= AClone(aRetCli[3])
		      aLinCli	:= AClone(aRetCli[5])
		      aTamCli	:= AClone(aRetCli[4])
	          aCpoCli	:= AClone(aRetCli[1])
		
		      oLbxCli := TwBrowse():New(030,000,000,000,,aCabCli,aTamCli,oDlgCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		      oLbxCli:nHeight	:= (__DlgHeight(oDlgCli)*2) - 8
		      oLbxCli:nWidth		:= __DlgWidth(oDlgCli)*2
		      oLbxCli:lColDrag	:= .T.
		      oLbxCli:nFreeze	:= 1
		      oLbxCli:SetArray(aLinCli)
		      oLbxCli:bLine		:= LocxBLin('oLbxCli',aCpoCli,.T.)
		      oLbxCli:bLDblClick	:={ || ChgMarkLb(oLbxCli,aLinCli,{|| .T. },.F.) }

		      ACTIVATE MSDIALOG oDlgCli ON INIT EnchoiceBar(oDlgCli,{|| lRetCli := .T.,oDlgCli:End()},{|| lRetCli := .F.,oDlgCli:End()},,)		   
		
              If lRetCli
                 //Posiciona no cliente selecionado pelo Caixa
	             aEval( aLinCli, { |x,y| If( aLinCli[y,1] == 1, cRetCli := (aLinCli[y,3]+aLinCli[y,4]), ) } )
	             Posicione("SA1",1,xFilial("SA1")+cRetCli,"A1_COD+A1_LOJA")
	             //Variaveis Private do programa FRTA010A, que armazena o codigo do cliente caso encontre duas ocorrencias de CPF no SA1
	             //Somente atribui as variaveis se o CPF estiver duplicado
	             M->LQ_CLIENTE   := SA1->A1_COD
	             M->LQ_LOJA      := SA1->A1_LOJA				   
	             M->LQ_NOMCLI    := SA1->A1_NOME
	             M->LQ_TIPOCLI   := SA1->A1_TIPO	             
              EndIf		
           EndIf
           If lRetCli
		      nRecno := SA1->(Recno())
		      SA1->(dbSetOrder(1))  //Volta o indice para o padrao por causa da validacao do x3_valid		      
		      lRet := .T.
	           M->LQ_CLIENTE   := SA1->A1_COD
	           M->LQ_LOJA      := SA1->A1_LOJA				   
	           M->LQ_NOMCLI    := SA1->A1_NOME
	           M->LQ_TIPOCLI   := SA1->A1_TIPO	             
		   EndIf   
		ENDIF
	ENDIF	
ElseIf (nTipCar == 5)	//Matricula

   If SuperGetMv("MV_PLSATIV",.F.,.F.) 
   		cTitTela:= "Consulta Beneficiário Plano de Saúde"
   Else
		cTitTela:= "Consulta do conveniado"
   Endif 	
   
   DEFINE MSDIALOG oDlg TITLE  cTitTela FROM 13,21 TO 20,64 OF GetWNDDefault()
   		
   		@ 06,12 SAY		"Matrícula para consulta:"	SIZE 130,10 OF oDlg PIXEL 
	   
	   If SuperGetMv("MV_PLSATIV",.F.,.F.) 
	    	@ 06,88 MSGET	cMatricula SIZE 062,10 OF oDlg PIXEL PICTURE "@!" F3 "BY2PLS" VALID !Empty(cMatricula)
	   Else
	    	@ 06,88 MSGET	cMatricula SIZE 055,10 OF oDlg PIXEL PICTURE "@!" VALID !Empty(cMatricula)
	   Endif
	   DEFINE SBUTTON FROM 35,090 TYPE 1 PIXEL ACTION ( IIf(T_DROPesqConv(cMatricula),(nSel:=1,oDlg:End()),NIL) ) ENABLE OF oDlg
	   DEFINE SBUTTON FROM 35,120 TYPE 2 PIXEL ACTION ( nSel:=2,oDlg:End() ) ENABLE OF oDlg
   
   ACTIVATE MSDIALOG oDlg CENTERED
   
   If nSel == 1
   		If SuperGetMv("MV_PLSATIV",.F.,.F.) 
   			cCodCli	:= A1_COD
   			cLoja   := A1_LOJA
   	   		cSeekSA1   := '"' + xFilial("SA1")+cCodCli+cLoja + '"'   
        	cWhileSA1  :=  "!EOF() .And. A1_FILIAL+A1_COD+A1_LOJA==" + cSeekSA1  
        Else
	        cSeekSA1   := '"' + xFilial("SA1")+ cMatricula + '"'   
	        cWhileSA1  :=  "!EOF() .And. A1_FILIAL+A1_MATRICU==" + cSeekSA1
        Endif       
        
		DEFINE MSDIALOG oDlgCli TITLE "Conveniados" FROM 5,30 TO 25,100   

		   aRetCli	:= LocxGrid("SA1",cWhileSA1,,.T.,".F.",cSeekSA1,IIf(SuperGetMv("MV_PLSATIV",.F.,.F.),1,"SA1DRO1"),{"A1_NOME","A1_COD","A1_LOJA"},)      
	 	   aCabCli	:= AClone(aRetCli[3])
		   aLinCli	:= AClone(aRetCli[5])
		   aTamCli	:= AClone(aRetCli[4])
		   aCpoCli	:= AClone(aRetCli[1]) 		   
		   oLbxCli := TwBrowse():New(030,000,000,000,,aCabCli,aTamCli,oDlgCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		   oLbxCli:nHeight	:= (__DlgHeight(oDlgCli)*2) - 8
		   oLbxCli:nWidth		:= __DlgWidth(oDlgCli)*2
		   oLbxCli:lColDrag	:= .T.
		   oLbxCli:nFreeze	:= 1
		   oLbxCli:SetArray(aLinCli)
		   oLbxCli:bLine		:= LocxBLin('oLbxCli',aCpoCli,.T.)
		   oLbxCli:bLDblClick	:={ || ChgMarkLb(oLbxCli,aLinCli,{|| .T. },.F.) }

		ACTIVATE MSDIALOG oDlgCli ON INIT EnchoiceBar(oDlgCli,{|| lRet := .T.,oDlgCli:End()},{|| lRet := .F.,oDlgCli:End()},,)		   
		
        If lRet
           If SuperGetMv("MV_PLSATIV",.F.,.F.) .AND. SLQ->(ColumnPos("LQ_MATRIC")) >0
	       		M->LQ_MATRIC   := cMatricula 
	       Endif
           //Posiciona no cliente selecionado pelo Caixa
	       aEval( aLinCli, { |x,y| If( aLinCli[y,1] == 1, cRetCli := (aLinCli[y,3]+aLinCli[y,4]), ) } )
	       Posicione("SA1",1,xFilial("SA1")+cRetCli,"A1_COD+A1_LOJA")
	       nRecno := SA1->(Recno())
        EndIf		
   EndIf
ENDIF

RestArea(aArea)

SA1->(DbGoTo(nRecno))

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} VldGetCartao()

@version 	P12
@since   	XX/XX/XXXX
@autor		varejo
/*/
//-----------------------------------------------------------
Static Function VldGetCartao(nContVld)
Local lRet := .F.

If Len(Alltrim(ctCartao)) < 16 .And. !Empty(ctCartao) 
	lRet := .F.
	nContVld := 1
Else
	If Len(Alltrim(ctCartao)) == 16 .And. nContVld == 1
		lRet := .T. 
		nContVld++
	Else
		lRet := .F. 
		nContVld := 1
	Endif
Endif

Return lRet