#include "APWizard.ch"
 
//Extras
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#xcommand DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

//Pula Linha
#Define CTRL Chr(13)+Chr(10)

//DEFINE's do array aCliConv
#DEFINE __CODCLI    1
#DEFINE __LOJCLI    2

//DEFINE's do array aTitConv
#DEFINE __PREFIXO   1
#DEFINE __NUMERO    2
#DEFINE __PARCELA   3
#DEFINE __TIPO      4
#DEFINE __CLIENTE   5
#DEFINE __LOJA      6

//DEFINE's do array aTitGlobal
#DEFINE __NOMEEMP   1
#DEFINE __TITPROC   2
#DEFINE __PREFGLOB  3
#DEFINE __NUMGLOB   4
#DEFINE __PARCGLOB  5
#DEFINE __TIPOGLOB  6
#DEFINE __VALORGLOB 7

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROFCHCONVºAutor  ³Fernando Machima    º Data ³  23/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fechamento de convenio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROFCHCONV
Local oWizard, oPanel
Local oGetCodClIni, oGetLojClIni
Local oGetCodClFim, oGetLojClFim             
Local oGetDtPgto
Local oLBBx
Local cText :=	'Este programa processará o fechamento do convênio de acordo com os ' + CTRL +; 
	  			'parâmetros selecionados.' + CTRL +; 
	  			'Para continuar clique em Avançar.'
Local cMascara :=PesqPict("SE1","E1_VALOR",18)
Local bValid
Local aCabBx	:= {}
Local aTamBx	:= {}
Private cCodCliIni := Space(TamSX3("A1_COD")[1])
Private cLojCliIni := Space(TamSX3("A1_LOJA")[1])
Private cCodCliFim := Space(TamSX3("A1_COD")[1])
Private cLojCliFim := Space(TamSX3("A1_LOJA")[1])
Private dDtPgtoIni := cTOD("  /  /    ")
Private dDtPgtoFim := cTOD("  /  /    ")
Private lMsErroAuto  := .F.
Private aTitGlobal   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aTitGlobal       ³
//³------------------------------      ³
//³1-Nome reduzido do cliente          ³
//³2-Quantidade de titulos do cliente  ³
//³3-Prefixo do titulo aglutinado      ³
//³4-Numero do ultimo titulo aglutinado³
//³  de convenio                       ³
//³5-Parcela do titulo aglutinado      ³
//³6-Tipo do titulo aglutinado         ³
//³7-Valor do titulo aglutinado        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard TITLE 'Drogaria - Processamento do Fechamento de Convênio' ;
HEADER 'Wizard de fechamento de convênio:' ; 
MESSAGE 'Processamento automático.' TEXT cText ;
NEXT {|| .T.} FINISH {|| .T.} PANEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo Panel - Pergunte do fechamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Dados para fechamento do convênio' ;
MESSAGE 'Informe os dados abaixo para o processamento do fechamento de convênio.' ;
BACK {|| .T. } NEXT {|| IIf(VldFecha(),VldProc(),.F.) } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(2)

bValid   := {|| IIf(!Empty(dDtPgtoFim),(Dtos(dDtPgtoFim) >= Dtos(dDtPgtoIni)),.T.)}
TSay():New(15,05,{|| "Data de pagamento inicial"},oPanel,,,,,,.T.)
oGetDtPgto := TGet():New(14,95,bSETGET(dDtPgtoIni),oPanel,50,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| IIf(!Empty(dDtPgtoIni),(Dtos(dDtPgtoFim) >= Dtos(dDtPgtoIni)),.T.)}
TSay():New(35,05,{|| "Data de pagamento final"},oPanel,,,,,,.T.)
oGetDtPgto := TGet():New(34,95,bSETGET(dDtPgtoFim),oPanel,50,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| ExistCpo("SA1",cCodCliIni)}
TSay():New(55,05,{|| "Empresa Conveniada (Cliente) Inicial"},oPanel,,,,,,.T.)
oGetCodClIni := TGet():New(54,95,bSETGET(cCodCliIni),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L54",)

bValid   := {|| ExistCpo("SA1",cCodCliIni+cLojCliIni)}
TSay():New(75,05,{|| "Loja Empresa Conveniada Inicial"},oPanel,,,,,,.T.)
oGetLojClIni := TGet():New(74,95,bSETGET(cLojCliIni),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| ExistCpo("SA1",cCodCliFim) .And. cCodCliFim >= cCodCliIni}
TSay():New(95,05,{|| "Empresa Conveniada (Cliente) Final"},oPanel,,,,,,.T.)
oGetCodClFim := TGet():New(94,95,bSETGET(cCodCliFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L54",)

bValid   := {|| ExistCpo("SA1",cCodCliFim+cLojCliFim)}
TSay():New(115,05,{|| "Loja Empresa Conveniada Final"},oPanel,,,,,,.T.)
oGetLojClFim := TGet():New(114,95,bSETGET(cLojCliFim),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Terceiro Panel - Status do Processamento³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo os dados processados e dos títulos aglutinados por empresa de convênio' ;
BACK {|| .F. } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(3)

aCabBx	:= {"Empresa de convênio", "Tít. processados", "Prefixo", "Número", "Parcela","Tipo", "Valor Total" }
aTamBx	:= {65,45,20,30,22,15,55}
AAdd(aTitGlobal,{"",0,"","","","",0})
oLBBx		:=TwBrowse():New(000,003,000,000,,aCabBx,aTamBx,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx:SetArray(aTitGlobal)
oLBBx:bLine 	:= { ||{aTitGlobal[oLBBx:nAT][__NOMEEMP], Transform(aTitGlobal[oLBBx:nAT][__TITPROC],"@E 999,999"), ;
                        aTitGlobal[oLBBx:nAT][__PREFGLOB], aTitGlobal[oLBBx:nAT][__NUMGLOB], aTitGlobal[oLBBx:nAT][__PARCGLOB], ;
                        aTitGlobal[oLBBx:nAT][__TIPOGLOB],Transform(aTitGlobal[oLBBx:nAT][__VALORGLOB],cMascara)}}                        
                        
oLBBx:lHScroll  :=.T.
oLBBx:nHeight	:=270
oLBBx:nWidth	:=550

ACTIVATE WIZARD oWizard CENTER

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VldProc    ºAutor  ³Carlos A. Gomes Jr. º Data ³  14/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada do processamento de fechamento de convenio          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldProc()

Local lRet  := .T.

//Processamento
If MsgYesNo("Confirma o processo de fechamento do convênio?")
   Processa( { |lEnd| lRet  := ConvProc() }, "Processando...",, .F.)  
Else
   lRet := .F.   
EndIf   

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ConvProc  ºAutor  ³Fernando Machima    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento do fechamento de convenio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvProc()
Local nX, nY, nZ, nT
Local nPosCliConv  := 0
Local nHandle   
Local nIndAtu  
Local nVlrGlobal := 0
Local nQtdTitulos := 0
Local lRet      := .T.
Local lGeraLog  := .F.
Local lQuery    := .F.
Local cMotBx    := "DAC"  //Motivo da baixa por Dacao dos titulos do cliente
Local cTxtLog   := ""
Local cIndex    := ""
Local cKey	    := ""
Local cFiltro   := ""
Local cPrefConv := PadR(GetMV("MV_PRFCONV",,"CON"),3)  //Prefixo do titulo aglutinado
Local cNomeReduz  := ""
Local cNumGlobal := ""
Local cQuery    := ""
Local cAliasQry := "QRY"   
Local cParcGlobal:= ""
//Recupera a propriedade StartPath do Server.Ini
Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local aCliConv  := {}  //Contem as empresas para as quais se deve realizar o fechamento de convenio
Local aTitConv  := {}
Local aBaixa    := {}
Local aLayOut   := {}
Local aStruSE1  := {}
Local dDtVencto := cTOD("  /  /    ")
Local bWhile
Local nTamE1Num := TamSX3("E1_NUM")[1]
Local cChvLock 	:= "" //Chave para controle de LockByName (no caso de execucao desta rotina simultaneamente por mais de um usuario)
Local aChvLock  := {} //Array com as chaves de controle de LockByName
Local cErro		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aTitConv         ³
//³------------------------------      ³
//³1-Cod. empresa de convenio          ³
//³2-Loja empresa de convenio          ³
//³3,1-Prefixo do titulo de convenio   ³
//³3,2-Numero do titulo de convenio    ³
//³3,3-Parcela do titulo de convenio   ³
//³3,4-Tipo do titulo de convenio      ³
//³3,5-Cliente do titulo de convenio   ³
//³3,6-Loja do titulo de convenio      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP
   lQuery  := (TcSrvType() <> "AS/400")
#ENDIF
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao dos titulos de convenio        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery                  
   DbSelectArea("SE1")
   DbSetOrder(1)
   aStruSE1  := SE1->(dbStruct())
   cQuery    := "SELECT SA1.A1_FILIAL, SA1.A1_EMPCONV, SA1.A1_LOJCONV, SE1.* "
   cQuery    += "FROM "+RetSqlName("SA1")+" SA1, "+RetSqlName("SE1")+" SE1 "
   cQuery    += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
   cQuery    += "SA1.A1_TPCONVE = '3' AND "  //Conveniados

   cQuery    += "SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "      
   //Intervalo de datas de pagamento do convenio
   cQuery    += "SE1.E1_VENCTO >='"+DTOS(dDtPgtoIni)+"' AND "
   cQuery    += "SE1.E1_VENCTO <='"+DTOS(dDtPgtoFim)+"' AND "   
   cQuery    += "SE1.E1_SALDO = SE1.E1_VALOR AND "   
   cQuery    += "SE1.E1_STATUS = 'A' AND "
   cQuery    += "SE1.E1_TIPO = 'FI ' AND "   
   cQuery    += "SE1.E1_SALDO > 0    AND "      
   
   //SA1 x SE1
   cQuery    += "SE1.E1_CLIENTE = SA1.A1_COD AND "   
   cQuery    += "SE1.E1_LOJA = SA1.A1_LOJA   AND "      
   
   //Funcionarios das empresas de convenio selecionados na tela de parametros
   //A loja serah filtrada no loop
   cQuery    += "SA1.A1_EMPCONV >= '"+cCodCliIni+"' AND "
   cQuery    += "SA1.A1_EMPCONV <= '"+cCodCliFim+"' AND "               
   
   cQuery    += "SA1.D_E_L_E_T_=' ' AND "
   cQuery    += "SE1.D_E_L_E_T_=' ' "   
   cQuery    += "ORDER BY SE1.E1_FILIAL,SA1.A1_EMPCONV,SA1.A1_LOJCONV,SE1.E1_VENCTO,SE1.E1_NUM"

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
      
   For nX := 1 To Len(aStruSE1)
      If aStruSE1[nX,2]<>"C"
	     TcSetField(cAliasQry,aStruSE1[nX,1],aStruSE1[nX,2],aStruSE1[nX,3],aStruSE1[nX,4])
	  EndIf
   Next nX

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Busca o numero do ultimo titulo com o prefixo dos titulos aglu- ³
   //³tinados(MV_PRFCONV)de convenio                                  ³   
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
   cNumGlobal  := RetNumGlobal(cPrefConv)
   
   bWhile := {|| (cAliasQry)->(!Eof())}      
   //Loop dos titulos de convenio selecionados
   While Eval(bWhile)   
      
      //Filtra as lojas das empresas de convenio. Nao foi colocado na query, porque deve considerar os casos em que
      //o codigo inicial do filtro eh, por exemplo: 001/02 e o final: 005/01. Nesta situacao, a query nao selecionaria 
      //as empresas de loja 01.
      If (cAliasQry)->A1_EMPCONV+(cAliasQry)->A1_LOJCONV < cCodCliIni+cLojCliIni .Or. ;
         (cAliasQry)->A1_EMPCONV+(cAliasQry)->A1_LOJCONV > cCodCliFim+cLojCliFim
         
         (cAliasQry)->(DbSkip())
         Loop
      EndIf   
           
      nPosCliConv  := aScan(aTitConv,{|z| z[1]+z[2]==(cAliasQry)->A1_EMPCONV+(cAliasQry)->A1_LOJCONV})
      If nPosCliConv == 0 
         //              Cod.Emp.Convenio          Loja Emp.Convenio  
         Aadd(aTitConv,{(cAliasQry)->A1_EMPCONV,(cAliasQry)->A1_LOJCONV, {}})
         Aadd(aTitConv[Len(aTitConv)][3],{(cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,;
                                           (cAliasQry)->E1_TIPO,(cAliasQry)->E1_CLIENTE,(cAliasQry)->E1_LOJA})
      Else                              
        //                                         1                        2                    3 
        Aadd(aTitConv[nPosCliConv][3],{(cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,;
                                        (cAliasQry)->E1_TIPO,(cAliasQry)->E1_CLIENTE,(cAliasQry)->E1_LOJA})                        
        //                                          4                    5                        6                                  
      EndIf                  
       
      (cAliasQry)->(DbSkip())
   End   
Else  
   DbSelectArea("SA1")
   DbSetOrder(1)
   If DbSeek(xFilial("SA1")+cCodCliIni+cLojCliIni,.T.)
      While !Eof() .And. xFilial("SA1")+cCodCliIni+cLojCliIni <= SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA .And. ;
            xFilial("SA1")+cCodCliFim+cLojCliFim >= SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA    
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Ignorar os registros que nao sao empresas de convenio³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
         If SA1->A1_TPCONVE != "4"
            DbSkip()
            Loop
         EndIf
      
         Aadd(aCliConv,{SA1->A1_COD, SA1->A1_LOJA})
      
         DbSkip()      
      End
   EndIf

   If Len(aCliConv) > 0
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Busca o numero do ultimo titulo com o prefixo dos titulos aglu- ³
      //³tinados(MV_PRFCONV)de convenio                                  ³   
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
      cNumGlobal  := RetNumGlobal(cPrefConv)
       
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Filtrando o SE1 com base nos parametros informados. Nao filtrar ³
      //³pelo cliente porque os titulos de convenio sao gerados para os  ³   
      //³funcionarios e nao para as empresas de convenio                 ³      
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
      cIndex    := CriaTrab(Nil,.F.)
      cKey      := "E1_FILIAL+E1_CLIENTE+E1_LOJA+DTOS(E1_VENCTO)+E1_NUM"
      cFiltro   := "E1_FILIAL ==        '"+ xFilial("SE1")   +"' .And. "
      cFiltro   += "DTOS(E1_VENCTO)  >= '"+ DTOS(dDtPgtoIni) +"' .And. "      
      cFiltro   += "DTOS(E1_VENCTO)  <= '"+ DTOS(dDtPgtoFim) +"' .And. "            
      cFiltro   += "E1_TIPO == 'FI '     .And. "      
      cFiltro   += "E1_SALDO == E1_VALOR .And. "         
      cFiltro   += "E1_SALDO > 0         .And. "               
      cFiltro   += "E1_STATUS == 'A'           "            
   	
      IndRegua("SE1",cIndex,cKey,,cFiltro,"Filtrando Registros...")  
      nIndAtu := RetIndex("SE1") + 1
      dbSelectArea("SE1")   
      dbSetIndex(cIndex+OrdBagExt())
      dbSetOrder(nIndAtu)   
      dbGoTop()      
      If BOF() .and. EOF()
  	     MsgAlert("Não foi selecionado nenhum título de convênio com os parâmetros informados.")
	     RetIndex("SE1")
	     dbClearFilter()
	     FErase(cIndex+OrdBagExt())  	  
	     Return .F.	
      EndIf
   
      For nX := 1 to Len(aCliConv)   
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Posicionar no registro do funcionario da empresa convenio    ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
         DbSelectArea("SA1")
         //DbSetOrder(9)
         DbOrderNickName("SA1DRO2")//indice criado p/ o Template de Drogaria
         If DbSeek(xFilial("SA1")+aCliConv[nX][1]+aCliConv[nX][2])
            While !Eof() .And. xFilial("SA1")+aCliConv[nX][1]+aCliConv[nX][2] == SA1->A1_FILIAL+SA1->A1_EMPCONV+SA1->A1_LOJCONV
               
               DbSelectArea("SE1")
               DbSetOrder(nIndAtu)  
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³Posicionar nos titulos de convenio do funcionario            ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                     
               If DbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
                  While !Eof() .And. xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA == ;
                        SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA
                                    
                     nPosCliConv  := aScan(aTitConv,{|z| z[1]+z[2]==aCliConv[nX][__CODCLI]+aCliConv[nX][__LOJCLI]})
                     If nPosCliConv == 0 
                        //              Cod.Emp.Convenio          Loja Emp.Convenio  
                        Aadd(aTitConv,{aCliConv[nX][__CODCLI], aCliConv[nX][__LOJCLI], {}})
                        Aadd(aTitConv[Len(aTitConv)][3],{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
                                                       SE1->E1_CLIENTE,SE1->E1_LOJA})
                     Else                               //      1             2             3              4 
                        Aadd(aTitConv[nPosCliConv][3],{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
                                                        SE1->E1_CLIENTE,SE1->E1_LOJA})      
                                                     //      5             6 
                     EndIf                  
                  
                     DbSkip()    
                  End
               EndIf
               DbSelectArea("SA1")            
               DbSkip()
            End
         EndIf
      Next nX
   Else
      MsgAlert("Nao há nenhuma empresa de convênio no intervalo de clientes informado.")   
      lRet  := .F.
   EndIf
EndIf

DbSelectArea("SE1")
DbSetOrder(2)

If Len(aTitConv) == 0
	MsgAlert("Não foi selecionado nenhum título de convênio com os parâmetros informados.")
	lRet  := .F.
ElseIf lRet
    //Exclui a linha em branco 
    If Len(aTitGlobal) == 1 .And. Empty(aTitGlobal[1][1])
       ADel(aTitGlobal,1)
       ASize(aTitGlobal, Len(aTitGlobal)-1 )
    EndIf
	BEGIN TRANSACTION
	For nX := 1 to Len(aTitConv) 
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+aTitConv[nX][__CODCLI]+aTitConv[nX][__LOJCLI]))
		   cNomeReduz  := SA1->A1_NREDUZ				
		Else 
			cTxtLog  := "Empresa de convênio de código "+aTitConv[nX][__CODCLI]+aTitConv[nX][__LOJCLI]+" não foi encontrada no arquivo de Clientes."+CTRL+;
			"Não foi processado o fechamento de convênio para este código."+CTRL
			ConvGrvLog(cTxtLog)
			lGeraLog  := .T.
			Loop
		EndIf   
		
		//Loop para todos os titulos dos funcionarios de uma empresa de convenio
		nVlrGlobal := 0		
 		cNumGlobal  := StrZero(Val(cNumGlobal)+1,nTamE1Num)
 		
 		//Faz o controle (Lock) na numeracao de titulo E1_NUM reservado para utilizacao (Numeros de titulos que serao gerados)
 		cChvLock := "DROFCHCONV"+xFilial("SE1")+cNumGlobal+cPrefConv
 		While !LockByName( cChvLock, .T. )
 			cNumGlobal := StrZero(Val(cNumGlobal)+1,nTamE1Num)
 			cChvLock := "DROFCHCONV"+xFilial("SE1")+cNumGlobal+cPrefConv
 		End
 		aAdd( aChvLock, cChvLock)
		
		nQtdTitulos := 0
		For nY := 1 to Len(aTitConv[nX][3])  
			aBaixa  := {}
			//Setar a variavel estatica __nExeBaixa do programa FINA070 para permitir varias baixas
			//Fa070SetVarB()          //          Cliente                         Loja                           Prefixo                        Numero
			DbSetOrder(2)
			If DbSeek(xFilial("SE1")+aTitConv[nX][3][nY][__CLIENTE]+aTitConv[nX][3][nY][__LOJA]+aTitConv[nX][3][nY][__PREFIXO]+aTitConv[nX][3][nY][__NUMERO]+;
				aTitConv[nX][3][nY][__PARCELA]+aTitConv[nX][3][nY][__TIPO])
				//        Parcela                       Tipo
				
				nVlrGlobal  += SE1->E1_SALDO
				dDtVencto   := SE1->E1_VENCTO
                
				nQtdTitulos++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena a referencia do titulo aglutinado nos titulos de convenio baixados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
                RecLock("SE1",.F.)
                SE1->E1_CNVPREF  := cPrefConv
                SE1->E1_CNVNUM   := cNumGlobal
                MsUnlock()  
                
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa automatica do titulo do conveniado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AADD(aBaixa,{"E1_PREFIXO" 	,E1_PREFIXO			, Nil})	// 01
				AADD(aBaixa,{"E1_NUM"     	,E1_NUM				, Nil})	// 02
				AADD(aBaixa,{"E1_PARCELA" 	,E1_PARCELA			, Nil})	// 03
				AADD(aBaixa,{"E1_TIPO"    	,E1_TIPO			, Nil})	// 04
				AADD(aBaixa,{"E1_ORIGEM"	,""     			, Nil})	// 05
				AADD(aBaixa,{"AUTVALREC"	,E1_SALDO  			, Nil})	// 06
				AADD(aBaixa,{"AUTMOTBX"  	,cMotBx				, Nil})	// 07
				AADD(aBaixa,{"AUTDTBAIXA"	,dDataBase			, Nil})	// 08
				AADD(aBaixa,{"AUTDTCREDITO" ,dDataBase			, Nil})	// 09
				
				MSExecAuto({|x,y| FINA070(x,y)},aBaixa,3)										
				If lMsErroAuto
					cErro := MostraErro()
					LjGrvLog("TPL_DRO",cErro)
					MsgAlert(cErro)
					DisarmTransaction()
			        cTxtLog  := "Erro na baixa automática do título->Pref: "+SE1->E1_PREFIXO+", Número: "+SE1->E1_NUM+;
			                    ", Parcela: "+SE1->E1_PARCELA+", Cliente: "+SE1->E1_CLIENTE+"/"+SE1->E1_LOJA+CTRL
			        ConvGrvLog(cTxtLog)
			        LjGrvLog("TPL_DRO",cTxtLog)
			        lGeraLog  := .T.					
					Break
				EndIf
			EndIf
		Next nY
		
		// Utiliza a data base para vencimento do titulo unificado
		dDtVencto := dDataBase 
		
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Geracao automatica do titulo aglutinado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !GeraTitulo(nVlrGlobal,cPrefConv,aTitConv,nX,cNomeReduz,dDtVencto,cNumGlobal,@cParcGlobal)
		   cTxtLog  := "Erro na inclusão automática do título->Pref: "+cPrefConv+", Número: "+cNumGlobal+;
		                ", Parcela: 1, Cliente: "+aTitConv[nX][__CODCLI]+"/"+aTitConv[nX][__LOJCLI]+CTRL
		   ConvGrvLog(cTxtLog)
		   lGeraLog  := .T.					
		ElseIf nQtdTitulos > 0   
		   Aadd(aTitGlobal,{cNomeReduz,nQtdTitulos,cPrefConv,cNumGlobal,cParcGlobal,"FI",nVlrGlobal})
		EndIf
	Next nX
	END TRANSACTION
	
	//Elimina o semaforo da chaves criadas por "LockByName"
	For nZ:=1 to Len(aChvLock)
		UnLockByName( aChvLock[nZ], .T. )
	Next nZ
	
EndIf

If lQuery   
   dbSelectArea(cAliasQry)
   dbCloseArea()   
Else
   RetIndex("SE1")
   dbClearFilter()
   FErase(cIndex+OrdBagExt())  	  
EndIf

If lGeraLog
   MsgAlert("Foram encontradas algumas inconsistências no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cStartPath+"LogCONV.log no servidor.")
Else
	If lRet 
		MsgInfo("Titulo(s) gerado(s) com sucesso")
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VldFecha  ºAutor  ³Fernando Machima    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao dos dados de fechamento de convenio              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldFecha()

If Empty(dDtPgtoIni)
   MsgAlert("Preencher a data de pagamento inicial.")
   Return .F.
EndIf

If Empty(dDtPgtoFim)
   MsgAlert("Preencher a data de pagamento final.")
   Return .F.
EndIf

If Empty(cCodCliIni)
   MsgAlert("Preencher o codigo do cliente inicial.")
   Return .F.
EndIf

If Empty(cLojCliIni)
   MsgAlert("Preencher a loja do cliente inicial.")
   Return .F.
EndIf

If Empty(cCodCliFim)
   MsgAlert("Preencher o codigo do cliente final.")
   Return .F.
EndIf

If Empty(cLojCliFim)
   MsgAlert("Preencher a loja do cliente final.")
   Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GeraTituloºAutor  ³Fernando Machima    º Data ³  23/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o titulo aglutinado(global)de fechamento de convenio  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTitulo(	nVlrGlobal,cPrefConv,aTitConv	,nX,;
							cNomeReduz,dDtVencto,cNumGlobal	,cParcGlobal)
Local aTit		:= {}
Local c1DUP		:= GetMv("MV_1DUP")
Local cHistorico:= "TITULO FECHAMENTO CONVENIO"
Local cOrigem   := "FECHCONV"
Local lRet		:= .T.
Local cErro		:= ""
Local cNature  := &(SuperGetMv("MV_NATFIN",,'"FINAN"' ))

lMsErroAuto  := .F.
cParcGlobal     := LJParcela( 1, c1DUP )

If Empty(cNature)
   cNature := "FINAN"
EndIf

AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")         , NIL })
AADD(aTit , {"E1_PREFIXO"	, cPrefConv	             , NIL })
AADD(aTit , {"E1_NUM"		, cNumGlobal		     , NIL })
AADD(aTit , {"E1_PARCELA"	, cParcGlobal            , NIL })
AADD(aTit , {"E1_TIPO"		, "FI "		             , NIL })
AADD(aTit , {"E1_NATUREZ"	, cNature	             , NIL })
AADD(aTit , {"E1_CLIENTE"	, aTitConv[nX][__CODCLI], NIL })
AADD(aTit , {"E1_NOMCLI"	, SA1->A1_NREDUZ 	     , NIL })
AADD(aTit , {"E1_LOJA"		, aTitConv[nX][__LOJCLI], NIL })
AADD(aTit , {"E1_EMISSAO"	, dDatabase   			 , NIL })
AADD(aTit ,	{"E1_VENCTO"	, dDtVencto		         , Nil })
AADD(aTit ,	{"E1_VENCREA"	, DataValida(dDtVencto) , Nil })
AADD(aTit ,	{"E1_VALOR"  	, nVlrGlobal	         , Nil })
AADD(aTit ,	{"E1_SALDO"  	, nVlrGlobal    		 , Nil })
AADD(aTit ,	{"E1_MOEDA"	    , 1              		 , Nil })
AADD(aTit ,	{"E1_VLCRUZ" 	, nVlrGlobal     		 , Nil })
AADD(aTit ,	{"E1_HIST"   	, cHistorico		     , Nil })
AADD(aTit ,	{"E1_ORIGEM" 	, cOrigem   		     , Nil })

MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)

If lMsErroAuto
   cErro := MostraErro()
   LjGrvLog("TPL_DRO",cErro)
   MsgAlert(cErro)
   DisarmTransaction()
   lRet   := .F.
   Break
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvGrvLogºAutor  ³Fernando Machima    º Data ³  23/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do arquivo de log para erros de configuracao para  º±±
±±º          ³ fechamento de convenio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvGrvLog(cTexto)

Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local cArqLog    := cStartPath+"LogCONV.log"
Local nHandle 

If !File(cArqLog)                     
   nHandle := FCreate(cArqLog)
Else
	nHandle := FOpen(cArqLog,1)
	FSeek(nHandle,0,2)
EndIf

fWrite(nHandle,cTexto,Len(cTexto))          
FClose(nHandle)    

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³RetNumGlobºAutor  ³Fernando Machima    º Data ³  23/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retornar o numero do ultimo titulo aglutinado de convenio  º±±
±±º          ³ para a geracao do proximo titulo                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetNumGlobal(cPrefConv)
Local cNumero  := ""
Local cNumAux  := ""
Local nTamE1Num:= TamSX3("E1_NUM")[1]

DbSelectArea("SE1") 
SE1->(DbSetOrder(1))
SE1->(DbSeek(xFilial("SE1")+cPrefConv+'ZZZZZZ',.T.))            
SE1->(DbSkip(-1))
If SE1->E1_FILIAL+SE1->E1_PREFIXO == xFilial("SE1")+cPrefConv
	cNumero  := SE1->E1_NUM
	//Tratamento para verificar se o maior numero encontrado realmente eh o maior (pelo motivo qdo. o tamanho do campo E1_NUM tenha sido alterado)
	If Len(AllTrim(cNumero)) <> nTamE1Num
		cNumAux := StrZero(Val(cNumero)+1,nTamE1Num)
		If SE1->( DbSeek(xFilial("SE1")+cPrefConv+cNumAux) )
			While !SE1->(EOF()) .And. SE1->(E1_FILIAL + E1_PREFIXO) == xFilial("SE1")+cPrefConv
				If Val(SE1->E1_NUM) > Val(cNumero)
					cNumero  := SE1->E1_NUM
				Else
					Exit
				EndIf
				SE1->(DbSkip()) 
			End
		EndIf
	EndIf
Else
   //Nao existe nenhum titulo com este prefixo
   cNumero  := StrZero(0,nTamE1Num)
EndIf

Return cNumero