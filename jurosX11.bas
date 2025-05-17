' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1:  17/05/2025: versão feita sem muito conhecimento de X11-Basic

' variáveis globais para simplificar as chamadas
Quantidade% = 3
Composto% = 1
Periodo = 30.0
DIM Pagamentos(Quantidade%)
DIM Pesos(Quantidade%)

' inicializa dinamicamente os arrays
FOR indice% = 0 TO Quantidade% - 1
    Pagamentos(indice%) = (indice% + 1) * Periodo
    Pesos(indice%) = 1.0
NEXT indice%

' calcula e guarda os resultados das funcoes
pesoTotal = @getPesoTotal
acrescimoCalculado = @jurosParaAcrescimo(3.0)
jurosCalculado = @acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
PRINT "Peso total = "; pesoTotal
PRINT "Acrescimo = "; acrescimoCalculado
PRINT "Juros = "; jurosCalculado

END

' calcula a somatória de Pesos()
FUNCTION getPesoTotal
    LOCAL acumulador, indice%
    acumulador = 0.0
    FOR indice% = 0 TO Quantidade% - 1
        acumulador = acumulador + Pesos(indice%)
    NEXT indice%
    RETURN acumulador
ENDFUNC

' calcula o acréscimo a partir dos juros e parcelas
FUNCTION jurosParaAcrescimo(juros)
    LOCAL acumulador, pesoTotal, indice%
    pesoTotal = @getPesoTotal
    IF Quantidade% < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0
        RETURN 0.0
    ENDIF
    acumulador = 0.0
    FOR indice% = 0 TO Quantidade% - 1
        IF Composto% <> 0
            acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0) ^ (Pagamentos(indice%) / Periodo)
        ELSE
            acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0 * Pagamentos(indice%) / Periodo)
        ENDIF
    NEXT indice%
    IF acumulador <= 0.0
        RETURN 0.0
    ENDIF
    RETURN (pesoTotal / acumulador - 1.0) * 100.0
ENDFUNC

' calcula os juros a partir do acréscimo e parcelas
FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    LOCAL pesoTotal, minJuros, medJuros, minDiferenca, indice%
    pesoTotal = @getPesoTotal
    IF Quantidade% < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0
        RETURN 0.0
    ENDIF
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = 0.1 ^ precisao
    FOR indice% = 1 TO maxIteracoes
        if maxJuros - minJuros < minDiferenca
            RETURN medJuros
        ENDIF
        if @jurosParaAcrescimo(medJuros) < acrescimo
            minJuros = medJuros
        ELSE
            maxJuros = medJuros
        ENDIF
        medJuros = (minJuros + maxJuros) / 2.0
    NEXT indice%
    RETURN medJuros
ENDFUNC