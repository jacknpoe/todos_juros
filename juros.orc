-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 03/03/2025: versão feita sem muito conhecimento de Orc

-- função recursiva que realmente calcula a somatória de Pesos()
def rGetPesoTotal(pesos, indice) = if (indice = 0) then pesos(0)? else rGetPesoTotal(pesos, indice - 1) + pesos(indice)?

-- perfume que calcula a somatória de Pesos()
def getPesoTotal(quantidade, pesos) = rGetPesoTotal(pesos, quantidade - 1)

-- calcula a soma do amortecimento de todas as parcelas para juros compostos
def rJurosCompostos(periodo, pagamentos, pesos, indice, juros) =
  if (indice = 0) then pesos(0)? / (1.0 + juros / 100.0) ** (pagamentos(0)? / periodo)
  else rJurosCompostos(periodo, pagamentos, pesos, indice - 1, juros) + pesos(indice)? / (1.0 + juros / 100.0) ** (pagamentos(indice)? / periodo)

-- calcula a soma do amortecimento de todas as parcelas para juros simples
def rJurosSimples(periodo, pagamentos, pesos, indice, juros) =
  if (indice = 0) then pesos(0)? / (1.0 + juros / 100.0 * pagamentos(0)? / periodo)
  else rJurosSimples(periodo, pagamentos, pesos, indice - 1, juros) + pesos(indice)? / (1.0 + juros / 100.0 * pagamentos(indice)? / periodo)

-- calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo(quantidade, composto, periodo, pagamentos, pesos, juros) =
  if (composto) then (rGetPesoTotal(pesos, quantidade - 1) / rJurosCompostos(periodo, pagamentos, pesos, quantidade - 1, juros) - 1.0) * 100.0
  else (rGetPesoTotal(pesos, quantidade - 1) / rJurosSimples(periodo, pagamentos, pesos, quantidade - 1, juros) - 1.0) * 100.0

-- função recursiva no lugar de um for, que realmente calcula os juros
def rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) =
  if ((iteracaoAtual = 0) || ((maxJuros - minJuros) <: minDiferenca)) then medJuros
  else if (jurosParaAcrescimo(quantidade, composto, periodo, pagamentos, pesos, medJuros) <: acrescimo)
    then rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca,
                             iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
    else rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, minDiferenca,
                             iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

-- calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, precisao, maxIteracoes, maxJuros) =
  rAcrescimoParaJuros(quantidade, composto, periodo, pagamentos, pesos, acrescimo, 0.1 ** precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

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
jurosCalculado.write(acrescimoParaJuros(Quantidade, Composto, Periodo, Pagamentos, Pesos, acrescimoCalculado.read(), 15, 100, 50.0)) >>

-- imprime os resultados
Println("Peso total = " + pesoTotal.read()) >>
Println("Acréscimo = " + acrescimoCalculado.read()) >>
Println("Juros = " + jurosCalculado.read())