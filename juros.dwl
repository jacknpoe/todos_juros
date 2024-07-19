// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 19/07/2024: versão feita sem muito conhecimento de DadaWeave

%dw 2.0
output application/json

// estrutura básica de variáveis para simplificar as chamadas
var Quantidade = 3
var Composto = true
var Periodo = 30.0
var Pagamentos = [30.0, 60.0, 90.0]
var Pesos = [1.0, 1.0, 1.0]

// função recursiva que realmente calcula a somatória de Pesos[]
fun rGetPesoTotal(indice) =
    if (indice == 0) (Pesos[0])
    else (Pesos[0]) + rGetPesoTotal (indice-1)

//  perfume que calcula a somatória de Pesos[]
fun getPesoTotal() = rGetPesoTotal(Quantidade-1)

// função recursiva que calcula o amortecimento das parcelas em juros compostos
fun rJurosCompostos(indice, juros) = 
    if (indice == 0)
        Pesos[0] / ((1.0 + juros / 100.0) pow (Pagamentos[0] / Periodo))
    else
        Pesos[indice] / ((1.0 + juros / 100.0) pow (Pagamentos[indice] / Periodo)) + rJurosCompostos((indice-1), juros)

// função recursiva que calcula o amortecimento das parcelas em juros simples
fun rJurosSimples(indice, juros) = 
    if (indice == 0)
        Pesos[0] / (1.0 + juros / 100.0 * Pagamentos[0] / Periodo)
    else
        Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo) + rJurosSimples((indice-1), juros)

// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
fun jurosParaAcrescimo(juros) =
    if (Composto) (getPesoTotal() / rJurosCompostos(Quantidade - 1, juros) - 1.0) * 100.0
    else (getPesoTotal() / rJurosSimples(Quantidade - 1, juros) - 1.0) * 100.0

// função recursiva no lugar de um for que realmente calcula os juros
fun rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) =
    if (iteracaoAtual == 0 or (maxJuros - minJuros) < minDiferenca) medJuros
    else if (jurosParaAcrescimo(medJuros) < acrescimo)
        rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
        else rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

// 

// calcula e guarda os resultados
var pesoTotal = getPesoTotal()
var acrescimoCalculado = jurosParaAcrescimo(3.0)
---
{
    // retorna os valores
    potencia: 1.03 pow 0.5,
    pagamentos1: Pagamentos[1],
    peso_total: pesoTotal,
    acrescimo: acrescimoCalculado
}
