@ � CALCULO DOS JUROS, SENDO QUE PRECISA DE ARRAYS PARA ISSO r � VERSAO 0.1: 03/01/2025: COPIADO DO GW-BASIC �	 �        0.2: 04/01/2025 CORRIGIDO ERRO DE IF E RETIRADAS LINHAS 1210, 1600 E 1810 �_ � VARIAVEIS GLOBAIS E ATRIBUICAO DE VALORES 	d QT�3 	n CM�1 	x PR�30 #	� �PA(QT�1) 1	� �PE(QT�1) ?	� �I�0�QT�1 R	� PA(I)�30�(I�1) ^	� PE(I)�1 e	� �I �	'� TESTA OS RETORNOS DAS FUNCOES �	,�500 �	6�"PESO TOTAL =",PT �	@JU�3 �	J�1000 �	T�"ACRESCIMO = ",AC �	^PC�15 �	hIN�100 �	rMX�50 �	|AP�AC 
��1500 
��"JUROS =",JU 
�� '
�PT�0 5
��I�0�QT�1 E
PT�PT�PE(I) L
�I R
� �
�� CALCULA O ACRESCIMO A PARTIR DOS JUROS E PARCELAS �
�AC�0 �
��JU��0ı �
��QT�1ı �
�PR��0ı �
�500 �
�PT��0ı �
$�I�0�QT�1 �
.�CM��1ī1200 LAC�AC�PE(I)�(1�JU�100)�(PA(I)�PR) V�1300 B�AC�AC�PE(I)�(1�JU�100�PA(I)�PR) I�I ^AC�(PT�AC�1)�100 d(� ��� CALCULA OS JUROS A PARTIR DO ACRESCIMO E PARCELAS ��JU�0 ���IN�1ı ���QT�1ı ���PC�1ı ��PR��0ı ��AP��0ı ��MX��0ı �"�500 ,�PT��0ı 6MN�0 JMD�0.1�PC )T�J�1�IN :^JU�(MN�MX)�2 Lh�(MX�MN)�MDı Vr�1000 g|�AC�APī1800 q�MN�JU {��1900 �MX�JU �l�J �v�   
