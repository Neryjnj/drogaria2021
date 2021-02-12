#INCLUDE "MSOBJECT.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
   
#DEFINE NOMEARQ IIF(IsInCallStack("T_DROInvWizard"),"INVENTAR.XML","ANVISA.XML")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipo de dados da consultaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ENTRADA 	"1"
#DEFINE SAIDAVEND 	"2"
#DEFINE SAIDATRANS	"3"
#DEFINE SAIDAPERD 	"4"
#DEFINE INVPROD	 	"5"


User Function DRO003 ; Return  // "dummy" function - Internal Use 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณDROXMLAnvisa     บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em gerar o XML na estrutura estabelecida pela   บฑฑ
ฑฑบ			 ณAnvisa (Agencia Nacinal de Vigilancia Sanitaria).					 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Class DROXMLAnvisa From LJAXml
	
	Data cCnpj												//Cnpj do emissor
	Data cCpf												//Cpf do transmissor
	Data dDtInicio											//Data inicio
	Data dDtFim												//Data fim
	Data oXMLANVISA											//Objeto XML

	Data oAnvisaEnt											//Objeto com os dados de movimetacoes de Entrada
	Data oAnvisaSai											//Objeto com os dados de movimetacoes de Saida Venda
	Data oAnvisaPer											//Objeto com os dados de movimetacoes de Saida Perda
	Data oAnvisaTra											//Objeto com os dados de movimetacoes de Saida Transferencia
	Data oAnvisaINV											//Objeto com os dados de Invetario
	
	Method Anvisa(cCnpj, cCpf, dDtInicio, dDtFim, ;
				  cPath)									//Metodo construtor
	//Metodos internos
	Method Consulta()				  						//Metodo que ira carregar os dados de entrada, saida, perda e transferencia
	Method ConsultaInv()				  					//Metodo que ira carregar os dados de Inventario
	Method Gerar()											//Metodo que ira gerar e gravar o Xml
	Method GerarInv()										//Metodo que ira gerar os arquivos de Inventario
	Method EstrutXML()										//Metodo que ira gerar a estrutura do XML.
	Method EstrutINV()										//Metodo que ira gerar a estrutura do Inventario XML.
	Method Cabecalho()										//Metodo que ira carregar os dados do cabecalho
	Method CabecalhoInv()									//Metodo que ira carregar os dados do cabecalho de invetario
	Method Entrada()										//Metodo que ira carregar os dados da entrada de medicamento no arquivo XML
	Method Inventario()										//Metodo que ira carregar os dados de invetario no arquivo XML
	Method SaidaVenda()										//Metodo que ira carregar os dados de saida de venda consumidor no arquivo XML
	Method SaidaPerda()										//Metodo que ira carregar os dados de saida por perda no arquivo XML
	Method SaidaTrans()										//Metodo que ira carregar os dados de saida por Transferencia no arquivo XML
	Method FormataDt(dData)									//Metodo que ira formatar a data
	Method NodeSaida(oOrigem, oDestino)						//Metodo que ira carregar as propriedades TYPE e REALNAME do node
	Method NodeEnt(oOrigem, oDestino)						//Metodo que ira carregar as propriedades TYPE e REALNAME do node
	Method NodeInv(oOrigem, oDestino)						//Metodo que ira carregar as propriedades TYPE e REALNAME do node
	Method NodeSaiPer(oOrigem, oDestino)					//Metodo que ira carregar as propriedades TYPE e REALNAME do node
	Method NodeSaiTra(oOrigem, oDestino)					//Metodo que ira carregar as propriedades TYPE e REALNAME do node
	Method GetXML()      									//Metodo que ira retornar o objeto oXMLANVISA
	Method SaidaNode(cTpUso, oParent, nCount) 						//Retorna a estrutua do xml de saida
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAnvisa           บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe DROXMLAnvisa.						     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1 (1 - cCnpj) 		- CNPJ do emissor.						 บฑฑ
ฑฑบ			 ณExpN2 (2 - cCpf)  		- CPF do transmissor.					 บฑฑ
ฑฑบ			 ณExpD1 (2 - dDtInicio)  	- Data inicio.							 บฑฑ
ฑฑบ			 ณExpD2 (2 - dDtFim)  		- Data fim.								 บฑฑ
ฑฑบ			 ณExpC1 (2 - cPath)  		- Caminho onde sera gravado o arquivo.	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Anvisa(cCnpj, cCpf, dDtInicio, dDtFim, ;
			  cPath) Class DROXMLAnvisa

	//Executa o metodo construtor da classe pai
	::LJAXml(cPath, NOMEARQ)
	
	//Inicializa variaveis
	::cCnpj 		:= PadR(cCnpj,14,"0")
	::cCpf         	:= PadR(cCpf,11,"0")
	::dDtInicio   	:= dDtInicio
	::dDtFim      	:= dDtFim
	::oXMLANVISA	:= NIL
    
Return Self
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConsulta         บAutor  ณVendas Clientes     บ Data ณ  15/04/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em consultar as movimentacoes dos medicamentos  บฑฑ
ฑฑบ          ณcontrolados                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                      							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNIL   														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Consulta() Class DROXMLAnvisa

//Estancia dos objetos para consultas
::oAnvisaEnt := DROConsultaAnvisa():ConsAnvisa()
::oAnvisaSai := DROConsultaAnvisa():ConsAnvisa()
::oAnvisaPer := DROConsultaAnvisa():ConsAnvisa()
::oAnvisaTra := DROConsultaAnvisa():ConsAnvisa()

//Alimenta os objetos com os dados da consulta
::oAnvisaEnt:ConsDtTp(::dDtInicio, ::dDtFim, ENTRADA)
::oAnvisaSai:ConsDtTp(::dDtInicio, ::dDtFim, SAIDAVEND)
::oAnvisaPer:ConsDtTp(::dDtInicio, ::dDtFim, SAIDAPERD)
::oAnvisaTra:ConsDtTp(::dDtInicio, ::dDtFim, SAIDATRANS)
    
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConsultaInv      บAutor  ณVendas Clientes     บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em consultar os medicamentos 					 บฑฑ
ฑฑบ          ณcontrolados  para inventario                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                      							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNIL   														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConsultaInv() Class DROXMLAnvisa

//Estancia dos objetos para consultas
::oAnvisaINV := DROConsultaAnvisa():ConsAnvisa()

//Alimenta os objetos com os dados da consulta
::oAnvisaINV:ConsDtTp(::dDtInicio,::dDtFim,INVPROD)
    
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGerar            บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em gerar e gravar o XML.   				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Gerar() Class DROXMLAnvisa
	
	Local lRetorno  	:= .F.							//Retorno do metodo
	Local cXML			:= "" 								//XML a ser gravado
	Local cBlocoIni 	:= ""							//Bloco Inicial a ser substituํdo
	Local cBlocoFim 	:= "" 							//Bloco Final a ser substituํdo
	Local cXML2 		:= ""							//XML a ser substituํdo
	Local cBlocoIniR 	:= ""							//Bloco a ser substituํdo
	Local cBlocoFimR 	:= ""							//Bloco Final a ser substotuํdo
	Local nPosBlocoIni 	:= 0							//Posicใo Inicial do Bloco a ser substituํdo
	Local nPosBlocoFim 	:= 0							//Posi็ใo Final do bloco a ser substituํdo
	Local nTamBlocoFim 	:= 0							//Tamanho do bloco final					
	Local cXML3			:= ""							//XML temporแrio	
	Local nPosBlocoIniR := 0							//Tamanho do bloco a ser substituํdo
	Local nTamBlocoR	:= 0							//Tamanhodo bloco a ser substuํdo				
	Local nPosBlocoFimR := 0							//Tamanho do bloco final se ser substituํdo
	
	//Efetua a consulta das movimentacoes do medicamentos controlados
	::Consulta()
	
	//Gera o Objeto XML ANVISA com a estrutura definida
	::oXMLANVISA := ::Criar(::EstrutXML())
	
    //Alimenta os dados do cabecalho
	If ::oXMLANVISA <> NIL
		lRetorno := ::Cabecalho()	
	EndIf
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInformacoes para MEDICAMENTOSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Alimenta os dados de entrada
	If lRetorno
		lRetorno := ::Entrada()	
	EndIf

	//Alimenta os dados de saida por venda
	If lRetorno
		lRetorno := ::SaidaVenda()	
	EndIf
	
	//Alimenta os dados de saida por transferencia
	If lRetorno
		lRetorno := ::SaidaTransf()
	EndIf

	//Alimenta os dados de saida por perda
	If lRetorno
		lRetorno := ::SaidaPerda()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInformacoes para INSUMOSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--
	
	//Transforma o Objeto XML em arquivo
	If lRetorno
		//Realiza o reordenamento do arquivo
		If  ::oAnvisaSai:Count() > 0
			cXML2 := ""
			cXML := ""
			SAVE ::oXml XMLSTRING cXML
			cBlocoIniR := "<saidaMedicamentoVendaAoConsumidor_REPLACED>"
			cBlocoFimR :=  "</saidaMedicamentoVendaAoConsumidor_REPLACED>"
			cBlocoIni := "<saidaMedicamentoVendaAoConsumidor>"
			cBlocoFim := "</saidaMedicamentoVendaAoConsumidor>"	
			nPosBlocoIni := At(cBlocoIni, cXML)
			nPosBlocoFim := RAt(cBlocoFim, cXML)
			nTamBlocoFim := Len(cBlocoFim)
			//Bloco a ser substituido
			cXML2 := Substr( cXML, nPosBlocoIni, ( nPosBlocoFim + nTamBlocoFim ) -  nPosBlocoIni )
			//Texto xml
			cXML := Left( cXML,  nPosBlocoIni -1) + Substr(  cXML, (nPosBlocoFim + nTamBlocoFim )) 
			
			//Bloco a ser retirado
			nPosBlocoIniR := At(cBlocoIniR, cXML)
			nTamBlocoR	:= Len(cBlocoIniR+cBlocoFimR)

			cXML := Left(cXML,nPosBlocoIniR - 1) + cXML2 + Substr(cXML, nPosBlocoIniR+nTamBlocoR)
			oArquivo := LJCArquivo():Arquivo(::cPath, NOMEARQ)
			oArquivo:Criar()
			oArquivo:Escrever(cXML)
			oArquivo:Fechar()
			
			lRetorno := .T.

		Else
			lRetorno := ::Salvar()
		EndIf
	EndIf
	
    
    If lRetorno
	    //Grava o comentario do XML(Provisorio)
		oArquivo := LJCArquivo():Arquivo(::cPath, NOMEARQ)
		oArquivo:Abrir()
		oArquivo:EscrevXML('<?xml version="1.0" encoding="ISO-8859-1"?>')
		oArquivo:Fechar()
		
		//Ponto de Entrada para exporta็ใo das informacoes de cabecalho do XLM
		If ExistBlock("DROXMLCABE")
			Execblock("DROXMLCABE", .F., .F., {::cCnpj, ::cCpf, ::FormataDt(::dDtInicio), ::FormataDt(::dDtFim)})
		EndIf
	Endif

	
Return lRetorno 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEstrutXML        บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em gerar a estrutura do XML.  				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EstrutXML() Class DROXMLAnvisa

	Local cXml := ""								//String com a estrutura do xml  
	
	//Declaracao do XML
	cXml 	:= '<?xml version="1.0" encoding="ISO-8859-1"?>'
	
	cXml 	+= '<mensagemSNGPC xmlns="urn:sngpc-schema">'
	
	//Cabecalho	
	cXml 	+= "	<cabecalho>"
	cXml 	+= "  		<cnpjEmissor></cnpjEmissor>"
	cXml 	+= "		<cpfTransmissor></cpfTransmissor>"
	cXml 	+= "  		<dataInicio></dataInicio>"
	cXml 	+= "  		<dataFim></dataFim>"
	cXml 	+= "	</cabecalho>"
		
	//Corpo
	cXml 	+= "	<corpo>"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMEDICAMENTOS|
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
	cXml 	+= "		<medicamentos>"	
	
	//Entrada de medicamentos
                           If ::oAnvisaEnt:Count() > 0
	cXml 	+= "			<entradaMedicamentos>"
	cXml 	+= "  				<notaFiscalEntradaMedicamento>"
	cXml 	+= "  					<numeroNotaFiscal></numeroNotaFiscal>"
	cXml 	+= "  					<tipoOperacaoNotaFiscal></tipoOperacaoNotaFiscal>"
	cXml 	+= "  					<dataNotaFiscal></dataNotaFiscal>"
	cXml 	+= "  					<cnpjOrigem></cnpjOrigem>"
	cXml 	+= "  					<cnpjDestino></cnpjDestino>"	
	cXml 	+= "  				</notaFiscalEntradaMedicamento>"
	
	cXml 	+= "  				<medicamentoEntrada>"
	cXml 	+= "  					<classeTerapeutica></classeTerapeutica>"   // Versao 2.0
	cXml 	+= "  					<registroMSMedicamento></registroMSMedicamento>"
	cXml 	+= "  					<numeroLoteMedicamento></numeroLoteMedicamento>"
	cXml 	+= "  					<quantidadeMedicamento></quantidadeMedicamento>"
	cXml 	+= "  					<unidadeMedidaMedicamento></unidadeMedidaMedicamento>"  // Versao 2.0
	cXml 	+= "  				</medicamentoEntrada>"
	cXml 	+= "  				<dataRecebimentoMedicamento></dataRecebimentoMedicamento>"	
	cXml 	+= "			</entradaMedicamentos>"
                           Endif	
	//Saida de medicamentos venda ao consumidor
                          If ::oAnvisaSai:Count() > 0
	cXml 	+= "			<saidaMedicamentoVendaAoConsumidor_REPLACED></saidaMedicamentoVendaAoConsumidor_REPLACED>"
/*	cXml 	+= "  				<tipoReceituarioMedicamento></tipoReceituarioMedicamento>"
	cXml 	+= "  				<numeroNotificacaoMedicamento></numeroNotificacaoMedicamento>"
	cXml 	+= "  				<dataPrescricaoMedicamento></dataPrescricaoMedicamento>"
	
	cXml 	+= "  				<prescritorMedicamento>"
	cXml 	+= "  					<nomePrescritor></nomePrescritor>"
	cXml 	+= "  					<numeroRegistroProfissional></numeroRegistroProfissional>"
	cXml 	+= "  					<conselhoProfissional></conselhoProfissional>"
	cXml 	+= "  					<UFConselho></UFConselho>"
	cXml 	+= "  				</prescritorMedicamento>"
	cXml 	+= "  				<usoMedicamento></usoMedicamento>"	
	
	cXml 	+= "  				<compradorMedicamento>"
	cXml 	+= "  					<nomeComprador></nomeComprador>"
	cXml 	+= "  					<tipoDocumento></tipoDocumento>"
	cXml 	+= "  					<numeroDocumento></numeroDocumento>"
	cXml 	+= "  					<orgaoExpedidor></orgaoExpedidor>"
	cXml 	+= "  					<UFEmissaoDocumento></UFEmissaoDocumento>"	
	cXml 	+= "  				</compradorMedicamento>"
	
	cXml 	+= "  				<pacienteMedicamento>"     // Versao 2.0
	cXml 	+= "  					 <nome></nome>"  
	cXml 	+= "  					 <idade></idade>"  
	cXml 	+= "  					 <unidadeIdade></unidadeIdade>"  
	cXml 	+= "  					 <sexo></sexo>"   
	cXml 	+= "  					 <cid></cid>"  
    cXml 	+= " 		        </pacienteMedicamento>"
	
	cXml 	+= "  				<medicamentoVenda>"
	cXml 	+= "  					<usoProlongado></usoProlongado>" // Versao 2.0  
	cXml 	+= "  					<registroMSMedicamento></registroMSMedicamento>"
	cXml 	+= "  					<numeroLoteMedicamento></numeroLoteMedicamento>"
	cXml 	+= "  					<quantidadeMedicamento></quantidadeMedicamento>"
	cXml 	+= "  					<unidadeMedidaMedicamento></unidadeMedidaMedicamento>"  // Versao 2.0
	cXml 	+= "  				</medicamentoVenda>"

	cXml 	+= "  				<dataVendaMedicamento></dataVendaMedicamento>"	
	cXml 	+= "			</saidaMedicamentoVendaAoConsumidor>"*/
                           Endif
                           


	//Saida de medicamento transferencia
						   If ::oAnvisaTra:Count() > 0
	cXml 	+= "			<saidaMedicamentoTransferencia>"
	cXml 	+= "  				<notaFiscalTransferenciaMedicamento>"
	cXml 	+= "  					<numeroNotaFiscal></numeroNotaFiscal>"
	cXml 	+= "  					<tipoOperacaoNotaFiscal></tipoOperacaoNotaFiscal>"
	cXml 	+= "  					<dataNotaFiscal></dataNotaFiscal>"
	cXml 	+= "  					<cnpjOrigem></cnpjOrigem>"
	cXml 	+= "  					<cnpjDestino></cnpjDestino>"	
	cXml 	+= "  				</notaFiscalTransferenciaMedicamento>"
	
	cXml 	+= "  				<medicamentoTransferencia>"
	cXml 	+= "  					<registroMSMedicamento></registroMSMedicamento>"
	cXml 	+= "  					<numeroLoteMedicamento></numeroLoteMedicamento>"
	cXml 	+= "  					<quantidadeMedicamento></quantidadeMedicamento>"
	cXml 	+= "  					<unidadeMedidaMedicamento></unidadeMedidaMedicamento>"  // Versao 2.0
	cXml 	+= "  				</medicamentoTransferencia>"
	cXml 	+= "  				<dataTransferenciaMedicamento></dataTransferenciaMedicamento>"	
	cXml 	+= "			</saidaMedicamentoTransferencia>"
                           Endif
	//Saida de medicamento por perda
                           If ::oAnvisaPer:Count() > 0
	cXml 	+= "			<saidaMedicamentoPerda>"
	cXml 	+= "  				<motivoPerdaMedicamento></motivoPerdaMedicamento>"	
	cXml 	+= "  				<medicamentoPerda>"
	cXml 	+= "  					<registroMSMedicamento></registroMSMedicamento>"
	cXml 	+= "  					<numeroLoteMedicamento></numeroLoteMedicamento>"
	cXml 	+= "  					<quantidadeMedicamento></quantidadeMedicamento>"
	cXml 	+= "  					<unidadeMedidaMedicamento></unidadeMedidaMedicamento>"  // Versao 2.0
	cXml 	+= "  				</medicamentoPerda>"
	cXml 	+= "  				<dataPerdaMedicamento></dataPerdaMedicamento>"	
	cXml 	+= "			</saidaMedicamentoPerda>"
                           Endif
	cXml 	+= "		</medicamentos>" 


	//ฺฤฤฤฤฤฤฤฟ
	//ณINSUMOSณ
	//ภฤฤฤฤฤฤฤู
	cXml 	+= "		<insumos></insumos>"	
	
	//Entrada de insumo
	/*
	cXml 	+= "			<entradaInsumos>"    
	
	cXml 	+= "  				<notaFiscalEntradaInsumo>"
	cXml 	+= "  					<numeroNotaFiscal></numeroNotaFiscal>"
	cXml 	+= "  					<tipoOperacaoNotaFiscal></tipoOperacaoNotaFiscal>"
	cXml 	+= "  					<dataNotaFiscal></dataNotaFiscal>"
	cXml 	+= "  					<cnpjOrigem></cnpjOrigem>"
	cXml 	+= "  					<cnpjDestino></cnpjDestino>"	
	cXml 	+= "  				</notaFiscalEntradaInsumo>" 
	
	//cXml 	+= "  				<substanciaInsumoEntrada>"          // Versao 2.0           
	cXml 	+= "  					<insumoEntrada>"
	cXml 	+= "  					<classeTerapeutica></classeTerapeutica>"   // Versao 2.0
	cXml 	+= "  					<codigoInsumo></codigoInsumo>"
	cXml 	+= "  					<numeroLoteInsumo></numeroLoteInsumo>"
	cXml 	+= "  					<insumoCNPJFornecedor></insumoCNPJFornecedor>"
    cXml 	+= " 	 				<quantidadeInsumo></quantidadeInsumo>"    // Versao 2.0 
	cXml 	+= "  					<tipoUnidade></tipoUnidade>"          // Versao 2.0

	cXml 	+= "  				</insumoEntrada>" 
	
	//cXml 	+= "  					<quantidadeInsumoEntrada></quantidadeInsumoEntrada> "   // Versao 2.0 
	//cXml 	+= "  					<tipoUnidadeEntrada></tipoUnidadeEntrada> "             // Versao 2.0
	
//	cXml 	+= "  				</substanciaInsumoEntrada>"       // Versao 2.0  
	
	cXml 	+= "  				<dataRecebimentoInsumo></dataRecebimentoInsumo> " 
		
	cXml 	+= "			</entradaInsumos>"
	
	//Saida de insumo VENDA
	cXml 	+= "			<saidaInsumoVendaAoConsumidor>"
	
	cXml 	+= "  				<tipoReceituarioInsumo></tipoReceituarioInsumo>
	cXml 	+= "  				<numeroNotificacaoInsumo></numeroNotificacaoInsumo>"
	cXml 	+= "  				<dataPrescricaoInsumo></dataPrescricaoInsumo>"
	
	cXml 	+= "  				<prescritorInsumo>"
	cXml 	+= "  					<nomePrescritor></nomePrescritor>"
	cXml 	+= "  					<numeroRegistroProfissional></numeroRegistroProfissional>"
	cXml 	+= "  					<conselhoProfissional></conselhoProfissional>"
	cXml 	+= "  					<UFConselho></UFConselho>"	
	cXml 	+= "  				</prescritorInsumo>"
	
	cXml 	+= "  				<usoInsumo></usoInsumo>" 
	
	cXml 	+= "  				<compradorInsumo>"
	cXml 	+= "  					<nomeComprador></nomeComprador>"
	cXml 	+= "  					<tipoDocumento></tipoDocumento>"
	cXml 	+= "  					<numeroDocumento></numeroDocumento>"
	cXml 	+= "  					<orgaoExpedidor></orgaoExpedidor>"
	cXml 	+= "  					<UFEmissaoDocumento></UFEmissaoDocumento>"
	cXml 	+= "  				</compradorInsumo>"  
	
	cXml 	+= "  				<pacienteInsumo>"     // Versao 2.0
	cXml 	+= "  					<nome></nome>"  
	cXml 	+= "  					 <idade></idade>"  
	cXml 	+= "  					 <unidadeIdade></unidadeIdade>"  
	cXml 	+= "  					 <sexo></sexo>"    
	cXml 	+= "  					 <cid></cid>"  
    cXml 	+= " 		        </pacienteInsumo>"
	
	cXml 	+= "  				<substanciaInsumoVendaAoConsumidor>" 
	cXml 	+= "  					<usoProlongado></usoProlongado>" // Versao 2.0  
	
	cXml 	+= "  					<insumoVendaAoConsumidor>"
	cXml 	+= "  						<codigoInsumo></codigoInsumo>"
	cXml 	+= "  						<numeroLoteInsumo></numeroLoteInsumo>"
	cXml 	+= "  						<insumoCNPJFornecedor></insumoCNPJFornecedor>"
	cXml 	+= "  					</insumoVendaAoConsumidor>" 
	
	cXml 	+= "  					<quantidadeDeInsumoPorUnidadeFarmacotecnica></quantidadeDeInsumoPorUnidadeFarmacotecnica>"
	cXml 	+= "  					<unidadeDeMedidaDoInsumo></unidadeDeMedidaDoInsumo>"
	cXml 	+= "  					<unidadeFarmacotecnica></unidadeFarmacotecnica>"
	cXml 	+= "  					<quantidadeDeUnidadesFarmacotecnicas></quantidadeDeUnidadesFarmacotecnicas>" 
	
	cXml 	+= "  				</substanciaInsumoVendaAoConsumidor>"
	
	cXml 	+= "  				<dataVendaInsumo></dataVendaInsumo>" 
	
	cXml 	+= "			</saidaInsumoVendaAoConsumidor>"


	
	//Saida de insumo TRANSFERENCIA
	cXml 	+= "			<saidaInsumoTransferencia>" 
	
	cXml 	+= "  				<notaFiscalTransferenciaInsumo>"
	cXml 	+= "  					<numeroNotaFiscal></numeroNotaFiscal>"
	cXml 	+= "  					<tipoOperacaoNotaFiscal></tipoOperacaoNotaFiscal>"
	cXml 	+= "  					<dataNotaFiscal></dataNotaFiscal>"
	cXml 	+= "  					<cnpjOrigem></cnpjOrigem>"
	cXml 	+= "  					<cnpjDestino></cnpjDestino>"
	cXml 	+= "  				</notaFiscalTransferenciaInsumo>" 
	
	//cXml 	+= "  				<substanciaInsumoTransferencia>"    Versao 2.0
	cXml 	+= "  					<insumoTransferencia>"
	cXml 	+= "  						<codigoInsumo></codigoInsumo>"
	cXml 	+= "  						<numeroLoteInsumo></numeroLoteInsumo>"
	cXml 	+= "  						<insumoCNPJFornecedor></insumoCNPJFornecedor>"
	cXml 	+= "  					<quantidadeInsumo></quantidadeInsumo>"  // Versao 2.0	
	cXml 	+= "  					<tipoUnidade></tipoUnidade>"			 //  Versao 2.0	
	cXml 	+= "  					</insumoTransferencia>"	
	
	//cXml 	+= "  					<quantidadeInsumoTransferencia></quantidadeInsumoTransferencia>"   Versao 2.0	
	//cXml 	+= "  					<tipoUnidadeTransferencia></tipoUnidadeTransferencia>"			   Versao 2.0	
	
	//cXml 	+= "  				</substanciaInsumoTransferencia>"   Versao 2.0
	
	cXml 	+= "  				<dataTransferenciaInsumo></dataTransferenciaInsumo>"
	cXml 	+= "			</saidaInsumoTransferencia>"


	//Saida de insumo PERDA
	cXml 	+= "			<saidaInsumoPerda>"
	
	cXml 	+= "  				<motivoPerdaInsumo></motivoPerdaInsumo>"    
	
	cXml 	+= "  				<substanciaInsumoPerda>"  
	
	cXml 	+= "  					<insumoPerda>"
	cXml 	+= "  						<codigoInsumo></codigoInsumo>"
	cXml 	+= "  						<numeroLoteInsumo></numeroLoteInsumo>"
	cXml 	+= "  						<insumoCNPJFornecedor></insumoCNPJFornecedor>"
	cXml 	+= "  					</insumoPerda>" 
	
	cXml 	+= "  					<quantidadeInsumoPerda></quantidadeInsumoPerda>"
	cXml 	+= "  					<tipoUnidadePerda></tipoUnidadePerda>"   
	
	cXml 	+= "  				</substanciaInsumoPerda>"  
	
	cXml 	+= "  				<dataPerdaInsumo></dataPerdaInsumo>" 
	cXml 	+= "  				<InsumoCNPJFornecedor></InsumoCNPJFornecedor>"  
	
	cXml 	+= "			</saidaInsumoPerda>"

	cXml 	+= "		</insumos>"	
	*/
	cXml 	+= "	</corpo>"
	
	cXml 	+= "</mensagemSNGPC>"

Return cXml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCabecalho        บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados do cabecalho no XML.	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Cabecalho() Class DROXMLAnvisa

	Local lRetorno := .T.						//Retorno do metodo
	
	//Alimenta os dados do cabecalho no XML
	::GetXml():_mensagemSNGPC:_cabecalho:_cnpjEmissor:TEXT		:= ::cCnpj
	::GetXml():_mensagemSNGPC:_cabecalho:_cpfTransmissor:TEXT 	:= ::cCpf
	::GetXml():_mensagemSNGPC:_cabecalho:_dataInicio:TEXT 		:= ::FormataDt(::dDtInicio)
	::GetXml():_mensagemSNGPC:_cabecalho:_dataFim:TEXT			:= ::FormataDt(::dDtFim)
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCabecalhoInv     บAutor  ณVendas Clientes     บ Data ณ  06/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados do cabecalho no XML.	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CabecalhoInv() Class DROXMLAnvisa

	Local lRetorno := .T.						//Retorno do metodo
	
	//Alimenta os dados do cabecalho no XML
	::GetXml():_mensagemSNGPCInventario:_cabecalho:_cnpjEmissor:TEXT		:= ::cCnpj
	::GetXml():_mensagemSNGPCInventario:_cabecalho:_cpfTransmissor:TEXT 	:= ::cCpf
	::GetXml():_mensagemSNGPCInventario:_cabecalho:_data:TEXT 				:= ::FormataDt(::dDtInicio)
	
Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEntrada          บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados de entrada de medicamento	 บฑฑ
ฑฑบ			 ณno XML.	     										   			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Entrada() Class DROXMLAnvisa

	Local lRetorno 		:= .T.						//Retorno do metodo
	Local nCount		:= 0						//Variavel de controle contador
	Local nLK9_REGMS 	:= TamSX3("LK9_REGMS")[1]	//Tamanho do campo LK9_REGMS	
	Local cUM			:= "1"  					//  Vs 2.0 considera sempre unidade padrao Caixa   

	For nCount := 1 To ::oAnvisaEnt:Count()
		
		If nCount > 1
			//Clona um node do XML
			::ClonarNode(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos, "_entradaMedicamentos")
			//Alimenta os dados ao node
			::NodeEnt(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[1], ::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount])		
		Else
			//Transforma o node em array
			::TransNodAr(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos, "_entradaMedicamentos")
		EndIf
		
		//Alimenta os dados da entrada
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_notaFiscalEntradaMedicamento:_numeroNotaFiscal:TEXT			:= AllTrim(::oAnvisaEnt:Elements(nCount):cLK9_DOC)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_notaFiscalEntradaMedicamento:_tipoOperacaoNotaFiscal:TEXT		:= "1"
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_notaFiscalEntradaMedicamento:_dataNotaFiscal:TEXT				:= ::FormataDt(::oAnvisaEnt:Elements(nCount):cLK9_DATANF)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_notaFiscalEntradaMedicamento:_cnpjOrigem:TEXT					:= Alltrim(::oAnvisaEnt:Elements(nCount):cLK9_CNPJFO)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_notaFiscalEntradaMedicamento:_cnpjDestino:TEXT				:= ::cCnpj				
				
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_classeTerapeutica:TEXT					:= AllTrim(::oAnvisaEnt:Elements(nCount):cLK9_CLASST)  // V 2.0
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_registroMSMedicamento:TEXT				:= Padr(AllTrim(::oAnvisaEnt:Elements(nCount):cLK9_REGMS),nLK9_REGMS,"0")
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_numeroLoteMedicamento:TEXT				:= AllTrim(::oAnvisaEnt:Elements(nCount):cLK9_LOTE)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_quantidadeMedicamento:TEXT				:= AllTrim(Str(::oAnvisaEnt:Elements(nCount):nLK9_QUANT))

		If Upper(AllTrim(::oAnvisaEnt:Elements(nCount):cLK9_UM)) == 'FR' 
			cUM := '2'
		EndIf
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_unidadeMedidaMedicamento:TEXT			:= Alltrim(cUM) // V 2.0
		
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_dataRecebimentoMedicamento:TEXT								:= ::FormataDt(::oAnvisaEnt:Elements(nCount):cLK9_DATA)

		
	Next nCount		
	
Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSaidaVenda       บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados de saida de venda ao		 บฑฑ
ฑฑบ			 ณconsumidor no XML.	     										 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SaidaVenda() Class DROXMLAnvisa

	Local lRetorno 		:= .T.						//Retorno do metodo
	Local nCount		:= 0						//Variavel de controle contador
	Local nLK9_REGMS 	:= TamSX3("LK9_REGMS")[1]	//Tamanho do campo LK9_REGMS	
	Local cUM			:= "1"  					//  Vs 2.0 considera sempre unidade padrao Caixa   
	Local oNodeSaida    := NIL
	//Ordena pelo medicamento padrao

	For nCount := 1 To ::oAnvisaSai:Count()
		
		oNodeSaida := ::SaidaNode( ::oAnvisaSai:Elements(nCount):cLK9_TIPUSO, ::GetXml():_mensagemSNGPC:_corpo:_medicamentos, nCount)

		oNodeSaida:_tipoReceituarioMedicamento:TEXT							:= Alltrim(::oAnvisaSai:Elements(nCount):cLK9_TIPREC)
		oNodeSaida:_numeroNotificacaoMedicamento:TEXT						:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_NUMREC)
		oNodeSaida:_dataPrescricaoMedicamento:TEXT							:= ::FormataDt(::oAnvisaSai:Elements(nCount):cLK9_DATARE)
		
		oNodeSaida:_prescritorMedicamento:_nomePrescritor:TEXT				:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_NOMMED)
		oNodeSaida:_prescritorMedicamento:_numeroRegistroProfissional:TEXT	:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_NUMPRO)
		oNodeSaida:_prescritorMedicamento:_conselhoProfissional:TEXT		:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_CONPRO)
		oNodeSaida:_prescritorMedicamento:_UFConselho:TEXT					:= AllTRim(::oAnvisaSai:Elements(nCount):cLK9_UFCONS)
		
		oNodeSaida:_usoMedicamento:TEXT										:= Alltrim(::oAnvisaSai:Elements(nCount):cLK9_TIPUSO)
		
		oNodeSaida:_compradorMedicamento:_nomeComprador:TEXT				:= Alltrim(::oAnvisaSai:Elements(nCount):cLK9_NOME)
		oNodeSaida:_compradorMedicamento:_tipoDocumento:TEXT				:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_TIPOID)
		oNodeSaida:_compradorMedicamento:_numeroDocumento:TEXT				:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_NUMID)
		oNodeSaida:_compradorMedicamento:_orgaoExpedidor:TEXT				:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_ORGEXP)
		oNodeSaida:_compradorMedicamento:_UFEmissaoDocumento:TEXT			:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_UFEMIS)
		
 		// V 2.0
 		IF ::oAnvisaSai:Elements(nCount):cLK9_TIPUSO <> "2"
			oNodeSaida:_pacienteMedicamento:_nome:TEXT							:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_NOMEP)
			oNodeSaida:_pacienteMedicamento:_idade:TEXT							:=  AllTrim(Str(::oAnvisaSai:Elements(nCount):nLK9_IDADEP))
			oNodeSaida:_pacienteMedicamento:_unidadeIdade:TEXT					:= AllTRim(::oAnvisaSai:Elements(nCount):cLK9_UNIDAP)
			oNodeSaida:_pacienteMedicamento:_sexo:TEXT							:= AllTRim(::oAnvisaSai:Elements(nCount):cLK9_SEXOPA)
		EndIf
		oNodeSaida:_pacienteMedicamento:_cid:TEXT							:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_CIDPA )
		//
		oNodeSaida:_medicamentoVenda:_usoProlongado:TEXT					:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_USOPRO)  // V 2.0
		oNodeSaida:_medicamentoVenda:_registroMSMedicamento:TEXT			:= Padr(AllTrim(::oAnvisaSai:Elements(nCount):cLK9_REGMS),nLK9_REGMS,"0")
		oNodeSaida:_medicamentoVenda:_numeroLoteMedicamento:TEXT			:= AllTrim(::oAnvisaSai:Elements(nCount):cLK9_LOTE)
		oNodeSaida:_medicamentoVenda:_quantidadeMedicamento:TEXT			:= AllTrim(Str(::oAnvisaSai:Elements(nCount):nLK9_QUANT))

		If Upper(AllTrim(::oAnvisaSai:Elements(nCount):cLK9_UM)) == 'FR' 
			cUM := '2'
		EndIf
		oNodeSaida:_medicamentoVenda:_unidadeMedidaMedicamento:TEXT		:= AllTRim(cUM) // V 2.0
		
		oNodeSaida:_dataVendaMedicamento:TEXT								:= ::FormataDt(::oAnvisaSai:Elements(nCount):cLK9_DATA)
		
	Next nCount		

Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSaidaPerda       บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados de saida por perda    	 บฑฑ
ฑฑบ			 ณno XML.	     										   			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SaidaPerda() Class DROXMLAnvisa

	Local lRetorno 		:= .T.						//Retorno do metodo
	Local nCount		:= 0						//Variavel de controle contador
	Local nLK9_REGMS 	:= TamSX3("LK9_REGMS")[1]	//Tamanho do campo LK9_REGMS	
	Local cUM			:= "1"  					//  Vs 2.0 considera sempre unidade padrao Caixa   
	
	For nCount := 1 To ::oAnvisaPer:Count()
		
		If nCount > 1
			//Clona um node do XML
			::ClonarNode(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda, "_saidaMedicamentoPerda")
			//Alimenta os dados ao node
			::NodeSaiPer(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[1], ::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount])		
		Else
			//Transforma o node em array
			::TransNodAr(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda, "_saidaMedicamentoPerda")
		EndIf
		
		//Alimenta os dados de saida por perda
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_motivoPerdaMedicamento:TEXT						:= AllTrim(::oAnvisaPer:Elements(nCount):cLK9_MTVPER)

		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_medicamentoPerda:_registroMSMedicamento:TEXT	:= Padr(AllTrim(::oAnvisaPer:Elements(nCount):cLK9_REGMS),nLK9_REGMS,"0")
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_medicamentoPerda:_numeroLoteMedicamento:TEXT	:= AllTrim(::oAnvisaPer:Elements(nCount):cLK9_LOTE)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_medicamentoPerda:_quantidadeMedicamento:TEXT	:= AllTrim(Str(::oAnvisaPer:Elements(nCount):nLK9_QUANT))
		
		If Upper(AllTrim(::oAnvisaPer:Elements(nCount):cLK9_UM)) == 'FR' 
			cUM := '2'
		EndIf
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_medicamentoPerda:_unidadeMedidaMedicamento:TEXT:= AllTrim(cUM) // V 2.0
	
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoPerda[nCount]:_dataPerdaMedicamento:TEXT	   					:= ::FormataDt(::oAnvisaPer:Elements(nCount):cLK9_DATA)
		
	Next nCount		
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSaidaTrans       บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados de saida por transferencia บฑฑ
ฑฑบ			 ณno XML.	     										   			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method SaidaTrans() Class DROXMLAnvisa

	Local lRetorno 		:= .T.						//Retorno do metodo
	Local nCount		:= 0						//Variavel de controle contador
	Local nLK9_REGMS 	:= TamSX3("LK9_REGMS")[1]	//Tamanho do campo LK9_REGMS	
	Local cUM			:= "1"  					//  Vs 2.0 considera sempre unidade padrao Caixa   
	
	For nCount := 1 To ::oAnvisaTra:Count()
		
		If nCount > 1
			//Clona um node do XML
			::ClonarNode(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia, "_saidaMedicamentoTransferencia")
			//Alimenta os dados ao node
			::NodeSaiTra(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[1], ::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount])					
		Else
			//Transforma o node em array
			::TransNodAr(::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia, "_saidaMedicamentoTransferencia")
		EndIf
		
		//Alimenta os dados de saida por transferencia
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_notaFiscalTransferenciaMedicamento:_numeroNotaFiscal:TEXT			:= Padl(AllTrim(::oAnvisaTra:Elements(nCount):cLK9_DOC),9,"0")
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_notaFiscalTransferenciaMedicamento:_tipoOperacaoNotaFiscal:TEXT		:= "2"
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_notaFiscalTransferenciaMedicamento:_dataNotaFiscal:TEXT				:= ::FormataDt(::oAnvisaTra:Elements(nCount):cLK9_DATANF)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_notaFiscalTransferenciaMedicamento:_cnpjOrigem:TEXT					:= AllTrim(::oAnvisaTra:Elements(nCount):cLK9_CNPJOR)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_notaFiscalTransferenciaMedicamento:_cnpjDestino:TEXT				:= AllTrim(::oAnvisaTra:Elements(nCount):cLK9_CNPJDE)				
				
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_medicamentoTransferencia:_registroMSMedicamento:TEXT				:= Padr(AllTrim(::oAnvisaTra:Elements(nCount):cLK9_REGMS),nLK9_REGMS,"0")
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_medicamentoTransferencia:_numeroLoteMedicamento:TEXT				:= AllTrim(::oAnvisaTra:Elements(nCount):cLK9_LOTE)
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_medicamentoTransferencia:_quantidadeMedicamento:TEXT				:= AllTrim(Str(::oAnvisaTra:Elements(nCount):nLK9_QUANT))
		
		If Upper(AllTrim(::oAnvisaTra:Elements(nCount):cLK9_UM)) == 'FR' 
			cUM := '2'
		EndIf
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_medicamentoTransferencia:_unidadeMedidaMedicamento:TEXT			:= AllTrim(cUM) // V 2.0
		
		::GetXml():_mensagemSNGPC:_corpo:_medicamentos:_saidaMedicamentoTransferencia[nCount]:_dataTransferenciaMedicamento:TEXT									:= ::FormataDt(::oAnvisaTra:Elements(nCount):cLK9_DATA)
		
	Next nCount		
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFormataDt        บAutor  ณVendas Clientes     บ Data ณ  29/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em formatar a data em YYYY-MM-DD.				 บฑฑ
ฑฑบ			 ณno XML.	     										   			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPD1 (1 - dData)	- Data a ser formatada.						     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FormataDt(dData) Class DROXMLAnvisa
	
	Local cData	:= ""							//Retorno do metodo
	
	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
		
Return cData

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNodeSaida        บAutor  ณVendas Clientes     บ Data ณ  30/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar as propridades TYPE e REALMANE		 บฑฑ
ฑฑบ			 ณdo node _saidaMedicamentoVendaAoConsumidor se baseando no original.บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1 (1 - oOrigem)	- Objeto com os dados originais.		     บฑฑ
ฑฑบ          ณEXPO2 (2 - oDestino)	- Objeto a ser carregado.       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |      														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NodeSaida(oOrigem, oDestino, cTpUso) Class DROXMLAnvisa

	oDestino:TYPE															:= oOrigem:TYPE
	oDestino:REALNAME 														:= oOrigem:REALNAME
	
	oDestino:_tipoReceituarioMedicamento:TYPE								:= oOrigem:_tipoReceituarioMedicamento:TYPE
	oDestino:_tipoReceituarioMedicamento:REALNAME 							:= oOrigem:_tipoReceituarioMedicamento:REALNAME

	oDestino:_numeroNotificacaoMedicamento:TYPE								:= oOrigem:_numeroNotificacaoMedicamento:TYPE
	oDestino:_numeroNotificacaoMedicamento:REALNAME 						:= oOrigem:_numeroNotificacaoMedicamento:REALNAME		

	oDestino:_dataPrescricaoMedicamento:TYPE								:= oOrigem:_dataPrescricaoMedicamento:TYPE
	oDestino:_dataPrescricaoMedicamento:REALNAME 							:= oOrigem:_dataPrescricaoMedicamento:REALNAME			

	oDestino:_prescritorMedicamento:TYPE									:= oOrigem:_prescritorMedicamento:TYPE
	oDestino:_prescritorMedicamento:REALNAME 								:= oOrigem:_prescritorMedicamento:REALNAME			
	
	oDestino:_prescritorMedicamento:_nomePrescritor:TYPE					:= oOrigem:_prescritorMedicamento:_nomePrescritor:TYPE
	oDestino:_prescritorMedicamento:_nomePrescritor:REALNAME 				:= oOrigem:_prescritorMedicamento:_nomePrescritor:REALNAME			
	
	oDestino:_prescritorMedicamento:_numeroRegistroProfissional:TYPE		:= oOrigem:_prescritorMedicamento:_numeroRegistroProfissional:TYPE
	oDestino:_prescritorMedicamento:_numeroRegistroProfissional:REALNAME 	:= oOrigem:_prescritorMedicamento:_numeroRegistroProfissional:REALNAME			

	oDestino:_prescritorMedicamento:_conselhoProfissional:TYPE				:= oOrigem:_prescritorMedicamento:_conselhoProfissional:TYPE
	oDestino:_prescritorMedicamento:_conselhoProfissional:REALNAME 			:= oOrigem:_prescritorMedicamento:_conselhoProfissional:REALNAME			
	
	oDestino:_prescritorMedicamento:_UFConselho:TYPE						:= oOrigem:_prescritorMedicamento:_UFConselho:TYPE
	oDestino:_prescritorMedicamento:_UFConselho:REALNAME 					:= oOrigem:_prescritorMedicamento:_UFConselho:REALNAME			

	oDestino:_usoMedicamento:TYPE											:= oOrigem:_usoMedicamento:TYPE
	oDestino:_usoMedicamento:REALNAME 										:= oOrigem:_usoMedicamento:REALNAME			
		
	oDestino:_compradorMedicamento:TYPE										:= oOrigem:_compradorMedicamento:TYPE
	oDestino:_compradorMedicamento:REALNAME 								:= oOrigem:_compradorMedicamento:REALNAME			

	oDestino:_compradorMedicamento:_nomeComprador:TYPE						:= oOrigem:_compradorMedicamento:_nomeComprador:TYPE
	oDestino:_compradorMedicamento:_nomeComprador:REALNAME 					:= oOrigem:_compradorMedicamento:_nomeComprador:REALNAME			
		
	oDestino:_compradorMedicamento:_tipoDocumento:TYPE						:= oOrigem:_compradorMedicamento:_tipoDocumento:TYPE
	oDestino:_compradorMedicamento:_tipoDocumento:REALNAME 					:= oOrigem:_compradorMedicamento:_tipoDocumento:REALNAME			

	oDestino:_compradorMedicamento:_numeroDocumento:TYPE					:= oOrigem:_compradorMedicamento:_numeroDocumento:TYPE
	oDestino:_compradorMedicamento:_numeroDocumento:REALNAME 				:= oOrigem:_compradorMedicamento:_numeroDocumento:REALNAME			
		
	oDestino:_compradorMedicamento:_orgaoExpedidor:TYPE						:= oOrigem:_compradorMedicamento:_orgaoExpedidor:TYPE
	oDestino:_compradorMedicamento:_orgaoExpedidor:REALNAME 				:= oOrigem:_compradorMedicamento:_orgaoExpedidor:REALNAME			

	oDestino:_compradorMedicamento:_UFEmissaoDocumento:TYPE					:= oOrigem:_compradorMedicamento:_UFEmissaoDocumento:TYPE
	oDestino:_compradorMedicamento:_UFEmissaoDocumento:REALNAME 			:= oOrigem:_compradorMedicamento:_UFEmissaoDocumento:REALNAME			


	oDestino:_pacienteMedicamento:TYPE										:= oOrigem:_pacienteMedicamento:TYPE
	oDestino:_pacienteMedicamento:REALNAME 								:= oOrigem:_pacienteMedicamento:REALNAME			

	If cTpUso <> "2"
		oDestino:_pacienteMedicamento:_nome:TYPE								:= oOrigem:_pacienteMedicamento:_nome:TYPE
		oDestino:_pacienteMedicamento:_nome:REALNAME							:= oOrigem:_pacienteMedicamento:_nome:REALNAME
	
		oDestino:_pacienteMedicamento:_idade:TYPE								:= oOrigem:_pacienteMedicamento:_idade:TYPE
		oDestino:_pacienteMedicamento:_idade:REALNAME							:= oOrigem:_pacienteMedicamento:_idade:REALNAME
	
		oDestino:_pacienteMedicamento:_unidadeIdade:TYPE						:= oOrigem:_pacienteMedicamento:_unidadeIdade:TYPE
		oDestino:_pacienteMedicamento:_unidadeIdade:REALNAME					:= oOrigem:_pacienteMedicamento:_unidadeIdade:REALNAME
	
		oDestino:_pacienteMedicamento:_sexo:TYPE								:= oOrigem:_pacienteMedicamento:_sexo:TYPE
		oDestino:_pacienteMedicamento:_sexo:REALNAME							:= oOrigem:_pacienteMedicamento:_sexo:REALNAME
	EndIf
	oDestino:_pacienteMedicamento:_cid:TYPE								:= oOrigem:_pacienteMedicamento:_cid:TYPE
	oDestino:_pacienteMedicamento:_cid:REALNAME							:= oOrigem:_pacienteMedicamento:_cid:REALNAME

	
	oDestino:_medicamentoVenda:TYPE											:= oOrigem:_medicamentoVenda:TYPE
	oDestino:_medicamentoVenda:REALNAME 									:= oOrigem:_medicamentoVenda:REALNAME			


	oDestino:_medicamentoVenda:_usoProlongado:TYPE						:= oOrigem:_medicamentoVenda:_usoProlongado:TYPE
	oDestino:_medicamentoVenda:_usoProlongado:REALNAME 					:= oOrigem:_medicamentoVenda:_usoProlongado:REALNAME			

	oDestino:_medicamentoVenda:_registroMSMedicamento:TYPE					:= oOrigem:_medicamentoVenda:_registroMSMedicamento:TYPE
	oDestino:_medicamentoVenda:_registroMSMedicamento:REALNAME 				:= oOrigem:_medicamentoVenda:_registroMSMedicamento:REALNAME			

	oDestino:_medicamentoVenda:_numeroLoteMedicamento:TYPE					:= oOrigem:_medicamentoVenda:_numeroLoteMedicamento:TYPE
	oDestino:_medicamentoVenda:_numeroLoteMedicamento:REALNAME 				:= oOrigem:_medicamentoVenda:_numeroLoteMedicamento:REALNAME			

	oDestino:_medicamentoVenda:_quantidadeMedicamento:TYPE					:= oOrigem:_medicamentoVenda:_quantidadeMedicamento:TYPE
	oDestino:_medicamentoVenda:_quantidadeMedicamento:REALNAME 				:= oOrigem:_medicamentoVenda:_quantidadeMedicamento:REALNAME			
		
	oDestino:_medicamentoVenda:_unidadeMedidaMedicamento:TYPE				:= oOrigem:_medicamentoVenda:_unidadeMedidaMedicamento:TYPE
	oDestino:_medicamentoVenda:_unidadeMedidaMedicamento:REALNAME			:= oOrigem:_medicamentoVenda:_unidadeMedidaMedicamento:REALNAME			
		
	oDestino:_dataVendaMedicamento:TYPE										:= oOrigem:_dataVendaMedicamento:TYPE
	oDestino:_dataVendaMedicamento:REALNAME 								:= oOrigem:_dataVendaMedicamento:REALNAME			

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNodeEnt          บAutor  ณVendas Clientes     บ Data ณ  30/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar as propridades TYPE e REALMANE		 บฑฑ
ฑฑบ			 ณdo node _entradaMedicamentos se baseando no original.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1 (1 - oOrigem)	- Objeto com os dados originais.		     บฑฑ
ฑฑบ          ณEXPO2 (2 - oDestino)	- Objeto a ser carregado.       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |      														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NodeEnt(oOrigem, oDestino) Class DROXMLAnvisa
		
	oDestino:TYPE																:= oOrigem:TYPE
	oDestino:REALNAME 															:= oOrigem:REALNAME
	
	oDestino:_notaFiscalEntradaMedicamento:TYPE									:= oOrigem:_notaFiscalEntradaMedicamento:TYPE
	oDestino:_notaFiscalEntradaMedicamento:REALNAME 							:= oOrigem:_notaFiscalEntradaMedicamento:REALNAME

	oDestino:_notaFiscalEntradaMedicamento:_numeroNotaFiscal:TYPE				:= oOrigem:_notaFiscalEntradaMedicamento:_numeroNotaFiscal:TYPE
	oDestino:_notaFiscalEntradaMedicamento:_numeroNotaFiscal:REALNAME 			:= oOrigem:_notaFiscalEntradaMedicamento:_numeroNotaFiscal:REALNAME			
	
	oDestino:_notaFiscalEntradaMedicamento:_tipoOperacaoNotaFiscal:TYPE			:= oOrigem:_notaFiscalEntradaMedicamento:_tipoOperacaoNotaFiscal:TYPE
	oDestino:_notaFiscalEntradaMedicamento:_tipoOperacaoNotaFiscal:REALNAME		:= oOrigem:_notaFiscalEntradaMedicamento:_tipoOperacaoNotaFiscal:REALNAME			

	oDestino:_notaFiscalEntradaMedicamento:_dataNotaFiscal:TYPE					:= oOrigem:_notaFiscalEntradaMedicamento:_dataNotaFiscal:TYPE
	oDestino:_notaFiscalEntradaMedicamento:_dataNotaFiscal:REALNAME 			:= oOrigem:_notaFiscalEntradaMedicamento:_dataNotaFiscal:REALNAME			
	
	oDestino:_notaFiscalEntradaMedicamento:_cnpjOrigem:TYPE						:= oOrigem:_notaFiscalEntradaMedicamento:_cnpjOrigem:TYPE
	oDestino:_notaFiscalEntradaMedicamento:_cnpjOrigem:REALNAME 				:= oOrigem:_notaFiscalEntradaMedicamento:_cnpjOrigem:REALNAME			

	oDestino:_notaFiscalEntradaMedicamento:_cnpjDestino:TYPE					:= oOrigem:_notaFiscalEntradaMedicamento:_cnpjDestino:TYPE
	oDestino:_notaFiscalEntradaMedicamento:_cnpjDestino:REALNAME 				:= oOrigem:_notaFiscalEntradaMedicamento:_cnpjDestino:REALNAME			

	oDestino:_medicamentoEntrada:TYPE											:= oOrigem:_medicamentoEntrada:TYPE
	oDestino:_medicamentoEntrada:REALNAME 										:= oOrigem:_medicamentoEntrada:REALNAME
    
	oDestino:_medicamentoEntrada:_classeTerapeutica:TYPE						:= oOrigem:_medicamentoEntrada:_classeTerapeutica:TYPE
	oDestino:_medicamentoEntrada:_classeTerapeutica:REALNAME 				:= oOrigem:_medicamentoEntrada:_classeTerapeutica:REALNAME

	oDestino:_medicamentoEntrada:_registroMSMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_registroMSMedicamento:TYPE
	oDestino:_medicamentoEntrada:_registroMSMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_registroMSMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_numeroLoteMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_numeroLoteMedicamento:TYPE
	oDestino:_medicamentoEntrada:_numeroLoteMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_numeroLoteMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_quantidadeMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_quantidadeMedicamento:TYPE
	oDestino:_medicamentoEntrada:_quantidadeMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_quantidadeMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_unidadeMedidaMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_unidadeMedidaMedicamento:TYPE
	oDestino:_medicamentoEntrada:_unidadeMedidaMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_unidadeMedidaMedicamento:REALNAME
	
	oDestino:_dataRecebimentoMedicamento:TYPE									:= oOrigem:_dataRecebimentoMedicamento:TYPE
	oDestino:_dataRecebimentoMedicamento:REALNAME 								:= oOrigem:_dataRecebimentoMedicamento:REALNAME
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNodeEntInv       บAutor  ณVendas Clientes     บ Data ณ  06/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar as propridades TYPE e REALMANE		 บฑฑ
ฑฑบ			 ณdo node _entradaMedicamentos se baseando no original.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1 (1 - oOrigem)	- Objeto com os dados originais.		     บฑฑ
ฑฑบ          ณEXPO2 (2 - oDestino)	- Objeto a ser carregado.       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |      														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NodeInv(oOrigem, oDestino) Class DROXMLAnvisa
		
	oDestino:TYPE																:= oOrigem:TYPE
	oDestino:REALNAME 															:= oOrigem:REALNAME
	
	oDestino:_medicamentoEntrada:TYPE											:= oOrigem:_medicamentoEntrada:TYPE
	oDestino:_medicamentoEntrada:REALNAME 										:= oOrigem:_medicamentoEntrada:REALNAME
    
	oDestino:_medicamentoEntrada:_classeTerapeutica:TYPE						:= oOrigem:_medicamentoEntrada:_classeTerapeutica:TYPE
	oDestino:_medicamentoEntrada:_classeTerapeutica:REALNAME 				:= oOrigem:_medicamentoEntrada:_classeTerapeutica:REALNAME

	oDestino:_medicamentoEntrada:_registroMSMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_registroMSMedicamento:TYPE
	oDestino:_medicamentoEntrada:_registroMSMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_registroMSMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_numeroLoteMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_numeroLoteMedicamento:TYPE
	oDestino:_medicamentoEntrada:_numeroLoteMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_numeroLoteMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_quantidadeMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_quantidadeMedicamento:TYPE
	oDestino:_medicamentoEntrada:_quantidadeMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_quantidadeMedicamento:REALNAME

	oDestino:_medicamentoEntrada:_unidadeMedidaMedicamento:TYPE					:= oOrigem:_medicamentoEntrada:_unidadeMedidaMedicamento:TYPE
	oDestino:_medicamentoEntrada:_unidadeMedidaMedicamento:REALNAME 				:= oOrigem:_medicamentoEntrada:_unidadeMedidaMedicamento:REALNAME
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNodeSaiPer       บAutor  ณVendas Clientes     บ Data ณ  30/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar as propridades TYPE e REALMANE		 บฑฑ
ฑฑบ			 ณdo node _saidaMedicamentoPerda se baseando no original.            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1 (1 - oOrigem)	- Objeto com os dados originais.		     บฑฑ
ฑฑบ          ณEXPO2 (2 - oDestino)	- Objeto a ser carregado.       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |      														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NodeSaiPer(oOrigem, oDestino) Class DROXMLAnvisa
    
	oDestino:TYPE												:= oOrigem:TYPE
	oDestino:REALNAME 											:= oOrigem:REALNAME
	
	oDestino:_motivoPerdaMedicamento:TYPE						:= oOrigem:_motivoPerdaMedicamento:TYPE
	oDestino:_motivoPerdaMedicamento:REALNAME 					:= oOrigem:_motivoPerdaMedicamento:REALNAME
    
	oDestino:_medicamentoPerda:TYPE								:= oOrigem:_medicamentoPerda:TYPE
	oDestino:_medicamentoPerda:REALNAME 						:= oOrigem:_medicamentoPerda:REALNAME

	oDestino:_medicamentoPerda:_registroMSMedicamento:TYPE		:= oOrigem:_medicamentoPerda:_registroMSMedicamento:TYPE
	oDestino:_medicamentoPerda:_registroMSMedicamento:REALNAME 	:= oOrigem:_medicamentoPerda:_registroMSMedicamento:REALNAME

	oDestino:_medicamentoPerda:_numeroLoteMedicamento:TYPE		:= oOrigem:_medicamentoPerda:_numeroLoteMedicamento:TYPE
	oDestino:_medicamentoPerda:_numeroLoteMedicamento:REALNAME 	:= oOrigem:_medicamentoPerda:_numeroLoteMedicamento:REALNAME

	oDestino:_medicamentoPerda:_quantidadeMedicamento:TYPE		:= oOrigem:_medicamentoPerda:_quantidadeMedicamento:TYPE
	oDestino:_medicamentoPerda:_quantidadeMedicamento:REALNAME 	:= oOrigem:_medicamentoPerda:_quantidadeMedicamento:REALNAME

	oDestino:_medicamentoPerda:_unidadeMedidaMedicamento:TYPE		:= oOrigem:_medicamentoPerda:_unidadeMedidaMedicamento:TYPE
	oDestino:_medicamentoPerda:_unidadeMedidaMedicamento:REALNAME 	:= oOrigem:_medicamentoPerda:_unidadeMedidaMedicamento:REALNAME

	oDestino:_dataPerdaMedicamento:TYPE							:= oOrigem:_dataPerdaMedicamento:TYPE
	oDestino:_dataPerdaMedicamento:REALNAME 					:= oOrigem:_dataPerdaMedicamento:REALNAME

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNodeSaiTra       บAutor  ณVendas Clientes     บ Data ณ  30/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar as propridades TYPE e REALMANE		 บฑฑ
ฑฑบ			 ณdo node _saidaMedicamentoTransferencia se baseando no original.    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1 (1 - oOrigem)	- Objeto com os dados originais.		     บฑฑ
ฑฑบ          ณEXPO2 (2 - oDestino)	- Objeto a ser carregado.       		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   |      														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method NodeSaiTra(oOrigem, oDestino) Class DROXMLAnvisa

	oDestino:TYPE																		:= oOrigem:TYPE
	oDestino:REALNAME 																	:= oOrigem:REALNAME
	
	oDestino:_notaFiscalTransferenciaMedicamento:TYPE									:= oOrigem:_notaFiscalTransferenciaMedicamento:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:REALNAME 								:= oOrigem:_notaFiscalTransferenciaMedicamento:REALNAME

	oDestino:_notaFiscalTransferenciaMedicamento:_numeroNotaFiscal:TYPE					:= oOrigem:_notaFiscalTransferenciaMedicamento:_numeroNotaFiscal:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:_numeroNotaFiscal:REALNAME 			:= oOrigem:_notaFiscalTransferenciaMedicamento:_numeroNotaFiscal:REALNAME			
	
	oDestino:_notaFiscalTransferenciaMedicamento:_tipoOperacaoNotaFiscal:TYPE			:= oOrigem:_notaFiscalTransferenciaMedicamento:_tipoOperacaoNotaFiscal:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:_tipoOperacaoNotaFiscal:REALNAME		:= oOrigem:_notaFiscalTransferenciaMedicamento:_tipoOperacaoNotaFiscal:REALNAME			

	oDestino:_notaFiscalTransferenciaMedicamento:_dataNotaFiscal:TYPE					:= oOrigem:_notaFiscalTransferenciaMedicamento:_dataNotaFiscal:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:_dataNotaFiscal:REALNAME 				:= oOrigem:_notaFiscalTransferenciaMedicamento:_dataNotaFiscal:REALNAME			
	
	oDestino:_notaFiscalTransferenciaMedicamento:_cnpjOrigem:TYPE						:= oOrigem:_notaFiscalTransferenciaMedicamento:_cnpjOrigem:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:_cnpjOrigem:REALNAME 					:= oOrigem:_notaFiscalTransferenciaMedicamento:_cnpjOrigem:REALNAME			

	oDestino:_notaFiscalTransferenciaMedicamento:_cnpjDestino:TYPE						:= oOrigem:_notaFiscalTransferenciaMedicamento:_cnpjDestino:TYPE
	oDestino:_notaFiscalTransferenciaMedicamento:_cnpjDestino:REALNAME 					:= oOrigem:_notaFiscalTransferenciaMedicamento:_cnpjDestino:REALNAME			

	oDestino:_medicamentoTransferencia:TYPE												:= oOrigem:_medicamentoTransferencia:TYPE
	oDestino:_medicamentoTransferencia:REALNAME 										:= oOrigem:_medicamentoTransferencia:REALNAME
    
	oDestino:_medicamentoTransferencia:_registroMSMedicamento:TYPE						:= oOrigem:_medicamentoTransferencia:_registroMSMedicamento:TYPE
	oDestino:_medicamentoTransferencia:_registroMSMedicamento:REALNAME 					:= oOrigem:_medicamentoTransferencia:_registroMSMedicamento:REALNAME

	oDestino:_medicamentoTransferencia:_numeroLoteMedicamento:TYPE						:= oOrigem:_medicamentoTransferencia:_numeroLoteMedicamento:TYPE
	oDestino:_medicamentoTransferencia:_numeroLoteMedicamento:REALNAME 					:= oOrigem:_medicamentoTransferencia:_numeroLoteMedicamento:REALNAME

	oDestino:_medicamentoTransferencia:_quantidadeMedicamento:TYPE						:= oOrigem:_medicamentoTransferencia:_quantidadeMedicamento:TYPE
	oDestino:_medicamentoTransferencia:_quantidadeMedicamento:REALNAME 					:= oOrigem:_medicamentoTransferencia:_quantidadeMedicamento:REALNAME
		   
	oDestino:_medicamentoTransferencia:_unidadeMedidaMedicamento:TYPE					:= oOrigem:_medicamentoTransferencia:_unidadeMedidaMedicamento:TYPE
	oDestino:_medicamentoTransferencia:_unidadeMedidaMedicamento:REALNAME 				:= oOrigem:_medicamentoTransferencia:_unidadeMedidaMedicamento:REALNAME

		   
	oDestino:_dataTransferenciaMedicamento:TYPE											:= oOrigem:_dataTransferenciaMedicamento:TYPE
	oDestino:_dataTransferenciaMedicamento:REALNAME 									:= oOrigem:_dataTransferenciaMedicamento:REALNAME

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetXML           บAutor  ณVendas Clientes     บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o objeto oXMLANVISA									     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNIL                                          						 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetXML() Class DROXMLAnvisa
Return ::oXMLANVISA




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEstrutXML        บAutor  ณVendas Clientes     บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em gerar a estrutura do Invetario XML. 	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EstrutINV() Class DROXMLAnvisa

	Local cXml := ""								//String com a estrutura do xml  
	
	//Declaracao do XML
	cXml 	:= '<?xml version="1.0" encoding="iso-8859-1" ?>'

	cXml 	+= '<mensagemSNGPCInventario xmlns="urn:sngpc-schema">'

	//Cabecalho	
	cXml 	+= "	<cabecalho>"
	cXml 	+= "  		<cnpjEmissor></cnpjEmissor>"
	cXml 	+= "		<cpfTransmissor></cpfTransmissor>"
	cXml 	+= "  		<data></data>"
	cXml 	+= "	</cabecalho>"
		
	//Corpo
	cXml 	+= "	<corpo>"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMEDICAMENTOS|
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
	cXml 	+= "		<medicamentos>"	
	//Entrada de medicamentos
                           If ::oAnvisaInv:Count() > 0
	cXml 	+= "			<entradaMedicamentos>"
	cXml 	+= "  				<medicamentoEntrada>"
	cXml 	+= "  					<classeTerapeutica></classeTerapeutica>"   // Versao 2.0
	cXml 	+= "  					<registroMSMedicamento></registroMSMedicamento>"
	cXml 	+= "  					<numeroLoteMedicamento></numeroLoteMedicamento>"
	cXml 	+= "  					<quantidadeMedicamento></quantidadeMedicamento>"
	cXml 	+= "  					<unidadeMedidaMedicamento></unidadeMedidaMedicamento>"  // Versao 2.0
	cXml 	+= "  				</medicamentoEntrada>"
	cXml 	+= "			</entradaMedicamentos>"
                           Endif	
	cXml 	+= "		</medicamentos>" 

	//ฺฤฤฤฤฤฤฤฟ
	//ณINSUMOSณ
	//ภฤฤฤฤฤฤฤู
	cXml 	+= "		<insumos></insumos>"	
	
	//Entrada de insumo
	/*
	cXml 	+= "			<entradaInsumos>"    
	cXml 	+= "  					<insumoEntrada>"
	cXml 	+= "  						<classeTerapeutica></classeTerapeutica>"   // Versao 2.0
	cXml 	+= "  						<codigoInsumo></codigoInsumo>"
	cXml 	+= "  						<numeroLoteInsumo></numeroLoteInsumo>"
	cXml 	+= "  						<insumoCNPJFornecedor></insumoCNPJFornecedor>"
    cXml 	+= " 	 					<quantidadeInsumo></quantidadeInsumo>"    // Versao 2.0 
	cXml 	+= "  						<tipoUnidade></tipoUnidade>"          // Versao 2.0
	cXml 	+= "  					</insumoEntrada>" 
	cXml 	+= "			</entradaInsumos>"
	
	cXml 	+= "		</insumos>"	
	*/
	cXml 	+= "	</corpo>"
	
	cXml 	+= "</mensagemSNGPCInventario>"

Return cXml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGerarInv         บAutor  ณVendas Clientes     บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em gerar e gravar o XML de Invetario		     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GerarInv() Class DROXMLAnvisa
	
	Local lRetorno  := .F.							//Retorno do metodo
		
	//Efetua a consulta das movimentacoes do medicamentos controlados
	::ConsultaInv()
	
	//Gera o Objeto XML ANVISA com a estrutura definida
	::oXMLANVISA := ::Criar(::EstrutInv())
	
    //Alimenta os dados do cabecalho
	If ::oXMLANVISA <> NIL
		lRetorno := ::CabecalhoInv()	
	EndIf
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInformacoes para MEDICAMENTOSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Alimenta os dados de entrada
	If lRetorno
		lRetorno := ::Inventario()	
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInformacoes para INSUMOSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--
	//Transforma o Objeto XML em arquivo
	If lRetorno
		lRetorno := ::Salvar()
		 
	EndIf
		
    If lRetorno
	    //Grava o comentario do XML(Provisorio)
		oArquivo := LJCArquivo():Arquivo(::cPath, NOMEARQ)
		oArquivo:Abrir()
		oArquivo:EscrevXML('<?xml version="1.0" encoding="ISO-8859-1"?>')
		oArquivo:Fechar()
		
		//Ponto de Entrada para exporta็ใo das informacoes de cabecalho do XLM
		If ExistBlock("DROXMLCABE")
			Execblock("DROXMLCABE", .F., .F., {::cCnpj, ::cCpf, ::FormataDt(::dDtInicio), ::FormataDt(::dDtFim)})
		EndIf
	Endif
	
Return lRetorno 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณInventario       บAutor  ณVendas Clientes     บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em carregar os dados de Invetario	 no XML		 บฑฑ
ฑฑบ			 ณ 	     										   			 		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Inventario() Class DROXMLAnvisa

	Local lRetorno 		:= .T.						//Retorno do metodo
	Local nCount		:= 0						//Variavel de controle contador
	Local nB1_REGMS 	:= TamSX3("B1_REGMS")[1]	//Tamanho do campo B1_REGMS	
	Local cUM          := "1"  					//  Vs 2.0 considera sempre unidade padrao Caixa   

	For nCount := 1 To ::oAnvisaInv:Count()
		
		If nCount > 1
			//Clona um node do XML
			::ClonarNode(::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos, "_entradaMedicamentos")
			//Alimenta os dados ao node
			::NodeInv(::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[1], ::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount])		
		Else
			//Transforma o node em array
			::TransNodAr(::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos, "_entradaMedicamentos")
		EndIf
		
		//Alimenta os dados da entrada
				
		::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_classeTerapeutica:TEXT					:= 		 AllTrim(		::oAnvisaInv:Elements(nCount):cB1_CLASSTE)  // V 2.0
		::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_registroMSMedicamento:TEXT				:= Padr(AllTrim(		::oAnvisaInv:Elements(nCount):cB1_REGMS),nB1_REGMS,"0")
		::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_numeroLoteMedicamento:TEXT				:= 		 AllTrim(	  	::oAnvisaInv:Elements(nCount):cLOTE)
		::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_quantidadeMedicamento:TEXT				:= 		 AllTrim(Str(	::oAnvisaInv:Elements(nCount):nB2_QATU))

		If Upper(AllTrim(::oAnvisaInv:Elements(nCount):cB1_UM)) == 'FR' 
			cUM := '2'
		EndIf
		::GetXml():_mensagemSNGPCInventario:_corpo:_medicamentos:_entradaMedicamentos[nCount]:_medicamentoEntrada:_unidadeMedidaMedicamento:TEXT			:= cUM // V 2.0
		 
		
	Next nCount		
	  
Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณSaidaNode       บAutor  ณVendas Clientes     บ Data ณ  22/03/2018  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel montar a estrutura de venda de med controlado  บฑฑ
ฑฑบ			 ณ 	     										   			 		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method SaidaNode(cTpUso, oParent, nCount) Class DROXMLAnvisa
Local oNode := NIL
Local cNomeNode := ""

	cNomeNode := "_saidaMedicamentoVendaAoConsumidor"+StrZero(nCount,18)
	XmlNewNode( oParent, cNomeNode, "saidaMedicamentoVendaAoConsumidor", "NOD" ) 

	cNomeNode := Upper(cNomeNode)
	oNode := XmlChildEx(oParent, cNomeNode)
	oNode:REALNAME := "saidaMedicamentoVendaAoConsumidor"
	
	XmlNewNode( oNode, "_tipoReceituarioMedicamento", "tipoReceituarioMedicamento", "NOD" )
	oNode:_tipoReceituarioMedicamento:REALNAME := "tipoReceituarioMedicamento"
	
	XmlNewNode( oNode, "_numeroNotificacaoMedicamento", "numeroNotificacaoMedicamento", "NOD" )
	oNode:_numeroNotificacaoMedicamento:REALNAME := "numeroNotificacaoMedicamento"
	
	XmlNewNode( oNode, "_dataPrescricaoMedicamento", "dataPrescricaoMedicamento", "NOD" )
	oNode:_dataPrescricaoMedicamento:REALNAME := "dataPrescricaoMedicamento"	
	
	XmlNewNode( oNode, "_prescritorMedicamento", "prescritorMedicamento", "NOD" )
	oNode:_prescritorMedicamento:REALNAME := "prescritorMedicamento"
	
		XmlNewNode( oNode:_prescritorMedicamento, "_nomePrescritor", "nomePrescritor", "NOD" )
		oNode:_prescritorMedicamento:_nomePrescritor:REALNAME := "nomePrescritor"
		
		XmlNewNode( oNode:_prescritorMedicamento, "_numeroRegistroProfissional", "numeroRegistroProfissional", "NOD" )
		oNode:_prescritorMedicamento:_numeroRegistroProfissional:REALNAME := "numeroRegistroProfissional"
		
		XmlNewNode( oNode:_prescritorMedicamento, "_conselhoProfissional", "conselhoProfissional", "NOD" )
		oNode:_prescritorMedicamento:_conselhoProfissional:REALNAME := "conselhoProfissional"
		
		XmlNewNode( oNode:_prescritorMedicamento, "_UFConselho", "UFConselho", "NOD" )
		oNode:_prescritorMedicamento:_UFConselho:REALNAME := "UFConselho"
		
	XmlNewNode( oNode, "_usoMedicamento", "usoMedicamento", "NOD" )
	oNode:_usoMedicamento:REALNAME := "usoMedicamento"
	
	XmlNewNode( oNode, "_compradorMedicamento", "compradorMedicamento", "NOD" )
	oNode:_compradorMedicamento:REALNAME := "compradorMedicamento"
	
		XmlNewNode( oNode:_compradorMedicamento, "_nomeComprador", "nomeComprador", "NOD" )
		oNode:_compradorMedicamento:_nomeComprador:REALNAME := "nomeComprador"
		
		XmlNewNode( oNode:_compradorMedicamento, "_tipoDocumento", "tipoDocumento", "NOD" )
		oNode:_compradorMedicamento:_tipoDocumento:REALNAME := "tipoDocumento"
		
		XmlNewNode( oNode:_compradorMedicamento, "_numeroDocumento", "numeroDocumento", "NOD" )
		oNode:_compradorMedicamento:_numeroDocumento:REALNAME := "numeroDocumento"	
		
		XmlNewNode( oNode:_compradorMedicamento, "_orgaoExpedidor", "orgaoExpedidor", "NOD" )
		oNode:_compradorMedicamento:_orgaoExpedidor:REALNAME := "orgaoExpedidor"
		
		XmlNewNode( oNode:_compradorMedicamento, "_UFEmissaoDocumento", "UFEmissaoDocumento", "NOD" )
		oNode:_compradorMedicamento:_UFEmissaoDocumento:REALNAME := "UFEmissaoDocumento"
		
	XmlNewNode( oNode, "_pacienteMedicamento", "pacienteMedicamento", "NOD" )
	oNode:_pacienteMedicamento:REALNAME := "pacienteMedicamento"
	
		If cTpUso <> "2"
			XmlNewNode( oNode:_pacienteMedicamento, "_nome", "nome", "NOD" )	
			oNode:_pacienteMedicamento:_nome:REALNAME := "nome"
			
			XmlNewNode( oNode:_pacienteMedicamento, "_idade", "idade", "NOD" )	
			oNode:_pacienteMedicamento:_idade:REALNAME := "idade"
			
			XmlNewNode( oNode:_pacienteMedicamento, "_unidadeIdade", "unidadeIdade", "NOD" )
			oNode:_pacienteMedicamento:_unidadeIdade:REALNAME := "unidadeIdade"
				
			XmlNewNode( oNode:_pacienteMedicamento, "_sexo", "sexo", "NOD" )
			oNode:_pacienteMedicamento:_sexo:REALNAME := "sexo"
			
		EndIf

		XmlNewNode( oNode:_pacienteMedicamento, "_cid", "cid", "NOD" )	
		oNode:_pacienteMedicamento:_cid:REALNAME := "cid"	

	XmlNewNode( oNode, "_medicamentoVenda", "medicamentoVenda", "NOD" )
	oNode:_medicamentoVenda:REALNAME := "medicamentoVenda"
	
		XmlNewNode( oNode:_medicamentoVenda, "_usoProlongado", "usoProlongado", "NOD" )	
		oNode:_medicamentoVenda:_usoProlongado:REALNAME := "usoProlongado"
		
		XmlNewNode( oNode:_medicamentoVenda, "_registroMSMedicamento", "registroMSMedicamento", "NOD" )
		oNode:_medicamentoVenda:_registroMSMedicamento:REALNAME := "registroMSMedicamento"
		
		XmlNewNode( oNode:_medicamentoVenda, "_numeroLoteMedicamento", "numeroLoteMedicamento", "NOD" )	
		oNode:_medicamentoVenda:_numeroLoteMedicamento:REALNAME := "numeroLoteMedicamento"
		
		XmlNewNode( oNode:_medicamentoVenda, "_quantidadeMedicamento", "quantidadeMedicamento", "NOD" )
		oNode:_medicamentoVenda:_quantidadeMedicamento:REALNAME := "quantidadeMedicamento"
		
		XmlNewNode( oNode:_medicamentoVenda, "_unidadeMedidaMedicamento", "unidadeMedidaMedicamento", "NOD" )	
		oNode:_medicamentoVenda:_unidadeMedidaMedicamento:REALNAME := "unidadeMedidaMedicamento"
		
	XmlNewNode( oNode, "_dataVendaMedicamento", "dataVendaMedicamento", "NOD" )
	oNode:_dataVendaMedicamento:REALNAME := "dataVendaMedicamento"
 
Return oNode
