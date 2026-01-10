3   REM Calculo dos juros,sendo que precisa de arrays para isso
6   REM Versao 0.1:10/01/2026:adaptada de GW-BASIC,sem conhecimento de Apple III Business BASIC
95   REM variaveis globais e atribuicao de valores a arrays
100   quantidade=3
110   composto=1
120   periodo=30.0
130   DIM pagamentos(quantidade-1)
140   DIM pesos(quantidade-1)
200   FOR indice=0 TO quantidade-1
210     pagamentos(indice)=(indice+1.0)*periodo
220     pesos(indice)=1.0
230     NEXT indice
295   REM testa os valores das funcoes
300   GOSUB 500
310   PRINT "Peso total = ";pesototal
320   juros=3.0
330   GOSUB 1000
340   PRINT "Acrescimo = ";acrescimo
350   precisao=15
360   maxiteracoes=100
370   maxjuros=50.0
380   acrescimoparam=acrescimo
390   GOSUB 1500
400   PRINT "Juros = ";juros
450   END
495   REM calcula a somatoria dos pesos
500   pesototal=0.0
510   FOR indice=0 TO quantidade-1
520     pesototal=pesototal+pesos(indice)
530     NEXT indice
540   RETURN
995   REM calcula o acrescimo a partir dos juros e parcelas
1000   acrescimo=0.0
1010   IF juros<=0.0 THEN RETURN
1020   IF quantidade<1 THEN RETURN
1030   IF periodo<=0.0 THEN RETURN
1040   GOSUB 500
1050   IF pesototal<=0.0 THEN RETURN
1060   acumulador=0.0
1070   FOR indice=0 TO quantidade-1
1080     IF composto=1 THEN GOTO 1100:ELSE GOTO 1200
1100     acumulador=acumulador+pesos(indice)/(1.0+juros/100.0)^(pagamentos(indice)/periodo)
1110     GOTO 1300
1200     acumulador=acumulador+pesos(indice)/(1.0+juros/100*pagamentos(indice)/periodo)
1300     NEXT indice
1310   IF acumulador<=0.0 THEN RETURN
1320   acrescimo=(pesototal/acumulador-1.0)*100.0
1330   RETURN
1495   REM calcula os juros a partir do acrescimo e parcelas
1500   juros=0.0
1510   IF maxiteracoes<1 THEN RETURN
1520   IF quantidade<1 THEN RETURN
1530   IF precisao<1 THEN RETURN
1540   IF periodo<=0.0 THEN RETURN
1550   IF acrescimoparam<=0.0 THEN RETURN
1560   IF maxjuros<=0.0 THEN RETURN
1570   GOSUB 500
1580   IF pesototal<=0.0 THEN RETURN
1590   minjuros=0.0
1600   juros=maxjuros/2.0
1610   mindiferenca=0.1^precisao
1620   FOR interacao=1 TO maxiteracoes
1630     IF (maxjuros-minjuros)<mindiferenca THEN RETURN
1640     GOSUB 1000
1650     IF acrescimo<acrescimoparam THEN minjuros=juros:ELSE maxjuros=juros
1660     juros=(minjuros+maxjuros)/2.0
1670     NEXT interacao
1680   RETURN