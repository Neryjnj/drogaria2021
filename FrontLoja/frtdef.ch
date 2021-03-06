/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FRTDEF    �Autor  �MARCELO KOTAKI      � Data �  25/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao �DEFINES DA TELA DE FRONT-LOJA                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MP8                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//�����������������������������������������������������������������
//�UTILIZADOS NA ROTINA DE VENDA DO FRONT-LOJA TELA ANTIGA E NOVA �
//�����������������������������������������������������������������

#DEFINE	 FRT_SEPARATOR		"----------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				1
#DEFINE AIT_COD			     	2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM			    7
#DEFINE AIT_VALDESC		   	    8
#DEFINE AIT_ALIQUOTA			9
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          		// Deducao de ICMS

#DEFINE _FORMATEF				"CC;CD"     		// Formas de pagamento que utilizam opera��o TEF para valida��o
#DEFINE CRLF                   Chr(13)+Chr(10) 	// Fim de Linha 

//����������������������������������������Ŀ
//�DEFINES criados pelos Templates		   �
//������������������������������������������


//����������������������������������������Ŀ
//�Usado no Template de Drogaria.          �
//������������������������������������������
// |-> [PBM VidaLink] --------    
#DEFINE VL_C_CODCL	 		 1
#DEFINE VL_C_LOJA 		 	 2  
#DEFINE VL_NDXPROD	 	 	 1
#DEFINE VL_EAN  	 	 	 2
#DEFINE VL_QUANTID		 	 3
#DEFINE VL_PRECO		   	 4    
#DEFINE VL_PRVENDA	    	 5  
#DEFINE VL_PRMAX 	 	 	 7 
#DEFINE VL_SUBSIDI		 	 8 
#DEFINE VL_PRVISTA	 	 	 9 
#DEFINE VL_DETALHE    	 	 2
#DEFINE VL_TOTVEND	    	 3
// |-> [Parametros PBM VidaLink > Array aParamVL] --------------
#DEFINE VLP_OHORA		 1
#DEFINE VLP_CHORA		 2
#DEFINE VLP_ODOC		 3
#DEFINE VLP_CDOC		 4
#DEFINE VLP_OCUPOM		 5
#DEFINE VLP_CCUPOM		 6
#DEFINE VLP_NLASTT		 7
#DEFINE VLP_NVLRTO		 8
#DEFINE VLP_NLASTI		 9
#DEFINE VLP_NTOTIT		 10
#DEFINE VLP_NVLRBR		 11
#DEFINE VLP_ODESCO		 12
#DEFINE VLP_OTOTIT		 13
#DEFINE VLP_OVLRTO		 14
#DEFINE VLP_OFOTOP		 15
#DEFINE VLP_NMOEDA		 16
#DEFINE VLP_CSIMBC		 17
#DEFINE VLP_OTEMP3		 18
#DEFINE VLP_OTEMP4		 19
#DEFINE VLP_OTEMP5		 20
#DEFINE VLP_NTAXAM		 21
#DEFINE VLP_OTAXAM		 22
#DEFINE VLP_NMOED2		 23
#DEFINE VLP_CMOEDA		 24
#DEFINE VLP_OMOEDA		 25
#DEFINE VLP_NVLRPE		 26
#DEFINE VLP_CCODPR		 27
#DEFINE VLP_CPRODU		 28
#DEFINE VLP_NTMPQU		 29
#DEFINE VLP_NQUANT		 30
#DEFINE VLP_CUNIDA		 31
#DEFINE VLP_NVLRUN		 32
#DEFINE VLP_NVLRIT		 33
#DEFINE VLP_OPRODU		 34
#DEFINE VLP_OQUANT		 35
#DEFINE VLP_OUNIDA		 36
#DEFINE VLP_OVLRUN		 37
#DEFINE VLP_OVLRIT		 38
#DEFINE VLP_LF7			 39
#DEFINE VLP_OPGTOS		 40
#DEFINE VLP_OPGTO2		 41
#DEFINE VLP_APGTOS		 42
#DEFINE VLP_APGTO2		 43
#DEFINE VLP_CORCAM		 44
#DEFINE VLP_CPDV		 45
#DEFINE VLP_LTEFPE		 46
#DEFINE VLP_ATEFBK		 47
#DEFINE VLP_ODLGFR		 48
#DEFINE VLP_CCLIEN		 49
#DEFINE VLP_CLOJAC		 50
#DEFINE VLP_CVENDL		 51
#DEFINE VLP_LOCIOS		 52
#DEFINE VLP_LRECEB		 53
#DEFINE VLP_LLOCKE		 54
#DEFINE VLP_LCXABE		 55
#DEFINE VLP_ATEFDA		 56
#DEFINE VLP_DDATAC		 57
#DEFINE VLP_NVLRFS		 58
#DEFINE VLP_LDESCI		 59
#DEFINE VLP_NVLRDE		 60
#DEFINE VLP_NVALIP		 61
#DEFINE VLP_AITENS		 62
#DEFINE VLP_NVLRME		 63
#DEFINE VLP_LESC		 64
#DEFINE VLP_APARCO		 65
#DEFINE VLP_CITEMC		 66
#DEFINE VLP_APARC2		 67
#DEFINE VLP_AKEYFI		 68
#DEFINE VLP_LALTVE		 69
#DEFINE VLP_LIMPNE		 70
#DEFINE VLP_LFECHA		 71
#DEFINE VLP_ATPADM		 72
#DEFINE VLP_CUSRSE		 73
#DEFINE VLP_CCONTR		 74
#DEFINE VLP_ACRDCL		 75
#DEFINE VLP_ACONTR		 76
#DEFINE VLP_ARECCR		 77
#DEFINE VLP_ATEFPE		 78
#DEFINE VLP_ABCKTE		 79
#DEFINE VLP_CCODCO		 80
#DEFINE VLP_CLOJCO		 81
#DEFINE VLP_CNUMCA		 82
#DEFINE VLP_UCLITP		 83
#DEFINE VLP_UPRODT		 84
#DEFINE VLP_LDESCT		 85
#DEFINE VLP_LDESCS		 86
#DEFINE VLP_AVLC		 87
#DEFINE VLP_AVLD		 88
#DEFINE VLP_NVIDAL		 89
#DEFINE VLP_CCDPGT		 90
#DEFINE VLP_CCDDES		 91
#DEFINE VLP_NVALTP		 92
#DEFINE VLP_NVALTC		 93
#DEFINE VLP_NVALT2		 94
#DEFINE VLP_LORIGO		 95
#DEFINE VLP_LVERTE		 96
#DEFINE VLP_NTOTDE		 97
#DEFINE VLP_LIMPOR		 98
#DEFINE VLP_NVLRP2		 99
#DEFINE VLP_NVLRP3		 100
#DEFINE VLP_NVLRAC		 101
#DEFINE VLP_NVLRD2		 102
#DEFINE VLP_NVLRP4		 103
#DEFINE VLP_NQTDEI		 104
#DEFINE VLP_NNUMPA		 105
#DEFINE VLP_AMOEDA		 106
#DEFINE VLP_ASIMBS		 107
#DEFINE VLP_CRECCA		 108
#DEFINE VLP_CRECCP		 109
#DEFINE VLP_CRECCO		 110
#DEFINE VLP_AIMPSS		 111
#DEFINE VLP_AIMPS2		 112
#DEFINE VLP_AIMPSP		 113
#DEFINE VLP_AIMPVA		 114
#DEFINE VLP_ATOTVE		 115
#DEFINE VLP_NTOTAL		 116
#DEFINE VLP_LRECAL		 117
#DEFINE VLP_ACOLS		 118
#DEFINE VLP_AHEADE		 119
#DEFINE VLP_ADADOS		 120
#DEFINE VLP_ACPROV		 121
#DEFINE VLP_AFORMC		 122
#DEFINE VLP_NTROCO		 123
#DEFINE VLP_NTROC2		 124
#DEFINE VLP_LDESCC		 125
#DEFINE VLP_NDESCO		 126
#DEFINE VLP_ADADO2		 127
#DEFINE VLP_LDIAFI		 128
#DEFINE VLP_ATEFMU		 129
#DEFINE VLP_ATITUL		 130
#DEFINE VLP_LCONFL		 131
#DEFINE VLP_ATITIM		 132
#DEFINE VLP_APARCE		 133
#DEFINE VLP_OCODPR		 134
#DEFINE VLP_CITEM2		 135
#DEFINE VLP_LCONDN		 136
#DEFINE VLP_NTXJUR		 137
#DEFINE VLP_NVALOR		 138
#DEFINE VLP_OMENSA		 139
#DEFINE VLP_OFNTGE		 140
#DEFINE VLP_CTIPOC		 141
#DEFINE VLP_LABREC		 142
#DEFINE VLP_LRESER		 143
#DEFINE VLP_ARESER		 144
#DEFINE VLP_OTIMER		 145
#DEFINE VLP_LRESUM		 146
#DEFINE VLP_NVALO2		 147
#DEFINE VLP_AREGTE		 148
#DEFINE VLP_LRECAR		 149
#DEFINE VLP_OONOFF		 150
#DEFINE VLP_NVALI2		 151
#DEFINE VLP__AMULT		 152
#DEFINE VLP__AMUL2		 153
#DEFINE VLP_NVLRD3		 154
#DEFINE VLP_OFNTMO		 155
#DEFINE VLP_LBSCPR		 156
#DEFINE VLP_OPDV		 157
#DEFINE VLP_AICMS		 158
#DEFINE VLP_LDESC2		 159
//-------Fim dos parametros PBM Vidalink ---


//����������������������������������������Ŀ
//�Valores para controle de transacao      �
//������������������������������������������
#DEFINE WAITID 	'FRONTVENDA'
