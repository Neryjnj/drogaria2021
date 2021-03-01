#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------
/*{Protheus.doc} STFRestart
Funcao respons�vel em reiniciar para pr�xima venda 

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	Nil
@obs     
@sample
*/
//--------------------------------------------------------
Function STFRestart()

Local lFinServ	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros
Local lLimSang	:= SuperGetMV( "MV_LJLISAN",, .F.) // Utiliza controle para limite de sangria 
Local lSelNcc	:= ExistBlock("STSelNcc")		//Existe ponto de entrada para selecao da NCC?
/*/
	Motivo de Venda Perdida
/*/
STDRLSFree()

/*
	Limpa regras de bonificacao
*/
STDBS7Rules( )

/*/
	Motivo de Desconto
/*/
STDRFDSFree()

/*/
	Desconto na pr�xima venda
/*/
STDNSDFree()

/*
	Reinicio a variavel que controla se a tela do CPF ja foi apresentada.
*/
STI7InfCPF(.F.)

/*
	Reinicializo o modelo de dados e o preencho com as informacoes iniciais basicas.
*/
STDPBRestart()
STDInitPBasket()


// Limpa as variaveis static das NCCs
If ProcName(1) <> "STIRECESEL" .OR. !lSelNcc
	STINCCClearStatic()
EndIf

/*/
	Zera fun��es fiscais
/*/
STBTaxEnd()
                   
/*/
	Inicia Fun��e fiscais
/*/
STBStartTax()

/*/
	Seta Default cupom aberto
/*/
STWSetIsOpenReceipt( .F. )

/*/
	Set na variavel lCard
/*/ 
STISetCard()

/*/
	Set no array de ID de TEF
/*/
If FindFunction("STBSetIDTF")
	STBSetIDTF()
EndIf

/*/
	Totalizador
/*/
STFTotRestart()

/*/
	FreeObj no objeto do TEF
/*/
STBSetRetTef()

/*/
	Limpa variavel  dos dados do cheque
/*/
STWSetCkRet()

/*
	Limpa dados do Cupom de Vale Troca
*/
STICVTClear()

/*
	Limpa dados do Cupom de Vale Presente / Credito	
*/
STBSetCodVP()
STBSetVlrVP()

/*
	Limpa os dados das parcelas
*/
STBSetParc()

/*/
	Limpa msg da tela
/*/
STFCleanInterfaceMessage()

/* Desabilita os botoes da tela */
STIBtnDeActivate()

//Venda nao esta mais ativa
STBSaleAct(.F.)

/* Zerar doa��o Instituto Arredondar */
STBSetInsArr(0)

/* Limpa informacoes do objeto de Garantia Estendida */
If ExistFunc("STWItemGarEst")
	STWItemGarEst(3) //(1=Set - 2=Get - 3=Clear)
EndIf

/* Limpa informacoes do objeto de Servi�os Financeiros */
If lFinServ
	STWItemFin(3) //(1=Set - 2=Get - 3=Clear)
EndIf

/* Limpa CPF/CNPJ utilizado no Panel de Recebimento do Cliente selecionado */
If FindFunction("STISCnpjRec")
	STISCnpjRec("")
EndIf

/* Reseta a Opera��o em execu��o atual */
If FindFunction("STIPosSOpc")
	STIPosSOpc("")
EndIf

/* Verificar Limite de Sangria */
If lLimSang .AND. AliasIndic("MGW") .AND. AliasIndic("MGX") .AND. FindFunction("STDVerLimSan")
	STDVerLimSan()
EndIf

/*
	Limpa a variavel que define se os pagamentos ser�o Somente Leitura 
	(quando o Caixa n�o tem permiss�o de Alterar Parcelas)
*/
If FindFunction("STIGetPayRO")
	STISetPayRO(0)
EndIf

/* Reseta a variavel que define que os pagamentos de um or�amento importado foram utilizados */
STISetPayImp(.F.)

/* Reseta as variavel de recebimento de titulo*/
STISetRecTit(.F.)

/* Reseta o botao responsavel por finalizar a venda (STIItemRegister) */
If FindFunction("STISetBtIR")
	STISetBtIR()
EndIf

/* Limpa a variavel de vendedor selecionado na venda */
If FindFunction("STISSelVend")
	STISSelVend(.F.)
EndIf

/* Limpa a variaveis dos pagamentos da venda */
If ExistFunc("STBClearPay")
	STBClearPay()
EndIf

/* Limpa a variavel do valor de entrada da venda */
If ExistFunc("STBSetEnt")
	STBSetEnt()
EndIf

/* Limpa a variavel model dos pagamentos */
If ExistFunc("STIPayMdlc")
	STIPayMdlc()
EndIf

/* Limpa a variaveis do codigo do cliente e loja */
If ExistFunc("STWSCliLoj")
	STWSCliLoj()
EndIf 

/* Limpa variavel estatica de importacao de orcamento, para nao limpar desconto em vendas sem importacao */
If ExistFunc("STIClrVar")
	STIClrVar()
EndIF

//Volta ao estado original da variavel que indica se houve altera��o em alguma informa��o do or�amento do tipo FI
If ExistFunc("STISFiAltImp")
	STISFiAltImp()
EndIf	

/* Limpa a variavel de recupera��o de venda */
STB7Recovered(.F.) 

/* Limpa o array aCustSele com o c�digo do cliente e a loja utilizado no Recebimeno de T�tulo do fonte STDCustLis.prw */
If ExistFunc("STDSCustSele")
	STDSCustSele()
EndIf

/* Essa funcao limpa o conteudo do array com os precos da ultima tabela de preco */
MaReleTabPrc()

/*Limpa Variavel lZeraPayImport presente no STINCCSelection */ 
If ExistFunc("STISetZrPg")
	STISetZrPg()
EndIf 

//Limpar a variavel da multi-negociacao
If ExistFunc("STISetMult")
	STISetMult(.F.)
EndIf 

//Limpar as vari�veis de pergunta se imprime CPF/CNPJ ap�s importar or�amento, caso se MV_LJDCCLI for 0 ou 1. Estas fun��es est�o em STBImportSale.prw 
If ExistFunc("STBSetPgtCpf") .AND. ExistFunc("STBSetCpfRet")
	STBSetPgtCPF(.F.)
	STBSetCPFRet(.F.)
EndIf

//Inicializa a variavel static lDescOk com valor default. 
If ExistFunc("STBIDSet")
	STBIDSet(.T.)
EndIF

If ExistFunc("STBGetDPgChck")
	STBGetDPgChck()
EndIF

/* Limpa as vari�veis para An�lise de Cr�dito SIGACRD */
If ExistFunc("STBSetCrdIdent")
	STBSetCrdIdent()
EndIf

If ExistFunc("STBSetAcresFin")
	STBSetAcresFin( 0, 0 )
EndIf

//Limpa vari�vel de tributa��o dos produtos para impress�o SAT
If ExistFunc("LjSetTriSat")		//LOJSAT.PRW
	LjSetTriSat() 
EndIf

//Limpa vari�vel de desconto do total da venda dos or�amentos importados
If ExistFunc("STBSetDscImp")	//STBImportSale.prw
	STBSetDscImp(0)
EndIf

// Limpa Variavel que indica se tem desconto no total da venda
If ExistFunc("STBSetDiscTotPDV") 
	STBSetDiscTotPDV( .F. ) 
EndIf

//Limpa Variaveis utilizadas no Template de Drogaria
If ExistFunc("LJIsDro") .And. LJIsDro() .And. ExistFunc("STBDroVars")
    STBDroVars(.T.)
EndIf

Return Nil