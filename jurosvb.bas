3 REM Cálculo dos juros, sendo que precisa de arrays para isso
6 REM Versão 0.1: 03/04/2026: feita sem muito conhecimento de Vintage BASIC (a partir de TRS-80 BASIC)

95 REM variáveis globais e atribuição de valores

100 QT% = 3
110 CP% = 1
120 PR = 30.0

130 DIM PA(QT%-1)
140 DIM PE(QT%-1)

200 FOR I = 0 TO QT%-1
210 PA(I) = PR * (I + 1.0)
220 PE(I) = 1.0
230 NEXT I

295 REM testa os retornos das funções

300 GOSUB 500
310 PRINT "Peso total ="; PT

320 JU = 3.0
330 GOSUB 1000
340 PRINT "Acréscimo ="; AC

350 PC% = 6
360 MI% = 26
370 MA = 50.0
380 AP = AC
390 GOSUB 1500
400 PRINT "Juros ="; JU

450 END

495 REM calcula a somatória de pesos()

500 PT = 0.0
510 FOR I = 0 TO QT%-1
520 PT = PT + PE(I)
530 NEXT I
540 RETURN

995 REM calcula o acréscimo a partir dos juros e parcelas

1000 AC = 0.0
1010 IF JU <= 0.0 THEN RETURN
1020 IF QT% < 1 THEN RETURN
1030 IF PR <= 0.0 THEN RETURN
1040 GOSUB 500
1050 IF PT <= 0.0 THEN RETURN
1060 CU = 0.0
1070 FOR I = 0 TO QT%-1
1080 IF CP% = 0 THEN GOTO 1200
1100 CU = CU + PE(I) / (1.0 + JU / 100.0) ^ (PA(I) / PR)
1110 GOTO 1300
1200 CU = CU + PE(I) / (1.0 + JU / 100.0 * PA(I) / PR)
1300 NEXT I
1310 IF CU <= 0.0 THEN RETURN
1320 AC = (PT / CU - 1.0) * 100.0
1330 RETURN

1495 REM calcula os juros a partir do acréscimo e parcelas

1500 JU = 0.0
1510 IF MI% < 1 THEN RETURN
1520 IF QT% < 1 THEN RETURN
1530 IF PC% < 1 THEN RETURN
1540 IF PR <= 0.0 THEN RETURN
1550 IF AP <= 0.0 THEN RETURN
1560 IF MA <= 0.0 THEN RETURN
1570 GOSUB 500
1580 IF PT <= 0.0 THEN RETURN
1590 MN = 0.0
1600 JU = MA / 2.0
1610 MD = 0.1 ^ PC%
1620 FOR T = 1 TO MI%
1630 IF (MA - MN) < MD THEN RETURN
1640 GOSUB 1000
1650 IF AC < AP THEN MN = JU
1660 IF AC >= AP THEN MA = JU
1670 JU = (MN + MA) / 2.0
1680 NEXT T
1690 RETURN
