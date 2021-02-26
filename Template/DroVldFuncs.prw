#INCLUDE "PROTHEUS.CH"
#INCLUDE "DroVldFuncs.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "AUTODEF.CH"

#DEFINE CTRL Chr(13)+Chr(10)		//Pula linha     

// Indices do Array aANVISA
#DEFINE NOME					 1
#DEFINE TIPOID			   		 2
#DEFINE NUMID					 3
#DEFINE ORGEXP					 4
#DEFINE UFEMIS					 5
#DEFINE RECEITA					 6
#DEFINE TPRECEITA		   		 7
#DEFINE TPUSO			   		 8
#DEFINE DATRECEITA				 9
#DEFINE MEDICO					10
#DEFINE CRM						11
#DEFINE CONPROF		   			12
#DEFINE UFCONS		   			13
#DEFINE LOTEPROD	   			14
#DEFINE PRODUTO		   			15
#DEFINE QTDEPROD	   			16 
#DEFINE NUMDOC  	   			17
#DEFINE SERIE   	   			18
#DEFINE UM		   	   			19 
#DEFINE DESCPRO	   	   			20 
#DEFINE IDANVISA  	   			21
#DEFINE NUMORC		   			22     
#DEFINE REGMS		   			23   
#DEFINE ENDERECO	   			24   
#DEFINE NPACIENTE               25
#DEFINE CLASSTERAP   			26   
#DEFINE USOPROLONG           	27
#DEFINE IDADEP					28 
#DEFINE UNIDAP					29
#DEFINE SEXOPA	 				30
#DEFINE CIDPA	 				31
#DEFINE QUANTP					32

//������������������������������������������������������Ŀ
//�o DEFINE 'TAMANVISA' deve conter o mesmo numero       �
//�de campos do array aANVISA.                           �
//�Caso seja criado mais algum campo, o TAMANVISA tambem �
//�devera' ser alterado                                  �
//��������������������������������������������������������
#DEFINE TAMANVISA  	   			32
#DEFINE TAMAUXANVISA   			32

Static aANVISA 			:= {}								//Array que armazena os Logs da ANVISA
Static aAuxANVISA		:= {}								//Array Auxiliar que armazena os Logs da ANVISA
Static lInformouLote	:= .F.								//Verifica se deve ou nao informar a tela de lote.
Static lPressAtalho		:= .F.								//Verifica se a tela da ANVISA foi acionada via teclas de Atalho
Static cCaixaSup		:= Space(25)						// usuario superior que autorizou a operacao
Static nDiasRev 		:= SuperGetMv("MV_DROREV", Nil, 7)	//Determina o numero de dias que sera possivel realizar ajuste no livro                                
Static aLK9Usr			:= {}
Static aAuxLK9Usr		:= {}

//��������������������������������������������������Ŀ
//�Programa que contem funcoes genericas que sao     �
//�usadas no template Drogaria                       �
//�Tambem contem funcoes que sao chamada a partir da �
//�coluna X3_VALID                                   �
//����������������������������������������������������
/*���������������������������������������������������������������������������
���Programa  �DroVldEmp �Autor  �Vendas Clientes     � Data �  JAN/05     ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o codigo digitado nos campos 				  ���
���          � A1_EMPCONV e A1_LOJCONV sao relacionado a uma			  ���
���          � Empresa de Convenio.						 				  ���
���          � Esta verificacao eh realizada quando estamos cadastrando   ���
���          � um cliente do tipo "Conveniado".					   		  ���
���������������������������������������������������������������������������*/                                                                                 
Template Function DroVldEmp( cCodEmp, cCodLojaE )

Local lRet     := .T.    
Local lEmp     := .T.
Local cText1   := STR0001+;  //'Empresa de Conv�nio n�o existe.'
                  STR0002+; //'Favor verifique os seguintes campos:'
                  STR0003   //'Empresa Conv  e/ou  Loja emp con.'
Local cText2   := STR0004+; //'O C�digo do Cliente e C�digo da Loja  colocados  n�o s�o referentes � uma Empresa de Conv�nio.'
				  STR0005                	 //'Favor corrigi-los.'

DEFAULT cCodEmp     := M->A1_EMPCONV
DEFAULT cCodLojaE   := M->A1_LOJCONV

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

lEmp   := !Empty(cCodEmp) .AND. !Empty(cCodLojaE) 

If lEmp // verifica se os campo Empresa Conv. e Loja emp com estao preenchidos 
	If SA1->(!MsSeek(xFilial("SA1")+cCodEmp+cCodLojaE))// verifica se o codigo do fornecedor + codigo da loja existem em SA2
		MsgAlert(cText1)
		lRet := .F.
	Else
		If SA1->A1_TPCONVE <> "4"//caso codigo da Empresa + codigo da Loja da Emresa existam,verifica se a opcao A1_TPCONVE <> "4" 
			MsgAlert(cText2)
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroVLDAPRE�Autor  �Vendas Clientes     � Data �  JUL/05     ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o Codigo da apresentacao digitado                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Template Function DroVldApre( cCodApre )
Local lRet		:= .T.    
Local cText1	:= STR0006 //'N�o existe nenhum cadastro de Apresenta��o relacionado a este c�digo.'
Local cText2	:= STR0007 //'Favor verificar o campo Grupo localizado na pasta Cadastrais'
Local aAreaMHB	:= {}
Local cPesq		:= "" 

/*verificamos se o sistema possui a licenca de          
Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DbSelectArea("MHB")
aAreaMHB := MHB->(GetArea())//coloca MHB como area atual

cPesq := PadR(AllTrim(cCodApre),TamSx3("MHB_CODAPR")[1])

If !MHB->(DbSeek(xFilial("MHB")+cPesq))
	MsgAlert(cText1)
	lRet := .F.   
Else
	If SubStr(AllTrim(M->B1_GRUPO),1,2) <> SubStr(AllTrim(MHB->MHB_GRUPO),1,2)
		MsgInfo(cText2)
   		lRet := .F.
   	Endif
Endif	

MHB->(RestArea(aAreaMHB))

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroVldFab �Autor  �Vendas Clientes     � Data �  JUL/05     ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do codigo do 'Fabricante' 						  ���
���������������������������������������������������������������������������*/
Template Function DroVldFab( cCodFab, cCodLoja, nChamada )
Local lRet     := .T.    
Local lFabric  := .T.
Local cText1   := STR0008+;  //'Fabricante n�o existe.                               '
                  STR0009    //'Verifique o C�digo do Fabricante e/ou Codigo da  Loja. '
Local cText2   := STR0010+;  //'O C�digo do Fabricante e C�digo da Loja  colocados s�o referentes a um Fornecedor.'
				  STR0005    //'Favor corrigi-los.'
Local aAreaSa2 := {}
Local nPosCod  := 0
Local nPosLoja := 0

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

If nChamada = 1	//funcao chamada a partir dos campos da tabela SB1            
	DEFAULT cCodFab    := M->B1_CODFAB
	DEFAULT cCodLoja   := M->B1_LOJA 
Elseif nChamada = 2//funcao chamada a partir dos campos da tabela AIB
	nPosCod  := Ascan(aHeader,{|x| AllTrim(x[2]) == "AIB_CODFAB"})
	nPosLoja := Ascan(aHeader,{|x| AllTrim(x[2]) == "AIB_LOJAF"})         
	
	DEFAULT cCodFab    := aCols[n,nPosCod]
	DEFAULT cCodLoja   := aCols[n,nPosLoja]
Endif

lFabric   := !Empty(cCodFab) .AND. !Empty(cCodLoja) 

If lFabric // verifica se os campo Fabricante e Loja estao preenchidos 
	aAreaSA2 := SA2->(GetArea())//coloca SA2 como area atual
	DbSetOrder(1)
	If SA2->(!MsSeek(xFilial("SA2")+cCodFab+cCodLoja))// verifica se o codigo do fornecedor + codigo da loja existem em SA2
		MsgAlert(cText1)
		lRet := .F.
	Else
		If SA2->A2_FABRICA = "N"//caso codigo do fabricante + codigo da loja existam,verifica se a opcao A2_FABRICA = "N" 
			MsgAlert(cText2)
			lRet := .F.
		Endif
	Endif
Else
	MsgAlert("Este campo deve ser preenchido com um fabricante/fornecedor v�lido." + CHR(13) + CHR(13) +;
			"Verifique se o campo Fabricante(A2_FABRICA) do cadastro de Fornecedor est� com 'S-Sim' ")
Endif

//Restaurando as Areas
If !Empty(aAreaSA2)
	SA2->(RestArea(aAreaSA2))
EndIf     

Return lRet

/*���������������������������������������������������������������������������
���Programa  �VldCampo  �Autor  �Vendas Clientes     � Data �  NOV/05     ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina disparada atraves dos campos                        ���
���          � A1_LAYOUTC,A1_LAYIMP,A2_LAYOUTE,A2_LAYOUTR                 ��� 
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Template Function DroVldCampo( nOpd, cConteudo ) 
Local lRet := .T.

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

//�����������������������������������������Ŀ
//�Verifica os campos da empresa de convenio�
//�������������������������������������������
If nOpd = 1//Validacao no campo A1_LAYOUTC
	If (Substr(cConteudo,At(".",cConteudo),4) <> ".cle" .AND. Substr(cConteudo,At(".",cConteudo),4) <> ".CLE")
		MsgStop(STR0011+ CTRL + ; //"O Conte�do deste campo deve conter extens�o '.cle' "
				STR0012+ CTRL + ; //"Exemplo:"
				STR0013) //"TESTE.cle"
		lRet := .F.
	Endif
Elseif nOpd = 2//Validacao no campo A1_LAYIMP
	If (Substr(cConteudo,At(".",cConteudo),4) <> ".clr" .AND. Substr(cConteudo,At(".",cConteudo),4) <> ".CLR")
		MsgStop(STR0014+ CTRL + ; //"O Conte�do deste campo deve conter extens�o '.clr' "
				STR0012 + CTRL + ; //"Exemplo:"
				STR0015) //"TESTE.clr"
		lRet := .F.
	Endif
//��������������������������������Ŀ
//�verifica os campos do fornecedor�
//����������������������������������
Elseif nOpd = 3//Validacao no campo A2_LAYOUTE
	If (Substr(cConteudo,At(".",cConteudo),4) <> ".env" .AND. Substr(cConteudo,At(".",cConteudo),4) <> ".ENV")
		MsgStop(STR0016+ CTRL + ; //"O Conte�do deste campo deve conter extens�o '.env' "
				STR0012+ CTRL + ; //"Exemplo:"
				STR0017) //"TESTE.env"
		lRet := .F.
	Endif
Elseif nOpd = 4//Validacao no campo A1_LAYOUTR
	If (Substr(cConteudo,At(".",cConteudo),4) <> ".rec" .AND. Substr(cConteudo,At(".",cConteudo),4) <> ".REC")
		MsgStop(STR0018+ CTRL + ; //"O Conte�do deste campo deve conter extens�o '.rec' "
				STR0012 + CTRL + ; //"Exemplo:"
				STR0019) //"TESTE.rec"
		lRet := .F.
	Endif
Endif	                                   

Return lRet 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DroCriarTe�Autor  �Vendas Clientes     � Data �  10/25/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela na qual o usuario ira selecionar a empresa de convenio ���
���          �ou Fornecedor.											  ���
���          �Apos selecionada a empresa ou fornecedor,					  ���
���          �aparecera o nome do Arquivo de  Envio ou Recebimento.	  	  ���
���          � 															  ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function DroCriarTe( nVar, cArq, cModulo )

// Variaveis Locais da Funcao
Local cCod	 	   := "" // codigo 
Local cLoja	 	   := "" // loja 
Local cArqEnv	   := "" // arquivo de ENVIO
Local cArqRec	   := "" // arquivo de RECEBIMENTO
Local cTitulo	   := "" // titulo da tela 
Local cInform1 	   := "" // 
Local cInform2     := "" //
Local cF3		   := "" // consulta a ser usada	
Local cLabel1      := "" //
Local cLabel2      := "" //
Local cMsg		   := "" // mensagem de confirmacao dos dados
Local _oCod
Local _oLoja
Local _oArqEnv
Local _oArqRec 
Local nOpd
Local cStartPath := GetSrvProfString("STARTPATH","")
Local cReturn 	:= ""
Local cBarra     := If(GetRemoteType() == REMOTE_LINUX ,"/","\") //Complementa a Barra do StarPath Caso nao Tenha

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
If !Substr(cArq,Len(AllTrim(cArq)),1) $ "/\" 
	cArq := cArq + cBarra
EndIf 

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

If cModulo = "L"//funcao chamada pelo modulo SIGALOJA
	cCod	 	 := Space(TamSX3("A1_COD")[1])
	cLoja	 	 := Space(TamSX3("A1_LOJA")[1])
 	cArqEnv	 	 := Space(TamSX3("A1_LAYOUTC")[1])
	cArqRec	 	 := Space(TamSX3("A1_LAYIMP")[1])
	cTitulo 	 := STR0020  //"Layout Empresa de Conv�nio"
	cInform1 	 := STR0021 //"Selecione uma empresa para"
	cInform2 	 := STR0022 //"posicionar nos Layouts."
	cF3 		 := "CNV"
	cLabel1 	 := STR0023   //"C�d. Empresa"
	cLabel2 	 := STR0024 //"Loja"
	cMsg 		 := STR0025 //"Confirma os Dados da Empresa de Conv�nio?"
Elseif cModulo = "C"//funcao chamada pelo modulo COMPRAS     
	cCod	 	 := Space(TamSX3("A2_COD")[1])
	cLoja	 	 := Space(TamSX3("A2_LOJA")[1])
 	cArqEnv	 	 := Space(TamSX3("A2_LAYOUTE")[1])
	cArqRec	 	 := Space(TamSX3("A2_LAYOUTR")[1])
	cTitulo 	 := STR0026 //"Layout Pedido de Compras"
	cInform1 	 := STR0027 //"Selecione um fornecedor para"
	cInform2 	 := STR0022	 //"posicionar nos Layouts."
	cF3 		 := "SA2"	
	cLabel1 	 := STR0028   //"C�d. Fornec."
	cLabel2 	 := STR0024	 //"Loja"
	cMsg 	   	 := STR0029	 //"Confirma os Dados do Fornecedor?"
Endif

DEFINE MSDIALOG _oDlg TITLE OemtoAnsi(cTitulo) FROM 183,242 TO 340,524 PIXEL

	// Cria Componentes Padroes do Sistema
	@ 003,005 Say cInform1 Size 096,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 010,005 Say cInform2 Size 062,009 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 023,040 MsGet _oCod  Var cCod F3 cF3 Size 050,009 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 023,118 MsGet _oLoja Var cLoja Valid(T_ValidaCampo(cCod,cLoja,nVar,@cArqEnv,@cArqRec,cModulo)) Size 018,009 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 027,005 Say cLabel1 Size 035,008 COLOR CLR_BLACK PIXEL OF _oDlg
	@ 027,103 Say cLabel2 Size 012,008 COLOR CLR_BLACK PIXEL OF _oDlg
	If nVar = 1 //Arquivo de Envio
		@ 040,076 MsGet _oArqEnv Var cArqEnv WHEN .F. Size 060,009 COLOR CLR_BLACK PIXEL OF _oDlg
		@ 044,005 Say STR0030 Size 052,008 COLOR CLR_BLACK PIXEL OF _oDlg  //"Arquivo Layout Envio"
	Elseif nVar = 2 //Arquivo de Recebimento
		@ 040,076 MsGet _oArqRec Var cArqRec  WHEN .F. Size 060,009 COLOR CLR_BLACK PIXEL OF _oDlg
		@ 044,005 Say STR0031 Size 070,008 COLOR CLR_BLACK PIXEL OF _oDlg  //"Arquivo Layout Recebimento"
	Endif
	@ 064,100 Button OemtoAnsi(STR0032) Size 037,012 OF _oDlg PIXEL Action(nOpd := 1,_oDlg:End())	 //"OK"
ACTIVATE MSDIALOG _oDlg CENTERED 
If nOpd = 1
	If MsgYesNo(cMsg)
		If nVar == 1 //Arquivo de Envio
			cArq := Lower(cStartPath+cArqEnv+Space(23) )         
 		Elseif nVar == 2 //Arquivo de Recebimento
			cArq := Lower(cStartPath+cArqRec+Space(23)	)
		Endif
	Endif
Endif

Return(.T.)
/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������ͻ��
���Programa  �ValidaCampo �Autor  �Vendas Clientes     			  � Data �  10/26/05   ���
��������������������������������������������������������������������������������������͹��
���Desc.     � Faz a validacao dos dados digitados pelo usuario            			   ���
��������������������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                            		   ���
��������������������������������������������������������������������������������������͹��
���Parametros� cCod     -- Codigo (Empresa ou Fornecedor, depende do parametro cModulo)���
���			 � cLoja    -- Loja   (Empresa ou Fornecedor, depende do parametro cModulo)���
���			 � nVar     -- verifica se estah sendo tratado layout envio ou recebimento ���
���			 � cArqEnv  -- layout do arquivo de envio                                  ���
���			 � cArqREc  -- layout do arquivo de recebimento                            ���
���			 � cModulo  -- modulo no qual a rotina foi disparada                       ���
��������������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Template Function ValidaCampo( cCod   , cLoja, nVar, cArqEnv,;
							   cArqRec, cModulo )

Local lRet     	:= .T.    
Local lVerifica := .T.
Local cTpConv  	:= ""
Local cText1   	:= ""
Local cText2   	:= ""

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()
                              
If cModulo = "C"
	cText1   := STR0033+;  //'Fornecedor n�o existe.'
                STR0034+; //'Favor verifique os seguintes campos:'
                STR0035   //'"C�d. fornec."  e/ou  "Loja".'
Elseif cModulo = "L"
	cText1   := STR0036+;  //'Empresa de Conv�nio n�o existe.'
                STR0034+; //'Favor verifique os seguintes campos:'
                STR0037   //'"C�d.Empresa"  e/ou  "Loja".'
 	cText2   := STR0038+; //'O C�digo e Loja  colocados  n�o s�o referentes � uma Empresa de Conv�nio.'
				STR0005                	 //'Favor corrigi-los.'
End           

lVerifica   := !Empty(cCod) .AND. !Empty(cLoja)                                      

If lVerifica .AND. cModulo = "L"// verifica se os campo Cod.Empresa e Loja estao preenchidos 
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !MsSeek(xFilial("SA1")+cCod+cLoja)// verifica se o codigo da empresa + codigo da loja existem em SA1
		MsgAlert(cText1)
		lRet := .F.
	Else
		cTpConv := Lower(Posicione("SA1",1,xFilial("SA1")+cCod+cLoja,"A1_TPCONVE"))
		If cTpConv <> "4"//caso codigo da Empresa + codigo da Loja da Emresa existam,verifica se a opcao A1_TPCONVE <> "4" 
			MsgAlert(cText2)
			lRet := .F.
		Endif
	Endif
Endif


If lVerifica .AND. cModulo = "C"// verifica se os campo Cod.Fornec. e Loja estao preenchidos 
	DbSelectArea("SA2")
	DbSetOrder(1)
	If !MsSeek(xFilial("SA2")+cCod+cLoja)// verifica se o codigo do fornecedor + codigo da loja existem em SA2
		MsgAlert(cText1)
		lRet := .F.
	Endif
Endif

If lRet
	//��������������������������������������|
	//�Buscando arquivo de Layout cadastrado�
	//�na Empresa de Convenio               �
	//��������������������������������������|
	If nVar = 1 .AND. cModulo = "L"
		cArqEnv := Posicione("SA1",1,xFilial("SA1")+cCod+cLoja,"A1_LAYOUTC")
	Elseif nVar = 2 .AND. cModulo = "L"
		cArqRec := Posicione("SA1",1,xFilial("SA1")+cCod+cLoja,"A1_LAYIMP")
	Endif
	//��������������������������������������|
	//�Buscando arquivo de Layout cadastrado�
	//�no Fornecedor		                �
	//��������������������������������������|	
	If nVar = 1 .AND. cModulo = "C"
		cArqEnv := Posicione("SA2",1,xFilial("SA2")+cCod+cLoja,"A2_LAYOUTE")
	Elseif nVar = 2 .AND. cModulo = "C"
		cArqRec := Posicione("SA2",1,xFilial("SA2")+cCod+cLoja,"A2_LAYOUTR")
	Endif	
Endif

Return .T.

/*���������������������������������������������������������������������������
���Programa  �DroVldMA6C�Autor  �Vendas Clientes     � Data �  04/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao do campo do status do cartao                      ���
�������������������������������������������������������������������������͹��
���Uso       �Template Drogaria - CRDA010                                 ���
���������������������������������������������������������������������������*/
Template Function DroVldMA6C()
Local lRet			:= .T. 													// Retorno da funcao 
Local cChaveAtivo 	:= ""	    											// Chave de busca
Local cChaveBloque	:= "" 													// Chave de busca
Local nPosSitua 	:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_SITUA"})		// Posicao do status do cartao 1=Ativo;2=Bloqueado;3=Cancelado
Local nPosDepCart	:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_CODDEP"})		// Posicao do codigo do dependente
Local nPosNumCart	:= Ascan(aHeader6,{|x| Trim(x[2]) == "MA6_NUM"})		// Numero do cartao
Local nX			:= 0													// Variavel de looping
Local cMA6_SITUA	:= ""													// Situacao do campo

LjGrvLog( NIL, " Pilha (-1): " + ProcName(1))
LjGrvLog( NIL, " Pilha (-2): " + ProcName(2))

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

LjGrvLog( NIL, " Log do OBjeto : oGetD6 " , ValType(oGetD6))
LjGrvLog( NIL, " Log do OBjeto : oGetD6:aCols " , oGetD6:aCols)
LjGrvLog( NIL, " Log do OBjeto : oGetD6:nAT " , oGetD6:nAT)

//����������������������������������������������������������������������Ŀ
//� So' faz a validacao se a linha nao estiver deletada                  �
//������������������������������������������������������������������������
If !oGetD6:aCols[oGetD6:nAT][Len( oGetD6:aCols[oGetD6:nAT] )]
	
	LjGrvLog( NIL, " Objeto Validado e Linha V�lida ")
	            
	/* Pega a situacao do campo que o usuario digitou */
	cMA6_SITUA := Alltrim( &(ReadVar()) )
	LjGrvLog( NIL, " Campo Digitado pelo Usu�rio :", cMA6_SITUA)
	
	LjGrvLog( NIL, " Log da Variavel nPosDepCart :", nPosDepCart)
	
	/* Determina qual a chave de busca para validacao do status do cartao   */
	cChaveAtivo 	:= 	Alltrim( oGetD6:aCols[oGetD6:nAT][nPosDepCart] ) + ;	// Codigo do dependente
						"1"		    											// Status do cartao
	
	cChaveBloque	:= 	Alltrim( oGetD6:aCols[oGetD6:nAT][nPosDepCart] ) + ;	// Codigo do dependente
						"2"		    											// Status do cartao
	
	LjGrvLog( NIL, " Log da Variavel cChaveAtivo :", cChaveAtivo)
	LjGrvLog( NIL, " Log da Variavel cChaveBloque :", cChaveBloque)
	
	/* Faz a validacao se pode alterar o status do cartao. Se for para    
	 status CANCELADO nao valida, mas se alterar ATIVO ou BLOQUEADO veri- 
	 fica se ja' existe outro cartao com o mesmo status. Caso exista, nao 
	 permite alteracao                                               */
	If cMA6_SITUA $ "1|2" // Ativo ou Bloqueado
		For nX := 1 To Len( oGetD6:aCols )
			//Nao valida se for a mesma linha que foi digitada
			If nX <> oGetD6:nAT	
				//Verifica so os registros que nao estao deletados
				If !oGetD6:aCols[nX][Len( oGetD6:aCols[nX] )]
					
					If 	cChaveAtivo == Alltrim( oGetD6:aCols[nX][nPosDepCart] ) + Alltrim( oGetD6:aCols[nX][nPosSitua] ) .OR.;
						cChaveBloque == Alltrim( oGetD6:aCols[nX][nPosDepCart] ) + Alltrim( oGetD6:aCols[nX][nPosSitua] )
							MsgStop( STR0039 ) //"J� existe um cart�o ATIVO/BLOQUEADO para este cliente. Voc� dever� alterar o status do outro cart�o antes de fazer esta altera��o."
							lRet := .F.
					Endif
					
				Endif
			Endif
		Next nX
	Endif
Endif
              
Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroVldPln �Autor  �Vendas Clientes     � Data �  29/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Verifica se o(s) campo(s) do Codigo do Plano de Fidelidade  ���
���          �estao preenchido.                                           ���
���          �Os campo referente a Situacao dos Planos de Fidelidade      ���
���          �so' serao habilitados caso os campo do Codigo do Plano de   ���
���          �Fidelidade estiverem preenchido.                            ���
�������������������������������������������������������������������������͹��
���Uso       �Template Drogaria - CRDA010                                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numeracao do ultimo caracter do campo A1_CODPLF''   ���
���          �        A1_CODPLF1                                          ���
���          �        A1_CODPLF2                                          ���
���          �        A1_CODPLF3                                          ���
���          �        A1_CODPLF4                                          ���
���          �        A1_CODPLF5                                          ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Habilita ou nao os campos referente a Situacao      ���
���          �        dos planos de fidelidade.                           ���
���������������������������������������������������������������������������*/
Template Function DroVldPln( nParam )
Local lRet   	 := .F.									//Retorno da funcao 
Local cCampo 	 := "M->A1_CODPLF"+Alltrim(Str(nParam))//concatenacao entre campo e parametro
Local cContCampo := &(cCampo) 							//conteudo do campo do codigo do plano de fidelidade

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

If !Empty(cContCampo)
	lRet := .T.
Endif

Return lRet

/*����������������������������������������������������������������������������
���Programa  �DROSeekMA6  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna a numeracao do Cartao ATIVO do cliente.             ���
��������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                           ���
��������������������������������������������������������������������������͹��
���Chamada   � TPLDROPE (funcao FRT010CL)                                  ���
��������������������������������������������������������������������������͹��
���Parametros�ExpN1 - 1 - Busca no SA1 pelo CPF                            ���
���          �        2 - Busca no SA1 pela MATRICUA                       ���
���          �ExpC1 - Pode ser numeracao do CPF ou numeracao da matricula  ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpC1 - Numeracao do cartao do cliente                       ���
��������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���          �        �      �                                             ���
����������������������������������������������������������������������������*/
Template Function DROSeekMA6( nTipo, cParam )
Local cNumCartao   := "" 	//Numeracao do cartao
Local cCod 		   := ""	//Codigo do cliente
Local cLoj 		   := ""	//Loja do cliente
Local lAchouCartao := .F.	//Verifica se achou o cartao nos registros da tabela MA6

//��������������������������������������������������������
//�verificamos se o sistema possui a licenca de          �
//� Integracao Protheus x SIAC ou de Template de Drogaria�
//��������������������������������������������������������
T_DROLCS()

DbSelectArea("SA1")
If nTipo = 1 //significa que a busca no SA1 sera' pelo CPF 
	DbSetOrder(3)//A1_FILIAL + A1_CGC
Else // significa que a busca no SA1 sera' pela MATRICULA
	DbOrderNickName("SA1DRO1")// A1_FILIAL+A1_MATRICU+A1_EMPCONV+A1_LOJCONV //A1_FILIAL + A1_MATRICU + A1_EMPCONV + A1_LOJCONV
Endif
If DbSeek(xFilial("SA1") + cParam )
	cCod := A1_COD
	cLoj := A1_LOJA
	DbSelectArea("MA6")
	DbSetOrder(2)	
	If DbSeek(xFilial("MA6") + cCod + cLoj )
	   	// percorre os registros do MA6, pois um determinado cliente pode conter mais de um cartao
	   	// mas somente um cartao ativo
	   	While ( !lAchouCartao 								    .AND.;
	   			cCod + cLoj == MA6->MA6_CODCLI + MA6->MA6_LOJA .AND.;
	   		    Empty(MA6->MA6_CODDEP) )                      
		   	If  MA6->MA6_SITUA = "1"
				cNumCartao := MA6_NUM
				lAchouCartao := .T.
			Else
				MA6->(DbSkip())   	
		   	Endif   	
		End  	
	Endif
Endif

Return cNumCartao

/*����������������������������������������������������������������������������
���Programa  �DroVerCont  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Verifica se o produto que esta sendo vendido e' do tipo      ���
���          �CONTROLADO                                                   ���
��������������������������������������������������������������������������͹��
���Uso       �TPLDROPE    - funcoes: FRTDescIt() e LJ7036()                ���
���          �FRTA010A    - funcoes: FRTProdOK() e FRTCancIT()             ���
���          �DROVLDFUNCS - funcao   DroEntANVISA()    			           ���
���          �LOJA430     - funcoes: Lj430Grv() e LJ430LIN()	           ���
��������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do produto                                    ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Produto controlado ou nao                            ���
����������������������������������������������������������������������������*/
Template Function DroVerCont( cCodProd )
Local cAlias 	 := ""		//Alias
Local cCampo	 := ""		//Nome do campo
Local cCampoClass:= ""		//Nome do campo
Local lRet   	 := .F.		//Retorno da funcao
Local lTotvsPDV	 :=  STFIsPOS()
Local nTamCodProd:= 0

If nModulo == 23 .And. !lTotvsPDV
	cAlias 	  		:= "SBI"
	cCampo	  		:= "SBI->BI_PSICOTR"
	cCampoClass		:= "SBI->BI_CLASSTE"
	nTamCodProd		:= TamSx3("BI_COD")[1]
Else
	cAlias 	  		:= "SB1"
	cCampo	  		:= "SB1->B1_PSICOTR"
	cCampoClass		:= "SB1->B1_CLASSTE"
	nTamCodProd		:= TamSx3("B1_COD")[1]		
Endif

DbSelectArea(cAlias)                 
(cAlias)->(DbSetOrder(1))
If (cAlias)->(DbSeek(xFilial(cAlias) + Padr(AllTrim(cCodProd),nTamCodProd)))
	If  &(cCampo) == "1" 
		lRet := .T.
	Endif
Endif	

If !lRet
	DbSelectArea(cAlias)                 
	(cAlias)->(DbSetOrder(1))
	If (cAlias)->(DbSeek(xFilial(cAlias) + Padr(AllTrim(cCodProd),nTamCodProd)))
		If !Alltrim(&(cCampoClass)) == ""   
			lRet := .T.
		Endif
	Endif
Endif	

Return lRet

/*����������������������������������������������������������������������������
���Programa  �DroTempLK9  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Validaca da tela da ANVISA                                   ���
��������������������������������������������������������������������������͹��
���Uso       �DROAXCADASTRO  - funcao DroVSNGPC()                          ���
��������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Botao Ok pressionado = .T.                           ���
���          �ExpA2 - Array contendo os campos a serem gravados            ���
���          �ExpL3 - Indica que a tela da ANVISA foi acionada automatica- ���
���          �        mente apos informar o produto controlado             ���
���          �ExpL4 - Indica que a tela ANVISA foi acionada via tecla F12  ���
��������������������������������������������������������������������������͹��
���Retorno   �.T.                                                          ���
����������������������������������������������������������������������������*/
Template Function DroTempLK9( lRet, aCampos, lTela, lF12 )

If lRet
	If IsInCallStack("T_DroVlApr")	//Grava��o do campo LK9 vindo da tela de aprova��o de medicamentos
		T_DroGrLk9(aCampos) 
	ElseIf nModulo == 23
		T_DroAddANVISA(lTela, aCampos, lF12)
	ElseIf nModulo == 12
		T_DroAuxANVISA( lTela, aCampos, lF12 ) 
		If lF12
			DrochkLK9(lF12)
		EndIf
	Endif
Endif

Return .T.

/*����������������������������������������������������������������������������
���Programa  �DroAddANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Adiciona informacoes do medico e do cliente no array aANVISA ���
��������������������������������������������������������������������������͹��
���Uso       �TPLDROPE    - funcao FrtDescIT()                             ���
���          �DROVLDFUNCS - funcao DroTempLK9()                            ���
��������������������������������������������������������������������������͹��
���Chamada   �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica que a tela da ANVISA foi acionada automatica- ���
���          �        mente apos informar o produto controlado             ���
���          �ExpA2 - Array contendo os campos a serem gravados            ���
���          �ExpL3 - Indica que a tela ANVISA foi acionada via tecla F12  ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroAddANVISA( lDadosTela, aCampos, lF12 )

Local nCont   		:= 0	//Controle de loop
Local nX			:= 0
Local nLinha  		:= 0	//Posicao do array a ser utilizada
Local cLote	  		:= ""	//Lote do produto
Local cTemp					// Sem tipo definido , pode ser Array ou Caracter 
Local cUsoPro		:= "2"	//Uso Prolongado
Local aDroPELK9		:= {}

//pega a posicao dos campo do array acampos
Local  nNOME		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NOME"})    //01
Local  nTIPOID		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_TIPOID"})  //02 
Local  nNUMID		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NUMID"})   //03
Local  nORGEXP		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_ORGEXP"})  //04 
Local  nUFEMIS		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_UFEMIS"})  //05
Local  nRECEITA		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NUMREC"})  //06  
Local  nTPRECEITA	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_TIPREC"})  //07 
Local  nTPUSO		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_TIPUSO"})  //08 
Local  nDATRECEITA	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_DATARE"})  //09 
Local  nMEDICO      := aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NOMMED"})  //10 
Local  nCRM			:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NUMPRO"})  //11 
Local  nCONPROF		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_CONPRO"})  //12 
Local  nUFCONS		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_UFCONS"})  //13
Local  nLOTEPROD	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_LOTE"})    //14
Local  nENDERECO	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_END"})     //15
Local  nPACIENTE	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_NOMEP"})  	//16 
Local  nUSOPROLON	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_USOPRO"}) 	//18 
Local  nIDADEP		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_IDADEP"})	//19 
Local  nUNIDAP		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_UNIDAP"})	//20 
Local  nSEXOP		:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_SEXOPA"})	//21 
Local  nCI			:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_CIDPA"})		//22 
Local  nQtdPresc	:= aScan(aCampos,{|x| AllTrim(Upper(x[2])) == "LK9_QUANTP"})	//32 

// verifica se possui campo de usuario
If ExistBlock("DROPELK9")
	aDroPELK9 := ExecBlock("DROPELK9",.F.,.F.,{{}})
	If ValType(aDroPELK9) <> "A"
		aDroPELK9 := {}
	EndIf
EndIf

//�����������������������������������������������������Ŀ
//�Se lDadosTela = .F., nao e' utilizado o array aCampos�
//�������������������������������������������������������
If lDadosTela .OR. lF12
	//�������������������������Ŀ
	//�Cria a dimens�o no array �
	//���������������������������
	If !lInformouLote
		aAdd( aANVISA, {} )
		// tratamento para campos de usuario
		If Len(aDroPELK9) = 2
			aAdd( aLK9Usr, {} )
		EndIf
		nLinha := T_DroLenANVISA()
	Endif

	For nCont := 1 to TAMANVISA
		aAdd(aANVISA[nLinha], )
	Next nCont

	If lF12
		lInformouLote := .T.		//Indica que nao sera' necessario informar o lote na digitacao do produto
	Endif
	
	aANVISA[nLinha][NOME]		:= M->&(aCampos[nNOME][2])				//Nome do cliente
	aANVISA[nLinha][TIPOID]		:= M->&(aCampos [nTIPOID][2])    		//Tipo de identificacao do cliente
	aANVISA[nLinha][NUMID]		:= M->&(aCampos [nNUMID][2])     		//Numero de identificacao do cliente
	aANVISA[nLinha][ORGEXP]		:= M->&(aCampos [nORGEXP][2])    		//Orgao Expedidor
	aANVISA[nLinha][UFEMIS] 	:= M->&(aCampos [nUFEMIS][2])    		//Unidade Federatica
	aANVISA[nLinha][RECEITA]	:= M->&(aCampos [nRECEITA][2])   		//Numero da receita medica
	aANVISA[nLinha][TPRECEITA]	:= M->&(aCampos [nTPRECEITA][2]) 		//Tipo da receita medica
	aANVISA[nLinha][TPUSO]		:= M->&(aCampos [nTPUSO][2])  	 		//Tipo de uso da receita medica
	aANVISA[nLinha][DATRECEITA]	:= M->&(aCampos [nDATRECEITA][2])		//Data da receita medica
	aANVISA[nLinha][MEDICO]		:= M->&(aCampos [nMEDICO][2])    		//Nome do medico
	aANVISA[nLinha][CRM]		:= M->&(aCampos [nCRM][2])       		//CRM do medico
	aANVISA[nLinha][CONPROF]   	:= M->&(aCampos [nCONPROF][2])  		//Conselho profissional do medico
	aANVISA[nLinha][UFCONS]    	:= M->&(aCampos [UFCONS][2])    		//Unidade federativa do conselho profissional do medico
	aANVISA[nLinha][LOTEPROD]  	:= M->&(aCampos [nLOTEPROD][2]) 
	aANVISA[nLinha][ENDERECO]  	:= M->&(aCampos [nENDERECO][2])			//Endereco do cliente
	aANVISA[nLinha][NPACIENTE]	:= M->&(aCampos [nPACIENTE][2]) 		//Nome do Paciente 
	aANVISA[nLinha][USOPROLONG]	:= M->&(aCampos [nUSOPROLON][2]) 
	aANVISA[nLinha][IDADEP]		:= M->&(aCampos [nIDADEP][2]) 
	aANVISA[nLinha][UNIDAP]		:= M->&(aCampos [nUNIDAP][2]) 
	aANVISA[nLinha][SEXOPA]		:= M->&(aCampos [nSEXOP][2]) 
	aANVISA[nLinha][CIDPA]		:= M->&(aCampos [nCI][2])
	aANVISA[nLinha][QUANTP]		:= M->&(aCampos [nQtdPresc][2]) 
	If Len(aDroPELK9) = 2
		For nX := 1 to Len( aDroPELK9[2] )
			Aadd( aLK9Usr[nLinha], {aDroPELK9[2][nX], M->&(aDroPELK9[2][nX])} )			
		Next		
	EndIf
Else 
	If !lInformouLote .AND. Len(aANVISA) > 0 
		aAdd(aANVISA, ARRAY(TAMANVISA))

		// tratamento para campos de usuario
		If Len(aDroPELK9) = 2			
			aAdd(aLK9Usr, {})
		EndIf

		nLinha := T_DroLenANVISA()	
	
		//������������������������������������������������������������������������Ŀ
		//�Tratamento em que a tela com informacoes referentes a                   �
		//�receita medica e cliente ja' foi informada, com isso, nao e' necessario �
		//�a solicitacao da tela novamente, porem, as informacoes de               �
		//�receita medica e cliente, deverao ser mantidas.                         �
		//��������������������������������������������������������������������������
 		aANVISA[nLinha][NOME]		:= aANVISA[nLinha-1][NOME]      		//Nome do cliente
		aANVISA[nLinha][TIPOID]		:= aANVISA[nLinha-1][TIPOID]    		//Tipo de identificacao do cliente
		aANVISA[nLinha][NUMID]		:= aANVISA[nLinha-1][NUMID]     		//Numero de identificacao do cliente
		aANVISA[nLinha][ORGEXP]		:= aANVISA[nLinha-1][ORGEXP]    		//Orgao Expedidor
		aANVISA[nLinha][UFEMIS] 	:= aANVISA[nLinha-1][UFEMIS]    		//Unidade Federatica
		aANVISA[nLinha][RECEITA]	:= aANVISA[nLinha-1][RECEITA]   		//Numero da receita medica
		aANVISA[nLinha][TPRECEITA]	:= aANVISA[nLinha-1][TPRECEITA] 		//Tipo da receita medica
		aANVISA[nLinha][TPUSO]		:= aANVISA[nLinha-1][TPUSO]  	 		//Tipo de uso da receita medica
		aANVISA[nLinha][DATRECEITA]	:= aANVISA[nLinha-1][DATRECEITA]		//Data da receita medica
		aANVISA[nLinha][MEDICO]		:= aANVISA[nLinha-1][MEDICO]    		//Nome do medico
		aANVISA[nLinha][CRM]		:= aANVISA[nLinha-1][CRM]       		//CRM do medico
		aANVISA[nLinha][CONPROF]   	:= aANVISA[nLinha-1][CONPROF]   		//Conselho profissional do medico
		aANVISA[nLinha][UFCONS]    	:= aANVISA[nLinha-1][UFCONS]    		//Unidade federativa do conselho profissional do medico
		aANVISA[nLinha][ENDERECO]  	:= aANVISA[nLinha-1][ENDERECO]			//Endereco do cliente
		aANVISA[nLinha][NPACIENTE]	:= aANVISA[nLinha-1][NPACIENTE] 
		aANVISA[nLinha][USOPROLONG]	:= aANVISA[nLinha-1][USOPROLONG]  
		aANVISA[nLinha][IDADEP]		:= aANVISA[nLinha-1][IDADEP] 
		aANVISA[nLinha][UNIDAP]		:= aANVISA[nLinha-1][UNIDAP] 
		aANVISA[nLinha][SEXOPA]		:= aANVISA[nLinha-1][SEXOPA] 
		aANVISA[nLinha][CIDPA]		:= aANVISA[nLinha-1][CIDPA] 
		aANVISA[nLinha][QUANTP]		:= aANVISA[nLinha-1][QUANTP] 
		//��������������������������������������������Ŀ
		//�Solicitacao de tela para a digitacao do lote�
		//� e Uso Prolongado do produto                �
		//����������������������������������������������
		cTemp := T_DroLoteANVISA()
		If Valtype(cTemp) == "A" 
			cLote := cTemp[1]
			cUsoPro	:= cTemp[2]
		Else
			cLote := cTemp
		EndIf

		aANVISA[nLinha][LOTEPROD] 	:= cLote 								//Lote do produto
		aANVISA[nLinha][USOPROLONG] := cUsoPro								//Lote do produto

		If Len(aDroPELK9) = 2
			For nX := 1 to Len( aDroPELK9[2] )
				Aadd( aLK9Usr[nLinha], {aDroPELK9[2][nX], M->&(aDroPELK9[2][nX])} )			
			Next		
		EndIf

		If FunName() == "LOJA701"
			LJ7AtuLote(cLote)
		EndIf
	Endif
Endif

Return

/*����������������������������������������������������������������������������
���Programa  �DroAltANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Alteracao no array aANVISA, inclusao dos dados do produto    ���
��������������������������������������������������������������������������͹��
���Uso       �FRTA010A - funcao FRTProdOK()                                ���
��������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do produto                                    ���
���          �ExpN2 - Quantidade informada                                 ���
���          �ExpC3 - Numero do documento- NF                              ���
���          �ExpC4 - Serie do documento                                   ���
���          �ExpN5 - ID referente ao array aItens                         ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroAltANVISA( cCodProd  , nQuant, cDoc, cSerie,;
								nCodANVISA  )   
Local nLinha     := 0						//Posicao do array a ser utilizada
Local cAlias     := ""						//Alias
Local cUM	     := ""						//Unidade de Medida do produto		
Local cDescProd  := ""						//Descricao do produto	
Local cRegMS     := ""						//Registro do Ministerio da Saude
Local cClassTer := ""						//Classe Terapeutica

If ValType(nCodANVISA) == "C"
	nCodANVISA := Val(nCodANVISA)
Endif

If T_DroLenANVISA() > 0 
	If nModulo == 23
		cAlias := "SBI"
	Else
		cAlias := "SB1"
	Endif
	
	DbSelectArea(cAlias)                 
	DbSetOrder(1)
	If DbSeek(xFilial(cAlias) + cCodProd)  
		cUM 	  := &(Substr(cAlias,2,2)+"_UM")
		cDescProd := &(Substr(cAlias,2,2)+"_DESC")
		cRegMS    := &(Substr(cAlias,2,2)+"_REGMS")
		cClassTer := &(Substr(cAlias,2,2)+"_CLASSTE")
		
	Endif
	
	If AllTrim(cClassTer) == ""
		cClassTer := "2"
	EndIf

	nLinha := T_DroLenANVISA()
	
	//������������������������������������������Ŀ
	//�Adiciona informacoes do produto registrado�
	//��������������������������������������������
	
	aANVISA[nLinha][PRODUTO]  := cCodProd	  		//Codigo do produto 
	
	aANVISA[nLinha][REGMS]    := cRegMS	    		//Registro do produto no Ministerio da Saude
		
	aANVISA[nLinha][QTDEPROD] := nQuant	 		 	//Quantidade 
	aANVISA[nLinha][NUMDOC]   := cDoc		 		//Numero do Documento
	aANVISA[nLinha][SERIE]    := cSerie	 			//Serie do Documeto
	aANVISA[nLinha][UM]       := cUM		 		//Unidade de Medida do produto  
	aANVISA[nLinha][DESCPRO]  := cDescProd   		//Descricao do produto  
	aANVISA[nLinha][IDANVISA] := nCodANVISA 		//ID que faz referencia ao array aItens localizado no FRTA010
	aANVISA[nLinha][CLASSTERAP] := cClassTer		// Classe Terapeutica
Endif 

lInformouLote := .F.

Return

/*����������������������������������������������������������������������������
���Programa  �DroDelANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Delecao de linhas do array aANVISA quando um ou todos os     ���
���          �itens forem cancelados                                       ���
��������������������������������������������������������������������������͹��
���Uso       �No cancelamento de um ou todos os itens da venda             ���
��������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se sera' deletado todos os itens do venda     ���
���          �ExpN2 - ID do item que sera' deletado                        ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroDelANVISA( lAllItens, nCodANVISA )
Local nCont := 0	//Controle de loop

If ValType(nCodANVISA) == "C"
	nCodANVISA := Val(nCodANVISA)
Endif

If T_DroLenANVISA() > 0
	If !lAllItens
		For nCont := 1 to T_DroLenANVISA()
			If aANVISA[nCont][IDANVISA] == nCodANVISA
				ADel( aANVISA, nCont )
				ASize(aANVISA, T_DroLenANVISA()-1 )

				//Apaga o vetor com os campos de usuario
				If Len(aLK9Usr) > 0
					ADel( aLK9Usr, nCont )
					ASize(aLK9Usr, T_DroLenANVISA()-1 )
				EndIf

				Exit
			Endif
		Next nCont 
	Else 
		aSize(aANVISA,0)
		aSize(aLK9Usr,0)
	Endif	
Endif

Return

/*����������������������������������������������������������������������������
���Programa  �DroGrvANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Efetua a gravacao na tabela LK9 - Logs ANVISA                ���
��������������������������������������������������������������������������͹��
���Uso       �Apos a impressao do CUPOM FISCAL - Ponto de Entrada FrtEntreg���
��������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Indica o tipo de acao que foi executada:             ���
���          �        1 = Finalizacao da Venda                             ���
���          �        2 = Gravacao como Orcamento                          ���
���          �        3 = Finalizacao da Venda com receita na preenchida   ���
���                       na retaguarda, nao preenchida no front           ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroGrvANVISA(nTipo)   

Local nCont   	:= 0 	// Controle de loop
Local cStatus 	:= "3"	// Status no qual sera' gravado o registro (1 - Orcamento; 2 - Venda; 3 - Venda Front Loja)
Local nI		:= 0	// Contador

DEFAULT nTipo := 0	//Usando somente para o SIGALOJA

If nModulo == 12
	If nTipo == 1
		cStatus := "1"
	ElseIf nTipo == 2
		cStatus := "2"
		T_DroDocSerie()
	Endif

	T_DROCancANVISA()
Endif

If T_DroLenANVISA() > 0 
	For nCont := 1 to T_DroLenANVISA()
		RecLock("LK9", .T.)
		REPLACE LK9_FILIAL	WITH xFilial("LK9")
		REPLACE LK9_DATA	WITH dDataBase
		REPLACE LK9_DOC		WITH aANVISA[nCont][NUMDOC]
		REPLACE LK9_SERIE	WITH aANVISA[nCont][SERIE]
		REPLACE LK9_TIPMOV	WITH "2"
		REPLACE LK9_NOME	WITH aANVISA[nCont][NOME]		
		REPLACE LK9_TIPOID	WITH aANVISA[nCont][TIPOID]
		REPLACE LK9_NUMID	WITH aANVISA[nCont][NUMID]
		REPLACE LK9_ORGEXP	WITH aANVISA[nCont][ORGEXP]
		REPLACE LK9_UFEMIS	WITH aANVISA[nCont][UFEMIS]
		REPLACE LK9_NUMREC	WITH aANVISA[nCont][RECEITA]
		REPLACE LK9_TIPREC	WITH aANVISA[nCont][TPRECEITA]
		REPLACE LK9_TIPUSO	WITH aANVISA[nCont][TPUSO]
		REPLACE LK9_DATARE	WITH aANVISA[nCont][DATRECEITA]
		REPLACE LK9_NOMMED	WITH aANVISA[nCont][MEDICO]
		REPLACE LK9_NUMPRO	WITH aANVISA[nCont][CRM]
		REPLACE LK9_CONPRO	WITH aANVISA[nCont][CONPROF]
		REPLACE LK9_UFCONS	WITH aANVISA[nCont][UFCONS]
		REPLACE LK9_CODPRO	WITH aANVISA[nCont][PRODUTO]
		REPLACE LK9_DESCRI	WITH aANVISA[nCont][DESCPRO]		
		REPLACE LK9_UM		WITH aANVISA[nCont][UM]
		REPLACE LK9_QUANT	WITH aANVISA[nCont][QTDEPROD]
		REPLACE LK9_LOTE	WITH aANVISA[nCont][LOTEPROD] 
		REPLACE LK9_STATUS	WITH cStatus   
		REPLACE LK9_NUMORC	WITH If(nModulo <> 23,aANVISA[nCont][NUMORC],"")
		REPLACE LK9_REGMS	WITH aANVISA[nCont][REGMS]
		REPLACE LK9_OBSPER	WITH "Venda Doc:" + Alltrim(aANVISA[nCont][NUMDOC]) + " Serie:" + aANVISA[nCont][SERIE] + " em:" + dToC(dDataBase)  	  
		REPLACE LK9_CODLIS	WITH Posicione("SB1",1,xFilial("SB1")+aANVISA[nCont][PRODUTO],"B1_CODLIS")	
		REPLACE LK9_SITUA	WITH "00" 
		REPLACE LK9_END     WITH aANVISA[nCont][ENDERECO]
		REPLACE LK9_NOMEP	WITH aANVISA[nCont][NPACIENTE]
		REPLACE LK9_CLASST	WITH aANVISA[nCont][CLASSTERAP]
		REPLACE LK9_USOPRO  WITH aANVISA[nCont][USOPROLONG]
		REPLACE LK9_IDADEP  WITH aANVISA[nCont][IDADEP]
		REPLACE LK9_UNIDAP  WITH aANVISA[nCont][UNIDAP]
		REPLACE LK9_SEXOPA  WITH aANVISA[nCont][SEXOPA]
		REPLACE LK9_CIDPA	WITH aANVISA[nCont][CIDPA] 
		REPLACE LK9_QUANTP  WITH aANVISA[nCont][QUANTP]
		REPLACE LK9_TPCAD	WITH "2"
		//campos de seguranca
		REPLACE LK9_USVEND  WITH IIF(!Empty(SL1->L1_USVENDA),SL1->L1_USVENDA,cUserName)	//No F4, n�o preciso mais digitar usu�rio e a senha do supervisor, somente o login do usu�rio.		
		//campos de seguranca
		REPLACE LK9_USAPRO  WITH SL1->L1_USAPROV	//cCaixaSup

		//Grava��o de Campos de Usuario
		If Len(aLK9Usr) > 0
			For nI := 1 to Len(aLK9Usr[nCont])
				Replace &( aLK9Usr[nCont][nI][1] ) with aLK9Usr[nCont][nI][2]
			Next
		EndIf

		LK9->( MsUnLock() )
	Next nCont
Endif

                                                
//���������������������������������������������������������������Ŀ
//�Inicializacao das variaveis do tipo STATIC para a proxima venda�
//�����������������������������������������������������������������
aSize(aANVISA,0)						//Array que armazena os Logs da ANVISA
aSize(aAuxANVISA,0)						//Array Auxiliar que armazena os Logs da ANVISA

aSize(aLK9Usr,0) 						//Array que armazena os Logs da ANVISA
aSize(aAuxLK9Usr,0)						//Array Auxiliar que armazena os Logs da ANVISA

lInformouLote	:= .F.					//Verifica se deve ou nao informar a tela de lote
lPressAtalho	:= .F.					//Verifica se a tela da ANVISA foi acionada via teclas de Atalho

Return

/*����������������������������������������������������������������������������
���Programa  �DroVldTela  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Valida se todos os campos da tela ANVISA foram informados    ���
��������������������������������������������������������������������������͹��
���Uso       �Botao Ok da tela que contem os dados de venda dos medicamento���
���          �controlados                                                  ���
��������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se o Botao Ok foi ou nao pressionado          ���
���          �ExpA2 - Array contendo os campos relacionados a ANVISA       ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Valida ou nao informacoes                            ���
����������������������������������������������������������������������������*/
Template Function DroVldTela(lRet, aCampos,cClassTe)
Local lRetorno 		:= .F.			//Retorno da funcao
Local nCont	   		:= 0			//Controle de loop
Local lEmBranco		:= .F.		 	//Verifica se existe algum campo em branco
Local nCONPROF		:= aScan(aCampos, {|x| AllTrim(x[2]) == "LK9_CONPRO"})
Local nTIPUSO		:= aScan(aCampos, {|x| AllTrim(x[2]) == "LK9_TIPUSO"})
Local nNumID		:= aScan(aCampos, {|x| AllTrim(x[2]) == "LK9_NUMID"})
Local cContNumID	:= ""
Local cPsico		:= ''
Local lCpoPac		:= .F.  // Campos de Validacao de Paciente  // Guia SNGPC V2.0 regra SGNPC 4.1.5 � Identifica��o do paciente e comprador 
Local lCpoComp		:= .F.  // Campos de Validacao de Cliente/Comprador  SGNPC 4.1.5 � Identifica��o do paciente e comprador
Local lCpoNobr		:= .F.  // Campos nao obrigatorios   SGNPC 4.1.5 � Identifica��o do paciente e comprador
Local nDiasValid	:= SuperGetMv("MV_DROVLRC",,10)		 // parametro de validade de dias da receita AntiMicrobiano
Local cCodLis       := ""								 // Codigo da Lista	
Local cComple       := ""								 // Complemento do tipo de Receita	
Local lVldCpoPac	:= .T.			//indica se valida os campos de Paciente
Local cVdForaAu		:= ""//Campo SB1/SBI_VDFORAU
Local lCpoAntM		:= .T.//Campos Antimicrobiano
Local lTotvsPDV     := STFIsPOS()

If nModulo == 23 .And. !lTotvsPDV
	cClassTe := Alltrim(SBI->BI_CLASSTE)	
	cPsico := Alltrim(SBI->BI_PSICOTR)	
	cVdForaAu := SBI->BI_VDFORAU
Else
	cClassTe := Alltrim(SB1->B1_CLASSTE)	
	cPsico := Alltrim(SB1->B1_PSICOTR)	
	cCodLis := Alltrim(SB1->B1_CODLIS)
	cVdForaAu := SB1->B1_VDFORAU	
Endif

If lRet

	If nTIPUSO > 0 .AND. Alltrim( M->&(aCampos[nTIPUSO][2]) ) == "2"	//Uso Veterinario
		lVldCpoPac := .F.	//n�o valida os campos de Paciente
	EndIf

	For nCont := 1 to Len(aCampos)
		If !aCampos[nCont][13]	//Verifica se o campo e somente visual
			If Empty(M->&(aCampos[nCont][2]))  // se o campos estiver vazio 

				lCpoPac :=	(Alltrim(aCampos[nCont][2]) == "LK9_NOMEP"	) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_IDADEP" ) .OR. ; 
							(Alltrim(aCampos[nCont][2]) == "LK9_UNIDAP" ) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_SEXOPA"	) 
	
				lCpoAntM :=	(Alltrim(aCampos[nCont][2]) == "LK9_USOPRO"	) .OR. ;  // uso prolongado tem que ter valor em Medicamento AntiMicrobiano
							(Alltrim(aCampos[nCont][2]) == "LK9_QUANTP"	) 
	
	
				lCpoComp:=	(Alltrim(aCampos[nCont][2]) == "LK9_NOME" )   .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_TIPOID" ) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_NUMID"	) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_ORGEXP"	) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_END"	) .OR. ;
							(Alltrim(aCampos[nCont][2]) == "LK9_UFEMIS"	)

				lCpoNobr:= 	(Alltrim(aCampos[nCont][2]) == "LK9_CIDPA" )	// Campos nao obrigatorios

				If cClassTe == '1' .AND. (lCpoPac .AND. lVldCpoPac) .or. ( !lVldCpoPac .AND. lCpoAntM )	// Guia SNGPC V2.0 regra Antimicrobiano - Dados do Paciente Obrigatorio
					If Alltrim(M->&(aCampos[nCont][2])) == ''
	    				MsgAlert( "Campo [" + Alltrim( aCampos[nCont][1])  + "]  de " + IIF( !lVldCpoPac, "Paciente/" , "") + "Uso Prolong. s�o obrigatorios para medicamento AntiMicrobiano.")
				    	lEmBranco := .T.
	    				EXIT
					Endif

				ElseIf cClassTe == '2'  .AND. lCpoComp  // Guia SNGPC V2.0 regra Sujeito a Controle Especial - Dados do comprador Obrigatorio
					If	Alltrim(M->&(aCampos[nCont][2])) == '' 
	    					MsgAlert("Campo [" + Alltrim( aCampos[nCont][1])  + "] de Comprador/Cliente s�o obrigatorios para medicamento Sujeito a Controle Especial.") 
						lEmBranco := .T.
						EXIT
					EndIf
				EndIf

				if !lCpoComp .AND. !lCpoPac  .AND. !lCpoAntM .AND. (!Empty(cClassTe) .AND. !lCpoNobr)
					MsgAlert("O preenchimento do campo " + Alltrim(aCampos[nCont][1]) + " � obrigatorio")
					lEmBranco := .T.
					EXIT
				EndIf

		    Else
		    	// Guia SNGPC V2.0 regra 4.1.4 , Item 7
		    	If Alltrim(aCampos[nCont][2]) == "LK9_TIPUSO"
		    		If M->&(aCampos[nCont][2]) == '2'  // Veterinario
		    			If nCONPROF > 0
							M->&(aCampos[nCONPROF][2] ):= "CRMV"
						EndIf
						
					ElseIf M->&(aCampos[nCont][2]) == '1' .AND. IIF( nCONPROF > 0, Alltrim(M->&(aCampos[nCONPROF][2])) == "CRMV", .F.)
						If nCONPROF > 0
							M->&(aCampos[nCONPROF][2] ):= "CRM"
						EndIf									   
				    	MsgAlert("Para uso humano , conselho CRMV n�o permitido") 
				    	lEmBranco := .T.
				    	EXIT
				    EndIf
				EndIf
								    			
				// Guia SNGPC V2.0 regra 4.1.4 � Cria��o da indica��o de uso prolongado
			    If Alltrim(aCampos[nCont][2]) == "LK9_USOPRO"
			    	If cClassTe == '2'// Sujeito a controle especial n�o precisa informar
						M->&(aCampos[nCont][2] ):= "" 									   
					EndIf	
				EndIf
				
		    	// Covisa - Movimentacao Saida -  Verificacao receita fora estado 
		    	If Alltrim(aCampos[nCont][2]) == "LK9_UFEMIS"
		    		If (cVdForaAu == '2' ) .AND.( M->&(aCampos[nCont][2]) <> SM0->M0_ESTCOB)  
				    	MsgAlert("Venda deste medicamento n�o permitida, fora da UF de Emiss�o") 
				    	lEmBranco := .T.
				    	EXIT
				    ELseIF 	(cVdForaAu == '1' ) .AND.( M->&(aCampos[nCont][2]) <> SM0->M0_ESTCOB)
				    	MsgAlert("Venda deste medicamento permitida, mas fora da UF de Emiss�o") 
				    EndIf	
				EndIf
				
				/* 
		    	// Covisa - Movimentacao Saida -  Verificacao data da receita 
		    	If Alltrim(aCampos[nCont][2]) == "LK9_DATARE" 
		    		If Date() > ( M->&(aCampos[nCont][2]) + nDiasValid)    
				    	MsgAlert("Venda desta Receita n�o permitida, fora da data de vig�ncia") 
				    	lEmBranco := .T.
				    	EXIT
				    EndIf	
				EndIf
				*/
				
		    	// Covisa - Movimentacao Saida -  Verificacao data da receita por tipo  
		    	If Alltrim(aCampos[nCont][2]) == "LK9_DATARE" 

		    		If cClassTe == '1'  // // Guia SNGPC V2.0 regra Antimicrobiano - Cheka validade
		    			If Date() > ( M->&(aCampos[nCont][2]) + nDiasValid)     
		    				MsgAlert("Venda desta Receita tipo (antiMicroBiano) n�o permitida, fora da data de vig�ncia") 
		    				lEmBranco := .T.
		    				EXIT							
		    			Endif		
		    		EndIf		

		    		cComple :=  Posicione("LX5",1,xFilial("LX5")+"T8" + cCodLis,"LX5->LX5_COMPLE")		    		
		    		If !Empty(cComple) .AND. Date() > ( M->&(aCampos[nCont][2]) + Val(cComple))    
				    	MsgAlert("Venda desta Receita tipo " + cCodLis + " n�o permitida, fora da data de vig�ncia") 
				    	lEmBranco := .T.
				    	EXIT
				    EndIf
				EndIf
				
				//Campos n�o virtuais que tamb�m precisam ser validados
				If nNumID > 0 .AND. AllTrim(aCampos[nCont][2]) == "LK9_TIPOID"
					If  AllTrim(M->&(aCampos[nCont][2])) == '2'
						cContNumID := AllTrim(M->&(aCampos[nNumID][2]))
						If	(Val(cContNumID) == 0) .Or.;
							(Val(SubStr(cContNumID,1,7)) == 0)
							
							MsgAlert("Conte�do inv�lido para o campo Numero da Identifica��o (LK9_NUMID) " +;
									" segundo o documento escolhido [2 - Carteira Identidade] - Digite somente n�meros")
							M->&(aCampos[nNumID][2]) := Space(TamSX3("LK9_NUMID")[1])
							lEmBranco := .T.
							Exit
						EndIf
					EndIf
				EndIf
			Endif
		Endif

		//Resetar Vari�veis
		lCpoPac	:= .F. 
		lCpoComp:= .F.
	Next nCont 
Endif 

If !lEmBranco
	lRetorno := .T.
Endif

Return lRetorno

/*������������������������������������������������������������������������������
���Programa  �DROCheckCampo �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Verifica a existencia da informacao na Tabela de Parametros.   ���
����������������������������������������������������������������������������͹��
���Uso       �Validacao de campo                                             ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Conteudo digitado no campo                             ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpL1 - Conteudo digitado encontrado ou nao	                 ���
������������������������������������������������������������������������������*/
Template Function DROCheckCampo(cConteudo)
Local lRet 		:= .T.								//Retorno da funcao
Local cCampo  	:= AllTrim(Substr(ReadVar(),4))    //Campo a ser procurado na tabela LXB
Local cTabela 	:= ""								//Tabela de Pesquisa

If Empty(cConteudo)
	lRet := .F.
Endif

If lRet
	DbSelectArea("LXB")
	LXB->(DbSetOrder(1))
	If LXB->(DbSeek(xFilial()+ cCampo ))
		cTabela := LXB->LXB_TABELA
		DbSelectArea("LX5")
		LX5->(DbSetOrder(1))
		If !LX5->(DbSeek( xFilial("LX5") + cTabela + cConteudo ))
			MsgAlert("N�o existe registro relacionado a este c�digo. Favor verificar.")
			lRet := .F.
		EndIf	
	EndIf
Endif

Return lRet  

/*������������������������������������������������������������������������������
���Programa  �DROVldCampo   �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Validacao a ser executada nos campos da tela ANVISA            ���
����������������������������������������������������������������������������͹��
���Uso       �Validacao de campo                                             ���
����������������������������������������������������������������������������͹��
���Parametros�NIL                                                            ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpC1 - validacao a ser executada          	                 ���
������������������������������������������������������������������������������*/
Template Function DROVldInfo()
Local cCampo 	:= AllTrim(Substr(ReadVar(),4))    //Campo a ser validado
Local cX3_VALID := ""								//Validacao a ser executada
Local lMvLjPdvPa:= LjxBGetPaf()[2] //Indica se � pdv
Local xRet		:= NIL  

SX3->( DbSetOrder( 2 ) )
If SX3->( DbSeek( PadR(cCampo,10) ) ) 
	If (SX3->X3_CAMPO == PadR("LK9_LOTE",10)) .AND. nModulo <> 23
		If lMvLjPdvPa		//Ver se pega
		  	cX3_VALID := "DROVldLote()"
		Else              
			If IsInCallStack("LOJA701")
				cX3_VALID := "Lj7Lote( Nil,M->LK9_LOTE,Nil,Nil,M->LK9_CODPRO)"
			Else             
				//Este valid tambem � chamado da fun��o do DroAxCadastro para lancamento manual de perda
			    cX3_VALID := "T_DroVerLote(M->LK9_CODPRO,M->LK9_LOTE)"
			EndIf	
		EndIf
	Else
	    If !Empty(SX3->X3_VLDUSER)
			cX3_VALID := IIF(Empty(SX3->X3_VALID), "" , AllTrim(SX3->X3_VALID) + " .AND. ") + SX3->X3_VLDUSER
		Else
			cX3_VALID := AllTrim(SX3->X3_VALID)
		EndIf
	EndIf

	If AllTrim(SX3->X3_CAMPO) == "LK9_TIPUSO"
		cX3_VALID += IIf(!Empty(cX3_VALID), " .AND. ", "") + "T_DroVlCpUso()"
	EndIf
Endif

xRet := &(cX3_VALID)

Return xRet

/*����������������������������������������������������������������������������
���Programa  �DroCapANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Captura do cliente ja' informado anteriormente na tela da    ���
���          �ANVISA                                                       ���
��������������������������������������������������������������������������͹��
���Uso       �DROAXCADASTRO - funcao DroVSNGPC()                           ���
��������������������������������������������������������������������������͹��
���Parametros�ExpA1 - Array contendo os campos relacionados a ANVISA       ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpA1 - Array contendo informacoes do cliente indicado       ���
���          �       anteriormente                                         ���
����������������������������������������������������������������������������*/
Template Function DroCapANVISA(aCampos)
Local nCont	:= 0	//Controle de loop
Local aAux	:= {}	//Array auxiliar 
Local aTemp := {}	//Array Temporario

If nModulo == 23
	aTemp := aANVISA
ElseIf nModulo == 12
	aTemp := aAuxANVISA
Endif
//�������������������������������������������������������������Ŀ
//�Caso a tela da ANVISA seja solicitada novamente via tecla F12�
//�Mantem as informacoes do cliente anterior.                   �
//���������������������������������������������������������������
If Len(aTemp) > 0
	For nCont := 1 to Len(aCampos)-9
		aAdd(aAux, aTemp[Len(aTemp)][nCont])
	Next nCont
Endif

Return aAux

/*����������������������������������������������������������������������������
���Programa  �DroLenANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Verifica o comprimento do array aANVISA(array do tipo STATIC)���
��������������������������������������������������������������������������͹��
���Uso       �TPLDROPE    - funcoes: LJ7003(), LJ7016(), FRTFuncoes() e    ���
���          �              LJ7036() 									   ���
���          �DROVLDFUNCS - funcoes: DroAtuANVISA() e DroInfLote()         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Retorno   �ExN1 - Tamanho do array aANVISA                              ���
����������������������������������������������������������������������������*/
Template Function DroLenANVISA()
Local nLenArray := 0		//Tamanho do array aANVISA

nLenArray := Len(aANVISA)

Return nLenArray

/*������������������������������������������������������������������������������
���Programa  �DROCancANVISA �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Delecao dos registros na tabela LK9 quando uma venda for	     ���
���          �CANCELADA.                                                     ���
���          �Servira' tanto para a dos registros do PDV quanto da           ���
���          �RETAGUARDA, dependendo apenas o local de onde sera' chamada	 ���
����������������������������������������������������������������������������͹��
���Uso       �DROVLDFUNCS - funcao DroGrvANVISA()                            ���
���          �TPLDROPE    - funcoes: LJ140DEL()  e LJ140EXC()                ���
����������������������������������������������������������������������������͹��
���Chamada   �FRTA010B - funcao FRTCancela() 								 ���
���          �TPLDROPE - funcao LJ140DEL()  				                 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se executa ou nao a rotina                      ���
���          �ExpL2 - Indica se esta' sendo acionado pelo FRONT LOJA via JOB ���
����������������������������������������������������������������������������͹��
���Retorno   �                       	                                     ���
������������������������������������������������������������������������������*/
Template Function DROCancANVISA(lExecuta, lJob)
Local nIndex    := 0		//Indice a ser utilizado
Local nTamLK9DOC:= 0        // Tamanho do campo LK9_DOC
Local cChaveSL1 := ""		//Expressao para chave SL1
Local cChaveLK9 := ""		//Expressao para chave LK9

DEFAULT lExecuta := .T.
DEFAULT lJob	 := .F.	   

If AliasIndic("LK9")
	If lExecuta      

		nTamLK9DOC:= TamSx3("LK9_DOC")[1]
	
		If nModulo == 12
			If lJob
				nIndex := 1
				cChaveSL1 := xFilial("LK9")+DtoS(SL1->L1_EMISSAO)+Subs(SL1->L1_DOC,1,nTamLK9DOC)+SL1->L1_SERIE
				cChaveLK9 := 'xFilial("LK9")+DtoS(LK9_DATA)+LK9_DOC+LK9_SERIE'		
			Else
				nIndex := 4
				cChaveSL1 := xFilial("LK9")+DtoS(SL1->L1_EMISSAO)+SL1->L1_NUM
				cChaveLK9 := 'xFilial("LK9")+DtoS(LK9_DATA)+LK9_NUMORC'
			Endif	
		ElseIf nModulo == 23
			nIndex := 1
			cChaveSL1 := xFilial("LK9")+DtoS(SL1->L1_EMISSAO)+Subs(SL1->L1_DOC,1,nTamLK9DOC)+SL1->L1_SERIE
			cChaveLK9 := 'xFilial("LK9")+DtoS(LK9_DATA)+LK9_DOC+LK9_SERIE'
		Endif
	 	DbSelectArea("LK9")
		LK9->(DbClearFilter())	
		LK9->(DbSetOrder(nIndex))
		If LK9->(DbSeek(cChaveSL1))			
			While !(LK9->(Eof())) .AND. (&(cChaveLK9) == cChaveSL1) .AND. (LK9->LK9_TIPMOV == "2")
			
				RecLock("LK9", .F.)
				If FunName() == "LOJA140"
					If LK9->LK9_STATUS == "2"
						REPLACE LK9->LK9_STATUS WITH "1"
					ElseIf LK9->LK9_STATUS == "1" .OR. LK9->LK9_STATUS == "3"
						LK9->(DbDelete())
					Endif
                                                                                    // Sem Venda
				ElseIf FunName()=="RPC:JOB"  .AND. Alltrim(SL1->L1_DOC) <> "" .AND. LK9->LK9_STATUS == "1"
					REPLACE LK9->LK9_STATUS WITH "2"
					REPLACE LK9->LK9_DOC    WITH SL1->L1_DOC
					REPLACE LK9->LK9_SERIE  WITH SL1->L1_SERIE                      // Com Venda
				ElseIf FunName()=="RPC:JOB"  .AND. Alltrim(SL1->L1_DOC) <> "" .AND. LK9->LK9_STATUS == "2"
					REPLACE LK9->LK9_STATUS WITH "1"
					REPLACE LK9->LK9_DOC    WITH ""
					REPLACE LK9->LK9_SERIE  WITH ""
				Else  
					LK9->(DbDelete())
				Endif
				LK9->(MsUnLock())
			    LK9->(DbSkip())
			End
		Endif
	Endif
Endif
	
Return 

/*����������������������������������������������������������������������������
���Programa  �DroAtuANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Atualiza o array ANVISA                                      ���
��������������������������������������������������������������������������͹��
���Uso       �TPLDROPE - funcao LJ7036()                                   ���
��������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Numero do Orcamento                                  ���
���          �ExpC2 - Numero do Documento                                  ���
���          �ExpC3 - Numero da Serie                                      ���
���          �ExpN4 - ITEM                                                 ���
���          �ExpC5 - Codigo do Produto                                    ���
���          �ExpN6 - Quantidade                                           ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroAtuANVISA( cNumOrc , cNumDoc, cNumSerie, nItem,;
								cCodProd, nQuant,lF12 )			

Local cUM	     := ""		//Unidade de Medida do produto		
Local cDescProd  := ""		//Descricao do produto	
Local nTamANVISA := 0		//Tamanho do array aANVISA        
Local nLinha	 := 0		//Linha do aANVISA
Local cRegMS     := ""		//Registro do Ministerio da Saude
Local cClassTer	 := ""      // Classe Terapeutica
Local nI		 := 0

Default lF12 := .F.

If ValType(nItem) == "C"
	nItem := Val(nItem)
Endif

If NMODULO == 12
	DbSelectArea("SB1")                 
	SB1->( DbSetOrder(1) )
	SB1->( DbSeek(xFilial("SB1") + cCodProd) )
	cUM 	  := B1_UM
	cDescProd := B1_DESC
	cRegMS    := B1_REGMS
	cClassTer := B1_CLASSTE
Else
	DbSelectArea("SBI")
	SBI->( DbSetOrder(1) )
	SBI->( DbSeek(xFilial("SBI") + cCodProd) )
	cUM 	  := SBI->BI_UM
	cDescProd := SBI->BI_DESC
	cRegMS    := SBI->BI_REGMS
	cClassTer := SBI->BI_CLASSTE
EndIf

If AllTrim(cClassTer) == ""
	cClassTer := "2"
Endif

nTamANVISA := T_DroLenANVISA() 

If nTamANVISA > 0
	If T_DroExisANVISA(nItem)
		nLinha := T_DroPosANVISA(nItem)		
	Else
		aAdd(aANVISA, ARRAY(TAMANVISA))
		// campos de usuario
		If Len(aAuxLK9Usr) > 0
			aAdd(aLK9Usr, {})
		EndIf
		nLinha := T_DroLenANVISA()
	Endif
Else	
	aAdd( aANVISA, ARRAY(TAMANVISA) )
	nLinha := T_DroLenANVISA()	
	// campos de usuario
	If Len(aAuxLK9Usr) > 0
		aAdd(aLK9Usr, {})
	EndIf
Endif

If Len(aAuxANVISA) > 0 // pode estar vazia por ter vindo de uma recuperacao de venda

	aANVISA[nLinha][NOME] 		:= aAuxANVISA[1][NOME]      //1		//Nome do cliente
	aANVISA[nLinha][TIPOID] 	:= aAuxANVISA[1][TIPOID]    //2		//Tipo de identificacao do cliente
	aANVISA[nLinha][NUMID] 		:= aAuxANVISA[1][NUMID]     //3		//Numero de identificacao do cliente
	aANVISA[nLinha][ORGEXP] 	:= aAuxANVISA[1][ORGEXP]    //4		//Orgao Expedidor
	aANVISA[nLinha][UFEMIS] 	:= aAuxANVISA[1][UFEMIS]    //5		//Unidade Federatica
	aANVISA[nLinha][RECEITA] 	:= aAuxANVISA[1][RECEITA]   //6		//Numero da receita medica
	aANVISA[nLinha][TPRECEITA] 	:= aAuxANVISA[1][TPRECEITA] //7		//Tipo da receita medica
	aANVISA[nLinha][TPUSO] 		:= aAuxANVISA[1][TPUSO]     //8		//Tipo de uso da receita medica
	aANVISA[nLinha][DATRECEITA]	:= aAuxANVISA[1][DATRECEITA]//9		//Data da receita medica
	aANVISA[nLinha][MEDICO] 	:= aAuxANVISA[1][MEDICO]    //10	//Nome do medico
	aANVISA[nLinha][CRM] 		:= aAuxANVISA[1][CRM]       //11	//CRM do medico
	aANVISA[nLinha][CONPROF] 	:= aAuxANVISA[1][CONPROF]   //12	//Conselho profissional do medico
	aANVISA[nLinha][UFCONS] 	:= aAuxANVISA[1][UFCONS]    //13	//Unidade federativa do conselho profissional do medico
	If !lF12
		aANVISA[nLinha][LOTEPROD] := aAuxANVISA[1][LOTEPROD]  //14	//Lote
	EndIf	
	aANVISA[nLinha][PRODUTO] 	:= cCodProd 				 //15	//Codigo do produto
	aANVISA[nLinha][QTDEPROD] 	:= nQuant 				 	 //16 	//Quantidade 
	aANVISA[nLinha][NUMORC] 	:= cNumOrc				 	 //17	//Numero do Orcamento
	aANVISA[nLinha][NUMDOC] 	:= cNumDoc				 	 //18	//Numero do Documento
	aANVISA[nLinha][SERIE] 		:= cNumSerie				 //19	//Serie do Documeto
	aANVISA[nLinha][UM] 		:= cUM	   				 	 //20	//Unidade de Medida do produto  
	aANVISA[nLinha][DESCPRO] 	:= cDescProd				 //21	//Descricao do produto  
	aANVISA[nLinha][IDANVISA] 	:= nItem					 //22	//ID que faz referencia ao array aItens localizado no FRTA010
	aANVISA[nLinha][REGMS] 	    := cRegMS	 				 //23	//Registro do produto no Ministerio da Saude
	aANVISA[nLinha][ENDERECO]	:= aAuxANVISA[1][15]  		//24 Endereco do cliente
	aANVISA[nLinha][NPACIENTE]	:= aAuxANVISA[1][16]  		//25 Nome do Paciente
	aANVISA[nLinha][CLASSTERAP]	:= cClassTer  				//26 Class Terapeutica
	aANVISA[nLinha][USOPROLONG]	:= aAuxANVISA[1][17]  		//27 Uso Prolongado
	aANVISA[nLinha][IDADEP]		:= aAuxANVISA[1][18] 		//28 Idade Paciente  
	aANVISA[nLinha][UNIDAP]		:= aAuxANVISA[1][19] 		//29 Unidade Idade 
	aANVISA[nLinha][SEXOPA]		:= aAuxANVISA[1][20] 		//30 Sexo Paciente
	aANVISA[nLinha][CIDPA]		:= aAuxANVISA[1][21] 		//31 CId Paciente
	aANVISA[nLinha][QUANTP]		:= aAuxANVISA[1][22] 		//32 Quantidade prescrita

	If Len(aAuxLK9Usr) > 0
		For nI := 1 to Len(aAuxLK9Usr)	//quantidade de campos customizados
			aLK9Usr[nLinha] := aClone( aAuxLK9Usr[nI] )
		Next
	Endif

EndIf
	
Return

/*����������������������������������������������������������������������������
���Programa  �DroAuxANVISA�Autor  �Vendas Clientes     � Data �  20/12/06  ���
��������������������������������������������������������������������������͹��
���Desc.     �Adiciona informacoes do medico e do cliente no array aANVISA ���
��������������������������������������������������������������������������͹��
���Uso       �DROVLDFUNCS - funcao DroTempLK9()                            ���
��������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica que a tela da ANVISA foi acionada automatica- ���
���          �        mente apos informar o produto controlado             ���
���          �ExpA2 - Array contendo os campos a serem gravados            ���
���          �ExpL3 - Indica que a tela ANVISA foi acionada via tecla F12  ���
��������������������������������������������������������������������������͹��
���Retorno   �                                                             ���
����������������������������������������������������������������������������*/
Template Function DroAuxANVISA( lTela, aCampos, lAtalho )

Local nCont  	:= 0		//Controle de loop
Local nLinha  	:= 0		//Linha do array a ser utilizada
Local aDroPELK9	:= {}

/* Se lDadosTela = .F., nao e' utilizado o array aCampos */
If lTela .OR. lAtalho
	
	// verifica se possui campo de usuario
	If ExistBlock("DROPELK9")
		aDroPELK9 := ExecBlock("DROPELK9",.F.,.F.,{{}})
		If ValType(aDroPELK9) <> "A"
			aDroPELK9 := {}
		EndIf
	EndIf

	If lAtalho
		lInformouLote := .F.	//Indica que sera' necessario informar o lote na digitacao do produto
	EndIf

	aAuxANVISA := {}
	aAdd(aAuxANVISA , {})

	nLinha := Len(aAuxANVISA)

	For nCont := 1 to Len(aCampos)
		aAdd(aAuxANVISA[nLinha], M->&(aCampos[nCont][2])  )
	Next nCont

	If Len(aDroPELK9) = 2
		aAuxLK9Usr := {}
		aAdd(aAuxLK9Usr	, {})

		For nCont := 1 to Len(aDroPELK9[2])
			aAdd( aAuxLK9Usr[nLinha], { aDroPELK9[2][nCont], M->&(aDroPELK9[2][nCont]) } )
		Next nCont
	EndIf

	//Precisei proteger o 'n', pois pode ter casos que vem da tela exclusiva de aprova��o dos medicamentos.
	If FunName() == "LOJA701".AND. Type("n") = "N" .AND. n <= Len(aColsDet) // Segunda condicao para caso o usuario nao tenha informado o codigo do produto no acols, apenas adicionado nova linha.
		LJ7AtuLote(M->LK9_LOTE)
	EndIf
Else
	lInformouLote := .F.		//Indica que sera' necessario informar o lote na digitacao do produto	
Endif

Return NIL

/*������������������������������������������������������������������������������
���Programa  �DroExisANVISA �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Verifica se ID existe no array ANVISA                          ���
����������������������������������������������������������������������������͹��
���Uso       �DROVLDFUNCS - funcao DroAtuANVISA()                            ���
����������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Codigo do item                                         ���
����������������������������������������������������������������������������͹��
���Retorno   �                       	                                     ���
������������������������������������������������������������������������������*/
Template Function DroExisANVISA(nItem)
Local lRet		:= .F.		//Retorno da funcao
Local nPosId	:= 0		//Posicao do item no array aANVISA	

If ValType(nItem) == "C"
	nItem := Val(nItem)
Endif

nPosId := Ascan(aANVISA,{|x| x[IDANVISA] == nItem })

If nPosId > 0  	
	lRet := .T.
Endif 

Return lRet
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �DroPosANVISA  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Retorna a posicao do ID no array ANVISA                        ���
����������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                             ���
����������������������������������������������������������������������������͹��
���Chamada   �DROVLDFUNCS - funcao DroAtuANVISA()                            ���
����������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Codigo do item                                         ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpN1 - Posicao do item no array aANVISA	                     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Template Function DroPosANVISA(nItem)
Local nPosId	:= 0		//Posicao do item no array aANVISA	

If ValType(nItem) == "C"
	nItem := Val(nItem)
Endif

nPosId := Ascan(aANVISA,{|x| x[IDANVISA] == nItem })

Return nPosId

/*������������������������������������������������������������������������������
���Programa  �DroInfLote    �Autor  �Vendas Clientes     � Data �  20/12/06  ���
����������������������������������������������������������������������������͹��
���Desc.     �Para a rotina de venda da Venda Assistida, e' verificado a     ���
���          �situacao em que o usuario confirma a mesma linha do aCols      ���
���          �mais de uma vez. Caso isso ocorra, nao e' necessario executar  ���
���          �todas as funcoes relacionadas a ANVISA novamente               ���
����������������������������������������������������������������������������͹��
���Uso       �FRTA010B - funcao FRTCancela()                                 ���
���          �TPLDROPE - funcao LJ140DEL()    				                 ���
����������������������������������������������������������������������������͹��
���Parametros�NIL                                                            ���
����������������������������������������������������������������������������͹��
���Retorno   �                       	                                     ���
������������������������������������������������������������������������������*/
Template Function DroInfLote()
Local cLote	  := ""		//Lote do produto
Local nLinha  := 0		//Linha do array a ser utilizada
Local cTemp   			// Sem tipo definido , pode ser Array ou Caracter 
Local cUsoPro := "2"	// Uso Prolongado

If !lInformouLote
	nLinha := T_DroLenANVISA() 
		
	cTemp  := T_DroLoteANVISA()
	If Valtype(cTemp) == "A" 
		cLote		:= cTemp[1]  
		cUsoPro	:= cTemp[2]
	Else
		cLote		:= cTemp  
	EndIf
	
	aANVISA[nLinha][LOTEPROD] 	:= cLote 	//Lote
	aANVISA[nLinha][USOPROLONG] := cUsoPro	//Uso Prolongadoo

	If FunName() == "LOJA701"
		LJ7AtuLote(cLote)
	EndIf
Endif

Return NIL

/*�������������������������������������������������������������������������������
���Programa  �DroRestANVISA  �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Restaura as informacoes referentes a ANVISA para dar            ���
���          �continuidade a venda                                            ���
�����������������������������������������������������������������������������͹��
���Uso       �TPLDROPE - funcao LJ7016()                                      ���
�����������������������������������������������������������������������������͹��
���Parametros�                                                                ���
�����������������������������������������������������������������������������͹��
���Retorno   �                       	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroRestANVISA()
Local nLinha	:= 0			//Linha do array a ser utilizada
Local nI		:= 0
Local aDroPELK9 := {}

// verifica se possui campo de usuario
If ExistBlock("DROPELK9")
	LjGrvLog("DROVLDFUNCS","Antes da execu��o do PE DROPELK9")
	aDroPELK9 := ExecBlock("DROPELK9",.F.,.F.,{{}})
	LjGrvLog("DROVLDFUNCS","Depois da execu��o do PE DROPELK9",aDroPELK9)
	If ValType(aDroPELK9) <> "A"
		aDroPELK9 := {}
	EndIf
EndIf

aANVISA	   := {}			//Inicializa o array aANVISA
aAuxANVISA := {}			//Inicializa o array Auxiliar aANVISA

aLK9Usr	   := {}
aAuxLK9Usr := {}

DbSelectArea("LK9")
LK9->( DbSetOrder(4) )	//FILIAL+DATA+NUMORC
If LK9->( DbSeek(xFilial("SL1") + DtoS(SL1->L1_EMISSAO) + SL1->L1_NUM) )
	While LK9->(!EoF()) .AND. (LK9_FILIAL + DtoS(LK9_DATA) + LK9_NUMORC == xFilial("SL1")+DtoS(SL1->L1_EMISSAO) + SL1->L1_NUM)

		aAdd(aANVISA, ARRAY(TAMANVISA))
		aAdd(aLK9Usr, {})

		nLinha := T_DroLenANVISA()

		//���������������������������Ŀ
		//�Restaurando o array aANVISA�
		//�����������������������������
		aANVISA[nLinha][NUMORC]     := LK9->LK9_NUMORC
		aANVISA[nLinha][NUMDOC]     := LK9->LK9_DOC
		aANVISA[nLinha][SERIE]      := LK9->LK9_SERIE
		aANVISA[nLinha][NOME]       := LK9->LK9_NOME		
		aANVISA[nLinha][TIPOID]     := LK9->LK9_TIPOID
		aANVISA[nLinha][NUMID]      := LK9->LK9_NUMID
		aANVISA[nLinha][ORGEXP]     := LK9->LK9_ORGEXP
		aANVISA[nLinha][UFEMIS]     := LK9->LK9_UFEMIS
		aANVISA[nLinha][RECEITA]    := LK9->LK9_NUMREC
		aANVISA[nLinha][TPRECEITA]  := LK9->LK9_TIPREC
		aANVISA[nLinha][TPUSO]      := LK9->LK9_TIPUSO 
		aANVISA[nLinha][DATRECEITA] := LK9->LK9_DATARE
		aANVISA[nLinha][MEDICO]     := LK9->LK9_NOMMED
		aANVISA[nLinha][CRM]        := LK9->LK9_NUMPRO
		aANVISA[nLinha][CONPROF]    := LK9->LK9_CONPRO
		aANVISA[nLinha][UFCONS]     := LK9->LK9_UFCONS
		aANVISA[nLinha][PRODUTO]    := LK9->LK9_CODPRO
		aANVISA[nLinha][DESCPRO]    := LK9->LK9_DESCRI		
		aANVISA[nLinha][UM]         := LK9->LK9_UM
		aANVISA[nLinha][QTDEPROD]   := LK9->LK9_QUANT
		aANVISA[nLinha][LOTEPROD]   := LK9->LK9_LOTE
		aANVISA[nLinha][IDANVISA]   := nLinha
		aANVISA[nLinha][REGMS]      := LK9->LK9_REGMS 
		aANVISA[nLinha][ENDERECO]   := LK9->LK9_END
		aANVISA[nLinha][NPACIENTE]  := LK9->LK9_NOMEP
		aANVISA[nLinha][USOPROLONG] := LK9->LK9_USOPRO
		aANVISA[nLinha][IDADEP]		:= LK9->LK9_IDADEP
		aANVISA[nLinha][UNIDAP]		:= LK9->LK9_UNIDAP
		aANVISA[nLinha][SEXOPA]		:= LK9->LK9_SEXOPA
		aANVISA[nLinha][CIDPA]		:= LK9->LK9_CIDPA 
		aANVISA[nLinha][QUANTP]		:= LK9->LK9_QUANTP
		aANVISA[nLinha][CLASSTERAP]	:= LK9->LK9_CLASST

		If Len(aDroPELK9) == 2
			For nI := 1 to Len(aDroPELK9[2])
				aAdd( aLK9Usr[nLinha], {aDroPELK9[2][nI], &(aDroPELK9[2][nI])} )
			Next
		EndIf

		LK9->( DbSkip() )
	End

	aAuxANVISA := {ARRAY(TAMAUXANVISA)}
	//����������������������������������������������������������������������������������Ŀ
	//�Restaurando o array aAuxANVISA (refente a informacoes do cliente, medico, receita)�
	//�Sempre restaura com as informacoes do ultimo item informado na venda              |
	//������������������������������������������������������������������������������������
	aAuxANVISA[1][NOME]			:= aANVISA[nLinha][NOME]      //1		Nome do cliente
	aAuxANVISA[1][TIPOID]		:= aANVISA[nLinha][TIPOID]    //2		Tipo de identificacao do cliente
	aAuxANVISA[1][NUMID]		:= aANVISA[nLinha][NUMID]     //3		Numero de identificacao do cliente
	aAuxANVISA[1][ORGEXP]		:= aANVISA[nLinha][ORGEXP]    //4		Orgao Expedidor
	aAuxANVISA[1][UFEMIS]		:= aANVISA[nLinha][UFEMIS]    //5		Unidade Federatica
	aAuxANVISA[1][RECEITA]		:= aANVISA[nLinha][RECEITA]   //6		Numero da receita medica
	aAuxANVISA[1][TPRECEITA]	:= aANVISA[nLinha][TPRECEITA] //7		Tipo da receita medica
	aAuxANVISA[1][TPUSO]		:= aANVISA[nLinha][TPUSO]     //8		Tipo de uso da receita medica
	aAuxANVISA[1][DATRECEITA]	:= aANVISA[nLinha][DATRECEITA]//9		Data da receita medica
	aAuxANVISA[1][MEDICO]		:= aANVISA[nLinha][MEDICO]    //10		Nome do medico
	aAuxANVISA[1][CRM]			:= aANVISA[nLinha][CRM]       //11		CRM do medico
	aAuxANVISA[1][CONPROF]		:= aANVISA[nLinha][CONPROF]   //12		Conselho profissional do medico
	aAuxANVISA[1][UFCONS]		:= aANVISA[nLinha][UFCONS]    //13		Unidade federativa do conselho profissional do medico
	aAuxANVISA[1][LOTEPROD]		:= aANVISA[nLinha][LOTEPROD]  //14		Lote	
	aAuxANVISA[1][PRODUTO]		:= aANVISA[nLinha][PRODUTO]   //15		Codigo do Produto	
	aAuxANVISA[1][QTDEPROD]		:= aANVISA[nLinha][QTDEPROD]  //16     Quantidade
	aAuxANVISA[1][NUMDOC]		:= aANVISA[nLinha][NUMDOC]	   //17     Numero do Doc
	aAuxANVISA[1][SERIE]		:= aANVISA[nLinha][SERIE]	   //18     Serie do Documeto
	aAuxANVISA[1][UM]	    	:= aANVISA[nLinha][UM]	   	   //19     Unidade de Medida do produto  
	aAuxANVISA[1][DESCPRO]	   	:= aANVISA[nLinha][DESCPRO]   //20     Descricao do Produto 
	aAuxANVISA[1][IDANVISA]	   	:= aANVISA[nLinha][IDANVISA]  //21     ID que faz referencia ao array aItens localizado no FRTA010
	aAuxANVISA[1][NUMORC]	   	:= aANVISA[nLinha][NUMORC]    //22     Numero do Orcamento 
	aAuxANVISA[1][REGMS]	   	:= aANVISA[nLinha][REGMS] 	   //23     Registro do produto no Ministerio da Saude   
	aAuxANVISA[1][ENDERECO]		:= aANVISA[nLinha][15]//24 Endereco do cliente	 					
	aAuxANVISA[1][NPACIENTE]	:= aANVISA[nLinha][16] //25 Nome Paciente
	aAuxANVISA[1][USOPROLONG]	:= aANVISA[nLinha][USOPROLONG]//27 Nome Paciente
	aAuxANVISA[1][IDADEP]		:= aANVISA[nLinha][IDADEP]//28 Idade Paciente 
	aAuxANVISA[1][UNIDAP]		:= aANVISA[nLinha][UNIDAP]//29 Unidade da Idade
	aAuxANVISA[1][SEXOPA]		:= aANVISA[nLinha][SEXOPA]//30 Sexo Paciente
	aAuxANVISA[1][CIDPA]		:= aANVISA[nLinha][CIDPA]//31 Co. Inter. doenca Pac.
	aAuxANVISA[1][QUANTP]		:= aANVISA[nLinha][QUANTP]//32 Quantidade Prescrita

Endif     

Return

/*�������������������������������������������������������������������������������
���Programa  �DroDocSerie    �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Atualiza Codigo do DOCUMENTO e SERIE no array aANVISA           ���
�����������������������������������������������������������������������������͹��
���Uso       �DROVLDFUNCS - funcao DroGrvANVISA()                             ���
�����������������������������������������������������������������������������͹��
���Parametros�NIL                                                             ���
�����������������������������������������������������������������������������͹��
���Retorno   �NIL                    	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroDocSerie()
Local nLinha := 0		//Controle de loop

For nLinha := 1 to T_DroLenANVISA()
	aANVISA[nLinha][NUMDOC] := SL1->L1_DOC
	aANVISA[nLinha][SERIE]  := SL1->L1_SERIE		
Next nLinha

Return NIL

/*�������������������������������������������������������������������������������
���Programa  �DroEntANVISA   �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Grava informacoes do documento de entrada dos medicamentos      ���
���          �controlados na tabela LK9 - Log's ANVISA                        ���
�����������������������������������������������������������������������������͹��
���Uso       �TPLDROPE - Funcoes: GQREENTR() e MT100GRV()					  ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpL1 - Indica se o documento esta' sendo deletado ou nao       ���
�����������������������������������������������������������������������������͹��
���Retorno   �.T.                    	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroEntANVISA(lDeleta,cOrigem,cListaMed,cProduto)

Local aArea     	:= GetArea()	  			//Area Atual
Local cCodFornec 	:= ""			  			//Codigo do Fornecedor
Local cLojFornec    := ""			  			//Loja do Fornecedor
Local cCNPFFornec	:= ""			   			//CNPJ do Fornecedor		
Local cDesc			:= ""
Local cREGMS  		:= ""
Local cClassT 		:= ""
Local cTipoMov		:= ""
Local cCaixaSup 	:= LjGetSup()
Local nSaldoEst		:= 0 

DEFAULT cOrigem		:= ""
DEFAULT cListaMed	:= ""
DEFAULT cProduto	:= ""

// Se deletar a nota , nao exclui a lk9 , mas inclui um mov de estorno (COVISA 2015)
If lDeleta
 	cTipoMov := "7"
 	lDeleta	 := .F.
Else
	cTipoMov := "1" 	
EndIf


If AliasIndic("LK9")

	If Empty(cOrigem) 
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
			cCNPFFornec := SA2->A2_CGC
		Endif
		
		DbselectArea("SD1")
		DbSetOrder(1)
		If DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			If !lDeleta 
				While !Eof() .AND. xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
									SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA 
					If T_DroVerCont( SD1->D1_COD )
	
						If DbSeek(xFilial("SB1")+SD1->D1_COD)
							cDesc 	:= SB1->B1_DESC
							cREGMS  := SB1->B1_REGMS
							cClassT := SB1->B1_CLASSTE
						EndIf  
	
						RecLock("LK9", .T.)
						REPLACE LK9_FILIAL	WITH xFilial("LK9")
						REPLACE LK9_DATA	WITH dDataBase
						REPLACE LK9_DOC		WITH SD1->D1_DOC
						REPLACE LK9_SERIE	WITH SD1->D1_SERIE
						REPLACE LK9_TIPMOV	WITH cTipoMov
						REPLACE LK9_CNPJFOR	WITH cCNPFFornec
						REPLACE LK9_DATANF	WITH SF1->F1_EMISSAO
						REPLACE LK9_CODPRO	WITH SD1->D1_COD
						REPLACE LK9_DESCRI	WITH cDesc 
						REPLACE LK9_UM		WITH SD1->D1_UM
						REPLACE LK9_QUANT	WITH SD1->D1_QUANT
						REPLACE LK9_CODLIS  WITH SB1->B1_CODLIS
						
						If !Empty(SD1->D1_LOTECTL)
							REPLACE LK9_LOTE	WITH SD1->D1_LOTECTL
						Else
							REPLACE LK9_LOTE	WITH SD1->D1_LOTEFOR
						Endif
		
						REPLACE LK9_REGMS	 WITH cREGMS
						REPLACE LK9_CLASST WITH cClassT // Classe Terapeutica
						REPLACE LK9_TPCAD  WITH "2"
						
						If cTipoMov == "1"
							cDesc  := "Entrada-Doc:" + Alltrim(SD1->D1_DOC) + " Serie:" + SD1->D1_SERIE + " em:" + dToC(dDataBase) 	  
						ElseIf 	cTipoMov == "7"
							cDesc  := "Estorno-Doc:" + Alltrim(SD1->D1_DOC) + " Serie:" + SD1->D1_SERIE + " em:" + dToC(dDataBase)  	  
						EndIf
						REPLACE LK9_OBSPER	 WITH cDesc  	  

						//campos de seguranca
						REPLACE LK9_USVEND  WITH cUserName
						
						//campos de seguranca
						REPLACE LK9_USAPRO  WITH cCaixaSup
						
						LK9->(MsUnLock())
					Endif
					SD1->(DbSkip())
				End
			Else
				If AliasIndic("LK9")
					DbSelectArea("LK9")
					DbSetOrder(1)      
					If DbSeek(xFilial("LK9")+DTOS(SF1->F1_EMISSAO)+SD1->D1_DOC+SD1->D1_SERIE+"1")
						While LK9->(!Eof()) .AND.	(xFilial("LK9") + DTOS(LK9_DATA)		+ LK9_DOC 	  	+ LK9_SERIE == ;
													 SF1->F1_FILIAL + DTOS(SF1->F1_EMISSAO)	+ SF1->F1_DOC	+ SF1->F1_SERIE);
											 .AND.   LK9_TIPMOV == "1"
							//���������������������������������������������������Ŀ
							//�Tratamento para existencia de DOC's e SERIES iguais�
							//�para FORNECEDORES diferentes                       �
							//�����������������������������������������������������
							DbSelectArea("SA2")
							DbSetOrder(3)
							If DbSeek(xFilial("SA2")+LK9->LK9_CNPJFOR)
								cCodFornec := SA2->A2_COD
								cLojFornec := SA2->A2_LOJA
							Endif
							If AllTrim(SF1->F1_FORNECE+SF1->F1_LOJA) == AllTrim(cCodFornec+cLojFornec)
								RecLock("LK9", .F.)
								LK9->(DbDelete())
								LK9->(MsUnLock())
							Endif
							LK9->(DbSkip())
						End
					Endif
				Endif
			Endif
		Endif
	ElseIf cOrigem == "MT340D3"	// Ajuste de Inventario 

		If T_DroVerCont( SD3->D3_COD )// se for produto controlado

			//If DbSeek(xFilial("SB1")+SD3->D3_COD)
				cDesc 	 := SB1->B1_DESC
				cREGMS   := SB1->B1_REGMS
				cClassT  := SB1->B1_CLASSTE
			//EndIf  
	
			RecLock("LK9", .T.)
			REPLACE LK9_FILIAL	WITH xFilial("LK9")
			REPLACE LK9_DATA	WITH dDataBase
			REPLACE LK9_DOC		WITH SD3->D3_DOC
			REPLACE LK9_SERIE	WITH SD3->D3_NUMSERI
			REPLACE LK9_CODLIS  WITH SB1->B1_CODLIS
			
			If SD3->D3_TM == "999"
				REPLACE LK9_TIPMOV	WITH "8"
			ElseIf 	SD3->D3_TM == "499"
				REPLACE LK9_TIPMOV	WITH "9"
			EndIf
			
			//REPLACE LK9_CNPJFOR	WITH cCNPFFornec
			//REPLACE LK9_DATANF	WITH SF1->F1_EMISSAO
			REPLACE LK9_CODPRO	 WITH SB1->B1_COD
			REPLACE LK9_DESCRI	 WITH cDesc 
			REPLACE LK9_UM		 WITH SB1->B1_UM
			REPLACE LK9_QUANT	 WITH SD3->D3_QUANT
			REPLACE LK9_LOTE	 WITH SD3->D3_LOTECTL
			REPLACE LK9_REGMS	 WITH cREGMS   
			REPLACE LK9_OBSPER	 WITH "Inventario " +  Alltrim(SB7->B7_OBSALTE) + " Doc: " + Alltrim(SD3->D3_DOC) + " Tipo Mov: " +  SD3->D3_TM + "-" + SD3->D3_CF + " Seq:" + SD3->D3_NUMSEQ 	  
			REPLACE LK9_OBSALT   WITH Alltrim(SB7->B7_OBSALTE)  	  

			REPLACE LK9_PAGINA	 WITH Alltrim(SB7->B7_PAGINA)
			REPLACE LK9_LIVRO	 WITH Alltrim(SB7->B7_LIVRO)
			REPLACE LK9_CLASST WITH cClassT // Classe Terapeutica
			REPLACE LK9_TPCAD  WITH "2"
					
			//campos de seguranca
			REPLACE LK9_USVEND  WITH SB7->B7_USVENDA
						
			//campos de seguranca
			REPLACE LK9_USAPRO  WITH SB7->B7_USAPRO 
						
			LK9->(MsUnLock())
		Endif
	ElseIf cOrigem == "PRODUTO"	// Mudanca de lista 

		If T_DroVerCont( SB1->B1_COD )

			DbSelectArea( "SB2" )
			If ( DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ))
				nSaldoEst := SB2->B2_QATU
			EndIf 
								 
			cDesc 	 := SB1->B1_DESC
			cREGMS   := SB1->B1_REGMS
			cClassT  := SB1->B1_CLASSTE

			RecLock("LK9", .T.)
			REPLACE LK9_FILIAL	WITH xFilial("LK9")
			REPLACE LK9_DATA	WITH dDataBase
			REPLACE LK9_DOC		WITH "ALTLIS"
			REPLACE LK9_TIPMOV	WITH "D"
			REPLACE LK9_CODPRO	WITH SB1->B1_COD
			REPLACE LK9_DESCRI	WITH cDesc 
			REPLACE LK9_UM		WITH SB1->B1_UM

			REPLACE LK9_QUANT	WITH nSaldoEst
			REPLACE LK9_REGMS	WITH cREGMS   
			REPLACE LK9_OBSPER	WITH "Saida : Altera��o da Lista " + cListaMed + " para " + B1_CODLIS  	  
			REPLACE LK9_OBSALT	WITH Alltrim(SB1->B1_OBSALTE)  	  

			REPLACE LK9_CODLIS  WITH cListaMed

			REPLACE LK9_PAGINA	WITH Alltrim(SB1->B1_PAGINA)
			REPLACE LK9_LIVRO	WITH Alltrim(SB1->B1_LIVRO)   
			REPLACE LK9_CLASST WITH cClassT // Classe Terapeutica
			REPLACE LK9_TPCAD  WITH "2"
						
			//campos de seguranca
			REPLACE LK9_USVEND  WITH cUserName
						
			//campos de seguranca
			REPLACE LK9_USAPRO  WITH cCaixaSup 
					
			LK9->(MsUnLock())

			/// lista destino 
			RecLock("LK9", .T.)
			REPLACE LK9_FILIAL	WITH xFilial("LK9")
			REPLACE LK9_DATA	WITH dDataBase
			REPLACE LK9_DOC		WITH "ALTLIS"
			REPLACE LK9_TIPMOV	WITH "C"
			REPLACE LK9_CODPRO	WITH SB1->B1_COD
			REPLACE LK9_DESCRI	WITH cDesc 
			REPLACE LK9_UM		WITH SB1->B1_UM

			REPLACE LK9_QUANT	WITH nSaldoEst
			REPLACE LK9_REGMS	WITH cREGMS   
			REPLACE LK9_OBSPER	WITH "Entrada : Altera��o da Lista " + B1_CODLIS + " para " +   cListaMed	  
			REPLACE LK9_CODLIS  WITH SB1->B1_CODLIS
			REPLACE LK9_OBSALT	WITH Alltrim(SB1->B1_OBSALTE)  	  
			REPLACE LK9_CLASST WITH cClassT // Classe Terapeutica
			REPLACE LK9_TPCAD  WITH "2"
						
			//campos de seguranca
			REPLACE LK9_USVEND  WITH cUserName
						
			//campos de seguranca
			REPLACE LK9_USAPRO  WITH cCaixaSup
						
			LK9->(MsUnLock())
		Endif
	ElseIf cOrigem == "INCPROD"	// Inclusao de produto 

		If T_DroVerCont( SB1->B1_COD )

			DbSelectArea( "SB2" )
			If ( DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ))
				nSaldoEst := SB2->B2_QATU
			EndIf
								 
			cDesc 	 := SB1->B1_DESC
			cREGMS   := SB1->B1_REGMS
			cClassT  := SB1->B1_CLASSTE

			RecLock("LK9", .T.)
			REPLACE LK9_FILIAL	WITH xFilial("LK9")
			REPLACE LK9_DATA	WITH dDataBase
			REPLACE LK9_DOC		WITH "INCPRO"
			REPLACE LK9_TIPMOV	WITH "A"
			REPLACE LK9_CODPRO	WITH SB1->B1_COD
			REPLACE LK9_DESCRI	WITH cDesc 
			REPLACE LK9_UM		WITH SB1->B1_UM

			REPLACE LK9_QUANT	WITH nSaldoEst
			REPLACE LK9_REGMS	WITH cREGMS   
			REPLACE LK9_OBSPER	WITH "Inclus�o de medicamento - Lista " + B1_CODLIS  	  
			REPLACE LK9_CODLIS  WITH SB1->B1_CODLIS
			REPLACE LK9_OBSALT	WITH Alltrim(SB1->B1_OBSALTE)  	  

			REPLACE LK9_PAGINA	 WITH Alltrim(SB1->B1_PAGINA)
			REPLACE LK9_LIVRO	 WITH Alltrim(SB1->B1_LIVRO)   
			REPLACE LK9_CLASST WITH cClassT // Classe Terapeutica
			REPLACE LK9_TPCAD  WITH "2"
						
			//campos de seguranca
			REPLACE LK9_USVEND  WITH cUserName
						
			//campos de seguranca
			REPLACE LK9_USAPRO  WITH cCaixaSup 
						
			LK9->(MsUnLock())
		Endif
	ElseIf cOrigem == "MT220GRV"	// Saldo inicial  -- MAta220

		If !Empty(cProduto) .AND. DbSeek(xFilial("SB1")+cProduto)
			If T_DroVerCont( cProduto )
				If DbSeek(xFilial("SB1")+cProduto)
		
					RecLock("LK9", .T.)
					REPLACE LK9_FILIAL	WITH xFilial("LK9")
					REPLACE LK9_DATA	WITH dDataBase
					REPLACE LK9_DOC		WITH "SD.INI"
					REPLACE LK9_CODLIS  WITH SB1->B1_CODLIS
					
					REPLACE LK9_TIPMOV	WITH "B"
					
					REPLACE LK9_CODPRO	 WITH SB1->B1_COD
					REPLACE LK9_DESCRI	 WITH SB1->B1_DESC
					REPLACE LK9_UM		 WITH SB1->B1_UM
					REPLACE LK9_QUANT	 WITH SB2->B2_QATU
					REPLACE LK9_REGMS	 WITH SB1->B1_REGMS  
					REPLACE LK9_OBSPER	 WITH "Saldo Inicial - " + SB9->B9_OBSALTE  
					REPLACE LK9_OBSALT	 WITH Alltrim(SB9->B9_OBSALTE )  	  
					REPLACE LK9_CLASST WITH SB1->B1_CLASSTE // Classe Terapeutica
					REPLACE LK9_TPCAD  WITH "2"
								
					//campos de seguranca
					REPLACE LK9_USVEND  WITH cUserName
								
					//campos de seguranca
					REPLACE LK9_USAPRO  WITH cCaixaSup 
								
					LK9->(MsUnLock())
				Endif
			EndIf	
		EndIf			
	EndIf	
Endif
RestArea(aArea)

Return .T.

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �DroNumLote     �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Chama a tela de detalhes do item para que o codigo do lote seja ���
���          �informado                                                       ���
�����������������������������������������������������������������������������͹��
���Uso		 �Consulta LKC                                                    ���
�����������������������������������������������������������������������������͹��
���Parametros�NIL                                                             ���
�����������������������������������������������������������������������������͹��
���Retorno   �.T.                    	                                      ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Template Function DroNumLote()

If FunName() == "LOJA701"
	Lj7DetItem()
EndIf

Return .T. 

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �DroPegLote     �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Retorna a numeracao do lote                                     ���
�����������������������������������������������������������������������������͹��
���Uso       �Consulta LKC		                                              ���
�����������������������������������������������������������������������������͹��
���Parametros�NIL                                                             ���
�����������������������������������������������������������������������������͹��
���Retorno   �ExpC - LOTE            	                                      ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Template Function DroPegLote()
	Local cRet := ""
	
	If FunName() = "LOJA701"
		cRet := aColsDet[n][Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOTECTL" })] 
	Else
		cRet := M->LK9_LOTE
	EndIf

Return cRet

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �DroTransANVISA �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Gravacao e Exclusao das movimentacoes de transferencias dos     ���
���          �medicamentos controlados                                        ���
�����������������������������������������������������������������������������͹��
���Uso       �LOJA430 - funcoes: Lj430Grv() e Lj430Exc()                      ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Opcao do browse selecionada                            ���
���          �ExpL2  - Flag para efetuar o comando Reclock                    ���
���          �ExpC3  - Numero do documento a ser gravado                      ���
���          �ExpC4  - Codigo do cliente                                      ���
���          �ExpC5  - Loja do cliente                                        ���
���          �ExpC6  - Codigo do produto                                      ���
���          �ExpC7  - Unidade de Medida                                      ���
���          �ExpN8  - Quantidade a ser transferida                           ���
���          �ExpC9  - LOTE                                                   ���
���          �ExpD10 - Data da movimentacao                                   ���
���          �ExpL11 - Indica se o item esta' deletado ou nao                 ���
�����������������������������������������������������������������������������͹��
���Retorno   �                       	                                      ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Template Function DroTransANVISA( nOpc     , lFlag  , cNumDoc, cCodCli,;
						  		  cLojCli  , cCodPro, cUM    , nQuant ,;
						          cLote	   , dData  , lDeletado )
Local cCNPJOr 	 := ""						//CNPJ Origem
Local cCNPJDe 	 := ""						//CNPJ Destino

If nOpc == 1		//Inclusao / Alteracao
	DbSelectarea("SM0")      
	DbSetOrder(1)
	If DbSeek(cEmpAnt+cFilAnt)
		cCNPJOr := SM0->M0_CGC	//CNPJ Origem
	Endif
	
	DbSelectarea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCodCli+cLojCli)
		cCNPJDe := SA1->A1_CGC	//CNPJ Destino
	Endif
	
	DbSelectArea("LK9")
	DbSetorder(1)
	DbSeek(xFilial("LK9")+DTOS(dData)+cNumDoc+"TRA"+"3" )
	RecLock("LK9", lFlag)
	If lDeletado
		LK9->(DbDelete())
		LK9->(MsUnLock())		
	Else
		REPLACE LK9_FILIAL	WITH xFilial("LK9")
		REPLACE LK9_DOC		WITH cNumDoc
		REPLACE LK9_SERIE	WITH "TRA"
		REPLACE LK9_DATANF	WITH dDataBase
		REPLACE LK9_CNPJOR	WITH cCNPJOr
		REPLACE LK9_CNPJDE	WITH cCNPJDe	
		REPLACE LK9_CODPRO	WITH cCodPro
		REPLACE LK9_DESCRI	WITH Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
		REPLACE LK9_UM		WITH cUM
		REPLACE LK9_QUANT	WITH nQuant
		REPLACE LK9_LOTE	WITH cLote 
		REPLACE LK9_REGMS	WITH Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_REGMS")
		REPLACE LK9_TIPMOV	WITH "3"
		REPLACE LK9_DATA	WITH dDataBase
		REPLACE LK9_CODLIS	WITH Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_CODLIS")	
		REPLACE LK9_TPCAD  WITH "2"

		//campos de seguranca
		REPLACE LK9_USVEND  WITH cUserName
						
		//campos de seguranca
		REPLACE LK9_USAPRO  WITH cCaixaSup 
		
		LK9->(MsUnLock())
	Endif
ElseIf nOpc == 2		//Exclusao
	DbSelectArea("LK9")
	DbSetorder(1)
	If DbSeek(xFilial("LK9")+DTOS(dData)+cNumDoc+"TRA"+"3" )
		RecLock("LK9", .F.)
		LK9->(DbDelete())    
		LK9->(MsUnLock())
	Endif	
Endif                  

Return .T.

/*����������������������������������������������������������������������������
���Fun��o    �DroGrvPerda� Autor � Vendas Clientes       � Data � 28/08/01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Grava dados dos Lancamentos das Perdas na tabela LK9		   ���
��������������������������������������������������������������������������Ĵ��
���Parametros�  ExpN1 - Opcao do browse selecionada                        ���
���          �  ExpN2 - Controle de semaforo                               ���
���          �  ExpC3 - Numero do documento a ser gravado na tabela        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � DROAXCADASTRO - funcao DroAxPerda()		  	               ���
����������������������������������������������������������������������������*/
Template Function DroGrvPerda( nOpc, nSaveSx8, cDocumento )
Local lFlag	:= .T.  					//Define se e inclusao ou alteracao
Local lRet	:= .T.
Local cLK9ObsPer := ""

If !Obrigatorio(aGets,aTela)
   lRet := .F.
Endif

If lRet .And. nOpc == 4
	If M->LK9_DATA + nDiasRev < dDataBase 
	    Alert("Altera��o n�o permitida, periodo excedido para ajuste no registro do livro")
		lRet := .F.
	EndIf
	
	If Alltrim(M->LK9_OBSPER) == "" 
	    Alert("Altera��o n�o permitida, campo de observa��o precisa ser preenchido")
		lRet := .F.
	EndIf
Endif

If lRet .And. nOpc == 4
   lFlag := .F.
EndIf

If lRet
	BEGIN TRANSACTION 
		If (nOpc == 3 .OR. nOpc == 4)		//INCLUSAO ou ALTERACAO
			DbSelectArea("LK9")
			LK9->(DbSetorder(1))
			
			// Travando o Registro ate o final da operacao
			RecLock("LK9",lFlag)
			REPLACE LK9_FILIAL  WITH xFilial("LK9")
			REPLACE LK9_CODPRO  WITH M->LK9_CODPRO
			REPLACE LK9_DESCRI  WITH Posicione("SB1",1,xFilial("SB1")+M->LK9_CODPRO,"B1_DESC")
			REPLACE LK9_UM 	    WITH M->LK9_UM
			REPLACE LK9_QUANT   WITH M->LK9_QUANT
			REPLACE LK9_LOTE    WITH M->LK9_LOTE 
			REPLACE LK9_REGMS	WITH Posicione("SB1",1,xFilial("SB1")+M->LK9_CODPRO,"B1_REGMS")
			REPLACE LK9_MTVPER  WITH M->LK9_MTVPER
			REPLACE LK9_DATAPE  WITH M->LK9_DATAPE
			REPLACE LK9_TIPMOV  WITH "4" 
			REPLACE LK9_DOC     WITH cDocumento
			REPLACE LK9_SERIE   WITH "PER"
			REPLACE LK9_DATA    WITH dDataBase
			
			cLK9ObsPer := ""
			
			If nOpc == 4
				cLK9ObsPer := Alltrim(M->LK9_OBSPER)
				If AllTrim(LK9->LK9_OBSPER) <> cLK9ObsPer
					cLK9ObsPer := Alltrim(LK9->LK9_OBSPER) + " | " + dToc(dDataBase) + " - " + StrTran(cLK9ObsPer,Alltrim(LK9->LK9_OBSPER),"")
				EndIf
			Else		
				If Alltrim(LK9_OBSPER) == ""
					cLK9ObsPer := "Perda - " + dToc(dDataBase) + " - " + M->LK9_OBSPER
				Else
					cLK9ObsPer := Alltrim(LK9->LK9_OBSPER)
				EndIf
			EndIf
			
			REPLACE LK9_OBSPER  WITH cLK9ObsPer
			REPLACE LK9_CODLIS	WITH Posicione("SB1",1,xFilial("SB1")+M->LK9_CODPRO,"B1_CODLIS")
			REPLACE LK9_TPCAD	WITH "2"
		
			//campos de seguranca
			REPLACE LK9_USVEND  WITH cUserName
								
			//campos de seguranca
			REPLACE LK9_USAPRO  WITH cCaixaSup 
			
			While (GetSX8Len() > nSaveSx8)
				ConfirmSx8()
			End
			
			LK9->(MsUnlock())
		ElseIf nOpc == 5	//EXCLUSAO 
			DbSelectArea("LK9")
			RecLock("LK9",.F.)
			LK9->(DbDelete())
			LK9->(MsUnlock())
		Endif  
	
	END TRANSACTION 
EndIf

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroBtnCanc�Autor  �Vendas Clientes     � Data �  10/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao chamada no botao cancelar na tela de inclusao dos    ���
���          �Lancamentos das Perdas do medicamentos                      ���
�������������������������������������������������������������������������͹��
���Uso       �DROAXCADASTRO - funcao DroAxPerda()                         ���
���������������������������������������������������������������������������*/
Template Function DroBtnCanc( nSaveSx8 )

// Controle do semaforo
While (GetSx8Len() > nSaveSX8)
	RollBackSX8()
End

Return Nil  

/*���������������������������������������������������������������������������
���Programa  �DroSB8    �Autor  �Vendas Clientes     � Data �  10/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tratamento para o filtro que sera' realizado na consulta    ���
���          �SB8 - Lote do produto                                       ���
�������������������������������������������������������������������������͹��
���Uso       �F3 para o campo LK9_LOTE na rotina de lancamento de perdas  ���
���������������������������������������������������������������������������*/
Template Function DroSB8()
Local cConsulta  := ""						//Conteudo da consulta F3 para o campo LK9_LOTE
Local nTamX3Prod := TamSX3("B8_PRODUTO")[1]	// Tamanho do campo de Codigo do produto da SB8 no SX3
Local nPosProd   := 0						// Posicao do codigo do produto no aCols
Local cEAN 		 := Space(nTamX3Prod)		// EAN do produto
Local xRet		 := NIL

If IsInCallStack("RELINVENT") .Or. IsInCallStack("RELCOVISA") //Consulta padr�o de um Pergunte, dai retorno .T. pra prosseguir
	xRet := .T.
Else
	If FunName() == "LOJA701" .AND. !IsInCallStack("T_DroVlApr")                              
		nPosProd  := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]
		cEAN 	  := PadR(aCols[n,nPosProd], nTamX3Prod)
	Else 
		cEAN 	  := PadR(M->LK9_CODPRO, nTamX3Prod)    
	Endif
	
	If !Empty(cEAN)
		cConsulta := "SB8->B8_PRODUTO == '" + cEAN + "'"
	EndIf
	
	xRet := &(cConsulta)
EndIf

Return  xRet

/*�������������������������������������������������������������������������������
���Programa  �DroLK9Quant    �Autor  �Vendas Clientes     � Data �  06/03/08  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Atualiza quantidade informada na venda assistida                ���
�����������������������������������������������������������������������������͹��
���Uso       �DROVLDFUNCS - funcao DroGrvANVISA()                             ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Linha do aCols aANVISA a ser editada                    ���
���          �ExpN2 - Quantidade a ser atualizada                             ���
�����������������������������������������������������������������������������͹��
���Retorno   �NIL                    	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroLK9Quant( nItem, nLR_QUANT )
Local nTamANVISA := T_DroLenANVISA()	//Tamanho do array aANVISA
Local nLinha     := 0					//Linha do aCols aANVISA a ser atualizada 

If nTamANVISA > 0
	If T_DroExisANVISA(nItem)
		nLinha := T_DroPosANVISA(nItem)	
		aANVISA[nLinha][QTDEPROD] := nLR_QUANT
	Endif
Endif	

Return    

/*�������������������������������������������������������������������������������
���Programa  �DroLK9LF	     �Autor  �Vendas Clientes     � Data �  01/06/09  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Retorna os Dados do Cliente para o Livro Fiscal	              ���
�����������������������������������������������������������������������������͹��
���Uso       �LIVRO FISCAL						                              ���
�����������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero do Documento 					                  ���
���          �ExpN2 - Serie do Documento			                          ���
�����������������������������������������������������������������������������͹��
���Retorno   �NIL                    	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroLK9LF(	dData, cDoc, cSerie, cProduto,;
							nQuant1)
Local aArea		:= GetArea() 
Local aRet 		:= ARRAY(3) //Retorno dos Dados do cliente  
Local cLK9_PRO	:= ""

DEFAULT dData     := dDataBase
DEFAULT cDoc      := ""
DEFAULT cSerie    := ""     
DEFAULT cProduto  := ""  
DEFAULT nQuant1   := 0

If !Empty(cDoc) .And. !Empty(cSerie)
	DbSelectArea("LK9")
	LK9->(DbSetorder(1))      
	If LK9->(DbSeek(xFilial("LK9") + DTOS(dData) + Substr(cDoc,1,TamSX3("LK9_DOC")[1]) + cSerie )) 
	    nQuant1   := AllTrim(str(nQuant1) )   
	    cProduto := Padr(cProduto, TamSx3("B1_COD")[1] )     
		While !LK9->(EOF()) 
		    cLK9_PRO := Padr(LK9->LK9_CODPRO, TamSx3("B1_COD")[1]  )  
			If cProduto + nQuant1 == cLK9_PRO + AllTrim(Str(LK9->LK9_QUANT) )
				aRet[1] := LK9->LK9_NUMREC 
				aRet[2] := LK9->LK9_NOME
				aRet[3] := LK9->LK9_END	 
				Exit
			EndIf	
			LK9->(DbSkip() )
		End	
	EndIf 
	 
	Restarea(aArea)
EndIf

Return aRet

/*-------------------------------------------------------------------------------------
 	Autor - Thiago Honorato       
 	Data - 06/08/2008
 	Descri�ao - Funcoes para a CENTRAL DE COMPRAS
-------------------------------------------------------------------------------------*/
/*�����������������������������������������������������������������������������������
���Programa  �DroPCusto   �Autor  �Vendas Clientes     	   � Data �  17/03/08     ���
���������������������������������������������������������������������������������͹��
���Desc.     �Atualiza campos de maior e menor custo no cadastro de produtos      ���
���          �Essas informacoes serao utilizada na rotina da Central de Compras   ���
���          �tela de pre-pedido de compras                                       ���
���������������������������������������������������������������������������������͹��
���Uso       �TPLDROPE.prw - funcao GQREENTR() , Central de Compras				  ���
�����������������������������������������������������������������������������������*/
Template Function DroPCusto()
Local aArea     := GetArea()	//Area atual

SB1->(DbSetOrder(1))
DbselectArea("SD1")
SD1->(DbSetOrder(1))
If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!Eof()) .AND. 	xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
								SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA 

		If SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
			//Verifica se atualiza o campo de menor custo
			If SD1->D1_VUNIT < SB1->B1_MINCUS .OR. EMPTY(SB1->B1_MINCUS)
				RecLock("SB1",.F.)
				REPLACE SB1->B1_MINCUS  WITH SD1->D1_VUNIT
				REPLACE SB1->B1_DMINCUS WITH SD1->D1_EMISSAO
				SB1->(MsUnlock())
			EndIf
			
			//Verifica se atualiza o campo de maior custo
			If SD1->D1_VUNIT > SB1->B1_MAXCUS .OR. EMPTY(SB1->B1_MAXCUS)
				RecLock("SB1",.F.)
				REPLACE SB1->B1_MAXCUS  WITH SD1->D1_VUNIT
				REPLACE SB1->B1_DMAXCUS WITH SD1->D1_EMISSAO
				SB1->(MsUnlock())
			EndIf
		EndIf	
		
		SD1->(DbSkip())
	End
EndIf
RestArea(aArea)

Return .T.

/*���������������������������������������������������������������������������
���Fun��o    �A177Giro  � Autor � Thiago Honorato       � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Calculo do giro por filial								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA177()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPC1 - Filial de necessidade                  			  ���
���          �EXPC2 - Codigo do produto                      			  ���
���          �EXPA3 - Parametros contendo as perguntas para filtro		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPN1 - Giro                                   			  ���
���������������������������������������������������������������������������*/
Template Function A177Giro(cFilNec, cCodProd, aParam177)
Local nEstAtual := 0	 										//Estoque atual do produto
Local nGiro		:= 0	   										//Valor do giro - retorno da funcao 
Local dDataFim 	:= dDataBase							   		//Data fim
Local dDataIni  := MsSomaMes( dDataFim, - aParam177[8])		//Data inicio
Local nDias	    := dDataFim - dDataIni							//Numero de dias do periodo
Local nD2_QUANT := 0											//Conteudo do campo D2_QUANT

//������������������������Ŀ
//�Estoque atual do produto�
//��������������������������
nEstAtual := T_A177SB2(cFilNec, cCodProd)	

//������������������������Ŀ
//�Quantidade no SD2       �
//��������������������������
nD2_QUANT := T_A177SD2(cFilNec, cCodProd, aParam177)

//���������������Ŀ
//�Giro por filial�
//�����������������
nGiro  := Round(nEstAtual / (nD2_QUANT/nDias),2)

Return nGiro

/*���������������������������������������������������������������������������
���Fun��o    �A177SB2   � Autor � Thiago Honorato       � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Calculo do estoque atual do produto em todas as filiais  	  ���
���          �selecionadas             									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPN1 - Estoque atual do produto               			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA177()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPC1 - Filial de necessidade                  			  ���
���          �EXPC2 - Codigo do produto                      			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPN1 - Estoque atual                          			  ���
���������������������������������������������������������������������������*/
Template Function A177SB2(cFilNec, cCodProd)
Local cSB2		:= ""		//Tabela utilizada
Local nEstAtual	:= 0

#IFDEF TOP
	//���������������Ŀ
	//�Estoque atual do produto por filial�
	//�����������������
	cSB2 := GetNextAlias()		
	BeginSql Alias cSB2
		SELECT SUM(B2_QATU) SALDO_ATUAL
		FROM %table:SB2% SB2
		WHERE 	B2_FILIAL 	=  %Exp:cFilNec% 	AND
		      	B2_COD    	=  %Exp:cCodProd% 	AND
		   		SB2.%NotDel%
	EndSQL

	nEstAtual  := (cSB2)->SALDO_ATUAL
	
	(cSB2)->(DbCloseArea())
#ELSE	
	//Estoque atual do produto por filial
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	
	//Estoque atual de todos os almoxarifados
	If SB2->(DbSeek(cFilNec+cCodProd))
		nEstAtual := 0				
		While !SB2->(Eof()) .AND. SB2->B2_FILIAL+SB2->B2_COD == cFilNec+cCodProd
			nEstAtual += SB2->B2_QATU
			SB2->(DbSkip())
		End
	EndIf
#ENDIF

nEstAtual := Round(nEstAtual,2)

Return nEstAtual

/*���������������������������������������������������������������������������
���Fun��o    �A177SD2   � Autor � Thiago Honorato       � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Calculo das quantidades do SD2							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA177()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPC1 - Filial de necessidade                  			  ���
���          �EXPC2 - Codigo do produto                      			  ���
���          �EXPA3 - Parametros contendo as perguntas para filtro		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPN1 - Quantidade de pedidos em aberto       			  ���
���������������������������������������������������������������������������*/
Template Function A177SD2(cFilNec, cCodProd, aParam177)
Local cSD2   	:= ""	  										//Tabela utilizada
Local dDataFim 	:= dDataBase							   		//Data fim
Local dDataIni  := MsSomaMes( dDataFim, - aParam177[8])		//Data inicio
Local nD2_QUANT := 0											//Conteudo do campo D2_QUANT


#IFDEF TOP
	//���������������������Ŀ
	//�Quantidade por filial|
	//�����������������������	
	cSD2 := GetNextAlias()		
	BeginSql Alias cSD2
		SELECT SUM(D2_QUANT) QTDE_TOTAL
		FROM %table:SD2% SD2, %table:SF4% SF4 
		WHERE 	D2_FILIAL 	=  %Exp:cFilNec%  					AND
		      	D2_COD    	=  %Exp:cCodProd% 					AND
		      	D2_TIPO   	=  'N'                           	AND
				D2_EMISSAO 	>= %Exp:dDataIni%   		   		AND
		   		D2_EMISSAO	<= %Exp:dDataFim% 					AND
				D2_TES 		=  F4_CODIGO 						AND 
				F4_FILIAL   =  %Exp:cFilNec%   					AND
				F4_ESTOQUE  =  'S' 								AND
		   		SD2.%NotDel%									AND
		   		SF4.%NotDel%
	EndSQL

	nD2_QUANT :=  (cSD2)->QTDE_TOTAL
	
	(cSD2)->(DbCloseArea())
#ELSE	
	//���������������������Ŀ
	//�Quantidade por filial|
	//�����������������������
	SD2->(DbSetOrder(1))
	If SD2->(DbSeek(cFilNec+cCodProd))
		While !SD2->(Eof())	.AND. SD2->D2_FILIAL+SD2->D2_COD == cFilNec+cCodProd;
							.AND. SD2->D2_TIPO == "N";
							.AND. (DTOS(D2_EMISSAO) >= DTOS(dDataIni) .AND. DTOS(D2_EMISSAO) <= DTOS(dDataFim))

			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(SD2->D2_FILIAL+SD2->D2_COD))			
				If SF4->F4_CODIGO == SD2->D2_TES
					If SF4->F4_ESTOQUE == "S"
						nD2_QUANT += SD2->D2_QUANT
						SD2->(DbSkip())
					Endif
				Endif
			Endif
			SD2->(DbSkip())				
		End
	EndIf	
	
#ENDIF

Return (nD2_QUANT)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |A177PPend � Autor � Thiago Honorato       � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Calculo dos pedidos pendentes 							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA177()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPC1 - Filial de necessidade                  			  ���
���          �EXPC2 - Codigo do produto                      			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPN1 - Quantidade de pedidos pendentes       			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function A177PPend(cFilNec, cCodProd)
Local cSC7   	:= ""	//Tabela utilizada
Local nPendente := 0	//Quantidade pendente - retorno da funcao
Local nC7_QUANT := 0	//Quantidade total por pedido de compra solicitada
Local nC7_QUJE	:= 0	//Quantidade total por pedido de compra ja' entregue	 


#IFDEF TOP
	//���������������������Ŀ
	//�Quantidade por filial|
	//�����������������������	
	cSC7 := GetNextAlias()		
	BeginSql Alias cSC7
		SELECT SUM(C7_QUANT) TOTAL, SUM(C7_QUJE) ATENDIDO
		FROM %table:SC7% SC7
		WHERE 	C7_FILIAL 	=  %Exp:cFilNec% 	AND
		      	C7_PRODUTO	=  %Exp:cCodProd% 	AND
		      	C7_ENCER	<> 'E'								AND
		   		SC7.%NotDel%									
	EndSQL
	
	nC7_QUANT := (cSC7)->TOTAL
	nC7_QUJE  := (cSC7)->ATENDIDO

	(cSC7)->(DbCloseArea())
#ELSE	
	//������������������������������������������������������������Ŀ
	//�Selecionaodo a quantidade solicitada e a quantidade atendida|
	//��������������������������������������������������������������
	SC7->(DbSetOrder(2))
	If SC7->(DbSeek(cFilNec+cCodProd))
		While !SC7->(Eof())	.AND. SC7->C7_ENCER <> 'E' 
			nC7_QUANT += SC7->C7_QUANT
			nC7_QUJE  += SC4->C7_QUJE
			SC7->(DbSkip())				
		End
	EndIf
#ENDIF

nPendente := (nC7_QUANT - nC7_QUJE)

Return (nPendente)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A177SB3   � Autor � Thiago Honorato       � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Calculo da quantidade do vendas do mes atual, anterior e 	  ���
���          �media entre os dois meses									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�EXPC1 - Filial de necessidade                  			  ���
���          �EXPC2 - Codigo do produto                      			  ���
���          �EXPN3 - Opcao de retorno a ser escolhida      			  ���
���          �        nOpcao = 1(quantidade vendas do mes atual)		  ���
���          �        nOpcao = 2(quantidade vendas do mes anterior)		  ���
���          �        nOpcao = 3(media das vendas)               	 	  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPN1 - Opcao de retorno a ser escolhida      			  ���
���          �        nOpcao = 1(quantidade vendas do mes atual)		  ���
���          �        nOpcao = 2(quantidade vendas do mes anterior)		  ���
���          �        nOpcao = 3(media das vendas)               	 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA177()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function A177SB3( cFilNec, cCodProd, nOpcao )
Local nMesAtual 	:= 0		//Mes atual										
Local nMesAnter 	:= 0		//Mes anterior
Local cSB3      	:= ""		//Query utilizada
Local cQTDE_MATUAL 	:= ""		//Nome do campo que sera' utilizado para o mes atual
Local cQTDE_MANT 	:= ""		//Nome do campo que sera' utilizado para o mes anterior
Local xRet						//Retorno da funcao (pode ser quantidade atual ou quantidde anterior ou media de vendas)

//������������������������Ŀ
//�Mes atual e mes anterior�
//��������������������������
nMesAtual     := Month(dDatabase)
If nMesAtual == 1
	nMesAnter := 12
Else
	nMesAnter := nMesAtual - 1
Endif

#IFDEF TOP
	//����������������������������������������������������������������������������������Ŀ
	//�Calculo da quantidade do vendas do mes atual, anterior e media entre os dois meses�
	//������������������������������������������������������������������������������������
	cSB3 := GetNextAlias()	
	cQTDE_MATUAL := "%SB3.B3_Q"+StrZero(nMesAtual,2)+"%"  
	cQTDE_MANT   := "%SB3.B3_Q"+StrZero(nMesAnter,2)+"%"  

	BeginSql Alias cSB3
		SELECT 	%exp:cQTDE_MATUAL% QTDE_MATUAL, %exp:cQTDE_MANT% QTDE_MANT 
		FROM 	%table:SB3% SB3
		WHERE 	B3_FILIAL = %Exp:cFilNec%  AND
		        B3_COD    = %Exp:cCodProd% AND
				SB3.%NotDel%		
				
	EndSQL

	nQtdeAtual 	:= (cSB3)->QTDE_MATUAL
	nQtdeAnter 	:= (cSB3)->QTDE_MANT 
	(cSB3)->(DbCloseArea())
	
#ELSE
	//����������������������������������������������������������������������������������Ŀ
	//�Calculo da quantidade do vendas do mes atual, anterior e media entre os dois meses�
	//������������������������������������������������������������������������������������
	SB3->(DbSetOrder(1))
	If SB3->(DbSeek(cFilNec+cCodProd))
		cQTDE_MATUAL 	:= "SB3->B3_Q"+StrZero(nMesAtual,2)
		cQTDE_MANT 		:= "SB3->B3_Q"+StrZero(nMesAnter,2)
		nQtdeAtual 		:= &(cQTDE_MATUAL)
		nQtdeAnter 		:= &(cQTDE_MANT)
	EndIf
#ENDIF
	
nMedia := (nQtdeAtual + nQtdeAnter) / 2

If nOpcao == 1
	xRet := nQtdeAtual
Elseif nOpcao == 2
	xRet := nQtdeAnter
Elseif nOpcao == 3
	xRet := nMedia
Endif             

Return xRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �DRODescSA2 � Autor � Totvs                � Data � 22/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao para retornar o % de desconto comercial e financeiro ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �DrogDesc( cFabr, cFabrLoja, cProd )                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Codigo do Fabricante                                ���
���          �ExpC2 = Loja do Fabricante                                  ���
���          �ExpC3 = Codigo do Produto                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �TPLDROPE.prw - Funcao MT103IPC()                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DRODescSA2( cFabr, cFabrLoja, cProd )
Local nDesc := 0		//Percentual de desconto 

If SA5->(ColumnPos("A5_DESCFOR")) > 0   
	DbSelectArea( "SA5" )
	DbSetOrder( 1 )
	If SA5->( DbSeek( xFilial( "SA5" ) + cFabr + cFabrLoja + cProd ) )
		If SA5->A5_DESCFOR == "1"
			DbSelectArea( "SA2" )
			DbSetOrder( 1 )
			If SA2->( DbSeek( xFilial( "SA2" ) + cFabr + cFabrLoja ) )
				nDesc := SA2->A2_DESCCOM + SA2->A2_DESCFIN
			EndIf
		Else
			nDesc := SA5->A5_DESCCOM + SA5->A5_DESCFIN
		EndIf
	EndIf     
EndIf

Return nDesc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MTA177C7  � Autor � Totvs                � Data � 22/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza a tabela de prioridades                           ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �                      									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function MTA177C7( aCabec, aItens, lBonus )
Local aReturn    := {}
Local aLinha     := {}
Local cQuery     := ""
Local cIn        := ""
Local nSeq       := 0
Local nInc       := 0    
Local lC7Bonus   := SC7->(ColumnPos("C7_BONUS")) > 0       //Verifica se o campo existe no dicion�rio de dados

//�����������������������������������������������������������Ŀ
//� Altera flag para sinalizar que o PC e uma bonificacao e   �
//� atualiza variavel cIn para auxiliar na montagem da query. �
//�������������������������������������������������������������
For nInc := 1 To Len( aItens )
	If lC7Bonus
		aLinha := aItens[nInc]
		aAdd( aLinha, { "C7_BONUS", IIf( lBonus, "1", "2" ), NIL } )
   		aItens[nInc] := aClone( aLinha )   
    EndIf

	cIn += "'" + aItens[nInc][02][02] + "'"
	If nInc < Len( aItens )
		cIn += ", "
	EndIf
Next nInc

aAdd( aReturn, aClone( aCabec ) )
aAdd( aReturn, aClone( aItens ) )

//�����������������������������������������������������������Ŀ
//� Monta a query para atualizar a tabela de prioridades.     �
//�������������������������������������������������������������
cQuery += "SELECT A5_FORNECE, "
cQuery += "       A5_LOJA, "
cQuery += "       A2_CGC, "
cQuery += "       ( sum( A5_DESCCOM ) + sum( A5_DESCFIN ) ) AS DESCONTO "
cQuery += "FROM " + RetSqlName( "SA5" ) + " "
cQuery += "LEFT JOIN " + RetSqlName( "SA2" ) + " ON A2_COD = A5_FORNECE "
cQuery += "WHERE " + RetSqlName( "SA5" ) + ".D_E_L_E_T_ = '' AND "
cQuery += "      " + RetSqlName( "SA2" ) + ".D_E_L_E_T_ = '' AND "
cQuery += "      A5_PRODUTO IN ( " + cIn + " ) "
cQuery += "GROUP BY A5_FORNECE, A5_LOJA, A2_CGC, A5_PRIOFOR "
cQuery += "ORDER BY DESCONTO DESC, A5_PRIOFOR "

cAliasTrb := GetNextAlias()
cQuery    := ChangeQuery( cQuery )
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

While !(cAliasTrb)->(Eof())
	nSeq++

	For nInc := 1 To Len( aItens )
		RecLock( "LKC", .T. )
		LKC->LKC_FILIAL  := xFilial( "ZZZ" )
		LKC->LKC_FORNECE := (cAliasTrb)->A5_FORNECE
		LKC->LKC_LOJA    := (cAliasTrb)->A5_LOJA
		LKC->LKC_PEDIDO  := aCabec[01][02]
		LKC->LKC_PRODUTO := aItens[nInc][02][02]
		LKC->LKC_SEQ     := StrZero( nSeq, TamSX3( "LKC_SEQ" )[1] )
		LKC->LKC_STATUS  := ""      // "A"=Atendido;"R"=Remanejado;""=Pendente
		MsUnLock( "LKC" )
	Next nInc
	
	(cAliasTrb)->( DbSkip() )
End  

Return (aReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DrogForn  � Autor � Totvs                � Data � 22/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o fornecedor/distribuidor relacionados para a NF   ���
���          � de entrada (MATA103)                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �                      									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DrogForn( cForn )
Local cReturn    := "'"+ cForn +"'," 
Local cQuery     := ""  
Local cAliasTrb  := ""    


cQuery += "SELECT DISTINCT(A5_FABR) "
cQuery += "FROM " + RetSqlName( "SA5" ) + " "
cQuery += "WHERE " + RetSqlName( "SA5" ) + ".D_E_L_E_T_ = '' AND "
cQuery += "      A5_FORNECE = " +"'"+cForn +"'"+ " "

cAliasTrb := GetNextAlias()
cQuery    := ChangeQuery( cQuery )
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

While (cAliasTrb)->( !Eof() )
	cReturn += "'" + (cAliasTrb)->A5_FABR + "'," 	
	(cAliasTrb)->( DbSkip() )	
End                           

cReturn = SubStr(cReturn,1,Len(cReturn) -1)

Return cReturn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DRODelLKC � Autor � Totvs                � Data � 22/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Deleta os registros na tabela LKC (Prioridades para o      ���
���          � pedido de compra)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Codigo do Pedido de compra                         ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � TPLDROPE.prw, MATA177.prx								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DRODelLKC(cNumPed)

If AliasInDic("LKC")
	DbSelectArea( "LKC" )
	LKC->(DbSetOrder(1))
	If LKC->( DbSeek( xFilial( "LKC" ) + cNumPed ) )
		While LKC->( !Eof() ) .AND. LKC->LKC_PEDIDO == cNumPed
			RecLock( "LKC" )
			DbDelete()
			MsUnlock()
			LKC->( DbSkip() )
		End
	Endif
EndIf	

Return     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DroVldSt  � Autor � Vendas Clientes      � Data � 12/04/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Mostras dos dados de forma sistetica de um determinado     ���
���          � produto para a central de comprasa                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 										                      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177.prx	                							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DroVldSt( aItens,oDadosPed, nLin )
Local nOpcA   := 0                        
Local nCount  := 0
Local nTotNec := 0
Local nAtuNec := aItens[nLin,7]
Local nNewNec := aItens[nLin,8]
Local oDlg
Local oFont   

Local nVendMes  := 0   
Local nVendMAnt := 0
Local nMediMens := 0
Local nEstoque  := 0
Local nQdItens  := 0
           
 For nCount := 1 to Len(oDadosPed:ACOLECAO)
    If AllTrim( aItens[nLin, 3]) == AllTrim( oDadosPed:ACOLECAO[nCount][2]:CCODPROD)
       	nVendMes  += oDadosPed:ACOLECAO[nCount][2]:NVMESATUAL 
      	nVendMAnt += oDadosPed:ACOLECAO[nCount][2]:NVMESANTERIOR
      	nMediMens += oDadosPed:ACOLECAO[nCount][2]:NMEDIAMES
        nEstoque  += oDadosPed:ACOLECAO[nCount][2]:NESTOQUEATUAL    
    EndIf
 Next nCount


//--Totaliza as Necessidades
//AEval( aItens, {|x| If( x[3] == aItens[nLin,3], nTotNec += x[07], )} )

//--Monta tela para edicao da necessidade
Define MSDialog oDlg Title STR0040  From 000, 000 To 190, 602 Pixel //--"Editar Necessidade"  STR -"Dados Sinteticos"

	oFont := TFont():New( 'Arial',, -12,, .T. )
	                              //320
	TGroup():New( 005, 005, 035, 297, STR0041 , oDlg, CLR_BLUE,, .T. ) //--" Produto "
	TSay():New( 018, 010, {|| AllTrim( aItens[nLin, 3] ) + ' - ' + aItens[nLin,4]}, oDlg,, oFont,,,, .T., CLR_RED, CLR_WHITE, 200, 20 )

	TGroup():New( 040, 005, 070, 070, STR0042 , oDlg, CLR_BLUE,, .T. ) //-- STR "Venda Mes Atual"
	TGet():New( 050, 010, {|x| If( PCount() > 0, nVendMes := x, nVendMes )}, oDlg, 50, 05, '99999', {|| },,,oFont,,,.T.,,,{|| .F.}) 

	TGroup():New( 040, 072, 070, 146, STR0043 , oDlg, CLR_BLUE,, .T. ) //--  SRT "Venda Mes Anterior"
	TGet():New( 050, 077, {|x| If( PCount() > 0, nVendMAnt := x, nVendMAnt )}, oDlg, 50, 05, '99999', {|| },,,oFont,,,.T.,,,{|| .F.}) 

	TGroup():New( 040, 148, 070, 220, STR0044 , oDlg, CLR_BLUE,, .T. ) //-- STR "Media Mensal"
	TGet():New( 050, 153, {|x| If( PCount() > 0, nMediMens := x, nMediMens )}, oDlg, 50, 05, '99999', {|| },,,oFont,,,.T.,,,{|| .F.}) 
	                   //224
	TGroup():New( 040, 222, 070, 296, STR0045 , oDlg, CLR_BLUE,, .T. ) //--STR "Estoque "
	TGet():New( 050, 227, {|x| If( PCount() > 0, nEstoque := x, nEstoque )}, oDlg, 50, 05, '99999', {|| },,,oFont,,,.T.,,,{|| .F.}) 
	

	TButton():New( 075, 225, STR0046 , oDlg, {|| nOpcA := 1, oDlg:End() }, 070, 015,,,,.T. ) //--"SAIR"
   
Activate MSDialog oDlg Centered


Return()  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � DroRetFornec� Autor � Vendas Clientes      � Data � 22/05/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o Fornecedor a partir da Filial Centalizadora para   ���
���          � Distribuicao 						                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177.prx	                							    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Template Function DroRetFornec()
Local cFilCent    := APARAM177[21] //Filial centralizadora
Local cCGCFilCent :=""             //CGC da Filial Centralizadora
Local aRet        := {}            // retorno com o codigo do Fornecedor e Loja

DbSelectArea("SM0")
DbSetorder(1)
If DbSeek(cEmpant + cFilCent)
	cCGCFilCent := SM0->M0_CGC   
EndIf	
If cCGCFilCent <> ""
	DbSelectArea("SA2")
	DbSetOrder(3)
    If DbSeek(xFilial("SA2") + cCGCFilCent)
    	aRet := {A2_COD,A2_LOJA} 
    Else
    	aRet := {"",""}
    EndIf 
Else
	aRet := {"",""}         
EndIf		    
Return(aRet)  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � DroRetFornec� Autor � Vendas Clientes      � Data � 27/05/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se a prioridade  ja esta sendo usada para outro     ���
���          � Fornecedor	 						                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � 				                							    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Template Function DROVLPRI() 
Local lret := .T.

DbSelectArea("SA5")
DbsetOrder(2)  
DbSeek(xFilial("SA5")+ M->A5_PRODUTO)
While !Eof() .AND. (M->A5_FORNECE+M->A5_LOJA <> SA5->A5_FORNECE+ SA5->A5_LOJA) .AND. ;
      (M->A5_PRIOFOR ==A5_PRIOFOR)  
      
	MsgAlert(STR0050) //"Prioridade j� informada para outro fornecedor"
	lRet := .F.             
	DbSkip()	 
End
Return(lRet)    

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � DroQProp	   � Autor � Vendas Clientes      � Data � 27/05/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Calcula a quantidade Proprocional para a Distribuicao na     ���
���          � Central de Compras					                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177		                							    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/  
Template Function DroQProp(aArray,aTotNec,nPropAcum, cCodPro,nCount,nContProd,nQuntProd,nTipo )
Local nPosTotNec := AScan( aTotNec, {|x| x[1] == cCodPro} )
Local nValRound  := Posicione("SB1",1,xFilial("SB1") + cCodPro , "B1_QE") // Verifica se usa decimal na quantidade
Local lRound     := If(nValRound == 1 , .T., .F.)
Local nQuant     := 0  //Quantidade para calculo das necessidades  
Local aItens     := {} // aray de Retorno
Local nP01	     := If (nTipo == 1 , 7,3) //QTD. DA NECESSIDADE (CALCULO)
Local nP02       := If (nTipo == 1 , 13,5)//posicao da Quantidade da Centralizadora 
Local nP03		 := If (nTipo == 1 , 9,4) //posicao da QTD. PROPORCIONAL
Local np04       :=  8                     //QTD. DA NECESSIDADE (INFORMADA)
DEFAULT aArray   := {}  

aItens := aClone(aArray)
nContProd += 1                  

If aItens[nCount,nP02] > aTotNec[nPosTotNec, 2] // caso a quantidade Centralizadora atenda as necessiades das filiais
	// Se o produto tiver 1 por embalagem nao aceita decimas na quantidade 
	aItens[nCount,nP03] := If ( lRound,Round(aItens[nCount,nP01],0 ),;
	                                 Round(aItens[nCount,nP01],TamSX3('B2_QATU')[2] ) ) 
Else                                                            
	nQuant := (aItens[nCount,nP01] / aTotNec[nPosTotNec, 2]) 
	aItens[nCount,nP03] := If ( lRound,Round( (nQuant * aItens[nCount,nP02]) ,0) ,;
								 Round( (nQuant * aItens[nCount,nP02]) ,TamSX3('B2_QATU')[2]) )

	If nContProd < nQuntProd  //verificacao do ultimo item e a quantidade restante.
    	nPropAcum += aItens[nCount,nP03] 
    //Verifica se existe sobra na quantidade ou se faltou para o ultimo produto	
    ElseIf aItens[nCount,nP02] - nPropAcum > aItens[nCount,nP03]  .OR. aItens[nCount,nP03] > aItens[nCount,nP02] - nPropAcum 
    	aItens[nCount,nP03] := aItens[nCount,nP02] - nPropAcum    	    	
	EndIf 								 
EndIf  
If nTipo == 1
	aItens[nCount,nP04] := aItens[nCount,nP03]
EndIf	

Return(aItens)    

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � DroQuery	   � Autor � Vendas Clientes      � Data � 22/06/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se a Data do consumo inicial para os calculos na    ���
���          � Query da Central de Compras			                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177		                							    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/  

Template Function DroQuery(lBanco)
Local cRet     := ""
Local cDataIni := If ( !Empty(aPARAM177[31]), DtoS(aPARAM177[31]),"" )
Local cDataFim := If ( !Empty(aPARAM177[32]), DtoS(aPARAM177[32]),"" )  
Local cParam   := AllTrim(Str(aPARAM177[08]) )    
Local cTabela  := SuperGetMV( 'MV_ARQPROD', .F., 'SB1' )	
Local cCampo   := 	If (cTabela == 'SBZ',"SBZ.BZ_CONINI" ,"SB1.B1_CONINI" )

Default lBanco := .T.    

If !Empty (aPARAM177[31]) .AND. !Empty (aPARAM177[32]) 
    If lBanco 
    	cRet := " DECODE( SIGN( TO_DATE(COALESCE(RTRIM(LTRIM(" + cCampo +")),'" + cDataIni 
    	cRet += "'),'YYYYMMDD') - TO_DATE('" + cDataIni + "','YYYYMMDD')),1," 
       	cRet += " TO_DATE('" + cDataFim + "','YYYYMMDD') - " 
    	cRet += " TO_DATE(COALESCE(RTRIM(LTRIM(" + cCampo +" )),'" + cDataIni + "'),'YYYYMMDD')+1, "
    	cRet += cParam + " )"
    Else 
		cRet := " CASE WHEN CAST("+ cCampo +" AS BIGINT) = 0 THEN " + cParam 
		cRet += " WHEN CAST('" + cDataFim +"' AS DATETIME) < CAST(" + cCampo +  " AS DATETIME )"
		cRet += " THEN (CASE WHEN CAST('" + cDataFim  + "' AS DATETIME) <=  CAST(" + cCampo + " AS DATETIME )  THEN " +  cParam 
		cRet += " ELSE CAST( CAST('" + cDataFim  + "' AS DATETIME) - CAST(" + cCampo + " AS DATETIME ) AS BIGINT )"
		cRet += " END )
		cRet += " ELSE " + cParam   
		cRet += " END"
	EndIf	
else
	cRet := Alltrim(Str(aPARAM177[08]))
EndIf
Return cRet    

/*�����������������������������������������������������������������������������
���Funcao    � DroSB1ToSBZ � Autor � Vendas Clientes      � Data � 24/07/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Busca o campo da tabela SBZ cao nao exista pega o campo da   ���
���          � Tabela SB1							                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177		                							    ���
�����������������������������������������������������������������������������*/
Template Function DroSB1ToSBZ(cCodpro , cCampo ,cFilnec) 
Local aArea     := GetArea()  
Local cCampBZ   := Stuff(cCampo,2,1,"Z")   // Campo corespondente ao campo do SB1
Local cRet      := "" //Retorna o valor da funcao     
Local cMvarqPed := SuperGetMV("MV_ARQPROD",.F.,"SB1")


If SBZ->(ColumnPos(cCampBZ)) > 0 .AND. AllTrim(cMvarqPed) == "SBZ"  
	cRet := Posicione("SBZ",1,cFilnec + cCodPro, cCampBZ)  	 
Else
	cRet := Posicione("SB1",1,xFilial("SB1")+ cCodPro, cCampo)
EndIf 

Restarea(aArea)
Return cRet  

/*�����������������������������������������������������������������������������
���Funcao    � DroRetConini� Autor � Vendas Clientes      � Data � 28/07/09 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Retorna o campo Saldo inicial da tabela SB1 ou SBZ           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA177		                							    ���
�����������������������������������������������������������������������������*/  
Template Function DroRetConini(cDadosProd)
Local cRet := ""  
DEFAULT cDadosProd := "SB1"
 If !Empty (aPARAM177[31]) .AND. !Empty (aPARAM177[32]) 
    If cDadosprod == "SBZ"
    	cRet := ", SBZ.BZ_CONINI "    
    Else
  		cRet := ", SB1.B1_CONINI "    
  	EndIf
 Endif  
Return cRet

/*�����������������������������������������������������������������������������
���Funcao    � DroAnviDad  � Autor � Vendas Clientes      � Data � 29/04/10 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Pega o nome e endereco do cadastro de cliente para preencher ���
���          � os campos da tela LK9                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� 										                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � DROVLDFUNCS	                							    ���
�����������������������������������������������������������������������������*/  
Template Function DroAnviDad(cCliente,cLoja)
Local cLojP  := SuperGetMv("MV_LOJAPAD") //LOJA PADRAO
Local cCliP  := SuperGetMv("MV_CLIPAD")  //CLIENTE PADRAO
Local lAchou := .F.
Local lTotvsPDV:= STFIsPOS()

Default cCliente := ""
Default cloja    := ""


If nModulo == 12 .AND. AllTrim(M->LQ_CLIENTE)+ AllTrim(M->LQ_LOJA) <> cClip + cLojP
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + AllTrim(M->LQ_CLIENTE)+ AllTrim(M->LQ_LOJA) ) ) .AND. cCliP+cLojP <> AllTrim(M->LQ_CLIENTE)+ AllTrim(M->LQ_LOJA)
		lAchou := .T.
	Endif
ElseIf (nModulo == 23 .Or. lTotvsPDV) .AND. cCliente + cLoja  <> cClip + CLojP
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + AllTrim(cCliente)+ AllTrim(cLoja) ) ) .AND. cCliP+cLojP <> AllTrim(cCliente)+ AllTrim(cLoja)
		lAchou := .T.
	EndIf	
EndIf

If lAchou
	M->LK9_NOME  := SA1->A1_NOME            
	M->LK9_NOMEP := SA1->A1_NOME
	M->LK9_END   := SA1->A1_END
EndIf

Return

/*�����������������������������������������������������������������������������
���Funcao    � DrochkLK9   � Autor � Vendas Clientes      � Data � 27/08/10 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Chama a tela para fazer a atualizacao dos dados da uma outra ���
���			 � receita caso a tela de receita seja chamada pelo menu        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Param01 - Controla se foi chamada pelo menu ou automatica    ���
���          � Pelo produto 							                    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � Drovldfuncs	                							    ���
�����������������������������������������������������������������������������*/  
Static Function DrochkLK9(lF12)
Local cNumOrc    := ""
Local cNumDoc    := ""
Local cNumSerie  := ""
Local nItem      := "" 
Local cCodProd   := ""
Local nQuant     := 0
Local nItem1 	 := 0
Local nPosQuant	 := 0
Local nPosProd	 := 0    

Default lF12 := .F.

If nModulo == 12 .AND. lF12  
   nItem1 		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ITEM"})][2]	// Posicao da coluna Item 
   nPosQuant	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
   nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]// Posicao da codigo do produto
   
	cNumOrc    := M->LQ_NUM
	cNumDoc    := M->LQ_DOC
	cNumSerie  := M->LQ_SERIE
	nItem1     := aCols[n][nItem1] 
	cCodProd   := aCols[n][nPosProd]
	nQuant     := aCols[n][nPosQuant]

	T_DroAtuANVISA( cNumOrc , cNumDoc, cNumSerie, nItem1,;
				  cCodProd, nQuant, lF12 )
EndIf

Return nil

/*���������������������������������������������������������������������������
���Programa  �DROVldLote�Autor  �Vendas CRM	     � Data �  02/09/2011     ���
�������������������������������������������������������������������������͹��
���Desc.     � Chama Web Service para consultar lote na retaguarda		  ���
�������������������������������������������������������������������������͹��
���Retorno   � lRet - Se achou lote no sb8								  ���
�������������������������������������������������������������������������͹��
���Uso       � SigaLoja													  ���
���������������������������������������������������������������������������*/                                                                                 
Function DROVldLote()

Local lRet 		:= .T.
Local oWS  		:= WSLOJGERDADDR():New()
Local cWSServer	:= AllTrim(LJGetStation("WSSRV"))

//Ajusta o caminho do servico
oWs:_URL := "http://"+cWSServer+"/LOJGERDADDR.apw"

//���������������������Ŀ
//�Executa o web service�
//�����������������������
LjMsgRun( STR0051,, { || oWs:GetLote(M->LR_PRODUTO, M->LK9_LOTE, cEmpAnt,cFilAnt) } ) //"Aguarde. Pesquisando Lote na Retaguarda"

If ValType(oWs:LGETLOTERESULT) == "L"
	lRet := oWs:LGETLOTERESULT
	If !lRet
		Alert(STR0052+ M->LK9_LOTE + STR0053) //"Lote: " "n�o existe"	
	EndIF
Else
	Alert(STR0054 + oWs:_URL + Chr(13) +; //"Sem conex�o com Web Service "
	      STR0055 + AllTrim(M->LK9_LOTE) + STR0056) //"N�o ser� possivel validar o Lote " " na retaguarda"
	lRet 		:= .T.
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LjLogDro  � Autor � Vendas Clientes       � Data � 13/07/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se existe orcamento em aberto vencido para       ���
���            limpeza do log anvisa                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LjLogDro()
Local cQuery	:= ""				// Variavel a ser utilizada na query
Local lUsaQuery	:= .F.				// Verifica se o sistema esta trabalhando com Query
Local aLogDro   := {}               // Array com os or�amentos vencidos
Local nX        := 0 
Local cAlias	:= Alias()			// Guarda a area atual para restaurar apos a Query

#IFDEF TOP
	If 	UPPER(TcGetDb()) <> "DB2"
		lUsaQuery := .T.
	EndIf
#Endif

If lUsaQuery
	cQuery := "SELECT "
	cQuery += "SL1.R_E_C_N_O_ L1REC "
	cQuery += "FROM "+RetSQLName("SL1")+" SL1 "
	cQuery += "WHERE "
	cQuery += "SL1.L1_FILIAL      = '" + xFilial( "SL1" ) +"' "
	cQuery += "AND SL1.L1_DOC     = '" + Space(TamSx3("L1_DOC")[1])  +"' "   
	cQuery += "AND SL1.L1_RESERVA = '" + Space(TamSx3("L1_RESERVA")[1])  +"' "   
	cQuery += "AND SL1.L1_STATUS  <> 'D' "   
	cQuery += "AND SL1.L1_DTLIM   < '" + DTOS( dDataBase )  +"' "
	cQuery += "AND SL1.D_E_L_E_T_ <> '*' "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TRBLOG", .F., .T.) 
		
	TRBLOG->( DBGoTop() )
		
	While ! TRBLOG->(EOF())
		
		Aadd(aLogDro, {TRBLOG->L1REC} )

		TRBLOG->(DBSkip())

	Enddo
		
	TRBlOG->(dbCloseArea())
	DbSelectArea(cAlias)

Else

	aLogDro := {} // Array com os or�amentos vencidos

	//�����������������������������������Ŀ
	//�Procura a database como data limite�
	//�������������������������������������
	dDataBusca := DTOS( dDataBase - SuperGetMV("MV_DTLIMIT",,0)-1 ) 

	DbSelectArea("SL1")
	cIndex	:= CriaTrab(Nil,.F.)
	cChave	:= "L1_FILIAL+DTOS(L1_DTLIM)"
	IndRegua("SL1",cIndex,cChave,,,STR0005) //"Selecionando Registros..."
	nIndex  := RetIndex("SL1") 
    SL1->(DbSetIndex( cIndex + OrdBagExt() ))
	SL1->(DbSetOrder( nIndex + 1 ))

	If SL1->( DbSeek( xFilial( "SL1" ) + dDataBusca , .T. ) )
		
	 	//�����������������������������������������Ŀ
		//�Varre todo o SL1 para verificar um por um�
		//�������������������������������������������
		While SL1->( !Eof() ) .AND. SL1->L1_DTLIM == sTod(dDataBusca) .AND. AllTrim(SL1->L1_DOC) == "" .AND. dDataBase > SL1->L1_DTLIM 
	
			Aadd(aLogDro, {SL1->(Recno())} )
	
			SL1->( DbSkip() )	
		End
	EndIf
EndIf

If Len(aLogDro) > 0 

    dbSelectArea("SL1")

	If lUsaQuery
	   BeginTran()
	Endif
		
	For nX := 1 To Len(aLogDro)	 		       

        SL1->(dbGoTo(aLogDro[nX][1]))
		
		//������������������������������������������������
		//�Chama funcao para cancelamento dos Logs Anvisa�
		//������������������������������������������������
        If (ExistTemplate("LJ140EXC"))
			ExecTemplate("LJ140EXC",.F.,.F.,{.F.})
        EndIf 
		
	Next

    If lUsaQuery
	   EndTran()
	Endif
	
Endif

Return

/*���������������������������������������������������������������������������
���Fun��o    �DroVerLote� Autor � Vendas Clientes       � Data � 14/02/13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Verifica a existencia do lote na tabela e se existe o lote  ���
���          �para o produto											  ���
���������������������������������������������������������������������������*/
Template Function DroVerLote(cProduto, cLote)
Local lRet 		:= .F. 
Local cLocal	:= ""
Local nX		:= 0
Local aArea		:= {}

DEFAULT cProduto:= ""
DEFAULT	cLote	:= ""

DbSelectArea("SB1")
Aadd(aArea,SB1->(GetArea()))

SB1->(DbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cProduto))	
	cLocal := SB1->B1_LOCPAD
	DbSelectArea("SB8")
	Aadd(aArea,SB8->(GetArea()))
	SB8->(DbSetOrder(3))
	cProduto:= 	SubStr(cProduto,1,TamSX3("B8_PRODUTO")[1]) 	//Formata a variavel no tamanho correto do campo
	lRet 	:=	SB8->(MsSeek(xFilial("SB8")+cProduto+cLocal+cLote))
EndIf

For nX:=1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return lRet

/*�������������������������������������������������������������������������
���Programa  �DROLCS 	�Autor  �Microsiga           � Data �  02/03/13 ���
�����������������������������������������������������������������������͹��
���Desc.     �Verifica se o sistema possui a licenca da Integracao		���
���          � Protheus x SIAC ou de Template de Drogaria. Se nao tiver	���
���			 | nenhuma das duas, a execucao do sistema e abortada		���
�����������������������������������������������������������������������͹��
���Uso       � Template Drogaria										���
�������������������������������������������������������������������������*/
Template Function DROLCS()
Local lRet := .F.

If HasTemplate("DRO") .And. LjIsDro()
	lRet := .T.
Else
	Final("Acesso negado pois o CNPJ n�o esta liberado para uso de Template de Drogaria")
EndIf

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroVERArray   � Autor � Vendas Clientes    � Data �  26/03/15   ���
�����������������������������������������������������������������������������͹��
���Descricao � Logs ANVISA              	       		                      ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o chamada da fun��o FrtDescIT, para verificar se ja h� dados���
���          de cliente preenchidos para remedios de controle especial        ���
�������������������������������������������������������������������������������*/
Template Function DroVERArray(_cDoc, _cSerie, _cReceita, _cNomePac, _nPosItem )
Local lRet := .F.

Default _cDoc	:= "" 
Default _cSerie	:= ""  
Default _nPosItem := 0
Default _cNomePac := ""
Default _cReceita := ""

If ValType(aAnvisa) == "A" .AND. Len(aAnvisa) > 0
	_nPosItem := aScan(aAnvisa,{|x| x[NUMDOC]+x[SERIE] == _cDoc+_cSerie })
	If (lRet := _nPosItem > 0)
		_cReceita := aAnvisa[_nPosItem][RECEITA]
		_cNomePac := aAnvisa[_nPosItem][NPACIENTE]
	EndIf
EndIf	 

Return lRet

/*-------------------------------------------------------------------------------
���Programa  �DroVERPerm   � Autor � Vendas Clientes    � Data �  09/10/15    ���
�����������������������������������������������������������������������������͹��
���Descricao � Verifica Permissao de Farmaceutico                             ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o chamada de varios fontes parapara verificar se ja h� dados���
���          de cliente preenchidos para remedios de controle especial        ���
-------------------------------------------------------------------------------*/
Template Function DroVERPerm(nOrigem,cCaixaSup)
Local lRet		:= .T.
Local cSuperior := ""
Local cMensagem := ""
Local aAreasTab	:= {}
Local aProfile42:= {}
Local nX		:= 0
Local lProfile42:= .F.
Local lTotvsPDV := STFIsPOS()

Default nOrigem		:= IIf(lTotvsPDV,4,1)  //1-Sigaloja / 4-TotvsPDV
Default cCaixaSup	:= Space(25)

cSuperior := cCaixaSup

//Origem do MATA220 ou a variavel em branco/nil, caso esteja incorreta n�o valida as permiss�es certo
If (nOrigem == 3) .Or. (ValType(cStrAcesso) == "C" .And. Empty(AllTrim(cStrAcesso))) .Or. (cStrAcesso == NIL)
	DbSelectArea("SA6")	
	Aadd( aAreasTab , SA6->(GetArea()) )
	SA6->(DbSetOrder(2))
	If SA6->(DbSeek(xFilial("SA6")+PadR(AllTrim(Upper(cUserName)),TamSX3("A6_NOME")[1])))
		DbSelectArea("SLF")
		Aadd( aAreasTab , SLF->(GetArea()) )
		SLF->(DbSetOrder(1))
		If SLF->(DbSeek(xFilial("SLF")+PadR(AllTrim(Upper(SA6->A6_COD)), TamSX3("LF_COD")[1])))
			cStrAcesso := SLF->LF_ACESSO
		Else
			Conout("Caixa [" + AllTrim(SA6->A6_COD) + "] n�o encontrado, poss�vel verifica��o incorreta da permiss�o de caixa")
		EndIF
	Else
		Conout("Banco [" + cUserName + "] n�o encontrado, poss�vel verifica��o incorreta da permiss�o de caixa")
	EndIf
EndIf

//permissao para manipular remedios controlados (template drogaria)
If lTotvsPDV
	aProfile42 := STFPROFILE(42)
	lProfile42 := aProfile42[1]
	cSuperior  := aProfile42[2]
Else
	lProfile42 := LJProfile(42,@cSuperior)
EndIf

If !lProfile42
	lRet := .F.
	cMensagem := "Usu�rio n�o � um Farmaceutico. Venda/Cadastro n�o permitido"
	MsgAlert(cMensagem)
EndIf

If lRet 
	//Preenchimento dos campos de seguranca
	If nOrigem == 1  // Venda Loja
		M->LQ_USVENDA := cUserName
		M->LQ_USAPROV := cSuperior

	ElseIf nOrigem == 2  // cadastro de produto Loja110 
		If (INCLUI .OR. ALTERA)
			M->B1_USVENDA := cUserName
			M->B1_USAPRO := cSuperior 
		EndIf
	ElseIf nOrigem == 4 //TotvsPDV
		STDSPBasket("SL1","L1_USVENDA",cUserName)
		STDSPBasket("SL1","L1_USAPROV",cSuperior)
	Endif
EndIf

For nX := 1 to Len(aAreasTab)
	RestArea(aAreasTab[nX])
Next nX

If Empty(AllTrim(cCaixaSup)) .And. !Empty(AllTrim(cSuperior)) 
	cCaixaSup := cSuperior
EndIf

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroGrvUs   � Autor � Vendas Clientes    � Data �  09/10/15   	  ���
�����������������������������������������������������������������������������͹��
���Descricao � Grava o uPermissao de Farmaceutico                             ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o chamada de varios fontes parapara verificar se ja h� dados���
���          de cliente preenchidos para remedios de controle especial        ���
�������������������������������������������������������������������������������*/
Template Function DroGrvUs()
Local lRet		:= .T.
Local lProfile42:= .F.
Local lTotvsPDV := STFIsPOS()
Local cMsg := "Usu�rio n�o � um Farmaceutico. N�o poder� efetuar manuten��o neste cadastro."

// permissao para manupilar remedios controlados (template drogaria)
If lTotvsPDV
	lProfile42 := STFPROFILE(42)
Else
	cCaixaSup := Space(25)  // limpa a variavel estatica
	lProfile42 := LJProfile(42,@cCaixaSup)
EndIf

If !lProfile42
	MsgAlert(cMsg)
	lRet := .F.
EndIf

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroBrwAnvi   � Autor � Vendas Clientes    � Data �  14/10/15   ���
�����������������������������������������������������������������������������͹��
���Descricao � Abre Browse para transmissao xml anvisa                        ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o chamada de varios fontes parapara verificar se ja h� dados���
���          de cliente preenchidos para remedios de controle especial        ���
�������������������������������������������������������������������������������*/
Template Function DroBrwAnvi(_cTipoXml,_cCpf,_cCaixaSup)
Local lRet := .T.
Local cUrlAnvisa := SuperGetMV("MV_URLANVI",,"https://sngpc.anvisa.gov.br/webservice/sngpc_consulta/upload.aspx")

Default _cCaixaSup	:= cCaixaSup
Default _cCPF		:= ""
Default _cTipoXml	:= "AV_XML"   // avulso via menu

If !Empty(_cCaixaSup) 
	cCaixaSup := _cCaixaSup
EndIf
	
//��������������������������������������������������������������������������Ŀ
//  Template Drogaria 
//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
//����������������������������������������������������������������������������
If Empty(cCaixaSup) .OR. _cTipoXml	== "AV_XML"
	If !T_DroVERPerm(,@cCaixaSup)
		Return lRet
	EndIf
EndIf		 

ShellExecute( "Open", cUrlAnvisa, "", "C:\", 1 )

T_DroXmlANVISA(_cTipoXml,_cCPF,cCaixaSup) // grava as informacoes na lk9

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroBrwInve   � Autor � Vendas Clientes    � Data �  14/10/15   ���
�����������������������������������������������������������������������������͹��
���Descricao � Abre Browse para transmissao Inventario Anvisa                 ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DroBrwInve(_cTipoXml,_cCpf,_cCaixaSup)
Local lRet := .T.
Local cUrlAnvisa := SuperGetMV("MV_URLANVI",,"https://sngpc.anvisa.gov.br/webservice/sngpc_consulta/upload.aspx")

Default _cCaixaSup	:= cCaixaSup
Default _cCPF		:= ""
Default _cTipoXml	:= "AV_INV"  //avulso via menu

If !Empty(_cCaixaSup) 
	cCaixaSup := _cCaixaSup
EndIf
	
//��������������������������������������������������������������������������Ŀ
//  Template Drogaria 
//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
//����������������������������������������������������������������������������
If Empty(cCaixaSup) .OR. _cTipoXml	== "AV_INV"
	If !T_DroVERPerm(,@cCaixaSup)
		Return lRet
	EndIf
EndIf		 

ShellExecute( "Open", cUrlAnvisa, "", "C:\", 1 )

T_DroXmlANVISA(_cTipoXml,_cCPF,cCaixaSup) //grava as informacoes na lk9

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroXmlANVISA   �Autor  �Vendas Clientes     � Data �  20/12/06  ���
�����������������������������������������������������������������������������͹��
���Desc.     �Grava informacoes da geracao de Xml para ANVISA de remedios     ���
���          �controlados na tabela LK9 - Log's ANVISA                        ���
�����������������������������������������������������������������������������͹��
���Uso       �                                                       		  ���
�����������������������������������������������������������������������������͹��
���Parametros� cTipoXml -> se 5 XML para ANVISA , se 6 Invet�rio em XML
                                                                              ���
�����������������������������������������������������������������������������͹��
���Retorno   �.T.                    	                                      ���
�������������������������������������������������������������������������������*/
Template Function DroXmlANVISA(cTipXml,cCpf,cCaixaSup)

Local aArea   	:= GetArea()	  			//Area Atual
Local cDesc		:= "" 
Local cUsuario	:= "" 

DEFAULT cTipXml	:= ""
DEFAULT cCpf	:= ""

//aqui eh para apenas gravar na lk9 a geracao de xml e inventario e a data de envio dos arquivos , que
//pode ser na hora ou em outro dia

If 	cTipXml == "5" 
	cDesc := "Geracao do XML ANVISA"
ElseIf cTipXml == "6" 
	cDesc := "Geracao do INVENTARIO ANVISA"
ElseIf cTipXml == "INV"
	cTipXml := "0"
	cDesc := "Envio de INVENTARIO para ANVISA"
ElseIf 	cTipXml == "XML"
	cTipXml := "0"
	cDesc := "Envio de XML para ANVISA"
ElseIf cTipXml == "AV_XML"
	cTipXml := "0"
	cDesc := "Envio de XML Avulso para ANVISA"
ElseIf cTipXml == "AV_INV"
	cTipXml := "0"
	cDesc := "Envio de INVENT. Avulso para ANVISA"
EndIf
  
If !Empty(cTipXml)

	RecLock("LK9", .T.)

	REPLACE LK9_FILIAL	WITH xFilial("LK9")
	REPLACE LK9_DATA	WITH dDataBase
	REPLACE LK9_TIPMOV	WITH cTipXml 
	REPLACE LK9_SITUA	WITH "RX" 
	REPLACE LK9_DESCRI	WITH cDesc 
	REPLACE LK9_OBSPER	WITH cDesc + " Responsavel - Cpf:" + cCpf + " , Usuario : " + __CUSERID + " - " + cUserName + ",  Autorizado por :" + cCaixaSup	  

	//campos de seguranca
	REPLACE LK9_USVEND  WITH cUserName
		
	//campos de seguranca
	REPLACE LK9_USAPRO  WITH cCaixaSup
	
	LK9->(MsUnLock())
EndIf

RestArea(aArea)

cCaixaSup := Space(25)

Return .T.

/*�������������������������������������������������������������������������������
���Programa  �DroCPF   � Autor � Vendas Clientes    � Data �       15/12/15   ���
�����������������������������������������������������������������������������͹��
���Descricao � Valida CPF                                                     ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o para validar o cpf digitado no cadastro de farmaceutico e ���
���          e na digitacao do responsavel pela transmissao do xml            ���
�������������������������������������������������������������������������������*/
Template Function DroCPF(cCPF, lErrorMsg)
Local lRet 			:= .T.
Local aArea			:= GetArea()

Default cCPF		:= ""
Default lErrorMsg	:= .T.

If !Empty(cCPF)
	If !CGC(cCpf,,.F.) .AND. lErrorMsg // funcao da LIb http://tdn.totvs.com.br/display/public/mp/CGC
		MsgAlert("CPF inv�lido")//"CPF inv�lido"
		lRet := .F.
	Else
		If !isIncallStack("ValidaCPF")
			LKB->( DbSetOrder(1) )	//LKB_FILIAL+LKB_CPF
			If LKB->( DbSeek(xFilial("LKB") + M->LKB_CPF) )
				lRet := .F.
				If lErrorMsg
					MsgStop("Esse CPF j� foi cadastrado.")
				EndIf
			EndIf		
		EndIf			
	EndIf
Endif

RestArea(aArea)

Return lRet


/*�������������������������������������������������������������������������������
���Programa  �DroCrF   � Autor � Vendas Clientes    � Data �       15/12/15   ���
�����������������������������������������������������������������������������͹��
���Descricao � Valida CRF                                                     ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
���          fun��o para validar o crf digitado no cadastro de farmaceutico   ���
�������������������������������������������������������������������������������*/
Template Function DroCRF(cCrF)

Local lRet := .T.
Local aArea := GetArea()

Default cCrf := ""

If !Empty(cCRF)
	dbSelectArea("LKB")
	LKB->(dbSetOrder(2))
	If LKB->( dbSeek(xFilial("LKB") + cCRF) )
		MsgStop("CRF J� cadastrado")//"CRF J� cadastrado"
		lRet := .F.
	EndIf
	RestArea(aArea)	
Endif

Return lRet

/*������������������������������������������������������������������������������
���Programa  �LjSetSup�    Autor  � Vendas Clientes        � Data � 02/09/13 ���
����������������������������������������������������������������������������͹��
���Descricao � Atribui valor a variavel caracter(Static) cCaixaSup	         ���
����������������������������������������������������������������������������͹��
���Retorno   � 													             ���
������������������������������������������������������������������������������*/
Function LjSetSup(_cCaixaSup)

DEFAULT _cCaixaSup :=  Space(25)

cCaixaSup := _cCaixaSup

Return Nil

/*������������������������������������������������������������������������������
���Programa  �LjGetSup �   Autor  � Vendas Clientes        � Data � 02/09/13 ���
����������������������������������������������������������������������������͹��
���Descricao � Retorna a variavel variavel caracter(Static) cCaixaSup	     ���
����������������������������������������������������������������������������͹��
���Retorno   � Logico											             ���
������������������������������������������������������������������������������*/
Function LjGetSup()
Return cCaixaSup

//------------------------------------------------------------------------------
/*/{Protheus.doc} AjTpDroSx1
Faz o papel da antiga ajusta SX1 que n�o existe na V12,
pois o template necessita das altera��es espec�ficas
@type		function
@author  	julio.nery
@version 	P12
@since   	16/02/2017
@return  	Nil
/*/
//------------------------------------------------------------------------------
Function AjTpDroSx1(cGrupo	,	cOrdem	,	cPergunt,	cPerSpa		,;
					cPerEng	,	cVar	,	cTipo	,	nTamanho	,;
					nDecimal,	nPresel	,	cGSC	,	cValid		,;
					cF3		,	cGrpSxg	,	cPyme	,	cVar01		,;
					cDef01	,	cDefSpa1,	cDefEng1,	cCnt01		,;
					cDef02	,	cDefSpa2,	cDefEng2,	cDef03		,;
					cDefSpa3,	cDefEng3,	cDef04	,	cDefSpa4	,;
					cDefEng4,	cDef05	,	cDefSpa5,	cDefEng5	,;
					aHelpPor,	aHelpEng,	aHelpSpa,	cHelp		)

Local aArea := GetArea()
Local cKey	:= ""
Local lNovo	:= .T.

Default cHelp	:= NIL

cKey  	:= "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
cPyme	:= Iif( cPyme 	== Nil, " ", cPyme		)
cF3		:= Iif( cF3 	== NIl, " ", cF3		)
cGrpSxg	:= Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
cCnt01	:= Iif( cCnt01	== Nil, "" , cCnt01 	)
cHelp	:= Iif( cHelp	== Nil, "" , cHelp		)

dbSelectArea( "SX1" )
SX1->(dbSetOrder( 1 ))
cGrupo	:=	PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
lNovo	:=	!SX1->( DbSeek( cGrupo + cOrdem ))

cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

Reclock( "SX1" , lNovo )
Replace X1_GRUPO   With cGrupo
Replace X1_ORDEM   With cOrdem
Replace X1_PERGUNT With cPergunt
Replace X1_PERSPA  With cPerSpa
Replace X1_PERENG  With cPerEng
Replace X1_VARIAVL With cVar
Replace X1_TIPO    With cTipo
Replace X1_TAMANHO With nTamanho
Replace X1_DECIMAL With nDecimal
Replace X1_PRESEL  With nPresel
Replace X1_GSC     With cGSC
Replace X1_VALID   With cValid
Replace X1_VAR01   With cVar01
Replace X1_F3      With cF3
Replace X1_GRPSXG  With cGrpSxg

If cPyme <> Nil
	Replace X1_PYME With cPyme
Endif

Replace X1_CNT01   With cCnt01

If cGSC == "C"			// Mult Escolha
	Replace X1_DEF01   With cDef01
	Replace X1_DEFSPA1 With cDefSpa1
	Replace X1_DEFENG1 With cDefEng1

	Replace X1_DEF02   With cDef02
	Replace X1_DEFSPA2 With cDefSpa2
	Replace X1_DEFENG2 With cDefEng2

	Replace X1_DEF03   With cDef03
	Replace X1_DEFSPA3 With cDefSpa3
	Replace X1_DEFENG3 With cDefEng3

	Replace X1_DEF04   With cDef04
	Replace X1_DEFSPA4 With cDefSpa4
	Replace X1_DEFENG4 With cDefEng4

	Replace X1_DEF05   With cDef05
	Replace X1_DEFSPA5 With cDefSpa5
	Replace X1_DEFENG5 With cDefEng5
Endif

If Len(aHelpPor) > 0 .Or. Len(aHelpEng) > 0 .Or. Len(aHelpSpa) > 0
	If (cHelp <> NIL)
		Replace X1_HELP  With cHelp
	EndIf
	PutSx1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
Else
	Replace X1_HELP With ""
EndIf

SX1->(DbCommit())
SX1->(MsUnlock())
	
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrAjSX(cMensagem)
Efetua altera��es do dicion�rio para essa release

@author Julio.nery
@since 20/07/2018
@version P12
/*/
//-------------------------------------------------------------------
Template Function LjDrAjSX()
Local lExecFunc	:= ExistFunc("EngSX3117")
Local aDadosDic	:= {}
Local cUsadoOpc	:= "���������������"
Local cAUsado	:= "���������������"
Local cX3aRESERV:= "��"
Local cX3bRESERV:= "��"
Local cX3cRESERV:= "��"
Local cX3dRESERV:= "��"
Local cX3eRESERV:= "��"
Local cX3fRESERV:= "��"
Local cAux		:= ""

If lExecFunc
	LjGrvLog( Nil,"Fun��o de Ajuste de Dicion�rio do Template")
	
	If AliasInDic("MHA")
		aAdd( aDadosDic, {{'MHA_CODIGO'}, {{'X3_USADO', cAUsado   , NIL },{'X3_RESERV', cX3fRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHA_PATIVO'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHA_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	EndIf
	
	If AliasInDic("MHB")
		aAdd( aDadosDic, {{'MHB_CODAPR'}, {{'X3_USADO', cAUsado   , NIL },{'X3_RESERV', cX3fRESERV , NIL },;
											{'X3_VALID','ExistChav("MHB",M->MHB_CODAPR)',NIL};
											}} )
		aAdd( aDadosDic, {{'MHB_APRESE'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHB_GRUPO'} , {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3cRESERV , NIL },;
											{'X3_F3', 'L34' , NIL };
											}} )
		aAdd( aDadosDic, {{'MHB_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL } ,;
										   {'X3_TITULO', "Obs Alt/Inc" , NIL } ;
											}} )
	EndIf

	If AliasInDic("MHC")
		aAdd( aDadosDic, {{'MHC_CODSIM'}, {{'X3_USADO', cAUsado	  , NIL },{'X3_RESERV', cX3fRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHC_DESIMI'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHC_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	EndIf

	If AliasInDic("MHD")
		aAdd( aDadosDic, {{'MHD_PRODUT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }, ;
											{'X3_VALID','ExistCpo("SB1") .And. ExistChav("MHD") .And. T_A004Prod()',NIL},;
											{'X3_F3',"SB1", NIL}, {'X3_GRPSXG','030',NIL} ;
											}} )
		aAdd( aDadosDic, {{'MHD_DESCRI'}, {{'X3_VALID', 	"" 	  , NIL },{'X3_RELACAO', 'T_A004DESCRI("MHD_DESCRI")' , NIL },;
    									   {'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV' , cX3cRESERV 				  , NIL };
    									   }})
	EndIf

	If AliasInDic("MHE")
		aAdd( aDadosDic, {{'MHE_PRODUT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_VALID','ExistCpo("SB1")',NIL},;
											{'X3_F3',"SB1", NIL}, {'X3_GRPSXG','030',NIL} ;
											}} )
		
		aAdd( aDadosDic, {{'MHE_CODCOM'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_F3',"SB1", NIL};
											}} )
		
		aAdd( aDadosDic, {{'MHE_SEQUEN'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3cRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL };
											}} )
											
		aAdd( aDadosDic, {{'MHE_DESCRI'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3cRESERV , NIL },;
											{'X3_RELACAO', 'T_A004DESCRI("MHE_DESCRI")' , NIL },;
											{'X3_VALID', 'Texto()' , NIL };
											}} )		
		aAdd( aDadosDic, {{'MHE_QUANT'} , {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	EndIf

	If AliasInDic("MHF")
		aAdd( aDadosDic, {{'MHF_CODIGO'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
		aAdd( aDadosDic, {{'MHF_NOME'}  , {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_VALID', '' , NIL };
											}} )
	EndIf
	
	If AliasInDic("MHG")
		aAdd( aDadosDic, {{'MHG_CODIGO'}, {{'X3_USADO', cAUsado , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL },{'X3_TITULO','C�digo Plano', NIL },;
											{'X3_DESCRIC','C�digo do Plano', NIL },{'X3_WHEN','INCLUI', NIL };
											}} )
											
		aAdd( aDadosDic, {{'MHG_NOME'}  , {{'X3_USADO', cAUsado , NIL },{'X3_RESERV', cX3cRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL } ;
											}} )

		aAdd( aDadosDic, {{'MHG_CODREG'}, {{'X3_USADO', cAUsado , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL },{'X3_F3', "ACO" , NIL },;
											{'X3_VALID', "ExistCpo('ACO',M->MHG_CODREG)" , NIL } ;
											}} )
											
		aAdd( aDadosDic, {{'MHG_REGRA'} , {{'X3_USADO', cAUsado , NIL },{'X3_RESERV', cX3cRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL },{'X3_VISUAL',	"A"		, NIL} ;
											}} )
											
		aAdd( aDadosDic, {{'MHG_TIPO'}  , {{'X3_USADO', cAUsado , NIL },{'X3_RESERV', cX3bRESERV , NIL },;
											{'X3_PICTURE', "@!" , NIL },;
											{'X3_CBOX','1=Empresarial;2=Aposentado;3=Plano de Saude;4=Bandeira Propria',NIL} ;
											}} )
	EndIf
	
	aAdd( aDadosDic, {{'LIP_CODIGO'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LIP_DESC'}	, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LIP_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	
	aAdd( aDadosDic, {{'B1_OBSALTE'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LK9_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LEO_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LKA_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'LKB_OBSALT'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'B7_OBSALTE'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	aAdd( aDadosDic, {{'B9_OBSALTE'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3bRESERV , NIL }}} )
	
	aAdd( aDadosDic, {{'B1_PRINATV'}, {{'X3_TAMANHO', 25 , NIL } }})
	aAdd( aDadosDic, {{'B1_PATOLOG'}, {{'X3_TAMANHO', 30 , NIL } }})
	aAdd( aDadosDic, {{'B1_FABRIC'} , {{'X3_TAMANHO', TamSX3("A2_NOME")[1] , NIL },{'X3_CONTEXT', "R" , NIL } }})
	
	//Esses campos s�o campos padr�o
	aAdd( aDadosDic, {{'LQ_NOMCLI'}  , {{'X3_RELACAO', 'IF( nModulo == 12 .And. INCLUI,"",POSICIONE("SA1",1,XFILIAL("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME"))' , NIL } }})
	aAdd( aDadosDic, {{'LQ_IFSMSG1'} , {{'X3_RELACAO', "IF( nModulo == 12 .And. !INCLUI,MSMM(SL1->L1_IFSCDM1, 255),'')" , NIL } }})
	aAdd( aDadosDic, {{'LQ_IFSMSG2'} , {{'X3_RELACAO', "IF( nModulo == 12 .And. !INCLUI,MSMM(SL1->L1_IFSCDM2, 255),'')" , NIL } }})
	
	aAdd( aDadosDic, {{'LR_PRODUTO'}, {{'X3_VALID', "IF( nModulo == 12,Lj7Prod(.T.,,.T.), .T.)" , NIL } }})
	aAdd( aDadosDic, {{'LR_VRUNIT'} , {{'X3_VALID', "IF( nModulo == 12,Lj7VlItem(2), .T.)" , NIL } }})

	aAdd( aDadosDic, {{'MA6_CODDEP'}, {{'X3_USADO', cUsadoOpc , NIL },{'X3_RESERV', cX3aRESERV , NIL }}} )
	
	cAux := "1=Cartao Novo;2=Perda/Furto;3=Obito;4=Desligamento;5=Atraso"
	aAdd( aDadosDic, {{'MA6_MOTIVO'}, {{'X3_CBOX', cAux , NIL },{'X3_VALID', "Vazio() .or. Pertence('12345')" , NIL }}} )
	
	aAdd( aDadosDic, {{'A1_CODPLF1'} , {{'X3_VALID', 'IiF( !Empty(M->A1_CODPLF1),ExistCpo("MHG",M->A1_CODPLF1),.T.)' , NIL } }})
	aAdd( aDadosDic, {{'A1_CODPLF2'} , {{'X3_VALID', 'Iif( !Empty(M->A1_CODPLF2),ExistCpo("MHG",M->A1_CODPLF2),.T.)' , NIL } }})	
	aAdd( aDadosDic, {{'A1_CODPLF3'} , {{'X3_VALID', 'Iif( !Empty(M->A1_CODPLF3),ExistCpo("MHG",M->A1_CODPLF3),.T.)' , NIL } }})
	aAdd( aDadosDic, {{'A1_CODPLF4'} , {{'X3_VALID', 'Iif( !Empty(M->A1_CODPLF4),ExistCpo("MHG",M->A1_CODPLF4),.T.)' , NIL } }})
	aAdd( aDadosDic, {{'A1_CODPLF5'} , {{'X3_VALID', 'Iif( !Empty(M->A1_CODPLF5),ExistCpo("MHG",M->A1_CODPLF5),.T.)' , NIL } }})

	/*Efetua Ajuste no Dicion�rio*/
	EngSX3117(aDadosDic) //Devera ser excluido na proxima Release
	
	/* Altera��o de consulta padr�o	*/
	aDadosDic := {}
	aAdd( aDadosDic, { {'L36' , '6', '01', ''}, { {'XB_CONTEM', "SA2->A2_FABRICA<>'N'"} } } )
	EngSXB117(aDadosDic)
	
	LjGrvLog( Nil,"Final da Fun��o de Ajuste de Dicion�rio do Template")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX1(cMensagem)
Insere as perguntas que anteriormente eram criados via UPDDRO
Essa fun��o eh chamada pelo RBE_LOJA (tamb�m)

@param cMensagem - mensagem de log do processo
@param lExecUpd	- executa UPD de campo ?
@author Julio.nery
@since 12/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Template Function LjDrCriaX1(cMensagem,lExecUpd,lIsRBe)
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local cX1_VALID	:= ""
Local cX1_Pergunt:= ""
Local cX1_DEF01	:= ""
Local cX1_DEF02	:= ""
Local cX1_DEF03	:= ""
Local cX1_DEF04	:= ""
Local cX1_DEF05	:= ""
Local cX1_Help	:= ""
Local cPath		:= ""
Local cNomArq	:= "HLP_TPLDRO.DRO"
Local lExistFile:= .F.
Local lGerado	:= .F.
Local nHdlTXT	:= 0
Local _PLINHA	:= CHR(13) + CHR(10)

Default cMensagem	:= ""
Default lExecUpd	:= .T.
Default lIsRBe		:= .F.

cPath := IIf(lIsRBe, " ", GetSrvProfString("RootPath","") + "\system\")

If lExecUpd
	//Aqui dentro � poss�vel por o LJGRVLOG(LogLoja) pois o RBE n�o deve entrar 
	
	Conout("Antes da fun��o LjDrAjSX")
	T_LjDrAjSX() //Efetua ajuste de dicion�rio do Template
	Conout("Depois da fun��o LjDrAjSX")
	
	If ExistTemplate("TpDrIncLX")
		Conout("Antes da fun��o TpDrIncLX")
		T_TpDrIncLX() //Efetua ajuste de dicion�rio do Template
		Conout("Depois da fun��o TpDrIncLX")
	Else
		Conout("Atualize o fonte TPLLX5 para atualiza��o das tabelas de Template")
		LjGrvLog("TPL_DRO","Atualize o fonte TPLLX5 para atualiza��o das tabelas de Template")
	EndIf
	
EndIf

lExistFile := !lIsRBe .And. File(cPath + cNomArq)

If lIsRBe .Or. !lExistFile

	DbSelectArea("SX1")
	
	cMensagem += " In�cio da fun��o LjDrCriaX1 - Cria��o de Perguntas"+ _PLINHA
	Conout(" In�cio da fun��o LjDrCriaX1 - Cria��o de Perguntas")

	/*
		RELRMNR
	*/
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o Ano no formato AAAA."}
	AjTpDroSx1 ("RELRMNR"	, "01"			, "Ano ?"	, "Ano ?"			,;
				"Ano ?"		, "MV_CH0"		, "C"		, 4					,;
				0			, 0				, "G"		, "!Empty(MV_PAR01)",;
	            ""			, ""			, "S"		, "MV_PAR01"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELRMNR01"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o M�s no formato M ou MM.", "Ex: 1 equivale a Janeiro"}
	AjTpDroSx1 ("RELRMNR"	, "02"			, "M�s ?"	, "M�s ?"							,;
				"M�s ?"		, "MV_CH1"		, "N"		, 2									,;
				0			, 0				, "G"		, "(MV_PAR02>0 .AND. MV_PAR02<13)"	,;
	            ""			, ""			, "S"		, "MV_PAR02"						,;
				""			, ""			, ""		, ""								,;
	            ""			, ""			, ""		, ""								,;
				""			, ""			, ""		, ""								,;
				""			, ""			, ""		, ""								,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELRMNR02"						)
	
	aHelpPor := aHelpEng := aHelpSpa := {"A=Notifica��o de Receita A (amarela)","/B2=Notifica��o de Receita B2 (azul)"}
	AjTpDroSx1 ("RELRMNR"			, "03"			, "Tipo de Receita?", "Tipo de Receita?",;
				"Tipo de Receita?"	, "MV_CH2"		, "N"				, 1					,;
				0					, 0				, "C"				, ""				,;
	            ""					, ""			, "S"				, "MV_PAR03"		,;
				"Receita A"			, "Receita A"	, "Receita A"		, ""				,;
	            "Receita B2-azul"	, "Receita B2-azul","Receita B2-azul", ""				,;
				""					, ""			, ""				, ""				,;
				""					, ""			, ""				, ""				,;
	            aHelpPor			, aHelpEng		, aHelpSpa			, "RELRMNR03"		)
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELRMNR" + _PLINHA
	Conout("fun��o LjDrCriaX1 -  Criado a pergunta RELRMNR")
	
	/*
		RELBMPO
	*/
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o Ano no formato AAAA."}
	AjTpDroSx1 ("RELBMPO"	, "01"			, "Ano?"	, "Ano?"			,;
				"Ano?"		, "MV_CH0"		, "C"		, 4					,;
				0			, 0				, "G"		, "!Empty(MV_PAR01)",;
	            ""			, ""			, "S"		, "MV_PAR01"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELBMPO01"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Selecione o Per�odo."}
	AjTpDroSx1 ("RELBMPO"			, "02"			, "Periodo?"		, "Periodo?",;
				"Periodo?"			, "MV_CH1"		, "N"				, 1					,;
				0					, 0				, "C"				, ""				,;
	            ""					, ""			, "S"				, "MV_PAR02"		,;
				"1o Trimestre"		, "1o Trimestre", "1o Trimestre"	, ""				,;
	            "2o Trimestre"		, "2o Trimestre", "2o Trimestre"	, "3o Trimestre"	,;
				"3o Trimestre"		, "3o Trimestre", "4o Trimestre"	, "4o Trimestre"	,;
				"4o Trimestre"		, "Anual"		, "Anual"			, "Anual"			,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELBMPO02"		)
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELBMPO" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta RELBMPO")
	
	/*
		RELINVENT
	*/
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o produto inicio p/ pesquisa"}
	AjTpDroSx1 ("RELINVENT"	, "01"			, "Do Produto", "Do Produto"	,;
				"Do Produto", "MV_CH1"		, "C"		, 30				,;
				0			, 0				, "G"		, ""				,;
	            "SB1"		, "030"			, "S"		, "MV_PAR01"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELINVENT01"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o produto final p/ pesquisa"}
	AjTpDroSx1 ("RELINVENT"	, "02"			, "At� produto", "At� Produto"	,;
				"At� produto", "MV_CH2"		, "C"		, 30				,;
				0			, 0				, "G"		, ""				,;
	            "SB1"		, "030"			, "S"		, "MV_PAR02"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELINVENT02"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o lote inicial p/ pesquisa"}
	AjTpDroSx1 ("RELINVENT"	, "03"			, "Do Lote"	, "Do Lote"			,;
				"Do Lote"	, "MV_CH3"		, "C"		, 10				,;
				0			, 0				, "G"		, ""				,;
	            "SB8"		, "068"			, "S"		, "MV_PAR03"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELINVENT03"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o lote final p/ pesquisa"}
	AjTpDroSx1 ("RELINVENT"	, "04"			, "At� Lote", "At� Lote"		,;
				"At� Lote"	, "MV_CH4"		, "C"		, 10				,;
				0			, 0				, "G"		, ""				,;
	            "SB8"		, "068"			, "S"		, "MV_PAR04"		,;
				""			, ""			, ""		, ""				,;
	            ""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
				""			, ""			, ""		, ""				,;
	            aHelpPor	, aHelpEng		, aHelpSpa	, "RELINVENT04"		)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o Tipo de Medicamento"}
	AjTpDroSx1 ("RELINVENT"				, "05"			, "Tipo de Medicamento", "Tipo de Medicamento",;
				"Tipo de Medicamento"	, "MV_CH5"		, "C"		, 6				  	,;
				0						, 0				, "G"		, ""				,;
	            "LX5T8D"				, ""			, "S"		, "MV_PAR05"		,;
				""						, ""			, ""		, ""				,;
	            ""						, ""			, ""		, ""				,;
				""						, ""			, ""		, ""				,;
				""						, ""			, ""		, ""				,;
	            aHelpPor				, aHelpEng		, aHelpSpa	, "RELINVENT05"		)
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELINVENT" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta RELINVENT")
	
	/*
	RELRMV
	*/
	aHelpPor := aHelpEng := aHelpSpa := {'Per�odo a ser gerado o Relat�rio'}
	AjTpDroSx1("RELRMV","01","Per�odo ?","Periodo?"	,;
				"Periodo?"	,"MV_CH1"	,"D"		,8,;
				0			,	0		,"G"		,"!Empty(mv_par01)"	,;
				""			,	""		,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,"RELRMV01")
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o N�mero da Autoriza��o de Funcionamento'}
	AjTpDroSx1("RELRMV","02","Autorz. de Funcionamento","Autorz. de Funcionamento"	,;
				"Autorz. de Funcionamento"	,"MV_CH2"	,"C"		,30,;
				0			,	0		,"G"		,""	,;
				""			,	""		,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,"RELRMV02")
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o N�mero da Autoriza��o Especial'}
	AjTpDroSx1("RELRMV","03","Autoriza��o Especial","Autoriza��o Especial"	,;
				"Autoriza��o Especial"	,"MV_CH3"	,"C"		,30,;
				0			,	0		,"G"		,""	,;
				""			,	""		,"S"		,"MV_PAR03"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,"RELRMV03")
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o Nome do Representante Legal'}
	AjTpDroSx1("RELRMV","04","Nome do Representante Legal","Nome do Representante Legal"	,;
				"Nome do Representante Legal"	,"MV_CH4"	,"C"		,40,;
				0			,	0		,"G"		,"!Empty(MV_PAR04)"	,;
				""			,	""		,"S"		,"MV_PAR04"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,"RELRMV04")
	
	//Exclus�o de Pergunte RELRMV - ordem "05" pois foi criado errado
	SX1->(dbSetOrder( 1 ))
	If SX1->( DbSeek( PadR("RELRMV",Len( SX1->X1_GRUPO )) + "05" ))
		RecLock("SX1",.F.)
		SX1->(DbDelete())
		SX1->(DbCommit())
		SX1->(MsUnlock())
		cMensagem += "fun��o LjDrCriaX1 - Dele��o da pergunta RELRMV_05 (n�o ser� mais utilizada) " + _PLINHA
		ConOut("fun��o LjDrCriaX1 - Dele��o da pergunta RELRMV_05 (n�o ser� mais utilizada) ")
	EndIf
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELRMV" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta RELRMV")
	
	/*
	RELCOVISA
	*/	
	//Exclus�o de Pergunte RELCOVISA - para ajuste de numera��o
	SX1->(dbSetOrder( 1 ))
	If SX1->( DbSeek( PadR("RELCOVISA",Len( SX1->X1_GRUPO ))))
		While !SX1->(Eof()) .And. AllTrim(SX1->X1_GRUPO) == "RELCOVISA"
			RecLock("SX1",.F.)
			SX1->(DbDelete())
			SX1->(DbCommit())
			SX1->(MsUnlock())
			
			SX1->(DbSkip())
		End
		cMensagem += "fun��o LjDrCriaX1 - Dele��o da pergunta RELCOVISA (ajuste de numera��o) " + _PLINHA
		ConOut("fun��o LjDrCriaX1 - Dele��o da pergunta RELCOVISA (ajuste de numera��o) ")
	EndIf
	
	//Grava��o do novo SX1
	aHelpPor := aHelpEng := aHelpSpa := {'Informe a data inicial'}
	cX1_Pergunt := "Do Per�odo ?"
	cX1_Help := "RELCOVISA01"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"01"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH1"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe a data final'}
	cX1_Pergunt := "At� Per�odo ?"
	cX1_Help := "RELCOVISA02"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"02"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH2"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o produto inicial'}
	cX1_Pergunt := "Do Produto ?"
	cX1_Help := "RELCOVISA03"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"03"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH3"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB1"		,	"030"	,"S"		,"MV_PAR03"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o produto final'}
	cX1_Pergunt := "At� Produto ?"
	cX1_Help := "RELCOVISA04"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"04"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH4"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB1"		,	"030"	,"S"		,"MV_PAR04"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o lote inicial'}
	cX1_Pergunt := "Do Lote ?"
	cX1_Help := "RELCOVISA05"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"05"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH5"	,"C"		,10					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB8"		,	"068"	,"S"		,"MV_PAR05"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o lote final'}
	cX1_Pergunt := "At� Lote ?"
	cX1_Help := "RELCOVISA06"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"06"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH6"	,"C"		,10					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB8"		,	"068"	,"S"		,"MV_PAR06"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o CNPJ Inicial de Pesquisa do Fornecedor'}
	cX1_Pergunt := "De CNPJ Fornecedor"
	cX1_Help := "RELCOVISA07"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"07"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH7"	,"C"		,14					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR07"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o CNPJ Final de Pesquisa do Fornecedor'}
	cX1_Pergunt := "At� CNPJ Fornecedor"
	cX1_Help := "RELCOVISA08"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"08"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH8"	,"C"		,14					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR08"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o Nome Inicial do Prescritor'}
	cX1_Pergunt := "De Nome Prescritor"
	cX1_Help := "RELCOVISA09"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"09"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH9"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR09"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o Nome Final do Prescritor'}
	cX1_Pergunt := "At� Nome Prescritor"
	cX1_Help := "RELCOVISA10"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"10"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHA"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR10"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o Nome Inicial do Comprador'}
	cX1_Pergunt := "De Nome Comprador"
	cX1_Help := "RELCOVISA11"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"11"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHB"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR11"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o Nome Final do Comprador'}
	cX1_Pergunt := "At� Nome Comprador"
	cX1_Help := "RELCOVISA12"
	cX1_VALID:= ""
	AjTpDroSx1("RELCOVISA"	,"12"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHC"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR12"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {"Informe o Grupo da lista"}
	cX1_Pergunt := "Grupo da Lista"
	cX1_Help := "RELCOVISA13"
	cX1_DEF01:= "A1 e A2"
	cX1_DEF02:= "A3,B1 e B2"
	cX1_DEF03:= "C3"
	cX1_DEF04:= "C1,C2,C4,C5"
	cX1_DEF05:= "D1 e D2"
	cX1_VALID:= ""
	AjTpDroSx1 ("RELCOVISA"		, "13"		, cX1_Pergunt	, cX1_Pergunt		,;
				cX1_Pergunt		, "MV_CHD"	, "C"			, 20				,;
				0				, 0			, "C"			, cX1_VALID			,;
	            ""				, ""		, "S"			, "MV_PAR13"		,;
				cX1_DEF01		, cX1_DEF01	, cX1_DEF01		, ""				,;
	            cX1_DEF02		, cX1_DEF02	, cX1_DEF02		, cX1_DEF03			,;
				cX1_DEF03		, cX1_DEF03	, cX1_DEF04		, cX1_DEF04			,;
				cX1_DEF04		, cX1_DEF05	, cX1_DEF05		, cX1_DEF05			,;
	            aHelpPor		, aHelpEng	, aHelpSpa		, cX1_Help			)
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELCOVISA" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta RELCOVISA")
	
	/*
	RELSALDO
	*/	
	//Exclus�o de Pergunte RELSALDO - para ajuste de numera��o
	SX1->(dbSetOrder( 1 ))
	If SX1->( DbSeek( PadR("RELSALDO",Len( SX1->X1_GRUPO ))))
		While !SX1->(Eof()) .And. AllTrim(SX1->X1_GRUPO) == "RELSALDO"
			RecLock("SX1",.F.)
			SX1->(DbDelete())
			SX1->(DbCommit())
			SX1->(MsUnlock())
			
			SX1->(DbSkip())
		End
		cMensagem += "fun��o LjDrCriaX1 - Dele��o da pergunta RELSALDO (ajuste de numera��o) " + _PLINHA
		ConOut("fun��o LjDrCriaX1 - Dele��o da pergunta RELSALDO (ajuste de numera��o) ")
	EndIf
	
	//Grava��o do novo SX1
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o produto inicial'}
	cX1_Pergunt := "Do Produto ?"
	cX1_Help := "RELSALDO01"
	cX1_VALID:= ""
	AjTpDroSx1("RELSALDO"	,"01"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH1"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB1"		,	"030"	,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o produto final'}
	cX1_Pergunt := "At� Produto ?"
	cX1_Help := "RELSALDO02"
	cX1_VALID:= ""
	AjTpDroSx1("RELSALDO"	,"02"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH2"	,"C"		,30					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"SB1"		,	"030"	,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	aHelpPor := aHelpEng := aHelpSpa := {'Informe o tipo de medicamento'}
	cX1_Pergunt := "Tipo de Medicamento"
	cX1_Help := "RELSALDO03"
	cX1_VALID:= ""
	AjTpDroSx1("RELSALDO"	,"03"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH3"	,"C"		,6					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"LX5T8D"	,	""		,"S"		,"MV_PAR03"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)				
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta RELSALDO" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta RELSALDO")
	
	/*
	DROREL
	*/
	aHelpPor := {}	
	AAdd( aHelpPor, "Digite a filial inicial ou mantenha este ")
	AAdd( aHelpPor, "campo em branco para selecionar todas as ")
	AAdd( aHelpPor, "filiais.")
	
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Filial de ?"
	cX1_Help := "DROREL01"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"01"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH1"	,"C"		,2					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	"033"	,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}	
	AAdd( aHelpPor, "Digite a filial final ou preencha este ")
	AAdd( aHelpPor, "campo com 'ZZ' para selecionar todas as ")
	AAdd( aHelpPor, "filiais.")
	
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Filial ate ?"
	cX1_Help := "DROREL02"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"02"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH2"	,"C"		,2					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	"033"	,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,Replicate( "Z", FWGETTAMFILIAL ),;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
				
	aHelpPor := {}
	AAdd( aHelpPor, "Digite o codigo da empresa de Conv�nio ")
	AAdd( aHelpPor, "inicial.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Emp. Conv�nio de ?"
	cX1_Help := "DROREL03"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"03"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH3"	,"C"		,6					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"L54"		,	""		,"S"		,"MV_PAR03"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite a loja da empresa de Conv�nio ")
	AAdd( aHelpPor, "inicial.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Loja Conv�nio De ?"
	cX1_Help := "DROREL04"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"04"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH4"	,"C"		,2					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR04"			,;
				""			,	""		,""			,""			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite o codigo da empresa de Conv�nio ")
	AAdd( aHelpPor, "final.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Emp. Conv�nio At� ?"
	cX1_Help := "DROREL05"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"05"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH5"	,"C"		,6					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"L54"		,	""		,"S"		,"MV_PAR05"			,;
				""			,	""		,""			,"ZZZZZZ"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite o loja da empresa de convenio ")
	AAdd( aHelpPor, "final.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Loja Convenio At� ?"
	cX1_Help := "DROREL06"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"06"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH6"	,"C"		,2					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR06"			,;
				""			,	""		,""			,"ZZ"				,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite a data de emissao inicial dos ")
	AAdd( aHelpPor, "titulos de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de Emissao de ?"
	cX1_Help := "DROREL07"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"07"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH7"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR07"			,;
				""			,	""		,""			,"01/01/18"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite a data de emissao final dos ")
	AAdd( aHelpPor, "titulos de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de Emissao At� ?"
	cX1_Help := "DROREL08"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"08"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH8"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR08"			,;
				""			,	""		,""			,"31/12/18"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite a data de vencimento inicial ")
	AAdd( aHelpPor, "dos titulos de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de Vencto. de ?"
	cX1_Help := "DROREL09"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"09"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH9"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR09"			,;
				""			,	""		,""			,"01/01/18"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite a data de vencimento final ")
	AAdd( aHelpPor, "dos titulos de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de Vencto. At� ?"
	cX1_Help := "DROREL10"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"10"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHA"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR12"			,;
				""			,	""		,""			,"31/12/18"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite o numero do documento(cupom) ini- ")
	AAdd( aHelpPor, "cial para selecao dos dados de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Documento de ?"
	cX1_Help := "DROREL11"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"11"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHB"	,"C"		,9					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	"018"	,"S"		,"MV_PAR11"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Digite o numero do documento(cupom) final ")
	AAdd( aHelpPor, "para selecao dos dados de convenio.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Documento At� ?"
	cX1_Help := "DROREL12"
	cX1_VALID:= ""
	AjTpDroSx1("DROREL"		,"12"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHC"	,"C"		,9					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	"018"	,"S"		,"MV_PAR12"			,;
				""			,	""		,""			,"ZZZZZZZZZ"		,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Selecione a forma de visualizacao: ")
	AAdd( aHelpPor, "cabecalho ou itens do documento ou ")
	AAdd( aHelpPor, "total por conveniado.")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Visualizacao ?"
	cX1_Help := "DROREL13"
	cX1_VALID:= ""
	cX1_DEF01:= "Cabecalho da NF"
	cX1_DEF02:= "Itens da NF"
	cX1_DEF03:= "Total"
	AjTpDroSx1("DROREL"		,"13"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CHD"	,"N"		,1					,;
				0			,	0		,"C"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR13"			,;
				cX1_DEF01	,cX1_DEF01	,cX1_DEF01	,""					,;
				cX1_DEF02	,cX1_DEF02	,cX1_DEF02	,cX1_DEF03			,;
				cX1_DEF03	,cX1_DEF03	,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta DROREL" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta DROREL")
	
	/*
	DROPER
	*/
	aHelpPor := {}
	AAdd( aHelpPor, "Informe a Data Inicial")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de ?"
	cX1_Help := "DROPER01"
	cX1_VALID:= ""
	AjTpDroSx1("DROPER"		,"01"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH1"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Informe a Data Final")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data At� ?"
	cX1_Help := "DROPER02"
	cX1_VALID:= ""
	AjTpDroSx1("DROPER"		,"02"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH2"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Motivo da Perda, deixar em branco, trar� todos")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Motivo de Perda?"
	cX1_Help := "DROPER03"
	cX1_VALID:= ""
	AjTpDroSx1("DROPER"		,"03"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH3"	,"C"		,2					,;
				0			,	0		,"G"		,cX1_VALID			,;
				"LX5T6"		,	""		,"S"		,"MV_PAR03"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta DROPER" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta DROPER")
	
	/*
	DROXML
	*/
	aHelpPor := {}
	AAdd( aHelpPor, "Informe a Data Inicial")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data de ?"
	cX1_Help := "DROXML01"
	cX1_VALID:= ""
	AjTpDroSx1("DROXML"		,"01"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH1"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR01"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)

	aHelpPor := {}
	AAdd( aHelpPor, "Informe a Data Final")
	aHelpEng := aHelpSpa := aHelpPor
	cX1_Pergunt := "Data At� ?"
	cX1_Help := "DROXML02"
	cX1_VALID:= ""
	AjTpDroSx1("DROXML"		,"02"		,cX1_Pergunt,cX1_Pergunt		,;
				cX1_Pergunt	,"MV_CH2"	,"D"		,8					,;
				0			,	0		,"G"		,cX1_VALID			,;
				""			,	""		,"S"		,"MV_PAR02"			,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				""			,	""		,""			,""					,;
				aHelpPor	,	aHelpEng,aHelpSpa	,cX1_Help)
	cMensagem += "fun��o LjDrCriaX1 - Criado a pergunta DROXML" + _PLINHA
	ConOut("fun��o LjDrCriaX1 - Criado a pergunta DROXML")				
	
	//Final da Execu��o
	cMensagem += " Final da fun��o LjDrCriaX1 - Cria��o de Perguntas" + _PLINHA
	Conout(" Final da fun��o LjDrCriaX1 - Cria��o de Perguntas")
	
	If lIsRBe
		lGerado := .T.
		Conout("Cria��o de SX1 via RBE_LOJA")	
	Else
		nHdlTXT := FCreate(cPath + cNomArq,0) 
		If nHdlTXT > 0 
			If FError() <> 0
				cMensagem += " fun��o LjDrCriaX1 - Erro na cria��o do arquivo de confer�ncia de cria��o de Help," +;
				 			"verifique permiss�o de acesso as pastas" + _PLINHA
				Conout(" fun��o LjDrCriaX1 - Erro na cria��o do arquivo de confer�ncia de cria��o de Help," +;
				 	"verifique permiss�o de acesso as pastas")
			Else
				FWrite(nHdlTXT,"Helps de Template de Drogaria inseridos em " + Dtoc(dDataBase))
				FClose(nHdlTXT)
				lGerado := .T.
			EndIf
		EndIf
	EndIf
EndIf

If lIsRBe
	Conout("Fim da execu��o LjDrCriaX1 via RBE_LOJA - Cria��o com Sucesso ? [" + IIf(lGerado, "SIM", "N�O") + "]")
Else	
	If lExistFile
		LjGrvLog("LjDrCriaX1", " Helps Existentes [caso necess�rio reiniciar os helps" +;
							" apague o arquivo: (" + cPath + cNomArq +") ]")
		Conout(" Fun��o LjDrCriaX1 - Helps Existentes [caso necess�rio reiniciar os helps" +;
							" apague o arquivo: (" + cPath + cNomArq +") ]")
	ElseIf lGerado
		LjGrvLog("LjDrCriaX1", " Helps Criados com Sucesso [caso necess�rio reiniciar os arquivos" +;
							" apague o arquivo (" + cPath + cNomArq +") ]")
		Conout(" Fun��o LjDrCriaX1 - Helps Criados com Sucesso [caso necess�rio reiniciar os arquivos" +;
							" apague o arquivo (" + cPath + cNomArq +") ]")
	Else
		LjGrvLog("LjDrCriaX1", " Aten��o ! Sinalizador de Helps de Template n�o foram criados. Verifique permiss�o de acesso/cria��o no caminho [" + cPath +"]")
		Conout(" Fun��o LjDrCriaX1 - Aten��o ! Sinalizador de Helps de Template n�o foram criados. Verifique permiss�o de acesso/cria��o no caminho [" + cPath +"]")
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroItemAnvisa

Restaura as informa��es referentes a ANVISA para dar continuidade a venda

@owner  	Varejo

@author  	Varejo
@version 	V12
@since   	06/04/2017 
/*/
//------------------------------------------------------------------------------
Template Function DroItemANVISA(nItem, cProd, lInfoAnvisa, lCopyAnvisa, ;
								_nPosItem)
Local lRet		:= .T.		
Local lInclusao	:= .F.
Local nLinha 	:= 0
Local nI		:= 0

Default cProd	:= ""
Default lInfoAnvisa := .F. //Solicita replicar intem anterior
Default lCopyAnvisa := .F. //Ja informou anvisa e permite a copia do dado
Default _nPosItem := 0 //Posicao do item

If !Empty(cProd)		//Se vier produto, veio da tela de altera��o da aprova��o de medicamentos. Eu passo o produto e recebo o n�mero da linha correto.
	nLinha := T_DroProdAnvisa(cProd)
ElseIf T_DroExisANVISA(nItem)
	nLinha := T_DroPosANVISA(nItem)		
EndIf

If !lCopyAnvisa 
	If (nLinha <= Len(aAnvisa)) .AND. (nLinha > 0) .AND. (Len(aAnvisa) > 0)		//Encontrado
		lInclusao := .F.
		lRet := .T.
	ElseIf nLinha = 0 .AND. nItem > 1 .AND. Len(aAnvisa) > 0	//N�o encontrado, entendemos como inclus�o se o nLinha for maior que 1
		lInclusao := .T.
		nLinha := Len(aAnvisa)	//Volto 1 linha e leio o �ltimo item, repetindo o nome, crm do m�dico, etc.
		lRet := .T.
	Else
		lRet := .F.
	EndIf
ElseIf lInfoAnvisa
	lInclusao := .T.
	nLinha := _nPosItem	//Posicao do item
	lRet := .T.
Else
	lRet := .F.
EndIf

If lRet
	//����������������������������������������������������������������������������������Ŀ
	//�Restaurando o array aAuxANVISA (refente a informacoes do cliente, medico, receita)�
	//�Sempre restaura com as informacoes do ultimo item informado na venda              |
	//������������������������������������������������������������������������������������
	M->LK9_NOME					:= aANVISA[nLinha][NOME]      //1		Nome do cliente
	M->LK9_TIPOID				:= aANVISA[nLinha][TIPOID]    //2		Tipo de identificacao do cliente
	M->LK9_NUMID				:= aANVISA[nLinha][NUMID]     //3		Numero de identificacao do cliente
	M->LK9_ORGEXP				:= aANVISA[nLinha][ORGEXP]    //4		Orgao Expedidor
	M->LK9_UFEMIS				:= aANVISA[nLinha][UFEMIS]    //5		Unidade Federativa
	M->LK9_NUMREC				:= aANVISA[nLinha][RECEITA]   //6		Numero da receita medica
	M->LK9_TIPREC				:= aANVISA[nLinha][TPRECEITA] //7		Tipo da receita medica
	M->LK9_TIPUSO				:= aANVISA[nLinha][TPUSO]     //8		Tipo de uso da receita medica
	M->LK9_DATARE				:= aANVISA[nLinha][DATRECEITA]//9		Data da receita medica
	M->LK9_NOMMED				:= aANVISA[nLinha][MEDICO]    //10		Nome do medico
	M->LK9_NUMPRO				:= aANVISA[nLinha][CRM]       //11		CRM do medico
	M->LK9_CONPRO				:= aANVISA[nLinha][CONPROF]   //12		Conselho profissional do medico
	M->LK9_UFCONS				:= aANVISA[nLinha][UFCONS]    //13		Unidade federativa do conselho profissional do medico
	
	If !lInclusao
		M->LK9_LOTE					:= aANVISA[nLinha][LOTEPROD] 	//14 Lote
		M->LK9_CODPRO				:= aANVISA[nLinha][PRODUTO]		//15 Codigo do Produto
		M->LK9_DESCRI			   	:= aANVISA[nLinha][DESCPRO]		//20 Descricao do Produto
		M->LK9_QUANT				:= aANVISA[nLinha][QTDEPROD]	//16 Quantidade
		M->LK9_NUMDOC				:= aANVISA[nLinha][NUMDOC]		//17 Numero do Doc
		M->LK9_SERIE				:= aANVISA[nLinha][SERIE]		//18 Serie do Documeto
		M->LK9_UM			    	:= aANVISA[nLinha][UM]			//19 Unidade de Medida do produto
		M->LK9_REGMS			   	:= aANVISA[nLinha][REGMS]		//23 Registro do produto no Ministerio da Saude
		M->LK9_USOPRO				:= aANVISA[nLinha][USOPROLONG]	//27 Uso Prolongado
	EndIf
	
	M->LK9_NUMORC			   	:= aANVISA[nLinha][NUMORC]			//22     Numero do Orcamento 
	M->LK9_END					:= aANVISA[nLinha][ENDERECO]		//24 Endereco do cliente	 					
	M->LK9_NOMEP				:= aANVISA[nLinha][NPACIENTE]		//25 Nome Paciente
	M->LK9_IDADEP				:= aANVISA[nLinha][IDADEP]			//28 Idade Paciente 
	M->LK9_UNIDAP				:= aANVISA[nLinha][UNIDAP]			//29 Unidade da Idade
	M->LK9_SEXOPA				:= aANVISA[nLinha][SEXOPA]			//30 Sexo Paciente
	M->LK9_CIDPA				:= aANVISA[nLinha][CIDPA]			//31 Co. Inter. doenca Pac.
	M->LK9_QUANTP				:= aANVISA[nLinha][QUANTP]			//32 Quantidade Prescrita

	If Len(aLK9Usr) > 0
		For nI := 1 to Len(aLK9Usr[nLinha])
			M->&(aLK9Usr[nLinha][nI][1]) := aLK9Usr[nLinha][nI][2]
		Next
	EndIf

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroGrLk9

Gravo os dados alterados na tabela LK9

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	19/04/2017 
/*/
//------------------------------------------------------------------------------
Template Function DroGrLk9(aCampos)
Local nX 		:= 0			//Contador
Local cNumOrc	:= M->LK9_NUMORC //Consulto o or�amento
Local cProd		:= M->LK9_CODPRO 

//Consulto o produto
DbSelectArea("LK9")
LK9->(DbSetOrder(6))	//LK9_FILIAL+LK9_NUMORC
//Verifico o produto
If LK9->(DbSeek(xFilial("LK9")+cNumOrc))
	While !(LK9->(EOF())) .AND. LK9->LK9_NUMORC = cNumOrc
		//O motivo � que n�o h� indice criado. Utilizei por Filial e n�mero do or�amento. E n�o h� liga��o com itens, somente com C�d. Produto
		If Alltrim(LK9->LK9_CODPRO) == Alltrim(cProd)
			RecLock("LK9", .F.)
			For nX := 1 to Len(aCampos)
				REPLACE LK9->&(aCampos[nX][2]) WITH M->&(aCampos[nX][2]) 			
			Next
			LK9->(MsUnLock())
		EndIf
		LK9->(DbSkip()) 
	EndDo
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroProdAnvisa

Retorna a posi��o do ID no array ANVISA, passando o c�digo do produto LK9

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	26/04/2017 
/*/
//------------------------------------------------------------------------------
Template Function DroProdANVISA(cProd)
Local nPosId := 0		//Posicao do item no array aANVISA	

nPosId := Ascan(aANVISA,{|x| x[PRODUTO] == cProd })

Return nPosId

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroIsFrm
Verifica se o usu�rio est� cadastrado como Farmaceutico
@owner  	Varejo
@author  	michael.gabriel
@version 	V12
@since   	19/09/2017 
@param		lErrorMsg	Se exibe a mensagem de erro
/*/
//------------------------------------------------------------------------------
Template Function DroIsFrm(lErrorMsg)
Local lRet			:= .F.

Default lErrorMsg 	:= .T.

If TableInDic( "LKB", .F./*lHelp*/)
	//posiciona no farmaceutico
	DbSelectArea("LKB")
	LKB->( DbSetOrder(3) )	//LKB_FILIAL+LKB_CUSERI
	lRet := LKB->( DbSeek(xFilial("LKB") + RetCodUsr()) )	//LKB_FILIAL+LKB_CUSERI
	If !lRet .AND. lErrorMsg
		MsgInfo("O usu�rio " + UsrFullName() + " n�o consta no cadastro de Farmac�uticos." +;
				CRLF + "Por favor, fa�a o cadastro atrav�s da rotina Farmaceuticos")
	EndIf
ElseIf lErrorMsg
	MsgStop("A tabela LKB n�o existe." + CRLF + "Por favor, atualiza seu dicion�rio de dados")
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroDocAnvisa
chamada da fun��o FrtEntreg, para atualizar os dados da NFCe
@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	10/10/2017 
/*/
//------------------------------------------------------------------------------
Template Function DroDocAnvisa(_cDoc, _cSerie) 
Local nLinha 		:= 0 // linha do array aAnvisa
Local nTamANVISA 	:=  0 //Tamanho do array aAnvisa

If !Empty(_cDoc) .AND. !Empty(_cSerie)
	nTamANVISA := T_DroLenANVISA() 
	
	For nLinha := 1 to nTamANVISA
		aANVISA[nLinha][NUMDOC]     := _cDoc
		aANVISA[nLinha][SERIE]      := _cSerie
	Next nLinha
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} DroVlCpUso
fun��o para validar os campos:
  - LK9_TIPUSO
@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	27/12/2018 
/*/
//------------------------------------------------------------------------------
Template Function DroVlCpUso()

IF RTrim(M->LK9_TIPUSO) == '2'
	M->LK9_CONPRO	:= 'CRMV'
	M->LK9_NOME		:= Space(TamSX3("LK9_NOME")[1])
	M->LK9_NOMEP	:= Space(TamSX3("LK9_NOMEP")[1])
	M->LK9_IDADEP	:= 0
	M->LK9_SEXOPA	:= Space(TamSX3("LK9_SEXOPA")[1])
	M->LK9_UNIDAP	:= Space(TamSX3("LK9_UNIDAP")[1])
EndIf

Return .T.

/*/{Protheus.doc} LjIsDro
	Valida o template de Drogaria conforme o CNPJ
	@type  Function
	@author Julio.Nery
	@since 29/01/2021
	@version 12
	@param nenhum
	@return lRet, logico, confirma uso de TPL Dro?
/*/
Function LjIsDro()
Local aSM0 := FWLoadSM0()
Local lRet := .F.
Local nX   := 0	

For nX := 1 to Len(aSM0)
	If AllTrim(aSM0[nX][18]) == "53113791000122"
		lRet := .T.
		Exit
	EndIf
Next nX

Return lRet