@  CALCULO DOS JUROS, SENDO QUE PRECISA DE ARRAYS PARA ISSO p_  VARIAVEIS GLOBAIS E ATRIBUICAO DE VALORES |d QT% ² 3 n CP% ² 1 x PR ² 30.0 ¤  PA(QT%) ²  PE(QT%) ÄÈ  I ² 1 ¤ QT% ×Ò PA(I) ² PR ¬ I çÜ PE(I) ² 1.0 ïæ  I 	' TESTA OS RETORNOS DAS FUNCOES 	, 500 6	6 "PESO TOTAL ="; PT C	@JU ² 3.0 N	J 1000 f	T "ACRESCIMO ="; AC s	^PC% ² 15 	hMI% ² 100 	rMA ² 50.0 	|AP ² AC ¦	 1500 º	 "JUROS =", JU À	Â á	ïCALCULA A SOMA¤RIA DOS PESOS î	ôPT ² 0.0  
þ I ² 1 ¤ QT% 
PT ² PT ª PE(I) 
 I "
 Z
ã CALCULA O ACRESCIMO A PARTIR DOS JUROS E PARCELAS g
èAC ² 0.0 {
ò JU ³² 0.0 §  
ü QT% ³ 1 §  ¡
 PR ³² 0.0 §  «
 500 ¿
 PT ³² 0.0 §  Ì
$CU ² 0.0 Þ
. I ² 1 ¤ QT% õ
8 CP% ² 0 §  1200 -LCU ² CU ª PE(I) ­ (1.0 ª JU ­ 100.0) ® (PA(I) ­ PR) 8V 1300 f°CU ² CU ª (1.0 ª JU ­ 100.0 ¬ PA(I) ­ PR) n I  CU ³² 0.0 §  £(AC ² (PT ­ CU « 1.0) ¬ 100.0 ©2 á× CALCULA OS JUROS A PARTIR DO ACRESCIMO E PARCELAS îÜJU ² 0.0  æ MI% ³ 1 §  ð QT% ³ 1 §  $ú PC% ³ 1 §  8 PR ³² 0.0 §  L AP ³² 0.0 §  ` MA ³² 0.0 §  j" 500 ~5 PT ³² 0.0 §  6MN ² 0.0 @JU ² MA ­ 2.0 °JMD ² 0.1 ® PC% ÂT T ² 1 ¤ MI% Û^ (MA « MN) ³ MD §  æh 1000 þr AC ³ AP § MN ² JU | AC ± AP § MA ² JU /JU ² (MN ª MA) ­ 2.0 7 T =   