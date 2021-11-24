#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "LOJXFUNC.CH"
#INCLUDE "CRDDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Defines utilizados para trata a matriz de parcelas    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE __DATA		1        //Data de vencimento da parcela
#DEFINE __VALOR		2        //Valor da parcela
#DEFINE __FORMA		3        //Forma de recebimento
#DEFINE __ADMINIS	4        //Codigo ou nome da Administradora
#DEFINE __NUMCART	5        //Numero do cartao ou cheque
#DEFINE __AGENCIA	6        //Agencia do cheque
#DEFINE __CONTA		7        //Numero da conta do cheque
#DEFINE __RG		8        //RG do portador do cheque
#DEFINE __TELEFON	9        //Telefone do portador do cheque
#DEFINE __TERCEIR	10       //Indica se o cheque eh de terceiros
#DEFINE __MOEDA  	11       //Moeda da parcela
#DEFINE __PARCTEF   12       //Tipo de parcelamento quando venda TEF(Client SiTEF DLL)
#DEFINE __ACRSFIN 	13		 //Valor separado do acrescimo para cada parcela de financiamento
#DEFINE __EMITENT 	14		 //Emitente quando o cheque for de terceiros
#DEFINE __FORMAID 	15		 //ID do Cartao de Credito ou Debito
#DEFINE __NSUTEF	16		 //NSU da trasacao TEF
#DEFINE __DOCTEF   	17		 //Num. Documento TEF
#DEFINE __NRECNO   	18		 //Num. Recno SL4
#DEFINE __DESCMN   	19		 //Desconto MultNegociacao
#DEFINE __FORMATEF	"CC;CD"  //Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMAPGDG	"PD/PX"  //Forma de pagamento considerado Pagamento Digital
#DEFINE __PREDIC		11	 //Posicao Reducao de Base
#DEFINE __CONHTL		20 	 //Conta Hotelaria
#DEFINE __AUTORIZ       21 	 //Codigo Autorizacao TEF
#DEFINE __COMPEN   		22 	 //Compensacao do Cheque
#DEFINE __IDCNAB   		23 	 //IDCNAB financeiro
#DEFINE TEF_NAO_USADO				"1"		//Nao Utiliza TEF
#DEFINE TEF_SEMCLIENT_DEDICADO  	"2"     //Utiliza TEF Dedicado Troca de Arquivos
#DEFINE TEF_COMCLIENT_DEDICADO  	"3"		//Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             	"4"		//Utiliza TEF Discado
#DEFINE TEF_LOTE                	"5"		//Utiliza TEF em Lote
#DEFINE TEF_CLISITEF				"6"		//Utiliza a DLL CLISITEF
#DEFINE TEF_CENTROPAG				"7"		//Utiliza a DLL CENTRO DE PAGOS
#DEFINE CTRL Chr(10)+Chr(13)              	//Pula linha		

/*
	Tipos do LogManager
*/
#define LMOK 1
#define LMINFO 2
#define LMALERT 3
#define LMSTOP 4
#define LMCONFIG 5

/*
	Niveis do LogManager
*/
#DEFINE LMTECH 1
#DEFINE LMPROC 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este Log e um recurso a ser habilitado pelo departamento de desenvolvimento para averigua-³
//³cao de possiveis problemas de transacoes TEF.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE LOG_TEF LjLogTef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Defines utilizados para tratar o Array de Totais      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE __VALMERC 1
#DEFINE __DESCONT 2
#DEFINE __VALACRS 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Defines utilizados para EventViewer |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE IDEVENT "050"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Defines utilizados para distiguir geracao de guia de despacho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE GDP_NO			"0" 	//Nao sera gerada guia de despacho.Quando a venda não tem item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_PARCIAL    	"1"		//Sera gerada guia de despacho parcial.Quando a venda possui pelo menos um item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_TOTAL		"2"		//Sera gerada guia de despacho total.Quando todos os itens da venda estao reservados e com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI


Static cClientDir           					// Pasta de instalacao do Remote
Static lRemoteType 	:= GetRemoteType() <> -1		// Verifica a origem (Front ou Venda Assistida)
Static lArqLog				                    // Verifica se o arquivo de log ja' foi criado
Static lLogHabilitado							// Verifica se o log esta' habilitado
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis utilizada no SELF-LIQUIDATE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aPremio			:= {}  				   	// Array com os premios resgatados pelo cliente
Static oIntVenda  	:= Nil                        // Responsavel por integrar venda
Static lLogManager  := .F. //Habilita Log em arquivo DBF, antes era habilitado por meio de FindFunction("LoggerOut")
Static aTESVenda 	:= { "", {} }

//Vale Presente
Static cTipoPrdVP 	:= ""				//Armazena se o tipo de produto que estah sendo vendido na venda eh "Vale Presente" ("S") ou NAO ("N"). Pois "Vale Presente" nao pode ser vendido junto com outros produtos.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis referente a implementacao de Cartao Presente (Gift Card).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static lCPAtivo		:= .F.				// Verifica a configuracao de "Cartao Presente (Gift Card)" esta ativo.
Static aProdsCP   	:= {}				// Array com a relacao de produtos considerados "Cartao Presente (Gift Card)"
Static lTrnCPEfet	:= .F.				// Indica se na venda foi efetuada alguma recarga de "Cartao Presente (Gift Card)"
Static aRegTefCP	:= {} 				// Array com as movimentacoes do TEF da recarga de "Cartao Presente (Gift Card)"
Static cTipoPrdCP 	:= ""				// Armazena se o tipo de produto que estah sendo vendido na venda eh "recarga de Cartao Presente (Gift Card)" ("S") ou NAO ("N"). Pois "recarga de Cartao Presente" nao pode ser vendido junto com outros produtos.

Static nTotCarFed := 0
Static nTotCarEst := 0
Static nTotCarMun := 0

Static lGrvErro := .F. //Varivel que faz o controle se grava a informação do erro na L1_ERGRVBT

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³LjGrvTudo³ Autor ³ Vendas Clientes       ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava as informa‡•es no SD2, SF2, SE1, SE5, SEF, SB2, SA1  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Chamar a funcao com o SL1 posicionado no orcamento correto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010, LOJA220, FRT                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrvTudo( _lScreen	,lFinanceiro	,nNccUsada	,aNccItens	,;
                    nNccGerada	,aImpCheque		,nMoedaCor	,aRecSE1	,;
                    aVlrAcres	,aSL1			,aSL2		,cDoc		,;
                    lVendaCup	,nNumItens		,nFrete		,nSeguro	,;
                    nDespesa	,cLQFrete		,aAcrFin	,lPedFin 	,;
                    cCgcCli		,cNomeCli		,lNfManual	,lExistNF   ,;
                    cDescErro   ,cEspecNf		,cDocFo		,aBreakNota ,;
                    aNewNCC		,cTpGeraGdp		,nOpc		,nArredondar,;
                    lErroNFe	,lTefNsuDigit	,cLojaNF	,lNFePDV)

Local nCheck    	:= Val(Left(SL1->L1_IMPRIME,1))			// 1-Cupom Fiscal, 2-Nota Fiscal, 3-Recibo, 4-Nao Imprime
Local cNumNota  	:= "" 									// Numero da Nota a ser gerada (ja vem preenchido se for de ECF)
Local nMaxItens 	:= 999									// Cupom Fiscal = 999, caso contrario pego o numero maximo abaixo com GetMV
Local aReceb		:= {}									// Parcelas (SL4)
Local nI													// Utilizado para contadores diversos
Local aImpsSF2 		:= {}            						// Array com o valor da base e dos impostos do SF2 - Localizações
Local lError		:= .F.									// Variavel para identificar se houve erro durante o orcamento
Local nTotLiq		:= 0									// Total Liquido - Localizacoes
Local nTotImp		:= 0									// Total dos Impostos Discriminados - Localizacoes
Local nItVenda  	:= 0									// Quantidade de Itens da Nota
Local nQtdeNotas	:= 0									// Quantidade de Notas que serao geradas
Local aNotas    	:= {}									// Array que irá armazenar a numeração das notas
Local lSaida    	:= .T.									// Verifica se o usuario aceita a alteracao da numeracao
Local cAliasNF  	:= ""									// Alias da NF (SF2)
Local cNumAnt   	:= ""									// Numero anterior da Nota
Local nTotDesc  	:= 0									// Totalizador dos Descontos
Local lExiste   	:= .T.									// Retorno da funcao aNumNaoExiste()
Local nAltera   	:= SuperGetMV("MV_ALTNUM",,1)			// Se permite ou nao a alteracao da NF
Local nBaseDup   	:= 0									// Valor da base das Duplicadas para o financeiro
Local nTamSerie     := TamSX3("L1_SERIE")[1]				// Tamanho do campo L1_SERIE
Local nTamDoc       := TamSX3("L1_DOC")[1]					// Tamanho do campo L1_DOC
Local nTamF2_DOC  	:= TamSx3("F2_DOC")[1] 					// Tamanho do campo F2_DOC
Local cMV_TPNRNFS	:= LjTpNrNFS()							// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local nX			:= 1									// Variavel auxiliar em For...Next
Local nBasePS2      := 0									// Valor da Base PIS 2 (Apuracao)
Local nValPS2		:= 0									// Valor do PIS 2 (Apuracao)
Local nBaseCF2		:= 0									// Valor da Base Cofins 2 (Apuracao)
Local nValCF2		:= 0									// Valor do Cofins 2 (Apuracao)
Local cNumOrc       := SL1->L1_NUM							// Numero do orcamento para gravacao do LOG
Local bOldError												// Variavel para tratamento de erro
Local lScreen		:= If(_lScreen == NIL, .T.,_lScreen)	// Verifica se exibe as mensagens na tela ou com conout
Local lRetTran		:= .F.									// Retorno da funcao de gravacao
Local nPosImprim	:= 0									// Verificao do SL1
Local bMTrans		:= ""									// Macro de execucao da transacao de venda
Local lRetIncSx5    := .F.									// Variavel que verifica se o X5_Descri foi gravado para não ser incrementado novamente.
Local nRet 			:= 0									//Retorno de verificao em ECF
Local lImpTicFat    := .F.                                  //indica se a msm impressora imprime ticket e fatura.
Local nSaveSx8 		:= GetSx8Len()							// Numeracao do SX8
Local lGerInt       := SuperGetMv("MV_LJGRINT",.F.,.F.)		//Verifica se a integracao esta habilitada
Local cPadrao		:= "701"                                // Codigo Padrao
Local lPadrao  		:= VerPadrao(cPadrao)					// verifica padrao
Local nHdlPrv  		:= 0									// Contabilizacao
Local nTotal   		:= 0									// Contabilizacao
Local cArquivo 		:= ""									// Contabilizacao
Local lAglutina 	:= .T.									// Contabilizacao
Local oLJCLocker 	:= If( SuperGetMV( "MV_LJILVLO",,"2" ) == "1", LJCGlobalLocker():New(), )
Local cTextoErro	:= ""
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI		  ³
Local lCFolLocR5	:=	cPaisLoc$"CHI|COL" .AND. SuperGetMv("MV_CTRLFOL",,.F.)
Local cSigEspFo		:= ""										//Sigla da especie de documento fiscal escolhida no inicio da venda.
Local l2SPdvChi		:= .F.										//Indica se trata-se de uma venda gravada como nota (L1_IMPRIME=S2) no PDV.Se sim, nao passar pelo LjxDNota para manter o L1_DOC e L1_SERIE provenientes do PDV
Local cNumOrcPai	:= Iif(!lScreen,SL1->L1_ORCRES,M->LQ_NUM) //Numero do orcamento pai
Local lFtvdVer12	:= ExistFunc("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") //Nome da Rotina
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 	// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local cMVLOJARPS	:= PadR(SuperGetMv("MV_LOJARPS",,"RPS"), nTamSerie )// Serie da Nota Fiscal de Servico (RPS) usado apenas qdo. parametro MV_LJPRDSV estiver ativo
Local lOnlyServ 	:= .F. 									// Indica se a venda tem somente itens de "servico"
Local nItensProd	:= 0									// Conta somente itens de "Produto"
Local nItensServ	:= 0									// Conta somente itens de "Servico"
Local nItensSF		:= 0									// Conta somente itens de "Servico Financeiro"
Local lVAssConc	    := LjVassConc()							// Indica se o cliente utiliza a Vda Assistida Concomitante
Local cOrigVend		:= SL1->L1_ORIGEM						// Origem da Venda (FRT=FrontLoja; LOJ=Loja)
Local cFilSL4		:= xFilial("SL4")						// Filial da tabela SL4
Local lIsVendaVP 	:= .F.									// Indica se eh venda de Vale Presente
Local lIsVdRecCP 	:= .F.									// Indica se eh venda de Recarga de Cartao Presente (Gift Card)
Local lTemItProd	:= .F.	// validacao de tem produto fiscal na venda
Local lTemItServ	:= .F.	// valicadao de servico na venda
Local cMVLOJASF		:= PadR(SuperGetMv("MV_LJTPSFA",,"SFA"), nTamSerie )			// Serie do Serviço Financeiro Avulso se somente todos os itens tiverem S.Fin.Avulso
Local lIntegDef		:= SL1->L1_ORIGEM == "N"                //Venda Origem Integração
Local lIntegEAI		:= FWHasEAI("LOJXFUNC",.T.,, .T.) 								//Integração Varejo envio do status ou Erro do processamento da venda
Local cMVLOJANF		:= AllTrim(SuperGetMV("MV_LOJANF"))		// Serie da Nota Fiscal
Local aAuxReceb		:= {}									// [1]-indica se o array foi carregado com sucesso [2]-conteudo do array aReceb
Local lModDoc55		:= .F. //Identifica se esta sendo executado pelo Totvs PDV e carrega a serie da nFe

Private nDecimais 	:= 2									// Verifica a qtde de casas decimais da moeda do orcamento
Private cEspecie  	:= ""									// Cupom fiscal ou NF
Private cSerie    	:= Space(nTamSerie)						// Serie

If cPaisLoc <> "BRA"
	Private lAnulaSF3 := .F.
EndIf

Default cLojaNF			:= cMVLOJANF							// Serie da Nota Fiscal
Default aImpCheque  	:= {}									// Controla se os cheques da venda foram impressos
Default nMoedaCor		:= 1              						// Moeda da venda - Localizações
Default aRecSE1     	:= {}  									// Array com os recnos dos registros do SE1
Default aVlrAcres		:= {}									// Valor de acrescimo financeiro
Default aSL1			:= {}									// Informacoes do SL1
Default aSL2			:= {}									// Informacoes do SL2
Default cDoc			:= ""									// Documento
Default lVendaCup		:= .T.									// Se a venda eh proveniente de Cupom ou Nota Fiscal
Default nNumItens		:= nMaxItens							// Define o valor DEFAULT para o numero de itens
Default nFrete	 		:= 0									// Define o valor DEFAULT do Frete
Default nSeguro 		:= 0									// Define o valor DEFAULT do seguro
Default nDespesa		:= 0									// Define o valor DEFAULT do despesa
Default cLQFrete		:= ""									// Recebe conteudo do campo LQ_TPFRET 1- CIF 2- FOB
Default lPedFin			:= .F.                                  // Define se trata de um Pedido
Default aAcrFin			:= {}
Default cNomeCli		:= ""
Default cCgcCli			:= ""
Default lNfManual		:= .F.
Default cEspecNf    	:= Nil                                  //Especie do documento
Default aNewNCC			:= {}									//Array com as Notas de Créditos informadas
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI 		  ³
Default cDocFo			:= ""									//Numero de Nota definida pelo usuário no inicio da venda
Default aBreakNota		:= {}									//Notas geradas a partir da venda, quando o numero de itens venda exceder o limite e a nota original for divida em mais de uma
Default cTpGeraGdp		:= GDP_NO
Default nOpc			:= 3
Default cDescErro		:= ""
Default nArredondar 	:= 0
Default lErroNFe 		:= .F.
Default lTefNsuDigit	:= .F.
Default lNFePDV		:= .F. //Acrescimo parametro para identificar se a chamada e do STBGrvBatch

If Empty(cLojaNF) 
	cLojaNF	:= cMVLOJANF							
EndIf

//Somente considera ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas, se a venda nao for com "Reserva" e nao for concomitante
lMVLJPRDSV := lMVLJPRDSV .And. Empty(SL1->L1_ORCRES) .And. Empty(SL1->L1_DOCPED) .And. !lVAssConc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instacia Integracao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGerInt
	oIntVenda := LJCAdapXMLEnvVenda():New()
EndIf

If SLG->(ColumnPos("LG_IMPCUFA")) > 0
	lImpTicFat := LjGetStation("LG_IMPCUFA")
EndIf

If Empty(cDoc)
	//Faz o tratamento dos campos L1_DOC / L1_DOCPED e L1_SERIE / L1_SERPED
	cNumNota := If(Empty(SL1->L1_DOC),SL1->L1_DOCPED,SL1->L1_DOC)
Else
	cNumNota := cDoc
EndIf

cNumNota     := PadR( cNumNota , nTamF2_DOC )

LjGrvLog(SL1->L1_NUM,"L1_DOC",SL1->L1_DOC )
LjGrvLog(SL1->L1_NUM,"L1_DOCPED",SL1->L1_DOCPED )
LjGrvLog(SL1->L1_NUM,"Numero cDoc",cDoc )
LjGrvLog(SL1->L1_NUM,"Numero cNumNota",cNumNota )

//Tratamento para quando o L1_IMPRIME vier em branco
//necessário para não pegar outra séria diferente do L1_SERIE
If Empty(SL1->L1_IMPRIME) .And. !Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_SERIE)
	Lj7GeraSL( "SL1", {{"L1_IMPRIME","1S"}}, .F., .F. )
	nCheck := Val(Left(SL1->L1_IMPRIME,1))
	LjGrvLog(SL1->L1_NUM,"Corrigindo L1_IMPRIME para 1S",nCheck)
EndIf

//Release 11.5 - Chile - F2CHI 
//Verificar no orcamento PAI como sera gerada a Guia de Despacho,
//de acordo com o tipo de entrega de cada item da venda.
If lCFolLocR5 .AND. cPaisLoc == "CHI"
	cTpGeraGdp := Lj7ChkGdp(cNumOrcPai,!lScreen)
	nCheck := 2
Else

	//Redefine a variavel nCheck, pois o L1_IMPRIME
	//somente eh gravado corretamente se todo o processo estiver correto
	If Len(aSL1) > 0
		nPosImprim := aScan(aSL1, {|x| AllTrim(Upper(x[1])) == "L1_IMPRIME" })
		If nPosImprim > 0
			If !Empty(aSL1[nPosImprim][2])
				nCheck := Val(Left(aSL1[nPosImprim][2],1))
			EndIf
		EndIf
	EndIf

EndIf
	
//Sempre deve buscar a serie da SL1 para NF-e no PDV
if ( IsBlind() .or. lNFePDV ) .and.;
	(Substr(SL1->L1_KEYNFCE,21,2) == "55" .or. SL1->L1_IMPNF )
	
	lModDoc55 := .T. 
	cLojaNF	:= SL1->L1_SERIE

else

	//Verifica se existe um sinal de & (macro substituicao), dessa forma
	//possibilita ao usuario montar um parametro o qual seja executada
	//uma condicional.
	//Foi necessario fazer dessa forma, pois caso contrario acarretaria
	//erro na base de clientes ja implantada.
	//Solicitado por: Projeto Kodak
	//Incluido a funcao PadR, para que, a variavel fique com o mesmo
	//tamanho do campo L1_SERIE evitando problemas com DbSeek.

	cLojaNF	:= PadR(If(SubStr(cLojaNF,1,1)=="&",&(SubStr(cLojaNF,2,Len(cLojaNF))),cLojaNF), nTamSerie)

endif

//Verifica se eh cupom fiscal/NFC-e(Nao Fiscal) e se a serie serah lida do cadastro de estacao
If nCheck == 1 .OR. nCheck == 5
	lImpCupFis := .T.

	If cPaisLoc=="ARG"
		cSerie  := Lj7SerArg()

	ElseIf lScreen

		LjCheckRPS(SL1->L1_NUM, @lTemItProd, @lTemItServ)

		//Se for NFC-e com Vale Presente(nCheck=5), usamos a SERIE NAO FISCAL do cadastro de estacao
		//IMPORTANTE: ajustar o nCheck para comprovante nao fiscal quando tivermos essa situacao
		If nCheck == 5 .AND. SLG->(ColumnPos("LG_SERNFIS")) > 0 .AND. Lj7VPYesNo() == "S"
			cSerie := LjGetStation("LG_SERNFIS")
		Elseif lMVLJPRDSV .And. !lTemItProd .And. lTemItServ
			cSerie := cMVLOJARPS
		Else
			cSerie := LjGetStation("LG_SERIE")
		EndIf
	Else
		cSerie  := If(Empty(SL1->L1_SERIE), SL1->L1_SERPED, SL1->L1_SERIE)
		If Empty(cSerie) .And. lMVLJPRDSV .And. !Empty(SL1->L1_SERRPS)
			cSerie := SL1->L1_SERRPS
		EndIf
	EndIf

Else
	lImpCupFis := .F.

	If LjNfPafEcf(SM0->M0_CGC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o SL1->L1_ESPECIE so retorna "NFM" caso vir do front de notas digitadas manualmente                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SL1->L1_ESPECIE) $ "NFM|NFCF"
			cSerie	:= SL1->L1_SERIE
		Else
			cSerie	:= cLojaNF
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios ³
		//³Paises:Chile/Colombia - F1CHI		  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCFolLocR5
			If lScreen
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a venda esteja sendo finalizada via tela (SIGALOJA).              ³
				//³Se o usuario escolheu o formulario no inicio da venda, 			      ³
				//³obter a respectiva serie para que seja validada pela funcao LJXDNOTA.  ³
				//³Senao, manter a serie default do parametro MV_LOJANF.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LjGRecFo() > 0
					nRecnoSFP := LjGRecFo()
					LjxDadosFo(nRecnoSFP,NIL,NIL,NIL,@cSerie)
				Else
					cSerie	:= cLojaNF
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a venda estiver sendo finalizada via job (LJGRVBATCH),          ³
				//³sera mantida a serie definida durante a realizacao da venda no PDV,³
				//³sem necessidade de verificacao pela funcao LJXDNOTA (l2sPdvChi=.T.)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				l2SPdvChi := .T.
				cSerie  := SL1->L1_SERIE
			EndIf
		Else
			If lMVLJPRDSV .And. !Empty(SL1->L1_SERRPS) .And. SL1->L1_SERRPS == SL1->L1_SERIE
				cSerie 	:= SL1->L1_SERRPS
			Else
				cSerie	:= cLojaNF
			EndIf
		EndIf
	EndIf
EndIf

If Empty(cSerie) .AND. !lScreen
	LjMsgGrvTudo( lScreen, cNumOrc, STR0001)// "Processo Batch nao pode ser utilizado qdo parametro MV_LOJANF e L1_SERIE estao em branco..."
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So da para saber se e para gerar ou nao com passagem de parametros...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinanceiro == NIL
	lFinanceiro := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para utilizacao de NCC's³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNccUsada == NIL
	nNccUsada := 0
EndIf
If aNccItens == NIL
	aNccItens := {}
EndIf
If nNccGerada == NIL
	nNccGerada := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente foi gravado corretamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA1")
SA1->( DbSetOrder( 1 ) )
If ! SA1->( MsSeek( xFilial( "SA1" ) + SL1->L1_ClIENTE + SL1->L1_LOJA ) )
	LjMsgGrvTudo(lScreen, cNumOrc, STR0071 + SL1->L1_NUM + Chr(10) + STR0002 + SL1->L1_CLIENTE + "/" + SL1->L1_LOJA )  //"Orcamento:" "Cliente não encontrado: "
	cTextoErro := STR0071 + SL1->L1_NUM + Chr(10) + STR0002 + SL1->L1_CLIENTE + "/" + SL1->L1_LOJA
	LjGravaErr(cTextoErro)
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica Se o Cupom Ja Foi Processado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cNumNota)
	LjGrvLog(SL1->L1_NUM,"Numero cNumNota",cNumNota )
	LjGrvLog(SL1->L1_NUM,"Numero cSerie",cSerie )
	LjGrvLog(SL1->L1_NUM,"L1_DOC",SL1->L1_DOC )
	LjGrvLog(SL1->L1_NUM,"L1_SERIE",SL1->L1_SERIE )
	LjGrvLog(SL1->L1_NUM,"L1_DOCPED",SL1->L1_DOCPED )
	SF2->( DbSetOrder( 1 ) )
	If SF2->( DbSeek( xFilial( "SF2" ) + cNumNota + cSerie ) )
		LjMsgGrvTudo(lScreen, cNumOrc, STR0071 + SL1->L1_NUM + Chr(10) + STR0073 + SL1->L1_DOC + SL1->L1_SERIE )  //"Orcamento:" ### "DOC e SERIE ja existente no SF2: "
		cTextoErro := STR0071 + SL1->L1_NUM + Chr(10) + STR0073 + SL1->L1_DOC + SL1->L1_SERIE
		LjGravaErr(cTextoErro)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a integração com EAI Enviando o Erro.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntegEAI .AND. !Empty(cTextoErro)
			//ConOut("LOJIXFUNC:(462) Start integracao EAI Enviando o Erro: "+cTextoErro) 
			FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
		Endif
		If lFtvdVer12
			lExistNF  := .T.
		EndIf
		Return(.F.)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os itens foram gravados corretamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SL2->( DbSetOrder( 1 ) )
If ! SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) )
	LjMsgGrvTudo(lScreen, cNumOrc, STR0003 + SL1->L1_NUM )  //"Itens não encontrados no orçamento: "
	cTextoErro := STR0003 + SL1->L1_NUM
	LjGravaErr(cTextoErro)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a integração com EAI Enviando o Erro.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntegEAI .AND. !Empty(cTextoErro)
		//ConOut("LOJIXFUNC:(483) Start integracao EAI Enviando o Erro: "+cTextoErro)
		FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
	Endif
	Return (.F.)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza Todas as Consistencias do SL2.            ³
	//³ Caso Haja Algo de Errado, Grava L1_SITUA := "ER". ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lError := .F.
	While !SL2->( Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM

		//Devido a emissao de NF-e no PDV devemos validar se o item nao foi cancelado no PDV
		if lNFePDV .and. SL2->L2_VENDIDO <> "S"
			SL2->( DbSkip() )
			Loop			
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura TES do item (para calculo de impostos)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF4")
		If ! SF4->(MsSeek(xFilial("SF4") + SL2->L2_TES))
			LjMsgGrvTudo(lScreen, cNumOrc, STR0071+SL1->L1_NUM+STR0074+SL2->L2_ITEM+Chr(10)+STR0007+SL2->L2_TES)  //"Orcamento:" ### " Item:" ### "Tipo de Entrada/Saída não encontrado: "
			cTextoErro := STR0071+SL1->L1_NUM+STR0074+SL2->L2_ITEM+Chr(10)+STR0007+SL2->L2_TES
			lError := .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no B1 Correspondente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		If ! SB1->(MsSeek( xFilial("SB1") + SL2->L2_PRODUTO ))
			LjMsgGrvTudo(lScreen, cNumOrc, STR0071+SL1->L1_NUM+STR0074+SL2->L2_ITEM+Chr(10)+STR0008+SL2->L2_PRODUTO)  //"Orcamento:" ### " Item:" ### "Código de produto não encontrado: "
			cTextoErro := STR0071+SL1->L1_NUM+STR0074+SL2->L2_ITEM+Chr(10)+STR0008+SL2->L2_PRODUTO
			lError := .T.
		EndIf

		If Empty(cOrigVend)
			If !Empty(SL2->L2_NUMORIG) //Se tiver preenchido o campo L2_NUMORIG, significa que foi um orcamento importado e finalizado por um PDV FrontLoja
				cOrigVend := "FRT" //Venda Finalizada no FRONT (Origem = FRT)
			Else
				cOrigVend := "LOJ" //Venda Finalizada no LOJA  (Origem = LOJ)
			EndIf
		EndIf

		If Lj7SFisPrd(SL2->L2_PRODUTO)  //Se o tipo for Serviço Financeiro, para que, se tiver item somente de SF avulso, vai ter uma série somente para ela.
			nItensSF++
		//Item de "servico"
		ElseIf lMVLJPRDSV .And. LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) .And. ( lScreen .Or. ( !lScreen .And. ( ( cOrigVend == "FRT" .And. !Empty(SL2->L2_NUMORIG) ) .Or. ( cOrigVend == "LOJ" ) ) ) )
			nItensServ++
		ElseIf lFTvdVer12 .AND. lMVLJPRDSV .AND. LjIsTesISS(SL1->L1_NUM,SL2->L2_TES)
			nItensServ++
		Else //Item de "produto"
			nItensProd++
			nItVenda++
		EndIf

		SL2->(DbSkip())
	End
	If lError
		LjGravaErr(cTextoErro)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a integração com EAI Enviando o Erro.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntegEAI .AND. !Empty(cTextoErro)
			//ConOut("LOJIXFUNC:(543) Start integracao EAI Enviando o Erro: "+cTextoErro)
			FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
		Endif
		Return(.F.)
	EndIf

	If lMVLJPRDSV
		lOnlyServ := nItensProd == 0 .And. nItensServ > 0

		//Se tiver apenas itens de servico na venda, considera a serie do RPS (parametro MV_LOJARPS)
		If lScreen .And. lOnlyServ
			cSerie := cMVLOJARPS
		EndIf
		If nItVenda == 0
			nItVenda := nItensServ
		EndIf
	EndIf

	//Atribuo a série de Serviços Financeiros: As vezes a série pode estar preenchida após a emissão fiscal, mas o número de ordem não.
	If nItensSF > 0 .AND. nItensServ = 0 .AND. nItensProd = 0
		cSerie := cMVLOJASF
	EndIf
	
	//-----------------------
	// Se for Emissao de NF-e
	//-----------------------
	If !IsBlind() .And. !lNFePDV .And. SL1->L1_IMPNF .And. AllTrim(LjNfEspeci(cSerie)) == "SPED"
		//---------------------------------------------------------------------------
		// Quando é NF-e, valida a situação do Cliente (Contribuinte) junto a SEFAZ,
		// para verificar se existe alguma restrição antes de transmitir a NF-e,
		// evitando assim, que ocorra erro de Nota Denegada.
		//---------------------------------------------------------------------------
		If ExistFunc("LjVldContr")
			//Valida se o Contribuite está com alguma Restrição junto a SEFAZ.
			If !LjVldContr(SL1->L1_CLIENTE,SL1->L1_LOJA,@cDescErro)
				lErroNFe	:= .T.	//Sinaliza como ERRO para venda NF-e
				LjMsgGrvTudo(lScreen, cNumOrc, STR0193) //"Venda abortada devido Restrição do Cliente junto à SEFAZ."
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a variavel nNccGerada > 0 significa que as parcelas do SL4 foram excluidas ³
//³pelo fato de estarem com valor igual a zero. Se a soma das NCCs utilizadas for³
//³igual ao valor da venda, tambem nao gera parcelas no SL4 porque se equivalem  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNccGerada == 0 .AND. If(_lScreen, nNccUsada+0.01 < SL1->L1_VLRTOT, SL1->L1_CREDITO+0.01 < SL1->L1_VLRTOT )
	dbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	If !SL4->(MsSeek(cFilSL4 + SL1->L1_NUM))
		LjMsgGrvTudo(lScreen, cNumOrc, STR0004+SL1->L1_NUM) //"Parcelas não encontradas no orçamento: "
		cTextoErro := STR0004+SL1->L1_NUM
		LjGravaErr(cTextoErro)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a integração com EAI Enviando o Erro.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntegEAI .AND. !Empty(cTextoErro)
			//ConOut("LOJIXFUNC:(583) Start IntegDef EAI Enviando o Erro: "+cTextoErro)
			FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
		Endif
		Return (.F.)
	EndIf
EndIf

If nModulo == 12 .and. Empty(SL1->L1_ORCRES)
	LjGrvLiq(nMoedaCor)
EndIf

aAuxReceb := LJ7aReceb( lScreen, lTEFNSUDigit )
If aAuxReceb[1]
	aReceb := aClone( aAuxReceb[2] )
Else
	Return .F.
EndIf

//Se integracao via Mensagem Unica, mantem Documento e Serie enviado
//Nao necessita verificar se numeracao ja foi utilizada, ja efetuada no adapter
If lIntegDef
	//Serie
	cSerie := SL1->L1_SERIE			
			
	//Doc
	cNumNota := SL1->L1_DOC	
			
	AAdd(aNotas,{cSerie,cNumNota})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ * o SL1->L1_ESPECIE so retorna "NFM" caso vir do front de notas digitadas manualmente                     ³
//³ * Release 11.5 - Controle de Formularios - O l2SPdvChi retorna T se a venda veio do front-loja			  ³
//³   como NF (L1_IMPRIME = 2S).Neste caso,numero e serie definidos no front loja serao mantidos sem          ³
//³   necessidade de passar pelo LJXDNOTA. 																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Tratamento para NF-e vindo do PDV respeitar o numero/serie
ElseIf !lImpCupFis .AND. !(AllTrim(SL1->L1_ESPECIE) $ "NFM|NFCF") .AND. !l2SPdvChi .and. !lModDoc55	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica numeracao maxima de itens no caso de NF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cPaisLoc == "BRA"

		nMaxItens := SuperGetMV("MV_SER"+cSerie,.F.,SuperGetMV("MV_NUMITEN"))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem proximo numero de nota de acordo com a serie informada, ou de acordo com a serie escolhida no ListBox³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a quantidade de notas a serem geradas   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nItVenda > nMaxItens
			nQtdeNotas := Int(nItVenda / nMaxItens) + If(Mod(nItVenda,nMaxItens) > 0,1,0)
		Else
			nQtdeNotas := 1
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o numero da nota                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cSerie)
			cSerie    := Space(nTamSerie)
		EndIf
		If !LjxDNota( cSerie  , nCheck   , @lImpCupFis , nQtdeNotas , ;
		              @aNotas , cNumNota , NIL         , NIL        , ;
		              NIL     , NIL      , NIL         , @lVendaCup   )
			Return (.F.)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta usando numeracao de NF pelo SD9  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMV_TPNRNFS <> "3"
				cSerie		:= aNotas[1,1]
				cNumNota	:= aNotas[1,2]
				cNumNota    := PadR( cNumNota  , nTamF2_DOC )
				lRetIncSx5  := .T.
			EndIf
		EndIf

	Else
		nMaxItens := SuperGetMV("MV_SER"+cSerie,.F.,0)

		If ValType(nMaxItens) <> 'N' .OR. nMaxItens ==0
			nMaxItens := SuperGetMV("MV_NUMITEN")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem proximo numero de nota de acordo com a serie informada, ou de acordo com a serie escolhida no ListBox³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a quantidade de notas a serem geradas   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nItVenda > nMaxItens
			nQtdeNotas := Int(nItVenda / nMaxItens) + If(Mod(nItVenda,nMaxItens) > 0,1,0)
		Else
			nQtdeNotas := 1
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o numero da nota                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cSerie )
			cSerie    := Space( nTamSerie )
		EndIf

		If !LjxDNota( cSerie  	, nCheck   	, @lImpCupFis , nQtdeNotas , ;
		              @aNotas 	, cNumNota 	, NIL         , NIL        , ;
		              NIL     	, NIL      	, NIL         , @lVendaCup , ;
		              NIL		,NIL		, cDocFo   )
			Return (.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios 		  ³
		//³Validar o controle de formulario informado     ³
		//³no inicio da venda.  						  ³
		//³Paises:Chile/Colombia - F1CHI				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCFolLocR5 .AND. !Empty(cDocFo)
			nRecnoSFP := LjGRecFo()
			LjxDadosFo(nRecnoSFP,NIL,@cSigEspFo)
			If !ChkFolCHI(	xFilial("SFP")	, aNotas[1,1], aNotas[1,2], "1|2|3|4",;
							NIL,	.F.)
				Return (.F.)
			EndIf
		EndIf


        DbSelectArea("SF2")
        DbSetOrder(1)
        cNumNota := aNotas[1,2]
		cNumNota := PadR( cNumNota, nTamF2_DOC )
        cNumAnt  := cNumNota
        If cPaisLoc$"CHI|COL" .AND. Empty(cSerie)
        	cSerie := aNotas[1,1]
        EndIf
       	cAliasNF := "SF2"
		While lExiste
        	lExiste := !aNumNaoExiste( cAliasNF    , cSerie , cNumNota , SL1->L1_CLIENTE , ;
        	                           SL1->L1_LOJA, If(lImpCupFis,"CF",MVNOTAFIS)       , ;
        	                           "LOJ"       )
            If lExiste
				cNumNota := PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
			Else
            	If cNumAnt <> cNumNota
                	nI := 1
                    aNotas  := {}
                    While nI <= nQtdeNotas
	                	AAdd(aNotas,{cSerie,cNumNota})
		               	If nI < nQtdeNotas
							cNumNota := PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
		               	EndIf
	                   	nI++
                    End
                    cNumNota  := aNotas[1,2]
                    cNumNota  := PadR( cNumNota , nTamF2_DOC )
	                If nAltera == 1
		               	MsgInfo( STR0095 + cNumAnt + STR0096 + cNumNota, STR0030)		          //" O Numero do Documento foi alterado de: "###" para: "###"Numero"
	                ElseIf nAltera == 2
		               	lSaida := MsgYesNo(STR0097+ cNumAnt + STR0098 + cNumNota ) //" O documento no.: "###" ja existe, confirma alteracao da numeracao para: "
	                	If !lSaida
	                		Return(.F.)
	                	EndIf
	                Else
		               MsgInfo(STR0097 + cNumAnt + STR0099,STR0100) //" O documento no.: "###" ja existe "###"Numero do Documento "
   		               lSaida := .F.
   		               Return(.F.)
	            	EndIf
              	EndIf
			EndIf
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna numero da nota fiscal para o arquivo de Tabelas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSaida
			cNumNota := aNotas[1,2]
			cNumNota := PadR( cNumNota , nTamF2_DOC )
			DbSelectArea("SX5")
			If DbSeek( cFilial+"01"+cSerie )
				RecLock("SX5",.F.)
				If Val(X5Descri()) <= Val(cNumNota)
	                REPLACE X5_DESCRI  WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
					REPLACE X5_DESCSPA WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
					REPLACE X5_DESCENG WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
				EndIf
				MsUnlock()
			EndIf
		EndIf
	EndIf
Elseif cPaisLoc == "ARG" .AND. lImpCupFis .AND. lImpTicFat

	cSerie  := Lj7SerArg()

	nMaxItens := SuperGetMV("MV_NUMITEN")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a quantidade de notas a serem geradas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItVenda > nMaxItens
		nQtdeNotas := Int(nItVenda / nMaxItens) + If(Mod(nItVenda,nMaxItens) > 0,1,0)
		lImpCupFis := .F.
	Else
		nQtdeNotas := 1
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o numero da nota da impressora.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LJ7VerCmd( nRet )
		nX := 1
		While nX <= nQtdeNotas
			aAdd(aNotas,{cSerie,cNumNota})
			If nX < nQtdeNotas
				cNumNota := StrZero(Val(cNumNota)+1, nTamDoc)
			Endif
			nX ++
		End
	Else
		Alert( STR0186 ) //"Erro ao pegar o numero do documento da Impressora."
		Return (.F.)
	Endif

	cNumNota := StrZero(Val(cNumNota) - (nQtdeNotas - 1), nTamDoc)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao utilizada para caso algum registro esteja locado retorne erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("SetAbendLock") .AND. cPaisLoc <> "ARG"
	ConOut("Habilita SetAbendLock - .T.")
	SetAbendLock(.T.)
EndIf

//-------------------------------------------------------------------------
// Carrega as variaveis estaticas referente ao "Cartao Presente" (Gift Card).
//-------------------------------------------------------------------------
If Lj7CP_OK() .And. !lScreen
	Lj7CP_Load()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para caso ocorra algum erro durante     ³
//³a transação de gravação seja identificado e tratado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

bMTrans := {|| LjGrvTran(	lScreen		, 	cNumOrc		, 	aSL1		, 	aSL2		,;
							lImpCupFis	, 	@aNotas		, 	cNumNota	, 	cSerie		,;
							nMaxItens	, 	aImpsSF2	, 	nTotLiq		, 	nTotImp		,;
							nTotDesc	, 	nBaseDup	, 	nDecimais	, 	nBasePS2	,;
							nValPS2		, 	nBaseCF2	, 	nValCF2		, 	aRecSE1		,;
							aVlrAcres	, 	cMV_TPNRNFS	, 	lFinanceiro	, 	nNccUsada	,;
							aNccItens	,	nNccGerada	,	aReceb		,	aImpCheque	,;
							nMoedaCor	,	nNumItens	,   nFrete	  	,	nSeguro	    ,;
							nDespesa	,	nCheck      ,   cLQFrete    ,   lRetIncSx5  ,;
							aAcrFin		,	lPedFin 	,	cCgcCli   	,	cNomeCli	,;
							lNfManual	,   @cEspecNf 	,   aBreakNota	,	@aNewNCC	,;
							cTpGeraGdp	,	nOpc 		, 	@lIsVendaVP , 	@lIsVdRecCP ,;
							nArredondar	, 	@cDescErro  ,   lNFePDV  )}

If InTransaction()
	lRetTran := Eval(bMTrans)
	LjGrvLog(ProcName(0),"Está em transação ? " + IIf(InTransaction(), "SIM", "NÃO") )
Else 
	/*|Gravo como 'ER' antes de processar a venda, pois caso ocorra problema de chave| 
	|duplicada é efeutado o Rollback e o registro ficava em loop pois nao atualizava |
	|o L1_SITUA para 'ER' 															 |*/
	If SL1->L1_SITUA == "RX"
		RecLock("SL1", .F.)
		REPLACE	SL1->L1_SITUA WITH "ER"
		SL1->(MsUnlock())
		IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
	EndIf

	bOldError := ErrorBlock( {|x| LjVerifErro(x,@cDescErro) } ) // muda code-block de erro
	
	Begin Transaction
	
		Begin Sequence
			lRetTran := Eval(bMTrans)
			//Caso o retorno da LjGrvTran seja falso desfaço a transação atual.
			If !lRetTran
				LjVerifErro(,,.T.)
			Endif
		Recover   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso tenha ocorrido erro a transaçao sera desfeita³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lScreen
				If !Empty(AllTrim(SL1->L1_SERSAT))
					LJSatxCanc(.T.) //Cancela SAT
				EndIf
			EndIf		
			DisarmTransaction()
			LjGravaLog( lScreen, cNumOrc, 'Ocorreu erro na transacao de gravacao - 1', LMSTOP)	
			lRetTran := .F.
	
			If !lImpCupFis .AND. cMV_TPNRNFS == "1"
				DbSelectArea("SX5")
				If DbSeek( xFilial()+"01"+cSerie )
					RecLock("SX5",.F.)
					REPLACE X5_DESCRI  WITH PadR( StrZero(Val(cNumNota),Len(AllTrim(cNumNota))) , nTamDoc )
					REPLACE X5_DESCSPA WITH PadR( StrZero(Val(cNumNota),Len(AllTrim(cNumNota))) , nTamDoc )
					REPLACE X5_DESCENG WITH PadR( StrZero(Val(cNumNota),Len(AllTrim(cNumNota))) , nTamDoc )
					MsUnlock()
				EndIf
		
			ElseIf __lSX8 .AND. cMV_TPNRNFS == "2"
				While (GetSX8Len() > nSaveSx8)   	
					RollbackSX8()
				End
			ElseIf cMV_TPNRNFS == "3" .And. Len(aNotas) > 0
				DbSelectArea("SD9")
				SD9->( DbSetOrder(1) )	
				If SD9->( DbSeek(xFilial("SD9") + aNotas[1][1] + DtoS(DDATABASE) + aNotas[1][2]) )
					RecLock("SD9", .F.)
					Replace SD9->D9_DTUSO with CtoD("  /  /  ")
					Replace SD9->D9_HORA with Space(TamSX3("D9_HORA")[1])
					Replace SD9->D9_USUARIO with Space(TamSX3("D9_USUARIO")[1])
					SD9->( MsUnlock() )	
				EndIf
			EndIf
			
			If lScreen .AND. ( ( !lIsVendaVP .And. !lIsVdRecCP )  .Or.;
				 !( !SuperGetMV("MV_LJGRVON",,.T.) .And. ( (SuperGetMV("MV_LJTXNFE",,0) == 1) .Or. LjEmitNFCe() ) ) )
				If !SF2->(Eof()) // Se entrar para gerar livro em final de arquivo esta gerando livro com informacoes em branco
					/*Gera SF3 OnLine como cancelada*/
					MaFisAtuSF3(1,"S",SF2->(Recno()),"SF2",NIL,NIL,cNomeProg)
					SFT->(MsUnlock())
					MaFisAtuSF3(2,"S",SF2->(Recno()),"SF2",NIL,NIL,cNomeProg)
				EndIf	
			EndIf
			
			If lPadrao .AND. cPaisLoc $ "MEX|PAR"
			
				nHdlPrv:=HeadProva("","LOJXFUNC",Substr(cUsername,1,6),@cArquivo)
					
				If  nHdlPrv > 0
					nTotal+=DetProva(nHdlPrv,cPadrao,"LOJXFUNC","")
				EndIf
						
				If  nTotal > 0
					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina)
				EndIf
				
		    EndIf
		End Sequence
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura rotina de erro anterior³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ErrorBlock( bOldError )
	End Transaction
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
|Caso ocorra algum problema e a transação ficar em aberto derrubo a tread coselho do Framework  |
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
If InTransaction() .And. !lRetTran
	Conout(cNumOrc +",Ocorreu erro na transacao de gravacao da venda e essa sera abortada. Finalizando a Tread")
	LjGrvLog( cNumOrc, "Ocorreu erro na transacao de gravacao da venda e essa sera abortada. Finalizando a Tread")
	Final()
EndIf
//Função que excluirá fisicamente as temporárias do banco de dados.
If UPPER(Alltrim(TCGetDb()))=="POSTGRES"
	Fa040Drop()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao utilizada para caso algum registro esteja locado retorne erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("SetAbendLock") .AND. cPaisLoc <> "ARG"
	ConOut("Desabilita a funcao SetAbendLock - .F.")
	SetAbendLock(.F.)
EndIf

If lRetTran
	If FwHasEai("LOJI701A",.T.,,.T.)
		//Chamada da função de atualização de status no fonte LOJI701A
		LjGrvLog("LOJXFUNC", "Gera mensagem de Rastreio se venda contiver itens do tipo Retira. Finalização como venda (LOJI701A)")
		FwIntegDef("LOJI701A",,,, "LOJI701A")
	EndIf
Else
	LjGravaLog( lScreen, cNumOrc, 'Ocorreu erro na transacao de gravacao - 2', LMSTOP)
	 //---------------------------------------------
	 //| Faz a integração com EAI Enviando o Erro. |
	 //---------------------------------------------
	cTextoErro := 'Ocorreu erro na transacao de gravacao - 2'
	If lIntegEAI .AND. !Empty(cTextoErro)
		//ConOut("LOJIXFUNC:(1073) Start IntegDef EAI Enviando o Erro: "+cTextoErro)
		FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
	Endif
	Return .F.
EndIf

LjGravaLog( lScreen, cNumOrc, '30) END TRANSACTION' + ' - lRetTran= ' + IIf(lRetTran,".T.",".F.") + ' - ', LMALERT)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Si identifica que hay error en la transaccion cierra sesi evitando    ³
//³que las demas ventas se graben con el mismo error y realice Roolback  ³
//³de las facturas generas a partir del primer evento generado con error.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If InTransaction() .And. !lRetTran .AND. cPaisLoc $ "MEX"
	Conout(cNumOrc +",Ocorreu erro na transacao de gravacao da venda e essa sera abortada. Finalizando a Tread")
	LjGrvLog( cNumOrc, "Ocorreu erro na transacao de gravacao da venda e essa sera abortada. Finalizando a Tread")
	Final()
EndIf

If SuperGetMV( "MV_LJILVLO",,"2" ) == "1"
	oLJCLocker:ReleaseLock( "LOJA701AILLock" )
	Sleep(300)
 	If !oLJCLocker:GetLock( "LOJA701AILLock" )
 		If ModType(nModulo) == 'L'
			FinishLoja(.T.)
		EndIf
 		nModulo := 0 // Impede que o final rode o FinishLoja novamente.
 		DbCloseAll() // Fecha todas as tabela para que a carga possa ser efetuada.
		Final(STR0152) // "O sistema será encerrado, pois foi solicitado a carga de dados nesse terminal."
	EndIF
Endif

//Verifica se transação ocorreu corretamente e se é N.Fiscal
If lRetTran .And. LjNFFimVd()
	LjGrvLog( SL1->L1_NUM, "Verifica se emite a guia do DIFAL" )

	// Função responsavel pela gravação das guias de DIFAL, e tambem FECP se caso houver SF3->F3_VFCPDIF
	// (Valor do ICMS relativo ao Fundo de Combate à Pobreza (FCP) da UF de destino)
	LjGrvDIFAL( cNumNota )
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Ponto de Entrada de Templates Chamado apos a Gravacao do SE1 ³
³Atualiza o SE1 gravando o Cod. Dependente                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If ExistTemplate("LJTPLSE1")
	ExecTemplate("LJTPLSE1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a integração com EAI Enviando o Situa OK.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntegEAI .AND. Empty(cTextoErro)
	//ConOut("LOJIXFUNC:(1117) Start IntegDef OK: "+cTextoErro)
	FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ljNota    ³ Autor ³  Vendas Clientes      ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao do numero e serie da nota fiscal                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXFUNC                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNota(cSerie, cNumNota,lRetIncSx5)
Local lTudo													// Se eh tudo
Local aSerNf												// Serie da Nota Fiscal
Local aRecnos												// Recno
Local nI													// Contador
Local oDlgLojaNota											// Objeto
Local nContErr		:= 0									// Contador de Erro
Local oQual													// Objeto
Local cVarQ 		:= "  "									// Variavel
Local lRetorno		:= .F.									// Retorno da funcao
Local lRet          := .F.                                 	// Retorno da funcao - numero valido
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5
Local __lChgX5FIL   := ExistBlock("CHGX5FIL")				// Ponto de Entrada
Local nTamDoc       := TamSX3("L1_DOC")[1]                 // Tamanho do campo L1_DOC
Local lScreen		:= If(_lScreen == NIL, .T.,_lScreen)	// Verifica se exibe as mensagens na tela ou com conout

Default lRetIncSx5  		:= .F.										// Verifica se o SX5 ja foi gravado com o numero da NF atual

If __lChgX5FIL
	cFilSx5 := ExecBlock("CHGX5FIL",.F.,.F.)
EndIf

If Empty(cSerie)
	While .T.
		If ! SX5->(DbSeek( cFilSx5+"01" ))
			Help("",1,"ERROSERIE")
			Return (.F.)
		EndIf

		lTudo   := .T.
		aSerNf	:= {}
		aRecnos := {}

		While cFilSx5+"01" == SX5->X5_FILIAL+SX5->X5_TABELA
			If ! SX5->(MSRLock()) .OR. SubStr(SX5->(X5Descri()),1,1) == "*"
				lTudo := .F.
				Exit
			EndIf

			Aadd(aRecnos,SX5->(Recno()))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
			//³ internamente para emissao de Cupom Fiscal.					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If AllTrim(SX5->X5_CHAVE) $ "CPF;CP"
				SX5->(DbSkip())
				Loop
			EndIf

			Aadd(aSerNF,{Trim(SX5->X5_CHAVE),Trim(SX5->(X5Descri()))})
			SX5->(DbSkip())
		End

		If ! lTudo
			nContErr ++

			If nContErr > 10
				SX5->(DbSeek( cFilSx5+"01" ))

				While cFilSx5+"01" == SX5->X5_FILIAL+SX5->X5_TABELA
					SX5->(MsUnlock())
					SX5->(DbSkip())
				End

				Help(" ",1,"NOTAPRESA")
				nCOntErr := 0
			EndIf

			Inkey(1)
			Loop
		EndIf

		Exit
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata s‚rie e numero da nota fiscal  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DEFINE MSDIALOG oDlgLojaNota TITLE STR0012 From 10,30 To 19.7,68;		// "Série/NF"
	OF GetWndDEFAULT()

	@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0013,STR0030 SIZE 130,42; // "Serie"  /  "Número"
	ON DBLCLICK (LjGetNota(oQual:nAt,@aSerNF),oQual:Refresh()) NOSCROLL

	oQual:SetArray(aSerNF)
	oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}

	DEFINE SBUTTON FROM 51,078 TYPE 1 ACTION (lRetorno := .T.,If(LjAtuNota(@cSerie,@cNumnota,oQual,@aSerNf),;
	oDlgLojaNota:End(),)) ENABLE OF oDlgLojaNota

	DEFINE SBUTTON FROM 51,107 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota

	ACTIVATE MSDIALOG oDlgLojaNota CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acertando o numero da nota no Sx5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		SX5->(DbSeek( cFilSx5+"01"+cSerie ))
        REPLACE SX5->X5_DESCRI 	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
		REPLACE SX5->X5_DESCSPA	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
		REPLACE SX5->X5_DESCENG	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Liberando registros locados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to Len(aRecnos)
		SX5->(DbGoTo(aRecnos[nI]))
		SX5->(MsUnlock())
	Next nI
	Return (lRetorno)
Else
	If !SX5->(DbSeek(cFilSx5+"01"+cSerie))
		If lScreen
			HELP(" ",1,"ERROSERIE")
		Else
			ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0014+" - "+cSerie)     // "Filial " ### ". " "Tabela de Series (01) nao encontrada no SX5"
		EndIf
		Return .F.
	EndIf
	While !SX5->(MsRLock())
		InKey(1)
		nContErr++
		If nContErr > 10
			If lScreen
				Help(" ",1,"NOTAPRESA")
			Else
				ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0015+cSerie)    // "Filial " ### ". " "Registro travado no SX5, Tabela 01, Serie "
			EndIf
			nCOntErr := 0
		End
	End
	cNumNota := SubStr(Sx5->(X5Descri()),1,nTamDoc)
    REPLACE SX5->X5_DESCRI 	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
	REPLACE SX5->X5_DESCSPA	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
	REPLACE SX5->X5_DESCENG	WITH PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamDoc )
	SX5->(MsUnlock())
EndIf

lRet  := LjValNota(cSerie,cNumNota)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjGetNota³ Autor ³ Vendas Clientes       ³ Data ³ 19/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Da get no numero da nota fiscal e na serie                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetNota(nIt, aSerNF)
Local oDlgLojaNf
Local oBtn
Local cNumero	:= aSerNf[nIt,2]

DEFINE MSDIALOG oDlgLojaNf TITLE STR0012 From 13,50 To 18,65 OF GetWndDEFAULT()	// "Série/NF"

@ .8,.8 MSGET cNumero Picture "@!" Font oDlgLojaNf:oFont Valid oDlgLojaNf:End()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao invisivel para poder exibir help na validacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 2000, 2000 BUTTON oBtn Prompt STR0016 SIZE 44, 11 ACTION oDlgLojaNf:End() OF oDlgLojaNf PIXEL   //"Sair"

ACTIVATE MSDIALOG oDlgLojaNf

aSerNf[nIt,2] := cNumero

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³LjAtuNota ³ Autor ³ Vendas Clientes       ³ Data ³ 18/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Atualiza numero de nota e serie                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010ANf                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjAtuNota( cSerie , cNumNota , oQual , aSerNf )
Local cNumSX5
Local cNota
Local nRecSF2   := SF2->(Recno())
Local nOrderSF2 := SF2->(IndexOrd())
Local nTamDoc   := TamSX3("L1_DOC")[1]                 // Tamanho do campo L1_DOC
Local cFilSx5	:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5

If !LjValNota(aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2])
	SX5->(DbSeek( cFilSx5+"01" ))

	While ! SX5->(Eof()) .AND. SX5->X5_Tabela == "01"
		If AllTrim(SX5->(X5_Chave)) == AllTrim(aSerNf[oQual:nAT,1])
			cNumSx5 := SX5->(X5Descri())
			Exit
		EndIf
		SX5->(DbSkip())
	End

	If Val(aSerNf[oQual:nAT,2]) >= Val(cNumSx5)
		aSerNf[oQual:nAT,2] := StrZero(Val(cNumSx5),nTamDoc)
		oQual:Refresh()

		Return .F.

	EndIf

	SF2->(DbSetOrder(4))
	SF2->(DbSeek(xFilial("SF2")+aSerNf[oQual:nAT,1]))

	IF SF2->(Eof())
		cNota := STRZERO(0,nTamDoc)
	Else

		While SF2->F2_Filial+SF2->F2_Serie == xFilial("SF2")+aSernF[oQual:nAT,1] .AND. ! SF2->(Eof())
			cNota := SF2->F2_Doc
			SF2->(DbSkip())
		End

	EndIf

	aSerNf[oQual:nAT,2] := PadR( StrZero(Val(cNota)+1,Len(cNota)) , nTamDoc )

	oQual:Refresh()
	SF2->(DbGoTo(nRecSF2))
	SF2->(DbSetOrder(nOrderSF2))

	Return .F.

Else
	cSerie	:= aSerNf[oQual:nAT,1]
	cNumNota := aSerNf[oQual:nAT,2]
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjValNota³ Autor ³ Vendas Clientes       ³ Data ³ 19/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida nota informada                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjValNota(cSerie, cNumNota, lDavPre)
Local lRet 		  := .T.
Local lNotaManual := .F.
Local nRecSL1     := SL1->(Recno())
Local nOrderSL1   := SL1->(IndexOrd())
Local nRecSF2     := SF2->(Recno())
Local nOrderSF2   := SF2->(IndexOrd())
Local nRecSF1     := SF1->(Recno())
Local nOrderSF1   := SF1->(IndexOrd())
Local cContNF     := SuperGetMV("MV_CONTNF",,"I")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5	:=	cPaisLoc$"CHI|COL" .AND. SuperGetMv("MV_CTRLFOL",,.F.) .AND. !lFiscal
Local lErroNumNota	:= .F.
Local lIsSat	  	:= LjUseSat()

DEFAULT lDavPre := .F.

If lDavPre
	cNumNota	:= Padr(cNumNota,TamSx3("L1_NUMORC")[1])
	cSerie 		:= Padr(cSerie,TamSx3("L1_TPORC")[1])
Else
	cSerie 		:= Padr(cSerie,TamSx3("L1_SERIE")[1])
	cNumNota	:= Padr(cNumNota,TamSx3("L1_DOC")[1])
EndIf

If Empty(cNumNota)
	LjGrvLog(Nil,"Numero da nota em branco")
	Help(" ",1,"LJ010NOTA")
	lRet := .F.
EndIf

If lIsSat
	LjGrvLog(Nil,"Venda SAT não tem controle de numeração pelo SX5 - LjValNota não validado")
EndIf

If !lIsSat
	If lRet
		If lDavPre
			SL1->(DbSetOrder(13)) //L1_FILIAL+L1_TPORC+L1_NUMORC
		Else
			SL1->(DbSetOrder(2))  //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		EndIf
		SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		SF3->(DbSetOrder(5)) //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT

		/*Release 11.5 - Controle de Formularios      				               
		Quando for modulo FRONTLOJA, caso o numero de documento                    
		ja existir na tabela SL1 mas o registro estiver com L1_SITUA == "00"       
		indicando que a venda nao foi encerrada com sucesso, o numero da nota sera 
		considerado valido.                                                        
		Paises : Chile/Colombia - F1CHI                                            */
		If lCFolLocR5 .AND. nModulo == 23 .And. SL1->(DbSeek(xFilial("SL1")+cSerie+cNumNota)) .And. SL1->L1_SITUA == "00" //Venda Efetuada com sucesso
			LjGrvLog(Nil,"Numeração Existente - Chave SL1 Filial+Serie+NumNota [" + xFilial("SL1")+cSerie+cNumNota +"]")
			lErroNumNota := .T.
		Else
			If SL1->(DbSeek(xFilial("SL1")+cSerie+cNumNota)) .OR. SF2->(DbSeek(xFilial("SF2")+cNumNota+cSerie))
				LjGrvLog(Nil,"Numeração Existente - Chave SL1 -> Filial + Serie + NumNota [" + xFilial("SL1")+cSerie+cNumNota +"]")
				LjGrvLog(Nil,"Numeração Existente - Chave SF2 -> Filial + NumNota + Serie [" + xFilial("SF2")+cNumNota+cSerie +"]")
				lErroNumNota := .T.
			EndIf
		EndIf

		//Volta posicionamento na SL1 pq ira gravar no campo L1_ERGRBT	
		SL1->( DbGoTo(nRecSL1) )

		If lErroNumNota
			lScreen := If(Type("lScreen") == "L",lScreen,.T.)
			If lScreen
				Help(" ",1,"LJ010NOTA")
			Else
				ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0017+cNumNota+"/"+cSerie)  // "Filial " ### ". " "Numero de nota ja utilizado. Nota/Serie: "
			EndIf
			lRet := .F.
			If SL1->(ColumnPos("L1_ERGRVBT")) > 0
				RecLock("SL1",.F.)
				SL1->L1_ERGRVBT := "LJGrvBatch: "+STR0079+cFilAnt+". "+STR0017+cNumNota+"/"+cSerie
				SL1->(MsUnLock())
			EndIf
			LjGrvLog(Nil,"LJGrvBatch: "+STR0079+cFilAnt+". "+STR0017+cNumNota+"/"+cSerie)
		EndIf
	
		// Caso emita NF vai verificar se a NF foi denegada
		If lRet .AND. LjNFFimVd() .AND. SF3->(DbSeek(xFilial("SF3")+cSerie+cNumNota))
			If ChkF3Deneg( cSerie,cNumNota )
				lScreen := If(Type("lScreen") == "L",lScreen,.T.)
				If lScreen
					Help(" ",1,"LJ030NOTA")
				Else
					ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0157+cNumNota+"/"+cSerie)  // "Filial " ### ". " "Número de nota já utilizado. Esta numeração está denegada e nãopoderá ser reutilizada. Nota/Serie: "
				EndIf
				lRet := .F.
				If SL1->(ColumnPos("L1_ERGRVBT")) > 0
					RecLock("SL1",.F.)
					SL1->L1_ERGRVBT := "LJGrvBatch: "+STR0079+cFilAnt+". "+STR0157+cNumNota+"/"+cSerie
					SL1->(MsUnLock())
				EndIf
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Varre o SF1 para ver se a nota foi utilizada como devolucao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			DbSelectArea("SF1")
			DbSetOrder(1)
			DbSeek(xFilial("SF1")+cNumNota+cSerie)
			While !Eof() .AND. SF1->F1_DOC+SF1->F1_SERIE = cNumNota+cSerie .AND. lRet
		
			    If cPaisLoc <> "BRA" .AND. cContNF == "I"
			       DbSkip()
			       Loop
			    EndIf
		
				If SF1->F1_FORMUL == "S"
					lScreen := If(Type("lScreen") == "L",lScreen,.T.)
					If lScreen
						Help(" ",1,"LJ010NOTA")
					Else
						ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0017+cNumNota+"/"+cSerie)  // "Filial " ### ". " "Numero de nota ja utilizado. Nota/Serie: "
					EndIf
					lRet := .F.
					If SL1->(ColumnPos("L1_ERGRVBT")) > 0
						RecLock("SL1",.F.)
						SL1->L1_ERGRVBT := "LJGrvBatch: "+STR0079+cFilAnt+". "+STR0017+cNumNota+"/"+cSerie
						SL1->(MsUnLock())
					EndIf
				EndIf
				DbSkip()
			End
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se numeracao da NF esta autorizada por resolucao    ³
		//³(SAT)-Loc. Guatemala                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "GUA" .AND. lRet
		   If Type("lNFManual")<>"U"
			   	lNotaManual  := lNFManual
		   Else
				lNotaManual  := .F.
		   EndIf
		
		   lRet  := ValNumSAT(cSerie,cNumNota,"1",lNotaManual)
		   If !lRet
			  lScreen := If(Type("lScreen") == "L",lScreen,.T.)
			  If lScreen
			     //"Atenção"###"Numeracao: "###" nao autorizada por resolucao. Entre em contato com a SAT."###"Ok"
			     Aviso(STR0082,STR0101+cNumNota+"/"+cSerie+STR0102,{STR0103})
			  Else
				 ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0101+cNumNota+"/"+cSerie+STR0102)  // "Filial " ### ". " "Numeracao: "###" nao autorizada por resolucao. Entre em contato com a SAT."
			  EndIf
		   EndIf
		EndIf
	EndIf
	
	SL1->(DbGoTo(nRecSL1))
	SL1->(DbSetOrder(nOrderSL1))
	SF2->(DbGoTo(nRecSF2))
	SF2->(DbSetOrder(nOrderSF2))
	SF1->(DbGoTo(nRecSF1))
	SF1->(DbSetOrder(nOrderSF1))
EndIf

Return lRet

/*/{Protheus.doc} LjGrvSF2
Fecha uma determinada Nota Fiscal
@type	Function
@author	Vendas Clientes
@since	19/09/00
@param	ExpL1 - controla se e a primeira ou ultima chamada da gravacao
		ExpL2 - controla se imprime cupom fiscal
		ExpC3 - numero do documento
		ExpC4 - numero do primeiro documento
		ExpA5 - array com impostos variaveis(Loc.)
		ExpN6 - valor total liquido(Loc.)
		ExpN7 - valor total dos impostos discriminados(Loc.)
		ExpC8 - serie do documento
		ExpN9 - valor do desconto da venda
		ExpN10 - valor base das duplicatas
@return	Nil
/*/
Function LjGrvSF2(	lFim	,	lImpCupFis	,	cNumNota	,	cFirst	,;
					aImpsSF2,	nTotLiq		,	nTotImp		,	cSerie	,;
					nTotDesc,	nBaseDup	,	nBasePS2	,   nValPS2	,;
					nBaseCF2,	nValCF2		,	lScreen		,	aTotais ,;
					lRetIncSx5, cCgcCli   	,	lNfManual	, 	nBaseRed,;
					lIsNextNF, 	lNxtNFServ 	,	cSerieNF	, 	lNFServ )

Local cTiposDoc 	:= AllTrim( SuperGetMv( 'MV_ESPECIE' ) )	// Tipos de documento (busca no param. MV_ESPECIE)
Local cEspecie  	:= SPACE(5)									// Especie do Documento
Local cMV_TPNRNFS	:= LjTpNrNFS()								// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local nVlrDescFin   := 0										// Valor do Desconto financeiro
Local lCondNeg		:= .F.										// Verifica se eh condicao negociada
Local nPerDescFin   := 0                                  		// Valor do desconto financeiro
Local cCondPgto		:= ""										// condição de pagamento
Local lSelNota		:= .F.										// Verifica seleção de NF
Local nPerAcrsFin   := 0                                        // Percentual de Acrescimo financeiro
Local nVlrAcrsFin   := 0                                        // Valor de Acreximo financeiro
Local cF2Ecf		:= ""
Local cPadrao		:= "700"                                    // Contabilizacao - Codigo Padrao (Lancamento Padrao: 700=Venda)
Local lPadrao  		:= VerPadrao(cPadrao)						// Contabilizacao - Verifica se o codigo Padronizado existe
Local nHdlPrv  		:= 0										// Contabilizacao
Local nTotal   		:= 0										// Contabilizacao
Local cArquivo 		:= ""										// Contabilizacao
Local lAglutina 	:= .T.										// Contabilizacao (Aglutina Lancamentos)
Local aLancCtb 		:= {} 										// Contabilizacao (Campo Flag de Contabilizacao a ser atualizado)
Local lContrFol     := .F.										// Controle de formularios
Local aDados		:= Array(6)									// Array auxiliar utilizado no controle de faturas
Local nTamCodCTR	:=  0 							       		// Tamanho do Campo Codigo de Controle
Local lFisLivro 	:= (SuperGetMV("MV_LJLVFIS",,1) == 2)		// Utiliza novo conceito para geracao do SF3
Local cNumNextNF	:= ""										// Numero da proxima NF
Local aNotaRPS 	 	:= {}										// Array com informacoes do Numero e Serie da NF de "Servico" (RPS)
Local cChaveNfce	:= SL1->L1_KEYNFCE							// Verifica se foi gerado NFC-e para a venda
Local nTamF2_DOC  	:= 0
Local cRecIss 		:= SA1->A1_RECISS							// Se o cliente recolhe ISS
Local lIntSynt 	 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes³
//³Paises:Chile/Colombia-F1CHI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5		:= cPaisLoc $ "CHI|COL"
Local lFtvdVer12	:= ExistFunc("LjFTvd") .AND. LjFTVD() 	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") 	//Nome da Rotina
Local lVendDireta   := Iif(lFtvdVer12, .T., .F.)
Local nW		    := 0
Local lCalcImpV   	:= SuperGetMV("MV_GERIMPV",,"N")=="S"		// Indica se utiliza impostos variáveis
Local lLeiTran		:= SL2->(ColumnPos("L2_TOTIMP"))>0 .And. SD2->(ColumnPos("D2_TOTIMP"))>0 .And. SF2->(ColumnPos("F2_TOTIMP"))>0 .And. SF2->(ColumnPos("F2_TIPIMP"))>0 //Verifica se existem os campos para utilização da Lei da transparência
Local cMvFisCTrb 	:= SuperGetMv("MV_FISCTRB",.F.,"1")             // método de consulta do percentual de carga tributária.Informe 1 para tratamento legado ou 2 alíquotas da Nota Fiscal e CGA/CGB - #conteudo gravado no campo D2_TIPIMP
Local aArea2		:= {}
Local aAreaSM0	:= {}
Local aTimeUf		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT	:= ""
Local nPesLiq       := 0										// Guarda o peso liquido total da venda
Local nPesBrut		:= 0										// Guarda o peso bruto total da venda
Local nRecnoSL1		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel referente a implementacao da nova lei dos impostos 13032015³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCpoImpEnt	:=	SD2->(ColumnPos("D2_TOTFED")) > 0 .AND.	SD2->(ColumnPos("D2_TOTEST")) > 0 .AND. ;
						SD2->(ColumnPos("D2_TOTMUN")) > 0 .AND.	SF2->(ColumnPos("F2_TOTFED")) > 0 .AND. ;
						SF2->(ColumnPos("F2_TOTEST")) > 0 .AND.	SF2->(ColumnPos("F2_TOTMUN")) > 0 .AND. ;
						SL2->(ColumnPos("L2_TOTEST")) > 0

Local lMenNota      := SuperGetMV("MV_LJMENNO",,.F.)		// Verifica se esta habilitado a apresentacao do campo de observacao da nota fiscal
Local lUseSAT	    := !Empty(SL1->L1_SERSAT) .And. !Empty(SL1->L1_KEYNFCE) //Valida se documento SAT
Local nValFat       := 0										//Total Faturado 
Local lIntegDef     := SL1->L1_ORIGEM == "N"                    //Venda Origem Integração
Local lIntegHtl     := lIntegDef .And. SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria
Local aRelImpInt    := {} //Relacao de impostos, usado para integracao Mensagem Unica
Local cProcesso     := "000405" //Codigo Processo PCO
Local cCodItem      := "02" //Item PCO
Local cHora			:= "" //Hora de escrituração

Local cPrefixo		:= ""

DEFAULT nBasePS2 	:= 0   										//Base de calculo do PIS
DEFAULT nValPS2 	:= 0       									//Valor do PIS
DEFAULT nBaseCF2	:= 0      									//Base de calculo do COFINS
DEFAULT nValCF2		:= 0    									//Valor do COFINS
DEFAULT lScreen		:= .T.										//Venda Assistida ou Job de Integracao Front
DEFAULT aTotais		:= {0, 0, 0}								//F2_VALMERC, F2_DESCONT, F2_VALACRS
DEFAULT lRetIncSx5  :=.F.  										// Verifica se já atualizou o SX5
DEFAULT cCGCCli		:= ""										//CGC/NIT do cliente
DEFAULT lNfManual	:= .F.										//Indica se a nota foi gerada manualmente (Bolivia)
DEFAULT nBaseRed 	:= 0                                        //Valor da base reduzida
DEFAULT lIsNextNF 	:= .T.										//Indica se eh Prox. NF, deve atualizar o campo F2_NEXTDOC
DEFAULT lNxtNFServ  := .F.										//Indica se a proxima NF eh de Servico (RPS)
DEFAULT cSerieNF 	:= SL1->L1_SERIE
DEFAULT lNFServ  	:= .F.										// Indica se eh NF de "servico"

LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - Inicio Gravacao cNumNota:",cNumNota)

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
If ValType(cHoraRMT) == "L"
	If cHoraRMT
		cHoraRMT := "1"
	Else
		cHoraRMT := "2"
	EndIf
Else
	If cHoraRMT == NIL
		cHoraRMT := "2"
	EndIf
EndIf

If Empty(cSerieNF)
	cSerieNF := SL1->L1_SERIE
EndIf

If lNFServ
	cSerie := cSerieNF
EndIf

//Relacao de impostos, usado para integracao
If lIntegDef
	aRelImpInt := MaFisRelImp("MT100", {"SF2", "SD2"}) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve ser realizado o controle de faturas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lContrFol	:=	SF1->(ColumnPos("F1_NUMAUT"))  > 0 .AND. SF1->(ColumnPos("F1_CODCTR")) > 0 .AND.;
				SF2->(ColumnPos("F2_NUMAUT"))  > 0 .AND. SF2->(ColumnPos("F2_CODCTR")) > 0 .AND.;
				SF2->(ColumnPos("F2_LIMEMIS")) > 0 .AND. SF3->(ColumnPos("F3_NUMAUT")) > 0 .AND.;
				SF3->(ColumnPos("F3_CODCTR"))  > 0 .AND. GetNewPar("MV_CTRLFOL",.F.)

If SF2->(ColumnPos("F2_CODCTR")) > 0
	nTamCodCTR	:=  TamSx3("F2_CODCTR")[1]
Endif


// Verifica se esta usando a nova configuracao para confirmar se o cliente recolhera o iss.
If ExistFunc('Lj7RecIss')
	cRecIss := Iif(Lj7RecIss(),"1","2")
Else
	cRecIss := SA1->A1_RECISS
EndIf

If Lj950CheckRPS(SL1->L1_NUM,cRecIss)                   // Verifica se tem excecao fiscal
	cF2Ecf	:= "S"
EndIf

/*	Orcamento que foi gerado em ambiente Loja com Nfce mas
	está sendo finalizado em Venda Direta não deve manter esse campo gravado */
If lFtvdVer12 .And. SL1->L1_TPORC == "E"
	nRecnoSL1 := SL1->(Recno())
	RecLock("SL1",.F.)
	REPLACE SL1->L1_TPORC WITH " "
	SL1->(MsUnlock())
	SL1->(DbGoTo(nRecnoSL1))
EndIf
 
RecLock( "SF2",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos Diversos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REPLACE SF2->F2_FILIAL	WITH xFilial("SF2")
REPLACE SF2->F2_DOC		WITH cNumNota

If lIntegDef //Tratamento integracao para Especie da Nota
	If AllTrim(SL1->L1_ESPECIE) == "NFM" 												
		cEspecie := "NFCF" 
	Else
		cEspecie := SL1->L1_ESPECIE
	EndIf
ElseIf SL1->L1_TPORC == "E" .And. (!Empty(cChaveNfce) .OR. !LjNFFimVd())  //Quando Job GrvBatch, possue chave e nao deve realizar nova validacao. Foi utilizado LjNFFimVd para validar venda onde foi informado no orçamento NFC-e e finalizou como NF-e (04/02/2015)
	
	LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - TPORC=E - cChaveNfce:",cChaveNfce)

	SF2->F2_ECF		:= ""
	If lNFServ
		cEspecie	:= "RPS"	//Para NF de "servico" grava a especie como RPS (Recibo Provisorio de Servico)
	//Para identificar NF-e
	Elseif SL1->L1_IMPNF .or. Substr(cChaveNfce,21,2) == "55" //Colocado duas validacoes devido a usuario mudar o L1_IMPNF para .F.
		cEspecie	:= "SPED"
		SF2->F2_CHVNFE	:= cChaveNfce		//Chave de acesso a NF-e
	ElseIf !lUseSat
		cEspecie	:= "NFCE"	//SpedFiscal trata especie NFCe
		SF2->F2_CHVNFE	:= cChaveNfce		//Chave de acesso a NFC-e
	ElseIf lUseSat
		cEspecie	:= "SATCE"	//SpedFiscal trata especie SAT
		SF2->F2_CHVNFE	:= cChaveNfce		//Chave de acesso a SAT
	EndIf

ElseIf lNFServ
	LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - lNFServ - Especie RPS")
	REPLACE SF2->F2_ECF WITH ""
	cEspecie := "RPS" //Para NF de "servico" grava a especie como RPS (Recibo Provisorio de Servico)
ElseIf lImpCupFis .AND. Empty(cF2Ecf)
	REPLACE SF2->F2_ECF WITH "S"
	cEspecie := "CF"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for o estado de Piaui, grava ECF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(18)[1]
		cEspecie := "ECF"
	EndIf
	LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - lImpCupFis - Especie Cupom:",cEspecie)	
Else
	LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - cF2Ecf:",cF2Ecf)
	REPLACE SF2->F2_ECF WITH cF2Ecf
	If cPaisLoc == "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o SL1->L1_ESPECIE so retorna "NFM" caso vir do front de notas digitadas manualmente                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SL1->L1_ESPECIE) == "NFM"
			cEspecie := "NF"
		ElseIf AllTrim(SL1->L1_ESPECIE) == "NFCF"
			cEspecie := "NFCF"
		//Para identificar NF-e
		Elseif SL1->L1_IMPNF .or. Substr(cChaveNfce,21,2) == "55" //Colocado duas validacoes devido a usuario mudar o L1_IMPNF para .F.
			cEspecie := "SPED"
		ElseIf cTiposDoc <> NIL
			cEspecie := LjNfEspeci(cSerie, cTiposDoc)
		EndIf
	Else
		LjGravaLog( .T., SL1->L1_NUM, '43) cEspecie MVNOTAFIS - ' + MVNOTAFIS, LMALERT)
		cEspecie := MVNOTAFIS
	EndIf
	LjGrvLog(SL1->L1_NUM,"LjGrvSF2 - Especie(NFM,NF,NFCD):",cEspecie)
EndIf
REPLACE	SF2->F2_ESPECIE	WITH cEspecie

//Emissao via Totvs PDV NF-e
if cEspecie == "SPED" .and. IsBlind() 
	SF2->F2_FIMP := "S"
endif

LjGravaLog( .T., SL1->L1_NUM, '44) cEspecie - ' + cEspecie, LMALERT)
//Parametro MV_HORARMT habilitado pega a hora do smartclient, do servidor ou do Estado da Filial
//Quando cupom fiscal, deve considerar a hora da venda registrada no ECF, GrvBatch pode estar localizado em outro estado e gerar divergencia de hora

//Alteracao para Totvs PDV com NFe manter a hora
If RTrim(cEspecie) $ "CF|ECF|NFCE|SATCE|SPED" 
	
	cHora :=  SL1->L1_HORA
	SF2->F2_HORA :=  SubStr(cHora,1,5)
Else
	
	If cHoraRMT == "1" .AND. lScreen
		cHora :=  SubStr(GetRmtTime(),1,5)
	ElseIf cHoraRMT == "3" .AND. lScreen
		If cPaisLoc == "BRA"
			aArea2	:= GetArea()
			dbSelectArea("SM0")
			aAreaSM0	:= GetArea()
			dbSetOrder(1)
			If dbSeek(cEmpAnt+cFilAnt)
				aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
			EndIf
			RestArea(aAreaSM0)
			RestArea(aArea2)
	
			cHora := aTimeUf[2]
		Else
			cHora := GetRmtTime()
		EndIf
	
	Else // 2- Default (data do servidor)
		cHora := Time()



	EndIf
	
	SF2->F2_HORA :=  SubStr(cHora,1,5)
	RecLock("SL1", .F.)
	SL1->L1_HORA := cHora
	SL1->(MsUnLock())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos Originarios do SL1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REPLACE SF2->F2_SERIE	WITH cSerieNF
REPLACE SF2->F2_PDV		WITH SL1->L1_PDV
If SL1->L1_TIPO $ "D|B"
	//Verifica se posicionado no cliente da venda
	If (SL1->L1_ClIENTE + SL1->L1_LOJA) <> (SA1->A1_COD + SA1->A1_LOJA) 
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(dbSeek(xFilial("SA1") + SL1->L1_ClIENTE + SL1->L1_LOJA))	  
	EndIf
	
	//Ajustei o Seek, estava fazendo Seek do CNPJ com base no código do cliente ? só funcionou se tinha código igual CNPJ	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))//A2_FILIAL+A2_CGC
	IF(SA2->(DbSeek(xFilial("SA2")+PADR(SA1->A1_CGC,TamSx3("A2_CGC")[1]))))
		REPLACE SF2->F2_CLIENTE	WITH SA2->A2_COD
		REPLACE SF2->F2_LOJA	WITH SA2->A2_LOJA	
		REPLACE SF2->F2_CLIENT	WITH SA2->A2_COD
		REPLACE SF2->F2_LOJENT	WITH SA2->A2_LOJA
	Endif
Else
	REPLACE SF2->F2_CLIENTE	WITH SL1->L1_CLIENTE
	REPLACE SF2->F2_LOJA	WITH SL1->L1_LOJA
	// Grava cliente entrega
	If MaFisFound("NF") .AND. !Empty( MaFisRet(,"NF_CLIENT") )
		REPLACE SF2->F2_CLIENT	WITH MaFisRet(,"NF_CLIENT")
		REPLACE SF2->F2_LOJENT	WITH MaFisRet(,"NF_LOJENT")
	EndIf
Endif

//Tratamento para proteger a transmissão da NFSE quando condição de pagamento negociada(CN)
If Alltrim(SL1->L1_CONDPG) == "CN" .AND. Alltrim(cEspecie) == "RPS"
	REPLACE SF2->F2_COND WITH SuperGetMV("MV_CONDPAD")
Else
	REPLACE SF2->F2_COND WITH SL1->L1_CONDPG
EndIF
REPLACE SF2->F2_DUPL	WITH cFirst
REPLACE SF2->F2_EMISSAO	WITH SL1->L1_EMISNF
REPLACE SF2->F2_VEND1	WITH SL1->L1_VEND

//Se os pesos tiverem sido informados no frete, mantem a informacao digitada
If SL1->L1_PLIQUI > 0 .And. SL1->L1_PBRUTO > 0
	SF2->F2_PLIQUI	:= SL1->L1_PLIQUI
	SF2->F2_PBRUTO	:= SL1->L1_PBRUTO
Else
	// Chama funcao para calcular os pesos
	LjRetPeso(@nPesLiq, @nPesBrut)
	SF2->F2_PLIQUI	:= nPesLiq
	SF2->F2_PBRUTO	:= nPesBrut
Endif

REPLACE SF2->F2_TRANSP	WITH SL1->L1_TRANSP

If SL1->(FieldPos("L1_VEICUL1" )) > 0 .And. !Empty(SL1->L1_VEICUL1) .And. SF2->(FieldPos("F2_VEICUL1" )) > 0
	REPLACE SF2->F2_VEICUL1	WITH SL1->L1_VEICUL1
EndIf

If SL1->(ColumnPos("L1_VEND1" )) > 0 .And. !Empty(SL1->L1_VEND1)
	REPLACE SF2->F2_VEND1	WITH SL1->L1_VEND1
EndIf
If SL1->(ColumnPos("L1_VEND2" )) > 0
	REPLACE SF2->F2_VEND2	WITH SL1->L1_VEND2
EndIf
If SL1->(ColumnPos("L1_VEND3" )) > 0
	REPLACE SF2->F2_VEND3	WITH SL1->L1_VEND3
EndIf
If SL1->(ColumnPos("L1_VEND4" )) > 0
	REPLACE SF2->F2_VEND4	WITH SL1->L1_VEND4
EndIf
If SL1->(ColumnPos("L1_VEND5" )) > 0
	REPLACE SF2->F2_VEND5	WITH SL1->L1_VEND5
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos Originarios do SA1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REPLACE SF2->F2_EST WITH IIf(MaFisFound("NF"), MaFisRet(,"NF_UFDEST"),SA1->A1_EST)

If !Empty(SL1->L1_TIPOCLI)
	REPLACE SF2->F2_TIPOCLI	WITH SL1->L1_TIPOCLI
Else
	REPLACE SF2->F2_TIPOCLI	WITH SA1->A1_TIPO
EndIf

If SF2->(ColumnPos("F2_RECISS")) > 0
	REPLACE SF2->F2_RECISS	WITH cRecIss
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos Originarios da MaFisRet ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"

	If lIntegDef //Integracao mantem valores de impostos
		//Usa o MaFisLoad para que os valores nao sejam recalculados
		MaFisLoad("NF_VALICM", SL1->L1_VALICM)
		MaFisLoad("NF_VALISS", SL1->L1_VALISS)
		MaFisLoad("NF_VALCSL", SL1->L1_VALCSLL)	
		MaFisLoad("NF_VALIRR", SL1->L1_VALIRRF)
		MaFisLoad("NF_VALIPI", SL1->L1_VALIPI)
		MaFisLoad("NF_TOTAL", SL1->L1_VALBRUT)

		If SL1->(ColumnPos("L1_BASEIPI")) > 0
			MaFisLoad("NF_BASEIPI", SL1->L1_BASEIPI)
		EndIf
		MaFisLoad("NF_VALSOL", SL1->L1_ICMSRET)
		MaFisLoad("NF_BASESOL", SL1->L1_BRICMS)

        If SL1->(ColumnPos("L1_VALFECP") > 0 .AND. ColumnPos("L1_BASFECP") > 0)
            MaFisLoad("NF_BASFECP", SL1->L1_BASFECP )
            MaFisLoad("NF_VALFECP", SL1->L1_VALFECP )
        EndIf    

		If SL1->L1_TIPO $ "D|B"
			MaFisLoad("NF_CLIENT", SA2->A2_COD)
			MaFisLoad("NF_LOJENT", SA2->A2_LOJA)
		EndIf
	Else
		REPLACE SF2->F2_VALICM	WITH MaFisRet(Nil, "NF_VALICM")
		REPLACE SF2->F2_VALISS	WITH MaFisRet(Nil, "NF_VALISS")
		REPLACE SF2->F2_VALPIS 	WITH MaFisRet(Nil, "NF_VALPIS")		//Valor do PIS				
		REPLACE SF2->F2_VALCOFI	WITH MaFisRet(Nil, "NF_VALCOF")		//Valor do COFINS
		REPLACE SF2->F2_VALCSLL	WITH MaFisRet(Nil, "NF_VALCSL")		//Valor do CSLL
		REPLACE SF2->F2_BASCSLL	WITH MaFisRet(Nil, "NF_BASECSL")	//Base de calculo do CSLL
		REPLACE SF2->F2_BASEISS	WITH MaFisRet(Nil, "NF_BASEISS")
		REPLACE SF2->F2_BASPIS 	WITH MaFisRet(Nil, "NF_BASEPIS")	//Base de calculo do PIS		
		REPLACE SF2->F2_BASCOFI	WITH MaFisRet(Nil, "NF_BASECOF")	//Base de calculo do COFINS
		REPLACE SF2->F2_VALIRRF	WITH MaFisRet(Nil, "NF_VALIRR") 	//Valor do IRRF
		REPLACE SF2->F2_BASEIRR	WITH MaFisRet(Nil, "NF_BASEIRR") 	//Base de calculo do IRRF
	EndIf
	
	REPLACE SF2->F2_ICMSRET	WITH MaFisRet(Nil, "NF_VALSOL")
	REPLACE SF2->F2_BRICMS	WITH MaFisRet(Nil, "NF_BASESOL")		
	REPLACE SF2->F2_VALINSS	WITH MaFisRet(Nil, "NF_VALINS")		//Valor do INSS		
	REPLACE SF2->F2_BASEINS	WITH MaFisRet(Nil, "NF_BASEINS")	//Base de calculo do INSS	
	REPLACE SF2->F2_FRETE 	With MaFisRet(Nil, "NF_FRETE")
	REPLACE SF2->F2_SEGURO 	With MaFisRet(Nil, "NF_SEGURO")
	REPLACE SF2->F2_DESPESA With MaFisRet(Nil, "NF_DESPESA")
	REPLACE SF2->F2_VALIPI  WITH MaFisRet(Nil, "NF_VALIPI")
    REPLACE SF2->F2_BASEIPI WITH MaFisRet(Nil, "NF_BASEIPI")

	If nBaseRed > 0
   		REPLACE SF2->F2_BASEICM	WITH nBaseRed
	Elseif !lFtvdVer12
   		REPLACE SF2->F2_BASEICM	WITH MaFisRet(Nil, "NF_BASEICM")
	ElseIf lFtvdVer12
   		REPLACE SF2->F2_BASEICM	WITH MaFisRet(Nil, "NF_BASEICM")
		  // Tratamento para gravação do cabeçalho imp. variáveis a nível Brasil
		If lCalcImpV
			For nW:= 1 to 9
				cBasImp:= "F2_BASIMP"+Str(nW,1)
				cValImp:= "F2_VALIMP"+Str(nW,1)
				If nW <= 6
					REPLACE &cBasImp	WITH MaFisRet(Nil,"NF_BASEIV"+Str(nW,1))
					REPLACE &cValImp	WITH MaFisRet(Nil,"NF_VALIV"+Str(nW,1))
				Else
					If FieldPos(cBasImp)>0 .AND. FieldPos(cAlqImp)>0 .AND. FieldPos(cValImp)>0
						REPLACE &cBasImp	WITH MaFisRet(Nil,"NF_BASEIV"+Str(nW,1))
						REPLACE &cValImp	WITH MaFisRet(Nil,"NF_VALIV"+Str(nW,1))
					EndIf
				EndIf
			Next nW
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ICMS Diferido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF2->(ColumnPos("F2_ICMSDIF")) > 0
		REPLACE SF2->F2_ICMSDIF	WITH MaFisRet(Nil, "NF_ICMSDIF")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula impostos de PIS e Cofins somente se for Brasil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lIntegDef //Integracao mantem os impostos enviados
		REPLACE SF2->F2_BASIMP5 WITH MaFisRet(Nil, "NF_BASECF2")
		REPLACE SF2->F2_BASIMP6 WITH MaFisRet(Nil, "NF_BASEPS2")
		REPLACE SF2->F2_VALIMP5 WITH MaFisRet(Nil, "NF_VALCF2")
		REPLACE SF2->F2_VALIMP6 WITH MaFisRet(Nil, "NF_VALPS2")
	EndIf

	REPLACE SF2->F2_CONTSOC WITH MaFisRet(Nil, "NF_FUNRURAL") 	//Valor do FUNRURAL
	REPLACE SF2->F2_BASEFUN	WITH MaFisRet(Nil, "NF_BASEFUN") 	//Base de Calculo do FUNRURAL
	REPLACE SF2->F2_VLSENAR	WITH MaFisRet(Nil, "NF_VLSENAR") 	//Valor do SENAR
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de controle de faturas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContrFol

	aDados := Array(6)

	aDados[1] := SF2->F2_SERIE
	aDados[2] := SF2->F2_ESPECIE
	aDados[3] := SF2->F2_DOC

	If Empty(cCGCCli)
		If Alltrim(aDados[2]) $ "NDI/NCP"
			aDados[4] := GetAdvFVal("SA2","A2_CGC",xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,1,"")
		Else
			aDados[4] := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,1,"")
		Endif
	Else
		aDados[4] := cCGCCli
	EndIf

	aDados[5] := DtoS(SF2->F2_EMISSAO)

	If nMoedaCor <> 1 .AND. cPaisLoc == "BOL"
		aDados[6] := Round(xMoeda(SL1->L1_VALBRUT,nMoedaCor,1,SF2->F2_EMISSAO),0)
	Else
		aDados[6] := Round(SL1->L1_VALBRUT,0)
	EndIf

	aRetCF := RetCF(aDados,cFilAnt)

	REPLACE SF2->F2_NUMAUT	WITH aRetCF[1]	//Numero de Autorizacao

	If lNfManual
		If SF2->(FieldPos("F2_MANUAL")) > 0
			REPLACE SF2->F2_MANUAL WITH "1"
		EndIf
		REPLACE SF2->F2_CODCTR	WITH  Replicate("0", nTamCodCTR )		//Codigo de Controle
	Else
		If SF2->(FieldPos("F2_MANUAL")) > 0
			REPLACE SF2->F2_MANUAL WITH "2"
		EndIf
		REPLACE SF2->F2_CODCTR	WITH aRetCF[2]	//Codigo de Controle
	EndIf

	REPLACE SF2->F2_LIMEMIS	WITH aRetCF[3]	//Data Limite de Emisao

Endif

If lScreen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual a Codição de Pagamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->LQ_CONDPG)
		cCondPgto := "CN"
	Else
		cCondPgto := M->LQ_CONDPG
	EndIf
Else
	If Empty(SL1->L1_CONDPG)
		cCondPgto := "CN"
	Else
		cCondPgto := SL1->L1_CONDPG
	EndIf
EndIf

lCondNeg := (Trim( cCondPgto ) == "CN")				// Verifica se eh condicao negociada

If !lCondNeg
	dbSelectArea("SE4")
	SE4->(DbSetOrder( 1 ))
	If SE4->(MsSeek( xFilial( "SE4" ) + cCondPgto ))
		nPerDescFin	  := SE4->E4_DESCFIN						//Valor do desconto financeiro
		nPerAcrsFin   := SE4->E4_ACRSFIN                        //Valor do acrescimo financeiro
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trata o desconto financeiro para subtrair dos valores bruto³
//³e faturado (F2_VALBRUT e F2_VALFAT)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cPaisLoc == "BRA"
	If aTotais[__DESCONT] > 0 .AND. aTotais[__VALACRS] > 0
		REPLACE SF2->F2_DESCONT	WITH aTotais[__DESCONT]
	Else
		REPLACE SF2->F2_DESCONT	WITH Max(MafisRet(Nil, "NF_DESCONTO"), 0)
	EndIf
	
	//Verifica o recolhimento de ISS - abatimento
	If ExistFunc("Lj7RecIss") .And. Lj7RecIss() 
		nValFat := MafisRet(Nil, "NF_TOTAL") - MafisRet(Nil, "NF_VALISS")
	Else
		nValFat := MafisRet(Nil, "NF_TOTAL")
	EndIf	
	
    //Integracao mantem valores da venda
	If lIntegDef
		REPLACE SF2->F2_VALBRUT	WITH SL1->L1_VALBRUT
		REPLACE SF2->F2_VALFAT	WITH SL1->L1_VLRLIQ

	ElseIf MaFisRet(,"NF_SUFRAMA")
		REPLACE SF2->F2_VALMERC	WITH A410Arred( aTotais[__VALMERC] - MafisRet(Nil, "NF_DESCZF"), "F2_VALMERC" )
		REPLACE SF2->F2_VALBRUT	WITH MafisRet(Nil, "NF_TOTAL")
   		REPLACE SF2->F2_VALFAT	WITH nValFat
        REPLACE SF2->F2_DESCZFR WITH MafisRet(Nil, "NF_DESCZF")

    Else
    	REPLACE SF2->F2_VALMERC	WITH A410Arred( aTotais[__VALMERC], "F2_VALMERC" )
		REPLACE SF2->F2_VALBRUT	WITH MafisRet(Nil, "NF_TOTAL")
		REPLACE SF2->F2_VALFAT	WITH nValFat

	EndIf

	nBaseDup += MaFisRet(Nil, "NF_BASEDUP")

	If	lMenNota .AND.  SL1->(ColumnPos("L1_MENNOTA")) > 0 .AND. SF2->(FieldPos("F2_MENNOTA")) > 0
		REPLACE SF2->F2_MENNOTA	WITH SL1->L1_MENNOTA
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Localizacoes                         ³
	//³Obter o total de acrescimos da venda ja registrados ³
	//³na tabela SD2 no campo D2_VALACRS.                  ³
	//³                                                    ³
	//³Paises:CHILE, COLOMBIA - F1CHI                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLocR5
		nVlrAcrsFin	:= LjVlAcrFin()
		If nPerDescFin > 0
			nVlrDescFin := A410Arred((MafisRet(Nil, "NF_TOTAL")* nPerDescFin)/100,"F2_VALACRS",nMoedaCor)
		EndIf
	EndIf

	If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
		REPLACE SF2->F2_DESCONT	WITH xMoeda(nTotDesc,nMoedaCor,1,SF2->F2_EMISSAO)
	Else
		REPLACE SF2->F2_DESCONT	WITH nTotDesc
	EndIf
	REPLACE SF2->F2_VALMERC	WITH nTotLiq


	If lLocR5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Localizacoes   ³
		//³Subtrair desconto financeiro  ³
		//³Paises:CHILE, COLOMBIA - F1CHI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		REPLACE SF2->F2_VALBRUT	WITH nTotLiq + nTotImp + nVlrAcrsFin - nVlrDescFin
		REPLACE SF2->F2_VALFAT	WITH nTotLiq + nTotImp + nVlrAcrsFin - nVlrDescFin
	Else
		If cPaisLoc == "ARG"
			REPLACE SF2->F2_VALBRUT	WITH MafisRet(Nil, "NF_TOTAL")
			REPLACE SF2->F2_VALFAT	WITH MafisRet(Nil, "NF_TOTAL")
		Else
			REPLACE SF2->F2_VALBRUT	WITH nTotLiq + nTotImp + nVlrAcrsFin
			REPLACE SF2->F2_VALFAT	WITH nTotLiq + nTotImp + nVlrAcrsFin
		EndIf
	Endif
	nBaseDup += nTotLiq + nTotImp

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao dos Impostos - Localizacoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	REPLACE SF2->F2_TIPODOC	WITH "01"
	If cPaisLoc == "BOL"
		REPLACE SF2->F2_MOEDA	WITH 1
		REPLACE SF2->F2_TXMOEDA	WITH 1
	Else
		REPLACE SF2->F2_MOEDA	WITH SL1->L1_MOEDA
		REPLACE SF2->F2_TXMOEDA	WITH SL1->L1_TXMOEDA
	EndIf
	If !Empty(aImpsSF2)
		AEval(aImpsSF2, {|x,y| SF2->(FieldPut(FieldPos(aImpsSF2[y][01]),aImpsSF2[y][02]))})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para Legislação de Carga Tributária - Lei nº 12.741/2012 (Lei da Transparência)        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntegDef //Integracao Mensagem Unica
	//Lei de Transparencia 
	SF2->F2_TOTFED := SL1->L1_TOTFED
	SF2->F2_TOTEST := SL1->L1_TOTEST
	SF2->F2_TOTMUN := SL1->L1_TOTMUN
	SF2->F2_TOTIMP := SL1->L1_TOTFED + SL1->L1_TOTEST + SL1->L1_TOTMUN 
	SF2->F2_LTRAN	 := SL1->L1_LTRAN
	
	SF2->F2_VALMERC	:= SL1->L1_VALMERC
ElseIf cPaisLoc == "BRA" .And. lLeiTran .And. Type("nTotCargT") == "N"
	SF2->F2_TOTIMP := nTotCargT

	// Nova lei dos Impostos
	If lCpoImpEnt
		SF2->F2_TOTFED	:= nTotCarFed
		SF2->F2_TOTEST	:= nTotCarEst
		SF2->F2_TOTMUN	:= nTotCarMun
	EndIf

	nTotCargT		 := 0 // zera para a proxima nota, que poder ser servico, se estiver habilitado RPS
	nTotCarFed := 0
	nTotCarEst := 0
	nTotCarMun := 0

	If nModulo == 5 .And. FindFunction("AlqLei2741")
		SF2->F2_TIPIMP := cMvFisCTrb
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parametro MV_LJPREF contem uma regra baseadano SF2, entao precisa ser o ultimo a ser preenchido. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPrefixo := LjGetPrefix(SF2->F2_SERIE)

If Empty(cPrefixo)
	cPrefixo := &(SuperGetMV("MV_LJPREF"))
EndIf

REPLACE	SF2->F2_PREFIXO	WITH cPrefixo

If lIntSynt //Mantem os valores gerados pelo Bridge POS

	REPLACE SF2->F2_VALBRUT	WITH SL1->L1_VALBRUT
	REPLACE SF2->F2_VALFAT	WITH SL1->L1_VLRTOT
	REPLACE SF2->F2_VALMERC	WITH SL1->L1_VALMERC

EndIf


If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao for a ultima nota (no caso do orcamento gerar varias notas) pega o numero da proxima e grava no F2_NEXTDOC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao grava o F2_NEXTDOC quando o MV_TPNRNSF for igual a "3" porque o  ³
	//³ numero da nota so' existe no meio da transacao, isto e', so' qdo o   ³
	//³ proximo SF2 for gravado.                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lFim .AND. (cMV_TPNRNFS <> "3" .Or. lNxtNFServ)

		If lRetIncSX5 .And. !lNxtNFServ
		   lSelNota  := .T.
		Else
			If lNxtNFServ //Proxima NF sera de "servico"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca a Serie e Numero da prox. Nota de Servico (RPS) a ser gerada. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aNotaRPS := LjSerNfRPS(lVendDireta)
				lSelNota := aNotaRPS[1]
				If lSelNota
					cNumNextNF 	:= aNotaRPS[2][1]
					cSerieNF 	:= aNotaRPS[2][2]
					cNumNota 	:= cNumNextNF
				EndIf
			Else
			   lSelNota  := ljNota(SL1->L1_SERIE,@cNumNextNF,lRetIncSx5)
			   cNumNota  := cNumNextNF
			EndIF
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campo que recebe numero da nota vinculada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIsNextNF
			If Empty(cNumNextNF)
				nTamF2_DOC := TamSx3("F2_DOC")[1] 	// Tamanho do campo F2_DOC
				cNumNextNF := PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , nTamF2_DOC )
			EndIf
			REPLACE SF2->F2_NEXTDOC WITH cNumNextNF
		EndIf

		If lSelNota
			//-----------------
			//|Gera SF3 OnLine|
			//-----------------
			If lFisLivro
				If lIntegDef //Se integracao, armazena as informacoes de impostos recebidas no xml
					SF4->(MaFisWrite(2, "SF2")) 										
				EndIf
			
				If lUseSat .And. !lNFServ
					MaFisAtuSF3(1,"S",SF2->(Recno()),"SF2",NIL,NIL,cNomeProg,,,SL1->L1_SERSAT)
				Else
					MaFisAtuSF3(1,"S",SF2->(Recno()),"SF2",NIL,NIL,cNomeProg)
				EndIf
				SFT->(MsUnlock())

				MAFISCDA(,2)  //Gravacao dos lancamentos fiscais
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpa os acumuladores de impostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MaFisFound("NF")
				MaFisEnd()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria novos acumuladores de impostos para a proxima nota ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			MaFisIni(	SL1->L1_CLIENTE	, 	SL1->L1_LOJA					,	"C"	,	"S"	,;
	   					SL1->L1_TIPOCLI	, 	IIF(lIntegDef, aRelImpInt, NIL)	,	NIL	,	.F.	,; 
	   					"SB1"			,	"LJGRVBATCH"			        ,	NIL	,	NIL	,;
	   					NIL				,	NIL								,	NIL	,	NIL	,;
	   					NIL				,	NIL								,	!lImpCupfis )
		   
			LjSatMxFis() //setando SAT na MatxFis
			Exit
		EndIf
	End
EndIf

If cPaisLoc == "ARG" .And. SL1->(ColumnPos("L1_ADIC5")) > 0 .And. SLQ->(ColumnPos("LQ_ADIC5")) > 0
	LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "SL1->L1_ADIC5", SL1->L1_ADIC5 )
	REPLACE SF2->F2_ADIC5	WITH SL1->L1_ADIC5
EndIf

//Registro do número de série do equipamento SAT
If lUseSat .And. !lNFServ
	LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "SL1->L1_SERSAT", SL1->L1_SERSAT )
	REPLACE SF2->F2_SERSAT	WITH SL1->L1_SERSAT
EndIf

SF2->(MsUnlock())

If lIntegDef 
	If lFisLivro
		SF4->(MaFisWrite(2, "SF2"))
	Else
		LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "A integração esta habilitada mas com o parametro MV_LJLVFIS diferente de 2 (Impacto na gravação dos livros fiscais)")
	EndIf			
EndIf

If lPadrao .AND. cPaisLoc $ "MEX|PAR"

	aLancCtb := {{"F2_DTLANC",dDataBase,"SF2",SF2->(Recno()),0,0,0}} //Campo Flag de Contabilizacao a ser atualizado

	nHdlPrv:=HeadProva("","LOJXFUNC",Substr(cUsername,1,6),@cArquivo)

	If  nHdlPrv > 0
		nTotal+=DetProva(nHdlPrv,cPadrao,"LOJXFUNC","")
	EndIf

	If  nTotal > 0
		RodaProva(nHdlPrv,nTotal)
		cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina,,,,aLancCtb)
	EndIf

EndIf

//Integracao hotelaria lancamento PCO para SF2
If lIntegHtl	
	//Inicia PCO
	PcoIniLan(cProcesso)
	
	//Posiciona no cliente
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))

	//Lancamento PCO	
	PCODetLan(cProcesso, cCodItem, "LOJXFUNC")
	
	//Finaliza PCO
	PcoFinLan(cProcesso)
EndIf

LjGrvLog(SL1->L1_NUM,"LjGrvSF2 Fim Gravacao cNumNota:",cNumNota)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjGrvBatch³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava em processo batch o com base no SL1, SL2, SL4.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Front Loja / Siga Loja                                   	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ljGrvBatch( cEmp, cFilTrab , cIntervalo, cMinReproc, cJobNFCe )
Local nHandle						   			   				// Indica se o arquivo foi criado
Local aFiles		:= {}						   				// Arquivos
Local nIntervalo 	:= 0			   			   				// Intervalo para o Loop
Local nTimes	 	:= 0			   							// Numero de loop antes de entrar no while
Local lRetValue  	:= .T.             			   				// Retorno da função
Local aFiliais   	:= {}              			   				// Filiais
Local aBadRecno  	:= {}			   			   				// Recnos
Local cFileName		:= ""			   			   				// Nome do arquivo
Local nCount 		:= 1						   				// Contador
Local cTemp			:= ""			   			   				// Temporario
Local lTemReserva	:= .F.						   				// Verifica se existe algum item com reserva
Local lProcessou	:= .F.			   			   				// Verifica se processou as vendas na Retaguarda.
Local bOldError  								   				// Bloco de tratamento de erro
Local lLJ7051		:= ExistBlock("LJ7051")	   					// Verifica se a funcao LJ7051 esta compilada
Local lExProc 		:= .T.			   			   				// Controla o while do Killapp
Local lMultFil 		:= .F.			   			   				// Verifica se e' passado mais de uma filial no parametro
Local lCriouAmb		:= .F.			   			   				// Verifica se o PREPARE ENVIRONMENT foi executado
Local nSleep		:= 0			   			   				// Utilizado para atribuicao na variavel nIntervalo
Local aAreaSL1		:= {}			   			   				// Guarda a Area do SL1
Local nRecSL1		:= 0			   			   				// Guarda o Recno do SL1
Local lGerInt 		:= .F.             			   				// Verifica se a integracao esta habilitada
Local aRecFail		:= {}			   			   				// Registros que nao conseguiram ser travados
Local oLJCLocker 	:= Nil
Local lLj7064       := ExistBlock("LJ7064") 	   				// Verifica se existe o ponto de entrada LJ7064
Local nOpcProc		:= 0			   			   				// Opcao de processamento
Local lLstPresAt	:= .F.              		   				// Lista de presente ativa?
Local lMvLjGrvBt	:= .F. 						   				// Parametro que define se utilizara o indice "14" para priorizar a integracao dos orcamentos com reserva.
Local lFtvdVer12	:= LjFTVD() 								// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") 		// Nome da Rotina
Local lTPLOtica 	:= .F.
Local lMvLjOffLn 	:= .F.
Local lUsaInd14 	:= .F. 										// Indica se usa o indice 14 da tabela SL1 para priorizar os orcamentos com pedido.
Local cMvLJILJLO 	:= ""
Local cCliPad		:= ""										// Cliente Padrao
Local cLojaPad		:= ""										// Loja Padrao
Local nMinReproc	:= 0										// Utilizado para atribuicao na variavel cMinReproc
Local nMinFalha		:= 0										// Tempo da ultima falha de processamento
Local lReproc		:= .T.										// Sinaliza se deve marcar como registro ja reprocessado, somente quando utiliza cMinReproc
Local lLj7082		:= ExistBlock("LJ7082")						// Indica se o PE LJ7082 esta compilado
Local lRetLj7082	:= .F.										// Retorno do PE LJ7082
Local lTryAgain		:= .F.										// Criada a variavel para tentar novamente caso o cliente esteja alocado ou nao exista
Local lLj7095		:= ExistBlock("LJ7095")						// Utilizado para liberacao da gravacao da venda com SA1 lock(para evitar erro de lock na MatxAtu(A040DupRec), deve trabalhar com o PE: F040TRVSA1)
Local lRetLj7095	:= .F.										// Retorno do PE LJ7082 - Se .T., libera gravacao da venda com registro Lock
Local lRestartGB 	:= .F.										// Variavel de controle para reinicar o ljGrvBatch
Local nPosCanNfc    := 0 
Local cErro         := ""
Local aJobs			:= {}										// vetor com os jobs configurado no appserver.ini
Local nJobNFCe		:= 1										// indica se o job de cancelamento da NFC-e deve ser iniciado, caso ele nao esteja configurado no appserver.ini (espelho da variavel cJobNFCe)
Local lIntegDef		:= .F. 										// Integracao via Mensagem Unica
Local lLj140StIn	:= ExistFunc("Lj140StInD")

Default cIntervalo  := 30000									// Conteudo do terceiro parametro (Parm3 do mp8srv.ini)
Default cMinReproc	:= 1000										// Conteudo do quarto parametro, para tentar processar novamente o registro quando ocorre falha por Lock(SA1)
Default cJobNFCe	:= '1'										// se 1, verifica se o job de cancelamento da NFC-e esta configurado no appserver.ini, se não estiver, o job sera iniciado com os mesmos parametros do LjGrvBatch

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel Private para que caso seja execultada a funcao      ³
//³ via JOB, atribua o valor padrao a nMoedaCor.				 ³
//³ Rotina Utilizada para o Padrao, Lista de Presentes e Localiza³
//³ cao Chile/Colombia.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nMoedaCor 	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento caso o terceiro parametro seja passado ou nao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(cIntervalo) <> "N"
	nSleep := Val(cIntervalo)
Else
	nSleep := cIntervalo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento caso o quarto parametro seja passado ou nao.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(cMinReproc) <> "N"
	nMinReproc := Val(cMinReproc)
Else
	nMinReproc := cMinReproc
Endif
//
// Tratamento para o quinto parametro
//
If ValType(cJobNFCe) <> "N"
	nJobNFCe := Val(cJobNFCe)
Else
	nJobNFCe := cJobNFCe
Endif

While nCount <= Len( cFilTrab )

	cTemp := ""
	While SubStr( cFilTrab, nCount, 1 ) <> "," .AND. nCount <= Len( cFilTrab )
		cTemp += SubStr( cFilTrab, nCount, 1 )
		nCount++
	End
	AADD( aFiliais, { cTemp } )
	nCount++

End

nCount := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o numero de filiais que esta sendo passado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFiliais) > 1
	lMultFil := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel lExProc inicializada como True³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !KillApp() .AND. lExProc
	cFileName := cEmp + aFiliais[ nCount ][1]
	If (!lMultFil .AND. lCriouAmb) .OR. ( nHandle := MSFCreate("LJGR"+cFileName+".WRK") ) >= 0
		If lMultFil .OR. !lCriouAmb
			ConOut("LJGrvBatch: "+STR0075 + cEmp + STR0076 + aFiliais[ nCount ][1])  // "Empresa:" ### " Filial:"
			ConOut("            "+STR0021)  //"Iniciando processo de gravacao batch..."

			RPCSetType(3)  // Nao comer licença

			//-----------------------------------------------------------------
			//|Retirado PREPARE ENVIRONMENT porque em alguns casos trava o JOB|
			//-----------------------------------------------------------------
			RPCSETENV(cEmp, aFiliais[ nCount ][1],,,"LOJ")
			lCriouAmb := .T.
			lIntegDef := FWHasEAI("LOJA701",, .T., .T.)
			LjGrvLog("LJGrvBatch", " Tem integração EAI ativa ?", lIntegDef)

			//Quando executado via Job, verifica se origem Loja
			//Seta nModulo para 12 para garantir execucao via Loja
			If cNomeProg == "LOJA701"
				nModulo := 12
			EndIf

			//-------------------------------------------------
			//|Objeto para envio de mensagem pelo EventViewer |
			//-------------------------------------------------
			If Type("oEvent") <> "O"
				oEvent := LjcEventIntegracao():New()
			EndIf

			//-------------------------------------------------------------------------------------------------------------
			//|Faz a inicializacao de variaveis de PARAMETROS que serao utilizadas no Loop da SL1.                        |
			//|Faz esta inicializacao aqui para executar apenas uma vez, ao inves de executar varias vezes no Loop da SL1.|
			//-------------------------------------------------------------------------------------------------------------
			cCliPad		:= SuperGetMV("MV_CLIPAD")				// Cliente Padrao
			cLojaPad	:= SuperGetMV("MV_LOJAPAD")				// Loja Padrao
			lGerInt 	:= SuperGetMv("MV_LJGRINT",.F.,.F.) 	// Verifica se a integracao esta habilitada
			lLstPresAt	:= SuperGetMV("MV_LJLSPRE",.F.,.F.) .AND. LjUpd78Ok()
			lMvLjGrvBt 	:= SuperGetMv("MV_LJGRVBT",.F.,.F.) 	// Se o parametro for .F. nao utiliza o indice "14" da SL1
			lUsaInd14 	:= lMvLjGrvBt .AND. AllTrim(SL1->(IndexKey(14))) = "L1_FILIAL+L1_SITUA+L1_STATUS" //Indica se usa o indice 14 da tabela SL1 para priorizar os orcamentos com pedido.
			lTPLOtica 	:= HasTemplate("OTC") 					// Verifica se eh Template Otica
			lMvLjOffLn  := SuperGetMv("MV_LJOFFLN", Nil, .F.) 	// Identifica se o ambiente esta operando em offline
			cMvLJILJLO  := SuperGetMV( "MV_LJILJLO",,"2" )    	// Se utilizará sistema de travas nos Jobs FRTA020, LOJA1115 e LJGrvBatch. (0=Não, 1=Sim)
		Endif
		//----------------------------------------------------------------------
		//| Integração Varejo envio do status de Erro do processamento da venda|
		//----------------------------------------------------------------------
		If FWHasEAI("LOJXFUNC",.T.,, .T.) //Integração Varejo envio do status ou Erro do processamento da venda
			LojEaiErr()//Funcão para chamada da Integração do EAI para o envio de processamento com erro.
		EndIf
		//----------------------------------------------------------------------------------//
		//	JOB de Cancelamento da NFC-e													//
		//	Caso o job de cancelamento da NFC-e não esteja configurado no appserver.ini,	//
		//	iniciamos ele em uma nova thread usando os mesmos parametros do LjGrvBatch,		//
		//	com exceção do intervalo de execução, que sera de 3 minutos						//
		//----------------------------------------------------------------------------------//
		
		//Armazeno as Thred's abertas na variavel aJobMonitor (o mesmo listado no Monitor.exe)
		aJobMonitor := GetUserInfoArray()
        nPosCanNfc  := Ascan( aJobMonitor,{|x| AllTrim( Upper(x[5]) ) == "LJCANCNFCE"})
		
		//---------------------------------------------------------------------------------------------------------
		//-Caso o job LJCANCNFCE estiver contido no array aJobMonitor na posição 5 indica que o Job esta iniciado
		//-lIntegDef com .T. = na integração foi habilitado o uso da inutilização
		//						 da NFC-e que não tem configurado o param MV_NFCEURL		
		//---------------------------------------------------------------------------------------------------------
        If nJobNFCe == 1 .AND. nPosCanNfc == 0 .AND. ( !Empty(SuperGetMV("MV_NFCEURL",,"")) .OR. lIntegDef )
			
			aJobs := JobInfo()

			//verificamos se o Job da NFC-e está configurado no appsever.ini
			nPos := aScan( aJobs, {|x| x[1] == "LJCANCNFCE"} )

			If nPos == 0
				Conout( "LjCancNFCe: Iniciando o JOB de Cancelamento da NFC-e" )
				LjGrvLog('GravaBatch', "LjCancNFCe: Iniciando o JOB de Cancelamento da NFC-e")

				StartJob( "LJCANCNFCE", GetEnvServer(), .F., cEmp, cFilTrab, '180' )

				Conout( "LjCancNFCe: JOB de Cancelamento da NFC-e iniciado" )
				LjGrvLog('GravaBatch', "LjCancNFCe: JOB de Cancelamento da NFC-e iniciado")
			EndIf
		Else
            If nPosCanNfc > 0
				LjGrvLog("GravaBatch", "Job LjCancNFCe em execução")
			EndIf
		EndIf

		If lCriouAmb
			If cMvLJILJLO == "1"
				oLJCLocker := LJCGlobalLocker():New()
				If !oLJCLocker:GetLock( "LOJXFUNCILLock" )
					Loop
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todos os arquivos devem ser abertos antes de entrar no Begin Transaction.    ³
		//³Caso exista customizacao, os arquivos devem ser abertos neste PE.            ³
		//³OBS: O ADSSERVER nao permite uso da ChkFile() dentro de um Begin Transaction.³
		//³Em outros ambientes, este problema nao ocorre.                               ³
		//³Retornar um array, por exemplo {"SZ1", "SZ2"}                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFtvdVer12
			If ExistBlock("LJGRVOPEN")
				aFiles := ExecBlock("LJGRVOPEN", .F., .F.)
				RPCOpenTables(aFiles)
			EndIf
		ElseIf lFtvdVer12
			If ExistBlock("FTVDGRVOPEN")
				aFiles := ExecBlock("FTVDGRVOPEN", .F., .F.)
				RPCOpenTables(aFiles)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processar a transferencia de caixa automatica, se necessario. ³
		//³Esse processamento deve chamar independente se existe SL1 para³
		//|explorir ou nao, no entanto foi incluido fora do Loop da SL1. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If GetNewPar("MV_LJTRANS",.F.)
			If FindFunction("LjVerTrans")
				LjVerTrans()
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza o indice L1_FILIAL+L1_SITUA+L1_STATUS para priorizar os orcamentos com pedido. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaInd14
			SL1->(DbSetOrder(14)) //L1_FILIAL+L1_SITUA+L1_STATUS
			If !SL1->(DbSeek(xFilial("SL1")+"RX"+"F"))
				SL1->(DbSetOrder(9))
				SL1->(DbSeek(xFilial("SL1")+"RX"))
			EndIf
		Else
			SL1->(DbSetOrder(9))
			SL1->(DbSeek(xFilial("SL1")+"RX"))
		EndIf
						                         
		While xFilial("SL1") ==  SL1->L1_FILIAL .AND. SL1->L1_SITUA == "RX" 
			
			lGrvErro := .F.

			LjGrvLog('GravaBatch', "ID_INICIO")
	   		LjGrvLog(SL1->L1_NUM,"Inicio do Processamento da Venda")
	   		
			//Varifico se a variavel dDatabase esta atualizada com a data atual
			if dDataBase <> Date()
				LjGrvLog(SL1->L1_NUM,"Diferença entre dDataBase e Date(), o ljGrvBatch sera reiniciado.")
				LjGrvLog(SL1->L1_NUM,"Função Date() = " + dToc(Date()) + " Variavel dDataBase = " + dToc(dDataBase))
				
				//Gravo o arquivo .Fim para iniciar a reinicialização do ljGrvBatch
				LjGrvEnd()
				lRestartGB := .T.
				Exit
			Endif 

	   		If !LjVldBatch(.F.)		//realiza validacoes se a venda pode ser processada. Exemplo: SA1,SL1 alocado
	   		
	   			//Se retornou que a venda nao pode ser processada, verifica se deve pular a venda para tentar novamente em outro momento
	   			//Em geral, a venda nao pode ser processada por Lock de registro, por esse motivo tenta em outro momento
	   			//Caso ja tenha tentado em outro momento algumas vezes, forca o processamento para que siga o fluxo padrao e se o impedimento for mantido, a venda ficara com ER
	   	 		If LjTryAgain(@aRecFail,nMinReproc)
	   				LjGrvLog(SL1->L1_NUM,"Venda nao sera processada nesse momento")
	   				LjGrvLog('GravaBatch', "ID_ALERT")
	   				SL1->( DbSkip() )
	   				Loop
	   			EndIf 			
	   						
			EndIf
			
			//Valida consistencia dos dados do orçamento
			LjVldBatch(.T.)
                                      
			If ( nPos := ASCAN( aBadRecno, SL1->( Recno() ) ) ) > 0
				While SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_SITUA == "RX" .AND. ;
					( ASCAN( aBadRecno, SL1->( Recno() ) ) > 0 )
					SL1->( DbSkip() )
				End
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa o PE, que verifica se a venda sera processada ou nao pelo LjGrvBatch.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLj7082
				lRetLj7082 := ExecBlock("LJ7082",.F.,.F.)
				If !lRetLj7082
					SL1->( DbSkip() )
					Loop
				EndIf
			EndIf

			// Protecao para nao permitir venda que nao tenha numeracao
			If Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_DOCPED) .And. Empty(SL1->L1_DOCRPS)
				ConOut(Chr(13)+Chr(10)+"LJGrvBatch: "+TIME()+" "+STR0079+aFiliais[nCount][1]+ " ORC:"+SL1->L1_NUM +" Com o L1_DOC, DOCPED e DOCRPS em branco")
				LjGrvLog(SL1->L1_NUM,Chr(13)+Chr(10)+"LJGrvBatch: "+TIME()+" "+STR0079+aFiliais[nCount][1]+ " ORC:"+SL1->L1_NUM +" Com o L1_DOC, DOCPED e DOCRPS em branco" )
				LjGravaErr("L1_DOC, DOCPED e DOCRPS em branco")
				SL1->( DbSkip() )
				Loop
			EndIf

			/* Verifica se o cliente esta alocado para outro usuario , caso esteja coloca
			 esse registro na fila novamente,apos cinco tentativas grava o mesmo como ER */
			lTryAgain := .F.
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
				If AllTrim(cCliPad+cLojaPad) <> AllTrim(SA1->A1_COD+SA1->A1_LOJA)
					If SA1->(Rlock())		// Funcao que tenta alocar sem chamar tela
						SA1->(MsUnlock())
					Else
						lTryAgain := .T.  	// Cliente alocado por outro usuario
					EndIf
				EndIf
			Else
				lTryAgain := .T. 			// Cliente ainda nao existe na base
			EndIf

			// Tratamento para pular esse registro e ir para o proximo pelo menos 5 vezes
			If lTryAgain
				nPos := aScan( aRecFail,{|x| x[1] ==  SL1->(Recno())})
				If nPos == 0
					aAdd(aRecFail,{ SL1->(Recno()) , 1, TIME() } )
				Else
					Conout(Chr(13) + Chr(10)+"LJGrvBatch: " + TIME() + " " + STR0079 + aFiliais[ nCount ][1] + "."+STR0146+; // "Filial " #"Registro alocado,Cliente:"
										SL1->L1_CLIENTE + STR0147 + SL1->L1_LOJA ) // " Loja:"#"

					If aRecFail[nPos][2] > 5
						//PE: Liberacao da gravacao da venda com SA1 lock(para evitar erro de lock na MatxAtu(A040DupRec), deve trabalhar com o PE: F040TRVSA1) - Nao foi realizado bloqueio se o cliente existe na base, documentacao do PE possui esse alerta
						If lLj7095
							LjGrvLog( NIL, "Antes da execução do PE LJ7095")
							lRetLj7095 := ExecBlock("LJ7095",.F.,.F.)
							LjGrvLog( NIL, "Depois da execução do PE LJ7095",lRetLj7095)
							If lRetLj7095
								ConOut( Chr(13) + Chr(10)+"LJGrvBatch: " + TIME() + " " + STR0079 + aFiliais[ nCount ][1] + "."+STR0146+;		// "Filial " #"Registro alocado ou inexistente,Cliente:"
										SL1->L1_CLIENTE+ STR0147 +SL1->L1_LOJA + STR0179) // #" Loja:"# " a gravacao da venda foi liberada via PELJ7095"
								lTryAgain := .F.
							EndIf
						EndIf

						If lTryAgain
							LjGravaErr("LJGrvBatch: " + TIME() + " " + STR0079 + aFiliais[ nCount ][1] + "."+STR0146+;		// "Filial " #"Registro alocado,Cliente:"
														SL1->L1_CLIENTE+ STR0147 +SL1->L1_LOJA + STR0148)
							ConOut( Chr(13) + Chr(10)+"LJGrvBatch: " + TIME() + " " + STR0079 + aFiliais[ nCount ][1] + ". ORC:"+SL1->L1_NUM+" "+STR0146+;		// "Filial " #"Registro alocado ou inexistente,Cliente:"
									SL1->L1_CLIENTE+ STR0147 +SL1->L1_LOJA + STR0148) // #" Loja:"# " a venda sera gravada como 'ER'."
						EndIf
					Else
						//Verifica se ultima validacao eh inferior ao tempo de reprocessamento
						If nMinReproc > 0
							nMinFalha 	:= Val(SubStr( ELAPTIME( aRecFail[nPos][3], TIME() ),4,2))
							lReproc 	:= IIF(nMinFalha < nMinReproc,.F.,.T.)
						Else
							lReproc := .T.
						EndIf

						If lReproc
							aRecFail[nPos][2]++
							aRecFail[nPos][3] := TIME() //Atualiza Ult verificacao
							Conout(Chr(13) + Chr(10)+"LJGrvBatch: " + TIME() + STR0079 + aFiliais[ nCount ][1] + "."+STR0146+; // "Filial " #"Registro alocado,Cliente:"
									SL1->L1_CLIENTE + STR0147 + SL1->L1_LOJA + STR0149) // " Loja:"#" tentara depois processar novamente."
						EndIf
					EndIf
				EndIf

				//Quando libera gravacao via PE LJ7095, nao deve ir para o próxim
				If lTryAgain
					SL1->(DbSkip())
					Loop
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Protejo situação de todos os orcamentos "RX" estarem em aBadRecno, neste    ³
			//³ caso não devo processar o proximo (que eh eof), mas sim abandonar o Loop    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->(Eof()) .OR. SL1->L1_SITUA <> 'RX'
				Exit
			EndIf

			nOpcProc := 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento de lista de presentes  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLstPresAt
				nOpcProc := Lj843GrvMv(SL1->L1_NUM)
				//Caso a rotina tenha identificado que existem itens de entrega, alterar a variavel identificadora de reserva
				If nOpcProc == 1
					lTemReserva := .T.
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se os itens foram gravados corretamente³
			//³Não grava como reserva, quando Template Otica   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpcProc == 0
				lTemReserva := .F.
				SL2->( DbSetOrder( 1 ) )
				If SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) ) .AND. !lTPLOtica
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe item com Reserva na venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM
                    	
                        //Com reserva e diferente de 2=Retira ou 5=Entrega c/ Pedido s/ Reserva
						If ( !Empty(SL2->L2_RESERVA) .And. SL2->L2_ENTREGA <> "2" ) .Or. SL2->L2_ENTREGA == "5"
							lTemReserva := IIF(SL2->L2_ENTREGA == "5", .F., .T.)
							nOpcProc    := 1    //LJ7PEDIDO
							Exit
						Endif

						SL2->(DbSkip())
					EndDo
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando orçamento(filho) possui outro orçamento com reserva,     ³
			//³Limpa L1_Status para salvar como venda e não gerar nova reserva.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTemReserva .AND. !Empty(SL1->L1_ORCRES)
				lTemReserva := .F.
				If nOpcProc == 1
					nOpcProc := 2
				Endif
				RecLock("SL1", .F.)
				REPLACE SL1->L1_STATUS WITH ""
				MsUnlock()
			EndIf

			cEstacao  := SL1->L1_ESTACAO
			aAreaSL1  := SL1->(GetArea())
			nRecSL1	  := SL1->(Recno())

			//Caso nao seja processamento de pedido (entrega) e lista de presentes do tipo credito, processar o LjGrvTudo
			If nOpcProc == 0
				nOpcProc := 2
			Endif
			
			Do Case

				//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
				//³LJ7PEDIDO  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
				Case nOpcProc == 1
                    Conout("LJGrvBatch: nOpcProc = " + cValToChar(nOpcProc) + " LJ7Pedido")
					Begin Transaction
						bOldError := ErrorBlock( {|x| LjVerPedErro(x,lProcessou,aFiliais[nCount][1],nRecSL1) } ) // muda code-block de erro
						Begin Sequence
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Transforma o orcamento para pedido   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lProcessou := LJ7Pedido(	{} , 2, NIL, .F.,;
														{} , .T. )

							LjGrvLog(ProcName(0),"Saiu de L7Pedido - Está em transação ? " + IIf(InTransaction(), "SIM", "NÃO"), lProcessou)

							If !lProcessou
                                cErro := STR0137 + "(LJ7Pedido)"    //"Problemas na geração do Pedido."

                                //Força erro, para dar rollback na transação
                                UserException(cErro)
                                LjGravaErr(cErro)
							EndIf
						End Sequence
						ErrorBlock( bOldError )
					End Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
				//³LJGRVTUDO  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
				Case nOpcProc == 2
                    Conout("LJGrvBatch: nOpcProc = " + cValToChar(nOpcProc) + " LjGrvTudo")
					lProcessou := LjGrvTudo(.F.)
					LjGrvLog(ProcName(0),"Saiu de LjGrvTudo - Está em transação ? " + IIf(InTransaction(), "SIM", "NÃO"), lProcessou)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³LJGRVFIN - LISTA DE PRESENTES EXCLUSIVA DE CREDITO  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case nOpcProc == 3
					//Como o SL1 esta posicionado, basta chamar a funcao de gravacao
                    Conout("LJGrvBatch: nOpcProc = " + cValToChar(nOpcProc) + " LjGrvFin")
					lProcessou := LjGrvFin(.F./*Interface*/,.T./*Gera fin.*/,/*nNccUsada*/,/*aNccItens*/,/*nNccGerada*/,/*aVendedor*/,/*aReceb*/,/*aRecSE1*/,;
						/*nValPIS*/,/*nValCSLL*/,/*Valor COFIN*/,/*nBaseDup*/,/*aImpCheque*/,/*nMoedaCor*/,/*lOriFun*/,,.T.,Nil,/*Lista presente de credito*/)
					LjGrvLog(ProcName(0),"Saiu de LjGrvFin - Está em transação ? " + IIf(InTransaction(), "SIM", "NÃO"), lProcessou)

					If lProcessou
						//Alterar o L1_SITUA para OK e Limpa L1_STATUS para salvar como venda e não gerar nova reserva
						RecLock("SL1",.F.)
						SL1->L1_SITUA := "OK"							
						SL1->L1_STATUS := ""
						//Para ficar com o status correto, pois senao ficava em aberto "VERDE"
						SL1->L1_RESERVA := "S"
						SL1->L1_TIPO := "P"
						If SL1->( ColumnPos( "L1_SUBSERI") ) > 0
							SL1->L1_SUBSERI := SL1->L1_SERPED
						EndIf
						SL1->(MsUnlock())
						
						IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
					Endif

			EndCase
			RestArea(aAreaSL1)

			If lProcessou
				If lMvLjOffLn
					Lj7AtuInte(Nil, SL1->L1_NUM, SL1->L1_FILIAL, .T.)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ambiente for do tipo SIGAPAF e orcamento          ³
				//³veio do SC5, entao atualiza campos do pedido de venda³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SL2->(ColumnPos("L2_PEDSC5")) > 0 .And. SL2->(ColumnPos("L2_ITESC6")) > 0 .And. SL2->(ColumnPos("L2_SEQUEN")) > 0
					Mt461PedUp(SL1->L1_NUM)
				Endif

				Lj7PesqAltMot( SL1->L1_SERIE, SL1->L1_DOC , SL1->L1_NUM ) //( cSerie , cDoc , cNumOrc ) - Pesquisa se existe algum motivo de desconto cadastrado para a venda

				If lGerInt .And. !lTemReserva
					LjProIntVe()
				EndIf
				FRTProcSZ()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Se usar os modulos de gestao de concessionarias chama a funcao que grava os relacionamentos.  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SuperGetMV("MV_VEICULO") == "S" .AND. !Empty(SL1->L1_VEICTIP) .AND. !Empty(SL1->L1_VEIPESQ)
    				FG_DEVLOJA(SL1->L1_VEICTIP,SL1->L1_VEIPESQ, SL1->L1_DOC, SL1->L1_SERIE)
    			Endif
				
				//Integracao hotelaria, verifica se venda integrada é excluida    			     			    			
    			If lProcessou .And. lIntegDef .And. (SL1->L1_ORIGEM == "N" .And. SL1->L1_STORC == "E") 
    				If lLj140StIn
    					Lj140StInD(.T.) //Setup de processamento de mensagem única
    				EndIf    					
    				MsExecAuto({|a,b,c,d,e,f,g| LJ140EXC(a,b,c,d,e,f,g)}, "SL1", /*nReg*/, 5, /*aReserv*/, .T., SL1->L1_FILIAL, SL1->L1_NUM) //Exclui venda
    				lj140ExcOrc() //Exclui orcamento
       				If lLj140StIn
    					Lj140StInD(.F.) //Setup de processamento de mensagem única
    				EndIf 
    			EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLJ7051
					//ponto de entrada Removido em 12/06/2018
					LjGrvLog("LJ7051","Ponto de Entrada LJ7051 descontinuado para o LojXFunc")
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclusao de chamada - Especifico Template  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistTemplate("LJ7002")
					ExecTemplate( "LJ7002", .F., .F., { 2, Nil, 2 } )
				EndIf
				If ExistBlock("LJ7002")
					ExecBlock( "LJ7002", .F., .F., { 2, Nil, 2 } )
				EndIf

				If ( nTimes > 30 ) .OR. ( nIntervalo == nSleep )

					If File("LJGR"+cFileName+".FIM")

						ConOut("            "+STR0023) 	//"Solicitacao para finalizar gravacao batch atendida..."

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Somente apaga o arquivo quando existir³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						FErase("LJGR"+cFileName+".FIM")
						lExProc := .F.
						Exit
					EndIf
					nTimes := 0
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente apaga o arquivo de orcamentos quando existir³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjxCDelArq( SL1->L1_NUM )

				nIntervalo := 0
				nTimes++

			Else
				LjGravaErr()
				ConOut("LJGrvBatch: "+ STR0079 + aFiliais[ nCount ][1] + ". "+STR0022) // "Filial " ### ". " "Ocorreu algum erro no processo de gravacao batch..."
				AADD(aBadRecno, SL1->(Recno()) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Envia msg pelo EventViewer ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oEvent:SetMsg(IDEVENT, STR0079 + aFiliais[ nCount ][1] + ". " + STR0022) // "Filial " ### ". " "Ocorreu algum erro no processo de gravacao batch..."
				oEvent:Enviar()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada que permite verificar o erro gerado no processo de gravacao batch ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLj7064
					ExecBlock("LJ7064", .F., .F., {SL1->(Recno())})
				EndIf
				
				//Tratamento para Erro, reinicia o job do ljGrvBatch caso tenha acontecido algum erro a gravação da venda.
				LjGrvEnd()
				Exit

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza o indice L1_FILIAL+L1_SITUA+L1_STATUS para priorizar os orcamentos com pedido. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaInd14
				SL1->(DbSetOrder(14)) //L1_FILIAL+L1_SITUA+L1_STATUS
				If !SL1->(DbSeek(xFilial("SL1")+"RX"+"F"))
					SL1->(DbSetOrder(9))
					SL1->(DbSeek(xFilial("SL1")+"RX"))
				EndIf
			Else
				SL1->(DbSetOrder(9))
				SL1->(DbSeek(xFilial("SL1")+"RX"))
			EndIf
			
			LjGrvLog('GravaBatch', "ID_FIM")
	   		LjGrvLog(SL1->L1_NUM,"Fim do Processamento da Venda")
			lGrvErro := .F.
			
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄa¿
		//³Checa se a tabela MBZ e função de gravacao de estorno existem na base                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÙ
		Lj601GrPDV()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄa¿
		//³Checa se o arquivo existe fora so while do SL1 para apagar quando não existir RX no SL1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄaÙ
		If ( nTimes > 30 ) .OR. ( nIntervalo == nSleep ) .OR. lRestartGB
			If File("LJGR"+cFileName+".FIM")
				ConOut("            "+STR0023) //"Solicitacao para finalizar gravacao batch atendida..."
				FErase("LJGR"+cFileName+".FIM")
				Exit
			EndIf
			nTimes := 0
		EndIf

		nIntervalo := 0
		nTimes++
		aBadRecno  := {}

		If( cMvLJILJLO == "1", oLJCLocker:ReleaseLock( "LOJXFUNCILLock" ),NIL)

		If lMultFil
			RESET ENVIRONMENT
		Endif
		nIntervalo := nSleep

		If ( nIntervalo > 0 )
			Sleep(nIntervalo)
		EndIf

		If lMultFil
			FClose(nHandle)
			FErase("LJGR"+cFileName+".WRK")

			ConOut("            "+STR0075 + cEmp + STR0076 + aFiliais[ nCount ][1]+" - "+STR0024) //""Empresa:" ### " Filial: - Processo de gravacao batch finalizado..."
		Endif
	Else
		ConOut(Repl("*",40)+Chr(10)+Chr(10))
		ConOut("LJGrvBatch: "+STR0075 + cEmp + STR0076 + aFiliais[ nCount ][1])  // "Empresa:" ### " Filial:"
		ConOut("            "+STR0018)  //"Processo de gravacao batch ja estava rodando"

		lRetValue := .F.
		Exit
	EndIf
	If nCount < LEN( aFiliais )
		nCount := nCount + 1
	Else
		nCount := 1
	EndIf

End

If !lMultFil .OR. !lExProc
	RESET ENVIRONMENT
Endif

FClose(nHandle)
FErase("LJGR"+cFileName+".WRK")

Return ( lRetValue )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjGrvStart³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicia o processo batch de gravacao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Front Loja / Siga Loja                                   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrvStart()

StartJob("LjGrvBatch",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

MsgInfo(STR0025)   //"Gravação batch iniciada com sucesso!"

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjGrvEnd	³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Finaliza o processo batch de gravacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Front Loja / Siga Loja                                   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrvEnd()
Local nHandle := fCreate("LJGR"+cEmpAnt+cFilAnt+".FIM")

If nHandle == -1
	MsgAlert(STR0026) //"Não consegui criar o arquivo LJGRV.FIM para finalizar a gravação batch."
	Return (.F.)
EndIf

fWrite(nHandle,STR0027)  //"Finaliza Gravacao Batch"
fClose(nHandle)
ConOut("LJGrvBatch: "+STR0075+cEmpAnt+STR0076+cFilAnt)  // "Empresa:" ### " Filial:"
ConOut("            "+STR0028) //"Recebida solicitacao para finalizar gravacao batch..."
MsgInfo(STR0029) //"Solicitação para finalizar gravacao batch enviada com sucesso ao server!"

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjGrvSB3    ³ Autor ³ Vendas Clientes     ³ Data ³03/07/01    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza demanda ao finalizar a venda.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010, LOJA220, FRTA010                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrvSB3()

Local cMes                    // Nome do campo a ser atualizado, de acordo com o mes da venda
Local lInclui	 := .F.      // Verifica se é inclusao ou alteracao.
Local nVezes     := 0        // Controla a quantidade de tentativas para lock do registro, 10 vezes
Local lExitLoop  := .F.     // Controla se sai do loop de tentativas de lock

If !(SD2->D2_TIPO $ "DB")
	cMes := "B3_Q"+StrZero(Month(SD2->D2_EMISSAO),2)
	DbSelectArea("SB3")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o produto no SB3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !DbSeek( xFilial("SB3")+SD2->D2_COD)
		lInclui := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente grava o registro se o RecLock retornar True.³
	//³Caso contrario gera um log.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lInclui
		While nVezes <= 10 .AND. !lExitLoop
			If SB3->(Rlock())
				SB3->(MsUnlock())
				nVezes     := 0
				lExitLoop  := .T.
			Else
			   nVezes++
			   Sleep(1000)
			EndIf
		End
	EndIf

	If nVezes == 0 .AND. RecLock("SB3",lInclui)
		REPLACE SB3->B3_FILIAL WITH xFilial("SB3")
		REPLACE SB3->B3_COD    WITH SD2->D2_COD
		If SD2->D2_TES <= "500"
			&(cMes) := &(cMes) - SD2->D2_QUANT
		Else
			&(cMes) := &(cMes) + SD2->D2_QUANT
		EndIf
		REPLACE  SB3->B3_MES WITH SD2->D2_EMISSAO
		dbCommit()
		MsUnlock()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando nao conseguir locar o registro gera esta mensagem no server.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ConOut("Impossible lock on file"  ;
			 + " Data/Hora:"+ DTOC(Date()) + "/" + Time() ;
			 + " Funcao: LjGrvSB3" ;
			 + " Produto:" + SD2->D2_COD ;
			 + " Record:" + AllTrim(Str(Recno())) ;
			 + ".")
			//			 + " Alias:" + cAlias ;
	EndIf

EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010ReservaºAutor³ Vendas Clientes    º Data ³  29/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta de estoques por loja.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Reserva()
Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
Local oWhite		:= LoadBitmap(GetResources(), "BR_BRANCO")
Local oTodasLojas
Local oTodosProds
Local oEstoque
Local oFntListBox

Local aLojas 		:= {}
Local aProdutos 	:= {}
Local aProds 		:= {}
Local aEstoque 		:= {}
Local aEstAux 		:= {}
Local aReserva		:= {}
Local aAlmox		:= {}
Local aRetorno		:= {}

Local lContinua 	:= .F.
Local lTodasLojas   := .F.
Local lTodosProds  	:= .F.
Local lReserva

Local cLojaLocal 	:= ""
Local cClientePad	:= Padr(SuperGetMV("MV_CLIPAD"),TamSx3("A1_COD")[1])+SuperGetMV("MV_LOJAPAD")

Local nPosCodProd 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="L2_PRODUTO"})
Local nPosDescPro 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="L2_DESCRI"})
Local nPosQuant 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="L2_QUANT"})
Local nPosReserva  	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="L2_RESERVA"})
Local nPosLojaRes  	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="L2_LOJARES"})
Local nTamL2_ITEM	:= TamSX3("L2_ITEM")[1]
Local i,x,z	 		:= 0
Local nQuant 		:= 0
Local nLinha 		:= 0
Local lLjPrdRes		:= ExistBlock("LJPRDRES")
Local lLjPrdResT	:= ExistTemplate("LJPRDRES")//Variavel utilizada por Templates
Local aLjPrdRes		:= {}  	// Retorno do P.E. LJPRDRES
Local lFTVDPRDRES		:= ExistBlock("FTVDPRDRES")
Local lFTVDPRDREST	:= ExistTemplate("FTVDPRDRES")	//Variavel utilizada por Templates
Local aFTVDPRDRES		:= {}  								// Retorno do P.E. FTVDPRDRES
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratamento do codigo e descricao do produto             ³
//³ Retorno a posicao da aCols que contem o codigo e a descricao do produto       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjPrdResT .AND. !lFtvdVer12
	aLjPrdRes := ExecTemplate("LJPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .AND. Len(aLjPrdRes) >= 2
		nPosCodProd	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	EndIf
EndIf

If lFTVDPRDREST .AND. lFtvdVer12
	aFTVDPRDRES := ExecTemplate("FTVDPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aFTVDPRDRES) == "A" .AND. Len(aFTVDPRDRES) >= 2
		nPosCodProd	:= aFTVDPRDRES[1]
		nPosDescPro	:= aFTVDPRDRES[2]
	EndIf
EndIf

If lLjPrdRes .AND. !lFtvdVer12
	aLjPrdRes := ExecBlock("LJPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .AND. Len(aLjPrdRes) >= 2
		nPosCodProd	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	EndIf
EndIf

If lFTVDPRDRES .AND. lFtvdVer12
	aFTVDPRDRES := ExecBlock("FTVDPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aFTVDPRDRES) == "A" .AND. Len(aFTVDPRDRES) >= 2
		nPosCodProd	:= aFTVDPRDRES[1]
		nPosDescPro	:= aFTVDPRDRES[2]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o codigo da loja local               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLJ")
DbSetOrder(3)
If DbSeek(xFilial("SLJ")+SM0->M0_CODIGO+FWGETCODFILIAL)
	cLojaLocal := SLJ->LJ_CODIGO
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pede para o usuario escolher as lojas para ver o estoque  ³
//³Varre o cadastro de Identificacao de lojas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSetOrder(2)
DbSeek(xFilial("SLJ"))
While !Eof() .AND. xFilial("SLJ") == SLJ->LJ_FILIAL
	aAdd(aLojas,{.F., SLJ->LJ_NOME, SLJ->LJ_CODIGO})
	DbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o array para o usuario escolher os produtos                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aCols)
	If !aCols[i][Len(aCols[i])] .AND. Empty(aCols[i][nPosReserva]) .AND. !Empty(aCols[i][nPosCodProd])
		aAdd(aProdutos,{.F.,aCols[i][nPosCodProd],aCols[i][nPosDescPro],aCols[i][nPosquant],StrZero(i,nTamL2_ITEM,0)})
	EndIf
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta tela para o usuário escolher a(s) loja(s) e os produtos             ³
//³que deseja consultar o estoque                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aProdutos)
	If SA1->A1_COD+SA1->A1_LOJA == cClientePad
		MsgStop(STR0031)	// "Não é permitido fazer reserva para o cliente padrão."
	Else

		DEFINE FONT oFntListBox	NAME "Courier New"
		DEFINE MSDIALOG oDlgConsulta TITLE STR0032 FROM 0,0 TO 300,490 PIXEL OF GetWndDEFAULT()  // "Consulta de Estoques / Identificação da Loja"

		@ 08,08 LISTBOX oLojas FIELDS HEADER "",STR0033 FIELDSIZES 14,130 SIZE 230,55 PIXEL FONT oFntListBox OF oDlgConsulta	// "Loja"
		oLojas:SetArray(aLojas)
		oLojas:bLDblClick := {|| (aLojas[oLojas:nAt,1] := !aLojas[oLojas:nAt,1]) }
		oLojas:bLine := {|| {If(aLojas[oLojas:nAt,1],oOk,oNo),aLojas[oLojas:nAt,2] }}

		@ 65,12 CHECKBOX oTodasLojas VAR lTodasLojas PROMPT STR0034 SIZE 53,8 PIXEL OF oDlgConsulta;	//"Selecionar Todas"
		ON CHANGE {|| aEval(aLojas,{|x| x[1]:= lTodasLojas }),oLojas:Refresh() }

		@ 75,08 LISTBOX oProdutos FIELDS HEADER "",STR0035,STR0036,STR0037 FIELDSIZES 14,40,123,40 SIZE 230,55 PIXEL FONT oFntListBox OF oDlgConsulta // "Codigo","Descrição","Quantidade"
		oProdutos:SetArray(aProdutos)
		oProdutos:bLDblClick := {|| (aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1])}
		oProdutos:bLine := {|| {If(aProdutos[oProdutos:nAt,1],oOk,oNo),;
		aProdutos[oProdutos:nAt,2],aProdutos[oProdutos:nAt,3],;
		Transform(aProdutos[oProdutos:nAt,4],PesqPict("SL2","L2_QUANT")) }}

		@ 133,12 CHECKBOX oTodosProds VAR lTodosProds PROMPT STR0038 SIZE 53,8 PIXEL OF oDlgConsulta; //"Selecionar Todos"
		ON CHANGE {|| aEval(aProdutos,{|x| x[1]:= lTodosProds }),oProdutos:Refresh() }

		DEFINE SBUTTON FROM 133, 180 TYPE 1 ACTION (lContinua:=.T.,oDlgConsulta:End()) ENABLE PIXEL OF oDlgConsulta
		DEFINE SBUTTON FROM 133, 210 TYPE 2 ACTION oDlgConsulta:End() ENABLE PIXEL OF oDlgConsulta

		ACTIVATE MSDIALOG oDlgConsulta CENTERED
	EndIf
Else
	MsgInfo(STR0039) // "Não foi digitado nenhum produto."
EndIf

If lContinua .AND. aScan(aLojas,{|x| x[1]})==0
	MsgStop(STR0040) // "Não foi selecionada nenhuma loja para consulta"
	lContinua := .F.
EndIf
If lContinua .AND. aScan(aProdutos,{|x| x[1]})==0
	MsgStop(STR0041) // "Não foi selecionado nenhum produto para consulta"
	lContinua := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aEstoque                                          ³
//³(Utilizada para mostrar os saldos dos estoques das outras lojas)     ³
//³                                                                     ³
//³aEstoque[1]-True ou False (para o ListBox)                           ³
//³aEstoque[2]-Codigo da Loja                                           ³
//³aEstoque[3]-Nome da Loja                                             ³
//³aEstoque[4]-Codigo do Produto                                        ³
//³aEstoque[5]-Array com a qtd em Estoque                               ³
//³            [1]-Local                                                ³
//³            [2]-Qtde Estoque                                         ³
//³aEstoque[6]-Quantidade a Reservar                                    ³
//³aEstoque[7]-Texto para ser mostrado no ListBox                       ³
//³aEstoque[8]-Item do produto.                                         ³
//³aEstoque[9]-Armazem                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEstoque := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estabelece uma comunicação via RPC com os outros servidores para³
//³consultar o estoque das lojas                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aProds := {}
If lContinua
	aEval(aProdutos,{|x| If(x[1],aAdd(aProds,{x[2],x[5]}),NIL) })
	DbSelectArea("SLJ")
	DbSetOrder(1)
	For i:=1 to Len(aLojas)
		aEstAux := {}
		If aLojas[i][1] .AND. DbSeek(xFilial("SLJ")+aLojas[i][3])
			aAlmox := Lj080Local(AllTrim(SLJ->LJ_LOCAL),2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama a função para conexão com as lojas               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjMsgRun( STR0042+AllTrim(aLojas[i][2])+".",,; // "Aguarde ... Consutando loja "
			{|| aEstAux := LjRpcConsulta( AllTrim(SLJ->LJ_RPCSRV), Val(AllTrim(SLJ->LJ_RPCPORT)), AllTrim(SLJ->LJ_RPCENV),;
			SLJ->LJ_RPCEMP, SLJ->LJ_RPCFIL, aProds, AllTrim(aLojas[i][2]),aAlmox ) } )

			If !Empty(aEstAux)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta o array aEstoque para montar o ListBox                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    aAdd(aEstoque,{.F.,aLojas[i][3],aLojas[i][2],"",0,0,aLojas[i][2]})
				For x:=1 to Len(aEstAux)
					For z:= 1 To Len(aEstAux[x][2])
						cArmazem 	:= aEstAux[x][2][z][1]
						nQuant 		:= aEstAux[x][2][z][2]
						aAdd(aEstoque, {.F.,;
	  									aLojas[i][3],;
										aLojas[i][2],;
										aEstAux[x][1],;
										aEstAux[x][2],;
										aProdutos[aScan(aProdutos,{|z| z[2]==aEstAux[x][1]})][4],;
										Space(5)+aEstAux[x][1]+' '+SubStr(Posicione("SB1",1,xFilial("SB1")+aEstAux[x][1],"B1_DESC"),1,25)+" "+cArmazem+"  "+Transform(nQuant,PesqPict("SB2","B2_QATU")),;
										aEstAux[x][3],;
										cArmazem})
					Next z
				Next x
			Else
				//"Não foi possível efetuar comunicação com XXXXXX
				//"Verifique a Identificação de Lojas")
				MsgStop( STR0093 + aLojas[i][2] + Chr(13) + Chr(10) + STR0094 )
			EndIf
		EndIf
	Next i
EndIf

lReserva := .F.
If !Empty(aEstoque)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela com o Resultado da consulta do estoque para          ³
	//³o usuario escolher a reserva                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgEstoque TITLE STR0043 FROM 0,0 TO 300,530 PIXEL OF GetWndDEFAULT() // "Consulta de Estoques"

	@ 08,08 LISTBOX oEstoque FIELDS HEADER "",STR0044 FIELDSIZES 14,100 SIZE 250,118 PIXEL FONT oFntListBox OF oDlgEstoque  // "Loja Codigo          Descrição                Local      Saldo"
	oEstoque:SetArray(aEstoque)
	oEstoque:bLine      := {|| { If( Empty(aEstoque[oEstoque:nAt][4]),oWhite,If(aEstoque[oEstoque:nAt,1],oOk,oNo)),;
								aEstoque[oEstoque:nAt,7] }}
	oEstoque:bLDblClick := {|| If(!Empty(aEstoque[oEstoque:nAt][4]),aEstoque[oEstoque:nAt,1]:=!aEstoque[oEstoque:nAt,1],),;
								oEstoque:Refresh() }

	@ 133,180 BUTTON STR0045 PIXEL SIZE 32,14 ACTION (lReserva:=.T.,oDlgEstoque:End()) OF oDlgEstoque // "Reserva"
	@ 133,215 BUTTON STR0061 PIXEL SIZE 32,14 ACTION (lContinua:=.F.,oDlgEstoque:End()) OF oDlgEstoque //"Cancelar"

	ACTIVATE MSDIALOG oDlgEstoque CENTERED

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e para efetuar a reserva                                 ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Estrutura do array aReserva                                          ³
//³aReserva[1]-Codigo da Loja                                           ³
//³aReserva[2]-Codigo do Produto                                        ³
//³aReserva[3]-Quantidade a Reservar                                    ³
//³aReserva[4]-Array. Contendo:                                         ³
//³            [1]-Local                                                ³
//³            [2]-Quantidade em estoque                                ³
//³aReserva[6]-Armazem                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReserva := {}
If lReserva
    For i:=1 to len(aEstoque)
    	If aEstoque[i][1] .AND. !Empty(aEstoque[i][4])
    		nQuant := 0
    		aEval( aEstoque[i][5],{|z| nQuant+=z[2] })
    		If nQuant >= aEstoque[i][6]
		    	aAdd(aReserva,{aEstoque[i][2],aEstoque[i][4],aEstoque[i][6],aEstoque[i][5],aEstoque[i][8],aEstoque[i][9]})
		    Else
				// "A reserva não pode ser efetuada."
				// "Ultrapassou o limite em estoque"
				// "Produto XXXXX"
	    		MsgStop(STR0048 +Chr(13)+Chr(10)+ STR0090 +Chr(13)+ Chr(10)+  STR0058 + ": " + aEstoque[i][4])
		    EndIf
    	EndIf
    Next i
    If !Empty(aReserva)

		LjMsgRun(STR0046,,; // "Aguarde ... Efetuando a reserva."
		{|| aRetorno := LjRpcReserva(aReserva) })

		lRetorno := !Empty(aRetorno)

		If lRetorno
			MsgInfo(STR0047) // "A reserva foi efetuada com sucesso."
		Else
			MsgStop(STR0048) // "A reserva não pode ser efetuada."
			lReserva := .F.
		EndIf
	Else
		lReserva := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o numero da reserva no aCols. Explode os produtos                ³
//³no aCols se necessario dividir em mais de um armazem                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReserva
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta o aCols com o numero da reserva          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For x:=1 to Len(aRetorno)
    	nLinha := Val(aRetorno[x][6])
        aCols[nLinha][nPosQuant]	:= aRetorno[x][3]
        aCols[nLinha][nPosReserva]	:= aRetorno[x][1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a reserva foi feita na loja local não grava o numero no aCols     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cLojaLocal <> aRetorno[x][5]
	        aCols[nLinha][nPosLojaRes]	:= aRetorno[x][5]
	 	EndIf
    Next x
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava as alteracoes no aCols para nao dar diferenca no pedido gerado na    ³
	//³ outra loja                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGet:Refresh()

EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcConsultaºAutor³ Vendas Clientes   º Data ³  06/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a conecao RPC com o servidor para consultar o saldo     º±±
±±º          ³em estoque.                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcConsulta( cRPCServer , nRPCPort , cRPCEnv  , cRPCEmp , ;
                        cRPCFilial , aProdutos, cNomeLoja, aLocal  )

Local aRetorno := {}
Local oServer

ConOut(STR0049+cRPCServer) // "Tentando estabelecer comunicacao com o Server "

oServer := TRPC():New( cRPCEnv )
If oServer:Connect( cRpcServer, nRPCPort )
	oServer:CallProc("RPCSetType", 3 )
	oServer:CallProc("RPCSetEnv", cRPCEmp, cRPCFilial,,,,, {'SB2','SBF','SBE','SDC','SDB','SDA','SB8'})

	ConOut(STR0050+cRPCServer+ STR0051 + AllTrim(cNomeLoja)) // "Conexao estabelecida com o servidor " / " Loja "
	aRetorno := oServer:CallProc("LjRpcEstoque", aProdutos, aLocal )

	oServer:CallProc( 'DbCloseAll' )
	oServer:Disconnect()
Else
	ConOut(STR0052+cRPCServer+ STR0051 + AllTrim(cNomeLoja)) // "Nao foi possivel estabelecer conexao com o servidor" / " Loja "
EndIf

Return (aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcEstoqueºAutor³ Vendas Clientes    º Data ³  31/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica o saldo em Estoque produto solicitado nos locais   º±±
±±º          ³indicados pelo array aLocal                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³aValores := LjRpcEstoque( aProdutos, aLocal )               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aProduto - array contendo os codigos dos produtos a         º±±
±±º          ³           pesquisar l                                      º±±
±±º          ³aLocal - array contendo os locais a pesquisar o estoque     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array contendo os valores.                                  º±±
±±º          ³[1] - Codigo do produto                                     º±±
±±º          ³[2] - Saldo Disponivel                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcEstoque( aProdutos,aLocal )
Local nY
Local nX
Local aRet   := {}
Local aQuant := {}

DbSelectArea("SB2")
DbSetOrder(1)
For nX := 1 to Len(aProdutos)
	aQuant := {}
	For nY := 1 to Len(aLocal)
		If DbSeek(xFilial("SB2")+aProdutos[nX][1]+aLocal[nY])
			nQuant := SB2->B2_QATU - SB2->B2_RESERVA
			aAdd(aQuant,{SB2->B2_LOCAL, nQuant} )
		EndIf
	Next nY
	aAdd( aRet, {aProdutos[nX][1],aQuant,aProdutos[nX][2]} )
Next nX

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcReservaºAutor³ Vendas Clientes    º Data ³  20/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a(s) reserva(s) na(s) loja(s) selecionada(s)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjRpcReserva( aReserva )                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aReserva[1]-Codigo da Loja                                  º±±
±±º          ³aReserva[2]-Codigo do Produto                               º±±
±±º          ³aReserva[3]-Quantidade a Reservar                           º±±
±±º          ³aReserva[4]-Array. Contendo:                                º±±
±±º          ³            [1]-Local                                       º±±
±±º          ³            [2]-Qtde em estoque                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRetorno[1]-Numero da Reserva                               º±±
±±º          ³aRetorno[2]-Codigo do Produto                               º±±
±±º          ³aRetorno[3]-Quantidade Reservada                            º±±
±±º          ³aRetorno[4]-Armazem em que foi reservado                    º±±
±±º          ³aRetorno[5]-Numero da loja onde foi feita a reserva         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcReserva( aReserva )
Local oServer
Local cRpcServer
Local cRPCEnv
Local cRPCEmp
Local cRPCFilial
Local cNumero 		:= ""
Local cProduto
Local cLocal
Local cLojaAnt
Local cItem

Local aArea 		:= GetArea()
Local aOperacao 	:= {}
Local aLote 		:= {}
Local aRetorno 		:= {}
Local aHeaderAux	:= {}
Local aColsAux		:= {}
Local aRetReserva	:= {}
Local aCliente 		:= {}

Local nRPCPort
Local nUso	 		:= 0
Local nX
Local nReserva	 	:= 0
Local nDiasReserva  := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com aHeader e aCols somente com os dados necessarios para a ³
//³ rotina de reserva                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderAux := {}
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("C0_VALIDA ")
		nUso++
		AADD(aHeaderAux,{ 	TRIM(X3Titulo())	, SX3->X3_CAMPO	,	SX3->X3_PICTURE	, SX3->X3_TAMANHO	,;
							SX3->X3_DECIMAL		, SX3->X3_VALID	,	SX3->X3_USADO	, SX3->X3_TIPO		,;
							SX3->X3_ARQUIVO		, SX3->X3_CONTEXT }	)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array aCliente com os dados do SA1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
For nX := 1 to FCount()
	aAdd(aCliente,{Field(nX),FieldGet(nX)})
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis da acols                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsAux := Array(nUso+1)
aColsAux[1] := dDataBase
aColsAux[nUso+1] := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura as variaveis para fazer a reserva                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOperacao := {1,"LJ",SA1->A1_COD,cUserName,xFilial("SC0")}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o array aReserva em ordem de codigo de lojas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aReserva,,,{|a,b| a[1]<b[1] })

nX := 1
DbSelectArea("SLJ")
DbSetOrder(1)
While nX <= Len(aReserva)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona a loja para pegar a configuracao do servidor        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSeek(xFilial("SLJ")+aReserva[nX][1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a loja não permitir reserva (LJ_RESERVA=="2")    ³
	//³avisa e pula para a proxima                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If SLJ->LJ_RESERVA == "2"
		// "Não será possível efetuar reserva na loja " # "Verifique a Identificação de Lojas" # "Atenção"
		MsgStop( STR0104 + aReserva[nX][1] + CHR(13) + CHR(10) + STR0094, STR0089)
		nX++
		Loop
    EndIf
    cRpcServer		:= AllTrim(SLJ->LJ_RPCSRV)
    nRPCPort		:= Val(AllTrim(SLJ->LJ_RPCPORT))
    cRPCEnv 		:= AllTrim(SLJ->LJ_RPCENV)
    cRPCEmp 		:= SLJ->LJ_RPCEMP
    cRPCFilial 		:= SLJ->LJ_RPCFIL
    cNomeLoja 		:= AllTrim(SLJ->LJ_NOME)
    cLojaAnt 		:= aReserva[nX][1]
    nDiasReserva 	:= SLJ->LJ_DIASRES
    aColsAux[1]		+= nDiasReserva

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estabelece comunicação RPC com o Server                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oServer := TRPC():New( cRPCEnv )
	If oServer:Connect( cRpcServer, nRPCPort )
		oServer:CallProc("RPCSetType", 3 )
		If oServer:CallProc("RPCSetEnv", cRPCEmp, cRPCFilial,,,,, {'SB2','SC0','SBF','SBE','SDC','SDB','SDA','SB8'})
			cLojaAnt := aReserva[nX][1]
			While (nX <= Len(aReserva)) .AND. (cLojaAnt == aReserva[nX][1])
				nReserva := aReserva[nX][3]
				cProduto   := aReserva[nX][2]
				cLocal     := aReserva[nX][6]
				cItem      := aReserva[nX][5]
				aLote := {GDFieldGet("L2_NLOTE"		, Val(cItem)),;
						  GDFieldGet("L2_LOTECTL"	, Val(cItem)),;
						  GDFieldGet("L2_LOCALIZ"	, Val(cItem)),;
						  GDFieldGet("L2_NSERIE"	, Val(cItem))}

				aRetorno := oServer:CallProc("LjRpcIncRes",aOperacao,cNumero,cProduto,cLocal,nReserva,aLote,aHeaderAux,aColsAux,aCliente)
				If ValType(aRetorno) == "A"
					If aRetorno[1]
						ConOut(STR0053+cRPCServer+STR0051+cNomeLoja) // "A reserva foi concluida no Server " / " Loja "
						aAdd(aRetReserva,{aRetorno[2],cProduto,nReserva,cLocal,aReserva[nX][1],cItem})
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o L2_LOCAL com o que foi reservado³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						GDFieldPut("L2_LOCAL", cLocal, Val(cItem))
					Else
						ConOut(STR0054+cRPCServer+STR0051+cNomeLoja)  // "A reserva nao pode ser efetuada no Server "  / " Loja "
					EndIf
				EndIf
				nX++
			End
		Else
			MsgStop( STR0095+cRPCEmp+STR0096+cRPCFilial+CHR(13)+CHR(10)+STR0094 , STR0089 )//"Problemas ao selecionar a empresa "//" e a Filial "
		EndIf
		oServer:CallProc( 'DbCloseAll' )
		oServer:Disconnect()
	Else
		MsgStop( STR0093 + SLJ->LJ_NOME + CHR(13) + CHR(10) + STR0094,STR0089)
	EndIf
End

RestArea(aArea)

Return (aRetReserva)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcIncRes ºAutor³ Vendas Clientes    º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a reserva                                               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcIncRes( aOperacao , cNumero , cProduto  , cLocal  , ;
                      nQuant    , aLote   , aHeaderAux, aColsAux, ;
                      aCliente  )

Local lRet
Local nPosCGC	:= aScan(aCliente,{|z| AllTrim(Upper(z[1]))=="A1_CGC" })
Local nPosCod	:= aScan(aCliente,{|z| AllTrim(Upper(z[1]))=="A1_COD" })
Local nPosLoja	:= aScan(aCliente,{|z| AllTrim(Upper(z[1]))=="A1_LOJA" })
Local cCGC
Local nX
Local nSaveSx8  := GetSx8Len()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente já existe na base de dados. Caso contrario cria un novo registro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCGC := aCliente[nPosCGC][2]
DbSelectArea("SA1")
DbSetOrder(3)
If !(DbSeek(xFilial("SA1")+cCGC))
	DbSetOrder(1)
	aCliente[nPosCod][2] := GetSx8Num("SA1","A1_COD")
	aCliente[nPosLoja][2] := "01"
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	End
	RecLock("SA1",.T.)
	For nX := 1 To Len(aCliente)
		FieldPut(FieldPos(aCliente[nX][1]),aCliente[nX][2])
	Next nX
	MsUnlock()
EndIf

aOperacao[3] := aCliente[nPosCod][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega um numero de reserva                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumero := GetSx8Num("SC0","C0_NUM")
While (GetSX8Len() > nSaveSx8)
	ConfirmSx8()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Reserva  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := a430Reserv(aOperacao	, cNumero	, cProduto	, cLocal, ;
					nQuant		, aLote		, aHeaderAux, aColsAux )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vincula a reserva ao orçamento para que nao seja manipulada   ³
//³ pelo programa Controle de Reservas (MATA340).                 ³
//³ Procedimento tambem utilizado para amarracoes entre pedidos   ³
//³ (SC6) e reservas (SC0) no modulo de faturamento               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC0->C0_QUANT  -= nQuant
SC0->C0_QTDPED += nQuant
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


Return {lRet,cNumero}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjTipoRes ºAutor  ³ Vendas Clientes    º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o tipo da Reserva.                                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTipoRes()
Local oTipoReserva
Local oCheck1
Local nCheck := 1

DEFINE MSDIALOG oTipoReserva TITLE STR0045 FROM 0,0 TO 130,300 PIXEL OF GetWndDEFAULT() // "Reserva"

@ 10,10 RADIO oCheck1 VAR nCheck 3D SIZE 130,10 PROMPT;
		STR0109,;                       //"Buscar produto na Outra Loja"
		STR0110,;                       //"Outra Loja Entrega"
		STR0111 OF oTipoReserva PIXEL   //"Transferência da outra Loja para esta Loja"

DEFINE SBUTTON FROM 45, 90 TYPE 1 ACTION oTipoReserva:End() ENABLE PIXEL OF oTipoReserva
DEFINE SBUTTON FROM 45, 120 TYPE 2 ACTION (nCheck:=0, oTipoReserva:End()) ENABLE PIXEL OF oTipoReserva

ACTIVATE DIALOG oTipoReserva CENTERED

Return (nCheck)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjCancRes ºAutor  ³ Vendas Clientes    º Data ³  17/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o cancelamento das reservas.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aReserva[1]-Numero da Reserva                               º±±
±±º          ³aReserva[2]-Codigo da Loja                                  º±±
±±º          ³aReserva[3]-Codigo do Produto                               º±±
±±º          ³aReserva[4]-Local (Armazem)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet - Conseguiu ou nao fazer a reserva                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCancRes( aReserva )
Local oServer
Local cRpcServer
Local nRPCPort
Local cRPCEnv
Local cRPCEmp
Local cRPCFilial
Local cNomeLoja
Local aArea 		:= GetArea()
Local x 			:= 0
Local aOperacao 	:= {3,"LJ","",cUserName,xFilial("SC0")}
Local aLote 	    := {"","","",""}
Local cNumero
Local cProduto
Local cLocal
Local cLojaAnt
Local lCancela 		:= .F.
Local lTudoOk       := .F.
Local lCancelRes    := .F.
Local lConectRPC	:= .F.
Local lRet          := .T.
Local lFilCor		:= .F.
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lEmpCor		:= .F.
Local cFilBkp 		:= cFilAnt

If Len(aReserva) == 0
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o array em ordem de lojas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aReserva,,,{|a,b| a[2]<b[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre o array de reservas e faz o cancelamento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLJ")
DbSetOrder(1)
x := 1
While x <= Len(aReserva)
If DbSeek(xFilial("SLJ")+aReserva[x][2])
		cRpcServer 	:= AllTrim(SLJ->LJ_RPCSRV)
		nRPCPort	:= Val(AllTrim(SLJ->LJ_RPCPORT))
		cRPCEnv 	:= AllTrim(SLJ->LJ_RPCENV)
		cRPCEmp 	:= SLJ->LJ_RPCEMP
		cRPCFilial 	:= SLJ->LJ_RPCFIL
		cNomeLoja 	:= AllTrim(SLJ->LJ_NOME)
		cLojaAnt 	:= aReserva[x][2]

		// Verifica se eh a mesma Empresa corrente
        lEmpCor		:= AllTrim(cRPCEmp) == AllTrim(cEmpAnt)
		// Verifica se eh a mesma Filial corrente
   		lFilCor		:= AllTrim(cRPCFilial) == AllTrim(cFilAnt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando Utilizar Conexão RPC(Emp/Filial diferente da atual), verifica cadastro Identif. de Loja ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !lEmpCor .AND. (Empty(cRpcServer) .OR. Empty(nRPCPort) .OR. Empty(cRPCEnv))
            lCancela := .T.
      	Else
      	    lCancela := .F.
        EndIf

		If !lCancela
			If Len( aReserva[x] ) > 4
				aLote	:= {	aReserva[x][5],;
								aReserva[x][6],;
								aReserva[x][7],;
								aReserva[x][8]   }
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando (Emp/Filial diferente da atual), estabelece comunicação RPC ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If !lEmpCor
		        lConectRPC	:= .F.
				oServer := TRPC():New( cRPCEnv )
				If oServer:Connect( cRpcServer, nRPCPort )
					lTudoOk := .T.
					oServer:CallProc("RPCSetType", 3 )
					oServer:CallProc("RPCSetEnv", cRPCEmp, cRPCFilial,,,,, {'SB2','SC0','SBF','SBE','SDC','SDB','SDA','SB8'})
					lConectRPC  := .T.		// Conexao estabelecida
				Else
					lCancela 	:= .T.
					lRet        := .F.
					lTudoOk 	:= .F.
	            EndIf
	        EndIf

			cLojaAnt := aReserva[x][2]
			While (x <= Len(aReserva)) .AND. (aReserva[x][2] == cLojaAnt)
				cNumero		:= aReserva[x][1]
				cProduto	:= aReserva[x][3]
				cLocal		:= aReserva[x][4]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Volta o valor da quantidade de reserva em pedido (orcamento)  ³
				//³ para que a reserva possa ser cancelada                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC0->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
				If LjNfPafEcf(SM0->M0_CGC) .AND. lFilCor
					cRPCFilial := xFilial("SC0")
				EndIf
				If SC0->(DbSeek(cRPCFilial+cNumero+cProduto+cLocal ))
					SC0->(RecLock("SC0",.F.))
					REPLACE SC0->C0_QUANT  WITH SC0->C0_QUANT  + SC0->C0_QTDPED
					REPLACE SC0->C0_QTDPED WITH SC0->C0_QTDPED - SC0->C0_QUANT
					SC0->(MsUnlock())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz o cancelamento da reserva   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        		If !lFilCor
        			// Altera para Filial que o produto esta reservado
          			cFilAnt := cRPCFilial
                Endif

	            If !lEmpCor
	            	If lConectRPC
						lCancelRes := oServer:CallProc("a430Reserv",aOperacao,cNumero,cProduto,cLocal,0,aLote,{},{})
					Else
						ConOut(STR0055+cRPCServer+STR0051+ AllTrim(cNomeLoja))  // "Nao foi possivel efetuar o cancelamento da reserva no servidor "  / " Loja "
					EndIf
				Else
					lCancelRes := a430Reserv(aOperacao,cNumero,cProduto,cLocal,0,aLote,{},{})
				EndIf

				//  Retona Filial corrente
        		If !lFilCor
		  			cFilAnt := cFilBkp
        		Endif
				If (lCancelRes == Nil) .OR. !lCancelRes
					lRet := .F.
				EndIf

				x++
			End

	  		If !lFilCor .AND. lConectRPC
				oServer:CallProc( 'DbCloseAll' )
				oServer:Disconnect()
			EndIf
	 	Else
			lRet := .F.
	 		Alert(STR0145)  //"Campos referentes a configuração de RPC não preenchidos corretamentes "
	 	    Exit
	 	EndIf
	Else
		lRet := .F.
	EndIf
End

If ExistBlock( "LJCANCRES" ) .AND. lRet .AND. !lFtvdVer12
	ExecBlock( "LJCANCRES" , .F., .F., aReserva )
EndIf

If ExistBlock( "FTVDECancRes" ) .AND. lRet .AND. lFtvdVer12
	ExecBlock( "FTVDECancRes" , .F., .F., aReserva )
EndIf

RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjConsRes ºAutor  ³ Vendas Clientes    º Data ³  27/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a consulta e ou o cancelamento das reservas em       º±±
±±º          ³outras lojas                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjConsRes()
Local oOk 			:= LoadBitmap(GetResources(), "LBOK")
Local oNo 			:= LoadBitmap(GetResources(), "LBNO")
Local oServer
Local oConsulta
Local oFntListBox

Local cClientePad	:= Padr(SuperGetMV("MV_CLIPAD"),TamSx3("A1_COD")[1])+SuperGetMV("MV_LOJAPAD")
Local cRpcServer 	:= AllTrim(SLJ->LJ_RPCSRV)
Local cRPCEnv
Local cRPCEmp
Local cRPCFilial
Local cNomeLoja
Local cCodigoLoja
Local cCliente

Local nRPCPort
Local nX

Local lCancelar		:= .F.

Local aLocal 		:= {}
Local aReservas 	:= {}
Local aConsulta		:= {}


DEFINE FONT oFntListBox	NAME "Courier New"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não faz a consulta se for cliente padrão ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SA1->A1_COD+SA1->A1_LOJA == cClientePad
	MsgStop(STR0056) // "Não é permitido efetuar / consultar reservas para o cliente padrão."
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o cadastro de lojas para verificar as reservas pendentes e ³
	//³tenta estabelecer comunicacao com as lojas para verificar as     ³
	//³reservas.                                                        ³
	//³(So ira checar as lojas que permitem reservas - LJ_RESERVA="1")  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SLJ")
	DbSetOrder(2)
	DbSeek(xFilial("SLJ"))
	While !Eof() .AND. xFilial("SLJ") == SLJ->LJ_FILIAL
		If SLJ->LJ_RESERVA == "1"
			aLocal := lj080Local(SLJ->LJ_LOCAL,2)
			cRpcServer 	:= AllTrim(SLJ->LJ_RPCSRV)
			nRPCPort 	:= Val(AllTrim(SLJ->LJ_RPCPORT))
			cRPCEnv 	:= AllTrim(SLJ->LJ_RPCENV)
			cRPCEmp 	:= SLJ->LJ_RPCEMP
			cRPCFilial	:= SLJ->LJ_RPCFIL
			cNomeLoja 	:= AllTrim(SLJ->LJ_NOME)
			cCodigoLoja := SLJ->LJ_CODIGO

			oServer := TRPC():New( cRPCEnv )
			If oServer:Connect( cRpcServer, nRPCPort )
				oServer:CallProc("RPCSetType", 3 )
				oServer:CallProc("RPCSetEnv", cRPCEmp, cRPCFilial,,,,, {'SA1','SC0','SB2','SBF','SBE','SDC','SDB','SDA','SB8'})

				// "Aguarde ... Consutando loja " /
				LjMsgRun(STR0042+cNomeLoja+".",,;
				{|| aReservas := oServer:CallProc("LjRpcConsRes",SA1->A1_CGC)} )
				If ValType(aReservas) == "A"
					For nX:=1 to Len(aReservas)
						aAdd( aConsulta, {.F.,cCodigoLoja,cNomeLoja,;
						aReservas[nX][1],Posicione("SB1",1,xFilial("SB1")+aReservas[nX][1],"B1_DESC"),;
						aReservas[nX][2],aReservas[nX][3],aReservas[nX][4],aReservas[nX][5],;
						aReservas[nX][6],aReservas[nX][7],aReservas[nX][8],aReservas[nX][9],;
						aReservas[nX][10]} )
					Next nX
				EndIf
				aReservas := {}
				oServer:CallProc( 'DbCloseAll' )
				oServer:Disconnect()
			EndIf
		EndIf
		DbSkip()
	End

	If !Empty(aConsulta)
		cCliente := SA1->A1_COD + " - " + SA1->A1_NOME
		DEFINE MSDIALOG oDlgConsulta TITLE STR0057 FROM 0,0 TO 300,490 PIXEL OF GetWndDEFAULT() // "Consulta de Reservas"
		@ 10,8 SAY STR0116 PIXEL OF oDlgConsulta //Cliente:
		@ 10,30 MSGET oCliente VAR cCliente WHEN .F. SIZE 130,08 PIXEL OF oDlgConsulta

		@ 25,8 LISTBOX oConsulta FIELDS HEADER "",STR0033,STR0058,STR0037,STR0045,STR0059,STR0060; //"Loja","Produto","Quantidade","Reserva","Validade","Emissão"
		FIELDSIZES 14,35,90,50,50,35,40,40 SIZE 230,100 PIXEL FONT oFntListBox OF oDlgConsulta

		oConsulta:SetArray(aConsulta)
		oConsulta:bLDblClick := {|| (aConsulta[oConsulta:nAt,1] := !aConsulta[oConsulta:nAt,1]) }
		oConsulta:bLine := {|| { If(aConsulta[oConsulta:nAt,1],oOk,oNo),aConsulta[oConsulta:nAt,3],;
		AllTrim(aConsulta[oConsulta:nAt,4])+"-"+AllTrim(aConsulta[oConsulta:nAt,5]),;
		aConsulta[oConsulta:nAt,6],aConsulta[oConsulta:nAt,7],;
		aConsulta[oConsulta:nAt,8],aConsulta[oConsulta:nAt,9] }}

		@ 133,175 BUTTON STR0061 PIXEL SIZE 32,14 ACTION (lCancelar:=.T.,oDlgConsulta:End()) OF oDlgConsulta // "Cancelar"
		@ 133,210 BUTTON STR0062 PIXEL SIZE 32,14 ACTION oDlgConsulta:End() OF oDlgConsulta // "Sair"

		ACTIVATE MSDIALOG oDlgConsulta CENTERED
	ElseIf Empty(SA1->A1_CGC)
		//	"Não é possível consultar. Cliente sem CPF/CNPJ."
		//	"Verifique o cadastro de cliente."
		MsgInfo(STR0091+Chr(13)+Chr(10)+STR0092)
	Else
		MsgInfo(STR0063) //"Não há reservas para este cliente."
	EndIf
EndIf

If lCancelar
	aReservas := {}
	For nX := 1 To Len(aConsulta)
		If aConsulta[nX][1]
			aAdd(aReservas,{ aConsulta[nX][7] , aConsulta[nX][2] , aConsulta[nX][4] , aConsulta[nX][10] ,;
  	             			 aConsulta[nX][11], aConsulta[nX][12], aConsulta[nX][13], aConsulta[nX][14] })
		EndIf
	Next nX

	If !Empty(aReservas)
		If LjCancRes(aReservas)
			MsgInfo(STR0064) //"A reserva foi cancelada."
		Else
			MsgStop(STR0065) //"A reserva não pode ser cancelada."
		EndIf
	EndIf
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcConsResºAutor³ Vendas Clientes    º Data ³  28/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a consulta das reservas                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCliente - CGC / CPF                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRetorno                                                    º±±
±±º          ³[1] - Codigo do produto                                     º±±
±±º          ³[2] - Quantidade Reservada                                  º±±
±±º          ³[3] - Numero da Reserva                                     º±±
±±º          ³[4] - Data da Reserva                                       º±±
±±º          ³[5] - Data da Validade                                      º±±
±±º          ³[6] - Armazem                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcConsRes( cCliente )
Local aRet	 	:= {}		// Array de retorno contendo as reservas
Local cCodigo	:= ""		// Codigo do cliente

DbSelectArea("SA1")
DbSetOrder(3)
If DbSeek(xFilial("SA1")+cCliente)
	cCodigo := SA1->A1_COD
	DbSelectArea("SC0")
	DbSeek(xFilial("SC0"))
	While !Eof() .AND. xFilial("SC0") == SC0->C0_FILIAL
		If SC0->C0_TIPO == "LJ" .AND. ( AllTrim(SC0->C0_DOCRES) == AllTrim(cCodigo) )
			aAdd(aRet, {SC0->C0_PRODUTO , SC0->C0_QTDORIG, SC0->C0_NUM   , SC0->C0_EMISSAO, ;
			            SC0->C0_VALIDA  , SC0->C0_LOCAL  , SC0->C0_NUMLOTE, SC0->C0_LOTECTL, ;
			            SC0->C0_LOCALIZ , SC0->C0_NUMSERI } )
		EndIf
		DbSkip()
	End
EndIf

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjChkReservaºAutor³ Vendas Clientes    º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Varre o aCols para verificar quais as reservas foram feitas º±±
±±º          ³em outras lojas e retira-las da venda.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjChkReserva()
Local oServer
Local nX 			:= 0
Local nPos 			:= 0
Local nPosProduto	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_PRODUTO" })
Local nPosDescri	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_DESCRI" })
Local nPosQuant 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_QUANT" })
Local nPosVrUnit 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_VRUNIT" })
Local nPosLocal  	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_LOCAL" })
Local nPosDesc   	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_DESC" })
Local nPosValDesc  	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_VALDESC" })
Local nPosTes		:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_TES" })
Local nPosLojaRes 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_LOJARES" })
Local nPosReserva 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_RESERVA" })
Local nPosPedFat  	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_PEDFAT" })
Local nTotMovFin	:= 0

Local aColsLojas 	:= {}
Local aColsAux 		:= {}
Local aTipoPagto 	:= {}
Local aPedido 		:= {}
Local aItens 		:= {}
Local aPedFat 		:= {}
Local aRetorno		:= {}

Local lGeraFin 		:= .F.

Local cLojaAnt		:= ""
Local cCaixa 		:= ""
Local cNatureza 	:= ""
Local cNomeLoja 	:= ""
Local cTpPagto		:= ""
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre o aCols para verificar as reservas em outras lojas e como serao tratados³
//³esses produtos                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1	 to Len(aCols)
	If !Empty(aCols[nX][nPosLojaRes])
		If aScan(aColsLojas,aCols[nX][nPosLojaRes]) == 0
			aAdd( aColsLojas, aCols[nX][nPosLojaRes] )
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo de pagamento que a loja trabalha (LJ_TPPAGTO)     ³
//³1-Pagamento somente na loja de compra                                  ³
//³2-Pagamento somente na loja de entrega                                 ³
//³3-Ambos                                                                ³
//³Se a loja trabalhar com os 2 será feita a pergunta de como sera tratada³
//³esta venda.                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLJ")
DbSetOrder(1)
For nX:=1 to Len(aColsLojas)
	If DbSeek(xFilial("SLJ")+aColsLojas[nX])
    	aAdd( aTipoPagto, {SLJ->LJ_CODIGO, SLJ->LJ_NOME, SLJ->LJ_TPPAGTO, SLJ->LJ_CAIXA})
	EndIf
Next nX

For nX:=1 to Len(aTipoPagto)
	If aTipoPagto[nX][3] == "3"
		If MsgYesNo(STR0066 + AllTrim(aTipoPagto[nX][2]) + STR0067) // "Os produtos reservados na loja " / " serão pagos aqui ?"
			aTipoPagto[nX][3] := "1"
		Else
			aTipoPagto[nX][3] := "2"
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retira do aCols somente os produtos que serão pagos na outra loja³
//³(TipoPagto = "2"). Os produtos que tem reservas em outras lojas  ³
//³ e será pago na loja da compra continuarao no aCols              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 to Len(aCols)
	nPos := aScan( aTipoPagto,{|z| z[1]==aCols[nX][nPosLojaRes]} )
	If !Empty(aCols[nX][nPosLojaRes]) .AND. nPos > 0
		If aTipoPagto[nPos][3] == "2"
			aCols[nX][Len(aCols[nX])] := .T.
		ElseIF aTipoPagto[nPos][3] == "1"
			aAdd( aColsAux, aCols[nX] )
		EndIf
	EndIf
Next nX

If nPos > 0
	cTpPagto := aTipoPagto[nPos][3]
EndIf
nX := 1
While nX <= Len(aCols)
	//retira do aCols somente se o produto for pago em outra loja (TipoPagto==2)
	If aCols[nX][Len(aCols[nX])] .AND. ( cTpPagto == "2" )
		aDel(aCols,nX)
		aSize(aCols,Len(aCols)-1)
	Else
		nX++
	EndIf
End

If Len(aCols) = 0
	aCols := Array(1,Len(aHeader)+1)
	For nX := 1 to Len(aHeader)
		If aHeader[nX][8] == "C"
			aCols[1][nX] := Space(aHeader[nX][4])
		ElseIf aHeader[nX][8] == "N"
			aCols[1][nX] := 0
		ElseIf aHeader[nX][8] == "D"
			aCols[1][nX] := dDataBase
		EndIf
		aCols[1][Len(aCols[1])] := .F.
	Next nX
EndIf

oGet:oBrowse:DrawSelect()
oGet:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver reservas em outras lojas cria o pedido para o faturamento ³
//³e a transferencia no SE5.                                           ³
//³Somente nas lojas em que o ambiente for 'Faturamento'               ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Cria 2 arrays para esse controle. aPedido (cabecalho do pedido)     ³
//³e aItens (com os itens da venda)                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nX := 1
While nX <= Len(aColsAux)
	cLojaAnt := aColsAux[nX][nPosLojaRes]
	If SLJ->(DbSeek(xFilial("SLJ")+cLojaAnt))
		cNatureza := SLJ->LJ_NATUREZ
		cNomeLoja := SLJ->LJ_NOME
	Else
		cNatureza := ""
		cNomeLoja := ""
	EndIf
	cCaixa 	:= aTipoPagto[aScan(aTipoPagto,{|z|z[1]==cLojaAnt})][4]
	aPedido := {cLojaAnt, SA1->A1_CGC, SE4->E4_CODIGO, SA3->A3_COD, cCaixa, cNatureza, cNomeLoja}
	While (nX <= Len(aColsAux)) .AND. (cLojaAnt == aColsAux[nX][nPosLojaRes])
		aAdd(aItens, {	aColsAux[nX][nPosProduto]	, aColsAux[nX][nPosDescri]	, aColsAux[nX][nPosQuant]	, aColsAux[nX][nPosVrUnit]	,;
						aColsAux[nX][nPosLocal]		, aColsAux[nX][nPosDesc]	, aColsAux[nX][nPosValDesc]	, aColsAux[nX][nPosTes]		,;
						aColsAux[nX][nPosReserva] })
		nX++
	End
	aAdd( aPedFat, {aPedido	,aItens})
	aPedido := {}
	aItens := {}
End

For nX := 1 to Len(aPedFat)
	aPedido := aPedFat[nX][1]
	aItens := aPedFat[nX][2]
	DbSelectArea("SLJ")
	DbSetOrder(1)
	If DbSeek(xFilial("SLJ")+aPedido[1])
		oServer := TRPC():New( AllTrim(SLJ->LJ_RPCENV) )
		If oServer:Connect( AllTrim(SLJ->LJ_RPCSRV), Val(AllTrim(SLJ->LJ_RPCPORT)) )
			oServer:CallProc("RPCSetType", 3 )
			oServer:CallProc("RPCSetEnv", AllTrim(SLJ->LJ_RPCEMP), AllTrim(SLJ->LJ_RPCFIL),,,,, {'AB6','AB7','AB8','SA1','SA3','SB1','SB2','SC0','SC5','SC6','SC9','SCN','SF4','SFG'})

			aRetorno := oServer:CallProc("LjRpcIncFat", aPedido, aItens)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Conteudo da array de retorno                            ³
			//³[1] Código da Loja                                      ³
			//³[2] Codigo do Produto                                   ³
			//³[3] Numero do pedido gerado no faturamento da outra loja³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType(aRetorno) == "A"
				For nX := 1 to Len(aRetorno)
					nPos := aScan(aCols,{|z| z[nPosLojaRes]+z[nPosProduto] == aRetorno[nX][1]+aRetorno[nX][2] })
					If nPos > 0
						aCols[nPos][nPosPedFat] := aRetorno[nX][3]
						lGeraFin := .T.
					EndIf
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PE para permitir gerar ou nao o financeiro na Reserva ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGeraFin .AND. ExistBlock("LJResFin") .AND. !lFtvdVer12
					lGeraFin := ExecBlock("LJResFin",.F.,.F.)
				EndIf

				If lGeraFin .AND. ExistBlock("FTVDResFin") .AND. lFtvdVer12
					lGeraFin := ExecBlock("FTVDResFin",.F.,.F.)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera a movimentação financeira  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGeraFin
					aEval( aItens, {|z| nTotMovFin += z[3]*z[4]-z[7] })
					LjIncMovFin("P",nTotMovFin,xNumCaixa(),aPedido[6],aPedido[7])
					oServer:CallProc("LjIncMovFin","R",nTotMovFin,aPedido[5],cNatureza,cNomeLoja)
				EndIf
			EndIf

			oServer:CallProc( 'DbCloseAll' )
			oServer:Disconnect()
        EndIf
    EndIf
Next nX
oGet:Refresh()

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcIncFatºAutor ³ Vendas Clientes    º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Inclui o pedido no faturamento da outra loja                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aPedido - array com os dados do cabecalho do pedido         º±±
±±º          ³aItens  - array com os itens do pedido                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³array contendo                                              º±±
±±º          ³[1] Codigo da Loja                                          º±±
±±º          ³[2] Codigo do Produto                                       º±±
±±º          ³[3] Numero do pedido                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcIncFat(aPedido, aItens)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aPedido                                                ³
//³[1] Codigo da Loja                                                        ³
//³[2] CGC do Cliente                                                        ³
//³[3] Codigo da Condicao de Pagametno                                       ³
//³[4] Codigo Vendedor                                                       ³
//³[5] Codigo do caixa para fazer a movimentacao bancaria                    ³
//³[6] Codigo da Natureza para gerar a movimentacao financeira               ³
//³[7] Nome da Loja                                                          ³
//³                                                                          ³
//³Estrutura do array aItens                                                 ³
//³[1] Codigo do produto                                                     ³
//³[2] Descricao                                                             ³
//³[3] Quantidade                                                            ³
//³[4] Valor Unitario                                                        ³
//³[5] Local (Armazem)                                                       ³
//³[6] % Desconto                                                            ³
//³[7] Valor Desconto                                                        ³
//³[8] TES                                                                   ³
//³[9] Codigo da Reserva                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNumSC5 	:= ""
Local cItem 	:= Replicate('0',TamSx3("C6_ITEM")[1])
Local nX 		:= 0
Local aRetorno	:= {}
Local lLiberOk	:= .T.
Local lResidOk	:= .T.
Local lFaturOk	:= .F.
Local lLiber	:= .F.
Local lTransf 	:= .F.
Local nSaveSx8  := GetSx8Len()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o numero para o pedido de venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumSC5 := GetSxeNum("SC5","C5_NUM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o arquivo de clientes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(3)
DbSeek(xFilial("SA1")+aPedido[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a gravação dos pedidos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SC5",.T.)
REPLACE C5_FILIAL  WITH xFilial("SC5")
REPLACE C5_NUM     WITH cNumSC5
REPLACE C5_TIPO    WITH "N"
REPLACE C5_CLIENTE WITH SA1->A1_COD
REPLACE C5_LOJACLI WITH SA1->A1_LOJA
REPLACE C5_LOJAENT WITH SA1->A1_LOJA
REPLACE C5_TIPOCLI WITH SA1->A1_TIPO
REPLACE C5_CONDPAG WITH aPedido[3]
REPLACE C5_TABELA  WITH "1"
REPLACE C5_VEND1   WITH aPedido[4]
REPLACE C5_EMISSAO WITH dDataBase
REPLACE C5_MOEDA   WITH 1
REPLACE C5_LIBEROK WITH "S"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar o percentual de comissao para o vendedor.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(C5_VEND1)
	SA3->(DbSetOrder(1))
	If SA3->( DbSeek( xFilial("SA3")+aPedido[4] ) )
		REPLACE C5_COMIS1 WITH SA3->A3_COMIS
	EndIf
EndIf
MsUnlock()
While (GetSX8Len() > nSaveSx8)
	ConfirmSx8()
End

For nX := 1 to Len(aItens)
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+aItens[nX][1])

	cItem := SomaIt(cITem)
	RecLock("SC6",.T.)
	REPLACE C6_FILIAL  	WITH xFilial("SC6")
	REPLACE C6_NUM      WITH cNumSC5
	REPLACE C6_ITEM    	WITH cItem
	REPLACE C6_PRODUTO 	WITH aItens[nX][1]
	REPLACE C6_UM		WITH SB1->B1_UM
	REPLACE C6_QTDVEN  	WITH aItens[nX][3]
	REPLACE C6_PRCVEN 	WITH aItens[nX][4]
	REPLACE C6_VALOR   	WITH aItens[nX][3] * aItens[nX][4]
	REPLACE C6_TES     	WITH aItens[nX][8]
	REPLACE C6_CF      	WITH Posicione("SF4",1,xFilial("SF4")+aItens[nX][8],"F4_CF")
	REPLACE C6_LOCAL   	WITH aItens[nX][5]
	REPLACE C6_CLI     	WITH SC5->C5_CLIENTE
	REPLACE C6_LOJA    	WITH SC5->C5_LOJACLI
	REPLACE C6_DESCRI  	WITH aItens[nX][2]
	REPLACE C6_ITEMORI 	WITH ""
	REPLACE C6_QTDLIB  	WITH aItens[nX][3]
	REPLACE C6_RESERVA 	WITH aItens[nX][9]
	MaAvalSC6("SC6",1,"SC5",.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)
	MsUnlock()

	aAdd( aRetorno,{aPedido[1],SC6->C6_PRODUTO,cNumSC5} )
Next nX
MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk)

Return (aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjIncMovFinºAutor ³ Vendas Clientes    º Data ³  05/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a movimentacao financeira para pagar a loja da reserva º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp1 - "R"-Recebimento ou "P"-Pagamento                    º±±
±±º          ³nExp2 - Valor da movimentacao                               º±±
±±º          ³cExp2 - Numero do caixa (Banco)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico. Se foi efetuada a transacao                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjIncMovFin(	cRecPag,	nTotMovFin,	cCaixa,	cNatureza,;
						cNomeLoja)

Local aArea 	:= GetArea()

DbSelectArea("SA6")
DbSetOrder(1)
If DbSeek(xFilial("SA6")+cCaixa)
	DbSelectArea("SE5")
	RecLock("SE5",.T.)
	REPLACE SE5->E5_FILIAL 	WITH xFilial("SE5")
	REPLACE SE5->E5_FILORIG	WITH cFilAnt
	REPLACE SE5->E5_DATA	WITH dDataBase
	REPLACE SE5->E5_MOEDA	WITH "M1"
	REPLACE SE5->E5_VALOR	WITH nTotMovFin
	REPLACE SE5->E5_NATUREZ	WITH cNatureza
	REPLACE SE5->E5_BANCO 	WITH cCaixa
	REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
	REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
	REPLACE SE5->E5_VENCTO	WITH dDataBase
	REPLACE SE5->E5_RECPAG	WITH cRecPag
	REPLACE SE5->E5_BENEF	WITH cNomeLoja
	REPLACE SE5->E5_HISTOR 	WITH STR0068 + If(cRecPag=="R",STR0069,STR0070) + cNomeLoja //"TRANSFERENCIA "/" DA LOJA "/" PARA A LOJA "
	REPLACE SE5->E5_DTDIGIT	WITH dDataBase
	REPLACE SE5->E5_RATEIO	WITH "N"
	REPLACE SE5->E5_DTDISPO	WITH dDataBase
	MsUnlock()
EndIf

RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldRes    ºAutor³ Vendas Clientes    º Data ³  04/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao do campo L2_RESERVA                         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVldRes()
Local aArea			:= GetArea()
Local aAreaF4		:= SF4->(GetArea())
Local aAreaC0		:= SC0->(GetArea())
Local lRet			:= .T.
Local nPosProduto	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_PRODUTO" })
Local nPosQuant 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_QUANT" })
Local nPosLocal  	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_LOCAL" })
Local nPosTes		:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_TES" })
Local nPosReserva 	:= aScan(aHeader, {|z| AllTrim(Upper(z[2]))=="L2_RESERVA" })
Local cProduto		:= aCols[n][nPosProduto]
Local cLocal   		:= aCols[n][nPosLocal]
Local cReserva		:= aCols[n][nPosReserva]
Local nPosLay		:= aScan(aHeader, {|z| AllTrim(Upper(Z[2]))=="L2_NUMLAY"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo é o L2_RESERVA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ReadVar() $ "M->L2_RESERVA"  )
	cReserva := &(ReadVar())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para utilizar a reserva o TES deverá movimentar estoque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[n][nPosTes])
	lRet := (SF4->F4_ESTOQUE=="S")
	If !lRet
		Help(" ",1,"A410TEEST")
	EndIf
Else
	lRet := .F.
	Help(" ",1,"A410TEEST")
EndIf

// Validacoes para compatibilização com Lay-Away
If cPaisLoc $ "EUA|POR|MEX"
	If nPosLay > 0 .AND. !(Empty(aCols[n][nPosLay]))
		lRet := .F.
	ElseIf !(SC0->(DbSeek(xFilial("SC0")+cReserva+cProduto+cLocal)))
		lRet := .F.
	ElseIf AllTrim(SC0->C0_TIPO)=="LW"
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a quantidade que foi solicitada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DbSelectArea("SC0")
	DbSetOrder(1)
	If !DbSeek(xFilial("SC0")+cReserva+cProduto+cLocal)
		lRet := .F.
	Else
		nQtdRes := SC0->C0_QUANT - SC0->C0_QTDPED
		If nQtdRes < aCols[n][nPosQuant]
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaC0)
RestArea(aAreaF4)
RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRpcQtdRes ºAutor³ Vendas Clientes    º Data ³ 24/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a quantidade reservada.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRpcQtdRes( cReserva )
Local nRet       := 0

Default cReserva := Space(TamSX3("L2_RESERVA")[1])

DbSelectArea( "SC0" )
DbSetOrder( 1 )
If DbSeek( xFilial( "SC0" ) + cReserva )
	nRet := C0_QUANT
EndIf

Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PesqFormPg³ Autor ³ Vendas Clientes       ³ Data ³ 18/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a forma de pagamento esta inclusa entre as     ³±±
±±³          ³ formas de pagamento validas.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 - Forma que esta sendo verificada.                   ³±±
±±³          ³ ExpA1 - Array com as formas de pgto validas.               ³±±
±±³          ³ ExpA2 - Array com as formas de pgto a serem agregadas as	  ³±±
±±³          ³         formas validas. 	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - .T. forma valida, ou .F. para forma invalida       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FRTA010A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqFormPg(cForma, aSimbs, aSimbsInc)
Local lRet       := .F.
Local cFormaPgto := cForma
Local aSimbsPgto := Aclone(aSimbs)

If  aSimbsInc <> Nil
	AEval(aSimbsInc, {|x,y| AAdd(aSimbsPgto, aSimbsInc[y])})
EndIf

If  Ascan( aSimbsPgto,{|x|  Trim(x) == Trim(cFormaPgto)}) > 0
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FRTProcSZ³ Autor ³  Vendas Clientes      ³ Data ³18/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa os Campos do Server Local.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTProcSZ()
Local aFiles 	:={}
Local i			:= 0
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Para Informar Quais Arquivos Subiram. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTGrvSZ") .AND. !lFtvdVer12
	aFiles := ExecBlock("FRTGrvSZ",.F.,.F.)
EndIf

If ExistBlock("FTFRTGrvSZ") .AND. lFtvdVer12
	aFiles := ExecBlock("FTFRTGrvSZ",.F.,.F.)
EndIf

For i := 1 To Len(aFiles)
	cAlias := aFiles[i][1]
	nOrder := aFiles[i][2]
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	If DbSeek(xFilial(cAlias)+"RX")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. Para Informar Quais Arquivos Subiram. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFtvdVer12
			If ExistBlock("FRTProSZ")
				If ExecBlock("FRTProSZ",.F.,.F.,{cAlias})
					If Left(cAlias, 1) == "S"
						aSZ := {{SubStr(cAlias,2,2)+"_SITUA","OK"}}					// "OK" - Foi Processado Pelo Server
					Else
						aSZ := {{cAlias+"_SITUA","OK"}}					// "OK" - Foi Processado Pelo Server
					EndIf
					FRTGeraSL(cAlias, aSZ, .F.)
				EndIf
			EndIf
		Else
			If ExistBlock("FTFRTProSZ")
				If ExecBlock("FTFRTProSZ",.F.,.F.,{cAlias})
					If Left(cAlias, 1) == "S"
						aSZ := {{SubStr(cAlias,2,2)+"_SITUA","OK"}}					// "OK" - Foi Processado Pelo Server
					Else
						aSZ := {{cAlias+"_SITUA","OK"}}									// "OK" - Foi Processado Pelo Server
					EndIf
					FRTGeraSL(cAlias, aSZ, .F.)
				EndIf
			EndIf
		EndIf

	EndIf
Next i

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CalcPgtºAutor  ³ Vendas Clientes    º Data ³  12/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua o calculo das parcelas da condicao de pagamento      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1:=Lj7CalcPgt(ExpN1,ExpC1,ExpA2,ExpN2,ExpN3,ExpN4,ExpN5)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ExpN1 - Valor a ser parcelado                               º±±
±±º          ³ExpC1 - Condicao - "CN" ou o Codigo da condicao de pagamentoº±±
±±º          ³        (SE4->E4_CODIGO)                                    º±±
±±º          ³ExpA2 - Array contendo os dados da condicao negociada:      º±±
±±º          ³        (Utilizada quando ExpC1 = "CN")                     º±±
±±º          ³        [1] - Tipo juros    1 - Juros simples               º±±
±±º          ³                            2 - Juros compostos             º±±
±±º          ³                            3 - Tabela price                º±±
±±º          ³        [2] - Data entrada                                  º±±
±±º          ³        [3] - Valor entrada                                 º±±
±±º          ³        [4] - Taxa de juros                                 º±±
±±º          ³        [5] - Quantidade de parcelas                        º±±
±±º          ³        [6] - Intervalo entre as parcelas (em dias)         º±±
±±º          ³        [7] - Calcula juros na 1a parcela (.T. or .F.)      º±±
±±º          ³ExpN2 - Valor que devera ser somado ao total da venda mas   º±±
±±º          ³        nao entra no calculo de juros (exemplo Vlr.Frete)   º±±
±±º          ³        Esse parametro eh opcional                          º±±
±±º          ³ExpN3 - Percentual de acrescimo na venda (Localizac1oes)     º±±
±±º          ³ExpN4 - Percentual de desconto financeiro (Localizacoes)    º±±
±±º          ³ExpN5 - Moeda da venda (Localizacoes)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array com as parcelas da venda                      º±±
±±º          ³        [1] - Data de vencimento                            º±±
±±º          ³        [2] - Valor                                         º±±
±±º          ³        [3] - Forma de pagamento                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CalcPgt( nValor		, cCondicao	, aCondNeg	, nVlrSoma	,;
					 nTmpJuros	, nTmpDesc	, nMoeda	, nICMSSol	,;
					 lDiaFixo	, nMoedaCor	, nDecimais , nVlrAcrsFi,;
					 cFomPag	, nValJurDIa, nDiferenca, nOpc      ,;
					 lAltCond   , nValIpi	, lUsoMultN , lIntegra )

Local aArea 		:= GetArea()				// Armazena area atual (alias, order e recno)
Local aRet	 		:= {}						// Array com os dados de retorno da funcao
Local aParcelas		:= {}						// Array com as parcelas de acordo com a condicao de pagto escolhida
Local aParcAcrs		:= {}						// Parcelas com acrescimo
Local aE4 			:= {}						// Array com as condicoes de pagamento no caso do tipo 9
Local aParcDiaFixo  := {}						// Array contendo as parcelas com o dia fixo
Local nValTaxa 		:= 0						// Valor da taxa na tabela Price
Local nDivisor 		:= 0						// Calculo do divisor
Local nParcelas 	:= 0						// Parcelas da condicao de pagamento
Local nPrestacao 	:= 0						// Calculo da prestacao
Local nTipoJuros 	:= 0						// Tipo de juros (simples / compostos / tabela price)
Local nVlrAux		:= 0						// Valor auxiliar para calculo da prestacao
Local nVlrSomaRet	:= 0						// Valor para calculo de arredondamento
Local nTotAux       := 0						// Total auxiliar que sera utilizado na comparacao do nValor
Local nValRatAcrs	:= 0						// Rateio para parcelas
Local cMvSimb1		:= SuperGetMV("MV_SIMB1")	// Simbolo da moeda 1
Local cSimbMoeda    := ""						// Simbolo das moedas utilizadas na venda
Local cE4Cond		:= ""						// Condicao que sera utilizada quando for tipo 3
Local nValorAcrs    := 0						// Valor de acrescimo
Local nX            := 0						// Variavel auxiliar em For...Next
Local nValRat       := 0						// Valor rateado
Local nValTot       := 0						// Valor total
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)	// Verifica as filiais da trabalharam com acrescimento separado
Local lCanAgreg		:= .T.						// Se cancela o acrescimo
Local cMvFiliais	:= SuperGetMV("MV_FILACRS",,"01")   	//Filiais que trabalham com o conceito de acrescimo.
Local nUltDiaFv		:= 0						// Ultimo dia de fevereiro
Local nE4Dias		:= 0						// Dias de intervalo informado no SE4
Local dDataAntE4	:= ""						// Data corrente
Local nJurosPar		:= 0						// valor do juros da parcela
Local lCalcFin		:= (SuperGetMv("MV_CALCFIN",,"M")== "F")  //variavel para controle do parametro MV_CALCFIN = [F]inanciado
Local nVlrFrete		:= 0
Local lFtvdVer12	:= ExistFunc("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") //Nome da Rotina
Local nNfDedIcm		:= 0
Local nICMSolDif	:= 0						// diferenca entre o valor do ICMS Solidario com e sem frete aplicado
Local nDifValSol	:= 0						// diferenca do valor do ICMS Solidario, quando se aplica um acrescimo ou desconto
Local nAcrPest		:= 0						// prestação de acrescimo separado
Local nVlrAcr		:= 0						// Valor de Acrescimo
Local nTotAcrAux	:= 0						// Auxiliar do total de acrescimo separado
Local lLjIcmJr		:= SuperGetMV("MV_LJICMJR",,.F.) .And. cPaisLoc == "BRA" // Incide Icms sobre juros de operações financeiras
Local cMvFormaCN	:= AllTrim(SuperGetMv("MV_LJFORCN",,"  ")) // forma para condição negociada. //
Local dDtbkpDtBase  := dDataBase
Local lMultNegoc    := SuperGetMv("MV_LJMULTN",,.F.)
Local nPosAcr		:= 0 //Posicao do array de acrescimo
Local nVlrAcrInd	:= 0						// valor do acrescimo indevido, pois p/ calculo do acrescimo, nao deve haver nenhum acrescimo (frete,ICMS-ST) 
Local lIsCard		:= (AllTrim(cFomPag) $ "CC|CD")				// Só irá considerar o parametro MV_LJICMJR para formas diferente de cartão (CC e CD)

DEFAULT nVlrSoma 	:= 0						// Valor da soma
DEFAULT nTmpJuros	:= 0						// Armazena o acrescimo financeiro
DEFAULT nTmpDesc 	:= 0						// Armazena o desconto financeiro
DEFAULT nMoeda 	    := 1						// Moeda utilizada
DEFAULT nICMSSol    := 0						// ICMS Solidario
DEFAULT lDiaFixo	:= .F.						// Se existe dia fixo para a condicao de pagamento
DEFAULT nMoedaCor	:= 1
DEFAULT nDecimais	:= MsDecimais(nMoedaCor)
DEFAULT nVlrAcrsFi	:= 0						// variavel para calculo de juros sobre valor financiado
DEFAULT aCondNeg	:= {} 						// Array contendo os dados da condicao negociada - Release 11.5 - Localizacoes
DEFAULT cFomPag		:= ""						// Forma de Pagamento
DEFAULT nValJurDIa 	:= 0						// Valor de Juros ai Dia
DEFAULT nDiferenca 	:= 0						// Valor da diferenca entre o valor de venda e o valor com juros
DEFAULT nOpc		:= 0						// Controla o tipo de Gravação
DEFAULT lAltCond	:= .F.						// Controla o tipo de Gravação
DEFAULT nValIpi		:= 0
DEFAULT lUsoMultN   := .F.
DEFAULT lIntegra	:= .F.

If nValor < 0
	nValor := 0
EndIf

If !lIntegra
	If Type("nNccUsada") <> "N" .AND. nModulo == 23 .AND. ExistFunc("Frt060Ret")
		nNccUsada := Frt060Ret( "NCC_USADA" )
	EndIf

	//se tiver ICMS Solidario, seu valor deve ser recalculado, pois o Frete altera a Base de Calculo
	If MaFisFound("NF") .AND. MaFisRet(Nil, "NF_VALSOL") > 0
		nVlrFrete := Lj7CalcFrete(,.T.,@nICMSolDif) + nICMSolDif
	Else
		nVlrFrete := Lj7CalcFrete()
	EndIf
EndIf

//--------------------------
//Array de retorno aRet
//[1] - Data
//[2] - Forma de pagamento
//[3] - Conteudo MVCHEQUE
//[4] - Array
//[5] - Vazio
//[6] - Moeda
//[7] - DataBase
//[8] - Valor acrescimo
//--------------------------

//---------------------
// Calcula as parcelas
//---------------------
//Condição Negociada
If Len(aCondNeg) > 0

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Faz a validacao do primeiro elemento do array aCondNeg       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If ValType( aCondNeg[1] ) == "C"
        nTipoJuros := Val( Subst( aCondNeg[1] ,1 ,1 ) )
    Else
        nTipoJuros := aCondNeg[1]
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica o tipo de juros que eh para calcular                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cPaisLoc == "BRA"
        nTmpJuros := aCondNeg[4]
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Juros simples³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        // Não incide ICMS sobre operações financeira porem somente qnd qtd de parcelas menor que 13
        lLjIcmJr := lLjIcmJr .And. nParcelas < 13 .And. cMvFormaCN == "FI" .And. !lUsoMultN
        cFomPag	 := If(Empty(cFomPag), AllTrim(cMvFormaCN),cFomPag)

        If nTipoJuros == 1
            //se houver Entrada, ela se torna a 1a parcela
            nParcelas 	:= aCondNeg[5] - If( !Empty( aCondNeg[3] ) ,1 ,0 )

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Calcula o juros sobre o montante (MV_CALCFIN = M)³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If aCondNeg[7]	//Calcula JUROS na 1a Parcela 
                If lLjIcmJr .And. !lIsCard
                    // A variável nVlrAcr, foi tirada neste ponto, pois não estava respeitando a Condição Negociação realizada
                    // Lembrando que o paramêtro MV_LJICMJR, tem a finalidade de incidir ICMS sobre os juros
                    // Porém, a varável nVlrAcr continua sendo calculada					
                    nVlrAcr := (nValor + nValJurDIa) * ( aCondNeg[4] / 100 )
                EndIf
                nVlrAux := (nValor + nValJurDIa)* ( 1 + (aCondNeg[4] / 100 ) )
            Else
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Calcula o juros somente sobre o valor financiado, subtraindo a entrada ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If lLjIcmJr .And. !lIsCard
                    nVlrAcr	:= ( nValor - aCondNeg[3] + nValJurDIa) * ( (aCondNeg[4] / 100 ) )
                EndIf
                // A variável nVlrAcr, foi tirada neste ponto, pois não estava respeitando a Condição Negociação realizada
                // Caso o paramêtro MV_LJICMJR for .F., a variável nVlrAcr não tem atribuido nenhum valor
                // Lembrando que o paramêtro MV_LJICMJR, tem a finalidade de incidir ICMS sobre os juros
                // Porém, a varável nVlrAcr continua sendo calculada
                nVlrAux	:= (( nValor - aCondNeg[3] + nValJurDIa) * ( 1 + (aCondNeg[4] / 100 ) ) + aCondNeg[3] )
            EndIf
            //
            nPrestacao 	:= ( nVlrAux - aCondNeg[3] ) / nParcelas
            nAcrPest	:= nVlrAcr / nParcelas

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Armazena o valor do acrescimo financeiro total³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If (lCalcFin .OR. !lLjICMJr) .AND. ((nVlrAux + nVlrAcr) > nValor)
                nVlrAcrsFi := (nVlrAux + nVlrAcr) - nValor
            EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Juros compostos³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        ElseIf nTipoJuros == 2
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Calcula o juros sobre o montante (MV_CALCFIN = M)³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If aCondNeg[7]
                nVlrAux 	:= (nValor + nValJurDIa)* ( ( 1 + ( aCondNeg[4] / 100 ) ) ^ aCondNeg[5] )
            Else
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Calcula o juros somente sobre o valor financiado, subtraindo a entrada ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                nParcelas 	:= aCondNeg[5] - If( Empty( aCondNeg[3] ) ,0 ,1 )
                nVlrAux 	:= ( nValor - aCondNeg[3] + nValJurDIa ) * ( ( 1 + ( aCondNeg[4] / 100 ) ) ^ nParcelas ) + aCondNeg[3]
            EndIf
            nParcelas 	:= aCondNeg[5] - If( !Empty( aCondNeg[3] ) ,1 ,0 )
            nPrestacao 	:= ( nVlrAux - aCondNeg[3] ) / nParcelas

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Tabela price³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
        ElseIf nTipoJuros == 3

            nValTaxa 	:= aCondNeg[4] / 100
            nParcelas 	:= aCondNeg[5] - If( aCondNeg[5] == 1 ,0 ,If( Empty( aCondNeg[3] ) ,0 ,1 ) )
            nDivisor 	:= (1 + nValTaxa) ^ nParcelas

            nPrestacao 	:= ( nValor - aCondNeg[3] ) * ( ( nDivisor * nValTaxa ) / ( nDivisor - 1 ) )
            nVlrAux := ((Round(nPrestacao,2) * nParcelas) + aCondNeg[3])

            // Desconsidera o acrescimo se o parametro estiver ligado,
            // assim o acrescimo soh saira na SE1.

            If lLjIcmJr  .And. !lIsCard .AND. !IsInCallStack( "LJ76TELNEG") //RBM
                nVlrAcr := nVlrAux -  nValor
            EndIf

            nAcrPest	:= nVlrAcr / nParcelas

        EndIf

    Else
        nVlrAux := nValor
        //"Fazendo o calculo do acrescimo/desconto e o recalculo dos impostos..."
        If cPaisLoc == "MEX"
            // Sem arroba no nVlrAux, pois precisamos do valor sem subtração para incluir os juros abaixo
            // Dentro da função é retirado o IVA, calcula os juros e depois o IVA é embutido novamente
            LJMsgRun(STR0081,,{|| LjxDRecVB(nVlrAux,aCondNeg[4],0,0,nVlrAux,0,nTipoJuros,aCondNeg[5],aCondNeg[3],aCondNeg[7])})
        Else
            LJMsgRun(STR0081,,{|| nVlrAux += LjxDRecVB(@nVlrAux,aCondNeg[4],0,0,@nVlrAux,0,nTipoJuros,aCondNeg[5],aCondNeg[3],aCondNeg[7])})
        EndIf
        nTmpJuros := aCondNeg[4]
        nVlrAux   += ( aDadosJur[1] - aDadosJur[9] )
        nParcelas := ( aCondNeg[5] - If( !Empty( aCondNeg[3] ) ,1 ,0 ) )
        nPrestacao:= ( nVlrAux - aCondNeg[3] ) / nParcelas
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Alimenta o array de retorno ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !Empty( aCondNeg[3] )
        nTotAux += Round( aCondNeg[3], nDecimais )
        aAdd( aRet, { dDataBase, Round(aCondNeg[3], nDecimais), (IIF (Empty(cFomPag), MVCHEQUE, cFomPag )), {}, NIL, nMoedaCor, dDatabase, 0 } )
    EndIf

    For nX := 1 to nParcelas
        //
        nTotAux += Round( nPrestacao , nDecimais )
        nTotAcrAux += Round( nAcrPest, nDecimais )
        aAdd( aRet, { dDataBase, Round( nPrestacao, nDecimais ), (IIF (Empty(cFomPag), MVCHEQUE, cFomPag )), {}, NIL, nMoedaCor, dDatabase, Round( nAcrPest, nDecimais ) } )
    next nX

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Faz o rateio do valor a somar na venda                       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nVlrSoma > 0
        For nX := 1 to Len( aRet )
            aRet[nX][2] += NoRound( nVlrSoma / Len( aRet ), nDecimais )
        Next nX
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Faz o arredondamento se necessario                           ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cPaisLoc == "BRA"
        nVlrSomaRet := 0
        nAcrSomaRet := 0 //
        aEval( aRet, { |x| nVlrSomaRet += x[2] } )
        aEval( aRet, { |x| nAcrSomaRet += x[8] } )
        If aCondNeg[4] == 0
            aRet[Len(aRet)][2] += ( nValor + nVlrSoma - nVlrSomaRet )
        Else
            If nTipoJuros == 1 .OR. nTipoJuros == 2 .OR. nTipoJuros == 3
                If lLjIcmJr
                    aRet[Len(aRet)][2] += ( nVlrAux + nVlrSoma - nVlrSomaRet )
                    aRet[Len(aRet)][8] += ( nVlrAcr - nAcrSomaRet )
                Else
                    aTail(aRet)[2] += ( nVlrAux + nVlrSoma - nVlrSomaRet )
                EndIf
            EndIf
        EndIf
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta as datas das parcelas e a forma de pagto se for a vista³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len( aRet )
		aRet[nX][1] := aCondNeg[2] + ( ( nX-1 ) * aCondNeg[6] )
		If nX == 1 .AND. aRet[nX][1] == dDatabase
			If Empty(cFomPag) .Or. aCondNeg[3] > 0 //
			   If nMoeda == 1
				  aRet[nX][3] := cMvSimb1
			   Else
			      cSimbMoeda  := SuperGetMV( "MV_SIMB" + Str( nMoeda,1 ) )
			      aRet[nX][3]  := cSimbMoeda
			   EndIf
			Else
				aRet[nX][3] := cFomPag
			EndIf
		EndIf
	Next nX

	If lDiaFixo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de uso da opção Dia Fixo para vencimento das parcelas,   ³
		//³a variável nIntervalo é utilizada para armazenar o dia escolhido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataBase := aCondNeg[2]
		cE4Cond:= Str( Len( aRet ) ) + ',0,' + Str( aCondNeg[6] )
		aE4 := {,cE4Cond, "3"," "," "," "}
		aParcDiaFixo := AvalCond( nVlrAux , , , , nICMSSol,,aE4,nValorAcrs,aE4, ,{0,aCondNeg[6]} )
		For nX:=1 to Len( aRet )
			If nX <= Len(aParcDiaFixo)
				aRet[nX][1] := aParcDiaFixo[nX][1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Há uma exceção para o mês de Fevereiro em anos não bissextos: Se a venda for               ³
				//³efetuada no dia 31, a data do vencimento deverá cair no dia 1º de março e não no dia 28/02.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Month( aRet[nX][1] ) == 2 .AND. aCondNeg[6] == 31 .AND. !AnoBissexto( Year(aRet[nX][1]) )
					aRet[nX][1] := Ctod( '01/03/' + Str( Year( aRet[nX][1] ) ) )
				EndIf
			EndIf
		Next nX
		If lMultNegoc .And. IsInCallStack( "LJ76TELNEG")
			dDatabase := dDtbkpDtBase //Volto a DataBase origem
		EndIf
	EndIf

//Condição de Pagamento
Else
	DbSelectArea( "SE4" )
	SE4->( DbSetOrder(1) )	//E4_FILIAL+E4_CODIGO
	If 	SE4->( DbSeek(xFilial( "SE4" ) + cCondicao) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o caso do tipo da condicao de pagamento ser 9, a funcao Condicao acessa as datas e as ³
		//³parcelas do SC5, que nao sao utilizadas pelo loja.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE4->E4_TIPO == "9"
			MsgAlert( STR0150 )		//"A condição de pagamento do tipo 9 é de uso exclusivo do faturamento."
			Lj7ZeraPgtos()
			aRet := {}
			Return aRet
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o caso do tipo da condicao de pagamento ser A, que não gera titulos e deve ser utilizada³
		//³exclusivamente nos ambientes Veículos "SIGAVEI" e Oficinas "SIGAOFI"                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE4->E4_TIPO == "A"
			MsgAlert( STR0151 )		//"A condição de pagamento do tipo A é de uso exclusivo dos ambientes de veículos e oficinas."
			Lj7ZeraPgtos()
			aRet := {}
			Return aRet
		EndIf

		//Se houver frete/seguro/despesa, nValor vem com ICMS-ST somado,
		//por isso o subtraimos, ja que para calcular o acrescimo, nao deve haver nenhum tipo de acrescimo no item
		If nVlrFrete == 0
			nVlrAcrInd := nICMSSol
		EndIf

		nVlrAux := nValor

		If cPaisLoc == "BRA"
			nVlrAux := Lj7E4DscFi(@nValor, nOpc, lAltCond) //Verifica se SE4->E4_DESCFIN > 0
			If SE4->E4_ACRSFIN > 0

				//Para calculo do acrescimo o frete nao deve ser considerado
				If nValor <>  0
					nValor := nValor + nVlrSoma - nVlrFrete
				EndIf

				nTmpJuros := SE4->E4_ACRSFIN
				nValorAcrs 	:= nValor

				If lFtvdVer12
					nNfDedIcm := LjVDItDedIcm()
					If nNfDedIcm > 0
						nValor    += nNfDedIcm
						nNfDedIcm := NoRound( ( nNfDedIcm + (nNfDedIcm *( SE4->E4_ACRSFIN / 100 )) ), nDecimais)
						nVlrAux   := NoRound( ( nValor + ( nValor *( SE4->E4_ACRSFIN / 100 )) ), nDecimais)
						nVlrAux	  := nVlrAux - nNfDedIcm
  					Else
  						nVlrAux := NoRound( nValor + A410Arred( nValor *( SE4->E4_ACRSFIN / 100 ), "D2_VALACRS"), nDecimais)
					EndIf
				Else				 	
					nVlrAux := NoRound( nValor + A410Arred( (nValor-nVlrAcrInd) * (SE4->E4_ACRSFIN / 100), "D2_VALACRS"), nDecimais )
				EndIf
				nValorAcrs 	:= nVlrAux - nValorAcrs
				nVlrAcrsFi	:= nValorAcrs

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o campo de agregar o acrescimo na parcela esta ativo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (lVerEmpres .AND. (cFilAnt $ cMvFiliais)) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
					If (SE4->(FieldPos("E4_AGRACRS")) > 0)
						If SE4->E4_AGRACRS == "2"
							lCanAgreg	:= .F.
							nVlrAux		:= nValor
						EndIf
					EndIf
	            EndIf
			EndIf
        Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acrescimos e Descontos financeiros em Localizacoes,     ³
			//³devem ser calculados sobre o Total da Venda com Imposto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE4->E4_DESCFIN > 0
				nVlrAux := NoRound( nValor * ( 1 - ( SE4->E4_DESCFIN / 100 ) ), nDecimais )
			ElseIf SE4->E4_ACRSFIN > 0
				nValorAcrs := nValor
				nVlrAux := NoRound( nValor * ( 1 + ( SE4->E4_ACRSFIN / 100 ) ), nDecimais )
				nValorAcrs := nVlrAux - nValorAcrs
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o campo de agregar o acrescimo na parcela esta ativo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (lVerEmpres .AND. (cFilAnt $ cMvFiliais)) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
					If (SE4->(FieldPos("E4_AGRACRS")) > 0)
						If SE4->E4_AGRACRS == "2"
							lCanAgreg	:= .F.
							nVlrAux		:= nValor
						EndIf
					EndIf
				EndIf
	  		Else
	  			If !lIntegra .And. FunName() == cNomeProg .AND. ( aDadosJur[01] <> 0 .OR. aDadosJur[09] <> 0 )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acerta o valor base para o calculo das parcelas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   			nVlrAux      := aDadosJur[02]
                    nValor       := aDadosJur[02]

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Os pagamentos são zerados para que seja realizado o recalculo dos impostos variáveis...³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  				Lj7ZeraPgtos()
	  				M->LQ_CONDPG := cCondicao
					cDescCondPg	 := Posicione( "SE4", 1, xFilial( "SE4" ) + M->LQ_CONDPG, "SE4->E4_DESCRI" )
					cCondSE4     := M->LQ_CONDPG
					oCondPg:Refresh()
					oDescCondPg:Refresh()
	  			EndIf
	  		EndIf
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizar o conceito de "JUNTA, SEPARA e NORMAL" dos tipos de acrescimo³
		//³caso o campo E4_ACRES seja criado como campo de usuario na base.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE4->( FieldPos("E4_ACRES") ) > 0
			//Se a venda possui Acrescimo + ICMS Solidario, utilizamos o retorno da MatxFis para calcular o aParcelas,
			// pois o acrescimo altera a Base de Calculo, o que provoca o aumento no total da venda
			If nICMSSol > 0 .AND. nValorAcrs > 0 .AND. MaFisFound("NF")
				nDifValSol := MaFisRet(,"NF_DESCONTO") - NoRound(A410Arred( (nValor-nVlrAcrInd) * (SE4->E4_ACRSFIN/100), "D2_VALACRS"), nDecimais )
				nDifValSol := LjDifVlSol( "NF_DESCONTO", nDifValSol )
				nVlrAux += nDifValSol
			EndIf

			If nValorAcrs > 0
				If SE4->E4_ACRES $ "N "
					aParcelas := Condicao( nVlrAux + nVlrFrete , cCondicao, nValIpi, , nICMSSol, , ,nValorAcrs )
				Else
					aParcelas := Condicao( nVlrAux - nValorAcrs, cCondicao, nValIpi, , nICMSSol, , , )
				EndIf
			Else
				aParcelas := Condicao( nVlrAux + nVlrSoma, cCondicao, nValIpi, , nICMSSol, , ,nValorAcrs )
			EndIf

			If nValorAcrs > 0
				If SE4->E4_ACRES $ "JN "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³tratamento para calculo de juros sobre valor financiado³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCalcFin .AND. Len( aParcelas ) > 0
						nJurosPar 	:= nValorAcrs /  Len( aParcelas )
						For nX := 1 to Len( aParcelas )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se for encontrada parcela com vencimento igual data base, e considerada como entrada³
							//³e subtrai o juros proporcional                                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If aParcelas[nX][1] = dDatabase
								If SE4->E4_ACRES <> "J"
									aParcelas[nX][2] -= nJurosPar
								EndIf
								nValorAcrs 	-= nJurosPar
								nVlrAux		-= nJurosPar
							EndIf
						Next nX
						nVlrAcrsFi := nValorAcrs
					EndIf
					If SE4->E4_ACRES == "J"
						aParcelas[1][2] += nValorAcrs
					EndIf

				ElseIf SE4->E4_ACRES == "S"
					aEval( aParcelas,{ |ExpA1,nCntFor| nValRat += If( nCntFor == 1, 0, ExpA1[2] ) } )
					aEval( aParcelas,{ |ExpA1,nCntFor| nValTot += ExpA1[2] } )

					For nX := 1 to Len( aParcelas )
						If nX == 1
							aParcelas[nX][2] := nValorAcrs
						Else
							aParcelas[nX][2] := NoRound( nValTot * ( aParcelas[nX][2] / nValRat ), nDecimais )
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se trabalha com conceito de acrescimo separado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((lVerEmpres .AND. (cFilAnt $ cMvFiliais)) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")) .AND. ;
			SL4->(FieldPos("L4_ACRSFIN")) > 0
				/*Incluída validação para caso seja NCC, não adiciona Valor do Frete no aRetPgto*/
				If nNCCUsada > 0
					aParcelas := Condicao( nVlrAux, cCondicao, nValIpi, , nICMSSol, , ,nValorAcrs)
				Else
					aParcelas := Condicao( nVlrAux + nVlrFrete, cCondicao, nValIpi, , nICMSSol, , ,nValorAcrs)
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula os valores dos acrescimos rateados por parcela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aParcAcrs := Condicao( nValorAcrs, cCondicao)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o ajuste dos valores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValRat := 0
		aEval( aParcelas,{ |ExpA1,nCntFor| nValRat += ExpA1[2]} )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso haja diferenca em centavos, rateio entre as parcelas, seja diferenca maior ou menor  ³
		//³Se a diferenca for maior ou menor, subtraio a diferenca na ultima parcela                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValRat := Round( nValRat, nDecimais )
		If nValRat < nVlrAux
			nX      := Len( aParcelas )
			While nValRat < nVlrAux .AND. nX > 0
				aParcelas[nX][2]	+= ( 1 / ( 10 ^ nDecimais ) )
				nValRat				+= ( 1 / ( 10 ^ nDecimais ) )
				nX					-= 1
				If nX == 0
					nX := Len( aParcelas )
				EndIf
			End
		ElseIf nValRat > nVlrAux + nVlrSoma .AND. nVlrAux > 0 .AND. nICMSSol == 0
			nX      := Len( aParcelas )
			While nValRat > nVlrAux + nVlrSoma .AND. nX > 0
				aParcelas[nX][2]	-= ( 1 / ( 10 ^ nDecimais ) )
				nValRat				-= ( 1 / ( 10 ^ nDecimais ) )
				nX					-= 1
				If nX == 0
					nX := Len( aParcelas )
				EndIf
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se trabalha com conceito de acrescimo separado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((lVerEmpres .AND. (cFilAnt $ cMvFiliais)) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")) .AND. ;
			SL4->(FieldPos("L4_ACRSFIN")) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o valor total do acrescimo para realizar o rateio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValRatAcrs := 0
			aEval( aParcAcrs,{ |ExpA1,nCntFor| nValRatAcrs += ExpA1[2]} )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso haja diferenca em centavos, rateio entre as parcelas, seja diferenca maior ou menor  ³
			//³Se a diferenca for maior ou menor, subtraio a diferenca na ultima parcela                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValRatAcrs := Round(nValRatAcrs,nDecimais)
			If nValRatAcrs < nValorAcrs
				nX      := Len(aParcAcrs)
				While nValRatAcrs < nValorAcrs
					aParcAcrs[nX][2]	+= (1/(10^nDecimais))
					nValRatAcrs			+= (1/(10^nDecimais))
					nX               	-= 1
					If nX == 0
						nX := Len(aParcAcrs)
					EndIf
				End
			ElseIf nValRatAcrs > nValorAcrs
				nX      := Len(aParcAcrs)
				While nValRatAcrs > nValorAcrs
					aParcAcrs[nX][2]	-= (1/(10^nDecimais))
					nValRatAcrs			-= (1/(10^nDecimais))
					nX					-= 1
					If nX == 0
						nX := Len(aParcAcrs)
					EndIf
				End
			EndIf
	    EndIf

        For nX := 1 to Len( aParcelas )
        	nTotAux += Round( aParcelas[nx][2], nDecimais )

		    nPosAcr := 0
		    
		    If !lCanAgreg .and. !Empty(aParcAcrs)
		    	nPosAcr := AScan( aParcAcrs, { |x| x[1] == aParcelas[nX][1]})
		    EndIf
		    
		    
			aAdd( aRet, { aParcelas[nX][1],;
			               Round( aParcelas[nX][2], nDecimais ),;
						   If( Trim( SE4->E4_FORMA ) $ cMvSimb1 .AND. aParcelas[nX][1] <> dDataBase, MVCHEQUE,;
			               If( !Empty( SE4->E4_FORMA ), SE4->E4_FORMA,;
			               If(aParcelas[nX][1]<>dDataBase,MVCHEQUE,cMvSimb1))),;
			               {},;
			               NIL,;
			               nMoedaCor,;
			               If(cPaisLoc <> "BRA",aParcelas[nX][1],dDatabase),;
			               If(lCanAgreg, 0,If(nPosAcr > 0,Round(aParcAcrs[nPosAcr][2],nDecimais),0))})
		    
		    If cPaisLoc <> "BRA"  //Busca o simbolo da moeda correspondente da venda
		       If IsMoney( aRet[nX][3] ) .AND. nMoeda > 1
		          cSimbMoeda	:= SuperGetMV( "MV_SIMB" + Str( nMoeda,1 ) )
		          aRet[nX][3]	:= cSimbMoeda
		       EndIf

		       If (cPaisLoc $ "EUA|POR|MEX") .AND. If( Type( "lLayAway" ) # "U", lLayAway, .F. )
		          aRet[nX][3]  := "NF"
		       EndIf
		    EndIf
        Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento especial para Tipo 3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE4->E4_TIPO == "3" .AND. SuperGetMv("MV_CNDTP3",.F.,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza o recalcula do vencimento das datas devido ³
			//³ao mes de fevereiro                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Month(ddatabase) == 1  .AND. ( Day(dDataBase) >= 30 .AND.  Day(dDataBase) <= 31 ) )  .OR. ;
				( Month(ddatabase) == 2 .AND. ( Day(dDataBase) >= 1 .AND.  Day(dDataBase) <= 29 ) )

				cE4Cond := AllTrim(SubStr(E4_COND,at(",",E4_COND)+1))
				nE4Dias := Val( AllTrim(SubStr(cE4Cond,1,(at(",",cE4Cond)-1))) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se eh ano Bissexto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AnoBissexto( Year(dDataBase))
					nUltDiaFv := 29
				Else
					nUltDiaFv := 28
				EndIf

				If ( nE4Dias == nUltDiaFv .OR. nE4Dias == 30 .OR. nE4Dias == 31 ) .AND. SubStr(cE4Cond,Len(cE4Cond)-1) == ",0"

					dDataAntE4 := dDataBase
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza das datas do vencimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 to Len(aRet)
						dDataAntE4 := dDataAntE4 + nE4Dias
						aRet[nX][1] := dDataAntE4
					Next nX
			    EndIf
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Entrada do financiamento e FI       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SuperGetMv("MV_ENTFIN",,.F.) == .F.)
	For nX := 1 to Len(aRet)
		If Alltrim(aRet[nX][3]) == "FI" .AND. aRet[nX][1] = dDatabase
			aRet[nX][3] := AllTrim(SuperGetMv("MV_SIMB1"))
		EndIf
	Next nX
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acerta o total das parcelas conforme o total da venda...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA" .AND. !Empty( aRet )
	 If ( cCondicao <> "CN" .AND. SE4->E4_DESCFIN == 0 .AND. SE4->E4_ACRSFIN == 0 ) .OR.;
	    ( cCondicao == "CN" .AND. aCondNeg[5] == 0 )
		If (nValor + nVlrSoma) <> nTotAux
	    	aRet[Len( aRet )][2] += ( (nValor + nVlrSoma) - nTotAux )
	    EndIf
	 Else
		If (nVlrAux + nVlrSoma) <> nTotAux
	    	aRet[Len( aRet )][2] += ( (nVlrAux + nVlrSoma) - nTotAux )
	    EndIf
	 EndIf
EndIf

nDiferenca := 0
If nVlrAux > 0
	nDiferenca := nVlrAux - nValor + nDifValSol
EndIf

RestArea( aArea )

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³LJGrvFin  ³Autor  ³ Vendas Clientes    ³ Data ³  25/09/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Faz a gravacao dos arquivos do financeiro. Essa funcao foi  ³±±
±±³          ³extraida da funcao LJGRVTUDO para se tornar uma funcao      ³±±
±±³          ³generica.                                                   ³±±
±±³          ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrvFin(	_lScreen  , lFinanceiro	, nNccUsada, 	aNccItens	,;
                  	nNccGerada, aVendedor  	, aReceb   , 	aRecSE1  	,;
                  	nValPIS   , nValCSLL   	, nValCOFI , 	nBaseDup 	,;
                  	aImpCheque, nMoedaCor  	, lOriFun  , 	aNewNCC  	,;
                  	lLstPresC , nBasePIS   	, nBaseCOFI, 	nBaseCSLL	,;
                  	cL1Serie  , lIsVendaVP 	, cB1M996  , 	nValINSS 	,;
                  	nValIRRF  , nBaseINSS  	, nBaseIRRF,	lIsVdRecCP 	,;
                  	nArredondar	, nOpc 		, aRecnoFin, 	lTefNsuDigit,;
					nVFunrural	, cDescErro , lNFePDV  )
Local i
Local nI																	// Contador
Local nVend			:= 0													// Contador de Vendedores (para processar aVendedor)
Local lCxEstrang                											// Identifica se é utilizado um caixa padrao ou não - Localizações
Local nPCH			:= 0													// Controle da numeracao das parcelas de Cheque (CH) SE1 e SEF
Local c1DUP 		:= SuperGetMV("MV_1DUP") 								// Sequência das parcelas "1" = 1..9;A..Z;a..z    e   "A" = A..Z
Local nPFI			:= 0													// Controle da numeracao das parcelas de Financiamento (FI) SE1
Local cCodCliFin															// Codigo do Cliente/Financiadora - Para titulos do tipo FI (Financiamento)
Local cCliFin																// Nome do Cliente/Financiadora - Para titulos do tipo FI (Financiamento)
Local cLojaFin																// Loja do Cliente
Local nPerJur 		:= SuperGetMV("MV_TXPER")								// Parametros MV_TXPER
Local nPVA			:= 0													// Controle de numeracao das parcelas de Vale (VA) SE1
Local nPVP			:= 0													// Controle de numeracao das parcelas de Vale Presente (VP)
Local nPCC			:= 0													// Controle de numeracao das parcelas de Cartao de Credito (CC) SE1
Local nPCD			:= 0													// Controle de numeracao das parcelas de Cartao de Debito (CD) SE1
Local nPCO			:= 0													// Controle de numeracao das parcelas de Convenio (CO) SE1
Local nPDI      	:= 0													// Controle de numeracao das parcelas de Dinheiro SE1 - Localizacoes
Local nPPD			:= 0													// Controle de numeracao das parcelas de Pagamento Digital (PD) SE1 // Incluso PIX
Local nMoedaBco		:= 1													// Moeda do Banco vigente para gravaçao no SE5 - Localizações
Local nRndBco		:= 1													// Casas decimais do Banco vigente para gravaçao no SE5 - Localizações
Local nPOU			:= 0													// Controle de numeracao das parcelas de Outros SE1
Local aRegSE1 		:= {} 													// Matriz para acumulo do registros do SE1 para gerar comissao online.
Local lLJGrvBatch 	:= IsInCallStack("LJGRVBATCH") 							//verifica se a origem da chamada é Grava batch 
Local cOrigem 		:= Iif(nModulo == 12 .Or. lLJGrvBatch,"LOJA701",Iif(FunName() == "RPC","LOJA010",FunName()))// Origem
Local aAreaSA6      := {}													// Area do SA6
Local cL1Doc		:= ""													// Documento do SL1
Local cMvLjPref		:= SuperGetMV("MV_LJPREF")								// Regra para gravacao do SF2->F2_PREFIXO
Local cPrefE1		:= ""													// elemento que sera utilizado como SE1->E1_PREFIXO, na busca do titulo
Local cNumE1		:= ""													// elemento que sera utilizado como SE1->E1_NUM, na busca do titulo
Local nRndMoed1 	:= MsDecimais(1)										// Arredondamento para localizacoes
Local cDocCred      := ""													// Documento Credito
Local nRecnoSE1     := 0													// Recno do SE1
Local cContaCx      := ""													// Caixa
Local cAgenciaCx    := ""													// Agencia
Local nImpostos     := 0													// Impostos
Local nRestPIS      := 0													// PIS
Local nRestCSLL     := 0													// CSLL
Local nRestCOFI     := 0													// Cofins
Local nRestINSS     := 0													// INSS
Local lFirstDupRec  := .T.													// Controle para recebimento de duplicatas
Local nTotAbat      := 0													// Total abatimento
Local cParcelaAbat  := ""													// Parcela abatimento
Local cMV_FORMCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI")  					// Formas de pagamento que devem ter analise de credito - SIGACRD
Local aAliasSE1     := {}													// Alias SE1
Local aDadosFin     := {}                              						// Array com as parcelas da venda, integracao SIGACRD
Local lpTPAbISS     := ( SuperGetMV("MV_TPABISS", NIL, "1") == "2" )		// GetMv do MV_TPABISS
Local nTotNFISS     := 0													// Total NF ISS
Local nRestISS      := 0													// RestISS
Local nLoopParc     := 0													// Total de parcelas
Local nRestDiv      := 0													// Resto da divisao
Local cSeek         := ""													// Variavel de busca
Local lAltParcela   := .T.													// Altera parcela
Local nTotNFIRRF	:= 0 													// Total Nf IRRF
Local nRestIRRF		:= 0													// Resto do IRRF
Local nDecimal		:= TamSX3("E1_BASCOM1")[2] 								// N@ de decimais considerados no calculo
Local nPosImpCheque := 0                       								// Posicao da parcela no array aImpCheque para gravar o campo EF_IMPRESS
Local nTamCodSAE    := TamSx3("AE_COD")[1]    								// Tamanho do campo AE_COD
Local nTamE1_PREFIXO:= TamSX3("E1_PREFIXO")[01]								// Tamanho do campo E1_PREFIXO
Local nTamE1_PARCELA:= TamSX3("E1_PARCELA")[01]								// Tamanho do campo E1_PARCELA
Local nTamA6_AGENCIA:= TamSX3("A6_AGENCIA")[1]								// Tamanho do campo A6_AGENCIA
Local l040duprec 	:= .T.					   								// Controle para so gerar contador da compra na primeira vez na A040DupRec
Local nContaParc	:= 1					   								// Contador para numero de parcelas
Local lUsaSPB		:= SpbInUse() .AND. (SE1->(ColumnPos("E1_MODSPB")) > 0)	// Controle para uso do SPB
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)								// Verifica as filiais da trabalharam com acrescimento separado
Local aRegNomE1		:= {}													// Array com as informacoes do titulo
Local nX			:= 0													// Contador
Local lNotFinPro	:= .F.													// Verifica se pode incluir informacoes no aRegNomE1
Local nTamSx3A1		:= TamSx3("A1_COD")[1]									// Tamanho do A1_COD
Local cMvFiliais	:= SuperGetMV("MV_FILACRS",,"01")   					// Filiais que trabalham com o conceito de acrescimo.
Local cNumOrc		:= SL1->L1_NUM									    	// Numero do Orcamento
Local lScreen		:= If(_lScreen == NIL, .T.,_lScreen)  					// Verifica se exibe as mensagens na tela ou com conout
Local lAdmin		:= .F.													// Utilizada para quebrar ou nao o Titulo por Administradora.
Local aBkpRcb       := aClone(aReceb)										// Backup do Array aReceb, para restauracao apos criacao dos Titulos de Contas a Pagar.
Local cParcela		:= PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA)			// Variavel utilizada para definicao da Parcela do Contas a Receber
Local nPosDin		:= 0													// Posicao do Dinheiro, dentro do Array 'aReceb'
Local cMvSimb1		:= SuperGetMV("MV_SIMB1")								// Simbolo da Moeda 1 do Sistema
Local lAglutina     := .F.													// Controla se aglutina os titulos ou nao, DEFAULT nao aglutina
Local aRetTp		:= {}													// Retorno da Funcao LjGrvTpFin, aglutina e financeira propria
Local lAdmProp		:= .F.													// Retorna se a administradora e' propria
Local cWhileSE1		:= ""													// Variavel de busca no SE1
Local aBaixas		:= {}													// Array utilizado para o calculo das comissoes
Local aBaixasTmp    := {}                                                   // Array utilizado para o calculo das comissoes
Local nScanBx       := 0
Local nComis		:= 0										 			// Valor da comissao para o item
Local nPos			:= 0													// Auxiliar para posicionamento do vetor aVendedor
Local aLista		:= {}
Local lRetLJTES     :=.T.													// Lista de verificação de valores
Local aFinProp      := {}                                                  	// Array para armazenar se a administradora financeira tem financiamento proprio
Local lAtuSalDup    := .T. 													// Controla se atualiza o saldo de duplicatas
Local lAbatOrc		:= .F.
Local lPedido		:= .F.													// Controla se a venda tem pedido
Local lRet			:= .T.													// Retorno Logico
Local lGvr          := .T.
Local aAreaSE1      := {}                                                  	// Area do SE1 para recuperar na atualizacao do Contas a Receber
Local lUsaVP		:= SuperGetMV("MV_LJVALEP",,.F.)  						// Utiliza Vale Presente
Local cNatureza		:= ""													// Natureza da operacao
Local nBaseCom		:= 0													// Base da comissao
Local lGerInt      	:= SuperGetMV("MV_LJGRINT",.F.,.F.)						// Verifica se a integracao esta habilitada
Local nMVLjCpNCC	:= SuperGetMV("MV_LJCPNCC",,1)							//Tratamento para compensacao de NCC //Tratamento para compensacao de NCC 1=Compensa em uma nova NCC; 2=Abate o saldo mesma NCC;3=Consome o Saldo da NCC; 4=Devolve o troco da NCC em dinheiro
Local lComisCR      := SuperGetMv("MV_COMISCR",,"N") == "S"
Local lComiDev		:= SuperGetMV("MV_COMIDEV",,.F.)
Local lComFILJ      := SuperGetMV("MV_LJFICOM",,"N") == "S"
Local aDescNCC      := {}                                                  	// Ricardo - ItensNCC
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.)						// Indica se a integracao com o cenario de vendas esta ativa
Local lGeraTaxa 	:= SuperGetMV("MV_LJGERTX",,.F.)   						// Verifica se ira gerar um Contas a Pagar quando existir taxa na admistradora do cartao.
Local aVetorSE2 	:= {}                                  					// Array para inclusao do contas a pagar via execauto
Local cNumSA2		:= ""							   						// Numero do fornecedor (SE2)
Local lCtaCorren	:= .F. 													// Indica se utiliza a funciolidade de conta corrente. **
Local cNatCCor		:= "" 													// Natureza referente a Conta Corrente  **
Local lGrvMEP       := .F.                                   				//Verifica se está sendo utilizada a tabela de parcelamentos SITEF
Local nParcMEP		:= 0                                                    //Parcela SITEF
Local nTamParTEF    := 0													//Tamanho do Campo Parcela SITEF
Local aCampMEP      := {}                                                   //Array para retornar o tamanho do campo MEP_PARTEF
Local nValAdm		:= 0													// Valor Calculado do Juros por Administradora calculado por MEN_TAXADM.
Local nValTaxAdm    := 0													// Variável com cáluclo da taxa das parcelas.
Local nArreAux 		:= 0
Local nParTx		:= 0
Local lUltParc		:= .F.	
//³Release 11.5 - Cartao Fidelidade³
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()	//Indica se a recarga de cartao fidelidade esta ativa
Local nPFID			:= 0											// Controle de numeracao das parcelas de Cartao Fidelidade (FID)
Local nPBOL			:= 0											// Controle de numeracao das parcelas de Boleto (BOL)
Local cHist         := ""											// Historico do cheque recebido
Local nIHist		:= 0											// Contador Historico
Local cFormaAnt		:= ""											// Utilizada para quebra das Formas de Pagamento
Local lFtvdVer12	:= LjFTVD()		 								//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lPedidoVD		:= lFtvdVer12 .And. IsInCallStack("LJ7PEDIDO")
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701")			//Nome da Rotina
Local lRetFTVDTES	:= .T.											// Lista de verificação de valores
Local lAbateISS 	:= .F.
Local cFilSAE		:= xFilial("SAE")					   			// Filial da tabela SAE
Local lRpcIss		:= .F.
Local lCliRecIss	:= Iif(ExistFunc('lj7RecISS'),Lj7recIss(), GetNewPar("MV_DESCISS",.F.) .And. SA1->A1_RECISS == "1")
Local cRecIss		:= ""
Local aBAKReceb		:= {}
Local nQtdCC		:= 0
Local nQtdCD		:= 0
//³Tratamento para eCommerce       ³
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .And. (SL1->L1_ECFLAG == "1")
Local lE1Seek		:= .T. 									//Verifica se posicionou no SE1 corretamente
Local aVetorSE5 	:= {}                                  	// Array para baixa de titulo do tipo "VP" via execauto
Local cMV_A1M996	:= GetNewPar("MV_A1M996", "") 			//Campo da tabela SA1 que identifica se o cliente eh Orgao Publico. Tratamento na Apuracao PIS/COF
Local cA1M996		:= "" 									//Informacao do Campo do Cadastro de Cliente utilizado para identificar PIS/Cofins para pessoa juridica de direito Publico. Art. 7, Lei 9718(SRF).
Local lA1M996 		:= SA1->(ColumnPos(cMV_A1M996)) > 0  	//Identifica se o campo configurado no parametro "MV_A1M996" existe na tabela SA1.
Local aTotReceb 	:= {}									// Guarda as formas de pagamento e os ID dos cartoes
Local dDtVencSE1	:= Ctod(Space(08))						// Guarda as Datas das Parcelas de vencimentos
Local cControlReceb := ""									// controla se houve mudança de forma e id de pagameto na geracao das datas de vencimento
Local lRetemPCC 	:= .F.
Local cDiaVen		:= ""									// Variavel para fixar o dia da primeira parcela e  replicar para as demais
Local cAEForm		:= ""									// Variavel para controlar o dia fixo da primeira parcela usando a forma de pagamento da ADM
Local cAEFormID 	:= ""       							// Variavel para controlar o dia fixo da primeira parcela usando o ID do cartao
Local lCpoFixSAE	:= SAE->(ColumnPos("AE_FIXADIA")) > 0
Local lRecSe1		:= IIf(SL4->(ColumnPos("L4_RECSE1")) > 0, .T., .F.)
Local lAtuSldNat 	:= ExistFunc("AtuSldNat")
Local aAreaSA1 		:= {}
Local nTamSerie     := TamSX3("L1_SERIE")[1]				// Tamanho do campo L1_SERIE
Local cMVLOJASF		:= PadR(SuperGetMv("MV_LJTPSFA",,"SFA"), nTamSerie )// Serie do Serviço Financeiro Avulso se somente todos os itens tiverem S.Fin.Avulso
Local cNumPedSF		:= ""									//Numero do pedido de Serviços Financeiros
Local lMultNegoc    := SuperGetMv("MV_LJMULTN",,.F.)
Local lIsMoney		:= .F.
Local nVlTotal       := 0
Local nVlItem       := 0
Local cMvComisCC	:= Upper( SuperGetMv("MV_COMISCC",,"S") )	// Verifica se deduz ou nao a taxa da adm. financeira p/ LOJA
Local uValue
Local aDadosBanc	:= {}                                       //array com dados de ag e conta CADASTRADOS Na SA6
Local lOriFin		:= .F.
Local lIntegDef	    := SL1->L1_ORIGEM == "N"                // Venda de Origem Integração
Local lIntegHtl	    := lIntegDef .And. SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria
Local dDataBkp	    := dDataBase 							//Backup de data base para integracao hotel
Local cPgtoHotel	:= SuperGetMv("MV_LJFORHT",, "CQ|CI")	//Formas de Pagamento Hotel que nao geram financeiro
Local aRecRa		:= {}  									//Array contendo Recnos dos titulos com Forma de Pagamento RA do cliente Hotel
Local lAltCli		:= .F. 									//Flag controle cliente - hotelaria
Local cCliBkp		:= ""  									//Backup cliente - hotelaria
Local cLojaBkp	    := ""  									//Backup loja - hotelaria
Local cTitPai		:= ""  									//Chave titulo pai
Local c1DUPRa		:= "1"
Local nPOUCmp		:= 0
Local lCtaPagar     := .T. 									//Gera Contas a Pagar
Local aRetfor       := {}
Local aAreaSL1      := SL1->( GetArea() )
Local xRet			:= {}
Local lIDCNAB		:= SL4->(ColumnPos("L4_IDCNAB")) > 0
Local lLJ7113	 	:= ExistBlock( "LJ7113" )				// Ponto de entrada para contabilizar on line no encerramento da venda.
Local aParamLj      := {{"MV_PAR01",2},{"MV_PAR04",2}} 		// MV_PAR01 Mostra Lanc Contabil? 1=SIM, 2=NÃO / MV_PAR04 Contabiliza On-line? 1=SIM, 2=NÃO 
Local aTotaisLJ		:= {}									// Utilizado para salvar o array aTotais
Local lLjGrvOn		:= SuperGetMV("MV_LJGRVON",,.T.)		// Indica se é venda online
Local cE1Filial 	:= xFilial("SE1") 	                    // Valor do campo E1_FILIAL
Local cE1Num		:= ""				                    // Valor do campo E1_NUM
Local cE1Prefixo	:= "" 				                    // Valor do campo E1_PREFIXO
Local cE1Parcela	:= "" 				                    // Valor do campo E1_PARCELA
Local cE1Tipo		:= "" 				                    // Valor do campo E1_TIPO
local cE1Naturez 	:= "" 				                    // Valor do campo E1_NATUREZ
Local cNatDinh   	:= LjMExeParam("MV_NATDINH")            // Natureza em Dinheiro
local aSE1			:= {}				                    // Avvay para gravação de dados na SE1
Local nE1Valor		:= 0				                    // Valor do campo E1_VALOR
Local nE1ValIss     := 0									// Valor do campo E1_VALOR Calculo ISS
Local dE1Vencto		:= DATE()			                    // Valor do campo E1_VENCTO
Local nE1IRRF		:= 0 				                    // Valor do campo E1_IRRF
Local nE1PIS		:= 0				                    // Valor do campo E1_PIS
Local nE1COFINS		:= 0				                    // Valor do campo E1_CSLL
Local nE1CSLL		:= 0 				                    // Valor do campo E1_CSLL
Local nE1INSS		:= 0				                    // Valor do campo E1_INSS
local nE1ValJur		:= 0				                    // Valor do campo E1_VALJUR
Local nE1Recno		:= 0				                    // RECNO para posicionamento da SE1
Local nValE1ISS		:= 0				                    // Valor do campo E1_ISS
Local nCountaSE1    := 0				                    // Variavel para percorrer aSE1
Local aAuxReceb		:= {}
Local lAutomato 	:= IIf(Type("lAutomatoX")<>"L",.F.,lAutomatoX)	//Teste Automatizado
Local cLogErro		:= ""				// Log para MostraErro()
Local nPosVCruz     := 0   				// Posição no Array aSE1 do campo E1_VLCRUZ
Local nPosVlReal	:= 0				// Posição no Array aSE1 do campo E1_VLRREAL
Local nPosISS		:= 0				// Posição no Array aSE1 do campo E1_ISS

Default lFinanceiro	:= .T.				// Se gera financeiro
Default aReceb 		:= {}				// Titulos a receber
Default aVendedor	:= {}				// Vendedores utilizados no SL2, para gravacao no financeiro
Default aNccItens 	:= {}				// Nccs
Default aRecSE1     := {}               // Array com os recnos dos registros do SE1
Default nNccUsada	:= 0				// Nccs usadas
Default nNccGerada	:= 0                // NCC geradas
Default nValPIS     := 0				// Valor do PIS
Default nValCSLL    := 0				// Valor do CSLL
Default nValCOFI    := 0                // Valor COFIN
Default nBaseDup    := 0				// Base para duplicata
Default aImpCheque  := {}     			// Controla que cheque foi impresso para gravar no EF_IMPRESS
Default nMoedaCor   := 1				// Moeda Corrente
Default nPerJur 	:= 0
Default lOriFun 	:= .F.
Default lLstPresC	:= .F.				// Lista de presentes do tipo credito?
Default aNewNCC		:= {}				// Array com as Notas de Créditos informadas
DEFAULT nBasePIS    := 0				// Base de calculo do PIS
DEFAULT nBaseCSLL   := 0				// Base de calculo do CSLL
DEFAULT nBaseCOFI   := 0				// Base de calculo do COFINS
DEFAULT cL1Serie	:= ""				// Serie do SL1
DEFAULT lIsVendaVP 	:= .F.				// Indica se eh venda de Vale Presente
DEFAULT cB1M996 	:= ""				// Informacao do Campo do Cadastro de Produtos (Configurado no parametro MV_B1M996) utilizado para identificar PIS/Cofins para pessoa juridica de direito Publico. Art. 7, Lei 9718(SRF).
Default nValINSS 	:= 0				// Valor INSS
Default nValIRRF 	:= 0				// Valor IRRF
DEFAULT nBaseINSS	:= 0				// Base de calculo do INSS
DEFAULT nBaseIRRF	:= 0				// Base de calculo do IRRF
DEFAULT lIsVdRecCP	:= .F.				// Indica se eh venda de Recarga de Cartao Presente (Gift Card)
Default nArredondar	:= 0				// Doação para o Instituto Arredondar
Default nOpc		:= 0
Default aRecnoFin 	:= {}
Default lTefNsuDigit:= .f.				// NSU Informado pelo usuário
Default nVFunrural	:= 0				// Valor do FUNRURAL
Default cDescErro	:= "" 				// Descrição caso ocorra erro na transação
Default lNFePDV	:= .F.					// Parametro para verificar se chamada origina do Totvs PVD com NFe

Private nPosValor	:= 0
Private nValFun		:= 0				// Essa variavel Private é utilizada na função A040DupRec para geraar o Titulo a Pagar referente a Taxa da Contribuicao Seguridade Social (FUNRURAL)

lRetemPCC := LjRetemPCC(SL1->L1_VLRTOT, nValPIS, nValCOFI, nValCSLL)
If !lRetemPCC
	nValPIS  := 0
	nValCOFI := 0
	nValCSLL := 0
	nBasePIS := 0
	nBaseCOFI:= 0
	nBaseCSLL:= 0
EndIf

aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+SL1->L1_OPERADO, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
cContaCx      := aDadosBanc[1]
cAgenciaCx    := aDadosBanc[2]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a tabela MEP existe pelo retorno do campo³
//³TamSX3                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// alteração para atender transmissão Sped , que considera e1_origem igual a LOJA701 e o FATA701.
If LjNfPafEcf(SM0->M0_CGC)
	cOrigem := "LOJA701"
EndIf

aCampMEP:= TamSX3("MEP_PARTEF")

If Len(aCampMEP) > 0
	lGrvMEP := .T.
	nTamParTEF := aCampMEP[1]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Cria vetor que sera utilizado para gravacao das parcelas se o mesmo nao foi informado    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aReceb)
	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))

	dbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(MsSeek(xFilial("SL2")+SL1->L1_NUM))

	dbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	SL4->(MsSeek(xFilial("SL4")+SL1->L1_NUM))

	aAuxReceb := LJ7aReceb(lScreen, lTefNsuDigit)
	If aAuxReceb[1]
		aReceb := aClone(aAuxReceb[2])
	Else
		Return .F.
	EndIf
EndIf

LjGrvLog(cNumOrc,"GERACAO DO FINANCEIRO",aReceb )

//P.E. permite alterar o array aReceb
If lRet .AND. ExistBlock("LJGRFIN")
	LjGrvLog(cNumOrc,"Antes da execução do P.E. LJGRFIN",aReceb)
	aRetReceb := ExecBlock( "LJGRFIN",.F.,.F., {aReceb} )
	LjGrvLog(cNumOrc,"Depois da execução do P.E. LJGRFIN - Retorno:",aRetReceb)
	If ValType(aRetReceb) == "A"
		aReceb := aRetReceb
	EndIf
EndIf

//Verifica configuracao do Cliente referente a Venda para Orgaos Publicos
If lA1M996 .And. SA1->(ColumnPos(cMV_A1M996)) > 0
	cA1M996 := SA1->(&(cMV_A1M996))
EndIf

If SuperGetMV("MV_RTIPFIN", NIL, .F.)
	nImpostos := Len( aReceb )
Else
	nImpostos := 1
EndIf

nLoopParc  := Len( aReceb )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a posicao da Condicao de Pagamento Dinheiro,³
//³dentro do Array aReceb, para gravacao com a posicao  ³
//³correta.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosDin := 	Ascan(aReceb, {|x| AllTrim(x[__FORMA]) == AllTrim(cMvSimb1)})

//Faz a verificacao se o valor do ISS deve ser abatido no valor total da venda.
lAbateISS := !( lECommerce ) .AND. LjxDAbISS(SL1->L1_CONDPG,SL1->L1_FORMPG,SL1->L1_VALISS)

//Faz a verificacao se o valor do ISS deve ser abatido no valor total da venda quando executado via Job (!_lScreen)
lRpcIss   := !_lScreen .And. lCliRecIss .And. SL1->L1_VALISS >= SuperGetMv("MV_VRETISS",.T.,0) .And. IIF(lIntegDef, SA1->A1_INCISS == "N", .T.)

If ( If( lpTPAbISS .And. (lAbateISS .Or. lRpcIss), SL1->L1_VALISS, 0 ) ) > 0 .AND. ;
	( nLoopParc > 1 .OR. (nLoopParc == 1 .AND. aReceb[1][2] > 0) ) .AND. ;
	( If(_lScreen,Lj7T_Troco(2)==0,.T.) )

	For i := 1 to nLoopParc
		aReceb[i][2]+= NoRound(( ( If( ! lpTPAbISS, 0, SL1->L1_VALISS ) ) / nLoopParc ),nRndMoed1)
		nRestDiv 	+= NoRound(( ( If( ! lpTPAbISS, 0, SL1->L1_VALISS ) ) / nLoopParc ),nRndMoed1)
	Next i

	If nRestDiv < (  If( ! lpTPAbISS, 0, SL1->L1_VALISS ) )
		aReceb[nLoopParc][2] += ( If( ! lpTPAbISS, 0, SL1->L1_VALISS ) ) - nRestDiv
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Cria array de vendedores utilizados no SL2, para gravacao no financeiro caso o array nao tenha sido informado |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aVendedor)
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
		If !Empty(SL2->L2_VEND)

				DbSelectArea("SA3")
				DbSetOrder(1)
				SA3->(DbSeek(xFilial("SA3") + SL2->L2_VEND))

				DbSelectArea("SB1")
				DbSetOrder(1)
				SB1->(DbSeek(xFilial("SB1") + SL2->L2_PRODUTO))

				Do Case
					Case ! Empty(SB1->B1_COMIS)
						nComis := SB1->B1_COMIS
					Case ! Empty(SA3->A3_COMIS)
						nComis := SA3->A3_COMIS
					OtherWise
						nComis := SA1->A1_COMIS
				EndCase

				nPos 	:= Ascan( aVendedor, { |x| x[1] = SL2->L2_VEND } )
				If AllTrim(SA3->A3_FRETE) == "N"
					nVlItem := SL2->L2_VLRITEM
				else
					nVlItem := SL2->L2_VLRITEM + SL2->L2_SEGURO + SL2->L2_VALFRE + SL2->L2_DESPESA	
				EndIf

				// Considera o IPI na Base da Comissao
				If AllTrim(SA3->A3_IPI) == "S" .AND. SL2->L2_VALIPI > 0
					nVlItem += SL2->L2_VALIPI 
				Endif

				//Abate o percentual da administradora proporcionalmente
				If SL1->L1_CARTAO > 0 .AND. cMvComisCC  == 'S'
					xRet := Lj440AdmFin(SL1->L1_NUM, nDecimal) 
					If ValType(xRet) == "N" 
						nVlItem -= xRet 	//Antes de 05/2019 retornava numerico
					Else
						nVlItem -= xRet[1] 	//Criado mais uma posição de retorno. 1 numerico / 2 Logico
					EndIf		
				EndIf
				
				If nPos == 0
					Aadd(aVendedor, {SL2->L2_VEND, nComis, nVlItem,((nVlItem*nComis)/100),1} )					
				Else
					aVendedor[nPos][3] += nVlItem				
					aVendedor[nPos][4] += (nVlItem*nComis)/100
					aVendedor[nPos][5] += 1
				EndIf
		EndIf
		SL2->(DbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Proporcionaliza a comissao da venda, de acordo com a³
	//³comissao para cada item                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPos := 1 to Len(aVendedor)
		If aVendedor[nPos][5] > 1
			aVendedor[nPos][2] := (aVendedor[nPos][4] / aVendedor[nPos][3]) * 100
		EndIf
	Next nPos
EndIf

//Trecho colocado, pois tinha um cliente que queria dois vendedores no cabecalho (ANTONIO AUTOPECAS)
//Nesse caso o cliente preenchendo o campo (customizado) L1_VEND2 e considera na comissao
//Tratamento no Loja440 funcionava apenas para Calculo de Comissao Off-Line, adicionado aqui para funcionar no calculo de Comissao On-Line
If cPaisLoc == "BRA" .AND. SL1->L1_TIPO <> 'P' .AND. SL1->(ColumnPos("L1_VEND2")) > 0
	If ValType(M->LQ_VEND2) <> Nil .AND. !Empty(M->LQ_VEND2)
		//Atualiza vendedor 2 na SF2
		SF2->(RecLock("SF2", .F.))
		Replace SF2->F2_VEND2 with M->LQ_VEND2
		SF2->( MsUnLock() )

		//Salva area SA3
		aAreaSA3 := SA3->( GetArea() )

		SA3->( dbSetOrder(1) )

		If SA3->(MsSeek(xFilial("SA3") + SF2->F2_VEND2)) .And. SA3->A3_COMIS > 0 .AND. (aScan(aVendedor, {|x| x[1] == SF2->F2_VEND2 }) == 0)
			Aadd(aVendedor, {SF2->F2_VEND2, SA3->A3_COMIS, SL1->L1_VLRTOT, ((SL1->L1_VLRTOT * SA3->A3_COMIS) / 100), 1})
		EndIf

		//Restaura area SA3
		RestArea(aAreaSA3)
	EndIf		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o tratamento dos campos L1_DOC / L1_DOCPED e L1_SERIE / L1_SERPED   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cL1Doc	  := If(Empty(SL1->L1_DOC),SL1->L1_DOCPED,SL1->L1_DOC)
nTotNFISS := SL1->L1_VALISS

If SL1->(ColumnPos("L1_VALIRRF")) > 0
	nTotNFIRRF:= SL1->L1_VALIRRF
Else
	nTotNFIRRF:= 0
EndIf

//Define o prefixo do Titulo
cPrefE1  	:= cL1Serie

If lIsVendaVP .Or. lIsVdRecCP
	cL1Serie	:= If( !Empty(SL1->L1_SERIE),SL1->L1_SERIE , SL1->L1_SERPED)
	
	//Define o prefixo do Titulo
	cPrefE1  	:= cL1Serie
	
ElseIf lECommerce .OR. (((cOrigem == cNomeProg) .Or. (lPedidoVD)) .AND. SL1->L1_TIPO=="P") .OR.;
 		(cOrigem =="LOJA010" .AND. (SL1->L1_TIPO =="P" .OR. !Empty(SL1->L1_DOCPED))) .AND. !HasTemplate("OTC")
 		
	lPedido := .T.
	cL1Serie	:= If(Empty(SL1->L1_SERIE),SL1->L1_SERPED,SL1->L1_SERIE)
	
	/*
	Verifica se o parametro MV_LJPREF foi alterado, pois qdo eh gerado um pedido nao               
	eh feita a gravacao do SF2, desta forma eh impossivel considerar a informacao do SF2->F2_SERIE
	-- Define o prefixo do Titulo
	*/
	If Empty(LjGetPrefix(SF2->F2_SERIE)) .And. AllTrim(Upper(cMvLjPref)) == "SF2->F2_SERIE"
		cPrefE1 := cL1Serie
	ElseIf cL1Serie <> cMvLojaSF   //Se for Serviços Financeiros, nunca irá encontrar a SF2->F2_SERIE, permanecerá o dado de entrada da função
		cPrefE1 := &(cMvLjPref)
	Else
		cPrefE1 := LjGetPrefix(SF2->F2_SERIE)		
	EndIf
Else
    If cL1Serie <> cMvLojaSF   //Se for Serviços Financeiros, nunca irá encontrar a SF2->F2_SERIE, permanecerá o dado de entrada da função
	    cL1Serie	:= SF2->F2_SERIE
	    
		//Define o prefixo do Titulo
		cPrefE1  	:= &(cMvLjPref)
    EndIf
    
	If lLstPresC
    	cL1Serie := If(!Empty(SL1->L1_SERPED),SL1->L1_SERPED,SL1->L1_SERIE)
    	cPrefE1	 := cL1Serie
    EndIf
EndIf

cPrefE1 := PadR(cPrefE1, nTamE1_PREFIXO)
cNumE1 	:= LJ7NumTit()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao de Contas a Receber ja' baixado                                                                          ³
//³ Foi tirada a condicao lfinanceiro para que em dinheiro E1 e E5 sejam atualizados                                     ³
//³                                                                                                                      ³
//³ ??? - Se o usuario pode alterar o pagamento na entrega (lFinanceiro:=.F.) entao nem o dinheiro deveria ser gravado...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. ExistBlock("LJTES",,.T.) .AND. !lFtvdVer12
	uValue := ExecBlock("LJTES",.F.,.F.)
	If ValType(uValue) == "L"
		lRetLJTES := uValue
	ElseIf ValType(uValue) == "A"
		lRetLJTES 	:= uValue[1]
		lRet 		:= uValue[2]
	Else
		lRetLJTES := .T.	
	Endif
EndIf

//Tratamento para Geracao ou nao de financeiro para processos originados da Integracao EAI.
//para integracao não poderá ter itens com e sem geração de financeiro no mesmo pedido.
//Notas do Tipo B-Beneficiamento náao geram Financeiro, para os casos de devolucao de compras
//os titulos serao gerados no Contas a Pagar e finalmente os processos vendas nao sofreram nenhuma
//alteracao.
If lIntegDef
	
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
	While !SL2->(Eof()) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
		SF4->(DbSetOrder(1))
		If(SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES)))
			If SF4->F4_DUPLIC == "N"
				lRetLJTES   := .F.
				lFinanceiro := .F.
				lCtaPagar   := .F.
				Exit
			Endif
		Endif	
		SL2->(DbSkip())
	Enddo

	If SL1->L1_TIPO $ "B|D" //BENEFICIAMENTO
		If lCtaPagar
			lRetLJTES   := .F.
			lFinanceiro := .F.
	
			//NOTA FISCAL DE DEVOLUCAO
			If SL1->L1_TIPO == "D" 
				LjGrvLog(cNumOrc,"GERACAO DO CONTAS A PAGAR", xFilial("SL1")+SL1->L1_DOC+SL1->L1_SERIE)
				CONOUT(cNumOrc + " GERACAO DO CONTAS A PAGAR - "+xFilial("SL1")+SL1->L1_DOC+SL1->L1_SERIE)
				DbSelectArea("SA2")
	
				//Verifica se posicionado no cliente da venda
				If (SL1->L1_ClIENTE + SL1->L1_LOJA) <> (SA1->A1_COD + SA1->A1_LOJA) 
					SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					SA1->(dbSeek(xFilial("SA1") + SL1->L1_ClIENTE + SL1->L1_LOJA))	  
				EndIf
				//Ajustei o Seek, estava fazendo Seek do CNPJ com base no código do cliente ? só funcionou se tinha código igual CNPJ	
				DbSelectArea("SA2")
				SA2->(DbSetOrder(3))//A2_FILIAL+A2_CGC
				IF(SA2->(DbSeek(xFilial("SA2")+PADR(SA1->A1_CGC,TamSx3("A2_CGC")[1]))))
					 LjGerfincp(CEMPANT, CFILANT, xFilial("SL1"),SL1->L1_NUM,;
					  		    SA2->A2_COD, SA2->A2_LOJA, SA2->A2_NREDUZ, SL1->L1_DOC,;
					  		    SL1->L1_SERIE, SL1->L1_VALBRUT)
				Endif		
			Endif
		Else
			//Se nao gera financeiro deve limpar os campos F2_VALFAT e F2_DUPL
			If SF2->( F2_FILIAL + F2_DOC + F2_SERIE ) == xFilial("SF2")+SL1->L1_DOC+SL1->L1_SERIE
				RecLock("SF2", .F.)
				SF2->F2_VALFAT 	:= 0
				SF2->F2_DUPL	:= ""
				SF2->(MsUnLock())
			EndIf
		EndIf
	Endif
Endif

If lRet .AND. ExistBlock("FTVDTES",,.T.) .AND. lFtvdVer12
	lRetFTVDTES := ExecBlock("FTVDTES",.F.,.F.)
	If ValType(lRetFTVDTES) <> "L"
		lRetFTVDTES := .T.
	Endif
EndIf

If lScreen .AND.lRet
	lAbatOrc := LjAbatOrc()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No caso de pedido verifica se existe algum registro no SE1 do mesmo tipo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPedido .AND. !lScreen .AND. lRetLJTES

	LjGrvLog(cNumOrc,"INDICE DO TITULO FINANCEIRO", xFilial("SE1")+cPrefE1+cNumE1)
	
	aAliasSE1    := SE1->( GetArea() )
	DbSelectArea("SE1")
	DbSetOrder(1)	// 	E1_FILIAL+E1_PREFIXO+E1_NUM
	lE1Seek := DbSeek(xFilial("SE1")+cPrefE1+cNumE1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ja existe um titulo do mesmo tipo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lE1Seek
		While !Eof() .AND. (xFilial("SE1")+cPrefE1+cNumE1) == (SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM )
			For nX := 1 To Len(aReceb)
				If AllTrim(aReceb[nX][__FORMA]) == AllTrim(SE1->E1_TIPO)
					LjGravaLog( lScreen,cNumOrc,STR0071+SL1->L1_NUM+Chr(10)+"TITULO e PREFIXO ja existe no SE1:"+SE1->E1_NUM+SE1->E1_PREFIXO, LMSTOP, LMPROC) //"Orcamento:" ### "TITULO e PREFIXO ja existe no SE1 "
					lRet := .F.
				EndIf	
		   	Next nX 
			SE1->(DbSkip())
		End   	
	EndIf

	RestArea( aAliasSE1 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica a utilizacao da funcionalidade referente a Conta Corrente|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE4->(ColumnPos("E4_CCORREN")) > 0
	If Alltrim(SL1->L1_FORMPG) == "FI"
		cNatCCor := SuperGetMv( "MV_NATCCOR" , .F. , "OUTROS" ,  )
		If !Empty(cNatCCor)
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
		        DbSelectArea("SE4")
		        SE4->(DbSetOrder(1))
		        If SE4->(MsSeek(xFilial("SE4")+SL1->L1_CONDPG)) .AND. SE4->E4_CCORREN == "1"
					DbSelectArea("SED")
					SED->(DbSetOrder(1))
					If SED->(Msseek(xFilial("SED")+cNatCCor))
						lCtaCorren := .T.
					Endif
				Endif
		    Endif
		Endif
	Endif
Endif

// Array com as formas de pagamentos e ID dos cartoes
aTotReceb := LjTotRec(aReceb,@nVlTotal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| SE (Dinheiro maior que zero                                                              |
//|     OU (o abatimento foi total E este orcamento nao seja proveniente de uma reserva))    |
//| E o LJTES retornou verdadeiro E Brasil)                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SL1->L1_DINHEIR > 0 .OR. lAbatOrc ) .AND. ((lRetLJTES .AND. !lFtvdVer12) .OR. (lRetFTVDTES .AND. lFtvdVer12))  .AND. (cPaisLoc == "BRA") .AND. lRet

	cE1Filial := xFilial("SE1")
	AADD( aSE1 , { "E1_FILIAL" , cE1Filial } )
	//Vendas sem DOC da erro
	If cPrefE1 = cMVLOJASF  //Se Itens de Serviços Financeiros
		If Empty(SL1->L1_DOC)
			cNumPedSF := NxtSX5Nota( cMvLojaSF )
		Else
			cNumPedSF := SL1->L1_DOC
		EndIf
		cE1Num := cNumPedSF
		cE1Prefixo := cPrefE1
		cE1Portado := IIF(lScreen,xNumCaixa(),SL1->L1_OPERADO)

	Elseif lPedido
		cE1Num := cNumE1
		cE1Prefixo := cPrefE1
		cE1Portado := IIF(lScreen,xNumCaixa(),SL1->L1_OPERADO)
	ElseIf Empty(SL1->L1_DOC) 
		cE1Num := cNumE1
		cE1Prefixo := cPrefE1
		cE1Portado := SL1->L1_OPERADO
	ElseIf lIsVendaVP .Or. lIsVdRecCP
		cE1Num := cNumE1
		cE1Prefixo := cPrefE1
		cE1Portado := SL1->L1_OPERADO
	Else	
		cE1Num := cNumE1
		cE1Prefixo := SF2->F2_PREFIXO
		cE1Portado := SL1->L1_OPERADO
	EndIf

	AADD( aSE1 , { "E1_NUM" , cE1Num } )
	AADD( aSE1 , { "E1_PREFIXO" , cE1Prefixo } )
	AADD( aSE1 , { "E1_PORTADO" , cE1Portado } )

	AADD( aSE1 , { "E1_AGEDEP"	, aDadosBanc[1] } )
	AADD( aSE1 , { "E1_CONTA"	, aDadosBanc[2] } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o dinheiro for zero, joga o valor do abatimento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SL1->(ColumnPos("L1_ABTOPCC")) > 0 .AND. SL1->L1_DINHEIR == 0
		nE1Valor := SL1->L1_ABTOPCC
	Else
		If nPosDin > 0
			nE1Valor := aReceb[nPosDin][__VALOR]
		Else
			nE1Valor := SL1->L1_DINHEIR
		EndIf
	EndIf

	AADD( aSE1 , { "E1_VALOR" , nE1Valor } )

	If Empty(SL1->L1_EMISNF)
		dE1Emissao := dDatabase
		AADD( aSE1 , { "E1_EMISSAO" , dE1Emissao } )
		AADD( aSE1 , { "E1_EMIS1" 	, dDatabase } )
		dE1Vencto := dDatabase
		AADD( aSE1 , { "E1_VENCTO" , dE1Vencto } )
	Else
		dE1Emissao := SL1->L1_EMISNF
		AADD( aSE1 , { "E1_EMISSAO" , dE1Emissao } )
		AADD( aSE1 , { "E1_EMIS1" 	, SL1->L1_EMISNF } )
		dE1Vencto := SL1->L1_EMISNF
		AADD( aSE1 , { "E1_VENCTO" 	, dE1Vencto } )
	EndIf

    AADD( aSE1 , { "E1_NRDOC" , SL1->L1_ECPEDEC } )

	cE1Parcela := "  "
	AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
	AADD( aSE1 , { "E1_VENCREA" , DataValida(dE1Vencto,.T.) } )
	AADD( aSE1 , { "E1_VENCORI" , dE1Vencto } )
	
	If SL1->L1_TIPO $ ("D|B")
		aRetfor := LjRetfor(SL1->L1_CLIENTE,SL1->L1_LOJA)
		AADD( aSE1 , { "E1_CLIENTE" , aRetFor[1] } )
		AADD( aSE1 , { "E1_LOJA" 	, aRetFor[2] } )
	Else
		AADD( aSE1 , { "E1_CLIENTE" , SA1->A1_COD } )
		AADD( aSE1 , { "E1_LOJA" 	, SA1->A1_LOJA } )
	Endif
	
	AADD( aSE1 , { "E1_NOMCLI"	, SA1->A1_NOME } )
	cE1Tipo := cMvSimb1
	AADD( aSE1 , { "E1_TIPO"	, cE1Tipo } )
	AADD( aSE1 , { "E1_SITUACA"	, IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,cMvSimb1,cE1Portado),"0") } )
	AADD( aSE1 , { "E1_SALDO" 	, 0 } )
	AADD( aSE1 , { "E1_MOEDA" 	, 1 } )
    cE1Naturez := cNatDinh
	AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
	AADD( aSE1 , { "E1_VLCRUZ" 	, xMoeda(nE1Valor, 1, 1, dE1Emissao ) } )
	AADD( aSE1 , { "E1_NUMNOTA" , cE1Num } )

	If lPedido .AND. !lLstPresC
		AADD( aSE1 , { "E1_SERIE", "SE1", 1, "E1_SERIE", dDataBase, SL1->L1_SERPED } )
	Else
		AADD( aSE1 , { "E1_SERIE", "SE1", 1, "E1_SERIE", dDataBase, SL1->L1_SERIE } )
	EndIf

	AADD( aSE1 , { "E1_FILORIG" , cFilAnt } )
	AADD( aSE1 , { "E1_HIST" 	, "VENDA EM DINHEIRO" } )
	AADD( aSE1 , { "E1_STATUS" 	, "B" } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se Existir o Campo E1_NumMov,Grava o Numero do Ultimo Movimento do SLW ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->(ColumnPos("E1_NUMMOV"))>0
		AADD( aSE1 , { "E1_NUMMOV" , LJNumMov() } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir o campo E1_RELATO, grava com o valor padrao do X3_RELACAO para nao gerar erro na rotina do  ³
	//³modulo Financeiro (FINA630 - Aprovacao/Rejeicao da transferencia), conforme descrito no chamado TERHZ6.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->(ColumnPos("E1_RELATO")) > 0
		AADD( aSE1 , { "E1_RELATO" , "2" } ) //Valor padrao (X3_RELACAO)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SED")
	DbSetOrder(1)
	MsSeek(xFilial("SED") + cE1Naturez )

	If SED->ED_CALCISS=="S"
		//Calculo e atribuição do campo SE1->E1_ISS
		LjCalcRecIss(	@nTotNFISS	, @nRestISS	, .F.	, lCliRecIss	,;
						nImpostos	, lpTPAbISS	, 1		, @nValE1ISS	,;
						@nE1Valor	)
		
		AADD( aSE1 , { "E1_ISS" , nValE1ISS } )
		AADD( aSE1 , { "E1_VALOR" , nE1Valor } )

		If lIntegDef //Integracao Mensagem Unica atualiza valor do ISS do titulo
			If nTotNFISS >= SuperGetMv("MV_VRETISS",.T.,0)
				AADD( aSE1 , { "E1_ISS" , nTotNFISS } )
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetuar o calculo do IRRF conforme natureza         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nE1IRRF := NoRound(nTotNFIRRF/nImpostos,2)
	nRestIRRF += nE1IRRF
	If 1 == nImpostos
		nE1IRRF += nTotNFIRRF - nRestIRRF
		nTotNFIRRF  := nRestIRRF := 0
	EndIf

	For nVend := 1 To Min(Len(aVendedor),5) // So existem 5 campos no SD2 e SE1

		If IsBlind() .AND. SL1->L1_CREDITO > 0 .AND. !lComiDev
			nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + SL1->L1_CREDITO) ) * SL1->L1_DINHEIR,nDecimal )
		Else
			nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + nNccUsada) ) * SL1->L1_DINHEIR,nDecimal )
		EndIf

		AADD( aSE1 , { "E1_VEND"+Str(nVend,1) 	, aVendedor[nVend][1] } )
		AADD( aSE1 , { "E1_COMIS"+Str(nVend,1) 	, aVendedor[nVend][2] } )
		AADD( aSE1 , { "E1_BASCOM"+Str(nVend,1) , nBaseCom } )
		AADD( aSE1 , { "E1_VALCOM"+Str(nVend,1) , Round(nBaseCom * (aVendedor[nVend][2]/100),nDecimal) } )
	Next nVend

	AADD( aSE1 , { "E1_BAIXA" 	, SL1->L1_EMISNF } )
	AADD( aSE1 , { "E1_VALLIQ" 	, nE1Valor } )
	AADD( aSE1 , { "E1_ORIGEM" 	, cOrigem } )
	AADD( aSE1 , { "E1_MULTNAT" , "2" } )
	AADD( aSE1 , { "E1_FLUXO" 	, "S" } )

	If SE1->(ColumnPos("E1_SCORGP")) > 0	//Campo da tabela SE1 que identifica fornecimento de (1) bens e Servicos contratados por pessoa juridica de direito publico ou (2 ou '') identifica que Nao.
		If ("1"$cA1M996) .And. ("1"$cB1M996)
			AADD( aSE1 , { "E1_SCORGP" , "1" } )
		EndIf
	EndIf
	
	//Alimenta campo Reserva do Cliente - Integracao Hotelaria
	If lIntegHtl
		AADD( aSE1 , { "E1_CONHTL" , SL1->L1_RESEHTL } )
	EndIf

	If cPaisLoc == "BRA" .AND. lFirstDupRec
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo para o valor do PIS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1PIS := NoRound(nValPIS/nImpostos,2)
		nRestPIS  += nE1PIS
		If nImpostos == 1
			nE1PIS += nValPIS - nRestPIS
			nValPIS  := 0
			nRestPIS := 0
		EndIf

		AADD( aSE1 , { "E1_PIS" , nE1PIS } )

		If SE1->(ColumnPos("E1_SABTPIS")) > 0
			AADD( aSE1 , { "E1_SABTPIS" , nE1PIS } )
		EndIf

		AADD( aSE1 , { "E1_BASEPIS" , nBasePIS } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo para o valor do Cofins³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1COFINS := NoRound(nValCOFI/nImpostos,2)
		nRestCOFI += nE1COFINS
		If nImpostos == 1
			nE1COFINS += nValCOFI-nRestCOFI
			nValCOFI  := 0
			nRestCOFI := 0
		EndIf

		AADD( aSE1 , { "E1_COFINS" , nE1COFINS } )
                            
		If SE1->(ColumnPos("E1_SABTCOF")) > 0
			AADD( aSE1 , { "E1_SABTCOF" , nE1COFINS } )
		EndIf

		AADD( aSE1 , { "E1_BASECOF" , nBaseCOFI } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo para o valor do CSLL  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1CSLL := NoRound(nValCSLL/nImpostos,2)
		nRestCSLL +=  nE1CSLL
		If nImpostos == 1
			nE1CSLL += nValCSLL-nRestCSLL
			nValCSLL  := 0
			nRestCSLL := 0
		EndIf

		AADD( aSE1 , { "E1_CSLL" , nE1CSLL } )

		If SE1->(ColumnPos("E1_SABTCSL")) > 0
			AADD( aSE1 , { "E1_SABTCSL" , nE1CSLL } )
		EndIf

		AADD( aSE1 , { "E1_BASECSL" , nBaseCSLL } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo para o valor do INSS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1INSS := NoRound(nValINSS/nImpostos,2)
		nRestINSS += nE1INSS
		If nImpostos == 1
			nE1INSS += nValINSS-nRestINSS
			nValINSS  := 0
			nRestINSS := 0
		EndIf

		AADD( aSE1 , { "E1_INSS" , nE1INSS } )

		AADD( aSE1 , { "E1_BASEINS" , nBaseINSS } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo para o valor do IRRF  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1IRRF := NoRound(nValIRRF/nImpostos,2)
		nRestIRRF += SE1->E1_IRRF
		If nImpostos == 1
			nE1IRRF += nValIRRF-nRestIRRF
			nValIRRF  := 0
			nRestIRRF := 0
		EndIf

		AADD( aSE1 , { "E1_IRRF" , nE1IRRF } )

		If SE1->(ColumnPos("E1_SABTIRF")) > 0
			AADD( aSE1 , { "E1_SABTIRF" , nE1IRRF } )
		EndIf

		AADD( aSE1 , { "E1_BASEIRF" , nBaseIRRF } )

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta a modalidade de pagamento quando o parametro³
	//³MV_USASPB estiver ativo                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaSPB
		AADD( aSE1 , { "E1_MODSPB" , "1" } )
	EndIf

	// Envia para gravação da SE1
	lRet := LjGrFinSE1( aSE1, cE1Filial, cE1Prefixo, cE1Num, cE1Parcela, cE1Tipo, @nE1Recno )

	If !lRet
		LjGrvLog(cE1Num, "Registro já existe na tabela do Contas a Receber (SE1), verifique e efetue o processo novamente." )
		cDescErro += STR0187	+ CTRL +; // "Registro já existe na tabela do Contas a Receber (SE1), verifique e efetue o processo novamente."
					STR0188		+ cE1Prefixo 	+ CTRL +;	// "Prefixo: "
					STR0030+":" + cE1Num		+ CTRL +;	// "Número:"
					STR0189		+ cE1Parcela 	+ CTRL +;	// "Parcela: "
					STR0190		+ cE1Tipo 		+ CTRL		// "Tipo: "

		If !lLjGrvOn 
			LjGravaLog( lScreen, cNumOrc, cDescErro, LMALERT, LMTECH)
		EndIf

	Else

		// Garante o posicionamento do registro
		SE1->( dbGoTo( nE1Recno ) )

		aAdd( aRecnoFin, { "SE1", SE1->E1_NUM, SE1->(Recno()) } )

		If lOriFun .AND. lGerInt
			oIntVenda:Inserir("SE1", xFilial("SE1") +  SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "1", "3")
		EndIf

		aAdd( aRegSE1, SE1->(Recno()) )
		aAdd( aFinProp, .F. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao de titulos a receber, gerando todos os dados³
		//³complementares a uma implantacao de titulo.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//Nao executar essa funcao para Totvs PDV com NFe
		If !lNFePDV .and. lFirstDupRec
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 2) Antes da Rotina A040DupRec", LMALERT, LMTECH)

			// *** Verifica se esta usando a nova configuracao para confirmar se o cliente recolhera o iss ***
			cRecIss := Iif(Lj7RecIss(),"1","2")

			nValFun := nVFunrural //Alimenta a variável nValFun usada na função A040DupRec para geraar o Titulo a Pagar referente a Taxa da Contribuicao Seguridade Social (FUNRURAL)

			A040DupRec(cOrigem,.T.,nBaseDup, lRetemPCC, lpTPAbISS, lAtuSalDup,  ,cRecIss , , , , , )
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 3) Depois da Rotina A040DupRec", LMALERT, LMTECH)

			//Zera as variaveis que controla o valor da Taxa da Contribuicao Seguridade Social (FUNRURAL), para que o imposto não seja gerado duplicado
			nVFunrural 	:= 0
			nValFun 	:= 0

			If !SuperGetMV("MV_RTIPFIN", NIL, .F.)
				lFirstDupRec := .F.
			EndIf
		EndIf

		DbSelectArea( "SE1" )
		SE1->( DbGoTo( aRegSE1[Len(aRegSE1)] ) )

		If (SE1->E1_PIS + SE1->E1_CSLL + SE1->E1_COFINS + SE1->E1_ISS ) > 0  // Acrescentado a retenção Iss
			cParcelaAbat := SE1->E1_PARCELA

			aAliasSE1    := SE1->( GetArea() )

			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 4) antes da Rotina SumAbatRec", LMALERT, LMTECH)
			nTotAbat := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,cParcelaAbat,1,"S",dDataBase)
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 5) Depois da Rotina SumAbatRec", LMALERT, LMTECH)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apos rodar a funcao acima "SumAbatRec", o alias __SE1 eh criado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select( "__SE1" ) <> 0
				DbSelectArea( "__SE1" )
				DbCloseArea()
			EndIf

			RestArea( aAliasSE1 )

		EndIf
		
		If lFtvdVer12
			If ExistBlock("FTVDDEPSE1")
				ExecBlock("FTVDDEPSE1",.F.,.F.)
			EndIf
		Else
			If ExistBlock("LJDEPSE1")
				If nPosDin > 0
					ExecBlock("LJDEPSE1",.F.,.F.,{aReceb[nPosDin]})
				Else
					ExecBlock("LJDEPSE1",.F.,.F.,{Nil})
				EndIf
			EndIf
		EndIf

		if !lNFePDV
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 6) antes da Rotina LjGeraE5 ", LMALERT, LMTECH)
			
			If !(LjGeraE5(aDadosBanc,nTotAbat,aRegSE1[Len(aRegSE1)]))
				lRet := .F.
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin - Erro na baixa automatica do titulo ", LMALERT, LMTECH)	
			EndIf

			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 7) Depois da Rotina LjGeraE5 ", LMALERT, LMTECH)
		endif
		
		If lOriFun .AND. lGerInt
			oIntVenda:Inserir("SE5", xFilial("SE5") + SE5->E5_NATUREZ + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(dDatabase), "4", "3")
		EndIF

		//Array para calculo das comissoes
		Aadd(aBaixas,	{SE5->E5_MOTBX,	SE5->E5_SEQ, SE5->(Recno()) })

		//Array para calculo das comissoes
		nScanBx := aScan(aBaixasTmp,{|x| x[1] == SE1->(Recno())})
		
		If nScanBx == 0
			Aadd(aBaixasTmp,{SE1->(Recno()),{}})
			nScanBx := Len(aBaixasTmp)
		EndIf
		aAdd(aBaixasTmp[nScanBx,2],{SE5->E5_MOTBX, SE5->E5_SEQ, SE5->(Recno())})
	EndIf
EndIf

If lFinanceiro .AND. lRet
	If !lFtvdVer12
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin - 8) antes da Bloco LJTES", LMALERT, LMTECH)
		If ExistBlock("LJTES",,.T.)
			uValue := ExecBlock("LJTES",.F.,.F.)
			If ValType(uValue) == "L"
				lFinanceiro := uValue
			ElseIf ValType(uValue) == "A"
				lFinanceiro	:= uValue[1]
				lRet 		:= uValue[2]
			Else
				lFinanceiro := .T.	
			Endif
		EndIf	
		LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 9) depois da Bloco LJTES", LMALERT, LMTECH)
	ElseIf lFtvdVer12
		LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 8) antes da Bloco FTVDTES", LMALERT, LMTECH)
		lFinanceiro := If(ExistBlock("FTVDTES",,.T.),ExecBlock("FTVDTES",.F.,.F.),lFinanceiro)
		LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 9) depois da Bloco FTVDTES", LMALERT, LMTECH)
	EndIf
EndIf

// Verifica se esta usando a nova configuracao para confirmar se o cliente recolhera o iss.
cRecIss := Iif(Lj7RecIss(),"1","2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do aRegNomE1                  ³
//³[1] - Codigo da administradora no SAE   ³
//³[2] - Loja da administradora no SAE     ³
//³[3] - Prefixo do SE1                    ³
//³[4] - Numero do SE1                     ³
//³[5] - Parcela no SE1                    ³
//³[6] - Forma no SE1                      ³
//³[7] - Descricao da Administradora no SAE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinanceiro .AND. lRet

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao tem problema se nao encontrar pois Condicao Negociada nao e' cadastrada no SE4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE4->(MsSeek(xFilial("SE4")+SL1->L1_CONDPG))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Classifica o Array aReceb, em ordem de:                                           ³
	//³Forma de Pagamento + Administradora + ID do Cartao + Data de Vencimento, para efe-³
	//³tuar a quebra do titulo, caso a Administradora seja diferente entre as parcelas.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aSort(aReceb,,,{|x,y| 	x[__FORMA] + x[__ADMINIS] + x[__FORMAID] + DtoS(x[__DATA]) <;
							y[__FORMA] + y[__ADMINIS] + y[__FORMAID] + DtoS(y[__DATA])})

	dDtVencSE1		:= SL1->L1_EMISNF		// Inicializa variavel com a Data de Emissao

	If Len(aReceb) > 0
		cControlReceb := Alltrim(aReceb[1][__FORMA]) + Alltrim(aReceb[1][__ADMINIS]) + Alltrim(aReceb[1][__FORMAID])
	EndIf

	For i := 1 To Len(aReceb)

		aSE1 := {}	//Reinicializando os elementos para cada registro lido no SE1

		//---------------------------------------------------------------------------
		//|A data de vencimento inicial deve ser zerada a cada mudanca de           |
		//|Forma de Pagamento + Administradora + ID do Cartao , para nao gerar datas|
		//|de vencimentos sequenciais quando utilizado dois cartoes por exemplo		|
		//---------------------------------------------------------------------------
		If 	cControlReceb <> (Alltrim(aReceb[i][__FORMA]) + Alltrim(aReceb[i][__ADMINIS]) + Alltrim(aReceb[i][__FORMAID]))
			dDtVencSE1		:= SL1->L1_EMISNF		// Inicializa variavel com a Data de Emissao
			cControlReceb := (Alltrim(aReceb[i][__FORMA]) + Alltrim(aReceb[i][__ADMINIS]) + Alltrim(aReceb[i][__FORMAID])) // se prepara para a proxima forma
		EndIf

		//---------------------------------------------------------------------------
		//|Para paises diferentes de Brasil a gravacao dos titulos em $ tem que ser |
		//|realizada pelo array aReceb devido o fato de poder existir recebimento em|
		//|diversas moedas...                                                       |
		//---------------------------------------------------------------------------
		If 	aReceb[i][__VALOR] <= 0 .OR.;
			(AllTrim(aReceb[i][__FORMA]) == SuperGetMV("MV_SIMB1") .AND.;
			cPaisLoc == "BRA")
			Loop
		EndIf

		lAltParcela := .T.

		// ** Posiciona o SA1 **
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))

		// Se nao encontrar na SAE(Adm Financeira) ira gravar o cliente da SA1(Cadastro de Clientes)
		DbSelectArea("SAE")
		SAE->(DbSetOrder(1))
		If SAE->(MsSeek(cFilSAE+Left(aReceb[i][__ADMINIS],nTamCodSAE)))
			aRetTp := LjGrvTpFin( SAE->AE_FINPRO, If( SAE->(ColumnPos("AE_AGLPARC")) > 0, SAE->AE_AGLPARC, 2 ) )
			lAglutina	:= aRetTp[1]
			lAdmProp	:= aRetTp[2]
			//Verifica se deve ficar o dia do primeiro vencimento para as demais parcelas
			If lCpoFixSAE
				If SAE->AE_FIXADIA == "2"		// 1=Nao; 2=Sim
					If 	cAEForm <> aReceb[i][__FORMA] .OR. cAEFormID <> aReceb[i][__FORMAID]
						cAEForm		:= aReceb[i][__FORMA]
						cAEFormID	:= aReceb[i][__FORMAID]
						cDiaVen		:= ""
					Endif
				Else
					cAEForm		:= ""
					cAEFormID	:= ""
					cDiaVen		:= ""
				Endif
			Endif

		Else
			lAdmProp	:= .T.
			cDiaVen		:= ""
			cAEForm		:= ""
			cAEFormID	:= ""
		Endif

		cSeek := xFilial("SE1") + cPrefE1 + cNumE1 + ;
		         cParcela + AllTrim(aReceb[i][__FORMA])
		         
		LjGrvLog(cNumOrc,"INDICE DO TITULO PARA GERAR", cSeek)
		LjGrvLog(cNumOrc,"PARCELA DO TITULO", cParcela)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a Administradora ou o ID do Cartao forem diferentes ³
		//³da parcela anterior, gera um novo titulo.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAdmin := .F.
		If i > 1
			If 	aReceb[i][__ADMINIS] <> aReceb[i - 1][__ADMINIS] .OR.;
				aReceb[i][__FORMAID] <> aReceb[i - 1][__FORMAID]
	            lAdmin 		:= .T.
	  		EndIf
	  	EndIf

	  	//Eh forma de pagamento de conciliador e alterou a forma, a administradora e  cartão, reinicia MEP
	  	If lGrvMEP .and. AllTrim(aReceb[i][__FORMA]) $ __FORMATEF .and. i > 1 .and.;
	  		!( aReceb[i][__FORMA]   +	aReceb[i][__ADMINIS]      + aReceb[i][__NSUTEF] + aReceb[i][__FORMAID] == ;
	  	       aReceb[i - 1][__FORMA] +   aReceb[i - 1][__ADMINIS] + aReceb[i - 1][__NSUTEF] + aReceb[i - 1][__FORMAID])

			nParcMEP := 0
	  	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inserida opção se caso seja GeraTaxa ativado e forma de pagamento = Cartão de Crédito³
		//³Seleciona o plano cadastrado na Administradora financeira, caso retorne              ³
		//³utiliza no lugar de SAE_TAXADM.                                                      ³
		//³-------------------------------------------------------------------------------------³
		//³Caso efetuar alguma alteracao nesse IF, favor verificar tamebm, se havera a          ³
		//³necessidade de ajustar tambem a funcao Lj440AdmFin do LOJA440.PRX                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nValTaxAdm := 0
		If AllTrim(aReceb[i][__FORMA]) $ "CC|CD"
			DBSelectArea("MEN")
			If MEN->(ColumnPos("MEN_TAXADM")) > 0

			    //Valida se existe mais de uma forma de pagamento
			    //senão pode calcular a taxa de administradora errado
			    nQtdCC := 0
			    nQtdCD := 0
   			    aBAKReceb := aReceb
			    For nI:= 1 to Len(aBakReceb)
			    	If	AllTrim(SAE->AE_TIPO) == AllTrim(aReceb[i][__FORMA]) .AND. ;
			    		(AllTrim(SAE->AE_TIPO) == AllTrim(aBakReceb[nI][__FORMA]))

				    	If AllTrim(aBAKReceb[nI][__FORMA]) == "CC"
		                	nQtdCC += 1
	    	            ElseIf AllTrim(aBAKReceb[nI][__FORMA]) == "CD"
							nQtdCD += 1
						EndIf
					EndIf
				Next nI

				nI := Iif( nQtdCC > 0, nQtdCC, nQtdCD )

				If nI > 0

				    // Procura no array aPgtosSint por FORMA+ID informado do cartao
					nPosReceb := aScan( aTotReceb,{|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aReceb[i][__FORMA])+Alltrim(aReceb[i][__FORMAID]) })

					If nPosReceb > 0
						// aTotReceb[nPosReceb][4] - Quantidade de parcelas
						// aTotReceb[nPosReceb][3] - Valor total das parcelas
						aAdmValTax := LJ7_TxAdm( SAE->AE_COD, aTotReceb[nPosReceb][4], aTotReceb[nPosReceb][3] )

			    	    If Len(aAdmValTax) > 0
			        		nValTaxAdm := aAdmValTax[3]
			    	    EndIf
			    	Endif

		    	EndIf
		    EndIf
		    // Se foi selecionda Adm Financeira, e verificado valor taxa
		    // Se nao foi, nValTaxAdm continua com valor zero
		    If nValTaxAdm == 0
		    	nValTaxAdm := SAE->AE_TAXA
		    EndIf
	    Else
	    	nValTaxAdm := SAE->AE_TAXA
	    EndIf

		If 	AllTrim(aReceb[i][__FORMA]) $ "CC|VA|CO|CD|FI" .AND. SE1->(DbSeek(cSeek)) .AND. !lAdmin .AND. lAglutina

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao deve alterar o número da parcela para que o DbSeek continue funcionando...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAltParcela := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	Caso exista AE_TAXA > 0 cadastrada e se parametro MV_LJGERTX = .T., gera Contas a Receber³
			//|	com VALOR BRUTO sem desconto da taxa da administradora (AE_TAXA).					     ³
			//|	Sendo assim pode-se gerar um Contas a Pagar com o valor da Taxa para a administradora    ³
			//|	financeira e respeitar o fluxo de caixa.												 ³																													|
			//|	Colocado verificação de nValTaxAdm = MEN_TAXADM											 ³																													|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" })
			nPosVlReal 	:= aScan(aSE1,{|x| x[1] == "E1_VLRREAL" })

  			If lGeraTaxa
				If nPosValor > 0
					aSE1[nPosValor][2] := aSE1[nPosValor][2] + aReceb[i][__VALOR]
				Else
					AADD(aSE1,{ "E1_VALOR" ,SE1->E1_VALOR + aReceb[i][__VALOR]})
				EndIf 
			Else
				If nPosValor > 0
					aSE1[nPosValor][2] := aSE1[nPosValor][2] + aReceb[i][__VALOR] - (aReceb[i][__VALOR] * (nValTaxAdm / 100))
				Else
					AADD(aSE1,{"E1_VALOR",SE1->E1_VALOR + aReceb[i][__VALOR] - (aReceb[i][__VALOR] * (nValTaxAdm / 100))})
				EndIf 
			EndIf

			If nPosVlReal > 0 
				aSE1[nPosVlReal][2] := aSE1[nPosVlReal][2] + aReceb[i][__VALOR]
			Else
				AADD(aSE1,{"E1_VLRREAL",SE1->E1_VLRREAL + aReceb[i][__VALOR]})
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SED")
			SED->(DbSetOrder(1))
			SED->(DbSeek(xFilial("SED")+SE1->E1_NATUREZ))

			If SED->ED_CALCISS=="S" // Calcula ISS sobre o Valor de cada parcela 
	
				//Calculo e atribuição do campo SE1->E1_ISS
				nE1ValIss := aReceb[i][__VALOR] //Valor de cada parcela 
				LjCalcRecIss(	@nTotNFISS	, @nRestISS	, .F.	, .F.			,;
								nImpostos	, .F.		, i		, @nValE1ISS	,;
								@nE1ValIss	)
				
				AADD( aSE1 , { "E1_ISS" , nValE1ISS } )
				nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" })
				nPosVlReal 	:= aScan(aSE1,{|x| x[1] == "E1_VLRREAL" })
				If nPosValor > 0 .AND. nPosVlReal > 0	//Lembrando que o elemento já foi atribuído anteriormente
					aSE1[nPosValor][2] := (aSE1[nPosVlReal][2] - aReceb[i][__VALOR]) + nE1ValIss // LjCalcRecIss() calculou ISS o nE1ValIss deve ser atualizado.
				EndIf 
			EndIf

		Else
			If lIntegHtl //Integracao Hotel, nao gera financeiro para Formas de Pagamento contidas no parametro MV_LJFORHT
				If AllTrim(aReceb[i][__FORMA]) $ cPgtoHotel
					Loop
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria caixa p/ tratamento multi-moeda  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lCxEstrang := .F.
			If cPaisLoc <> "BRA" .AND. aReceb[i][__MOEDA] > 1
				lCxEstrang := .T.
				aAreaSA6 := SA6->(GetArea())
				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial("SA6")+SL1->L1_OPERADO))
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin -10) antes da funcao VerifCaixa", LMALERT, LMTECH)
				LjxDVerCx(aReceb[i][__MOEDA],SA6->A6_COD)
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin -11) depois da funcao VerifCaixa", LMALERT, LMTECH)
				RestArea(aAreaSA6)
			EndIf

			cE1Filial := xFilial("SE1")
			AADD( aSE1 , { "E1_FILIAL" , cE1Filial } )
			If cPrefE1 = cMVLOJASF  //Se Itens de Serviços Financeiros
				If Empty(SL1->L1_DOC)
					cNumPedSF := NxtSX5Nota( cMvLojaSF )
				Else
					cNumPedSF := SL1->L1_DOC
				EndIf
				cE1Num := cNumPedSF
				cE1Prefixo := cPrefE1
				cE1Portado := IIF(lScreen,xNumCaixa(),SL1->L1_OPERADO)
			Elseif lPedido
				cE1Num := cNumE1
				cE1Prefixo := cPrefE1
				cE1Portado := IIF(lScreen,xNumCaixa(),SL1->L1_OPERADO)
			ElseIf Empty(SL1->L1_DOC) 
				cE1Num := cNumE1
				cE1Prefixo := cPrefE1
				cE1Portado := SL1->L1_OPERADO
			ElseIf lIsVendaVP .Or. lIsVdRecCP
				cE1Num := cNumE1
				cE1Prefixo := cPrefE1
				cE1Portado := SL1->L1_OPERADO
			Else	
				cE1Num := cNumE1
				cE1Prefixo := SF2->F2_PREFIXO
				cE1Portado := SL1->L1_OPERADO
			EndIf

			AADD( aSE1 , { "E1_NUM" , cE1Num } )
			AADD( aSE1 , { "E1_PREFIXO" , cE1Prefixo } )
			AADD( aSE1 , { "E1_PORTADO" , cE1Portado } )

            AADD( aSE1 , { "E1_NRDOC" , SL1->L1_ECPEDEC } )

			If !lCxEstrang .OR. !IsMoney(aReceb[i][__FORMA])
				AADD( aSE1 , { "E1_AGEDEP" , aDadosBanc[1] } )
			Else
				AADD( aSE1 , { "E1_AGEDEP" , aReceb[i][__FORMA] } )
			EndIf

			AADD( aSE1 , { "E1_CONTA" , aDadosBanc[2] } )
			
			//Tratamento Hotel - Forma de Pagamento dinheiro quando cliente utilizou adiantamento
			If lIntegHtl .And. AllTrim(aReceb[i][__FORMA]) == "RA"
				cE1Tipo := "R$"
				AADD( aSE1 , { "E1_TIPO" , cE1Tipo } )	
			Else
				cE1Tipo := AllTrim(aReceb[i][__FORMA])
				AADD( aSE1 , { "E1_TIPO" , cE1Tipo } )
			EndIf 
			
			AADD( aSE1 , { "E1_SITUACA" , IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM, AllTrim(aReceb[i][__FORMA]), cE1Portado),"0") } )
			AADD( aSE1 , { "E1_ORIGEM" 	, cOrigem } )
			AADD( aSE1 , { "E1_MULTNAT" , "2" } )
			AADD( aSE1 , { "E1_FLUXO" 	, "S" } )

			If SE1->(ColumnPos ("E1_SCORGP")) > 0	//Campo da tabela SE1 que identifica fornecimento de (1) bens e Servicos contratados por pessoa juridica de direito publico ou (2 ou '') identifica que Nao.
				If ("1"$cA1M996) .And. ("1"$cB1M996)
					AADD( aSE1 , { "E1_SCORGP" , "1" } )
				EndIf
			EndIf

			If ( lUsaTef .And. AllTrim(aReceb[i][__FORMA]) $ __FORMATEF + _FORMAPGDG ) .Or. lIntegDef //Forma de pagamento TEF ou Pagamento Digital e PIX
				If SE1->(ColumnPos("E1_NSUTEF")) > 0
					AADD( aSE1 , { "E1_NSUTEF" , aReceb[i,__NSUTEF] } )
				Endif
				If SE1->(ColumnPos("E1_DOCTEF")) > 0
					AADD( aSE1 , { "E1_DOCTEF" , aReceb[i,__DOCTEF] } )
				EndIF
				If SE1->(ColumnPos("E1_CARTAUT")) > 0             
					AADD( aSE1 , { "E1_CARTAUT" , aReceb[i,__AUTORIZ] } )
                EndIf
            Else
            	//Numa venda com cartão e cheque, o cheque assumia os valores desses campos preenchidos do cartão
            	If SE1->(ColumnPos("E1_NSUTEF")) > 0
					AADD( aSE1 , { "E1_NSUTEF" , "" } )
				Endif
				If SE1->(ColumnPos("E1_DOCTEF")) > 0
					AADD( aSE1 , { "E1_DOCTEF" , "" } )
				EndIF
				If SE1->(ColumnPos("E1_CARTAUT")) > 0             
					AADD( aSE1 , { "E1_CARTAUT" , "" } )
                EndIf
			EndIf

			If lMultNegoc .And. Len(aReceb[i]) > __NRECNO
				AADD( aSE1 , { "E1_DESCONT" , Round(aReceb[i,__DESCMN]	,2) } )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Somente considerar a taxa do SAE quando nao for DINHEIRO ou CHEQUE.                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (AllTrim(aReceb[i][__FORMA]) == "CH") .OR. (AllTrim(aReceb[i][__FORMA]) == SuperGetMV("MV_SIMB1"))
				nE1Valor := aReceb[i][__VALOR]
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|	Caso exista AE_TAXA > 0 cadastrada e se parametro MV_LJGERTX = .T., gera Contas a Receber³
				//|	com VALOR BRUTO sem desconto da taxa da administradora (AE_TAXA).					     ³
				//|	Sendo assim pode-se gerar um Contas a Pagar com o valor da Taxa para a administradora    ³
				//|	financeira e respeitar o fluxo de caixa.												 ³																													|
				//|	Colocado verificação de nValTaxAdm = MEN_TAXADM											 ³																													|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGeraTaxa
					nE1Valor := aReceb[i][__VALOR]
				Else
					lUltParc := Alltrim(aReceb[i][__FORMA]) $ __FORMATEF .AND.;				//Verifica se é um pagamento TEF 
						(i == len(aReceb) .OR.;												//Verifica se é a ultima parcela
						aReceb[i][__FORMA]+aReceb[i][__ADMINIS]+aReceb[i][__FORMAID] !=;	//Compara se a transação da parcela atual
						aReceb[i+1][__FORMA]+aReceb[i+1][__ADMINIS]+aReceb[i+1][__FORMAID])	//é a mesma da próxima parcela
						
					nParTx := aReceb[i][__VALOR] - (aReceb[i][__VALOR] * (nValTaxAdm / 100))//Guarda o valor da parcela já descontando TX adm
					nArreAux += nParTx - noRound(nParTx,2)//Guarda diferença da terceira casa decimal em diante
					
					//A diferença só é gravada caso menor que 1 como proteção devido a eventuais situações que venham alterar o calculo
					nE1Valor := NoRound(nParTx,2) + If(lUltParc .AND. nArreAux < 1 , Round(nArreAux,2),0) //Caso ultuma parcela adiciona a diferença
						 
					If(lUltParc, nArreAux := 0,)
					
				EndIf

			EndIf

			nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" })
			nPosVlReal 	:= aScan(aSE1,{|x| x[1] == "E1_VLRREAL" })

			If nPosValor = 0
				AADD( aSE1 , { "E1_VALOR" , nE1Valor } )
			Else
				aSE1[nPosValor][2] := nE1Valor
			EndIf

			nE1VlrReal := aReceb[i][__VALOR]
			If nPosVlReal = 0
				AADD( aSE1 , { "E1_VLRREAL" , nE1VlrReal } )
			Else
				aSE1[nPosVlReal][2] := nE1VlrReal
			EndIf 

			If Empty(SL1->L1_EMISNF) .AND. !lECommerce
				dE1Emissao := dDatabase
				AADD( aSE1 , { "E1_EMISSAO" , dE1Emissao } )
				AADD( aSE1 , { "E1_EMIS1" 	, dDatabase } )
			ElseIf lECommerce
				dE1Emissao := SL1->L1_EMISSAO
				AADD( aSE1 , { "E1_EMISSAO" , dE1Emissao } )
				AADD( aSE1 , { "E1_EMIS1" 	, SL1->L1_EMISSAO } )
			Else
				dE1Emissao := SL1->L1_EMISNF
				AADD( aSE1 , { "E1_EMISSAO" , dE1Emissao } )
				AADD( aSE1 , { "E1_EMIS1" 	, SL1->L1_EMISNF } )
			EndIf
			If cPaisLoc == "BRA"
				nE1Moeda := 1
				AADD( aSE1 , { "E1_MOEDA" , nE1Moeda } )
			Else
				nE1Moeda := aReceb[i][__MOEDA]
				AADD( aSE1 , { "E1_MOEDA" , nE1Moeda } )
			EndIf

			AADD( aSE1 , { "E1_STATUS" , "A" } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Nome do Emitente em caso de Cheque de Terceiros   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aReceb[i,__TERCEIR]
				AADD( aSE1 , { "E1_EMITCHQ" , aReceb[i][__EMITENT] } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se trabalha com conceito de acrescimo separado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If (lVerEmpres .AND. (cFilAnt $ cMvFiliais)	) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
				AADD( aSE1 , { "E1_ACRESC" 	, aReceb[i][__ACRSFIN] } )
				AADD( aSE1 , { "E1_SDACRES" , aReceb[i][__ACRSFIN] } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajusta a modalidade de pagamento quando o parametro³
			//³MV_USASPB estiver ativo                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaSPB
				AADD( aSE1 , { "E1_MODSPB" , "1" } )
			EndIf

			If lFtvdVer12

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SED")
				DbSetOrder(1)
				DbSeek(xFilial("SED") + cE1Naturez )

				If SED->ED_CALCISS=="S"
					//Calculo e atribuição do campo SE1->E1_ISS
					LjCalcRecIss(	@nTotNFISS	, @nRestISS	, .F.	, .F.			,;
									nImpostos	, .F.		, i		, @nValE1ISS	,;
									@nE1Valor	)
					
					nPosISS	:= aScan(aSE1,{|x| x[1] == "E1_ISS" })
					nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" })

					AADD( aSE1 , { "E1_ISS" , nValE1ISS } )
					If nPosISS = 0
						AADD( aSE1 , { "E1_ISS" , nValE1ISS } )
					Else
						aSE1[nPosISS][2] := nValE1ISS
					EndIf
					If nPosValor = 0
						AADD( aSE1 , { "E1_VALOR" , nE1Valor } )
					Else
						aSE1[nPosValor][2] := nE1Valor
					EndIf
				EndIf

			EndIf

			If lPedido
				AADD( aSE1 , { "E1_SERIE", "SE1", 1, "E1_SERIE", dDataBase, SL1->L1_SERPED } )
			Else
				AADD( aSE1 , { "E1_SERIE", "SE1", 1, "E1_SERIE", dDataBase, SL1->L1_SERIE } )
			EndIf

			AADD( aSE1 , { "E1_FILORIG" , cFilAnt } )
			AADD( aSE1 , { "E1_NUMNOTA" , cL1Doc } )
			AADD( aSE1 , { "E1_NUMCART" , aReceb[i][__NUMCART] } )

			For nVend := 1 To Min(Len(aVendedor),5) //  So existem 5 campos no SD2 e SE1
				nBaseCom :=  Round((aVendedor[nVend][3] / (nVlTotal+ nNccUsada) ) * nE1VlrReal,nDecimal )
				AADD( aSE1 , { "E1_VEND" + Str(nVend,1)		, aVendedor[nVend][1] } )
				AADD( aSE1 , { "E1_COMIS" + Str(nVend,1) 	, aVendedor[nVend][2] } )
				AADD( aSE1 , { "E1_BASCOM"+ Str(nVend,1) 	, nBaseCom } )
			Next nVend
		EndIf

		Do Case
			Case AllTrim(aReceb[i][__FORMA]) == "CH"	// Cheques

		 		nPCH ++
				cParcela := LJParcela(nPCH, c1DUP)
				cE1Parcela := cParcela
				AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
				dE1Vencto := aReceb[i][__DATA]
				AADD( aSE1 , { "E1_VENCTO" 	, dE1Vencto } )
				AADD( aSE1 , { "E1_CLIENTE" , SA1->A1_COD } )
				AADD( aSE1 , { "E1_LOJA" 	, SA1->A1_LOJA } )
				AADD( aSE1 , { "E1_NOMCLI" 	, SA1->A1_NREDUZ } )
				cE1Naturez := LjMExeParam("MV_NATCHEQ")
				AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
				AADD( aSE1 , { "E1_BCOCHQ" 	, aReceb[i][__ADMINIS] } )
				AADD( aSE1 , { "E1_AGECHQ" 	, aReceb[i][__AGENCIA] } )
				AADD( aSE1 , { "E1_CTACHQ" 	, aReceb[i][__CONTA] } )
				AADD( aSE1 , { "E1_HIST" 	, "" } )

				If cPaisLoc == "PAR" .AND. SE1->(ColumnPos("E1_NUMCHQ")) > 0
				   AADD( aSE1 , { "E1_NUMCHQ" , aReceb[i][__NUMCART] } )
				EndIf

			// Cartao Credito, Vales, Vale-Presente, Convenio, Cartao de Debito, Financiamento, Cartao Fidelidade, Pagto Digital, PIX (R11.5)
			Case AllTrim(aReceb[i][__FORMA]) $ "CC|VA|CO|CD|FI|BO|BOL|PD|PX" .OR.;
				(AllTrim(aReceb[i][__FORMA]) $ "VP" .AND. lUsaVP) .OR.;
				(AllTrim(aReceb[i][__FORMA]) $ "FID" .AND. lLjcFid)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Somente altera as informacoes:                        ³
				//³ - Cod. Cliente --> cCodCliFin                         ³
				//³ - Nome Cliente --> cCliFin                            ³
				//³ - Loja Cliente --> cLojaFin                           ³
				//³ - Vencimento   --> dSaeVencto                         ³
				//³ - Natureza     --> cNatureza                          ³
				//³ - Porc. Juros  --> cPorJur                            ³
				//³ quando for criar um novo titulo, pois quando for      ³
				//³ gerado um unico titulo, para juros pela adminis-      ³
				//³ tradora, estas informacoes nao precisam ser alteradas.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAltParcela
					If lAdmProp
						DbSelectArea("SA1")
						SA1->(DbSetOrder(1))
						SA1->( MsSeek( xFilial("SA1") + SL1->L1_CLIENTE+SL1->L1_LOJA) )
						cCodCliFin	:= SA1->A1_COD
						cCliFin		:= SA1->A1_NREDUZ
						cLojaFin	:= SA1->A1_LOJA
						dE1Vencto := aReceb[i][__DATA]
						AADD( aSE1 , { "E1_VENCTO", dE1Vencto } )
					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica no parametro se gera um Contas a Pagar ³
						//³ quando existir taxa na admistradora do cartao   ³
						//³ para fazer a gravacao do SA2 do fornecedor      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lGeraTaxa
							LjGravaLog( lScreen, cNumOrc, "LjGrvFin -14) antes da funcao L070IncSA2 - 2", LMALERT, LMTECH)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Inclui o Fornecedor caso nao tenha sido cadastrado,³
							//³e retorna com o codigo para gerar SE2              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cNumSA2 := L070IncSA2()
							LjGravaLog( lScreen, cNumOrc, "LjGrvFin -15) depois da funcao L070IncSA2 - 2", LMALERT, LMTECH)
						Endif

                        If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                            cCodCliFin  := SAE->AE_CODCLI
                            cLojaFin    := SAE->AE_LOJCLI
                        Else
                            
                            //Inclui Administradora como cliente para geração do contas a receber
                            LjGravaLog(lScreen, cNumOrc, "LjGrvFin -16) antes da funcao L070IncSA1 - 2" , LMALERT, LMTECH)
                            L070IncSA1()
                            LjGravaLog(lScreen, cNumOrc, "LjGrvFin -17) depois da funcao L070IncSA1 - 2", LMALERT, LMTECH)

                            cCodCliFin	:= SAE->AE_COD
                            cLojaFin	:= "01"         //O cliente eh criado com A1_LOJA = "01" no LOJA070.
                        EndIf

                        cCliFin    := SAE->AE_DESC
						lNotFinPro := .T.

						nPosReceb := aScan( aTotReceb,{|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aReceb[i][__FORMA])+Alltrim(aReceb[i][__FORMAID]) })

						dDtVencSE1 := LJCalcVenc(.F., dDtVencSE1, lScreen, aReceb[i][__DATA], @cDiaVen, aTotReceb[nPosReceb][4]) //Calcula o vencimento da parcela

						dE1Vencto := dDtVencSE1
						AADD( aSE1 , { "E1_VENCTO" , dE1Vencto } )
					EndIf

					Do Case
						Case AllTrim(aReceb[i][__FORMA]) == "VA"
							nPVA ++
							cParcela	:= LJParcela(nPVA, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATVALE")
						Case AllTrim(aReceb[i][__FORMA]) == "VP"
							nPVP ++
							cParcela	:= LJParcela(nPVP, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATVALE")
						Case AllTrim(aReceb[i][__FORMA]) == "CC"
							nPCC ++
							cParcela	:= LJParcela(nPCC, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATCART")
						Case AllTrim(aReceb[i][__FORMA]) == "CD"
							nPCD ++
							cParcela	:= LJParcela(nPCD, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATTEF")
						Case AllTrim(aReceb[i][__FORMA]) == "CO"
							nPCO ++
							cParcela	:= LJParcela(nPCO, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATCONV")
						Case AllTrim(aReceb[i][__FORMA]) == "FI"
							nPFI ++
							cParcela := LJParcela(nPFI, c1DUP)

							/* Conta Corrente - Natureza */
							If lCtaCorren
	                            cNatureza := LjMExeParam( "MV_NATCCOR" , .F. , "OUTROS")
							Else
								cNatureza := LjMExeParam("MV_NATFIN")
							Endif

						/*Release 11.5 - Cartao Fidelidade*/
       					Case AllTrim(aReceb[i][__FORMA]) == "FID"
							nPFID ++
							cParcela	:= LJParcela(nPFID, c1DUP)
							cNatureza	:= LjMExeParam("MV_LJNATFI")
						Case AllTrim(aReceb[i][__FORMA]) $ "BO|BOL"
							nPBOL ++
							cParcela	:= LJParcela(nPBOL, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATFIN")
						Case AllTrim(aReceb[i][__FORMA]) $ "PD" //Pagamento Digital
							nPPD ++
							cParcela	:= LJParcela(nPPD, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATPGDG", .F. , "PAGDIGITAL")
							//Verifica se existe a Natureza configurada no parametro MV_NATPGDG
							cNatureza	:= AllTrim(GetAdvFVal("SED","ED_CODIGO",xFilial("SED") + cNatureza,1,""))
							If Empty(cNatureza)
								cNatureza	:= LjMExeParam("MV_NATOUTR")
							EndIf
						Case AllTrim(aReceb[i][__FORMA]) == "PX" //Pagamento Digital
							nPPD ++
							cParcela	:= LJParcela(nPPD, c1DUP)
							cNatureza	:= LjMExeParam("MV_NATPGPX", .F. , "PAGTOPIX")
							//Verifica se existe a Natureza configurada no parametro MV_NATPGPX
							cNatureza	:= AllTrim(GetAdvFVal("SED","ED_CODIGO",xFilial("SED") + cNatureza,1,""))
							If Empty(cNatureza)
								cNatureza	:= LjMExeParam("MV_NATOUTR")
							EndIf
					EndCase

					If lNotFinPro

						Aadd(aRegNomE1,{	PadR(cCodCliFin,nTamSx3A1),;
											cLojaFin,;
											cE1Prefixo,;
											cE1Num,;
											cParcela,;
											AllTrim(aReceb[i][__FORMA]),;
											SAE->AE_DESC})

						lNotFinPro := .F.
					EndIf
					
					LjGrvLog(cNumOrc,"PARCELA DO TITULO - APÓS AJUSTE - [Para formas diferente de dinheiro pode haver mudança]", cParcela)
					cE1Parcela := cParcela
					AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
					AADD( aSE1 , { "E1_CLIENTE" , cCodCliFin } )
					AADD( aSE1 , { "E1_LOJA" 	, cLojaFin } )
					AADD( aSE1 , { "E1_NOMCLI" 	, cCliFin } )
					cE1Naturez := cNatureza
					AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
					AADD( aSE1 , { "E1_PORCJUR" , nPerJur } )

				EndIf

				AADD( aSE1 , { "E1_VALJUR" , nE1ValJur + Round(aReceb[i][__VALOR] * (nPerJur / 100),2) } )
				AADD( aSE1 , { "E1_HIST" 	, "" } ) 

				// Gravacao no SE1 dos campos utilizandos pelo conciliador TEF
				If AllTrim(aReceb[i][__FORMA]) $ __FORMATEF + "/" + _FORMAPGDG //Forma de pagamento TEF ou Pagamento Digital
				   If SE1->(ColumnPos("E1_NSUTEF")) > 0
					  AADD( aSE1 , { "E1_NSUTEF" , aReceb[i,__NSUTEF] } )
				   Endif
				   If SE1->(ColumnPos("E1_DOCTEF")) > 0
					  AADD( aSE1 , { "E1_DOCTEF" , aReceb[i,__DOCTEF] } )
				   Endif
				   If SE1->(ColumnPos("E1_CARTAUT")) > 0             
					  AADD( aSE1 , { "E1_CARTAUT" , aReceb[i,__AUTORIZ] } )
                   EndIf					

				   If lAltParcela .and. lGrvMEP
				   		nParcMEP++ //Incrementa o contador TEF
				   		DbSelectArea("MEP")
				   		DbSetOrder(1) //MEP_FILIAL+MEP_PREFIX+MEP_NUM+MEP_PARCEL+MEP_TIPO+MEP_PARTEF
						   If !DbSeek(xFilial("MEP")+ cE1Prefixo + cE1Num + cE1Parcela + cE1Tipo + StrZero(nParcMEP, nTamParTEF) )
					   		RecLock("MEP", .T.)

							REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
					   		REPLACE MEP->MEP_PREFIX WITH cE1Prefixo
					   		REPLACE MEP->MEP_NUM 	WITH cE1Num
					   		REPLACE MEP->MEP_PARCEL WITH cE1Parcela
					   		REPLACE MEP->MEP_TIPO   WITH cE1Tipo
					   		REPLACE MEP->MEP_PARTEF WITH StrZero(nParcMEP, nTamParTEF)

					   		MEP->(MsUnLock())
					   		MEP->(FkCommit())
					   	EndIf
				   EndIf
				Endif
			Case (cPaisLoc <> "BRA") .AND. IsMoney(aReceb[i,__FORMA])
				nPDI ++

				cE1Parcela := LJParcela(nPDI, c1DUP)
				AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
				dE1Vencto := aReceb[i][__DATA]
				AADD( aSE1 , { "E1_VENCTO" 	, dE1Vencto } )
				AADD( aSE1 , { "E1_CLIENTE" , SA1->A1_COD } )
				AADD( aSE1 , { "E1_LOJA" 	, SA1->A1_LOJA } )
				AADD( aSE1 , { "E1_NOMCLI" 	, SA1->A1_NOME } )
				AADD( aSE1 , { "E1_SALDO" 	, 0 } )
                cE1Naturez := cNatDinh
				AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
				AADD( aSE1 , { "E1_HIST" 	, STR0080 } ) //"VENDA EM DINHEIRO"
				AADD( aSE1 , { "E1_STATUS" 	, "B" } )

				If Empty(SL1->L1_EMISNF)
					AADD( aSE1 , { "E1_BAIXA" , dDataBase } )
				Else
					AADD( aSE1 , { "E1_BAIXA" , SL1->L1_EMISNF } )
				EndIf

				AADD( aSE1 , { "E1_VALLIQ" , nE1Valor } )

			OtherWise
				If !lFtvdVer12
					nPOU ++
				ElseIf lFtvdVer12
					//Se mudar a forma de pagamento, inicializa a contagem das parcelas.
					If cFormaAnt <> AllTrim(aReceb[i][__FORMA])
						nPOU := 1
					Else
						nPOU ++
					EndIf
				EndIf

				If lIntegHtl .And. AllTrim(aReceb[i][__FORMA]) == "RA" //Integracao hotel e Forma de Pagamento RA					
					AADD( aSE1 , { "E1_HIST" , STR0180 } ) //"ADIANT. CLIENTE HOTEL"
					nPOUCmp ++
					cE1Parcela := LJParcela(nPOUCmp, c1DUPRa)
					AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
				Else
					cE1Parcela := LJParcela(nPOU, c1DUP)
					AADD( aSE1 , { "E1_PARCELA" , cE1Parcela } )
				EndIf
				
				dDtVencSE1 := aReceb[i][__DATA]
				
				If !Empty(aReceb[i][__ADMINIS])
					dDtVencSE1 := LJCalcVenc(.F., dDtVencSE1, lScreen, aReceb[i][__DATA], @cDiaVen ) //Calcula o vencimento da parcela
				EndIf

				dE1Vencto := dDtVencSE1
				AADD( aSE1 , { "E1_VENCTO" , dE1Vencto } )
                //Financiamento proprio
				If lAdmProp

					cCodCliFin	:= SA1->A1_COD
					cCliFin		:= SA1->A1_NREDUZ
					cLojaFin	:= SA1->A1_LOJA
				Else

                    If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                        cCodCliFin  := SAE->AE_CODCLI
                        cLojaFin    := SAE->AE_LOJCLI
                    Else

                        //Inclui Administradora como cliente para geração do contas a receber
					    L070IncSA1()

					    cCodCliFin	:= SAE->AE_COD
					    cLojaFin	:= "01"
                    EndIf

                    cCliFin := SAE->AE_DESC
				EndIf

				AADD( aSE1 , { "E1_CLIENTE" , cCodCliFin } )
				AADD( aSE1 , { "E1_LOJA" 	, cLojaFin } )
				AADD( aSE1 , { "E1_NOMCLI" 	, cCliFin } )
				
				If lIntegHtl .And. AllTrim(aReceb[i][__FORMA]) == "FA" //Integracao hotel e Forma de Pagamento FA
					cE1Naturez := SuperGetMV("MV_NATFATU",, "")
					AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
				ElseIf lIntegHtl .And. AllTrim(aReceb[i][__FORMA]) == "RA" //Integracao hotel e Forma de Pagamento RA
                    cE1Naturez := cNatDinh
					AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
				Else
					cE1Naturez := Iif(AllTrim(aReceb[i][__FORMA])=="CR",&(SuperGetMV("MV_NATCRED")),&(SuperGetMV("MV_NATOUTR")))
					AADD( aSE1 , { "E1_NATUREZ" , cE1Naturez } )
				EndIf
				
				AADD( aSE1 , { "E1_PORCJUR" , nPerJur } )
				nE1ValJur := Round( aReceb[i][__VALOR] * (nPerJur /100),2)
				AADD( aSE1 , { "E1_VALJUR" , nE1ValJur } )

				If lFtvdVer12
					cFormaAnt := AllTrim(aReceb[i][__FORMA])
				EndIf
		EndCase

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SED")
		DbSetOrder(1)
		MsSeek(xFilial("SED") + cE1Naturez )

		If SED->ED_CALCISS=="S" 
			//Calculo e atribuição do campo SE1->E1_ISS
			LjCalcRecIss(	@nTotNFISS	, @nRestISS	, lAltParcela	, .F.			,;
							nImpostos	, .F.		, i				, @nValE1ISS	,;
							@nE1Valor	)

			AADD( aSE1 , { "E1_ISS" , nValE1ISS } )
			If !lAglutina // Quando é aglutina o calculo ISS é feito na linha 6892 
				AADD( aSE1 , { "E1_VALOR" , nE1Valor } )
			Else
				nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" }) //Atualiza o valor ISS no Array E1_VALOR
				If Len(aReceb) > 0 .AND. Valtype(i) <> "U" .AND. i == 1 //verifica se é a primeira vez depois o calculo é feito na linha 6892 
					aSE1[nPosValor][2] := nE1Valor
				EndIf	
			EndIf	
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|   So atualiza o saldo caso nao seja dinheiro...   |
		//|   vale-presente OU Cartão fidelidade (R11.5)      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !IsMoney(aReceb[i,__FORMA]) .AND. aReceb[i,__FORMA] <> "VP" .AND. AllTrim(aReceb[i,__FORMA]) <> "FID" .AND. !lAglutina
			AADD( aSE1 , { "E1_SALDO" , nE1Valor } )
		EndIf

		// Ajuste para E1_VLCRUZ considerar o E1_VALOR quando lAglutina = .T. 
		If AllTrim(aReceb[i][__FORMA]) $ "CC|VA|CO|CD|FI" .AND. SE1->(DbSeek(cSeek)) .AND. !lAdmin .AND. lAglutina
			nPosValor	:= aScan(aSE1,{|x| x[1] == "E1_VALOR" })
			nPosVCruz   := aScan(aSE1,{|x| x[1] == "E1_VLCRUZ" })
			If nPosValor > 0
				If nPosVCruz > 0
					aSE1[nPosVCruz][2] := xMoeda(aSE1[nPosValor][2], nE1Moeda, 1, dE1Emissao)
				Else
					AADD( aSE1	, { "E1_VLCRUZ", xMoeda(aSE1[nPosValor][2], nE1Moeda, 1, dE1Emissao)} )
				EndIf

				//Recalcular Comissões E1_BASCOM1 caso aglutina parcelas
				For nVend := 1 To Min(Len(aVendedor),5) // So existem 5 campos no SD2 e SE1

					If IsBlind() .AND. (nVlTotal + SL1->L1_CREDITO) > 0 .AND. !lComiDev
						nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + SL1->L1_CREDITO) ) * aSE1[nPosValor][2],nDecimal )
					ElseIf (nVlTotal + nNccUsada) > 0
						nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + nNccUsada) ) * aSE1[nPosValor][2],nDecimal )
					Else
						nBaseCom := 0
					EndIf

					AADD( aSE1 , { "E1_VEND"+Str(nVend,1) 	, aVendedor[nVend][1] } )
					AADD( aSE1 , { "E1_COMIS"+Str(nVend,1) 	, aVendedor[nVend][2] } )
					AADD( aSE1 , { "E1_BASCOM"+Str(nVend,1) , nBaseCom } )
					AADD( aSE1 , { "E1_VALCOM"+Str(nVend,1) , Round(nBaseCom * (aVendedor[nVend][2]/100),nDecimal) } )
				Next nVend

			EndIf
		Else
			AADD( aSE1 , { "E1_VLCRUZ" 	, xMoeda(nE1Valor, nE1Moeda, 1, dE1Emissao) } )
		EndIf
		
		AADD( aSE1 , { "E1_VENCREA" , DataValida(dE1Vencto,.T.) } )
		AADD( aSE1 , { "E1_VENCORI" , dE1Vencto } )

		//Gravação do Campo CNAB para controle Financeiro
		If lIDCNAB .And. !Empty(aReceb[i,__IDCNAB] )
			AADD( aSE1 , { "E1_IDCNAB" , aReceb[i,__IDCNAB] } )
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetuar o calculo do IRRF conforme natureza         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nE1IRRF := NoRound(nTotNFIRRF/nImpostos,2)
		nRestIRRF +=  nE1IRRF
		If i == nImpostos
			nTotNFIRRF  := nRestIRRF := 0
			nE1IRRF := nE1IRRF + nTotNFIRRF - nRestIRRF
		EndIf

		If cPaisLoc == "BRA" .AND. lFirstDupRec
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo para o valor do PIS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nE1PIS := NoRound(nValPIS/nImpostos,2)
			nRestPIS  += nE1PIS
			If nImpostos == i
				nValPIS  := 0
				nRestPIS := 0
				AADD( aSE1 , { "E1_PIS" , nE1PIS + nValPIS - nRestPIS } )
			Else
				AADD( aSE1 , { "E1_PIS" , nE1PIS } )	
			EndIf

			AADD( aSE1 , { "E1_BASEPIS" , nBasePIS } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo para o valor do Cofins³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nE1COFINS := NoRound(nValCOFI/nImpostos,2)
			nRestCOFI += nE1COFINS
			If nImpostos == i
				nValCOFI  := 0
				nRestCOFI := 0
				AADD( aSE1 , { "E1_COFINS" , nE1COFINS + nValCOFI - nRestCOFI } )
			Else
				AADD( aSE1 , { "E1_COFINS" , nE1COFINS } )	
			EndIf

			AADD( aSE1 , { "E1_BASECOF" , nBaseCOFI } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo para o valor do CSLL  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nE1CSLL := NoRound(nValCSLL / nImpostos,2)
			nRestCSLL +=  nE1CSLL
			If nImpostos == i
				nValCSLL  := 0
				nRestCSLL := 0
				AADD( aSE1 , { "E1_CSLL" , nE1CSLL + nValCSLL - nRestCSLL } )
			Else
				AADD( aSE1 , { "E1_CSLL" , nE1CSLL } )	
			EndIf

			AADD( aSE1 , { "E1_BASECSL" , nBaseCSLL } )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo para o valor do INSS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nE1INSS := NoRound(nValINSS / nImpostos,2)
			nRestINSS +=  nE1INSS
			If nImpostos == i
				nValINSS  := 0
				nRestINSS := 0
				AADD( aSE1 , { "E1_INSS" , nE1INSS + nValINSS - nRestINSS } )
			Else
				AADD( aSE1 , { "E1_INSS" , nE1INSS } )
			EndIf

			AADD( aSE1 , { "E1_BASEINS" , nBaseINSS } )	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo para o valor do IRRF  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nE1IRRF := NoRound(nValIRRF / nImpostos,2)
			nRestIRRF += nE1IRRF
			If nImpostos == i
				nValIRRF  := 0
				nRestIRRF := 0
				nE1IRRF := nE1IRRF + nValIRRF - nRestIRRF
			EndIf

			AADD( aSE1 , { "E1_BASEIRF" , nBaseIRRF } )

		EndIf

		AADD( aSE1 , { "E1_IRRF" , nE1IRRF } )

		//Alimenta campo Conta do Cliente - Integracao Hotel
		If lIntegHtl
			//Armazena Reserva Hotel
			AADD( aSE1 , { "E1_CONHTL" , SL1->L1_RESEHTL } )					
		EndIf

		// Envia para gravação da SE1
		lRet := LjGrFinSE1( aSE1, cE1Filial, cE1Prefixo, cE1Num, cE1Parcela, cE1Tipo, @nE1Recno, lAglutina )

		// Os dados do cheque serão limpos, pois o array aSE1
		// qdo tinha uma forma de pagamento igual a cheque e 
		// na proxima forma de pagto os dados do cheque era gravados
		// A chacagem do campo não vazio, se deve porque no array aSE!,
		// pode ter mais de um cheque.
		If cE1Tipo == "CH"				
			For nCountaSE1 = 1 to Len(aSE1)
				If aSE1[nCountaSE1,1] == "E1_BCOCHQ"  .AND. !Empty(aSE1[nCountaSE1,2])
					aSE1[nCountaSE1,2] := ""
				EndIf					
				If aSE1[nCountaSE1,1] == "E1_AGECHQ"  .AND. !Empty(aSE1[nCountaSE1,2])
					aSE1[nCountaSE1,2] := ""
				EndIF	
				If aSE1[nCountaSE1,1] == "E1_CTACHQ"  .AND. !Empty(aSE1[nCountaSE1,2])
					aSE1[nCountaSE1,2] := ""
					Exit
				EndIf
			Next
		EndIf	

		If !lRet
			LjGrvLog(cE1Num, "Registro já existe na tabela do Contas a Receber (SE1), verifique e efetue o processo novamente." )
			cDescErro +=	STR0187						+ CTRL +; 	// "Registro já existe na tabela do Contas a Receber (SE1), verifique e efetue o processo novamente."
							STR0188		+ cE1Prefixo 	+ CTRL +;	// "Prefixo: "
							STR0030+":"	+ cE1Num		+ CTRL +;	// "Número"
							STR0189		+ cE1Parcela 	+ CTRL +;	// "Parcela: "
							STR0190		+ cE1Tipo 		+ CTRL		// "Tipo: "

			If !lLjGrvOn 
				LjGravaLog( lScreen, cNumOrc, cDescErro, LMALERT, LMTECH)
			EndIf

		Else

			// Garante o posicionamento do registro
			SE1->( dbGoTo(nE1Recno) )

			If lIntegHtl
				If AllTrim(aReceb[i][__FORMA]) == "RA"				
					aAdd(aRecRa, {SE1->(Recno()), Val(aReceb[i][__CONHTL]), dE1Emissao })
				EndIf
			Endif	

			aAdd( aRecnoFin, { "SE1", SE1->E1_NUM, SE1->(Recno()) } )

			If lRecSe1 .AND. Len(aReceb[i]) >= 18 .AND. aReceb[i][__NRECNO] <> 0
				aAreaSL4 := GetArea()
				nRecnoSE1 := SE1->(Recno())

				dbSelectArea("SL4")
				SL4->(DbSetOrder(1))
				SL4->(DbGoto(aReceb[i][__NRECNO]))
				RecLock( "SL4",.F.)

				REPLACE SL4->L4_RECSE1 WITH nRecnoSE1

				SL4->(MsUnlock())
				SL4->(FkCommit())

				RestArea(aAreaSL4)
			Endif

			If cPaisLoc == "MEX"
				DbSelectArea( "SE1" )
				If AllTrim(SF2->F2_COND) <> "CN"
					// a função abaixo não há cálculo de parcela na multinegociação
					// se for SigaLoja ou SigaFrt
					If ! (nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72)
						RcFatMex(.T.,lScreen)
					Endif
				Else
					RcLojMex(lScreen)
				EndIf
			EndIf

			If lOriFun .AND. lGerInt
				oIntVenda:Inserir("SE1", xFilial("SE1") +  SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "1", "3")
			EndIF

			If ( aScan(aRegSE1, { |x| x == SE1->(RecNo()) }) == 0 )
				aadd( aRegSE1, SE1->(Recno()) )
				aAdd( aFinProp, lAdmProp )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for Vale-Presente, grava o recebimento na MDD³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e
			If !lNFePDV .and. lUsaVP .AND. Alltrim(aReceb[i][__FORMA]) == "VP"
				LjGrRVlPre(	aReceb[i][__NUMCART]	, SL1->L1_OPERADO	, SL1->L1_DOC	, SL1->L1_ESTACAO,;
							SL1->L1_PDV			 	, SL1->L1_EMISNF	, SL1->L1_HORA	, SL1->L1_CLIENTE,;
							SL1->L1_LOJA 			, SL1->L1_SERIE )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se os impostos financeiros serão atribuidos  ³
			//³na 1a. parcela ou rateados em todas as parcelas.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFirstDupRec
				If !SuperGetMV("MV_RTIPFIN", NIL, .F.)
					lFirstDupRec := .F.
				EndIf
			EndIf

			//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e
			If !lNFePDV .and. AllTrim(aReceb[i][__FORMA]) == "CH"	// Cheques
				If lFtvdVer12
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Historico do Cheque para gravar na tabela SEF   		  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nIHist := 1 To Len(aPgtos)
						If AllTrim(aPgtos[nIHist][3]) == AllTrim(MVCHEQUE) .AND. Len(aPgtos[nIHist][4]) >= 15 .AND.;
							AllTrim(aPgtos[nIHist][4][7]) == AllTrim(aReceb[i][__NUMCART]) .AND.;
							AllTrim(aPgtos[nIHist][4][5]) == AllTrim(aReceb[i][__AGENCIA]) .AND.;
							AllTrim(aPgtos[nIHist][4][6]) == AllTrim(aReceb[i][__CONTA])
							cHist := aPgtos[nIHist][4][15]
						EndIf
					Next nIHist
				EndIf

				RecLock( "SEF" , .T. )
				REPLACE SEF->EF_FILIAL	WITH xFilial("SEF")
				REPLACE SEF->EF_BANCO	WITH aReceb[i][__ADMINIS]
				REPLACE SEF->EF_AGENCIA	WITH aReceb[i][__AGENCIA]
				REPLACE SEF->EF_CONTA	WITH aReceb[i][__CONTA]
				REPLACE SEF->EF_NUM		WITH aReceb[i][__NUMCART]
				REPLACE SEF->EF_VALOR	WITH aReceb[i][__VALOR]
				REPLACE SEF->EF_VALORBX WITH aReceb[i][__VALOR]
				REPLACE SEF->EF_DATA	WITH SL1->L1_EMISNF
				REPLACE SEF->EF_VENCTO	WITH aReceb[i][__DATA]
				REPLACE SEF->EF_BENEF	WITH SM0->M0_NOMECOM
				REPLACE SEF->EF_CART	WITH "R"
				REPLACE SEF->EF_TEL		WITH aReceb[i][__TELEFON]
				REPLACE SEF->EF_RG		WITH aReceb[i][__RG]
				REPLACE SEF->EF_TITULO	WITH cNumE1
				If lPedido
					REPLACE SEF->EF_SERIE 	WITH SL1->L1_SERPED
				Else
					REPLACE SEF->EF_SERIE 	WITH SL1->L1_SERIE
				EndIf
				REPLACE SEF->EF_NUMNOTA	WITH cL1Doc
				REPLACE SEF->EF_TIPO	WITH AllTrim(aReceb[i][__FORMA])
				REPLACE SEF->EF_TERCEIR	WITH aReceb[i][__TERCEIR]

				If lFtvdVer12
					REPLACE SEF->EF_HIST	WITH cHist
				Else
					REPLACE SEF->EF_HIST	WITH ""
				EndIf

				REPLACE SEF->EF_PARCELA	WITH cE1Parcela
				REPLACE SEF->EF_PREFIXO	WITH cPrefE1
				REPLACE SEF->EF_ORIGEM	WITH "FINA040"
				If Type("cGaranCh") == "C"
					SEF->EF_GARANT	:= cGaranCh
				EndIf
				
				nPosImpCheque := Ascan(aImpCheque,{|x| x[1] == i })
				If nPosImpCheque > 0 .AND. aImpCheque[nPosImpCheque][2]
					SEF->EF_IMPRESS := "S"
				EndIf

				If Len(aReceb[i]) >= __COMPEN  			
					REPLACE SEF->EF_COMP	WITH aReceb[i][__COMPEN] 
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Posiciona o SA1  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|  Gravação dos dados do cliente no cheque    |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SEF->EF_CLIENTE := SA1->A1_COD
				SEF->EF_LOJACLI := SA1->A1_LOJA

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se e CPF/CNPJ estiver em branco na tabela SA1,     ³
				//³será considerado o CPF/CNPJ informado na tabela SL4³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SA1->A1_CGC)
					SEF->EF_CPFCNPJ := SA1->A1_CGC
				Else
					SL1->(DbSetOrder(2))
					SL1->(DbSeek(xFilial("SL1")+cL1Serie+cL1Doc))

					SL4->(DbSetOrder(1))
					SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))

					SEF->EF_CPFCNPJ := SL4->L4_CGC
				EndIf

				If aReceb[i,__TERCEIR]
					SEF->EF_EMITENT := aReceb[i][__EMITENT]
				Else
					SEF->EF_EMITENT := SA1->A1_NOME
				EndIf

				SEF->(MsUnlock())
				aAdd( aRecnoFin, { "SEF", SEF->EF_TITULO, SEF->(Recno()) } )

				If lOriFun .AND. lGerInt
					oIntVenda:Inserir("SEF", xFilial("SEF") +  SEF->EF_BANCO + SEF->EF_AGENCIA + SEF->EF_CONTA + SEF->EF_NUM, "1", "3")
				EndIF

			//Tratamento Totvs PDV NF-e
			ElseIf !lNFePDV .and. (cPaisLoc <> "BRA") .AND. IsMoney(aReceb[i,__FORMA])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| A funcao A040DUPREC Abre o titulo porque não foi gerado o SE5 para ele, sendo assim      |
				//| forco a baixa e gero o SE5 com os valores sem o abatimento                               |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( "SE1" )
				RecLock( "SE1", .F. )
				REPLACE E1_SALDO	  WITH 0
				REPLACE E1_BAIXA	  WITH If(E1_BAIXA <= dDataBase, dDataBase, E1_BAIXA)
				REPLACE E1_MOVIMEN    WITH dDataBase
				REPLACE E1_STATUS     WITH "B"
				REPLACE E1_VALLIQ     WITH E1_VALOR
				MsUnlock()

				SA6->(DbSetOrder(1))
				If SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
					nMoedaBco := Max(SA6->A6_MOEDA,1)
					nRndBco   := MsDecimais(nMoedaBco)
				EndIf

				RecLock("SE5",.T.)
				REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
				REPLACE SE5->E5_FILORIG	WITH cFilAnt
				REPLACE SE5->E5_TIPODOC	WITH "LJ"
				REPLACE SE5->E5_VALOR	WITH Round(xMoeda(SE1->E1_VALOR,aReceb[Len(aReceb)][11],nMoedaBco,dDataBase,nRndBco+1),nRndBco)
				REPLACE SE5->E5_MOEDA	WITH StrZero(nMoedaBco,2)
				REPLACE SE5->E5_VLMOED2	WITH SE1->E1_VALOR
				REPLACE SE5->E5_BANCO	WITH SL1->L1_OPERADO
				REPLACE SE5->E5_AGENCIA WITH SE1->E1_AGEDEP
				REPLACE SE5->E5_CONTA	WITH aDadosBanc[2]
				REPLACE SE5->E5_DATA	WITH SL1->L1_EMISNF
				REPLACE SE5->E5_DTDIGIT	WITH If(Empty(SL1->L1_EMISNF),dDatabase,SL1->L1_EMISNF)
				REPLACE SE5->E5_DTDISPO	WITH SE1->E1_EMISSAO
				REPLACE SE5->E5_PREFIXO	WITH SE1->E1_PREFIXO
				REPLACE SE5->E5_NUMERO	WITH SE1->E1_NUM
				REPLACE SE5->E5_PARCELA	WITH SE1->E1_PARCELA
				REPLACE SE5->E5_TIPO	WITH SE1->E1_TIPO
				REPLACE SE5->E5_SEQ		WITH "01"
				REPLACE SE5->E5_NATUREZ	WITH SE1->E1_NATUREZ
				REPLACE SE5->E5_CLIFOR	WITH SE1->E1_CLIENTE
				REPLACE SE5->E5_CLIENTE	WITH SE1->E1_CLIENTE
				REPLACE SE5->E5_LOJA	WITH SE1->E1_LOJA
				REPLACE SE5->E5_RECPAG	WITH "R"
				REPLACE SE5->E5_HISTOR	WITH STR0009  // "BAIXA REF VENDA EM DINHEIRO"
				REPLACE SE5->E5_MOTBX	WITH "NOR"
				SE5->(MsUnlock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|  Atualiza saldo do BANCO Caixa   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"+")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  Gera contas a pagar para a administradora financeira	|
			//|  caso exista AE_TAXA  > 0 cadastrada e se parametro		|
			//|  MV_LJGERTX = .T. e o fornecedor nao for vazio         	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//Tratamento para nao gerar quando estiver sendo executado o Totvs PDV NF-e
			If !lNFePDV .and. lGeraTaxa .AND. ((SAE->AE_TAXA > 0) .OR. (nValTaxAdm >0)) ;
			.AND. AllTrim(aReceb[i][__FORMA]) $ "CC/CD" .AND. !Empty(cNumSA2)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso esteja preenchido o valor da Taxa de Administração do      ³
				//³plano da Administradora financeira, da prioridade ao MEN_TAXADM.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IIf( (nValTaxAdm > 0), (nValAdm := SE1->E1_VALOR*nValTaxAdm), (nValAdm := SE1->E1_VALOR*SAE->AE_TAXA))

				aVetorSE2 :={	{"E2_PREFIXO"	,SE1->E1_PREFIXO,Nil}	,;						  	 				// 01
								{"E2_NUM"	   	,SE1->E1_NUM    ,Nil}	,; 						  	 				// 02
								{"E2_PARCELA"	,SE1->E1_PARCELA,Nil}	,; 						   					// 03
								{"E2_TIPO"		,SE1->E1_TIPO   ,Nil}	,;				   		   	 				// 04
								{"E2_NATUREZ"	,SE1->E1_NATUREZ,Nil}	,;						   					// 05
								{"E2_FORNECE"	,cNumSA2	 	,Nil}	,;											// 06
								{"E2_LOJA"		,SE1->E1_LOJA   ,Nil}	,; 							  				// 07
								{"E2_EMISSAO"	,Iif(dDataBase > SE1->E1_VENCTO,SL1->L1_EMISNF,dDataBase)      ,NIL}	,;				   			  				// 08
								{"E2_VENCTO"	,SE1->E1_VENCTO ,NIL}	,; 							   				// 09
								{"E2_VENCREA"	,SE1->E1_VENCREA,NIL}	,; 											// 10
								{"E2_VALOR"		,A410Arred((nValAdm)/100 , "L2_VRUNIT"),NIL},;						// 11
								{"E2_HIST"		,AllTrim(SE1->E1_NUM),NIL}} 					   					// 12

				lMsErroAuto := .F.
				
				nValFun		:= 0 //Zera o Valor do FUNRURAL, para que não seja também gerado a taxa de FUNRURAL para o titulo a pagar da Adm. Financeira atraves da rotina FINA050
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz a inclusao do contas a pagar via ExecAuto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetorSE2,,3)
				
				nValFun		:= nVFunrural //Alimenta a variável nValFun usada na função A040DupRec para geraar o Titulo a Pagar referente a Taxa da Contribuicao Seguridade Social (FUNRURAL)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se houveram erros durante a execucao da rotina automatica.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMsErroAuto
					cLogErro := MostraErro(Iif( lAutomato .or. IsBlind(), "\", ""))
					LjGrvLog(SL1->L1_NUM,"Depois da chamada do FINA050 - Erro:", cLogErro)
				Endif
			EndIf
			If ExistBlock("LJDEPSE1") .AND. !lFtvdVer12
				ExecBlock("LJDEPSE1",.F.,.F.,{aReceb[i]})
			EndIf

			If ExistBlock("FTVDDEPSE1") .AND. lFtvdVer12
				ExecBlock("FTVDDEPSE1",.F.,.F.)
			EndIf

			If AllTrim(SE1->E1_TIPO) $ cMV_FORMCRD
			AADD(aDadosFin,{SE1->E1_PREFIXO						, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
							SAE->AE_COD + " - " + SAE->AE_DESC	, SE1->E1_VENCTO })
			EndIf
		EndIf
	Next i

	/* Restaura o Array aReceb*/
	aReceb := aClone(aBkpRcb)

	/* Gravação do Instituto Arredondar para Contas a Pagar */
	If SL1->(ColumnPos("L1_VLRARR")) > 0 .And. SL1->L1_VLRARR > 0  //Inclusive com grvbatch
		//O valor do nArredondar, se vier do GrvBatch(), não tenho como pegar o valor original da doação no cupom.
		//Pegarei pelo SL1->L1_VLRARR já descontado as taxas administrativas.
		Lj950GrArr( SL1->L1_NUM,SL1->L1_SERIE,SL1->L1_DOC, SA1->A1_COD,;
							 SA1->A1_LOJA, SL1->L1_CGCCLI,SL1->L1_FORMPG,;
							  If(lScreen,nArredondar,SL1->L1_VLRARR),SL1->L1_VLRARR )
	EndIf

	/* Deleta os registros do MAL depois de criado o SE1 e
	grava o numero do contrato no SE1 */
	//Tratamento Totvs PDV com NF-e
	If !lNFePDV .and. CrdxInt()
	   If SL1->(ColumnPos("L1_CONTRA")) > 0
	      If !Empty(SL1->L1_CONTRA) .AND. Len(aDadosFin) > 0
	      	 LjGravaLog( lScreen, cNumOrc, "LjGrvFin -18) antes da funcao CrdAtuFinan", LMALERT, LMTECH)
	         CrdAtuFinan(SL1->L1_CONTRA  ,aDadosFin)
	         LjGravaLog( lScreen, cNumOrc, "LjGrvFin -19) depois da funcao CrdAtuFinan", LMALERT, LMTECH)
	      EndIf
	   EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a lista de verificação de valores.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEval( StrToKArr(MVRECANT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MV_CRNEG	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVABATIM	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVIRABT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVFUABT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVINABT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVABATIM	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVPIABT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVCFABT	, "|"), {| x | aAdd( aLista, x ) } )
	aEval( StrToKArr(MVPROVIS	, "|"), {| x | aAdd( aLista, x ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao de titulos a receber, gerando todos os dados³
	//³complementares a uma implantacao de titulo.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nContaParc := 1 to Len(aRegSE1)
		SE1->(DbGoTo( aRegSE1[nContaParc] ))
		
		//l040duprec eh para so gerar contador do titulo 1 vez na A040DupRec		
		If !(aScan( aLista, { |x| AllTrim(SE1->E1_TIPO) == x } ) > 0) .AND. !IsMoney(SE1->E1_TIPO)
		    If nContaParc <= LEN(aFinProp) .AND. AllTrim(SE1->E1_TIPO) <> AllTrim(MVCHEQUE)  .AND. AllTrim(SE1->E1_TIPO) <> 'CC' .AND. AllTrim(SE1->E1_TIPO) <> 'CD'
		       lAtuSalDup  := aFinProp[nContaParc]
		    Else
		       lAtuSalDup  := .T.
		    EndIf
		    
		    cTitPai := "" //Inicializa chave titulo pai
			
			//Tratamento hotelaria para alterar cliente 
			If lIntegHtl
				lAltCli := .F.
				
				If SE1->E1_CLIENTE + SE1->E1_LOJA <> SL1->L1_CLIENTE + SL1->L1_LOJA
					cTitPai := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
					
					lAltCli  := .T.					
					cCliBkp  := SE1->E1_CLIENTE
					cLojaBkp := SE1->E1_LOJA	
					
					SE1->E1_CLIENTE := SL1->L1_CLIENTE
					SE1->E1_LOJA	:= SL1->L1_LOJA
				EndIf
			EndIf
			
			nValFun := nVFunrural //Alimenta a variável nValFun usada na função A040DupRec para geraar o Titulo a Pagar referente a Taxa da Contribuicao Seguridade Social (FUNRURAL)

			//Nao precisa executar para Totvs PDV NFe
			if !lNFePDV
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin -20) antes da funcao A040DupRec", LMALERT, LMTECH)
				A040DupRec(	cOrigem		,  l040duprec 	, nBaseDup	, lRetemPCC,;
							lpTPAbISS	, lAtuSalDup	, Nil		, cRecIss,;
							Nil			, Nil			, Nil		, Nil,;
							Nil			, Nil			, cTitPai  	)
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin -21) depois da funcao A040DupRec", LMALERT, LMTECH)
			endif
			l040duprec := .F.		//Se ja contou o titulo, nao deve contar mais.

			//Zera as variaveis que controla o valor da Taxa da Contribuicao Seguridade Social (FUNRURAL), para que o imposto não seja gerado duplicado
			nVFunrural 	:= 0
			nValFun 	:= 0
			
			RecLock( "SE1",.F.)
			
			//Tratamento hotelaria para restaurar cliente
			If lIntegHtl .And. lAltCli				
				SE1->E1_CLIENTE := cCliBkp
				SE1->E1_LOJA 	:= cLojaBkp				
			EndIf
			
			If Empty(SL1->L1_EMISNF)
				SE1->E1_EMIS1	:= dDatabase
			Else
				SE1->E1_EMIS1	:= SL1->L1_EMISNF
			EndIf
			
			SE1->(MsUnlock())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recupera o nome da Administradora para gravar no³
			//³campo E1_NOMCLI. Pois a funcao A40DupRec        ³
			//³Grava com o nome do Cliente da Venda            ³
			//³SE1 ja esta posicionado.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aRegNomE1) > 0
				aAreaSE1 := SE1->(GetArea())
				DbSelectArea("SE1")
				SE1->(DbSetOrder(2)) // E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				For nX := 1 To Len(aRegNomE1)
					If SE1->(DbSeek(xFilial("SE1") + aRegNomE1[nX][1] + aRegNomE1[nX][2] + aRegNomE1[nX][3] + ;
									aRegNomE1[nX][4] + aRegNomE1[nX][5] + aRegNomE1[nX][6]))
						RecLock( "SE1",.F.)
						SE1->E1_NOMCLI  := aRegNomE1[nX][7]
						SE1->(MsUnlock( ))
					EndIf
				Next nX
				RestArea(aAreaSE1)
			EndIf

			If lUsaVP .And. AllTrim(SE1->E1_TIPO) == "VP"
				nRecnoSE1	:= SE1->(Recno())
				aAreaSE1	:= SE1->(GetArea())
				aAreaSL1	:= SL1->(GetArea())
				LjGrvLog(SL1->L1_NUM," Venda de Vale Presente - Recno SE1 antes da Fina070", nRecnoSE1 )
			
				aVetorSE5 := {	{ "E1_PREFIXO" 	,SE1->E1_PREFIXO	, Nil},	;
								{ "E1_NUM"     	,SE1->E1_NUM		, Nil},	;
								{ "E1_PARCELA" 	,SE1->E1_PARCELA	, Nil},	;
								{ "E1_TIPO"    	,SE1->E1_TIPO		, Nil},	;
								{ "E1_MOEDA"    ,SE1->E1_MOEDA		, Nil},	;
								{ "E1_TXMOEDA"	,SE1->E1_TXMOEDA	, Nil},	;
								{ "E1_ORIGEM"	,SE1->E1_ORIGEM		, Nil},	;
								{ "AUTVALREC"	,SE1->E1_VALOR  	, Nil},	;
								{ "AUTMOTBX"  	,"NOR"				, Nil},	;
								{ "AUTDTBAIXA"	,dDataBase			, Nil},	;
								{ "AUTDTCREDITO",dDataBase			, Nil},	;
								{ "AUTHIST"   	,STR0174			, Nil}, ; //"BAIXA REF VENDA EM VP"
								{ "AUTBANCO"  	,SE1->E1_PORTADO	, Nil},	;
								{ "AUTAGENCIA"  ,SE1->E1_AGEDEP		, Nil},	;
								{ "AUTCONTA"  	,PadR(".", TamSX3("E5_CONTA")[1]) , Nil}}

		 		lMsErroAuto := .F.
		 		LjGrvLog(,"Antes da chamada do FINA070 para VP",aVetorSE5)

				// Ponto de Entrada - Contabiliza On-Line
				If lLj7113
					aParamLj := ExecBlock("LJ7113",.F.,.F.)
				EndIf

				// aTotaisLJ : Salva o array aTotais para garantir a integridade
				If !IsBlind()
					aTotaisLJ := aTotais
				EndIf

				MSExecAuto( { |a,b,c,d,e,f| FINA070( a,b,c,d,e,f ) }, aVetorSE5, 3 ,,,,aParamLj)

				If !IsBlind()
					aTotais	:= aTotaisLJ
				EndIf
				LjGrvLog(,"Depois da chamada do FINA070 para VP")

		   		/*Verifica se houveram erros durante a execucao da rotina automatica.*/
				If lMsErroAuto
					cLogErro := MostraErro(Iif( lAutomato .or. IsBlind(), "\", ""))
					LjGrvLog(SL1->L1_NUM,"Depois da chamada do FINA070 para VP - Erro:", cLogErro)
				EndIf
				LjGrvLog(SL1->L1_NUM," Venda de Vale Presente - Recno SE1 depois da Fina070", SE1->(Recno()))
				RestArea(aAreaSE1)
				RestArea(aAreaSL1)
				SE1->(dbGoto(nRecnoSE1))
				LjGrvLog(SL1->L1_NUM," Venda de Vale Presente - Recno SE1 depois do ajuste ", SE1->(Recno()))
			EndIf

			RecLock( "SE1",.F.)
				If ExistIni("E1_OCORREN",.T.)	// Verifica se existe inicializador padrao
					REPLACE E1_OCORREN WITH InitPad(GetSx3Cache("E1_OCORREN","X3_RELACAO")) // Executa o ini padrao do campo
				EndIf
			SE1->(MsUnlock())

		EndIf
		
		If AllTrim(Upper(SE1->E1_TIPO)) $ Upper(SuperGetMV( "MV_LJBXTIT",.F.,"" )) .And. !IsMoney(SE1->E1_TIPO)
						 
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 38) antes da Rotina LjGeraE5. MV_LJBXTIT " + AllTrim(Upper(SE1->E1_TIPO)) , LMALERT, LMTECH)
			
			If !(LjGeraE5(aDadosBanc,0, aRegSE1[nContaParc] , STR0185) ) //"BAIXA AUTOMATICA"
				lRet := .F.
				LjGravaLog( lScreen, cNumOrc, "LjGrvFin - Erro na baixa automatica do titulo. MV_LJBXTIT.", LMALERT, LMTECH)	
			EndIf

			LjGravaLog( lScreen, cNumOrc, "LjGrvFin - 39) Depois da Rotina LjGeraE5. MV_LJBXTIT" + AllTrim(Upper(SE1->E1_TIPO)) , LMALERT, LMTECH)		
		EndIf
		
	Next nContaParc

EndIf
/*
	Ponto para Gerar NCC para integração 
	quando o pagamento for credito vale troca.
	Issue: DVARLOJ1-5656
*/
If lIntegDef .AND. SL1->L1_CREDITO > 0 	
	// nNccGerada e nNccUsada Usada na função FrtIncluiNCC para calcular o valor a ser criado da NCC
	nNccGerada := SL1->L1_CREDITO
	nNccUsada  := 0
	//aNccItens Simulando a NCC selecionada em Tela.
	aAdd(aNccItens, {.T.,SL1->L1_CREDITO,SL1->L1_DOC,SL1->L1_EMISSAO,0,SL1->L1_CREDITO,SuperGetMV("MV_MOEDA1"),SL1->L1_SERIE,"A","NCC",SL1->L1_LOJA})
	LjGrvLog(SL1->L1_NUM,"Vai realizar a baixa das NCCs",aNCCItens)

	//--------------------------------
	// Inclui nova NCC para o cliente
	//--------------------------------
	lGvr := StaticCall( WSFRTNCC		, FrtIncluiNCC		,;
						aNCCItens		, 	nNccUsada		, nNccGerada		, SL1->L1_DOC		,;
						SL1->L1_SERIE	,	SL1->L1_OPERADO	, SL1->L1_EMISSAO	, SL1->L1_CLIENTE	,;
						SL1->L1_LOJA,,lIntegDef)//passa lIntegDef se é integração para função FrtIncluiNCC

	LjGrvLog(SL1->L1_NUM,"Retorno se incluiu a nova NCC",lRet)
	LjGrvLog(SL1->L1_NUM,"Valor da nova NCC:",nNccGerada)
	
	If lGvr
		//Adiciona Recno para que função LjInMovNCC possa posicionar na NCC
		aNCCItens[1][5] := SE1->(Recno())
		//Ajustar o valor da NCC Gerada para o valor SL1->L1_CREDITO 
		RecLock( "SE1",.F.)
			REPLACE SE1->E1_VALOR 		WITH SL1->L1_CREDITO
			REPLACE SE1->E1_SALDO 		WITH SL1->L1_CREDITO
			REPLACE SE1->E1_VALLIQ 		WITH SL1->L1_CREDITO
			REPLACE SE1->E1_VLCRUZ 		WITH SL1->L1_CREDITO
			REPLACE SE1->E1_BASCOM1		WITH SL1->L1_CREDITO
		SE1->(MsUnlock())
		//------------------------------------------------------------------
		// Inclui tipo CR para fazer a compensação das NCCs usadas na venda
		//------------------------------------------------------------------
		lGvr := StaticCall( WSFRTNCC		, FrtIncluiCR		,;
							SL1->L1_SERIE	, @cDocCred			, @nRecnoSE1	, SL1->L1_DOC		,;
							SL1->L1_SERIE	, SL1->L1_CLIENTE	, SL1->L1_LOJA	, SL1->L1_CREDITO	,;
							SL1->L1_OPERADO	, nNccUsada			, nNccGerada   	, aNccItens			)

		LjGrvLog(SL1->L1_NUM,"Retorno se incluiu o CR para compensacao da NCC",lRet)

		//----------------------
		// Efetua a compensacao
		//----------------------
		If lGvr
			nNccGerada := 0
			nNccUsada  := SL1->L1_CREDITO
			
			LjGrvLog(SL1->L1_NUM,"Executa a baixa da NCC utilizada na venda")
			LjInMovNCC(	aNccItens,	nRndMoed1,	cDocCred,	;
					nRecnoSE1,	nNccUsada, nNccGerada, SL1->L1_NUM, nMoedaCor, lNFePDV )
		Else
			cTextoErro := "Não foi possível realizar a inclusão do título do tipo CR referente a NCC"
			LjGrvLog(SL1->L1_NUM,cTextoErro)
		EndIf
	Else
		cTextoErro := "Não foi possível realizar a inclusão da Nota de Crédito"
		LjGrvLog(SL1->L1_NUM,cTextoErro) 
	EndIf
	
	If !lGvr
		RPCOpenTables({"MHL"}) //Necessario abrir tabela especifica         
		RMIGRVLOG( "IR"       ,"SL1"   ,SL1->(Recno()), "GRVBAT"    ,;
			cTextoErro ,        ,              ,             ,;
			.F.        , 1      ,SL1->L1_FILIAL+ SL1->L1_NUM, 'GRVBATCH', 'PROTHEUS' )
	endIf		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Baixas os Creditos do Cliente   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e8
If !lNFePDV .and. nNccGerada > 0 .AND. lRet
	cParcela := PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA) // Ajusta de acordo com o tamanho do E1_PARCELA
	nE1Valor := SL1->L1_CREDITO

	While SE1->(DbSeek(xFilial("SE1") + cPrefE1 + cNumE1 + cParcela + "NCC"))
		cParcela := CHR(ASC(cParcela)+1)
	End

    LjGravaLog( lScreen, cNumOrc, "LjGrvFin -22) antes da funcao LjIncluiNCC", LMALERT, LMTECH)
	LjIncluiNCC(aNCCItens	, 	nNccUsada	, 	nNccGerada, 	cNumE1, ;
				cParcela	, 	cOrigem		, 	lUsaSPB   ,     cPrefE1,;
				aVendedor	,	@aNewNCC	, 	@aRecnoFin,		lPedidoVD )
	LjGravaLog( lScreen, cNumOrc, "LjGrvFin -23) depois da funcao LjIncluiNCC", LMALERT, LMTECH)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza saldo dos titulos do cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! SuperGetMV( "MV_CLIPAD" )+ SuperGetMV( "MV_LOJAPAD" ) == SA1->A1_COD+SA1->A1_LOJA
		LjGravaLog( lScreen, cNumOrc, "LjGrvFin -24) antes da funcao AtuSalDup", LMALERT, LMTECH)
       	AtuSalDup(	"-",	SE1->E1_SALDO,	SE1->E1_MOEDA,	SE1->E1_TIPO, , ;
       				SE1->E1_EMISSAO)
       	LjGravaLog( lScreen, cNumOrc, "LjGrvFin -25) depois da funcao AtuSalDup", LMALERT, LMTECH)
	EndIf

EndIf

If lPedido .OR. lLstPresC
	cWhileSE1 := "xFilial('SE1') + cPrefE1 + cNumE1 + cParcela + 'CR '"
ElseIf lIsVendaVP .Or. lIsVdRecCP
	cWhileSE1 := "xFilial('SE1') + cPrefE1 + cNumE1 + cParcela + 'CR '"
Else
	cWhileSE1 := "xFilial('SE1') + SF2->F2_PREFIXO + cNumE1 + cParcela + 'CR '"
EndIf

If SL1->L1_CREDITO > 0 .AND. lFinanceiro .AND. lScreen .AND. lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  1 - Valor pago em Credito  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cParcela := PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA) // Ajusta de acordo com o tamanho do E1_PARCELA

	If nE1Valor == 0
			nE1Valor := SL1->L1_CREDITO
	EndIf

	SE1->(DbSetOrder(1))
	While SE1->(DbSeek(cWhileSE1))
		cParcela := CHR(ASC(cParcela)+1)
	End
	
	cNatureza := &(SuperGetMV("MV_NATCRED"))
	If Empty(cNatureza)
		SX5->(DbSeek(xFilial("SX5")+"24"+PADR("CR",6)))
		cNatureza := If(Empty(SX5->X5_DESCRI),"CREDITO",SX5->X5_DESCRI)
	EndIf
	
	If nMoedaCor > 1
	   cAgenciaCx  := PadR(SuperGetMV("MV_SIMB"+Str(nMoedaCor,1)),nTamA6_AGENCIA)
	   SA6->(DbSetOrder(1))
	   If SA6->(DbSeek(xFilial("SA6")+xNumCaixa()+cAgenciaCx))
	      cContaCx  := SA6->A6_NUMCON
	   EndIf
	EndIf
	
	aAreaSA1 := SA1->(GetArea())
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
	
	RecLock( "SE1",.T.)
	REPLACE SE1->E1_FILIAL 		WITH cFilial

	If lPedido .OR. lLstPresC 
		REPLACE SE1->E1_PREFIXO 	WITH cPrefE1
		REPLACE SE1->E1_NUM 		WITH cNumE1 
	ElseIf lIsVendaVP .Or. lIsVdRecCP
		REPLACE SE1->E1_PREFIXO 	WITH cPrefE1
		REPLACE SE1->E1_NUM 		WITH cNumE1
	Else                                            
		REPLACE SE1->E1_PREFIXO 	WITH SF2->F2_PREFIXO
		REPLACE SE1->E1_NUM 		WITH cNumE1
	EndIf

	REPLACE SE1->E1_PARCELA 	WITH cParcela
	REPLACE SE1->E1_TIPO 		WITH "CR"
	REPLACE SE1->E1_NUMNOTA 	WITH SL1->L1_DOC

	If lPedido

		SerieNfId("SE1",1,"E1_SERIE",dDataBase,LjEspecieNF(), SL1->L1_SERPED)

	Else

		SerieNfId("SE1",1,"E1_SERIE",dDataBase,LjEspecieNF(), SL1->L1_SERIE)
	EndIf

	REPLACE SE1->E1_FILORIG 	WITH cFilAnt
	REPLACE SE1->E1_NATUREZ 	WITH cNatureza
	REPLACE SE1->E1_PORTADO 	WITH IIF(lScreen,xNumCaixa(),SL1->L1_OPERADO)
	REPLACE SE1->E1_AGEDEP 		WITH cAgenciaCx
	REPLACE SE1->E1_CONTA 		WITH cContaCx
	REPLACE SE1->E1_MOEDA 		WITH nMoedaCor
	REPLACE SE1->E1_CLIENTE 	WITH SL1->L1_CLIENTE
	REPLACE SE1->E1_LOJA 		WITH SL1->L1_LOJA
	REPLACE SE1->E1_NOMCLI 		WITH SA1->A1_NREDUZ
	
	If !lECommerce
		REPLACE SE1->E1_EMISSAO 	WITH dDataBase
		REPLACE SE1->E1_EMIS1 		WITH dDataBase
		REPLACE SE1->E1_VENCTO 		WITH dDataBase
	Else
		REPLACE SE1->E1_EMISSAO 	WITH SL1->L1_EMISSAO
		REPLACE SE1->E1_EMIS1 		WITH SL1->L1_EMISSAO
		REPLACE SE1->E1_VENCTO 		WITH SL1->L1_EMISSAO
	EndIf
	REPLACE SE1->E1_VENCREA 	WITH DataValida(SE1->E1_VENCTO,.T.)
	REPLACE SE1->E1_VENCORI		WITH dDataBase
	REPLACE SE1->E1_MOVIMEN	 	WITH SE1->E1_BAIXA
	If !lFtvdVer12
		If nMVLjCpNCC <> 1
			REPLACE SE1->E1_VALOR 		WITH SL1->L1_CREDITO
		Else
			REPLACE SE1->E1_VALOR 		WITH nNCCUsada
		EndIf
	ElseIf lFtvdVer12
		REPLACE SE1->E1_VALOR 		WITH SL1->L1_CREDITO
	EndIf
	REPLACE SE1->E1_SALDO 		WITH SE1->E1_VALOR
	REPLACE SE1->E1_STATUS 		WITH "A"
	REPLACE SE1->E1_VLCRUZ 		WITH Round(xMoeda(SE1->E1_VALOR, SE1->E1_MOEDA,1, SE1->E1_EMISSAO),nRndMoed1)
	REPLACE SE1->E1_VALLIQ 		WITH SE1->E1_VALOR
	REPLACE SE1->E1_SITUACA   		WITH IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,"CR",SE1->E1_PORTADO),"0")
	REPLACE SE1->E1_ORIGEM 		WITH cOrigem
	REPLACE SE1->E1_MULTNAT		WITH "2"
	REPLACE SE1->E1_FLUXO		WITH "S"

	If SE1->(ColumnPos("E1_SCORGP")) > 0	//Campo da tabela SE1 que identifica fornecimento de (1) bens e Servicos contratados por pessoa juridica de direito publico ou (2 ou '') identifica que Nao.
		If ("1"$cA1M996) .And. ("1"$cB1M996)
			SE1->E1_SCORGP	:=	"1" //Para sinalizar que eh venda para Orgão Publico
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta a modalidade de pagamento quando o parametro³
	//³MV_USASPB estiver ativo                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaSPB
		SE1->E1_MODSPB	:= "1"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SED")
	DbSetOrder(1)
	DbSeek(xFilial("SED")+SE1->E1_NATUREZ)

	If SED->ED_CALCISS=="S"
		//Calculo e atribuição do campo SE1->E1_ISS
		LjCalcRecIss(	@nTotNFISS	, @nRestISS	, .F.	, .F.			,;
						nImpostos	, .F.		, 1		, @nValE1ISS	,;
						@nE1Valor	)
					
		REPLACE SE1->E1_ISS		WITH nValE1ISS
		REPLACE SE1->E1_VALOR	WITH nE1Valor
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetuar o calculo do IRRF conforme natureza         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE1->E1_IRRF := NoRound(nTotNFIRRF/nImpostos,2)
	nRestIRRF += SE1->E1_IRRF
	If 1 == nImpostos
		SE1->E1_IRRF += nTotNFIRRF - nRestIRRF
		nTotNFIRRF  := nRestIRRF := 0
	EndIf

	For nVend := 1 To Len(aVendedor)
		If SE1->(ColumnPos("E1_VEND"+Str(nVend,1))) > 0 .AND. SE1->(ColumnPos("E1_COMIS"+Str(nVend,1))) > 0
			If Ascan(aRegSE1, SE1->(Recno()) ) = 0
				aAdd( aRegSE1, SE1->(Recno()) )
			EndIf

			If ( AllTrim(SE1->E1_TIPO) == "CR" .AND. lComiDev ) .AND. nNccUsada <= SL1->L1_CREDITO
				nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + nNccUsada) ) * SL1->L1_CREDITO, nDecimal )
			ElseIf ( AllTrim(SE1->E1_TIPO) == "CR" .AND. lComiDev ) .AND. nNccUsada > SL1->L1_CREDITO .AND. nVlTotal == 0
				nBaseCom := Round((aVendedor[nVend][3] / (nVlTotal + SL1->L1_CREDITO) ) * SL1->L1_CREDITO, nDecimal )
			Else
				// Caso lComiDev estiver como .F. não gera comissão para NCC
				nBaseCom := 0
			EndIf
			
			&("SE1->E1_VEND"  +Str(nVend,1)) := aVendedor[nVend][1]
			&("SE1->E1_COMIS" +Str(nVend,1)) := aVendedor[nVend][2]
            &("SE1->E1_BASCOM"+Str(nVend,1)) := nBaseCom
            &("SE1->E1_VALCOM"+Str(nVend,1)) := Round(nBaseCom * (aVendedor[nVend][2]/100),nDecimal)
        EndIf
	Next nVend
	
	//Alimenta campo Reserva do Cliente - Integracao Hotel
	If lIntegHtl
		REPLACE SE1->E1_CONHTL WITH SL1->L1_RESEHTL
	EndIf
	
	SE1->(MsUnlock())
	aAdd( aRecnoFin, { "SE1", SE1->E1_NUM, SE1->(Recno()) } )

	RestArea(aAreaSA1)

	cDocCred := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
	nRecnoSE1 := SE1->(Recno())

	LjGravaLog( lScreen, cNumOrc, "LjGrvFin -26) antes da funcao LjInMovNCC", LMALERT, LMTECH)

	LjInMovNCC(	aNccItens,	nRndMoed1,	cDocCred,	;
				nRecnoSE1,	nNccUsada, nNccGerada, SL1->L1_NUM, nMoedaCor, lNFePDV )

	LjGravaLog( lScreen, cNumOrc, "LjGrvFin -27) depois da funcao LjInMovNCC", LMALERT, LMTECH)
	
	lOriFin := Lj7OrigNCC()

	If (lComisCR .And. SE5->E5_MOTBX == "CMP") .Or. (lComiDev .And. SE5->E5_MOTBX == "DEV")
    	//Array para calculo das comissoes
        aAdd( aRegSE1, SE1->(Recno()) )
        aAdd(aBaixas,   {SE5->E5_MOTBX, SE5->E5_SEQ, SE5->(Recno()) })
    
        //Array para calculo das comissoes
        nScanBx := aScan(aBaixasTmp,{|x| x[1] == SE1->(Recno())})
        
        If nScanBx == 0
           Aadd(aBaixasTmp,{SE1->(Recno()),{}})
           nScanBx := Len(aBaixasTmp)
        EndIf
        aAdd(aBaixasTmp[nScanBx,2],{SE5->E5_MOTBX, SE5->E5_SEQ, SE5->(Recno())})

	ElseIf lOriFin .And. lComFILJ
        aAdd( aRegSE1, SE1->(Recno()) )
        aAdd(aBaixas,   {SE5->E5_MOTBX, SE5->E5_SEQ, SE5->(Recno()) })

        //Array para calculo das comissoes
        nScanBx := aScan(aBaixasTmp,{|x| x[1] == SE1->(Recno())})
        
        If nScanBx == 0
           Aadd(aBaixasTmp,{SE1->(Recno()),{}})
           nScanBx := Len(aBaixasTmp)
        EndIf
        aAdd(aBaixasTmp[nScanBx,2],{SE5->E5_MOTBX, SE5->E5_SEQ, SE5->(Recno())})

	EndIf

EndIf

If lRet
	//Se Venda assistida com pagamento 100% NCC,
	//eu insiro o vendedor e a comissão para gerar registro na tabela de comissões SE3 - desde que l1_dinheiro = 0
	//O motivo é que na SE1 ele gera somente tipo CR, não o tipo R$ ou similar
	If !lLjGrvOn .AND. Len(aRegSE1) = 0 .AND. (SL1->L1_DINHEIR = 0) .AND. Len(aVendedor) >= 0
		If SE1->(DBSeek(cE1Filial+cPrefE1+cNumE1+cParcela+cE1Tipo)) .AND. (SE1->E1_TIPO = "CR")		//Para certificar que pesquisou o tipo CR
			aAdd( aRegSE1, SE1->(Recno()) )
			RecLock( "SE1",.F.)
			For nVend := 1 To Len(aVendedor)
				If Empty(&("SE1->E1_VEND"  +Str(nVend,1))) .AND. Len(aVendedor[nVend]) >= 2
					&("SE1->E1_VEND"  +Str(nVend,1)) := aVendedor[nVend][1]
					&("SE1->E1_COMIS" +Str(nVend,1)) := aVendedor[nVend][2]
					&("SE1->E1_BASCOM"+Str(nVend,1)) := nBaseCom
					&("SE1->E1_VALCOM"+Str(nVend,1)) := Round(nBaseCom * (aVendedor[nVend][2]/100),nDecimal)
				EndIf
			Next nVend
			SE1->(MsUnlock())
		EndIf
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Zera os abatimentos de PIS/COFINS/CSLL caso tenha gerado os títulos de abatimentos no SE1|
	//| Inicio                                                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetemPCC .AND. SE1->(ColumnPos("E1_SABTPIS")) > 0 .AND. SE1->(ColumnPos("E1_SABTCOF")) > 0 .AND. SE1->(ColumnPos("E1_SABTCSL")) > 0  .AND. Type("aPISCofCSL") == "A"
		
		aRecNoSE1 := aClone(aPISCofCSL[02,05])

		For i := 1 To Len(aRecNoSE1)

			DbSelectArea("SE1")
			DbGoTo(aRecNoSE1[i])

			RecLock("SE1", .F.)
			REPLACE SE1->E1_SABTPIS WITH 0, ;
		        SE1->E1_SABTCOF WITH 0, ;
		        SE1->E1_SABTCSL WITH 0
			MsUnlock()

		Next i
		
	EndIf
	
	//Calculo de Comissao
	//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e
	If !lNFePDV .and. SuperGetMV("MV_TPCOMLJ") == "O"
		For nI := 1 To Len(aRegSE1)
			DbSelectArea("SE1")
			SE1->(DbGoTo(aRegSE1[nI]))
			lIsMoney := IsMoney(SE1->E1_TIPO)
			
            nScanBx := aScan(aBaixasTmp,{|x| x[1] == SE1->(Recno())})
    
            If nScanBx == 0
                aBaixas := {}
            Else
               aBaixas := aBaixasTmp[nScanBx,2]
            EndIf
           	
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin -28) antes da funcao Fa440CalcE", LMALERT, LMTECH)
			SE1->(Fa440CalcE("FINA280","","zzzzzz",,.T.,.T.))
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin -29) depois da funcao Fa440CalcE", LMALERT, LMTECH) 
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin -30) antes da funcao Fa440CalcB", LMALERT, LMTECH)
			If lIsMoney .Or. (!lIsMoney .And. (lComiDev .Or. lComisCR .Or. (lComFILJ .And. lOriFin)) .And. AllTrim(SE1->E1_TIPO) == "CR")
				Fa440CalcB(	aBaixas        ,.T.,.T.     ,"LOJA010",;
							"+"            ,"" ,"zzzzzz",.T.      ,;
							SE1->(Recno()) ,   ,lOriFin )
			EndIf
			LjGravaLog( lScreen, cNumOrc, "LjGrvFin -31) depois da funcao Fa440CalcB", LMALERT, LMTECH)
		Next nI
	EndIf

	aRecSE1 := AClone(aRegSE1)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criação de  NCC com os valores dos Descontos concedidos³
//³     pelo Cenario de vendas ativo/regras de Desconto.  ³
//³				Somente com Release 11.5 ativo			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCenVenda
	aDescNCC := LjGetCVar()
	If Len(aDescNcc) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Execulta Funcao LJSelIncTit que Gera NCC e verifica se³
		//³execulta via WebService.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJSelIncTit(aDescNCC, "SL1")
    EndIf
EndIf

//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e
If !lNFePDV .and. lRet .And. lFinanceiro .And. lAtuSldNat

	For nI := 1 To Len(aRegSE1)
		DbSelectArea("SE1")
		SE1->(DbGoTo(aRegSE1[nI]))

		//Atualiza saldo por natureza financeira
		AtuSldNat(SE1->E1_NATUREZ,; 						// 1 -> Codigo da natureza em que o saldo sera atualizado
		SE1->E1_BAIXA,; 									// 2 -> Data em que o saldo deve ser atualizado
		SE1->E1_MOEDA,; 									// 3 -> Codigo da moeda do saldo
		If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG,"3","2"),; 	// 4 -> Tipo de saldo (1=Orcado, 2=Previsto, 3=Realizado)
		"R",;												// 5 -> Codigo da carteira (P=Pagar, R=Receber)
		SE1->E1_VALOR,; 									// 6 -> Valor que atualizara o saldo na moeda do saldo
		SE1->E1_VLCRUZ,; 									// 7 -> Valor que atualizara o saldo na moeda corrente
		If(SE1->E1_TIPO $ MVABATIM,"-","+"),; 				// 8 -> Sinal para atualizacao (+) ou (-)
		,; 													// 9 -> Saldo a ser atualizado (D = Diario, M = Mensal, NIL = Ambos (importante apenas no recalculo)
		SE1->E1_ORIGEM,; 									// 10 -> Rotina de Origem do movimento de fluxo de caixa. Ex. FUNNAME()
		"SE1",; 											// 11-> Alias onde ocorreu a movimentação de fluxo de caixa. Ex. SE2
		SE1->(Recno()),;								 	// 12 -> Número do registro no alias onde ocorreu a movimentação de fluxo de caixa.
		nOpc) 												// 13 -> Opção de manipulação da rotina de origem da chamada da função AtuSldNat()

    	Next nI

EndIf

//Tratamentos Hotelaria
If lIntegHtl .And. lRet .And. lFinanceiro 			
	//Compensacao de RA
	For nI := 1 To Len(aRecRa)																														
		//Altera data base para compensacao
		dDataBkp  := dDataBase //Backup da data atual 
		dDataBase := aRecRa[nI][3]
		
		//Atualiza saldo do cliente
		SE1->(dbGoTo(aRecRa[nI][1])) 
		AtuSaldup("+", SE1->E1_VALOR, SE1->E1_MOEDA, SE1->E1_TIPO,, SE1->E1_EMISSAO)
						
		//Efetua a compensacao				
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -32) antes da funcao MaIntBxCR", LMALERT, LMTECH)
		MaIntBxCR(3, {aRecRa[nI][1]},, {aRecRa[nI][2]},, {.T., .F., .F., .F., .F., .F.})	
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -33) depois da funcao MaIntBxCR", LMALERT, LMTECH)
		
		//Restaura data base
		dDataBase := dDataBkp										
	Next nI
	
	//Baixa troco
	If SL1->L1_TROCO1 > 0 .And. ExistFunc("LjTrocoHtl")
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -34) antes da funcao LjTrocoHtl", LMALERT, LMTECH)
		lRet := LjTrocoHtl(aRecRa)
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -35) depois da funcao LjTrocoHtl", LMALERT, LMTECH)	
	EndIf
	
	//Rateio de pagamentos
	If ExistFunc("LjRateioHtl")
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -36) antes da funcao LjRateioHtl", LMALERT, LMTECH)				
		LjRateioHtl(aRegSE1)	 
		LjGravaLog(lScreen, cNumOrc, "LjGrvFin -37) depois da funcao LjRateioHtl", LMALERT, LMTECH)
	EndIf						
EndIf 

SL1->(RestArea(aAreaSL1))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RcLojMexºAutor  ³ Vendas Clientes    º Data ³ 18/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao grava o valor dos impostos nos titulos a receber   º±±
±±º          ³gerados.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RcLojMex(_lScreen)

Local aArea		:= GetArea()
Local aTotal1	:= {}
Local aTotal2	:= {}
Local aTotal3	:= {}
Local aTotal4	:= {}
Local aTotal5	:= {}
Local aTotal6	:= {}

Local aBase1	:= {}
Local aBase2	:= {}
Local aBase3	:= {}
Local aBase4	:= {}
Local aBase5	:= {}
Local aBase6	:= {}

Local cSerie	:= SF2->F2_SERIE
Local cNumero	:= SF2->F2_DOC
Local cChaveSE1	:= xFilial("SE1")+cNumero+cSerie
Local lExistE1	:= SE1->(FieldPos("E1_VALIMP1")) > 0 .And.;
					SE1->(FieldPos("E1_VALIMP2")) > 0 .And.;
					SE1->(FieldPos("E1_VALIMP3")) > 0 .And.;
					SE1->(FieldPos("E1_VALIMP4")) > 0 .And.;
					SE1->(FieldPos("E1_VALIMP5")) > 0 .And.;
					SE1->(FieldPos("E1_VALIMP6")) > 0
Local lVerCpoE1	:=  SE1->(FieldPos("E1_ALQIMP1")) > 0 .And.;
					SE1->(FieldPos("E1_ALQIMP2")) > 0 .And.;
					SE1->(FieldPos("E1_ALQIMP3")) > 0 .And.;
					SE1->(FieldPos("E1_ALQIMP4")) > 0 .And.;
					SE1->(FieldPos("E1_ALQIMP5")) > 0 .And.;
					SE1->(FieldPos("E1_ALQIMP6")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP1")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP2")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP3")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP4")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP5")) > 0 .And.;
					SE1->(FieldPos("E1_BASIMP6")) > 0

Local nValImp1	:= SF2->F2_VALIMP1   // Busca valor generado en la facturacion
Local nValImp2	:= SF2->F2_VALIMP2   // Busca valor generado en la facturacion
Local nValImp3	:= SF2->F2_VALIMP3   // Busca valor generado en la facturacion
Local nValImp4	:= SF2->F2_VALIMP4   // Busca valor generado en la facturacion
Local nValImp5	:= SF2->F2_VALIMP5   // Busca valor generado en la facturacion
Local nValImp6	:= SF2->F2_VALIMP6   // Busca valor generado en la facturacion
Local nConta	:= 0
Local nI		:= 0
Local cTes		:= ""
Local aImps		:= {}
Local cBase		:= ""
Local lScreen	:= If(_lScreen == NIL, .T.,_lScreen)
Local nPosTes	:= If(lScreen,aScan(aHeaderDet, { |x| AllTrim(x[02]) == "LR_TES" }),0)

If lImpCupFis
	If lScreen
		If Len(aColsDet) > 1
			For nI := 1 to Len(aColsDet)
				If !aColsDet[nI][Len(aHeaderDet)+1]
					cTes := aColsDet[nI][nPosTes]
					Exit
				Endif
			Next
		Endif
	Else
		SL2->( DbSetOrder( 1 ) )
		If SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) )
			cTes := SL2->L2_TES
		EndIf
	EndIf
	aImps := TesImpInf(cTES)
	If Len(aImps) > 0
		cBase := SubStr(aImps[1][2],Len(aImps[1][2]),1)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente efetua o processamento se os campos do E1 e E2 para lançamento dos impostos variaveis existirem.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExistE1
	// No estoy tratando IVA con retencion. Tendra que prever.
	aTotal1 := CondLoja(nValImp1) // Genera el IVA igual em todas as parcelas
	aTotal2 := CondLoja(nValImp2) // Genera el IVA igual em todas as parcelas
	aTotal3 := CondLoja(nValImp3) // Genera el IVA igual em todas as parcelas
	aTotal4 := CondLoja(nValImp4) // Genera el IVA igual em todas as parcelas
	aTotal5 := CondLoja(nValImp5) // Genera el IVA igual em todas as parcelas
	aTotal6 := CondLoja(nValImp6) // Genera el IVA igual em todas as parcelas

	aBase1 := CondLoja(SF2->F2_BASIMP1) // Genera el Base IVA igual em todas as parcelas
	aBase2 := CondLoja(SF2->F2_BASIMP2) // Genera el Base IVA igual em todas as parcelas
	aBase3 := CondLoja(SF2->F2_BASIMP3) // Genera el Base IVA igual em todas as parcelas
	aBase4 := CondLoja(SF2->F2_BASIMP4) // Genera el Base IVA igual em todas as parcelas
	aBase5 := CondLoja(SF2->F2_BASIMP5) // Genera el Base IVA igual em todas as parcelas
	aBase6 := CondLoja(SF2->F2_BASIMP6) // Genera el Base IVA igual em todas as parcelas

	DbSelectArea("SE1")
    cChaveSE1	:= xFilial("SE1")+cSerie+cNumero
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+cSerie+cNumero)
	nConta 		:= 1
	While !Eof() .And. E1_FILIAL+E1_PREFIXO+E1_NUM == cChaveSE1
		RecLock("SE1",.F.)
		If Len(aTotal1) > 0 .AND. Len(aTotal1)>= nConta
			SE1->E1_VALIMP1 := aTotal1[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP1 := aBase1[nConta]
				If lImpCupFis .AND. cBase == "1"
					SE1->E1_ALQIMP1 := aImps[1][9]
				Else
					SE1->E1_ALQIMP1 := SF3->F3_ALQIMP1
				EndIf
			EndIf
		Endif
		If Len(aTotal2) > 0.AND. Len(aTotal2)>= nConta
			SE1->E1_VALIMP2 := aTotal2[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP2 := aBase2[nConta]
				If lImpCupFis .AND. cBase == "2"
					SE1->E1_ALQIMP2 := aImps[1][9]
				Else
					SE1->E1_ALQIMP2 := SF3->F3_ALQIMP2
				EndIf
			EndIf
		Endif
		If Len(aTotal3) > 0 .AND. Len(aTotal3)>= nConta
			SE1->E1_VALIMP3 := aTotal3[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP3 := aBase3[nConta]
				If lImpCupFis .AND. cBase == "3"
					SE1->E1_ALQIMP3 := aImps[1][9]
				Else
					SE1->E1_ALQIMP3 := SF3->F3_ALQIMP3
				EndIf
			EndIf
		Endif
		If Len(aTotal4) > 0.AND. Len(aTotal4)>= nConta
			SE1->E1_VALIMP4 := aTotal4[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP4 := aBase4[nConta]
				If lImpCupFis .AND. cBase == "4"
					SE1->E1_ALQIMP4 := aImps[1][9]
				Else
					SE1->E1_ALQIMP4 := SF3->F3_ALQIMP4
				EndIf
			EndIf
		Endif
		If Len(aTotal5) > 0 .AND. Len(aTotal5)>= nConta
			SE1->E1_VALIMP5 := aTotal5[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP5 := aBase5[nConta]
				If lImpCupFis .AND. cBase == "5"
					SE1->E1_ALQIMP5 := aImps[1][9]
				Else
					SE1->E1_ALQIMP5 := SF3->F3_ALQIMP5
				EndIf
			EndIf
		Endif
		If Len(aTotal6) > 0.AND. Len(aTotal6)>= nConta
			SE1->E1_VALIMP6 := aTotal6[nConta]
			If lVerCpoE1
				SE1->E1_BASIMP6 := aBase6[nConta]
				If lImpCupFis .AND. cBase == "6"
					SE1->E1_ALQIMP6 := aImps[1][9]
				Else
					SE1->E1_ALQIMP6 := SF3->F3_ALQIMP6
				EndIf
			EndIf
		Endif
		MsUnLock()
		nConta ++

		DbSelectArea("SE1")
		DbSkip()
	End
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CondLojaºAutor  ³ Vendas Clientes    º Data ³ 18/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para avaliar condicao de pagamento                 º±±
±±º          ³                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CondLoja(nValTot)

Local aDados   := {}                                           // Array com o valor dos impostos
Local aAreaSL4 := SL4->(GetArea())                             // Area do SL4
Local nVlrBrt  := SL1->L1_VLRTOT                               // Valor Total
Local nVlrItem := Space(TamSX3("L4_VALOR")[1])                 // Valor do Item
Local cOrcament:= SL1->L1_NUM                                  // Numero do Orcamento
Local nPercentual := 0                                         // Percentual correspondente
Local nVlrImposto := 0                                         // Valor do imposto calculado
Local nDecimais   := 2                                         // Casas decimais
Local nDiferenca  := 0                                         // Ajuste de arredondamento
Local nTotImposto := 0                                         // Total de impostos proporcionalizados

Default nValTot   := 0

SL4->(dbSetOrder(1))
SL4->(DbSeek(xFilial("SL4")+cOrcament))
While !SL4->(EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cOrcament
	nVlrItem   := SL4->L4_VALOR
	nPercentual:= Round((( nVlrItem * 100)/ nVlrBrt),nDecimais)
	nVlrImposto:= Round(((nPercentual/100) * nValTot),nDecimais)
	nTotImposto+= nVlrImposto
	Aadd(aDados, nVlrImposto)
	SL4->(DbSkip())
End
RestArea(aAreaSL4)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona a posicao da NCC,pois a mesma nao consta no SL4³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SL1->L1_CREDITO > 0
	nVlrItem   := SL1->L1_CREDITO
	nPercentual:= Round((( nVlrItem * 100)/ nVlrBrt),nDecimais)
	nVlrImposto:= Round(((nPercentual/100) * nValTot),nDecimais)
	nTotImposto+= nVlrImposto
	Aadd(aDados, nVlrImposto)
EndIf

nDiferenca := nValTot - nTotImposto

If nDiferenca > 0 .AND. Len(aDados) > 0
	aDados[Len(aDados)]+= nDiferenca
EndIf

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjECFxDataºAutor  ³ Vendas Clientes    º Data ³ 12/12/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que compara a data do ECF com a data do sistema e fazº±±
±±º          ³a atualizacao.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjECFxData()
Local lRet     := .T.						//Retorno da funcao
Local lRetImp  := .T.						//Retorno da consulta no ECF
Local cRetorno := ""						//Retorno da verificacao do ECF
Local dDataAnt := dDataBase               	//DataBase antiga
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() 		//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este controle e valido apenas para usuario fiscal                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal
	If LjEcfIfData(  NIL  ,  .F.  ,  .T.  ,  @lRetImp  , ;
					 @cRetorno   )

		If !VerifHora()
			If lRetImp
				lRet := MsgYesNo( STR0086 + cRetorno + STR0087 + DtoC(dDataBase) + STR0088, STR0089 )//"A data do ECF ("###") é diferente da data do sistema ("###"), deseja efetuar a atualizacao da data do sistema?"###"Atenção"

				If ( lRet )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada para atualizacao de valores e consistencias especificas  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock( "LATUDATA" ) .AND. !lFtvdVer12
						lRet := ExecBlock( "LATUDATA" , .F. , .F. )
					EndIf

					If ExistBlock( "FTVDTUDATA" ) .AND. lFtvdVer12
						lRet := ExecBlock( "FTVDTUDATA" , .F. , .F. )
					EndIf

					dDataBase := CtoD(cRetorno)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifico se o caixa esta aberto para o dia que foi selecionado.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !LjCxAberto()
						lRet := .F.
						dDataBase := dDataAnt
					EndIf
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Emite mensagem informando diferenca de 15 minutos³
				//³do sistema operacional e a impressora            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LjAnalisaLeg(3)[1]
					lRet := .F.
					MsgAlert(STR0117) //"A diferença entre a hora do computador e do ECF não pode ultrapassar 15 minutos"
				EndIf
			EndIf
        EndIf
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjCriaMot ºAutor  ³ Vendas Clientes    º Data ³ 23/06/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria um motivo especifico para o SIGALOJA                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjCriaMot()
Local nHdlMot 		:= 0           	//Handle do Arquivo
Local nPos			:= 0
Local cLinha  		:= ""		    //Linha
Local cLinBAK		:= ""
Local cAux			:= ""
Local aAux			:= {}
Local cExpressao  	:= ""			//Expressao
Local cExpCompleta	:= ""
Local lNovoByte		:= .F. //Novo
Local cIdioma		:= FwRetIdiom() 

If !File("SIGAADV.MOT")
	nHdlMot := MSFCreate("SIGAADV.MOT",0)
	IF nHdlMot == -1
		Help(" ",1,"MOT_ERROR")
		Final("Erro F_"+str(ferror(),2)+" em SIGAADV.MOT")
	EndIf
	If cIdioma == "en"
	   FWrite(nHdlMot,"NORNORMAL    ASSSN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DACEXCHANGE  ANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEVDEVOLUTIONANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEBDEBIT CC  PSNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"VENVENDOR    PNNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"LOJANOTHER SHANSSN"+chr(13)+chr(10))
	ElseIf cIdioma == "es"
	   FWrite(nHdlMot,"NORNORMAL    ASSSN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DACPERMUTA   ANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEVDEVOLUCIONANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEBDEBITO CC PSNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"VENTIT.BANCO PNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"LOJOTRA TIENDANSS"+chr(13)+chr(10))
	Else
	   FWrite(nHdlMot,"NORNORMAL    ASSSN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DACDACAO     ANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEVDEVOLUCAO ANNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"DEBDEBITO CC PSNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"VENVENDOR    PNNNN"+chr(13)+chr(10))
	   FWrite(nHdlMot,"LOJOUTRA LOJAANSSN"+chr(13)+chr(10))
	EndIf
    FClose( nHdlMot )
Else

	lNovoByte := LjMotBxS()
	nHdlMot := FOpen( "SIGAADV.MOT" )
	IF nHdlMot == -1
		Help(" ",1,"MOT_ERROR")
		Final("Erro ao criar SIGAADV.MOT")
	EndIf

	cLinha := Space( FSeek( nHdlMot, 0, 2 ) )
	FSeek( nHdlMot, 0 )

	FRead( nHdlMot, @cLinha, Len( cLinha ) )
	FClose( nHdlMot )

	If cIdioma == "en"
       cExpressao  := "LOJANOTHER SH"
	ElseIf cIdioma == "es"
       cExpressao  := "LOJOTRA TIEND"
	Else
       cExpressao  := "LOJOUTRA LOJA"
	EndIf
	  
	//Caso o cliente tenha alterado pela rotina FINA490 ou pelo arquivo, 
	//devo retornar o padrão isso afeta diretamente o recebimento de titulo com cartão
	cLinBAK := cLinha
	cLinha	:= ""
	cExpCompleta := cExpressao + "ANSS" + IIF(lNovoByte, "N", "") + chr(13) + chr(10)
	While !Empty(cLinBAK)
		nPos 	:= At(chr(10),cLinBAK)
		If !(nPos > 0)
			nPos := Len(cLinBAK) //Tamanho padrão da linha do arquivo
		EndIf
		 
		cAux	:= Substr(cLinBAK,1,nPos)
		cLinBAK := Substr(cLinBAK,nPos+1, Len(cLinBAK))
		//removo linha iguais e não permito preencher com o motivo loja(caso cliente tenha alterado)
		If !(cExpressao $ cAux) .And. (Ascan(aAux,{|x| x == cAux}) == 0)			
			aAdd(aAux, cAux)
			cLinha += aAux[Len(aAux)]
		EndIf
	End

	//Para evitar problemas do Loja sempre vai recriar o arquivo, inserindo a linha do loja e com os outros conteudos
	nPos := AT(cExpCompleta,cLinha)
	
	If (nPos == 0)
		FErase( "SIGAADV.MOT" )
		nHdlMot := FCreate( "SIGAADV.MOT" )
		
		IF nHdlMot == -1
			Help(" ",1,"MOT_ERROR")
			Final("Erro ao criar SIGAADV.MOT")
		EndIf
		
		FWrite(nHdlMot,cLinha+cExpCompleta)
		FClose( nHdlMot )
	EndIf
EndIf

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjAltSerie ºAutor ³ Vendas Clientes    º Data ³  28/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Troca a serie automatica da estacao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjAltSerie( cEstacao, cDoc )
Local aArea 	:= ""								// Area
Local lAuto		:= SuperGetMV("MV_LJSRAUT", ,.F.)  // Indica se utiliza incremento automatico da serie
Local cCOO		:= '999999'							// Numero maximo do COO
Local cDocAtu	:= ""								// Numero do documento com 6 digitos

If lAuto
	aArea	:= GetArea()

	DbSelectArea("SLG")
	DbSetOrder(1)

	If DbSeek( xFilial("SLG") + cEstacao )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Compara se o numero do cupom e o ultimo numero antes de zerar o COO.               ³
		//³(l6_status == 1 -> serie disponivel pra uso. l6_status==2 -> serie utilizada.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cDocAtu := LjValcDoc( cDoc )

	 	If Val(cDocAtu) == Val(SubStr(cCOO,1, Len(SLG->LG_TAMSER) ))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inativa a serie atual do PDV na tabela SL6, para reservar a proxima            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL6")
			DbSetOrder(1)

        	If DbSeek( xFilial("SL6")+SLG->LG_SERIE+cEstacao )
	 	    	RecLock( "SL6", .F. )
		    		L6_STATUS	:=	'2'
		    	MsUnlock()
	 	    EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reserva a proxima serie disponivel para a Estacao. Caso nenhuma serie estiver disponivel³
			//³para a estacao, o sistema devera informar ao usuario.                                   ³
			//³Status: 1-Disponivel para uso 2- utilizado.                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSetOrder(2)
	 	    If DbSeek( xFilial("SL6")+cEstacao+'1')

	 	    	SLG->( RecLock( "SLG", .F. ) )

		 			SerieNfId("SL6",1,"L6_SERIE",dDataBase,LjEspecieNF(), cSerieNF )

		 		SLG->( MsUnlock() )
		 	Else
		 		Aviso(STR0107, STR0108, {"OK"} )	//"Cadastro de Estacao", "Numero do COO foi reinicializado. "
		    EndIf

		    MsUnlock()
		EndIf

	EndIf

	RestArea(aArea)

EndIf

Return (NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjLJNSrDispºAutor ³ Vendas Clientes    º Data ³  14/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o numero de serie disponivel para a estacao       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJNSrDisp()
Local 	nI			:= 0                            // Indica quando executar a rotina de serie x PDV
Local	nMvNsrDisp	:= SuperGetMV("MV_NSRDISP",,0)	// Indica se utiliza controle de serie automatica

If nMvNsrDisp > 0

	DbSelectArea("SL6")
	DbSetOrder(2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura todas as series disponiveis para esta estacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DbSeek( xFilial("SL6")+cEstacao+"1" )
		While SL6->( !Eof() ) .AND. SL6->L6_ESTACAO == cEstacao;
		 						  .AND. SL6->L6_STATUS  == "1"

			nI++
			SL6->( DbSkip() )
		End
    EndIf

    If nI <= nMvNsrDisp
    	Aviso (STR0105, STR0106, {"OK"} )	//"Reserva de série para esta etação está chegando ao final. Favor rodar a rotina Série X PDV."
    EndIf
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³ LjInclSF2 ºAutor ³ Vendas Clientes    º Data ³  26/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui o cabecalho da NF de Saida (SF2)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cNumNota = Nr. da NF                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjInclSF2(cNumNota, lImpCupFis, cSerie, cFirst, cSerieNF, lNFServ)

Local cTiposDoc 	:= AllTrim( SuperGetMv( 'MV_ESPECIE' ) )					// Tipos de documento (busca no param. MV_ESPECIE)
Local cEspecie  	:= SPACE(5)													// Especie do Documento
Local cChaveNfce	:= SL1->L1_KEYNFCE											// Verifica se foi gerado NFC-e para a venda
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local aTimeUf		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT		:= ""
Local lUseSat		:= !Empty(SL1->L1_SERSAT) .And. !Empty(SL1->L1_KEYNFCE)
Local cHora 		:= ""
Local aRetfor       := {}
Local cCliente		:= SL1->L1_CLIENTE
Local cLoja			:= SL1->L1_LOJA
Local cTipo			:= "N"

Default cSerieNF 	:= SL1->L1_SERIE
Default lNFServ  	:= .F.										// Indica se eh NF de "servico"

LjGrvLog(SL1->L1_NUM,"LjInclSF2 - Inicio Gravacao cNumNota:",cNumNota+'/'+cSerie)

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
If ValType(cHoraRMT) == "L"
	If cHoraRMT
		cHoraRMT := "1"
	Else
		cHoraRMT := "2"
	EndIf
Else
	If cHoraRMT == NIL
		cHoraRMT := "2"
	EndIf
EndIf

If lNFServ
	cSerie := cSerieNF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta o tamanho da nota fiscal, caso haja diferenca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumNota := PadR(cNumNota,TamSx3("F2_DOC")[1])
cSerieNF := PadR(cSerieNF,TamSX3("F2_SERIE")[1])

If SL1->L1_TIPO $ ("B|D")
	aRetfor		:= LjRetfor(SL1->L1_CLIENTE,SL1->L1_LOJA)	
	cCliente	:= aRetFor[1]
	cLoja    	:= aRetFor[2]
	cTipo	 	:= SL1->L1_TIPO
Endif
SF2->(DbSetOrder( 1 ))
If !SF2->( DbSeek( xFilial( "SF2" )+ cNumNota + cSerieNF + cCliente + cLoja ) )
	RecLock( "SF2", .T. )
	SF2->F2_FILIAL  := xFilial( "SF2" )
	SF2->F2_DOC     := cNumNota
	SF2->F2_SERIE   := cSerieNF
	//Tratamento para Integracao EAI  de Notas 
	//que utilizam Fornecedores.
	If SL1->L1_TIPO $ ("B|D")	
		SF2->F2_CLIENT  := cCliente
		SF2->F2_LOJENT  := cLoja
	Endif
	SF2->F2_CLIENTE := cCliente
	SF2->F2_LOJA    := cLoja
	SF2->F2_TIPO    := cTipo
	
	SF2->F2_EMISSAO := SL1->L1_EMISNF
	SF2->F2_VOLUME1 := SL1->L1_VOLUME
	SF2->F2_PDV		:= SL1->L1_PDV
	SF2->F2_COND	:= SL1->L1_CONDPG
	SF2->F2_DUPL	:= cFirst
	SF2->F2_VEND1	:= SL1->L1_VEND
	SF2->F2_PLIQUI	:= SL1->L1_PLIQUI
	SF2->F2_PBRUTO	:= SL1->L1_PBRUTO
	SF2->F2_TRANSP	:= SL1->L1_TRANSP

	If SL1->(ColumnPos('L1_ESPECI1')) > 0 .And. !Empty(SL1->L1_ESPECI1)
		REPLACE SF2->F2_ESPECI1	WITH SL1->L1_ESPECI1
	EndIf 

	If SL1->(FieldPos("L1_VEICUL1" )) > 0 .And. !Empty(SL1->L1_VEICUL1) .And. SF2->(FieldPos("F2_VEICUL1" )) > 0
		SF2->F2_VEICUL1	:= SL1->L1_VEICUL1
	EndIf

	If SL1->(FieldPos("L1_CGCCLI")) > 0	.And. SF2->( FieldPos("F2_CGCCLI") ) > 0
		SF2->F2_CGCCLI := SL1->L1_CGCCLI
	EndIf

	If cPaisLoc == "ARG"
		If SL1->(FieldPos( "L1_PROVENT" )) > 0 .AND. SF2->(FieldPos( "F2_PROVENT" )) > 0
			REPLACE SF2->F2_PROVENT	WITH SL1->L1_PROVENT
		EndIf
	EndIf

	If SF2->(FieldPos("F2_TPFRETE")) > 0 .AND. SL1->(FieldPos("L1_TPFRET")) > 0
		SF2->F2_TPFRETE := SL1->L1_TPFRET
	EndIf

	If !Empty(cChaveNfce) .And. !lUseSat .And. !lNFServ //NFC-e/SAT: Verifica se venda tem como documento fiscal
		SF2->F2_ECF		:= ""
		cEspecie 		:= "NFCE"			//Especie da NFC-e
		SF2->F2_CHVNFE	:= cChaveNfce	//Chave de autorizacao da Nota
	ElseIf lUseSat .And. !lNFServ
		SF2->F2_ECF		:= ""
		cEspecie 			:= "SATCE"			//Especie do SAT
		SF2->F2_CHVNFE	:= cChaveNfce	//Chave de autorizacao da Nota
	ElseIf lNFServ
		SF2->F2_ECF	:= ""
		cEspecie := "RPS" //Para NF de "servico" grava a especie como RPS (Recibo Provisorio de Servico)
	ElseIf lImpCupFis
		SF2->F2_ECF	:= "S"
		cEspecie	:= "CF"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for o estado de Piaui, grava ECF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjAnalisaLeg(18)[1]
			cEspecie := "ECF"
		EndIf
	Else
		SF2->F2_ECF	:= ""
		If cPaisLoc == "BRA"
			If cTiposDoc <> NIL
				cEspecie := LjNfEspeci(cSerie, cTiposDoc)
			EndIf
		Else
			LjGravaLog( .T. , cNumNota + " - " + cSerieNF , '40) Especie MVNOTAFIS - ' + MVNOTAFIS, LMALERT)
			cEspecie := MVNOTAFIS
		EndIf
	EndIf
	LjGravaLog( .T. , cNumNota + " - " + cSerieNF , '41) Especie MVNOTAFIS - ' + MVNOTAFIS, LMALERT)
	SF2->F2_ESPECIE	:= cEspecie
	
	If RTrim(cEspecie) $ "CF|ECF|NFCE|SATCE" 
		SF2->F2_HORA := SubStr(SL1->L1_HORA, 1,5)
	Else
		
		If cHoraRMT == "1"
			cHora       := GetRmtTime()
	
		ElseIf cHoraRMT == "3"
			If cPaisLoc == "BRA"
				aArea2	:= GetArea()
				dbSelectArea("SM0")
				aAreaSM0	:= GetArea()
				dbSetOrder(1)
				If dbSeek(cEmpAnt+cFilAnt)
					aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
				EndIf
				RestArea(aAreaSM0)
				RestArea(aArea2)
	
				cHora := aTimeUf[2]
			Else
				cHora := GetRmtTime()
			EndIf
	
		Else // 2- Default (data do servidor)
			cHora       := Time()
		EndIf
		SF2->F2_HORA  := Substr(cHora,1,5) 
		RecLock("SL1", .F.)
		SL1->L1_HORA  := cHora
		SL1->(MsUnLock())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos Originarios do SA1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF2->F2_EST := IIf(MaFisFound("NF"), MaFisRet(,"NF_UFDEST"),SA1->A1_EST)

	If !Empty(SL1->L1_TIPOCLI)
		SF2->F2_TIPOCLI	:= SL1->L1_TIPOCLI
	Else
		SF2->F2_TIPOCLI	:= SA1->A1_TIPO
    EndIf
	SF2->(MsUnlock())
	SF2->(dbCommit())
EndIf

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJTPNRNFS	  ºAutor³ Vendas Clientes    º Data ³  13/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o tratamento do parametro MV_LJTPNRNFS para o SIGALOJA  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA (V. Balcao e V. Assistida)                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTpNrNFS()
Local cMV_TPNRNFS	:= SuperGetMV("MV_TPNRNFS",,"1")		// Utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local lMV_LJNFSXE	:= SuperGetMV("MV_LJNFSXE",,.F.)		// Utilizado para verificar como sera a numeracao das notas

If cMV_TPNRNFS == "3"
	DbSelectArea("SD9")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para manter a compatibilidade com o legado olha primeiro para o       ³
//³ parametro MV_LJNFSXE e se estiver desabilitado forca sempre pegar do  ³
//³ SX5                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMV_LJNFSXE
	cMV_TPNRNFS := "1"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o parametro estiver configurado para pegar do SX5, muda para "2"   ³
	//³ para forcar pegar do SXE pois este trecho do fonte nao pega do SX5.   ³
	//³ Se for Localizacoes, nao permite que o conteudo se 3 pois serah imple-³
	//³ mentado apenas no Brasil nesta versao.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cMV_TPNRNFS == "1" ) .OR. ( cPaisLoc <> "BRA" .AND. cMV_TPNRNFS == "3" )
		cMV_TPNRNFS := "2"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o parametro MV_TPNRNFS estiver configura igual a "3" verifica tbem ³
	//³ se existe a tabela SD9. Caso o SD9 ainda nao exista, forca o conteudo ³
	//³ do parametro para "2".                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMV_TPNRNFS == "3" .AND. Select("SD9") == 0
		cMV_TPNRNFS := "2"
	EndIf
EndIf

Return (cMV_TPNRNFS)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ LjLogTef  ºAutor ³ Vendas Clientes    º Data ³  19/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Determina a pasta para geracao do LOG TEF				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Pasta onde sera gerado o LOG								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjLogTef()
Local cDirLog  := ""				// Diretorio para o LOG

If cClientDir == NIL
   cClientDir  := GetClientDir()
EndIf
If lArqLog == NIL
   lArqLog  := File(cClientDir+"SIGALOJA.INI")
EndIf
If lLogHabilitado == NIL
   lLogHabilitado  := GetPvProfString("Logs TEF","Habilita","01",cClientDir+"SIGALOJA.INI") == "01"
EndIf

If lArqLog .AND. lLogHabilitado
   cDirLog  := "\AUTOCOM\TEF"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")+"\"
EndIf

Return cDirLog

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³ LjIncluiNCC ºAutor ³  Vendas Clientes   º Data ³  22/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui/atualiza na SE1 as NCC utilizadas na venda quando o   º±±
±±º          ³ parametro parcialmente MV_LJCPNCC estiver igual a 1          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ LjIncluiNCC( ExpA1,  ExpN2,  ExpN3,  ExpC4,					³±±
±±³			 ³				ExpC5,  ExpC6,  ExpL7)							³±±
±±³			 ³ 		                                 						³±±
±±³          ³ ExpA1  - Array que contem todas as NCC selecionadas na venda ³±±
±±³          ³ ExpN2  - Valor Total das Nccs que foram utilizadas           ³±±
±±³          ³ ExpN3  - Valor Total das Nccs que serao geradas              ³±±
±±³          ³ ExpC4  - Valor da Numero que sera gravada na SE1				³±±
±±³          ³ ExpC5  - Valor do Parcela que sera gravada na SE1			³±±
±±³          ³ ExpC6  - Valor da Origem que sera gravada na SE1	    		³±±
±±³          ³ ExpL7  - Identifica o paramentro MV_USASPB					³±±
±±³          ³ ExpC8  - Conteudo do parametro MV_LJPREF. 					³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjIncluiNCC(aNCCItens	, nNccUsada	, nNccGerada, cNumE1	,;
							cParcela	, cOrigem	, lUsaSPB	, cPrefixo	,;
							aVendedor	, aNewNCC	, aRecnoFin , lPedidoVD	)
Local nContaNCC		:= 0												// Variavel para contar as NCC's selecionadas durante a venda
Local nValorNCC		:= 0												// Variavel que identifica o valor que esta faltando a ser baixado da NCC
Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)						//Tratamento para compensacao de NCC //Tratamento para compensacao de NCC 1=Compensa em uma nova NCC; 2=Abate o saldo mesma NCC;3=Consome o Saldo da NCC; 4=Devolve o troco da NCC em dinheiro
Local lGeraSE1 		:= .T.												// Gera NCC
Local lFtvdVer12	:= LjFTVD() 										//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") 				//Nome da Rotina
Local aDadosBanc 	:= {}							//array com dados de ag e conta CADASTRADOS NA SA6

Default aNewNCC		:= {}													//Array com as Notas de Créditos informadas
Default aRecnoFin 	:= {} //Recno dos registros gerados na SE1
Default lPedidoVD	:= .F.

If nTPCompNCC == 2
	Return NIL
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor que deve ser baixado das NCC's³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorNCC = nNccUsada - nNccGerada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para reinserir que foram selecionadas na    ³
//³venda porem ainda possuem saldo                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nContaNCC := 1 to len(aNCCItens)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a NCC foi selecionada para ser utilizada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aNCCItens[nContaNCC][1]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso ja tenha atingido o valor a ser utilizado   ³
		//³as demais NCC's nao serao baixadas               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValorNCC == 0
			aNCCItens[nContaNCC][1] := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³se o Valor da NCC atual foi menor ou igual a que sera utilzado a ³
		//³NCC sera completamente utilizada e nao gera nova NCC             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ( nValorNCC >= aNCCItens[nContaNCC][2] ) .OR. ( ( nTPCompNCC == 3 ) .OR. ( nTPCompNCC == 4 ) )
			nValorNCC -= aNCCItens[nContaNCC][2]
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso a reserva seja da mesma filial, não ha necessidade de ³
			//³gerar NCC novamente na baixa, já que foi gerada no pedido  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SL1->L1_ORCRES) .AND. !Empty(SL1->L1_FILRES)
				lGeraSE1 := .F.
			EndIf

			If lGeraSE1
				aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+SL1->L1_OPERADO, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6 
				RecLock("SE1",.T.)
				REPLACE SE1->E1_FILIAL	WITH xFilial("SE1")

				If ((cOrigem == cNomeProg .Or. lPedidoVD) .AND. SL1->L1_TIPO=="P") .OR. ;
				 	(cOrigem == "LOJA010" .AND. (SL1->L1_TIPO =="P" .OR. !Empty(SL1->L1_DOCPED)))

					REPLACE SE1->E1_PREFIXO	WITH cPrefixo
				Else
					REPLACE SE1->E1_PREFIXO	WITH SF2->F2_PREFIXO
				EndIf

				REPLACE SE1->E1_NUM		WITH cNumE1
				REPLACE SE1->E1_PARCELA	WITH cParcela
				REPLACE SE1->E1_NATUREZ	WITH &(SuperGetMV("MV_NATNCC"))
				REPLACE SE1->E1_PORTADO	WITH SL1->L1_OPERADO
				REPLACE SE1->E1_AGEDEP	WITH aDadosBanc[1]
				REPLACE SE1->E1_CONTA	WITH aDadosBanc[2]
				REPLACE SE1->E1_TIPO	WITH "NCC"
				REPLACE SE1->E1_EMISSAO	WITH aNCCItens[nContaNCC][4]//Data original do titulo gerado
				REPLACE SE1->E1_VALOR	WITH aNCCItens[nContaNCC][2] - nValorNCC //Saldo restante do titulo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se usar data de validade na NCC altera data de vencimento da NCC	   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SuperGetMV("MV_LJVLNCC",,.F.)
					REPLACE SE1->E1_VENCTO	WITH (dDataBase + SuperGetMV("MV_LJDTNCC",,0))
				Else
					REPLACE SE1->E1_VENCTO	WITH SL1->L1_EMISNF
				Endif

				REPLACE SE1->E1_VENCREA	WITH DataValida(SE1->E1_VENCTO,.T.)
				REPLACE SE1->E1_VENCORI	WITH SE1->E1_VENCTO
				REPLACE SE1->E1_SALDO	WITH SE1->E1_VALOR
				REPLACE SE1->E1_VLCRUZ	WITH xMoeda(SE1->E1_VALOR,1,1,SE1->E1_EMISSAO)
				REPLACE SE1->E1_EMIS1	WITH SL1->L1_EMISNF
				REPLACE SE1->E1_CLIENTE	WITH SA1->A1_COD
				REPLACE SE1->E1_LOJA	WITH SA1->A1_LOJA
				REPLACE SE1->E1_NOMCLI	WITH SA1->A1_NREDUZ
				If cPaisLoc <> "BRA"
					SA6->(DbSetOrder(1))
					If SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
						REPLACE SE1->E1_MOEDA WITH Max(SA6->A6_MOEDA,1)
					Else
						REPLACE SE1->E1_MOEDA	WITH 1
					EndIf
	 			Else
					REPLACE SE1->E1_MOEDA	WITH 1
				EndIf
				REPLACE SE1->E1_STATUS	WITH If(SE1->E1_SALDO>0.01,"A","B")
				REPLACE SE1->E1_SITUACA	WITH IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,"NCC",SL1->L1_OPERADO),"0")
				REPLACE SE1->E1_ORIGEM	WITH cOrigem
				REPLACE SE1->E1_MULTNAT	WITH "2"
				REPLACE SE1->E1_FLUXO	WITH "N"
				//Grava a chave do primeiro indice da NCC original //Chave-> E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				REPLACE SE1->E1_HIST	WITH xFilial("SE1") + aNCCItens[nContaNCC][9] + aNCCItens[nContaNCC][3] + aNCCItens[nContaNCC][10] + aNCCItens[nContaNCC][11]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ajusta a modalidade de pagamento quando o parametro³
				//³MV_USASPB estiver ativo                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaSPB
					REPLACE SE1->E1_MODSPB	WITH "1"
				EndIf

				SE1->(MsUnlock())
				aAdd( aRecnoFin, { "SE1", SE1->E1_NUM, SE1->(Recno()) } )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona as informacoes da NCC gerada. ³ //
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AADD(aNewNCC,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_EMISSAO,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_MOEDA } )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera a Variavel de saldo restante da NCC para que as demais³
			//³NCC nao sejam utilizadas                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValorNCC := 0

		EndIf
	EndIf

Next nContaNCC

Return NIL

/*/{Protheus.doc} LjInMovNCC
Inclui na SE5 os dados da NCC e baixa os titulos da SE1 conforme a necessidade
@type	Static Function
@author Vendas Clientes
@since	22/08/06
@param	LjInMovNCC( ExpA1,  ExpN2,  ExpC3,  ExpN4, N5, N6, N7)
		ExpA1  - Array que contem todas as NCC selecionadas na venda
		ExpN2  - Numero de Casas que deve ser arredondada a moeda
		ExpC3  - Dado a ser gravado no campo documento do se5
		ExpN4  - Numero do registo que foi incluido a SE1
		ExpN5  - NCC Usada
		ExpN6  - NCC Gerada
		ExpN7  - Chamada do Totvs PDV para NFe
@return Nil
/*/

Static Function LjInMovNCC(	aNccItens,	nRndMoed1,	cDocCred,	nRecnoSE1, ;
							nNccUsada, 	nNccGerada, cNumOrc, nMoedaCor, lNFePDV )

Local nX
Local cDocNCC											// chave para identificacao da NCC no SE1
Local cTipoDoc											// Variavel de gravacao na SE5 no campo E5_TIPODOC (Tipo de titulo envolvido na movimentacao)
Local cBenef			:= Space(1)					 	// Variavel de gravacao na SE5 no campo E5_BENEF
Local nValor											// Variavel de gravacao na SE5 no campo E5_VALOR
Local cMoeda											// Variavel de gravacao na SE5 no campo E5_MOEDA
Local nSaldo											// Variavel de gravacao na SE5 no campo E5_VLMOED2
Local nTPCompNCC    	:= SuperGetMV("MV_LJCPNCC",,1)	//Tratamento para compensacao de NCC 1=Compensa em uma nova NCC; 2=Abate o saldo mesma NCC;3=Consome o Saldo da NCC; 4=Devolve o troco da NCC em dinheiro
Local nDecs         	:= 2
Local lGravaSE5			:= .T.							// Se deve gravar o SE5
Local lBaixarNCC		:= .T.							// baixa o NCC total ou parcial
Local nValorNCCAtual	:= 0							// Valor da NCC Atual
Local nValorNCC			:= 0							// Valor a ser Baixado nas ncc
Local cSeqBxCp 			:= ""							// Numero sequencial da baixa
Local cSqBxCpNCC		:= ""							// Numero sequencial da baixa da NCC
Local cTpTitComp		:= AllTrim(SuperGetMV("MV_LJNCCBA",,"NCC")) //Tipos de Titulos de Credito que serao compensados como Tipo de Documento (E5_TIPODOC) = "BA". (separados por barra) Ex.: NCC/RA
Local aTpTitComp		:= StrTokArr( cTpTitComp, "/" )
Local aDadosBanc		:= {}                          //array com dados de ag e conta CADASTRADOS Na SA6

Default lNFePDV			:= .F.

cTpTitComp := ""
aEval( aTpTitComp, {|x| cTpTitComp += "|" + PadR(x,TamSX3("E1_TIPO")[1]) } )

/*
//Valor que deve ser baixado das NCC's
*/
nValorNCC = nNccUsada - nNccGerada

For nX := 1 to Len(aNccItens)

	If aNccItens[nX][1]

        SE1->(DbGoTo(aNccItens[nX][5])) // recno da NCC

        cDocNCC := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA

		/*
        // Verifica a proxima sequencia de baixa do titulo da NCC
        */
		cSqBxCpNCC := FaNxtSeqBx()
		LjGrvLog( SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO , "Baixa NCC | Sequencia da baixa NCC: cSeqBxCp" , cSeqBxCp )
	   
        If nRecnoSE1 > 0
            SE1->(DbGoTo(nRecnoSE1))
			/*
			// Verifica a proxima sequencia de baixa do titulo da Venda
			*/
			cSeqBxCp := FaNxtSeqBx()
			LjGrvLog( SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO , "Baixa NCC | Sequencia da baixa do Titulo da Venda: cSeqBxCp" , cSeqBxCp )
        EndIf

		/*
		Caso a sequencia de baixa da NCC for maior que 01 significa que esta NCC ja teve baixa parcial
		com isso é atribuido a sequência de baixa conforme a NCC para gravação na SE5, mesma maneira que é feito pelo Financeiro.
		*/
		If cSqBxCpNCC <> "01"
			cSeqBxCp := cSqBxCpNCC
		EndIf

        cBenef := Space(1)
        If SE1->E1_TIPO $ cTpTitComp
            cTipoDoc := "BA"
            /*
            // Coloca o nome do cliente no E5_BENEF
            */
            SA1->( DbSetOrder( 1 ) )
            If SA1->( DbSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
                cBenef := SA1->A1_NOME
            EndIf
        Else
            cTipoDoc := "CP"
        EndIf

        If cPaisLoc == "BRA"
            If nTPCompNCC == 1
                lGravaSE5 := .T.
                nValor   := xMoeda(aNccItens[nX][2],SE1->E1_MOEDA,1)
			ElseIf nValorNCC >= aNCCItens[nX][2]
				nValor := Round(xMoeda(aNccItens[nX][6],SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
			Else
				nValor := Round(xMoeda(nValorNCC,SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
            EndIf
            cMoeda   := IIF(!Empty(nMoedaCor),PadL(AllTrim(STR(nMoedaCor)),2,"0"),"01")
            nSaldo   := aNccItens[nX][2]
        Else
            nDecs  := MsDecimais(SE1->E1_MOEDA)
            If nTPCompNCC == 1
                lGravaSE5 := .T.
                nValor := Round(xMoeda(aNccItens[nX][6],aNccItens[nX][8],1,dDataBase,nRndMoed1+1),nRndMoed1)
			Else
				nDecs  := MsDecimais(SE1->E1_MOEDA)
				nValor := Round(xMoeda(nValorNCC,aNccItens[nX][8],1,dDataBase,nRndMoed1+1),nRndMoed1)
            EndIf
            cMoeda :=   "01"
            /*
            //  E5_VLMOED2 deve ser gravado na moeda do titulo original(CR)
            */
            nSaldo   := Round(xMoeda(aNccItens[nX][6],aNccItens[nX][8],SE1->E1_MOEDA,dDataBase,nDecs+1),nDecs)
        EndIf
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Ordem dos campos que serao gravados no SE5              ³
        //³LjInSE5( dData,      Tipo,       TipoDoc,    Benef, ;   ³
        //³         Valor,      Moeda,      Saldo,      DtDigit, ; ³
        //³         Naturez,    DtDispo,    Banco,      Agencia, ; ³
        //³         Conta,      RecPag,     MotBX,      Prefixo, ; ³
        //³         Numero,     Parcela,    CliFor,     Cliente, ; ³
        //³         Loja,       Histor,     Document,   Seq)       ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lGravaSE5
            aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+SE1->E1_PORTADO, 1, { ".", "."} )     //³ Busca AG e conta cadastrados na SA6
            LjInSE5(dDataBase,			SE1->E1_TIPO,		cTipoDoc,           cBenef, 			;
                    nValor,             cMoeda,             nSaldo,             dDataBase, 			;
                    SE1->E1_NATUREZ,    dDataBase,      	SE1->E1_PORTADO,    aDadosBanc[1], 		;
                    aDadosBanc[2],      "R",                "CMP",              SE1->E1_PREFIXO,	;      
                    SE1->E1_NUM,        SE1->E1_PARCELA,    SE1->E1_CLIENTE,    SE1->E1_CLIENTE,	;
                    SE1->E1_LOJA,       STR0010,            cDocNCC,            cSeqBxCp,			;
                    SE1->E1_FILORIG )
        EndIf

        RecLock("SE1",.F.)
        SE1->E1_SALDO := 0
        If SE1->E1_SALDO = 0
            REPLACE SE1->E1_STATUS  WITH "B"
            REPLACE SE1->E1_BAIXA   WITH dDataBase
            REPLACE SE1->E1_MOVIMEN WITH dDataBase
            REPLACE SE1->E1_VALLIQ  WITH SE1->E1_VALOR
        EndIf
        MsUnlock()
        
        // Posiciona no registro da NCC
		SE1->(DbGoTo(aNccItens[nX][5]))

		/*
        // Verifica a proxima sequencia de baixa do titulo da NCC
        */
        cSqBxCpNCC := FaNxtSeqBx()
		LjGrvLog( SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO , "Baixa NCC | Sequencia da baixa NCC: cSeqBxCp" , cSqBxCpNCC )

		cBenef := Space(1)
		If SE1->E1_TIPO $ cTpTitComp
			cTipoDoc := "BA"
			/*
			// Coloca o nome do cliente no E5_BENEF
			*/
			SA1->( DbSetOrder( 1 ) )
			If SA1->( DbSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
				cBenef := SA1->A1_NOME
			EndIf
		Else
			cTipoDoc := "CP"
		EndIf

  		lGravaSE5 := .T.
		If ( nTPCompNCC == 1 ) .OR. ( nTPCompNCC == 3 ) .OR. ( nTPCompNCC == 4 )
			nValor	:= Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
		Else
			If nValorNCC == 0
				lGravaSE5 := .F.
			ElseIf nValorNCC >= aNCCItens[nX][2]
				lBaixarNCC := .T.
				nValorNCC -= aNCCItens[nX][2]
				If cPaisLoc == "BRA"
					nValor := Round(xMoeda(aNccItens[nX][6],SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
				Else
					nDecs  := MsDecimais(SE1->E1_MOEDA)
					nValor := Round(xMoeda(aNccItens[nX][6],aNccItens[nX][8],1,dDataBase,nRndMoed1+1),nRndMoed1)
				EndIf
			Else
				lBaixarNCC := .F.
				If cPaisLoc == "BRA"
					nValor := Round(xMoeda(nValorNCC,SE1->E1_MOEDA,1,dDataBase,nRndMoed1+1),nRndMoed1)
				Else
					nDecs  := MsDecimais(SE1->E1_MOEDA)
					nValor := Round(xMoeda(nValorNCC,aNccItens[nX][8],1,dDataBase,nRndMoed1+1),nRndMoed1)
				EndIf
				nValorNCCAtual := nValorNCC
				nValorNCC := 0
			EndIf

		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordem dos campos que serao gravados no SE5              ³
		//³LjInSE5( dData, 		Tipo, 		TipoDoc,	Benef, ;   ³
		//³			Valor, 		Moeda,		Saldo, 		DtDigit, ; ³
		//³			Naturez, 	DtDispo,	Banco,		Agencia, ; ³
		//³			Conta,		RecPag, 	MotBX,		Prefixo, ; ³
		//³			Numero,		Parcela, 	CliFor,		Cliente, ; ³
		//³			Loja,		Histor, 	Document	,Seq)      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lGravaSE5
			aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+SL1->L1_OPERADO, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
			LjInSE5(SL1->L1_EMISNF, 		SE1->E1_TIPO, 		cTipoDoc,				cBenef,				;
					nValor, 				"01",				SE1->E1_SALDO, 			dDataBase, 			;
					SE1->E1_NATUREZ, 		dDataBase,			SL1->L1_OPERADO,		aDadosBanc[1], 		;
					aDadosBanc[2],			"R", 				"CMP",					SE1->E1_PREFIXO,	;		
					SE1->E1_NUM,			SE1->E1_PARCELA, 	SE1->E1_CLIENTE,		SE1->E1_CLIENTE,	;
					SE1->E1_LOJA,			STR0010, 			cDocCred,				cSeqBxCp ,			;
					SE1->E1_FILORIG )
		EndIf

		/*
		// Atualiza saldo dos titulos do cliente
		*/
		//Tratamento Mini GrvBatch do Totvs PDV para emissao NF-e
		If !lNFePDV .and. ! SuperGetMV( "MV_CLIPAD" )+ SuperGetMV( "MV_LOJAPAD" ) == SA1->A1_COD+SA1->A1_LOJA
          	AtuSalDup("+",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		EndIf

		If lGravaSE5
			RecLock("SE1",.F.)

			If lBaixarNCC
				REPLACE SE1->E1_SALDO	WITH 0
				REPLACE SE1->E1_STATUS	WITH "B"
				REPLACE SE1->E1_VALLIQ	WITH SE1->E1_VALOR
			Else
				REPLACE SE1->E1_SALDO	WITH aNCCItens[nX][2] - nValorNCCAtual
				REPLACE SE1->E1_VALLIQ	WITH SE1->E1_VALLIQ + nValorNCCAtual
			EndIf

			REPLACE SE1->E1_BAIXA	WITH SL1->L1_EMISNF
			REPLACE SE1->E1_MOVIMEN	WITH SL1->L1_EMISNF
			SE1->(MsUnlock())
		EndIf
       
	EndIf
Next nX

//Verifica se esta ativa a implementacao que Grava a NCC do Orçamento quando salvo para importação no PDV ou Finalização posterior no SigaLoja
If SuperGetMv("MV_LJNCCOR", Nil, .F.) .And. nModulo == 12 .And. !LjNfPafEcf(SM0->M0_CGC) 
	DbSelectArea("MDJ")
	MDJ->(DbSetOrder(3)) 		//MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC
	If MDJ->(DbSeek(xFIlial("MDJ") + cNumOrc))
		//Deleta os Itens - Ncc Pendente
		DbSelectArea("MDK")
		MDK->( DbSetOrder(2) )	//MDK_FILIAL + MDK_NUMORC
		While MDK->(DbSeek(MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC))
			RecLock("MDK",.F.)
			MDK->( dbDelete() )
			MDK->( MsUnlock() )
		End
		
		//Deleta Cabecalho - Ncc Pendente
		RecLock("MDJ",.F.)
		MDJ->(dbDelete())
		MDJ->(MsUnlock())
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ LjInSE5     ºAutor ³  Vendas Clientes   º Data ³  22/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui na SE5 conforme os parametros informados				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ LjInSE5( ExpD1,  ExpC2,  ExpC3,  ExpC4, 						³±±
±±³			 ³		    ExpN5,  ExpC6,  ExpN7,  ExpD8, 						³±±
±±³			 ³ 		    ExpC9, ExpD10, ExpC11, ExpC12, 						³±±
±±³			 ³         ExpC13, ExpC14, ExpC15, ExpC16,						³±±
±±³			 ³ 		   ExpC17, ExpC18, ExpC19, ExpC20,						³±±
±±³			 ³ 		   ExpC21, ExpC22, ExpC23)								³±±
±±³			 ³ 		                                 						³±±
±±³          ³ ExpD1  - campo E5_DATA										³±±
±±³          ³ ExpC2  - Campo E5_TIPO										³±±
±±³          ³ ExpC3  - Campo E5_TIPODOC									³±±
±±³          ³ ExpC4  - Campo E5_BENEF 										³±±
±±³          ³ ExpN5  -	Campo E5_VALOR										³±±
±±³			 ³ ExpV6  - Campo E5_MOEDA										³±±
±±³          ³ ExpN7  - Campo E5_SALDO										³±±
±±³          ³ ExpD8  - Campo E5_DTDIGIT									³±±
±±³          ³ ExpC9  -	Campo E5_NATUREZ 									³±±
±±³			 ³ ExpD10 - Campo E5_DTDISPO									³±±
±±³          ³ ExpC11 - Campo E5_BANCO										³±±
±±³          ³ ExpC12 - Campo E5_AGENCIA									³±±
±±³          ³ ExpC13 -	Campo E5_CONTA 										³±±
±±³			 ³ ExpC14 - Campo E5_RECPAG										³±±
±±³          ³ ExpC15 - Campo E5_MOTBX										³±±
±±³          ³ ExpC16 - Campo E5_PREFIXO									³±±
±±³          ³ ExpC17 -	Campo E5_NUMERO										³±±
±±³			 ³ ExpC18 - Campo E5_PARCELA									³±±
±±³          ³ ExpC19 - Campo E5_CLIFOR										³±±
±±³          ³ ExpC20 - Campo E5_CLIENTE									³±±
±±³          ³ ExpC21 -	Campo E5_LOJA 										³±±
±±³			 ³ ExpC22 - Campo E5_HISTOR										³±±
±±³          ³ ExpC23 - Campo E5_DOCUMENT									³±±
±±³			 ³ 		                                 						³±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                              						        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjInSE5(dData, 		cTipo, 		cTipoDoc,	cBenef, ;
						nValor, 	cMoeda,		nSaldo, 	dDtDigit, ;
						cNaturez, 	dDtDispo,	cBanco,		cAgencia, ;
						cConta,		cRecPag, 	cMotBX,		cPrefixo, ;
						cNumero,	cParcela, 	cCliFor,	cCliente, ;
						cLoja,		cHistor, 	cDocument,	cSeq	, ;
						cFilOriTit )

Default cSeq := ""



RecLock("SE5",.T.)
SE5->E5_FILIAL	:= xFilial("SE5")
SE5->E5_FILORIG	:= If(!Empty(cFilOriTit),cFilOriTit,cFilAnt)

REPLACE SE5->E5_DATA 	WITH dData
REPLACE SE5->E5_TIPO	WITH cTipo
REPLACE SE5->E5_BENEF 	WITH cBenef
REPLACE SE5->E5_TIPODOC	WITH cTipoDoc
REPLACE SE5->E5_VALOR	WITH nValor
REPLACE SE5->E5_MOEDA	WITH cMoeda
REPLACE SE5->E5_VLMOED2	WITH nValor  
REPLACE SE5->E5_DTDIGIT	WITH dDtDigit
REPLACE SE5->E5_NATUREZ	WITH cNaturez
REPLACE SE5->E5_DTDISPO	WITH dDtDispo
REPLACE SE5->E5_BANCO	WITH cBanco
REPLACE SE5->E5_AGENCIA	WITH cAgencia
REPLACE SE5->E5_CONTA	WITH cConta
REPLACE SE5->E5_RECPAG	WITH cRecPag
REPLACE SE5->E5_MOTBX	WITH cMotBX
REPLACE SE5->E5_PREFIXO	WITH cPrefixo
REPLACE SE5->E5_NUMERO	WITH cNumero
REPLACE SE5->E5_PARCELA	WITH cParcela
REPLACE SE5->E5_CLIFOR	WITH cCliFor
REPLACE SE5->E5_CLIENTE	WITH cCliente
REPLACE SE5->E5_LOJA 	WITH cLoja
REPLACE SE5->E5_HISTOR	WITH cHistor
REPLACE SE5->E5_DOCUMEN WITH cDocument
REPLACE SE5->E5_FORNADT WITH cCliente
REPLACE SE5->E5_LOJAADT WITH cLoja

If cTipo $ "NCC/CR /RA "
	REPLACE SE5->E5_SEQ 	WITH cSeq
EndIf
SE5->(MsUnlock())

//Gera FKs com base na SE5 gerada
FINXSE5( SE5->( Recno() ) , 3 )	//Baixas a Receber

//Compatibiliza as Fks com padrao do loja
LjCompFKs(.F.)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjMsgGrvTudo ºAutor  ³ Vendas Clientes     º Data ³05/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mensagem de erro e grava o erro                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjMsgGrvTudo(ExpL1, ExpC2, ExpC3)						       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ LjMsgGrvTudo( ExpL1, ExpC2, ExpC3)					       ³±±
±±³			 ³ 			                                                   ³±±
±±³			 ³ ExpL1 - Se esta utlizando venda assistida                   ³±±
±±³			 ³ ExpC2 - Numero do Orcamento                                 ³±±
±±³			 ³ ExpC3 - Texto a ser gravado                 				   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum			    		  							   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjMsgGrvTudo( lScreen, cNumOrc, cTexto)
Local cError  := STR0075 + cEmpAnt + STR0076 + cFilAnt + "  " + DToC(dDataBase) + "  " + Time() + ;
                 Chr(10) + cTexto + Chr(10)  // "Empresa:" ### " Filial:"

If !lScreen
	ConOut(Repl("*",40)+Chr(10)+Chr(10)+cError)
	ConOut(STR0077)  //'Este registro possui inconsistencias.'
	conOut(STR0078+Chr(10)+Repl("*",40))  //'Corrija-o e altere o L1_SITUA de "ER" Para "RX".'
EndIf

LjGravaLog( lScreen, cNumOrc, cTexto)
MsgStop(cTexto)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjGravaLog ºAutor  ³ Vendas Clientes     º Data ³05/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o log                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjGravaLog(ExpL1, ExpC2, ExpC3)					          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ LjGravaLog(ExpL1, ExpC2, ExpC3)						      ³±±
±±³			 ³ 			                                                  ³±±
±±³			 ³ ExpL1 - Se esta utlizando venda assistida                  ³±±
±±³			 ³ ExpC2 - Numero do Orcamento                                ³±±
±±³			 ³ ExpC3 - Texto a ser gravado                 		          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGravaLog( lScreen, cNumOrc, cTexto, nLevel, nType )

Default nLevel := LMOK
Default nType	 := LMTECH

If lRemoteType .AND. !Empty(LOG_TEF)
	cTexto := cTexto + ' - InTransaction = '+ If(InTransaction(),'.T.','.F.')
	LjWriteLog( LOG_TEF + cNumOrc + '.TXT', cTexto )
	If lLogManager
		LoggerOut( cTexto , nLevel, nType )
	EndIf
Else
	If lLogManager
		LoggerOut( "Log - Orcamento: " + cNumOrc + " - mensagem: " + cTexto , nLevel, nType )
	Else
		ConOut("Log - Orcamento: " + cNumOrc + " - mensagem: " + cTexto )
	EndIf
EndIf

LjGrvLog("LjGravaLog",cTexto)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjGravaErr ºAutor  ³ Vendas Clientes     º Data ³06/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava erro no SL1                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjGravaErr()            								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGravaErr(cTextoErro)

Default cTextoErro := STR0022 //"Ocorreu algum erro no processo de gravacao batch..."

If !lGrvErro

	LjGrvLog('GravaBatch', "ID_ERRO")
	LjGrvLog('GravaBatch', "ERRO: " + cTextoErro ,, .T. )

	RecLock("SL1", .F.)

	//Ocorreu que nao estava gravando o campo "L1_ERGRVBT", devido a mudanca do processo de integracao via LjGrvBatch que o "L1_SITUA" nao fica mais "RX"
	//por isso foi acrescentado o status "ER"
	If SL1->( ColumnPos("L1_ERGRVBT") ) > 0 .AND. ( SL1->L1_SITUA == "RX" .or. SL1->L1_SITUA == "ER" )
		REPLACE SL1->L1_ERGRVBT WITH cTextoErro
	EndIf

	REPLACE	SL1->L1_SITUA WITH "ER"

	SL1->( MsUnlock() )

	IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)

	//Grava Log para registros de Integração
	If SL1->L1_ORIGEM == "N" .And. ExistFunc("RMIGRVLOG")  .And. FwAliasInDic( "MHL" ) 
		RPCOpenTables({"MHL"}) //Necessario abrir tabela especifica         
		RMIGRVLOG( "IR"       ,"SL1"   ,SL1->(Recno()), "GRVBAT"    ,;
				cTextoErro ,        ,              ,             ,;
				.F.        , 1      ,SL1->L1_FILIAL+ SL1->L1_NUM, 'GRVBATCH', 'PROTHEUS' )
	EndIf

	lGrvErro := .T.

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjVerifGrv ºAutor  ³ Vendas Clientes     º Data ³14/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a venda foi grava corretamente                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjVerifGrv()            								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjVerifGrv( cDoc   , cSerie, cCliente, cLoja, cNumOrc )

Local cNumDoc := PadR(cDoc,TamSX3("F2_DOC")[1])		 //Codigo do documento
Local cNumSer := PadR(cSerie,TamSX3("F2_SERIE")[1])  //Serie do documento

cCliente:= PadR(cCliente,TamSX3("A1_COD")[1])  //Codigo do Cliente
cLoja   := PadR(cLoja,TamSX3("A1_LOJA")[1]) 	//Loja do Cliente

//SF2 - indice 1 - F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
SF2->( DbSetOrder( 1 ) )
If ! SF2->( DbSeek( xFilial( "SF2" ) + cNumDoc + cNumSer + cCliente + cLoja) )
	LjGravaLog(.T., cNumOrc, "ERRO - SF2 nao encontrado Doc->" + cDoc + " Serie->" + cSerie + " Cliente->" + cCliente + " Loja->" + cLoja, LMSTOP, LMPROC)
	Return .F.
EndIf

//SD2 - indice 3 - D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
SD2->( DbSetOrder( 3 ) )
If ! SD2->( DbSeek( xFilial( "SD2" ) + cNumDoc + cNumSer + cCliente + cLoja) )
	LjGravaLog(.T., cNumOrc, "ERRO - SD2 nao encontrado Doc->" + cDoc + " Serie->" + cSerie + " Cliente->" + cCliente + " Loja->" + cLoja, LMSTOP, LMPROC)
 	Return .F.
EndIf

//Verificar se o L1_DOC e L1_SERIE foram gravados
SL1->( DbSetOrder( 1 ) )
If SL1->( DbSeek( xFilial( "SL1" ) + cNumOrc) )
	If Empty( SL1->L1_DOC ) .OR. (Empty( SL1->L1_SERIE) .AND. !Empty(SuperGetMV("MV_LOJANF")))
		If Empty( SL1->L1_DOCPED ) .OR. Empty( SL1->L1_SERPED )
			LjGravaLog(.T., cNumOrc, "ERRO - SL1 ou L1_DOC ou L1_SERIE esta vazio", LMSTOP, LMPROC)
    	 	Return .F.
	 	EndIf
 	EndIf
Else
	LjGravaLog(.T., cNumOrc, "ERRO - Nao encontrou ou registro no SL1 Orcamento->" + cNumOrc, LMSTOP, LMPROC)
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjGrvTran  ºAutor  ³ Vendas Clientes     º Data ³21/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a venda foi grava corretamente                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjGrvTran()            								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjGrvTran(	lScreen, 		cNumOrc, 		aSL1, 			aSL2		,;
							lImpCupFis, 	aNotas, 		cNumNota, 		cSerie		,;
							nMaxItens, 		aImpsSF2, 		nTotLiq, 		nTotImp		,;
							nTotDesc , 		nBaseDup, 		nDecimais, 		nBasePS2	,;
							nValPS2	 , 		nBaseCF2, 		nValCF2, 		aRecSE1		,;
							aVlrAcres, 		cMV_TPNRNFS, 	lFinanceiro, 	nNccUsada	,;
							aNccItens,		nNccGerada,		aReceb,			aImpCheque	,;
							nMoedaCor,		nNumItens,		nFrete	  ,		nSeguro	   	,;
							nDespesa ,		nCheck,         cLQFrete,		lRetIncSx5	,;
							aAcrFin	 ,		lPedFin,		cCgcCli,		cNomeCli	,;
							lNfManual,      cEspecNf,		aBreakNota,		aNewNCC		,;
							cTpGeraGdp,		nOpc, 			lIsVendaVP, 	lIsVdRecCP  ,;
							nArredondar,	cDescErro,		lNFePDV )

Local nTotItens		:= 0											// Valor total dos itens   LjxTotItens()
Local nNotaAtu  	:= 1											// Indice no array de notas
Local cFirst														// Numero da Primeira nota (F2_DUPLI)
Local nRecnoSa1     := 0											// Recno do cliente
Local lCliente	 	:= .F.											// Procura cliente pelo CGC
Local nTotFin    	:= 0											// Variavel que realiza a somatoria do SL4, valor dos titulos financiados para a venda em modo Off Line
Local cNumContra 	:= ""											// Variavel que armazenara temporariamente o codigo do contrato para venda em modo Off Line
Local cRecno		:= 0											// Recno do SM0
Local lFaturar  	:= .T.											// Gerar nota Fiscal .T. ou .F. (Eh falso somente quando eh pedido nao finalizado)
Local nItens    	:= 0											// Controle do numero de itens por nota
Local cItemNF   	:= "00"											// Controle para numeracao de itens acima de 100 (A0,A1,...)
Local nValIss		:= 0											// Valor total di ISS
Local nF2ValISS		:= 0											// Soma o valor do ISS, caso o parametro lMvTpAbISS == .T. e lMvDescISS == .F.
Local nF2BaseISS	:= 0											// Soma a base do ISS, caso o parametro lMvTpAbISS == .T. e lMvDescISS == .F.
Local nBaseImp		:= 0											// Base do imposto calculado
Local nValImp		:= 0											// Valor do imposto calculado
Local aLivro 		:= {}											// Array utilizado na gravacao do livro fiscal - Localizacoes
Local nValIcm		:= 0											// Valor total do ICMS
Local nValIpi		:= 0											// Valor total do IPI
Local nBrIcms		:= 0											// Valor total de base do ICMS Retido
Local nIcmsRet  	:= 0											// Valor total de ICMS Retido
Local nValPIS    	:= 0											// Valor total do PIS
Local nValCSLL   	:= 0											// Valor total do CSLL
Local nValCOFI   	:= 0											// Valor total do COFINS
Local nValINSS   	:= 0											// Valor total do INSS
Local nValIRRF   	:= 0											// Valor total do IRRF
Local nBasePIS    	:= 0											// Base de calculo do PIS
Local nBaseCSLL   	:= 0											// Base de calculo do CSLL
Local nBaseCOFI   	:= 0											// Base de calculo do COFINS
Local nBaseINSS   	:= 0											// Base de calculo do INSS
Local nBaseIRRF   	:= 0											// Base de calculo do IRRF
Local cProxNum  	:= Nil											// Proximo numero
Local nAliqISS		:= 0											// Aliquota do ISS caso nao exista
Local aImps			:={}											// Array para armazenamento dos dados do Imposto - Localizações
Local nPos			:=0                								// Utilizado para armazenar o posicionamento dos campos de impostos  -  Localizações
Local aImpVarSD2	:= {}											// Array utilizado na gravacao do livro fiscal - Localizacoes
Local aGetBook 														// Array utilizado na gravacao do livro fiscal - Localizacoes
Local aVendedor		:= {}											// Vendedores utilizados no SL2, para gravacao no financeiro
Local nRecnoSF2		:= 0 											// Controle do recno do SF2
Local aCaixaFin 	:= {} 											// Array com dados do SA6
Local nY			:= 0											// Utilizado para contadores diversos
Local nX			:= 0											// Utilizado para contadores diversos
Local i				:= 0						    				// Utilizado para contadores diversos
Local nVlrAcreFin	:= 0											// Total do Acrescimo Financeiro.
Local lLJGRVAD2 	:= ExistBlock( "LJGRVAD2" )						// Ponto de entrada antes da gravacao do SD2
Local lFTVDGRVAD2 	:= ExistBlock( "FTVDGRVAD2" )					// Ponto de entrada antes da gravacao do SD2
Local nDecDesc		:= TamSX3("D2_DESC")[2]							// Numero de Decimais do Campo D2_DESC
Local aRelImp    	:= MaFisRelImp("MT100",{ "SD2" })				// Retorno da funcao MaFisRelImp()
Local lMvTpAbISS	:= ( SuperGetMV("MV_TPABISS", NIL, "1")=="1" )  // Existe abatimento de ISS
Local lMvDescISS	:= SuperGetMV("MV_DESCISS", NIL, .T.)			// Verifica se o ISS deve ser descontado ou nao
Local nTamAE_COD  	:= TamSx3("AE_COD")[1] 							// Tamanho do campo AE_COD
Local cMV_FORMCRD	:= SuperGetMV("MV_FORMCRD",,"CH/FI")			// Formas de pagamento que devem ter analise de credito
Local cMvAliqIss	:= SuperGetMV( "MV_ALIQISS" )					// Variavel com a aliquota DEFAULT do ISS
Local lFirst    	:= .T.							   				// Controle para primeira nota (caso haja desmembramento)
Local aTotais		:= {0, 0, 0}									// 	Acumuladores [01] F2_VALMERC,[02] F2_DESCONT, [03] F2_VALACRS
Local nComis		:= 0											// Valor da comissao para o item
Local nVAlFSD		:= 0											// Soma Frete Seguro e Despesas
Local lFisLivro 	:= (SuperGetMV("MV_LJLVFIS",,1) == 2)			// Utiliza novo conceito para geracao do SF3
Local aAreaSC0		:= {}											//Reservas
Local lEmisNF		:= .F.											// Se esta emitindo NF ou Cupom
Local cNumNFFech	:= ""											// Numero da NF a ser finalizada
Local aAreaSF2		:= {}											// Armazena o posicionamento do SF2
Local lCalcFin		:= (SuperGetMv("MV_CALCFIN",,"M")== "F")  		//variavel para controle do parametro MV_CALCFIN = [F]inanciado
Local aProdCri		:= {}
Local cGrupoProd    := {}
Local nTotPontos  	:= 0
Local cPgVc 		:= ""
Local lUsaCrd		:= SuperGetMV("MV_FRTCRD",,.F.)
Local lGerInt       := SuperGetMv("MV_LJGRINT",.F.,.F.) 			// Verifica se tem integracao ou nao
Local nBaseRed      := 0                                            // Valor da base reduzida
Local lHabArred 	:= SuperGetMv("MV_LJIPECF",,.F.)  				// calcula o imposto conforme o ECF
Local nVlTotDesp    := 0                                            // Valor total das despesas
Local nTotDescFrt   := 0                                            // Total de desconto (Front Loja)
Local nVlrAcrs      := 0                                           	// Total de Acrescimo
Local lLjDespa		:= SuperGetMv("MV_LJDESPA",,.F.)			 	// Habilita desconto por Adm e banco
Local cPafMd5		:= "" 											// Chave MD5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()	//Indica se a recarga de cartao fidelidade esta ativa
Local lRetFid		:= .F.											//Indica se o movimento do cartao fidelidade foi processado com sucesso
Local lMvLjPdvPa    := LjxBGetPaf()[2]							//Indica se é pdv

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes³
//³Paises:Chile/Colombia-F1CHI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aItens		:= {}											//Itens das notas geradas a partir da venda, quando o numero de itens venda exceder o limite e a nota original for divida em mais de uma - Release 11.5 - Chile
Local lLocR5 		:= cPaisLoc $ "CHI|COL"
Local lCFolChiR5	:= cPaisLoc$"CHI" .AND. SuperGetMv("MV_CTRLFOL",.F.,.F.) .AND. !lFiscal	//Localizao CHILE, Release 11.5, Controle de Formulariios Ativo,Usuario nao fiscal
Local cNumOrcPai	:= Iif(!lScreen,SL1->L1_ORCRES,M->LQ_NUM) 		//Numero do orcamento pai
Local nTotImpIt		:= 0											//Total de impostos do item
Local nVlrTrocoAux	:= 0											//Variável auxiliar para o troco do produto
Local nVlrDescItem	:= 0											//Variável auxiliar para soma do desconto, caso haja desconto no item
Local nVlrCredDesc	:= 0											//Variável que trata a soma do L1_CREDITO com L2_VALDESC
Local lCAT83 		:= SD2->(FieldPos("D2_CODLAN")) > 0 .AND. ;
					   SL2->(FieldPos("L2_CODLAN")) > 0 .AND. ;
					   FindFunction("FISA023") 			.AND. ;
					   SuperGetMV("MV_CAT8309",,.F.) // Verifica CAT/83

Local lFtvdVer12	:= LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") //Nome da Rotina
Local lLjDifal 	  	:= SuperGetMV("MV_LJINTUF",,0) > 0 		//Ativa verificação e operacoes relacionadas ao DIFAL

Local cCodIss 		:= ""											// Codigo de servico
Local lMVLJPRDSV    := SuperGetMv("MV_LJPRDSV",.F.,.F.) 			// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local aItensProd	:= {}											// Armazena somente itens de "Produto"
Local aItensServ	:= {}											// Armazena somente itens de "Servico"
Local aItServ2		:= {}
Local aItensSL2		:= {}											// Armazena todos os itens da SL2 {Itens de "produto"} e {Itens de "servico"}
Local aItensGar		:= {}											// Armazena somente itens de "Garantia"
Local aItensSFin	:= {}											// Armazena somente itens de "Servicos Financeiros"
Local aItensVP		:= {}											// Armazena somente itens de "Servicos Financeiros"
Local nIndnX		:= 0
Local nIndnY		:= 0
Local lIsNextNF 	:= .T.
Local lQuebraNF		:= .F.											// Controla se quebra a Nota (SF2), gerando uma nota com itens de "produto" e outra com itens de "servico"
Local lIsNFServ 	:= .F.											// Controla se a NF em questao eh NF de "servico"
Local lTemItServ  	:= .F.											// Controla se tem ou nao itens de "servico" na venda
Local aNotaRPS 	 	:= {}											// Array com informacoes do Numero e Serie da NF de "Servico" (RPS)
Local cSerieNF 		:= cSerie										// Serie da Nota Fiscal
Local lBreakNFPS 	:= .F.  										// Indica que ira quebrar a NF em mais de uma nota (no caso de existir itens de "Produto" e de "Servico")
Local lBreakNFGar	:= .F.
Local lLj7Arred     := FindFunction("Lj7Arred")						// Verifica a existencia da função lj7arred que esta no LOJa701C
Local lCpoAcres 	:= SL2->(FieldPos("L2_VALACRS")) > 0			// Verifica a existencia do campo de Acrescimo Financeiro no L2
Local nCountIT		:= 0 											// Total de itens, usada para calculo de acrescimo
Local nDiffAc       := 0 											// Diferenca entre total de Acrescimo no Total e Soma de Acrescimo Rateado de itens
Local nFreteProp    := 0											// Valor do Frete Proporcional
Local nDespeProp    := 0											// Valor da Despesa Proporcional
Local nSegurProp    := 0											// Valor do Seguro Proporcional
Local cOrigVend		:= SL1->L1_ORIGEM								// Origem da Venda (FRT=FrontLoja; LOJ=Loja)
Local lOnlyServ		:= .F.
Local aEmp			:= {}											// Array contendo os ítens a serem empenhados na Ordem de Produção quando utilizado o template Ótica
Local lGeraOP		:= SuperGetMV("MV_GROPOTC ",.F.,.F.)			// Parâmetro para verificar a necessidade de criar ou não Ordem de Produção para o template Otica								   			// Indica se a venda tem somente itens de "servico"
Local nScanPis   	:= 0											// Retorna posicao do campo
Local lL2_SEGUM  	:= SL2->(FieldPos( "L2_SEGUM" )) > 0			// Verifica se campo existe
Local lTPLOtica 	:= HasTemplate("OTC")							// Verifica se eh Template Otica
Local lMvArrefat 	:= SuperGetMv("MV_ARREFAT") == "S"				// Define se arredonda os valores
Local lB1FANTASM	:= SB1->(FieldPos( "B1_FANTASM" )) > 0			// Usado para verificar a geração de empenho no TPL de OTC
Local lL2VALPS2 	:= SL2->(FieldPos( "L2_VALPS2"  )) > 0			// Verifica se campo existe
Local lL2VALCF2 	:= SL2->(FieldPos( "L2_VALCF2"  )) > 0			// Verifica se campo existe
Local lL2BASEPS2 	:= SL2->(FieldPos( "L2_BASEPS2" )) > 0			// Verifica se campo existe
Local lL2BASECF2 	:= SL2->(FieldPos( "L2_BASECF2" )) > 0			// Verifica se campo existe
Local lL2ALIQPS2 	:= SL2->(FieldPos( "L2_ALIQPS2" )) > 0			// Verifica se campo existe
Local lL2ALIQCF2 	:= SL2->(FieldPos( "L2_ALIQCF2" )) > 0			// Verifica se campo existe
Local lL2VALEPRE	:= SL2->(FieldPos( "L2_VALEPRE" )) > 0			// Verifica se campo existe
Local lD2DESCICM  	:= SD2->(FieldPos( "D2_DESCICM" )) > 0	   		// Verifica se campo existe
Local lD2CFPS  		:= SD2->(FieldPos( "D2_CFPS"    )) > 0	   		// Verifica se campo existe
Local lD2SITTRIB  	:= SD2->(FieldPos( "D2_SITTRIB" )) > 0	   		// Verifica se campo existe
Local lD2FECP		:= SD2->(ColumnPos( "D2_ALQFECP" )) > 0 .And. SD2->(ColumnPos( "D2_VALFECP" )) > 0 // Verifica se campo existe
Local lD2BASFECP	:= SD2->(ColumnPos( "D2_BASFECP" )) > 0			// Verifica se campo existe	 
Local lD2FECPST		:= SD2->(ColumnPos( "D2_ALFCPST" )) > 0 .And. SD2->(ColumnPos( "D2_VFECPST" )) > 0 // Verifica se os campos FECP_ST existem
Local lD2STBASFECP	:= SD2->(ColumnPos( "D2_BSFCPST" )) > 0			// // Verifica se campo Base FECP_ST existe 
Local lL2FECP		:= SL2->(ColumnPos( "L2_ALQFECP" )) > 0 .And. SL2->(ColumnPos( "L2_VALFECP" )) > 0 // Verifica se campo existe
Local lL2BASFECP	:= SL2->(ColumnPos( "L2_BASFECP" )) > 0			// Verifica se campo existe	 
Local lL2FECPST		:= SL2->(ColumnPos( "L2_ALQFCST" )) > 0 .And. SL2->(ColumnPos( "L2_VFECPST" )) > 0 // Verifica se os campos FECP_ST existem
Local lL2STBASFECP	:= SL2->(ColumnPos( "L2_BSFCPST" )) > 0			// // Verifica se campo Base FECP_ST existe 
Local lL2ITEMCC	:= SL2->(ColumnPos( "L2_ITEMCC" )) > 0			// Verifica se campo existe	 
Local lL2CCUSTO	:= SL2->(ColumnPos( "L2_CCUSTO" )) > 0			// Verifica se campo existe	 
Local lL2CLVL	:= SL2->(ColumnPos( "L2_CLVL" )) > 0			// Verifica se campo existe	
Local lL2DTVALID  	:= SL2->(FieldPos( "L2_DTVALID" )) > 0	   		// Verifica se campo existe
Local lPafEcf 		:= If(!lFtvdVer12,LjNfPafEcf(SM0->M0_CGC),.F.)	// Sinaliza se utiliza PAF-ECF
Local cMvMapaRes  	:= SuperGetMV("MV_MAPARES") 					// Forma de utilizacao do mapa resumo. "U"-utiliza mapa resumo mas nao e obrigatorio, "O"-uso obrigatorio e "N"-Nao utiliza.
Local lFRTECF13  	:= ExistBlock("FRTECF13") 						// PE para indicar se o ECF faz o arredondamento (.T.) ou truncamento (.F.) dos valores.
Local lStatusImp13	:= .F.											// Pega o retorno do PE FRTECF13 para verificar arredondamento
Local nVlrMerc			:= 0 										// Valor Mercadoria usada no MafisAdd
Local nBaseISS		:= 0											// Valor base de ISS
Local cLjPref		:= ""											// Prefixo do titulo a ser gravado nos campos x_PREFIXO
Local lLjGrvFisc	:= ExistBlock("LJGRVFISC")						// Ponto de entrada Machima
Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE")     			// Garantia Estendida
Local cMvLjTSFin	:= SuperGetMV("MV_LJTPSF",,"SF")     			// Servico financeiro
Local lD2ItemGar	:= SL2->(FieldPos("L2_ITEMGAR")) > 0 .AND. SD2->(FieldPos("D2_ITEMGAR")) > 0	// Verifica a existencia do campo XX_ITEMGAR
Local lD2OrcGar		:= SD2->(FieldPos("D2_ORCGAR")) > 0			// Verifica a existencia do campo D2_ORCGAR
Local nDcD2TOTAL  	:= TamSx3("D2_TOTAL")[2]						// Numero de Decimais do Campo D2_TOTAL
Local nDedICM		:= 0
Local nW			:= 0
Local nAcreTotBk	:= 0
Local lGE			:= LjUP104OK()									// Validação do Conceito Garantia Estendida
Local lLeiTran		:= SL2->(FieldPos("L2_TOTIMP"))> 0 .And. SD2->(FieldPos("D2_TOTIMP"))> 0 .And. SF2->(FieldPos("F2_TOTIMP"))> 0 .And. SF2->(FieldPos("F2_TIPIMP"))>0  //Verifica se existem os campos para utilização da Lei da transparência
Local aSxFci		:= {}											// Verifica parametrização e campos para uso das informações de FCI
Local cClasFis		:= ""											// Classificação Fiscal do Produto
Local lLjGrvSL2		:= ExistBlock("LJGRVSL2")						// Ponto de entrada
Local ljImpGf		:= SuperGetMv("MV_LJIMPGF",,.F.)
Local lSFinanc      :=  SuperGetMV("MV_LJCSF",,.F.)
Local cMV_B1M996	:= GetNewPar("MV_B1M996", "") //Campo da tabela SB1 que identifica venda para Orgaos Publicos. Tratamento Apuração de PIS/COF.
Local cB1M996		:= "" //Informacao do Campo do Cadastro de Produtos (Configurado no parametro MV_B1M996) utilizado para identificar PIS/Cofins para pessoa juridica de direito Publico. Art. 7, Lei 9718(SRF).
Local lB1M996 		:= SB1->(FieldPos(cMV_B1M996)) > 0  //Identifica se o campo configurado no parametro "MV_B1M996" existe na tabela SB1.
Local aCusto		:= {}											// Vetor com os custos do produto, conforme o retorno da função GravaCusD2()
Local nItemProd 	:= 0											// Variavel que ira passar o numero Item igual a Produto
Local nItemServ 	:= 0											// Variavel que ira passar o numero Item igual a Servico
Local lMVPRDSERV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 			// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local lAcrescBC		:= ChkIncICMS()									// Incide Icms sobre juros de operações financeiras
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local aTimeUf		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT		:= ""
Local lIntSynt 	 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
Local nTamSerie     := TamSX3("L1_SERIE")[1]				// Tamanho do campo L1_SERIE
Local cMVLOJASF		:= PadR(SuperGetMv("MV_LJTPSFA",,"SFA"), nTamSerie )// Serie do Serviço Financeiro Avulso se somente todos os itens tiverem S.Fin.Avulso
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel referente a implementacao da nova lei dos impostos 13032015³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCpoImpEnt	:=	SD2->(FieldPos("D2_TOTFED")) > 0 .AND.	SD2->(FieldPos("D2_TOTEST")) > 0 .AND. ;
						SD2->(FieldPos("D2_TOTMUN")) > 0 .AND.	SF2->(FieldPos("F2_TOTFED")) > 0 .AND. ;
						SF2->(FieldPos("F2_TOTEST")) > 0 .AND.	SF2->(FieldPos("F2_TOTMUN")) > 0 .AND. ;
						SL2->(FieldPos("L2_TOTEST")) > 0

Local nTentativas	:= 0
Local lGerFin		:= .T.
Local cPrefSFA	    := ""	//Prefixo Serviços Financeiros Avulsos
Local cTitSFA		:= ""	//Título Serviços Financeiros Avulsos
Local nComisAux	    := 0 //Auxiliar para calculo comissao
Local cMvComisCC	:= Upper( SuperGetMv("MV_COMISCC",,"S") )		// Verifica se deduz ou nao a taxa da adm. financeira p/ LOJA
Local nTDCPED		:= TamSx3("DC_PEDIDO")[1]
Local nTDCITE		:= TamSx3("DC_ITEM")[1]
Local nTDCSEQ		:= TamSx3("DC_SEQ")[1]
Local lRet			:= .T.	
Local lMultNegoc	:= SL1->(ColumnPos("L1_CODMNEG")) > 0 .And. !Empty(SL1->L1_CODMNEG)
Local aArea		    := GetArea()
Local lIntegDef	    := SL1->L1_ORIGEM == "N" //Venda de Origem Integração
Local lIntegHtl	    := lIntegDef .And. SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria 
Local aRelImpInt	:= {} //Relacao de impostos, usado para integracao Mensagem Unica
Local nBasePisApu	:= 0 //Base Pis Apuracao
Local nValPisApu	:= 0 //Valor Pis Apuracao
Local aAreaSF3	    := SF3->(GetArea()) //Area SF3
Local cProcesso	    := "000405" //Codigo Processo PCO
Local cCodItem	    := "01" //Item PCO
Local aTesInteg	    := {} //Array com informacoes Tes - Integracao Mensagem Unica
Local cCodCli 		:= "" //Codigo do Cliente 
Local cLojaCli		:= "" //Loja do Cliente
Local aCusDev		:= {} //Array com informações para o custo de Devolução	
Local lUseSAT		:= LjUseSat()   // Verifica se utiliza SAT
Local lCpBzConta	:= SBZ->(ColumnPos("BZ_CONTA")) > 0				// Verifica a existencia do campo de Conta Contabil na SBZ
Local cCtaCont		:= ""											// Recebe o numero da conta contabil
Local aRetfor       := {}
Local cFilRes		:= cFilAnt
Local cFilBkp		:= cFilAnt	
Local cTipoNF		:= "S"		//Tipo de Nota de saida padrão
Local cCliFor 		:= "C"      //Tipo cliente ou fornecedor. cliente padrão
Local cTpCliFor 	:= ""       //Tipo do cliente cliente ou fornecedor
Local cCodCliFor   	:= ""
Local cLoja			:= ""
Local lL2BASEIPI  	:= SL2->(ColumnPos("L2_BASEIPI")) > 0
Local lL2IPI  		:= SL2->(ColumnPos("L2_IPI")) > 0
Local lL2ALIQSOL	:= SL2->(ColumnPos("L2_ALIQSOL")) > 0
Local lWmsNew   	:= SuperGetMV("MV_WMSNEW",.F.,.F.)				// Parâmetro para NOVO WMS
Local oEstEnder 	:= nil											// Objeto para estoque de endereçamento para novo WMS
Local xRet			:= {}
Local nVFunrural	:= 0 											// Valor do FUNRURAL
Local nPosVend		:= 0                                            // Guarda Posição do Vendedor no array aVendedor
Local cTipTef       := LjGetStation("LG_TIPTEF")					// Tipo do TEf no Cadastro de Estações
Local lEmitNFCe 	:= LjEmitNFCe()
Local lAutoExA		:= IsBlind()	// Verifica se a rotina sera executada via execauto ou nao

Private cEspecie  	:= ""									   		// Cupom fiscal ou NF
Private nTotCargT	:= 0											// Variavel do valor total de carga tributáia - somatótia dos itens

Default cLQFrete	:= "" 											// Recebe conteudo do campo LQ_TPFRET 1- CIF 2- FOB
Default lRetIncSx5	:= .F.											// Verifica se já atualizou o SX5
Default lPedFin		:= .F.									        // Indica se e um pedido
Default aAcrFin     := {}
Default cEspecNf    := Nil											// Especie do documento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes³
//³Paises:Chile/Colombia-F1CHI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default aBreakNota	:= {}											//Notas geradas a partir da venda, quando o numero de itens venda exceder o limite e a nota original for divida em mais de uma.
Default aNewNCC		:= {}											//Array com as Notas de Créditos informadas
Default cTpGeraGdp	:= GDP_NO
Default nOpc		:= 3
Default nArredondar := 0
Default cDescErro	:= ""
Default lNFePDV	:= .F.												//Variavel para saber esta no Totvs PDV 

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
If ValType(cHoraRMT) == "L"
	If cHoraRMT
		cHoraRMT := "1"
	Else
		cHoraRMT := "2"
	EndIf
Else
	If cHoraRMT == NIL
		cHoraRMT := "2"
	EndIf
EndIf

//Relacao de impostos, usado para integracao Hotelaria
If lIntegDef
	aRelImpInt := MaFisRelImp("MT100", {"SF2","SD2"}) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Begin Transaction³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LjGravaLog(lScreen, cNumOrc, '1) LOJXFUNC -- LjGrvTudo ' + Replicate('-',40) + Chr(13) + Chr(10) + ;
                             '	2) cEstacao = '            + cEstacao + Chr(13) + Chr(10) + ;
                                '	3) lFiscal = '             + If(lFiscal,'.T.','.F.') + Chr(13) + Chr(10) + ;
                                '	4) cUsuario = '            + cUserName + Chr(13) + Chr(10) + ;
                                '	5) xNumCaixa() = '         + xNumCaixa() + Chr(13) + Chr(10) + ;
                                '	6) lImpCupFis = '          + If(lImpCupFis,'.T.','.F.') + Chr(13) + Chr(10) + ;
                                '	7) L1_DOC = '              + SL1->L1_DOC + Chr(13) + Chr(10) + ;
                                '	8) L1_SERIE = '            + SL1->L1_SERIE + Chr(13) + Chr(10) + ;
                                '	9) Tem Log = '            + Subs(LJGetProfile("LOGERRO"),1,1) + Chr(13) + Chr(10) + ;
                                '	10) Tem Monitoramento = '            + Subs(LJGetProfile("LOGERRO"),4,1) + Chr(13) + Chr(10) + ;
                                '	11) BEGIN TRANSACTION')

//Somente considera ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas, se a venda nao for com "Reserva" e nao for concomitante
lMVLJPRDSV := lMVLJPRDSV .And. Empty(SL1->L1_ORCRES) .And. Empty(SL1->L1_DOCPED)

aSxFci := Iif(FindFunction("LjCFciParam"), LjCFciParam(), {.F. , "", .F., .F., .F., .F., .F., .F.})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So devem ser atualizadas as SL1, SL2 e SF2 quando a venda for venda assistida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lScreen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os dados da SL1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7GeraSL( "SL1", aSL1, .F., .F. )
	LjGravaLog( lScreen, cNumOrc , 'Atualizou SL1', LMALERT, LMPROC)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a gravacao do SL2                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL2")
	DbSetOrder(1)
	DbSeek(xFilial("SL2") + SL1->L1_NUM)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor para dar baixa no Lay-Away  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOutros    := SL1->L1_OUTROS
	While !EOF() .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM
		//Devido a emissao de NF-e no PDV devermos validar se o item nao foi cancelado no PDV
		if lNFePDV .and. SL2->L2_VENDIDO <> "S"
			SL2->( DbSkip() )
			Loop			
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados da SL2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj7GeraSL( "SL2", aSL2 )

		LjGravaLog( lScreen, cNumOrc , 'Atualizou SL2', LMALERT, LMPROC)

		DbSelectArea("SL2")
		DbSkip()
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a separacao de itens de "Produto" e itens de "Servico", caso o parametro MV_LJPRDSV esteja ativo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL2")
SL2->( DbSetOrder(1) )
SL2->( DbSeek(xFilial("SL2") + SL1->L1_NUM) )
While SL2->( !EOF() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM

	// Busca tipo de produto para garantia
	dbSelectArea("SB1")
	SB1->(MsSeek( xFilial("SB1") + SL2->L2_PRODUTO ))

	If Lj7CP_OK() .And. Lj7CP_Ativ() .And. Lj7CP_Prod(SL2->L2_PRODUTO)
		lIsVdRecCP := .T. //Indica que eh venda de Recarga de Cartao Presente (Gift Card)
	ElseIf lL2VALEPRE .And. !Empty(SL2->L2_VALEPRE) .And. Lj7VPNew()
		lIsVendaVP 	:= .T.

		If nModulo == 12 .And. lScreen .And. !lMvLjPdvPa //Somente se for SIGALOJA On-Line
			// Efetua a gravação da venda do Vale Presente
			LjGrVVlPre(	SL2->L2_VALEPRE	, SL1->L1_VEND  , SL2->L2_DOC , SL1->L1_ESTACAO,;
				   		SL2->L2_PDV		, SL1->L1_EMISNF, SL1->L1_HORA, SL1->L1_CLIENTE,;
						SL1->L1_LOJA, SL2->L2_SERIE )
		EndIf
	Else
		lIsVendaVP 	:= .F.
	EndIf

	If Empty(cOrigVend)
		If !Empty(SL2->L2_NUMORIG) //Se tiver preenchido o campo L2_NUMORIG, significa que foi um orcamento importado e finalizado por um PDV FrontLoja
			cOrigVend := "FRT" //Venda Finalizada no FRONT (Origem = FRT)
		Else
			cOrigVend := "LOJ" //Venda Finalizada no LOJA  (Origem = LOJ)
		EndIf
	EndIf

	//Item de "servico"
	If lSFinanc .AND. Alltrim(cMvLjTSFin) == Alltrim(SB1->B1_TIPO)// Produto Garantia não vai para D2
		//item de servico nao devera vigorar na nota, somente no orcamento
 		aAdd( aItensSFin, { SL2->L2_ITEM, SL2->(Recno()) } )
	ElseIf lMVLJPRDSV .And. LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) .And. ( lScreen .Or. ( !lScreen .And. ( ( cOrigVend == "FRT" .And. !Empty(SL2->L2_NUMORIG) ) .Or. ( cOrigVend == "LOJ" ) ) ) ) 
			If Len(aItensServ) > 0
				If (nPos := aScan(aItensServ,{|x| x[3]==SL2->L2_CODISS} ) ) > 0
					aAdd( aItensServ, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
				Else
					aAdd( aItServ2, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
				EndIf
			Else
				aAdd( aItensServ, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
			EndIf
	ElseIf lFtvdVer12 .AND. lMVLJPRDSV .And. LjIsTesISS(SL1->L1_NUM,SL2->L2_TES)
		If Len(aItensServ) > 0
			If (nPos := aScan(aItensServ,{|x| x[3]==SL2->L2_CODISS} ) ) > 0
				aAdd( aItensServ, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
			Else
				aAdd( aItServ2, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
			EndIf
		Else
			aAdd( aItensServ, { SL2->L2_ITEM, SL2->(Recno()) , SL2->L2_CODISS} )
		EndIf
	ElseIf ljImpGf .AND. Alltrim(cMvLjTGar) == Alltrim(SB1->B1_TIPO)// Produto Garantia não vai para D2
		//item de garantia nao devera vigorar na nota, somente no orcamento
 		aAdd( aItensGar, { SL2->L2_ITEM, SL2->(Recno()) } )
	ElseIf lIsVendaVP // Produto Vale presente
		//item de servico nao devera vigorar na nota, somente no orcamento
 		aAdd( aItensVP, { SL2->L2_ITEM, SL2->(Recno()) } )
	Else  //Item de "produto"
		aAdd( aItensProd, { SL2->L2_ITEM, SL2->(Recno()) } )
	EndIf

	//Calcula o Valor total dos itens
	nTotItens += SL2->L2_VLRITEM

	SL2->( DbSkip() )
End
//Coloca os itens na ordem como serao considerados. Primeiro itens de "produto" e depois itens de "servico"
If Len(aItensProd) > 0
	aAdd( aItensSL2, aItensProd )
EndIf
If Len(aItensServ) > 0
	lTemItServ := .T. //Indica que tem itens de "servico" na venda
	aAdd( aItensSL2, aItensServ)
	If Len(aItServ2) > 0
		aAdd( aItensSL2, aItServ2)
	EndIf
EndIf
If lMVLJPRDSV .And. Len(aItensServ) > 0 .And. Len(aItensProd) > 0
	lBreakNFPS := .T.
	nNumItens := Len(aItensSL2[1])
EndIf

If ( Len(aItensGar) > 0 .Or. Len(aItensSFin) > 0)
	lBreakNFGar := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
//³ cMV_TPNRNFS for igual a "3" e nao for impressao de cupom)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3" .AND. !lImpCupFis
	If Empty(aNotas)
		aAdd( aNotas, { cSerie,  MA461NumNf( .T., cSerie ) } )
	EndIf
	cSerie 		:= aNotas[nNotaAtu][1]
	cNumNota 	:= aNotas[nNotaAtu][2]
    LjGravaLog( lScreen, cNumOrc, '11) cSerie = '   + cSerie + Chr(13) + Chr(10) + ;
			            '	12) cNumNota = ' + cNumNota, LMALERT, LMPROC )
EndIf

If Select("MAH") > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criar o contrato e suas referencias no caso de uma venda forcada                              ³
	//³ Para identificarmos se uma venda foi forcada, o campo L1_FORCADA deverá estar com conteudo = 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SM0")
	DbSetOrder(1)
	cRecno:= Recno()
	DbSeek(cEmpAnt+cFilAnt)

	If SL1->(FieldPos("L1_FORCADA")) > 0 .AND. SL1->L1_FORCADA == Str(FORCADA,1)

		If SL1->(FieldPos("L1_CGCCART")) > 0

			If !Empty(SL1->L1_CGCCART)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pesquisa pelo numero do CGC/CPF                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SA1")
				nRecnoSa1 := Recno()
				DbSetOrder(3) 	// Filial + CGC
				If DbSeek(xFilial("SA1")+SL1->L1_CGCCART)
					lCliente := .T.
				EndIf

                If !lCliente
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Pesquisa pelo numero do cartao                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("MA6")
					DbSetOrder(1)	// Filial + Num
					If DbSeek(xFilial("MA6")+SL1->L1_CGCCART)
						DbSelectArea("SA1")
						DbSetOrder(1) 	// Filial + Cod + Loja
						If DbSeek(xFilial("SA1")+MA6->MA6_CODCLI+MA6->MA6_LOJA)
							lCliente := .T.
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Foi realizada uma Venda Off Line onde nao foi possivel identificar o cliente na    ³
				//³Venda porque alem do Web Service estar fora do ar, o Caixa do Front Loja nao tinha ³
				//³o cadastro do cliente localmente. Desta forma, o cliente agora eh localizado atra- ³
				//³vez do CPF/CGC ou atraves do numero do cartao, o que tiver sido informado.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCliente
					RecLock("SL1",.F.)
					SL1->L1_CLIENTE 	:= SA1->A1_COD
					SL1->L1_LOJA		:= SA1->A1_LOJA
					MsUnlock()
				Else
					DbSelectArea("SA1")
					DbGoTo(nRecnoSa1)
				EndIf
			EndIf
		Else
			ConOut("Falta criar o campo L1_CGCCART (Caracter, Tamanho de 16). Informe ao administrador do sistema.")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar através do SL4 o valor da venda que foi financiada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "SL4" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "SL4" ) + SL1->L1_NUM )

		SAE->( DbSetOrder( 1 ) )

		While !SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM	.AND. Empty(SL4->L4_ORIGEM)
			If SAE->(DbSeek(xFilial("SAE")+Left(SL4->L4_ADMINIS,nTamAE_COD))) .AND. AllTrim(SL4->L4_FORMA) $ cMV_FORMCRD
				If SAE->AE_PLABEL == "1"
					nTotFin += SL4->L4_VALOR
				EndIf
			EndIf
			SL4->(DbSkip())
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera novo contrato com status OK quando venda forcada      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumContra   := CrdGeraContr(nTotFin   ,SL1->L1_PDV   ,SL1->L1_OPERADO)
	EndIf
	DbSelectArea("SM0")
	DbGoTo(cRecno)

	DbSelectArea("SL1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Trava o orcamento para que ninguem o use enquanto esta sendo fechado e tambem para gravar informacoes adicionais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SL1",.F.)

//Caso esteja ativa a implementacao de venda com Produto x Servicos (RPS), verifica se a venda possui apenas itens de servico
If lMVLJPRDSV .And. !lScreen .And. Len(aItensProd) == 0 .And. Len(aItensServ) > 0 //Verifica se eh NF de servico apenas (apenas com itens de "servicos")

	//Caso seja uma venda finalizada pelo FrontLoja atraves de importacao de orcamento e nesta venda possuir apenas itens de servico,
	//o campo L1_DOC ainda estara vazio, entao pega o numero da nota de servico (RPS) para alimentar o campo L1_DOC.
	If ( Empty(cNumNota) .And. lImpCupFis .And. Empty(SL1->L1_DOC) .And. Empty(SL1->L1_SERIE) .And. !Empty(SL1->L1_SERRPS) ) .Or.; //Venda finalizada no FrontLoja
		( !Empty(SL1->L1_DOCRPS) .And. !Empty(SL1->L1_SERRPS) .And. SL1->L1_DOC == SL1->L1_DOCRPS .And. SL1->L1_SERIE == SL1->L1_SERRPS ) //Venda finalizada no LOJA (PAF-ECF)

		lOnlyServ := .T. //Indica que a venda tem somente itens de "servico"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a Serie e Numero da Nota de Servico (RPS). ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNotaRPS := LjSerNfRPS()
		If aNotaRPS[1]
			cNumNota 	:= aNotaRPS[2][1]
			cSerie	 	:= aNotaRPS[2][2]

			SL1->L1_DOC 	:= cNumNota
			SL1->L1_SERIE 	:= cSerie
		EndIf
	EndIf
EndIf

cSerieNF := cSerie
cFirst 	 := cNumNota


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazenar no SL1 a referencia do contrato criado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SL1->(FieldPos("L1_FORCADA")) > 0 .AND. SL1->L1_FORCADA == Str(FORCADA,1) .AND. SL1->(FieldPos("L1_CONTRA")) > 0
	SL1->L1_CONTRA	:= cNumContra
EndIf

If ! lScreen
	ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0006+SL1->L1_NUM)	// "Filial " ### "." "Iniciando gravacao do orcamento: "
EndIf

//Se for venda de Vale Presente, nao deve gerar (SF2, SD2, SFT, SF3)
If lIsVendaVP
	Lj7VPVdaVP(1) //Seta para indicar que eh venda de Vale Presente. Eh setado aqui para que seja verificado na funcao A040DupRec (Fonte MATXATU)
Else
	Lj7VPVdaVP(2) //Seta para indicar que NAO eh venda de Vale Presente. Eh setado aqui para que seja verificado na funcao A040DupRec (Fonte MATXATU)
EndIf

//Se for venda de Recarga de Cartao Presente (Gift Card), nao deve gerar (SF2, SD2, SFT, SF3)
If lIsVdRecCP
	lFaturar := .F.
	Lj7CPSetSt(1,!lScreen) //Seta para indicar que eh venda de Recarga de Cartao Presente (Gift Card). Eh setado aqui para que seja verificado na funcao A040DupRec (Fonte MATXATU)
Else
	Lj7CPSetSt(2,!lScreen) //Seta para indicar que NAO eh venda de Recarga de Cartao Presente (Gift Card). Eh setado aqui para que seja verificado na funcao A040DupRec (Fonte MATXATU)
EndIf

If lFaturar

	If ! lImpCupfis

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava numero de nota e serie (obtido/escolhido) no SL1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_SERIE := cSerie
		SL1->L1_DOC   := cNumNota
	EndIf

	If Empty(SL1->L1_EMISNF)
		If cHoraRMT == "3" .AND. cPaisLoc == "BRA"
			aArea2	:= GetArea()
			dbSelectArea("SM0")
			aAreaSM0	:= GetArea()
			dbSetOrder(1)
			If dbSeek(cEmpAnt+cFilAnt)
				aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
			EndIf
			RestArea(aAreaSM0)
			RestArea(aArea2)

			SL1->L1_EMISNF := STOD(aTimeUf[1])
		Else
			SL1->L1_EMISNF := dDataBase
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³Identifica se sera gerado nota fiscal e se o numero de itens³
	//³na nota eh maior que o maximo configurado                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nCheck == 2 .AND. nNumItens > nMaxItens) .OR. !lScreen .Or. lBreakNFPS .OR. lBreakNFGar
		If SL1->L1_FRETE > 0 .OR. SL1->L1_DESPESA > 0 .OR. SL1->L1_SEGURO > 0
			nFrete 		:= SL1->L1_FRETE    	// Valor do Frete
			nDespesa    := SL1->L1_DESPESA   	// Valor das despesas
			nSeguro     := SL1->L1_SEGURO		// Valor do seguro
		EndIf
		If !lScreen
			nVlTotDesp := nFrete + nDespesa + nSeguro
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicia a Funcao Fiscal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaFisFound("NF")
			MaFisEnd()
		EndIf

		If !lImpCupfis
			lEmisNF := .T.
		EndIf

		If SL1->L1_TIPO $ "D|B"
			cTipoNF 	:= SL1->L1_TIPO
			cCliFor     := "F"
			cTpCliFor 	:= "R"
			
			DbSelectArea("SA2")
			SA2->(DbSetOrder(3))//A2_FILIAL+A2_CGC
			IF(SA2->(DbSeek(xFilial("SA2")+PADR(SA1->A1_CGC,TamSx3("A2_CGC")[1]))))
				cCodCliFor  := SA2->A2_COD
				cLoja		:= SA2->A2_LOJA	
			Endif
			
		Else
			cTpCliFor 	:= SL1->L1_TIPOCLI
			cCodCliFor  := SL1->L1_CLIENTE
			cLoja		:= SL1->L1_LOJA	
		EndIf 
				
		MaFisIni(	cCodCliFor		,   cLoja							,	cCliFor		,cTipoNF,;
   					cTpCliFor		,	IIF(lIntegDef, aRelImpInt, NIL)	,	NIL	,	.F.	,;  
   					"SB1"			,	"LJGRVBATCH"			        ,	NIL	,	NIL	,;
   					NIL				,	NIL							    ,	NIL	,	NIL	,;
   					NIL				,	NIL							    ,	lEmisNF	)		

		LjSatMxFis() //setando SAT na MatxFis

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Chile - Guia de Despacho - F2CHI            ³
	//³Quando for gerada Guia de Despacho parcial, ou seja ,	  ³
	//³no minimo um item com entrega do tipo 3, repososiciona na  ³
	//³SL1 no orcamento PAI, para obter todos os itens da venda   ³
	//³e inclui-los na factura									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCFolChiR5 .AND. (cTpGeraGdp $ GDP_PARCIAL)
		aAreaSL1 := SL1->(GetArea())
		DbSelectArea("SL1")
	    SL1->(DbSetOrder(1))
	    If !SL1->(DbSeek (xFilial("SL1") + cNumOrcPai))
			SL1->(RestArea())
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia gravacao do SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nIndnX:=1 to Len(aItensSL2) //Percorre itens do SL2 por tipos de itens separados (Itens de "Produto" e Itens de "Servico")

		//Verifica se quebra a SF2 gerando os demais itens de "servico" na proxima nota
		lQuebraNF := lMVLJPRDSV .And. Len(aItensSL2) > 1 .And. nIndnX > 1
		lIsNFServ := Len(aItensProd) == 0 .And. Len(aItensServ) > 0 //Verifica se eh NF de servico apenas (apenas com itens de "servicos")

		nNumItens := Len(aItensSL2[nIndnX])

		If lQuebraNF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena o numero da nota atual a ser fechada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumNFFech	:= cNumNota
			lIsNFServ   := .T.  //Indica que eh NF de "servico"

			LjGravaLog( lScreen, cNumOrc, '13.1) Antes da LjGrvSF2' + Chr(13) + Chr(10) + ;
                                          '	14.1) nItens = '         + AllTrim(STR(nItens))+ Chr(13) + Chr(10) + ;
                                          '	15.1) nMaxItens = '      + AllTrim(STR(nMaxItens)), LMALERT, LMTECH )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenche a nota atual e limpa os acumuladores para iniciar outra NF (SF2).   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjGrvSF2( .F.		,lImpCupFis		,@cNumNota	,cFirst	,;
			         aImpsSF2 	,nTotLiq		,nTotImp	,cSerie	,;
			         nTotDesc 	,@nBaseDup		,Nil		,Nil	,;
			         Nil		,Nil			,lScreen    ,aTotais,;
			         Nil		,Nil			,Nil		,Nil  	,;
			         .F. 		,lIsNFServ		,@cSerieNF 	, IIF(!(Alltrim(SF2->F2_ESPECIE) == "RPS"), .F., .T.) )

			LjGravaLog( lScreen, cNumOrc, '16.1) Depois da LjGrvSF2', LMALERT, LMTECH)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava numero de nota e serie de servico (RPS)    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIsNFServ .And. lTemItServ
				SL1->L1_DOCRPS := cNumNota
				SL1->L1_SERRPS := cSerieNF

				//Grava o campo F2_NUMORC,  com o numero do orcamento (L1_NUM). Este campo eh gravado somente se na venda existir itens de "serviço".
				RecLock( "SF2", .F. )
				SF2->F2_NUMORC := SL1->L1_NUM
				SF2->( MsUnlock() )
			EndIf
			
			//Integracao atualiza valor bases SF2
			If lIntegDef	
				SF2->F2_VALBRUT := SL1->L1_VALBRUT
			EndIf
			
			If nValIss == 0 .AND. nF2ValISS > 0
				If !lIntegDef //Integracao nao atualiza valores de ISS
					SL1->L1_VALISS	:= nF2ValISS 

					//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava o valor do ISS no SL1, atualiza o SF2 com o valor do ISS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock( "SF2", .F. )
					SF2->F2_BASEISS	:= nF2BaseISS 
					SF2->F2_VALISS	:= nF2ValISS
					SF2->( MsUnlock() )
				EndIf
				
				nF2ValISS	:= 0
				nF2BaseISS	:= 0
			EndIf
			
			If cPaisLoc == "BRA" .And. !lIntegDef //Integracao nao atualiza impostos
				nValIcm  += SF2->F2_VALICM
				nValIpi  += SF2->F2_VALIPI
				nValIss  += SF2->F2_VALISS
				nBrIcms  += SF2->F2_BRICMS
				nIcmsRet += SF2->F2_ICMSRET
				nValPIS  += SF2->F2_VALPIS
				nValCSLL += SF2->F2_VALCSLL
				nValCOFI += SF2->F2_VALCOFI
				nValINSS += SF2->F2_VALINSS
				nValIRRF += SF2->F2_VALIRRF
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o cabecalho da nova NF gerada  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjInclSF2(cNumNota, lImpCupFis, cSerie, cFirst, cSerieNF, lIsNFServ)

			//Reinicia variaveis
			nItens   := 0
			cItemNF  := "00"
			aImpsSF2 := {}
			aLivro   := {}
			nTotLiq  := 0
			nTotImp  := 0
			nTotDesc := 0
			nBasePS2 := 0
			nValPS2  := 0
			nBaseCF2 := 0
			nValCF2  := 0
			aTotais  := {0,0,0}
		EndIf

		If lLj7Arred
			Lj7Arred(1) // limpa array statico da função de arredondamento
		EndIf

		nCountIT :=  Len(aItensSL2[nIndnX])
		
		aArea := GetArea()

		//Integracao hotelaria lancamento PCO para SF2
		If lIntegHtl
			//Inicia PCO
			PcoIniLan(cProcesso)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a inclusao do cabec. da NF (SF2)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFtvdVer12
			LjInclSF2(cNumNota,	lImpCupFis, cSerie, cFirst, cSerieNF, lIsNFServ)
		ElseIf lFtvdVer12
			LjInclSF2(cNumNota,	lImpCupFis, cSerie, cFirst, cSerieNF)
		EndIf

		For nIndnY:=1 to Len(aItensSL2[nIndnX]) //Percorre item a item do SL2
			SL2->( dbGoTo(aItensSL2[nIndnX][nIndnY][2]) ) //Posiciona no SL2

			//Devido a emissao de NF-e no PDV devermos validar se o item nao foi cancelado no PDV
			if lNFePDV .and. SL2->L2_VENDIDO <> "S" 
				SL2->( DbSkip() )
				Loop			
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Chile - Guia de Despacho - F2CHI       ³
			//³Se estiver gravando incluido na factura item com tipo ³
			//³de entrega 3,incluir apenas os itens reservados       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCFolChiR5
				If (cTpGeraGdp $ GDP_TOTAL) .AND. !(SL1->L1_PEDRES==SL2->L2_PEDRES  .AND. !Empty(SL2->L2_PEDRES) .AND. SL2->L2_ENTREGA == "3" .AND. !Empty(SL2->L2_RESERVA))
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³GUIA DE DESPACHO PARCIAL/TOTAL - Nao incluir na factura os       ³
				//³itens de venda com entrega tipo 1 durante a gravacao do orcamento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTpGeraGdp $ GDP_TOTAL + ";"+ GDP_PARCIAL .AND. SL2->L2_ENTREGA == "1" .AND. nOpc == 3
					Loop
				EndIf
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura TES do item (para calculo de impostos)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + SL2->L2_TES))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no B1 Correspondente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(DbSetOrder(1))
			SB1->(DbSeek( xFilial("SB1") + SL2->L2_PRODUTO + SL2->L2_LOCAL ))

			SB0->(DbSetOrder(1))
			SB0->(DbSeek( xFilial("SB0") + SL2->L2_PRODUTO ))
			nItens ++
			cItemNF	:= SomaIt(cItemNF)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes				³
			//³Incluir nro e serie no array aBreakNota 	³
			//³para controle de quebra de factura		³
			//³Paises:Chile/Colombia - F1CHI/F2CHI		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		If lLocR5
	 			LjAddBrkNF (@aBreakNota	,@aItens	,SL2->L2_ENTREGA	,cNumNota,;
							cSerie		,cTpGeraGdp	,nOpc)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estourou o maximo de itens por nota!³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nItens > nMaxItens

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o numero da nota atual a ser fechada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumNFFech	:= cNumNota
				lIsNextNF 	:= nItens > nMaxItens

				LjGravaLog( lScreen, cNumOrc, '13) Antes da LjGrvSF2' + Chr(13) + Chr(10) + ;
	                                          '	14) nItens = '         + AllTrim(STR(nItens))+ Chr(13) + Chr(10) + ;
	                                          '	15) nMaxItens = '      + AllTrim(STR(nMaxItens)), LMALERT, LMTECH )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenche a nota atual e limpa os acumuladores para gerar a continuacao da nota.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjGrvSF2( .F.		,lImpCupFis		,@cNumNota	,cFirst	,;
				         aImpsSF2 	,nTotLiq		,nTotImp	,cSerie	,;
				         nTotDesc 	,@nBaseDup		,Nil		,Nil	,;
				         Nil		,Nil			,lScreen    ,aTotais,;
				         lRetIncSx5 ,Nil			,Nil		,Nil  	,;
				         lIsNextNF 	,lIsNFServ		,@cSerieNF  ,lIsNFServ )

				LjGravaLog( lScreen, cNumOrc, '16) Depois da LjGrvSF2', LMALERT, LMTECH)

				If lMVLJPRDSV .And. lTemItServ
					//Grava o campo F2_NUMORC,  com o numero do orcamento (L1_NUM). Este campo eh gravado somente se na venda existir itens de "serviço".
					SF2->F2_NUMORC := SL1->L1_NUM
				EndIf

				If nValIss == 0 .AND. nF2ValISS > 0
					If !lIntegDef //Integracao nao atualiza informacoes de ISS
						SL1->L1_VALISS	:= nF2ValISS
		
						//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava o valor do ISS no SL1, atualiza o SF2 com o valor do ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock( "SF2", .F. )
						SF2->F2_BASEISS	:= nF2BaseISS
						SF2->F2_VALISS	:= nF2ValISS
						SF2->( MsUnlock() )
					EndIf
					
					nF2ValISS	:= 0
					nF2BaseISS	:= 0
				EndIf

				If cPaisLoc == "BRA" .And. !lIntegDef //Integracao nao atualiza variaveis
					nValIcm  += SF2->F2_VALICM
					nValIpi  += SF2->F2_VALIPI
					nValIss  += SF2->F2_VALISS
					nBrIcms  += SF2->F2_BRICMS
					nIcmsRet += SF2->F2_ICMSRET
					nValPIS  += SF2->F2_VALPIS
					nValCSLL += SF2->F2_VALCSLL
					nValCOFI += SF2->F2_VALCOFI
					nValINSS += SF2->F2_VALINSS
					nValIRRF += SF2->F2_VALIRRF
				EndIf

				If !lImpCupFis

					If !(lMVLJPRDSV .And. lIsNFServ) //Se nao eh NF de "Servico"
						nNotaAtu++
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
						//³ cMV_TPNRNFS for igual a "3". Como ja' pegou o numero da nota no      ³
						//³ inicio da rotina, pega agora somente quando for outra NF (no caso da ³
						//³ quantidade de itens ser maior que a quantidade por nota.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cMV_TPNRNFS == "3" .And. Len(aNotas) < nNotaAtu
							aAdd( aNotas, { cSerie,  MA461NumNf( .T., cSerie ) } )
						EndIf
						cSerie	 := aNotas[nNotaAtu][1]
						cNumNota := aNotas[nNotaAtu][2]
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   				//³ Inicia variav. fiscais da prox. NF ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso gere uma nova Nota, reinicia o Array de Totais³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aTotais := {	0,;		//F2_VALMERC
									0,;		//F2_DESCONT
									0 }		//F2_VALACRS

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o F2_NEXTDOC para localizacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cPaisLoc <> "BRA"
						RecLock("SF2",.F.)
						SF2->F2_NEXTDOC	:= cNumNota
						SF2->(MsUnlock())
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Reinicia a Funcao Fiscal³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If MaFisFound("NF")
						MaFisEnd()
					EndIf
																			
					MaFisIni( SL1->L1_CLIENTE , SL1->L1_LOJA 						, "C"  , "S" , ;
							   SL1->L1_TIPOCLI , IIF(lIntegDef, aRelImpInt, NIL)	, NIL  , .F. , ; 
						   	   "SB1", "LJGRVBATCH" )
										
					LjSatMxFis() //setando SAT na MatxFis
						   	  
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava o cabecalho da nova NF gerada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjInclSF2(cNumNota,	lImpCupFis, cSerie, cFirst, cSerieNF, lIsNFServ)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Release 11.5 - Localizacoes				³
					//³Incluir nro e serie no array aBreakNota 	³
					//³para controle de quebra de factura		³
					//³Paises:Chile/Colombia - F1CHI/F2CHI		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 		If lLocR5
			 			LjAddBrkNF (@aBreakNota	,@aItens	,SL2->L2_ENTREGA	,cNumNota,;
									cSerie		,cTpGeraGdp	,nOpc)
					EndIf

				EndIf

				If cPaisLoc <> "BRA"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica a qtde de casas decimais da moeda do orcamento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDecimais := MsDecimais(SL1->L1_MOEDA)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza a gravacao do Livro Fiscal³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    If Len(aLivro) > 0

				    	aAreaSF2 := SF2->(GetArea())

				    	SF2->(DbSetOrder( 1 ))
						SF2->(DbSeek( xFilial( "SF2" )+ cNumNFFech + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ))

						//Nit e nome de terceiros - Bolivia
				    	If cPaisLoc == "BOL" .AND. SF3->(FieldPos("F3_NIT")) > 0 .AND. SF3->(FieldPos("F3_RAZSOC")) > 0

				    		//Grava o NIT de terceiro
				    		nPos := aScan(aLivro[1],"F3_NIT")
				    		If nPos == 0
				    			AAdd(aLivro[1],"F3_NIT")
				    			AAdd(aLivro[2],"")
				    			nPos := Len(aLivro[1])
				    		EndIf
				    		aLivro[2][nPos] := cCGCCli

				    		//Grava o nome de terceiro
				    		nPos := aScan(aLivro[1],"F3_RAZSOC")
				    		If nPos == 0
				    			AAdd(aLivro[1],"F3_RAZSOC")
				    			AAdd(aLivro[2],"")
				    			nPos := Len(aLivro[1])
				    		EndIf
				    		aLivro[2][nPos] := cNomeCli

				    	EndIf

						GravaLivro( @aLivro , SL1->L1_SERIE , cNumNFFech, cCGCCli )

						RestArea(aAreaSF2)

					EndIf

				EndIf

				If lFirst
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava no orcamento informacao de que foram geradas varias notas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SL1->L1_MULTNOT := "S"
					lFirst := .F.
				EndIf

				nItens   := 1
				cItemNF  := "01"
				aImpsSF2 := {}
				aLivro   := {}
				nTotLiq  := 0
				nTotImp  := 0
				nTotDesc := 0
				nBasePS2 := 0
				nValPS2  := 0
				nBaseCF2 := 0
				nValCF2  := 0
				aTotais  := {0,0,0}

			EndIf

			If lMVLJPRDSV
				RecLock("SL2",.F.)
				SL2->L2_DOC   	:= cNumNota
				SL2->L2_SERIE 	:= cSerieNF
				SL2->L2_ITEMNF 	:= cItemNF //Item da NF (o mesmo que sera gravado no D2_ITEM)
				SL2->(MsUnlock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Chile - Guia de Despacho - F2CHI      ³
				//³Se estiver gravando Factura de venda associada a uma ³
				//³guia de despacho parcial, nao atualizar os dados do  ³
				//³documento na SL2 pois a mesma esta posicionada       ³
				//³no orcamento pai.                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf !(lCFolChiR5 .AND. cTpGeraGdp == GDP_PARCIAL) .And. !lImpCupFis
					RecLock("SL2",.F.)
					SL2->L2_DOC   := SL1->L1_DOC
					SL2->L2_SERIE := SL1->L1_SERIE
					SL2->(MsUnlock())
			EndIf

		    cProxNum := Nil
		    nTentativas := 0

			While cProxNum == Nil .AND. nTentativas < 10
				cProxNum := ProxNum(.T.,.F.)

				If cProxNum == Nil
					Conout("GravaBatch - LjGrvTudo: ProxNum() Tentativa",nTentativas)
					Sleep(500)
				EndIf

				nTentativas++
			End

			If cProxNum == Nil
				Conout("GravaBatch - LjGrvTudo: Erro ProxNum()")
				FINAL("AJUSTAR PARAMETRO MV_DOCSEQ") //AJUSTAR PARAMETRO MV_DOCSEQ
			EndIf


	   		nVlrDescItem	+= SL2->L2_VALDESC // Esta variável será usada caso haja pagamento com NCC em localidade com troco para verificar se há desconto no item

			LjGravaLog( lScreen, cNumOrc, 'Antes do bloco  LJGRVAD2', LMALERT, LMTECH)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada antes da gravacao do SD2                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lFtvdVer12
				If lLJGRVAD2
					ExecBlock( "LJGRVAD2", .F., .F. )
				EndIf
			Else
				If lFTVDGRVAD2
					ExecBlock( "FTVDGRVAD2", .F., .F. )
				EndIf
			EndIf

			LjGravaLog( lScreen, cNumOrc, 'Depois do bloco  LJGRVAD2', LMALERT, LMTECH)

			If cPaisLoc == "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor da Mercadoria sem Desconto e sem Acrescimo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para indicar se o ECF faz o arredondamento (.T.) ou ³
				//³ truncamento (.F.) dos valores.                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFRTECF13
				    lStatusImp13 := ExecBlock("FRTECF13",.F.,.F.,{SL2->L2_PRODUTO,SL2->L2_VRUNIT, SL2->L2_QUANT})
					If lStatusImp13  // Se o ECF Nao Tem Arredondamento
						nValMerc	:= Round( SL2->L2_PRCTAB * SL2->L2_QUANT, nDcD2TOTAL)
					Else
						nValMerc	:= NoRound( SL2->L2_PRCTAB * SL2->L2_QUANT, nDcD2TOTAL)
					EndIf
				Else
					If lMvArrefat
						nValMerc := Round( SL2->L2_PRCTAB * SL2->L2_QUANT, nDcD2TOTAL)
					Else
						nValMerc := NoRound( SL2->L2_PRCTAB * SL2->L2_QUANT, nDcD2TOTAL)
					EndIf
				Endif

	           If lScreen .AND. !Empty(aVlrAcres)	            					
					nVlrAcrs := aVlrAcres[nIndnY]
					nVlrAcreFin += nVlrAcrs
				ElseIf lCalcFin
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valor do acrescimo calculado proporcional ao item ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aAcrFin) >= nItens
						nVlrAcrs := ((aAcrFin[nItens] + SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA) - SL2->L2_VALDESC - SL2->L2_DESCPRO)
					Else
						nVlrAcrs := 0
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valor do Acrescimo proporcional ao item, calculado a partir do percentual definido no campo L1_JUROS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLj7Arred
						If lCpoAcres
							nVlrAcrs := SL2->L2_VALACRS
						Else
							nVlrAcrs := Lj7Arred(2,3,((nValMerc + (SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA) - SL2->L2_VALDESC - SL2->L2_DESCPRO) * (SL1->L1_JUROS) /100))
						EndIf
					EndIf

				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valor do Desconto sobre o Item, descontado o Acrescimo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nVlrDesc := SL2->L2_DESCPRO + SL2->L2_VALDESC

				aTotais[__VALMERC] += nValMerc
				aTotais[__DESCONT] += nVlrDesc
				aTotais[__VALACRS] += nVlrAcrs
	        EndIf
			
			If !lMultNegoc
				If nCountIT = nItens // Indica que eh ultimo item , e realiza ajuste , caso o acrescimo no total seja
									 // diferente da soma dos acrescimo Rateado
							
					If lFRTECF13 .AND. !lStatusImp13 	// Verifica PE FRTECF13 e pega o Retorno
						nAcreTotBk := NoRound( ((SL1->L1_VALMERC - nVlrDescItem) * (SL1->L1_JUROS) /100), nDecimais)
					Else 						//L1_VALMERC nao considera o valor do desconto no item, calculando o juros errado
						nAcreTotBk := a410Arred( ((SL1->L1_VALMERC - nVlrDescItem) * (SL1->L1_JUROS) /100),"D2_VALACRS" )
					EndIf
	
					nDiffAc :=  nAcreTotBk - aTotais[__VALACRS]
					If Abs(nDiffAc) = (1/10**nDecDesc)  // 0.01
						nVlrAcrs := nVlrAcrs + nDiffAc
						aTotais[__VALACRS] += nDiffAc
					EndIf
				EndIf
			EndIf

	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica se sera gerado nota fiscal e se o numero de itens³
			//³na nota eh maior que o maximo configurado                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//Calcula Frete proporcional no Item						
			If Len(aItensSL2[nIndnX]) > 1
				nFreteProp	:= IIF(!lScreen .And. !lIntegDef, SL2->L2_VALFRE , LjxPropItem(nTotItens, nFrete  , lScreen))  	// Valor do frete do item
				nDespeProp	:= IIF(!lScreen .And. !lIntegDef, SL2->L2_DESPESA, LjxPropItem(nTotItens, nDespesa, lScreen))	// Valor da despesa do item							   
				nSegurProp	:= IIF(!lScreen .And. !lIntegDef, SL2->L2_SEGURO , LjxPropItem(nTotItens, nSeguro , lScreen))	// Valor do seguro do item								
			Else
				nFreteProp := nFrete
				nDespeProp := nDespesa
				nSegurProp := nSeguro
			EndIf

			If (nCheck == 2 .AND. nNumItens > nMaxItens) .OR. !lScreen .Or. lBreakNFPS .OR. lBreakNFGar

		 		nTotDescFrt := SL2->L2_VALDESC + SL2->L2_DESCPRO
				nVlrMerc	:= a410Arred((SL2->L2_PRCTAB * SL2->L2_QUANT),"D2_TOTAL") 	// Valor da mercadoria

				// Verifica PE FRTECF13 e pega o Retorno
				If lFRTECF13 .AND. !lStatusImp13
					nVlrMerc		:= noRound((SL2->L2_PRCTAB * SL2->L2_QUANT),nDecimais) 	// Valor da mercadoria
				EndIf

		   	   	MaFisAdd(	SL2->L2_PRODUTO,;							// Produto
							SL2->L2_TES,;								// Tes
							SL2->L2_QUANT,;								// Quantidade
							SL2->L2_VRUNIT,;							// Preco unitario
							nTotDescFrt   ,; 							// Valor do desconto
							"",;                                        // Numero da NF original
							"",;										// Serie da NF original
							Nil,;										// Recno da NF original
							nFreteProp,;							  	// Valor do frete do item
							nDespeProp,;								// Valor da despesa do item
							nSegurProp,;								// Valor do seguro do item
							0,;											// Valor do frete autonomo
							nVlrMerc,; 									// Valor da mercadoria
							0 )											// Valor da embalagem

				If lLjGrvSL2
			        ExecBlock( "LJGRVSL2", .F., .F., {nItens} )			// Ponto de Entrada para gravação de campos na Tabela SL2
	        	EndIf
				
				If nVlrAcrs > 0 .And. lAcrescBC
					MaFisAlt("IT_ACRESCI", nVlrAcrs, nItens)
				EndIf

			EndIf
			
			If lIntegDef
				//Zera os valores de impostos que podem influenciar no valor total (Essas referencias serao alimentadas logo adiante)
            	//Valores de IPI
                MaFisAlt("IT_BASEIPI", 0, nItens,,,, "LOJA701", .T.)
                MaFisAlt("IT_ALIQIPI", 0, nItens,,,, "LOJA701", .T.)
                MaFisAlt("IT_VALIPI" , 0, nItens,,,, "LOJA701", .T.)
                
                //Valores de ICMS Solidario (ICMS-ST)
                MaFisAlt("IT_BASESOL", 0, nItens,,,, "LOJA701", .T.)
                MaFisAlt("IT_ALIQSOL", 0, nItens,,,, "LOJA701", .T.)
                MaFisAlt("IT_VALSOL" , 0, nItens,,,, "LOJA701", .T.)
                
				MaFisAlt("IT_BASFECP", 0, nItens,,,, "LOJA701", .T.)
				MaFisAlt("IT_ALIQFECP",0, nItens,,,, "LOJA701", .T.)
				MaFisAlt("IT_VALFECP", 0, nItens,,,, "LOJA701", .T.)
				
				MaFisAlt("IT_BSFCPST", 0, nItens,,,, "LOJA701", .T.)
				MaFisAlt("IT_ALFCST",  0, nItens,,,, "LOJA701", .T.)
				MaFisAlt("IT_VFECPST", 0, nItens,,,, "LOJA701", .T.)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso habilitado , efetua o calculo do ICMS de acordo com o ECF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lIntegDef .And. lHabArred .And. lD2SITTRIB .And. Left(SL2->L2_SITTRIB,1) $ "T|S" .And. !lUseSAT //Situacao Tributaria (T=ICMS ou S=ISS)
	        	LjxConfIcm(	nItens 	,(SL2->L2_VLRITEM + SL2->L2_VALFRE),SL1->L1_EMISNF , SL1->L1_PDV ,;
		       				SL2->L2_PRODUTO , lStatusImp13 )
	        EndIf

	        If !lScreen .Or. ( MaFisFound("IT",nItens) .And. Empty(MaFisRet(nItens, "IT_CODISS")) )
		        cCodIss := Alltrim(MaSBCampo("CODISS"))
				If !Empty(cCodIss)
		 			MaFisAlt("IT_CODISS", cCodIss, nItens)
		    	EndIf
	    	EndIf

			// Verifica se a aliq q foi vendida no PDV eh a msma da calculada na retaguarda
	    	// caso contrario altera, pois nao posso vender no PDV a uma aliq e depois gerar o livro com outra
	    	If !lScreen .AND. SubStr(SL2->L2_SITTRIB,1,1)=="T" .AND. SB0->B0_ALIQRED == 0 .And. SF4->F4_BASEICM == 0 
	    		cSitTrib := SL2->L2_SITTRIB
		        If Len(cSitTrib) > 4
		        	nAliqTrib := Val(SubStr(cSitTrib,2,2)+"."+SubStr(cSitTrib,4,Len(cSitTrib)))
				Else
					nAliqTrib := Val(SubStr(cSitTrib,2,Len(cSitTrib)))
				EndIf
	    		
	    		If nAliqTrib <> MaFisRet(nItens, "IT_ALIQICM") 
	    			MaFisAlt("IT_ALIQICM", nAliqTrib, nItens)
	    		EndIf	
	    	EndIf


	        If lLjGrvFisc      // Ponto de entrada sem parametros e chamado apos a inclusao fiscal do item pela rotina de gravacao da Nota
		        ExecBlock( "LJGRVFISC", .F., .F. )
        	EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravacao do SD2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock( "SD2",.T.)
			REPLACE SD2->D2_FILIAL		WITH xFilial("SD2")
			REPLACE SD2->D2_COD	        WITH SL2->L2_PRODUTO
			REPLACE SD2->D2_UM			WITH SL2->L2_UM

			If lD2ItemGar
			   	REPLACE SD2->D2_ITEMGAR	WITH SL2->L2_ITEMGAR
			EndIf

			If lD2OrcGar .AND. lD2ItemGar .AND. !Empty(SL2->L2_ITEMGAR)
			   	REPLACE SD2->D2_ORCGAR	WITH SL2->L2_NUM
			EndIf

			If lL2_SEGUM
				REPLACE SD2->D2_SEGUM		WITH SL2->L2_SEGUM
			EndIf

			REPLACE SD2->D2_QUANT		WITH SL2->L2_QUANT
			If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
				REPLACE SD2->D2_PRCVEN		WITH xMoeda(SL2->L2_VRUNIT,nMoedaCor,1,SL2->L2_EMISSAO)
				REPLACE SD2->D2_TOTAL		WITH xMoeda(SL2->L2_VLRITEM,nMoedaCor,1,SL2->L2_EMISSAO)
				REPLACE SD2->D2_PRUNIT		WITH xMoeda(SL2->L2_PRCTAB,nMoedaCor,1,SL2->L2_EMISSAO)
			Else
				REPLACE SD2->D2_PRCVEN		WITH SL2->L2_VRUNIT
				REPLACE SD2->D2_TOTAL		WITH SL2->L2_VLRITEM
				REPLACE SD2->D2_PRUNIT		WITH SL2->L2_PRCTAB
			EndIf
			REPLACE SD2->D2_TES			WITH SL2->L2_TES
			
			//Integracao mantem Cfop informado na integracao
			If lIntegDef
				MaFisAlt("IT_CF", SL2->L2_CF, nItens,,,, "LOJA701", .T.)  
			Else
				REPLACE SD2->D2_CF WITH SL2->L2_CF
			EndIf
			
			If SL1->L1_TIPO $ "D|B" 
				aRetfor := LjRetfor(SL1->L1_CLIENTE,SL1->L1_LOJA)
				
				REPLACE SD2->D2_CLIENTE		WITH aRetfor[1]
				REPLACE SD2->D2_LOJA  		WITH aRetfor[2]
			Else
				REPLACE SD2->D2_CLIENTE		WITH SL1->L1_CLIENTE
				REPLACE SD2->D2_LOJA  		WITH SL1->L1_LOJA
			Endif

			REPLACE SD2->D2_TIPO		WITH SL1->L1_TIPO	
			REPLACE SD2->D2_DOC			WITH cNumNota
			REPLACE SD2->D2_PDV			WITH SL1->L1_PDV
			REPLACE SD2->D2_CCUSTO		WITH SB1->B1_CC
			If !lFtvdVer12
				REPLACE SD2->D2_ORIGLAN		WITH "LO"
			ElseIf lFtvdVer12
				REPLACE SD2->D2_ORIGLAN		WITH "VD"
			EndIf
			REPLACE SD2->D2_EMISSAO		WITH SL1->L1_EMISNF
			REPLACE SD2->D2_GRUPO		WITH SB1->B1_GRUPO
			REPLACE SD2->D2_PESO		WITH SB1->B1_PESO

			If cPaisLoc == "ARG"	
				REPLACE SD2->D2_PROVENT WITH SL2->L2_PROVENT
			Endif
			// Limpa a variavel pois esta dentro de um laço
			cCtaCont := ""

			If lCpBzConta
				cCtaCont := RetFldProd(SB1->B1_COD, "B1_CONTA", "SB1")
			EndIf	

			If Empty(cCtaCont)
				cCtaCont := SB1->B1_CONTA
			EndIf

			REPLACE SD2->D2_CONTA		WITH cCtaCont

			If SD2->(FieldPos("D2_TNATREC")) > 0 .And. SB1->(FieldPos("B1_TNATREC")) > 0
				REPLACE SD2->D2_TNATREC		WITH SB1->B1_TNATREC
			EndIf

			If SD2->(FieldPos("D2_CNATREC")) > 0 .And. SB1->(FieldPos("B1_CNATREC")) > 0
				REPLACE SD2->D2_CNATREC		WITH SB1->B1_CNATREC
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Chile - Guia de Despacho - F2CHI       ³
			//³Gravar o valor de D2_SERIE a partir da variavel cSerie³
			//³ja que o SL1 esta posicionado no orcamento pai,que nao³
			//³tem L1_SERIE preenchido 								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCFolChiR5 .AND. cTpGeraGdp == GDP_PARCIAL
				SerieNfId("SD2",1,"D2_SERIE",,,,cSerie)
			Else
				SerieNfId("SD2",1,"D2_SERIE",,,,cSerieNF)
			EndIf

		    If lTPLOtica //Template de Otica
				REPLACE SD2->D2_CODGENE		WITH SL2->L2_CODGENE
				REPLACE SD2->D2_RECEITA		WITH SL2->L2_RECEITA
			EndIf
			If cPaisLoc == "BRA"
				If cLQFrete == "2" .AND. !lFtvdVer12
					nVAlFSD := (SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA)
				EndIf
				If cLQFrete == "1" .AND. lFtvdVer12
					nVAlFSD := (SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA)
				EndIf

				If lMvArrefat
					REPLACE SD2->D2_VALACRS	WITH Round(nVlrAcrs + nVAlFSD, nDecimais)
				Else
					REPLACE SD2->D2_VALACRS	WITH NoRound(nVlrAcrs + nVAlFSD, nDecimais)
				EndIf
	        Else
				If lLocR5
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Release 11.5 - Localizacoes³
					//³Totalizar impostos do item ³
					//³Paises: Chile/Colombia     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        	nTotImpIt	:= 0
					aTesImpInf  := TesImpInf(SL2->L2_TES)
				   	For nX := 1 to Len(aTesImpInf)
				    	If aTesImpInf[nX][3] == "1"  //Incide na NF
				     		nTotImpIt  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))
				      	EndIf
				   	Next nX
				EndIf

	  			If lMvArrefat
					If lLocR5
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Localizacoes                              ³
						//³No Chile o valor do acrescimo/juros eh calculado sobre o ³
						//³valor bruto do item (considerando impostos).             ³
						//³Paises:CHILE, COLOMBIA - F1CHI                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						REPLACE SD2->D2_VALACRS	WITH Round(((SL2->L2_QUANT * SL2->L2_PRCTAB-(SL2->L2_DESCPRO+SL2->L2_VALDESC)+nTotImpIt) * SL1->L1_JUROS)/100,nDecimais)
					Else
						REPLACE SD2->D2_VALACRS	WITH Round(((SL2->L2_QUANT * SL2->L2_PRCTAB-(SL2->L2_DESCPRO+SL2->L2_VALDESC)) * SL1->L1_JUROS)/100,nDecimais)
					Endif
				Else
					If lLocR5
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Localizacoes                              ³
						//³No Chile o valor do acrescimo/juros eh calculado sobre o ³
						//³valor bruto do item (considerando impostos).             ³
						//³Paises:CHILE, COLOMBIA - F1CHI                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						REPLACE SD2->D2_VALACRS	WITH NoRound(((SL2->L2_QUANT * SL2->L2_PRCTAB-(SL2->L2_DESCPRO+SL2->L2_VALDESC)+nTotImpIt) * SL1->L1_JUROS)/100,nDecimais)
					Else
						REPLACE SD2->D2_VALACRS	WITH NoRound(((SL2->L2_QUANT * SL2->L2_PRCTAB-(SL2->L2_DESCPRO+SL2->L2_VALDESC)) * SL1->L1_JUROS)/100,nDecimais)
					EndIf
				EndIf
	    	EndIf

			If MaFisRet(,"NF_SUFRAMA")
	        	REPLACE SD2->D2_DESCZFR	WITH MaFisRet(nItens,"IT_DESCZF")
	        EndIf

			If lFtvdVer12
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desconta o Valor do ICMS DESONERADO do valor do Item D2_PRCVEN         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_AGREG$"R"
					SD2->D2_TOTAL  -= MaFisRet(nItens,"IT_DEDICM")
					SD2->D2_PRCVEN := A410Arred(SD2->D2_TOTAL/IIf(SD2->D2_QUANT==0,1,SD2->D2_QUANT),"D2_PRCVEN")
					nDedICM += MaFisRet(nItens,'IT_DEDICM')
				EndIf
			EndIf

			REPLACE SD2->D2_LOCAL	WITH SL2->L2_LOCAL
			REPLACE SD2->D2_TIPO	WITH IIF(SL1->L1_TIPO $ "D|B",SL1->L1_TIPO,"N")
			REPLACE SD2->D2_ITEM	WITH cItemNF
			REPLACE SD2->D2_ITEMPV	WITH SL2->L2_ITEM
			REPLACE SD2->D2_TP		WITH SB1->B1_TIPO
			REPLACE SD2->D2_NUMSEQ	WITH cProxNum
			REPLACE SD2->D2_EST		WITH IIf(MaFisFound("NF"), MaFisRet(,"NF_UFDEST"),SA1->A1_EST)
			If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
				REPLACE SD2->D2_DESCON	WITH xMoeda(SL2->L2_VALDESC,nMoedaCor,1,SL2->L2_EMISSAO)
			Else
				REPLACE SD2->D2_DESCON	WITH SL2->L2_VALDESC
			EndIf
			REPLACE SD2->D2_DESC	WITH SL2->L2_DESC
			REPLACE SD2->D2_QTSEGUM WITH ConvUm(SL2->L2_PRODUTO,SL2->L2_QUANT,0,2)

			If SLR->(FieldPos("LR_CLASFIS")) > 0 .And. SL2->(FieldPos("L2_CLASFIS")) > 0 .And. !Empty(SL2->L2_CLASFIS)
				cClasFis := SL2->L2_CLASFIS
			Else
				cClasFis := Lj7RetClasFis(/*cProd*/, /*cTes*/, /*cNumLote*/, /*cLoteCtl*/,/*nItens*/nItens, lScreen)
			EndIf

			REPLACE SD2->D2_CLASFIS	WITH cClasFis

			If cPaisLoc == "BRA"

				If lFtvdVer12
					SFC->( DbSetOrder( 1 ) )
					If SFC->( DbSeek( xFilial( "SFC" ) + SD2->D2_TES ) )
						For nW:= 1 to 9
							cBasImp:= "D2_BASIMP"+Str(nW,1)
							cAlqImp:= "D2_ALQIMP"+Str(nW,1)
							cValImp:= "D2_VALIMP"+Str(nW,1)
							If nW <= 6
								REPLACE &cBasImp	WITH MaFisRet(nItens,"IT_BASEIV"+Str(nW,1))
								REPLACE &cAlqImp	WITH MaFisRet(nItens,"IT_ALIQIV"+Str(nW,1))
								REPLACE &cValImp	WITH MaFisRet(nItens,"IT_VALIV"+Str(nW,1))
							Else
								If FieldPos(cBasImp)>0 .AND. FieldPos(cAlqImp)>0 .AND. FieldPos(cValImp)>0
									REPLACE &cBasImp	WITH MaFisRet(nItens,"IT_BASEIV"+Str(nW,1))
									REPLACE &cAlqImp	WITH MaFisRet(nItens,"IT_ALIQIV"+Str(nW,1))
									REPLACE &cValImp	WITH MaFisRet(nItens,"IT_VALIV"+Str(nW,1))
								EndIf
							EndIf
						Next nW
					EndIf
				EndIf

                If lIntegDef
                	nBaseISS := SL2->L2_BASEISS
                	
                	//Valores de IPI
                    MaFisAlt("IT_BASEIPI", If(lL2BASEIPI,SL2->L2_BASEIPI,0), nItens,,,, "LOJA701", .F.)
                    MaFisAlt("IT_ALIQIPI", If(lL2IPI,SL2->L2_IPI,0), nItens,,,, "LOJA701", .F.)
                    MaFisAlt("IT_VALIPI" , SL2->L2_VALIPI , nItens,,,, "LOJA701", .F.)
                    MaFisAlt("IT_CLASFIS" , SL2->L2_CLASFIS , nItens,,,, "LOJA701", .F.) //Utilizar os dados da L2 quando for integração
                    //Utilizar os dados da L2 quando for integração
                    MaFisLoad("LF_CLASFIS","024", nItens)
                    //MaFisAlt Não funciona para alterar FT_CLASFIS então mudei para MaFisLoad  
                    MaFisAlt("IT_BASESOL", SL2->L2_BRICMS, nItens,,,, "LOJA701", .F.)
                    MaFisAlt("IT_ALIQSOL", If(lL2ALIQSOL,SL2->L2_ALIQSOL,0), nItens,,,, "LOJA701", .F.)
                    MaFisAlt("IT_VALSOL" , SL2->L2_ICMSRET , nItens,,,, "LOJA701", .F.)
				Else
					nBaseISS := MaFisRet(nItens,"IT_BASEISS")
					
    				REPLACE SD2->D2_IPI		WITH MaFisRet(nItens,"IT_ALIQIPI") 
    				REPLACE SD2->D2_VALIPI	WITH MaFisRet(nItens,"IT_VALIPI")
    				REPLACE SD2->D2_BASEIPI	WITH MaFisRet(nItens,"IT_BASEIPI")
    			EndIf
				REPLACE SD2->D2_VALFRE 	With MaFisRet(nItens,"IT_FRETE")
				REPLACE SD2->D2_SEGURO 	With MaFisRet(nItens,"IT_SEGURO")
				REPLACE SD2->D2_DESPESA	With MaFisRet(nItens,"IT_DESPESA")
								
				If nBaseISS > 0 .Or. (lIntegDef .And. AllTrim(SL1->L1_ESPECIE) == "RPS")
					REPLACE SD2->D2_CODISS	WITH Alltrim(MaSBCampo("CODISS"))
										
					//Integracao mantem o valor do ISS do item
					If lIntegDef																																				
						MaFisAlt("IT_VALISS" , SL2->L2_VALISS , nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASEISS", SL2->L2_BASEISS, nItens,,,, "LOJA701", .T.)						
						MaFisAlt("IT_ALIQISS", SL2->L2_ALIQISS, nItens,,,, "LOJA701", .F.)						
																																														
						nF2BaseISS += SL2->L2_BASEISS							
					Else																								
						REPLACE SD2->D2_ALIQISS	WITH MaFisRet(nItens,"IT_ALIQISS")
						REPLACE SD2->D2_BASEISS	WITH nBaseISS
						REPLACE SD2->D2_VALISS	WITH MaFisRet(nItens,"IT_VALISS")
					EndIf	
				Else
					//Integracao mantem o valor de ICMS do item
					If lIntegDef						
						MaFisAlt("IT_VALICM" , SL2->L2_VALICM	, nItens,,,, "LOJA701", .F.)
						
						If SL2->(ColumnPos("L2_PREDIC")) > 0
							If SL2->L2_PREDIC > 0 //Verifica se Reducao de Base informada na integracao														
								If SF4->F4_LFICM $ "I|O" //Verifica se Tes Isento ou Outros, demais configuracoes nao necessita de tratamento
									aTesInteg := MaFisRet(nItens, "IT_TS") //Recupera array com informacoes Tes da Matxfis
									
									If Len(aTesInteg) > 0 .And. ValType(aTesInteg[__PREDIC]) == "N"
										aTesInteg[__PREDIC] := SL2->L2_PREDIC //Altera Base de ICMS no array MatxFis
									EndIf																																	
								EndIf
							EndIf
							MaFisAlt("IT_PREDIC", SL2->L2_PREDIC, nItens,,,, "LOJA701", .F.)
						EndIf
						
						MaFisAlt("IT_BASEICM", SL2->L2_BASEICM	, nItens,,,, "LOJA701", .F.)												
						MaFisAlt("IT_ALIQICM", SL2->L2_PICM	, nItens,,,, "LOJA701", .F.)																																															
					Else																		
						REPLACE SD2->D2_BASEICM	WITH MaFisRet(nItens,"IT_BASEICM")
						REPLACE SD2->D2_VALICM	WITH MaFisRet(nItens,"IT_VALICM")						
					EndIf	
				EndIf
				If SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100 .AND. SB0->B0_ALIQRED > 0 .AND. lImpCupFis .AND. cMvMapaRes == "N"
	   				REPLACE SD2->D2_PICM	WITH SB0->B0_ALIQRED
	   				REPLACE SD2->D2_BASEICM	WITH MaFisRet(nItens,"IT_TOTAL")
	   				nBaseRed    += SD2->D2_BASEICM
				Else
					If !lIntegDef //Integracao mantem os impostos enviados
		   				REPLACE SD2->D2_PICM	WITH MaFisRet(nItens,"IT_ALIQICM")
		   				REPLACE SD2->D2_BASEICM	WITH MaFisRet(nItens,"IT_BASEICM")		   		
		   			EndIf	   				
				EndIf
				REPLACE SD2->D2_BRICMS	WITH MaFisRet(nItens,"IT_BASESOL")
				REPLACE SD2->D2_ALIQSOL	WITH MaFisRet(nItens,"IT_ALIQSOL")
				REPLACE SD2->D2_ICMSRET	WITH MaFisRet(nItens,"IT_VALSOL")
				If lD2DESCICM
				   REPLACE SD2->D2_DESCICM	WITH MaFisRet(nItens,"IT_DEDICM")
				EndIf
				If lD2CFPS
				   REPLACE SD2->D2_CFPS	WITH MaFisRet(nItens,"IT_CFPS")
				EndIf
				If lD2SITTRIB
					REPLACE SD2->D2_SITTRIB	WITH SL2->L2_SITTRIB
				Endif
				
				//Grava os campos de Base, Aliquota e Valor de (PIS, COFINS, CSLL, IRRF, INSS
				If lIntegDef //Integracao Mensagem Unica mantem valor do Pis e Cofins do item					
					//Zera impostos que nao serao utilizados

					//FECP
					If lL2FECP .And. lD2FECP .And. lL2BASFECP .AND. lD2BASFECP
						If SL2->L2_BASFECP > 0

							MaFisAlt("IT_ALIQFECP"	, SL2->L2_ALQFECP, nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_BASFECP"	, SL2->L2_BASFECP, nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_VALFECP" 	, SL2->L2_VALFECP , nItens,,,, "LOJA701", .T.)

                            MaFisLoad("LF_BASFECP", SL2->L2_BASFECP , nItens)
							MaFisLoad("LF_VALFECP", SL2->L2_VALFECP , nItens)
			
						EndIf
					EndIf

					//FECP_ST
					If lL2FECPST .And. lD2FECPST .And. lL2STBASFECP .And. lD2STBASFECP
						If SL2->L2_BSFCPST > 0
							//Se for fecp ST altera o Icm antes de gravar os campos para evitar que seja zerado apos alteracao.
							MaFisLoad("NF_VALICM", SL1->L1_VALICM)

							MaFisLoad("LF_BSFCPST", SL2->L2_BSFCPST , nItens)
							MaFisLoad("LF_VFECPST", SL2->L2_VFECPST , nItens)

							MaFisAlt("IT_ALFCST"	, SL2->L2_ALQFCST , nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_BSFCPST"	, SL2->L2_BSFCPST , nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_VFECPST" 	, SL2->L2_VFECPST , nItens,,,, "LOJA701", .F.)

						EndIf
					EndIf

					//PIS Apuracao																	
					If SL2->L2_BASEPS2 <= 0 
						MaFisAlt("IT_VALPS2" , 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_ALIQPS2", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASEPS2", 0, nItens,,,, "LOJA701", .T.)																	
					EndIf
					
					//PIS Retencao
					If SL2->L2_BASEPIS <= 0  
						MaFisAlt("IT_VALPIS" , 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_ALIQPIS", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASEPIS", 0, nItens,,,, "LOJA701", .T.)																
					EndIf	
					
					//COFINS Apuracao															
					If SL2->L2_BASECF2 <= 0  
						MaFisAlt("IT_VALCF2" , 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_ALIQCF2", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASECF2", 0, nItens,,,, "LOJA701", .T.)								
					EndIf
					
					//COFINS Retencao															
					If SL2->L2_BASECOF <= 0  
						MaFisAlt("IT_VALCOF" , 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_ALIQCOF", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASECOF", 0, nItens,,,, "LOJA701", .T.)														
					EndIf
					
					//CSLL 											 
					If SL2->L2_BASCSLL <= 0
						MaFisAlt("IT_VALCSL" , 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_BASECSL", 0, nItens,,,, "LOJA701", .T.) 
						MaFisAlt("IT_ALIQCSL", 0, nItens,,,, "LOJA701", .T.) 								
					EndIf							
					
					//IRRF
					If 	SL2->L2_BASIRRF <= 0				
						MaFisAlt("IT_BASEIRR", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_ALIQIRR", 0, nItens,,,, "LOJA701", .T.)
						MaFisAlt("IT_VALIRR" , 0, nItens,,,, "LOJA701", .T.)							
					EndIf		
					
					//Armazena informacoes dos impostos que serao calculados
					
					//PIS Apuracao														
					If SL2->L2_BASEPS2 > 0 
						MaFisAlt("IT_VALPS2" , SL2->L2_VALPS2 , nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_ALIQPS2", SL2->L2_ALIQPS2, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_BASEPS2", SL2->L2_BASEPS2, nItens,,,, "LOJA701", .F.)	
						
						nBasePisApu += SL2->L2_BASEPS2
						nValPisApu  += SL2->L2_VALPS2					
					EndIf
					
					//PIS Retencao
					If SL2->L2_BASEPIS > 0  
						MaFisAlt("IT_VALPIS" , SL2->L2_VALPIS , nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_ALIQPIS", SL2->L2_ALIQPIS, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_BASEPIS", SL2->L2_BASEPIS, nItens,,,, "LOJA701", .F.)	
											
						nBasePIS += SL2->L2_BASEPIS	//Base de calculo do PIS
						nValPIS  += SL2->L2_VALPIS //Valor do PIS					
					EndIf				 
					
					//COFINS Apuracao															
					If SL2->L2_BASECF2 > 0  
						MaFisAlt("IT_VALCF2" , SL2->L2_VALCF2 , nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_ALIQCF2", SL2->L2_ALIQCF2, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_BASECF2", SL2->L2_BASECF2, nItens,,,, "LOJA701", .F.)																
					EndIf
					
					//COFINS Retencao															
					If SL2->L2_BASECOF > 0  
						MaFisAlt("IT_VALCOF" , SL2->L2_VALCOFI, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_ALIQCOF", SL2->L2_ALIQCOF, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_BASECOF", SL2->L2_BASECOF, nItens,,,, "LOJA701", .F.)	
											
						nBaseCOFI += SL2->L2_BASECOF //Base de calculo do COFINS
						nValCOFI  += SL2->L2_VALCOFI //Valor COFINS					
					EndIf
					 																																																																																																															
					//CSLL 											 
					If SL2->L2_BASCSLL > 0
						MaFisAlt("IT_VALCSL" , SL2->L2_VALCSLL, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_BASECSL", SL2->L2_BASCSLL, nItens,,,, "LOJA701", .F.) 
						MaFisAlt("IT_ALIQCSL", SL2->L2_ALQCSLL, nItens,,,, "LOJA701", .F.) 
						nBaseCSLL += SL2->L2_BASCSLL //Base de calculo do CSLL	
						nValCSLL  += SL2->L2_VALCSLL //Valor CSLL		
					EndIf							
					
					//IRRF
					If 	SL2->L2_BASIRRF > 0				
						MaFisAlt("IT_BASEIRR", SL2->L2_BASIRRF, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_ALIQIRR", SL2->L2_ALQIRRF, nItens,,,, "LOJA701", .F.)
						MaFisAlt("IT_VALIRR" , SL2->L2_VALIRRF, nItens,,,, "LOJA701", .F.)	
						nBaseIRRF += SL2->L2_BASIRRF //Base de calculo do IRRF
						nValIRRF  += SL2->L2_VALIRRF //Valor IRRF	
					EndIf	
					
					
					//FECP							
					If lL2FECP .And. lD2FECP .And. lL2BASFECP .AND. lD2BASFECP											
						If SL2->L2_BASFECP > 0 

							MaFisAlt("IT_ALIQFECP"	, SL2->L2_ALQFECP, nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_BASFECP"	, SL2->L2_BASFECP, nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_VALFECP" 	, SL2->L2_VALFECP , nItens,,,, "LOJA701", .F.)

                            MaFisLoad("LF_BASFECP", SL2->L2_BASFECP , nItens)
							MaFisLoad("LF_VALFECP", SL2->L2_VALFECP , nItens)
						EndIf
					EndIf	
					
					//FECP_ST
					If lL2FECPST .And. lD2FECPST .And. lL2STBASFECP .And. lD2STBASFECP 											
						If SL2->L2_BSFCPST > 0 
							//Se for fecp ST altera o Icm antes de gravar os campos para evitar que seja zerado apos alteracao.
							MaFisLoad("NF_VALICM", SL1->L1_VALICM)
							
							MaFisLoad("LF_BSFCPST", SL2->L2_BSFCPST , nItens)
							MaFisLoad("LF_VFECPST", SL2->L2_VFECPST , nItens)

							MaFisAlt("IT_ALFCST"	, SL2->L2_ALQFCST , nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_BSFCPST"	, SL2->L2_BSFCPST , nItens,,,, "LOJA701", .F.)
							MaFisAlt("IT_VFECPST" 	, SL2->L2_VFECPST , nItens,,,, "LOJA701", .F.)
						Else
							MaFisAlt("IT_ALFCST"	, 0, nItens,,,, "LOJA701", .T.)
							MaFisAlt("IT_BSFCPST"	, 0, nItens,,,, "LOJA701", .T.)
							MaFisAlt("IT_VFECPST" 	, 0, nItens,,,, "LOJA701", .T.)													
						EndIf
					EndIf	
					If SL2->(ColumnPos("L2_CSTCOF")) > 0 .AND. SL2->(ColumnPos("L2_CSTPIS")) > 0  	  	
						MaFisLoad("LF_CSTCOF", SL2->L2_CSTCOF , nItens)
						MaFisLoad("LF_CSTPIS", SL2->L2_CSTPIS , nItens)
					EndIf																																							   										
				
				Else
					// PIS
					REPLACE D2_BASEPIS	WITH MaFisRet(nItens,"IT_BASEPIS")
					REPLACE D2_ALQPIS 	WITH MaFisRet(nItens,"IT_ALIQPIS")
					REPLACE D2_VALPIS 	WITH MaFisRet(nItens,"IT_VALPIS")
					nBasePIS += MaFisRet(nItens,"IT_BASEPIS")	//Base de calculo do PIS
				
					// COFINS
					REPLACE D2_BASECOF	WITH MaFisRet(nItens,"IT_BASECOF")
					REPLACE D2_ALQCOF 	WITH MaFisRet(nItens,"IT_ALIQCOF")
					REPLACE D2_VALCOF 	WITH MaFisRet(nItens,"IT_VALCOF")
					nBaseCOFI += MaFisRet(nItens,"IT_BASECOF")	//Base de calculo do COFINS
					
					// CSLL
					REPLACE D2_VALCSL 	WITH MaFisRet(nItens,"IT_VALCSL")
					REPLACE D2_BASECSL	WITH MaFisRet(nItens,"IT_BASECSL")
					REPLACE D2_ALQCSL 	WITH MaFisRet(nItens,"IT_ALIQCSL")
					nBaseCSLL += MaFisRet(nItens,"IT_BASECSL")	//Base de calculo do CSLL
					
					// IRRF
					REPLACE D2_BASEIRR	WITH MaFisRet(nItens,"IT_BASEIRR")
					REPLACE D2_ALQIRRF	WITH MaFisRet(nItens,"IT_ALIQIRR")
					REPLACE D2_VALIRRF	WITH MaFisRet(nItens,"IT_VALIRR")
					nBaseIRRF += MaFisRet(nItens,"IT_BASEIRR")	//Base de calculo do IRRF
					
					If lD2FECP //Atualiza campos do imposto FECP
						REPLACE SD2->D2_VALFECP WITH MaFisRet(nItens,"IT_VALFECP")
			   			REPLACE SD2->D2_ALQFECP	WITH MaFisRet(nItens,"IT_ALIQFECP")					
					EndIf
					If lD2BASFECP //Atualiza base do imposto FECP
						REPLACE SD2->D2_BASFECP WITH MaFisRet(nItens,"IT_BASFECP")					
					EndIf
					
					If lD2FECPST //Atualiza campos do imposto FECP-ST
						REPLACE SD2->D2_VFECPST WITH MaFisRet(nItens,"IT_VFECPST")
			   			REPLACE SD2->D2_ALFCPST	WITH MaFisRet(nItens,"IT_ALFCST")					
					EndIf
					If lD2STBASFECP //Atualiza base do imposto FECP-ST
						REPLACE SD2->D2_BSFCPST WITH MaFisRet(nItens,"IT_BSFCPST")					
					EndIf
				EndIf																																										
								
				// INSS
				REPLACE D2_BASEINS	WITH MaFisRet(nItens,"IT_BASEINS")
				REPLACE D2_ALIQINS	WITH MaFisRet(nItens,"IT_ALIQINS")
				REPLACE D2_VALINS 	WITH MaFisRet(nItens,"IT_VALINS")																
				nBaseINSS += MaFisRet(nItens,"IT_BASEINS")	//Base de calculo do INSS

				//Valores relacionados ao FUNRURAL
				REPLACE SD2->D2_BASEFUN	WITH MaFisRet(nItens,"IT_BASEFUN")	// Base de Calculo do FUNRURAL
				REPLACE SD2->D2_ALIQFUN	WITH MaFisRet(nItens,"IT_PERFUN") 	// Aliquota do FUNRURAL
				REPLACE SD2->D2_VALFUN	WITH MaFisRet(nItens,"IT_FUNRURAL")	// Valor do FUNRURAL
				REPLACE SD2->D2_BSSENAR	WITH MaFisRet(nItens,"IT_BSSENAR") 	// Base de Calculo do SENAR
				REPLACE SD2->D2_ALSENAR	WITH MaFisRet(nItens,"IT_ALSENAR")	// Aliquota do SENAR
				REPLACE SD2->D2_VLSENAR	WITH MaFisRet(nItens,"IT_VLSENAR") 	// Valor do SENAR
				nVFunrural += MaFisRet(nItens,"IT_FUNRURAL")				// Valor do FUNRURAL

				If SF4->F4_ISS == 'S' .AND. SF4->F4_LFISS == "T"
					If lIntegDef //Integracao mantem Aliquota ISS do item						
						nAliqISS := SL2->L2_ALIQISS
						
						MaFisAlt("IT_ALIQISS" , SL2->L2_ALIQISS, nItens,,,, "LOJA701", .F.)											
					Else
						If SB1->B1_ALIQISS <> 0
							nAliqISS	:= SB1->B1_ALIQISS
						Else
							nAliqISS	:= cMvAliqIss
						EndIf
						
						REPLACE SD2->D2_ALIQISS	WITH nAliqISS 
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se abater ISS mas nao descontar do titulo, e nao houver ISS somado ainda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lMvTpAbISS .AND. !lMvDescISS .AND. SD2->D2_BASEISS == 0 .AND. nAliqISS > 0
						If lIntegDef //Integracao mantem valor de ISS do item														
							MaFisAlt("IT_VALISS" , SL2->L2_VALISS , nItens,,,, "LOJA701", .F.) 
							MaFisAlt("IT_BASEISS", SL2->L2_BASEISS, nItens,,,, "LOJA701", .F.) 							
							nF2BaseISS := nF2BaseISS	+ SD2->D2_BASEISS
						Else							
							REPLACE SD2->D2_BASEISS	WITH SD2->D2_TOTAL
							REPLACE SD2->D2_VALISS	WITH NoRound( ( SD2->D2_TOTAL * nAliqISS ) / 100, nDecimais )							
							nF2BaseISS	 := nF2BaseISS	+ SD2->D2_BASEISS
						EndIf
						
						nF2ValISS		:= nF2ValISS	+ SD2->D2_VALISS
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava TODOS os valores como Base, Aliquota e Valor de apuracao do PIS/COFINS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lL2VALPS2 .AND. lL2VALCF2 .AND. lL2BASEPS2 .AND. lL2BASECF2 .AND. lL2ALIQPS2 .AND. lL2ALIQCF2
					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_BASEPS2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_BASEPS2
						nBasePS2 += SL2->L2_BASEPS2
					EndIf

					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALPS2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_VALPS2
						nValPS2 += SL2->L2_VALPS2
					EndIf

					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQPS2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_ALIQPS2
					EndIf

					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_BASECF2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_BASECF2
						nBaseCF2 += SL2->L2_BASECF2
					EndIf

					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALCF2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_VALCF2
						nValCF2  += SL2->L2_VALCF2
					EndIf

					If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQCF2"} ) )
						REPLACE SD2->&(aRelImp[nScanPis,2]) WITH SL2->L2_ALIQCF2
					EndIf

				EndIf

				If lLjDifal
					If SD2->(FieldPos("D2_DIFAL")) > 0 .And.  SD2->(FieldPos("D2_ALIQCMP")) > 0 .And.  SD2->(FieldPos("D2_VFCPDIF")) > 0

						REPLACE SD2->D2_ICMSCOM WITH MaFisRet(nItens,"IT_VALCMP")
						REPLACE SD2->D2_DIFAL WITH MaFisRet(nItens,"IT_DIFAL")
						REPLACE SD2->D2_PDORI WITH MaFisRet(nItens,"IT_PDORI")
						REPLACE SD2->D2_PDDES WITH MaFisRet(nItens,"IT_PDDES")
						REPLACE SD2->D2_ALFCCMP WITH MaFisRet(nItens,"IT_ALFCCMP")
						REPLACE SD2->D2_ALIQCMP WITH MaFisRet(nItens,"IT_ALIQCMP")
						REPLACE SD2->D2_BASEDES WITH MaFisRet(nItens,"IT_BASEDES")
						REPLACE SD2->D2_VFCPDIF WITH MaFisRet(nItens,"IT_VFCPDIF")
						REPLACE SD2->D2_VOPDIF  WITH MaFisRet(nItens,"IT_VOPDIF")
						REPLACE SD2->D2_ICMSDIF WITH MaFisRet(nItens,"IT_ICMSDIF")

					EndIf
				EndIf

				//Verifica configuracao do produto referente a Venda para Orgaos Publicos
				If lB1M996 .And. cB1M996 <> "1"
					cB1M996	:=	SB1->(FieldGet(FieldPos(cMV_B1M996)))
				EndIf

				//Gravação Especie SAT
				If AllTrim(SD2->D2_SERIE) <> "RPS" .And. AllTrim(SL1->L1_ESPECIE) == "SATCE"
					REPLACE SD2->D2_ESPECIE WITH SL1->L1_ESPECIE
				EndIf

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a gravação dos impostos - Localizações³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotLiq += SD2->D2_TOTAL //Acumula o total liquido...
				aImps := TesImpInf(SL2->L2_TES)
				For i := 1 To Len(aImps)
					If cPaisLoc == "ARG" .AND. (Subs(aImps[i,10],3,7) == "_ALQIMP")
						cCampo := Subs(aImps[i,10],1,10)
						nBaseImp := &("SL2->L2"+Subs(aImps[i,10],3,8))

						If SD2->(FieldPos( cCampo )) > 0
							//SD2->(FieldPut(FieldPos(cCampo),nBaseImp))
							REPLACE SD2->(&(cCampo)) WITH nBaseImp
						EndIf
					EndIf

					If Subs(aImps[i,7],3,7) == "_BASIMP"
						cCampo := Subs(aImps[i,7],1,10)
						If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
							nBaseImp := xMoeda(&("SL2->L2"+Subs(aImps[i,7],3,8)),nMoedaCor,1,SD2->D2_EMISSAO)
						Else
							nBaseImp := &("SL2->L2"+Subs(aImps[i,7],3,8))
						EndIf
						If FieldPos( cCampo ) > 0
							SD2->(FieldPut(FieldPos(cCampo),nBaseImp))
						EndIf
						nPos := Ascan( aImpsSF2,{|x| x[1] == Subs(aImps[i,8],1,10)})
						If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
							nBaseImp := xMoeda(&("SL2->L2"+Subs(aImps[i,8],3,8)),nMoedaCor,1,SD2->D2_EMISSAO)
						Else
							nBaseImp := &("SL2->L2"+Subs(aImps[i,8],3,8))
						EndIf
						If nPos == 0
							If lIntSynt //Para integracao Synthesis deve considerar o imposto enviado pelo BridgePOS
								Aadd(aImpsSF2,{Subs(aImps[i,8],1,10),&("SL1->L1"+Subs(aImps[i,8],3,8))})
							Else
								Aadd(aImpsSF2,{Subs(aImps[i,8],1,10),nBaseImp})
							EndIf
						Else
							If !lIntSynt //Para integracao Synthesis deve considerar o imposto enviado pelo BridgePOS
								aImpsSF2[nPos][02] += nBaseImp
							EndIf
						EndIf
					EndIf
					If Subs(aImps[i,2],3,7) == "_VALIMP"
						cCampo := Subs(aImps[i,2],1,10)
						If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
							nValImp := xMoeda(&("SL2->L2"+Subs(aImps[i,2],3,8)),nMoedaCor,1,SD2->D2_EMISSAO)
						Else
							nValImp := &("SL2->L2"+Subs(aImps[i,2],3,8))
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Acumula o total dos Impostos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//Verifica se Soma ou Subtrai valor do imposto ao valor da nota fiscal. Configuracao do campo FC_INCNOTA (1=Somar;2=Subtrair;3=Indiferente)
						If aImps[i,3] == "1" // 1=Somar
							nTotImp += nValImp
						ElseIf aImps[i,3] == "2" // 2=Subtrair
							nTotImp -= nValImp
						EndIf

						If FieldPos( cCampo ) > 0
							SD2->(FieldPut(FieldPos(cCampo),nValImp))
						EndIf
						nPos := Ascan( aImpsSF2,{|x| x[1] == Subs(aImps[i,6],1,10)})
						If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
							nValImp := xMoeda(&("SL2->L2"+Subs(aImps[i,6],3,8)),nMoedaCor,1,SD2->D2_EMISSAO)
						Else
							nValImp := &("SL2->L2"+Subs(aImps[i,6],3,8))
						EndIf
						If nPos == 0
							If lIntSynt //Para integracao Synthesis deve considerar o imposto enviado pelo BridgePOS
								Aadd(aImpsSF2,{Subs(aImps[i,6],1,10),&("SL1->L1"+Subs(aImps[i,6],3,8))})
							Else
								Aadd(aImpsSF2,{Subs(aImps[i,6],1,10),nValImp})
							EndIf
						Else
							If !lIntSynt //Para integracao Synthesis deve considerar o imposto enviado pelo BridgePOS
								aImpsSF2[nPos][02] += nValImp
							EndIf
						EndIf

						If !cPaisLoc == "ARG"
							cCampo := Subs(aImps[i,10],1,10)
							If FieldPos( cCampo ) > 0
								SD2->(FieldPut(FieldPos(cCampo),aImps[i][9]))
							EndIf
						EndIf
					EndIf
				Next i

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Totaliza os descontos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotDesc += (SL2->L2_VALDESC+SL2->L2_DESCPRO)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valoriza o array aImpVarSD2³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aImpVarSD2 := Lj010SimSD2(SL2->L2_TES)
				LjGravaLog( lScreen, cNumOrc, '42) Especie MVNOTAFIS - ' + MVNOTAFIS, LMALERT)
				cEspecie := If(lImpCupFis, "CF", MVNOTAFIS)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Array para geracao dos Livros Fiscais          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Qdo for pais Mexico nao podera ser gerado livro fiscal on-line³
				//³para cupom fiscal. A geracao sera feita na rotina de Factura  ³
				//³Global.                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc <> "MEX" .OR. (cPaisLoc == "MEX" .AND. !lImpCupFis)
					aLivro := GetBook(@aGetBook, aImpVarSD2, "V", SL1->L1_TXMOEDA, aLivro, "S")
				EndIf

				REPLACE SD2->D2_ESPECIE	WITH cEspecie
				REPLACE SD2->D2_TIPODOC	WITH "01"
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava numero da serial - Atualizacao da localizacao - SBF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			REPLACE SD2->D2_NUMSERI	WITH SL2->L2_NSERIE
			REPLACE SD2->D2_LOTECTL WITH SL2->L2_LOTECTL

			If lL2DTVALID
				REPLACE SD2->D2_DTVALID	WITH SL2->L2_DTVALID
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente grava o D2_NUMLOTE quando for³
			//³sublote                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Rastro(SD2->D2_COD,"S")
				REPLACE SD2->D2_NUMLOTE		WITH SL2->L2_NLOTE
			EndIf

			REPLACE SD2->D2_LOCALIZ		WITH SL2->L2_LOCALIZ

			/*
			O array aSxFci é carregado no inicio da função. Parametros/Campos da FCI:
			aSxFci ->	[4] - SD2->(FieldPos("D2_FCICOD") ) > 0
						[5] - SD2->(FieldPos("D2_VLIMPOR")) > 0
						[6] - SLR->(FieldPos("LR_VLIMPOR")) > 0 .And. SL2->(FieldPos("L2_VLIMPOR")) > 0
						[8] - SLR->(FieldPos("LR_FCICOD") ) > 0 .And. SL2->(FieldPos("L2_FCICOD")) > 0
			*/
			If aSxFci[5] .And. aSxFci[6]
				REPLACE SD2->D2_VLIMPOR WITH SL2->L2_VLIMPOR
			EndIf

			If aSxFci[4] .And. aSxFci[8]
				REPLACE SD2->D2_FCICOD  WITH SL2->L2_FCICOD
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava a comissao do item³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA3->(DbSetOrder(1))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao tem problema se nao encontrar, pois a comissao pode estar no produto ou no cliente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA3")
			SA3->(MsSeek(xFilial("SA3") + SL2->L2_VEND))

			Do Case
				Case ! Empty(SB1->B1_COMIS)
					REPLACE SD2->D2_COMIS1	WITH SB1->B1_COMIS
				Case ! Empty(SA3->A3_COMIS)
					REPLACE SD2->D2_COMIS1	WITH SA3->A3_COMIS
				OtherWise
					REPLACE SD2->D2_COMIS1	WITH SA1->A1_COMIS
			EndCase

			If ! Empty(SL2->L2_VEND)
				nComis  := SD2->D2_COMIS1
				nPos 	:= Ascan( aVendedor, { |x| x[1] = SL2->L2_VEND } )
				If AllTrim(SA3->A3_FRETE) == "N"
					nVlItem := SD2->D2_TOTAL 
				else
					nVlItem := SD2->D2_TOTAL + SD2->D2_SEGURO + SD2->D2_VALFRE + SD2->D2_DESPESA		
				EndIf

				// Considera o IPI na Base da Comissao
				If AllTrim(SA3->A3_IPI) == 'S' .AND. SD2->D2_VALIPI > 0
					nVlItem += SD2->D2_VALIPI
				Endif

				//Abate o percentual da administradora proporcionalmente
				If SL1->L1_CARTAO > 0 .AND. cMvComisCC == 'S'
					xRet := Lj440AdmFin(SL1->L1_NUM, nDecimais)
					If ValType(xRet) == "N" 
						nVlItem -= xRet    // Antes de 05/2019 retornava numerico
					Else
						nVlItem -= xRet[1] // Criado mais uma posição de retorno. 1 numerico / 2 Logico 
					EndIf		
				EndIf

				If nPos == 0
				   Aadd(aVendedor, {SL2->L2_VEND, nComis, nVlItem,((nVlItem*nComis)/100),1 } )
				Else
					aVendedor[nPos][3] += nVlItem
					aVendedor[nPos][4] += (nVlItem*nComis)/100          
					aVendedor[nPos][5] += 1
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Proporcionaliza a comissao da venda, de acordo com a³
				//³comissao para cada item                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nPos := 1 to Len(aVendedor)
					If aVendedor[nPos][5] > 1
						aVendedor[nPos][2] := (aVendedor[nPos][4] / aVendedor[nPos][3]) * 100
					EndIf
				Next nPos

			EndIf

			If cPaisLoc == "BOL" .AND. nMoedaCor <> 1
				REPLACE SD2->D2_VALBRUT WITH xMoeda(MaFisRet(nItens,"IT_TOTAL"),nMoedaCor,1,SL2->L2_EMISSAO)
			Else
				If lLocR5
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Release 11.5 - Localizacoes³
					//³Totalizar impostos do item ³
					//³Paises: Chile/Colombia     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        	nTotImpIt	:= 0
					aTesImpInf  := TesImpInf(SL2->L2_TES)
				   	For nX := 1 to Len(aTesImpInf)
				    	If aTesImpInf[nX][3] == "1"  //Incide na NF
				     		nTotImpIt  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))
				      	EndIf
				   	Next nX
				   	REPLACE SD2->D2_VALBRUT WITH (SL2->L2_PRCTAB-(SL2->L2_DESCPRO+SL2->L2_VALDESC)+nTotImpIt)
				Else
					If lIntegDef //Valor Total para integracao 
						MaFisAlt("IT_TOTAL" , SL2->L2_VLRITEM + SL2->L2_VALIPI + SL2->L2_ICMSRET, nItens,,,, "LOJA701", .F.)
					Else					
						REPLACE SD2->D2_VALBRUT WITH MaFisRet(nItens,"IT_TOTAL")
					EndIf
		   		EndIf
		   	EndIf
	  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para Legislação de Carga Tributária - Lei nº 12.741/2012 (Lei da Transparência)        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA" .And. lLeiTran
			   	If SL1->L1_TIPOCLI == "F" .And. nModulo == 5 .And. FindFunction("AlqLei2741") // Legislação aplicada apenas para cliente consumidor final
					If lMVPRDSERV .And. SL2->L2_VALISS > 0
						// Pega o numero do Item de Servico
						nItem := ++nItemServ
					Else
						// Pega o numero do Item de Produto
						nItem := ++nItemProd
					Endif

					SD2->D2_TOTIMP := SL2->L2_TOTIMP

					If lCpoImpEnt
						REPLACE SD2->D2_TOTFED WITH SL2->L2_TOTFED
						REPLACE SD2->D2_TOTEST WITH SL2->L2_TOTEST
						REPLACE SD2->D2_TOTMUN WITH SL2->L2_TOTMUN
					EndIf

				Else
					REPLACE SD2->D2_TOTIMP WITH SL2->L2_TOTIMP

					If lCpoImpEnt
						REPLACE SD2->D2_TOTFED WITH SL2->L2_TOTFED
						REPLACE SD2->D2_TOTEST WITH SL2->L2_TOTEST
						REPLACE SD2->D2_TOTMUN WITH SL2->L2_TOTMUN
					EndIf

				EndIf

				// Adequacao a nova lei dos impostos 13032015
				nTotCargT  += SD2->D2_TOTIMP

				If lCpoImpEnt
					nTotCarFed += SD2->D2_TOTFED
					nTotCarEst += SD2->D2_TOTEST
					nTotCarMun += SD2->D2_TOTMUN
				EndIf

			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza CAT83			  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCAT83
				REPLACE SD2->D2_CODLAN WITH SL2->L2_CODLAN
				FISA023("SD2",SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEM,"I")
			EndIf

			If lIntSynt //Quando integracao Synthesis tem que considerar o valor calculado pelo BridgePOS
			   	REPLACE SD2->D2_VALBRUT WITH SL2->L2_VLRITEM
			   	REPLACE SD2->D2_PRUNIT 	WITH SL2->L2_VRUNIT
			   	REPLACE SD2->D2_CF		WITH SL2->L2_CF
            EndIf
            
			//Integracao grava informacoes para centro de custo
			If lIntegDef
				If lL2ITEMCC .And. lL2CCUSTO .And. lL2CLVL					
	              	REPLACE SD2->D2_CCUSTO WITH SL2->L2_CCUSTO
					REPLACE SD2->D2_ITEMCC WITH SL2->L2_ITEMCC
					REPLACE SD2->D2_CLVL   WITH SL2->L2_CLVL
				EndIf	
			EndIf

			SD2->(MsUnlock())
			//Se integracao Mensagem Unica, verifica a filial da reserva	
			If lIntegDef
				SLJ->(dbSetOrder(1)) //LJ_FILIAL+LJ_CODIGO
				If SLJ->(dbSeek(xFilial("SLJ") + SL2->L2_LOJARES))
					cFilRes := SLJ->LJ_RPCFIL
				EndIf
					
				//Atualiza Saldo Poder de terceiros
				TrfSldPoder3(SD2->D2_TES,"SD2",SD2->D2_COD,.F.)
								
			EndIf
	  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Estoque - SB2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Nao processar Estoque quanto tiver em Totvs PDV com NF-e
			If !lNFePDV .and. SF4->F4_ESTOQUE == "S"
				//Forca a atualizacao da SB2 para evitar inconsistencias nos valores de custo
				SB2->(DbSkip(0))

				If !(lCFolChiR5 .AND. (cTpGeraGdp $ GDP_PARCIAL + ";"+ GDP_TOTAL) .AND. SL2->L2_ENTREGA == "3" .AND. !Empty(SL2->L2_RESERVA))//Release 11.5 - Chile - F2CH - Item de Guia de Despacho NAO atualiza estoque.
					LjGravaLog( lScreen, cNumOrc, '24) Antes da B2AtuComD2', LMALERT, LMTECH)
					If SL1->L1_TIPO $ "D|B"
						aCusDev := {SD2->D2_TOTAL,SD2->D2_VALIPI, SD2->D2_VALICM, SF4->F4_IPI, SF4->F4_ICM}
					Endif
					
					aCusto := GravaCusD2(PegaCMAtu(SD2->D2_COD , SD2->D2_LOCAL , SD2->D2_TIPO, aCusDev), SD2->D2_TIPO)
					
					//Integracao Mensagem Unica posiciona na filial da reserva
					If lIntegDef
						cFilBkp := cFilAnt
						cFilAnt := cFilRes
					EndIf
					
					B2AtuComD2(	aCusto			, Nil			, Nil	, !Empty(SL2->L2_RESERVA)	,;
								0				, "SC0"			, NIL	, .T.						,;
								SL2->L2_RESERVA	, SL2->L2_ITEM	, Space(nTDCSEQ)		)

					SB2->(MsUnlock())

					If lWmsNew .And. IntWms(SD2->D2_COD)									//Somente Novo WMS, não entra se WMS antigo
						If GetApoInfo("WMSDTCEstoqueEndereco.PRW")[4] >= Ctod("01/11/2018")	//Não há ExistFunc() para métodos: utilizei GetApoInfo para verificar se tem o método oEstEnder:MakeFatLoj()
							If oEstEnder = nil
								oEstEnder 	:= WMSDTCEstoqueEndereco():New()				
							EndIf
							LjGrvLog( NIL, " Antes da Execução do Método MakeFatLoj() - Recno da SD2: ", Alltrim( Str(SD2->(Recno()))) )
							oEstEnder:MakeFatLoj( SD2->(Recno()) )							//Efetua baixa das partes nas tabelas do novo Wms
							LjGrvLog( NIL, " Depois da Execução do Método MakeFatLoj() - Recno da SD2: ", Alltrim( Str(SD2->(Recno()))) )
						EndIf
					Endif
									
					//Integracao Mensagem Unica restaura filial da venda
					If lIntegDef
						cFilAnt := cFilBkp
					EndIf

			       LjGravaLog( lScreen, cNumOrc, '25) Depois da B2AtuComD2', LMALERT, LMTECH)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta as reservas qdo necessario                            ³
			//³ O SC0 esta sendo deletado aqui pq a B2AtuComD2 faz a atualiza³
			//³ cao do SB2->B2_RESERVA mas nao mata o SC0                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTPLOtica
				If lGeraOP
					//Valida se o produto pode gerar empenho
					If (lB1FANTASM .AND. !AllTrim(SB1->B1_FANTASM) == "S") .OR. !lB1FANTASM
						Aadd(aEmp,{	SL2->L2_RESERVA, SL2->L2_PRODUTO, SL2->L2_CONJUNT,SL2->L2_LOCAL,;
									SL2->L2_LOCALIZ, SL2->L2_LOTECTL, SL2->L2_NLOTE,SL2->L2_NSERIE,SL2->L2_DTVALID,SL2->L2_QUANT})
					EndIf
				Endif
			Endif

			If !Empty(SL2->L2_RESERVA)

				// Tambem deve excluir a tabela de empenho antes da SC0
				DbSelectArea("SDC")
				DbSetOrder(1) //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
				If DbSeek(xFilial("SDC")+SL2->L2_PRODUTO+SL2->L2_LOCAL+"SC0"+Padr(SL2->L2_RESERVA,nTDCPED)+Space(nTDCITE)+Space(nTDCSEQ)+SL2->L2_LOTECTL+SL2->L2_NLOTE)
					RecLock("SDC",.F.,.T.)
					dbDelete()
					MsUnLock()
				EndIf
				
				aAreaSC0 := GetArea()

				//Integracao Mensagem Unica posiciona na filial da reserva
				If lIntegDef
					cFilBkp := cFilAnt
					cFilAnt := cFilRes
				EndIf
				DbSelectArea( "SC0" )
				SC0->(DbSetOrder( 1 )) // filial + numero + produto + local
				If SC0->(DbSeek( xFilial( "SC0" ) + SL2->L2_RESERVA + SL2->L2_PRODUTO + SL2->L2_LOCAL ))
				    RecLock( "SC0", .F. )
					DbDelete()
					MsUnlock()
				EndIf
				//Integracao Mensagem Unica restaura filial da venda
				If lIntegDef
					cFilAnt := cFilBkp
				EndIf

				RestArea(aAreaSC0)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza Poder de Terceiro - Inclui registro na tabela SB6.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Mini-GrvBacth Totvs PDV nao precisa movimentar estoque
			If !lNFePDV .and. SF4->F4_PODER3 <> "N"
				RecLock("SD2",.F.)
				MaAtuSB6("SD2",3)
				SD2->(MsUnlock())
			EndIf

			//Mini-GrvBacth Totvs PDV nao precisa movimentar estoque
			if !lNFePDV
				LjGravaLog( lScreen, cNumOrc, '26) Antes da LjGrvSB3', LMALERT, LMTECH)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava arquivo de demandas SB3 ao gerar SD2 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjGrvSB3()

				LjGravaLog( lScreen, cNumOrc, '27) Depois da LjGrvSB3', LMALERT, LMTECH)
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao dos impostos na tabela SL2     ³
			//³ apartir da tabela SD2, a Atualizacao do SF2³
			//³ esta na funcao LjGrvSF2                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA" .And. !lIntegDef //Integracao nao atualiza impostos na tabela SL2
				RecLock( "SL2" ,.F.)
				SL2->L2_VALIPI	:= SD2->D2_VALIPI
				SL2->L2_BASEICM := SD2->D2_BASEICM
				SL2->L2_VALICM  := SD2->D2_VALICM
				SL2->L2_BRICMS  := SD2->D2_BRICMS
				SL2->L2_ICMSRET := SD2->D2_ICMSRET
				SL2->(MsUnlock())
			EndIf

			// Efetua a gravação da venda do Vale Presente
			If lL2VALEPRE .AND. !Empty( SL2->L2_VALEPRE )
				LjGrVVlPre(	SL2->L2_VALEPRE	, SL1->L1_VEND  , SL2->L2_DOC , SL1->L1_ESTACAO,;
							SL2->L2_PDV		, SL1->L1_EMISNF, SL1->L1_HORA, SL1->L1_CLIENTE,;
							SL1->L1_LOJA, SL2->L2_SERIE )
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes                  ³
			//³Verificar os itens que serao incluidos   	³
			//³na factura de acordo com  tipo de entrega	³
			//³Paises:Chile/Colombia - F1CHI/F2CHI			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If lLocR5
	        	LjAddBrkIt (@aBreakNota	,@aItens			,SL2->L2_ENTREGA,cNumNota,;
	        				cSerie		,SL2->(Recno())		,cTpGeraGdp		,nOpc)
			EndIf
			
			If lIntegDef //Tratamentos integracao Mensagem Unica								
				//Grava as informacoes fiscais para SF2 e SD2
				SF4->(MaFisWrite(2, "SD2", nIndnY))								
				//Valores de ICMS Ret (ICMS)
                If SF4->F4_INCSOL == 'S' .AND. SD2->D2_ICMSRET > 0 
                	MaFisLoad("LF_VALCONT", SD2->D2_ICMSRET + SD2->D2_TOTAL , FR271BPegaIT(SL2->L2_ITEM))
                EndIf
				//Utilizar os dados da L2 quando for integração DVARLOJ1-4024
                MaFisLoad("LF_CLASFIS",cClasFis, FR271BPegaIT(SL2->L2_ITEM))
                //MaFisAlt Não funciona para alterar FT_CLASFIS utilizei para MaFisLoad
				RecLock( "SD2", .F. )
				SD2->D2_TOTAL := SL2->L2_VLRITEM
				SD2->D2_CLASFIS := cClasFis //MaFisWrite usa TES mas Para integração considerar o que vem L2_CLASFIS no XML e gravado L2_CLASFIS 
				//Busca Informacoes da Nota de Origem para os casos de devolucao.
				//este posicionamento nao deve ser alterado, pois a rotina
				//MaFisWrite perdendo os valores de nota e serie de origem. 
				If SL1->L1_TIPO == "D"
					MH4->(DbSetOrder(1))//MH4_FILIAL + MH4_SERRPS + MH4_DOCRPS + MH4_ITEM
					If(MH4->(DbSeek(xFilial("MH4")+SL2->L2_SERIE+SL2->L2_DOC+SL2->L2_ITEM)))
						DbSelectArea("SD2")
						REPLACE SD2->D2_ESTOQUE		WITH "S"
						REPLACE SD2->D2_SERIORI		WITH MH4->MH4_SERORI
						REPLACE SD2->D2_NFORI		WITH MH4->MH4_DOCORI
						REPLACE SD2->D2_ITEMORI		WITH Strzero(Val(MH4->MH4_ITEORI), TamSX3("D2_ITEMORI")[1])
						
						MaFisAlt("IT_NFORI" , MH4->MH4_DOCORI , FR271BPegaIT(SL2->L2_ITEM),,,, "LOJA701", .F.)
						MaFisAlt("IT_SERORI", MH4->MH4_SERORI , FR271BPegaIT(SL2->L2_ITEM),,,, "LOJA701", .F.)
					Endif
				Endif	
				
				If !(SL2->L2_BASFECP > 0)
					REPLACE SD2->D2_BASFECP WITH 0
				EndIf
				SD2->(MsUnlock())
								
				If lIntegHtl //Tratamento PCO hotelaria												 													
					//Posiciona no cliente
					SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					SA1->(dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA))
									
					//Posiciona no produto
					SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
					SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
													
					//Chamada lancamento do PCO para SD2				
					PCODetLan(cProcesso, cCodItem, "LOJXFUNC")
				EndIf																									
			EndIf

		Next nIndnY
		
		//Finaliza PCO - Hotelaria
		If lIntegHtl	
			PcoFinLan(cProcesso)
		EndIf
		
		RestArea(aArea)
	Next nIndnX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Chile - Guia de Despacho - F2CHI            ³
	//³Quando for gerada Guia de Despacho parcial, reposiciona    ³
	//³SL1 no orcamento PAI, para obter todos os itens da venda   ³
	//³e inclui-los na factura, inclusive os que estao com pedido ³
	//³de venda.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCFolChiR5 .AND. (cTpGeraGdp $ GDP_PARCIAL)
		SL1->(RestArea(aAreaSL1))
		DbSelectArea("SL2")
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a funcao de gravacao do SF2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItens > 0

		LjGravaLog( lScreen, cNumOrc, '17) Antes da LjGrvSF2' + Chr(13) + Chr(10) + ;
			                                        '	18) nItens = '         + AllTrim(STR(nItens)) + Chr(13) + Chr(10) + ;
			                                        '	19) cNumNota = '       + cNumNota + Chr(13) + Chr(10) + ;
			                                        '	20) cSerie = '         + cSerie, LMALERT, LMTECH )

		LjGrvSF2( .T.		, lImpCupFis, @cNumNota	, cFirst	,;
		          aImpsSF2	, nTotLiq	, nTotImp	, cSerie	,;
		          nTotDesc	, @nBaseDup	, nBasePS2	, nValPS2	,;
				  nBaseCF2	, nValCF2	, lScreen	, aTotais	,;
				  NIL		, cCgcCli	, lNfManual	, nBaseRed  ,;
				  .F. 		, lIsNFServ , @cSerieNF , lIsNFServ )

		LjGravaLog( lScreen, cNumOrc, '21) Depois da LjGrvSF2' + Chr(13) + Chr(10) + ;
			                                        '	22) cNumNota = '        + cNumNota + Chr(13) + Chr(10) + ;
			                                        '	23) cSerie = '          + cSerie, LMALERT, LMTECH )
		If lTPLOtica
			If lGeraOP
				GerOPOtc(cNumNota,cSerie,aEmp,3)
			Endif
		Endif

		If lGerInt
 			oIntVenda:Inserir("SF2", xFilial("SF2") + PADR(cNumNota,9) + PADR(cSerie,3) + SL1->L1_CLIENTE + SL1->L1_LOJA, "1", "3")
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava numero de nota e serie de servico (RPS)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMVLJPRDSV .And. lIsNFServ .And. lTemItServ
			If Empty(SL1->L1_DOCRPS) .Or. lOnlyServ

				// Vindo do Totvs PDV precisa de realizar o Lock, pois e destravado nas funcoes 
				// LjInclSF2 atualizando o campo L1_HORA e na funcao LjGravaErr o campo L1_SITUA para "ER"
				RecLock("SL1",.F.)
				SL1->L1_DOCRPS := cNumNota
				SL1->L1_SERRPS := cSerieNF
				SL1->( MsUnLock() )
			EndIf

			//Grava o campo F2_NUMORC,  com o numero do orcamento (L1_NUM). Este campo eh gravado somente se na venda existir itens de "serviço".
			RecLock( "SF2", .F. )
			SF2->F2_NUMORC := SL1->L1_NUM
			SF2->( MsUnlock() )
		EndIf

		If nValIss == 0 .AND. nF2ValISS > 0 .And. !lIntegDef //Integracao atualiza valor bases SF2
			RecLock("SL1",.F.)
			SL1->L1_VALISS	:= nF2ValISS
			SL1->( MsUnLock() )

			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava o valor do ISS no SL1, atualiza o SF2 com o valor do ISS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecnoSF2 := SF2->( Recno() )
			SF2->( DbSetOrder( 1 ) )
			If SF2->( DbSeek( xFilial( "SF2" ) + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
				RecLock( "SF2", .F. )
				SF2->F2_BASEISS	:= nF2BaseISS
				SF2->F2_VALISS	:= nF2ValISS
				SF2->( MsUnlock() )
			EndIf
			SF2->( DbGoTo ( nRecnoSF2 ) )
			nF2ValISS	:= 0
			nF2BaseISS	:= 0
		EndIf

		If cPaisLoc <> "BRA"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a qtde de casas decimais da moeda do orcamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDecimais := MsDecimais(SL1->L1_MOEDA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a gravacao do Livro Fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If Len(aLivro) > 0

				//Nit e nome de terceiros - Bolivia
		    	If cPaisLoc == "BOL" .AND. SF3->(FieldPos("F3_NIT")) > 0 .AND. SF3->(FieldPos("F3_RAZSOC")) > 0

		    		//Grava o NIT de terceiro
		    		nPos := aScan(aLivro[1],"F3_NIT")
		    		If nPos == 0
		    			AAdd(aLivro[1],"F3_NIT")
		    			AAdd(aLivro[2],"")
		    			nPos := Len(aLivro[1])
		    		EndIf
		    		aLivro[2][nPos] := cCGCCli

		    		//Grava o nome de terceiro
		    		nPos := aScan(aLivro[1],"F3_RAZSOC")
		    		If nPos == 0
		    			AAdd(aLivro[1],"F3_RAZSOC")
		    			AAdd(aLivro[2],"")
		    			nPos := Len(aLivro[1])
		    		EndIf
		    		aLivro[2][nPos] := cNomeCli

		    	EndIf

				GravaLivro( @aLivro 	, SL1->L1_SERIE , cNumNota, cCGCCli		,;
							lNfManual  	)

			EndIf
		Else
			nValIcm  += SF2->F2_VALICM
			nValIpi  += SF2->F2_VALIPI
			nValIss  += SF2->F2_VALISS
			nBrIcms  += SF2->F2_BRICMS
			nIcmsRet += SF2->F2_ICMSRET
			nValPIS  += SF2->F2_VALPIS
			nValCSLL += SF2->F2_VALCSLL
			nValCOFI += SF2->F2_VALCOFI
			nValINSS += SF2->F2_VALINSS
			nValIRRF += SF2->F2_VALIRRF
		EndIf
	EndIf

	// Atualizando os campos de impostos do orcamento
	// Nao faz o RecLock no SL1 pois o registro jah vem travado da funcao LjGrvTudo
	If cPaisLoc == "BRA" .And. !lIntegDef //Integracao nao atualiza SL1
		// Vindo do Totvs PDV precisa de realizar o Lock, pois e destravado nas funcoes 
		// LjInclSF2 atualizando o campo L1_HORA e na funcao LjGravaErr o campo L1_SITUA para "ER"
		RecLock("SL1",.F.)
		SL1->L1_VALICM	:= nValIcm
		SL1->L1_VALIPI  := nValIpi
		SL1->L1_VALISS  := nValIss
		SL1->L1_BRICMS  := nBrIcms
		SL1->L1_ICMSRET := nIcmsRet
		SL1->( MsUnLock() )
	EndIf

	LjGravaLog( lScreen, cNumOrc, '24) Antes do bloco  "LJ010SF3"', LMALERT, LMTECH)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para gerar Livro Fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ010SF3") .AND. !lFtvdVer12
		ExecBlock("LJ010SF3",.F.,.F.)
	EndIf

	If ExistBlock("FTVD010SF3") .AND. lFtvdVer12
		ExecBlock("FTVD010SF3",.F.,.F.)
	EndIf

	LjGravaLog( lScreen, cNumOrc, '25) Depois do bloco  "LJ010SF3"', LMALERT, LMTECH)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a gravacao do F2_NEXTDOC quando o parametro MV_TPNRNFS == "3"    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3" .AND. Len( aNotas ) > 1 .AND. !lImpCupFis
	nRecnoSF2 := SF2->( Recno() )
	SF2->( DbSetOrder( 1 ) )
    For nX := 1 to Len( aNotas ) - 1
		If SF2->( DbSeek( xFilial("SF2") + aNotas[nX][2] + aNotas[nX][1] ) )
			RecLock( "SF2", .F. )
			SF2->F2_NEXTDOC := aNotas[ nX + 1 ][2]
			SF2->( MsUnlock() )
		EndIf
	Next nX
	SF2->( DbGoTo ( nRecnoSF2 ) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento referente ao valor do abatimento do PIS/COFINS/CSLL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aPISCofCSL") == "A"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes da gravação dos títulos atualiza o valor do abatimento do PIS/COFINS/CSLL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJPCCAlt("SL", { , nValPIS, nValCOFI, nValCSLL })

	If LJPCCRet(1) > 0
		nValPIS := LJPCCRet(1)
	EndIf

	If LJPCCRet(2) > 0
		nValCOFI := LJPCCRet(2)
	EndIf

	If LJPCCRet(3) > 0
		nValCSLL := LJPCCRet(3)
	EndIf

EndIf

//Verifica se deve gerar financeiro, pois pode ter sido gerado anteriormente quando for uma venda com itens de "retira" e "entrega" e parametro MV_LJGRVON = .F.
If !lPedFin
	If FunName() == "RPC" .And. !SuperGetMV("MV_LJGRVON",,.T.) .And. SL1->L1_TIPO == "V" //Se orcamento em processamento eh relacionado a VENDA de itens "retira"
		//Verifica se o campo L1_DOCPED do orcamento pai esta preenchido
		aArea2 := SL1->(GetArea())
		SL1->(DbSetOrder(1))
		If SL1->(DbSeek(SL1->L1_FILRES+SL1->L1_ORCRES))
			If !Empty(SL1->L1_DOCPED)
				lGerFin := .F.
			EndIf
		EndIf
		RestArea(aArea2)
	EndIf
EndIf

//Trecho colocado, pois tinha um cliente que queria dois vendedores no cabecalho (ANTONIO AUTOPECAS)
//Nesse caso o cliente preenchendo o campos L1_VEND1, L1_VEND2, L1_VEND3, L1_VEND4, L1_VEND5 e considera na comissao
//Tratamento no Loja440 funcionava apenas para Calculo de Comissao Off-Line, adicionado aqui para funcionar
//no calculo de Comissao On-Line
If cPaisLoc == "BRA"
	For nX := 1 To 5 //Maximo de 5 vendedores	 				
		If SL1->(FieldPos("L1_VEND" + AllTrim(Str(nX)))) > 0 .And. !Empty(&("SL1->L1_VEND" + AllTrim(Str(nX))))																
			nComisAux := Posicione("SA3", 1, xFilial("SA3") + &("SL1->L1_VEND" + AllTrim(Str(nX))), "A3_COMIS") //Armazena percentual de comissao
			
			nPosVend := Ascan( aVendedor, { |x| x[1] = &("SL1->L1_VEND" + AllTrim(Str(nX))) } )

			//Se possui percentual de comissao, efetua calculo
			If nComisAux > 0 .AND. nPosVend == 0				
				Aadd(aVendedor, {&("SL1->L1_VEND" + AllTrim(Str(nX))), nComisAux, SL1->L1_VLRTOT, ((SL1->L1_VLRTOT * nComisAux) / 100), 1})
			EndIf
		EndIf					
	Next nX		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aqui chama a funcao para gravacao do financeiro (SE1, SE5, SEF)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lPedFin .And. lGerFin

	LjGravaLog( lScreen, cNumOrc, '27) Antes da LjGrvFin', LMALERT, LMTECH)

	nRecnoSF2 := SF2->( Recno() ) //Guarda a posicao atual da SF2
	If lMVLJPRDSV
		//Caso tenha sido gerada NF de Produto e NF de Servico, entao posiciona na NF de Produto antes de executar a funcao LjGrvFin
		If !Empty(SL1->L1_DOCRPS) .And. SL1->L1_DOC <> SL1->L1_DOCRPS			
			SF2->( DbSetOrder( 1 ) )
			//Posiciona na NF de Produto antes de executar a funcao LjGrvFin
			If !SF2->( DbSeek( xFilial( "SF2" ) + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
				SF2->( DbGoTo ( nRecnoSF2 ) )
			EndIf
		EndIf
	EndIf

	//Se for itens exclusivos de Serviços Financeiros que não geram cupom fiscal,
	//eu forço a gravar a série específica para LjGrvFin().
	If cSerie = cMvLojaSF
		cLjPref := cSerie
	EndIf

	lRet := LjGrvFin( 	lScreen   	, lFinanceiro	, nNccUsada	, aNccItens	,;
			          	nNccGerada	, aVendedor  	, aReceb   	, @aRecSE1 	,;
			          	nValPIS   	, nValCSLL   	, nValCOFI 	, nBaseDup 	,;
			          	aImpCheque	, nMoedaCor  	, .T.      	, @aNewNCC 	,;
			          	Nil       	, nBasePIS   	, nBaseCOFI	, nBaseCSLL	,;
			          	@cLjPref  	, lIsVendaVP 	, cB1M996  	, nValINSS 	,;
			          	nValIRRF  	, nBaseINSS  	, nBaseIRRF	, lIsVdRecCP,;
	          			nArredondar	, nOpc			, Nil		, Nil		,;
						nVFunrural	, @cDescErro	, lNFePDV )

	If nRecnoSF2 > 0
		SF2->( DbGoTo ( nRecnoSF2 ) )  //Retorna a posicao anterior da SF2
	EndIf

	LjGravaLog( lScreen, cNumOrc, '28) Depois da LjGrvFin', LMALERT, LMTECH)

EndIf

If ExistBlock("LJFIMGRV") .AND. !lFtvdVer12
	ExecBlock("LJFIMGRV",.F.,.F.) // Tomar cuidado com impress„o dentro deste PE
EndIf

If ExistBlock("FTVDFIMGRV") .AND. lFtvdVer12
	ExecBlock("FTVDFIMGRV",.F.,.F.) // Tomar cuidado com impress„o dentro deste PE
EndIf

LjGravaLog( lScreen, cNumOrc, '29) Depois do ponto de entrada LJFIMGRV', LMALERT, LMTECH)

RecLock("SL1", .F.)

//NFC-e: Se ocorrer um erro durante a venda(L1_STORC = A), o LjGrvBatch marca a venda (L1_SITUA = RY)
//para que posteriormente o ExecAuto do LOJA140 cancele a venda e transmita o cancelamento ao TSS
If SL1->L1_TPORC == "E" .AND. (SL1->L1_STORC $ "A|C") .And. Empty(SL1->L1_SERSAT) //Verifica o campo L1_SERSAT vazio para tratar este ponto somente para venda NFC-e
	REPLACE	SL1->L1_STORC WITH "A"
	Replace SL1->L1_SITUA with "X0"
	IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
//Se estiver sendo executado pelo Totvs PDV nao devera marcar o L1_SITUA como OK
Elseif !lNFePDV
	REPLACE	SL1->L1_SITUA WITH "OK"
	IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
EndIf

//PAF-ECF: Gera chave MD5
If !lFtvdVer12 .And. lPafEcf
	cPafMd5 := LjxPAFMD5("SL1")
	REPLACE	SL1->L1_PAFMD5 WITH cPafMd5
EndIf

SL1->(MsUnlock())

/*
	// Implementação feita somente para emissão de NFCe	
	lAutoExA		- Se for executado pelo Robô segue o fluxo anterior
	cTipTef			- Verifica o tipo TEF
	lEmitNFCe 		- Verifica se está configurado para emissão de NFCe
	lNFePDV 		- Verifica se está sendo executado pelo TOTVSPDV
	SL1->L1_SITUA	- Verifica se o status da venda está OK
	SL1->L1_KEYNFCE - Verifica se o campo já foi gravado( Nota gerada )	
	oTef			- Verifica os dados do oTEF
*/

If !lAutoExA .AND. cTipTef $ TEF_CLISITEF .AND. lEmitNFCe .AND. !lNFePDV .AND. SL1->L1_SITUA == "OK" .AND. !Empty(SL1->L1_KEYNFCE) .AND.;
	Type("oTef") == "O" .AND. ValType(oTef:lTEFOk) == "L" .AND. oTef:lTEFOk .AND. Type("oTef:ARETCARTAO") == "A" .AND. Len(oTef:ARETCARTAO) > 0

	// Neste ponto, a venda já esta com L1_SITUA = "OK", então não será possível recuperar caso ocorra algum problema
	// Desta forma, faz a confirmação da transação TEF e limpa SLG->LG_LOGTEF
	oTef:FinalTrn(1, .T.)

EndIf	

//PAF-ECF: Atualiza Chave MD5 SL2/SL4 para validação de registro
If !lFtvdVer12 .And. lPafEcf
	/*Atualiza os dados da SL2 para o PAF-ECF*/
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))

	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM
		RecLock("SL2",.F.)

		REPLACE	L2_SERPDV	WITH	SL1->L1_SERPDV
		REPLACE	L2_CONTDOC	WITH	SL1->L1_CONTDOC

		//Monta chave MD5 do registro
		cPafMd5 := LjxPAFMD5("SL2", SL1->L1_NUMORC)
		REPLACE	L2_PAFMD5	WITH	cPafMd5

		SL2->(MsUnlock())
		SL2->(DbSkip())
	End

	/*Atualiza os dados da SL4 para o PAF-ECF*/
	DbSelectArea( "SL4" )
	SL4->(DbSetOrder( 1 ))
	SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ))

	While !SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM

		RecLock("SL4",.F.)

		REPLACE	L4_SERPDV	WITH	SL1->L1_SERPDV
		REPLACE	L4_CONTDOC	WITH	SL1->L1_CONTDOC
		REPLACE	L4_DOC		WITH	SL1->L1_DOC
		REPLACE	L4_CONTONF	WITH	SL1->L1_CONTONF

		//Monta chave MD5 do registro
		cPafMd5 := LjxPAFMD5("SL4")
		REPLACE	L4_PAFMD5	WITH	cPafMd5

		SL4->(MsUnlock())
		SL4->(DbSkip())
	End
EndIf

cPrefSFA	:= ""	//Prefixo Serviços Financeiros Avulsos
cTitSFA	:= ""	//Título Serviços Financeiros Avulsos
If cPaisLoc <> "BRA"
	nVlrTrocoAux	:=	0
	nVlrCredDesc	:=	0

	For i := 1 To MoedFin()
		nVlrTrocoAux	:=	&("SL1->L1_TROCO"+AllTrim(Str(i)))
		nVlrCredDesc	:=	SL1->L1_CREDITO + nVlrDescItem

		If	nVlrTrocoAux  > 0
			If !(SL1->L1_CREDITO >= SL1->L1_VLRLIQ) .AND. ;	// Se .T. então pagamento com NCC no valor total
				!(nVlrCredDesc >= SL1->L1_VLRLIQ)				//Tratamento caso desconto seja no item e pagamento com NCC no valor total

				If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
					cLjPref := IIf( Empty(cLjPref), SL1->L1_SERIE, cLjPref )
					lRet := LjTrocoInc(	nVlrTrocoAux	, i				, 1				, SL1->L1_EMISNF	,;
										SL1->L1_OPERADO	, Nil			, Nil			, SL1->L1_SERIE		,;
										SL1->L1_DOC		, Nil			, @cDescErro 	, Nil )
					If !lRet
						Disarmtransaction()
					EndIf
				Else
					AtuaTroco( nVlrTrocoAux,i)
				EndIf
				
			EndIf
		EndIf
	Next i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa os titulos automaticamente se o campo E4_BXTITAV³
	//³for igual a "1" - Localizacoes                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lScreen
		//Busca caixa, agencia e conta logados
		xNumCaixa()
		aCaixaFin  := {SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON}
	Else
		SA6->(DbSetOrder(1))
		If SA6->(DbSeek(xFilial("SA6") + SL1->L1_OPERADO))
			aCaixaFin  := {SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON}
		EndIf
	EndIf
	//Excluir do array os titulos referentes a dinheiro porque ja estao baixados
	nY         := 1
	cPrefSFA	:= ""	//Prefixo Serviços Financeiros Avulsos
	cTitSFA	:= ""	//Título Serviços Financeiros Avulsos
	While nY <= Len(aRecSE1)
		SE1->(DbGoTo(aRecSE1[nY]))
		If lSFinanc  //Somente Servico Financeiro habilitado
			If SE1->E1_PREFIXO = cMVLOJASF
				//Atribuo quem são o número e série de serviço financeiro avulso para ser gravado nos novos campos da MFI via Lj7GrvMFI()
				cPrefSFA := SE1->E1_PREFIXO
				cTitSFA  := SE1->E1_NUM
			EndIf
		EndIf
		If IsMoney(SE1->E1_TIPO) .OR. SE1->E1_TIPO $ (MV_CRNEG+"/"+"CR ")
			ADel(aRecSE1,nY)
			aSize(aRecSE1,Len(aRecSE1)-1)
		Else
			nY++
		EndIf
	End
	//Baixa automatica dos titulos a vista, de acordo com a condicao de pagamento
	If Len(aRecSE1) > 0
		BaixAutSE1( SL1->L1_CONDPG , aRecSE1 , aCaixaFin , ;
		NIL            , .T.     )
	EndIf

Else
	If SL1->L1_VALISS > 0 .And. LjxDAbISS(SL1->L1_CONDPG,SL1->L1_FORMPG,SL1->L1_VALISS)
		nVlrTrocoAux := SL1->L1_TROCO1 - SL1->L1_VALISS
	Else
		nVlrTrocoAux := SL1->L1_TROCO1
	EndIf

	If nVlrTrocoAux  > 0
		If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
			cLjPref := IIf( Empty(cLjPref), SL1->L1_SERIE, cLjPref )
			lRet := LjTrocoInc(	nVlrTrocoAux	, 1			, 1				, SL1->L1_EMISNF,;
								SL1->L1_OPERADO	, Nil		, Nil			, cLjPref		,;
								SL1->L1_DOC		, Nil 		, @cDescErro	, Nil )
			If !lRet
				Disarmtransaction()
			EndIf
		Else
			AtuaTroco(	nVlrTrocoAux, 1		, Nil , Nil		,;
						Nil			, Nil	, Nil , Nil     ,;
						cLjPref	)
		EndIf
	EndIf

	//Ler aRecSE1, se houver prefixo de Serviços Financeiros Avulsos, preciso dele para gravar na MFI via função Lj7GrvMFI()
	If lSFinanc  //Somente Servico Financeiro habilitado
		nY         := 1
		cPrefSFA	:= ""	//Prefixo Serviços Financeiros Avulsos
		cTitSFA	:= ""	//Título Serviços Financeiros Avulsos
		While nY <= Len(aRecSE1)
			SE1->(DbGoTo(aRecSE1[nY]))
			If SE1->E1_PREFIXO = cMVLOJASF
				//Atribuo quem são o número e série de serviço financeiro avulso para ser gravado nos novos campos da MFI via Lj7GrvMFI()
				cPrefSFA := SE1->E1_PREFIXO
				cTitSFA  := SE1->E1_NUM
			EndIf
			nY++
		End
	EndIf
EndIf

If ! lScreen
	ConOut("LJGrvBatch: "+STR0079+cFilAnt+". "+STR0011+SL1->L1_NUM)   //"Filial " ### ". " "Terminando a gravacao do orcamento: "
	FRTGrvOK(SL1->L1_NUM)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o valor total de acrescimo da venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lScreen

	//Quando venda de produto com reserva e retira contendo frete há diferença de valores entre o M->LQ_FRETE e o
	//L1_FRETE, devido ao rateio, por isso pegar o conteudo do SL1
	If !lMvLjPdvPa .AND. SL1->L1_RESERVA = 'S' .AND. !EMPTY(SL1->L1_FILRES + SL1->L1_ORCRES) .AND. EMPTY(SL1->L1_PEDRES)
		nVlrAcreFin := nVlrAcreFin + Lj7CalcFrete(.T.)
	Else
		nVlrAcreFin := nVlrAcreFin + Lj7CalcFrete()
	EndIf

Else
	nVlrAcreFin	:= aTotais[__VALACRS]
EndIf
LjGravaLog( lScreen, cNumOrc, '45) SF2->F2_ESPECIE - ' + SF2->F2_ESPECIE, LMALERT)
cEspecNf := Alltrim(SF2->F2_ESPECIE)

 //Servico financeiro nao gera nota !
If  Len(aItensSFin) >= 1 .AND. Len(aItensProd) == 0 .AND. Len(aItensGar) == 0 .AND. Len(aItensServ) == 0
	lFaturar:=.F.
EndIf

If  Len(aItensVP) >= 1 .AND. Len(aItensProd) == 0
	lFaturar:=.F.
EndIf

If lFaturar .And. lRet
	//Caso tenha sido gerada NF de Produto e NF de Servico, entao proporcionaliza o valor do acrescimo entre as duas Notas (Nota de "Produto" e Nota de "Servico")
	If lMVLJPRDSV .And. !Empty(SL1->L1_DOCRPS) .And. !Empty(SL1->L1_DOC) .And. SL1->L1_DOC <> SL1->L1_DOCRPS
		cNumNota := SL1->L1_DOC
		cSerie	 := SL1->L1_SERIE
		//Atualiza NF de "Servico"
		RecLock("SF2",.F.)
		SF2->F2_VALACRS := nVlrAcreFin * (SF2->F2_VALMERC / SL1->L1_VALMERC) //Proporcionaliza o valor do acrescimo baseando-se no valor da mercadoria
		SF2->(MsUnlock())
		nRecnoSF2 := SF2->( Recno() ) //Guarda posicao atual da SF2
		SF2->( DbSetOrder( 1 ) )
		If SF2->( DbSeek( xFilial( "SF2" ) + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
			//Atualiza NF de "Produto"
			RecLock("SF2",.F.)
			SF2->F2_VALACRS := nVlrAcreFin * (SF2->F2_VALMERC / SL1->L1_VALMERC) //Proporcionaliza o valor do acrescimo baseando-se no valor da mercadoria
			SF2->(MsUnlock())
			cEspecNf := Alltrim(SF2->F2_ESPECIE)
		EndIf
		SF2->( DbGoTo ( nRecnoSF2 ) ) //Retorna a posicao anterior da SF2
	Else
        cNumNota := SL1->L1_DOC
        cSerie   := SL1->L1_SERIE
		nRecnoSF2 := SF2->( Recno() ) //Guarda posicao atual da SF2
		SF2->( DbSetOrder( 1 ) )
		If SF2->( DbSeek( xFilial( "SF2" ) + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
			RecLock("SF2",.F.)
			SF2->F2_VALACRS := nVlrAcreFin + If(cPaisLoc=="ARG",MaFisRet( ,"NF_ACRESCI"),0)
			SF2->(MsUnlock())
		EndIf
		SF2->( DbGoTo ( nRecnoSF2 ) ) //Retorna a posicao anterior da SF2 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconta o Valor do ICMS DESONERADO do valor do Item D2_PRCVEN         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFtvdVer12 .AND. nDedICM > 0
		SF2->F2_VALMERC -= nDedICM
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera SF3 OnLine³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Permite que gere o livro aqui somente quando Brasil pois em ambiente localizado ( BOL,MEX,ARG ) ele gera
	//mais um de registro, o segundo eh igual o primeiro que foi gerado por GravaLivro neste fonte
	If lFisLivro .AND. cPaisLoc == "BRA"
		LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "SF2->F2_SERSAT", SF2->F2_SERSAT ) //Grava Log

		LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "SF2->(Recno())", SF2->(Recno()) )
		MaFisAtuSF3(1,"S",SF2->(Recno()),"SF2",NIL,NIL,cNomeProg,,,SF2->F2_SERSAT )
		SFT->(MsUnlock())
		
		MAFISCDA(,2)  //Gravacao dos lancamentos fiscais

        //---------------------------------------------------------
        // Atualiza dados dos complementos do SPED automaticamente
        //--------------------------------------------------------
        If SuperGetMV("MV_ATUCOMP",,.F.)
            AtuComp(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,SF2->F2_CLIENTE,SF2->F2_LOJA,"S",SF2->F2_TIPO)
        EndIf
		
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Pontuação ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaCrd

	SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) )
	While !SL2->( Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM
		cGrupoProd :=  Posicione("SB1",1, xFilial("SB1") + SL2->L2_PRODUTO,"SB1->B1_GRUPO")
		AADD ( aProdCri, { SL2->L2_PRODUTO, cGrupoProd , SL2->L2_VLRITEM , SL2->L2_QUANT })
		SL2->(DbSkip())
	End

	Crd240_002(	"1",;					// ok
				SL1->L1_CLIENTE,;	   	// ok
				SL1->L1_LOJA,;			// Ok
				aProdCri ,;				// Ok
				SL1->L1_VLRTOT,;     	// ok
				cNumNota,; 		  		// ok
				cSerie,;     			// ok
				Nil,;          			// ok
				Nil,;           		// ok
				"FRT",;					// ok
				.T. ,;           		// ok
				nTotPontos,;       		// ok
				cPgVc  ,;           	// ok
				.F. ,;               	// ok
				aPremio)				// ok

EndIf

//Nao atualizar por estar sendo executado no Totvs PDV
if !lNFePDV
	//Atualiza ultima compra, primeira compra e maior compra do cliente caso não seja cliente padrão.
	Lj7AtuaCli()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjcFid
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava recarga/inclusao de saldo em cartao  ³
	//³fidelidade nas tabelas MBP e MBN           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Obter dados da SL2
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusão do saldo do cartao fidelidade - Recarga³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM .AND. LaFunhProd (SL2->L2_PRODUTO)

		If !Empty(SL2->L2_NUMCFID) .AND. !Empty(SL2->L2_DTSDFID) .AND. (SL2->L2_VLRCFID > 0) .AND. SL2->L2_PROCFID == "B"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recarga do cartao fidelidade processada: ³
			//³B - Via processo batch (LJGRVBATCH)      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			lRetFid := Ca280Exec("CA280ISLD",SL2->L2_NUMCFID,SL2->L2_DTSDFID,SL2->L2_VLRCFID,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA)
			If ! lScreen
				If lRetFid
					ConOut("LJGrvBatch: "+ STR0153 + SL2->L2_NUMCFID) //"Incluído novo saldo para o cartão fidelidade "
				Else
					ConOut("LJGrvBatch: "+ STR0154 + SL2->L2_NUMCFID) //"Erro ao incluir novo saldo para o cartão fidelidade "
				Endif
			Endif
			Exit
		EndIf
		SL2->(DbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao do saldo do cartao fidelidade - Venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL4")
	DbSetOrder(1)
	DbSeek( xFilial( "SL4" ) + SL1->L1_NUM )
	While !Eof() .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recarga do cartao fidelidade processada: ³
		//³B - Via processo batch (LJGRVBATCH)      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SL4->L4_FORMA) == "FID" .AND. SL4->L4_PROCFID == "B" .AND. !Empty(SL4->L4_NUMCFID) .AND. (SL4->L4_VALOR > 0)
			lRetFid := Ca280Exec("Ca280ASld",SL4->L4_NUMCFID,,,	SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,,	SL4->L4_VALOR )
			If ! lScreen
				If lRetFid
					ConOut("LJGrvBatch: "+ STR0155 + SL2->L2_NUMCFID) //"Atualizado saldo para o cartão fidelidade "
				Else
					ConOut("LJGrvBatch: "+ STR0156 + SL2->L2_NUMCFID) //"Erro ao atualizar saldo do cartão fidelidade "
				Endif
			Endif
			Exit
		EndIf
		SL4->(DbSkip())
	End

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera patrocinio de desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjDespa
	LJ803SE1()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Verifica se o Siga Loja esta integrado com o Gestao Hospitalar                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV( "MV_LOJAHSP",, .F. )
	HS_ConfRAt( SL1->L1_NUM  , 	SL1->L1_VLRTOT, SL1->L1_ENTRADA, SL1->L1_DESCONT,;
				SL1->L1_SERIE, 	SL1->L1_DOC )
EndIf

If Empty(cSerieNF)
	cSerieNF := SL1->L1_SERIE
EndIf

If SL1->L1_TIPO $ "D|B"
	//Verifica se posicionado no cliente da venda
	If (SL1->L1_ClIENTE + SL1->L1_LOJA) <> (SA1->A1_COD + SA1->A1_LOJA) 
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(dbSeek(xFilial("SA1") + SL1->L1_ClIENTE + SL1->L1_LOJA))	  
	EndIf
	
	//Ajustei o Seek, estava fazendo Seek do CNPJ com base no código do cliente ? só funcionou se tinha código igual CNPJ	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))//A2_FILIAL+A2_CGC
	IF(SA2->(DbSeek(xFilial("SA2")+PADR(SA1->A1_CGC,TamSx3("A2_CGC")[1]))))
		cCodCli  := SA2->A2_COD
		cLojaCli :=	SA2->A2_LOJA	
	Endif
Else
	cCodCli  := SL1->L1_CLIENTE
	cLojaCli :=	SL1->L1_LOJA	
Endif
	
If lFaturar .And. !LjVerifGrv(cNumNota, cSerie, cCodCli, cLojaCli, cNumOrc)
	If !lPedFin
		Disarmtransaction()
		LjGravaLog( lScreen, cNumOrc, 'Ocorreu erro na verificacao - transacao cancelada', LMSTOP, LMPROC)
	EndIf
	Return .F.
EndIf

//Verifica se ha integracao com o Callcenter para atualização de orçamento
If !lScreen
	Lj7AtuaTMK()
EndIf

//----------------------------------------------------
//|Release 11.5 - Chile - Guia de Despacho - F2CHI   |
//|Atualizar dados da Factura na SL2 e na SL1		 |
//----------------------------------------------------
If lCFolChiR5 .AND. (cTpGeraGdp $ GDP_PARCIAL + ";" + GDP_TOTAL	)
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))
	If SL1->(DbSeek(xFilial("SL1") + cNumOrcPai))
		//-----------------------------
		//|Posiciona no primeiro filho|
		//-----------------------------
		SL1->(DbSkip())
		While !SL1->(Eof()) .AND. SL1->L1_FILIAL == xFilial("SL1") .AND. !Empty(SL1->L1_ORCRES) .AND. SL1->L1_ORCRES == cNumOrcPai
			//------------------------------------------------------------
			//|Para cada orcamento filho, atualizar dados do documento na|
			//|SL2 e SL1, quando o tipo de entrega do item nao for igual |
			//|a 1 no modo de gravacao de venda (nOPC==3)                |
			//------------------------------------------------------------
			DbSelectArea("SL2")
			SL2->(DbSetOrder(1))
			If SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
				While !SL2->(Eof()) .and. SL2->L2_FILIAL == xFilial("SL2") .and. SL2->L2_NUM == SL1->L1_NUM
					If !(SL2->L2_ENTREGA == "1"	.AND. nOpc == 3)
						RecLock ("SL1",.F.)
						If Empty(SL1->L1_DOC ) .OR. Empty(SL1->L1_SERIE)
							SL1->L1_DOC 	:= cNumNota
							SL1->L1_SERIE 	:= cSerie
							SL1->L1_SITUA	:= "OK"
							SL1->L1_OPERADO := xNumCaixa()
					   		If cHoraRMT == "3" .AND. cPaisLoc == "BRA"
								aArea2	:= GetArea()
								dbSelectArea("SM0")
								aAreaSM0	:= GetArea()
								dbSetOrder(1)
								If dbSeek(cEmpAnt+cFilAnt)
									aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
								EndIf
								RestArea(aAreaSM0)
								RestArea(aArea2)

								SL1->L1_EMISNF := STOD(aTimeUf[1])
							Else
								SL1->L1_EMISNF := dDataBase
							EndIf
						EndIf

						SL1->L1_IMPRIME	:= Iif(LjProFile(28),"4S","2S")
						SL1->L1_TIPO	:= "V"
						SL1->(MsUnlock())

						IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)

						RecLock ("SL2",.F.)
						SL2->L2_DOC 	:= SL1->L1_DOC
						SL2->L2_SERIE 	:= SL1->L1_SERIE
						SL2->(MsUnlock())
					EndIf
					SL2->(DbSkip())
				End
			EndIf
			SL1->(DbSkip())
		End
	EndIf
EndIf

//Garantia estendida
If !lIsVendaVP .And. !lIsVdRecCP .And. SuperGetMv("MV_LJFNGE",,.F.) .AND. (nOpc == 3 ) .And. ExistFunc("LJ7GrvMFI") .And. lGe
	LJ7GrvMFI(nOpc,{},cNumNota,cSerie,.F.)
EndIf

//Servico finaceiro
If !lIsVendaVP .And. !lIsVdRecCP .And. lSFinanc .AND. (nOpc == 3 ) .And. ExistFunc("LJ7GrvMFI") //.And. Len(aItensSFin) > 0
	LJ7GrvMFI(nOpc,{},cNumNota,cSerie,lSFinanc,cPrefSFA,cTitSFA)
EndIf

//Função responsavel pela gravação de campos na SD2 e SF2 para o PAF-ECF - Homologacao 2017
//Não deverá entrar na função quando não houver itens faturados, por esse motivo validamos a variavel lFaturar
If ExistFunc("STFMMd5NS") .AND. lFaturar
	STFMMd5NS()
EndIf

//Integracao Mensagem Unica e NFCe, atualiza informacoes de transmissao
//Tratamento NFe: para Totvs PDV poder excluir notas denegadas eh necessaio preencher os campos na SF3,
//os dados basicos necessarios estao no campo L1_RETSFZ
If (lIntegDef .or. lNFePDV) .And. AllTrim(SL1->L1_ESPECIE) $ "NFCE|SPED" .And. !Empty(SL1->L1_KEYNFCE) 
	aAreaSF3 := SF3->(GetArea())
	
	SF3->(DbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE				
	
	If SF3->(dbSeek(xFilial("SF3") + SL1->L1_DOC + SL1->L1_SERIE))
		While !Eof() .And. xFilial("SF3") 	== SL1->L1_FILIAL .And. SF3->F3_NFISCAL == SL1->L1_DOC .And. SF3->F3_SERIE == SL1->L1_SERIE
			SF3->(RecLock("SF3", .F.))
			SF3->F3_CODRSEF := "100"
			SF3->F3_DESCRET := STR0184 //#"Autorizado o uso da NF-e"
			SF3->F3_CODRET  := "M"
			SF3->F3_PROTOC  := SL1->L1_PRONFCE
			SF3->(MsUnlock())
			SF3->(dbSkip())
		EndDo	
	EndIf
	
	RestArea(aAreaSF3)	
EndIf

Return lRet

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³LjVerifErro ³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONA010                                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjVerifErro(e, cDescErro, lError)
Local lRet 			:= .F.

Default lError 		:= .F.

IF e <> Nil .AND. e:gencode > 0 

	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40), LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, "DESCRIPTION:" + e:DESCRIPTION, LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, "ERRORSTACK:" + e:ERRORSTACK, LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40), LMSTOP, LMPROC)

	lRet:=.T.
	cDescErro := "DESCRIPTION: " + e:DESCRIPTION + CTRL
    cDescErro += "ERRORSTACK:" + CTRL
    cDescErro += e:ERRORSTACK
    
    LjGrvLog(SL1->L1_NUM,"ERRO: ",cDescErro )
    
	Break
ElseIf lError
	LjGrvLog(SL1->L1_NUM,"Ocorreu algum erro denro da função LjGrvTran durante a gravação da venda/orçamento: " +  SL1->L1_NUM)
	Conout("Ocorreu algum erro denro da função LjGrvTran durante a gravação da venda/orçamento: " +  SL1->L1_NUM)
	Break
EndIf

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjGrvTpFin  ³ Autor ³ Vendas Clientes       ³ Data ³ 09/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina definira' como serao gerados os titulos: aglutinado ou ³±±
±±³          ³nao e contra quem sera gerado o titulo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGALOJA                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ LjGrvTpFin( ExpC1, ExpN1 )    								³±±
±±³			 ³ ExpC1 - identifica contra quem devera ser gerado o titulo:   ³±±
±±³			 ³    S -> Contra Adm. / N -> Contra Cliente                    ³±±
±±³			 ³ ExpN1 - Identifica se ira aglutinar as parcelas num unico    ³±±
±±³			 ³ lancamento no contas a receber : 1 -> Aglutina 2->N. Aglutina³±±
±±³			 ³   DEFAULT: 2 (Nao aglutina)            					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ aRet( ExpL1, ExpL2 )										    ³±±
±±³			 ³ ExpL1 - Se .F. aglutina, .T. nao aglutina					³±±
±±³			 ³ ExpL2 - Se .T. titulo contra administradora, .F. contra   	³±±
±±³			 ³ cliente														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjGrvTpFin( cFinPro, nAgluPar )
Local aRet 		:= {}	  			// Retorno da funcao
Local lRetFin	:= .F.				// Retorno da Administradora financeira
Local lRetAglu	:= .F.				// Retorno da Aglutinacao

If nAgluPar == 1
	lRetAglu := .T.
EndIf

If cFinPro == "S"
	lRetFin := .T.
EndIf

Aadd( aRet, lRetAglu )
Aadd( aRet, lRetFin )

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJCalcVencºAutor  ³Vendas Clientes     º Data ³  25/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o calculo da Data de Vencimento da parcela          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lFront  - Chamada a partir do FrontLoja.                   º±±
±±º          ³ dDtParc - Data atual da parcela a calcular.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ dSaeVencto - Data de Vencimento da parcela.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJCalcVenc(lFront, dDtParc, lScreen, dDataReceb,cDiaVen, nQtPrc)

Local dSaeDias		:= dDataBase		// Dias para vencimento conforme cadastro da Administradora (SAE)
Local dSaeVencto	:= dDataBase		// Data de vencimento conforme cadastro da Administradora (SAE)
Local nCountD		:= 0
Local dDiaEmi		:= CtoD(Space(08))
Local lFixaDia	:= .F.	//Variavel utilizada para controlar se deve fixar o dia da primeira parcela nas demais parcelas
Local lCpoFixSAE	:= SAE->(ColumnPos("AE_FIXADIA")) > 0
Local lCpoUtiSAE	:= SAE->(ColumnPos('AE_DIAUTIL')) > 0
Local lCpoDiaSAE	:= SAE->(ColumnPos('AE_DIAEMI')) > 0
Local lCalc			:= .T.				// usada no controle de calculo.Se AE_VENCTO e AE_DIAS = 0, então a data de vencimento será a data da parcela
Local dDtVencPar	:=  CtoD(Space(08)) //Data base da parcela
Local cMesSegPar	:= "" //mes Seguinte da Parcela
Local cMesVencto	:= "" //Mes do vencimento
Local cIdLog		:= "L1_NUM: " + SL1->L1_NUM
Local lDataReceb	:= .F.
Local lCpoPCorte	:= SAE->(ColumnPos("AE_PCORTE")) > 0		//Dias de Periodicidade do Corte
Local lCpoDCorte	:= SAE->(ColumnPos("AE_DCORTE")) > 0		//Dia Inicial do Corte

Default lFront		:= .F.				//Nao verifica se e financiamento proprio - Exclusivo Front Loja
Default lScreen		:= .F.
Default dDtParc		:= SL1->L1_EMISNF
Default cDiaVen		:= ""				//Variavel utilizada para fixar o dia da primeira parcela nas demais parcelas
Default dDataReceb	:= CtoD(Space(08))
Default nQtPrc 		:= 1				//Quantidade de Parcelas

// Por protecao pega a data de Emissao (e-commerce)
If Empty(dDtParc)
	dDtParc := SL1->L1_EMISSAO
EndIf
// trecho movido para depois da protecao acima , antes era na declaracao da variavel
dDiaEmi		:=    CtoD("30" + "/" + Strzero(Month(dDtParc),2) + "/" +;
							Right(Strzero(Year(dDtParc),4),2),"ddmmyy")

//-----------------------------------------------------------------------------------------------------------------------
//PRIORIDADE:																											
//AE_VENCTO - indica o DIA de vencimento do titulo. Se AE_DIAS(dia da virada do cartao) estiver preenchido e for		
// 	maior que AE_VENCTO, o sistema utiliza o valor do campo AE_VENCTO, porem o vencimento sera gerado para o proximo mes
//AE_DIAS - indica a quantidade de dias que sera somado a data de vencimento, caso AE_VENCTO = 0 						
//Se AE_VENCTO e AE_DIAS = 0, então a data de vencimento será a data da parcela.										
// Usada no controle de calculo. Se AE_VENCTO e AE_DIAS = 0, então a data de vencimento será a data da parcela
//-----------------------------------------------------------------------------------------------------------------------
If SAE->AE_DIAS == 0 .AND. !IsInCallStack("LJ7MultNeg") .And. !Empty(dDataReceb)	
	If SAE->AE_VENCTO == 0
		dSaeVencto := dDataReceb
		lCalc := .F.
	Else	
		lDataReceb := .T.
		LjGrvLog(cIdLog," Campo AE_VENCTO preenchido - Parcelas serão geradas todo mês no dia (se for um dia válido) :", SAE->AE_VENCTO)
	EndIf
EndIf

If lCalc  // se ainda nao calculou dSaeVencto

	//Para Adm. Fin. de Vales-Refeição, que tem um cálculo diferenciado para definir dia do Corte e dia do Vencimento
	If (lCpoPCorte .AND. lCpoDCorte) .AND. (SAE->AE_PCORTE > 1)
		If (SAE->AE_PCORTE = 7 .AND. SAE->AE_DCORTE<=7) .OR. SAE->AE_PCORTE > 7 
			//Função que retorna a data do próximo corte
			dDtParc := LjDCorte(dDtParc,SAE->AE_DCORTE,SAE->AE_PCORTE) //data do próximo corte
			LjGrvLog( cIdLog , "Resultado da Data do Corte: " , dDtParc )	
		EndIf
	EndIf		

	If Empty(SAE->AE_DIAS)
		If lCpoDiaSAE .And. SAE->AE_DIAEMI == '2'
			dSaeDias := dDiaEmi
		Else
			dSaeDias := dDtParc
		Endif
	Else
		If lCpoDiaSAE .AND. SAE->AE_DIAEMI == '2'
			dSaeDias := dDiaEmi
		Else
			dSaeDias :=	CtoD(Strzero(SAE->AE_DIAS,2) + "/" + Strzero(Month(dDtParc),2) + "/" +;
						Right(Strzero(Year(dDtParc),4),2),"ddmmyy")
		EndIf
	EndIf

	//Verifica se deve ficar o dia do primeiro vencimento para as demais parcelas
	If lCpoFixSAE
		If SAE->AE_FIXADIA == "2"		// 1=Nao; 2=Sim
			lFixaDia	:= .T.
			If !Empty(cDiaVen)
				dSaeDias	:= 	CtoD(Strzero(cDiaVen,2) + "/" + Strzero(Month(dSaeDias),2) + "/" +;
								Right(Strzero(Year(dSaeDias),4),2),"ddmmyy")
			EndIf
		Else
			lFixaDia	:= .F.
			cDiaVen		:= ""
		Endif
	Endif	

	If SAE->AE_VENCTO == 0
		If lCpoDiaSAE .And.SAE->AE_DIAEMI == '2'
			dDtVencPar :=  dDiaEmi
		Else
			dDtVencPar := dDtParc 
		Endif
		
		dSaeVencto := dDtVencPar + SAE->AE_DIAS

		//Verifica se deve ficar o dia do primeiro vencimento para as demais parcelas
		If lCpoFixSAE
			If SAE->AE_FIXADIA == "2"
				If Month(dDtVencPar) < 12
					cMesSegPar := StrZero(Year(dDtVencPar),4)+StrZero(Month(dDtVencPar)+1,2)
				Else
					cMesSegPar := StrZero(Year(dDtVencPar)+1,4)+"01"
					
				EndIf
				cMesVencto := Left(DtoS(dSaeVencto),6)
			
				lFixaDia	:= .T.
				If !Empty(cDiaVen)
					//Se a data for um dia fixo e o ultimo dia do mes seguinte do vencimento não coincidir com o dia de vencimento
					//da parcela, e a data de vencimento ultrapassou o mes seguinte, joga para o último dia do
					//mes seguinte
					//Exemplo : AE_DIAS = 30 e cDiaVen = 30 e dtVencPar = 31/01/2016, se somar a data vai dar 01/03/2016 e quando fixar  vai dar 30/03/16, pulando o mes
					//Exemplo2: AE_DIas = 31 e cDiaVen = 31 e DtVencPar = 31/03/2016, se somar a data vai dar 01/05/2016 e quando fixar vai dar 30/05/16, pulando o mes
					If Day(LastDay(StoD(cMesSegPar+"01")))  < cDiaVen .AND. cMesVencto > cMesSegPar  
						dSaeVencto := LastDay(StoD(cMesSegPar+"01"))
					Else
					
						dSaeVencto	:= 	CtoD(Strzero(cDiaVen,2) + "/" + Strzero(Month(dSaeVencto),2) + "/" +;
											Right(Strzero(Year(dSaeVencto),4),2),"ddmmyy")
					EndIf
				EndIf
			Else
				lFixaDia	:= .F.
				cDiaVen		:= ""
			Endif
		Endif
	Else
		/* Uso o dDataReceb pois ele tem o mes e o ano atualizado, 
		senão gera as parcelas todas com a mesma data (dDtParc) */
		If lDataReceb .And. (Month(dDataReceb) <> Month(dDtParc))
			dSaeVencto := CtoD(Strzero(SAE->AE_VENCTO,2) + "/" + Strzero(Month(dDataReceb),2) +;
						"/" + Right(Strzero(Year(dDataReceb),4),2),"ddmmyy")
			LjGrvLog(cIdLog," AE_VENCTO preenchido e dDataReceb(SL4) preenchido - portanto" +;
						" será usado o mês e ano da parcela gerada na tabela SL4",dSaeVencto)
		Else
			dSaeVencto := CtoD(Strzero(SAE->AE_VENCTO,2) + "/" + Strzero(Month(dDtParc),2) +;
						"/" + Right(Strzero(Year(dDtParc),4),2),"ddmmyy")
			LjGrvLog(cIdLog," AE_VENCTO preenchido porém as parcelas serão geradas "+ ;
						" todas pro mesmo mês - {Vencimento,Data Parcela}",{dSaeVencto,dDtParc})
		EndIf
	EndIf

	//Tratamento abaixo colocado para evitar data em branco, pois quando a venda possuia varias
	//Parcelas, quando chegava em 30 de fevereiro retornava em branco, pois nao existe
	If Empty(dSaeVencto)
		nCountD := Iif(Empty(SAE->AE_VENCTO),31,SAE->AE_VENCTO)
		If nCountD > 27 .AND. nCountD <= 31  	// O min de dias no mes eh de 28 dias e o max 31
			While nCountD > 27
				nCountD--
				If Empty(dSaeVencto)
					If lDataReceb
						dSaeVencto := CtoD(Strzero(nCountD,2) + "/" + Strzero(Month(dDataReceb),2) + "/" +;
									Right(Strzero(Year(dDataReceb),4),2),"ddmmyy")
					Else
						dSaeVencto := CtoD(Strzero(nCountD,2) + "/" + Strzero(Month(dDtParc),2) + "/" +;
									Right(Strzero(Year(dDtParc),4),2),"ddmmyy")
					EndIf
				EndIf
			End
		EndIf
	EndIf

	If !Empty(SAE->AE_VENCTO) .AND. ((dSaeVencto < dSaeDias) .OR. (dSaeVencto < dDtParc))
		dSaeVencto := 	CtoD(Strzero(SAE->AE_VENCTO,2)+ "/" +;
							Strzero(Month(LastDay(dSaeVencto)+1),2)	+ "/" +;
							Right(Strzero(Year(LastDay(dSaeVencto)+1),4),2), "ddmmyy")
	EndIf

EndIF

//-------------------------------------------------------------------
// Valida se a administradora financeira utiliza somente dias úteis
// para o vencimento de suas parcelas
// Ou se considera somente dias úteis na contagem do vencimento.
//-------------------------------------------------------------------
If AllTrim(SAE->AE_TIPO) $__FORMATEF .And. lCpoUtiSAE 
	If SAE->(ColumnPos("AE_TMPVCTO")) > 0 .AND. !Empty(SAE->AE_TMPVCTO) .AND. nQtPrc == 1 
		/*SAE->AE_TMPVCTO (qtde de dias úteis para vencimento, válido somente para uma parcela, ou seja, a vista) */
		dSaeVencto := LjCalVctDf (dSaeVencto)
	ElseIf SAE->AE_DIAUTIL == '2'
		dSaeVencto := DataValida( dSaeVencto, .T. )
	ElseIf SAE->AE_DIAUTIL == '3'
		dSaeVencto := DataValida( dSaeVencto, .F. )
	EndIf
EndIf


If lFixaDia	.AND. Empty(cDiaVen)
	cDiaVen := day(dSaeVencto) // Se configurado fixa o dia da primeira parcela
Endif

Return dSaeVencto

/*/{Protheus.doc} LjGrvLiq
Grava o valor liquido da venda em dinheiro  
@type  Function
@author Vendas Clientes
@since 13/04/07
@version version
@param nMoedaCor, numerico, código da moeda corrente do sistema
@return return, Nil
/*/
Function LjGrvLiq(nMoedaCor)
Local nTotPagto		:= 0						// Valor total pago nas formas de pagamento
Local lDinheiro		:= .F.						// Indica que existe parcela em dinheiro
Local nX 			:= 0						// Variavel do FOR
Local aArea			:= GetArea()				// Guarda a area atual
Local nSomaFormas	:= 0						// Guarda o valor de todas as formas de pagamento <> de R$
Local nVlDinheiro	:= 0						// Valor em dinheiro a ser gravado
Local lTroco        := .F.						// Determina se o troco esta habilitado
Local cCampo        := ""						// Nome dos campos referente ao troco em varias moedas
Local nVlrParcela	:= 0						// Valor da Parcela Arredondado
Local nVlrTroco		:= 0						// Troco Total
Local nMoedaParc    := 1						// Moeda da Parcela
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701")  //Nome da Rotina
Local nVlrTotal		:= 0						// Valor total da venda 				

DEFAULT nMoedaCor	:= 1						// Moeda corrente

If cPaisLoc == "BRA"
   lTroco  := SuperGetMV( "MV_LJTROCO", , .F. )
Else
   lTroco  := SuperGetMV( "MV_LJTRLOC", , .F. )
EndIf
LjGrvLog(," ljGrvLiq | Inicio " )
If SuperGetMV( "MV_LJTRDIN", , 0 ) > 0 .AND. (FunName() $ cNomeProg + " ; RPC")  .AND. lTroco 
	LjGrvLog(," ljGrvLiq | passo 02  " )
	If Type("aPgtos") == "A" 

		nVlrTotal := Lj7T_SubTotal(2)

		For nX := 1 to Len(aPgtos)
			If cPaisLoc <> "BRA"
				nMoedaParc  := aPgtos[nX][6]
			EndIf
			nVlrParcela	:= xMoeda( A410Arred(aPgtos[nX][2],"L4_VALOR"), nMoedaParc, nMoedaCor, dDatabase )
			nTotPagto	+= nVlrParcela
			If IsMoney(aPgtos[nX][3])
				lDinheiro    := .T.
				nVlDinheiro  += nVlrParcela
			ElseIf aPgtos[nX][1] == dDatabase
				nSomaFormas  += nVlrParcela
			EndIf
		Next nX

	Else 

		nVlrTotal := SL1->L1_VLRTOT

		DbSelectArea("SL4")
		SL4->(DbSetOrder(1))
		SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
		
		While !SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM
			nVlrParcela	:= xMoeda( A410Arred(SL4->L4_VALOR) , nMoedaParc, nMoedaCor, dDatabase )
			nTotPagto	+= nVlrParcela
			If IsMoney(SL4->L4_FORMA)
				lDinheiro    := .T.
				nVlDinheiro  += nVlrParcela
			ElseIf SL4->L4_DATA  == dDatabase
				nSomaFormas  += nVlrParcela
			EndIf
			SL4->(DbSkip())
		End		
		
	EndIf 

	For nX := 1 to MoedFin()
	   If nX == 1 .OR. cPaisLoc <> "BRA"
	      cCampo    := "L1_TROCO" + AllTrim( STR( nX ) )
	      If SL1->(FieldPos(cCampo)) > 0
		     nVlrTroco += xMoeda( SL1->&( cCampo ), nX, nMoedaCor, dDatabase )
		  EndIf
	   EndIf
	Next nX

	If nTotPagto > nVlrTotal .AND. lDinheiro

	    nVlDinheiro  := nVlDinheiro 	- nVlrTroco
	    nSomaFormas  := ( nSomaFormas 	+ nVlDinheiro )

		Begin TRANSACTION

		DbSelectArea("SL4")
		DbSetOrder(1)
		DbSeek(xFilial("SL4")+SL1->L1_NUM)
		While !Eof() .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM
		   If IsMoney( SL4->L4_FORMA )
		      RecLock("SL4", .F.)
	   		  cCampo  := "L1_TROCO" + AllTrim( STR( Max(SL4->L4_MOEDA,1) ) )
	   		  If SL1->(ColumnPos(cCampo)) > 0
			     REPLACE SL4->L4_VALOR WITH SL4->L4_VALOR - SL1->&( cCampo )
			  	 REPLACE SL4->L4_TROCO WITH  SL1->&( cCampo )	
			  EndIf
			  MsUnlock()
		   EndIf
		   DbSkip()
		End

		RecLock( "SL1", .F. )
		REPLACE SL1->L1_DINHEIR		WITH nVlDinheiro
		REPLACE SL1->L1_ENTRADA		WITH nSomaFormas

		For nX := 1 to MoedFin()
	       If nX == 1 .OR. cPaisLoc <> "BRA"
			   cCampo  := "L1_TROCO" + AllTrim( STR( nX ) )
			   If SL1->(FieldPos(cCampo)) > 0
			      REPLACE SL1->&( cCampo )	WITH 0
			   EndIf
		   EndIf
		Next nX
        MsUnLock()

		End TRANSACTION
    EndIf

EndIf

RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjxVerFretºAutor  ³  Vendas Clientes   º Data ³  27/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Identifica a versao do fonte para calculo do frete         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Versao do fonte 						 		              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxVerFret()
Local nRet := 0   	//	Armazena o controle da Versão do fonte para calculo do Frete

nRet := 20060927 	// 27 de Setembro de 2006

Return (nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjxTotItensºAutor  ³  Vendas Clientes   º Data ³  29/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o total dos itens                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum													   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Valor Total dos Itens					 		               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXFUNC                                                    º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxTotItens()
Local aArea 	:= GetArea()            // Armazena area atual (alias, order e recno)
Local nSomItens	:= 0					// Total de itens

DbSelectArea( "SL2" )
DbSetOrder( 1 )
DbSeek( xFilial( "SL2" ) + SL1->L1_NUM )

While !Eof() .AND. ( xFilial( "SL2" ) + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM )
	nSomItens += (SL2->L2_VRUNIT * SL2->L2_QUANT) - (SL2->L2_VALDESC + SL2->L2_DESCPRO)
	DbSkip()
End
RestArea(aArea)

Return (nSomItens)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjxPropItemºAutor  ³  Vendas Clientes   º Data ³  29/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna valor proporcional do para o item atual             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Numerico contendo valor total dos itens        	   º±±
±±º          ³ExpN2 - Numerico contendo os valores do frete                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Valor proporcional do frete de cada item		               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXFUNC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxPropItem(nSomItens, nValor,	lScreen, nDescProp, nAcresProp)

Local nValItem 		:= 0    // Valor do item
Local nVlProp 		:= 0	// Valor proporcional do item

Default lScreen		:= .T.  // Verifica se foi chamada pela LJGRVBATCH
Default nDescProp		:= 0	// Desconto proporcional do item
Default nAcresProp  	:= 0	// Acrescimo proporcional do item

//Quando e chamada pela LjGrvBatch a soma dos itens (nSomItens) ja esta considerando o desconto proporcional.
If !lScreen
	//Pega o Valor do Item ja calculado do PDV
	nValItem := SL2->L2_VLRITEM
Else
	nValItem := (SL2->L2_VRUNIT * SL2->L2_QUANT) - nDescProp + nAcresProp
EndIf

nVlProp  := (nValItem / nSomItens) * nValor

Return (nVlProp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjValcDoc ºAutor  ³Vendas Clientes     º Data ³  07/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cDoc de acordo com os caracteres lidos do ECF.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 -> Numero do documento com 9 digitos (string)     	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1 -> Numero do documento com 6 digitos (String)         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjValcDoc( cDoc )
Local cDocAtu	:= ""		// Retorno da funcao

If TamSX3("L1_DOC")[1] == 9
	cDocAtu := SubStr( cDoc, 4, Len( cDoc ) )
EndIf

Return( cDocAtu )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º  Funcao  ³LjAbatOrc ºAutor  ³ Vendas Clientes    º Data ³  31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³o abatimento foi total E este orcamento nao seja provenienteº±±
±±º          ³de uma reserva.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjAbatOrc()
Local lRetorno := .F.

If SL1->(FieldPos("L1_ABTOPCC")) > 0
	If (SL1->L1_ABTOPCC == SL1->L1_VLRLIQ)
		If SL1->(FieldPos("L1_ORCRES")) > 0
			If Empty(SL1->L1_ORCRES)
				lRetorno := .T.
			EndIf
		Else
			lRetorno := .T.
		EndIf
	Endif
EndIf

Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGetVlPreºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Captura o codido do vale presente que esta sendo vendido   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetVlPre( cProduto, cValeOri, nPosValePre, nValorVP )
Local lRet		:= .F.						// Variavel de retorno. Tela confirmada ou cancelada
Local oDlgVlPre								// Objeto Dialog
Local oGrp									// Objeto group
Local oLbProduto							// Objeto label "Produto"
Local oProduto								// Objeto get para o código do produto
Local oLbValePre							// Objeto label "Vale Presente"
Local oValePre								// Objeto get para o codigo do vale presente
Local oOk									// Botao Ok
Local oCancelar								// Botao Cancelar
Local cValePre	:= PadR(cValeOri,15)		// Variavel para o get Vale Presente
Local lMvLjPdvPa:= FindFunction("LjxBGetPaf").AND. LjxBGetPaf()[2] //Indica se e PDV

Default nPosValePre 	:= 0

//Define se utiliza Vale Presente
If !SuperGetMv("MV_LJVALEP", , .F.)
    LjxjMsgErr( I18n(STR0191, {"MV_LJVALEP"}), I18n(STR0192, {"MV_LJVALEP", ".T."}) )   //"Configure corretamente o parâmetro #1, para utilizar a funcionalidade de Vale Presente."     "Altere o conteúdo do parâmetro #1 para #2"
    Return lRet
EndIf

oDlgVlPre := MSDIALOG():Create()
oDlgVlPre:cName := "oDlgVlPre"
oDlgVlPre:cCaption := "Vale Presente"
oDlgVlPre:nLeft := 0
oDlgVlPre:nTop := 0
oDlgVlPre:nWidth := 290
oDlgVlPre:nHeight := 160
oDlgVlPre:lShowHint := .F.
oDlgVlPre:lCentered := .T.

oGrp := TGROUP():Create(oDlgVlPre)
oGrp:cName := "oGrp"
oGrp:nLeft := 10
oGrp:nTop := 10
oGrp:nWidth := 260
oGrp:nHeight := 78
oGrp:lShowHint := .F.
oGrp:lReadOnly := .F.
oGrp:Align := 0
oGrp:lVisibleControl := .T.

oLbProduto := TSAY():Create(oDlgVlPre)
oLbProduto:cName := "oLbProduto"
oLbProduto:cCaption := "Produto"
oLbProduto:nLeft := 22
oLbProduto:nTop := 23
oLbProduto:nWidth := 80
oLbProduto:nHeight := 17
oLbProduto:lShowHint := .F.
oLbProduto:lReadOnly := .F.
oLbProduto:Align := 0
oLbProduto:lVisibleControl := .T.
oLbProduto:lWordWrap := .F.
oLbProduto:lTransparent := .F.

oProduto := TGET():Create(oDlgVlPre)
oProduto:cF3 := "SB1"
oProduto:cName := "oProduto"
oProduto:nLeft := 133
oProduto:nTop := 22
oProduto:nWidth := 121
oProduto:nHeight := 21
oProduto:lShowHint := .F.
oProduto:lReadOnly := .F.
oProduto:Align := 0
oProduto:cVariable := "cProduto"
oProduto:bSetGet := {|u| If(PCount()>0,cProduto:=u,cProduto) }
oProduto:lVisibleControl := .T.
oProduto:lPassword := .F.
oProduto:lHasButton := .F.
oProduto:bWhen := {|| .F. }

oLbValePre := TSAY():Create(oDlgVlPre)
oLbValePre:cName := "oLbValePre"
oLbValePre:cCaption := "Vale Presente"
oLbValePre:nLeft := 22
oLbValePre:nTop := 55
oLbValePre:nWidth := 79
oLbValePre:nHeight := 17
oLbValePre:lShowHint := .F.
oLbValePre:lReadOnly := .F.
oLbValePre:Align := 0
oLbValePre:lVisibleControl := .T.
oLbValePre:lWordWrap := .F.
oLbValePre:lTransparent := .F.

oValePre := TGET():Create(oDlgVlPre)
oValePre:cName := "oValePre"
oValePre:nLeft := 133
oValePre:nTop := 54
oValePre:nWidth := 120
oValePre:nHeight := 21
oValePre:lShowHint := .F.
oValePre:lReadOnly := .F.
oValePre:Align := 0
oValePre:cVariable := "cValePre"
If nModulo <> 23 .AND. !lMvLjPdvPa // Frontloja e PAF ECF(PDV)
	// A variável MDD abrirá realmente a tabela de Vale Presente,
	// pois o MDD001 estava abrindo a tabela de modalidade de frete (aéreo/rodoviário).
	oValePre:cF3 := "MDD" //"MDD001"
	oValePre:bValid := {|| LjVldVlPre( cProduto, cValePre, Nil, 1, nPosValePre ) }
EndIf
oValePre:bSetGet := {|u| If(PCount()>0,cValePre:=u,cValePre) }
oValePre:lVisibleControl := .T.
oValePre:lPassword := .F.
oValePre:lHasButton := .F.

oOk := SBUTTON():Create(oDlgVlPre)
oOk:cName := "oOk"
oOk:cCaption := "Ok"
oOk:nLeft := 155
oOk:nTop := 95
oOk:nWidth := 52
oOk:nHeight := 22
oOk:lShowHint := .F.
oOk:lReadOnly := .F.
oOk:Align := 0
oOk:lVisibleControl := .T.
oOk:nType := 1
oOk:bAction := {|| If( LjVldVlPre( cProduto, cValePre, @nValorVP, 1, nPosValePre ), ( cValeOri := cValePre, lRet := .T., oDlgVlPre:End() ), NIL ) }

oCancelar := SBUTTON():Create(oDlgVlPre)
oCancelar:cName := "oCancelar"
oCancelar:cCaption := "Cancelar"
oCancelar:nLeft := 216
oCancelar:nTop := 95
oCancelar:nWidth := 52
oCancelar:nHeight := 22
oCancelar:lShowHint := .F.
oCancelar:lReadOnly := .F.
oCancelar:Align := 0
oCancelar:lVisibleControl := .T.
oCancelar:nType := 2
oCancelar:bAction := {|| oDlgVlPre:End() }

oDlgVlPre:Activate()

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldVlPreºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o codigo do vale presente digitado                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVldVlPre( cProduto, cValePre, nValor, nOper, nPosValePre )
Local oSvc					// WebService
Local lRet		:= .T.		// Variavel de retorno
Local cMsg		:= ""		// Mensagem de erro
Local nI        := 0
Local aAreaSL2  := {}
Local aArea     := {}
Local lMvLjPdvPa:= FindFunction("LjxBGetPaf").AND. LjxBGetPaf()[2] //Indica se e PDV

Default cProduto		:= ""
Default nValor			:= 0
Default nPosValePre 	:= 0

If nModulo == 23 .OR. lMvLjPdvPa
	oSvc      := WSFRTValePre():New()
	oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
	oSvc:oWSVALEPRE				:= FRTVALEPRE_WSVALEPRE():New()
	oSvc:oWSVALEPRE:cCODIGO		:= cValePre
	oSvc:oWSVALEPRE:cPRODUTO	:= cProduto
	oSvc:oWSVALEPRE:nVALOR		:= nValor
	oSvc:oWSVALEPRE:nOPERACAO	:= nOper

	lRet := oSvc:VldVale(nil,cEmpAnt,cFilAnt)

	If !lRet
		cMsg := STR0138+;//"A consulta do vale-presente não pode ser realizada. "
				STR0139+Chr(13)+Chr(13)+GetWSCError()//"Não será possível prosseguir com a venda deste item."
	Else
		cMsg := oSvc:cVLDVALERESULT
		oSvc      					:= WSFRTValePre():New()
		oSvc:_URL 					:= "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
		oSvc:oWSVALEPRE				:= FRTVALEPRE_WSVALEPRE():New()
		oSvc:oWSVALEPRE:cCODIGO		:= cValePre
		oSvc:oWSVALEPRE:cPRODUTO	:= cProduto
		oSvc:oWSVALEPRE:nVALOR		:= 0
		oSvc:oWSVALEPRE:nOPERACAO	:= 1	//1-Venda,2-Recebimento
		If oSvc:ValorVale(nil, cEmpAnt, cFilAnt)
			nValor := oSvc:nVALORVALERESULT			
		EndIf
	EndIf
Else
	cMsg := LjVldVP( cProduto, cValePre, @nValor, nOper )
EndIf

// Validar se o vale presente nao foi associado a outro item vendido
If Empty(cMsg)
	If nModulo == 23 //Front Loja

		aAreaSL2 := SL2->(GetArea())
		aArea    := GetArea()

		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		If SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
			While !SL2->(Eof()) .and. SL2->L2_FILIAL == xFilial("SL2") .and. SL2->L2_NUM == SL1->L1_NUM
				If SL2->L2_VALEPRE == cValePre
					cMsg := STR0140+cValePre+STR0141//"O Vale presente "#" já foi associado a outro item da venda corrente"
				Endif
				SL2->(DbSkip())
			End
		Endif
		RestArea(aAreaSL2)
		RestArea(aArea)

	Else //SIGALOJA
	   If Len(aColsDet) >= 1 
	      For nI := 1 to Len(aColsDet)
	          If nI <> n .and. !aCols[nI][Len(aCols[nI])] .and. aColsDet[nI][nPosValePre] == cValePre
	             cMsg :=STR0140+cValePre+STR0141 //"O Vale presente "#" já foi associado a outro item da venda corrente"
	          Endif
	      Next
	   Endif
	EndIf
Endif

If !Empty( cMsg )
	Aviso( STR0115, cMsg, {STR0103} )//"Atenção"#"Ok"
EndIf

Return Empty( cMsg )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldVP   ºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o codigo do vale presente digitado                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVldVP( cProduto, cValePre, nValor, nOper )
Local aArea	:= GetArea()		// Guarda a area anterior
Local cRet	:= ""				// Variavel de retorno

Default cValePre := "" 

MDD->( DbSetOrder(1) )
If MDD->( DbSeek( xFilial("MDD")+cValePre ) )
	If nOper == 1				//1=Venda / 2=Recebimento
		If MDD->MDD_PROD <> cProduto
			cRet := STR0118+Chr(13)+;	//"Este vale presente está relacionado a outro produto."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf MDD->MDD_STATUS == "2"
			cRet := STR0120+Chr(13)+;	//"Este vale presente já foi vendido."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf MDD->MDD_STATUS == "3"
			cRet := STR0121+Chr(13)+;	//"Este vale presente já foi vendido e recebido."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf MDD->MDD_STATUS == "4"
			cRet := STR0122+Chr(13)+;	//"Este vale presente está indisponível para venda."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf dDatabase < MDD->MDD_DTINI .OR. dDataBase > MDD->MDD_DTFIM
			cRet := STR0142+Chr(13)+;	//"Este vale presente está fora de vigência."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		EndIf
	Else
		If MDD->MDD_STATUS == "1"
			cRet := STR0123				//"Este vale presente ainda não foi vendido e, portanto, não pode ser recebido como forma de pagamento."
		ElseIf MDD->MDD_STATUS == "3"
			cRet := STR0124+Chr(13)+;	//"Este vale presente já foi recebido como forma de pagamento."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf MDD->MDD_STATUS == "4"
			cRet := STR0125+Chr(13)+;	//"Este vale presente está indisponível para uso."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		ElseIf dDatabase < MDD->MDD_DTINI .OR. dDataBase > MDD->MDD_DTFIM
			cRet := STR0142+Chr(13)+;	//"Este vale presente está fora de vigência."
					STR0119				//"Verifique o cadastro deste vale presente para mais informações."
		EndIf
	EndIf
	nValor := MDD->MDD_VALOR
Else
	cRet := STR0131		//"Número de vale presente inválido."
EndIf

RestArea( aArea )

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGrVVlPreºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a venda do vale presente na MDD                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrVVlPre( cValePre, cVend, cDoc , cEstacao,;
					 cPDV	 , dData, cHora, cCliente,;
					 cLoja 	 , cSerie )
Local oSvc			// objeto Web-Service
Local lMvLjPdvPa := FindFunction("LjxBGetPaf").AND. LjxBGetPaf()[2] //Indica se e PDV

Default cSerie := ""															// Serie do Documento

If nModulo == 23 .OR. lMvLjPdvPa	// FrontLoja ou PAF ECF(PDV)
	oSvc      := WSFRTValePre():New()
	oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
	oSvc:ccCodigo	:= cValePre
	oSvc:ccVend		:= cVend
	oSvc:ccDoc		:= cDoc
	oSvc:ccEstacao	:= cEstacao
	oSvc:ccPDV		:= cPDV
	oSvc:ddData		:= dData
	oSvc:ccHora		:= cHora
	oSvc:ccCliente	:= cCliente
	oSvc:ccLoja		:= cLoja
	oSvc:ccSerie	:= cSerie

	oSvc:UpdVenda( nil, nil, nil, nil,;	
					 nil, nil, nil, nil,;
					 nil, nil,cEmpAnt,cFilAnt) 
	Sleep(1000)
Else
	LjGrVVP( cValePre, cVend, cDoc , cEstacao,;
			 cPDV	 , dData, cHora, cCliente,;
			 cLoja 	 , cSerie)
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGrVVP   ºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a venda do vale presente na MDD                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrVVP( cValePre	, cVend, cDoc , cEstacao,;
				  cPDV		, dData, cHora, cCliente,;
				  cLoja 	, cSerie)

Local lLJVENVP			:= ExistBlock("LJVENVP")// Ponto de entrada apos a atualizacao da venda do VP
Local lFTVDVENVP		:= ExistBlock("FTVDVENVP")// Ponto de entrada apos a atualizacao da venda do VP
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nValorVP			:= 0 // Valor do Vale presente

Default cSerie := ""						// Serie do Documento

MDD->( DbSetOrder(1) )
If MDD->( DbSeek( xFilial("MDD")+cValePre ) )
	nValorVP := MDD->MDD_VALOR
	RecLock( "MDD", .F. )
	REPLACE MDD->MDD_VEND	WITH cVend
	REPLACE MDD->MDD_DOCV	WITH cDoc
	REPLACE MDD->MDD_SERIV	WITH cSerie
	REPLACE MDD->MDD_ESTV	WITH cEstacao
	REPLACE MDD->MDD_PDVV	WITH cPDV
	REPLACE MDD->MDD_DATAV	WITH dData
	REPLACE MDD->MDD_HORAV	WITH cHora
	REPLACE MDD->MDD_CLIV	WITH cCliente
	REPLACE MDD->MDD_LJCLIV	WITH cLoja
	REPLACE MDD->MDD_STATUS	WITH "2"
	REPLACE MDD->MDD_SALDO	WITH nValorVP
	MDD->( MsUnlock() )
	// Ponto de entrada apos a atualizacao da venda do VP
	If lLJVENVP .AND. !lFtvdVer12
		ExecBlock("LJVENVP",.F.,.F.)
	Endif

	If lFTVDVENVP .AND. lFtvdVer12
		ExecBlock("FTVDVENVP",.F.,.F.)
	Endif

EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGrRVlPreºAutor  ³ Vendas Clientes    º Data ³  31/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava o recebimento do vale presente na MDD                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrRVlPre( cValePre	, cCaixa , cDoc		, cEstacao,;
					 cPDV		, dData	 , cHora	, cCliente,;
					 cLoja 		, cSerie )

Local oSvc			// objeto Web-Service

Default cSerie := ""		// Serie do Doc

If nModulo == 23		// FrontLoja
	oSvc      := WSFRTValePre():New()
	oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
	oSvc:UpdRecebto( cValePre, cCaixa, cDoc , cEstacao,;
					 cPDV	 , dData , cHora, cCliente,;
					 					 cLoja	 , cSerie, cEmpAnt, cFilAnt ) 
Else
	LjGrRVP( cValePre , cCaixa  , cDoc	, cEstacao,;
			 cPDV	  , dData	, cHora	, cCliente,;
			 cLoja 	  , cSerie	)
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGrRVP   ºAutor  ³ Vendas Clientes    º Data ³  31/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava o recebimento do vale presente na MDD                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGrRVP( cValePre	, cCaixa, cDoc	, cEstacao,;
		 		  cPDV		, dData	, cHora	, cCliente,;
				  cLoja 	, cSerie, nValor)
Local cLojaR	:= ""				// Codigo da loja recebedora
Default nValor	:= 0

SLJ->( DbSetOrder(3) )
If SLJ->( DbSeek(xFilial("SLJ")+SM0->M0_CODIGO+FWGETCODFILIAL) )
	cLojaR := SLJ->LJ_CODIGO
EndIf

MDD->( DbSetOrder(1) )
If MDD->( DbSeek( xFilial("MDD")+cValePre ) )
	RecLock( "MDD", .F. )
	REPLACE MDD->MDD_CAIXA	WITH cCaixa
	REPLACE MDD->MDD_LOJAR	WITH cLojaR
	REPLACE MDD->MDD_DOCR	WITH cDoc
	REPLACE MDD->MDD_SERIR	WITH cSerie
	REPLACE MDD->MDD_ESTR	WITH cEstacao
	REPLACE MDD->MDD_PDVR	WITH cPDV
	REPLACE MDD->MDD_DATAR	WITH dData
	REPLACE MDD->MDD_HORAR	WITH cHora
	REPLACE MDD->MDD_CLIR	WITH cCliente
	REPLACE MDD->MDD_LJCLIR	WITH cLoja
	REPLACE MDD->MDD_STATUS	WITH "3"
	
	If SuperGetMv("MV_LJBXPAR",,.F.) .And. nValor > 0 .And. MDD->(ColumnPos("MDD_SALDO" )) > 0
		MDD->MDD_SALDO := MDD->MDD_SALDO - nValor
		If MDD->MDD_SALDO > 0
			REPLACE MDD->MDD_STATUS	WITH "5" // Vale Presente Ulitizado
		EndIf
	Else
		REPLACE MDD->MDD_SALDO	WITH 0
	EndIf

	MDD->( MsUnlock() )
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ljGrvJob  ºAutor  ³ Vendas Clientes    º Data ³  15/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job para gravacao da venda assistida			              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ljGrvJob( cEmp, cFilTrab , cNum )
Local aFiles							// Arquivos
Local lRetValue  := .T.            		// Retorno da função
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() 		//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

	ConOut("            "+STR0021)  //"Iniciando processo de gravacao batch..."
	RPCSetType(3)  // Nao comer licensa
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "MAL", "SLI", "SL1", "SL2", "SL4", "SA1", "SA2", "SA3", "SA6", "SAE",;
	"SB1", "SB2", "SB3", "SC7", "SE1", "SE3", "SE4", "SE5", "SE8", "SED", "SEF", "SES", "SD1", "SD2", "SF1", "SF2",;
	"SF3", "SF4", "SF7", "SFC", "SM2", "MAH"


	ConOut("            "+STR0133)  //"Ambiente preparado....."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todos os arquivos devem ser abertos antes de entrar no Begin Transaction.    ³
	//³Caso exista customizacao, os arquivos devem ser abertos neste PE.            ³
	//³OBS: O ADSSERVER nao permite uso da ChkFile() dentro de um Begin Transaction.³
	//³Em outros ambientes, este problema nao ocorre.                               ³
	//³Retornar um array, por exemplo {"SZ1", "SZ2"}                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJGRVOPEN") .AND. !lFtvdVer12
		aFiles := ExecBlock("LJGRVOPEN", .F., .F.)
		RPCOpenTables(aFiles)
	EndIf

	If ExistBlock("FTVDGRVOPEN") .AND. lFtvdVer12
		aFiles := ExecBlock("FTVDGRVOPEN", .F., .F.)
		RPCOpenTables(aFiles)
	EndIf

	dbSelectArea("SL1")
	DbSetOrder(1)

	dbSeek(xFilial("SL1") + cNum)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Protejo situação de todos os orcamentos "RX" estarem em aBadRecno, neste    ³
	//³ caso não devo processar o proximo (que eh eof), mas sim abandonar o Loop    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SL1->L1_SITUA <> 'RX'
		ConOut("            "+STR0134 + SL1->L1_NUM)  //"Numero"
		ConOut("            "+STR0135 + SL1->L1_SITUA)  //"Situacao"
		ConOut("            "+STR0136)  //"nao encontrou o orcamento...."
		Return .T.
	EndIf

	If LjGrvTudo(.F.)
		FRTProcSZ()
	Else
		ConOut("LJGrvBatch: "+ STR0079 + cFilTrab + ". "+STR0022) // "Filial " ### ". " "Ocorreu algum erro no processo de gravacao batch..."
		AADD(aBadRecno, SL1->(Recno()) )
	EndIf

	RESET ENVIRONMENT

	ConOut("            "+STR0075 + cEmp + STR0076 + cFilTrab+" - "+STR0024) //""Empresa:" ### " Filial: - Processo de gravacao batch finalizado..."

Return ( lRetValue )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVPValor ºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o valor de face do vale presente.                  º±±
±±º          ³ Chamado via WEBSERVICE                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVPValor( cValePre )

Local aArea	:= GetArea()		// Guarda a area anterior
Local nRet	:= 0				// Variavel de retorno

MDD->( DbSetOrder(1) )
If MDD->( DbSeek( xFilial("MDD")+cValePre ) )
	If SuperGetMv("MV_LJBXPAR",,.F.) .And. MDD->(ColumnPos("MDD_SALDO")) > 0
		nRet := MDD->MDD_SALDO
	Else
		nRet := MDD->MDD_VALOR
	EndIf
EndIf

RestArea( aArea )

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVPValor ºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que busca os orcamentos que foram importados        ³±±
±±³ 	 	 ³ e que ja estão finalizados.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxCDelArq(cOrcamento, lValidRet)

Local aOrcsImp 		:= {}
Local nPosOrcam 	:= 0
Local nX			:= 0
Local aArea     	:= GetArea()         //Area atual
Local aAreaSL2  	:= SL2->(GetArea())  //Area do SL2
Local lFieldNOrig	:= SL2->(FieldPos("L2_NUMORIG")) > 0

Default cOrcamento 	:= ""
Default lValidRet   := .F. //Validar arquivo .RET na Retaguarda

DbSelectArea("SL2")
DbSetOrder(1)
If DbSeek(xFilial("SL2") + cOrcamento) .AND. lFieldNOrig
   While !Eof() .AND. cFilAnt + cOrcamento == SL2->L2_FILIAL + SL2->L2_NUM

      If !Empty(SL2->L2_NUMORIG)
	      nPosOrcam := Ascan( aOrcsImp , { |x| Alltrim( x[1] ) == Alltrim( SL2->L2_NUMORIG ) } )

	      If nPosOrcam == 0
	         AADD(aOrcsImp, { SL2->L2_NUMORIG , SL2->L2_PDV })
	      EndIf
	  EndIf

      DbSkip()
   End
EndIf

If Len(aOrcsImp) > 0

	For nX := 1 To Len(aOrcsImp)
		If !lValidRet
    		If File( "\AUTOCOM\IMP" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") + "\" + aOrcsImp[nX][1] + ".TXT" )
    			FErase("\AUTOCOM\IMP" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") + "\" + aOrcsImp[nX][1] + ".TXT")
    		EndIf
        EndIf
		
		If File( "\AUTOCOM\IMP" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") + "\" + aOrcsImp[nX][1] + ".RET" )
            FErase("\AUTOCOM\IMP" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") + "\" + aOrcsImp[nX][1] + ".RET")
        EndIf
	Next nX                                        

EndIf

RestArea(aAreaSL2)
RestArea(aArea)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjVerPedErro³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONA010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjVerPedErro(e, lProcessou, cFilSL1, nRecnoSL1)

Local lRet 		    := .F.

Default lProcessou 	:= .T.
Default cFilSL1		:= ""
Default nRecnoSL1 	:= 0

If e:gencode > 0

    lRet :=.T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta a transacao em caso de algum ero na L7pedido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If InTransact()
		DisarmTransaction()
	EndIf

    DbSelectArea("SL1")
    SL1->( DbGoTo(nRecnoSL1) )

	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40)             , LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, "DESCRIPTION: " + e:DESCRIPTION, LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, "ERRORSTACK: " + e:ERRORSTACK  , LMSTOP, LMPROC)
	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40)             , LMSTOP, LMPROC)

    LjGravaErr(e:DESCRIPTION + CRLF + e:ERRORSTACK)
    Conout("LJGrvBatch: " + e:DESCRIPTION + CRLF + e:ERRORSTACK)

	__QUIT()
EndIf

Return NIL

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  LjEstVP   ³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a venda foi paga com Vale Presete e estorna o mesmo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Front Loja                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjEstVP(aValePre)

Local lRet		:= .F.							// Retorno do WebService
Local oSvc										// Objeto do WebService
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia conexao com o WebService para consulta de NCCs abertas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc      := WSFRTValePre():New()
oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o array dentro do metodo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc:oWSaVPreEst:OWSVERARRAY 					:= FRTValePre_ARRAYOFWSVPreEst():New()
oSvc:oWSaVPreEst:OWSVERARRAY:OWSWSVPreEst 		:= Array( Len(aValePre) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Antes de chamar o metodo, atribui os valores as propriedades (passagem de parametros)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aValePre)
	oSvc:oWSaVPreEst:OWSVERARRAY:OWSWSVPreEst[nX] 			:= FRTValePre_WSVPreEst():New()
	oSvc:oWSaVPreEst:OWSVERARRAY:OWSWSVPreEst[nX]:CCCODIGO	:=	aValePre[nX][1]
	oSvc:oWSaVPreEst:OWSVERARRAY:OWSWSVPreEst[nX]:CCOPERACAO:=	aValePre[nX][2]
Next nX

//"Aguarde...Estornando o Vale Presente"
LJMsgRun( STR0143,, { || lRet := oSvc:VPEstorna(nil,cEmpAnt, cFilAnt) } ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a operacao WebService foi realizada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	cSvcError := GetWSCError()
	If Left(cSvcError,9) == "WSCERR048"
		cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
		cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
		Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
	Else
		//"Sem comunicação com o WebService!"+"Atencao"
		MsgStop( STR0144,STR0082)
	EndIf
EndIf

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LjxConfIcm ³ Autor ³ Vendas Clientes       ³ Data ³ 22/03/10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o calculo do ICMS deacordo com a impressora fiscal      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Front Loja                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjxConfIcm( nItem 	 , nTotItem , dDatRef , cPdv ,;
							cCodProd , lStatusImp13)

Local nAliqProd := MaFisRet( nItem ,"IT_ALIQICM")
Local nIcmProd	:= MaFisRet( nItem ,"IT_VALICM")
Local cCpoBas	:= "MDS_BA"
Local nBasMDS	:= 0
Local nValAual	:= 0
Local nDifIcm	:= 0
Local nAliqRed	:= 0
Local nPosPont	:= 0
Local nAliqNew	:= 0
Local nValEcfIcm:= 0

Default nTotItem 	:= 0
Default lStatusImp13:= .F.

If nAliqProd > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca se existe aliquota reduzida³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAliqRed := LjxRetAliq(cCodProd)
	If nAliqRed > 0
		nAliqProd := nAliqRed
	EndIf

	nPosPont := AT(".",AllTrim(Str(nAliqProd)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o campo que sera verificado de acordo com a aliquota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosPont > 0
		nAliqNew := Val(SubStr(AllTrim(Str(nAliqProd)) ,1, nPosPont -1 ))
	Else
		nAliqNew := nAliqProd
	EndIf

	If nAliqNew  >= 10
		cCpoBas := cCpoBas+ PadR(StrTran(AllTrim(Str(nAliqProd)),".",""),4,"0")
	Else
		cCpoBas := cCpoBas+ "0"+ PadR(StrTran(AllTrim(Str(nAliqProd)),".",""),3,"0")
	Endif

	If MDS->(FieldPos(cCpoBas) ) > 0
		DbSelectArea("MDS")
		DbSetOrder(1)
		If DbSeek(xFilial("MDS") + DTOS(dDatRef) + cPdv )

	        nBasMDS := MDS->(&cCpoBas)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe diferenca com o que foi vendido  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lStatusImp13	// Verificacao do ECF para o arredondamento PE FRTECF13
		        //////////////////////////////////////////////////////////////////////////////////////
		        //A rotina LjxDRound verifica se o modelo da impressora é BEMATECH 4000 ou 4200.	//
		        //Se verdadeiro, efetua o arredondamento de acordo com a regra da impressora e      // 
		        //baseando-se na norma ABNT, caso contrario, efetua o arredondamento padrão			//
		        //////////////////////////////////////////////////////////////////////////////////////
		        nValAual	:= LjxDRound((nBasMDS) * (nAliqProd / 100),nDecimais)
		        nValEcfIcm	:= LjxDRound((nBasMDS + nTotItem) * (nAliqProd / 100),nDecimais)
		    Else
		        nValAual	:= NoRound( (nBasMDS) * (nAliqProd/100) , nDecimais )
		        nValEcfIcm	:= NoRound( (nBasMDS+nTotItem) * (nAliqProd/100) , nDecimais )
	        Endif
			nDifIcm     := (nValAual + nIcmProd ) - nValEcfIcm
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O Intuito da funcao eh diferenca de arredondamento, valores maiores que 0.02 nao devem ser considerados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Abs(nDifIcm) <= 0.02
				If nDifIcm > 0
					MaFisAlt("IT_VALICM", nIcmProd - nDifIcm, nItem)
				ElseIf nDifIcm < 0
					MaFisAlt("IT_VALICM", nIcmProd + Abs(nDifIcm), nItem)
				EndIf
				
				//Se possui aliquota reduzida ajusto a base.
				If nAliqRed > 0
					MaFisAlt("IT_BASEICM", (MaFisRet(nItem, "IT_VALICM") / MaFisRet(nItem, "IT_ALIQICM") * 100), nItem)
				Endif
			EndIf

	    	RecLock("MDS",.F.)
       	    REPLACE &(cCpoBas)		WITH MDS->(&cCpoBas)+ nTotItem
		    MDS->(MsUnlock())
    	Else
	    	RecLock("MDS",.T.)
	        REPLACE MDS_FILIAL	WITH xFilial("MDS")
   	        REPLACE MDS_DATA	WITH dDatRef
	        REPLACE MDS_PDV		WITH cPdv
   	        REPLACE &(cCpoBas)	WITH nTotItem
		    MDS->(MsUnlock())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a mesma verificacao quando for o primeiro item dessa tributacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lStatusImp13	 // Verificacao do ECF para o arredondamento PE FRTECF13
		        nValEcfIcm	:= Round( nTotItem * (nAliqProd/100) , nDecimais )
		    Else
		        nValEcfIcm	:= NoRound( nTotItem * (nAliqProd/100) , nDecimais )
		    EndIf
			nDifIcm     := nIcmProd - nValEcfIcm
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O Intuito da funcao eh diferenca de arredondamento, valores maiores que 0.02 nao devem ser considerados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Abs(nDifIcm) <= 0.02
				If nDifIcm > 0
					MaFisAlt("IT_VALICM", nIcmProd - nDifIcm, nItem)
				ElseIf nDifIcm < 0
					MaFisAlt("IT_VALICM", nIcmProd + Abs(nDifIcm), nItem)
				EndIf
				
				//Se possui aliquota reduzida ajusto a base.
				If nAliqRed > 0
					MaFisAlt("IT_BASEICM", (MaFisRet(nItem, "IT_VALICM") / MaFisRet(nItem, "IT_ALIQICM") * 100), nItem)
				Endif
			EndIf
	    EndIf
	EndIf
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxRetAliq³ Autor ³ Vendas Clientes       ³ Data ³22/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca no arquivo SB0 se o produto tem aliquota reduzida    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjxRetAliq(cProd)

Local nRet	:= 0

Default cProd 		:= ""

DbSelectArea("SB0")
DbSetOrder(1)
If DbSeek(xFilial("SB0")+ cProd)
	nRet := SB0->B0_ALIQRED
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjCriaOS      ºAutor³ Vendas CRM        º Data ³  18/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a OS para entrega e montagem dos produtos informados    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNumOS: Character por referência que conterá o número da OS  º±±
±±º          ³         criado.                                              º±±
±±º          ³ cCliente: Cliente da OS.                                     º±±
±±º          ³ cLoja: Loja do cliente da OS.                                º±±
±±º          ³ cCondPag: Condição de pagamento que é obrigatório na OS.     º±±
±±º          ³ cNumLoj: Número do orçamento responsável pela OS.            º±±
±±º          ³ aOSInfo: N produtos sendo:                                   º±±
±±º          ³          aOSInfo[n,1]: Código do produto.                    º±±
±±º          ³          aOSInfo[n,2]: Número de série do produto.           º±±
±±º          ³          aOSInfo[n,3]: Código do serviço a ser executado.    º±±
±±º          ³          aOSInfo[n,4]: Código do contato que receberá o      º±±
±±º          ³                        serviço.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Se a OS foi criada ou não.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                    	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCriaOS( cNumOS, cCliente, cLoja, cCondPag, cNumLoj, aOSInfo, cErro )

	Local aCab			:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local nCount		:= 0
	Local lRetorno		:= .F.
	Local lGE		  	:= LjUP104OK() 								// Validação do Conceito Garantia Estendida
	Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE")			// Define se é tipo GE
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) 
	Private lAutoErrNoFile	:= .F.
	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.


	aCab :=	 {										;
				{ "AB6_CODCLI"	, cCliente	, Nil }	,;
				{ "AB6_LOJA"	, cLoja		, Nil }	,;
				{ "AB6_EMISSA"	, Date()	, Nil }	,;
				{ "AB6_ATEND" 	, cUserName	, Nil }	,;
				{ "AB6_CONPAG"	, cCondPag	, Nil }	,;
				{ "AB6_HORA"  	, Time()	, Nil }	,;
				{ "AB6_NUMLOJ"	, cNumLoj	, Nil }	;
			}

	For nCount := 1 To Len( aOSInfo )

	    If !lGE .Or. (lGE .And. (SB1->(DbSeek(xFilial("SB1")+aOSInfo[nCount][1])) .And. SB1->B1_TIPO<>cMvLjTGar))          // Garantia Estendida   //Garantia estendida configurada na retaguarda?

						aItem	:=	{															;
						{"AB7_ITEM"		, StrZero( nCount, 2 )	, Nil }	,;
						{"AB7_TIPO"		, "1"					, Nil }	,;
						{"AB7_CODPRO"	, aOSInfo[nCount][1]	, Nil }	,;
						{"AB7_NUMSER"	, aOSInfo[nCount][2]	, Nil }	,;
						{"AB7_CODPRB"	, aOSInfo[nCount][3]	, Nil }	,;
						{"AB7_CODCON"	, aOSInfo[nCount][4]	, Nil }	;
					}
			aAdd( aItens, aItem )
		EndIf
	Next

	TECA450(,aCab,aItens,,3)

	If !lMsErroAuto
		cNumOS := AB6->AB6_NUMOS
		lRetorno := .T.
		ConfirmSX8()
	Else
		RollBackSx8()
		cErro := MostraErro(IIF( lAutomato .or. IsBlind(), "\", ""))
		LjGrvLog( SL1->L1_NUM , "Problemas na Criação da OS" + CRLF + cErro)
	EndIf


Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjProIntVe  ³ Autor ³ Vendas Clientes       ³ Data ³ 14/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina chama metodo para processar integracao de venda        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjProIntVe()

Local lGerInt    := SuperGetMv("MV_LJGRINT",.F.,.F.) // se tem integracao ou nao

If lGerInt .And. ValType(oIntVenda) == "O"

	LjAdicInt(oIntVenda)

	oIntVenda:Gerar()
	oIntVenda:Finalizar()
	oIntVenda := Nil
EndIf

Return(NIL)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjAdicInt   ³ Autor ³ Vendas Clientes       ³ Data ³ 28/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Buscar os creditos utilizado na venda (SE1) para integracao   ³±±
±±³			 ³Buscar os itens cancelados da venda (SLX) para integracao   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJXFUNC	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjAdicInt(oIntegracao)

Local aArea		:= {}							//Guarda a area atual
Local aAreaSE1 	:= {}							//Guarda a area do SE1
Local aAreaSLX 	:= {}							//Guarda a area do SLX
Local cChave 	:= ""							//Chave

aArea 		:= GetArea()
aAreaSE1 	:= SE1->(GetArea())
aAreaSLX 	:= SLX->(GetArea())

//Creditos utilizados na venda
cChave := xFilial("SE1") + SL1->L1_SERIE + SL1->L1_DOC

DbSelectArea("SE1")

DbSetOrder(1)	//E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

If DbSeek(cChave)

	While !Eof() .AND. (cChave) == (SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM)
		If AllTrim(SE1->E1_TIPO) == "CR"
			oIntegracao:Inserir("SE1", xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "1", "3")
		EndIf
		SE1->(DbSkip())
	End
EndIf

//Itens cancelados na venda
cChave := xFilial("SLX") + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE

DbSelectArea("SLX")

DbSetOrder(1)	//LX_FILIAL + LX_PDV + LX_CUPOM + LX_SERIE + LX_ITEM + LX_HORA

If DbSeek(cChave)

	While !Eof() .AND. (cChave) == (SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE)
		If AllTrim(SLX->LX_TPCANC) == "I"
			oIntegracao:Inserir("SLX", xFilial("SLX") + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE + SLX->LX_ITEM + SLX->LX_HORA, "1", "3")
		EndIf
		SLX->(DbSkip())
	End
EndIf

RestArea(aArea)
RestArea(aAreaSE1)
RestArea(aAreaSLX)

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjFilSX5 ºAutor  ³ Wilson A. Silva Jr º Data ³  20/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao criada para quando Tabela "01" do SX5 for exclusiva,º±±
±±º          ³ porem a SX5 compartilhada, centraliza Ponto de Entrada.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fontes do Loja                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjFilSX5()

Local aArea 		:= GetArea()
Local cFilSx5		:= xFilial("SX5")			// SX5
Local __lChgX5FIL   := ExistBlock("CHGX5FIL")	// Ponto de Entrada

If __lChgX5FIL
	cFilSx5 := ExecBlock("CHGX5FIL",.F.,.F.)
EndIf

RestArea(aArea)

Return cFilSx5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVlAcrFinºAutor  ³ Vendas  CRM		 º Data ³  11/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o total de acrescimos (Juros+Acrescimos Financeiros)º±±
±±º			 ³gravadsos na SD2.     									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Retorno Total de Acrescimos da Venda         	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja/FrontLoja		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjVlAcrFin ()
Local nVlrAcrs 	:= 0  		//Valor de acrescimo
Local nMoedaCor	:= 1		//Moeda Corrente
Local aAreaSD2 	:= SD2->(GetArea())

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek (xFilial("SD2")+SL1->L1_DOC+SL1->L1_SERIE+SL1->L1_CLIENTE)

While !SD2->(Eof()) .AND. SD2->D2_DOC==SL1->L1_DOC .AND. SD2->D2_SERIE==SL1->L1_SERIE .AND. SD2->D2_CLIENTE==SL1->L1_CLIENTE
	If SuperGetMv("MV_ARREFAT") == "S"
		nVlrAcrs+= Round(D2_VALACRS,MsDecimais(nMoedaCor))
	Else
		nVlrAcrs += NoRound(D2_VALACRS,MsDecimais(nMoedaCor))
	EndIf
	SD2->(DbSkip())
End
EndIf
SD2->(RestArea(aAreaSD2))
Return nVlrAcrs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjAddBrkNF    ºAutor³ Vendas CRM        º Data ³  14/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acertar o array aBreakNota com as facturas que serao		    º±±
±±º		     ³ impressas a partir da venda									º±±
±±º		     ³ Release 11.5 - Localizacoes - F2CHI							º±±
±±º		     ³ Paises: Chile/Colombia 										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1 - Array com as Facturas que serao impressas			º±±
±±³			 ³ ExpA2 - Array com os itens da factura 						º±±
±±³			 ³ ExpC3 - Tipo de Entrega				    				  	º±±
±±³			 ³ ExpC4 - Numero da Factura			    				  	º±±
±±³			 ³ ExpC5 - Serie da Factura			    				  		º±±
±±³			 ³ ExpC6 - Tipo geracao da Guia de Despacho (Chile)				º±±
±±³			 ³ ExpN7 - Tipo de Operacao 									º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL								                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA/SIGAFRT                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjAddBrkNF (aBreakNota	,aItens		,cEntrega	,cNumNota,;
					cSerie		,cTpGeraGdp	,nOpc)

Default aBreakNota 	:= {}
Default aItens			:= {}
Default cEntrega		:= {}
Default cNumNota		:= ""
Default cSerie			:= ""
Default cTpGeraGdp 	:= GDP_NO
Default nOpc			:= 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar quebra de impressao da venda em +  ³
//³de uma factura de acordo com  tipo de entrega³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cPaisLoc == "CHI"
		If (nModulo == 12 .AND. !(cTpGeraGdp == GDP_PARCIAL .AND. cEntrega == "1" .AND. nOpc == 3)) .OR.;
			(nModulo == 23 .AND. cEntrega <> "1")
			If (AScan(aBreakNota,{|x| x[1] == cNumNota .AND. x[2] == cSerie})) == 0
				Aadd(aBreakNota,{cNumNota,cSerie,{}})
				aItens		:= {}
			EndIf
		EndIf
	Case cPaisLoc == "COL"
		If (nModulo == 12 .AND. !(cEntrega $ "1|3" .AND. nOpc == 3)) .OR.;
			(nModulo == 23 .AND. !(cEntrega $ "1|3"))
			If (AScan(aBreakNota,{|x| x[1] == cNumNota .AND. x[2] == cSerie})) == 0
				Aadd(aBreakNota,{cNumNota,cSerie,{}})
				aItens		:= {}
			EndIf
		EndIf
EndCase


Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjAddBrkIt    ºAutor³ Vendas CRM        º Data ³  14/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acertar os arrays aBreakNota e aItens com as facturas que    º±±
±±º		     ³ serao impressas e seus respectivos itens 					º±±
±±º		     ³ Release 11.5 - Localizacoes - F2CHI							º±±
±±º		     ³ Paises: Chile/Colombia 										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1 - Array com as Facturas que serao impressas			º±±
±±³			 ³ ExpA2 - Array com os itens da factura 						º±±
±±³			 ³ ExpC3 - Tipo de Entrega				    				  	º±±
±±³			 ³ ExpC4 - Numero da Factura			    				  	º±±
±±³			 ³ ExpC5 - Serie da Factura			    				  		º±±
±±³			 ³ ExpN6 - Numero do RECNO no item na SL2						º±±
±±³			 ³ ExpC7 - Tipo de geracao da Guia de Despacho (Chile)			º±±
±±³			 ³ ExpC8 - Tipo de operacao										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL								                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA/SIGAFRT                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjAddBrkIt (aBreakNota	,aItens		,cEntrega	,cNumNota,;
					cSerie		,nRecNoSL2	,cTpGeraGdp	,nOpc)

Local nPosBreak		:= 0

Default aBreakNota 	:= {}
Default aItens			:= {}
Default cEntrega		:= {}
Default cNumNota		:= ""
Default cSerie			:= ""
Default nRecNoSL2		:= 0
Default cTpGeraGdp 	:= GDP_NO
Default nOpc			:= 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar os itens que serao incluidos   	³
//³na factura de acordo com  tipo de entrega	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cPaisLoc == "CHI"
		If (nModulo == 12 .AND. !(cTpGeraGdp == GDP_PARCIAL .AND. cEntrega == "1" .AND. nOpc == 3)) .OR.;
			(nModulo == 23 .AND. !(cEntrega == "1"))

			If (nPosBreak := AScan(aBreakNota,{|x| x[1] == cNumNota .AND. x[2] == cSerie})) > 0
        		Aadd(aItens,nRecNoSL2)
        		aBreakNota[nPosBreak][3] := Aclone(aItens)
   			EndIf
		EndIf
	Case cPaisLoc == "COL"
		If (nModulo == 12 .AND. !(cEntrega $ "1|3" .AND. nOpc == 3)) .OR.(nModulo == 23 .AND. !(cEntrega $ "1|3"))
			If (nPosBreak := AScan(aBreakNota,{|x| x[1] == cNumNota .AND. x[2] == cSerie})) > 0
        		Aadd(aItens,nRecNoSL2)
        		aBreakNota[nPosBreak][3] := Aclone(aItens)
        	EndIf
		EndIf
EndCase

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjSerNfRPSºAutor  ³Vendas CRM          º Data ³  16/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o numero e serie da NF de Servico referente ao        º±±
±±º          ³ RPS (Recibo Provisorio de Servico).                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjSerNfRPS()				                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                            º±±
±±º          ³     													      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSerNfRPS(lVendDireta)

Local aRet			:= {.F.,'',''}          					// Array de retorno
Local aNumRPS       := {} 										// Array que armazenara o numero da NF de servico (RPS)
Local cMV_TPNRNFS	:= LjTpNrNFS()								// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cSerieRPS		:= AllTrim(SuperGetMv("MV_LOJARPS",,"RPS")) // Serie da NF de Servico RPS configurada no parametro MV_LOJARPS
Local lIntegDef	:= SL1->L1_ORIGEM == "N"                        // Venda de Origem Integração

DEFAULT lVendDireta := .F.                                      // Indica que foi acionada pela Venda Direta.

//Integracao utiliza Doc e Serie enviados no xml
If lIntegDef
	aRet := { .T. , {SL1->L1_DOCRPS, SL1->L1_SERRPS} }
Else
	If Empty(cSerieRPS)
		cSerieRPS := Space(TamSX3("L1_SERRPS")[1])
	Else
		cSerieRPS := PadR(cSerieRPS , TamSX3("L1_SERRPS")[1])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera o numero da NF com base na serie     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMV_TPNRNFS == "3" //3=Controle do numero da nota pelo SD9
		aAdd( aNumRPS, { cSerieRPS,  MA461NumNf( .T., cSerieRPS ) } )
	ElseIf !LjxDNota(cSerieRPS,3,.F.,1,@aNumRPS,,,,,,,,,,,"MV_LOJARPS") //Controle do numero da nota pelo  1=SX5  ou  2=SXE/SXF
		aRet := { .F., {} }
		Return(aRet)
	EndIf
	
	aRet := { .T. , {aNumRPS[01][02], aNumRPS[01][01]} }
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjCheckRPS  ³ Autor ³ Vendas Clientes    ³ Data ³08.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a venda possui item(s) de "servico".           ³±±
±±³ 		 ³	"Recibo Provisorio de Servicos - RPS".  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ ExpC1 - Numero do Orcamento	                        	  º±±
±±³			 ³ ExpL2 - Indica se tem item de "produto" na venda.		  º±±
±±³			 ³ ExpL3 - Indica se tem item de "servico" na venda.		  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCheckRPS(cNumOrcam, lTemItProd, lTemItServ)

Local aAreaSL2	:= {}

aAreaSL2 := SL2->(GetArea())
DbSelectArea("SL2")
DbSetOrder(1)
If DbSeek( xFilial( "SL2" ) + cNumOrcam )
	While !SL2->( Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + cNumOrcam .And. (!lTemItProd .Or. !lTemItServ)
		If LjIsTesISS(cNumOrcam,SL2->L2_TES)
			lTemItServ := .T. //Item de "Servico"
		Else
			lTemItProd := .T. //Item de "Produto"
		EndIf
		SL2->(DbSkip())
	End
EndIf
RestArea(aAreaSL2)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    GerOPOtc 	 ³ Autor ³ Totvs Fábrica        ³ Data ³ 15/01/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera OP pelo template  de Otica  								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= GerOPOtc() 	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Nota Fiscal												³±±
±±³          ³ExpC2 - Serie     												³±±
±±³          ³ExpA3 - Array contendo os ítens a serem Empenhados				³±±
±±³          ³ExpN8 - Opção de operação, sendo :								³±±
³±±												3 - Incluir						³±±
³±±												5 - Excluir						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = Nil           									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ EstOPOtc															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GerOPOtc(cNumNota,cSerie,aEmp,nOpc)
Local cQuery
Local aSC2
Local nCount		:= 0
Local cProduto := SuperGetMV("MV_OGENOTC",.F.,"")
Local cRoteiro := SuperGetMV("MV_RTOPOTC",.F.,"")
Local cNumOp

Private lMsErroAuto := .F.

If Empty(cProduto)
	Conout(STR0158) // Geração de OP - Template Otica - Não existe nenhum produto cadastrado no parâmetro MV_OGENOTC. Operação Abortada.
	DisarmTransaction()
	Return
Endif

If nOpc	== 3
	cQuery := " Select MAX(L1_NUM) Num_Orc,L1_DOC,L1_SERIE,L1_NROPCLI,L2_CONJUNT "
	cQuery += " FROM "+RetSqlName("SL1")+" SL1 "
	cQuery += " Inner Join "+RetSqlName("SL2")+" SL2 "
	cQuery += " on SL2.L2_NUM = SL1.L1_NUM "
	cQuery += " WHERE L1_DOC = '"+cNumNota+"' AND "
	cQuery += " L1_SERIE = '"+cSerie+"' AND "
	cQuery += " SL1.D_E_L_E_T_ = '' AND "
	cQuery += " SL2.D_E_L_E_T_ = '' AND "
	cQuery += " SL1.L1_FILIAL ='"+xFilial("SL1")+"' AND "
	cQuery += " SL2.L2_FILIAL ='"+xFilial("SL2")+"'  AND "
	cQuery += " SL2.L2_CONJUNT <> 0  "
	cQuery += " Group By L1_DOC,L1_SERIE,L1_NROPCLI,L2_CONJUNT "
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),"TempOP",.T.,.T.)

	ConOut(STR0159) // Geração de OP - Template Otica - Vereficando Necessidade de OP...

	While TempOP -> (!EOF())
				cNumOp := (GetSX8Num("SC2","SC2_NUM"))
				aSC2:={ {"C2_NUM",cNumOp,NIL},;
					 {"C2_ITEM","01",NIL},;
					 {"C2_SEQUEN","001",NIL},;
					 {"C2_PRODUTO",cProduto,NIL},;
					 {"C2_QUANT",1,NIL},;
					 {"C2_PRIOR","500",NIL},;
					 {"C2_DATPRI",ddatabase,NIL},;
					 {"C2_DATPRF",ddatabase,NIL},;
					  {"C2_OSLOJA",SubStr(TempOP->L1_NROPCLI,1,6)+Alltrim(strzero(TempOP->L2_CONJUNT,2,0)),NIL}}

					  lMsErroAuto := .F.

					  MSExecAuto({|x,y| mata650(x,y)},aSC2,nOpc) //Inclusao
					  If lMsErroAuto
							ConOut(STR0160)  //Geração de OP - Template Otica - Ocorreu um erro no momento da geração da OP. Operação abortada.
							DisarmTransaction()
				      Else
					      	SC2->(ConfirmSX8())
					      	RecLock("SC2",.F.)
				       	    REPLACE SC2->C2_ROTEIRO		WITH Alltrim(cRoteiro)
						    SC2->(MsUnlock())
				      		ConOut(STR0161)//Geração de OP - Template Otica - OP Gerada com Sucesso!
				      		If !Empty(aEmp)
									ConOut(STR0162) //Geração de OP - Template Otica - Ajustando Empenhos
									For nCount := 1 To Len(aEmp)
											If Alltrim(strzero(aEmp[nCount][03],2,0)) == SubStr(SC2->C2_OSLOJA,7,2)
													EmpOtc(aEmp[nCount][02],aEmp[nCount][04],SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,aEmp[nCount][10],aEmp[nCount][06],aEmp[nCount][09],aEmp[nCount][05],3)
											Endif
									Next
							Else
									ConOut(STR0163) //Geração de OP - Template Otica - A OP não possui empenho.
							Endif
				      Endif
	TempOP -> (DbSkip())
	Enddo
	TempOP -> (DbCloseArea())
Elseif nOpc ==5
	aSC2:={ {"C2_NUM",cNumOp,NIL},;
	{"C2_ITEM","01",NIL},;
	{"C2_SEQUEN","001",NIL},;
	{"C2_PRODUTO",cProduto,NIL},;
	{"C2_QUANT",1,NIL},;
	{"C2_PRIOR","500",NIL},;
	{"C2_DATPRI",ddatabase,NIL},;
	{"C2_DATPRF",ddatabase,NIL}}

	lMsErroAuto := .F.

	MSExecAuto({|x,y| mata650(x,y)},aSC2,nOpc) //Exclusão
	If lMsErroAuto
		ConOut(STR0164) //Exclusão de OP - Ocorreu algum erro no momento da Exclusão da Ordem de Produção
		DisarmTransaction()
	Else
		ConOut(STR0167) //Exclusão de OP - Operação Realizada com sucesso.
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    EmpOtc 	 ³ Autor ³ Totvs Fábrica        ³ Data ³ 15/01/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla o empenho dos materiais Quando utilizado o template   	³±±
±±³Otica                                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= EmpOtc() 	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Produto													³±±
±±³          ³ExpC2 - Local     												³±±
±±³          ³ExpC3 - Ordem de Produção         								³±±
±±³          ³ExpN4 - Quantidade         										³±±
±±³          ³ExpC5 - Lote               										³±±
±±³          ³ExpC6 - Data de Validade											³±±
±±³          ³ExpC7 - Endereço             										³±±
±±³          ³ExpN8 - Opção de operação, sendo :								³±±
±±												3 - Incluir						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = Nil           									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ EstOPOtc															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EmpOtc(cProduto,cLocal,cOP,nQtde,cLote,dValid,cLocaliz,nOpc)
Local aMata380 := {}
Local aEmp380  := {}
Local nModuloOld
Private lMSErroAuto := .f.

aadd(aMata380,{"D4_COD"    ,PADR(cProduto,tamsX3("B1_COD")[1])     			,NIL})
aadd(aMata380,{"D4_LOCAL"  ,cLocal       			,NIL})
aadd(aMata380,{"D4_OP"     ,cOP         			,NIL})
aadd(aMata380,{"D4_DATA"   ,dDataBase 				,NIL})
aadd(aMata380,{"D4_QTDEORI",nQtde					,NIL})
aadd(aMata380,{"D4_QUANT"  ,nQtde	 				,NIL})
aadd(aMata380,{"D4_LOTECTL",If(!Empty(cLote),cLote,CriaVar("D4_LOTECTL"))		,NIL})
aadd(aMata380,{"D4_NUMLOTE",CriaVar("D4_NUMLOTE")	,NIL})
aadd(aMata380,{"D4_DTVALID",If(!Empty(dValid),dValid,CTOD("//"))				,NIL})
aadd(aMata380,{"D4_QTSEGUM",0						,NIL})
aadd(aMata380,{"D4_POTENCI",CriaVar("D4_POTENCI")	,NIL})

If !Empty(cLocaliz)
	aadd(aEmp380,{nQtde,cLocaliz,CriaVar("DC_NUMSERI"),0,.F.})
Endif

If nOpc == 3
	nModuloOld  := nModulo
	nModulo     := 4
	lMSErroAuto := .F.
	lMSHelpAuto := .F.
	msExecAuto({|x,y,z|MATA380(x,y,z)},aMata380,nOpc,aEmp380)
	nModulo     := nModuloOld
	lMsHelpAuto:=.F.
	If lMSErroAuto
		Conout(STR0165 + " " + AllTrim(cProduto)+'.') //Geração de OP - Template Otica - Ocorreram problemas para alteração do empenho do produto:
		lErroReq := .t.
		DisarmTransaction()
	Else
		Conout(STR0166 + " " + cOP + '.') //Geração de OP - Template Otica - Empenho realizado com sucesso para a OP
	EndIf
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LjDifVlSol³ Autor ³ Vendas e DL			³ Data ³ 06/08/2013	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula a diferenca do valor do ICMS Solidario, quando ha    	³±±
±±³			 |alteracoes na Base de Calculo. Exemplo: Acrescimo, Desconto,	³±±
±±³			 |Frete. A diferenca eh baseada no retorno da MatxFis()			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= LjDifSol(cRefFiscal, nValor)							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Referencia Fiscal da MatxFis							³±±
±±³          ³ExpN1 - Valor a ser aplicado na MatxFis						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpN2 = Diferenca do Valor do ICMS Solidario					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 																³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjDifVlSol( cRefFiscal, nValor )
Local nBkpValSol:= 0	//valor do ICMS Solidario ANTES da alteracao
Local nAtuValSol:= 0	//valor do ICMS Solidario APOS alteracao
Local nDifValSol:= 0	//diferenca entre o valor do ICMS Solidario

Default cRefFiscal	:= ""
Default nValor		:= 0

If MaFisFound("NF")
	nBkpValSol := Lj7IcmsSol()

	MaFisSave()		//salva o estado da MatxFis
	MaFisAlt(cRefFiscal,nValor)
	nAtuValSol := Lj7IcmsSol()
	MaFisRestore()	//restaura o estado da MatxFis

	nDifValSol := nAtuValSol - nBkpValSol
EndIf

Return nDifValSol

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LjIsTesISS³ Autor ³ Vendas Clientes		³ Data ³ 11/10/2013	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a TES esta configurada para calcular ISS (Servico)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cod. do Orcamento ou Num. do Cupom (somente para   	³±±
±±³          ³        controlar se zera ou nao o array estatico "aTESVenda".³±±
±±³          ³ExpC2 - Codigo da TES a ser verificada. 						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA / SIGAFRT											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjIsTesISS(cIDVenda,cCodTES)
Local lRet 		:= .F.
Local nPos 		:= 0
Local aArea 	:= {}
Local aAreaSF4 	:= {}

If Empty(aTESVenda[1]) .Or. aTESVenda[1] != cIDVenda
	aTESVenda := { cIDVenda, {} }
EndIf

nPos := aScan( aTESVenda[2],{|x| x[1] == cCodTES })

If nPos > 0
	lRet := aTESVenda[2][nPos][2]
Else
	aArea 	 := GetArea()
	dbSelectArea("SF4")
	aAreaSF4 := SF4->( GetArea() )
	SF4->( dbSetOrder(1) ) //F4_FILIAL+F4_CODIGO
	If SF4->( dbSeek(xFilial("SF4")+cCodTES) )
		lRet := SF4->F4_ISS == "S" //Verifica se a TES estah configurada para calcular ISS

		aAdd( aTESVenda[2], {cCodTES, lRet} )
	EndIf
	RestArea( aAreaSF4 )
	RestArea( aArea )
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj7RetClasFis	º Vendas            º Data ³  10/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna classificação Fiscal do produto		              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpC1 - Codigo do produto a ser posicionado na tabela SB1. ³±±
±±³          ³  Caso nao seja passado entende-se que ja esteja posicionado³±±
±±³          ³ ExpC2 - Codigo da TES a ser posicionada na tabela SF4.	  ³±±
±±³          ³  Caso nao seja passado entende-se que ja esteja posicionado³±±
±±³          ³ ExpC3 - Numero do Lote do produto (produto com rastro).    ³±±
±±³          ³ ExpC4 - Numero do Sub-Lote do produto (produto com rastro).³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ String 												      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUsado	 ³ LOJXFUNC / LOJA701A / LOJA701B / 					      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7RetClasFis(cProd, cTes, cNumLote, cLoteCtl, nItem, lScreen)
Local cRet		:= ""
Local cOrigem	:= ""
Local aSB1Area	:= {}
Local aSF4Area	:= {}
Local aSD1Area	:= {}
Local aLjExcecao := {}

Local aSxFci		:= LjCFciParam()
Local lFciVlImpor	:= SL2->(ColumnPos("L2_VLIMPOR")) > 0 .And. SLR->(ColumnPos("LR_VLIMPOR")) > 0 .And. aSxFci[5] .And. aSxFci[6]
Local lFciCod		:= SL2->(ColumnPos("L2_FCICOD")) > 0 .And. SLR->(ColumnPos("LR_FCICOD")) > 0 .And. aSxFci[4] .And. aSxFci[8]
Local nPosBIcms		:= 0
Local nPosVIcms		:= 0
Local lHeaderDet	:= Type("aHeaderDet") == "A"
Local nTamB1Orig	:= SB1->(TamSx3("B1_ORIGEM"))[1]

Default cProd	:= ""
Default cTes	:= ""
Default cNumLote:= ""
Default cLoteCtl:= ""
Default nItem	 := 0
Default lScreen	 := .F.

nPosBIcms		:= IIF(!lScreen .And. lHeaderDet, Ascan(aHeaderDet,{|x| AllTrim(Upper(x[2])) == "LR_BASEICM"}), 0)
nPosVIcms		:= IIF(!lScreen .And. lHeaderDet, Ascan(aHeaderDet,{|x| AllTrim(Upper(x[2])) == "LR_VALICM"}), 0)

//Caso não esteja posicionado deve ser posicionada as tabelas:
If !Empty(cProd) .And. !(cProd == SB1->B1_COD)
	aSB1Area := SB1->(GetArea())
	SB1->(DbSetOrder(1))
	SB1->(DBSeek(xFilial("SB1")+cProd))
EndIf

If !Empty(cTes) .And. !(cTes == SF4->F4_CODIGO)
	aSF4Area := SF4->(GetArea())
	SF4->(DBSetOrder(1))
	SF4->(DBSeek(xFilial("SF4")+cTes))
EndIf

If (!Empty(cNumLote) .Or. !Empty(cLoteCtl)) .And. Rastro(SB1->B1_COD) .And. aSxFci[1] .And. aSxFci[9] .And. (lFciVlImpor .Or. lFciCod) .And. ;
	LjCRetFci(SB1->B1_COD, cNumLote, cLoteCtl,,, MaFisRet(nItem,"IT_CLASFIS"), nItem)

	   cRet := MaFisRet(nItem,"IT_CLASFIS")
	   If Type("aDadList") == "A" .And. nPosBIcms > 0 .And. nPosVIcms > 0//Variaveis private criadas apeans quando clicado no botão detalhes do venda assistida.
			aColsDet[nItem][nPosBIcms] := MaFisRet(nItem, "IT_BASEICM")
			aColsDet[nItem][nPosVIcms] := MaFisRet(nItem, "IT_VALICM")
		EndIf
Else

	If MaFisFound("NF") .And. nItem > 0 .And. MaFisFound("IT",nItem) .And. Len(aLjExcecao := MaFisRet(nItem,"IT_EXCECAO"))>0

		cRet := IIf(Empty(aLjExcecao[28]),SubStr(SB1->B1_ORIGEM, 1, nTamB1Orig), aLjExcecao[28]) + IIf(Empty(aLjExcecao[29]),SF4->F4_SITTRIB, aLjExcecao[29])
	Else
		//Regra para classificacao Fiscal do Produto:
		If !Empty(cNumLote) .And. !Empty(cLoteCtl) .And. Rastro(SB1->B1_COD)
			aSD1Area := SD1->(GetArea())
			If Lj7PosicSD1(cNumLote, cLoteCtl, SB1->B1_COD)
				cRet := Substr(SD1->D1_CLASFIS,1,nTamB1Orig) +  SF4->F4_SITTRIB
			EndIf
			RestArea(aSD1Area)
		EndIf

		If Empty(cRet)
			cOrigem := RetFldProd( SB1->B1_COD, "B1_ORIGEM" )
			cOrigem := IIf( Empty(cOrigem), SB1->B1_ORIGEM, cOrigem )

			cRet := SubStr(cOrigem, 1, nTamB1Orig) + SF4->F4_SITTRIB
		EndIf
	EndIf
EndIf

//Restauração do posicionamento das tabelas
If Len(aSB1Area) > 0
	RestArea(aSB1Area)
EndIf
If Len(aSF4Area) > 0
	RestArea(aSF4Area)
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj7PosiSD1	º Vendas              º Data ³  10/12/2013    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Posiciona o SD1 de acordo com o Produto, Lote e SubLote 	  º±±
±±º			 ³ para o controle de lote									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ Logico (.T./.F.)										      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUsado	 ³ LOJXFUNC							 					      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7PosicSD1(cNumLote,cLoteCtl,cProduto)
Local lRet		 := .F.
Local aAliasArea := GetArea()
Local aSB8Area	 := SB8->(GetArea())

DBSelectArea("SB8")
SB8->(DBSetOrder(2)) //B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
If SB8->(DBSeek(xFilial("SB8")+cNumLote+cLoteCtl+cProduto))
	DBSelectArea("SD1")
	SD1->(DBSetOrder(2)) //D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
	lRet := SD1->(DBSeek(xFilial("SD1")+cProduto+SB8->B8_DOC+SB8->B8_SERIE+SB8->B8_CLIFOR+SB8->B8_LOJA))
EndIf
RestArea(aSB8Area)
RestArea(aAliasArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |Lj7VPIsPrd³ Autor ³ Vendas Clientes       ³ Data ³06/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar se o produto informado na venda eh do tipo "VP"     ³±±
±±³			 ³ (Vale Presente).      									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj7VPIsPrd(cCodProd)
Local lRet 		:= .F.

If nModulo == 23 //Front Loja
	SBI->(DbSetOrder(1))
	If SBI->(DbSeek(xFilial("SBI")+cCodProd)) .And. SBI->BI_VALEPRE == "1"
		lRet:= .T.
	EndIf
Else
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cCodProd)) .And. SB1->B1_VALEPRE == "1"
		lRet:= .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |Lj7VPVdaVP³ Autor ³ Vendas Clientes       ³ Data ³06/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seta se eh ou nao uma venda de vale presente.	  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj7VPVdaVP(nTipo)

Do Case
	Case nTipo == 0
		cTipoPrdVP 	:= "" //Nao esta definido ainda se eh uma venda de VP ou Nao.
	Case nTipo == 1
		cTipoPrdVP := "S" //Eh uma venda de Vale Presente.
	Case nTipo == 2
		cTipoPrdVP := "N" //Nao eh venda de Vale Presente.
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |Lj7VPYesNo³ Autor ³ Vendas Clientes       ³ Data ³06/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se eh ou nao uma venda de vale presente.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ""  = Nao esta definido ainda se eh uma venda de VP ou Nao.³±±
±±³          ³ "S" = Eh uma venda de Vale Presente.                       ³±±
±±³          ³ "N" = Nao eh venda de Vale Presente.Eh venda de Prod.normal³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj7VPYesNo()
Return cTipoPrdVP

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7VdaIsVPºAutor  ³Vendas Cliente      º Data ³  06/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se eh venda de Vale Presente.					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA / FRONTLOJA                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7VdaIsVP(cNumOrc)
Local lRet		:= .F.
Local aAreaSL2	:= {}

If SL2->(FieldPos( "L2_VALEPRE" )) > 0
	aAreaSL2	:= SL2->(GetArea())
	DbSelectArea("SL2")
	SL2->( DbSetOrder(1) )
	If SL2->( DbSeek(xFilial("SL2")+cNumOrc) )
		While !SL2->( EOF() ) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cNumOrc
			If !Empty(SL2->L2_VALEPRE)
				lRet := .T.
				Exit
			EndIf

			SL2->( DbSkip() )
		End
	EndIf
	RestArea(aAreaSL2)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | LjTotRec   ³ Autor ³ Vendas Clientes     ³ Data ³11/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array com formas de pagamento e ID  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA / FRONTLOJA                     			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function LjTotRec(aReceb,nVlTotal)
Local nTotReceb := 0		// Valor total das parcelas
Local aTotReceb := {}		// Array com valores: cForma, cFormaID, nTotReceb, nTotParc}
Local nPosReceb := 0        // Posicao no array aTotReceb
Local nTotParc  := 0		// Total de parcelas
Local nX					// Controla laco externo do array aTotReceb
Local nI					// Controla laco interno do array aTotReceb

For nX := 1 To Len(aReceb)

	// Verifica se ja esta adicionado no array aTotReceb
	nPosReceb := aScan( aTotReceb,{|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aReceb[nX][__FORMA])+Alltrim(aReceb[nX][__FORMAID]) })

	cForma   := Alltrim(aReceb[nX][__FORMA])		// Forma de pagamento
	cFormaID := Alltrim(aReceb[nX][__FORMAID])		// ID do cartao

	// Se nao foi adicionado e incluido no array
	If nPosReceb == 0
		nTotReceb := 0		// Zera variavel para a proxima forma de pagamento
		nTotParc  := 0		// Zera variavel para a proxima forma de pagamento

		nI := nX

		For nI := nX to Len(aReceb)
			If Alltrim(cForma) <> Alltrim(aReceb[nI][__FORMA]) .OR. Alltrim(cFormaID) <> Alltrim(aReceb[nI][__FORMAID])
				Exit
			Endif
			nTotReceb += aReceb[nI][__VALOR]
			nTotParc++
		Next nI

		Aadd(aTotReceb, {cForma, cFormaID, nTotReceb, nTotParc})
		nVlTotal += nTotReceb
	Endif

Next nX

Return(aTotReceb)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CP_LoadºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega as variaveis estaticas referente ao "Cartao        º±±
±±º          ³ Presente" (Gift Card).                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CP_Load()
Local cMVLJPRCP := ""
Local cModulosCP:= "|1|2|" //Modulos de Cartao Presente (Gift Card) Homologados com a Software Express (1=Modulo GIVEX; 2=Modulo SQCF - Todo Cartoes)

//Parametro com o codigo do(s) produto(s) definido(s) como "Cartao Presente" (Gift Card).
cMVLJPRCP	:= AllTrim(SuperGetMv("MV_LJPRCP", ,"" ))
If Left(cMVLJPRCP,1) == "&" //Verifica se foi configurado o parametro para ser macro executado
	cMVLJPRCP	:= &(SubStr(cMVLJPRCP,2))
EndIf
aProdsCP := StrToKarr(cMVLJPRCP , "/")			// Array com a relacao de produtos definidos como "Cartao Presente" (Gift Card).

aRegTefCP 	:= {}
cTipoPrdCP 	:= ""

If !IsBlind()
	//So ativa a implementacao de "Cartao Presente (Gift Card)" se:
	//  1) Se o Tipo do TEF configurado no cadastro de estacao for modalidade CliSitef;
	//  2) Se os parametros MV_LJCPMOD e MV_LJPRCP estiverem configurados;
	//  3) Se for modulo SIGALOJA
	//  4) Se for PAF, eh permitido apenas no PDV. Na Retaguarda PAF nao pode habilitar, pois nao permite finaliza a venda na Retaguarda;
	lCPAtivo	:= lUsaTef .And. LjGetStation("TIPTEF") == TEF_CLISITEF .And. ( AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) $ cModulosCP ) //MV_LJCPMOD: Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
	lCPAtivo 	:= lCPAtivo .And. !Empty(cMVLJPRCP) //Verifica se o parâmetro MV_LJPRCP esta configurado
	lCPAtivo 	:= lCPAtivo .And. nModulo == 12 //Verifica se eh Modulo SIGALOJA
	lCPAtivo 	:= lCPAtivo .And. If(LjNfPafEcf(SM0->M0_CGC),FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2],.T.)  //Se for PAF, so permite usar a funcionalidade no PDV
Else
	lCPAtivo 	:= !Empty(cMVLJPRCP) .And. ( AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) $ cModulosCP )
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CP_ProdºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o produto informado eh "Cartao Presente"       º±±
±±º          ³ (Gift Card).                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CP_Prod(cCodProdut)
Return ( Ascan( aProdsCP, {|x| AllTrim(x) == AllTrim(cCodProdut)} ) > 0 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CP_AtivºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a implementacao de Cartao Presente (Gift Card) º±±
±±º          ³ estah ativa.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CP_Ativ()
Return lCPAtivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CPSetStºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta se eh ou nao uma venda de recarga de Cartao Presente  º±±
±±º          ³ (Gift Card).                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CPSetSt(nTipo,lJob)
Default lJob := .F.

Do Case
	Case nTipo == 0
		cTipoPrdCP 	:= "" //Nao esta definido ainda se eh uma venda de recarga de Cartao Presente ou Nao.
		aRegTefCP 		:= {}
		If !lJob .And. Lj7CP_OK() .And. Type("oTef") <> "U"
			oTef:aRetRecCP 	:= {}
			oTef:nTransCP  	:= 0
		EndIf
	Case nTipo == 1
		cTipoPrdCP := "S" //Eh uma venda de recarga de Cartao Presente.
	Case nTipo == 2
		cTipoPrdCP := "N" //Nao eh venda de recarga de Cartao Presente.
		aRegTefCP 		:= {}
		If !lJob .And. Lj7CP_OK() .And. Type("oTef") <> "U"
			oTef:aRetRecCP 	:= {}
			oTef:nTransCP  	:= 0
		EndIf
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CPGetStºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Verifica se eh ou nao venda de Recarga de "Cartao Presenteº±±
±±º          ³  (Gift Card)".                                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ""  = Nao definido ainda se eh recarga de Cartao Presente  ³±±
±±³          ³ "S" = Eh uma venda de recarga de Cartao Presente.          ³±±
±±³          ³ "N" = Nao eh venda de recarga de Cartao Presente.          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CPGetSt()
Return cTipoPrdCP

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CP_Rcg ºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o tratamento da Recarga de Cartao Presente (Gift Card) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CP_Rcg( cNum, nVlrUnit, cCodProd, lTefPendCS, lFirstPrd )
Local lRet		:= .F.
Local cSeqTrans := ""

If Len(aRegTefCP) > 0
	cSeqTrans 	:= aRegTefCP[1][1]
Else
	cSeqTrans := cNum //Tratamento da sequencia do TEF
Endif

//Recarga Cartao Presente (Recarga atraves da venda do produto) na tela de atendimento
lRet := oTef:CartaoPresenteGiftCard( "RCP"		, @nVlrUnit	, Nil		, Nil			,;
									Nil			, cSeqTrans	, cCodProd	, @lTefPendCS )

If lRet
	lTefPendCS  := .T.
	aAdd(aRegTefCP,{oTef:cCupom,oTef:cData,oTef:cHora,.T.})
Else
	If Len(aRegTefCP) == 0
		lTefPendCS  := .F.
	Endif
	aAdd(aRegTefCP,{oTef:cCupom,oTef:cData,oTef:cHora,.F.})
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CP_Imp ºAutor  ³ Vendas Cliente     º Data ³  10/03/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se tem "Recarga de Celular" pendente para         º±±
±±º          ³ impressao de comprovante.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CP_Imp()
Local lRet := .F.
lRet := Len(aRegTefCP) > 0
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjCompFKs
Altera os campos para utilizar o padrao do SigaLoja
	
@author  Leandro Kenji
@version P12.1.17
@since   13/11/2017
@return  n/a
/*/
//--------------------------------------------------------
Static Function LjCompFKs(lTpDoc,cPrefixo,cNumero,cParcela,cTipo,cCliente,cLoja)

Local aArea			:= GetArea()
Local aAreaFKA		:= FKA->( GetArea() )
Local cProcFKA		:= FKA->FKA_IDPROC
Local cRotBx		:= "LJGRVFIN" 
Local cTpDocLj		:= "LJ"

Default lTpDoc		:= .T.
Default cPrefixo	:= ""
Default cNumero		:= ""
Default cParcela	:= ""
Default cTipo		:= ""
Default cCliente	:= ""
Default cLoja		:= ""

LjGrvLog(," LjCompFKs | Inicio " )

dbSelectArea("SE5")
dbSetOrder(7)
If MsSeek(xFilial("SE5")+Alltrim(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja))
	//Atualiza campos na SE5
	RecLock("SE5",.F.)
	
		//Se Existir o Campo E5_NumMov,Grava o Numero do Ultimo Movimento do SLW
		If SE5->(FieldPos("E5_NUMMOV"))>0
			SE5->E5_NUMMOV := LJNumMov()
		EndIf
	
		//Altera origem e tipo para o Loja
		SE5->E5_ORIGEM := cRotBx
		
		If lTpDoc
			SE5->E5_TIPODOC := cTpDocLj
		EndIf
	
	SE5->( MsUnLock() )
EndIf

//Atualiza campos das FKs
dbSelectArea("FKA")
FKA->( dbSetOrder(2) )
FKA->( dbSeek( xFilial("FKA") + cProcFKA ) )
While FKA->( !EOF() ) .AND. ( xFilial("FKA") + cProcFKA == FKA->FKA_FILIAL + FKA->FKA_IDPROC )

	If FKA->FKA_TABORI == "FK1"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK1")
		FK1->( dbSetOrder(1) )
		If FK1->( dbSeek( xFilial("FK1") + FKA->FKA_IDORIG ) )

			RecLock("FK1",.F.)
			
			FK1->FK1_ORIGEM := cRotBx

			If lTpDoc
				FK1->FK1_TPDOC := cTpDocLj
			EndIf

			FK1->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK5"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK5")
		FK5->( dbSetOrder(1) )
		If FK5->( dbSeek( xFilial("FK5") + FKA->FKA_IDORIG ) )

			RecLock("FK5",.F.)

			FK5->FK5_ORIGEM := cRotBx
			
			If lTpDoc
				FK5->FK5_TPDOC := cTpDocLj
			EndIf
			
			FK5->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK6" .AND. lTpDoc

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK6")
		FK6->( dbSetOrder(1) )
		If FK6->( dbSeek( xFilial("FK6") + FKA->FKA_IDORIG ) )

			RecLock("FK6",.F.)
			FK6->FK6_TPDOC := cTpDocLj
			FK6->( MsUnLock() )

		EndIf


	ElseIf FKA->FKA_TABORI == "FK3"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK3")
		FK3->( dbSetOrder(1) )
		If FK3->( dbSeek( xFilial("FK3") + FKA->FKA_IDORIG ) )

			RecLock("FK3",.F.)
			FK3->FK3_ORIGEM := cRotBx
			FK3->( MsUnLock() )

		EndIf


	ElseIf FKA->FKA_TABORI == "FK4"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK4")
		FK4->( dbSetOrder(1) )
		If FK4->( dbSeek( xFilial("FK4") + FKA->FKA_IDORIG ) )

			RecLock("FK4",.F.)
			FK4->FK4_ORIGEM := cRotBx
			FK4->( MsUnLock() )

		EndIf


	EndIf

	FKA->( dbSkip() )

End

RestArea(aAreaFKA)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IntegDef  ³ Autor ³ Vendas Cliente       ³ Data ³ 12/12/18 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para Definicao de Integracao via Mensagem Unica.    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IntegDef(cXml, cTypeTran, cTypeMsg)			             	 	³±±
±±³          ³ aExp1 - Conteudo da mensagem (XML)    							³±±
±±³          ³ aExp2 - Tipo da transacao                             	  		³±±
±±³          ³ aExp3 - Tipo da mensagem          		            	   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	  ³ Aray com resultado da execucao e a mensagem Xml de retorno.	³±±
±±³          ³ aRet[1]-(boolean) Indica o resultado da execução da função		³±±
±±³          ³ aRet[2]-(caracter) Mensagem Xml para envio                		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJXFUNC.prw							    						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef(cXml,cTypeTran,cTypeMsg,cVersion,cTransaction,lJSon)
Local aRet := {}

aRet := LOJIXFUNC(cXml, cTypeTran, cTypeMsg,lJson)

Return aRet
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJIXERR

Funcao de integracao com o adapter EAI para envio/recebimento de Vendas com Erro

@author  Varejo
@version P12
@since   17/12/2018
@return  lRet - (boolean)  Indica o resultado da execução da função
          cXmlRet - (caracter) Mensagem XML para envio
          Nome do Adapter EAI
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojEaiErr()
Local aArea		:= GetArea()
Local aAreaSL1  := SL1->(GetArea())
Local cQuery  	:= ""
Local lOk	 	:= .T.
Local aInteg 	:= {}

LjGrvLog(," LojEaiErr | Inicio " )

cQuery  := " SELECT "
cQuery  += " R_E_C_N_O_,L1_NUM,L1_FILIAL "
cQuery  += " FROM " + RetSqlName("SL1") + " SL1"
cQuery  += " WHERE"
cQuery  += " SL1.L1_FILIAL = '"+ xFilial('SL1') + "' AND "
cQuery  += " SL1.L1_SITUA = 'ER' AND "
cQuery  += " SL1.L1_ERGRVBT IS NULL AND "
cQuery  += " SL1.D_E_L_E_T_ = ' ' "
cQuery  += " ORDER BY L1_FILIAL,SL1.L1_SITUA,SL1.L1_ERGRVBT"

If !TCSQLEXEC(cQuery) >= 0 //Verifica se nao ira gerar error.log o filtro retornado pelo P.E.         	        
	lOk	 := .F.
	LjGrvLog("", "LOJIXFUNC - Query com Erro na Integração com EAI no fonte LOJIXFUNC.", TCSQLError())
EndIf
If lOk
	ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPSL1",.F.,.T.)
EndIf

If lOk
	While TMPSL1->(!EOF())
		SL1->(DbGoTo(TMPSL1->R_E_C_N_O_))
		//ConOut("LOJIXFUNC: Registro com erro encontrado ")
		If SL1->(Rlock())// Funcao que tenta alocar sem chamar tela
			SL1->(MsUnlock())
			aInteg := FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,CValToChar(STR0148+' - '+STR0022), "LOJXFUNC")// " a venda sera gravada como 'ER'." "Ocorreu algum erro no processo de gravacao batch..."
			If aInteg[1]//Retorno da integração for .T. grava o envio do xml no campo de erro. 
				SL1->(Rlock())
				SL1->L1_ERGRVBT := CValToChar(STR0148+' - '+STR0022)// " a venda sera gravada como 'ER'." "Ocorreu algum erro no processo de gravacao batch..."
				SL1->(MsUnlock())
			EndIf 
		Else
			LjGrvLog(TMPSL1->L1_NUM," Registro da Venda(SL1) esta em uso por outro usuário, venda nao poderá ser processada nesse momento")
			TMPSL1->(dbSkip())
		EndIf
		TMPSL1->(dbSkip())
	EndDo
	TMPSL1->(DbCloseArea())
EndIf

RestArea(aArea)
RestArea(aAreaSL1)
Return

//--------------------------------------------------------
/*/{Protheus.doc} LjGeraE5
Realiza a baixa do contas a receber criado pelo loja

@param aDadosBanc	Array com os dados bancarios
@param nTotAbat		Valor total dos abatimentos
@param nRecSE1		Numero do Recno da SE1
@param cHistor		Historico da baixa 
	
@author  Leandro Kenji
@version P12.1.17
@since   13/11/2017
@return  lRet	Informa se a baixa ocorreu com sucesso
/*/
//--------------------------------------------------------
Function LjGeraE5(aDadosBanc,nTotAbat,nRecSE1,cHistor)

Local aArea			:= GetArea()
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSL1		:= SL1->(GetArea())
Local aFina070		:= {}
Local dDtBaix		:= IIf(Empty(SL1->L1_EMISNF),dDatabase,SL1->L1_EMISNF)
Local lRet			:= .T.
Local nVlrBx		:= 0
Local cErro			:= ""								// Variavel erro
Local lLJ7113	 	:= ExistBlock( "LJ7113" )			// Ponto de entrada para contabilizar on line no encerramento da venda.
Local aParamLj      := {{"MV_PAR01",2},{"MV_PAR04",2}} 	// MV_PAR01 Mostra Lanc Contabil? 1=SIM, 2=NÃO / MV_PAR04 Contabiliza On-line? 1=SIM, 2=NÃO 
Local aTotaisLJ		:= {}								// Salva o array aTotais

Private lMSErroAuto	:= .F.

Default aDadosBanc 	:= {}
Default nTotAbat   	:= 0
Default nRecSE1    	:= 0
Default cHistor    	:= STR0009			//"BAIXA REF VENDA EM DINHEIRO"

LjGrvLog(," LjGeraE5 | Inicio " )

//Posiciona na SE1
dbSelectArea("SE1")
SE1->( dbGoTo(nRecSE1) )

nVlrBx	:= SE1->E1_VALOR - nTotAbat
//Monta array para a ExecAuto
aFina070 := {	{"E1_PREFIXO"  ,SE1->E1_PREFIXO        ,Nil    	},;
				{"E1_NUM"      ,SE1->E1_NUM	           ,Nil    	},;
				{"E1_TIPO"     ,SE1->E1_TIPO           ,Nil    	},;
				{"E1_PARCELA"  ,SE1->E1_PARCELA        ,Nil    	},;
				{"AUTMOTBX"    ,"NOR"                  ,Nil    	},;
				{"AUTBANCO"    ,SL1->L1_OPERADO        ,Nil    	},;
				{"AUTAGENCIA"  ,aDadosBanc[1]          ,Nil   	},;
				{"AUTCONTA"    ,aDadosBanc[2]          ,Nil    	},;
				{"AUTDTBAIXA"  ,dDtBaix		           ,Nil    	},;
				{"AUTDTCREDITO",dDtBaix		           ,Nil   	},;
				{"AUTHIST"     ,cHistor			       ,Nil   	},; 
				{"AUTJUROS"    ,0                      ,Nil		},;
				{"AUTVALREC"   ,nVlrBx                 ,Nil    	}}

// Ponto de Entrada - Contabiliza On-Line
If lLj7113
	aParamLj := ExecBlock("LJ7113",.F.,.F.)
EndIf

// Salva a aTotais para garantir integridaade deste array
If Type("aTotais") == "A"
	aTotaisLJ := aTotais
EndIf

//Chama ExecAuto FINA070 para baixa automatica do titulo	
MSExecAuto({|a,b,c,d,e,f| Fina070(a,b,c,d,e,f)},aFina070, 3,,,, aParamLj)

If Type("aTotais") == "A"
	aTotais := aTotaisLJ
EndIf 

If !lMsErroAuto
	LjGrvLog(," LjGeraE5 | Executado Rotina Fina070 " )
	//Altera campos para compatibilizar com o padrao do Loja
	LjCompFKs(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)
Else
	cErro:= MostraErro("\")
	Conout(cErro)
	LjGrvLog(SL1->L1_NUM,"Erro ao executar a rotina fina070: " + cErro )
	lRet := .F.
EndIf
RestArea(aAreaSL1)
RestArea(aAreaSF2)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjNfEspeci
Retorna a Especie do Documento Fiscal com base na Série da nota e na 
configuração do parâmetro MV_ESPECIE.

@author  Alberto Deviciente
@since 	 27/07/2021
@version P12.1.27

@param 	 cSerie, Caractere, Série do Documento
@param 	 cTiposDoc, Caractere, Tipos de Documento (MV_ESPECIE)

@return  cRet, Caractere, Especie do Documento Fiscal
/*/
//-----------------------------------------------------------------------
Function LjNfEspeci(cSerie, cTiposDoc)
Local cRet 			:= ""
Local nCount     	:= 0
Local nPosSign 		:= 0 	// Posicao do sinal dentro da string

Default cTiposDoc	:= AllTrim( SuperGetMv( 'MV_ESPECIE' ) ) // Tipos de documento

cTiposDoc := StrTran( cTiposDoc, ";", CHR(13)+CHR(10))
For nCount := 1 TO MLCount( cTiposDoc )
	cRet := AllTrim( StrTran( MemoLine( cTiposDoc,, nCount ), CHR(13), CHR(10) ) )
	nPosSign := Rat( "=", cRet)
	If nPosSign > 0 .AND. AllTrim( cSerie ) == AllTrim( SubStr( cRet, 1, nPosSign - 1 ) )
		If SX5->( DbSeek( xFilial("SX5") + "42" + SubStr( cRet, nPosSign + 1 ) ) )
			cRet := SubStr( cRet, nPosSign + 1 )
		Else
			cRet := SPACE(5)
		EndIf
		Exit
	Else
		cRet := SPACE(5)
	EndIf
Next nCount

Return cRet
