//Definicao de variavel em objeto
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

#INCLUDE "PROTHEUS.CH"

//Posicoes no array aItensPrePC
#DEFINE _ITMARK  	 1
#DEFINE _ITGIROALL 	 2
#DEFINE _ITQTDSUG	 3
#DEFINE _ITQTDPED	 4
#DEFINE _ITCUSTO	 5
#DEFINE _ITDESCPRD	 6
#DEFINE _ITCODPRD	 7
#DEFINE _ITLOCAL    8
#DEFINE _ITUM       9
#DEFINE _ITSEGUM   10
#DEFINE _ITULTPRC  11
#DEFINE _ITDULTCOM 12
#DEFINE _ITMINCUS  13
#DEFINE _ITDMINCUS 14
#DEFINE _ITMAXCUS  15
#DEFINE _ITDMAXCUS 16
#DEFINE _ITFABRIC  17
#DEFINE _ITNOMEFAB 18
#DEFINE _ITESTQATU 19
#DEFINE _ITQTMESAT 20
#DEFINE _ITQTMESAN 21
#DEFINE _ITUPRVEND 22
#DEFINE _ITUDTVEND 23
#DEFINE _ITMedatraso 24
#DEFINE _ITPENDENT 25 
#DEFINE _ITTESPROD 26

//Posicoes no array aLinProdFil
#DEFINE _PRODMARK  	  1
#DEFINE _PRODGIROALL 2
#DEFINE _PRODQTDSUG	  3
#DEFINE _PRODQTDPED	  4
#DEFINE _PRODCUSTO	  5
#DEFINE _PRODDESCPRD 6

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDROPREPC  บAutor  ณAndre Melo/Machima  บ Data ณ 14/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pre-Pedido de Compras                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DROPREPC()
Local nTamCusto  := TamSX3("D1_VUNIT")[1]
Local nTamQCusto := TamSX3("D1_QUANT")[1]
Local nI
Local oDlg
Local cRet       := ""
Local lRet       := .F.
Local cSeek1     := '"' + xFilial("SB1") + '"'
Local cWhile1    := "!Eof() .And. "
Local cDescDoc   := ""
Local cNumDocIni := ""
Local lMark01	 := .F.
Local aTam1      := {5,35,40,40,40,20,60}
Local aCab1      := {" ","Giro","Sugestใo","Pedido", "Pre็o Unit." ,"Pendente","Produto","Descri็ใo Produto"}

Private nMinCusto    := 0
Private oGetMinCusto
Private dDtMinCusto  := dDatabase
Private oGetDtMinCus
Private nMaxCusto    := 0
Private oGetMaxCusto
Private dDtMaxCusto  := dDatabase
Private oGetDtMaxCus
Private cCodProd     := Space(TamSX3("B1_COD")[1])
Private oGetCodProd
Private cUnidProd    := Space(TamSX3("B1_UM")[1])
Private oGetUnidProd
Private nUltCompra   := 0
Private oGetUltCompra
Private dDtUltCompra := dDatabase
Private oGetDtUltCompra
Private nUltPrVenda  := 0
Private oGetUltPrVenda
Private dUltDtVenda  := dDatabase
Private oGetUltDtVenda
Private cNomeFabr    := Space(TamSX3("A2_NOME")[1])
Private oGetNomeFabr
Private cMedatraso    := Space(TamSX3("A2_METR")[1])  
Private oGetMedatraso
Private nMesAtu      := 0
Private oGetMesAtu
Private nMesAnt      := 0
Private oGetMesAnt
Private nEstAtu      := 0
Private oGetMedMes
Private nMedMes    := 0
Private oGetEstAtu
Private oGetAComprar
Private oGetVlrAComprar
Private nAPedir      := 0  //Quantidade selecionada que sera pedida
Private oGetAPedir
Private nVlrAPedir   := 0  //Valor dos itens selecionados que serao pedidos
Private oGetVlrAPedir
Private nPcComDesconto := 0  //Valor total dos produtos a PEDIR com o DESCONTO 1 e o DESCONTO 2 - tela do Pre-PC
Private oGetPcComDesconto
Private nPcDescFinanceiro		:= 0  //Valor do desconto financeiro - tela do Pre-PC
Private oGetPcDescFinanceiro
Private oChk01
Private	oOk          := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo          := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever       := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private cNumDoc		:= " " //Numero do Pedido de compra
Private cDescTela := IIf(nTipoDoc==1,"PRE-PEDIDO DE COMPRA","PRE-COTAวรO DE COMPRA")
Private cArqLogPC	:= "pccriado.log"  //Grava o arquivo de log de erro na criacao de PC pela central de compras.

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DEFINE MSDIALOG oDlg TITLE cDescTela FROM 1,1 TO 40,100

TGroup():New(002,005,073,275," Informa็๕es do Produto ",,,,.T.)
TGroup():New(002,280,073,385," Quantidades ",,,,.T.)
TGroup():New(075,005,229,385," Produtos ",,,,.T.)
TGroup():New(244,005,290,305," Totais ",,,,.T.)
TGroup():New(244,310,290,385," Confirma ",,,,.T.)//Botoes Ok e Cancela

//Caixa Informacoes do Produto
TSay():New(010,010,{|| "Menor      :  "},oDlg,,,,,,.T.)
oGetMinCusto := TGet():New(008,038, bSETGET(nMinCusto),oDlg,40,10,PesqPict("SD1","D1_VUNIT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetDtMinCus := TGet():New(008,080, bSETGET(dDtMinCusto),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,,)
TSay():New(025,010,{|| "Maior       :  "},oDlg,,,,,,.T.)
oGetMaxCusto := TGet():New(023,038, bSETGET(nMaxCusto),oDlg,40,10,PesqPict("SD1","D1_VUNIT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetDtMaxCus := TGet():New(023,080, bSETGET(dDtMaxCusto),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(040,010,{|| "Codigo     :  "},oDlg,,,,,,.T.)
oGetCodProd := TGet():New(038,038, bSETGET(cCodProd),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(055,010,{|| "Fabricante :   "},oDlg,,,,,,.T.)
oGetNomeFabr := TGet():New(053,038, bSETGET(cNomeFabr),oDlg,80,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)


TSay():New(010,140,{|| "Ult. Compra:   "},oDlg,,,,,,.T.)
oGetUltCompra := TGet():New(008,180, bSETGET(nUltCompra),oDlg,40,10,PesqPict("SB1","B1_UPRC"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetDtUltCompra := TGet():New(008,222, bSETGET(dDtUltCompra),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(025,140,{|| "Preco Venda:   "},oDlg,,,,,,.T.)
oGetUltPrVenda := TGet():New(023,180, bSETGET(nUltPrVenda),oDlg,40,10,PesqPict("SD2","D2_PRCVEN"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetUltDtVenda := TGet():New(023,222, bSETGET(dUltDtVenda),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(040,140,{|| "Embalagem  :   "},oDlg,,,,,,.T.)
oGetUnidProd := TGet():New(038,180, bSETGET(cUnidProd),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(055,140,{|| "Media Atraso:  "},oDlg,,,,,,.T.)
oGetMedatraso := TGet():New(053,180, bSETGET(cMedatraso),oDlg,40,10,"@!",,,,,,,.T.,,,,.T.,,,.T.,,,)


//Caixa Quantidades
TSay():New(010,285,{|| "Vd.M.Atual:  "},oDlg,,,,,,.T.)
oGetMesAtu := TGet():New(008,325, bSETGET(nMesAtu)  ,oDlg,40,10,PesqPict("SD2","D2_QUANT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(025,285,{|| "Vd.M.Ante.:  "},oDlg,,,,,,.T.)
oGetMesAnt := TGet():New(023,325, bSETGET(nMesAnt)  ,oDlg,40,10,PesqPict("SD2","D2_QUANT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(040,285,{|| "Med.Mensal:  "},oDlg,,,,,,.T.)
oGetMedMes := TGet():New(038,325, bSETGET(nMedMes),oDlg,40,10,PesqPict("SD2","D2_QUANT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
TSay():New(055,285,{|| "Est.Atual:   "},oDlg,,,,,,.T.)
oGetEstAtu:= TGet():New(053,325, bSETGET(nEstAtu),oDlg,40,10,PesqPict("SB2","B2_QATU"),,,,,,,.T.,,,,.T.,,,.T.,,,)

//Box - Produtos
// Thiago

oLbx01:= TwBrowse():New(085,010,365,137,,aCab1,aTam1,oDlg,,,,{|| DROPCAtuInfo(oLbx01:nAt)},,,,,,,,.F.,,.T.,,.F.,,,)
oLbx01:lColDrag	:= .T.
oLbx01:nFreeze	:= 1
oLbx01:SetArray(aItensPrePC)
cBLinLbx01:= "{If(aItensPrePC[oLbx01:nAt,1]>0,oOk,If(aItensPrePC[oLbx01:nAt,1]<0,oNo,oNever))"
oLbx01:bLDblClick	:={ || ChgMarkLb(oLbx01,aItensPrePC,{|| .T. },.T.), DROGiroFil(lMark01) }


//Montagem da linha da TwBrowse
nI := 2
For nI:= 2 to Len(aCab1)
	If nI == 5   //Custo
		cPicture := PesqPict("SB2","B2_CM1")
	ElseIf nI == 7   // Cod. Produto 
		cPicture := "@!"
	ElseIf nI == 8   //Descricao Produto
		cPicture := "@!"
	Else  //Giro, Qtde. sugerida e pedida
		cPicture := PesqPict("SC7","C7_QUANT")
	EndIf
	if nI = 6  // o campo Pendente eh o elemento _ITPENDENT da array
		cBLinLbx01:= cBLinLbx01 + ", Transform(aItensPrePC[oLbx01:nAT][" + alltrim(Str(_ITPENDENT)) + "], '" + cPicture + "')"
	Elseif nI = 7  // o campo Cod. Produto eh o elemento _ITCODPRD da array
		cBLinLbx01:= cBLinLbx01 + ", Transform(aItensPrePC[oLbx01:nAT][" + alltrim(Str(_ITCODPRD)) + "], '" + cPicture + "')"
	Elseif nI = 8  // o campo Descricao Produto eh o elemento _ITDESCPRD da array
		cBLinLbx01:= cBLinLbx01 + ", Transform(aItensPrePC[oLbx01:nAT][" + alltrim(Str(_ITDESCPRD)) + "], '" + cPicture + "')"
	Else
		cBLinLbx01:= cBLinLbx01 + ", Transform(aItensPrePC[oLbx01:nAT][" + alltrim(Str(nI))+ "], '" + cPicture + "')"
	endif
Next nI
oLbx01:bLine:= { || &(cBLinLbx01 + "}") }

//Marcar todos produtos
oChk01 := TCheckBox():New(229,338, "Marcar Todos", bSETGET(lMark01),oDlg,50, 17,,,,,,,,.T.,,,)
oChk01:bLClicked := {|| T_MarcAl2(@aItensPrePC,@lMark01), DROAtuAPedir(lMark01)  }

TSay():New(252,010,{|| "Necessidade Quant."},oDlg,,,,,,.T.)
TSay():New(252,102,{||  GETMV("MV_SIMB1") },oDlg,,,,,,.T.)
oGetAComprar := TGet():New(250,060, bSETGET(nAComprar),oDlg,40,10,PesqPict("SD1","D1_QUANT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetVlrAComprar := TGet():New(250,110, bSETGET(nVlrAComprar),oDlg,40,10,PesqPict("SF1","F1_VALBRUT"),,,,,,,.T.,,,,.T.,,,.T.,,,)

TSay():New(252,165,{|| "Desc. Financ. % "},oDlg,,,,,,.T.)
TSay():New(252,245,{||  GETMV("MV_SIMB1") },oDlg,,,,,,.T.)
oGetAIADESCFI			:= TGet():New(250,210, bSETGET(nAIADESCFI),oDlg,20,10,PesqPict("SC7","C7_DESC1"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetPcDescFinanceiro	:= TGet():New(250,260, bSETGET(nPcDescFinanceiro),oDlg,40,10,PesqPict("SF1","F1_VALBRUT"),,,,,,,.T.,,,,.T.,,,.T.,,,)

TSay():New(265,010,{|| "Pedido          Quant."},oDlg,,,,,,.T.)
TSay():New(265,102,{||  GETMV("MV_SIMB1") },oDlg,,,,,,.T.)
oGetAPedir					:= TGet():New(263,060, bSETGET(nAPedir),oDlg,40,10,PesqPict("SD1","D1_QUANT"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetVlrAPedir				:= TGet():New(263,110, bSETGET(nVlrAPedir),oDlg,40,10,PesqPict("SF1","F1_VALBRUT"),,,,,,,.T.,,,,.T.,,,.T.,,,)

TSay():New(265,165,{|| "Desc. Merc.    % "},oDlg,,,,,,.T.)
TSay():New(265,245,{|| "Desc. 2     % "},oDlg,,,,,,.T.)
oGetAIADESC1				:= TGet():New(263,210, bSETGET(nAIADESC1 ),oDlg,20,10,PesqPict("SC7","C7_DESC1"),,,,,,,.T.,,,,.T.,,,.T.,,,)
oGetAIADESC2				:= TGet():New(263,278, bSETGET(nAIADESC2 ),oDlg,20,10,PesqPict("SC7","C7_DESC1"),,,,,,,.T.,,,,.T.,,,.T.,,,)

TSay():New(278,010,{|| "Total com o desconto na Mercadoria"},oDlg,,,,,,.T.)
TSay():New(278,102,{||  GETMV("MV_SIMB1") },oDlg,,,,,,.T.)
oGetPcComDesconto		:= TGet():New(276,110, bSETGET(nPcComDesconto  ),oDlg,40,10,PesqPict("SF1","F1_VALBRUT"),,,,,,,.T.,,,,.T.,,,.T.,,,)


Atutelaped()  // Atualiza na tela de pre-pc o conteudo dos campos nAPedir , nVlrAPedir e nPcComDesconto

//Botoes de Confirma/Cancela
oBmt1 := SButton():New(263,320, 1, {|| lRet := .T., oDlg:End() },,)
oBmt2 := SButton():New(263,350, 2, {|| oDlg:End() },,)

ACTIVATE MSDIALOG oDlg CENTER

If lRet
	cDescDoc  := IIf(nTipoDoc==1,"do pedido","da cota็ใo")
	If MsgYesNo("Confirma a gera็ใo "+cDescDoc+" de compras?")
		Processa({|lEnd| DROGeraDoc(@cNumDocIni,@cNumDoc)},,"Gerando documento...")
	EndIf
	
	if empty(cNumDocIni)
		Aviso("Aten็ใo","Nao foi gerado nenhum pedido de Compra "   ,{"Ok"})	
	else
		if alltrim(cNumDocIni) == alltrim(cNumDoc)
			cDescDoc  := IIf(nTipoDoc==1,"Foi gerado o Pedido de Compras de n๚mero ","Foi gerada a Cota็ใo de Compras de n๚mero ")
			Aviso("Aten็ใo",cDescDoc+ cNumDoc ,{"Ok"})
		else
			cDescDoc  := IIf(nTipoDoc==1,"gerado o Pedido de Compras","gerada Cota็ใo de Compras")
			Aviso("Aten็ใo","Foi "+cDescDoc+" do n๚mero "+cNumDocIni +" ao n๚mero " + cNumDoc ,{"Ok"})
		endif
	endif
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcAl2   บAutor  ณAndre Melo          บ Data ณ 14/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marcar todos                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function MarcAl2(aLin,lMark01)

if 	lMark01
	If lSemPreco
		Aviso("Aten็ใo","Nใo ้ possivel marcar todos os itens, pois existe produto sem pre็o cadastrado na tabela selecionada"  ,{"Ok"})
		lMark01 := .f.
	Endif
Endif

If !lSemPreco
	aEval( aLin , { |x,y| aLin[y,1] := If(lMark01,1,-1)})
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROPCAtuInบAutor  ณFernando Machima    บ Data ณ 17/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizar as informacoes de produto quando muda de linha da บฑฑ
ฑฑบ          ณTWBrowse                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROPCAtuInfo(nLinAtu)

Local aArea  := GetArea()

cCodProd  := aItensPrePC[nLinAtu][_ITCODPRD]
oGetCodProd:Refresh()
cUnidProd  := aItensPrePC[nLinAtu][_ITUM]
oGetUnidProd:Refresh()
nUltCompra  := aItensPrePC[nLinAtu][_ITULTPRC]
oGetUltCompra:Refresh()
dDtUltCompra  := aItensPrePC[nLinAtu][_ITDULTCOM]
oGetDtUltCompra:Refresh()
nMinCusto  := aItensPrePC[nLinAtu][_ITMINCUS]
oGetMinCusto:Refresh()
dDtMinCusto  := aItensPrePC[nLinAtu][_ITDMINCUS]
oGetDtMinCus:Refresh()
nMaxCusto  := aItensPrePC[nLinAtu][_ITMAXCUS]
oGetMaxCusto:Refresh()
dDtMaxCusto  := aItensPrePC[nLinAtu][_ITDMAXCUS]
oGetDtMaxCus:Refresh()
cNomeFabr   :=  aItensPrePC[nLinAtu][_ITNOMEFAB]
oGetNomeFabr:Refresh()
cMedatraso  :=  aItensPrePC[nLinAtu][_ITMedatraso]
oGetMedatraso:Refresh()
nEstAtu   :=  aItensPrePC[nLinAtu][_ITESTQATU]
oGetEstAtu:Refresh()
nMesAtu   :=  aItensPrePC[nLinAtu][_ITQTMESAT]
oGetMesAtu:Refresh()
nMesAnt   :=  aItensPrePC[nLinAtu][_ITQTMESAN]
oGetMesAnt:Refresh()
nMedMes := ( nMesAtu + nMesAnt )  / 2
oGetMedMes:Refresh()
nUltPrVenda  := aItensPrePC[nLinAtu][_ITUPRVEND]
oGetUltPrVenda:Refresh()
dUltDtVenda  := aItensPrePC[nLinAtu][_ITUDTVEND]
oGetUltDtVenda:Refresh()

RestArea(aArea)
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROGiroFilบAutor  ณFernando Machima    บ Data ณ 19/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para visualizar a quantidade pedida por produto        บฑฑ
ฑฑบ          ณ(aglutinada por filial)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROGiroFil(lMark01)

Local oDlgFil
Local cPicture
Local nI
Local nPosProd   := 0
Local nOpca      := 0
Local lMark02	 := .F.
//Local aTamFil    := {5,35,40,40,70,40}
Local aTamFil    := {5,35,35,35,35,70}
Local aCabFil    := {" ","Giro","Sugestใo","Pedido","Pendente","Loja"}

Private aLinProdFil     := {}  //Contem as qtdes de giro, sugestao e pedido de todas as filiais do produto selecionado

If aItensPrePC[oLbx01:nAt][_ITMARK] == 1  //Marcado
	
	nPosProd   := Ascan(aProdFilial,{|x| x[1] == aItensPrePC[oLbx01:nAt][_ITCODPRD]})
	
	DBSELECTAREA("AIB")
	DBSETORDER(2)

	IF nTipoDoc ==  1		//Verifica se existe alguma Tabela de Precos cadastrada (Somente se for PC.  Cota็ใo nใo precisa)
		IF ! (AIB->( MsSeek(XFILIAL("AIB")+ cFornece+ cLoja+ cTabPreco+ aItensPrePC[oLbx01:nAt][_ITCODPRD] ) ) ) .or. AIB->AIB_PRCCOM <= 0
			Msgstop("Este produto nใo esta cadastrado nesta tabela de pre็o. " +chr(13)+chr(10)+ "Nใo serแ gerado pedido para este item" )
			aItensPrePC[oLbx01:nAt][_ITMARK] := -1
			Return .F.
		Endif
	Endif
	
	If nPosProd == 0
		MsgAlert("Produto nใo encontrado!")
		Return .F.
	Else
		//Preenche os dados de todas as filiais do produto selecionado
		For nI := 1 to Len(aProdFilial[nPosProd,3])
			Aadd(aLinProdFil,{aProdFilial[nPosProd][3][nI][1], aProdFilial[nPosProd][3][nI][2],aProdFilial[nPosProd][3][nI][3],aProdFilial[nPosProd][3][nI][4],;
			aProdFilial[nPosProd][3][nI][5],aProdFilial[nPosProd][3][nI][6]  })
		Next nI
	EndIf
	
	DEFINE MSDIALOG oDlgFil FROM 20,10 TO 300,565 TITLE aItensPrePC[oLbx01:nAt][_ITDESCPRD] PIXEL
	
	oLbx02:= TwBrowse():New(010,008,260,100,,aCabFil,aTamFil,oDlgFil,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx02:lColDrag	:= .T.
	oLbx02:nFreeze	:= 1
	oLbx02:SetArray(aLinProdFil)
	cBLinLbx02:= "{If(aLinProdFil[oLbx02:nAT,1]>0,oOk,If(aLinProdFil[oLbx02:nAT,1]<0,oNo,oNever))"
	oLbx02:bLDblClick	:={ || ChgMarkLb(oLbx02,aLinProdFil,{|| .T. },.T.), DROEditVlr(@lMark02,nPosProd) }
	
	//Montagem da linha da TwBrowse
	nI := 2
	For nI:= 2 to Len(aCabFil)
		If nI == 6   //Loja
			cPicture := "@!"
		Else  //Giro, Qtde. sugerida e pedida
			cPicture := PesqPict("SC7","C7_QUANT")
		EndIf
		cBLinLbx02:= cBLinLbx02 + ", Transform(aLinProdFil[oLbx02:nAT][" + alltrim(Str(nI))+ "], '" + cPicture + "')"
	Next nI
	oLbx02:bLine:= { || &(cBLinLbx02 + "}") }
	
	DEFINE SBUTTON FROM 120, 200 TYPE 1 ENABLE ACTION (nOpca:=1,oDlgFil:End()) OF oDlgFil
	DEFINE SBUTTON FROM 120, 240 TYPE 2 ENABLE ACTION (nOpca:=0,oDlgFil:End()) OF oDlgFil
	
	ACTIVATE MSDIALOG oDlgFil CENTERED
EndIf
Atutelaped()  // Atualiza na tela de pre-pc o conteudo dos campos nAPedir e nVlrAPedir
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROEditVlrบAutor  ณFernando Machima    บ Data ณ 19/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para editar a quantidade a ser pedida/solicitada       บฑฑ
ฑฑบ          ณpara o produto por filial.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROEditVlr(lMark01,nPosProd)

Local nQtdePed := aLinProdFil[oLbx02:nAt][_PRODQTDPED]
Local nQtdeSug := aLinProdFil[oLbx02:nAt][_ITQTDSUG]
Local nOpca    := 0
Local oDlgVlr, _ni

If aLinProdFil[oLbx02:nAt][_PRODMARK] == 1  //Marcado
	
	DEFINE MSDIALOG oDlgVlr FROM  69,70 TO 160,331 TITLE "Pr้-Pedido de Compras" PIXEL
	
	@ 1, 2 TO 24, 128 OF oDlgVlr	PIXEL
	@ 7, 68 MSGET nQtdePed Picture "@E 9999999.99" VALID  nQtdePed > 0 SIZE 54, 10 OF oDlgVlr PIXEL		// A valida็ใo nQtdePed <= nQtdeSug foi retirada seguindo o sistema anterior. Segundo o usuario Carlos, muitas vezes a quantidade estimada nใo representa a necessidade real . 
	@ 8, 9 SAY "Quantidade pedida"  SIZE 54, 7 OF oDlgVlr PIXEL
	DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (IIf((nQtdePed > 0 ),;
	(nOpca:=1,aLinProdFil[oLbx02:nAt][_ITQTDPED]:=nQtdePed,oDlgVlr:End()),nOpca:=0)) OF oDlgVlr
	DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION (nOpca:=0,oDlgVlr:End()) OF oDlgVlr
	
	ACTIVATE MSDIALOG oDlgVlr CENTERED
	
	//Se cancelar a operacao, desmarca
	If nOpca == 0
		aLinProdFil[oLbx02:nAt][_ITMARK]  := -1
	Else
		aLinProdFil[oLbx02:nAt][_PRODQTDPED] := nQtdePed
		aProdFilial[nPosProd][3][oLbx02:nAt][_PRODQTDPED] := nQtdePed
		
		nQtdePed := 0
		For _ni = 1 to len(aLinProdFil)
			if aLinProdFil[ _ni ][_PRODMARK] == 1
				nQtdePed += aLinProdFil[_ni][_PRODQTDPED]
			endif
		Next
		aItensPrePC[oLbx01:nAt][_ITQTDPED] := nQtdePed
		
	EndIf
Else
	lMark01     := .F.  //Desmarca opcao "Marcar Todos"
	oChk01:Refresh()
	
	aItensPrePC[oLbx01:nAt][_PRODQTDPED] -= nQtdePed
	nQtdePed := 0
	For _ni = 1 to len(aLinProdFil)
		if aLinProdFil[_nI][_PRODMARK] == 1 .and. _nI <> oLbx02:nAt  //Como estou desmarcando linha atual, nใo a considero na soma
			nQtdePed += aLinProdFil[_ni][_PRODQTDPED]
		endif
	Next
	
EndIf

For _nI := 1 to len( aProdFilial[nPosProd][3] )
	aProdFilial[nPosProd][3][ _nI ][_PRODMARK] := aLinProdFil[ _nI][_ITMARK]
Next

if nQtdePed == 0
	aItensPrePC[oLbx01:nAt][_ITMARK] := -1
	lMark01 := .f.
Endif

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROAtuAPedบAutor  ณFernando Machima    บ Data ณ 19/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao dos valores a pedir qdo seleciona Marcar Todos  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROAtuAPedir(lMark01)

Local nX

nAPedir    := 0
nVlrAPedir := 0
nPcComDesconto := 0
nPcDescFinanceiro := 0
If lMark01
	For nX := 1 to Len(aItensPrePC)
		nAPedir    +=  aItensPrePC[nX][_ITQTDPED]
		nVlrAPedir +=  aItensPrePC[nX][_ITQTDPED] * aItensPrePC[nX][_ITCUSTO]
	Next nX

	nPcComDesconto := nVlrAPedir
	If nAIADESC1 > 0  .and. nPcComDesconto > 0
		nPcComDesconto -= nPcComDesconto / 100 * nAIADESC1
	Endif

	If nAIADESC2 > 0 .and. nPcComDesconto > 0
		nPcComDesconto -= nPcComDesconto / 100 * nAIADESC2
	Endif

	If nAIADESCFI > 0 .and. nPcComDesconto > 0
		nPcDescFinanceiro :=  nPcComDesconto  / 100 * nAIADESCFI
	Endif

EndIf

oGetAPedir:Refresh()
oGetVlrAPedir:Refresh()
oGetPcComDesconto:Refresh()
oGetPcDescFinanceiro:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROGeraDocบAutor  ณFernando Machima    บ Data ณ 19/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o pedido ou cotacao de precos com base nos dados       บฑฑ
ฑฑบ          ณselecionados                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROGeraDoc(cNumDocIni,cNumDoc)

Local nX, nFornec
Local _cFilial := "XXX"
Local _lfirstCPC := .t.   // Primeira Cotacao ou PC
Local cItem		:= ""
Local cIdent	:= ""
Local lGeraPedido  := .f.
Local cNumCot
Local aCab := {} , aItem := {}
Local aArea := GetArea()
Local nLeAitem
Local aFilialpro := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  ****** Descrico do array aFilialpro  *****  ณ
//รฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
//ณ Dimensoes  ณ Descrico						   ณ
//รฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
//ณ    n,01	   ณ Cod. Filial                        ณ
//ณ    n,02	   ณ Cod. Produto                    ณ
//ณ    n,03   ณ  Local                               ณ
//ณ    n,04   ณ  Descricao Produto            ณ
//ณ    n,05   ณ  Quantidade                      ณ
//ณ    n,06   ณ  Unidade de Medida           ณ
//ณ    n,07   ณ  Segunda Unidade de Medida    ณ
//ณ    n,08   ณ  Codigo do .........                   ณ
//ณ    n,09   ณ  Qtd. Pedida                      ณ
//ณ    n,10   ณ  Preco de Compra                    ณ
//ณ    n,11  ณ  TES                     ณ
//ณ    n,12   ณ  Fabrica                   ณ
//ณ    n,13,1  ณ  Cod. Filial            ณ
//ณ    n,13,2 ณ  Qtd. Pedida                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					

dbSelectArea("SA2")
dbSetOrder(1)
dbSelectArea("SB1")
dbSetOrder(1)
DBSELECTAREA("AIA")
DBSETORDER(1)
DBSELECTAREA("AIB")
DBSETORDER(2)

BEGIN TRANSACTION

If nTipoDoc == 1  	//1= Inclusao do pedido de compra    2= Inclusao de cotacao de compra
	
	// Se EMPTY(cFilEntreg) aglutino pc por filial senao gero 1 pc para cada filial
	Filialprod(@aFilialpro, aItensPrePC, aProdFilial, lAglutina )
	if ! empty(aFilialpro)
		
		DBSELECTAREA("AIB")
		DBSETORDER(2)
		_cFilial := "XXX"
		For nX := 1 to Len(aFilialpro)
			
			if _cFilial	<>  aFilialpro[ nX,1 ]
				_cFilial	:= aFilialpro[ nX,1 ]
				cNumDoc     := Space(TamSX3("C7_NUM")[1])
				cItem		:= StrZero(1,Len(SC7->C7_ITEM))
				aItem:= {}
				AIA->( MsSeek(XFILIAL("AIA")+ cFornece+ cLoja+ cTabPreco ) )
				aCab:=	{{"C7_NUM"     ,cNumDoc  	     ,Nil},; // Numero do Pedido
				{ "C7_EMISSAO" ,dDataBase  	     ,Nil},; // Data de Emissao
				{ "C7_FORNECE" ,cFornece         ,Nil},; // Fornecedor
				{ "C7_LOJA"    ,cLoja            ,Nil},; // Loja do Fornecedor
				{ "C7_COND"    ,cCondPagto 	     ,Nil},; // Condicao de pagamento
				{ "C7_CONTATO" ,"             "  ,Nil},; // Contato
				{ "C7_DESC1"  , AIA->AIA_DESC1					,Nil},;  //*** Desconto 1 da Tabela de Pre็os
				{ "C7_DESC2"  , AIA->AIA_DESC2					,Nil},;  //*** Desconto 2 da Tabela de Pre็os
				{ "C7_FILENT"  ,if(EMPTY(cFilEntreg), aFilialpro[ nX, 1] , cFilEntreg )  ,Nil}} // Filial Entrega
			Endif
			
			DBSELECTAREA("AIB")
			IF AIB->( MsSeek(XFILIAL("AIB")+ cFornece+ cLoja+ cTabPreco+ aFilialpro[ nX, 02] ) ) .AND. AIB->AIB_PRCCOM > 0
				aadd(aItem,	{{"C7_ITEM"     ,cItem           				,Nil},; //Numero do Item
				{ "C7_VLRDFIN",  0					,Nil},; //*** Valor do Desconto Financeiro
				{ "C7_QUANT"  ,aFilialpro[ nX, 05]				,Nil},; //Quantidade
				{ "C7_PRECO"  , AIB->AIB_PRCCOM					,Nil},; //Preco
				{ "C7_DESCFIN", AIA->AIA_DESCFI					,Nil},; //*** Desconto Financeiro
				{ "C7_OBS"	  , " "   ,Nil},;				// if(!EMPTY(cFilEntreg), "Filial " + aFilialpro[ nX, 1] , " " )
				{ "C7_PRODUTO",aFilialpro[ nX, 02]				,Nil},; //Codigo do Produto
				{ "C7_UM"     ,aFilialpro[ nX, 06]				,Nil},; //Unidade de Medida
				{ "C7_QTDACLA",aFilialpro[ nX, 05]				,Nil},; //Quantidade
				{ "C7_CODTAB" ,cTabPreco						,Nil},; //Tabela de Preco
				{ "C7_TES"    ,aFilialpro[ nX, 11]				,Nil},; //TES
				{ "C7_DATPRF" ,dDataBase						,Nil},; //Data De Entrega
				{ "C7_FLUXO"  ,"S"								,Nil},; //Fluxo de Caixa (S/N)
				{ "C7_ORIGEM" , "DROPREPC"				,Nil},;  	// Ap๓s criar e utilizar ponteiros para esta array excluir este elemento (desnecessario) sem desposicionar os demais elementos 
				{ "C7_TIPO"   , 1								,Nil},; //PC
				{ "C7_QTDACLA", aFilialpro[ nX, 05]				,Nil},; //Quantidade a classificar
				{ "C7_ENVIAR" , " "								,Nil},;
				{ "C7_ENVNIVE", "00"							,Nil},;
				{ "C7_ORIGEM" , "DROPREPC"						,Nil},;
				{ "C7_LOCAL"  ,aFilialpro[ nX, 03]				,Nil}}) //Localizacao

				cItem := Soma1(cItem,Len(SC7->C7_ITEM))
			ENDIF

			// Se aglutino gero um PC somente no ultimo elemento
			If  nX == Len(aFilialpro)
				lGeraPedido := .t.
			endif
			
			If  nX <> Len(aFilialpro) .and. ! lAglutina		//Se Nใo aglutino gero PC a cada mudanca de filial
				If _cFilial <> aFilialpro[ nX+1 ,1 ]
					lGeraPedido := .t.
				endif
			endif
			
			if lGeraPedido
				lGeraPedido := .f.
				
				// nas linhas abaixo calculo e gravo nos itens o desconto financeiro do PC atual (nใo a soma de todos os PCs )
				nDescFinPC := 0
				nTotPedido := 0
				For nLeAitem = 1 to len(aItem)
					nTotPedido += aItem [nLeAitem] [3] [2] * aItem [nLeAitem] [4] [2]
				Next
				
				nComDesconto := nTotPedido
				If nAIADESC1 > 0  .and. nComDesconto > 0
					nComDesconto -= nComDesconto / 100 * nAIADESC1
				Endif
				
				If nAIADESC2 > 0 .and. nPcComDesconto > 0
					nComDesconto -= nComDesconto / 100 * nAIADESC2
				Endif
				
				If nAIADESCFI > 0 .and. nComDesconto > 0
					nDescFinPC :=  nComDesconto  / 100 * nAIADESCFI
				Endif

				nDescMercadoria := nTotPedido - nComDesconto
				cMsgObs	:=  if(nDescFinPC			> 0 , "Desconto Financeiro de R$ " +alltrim( transform( nDescFinPC , '@E 999,999,999.99' ) )  , "Sem Desconto Financeiro" )
				cMsgObs	+= "."+ space(4)+  if(nDescMercadoria	> 0 , 	"Desconto na Mercadoria de R$ " + alltrim( transform( nDescMercadoria , '@E 999,999,999.99' ) ) , "Sem Desconto na Mercadoria" )
				
				For nLeAitem = 1 to len(aItem)
					if nLeAitem == 1
						aItem [ 1] [6] [2] := cMsgObs
					endif
					aItem [nLeAitem] [2] [2] := nDescFinPC
				Next
				
				
				if ! T_GravaPed(aCab,aItem,aFilialpro, lAglutina )
					cTxtLog  := "Erro na Inclusใo automแtica do pedido de compra N๚mero: "+ cNumDoc
					T_EDIGrvLog( cTxtLog , cArqLogPC )
					lGeraLog  := .T.
				else
					if _lfirstCPC
						_lfirstCPC := .f.
						cNumDocIni := cNumDoc
					endif
				endif
			endif
		Next nX
	endif
Else   //Cotacao(SC8)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInclusao da cotacao de compra                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Filialprod(@aFilialpro, aItensPrePC, aProdFilial, .T. )		// A cota็ใo sempre ้ gerada aglutinada por filial
	if !empty(aProdFilial)
		For nFornec := 1 To Len(aFornec)
			aQuebra	:= {}
			cItem	:= StrZero(1,Len(SC8->C8_ITEM))
			cNumCot	:= GetNumSc8(.F.)
			cNumDoc := cNumCot
			if _lfirstCPC
				_lfirstCPC := .f.
				cNumDocIni := cNumDoc
			endif
			
			If ( Empty(cIdent) )
				cIdent   := StrZero(1,Len(SC8->C8_IDENT))
			ELSE
				cIdent   := StrZero(VAL(cIdent)+1 ,Len(SC8->C8_IDENT))
			EndIf
			
			For Nx = 1 to len(aFilialpro)
				
				If ( Len(aQuebra)>998 ) // Aqui eh previsto ate 998 Itens na cotacao
					cNumCot	:= GetNumSc8(.F.)
					cItem	:= StrZero(1,Len(SC8->C8_ITEM))
					aQuebra	:= {}
				EndIf
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPosiciona Registros                                                     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				dbSelectArea("AIB")
				MsSeek(XFILIAL("AIB")+ cFornece+ cLoja+ cTabPreco+ aFilialpro[ nX, 02] )
				dbSelectArea("SA2")
				MsSeek(xFilial("SA2")+aFornec[nFornec,1]+aFornec[nFornec,2])
				dbSelectArea("SB1")
				MsSeek(xFilial("SB1")+aFilialpro[ nX, 02])
				
				RecLock("SC8",.T.)
				SC8->C8_FILIAL		:=  xFilial("SC8")
				SC8->C8_FILENT		:=  if(EMPTY(cFilEntreg), aFilialpro[ nX, 1] , cFilEntreg )
				SC8->C8_NUM			:=  cNumCot
				SC8->C8_ITEM			:=  cItem
				SC8->C8_EMISSAO	:=  dDataBase
				SC8->C8_CONTATO	:=  SA2->A2_CONTATO
				SC8->C8_GRUPCOM	:=  " "
				SC8->C8_COND		:=  cCondPagto
				SC8->C8_CODTAB	:=  cTabPreco
				SC8->C8_FORNECE	:=  aFornec[nFornec,1]
				SC8->C8_LOJA			:=  aFornec[nFornec,2]
				SC8->C8_PRODUTO	:=  aFilialpro[ nX, 02]
				SC8->C8_PRAZO		:=  SB1->B1_PE
				SC8->C8_UM			:=  aFilialpro[ nX, 06]
				SC8->C8_VALIDA		:=  ddatabase + 30
				SC8->C8_QUANT		:=  aFilialpro[ nX, 05]
				SC8->C8_NUMPRO	:=  "01"
				SC8->C8_DATPRF		:= dDataBase
				SC8->C8_NUMSC		:= " "
				SC8->C8_ITEMSC		:= " "
				SC8->C8_OBS			:= " "				//if( !EMPTY(cFilEntreg), "Filial " + aFilialpro[ nX, 1] , " " )
				SC8->C8_IDENT		:= cIdent
				SC8->C8_SEGUM		:= aFilialpro[ nX, 07]
				SC8->C8_QTSEGUM := aFilialpro[ nX, 08]
				SC8->C8_CODTAB	:= " "
				SC8->C8_ORIGEM	:= "DROPREPC"
				SC8->C8_PRECO		:= 0
				SC8->C8_DESC1		:= 0		   		//AIA->AIA_DESC1
				SC8->C8_DESC2		:= 0				//AIA->AIA_DESC2
				SC8->C8_DESCFIN	:= 0				//AIA->AIA_DESCFI
				SC8->C8_VLRDFIN	:= 0				// nPcDescFinanceiro 	 //*** Valor do Desconto Financeiro
				MsUnLock()
				                           
				ConfirmSX8()

				cItem	:= Soma1(cItem)
				If aScan(aQuebra,aFilialpro[ nX, 02] ) == 0
					aadd(aQuebra, aFilialpro[ nX, 02] )
				EndIf
			Next nX
		Next nFornec
	EndIf
EndIf
END TRANSACTION

RestArea(aArea)
Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtutelapedบAutor  ณGeronimo Alves      บ Data ณ 02/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tela o conteudo dos campos nAPedir e nVlrAPedir บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuTelaPed()
Local _nI

nAPedir		:= 0
nVlrAPedir	:= 0

FOR _nI = 1 to len(aItensPrePC)
	If aItensPrePC[_nI][_ITMARK] == 1  //Marcado
		nAPedir    +=  aItensPrePC[_nI][_ITQTDPED]
		nVlrAPedir +=  aItensPrePC[_nI][_ITQTDPED] * aItensPrePC[_ni][_ITCUSTO]
	endif
Next

nPcComDesconto := nVlrAPedir
If nAIADESC1 > 0 .and. nPcComDesconto > 0
	nPcComDesconto -= nPcComDesconto / 100 * nAIADESC1
Endif

If nAIADESC2 > 0 .and. nPcComDesconto > 0
	nPcComDesconto -= nPcComDesconto / 100 * nAIADESC2
Endif

If nAIADESCFI > 0 .and. nPcComDesconto > 0
	nPcDescFinanceiro :=  nPcComDesconto  / 100 * nAIADESCFI
Endif

oGetAPedir:Refresh()
oGetVlrAPedir:Refresh()
oGetPcComDesconto:Refresh()
oGetPcDescFinanceiro:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFilialprodบAutor  ณGeronimo Alves      บ Data ณ 03/03/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlimenta a array aFilialpro com o conteudo das arrays       บฑฑ
ฑฑบ          ณaItensPrePC e aProdfilial.                                  บฑฑ
ฑฑบ          ณaFilialpro esta no formato adequado para gravar o SC7       บฑฑ
ฑฑบ          ณQuando SC7 ou SC8 nao deve ser aglutinada ordeno array no formato {filial,produto,local,etc }                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ Parametrosณ                                                            บฑฑ
ฑฑ aFilialproณArray a ser preenchida para gerar pedidos de compras.       บฑฑ
ฑฑaItensPrePCณ1a. Array de origem das informacoes                         บฑฑ
ฑฑaProdFilialณ2a. Array de origem das informacoes                         บฑฑ
ฑฑlAglutina ณSe aglutina == .T. , array sai em ordem de Produto      บฑฑ
ฑฑบ          ณSenao a ordem sera de Filial + Produto. Esta ordem serah   บฑฑ
ฑฑบ          ณutilizada para gerar PC. sem aglutinar filiais de entrega   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Filialprod(aFilialpro, aItensPrePC, aProdFilial, lAglutina )
Local nX, _nj
Local nPosProduto

//Local nQtdFil := len( aProdFilial )  /  len( aItensPrePC )		// A quantidade de filiais indica quantos elementos do aProdFilial existe para cada Aitensprepc
//nFilial_Ini := 1

For nX = 1 to len(aItensPrePC)				// Leio o aitensPrepc
	If aItensPrePC[nX][_ITMARK] == 1		// Marcado
		For _nJ = 1 to len(aProdFilial[nX,3] )
			If !empty(aProdFilial[nX, 3, _nJ, 4]) .and. aProdFilial[nX, 3, _nJ, 1] = 1
				nPosProduto := len(aFilialpro) + 1
				if lAglutina
					For nPosProduto = 1 to len(aFilialpro)
						if aFilialpro [nPosProduto] [ 2 ] == aProdFilial[nX, 1]
							exit
						endif
					Next
				endif
				
				if lAglutina .and. nPosProduto <= len(aFilialpro)
					aFilialpro[ nPosProduto ] [ 5 ]  += aProdFilial[nX, 3, _nJ, 4]
					aadd(aFilialpro[ nPosProduto ] [ 13 ]  , {  aProdFilial[nX, 3, _nJ, 8] , aProdFilial[nX, 3, _nJ, 4]  } )
				else
					//                     Cod. Filial,                 		Cod. Produto,     Local,                                  Descricao Produto,                     Quantidade
					aadd( aFilialpro, { aProdFilial[nX, 3, _nJ, 8], aProdFilial[nX,1], aItensPrePC[nX][_ITLOCAL], aItensPrePC[nX][_ITDESCPRD], aProdFilial[nX, 3, _nJ, 4], ;
					aItensPrePC[nX][_ITUM], aItensPrePC[nX][_ITSEGUM], ConvUm(aItensPrePC[nX][_ITCODPRD],aProdFilial[nX, 3, _nJ, 4],0,2)   ,   aProdFilial[nX, 3, _nJ, 4], aItensPrePC[nX][_ITCUSTO] ,;
					aItensPrePC[nX][_ITTESPROD], aItensPrePC[nX][_ITFABRIC] ,  {  {aProdFilial[nX, 3, _nJ, 8] , aProdFilial[nX, 3, _nJ, 4] }  }  } )
					

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  ****** Descrico do array aFilialpro  *****  ณ
//รฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
//ณ Dimensoes  ณ Descrico						   ณ
//รฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
//ณ    n,01	   ณ Cod. Filial                        ณ
//ณ    n,02	   ณ Cod. Produto                    ณ
//ณ    n,03   ณ  Local                               ณ
//ณ    n,04   ณ  Descricao Produto            ณ
//ณ    n,05   ณ  Quantidade                      ณ
//ณ    n,06   ณ  Unidade de Medida           ณ
//ณ    n,07   ณ  Segunda Unidade de Medida    ณ
//ณ    n,08   ณ  Codigo do .........                   ณ
//ณ    n,09   ณ  Qtd. Pedida                      ณ
//ณ    n,10   ณ  Preco de Compra                    ณ
//ณ    n,11  ณ  TES                     ณ
//ณ    n,12   ณ  Fabrica                   ณ
//ณ    n,13,1  ณ  Cod. Filial            ณ
//ณ    n,13,2 ณ  Qtd. Pedida                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					
					
					
					
					
					
					
					
					
				endif
			Endif
		Next
	Endif
Next

//Quando lAglutina = .T.  ordeno array por produto para consolidar as filiais
//Quando lAglutina = .F.  ordeno array por Filial + produto para quebrar as filiais

if lAglutina
	bOrdem	:=  &("{ |x,y| x[2] < y[2] }")   // Produto
else
	bOrdem	:=  &("{ |x,y|  x[1]+x[2] < y[1]+y[2]  }")   // Filial + Produto
endif
aSort(aFilialpro,,,bOrdem)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณGravaPed    ณ Autor ณGeronimo B. Alves    ณ Data ณ 07/03/05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRecebe array aCab e aItem  e grava Pedido de Compras        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nil                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObs       ณPara obter o numero do PC criado utilizo a variavel cNumDoc ณฑฑ
ฑฑณ          ณela eh atualizada no P.E. MT120GRV                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Template Function GravaPed(aCab,aItem,aFilialpro, lAglutina )
Local 	nItem := 0

lMsErroAuto := .f.
MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)
IF ! lMSErroAuto
	IF ( __lSx8 )
		ConfirmSX8()
	EndIF
	DbSeek( xfilial("SC7") + cNumDoc )
	While C7_FILIAL + C7_NUM  == xfilial("SC7") + cNumDoc
		nItem++
		RecLock("SC7",.F.)
		C7_FLUXO 	:= aItem [nItem] [11] [2]		// For็o gravacใo deste campo pois no Reenvio rotina esta gravando sempre com " "
		MsUnLock()		
		DbSkip()
	Enddo		
	// a Variavel cNumDoc eh atualizada com o conteudo de CA120NUM no Ponto de entrada MT120GRV
	SalPediFil(cNumDoc,aFilialpro, lAglutina )		// Esta fun็ใo grava arquivo LHU que desmembra a quantidade do pedido entre a filial de entrega e as demais filiais de acordo com as necessidades de cada filial.
Else
	MostraErro()
	RollBackSx8()
	DisarmTransaction()
Endif
Return ! lMSErroAuto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณGetNumSC8 ณ Autor ณEduardo Riera          ณ Data ณ 19.05.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณInicializa o Numero das Cotacoes de Compra                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNumero da Cotacao de Compra                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณlConfirma : Confirma a utilizacao do Numero                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GetNumSC8(lConfirma)

Local aArea	   := GetArea()
Local aAreaSC8 := SC8->(GetArea())
Local cNumCot  := GetSx8Num("SC8","C8_NUM")
Local nSaveSX8 := GetSX8Len()

lConfirma := IIf(lConfirma==Nil,.F.,lConfirma)

dbSelectArea("SC8")
dbSetOrder(1)
While ( SC8->(MsSeek(xFilial("SC8")+cNumCot)) )
	While ( GetSX8Len() > nSaveSX8 )
		ConfirmSX8()
	EndDo
	cNumCot := GetSx8Num("SC8","C8_NUM")
EndDo
If ( lConfirma )
	While ( GetSX8Len() > nSaveSX8 )
		ConfirmSx8()
	EndDo
EndIf

RestArea(aAreaSC8)
RestArea(aArea)

Return cNumCot

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณProgram   ณSalPediFilณ Autor ณGeronimo B. Alves      ณ Data ณ 09/03/05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Esta fun็ใo grava arquivo LHU que desmembra a quantidade   ณฑฑ
ฑฑณ          ณ do pedido entre a filial de entrega e as demais filiais    ณฑฑ 
ฑฑณ          ณ de acordo com as necessidades de cada filial.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC Function SalPediFil(cNumDoc,aFilialpro, lAglutina )
Local nRecSC7  := ""
Local aArea	   := GetArea()
Local nPosProduto
Local _nI

dbselectarea("LHU")
DBSETORDER(1)
dbselectarea("SC7")
MsSeek(XFILIAL("SC7")+ cNumDoc )
nRecSC7  := recno()

While !eof() .and. cNumDoc == SC7->C7_NUM
		
	For nPosProduto = 1 to len(aFilialpro)
		For _nI = 1 to len(aFilialpro[ nPosProduto ] [13]   )		// Leio as Filiais das necessidades
			if aFilialPro[ nPosProduto ] [ 2 ] <> SC7->C7_PRODUTO		// pesquiso a array inteira a cada registro do PC pois pode ocorrer PC com o mesmo Produto em itens diferentes.
				loop
			endif			
 
			dbselectarea("LHU")
			if MsSeek( XFILIAL("LHU") + XFILIAL("SC7") + SC7->C7_NUM+ SC7->C7_ITEM+ SC7->C7_SEQUEN + aFilialpro[nPosProduto][13][_nI][1] )
				RecLock("LHU",.F.)
				LHU->LHU_SALPED 		:= aFilialpro[nPosProduto][13][_nI][2]		// Qtd. Pedida por produto e necessidade de filial p/ relatorios podera ser ajustada nos retornos dos EDI.
				LHU->LHU_QTDPED		:= aFilialpro[nPosProduto][13][_nI][2]		// Qtd. Pedida por produto e necessidade de filial p/ relatorios ficarแ fixo para manter o historico.
				MsUnLock()
			else
				RecLock("LHU",.T.)
				LHU->LHU_FILIAL			:= XFILIAL("LHU")
				LHU->LHU_FILPED			:=XFILIAL("SC7")
				LHU->LHU_NUM			:= SC7->C7_NUM
				LHU->LHU_ITEM			:= SC7->C7_ITEM
				LHU->LHU_SEQUEN		:= SC7->C7_SEQUEN
				LHU->LHU_PRODUT		:= SC7->C7_PRODUTO
				LHU->LHU_DESCRI		:= SC7->C7_DESCRI
				LHU->LHU_LOCAL			:= SC7->C7_LOCAL
				LHU->LHU_FILNEC		:= aFilialpro[nPosProduto][13][_nI][1]
				LHU->LHU_SALPED		:= aFilialpro[nPosProduto][13][_nI][2]	// Usar este cpo nos relatorios. Qtd. Pedida (e atualizada) por prod./neces. da filial 
				LHU->LHU_QTDPED		:= aFilialpro[nPosProduto][13][_nI][2]
				LHU->LHU_AGLUTI		:= IF( lAglutina , "S" , "N" )
				MsUnLock()
			endif			
		Next
	Next
	
	dbselectarea("SC7")
	dbskip()
Enddo

RestArea(aArea)
dbgoto(nRecSC7)
Return .T.