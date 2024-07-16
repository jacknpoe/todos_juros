REM Cálculo dos juros, sendo que precisa de parcelas pra isso
REM Versão 0.1: 16/07/2024: versão feita sem muito conhecimento de XC=BASIC

REM variáveis globais para simplificar as chamadas
CONST QUANTIDADE = 3
DIM Composto AS BYTE
DIM Periodo AS FLOAT
DIM Pagamentos(QUANTIDADE) AS FLOAT
DIM Pesos(QUANTIDADE) AS FLOAT

REM inicializa as variáveis locais
Composto = 1
Periodo = 30.0

FOR indice AS BYTE = 0 to QUANTIDADE - 1
    Pagamentos(indice) = (indice + 1) * 30.0
    Pesos(indice) = 1.0
NEXT indice

REM calcula a somatória de Pesos()
FUNCTION getPesoTotal AS FLOAT () STATIC
    DIM acumulador AS FLOAT
    acumulador = 0.0
    FOR indice AS BYTE = 0 to QUANTIDADE - 1
        acumulador = acumulador + Pesos(indice)
    NEXT indice
    RETURN acumulador
END FUNCTION

REM calcula o acréscimo a partir dos juros e parcelas
FUNCTION jurosParaAcrescimo AS FLOAT (juros AS FLOAT) STATIC
    DIM pesoTotal AS FLOAT
    pesoTotal = getPesoTotal()
    IF juros <= 0.0 OR QUANTIDADE < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 THEN RETURN 0.0

    DIM acumulador AS FLOAT
    acumulador = 0.0

    FOR indice AS BYTE = 0 to QUANTIDADE - 1
        IF Composto = 1 THEN
            acumulador = acumulador + Pesos(indice) / EXP(Pagamentos(indice) / Periodo * LOG(1.0 + juros / 100.0))
        ELSE
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100 * Pagamentos(indice) / Periodo)
        END IF
    NEXT indice

    RETURN (pesoTotal / acumulador - 1.0) * 100.0
END FUNCTION

REM calcula os juros a partir do acréscimo e parcelas
FUNCTION acrescimoParaJuros AS FLOAT (acrescimo AS FLOAT, precisao AS BYTE, maxIteracoes AS BYTE, maxJuros AS FLOAT) STATIC
    DIM pesoTotal AS FLOAT
    pesoTotal = getPesoTotal()
    IF acrescimo <= 0.0 OR QUANTIDADE < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN RETURN 0.0

    DIM minJuros AS FLOAT
    DIM medJuros AS FLOAT
    DIM minDiferenca AS FLOAT
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = EXP(precisao * LOG(0.1))

    FOR indice AS BYTE = 0 to maxIteracoes
        medJuros = (minJuros + maxJuros) / 2.0
        IF (maxJuros - minJuros) < minDiferenca THEN RETURN medJuros
        IF jurosParaAcrescimo(medJuros) < acrescimo THEN
            minJuros = medJuros
        ELSE
            maxJuros = medJuros
        END IF
    NEXT indice

    RETURN medJuros
END FUNCTION

REM variáveis para guardar os resultados
DIM pesoTotal AS FLOAT
DIM acrescimoCalculado AS FLOAT
DIM jurosCalculado AS FLOAT

REM calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 5, 100, 50.0)

REM imprime os resultados
PRINT "peso total = ", pesoTotal
PRINT "acrescimo = ", acrescimoCalculado
PRINT "juros = ", jurosCalculado
