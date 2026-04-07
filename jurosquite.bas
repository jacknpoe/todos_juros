3 REM Cálculo dos juros, sendo que precisa de arrays para isso
6 REM Versão 0.1: 07/04/2026: adaptada de TrekBASIC, sem conhecimento de Quite BASIC

10 REM Q = Quantidade; C = Composto; P1 = Periodo; P2 = Pagamentos; P3 = Pesos
20 REM I1 = indice; J = juros (também usado como juros médio na bisseção);
30 REM A1 = acrescimo; P4 = precisao; M1 = maxIteracoes; M2 = maxJuros;
40 REM A2 = acrescimoCalculado; T = pesoTotal; A3 = acumulador; M3 = minJuros;
50 REM M4 = minDiferenca; I2 = iteracao;

95 REM variáveis globais e atribuição de valores a arrays

100 LET Q=3
110 LET C=1 : REM 0 = false
120 LET P1=30.0
130 DIM P2(0)
140 DIM P3(0)
200 FOR I1=0 TO Q-1
210 LET P2(I1)=(I1+1)*P1
220 LET P3(I1)=1.0
230 NEXT I1

295 REM testa os valores das funções

300 GOSUB 500
310 PRINT "Peso total = ";T

320 LET J=3.0
330 GOSUB 1000
340 PRINT "Acréscimo = ";A1

350 LET P4=15
360 LET M1=100
370 LET M2=50.0
380 LET A2=A1
390 GOSUB 1500
400 PRINT "Juros = ";J

450 END

495 REM calcula a somatória dos P3 (pesos)

500 LET T=0.0
510 FOR I1=0 TO Q-1
520 LET T=T+P3(I1)
530 NEXT I1
540 RETURN

995 REM calcula o acréscimo a partir dos juros e parcelas

1000 LET A1=0.0
1010 IF J<=0.0 THEN RETURN
1020 IF Q<1 THEN RETURN
1030 IF P1<=0.0 THEN RETURN
1040 GOSUB 500
1050 IF T<=0.0 THEN RETURN
1060 LET A3=0.0
1070 FOR I1=0 TO Q-1
1080 IF C=0 THEN 1200
1100 LET A3=A3+P3(I1)/(1.0+J/100.0)**(P2(I1)/P1)
1120 GOTO 1300
1200 LET A3=A3+P3(I1)/(1.0+J/100*P2(I1)/P1)
1300 NEXT I1
1310 IF A3<=0.0 THEN RETURN
1320 LET A1=(T/A3-1.0)*100.0
1330 RETURN

1495 REM calcula os juros a partir do acréscimo e parcelas

1500 LET J=0.0
1510 IF M1<1 THEN RETURN
1520 IF Q<1 THEN RETURN
1530 IF P4<1 THEN RETURN
1540 IF P1<=0.0 THEN RETURN
1550 IF A2<=0.0 THEN RETURN
1560 IF M2<=0.0 THEN RETURN
1570 GOSUB 500
1580 IF T<=0.0 THEN RETURN
1590 LET M3=0.0
1600 LET J=M2/2.0
1610 LET M4=0.1**P4
1620 FOR I2=1 TO M1
1630 IF (M2-M3)<M4 THEN RETURN
1640 GOSUB 1000
1650 IF A1<A2 THEN LET M3=J ELSE LET M2=J
1660 LET J=(M3+M2)/2.0
1670 NEXT I2
1680 RETURN
