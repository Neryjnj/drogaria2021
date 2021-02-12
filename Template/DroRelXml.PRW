#Include "Protheus.ch"
#INCLUDE "REPORT.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DRORELXML
Relatorio de Geração XML ANVISA
@author  Varejo
@version 	P12.1.07
@since   	19/10/2015
@obs     
@sample DRORELXML()
/*/
//-------------------------------------------------------------------
Function DRORELXML
Local oReport //Objeto Report
Local cPerg  := 'DroXML'//Consulta
Local cAlias := getNextAlias() //Alias

#IFDEF TOP

	Pergunte(cPerg,.T.)

	oReport := DroXmlDef(cAlias, cPerg)
	oReport:printDialog()

#ELSE
	MsgStop ("Relatório incompatível para este tipo de banco de dados !")//"Relatório incompatível para este tipo de banco de dados !"

#ENDIF

return
//-------------------------------------------------------------------
/*/{Protheus.doc} DroXmlDef
Relatorio de Geraçao XML ANVISA - Criação da estrutura do relatório
@param   	cAlias - Alias
@param   	cPerg - Pergunta
@author		Varejo
@version 	P12.1.07
@since   	19/10/2015
@obs     
@sample DroXMlDef(cAlias,cPerg)
/*/
//-------------------------------------------------------------------
Static Function DroXmlDef(cAlias,cPerg)

local cTitle  := "Relatório de Geração XML ANVISA" //"Relatório de Transmissão XML ANVISA"
local cHelp   := "Permite gerar um relatório para visualizar as gerações de XML para ANVISA" //"Permite gerar um relatório para visualizar as gerações de XML para ANVISA"

local oReport := nil
local oSection1 := nil

oReport	:= TReport():New('DroXmlDef',cTitle,cPerg,{|oReport|DroPerPrt(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Geração Xml/Inventario" ,{"LK9"},{}) //"Produtos com Perdas"

//       New(oParent   ,cName      ,cAlias  ,cTitle ,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection1,"LK9_DATA"	, "LK9", "Data") 			//"Data"
TRCell():New(oSection1,"LK9_DESCRI" , "LK9", "Operação") 	//"Descr.Produto"
TRCell():New(oSection1,"LK9_OBSPER" , "LK9", "Usuário Gerador") 		//"Observação"

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

cEndQuery := " AND LK9_DATA >= '" + DToS(MV_PAR01) + "' "
cEndQuery += " AND LK9_DATA <= '" + DToS(MV_PAR02) + "' "

cEndQuery += " ORDER BY LK9_DATA "

cEndQuery	:= "%"+cEndQuery+"%"
	
BeginSQL Alias cAlias
	
	Column LK9_DATA as Date

	SELECT LK9_DATA, LK9_DESCRI, LK9_OBSPER 

	FROM %Table:LK9%  LK9
 
	WHERE LK9.%NotDel% 
	AND LK9_FILIAL = %xFilial:LK9% 
	AND LK9_TIPMOV IN ('5','6')  %Exp:cEndQuery%
	
EndSQL               

oSection1b:EndQuery()

oReport:SetMeter((cAlias)->(LastRec()))

oSection1b:Print()

Return 