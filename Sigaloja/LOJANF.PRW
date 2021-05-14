#INCLUDE "PROTHEUS.CH"
Static aCNPJNF  := {}              //CNPJs validos para impressao de nota fiscal
Static aCnpjPaf := {}              //cnpjS validos para utilizacao do PAF-ECF
Static aCnpjNoPaf:= {}				//cnpjs que podem funcionar sem paf porem não usam ECF
Static aCnpjExPaf:= {}				//cnpjs que podem funcionar sem paf (excecao mediante a apresentacao de documento/acordo sefaz)
Static lPafEcf	:= NIL				//verifica se ambiente esta no PAF-ECF
Static lGetNFCe := Nil				//Retorna se Estacao Configurada para utilizar NFCe
Static cPDVECF	:= ""		        //Serie do ECF, pois nos Estados que entregam o gerencial de Identificacao do PAF a liberação ocorre por ECF

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjCanUseNFºAutor  ³Vendas Clientes     º Data ³  19/05/05          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade verificar se o CNPJ passado        º±±
±±º          ³ como parametro esta em Regime Especial para a geracao de          º±±
±±º          ³ nota fiscal pelo SIGALOJA.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1 : CNPJ                                               	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 : .T. - Este CNPJ pode gerar nota fiscal            		 º±±
±±º          ³         .F. - Este CNPJ nao pode gerar nota fiscal         		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                  		 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjCanUseNF(cCNPJ)

Local aCNPJ		:= {}						// Array com os CNPJs em Regime Especial para a geracao da nota fiscal
Local nPos		:= 0						// Posicao do array de CNPJs
Local lRetorno 	:= .F.						// Retorno da funcao
Local nMVLJLBNT := SuperGetMv("MV_LJLBNT",,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando a rotina de Venda Assistida for executada do modulo SIGAHSP   ³
//³ (Gestao Hospitalar) sempre permite a emissao de NF.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo == 51 
	Return .T.
Endif

If nMVLJLBNT == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona no array de CNPJs os CNPJs que estao em Regime Especial³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "20.021.812/0001-20" } )			// VIMACO VIEIRA MATERIAIS P/ CONSTRUCAO LTDA.
	AAdd( aCNPJ, { "20.021.812/0002-01" } )			// VIMACO VIEIRA MATERIAIS P/ CONSTRUCAO LTDA.
	AAdd( aCNPJ, { "18.004.218/0001-80" } )			// VIEIRA & SILVA LTDA.
	AAdd( aCNPJ, { "02.240.308/0001-30" } )			// CLOVIS ATACADISTA LTDA
	AAdd( aCNPJ, { "38.875.597/0002-71" } )			// OXI-MAQ COMERCIAL LTDA
	AAdd( aCNPJ, { "38.875.597/0001-90" } )			// OXI-MAQ COMERCIAL LTDA
	AAdd( aCNPJ, { "73.794.224/0010-87" } )			// ROMELSA LTDA 
	AAdd( aCNPJ, { "02.240.308/0004-82" } )			// CLOVIS ATACADO
	AAdd( aCNPJ, { "61.234.985/0001-04" } )			// PNEUAC          
	AAdd( aCNPJ, { "61.234.985/0002-95" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0004-57" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0008-80" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0011-86" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0014-29" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0015-00" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0052-54" } )			// PNEUAC         
	AAdd( aCNPJ, { "61.234.985/0061-45" } )			// PNEUAC         
	AAdd( aCNPJ, { "57.430.894/0001-77" } )			// PROCESS INFORMATICA LTDA - EPP
	AAdd( aCNPJ, { "18.162.321/0001-58" } )			// VIEIRA TANNUS & CIA LTDA.
	AAdd( aCNPJ, { "07.270.366/0001-20" } )			// GERARDO BASTOS PNEUS E PEçAS LTDA.
	AAdd( aCNPJ, { "05.639.184/0001-58" } )			// GILBEARCA RESTAURANTE LTDA. - ME
	AAdd( aCNPJ, { "12.268.652/0003-52" } )			// TYRESOLES DE ALAGOAS LTDA
	AAdd( aCNPJ, { "46.382.115/0001-99" } )			// JORGE LASKANI LTDA.
	AAdd( aCNPJ, { "15.211.527/0001-32" } )			// GERSON & CIA LTDA.
	AAdd( aCNPJ, { "15.211.527/0002-13" } )			// GERSON & CIA LTDA.
	AAdd( aCNPJ, { "15.211.527/0012-95" } )			// GERSON & CIA LTDA.
	AAdd( aCNPJ, { "03.473.042/0001-38" } )			// LIVRARIA E PAPELARIA SEREIA LTDA
	AAdd( aCNPJ, { "05.423.963/0012-74" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0037-22" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0044-51" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0009-79" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0004-64" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0003-83" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0010-02" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0039-94" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0032-18" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0007-07" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0005-45" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0006-26" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0011-93" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0029-12" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0010-02" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0011-93" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0009-79" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0004-64" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0036-41" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0034-80" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0035-60" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0058-57" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0057-76" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0059-38" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0043-70" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0006-26" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0005-45" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0088-72" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0066-67" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0087-91" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0067-48" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0064-03" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0074-77" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0073-96" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0076-39" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0068-29" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0091-78" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0065-86" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0094-10" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0089-53" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0092-59" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "01.366.508/0001-70" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0095-00" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "05.423.963/0130-19" } )			// BRASIL TELECOM
	AAdd( aCNPJ, { "00.963.257/0001-49" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0003-00" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0004-91" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0005-72" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0006-53" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0007-34" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0008-15" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0009-04" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0010-30" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0011-10" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0012-00" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0014-63" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0002-20" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0012-00" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 
	AAdd( aCNPJ, { "00.963.257/0014-63" } )			// GUAIAPO ELETRODOMESTICOS LTDA.         
	AAdd( aCNPJ, { "00.963.257/0013-82" } ) 		// GUAIAPO ELETRODOMESTICOS LTDA.
	AAdd( aCNPJ, { "07.654.902/0001-90" } )			// 2C Comercio e Imp. de Presentes Finos LTDA
	AAdd( aCNPJ, { "48.296.420/0001-93" } )			// Aslam comercio de armarinhos LTDA
	AAdd( aCNPJ, { "78.575.149/0001-96" } ) 		// RJU com. benef. frutas e verduras LTDA.                
	AAdd( aCNPJ, { "48.296.420/0002-74" } )			// Aslam Comercio de Armarinhos LTDA
	AAdd( aCNPJ, { "48.296.420/0004-36" } )			// Aslam Comercio de Armarinhos LTDA
	AAdd( aCNPJ, { "07.052.924/0001-80" } )			// Lara de Paula Oliveira - ME - MG
	AAdd( aCNPJ, { "34.241.067/0001-30" } )			// FOXTROT COMERCIO IMPORTACAO E EXPORTACAO LTDA
	AAdd( aCNPJ, { "60.740.651/0001-40" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0015-45" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0003-01" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0004-92" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0005-73" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0006-54" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0007-35" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0009-05" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0010-30" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0011-11" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0012-00" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0016-26" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0017-07" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0019-79" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0020-02" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0021-93" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0002-20" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0022-74" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0008-16" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0014-64" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0014-64" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0018-98" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0018-98" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0023-55" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0024-36" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0025-17" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0026-06" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0027-89" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0028-60" } )			// CACULA DE PNEUS		
	AAdd( aCNPJ, { "60.740.651/0029-40" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0030-84" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0031-65" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0032-46" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0033-27" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0034-08" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "60.740.651/0035-99" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "18.027.448/0001-64" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "19.795.703/0001-81" } )			// CACULA DE PNEUS
	AAdd( aCNPJ, { "03.997.790/0001-10" } )			// CACULA DE PNEUS
	
	AAdd( aCNPJ, { "19.768.600/0004-70" } )			// PNEUS VIA NOBRE LTDA
	AAdd( aCNPJ, { "07.338.279/0001-67" } )			// Calca Valadares Comercial de Calcados Ltda.
	AAdd( aCNPJ, { "01.810.196/0004-95" } )			// Netgate Internacional de Eletronica Ltda
	AAdd( aCNPJ, { "59.699.827/0001-88" } )			// Triangulo Screen Ltda.
	AAdd( aCNPJ, { "08.014.537/0001-12" } )			// WILSON IND.COM.ARTEFATOS EM COURO
	AAdd( aCNPJ, { "21.704.762/0001-49" } )			// AFP Materiais para Construcao Ltda.
	AAdd( aCNPJ, { "48.551.626/0001-12" } )			// Eskelsen Super Recap Pneus Comercio e Representacao Ltda
	AAdd( aCNPJ, { "07.862.945/0001-61" } )			// GBR Auto Center Ltda.
	AAdd( aCNPJ, { "07.766.866/0001-57" } ) 		// MMR Comércio de Oneus Ltda. - ME
	AAdd( aCNPJ, { "03.365.985/0001-47" } ) 		// RVM Comércio de Pneus Acessórios Ltda.
	AAdd( aCNPJ, { "05.526.864/0001-65" } )			// BRS Auto Center Ltda.
	AAdd( aCNPJ, { "02.928.264/0001-35" } ) 		// TOP Speed Auto Center Ltda.
	AAdd( aCNPJ, { "07.089.559/0001-89" } ) 		// Grupo GBR Auto Center Ltda. 
	AAdd( aCNPJ, { "01.218.272/0001-25" } ) 		// Grupo GBR Auto Center Ltda. 
	AAdd( aCNPJ, { "07.283.471/0001-01" } ) 		// Grupo GBR Auto Center Ltda. 
	AAdd( aCNPJ, { "73.730.129/0002-00" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0001-29" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0004-71" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0006-33" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0007-14" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0008-03" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0009-86" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0010-10" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "73.730.129/0011-09" } ) 		// Bellenzier Pneus Ltda.
	AAdd( aCNPJ, { "05.520.066/0001-26" } ) 		// Lingerie e Confeccoes 25 Ltda
	AAdd( aCNPJ, { "06.131.309/0001-05" } )         // Lingerie Santana Ltda
	AAdd( aCNPJ, { "07.242.453/0001-73" } )         // M&R Lingerie Confeccoes
	AAdd( aCNPJ, { "02.057.465/0001-04" } )         // Carol Lingerie Ltda
	AAdd( aCNPJ, { "07.583.609/0001-80" } )         // Carolina Benfica Fernandes
	AAdd( aCNPJ, { "03.810.852/0001-32" } )         // Central da Lingerie Ltda
	AAdd( aCNPJ, { "00.165.771/0001-39" } )         // Tetragraf Gráficas e Papelaria Ltda. ME
	AAdd( aCNPJ, { "07.952.874/0001-98" } )         // Maria Eunice da Silva Lingerie ME
	AAdd( aCNPJ, { "04.326.192/0001-81" } )         // Mercado das Lingeries de Roupa Intimas Ltda. 
	AAdd( aCNPJ, { "04.235.403/0001-70" } )         // Alpha Lingerie
	AAdd( aCNPJ, { "06.115.881/0001-72" } )         // Rede Lingerie Ltda
	AAdd( aCNPJ, { "00.818.165/0001-75" } )         // Roma Lingerie Ltda
	AAdd( aCNPJ, { "08.059.427/0001-77" } )         // Ouro Auto Comercio de Pneus de Ourinhos Ltda.
	AAdd( aCNPJ, { "07.580.620/0001-96" } )         // Link Mania Comercio e Representação de Produtos de Com. e Inf.
	AAdd( aCNPJ, { "03.196.118/0001-25" } )         // Brave Eagle Auto Center
	AAdd( aCNPJ, { "03.385.749/0001-92" } )         // Top Eagle Auto Center Ltda.
	AAdd( aCNPJ, { "22.152.508/0001-48" } )         // Ormibal Ltda.
	AAdd( aCNPJ, { "02.492.276/0001-60" } )         // Evolution Produtos de Tecnologia Ltda.
	AAdd( aCNPJ, { "23.442.619/0001-51" } )         // J.E. Carvalho Feitosa & Cia Ltda.
	AAdd( aCNPJ, { "04.253.535/0006-30" } )         // J.E. Carvalho Feitosa & Cia Ltda.
	AAdd( aCNPJ, { "04.253.535/0001-25" } )         // J.E. Carvalho Feitosa & Cia Ltda.
	AAdd( aCNPJ, { "23.442.619/0003-13" } )         // J.E. Carvalho Feitosa & Cia Ltda.
	AAdd( aCNPJ, { "04.574.754/0001-06" } )         // J.E. Carvalho Feitosa & Cia Ltda.
	AAdd( aCNPJ, { "07.654.902/0002-71" } )         // 2C Comercio e importação de presentes finos Ltda 
	AAdd( aCNPJ, { "02.941.456/0001-81" } )         // Linetec do Brasil Ltda. ME (Process Informatica)
	AAdd( aCNPJ, { "08.190.976/0001-86" } ) 		// BS Colway Pneus
	AAdd( aCNPJ, { "07.654.902/0002-71" } ) 		// 2C COMERCIO E IMPORTAcaO DE PRESENTES FINOS LTDA.
	AAdd( aCNPJ, { "03.246.792/0001-77" } ) 		// ATI Brasil
	AAdd( aCNPJ, { "01.449.760/0001-43" } ) 		// Mathias Sport
	AAdd( aCNPJ, { "01.810.196/0001-42" } ) 		// Netgate
	AAdd( aCNPJ, { "61.234.985/0036-34" } )         // Pneuac
	AAdd( aCNPJ, { "58.343.104/0001-89" } )         // Gomes Tavares
	AAdd( aCNPJ, { "60.593.415/0001-48" } )         // Armarinhos São Vicente Ltda.
	AAdd( aCNPJ, { "60.397.361/0004-98" } )         // Cia Textil Niazi Chohfi
	AAdd( aCNPJ, { "01.745.420/0001-60" } )         // Fernet Comercial Importadora Ltda.
	AAdd( aCNPJ, { "76.508.548/0010-08" } )         // Sonaex S.A. Ind. e Com. De Aco
	AAdd( aCNPJ, { "77.501.989/0001-41" } )         // Lojas Laurita Ltda.
	AAdd( aCNPJ, { "08.229.877/0001-60" } )         // JOSE PEDRO GALVAO DE SOUZA FILHO                       
	AAdd( aCNPJ, { "23.123.375/0001-44" } )         //Comercial Zizi Ltda.
	AAdd( aCNPJ, { "03.761.201/0001-08" } )         //Maricel Moda Ltda.
	AAdd( aCNPJ, { "18.506.584/0001-37" } )         //Tecidos Zizi Ltda.
	AAdd( aCNPJ, { "03.029.620/0001-41" } )         //Espaço Infantil Ltda.
	AAdd( aCNPJ, { "03.029.638/0001-43" } )         //Confecções Rosário Ltda.
	AAdd( aCNPJ, { "03.051.575/0001-21" } )         //Colchões e Cia Ltda.
	AAdd( aCNPJ, { "03.051.560/0001-63" } )         //Zint Moda Intima Ltda.
	AAdd( aCNPJ, { "04.029.745/0001-34" } )         //A casual Ltda.
	AAdd( aCNPJ, { "08.274.233/0001-94" } ) 		//	Tapevel Rio Aces sórios Automotivos Ltda.
	AAdd( aCNPJ, { "57.599.581/0001-47" } ) 		//Ars Comercio de parafusos e ferragens     
	AAdd( aCNPJ, { "01.060.513/0001-50" } ) 		//Com . de Ferro e Aço Cotuvel Ltda.
	AAdd( aCNPJ, { "53.162.566/0001-86" } ) 		//Sobase Com. Mat. Para Co nstrução Ltda.
	AAdd( aCNPJ, { "53.162.566/0001-86" } ) 		//Sobase Com. Mat. Para Co nstrução Ltda.
	AAdd( aCNPJ, { "04.416.209/0001-91" } )			//Vanessa Amaral Pa scoalotti - EPP
	AAdd( aCNPJ, { "05.737.319/0001-18" } )			//Isac Ama ral - EPP
	AAdd( aCNPJ, { "08.098.407/0001-05" } )			//MC Comercio de Artigos para Informática Ltda. ME
	AAdd( aCNPJ, { "07.454.034/0001-03" } )			//Adonai Comércdio de Artigos para Inform ática e Papelaria Ltda. ME
	AAdd( aCNPJ, { "06.225.021/0001-91" } )			//Adonai Industria e Comercio de Cartuchos Ltda. EPP
	AAdd( aCNPJ, { "05.734.668/0001-86" } )	  		//Academia de Ginás tica Pequetita Ltda.
	AAdd( aCNPJ, { "04.631.468/0001-35" } )			//Runner Moema Estética e Ginástica Ltd a.
	AAdd( aCNPJ, { "05.702.490/0001-91" } )			//Acade mia RPE Ginástica Ltda.
	AAdd( aCNPJ, { "05.702.299/0001-40" } )			//Tupiguaes Academia de Ginástica Lt da.
	AAdd( aCNPJ, { "05.694.436/0001-41" } )			//Moru mbi Fitness de Ginástica Ltda.
	AAdd( aCNPJ, { "06.915.299/0001-90" } )			//Caixa Sonline Comercio de Embalagens Descartáveis
	AAdd( aCNPJ, { "05.408.888/0001-10" } )			//Web Caixa Comercio de Embalagens Descartáveis Ltda.
	AAdd( aCNPJ, { "04.488.624/0001-50" } )			//Brasexpress Comercio de Embalagens Descartáveis
	AAdd( aCNPJ, { "07.540.789/0001-12" } )			//W-Paper Comercio de Embalagens Descartáveis
	AAdd( aCNPJ, { "05.734.668/0001-86" } ) 		// Academia de Ginás tica Pequetita Ltda.
	AAdd( aCNPJ, { "04.631.468/0001-35" } ) 		// Runner Moema Estética e Ginástica Ltda .
	AAdd( aCNPJ, { "05.702.490/0001-91" } ) 		// Academi a RPE Ginástica Ltda.
	AAdd( aCNPJ, { "05.949.864/0001-78" } ) 		// Square Fitness Empreendimentos Ltda.
	AAdd( aCNPJ, { "05.702.481/0001-09" } ) 		// WRA Fitne ss Academia de Ginástica Ltda.
	AAdd( aCNPJ, { "05.938.853/0001-92" } ) 		// Paulista Fitness Empreendime nros Ltda.
	AAdd( aCNPJ, { "05.702.299/0001-40" } ) 		// Tupiguases Academia de Ginástica Ltda.
	AAdd( aCNPJ, { "05.924.206/0001-21" } ) 		// Parque Colina de S ão Francisco e Ginástica Ltda.
	AAdd( aCNPJ, { "05.694.436/0001-41" } ) 		// Morumbu Fitness Academia de Ginástica Ltda.
	AAdd( aCNPJ, { "07.671.892/0001-00" } ) 		// Academia de Ginástica e Saúde Klabin Ltda.
	AAdd( aCNPJ, { "05.827.856/0001-59" } ) 		// Santo And ré Atlética de Ginástica Ltda.
	AAdd( aCNPJ, { "07.050.047/0001-09" } ) 		// Runner Serviços de Digitação Ltda.
	AAdd( aCNPJ, { "07.265.222/0001-85" } ) 		// Instituto de Ensino e Pesquisa Runner Ltda.
	AAdd( aCNPJ, { "02.057.501/0001-30" } ) 		// Castropil Coml. Ltda.
	AAdd( aCNPJ, { "78.718.673/0001-79" } ) 		// Comercial Eletrica DZ Ltda.                  
	AAdd( aCNPJ, { "61.234.985/0074-60" } ) 		// PNEUAC COMERCIAL E IMPORTADORA LTDA.
	AAdd( aCNPJ, { "05.408.888/0001-10" } ) 		// WebCaixas Comercio de Embalagens(Brasemba)
	AAdd( aCNPJ, { "06.915.299/0001-90" } ) 		// Caixasonline Comercio de Embalagens(Brasemba)
	AAdd( aCNPJ, { "07.540.789/0001-12" } ) 		// W Paper Comercio de Embalagens(Brasemba)
	AAdd( aCNPJ, { "04.488.624/0001-50" } ) 		// Brasexpress Comercio de Embalagens(Brasemba)
	AAdd( aCNPJ, { "32.296.378/0013-04" } ) 		// Cereais Bramil Ltda.
	AAdd( aCNPJ, { "01.452.789/0001-84" } ) 		// RAKE & RAÍ TELECO MUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0002-65" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0003-46" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0004-27" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0005-08" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0006-99" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0008-50" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0009-31" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0010-75" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "01.452.789/0011-56" } ) 		// RAKE & R AÍ TELECOMUNICAÇÕES LTDA.
	AAdd( aCNPJ, { "02.712.991/0001-60" } ) 		// Bs Colway Pneus Ltda
	AAdd( aCNPJ, { "02.240.308/0001-30" } ) 		// Clovis Atacadista Ltda.
	AAdd( aCNPJ, { "02.240.308/0004-82" } ) 		// Clovis Atacadista Ltda.
	AAdd( aCNPJ, { "03.608.076/0001-92" } ) 		// Carlos Renat o Mendonça Segura. 
	AAdd( aCNPJ, { "03.608.076/0004-35" } ) 		// Carlos Renato Mendonça Segura. 
	AAdd( aCNPJ, { "03.608.076/0005-16" } ) 		// Carlos Renato Mendonça Segura. 
	AAdd( aCNPJ, { "03.608.076/0002-73" } ) 		// Carlos Renato Mendonça Segura. 
	AAdd( aCNPJ, { "01.998.069/0001-19" } ) 		// Actos Com. Imp. Exp. Ltda.
	AAdd( aCNPJ, { "69.427.219/0001-78" } ) 		// Maquisul Comercio LTDA
	AAdd( aCNPJ, { "69.427.219/0002-59" } ) 		// Maquisul Comercio LTDA
	AAdd( aCNPJ, { "03.246.792/0001-77" } ) 		// ATI BRASIL ARTIGO S TECNICOS  INDUSTRIAIS LTDA
	AAdd( aCNPJ, { "02.907.469/0003-04" } ) 		// Reference Music Center Ltda.
	AAdd( aCNPJ, { "95.388.161/0001-00" } ) 		//Calpar Comércio de Calcário Ltda
	AAdd( aCNPJ, { "64.844.582/0001-75" } )			// Czerkes & Farre Ltda. ME
	AAdd( aCNPJ, { "03.196.118/0001-25" } ) 		// Brave Eagle Auto Center Ltda.    
	AAdd( aCNPJ, { "07.766.866/0001-57" } ) 		// MMR. Comércio de Pneus Ltda.
	AAdd( aCNPJ, { "02.928.264/0001-35" } ) 		// Top Speed Auto Center Ltda.
	AAdd( aCNPJ, { "03.385.749/0001-92" } ) 		// Top Eag le Auto Center Ltda.
	AAdd( aCNPJ, { "07.283.471/0001-01" } ) 		// RRC omercial de Pneus Ltda.      
	AAdd( aCNPJ, { "05.526.864/0001-65" } ) 		// BRS Auto Center Ltda.
	AAdd( aCNPJ, { "08.190.976/0001-86" } ) 		// Chai Auto Center Ltda.
	AAdd( aCNPJ, { "07.862.945/0001-61" } ) 		// GBR Auto Center Ltda.
	AAdd( aCNPJ, { "03.365.985/0001-47" } ) 		// RVM Comércio de Pneus e Acessórios Ltda.
	AAdd( aCNPJ, { "05.520.906/0001-50" } ) 		// ARC Importação e Exportação Ltda.
	AAdd( aCNPJ, { "05.347.110/0001-48" } ) 		// Elkagil Comunicaç ão Visual Ltda. MR
	AAdd( aCNPJ, { "07.984.113/0001-18" } ) 		// Central Caxiasing Comunicação Visual
	AAdd( aCNPJ, { "06.038.588/0001-59" } ) 		// Jolikar C omunicação Visual Ltda.
	AAdd( aCNPJ, { "36.556.371/0001-00" } ) 		// Talento Diferenciado Comunicação Vis ual Ltda.
	AAdd( aCNPJ, { "39.465.968/0001-29" } ) 		// Decorall Comércio de Tecido Ltda.
	AAdd( aCNPJ, { "08.084.152/0001-21" } ) 		// Decorall de São Gonçalo Comércio de tecidos Ltda.
	AAdd( aCNPJ, { "17.437.013/0004-78" } ) 		// Encapa - Atacado e Varejo     
	AAdd( aCNPJ, { "17.437.013/0005-59" } ) 		// Encapa - Atacado e Varejo - Juiz de Fora
	AAdd( aCNPJ, { "57.430.894/0001-77" } ) 		// Process Informatica Ltda
	AAdd( aCNPJ, { "03.099.193/0001-78" } ) 		// Requinte Comercial Ltda.
	AAdd( aCNPJ, { "02.297.736/0001-07" } ) 		// Renovadora de Pneus Ok Ltda.
	AAdd( aCNPJ, { "13.161.435/0001-60" } ) 		// Agrovel Agricultura e Veterinária Ltda - MATRIZ 
	AAdd( aCNPJ, { "13.161.435/0003-21" } ) 		// Agrovel Agricultura e Veterinária Ltda - FILIAL OSVALDO ARANHA
	AAdd( aCNPJ, { "13.161.435/0004-02" } ) 		// Agrovel Agricultura e Veterinária Ltda - FILIAL FRANCISCO PORTO
	AAdd( aCNPJ, { "60.397.361/0006-50" } ) 		// Cia Têxtil Niazi Chohfi
	AAdd( aCNPJ, { "60.397.361/0004-98" } ) 		// Cia Têxtil Niazi Chohfi
	AAdd( aCNPJ, { "60.397.361/0003-07" } ) 		// Companhia Têxtil Niazi Chohfi
	AAdd( aCNPJ, { "06.976.612/0001-09" } ) 		// Niazi Chohfi Têxtil Ltda.
	AAdd( aCNPJ, { "60.873.288/0001-30" } ) 		// Martins da Costa & Cia Ltda.
	AAdd( aCNPJ, { "02.907.469/0001-34" } ) 		// Reference Music Center Ltda. EPP
	AAdd( aCNPJ, { "12.268.876/0001-00" } ) 		// Renovadora de Pneus OK
	AAdd( aCNPJ, { "03.180.029/0003-52" } ) 		// Mercado da Festa Comércio e Artigos para Festas e Embalagens Ltda.
	AAdd( aCNPJ, { "03.180.029/0004-33" } ) 		// Mercado da Festa Comércio e Artigos para Festas e Embalagens Ltda.
	AAdd( aCNPJ, { "03.180.029/0001-90" } ) 		// Mercado da Festa Comércio e Artigos para Festas e Embalagens Ltda.
	AAdd( aCNPJ, { "05.874.086/0001-03" } ) 		// Thermus Ar Condic ionado e Refrigeração S.A.
	AAdd( aCNPJ, { "02.340.278/0001-33" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0002-14" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0003-03" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0004-86" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0005-67" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0006-48" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0009-90" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0010-24" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0020-04" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0023-49" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0024-20" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0026-91" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0027-72" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0029-34" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0030-78" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0033-10" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0034-00" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0036-63" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0039-06" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0046-35" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "02.340.278/0052-83" } ) 		// Amazônia Celul ar S.A.
	AAdd( aCNPJ, { "44.145.886/0005-60" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0006.41" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0012-90" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0013-70" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0038-29" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0039-00" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0057-91" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0036-67" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0024-23" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0050-15" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0004-80" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0046-39" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0045-58" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0043-96" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0010-28" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0054-49" } ) 		// Zoomp Confecções Ltda.
	AAdd( aCNPJ, { "44.145.886/0007-22" } ) 		// Zoomp Confecções Ltda. 
	AAdd( aCNPJ, { "03.079.139/0002-41" } ) 		// Industrial Portex Ltda.
	AAdd( aCNPJ, { "08.503.555/0001-68" } ) 		// Vila Verde Centro Automotivo LTDA
	AAdd( aCNPJ, { "07.216.054/0001-38" } ) 		// J Sleiman & Cia Ltda.
	AAdd( aCNPJ, { "07.216.054/0005-61" } ) 		// J Sleiman & Cia Ltda.
	AAdd( aCNPJ, { "84.093.137/0001-28" } ) 		// Cooperativa Juriti
	AAdd( aCNPJ, { "84.093.137/0004-70" } ) 		// Cooperativa Juriti
	AAdd( aCNPJ, { "84.093.137/0003-90" } ) 		// Cooperativa Juriti
	AAdd( aCNPJ, { "16.166.043/0001-81" } ) 		// Regatta Sport Produtos Esportivos LTDA
	AAdd( aCNPJ, { "00.968.443/0003-32" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "00.968.443/0005-02" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "00.968.443/0004-13" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "00.968.443/0002-51" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "00.968.443/0001-40" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "00.968.443/0006-85" } )			// Forca 10 Produtos Esportivos Ltda. 
	AAdd( aCNPJ, { "05.605.482/0003-99" } )			// Leste Marine Importacao e Exportacao Ltda.   
	AAdd( aCNPJ, { "60.869.013/0001-23" } ) 		// Centro Auditivo Widex-Brasitom Ltda. 
	AAdd( aCNPJ, { "05.867.340/0001-38" } ) 		// Comercial e Armarinhos AK 59 Ltda. 
	AAdd( aCNPJ, {"00.778.553/0001-70" } ) 			//O Mestre Materiais de Construção Ltda. 
	AAdd( aCNPJ, {"96.832.076/0003-14", CTOD("27/09/2010") } )			// Juagro Comercio e Representacoes Ltda. 
	AAdd( aCNPJ, {"02.199.521/0001-45", CTOD("18/04/2010") } )			// Carvalho & Freire Comercio e Representacoes Ltda.
	AAdd( aCNPJ, {"05.423.963/0121-28" } ) 								//Brasil Telecom
	AAdd( aCNPJ, {"03.391.468/0001-42" } ) 								//Suasolda Comércio e Tecnologia em Soldagem Ltda. 
	AAdd( aCNPJ, {"00.778.553/0003-31" } ) 								//O MESTRE MAT DE CONSTRUÇÃO LTDA                        
	AAdd( aCNPJ, {"05.557.910/0001-93" } ) 								//O MESTRE MAT DE CONSTRUÇÃO LTDA
	AAdd( aCNPJ, {"21.313.739/0001-29", CTOD("21/11/2010") } ) 		//Lopez Materiais de Construção Ltda.
	AAdd( aCNPJ, {"04.072.870/0012-80" } ) 								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0013-60" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0014-41" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0015-22" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0016-03" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0010-18" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0002-08" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0011-07" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"04.072.870/0007-12" } ) 								//HDSP Comércio de Veículos Ltda.                        
	AAdd( aCNPJ, {"05.017.443/0001-09" } ) 								//K.A. Mendes                    
	AAdd( aCNPJ, {"17.207.093/0001-22" } ) 								//Comercial Jorge Ltda.
	AAdd( aCNPJ, {"61.937.975/0001-35" } ) 								//Lar Escola Sao Francisco
	AAdd( aCNPJ, {"61.612.735/0001-60" } ) 								//Importador a Teixeira de Ferragens Ltda.
	AAdd( aCNPJ, {"17.437.013/0001-25" } ) 								//Encapa Atacado e Varejo Ltda.
	AAdd( aCNPJ, {"01.761.367/0001-90", CTOD("01/08/2008") } ) 	   		//Savasi
	AAdd( aCNPJ, {"01.761.367/0002-71", CTOD("01/08/2008") } ) 	   		//BH
	AAdd( aCNPJ, {"01.761.367/0004-33", CTOD("01/08/2008") } ) 	   		//Del Rey
	AAdd( aCNPJ, {"01.761.367/0005-14", CTOD("01/08/2008") } ) 	   		//Parana
	AAdd( aCNPJ, {"01.761.367/0006-03", CTOD("01/08/2008") } ) 	   		//Amazonas
	AAdd( aCNPJ, {"01.761.367/0007-86", CTOD("01/08/2008") } ) 			//Big
	AAdd( aCNPJ, {"01.761.367/0008-67", CTOD("01/08/2008") } ) 	   		//Cidade
	AAdd( aCNPJ, {"01.761.367/0009-48", CTOD("01/08/2008") } ) 			//Diamond
	AAdd( aCNPJ, {"02.912.819/0001-50", CTOD("01/08/2008") } ) 			//Minas
	AAdd( aCNPJ, {"61.937.975/0001-35" } )								//Lar Escola Sao Francisco
	AAdd( aCNPJ, {"07.862.945/0001-61" } )								//GBR Auto Center Ltda. 
	AAdd( aCNPJ, {"61.287.546/0005-93" } )								//Pia Sociedade de São Paulo 
	AAdd( aCNPJ, {"08.961.274/0001-59" } )								//Distribuidora de Embalagens Castropil Ltda
	AAdd( aCNPJ, {"02.648.868/0001-28" } )								//Ricardo Kastropil
	AAdd( aCNPJ, {"05.595.560/0001-50" } )								//Empresa: Comercial O&P LTDA
	AAdd( aCNPJ, {"01.329.973/0001-31" } )								//FRITOOLS FERRAMENTAS MAQ. E EQUIPAM
	AAdd( aCNPJ, {"07.526.625/0001-30" } )								//Naco Base Materiais de Construcao
	AAdd( aCNPJ, {"57.599.581/0001-47" } )								//ARS Comércio de Parafusos e Ferragens Ltda.
	AAdd( aCNPJ, {"05.423.963/0125-51" } )								//Brasil Telecom Celular S/A 
	AAdd( aCNPJ, {"05.423.963/0122-09" } )								//Brasil Telecom Celular S/A 
	AAdd( aCNPJ, {"19.525.260/0004-51" } )								//Companhia Manufatora de Tecidos e Algodão 
	AAdd( aCNPJ, {"62.843.917/0001-05" } )								//Marisa de Andrade de Lucca EPP 
	AAdd( aCNPJ, {"04.268.935/0001-04" } )							  	//Porto de Areia Pedra Grande São Roque Ltda. EPP   
	AAdd( aCNPJ, {"60.322.401/0001-90" } )							   	//Ronaldo de Lucca EPP 
	AAdd( aCNPJ, {"72.651.508/0001-60" } )							   	//Malharia Ipanema Ltda
	AAdd( aCNPJ, {"03.237.058/0001-41" } )								//Transportes de Areia Limoeiro Ltda
	AAdd( aCNPJ, {"08.386.945/0001-03" } )								//Tecno Trade-Comércio de Produtos Promocionais Ltda, ME      
	AAdd( aCNPJ, {"04.072.870/0015-22" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0007-12" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0001-27" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0002-08" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0010-18" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0011-07" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0012-80" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0013-60" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0014-41" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"04.072.870/0016-03" } )								//HDSP Comércio de Veículos Ltda. 
	AAdd( aCNPJ, {"08.317.673/0001-81" } )								//Iluminatti Comércio de Materiais Elétricos Ltda. EPP   
	AAdd( aCNPJ, {"05.382.938/0001-37" } )								//Industria da Mata – Prod. de Limpeza Ltda.   
	AAdd( aCNPJ, {"38.488.649/0001-76" } )								//Edwilson Martins da Mata EPP                    
	AAdd( aCNPJ, {"05.423.963/0124-70" } )								//14 Brasil Telecom Celular S/A
	AAdd( aCNPJ, {"05.423.963/0123-90" } )								//14 Brasil Telecom Celular S/A
	AAdd( aCNPJ, {"05.423.963/0128-02" } )								//14 Brasil Telecom Celular S/A
	AAdd( aCNPJ, {"01.452.789/0001-84" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0002-65" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0003-46" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0004-27" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0005-08" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0006-99" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0007-70" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0008-50" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0009-31" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0010-75" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0011-56" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"01.452.789/0012-37" } )								// Rake & Rai Telecomunicações Ltda.
	AAdd( aCNPJ, {"25.567.140/0009-24" } )								// RG PNEUS LTDA.
	AAdd( aCNPJ, {"16.110.041/0005-02", CTOD("29/10/2009") } ) 			// Fud. C ent. Bras. De Prot. E Pesq. Das Tartarugas Marinhas 
	AAdd( aCNPJ, {"16.110.041/0001-70", CTOD("16/12/2010") } ) 			// Fud. C ent. Bras. De Prot. E Pesq. Das Tartarugas Marinhas 
	AAdd( aCNPJ, {"16.110.041/0012-23", CTOD("23/09/2010") } ) 			// Fud. C ent. Bras. De Prot. E Pesq. Das Tartarugas Marinhas 
	AAdd( aCNPJ, {"16.110.041/0016-57" } ) 								// Fud. C ent. Bras. De Prot. E Pesq. Das Tartarugas Marinhas 
	AAdd( aCNPJ, {"61.287.546/0018-08" } ) 								// Pia Sociedade de São Paulo
	AAdd( aCNPJ, {"09.526.489/0001-04" } ) 								// Ecoprodutos Comér cio de produtos Sustentáveis Ltda. 
	AAdd( aCNPJ, {"24.333.411/0006-71" } ) 								// SCALON & CERCHI L TDA. 
	AAdd( aCNPJ, {"24.333.411/0004-00" } ) 								// SCALON & CERCHI LTDA. 
	AAdd( aCNPJ, {"09.065.773/0001-20" } ) 								// B. P. Dalles & Ci a Ltda. 
	AAdd( aCNPJ, {"07.847.146/0001-16" } ) 								// Empório Rede Duque Ltda.
	AAdd( aCNPJ, {"02.240.308/0003-00" } ) 								// Clovis Atacadista Ltda.
	AAdd( aCNPJ, {"02.240.308/0004-82" } ) 								// Clovis Atacadista Ltda.
	AAdd( aCNPJ, {"02.240.308/0005-63" } ) 								// Clovis Atacadista Ltda..
	AAdd( aCNPJ, {"02.240.308/0006-44" } ) 								// Clovis Atacadista Ltda.
	AAdd( aCNPJ, {"08.257.993/0001-93", CTOD("31/12/2009") } ) 			// Otica da Biblia com. de Artigo Opticos ltda.
	AAdd( aCNPJ, {"58.520.792/0001-05" } ) 								// OMICRON SISTEMAS COMÉRCIO E PRESTAÇÃO DE SERVIÇOS EM INFORMÁTICA E TELECOMUNICAÇ ÕES LTDA. 
	AAdd( aCNPJ, {"05.423.963/0027-50" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0049-66" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0046-13" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0047-02" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0045-32" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0091-78" } )		 						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0095-00" } )		 						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0100-01" } )		 						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0101-84" } )		 						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0109-31" } )		 						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0108-50" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0111-56" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0113-18" } )		  						// BRASIL TELECOM
	AAdd( aCNPJ, {"05.423.963/0117-41" } )								// BRASIL TELECOM
	AAdd( aCNPJ, {"02.240.308/0002-10" } )								// Clovis Atacadista Ltda. 
	AAdd( aCNPJ, {"61.287.546/0027-07" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0002-40" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0010-50" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0032-66" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0033-47" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0029-60", CTOD("21/01/2010") } )			// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0035-09", CTOD("25/04/2011") } )			// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0039-32", CTOD("24/07/2009") } )			// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0042-38" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0031-85" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0024-56" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0014-84" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0016-46" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0020-22" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"61.287.546/0009-17" } )								// PIA SOCIEDADE DE SÃO PAULO 
	AAdd( aCNPJ, {"16.110.041/0002-51" } )								// FUND CENTRO BRAS. PROT. P ESQ. TARTARUGAS MARINHAS
	AAdd( aCNPJ, {"16.110.041/0015-76" } )								// FUND CENTRO BRAS. PROT. P ESQ. TARTARUGAS MARINHAS
	AAdd( aCNPJ, {"16.110.041/0007-66", CTOD("22/01/2010") } )			// FUND CENTRO BRAS. PROT. P ESQ. TARTARUGAS MARINHAS
	AAdd( aCNPJ, {"16.110.041/0010-61", CTOD("28/06/2009") } )			// FUND CENTRO BRAS. PROT. P ESQ. TARTARUGAS MARINHAS
	AAdd( aCNPJ, {"16.110.041/0022-03", CTOD("22/01/2010") } )			// FUND CENTRO BRAS. PROT. P ESQ. TARTARUGAS MARINHAS
	AAdd( aCNPJ, {"05.423.963/0033-07" } )								// RS09 
	AAdd( aCNPJ, {"05.423.963/0040-28" } )								// RS11 
	AAdd( aCNPJ, {"05.423.963/0127-13" } )								// RS20  
	AAdd( aCNPJ, {"05.423.963/0126-32" } )								// RS21  
	AAdd( aCNPJ, {"54.069.380/0001-40" } )								// FUNDAÇÃO EDITORA DA UNESP
	AAdd( aCNPJ, {"61.287.546/0042-38" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0004-02" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0022-94" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0023-75" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0021-03" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0040-76", CTOD("23/07/2012") } )			// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0015-65" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0019-99" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0026-18" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"61.287.546/0034-28" } )								// PIA SOCIEDADE DE SÃO PAULO
	AAdd( aCNPJ, {"08.799.707/0001-11" } )								// VISUAL CORES TINTAS E TEXTURA LTDA. 
	AAdd( aCNPJ, {"07.627.167/0001-26" } )								// VISUAL CORES TINTAS E TEXTURA LTDA. 
	AAdd( aCNPJ, {"02.240.308/0003-00" } )								// Clovis Atacadista Ltda. 
	AAdd( aCNPJ, {"02.240.308/0004-82" } )								// Clovis Atacadista Ltda. 
	AAdd( aCNPJ, {"02.240.308/0005-63" } )								// Clovis Atacadista Ltda. 
	AAdd( aCNPJ, {"02.240.308/0006-44" } )								// Clovis Atacadista Ltda. 
	AAdd( aCNPJ, {"61.080.370/0007-66" } )								// Editora Atlas S.A.
	AAdd( aCNPJ, {"61.080.370/0001-70" } )								// Editora Atlas S.A.
	AAdd( aCNPJ, {"61.080.370/0003-32" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61.080.370/0005-02" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61.080.370/0006-85" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61.080.370/0008-47" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61.080.370/0013-04" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61.080.370/0014-95" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"61-080.370/0015-76" } )								// Editora Atlas S.A. 
	AAdd( aCNPJ, {"42.161.687/0001-97" } )								// FUNDAÇÃO ESCOLA NACIONAL DE SEGUROS 
	AAdd( aCNPJ, {"09.451.214/0001-59" } )								// DISTRIBUIDORA DE MÓVEIS IPANEMA LTDA. 
	AAdd( aCNPJ, {"07.064.293/0005-43" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0002-09" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0007-05" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0008-96" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0009-77" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0003-81" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0006-24" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0001-10" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0014-34" } )								// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0013-53" } )								// MARIA ELIZA MARIOTTO      
	AAdd( aCNPJ, {"07.064.293/0004-62" } )								// MARIA ELIZA MARIOTTO      
	AAdd( aCNPJ, {"07.064.293/0010-00" } )								// MARIA ELIZA MARIOTTO      
	AAdd( aCNPJ, {"07.064.293/0011-91" } )								// MARIA ELIZA MARIOTTO      
	AAdd( aCNPJ, {"07.064.293/0012-72" } )								// MARIA ELIZA MARIOTTO      
	AAdd( aCNPJ, {"07.064.293/0015-15", CTOD("13/08/2009") } )			// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0017-87", CTOD("13/08/2009") } )			// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0016-04", CTOD("13/08/2009") } )			// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.064.293/0018-68", CTOD("29/08/2009") } )			// MARIA ELIZA MARIOTTO
	AAdd( aCNPJ, {"07.227.426/0001-21", CTOD("13/12/2009") } )			// COMERCIAL COLCHÕES CASTOR DE JUIZ DE FORA LTDA. 
	AAdd( aCNPJ, {"07.227.426/0002-02", CTOD("05/08/2010") } )			// COMERCIAL COLCHÕES CASTOR DE JUIZ DE FORA LTDA. 
	AAdd( aCNPJ, {"07.227.426/0003-93", CTOD("01/08/2009") } )			// COMERCIAL COLCHÕES CASTOR DE JUIZ DE FORA LTDA. 
	AAdd( aCNPJ, {"07.227.426/0004-74", CTOD("12/09/2009") } )			// COMERCIAL COLCHÕES CASTOR DE JUIZ DE FORA LTDA. 
	AAdd( aCNPJ, {"03.738.541/0001-00", CTOD("22/01/2011") } )			// AGROINSUMOS LTDA. 
	AAdd( aCNPJ, {"03.738.541/0002-90", CTOD("11/02/2011") } )			// AGROINSUMOS LTDA. 
	AAdd( aCNPJ, {"03.738.541/0003-71", CTOD("09/06/2011") } )			// AGROINSUMOS LTDA. 
	AAdd( aCNPJ, {"04.791.160/0001-57", CTOD("10/09/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"04.791.160/0002-38", CTOD("23/01/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"05.574.282/0001-54", CTOD("12/09/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"06.850.173/0002-66", CTOD("23/01/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"05.780.767/0002-85", CTOD("23/11/2008") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"05.648.095/0001-78", CTOD("26/12/2010") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"05.780.767/0001-02", CTOD("16/12/2009") } )			// C&V SUL BAHIA AGROPECUARIA LTDA. 
	AAdd( aCNPJ, {"10.322.994/0001-16" } )								// Comercial PowerField Ltda. 
	AAdd( aCNPJ, {"61.546.131/0001-63" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"61.546.131/0005-97" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"61.546.131/0006-78" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"61.546.131/0009-10" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"61.546.131/0003-25" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"61.546.131/0010-54" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"44.137.974/0001-97" } )								// MADEIRAS MORUMBI LTDA. 
	AAdd( aCNPJ, {"44.137.974/0005-10" } )								// COMPENSADOS LANE LTDA.
	AAdd( aCNPJ, {"73.321.655/0001-35" } )								// SULFORMS IND. E COM. LTDA.  
	AAdd( aCNPJ, {"05.460.864/0002-90", CTOD("07/11/2009") } )			// Pólo Insumos Ltda.               
	AAdd( aCNPJ, {"31.816.515/0002-79", CTOD("25/10/2009") } )			// VN Comércio e Serviços Ltda. 
	AAdd( aCNPJ, {"06.850.173/0001-85", CTOD("27/11/2010") } )			// Ceres Agrícola Ltda. 
	AAdd( aCNPJ, {"05.634.329/0006-32", CTOD("03/08/2010") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0012-80", CTOD("18/08/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0010-19", CTOD("04/07/2010") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0011-08", CTOD("15/02/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0007-13", CTOD("18/10/2010") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0008-02", CTOD("26/08/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"05.634.329/0002-09", CTOD("05/09/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"03.738.541/0001-00", CTOD("22/01/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"03.738.541/0002-90", CTOD("11/02/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"03.738.541/0003-71", CTOD("09/06/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"04.791.160/0001-57", CTOD("10/09/2011") } )			// União Insumos Agrícolas Ltda. 
	AAdd( aCNPJ, {"04.791.160/0002-38", CTOD("23/01/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"05.574.282/0001-54", CTOD("12/09/2011") } )			// CAMPO VERDE RURAL LTDA. 
	AAdd( aCNPJ, {"06.850.173/0002-66", CTOD("23/01/2011") } )			// CERES AGRICOLA LTDA. 
	AAdd( aCNPJ, {"05.780.767/0002-85", CTOD("22/11/2008") } )			// CAMPO VERDE SUL BAHIA AGRICOLA LTDA. 
	AAdd( aCNPJ, {"05.648.095/0001-78", CTOD("26/12/2010") } )			// VALE FERTIL AGRICOLA LTDA. 
	AAdd( aCNPJ, {"05.780.767/0001-02", CTOD("16/12/2009") } )			// C&V SUL BAHIA AGROPECUARIA LTDA. 
	AAdd( aCNPJ, {"04.835.476/0001-01" } )								// Imprensa Oficial do Estado.
	AAdd( aCNPJ, {"08.855.562/0001-29" } )								// Lojas SPM Moveis Ltda.
	AAdd( aCNPJ, {"04.571.019/0001-49" } )								// Lojas SPM Moveis Ltda.
	AAdd( aCNPJ, {"04.571.019/0001-49" } )								// Cepar Materiais de Construção Ltda.
	
	AAdd( aCNPJ, {"07.749.164/0001-65" } )								// Otica Gospel Aldeota Ltda ME
	AAdd( aCNPJ, {"06.049.768/0001-36" } )								// Otica Face de Cristo ME
	AAdd( aCNPJ, {"03.963.213/0001-07" } )								// Otica dos Evangelhos Ltda. ME
	AAdd( aCNPJ, {"04.003.534/0001-22" } )								// Otica Caldas Ltda. ME
	AAdd( aCNPJ, {"04.003.534/0002-03" } )								// Otica Caldas Ltda. ME
	AAdd( aCNPJ, {"04.234.693/0001-38" } )								// Otica Evangelista Ltda. ME
	AAdd( aCNPJ, {"03.963.213/0002-98" } )								// Otica dos Evangélicos Ltda. ME
	AAdd( aCNPJ, {"10.188.315/0001-68" } )								// Otica Cristã Comércio de Artigos Ópticos Ltda. ME
	
	AAdd( aCNPJ, {"01.117.668/0001-86" } )								// LSV Com. Prods. Alimentícios Ltda. 
	
	AAdd( aCNPJ, {"84.054.329/0001-25" } )								// BRASFERRO COM. IN. IMP. EXP. LTDA.
	
	AAdd( aCNPJ, {"13.004.999/0001-99" } )                             // Huteba Mercantil Ltda.
	AAdd( aCNPJ, {"13.004.999/0003-50" } )                             // Huteba Mercantil Ltda. 
	AAdd( aCNPJ, {"13.004.999/0002-70" } )                             // Huteba Mercantil Ltda. 
	
	AAdd( aCNPJ, {"04.696.264/0001-82" } )      					    // LIGACAO COMERCIAL LTDA.  
	
	AAdd( aCNPJ, {"56.354.897/0001-06" } )  							// Barrela Pneus Ltda.    
	
	AAdd( aCNPJ, {"93.273.860/0001-80" } ) 								// STADTBUS TRANSPORTES LTDA.   
	
	AAdd( aCNPJ, {"61.080.370/0007-66" } ) 								// Editora Atlas SA.   
	
	AAdd( aCNPJ, {"56.354.897/0003-78" } )                             // BARRELA RECAUCHUTAGEM DE PNEUS LTDA
	
	//------------------------------
	//| GUAPORÉ ELETROMÓVEIS LTDA  |
	//------------------------------
	AAdd( aCNPJ, {"08.908.749/0001-43", CTOD("07/12/2011") } )			
	AAdd( aCNPJ, {"08.908.749/0002-24", CTOD("22/05/2012") } )
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Issam Importacao e Exportacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"00.327.385/0001-04" } )								
	AAdd( aCNPJ, {"00.327.385/0002-87" } )								
	AAdd( aCNPJ, {"00.327.385/0003-68" } )								
	AAdd( aCNPJ, {"00.327.385/0005-20" } )								
	AAdd( aCNPJ, {"00.327.385/0006-00" } )								                
	AAdd( aCNPJ, {"00.327.385/0007-91" } )								                
	AAdd( aCNPJ, {"00.327.385/0009-53" } )								                                
	                                
	AAdd( aCNPJ, {"00.850.209/0001-44" } )								// Top Cores Distribuidora de Tintas Ltda. 		                                                
	
	AAdd( aCNPJ, {"64.776.727/0001-48" } )								// Paola Di Verona Produtos Alimentícios Ltda. EPP
	
	AAdd( aCNPJ, {"61.546.131/0011-35" } )								// Compensados Lane Ltda.
	
	AAdd( aCNPJ, {"53.805.222/0001-48" } )								// Alapar Alavanca Com. de Parafusos Ltda. 
	
	AAdd( aCNPJ, {"47.532.825/0001-10" } )								// Robert Rammert & Cia Ltda
	
	AAdd( aCNPJ, {"91.023.168/0001-78" } )								// COTRIJUC COOPERATIVA AGROPECUÁRIA DE JULIO DE CASTILHOS
	
	AAdd( aCNPJ, {"04.021.332/0001-03"  , CTOD("15/01/2011") }  )		// Tecmedica Hospitalar Ltda.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SERVIÇO DE APOIO AS MICRO E PEQUENAS EMPRESAS DO PARANA - SEBRAE/PR     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"75.110.585/0001-00" } )								// SEBRAE/PR - SEDE/CURITIBA
	AAdd( aCNPJ, {"75.110.585/0004-44" } )								// SEBRAE/PR - REGIONAL CASCAVEL
	AAdd( aCNPJ, {"75.110.585/0005-25" } )								// SEBRAE/PR - REGIONAL PATO BRANCO
	AAdd( aCNPJ, {"75.110.585/0003-63" } )								// SEBRAE/PR - REGIONAL LONDRINA
	AAdd( aCNPJ, {"75.110.585/0007-97" } )								// SEBRAE/PR - REGIONAL MARINGA
	AAdd( aCNPJ, {"75.110.585/0005-25" } ) 								//- PATO BRANCO          - PR  - FILIAL:04
	AAdd( aCNPJ, {"75.110.585/0015-05" } ) 								//- PONTA GROSSA         - PR  - FILIAL:11
	AAdd( aCNPJ, {"75.110.585/0016-88" } ) 								//- GUARAPUAVA           - PR  - FILIAL:12
	AAdd( aCNPJ, {"75.110.585/0011-73" } ) 								//- IVAIPORA             - PR  - FILIAL:21
	AAdd( aCNPJ, {"75.110.585/0009-59" } )								// - JACAREZINHO          - PR  - FILIAL:22
	AAdd( aCNPJ, {"75.110.585/0002-82" } )								//- APUCARANA            - PR  - FILIAL:23
	AAdd( aCNPJ, {"75.110.585/0017-69" } )								//- FOZ DO IGUACU        - PR  - FILIAL:31
	AAdd( aCNPJ, {"75.110.585/0012-54" } ) 								//FRANCISCO BELTRAO    - PR  - FILIAL:41
	AAdd( aCNPJ, {"75.110.585/0010-92" } ) 								//- PARANAVAI            - PR  - FILIAL:51
	AAdd( aCNPJ, {"75.110.585/0014-16" } ) 								//- CAMPO MOURAO         - PR  - FILIAL:52
	AAdd( aCNPJ, {"75.110.585/0013-35" } )								// - UMUARAMA             - PR  - FILIAL:53
	AAdd( aCNPJ, {"75.110.585/0018-40" } )								// - TOLEDO
	AAdd( aCNPJ, {"75.110.585/0019-20" } )								// - PARANAGUA
	
	AAdd( aCNPJ, {"76.477.546/0001-08" } )								// AFUS - ASSOC DOS FUNC DO SEBRAE/PR
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RG Pneus Ltda                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"25.567.140/0008-43" } )			
	AAdd( aCNPJ, {"25.567.140/0001-77" } )			
	AAdd( aCNPJ, {"25.567.140/0002-58" } )			
	AAdd( aCNPJ, {"25.567.140/0003-39" } )			
	AAdd( aCNPJ, {"25.567.140/0005-09" } )			
	AAdd( aCNPJ, {"25.567.140/0004-10" } )			
	AAdd( aCNPJ, {"25.567.140/0006-81" } )			
	AAdd( aCNPJ, {"25.567.140/0009-24" } )			
	
	AAdd( aCNPJ, {"67.116.400/0002-19" } )								// Serelepe Comércio Importação e Exportação Ltda.  
	
	AAdd( aCNPJ, {"04.930.480/0001-40" } )								// Axxonal Máquinas Ferragens e Ferramentas Ltda. 
	
	AAdd( aCNPJ, {"10.887.669/0002-81" } )								// Kiola Indústria e Comércio Ltda. 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Lira & Cia Ltda.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"05.936.844/0004-05" } )			
	AAdd( aCNPJ, {"05.936.844/0001-62" } )			
	AAdd( aCNPJ, {"05.936.844/0002-43" } )			
	AAdd( aCNPJ, {"05.936.844/0010-53" } )			
	AAdd( aCNPJ, {"05.936.844/0006-77" } )			
	AAdd( aCNPJ, {"05.936.844/0007-58" } )			
	                                                
	AAdd( aCNPJ, {"80.224.785/0001-15" } )			 				// Eletrotrafo Produtos Elétricos Ltda. 
	AAdd( aCNPJ, {"07.800.034/0001-00" } )							// Sudoeste – Elétrica Industrial Ltda. 
	
	AAdd( aCNPJ, {"59.385.294/0001-60" } )							// LOREN RODAS COMÉRCIO E SERVIÇOS DE RODAS LTDA.
	
	AAdd( aCNPJ, {"48.881.626/0001-12" } )							// ESKELSEN SUPER RECAP DE PNEWS COMÉRCIO E REPRESENTAÇÕES LTDA
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³OPCAO IND. E COM. DE COMPUTADORES LTDA.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"03.635.803/0004-53"  , CTOD("04/05/2012") }  )		
	AAdd( aCNPJ, {"03.635.803/0005-34"  , CTOD("10/03/2012") }  )		
	AAdd( aCNPJ, {"03.635.803/0006-15"  , CTOD("03/06/2011") }  )		
	AAdd( aCNPJ, {"03.635.803/0003-72"  , CTOD("27/05/2012") }  )		
	
	AAdd( aCNPJ, {"30-58135828-4", CTOD("10/06/2012") } )				// LO BRUNO S.A.
	
	//----------------                                                                                    
	// ALPARAMIS     |
	//----------------
	AAdd( aCNPJ, {"30-59988339-4", CTOD("13/10/2013") } )
	
	AAdd( aCNPJ, {"16.110.041/0020-33", CTOD("20/12/2009") } )			// FUND. CENT. BRAS. PROT. PESQ. DAS. TART (TAMAR)
	
	AAdd( aCNPJ, {"10.841.950/0001-00" } )								// ROTTERMAN COMERCIO, IMPORTACAO E EXPORTACAO DE MAQUINAS E EQUIPAMENTOS INDUSTRIAIS LTDA.
	
	AAdd( aCNPJ, {"09.410.360/0001-36" } )								// DISTRIBUIDORA DE FRUTAS EMPORIO DAS FRUTAS LTDA.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DUTRA MAQUINAS COMERCIAL E TECNICA LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"50.970.342/0004-55" } )								
	AAdd( aCNPJ, {"50.970.342/0001-02" } )								
	AAdd( aCNPJ, {"50.970.342/0003-74" } )	
	AAdd( aCNPJ, {"50.970.342/0006-17" } )								
	AAdd( aCNPJ, {"50.970.342/0005-36" } )	
	AAdd( aCnpj, {"50.970.342/0007-06" } ) 
								
	
	AAdd( aCNPJ, {"55.261.515/0001-37" } )								// MIHARA MATERIAIS PARA CONSTRUÇÃO LTDA
	
	AAdd( aCNPJ, {"05.534.427/0001-93" } )								// MARIA MIYUKI MIHARA ME
	
	AAdd( aCNPJ, {"03.860.151/0001-08" } )								// ELIZA MIHARA ME
	
	AAdd( aCNPJ, {"04.831.526/0001-74" } )								// TAMENOSKE MIHARA EPP
	
	AAdd( aCNPJ, {"28.807.253/0001-90" } )								// FABRICA DE TELAS SAO JORGE LTDA
	
	AAdd( aCNPJ, {"00.777.223/0002-40" } )								// TECIA MORGANA SANTANA PRESTES PEREIRA   
	
	AAdd( aCNPJ, {"25.631.151/0001-79" } )								// IPABRAC LTDA
	
	AAdd( aCNPJ, {"37.375.805/0001-20" } )								// PARAFUSOLANDIA FERRAGENS E FERRAMENTAS LTDA ME
	
	AAdd( aCNPJ, {"53.840.542/0001-39" } )								// ELASTOBOR BORRACHAS E PLASTICOS LTDA
	
	AAdd( aCNPJ, {"00.525.343/0001-70" } )								// Vitale Artes Gráficas S/A
	
	AAdd( aCNPJ, {"44.194.660/0004-79" } )								// CASA PUBLICADORA BRASILEIRA
	
	AAdd( aCNPJ, {"58.473.398/0012-16" } )								// AMWAY DO BRASIL LTDA
	
	AAdd( aCNPJ, {"54.376.462/0007-22" } )								// Silcar Pneus Ltda
	
	AAdd( aCNPJ, {"00.525.343/0001-70"}  ) 								//  VITALE ARTES GRAFICAS S/A
	
	AAdd( aCNPJ, {"16.110.041/0003-32", CTOD("17/12/2009") } )         // FUND. CENT. BRAS. PROT. PESQ. DAS. TART (TAMAR)
	   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      DRYZUN IND COM LT       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"60.306.289/0003-65" } )
	AAdd( aCNPJ, {"61.341.962/0001-07" } )
	AAdd( aCNPJ, {"60.306.289/0007-99" } )
	AAdd( aCNPJ, {"60.306.289/0004-46" } )
	AAdd( aCNPJ, {"60.306.289/0002-84" } )
	AAdd( aCNPJ, {"60.306.289/0001-01" } )
	AAdd( aCNPJ, {"60.306.289/0011-75" } )       
	   
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³MORADA CEMITERIOS LTDA EPP.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		
	AAdd( aCNPJ, {"70.028.675/0001-24" } )
	AAdd( aCNPJ, {"70.313.051/0001-59" } )
	AAdd( aCNPJ, {"06.006.272/0001-85" } )
	AAdd( aCNPJ, {"40.791.386/0001-11" } )
	AAdd( aCNPJ, {"03.246.724/0001-08" } )
	AAdd( aCNPJ, {"04.689.302/0001-70" } )
	AAdd( aCNPJ, {"10.792.676/0001-19" } )
	AAdd( aCNPJ, {"09.452.018/0001-07" } )
	AAdd( aCNPJ, {"04.811.849/0001-04" } )
	AAdd( aCNPJ, {"07.139.718/0001-02" } )
	AAdd( aCNPJ, {"08.72.6760/0001-92" } )
	AAdd( aCNPJ, {"08.968.665/0001-03" } )    
	AAdd( aCNPJ, {"12.773.805/0002-38" } )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³EXPAND GROUP BRASIL S/A.		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, {"60.652.864/0018-68" } )   //EXPAND GROUP BRASIL S/A.
	AAdd( aCNPJ, {"60.652.864/0011-91" } )
	AAdd( aCNPJ, {"60.652.864/0007-05" } )   //EXPAND GROUP BRASIL S/A.
	AAdd( aCNPJ, {"08.617.380/0020-82" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA
	AAdd( aCNPJ, {"08.617.380/0015-15" } )
	AAdd( aCNPJ, {"08.617.380/0014-34" } )
	AAdd( aCNPJ, {"08.617.380/0007-05" } )
	AAdd( aCNPJ, {"08.617.380/0004-62" } )
	AAdd( aCNPJ, {"08.617.380/0012-72" } )
	AAdd( aCNPJ, {"08.617.380/0013-53" } )
	AAdd( aCNPJ, {"08.617.380/0006-24" } )
	AAdd( aCNPJ, {"08.617.380/0008-96" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA  
	AAdd( aCNPJ, {"08.617.380/0010-00" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA 
	AAdd( aCNPJ, {"08.617.380/0021-63" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ COMPUTER STORE COMERCIO LTDA.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"83.383.950/0004-12" } )
	AAdd( aCNPJ, {"83.383.950/0001-70" } )
	AAdd( aCNPJ, {"83.383.950/0005-01" } )
	
	AAdd( aCNPJ, {"08.726.760/0002-73" } )		// PARAIBA PLANO DE ASSISTENCIA FAMILIAR LTDA 
	AAdd( aCNPJ, {"70.028.675/0003-96" } )		// MORADA CEMITERIOS LTDA EPP
	AAdd( aCNPJ, {"03.246.724/0002-99" } )    	// MULTIFAM CLINICA MEDICA LTDA EPP 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SAFRA SAO FRANCISCO ASSISTENCIA FUNERARIA LTDA EPP    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"70.373.051/0004-00" } )		
	AAdd( aCNPJ, {"70.313.051/0002-30" } )    
	AAdd( aCNPJ, {"70.313.051/0006-63" } )    
	AAdd( aCNPJ, {"70.313.051/0005-82" } )    
	AAdd( aCNPJ, {"40.791.386/0004-64" } ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Silcar Pneus Ltda.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"54.376.462/0001-37" } )    
	AAdd( aCNPJ, {"54.376.462/0003-07" } )    
	AAdd( aCNPJ, {"54.376.462/0006-41" } )    
	AAdd( aCNPJ, {"54.376.462/0011-09" } )    
	AAdd( aCNPJ, {"54.376.462/0012-90" } )    
	AAdd( aCNPJ, {"54.376.462/0013-70" } )    
	AAdd( aCNPJ, {"54.376.462/0014-51" } )    
	AAdd( aCNPJ, {"54.376.462/0015-32" } )    
	AAdd( aCNPJ, {"54.376.462/0016-13" } )    
	AAdd( aCNPJ, {"54.376.462/0019-66" } )    
	AAdd( aCNPJ, {"54.376.462/0018-85" } )    
	AAdd( aCNPJ, {"54.376.462/0020-08" } )    
	AAdd( aCNPJ, {"54.376.462/0004-80" } )    
	AAdd( aCNPJ, {"54.376.462/0021-80" } )
	AAdd( aCNPJ, {"54.376.462/0022-61" } )    
	AAdd( aCNPJ, {"54.376.462/0023-42" } )
	AAdd( aCNPJ, {"54.376.462/0025-04" } )
	AAdd( aCNPJ, {"54.376.462/0024-23" } )
	
	AAdd( aCNPJ, {"10.321.195/0001-25" } )			// Arapneus comércio Ltda.
	AAdd( aCNPJ, {"10.486.709/0001-00" } )    		// Acer Tyre Ltda.
	AAdd( aCNPJ, {"07.267.997/0001-90" } )    		// Dipbras - Distribuidora de pneus Brasil Ltda.
	AAdd( aCNPJ, {"10.495.859/0001-72" } )    		// Arapneus Goiania Comércio Ltda.
	
	AAdd( aCNPJ, {"55.963.771/0001-76" } )			//Zanotti e Zanotti Com. Refrig. Ltda.
	AAdd( aCNPJ, {"57.704.363/0001-25" } )			//Milti-Frio Com. de Refrigeração Ltda.
	
	AAdd( aCNPJ, {"01.761.367/0006-03" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0010-81" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0001-90" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0005-14" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0002-71" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0008-67" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0004-33" } )			//CONNECTION CELULARES
	AAdd( aCNPJ, {"01.761.367/0007-86" } )			//CONNECTION CELULARES
	
	AAdd( aCNPJ, {"00.727.262/0003-14", CTOD("30/04/2010") } ) 	// SWAROVSKI CRISTAIS LTDA
	AAdd( aCNPJ, {"00.727.262/0010-43", CTOD("03/07/2010") } )		// SWAROVSKI CRISTAIS LTDA   

	//-------------------------------------------------------------
	// SWAROVSKI ARGENTINA SOCIEDAD ANONIMA COMERCIAL E INDUSTRIA | 
	//-------------------------------------------------------------
	AAdd( aCNPJ, {"30-53889423-7", CTOD("19/04/2018") } )
	AAdd( aCNPJ, {"30-70929639-2", CTOD("08/03/2014") } )
	AAdd( aCNPJ, {"30-70840152-4", CTOD("06/03/2016") } )
	AAdd( aCNPJ, {"20-07368606-8", CTOD("31/12/2015") } ) 
	AAdd( aCNPJ, {"30-71214911-2", CTOD("31/12/2015") } ) 
	AAdd( aCNPJ, {"30-64084332-9", CTOD("14/03/2020") } )			// ARIMEX IMPORTADORA S.A.
	AAdd( aCNPJ, {"30-54039667-8", CTOD("17/10/2016") } )			// ARIMEX IMPORTADORA S.A.
		
	//-------------------------------------------------------------
	// SUCESORES DE DOMINGO RESTA Y CIA S A						  | 
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI              
	AAdd( aCNPJ, {"30-67608106-9", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.106/9173-74", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.105/1462-86", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.114/3083-94", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.113/9438-68", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.106/2605-01", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.116/2289-55", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.109/4674-53", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"32.054.104/5502-48", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"33.054.112/9090-95", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"33.054.106/7465-44", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"33.054.113/9047-58", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"33.054.108/5287-42", CTOD("04/10/2016") } )
	AAdd( aCNPJ, {"33.054.116/5658-20", CTOD("04/10/2016") } )
	
	//-------------------------------------------------------------
	// MACOSER S A												  |
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI              
	// Tipos de documentos liberados:
	// - Facturas A
	// - Facturas B
	AAdd( aCNPJ, {"30-59792857-9", CTOD("20/11/2015") } )
	
	//-------------------------------------------------------------
	// ALPARAMIS SOCIEDAD ANONIMA								  | 
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI              
	// Tipos de documentos liberados:
	// - Facturas A
	// - Facturas B
	// - Remito R
	AAdd( aCNPJ, {"30-59988339-4", CTOD("10/09/2015") } )          
	AAdd( aCNPJ, {"30-54039667-8", CTOD("17/11/2016") } )
	
	AAdd( aCNPJ, {"34.016.115/1036-64", CTOD("17/11/2016") } )
	
	
	AAdd( aCNPJ, {"87.133.666/0004-49" } )			// ARTMED EDITORA S/A
	
	AAdd( aCNPJ, {"87.133.666/0003-68" } )			// Razão Social: ARTMED EDITORA S A
	
	AAdd( aCNPJ, {"08.060.861/0001-77" } )			// TUDO ALEGRIA ARTIGOS DE FESTAS LTDA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ REAL NOVIDADES DISTRIBUIDORA LTDA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"07.771.731/0001-80" } )			
	AAdd( aCNPJ, {"07.771.731/0003-41" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DI FLORES ARRANJOS DECORATIVOS LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"07.553.903/0001-49" } )			
	AAdd( aCNPJ, {"07.553.903/0002-20" } )			
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ELEGANCIA DISTRIBUIDORA DE COSMETICOS LTD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"08.377.511/0006-43" } )
	AAdd( aCNPJ, {"08.377.511/0011-00" } )
	AAdd( aCNPJ, {"08.377.511/0010-20" } )
	AAdd( aCNPJ, {"08.377.511/0009-96" } )
	AAdd( aCNPJ, {"08.377.511/0008-05" } )
	AAdd( aCNPJ, {"08.377.511/0005-62" } )
	AAdd( aCNPJ, {"08.377.511/0004-81" } )
	AAdd( aCNPJ, {"08.377.511/0003-09" } )
	AAdd( aCNPJ, {"08.377.511/0002-10" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RAKE & RAI TELECOMUNICACOES LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"01.452.789/0012-37" } )
	AAdd( aCNPJ, {"01.452.789/0013-18" } )
	AAdd( aCNPJ, {"01.452.789/0015-80" } )
	
	AAdd( aCNPJ, {"60.450.665/0001-29"}  ) 								//  TRANSFORMADORES LIDER IND COM LTDA
	AAdd( aCNPJ, {"73.730.129/0001-29"}  ) 								//  BELLENZIER PNEUS LTDA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA AGROPECUARIA UNAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"25.834.847/0002-83"}  )
	AAdd( aCNPJ, {"25.834.847/0004-45"}  )
	AAdd( aCNPJ, {"25.834.847/0003-64"}  )
	AAdd( aCNPJ, {"25.834.847/0008-79"}  )
	AAdd( aCNPJ, {"25.834.847/0006-07"}  )
	AAdd( aCNPJ, {"25.834.847/0016-89"}  )
	AAdd( aCNPJ, {"25.834.847/0012-55"}  )
	AAdd( aCNPJ, {"25.834.847/0013-36"}  )
	AAdd( aCNPJ, {"25.834.847/0015-06"}  )
	AAdd( aCNPJ, {"25.834.847/0019-21"}  )          
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³IND E COM DE COLCHÕES CASTOR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"09.452.214/0001-59"}  )
	AAdd( aCNPJ, {"09.452.214/0010-40"}  )
	AAdd( aCNPJ, {"09.452.214/0014-73"}  )
	AAdd( aCNPJ, {"53.424.594/0006-39"}  )
	AAdd( aCNPJ, {"09.451.214/0003-10"}  )
	AAdd( aCNPJ, {"09.451.214/0002-30"}  )
	AAdd( aCNPJ, {"09.451.214/0021-00"}  )
	AAdd( aCNPJ, {"09.451.214/0024-45"}  )
	AAdd( aCNPJ, {"94.127.776/0003-82"}  )
	AAdd( aCNPJ, {"94.127.776/0002-00"}  )          
	AAdd( aCNPJ, {"94.127.776/0004-63"}  )
	AAdd( aCNPJ, {"09.451.214/0029-50"}  )
	AAdd( aCNPJ, {"09.451.214/0012-01"}  )
	AAdd( aCNPJ, {"09.451.214/0013-92"}  )
	AAdd( aCNPJ, {"07.227.426/0001-21"}  )
	AAdd( aCNPJ, {"07.227.426/0002-02"}  )
	AAdd( aCNPJ, {"07.227.426/0003-93"}  )
	AAdd( aCNPJ, {"09.451.214/0036-89"}  )
	AAdd( aCNPJ, {"09.451.214/0011-20"}  )
	AAdd( aCNPJ, {"07.227.426/0004-74"}  )          
	AAdd( aCNPJ, {"09.451.214/0028-79"}  )
	AAdd( aCNPJ, {"09.451.214/0008-25"}  )
	AAdd( aCNPJ, {"09.451.214/0009-06"}  )
	AAdd( aCNPJ, {"09.451.214/0007-44"}  )
	AAdd( aCNPJ, {"09.451.214/0006-63"}  )
	AAdd( aCNPJ, {"09.451.214/0004-00"}  )
	AAdd( aCNPJ, {"09.451.214/0005-82"}  )
	AAdd( aCNPJ, {"09.451.214/0034-17"}  )
	AAdd( aCNPJ, {"09.451.214/0023-64"}  )
	AAdd( aCNPJ, {"09.451.214/0035-06"}  )          
	AAdd( aCNPJ, {"09.451.214/0018-05"}  )
	AAdd( aCNPJ, {"09.451.214/0020-11"}  )
	AAdd( aCNPJ, {"09.451.214/0019-88"}  )
	AAdd( aCNPJ, {"09.451.214/0017-16"}  )
	AAdd( aCNPJ, {"09.451.214/0016-35"}  )
	AAdd( aCNPJ, {"09.451.214/0015-54"}  )
	AAdd( aCNPJ, {"09.451.214/0022-83"}  )
	AAdd( aCNPJ, {"09.451.214/0038-40"}  )
	AAdd( aCNPJ, {"09.451.214/0037-60"}  )
	AAdd( aCNPJ, {"09.451.214/0031-74"}  )          
	AAdd( aCNPJ, {"09.451.214/0030-93"}  )
	AAdd( aCNPJ, {"09.451.214/0027-98"}  )
	AAdd( aCNPJ, {"09.451.214/0032-55"}  )
	AAdd( aCNPJ, {"09.451.214/0033-36"}  )       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA CENTRAL DOS PRODUTORES RURAIS DE MINAS GERAIS LTDA.³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	AAdd( aCNPJ, {"17.249.111/0014-53"}  ) //ITAMBÉ   
	AAdd( aCNPJ, {"20.219.382/0001-56"}  ) //ITAMBE
	AAdd( aCNPJ, {"19.715.523/0001-42"}  ) //ITAMBE
	AAdd( aCNPJ, {"09.451.214/0033-36"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0003-09"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0009-96"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0010-20"}  ) //ITAMBE
	AAdd( aCNPJ, {"52.106.911/0001-00"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0028-59"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0031-54"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0032-35"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0035-88"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0052-89"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0060-99"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0061-70"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0064-12"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0068-46"}  ) //ITAMBE
	AAdd( aCNPJ, {"17.249.111/0078-18"}  ) //ITAMBE
	AAdd( aCNPJ, {"19.714.245/0001-09"}  ) //ITAMBE
	AAdd( aCNPJ, {"19.715.523/0001-42"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0001-56"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0002-37"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0004-07"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0008-22"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0009-03"}  ) //ITAMBE
	AAdd( aCNPJ, {"02.959.655/0003-89"}  ) //ITAMBE
	AAdd( aCNPJ, {"02.959.655/0002-06"}  ) //ITAMBE
	AAdd( aCNPJ, {"06.036.387/0002-01"}  ) //ITAMBE
	AAdd( aCNPJ, {"06.944.301/0001-50"}  ) //ITAMBE
	AAdd( aCNPJ, {"08.409.101/0001-22"}  ) //ITAMBE
	AAdd( aCNPJ, {"20.219.382/0004-07"}  ) //ITAMBE
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CENTRAL BORRACHAS E FERRAMENTAS LTDA          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, {"02.226.278/0002-98"}  )
	AAdd( aCNPJ, {"02.226.278/0001-07"}  )
	AAdd( aCNPJ, {"02.226.278/0006-11"}  )
	AAdd( aCNPJ, {"02.226.278/0005-30"}  )
	
	AAdd( aCNPJ, {"70.064.035/0004-12"}  )	// FLOR ARTE LTDA
	AAdd( aCNPJ, {"38.058.475/0001-01"}  )	// KRISTA TECNOLOGIA LTDA      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ação Social Claretiana				         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"60.543.279/0010-72"}  )
	AAdd( aCNPJ, {"60.543.279/0020-44"}  )
	AAdd( aCNPJ, {"60.543.279/0016-68"}  )
	AAdd( aCNPJ, {"60.543.279/0008-58"}  )
	AAdd( aCNPJ, {"60.543.279/0002-62"}  )
	AAdd( aCNPJ, {"60.543.279/0007-77"}  )
	AAdd( aCNPJ, {"60.543.279/0006-96"}  )
	AAdd( aCNPJ, {"60.543.279/0003-43"}  )    
	AAdd( aCNPJ, {"60.543.279/0028-00"}  )
	AAdd( aCNPJ, {"60.543.279/0023-97"}  )
	
	AAdd( aCNPJ, {"43.477.256/0001-05"}  )  //Livraria e Papelaria Ave Maria Ltda.
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2C Comércio e Importação de Presentes Finos Ltda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"07.654.902/0004-33" } )							
	AAdd( aCNPJ, {"07.654.902/0005-14" } )							
	AAdd( aCNPJ, {"07.654.902/0006-03" } )
	AAdd( aCNPJ, {"50.588.409/0001-49" } )
	AAdd( aCNPJ, {"50.588.409/0002-20" } )
	AAdd( aCNPJ, {"50.588.409/0003-00" } )
	AAdd( aCNPJ, { "50.588.409/0004-91"} )
	AAdd( aCNPJ, { "50.588.409/0005-72"} )
	AAdd( aCNPJ, { "50.588.409/0006-53"} )
	AAdd( aCNPJ, { "50.588.409/0007-34"} )
	AAdd( aCNPJ, { "50.588.409/0008-15"} )
	AAdd( aCNPJ, { "50.588.409/0009-04"} )
	AAdd( aCNPJ, { "50.588.409/0010-30"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RUNNER ASSESSORIA EMPRESARIAL E PARTICIP	 		³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"04.145.844/0001-81" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.734.668/0001-86" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"04.631.468/0001-35" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.949.864/0001-78" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.490/0001-91" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.481/0001-09" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.938.853/0001-92" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.702.299/0001-40" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.924.206/0001-21" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.694.436/0001-41" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.590.343/0001-77" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.827.856/0001-59" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.924.206/0001-21" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.207.704/0001-89" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.050.047/0001-09" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.265.222/0001-85" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.671.892/0001-00" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"07.443.843/0001-01" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"08.661.940/0001-33" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"05.463.763/0001-92" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"08.319.582/0001-85" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"04.839.758/0001-15" , CTOD("08/08/2010") }  )
	AAdd( aCNPJ, {"00.074.927/0001-76" , CTOD("08/08/2010") }  )
	                                   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SANTA RITA COMERCIO E INSTALAÇÕES LTDA	 		³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"86.365.350/0005-09"}  )
	AAdd( aCNPJ, {"86.365.350/0012-20"}  )
	AAdd( aCNPJ, {"86.365.350/0001-77"}  )
	AAdd( aCNPJ, {"86.365.350/0002-58"}  )
	AAdd( aCNPJ, {"86.365.350/0004-10"}  )
	AAdd( aCNPJ, {"86.365.350/0008-43"}  )
	AAdd( aCNPJ, {"86.365.350/0006-81"}  )
	AAdd( aCNPJ, {"86.365.350/0010-68"}  )
	AAdd( aCNPJ, {"86.365.350/0013-00"}  )
	AAdd( aCNPJ, {"86.365.350/0014-91"}  )
	AAdd( aCNPJ, {"86.365.350/0021-10"}  )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dimex Distribuidora IMP EXP de Produtos em Geral LTDA³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"00.431.274/0004-88" } )			
	AAdd( aCNPJ, {"09.330.604/0001-70" } )			
	AAdd( aCNPJ, {"00.431.274/0006-40" } )			
	AAdd( aCNPJ, {"05.889.784/0001-74" } )			
	AAdd( aCNPJ, {"00.431.274/0007-20" } )			
	AAdd( aCNPJ, {"00.431.274/0005-69" } )			
	AAdd( aCNPJ, {"00.431.274/0001-35" } )			
	                                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Razão Social: Euromirror indústria importação e exportação Ltda³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"00.292.513/0001-13" } )			
	AAdd( aCNPJ, {"72.770.225/0004-80" } )			
	AAdd( aCNPJ, {"72.770.225/0001-38" } )	//Razão Social: Euroquadros ind imo e exp Ltda
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Locagyn máquinas e equipamentos Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"01.570.529/0001-03" } )			
	AAdd( aCNPJ, {"01.570.529/0003-75" } )      
	AAdd( aCNPJ, {"01.570.529/0004-56" } )      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DALLAS RENT A CAR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"00.470.111/0004-04" } )			
	AAdd( aCNPJ, {"00.470.111/0006-76" } )    
	AAdd( aCNPJ, {"00.470.111/0008-38" } )			
	AAdd( aCNPJ, {"00.470.111/0009-19" } )    
	AAdd( aCNPJ, {"00.470.111/0010-52" } )			
	AAdd( aCNPJ, {"00.470.111/0011-33" } )    
	AAdd( aCNPJ, {"00.470.111/0012-14" } )			
	AAdd( aCNPJ, {"00.470.111/0014-86" } )    
	AAdd( aCNPJ, {"00.470.111/0015-67" } )			
	AAdd( aCNPJ, {"00.470.111/0017-29" } )    
	AAdd( aCNPJ, {"00.470.111/0018-00" } )			
	AAdd( aCNPJ, {"00.470.111/0019-90" } )    
	AAdd( aCNPJ, {"00.470.111/0020-24" } )			
	AAdd( aCNPJ, {"00.470.111/0023-77" } )    
	AAdd( aCNPJ, {"00.470.111/0026-10" } )			
	AAdd( aCNPJ, {"00.470.111/0027-09" } )    
	AAdd( aCNPJ, {"00.470.111/0028-81" } )
	AAdd( aCNPJ, {"00.470.111/0001-61" } )
	AAdd( aCNPJ, {"00.470.111/0003-23" } )
	AAdd( aCNPJ, {"00.470.111/0005-95" } )
	AAdd( aCNPJ, {"00.470.111/0021-05" } )
	AAdd( aCNPJ, {"00.470.111/0022-96" } )
	AAdd( aCNPJ, {"00.470.111/0032-68" } )
	AAdd( aCNPJ, {"11.453.272/0001-63" } )
	AAdd( aCNPJ, {"00.470.111/0033-49" } )
	AAdd( aCNPJ, {"00.470.111/0036-91" } ) 
	AAdd( aCNPJ, {"11.455.816/0010-17" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BRC AUTOMÓVEIS DE ALUGUEL LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"07.185.183/0002-97" } )			
	AAdd( aCNPJ, {"07.185.183/0003-78" } )    
	AAdd( aCNPJ, {"07.185.183/0004-59" } )			
	AAdd( aCNPJ, {"07.185.183/0005-30" } )    
	AAdd( aCNPJ, {"07.185.183/0007-00" } )			
	AAdd( aCNPJ, {"07.185.183/0008-82" } )    
	AAdd( aCNPJ, {"07.185.183/0009-63" } )			
	AAdd( aCNPJ, {"07.185.183/0011-88" } )     
	AAdd( aCNPJ, {"07.185.183/0006-10" } )     
	AAdd( aCNPJ, {"07.185.183/0010-05" } )     
	AAdd( aCNPJ, {"07.185.183/0001-06" } )
	                                       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SAN MARINO SERVICOS E PARTICIPACOES LTDA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"08.617.380/0017-87" } )			
	AAdd( aCNPJ, {"08.617.380/0016-04" } )          
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MACTRA COMERCIO DE CONBUSTIVEIS E LUBRIFICANTES LTDA    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"01.630.610/0001-31" } )			
	AAdd( aCNPJ, {"01.630.610/0007-27" } )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COMERCIAL E IMPORTADORA DE PNEUS LTDA  				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"61.234.985/0066-50" } )			
	AAdd( aCNPJ, {"61.234.985/0065-79" } )    
	AAdd( aCNPJ, {"61.234.985/0081-99" } )			
	AAdd( aCNPJ, {"61.234.985/0068-11" } )    
	AAdd( aCNPJ, {"61.234.985/0008-80" } )	 
	
	AAdd( aCNPJ, {"61.234.985/0001-04" } )
	AAdd( aCNPJ, {"61.234.985/0011-86" } )
	AAdd( aCNPJ, {"61.234.985/0009-61" } )
	AAdd( aCNPJ, {"61.234.985/0012-67" } )
	AAdd( aCNPJ, {"61.234.985/0014-29" } )
	AAdd( aCNPJ, {"61.234.985/0015-00" } )
	AAdd( aCNPJ, {"61.234.985/0017-71" } )
	AAdd( aCNPJ, {"61.234.985/0020-77" } )
	AAdd( aCNPJ, {"61.234.985/0022-39" } )
	AAdd( aCNPJ, {"61.234.985/0052-54" } )
	AAdd( aCNPJ, {"61.234.985/0058-40" } )
	AAdd( aCNPJ, {"61.234.985/0061-45" } )
	AAdd( aCNPJ, {"61.234.985/0063-07" } )
	AAdd( aCNPJ, {"61.234.985/0049-59" } )
	AAdd( aCNPJ, {"61.234.985/0047-97" } )
	AAdd( aCNPJ, {"61.234.985/0036-34" } )
	AAdd( aCNPJ, {"61.234.985/0007-08" } )
	AAdd( aCNPJ, {"61.234.985/0078-93" } )
	AAdd( aCNPJ, {"61.234.985/0079-74" } )
	AAdd( aCNPJ, {"61.234.985/0076-21" } )
	AAdd( aCNPJ, {"61.234.985/0075-40" } )
	AAdd( aCNPJ, {"61.234.985/0073-89" } )
	AAdd( aCNPJ, {"61.234.985/0026-62" } )
	AAdd( aCNPJ, {"61.234.985/0019-33" } )
	AAdd( aCNPJ, {"61.234.985/0027-43" } )
	AAdd( aCNPJ, {"61.234.985/0030-49" } )
	AAdd( aCNPJ, {"61.234.985/0064-98" } )
	AAdd( aCNPJ, {"61.234.985/0074-60" } )
	AAdd( aCNPJ, {"61.234.985/0033-91" } ) 		// Pneuac Comercial e Importadora LTDA   
	AAdd( aCNPJ, {"61.234.985/0071-17" } ) 
	AAdd( aCNPJ, {"61.234.985/0021-58" } )    
	AAdd( aCNPJ, {"61.234.985/0077-02" } )    
	AAdd( aCNPJ, {"61.234.985/0023-10" } )  
	AAdd( aCNPJ, {"61.234.985/0034-72" } )  
	AAdd( aCNPJ, {"61.234.985/0080-08" } )  
	AAdd( aCNPJ, {"61.234.985/0025-81" } )  
	  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³União Comércio de Peças Ltda      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"27.744.333/0008-58" } )			
	AAdd( aCNPJ, {"27.744.333/0006-96" } )    
	AAdd( aCNPJ, {"27.744.333/0002-62" } )			
	AAdd( aCNPJ, {"27.744.333/0001-81" } )    
	AAdd( aCNPJ, {"27.744.333/0003-43" } )			
	AAdd( aCNPJ, {"27.744.333/0005-05" } )    
	AAdd( aCNPJ, {"27.744.333/0007-77" } )			
	AAdd( aCNPJ, {"27.744.333/0009-39" } )    
	AAdd( aCNPJ, {"27.744.333/0010-72" } )			
	AAdd( aCNPJ, {"31.809.080/0001-54" } )
	AAdd( aCNPJ, {"08.278.101/0001-30" } )    
	AAdd( aCNPJ, {"05.669.807/0001-35" } )			
	AAdd( aCNPJ, {"06.539.997/0001-39" } )    
	AAdd( aCNPJ, {"10.909.411/0001-58" } )			
	AAdd( aCNPJ, {"05.755.026/0001-63" } )    
						                       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DISTRIBUIDORA DE PECAS AUTOMOTIVAS DB LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  					
	AAdd( aCNPJ, {"04.315.899/0002-73" } )    
	AAdd( aCNPJ, {"04.315.899/0003-54" } )			
	AAdd( aCNPJ, {"04.315.899/0001-92" } )    
	AAdd( aCNPJ, {"11.139.947/0001-02" } )			
	AAdd( aCNPJ, {"08.396.963/0001-68" } )         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ABC WINES COMERCIO DE VINHOS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"07.484.529/0001-77" } )    
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DELLA VIA DE PNEUS 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"60.957.784/0001-72" } )    
	AAdd( aCNPJ, {"60.957.784/0002-53" } )    
	AAdd( aCNPJ, {"60.957.784/0003-34" } )    
	AAdd( aCNPJ, {"60.957.784/0004-15" } )    
	AAdd( aCNPJ, {"60.957.784/0005-04" } )    
	AAdd( aCNPJ, {"60.957.784/0006-87" } )    
	AAdd( aCNPJ, {"60.957.784/0007-68" } )    
	AAdd( aCNPJ, {"60.957.784/0049-17" } )    
	AAdd( aCNPJ, {"60.957.784/0009-20" } )    
	AAdd( aCNPJ, {"60.957.784/0010-63" } )    
	AAdd( aCNPJ, {"60.957.784/0011-44" } )    
	AAdd( aCNPJ, {"60.957.784/0012-25" } )    
	AAdd( aCNPJ, {"60.957.784/0013-06" } )    
	AAdd( aCNPJ, {"60.957.784/0014-97" } )    
	AAdd( aCNPJ, {"60.957.784/0015-78" } )    
	AAdd( aCNPJ, {"60.957.784/0016-59" } )    
	AAdd( aCNPJ, {"60.957.784/0017-30" } )    
	AAdd( aCNPJ, {"60.957.784/0018-10" } )    
	AAdd( aCNPJ, {"60.957.784/0019-00" } )    
	AAdd( aCNPJ, {"60.957.784/0020-35" } )    
	AAdd( aCNPJ, {"60.957.784/0021-16" } )    
	AAdd( aCNPJ, {"60.957.784/0024-69" } )    
	AAdd( aCNPJ, {"60.957.784/0025-40" } )    
	AAdd( aCNPJ, {"60.957.784/0026-20" } )    
	AAdd( aCNPJ, {"60.957.784/0028-92" } )    
	AAdd( aCNPJ, {"60.957.784/0029-73" } )    
	AAdd( aCNPJ, {"60.957.784/0033-50" } )    
	AAdd( aCNPJ, {"60.957.784/0053-01" } )    
	AAdd( aCNPJ, {"60.957.784/0037-83" } )    
	AAdd( aCNPJ, {"60.957.784/0038-64" } )    
	AAdd( aCNPJ, {"60.957.784/0039-45" } )    
	AAdd( aCNPJ, {"60.957.784/0027-01" } )    
	AAdd( aCNPJ, {"60.957.784/0040-89" } )    
	AAdd( aCNPJ, {"60.957.784/0041-60" } )    
	AAdd( aCNPJ, {"60.957.784/0042-40" } )    
	AAdd( aCNPJ, {"60.957.784/0043-21" } )    
	AAdd( aCNPJ, {"60.957.784/0046-74" } )    
	AAdd( aCNPJ, {"60.957.784/0048-36" } )    
	AAdd( aCNPJ, {"60.957.784/0055-65" } )    
	AAdd( aCNPJ, {"60.957.784/0008-49" } )    
	AAdd( aCNPJ, {"60.957.784/0023-88" } )    
	AAdd( aCNPJ, {"60.957.784/0032-79" } )    
	AAdd( aCNPJ, {"60.957.784/0036-00" } )    
	AAdd( aCNPJ, {"60.957.784/0044-02" } )    
	AAdd( aCNPJ, {"60.957.784/0045-93" } )    
	AAdd( aCNPJ, {"60.957.784/0047-55" } )       
	AAdd( aCNPJ, {"60.957.784/0054-84" } )
	AAdd( aCNPJ, {"60.957.784/0051-31" } )
	AAdd( aCNPJ, {"60.957.784/0056-46" } )   
	AAdd( aCNPJ, {"60.957.784/0070-02" } )
	AAdd( aCNPJ, {"60.957.784/0069-60" } )  
	AAdd( aCNPJ, {"60.957.784/0064-56" } ) 
	AAdd( aCNPJ, {"60.957.784/0066-18" } ) 
	AAdd( aCNPJ, {"60.957.784/0067-07" } ) 
	AAdd( aCNPJ, {"60.957.784/0071-85" } ) 
	AAdd( aCNPJ, {"60.957.784/0072-66" } ) 
	AAdd( aCNPJ, {"60.957.784/0073-47" } )  
	AAdd( aCNPJ, {"60.957.784/0074-28" } )
	AAdd( aCNPJ, {"60.957.784/0075-09" } )
	AAdd( aCNPJ, {"60.957.784/0077-70" } )
	AAdd( aCNPJ, {"60.957.784/0080-76" } )
	AAdd( aCNPJ, {"60.957.784/0076-90" } )
	AAdd( aCNPJ, {"60.957.784/0082-38" } )
	AAdd( aCNPJ, {"60.957.784/0083-19" } )
	AAdd( aCNPJ, {"60.957.784/0085-80" } )
	AAdd( aCNPJ, {"60.957.784/0087-42" } )
	AAdd( aCNPJ, {"60.957.784/0079-32" } )
	AAdd( aCNPJ, {"60.957.784/0086-61" } )
	AAdd( aCNPJ, {"60.957.784/0068-80" } )
	AAdd( aCNPJ, {"60.957.784/0061-03" } )
	AAdd( aCNPJ, {"60.957.784/0062-94" } )
	AAdd( aCNPJ, {"60.957.784/0063-75" } )
	AAdd( aCNPJ, {"60.957.784/0091-29" } )	
	AAdd( aCNPJ, {"60.957.784/0090-48" } )		
	AAdd( aCNPJ, {"60.957.784/0088-23" } )
	AAdd( aCNPJ, {"60.957.784/0092-00" } )
	AAdd( aCNPJ, {"60.957.784/0093-90" } )
	AAdd( aCNPJ, {"60.957.784/0089-04" } )
	AAdd( aCNPJ, {"60.957.784/0094-71" } )
	
	AAdd( aCNPJ, {"05.472.446/0001-32" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0002-13" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0003-02" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0004-85" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0005-66" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0006-47" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0007-28" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJ, {"05.472.446/0008-09" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³LOCAGYN MAQUINAS E EQUIPAMENTOS LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"01.570.529/0002-94" } )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ALBRAN COMÉRCIO DE SOLDAS E FERRAGENS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"29.441.987/0001-61" } )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Centerlonas Comercial Ltda. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"72.768.179/0001-32" } )
	AAdd( aCNPJ, {"08.043.875/0001-82" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ARTMED EDITORA S A. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"87.133.666/0003-68" } )    
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA  AGROPECUARIA CENTRO SERRANA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"27.942.085/0006-98" } )    
	AAdd( aCNPJ, {"27.942.085/0014-06" } )    
	AAdd( aCNPJ, {"27.942.085/0020-46" } )    
	AAdd( aCNPJ, {"27.942.085/0005-07" } )
	AAdd( aCNPJ, {"27.942.085/0025-50" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Irmaos Marconi & Cia LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"78.357.969/0001-01" } )    
	AAdd( aCNPJ, {"02.499.799/0001-38" } )    
	AAdd( aCNPJ, {"02.481.593/0001-80" } )    
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bonanza Supermercados     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"12.023.966/0032-20" } )    
	AAdd( aCNPJ, {"12.023.966/0041-10" } )    
	AAdd( aCNPJ, {"07.649.462/0001-83" } ) 
	AAdd( aCNPJ, {"07.649.462/0002-64" } )    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³N. R. COM. DE ARTIGOS DO VESTUÁRIO E CONFECÇÕES LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"07.748.874/0001-64" } ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Importação e exportação KS Ltda. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, {"01.656.173/0001-25" } ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³NELIO DE H. BOTTI. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, {"02.175.564/0001-90" } )    // NELIO DE H. BOTTI
	AAdd( aCNPJ, {"02.175.564/0002-71" } )    // NELIO DE H. BOTTI
	AAdd( aCNPJ, {"00.504.765/0001-69" } )    // ROSANGELA G DE GOES EPP
	AAdd( aCNPJ, {"05.157.992/0001-89" } )    // NR BOTTI CONFECCOESS LTDA
	AAdd( aCNPJ, {"05.530.242/0001-00" } )    // GILDA COM. DE ART. DO VESTUARIO LTDA
	AAdd( aCNPJ, {"05.821.292/0001-47" } )    // BOTTI CAMISARIA E CONFECCOES LTDA
	AAdd( aCNPJ, {"07.308.030/0001-09" } )    // FRANCA COM. DE ARTIGOS DO VESTUARIO LTDA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ASSOCIACAO CULTURA FRANCISCANA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, {"60.806.577/0023-22" , CTOD("31/12/2010") } )         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   ETNA - UF: SP   ³ - Permissao para emitir nota fiscal na Venda Assistida (07/2010)
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJ, { "84.453.844/0057-32" } )
	AAdd( aCNPJ, { "84.453.844/0066-23" } )
	AAdd( aCNPJ, { "84.453.844/0085-96" } )
	AAdd( aCNPJ, { "84.453.844/0094-87" } )
	AAdd( aCNPJ, { "84.453.844/0093-04" } )
	AAdd( aCNPJ, { "84.453.844/0073-52" } )
	AAdd( aCNPJ, { "84.453.844/0096-49" } )
	AAdd( aCNPJ, { "84.453.844/0101-40" } )
	AAdd( aCNPJ, { "84.453.844/0082-43" } )
	AAdd( aCNPJ, { "84.453.844/0088-39" } )
	AAdd( aCNPJ, { "84.453.844/0069-76" } )
	AAdd( aCNPJ, { "84.453.844/0120-03" } )
	AAdd( aCNPJ, { "84.453.844/0119-70" } )
	AAdd( aCNPJ, { "84.453.844/0135-90" } )
	AAdd( aCNPJ, { "84.453.844/0136-70" } )
	AAdd( aCNPJ, { "84.453.844/0134-09" } )
	AAdd( aCNPJ, { "84.453.844/0096-49" } )
	AAdd( aCNPJ, { "84.453.844/0141-38" } )
	AAdd( aCNPJ, { "84.453.844/0143-08" } )
	AAdd( aCNPJ, { "84.453.844/0145-61" } )
	AAdd( aCNPJ, { "84.453.844/0147-23" } )
	AAdd( aCNPJ, { "84.453.844/0148-02" } )
	AAdd( aCNPJ, { "84.453.844/0149-03" } )
	AAdd( aCNPJ, { "84.453.844/0150-04" } )
	AAdd( aCNPJ, { "84.453.844/0151-05" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Andréa comercio de artigos de decorações ltda. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, { "09.114.155/0001-23" } )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VIAMAR VEICULOS, PECAS E SERVICOS LTDA.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJ, { "02.020.620/0001-18" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRANSBYSHOP COMERCIO DE CONFECÇÕES LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "05.299.785/0001-69"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CURINGA DOS PNEUS LTDA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "00.041.327/0053-32"} )
	AAdd( aCNPJ, {"00.041.327/0043-60" } )
	AAdd( aCNPJ, {"00.041.327/0049-56" } )
	AAdd( aCNPJ, {"00.041.327/0033-99" } )
	AAdd( aCNPJ, { "00.041.327/0036-31"} )
	AAdd( aCNPJ, { "00.041.327/0005-35"} )
	AAdd( aCNPJ, { "00.041.327/0011-83"} )
	AAdd( aCNPJ, { "00.041.327/0038-01"} )
	AAdd( aCNPJ, { "00.041.327/0032-08"} )
	AAdd( aCNPJ, { "00.041.327/0052-51"} )
	AAdd( aCNPJ, { "00.041.327/0046-03"} )
	AAdd( aCNPJ, { "00.041.327/0047-94"} )
	AAdd( aCNPJ, { "00.041.327/0048-75"} )
	AAdd( aCNPJ, { "00.041.327/0050-90"} )
	AAdd( aCNPJ, { "00.041.327/0017-79"} )
	AAdd( aCNPJ, { "00.041.327/0003-73"} )
	AAdd( aCNPJ, { "00.041.327/0008-88"} )
	AAdd( aCNPJ, { "00.041.327/0006-16"} )
	AAdd( aCNPJ, { "00.041.327/0007-05"} )
	AAdd( aCNPJ, { "00.041.327/0013-45"} )
	AAdd( aCNPJ, { "00.041.327/0015-07"} )
	AAdd( aCNPJ, { "00.041.327/0016-98"} )
	AAdd( aCNPJ, { "00.041.327/0023-17"} )
	AAdd( aCNPJ, { "00.041.327/0024-06"} )
	AAdd( aCNPJ, { "00.041.327/0031-27"} )
	AAdd( aCNPJ, { "00.041.327/0035-50"} )
	AAdd( aCNPJ, { "00.041.327/0039-84"} )
	AAdd( aCNPJ, { "00.041.327/0044-41"} )
	AAdd( aCNPJ, { "00.041.327/0018-50"} )
	AAdd( aCNPJ, { "00.041.327/0027-40"} )
	AAdd( aCNPJ, { "00.041.327/0034-70"} )
	AAdd( aCNPJ, { "00.041.327/0037-12"} )
	AAdd( aCNPJ, { "00.041.327/0010-00"} )
	AAdd( aCNPJ, { "00.041.327/0025-89"} )
	AAdd( aCNPJ, { "00.041.327/0026-60"} )
	AAdd( aCNPJ, { "00.041.327/0002-92"} )
	AAdd( aCNPJ, { "00.041.327/0030-46"} )
	AAdd( aCNPJ, { "00.041.327/0051-70"} )
	AAdd( aCNPJ, { "00.041.327/0019-30"} )
	AAdd( aCNPJ, { "00.041.327/0041-07"} )
	AAdd( aCNPJ, { "00.041.327/0021-55"} )
	AAdd( aCNPJ, { "00.041.327/0022-36"} )
	AAdd( aCNPJ, { "00.041.327/0045-22"} )
	AAdd( aCNPJ, { "00.041.327/0028-21"} )
	AAdd( aCNPJ, { "00.041.327/0029-02"} )
	AAdd( aCNPJ, { "00.041.327/0014-26"} )
	AAdd( aCNPJ, { "00.041.327/0020-74"} )
	AAdd( aCNPJ, { "00.041.327/0040-18"} )
	AAdd( aCNPJ, { "04.843.999/0003-53"} )
	AAdd( aCNPJ, { "04.843.999/0002-72"} )
	AAdd( aCNPJ, { "00.041.327/0054-13"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DRASTOSA S/A INDUSTRIAS TEXTEIS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "61.088.936/0008-87"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³JDK COMERCIO DE JOIAS LTDA      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "60.306.289/0016-80"} )
	AAdd( aCNPJ, { "60.306.289/0017-60"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MUNDO CORRIDA COMERCIO DE PRODUTOS ESPORTIVOS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "11.401.564/0001-52", CTOD("15/08/2011") } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SEMPRE CENTRAL DE VELORIOS E FUNERARIAS LTDA        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJ, { "12.773.805/0001-57"} )
	AAdd( aCNPJ, { "12.773.805/0002-38"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| PRATA FORTE COMERCIO E DISTRIBUIÇÃO LTDA |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"02.770.621/0001-80"} )
	AAdd( aCNPJ, {"02.770.621/0005-03"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Comercio de Fios e Tecidos PortFio LTDA  | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "62.326.046/0001-52" } )
	AAdd( aCNPJ, { "62.326.046/0008-29" } )
	AAdd( aCNPJ, { "62.326.046/0009-00" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| TICCOLOR VIDEO FOTO SOM LTDA			 | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "77.986.321/0001-31" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| CURINGA CAMINHOES DO DF LTDA			 | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "04.843.999/0001-91" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| DISTRIBUIDORA DE PECAS KAMPEAO LTDA		 | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "38.060.430/0001-71" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|COMERCIAL DE PNEUS ROMA LTDA				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, { "61.721.320/0001-25"} )
	AAdd( aCNPJ, { "61.721.320/0002-06"} )
	AAdd( aCNPJ, { "61.721.320/0004-78"} )
	AAdd( aCNPJ, { "61.721.320/0005-59"} )
	AAdd( aCNPJ, { "61.721.320/0009-82"} )
	AAdd( aCNPJ, { "61.721.320/0010-16"} )
	AAdd( aCNPJ, { "61.721.320/0011-05"} )
	AAdd( aCNPJ, { "61.721.320/0012-88"} )
	AAdd( aCNPJ, { "61.721.320/0013-69"} )
	AAdd( aCNPJ, { "61.721.320/0014-40"} )
	AAdd( aCNPJ, { "61.721.320/0015-20"} )
	AAdd( aCNPJ, { "61.721.320/0016-01"} )
	AAdd( aCNPJ, { "61.721.320/0017-92"} )
	AAdd( aCNPJ, { "61.721.320/0018-73"} )
	AAdd( aCNPJ, { "61.721.320/0019-54"} )
	AAdd( aCNPJ, { "61.721.320/0020-98"} )
	AAdd( aCNPJ, { "61.721.320/0021-79"} )
	AAdd( aCNPJ, { "61.721.320/0022-50"} )
	
	//SEBRAE - AL
	AAdd( aCNPJ, {"12.517.413/0001-27"} )	//UF: AL
	AAdd( aCNPJ, {"12.517.413/0002-08"} )	//UF: AL
	AAdd( aCNPJ, {"12.517.413/0003-99"} )	//UF: AL
	AAdd( aCNPJ, {"12.517.413/0004-70"} )	//UF: AL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|TERRA UTIL COMERCIO DE MAQUINAS			 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJ, {"07.144.507/0001-68" } )
	
	//UNIMED NOROESTE CAPIXABA COOPERATIVA DE TRABALHO MEDICO
	AAdd( aCNPJ, {"39.384.664.0001-37" } ) //UF: ES
	AAdd( aCNPJ, {"39.384.664.0002-18" } ) //UF: ES
	
	//ENERGY NUTRITION
	AAdd( aCNPJ, {"20.297.287/0001-70"} ) //UF: AL
	AAdd( aCNPJ, {"16.971.364/0001-59"} ) //UF: AL
	
	//BULGARI
	AAdd( aCNPJ, {"14.863.735/0001-53"} ) //UF: SP
	
	// Ormimaquinas Ltda.
	AAdd( aCNPJ, { "22.351.415/0001-42" } )
	AAdd( aCNPJ, { "17.189.341/0001-50" } )
	AAdd( aCNPJ, { "22.152.508/0001-48" } )
	
	//Schirmman
	AAdd( aCNPJ, { "88.579.701/0001-78" } )
	
	//CASA J NAKAO LTDA
	AAdd( aCNPJ, { "53.794.996/0004-63" } ) //UF: SP
	AAdd( aCNPJ, { "53.794.996/0001-10" } ) //UF: SP
	AAdd( aCNPJ, { "53.794.996/0003-82" } ) //UF: SP
	
	//AGUILERA AUTOPEÇAS LTDA - MT 
	AAdd( aCNPJ, { "37.525.771/0001-02" } )
	AAdd( aCNPJ, { "37.525.771/0002-93" } )
	AAdd( aCNPJ, { "37.525.771/0003-74" } )
	AAdd( aCNPJ, { "37.525.771/0004-55" } )
	AAdd( aCNPJ, { "37.525.771/0005-36" } )
	AAdd( aCNPJ, { "37.525.771/0006-17" } )
	AAdd( aCNPJ, { "37.525.771/0007-06" } )
	AAdd( aCNPJ, { "37.525.771/0008-89" } )
	AAdd( aCNPJ, { "37.525.771/0009-60" } )
	AAdd( aCNPJ, { "37.525.771/0010-01" } )
	AAdd( aCNPJ, { "37.525.771/0011-84" } )
	AAdd( aCNPJ, { "37.525.771/0012-65" } )
	AAdd( aCNPJ, { "37.525.771/0013-46" } )
	AAdd( aCNPJ, { "37.525.771/0014-27" } )
	AAdd( aCNPJ, { "37.525.771/0015-08" } )
	AAdd( aCNPJ, { "37.525.771/0016-99" } )
	AAdd( aCNPJ, { "37.525.771/0017-70" } )
	AAdd( aCNPJ, { "37.525.771/0018-50" } )
	AAdd( aCNPJ, { "37.525.771/0019-31" } )
	AAdd( aCNPJ, { "37.525.771/0020-75" } )
	AAdd( aCNPJ, { "37.525.771/0021-56" } )
	AAdd( aCNPJ, { "37.525.771/0022-37" } )
	AAdd( aCNPJ, { "37.525.771/0023-18" } )
	AAdd( aCNPJ, { "37.525.771/0024-07" } )
	
	AAdd( aCNPJ, { "07.270.160/0001-08" } ) //COMERCIO DE PEÇAS VERDE LUCAS LTDA - MT - FILIAL 
	AAdd( aCNPJ, { "11.615.634/0001-75" } ) //COMÉRCIO DE PEÇAS GLOBAL LTDA - MT - FILIAL
	AAdd( aCNPJ, { "13.448.434/0001-09" } ) //COMERCIO DE AUTOPEÇAS COLIDER LTDA - MT - FILIAL
	
	//AGUILERA & CIA LTDA - RO 
	AAdd( aCNPJ, { "04.115.428/0001-30" } )
	AAdd( aCNPJ, { "04.115.428/0002-11" } )
	AAdd( aCNPJ, { "04.115.428/0003-00" } )
	AAdd( aCNPJ, { "04.115.428/0004-83" } )
	AAdd( aCNPJ, { "04.115.428/0005-64" } )
	
	//SHOW DE TELHAS / LEMI IND. COM. DE COIFA
	AAdd( aCNPJ, { "06.056.395/0001-20" } )
	AAdd( aCNPJ, { "06.211.343/0001-81" } )
	AAdd( aCNPJ, { "13.312.706/0001-30" } )
	
	//AUTO POSTO BRASIL DE VOLTA REDONDA LTDA
	AAdd( aCNPJ, { "28.680.429/0001-96" } )
	AAdd( aCNPJ, { "29.058.443/0001-15" } )
	AAdd( aCNPJ, { "29.066.594/0001-15" } )
	AAdd( aCNPJ, { "04.937.593/0001-78" } )
	AAdd( aCNPJ, { "32.504.565/0001-00" } )
	AAdd( aCNPJ, { "32.511.032/0001-48" } )
	AAdd( aCNPJ, { "36.512.044/0001-48" } )
	AAdd( aCNPJ, { "00.854.639/0001-34" } )
	AAdd( aCNPJ, { "31.662.604/0001-27" } )
	AAdd( aCNPJ, { "07.794.482/0001-48" } )
	AAdd( aCNPJ, { "07.248.564/0001-97" } )
	AAdd( aCNPJ, { "10.528.476/0001-53" } )
	
	//BENVINDO STOCO
	AAdd( aCNPJ, { "35.953.892/0001-20" } ) 
	
	//FATTU DO BRASIL COMERCIO DE MATERIAIS DE COMUNICACAO VISUAL LTDA
	AAdd( aCNPJ, { "11.460.665/0001-02" } )
	AAdd( aCNPJ, { "11.460.665/0002-85" } )
	AAdd( aCNPJ, { "11.460.665/0003-66" } )
	AAdd( aCNPJ, { "11.460.665/0004-47" } )
	AAdd( aCNPJ, { "11.449.801/0001-55" } )
	
	//CD-MAX
	AAdd( aCNPJ, { "00.777.674/0008-73" } )	
	AAdd( aCNPJ, { "00.777.674/0009-54" } )	
	AAdd( aCNPJ, { "00.777.674/0002-88" } )	
	AAdd( aCNPJ, { "01.396.282/0001-50" } )	
	
	//PLASTIREAL INDUSTRIA E COMERCIO DE PLASTICOS LTDA
	AAdd( aCNPJ, { "53.234.274/0001-01" } )	
	
	//MTI EXP E REP LTDA
	AAdd( aCNPJ, { "04.326.492/0001-60" } )
	AAdd( aCNPJ, { "04.326.492/0008-37" } )
	AAdd( aCNPJ, { "04.326.492/0024-57" } )
	AAdd( aCNPJ, { "04.326.492/0006-75" } )
	
	//Comando Auto Peças Ltda.
	AAdd( aCNPJ, { "01.032.275/0001-70" } )
	AAdd( aCNPJ, { "01.032.275/0002-50" } )
	AAdd( aCNPJ, { "01.032.275/0004-12" } )
	AAdd( aCNPJ, { "01.032.275/0003-31" } )
	AAdd( aCNPJ, { "01.032.275/0005-01" } )
	AAdd( aCNPJ, { "01.032.275/0006-84" } )
	AAdd( aCNPJ, { "01.032.275/0007-65" } )
	AAdd( aCNPJ, { "01.032.275/0008-46" } )
	
	//Direção Produtos Automotivos Ltda.
	AAdd( aCNPJ, { "08.184.963/0001-02" } )
	AAdd( aCNPJ, { "08.184.963/0002-85" } )
	AAdd( aCNPJ, { "08.184.963/0003-66" } )
	
	//Distribuidora de Peças Kampeão Ltda.
	AAdd( aCNPJ, { "38.060.430/0001-71" } )
	AAdd( aCNPJ, { "38.060.430/0002-52" } )
	
	//Contagem Motor Peças
	AAdd( aCNPJ, { "02.633.281/0001-45" } )
	AAdd( aCNPJ, { "10.418.748/0001-62" } )
	AAdd( aCNPJ, { "19.446.980/0001-89" } )
	
	//Cooper Sucesso
	AAdd( aCNPJ, { "08.112.721/0003-67" } )
	
	//RICCIERI CONFECCOES LTDA
	AAdd( aCNPJ, { "75.456.764/0006-08" } )
	AAdd( aCNPJ, { "75.456.764/0007-80" } )    
	
	//TODIMO Materiais de Construção
	AAdd( aCNPJ, { "15375991" } ) //Tratado com CNPJ raiz
	
	//Moderna Auto Pecas
	AAdd( aCNPJ, { "00.679.038/0001-32" } )    
EndIf

If nMVLJLBNT > 0
	lRetorno := .T.
Else	
	/* Verifica no array de CNPJs se o CNPJ esta passado como
	parametro para a funcao esta em Regime Especial */
	nPos := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, PesqPict("SA1","A1_CGC") ) } )
	
	If nPos == 0 //Se nao encontrar considerando o CNPJ completo, tenta buscar pelo CNPJ Raiz
		nPos := Ascan( aCNPJ, { |x| x[1] == SubStr(cCNPJ,1,8) } )
	EndIf	
	
	If nPos > 0
	    If Len(aCNPJ[nPos]) == 1
		   lRetorno := .T.				//O CNPJ pode imprimir NF no varejo
		Else
		   If DTOS(dDatabase) <= DTOS(aCNPJ[nPos][2])			
		      If (aCNPJ[nPos][2] - dDatabase) < SuperGetMV("MV_LJDMNF", ,60)
			  	LJMsgLeg(LJAnalisaLeg(27, ""))
			  EndIf
			  lRetorno := .T.				
		   EndIf          	       
		EndIf
	Else
		lRetorno := .F.				//O CNPJ nao pode imprimir NF no varejo	
	Endif
EndIf	

Return lRetorno

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o	 ³LjEmiteNF ³ Autor ³ Vendas Clientes       ³ Data ³05/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se pode emitir nota fiscal 					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³LjEmiteNF(cCNPJ, lLibEmiteNF)	- Controle de uso do ECF      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCNPJ - CNPJ da empresa 									  ³±±
±±³			 ³lLibEmiteNF - Determina se esta liberado para emitir NF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Determina se pode emitir nota fiscal   	          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function LjEmiteNF( cCNPJ, lLibEmiteNF )
Local lRet          := .F.                   // Valida se pode atualizar preco
Local liConta		:= 0					 // Contador de Variavel
Local nMvLJLBNT		:= SuperGetMv("MV_LJLBNT",,0)
/* Quando a rotina de Venda Assistida for executada do modulo SIGAHSP
(Gestao Hospitalar) sempre permite a emissao de NF */
If nModulo == 51 
	Return .T.
Endif

If nMvLJLBNT == 0 .And. Len(aCNPJNF) == 0	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Brasil Telecom   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"05423963001274"}) 
	AAdd( aCNPJNF, {"05423963003722"}) 	
	AAdd( aCNPJNF, {"05423963004451"}) 		
	AAdd( aCNPJNF, {"05423963000979"}) 		
	AAdd( aCNPJNF, {"05423963000464"}) 		
	AAdd( aCNPJNF, {"05423963000383"}) 			
	AAdd( aCNPJNF, {"05423963001002"}) 				
	AAdd( aCNPJNF, {"05423963003994"}) 					
	AAdd( aCNPJNF, {"05423963003218"}) 						
	AAdd( aCNPJNF, {"05423963000707"}) 						
	AAdd( aCNPJNF, {"05423963000545"}) 							
	AAdd( aCNPJNF, {"05423963000626"}) 							
	AAdd( aCNPJNF, {"05423963001193"}) 								
	AAdd( aCNPJNF, {"05423963002912"}) 									
	AAdd( aCNPJNF, {"05423963001193"}) 										
	AAdd( aCNPJNF, {"05423963003641"}) 													
	AAdd( aCNPJNF, {"05423963003480"}) 														
	AAdd( aCNPJNF, {"05423963003560"}) 															
	AAdd( aCNPJNF, {"05423963005857"}) 																
	AAdd( aCNPJNF, {"05423963005776"}) 																
	AAdd( aCNPJNF, {"05423963005938"}) 																	
	AAdd( aCNPJNF, {"05423963004370"}) 																	
	AAdd( aCNPJNF, {"05423963000545"}) 																		
	AAdd( aCNPJNF, {"05423963008872"}) 																		
	AAdd( aCNPJNF, {"05423963006667"}) 																		
	AAdd( aCNPJNF, {"05423963008791"}) 																			
	AAdd( aCNPJNF, {"05423963006748"}) 																								
	AAdd( aCNPJNF, {"05423963006403"}) 																								
	AAdd( aCNPJNF, {"05423963007477"}) 																								
	AAdd( aCNPJNF, {"05423963007396"}) 																										
	AAdd( aCNPJNF, {"05423963007639"}) 																											
	AAdd( aCNPJNF, {"05423963006829"}) 																											
	AAdd( aCNPJNF, {"05423963009178"}) 																											
	AAdd( aCNPJNF, {"05423963006586"}) 																											
	AAdd( aCNPJNF, {"05423963009410"}) 																												
	AAdd( aCNPJNF, {"05423963008953"}) 																													
	AAdd( aCNPJNF, {"05423963009259"}) 																														
	AAdd( aCNPJNF, {"01366508000170"}) 																																
	AAdd( aCNPJNF, {"05423963009500"}) 																																	
	AAdd( aCNPJNF, {"05423963009763"})	
	AAdd( aCNPJNF, {"05423963009925"})		
	AAdd( aCNPJNF, {"05423963010508"})			
	AAdd( aCNPJNF, {"05423963011237"})				
	AAdd( aCNPJNF, {"05423963011075"})					
	AAdd( aCNPJNF, {"05423963011156"})						
	AAdd( aCNPJNF, {"05423963011741"})							
	AAdd( aCNPJNF, {"05423963011318"})								
	AAdd( aCNPJNF, {"05423963010931"})									                 
	AAdd( aCNPJNF, {"05423963004966"})								
	AAdd( aCNPJNF, {"05423963002750"})											
	AAdd( aCNPJNF, {"05423963004613"})										
	AAdd( aCNPJNF, {"05423963004702"})										
	AAdd( aCNPJNF, {"05423963004532"})										
	AAdd( aCNPJNF, {"05423963009682"})										
	AAdd( aCNPJNF, {"05423963009844"})										
	AAdd( aCNPJNF, {"05423963010001"})										
	AAdd( aCNPJNF, {"05423963010184"})										
	AAdd( aCNPJNF, {"05423963011407"})										
	AAdd( aCNPJNF, {"05423963010850"})										
	AAdd( aCNPJNF, {"05423963012128"})
	AAdd( aCNPJNF, {"05423963012551"}) 
	AAdd( aCNPJNF, {"05423963012209"}) 
	AAdd( aCNPJNF, {"05423963012470"})   
	AAdd( aCNPJNF, {"05423963012390"})   
	AAdd( aCNPJNF, {"05423963012802"})  
	AAdd( aCNPJNF, {"05423963002750"})
	AAdd( aCNPJNF, {"05423963004966"})
	AAdd( aCNPJNF, {"05423963004613"})
	AAdd( aCNPJNF, {"05423963004702"})
	AAdd( aCNPJNF, {"05423963004532"})
	AAdd( aCNPJNF, {"05423963009178"})
	AAdd( aCNPJNF, {"05423963009500"})
	AAdd( aCNPJNF, {"05423963010001"})
	AAdd( aCNPJNF, {"05423963010184"})
	AAdd( aCNPJNF, {"05423963010931"})
	AAdd( aCNPJNF, {"05423963010850"})
	AAdd( aCNPJNF, {"05423963011156"})
	AAdd( aCNPJNF, {"05423963011318"})
	AAdd( aCNPJNF, {"05423963011741"})
	AAdd( aCNPJNF, {"05423963013019"})

	//Brasemba
	AAdd( aCNPJNF, {"05408888000110", CTOD("13/07/2007")})									
	AAdd( aCNPJNF, {"06915299000190", CTOD("13/07/2007")})									
	AAdd( aCNPJNF, {"07540789000112", CTOD("13/07/2007")})									
	AAdd( aCNPJNF, {"04488624000150", CTOD("13/07/2007")})										
    
	// OrmiMaquinas
	AAdd( aCNPJNF, {"22351415000142"})
	AAdd( aCNPJNF, {"17189341000150"})
	AAdd( aCNPJNF, {"22152508000148"})

	// Netgate
	AAdd( aCNPJNF, {"01810196000142", CTOD("31/12/2007")})	  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CALPAR COMERCIO DE CALCARIO LTDA ³                      											
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	AAdd( aCNPJNF, {"95388161000100", CTOD("31/12/2007")})	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Czerkes & Farre Ltda. ME³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"64844582000175", CTOD("31/12/2010")})	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PROCESS INFORMATICA - NAO TEM DATA DE RESTRICAO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"57430894000177"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Amazonia Celular S.A³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"02340278000133"})
	AAdd( aCNPJNF, {"02340278000214"})
	AAdd( aCNPJNF, {"02340278000303"})
	AAdd( aCNPJNF, {"02340278000486"})
	AAdd( aCNPJNF, {"02340278000567"})
	AAdd( aCNPJNF, {"02340278000648"})
	AAdd( aCNPJNF, {"02340278000990"})
	AAdd( aCNPJNF, {"02340278001024"})
	AAdd( aCNPJNF, {"02340278002004"})
	AAdd( aCNPJNF, {"02340278002349"})
	AAdd( aCNPJNF, {"02340278002420"})
	AAdd( aCNPJNF, {"02340278002691"})
	AAdd( aCNPJNF, {"02340278002772"})
	AAdd( aCNPJNF, {"02340278002934"})
	AAdd( aCNPJNF, {"02340278003078"})
	AAdd( aCNPJNF, {"02340278003310"})
	AAdd( aCNPJNF, {"02340278003400"})
	AAdd( aCNPJNF, {"02340278003663"})
	AAdd( aCNPJNF, {"02340278003906"})
	AAdd( aCNPJNF, {"02340278004635"})
	AAdd( aCNPJNF, {"02340278005283"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³J Sleiman & Cia Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	AAdd( aCNPJNF, {"07216054000561"}) 		
	AAdd( aCNPJNF, {"07216054000138"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cooperativa Juriti  ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"84093137000128"}) 		
	AAdd( aCNPJNF, {"84093137000470"})
	AAdd( aCNPJNF, {"84093137000390"})

	//ÚÄÄÄÄÄÄÄÄ¿
	//³SelfShop³
	//ÀÄÄÄÄÄÄÄÄÙ

	AAdd( aCNPJNF, {"01761367000190", CTOD("01/08/2008")}) 			// Savasi
	AAdd( aCNPJNF, {"01761367000271", CTOD("01/08/2008")}) 			// BH
	AAdd( aCNPJNF, {"01761367000433", CTOD("01/08/2008")}) 			// Del Rey
	AAdd( aCNPJNF, {"01761367000514", CTOD("01/08/2008")}) 			// Parana
	AAdd( aCNPJNF, {"01761367000603", CTOD("01/08/2008")}) 			// Amazonas
	AAdd( aCNPJNF, {"01761367000786", CTOD("01/08/2008")}) 			// Big
	AAdd( aCNPJNF, {"01761367000867", CTOD("01/08/2008")}) 			// Cidade
	AAdd( aCNPJNF, {"01761367000948", CTOD("01/08/2008")}) 			// Diamon
	AAdd( aCNPJNF, {"02912819000150", CTOD("01/08/2008")}) 			// Minas
	
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³SEBRAE/AL³
	//ÀÄÄÄÄÄÄÄÄÄÙ        
	AAdd( aCNPJNF, {"12517413000127"})
	AAdd( aCNPJNF, {"12517413000208"})	//UF: AL
	AAdd( aCNPJNF, {"12517413000399"})	//UF: AL
	AAdd( aCNPJNF, {"12517413000470"})	//UF: AL	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Suasolda Comercio e Tecnologia em Soldagem Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	AAdd( aCNPJNF, {"03391468000142"})
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Naco Base Materiais de Construcao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	AAdd( aCNPJNF, {"07526625000130"}) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ARS Comércio de Parafusos e Ferragens Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	AAdd( aCNPJNF, {"57599581000147"})   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ronaldo de Lucca EPP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        	
	AAdd( aCNPJNF, {"62843917000105" } )							//Marisa de Andrade de Lucca EPP 
	AAdd( aCNPJNF, {"04268935000104" } )						  	//Porto de Areia Pedra Grande São Roque Ltda. EPP   
	AAdd( aCNPJNF, {"60322401000190" } )						   	//Ronaldo de Lucca EPP 
	AAdd( aCNPJNF, {"03237058000141" } )							//Mineração e Transportes de Ar eia Limoeiro Ltda.
	
	AAdd( aCNPJNF, {"25567140000924" } )							// RG PNEUS LTDA.
	AAdd( aCNPJNF, {"24333411000400" } ) 							// SCALON & CERCHI LTDA. 
	AAdd( aCNPJNF, {"08257993000193", CTOD("31/12/2009") })			// Otica da Biblia com. de Artigo Opticos ltda.
	
	AAdd( aCNPJNF, {"61080370000766" } )							// Editora Atlas S.A.
	AAdd( aCNPJNF, {"61080370000170" } )							// Editora Atlas S.A.         
	AAdd( aCNPJNF, {"61080370000332" } )							// Editora Atlas S.A.         	
	AAdd( aCNPJNF, {"61080370000502" } )							// Editora Atlas S.A.         		
	AAdd( aCNPJNF, {"61080370000685" } )							// Editora Atlas S.A.         			
	AAdd( aCNPJNF, {"61080370000847" } )							// Editora Atlas S.A.         				
    AAdd( aCNPJNF, {"61080370001304" } )							// Editora Atlas S.A.         					
    AAdd( aCNPJNF, {"61080370001495" } )							// Editora Atlas S.A.         					    
	AAdd( aCNPJNF, {"61080370001576" } )							// Editora Atlas S.A. 
	
	AAdd( aCNPJNF, {"10322994000116" } )							// Comercial PowerField Ltda. 
	AAdd( aCNPJNF, {"04835476000101" } )							// Imprensa Oficial do Estado.
	
	AAdd( aCNPJNF, {"44137974000197" } )							// Madeiras Morumbi Ltda. 
	AAdd( aCNPJNF, {"44137974000510" } )							// Madeiras Morumbi Ltda. 
	AAdd( aCNPJNF, {"61546131000910" } )							// Compensados Lane Ltda.
	AAdd( aCNPJNF, {"61546131000678" } )							// Compensados Lane Ltda.	
	AAdd( aCNPJNF, {"61546131000597" } )							// Compensados Lane Ltda.	
	AAdd( aCNPJNF, {"61546131000163" } )							// Compensados Lane Ltda.	
	AAdd( aCNPJNF, {"61546131000325" } )							// Compensados Lane Ltda.	
	AAdd( aCNPJNF, {"61546131001054"})								// COMPENSADOS LANE LTDA.

	AAdd( aCNPJNF, {"07749164000165" } )							// Otica Gospel Aldeota Ltda ME
	AAdd( aCNPJNF, {"06049768000136" } )							// Otica Face de Cristo ME
	AAdd( aCNPJNF, {"03963213000107" } )							// Otica dos Evangelhos Ltda. ME
	AAdd( aCNPJNF, {"04003534000122" } )							// Otica Caldas Ltda. ME
	AAdd( aCNPJNF, {"04234693000138" } )							// Otica Evangelista Ltda. ME
	AAdd( aCNPJNF, {"03963213000298" } )							// Otica dos Evangélicos Ltda. ME
	AAdd( aCNPJNF, {"10188315000168" } )							// Otica Cristã Comércio de Artigos Ópticos Ltda. ME
	
	AAdd( aCNPJNF, {"42161687000197" } )							// Fundação Escola Nacional de Seguros 
	
	AAdd( aCNPJNF, {"08855562000129" } )							// Lojas SPM Moveis Ltda.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Issam Importacao e Exportacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	AAdd( aCNPJNF, {"00327385000104"})
	AAdd( aCNPJNF, {"00327385000287"})	
	AAdd( aCNPJNF, {"00327385000368"})	
	AAdd( aCNPJNF, {"00327385000520"})	
	AAdd( aCNPJNF, {"00327385000600"})	
	AAdd( aCNPJNF, {"00327385000791"})			
	AAdd( aCNPJNF, {"00327385000953"})				
	
	AAdd( aCNPJNF, {"61546131001135"})								// Compensados Lane Ltda.

	AAdd( aCNPJNF, {"04003534000203"})								// Otica Caldas Ltda. ME

	AAdd( aCNPJNF, {"00963257000653"})								// GUAIAPÓ ELETRODOMESTICOS LTDA
		
	AAdd( aCNPJNF, {"47532825000110"})								// Robert Rammert & Cia Ltda

	AAdd( aCNPJNF, {"38058475000101"})								//	KRISTA TECNOLOGIA LTDA
	
    //------------------------------------------------------------------
    //SEBRAE - Servico de Apoio as Micro e Pequenas Empresa do Parana  |
    //------------------------------------------------------------------
	AAdd( aCNPJNF, {"75110585000100"})								//	SEBRAE/PR - SEDE/CURITIBA        	
	AAdd( aCNPJNF, {"75110585000444"})								//	SEBRAE/PR - REGIONAL CASCAVEL	
	AAdd( aCNPJNF, {"75110585000525"})								//	SEBRAE/PR - REGIONAL PATO BRANCO	
	AAdd( aCNPJNF, {"75110585000363"})								//	SEBRAE/PR - REGIONAL LONDRINA	
	AAdd( aCNPJNF, {"75110585000797"})								//	SEBRAE/PR - REGIONAL MARINGA
	AAdd( aCNPJNF, {"75110585000797"})								//	SEBRAE/PR - REGIONAL MARINGA  
	AAdd( aCNPJNF, {"75110585001505"}) 								//- PONTA GROSSA         - PR  - FILIAL:11
	AAdd( aCNPJNF, {"75110585001688"}) 								//- GUARAPUAVA           - PR  - FILIAL:12
	AAdd( aCNPJNF, {"75110585001173"}) 								//- IVAIPORA             - PR  - FILIAL:21
	AAdd( aCNPJNF, {"75110585000959"})								// - JACAREZINHO          - PR  - FILIAL:22
	AAdd( aCNPJNF, {"75110585000282"})								//- APUCARANA            - PR  - FILIAL:23
	AAdd( aCNPJNF, {"75110585001769"})								//- FOZ DO IGUACU        - PR  - FILIAL:31
	AAdd( aCNPJNF, {"75110585001254"}) 								//FRANCISCO BELTRAO    - PR  - FILIAL:41
	AAdd( aCNPJNF, {"75110585001092"}) 								//- PARANAVAI            - PR  - FILIAL:51
	AAdd( aCNPJNF, {"75110585001416"}) 								//- CAMPO MOURAO         - PR  - FILIAL:52
	AAdd( aCNPJNF, {"75110585001335"})								// - UMUARAMA             - PR  - FILIAL:53	
	AAdd( aCNPJNF, {"75110585001840"})								// - TOLEDO
	AAdd( aCNPJNF, {"75110585001920"})								// - PARANAGUA
	
	AAdd( aCNPJNF, {"76477546000108"})								//	AFUS - ASSOC DOS FUNC DO SEBRAE/PR
	
	
	AAdd( aCNPJNF, {"64776727000148"})								//	Paola do Verona Produtos Alimentícios Ltda. EPP

	AAdd( aCNPJNF, {"25567140000681"})								//	RG Pneus Ltda. 
	
	AAdd( aCNPJNF, {"25567140000924"})								//	RG Pneus Ltda. 

	AAdd( aCNPJNF, {"34241067000130"})								// Foxtrot Comércio Importação e Exportação Ltda. 

	AAdd( aCNPJNF, {"59385294000160"})								// LOREN RODAS COMÉRCIO E SERVIÇOS DE RODAS LTDA.

	AAdd( aCNPJNF, {"48881626000112"})								// ESKELSEN SUPER RECAP DE PNEWS COMÉRCIO E REPRESENTAÇÕES LTDA

	AAdd( aCNPJNF, {"30581358284", CTOD("10/06/2012") } )			// LO BRUNO S.A.
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| ALPARAMIS        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"30599883394", CTOD("11/08/2017") } )
	
	AAdd( aCNPJNF, {"16110041002033", CTOD("20/12/2009") } )		// FUND. CENT. BRAS. PROT. PESQ. DAS. TART (TAMAR)

	AAdd( aCNPJNF, {"54376462000722"})								// Silcar Pneus Ltda

	AAdd( aCNPJNF, {"48551626000112"})								// Eskelsen Super Recap Pneus Comercio e Representacao Ltda
	
	AAdd( aCNPJNF, {"00525343000170"}) 								// VITALE ARTES GRAFICAS S/A
   
    AAdd( aCNPJNF, {"16110041000332", CTOD("17/12/2009") } )       // FUND. CENT. BRAS. PROT. PESQ. DAS. TART (TAMAR)
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MORADA CEMITERIOS LTDA EPP.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	
	AAdd( aCNPJNF, {"70028675000124" } )
	AAdd( aCNPJNF, {"70313051000159" } )
	AAdd( aCNPJNF, {"06006272000185" } )
	AAdd( aCNPJNF, {"40791386000111" } )
	AAdd( aCNPJNF, {"03246724000108" } )
	AAdd( aCNPJNF, {"04689302000170" } )
	AAdd( aCNPJNF, {"10792676000119" } )
	AAdd( aCNPJNF, {"09452018000107" } )
	AAdd( aCNPJNF, {"04811849000104" } )
	AAdd( aCNPJNF, {"07139718000102" } )
	AAdd( aCNPJNF, {"08726760000192" } ) 
	AAdd( aCNPJNF, {"08968665000103" } )    
	AAdd( aCNPJNF, {"12773805000408" } ) 
	

	AAdd( aCNPJNF, {"08726760000273" } )		// PARAIBA PLANO DE ASSISTENCIA FAMILIAR LTDA 
	AAdd( aCNPJNF, {"70028675000396" } )		// MORADA CEMITERIOS LTDA EPP
	AAdd( aCNPJNF, {"03246724000299" } )    	// MULTIFAM CLINICA MEDICA LTDA EPP 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SAFRA SAO FRANCISCO ASSISTENCIA FUNERARIA LTDA EPP    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"70373051000400" } )		
	AAdd( aCNPJNF, {"70313051000230" } )    
	AAdd( aCNPJNF, {"70313051000663" } )    
	AAdd( aCNPJNF, {"70313051000582" } )    
	AAdd( aCNPJNF, {"40791386000464" } ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Silcar Pneus Ltda.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"54376462000137" } )    
	AAdd( aCNPJNF, {"54376462000307" } )    
	AAdd( aCNPJNF, {"54376462000641" } )    
	AAdd( aCNPJNF, {"54376462001109" } )    
	AAdd( aCNPJNF, {"54376462001290" } )    
	AAdd( aCNPJNF, {"54376462001370" } )    
	AAdd( aCNPJNF, {"54376462001451" } )    
	AAdd( aCNPJNF, {"54376462001532" } )    
	AAdd( aCNPJNF, {"54376462001613" } )    
	AAdd( aCNPJNF, {"54376462001966" } )    
	AAdd( aCNPJNF, {"54376462001885" } )    
	AAdd( aCNPJNF, {"54376462002008" } )    
	AAdd( aCNPJNF, {"54376462000480" } )    
	AAdd( aCNPJNF, {"54376462002180" } )    
	AAdd( aCNPJNF, {"54376462002261" } )    
	AAdd( aCNPJNF, {"54376462002342" } )  
	AAdd( aCNPJNF, {"54376462002504" } )
	AAdd( aCNPJNF, {"54376462002423" } )

	AAdd( aCNPJNF, {"10321195000125" } )			// Arapneus comércio Ltda.
	AAdd( aCNPJNF, {"10486709000100" } )    		// Acer Tyre Ltda.
	AAdd( aCNPJNF, {"07267997000190" } )    		// Dipbras - Distribuidora de pneus Brasil Ltda.
	AAdd( aCNPJNF, {"10495859000172" } )    		// Arapneus Goiania Comércio Ltda.	
	AAdd( aCNPJNF, {"55963771000176" } )			//Zanotti e Zanotti Com. Refrig. Ltda.  
	AAdd( aCNPJNF, {"57704363000125" } )			//Milti-Frio Com. de Refrigeração Ltda. 	
	
	AAdd( aCNPJNF, {"00727262000314" , CTOD("01/04/2010") } )			// SWAROVSKI CRISTAIS LTDA

    //-------------------------------------------------------------
	// SWAROVSKI ARGENTINA SOCIEDAD ANONIMA COMERCIAL E INDUSTRIA |
	//-------------------------------------------------------------
	AAdd( aCNPJNF, {"30538894237", CTOD("13/06/2018") } )
	AAdd( aCNPJNF, {"30709296392", CTOD("08/03/2014") } )
	AAdd( aCNPJNF, {"30708401524", CTOD("06/03/2016") } )
	AAdd( aCNPJNF, {"20073686068", CTOD("31/12/2015") } )
	AAdd( aCNPJNF, {"30712149112", CTOD("31/12/2015") } )

	//-------------------------------------------------------------
	// SUCESORES DE DOMINGO RESTA Y CIA S A						  | 
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI
	AAdd( aCNPJNF, {"30676081069"	, CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054106917374", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054105146286", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054114308394", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054113943868", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054106260501", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054116228955", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054109467453", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"32054104550248", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"33054112909095", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"33054106746544", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"33054113904758", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"33054108528742", CTOD("04/10/2016") } )
	AAdd( aCNPJNF, {"33054116565820", CTOD("04/10/2016") } )
	
	//-------------------------------------------------------------
	// MACOSER S A												  |
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI
	// - Facturas A
	// - Facturas B
	AAdd( aCNPJNF, {"30597928579"	, CTOD("20/11/2015") } )
	
	//-------------------------------------------------------------
	// ALPARAMIS SOCIEDAD ANONIMA								  | 
	//-------------------------------------------------------------
	// Autorizacao AFIP/CAI              
	// Tipos de documentos liberados:
	// Facturas A
	// Facturas B
	// Remito R
	AAdd( aCNPJNF, {"30599883394"	 , CTOD("11/08/2017") } )	   	
    AAdd( aCNPJNF, {"30537280456"	 , CTOD("18/03/2012") } )  			// EDITORIAL SIGMAR SA COMERCIAL
	AAdd( aCNPJNF, {"30640843329"	 , CTOD("14/03/2020") } )	    	// ARIMEX IMPORTADORA S.A.
	AAdd( aCNPJNF, {"30540396678"	 , CTOD("29/01/2019") } )	    	// ARIMEX IMPORTADORA S.A.
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³EXPAND GROUP BRASIL S/A.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, {"60652864001868" } )   //EXPAND GROUP BRASIL S/A.
	AAdd( aCNPJNF, {"60652864001191" } )
	AAdd( aCNPJNF, {"60652864000705" } )   //EXPAND GROUP BRASIL S/A.
	AAdd( aCNPJNF, {"08617380002082" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA
	AAdd( aCNPJNF, {"08617380001515" } )
	AAdd( aCNPJNF, {"08617380001434" } )
	AAdd( aCNPJNF, {"08617380000705" } )
	AAdd( aCNPJNF, {"08617380000462" } )
	AAdd( aCNPJNF, {"08617380001272" } )
	AAdd( aCNPJNF, {"08617380001353" } )
	AAdd( aCNPJNF, {"08617380000624" } )
	AAdd( aCNPJNF, {"08617380000896" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA
	AAdd( aCNPJNF, {"08617380001000" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA 
    AAdd( aCNPJNF, {"08617380002163" } )   //NEW WINE DISTRIBUIDORA DE BEBIDAS LTDA 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA AGROPECUARIA UNAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"25834847000283" } )
	AAdd( aCNPJNF, {"25834847000445" } )
	AAdd( aCNPJNF, {"25834847000364" } )
	AAdd( aCNPJNF, {"25834847000879" } )
	AAdd( aCNPJNF, {"25834847000607" } )
	AAdd( aCNPJNF, {"25834847001689" } )
	AAdd( aCNPJNF, {"25834847001255" } )
	AAdd( aCNPJNF, {"25834847001336" } )
	AAdd( aCNPJNF, {"25834847001506" } )
	AAdd( aCNPJNF, {"25834847001921" } )
	
	AAdd( aCNPJNF, {"07771731000180" } )	//REAL NOVIDADES DISTRIBUIDORA LTDA 
	AAdd( aCNPJNF, {"07771731000341" } )    //REAL NOVIDADES DISTRIBUIDORA LTDA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RUNNER ASSESSORIA EMPRESARIAL E PARTICIP	 		³					
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"04145844000181" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05734668000186" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"04631468000135" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05949864000178" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05702490000191" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05702481000109" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05938853000192" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05702299000140" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05924206000121" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05694436000141" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05590343000177" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05827856000159" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05924206000121" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"07207704000189" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"07050047000109" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"07265222000185" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"07671892000100" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"07443843000101" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"08661940000133" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"05463763000192" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"08319582000185" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"04839758000115" , CTOD("08/08/2010") }  )
	AAdd( aCNPJNF, {"00074927000176" , CTOD("08/08/2010") }  )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Locagyn máquinas e equipamentos Ltda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"01570529000103" } )			
	AAdd( aCNPJNF, {"01570529000375" } )	    
	AAdd( aCNPJNF, {"01570529000456" } )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DALLAS RENT A CAR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"00470111000404" } )			
	AAdd( aCNPJNF, {"00470111000676" } )    
	AAdd( aCNPJNF, {"00470111000838" } )			
	AAdd( aCNPJNF, {"00470111000919" } )    
	AAdd( aCNPJNF, {"00470111001052" } )			
	AAdd( aCNPJNF, {"00470111001133" } )    
	AAdd( aCNPJNF, {"00470111001214" } )			
	AAdd( aCNPJNF, {"00470111001486" } )    
	AAdd( aCNPJNF, {"00470111001567" } )			
	AAdd( aCNPJNF, {"00470111001729" } )    
	AAdd( aCNPJNF, {"00470111001800" } )			
	AAdd( aCNPJNF, {"00470111001990" } )    
	AAdd( aCNPJNF, {"00470111002024" } )			
	AAdd( aCNPJNF, {"00470111002377" } )    
	AAdd( aCNPJNF, {"00470111002610" } )			
	AAdd( aCNPJNF, {"00470111002709" } )    
	AAdd( aCNPJNF, {"00470111002881" } )
	AAdd( aCNPJNF, {"00470111000161" } )
	AAdd( aCNPJNF, {"00470111000323" } )
	AAdd( aCNPJNF, {"00470111000595" } )
	AAdd( aCNPJNF, {"00470111002105" } )
	AAdd( aCNPJNF, {"00470111002296" } )
	AAdd( aCNPJNF, {"00470111003268" } )
	AAdd( aCNPJNF, {"11453272000163" } )
	AAdd( aCNPJNF, {"00470111003349" } )
	AAdd( aCNPJNF, {"00470111003691" } )
	AAdd( aCNPJNF, {"11455816001017" } )	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BRC AUTOMÓVEIS DE ALUGUEL LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"07185183000297" } )			
	AAdd( aCNPJNF, {"07185183000378" } )    
	AAdd( aCNPJNF, {"07185183000459" } )			
	AAdd( aCNPJNF, {"07185183000530" } )    
	AAdd( aCNPJNF, {"07185183000700" } )			
	AAdd( aCNPJNF, {"07185183000882" } )    
	AAdd( aCNPJNF, {"07185183000963" } )			
	AAdd( aCNPJNF, {"07185183001188" } )     
	AAdd( aCNPJNF, {"07185183000610" } )     
	AAdd( aCNPJNF, {"07185183001005" } )     
	AAdd( aCNPJNF, {"07185183000106" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MACTRA COMERCIO DE CONBUSTIVEIS E LUBRIFICANTES LTDA    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJNF, {"01630610000131" } )			
	AAdd( aCNPJNF, {"01630610000727" } )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³STADTBUS TRANSPORTES LTDA.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	AAdd( aCNPJNF, {"93273860000180" } )      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SAN MARINO SERVICOS E PARTICIPACOES LTDA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"08617380001787" } )			
	AAdd( aCNPJNF, {"08617380001604" } )  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DISTRIBUIDORA DE PECAS AUTOMOTIVAS DB LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  					
	AAdd( aCNPJNF, {"04315899000273" } )    
	AAdd( aCNPJNF, {"04315899000354" } )			
	AAdd( aCNPJNF, {"04315899000192" } )    
	AAdd( aCNPJNF, {"11139947000102" } )			
	AAdd( aCNPJNF, {"08396963000168" } )   
	
	AAdd( aCNPJNF, {"56354897000106" } ) 		// Barrela Pneus Ltda.    	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Della Via	    	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"60957784000172" } )    
	AAdd( aCNPJNF, {"60957784000253" } )    
	AAdd( aCNPJNF, {"60957784000334" } )    
	AAdd( aCNPJNF, {"60957784000415" } )    
	AAdd( aCNPJNF, {"60957784000504" } )    
	AAdd( aCNPJNF, {"60957784000687" } )    
	AAdd( aCNPJNF, {"60957784000768" } )    
	AAdd( aCNPJNF, {"60957784004917" } )    
	AAdd( aCNPJNF, {"60957784000920" } )    
	AAdd( aCNPJNF, {"60957784001063" } )    
	AAdd( aCNPJNF, {"60957784001144" } )    
	AAdd( aCNPJNF, {"60957784001225" } )    
	AAdd( aCNPJNF, {"60957784001306" } )    
	AAdd( aCNPJNF, {"60957784001497" } )    
	AAdd( aCNPJNF, {"60957784001578" } )    
	AAdd( aCNPJNF, {"60957784001659" } )    
	AAdd( aCNPJNF, {"60957784001730" } )    
	AAdd( aCNPJNF, {"60957784001810" } )    
	AAdd( aCNPJNF, {"60957784001900" } )    
	AAdd( aCNPJNF, {"60957784002035" } )    
	AAdd( aCNPJNF, {"60957784002116" } )    
	AAdd( aCNPJNF, {"60957784002469" } )    
	AAdd( aCNPJNF, {"60957784002540" } )    
	AAdd( aCNPJNF, {"60957784002620" } )    
	AAdd( aCNPJNF, {"60957784002892" } )    
	AAdd( aCNPJNF, {"60957784002973" } )    
	AAdd( aCNPJNF, {"60957784003350" } )    
	AAdd( aCNPJNF, {"60957784005301" } )    
	AAdd( aCNPJNF, {"60957784003783" } )    
	AAdd( aCNPJNF, {"60957784003864" } )    
	AAdd( aCNPJNF, {"60957784003945" } )    
	AAdd( aCNPJNF, {"60957784002701" } )    
	AAdd( aCNPJNF, {"60957784004089" } )    
	AAdd( aCNPJNF, {"60957784004160" } )    
	AAdd( aCNPJNF, {"60957784004240" } )    
	AAdd( aCNPJNF, {"60957784004321" } )    
	AAdd( aCNPJNF, {"60957784004674" } )    
	AAdd( aCNPJNF, {"60957784004836" } )    
	AAdd( aCNPJNF, {"60957784005565" } )    
	AAdd( aCNPJNF, {"60957784000849" } )    
	AAdd( aCNPJNF, {"60957784002388" } )    
	AAdd( aCNPJNF, {"60957784003279" } )    
	AAdd( aCNPJNF, {"60957784003600" } )    
	AAdd( aCNPJNF, {"60957784004402" } )    
	AAdd( aCNPJNF, {"60957784004593" } )    
	AAdd( aCNPJNF, {"60957784004755" } )    
	AAdd( aCNPJNF, {"60957784005484" } ) 
	AAdd( aCNPJNF, {"60957784005131" } )
	AAdd( aCNPJNF, {"60957784005646" } )  
	AAdd( aCNPJNF, {"60957784007002" } )
	AAdd( aCNPJNF, {"60957784006960" } )
	AAdd( aCNPJNF, {"60957784006456" } )
	AAdd( aCNPJNF, {"60957784006618" } )
	AAdd( aCNPJNF, {"60957784006707" } )		
	AAdd( aCNPJNF, {"60957784007185" } )		
	AAdd( aCNPJNF, {"60957784007266" } )		
	AAdd( aCNPJNF, {"60957784007347" } )
	AAdd( aCNPJNF, {"60957784007428" } )
	AAdd( aCNPJNF, {"60957784008076" } )	
	AAdd( aCNPJNF, {"60957784007690" } ) 
	AAdd( aCNPJNF, {"60957784008238" } ) 	
	AAdd( aCNPJNF, {"60957784008319" } )
	AAdd( aCNPJNF, {"60957784008580" } )
	AAdd( aCNPJNF, {"60957784008742" } )	
	AAdd( aCNPJNF, {"60957784009129" } )	
	AAdd( aCNPJNF, {"60957784009048" } )		
	AAdd( aCNPJNF, {"60957784008823" } )
	Aadd( aCNPJNF, {"60957784008661" } )
	Aadd( aCNPJNF, {"60957784006103" } )
	AAdd( aCNPJNF, {"60957784009200" } )
	AAdd( aCNPJNF, {"60957784009390" } )
	AAdd( aCNPJNF, {"60957784008904" } )
	AAdd( aCNPJNF, {"60957784009471" } )
	
	AAdd( aCNPJNF, {"05472446000132" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000213" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000302" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000485" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000566" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000647" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000728" } ) //DACOSTA COMERCIO DE PNEUS LTDA
	AAdd( aCNPJNF, {"05472446000809" } ) //DACOSTA COMERCIO DE PNEUS LTDA   

	//Santa Rita
	AAdd( aCNPJNF, {"86365350000509"} )
	AAdd( aCNPJNF, {"86365350001220"} )
	AAdd( aCNPJNF, {"86365350000177"} )
	AAdd( aCNPJNF, {"86365350000258"} )
	AAdd( aCNPJNF, {"86365350000410"} )
	AAdd( aCNPJNF, {"86365350000843"} )
	AAdd( aCNPJNF, {"86365350000681"} )
	AAdd( aCNPJNF, {"86365350001068"} )
	AAdd( aCNPJNF, {"86365350001300"} )
	AAdd( aCNPJNF, {"86365350001491"} )
	AAdd( aCNPJNF, {"86365350002110"} )
		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³LOCAGYN MAQUINAS E EQUIPAMENTOS LTDA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCNPJNF, {"01570529000294" } )   
                                                

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA  AGROPECUARIA CENTRO SERRANA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"27942085000698" } )    
	AAdd( aCNPJNF, {"27942085001406" } )    
	AAdd( aCNPJNF, {"27942085002046" } )
	AAdd( aCNPJNF, {"27942085002550" } )	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SWAROVSKI CRISTAIS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"00727262001043" , CTOD("03/07/2010") } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GUAIAPO ELETRODOMESTICOS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCNPJNF, {"00963257001382" , CTOD("05/01/2011") } )	
	AAdd( aCNPJNF, {"56354897000378" } )                      // BARRELA RECAUCHUTAGEM DE PNEUS LTDA     	
	AAdd( aCNPJNF, {"00963257000149" } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ASSOCIACAO CULTURA FRANCISCANA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, {"60806577002322" , CTOD("31/12/2010") } )		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CURINGA DOS PNEUS LTDA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, {"00041327005332"} ) 
	AAdd( aCNPJNF, {"00041327004360"} )
	AAdd( aCNPJNF, {"00041327004956"} )
	AAdd( aCNPJNF, {"00041327003399"} )
	AAdd( aCNPJNF, {"00041327003631"} )
	AAdd( aCNPJNF, {"00041327000535"} )
    AAdd( aCNPJNF, {"00041327001183"} )
    AAdd( aCNPJNF, {"00041327003801"} )
    AAdd( aCNPJNF, {"00041327003208"} )
    AAdd( aCNPJNF, {"00041327005251"} )
    AAdd( aCNPJNF, {"00041327004603"} )
    AAdd( aCNPJNF, {"00041327004794"} )
    AAdd( aCNPJNF, {"00041327004875"} )
    AAdd( aCNPJNF, {"00041327005090"} )
    AAdd( aCNPJNF, {"00041327001779"} )
    AAdd( aCNPJNF, {"00041327000373"} )
    AAdd( aCNPJNF, {"00041327000888"} )
    AAdd( aCNPJNF, {"00041327000616"} )
    AAdd( aCNPJNF, {"00041327000705"} )
    AAdd( aCNPJNF, {"00041327001345"} )
    AAdd( aCNPJNF, {"00041327001507"} )
    AAdd( aCNPJNF, {"00041327001698"} )
    AAdd( aCNPJNF, {"00041327002317"} )
    AAdd( aCNPJNF, {"00041327002406"} )
    AAdd( aCNPJNF, {"00041327003127"} )
    AAdd( aCNPJNF, {"00041327003550"} )
    AAdd( aCNPJNF, {"00041327003984"} )
    AAdd( aCNPJNF, {"00041327004441"} )
    AAdd( aCNPJNF, {"00041327001850"} )
    AAdd( aCNPJNF, {"00041327002740"} )
    AAdd( aCNPJNF, {"00041327003470"} )
    AAdd( aCNPJNF, {"00041327003712"} )
    AAdd( aCNPJNF, {"00041327001000"} )
    AAdd( aCNPJNF, {"00041327002589"} )
    AAdd( aCNPJNF, {"00041327002660"} )
    AAdd( aCNPJNF, {"00041327000292"} )
    AAdd( aCNPJNF, {"00041327003046"} )
    AAdd( aCNPJNF, {"00041327005170"} )
    AAdd( aCNPJNF, {"00041327001930"} )
    AAdd( aCNPJNF, {"00041327004107"} )
    AAdd( aCNPJNF, {"00041327002155"} )
    AAdd( aCNPJNF, {"00041327002236"} )
    AAdd( aCNPJNF, {"00041327004522"} )
    AAdd( aCNPJNF, {"00041327002821"} )
    AAdd( aCNPJNF, {"00041327002902"} )
    AAdd( aCNPJNF, {"00041327001426"} )
    AAdd( aCNPJNF, {"00041327002074"} )
    AAdd( aCNPJNF, {"00041327004018"} )
	AAdd( aCNPJNF, {"04843999000191"} )
	AAdd( aCNPJNF, {"04843999000353"} )
	AAdd( aCNPJNF, {"04843999000272"} )            
	AAdd( aCNPJNF, {"00041327005413"} )            	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DRASTOSA S/A INDUSTRIAS TEXTEIS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, { "61088936000887"} )		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³JDK COMERCIO DE JOIAS LTDA    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, { "60306289001680"} )
	AAdd( aCNPJNF, { "60306289001760"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MUNDO CORRIDA COMERCIO DE PRODUTOS ESPORTIVOS LTDA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, { "11401564000152", CTOD("15/08/2011") } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GUAPORÉ ELETROMÓVEIS LTDA	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, { "08908749000143", CTOD("07/12/2011") } )
	AAdd( aCNPJNF, { "08908749000224", CTOD("22/05/2012") } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SEMPRE CENTRAL DE VELORIOS E FUNERARIAS LTDA        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	AAdd( aCNPJNF, { "12773805000157"} )
	AAdd( aCNPJNF, { "12773805000238"} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CENTERLONAS COMERCIAL LTDA	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, { "08043875000182"} )	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TICCOLOR VIDEO FOTO SOM LTDA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, { "77986321000131"} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| DISTRIBUIDORA DE PECAS KAMPEAO LTDA		 | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, { "38060430000171"} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|COMERCIAL DE PNEUS ROMA LTDA				 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"61721320000125"} )
    AAdd( aCNPJNF, {"61721320000206"} )
    AAdd( aCNPJNF, {"61721320000478"} )
    AAdd( aCNPJNF, {"61721320000559"} )
    AAdd( aCNPJNF, {"61721320000982"} )
    AAdd( aCNPJNF, {"61721320001016"} )
    AAdd( aCNPJNF, {"61721320001105"} )
    AAdd( aCNPJNF, {"61721320001288"} )
    AAdd( aCNPJNF, {"61721320001369"} )
    AAdd( aCNPJNF, {"61721320001440"} )
    AAdd( aCNPJNF, {"61721320001520"} )
    AAdd( aCNPJNF, {"61721320001601"} )
    AAdd( aCNPJNF, {"61721320001792"} )
    AAdd( aCNPJNF, {"61721320001873"} )
    AAdd( aCNPJNF, {"61721320001954"} )
    AAdd( aCNPJNF, {"61721320002098"} )
    AAdd( aCNPJNF, {"61721320002179"} )
    AAdd( aCNPJNF, {"61721320002250"} )	
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|TERRA UTIL COMERCIO DE MAQUINAS			 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJNF, {"07144507000168" } )
	
	//UNIMED NOROESTE CAPIXABA COOPERATIVA DE TRABALHO MEDICO
	AAdd( aCNPJNF, {"39384664000137" } ) //UF: ES
	AAdd( aCNPJNF, {"39384664000218" } ) //UF: ES

	//BULGARI
	AAdd( aCNPJNF, {"14863735000153"} ) //UF: SP

	//TODIMO Materiais de Construção
	AAdd( aCNPJNF, {"15375991000326"} ) //UF: MT
	
	//Schirmman
	AAdd( aCNPJNF, {"88579701000178"} )
	
	//CASA J NAKAO LTDA
	AAdd( aCNPJNF, { "53794996000463" } ) //UF: SP
	AAdd( aCNPJNF, { "53794996000110" } ) //UF: SP
	AAdd( aCNPJNF, { "53794996000382" } ) //UF: SP	
	
	//AGUILERA AUTOPEÇAS LTDA - MT 
	AAdd( aCNPJNF, { "37525771000102" } )
	AAdd( aCNPJNF, { "37525771000293" } )
	AAdd( aCNPJNF, { "37525771000374" } )
	AAdd( aCNPJNF, { "37525771000455" } )
	AAdd( aCNPJNF, { "37525771000536" } )
	AAdd( aCNPJNF, { "37525771000617" } )
	AAdd( aCNPJNF, { "37525771000706" } )
	AAdd( aCNPJNF, { "37525771000889" } )
	AAdd( aCNPJNF, { "37525771000960" } )
	AAdd( aCNPJNF, { "37525771001001" } )
	AAdd( aCNPJNF, { "37525771001184" } )
	AAdd( aCNPJNF, { "37525771001265" } )
	AAdd( aCNPJNF, { "37525771001346" } )
	AAdd( aCNPJNF, { "37525771001427" } )
	AAdd( aCNPJNF, { "37525771001508" } )
	AAdd( aCNPJNF, { "37525771001699" } )
	AAdd( aCNPJNF, { "37525771001770" } )
	AAdd( aCNPJNF, { "37525771001850" } )
	AAdd( aCNPJNF, { "37525771001931" } )
	AAdd( aCNPJNF, { "37525771002075" } )
	AAdd( aCNPJNF, { "37525771002156" } )
	AAdd( aCNPJNF, { "37525771002237" } )
	AAdd( aCNPJNF, { "37525771002318" } )
	AAdd( aCNPJNF, { "37525771002407" } )

	AAdd( aCNPJNF, { "07270160000108" } ) //COMERCIO DE PEÇAS VERDE LUCAS LTDA - MT - FILIAL 
	AAdd( aCNPJNF, { "11615634000175" } ) //COMÉRCIO DE PEÇAS GLOBAL LTDA - MT - FILIAL
	AAdd( aCNPJNF, { "13448434000109" } ) //COMERCIO DE AUTOPEÇAS COLIDER LTDA - MT - FILIAL

	//AGUILERA & CIA LTDA - RO 
	AAdd( aCNPJNF, { "04115428000130" } )
	AAdd( aCNPJNF, { "04115428000211" } )
	AAdd( aCNPJNF, { "04115428000300" } )
	AAdd( aCNPJNF, { "04115428000483" } )
	AAdd( aCNPJNF, { "04115428000564" } )

	//SHOW DE TELHAS / LEMI IND. COM. DE COIFA
	AAdd( aCNPJNF, { "06056395000120" } )
	AAdd( aCNPJNF, { "06211343000181" } )
	AAdd( aCNPJNF, { "13312706000130" } )

	//AUTO POSTO BRASIL DE VOLTA REDONDA LTDA
	AAdd( aCNPJNF, { "28680429000196" } )
	AAdd( aCNPJNF, { "29058443000115" } )
	AAdd( aCNPJNF, { "29066594000115" } )
	AAdd( aCNPJNF, { "04937593000178" } )
	AAdd( aCNPJNF, { "32504565000100" } )
	AAdd( aCNPJNF, { "32511032000148" } )
	AAdd( aCNPJNF, { "36512044000148" } )
	AAdd( aCNPJNF, { "00854639000134" } )
	AAdd( aCNPJNF, { "31662604000127" } )
	AAdd( aCNPJNF, { "07794482000148" } )
	AAdd( aCNPJNF, { "07248564000197" } )
	AAdd( aCNPJNF, { "10528476000153" } )	

	//BENVINDO STOCO
	AAdd( aCNPJNF, { "35953892000120" } )
	
	//FATTU DO BRASIL COMERCIO DE MATERIAIS DE COMUNICACAO VISUAL LTDA
	AAdd( aCNPJNF, { "11460665000102" } )
	AAdd( aCNPJNF, { "11460665000285" } )
	AAdd( aCNPJNF, { "11460665000366" } )
	AAdd( aCNPJNF, { "11460665000447" } )
	AAdd( aCNPJNF, { "11449801000155" } )
	
	//CD-MAX
	AAdd( aCNPJNF, { "00777674000873" } )	
	AAdd( aCNPJNF, { "00777674000954" } )	
	AAdd( aCNPJNF, { "00777674000288" } )	
	AAdd( aCNPJNF, { "01396282000150" } )	
		
	//PLASTIREAL INDUSTRIA E COMERCIO DE PLASTICOS LTDA
	AAdd( aCNPJNF, { "53234274000101" } )
	
	//MTI EXP E REP LTDA
	AAdd( aCNPJNF, { "04326492000160" } )
	AAdd( aCNPJNF, { "04326492000837" } )
	AAdd( aCNPJNF, { "04326492002457" } )
	AAdd( aCNPJNF, { "04326492000675" } )
	
	//Comando Auto Peças Ltda.
	AAdd( aCNPJNF, { "01032275000170" } )
	AAdd( aCNPJNF, { "01032275000250" } )
	AAdd( aCNPJNF, { "01032275000412" } )
	AAdd( aCNPJNF, { "01032275000331" } )
	AAdd( aCNPJNF, { "01032275000501" } )
	AAdd( aCNPJNF, { "01032275000684" } )
	AAdd( aCNPJNF, { "01032275000765" } )
	AAdd( aCNPJNF, { "01032275000846" } )
	
	//Direção Produtos Automotivos Ltda.
	AAdd( aCNPJNF, { "08184963000102" } )
	AAdd( aCNPJNF, { "08184963000285" } )
	AAdd( aCNPJNF, { "08184963000366" } )
	
	//Distribuidora de Peças Kampeão Ltda.
	AAdd( aCNPJNF, { "38060430000171" } )
	AAdd( aCNPJNF, { "38060430000252" } )
	
		//Contagem Motor Peças
	AAdd( aCNPJNF, { "02633281000145" } )
	AAdd( aCNPJNF, { "10418748000162" } )
	AAdd( aCNPJNF, { "19446980000189" } )
	
	//Cooper Sucesso
	AAdd( aCNPJNF, { "08112721000367" } )
	
	//Lorenfer Comercio Repr Prod Met LTDA
	AAdd( aCNPJNF, { "59561001000158" } )
	AAdd( aCNPJNF, { "59561001000310" } )
	AAdd( aCNPJNF, { "59561001000239" } )
	AAdd( aCNPJNF, { "59561001000409" } )
	AAdd( aCNPJNF, { "59561001000581" } )

	//RICCIERI CONFECCOES LTDA
	AAdd( aCNPJNF, { "75456764000608" } )
	AAdd( aCNPJNF, { "75456764000780" } )

	//Moderna Auto Pecas
	AAdd( aCNPJNF, { "00679038000132" } )	
EndIf

If nMvLJLBNT > 0 	
	lRet := .T.
Else
	
	lRet := .F.	

	/*Valida pelo CNPJ e pela data limite */
	For liConta = 1 to len(aCNPJNF)
		If AllTrim(aCNPJNF[liConta][1]) == AllTrim(cCNPJ)
			If len(aCNPJNF[liConta]) == 1
				lRet := .T.
				Exit
			Else          
				If DTOS(dDatabase) <= DTOS(aCNPJNF[liConta][2])			
					If (aCNPJNF[liConta][2] - dDatabase) < SuperGetMV("MV_LJDMNF", ,60)
						LJMsgLeg(LJAnalisaLeg(27, ""))
					EndIf
					lRet := .T.				
					Exit
				EndIf          
			EndIf
		EndIf
	Next liConta	
EndIf

lLibEmiteNF  := lRet

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjNVCC    ºAutor  ³Vendas Clientes     º Data ³  19/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade verificar se o CNPJ passado º±±
±±º          ³ como parametro esta autorizado a Venda não concomitante    º±±
±±º          ³ pelo SIGALOJA.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1 : CNPJ                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 : .T. - Este CNPJ esta autorizado                    º±±
±±º          ³         .F. - Este CNPJ nao esta autorizado                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                           
Function LjNVCC(cCNPJ)
Local aCNPJ		:= {}						// Array com os CNPJs em Regime Especial para a geracao da nota fiscal
Local nPos		:= 0						// Posicao do array de CNPJs
Local lRetorno 	:= .F.						// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona no array de CNPJs os CNPJs que permite a nao concomitancia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEmpAnt == "99" .OR. LS_GetID() == 2100001237
	AAdd( aCNPJ, {"82.373.077/0001-71" } )
EndIf	
AAdd( aCNPJ, {"27.177.096/0052-64" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0055-07" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0054-26" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0057-79" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0007-00" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0006-29" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0004-67" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0021-68" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0065-89" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0070-46" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0071-27" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0074-70" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0073-99" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0086-03" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0088-75" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0087-94" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0089-56" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0095-02" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0098-47" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0092-51" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0100-04" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0099-28" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0107-72" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0111-59" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0108-53" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0113-10" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0109-34" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0114-00" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0112-30" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0115-82" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0118-25" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0120-40" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0121-20" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0005-48" } )			//ITAPUA 
AAdd( aCNPJ, {"27.177.096/0123-92" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0124-73" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0125-54" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0126-35" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0118-25" } )			//ITAPUA   

//-----------------------
// CONNECTION CELULARES |
//-----------------------
AAdd( aCNPJ, {"01.761.367/0001-90" } )			
AAdd( aCNPJ, {"01.761.367/0002-71" } )
AAdd( aCNPJ, {"01.761.367/0004-33" } )
AAdd( aCNPJ, {"01.761.367/0005-14" } )
AAdd( aCNPJ, {"01.761.367/0006-03" } )
AAdd( aCNPJ, {"01.761.367/0007-86" } )
AAdd( aCNPJ, {"01.761.367/0008-67" } )
AAdd( aCNPJ, {"01.761.367/0009-48" } )
AAdd( aCNPJ, {"02.912.819/0001-50" } )
AAdd( aCNPJ, {"01.761.367/0011-62" } )
AAdd( aCNPJ, {"01.761.367/0012-43" } )
AAdd( aCNPJ, {"01.761.367/0014-65" } )
AAdd( aCNPJ, {"01.761.367/0015-96" } )
AAdd( aCNPJ, {"01.761.367/0022-15" } )

AAdd( aCNPJ, {"64.435.670/0001-13" } )			//Diesel Sete Pecas Ltda.

AAdd( aCNPJ, {"17.189.341/0001-50" } )     		//Ormimaquinas Ltda.
AAdd( aCNPJ, {"22.152.508/0001-48" } )     		//Ormimaquinas Ltda.

AAdd( aCNPJ, {"23.401.920/0001-17" } )     		//AP MOTOS COMERCIO IMPORTACAO E EXPORTACAO LTDA

AAdd( aCNPJ, {"17.437.013/0004-78" } )			// ENCAPA
AAdd( aCNPJ, {"17.437.013/0001-25" } )			// ENCAPA
AAdd( aCNPJ, {"17.437.013/0005-59" } )			// ENCAPA

AAdd( aCNPJ, {"05.417.707/0001-11" } )			// LEAL CARNEIRO & CIA LTDA

AAdd( aCNPJ, {"17.207.093/0001-22" } )			// GUAIAPO ELETRODOMESTICOS LTDA. 

AAdd( aCNPJ, {"21.704.762/0001-49" } )			// AFP MATERIAIS PARA CONSTRUCAO LTDA
AAdd( aCNPJ, {"21.704.762/0003-00" } )			// AFP MATERIAIS PARA CONSTRUCAO LTDA
AAdd( aCNPJ, {"21.704.762/0004-91" } )			// AFP MATERIAIS PARA CONSTRUCAO LTDA
AAdd( aCNPJ, {"21.704.762/0005-72" } )			// AFP MATERIAIS PARA CONSTRUCAO LTDA
AAdd( aCNPJ, {"21.704.762/0006-53" } )			// AFP MATERIAIS PARA CONSTRUCAO LTDA

AAdd( aCNPJ, {"05.910.055/0001-52" } )			// Augusto Móveis e Colchões LTDA.  

AAdd( aCNPJ, {"24.333.411/0006-71" } )			// SCALON & CERCHI LTDA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   RG PNEUS LTDA    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"25.567.140/0008-43" } )		
AAdd( aCNPJ, {"25.567.140/0005-09" } )		
AAdd( aCNPJ, {"25.567.140/0003-39" } )		
AAdd( aCNPJ, {"25.567.140/0002-58" } )		
AAdd( aCNPJ, {"25.567.140/0004-10" } )		
AAdd( aCNPJ, {"25.567.140/0001-77" } )		

AAdd( aCNPJ, {"00.888.758/0001-08" } )			// FERROBRAS IND E COM DE FERRO E AÇO LTDA

AAdd( aCNPJ, {"05.951.613/0001-28" } )			// AUGUSTO ENXOVAL E DECORAÇÃO LTDA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   AUGUSTO MÓVEIS E COLCHÕES LTDA    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"05.910.055/0005-86" } )
AAdd( aCNPJ, {"05.910.055/0003-14" } )
AAdd( aCNPJ, {"05.910.055/0002-33" } )

AAdd( aCNPJ, {"00.727.262/0008-29" } )			// SWAROVSKI CRISTAIS LTDA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CURINGA DOS PNEUS LTDA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"00.041.327/0030-46" } )
AAdd( aCNPJ, {"00.041.327/0002-92" } )
AAdd( aCNPJ, {"00.041.327/0026-60" } )
AAdd( aCNPJ, {"00.041.327/0051-70" } )
AAdd( aCNPJ, {"00.041.327/0010-00" } )
AAdd( aCNPJ, {"00.041.327/0025-89" } )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0¿
//³CRISTAIS SAO MARCOS LTDA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0Ù
AAdd( aCNPJ, {"23.645.492/0002-59" } )
AAdd( aCNPJ, {"02.229.066/0001-83" } )
AAdd( aCNPJ, {"23.325.204/0001-72" } )

AAdd( aCNPJ, {"04.715.054/0002-75" } )			// LIGAS GERAIS IND.COMERCIO LTDA  

AAdd( aCNPJ, {"21.325.204/0001-72" } )			// SAN REMO LUSTRES E DECORACOES LTDA


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0¿
//³OTICAS MARIA JOSE 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0Ù
AAdd( aCNPJ, {"19.882.745/0001-50" } )
AAdd( aCNPJ, {"19.882.745/0004-00" } )
AAdd( aCNPJ, {"19.882.745/0003-11" } )
AAdd( aCNPJ, {"19.882.745/0005-83" } )
AAdd( aCNPJ, {"19.882.745/0002-30" } )
AAdd( aCNPJ, {"19.882.745/0008-26" } )
AAdd( aCNPJ, {"19.882.745/0009-07" } )
AAdd( aCNPJ, {"19.882.745/0010-40" } )
AAdd( aCNPJ, {"19.882.745/0011-21" } )
AAdd( aCNPJ, {"19.882.745/0012-02" } )
AAdd( aCNPJ, {"19.882.745/0013-93" } )
AAdd( aCNPJ, {"19.882.745/0014-74" } )

AAdd( aCNPJ, {"25.631.151/0001-79" } )			// IPABRAC LTDA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IND E COM DE COLCHÕES CASTOR LTDA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AAdd( aCNPJ, {"09.451.214/0036-89"}  )     
AAdd( aCNPJ, {"09.451.214/0011-20"}  )
AAdd( aCNPJ, {"09.451.214/0028-79"}  )
AAdd( aCNPJ, {"07.227.426/0002-02"}  )
AAdd( aCNPJ, {"07.227.426/0001-21"}  )
AAdd( aCNPJ, {"07.227.426/0003-93"}  )
AAdd( aCNPJ, {"07.227.426/0004-74"}  )
AAdd( aCNPJ, {"09.451.214/0062-70"}  ) // Distribuidora de Móveis Ipanema Ltda / UF: MG

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³COSTA LAGE COMERCIO DE MOVEIS LTDA ME³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"11.486.641/0001-14"}  )  
AAdd( aCNPJ, {"11.486.641/0002-03"}  )  
AAdd( aCNPJ, {"11.486.641/0003-86"}  )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adicao Agropecuaria Ltda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"07.104.562/0001-24"}  )  
                                                                                                                                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Proteção Total Ltda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
AAdd( aCNPJ, {"26.342.469/0001-00" } ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DISTRIBUIDORA DE MÓVEIS IPANEMA LTDA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"09.451.214/0042-27"}  ) 
AAdd( aCNPJ, {"09.451.214/0041-46"}  )
AAdd( aCNPJ, {"09.451.214/0043-08"}  ) 
AAdd( aCNPJ, {"09.451.214/0040-65"}  ) 
   
//ÚÄÄÄÄÄÄÄÄÄ¿
//³Madepal. ³
//ÀÄÄÄÄÄÄÄÄÄÙ     
AAdd( aCNPJ, {"25.183.047/0001-69" } )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BELA ISCHIA ALIMENTOS LTDA. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"01.130.631/0001-98"}  ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PNEUSOLA PNEUS E PECAS S A  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, { "17.281.668/0001-57"} )
AAdd( aCNPJ, { "17.281.668/0002-38"} )
AAdd( aCNPJ, { "17.281.668/0003-19"} )
AAdd( aCNPJ, { "17.281.668/0004-08"} )
AAdd( aCNPJ, { "17.281.668/0005-80"} )
AAdd( aCNPJ, { "17.281.668/0006-61"} )
AAdd( aCNPJ, { "17.281.668/0007-42"} )
AAdd( aCNPJ, { "17.281.668/0008-23"} )
AAdd( aCNPJ, { "17.281.668/0009-04"} )
AAdd( aCNPJ, { "17.281.668/0010-48"} )
AAdd( aCNPJ, { "17.281.668/0011-29"} )
AAdd( aCNPJ, { "17.281.668/0012-00"} )
AAdd( aCNPJ, { "17.281.668/1113-90"} )
AAdd( aCNPJ, { "17.281.668/0014-71"} )
AAdd( aCNPJ, { "17.281.668/0015-52"} )
AAdd( aCNPJ, { "17.281.668/0016-33"} )
AAdd( aCNPJ, { "17.281.668/0017-14"} )
AAdd( aCNPJ, { "17.281.668/0019-86"} )
AAdd( aCNPJ, { "17.281.668/0020-10"} )
AAdd( aCNPJ, { "17.281.668/0021-09"} )
AAdd( aCNPJ, { "17.281.668/0022-81"} )
AAdd( aCNPJ, { "17.281.668/0023-62"} )
AAdd( aCNPJ, { "17.281.668/0024-43"} )
AAdd( aCNPJ, { "17.281.668/0025-24"} )
AAdd( aCNPJ, { "17.281.668/0026-05"} )
AAdd( aCNPJ, { "17.281.668/0027-96"} )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   LB COMERCIO DE PRESENTES LTDA  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, { "05.529.117/0001-80"} )
AAdd( aCNPJ, { "05.529.117/0003-42"} )
AAdd( aCNPJ, { "05.529.117/0004-23"} )
AAdd( aCNPJ, { "05.529.117/0006-95"} )
AAdd( aCNPJ, { "05.529.117/0008-57"} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   ASICS BRASIL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, { "53.249.017/0006-58"} )

//MARAJO FRUTAL - AUTO POSTO M FRUTAL LTDA 
AAdd( aCNPJ, { "15.595.376/0001-63"} )

//POSTO MARAJO
AAdd( aCNPJ, { "19.921.410/0001-01" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica no array de CNPJs se o CNPJ esta passado como³
//³parametro para a funcao esta em Regime Especial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, "@R 99.999.999/9999-99" ) } )
If nPos > 0
   lRetorno := .T.				//O CNPJ pode imprimir nao concomitante
Else
	lRetorno := .F.				//O CNPJ nao pode imprimir nao concomitante	
Endif 

Return lRetorno

//-----------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjMPreVendºAutor  ³Vendas Clientes     º Data ³  19/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade verificar se o CNPJ passado º±±
±±º          ³ como parametro esta autorizado a Venda em Modo Pre Venda   º±±
±±º          ³ pelo SIGALOJA.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1 : CNPJ                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 : .T. - Este CNPJ esta na pre venda                  º±±
±±º          ³         .F. - Este CNPJ nao esta na pre venda              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                           
Function LjMPreVend(cCNPJ)
Local aCNPJ		:= {}						// Array com os CNPJs em Regime Especial para a geracao da nota fiscal
Local nPos		:= 0						// Posicao do array de CNPJs
Local lRetorno 	:= .F.						// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona no array de CNPJs os CNPJs que permite a nao concomitancia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cEmpAnt == "99" .OR. LS_GetID() == 2100001237 ) .AND. ( SM0->M0_ESTCOB $ "MG" )
	AAdd( aCNPJ, {"82.373.077/0001-71" } )
EndIf
AAdd( aCNPJ, {"27.177.096/0052-64" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0055-07" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0054-26" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0057-79" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0007-00" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0006-29" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0004-67" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0021-68" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0065-89" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0070-46" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0071-27" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0074-70" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0073-99" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0086-03" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0088-75" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0087-94" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0089-56" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0095-02" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0098-47" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0092-51" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0100-04" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0099-28" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0107-72" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0111-59" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0108-53" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0113-10" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0109-34" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0114-00" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0112-30" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0115-82" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0118-25" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0120-40" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0121-20" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0005-48" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0123-92" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0124-73" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0125-54" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0126-35" } )			//ITAPUA
AAdd( aCNPJ, {"27.177.096/0118-25" } )			//ITAPUA  
AAdd( aCNPJ, {"01.761.367/0001-90" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0002-71" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0004-33" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0005-14" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0006-03" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0007-86" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0008-67" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"01.761.367/0009-48" } )			//CONNECTION CELULARES
AAdd( aCNPJ, {"02.912.819/0001-50" } )			//CONNECTION CELULARES

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica no array de CNPJs se o CNPJ esta passado como³
//³parametro para a funcao esta em Regime Especial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, "@R 99.999.999/9999-99" ) } )
If nPos > 0
   lRetorno := .T.				//O CNPJ pode imprimir nao concomiatante
Else
	lRetorno := .F.				//O CNPJ nao pode imprimir nao concomitante	
Endif 

Return (lRetorno)

//-----------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjNfInterEst ³ Autor ³ Vendas Clientes    ³ Data ³ 31.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se eh uma venda interestadual e se o CNPJ 		  ³±±
±±³ 		 ³ seja um dos identificados 	  				  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet -> Pode Emite ou Nao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXFUNC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjNFInterEst(cCNPJ , cA1Est , cA1Pessoa)

Local aCNPJ		:= {}							// Array com os CNPJs em Regime Especial para a geracao da nota fiscal
Local nPos		:= 0							// Posicao do array de CNPJs
Local lRetorno 	:= .F.							// Retorno da funcao
Local cMVEstado := SuperGetMV("MV_ESTADO",,"")  // parametro que indica o estado
Local nMVLJIntUF:= SuperGetMV("MV_LJINTUF",,0)	// Responsável por habilitar Venda Interestadual.(0 - Não, 1 - Sim)

DEFAULT cCNPJ	:= ""							// CNPJ da empresa
DEFAULT cA1Est	:= ""							// Estado do Cliente

//nao faz mais sentido fazer a validacao sobre CNPJ, porém por causa do legado, manteremos o tratamento antigo
If nMVLJIntUF = 0

	If !Empty(cA1Est) .AND. AllTrim(cA1Est) <> AllTrim(cMVEstado) .AND. (AllTrim(cA1Pessoa) <> "J")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona no array de CNPJs os CNPJs ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aCNPJ, {"17.207.093/0001-22" } )		// Comercial Jorge
		AAdd( aCNPJ, {"21.704.762/0001-49" } )		// Comercial Jorge
		AAdd( aCNPJ, {"21.704.762/0003-00" } )		// AFP Materiais de Construção
		AAdd( aCNPJ, {"21.704.762/0004-91" } )		// AFP Materiais de Construção
		AAdd( aCNPJ, {"21.704.762/0005-72" } )		// AFP Materiais de Construção
		AAdd( aCNPJ, {"03.635.803/0004-53" } )		// Opção Ind. e Com. de Computadores
		AAdd( aCNPJ, {"03.635.803/0005-34" } )		// Opção Ind. e Com. de Computadores
		AAdd( aCNPJ, {"03.635.803/0006-15" } )		// Opção Ind. e Com. de Computadores
		AAdd( aCNPJ, {"03.635.803/0003-72" } )		// Opção Ind. e Com. de Computadores 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CURINGA DOS PNEUS LTDA			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aCNPJ, {"00.041.327/0030-46" } )
		AAdd( aCNPJ, {"00.041.327/0002-92" } )
		AAdd( aCNPJ, {"00.041.327/0026-60" } )  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³COOPERATIVA CENTRAL DOS PRODUTORES RURAIS DE MINAS GERAIS LTDA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	AAdd( aCNPJ, {"17.249.111/0014-53" } )	//ITAMBÉ
		AAdd( aCNPJ, {"20.219.382/0001-56" } )	//ITAMBE
		AAdd( aCNPJ, {"19.715.523/0001-42" } )	//ITAMBE   
		AAdd( aCNPJ, {"17.249.111/0003-09"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0009-96"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0010-20"}  ) //ITAMBE
		AAdd( aCNPJ, {"52.106.911/0001-00"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0028-59"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0031-54"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0032-35"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0035-88"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0052-89"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0060-99"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0061-70"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0064-12"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0068-46"}  ) //ITAMBE
		AAdd( aCNPJ, {"17.249.111/0078-18"}  ) //ITAMBE
		AAdd( aCNPJ, {"19.714.245/0001-09"}  ) //ITAMBE
		AAdd( aCNPJ, {"19.715.523/0001-42"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0001-56"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0002-37"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0004-07"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0008-22"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0009-03"}  ) //ITAMBE
		AAdd( aCNPJ, {"02.959.655/0003-89"}  ) //ITAMBE
		AAdd( aCNPJ, {"02.959.655/0002-06"}  ) //ITAMBE
		AAdd( aCNPJ, {"06.036.387/0002-01"}  ) //ITAMBE
		AAdd( aCNPJ, {"06.944.301/0001-50"}  ) //ITAMBE
		AAdd( aCNPJ, {"08.409.101/0001-22"}  ) //ITAMBE
		AAdd( aCNPJ, {"20.219.382/0004-07"}  ) //ITAMBE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica no array de CNPJs se o CNPJ esta passado como³
		//³parametro para a funcao esta em Regime Especial       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, "@R 99.999.999/9999-99" ) } )
		If nPos > 0
			lRetorno := .T.				//O CNPJ pode imprimir nao concomitante
		Else
			lRetorno := .F.				//O CNPJ nao pode imprimir nao concomitante	
		Endif
	EndIf
// validado pelo parametro MV_LJINTUF
Else
	lRetorno := .T.
EndIf
	
Return lRetorno


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfNoPaf   ³ Autor ³ Vendas Clientes     ³ Data ³ 19.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao para nao utilizacao do PAF-ECF, liberar somente³±±
±±³          ³ se o cliente provar a não obrigatoriedade.				  ³±±
±±³          ³ Para esses casos, nao eh possivel utilizar o ECF			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja e FrontLoja										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                           
Function LjNfNoPaf(cCnpj)
Local lRet	:= .F.
Local nPos	:= 0

If !Len(aCnpjNoPaf) >= 1
	//SEBRAE - AL
	AAdd( aCnpjNoPaf, {"12.517.413/0001-27"} )	//UF: AL
	AAdd( aCnpjNoPaf, {"12.517.413/0002-08"} )	//UF: AL
	AAdd( aCnpjNoPaf, {"12.517.413/0003-99"} )	//UF: AL
	AAdd( aCnpjNoPaf, {"12.517.413/0004-70"} )	//UF: AL
	
	//COOPERATIVA AGROPECUARIA CENTRO SERRANA
	AAdd( aCnpjNoPaf, {"27.942.085/0014-06"} )
	AAdd( aCnpjNoPaf, {"27.942.085/0020-46"} )
	AAdd( aCnpjNoPaf, {"27.942.085/0025-50"} )
	
	//UNIMED NOROESTE CAPIXABA COOPERATIVA DE TRABALHO MEDICO
	AAdd( aCnpjNoPaf, {"39.384.664.0001-37"} ) //UF: ES
	AAdd( aCnpjNoPaf, {"39.384.664.0002-18"} ) //UF: ES
	
	//ENERGY NUTRITION
	AAdd( aCnpjNoPaf, {"20.297.287/0001-70"} ) //UF: AL
	AAdd( aCnpjNoPaf, {"16.971.364/0001-59"} ) //UF: AL		
	
	
	//CURINGA DOS PNEUS
	AAdd( aCnpjNoPaf, { "00.041.327/0043-60" } ) //UF: MA
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DALLAS RENT A CAR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCnpjNoPaf, {"00.470.111/0004-04" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0006-76" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0008-38" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0009-19" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0010-52" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0011-33" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0012-14" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0014-86" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0015-67" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0017-29" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0018-00" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0019-90" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0020-24" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0023-77" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0026-10" } )			
	AAdd( aCnpjNoPaf, {"00.470.111/0027-09" } )    
	AAdd( aCnpjNoPaf, {"00.470.111/0028-81" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0001-61" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0003-23" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0005-95" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0021-05" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0022-96" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0032-68" } )
	AAdd( aCnpjNoPaf, {"11.453.272/0001-63" } )
	AAdd( aCnpjNoPaf, {"00.470.111/0033-49" } ) 
	AAdd( aCnpjNoPaf, {"00.470.111/0036-91" } )
	AAdd( aCnpjNoPaf, {"11.455.816/0010-17" } )	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BRC AUTOMÓVEIS DE ALUGUEL LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCnpjNoPaf, {"07.185.183/0002-97" } )			
	AAdd( aCnpjNoPaf, {"07.185.183/0003-78" } )    
	AAdd( aCnpjNoPaf, {"07.185.183/0004-59" } )			
	AAdd( aCnpjNoPaf, {"07.185.183/0005-30" } )    
	AAdd( aCnpjNoPaf, {"07.185.183/0007-00" } )			
	AAdd( aCnpjNoPaf, {"07.185.183/0008-82" } )    
	AAdd( aCnpjNoPaf, {"07.185.183/0009-63" } )			
	AAdd( aCnpjNoPaf, {"07.185.183/0011-88" } )     
	AAdd( aCnpjNoPaf, {"07.185.183/0006-10" } )     
	AAdd( aCnpjNoPaf, {"07.185.183/0010-05" } )     
	AAdd( aCnpjNoPaf, {"07.185.183/0001-06" } )
	//BRFIBRA TELECOMUNICACOES LTDA
	AAdd( aCnpjNoPaf, { "73.972.002/0001-16" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0002-05" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0004-69" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0003-88" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0006-20" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0005-40" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0007-01" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0012-79" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0008-92" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0011-98" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0010-07" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0013-50" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0014-30" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0015-11" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0016-00" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0017-83" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0018-64" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0019-45" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0020-89" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0021-60" } )
	AAdd( aCnpjNoPaf, { "73.972.002/0022-40" } )	
EndIf

nPos :=  Ascan( aCnpjNoPaf, { |x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
If nPos > 0
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LjNfExPaf

Autorizacao para nao utilizacao do PAF-ECF, liberar somente
se o cliente provar a não obrigatoriedade. Para esses casos, 
eh possivel utilizar o ECF
	                 
@param   	EXPl1 - Texto contendo o CNPJ                         
@author  	Varejo
@version 	P11.8
@since   	07/05/2015
@return  	EXPl1 - Indica se liberado para uso de ECF sem PAF-ECF 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------                           
Function LjNfExPaf(cCnpj)
Local lRet	:= .F.
Local nPos	:= 0

If !Len(aCnpjExPaf) >= 1
	//BEACH PARK HOTEL -> Motivo: Foi apresentado projeto de participante do projeto Piloto da NFC-e,
	//por esse motivo precisa permitir testes com ECF/NFC-e em ambiente atualizado
	AAdd( aCnpjExPaf, {"11.805.397/0001-05"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0003-77"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0005-39"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0007-09"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0009-62"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0010-04"} )	//UF: CE
	AAdd( aCnpjExPaf, {"01.092.234/0001-79"} )	//UF: CE
	AAdd( aCnpjExPaf, {"09.260.627/0001-56"} )	//UF: CE
	AAdd( aCnpjExPaf, {"10.888.414/0001-52"} )	//UF: CE
	AAdd( aCnpjExPaf, {"15.259.978/0001-40"} )	//UF: CE
	AAdd( aCnpjExPaf, {"12.549.940/0001-13"} )	//UF: CE
	AAdd( aCnpjExPaf, {"09.178.829/0001-53"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0013-49"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0011-87"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0012-68"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0014-20"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0016-91"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0017-72"} )	//UF: CE
	AAdd( aCnpjExPaf, {"22.575.834/0001-68"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0015-00"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0018-53"} )	//UF: CE
	AAdd( aCnpjExPaf, {"09.225.262/0001-29"} )	//UF: CE
	AAdd( aCnpjExPaf, {"11.805.397/0004-58"} )	//UF: CE
	AAdd( aCnpjExPaf, {"25.096.351/0001-79"} )	//UF: CE	
	
	//POSTO MARAJO
	AAdd( aCnpjExPaf, { "19.921.410/0001-01" } )	
EndIf

nPos :=  Ascan( aCnpjExPaf, { |x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
If nPos > 0
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfPafEcf  ³ Autor ³ Vendas Clientes     ³ Data ³ 04.08.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao para utilizacao do PAF-ECF					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validacao                                      ³±±
±±³Parametros³ Array: aCnpjPaf(CNPJ , nPDV, Data)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja e FrontLoja										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                           
Function LjNfPafEcf(cCnpj) 
Local lRet 		:= .F.
Local nPos 		:= 0
Local lCnpjTot	:= .F.
Local aLeg64	:= {}
Local aLeg65	:= {}
Local lPafObr	:= .F.
Local lVerCnpj	:= .F.
Local lEmitNfce := .F.
Local lEmitSAT	:= .F.
Local dDataHoje := Date()
Local lJob		:= IsBlind()
Local lPOS		:= STFIsPOS() // Valida se é POS
Local aRet 		:= {} //Retorno da StategyECF
Local aPDV		:= {""} //Parametro da Strategy
Local lIsSIGAFAT:= .F.
Local lVdaDireta:= .F. //Identiica se é execução da Venda Direta (Pelo módulo SIGAFAT)
Local lIsMDI 	:= .F.

If lPafECF == Nil
	
	lIsSIGAFAT := (ValType(nModulo) == "N" .AND. nModulo == 5)
	lVdaDireta := lIsSIGAFAT .And. ( IsInCallStack("FATA701") .Or. IsInCallStack("LOJA701") )
	
	If IsInCallStack("NfeInfAd") .OR.;
	   (!lJob .And. lVdaDireta .And. !IsInCallStack("FR271CRPCORC") ) //Não valida PAF quando rotina Venda Direta
		
		lPafECF := .F.
	EndIf            

	//Se estiver liberado do uso do PAF, sai da função
	If LjNfNoPaf(cCnpj)
		lPafECF := .F.		
	EndIf
	
	//Valida se está configurado o uso da NFC-e que sobrepoe o uso de PAF
	lEmitNFCe := LjEmitNFCe()
	
	//Valida se está configurado o uso de SAT que sobrepoe o uso de PAF
	lEmitSAT  := LjUseSat()
	
	//Se está configurado o uso da NFC-e, seta o PAF como .F.
	If lEmitNFCe .Or. lEmitSAT
		lRet 	:= .F.
		lPafEcf := .F.
	EndIf
EndIf

//Utilizado para avaliar o PAF-ECF apenas uma vez
If lPafEcf == Nil
		
	lEmitNfce := LjEmitNFCe()  //Valida se está configurado o uso da NFC-e que sobrepoe o uso de PAF
	lEmitSAT  := LjUseSat() //Valida se está configurado o uso de SAT que sobrepoe o uso de PAF
	
	aLeg64	:= LJAnalisaLeg(64) //Legislação de Obrigatoriedade do PAF
	aLeg65	:= LJAnalisaLeg(65) //Legislação que obriga o envio do relatório gerencial	
	
	If !lEmitNfce .And. !lEmitSAT	
		lPafObr:= aLeg64[1] .AND. !LjNfExPaf(cCnpj)	//Permite EXCECAO para uso do PAF quando estado obriga
	EndIf
	
	lIsMDI 	:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI
	
	//Deve verificar o PDV pois nos estados onde a entrega do Rel. Gerencial 
	//de Identificacao do PAF-ECF é obrigatoria a liberação funciona por PDV
	If (!lIsMDI .Or. Select("SLG") > 0) .And. ;
		!lEmitNfce .And. !lEmitSAT .AND. AllTrim(cPDVEcf) == ""
		
		//Ao iniciar o programa não ha comunicação com o ECF portanto validar de outra forma
		If lPOS
			aRet := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )		
			If ValType(aRet) <> "A" .OR. Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aPDV) < 1     
				cPDVEcf := STFGetStat("PDV")
				If Empty(cPDVEcf)
					STFMessage("LOJANF","STOP", "Falha na obtenção do número do PDV") //"Falha na obtenção do número do PDV"
					STFShowMessage("LOJANF")//"Falha na obtenção do número do PDV"
				EndIf
			Else
				cPDVEcf := aPDV[1]
			EndIf 		
		ElseIf lJob .Or. nHdlECF <> -1
			cPDVEcf	:= AllTrim(LjGetStation("PDV"))
		ElseIf !lJob .AND. (GetRemoteType() <> 5)	//Nao deve verificar PDV quando WEBAPP (SmartClient em HTML)
	 		IfPegPDV(nHdlECF, @cPDVEcf)
	 	EndIf
	EndIf
	
	If lPafObr
		If lEmitNfce .Or. lEmitSAT
			lRet	:= .F.
			lVerCnpj:= .F.
		Else
			lRet	:= .T.
			If aLeg65[1]
				lVerCnpj := .T.
			EndIf
		EndIf
	Else
		//Valida se acesso ao sistema vem do executavel ou parametro .T. e não está utilizando a NFC-e/SAT
		If (LjxBGetPaf()[2] .OR. SuperGetMV("MV_LJPAFEC",,.F.)) .AND. !lEmitNfce .And. !lEmitSAT
			lRet	:= .T.
			If aLeg65[1]
				lVerCnpj := .T.
			Else
			    lVerCnpj := .F.
			EndIf
		Else
			lRet	:= .F.		
			If !LjxBGetPaf()[2] .AND. (SuperGetMV("MV_LJPAFEC") <> Nil .AND. !SuperGetMV("MV_LJPAFEC",,.F.)) .AND. !aLeg65[1]			
				lVerCnpj:= .F.  //Caso o cliente possua liberação deve verificar o CNPJ
			Else 
				lVerCnpj:= .T.
			EndIf
		EndIf
	EndIf
	
	lCnpjTot := SuperGetMV("MV_LJHMPAF", ,.F.)
	cCnpj := AllTrim(cCnpj)
		    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas Carrega o Array na primeira vez que utilizar essa Funcao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVerCnpj .AND. !Len(aCnpjPaf) >= 1
		    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Validacao para indicar se o CNPJ da TOTVS esta ou nao no PAF-ECF.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCnpjTot .AND. AllTrim(cEmpAnt) == "99"
				AAdd( aCnpjPaf, {"53.113.791/0001-22"} ) 		//Totvs S.A   
				AAdd( aCnpjPaf, {"12.345.678/9012-34"} ) 		//EPSON TM-T81 FBII
				AAdd( aCnpjPaf, {"82.373.077/0001-71"} ) 		//BEMATECH MP-2100 TH FI		
			EndIf

			AAdd( aCnpjPaf, {"02.226.278/0002-98"} ) //CENTRAL BORRACHAS E FERRAMENTAS LTDA
			AAdd( aCnpjPaf, {"02.226.278/0006-11"} ) //CENTRAL BORRACHAS E FERRAMENTAS LTDA
			AAdd( aCnpjPaf, {"02.226.278/0005-30"} ) //CENTRAL BORRACHAS E FERRAMENTAS LTDA

		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  		   	//³ Lojas Guido		   ³
 		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
			AAdd( aCnpjPaf, {"35.640.937/0001-06"} )
			AAdd( aCnpjPaf, {"35.640.937/0003-78"} )
			AAdd( aCnpjPaf, {"35.640.937/0004-59"} )
			AAdd( aCnpjPaf, {"35.640.937/0014-20"} )
			AAdd( aCnpjPaf, {"35.640.937/0007-00"} )
			AAdd( aCnpjPaf, {"35.640.937/0008-82"} )
			AAdd( aCnpjPaf, {"35.640.937/0005-30"} )
			AAdd( aCnpjPaf, {"35.640.937/0009-63"} )
			AAdd( aCnpjPaf, {"35.640.937/0013-40"} )
			AAdd( aCnpjPaf, {"35.640.937/0015-01"} )
			AAdd( aCnpjPaf, {"35.640.937/0017-73"} )
			AAdd( aCnpjPaf, {"35.640.937/0018-54"} )
			AAdd( aCnpjPaf, {"35.640.937/0016-92"} )
			AAdd( aCnpjPaf, {"35.640.937/0020-79"} )
			AAdd( aCnpjPaf, {"35.640.937/0022-30"} )
			AAdd( aCnpjPaf, {"35.640.937/0021-50"} )
			AAdd( aCnpjPaf, {"35.640.937/0023-11"} )
			AAdd( aCnpjPaf, {"35.640.937/0024-00"} )
			AAdd( aCnpjPaf, {"35.640.937/0025-83"} )
			AAdd( aCnpjPaf, {"35.640.937/0026-64"} )
			AAdd( aCnpjPaf, {"35.640.937/0027-45"} )
			AAdd( aCnpjPaf, {"35.640.937/0028-26"} )
			AAdd( aCnpjPaf, {"35.640.937/0029-07"} )
			AAdd( aCnpjPaf, {"35.640.937/0030-40"} )
			AAdd( aCnpjPaf, {"35.640.937/0031-21"} )
			AAdd( aCnpjPaf, {"35.640.937/0032-02"} )
			AAdd( aCnpjPaf, {"35.640.937/0035-55"} )
			AAdd( aCnpjPaf, {"35.640.937/0034-74"} )
			AAdd( aCnpjPaf, {"35.640.937/0036-36"} )
			AAdd( aCnpjPaf, {"35.640.937/0039-89"} )
			AAdd( aCnpjPaf, {"35.640.937/0038-06"} )
			AAdd( aCnpjPaf, {"35.640.937/0040-12"} )
			AAdd( aCnpjPaf, {"35.640.937/0037-17"} )
			AAdd( aCnpjPaf, {"35.640.937/0041-01"} )
			AAdd( aCnpjPaf, {"35.640.937/0042-84"} )
			AAdd( aCnpjPaf, {"35.640.937/0022.30"} )
			AAdd( aCnpjPaf, {"35.640.937/0017.73"} )
			AAdd( aCnpjPaf, {"35.640.937/0018.54"} )
			AAdd( aCnpjPaf, {"35.640.937/0016.92"} )
			AAdd( aCnpjPaf, {"35.640.937/0023.11"} )
			AAdd( aCnpjPaf, {"35.640.937/0021.50"} )
			AAdd( aCnpjPaf, {"35.640.937/0039.89"} )

		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³FRISA-FRIGORIFICO RIO DOCE S/A		   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
			AAdd( aCnpjPaf, {"27.497.684/0014-50"} )   
			AAdd( aCnpjPaf, {"27.497.684/0018-83"} ) 	
			AAdd( aCnpjPaf, {"12.892.415/0001-04"} ) // FRISA COMERCIAL MATRIZ SA.	
			AAdd( aCnpjPaf, {"12.892.415/0002-87"} )   
			AAdd( aCnpjPaf, {"12.892.415/0003-68"} ) 	
			AAdd( aCnpjPaf, {"12.892.415/0005-20"} )
			AAdd( aCnpjPaf, {"12.892.415/0004-49"} )   
			AAdd( aCnpjPaf, {"27.497.684/0006-40"} ) 	
			AAdd( aCnpjPaf, {"27.497.684/0013-79"} )
			AAdd( aCnpjPaf, {"27.497.684/0008-01"} )   
			AAdd( aCnpjPaf, {"01.066.650/0001-00"} ) 	
		  	AAdd( aCnpjPaf, {"12.892.415/0006-00"} )
		  	AAdd( aCnpjPaf, {"12.892.415/0007-91"} )
		  	AAdd( aCnpjPaf, {"12.892.415/0008-72"} )
				
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Automecanica Campos Elíseos Ltda.        ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		     AAdd( aCnpjPaf, {"29.067.782/0001-68"} )  
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ASSOCIACAO CANCAO NOVA RIO DE JANEIRO.   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		     AAdd( aCnpjPaf, {"46.696.035/0007-01"} )
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ELCA COSMETICOS LTDA.   ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"08.377.511/0006-43"} )    
		    AAdd( aCnpjPaf, {"08.377.511/0015-34"} ) 
		    AAdd( aCnpjPaf, {"08.377.511/0016-15"} ) 
		   	AAdd( aCnpjPaf, {"08.377.511/0022-63"} )
			AAdd( aCnpjPaf, {"08.377.511/0030-73"} )
			AAdd( aCnpjPaf, {"08.377.511/0025-06"} )
			AAdd( aCnpjPaf, {"08.377.511/0027-78"} )
			AAdd( aCnpjPaf, {"08.377.511/0029-30"} ) 
			AAdd( aCnpjPaf, {"08.377.511/0021-82"} )
			AAdd( aCnpjPaf, {"08.377.511/0023-44"} )
			AAdd( aCnpjPaf, {"08.377.511/0028-59"} )
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Fritools Ferramentos Maq. e Equipamentos. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   AAdd( aCnpjPaf, {"01.329.973/0001-31"} )
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³SILIMED - COMERCIO DE PRODUTOS MEDICO HOSPITALARES LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   AAdd( aCnpjPaf, {"03.448.093/0001-00"} ) 
		   AAdd( aCnpjPaf, {"03.448.093/0004-52"} )   
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Santa Rita Comércio e Instalações Ltda. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   AAdd( aCnpjPaf, {"86.365.350/0001-77"} ) 
		   AAdd( aCnpjPaf, {"86.365.350/0012-20"} )   
		   AAdd( aCnpjPaf, {"86.365.350/0005-09"} )   
		   AAdd( aCnpjPaf, {"86.365.350/0002-58"} )
		   AAdd( aCnpjPaf, {"86.365.350/0004-10"} )
		   AAdd( aCnpjPaf, {"86.365.350/0008-43"} )
		   AAdd( aCnpjPaf, {"86.365.350/0006-81"} )
		   AAdd( aCnpjPaf, {"86.365.350/0010-68"} )
		   AAdd( aCnpjPaf, {"86.365.350/0013-00"} )
		   AAdd( aCnpjPaf, {"86.365.350/0014-91"} )
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Frutas Cantu Nordeste Ltda. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                      
			AAdd( aCnpjPaf, {"02.731.684/0004-70"} )
			AAdd( aCnpjPaf, {"02.731.684/0001-27"} )
			AAdd( aCnpjPaf, {"02.731.684/0002-08"} )
			AAdd( aCnpjPaf, {"02.731.684/0003-99"} )
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Santa Rita Comercio e Instalacoes Ltda. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"86.365.350/0001-77"} )  
			AAdd( aCnpjPaf, {"86.365.350/0012-20"} )  	   
			AAdd( aCnpjPaf, {"86.365.350/0005-09"} )    
		                                   
				                         
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Gonçalves Salles S A Indústria e Comércio. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		 	AAdd( aCnpjPaf, {"61.365.557/0004-63"} )  
			AAdd( aCnpjPaf, {"61.365.557/0003-82"} )  
			 	 		                                  
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Best Computadores LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		 	 		    
			AAdd( aCnpjPaf, {"05.892.610/0001-60"} )	 
			 	 		    
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³EVERKID MACEIO COMERCIO DE BRINQUEDOS LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		   AAdd( aCnpjPaf, {"11.891.394/0001-31"} )
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³APIA CONSULTORIA E SISTEMAS S/C. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		    AAdd( aCnpjPaf, {"00.554.240/0001-38"} )
		 	AAdd( aCnpjPaf, {"31.130.537/0001-08"} ) 	
			 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³COOPERATIVA AGROPECUARIA DE CASSIA LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		    AAdd( aCnpjPaf, {"19.508.639/0005-34"} )
			AAdd( aCnpjPaf, {"19.508.639/0018-59"} )
			AAdd( aCnpjPaf, {"19.508.639/0017-78"} )
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³FABRICA DE TELAS SÃO JORGE LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			 AAdd( aCnpjPaf, {"28.807.253/0001-90"} )      
			 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³MK PUBLICITA PRODUCOES PUBLICIDADE E PROPAGANDA LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			 AAdd( aCnpjPaf, {"31.449.358/0001-20"} )     
			 	 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³MYPLACE INDUSTRIA E COMERCIO DO VESTUARIO LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			 AAdd( aCnpjPaf, {"09.556.355/0001-36"} )
			 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Elegancia Cosméticos. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"08.377.511/0012-91"} )
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Metalosa Ind Metalurgica S/A. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"27.485.374/0004-43"} )  
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Metalosa Ind Metalurgica S/A. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"27.293.398/0001-58"} )
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³CINCAL P LTDA ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
		     AAdd( aCnpjPaf, {"01.503.952/0001-90"} )
		     AAdd( aCnpjPaf, {"01.503.952/0002-71"} )
		     AAdd( aCnpjPaf, {"01.503.952/0004-33"} )
		     AAdd( aCnpjPaf, {"01.503.952/0005-14"} )
		     AAdd( aCnpjPaf, {"01.503.952/0006-03"} )
		     AAdd( aCnpjPaf, {"01.503.952/0007-86"} )
		     AAdd( aCnpjPaf, {"01.503.952/0009-48"} )   
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³INTER COLOR LAB COM IMP MAT FOTOGRAF. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
		   	 AAdd( aCnpjPaf, {"55.589.477/0009-01"} )
			 AAdd( aCnpjPaf, {"04.175.781/0001-06"} ) // ARARAS EXPRESS LAB. COM. MAT. FOT LTDA
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Gremio Garoto. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
		   	 AAdd( aCnpjPaf, {"10.782.890/0001-94"} )    //Gremio Garoto		    
		     AAdd( aCnpjPaf, {"28.053.619/0011-55"} )    //Lojinha Garoto  
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³DLD COMERCIO VAREJISTA LTDA - Dadalto S/A ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	 AAdd( aCnpjPaf, {"27.179.753/0001-62"} )
			 AAdd( aCnpjPaf, {"27.179.753/0013-04"} )
			 AAdd( aCnpjPaf, {"27.179.753/0009-10"} )
			 AAdd( aCnpjPaf, {"27.179.753/0023-78"} )
			 AAdd( aCnpjPaf, {"27.179.753/0024-59"} )
			 AAdd( aCnpjPaf, {"27.179.753/0009-10"} )  
			 AAdd( aCnpjPaf, {"27.179.753/0015-68"} )
		     AAdd( aCnpjPaf, {"27.179.753/0034-20"} )
		   	 AAdd( aCnpjPaf, {"27.179.753/0002-43"} )
			 AAdd( aCnpjPaf, {"27.179.753/0004-05"} )
			 AAdd( aCnpjPaf, {"27.179.753/0012-15"} )
			 AAdd( aCnpjPaf, {"27.179.753/0028-82"} )
			 AAdd( aCnpjPaf, {"27.179.753/0014-87"} )
			 AAdd( aCnpjPaf, {"27.179.753/0016-49"} )  
			 AAdd( aCnpjPaf, {"27.179.753/0017-20"} )
			 AAdd( aCnpjPaf, {"27.179.753/0019-91"} )
		   	 AAdd( aCnpjPaf, {"27.179.753/0008-39"} )
			 AAdd( aCnpjPaf, {"27.179.753/0021-06"} )
			 AAdd( aCnpjPaf, {"27.179.753/0042-30"} )
			 AAdd( aCnpjPaf, {"27.179.753/0043-11"} )
			 AAdd( aCnpjPaf, {"27.179.753/0026-10"} )
			 AAdd( aCnpjPaf, {"27.179.753/0046-64"} )  
			 AAdd( aCnpjPaf, {"27.179.753/0044-00"} )
		     AAdd( aCnpjPaf, {"27.179.753/0030-05"} )
		   	 AAdd( aCnpjPaf, {"27.179.753/0031-88"} )
			 AAdd( aCnpjPaf, {"27.179.753/0032-69"} )
			 AAdd( aCnpjPaf, {"27.179.753/0025-30"} )
			 AAdd( aCnpjPaf, {"27.179.753/0035-01"} )
			 AAdd( aCnpjPaf, {"27.179.753/0006-77"} )
			 AAdd( aCnpjPaf, {"27.179.753/0018-00"} )  
			 AAdd( aCnpjPaf, {"27.179.753/0036-92"} )
		     AAdd( aCnpjPaf, {"27.179.753/0037-73"} )     
		   	 AAdd( aCnpjPaf, {"27.179.753/0038-54"} )
			 AAdd( aCnpjPaf, {"27.179.753/0040-79"} )
			 AAdd( aCnpjPaf, {"27.179.753/0041-50"} )
			 AAdd( aCnpjPaf, {"27.179.753/0045-83"} )
			 AAdd( aCnpjPaf, {"27.179.753/0047-45"} )
			 AAdd( aCnpjPaf, {"27.179.753/0048-26"} )
			 AAdd( aCnpjPaf, {"27.179.753/0050-40"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0051-21"} )
			 AAdd( aCnpjPaf, {"27.179.753/0052-02"} )
			 AAdd( aCnpjPaf, {"27.179.753/0053-93"} )
		     AAdd( aCnpjPaf, {"27.179.753/0054-74"} )
		 	 AAdd( aCnpjPaf, {"27.179.753/0056-36"} )
			 AAdd( aCnpjPaf, {"27.179.753/0055-55"} )
			 AAdd( aCnpjPaf, {"27.179.753/0058-06"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0059-89"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0060-12"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0061-01"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0062-84"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0063-65"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0064-46"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0065-27"} )
		 	 AAdd( aCnpjPaf, {"27.179.753/0070-94"} )
			 AAdd( aCnpjPaf, {"27.179.753/0073-37"} )
			 AAdd( aCnpjPaf, {"27.179.753/0072-56"} )
			 AAdd( aCnpjPaf, {"27.179.753/0071-75"} )
		  	 AAdd( aCnpjPaf, {"27.179.753/0075-07"} )
		 	 AAdd( aCnpjPaf, {"27.179.753/0074-18"} )
			 AAdd( aCnpjPaf, {"27.179.753/0076-80"} )
			 AAdd( aCnpjPaf, {"27.179.753/0077-60"} )
			 AAdd( aCnpjPaf, {"27.179.753/0078-41"} )
			 AAdd( aCnpjPaf, {"27.179.753/0079-22"} )
			 AAdd( aCnpjPaf, {"27.179.753/0080-66"} )
			 AAdd( aCnpjPaf, {"27.179.753/0081-47"} )
			 AAdd( aCnpjPaf, {"27.179.753/0082-28"} )
			 AAdd( aCnpjPaf, {"27.179.753/0083-09"} )
			 AAdd( aCnpjPaf, {"27.179.753/0084-90"} )
			 AAdd( aCnpjPaf, {"27.179.753/0085-70"} )
			
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³MEU MOVEL DE MADEIRA-COM.MOVEIS DEC.LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"09.175.816/0001-20"} )
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Marlim Azul comércio de petróleo e derivados LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"39.825.435/0012-63"} )     
		     AAdd( aCnpjPaf, {"39.825.435/0013-44"} )         
		     
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³SODIBA DISTRIBUIDORA DE BATERIAS AJAX LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"03.976.750/0001-91"} )       
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³Axxonal Máquinas Ferragens e Ferramentas Ltda. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		     AAdd( aCnpjPaf, {"04.930.480/0001-40"} )       
	                                                 
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³SWAROVSKI CRISTAIS LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
		   AAdd( aCnpjPaf, {"00.727.262/0014-77"} )  
		   AAdd( aCnpjPaf, {"00.727.262/0007-48"} ) // UF : RJ
		   AAdd( aCnpjPaf, {"00.727.262/0009-00"} ) // UF : RJ  
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³KRIATIVA EXPOSITORES LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   AAdd( aCnpjPaf, {"00.079.057/0001-28"} )
		   AAdd( aCnpjPaf, {"00.079.057/0002-09"} )   
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³SAN MARINO SERVICOS E PARTICIPACOES LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		   AAdd( aCnpjPaf, {"07.342.260/0001-94"} )                                                 
		   
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³AGROINSUMOS LTDA. ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		   AAdd( aCnpjPaf, {"03.738.541/0002-90"} )
		   AAdd( aCnpjPaf, {"03.738.541/0001-00"} )   
		   AAdd( aCnpjPaf, {"03.817.383/0001-83"} )      
		   AAdd( aCnpjPaf, {"05.642.271/0001-64"} )
		   AAdd( aCnpjPaf, {"05.648.095/0001-78"} )
		   AAdd( aCnpjPaf, {"05.780.767/0001-02"} ) 
		   AAdd( aCnpjPaf, {"05.876.680/0001-25"} )
		   AAdd( aCnpjPaf, {"05.634.329/0002-09"} )
		   AAdd( aCnpjPaf, {"05.634.329/0010-19"} )
		   AAdd( aCnpjPaf, {"05.634.329/0011-08"} )   
		   AAdd( aCnpjPaf, {"05.780.767/0003-66"} )
		   AAdd( aCnpjPaf, {"05.642.271/0003-26"} )   
		   AAdd( aCnpjPaf, {"05.642.271/0002-45"} )
		   AAdd( aCnpjPaf, {"05.780.767/0002-85"} )
		   AAdd( aCnpjPaf, {"05.634.329/0006-32"} )
		   AAdd( aCnpjPaf, {"05.634.329/0008-02"} )            
		   AAdd( aCnpjPaf, {"05.574.282/0001-54"} )
		   AAdd( aCnpjPaf, {"05.574.282/0003-16"} )                                           
		   AAdd( aCnpjPaf, {"06.850.173/0002-66"} )
		   AAdd( aCnpjPaf, {"06.850.173/0003-47"} )
		   AAdd( aCnpjPaf, {"06.850.173/0001-85"} )   
		   AAdd( aCnpjPaf, {"07.340.850/0001-88"} )
		   AAdd( aCnpjPaf, {"09.314.307/0001-31"} )
		   AAdd( aCnpjPaf, {"31.816.515/0004-30"} )
		   AAdd( aCnpjPaf, {"31.816.515/0006-00"} )   
		   AAdd( aCnpjPaf, {"31.816.515/0001-98"} )
		
			AAdd( aCnpjPaf, {"01.637.001/0001-04"} )
			AAdd( aCnpjPaf, {"03.390.386/0001-83"} )
			AAdd( aCnpjPaf, {"03.390.386/0002-64"} )
			AAdd( aCnpjPaf, {"03.390.386/0003-45"} )
			AAdd( aCnpjPaf, {"04.273.027/0001-09"} )
			AAdd( aCnpjPaf, {"04.399.595/0001-50"} )
			AAdd( aCnpjPaf, {"04.461.614/0003-93"} )
			AAdd( aCnpjPaf, {"04.791.160/0001-57"} )
			AAdd( aCnpjPaf, {"05.086.378/0001-73"} )
			AAdd( aCnpjPaf, {"05.460.864/0001-00"} )
			AAdd( aCnpjPaf, {"05.460.864/0001-00"} )
			AAdd( aCnpjPaf, {"05.460.864/0002-90"} )
			AAdd( aCnpjPaf, {"05.460.864/0002-90"} )
			AAdd( aCnpjPaf, {"05.560.924/0001-66"} )
			AAdd( aCnpjPaf, {"05.574.282/0004-05"} )
			AAdd( aCnpjPaf, {"05.574.282/0005-88"} )
			AAdd( aCnpjPaf, {"05.574.282/0006-69"} )
			AAdd( aCnpjPaf, {"05.574.282/0007-40"} )
			AAdd( aCnpjPaf, {"05.574.282/0008-20"} )
			AAdd( aCnpjPaf, {"05.574.282/0009-01"} )
			AAdd( aCnpjPaf, {"05.634.329/0001-28"} )
			AAdd( aCnpjPaf, {"05.634.329/0005-51"} )
			AAdd( aCnpjPaf, {"05.634.329/0007-13"} )
			AAdd( aCnpjPaf, {"05.634.329/0012-80"} )
			AAdd( aCnpjPaf, {"08.039.483/0001-40"} )
			AAdd( aCnpjPaf, {"08.210.806/0001-16"} )
			AAdd( aCnpjPaf, {"08.210.806/0002-05"} )
			AAdd( aCnpjPaf, {"12.144.590/0001-05"} )
			AAdd( aCnpjPaf, {"12.144.590/0003-77"} )
			AAdd( aCnpjPaf, {"12.702.241/0001-61"} )
			AAdd( aCnpjPaf, {"13.201.734/0001-80"} )      
		            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Renovadora de Pneus OK Ltda. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
		 	AAdd( aCnpjPaf, {"12.268.876/0001-00"} )
			AAdd( aCnpjPaf, {"12.268.876/0004-45"} )   
		   
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³J BATTIROLA CIA LTDA . ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		  AAdd( aCnpjPaf, {"83.684.910/0001-68"} ) 
		  AAdd( aCnpjPaf, {"83.684.910/0002-49"} ) 
		  AAdd( aCnpjPaf, {"83.684.910/0003-20"} ) 
		    
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³BESTCOMP COMPUTADORES LTDA. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		  AAdd( aCnpjPaf, {"05.892.610/0001-60"} ) 
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³PEIXOTO GONCALVES S/A INDUSTRIA E COMERCIO. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
		  AAdd( aCnpjPaf, {"13.342.076/0001-47"} )    // PEIXOTO GONCALVES S/A INDUSTRIA E COMERCIO
		  AAdd( aCnpjPaf, {"13.342.076/0007-32"} )    // PEIXOTO GONCALVES S/A INDUSTRIA E COMERCIO
		  AAdd( aCnpjPaf, {"01.580.289/0001-28"} )    // J.C. DALES E CIA LTDA.
		  AAdd( aCnpjPaf, {"01.580.289/0002-09"} )
		  AAdd( aCnpjPaf, {"01.580.289/0003-90"} )
		  AAdd( aCnpjPaf, {"01.580.289/0004-70"} )
		  AAdd( aCnpjPaf, {"01.580.289/0005-51"} )
		  AAdd( aCnpjPaf, {"01.580.289/0006-32"} )
		  AAdd( aCnpjPaf, {"01.580.289/0007-13"} )
		  AAdd( aCnpjPaf, {"01.580.289/0008-02"} )
		  AAdd( aCnpjPaf, {"01.580.289/0009-85"} )
		  AAdd( aCnpjPaf, {"01.580.289/0010-19"} )
		  AAdd( aCnpjPaf, {"01.580.289/0011-08"} )
		  AAdd( aCnpjPaf, {"01.580.289/0012-80"} )
		  AAdd( aCnpjPaf, {"01.580.289/0014-42"} )	// JC DALLES & CIA LTDA  
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³THAYSE SAMPAIO OLIVEIRA ME. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
		  AAdd( aCnpjPaf, {"06.926.106/0001-05"} )
		  
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³EDITORA DO BRASIL S/A. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  AAdd( aCnpjPaf, {"60.657.574/0001-69"} )
		  AAdd( aCnpjPaf, {"60.657.574/0030-01"} )
		  AAdd( aCnpjPaf, {"60.657.574/0031-84"} )
		  AAdd( aCnpjPaf, {"60.657.574/0032-65"} )
		  AAdd( aCnpjPaf, {"60.657.574/0002-40"} )
		  AAdd( aCnpjPaf, {"60.657.574/0034-27"} )
		  AAdd( aCnpjPaf, {"60.657.574/0035-08"} )
		  AAdd( aCnpjPaf, {"60.657.574/0003-20"} )
		  AAdd( aCnpjPaf, {"60.657.574/0007-54"} )
		  
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³Comercial Agro Industrial Ltda. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		 AAdd( aCnpjPaf, {"04.221.051/0001-02"} )
		 AAdd( aCnpjPaf, {"04.221.051/0004-47"} )
		 AAdd( aCnpjPaf, {"04.221.051/0003-66"} )
		 AAdd( aCnpjPaf, {"04.221.051/0002-85"} )
		 AAdd( aCnpjPaf, {"04.221.051/0005-28"} )
		 AAdd( aCnpjPaf, {"04.221.051/0006-09"} )
		 AAdd( aCnpjPaf, {"04.221.051/0008-70"} )
		 AAdd( aCnpjPaf, {"04.221.051/0009-51"} )
		 AAdd( aCnpjPaf, {"04.221.051/0010-95"} ) 
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³Razão: CJ MUHLMANN ME ³
		 //³EDITORA FTD S/A.      ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		 AAdd( aCnpjPaf, {"03.640.213/0001-76"} )
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³MATTHEIS BORG ADM.PART.COM. EIND LTDA. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		 AAdd( aCnpjPaf, {"30.240.931/0001-28"} )
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³IDREAM LTDA - EPP. ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		 AAdd( aCnpjPaf, {"12.351.893/0001-07"} )    
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³FUNDACAO JOAO PAULO II - V.CONQUISTA.  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		 AAdd( aCnpjPaf, {"50.016.039/0051-34"} ) 
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³Juagro Comercio e Representações LTDA.  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		 AAdd( aCnpjPaf, {"96.832.076/0001-52"} )
		 AAdd( aCnpjPaf, {"96.832 076/0003-14"} )
		 AAdd( aCnpjPaf, {"96.832.076/0006-67"} )
		 AAdd( aCnpjPaf, {"96.832.076/0010-43"} )
		 AAdd( aCnpjPaf, {"96.832.076/0007-48"} )  
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³LOUIS VUITTON DISTRIBUICAO LTDA - LVMH FASHION GROUP BRASIL LTDA ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		  AAdd( aCnpjPaf, {"32.331.472/0012-76"} )
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³CURINGA DOS PNEUS LTDA.   ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.041.327/0010-00"} )
			AAdd( aCnpjPaf, {"00.041.327/0018-50"} )
			AAdd( aCnpjPaf, {"00.041.327/0025-89"} )
			AAdd( aCnpjPaf, {"00.041.327/0026-60"} )
			AAdd( aCnpjPaf, {"00.041.327/0027-40"} )
			AAdd( aCnpjPaf, {"00.041.327/0002-92"} )
			AAdd( aCnpjPaf, {"00.041.327/0028-21"} )
			AAdd( aCnpjPaf, {"00.041.327/0029-02"} )
			AAdd( aCnpjPaf, {"00.041.327/0030-46"} )
			AAdd( aCnpjPaf, {"00.041.327/0034-70"} )
			AAdd( aCnpjPaf, {"00.041.327/0036-31"} )
			AAdd( aCnpjPaf, {"00.041.327/0037-12"} )
			AAdd( aCnpjPaf, {"00.041.327/0035-50"} )
			AAdd( aCnpjPaf, {"00.041.327/0046-03"} )
			AAdd( aCnpjPaf, {"00.041.327/0048-75"} )
			AAdd( aCnpjPaf, {"00.041.327/0047-94"} )
			AAdd( aCnpjPaf, {"00.041.327/0050-90"} )
			AAdd( aCnpjPaf, {"00.041.327/0051-70"} )
			AAdd( aCnpjPaf, {"00.041.327/0053-32"} )
			AAdd( aCnpjPaf, {"00.041.327/0017-79"} )
			AAdd( aCnpjPaf, {"00.041.327/0003-73"} )
			AAdd( aCnpjPaf, {"00.041.327/0008-88"} )
			AAdd( aCnpjPaf, {"00.041.327/0006-16"} )
			AAdd( aCnpjPaf, {"00.041.327/0013-45"} )
			AAdd( aCnpjPaf, {"00.041.327/0015-07"} )
			AAdd( aCnpjPaf, {"00.041.327/0016-98"} )
			AAdd( aCnpjPaf, {"00.041.327/0023-17"} )
			AAdd( aCnpjPaf, {"00.041.327/0024-06"} )
			AAdd( aCnpjPaf, {"00.041.327/0031-27"} )
			AAdd( aCnpjPaf, {"00.041.327/0035-50"} )
			AAdd( aCnpjPaf, {"00.041.327/0039-84"} )
			AAdd( aCnpjPaf, {"00.041.327/0044-41"} )
			AAdd( aCnpjPaf, {"00.041.327/0054-13"} )		
		 
		 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FRIOTRANS COM. E TRANSP. DE CARGAS LTDA..   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			AAdd( aCnpjPaf, {"07.552.901/0001-35"} )
			AAdd( aCnpjPaf, {"03.838.437/0001-97"} )
			AAdd( aCnpjPaf, {"03.838.437/0004-30"} )
			AAdd( aCnpjPaf, {"07.552.901/0003-05"} )
			AAdd( aCnpjPaf, {"03.838.437/0006-00"} )
			AAdd( aCnpjPaf, {"07.552.901/0004-88"} )
			AAdd( aCnpjPaf, {"03.838.437/0002-78"} )
			AAdd( aCnpjPaf, {"07.552.901/0008-01"} )
			AAdd( aCnpjPaf, {"07.552.901/0006-40"} )
			AAdd( aCnpjPaf, {"07.552.901/0007-20"} ) 
			AAdd( aCnpjPaf, {"07.552.901/0005-69"} )
			AAdd( aCnpjPaf, {"07.552.901/0009-92"} )
			AAdd( aCnpjPaf, {"12.605.561/0001-01"} ) // HERNANDES COMERCIO E TRANSPORTE LTDA	
			AAdd( aCnpjPaf, {"07.552.901/0010-26"} )
		
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³CASA DO LAVRADOR PRODUTOS AGRICOLAS LTDA.   ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		 AAdd( aCnpjPaf, {"09.268.250/0001-81"} )
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³SODIBA DISTRIBUIDORA DE BATERIAS AJAX LTDA  ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 AAdd( aCnpjPaf, {"03.976.750/0001-91"} )          
		 
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³OXIDAVILACOMERCIAL E TRANSPORTES LTDA    ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
		 AAdd( aCnpjPaf, {"12.343.942/0001-51"} )  
		         
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³DROGARIA GENERICA LTDA.    ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
			 AAdd( aCnpjPaf, {"03.658.904/0001-05"} )  
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³POLO NORTE IND COM DE REFRIGERACAO LTDA  ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
			 AAdd( aCnpjPaf, {"22.767.800/0001-75"} ) 
			 AAdd( aCnpjPaf, {"22.767.800/0002-56"} ) 
			 AAdd( aCnpjPaf, {"22.767.800/0004-18"} )   
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³CONÇALVES ASSIS LTDA.      ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
			 AAdd( aCnpjPaf, {"02.620.931/0001-18"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0002-07"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0004-60"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0005-41"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0006-22"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0007-03"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0008-94"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0009-75"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0010-09"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0012-70"} )  //Pernambuco
			 AAdd( aCnpjPaf, {"02.620.931/0003-80"} )  // Paraíba
			 AAdd( aCnpjPaf, {"02.620.931/0001-18"} )  // Paraíba
			 AAdd( aCnpjPaf, {"02.620.931/0002-07"} )
			 AAdd( aCnpjPaf, {"02.620.931/0011-90"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Partners Air.              ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"07.803.085/0001-95"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³HOSPITALIA PRODUTOS PARA SAUDE LTDA.  ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"10.704.623/0001-07"} )     
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³EMPACOTADORA AGUIAR LTDA.  ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"09.083.780/0001-55"} )  
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³URBANO AGROINDUSTRIAL LTDA.³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"84.432.111/0001-67"} ) 
			 AAdd( aCnpjPaf, {"84.432.111/0008-33"} )  
		
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³FORMULA COM. IMP.E REPRESENTACAO LTDA.³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"00.629.107/0001-01"} )    
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³MDC AGREGADOS LTDA  ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"07.912.650/0002-33"} ) 
			 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MIR IMPORTACAO E EXPORTACAO LTDA.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			AAdd( aCnpjPaf, {"03.341.024/0001-00"} )
			AAdd( aCnpjPaf, {"03.341.024/0015-06"} )
			AAdd( aCnpjPaf, {"03.341.024/0019-21"} )
			AAdd( aCnpjPaf, {"03.341.024/0002-83"} )
			AAdd( aCnpjPaf, {"03.341.024/0003-64"} )
			AAdd( aCnpjPaf, {"03.341.024/0004-45"} )
			AAdd( aCnpjPaf, {"03.341.024/0005-26"} )
			AAdd( aCnpjPaf, {"03.341.024/0006-07"} )
			AAdd( aCnpjPaf, {"03.341.024/0007-98"} )
			AAdd( aCnpjPaf, {"03.341.024/0008-79"} )
			AAdd( aCnpjPaf, {"03.341.024/0009-50"} )
			AAdd( aCnpjPaf, {"03.341.024/0010-93"} )
			AAdd( aCnpjPaf, {"03.341.024/0011-74"} )
			AAdd( aCnpjPaf, {"03.341.024/0012-55"} )
			AAdd( aCnpjPaf, {"03.341.024/0013-36"} )
			AAdd( aCnpjPaf, {"03.341.024/0014-17"} )
			AAdd( aCnpjPaf, {"03.341.024/0016-89"} )
			AAdd( aCnpjPaf, {"03.341.024/0017-60"} )
			AAdd( aCnpjPaf, {"03.341.024/0018-40"} )
			 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³IPABRAC LTDA  ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"25.631.151/0001-79"} ) 
			 AAdd( aCnpjPaf, {"25.631.151/0002-50"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³TE GUIMAES ARTEFATOS DE COURO LTDA.   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"23.290.117/0001-52"} ) 	  
			                                          
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SOM AND SOM IMPORTACAO LTDA.   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"84.537.265/0001-13"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³STUDIO TRAMA LTDA.   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"04.597.587/0002-08"} ) 
			 AAdd( aCnpjPaf, {"04.597.587/0001-19"} )   
		 	 AAdd( aCnpjPaf, {"85.227.221/0001-50"} )   
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³INFO STORE COMPUTADORES DA AMAZONIA LTDA.   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"02.337.524/0005-21"} )
			 AAdd( aCnpjPaf, {"02.337.524/0006-02"} )
			 AAdd( aCnpjPaf, {"02.337.524/0007-93"} )
			 AAdd( aCnpjPaf, {"02.337.524/0001-06"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³GURUPY COMERCIAL LTDA.   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"84.097.633/0001-50"} )    
			 AAdd( aCnpjPaf, {"84.097.633/0004-00"} )
			 AAdd( aCnpjPaf, {"84.097.633/0005-83"} )
			 AAdd( aCnpjPaf, {"84.097.633/0003-11"} )
			 AAdd( aCnpjPaf, {"84.097.633/0002-30"} )	 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³A R F REIS. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"06.126.291/0001-45"} ) 
			 AAdd( aCnpjPaf, {"06.126.291/0002-26"} )
			 AAdd( aCnpjPaf, {"06.126.291/0003-07"} ) 
			 AAdd( aCnpjPaf, {"06.126.291/0004-98"} ) 	  
			 AAdd( aCnpjPaf, {"06.126.291/0005-79"} )
		     AAdd( aCnpjPaf, {"06.126.291/0007-30"} )
			 AAdd( aCnpjPaf, {"06.126.291/0008-11"} )
		
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SOARES COMERCIO DE MATERIAIS EM GERAL LT.      ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"04.140.313/0001-04"} ) 
			 AAdd( aCnpjPaf, {"04.140.313/0002-87"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Cereais Bramil ltda. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			 AAdd( aCnpjPaf, {"32.296.378/0039-43"} )
		     AAdd( aCnpjPaf, {"32.296.378/0013-04"} )
		     AAdd( aCnpjPaf, {"32.296.378/0017-38"} )
		     AAdd( aCnpjPaf, {"32.296.378/0025-48"} ) 
		     AAdd( aCnpjPaf, {"32.296.378/0001-70"} )
		     AAdd( aCnpjPaf, {"32.296.378/0036-09"} )
		     AAdd( aCnpjPaf, {"32.296.378/0042-49"} )
			                                                 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³CENTRO SUL INFORMATICA LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
			 AAdd( aCnpjPaf, {"05.418.035/0001-69"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³MACOMAR COMERCIO DE ALIMENTOS LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
			 AAdd( aCnpjPaf, {"00.928.396/0008-08"} )  
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ELETRICA COMERCIAL ANDRA LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
			 AAdd( aCnpjPaf, {"47.674.429/0005-51"} )  
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SOCIAL MIDIA INFORMATICA LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
			 AAdd( aCnpjPaf, {"04.827.592/0001-70"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³MICREL BENFIO TEXTIL LTDA.     ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 AAdd( aCnpjPaf, {"35.027.945/0003-43"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³COOPERATIVA AGROPECUARIA MISTA DE PIRACANJUBA - COAPIL ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"02.447.928/0005-78"} )
			 AAdd( aCnpjPaf, {"02.447.928/0001-44"} )
			 AAdd( aCnpjPaf, {"02.447.928/0002-25"} )
			 AAdd( aCnpjPaf, {"02.447.928/0007-30"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SANRIO DO BRASIL COMERCIO E REPRESENTACOES ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"57.170.771/0001-44"} )    
	
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³UNIMED UBERABA COOPERATIVA DE TRABALHO MEDICO LTDA.³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"17.774.738/0002-90"} )   
		                        
		     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³TELLES CALCADOS LTDA EPP ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"81.610.461/0001-88"} )  
			 AAdd( aCnpjPaf, {"81.610.461/0003-40"} )
			 AAdd( aCnpjPaf, {"81.610.461/0004-20"} )
			 AAdd( aCnpjPaf, {"81.610.461/0005-01"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³PEDRO MUFFATO E CIA LTDA.³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"81.433.765/0023-22"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Marlisa Armarinhos Presentes e Utilidade³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"82.993.684/0001-34"} ) 
			 AAdd( aCnpjPaf, {"82.993.684/0003-04"} )
			 AAdd( aCnpjPaf, {"82.993.684/0004-87"} )
			 AAdd( aCnpjPaf, {"82.993.684/0005-68"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³FRASSON & SOUTO COMERCIO DE MAQUINAS E EQUIPAMENTOS LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"10.479.438/0001-58"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³COMERCIAL FRASSON LTDA. ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"02.537.589/0001-97"} ) 
			                                        
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³FRIGORIFICO NORDESTE ALIMENTOS LTDA ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"01.066.650/0001-00"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ATHLETIC WAY COM.EQUIP P/GIN.E FIS ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"86.736.568/0002-71"} )
			 AAdd( aCnpjPaf, {"86.736.568/0001-90"} )
			 AAdd( aCnpjPaf, {"86.736.568/0003-52"} )	
			 AAdd( aCnpjPaf, {"86.736.568/0004-33"} )
			 AAdd( aCnpjPaf, {"86.736.568/0005-14"} )
			 AAdd( aCnpjPaf, {"86.736.568/0007-86"} )
			 AAdd( aCnpjPaf, {"86.736.568/0008-67"} )
			 AAdd( aCnpjPaf, {"86.736.568/0009-48"} )
			 AAdd( aCnpjPaf, {"86.736.568/0010-81"} )
			 AAdd( aCnpjPaf, {"86.736.568/0011-62"} )
			 AAdd( aCnpjPaf, {"86.736.568/0014-05"} )
			 AAdd( aCnpjPaf, {"86.736.568/0015-96"} )
			 AAdd( aCnpjPaf, {"86.736.568/0017-58"} )
			 AAdd( aCnpjPaf, {"86.736.568/0018-39"} )
			 AAdd( aCnpjPaf, {"86.736.568/0019-10"} )
			 AAdd( aCnpjPaf, {"86.736.568/0020-53"} )
			 AAdd( aCnpjPaf, {"86.736.568/0021-34"} )
			 AAdd( aCnpjPaf, {"86.736.568/0022-15"} )      
			 AAdd( aCnpjPaf, {"86.736.568/0023-04"} )
			 AAdd( aCnpjPaf, {"86.736.568/0024-87"} )
			 AAdd( aCnpjPaf, {"86.736.568/0025-68"} )
			 AAdd( aCnpjPaf, {"86.736.568/0026-49"} )
			 AAdd( aCnpjPaf, {"86.736.568/0027-20"} )   
			 AAdd( aCnpjPaf, {"86.736.568/0028-00"} )
			 AAdd( aCnpjPaf, {"86.736.568/0029-91"} )
			 AAdd( aCnpjPaf, {"86.736.568/0029-91"} )
			 AAdd( aCnpjPaf, {"86.736.568/0030-25"} )
			 AAdd( aCnpjPaf, {"86.736.568/0031-06"} )
			 AAdd( aCnpjPaf, {"86.736.568/0032-97"} )
			 AAdd( aCnpjPaf, {"86.736.568/0033-78"} )
			 AAdd( aCnpjPaf, {"86.736.568/0034-59"} )
			 AAdd( aCnpjPaf, {"86.736.568/0035-30"} )
			 AAdd( aCnpjPaf, {"86.736.568/0036-10"} )
			 AAdd( aCnpjPaf, {"86.736.568/0037-00"} )
			 AAdd( aCnpjPaf, {"86.736.568/0038-82"} )
			 AAdd( aCnpjPaf, {"86.736.568/0039-63"} )
			 AAdd( aCnpjPaf, {"86.736.568/0040-05"} )
			 AAdd( aCnpjPaf, {"86.736.568/0041-88"} )
			 AAdd( aCnpjPaf, {"86.736.568/0042-69"} )
			 AAdd( aCnpjPaf, {"86.736.568/0043-40"} )
			 AAdd( aCnpjPaf, {"86.736.568/0044-20"} )
			 AAdd( aCnpjPaf, {"86.736.568/0045-01"} )
			 AAdd( aCnpjPaf, {"86.736.568/0046-92"} )
			 AAdd( aCnpjPaf, {"86.736.568/0047-73"} )
			 AAdd( aCnpjPaf, {"86.736.568/0003-50"} )
			 AAdd( aCnpjPaf, {"02.793.710/0001-41"} )
		     AAdd( aCnpjPaf, {"02.793.710/0002-22"} )
			 AAdd( aCnpjPaf, {"04.864.438/0001-79"} )
			 AAdd( aCnpjPaf, {"82.099.029/0001-37"} )
			 AAdd( aCnpjPaf, {"82.099.029/0003-07"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ACAO SOCIAL CLARETIANA ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"60.543.279/0006-96"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³INTER COATINGS COMERCIO E REPRESENTACOES LTDA ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"03.730.515/0001-35"} )
			 AAdd( aCnpjPaf, {"03.730.515/0002-16"} )
			 AAdd( aCnpjPaf, {"03.730.515/0003-05"} ) 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄ¿
			 //³AMAZON ACO³
			 //ÀÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"05.477.207/0001-05"} )
				
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³TOC FRIO ALIMENTOS LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"04.458.488/0001-56"} )
			 AAdd( aCnpjPaf, {"04.458.488/0002-37"} )
		
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SANTIAGO DISTRIBUIDORA DE PRODUTOS ALIMENTICIOS LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"08.781.231/0001-91"} )
		
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³TOC FRIO SORVETES LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"00.782.965/0001-83"} )
			 AAdd( aCnpjPaf, {"00.782.965/0002-64"} )
		
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³PIA SOCIEDADE DE SAO PAULO³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"61.287.546/0009-17"} )
			 AAdd( aCnpjPaf, {"61.287.546/0016-46"} )
			 AAdd( aCnpjPaf, {"61.287.546/0017-27"} )
			 AAdd( aCnpjPaf, {"61.287.546/0020-22"} )
			 AAdd( aCnpjPaf, {"61.287.546/0024-56"} )
			 AAdd( aCnpjPaf, {"61.287.546/0028-80"} )
			 AAdd( aCnpjPaf, {"61.287.546/0031-85"} )
			 AAdd( aCnpjPaf, {"61.287.546/0032-66"} )
			 AAdd( aCnpjPaf, {"61.287.546/0034-28"} )
			 AAdd( aCnpjPaf, {"61.287.546/0026-18"} )
			 AAdd( aCnpjPaf, {"61.287.546/0013-01"} )
			 AAdd( aCnpjPaf, {"61.287.546/0040-76"} )
			 AAdd( aCnpjPaf, {"61.287.546/0042-38"} )
			 AAdd( aCnpjPaf, {"61.287.546/0044-08"} )
			 	 	 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³SILIMED COMERCIO PROD. MED. HOSP. LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"03.448.093/0001-00"} )
			 AAdd( aCnpjPaf, {"03.448.093/0004-52"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³FABRICA DE MOVEIS MIDALA LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 AAdd( aCnpjPaf, {"26.357.368/0003-67"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³EMPRESA MIRANTE'S RESTAURANTES LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 AAdd( aCnpjPaf, {"85.183.531/0001-10"} )
			 AAdd( aCnpjPaf, {"85.183.531/0005-43"} )
			 AAdd( aCnpjPaf, {"03.740.690/0001-03"} )
		     AAdd( aCnpjPaf, {"03.740.690/0002-94"} )
			 AAdd( aCnpjPaf, {"03.884.337/0001-05"} )
		     AAdd( aCnpjPaf, {"03.884.337/0002-88"} )
		     AAdd( aCnpjPaf, {"03.884.328/0001-06"} )
			 AAdd( aCnpjPaf, {"03.884.328/0002-97"} )
			 AAdd( aCnpjPaf, {"00.641.376/0001-85"} )
			 AAdd( aCnpjPaf, {"04.778.485/0001-08"} )
			 AAdd( aCnpjPaf, {"04.778.485/0002-80"} )
		     AAdd( aCnpjPaf, {"00.641.376/0002-66"} )
			 AAdd( aCnpjPaf, {"03.884.337/0003-69"} )
			 AAdd( aCnpjPaf, {"19.164.425/0001-64"} )
		 	 AAdd( aCnpjPaf, {"19.164.425/0003-26"} )
		     AAdd( aCnpjPaf, {"19.164.425/0005-98"} )
			 AAdd( aCnpjPaf, {"03.178.849/0001-48"} )
			 AAdd( aCnpjPaf, {"26.260.638/0001-55"} )
			 AAdd( aCnpjPaf, {"26.260.638/0002-36"} )
			 AAdd( aCnpjPaf, {"26.260.638/0003-17"} )
			 AAdd( aCnpjPaf, {"26.357.368/0001-03"} )
			 AAdd( aCnpjPaf, {"26.357.368/0002-86"} )
			 AAdd( aCnpjPaf, {"26.357.368/0003-67"} )
			 AAdd( aCnpjPaf, {"05.036.460/0001-93"} )
			 AAdd( aCnpjPaf, {"05.036.460/0002-74"} )
			 AAdd( aCnpjPaf, {"05.036.460/0003-55"} )
			 AAdd( aCnpjPaf, {"07.102.776/0001-61"} )
			 AAdd( aCnpjPaf, {"09.522.083/0001-53"} )
			 AAdd( aCnpjPaf, {"09.522.083/0002-34"} )
			 AAdd( aCnpjPaf, {"11.078.464/0001-37"} )
			 AAdd( aCnpjPaf, {"11.881.312/0001-78"} )	 
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
			 //|NESTLE	BRASIL LTDA	  |
			 //³BOUTIQUE IPA - IPANEMA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 AAdd( aCnpjPaf, {"60.409.075/0137-26"} )
			 AAdd( aCnpjPaf, {"60.409.075/0216-64"} )
			 AAdd( aCnpjPaf, {"60.409.075/0226-36"} )
			 AAdd( aCnpjPaf, {"60.409.075/0229-89"} )
			 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³COMERCIAL TOTAL LTDA³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 AAdd( aCnpjPaf, {"08.334.173/0001-58"} )	 
			 	   
			//--------------------------------
			//|Boutique BAR - Barra Shopping |
			//--------------------------------
			 AAdd( aCnpjPaf, {"60.409.075/0169-03"} )	 
		 
			//----------------------------------------
			//|MOTONORTE MOTORES E MAQ. DO NORTE LTDA|
			//+---------------------------------------
			 AAdd( aCnpjPaf, {"05.447.263.0001/67"} )	 
			 AAdd( aCnpjPaf, {"05.447.263/0002-48"} )
			 AAdd( aCnpjPaf, {"08.362.374/0001-69"} )
			 AAdd( aCnpjPaf, {"05.447.263/0003-29"} )
		
			//----------------------------------------
			//|STA COMERCIO DE PRODUTOS LTDA.        |
			//+---------------------------------------
			 AAdd( aCnpjPaf, {"12.595.333/0002-70"} )	 
		
			//------------------------------------------
			//| RODRIGO DE SOUZA - EPP                 |
			//+----------------------------------------+
			AAdd( aCnpjPaf, {"01.084.661/0001-05"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DFM EMBALAGENS PLASTICAS LTDA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			AAdd( aCnpjPaf, {"07.281.492/0001-80"} )  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMO SCHINCARIOL IND DE CERVEJAS E REFRIGERANTES S/A³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"50.221.019/0001-36"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³OTICA DA GENTE LTDA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.393.406/0001-32"} )
		 	AAdd( aCnpjPaf, {"04.393.406/0002-13"} )
			AAdd( aCnpjPaf, {"04.393.406/0003-02"} )
			AAdd( aCnpjPaf, {"04.393.406/0004-85"} )
			AAdd( aCnpjPaf, {"04.393.406/0005-66"} )
			AAdd( aCnpjPaf, {"04.393.406/0006-47"} )
			AAdd( aCnpjPaf, {"04.393.406/0007-28"} )
			AAdd( aCnpjPaf, {"04.393.406/0008-09"} )
			AAdd( aCnpjPaf, {"04.393.406/0009-90"} )	
			AAdd( aCnpjPaf, {"04.393.406/0010-23"} )
			AAdd( aCnpjPaf, {"04.393.406/0011-04"} )
			AAdd( aCnpjPaf, {"04.393.406/0012-95"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³BIGATAO & CALDERAN LTDA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.963.023/0001-27"} )   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PLAZA I LTDA           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.509.693/0001-42"} )   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PLAZA II LTDA          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.509.693/0003-04"} )   
			
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CALCADOS ITAPUA SA CISA   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"27.177.096/0128-05"} ) 
			AAdd( aCnpjPaf, {"27.177.096/0119-06"} )
			AAdd( aCnpjPaf, {"27.177.096/0063-17"} )
			AAdd( aCnpjPaf, {"27.177.096/0082-80"} )
			AAdd( aCnpjPaf, {"27.177.096/0096-85"} )
			AAdd( aCnpjPaf, {"27.177.096/0014-39"} )
			AAdd( aCnpjPaf, {"27.177.096/0130-11"} )
			AAdd( aCnpjPaf, {"27.177.096/0127-16"} )
			AAdd( aCnpjPaf, {"27.177.096/0128-05"} )
			AAdd( aCnpjPaf, {"27.177.096/0129-88"} )
			AAdd( aCnpjPaf, {"27.177.096/0075-50"} )
			AAdd( aCnpjPaf, {"27.177.096/0144-17"} )
			AAdd( aCnpjPaf, {"27.177.096/0148-40"} )
			AAdd( aCnpjPaf, {"27.177.096/0143-36"} )
			AAdd( aCnpjPaf, {"27.177.096/0131-00"} )
			AAdd( aCnpjPaf, {"27.177.096/0147-60"} )
			AAdd( aCnpjPaf, {"27.177.096/0158-12"} )
			AAdd( aCnpjPaf, {"27.177.096/0151-46"} )
			AAdd( aCnpjPaf, {"27.177.096/0153-08"} )
			AAdd( aCnpjPaf, {"27.177.096/0156-50"} )
			AAdd( aCnpjPaf, {"27.177.096/0037-25"} )
			AAdd( aCnpjPaf, {"27.177.096/0024-00"} )
			AAdd( aCnpjPaf, {"27.177.096/0034-82"} )
			AAdd( aCnpjPaf, {"27.177.096/0018-62"} )
			AAdd( aCnpjPaf, {"27.177.096/0081-07"} )
			AAdd( aCnpjPaf, {"27.177.096/0171-90"} )
			AAdd( aCnpjPaf, {"27.177.096/0002-03"} )
			AAdd( aCnpjPaf, {"27.177.096/0016-09"} )
			AAdd( aCnpjPaf, {"27.177.096/0018-62"} )
			AAdd( aCnpjPaf, {"27.177.096/0019-43"} )
			AAdd( aCnpjPaf, {"27.177.096/0034-82"} )
			AAdd( aCnpjPaf, {"27.177.096/0024-00"} )
			AAdd( aCnpjPaf, {"27.177.096/0026-72"} )
			AAdd( aCnpjPaf, {"27.177.096/0027-53"} )
			AAdd( aCnpjPaf, {"27.177.096/0032-10"} )
			AAdd( aCnpjPaf, {"27.177.096/0033-00"} )
			AAdd( aCnpjPaf, {"27.177.096/0037-25"} )
			AAdd( aCnpjPaf, {"27.177.096/0035-63"} )
			AAdd( aCnpjPaf, {"27.177.096/0038-06"} )
			AAdd( aCnpjPaf, {"27.177.096/0040-20"} )
			AAdd( aCnpjPaf, {"27.177.096/0043-73"} )
			AAdd( aCnpjPaf, {"27.177.096/0017-81"} )
			AAdd( aCnpjPaf, {"27.177.096/0047-05"} )
			AAdd( aCnpjPaf, {"27.177.096/0015-10"} )
			AAdd( aCnpjPaf, {"27.177.096/0003-86"} )
			AAdd( aCnpjPaf, {"27.177.096/0053-45"} )
			AAdd( aCnpjPaf, {"27.177.096/0056-98"} )
			AAdd( aCnpjPaf, {"27.177.096/0029-15"} )
			AAdd( aCnpjPaf, {"27.177.096/0013-58"} )
			AAdd( aCnpjPaf, {"27.177.096/0067-40"} )
			AAdd( aCnpjPaf, {"27.177.096/0069-02"} )
			AAdd( aCnpjPaf, {"27.177.096/0084-41"} )
			AAdd( aCnpjPaf, {"27.177.096/0064-06"} )
			AAdd( aCnpjPaf, {"27.177.096/0022-49"} )
			AAdd( aCnpjPaf, {"27.177.096/0010-05"} )
			AAdd( aCnpjPaf, {"27.177.096/0081-07"} )
			AAdd( aCnpjPaf, {"27.177.096/0011-96"} )
			AAdd( aCnpjPaf, {"27.177.096/0104-20"} )
			AAdd( aCnpjPaf, {"27.177.096/0119-06"} )
			AAdd( aCnpjPaf, {"27.177.096/0117-44"} )
			AAdd( aCnpjPaf, {"27.177.096/0023-20"} )
			AAdd( aCnpjPaf, {"27.177.096/0145-06"} )
			AAdd( aCnpjPaf, {"27.177.096/0080-18"} )
			AAdd( aCnpjPaf, {"27.177.096/0142-55"} )
			AAdd( aCnpjPaf, {"27.177.096/0155-70"} )
			AAdd( aCnpjPaf, {"27.177.096/0149-21"} )
			AAdd( aCnpjPaf, {"27.177.096/0154-99"} )
			AAdd( aCnpjPaf, {"27.177.096/0157-31"} )
			AAdd( aCnpjPaf, {"27.177.096/0164-60"} )
			AAdd( aCnpjPaf, {"27.177.096/0165-41"} )
			AAdd( aCnpjPaf, {"27.177.096/0169-75"} )
			AAdd( aCnpjPaf, {"27.177.096/0166-22"} )
			AAdd( aCnpjPaf, {"27.177.096/0170-09"} )
			AAdd( aCnpjPaf, {"27.177.096/0167-03"} )
			AAdd( aCnpjPaf, {"27.177.096/0168-94"} )		
					
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REQUINTE COMERCIAL   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.099.193/0008-44"} )    
			
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³JET TECH COMÉRCIO IMPORTAÇÃO E EXPORTAÇÃO LTDA   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.416.137/0001-10"} )    	 
			                                                 
			AAdd( aCnpjPaf, {"07.531.806/0001-55"} )   // Riva Comércio de JetSki Importação e Exportação LTDA
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³RICSEN LTDA. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"80.382.054/0005-21"} )	
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³AUTO PEÇAS ALONSO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"31.474.836/0001-51"} )		
			AAdd( aCnpjPaf, {"31.474.836/0004-02"} )		
			AAdd( aCnpjPaf, {"31.474.836/0005-85"} )		
			AAdd( aCnpjPaf, {"31.474.836/0006-66"} )
			AAdd( aCnpjPaf, {"03.682.180/0001-27"} ) // EDGAR AUTO PECAS LTDA 
			AAdd( aCnpjPaf, {"10.593.098/0001-91"} ) // E.LOMBAS DA SILVA ME 
			AAdd( aCnpjPaf, {"03.421.489/0001-63"} ) // IRUPI AUTO PECAS LTDA
			AAdd( aCnpjPaf, {"03.715.749/0001-03"} ) // EDGAR AUTO PECAS IUNA LTDA 
			AAdd( aCnpjPaf, {"31.474.836/0001-51"} )
			AAdd( aCnpjPaf, {"31.474.836/0004-02"} )
			AAdd( aCnpjPaf, {"31.474.836/0005-85"} )
			AAdd( aCnpjPaf, {"31.474.836/0006-66"} )
			 	
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ALONSO MATERIAL DE CONSTRUCAO   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.528.859/0001-30"} )			
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MIX MATERIAL DE CONSTRUCAO   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"05.806.210/0001-95"} )				
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MUNIZ CAR REVENDEDORA DE AUTOMOVEIS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.365.779/0001-13"} )	
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ALONSO & FILHOS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"31.786.858/0001-57"} )		
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CAJADINA TEXTIL LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"72.170.392/0001-48"} )			
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³OLYMPIA DE FRIBURGO TEXTIL LTDA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.257.198/0001-68"} )				
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³COMERCIAL JOMART LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.152.804/0001-58"} ) // MERVIL MERCANTIL VIEIRA LTDA				
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³INSTITUTO DE ORTOPEDIA E FISIOTERAPIA SAO PAULO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.447.737/0001-10"} )
			AAdd( aCnpjPaf, {"01.447.737/0005-43"} )
			AAdd( aCnpjPaf, {"01.447.737/0006-24"} ) 
		    AAdd( aCnpjPaf, {"01.447.737/0011-91"} )
		    AAdd( aCnpjPaf, {"01.447.737/0012-72"} )
		    AAdd( aCnpjPaf, {"01.447.737/0004-62"} )
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VICENTE PEDROSA & IRMãOS LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"23.062.698/0008-41"} )
		    AAdd( aCnpjPaf, {"23.062.698/0001-75"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0002-56"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0003-37"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0004-18"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0005-07"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0006-80"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0007-60"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0009-22"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0010-66"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0011-47"} ) 
		    AAdd( aCnpjPaf, {"23.062.698/0012-28"} ) 
		    AAdd( aCnpjPaf, {"01.485.100/0001-18"} ) 
		    AAdd( aCnpjPaf, {"04.625.030/0001-44"} ) 	
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³COOPERATIVA AGROPECUARIA UNAI LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"25.834.847/0005-26"} )	
			AAdd( aCnpjPaf, {"25.834.847/0016-89"} )
			AAdd( aCnpjPaf, {"25.834.847/0004-45"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³JVM INDUSTRIA E COMERCIO LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.288.906/0001-07"} )	
			AAdd( aCnpjPaf, {"10.288.906/0002-98"} )	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³BONANZA SUPERMERCADOS LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"07.649.462/0002-64"} )		
			AAdd( aCnpjPaf, {"07.649.462/0005-07"} )	
			AAdd( aCnpjPaf, {"07.649.462/0006-98"} )		
			AAdd( aCnpjPaf, {"12.023.966/0032-20"} )		 
		    AAdd( aCnpjPaf, {"07.649.462/0001-83"} )
		    AAdd( aCnpjPaf, {"12.023.966/0041-10"} )				
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³T.C. DIAS ME		³
			//³CARNEIRO			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"27.191.725/0001-60"} )	
			AAdd( aCnpjPaf, {"27.191.725/0008-37"} )  
			AAdd( aCnpjPaf, {"09.640.952/0001-44"} )  //S.C. DIAS
			AAdd( aCnpjPaf, {"08.843.433/0001-10"} )  //C.F. DIAS			
			AAdd( aCnpjPaf, {"08.995.340/0001-07"} )  //J.E.C. DIAS	
			AAdd( aCnpjPaf, {"08.854.909/0001-19"} )  //E.C. DIAS		
			AAdd( aCnpjPaf, {"10.643.141/0001-86"} )  //T.C. DIAS
			AAdd( aCnpjPaf, {"27.191.725/0011-32"} ) 
			AAdd( aCnpjPaf, {"27.191.725/0012-13"} )
			AAdd( aCnpjPaf, {"27.191.725/0013-02"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CIMAFERRO MATERIAIS PARA CONSTRUCAO LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"33.101.882/0002-11"} ) 			
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³AMWAY DO BRASIL LIMITADA - TRITON COMERCIO E INDUSTRIA DE OCULOS LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"58.473.398/0014-88"} )	
			AAdd( aCnpjPaf, {"58.473.398/0015-69"} )
			AAdd( aCnpjPaf, {"58.473.398/0016-40"} )
			
			AAdd( aCnpjPaf, {"45.526.795/0001-04"} )	
			AAdd( aCnpjPaf, {"45.526.795/0004-57"} )
			AAdd( aCnpjPaf, {"12.346.633/0001-35"} )	
			AAdd( aCnpjPaf, {"07.495.320/0001-09"} )	
			
			AAdd( aCnpjPaf, {"07.337.653/0001-00"} )
			AAdd( aCnpjPaf, {"07.337.653/0002-90"} )
			AAdd( aCnpjPaf, {"07.337.653/0003-71"} )	
			AAdd( aCnpjPaf, {"67.987.347/0001-40"} )
			
			AAdd( aCnpjPaf, {"67.987.347/0003-02"} )
			AAdd( aCnpjPaf, {"67.987.347/0004-93"} )	
			AAdd( aCnpjPaf, {"67.987.347/0005-74"} )
			AAdd( aCnpjPaf, {"67.987.347/0006-55"} )
			
			AAdd( aCnpjPaf, {"67.987.347/0007-36"} )	
			AAdd( aCnpjPaf, {"67.987.347/0008-17"} )
			AAdd( aCnpjPaf, {"67.987.347/0009-06"} )
			AAdd( aCnpjPaf, {"67.987.347/0010-31"} )	
			
			AAdd( aCnpjPaf, {"05.126.919/0001-40"} )
			AAdd( aCnpjPaf, {"05.126.919/0002-20"} )
			AAdd( aCnpjPaf, {"05.126.919/0003-01"} )	
			AAdd( aCnpjPaf, {"05.126.919/0004-92"} )
			
			AAdd( aCnpjPaf, {"05.126.919/0005-73"} )
			AAdd( aCnpjPaf, {"05.126.919/0006-54"} )	
			AAdd( aCnpjPaf, {"05.126.919/0007-35"} )
			AAdd( aCnpjPaf, {"05.126.919/0008-16"} )
			
			AAdd( aCnpjPaf, {"05.126.919/0009-05"} )	
			AAdd( aCnpjPaf, {"05.126.919/0010-30"} )
			AAdd( aCnpjPaf, {"05.126.919/0011-11"} )
			AAdd( aCnpjPaf, {"05.126.919/0012-00"} )	
			
			AAdd( aCnpjPaf, {"05.126.919/0013-83"} )
			AAdd( aCnpjPaf, {"05.672.526/0001-31"} )
			AAdd( aCnpjPaf, {"05.672.526/0002-12"} )	
			AAdd( aCnpjPaf, {"05.672.526/0003-01"} )
			
			AAdd( aCnpjPaf, {"05.672.526/0004-84"} )
			AAdd( aCnpjPaf, {"05.672.526/0005-65"} )	
			AAdd( aCnpjPaf, {"05.672.526/0006-46"} )
			AAdd( aCnpjPaf, {"05.672.526/0007-27"} )
			
			AAdd( aCnpjPaf, {"05.672.526/0008-08"} )	
			AAdd( aCnpjPaf, {"05.672.526/0009-99"} )
			AAdd( aCnpjPaf, {"05.672.526/0010-22"} )
			AAdd( aCnpjPaf, {"05.672.526/0011-03"} )	
			
			AAdd( aCnpjPaf, {"05.672.526/0012-94"} )
			AAdd( aCnpjPaf, {"05.672.526/0013-75"} )
			AAdd( aCnpjPaf, {"05.672.526/0014-76"} )	
			AAdd( aCnpjPaf, {"01.927.828/0001-52"} )
			
			AAdd( aCnpjPaf, {"01.927.828/0002-33"} )
			AAdd( aCnpjPaf, {"01.927.828/0003-14"} )	
			AAdd( aCnpjPaf, {"01.927.828/0004-03"} )
			AAdd( aCnpjPaf, {"01.927.828/0005-86"} )															
			
			AAdd( aCnpjPaf, {"01.927.828/0006-67"} )
			AAdd( aCnpjPaf, {"01.927.828/0007-48"} )
			AAdd( aCnpjPaf, {"01.927.828/0008-29"} )	
			AAdd( aCnpjPaf, {"01.927.828/0009-00"} )
			
			AAdd( aCnpjPaf, {"01.927.828/0010-43"} )
			AAdd( aCnpjPaf, {"01.927.828/0011-24"} )	
			AAdd( aCnpjPaf, {"01.927.828/0012-05"} )
			AAdd( aCnpjPaf, {"01.927.828/0013-96"} )															
			
			AAdd( aCnpjPaf, {"01.927.828/0014-77"} )
			AAdd( aCnpjPaf, {"01.927.828/0015-58"} )
			AAdd( aCnpjPaf, {"01.927.828/0016-39"} )	
			AAdd( aCnpjPaf, {"01.927.828/0017-10"} )
			
			AAdd( aCnpjPaf, {"00.079.592/0001-89"} )
			AAdd( aCnpjPaf, {"00.079.592/0002-60"} )	
			AAdd( aCnpjPaf, {"00.079.592/0003-40"} )
			AAdd( aCnpjPaf, {"00.079.592/0006-93"} )															
			
			AAdd( aCnpjPaf, {"00.079.592/0007-74"} )
			AAdd( aCnpjPaf, {"00.079.592/0008-55"} )
			AAdd( aCnpjPaf, {"00.079.592/0009-36"} )	
			AAdd( aCnpjPaf, {"00.079.592/0010-70"} )
			
			AAdd( aCnpjPaf, {"00.079.592/0011-50"} )
			AAdd( aCnpjPaf, {"00.079.592/0012-31"} )	
			AAdd( aCnpjPaf, {"00.079.592/0013-12"} )
			AAdd( aCnpjPaf, {"00.079.592/0014-01"} )															
			
			AAdd( aCnpjPaf, {"03.737.396/0001-42"} )
			AAdd( aCnpjPaf, {"03.737.396/0002-23"} )
			AAdd( aCnpjPaf, {"03.737.396/0003-04"} )	
			AAdd( aCnpjPaf, {"03.737.396/0004-95"} )
			
			AAdd( aCnpjPaf, {"03.737.396/0005-76"} )
			AAdd( aCnpjPaf, {"03.737.396/0006-57"} )	
			AAdd( aCnpjPaf, {"07.337.653/0001-00"} )
			AAdd( aCnpjPaf, {"07.337.653/0002-90"} )															
			AAdd( aCnpjPaf, {"07.337.653/0003-71"} )
		
			AAdd( aCnpjPaf, {"01.927.828/0020-15"} )
			AAdd( aCnpjPaf, {"01.927.828/0018-09"} )
			AAdd( aCnpjPaf, {"01.927.828/0019-81"} )
			AAdd( aCnpjPaf, {"45.526.795/0006-19"} )
			AAdd( aCnpjPaf, {"45.526.795/0007-08"} )
			AAdd( aCnpjPaf, {"45.526.795/0008-80"} )
			
			AAdd( aCnpjPaf, {"67.987.347/0003-02"} )
			AAdd( aCnpjPaf, {"67.987.347/0004-93"} )
			AAdd( aCnpjPaf, {"67.987.347/0005-74"} )
			AAdd( aCnpjPaf, {"67.987.347/0006-55"} )
			AAdd( aCnpjPaf, {"67.987.347/0007-36"} )
			AAdd( aCnpjPaf, {"67.987.347/0008-17"} )
			AAdd( aCnpjPaf, {"01.927.828/0002-33"} )
			AAdd( aCnpjPaf, {"01.927.828/0003-14"} )
			AAdd( aCnpjPaf, {"01.927.828/0004-03"} )
			AAdd( aCnpjPaf, {"01.927.828/0005-86"} )
			AAdd( aCnpjPaf, {"01.927.828/0006-67"} )
			AAdd( aCnpjPaf, {"01.927.828/0007-48"} )
			AAdd( aCnpjPaf, {"01.927.828/0008-29"} )
			AAdd( aCnpjPaf, {"00.079.592/0002-60"} )
			AAdd( aCnpjPaf, {"00.709.592/0003-40"} )
			AAdd( aCnpjPaf, {"00.079.592/0006-93"} )
			AAdd( aCnpjPaf, {"00.079.592/0008-55"} )
			AAdd( aCnpjPaf, {"00.079.592/0007-74"} )
			AAdd( aCnpjPaf, {"00.079.592/0009-36"} )
			AAdd( aCnpjPaf, {"00.079.592/0010-70"} )
			AAdd( aCnpjPaf, {"00.079.592/0011-50"} )
			AAdd( aCnpjPaf, {"00.079.592/0012-31"} )
			AAdd( aCnpjPaf, {"00.079.592/0013-12"} )
			AAdd( aCnpjPaf, {"00.079.592/0014-01"} )
			AAdd( aCnpjPaf, {"05.126.919/0001-40"} )
			AAdd( aCnpjPaf, {"05.126.919/0002-20"} )
			AAdd( aCnpjPaf, {"05.126.919/0003-01"} )
			AAdd( aCnpjPaf, {"05.126.919/0004-92"} )
			AAdd( aCnpjPaf, {"05.126.919/0005-73"} )
			AAdd( aCnpjPaf, {"05.126.919/0006-54"} )
			AAdd( aCnpjPaf, {"05.126.919/0007-35"} )
			AAdd( aCnpjPaf, {"05.126.919/0008-16"} )
			AAdd( aCnpjPaf, {"05.126.919/0009-05"} )
			AAdd( aCnpjPaf, {"05.126.919/0010-30"} )
			AAdd( aCnpjPaf, {"05.126.919/0011-11"} )
			AAdd( aCnpjPaf, {"05.126.919/0012-00"} )
			AAdd( aCnpjPaf, {"05.672.526/0001-31"} )
			AAdd( aCnpjPaf, {"05.672.526/0002-12"} )
			AAdd( aCnpjPaf, {"05.672.526/0003-01"} )
			AAdd( aCnpjPaf, {"05.672.526/0004-84"} )
			AAdd( aCnpjPaf, {"05.672.526/0005-65"} )
			AAdd( aCnpjPaf, {"05.672.526/0006-46"} )
			AAdd( aCnpjPaf, {"05.672.526/0007-27"} )
			AAdd( aCnpjPaf, {"05.672.526/0008-08"} )
			AAdd( aCnpjPaf, {"05.672.526/0009-99"} )
			AAdd( aCnpjPaf, {"05.672.526/0010-22"} )
			AAdd( aCnpjPaf, {"05.672.526/0011-03"} )
			AAdd( aCnpjPaf, {"05.672.526/0012-94"} )
			AAdd( aCnpjPaf, {"05.672.526/0013-75"} )
			AAdd( aCnpjPaf, {"05.672.526/0014-56"} )
			AAdd( aCnpjPaf, {"03.737.396/0002-23"} )
			AAdd( aCnpjPaf, {"03.737.396/0003-04"} )
			AAdd( aCnpjPaf, {"03.737.396/0004-95"} )
			AAdd( aCnpjPaf, {"03.737.396/0005-76"} )
			AAdd( aCnpjPaf, {"03.737.396/0006-57"} )
			AAdd( aCnpjPaf, {"67.987.347/0001-31"} )
			AAdd( aCnpjPaf, {"07.337.653/0002-90"} )
			AAdd( aCnpjPaf, {"07.337.653/0003-71"} )
			AAdd( aCnpjPaf, {"05.126.919/0013-83"} )
			AAdd( aCnpjPaf, {"01.927.828/0009-00"} )
			AAdd( aCnpjPaf, {"01.927.828/0010-43"} )
			AAdd( aCnpjPaf, {"01.927.828/0011-24"} )
			AAdd( aCnpjPaf, {"01.927.828/0015-58"} )
			AAdd( aCnpjPaf, {"01.927.828/0013-96"} )
			AAdd( aCnpjPaf, {"01.927.828/0014-77"} )
			AAdd( aCnpjPaf, {"01.927.828/0012-05"} )
			AAdd( aCnpjPaf, {"01.927.828/0016-39"} )
			AAdd( aCnpjPaf, {"01.927.828/0017-10"} )
			AAdd( aCnpjPaf, {"01.927.828/0020-15"} )
			AAdd( aCnpjPaf, {"01.927.828/0018-09"} )
			AAdd( aCnpjPaf, {"01.927.828/0019-81"} )
			AAdd( aCnpjPaf, {"01.927.828/0021-04"} )
			AAdd( aCnpjPaf, {"45.526.795/0004-57"} )
			AAdd( aCnpjPaf, {"45.526.795/0005-38"} )
			AAdd( aCnpjPaf, {"45.526.795/0006-19"} )
			AAdd( aCnpjPaf, {"45.526.795/0007-08"} )
			AAdd( aCnpjPaf, {"45.526.795/0008-80"} )
			AAdd( aCnpjPaf, {"45.526.795/0009-61"} )	
			AAdd( aCnpjPaf, {"45.526.795/0004-57"} )
			AAdd( aCnpjPaf, {"45.526.795/0005-38"} )
			AAdd( aCnpjPaf, {"45.526.795/0006-19"} )
			AAdd( aCnpjPaf, {"45.526.795/0007-08"} )
			AAdd( aCnpjPaf, {"45.526.795/0008-80"} )
			AAdd( aCnpjPaf, {"45.526.795/0009-61"} )
			AAdd( aCnpjPaf, {"45.526.795/0010-03"} )
			AAdd( aCnpjPaf, {"45.526.795/0011-86"} )
			AAdd( aCnpjPaf, {"45.526.795/0012-67"} )
			AAdd( aCnpjPaf, {"45.526.795/0013-48"} )
			AAdd( aCnpjPaf, {"45.526.795/0014-29"} )
			AAdd( aCnpjPaf, {"67.987.347/0003-02"} )
			AAdd( aCnpjPaf, {"67.987.347/0004-93"} )
			AAdd( aCnpjPaf, {"67.987.347/0005-74"} )
			AAdd( aCnpjPaf, {"67.987.347/0006-55"} )
			AAdd( aCnpjPaf, {"67.987.347/0007-36"} )
			AAdd( aCnpjPaf, {"67.987.347/0008-17"} )
			AAdd( aCnpjPaf, {"67.987.347/0009-06"} )
			AAdd( aCnpjPaf, {"67.987.347/0010-31"} )
			AAdd( aCnpjPaf, {"05.126.919/0001-40"} )
			AAdd( aCnpjPaf, {"05.126.919/0002-20"} )
			AAdd( aCnpjPaf, {"05.126.919/0003-01"} )
			AAdd( aCnpjPaf, {"05.126.919/0004-92"} )
			AAdd( aCnpjPaf, {"05.126.919/0005-73"} )
			AAdd( aCnpjPaf, {"05.126.919/0006-54"} )
			AAdd( aCnpjPaf, {"05.126.919/0007-35"} )
			AAdd( aCnpjPaf, {"05.126.919/0008-16"} )
			AAdd( aCnpjPaf, {"05.126.919/0009-05"} )
			AAdd( aCnpjPaf, {"05.126.919/0010-30"} )
			AAdd( aCnpjPaf, {"05.126.919/0011-11"} )
			AAdd( aCnpjPaf, {"05.126.919/0012-00"} )
			AAdd( aCnpjPaf, {"05.126.919/0013-83"} )
			AAdd( aCnpjPaf, {"05.672.526/0001-31"} )
			AAdd( aCnpjPaf, {"05.672.526/0002-12"} )
			AAdd( aCnpjPaf, {"05.672.526/0003-01"} )
			AAdd( aCnpjPaf, {"05.672.526/0004-84"} )
			AAdd( aCnpjPaf, {"05.672.526/0005-65"} )
			AAdd( aCnpjPaf, {"05.672.526/0006-46"} )
			AAdd( aCnpjPaf, {"05.672.526/0007-27"} )
			AAdd( aCnpjPaf, {"05.672.526/0008-08"} )
			AAdd( aCnpjPaf, {"05.672.526/0009-99"} )
			AAdd( aCnpjPaf, {"05.672.526/0010-22"} )
			AAdd( aCnpjPaf, {"05.672.526/0011-03"} )
			AAdd( aCnpjPaf, {"05.672.526/0012-94"} )
			AAdd( aCnpjPaf, {"05.672.526/0013-75"} )
			AAdd( aCnpjPaf, {"05.672.526/0014-76"} )
			AAdd( aCnpjPaf, {"01.927.828/0002-33"} )
			AAdd( aCnpjPaf, {"01.927.828/0003-14"} )
			AAdd( aCnpjPaf, {"01.927.828/0004-03"} )
			AAdd( aCnpjPaf, {"01.927.828/0005-86"} )
			AAdd( aCnpjPaf, {"01.927.828/0006-67"} )
			AAdd( aCnpjPaf, {"01.927.828/0007-48"} )
			AAdd( aCnpjPaf, {"01.927.828/0008-29"} )
			AAdd( aCnpjPaf, {"01.927.828/0009-00"} )
			AAdd( aCnpjPaf, {"01.927.828/0010-43"} )
			AAdd( aCnpjPaf, {"01.927.828/0011-24"} )
			AAdd( aCnpjPaf, {"01.927.828/0012-05"} )
			AAdd( aCnpjPaf, {"01.927.828/0013-96"} )
			AAdd( aCnpjPaf, {"01.927.828/0014-77"} )
			AAdd( aCnpjPaf, {"01.927.828/0015-58"} )
			AAdd( aCnpjPaf, {"01.927.828/0016-39"} )
			AAdd( aCnpjPaf, {"01.927.828/0017-10"} )
			AAdd( aCnpjPaf, {"01.927.828/0018-09"} )
			AAdd( aCnpjPaf, {"01.927.828/0019-81"} )
			AAdd( aCnpjPaf, {"01.927.828/0020-15"} )
			AAdd( aCnpjPaf, {"01.927.828/0021-04"} )
			AAdd( aCnpjPaf, {"00.079.592/0002-60"} )
			AAdd( aCnpjPaf, {"00.079.592/0003-40"} )
			AAdd( aCnpjPaf, {"00.079.592/0006-93"} )
			AAdd( aCnpjPaf, {"00.079.592/0007-74"} )
			AAdd( aCnpjPaf, {"00.079.592/0008-55"} )
			AAdd( aCnpjPaf, {"00.079.592/0009-36"} )
			AAdd( aCnpjPaf, {"00.079.592/0010-70"} )
			AAdd( aCnpjPaf, {"00.079.592/0011-50"} )
			AAdd( aCnpjPaf, {"00.079.592/0012-31"} )
			AAdd( aCnpjPaf, {"00.079.592/0013-12"} )
			AAdd( aCnpjPaf, {"00.079.592/0014-01"} )
			AAdd( aCnpjPaf, {"03.737.396/0002-23"} )
			AAdd( aCnpjPaf, {"03.737.396/0003-04"} )
			AAdd( aCnpjPaf, {"03.737.396/0004-95"} )
			AAdd( aCnpjPaf, {"03.737.396/0005-76"} )
			AAdd( aCnpjPaf, {"03.737.396/0006-57"} )
			AAdd( aCnpjPaf, {"07.337.653/0002-90"} )
			AAdd( aCnpjPaf, {"07.337.653/0003-71"} )
			AAdd( aCnpjPaf, {"07.337.653/0004-52"} )
			AAdd( aCnpjPaf, {"45.526.795/0004-57"} )
			AAdd( aCnpjPaf, {"45.526.795/0005-38"} )
			AAdd( aCnpjPaf, {"45.526.795/0006-19"} )
			AAdd( aCnpjPaf, {"45.526.795/0007-08"} )
			AAdd( aCnpjPaf, {"45.526.795/0008-80"} )
			AAdd( aCnpjPaf, {"45.526.795/0009-61"} )
			AAdd( aCnpjPaf, {"45.526.795/0010-03"} )
			AAdd( aCnpjPaf, {"45.526.795/0011-86"} )
			AAdd( aCnpjPaf, {"45.526.795/0012-67"} )
			AAdd( aCnpjPaf, {"45.526.795/0013-48"} )
			AAdd( aCnpjPaf, {"45.526.795/0014-29"} )
			AAdd( aCnpjPaf, {"67.987.347/0003-02"} )
			AAdd( aCnpjPaf, {"67.987.347/0004-93"} )
			AAdd( aCnpjPaf, {"67.987.347/0005-74"} )
			AAdd( aCnpjPaf, {"67.987.347/0006-55"} )
			AAdd( aCnpjPaf, {"67.987.347/0007-36"} )
			AAdd( aCnpjPaf, {"67.987.347/0008-17"} )
			AAdd( aCnpjPaf, {"67.987.347/0009-06"} )
			AAdd( aCnpjPaf, {"67.987.347/0010-31"} )
			AAdd( aCnpjPaf, {"05.126.919/0001-40"} )
			AAdd( aCnpjPaf, {"05.126.919/0002-20"} )
			AAdd( aCnpjPaf, {"05.126.919/0003-01"} )
			AAdd( aCnpjPaf, {"05.126.919/0004-92"} )
			AAdd( aCnpjPaf, {"05.126.919/0005-73"} )
			AAdd( aCnpjPaf, {"05.126.919/0006-54"} )
			AAdd( aCnpjPaf, {"05.126.919/0007-35"} )
			AAdd( aCnpjPaf, {"05.126.919/0008-16"} )
			AAdd( aCnpjPaf, {"05.126.919/0009-05"} )
			AAdd( aCnpjPaf, {"05.126.919/0010-30"} )
			AAdd( aCnpjPaf, {"05.126.919/0011-11"} )
			AAdd( aCnpjPaf, {"05.126.919/0012-00"} )
			AAdd( aCnpjPaf, {"05.126.919/0013-83"} )
			AAdd( aCnpjPaf, {"05.672.526/0001-31"} )
			AAdd( aCnpjPaf, {"05.672.526/0002-12"} )
			AAdd( aCnpjPaf, {"05.672.526/0003-01"} )
			AAdd( aCnpjPaf, {"05.672.526/0004-84"} )
			AAdd( aCnpjPaf, {"05.672.526/0005-65"} )
			AAdd( aCnpjPaf, {"05.672.526/0006-46"} )
			AAdd( aCnpjPaf, {"05.672.526/0007-27"} )
			AAdd( aCnpjPaf, {"05.672.526/0008-08"} )
			AAdd( aCnpjPaf, {"05.672.526/0009-99"} )
			AAdd( aCnpjPaf, {"05.672.526/0010-22"} )
			AAdd( aCnpjPaf, {"05.672.526/0011-03"} )
			AAdd( aCnpjPaf, {"05.672.526/0012-94"} )
			AAdd( aCnpjPaf, {"05.672.526/0013-75"} )
			AAdd( aCnpjPaf, {"05.672.526/0014-76"} )
			AAdd( aCnpjPaf, {"01.927.828/0002-33"} )
			AAdd( aCnpjPaf, {"01.927.828/0003-14"} )
			AAdd( aCnpjPaf, {"01.927.828/0004-03"} )
			AAdd( aCnpjPaf, {"01.927.828/0005-86"} )
			AAdd( aCnpjPaf, {"01.927.828/0006-67"} )
			AAdd( aCnpjPaf, {"01.927.828/0007-48"} )
			AAdd( aCnpjPaf, {"01.927.828/0008-29"} )
			AAdd( aCnpjPaf, {"01.927.828/0009-00"} )
			AAdd( aCnpjPaf, {"01.927.828/0010-43"} )
			AAdd( aCnpjPaf, {"01.927.828/0011-24"} )
			AAdd( aCnpjPaf, {"01.927.828/0012-05"} )
			AAdd( aCnpjPaf, {"01.927.828/0013-96"} )
			AAdd( aCnpjPaf, {"01.927.828/0014-77"} )
			AAdd( aCnpjPaf, {"01.927.828/0015-58"} )
			AAdd( aCnpjPaf, {"01.927.828/0016-39"} )
			AAdd( aCnpjPaf, {"01.927.828/0017-10"} )
			AAdd( aCnpjPaf, {"01.927.828/0018-09"} )
			AAdd( aCnpjPaf, {"01.927.828/0019-81"} )
			AAdd( aCnpjPaf, {"01.927.828/0020-15"} )
			AAdd( aCnpjPaf, {"01.927.828/0021-04"} )
			AAdd( aCnpjPaf, {"00.079.592/0002-60"} )
			AAdd( aCnpjPaf, {"00.079.592/0003-40"} )
			AAdd( aCnpjPaf, {"00.079.592/0006-93"} )
			AAdd( aCnpjPaf, {"00.079.592/0007-74"} )
			AAdd( aCnpjPaf, {"00.079.592/0008-55"} )
			AAdd( aCnpjPaf, {"00.079.592/0009-36"} )
			AAdd( aCnpjPaf, {"00.079.592/0010-70"} )
			AAdd( aCnpjPaf, {"00.079.592/0011-50"} )
			AAdd( aCnpjPaf, {"00.079.592/0012-31"} )
			AAdd( aCnpjPaf, {"00.079.592/0013-12"} )
			AAdd( aCnpjPaf, {"00.079.592/0014-01"} )
			AAdd( aCnpjPaf, {"03.737.396/0002-23"} )
			AAdd( aCnpjPaf, {"03.737.396/0003-04"} )
			AAdd( aCnpjPaf, {"03.737.396/0004-95"} )
			AAdd( aCnpjPaf, {"03.737.396/0005-76"} )
			AAdd( aCnpjPaf, {"03.737.396/0006-57"} )
			AAdd( aCnpjPaf, {"07.337.653/0002-90"} )
			AAdd( aCnpjPaf, {"07.337.653/0003-71"} )
			AAdd( aCnpjPaf, {"07.337.653/0004-52"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Otica Diniz  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.777.767/0001-00"} )
			AAdd( aCnpjPaf, {"04.992.594/0001-15"} )
			AAdd( aCnpjPaf, {"04.992.594/0002-04"} )
			AAdd( aCnpjPaf, {"04.992.594/0004-68"} )
			AAdd( aCnpjPaf, {"04.992.594/0003-87"} )
			AAdd( aCnpjPaf, {"04.992.594/0005-49"} )
			AAdd( aCnpjPaf, {"04.992.594/0006-20"} )
			AAdd( aCnpjPaf, {"04.992.594/0007-00"} )
			AAdd( aCnpjPaf, {"04.992.594/0010-06"} )
			AAdd( aCnpjPaf, {"04.992.594/0009-72"} )
			AAdd( aCnpjPaf, {"06.167.941/0001-09"} )
			AAdd( aCnpjPaf, {"06.167.941/0002-81"} )
			AAdd( aCnpjPaf, {"06.167.941/0003-62"} )
			AAdd( aCnpjPaf, {"06.167.941/0004-43"} )
			AAdd( aCnpjPaf, {"06.167.941/0005-24"} )
			AAdd( aCnpjPaf, {"08.596.513/0001-19"} )
			AAdd( aCnpjPaf, {"08.596.513/0002-08"} )
			AAdd( aCnpjPaf, {"06.167.941/0006-05"} )
			AAdd( aCnpjPaf, {"10.449.527/0001-51"} )
			AAdd( aCnpjPaf, {"11.072.344/0001-22"} )
			AAdd( aCnpjPaf, {"11.072.344/0002-03"} )
			AAdd( aCnpjPaf, {"13.120.321/0001-71"} )
			AAdd( aCnpjPaf, {"01.590.406/0001-34"} )
			AAdd( aCnpjPaf, {"02.759.277/0001-28"} )
			AAdd( aCnpjPaf, {"00.434.971/0001-40"} )	
			AAdd( aCnpjPaf, {"00.434.971/0002-20"} )
			AAdd( aCnpjPaf, {"03.442.404/0001-23"} )
			AAdd( aCnpjPaf, {"12.686.940/0001-65"} )	
			AAdd( aCnpjPaf, {"01.590.406/0002-15"} )
			AAdd( aCnpjPaf, {"12.777.767/0001-00"} )
			AAdd( aCnpjPaf, {"07.275.115/0001-38"} )	
			AAdd( aCnpjPaf, {"01.590.406/0005-68"} )
			AAdd( aCnpjPaf, {"02.759.277/0002-09"} )
			AAdd( aCnpjPaf, {"12.687.094/0001-06"} )
			AAdd( aCnpjPaf, {"01.590.406/0006-49"} )
			AAdd( aCnpjPaf, {"14.368.038/0001-26"} )
			AAdd( aCnpjPaf, {"14.359.873/0001-08"} )
			AAdd( aCnpjPaf, {"05.559.108/0005-66"} )
			AAdd( aCnpjPaf, {"04.663.848/0004-02"} )
			AAdd( aCnpjPaf, {"05.559.108/0004-85"} )
			AAdd( aCnpjPaf, {"02.717.077/0004-55"} )
			AAdd( aCnpjPaf, {"02.717.077/0003-74"} )
			AAdd( aCnpjPaf, {"05.559.108/0003-02"} )
			AAdd( aCnpjPaf, {"04.663.848/0003-13"} )
			AAdd( aCnpjPaf, {"02.717.077/0002-93"} )
			AAdd( aCnpjPaf, {"02.717.077/0001-02"} )
			AAdd( aCnpjPaf, {"05.559.108/0002-13"} )
			AAdd( aCnpjPaf, {"05.559.108/0001-32"} )
			AAdd( aCnpjPaf, {"04.663.848/0002-32"} )
			AAdd( aCnpjPaf, {"04.663.848/0001-51"} )
			AAdd( aCnpjPaf, {"07.317.354/0002-94"} )
			AAdd( aCnpjPaf, {"06.114.783/0001-10"} )
			AAdd( aCnpjPaf, {"07.317.354/0001-03"} )
			AAdd( aCnpjPaf, {"07.856.137/0001-91"} )
			AAdd( aCnpjPaf, {"07.846.154/0001-48"} )
			AAdd( aCnpjPaf, {"08.389.084/0001-09"} )
			AAdd( aCnpjPaf, {"07.846.154/0002-29"} )
			AAdd( aCnpjPaf, {"78.561.137/0002-72"} )
			AAdd( aCnpjPaf, {"12.318.109/0001-50"} )
			AAdd( aCnpjPaf, {"13.177.114/0001-53"} )
			AAdd( aCnpjPaf, {"07.376.944/0001-07"} )
			AAdd( aCnpjPaf, {"08.717.901/0001-53"} )
			AAdd( aCnpjPaf, {"11.311.905/0001-07"} )
			AAdd( aCnpjPaf, {"08.717.901/0001-00"} )
			AAdd( aCnpjPaf, {"08.717.901/0002-91"} )
			AAdd( aCnpjPaf, {"08.717.901/0003-72"} )
			AAdd( aCnpjPaf, {"10.816.517/0001-07"} )
			AAdd( aCnpjPaf, {"11.311.905/0002-80"} )
			AAdd( aCnpjPaf, {"07.856.137/0002-72"} ) // VAM COMÉRCIO DE ÓTICA LTDA ME	
			AAdd( aCnpjPaf, {"04.992.594/0011-97"} )
			AAdd( aCnpjPaf, {"06.004.090/0004-18"} )
			AAdd( aCnpjPaf, {"06.004.090/0003-37"} )
			AAdd( aCnpjPaf, {"05.003.489/0004-11"} )
			AAdd( aCnpjPaf, {"06.164.599/0002-66"} )	
			AAdd( aCnpjPaf, {"05.003.489/0008-45"} )	
			AAdd( aCnpjPaf, {"05.003.489/0007-64"} )
			AAdd( aCnpjPaf, {"06.164.599/0001-85"} )
			AAdd( aCnpjPaf, {"05.003.489/0003-30"} )	
			AAdd( aCnpjPaf, {"05.003.489/0010-60"} )
			AAdd( aCnpjPaf, {"06.004.090/0002-56"} )
			AAdd( aCnpjPaf, {"05.003.489/0001-79"} )
			AAdd( aCnpjPaf, {"05.003.489/0009-26"} )
			AAdd( aCnpjPaf, {"05.003.489/0005-00"} )
			AAdd( aCnpjPaf, {"07.548.026/0001-18"} )
			AAdd( aCnpjPaf, {"06.004.090/0005-07"} )
			AAdd( aCnpjPaf, {"10.546.533/0001-27"} )
			AAdd( aCnpjPaf, {"06.164.599/0003-47"} )
			AAdd( aCnpjPaf, {"06.004.090/0001-75"} )
			AAdd( aCnpjPaf, {"13.667.519/0001-70"} )
			AAdd( aCnpjPaf, {"07.568.063/0001-98"} )
			AAdd( aCnpjPaf, {"07.568.063/0002-79"} )
			AAdd( aCnpjPaf, {"07.568.063/0003-50"} )
			AAdd( aCnpjPaf, {"07.568.063/0004-30"} )
			AAdd( aCnpjPaf, {"07.568.063/0005-11"} )
			AAdd( aCnpjPaf, {"07.568.063/0006-00"} )
			AAdd( aCnpjPaf, {"07.568.063/0007-83"} )
			AAdd( aCnpjPaf, {"07.568.063/0008-64"} )
			AAdd( aCnpjPaf, {"07.568.063/0009-45"} )
			AAdd( aCnpjPaf, {"07.568.063/0010-89"} )
			AAdd( aCnpjPaf, {"15.395.077/0002-66"} )
			AAdd( aCnpjPaf, {"15.395.077/0001-85"} )
			AAdd( aCnpjPaf, {"04.663.848/0001-51"} )
			AAdd( aCnpjPaf, {"04.663.848/0002-32"} )
			AAdd( aCnpjPaf, {"05.559.108/0001-32"} )
			AAdd( aCnpjPaf, {"05.559.108/0002-13"} )
			AAdd( aCnpjPaf, {"02.717.077/0001-02"} )
			AAdd( aCnpjPaf, {"02.717.077/0002-93"} )
			AAdd( aCnpjPaf, {"04.663.848/0003-13"} )
			AAdd( aCnpjPaf, {"05.559.108/0003-02"} )
			AAdd( aCnpjPaf, {"02.717.077/0003-74"} )
			AAdd( aCnpjPaf, {"02.717.077/0004-55"} )
			AAdd( aCnpjPaf, {"05.559.108/0004-85"} )
			AAdd( aCnpjPaf, {"04.663.848/0004-02"} )
			AAdd( aCnpjPaf, {"05.559.108/0005-66"} )
			AAdd( aCnpjPaf, {"07.357.919/0009-58"} )
			AAdd( aCnpjPaf, {"14.807.046/0001-21"} )
			AAdd( aCnpjPaf, {"15.252.420/0001-32"} )
			AAdd( aCnpjPaf, {"06.167.941/0008-77"} )
			AAdd( aCnpjPaf, {"16.637.286/0001-50"} ) //RENNAN COMÉRCIO DE PRODUTOS ÓTICOS
			AAdd( aCnpjPaf, {"06.167.941/0007-96"} )
			AAdd( aCnpjPaf, {"05.389.849/0001-12"} )
			AAdd( aCnpjPaf, {"05.389.849/0002-01"} )
			AAdd( aCnpjPaf, {"07.696.293/0002-13"} )
			AAdd( aCnpjPaf, {"07.696.293/0001-32"} )
			AAdd( aCnpjPaf, {"15.185.369/0001-93"} )
			AAdd( aCnpjPaf, {"06.126.485/0001-40"} )
			AAdd( aCnpjPaf, {"07.713.655/0001-56"} )
			AAdd( aCnpjPaf, {"06.126.485/0002-21"} )
			AAdd( aCnpjPaf, {"07.713.655/0002-37"} )
			AAdd( aCnpjPaf, {"13.166.765/0001-48"} )
			AAdd( aCnpjPaf, {"16.562.598/0001-42"} )
			AAdd( aCnpjPaf, {"09.563.083/0001-00"} )
			AAdd( aCnpjPaf, {"09.563.083/0002-82"} )
			AAdd( aCnpjPaf, {"09.563.083/0003-63"} )
			AAdd( aCnpjPaf, {"09.563.083/0004-44"} )
			AAdd( aCnpjPaf, {"08.717.901/0004-53"} )
			AAdd( aCnpjPaf, {"08.717.901/0005-34"} )
			AAdd( aCnpjPaf, {"04.663.848/0001-51"} )
			AAdd( aCnpjPaf, {"04.663.848/0002-32"} )
			AAdd( aCnpjPaf, {"04.663.848/0006-66"} )
			AAdd( aCnpjPaf, {"04.663.848/0013-95"} )
			AAdd( aCnpjPaf, {"04.663.848/0009-09"} )
			AAdd( aCnpjPaf, {"04.663.848/0010-42"} )
			AAdd( aCnpjPaf, {"04.663.848/0003-13"} )
			AAdd( aCnpjPaf, {"04.663.848/0008-28"} )
			AAdd( aCnpjPaf, {"04.663.848/0005-85"} )
			AAdd( aCnpjPaf, {"04.663.848/0007-47"} )
			AAdd( aCnpjPaf, {"04.663.848/0012-04"} )
			AAdd( aCnpjPaf, {"04.663.848/0004-02"} )
			AAdd( aCnpjPaf, {"04.663.848/0011-23"} )
			AAdd( aCnpjPaf, {"04.663.848/0014-76"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CD ALIMENTOS LTDA - ME  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"13.257.892/0001-52"} )															
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Notebook Traders Comércio De Equipamentos De Informatica LTDA ME  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			AAdd( aCnpjPaf, {"07.807.230/0001-06"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PAISAGEM DISTRIBUIDORA DE LIVROS LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			AAdd( aCnpjPaf, {"27.512.821/0001-63"} )	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³RIOBEL RIO JOANES DISTRIBUIDORA BEBIDAS LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			AAdd( aCnpjPaf, {"96.713.839/0001-46"} )		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FLOR ARTE LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			AAdd( aCnpjPaf, {"70.064.035/0004-12"} )  
					  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SHARK MAQUINAS PARA CONSTRUCAO LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		    AAdd( aCnpjPaf, {"47.390.307/0001-00"} )    
		    AAdd( aCnpjPaf, {"47.390.307/0013-43"} )
		    AAdd( aCnpjPaf, {"47.390.307/0004-52"} )
		    AAdd( aCnpjPaf, {"47.390.307/0018-58"} )
		    AAdd( aCnpjPaf, {"47.390.307/0019-39"} )
		    AAdd( aCnpjPaf, {"47.390.307/0022-34"} )    
		    AAdd( aCnpjPaf, {"47.390.307/0026-68"} )
		    AAdd( aCnpjPaf, {"47.390.307/0028-20"} )
		    AAdd( aCnpjPaf, {"05.444.853/0001-36"} )
		    AAdd( aCnpjPaf, {"71.724.512/0004-91"} )
		    AAdd( aCnpjPaf, {"71.724.512/0008-15"} )    
		    AAdd( aCnpjPaf, {"77.310.589/0007-44"} )
		    AAdd( aCnpjPaf, {"47.390.307/0021-53"} )
		    AAdd( aCnpjPaf, {"04.445.434/0003-18"} )
		    AAdd( aCnpjPaf, {"08.237.002/0010-00"} )    
		    AAdd( aCnpjPaf, {"08.237.002/0013-44"} )
		    AAdd( aCnpjPaf, {"05.444.853/0004-89"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA	    
		    AAdd( aCnpjPaf, {"05.444.853/0007-21"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA	    
			AAdd( aCnpjPaf, {"05.444.853/0006-40"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"05.444.853/0008-02"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"05.444.853/0009-93"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"05.444.853/0010-27"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"05.444.853/0003-06"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA	
			AAdd( aCnpjPaf, {"05.444.853/0005-60"} ) //AGRICASE EQUIPAMENTOS AGRICOLAS LTDA	
			AAdd( aCnpjPaf, {"06.224.121/0001-01"} )
			AAdd( aCnpjPaf, {"47.390.307/0013-43"} )
			AAdd( aCnpjPaf, {"47.390.307/0029-00"} )
			AAdd( aCnpjPaf, {"47.390.307/0008-86"} )
			AAdd( aCnpjPaf, {"47.390.307/0012-62"} )
			AAdd( aCnpjPaf, {"47.390.307/0009-67"} )
			AAdd( aCnpjPaf, {"47.390.307/0011-81"} )
			AAdd( aCnpjPaf, {"47.390.307/0014-24"} )
			AAdd( aCnpjPaf, {"47.390.307/0018-58"} )
			AAdd( aCnpjPaf, {"47.390.307/0017-77"} )
			AAdd( aCnpjPaf, {"47.390.307/0019-39"} )
			AAdd( aCnpjPaf, {"47.390.307/0021-53"} )
			AAdd( aCnpjPaf, {"47.390.307/0023-15"} )
			AAdd( aCnpjPaf, {"47.390.307/0025-87"} )
			AAdd( aCnpjPaf, {"47.390.307/0027-49"} )
			AAdd( aCnpjPaf, {"47.390.307/0028-20"} )
			AAdd( aCnpjPaf, {"47.390.307/0030-44"} )
			AAdd( aCnpjPaf, {"06.224.121/0001-01"} )
			AAdd( aCnpjPaf, {"03.988.196/0001-62"} )
			AAdd( aCnpjPaf, {"03.988.196/0003-24"} )
			AAdd( aCnpjPaf, {"03.988.196/0002-43"} )
			AAdd( aCnpjPaf, {"03.988.196/0004-05"} )
			AAdd( aCnpjPaf, {"03.988.196/0005-96"} )
			AAdd( aCnpjPaf, {"03.988.196/0006-77"} )
			AAdd( aCnpjPaf, {"03.988.196/0007-58"} )
			AAdd( aCnpjPaf, {"03.988.196/0008-39"} )
			AAdd( aCnpjPaf, {"77.310.589/0001-59"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0002-30"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0007-44"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0008-25"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0009-06"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0010-40"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0011-20"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0012-01"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0015-54"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0017-16"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0018-05"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0019-88"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0021-00"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0022-83"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0023-64"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0024-45"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0025-26"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
			AAdd( aCnpjPaf, {"77.310.589/0026-07"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA
		    AAdd( aCnpjPaf, {"77.310.589/0021-00"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA	    
			AAdd( aCnpjPaf, {"77.310.589/0027-98"} ) //	EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA - UF:PR
			AAdd( aCnpjPaf, {"77.310.589/0028-79"} ) //	EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA - UF:SC
			AAdd( aCnpjPaf, {"77.310.589/0029-50"} ) //EQUAGRIL EQUIPAMENTOS AGRICOLAS LTDA - UF:PR    
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Multimicro Comércio de Produtos de InformÁtica LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		    AAdd( aCnpjPaf, {"08.363.085/0001-84"} )        
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³KAFER COMERCIO LTDA-EPP   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		    AAdd( aCnpjPaf, {"82.923.244/0001-00"} )        
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³RAYZA TAPETES & LINHAS LTDA   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		    AAdd( aCnpjPaf, {"19.882.364/0001-70"} )    
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³2BS Comércio de Acessórios e Semi-Jóias Ltda.    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		    AAdd( aCnpjPaf, {"13.788.415/0001-13"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ABC D EMPRESA DE LIMPEZA E DESCARTAVEIS LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			    
		    AAdd( aCnpjPaf, {"11.361.764/0001-29"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VR BACHES E CIA LTDA - ME ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			    
		    AAdd( aCnpjPaf, {"01.798.656/0001-64"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³KHRONOS IND COM E SERVICOS EM ELETRONICA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			    
		    AAdd( aCnpjPaf, {"78.323.094/0001-27"} )    
		    AAdd( aCnpjPaf, {"78.323.094/0004-70"} )
		    AAdd( aCnpjPaf, {"78.323.094/0002-08"} )
		    AAdd( aCnpjPaf, {"78.323.094/0003-99"} )
		    AAdd( aCnpjPaf, {"78.323.094/0005-50"} )
		    AAdd( aCnpjPaf, {"78.323.094/0006-31"} )
		    AAdd( aCnpjPaf, {"78.323.094/0008-01"} )
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³LRV NORTE BRINQUEDOS LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"13.762.621/0001-54"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MAGAZINE NOVO HIPER  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"12.684.290/0002-08"} )    
		    AAdd( aCnpjPaf, {"12.684.290/0003-80"} )    
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³JAMILE SAMPAIO OLIVEIRA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"11.746.259/0001-00"} )    
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³COOPERATIVA AGRO INDUSTRIAL ALEGRETE LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"89.231.708/0011-39"} )        
		    AAdd( aCnpjPaf, {"89.231.708/0015-62"} )    
		    AAdd( aCnpjPaf, {"89.231.708/0023-72"} )        
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SICITEC SOCIEDADE TECNICA COMERCIO E REPRESENTANT LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"12.517.553/0001-03"} )                
		    
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³CASTRO DIESEL LTDA ME  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"71.502.397/0001-68"} ) //Castro Diesel LTDA
		    AAdd( aCnpjPaf, {"03.615.103/0001-54"} ) //Hidraucastro Direções Hidráulicas Ltda
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MFB MATERIAL DE CONSTRUCAO LTDA  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"34.196.147/0001-10"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pedreiras Valeria SA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"15.851.413/0001-57"} )
		                      
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³OFS RJ LTDA			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"04.779.685/0001-77"} )
		    AAdd( aCnpjPaf, {"04.779.685/0002-58"} )
		    AAdd( aCnpjPaf, {"04.779.685/0003-39"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0004-10"} )
		    AAdd( aCnpjPaf, {"04.779.685/0005-09"} )
		    AAdd( aCnpjPaf, {"04.779.685/0006-81"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0007-62"} )
		    AAdd( aCnpjPaf, {"04.779.685/0008-43"} )
		    AAdd( aCnpjPaf, {"04.779.685/0009-24"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0010-68"} )
		    AAdd( aCnpjPaf, {"04.779.685/0011-49"} )
		    AAdd( aCnpjPaf, {"04.779.685/0012-20"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0013-00"} )
		    AAdd( aCnpjPaf, {"04.779.685/0014-91"} )
		    AAdd( aCnpjPaf, {"04.779.685/0015-72"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0016-53"} )
		    AAdd( aCnpjPaf, {"04.779.685/0017-34"} )
		    AAdd( aCnpjPaf, {"04.779.685/0018-15"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0019-04"} )
		    AAdd( aCnpjPaf, {"04.779.685/0020-30"} )
		    AAdd( aCnpjPaf, {"04.779.685/0021-10"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0022-00"} )
		    AAdd( aCnpjPaf, {"04.779.685/0023-82"} )
		    AAdd( aCnpjPaf, {"04.779.685/0024-63"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0025-44"} )
		    AAdd( aCnpjPaf, {"04.779.685/0026-25"} )
		    AAdd( aCnpjPaf, {"04.779.685/0027-06"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0028-97"} )
		    AAdd( aCnpjPaf, {"04.779.685/0029-78"} )
		    AAdd( aCnpjPaf, {"04.779.685/0030-01"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0031-92"} )
		    AAdd( aCnpjPaf, {"04.779.685/0032-73"} )
		    AAdd( aCnpjPaf, {"04.779.685/0033-54"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0034-35"} )
		    AAdd( aCnpjPaf, {"04.779.685/0035-16"} )
		    AAdd( aCnpjPaf, {"04.779.685/0036-05"} )
		    AAdd( aCnpjPaf, {"04.779.685/0037-88"} )
		    AAdd( aCnpjPaf, {"04.779.685/0038-69"} )
		    AAdd( aCnpjPaf, {"04.779.685/0039-40"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0040-83"} )
		    AAdd( aCnpjPaf, {"04.779.685/0041-64"} )
		    AAdd( aCnpjPaf, {"04.779.685/0042-45"} )    
		    AAdd( aCnpjPaf, {"04.779.685/0043-26"} )
			AAdd( aCnpjPaf, {"04.779.685/0045-98"} )
			AAdd( aCnpjPaf, {"04.779.685/0044-07"} )
			AAdd( aCnpjPaf, {"04.779.685/0046-79"} )
			AAdd( aCnpjPaf, {"04.779.685/0048-30"} )
			AAdd( aCnpjPaf, {"04.779.685/0047-50"} )
			AAdd( aCnpjPaf, {"04.779.685/0049-11"} )
			AAdd( aCnpjPaf, {"04.779.685/0050-55"} )
			AAdd( aCnpjPaf, {"04.779.685/0051-36"} )
			AAdd( aCnpjPaf, {"04.779.685/0052-17"} )
			AAdd( aCnpjPaf, {"04.779.685/0053-06"} )
			AAdd( aCnpjPaf, {"04.779.685/0054-89"} )
			AAdd( aCnpjPaf, {"04.779.685/0055-60"} )
			AAdd( aCnpjPaf, {"04.779.685/0056-40"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SBS - SPECIAL BOOK SERVICES LIVRARIA E EDITORA LTDA   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"54.394.630/0030-51"} )
		    AAdd( aCnpjPaf, {"54.394.630/0042-95"} )
		    AAdd( aCnpjPaf, {"54.394.630/0032-13"} )    
		    AAdd( aCnpjPaf, {"54.394.630/0025-94"} )
		    AAdd( aCnpjPaf, {"54.394.630/0002-06"} )
			AAdd( aCnpjPaf, {"03.608.306/0001-13"} ) // LIVRARIA INTERNACIONAL SBS LTDA 
			AAdd( aCnpjPaf, {"03.608.306/0003-85"} ) // LIVRARIA INTERNACIONAL SBS LTDA 
			AAdd( aCnpjPaf, {"54.394.630/0006-21"} )
			AAdd( aCnpjPaf, {"54.394.630/0008-93"} )
			AAdd( aCnpjPaf, {"54.394.630/0014-31"} )
			AAdd( aCnpjPaf, {"54.394.630/0022-41"} )
			AAdd( aCnpjPaf, {"15.682.994/0001-40"} ) // LIVRARIA INTERNACIONAL DO CEARA
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ALUAH COSMETICOS LTDA - MARCELLE DE MOURA SA ROCHA ANGELINE MEE    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"06.001.656/0001-05"} )
		    AAdd( aCnpjPaf, {"01.327.697/0001-72"} )
		    AAdd( aCnpjPaf, {"11.203.847/0001-90"} )
				
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| KS COSMETICOS LTDA.    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"11.171.467/0001-10"} )
		    AAdd( aCnpjPaf, {"11.171.467/0003-82"} )
			AAdd( aCnpjPaf, {"11.171.467/0002-00"} )
			AAdd( aCnpjPaf, {"04.561.728/0001-43"} ) // Sun Chul Kim Kim - EPP	
			AAdd( aCnpjPaf, {"03.687.608/0001-24"} ) // Lefragile Cosmeticos Ltda. - EPP
			AAdd( aCnpjPaf, {"09.172.877/0001-34"} ) // Jung Eun Bae Cosmeticos - EPP	
			AAdd( aCnpjPaf, {"53.267.928/0001-01"} ) // COSMETICOS MAXIBOM LTDA.
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| COOPERATIVA DOS AGRICULTORES DA REGIAO DE ORLANDIA    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"53.311.361/0001-15"} ) 
			AAdd( aCnpjPaf, {"53.311.361/0002-04"} )
			AAdd( aCnpjPaf, {"53.311.361/0007-00"} )
			AAdd( aCnpjPaf, {"53.311.361/0009-72"} )
			AAdd( aCnpjPaf, {"53.311.361/0017-82"} )
			AAdd( aCnpjPaf, {"53.311.361/0093-33"} )
			AAdd( aCnpjPaf, {"53.311.361/0023-20"} )
			AAdd( aCnpjPaf, {"53.311.361/0024-01"} )
			AAdd( aCnpjPaf, {"53.311.361/0094-14"} )
			AAdd( aCnpjPaf, {"53.311.361/0038-07"} )
			AAdd( aCnpjPaf, {"53.311.361/0039-98"} )
			AAdd( aCnpjPaf, {"53.311.361/0040-21"} )
			AAdd( aCnpjPaf, {"53.311.361/0043-74"} )
			AAdd( aCnpjPaf, {"53.311.361/0051-84"} )
			AAdd( aCnpjPaf, {"53.311.361/0052-65"} )
			AAdd( aCnpjPaf, {"53.311.361/0055-08"} )
			AAdd( aCnpjPaf, {"53.311.361/0060-75"} )
			AAdd( aCnpjPaf, {"53.311.361/0063-18"} )
			AAdd( aCnpjPaf, {"53.311.361/0066-60"} )
			AAdd( aCnpjPaf, {"53.311.361/0070-47"} )
			AAdd( aCnpjPaf, {"53.311.361/0089-57"} )
			AAdd( aCnpjPaf, {"53.311.361/0082-80"} )
			AAdd( aCnpjPaf, {"53.311.361/0090-90"} )
			AAdd( aCnpjPaf, {"53.311.361/0091-71"} )
			AAdd( aCnpjPaf, {"53.311.361/0088-76"} )
			AAdd( aCnpjPaf, {"53.311.361/0097-67"} )
			AAdd( aCnpjPaf, {"53.311.361/0013-59"} )
			AAdd( aCnpjPaf, {"53.311.361/0108-54"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| BIG CENTER COMERCIAL LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"09.595.675/0001-03"} )
		    AAdd( aCnpjPaf, {"97.523.103/0001-78"} )		//SBT DE FREITAS ME
		    AAdd( aCnpjPaf, {"09.301.070/0001-54"} )		//LARANJEIRAS COMERCIO DE MAGAZINE
		        
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| RM COMERCIAL LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"06.001.656/0001-05"} )
		    AAdd( aCnpjPaf, {"69.612.406/0001-21"} )
		    AAdd( aCnpjPaf, {"69.612.406/0002-02"} )
		    AAdd( aCnpjPaf, {"69.612.406/0003-93"} )
		    AAdd( aCnpjPaf, {"69.612.406/0004-74"} )
		    AAdd( aCnpjPaf, {"69.612.406/0005-55"} )
		    AAdd( aCnpjPaf, {"69.612.406/0006-36"} )
		    AAdd( aCnpjPaf, {"69.612.406/0007-17"} )
		    AAdd( aCnpjPaf, {"69.612.406/0008-06"} )
		    AAdd( aCnpjPaf, {"69.612.406/0009-89"} )
		    AAdd( aCnpjPaf, {"69.612.406/0010-12"} )
		    AAdd( aCnpjPaf, {"69.612.406/0011-01"} )
		    AAdd( aCnpjPaf, {"69.612.406/0012-84"} )
		    AAdd( aCnpjPaf, {"69.612.406/0013-65"} )
		    AAdd( aCnpjPaf, {"69.612.406/0014-46"} )
		    AAdd( aCnpjPaf, {"69.612.406/0015-27"} )    
		    AAdd( aCnpjPaf, {"69.612.406/0016-08"} )
		    AAdd( aCnpjPaf, {"69.612.406/0017-99"} )
		    AAdd( aCnpjPaf, {"69.612.406/0018-70"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| OFICINA RUBI LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"07.953.495/0001-12"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| E.J. Móveis e Confecções LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"13.235.915/0001-28"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| MIRTES TAVARES DA SILVA ME  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"03.078.133/0001-79"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| AGROVEL AGRICULTURA E VETERINARIA LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"13.161.435/0001-60"} )
		    AAdd( aCnpjPaf, {"13.161.435/0003-21"} )
		    AAdd( aCnpjPaf, {"13.161.435/0004-02"} )    
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| O MESTRE MATERIAIS DE CONSTRUCAO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"00.778.553/0001-70"} )
		    AAdd( aCnpjPaf, {"00.778.553/0003-31"} )
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| MEDEIROS MATERIAIS DE CONSTRUCAO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"05.557.910/0001-93"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| INFONEWS BRINQUEDOS LTDA.  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"01.288.476/0001-32"} )
		    AAdd( aCnpjPaf, {"01.288.476/0002-13"} )
		    AAdd( aCnpjPaf, {"01.288.476/0004-85"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| PNEUMAC AUTO CENTER LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"09.623.995/0001-11"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Guaraves Guarabira Aves Ltda |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"12.727.145/0001-78"} )
		    AAdd( aCnpjPaf, {"12.727.145/0011-40"} )
		    
		   	//ÚÄÄÄÄÄÄÄÄ¿
			//| Ceasa  |
			//ÀÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"12.727.145/0014-92"} )//Recife
		    AAdd( aCnpjPaf, {"12.727.145/0005-00"} )//Natal
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³DM7 COMERCIO DE BRINQUEDOS LTDA EPP(PBKIDS) |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"09.400.493/0001-21"} )
		   	AAdd( aCnpjPaf, {"64.731.433/0008-76"} )  
	
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| RYMO IMAGEM E PROD.GRAF.DA AMAZONIA LTDA|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"14.220.230/0001-70"} )   
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|FERRAGENS FILGUEIRAS LTDA ME   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"22.207.856/0002-56"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|DL MATERIAIS MÉDICOS E HOSPITALARES LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.007.934/0001-20"} )	
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|TECMEDICA HOSPITALAR LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.021.332/0002-94"} )
			AAdd( aCnpjPaf, {"04.021.332/0004-56"} )
			AAdd( aCnpjPaf, {"04.021.332/0005-37"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|HUTEBA MERCANTIL LTDA    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.004.999/0003-50"} )
			AAdd( aCnpjPaf, {"13.004.999/0001-99"} )
			AAdd( aCnpjPaf, {"13.004.999/0002-70"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|BELA ISCHIA IND E COM DE POLPA E FRUTA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.130.631/0003-50"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|VIAÇÃO ITAPEMIRIM S/A   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"31.719.032/0001-75"} )
			AAdd( aCnpjPaf, {"31.719.032/0008-41"} )
			AAdd( aCnpjPaf, {"31.719.032/0005-07"} )
			AAdd( aCnpjPaf, {"31.719.032/0006-80"} )
			AAdd( aCnpjPaf, {"31.719.032/0002-56"} )
			AAdd( aCnpjPaf, {"31.719.032/0009-22"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|SORVEPAN COMERCIO E REPRESENTACOES LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.904.538/0001-20"} )	
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|DISMEL COMERCIO E SERVICOS LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.111.438/0001-14"} )
			AAdd( aCnpjPaf, {"15.111.438/0003-86"} )
			AAdd( aCnpjPaf, {"15.111.438/0004-67"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|COMANG COMERCIO DE CORREIAS E MANGUEIRAS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.852.270/0001-72"} ) 
		
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| AMOROSA A MALHARIA DO CORACAO LTDA.     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.294.869/0001-60"} )
			AAdd( aCnpjPaf, {"09.294.869/0002-41"} )
			AAdd( aCnpjPaf, {"09.294.869/0003-22"} )
			AAdd( aCnpjPaf, {"09.294.869/0005-94"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| LOJAS SAN MARINO LTDA    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.406.198/0001-04"} )
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| SAN REMO COM. DE CONFECCOES E MOVEIS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"06.886.145/0001-18"} )	
			AAdd( aCnpjPaf, {"07.524.930/0001-93"} ) // SAN REMO BABY	
			AAdd( aCnpjPaf, {"08.766.085/0001-25"} )
			AAdd( aCnpjPaf, {"08.985.124/0001-85"} )
			AAdd( aCnpjPaf, {"09.381.258/0001-50"} ) //LTM CONFECCOES
			AAdd( aCnpjPaf, {"09.527.965/0001-01"} ) //DTV COMERCIO DE CONFECCOES E MOVEIS LTDA.
			AAdd( aCnpjPaf, {"11.760.991/0001-27"} ) //FELIX & FELIX COMERCIO DE CONFECCOES LTDA.		
		
		   	// ÚÄÄÄÄÄÄÄÄÄÄ¿
			// |RJU LTDA  |
			// ÀÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"78.575.149/0019-15"} )
		
		   	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// |KI DOCES COMERCIO DE ALIMENTOS LTDA  |
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.001.425/0001-02"} )
			AAdd( aCnpjPaf, {"12.001.425/0002-85"} )
			AAdd( aCnpjPaf, {"12.001.425/0003-66"} )
			AAdd( aCnpjPaf, {"12.001.425/0004-47"} )
			AAdd( aCnpjPaf, {"12.001.425/0005-28"} )
			AAdd( aCnpjPaf, {"12.001.425/0006-09"} )
		
		   	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// |MUNDO CORRIDA COMERCIO DE PRODUTOS ESPORTIVOS LTDA. |
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.984.263/0001-33"} )
			AAdd( aCnpjPaf, {"11.401.564/0004-03"} )
			AAdd( aCnpjPaf, {"11.401.564/0003-14"} )
			AAdd( aCnpjPaf, {"11.401.564/0001-52"} )
			
		   	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// |A Serenata Ltda     |
			// |LOG Importacao Ltda |
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"17.220.054/0001-65"} )
			AAdd( aCnpjPaf, {"17.220.054/0006-70"} )
			AAdd( aCnpjPaf, {"17.220.054/0007-50"} )
			AAdd( aCnpjPaf, {"17.220.054/0002-46"} )
			AAdd( aCnpjPaf, {"17.220.054/0009-12"} )
			AAdd( aCnpjPaf, {"17.220.054/0010-56"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|POTIGUAR MATERIAIS DE CONSTRUCAO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"06.778.591/0001-09"} )
			AAdd( aCnpjPaf, {"06.778.591/0003-70"} )
			AAdd( aCnpjPaf, {"06.256.879/0001-13"} ) //VIEIRA BRASIL DISTRIBUIDORA LTDA 
			AAdd( aCnpjPaf, {"06.256.879/0004-66"} ) //VIEIRA BRASIL DISTRIBUIDORA LTDA 
			AAdd( aCnpjPaf, {"08.195.327/0001-78"} ) //FORQUILHA MATERIAIS DE CONSTRUCAO LTDA
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| CRISTAIS SÃO MARCOS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"23.645.492/0002-59"} )
			AAdd( aCnpjPaf, {"02.229.066/0001-83"} ) //CSM PRESENTES E DECORACOES LTDA
			AAdd( aCnpjPaf, {"21.325.204/0001-72"} ) //SAN REMO LUSTRES E DECORAÇOES LTDA
			AAdd( aCnpjPaf, {"10.972.555/0001-59"} ) //MOLINARI MURANO COMERCIO DE CRISTAIS LTDA
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| QUALY CARNE LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.310.031/0001-13"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| ROCHA MADEIRA E FERRAGENS INDUSTRIA E COMERCIO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"08.958.622/0001-39"} )	//UF: PB
			AAdd( aCnpjPaf, {"04.866.077/0001-08"} )	//UF: PB
			AAdd( aCnpjPaf, {"04.866.077/0002-80"} )	//UF: PB
			AAdd( aCnpjPaf, {"11.084.591/0001-49"} )	//UF: RN
			AAdd( aCnpjPaf, {"03.596.192/0001-39"} )	//UF: PE
			AAdd( aCnpjPaf, {"70.080.338/0001-86"} )	//UF: PE
			AAdd( aCnpjPaf, {"10.102.168/0001-61"} )	//UF: PE
			AAdd( aCnpjPaf, {"08.958.622/0002-10"} )	//UF: PB
			AAdd( aCnpjPaf, {"11.240.381/0001-66"} )	//UF: PE
			AAdd( aCnpjPaf, {"07.693.743/0001-33"} )	//UF: PE
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| SFUJII & CIA LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.803.174/0001-60"} ) 
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	PORTO VAZ LABORATORIO A CORES LTDA	  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.526.769/0001-00"} )
			AAdd( aCnpjPaf, {"01.526.769/0002-91"} )
			AAdd( aCnpjPaf, {"01.526.769/0003-72"} )
			AAdd( aCnpjPaf, {"10.446.534/0001-08"} ) // NEW COLOR MG ME
		    
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	FRIGORIFICO VITELLO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"84.125.681/0001-04"} )
			AAdd( aCnpjPaf, {"84.125.681/0002-95"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	J WELLINGTON C MACIEL  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"40.856.999/0001-90"} )
			AAdd( aCnpjPaf, {"40.856.999/0005-13"} )
			AAdd( aCnpjPaf, {"40.856.999/0010-80"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	R B DANTAS E CIA LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.895.028/0004-02"} )
			                 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|V.C. COMERCIO DE COMPONENTES ELETRONICOS E INSTRUMENTOS MUSICAIS LTDA - ME  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.203.836/0001-68"} )
			AAdd( aCnpjPaf, {"10.361.662/0001-40"} )
			AAdd( aCnpjPaf, {"09.005.225/0001-05"} )
			AAdd( aCnpjPaf, {"09.219.022/0001-11"} )
			AAdd( aCnpjPaf, {"09.219.022/0002-00"} )
			AAdd( aCnpjPaf, {"11.111.536/0002-81"} )
			AAdd( aCnpjPaf, {"09.480.616/0001-81"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	ETNA COM DE MOV E ART P DECORACAO LTDA  |
			//³ TELLERINA COM PRES ART DECORACAO SA.    ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.477.066/0011-90"} )
			AAdd( aCnpjPaf, {"13.477.066/0016-03"} )
		    AAdd( aCnpjPaf, {"84.453.844/0143-08"} )  
		    AAdd( aCnpjPaf, {"84.453.844/0156-14"} )
			AAdd( aCnpjPaf, {"13.477.066/0014-33"} ) // UF: MG
			AAdd( aCnpjPaf, {"13.477.066/0019-48"} ) // UF: MG
			AAdd( aCnpjPaf, {"13.477.066/0022-43"} ) // UF: MG
			AAdd( aCnpjPaf, {"13.477.066/0026-77"} ) // UF: MG
			AAdd( aCnpjPaf, {"13.477.066/0015-14"} )
			AAdd( aCnpjPaf, {"13.477.066/0012-71"} )
			AAdd( aCnpjPaf, {"13.477.066/0018-67"} )	
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	PREMIERE COMERCIO E IMPORTAÇÃO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.664.005/0001-44"} )
			AAdd( aCnpjPaf, {"02.664.005/0002-25"} )
			AAdd( aCnpjPaf, {"02.664.005/0003-06"} )
			AAdd( aCnpjPaf, {"02.664.005/0004-97"} )
			AAdd( aCnpjPaf, {"02.664.005/0005-78"} )
			AAdd( aCnpjPaf, {"02.664.005/0006-59"} )
			AAdd( aCnpjPaf, {"02.664.005/0007-30"} )
			AAdd( aCnpjPaf, {"02.664.005/0008-10"} )
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	BENVINDO STOCO  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"35.953.892/0001-20"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	SAO LUIS DISTRIBUIDORA DE LIVROS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"41.490.756/0001-43"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| 	AMIN BARBOSA QUENEL   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.527.911/0001-05"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	VISUAL COMERCIO E SERVICOS DE OTICA LTDA 	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"14.302.267/0002-29"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	SUA CASA HOME CENTER	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.664.013/0004-08"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	CASA DAS TINTAS LTDA     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.073.747/0001-11"} )
			AAdd( aCnpjPaf, {"13.073.747/0002-00"} )
			AAdd( aCnpjPaf, {"08.853.810/0001-00"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	DINAMICA DISTRIBUIDORA LTDA.		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"84.467.307/0001-97"} )
			AAdd( aCnpjPaf, {"84.467.307/0004-30"} )
			AAdd( aCnpjPaf, {"84.467.307/0005-10"} )
			AAdd( aCnpjPaf, {"84.467.307/0006-00"} )
			AAdd( aCnpjPaf, {"84.467.307/0008-63"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	PAULO ESCARIZ LTDA		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"16.470.999/0001-72"} )
			AAdd( aCnpjPaf, {"16.470.999/0003-34"} )
			AAdd( aCnpjPaf, {"16.470.999/0006-87"} )
			AAdd( aCnpjPaf, {"16.470.999/0005-04"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	FATIMA R. G. LIMA COMERCIO - ME		|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.378.094/0001-08"} )
			
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	WT ALBUQUERQUE COMERCIO E REPRESENTACOES LTDA	  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.524.668/0001-54"} )   
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	RC ZANOTELLI EPP  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"08.224.103/0001-47"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// CAT COMERCIO IMPORTAÇÃO E EXPORTAÇÃO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.222.362/0002-97"} )
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| CONFECCOES E ACESSORIOS AR A C LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"36.289.544/0001-62"} )
			AAdd( aCnpjPaf, {"36.576.999/0001-69"} )
			AAdd( aCnpjPaf, {"01.375.982/0001-69"} )
			AAdd( aCnpjPaf, {"39.690.151/0001-54"} )
			AAdd( aCnpjPaf, {"03.456.353/0001-99"} )
			AAdd( aCnpjPaf, {"07.493.762/0001-16"} )
			AAdd( aCnpjPaf, {"07.431.624/0001-02"} )
			AAdd( aCnpjPaf, {"07.431.624/0002-93"} )
			AAdd( aCnpjPaf, {"07.874.181/0001-24"} )
			AAdd( aCnpjPaf, {"07.874.181/0002-05"} )
			AAdd( aCnpjPaf, {"08.672.679/0001-77"} )
			AAdd( aCnpjPaf, {"07.996.312/0001-46"} )
			AAdd( aCnpjPaf, {"10.374.183/0001-69"} )
			AAdd( aCnpjPaf, {"10.381.700/0001-27"} )
			AAdd( aCnpjPaf, {"10.886.563/0001-10"} )
			AAdd( aCnpjPaf, {"36.289.544/0002-43"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| DISTAK COMPUTADORES LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"05.410.128/0001-47"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| LOPES & BAY LTDA ME  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"08.204.524/0002-97"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Pegurim Com.Produtos Hospitalares Ltda. |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.411.318/0001-53"} )
		
			//--------------------------
			// PELMEX DA AMAZONIA LTDA |
			//--------------------------
			AAdd( aCnpjPaf, {"04.321.519/0009-80"} )
			AAdd( aCnpjPaf, {"04.321.519/0010-13"} )
			AAdd( aCnpjPaf, {"04.321.519/0011-02"} )
			AAdd( aCnpjPaf, {"04.321.519/0015-85"} )
			AAdd( aCnpjPaf, {"04.321.519/0012-85"} )
			AAdd( aCnpjPaf, {"04.321.519/0001-22"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| FATIMA R. G. LIMA COMERCIO - ME |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.242.797/0001-50"} ) // G.L.COMERCIO E IMPORTAÇÃO DE MOVEIS E OBJETOS LTDA 
			AAdd( aCnpjPaf, {"04.490.822/0001-59"} ) // M.J. BARROS GONCALVES
			AAdd( aCnpjPaf, {"09.323.927/0001-37"} ) // A DA FONSECA GONÇALVES
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| TECIDOS SÃO GERALDO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"20.162.723/0001-02"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Elmo Calçados S/A  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"17.170.416/0001-50"} )
			AAdd( aCnpjPaf, {"17.170.416/0003-12"} )
			AAdd( aCnpjPaf, {"17.170.416/0005-84"} )
			AAdd( aCnpjPaf, {"17.170.416/0019-80"} )
			AAdd( aCnpjPaf, {"17.170.416/0090-26"} )
			AAdd( aCnpjPaf, {"17.170.416/0046-52"} )
			AAdd( aCnpjPaf, {"17.170.416/0047-33"} )
			AAdd( aCnpjPaf, {"17.170.416/0048-14"} )
			AAdd( aCnpjPaf, {"17.170.416/0050-39"} )
			AAdd( aCnpjPaf, {"17.170.416/0052-09"} )
			AAdd( aCnpjPaf, {"17.170.416/0053-81"} )
			AAdd( aCnpjPaf, {"17.170.416/0056-24"} )
			AAdd( aCnpjPaf, {"17.170.416/0062-72"} )
			AAdd( aCnpjPaf, {"17.170.416/0068-68"} )
			AAdd( aCnpjPaf, {"17.170.416/0069-49"} )
			AAdd( aCnpjPaf, {"17.170.416/0070-82"} )
			AAdd( aCnpjPaf, {"17.170.416/0073-25"} )
			AAdd( aCnpjPaf, {"17.170.416/0074-06"} )
			AAdd( aCnpjPaf, {"17.170.416/0076-78"} )
			AAdd( aCnpjPaf, {"17.170.416/0077-59"} )
			AAdd( aCnpjPaf, {"17.170.416/0079-10"} )
			AAdd( aCnpjPaf, {"17.170.416/0086-40"} )
			AAdd( aCnpjPaf, {"17.170.416/0087-20"} )
			AAdd( aCnpjPaf, {"17.170.416/0088-01"} )
			AAdd( aCnpjPaf, {"17.170.416/0089-92"} )
			AAdd( aCnpjPaf, {"17.170.416/0091-07"} )
			AAdd( aCnpjPaf, {"17.170.416/0092-98"} )
			AAdd( aCnpjPaf, {"17.170.416/0093-79"} )
			AAdd( aCnpjPaf, {"17.170.416/0094-50"} )
			AAdd( aCnpjPaf, {"17.170.416/0095-30"} )
			AAdd( aCnpjPaf, {"17.170.416/0096-11"} )
			AAdd( aCnpjPaf, {"17.170.416/0009-08"} )
			AAdd( aCnpjPaf, {"17.170.416/0037-61"} )
			AAdd( aCnpjPaf, {"17.170.416/0012-03"} )
			AAdd( aCnpjPaf, {"17.170.416/0017-18"} )
			AAdd( aCnpjPaf, {"17.170.416/0018-07"} )
			AAdd( aCnpjPaf, {"17.170.416/0025-28"} )
			AAdd( aCnpjPaf, {"17.170.416/0023-66"} )
			AAdd( aCnpjPaf, {"17.170.416/0024-47"} )
			AAdd( aCnpjPaf, {"17.170.416/0027-90"} )
			AAdd( aCnpjPaf, {"17.170.416/0028-70"} )
			AAdd( aCnpjPaf, {"17.170.416/0032-57"} )
			AAdd( aCnpjPaf, {"17.170.416/0033-38"} )
			AAdd( aCnpjPaf, {"17.170.416/0004-01"} )
			AAdd( aCnpjPaf, {"17.170.416/0004-01"} )
			AAdd( aCnpjPaf, {"17.170.416/0022-85"} )
			AAdd( aCnpjPaf, {"17.170.416/0039-23"} )
			AAdd( aCnpjPaf, {"17.170.416/0041-48"} )
			AAdd( aCnpjPaf, {"17.170.416/0042-29"} )
			AAdd( aCnpjPaf, {"17.170.416/0043-00"} )
			AAdd( aCnpjPaf, {"17.170.416/0045-71"} )
			AAdd( aCnpjPaf, {"17.170.416/0097-00"} )
			AAdd( aCnpjPaf, {"17.170.416/0013-94"} )
			AAdd( aCnpjPaf, {"17.170.416/0098-83"} )
			AAdd( aCnpjPaf, {"17.170.416/0099-66"} )  
			AAdd( aCnpjPaf, {"17.170.416/0100-32"} )
			AAdd( aCnpjPaf, {"17.170.416/0101-13"} )
			AAdd( aCnpjPaf, {"17.170.416/0102-02"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MOVEIS ESPLENDIDOS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.917.017/0001-28"} )
			AAdd( aCnpjPaf, {"06.375.549/0001-47"} )
			AAdd( aCnpjPaf, {"05.769.034/0001-69"} )
			AAdd( aCnpjPaf, {"06.375.549/0002-28"} )
			AAdd( aCnpjPaf, {"03.523.839/0001-00"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Refrigel Comércio e Refrigeração  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"07.227.502/0001-07"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|INTER COLOR LAB COM IMP MAT FOTOGRAFICOS  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"55.589.477/0002-27"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|A R RODRIGUEZ & CIA. LTDA. |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.562.591/0001-41"} )    //A R RODRIGUEZ & CIA. LTDA
			AAdd( aCnpjPaf, {"04.585.611/0001-08"} )	//A M TECNOLOGIA LTDA
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|KROPNEUS PECAS E PNEUS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"70.055.728/0001-04"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MAKITA DO BRASIL FERRAMENTAS ELETRICAS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"45.865.920/0008-87"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| CONCRET MATERIAIS DE CONSTRUCÃO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.746.673/0002-55"} )    //A R RODRIGUEZ & CIA. LTDA	
			AAdd( aCnpjPaf, {"12.746.673/0006-89"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|ALBRAN COMERCIO DE SOLDAS E FERRAGENS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"29.441.987/0001-61"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Centro Auditivo Windex Brasitom Ltda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"60.869.013/0002-76"} )
			AAdd( aCnpjPaf, {"60.869.013/0012-86"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| REAL COMERCIAL LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.780.640/0010-88"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Innovare Tecnologia e Gestão Ltda  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"07.508.475/0001-32"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|UNIAO COMERCIO DE PECAS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.466.649/0001-65"} )
		    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Ibratin Nordeste Ltda  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"05.966.389/0001-48"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Plugtech do Brasil Ltda.  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.425.358/0001-91"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| EMIS COMERCIO E RERESENTAÇOES LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"08.855.199/0009-07"} )
		                                            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Nova Holanda |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.069.897/0001-26"} )
			AAdd( aCnpjPaf, {"11.069.897/0002-07"} )
			AAdd( aCnpjPaf, {"11.069.897/0003-98"} )
			AAdd( aCnpjPaf, {"11.069.897/0004-79"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Multdrink do Brasil Ltda |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"72.565.765/0001-80"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| GERSON E CIA LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"03.130.203/0001-90"} ) // TOPAZIO COMERCIO DE JOIAS LTDA
			AAdd( aCnpjPaf, {"03.130.219/0001-01"} ) // TURQUESA COMERCIO DE JOIAS LTDA
			AAdd( aCnpjPaf, {"03.849.092/0001-77"} ) // RIO DE CONTAS FABRICA DE JOIAS LTDA
			AAdd( aCnpjPaf, {"03.130.203/0002-71"} ) // TOPAZIO COMERCIO DE JOIAS LTDA
			AAdd( aCnpjPaf, {"10.594.805/0001-64"} ) // VIANA COMERCIO DE JOIAS LTDA
			AAdd( aCnpjPaf, {"11.175.291/0001-75"} ) // PIERINA COMERCIO DE JOIAIS LTDA
			AAdd( aCnpjPaf, {"15.211.527/0001-32"} ) // GERSON E CIA LTDA
			AAdd( aCnpjPaf, {"15.211.527/0002-13"} ) // GERSON E CIA LTDA
			AAdd( aCnpjPaf, {"15.211.527/0012-95"} ) // GERSON E CIA LTDA
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| ELETROSOLDA COMERCIO E REPRESENTACOES LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"35.968.825/0001-89"} )   // ELETROSOLDA COMERCIO E REPRESENTACOES LTDA
			AAdd( aCnpjPaf, {"08.865.942/0001-44"} )   // EUROSOLDA COMERCIO E LOCACOES LTDA - ME   
			AAdd( aCnpjPaf, {"08.865.942/0002-25"} )   // EUROSOLDA COMERCIO E LOCACOES LTDA - ME
			AAdd( aCnpjPaf, {"07.100.104/0001-17"} )   // HIPER ENTREGAMOS MIX DE MATERIAIS LTDA.
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| MACODESC MATERIAIS DE CONTRUCAO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"80.067.358/0001-70"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|EJ COMERCIO DE CONFECCOES E ARTEFATOS DE COURO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"13.579.747/0001-98"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Primu's Rio Comercio de utilidades do Lar Ltda   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"03.375.396/0004-92"} )
			AAdd( aCnpjPaf, {"03.375.396/0003-01"} )
			AAdd( aCnpjPaf, {"03.375.396/0001-40"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MEU VISUAL COSMETICOS E SEMI JOIAS LTDA ME   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"72.562.895/0001-69"} )   // MEU VISUAL COSMETICOS E SEMI JOIAS LTDA ME / UF : RJ
			AAdd( aCnpjPaf, {"07.110.411/0001-89"} )	// MLRL Comércio de Folheados Ltda 			  / UF : RJ
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|S.S. DISTRIBUIDORA DE BEBIDAS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.290.421/0001-92"} ) // UF: MG
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Equipamentos Eletrônicos Santa Maria Ltda  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.280.862/0010-79"} )
		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Grupo A Educação SA.  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"87.133.666/0003-68"} ) // UF: SP
			AAdd( aCnpjPaf, {"87.133.666/0007-91"} ) // UF: MG
			AAdd( aCnpjPaf, {"87.133.666/0011-78"} ) // UF: DF
			AAdd( aCnpjPaf, {"87.133.666/0006-00"} ) // UF: RS
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Riccieri Confecções Ltda |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"75.456.764/0006-08"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MEU VISUAL COSMETICOS E SEMI JOIAS LTDA ME |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"72.562.895/0001-69"} ) // UF: RJ
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Vinhos S/A Industria e Comercio |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"87.547.428/0001-37"} )
			AAdd( aCnpjPaf, {"87.547.428/0002-18"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| BAZAR GURI LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"20.714.440/0001-18"} ) // UF: MG
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| PRATA FORTE COMERCIO E DISTRIBUIÇÃO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.770.621/0001-80"} )
			AAdd( aCnpjPaf, {"02.770.621/0003-41"} )
			AAdd( aCnpjPaf, {"02.770.621/0005-03"} )
			AAdd( aCnpjPaf, {"15.719.005.0001-46"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|J.A.B. Leite ind com e exportação Ltda-me |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.638.758/0002-29"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| BIAVAL LOJA DE ROUPAS E ACESSORIOS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.126.680/0001-61"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| LUIS EDUARDO PAVAN ME 	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.690.261/0001-60"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| GESTOR ADMINISTRACAO EMPRESARIAL LTDA.	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.595.157/0001-68"} )
			AAdd( aCnpjPaf, {"04.594.520/0001-20"} )
			AAdd( aCnpjPaf, {"04.322.722/0001-13"} )
			AAdd( aCnpjPaf, {"07.411.141/0001-46"} )
			AAdd( aCnpjPaf, {"07.411.153/0001-70"} )
			AAdd( aCnpjPaf, {"00.400.241/0001-28"} )
			AAdd( aCnpjPaf, {"10.362.456/0001-55"} )
			AAdd( aCnpjPaf, {"04.712.131/0001-52"} )
			AAdd( aCnpjPaf, {"02.944.992/0001-30"} )
			AAdd( aCnpjPaf, {"05.890.510/0001-03"} )
			AAdd( aCnpjPaf, {"03.110.912/0001-04"} )
			AAdd( aCnpjPaf, {"05.900.772/0001-01"} )
			AAdd( aCnpjPaf, {"05.874.259/0001-85"} )
			AAdd( aCnpjPaf, {"04.001.658/0001-79"} )
			AAdd( aCnpjPaf, {"05.552.276/0001-04"} )
			AAdd( aCnpjPaf, {"05.432.654/0001-08"} )
			AAdd( aCnpjPaf, {"07.557.323/0001-20"} )
			AAdd( aCnpjPaf, {"08.697.937/0001-70"} )
			AAdd( aCnpjPaf, {"07.615.548/0001-95"} )
			AAdd( aCnpjPaf, {"09.653.303/0001-88"} )
			AAdd( aCnpjPaf, {"11.966.713/0001-20"} )
			AAdd( aCnpjPaf, {"15.120.424/0001-67"} )
			AAdd( aCnpjPaf, {"04.651.734/0001-91"} ) //Ingred Comercio de Calcados Ltda 
			AAdd( aCnpjPaf, {"03.430.732/0001-00"} ) //Pé da Moda Calcados Ltda 
			AAdd( aCnpjPaf, {"03.955.355/0001-22"} ) //Comercial de Calcados IJS 
			AAdd( aCnpjPaf, {"03.593.783/0001-52"} ) //Comercial de tecidos Dias D’avila Ltda 
			AAdd( aCnpjPaf, {"04.407.006/0001-39"} ) //Calcados Minas Bahia Ltda 
			AAdd( aCnpjPaf, {"06.166.665/0001-56"} ) //J.B.R. Comercio de Calcados Ltda 
			AAdd( aCnpjPaf, {"00.301.327/0001-01"} ) //Cachoeira Tecidos Ltda 
			AAdd( aCnpjPaf, {"03.750.798/0001-87"} ) //Comercial  Tecidos Minas Bahia Ltda 
			AAdd( aCnpjPaf, {"09.618.831/0001-04"} ) //Lafex Comercio de Calcados e Confecções Ltda 
			AAdd( aCnpjPaf, {"10.594.288/0001-23"} ) //Costa Souza comercial de Tecidos e Confecções Ltda 
			AAdd( aCnpjPaf, {"10.849.175/0001-21"} ) //Lauro de Freitas Comercio de Confecções Ltda 
			AAdd( aCnpjPaf, {"11.415.805/0001-12"} ) //JR Comercio de Confecções Ltda
			AAdd( aCnpjPaf, {"11.914.444/0001-59"} ) //Pojuca Comercio de Confecções Ltda 
			AAdd( aCnpjPaf, {"15.544.546/0001-80"} ) //	COMERCIAL DE CALCADOS SETE LTDA                             
			AAdd( aCnpjPaf, {"14.701.291/0001-50"} ) //	SEBE COMERCIAL DE CALCADOS E CONFECCOES LTDA                
			AAdd( aCnpjPaf, {"16.422.705/0001-37"} ) //	COMERCIAL DE CALCADOS SOUZA E PEREIRA LTDA  	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| MEDICAL SHOP PRODUTOS HOSPITALARES LTDA	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"38.056.131/0002-44"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| DIVINOPOLIS VIDROS LTDA	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"19.103.597/0001-28"} )
			AAdd( aCnpjPaf, {"04.408.172/0001-50"} ) 	//UF: MG - Divine Vidros de Segurança Ltda
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Qualiminas LTDA	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.735.585/0001-41"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| TOTAL FERRO E COMERCIO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"08.166.314/0001-70"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| DECKER MODAS LTDA ME  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"24.042.244/0001-03"} )
			AAdd( aCnpjPaf, {"00.369.986/0001-71"} )
			AAdd( aCnpjPaf, {"02.482.795/0001-47"} )
			AAdd( aCnpjPaf, {"02.482.795/0002-28"} )
			AAdd( aCnpjPaf, {"03.041.181/0001-92"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| SUPERMERCADO DEGRAU LTDA.  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"02.912.729/0001-60"} )
			AAdd( aCnpjPaf, {"02.912.729/0003-21"} )
			AAdd( aCnpjPaf, {"02.912.729/0004-02"} )	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| PEG informatica   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.105.481/0001-62"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| ATACADÃO DOS ELETRODOMESTICOS DO NORDESTE LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"70.120.662/0042-59"} )
			AAdd( aCnpjPaf, {"70.120.662/0004-23"} )
			AAdd( aCnpjPaf, {"70.120.662/0005-04"} )
			AAdd( aCnpjPaf, {"70.120.662/0008-57"} )
			AAdd( aCnpjPaf, {"70.120.662/0009-38"} )
			AAdd( aCnpjPaf, {"70.120.662/0010-71"} )
			AAdd( aCnpjPaf, {"70.120.662/0011-52"} )
			AAdd( aCnpjPaf, {"70.120.662/0012-33"} )
			AAdd( aCnpjPaf, {"70.120.662/0013-14"} )
			AAdd( aCnpjPaf, {"70.120.662/0014-03"} )
			AAdd( aCnpjPaf, {"70.120.662/0015-86"} )
			AAdd( aCnpjPaf, {"70.120.662/0016-67"} )
			AAdd( aCnpjPaf, {"70.120.662/0017-48"} )
			AAdd( aCnpjPaf, {"70.120.662/0018-29"} )
			AAdd( aCnpjPaf, {"70.120.662/0019-00"} )
			AAdd( aCnpjPaf, {"70.120.662/0020-43"} )
			AAdd( aCnpjPaf, {"70.120.662/0021-24"} )
			AAdd( aCnpjPaf, {"70.120.662/0022-05"} )
			AAdd( aCnpjPaf, {"70.120.662/0023-96"} )
			AAdd( aCnpjPaf, {"70.120.662/0024-77"} )
			AAdd( aCnpjPaf, {"70.120.662/0025-58"} )
			AAdd( aCnpjPaf, {"70.120.662/0026-39"} )
			AAdd( aCnpjPaf, {"70.120.662/0027-10"} )
			AAdd( aCnpjPaf, {"70.120.662/0028-09"} )
			AAdd( aCnpjPaf, {"70.120.662/0029-81"} )
			AAdd( aCnpjPaf, {"70.120.662/0030-15"} )
			AAdd( aCnpjPaf, {"70.120.662/0031-04"} )
			AAdd( aCnpjPaf, {"70.120.662/0032-87"} )
			AAdd( aCnpjPaf, {"70.120.662/0033-68"} )
			AAdd( aCnpjPaf, {"70.120.662/0001-80"} )
			AAdd( aCnpjPaf, {"70.120.662/0034-49"} )
			AAdd( aCnpjPaf, {"70.120.662/0035-20"} )
			AAdd( aCnpjPaf, {"70.120.662/0036-00"} )
			AAdd( aCnpjPaf, {"70.120.662/0037-91"} )
			AAdd( aCnpjPaf, {"70.120.662/0038-72"} )
			AAdd( aCnpjPaf, {"70.120.662/0039-53"} )
			AAdd( aCnpjPaf, {"70.120.662/0040-97"} )
			AAdd( aCnpjPaf, {"70.120.662/0041-78"} )
			AAdd( aCnpjPaf, {"70.120.662/0043-30"} )
			AAdd( aCnpjPaf, {"70.120.662/0044-10"} )
			AAdd( aCnpjPaf, {"70.120.662/0045-00"} )
			AAdd( aCnpjPaf, {"70.120.662/0001-80"} )
			AAdd( aCnpjPaf, {"70.120.662/0046-82"} )
			AAdd( aCnpjPaf, {"70.120.662/0047-63"} )
			AAdd( aCnpjPaf, {"70.120.662/0048-44"} )
			AAdd( aCnpjPaf, {"70.120.662/0049-25"} )
			AAdd( aCnpjPaf, {"70.120.662/0050-69"} )
			AAdd( aCnpjPaf, {"70.120.662/0053-01"} )
			AAdd( aCnpjPaf, {"70.120.662/0055-73"} )
			AAdd( aCnpjPaf, {"70.120.662/0051-40"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| BIG ELETRO COM  DISTRIB MAT ELETRICO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.851.795/0001-30"} )
			AAdd( aCnpjPaf, {"03.851.795/0002-10"} )
			AAdd( aCnpjPaf, {"03.851.795/0003-00"} )
			AAdd( aCnpjPaf, {"03.851.795/0004-82"} )	
			
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| NOVA CRUZ COMERCIO DE MOVEIS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"07.221.618/0001-20"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| RPM COMERCIO DE MATERIAL HOSPITALAR LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"40.396.103/0001-37"} )
			AAdd( aCnpjPaf, {"09.496.551/0001-62"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| APAIL DIESEL AUTOPECAS LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"23.360.605/0003-50"} )
			AAdd( aCnpjPaf, {"23.360.605/0004-31"} )
			AAdd( aCnpjPaf, {"23.360.605/0001-99"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| ALUMIACO DA AMAZONIA LTDA ME  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.397.432/0001-02"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	CLUB MED BRASIL SA     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.010.384/0005-45"} )
			AAdd( aCnpjPaf, {"03.010.384/0003-83"} )
			AAdd( aCnpjPaf, {"28.573.830/0001-27"} ) //TAIPE TRANCOSO EMPREENDIMENTOS SA
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| COMERCIAL LONTRA LOJA DE DEPARTAMENTOS LTDA	 |
			//| E DE SA LOJAS DE DEPARTAMENTOS EIRELI		 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.374.505/0001-89"} )
			AAdd( aCnpjPaf, {"01.374.505/0002-60"} )
			AAdd( aCnpjPaf, {"26.750.802/0001-02"} ) // PELLICANO MODAS LTDA
			AAdd( aCnpjPaf, {"03.471.764/0001-53"} ) // LOJAO RELAMPAGO LTDA-ME - UF: PA
			AAdd( aCnpjPaf, {"15.377.105/0001-31"} ) // POLLYPAIXAO LOJAS DE DEPARTAMENTOS EIRELE EPP
			AAdd( aCnpjPaf, {"13.384.317/0001-10"} ) // TANAMODA DISTRIBUIDORA TEXTIL LTDA	
			AAdd( aCnpjPaf, {"15.377.105/0002-12"} ) //POLLYPAIXAO LOJAS DE DEPARTAMENTOS EIRELE EPP
			AAdd( aCnpjPaf, {"17.087.373/0001-44"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Joalheria e Otica Paladio Ltda	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"82.944.331/0001-44"} )
			AAdd( aCnpjPaf, {"79.880.381/0001-09"} ) //Joalheria e Ótica Simara ltda - (Simara II) - Matriz
			AAdd( aCnpjPaf, {"79.880.381/0003-62"} ) //Joalheria e Ótica Simara Ltda – (Simara III)
			AAdd( aCnpjPaf, {"09.169.751/0001-00"} ) //Joalheria e Ótica Aline Ltda – (Simara IV)
			AAdd( aCnpjPaf, {"09.169.751/0002-91"} ) //JOALHERIA E ÓTICA ALINE LTDA		
			AAdd( aCnpjPaf, {"17.115.241/0001-89"} ) //JOALHERIA e OTICA DAIMAR LTDA ME
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| COOPERATIVA MISTA AGRO PECUARIA DE PATOS DE MINAS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"23.338.189/0001-22"} )
			AAdd( aCnpjPaf, {"23.338.189/0005-56"} )
			AAdd( aCnpjPaf, {"23.338.189/0011-02"} )
			AAdd( aCnpjPaf, {"23.338.189/0007-18"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	JE COMERCIO DE CALCADOS LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"08.593.749/0001-00"} )
			AAdd( aCnpjPaf, {"08.593.749/0002-82"} )
			AAdd( aCnpjPaf, {"07.629.007/0001-16"} ) //PIT STOP COMERCIO DE CALÇADOS LTDA 
			AAdd( aCnpjPaf, {"07.629.007/0002-05"} ) //PIT STOP COMERCIO DE CALÇADOS LTDA  
			AAdd( aCnpjPaf, {"08.592.953/0001-06"} ) //MP COMERCIO DE CALÇADOS LTDA 
			AAdd( aCnpjPaf, {"05.492.153/0001-17"} ) //ZILMA COMERCIO DE CALÇADOS LTDA 
			AAdd( aCnpjPaf, {"12.999.216/0001-91"} ) //E.E. COMERCIO DE CALÇADOS E VESTUARIO LTDA
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| TYRESOLES DE ALAGOAS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.268.652/0003-52"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Comercial Jorge Ltda EPP  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"17.207.093/0001-22"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| LS GUARATO LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"19.867.464/0001-28"} )
				                                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//|	V. CARVALHO CONSTRUCOES E COMERCIO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.040.872/0001-62"} )
			AAdd( aCnpjPaf, {"12.040.872/0002-43"} )
		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|IMAGEM COMERCIO IMPORTACAO E EXPORTACAO LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"84.520.493/0005-04"} )	// UF: AM
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| DVN vidros industria e comercio LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.001.491/0001-01"} ) 
			AAdd( aCnpjPaf, {"41.003.278/0005-23"} )
			AAdd( aCnpjPaf, {"41.003.278/0007-95"} )
			AAdd( aCnpjPaf, {"41.003.278/0011-71"} )
			AAdd( aCnpjPaf, {"41.003.278/0002-80"} )
			AAdd( aCnpjPaf, {"41.003.278/0012-52"} )
			AAdd( aCnpjPaf, {"08.596.532/0001-45"} )
			AAdd( aCnpjPaf, {"05.703.779/0001-25"} )
			AAdd( aCnpjPaf, {"41.003.278/0001-08"} )
			AAdd( aCnpjPaf, {"41.003.278/0009-57"} )
			AAdd( aCnpjPaf, {"11.001.791/0001-01"} )	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| MR SUPERMERCADOS LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"07.972.173/0001-10"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| OLYMPIA DE FRIBURGO TEXTIL LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.221.517/0002-66"} )
			
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	PERFILADOS DA AMAZONIA COMERCIAL LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"14.443.718/0001-67"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	WAP do Brasil Industria e Comercio Ltda EPP |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.511.837/0001-11"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	EMPRESA NUTRECO FRI RIBE NUTRICAO ANIMAL SA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.848.214/0006-80"} )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Kiola Industria e Comercio Ltda   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.887.669/0002-81"} )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| L. R. AFONSO GARCIA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"14.998.895/0001-00"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| SAHELI EMPREENDIMENTOS E LOCACOES LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"63.056.493/0003-63"} )
			AAdd( aCnpjPaf, {"63.056.493/0001-00"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Foxtrot Comércio, Importação e Exportação Ltda  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"34.241.067/0007-25"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//|	Antonio Auto Peças LTDA	|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"27.340.074/0001-23"} )
			AAdd( aCnpjPaf, {"27.340.074/0005-57"} )
			AAdd( aCnpjPaf, {"27.340.074/0006-38"} )
			AAdd( aCnpjPaf, {"27.340.074/0009-80"} )
			AAdd( aCnpjPaf, {"27.340.074/0010-14"} )
			AAdd( aCnpjPaf, {"27.340.074/0011-03"} )
			AAdd( aCnpjPaf, {"27.340.074/0013-67"} )
			AAdd( aCnpjPaf, {"27.340.074/0015-29"} )
			AAdd( aCnpjPaf, {"27.340.074/0016-00"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| SIRIUS ARTIGOS NAUTICOS LTDA EPP  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.050.689/0001-48"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| Fundaçao dos Empregrados da Fiat  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"19.740.471/0004-07"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| Valor Postos LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"27.176.072/0001-40"} )
			AAdd( aCnpjPaf, {"27.176.072/0005-74"} )
			AAdd( aCnpjPaf, {"35.993.468/0001-09"} )
			AAdd( aCnpjPaf, {"35.993.468/0005-32"} )
			AAdd( aCnpjPaf, {"35.993.468/0019-38"} )
			AAdd( aCnpjPaf, {"09.075.096/0001-21"} )
			AAdd( aCnpjPaf, {"39.706.460/0001-75"} )
			AAdd( aCnpjPaf, {"06.947.482/0001-78"} )
			AAdd( aCnpjPaf, {"07.832.245/0001-24"} )
			AAdd( aCnpjPaf, {"05.485.285/0001-11"} )
			AAdd( aCnpjPaf, {"07.808.525/0001-05"} )
			AAdd( aCnpjPaf, {"03.912.705/0001-73"} )
			AAdd( aCnpjPaf, {"09.256.425/0001-30"} )
			AAdd( aCnpjPaf, {"12.882.428/0001-94"} )
			AAdd( aCnpjPaf, {"12.882.428/0002-75"} )
			AAdd( aCnpjPaf, {"12.882.428/0003-56"} )
			AAdd( aCnpjPaf, {"09.072.453/0001-06"} )
			AAdd( aCnpjPaf, {"10.293.860/0001-14"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//|	DEC 11 HARDWARE INFORMATICA LTDA	  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"07.026.076/0001-35"} )
			AAdd( aCnpjPaf, {"07.026.076/0002-16"} )
			AAdd( aCnpjPaf, {"07.026.076/0003-05"} )
			AAdd( aCnpjPaf, {"07.026.076/0005-69"} )
			AAdd( aCnpjPaf, {"07.026.076/0006-40"} )
			AAdd( aCnpjPaf, {"07.026.076/0007-20"} )
			AAdd( aCnpjPaf, {"07.026.076/0008-01"} )
			AAdd( aCnpjPaf, {"07.026.076/0011-07"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//|	LFDE DE SA E CIA LTDA      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"11.088.355/0001-09"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	FLOC TEXTIL INDUSTRIA E COMERCIO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"29.154.333/0001-57"} )
			AAdd( aCnpjPaf, {"39.061.296/0001-96"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|POLITEC IMPORTACAO E COMERCIO LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"43.894.609/0004-07"} )
			AAdd( aCnpjPaf, {"14.951.254/0001-08"} )
			AAdd( aCnpjPaf, {"07.046.809/0001-01"} )
			AAdd( aCnpjPaf, {"11.247.811/0001-08"} )
			AAdd( aCnpjPaf, {"08.975.531/0001-01"} )
			AAdd( aCnpjPaf, {"16.585.936/0001-61"} )
			AAdd( aCnpjPaf, {"29.321.197/0001-42"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| FUNDACAO CENTRO BRASILEIRO DE PROT E PESQ DAS T MARINHA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"16.110.041/0001-70"} )
			AAdd( aCnpjPaf, {"16.110.041/0002-51"} )
			AAdd( aCnpjPaf, {"16.110.041/0003-32"} )
			AAdd( aCnpjPaf, {"16.110.041/0005-02"} )
			AAdd( aCnpjPaf, {"16.110.041/0006-85"} )
			AAdd( aCnpjPaf, {"16.110.041/0007-66"} )
			AAdd( aCnpjPaf, {"16.110.041/0008-47"} )
			AAdd( aCnpjPaf, {"16.110.041/0009-28"} )
			AAdd( aCnpjPaf, {"16.110.041/0010-61"} )
			AAdd( aCnpjPaf, {"16.110.041/0012-23"} )
			AAdd( aCnpjPaf, {"16.110.041/0013-04"} )
			AAdd( aCnpjPaf, {"16.110.041/0014-95"} )
			AAdd( aCnpjPaf, {"16.110.041/0015-76"} )
			AAdd( aCnpjPaf, {"16.110.041/0016-57"} )
			AAdd( aCnpjPaf, {"16.110.041/0017-38"} )
			AAdd( aCnpjPaf, {"16.110.041/0018-19"} )
			AAdd( aCnpjPaf, {"16.110.041/0019-08"} )
			AAdd( aCnpjPaf, {"16.110.041/0020-33"} )
			AAdd( aCnpjPaf, {"16.110.041/0021-14"} )
			AAdd( aCnpjPaf, {"16.110.041/0022-03"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|LOJAS PALHETA VERIEDADES LTDA EPP|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.326.058/0001-18"} )
			AAdd( aCnpjPaf, {"03.326.058/0002-07"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|WORLD WINE COMERCIAL EIRELI-ME   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.304.398/0001-27"} ) 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Centro Avançado de Estética Payot LDTA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.422.824/0001-48"} )
			AAdd( aCnpjPaf, {"03.422.824/0002-29"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|ALEX M TAVARES DANTAS    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.207.226/0004-61"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|COMERCIAL ALCIDES ARAUJO LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"08.398.455/0001-19"} )
			AAdd( aCnpjPaf, {"08.398.455/0002-08"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MADISO RODBEL SOLUÇÕES DE PONTO E ACESSO LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"61.092.565/0002-11"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|	INNOVATION INFORMATICA LTDA    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AAdd( aCnpjPaf, {"12.349.305/0001-92"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|CLIMASTER AR CONDICIONADO LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"04.064.161/0002-80"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| AGROPECUARIA MONTE ALEGRE COMERCIO DE PRODUTOS AGROPECUARIOS LTDA  |		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.026.481/0001-77"} )
			AAdd( aCnpjPaf, {"01.026.481/0003-39"} )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|BRASFERRO COMERCIO E INDUSTRIA IMP. E EXP. LTDA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"84.054.329/0002-06"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|TRS gestão Tecnológica S.A  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.358.343/0003-73"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MONACO IMPORTADORA LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"01.325.678/0001-07"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|ATHAYDES ALONSO EIRELI -ME |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.730.871/0001-38"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Dirce Zelia Torquetti - Torque Grill  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"15.730.871/0001-38"} )	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|MSB COMERCIO DE EQUIPAMENTOS  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"09.222.721/0001-10"} )
			AAdd( aCnpjPaf, {"09.222.721/0002-00"} )
			AAdd( aCnpjPaf, {"09.222.721/0003-82"} )
			AAdd( aCnpjPaf, {"07.714.243/0001-30"} ) //PONTO DO CHEF COM DE EQ. IND LTDA
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| QUALIFARMA PRODUTOS HOSPITALARES LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"00.468.700/0001-05"} )
		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Asa Branca Distribuidora de Livros LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"03.943.335/0001-31"} )

		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| J.E.C. DIAS ME     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"08.995.534/0001-07"} )
		    	
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| JHV IMPLEMENTOS RODOVIARIOS LTDA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.284.459/0001-18"} )
			AAdd( aCnpjPaf, {"10.284.459/0003-80"} )
			AAdd( aCnpjPaf, {"10.284.459/0002-07"} )
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| COOPERATIVA DE PRODUTORES DE LEITE DA BACIA DO RIO PARANAIBA LTDA - COPROLEITE   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"05.301.941/0006-93"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    
			//³PREMIER HYTECH COMPUTADORES LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"11.067.966/0001-62"} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRB COMERCIO DE COLCHOES LTDA    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"12.147.119/0003-32"} )
			AAdd( aCnpjPaf, {"12.147.119/0001-70"} )
			AAdd( aCnpjPaf, {"12.147.119/0004-13"} )
			AAdd( aCnpjPaf, {"12.147.119/0005-02"} )
			AAdd( aCnpjPaf, {"12.147.119/0006-85"} )
			
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³COMERCIAL CASA DE FRIOS LTDA.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"05.359.030/0015-08"} )
		
		  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MADEIRANIT RIBEIRAO PRETO LTDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    AAdd( aCnpjPaf, {"64.427.123/0001-96"} )
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|HOME CENTER JACARE MATERIAL DE CONSTRUÇÃO E MADEIRAS LTDA |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"10.600.446/0001-00"} )
		
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| Diesel Sete Pecas Ltda	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"64.435.670/0001-13" } )		
			
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| Cooperativa Central Mineira e Laticínios Ltda	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"42.942.235/0009-08" } )
	
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
			//| FIXOFER COMERCIO E INDUSTRIA LTDA	 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCnpjPaf, {"19.682.491/0001-26" } )
			
			//R B DANTAS & CIA LTDA - UF: AL
			AAdd( aCnpjPaf, {"02.895.028/0002-40","003", dDataHoje } )
			AAdd( aCnpjPaf, {"02.895.028/0002-40","002", dDataHoje } )			
			AAdd( aCnpjPaf, {"02.895.028/0004-02","002", dDataHoje } )
			AAdd( aCnpjPaf, {"02.895.028/0004-02","003", dDataHoje } )			
			AAdd( aCnpjPaf, {"02.895.028/0006-74","002", dDataHoje } )
			AAdd( aCnpjPaf, {"02.895.028/0007-55","001", dDataHoje } )
			AAdd( aCnpjPaf, {"02.895.028/0008-36","004", dDataHoje } )
			AAdd( aCnpjPaf, {"02.895.028/0008-36","005", dDataHoje } )			
			AAdd( aCnpjPaf, {"08.986.244/0001-05","002", dDataHoje } )
			
			//RELOJOARIA E JOALHERIAS PIAZZA DORO LTDA - CASA DAS ALIANÇAS
			AAdd( aCnpjPaf, {"14.304.931/0002-79" } )
			
			//Alluz Distribuidora - UF: MS
			AAdd( aCnpjPaf, {"03.687.394/0001-96" } )
			
			//Santa Lolla                            
			AAdd( aCnpjPaf, {"18.711.318/0001-46" } )			
			AAdd( aCnpjPaf, {"16.913.133/0001-99" } )			
			AAdd( aCnpjPaf, {"08.924.640/0001-08" } )			
			AAdd( aCnpjPaf, {"18.667.994/0001-60" } )														
			
			//Distribuidora de Moveis Ipanema
			AAdd( aCnpjPaf, {"09.451.214/0058-94" } )																	
			
			//ANTONIO S NAUTICA LTDA - UF: MT
			AAdd( aCnpjPaf, {"36.804.219/0001-90" } )																							
			
			//MACRO DENTAL 
			AAdd( aCnpjPaf, {"73.457.186/0001-86" } )
			
			//BAGAGGIO
			AAdd( aCnpjPaf, {"18.134.829/0001-42" } )
			AAdd( aCnpjPaf, {"18.134.829/0002-23" } )
			AAdd( aCnpjPaf, {"19.785.713/0001-36" } )
			AAdd( aCnpjPaf, {"19.785.713/0002-17" } )
			
			//CARAJAS MATERIAL DE CONSTRUCAO LTDA
			AAdd( aCnpjPaf, {"03.656.804/0011-03" } )
			
			//RB DANTAS E CIA LTDA
			AAdd( aCnpjPaf, {"02.895.028/0008-36" } )			
			AAdd( aCnpjPaf, {"02.895.028/0007-55" } )			
			AAdd( aCnpjPaf, {"02.895.028/0006-74" } )					
			
	EndIf
		
	If !lEmitNfce .And. !lEmitSAT .AND. lVerCnpj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos	:=	Ascan(aCnpjPaf,{|x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
		If nPos > 0
			If Len(aCnpjPaf[nPos]) == 1
				lRet := .T.
			Else
				If !Empty(AllTrim(cPDVEcf)) .AND. (cPDVEcf == aCnpjPaf[nPos][2])
				    lRet := .T.
				ElseIf Empty(AllTrim(cPDVEcf)) .AND. DTOS(Date()) <= DTOS(aCnpjPaf[nPos][3])
					lRet := .T.
				Else
					Alert("ECF não liberado para uso. Envie o relatório gerencial com o número do PDV de uso ou data de validade do seu PAF-ECF está vencida")
					lRet := .F.
				EndIf          	       
			EndIf
		Else
			lRet	:= .F.
		EndIf
	EndIf    
	
	lPafEcf := lRet
Else
	lRet := lPafEcf
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜéÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRecEmul ºAutor  ³Vendas Clientes     º Data ³  26/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao tem por finalidade verificar se o CNPJ passado º±±
±±º          ³ como parametro esta liberado para utilizacao de Impressora º±±
±±º          ³ Nao-Fiscal no Recebimento de Titulos                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.    ³ ExpC1 : CNPJ                                               º±±
±±º          ³ ExpC2 : Tipo de Verificacao (1- CNPJ; 2 - CNPJ E Data)     º±±
±±º          ³ ExpL3 : Exibe mensagem de informando que o prazo de        º±±
±±º          ³         validade para uso desta rotina expirou.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL3 : .T. - Este CNPJ pode usar a Impr.Nao-Fiscal        º±±
±±º          ³         .F. - Este CNPJ nao pode usar a Impr.Nao-Fiscal    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRecEmul( cCNPJ, cTipo, lMsg )
Local 	lRet		:= .F.								// Valida se pode atualizar preco
Local 	nCont		:= 0								// Contador de Variavel
Local 	aCNPJRec	:= {}								// Inicializa o array de CNPJ
Local 	nDiaVenRec	:= 0								// Numero de dias que falta para vencer o prazo de utilizacao de recebimento de titulos com impressora nao fiscal.		
Local   nDiaMsg		:= SuperGetMV("MV_LJDREC", ,60)		// Determina o numero de dias que sera disparado a mensagem informativa
														// para o cliente de que o prazo para utilizacao de impressora nao fiscal no recebimento de titulos esta terminando.

DEFAULT cCNPJ		:= ""								// Inicializa o CNPJ 
DEFAULT cTipo		:= "1"								// Tipo de Validacao: 1) Valida CNPJ; 2) Valida CNPJ e Data		
DEFAULT lMsg		:= .F.								// Nao exibir a mensagem de prazo de expiracao da rotina

If Len(aCNPJRec) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ACM			    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCNPJRec, {"60982576000123"}) 
	AAdd( aCNPJRec, {"60982576000476"}) 
	AAdd( aCNPJRec, {"60982576000557"}) 
	AAdd( aCNPJRec, {"60982576001790"}) 
	AAdd( aCNPJRec, {"60982576001103"}) 
	AAdd( aCNPJRec, {"60982576000638"}) 
	AAdd( aCNPJRec, {"60982576001014"}) 
	AAdd( aCNPJRec, {"60982576001529"}) 
	AAdd( aCNPJRec, {"60982576001286"}) 
	AAdd( aCNPJRec, {"60982576002410"}) 
	AAdd( aCNPJRec, {"60982576001600"}) 
	AAdd( aCNPJRec, {"60982576001952"}) 
	AAdd( aCNPJRec, {"60982576002681"}) 
	AAdd( aCNPJRec, {"60982576002509"}) 
	AAdd( aCNPJRec, {"60982576002177"}) 
	AAdd( aCNPJRec, {"60982576002258"}) 
	AAdd( aCNPJRec, {"60982576002339"}) 
	AAdd( aCNPJRec, {"60982576002762"}) 
	AAdd( aCNPJRec, {"60982576003068"}) 
	AAdd( aCNPJRec, {"60982576002843"}) 
	AAdd( aCNPJRec, {"60982576000204"}) 
	AAdd( aCNPJRec, {"60982576000719"}) 
	AAdd( aCNPJRec, {"60982576000123"}) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida pelo CNPJ e pela data limite³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
For nCont = 1 to Len(aCNPJRec)
	If AllTrim(aCNPJRec[nCont][1]) == AllTrim(cCNPJ)
		If Len(aCNPJRec[nCont]) == 1
			lRet := .T.
			Exit
		Else          
			If cTipo = "2"
				If DTOS(dDatabase) <= DTOS(aCNPJRec[nCont][2])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Vefica se deve emitir aviso de prazo de validade da rotina.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lMsg        
						nDiaVenRec := aCNPJRec[nCont][2] - dDatabase	
						If nDiaVenRec  < nDiaMsg
							LJMsgLeg(LJAnalisaLeg(28, "", nDiaVenRec))
						EndIf
					Endif
					lRet := .T.				
				EndIf
				Exit	
			Else
				lRet := .T.
				exit
			Endif		
		Endif
	EndIf
Next nCont

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfAltPrc  ³ Autor ³ Vendas Clientes     ³ Data ³ 04.08.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao para alterar a tabela de preco				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validaca                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNfAltPrc(cCnpj) 
Local lRet 		:= .F. 
Local nPos 		:= 0
Local aCgcPrc   := {}

cCnpj := AllTrim(cCnpj)    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao para indicar se o CNPJ da TOTVS esta ou nao no PAF-ECF.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCgcPrc, { "34.241.067/0001-30" } )			// FOXTROT COMERCIO IMPORTACAO E EXPORTACAO LTDA	
AAdd( aCgcPrc, { "34.241.067/0004-82" } )			// FOXTROT COMERCIO IMPORTACAO E EXPORTACAO LTDA	
AAdd( aCgcPrc, { "34.241.067/0005-63" } ) 			// FOXTROT COMERCIO IMPORTACAO E EXPORTACAO LTDA
AAdd( aCgcPrc, { "07.508.419/0005-21" } )			// A. MORENO INDUSTRIA E COMERCIO LTDA	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos:= Ascan(aCgcPrc,{|x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
If nPos > 0
	lRet:= .T.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjNfAltPrc  ³ Autor ³ Vendas Clientes     ³ Data ³ 10.05.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao utilizar TEF com NF           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validaca                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjNfUsaTef(cCnpj) 
Local lRet 		:= .F. 
Local nPos 		:= 0
Local aCgcTef   := {}

If nModulo == 5
	lRet := .T. 
Else
	cCnpj := AllTrim(cCnpj)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DALLAS RENT A CAR LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCgcTef, {"00.470.111/0004-04" } )			
	AAdd( aCgcTef, {"00.470.111/0006-76" } )    
	AAdd( aCgcTef, {"00.470.111/0008-38" } )			
	AAdd( aCgcTef, {"00.470.111/0009-19" } )    
	AAdd( aCgcTef, {"00.470.111/0010-52" } )			
	AAdd( aCgcTef, {"00.470.111/0011-33" } )    
	AAdd( aCgcTef, {"00.470.111/0012-14" } )			
	AAdd( aCgcTef, {"00.470.111/0014-86" } )    
	AAdd( aCgcTef, {"00.470.111/0015-67" } )			
	AAdd( aCgcTef, {"00.470.111/0017-29" } )    
	AAdd( aCgcTef, {"00.470.111/0018-00" } )			
	AAdd( aCgcTef, {"00.470.111/0019-90" } )    
	AAdd( aCgcTef, {"00.470.111/0020-24" } )			
	AAdd( aCgcTef, {"00.470.111/0023-77" } )    
	AAdd( aCgcTef, {"00.470.111/0026-10" } )			
	AAdd( aCgcTef, {"00.470.111/0027-09" } )    
	AAdd( aCgcTef, {"00.470.111/0028-81" } )
	AAdd( aCgcTef, {"00.470.111/0001-61" } )
	AAdd( aCgcTef, {"00.470.111/0003-23" } )
	AAdd( aCgcTef, {"00.470.111/0005-95" } )
	AAdd( aCgcTef, {"00.470.111/0021-05" } )
	AAdd( aCgcTef, {"00.470.111/0022-96" } )
	AAdd( aCgcTef, {"00.470.111/0032-68" } )
	AAdd( aCgcTef, {"11.453.272/0001-63" } )
	AAdd( aCgcTef, {"00.470.111/0033-49" } ) 
	AAdd( aCgcTef, {"00.470.111/0036-91" } )
	AAdd( aCgcTef, {"11.455.816/0010-17" } )	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³BRC AUTOMÓVEIS DE ALUGUEL LTDA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCgcTef, {"07.185.183/0002-97" } )			
	AAdd( aCgcTef, {"07.185.183/0003-78" } )    
	AAdd( aCgcTef, {"07.185.183/0004-59" } )			
	AAdd( aCgcTef, {"07.185.183/0005-30" } )    
	AAdd( aCgcTef, {"07.185.183/0007-00" } )			
	AAdd( aCgcTef, {"07.185.183/0008-82" } )    
	AAdd( aCgcTef, {"07.185.183/0009-63" } )			
	AAdd( aCgcTef, {"07.185.183/0011-88" } )     
	AAdd( aCgcTef, {"07.185.183/0006-10" } )     
	AAdd( aCgcTef, {"07.185.183/0010-05" } )     
	AAdd( aCgcTef, {"07.185.183/0001-06" } )
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos:= Ascan(aCgcTef,{|x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
	If nPos > 0
		lRet:= .T.
	Endif

	If lRet .And. LjEmitNFCe()  //Valida se está configurado o uso da NFC-e.
		lRet := .F.
	EndIf

EndIf
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfAltDoc  ³ Autor ³ Vendas Clientes     ³ Data ³ 10.05.10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao para alterar o documento de saida na finalizaçao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validaca                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNfAltDoc(cCnpj) 

Local lRet 		:= .F. 
Local nPos 		:= 0
Local aCgcNF    := {}
Local nMVLJLBNT :=  SuperGetMv("MV_LJLBNT",,0)

cCnpj := AllTrim(cCnpj)

If nMVLJLBNT == 0    	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DELLA VIA DE PNEUS 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCgcNF, {"60.957.784/0001-72" } )    
	AAdd( aCgcNF, {"60.957.784/0002-53" } )    
	AAdd( aCgcNF, {"60.957.784/0003-34" } )    
	AAdd( aCgcNF, {"60.957.784/0004-15" } )    
	AAdd( aCgcNF, {"60.957.784/0005-04" } )    
	AAdd( aCgcNF, {"60.957.784/0006-87" } )    
	AAdd( aCgcNF, {"60.957.784/0007-68" } )    
	AAdd( aCgcNF, {"60.957.784/0049-17" } )    
	AAdd( aCgcNF, {"60.957.784/0009-20" } )    
	AAdd( aCgcNF, {"60.957.784/0010-63" } )    
	AAdd( aCgcNF, {"60.957.784/0011-44" } )    
	AAdd( aCgcNF, {"60.957.784/0012-25" } )    
	AAdd( aCgcNF, {"60.957.784/0013-06" } )    
	AAdd( aCgcNF, {"60.957.784/0014-97" } )    
	AAdd( aCgcNF, {"60.957.784/0015-78" } )    
	AAdd( aCgcNF, {"60.957.784/0016-59" } )    
	AAdd( aCgcNF, {"60.957.784/0017-30" } )    
	AAdd( aCgcNF, {"60.957.784/0018-10" } )    
	AAdd( aCgcNF, {"60.957.784/0019-00" } )    
	AAdd( aCgcNF, {"60.957.784/0020-35" } )    
	AAdd( aCgcNF, {"60.957.784/0021-16" } )    
	AAdd( aCgcNF, {"60.957.784/0024-69" } )    
	AAdd( aCgcNF, {"60.957.784/0025-40" } )    
	AAdd( aCgcNF, {"60.957.784/0026-20" } )    
	AAdd( aCgcNF, {"60.957.784/0028-92" } )    
	AAdd( aCgcNF, {"60.957.784/0029-73" } )    
	AAdd( aCgcNF, {"60.957.784/0033-50" } )    
	AAdd( aCgcNF, {"60.957.784/0053-01" } )    
	AAdd( aCgcNF, {"60.957.784/0037-83" } )    
	AAdd( aCgcNF, {"60.957.784/0038-64" } )    
	AAdd( aCgcNF, {"60.957.784/0039-45" } )    
	AAdd( aCgcNF, {"60.957.784/0027-01" } )    
	AAdd( aCgcNF, {"60.957.784/0040-89" } )    
	AAdd( aCgcNF, {"60.957.784/0041-60" } )    
	AAdd( aCgcNF, {"60.957.784/0042-40" } )    
	AAdd( aCgcNF, {"60.957.784/0043-21" } )    
	AAdd( aCgcNF, {"60.957.784/0046-74" } )    
	AAdd( aCgcNF, {"60.957.784/0048-36" } )    
	AAdd( aCgcNF, {"60.957.784/0055-65" } )    
	AAdd( aCgcNF, {"60.957.784/0008-49" } )    
	AAdd( aCgcNF, {"60.957.784/0023-88" } )    
	AAdd( aCgcNF, {"60.957.784/0032-79" } )    
	AAdd( aCgcNF, {"60.957.784/0036-00" } )    
	AAdd( aCgcNF, {"60.957.784/0044-02" } )    
	AAdd( aCgcNF, {"60.957.784/0045-93" } )    
	AAdd( aCgcNF, {"60.957.784/0047-55" } )
	AAdd( aCgcNF, {"60.957.784/0054-84" } )
	AAdd( aCgcNF, {"60.957.784/0051-31" } )
	AAdd( aCgcNF, {"60.957.784/0056-46" } )
	AAdd( aCgcNF, {"60.957.784/0051-31" } )
	AAdd( aCgcNF, {"60.957.784/0056-46" } )
	AAdd( aCgcNF, {"60.957.784/0064-56" } )
	AAdd( aCgcNF, {"60.957.784/0066-18" } )
	AAdd( aCgcNF, {"60.957.784/0067-07" } )
	AAdd( aCgcNF, {"60.957.784/0069-60" } ) 
	AAdd( aCgcNF, {"60.957.784/0070-02" } ) 
	AAdd( aCgcNF, {"60.957.784/0071-85" } )
	AAdd( aCgcNF, {"60.957.784/0072-66" } )
	AAdd( aCgcNF, {"60.957.784/0073-47" } )
	AAdd( aCgcNF, {"60.957.784/0074-28" } )
	AAdd( aCgcNF, {"60.957.784/0075-09" } )
	AAdd( aCgcNF, {"60.957.784/0077-70" } )
	AAdd( aCgcNF, {"60.957.784/0080-76" } )
	AAdd( aCgcNF, {"60.957.784/0076-90" } )
	AAdd( aCgcNF, {"60.957.784/0082-38" } ) 	
	AAdd( aCgcNF, {"60.957.784/0083-19" } )
	AAdd( aCgcNF, {"60.957.784/0085-80" } )
	AAdd( aCgcNF, {"60.957.784/0087-42" } )
	AAdd( aCgcNF, {"60.957.784/0091-29" } )	
	AAdd( aCgcNF, {"60.957.784/0090-48" } )		
	AAdd( aCgcNF, {"60.957.784/0088-23" } )
	Aadd( aCgcNF, {"60.957.784/0086-61" } )
	Aadd( aCgcNF, {"60.957.784/0061-03" } )
	AAdd( aCgcNF, {"60.957.784/0092-00" } )
	AAdd( aCgcNF, {"60.957.784/0093-90" } )
	AAdd( aCgcNF, {"60.957.784/0089-04" } )
	AAdd( aCgcNF, {"60.957.784/0094-71" } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CURINGA DOS PNEUS LTDA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCgcNF, {"00.041.327/0043-60" } )
	AAdd( aCgcNF, {"00.041.327/0049-56" } )
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DACOSTA COMERCIO DE PNEUS - GRUPO DELLA VIA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	AAdd( aCgcNF, {"05.472.446/0001-32" } ) 
	AAdd( aCgcNF, {"05.472.446/0002-13" } ) 
	AAdd( aCgcNF, {"05.472.446/0003-02" } ) 
	AAdd( aCgcNF, {"05.472.446/0004-85" } ) 
	AAdd( aCgcNF, {"05.472.446/0005-66" } ) 
	AAdd( aCgcNF, {"05.472.446/0006-47" } ) 
	AAdd( aCgcNF, {"05.472.446/0007-28" } ) 
	AAdd( aCgcNF, {"05.472.446/0008-09" } )       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³COOPERATIVA CENTRAL DOS PRODUTORES RURAIS DE MINAS GERAIS LTDA.³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	AAdd( aCgcNF, {"17.249.111/0014-53"}  ) //ITAMBÉ   
	AAdd( aCgcNF, {"20.219.382/0001-56"}  ) //ITAMBE
	AAdd( aCgcNF, {"19.715.523/0001-42"}  ) //ITAMBE
	AAdd( aCgcNF, {"09.451.214/0033-36"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0003-09"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0009-96"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0010-20"}  ) //ITAMBE
	AAdd( aCgcNF, {"52.106.911/0001-00"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0028-59"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0031-54"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0032-35"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0035-88"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0052-89"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0060-99"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0061-70"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0064-12"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0068-46"}  ) //ITAMBE
	AAdd( aCgcNF, {"17.249.111/0078-18"}  ) //ITAMBE
	AAdd( aCgcNF, {"19.714.245/0001-09"}  ) //ITAMBE
	AAdd( aCgcNF, {"19.715.523/0001-42"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0001-56"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0002-37"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0004-07"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0008-22"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0009-03"}  ) //ITAMBE
	AAdd( aCgcNF, {"02.959.655/0003-89"}  ) //ITAMBE
	AAdd( aCgcNF, {"02.959.655/0002-06"}  ) //ITAMBE
	AAdd( aCgcNF, {"06.036.387/0002-01"}  ) //ITAMBE
	AAdd( aCgcNF, {"06.944.301/0001-50"}  ) //ITAMBE
	AAdd( aCgcNF, {"08.409.101/0001-22"}  ) //ITAMBE
	AAdd( aCgcNF, {"20.219.382/0004-07"}  ) //ITAMBE
	
	AAdd( aCgcNF, {"53.794.996/0004-63" } ) //CASA J NAKAO LTDA UF: SP
	AAdd( aCgcNF, {"53.794.996/0001-10" } ) //CASA J NAKAO LTDA UF: SP
	AAdd( aCgcNF, {"53.794.996/0003-82" } ) //CASA J NAKAO LTDA UF: SP
	
	
	//AGUILERA AUTOPEÇAS LTDA - MT 
	AAdd( aCgcNF, { "37.525.771/0001-02" } )
	AAdd( aCgcNF, { "37.525.771/0002-93" } )
	AAdd( aCgcNF, { "37.525.771/0003-74" } )
	AAdd( aCgcNF, { "37.525.771/0004-55" } )
	AAdd( aCgcNF, { "37.525.771/0005-36" } )
	AAdd( aCgcNF, { "37.525.771/0006-17" } )
	AAdd( aCgcNF, { "37.525.771/0007-06" } )
	AAdd( aCgcNF, { "37.525.771/0008-89" } )
	AAdd( aCgcNF, { "37.525.771/0009-60" } )
	AAdd( aCgcNF, { "37.525.771/0010-01" } )
	AAdd( aCgcNF, { "37.525.771/0011-84" } )
	AAdd( aCgcNF, { "37.525.771/0012-65" } )
	AAdd( aCgcNF, { "37.525.771/0013-46" } )
	AAdd( aCgcNF, { "37.525.771/0014-27" } )
	AAdd( aCgcNF, { "37.525.771/0015-08" } )
	AAdd( aCgcNF, { "37.525.771/0016-99" } )
	AAdd( aCgcNF, { "37.525.771/0017-70" } )
	AAdd( aCgcNF, { "37.525.771/0018-50" } )
	AAdd( aCgcNF, { "37.525.771/0019-31" } )
	AAdd( aCgcNF, { "37.525.771/0020-75" } )
	AAdd( aCgcNF, { "37.525.771/0021-56" } )
	AAdd( aCgcNF, { "37.525.771/0022-37" } )
	AAdd( aCgcNF, { "37.525.771/0023-18" } )
	AAdd( aCgcNF, { "37.525.771/0024-07" } )
	
	AAdd( aCgcNF, { "07.270.160/0001-08" } ) //COMERCIO DE PEÇAS VERDE LUCAS LTDA - MT - FILIAL 
	AAdd( aCgcNF, { "11.615.634/0001-75" } ) //COMÉRCIO DE PEÇAS GLOBAL LTDA - MT - FILIAL
	AAdd( aCgcNF, { "13.448.434/0001-09" } ) //COMERCIO DE AUTOPEÇAS COLIDER LTDA - MT - FILIAL
	
	//AGUILERA & CIA LTDA - RO 
	AAdd( aCgcNF, { "04.115.428/0001-30" } )
	AAdd( aCgcNF, { "04.115.428/0002-11" } )
	AAdd( aCgcNF, { "04.115.428/0003-00" } )
	AAdd( aCgcNF, { "04.115.428/0004-83" } )
	AAdd( aCgcNF, { "04.115.428/0005-64" } )
	
	//Santa Rita
	AAdd( aCgcNF, {"86.365.350/0005-09"}  )
	AAdd( aCgcNF, {"86.365.350/0012-20"}  )
	AAdd( aCgcNF, {"86.365.350/0001-77"}  )
	AAdd( aCgcNF, {"86.365.350/0002-58"}  )
	AAdd( aCgcNF, {"86.365.350/0004-10"}  )
	AAdd( aCgcNF, {"86.365.350/0008-43"}  )
	AAdd( aCgcNF, {"86.365.350/0006-81"}  )
	AAdd( aCgcNF, {"86.365.350/0010-68"}  )
	AAdd( aCgcNF, {"86.365.350/0013-00"}  )
	AAdd( aCgcNF, {"86.365.350/0014-91"}  )
	AAdd( aCgcNF, {"86.365.350/0021-10"}  )
	
	
	AAdd( aCgcNF, { "00.777.674/0008-73" } )	
	AAdd( aCgcNF, { "00.777.674/0009-54" } )	
	AAdd( aCgcNF, { "00.777.674/0002-88" } )	
	AAdd( aCgcNF, { "01.396.282/0001-50" } )	
	
	
	//PLASTIREAL INDUSTRIA E COMERCIO DE PLASTICOS LTDA
	AAdd( aCgcNF, { "53.234.274/0001-01" } )
	
	//MTI EXP E REP LTDA
	AAdd( aCgcNF, { "04.326.492/0001-60" } )
	AAdd( aCgcNF, { "04.326.492/0008-37" } )
	AAdd( aCgcNF, { "04.326.492/0024-57" } )
	AAdd( aCgcNF, { "04.326.492/0006-75" } )
	
	//Schirmann
	AAdd( aCgcNF, { "88.579.701/0001-78" } )
	
	//Comando Auto Peças Ltda.
	AAdd( aCgcNF, { "01.032.275/0001-70" } )
	AAdd( aCgcNF, { "01.032.275/0002-50" } )
	AAdd( aCgcNF, { "01.032.275/0004-12" } )
	AAdd( aCgcNF, { "01.032.275/0003-31" } )
	AAdd( aCgcNF, { "01.032.275/0005-01" } )
	AAdd( aCgcNF, { "01.032.275/0006-84" } )
	AAdd( aCgcNF, { "01.032.275/0007-65" } )
	AAdd( aCgcNF, { "01.032.275/0008-46" } )
	
	//Direção Produtos Automotivos Ltda.
	AAdd( aCgcNF, { "08.184.963/0001-02" } )
	AAdd( aCgcNF, { "08.184.963/0002-85" } )
	AAdd( aCgcNF, { "08.184.963/0003-66" } )
	
	//Distribuidora de Peças Kampeão Ltda.
	AAdd( aCgcNF, { "38.060.430/0001-71" } )
	AAdd( aCgcNF, { "38.060.430/0002-52" } )
	
	//Contagem Motor Peças
	AAdd( aCgcNF, { "02.633.281/0001-45" } )
	AAdd( aCgcNF, { "10.418.748/0001-62" } )
	AAdd( aCgcNF, { "19.446.980/0001-89" } )
	
	//Cooper Sucesso
	AAdd( aCgcNF, { "08.112.721/0003-67" } )
	
	//RICCIERI CONFECCOES LTDA
	AAdd( aCgcNF, { "75.456.764/0006-08" } )
	AAdd( aCgcNF, { "75.456.764/0007-80" } )
	
	//Moderna Auto Pecas
	AAdd( aCgcNF, { "00.679.038/0001-32" } )
EndIf

If nMVLJLBNT > 0
	lRet	:= .T.
Else
	/* Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso */
	nPos:= Ascan(aCgcNF,{|x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )
	If nPos > 0
		lRet:= .T.
	Else
		lRet := .F.
	Endif
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfPtgNEcf ³ Autor ³ Vendas Clientes     ³ Data ³ 10.06.10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Indica se desabilitara ECF para FrontLoja em PTG e ANG.	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - M0_CGC codigo do cliente							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja												   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNfPtgNEcf(cCnpj) 
Local lRet 		:= .F. 				// Indica se esta habilitado para utilizar essa funcionalidade
Local nPos 		:= 0             	// Indica se encontrou no o CGC no array
Local aCgc		:= {}              	// Array contendo o codigo dos clientes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Lozalizacoes ³
//³Paises:Chile/Colombia -F1CHI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5	:=	cPaisLoc $ "CHI|COL"

If cPaisLoc == "PTG" .OR. cPaisLoc == "ANG"

	cCnpj := AllTrim(cCnpj)    

	AAdd( aCgc, {""} )    	// Adicionar o M0_CGC do cliente PROSYS atendido pela unidade de Portugal
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos:= Ascan(aCgc,{|x| x[1] == Transform( cCnpj, "@R 99999999999999999999" ) } )
	
	If nPos > 0
		lRet:= .T.
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desabilita utilizacao do ECF ³
//³se o usuario nao eh caixa. 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLocR5
	lRet:= .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjNfVldImp ºAutor  ³Vendas Clientes     º Data ³  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adequacao conforme Ricms/2002 – Anexo VII – Seção IV – Art. º±±
±±º			 ³21 a 28 - emitir NF atraves de impressora de nao-impacto    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjNfVldImp()

Local lRet      := .F.
Local aCNPJ		:= {}						
Local nPosCNPJ  := 0
Local cCNPJ     := SM0->M0_CGC

//ÚÄÄÄÄÄÄ¿
//³ITAMBE³
//ÀÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"17.249.111/0003-09" } )
AAdd( aCNPJ, {"17.249.111/0009-96" } )			
AAdd( aCNPJ, {"17.249.111/0010-20" } )			
AAdd( aCNPJ, {"17.249.111/0011-00" } )			
AAdd( aCNPJ, {"17.249.111/0014-53" } )			
AAdd( aCNPJ, {"17.249.111/0028-59" } )			
AAdd( aCNPJ, {"17.249.111/0031-54" } )			
AAdd( aCNPJ, {"17.249.111/0032-35" } )			
AAdd( aCNPJ, {"17.249.111/0033-16" } )			
AAdd( aCNPJ, {"17.249.111/0035-88" } )			
AAdd( aCNPJ, {"17.249.111/0040-45" } )			
AAdd( aCNPJ, {"17.249.111/0045-50" } )			
AAdd( aCNPJ, {"17.249.111/0050-17" } )			
AAdd( aCNPJ, {"17.249.111/0051-06" } )			
AAdd( aCNPJ, {"17.249.111/0052-89" } )			
AAdd( aCNPJ, {"17.249.111/0055-21" } )			
AAdd( aCNPJ, {"17.249.111/0057-93" } )			
AAdd( aCNPJ, {"17.249.111/0060-99" } )			
AAdd( aCNPJ, {"17.249.111/0061-70" } )			
AAdd( aCNPJ, {"17.249.111/0064-12" } )			
AAdd( aCNPJ, {"17.249.111/0068-46" } )			
AAdd( aCNPJ, {"17.249.111/0069-27" } )			
AAdd( aCNPJ, {"17.249.111/0070-60" } )			
AAdd( aCNPJ, {"17.249.111/0078-18" } )			
AAdd( aCNPJ, {"19.714.245/0001-09" } )	
AAdd( aCNPJ, {"19.715.523/0001-42" } )		
AAdd( aCNPJ, {"20.219.382/0001-56" } )			
AAdd( aCNPJ, {"20.219.382/0002-37" } )			
AAdd( aCNPJ, {"20.219.382/0004-07" } )			
AAdd( aCNPJ, {"20.219.382/0008-22" } )			
AAdd( aCNPJ, {"20.219.382/0009-03" } )
AAdd( aCNPJ, {"02.959.655/0001-17" } )	
AAdd( aCNPJ, {"02.499.319/0001-39" } )
AAdd( aCNPJ, {"02.959.655/0004-60" } )
AAdd( aCNPJ, {"02.959.655/0003-89" } )
AAdd( aCNPJ, {"02.959.655/0002-06" } )
AAdd( aCNPJ, {"06.036.387/0001-12" } )			
AAdd( aCNPJ, {"06.036.387/0002-01" } )			
AAdd( aCNPJ, {"06.944.301/0001-50" } )			
AAdd( aCNPJ, {"08.331.425/0001-95" } )
AAdd( aCNPJ, {"08.409.101/0001-22" } )
AAdd( aCNPJ, {"52.106.911/0001-00" } )

nPosCNPJ := Ascan( aCNPJ, { |x| x[1] == Transform( cCNPJ, "@R 99.999.999/9999-99" ) } )
If nPosCNPJ > 0
   lRet := .T.				
Else
   lRet := .F.				
Endif   

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNImpSped  ³ Autor ³ Vendas Cliente      ³ Data ³ 27.08.10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Autorizacao para gerar os dados sem que seja exibida a tela  ³±±
±±³			 ³ de impressão do documento caso a especie for SPED			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validacao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNImpSped(cCnpj) 

Local lRet 		:= .F. 
Local nPos 		:= 0
Local aCNPJ   	:= {}

cCnpj := AllTrim(cCnpj) 
   
/*Pneuac Comercial e Importadora LTDA*/
AAdd( aCNPJ, {"61.234.985/0002-95" } )
AAdd( aCNPJ, {"61.234.985/0004-57" } )
AAdd( aCNPJ, {"61.234.985/0066-50" } )
AAdd( aCNPJ, {"61.234.985/0065-79" } )    
AAdd( aCNPJ, {"61.234.985/0081-99" } )
AAdd( aCNPJ, {"61.234.985/0068-11" } )    
AAdd( aCNPJ, {"61.234.985/0008-80" } )
AAdd( aCNPJ, {"61.234.985/0001-04" } )
AAdd( aCNPJ, {"61.234.985/0011-86" } )
AAdd( aCNPJ, {"61.234.985/0009-61" } )
AAdd( aCNPJ, {"61.234.985/0012-67" } )
AAdd( aCNPJ, {"61.234.985/0014-29" } )
AAdd( aCNPJ, {"61.234.985/0015-00" } )
AAdd( aCNPJ, {"61.234.985/0017-71" } )
AAdd( aCNPJ, {"61.234.985/0020-77" } )
AAdd( aCNPJ, {"61.234.985/0022-39" } )
AAdd( aCNPJ, {"61.234.985/0052-54" } )
AAdd( aCNPJ, {"61.234.985/0058-40" } )
AAdd( aCNPJ, {"61.234.985/0061-45" } )
AAdd( aCNPJ, {"61.234.985/0063-07" } )
AAdd( aCNPJ, {"61.234.985/0049-59" } )
AAdd( aCNPJ, {"61.234.985/0047-97" } )
AAdd( aCNPJ, {"61.234.985/0036-34" } )
AAdd( aCNPJ, {"61.234.985/0007-08" } )
AAdd( aCNPJ, {"61.234.985/0078-93" } )
AAdd( aCNPJ, {"61.234.985/0079-74" } )
AAdd( aCNPJ, {"61.234.985/0076-21" } )
AAdd( aCNPJ, {"61.234.985/0075-40" } )
AAdd( aCNPJ, {"61.234.985/0073-89" } )
AAdd( aCNPJ, {"61.234.985/0026-62" } )
AAdd( aCNPJ, {"61.234.985/0019-33" } )
AAdd( aCNPJ, {"61.234.985/0027-43" } )
AAdd( aCNPJ, {"61.234.985/0030-49" } )
AAdd( aCNPJ, {"61.234.985/0064-98" } )
AAdd( aCNPJ, {"61.234.985/0074-60" } )
AAdd( aCNPJ, {"61.234.985/0033-91" } )  
AAdd( aCNPJ, {"61.234.985/0071-17" } ) 
AAdd( aCNPJ, {"61.234.985/0021-58" } )    
AAdd( aCNPJ, {"61.234.985/0077-02" } )    
AAdd( aCNPJ, {"61.234.985/0023-10" } )  
AAdd( aCNPJ, {"61.234.985/0034-72" } )  
AAdd( aCNPJ, {"61.234.985/0080-08" } )  
AAdd( aCNPJ, {"61.234.985/0025-81" } )
AAdd( aCNPJ, {"83.008.425/0001-74" } )

//ÚÄÄÄÄÄÄÄ¿
//³ITAMBE ³
//ÀÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"17.249.111/0003-09" } )
AAdd( aCNPJ, {"17.249.111/0009-96" } )
AAdd( aCNPJ, {"17.249.111/0010-20" } )
AAdd( aCNPJ, {"17.249.111/0011-00" } )
AAdd( aCNPJ, {"17.249.111/0014-53" } )
AAdd( aCNPJ, {"17.249.111/0028-59" } )
AAdd( aCNPJ, {"17.249.111/0031-54" } )
AAdd( aCNPJ, {"17.249.111/0032-35" } )
AAdd( aCNPJ, {"17.249.111/0033-16" } )
AAdd( aCNPJ, {"17.249.111/0035-88" } )
AAdd( aCNPJ, {"17.249.111/0040-45" } )
AAdd( aCNPJ, {"17.249.111/0045-50" } )
AAdd( aCNPJ, {"17.249.111/0050-17" } )
AAdd( aCNPJ, {"17.249.111/0051-06" } )
AAdd( aCNPJ, {"17.249.111/0052-89" } )
AAdd( aCNPJ, {"17.249.111/0055-21" } )
AAdd( aCNPJ, {"17.249.111/0057-93" } )
AAdd( aCNPJ, {"17.249.111/0060-99" } )
AAdd( aCNPJ, {"17.249.111/0061-70" } )
AAdd( aCNPJ, {"17.249.111/0064-12" } )
AAdd( aCNPJ, {"17.249.111/0068-46" } )
AAdd( aCNPJ, {"17.249.111/0069-27" } )
AAdd( aCNPJ, {"17.249.111/0070-60" } )
AAdd( aCNPJ, {"17.249.111/0078-18" } )
AAdd( aCNPJ, {"19.714.245/0001-09" } )
AAdd( aCNPJ, {"19.715.523/0001-42" } )
AAdd( aCNPJ, {"20.219.382/0001-56" } )
AAdd( aCNPJ, {"20.219.382/0002-37" } )
AAdd( aCNPJ, {"20.219.382/0008-22" } )
AAdd( aCNPJ, {"20.219.382/0009-03" } )
AAdd( aCNPJ, {"02.959.655/0004-60" } )
AAdd( aCNPJ, {"02.959.655/0003-89" } )
AAdd( aCNPJ, {"02.959.655/0002-06" } )
AAdd( aCNPJ, {"06.036.387/0002-01" } )
AAdd( aCNPJ, {"06.944.301/0001-50" } )
AAdd( aCNPJ, {"08.331.425/0001-95" } )
AAdd( aCNPJ, {"08.409.101/0001-22" } )
AAdd( aCNPJ, {"20.219.382/0004-07" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CURINGA DOS PNEUS LTDA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCNPJ, {"00.041.327/0030-46" } )
AAdd( aCNPJ, {"00.041.327/0002-92" } )
AAdd( aCNPJ, {"00.041.327/0026-60" } )
AAdd( aCNPJ, {"00.041.327/0051-70" } )
AAdd( aCNPJ, {"00.041.327/0010-00" } )
AAdd( aCNPJ, {"00.041.327/0025-89" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DELLA VIA DE PNEUS 				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
AAdd( aCNPJ, {"60.957.784/0001-72" } )    
AAdd( aCNPJ, {"60.957.784/0002-53" } )    
AAdd( aCNPJ, {"60.957.784/0003-34" } )    
AAdd( aCNPJ, {"60.957.784/0004-15" } )    
AAdd( aCNPJ, {"60.957.784/0005-04" } )    
AAdd( aCNPJ, {"60.957.784/0006-87" } )    
AAdd( aCNPJ, {"60.957.784/0007-68" } )    
AAdd( aCNPJ, {"60.957.784/0049-17" } )    
AAdd( aCNPJ, {"60.957.784/0009-20" } )    
AAdd( aCNPJ, {"60.957.784/0010-63" } )    
AAdd( aCNPJ, {"60.957.784/0011-44" } )    
AAdd( aCNPJ, {"60.957.784/0012-25" } )    
AAdd( aCNPJ, {"60.957.784/0013-06" } )    
AAdd( aCNPJ, {"60.957.784/0014-97" } )    
AAdd( aCNPJ, {"60.957.784/0015-78" } )    
AAdd( aCNPJ, {"60.957.784/0016-59" } )    
AAdd( aCNPJ, {"60.957.784/0017-30" } )    
AAdd( aCNPJ, {"60.957.784/0018-10" } )    
AAdd( aCNPJ, {"60.957.784/0019-00" } )    
AAdd( aCNPJ, {"60.957.784/0020-35" } )    
AAdd( aCNPJ, {"60.957.784/0021-16" } )    
AAdd( aCNPJ, {"60.957.784/0024-69" } )    
AAdd( aCNPJ, {"60.957.784/0025-40" } )    
AAdd( aCNPJ, {"60.957.784/0026-20" } )    
AAdd( aCNPJ, {"60.957.784/0028-92" } )    
AAdd( aCNPJ, {"60.957.784/0029-73" } )    
AAdd( aCNPJ, {"60.957.784/0033-50" } )    
AAdd( aCNPJ, {"60.957.784/0053-01" } )    
AAdd( aCNPJ, {"60.957.784/0037-83" } )    
AAdd( aCNPJ, {"60.957.784/0038-64" } )    
AAdd( aCNPJ, {"60.957.784/0039-45" } )    
AAdd( aCNPJ, {"60.957.784/0027-01" } )    
AAdd( aCNPJ, {"60.957.784/0040-89" } )    
AAdd( aCNPJ, {"60.957.784/0041-60" } )    
AAdd( aCNPJ, {"60.957.784/0042-40" } )    
AAdd( aCNPJ, {"60.957.784/0043-21" } )    
AAdd( aCNPJ, {"60.957.784/0046-74" } )    
AAdd( aCNPJ, {"60.957.784/0048-36" } )    
AAdd( aCNPJ, {"60.957.784/0055-65" } )    
AAdd( aCNPJ, {"60.957.784/0008-49" } )    
AAdd( aCNPJ, {"60.957.784/0023-88" } )    
AAdd( aCNPJ, {"60.957.784/0032-79" } )    
AAdd( aCNPJ, {"60.957.784/0036-00" } )    
AAdd( aCNPJ, {"60.957.784/0044-02" } )    
AAdd( aCNPJ, {"60.957.784/0045-93" } )    
AAdd( aCNPJ, {"60.957.784/0047-55" } )       
AAdd( aCNPJ, {"60.957.784/0054-84" } )
AAdd( aCNPJ, {"60.957.784/0051-31" } )
AAdd( aCNPJ, {"60.957.784/0056-46" } )  
AAdd( aCNPJ, {"60.957.784/0070-02" } )
AAdd( aCNPJ, {"60.957.784/0069-60" } )  
AAdd( aCNPJ, {"60.957.784/0071-85" } )  
AAdd( aCNPJ, {"60.957.784/0072-66" } )  
AAdd( aCNPJ, {"60.957.784/0073-47" } )
AAdd( aCNPJ, {"60.957.784/0076-90" } )  
AAdd( aCNPJ, {"60.957.784/0087-42" } )  
AAdd( aCNPJ, {"60.957.784/0091-29" } )	
AAdd( aCNPJ, {"60.957.784/0090-48" } )		
AAdd( aCNPJ, {"60.957.784/0088-23" } )
Aadd( aCNPJ, {"60.957.784/0086-61" } ) 
Aadd( aCNPJ, {"60.957.784/0093-90" } )
AAdd( aCNPJ, {"60.957.784/0089-04" } )
AAdd( aCNPJ, {"60.957.784/0094-71" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o CNPJ da filial corrente estiver em nossa lista, utiliza o recurso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos:= Ascan(aCNPJ,{|x| x[1] == Transform( cCnpj, "@R 99.999.999/9999-99" ) } )

If nPos > 0
	lRet:= .T.
Endif
	
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjEmitNFCe  ³ Autor ³ Vendas Cliente      ³ Data ³ 28.03.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se NFC-e Habilitado na estação						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico(Static para otimizar diversas chamadas		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjEmitNFCe() 

Local lPOS 		:= STFIsPOS()
Local lIsMDI	:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI

If FunName() == "FATA701" .OR. nModulo == 5  //Venda direta não emite NFCe
	lGetNFCe := .F.
ElseIf !lIsMDI .Or. Select("SLG") > 0
	//------------------------------------------------------------------
	// Regra para utilizar NFC-e:
	// - Estado(UF)(AnalisaLeg(61)) ter cronograma oficial divulgado
	// - Possuir impressora não fiscal cadastrada na estacao(LG_IMPFISC)
	//------------------------------------------------------------------
	If ValType(lGetNFCe) == "U" .Or. ValType(lGetNFCe) == "L" .And. !lGetNFCe
		If LjAnalisaLeg(61)[1] .AND. SLG->(ColumnPos("LG_NFCE")) > 0
			If lPos
				lGetNFCe := IIf(STFGetStat("NFCE"), .T., .F.)
			Else
				lGetNFCe := IIf(LJGetStation("NFCE"), .T., .F.)
			EndIf
		Else
			lGetNFCe := .F.
		EndIf
		
		// Valida SAT com NFCE
		// Pois utiliza as mesmas rotinas com desvios nas mesmas, quando há diferenca 
		If !lGetNFCe .AND. SLG->(ColumnPos("LG_USESAT")) > 0
			lGetNFCe 	:= IIF( LJGetStation("USESAT") == Nil , .F. , LJGetStation("USESAT") )
		Endif		
	EndIf
EndIf

Return lGetNFCe


//--------------------------------------------------------
/*/{Protheus.doc} LjResetNFCe
Reseta variavel statica lGetNFCe para que na proxima chamada da LjEmitNFCe
seja reavalida a regra de negocio da NFCE
@type function
@author  	rafael.pessoa
@since   	20/02/2017
@version 	P12
@param 		@return		Nil
/*/
//--------------------------------------------------------
Function LjResetNFCe()
lGetNFCe := Nil
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjNfGrvAuto  ³ Autor ³ Vendas Cliente      ³ Data ³ 28.03.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se CNPJ(faixa) permite utilizar ExecAuto(Loja701)   ³±±
±±³			 ³ para gravar venda											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Cnpj para a validacao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico									                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja 												    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjNFGrvAuto(cCNPJ)

	Local cRaiz		:= ""		//CNPJ raiz (8 primeiros digitos)
	Local lRet 		:= .F.		//indica se pode gravar o orçamento como Venda
	Local aExAuNFCe	:= {}		//CNPJ raizes que permitem a gravação do orçamento como Venda

	Default cCNPJ	:= ""

	cRaiz := SubStr(cCNPJ,1,8)

	//---
	// Utilizacao da ExecAuto LOJA701 para gravação do orçamento como Venda.
	// Não adicionar nenhum CNPJ raiz, sem antes falar com o líder de Manutenção do Varejo
	// IMPORTANTE: Modo de gravacao validado apenas para NFC-e
	//---
	Aadd( aExAuNFCe, {"04415928"} )	//LOJAS BECKER	(Participativo)
	Aadd( aExAuNFCe, {"37525771"} )	//CASTRILLON AUTO PEÇAS - AGUILERA
	Aadd( aExAuNFCe, {"53113791"} )	//TOTVS , para testes
	Aadd( aExAuNFCe, {"12345678"} )	//EPSON , para testes
	Aadd( aExAuNFCe, {"82373077"} )	//Bematech , para testes
	Aadd( aExAuNFCe, {"03339493"} )	//MODA MODAL LTDA - LOJAS FARINA
	Aadd( aExAuNFCe, {"04115428"} )	//AGUILERA & CIA LTDA
	Aadd( aExAuNFCe, {"12145475"} )	//AGUILERA AUTOPECAS DE GOIAS LTDA
	Aadd( aExAuNFCe, {"07270160"} )	//COMERCIO DE PECAS VERDE LUCAS LTDA
	Aadd( aExAuNFCe, {"12710274"} )	//AGUILERA DISTRIBUIDORA DE AUTOPECAS LTDA
	Aadd( aExAuNFCe, {"37598221"} )	//LOJAS FARINA POCOS DE CALDAS EIRELI
	Aadd( aExAuNFCe, {"38090048"} )	//LOJAS FARINA POUSO ALEGRE EIRELI
	Aadd( aExAuNFCe, {"37396172"} )	//LOJAS FARINA VARGINHA EIRELI

lRet := Ascan( aExAuNFCe, {|x| x[1] == cRaiz} ) > 0

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} LjRstLjNf()
Resseta todas as variáveis static deste fonte.

@type function
@param 		nil
@author  	marisa.cruz
@since   	05/06/2020
@version 	P12
@return		Nil
/*/
//--------------------------------------------------------
Function LjRstLjNf()

//Variáveis Static
aCNPJNF  := {}              //CNPJs validos para impressao de nota fiscal
aCnpjPaf := {}              //cnpjS validos para utilizacao do PAF-ECF
aCnpjNoPaf:= {}				//cnpjs que podem funcionar sem paf porem não usam ECF
aCnpjExPaf:= {}				//cnpjs que podem funcionar sem paf (excecao mediante a apresentacao de documento/acordo sefaz)
lPafEcf	:= NIL				//verifica se ambiente esta no PAF-ECF
lGetNFCe := Nil				//Retorna se Estacao Configurada para utilizar NFCe
cPDVECF	:= ""		        //Serie do ECF, pois nos Estados que entregam o gerencial de Identificacao do PAF a liberação ocorre por ECF

Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} LjIsDro
	Valida o uso do template de Drogaria conforme o CNPJ.
	@type  Function
	@author Julio.Nery
	@since 29/01/2021
	@version 12
	@param cCNPJ, Caracter, Número do CNPJ
	@return lRet, logico, permite o uso do template de Drogaria?
/*/
//------------------------------------------------------------------------------
Function LjIsDro(cCNPJ)
Local lRet 		:= .F.

If ExistTemplate("VldIsDro")
    If Empty(cCNPJ)
        cCNPJ := SM0->M0_CGC
    EndIf
	lRet := ExecTemplate("VldIsDro",.F.,.F.,{cCNPJ})
Endif

Return lRet