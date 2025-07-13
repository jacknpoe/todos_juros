# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 12/07/2025: versão feita sem muito conhecimento de Ratfor

define QUANTIDADE 3   # os arrays são fixos

program jurosr
    integer indice
    real*8 pesoTotal, acrescimoCalculado, jurosCalculado

    # variáveis globais para simplificar as chamadas às funções
    logical Composto
    real*8 Periodo, Pagamentos(QUANTIDADE), Pesos(QUANTIDADE)

    data Composto /.true./, Periodo /30.0/

    for (indice = 1; indice <= QUANTIDADE; indice = indice + 1) {
        Pagamentos(indice) = indice * Periodo
        Pesos(indice) = 1.0
    }

    # calcula e guarda os resultados das funções
    pesoTotal = getPesoTotal()
    acrescimoCalculado = jurosParaAcrescimo(real(3.0, 8))
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, real(50.0, 8))

    # imprime os resultados
    print *, "Peso total =", pesoTotal
    print *, "Acréscimo =", acrescimoCalculado
    print *, "Juros =", jurosCalculado

contains

# calcula a somatória de Pesos()
real*8 function getPesoTotal()
    real*8 acumulador
    integer indice

    acumulador = 0.0
    for (indice = 1; indice <= QUANTIDADE; indice = indice + 1) {
        acumulador = acumulador + Pesos(indice)
    }
    return(acumulador)
end function getPesoTotal

# calcula o acréscimo a partir dos juros e parcelas
real*8 function jurosParaAcrescimo(juros)
    real*8 juros, acumulador, pesoTotal
    integer indice
    pesoTotal = getPesoTotal()
    if (QUANTIDADE < 1 | Periodo <= 0.0 | pesoTotal <= 0.0 | juros <= 0.0) {
        return(0.0)
    }

    acumulador = 0.0
    for (indice = 1; indice <= QUANTIDADE; indice = indice + 1) {
        if (Composto) {
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ** (Pagamentos(indice) / Periodo)
        } else {
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
        }
    }

    if (acumulador <= 0.0) {
        return(0.0)
    }
    return((pesoTotal / acumulador - 1.0) * 100.0)
end function jurosParaAcrescimo

# calcula os juros a partir do acréscimo e parcelas
real*8 function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, mJuros)
    real*8 acrescimo, pesoTotal, mJuros, minJuros, medJuros, maxJuros, minDiferenca
    integer precisao, maxIteracoes, indice
    pesoTotal = getPesoTotal()
    if (QUANTIDADE < 1 | Periodo <= 0.0 | pesoTotal <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0) {
        return(0.0)
    }

    minJuros = 0.0
    medJuros = maxJuros / 2.0
    maxJuros = mJuros
    minDiferenca = 0.1 ** precisao
    for (indice = 1; indice <= maxIteracoes; indice = indice + 1) {
        if (maxJuros - minJuros < minDiferenca) {
            return(medJuros)
        }
        if (jurosParaAcrescimo(medJuros) < acrescimo) {
            minJuros = medJuros
        } else {
            maxJuros = medJuros
        }
        medJuros = (minJuros + maxJuros) / 2.0
    }
    return(medJuros)
end function acrescimoParaJuros

end program jurosr
