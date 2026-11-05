// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 19/07/2024: versão feita sem muito conhecimento de DadaWeave
//        0.2: 05/11/2026: 15 decimais; melhorados comentários; valida variáveis, parâmetros, cálculos; removidos casos especiais; corrigido índice em rGetPesoTotal
//                         arrays escaláveis criados dinamicamente; funções recursivas agora permitem Tail Call Optimization (TCO)

// RODAR COM: dw run -f juros.dwl -s

%dw 2.0
import * from dw::util::Math
output application/json

// configuração da precisão
var MaxJuros = 50.0
var Precisao = 15.0
var MaxIteracoes = ceil((log(MaxJuros / 2.0) + Precisao * log(10.0)) / log(2.0))

// variáveis escalares para simplificar as chamadas
var Quantidade = 3
var Composto = true
var Periodo = 30.0

// função recursiva que cria o array Pagamentos[]
fun rCriaPagamentos(indice, acumulador) =
    if (indice < 0)
        acumulador
    else
        rCriaPagamentos(indice - 1, acumulador << (indice + 1) * Periodo)

// função açúcar que cria o array Pagamentos[]
fun criaPagamentos() = rCriaPagamentos(Quantidade - 1, [])

// função recursiva que cria o array Pesos[]
fun rCriaPesos(indice, acumulador) =
    if (indice < 0)
        acumulador
    else
        rCriaPesos(indice - 1, acumulador << 1.0)

// função açúcar que cria o array Pagamentos[]
fun criaPesos() = rCriaPesos(Quantidade - 1, [])

// arrays para simplificar as chamadas
var Pagamentos = criaPagamentos()
var Pesos = criaPesos()

// função recursiva que calcula a somatória de Pesos[]
fun rGetPesoTotal(indice, acumulador) =
    if (indice < 0)
        acumulador
    else
        rGetPesoTotal (indice - 1, Pesos[indice] + acumulador)

// função açúcar que calcula a somatória de Pesos[]
fun getPesoTotal() = rGetPesoTotal(Quantidade - 1, 0.0)

// função recursiva que calcula o amortecimento das parcelas em juros compostos
fun rJurosCompostos(indice, juros, acumulador) = 
    if (indice < 0)
        acumulador
    else
        rJurosCompostos((indice - 1), juros, Pesos[indice] / decimalPow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo) + acumulador)

// função recursiva que calcula o amortecimento das parcelas em juros simples
fun rJurosSimples(indice, juros, acumulador) = 
    if (indice < 0)
        acumulador
    else
        rJurosSimples((indice - 1), juros, Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo) + acumulador)

// função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
fun jurosParaAcrescimo(juros) =
    do {
        var pesoTotal = getPesoTotal()
        ---
        if (Quantidade < 1 or Periodo <= 0.0 or juros <= 0.0 or pesoTotal <= 0.0)
            0.0
        else
            do {
                var acumulador =
                    if (Composto)
                        rJurosCompostos(Quantidade - 1, juros, 0.0)
                    else
                        rJurosSimples(Quantidade - 1, juros, 0.0)
                ---
                if (acumulador <= 0.0)
                    0.0
                else
                    (pesoTotal / acumulador - 1.0) * 100.0
            }
    }

// função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
fun rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) =
    if (iteracaoAtual == 0 or (maxJuros - minJuros) < minDiferenca)
        medJuros
    else
        if (jurosParaAcrescimo(medJuros) < acrescimo)
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
        else
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

// função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
fun acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) =
    if (Quantidade < 1 or Periodo <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 or getPesoTotal() <= 0.0)
        0.0
    else
        rAcrescimoParaJuros(acrescimo, 0.1 pow precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

// arredonda um número ponto flutuante para limitar decimais no JSON
fun arredonda(numero, casas) = round(numero * (10.0 pow casas)) / (10.0 pow casas)

// calcula e guarda os resultados
var pesoTotalCalculado = getPesoTotal()
var acrescimoCalculado = jurosParaAcrescimo(3.0)
var jurosCalculado = acrescimoParaJuros(acrescimoCalculado, Precisao, MaxIteracoes, MaxJuros)

---
{
    // retorna os valores
    pesoTotal: arredonda(pesoTotalCalculado, 15),
    acrescimo: arredonda(acrescimoCalculado, 15),
    juros: arredonda(jurosCalculado, 15)
}
