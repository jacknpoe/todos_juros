3 REM Cálculo dos juros, sendo que precisa de arrays para isso
6 REM Versão 0.1: 06/04/2026 copiado de MSX BASIC, retirados #, separados ELSEs, ajustados PRINTs

95 REM variáveis globais e atribuição de valores

100 DEFINT C, D, I, Q
110 DEFDBL A, J, M, P
120 QT = 3
130 CM = 1
140 PR = 30
150 DIM PA(QT-1)
160 DIM PE(QT-1)

200 FOR I = 0 TO QT-1
210 PA(I) = PR * (I+1)
220 PE(I) = 1
230 NEXT I

295 REM testa os retornos das funções

300 GOSUB 500
310 PRINT "Peso total = "; : PRINT USING "#.###############"; PT

320 JU = 3
330 GOSUB 1000
340 PRINT "Acréscimo = "; : PRINT USING "#.###############"; AC

350 DG = 15
360 IN = 100
370 MX = 50
380 AP = AC
390 GOSUB 1500
400 PRINT "Juros = "; : PRINT USING "#.###############"; JU

450 END

495 REM calcula a soma dos pesos

500 PT = 0
510 FOR I = 0 TO QT-1
520 PT = PT + PE(I)
530 NEXT I
540 RETURN

995 REM calcula o acréscimo a partir dos juros e parcelas

1000 AC = 0
1010 IF JU <= 0 THEN RETURN
1020 IF QT < 1 THEN RETURN
1030 IF PR <= 0 THEN RETURN
1040 GOSUB 500
1050 IF PT <= 0 THEN RETURN
1060 AM = 0
1070 FOR I = 0 TO QT-1
1080 IF CM = 0 THEN 1200
1100 AM = AM + PE(I) / (1 + JU / 100) ^ (PA(I) / PR)
1110 GOTO 1300
1200 AM = AM + PE(I) / (1 + JU / 100 * PA(I) / PR)
1300 NEXT I
1310 AC = (PT / AM - 1) * 100
1320 RETURN

1495 REM calcula os juros a partir do acréscimo e parcelas

1500 JU = 0
1510 IF IN < 1 THEN RETURN
1520 IF QT < 1 THEN RETURN
1530 IF DG < 1 THEN RETURN
1540 IF PR <= 0 THEN RETURN
1550 IF AP <= 0 THEN RETURN
1560 IF MX <= 0 THEN RETURN
1570 GOSUB 500
1580 IF PT <= 0 THEN RETURN
1590 MN = 0
1610 MD = .1 ^ DG
1620 FOR IT = 1 TO IN
1630 JU = (MN + MX) / 2
1640 IF (MX - MN) < MD THEN RETURN
1650 GOSUB 1000
1660 IF AC < AP THEN MN = JU
1670 IF AC > AP THEN MX = JU
1680 NEXT IT
1690 RETURN
