' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 14/04/2026: feita sem muito conhecimento de EndBASIC

' escalares globais para simplificar as chamadas às funções e inicialização
DIM SHARED Quantidade AS INTEGER
DIM SHARED Composto AS BOOLEAN
DIM SHARED Periodo AS DOUBLE
Quantidade = 3
Composto = TRUE
Periodo = 30.0

' arrays globais para simplificar as chamadas às funções
DIM SHARED Pagamentos(Quantidade) AS DOUBLE
DIM SHARED Pesos(Quantidade) AS DOUBLE

' inicialização dos arrays globaus
FOR indice% = 0 TO Quantidade - 1
    Pagamentos(indice%) = (indice% + 1) * Periodo
    Pesos(indice%) = 1.0
NEXT

' calcula a somatória dos elementos do array Pesos()
FUNCTION getPesoTotal#
    acumulador# = 0.0

    FOR indice% = 0 TO Quantidade - 1
        acumulador# = acumulador# + Pesos(indice%)
    NEXT

    getPesoTotal# = acumulador#
END FUNCTION

' calcula o acréscimo a partir dos juros e parcelas
FUNCTION jurosParaAcrescimo#(juros#)
    pesoTotal# = getPesoTotal#
    IF Quantidade > 0 AND Periodo > 0.0 AND pesoTotal# > 0.0 AND juros# > 0.0 THEN
        acumulador# = 0.0
        FOR indice% = 0 TO Quantidade - 1
            IF Composto THEN
                acumulador# = acumulador# + Pesos(indice%) / (1.0 + juros# / 100.0) ^ (Pagamentos(indice%) / Periodo)
            ELSE
                acumulador# = acumulador# + Pesos(indice%) / (1.0 + juros# / 100.0 * Pagamentos(indice%) / Periodo)
            END IF
        NEXT

        IF acumulador# > 0.0 THEN
            jurosParaAcrescimo# = (pesoTotal# / acumulador# - 1.0) * 100.0
        ELSE
            jurosParaAcrescimo# = 0.0
        END IF
    ELSE
        jurosParaAcrescimo# = 0.0
    END IF
END FUNCTION

' calcula os juros a partir do acréscimo e parcelas
FUNCTION acrescimoParaJuros#(acrescimo#, precisao%, maxIteracoes%, maxJuros#)
    pesoTotal# = getPesoTotal#
    IF Quantidade > 0 AND Periodo > 0.0 AND pesoTotal# > 0.0 AND acrescimo# > 0.0 AND precisao% > 0 AND maxIteracoes% > 0 AND maxJuros# > 0.0 THEN
        minJuros# = 0.0
        medJuros# = maxJuros# / 2.0
        minDiferenca# = 0.1 ^ precisao%
        iteracao% = 0

        WHILE iteracao% < maxIteracoes% AND maxJuros# - minJuros# > minDiferenca#
            IF jurosParaAcrescimo#(medJuros#) < acrescimo# THEN
                minJuros# = medJuros#
            ELSE
                maxJuros# = medJuros#
            END IF
            medJuros# = (minJuros# + maxJuros#) / 2.0
            iteracao% = iteracao% + 1
        WEND

        acrescimoParaJuros# = medJuros#
    ELSE
        acrescimoParaJuros# = 0.0
    END IF
END FUNCTION

' calcula e guarda os resultados das funções
pesoTotal# = getPesoTotal#
acrescimoCalculado# = jurosParaAcrescimo#(3.0)
jurosCalculado# = acrescimoParaJuros#(acrescimoCalculado#, 15, 65, 50.0)

' imprime os resultados
PRINT "Peso total ="; pesoTotal#
PRINT "Acréscimo ="; acrescimoCalculado#
PRINT "Juros ="; jurosCalculado#
