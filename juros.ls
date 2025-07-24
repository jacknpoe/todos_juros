# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 24/07/2025: versão feita sem muito conhecimento de LiveScript

# variáveis globais para simplificar as chamadas de função (os arrays são inicializados dinamicamente)
Quantidade = 300000
Composto = true
Periodo = 30.0
Pagamentos = []
Pesos = []

for indice from 1 to Quantidade
    Pagamentos ++= [indice * Periodo]
    Pesos ++= [1.0]

# calcula a somatória de Pesos[]
getPesoTotal = ->
    acumulador = 0
    for indice from 0 to Quantidade - 1
        acumulador += Pesos[indice]
    acumulador

# calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo = (juros) ->
    pesoTotal = getPesoTotal!
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0
        0.0
    else
        acumulador = 0.0
        for indice from 0 to Quantidade - 1
            if Composto
                acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
            else
                acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
        
        if acumulador <= 0.0
            0.0
        else
            (pesoTotal / acumulador - 1.0) * 100.0

# calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros = (acrescimo, precisao, maxIteracoes, maxJuros) ->
    pesoTotal = getPesoTotal!
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0
        0.0
    else
        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = 0.1 ^ precisao
        indice = 0
        while indice < maxIteracoes
            if maxJuros - minJuros < minDiferenca
                indice = maxIteracoes
            if jurosParaAcrescimo(medJuros) < acrescimo
                minJuros = medJuros
            else
                maxJuros = medJuros
            medJuros = (minJuros + maxJuros) / 2.0
            indice++
        medJuros

# calcula e guarda os resultados das funções
pesoTotal = getPesoTotal!
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 56, 50.0)

# imprime os resultados
console.log "Peso total = #{pesoTotal}"
console.log "Acréscimo = #{acrescimoCalculado}"
console.log "Juros = #{jurosCalculado}"