' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 03/02/2026: versão feita sem muito conhecimento de Chipmunk Basic

' variáveis globais para simplificar as chamadas às funções (e inicialização de escalares)
LET Quantidade% = 3
LET Composto% = 1  ' 1 = TRUE
LET Periodo = 30.0
DIM Pagamentos(Quantidade% - 1)
DIM Pesos(Quantidade% - 1)

' inicialização dos elementos dos arrays globais
FOR indice% = 0 TO Quantidade% - 1
    LET Pagamentos(indice%) = Periodo * (indice% + 1.0)
    LET Pesos(indice%) = 1.0
NEXT indice%

' calcula a somatória dos elementos em pesos()
SUB getPesoTotal()
    LOCAL acumulador, indice%
    LET acumulador = 0.0

    FOR indice% = 0 TO Quantidade% - 1
        LET acumulador = acumulador + Pesos(indice%)
    NEXT indice%

    LET getPesoTotal = acumulador
END SUB

' calcula o acréscimo a partir dos juros e parcelas
SUB jurosParaAcrescimo(juros)
    LOCAL pesoTotal, acumulador, indice% : LET pesoTotal = getPesoTotal()

    IF Quantidade% < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0
        LET jurosParaAcrescimo = 0.0
    ELSE
        LET acumulador = 0.0
        FOR indice% = 0 TO Quantidade% - 1
            IF Composto% = 1 THEN
                LET acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0) ^ (Pagamentos(indice%) / Periodo)
            ELSE
                LET acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0 * Pagamentos(indice%) / Periodo)
            END IF
        NEXT indice%

        IF acumulador <= 0.0 THEN
            LET jurosParaAcrescimo = 0.0
        ELSE
            LET jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
        END IF
    END IF
END SUB

' calcula os juros a partir do acréscimo e parcelas
SUB acrescimoParaJuros(acrescimo, precisao%, maxIteracoes%, maxJuros)
    LOCAL pesoTotal, minJuros, medJuros, minDiferenca, iteracao% : LET pesoTotal = getPesoTotal()
    IF Quantidade% < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao% < 1 OR maxIteracoes% < 1 OR maxJuros < 0.0
        LET acrescimoParaJuros = 0.0
    ELSE
        LET minJuros = 0.0
        LET medJuros = maxJuros / 2.0
        LET minDiferenca = 0.1 ^ precisao%
        LET iteracao% = 0

        WHILE iteracao% < maxIteracoes%
            IF maxJuros - minJuros < minDiferenca THEN
                LET iteracao% = maxIteracoes%
            ELSE
                IF jurosParaAcrescimo(medJuros) < acrescimo THEN
                    LET minJuros = medJuros
                ELSE
                    LET maxJuros = medJuros
                ENDIF
                LET medJuros = (minJuros + maxJuros) / 2.0
                LET iteracao% = iteracao% + 1
            END IF
        WEND

        LET acrescimoParaJuros = medJuros
    END IF
END SUB

' calcula e guarda os resultados das funções
LET pesoTotal = getPesoTotal()
LET acrescimoCalculado = jurosParaAcrescimo(3.0)
LET jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

' imprime os resultados
PRINT "Peso total = "; : PRINT USING "#.###############"; pesoTotal
PRINT "Acréscimo = "; : PRINT USING "#.###############"; acrescimoCalculado
PRINT "Juros = "; : PRINT USING "#.###############"; jurosCalculado
