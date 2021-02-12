#Include "Protheus.ch"
#INCLUDE "REPORT.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DRORELPE
Relatorio de Pedidos Integrado e-commerce CiaShop
@author  Varejo
@version 	P12.1.07
@since   	14/10/2015
@obs     
@sample DRORELPE()
/*/
//-------------------------------------------------------------------
Function DRORELPE

local oReport //Objeto Report
local cPerg  := 'DROPER'//Consulta
local cAlias := getNextAlias() //Alias

#IFDEF TOP
	dbSelectArea("LXB")  // colocado aqui por causa da pesquisa F3 no motivo de perda
	Pergunte(cPerg,.T.)

	oReport := DroPerDef(cAlias, cPerg)
	oReport:printDialog()

#ELSE
	MsgStop ("Relatório incompatível para este tipo de banco de dados !")//"Relatório incompatível para este tipo de banco de dados !"
#ENDIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DroPerDef
Relatorio de Produtos com perda - Criação da estrutura do relatório
@param   	cAlias - Alias
@param   	cPerg - Pergunta
@author		Varejo
@version 	P12.1.07
@since   	14/10/2015
@obs     
@sample DroPerDef(cAlias,cPerg)
/*/
//-------------------------------------------------------------------
Static Function DroPerDef(cAlias,cPerg)
Local cTitle	:= "Relatório de Perdas Produtos" //"Relatório de Perdas Produtos"
Local cHelp		:= "Permite gerar um relatório para visualizar os Produtos com perdas." //"Permite gerar um relatório para visualizar os Produtos com perdas."
Local oReport 	:= nil
Local oSection1 := nil

oReport	:= TReport():New('DroPerDef',cTitle,cPerg,{|oReport|DroPerPrt(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Produtos com Perdas" ,{"LK9"},{}) //"Produtos com Perdas"

//       New(oParent   ,cName      ,cAlias  ,cTitle ,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection1,"LK9_DATAPE"	, "LK9", "Data") 			//"Data"
TRCell():New(oSection1,"LK9_DOC" 	, "LK9", "Documento") 		//"Documento"
TRCell():New(oSection1,"LK9_CODPRO" , "LK9", "Cod.Produto") 	//"Cod.Produto"
TRCell():New(oSection1,"LK9_DESCRI" , "LK9", "Descr.Produto") 	//"Descr.Produto"
TRCell():New(oSection1,"LK9_UM" 	, "LK9", "Unidade") 		//"Unidade"
TRCell():New(oSection1,"LK9_LOTE" 	, "LK9", "Lote") 			//"Lote"
TRCell():New(oSection1,"LK9_MTVPER" , "LK9", "Cod. Perda") 		//"Cod. Perda"
TRCell():New(oSection1,"LX5_DESCRI" , "LX5", "Descrição") 		//"Descrição"
TRCell():New(oSection1,"LK9_QUANT"  , "LK9", "Quantidade", "@E 999999", 13,,,,,"RIGHT") //"Quantidade"
TRCell():New(oSection1,"LK9_OBSPER" , "LK9", "Observação") 		//"Observação"

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} DroPerPrt
Relatorio de Produtos com perda - Montagem dos dados do relatório
@param   	oReport - Objeto Report
@param   	cAlias - Alias
@author  	Varejo
@version 	P12.1.07
@since   	14/10/2015
@obs     
@sample DroPerPrt(oReport,cAlias)
/*/
//+-----------------------------------------------------------------------------------------------+
Static Function DroPerPrt(oReport,cAlias)
Local oSection1b := oReport:Section(1) //Objeto seção
Local cEndQuery  := 0 

oSection1b:BeginQuery()

 cEndQuery := " AND LK9_DATAPE >= '" + DToS(MV_PAR01) + "' "
 cEndQuery += " AND LK9_DATAPE <= '" + DToS(MV_PAR02) + "' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Motivo de Perda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR03)
	cEndQuery += " AND LK9_MTVPER = '" + Alltrim(MV_PAR03) + "' "           
Endif
	
cEndQuery += " ORDER BY LK9_DATAPE "

cEndQuery	:= "%"+cEndQuery+"%"
	
BeginSQL Alias cAlias
	
	Column LK9_DATAPE as Date

	SELECT LK9_DOC, LK9_CODPRO, LK9_DESCRI, LK9_UM, LK9_QUANT, LK9_LOTE,
	LK9_MTVPER,LX5_DESCRI ,LK9_DATAPE, LK9_OBSPER 

	FROM %Table:LK9% LK9
 
	INNER JOIN %Table:LX5% LX5
	ON LX5_FILIAL =  %xFilial:LX5%
	AND LX5_CHAVE = LK9_MTVPER 
	AND LX5_TABELA = 'T6' 
	AND	LX5.%NotDel%

	WHERE LK9.%NotDel% 
	AND LK9_FILIAL = %xFilial:LK9% 
	AND LK9_TIPMOV = 4  %Exp:cEndQuery%
	
EndSQL               

oSection1b:EndQuery()

oReport:SetMeter((cAlias)->(LastRec()))

oSection1b:Print()

Return