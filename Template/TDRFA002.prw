#INCLUDE "TOTVS.CH"
#include "rwmake.ch"

/*���������������������������������������������������������������������������
���Programa  � TDREA002 � Autor � Andre Melo         � Data � 05/04/04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Cadastro de Planos de Fidelidade                           ���
�������������������������������������������������������������������������͹��
���Observ.   �                                                            ���
�������������������������������������������������������������������������͹�� 
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE DE DROGARIA - DRO                                 ���
���������������������������������������������������������������������������*/
Template Function TDRFA002()
/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

AxCadastro("MHG","Cadastro de Planos de Fidelidade",".T.",".T.")

Return Nil
