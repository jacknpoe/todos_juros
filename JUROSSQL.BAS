3 REMark calculo dos juros, sendo que precisa de arrays para isso
6 REMark Versao 0.1: 20/05/2025: feita sem muito conhecimento de Sinclair SuperBASIC
95 REMark variaveis globais e atribuicao de valores
100 Quantidade = 3
110 Composto = 1
120 Periodo = 30
130 DIM Pagamentos(Quantidade-1)
140 DIM Pesos(Quantidade-1)
200 FOR I = 0 TO Quantidade-1
210 Pagamentos(I) = Periodo * (I + 1)
220 Pesos(I) = 1
230 NEXT I
295 REMark testa os retornos das funcoes
299 CLS
300 pesoTotal = getPesoTotal
310 PRINT "Peso total = "; pesoTotal
450 STOP
495 REMark calcula a somatoria dos pesos
500 DEFine FuNction getPesoTotal
510 acumulador = 0
520 FOR I = 0 TO Quantidade-1
530 acumulador = acumulador + Pesos(I)
540 NEXT I
550 RETurn acumulador
560 END DEFine
995 REMark calcula o acrescimo a partir dos juros e parcelas
1000 DEFine FuNction jurosParaAcrescimo(juros)
1010 IF juros <= 0 THEN RETurn 0
1020 IF Quantidade < 1 THEN RETurn 0
1030 IF Periodo <= 0 THEN RETurn 0
1040 pesoTotal = getPesoTotal
1050 IF pesoTotal <= 0 THEN RETurn 0
1060 acumulador = 0
1070 FOR I = 0 TO Quantidade-1
1080 IF Composto <> 0 THEN
1090 acumulador = acumulador + Pesos(I) / (1 + juros / 100) ^ (Pagamentos(I) / Periodo)
1100 ELSE
1110 acumulador = acumulador + Pesos(I) / (1 + juros / 100 * Pagamentos(I) / Periodo)
1120 END IF
1130 NEXT I
1140 IF acumulador <= 0 THEN RETurn 0
1150 RETurn (pesoTotal / acumulador - 1) * 100
1160 END DEFine
1495 REMark calcula os juros a partir do acrescimo e parcelas
1500 DEFine FuNction acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
1510 IF maxIteracoes < 1 THEN RETurn 0
1520 IF Quantidade < 1 THEN RETurn 0
1530 IF precisao < 1 THEN RETurn 0
1540 IF Periodo <= 0 THEN RETurn 0
1550 IF acrescimo <= 0 THEN RETurn 0
1560 IF maxJuros <= 0 THEN RETurn 0
1570 pesoTotal = getPesoTotal
1580 IF pesoTotal <= 0 THEN RETurn 0
1590 minJuros = 0
1600 medJuros = maxJuros / 2
1610 minDiferenca = .1 ^ precisao
1620 FOR T = 1 TO maxIteracoes
1630 IF maxJuros - minJuros < minDiferenca THEN RETurn medJuros
1640 IF jurosParaAcrescimo(medJuros) < acrescimo THEN
1650 minJuros = medJuros
1660 ELSE
1670 maxJuros = medJuros
1680 END IF
1690 medJuros = (minJuros + maxJuros) / 2
1700 NEXT T
1710 RETurn medJuros
1720 END DEFine
