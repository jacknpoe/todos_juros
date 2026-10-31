-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 03/03/2025: versão feita sem muito conhecimento de Orc
--        0.2: 30/10/2026: revisados os comentários, substituídos os cálculos dos casos-base das funções recursivas por retornos de 0.0 e padronizada a formatação
--        0.3: 31/10/2026: formatados os decimais, validações de variáveis, parâmetros e cálculos
--                         funções recursivas alteradas para permitir Tail Call Optimization (TCO) embora na prática o ganho tenha sido marginal
--                         ATENÇÃO: ainda não escala bem, os testes marcaram em média 10 s para 300 parcelas e 36 min para 3.000 parcelas

-- para formatar os decimais na impressão
import class DecimalFormat = "java.text.DecimalFormat"
val formato = DecimalFormat("0.0##############")

-- função recursiva que calcula a somatória de Pesos()
def rGetPesoTotal(pesos, indice, acumulador) =
  if (indice <: 0)
    then acumulador
  else rGetPesoTotal(pesos, indice - 1, pesos(indice)? + acumulador)

-- função açúcar que calcula a somatória de Pesos()
def getPesoTotal(quantidade, pesos) =
  rGetPesoTotal(pesos, quantidade - 1, 0.0)

-- função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
def rJurosCompostos(periodo, pagamentos, pesos, indice, juros, acumulador) =
  if (indice <: 0)
    then acumulador
    else rJurosCompostos(periodo, pagamentos, pesos, indice - 1, juros, pesos(indice)? / (1.0 + juros / 100.0) ** (pagamentos(indice)? / periodo) + acumulador)

-- função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
def rJurosSimples(periodo, pagamentos, pesos, indice, juros, acumulador) =
  if (indice <: 0)
    then acumulador
    else rJurosSimples(periodo, pagamentos, pesos, indice - 1, juros, pesos(indice)? / (1.0 + juros / 100.0 * pagamentos(indice)? / periodo) + acumulador)

-- função que calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo(quantidade, composto, periodo, pagamentos, pesos, juros) =
  val pesoTotal = rGetPesoTotal(pesos, quantidade - 1, 0.0)
  if ((quantidade <: 1) || (periodo <= 0.0) || (pesoTotal <= 0.0) || (juros <= 0.0))
    then 0.0
    else val acumulador = if (composto)
      then rJurosCompostos(periodo, pagamentos, pesos, quantidade - 1, juros, 0.0)
      else rJurosSimples(periodo, pagamentos, pesos, quantidade - 1, juros, 0.0)
      # if (acumulador <= 0.0)
            then 0.0
            else (pesoTotal / acumulador - 1.0) * 100.0

-- função recursiva que calcula os juros a partir do acréscimo e parcelas
def rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) =
  if ((iteracaoAtual = 0) || ((maxJuros - minJuros) <: minDiferenca))
    then medJuros
    else if (jurosParaAcrescimo(quantidade, composto, periodo, pagamentos, pesos, medJuros) <: acrescimo)
      then rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca,
                              iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
      else rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca,
                              iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

-- função açúcar que calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, precisao, maxIteracoes, maxJuros) =
  val pesoTotal = rGetPesoTotal(pesos, quantidade - 1, 0.0)
  if ((quantidade <: 1) || (periodo <= 0.0) || (pesoTotal <= 0.0) || (acrescimo <= 0.0) || (precisao <: 1) || (maxIteracoes <: 1) || (maxJuros <= 0.0))
    then 0.0
    else rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, 0.1 ** precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

-- variáveis imutáveis + Refs para guardar os resultados
val Quantidade = 3
val Composto = true
val Periodo = 30.0
val pesoTotal = Ref(0.0)
val acrescimoCalculado = Ref(0.0)
val jurosCalculado = Ref(0.0)
fillArray(Array(Quantidade), lambda(i) = 30.0 * (i + 1.0)) >Pagamentos>
fillArray(Array(Quantidade), lambda(i) = 1.0) >Pesos>

-- calcula e guarda o resultado das funções
pesoTotal.write(getPesoTotal(Quantidade, Pesos)) >>
acrescimoCalculado.write(jurosParaAcrescimo(Quantidade, Composto, Periodo, Pagamentos, Pesos, 3.0)) >>
jurosCalculado.write(acrescimoParaJuros(Quantidade, Composto, Periodo, Pagamentos, Pesos, acrescimoCalculado.read(), 15, 65, 50.0)) >>

-- imprime os resultados
Println("Peso total = " + formato.format(pesoTotal?)) >>
Println("Acréscimo = " + formato.format(acrescimoCalculado?)) >>
Println("Juros = " + formato.format(jurosCalculado?))
