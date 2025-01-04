3 REM Calculo dos juros, sendo que precisa de arrays para isso
6 REM Versao 0.1: 02/01/2025 Copiada de GW-BASIC
9 REM        0.2: 04/01/2025 retirada linha 1210 e alterado acumulador de AC para AM e linha 1600
95 REM variaveis globais e atribuicao de valores
100 QT = 3
110 CM = 1
115 DEFDBL P, J, M, A
120 PR = 30#
130 DIM PA(QT-1)
140 DIM PE(QT-1)
200 FOR I = 0 TO QT-1
210 PA(I) = 30# * (I+1)
220 PE(I) = 1#
230 NEXT I
295 REM testa os retornos das funcoes
300 GOSUB 500
310 PRINT "Peso total =", PT
320 JU = 3#
330 GOSUB 1000
340 PRINT "Acrescimo =", AC
350 PC = 15
360 IN = 100
370 MX = 50#
380 AP = AC
390 GOSUB 1500
400 PRINT "Juros =", JU
450 END
495 REM calcula a soma dos pesos
500 PT = 0#
510 FOR I = 0 TO QT-1
520 PT = PT + PE(I)
530 NEXT I
540 RETURN
995 REM calcula o acrescimo a partir dos juros e parcelas
1000 AC = 0#
1010 IF JU <= 0# THEN RETURN
1020 IF QT < 1 THEN RETURN
1030 IF PR <= 0# THEN RETURN
1040 GOSUB 500
1050 IF PT <= 0# THEN RETURN
1060 AM = 0#
1070 FOR I = 0 TO QT-1
1080 IF CM = 1 THEN 1100 ELSE 1200
1100 AM = AM + PE(I) / (1# + JU / 100#) ^ (PA(I) / PR)
1110 GOTO 1300
1200 AM = AM + PE(I) / (1# + JU / 100# * PA(I) / PR)
1300 NEXT I
1310 AC = (PT / AM - 1#) * 100
1320 RETURN
1495 REM calcula os juros a partir do acrescimo e parcelas
1500 JU = 0
1510 IF IN < 1 THEN RETURN
1520 IF QT < 1 THEN RETURN
1530 IF PC < 1 THEN RETURN
1540 IF PR <= 0# THEN RETURN
1550 IF AP <= 0# THEN RETURN
1560 IF MX <= 0# THEN RETURN
1570 GOSUB 500
1580 IF PT <= 0# THEN RETURN
1590 MN = 0#
1610 MD = .1# ^ PC
1620 FOR J = 1 TO IN
1630 JU = (MN + MX) / 2#
1640 IF (MX - MN) < MD THEN RETURN
1650 GOSUB 1000
1660 IF AC < AP THEN MN = JU ELSE MX = JU
1670 NEXT J
1680 RETURN
