PROGRAM JUROSDB

REM Cálculo dos juros, sendo que precisa de parcelas pra isso
REM Versão 0.1:  30/01/2025: versão feita sem muito conhecimento de Decimal BASIC

REM variáveis globais para simplificar as chamadas
REM PUBLIC NUMERIC Quantidade
REM PUBLIC NUMERIC Composto
REM PUBLIC NUMERIC Periodo
REM PUBLIC NUMERIC Pagamentos(1000)
REM PUBLIC NUMERIC Pesos(1000)

REM calcula a somatória de Pesos()
FUNCTION getPesoTotal
   LET acumulador = 0.0
   FOR indice = 1 TO Quantidade
      LET acumulador = acumulador + Pesos(indice)
   NEXT indice
   LET getPesoTotal = acumulador
END FUNCTION

REM calcula o acréscimo a partir dos juros e parcelas
FUNCTION jurosParaAcrescimo(juros)
   LET pesoTotal = GetPesoTotal
   IF juros <= 0.0 OR Quantidade < 1 OR periodo <= 0.0 OR pesoTotal <= 0.0 THEN
      LET jurosParaAcrescimo = 0.0
   ELSE
      LET acumulador = 0.0
       
      FOR indice = 1 TO Quantidade
         IF Composto = 1 THEN
            LET acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
         ELSE
            LET acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
         END IF
      NEXT indice
       
      IF acumulador <= 0.0 THEN
         LET jurosParaAcrescimo = 0.0
      ELSE
         LET jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
      END IF
   END IF
END FUNCTION

REM calcula os juros a partir do acréscimo e parcelas
FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
   LET pesoTotal = GetPesoTotal
   IF acrescimo <= 0.0 OR Quantidade < 1 OR periodo <= 0.0 OR pesoTotal <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN
      LET acrescimoParaJuros = 0.0
   ELSE
      LET minJuros = 0.0
      LET minDiferenca = 0.1 ^ precisao
       
      FOR turno = 1 TO maxIteracoes
         LET medJuros = (minJuros + maxJuros) / 2.0
         IF (maxJuros - minJuros) < minDiferenca THEN EXIT FOR
         IF jurosParaAcrescimo(medJuros) < acrescimo THEN
            LET minJuros = medJuros
         ELSE
            LET maxJuros = medJuros
         END IF
      NEXT turno
       
      LET acrescimoParaJuros = medJuros
   END IF
END FUNCTION

REM inicializa as variáveis globais
LET Quantidade = 3
LET Composto = 1
LET Periodo = 30.0
DIM Pagamentos(Quantidade)
DIM Pesos (Quantidade)

FOR indice = 1 TO Quantidade
   LET Pagamentos(indice) = 30.0 * indice
   LET Pesos(indice) = 1.0
NEXT indice

REM calcula e guarda o retorno das funções
LET pesoTotal = getPesoTotal
LET acrescimoCalculado = jurosParaAcrescimo(3.0)
LET jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

REM imprime os resultados
PRINT "Peso total ="; pesoTotal
PRINT "Acréscimo ="; acrescimoCalculado
PRINT "Juros ="; jurosCalculado

END