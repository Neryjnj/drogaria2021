#INCLUDE 'TOTVS.CH'

//�������������������������������Ŀ
//�Definicao de variavel em objeto�
//���������������������������������  
 
#XTRANSLATE bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

Static lUsaBaseTop := UsaBaseTop()

//�������Ŀ
//�DEFINES�
//���������
//OPERADORES
#DEFINE OPE_AND 	If(lUsaBaseTop, " AND "," .AND. ")
#DEFINE OPE_OR  	If(lUsaBaseTop, " OR " ," .OR. ")
#DEFINE OPE_IGUAL	If(lUsaBaseTop, " = "  ," == ")

//�����������������������������������Ŀ
//�Numero de caracteres dos operadores�
//�������������������������������������
#DEFINE TAM_AND  	Len(OPE_AND)
#DEFINE TAM_OR  	Len(OPE_OR)
#DEFINE TAM_IGUAL	Len(OPE_IGUAL)

//������Ŀ
//�Campos�
//��������
#DEFINE	 CAMPO_B1_CODFAB  If(lUsaBaseTop,"SB1.B1_CODFAB" ,"B1_CODFAB") 
#DEFINE	 CAMPO_B1_LOJA    If(lUsaBaseTop,"SB1.B1_LOJA"   ,"B1_LOJA")
#DEFINE	 CAMPO_B1_CODAPRE If(lUsaBaseTop,"SB1.B1_CODAPRE","B1_CODAPRE")
#DEFINE	 CAMPO_B1_CODCOTL If(lUsaBaseTop,"SB1.B1_CODCOTL","B1_CODCOTL")
#DEFINE CAMPO_B1_CODPRIN If(lUsaBaseTop,"SB1.B1_CODPRIN","B1_CODPRIN")
#DEFINE CAMPO_B1_GENERIC If(lUsaBaseTop,"SB1.B1_GENERIC","B1_GENERIC")
#DEFINE CAMPO_B1_ALTERNA If(lUsaBaseTop,"SB1.B1_ALTERNA","B1_ALTERNA")

/*���������������������������������������������������������������������������
���Programa  �DROCENTRAL�Autor  �Vendas Clientes     � Data � 23/01/08    ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela de filtro para a CENTRLA DE COMPRAS                    ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE - DROGARIA                                        ���
���������������������������������������������������������������������������*/
Template Function DRO0011()
//�Objeto para a criacao da tela principal
Local oDlg

//�������������������������������������������������������Ŀ
//� Parametros Devolvidos pela funcao  LocxGrid()         �
//���������������������������������������������������������
//���������������������������������������������������������������������������������������������������������Ŀ
//�1. aRet	-	Array contendo 6 arrays como descrito abaixo:												�
//�				[1] = Array com o aHeader                                                                   �
//�				[2] = Array contendo somente campos validos dos que foram passados                          �
//�				[3] = Array contendo Titulo dos campos validos                                              �
//�				[4] = Array contendo Tamanho dos campos validos												�
//�				[5] = Array co o conteudo das linhas (aCols)                                                �
//�				[6] = Array contendo os Recnos referentes a cada linha                                      �
//�����������������������������������������������������������������������������������������������������������

//���������������Ŀ
//�Principio ativo�
//�����������������
Local cSeekMHA    := '"' + xFilial("MHA") + '"'
Local cWhileMHA   := "!EOF() .AND. MHA_FILIAL == " + cSeekMHA
Local aPAtivo     := LocxGrid("MHA",cWhileMHA,,.T.,".F.",cSeekMHA,1,{"MHA_CODIGO","MHA_PATIVO"},)  
Local aTitPAtivo  := AClone(aPAtivo[3])
Local aContPAtivo := AClone(aPAtivo[5])
Local aTamCPAtivo := AClone(aPAtivo[4])
Local aHdrPAtivo  := AClone(aPAtivo[1]) 
Local oMarkPAtivo
Local lMarkPAtivo := .F.  
Local oPAtTWBrose   := NIL
Local oPAtTCheckBox := NIL

//��������������
//�Apresentacao�
//��������������
Local cSeekMHB  := '"' + xFilial("MHB") + '"'
Local cWhiMHBEL := "!EOF() .AND. MHB_FILIAL == " + cSeekMHB
Local aApre     := LocxGrid("MHB",cWhiMHBEL,,.T.,".F.",cSeekMHB,1,{"MHB_CODAPR","MHB_APRESE"},)  
Local aTitApre  := AClone(aApre[3])
Local aContApre := AClone(aApre[5])
Local aTamCApre := AClone(aApre[4])
Local aHdrApre  := AClone(aApre[1])  
Local oMarkApre
Local lMarkApre := .F.  
Local oAprTWBrose   := NIL
Local oAprTCheckBox := NIL      


//��������������
//�Fabricante  �
//��������������
Local cSeekSA2    := '"' + xFilial("SA2") + '"'
Local cWhileSA2   := "!EOF() .And. A2_FILIAL == " + cSeekSA2
Local aFabric     := LocxGrid("SA2",cWhileSA2,'(A2_FABRICA=="S" .Or. A2_FABRICA=="1")',.T.,".F.",cSeekSA2,2,{"A2_COD","A2_LOJA","A2_NOME"},)  //Fabricantes
Local aTitFabric  := AClone(aFabric[3])
Local aContFabric := AClone(aFabric[5])
Local aTamCFabric := AClone(aFabric[4])
Local aHdrFabric  := AClone(aFabric[1])
Local oMarkFabric
Local lMarkFabric := .F. 
Local oFabTWBrose   := NIL
Local oFabTCheckBox := NIL      


//��������������
//�Controle    �
//��������������
Local cSeekLEO      := '"' + xFilial("LEO") + '"'
Local cWhiMHBEO     := "!EOF() .And. LEO_FILIAL == " + cSeekLEO
Local aControle     := LocxGrid("LEO",cWhiMHBEO,,.T.,".F.",cSeekLEO,2,{"LEO_CODCON","LEO_CONDES"},)  //Controles
Local aTitControle  := AClone(aControle[3])
Local aContControle := AClone(aControle[5])
Local aTamCControle := AClone(aControle[4])
Local aHdrControle  := AClone(aControle[1])
Local oMarkControle
Local lMarkControle := .F.  
Local oContTWBrose   := NIL
Local oContTCheckBox := NIL      


//����������������������Ŀ
//�Texto para os CheckBox�
//������������������������
Local cTexto1		:= "Marcar Todos"						//Texto para check BOX

Local aRadOpcGen 	:= {}	//Array contendo tipo para o objeto radio para medicamento generico		
Local oGenTRadMenu	:= NIL
Local oGenRMenu  	:= NIL

Local aRadOpcAlt 	:=	{}	//Array contendo tipo para o objeto radio para medicamento alternativo
Local oAltTRadMenu	:= NIL
Local oAltRMenu		:= NIL

Local oCompTela	    := DroCCompTela():CompTela()		//Localizado no fonte DRO005	
Local oParTGroup    := NIL

Local lRet		 	 := .F.  
Local cWhereFab  	 := ""	//Clausula WHERE criada a partir da selecao dos fabricantes
Local cWhereApre     := ""	//Clausula WHERE criada a partir da selecao das apresentacoes
Local cWhereControle := ""	//Clausula WHERE criada a partir da selecao dos controles
Local cWherePAtivo 	 := ""	//Clausula WHERE criada a partir da selecao dos princios ativo
Local cWhereGen 	 := "" 	//Clausula WHERE criada a partir da selecao do Medicamento Generico
Local cWhereAlt 	 := ""	//Clausula WHERE criada a partir da selecao do Medicamento Altenativo
Local cWhere	 	 := ""	//Clausula WHERE criada a partir da selecao dos registro	

Private oListPAtivo
Private oListApre
Private oListFabric
Private oListControle

Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//�����������������������������������������������������������Ŀ
//� Tela da Central de Compras                                �
//�������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE "Central de Compras" FROM 1,1 TO 35,100

//��������������������
//�Box - Fabricante  �
//��������������������
oParTGroup := DROCParTGroup():ParTGroup( 005				, 005 , 089, 190,;
									     " Fabricantes     ", oDlg)	//Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)


oFabTWBrose := DROCParTWBrowse():ParTWBrose(	014        , 010          , 170       , 60			,;
							   			    	oDlg       , 'oListFabric', aHdrFabric, aTitFabric	,;
										   		aTamCFabric, aContFabric ) //Metodo CONSTRUTOR - DRO007.prw
oListFabric := oCompTela:CompTWBrose(oFabTWBrose)									     											


oFabTCheckBox := DROCParTCheckBox():ParTCheckBox( 076	  , 135 , oDlg, @lMarkFabric,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkFabric := oCompTela:CompTCheckBox(oFabTCheckBox)	

oMarkFabric:bLClicked := {|| aEval( oFabTWBrose:aConteudo , { |x,y| oFabTWBrose:aConteudo[y,1] := If(oFabTCheckBox:lMarcado ,1,-1)}) }

//��������������������
//�Box - Apresentacao�
//��������������������
oParTGroup := DROCParTGroup():ParTGroup( 092				, 005 , 176, 190,;
									     " Apresenta��o    ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oAprTWBrose := DROCParTWBrowse():ParTWBrose(	101        , 010          , 170     , 60		,;
							   			    oDlg       , 'oListApre'  , aHdrApre, aTitApre	,;
											aTamCApre  , aContApre ) //Metodo CONSTRUTOR - DRO007.prw 
oListApre := oCompTela:CompTWBrose(oAprTWBrose)									     											


oAprTCheckBox := DROCParTCheckBox():ParTCheckBox( 163	  , 135 , oDlg, @lMarkApre,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkApre := oCompTela:CompTCheckBox(oAprTCheckBox)	
oMarkApre:bLClicked := {|| aEval( oAprTWBrose:aConteudo , { |x,y| oAprTWBrose:aConteudo[y,1] := If(oAprTCheckBox:lMarcado ,1,-1)}) }

//��������������������
//�Box - Controle    �
//��������������������
oParTGroup := DROCParTGroup():ParTGroup( 005				, 200 , 089, 385,;
									     " Controles       ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oContTWBrose := DROCParTWBrowse():ParTWBrose(	014        , 205          , 170     , 60		,;
							   			    oDlg       , 'oListControle'  , aHdrControle, aTitControle	,;
											aTamCControle  , aContControle ) //Metodo CONSTRUTOR - DRO007.prw  
oListControle := oCompTela:CompTWBrose(oContTWBrose)									     											


oContTCheckBox := DROCParTCheckBox():ParTCheckBox( 76	  , 330 , oDlg, @lMarkControle,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkApre := oCompTela:CompTCheckBox(oContTCheckBox)	
oMarkApre:bLClicked := {|| aEval( oContTWBrose:aConteudo , { |x,y| oContTWBrose:aConteudo[y,1] := If(oContTCheckBox:lMarcado ,1,-1)}) }

//���������������������Ŀ
//�Box - Principio Ativo�
//�����������������������
oParTGroup := DROCParTGroup():ParTGroup( 092				, 200 , 176, 385,;
									     " Princ�pio Ativo ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oPAtTWBrose := DROCParTWBrowse():ParTWBrose(	101        , 205          , 170     , 60		,;
							   			    oDlg       , 'oListPAtivo'  , aHdrPAtivo, aTitPAtivo	,;
											aTamCPAtivo  , aContPAtivo ) //Metodo CONSTRUTOR - DRO007.prw   
oListPAtivo := oCompTela:CompTWBrose(oPAtTWBrose)									     											


oPAtTCheckBox := DROCParTCheckBox():ParTCheckBox( 163	  , 330 , oDlg, lMarkPAtivo,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw  

oMarkPAtivo := oCompTela:CompTCheckBox(oPAtTCheckBox)	
oMarkPAtivo:bLClicked := {|| aEval( oPAtTWBrose:aConteudo , { |x,y| oPAtTWBrose:aConteudo[y,1] := If(oPAtTCheckBox:lMarcado ,1,-1)}) }

//����������������������������Ŀ
//�Radio - Medicamento Generico�
//������������������������������
oParTGroup := DROCParTGroup():ParTGroup( 180					 , 005 , 220, 190,;
								   		  " Medicamento Gen�rico", oDlg) //Metodo CONSTRUTOR - DRO006.prw  
oCompTela:CompTGroup(oParTGroup)

aRadOpcGen 	 := {"Sim", "N�o", "Todos"}
oGenTRadMenu := DROCParTRadMenu():ParTRadMenu(188    , 010, oDlg, aRadOpcGen,;
							   			      1) //Metodo CONSTRUTOR - DRO009.prw  
						   			      
oCompTela:CompTRadMenu(oGenTRadMenu)
//�������������������������������Ŀ
//�Radio - Medicamento Alternativo�
//���������������������������������  
oParTGroup := DROCParTGroup():ParTGroup( 180						, 200 , 220, 385,;
								   		  " Medicamento Alternativo", oDlg) //Metodo CONSTRUTOR - DRO006.prw  
oCompTela:CompTGroup(oParTGroup)


aRadOpcAlt := {"Sim", "N�o", "Todos"}
oAltTRadMenu := DROCParTRadMenu():ParTRadMenu(188    , 205, oDlg, aRadOpcAlt,;
                                              1) //Metodo CONSTRUTOR - DRO009.prw  
oCompTela:CompTRadMenu(oAltTRadMenu)

//����������������������������Ŀ
//�Botoes de Confirma / Cancela�
//������������������������������
DEFINE SBUTTON FROM 233,325 TYPE 1 ACTION (lRet := .T., oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 233,355 TYPE 2 ACTION (lRet := .F., oDlg:End()) ENABLE OF oDlg


ACTIVATE MSDIALOG oDlg CENTER

If lRet
	//����������Ŀ
	//�Fabricante�
	//������������
	cWhereFab := CompWhere(oFabTWBrose:aConteudo, 1)	

	//������������Ŀ
	//�Apresentacao�
	//��������������
	cWhereApre := CompWhere(oAprTWBrose:aConteudo, 2)	
	
	//�����������
	//�Controles�
	//�����������
	cWhereControle := CompWhere(oContTWBrose:aConteudo, 3)	
	
	//���������������Ŀ
	//�Principio Ativo�
	//�����������������
	cWherePAtivo := CompWhere(oPAtTWBrose:aConteudo, 4) 
	
	//��������������������Ŀ
	//�Medicamento Generico�
	//����������������������
	cWhereGen := CompWhere(NIL, 5, oGenTRadMenu:nOpcoes) 		   
	
	//�����������������������Ŀ
	//�Medicamento Alternativo�
	//�������������������������
	cWhereAlt := CompWhere(NIL, 6, oAltTRadMenu:nOpcoes) 		   
		
	cWhere := If(cWhereFab 		<> "()", cWhereFab		+ OPE_AND,"")+;
	          If(cWhereApre 	<> "()", cWhereApre	  	+ OPE_AND,"")+;
	          If(cWhereControle <> "()", cWhereControle	+ OPE_AND,"")+;
	          If(cWherePAtivo 	<> "()", cWherePAtivo	+ OPE_AND,"")+;
	          If(cWhereGen 		<> "()", cWhereGen		+ OPE_AND,"")+;
	          If(cWhereAlt 		<> "()", cWhereAlt		+ OPE_AND,"")

	If cWhere <> ""
		cWhere := Left(cWhere, Len(cWhere) - TAM_AND)
	Else
		cWhere := "()"
	Endif
Else
	cWhere := "()"
Endif 

Return (cWhere)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CompWhere �Autor  �Vendas Clientes     � Data � 21/01/08    ���
�������������������������������������������������������������������������͹��
���Desc.     � Criacao da clausula WHERE baseado nas opcoes marcadas na   ���
���          � tela de parametros da Central de Compras                   ���
�������������������������������������������������������������������������͹��
���Parametros� ExpA1 - Array contendo informacoes de filtro               ���
���          � ExpN2 - Tipo de filtro a ser trabalhado                    ���
���          �         nTipo = 1 (Fabricante)                             ���
���          �         nTipo = 2 (Apresentacao)                           ���
���          �         nTipo = 3 (Controles)                              ���
���          �         nTipo = 4 (Principio Ativo)                        ���
���          �         nTipo = 5 (Medicamento Generico)                   ���
���          �         nTipo = 6 (Medicamento Alternativo)                ���
���          � ExpN3 - Opcao escolhida para Medicamento Generico e        ���
���          �         Medicamento Alternativo                            ���
���          �         nOpcRadio = 1 (Filtrar Medicamentos Generico/Alter ���
���          �         nOpcRadio = 2 (Nao Filtrar Medicamento Genric/Alter���
���          �         nOpcRadio = 3 Desconsiderar filtro para este campo ���
�������������������������������������������������������������������������͹��
���Retorno   � ExpC1 - Clausula WHERE montadacoes de filtro               ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE - DROGARIA                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CompWhere(aArray, nTipo, nOpcRadio)
Local cWhere 		:= ""		// Clausula WHERE a ser montada de acordo com o preenchimento da tela Central de Compras 
Local aContAux  	:= {}		// Array auxiliar para armazenar os registros marcados
Local nTamAContAux	:= 0		// Tamanho do array aContAux	
Local nFor      	:= 0		// Controle de loop	

DEFAULT aArray 		:= {} 
DEFAULT nTipo  		:= 0  
DEFAULT nOpcRadio  	:= 0  

//��������������������������������������������������������Ŀ
//�Verifica se a funcao esta sendo chamada a partir de     �
//�Medicamento Generico (5) ou Medicamento Alternartivo (6)�
//����������������������������������������������������������
If (nTipo <> 5 .AND. nTipo <> 6)
	AEval(aArray, {|x| If(x[1]==1,AtuArray(nTipo, @aContAux, x[2], x[3]),NIL)})
	nTamAContAux := Len(aContAux)
    cWhere := "("
	If nTamAContAux > 0
		For nFor := 1 to nTamAContAux
			If nTipo == 1		//Fabricante
				cWhere += CAMPO_B1_CODFAB + OPE_IGUAL + "'" + aContAux[nFor][1] + "'" + OPE_AND
				cWhere += CAMPO_B1_LOJA   + OPE_IGUAL + "'" + aContAux[nFor][2] + "'" 
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif	
			ElseIf nTipo == 2	//Apresentacao
				cWhere += CAMPO_B1_CODAPRE + OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			ElseIf nTipo == 3	//Controles
				cWhere += CAMPO_B1_CODCOTL + OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			ElseIf nTipo == 4	//Principio Ativo
				cWhere += CAMPO_B1_CODPRIN +  OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			Endif
		Next nFor
	Endif	
	cWhere += ")" 	
Else
	cWhere := "("
	If nTipo == 5	//Medicamento Generico
		If nOpcRadio == 1 	//Opcao SIM selecionada  
			cWhere += CAMPO_B1_GENERIC + OPE_IGUAL + "'S'" 
		ElseIf nOpcRadio == 2 //Opcao NAO selecionada
			cWhere += CAMPO_B1_GENERIC + OPE_IGUAL + "'N'" 
		Endif
	ElseIf nTipo == 6	//Medicamento Alternativo
		If nOpcRadio == 1 	//Opcao SIM selecionada  
			cWhere += CAMPO_B1_ALTERNA + OPE_IGUAL + "'1'" 
		ElseIf nOpcRadio == 2 //Opcao NAO selecionada
			cWhere += CAMPO_B1_ALTERNA + OPE_IGUAL + "'2'" 
		Endif	
	Endif
	cWhere += ")"	
EndIf

Return (cWhere)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuArray  �Autor  �Vendas Clientes     � Data � 21/01/08    ���
�������������������������������������������������������������������������͹��
���Desc.     � Preenche o array com os registros selecionados             ���
�������������������������������������������������������������������������͹��
���Parametros� ExpN1 - Tipo de filtro a ser trabalhado                    ���
���          �         nTipo = 1 (Fabricante)                             ���
���          �         nTipo = 2 (Apresentacao)                           ���
���          �         nTipo = 3 (Controles)                              ���
���          �         nTipo = 4 (Principio Ativo)                        ���
���          � ExpA2 - Array que ira' armazenar os registros selecionados ���
���          � ExpC3 - Codigo                                             ���
���          � ExpC4 - Loja (somente p/ filtro dos Fabricantes)           ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE - DROGARIA                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AtuArray(nTipo, aContAux, cCod, cLoj )

//������������������������������������������������������Ŀ
//�nTipo = 1 (Fabricante), significa que devera armazenar�
//�CODIGO DO FABRICANTE + LOJA                           �
//��������������������������������������������������������
If nTipo == 1 
	aAdd(aContAux,{cCod,cLoj})
Else
	aAdd(aContAux,{cCod})
Endif

Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UsaBaseTop�Autor  �Vendas Clientes     � Data � 21/01/08    ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica qual a base de dados e' utilizada, TOP ou DBF      ��� 
�������������������������������������������������������������������������͹��
���Retorno   �ExpL1  - Usa ou nao a base TOP                              ���
�������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras)                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function UsaBaseTop()
Local lUsaTOP := .F.		//Verifica se utiliza TOP

#IFDEF TOP 
	If TcSrvType() <> "AS/400"
		lUsaTOP := .T.
	EndIf
#ENDIF	

Return (lUsaTOP)