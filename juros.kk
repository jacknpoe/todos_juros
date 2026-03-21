// Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
// Versão: 0.1: 20/03/2026: feita sem muito conhecimento de Koka

import std/num/float64
import std/num/int64

// variáveis globais escalares para simplificar as chamadas e inicializações
val quantidade: int64 = 3.int64
val composto: bool = True
val periodo: float64 = 30.0

// recursão de cria a lista pagamentos (com inversão de operandos em ++, caso contrário o tempo seria O(n²))
fun rCriaPagamentos(indice: int64): div list<float64> {
  if indice < 1.int64 then return []
  [(indice.float64 * periodo)] ++ rCriaPagamentos(indice - 1.int64)   // está invertida a ordem, mas não importa para o resultado final, apenas é ~200x mais rápido
}

// açúcar de cria a lista pagamentos
fun criaPagamentos(): div list<float64> {
  rCriaPagamentos(quantidade)
}

// recursão de cria a lista pesos (com inversão de operandos em ++, caso contrário o tempo seria O(n²))
fun rCriaPesos(indice: int64): div list<float64> {
  if indice < 1.int64 then return []
  [1.0] ++ rCriaPesos(indice - 1.int64)   // está invertida a ordem, mas não importa para o resultado final, apenas é ~200x mais rápido
}

// açúcar de cria a lista pesos
fun criaPesos(): div list<float64> {
  rCriaPesos(quantidade)
}

// recursão que calcula a somatória dos elementos de uma lista
fun getTotalLista(lista: list<float64>): div float64 {
  if lista.is-empty return 0.0
  getTotalLista(lista.tail) + lista.head.default(0.0)
}

// recursão que calcula o somatório das amortizações dos juros compostos
fun rJurosCompostos(pagamentos: list<float64>, pesos: list<float64>, juros: float64): div float64 {
  if pagamentos.is-empty return 0.0
  rJurosCompostos(pagamentos.tail, pesos.tail, juros) + pesos.head.default(0.0) / pow(1.0 + juros / 100.0, pagamentos.head.default(0.0) / periodo)
}

// recursão que calcula o somatório das amortizações dos juros simples
fun rJurosSimples(pagamentos: list<float64>, pesos: list<float64>, juros: float64): div float64 {
  if pagamentos.is-empty return 0.0
  rJurosSimples(pagamentos.tail, pesos.tail, juros) + pesos.head.default(0.0) / (1.0 + juros / 100.0 * pagamentos.head.default(0.0) / periodo)
}

// açúcar que calcula o acréscimo a partir dos juros e parcelas
fun jurosParaAcrescimo(pagamentos: list<float64>, pesos: list<float64>, juros: float64): div float64 {
  if composto then return (getTotalLista(pesos) / rJurosCompostos(pagamentos, pesos, juros) - 1.0) * 100.0
  (getTotalLista(pesos) / rJurosSimples(pagamentos, pesos, juros) - 1.0) * 100.0
}

// recursão que calcula os juros a partir do acréscimo e parcelas com busca binária (método da bisseção)
fun rAcrescimoParaJuros(pagamentos: list<float64>, pesos: list<float64>, acrescimo: float64, minDiferenca: float64,
                        iteracaoAtual: int64, minJuros: float64, maxJuros: float64, medJuros: float64): div float64 {
  if maxJuros - minJuros < minDiferenca || iteracaoAtual < 1.int64 then return medJuros
  if jurosParaAcrescimo(pagamentos, pesos, medJuros) < acrescimo then
    rAcrescimoParaJuros(pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1.int64, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
  else
    rAcrescimoParaJuros(pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1.int64, minJuros, medJuros, (minJuros + medJuros) / 2.0)
}

// açúcar que calcula os juros a partir do acréscimo e parcelas
fun acrescimoParaJuros(pagamentos: list<float64>, pesos: list<float64>, acrescimo: float64, precisao: int64, maxIteracoes: int64, maxJuros: float64): div float64 {
  rAcrescimoParaJuros(pagamentos, pesos, acrescimo, pow(0.1, precisao.float64), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)
}

fun main() {
  // listas que, infelizmente, só podem ser declaradas dentro de main, inicializadas dinamicamente
  val pagamentos: list<float64> = criaPagamentos()
  val pesos: list<float64> = criaPesos()

  // calcula e guarda os resultados das funções
  val pesoTotal: float64 = getTotalLista(pesos)
  val acrescimoCalculado: float64 = jurosParaAcrescimo(pagamentos, pesos, 3.0)
  val jurosCalculado: float64 = acrescimoParaJuros(pagamentos, pesos, acrescimoCalculado, 15.int64, 65.int64, 50.0)

  // imprime os resultados
  println("Peso Total = " ++ show(pesoTotal))
  println("Acréscimo = " ++ show(acrescimoCalculado))
  println("Juros = " ++ show(jurosCalculado))
}
