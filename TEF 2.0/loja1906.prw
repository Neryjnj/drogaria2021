#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1906.CH"

Static lUsePayHub := Nil //Variแvel que controla se o ambiente estแ atualizado para poder utilizar o Payment Hub.

Function LOJA1906 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCConfiguradorTefบAutor  ณVENDAS CRM  บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as configuracoes de TEF disponiveis para a aplica- บฑฑ 
ฑฑบ          ณ -cao.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCConfiguradorTef

	Data oCCCD
	Data oCheque
	Data oCB
	Data oRecCel                   
	Data oPBM 
	Data oCfgTef
	Data oCupom
	Data lAtivo
	Data lInfAdm  
	Data aFormas    
	Data aAdmin
	Data oComSitef
	Data oComPaymentHub
	Data oPgDig
	
	Method New()
	Method GetCCCD()
	Method GetCheque()
	Method GetCB()
	Method GetRecCel()
	Method GetPBM()  
	Method GetCupom()
	Method ISCCCD()
	Method ISCheque()
	Method ISCB()
	Method ISRecCel()
	Method ISPBM()
	Method ISAtivo()
	Method Carregar()
	Method AtivaSitef()
	Method AtivaDisc()
	Method AtivaPayGo()
	Method AtivaDirecao()
	Method AtivaCupom() 
	Method AtivaFormas()
	Method AtivaAdm()
	Method Fechar() 
	Method GetAdm()			//Indica se o configurador necessita de administradora Financeira 
	Method GetAdmin()		//Retorna as administradoras
	Method GetFormas()
	Method AtivaPaymentHub()
	Method ISPgtoDig()
	Method ISPayHub()
	Method GetPgtoDigital()

EndClass  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCConfiguradorTef

	Self:oCfgTef := LJCCfgTef():New() 
    
	Self:oCCCD		:= Nil
	Self:oCheque	:= Nil
	Self:oCB		:= Nil
	Self:oRecCel	:= Nil                   
	Self:oPBM		:= Nil 
	Self:oCupom		:= Nil
	Self:lAtivo		:= .F.
	Self:lInfAdm	:= .T.
	Self:aFormas	:= {}       
	Self:aAdmin     := {}	//Classe responsแvel por armazenar as administradoras
	Self:oPgDig		:= Nil

Return Self           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsCCCD       บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o cartใo estแ habilitado.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISCCCD() Class LJCConfiguradorTef
Local lRet := .F.

lRet := Self:oCfgTef:lAtivo .And. ;
		(	Self:oCfgTef:oSitef:lCCCD 							.OR. ; //Sitef
			Self:oCfgTef:oDiscado:lGPCCCD 						.OR. ; //Gerenciador Padrao Discado
		 	Self:oCfgTef:oDiscado:lHiperCDCCCD 					.OR. ; //HiperCard
			Self:oCfgTef:oDiscado:lTecBanCCCD 					.OR. ; //TecBan
			Self:oCfgTef:oPayGo:lCCCD 							.OR. ; //PayGo
			Self:oCfgTef:oDirecao:lCCCD 						.OR. ; //TEF Direcao
			If(LjUsePayHub(),Self:oCfgTef:oPaymentHub:lCCCD,.F.) 	 ; //Payment Hub
		)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsCheque     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o cheque estแ habilitado.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISCheque() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. (Self:oCfgTef:oSitef:lCheque .OR. Self:oCfgTef:oDiscado:lGPCheque .OR. Self:oCfgTef:oDiscado:lTecBanCheque .OR. Self:oCfgTef:oPayGo:lCheque .OR. Self:oCfgTef:oDirecao:lCheque))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsCB         บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o correspondente bancario estแ habilitado.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISCB() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lCB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsRecCel     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a recarga celular estแ habilitada.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISRecCel() Class LJCConfiguradorTef
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lRC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsPBM        บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a PBM estแ habilitado.	                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISPBM() Class LJCConfiguradorTef 
Return (Self:oCfgTef:lAtivo .AND. Self:oCfgTef:oSitef:lPBM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsAtivo      บAutor  ณVendas CRM       บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se conseguiu carregar as configuracoes do TEF e se  บฑฑ
ฑฑบ          ณo mesmo esta habilitado/ativo                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ISAtivo() Class LJCConfiguradorTef 
Return Self:lAtivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCCCD      บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCCCD() Class LJCConfiguradorTef 
Return Self:oCCCD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCheque    บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCheque() Class LJCConfiguradorTef 
Return Self:oCheque

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCB        บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCB() Class LJCConfiguradorTef 
Return Self:oCB 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetRecCel    บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetRecCel() Class LJCConfiguradorTef 
Return Self:oRecCel 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPBM       บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPBM() Class LJCConfiguradorTef 
Return Self:oPBM 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCupom     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCupom() Class LJCConfiguradorTef 
Return Self:oCupom 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCarregar     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega as configuracoes de TEF disponiveis.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Carregar(cCodigo, lMensagem) Class LJCConfiguradorTef 
	
	Local lRet := .F.               //Retorno da Classe
	Local cTipo := "0"
	
	DEFAULT lMensagem := .T.   
	
	//Carrega as configuracoes do TEF

	lRet := Self:oCfgTef:Carregar(cCodigo,lMensagem)
	
	//Verifica se conseguiu carregar as configuracoes do TEF ou se o TEF esta habilitado/ativo
	Self:lAtivo := (lRet .AND. Self:oCfgTef:lAtivo)
	
	If !Self:lAtivo
		lRet := .F.
	Else 
		
		//Verifica se existe alguma configuracao do SITEF habilitada
		If Self:oCfgTef:oSitef:lCCCD .OR. ;
			Self:oCfgTef:oSitef:lCheque .OR. ;
			Self:oCfgTef:oSitef:lCB .OR. ;
			Self:oCfgTef:oSitef:lRC .OR. ;
			Self:oCfgTef:oSitef:lPBM
			
			Self:lInfAdm := Self:oCfgTef:oSitef:lInfAdm
			lRet := Self:AtivaSitef()
					
		//Verifica se existe alguma configuracao do TEF Discado(GP) habilitada
		ElseIf Self:oCfgTef:oDiscado:lGPCCCD .OR. ;
				Self:oCfgTef:oDiscado:lGPCheque .OR. ;
				Self:oCfgTef:oDiscado:lTECBANCCCD .OR. ;
				Self:oCfgTef:oDiscado:lTECBANCheque .OR. ;
				Self:oCfgTef:oDiscado:lHIPERCDCCCD .OR. ;
				Self:oCfgTef:oDiscado:lHIPERCDCheque
		        
		        Self:lInfAdm := Self:oCfgTef:oDiscado:lInfAdm
				lRet	:= Self:AtivaDisc()
				cTipo 	:= "2"
		
		//Verifica se existe alguma configuracao do TEF Discado(PayGo) habilitada
		ElseIf Self:oCfgTef:oPayGo:lCCCD .OR. ;
				Self:oCfgTef:oPayGo:lCheque
				
				Self:lInfAdm := Self:oCfgTef:oPayGo:lInfAdm
				lRet 	:= Self:AtivaPayGo() 
				cTipo 	:= "2"

		//Verifica se existe alguma configuracao do TEF Direcao habilitada
		ElseIf Self:oCfgTef:oDirecao:lCCCD .OR. ;
				Self:oCfgTef:oDirecao:lCheque  
				
				Self:lInfAdm := Self:oCfgTef:oDirecao:lInfAdm
				lRet 	:= Self:AtivaDirecao()
				cTipo 	:= "2"
		EndIf

		//Verifica se existe alguma configuracao do Payment Hub habilitada		
		If LjUsePayHub()
			lRet := Self:AtivaPaymentHub()
		EndIf 

		If ExistFunc("STTMTT") .AND. cTipo <> "0"
			STTMTT(cTipo)
		EndIf 

		If lRet
			
			Self:AtivaCupom()  
			Self:AtivaFormas()   
			Self:AtivaAdm()
		
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaSitef   บAutor  ณVendas CRM       บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria comunicacao com a TOTVSAPI.DLL, inicializa comunicacao บฑฑ
ฑฑบ          ณcom o sitef e cria os objetos para cada tipo de servico     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtivaSitef() Class LJCConfiguradorTef 
	
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oComCliSitef 	:= Nil				//Objeto do tipo LJCComCLisitef
	Local oTotvsApi 	:= NIL				//Objeto do tipo LJCTotvsAPI    
    Local oImpBWECF 	:= Nil  //STFECFCONTROL      
	Local lHomTEF		:= FindFunction("STHOMTEF") .AND. STWIsTotvs(SM0->M0_CGC)
	
	//Cria o objeto TOTVSAPI (Comunicacao com a TOTVSAPI.DLL)                               
	
	// Verifico se existe a funcao antes de instaciar a classe
	If oTotvsApi == Nil 
		If FindFunction("LOJA1326")
		
			oImpBWECF          := STFECFCONTROL():STFECFCONTROL(lHomTEF)  //Objeto do tipo STBCCECFCONTROL
    		oImpBWECF:CreateTotvsApi()
    		oTotvsApi := oImpBWECF:GetTotvsApi()
			If !oTotvsApi:ComAberta()
				//Abre comunicacao com TOTVSAPI.DLL
				If oTotvsApi:AbrirCom() <> -1
					//Cria o objeto de comunicacao com o SITEF
					oComCliSitef := LJCComCliSitef():New(oTotvsApi)
					//Abre comunicacao com o SITEF
					If oComCliSitef:ConfSitef(AllTrim(Self:oCfgTef:oSitef:cIpAddress), Self:oCfgTef:oSitef:cEmpresa, Self:oCfgTef:oSitef:cTerminal) == 0
						//Guardo a comunica็ใo com Sitef
						::oComSitef := oComCliSitef
						lRetorno := .T.
					Else
						lRetorno := .F.
						STFMessage("SITEF", "ALERT", STR0004) //"Nใo foi possํvel abrir comunica็ใo com o SITEF."
						STFShowMessage( "SITEF")
					EndIf
				Else
					lRetorno := .F.
					STFMessage("SITEF", "ALERT", STR0001) //"Nใo foi possํvel abrir comunica็ใo com a TOTVSAPI.DLL"
					STFShowMessage( "SITEF")
				EndIf
			EndIf 
			

		EndIf	
	Else
		lRetorno := .T.			
	EndIf 
	    
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oSitef:lCCCD 
			Self:oCCCD := LJCClisitefCCCD():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oSitef:lCheque 
			Self:oCheque := LJCClisitefCheque():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de recarga de celular
		If Self:oCfgTef:oSitef:lRC 
			Self:oRecCel := LJCClisitefRC():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de correspondente bancario
		If Self:oCfgTef:oSitef:lCB 
			Self:oCB := LJCClisitefCB():New(oComCliSitef)
		EndIf
		
		//Instancia a classe para transacoes de PBM
		If Self:oCfgTef:oSitef:lPBM 
			Self:oPBM := LJCClisitefPBM():New(oComCliSitef, Self:oCfgTef:oSitef:oPbms)
		EndIf
	
	EndIf  
		
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaDisc    บAutor  ณVendas CRM       บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa comunicacao com o TEF Discado e cria os objetos  บฑฑ
ฑฑบ          ณpara cada tipo de servico     							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtivaDisc() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo    
	Local oTransDiscado := NIL				//Objeto transa็ใo discado
		
	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComGP():New(Self:oCfgTef:oDiscado:oConfig)		
	
	//Abri comunicacao com o TEF Discado(GP)
	lRetorno := oComDiscado:InicializaConf()
		
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oDiscado:lGPCCCD .OR. Self:oCfgTef:oDiscado:lTECBANCCCD .OR. Self:oCfgTef:oDiscado:lHIPERCDCCCD  
			Self:oCCCD := LJCDiscadoCCCD():Create(oComDiscado)   
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oDiscado:lGPCheque .OR.  Self:oCfgTef:oDiscado:lHIPERCDCheque
			Self:oCheque := LJCDiscadoCheque():Create(oComDiscado)
			oTransDiscado := 	Self:oCheque:oTransDiscado
		EndIf 
		
		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf
		
	EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaPayGo   บAutor  ณVendas CRM       บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa comunicacao com o TEF Discado (PayGo) e          บฑฑ
ฑฑบ          ณcria os objetos para cada tipo de servico     			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtivaPayGo() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo     
	Local oTransDiscado := NIL				//Objeto transa็๕es discado
	

	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComPayGo():New(Self:oCfgTef:oPayGo:oConfig)		

	//Abri comunicacao com o TEF Discado(Pay Go)
	lRetorno := oComDiscado:InicializaConf()
	
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oPayGo:lCCCD
			Self:oCCCD := LJCDiscPayGoCCCD():Create(oComDiscado) 
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//Instancia a classe para transacoes de cheque
		If Self:oCfgTef:oPayGo:lCheque
			Self:oCheque := LJCDiscPayGoCheque():Create(oComDiscado) 
			oTransDiscado := 	Self:oCheque:oTransDiscado
		EndIf
		

		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf

	EndIf


Return lRetorno        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaDirecao บAutor  ณVendas CRM       บ Data ณ  09/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa comunicacao com o TEF Discado (PayGo) e          บฑฑ
ฑฑบ          ณcria os objetos para cada tipo de servico     			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtivaDirecao() Class LJCConfiguradorTef 
	
	Local oComDiscado  	:= Nil              //Objeto do tipo LJAComDiscado
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oTransDiscado	:= NIL				//Objeto transa็ใo discado
	

	//Criar objeto de comunicacao com o TEF Discado(GP)
	oComDiscado := LJCComDirecao():New(Self:oCfgTef:oDirecao:oConfig)		

	//Abri comunicacao com o TEF Discado(Pay Go)
	lRetorno := oComDiscado:InicializaConf()
	
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oDirecao:lCCCD
			Self:oCCCD := LJCDiscDirecaoCCCD():Create(oComDiscado)     //alterado por causa da heran็a 
			oTransDiscado := 	Self:oCCCD:oTransDiscado
		EndIf
		
		//to do Instancia a classe para transacoes de cheque
	   	If Self:oCfgTef:oDirecao:lCheque
	   		//Self:oCheque := LJCDiscPayGoCheque():New(oComDiscado) 
	   		oTransDiscado := 	Self:oCheque:oTransDiscado
	   	EndIf
	   
		If oTransDiscado <> NIL   
			oTransDiscado:Desfazer()
		EndIf
		
	EndIf


Return lRetorno        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaCupom   บAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa o componente cupom    							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method AtivaCupom() Class LJCConfiguradorTef

	Self:oCupom := LJCCupom():New()

Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaFormas  บAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa o componente formas  							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method AtivaFormas() Class LJCConfiguradorTef
    Local oBPgtos := STBWCPayment():STBWCPayment()   //Model das formas de pagamento
    Local nI     := 0   							//Variแvel contadora
    Local oPgtos := oBPgtos:oPayX5:GetAllData()     //Model das formas de pagamento
    Local oMdlPgtos  := oPgtos:GetModel("GridStr")   //Model das formas de pagamento


 	For nI := 1 To oMdlPgtos:Length()

		oMdlPgtos:GoLine(nI)

		aAdd( Self:aFormas, {AllTrim(oMdlPgtos:GetValue("X5_TYPE")), oMdlPgtos:GetValue("X5_DESC")})

   
	Next
	
	oMdlPgtos := FreeObj(oMdlPgtos)
	oPgtos	  := FreeObj(oPgtos)   
	oBPgtos	  := FreeObj(oBPgtos)

Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFechar    บAutor  ณVendas CRM       บ Data ณ  18/01/2013บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFecha a DLL                    							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method Fechar() Class LJCConfiguradorTef
	//Verifica se existe alguma configuracao do SITEF habilitada
			


			
//Instancia a classe para transacoes de cartao
If Self:oCfgTef:oSitef:lCCCD .AND. ValType(Self:oCCCD:oTransSitef:oCliSitef) == "O"  

	Self:oCCCD:oTransSitef:oCliSitef:Fechar()

ElseIf Self:oCfgTef:oSitef:lCheque .AND. ValType(Self:oCheque:oTransSitef:oCliSitef) == "O"

	Self:oCheque:oTransSitef:oCliSitef:Fechar()    
	
ElseIf Self:oCfgTef:oSitef:lRC .AND. ValType(Self:oRecCel:oTransSitef:oCliSitef) == "O"  

	Self:oRecCel:oTransSitef:oCliSitef:Fechar() 
		
ElseIf Self:oCfgTef:oSitef:lCB .AND. ValType(Self:oCB:oTransSitef:oCliSitef) == "O"  

	Self:oCB:oTransSitef:oCliSitef:Fechar() 

ElseIf Self:oCfgTef:oSitef:lPBM .AND. ValType(Self:oPBM:oTransSitef:oCliSitef) == "O"

	Self:oPBM:oTransSitef:oCliSitef:Fechar()

EndIf

  
	If Valtype(Self:oCCCD) == "O"
	//Libera os Objetos
		FreeObj(Self:oCCCD)  
   		Self:oCCCD := NIL 
    EndIf
	
	If Valtype(Self:oCheque) == "O"
		FreeObj(Self:oCheque)
		Self:oCheque := NIL  
	EndIf
	
	If Valtype(Self:oCB) == "O"
		FreeObj(Self:oCB)
		Self:oCB := NIL
	EndIf
	
	If ValType(Self:oRecCel) == "O"
		FreeObj(Self:oRecCel)    
		Self:oRecCel := NIL                  
	EndIf
	
	If ValType(Self:oPBM) == "O"
		FreeObj(Self:oPBM)
   		Self:oPBM := NIL
   	EndIf 
	
	FreeObj(Self:oCfgTef)
	Self:oCfgTef := NIL
	
	FreeObj(Self:oCupom)
	Self:oCupom := NIL   

Return .T. 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetAdm       บAutor  ณVendas CRM       บ Data ณ  04/02/2013บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o configurador necessita de administradora Finan  ฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method GetAdm() Class LJCConfiguradorTef        

Return 	Self:lInfAdm  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtivaAdm     บAutor  ณVendas CRM       บ Data ณ  04/02/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as administradoras Financeiras                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AtivaAdm() Class LJCConfiguradorTEF      
 
	Local aArea	:= GetArea()             //WorkArea Ativa
	Local aAreaSAE := SAE->(GetArea())	 //WorkArea Anteriror SAE
	Local aAreaMDE := MDE->(GetArea())   //WorkArea Anterior MDE
	Local nParcDe := 0                   //Parcela De
	Local nParcAte := 0                  //Parcela Ate
	Local lAEREDEAUT	:= SAE->(ColumnPos("AE_REDEAUT")) > 0
	Local cBandSITEF	:= ""
	Local cDesBandMDE 	:= ""
	Local cRedeSITEF	:= ""
	Local cDesRedeMDE 	:= ""
	
	
	DbSelectArea("MDE") 
	MDE->(DbSetOrder(1))  //MDE_FILIAL+MDE_CODIGO
	DbSelectArea("SAE")
	DbSetOrder(1) //AE_FILIAL+AE_COD
	DbSeek(xFilial("SAE"))    
	//To: Verificar a possibilidade de filtrar pela forma de pagamento CC/CD 
	
	While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")
 		nParcDe := SAE->AE_PARCDE                 
		nParcAte := SAE->AE_PARCATE 
		
		//Se parcela De/Ate vier em branco configua 1 a 99
		If nParcDe = 0 .AND. nParcAte = 0    
			nParcDe := 1 
			nParcAte := Val(Replicate("9", SAE->(TamSx3("AE_PARCATE")[1])))
		EndIf
		
		If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART ))
			cBandSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Bandeira (Retornado pelo SITEF)
			cDesBandMDE := MDE->MDE_DESC	//Descricao da Bandeira
		Else
			cBandSITEF	:= ""
			cDesBandMDE := SAE->AE_DESC
		EndIf
		
		If lAEREDEAUT //Controle pela Rede que autorizou a transacao TEF
			If !Empty(SAE->AE_REDEAUT) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_REDEAUT ))
				cRedeSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Rede autorizadora da transa็ใo TEF (Retornado pelo SITEF)
				cDesRedeMDE := MDE->MDE_DESC	//Descricao da Rede
			Else
				cRedeSITEF	:= ""
				cDesRedeMDE := ""
			EndIf
		Else
			cRedeSITEF	:= ""
		EndIf
		
		AAdd(Self:aAdmin, {	SAE->AE_COD											,; //01-Codifo da Adm. Financeira
							AllTrim(SAE->AE_TIPO)								,; //02-Tipo (CC,CD,...)
							SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))	,; //03-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
							nParcDe												,; //04-Parcela Inicial
							nParcAte											,; //05-Parcela Final
							SAE->AE_ADMCART										,; //06-Codigo Relacionado a tabela MDE para a Bandeira
							cDesBandMDE											,; //07-Descricao da Bandeira 
							cBandSITEF 											,; //08-Codigo da Bandeira(campo MDE_CODSIT)
							cRedeSITEF											,; //09-Codigo da Rede (Campo MDE_CODSIT)
							cDesRedeMDE 										}) //10-Descricao da Rede (campo MDE_DESC)
		
		SAE->(DbSkip())
	End

     RestArea(aAreaSAE)
     RestArea(aAreaMDE)
     RestArea(aArea) 

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetFormas    บAutor  ณVendas CRM       บ Data ณ  04/02/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna as formas de pagamento                               ฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method GetFormas() Class LJCConfiguradorTef        

Return 	Self:aFormas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetAdmin     บAutor  ณVendas CRM       บ Data ณ  04/02/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Administradora Financeira                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method GetAdmin() Class LJCConfiguradorTef

Return Self:aAdmin     

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtivaPaymentHub
Inicializa comunicacao com o Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return lRetorno, L๓gico, Retorna se conseguiu fazer a comunica็ใo com a API do Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method AtivaPaymentHub() Class LJCConfiguradorTef 
	
	Local lRetorno 		:= .F.				//Retorno do metodo
	Local oComPaymentHub:= Nil				//Objeto do tipo LJCComPaymentHub

	LjGrvLog("TPD"," Inicio - Inicializa comunicacao com o Payment Hub.", )

	//Cria o objeto de comunicacao com o Payment Hub
	oComPaymentHub := LJCComPaymentHub():New(Self:oCfgTef:oPaymentHub)

	//Testa a comunicacao com o Payment Hub
	If oComPaymentHub:CommPaymentHub()
		::oComPaymentHub := oComPaymentHub
		lRetorno := .T.
		LjGrvLog("TPD"," Comunicacao com o Payment Hub efetuada.", )
	Else
		lRetorno := .F.
		STFMessage("PaymentHub", "ALERT", STR0005) // "Nใo foi possํvel se comunicar com o Payment Hub."
		STFShowMessage( "PaymentHub")
		LjGrvLog("TPD"," Nใo foi possํvel se comunicar com o Payment Hub.", )
	EndIf
	    
	If lRetorno
	
		//Instancia a classe para transacoes de cartao
		If Self:oCfgTef:oPaymentHub:lCCCD 
			Self:oCCCD := LJCPaymentHubCCCD():New(oComPaymentHub)
		EndIf

		If Self:oCfgTef:oPaymentHub:lPagDig
			Self:oPgDig := LJCPaymentHubDigitais():New(oComPaymentHub)
		EndIf
	
	EndIf

	LjGrvLog("TPD"," Fim - Inicializa comunicacao com o Payment Hub. lRetorno -> ", lRetorno)
		
Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtivaPaymentHub
Funcao criada apenas para verificar se o ambiente estแ atualizado para poder utilizar o Payment Hub.
*** Excluir esta fun็ใo quando os campos existirem por padrao na tabela MDG.

@type       Function
@author     Alberto Deviciente
@since      31/07/2020
@version    12.1.27

@return lRetorno, L๓gico, Retorna se o ambiente estแ atualizado para poder utilizar o Payment Hub. 
/*/
//-------------------------------------------------------------------------------------
Function LjUsePayHub()
Local aFontes	:= {}
Local aCampos 	:= {}
Local aInfoFonte:= {}
Local nCount 	:= 0
Local lOK 		:= .T.
Local dDataRef 	:= Nil
Local cAliasTab	:= ""
Local cCampoTab	:= ""
Local cMsg 		:= ""

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " Inicio da Verifica็ใo " ,ProcName(1))

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " lUsePayHub " ,lUsePayHub )

If lUsePayHub == Nil
	dDataRef 	:= CToD("28/08/2020") //Data de referencia dos fontes

	//Fontes a serem verificados se estao atualizados
	aAdd( aFontes, "LJCCfgTefPaymentHub.PRW")
	aAdd( aFontes, "LJCComPaymentHub.PRW")
	aAdd( aFontes, "LJCPaymentHubCCCD.prw")
	aAdd( aFontes, "LJCRetornoPayHub.prw")
	aAdd( aFontes, "RotinasGerenciais.prw")
	aAdd( aFontes, "Telaterminal.PRW")
	aAdd( aFontes, "PaymentHub.PRW")
	aAdd( aFontes, "LOJA1906.PRW")
	aAdd( aFontes, "LOJA1906A.PRW")
	aAdd( aFontes, "loja1934.prw")
	aAdd( aFontes, "STWInfoCNPJ.PRW")
	aAdd( aFontes, "STWCancelSale.PRW")
	aAdd( aFontes, "STIInfoCNPJ.prw")
	aAdd( aFontes, "STIPayment.PRW")
	aAdd( aFontes, "STBTEF.prw")
	aAdd( aFontes, "loja075.prw")
	aAdd( aFontes, "STWPayCard.prw")
	aAdd( aFontes, "STDCancelSale.prw")
	aAdd( aFontes, "STBPayCard.prw")
	aAdd( aFontes, "STWChkTef.prw")
	aAdd( aFontes, "LOJA121.PRW")
	aAdd( aFontes, "LOJA140.PRX")
	aAdd( aFontes, "LOJA701B.PRW")
	aAdd( aFontes, "LOJA701C.PRW")
	aAdd( aFontes, "LOJXFUNB.PRX")
	aAdd( aFontes, "LOJXFUNC.PRW")
	aAdd( aFontes, "LOJXFUNK.PRW")
	aAdd( aFontes, "LOJXPED.PRW")
	aAdd( aFontes, "LOJXTEF.PRW")
	aAdd( aFontes, "LOJXPAGDIG.PRW")
	
	//Verifica a data dos fontes no RPO
	For nCount := 1 To Len(aFontes)
		aInfoFonte := GetAPOInfo(aFontes[nCount])
		If Empty(aInfoFonte)
			cMsg := "Fonte " + aFontes[nCount] + " nใo encontrado no RPO."
		ElseIf aInfoFonte[4] < dDataRef
			cMsg := "Fonte " + aFontes[nCount] + " com data " + dtoc(aInfoFonte[4]) + ", inferior a " + dtoc(dDataRef)
		EndIf

		If !Empty(cMsg)
			LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", cMsg)
			lOK := .F.
			Exit
		EndIf
	Next nCount

	If lOK
		//Campos a serem verificados se existem no ambiente

		aAdd( aCampos, "MDG_PHCOMP"	)
		aAdd( aCampos, "MDG_PHTENA"	)
		aAdd( aCampos, "MDG_PHUSER"	)
		aAdd( aCampos, "MDG_PHPSWD"	)
		aAdd( aCampos, "MDG_PHCLID"	)
		aAdd( aCampos, "MDG_PHCLSR"	)
		aAdd( aCampos, "MDG_PHPAGD"	)
		aAdd( aCampos, "L1_VLRPGDG"	)
		aAdd( aCampos, "L4_TRNID"	)
		aAdd( aCampos, "L4_TRNPCID"	)
		aAdd( aCampos, "L4_TRNEXID"	)

		//Verifica se os campos existem no ambiente
		For nCount := 1 To Len(aCampos)

			cCampoTab := aCampos[nCount]
			cAliasTab := PadL( Left( cCampoTab, AT("_",cCampoTab)-1 ), 3, "S")

			If (cAliasTab)->(Columnpos(cCampoTab)) == 0
				LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", "Campo " + cCampoTab + " nใo encontrado na tabela " + cAliasTab)
				lOK := .F.
				Exit
			EndIf
		Next nCount
	EndIf

	lUsePayHub := lOK .And. cPaisLoc == "BRA" .And. ; 	//Disponํvel apenas para o Brasil
				 ( nModulo == 12 .Or. ; 				//Verifica se ้ SIGALOJA
	 				STFIsPOS() .Or. ;  					//Verifica se ้ Totvs PDV
					LjFTVD() 	)						//Verifica se ้ Venda Direta (SIGAFAT)

EndIf

LJGrvLog("TOTVS_PAGAMENTO_DIGITAL", " Fim da Verifica็ใo. " , lUsePayHub)

Return lUsePayHub

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPgtoDigital
Metodo para retornar o objeto com as configura็๕es do pagamento digital

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@param 
@return 	oPgDig, Objeto, Retorna objeto com as configura็๕es do pgto digital

/*/
//-------------------------------------------------------------------------------------
Method GetPgtoDigital() Class LJCConfiguradorTef 
Return Self:oPgDig

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ISPgtoDig
Verifica se o pagamento digital esta ativo

@type       Method
@author     Bruno Almeida
@since      28/10/2020
@version    12.1.27
@param 
@return 	lRet, l๓gico

/*/
//-------------------------------------------------------------------------------------
Method ISPgtoDig() Class LJCConfiguradorTef

Local lRet := .F. //Variavel de retorno

If LjUsePayHub()
	lRet := Self:oCfgTef:lAtivo .AND.  Self:oCfgTef:oPaymentHub:lPagDig
EndIf

LjGrvLog("ISPgtoDig", " lRet - TPD habilitado no cadastro de esta็ใo?",lRet )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ISPayHub
Verifica se o payment hub esta ativo

@type       Method
@author     Bruno Almeida
@since      28/10/2020
@version    12.1.27
@param 
@return 	lRet, l๓gico

/*/
//-------------------------------------------------------------------------------------
Method ISPayHub() Class LJCConfiguradorTef
Return Self:oCfgTef:oPaymentHub:lCCCD