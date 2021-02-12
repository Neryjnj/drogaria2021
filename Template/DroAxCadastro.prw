#INCLUDE "PROTHEUS.CH"
#INCLUDE "DROAXCADAS.CH" 
#INCLUDE "TCBROWSE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "MSMGADD.CH"                                

/*Fonte contendo algumas telas de Cadastro do Template Drogaria.
(Telas SIMPLES).                                            */
Static cCampoPk   	:= ""											//Armazena campo chave(PK) do cadastro para n�o permitir altera��i do mesmo quando operando em offline                        	
Static lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Static lMvLjPdvPa   := LjxBGetPaf()[2] //Indica se � pdv 
Static nDiasRev 	:= SuperGetMv("MV_DROREV", Nil, 7)					//Determina o numero de dias que sera possivel realizar ajuste no livro                                
Static cCaixaSup	:= Space(25)
Static lCpoGrpMHB	:= .F.

/*���������������������������������������������������������������������������
���Programa  � DroAxMHA � Autor � Vendas Clientes    � Data � 29/03/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Principio Ativo	                              ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxMHA()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

AxCadastro("MHA","Cadastro de Principio Ativo"  ,".T.",".T." ,;
            Nil		,{||DroAxAlter(MHA->MHA_CODIGO,"MHA","MHA")})
Return

/*���������������������������������������������������������������������������
���Programa  � DroAxMHB � Autor � Vendas Clientes    � Data � 29/03/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Apresentacao                                   ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxMHB()
/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf	 

AxCadastro(	"MHB"	,"Cadastro de Apresentacao"	,Nil	,"DroAxValid(M->MHB_CODAPR, 'MHB_CODAPR' )"	,;
           	Nil		,{||DroAxAlter(MHB->MHB_CODAPR,"MHB","MHB")}			,Nil	,Nil	,;
			{ ||DroAxAltOk("030","MHB",MHB->MHB_CODAPR + MHB->MHB_APRESE,1) })
                                             
Return

/*���������������������������������������������������������������������������
���Programa  � DroAxMHC � Autor � Vendas Clientes    � Data � 29/03/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Similaridade de Preco                          ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxMHC()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

// Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf	 

AxCadastro(	"MHC"	,"Similaridade de Preco"	,Nil	,"DroAxValid(M->MHC_CODSIM, 'MHC_CODSIM' )"	,;
           	Nil		,{||DroAxAlter(MHC->MHC_CODSIM,"MHC","MHC")}			,Nil	,Nil	,;
			{ ||DroAxAltOk("026","MHC",MHC->MHC_CODSIM + MHC->MHC_DESIMI,1) })

Return

/*���������������������������������������������������������������������������
���Programa  � DroAxLEO � Autor � Vendas Clientes    � Data � 29/03/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Controle de Produto                            ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxLEO()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

AxCadastro("LEO"    ,"Tipos de Controle"        ,"DroLeoExcl(LEO->LEO_CODCON)",".T." ,;
            Nil		,{||DroAxAlter(LEO->LEO_CODCON,"LEO","LEO")})

Return


/*���������������������������������������������������������������������������
���Programa  � DroAxLHG � Autor � Vendas Clientes    � Data � 29/07/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � TABELA DE HISTORICO DE PONTUACAO E MOVIMENTO DO CLIENTE    ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxLHG()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

AxCadastro("LHG","Tabela de Historico de Pontuacao e Movimentos do Cliente",".T.",".T.")

Return

/*���������������������������������������������������������������������������
���Programa  � DroAxLHH � Autor � Vendas Clientes    � Data � 11/08/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Tabela de Brindes e Beneficios                             ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxLHH()
/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

AxCadastro("LHH","Tabela de Brindes e Beneficios",".T.",".T.")

Return

/*���������������������������������������������������������������������������
���Programa  � DroAxLIP � Autor � Vendas Clientes    � Data � JAN/2005    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Patologia			                          ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function DroAxLIP()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

AxCadastro("LIP","Cadastro de Patologias","DrolipExcl(LIP->LIP_CODIGO)", ".T." ,;
            Nil	,{||DroAxAlter(LIP->LIP_CODIGO,"LIP","LIP")})

Return

/*���������������������������������������������������������������������������
���Programa  �DroAxLIO  � Autor � Vendas Clientes    � Data �  02/02/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Numeros de Cartoes                             ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
���������������������������������������������������������������������������*/
Template Function DroAxLIO()

Private cCadastro 	:= "Visualiza��o dos Cart�es Gerados"
Private aRotina		:= MenuDef()
Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "LIO"

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

dbSelectArea("LIO")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

/*�����������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 11.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Template Drogarias                                         ���
���������������������������������������������������������������������������*/
Static Function MenuDef()
	Local aRotina := {	{"Pesquisar"	,"AxPesqui"	,0	,1	,0	,.F.	}	,;
	                 	{"Visualizar"	,"AxVisual"	,0	,2	,0	,.T.	}	}
Return aRotina

/*���������������������������������������������������������������������������
���Programa  �DroAxLFX  � Autor � Vendas Clientes    � Data �  02/02/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Configuracoes de Cartoes                       ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
���������������������������������������������������������������������������*/
Template Function DroAxLFX()

AxCadastro("LFX","Cadastro de Configura��o de Cart�o")

Return .T.

/*���������������������������������������������������������������������������
���Programa  �DroAxLFW  � Autor � Vendas Clientes    � Data �  02/02/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Situacao de Bloqueio		                      ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
���������������������������������������������������������������������������*/
Template Function DroAxLFW()

AxCadastro("LFW","Cadastro de Situa��o de Bloqueio")

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DroAxLKA  � Autor � Vendas Clientes    � Data �  23/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Medicos             		                      ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DroAxLKA()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf	 

AxCadastro("LKA","Cadastro de M�dicos" ,NIL , NIL ,;
            Nil		,{||DroAxAlter(LKA->LKA_CONPRO,"LKA","LKA")})

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DroAxLKB  � Autor � Vendas Clientes    � Data �  23/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Farmaceuticos       		                      ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DroAxLKB()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

AxCadastro("LKB","Cadastro de Farmac�uticos" ,NIL ,NIL, Nil, {||DroAxAlter(LKB->LKB_CPF,"LKB","LKB")})

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DroAxLK9  � Autor � Vendas Clientes    � Data �  23/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Logs ANVISA                     		                      ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function DroAxLK9()

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

AxCadastro("LK9", ;
		   "Logs ANVISA",;
		   NIL,;
		   NIL,;
           Nil,;
           {||DroAxAlter(LK9->LK9_DOC,"LK9","LK9")},; 
           {||DroAxVld(LK9->LK9_DOC,"LK9")})

Return .T.


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �DroAxVld     � Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao � Logs ANVISA              	       		                      ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function DroAxVld( cCampo,_cAlias )

Local lRet := .T.

DEFAULT cCampo		:= ""			// Parametro com o campo chave
DEFAULT _cAlias		:= ""			

If lAmbOffLn
	cCampoPk := cCampo
EndIf

If ALTERA .AND. !Empty(_cAlias) 
	If _cAlias == "LK9" .AND. ((LK9->LK9_DATA + nDiasRev) < dDataBase )
	    lRet   := .F.
	    Alert("Altera��o n�o permitida, periodo excedido para ajuste no registro do livro")
	EndIf   
Endif

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DroVSNGPC     � Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao � Logs ANVISA              	       		                      ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DroVSNGPC(lF12		, lTela		, cCliente	, cLoja			,;
							cClassTe	, nItem		, cProd		, lInfoAnvisa	,;
							lJaAnvisa	, _nPosItem	, lAcessoLib)
Local nI			:= 0
Local nX			:= 0
Local lRet			:= .F.	    // Retorno da funcao
Local oDlgLoja                  // objeto da tela
Local bOk						// Botao Ok da Enchoice Bar
Local bCancel					// Botao Cancel da Enchoice Bar
Local aCampos	 	:= {}		// Array com os campos para o Msmget
Local aCamposAux    := {}
Local aMemoria		:= {}		//Array que armazena memoria dos campos digitados anteriormente
Local nTamArray     := 0		//Tamanho do array aCamposAux      
Local lDrVlApro		:= IsInCallStack("T_DroVlApr")	//Ver se veio da fun��o da Aprova��o de Medicamentos
Local aDroPELK9		:= {}		// retorno do ponto de entrada DROPELK9 [1] campos do template [2] campos do usuario
Local aCposNObr     := {}
Local lAntM			:= .F. 		//Medicamento antimicrobiano
Local cSupervisor	:= Space(25)
Local lContinua		:= .T.

Default cCliente	:= ""
Default cLoja		:= ""
Default cClassTe	:= ''
Default	nItem		:= 1
Default cProd		:= ""
Default lInfoAnvisa := .F.
Default lJaAnvisa	:= .F.
Default _nPosItem	:= 0
Default lAcessoLib	:= .F.

If !lAcessoLib .And. !LjProfile(42,@cSupervisor)
	MsgStop("Usu�rio n�o tem permiss�o para venda de medicamentos controlados")
	lContinua := .F.
EndIf

If lContinua
	If nModulo == 23
		cClassTe := Alltrim(SBI->BI_CLASSTE)	
	Else
		cClassTe := Alltrim(SB1->B1_CLASSTE)	
	Endif
	
	lAntM := AllTrim(cClassTe) == "1"
	
	If cClassTe == "1" //Antimicrobiano	
		aCposNObr := {"LK9_CIDPA","LK9_TIPOID", "LK9_NOMEP","LK9_IDADEP", "LK9_UNIDAP", "LK9_SEXOPA", "LK9_NOME", "LK9_TIPOID","LK9_NUMID", "LK9_ORGEXP", "LK9_END", "LK9_UFEMIS"}	
	ElseIf cClassTe == "2"
		aCposNObr := {"LK9_CIDPA", ,"LK9_NOMEP","LK9_IDADEP","LK9_UNIDAP","LK9_SEXOPA","LK9_USOPRO","LK9_QUANTP"}
	EndIf
	
	aCamposAux := {	"LK9_NOME"	,;
					"LK9_TIPOID",;
					"LK9_NUMID" ,;
					"LK9_ORGEXP",;
					"LK9_UFEMIS",;
					"LK9_NUMREC",;
					"LK9_TIPREC",;
					"LK9_TIPUSO",;
					"LK9_DATARE",;
					"LK9_NOMMED",;
					"LK9_NUMPRO",;
					"LK9_CONPRO",;
					"LK9_UFCONS",;
					"LK9_LOTE"  ,;
					"LK9_END"	,;
					"LK9_NOMEP"	,;
					"LK9_USOPRO",;
					"LK9_IDADEP",;
					"LK9_UNIDAP",;
					"LK9_SEXOPA",;
					"LK9_CIDPA"	,;
					"LK9_QUANTP" }
	
	nTamArray := Len( aCamposAux )
	
	//Checa o ponto de entrada para o tratamento dos campos. Dever� ser utilizado para novos campos da tabela LK9. Ir� substituir o conte�do original passado l� em cima
	If ExistBlock( "DROPELK9", .F., .F. )
		LjGrvLog( Nil , "Antes da chamado do PE DROPELK9",aCamposAux)
		aDroPELK9 := ExecBlock( "DROPELK9", .F., .F., {aCamposAux} )
		LjGrvLog( Nil , "Depois da chamado do PE DROPELK9",aDroPELK9)
	
		If ValType(aDroPELK9) == "A"
			aSize(aCamposAux,0)
			// Dois loops por causa que ele adiciona os campos do Template e depois os campos do Usuario (se houver)
			For nI := 1 to Len(aDroPELK9)
				For nX := 1 to Len(aDroPELK9[nI])
					If LK9->( ColumnPos( aDroPELK9[nI][nX]) ) > 0
						Aadd( aCamposAux, aDroPELK9[nI][nX] )
					EndIf
				Next
			Next
		EndIf
		nTamArray := Len( aCamposAux )	//Tamanho do array aCamposAux
	EndIf
	
	If (lInfoAnvisa .AND. _nPosItem > 0 )
		//Coloca os campos lote e uso prolongado no topo da janela
		If (nX :=  aScan(aCamposAux, { |c| c == "LK9_LOTE"})) > 0
			aDel(aCamposAux, nX)
			aIns(aCamposAux, 1)
			aCamposAux[1] := "LK9_LOTE"
		EndIf
	
		If (nX :=  aScan(aCamposAux, { |c| c == "LK9_USOPRO"})) > 0
			aDel(aCamposAux, nX)
			aIns(aCamposAux, 2)
			aCamposAux[2] := "LK9_USOPRO"
		EndIf
	EndIf
	
	RegToMemory( "LK9", .T. )
	
	If !lDrVlApro .OR.  (lInfoAnvisa .AND. _nPosItem > 0 )			//Caso n�o veio da tela de aprova��o de medicamentos. Se veio da tela da Venda Assistida, preciso recuperar os dados digitados ao incluir um item novo.
		T_DroItemAnvisa( nItem, Nil, lInfoAnvisa, lJaAnvisa,_nPosItem )
	EndIf
	
	For nX := 1 to nTamArray
		SX3->( DbSetOrder( 2 ) )		//X3_CAMPO
	
		If SX3->( DbSeek( PadR(aCamposAux[nX],10) ) )
			If M->&( SX3->X3_CAMPO ) == NIL
				M->&( SX3->X3_CAMPO ) := CriaVar( SX3->X3_CAMPO )
			Endif
			If   !(RTrim(SX3->X3_CAMPO) $ "LK9_NOMEP/LK9_IDADEP/LK9_UNIDAP/LK9_SEXOPA/LK9_CONPRO") .AND.;
				 !(RTrim(SX3->X3_CAMPO) == "LK9_LOTE" .AND. nModulo == 12 .AND. lF12 .AND. lTela)
				 
				 	ADD FIELD aCampos TITULO  X3TITULO()  ;
								  CAMPO   SX3->X3_CAMPO   ;
								  TIPO    SX3->X3_TIPO    ;
								  TAMANHO SX3->X3_TAMANHO ;
								  DECIMAL SX3->X3_DECIMAL ;
								  PICTURE PesqPict( "LK9", SX3->X3_CAMPO ) ;
								  VALID   T_DROVldInfo();
								  NIVEL 1 ;   
								  INITPAD &(SX3->X3_RELACAO);
								  F3 If(SX3->X3_CAMPO == PadR("LK9_LOTE",10),If(nModulo == 12 .AND. !lMvLjPdvPa, SX3->X3_F3, ),SX3->X3_F3) ;
								  BOX SX3->X3_CBOX  
	
			ElseIf ( RTrim(SX3->X3_CAMPO) == "LK9_LOTE" .AND. nModulo == 12 .AND. lF12 .AND. lTela) .OR.;
					( AllTrim(SX3->X3_CAMPO) $ "LK9_LOTE|LK9_USOPRO" .AND. lInfoAnvisa .AND. _nPosItem > 0)
					
					ADD FIELD aCampos TITULO  X3TITULO()      ;
								  CAMPO   SX3->X3_CAMPO   ;
								  TIPO    SX3->X3_TIPO    ;
								  TAMANHO SX3->X3_TAMANHO ;
								  DECIMAL SX3->X3_DECIMAL ;
								  PICTURE PesqPict( "LK9", SX3->X3_CAMPO ) ;
								  VALID   T_DROVldInfo();
								  NIVEL 1 ;   
								  INITPAD &(SX3->X3_RELACAO);
								  F3 If(SX3->X3_CAMPO == PadR("LK9_LOTE",10),If(nModulo == 12 .AND. !lMvLjPdvPa, SX3->X3_F3, ),SX3->X3_F3) ;
								  BOX SX3->X3_CBOX ;
								  WHEN { || .F. }
	
			Else
					ADD FIELD aCampos TITULO  X3TITULO()      ;
								  CAMPO   SX3->X3_CAMPO   ;
								  TIPO    SX3->X3_TIPO    ;
								  TAMANHO SX3->X3_TAMANHO ;
								  DECIMAL SX3->X3_DECIMAL ;
								  PICTURE PesqPict( "LK9", SX3->X3_CAMPO ) ;
								  VALID   T_DROVldInfo();
								  NIVEL 1 ;   
								  INITPAD &(SX3->X3_RELACAO);
								  F3 If(SX3->X3_CAMPO == PadR("LK9_LOTE",10),If(nModulo == 12 .AND. !lMvLjPdvPa, SX3->X3_F3, ),SX3->X3_F3) ;
								  BOX SX3->X3_CBOX ;
								  WHEN { || RTrim(M->LK9_TIPUSO) <> '2'}
			Endif
	
			If !Empty(cClassTe) .AND. aScan(aCposNObr, { |c| c == AllTrim(SX3->X3_CAMPO)}) = 0
				aCampos[nX][08] := .T. //Campos Obrigat�rios
			EndIf
	
		EndIf 
	Next nX
	
	If lDrVlApro 		//Se veio da tela de aprova��o de medicamentos, eu passo para o array aAnvisa. O SL1 est� ponteirado de acordo com o or�amento
		T_DroRestAnvisa()
		T_DroItemAnvisa(1,cProd)
	EndIf 
	
	//�����������������������������������������������������Ŀ
	//�Verifica se a tela ANVISA foi acionada pela tecla F12�
	//�������������������������������������������������������
	If lF12
		aMemoria := T_DroCapANVISA(aCampos)
		If Len(aMemoria) > 0 
			For nX := 1 to Len(aMemoria)
				M->&( aCamposAux[nX]) := aMemoria[nX]
			Next nX
		Endif
	Endif
	                                                            
	DEFINE MSDIALOG oDlgLoja FROM 40,5 TO 430,640 TITLE "SNGPC - Venda de Medicamentos Controlados (ANVISA)" PIXEL STYLE DS_MODALFRAME
	
		oEnchoice := MsMGet():New( "LK9"	, NIL, 3	, NIL	,;
									NIL		, NIL, NIL	, NIL	,;
									NIL		, NIL, NIL	, NIL	,;
									NIL		, NIL, NIL	, NIL	,;
									NIL		, NIL, NIL	, .T.	,;
									aCampos	, NIL )                             
									
		/* 
		Paga os dados da tabela	SA1 para preenchimento dos campos nome e endereco
		//
		lDrVlApro - Se veio da tela de aprova��o de medicamentos, n�o preciso ler o nome no cadastro de clientes. 
					Ir� alterar ou n�o o nome digitado na Venda Assistida.
		*/ 
		If !lDrVlApro	
			T_DroAnviDad(cCliente,cLoja)
		EndIf	
		
		//Inicio automatico para testes, pode ser ponto de entrada posteriormente -11122015
		If nModulo == 12
			M->LK9_TIPREC := SB1->B1_CODLIS
		Else
			M->LK9_TIPREC := SBI->BI_CODLIS
		EndIf
									
		//���������������������������������������������������������������������Ŀ
		//� Define os blocos de codigo para os botoes "Ok" e "Cancel" da dialog �
		//�����������������������������������������������������������������������
		bOk		:= {|| lRet := .T., If(T_DroVldTela(lRet, aCampos,@cClassTe), If(T_DroTempLK9(lRet, aCampos, lTela, lF12), oDlgLoja:End(),),.F.)}
		bCancel	:= {|| lRet := .F., oDlgLoja:End()}
		
		//����������������������������������������������������������������Ŀ
		//� Nao permite que o usuario saia da tela clicando "ESC"          �
		//������������������������������������������������������������������
		oDlgLoja:lEscClose := .F. 
	
	ACTIVATE MSDIALOG oDlgLoja CENTERED ON INIT EnchoiceBar( oDlgLoja, bOk, bCancel, Nil, Nil )

EndIf

Return lRet             

/*�������������������������������������������������������������������������������
���Programa  �DroLoteANVISA � Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao � Digitacao do lote do produto	       		                      ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DroLoteANVISA()
Local nX		 := 0		//Controle de loop
Local lRet		 := .F.	    //Retorno da funcao
Local oDlgLoja             
Local bOk					// Botao Ok da Enchoice Bar
Local bCancel				// Botao Cancel da Enchoice Bar
Local aLote	 	 := {}		// Array com os campos para o Msmget
Local aLoteAux   := {"LK9_LOTE"}
Local cRastro	 := SuperGetMV("MV_RASTRO")											// Verifica se a rastreabilidade esta' habilitada
Local nPosProd	 := Ascan(aHeaderDet,{|x| AllTrim(Upper(x[2])) == "LR_PRODUTO"}) 	// Guarda posicao do campo LR_PRODUTO para procura no aColsDet
Local lAutoExB	 := IsBlind()														// Verifica se a rotina sera executada via execauto ou nao
Local aRet		 := {}
Local lContrLote := .F.

LjGrvLog( Nil, "Fun��o Lote Anvisa")

AADD(aLoteAux,"LK9_USOPRO")

RegToMemory( "LK9", .T. )

For nX := 1 to Len( aLoteAux )
	SX3->( DbSetOrder( 2 ) )

	If SX3->( DbSeek( PadR( aLoteAux[nX], 10 ) ) )
		ADD FIELD aLote TITULO    X3TITULO() 	  ;
						  CAMPO   SX3->X3_CAMPO   ;
						  TIPO    SX3->X3_TIPO    ;
						  TAMANHO SX3->X3_TAMANHO ;
						  DECIMAL SX3->X3_DECIMAL ;
						  PICTURE PesqPict( "LK9", SX3->X3_CAMPO );
						  VALID T_DROVldInfo();
						  NIVEL 1;
						  ;  
						  F3 If(SX3->X3_CAMPO == PadR("LK9_LOTE",10),If(nModulo == 12 .AND. !lMvLjPdvPa, SX3->X3_F3, ),SX3->X3_F3);
						  BOX SX3->X3_CBOX    	
		
		If M->&( SX3->X3_CAMPO ) == NIL
			M->&( SX3->X3_CAMPO ) := CriaVar( SX3->X3_CAMPO )
		Endif
		
	Endif
Next nX

DEFINE MSDIALOG oDlgLoja FROM 80,1 TO 200,575 TITLE "SNGPC - LOTE do Produto" PIXEL STYLE DS_MODALFRAME

oLoteEncho:=MsMGet():New( "LK9"		, NIL, 3							, NIL	,;
							NIL		, NIL, NIL							, NIL	,;
							NIL		, NIL, NIL							, NIL	,;
							NIL		, NIL, NIL							, NIL	,;
							NIL		, NIL, NIL							, .T.	,;
							aLote	, NIL )

//���������������������������������������������������������������������������Ŀ
//�Procura no SB1, para verificar se o produto possui controle por lote/rastro�
//�����������������������������������������������������������������������������
lContrLote := .F.
If cRastro == "S" .AND. Len(aColsDet) > 0 
	aAreaSB1 := SB1->(GetArea())
	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL + B1_COD
	If ( DbSeek( xFilial("SB1") + aColsDet[n][nPosProd] ) )
		lContrLote := SB1->B1_RASTRO $"LS"
	EndIf
	RestArea(aAreaSB1)
EndIf

bOk		:= {|| lRet := .T., If(If(lContrLote,T_DroVldTela(lRet, aLote) ;
                                  .AND.Lj7Lote( Nil,Alltrim(M->LK9_LOTE),Nil,Nil),.T.), oDlgLoja:End(),)}

bCancel	:= {|| lRet := .F., oDlgLoja:End()}
ACTIVATE MSDIALOG oDlgLoja CENTERED ON INIT EnchoiceBar( oDlgLoja, bOk, bCancel, NIL, NIL )
	
IIf( !lContrLote,M->LK9_LOTE := "", )

aRet := {	M->&(aLoteAux[1])	,;	// Lote 
    	  	M->&(aLoteAux[2])	} 	// Uso Prolongado , padrao 2(n�o)

Return aRet

/*�������������������������������������������������������������������������������
���Programa  �DROXMLWizard  � Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao �Wizard para a geracao do XML que sera' enviado a ANVISA para    ���
���          �atender a SNGPC - Sistema Nacional de Gerenciamento de Produtos ���
���          �                  Controlados                                   ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DROXMLWizard()
Local oWizard 	 := NIL		//Objeto do tipo WizardAnvisa
Local oXML	  	 := NIL		//Objeto do tipo XML
Local cCNPJ	  	 := ""			//CNPJ da filial corrente

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf	 

//Estancia o objeto WizardAnvisa
oWizard := DROWizardAnvisa():WizardAnv() 
oWizard:Show()

If !oWizard:GetCancel()
	DbSelectarea("SM0")      
	DbSetOrder(1)
	If DbSeek(cEmpAnt+cFilAnt)
		cCNPJ := SM0->M0_CGC
	Endif

	oXML := DROXMLAnvisa():Anvisa( cCNPJ, oWizard:GetCpf(),oWizard:GetDtIni(), oWizard:GetDtFim(), ;
					  			    oWizard:GetPath() )
	If oXML:Gerar()
		MsgAlert("XML gerado com sucesso")
		T_DroXmlANVISA("5",oXML:cCPF,cCaixaSup)

		If MsgYesNo("Deseja enviar o arquivo agora � Anvisa?","Aten��o")//"Deseja enviar o arquivo agora � Anvisa?"//"Aten��o"
			T_DroBrwAnvi("XML",oXML:cCPF,cCaixaSup)
		EndIf	  				
	Else
		oXML:GetMsg()	
	Endif  			
		  			
Endif

Return

/*�������������������������������������������������������������������������������
���Programa  �DroPerdaANVISA� Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao �Tela para o lancamento das perdas dos medicamentos controlados  ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DroPerdaANVISA()
Local cIndex  := CriaTrab(NIL, .F.)
Local cIndice := LK9->(IndexKey(5))  // Indice 5 => LK9_FILIAL+LK9_TIPMOV
Local cFiltro := "LK9_TIPMOV == '" + '4' + "'"
Local lProssegue  := .T.

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina :=  {{"Pesquisar" 	, "AxPesqui"	, 0, 1},;	// Pesquisar
					 {"Visualizar"	, "T_DroAxPerda", 0, 2},;	// Visualizar
                     {"Incluir"		, "T_DroAxPerda", 0, 3},;	// Incluir
                     {"Alterar"		, "T_DroAxPerda", 0, 4},;	// Alterar
                     {"Excluir"		, "T_DroAxPerda", 0, 5} }	// Excluir

PRIVATE cCadastro :=  "Lan�amento das perdas dos medicamentos controlados"   // "Distribui��o de mercadoria"                     

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	lProssegue := .F.
EndIf

If lProssegue
	DbSelectArea("LK9")
	DbSetOrder(1)
	
	IndRegua("LK9", cIndex, cIndice,, cFiltro)
	       
	MBrowse(6, 1,22,75,"LK9",,,,,,)
	
	// Limpa o filtro.
	DbSelectArea("LK9")
	Set Filter To
EndIf

Return Nil

/*����������������������������������������������������������������������������
���Fun��o    �DroAxPerda | Autor � Vendas Clientes       � Data � 28/08/01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Browse para Lancamento das Perdas dos medicmaentos          ���
���          � CONTROLADOS                                                 ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Lj430INI(cAlias,nReg,nOpc)                                  ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cAlias - Alias enviado pelo browse                          ���
���          � nReg   - registro atual enviado pelo browse                 ���
���          � nOpc   - Numero da opcao selecionada                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Template Drogaria                                           ���
����������������������������������������������������������������������������*/
Template Function DroAxPerda( cAlias, nReg, nOpc )
Local nSaveSx8 		:= GetSx8Len()	
Local oDlgPerda  					//Objeto da tela
Local lRet			:= .F.	    	//Retorno da funcao
Local lIsRotPrAn	:= .F.
Local cFldLK9		:= ""
Local bOk							//Botao Ok da Enchoice Bar
Local bCancel						//Botao Cancel da Enchoice Bar
Local aCpoEnchoice  := {}			//Array contendo os campos que irao aparecer para o usuario
Local aCampos		:= {}			//Array que sera' utilizado na funcao MSMGET
Local aSize			:= MsAdvSize()
Local nX			:= 0			//Controle de loop

PRIVATE aGETS   := {}
PRIVATE aTELA   := {}

/*Cria um array com os campos que irao aparecer na enchoice*/
aCpoEnchoice := {	"LK9_DOC",;
					"LK9_CODPRO",;
				  	"LK9_DESCRI",;
				  	"LK9_UM"	,;
				  	"LK9_QUANT" ,;
				  	"LK9_LOTE"  ,;
				  	"LK9_MTVPER",;
				  	"LK9_DATAPE",;
				  	"LK9_OBSPER"}

RegToMemory("LK9",IIF(nOpc == 3,.T.,.F.))

//Somente apaga o conteudo quando for inclus�o, nos outros casos deve trazer o conteudo 
If nOpc == 3
	M->LK9_OBSPER:= ""
	lIsRotPrAn	 := FunName() == "DROPERDAANVISA"
EndIf 

For nX := 1 to Len( aCpoEnchoice )
	SX3->( DbSetOrder( 2 ) )

	If SX3->( DbSeek( PadR( aCpoEnchoice[nX], 10 ) ) )
		cFldLK9 := Upper(AllTrim(SX3->X3_CAMPO))
		
		ADD FIELD aCampos /*1 - TITULO*/	TITULO  X3TITULO() 		;
						  /*2 - CAMPO*/		CAMPO   SX3->X3_CAMPO	;
						  /*3 - TIPO*/		TIPO    SX3->X3_TIPO    ;
						  /*4 - TAMANHO*/	TAMANHO SX3->X3_TAMANHO ;
						  /*5 - DECIMAL*/	DECIMAL SX3->X3_DECIMAL ;
						  /*6 - PICTURE*/	PICTURE PesqPict( "LK9", SX3->X3_CAMPO ) ;
						  /*7 - VALID*/		VALID {T_DROVldInfo(), If(ExistTrigger(SubStr(ReadVar(),4)),RunTrigger(1),)};
						  /*8 - OBRIGAT*/	;
						  /*9 - NIVEL*/		NIVEL 1 ;
						  /*10- INITPAD*/	INITPAD If(lIsRotPrAn .And. (cFldLK9 == "LK9_DOC"), "" , &(SX3->X3_RELACAO)); //Para n�o pular a numera��o da LK9_DOC,pois j� executou o rela��o na inclus�o
						  /*11- F3*/		F3 If(SX3->X3_CAMPO == PadR( "LK9_LOTE", 10 ),"SB8",SX3->X3_F3)
						  /*12- WHEN*/		
                          /*13- VISUAL*/	
                          /*14- CHAVE*/		
                          /*15- BOX*/		
                          /*16- FOLDER*/	
                          /*17- NAO ALTERA*/
                          /*18- PICTVAR*/	
  		
		/*Indica se o campo podera' ou nao ser editado*/
  		If SX3->X3_VISUAL == "V"
  			aCampos[nX][13] := .T.
  		Endif
	Endif
Next nX
                                     
DEFINE MSDIALOG oDlgPerda FROM aSize[7],0 To aSize[6],aSize[5] TITLE "Lan�amento de Perdas dos Medicamentos Controlados" PIXEL //STYLE DS_MODALFRAME

    nReg := RECNO() 
	oEnchoice := MsMGet():New("LK9"		, nReg, nOpc						, NIL	,;
								NIL		, NIL, NIL							, NIL	,;
								NIL		, NIL, NIL							, NIL	,;
								NIL		, NIL, NIL							, NIL	,;
								NIL		, NIL, NIL							, .T.	,;
								aCampos , NIL )
//���������������������������������������������������������������������Ŀ
//� Define os blocos de codigo para os botoes "Ok" e "Cancel" da dialog �
//�����������������������������������������������������������������������
bOk		:= {|| lRet := .T., If(T_DroVldTela(lRet, aCampos),If( T_DroGrvPerda(nOpc,nSaveSx8, M->LK9_DOC),oDlgPerda:End(),.F.),)}
bCancel	:= {|| lRet := .F., T_DroBtnCanc( nSaveSx8, M->LK9_DOC ), oDlgPerda:End()}

oDlgPerda:lMaximized := .T. //Maximiza a janela
	
oEnchoice :oBox:Align := CONTROL_ALIGN_ALLCLIENT//CONTROL_ALIGN_CENTER

ACTIVATE MSDIALOG oDlgPerda CENTERED ON INIT  EnchoiceBar( oDlgPerda, bOk, bCancel, NIL, NIL )

Return NIL

/*���������������������������������������������������������������������������
���Funcao    �DroAxAltOk� Autor � IP-Vendas 			� Data � 22/03/10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracap de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
���������������������������������������������������������������������������*/
Function DroAxAltOk( cProcess, cTabela, cChave, nOrdem, cTipo)
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	
//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New(cProcess)
	
	//Determina o tipo de operacao 
	If Empty(cTipo)
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"				
		EndIf
	Endif
	
	If cTipo = "DELETE"				
		//Considera os registros deletados
		SET DELETED OFF
	EndIf
		    
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
			
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf
	
Return Nil

/*����������������������������������������������������������������������������
���Funcao    �DroAxAlter� Autor � IP-Vendas			     � Data � 22/03/10 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Armazena campo chave para n�o permitir alteracao do mesmo   ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Cadastro de Codigo de Barra                                 ���
����������������������������������������������������������������������������*/
Function DroAxAlter( cCampo,_cAlias,_cPrefixo  )
Local lRet		:= .T.
Local aAreaLkb	:= {}
Local cMsgMHBGp := ""

DEFAULT cCampo		:= ""			// Parametro com o campo chave
DEFAULT _cAlias		:= ""			
DEFAULT _cprefixo	:= ""		

If lAmbOffLn
	cCampoPk := cCampo
EndIf

If (ALTERA .OR. INCLUI) .AND. !Empty(_cAlias) 
	
	If (_cAlias)->(ColumnPos((_cPrefixo+"_OBSALT"))) > 0 .And. INCLUI
		M->&(_cPrefixo+"_OBSALT") := Space(TamSx3((_cPrefixo+"_OBSALT"))[1])
	EndIf
	
	If _cPrefixo == "LKB" .And. INCLUI
		aAreaLkb := LKB->(GetArea())
		
		If Alltrim(POSICIONE("LKB", 3, xFilial("LKB")+__CUSERID , "LKB_CUSERI")) == ""
			M->&(_cPrefixo+"_CUSERI") := __CUSERID
			M->&(_cPrefixo+"_NOME")   := UsrFullName ( __CUSERID )
		Else
			lRet := .F. 
		EndIf
		
		RestArea(aAreaLkb)
	EndIf

	//campos de seguranca
	If (_cAlias)->(ColumnPos(_cPrefixo+"_USVEND")  > 0)  
		M->&(_cPrefixo+"_USVEND") := cUserName
	EndIf	
					
	//campos de seguranca
	If (_cAlias)->(ColumnPos(_cPrefixo+"_USAPRO")  > 0)
		M->&(_cPrefixo+"_USAPRO") := cCaixaSup 
	EndIf
	
	If _cAlias == "MHB"
		cMsgMHBGp := " O Conte�do do campo Grupo (MHB_GRUPO), interfere diretamente no " + CHR(13) +;
		" no cadastro de Produtos (LOJA110/MATA110), pois somente ser�o mostrados " + CHR(13) +;
		" os registros que tiverem o campo B1_GRUPO igual ao conte�do do campo MHB_GRUPO"
		
		Conout(cMsgMHBGp)
		LjGrvLog("DroAxAlter", cMsgMHBGp)
		
		If !lCpoGrpMHB //Para emitir a mensagem somente 1 vez
			MsgInfo(cMsgMHBGp)
			lCpoGrpMHB := .T.			
		EndIf
	EndIf
Endif

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroAxValid�Autor  �IP-Vendas           � Data �  22/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se houve altera��o no campo chave                   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
���������������������������������������������������������������������������*/
Function DroAxValid( cCampo, cNomeCampo )
Local lRet 			:= .T.			// Retorno da funcao

DEFAULT cCampo		:= ""			// Parametro com o campo chave
DEFAULT cNomeCampo	:= ""			// Parametro com o Nome do campo chave para buscar o titulo

/*Valida se houve alteracao no campo chave(PK)
em ambiente OffLine   */                        
If lAmbOffLn .AND. ALTERA .AND. ( cCampo <> cCampoPk )
	Alert(STR0001 + AVSX3(cNomeCampo,5) )   //N�o � permitido alterar o c�digo.
	lRet := .F.
EndIf

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroLIPExcl�Autor  �IP-Vendas           � Data �  22/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se pode excluir patologia do produto                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
���������������������������������������������������������������������������*/
Function DroLIPExcl(cCodPat)

Local lRet     := .T.
Local cQuery   := ""  
Local cPAT     := "cPAT"

DEFAULT cCodPat   := ""

If Alltrim(cCodPat) <> "" 

	#IFDEF TOP  
	    
		If Select(cPAT) > 0
			(cPAT)->(DbCloseArea())
		EndIf
	
		cQuery := "Select * From " + RetSqlName("SB1")+ " SB1 where B1_CODPATO = '" + Alltrim(cCodPat) + "'"
		cQuery := ChangeQuery( cQuery )

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cPAT, .F., .T.)

		If Alltrim((cPAT)->B1_COD) <> "" 
			lRet := .F.
		EndIf
	    
	#ELSE

		DbSelectArea("SB1")
		cIndex	:= CriaTrab(Nil,.F.)
		cChave	:= "B1_FILIAL+B1_CODPATO"
		IndRegua("SB1",cIndex,cChave,,,STR0005) //"Selecionando Registros..."
		DbSelectArea("SB1")
		nIndex  := RetIndex("SB1") 
	    SB1->(DbSetIndex( cIndex + OrdBagExt() ))
		SB1->(DbSetOrder( nIndex + 1 ))
		If SB1->(DbSeek(xFilial("SB1")+ cCodPat))                                                                                                           
      		lRet := .F.
		EndIf	
		
	#ENDIF

	If !lRet
	   	MsgInfo(STR0006 + CHR(13) +STR0007,STR0004) //"Patologia n�o pode ser excluida.", "Esta vinculada aos produtos","AVISO"
	EndIf
	
EndIf

Return lRet

/*���������������������������������������������������������������������������
���Programa  �DroLEOExcl�Autor  �IP-Vendas           � Data �  22/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se pode excluir controle de  produto                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
���������������������������������������������������������������������������*/
Function DroLEOExcl(cCodLEO)
Local lRet     := .T.
Local cQuery   := ""  
Local cLEO     := "cLEO"

DEFAULT cCodLEO   := ""

If Alltrim(cCodLEO) <> "" 

	#IFDEF TOP  
	    
		If Select(cLEO) > 0
			(cLEO)->(DbCloseArea())
		EndIf
	
		cQuery := "Select * From " + RetSqlName("SB1")+ " SB1 where B1_CODCOTL = '" + Alltrim(cCodLEO) + "'"
		cQuery := ChangeQuery( cQuery )

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cLEO, .F., .T.)

		If Alltrim((cLEO)->B1_COD) <> "" 
			lRet := .F.
		EndIf
	    
	#ELSE

		DbSelectArea("SB1")
		cIndex	:= CriaTrab(Nil,.F.)
		cChave	:= "B1_FILIAL+B1_CODCOTL"
		IndRegua("SB1",cIndex,cChave,,,STR0005) //"Selecionando Registros..."
		DbSelectArea("SB1")
		nIndex  := RetIndex("SB1") 
	    SB1->(DbSetIndex( cIndex + OrdBagExt() ))
		SB1->(DbSetOrder( nIndex + 1 ))
		If SB1->(DbSeek(xFilial("SB1")+ cCodLEO))                                                                                                           
      		lRet := .F.
		EndIf	
		
	#ENDIF

	If !lRet
	   	MsgInfo(STR0008 + CHR(13) +STR0007,STR0004) //"Controle n�o pode ser excluido.", "Esta vinculada aos produtos","AVISO"
	EndIf
	
EndIf

Return lRet

/*�������������������������������������������������������������������������������
���Programa  �DROInvWizard  � Autor � Vendas Clientes    � Data �  23/10/07   ���
�����������������������������������������������������������������������������͹��
���Descricao �Wizard para a geracao do XML que sera' enviado a ANVISA para    ���
���          �atender a SNGPC - Sistema Nacional de Gerenciamento de Produtos ���
���          �                  Controlados                                   ���
�����������������������������������������������������������������������������͹��
���Uso       � Template Drogarias               	                          ���
�������������������������������������������������������������������������������*/
Template Function DROInvWizard()
Local oWizard := NIL		//Objeto do tipo WizardAnvisa
Local oXML	  := NIL		//Objeto do tipo XML
Local cCNPJ	  := ""			//CNPJ da filial corrente

//  Verifica se usuario tem permissao de de farmaceuto para incluir registros
If !T_DroVERPerm(,@cCaixaSup)
	Return .T.
EndIf

//Estancia o objeto WizardAnvisa
oWizard := DroWizardAnvisaInv():New() 
oWizard:Show()
   
If !oWizard:GetCancel()
	DbSelectarea("SM0")      
	DbSetOrder(1)
	If DbSeek(cEmpAnt+cFilAnt)
		cCNPJ := SM0->M0_CGC
	Endif

	oXML := DROXMLAnvisa():Anvisa( cCNPJ, oWizard:GetCpf(),oWizard:GetDtIni(), oWizard:GetDtFim(),  ;
					  			    oWizard:GetPath() )
	If oXML:GerarInv()
		MsgInfo("Arquivo XML do Invent�rio gerado com sucesso!", "XML ANVISA")

		T_DroXmlANVISA("6",oXML:cCPF,cCaixaSup)
		
		If MsgYesNo("Deseja enviar o arquivo agora � ANVISA?","Aten��o")//"Deseja enviar o arquivo agora � Anvisa?"//"Aten��o"
			T_DroBrwInve("INV",oXML:cCPF,cCaixaSup)
		EndIf
	Else
		oXML:GetMsg()	
	Endif  				  			
Endif

Return