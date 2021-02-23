#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1942 ; Return                     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJADadosTransacao บAutor  ณVENDAS CRM  บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArmazena as informacoes para realizacao de uma transacao    บฑฑ 
ฑฑบ          ณutilizando TEF.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJADadosTransacao

	Data nValor														//Valor da transacao
   	Data nCupom														//Numero de identificacao da transacao
   	Data dData														//Data da transacao
   	Data cHora														//Hora da transacao
	Data nTipoTrans													//Tipo da transacao utilizado o DEFTEF.CH 
	Data lUltimaTrn                                                 //Ultima transacao - Utilizada para o gerenciador Direcao
	Data cRede														//Rede da Transacao
	Data oRetorno													//Objeto do tipo LJATransacaoTef
	Data nParcela													//Numero de parcelas para vendas parceladas
	Data dDataVcto  												//Data da transacao de pre-datado	
	Data cOperador													//Operador da venda
	Data cTpDoc														//tipo de documento utilizado no pbm => 0 - ecf, 1 - nfce, 2 -sat
	
	Method New()
	Method Retorno()

EndClass                

/*---------------------------------------------------------------------------
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
---------------------------------------------------------------------------*/
Method New(	nValor, 		nCupom, 		dData,	cHora, ;
			nTipoTrans,		lUltimaTrn,		cRede,	cTpDoc, ;
			cOperador) Class LJADadosTransacao 
			
Default lUltimaTrn := .T. //Valida apenas para gerenciador Direcao
Default cTpDoc	   := "1" //Insiro padrใo NFCE

Self:nValor		:= nValor
Self:nCupom		:= nCupom
Self:dData		:= dData
Self:cHora		:= cHora
Self:nTipoTrans	:= nTipoTrans
Self:lUltimaTrn	:= lUltimaTrn   
Self:oRetorno 	:= Nil   
Self:cRede		:= cRede
Self:nParcela	:= 0
Self:dDataVcto	:=	CtoD("  /  /  ")
Self:cOperador  := cOperador
Self:cTpDoc		:= cTpDoc //tipo de documento utilizado no pbm => 0 - ecf, 1 - nfce, 2 -sat

Return Self 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetorno      บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtem o retorno da classe.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Retorno() Class LJADadosTransacao
Return Self:oRetorno 
