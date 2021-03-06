#INCLUDE "TOTVS.CH"
#INCLUDE "tpllx5.ch"

/*���������������������������������������������������������������������������
���Fun�ao    �TPLLX5    � Autor � 	Templates           � Data �Junho/2004���
�������������������������������������������������������������������������Ĵ��
���Descricao �Carga de Dados dos arquivos de transacoes (LDE e LDF) para: ��� 
���          �V609:LDE ---> OZ5  //  LDF ---> OZ6                         ���
���          �V710:LDE ---> OZ5(padrao na 710)//LDF --->OZ6(padrao na 710)���
�������������������������������������������������������������������������Ĵ��
���Obs:      �Os arqs OZ5 e OZ6 sao do padrao da V710. Como o aplicador do���
���          �template nao trata arqs q nao comecem com L (padrao de tpls)���
���          �e portanto nao podem  ser criados na aplicacao do tpl na 609���
���          �devem ser criados manualmente (apenas na 609).              ���
���          �Sempre a carga do conteudo do OZ5 e OZ6 sao feitas a partir ���
���          �do LDE e LDF, que servem como arqs de ponte. Nao sao usados ���
���          �efetivamente no processamento do SigaREP.                   ���
���������������������������������������������������������������������������*/
Template Function TPLLX5(aTplEmp,aTplFiles)
Local nI := 0
Local nj := 0
Local cField
Local lNew

Local cTplEmp
Local cTplFil
Local cAllEmp := ""
Local nPos

For nI := 1 To Len(aTplEmp)
	//  Faz a Checagem dos arquivos

	If !ChkTplFile("LX5",aTplFiles,".DTP") .or. ;
	   !ChkTplFile("LXB",aTplFiles,".DTP")
	   Return .F.
	EndIf

	cTplEmp := Subs(aTplEmp[ni],1,2)
	cTplFil := Subs(aTplEmp[ni],3,2)

	//Fecha todos os arquivos abertos

	//prepara ambiente da empresa
	RpcSetEnv(cTplEmp,cTplFil)
	
	If !(cTplEmp $ cAllEmp)
		cAllEmp += cTplEmp + "#"
	
		ChkFile("LX5")

		DbSelectArea("LX5TPL")
		DbGoTop()
		While !Eof()
			DbSelectArea("LX5")
			lNew := DbSeek(xFilial("LX5")+LX5TPL->LX5_TABELA+LX5TPL->LX5_CHAVE)
			RecLock("LX5",lNew)
			For nj := 1 To FCount()
				uVar := NIL
				cField := Field(nj)
				If cField == "LX5_FILIAL"
					uVar := cTplFil
				Else
					nPos := LX5TPL->(ColumnPos(cField))
					If nPos > 0
						uVar := LX5TPL->(FieldGet(nPos))
					EndIf
				EndIf
				If uVar <> NIL
					FieldPut(nj,uVar)
				EndIf
			Next nj
			MsUnlock()
			DbSelectArea("LX5TPL")
			DbSkip()
		End
	
		ChkFile("LXB")
		
		DbSelectArea("LXB")
		DbSetOrder(1)
		DbGoTop()
	
		DbSelectArea("LXBTPL")
		DbGoTop()
		While !Eof()
			DbSelectArea("LXB")
			lNew := DbSeek(xFilial("LXB")+LXBTPL->LXB_ALIAS+LXBTPL->LXB_TIPO+LXBTPL->LXB_SEQ+LXBTPL->LXB_COLUNA)
			RecLock("LXB",lNew)
			For nj := 1 To FCount()
				uVar := NIL
				cField := Field(nj)
				If cField == "LXB_FILIAL"
					uVar := cTplFil
				Else
					nPos := LXBTPL->(ColumnPos(cField))
					If nPos > 0
						uVar := LXBTPL->(FieldGet(nPos))
					EndIf
				EndIf
				
				If uVar <> NIL
					FieldPut(nj,uVar)
				EndIf
			Next nj
			MsUnlock()
			DbSelectArea("LXBTPL")
			DbSkip()
		End

	EndIf
    
	//fecha TODOS os alias abertos
	RpcClearEnv()
Next nI

Conout(STR0001) //"Operacao Finalizada com sucesso!!!!"

Return .T.

//----------------------------------------------------------------
/*/{Protheus.doc} TpDrIncLX
Fun��o para incluir os dados nas tabelas LX_
devido a n�o cria��o no aplicador caso j� haja 
a tabela no ambiente

@param   nenhum
@author  julio.nery
@version P12
@since   22/11/2018
@return  lRet - Dados OK ou n�o		
/*/
//----------------------------------------------------------------
Template Function TpDrIncLX(aTplEmp,aTplFiles)
Local cTabFil	:= ""
Local cTabLX5	:= ""
Local cKeyLX5	:= ""
Local lRet		:= .T.
Local lInc		:= .F.
Local nX		:= 0
Local nTamTab	:= 0
Local nTamKey	:= 0
Local aDados	:= {}

If AliasInDic("LX5")
	LjGrvLog("TpDrIncLX","Inclus�o de Dados na LX5")
	COnout("Inclus�o de Dados na LX5")
	
	Aadd(aDados,{"00","T1","TIPOS DE RECEITUARIO","",""})
	Aadd(aDados,{"T1","1","RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)","RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)","RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)"})
	Aadd(aDados,{"T1","2","NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)","NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)","NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)"})
	Aadd(aDados,{"T1","3","NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)","NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)","NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)"})
	Aadd(aDados,{"T1","4","NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)","NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)","NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)"})
	Aadd(aDados,{"T1","5","RECEITA ANTIMICROBIANO EM 2 VIAS","RECEITA ANTIMICROBIANO EM 2 VIAS","RECEITA ANTIMICROBIANO EM 2 VIAS"})
	Aadd(aDados,{"00","T2","TIPOS DE USO DE MEDICAMENTOS","",""})
	Aadd(aDados,{"T2","1","HUMANO","HUMANO","HUMANO"})
	Aadd(aDados,{"T2","2","VETERINARIO","VETERINARIO","VETERINARIO"})
	Aadd(aDados,{"00","T3","CONSELHO PROFISSONAL","",""})
	Aadd(aDados,{"T3","COREN","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM"})
	Aadd(aDados,{"T3","CRM","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA"})
	Aadd(aDados,{"T3","CRMV","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA"})
	Aadd(aDados,{"T3","CRO","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA"})
	Aadd(aDados,{"00","T4","TIPOS DE DOCUMENTO","",""})
	Aadd(aDados,{"T4","1","CARTEIRA DE REGISTRO PROFISSIONAL","CARTEIRA DE REGISTRO PROFISSIONAL","CARTEIRA DE REGISTRO PROFISSIONAL"})
	Aadd(aDados,{"T4","2","CARTEIRA DE IDENTIDADE","CARTEIRA DE IDENTIDADE","CARTEIRA DE IDENTIDADE"})
	Aadd(aDados,{"T4","4","PEDIDO DE AUTORIZACAO DE TRABALHO","PEDIDO DE AUTORIZACAO DE TRABALHO","PEDIDO DE AUTORIZACAO DE TRABALHO"})
	Aadd(aDados,{"T4","5","CERTIDAO DE NASCIMENTO","CERTIDAO DE NASCIMENTO","CERTIDAO DE NASCIMENTO"})
	Aadd(aDados,{"T4","6","CERTIDAO DE CASAMENTO","CERTIDAO DE CASAMENTO","CERTIDAO DE CASAMENTO"})
	Aadd(aDados,{"T4","7","CERTIFICADO DE RESERVISTA","CERTIFICADO DE RESERVISTA","CERTIFICADO DE RESERVISTA"})
	Aadd(aDados,{"T4","8","CARTA PATENTE","CARTA PATENTE","CARTA PATENTE"})
	Aadd(aDados,{"T4","10","CERTIFICADO DE DISPENSA DE INCORPORACAO","CERTIFICADO DE DISPENSA DE INCORPORACAO","CERTIFICADO DE DISPENSA DE INCORPORACAO"})
	Aadd(aDados,{"T4","11","CARTEIRA DE IDENTIDADE DO ESTRANGEIRO","CARTEIRA DE IDENTIDADE DO ESTRANGEIRO","CARTEIRA DE IDENTIDADE DO ESTRANGEIRO"})
	Aadd(aDados,{"T4","19","INSCRICAO ESTADUAL","INSCRICAO ESTADUAL","INSCRICAO ESTADUAL"})
	Aadd(aDados,{"T4","38","AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA","AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA","AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA"})
	Aadd(aDados,{"T4","39","AUTORIZACAO ESPECIAL DE FUNCIONAMENTO","AUTORIZACAO ESPECIAL DE FUNCIONAMENTO","AUTORIZACAO ESPECIAL DE FUNCIONAMENTO"})
	Aadd(aDados,{"T4","40","AUTORIZACAO ESPECIAL SIMPLIFICADA","AUTORIZACAO ESPECIAL SIMPLIFICADA","AUTORIZACAO ESPECIAL SIMPLIFICADA"})
	Aadd(aDados,{"T4","13","PASSAPORTE","PASSAPORTE","PASSAPORTE"})
	Aadd(aDados,{"T4","14","PROTOCOLO DA POLICIA FEDERAL","PROTOCOLO DA POLICIA FEDERAL","PROTOCOLO DA POLICIA FEDERAL"})
	Aadd(aDados,{"T4","20","INSCRICAO MUNICIPAL","INSCRICAO MUNICIPAL","INSCRICAO MUNICIPAL"})
	Aadd(aDados,{"T4","21","ALVARA / LICENSA SANITARIA MUNICIPAL","ALVARA / LICENSA SANITARIA MUNICIPAL","ALVARA / LICENSA SANITARIA MUNICIPAL"})
	Aadd(aDados,{"T4","22","ALVARA / LICENSA SANITARIA ESTADUAL","ALVARA / LICENSA SANITARIA ESTADUAL","ALVARA / LICENSA SANITARIA ESTADUAL"})
	Aadd(aDados,{"T4","50","CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL","CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL","CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL"})
	Aadd(aDados,{"00","T5","ORGAO EXPEDIDOR","",""})
	Aadd(aDados,{"T5","CRA","CONSELHO REGIONAL DE ADMINISTRACAO","CONSELHO REGIONAL DE ADMINISTRACAO","CONSELHO REGIONAL DE ADMINISTRACAO"})
	Aadd(aDados,{"T5","CRE","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA"})
	Aadd(aDados,{"T5","CREA","CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA","CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA","CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA"})
	Aadd(aDados,{"T5","CRF","CONSELHO REGIONAL DE FARMACIA","CONSELHO REGIONAL DE FARMACIA","CONSELHO REGIONAL DE FARMACIA"})
	Aadd(aDados,{"T5","DGPC","DIRETORIA GERAL DA POLICIA CIVIL","DIRETORIA GERAL DA POLICIA CIVIL","DIRETORIA GERAL DA POLICIA CIVIL"})
	Aadd(aDados,{"T5","DPF","DEPARTAMENTO DA POLICIA FEDERAL","DEPARTAMENTO DA POLICIA FEDERAL","DEPARTAMENTO DA POLICIA FEDERAL"})
	Aadd(aDados,{"T5","IDAMP","INSTITUTO IDENT. AROLDO MENDES PAIVA","INSTITUTO IDENT. AROLDO MENDES PAIVA","INSTITUTO IDENT. AROLDO MENDES PAIVA"})
	Aadd(aDados,{"T5","IFP","INSTITUTO FELIX PACHECO","INSTITUTO FELIX PACHECO","INSTITUTO FELIX PACHECO"})
	Aadd(aDados,{"T5","IN","IMPRENSA NACIONAL","IMPRENSA NACIONAL","IMPRENSA NACIONAL"})
	Aadd(aDados,{"T5","JUNTA","JUNTA","JUNTA","JUNTA"})
	Aadd(aDados,{"T5","MAER","MINISTERIO DA AERONAUTICA","MINISTERIO DA AERONAUTICA","MINISTERIO DA AERONAUTICA"})
	Aadd(aDados,{"T5","MEX","MINISTERIO DO EXERCITO","MINISTERIO DO EXERCITO","MINISTERIO DO EXERCITO"})
	Aadd(aDados,{"T5","MM","MINISTERIO DA MARINHA","MINISTERIO DA MARINHA","MINISTERIO DA MARINHA"})
	Aadd(aDados,{"T5","OAB","ORDEM DOS ADVOGADOS DO BRASIL","ORDEM DOS ADVOGADOS DO BRASIL","ORDEM DOS ADVOGADOS DO BRASIL"})
	Aadd(aDados,{"T5","SEJSP","SECRETARIA DE EST. DA JUSTICA E SEG. PUB","SECRETARIA DE EST. DA JUSTICA E SEG. PUB","SECRETARIA DE EST. DA JUSTICA E SEG. PUB"})
	Aadd(aDados,{"T5","SES","SECRETARIA DO ESTADO E DA SEGURANCA","SECRETARIA DO ESTADO E DA SEGURANCA","SECRETARIA DO ESTADO E DA SEGURANCA"})
	Aadd(aDados,{"T5","SESP","SECRETARIA DO ESTADO SEG. PUBLICA","SECRETARIA DO ESTADO SEG. PUBLICA","SECRETARIA DO ESTADO SEG. PUBLICA"})
	Aadd(aDados,{"T5","SJS","SECRETARIA DA JUSTICA E DA SEGURANCA","SECRETARIA DA JUSTICA E DA SEGURANCA","SECRETARIA DA JUSTICA E DA SEGURANCA"})
	Aadd(aDados,{"T5","SJTC","SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA","SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA","SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA"})
	Aadd(aDados,{"T5","SSIPT","SECR. DE SEG. E INFORM. POLICIA TECNICA","SECR. DE SEG. E INFORM. POLICIA TECNICA","SECR. DE SEG. E INFORM. POLICIA TECNICA"})
	Aadd(aDados,{"T5","SSP","SECRETARIA DE SEGURANCA PUBLICA","SECRETARIA DE SEGURANCA PUBLICA","SECRETARIA DE SEGURANCA PUBLICA"})
	Aadd(aDados,{"T5","VACIV","VARA CIVIL","VARA CIVIL","VARA CIVIL"})
	Aadd(aDados,{"T5","VAMEM","VARA DE MENORES","VARA DE MENORES","VARA DE MENORES"})
	Aadd(aDados,{"T5","PM","POLICIA MILITAR","POLICIA MILITAR","POLICIA MILITAR"})
	Aadd(aDados,{"T5","ITB","INSTITUTO TAVARES BURIL","INSTITUTO TAVARES BURIL","INSTITUTO TAVARES BURIL"})
	Aadd(aDados,{"T5","CRM","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA"})
	Aadd(aDados,{"T5","CBM","CORPO DE BOMBEIRO MILITAR","CORPO DE BOMBEIRO MILITAR","CORPO DE BOMBEIRO MILITAR"})
	Aadd(aDados,{"T5","DIC","DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL","DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL","DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL"})
	Aadd(aDados,{"T5","CPF","CONSELHO FEDERAL DE PSICOLOGIA","CONSELHO FEDERAL DE PSICOLOGIA","CONSELHO FEDERAL DE PSICOLOGIA"})
	Aadd(aDados,{"T5","CRO","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA"})
	Aadd(aDados,{"T5","COREN","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM"})
	Aadd(aDados,{"T5","CFN","CONSELHO REGIONAL DE NUTRICIONISTAS","CONSELHO REGIONAL DE NUTRICIONISTAS","CONSELHO REGIONAL DE NUTRICIONISTAS"})
	Aadd(aDados,{"T5","MRE","MINISTERIO DAS RELACOES EXTERIORES","MINISTERIO DAS RELACOES EXTERIORES","MINISTERIO DAS RELACOES EXTERIORES"})
	Aadd(aDados,{"T5","CRCI","CONSELHO REGIONAL DE CORRETORES DE IMOVEIS","CONSELHO REGIONAL DE CORRETORES DE IMOVEIS","CONSELHO REGIONAL DE CORRETORES DE IMOVEIS"})
	Aadd(aDados,{"T5","CRB","CONSELHO REGIONAL DE BIOLOGIA","CONSELHO REGIONAL DE BIOLOGIA","CONSELHO REGIONAL DE BIOLOGIA"})
	Aadd(aDados,{"T5","CRN","CONSELHO REGIONAL DE NUTRICAO","CONSELHO REGIONAL DE NUTRICAO","CONSELHO REGIONAL DE NUTRICAO"})
	Aadd(aDados,{"T5","CFE","CONSELHO FEDERAL DE ENFERMAGEM","CONSELHO FEDERAL DE ENFERMAGEM","CONSELHO FEDERAL DE ENFERMAGEM"})
	Aadd(aDados,{"T5","CRC","CONSELHO REGIONAL DE CONTABILIDADE","CONSELHO REGIONAL DE CONTABILIDADE","CONSELHO REGIONAL DE CONTABILIDADE"})
	Aadd(aDados,{"T5","CRP","CONSELHO REGIONAL DE PSICOLOGIA","CONSELHO REGIONAL DE PSICOLOGIA","CONSELHO REGIONAL DE PSICOLOGIA"})
	Aadd(aDados,{"T5","CRQ","CONSELHO REGIONAL DE QUIMICA","CONSELHO REGIONAL DE QUIMICA","CONSELHO REGIONAL DE QUIMICA"})
	Aadd(aDados,{"T5","ANVISA","AGENCIA NACIONAL DE VIGILANCIA SANITARIA","AGENCIA NACIONAL DE VIGILANCIA SANITARIA","AGENCIA NACIONAL DE VIGILANCIA SANITARIA"})
	Aadd(aDados,{"T5","GOVEST","GOVERNO DO ESTADO","GOVERNO DO ESTADO","GOVERNO DO ESTADO"})
	Aadd(aDados,{"T5","PREF","PREFEITURA","PREFEITURA","PREFEITURA"})
	Aadd(aDados,{"T5","CRBM","CONSELHO REGIONAL DE BIOMEDICINA","CONSELHO REGIONAL DE BIOMEDICINA","CONSELHO REGIONAL DE BIOMEDICINA"})
	Aadd(aDados,{"T5","IPF","INSTITUTO PEREIRA FAUSTINO","INSTITUTO PEREIRA FAUSTINO","INSTITUTO PEREIRA FAUSTINO"})
	Aadd(aDados,{"T5","CREFIT","CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL","CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL","CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL"})
	Aadd(aDados,{"T5","CRMV","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA"})
	Aadd(aDados,{"T5","MTE","MINISTERIO DO TRABALHO E EMPREGO","MINISTERIO DO TRABALHO E EMPREGO","MINISTERIO DO TRABALHO E EMPREGO"})
	Aadd(aDados,{"T5","CRFA","CONSELHO REGIONAL DE FONOUDIOLOGIA","CONSELHO REGIONAL DE FONOUDIOLOGIA","CONSELHO REGIONAL DE FONOUDIOLOGIA"})
	Aadd(aDados,{"T5","CORENC","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA"})
	Aadd(aDados,{"00","T6","MOTIVO DA PERDA","",""})
	Aadd(aDados,{"T6","1","FURTO / ROUBO","FURTO / ROUBO","FURTO / ROUBO"})
	Aadd(aDados,{"T6","2","AVARIA","AVARIA","AVARIA"})
	Aadd(aDados,{"T6","3","VENCIMENTO","VENCIMENTO","VENCIMENTO"})
	Aadd(aDados,{"T6","4","APREENSAO / RECOLHIMENTO PELA VISA","APREENSAO / RECOLHIMENTO PELA VISA","APREENSAO / RECOLHIMENTO PELA VISA"})
	Aadd(aDados,{"T6","5","PERDA NO PROCESSO","PERDA NO PROCESSO","PERDA NO PROCESSO"})
	Aadd(aDados,{"T6","6","COLETA PARA CONTROLE DE QUALIDADE","COLETA PARA CONTROLE DE QUALIDADE","COLETA PARA CONTROLE DE QUALIDADE"})
	Aadd(aDados,{"T6","7","PERDA DE EXCLUSAO DA PORTARIA 344","PERDA DE EXCLUSAO DA PORTARIA 344","PERDA DE EXCLUSAO DA PORTARIA 344"})
	Aadd(aDados,{"T6","8","POR DESVIO DE QUALIDADE","POR DESVIO DE QUALIDADE","POR DESVIO DE QUALIDADE"})
	Aadd(aDados,{"T6","9","RECOLHIMENTO DO FABRICANTE","RECOLHIMENTO DO FABRICANTE","RECOLHIMENTO DO FABRICANTE"})
	Aadd(aDados,{"T7","1","ANTIBACTERIANO","ANTIBACTERIANO","ANTIBACTERIANO"})
	Aadd(aDados,{"T7","2","ANESTESICOS","ANESTESICOS","ANESTESICOS"})
	Aadd(aDados,{"T7","3","CARDIOVASCULAR","CARDIOVASCULAR","CARDIOVASCULAR"})
	Aadd(aDados,{"T7","4","ANTI-HEMORRAGICOS","ANTI-HEMORRAGICOS","ANTI-HEMORRAGICOS"})
	Aadd(aDados,{"T7","5","ANTITUSSICOS E EXPECTORANTE","ANTITUSSICOS E EXPECTORANTE","ANTITUSSICOS E EXPECTORANTE"})
	Aadd(aDados,{"T7","6","APARELHO DIGESTIVO","APARELHO DIGESTIVO","APARELHO DIGESTIVO"})
	Aadd(aDados,{"T7","7","APARELHO GENITURINARIIO","APARELHO GENITURINARIIO","APARELHO GENITURINARIIO"})
	Aadd(aDados,{"T7","8","DOENCAS ENDOCRINAS","DOENCAS ENDOCRINAS","DOENCAS ENDOCRINAS"})
	Aadd(aDados,{"T7","9","APARELHO LOCOMOTOR","APARELHO LOCOMOTOR","APARELHO LOCOMOTOR"})
	Aadd(aDados,{"T7","10","MEDICAO ANTIALERGICA","MEDICAO ANTIALERGICA","MEDICAO ANTIALERGICA"})
	Aadd(aDados,{"T7","11","NUTRICAO","NUTRICAO","NUTRICAO"})
	Aadd(aDados,{"T7","12","HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE","HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE","HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE"})
	Aadd(aDados,{"T7","13","AFECCOES CUTANEAS","AFECCOES CUTANEAS","AFECCOES CUTANEAS"})
	Aadd(aDados,{"T7","14","AFECCOES OTORRINOLARINGOLOGAS","AFECCOES OTORRINOLARINGOLOGAS","AFECCOES OTORRINOLARINGOLOGAS"})
	Aadd(aDados,{"T7","15","OFTAMOLOGIA","OFTAMOLOGIA","OFTAMOLOGIA"})
	Aadd(aDados,{"T7","16","MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES","MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES","MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES"})
	Aadd(aDados,{"T7","17","MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES","MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES","MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES"})
	Aadd(aDados,{"T7","18","VACINAS E IMUNOGLOBULINAS","VACINAS E IMUNOGLOBULINAS","VACINAS E IMUNOGLOBULINAS"})
	Aadd(aDados,{"T7","19","MEIOS DE DIAGNOSTICO","MEIOS DE DIAGNOSTICO","MEIOS DE DIAGNOSTICO"})
	Aadd(aDados,{"T7","20","OUTROS PRODUTOS","OUTROS PRODUTOS","OUTROS PRODUTOS"})
	Aadd(aDados,{"T8","A1","LISTA DAS SUBST�NCIAS ENTORPECENTES","LISTA DAS SUBST�NCIAS ENTORPECENTES","LISTA DAS SUBST�NCIAS ENTORPECENTES"})
	Aadd(aDados,{"T8","A2","LISTA DAS SUBST�NCIAS ENTORPECENTES","LISTA DAS SUBST�NCIAS ENTORPECENTES","LISTA DAS SUBST�NCIAS ENTORPECENTES"})
	Aadd(aDados,{"T8","A3","LISTA DAS SUBST�NCIAS PSICOTR�PICAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS"})
	Aadd(aDados,{"T8","B1","LISTA DAS SUBST�NCIAS PSICOTR�PICAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS"})
	Aadd(aDados,{"T8","B2","LISTA DAS SUBST�NCIAS PSICOTR�PICAS ANOREX�GENAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS ANOREX�GENAS","LISTA DAS SUBST�NCIAS PSICOTR�PICAS ANOREX�GENAS"})
	Aadd(aDados,{"T8","C1","LISTA DAS OUTRAS SUBST�NCIAS SUJEITAS A CONTROLE ESPECI","LISTA DAS OUTRAS SUBST�NCIAS SUJEITAS A CONTROLE ESPECI","LISTA DAS OUTRAS SUBST�NCIAS SUJEITAS A CONTROLE ESPECI"})
	Aadd(aDados,{"T8","C2","LISTA DE SUBST�NCIAS RETIN�ICAS","LISTA DE SUBST�NCIAS RETIN�ICAS","LISTA DE SUBST�NCIAS RETIN�ICAS"})
	Aadd(aDados,{"T8","C3","LISTA DE SUBST�NCIAS IMUNOSSUPRESSORAS","LISTA DE SUBST�NCIAS IMUNOSSUPRESSORAS","LISTA DE SUBST�NCIAS IMUNOSSUPRESSORAS"})
	Aadd(aDados,{"T8","C4","LISTA DAS SUBST�NCIAS ANTI-RETROVIRAIS","LISTA DAS SUBST�NCIAS ANTI-RETROVIRAIS","LISTA DAS SUBST�NCIAS ANTI-RETROVIRAIS"})
	Aadd(aDados,{"T8","C5","LISTA DAS SUBST�NCIAS ANABOLIZANTES","LISTA DAS SUBST�NCIAS ANABOLIZANTES","LISTA DAS SUBST�NCIAS ANABOLIZANTES"})
	
	DbSelectArea("LX5")
	LX5->(DbSetOrder(1)) //LX5_FILIAL + LX5_TABELA + LX5_CHAVE
	cTabFil := xFilial("LX5")
	nTamKey := TamSX3("LX5_CHAVE")[1]
	nTamTab := TamSX3("LX5_TABELA")[1]
	For	nX := 1 to Len(aDados)
		cTabLX5 := Padr(aDados[nX][1],nTamTab)
		cKeyLX5 := Padr(aDados[nX][2],nTamKey)
		If !LX5->(DbSeek(cTabFil+cTabLX5+cKeyLX5))
			lInc := .T.
			RecLock("LX5",.T.)
			REPLACE LX5_FILIAL	WITH cTabFil
			REPLACE LX5_TABELA	WITH aDados[nX][1]
			REPLACE LX5_CHAVE	WITH aDados[nX][2]
			REPLACE LX5_DESCRI	WITH aDados[nX][3]
			REPLACE LX5_DESCSP	WITH aDados[nX][4]
			REPLACE LX5_DESCEN	WITH aDados[nX][5]
			LX5->( MsUnLock() )
			
			LjGrvLog("TpDrIncLX","Novo Dado na LX5",aDados)
			COnout("Novo Dado na LX5 [" + cTabFil+cTabLX5+cKeyLX5 + "]")	
		EndIf
		
		If lInc
			LX5->( DbCommit() )
			lInc := .F.
		EndIf
	Next nX
	
	LjGrvLog("TpDrIncLX","Fim da Inclus�o de Dados na LX5")
	COnout("Fim da Inclus�o de Dados na LX5")
EndIf

If AliasInDic("LXB")
	ASize(aDados,0)
	aDados	:= {}
	lInc	:= .F.
	LjGrvLog("TpDrIncLX","Inclus�o de Dados na LXB")
	COnout("Inclus�o de Dados na LXB")
		
	Aadd(aDados,{"LK9_CONPRO","T3","1"})
	Aadd(aDados,{"LK9_MTVPER","T6","1"})
	Aadd(aDados,{"LK9_ORGEXP","T5","1"})
	Aadd(aDados,{"LK9_TIPOID","T4","1"})
	Aadd(aDados,{"LK9_TIPREC","T1","1"})
	Aadd(aDados,{"LK9_TIPUSO","T2","1"})
	Aadd(aDados,{"LKA_CONPRO","T3","1"})
	
	DbSelectArea("LXB")
	LXB->(DbSetOrder(1)) //LXB_FILIAL + LXB_CAMPO + LXB_TABELA
	cTabFil := xFilial("LXB")
	nTamKey := TamSX3("LXB_CAMPO")[1]
	nTamTab := TamSX3("LXB_TABELA")[1]
	For	nX := 1 to Len(aDados)
		cTabLX5 := Padr(aDados[nX][2],nTamTab)
		cKeyLX5 := Padr(aDados[nX][1],nTamKey)
		If !LXB->(DbSeek(cTabFil+cKeyLX5+cTabLX5))
			lInc := .T.
			RecLock("LXB",.T.)
			REPLACE LXB_FILIAL	WITH cTabFil
			REPLACE LXB_CAMPO	WITH aDados[nX][1]
			REPLACE LXB_TABELA	WITH aDados[nX][2]
			REPLACE LXB_INCLUI	WITH aDados[nX][3]
			LXB->( MsUnLock() )
			
			LjGrvLog("TpDrIncLX","Novo Dado na LXB",aDados)
			COnout("Novo Dado na LXB [" + cTabFil+cTabLX5+cKeyLX5 + "]")	
		EndIf
		
		If lInc
			LXB->( DbCommit() )
			lInc := .F.
		EndIf
	Next nX
	
	LjGrvLog("TpDrIncLX","Fim da Inclus�o de Dados na LXB")
	COnout("Fim da Inclus�o de Dados na LXB")
EndIf

Return lRet