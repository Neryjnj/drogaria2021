#DEFINE GPI_GRAUS 9999
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDroAxLFA  บAutor  ณTHIAGO HONORATO     บ Data ณ  NOV/04     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grupo de Compras								              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Template Function DroAxLFA()
Private bRefresh    := {|| GPI020TOT() }

Private aRotina := MenuDef()

Private aAreaSM0 := SM0->(GetArea())

dbSelectArea("LFA")
LFA->(dbSetOrder(1))

mBrowse( 6,1,22,75,"LFA")

SM0->(RestArea(aAreaSM0))

Return  

/*ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Template Drograria                                         ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MenuDef()
	Local aRotina := {	{"Pesquisar"	,"AxPesqui"	,0	,1	,0	,.F.	}	,;
						{"Visualizar"	,"GPI020TL"	,0	,2	,0	,.T.	}	,;
						{"Incluir"		,"GPI020TL"	,0	,3	,0	,.T.	}	,;
						{"Alterar"		,"GPI020TL"	,0	,4	,0	,.T.	}	,;
						{"Excluir"		,"GPI020TL"	,0	,5	,0	,.T.	}	}
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPIA020TEL บAutor ณCarlos A. Gomes Jr. บ Data ณ  01/17/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao / Alteracao / Exclusao.                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPI020TL(cAlias,nReg,nOpcx)
Local cSeek     := NIL
Local cWhile    := NIL

Private lInclui := (nOpcx == 3)
Private nSaveSx8 := GetSx8Len()

If nOpcx <> 3
	LFA->(DbSetOrder(1))
	cSeek     := "'" + xFilial("LFA") + LFA->LFA_CODCOM + "'"
	cWhile    := "!EOF() .And. LFU_FILIAL + LFU_CODCOM == " + cSeek
EndIf

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXGRID
//   1         2       3        4        5       6      7       8    9   10    11     12      13     14     15        16        17      18     19      20     21         22       23      24      25       26       27    28     29
//locxMod(aParHead,aCposCab,aParRod,aCposRod,aParGrid,aCpos,cTitulo,aCordW,lGD,aCGD,aCSbx,nOpcx,cFldOK,cLineOk,cAllOk,__cFunOk,__cFunCanc,cIniLin,aGetsGD,nMax,lDelGetD,__aBotoes,__aTeclas,aObjs,__cDelOk,cOnInit,lEnchBar,lEndWnd,aOrditem)

LocxMod({"LFA"},,,,{"LFU",cWhile,,,,cSeek},,,,,,,nOpcx,,"T_TPLinok()","T_PFAlOk()","GPIUOK(__nOpcx,aRecnos)","TDREA014CANC(__nOpcx)",,,GPI_GRAUS,.T.,,,,,,.T.,.T.)

Return

/*----------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------------------------------*/
Function GPINIUF(oGetDados,nOpc)
Local nI := 0

If nOpc <> 3
	Return
EndIf
For nI :=  1 to GPI_GRAUS
	oGetDados:AddLine()
Next nI
n := 1
oGetDados:oBrowse:nAt := 1
oGetDados:oBrowse:Refresh()
Return

/*----------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------------------------------*/
Function GPIUOK(nOpcx,aRecnos)
Local lRet    := .T.
Local aCpos   := {}
Local nI      := 0
Local lNew    := .T.
Local cTmpLog := Dtos(Date())+Time()
Local nPosCod := AScan(aHeader,{|x| x[2] == "LFU_CODFIL" })

If nOpcx <= 2
	Return lRet
EndIf

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณInclui Grupo de Compras	    	    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

If nOpcx == 3
		
	Reclock("LFA",.T.)
	aCpos      := GeraCampos("LFA")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	LFA_FILIAL := xFilial("LFA")
	MsUnlock()

	For nI := 1 To Len(aCols)
		If !(aCols[nI][Len(aCols[nI])])
			If RecLock("LFU",.T.)
				LFU->LFU_FILIAL := xFilial("LFU")
				LFU->LFU_CODCOM := LFA->LFA_CODCOM
				AEval(aHeader,{|x,y| If( ColumnPos(x[2])> 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
				MsUnlock()
			EndIf
		EndIf
	Next nI

    If __lSX8
       While (GetSX8Len() > nSaveSx8)
	      ConfirmSX8()
	   End
    EndIf	     	
	                
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณAltera Gupo de Compras 	    	    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
ElseIf nOpcx == 4
	Reclock("LFA",.F.)
	aCpos      := GeraCampos("LFA")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	MsUnlock()

	Do While LFU->(DbSeek(xFilial("LFU")+M->LFA_CODCOM))
		RecLock("LFU",.F.)
		DbDelete()
		MsUnLock()
	EndDo
	
	For nI := 1 To Len(aCols)

		If !aCols[nI][Len(aHeader)+1]
			RecLock("LFU",.T.)
			LFU->LFU_FILIAL := xFilial("LFU")
			LFU->LFU_CODCOM := M->LFA_CODCOM
			AEval(aHeader,{|x,y| If( ColumnPos(x[2]) > 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
			MsUnlock()
		EndIf

	Next nI

	
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณExclui Grupo de Compras 	    	    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
ElseIf nOpcx == 5
	Reclock("LFA",.F.)
	DbDelete()
	MsUnlock()
	For nI := 1 To Len(aRecnos)
		LFU->(DbGoto(aRecnos[nI]))
		RecLock("LFU",.F.)
		DbDelete()
		MsUnlock()
	Next nI
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncaoณ TPLinok      ณ Por: Andre Melo				      ณ Data ณ 16/08/04 ณฑฑ
ฑฑภฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TPLinok()
Local lRet := .T.
Local nPosCod  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LFU_CODFIL" })

If Empty(aCols[n,nPosCod]) .and. !aCols[n,Len(aHeader)+1]
	Help("",1,"OBRIGAT")
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPFAlOk    บAutor  ณThiago P.Honorato   บ Data ณ  23/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe pelo menos uma  "Filial" 				  บฑฑ
ฑฑบ          ณ no momento de cofirmar alguma alteracao					  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function PFAlOk()
Local nDel := Len(aHeader)+1
Local lRet := .T.     

If AScan(aCols,{|x| x[nDel] == .F. }) == 0 
	MsgAlert("Deve existir pelo menos uma Filial para este Grupo de compras ")
	lRet :=  .F.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณVlAcolsD  บAutor  ณThiago P.Honorato   บ Data ณ  23/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o valor digitado no campo "Cod. Filial" 		  บฑฑ
ฑฑบ          ณ (LFU_CODFIL) ja existe									  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function VlAcols(cCod) //pega o valor que o usuแrio ira digitar no campo(LFU_CODFIL)
Local aAreaSM0 := {}
Local lRet     := .T.
Local nPos     := aScan(aCols,{|x,y| Upper(AllTrim(x[1])) == cCod}) 
Local ctplEmp  := ""

If nPos > 0 .And. nPos <> n // Verifica se o codigo da Filial que esta sendo digitada ja existe no aCols 
	MsgAlert("Jแ existe um registro relacionado a este c๓digo!")
	lRet := .F.
Endif

aAreaSMO := SM0->(GetArea())
ctplEmp  := SM0->M0_CODIGO 
If SM0->(!DbSeek(ctplEmp+cCod)) // verifica se o codigo da filial  existe no alias SM0
	MsgAlert("Filial nใo existe")
	lRet := .F.
Endif

//Restaurando as Areas
If !Empty(aAreaSM0)
	RestArea(aAreaSM0)
EndIf
  
Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTDREA014CAบAutor  ณFernando Machima    บ Data ณ  14/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle do semaforo da numeracao sequencial do codigo     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TDREA014CANC(nOpcx)

If nOpcx == 3  //Incluir
   If __lSX8
		While (GetSX8Len() > nSaveSx8)   	
			RollbackSX8()
		End
   EndIf        
EndIf

Return .T.