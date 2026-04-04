// Cálculo dos juros, sendo que precisa de arrays para isso
// Versão 0.1: 03/04/2026: feita sem muito conhecimento de wwwBASIC
// a precisão tem cinco dígitos, depois disso é ruído
// (essa solução é, praticamente, a mesma que a em .html, mas roda em node totalmente independente)

var basic = require('wwwbasic');

basic.Basic(
`
    ' declarações antecipadas das fumções
    DECLARE FUNCTION getPesoTotal()
    DECLARE FUNCTION jurosParaAcrescimo(juros)
    DECLARE FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)

    ' variáveis globais para simplificar as chamadas às funções e inicialização de escalares
    Quantidade = 3
    Composto = 1   ' 0 = FALSE
    Periodo = 30.0
    Maximo = Quantidade - 1
    TamDim = Quantidade * 2 - 1
    DIM Parcelas(TamDim) AS double

    
    ' inicialização dos elementos nos arrays Pagamentos() e Pesos()
    FOR indice = 0 TO Maximo
        Parcelas(indice) = (indice + 1.0) * Periodo
        Parcelas(indice + Quantidade) = 1.0
    NEXT indice

    ' calcula e guarda os retornos das funções
    pesoTotal = getPesoTotal()
    acrescimoCalculado = jurosParaAcrescimo(3.0)
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 100.0)

    ' imprime os resultados
    PRINT "Peso total = "; pesoTotal
    PRINT "Acréscimo = "; acrescimoCalculado
    PRINT "Juros = "; jurosCalculado

    END

    ' calcula a somatória dos elementos em Pesos()
    FUNCTION getPesoTotal()
        acumulador = 0.0
        FOR indice = 0 TO Maximo
            acumulador = acumulador + Parcelas(indice + Quantidade)
        NEXT indice
        getPesoTotal = acumulador
    END FUNCTION

    ' calcula o acréscimo a partir dos juros e parcelas
    FUNCTION jurosParaAcrescimo(juros)
        pesoTotal = getPesoTotal()
        IF Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0 THEN
            jurosParaAcrescimo = 0.0
        ELSE
            acumulador = 0.0

            FOR indice = 0  TO Maximo
                IF Composto THEN
                    acumulador = acumulador + Parcelas(indice + Quantidade) / (1.0 + juros / 100.0) ^ (Parcelas(indice) / Periodo)
                ELSE
                    acumulador = acumulador + Parcelas(indice + Quantidade) / (1.0 + juros / 100.0 *    Parcelas(indice) / Periodo)
                END IF
            NEXT

            IF acumulador <= 0.0 THEN
                jurosParaAcrescimo = 0.0
            ELSE
                jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
            END IF
        END IF
    END FUNCTION

    ' calcula os juros a partir do acréscimo e parcelas
    FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
        pesoTotal = getPesoTotal()
        IF Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN
            acrescimoParaJuros = 0.0
        ELSE
            minJuros = 0.0
            medJuros = maxJuros / 2.0
            minDiferenca = 0.1 ^ precisao
            iteracao = 0

            WHILE maxJuros - minJuros > minDiferenca AND iteracao < maxIteracoes
                IF jurosParaAcrescimo(medJuros) < acrescimo THEN
                    minJuros = medJuros
                ELSE
                    maxJuros = medJuros
                END IF
                medJuros = (minJuros + maxJuros) / 2.0
                iteracao = iteracao + 1
            WEND

            acrescimoParaJuros = medJuros
        END IF
    END FUNCTION
`);
