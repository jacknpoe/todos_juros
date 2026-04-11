    3REM Cálculo dos juros, sendo que precisa de arrays para isso
    6REM Versão 0.1: 11/04/2026: feito sem muito conhecimento de Matrix Brandy
   95REM variáveis globais e atribuição de valores para simplificar chamadas às funções
  100Quantidade% = 3
  110Composto% = 1
  120Periodo = 30.0
  130DIM Pagamentos(Quantidade%)
  140DIM Pesos(Quantidade%)
  200FOR indice% = 0 TO Quantidade% - 1
  210Pagamentos(indice%) = (indice% + 1) * Periodo
  220Pesos(indice%) = 1.0
  230NEXT indice%
  295REM testa os valores das funções
  300@% = &20E10
  310GOSUB 500
  320PRINT "Peso total = "; pesototal
  330juros = 3.0
  340GOSUB 1000
  350PRINT "Acréscimo = "; acrescimo
  360precisao% = 15
  370maxiteracoes% = 65
  380maxjuros = 50.0
  390acrescimoparametro = acrescimo
  400GOSUB 1500
  410PRINT "Juros = "; juros
  450END
  495REM calcula a somatória de Pesos()
  500pesototal = 0.0
  510FOR indice% = 0 TO Quantidade% - 1
  520pesototal = pesototal + Pesos(indice%)
  530NEXT indice%
  540RETURN
  995REM calcula o acréscimo a partir dos juros e parcelas
 1000acrescimo = 0.0
 1010IF juros <= 0.0 THEN RETURN
 1020IF Quantidade% < 1 THEN RETURN
 1030IF Periodo <= 0.0 THEN RETURN
 1040GOSUB 500
 1050IF pesototal <= 0.0 THEN RETURN
 1060acumulador = 0.0
 1070FOR indice% = 0 TO Quantidade% - 1
 1080IF Composto% = 0 THEN 1200
 1100acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0) ^ (Pagamentos(indice%) / Periodo)
 1110GOTO 1300
 1200acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0 * Pagamentos(indice%) / Periodo)
 1300NEXT indice%
 1310IF acumulador <= 0.0 THEN RETURN
 1320acrescimo =  (pesototal / acumulador - 1.0) * 100.0
 1330RETURN
 1495REM calcula os juros a partir do acréscimo e parcelas
 1500juros = 0.0
 1510IF maxiteracoes% < 1 THEN RETURN
 1520IF Quantidade% < 1 THEN RETURN
 1530IF precisao% < 1 THEN RETURN
 1540IF Periodo <= 0.0 THEN RETURN
 1550IF acrescimoparametro <= 0.0 THEN RETURN
 1560IF maxjuros <= 0.0 THEN RETURN
 1570GOSUB 500
 1580IF pesototal <= 0.0 THEN RETURN
 1590minjuros = 0.0
 1600juros = maxjuros / 2.0
 1610mindiferenca = 0.1 ^ precisao%
 1620FOR iteracao% = 1 TO maxiteracoes%
 1630IF maxjuros - minjuros < mindiferenca THEN RETURN
 1640GOSUB 1000
 1650IF acrescimo < acrescimoparametro THEN minjuros = juros ELSE maxjuros = juros
 1660juros = (minjuros + maxjuros) / 2.0
 1670NEXT iteracao%
 1680RETURN
