#INCLUDE "MSOBJECT.CH"
   

User Function DRO002 ; Return  // "dummy" function - Internal Use 

/*����������������������������������������������������������������������������������
���Classe    �DROEntidadeAnvisa�Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe que possui os campos da tabela LK9.					     ���
���			 �Anvisa (Agencia Nacinal de Vigilancia Sanitaria).					 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
����������������������������������������������������������������������������������*/
Class DROEntidadeAnvisa
	
	Data cLK9_FILIAL						//Filial
	Data cLK9_DATA                          //Data da movimentacao do medicamento
	Data cLK9_DOC							//Numero da nota				
	Data cLK9_SERIE							//Serie da nota
	Data cLK9_TIPMOV						//Tipo de movimentacao
	Data cLK9_CNPJFO						//CNPJ fornecedor 
	Data cLK9_DATANF						//Data da nota
	Data cLK9_CNPJOR						//CNPJ origem 
	Data cLK9_CNPJDE						//CNPJ destino
	Data cLK9_NUMREC						//Numero notificacao do medicamento
	Data cLK9_TIPREC						//Tipo receituario do medicamento
	Data cLK9_TIPUSO						//Uso do medicamento
	Data cLK9_DATARE						//Data prescricao do medicamento
	Data cLK9_NOMMED						//Nome prescritor
	Data cLK9_NUMPRO						//Numero registro profissional
	Data cLK9_CONPRO						//Conselho profissional
	Data cLK9_UFCONS						//UF do conselho
	Data cLK9_NOME							//Nome do comprador
	Data cLK9_TIPOID						//Tipo do documento
	Data cLK9_NUMID							//Numero do documento
	Data cLK9_ORGEXP						//Orgao expedidor
	Data cLK9_UFEMIS						//UF emissao do documento
	Data cLK9_MTVPER						//Motipo perda do medicamento
	Data cLK9_CODPRO						//Codigo do produto
	Data cLK9_DESCRI						//Descricao do medicamento
	Data cLK9_UM							//Unidade de Medida
	Data cLK9_LOTE                          //Numero lote do medicamento
	Data nLK9_QUANT                       	//Quantidade do medicamento
	Data cLK9_SITUA							//Situa
	Data cLK9_REGMS							//Registro MS medicamento
	Data cLK9_NOMEP							//Nome Paciente
	Data cLK9_CLASST						//Classe Terapeutica V 2.0
	Data cLK9_USOPRO						//Uso Prolongado     V 2.0
	Data nLK9_IDADEP						//Idade Paciente     V 2.0
	Data cLK9_UNIDAP						//Unidade Idade		 V 2.0
	Data cLK9_SEXOPA						//Sexo Paciente      V 2.0
	Data cLK9_CIDPA							//CId Paciente       V 2.0 
	Data cD_E_L_E_T_						//Registro apagado logicamente
	Data nR_E_C_N_O_                        //Registro da tabela
	
	Method EntAnvisa()						//Metodo construtor
		
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �DROEntidadeAnvis         �Autor  �Vendas Clientes    � Data �26/10/07���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe EntidadeAnvisa.					     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/

Class DROEntidadeAnvisaInv

	// Variaveia relacionadas a invetario
	Data cB1_FILIAL						
	Data cB1_CLASSTE
	Data cB1_REGMS
	Data cLOTE
	Data cB1_UM
	Data nB2_QATU 
	Data nR_E_C_N_O_                        //Registro da tabela

	Method InvAnvisa()						//Metodo construtor do inventario
		
EndClass


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �EntAnvisa        �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe EntidadeAnvisa.					     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method EntAnvisa() Class DROEntidadeAnvisa
	
	::cLK9_FILIAL 	:= ""
	::cLK9_DATA		:= ""
	::cLK9_DOC		:= ""
	::cLK9_SERIE	:= ""
	::cLK9_TIPMOV	:= ""
	::cLK9_CNPJFO	:= ""
	::cLK9_DATANF	:= ""
	::cLK9_CNPJOR	:= ""
	::cLK9_CNPJDE	:= ""
	::cLK9_NUMREC	:= ""
	::cLK9_TIPREC	:= ""
	::cLK9_TIPUSO	:= "" 	
	::cLK9_DATARE	:= ""
	::cLK9_NOMMED	:= ""
	::cLK9_NUMPRO	:= ""
	::cLK9_CONPRO	:= ""
	::cLK9_UFCONS	:= ""
	::cLK9_NOME		:= ""
	::cLK9_TIPOID	:= ""
	::cLK9_NUMID	:= ""
	::cLK9_ORGEXP	:= ""
	::cLK9_UFEMIS	:= ""
	::cLK9_MTVPER	:= ""
	::cLK9_CODPRO	:= ""
	::cLK9_DESCRI	:= ""
	::cLK9_UM		:= ""
	::cLK9_LOTE		:= ""
	::nLK9_QUANT	:= 0
	::cLK9_SITUA	:= ""
	::cLK9_REGMS    := ""	
	::cLK9_NOMEP	:= ""
	::cLK9_CLASST	:= ""
	::cLK9_USOPRO	:= ""
	::nLK9_IDADEP	:= 0
	::cLK9_UNIDAP	:= ""
	::cLK9_SEXOPA	:= ""
	::cLK9_CIDPA	:= "" 
	::cD_E_L_E_T_	:= ""
	::nR_E_C_N_O_	:= 0
    
Return Self


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �InvAnvisa        �Autor  �Vendas Clientes     � Data �  05/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe EntidadeAnvisa.					     ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method InvAnvisa() Class DROEntidadeAnvisaInv
	
	::cB1_FILIAL	:= ""						
	::cB1_CLASSTE	:= ""
	::cB1_REGMS	:= ""
	::cLOTE		:= ""
	::cB1_UM		:= ""
	::nB2_QATU 	:= 0
	::nR_E_C_N_O_	:= 0
    
Return Self
