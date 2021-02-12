#INCLUDE "rwmake.ch"

/*���������������������������������������������������������������������������
���Programa  �RAPrec    � Autor � AP6 IDE            � Data �  22/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
���������������������������������������������������������������������������*/
Template Function RAPrec()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario." 
Local cDesc3        := "Relat�rio de Analise de Pre�os"
Local titulo        := "Relat�rio de Analise de Pre�os"
Local nLin          := 80
Local Cabec1		:= "              Fornecedor                  Loja  Num.Doc.  Serie  Data Emiss.  Item    Cod. Prod.               Desc. Prod.           UM   Preco Cust.       Markup      Preco Venda     Diferenca"
Local Cabec2       := Replicate("-",40) + " " + "----  --------  -----  -----------  ----  ---------------  ------------------------------  --  -------------  -------------  -------------  -------------"
Local aOrd			:= {}

Private lAbortPrint := .F.
Private Tamanho     := "G"
Private NomeProg    := "RAPREC" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private wnrel		:= "RAPREC" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg		:= "TPLLJ2"
Private cString		:= "LJ2"

dbSelectArea("LJ2")
LJ2->(dbSetOrder(1))

Pergunte(cPerg,.T.)

//Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*���������������������������������������������������������������������������
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  22/12/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
���������������������������������������������������������������������������*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

dbSelectArea(cString)
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

//���������������������������������������������������������������������Ŀ
//� Posicionamento do primeiro registro e loop principal. Pode-se criar �
//� a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
//� cessa enquanto a filial do registro for a filial corrente. Por exem �
//� plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
//�                                                                     �
//� dbSeek(xFilial())                                                   �
//� While !EOF() .And. xFilial() == A1_FILIAL                           �
//�����������������������������������������������������������������������

DbSeek(xFilial("LJ2")+MV_PAR01)
While !EOF() .And. LJ2_FILIAL+LJ2_FORNEC <= xFilial("LJ2")+MV_PAR02

   If !(LJ2_EMISS >= MV_PAR03 .And. LJ2_EMISS <= MV_PAR04)
   		DbSkip()
   		Loop
   EndIf

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
   
   @ nLin,000 PSAY Posicione("SA2",1,xFilial("SA2")+LJ2->LJ2_FORNEC+LJ2_LOJA,"A2_NOME")
   @ nLin,043 PSAY LJ2_LOJA
   @ nLin,049 PSAY LJ2_DOC
   @ nLin,059 PSAY LJ2_SERIE
   @ nLin,066 PSAY DTOC(LJ2_EMISS)
   @ nLin,078 PSAY LJ2_ITEM
   @ nLin,084 PSAY LJ2_COD
   @ nLin,101 PSAY Posicione("SB1",1,xFilial("SB1")+LJ2->LJ2_COD,"B1_DESC")
   @ nLin,133 PSAY LJ2_UM
   @ nLin,135 PSAY Transform(LJ2_VUNIT,"@E 999,999,999.99")
   @ nLin,150 PSAY Transform(LJ2_MARKUP,"@E 999,999,999.99")
   @ nLin,165 PSAY Transform(LJ2_PRV1,"@E 999,999,999.99")
   @ nLin,180 PSAY Transform((LJ2_PRV1-(LJ2_MARKUP+LJ2_VUNIT)),"@E 999,999,999.99")
   
   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD

   nLin := nLin + 1 // Avanca a linha de impressao

   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
