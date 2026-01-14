#!/usr/bin/env rexx

/* Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
   Versões: 0.1.1: 13/01/2026: funções matemáticas (pow, ln, exp)
            0.1.2: 14/01/2026: implementação das outras funções (incluindo p10mn) */

numeric digits 15

/* globais e inicializações */
Quantidade = 3
Composto = 1  /* 1 = true */
Periodo = 30.0

do indice = 1 to Quantidade
    Pagamentos.indice = indice * Periodo
    Pesos.indice = 1.0
end

/* chama as funções e guarda os resultados */
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

/* imprime os resultados */
say "Peso total = " || pesoTotal
say "Acréscimo = " || acrescimoCalculado
say "Juros = " || jurosCalculado

exit

/* calcula os juros a partir do acréscimo e parcelas */
acrescimoParaJuros:
    parse arg acrescimo, precisao, maxIteracoes, maxJuros
    pesoTotal = getPesoTotal()
    if Quantidade < 1 | Periodo <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0 | pesoTotal <= 0.0 then return 0.0
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = p10mn(precisao)
    
    do iteracao = 1 to maxIteracoes
        if maxJuros - minJuros < minDiferenca then return medJuros
        if jurosParaAcrescimo(medJuros) < acrescimo then
            minJuros = medJuros
        else
            maxJuros = medJuros
        medJuros = (minJuros + maxJuros) / 2.0
    end

    return medJuros

/* calcula o acréscimo a partir dos juros e parcelas */
jurosParaAcrescimo:
    parse arg juros
    pesoTotal = getPesoTotal()
    if Quantidade < 1 | Periodo <= 0.0 | juros <= 0.0 | pesoTotal <= 0.0 then return 0.0
    acumulador = 0.0

    do indice = 1 to Quantidade
        if Composto then
            acumulador = acumulador + Pesos.indice / pow(1.0 + juros / 100.0, Pagamentos.indice / Periodo)
        else
            acumulador = acumulador + Pesos.indice / (1.0 + juros / 100.0 * Pagamentos.indice / Periodo)
    end

    if acumulador <= 0.0 then return 0.0
    return (pesoTotal / acumulador - 1.0) * 100.0   

/* calcula a soma de todos os elementos de Pesos */
getPesoTotal:
    acumulador = 0.0

    do indice = 1 to Quantidade
        acumulador = acumulador + Pesos.indice
    end

    return acumulador

/* pow só funciona 100% para bases maiores do que 1.0, por isso precisamos fazer essa pow de 10 na menos n para minDiferenca */
p10mn: procedure
    parse arg expoente
    atual = 1.0

    do indice = 1 to expoente
        atual = atual * 0.1
    end

    return atual

/* funcão pow, simplifica a leitura do código (originalmente do GitHub Copilot, mas a equação é domínio público) */
pow: procedure
    parse arg base, expoente
    return exp(ln(base) * expoente)

/* função para calcular o logaritmo natural, adaptado da versão Apple Pascal do ChatGPT */
ln: procedure
    parse arg x
    ITER = 15
    y = (x - 1.0) / (x + 1.0);
    termo = y;
    soma = 0.0;
    
    do indice = 1 to ITER
        soma  = soma + termo / (2 * indice - 1)
        termo = termo * y * y
    end

    return 2.0 * soma

/* função para calcular e elevado a x, adaptado da versão Apple Pascal do ChatGPT */
exp: procedure
    parse arg x
    ITER = 20
    termo = 1.0
    soma = 1.0
        
    do indice = 1 to ITER
        termo = termo * x / indice
        soma = soma + termo
    end

    return soma
