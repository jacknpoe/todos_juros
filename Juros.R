# Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0
Juros <- list(quantidade = 0, composto = FALSE, periodo = 30, pagamentos = c(), pesos = c())

# calcula o peso total de todas as parcelas (números arbitrários)
getPesoTotal = function() {
  acumulador <- 0.0
  for (indice in 1:Juros$quantidade) {
    acumulador <- acumulador + Juros$pesos[indice]
  }
  acumulador
}

# calcula o acréscimo a partir de juros e parcelas
jurosParaAcrescimo = function(juros) {
  if (juros <= 0 | Juros$quantidade < 1 | Juros$periodo <= 0) { 0.0 }
  pesoTotal <- getPesoTotal()
  if (pesoTotal <= 0) { 0.0 }
  
  acumulador <- 0.0
  # soZero <- TRUE
  
  for (indice in 1:Juros$quantidade) {
    # if (Juros$pagamentos[indice] > 0 & Juros$pesos[indice] > 0) { soZero <- FALSE}
    if (Juros$composto) {
      acumulador <- acumulador + Juros$pesos[indice] / (1 + juros / 100) ** (Juros$pagamentos[indice] / Juros$periodo)
    } else {
      acumulador <- acumulador + Juros$pesos[indice] / (1 + juros / 100 * Juros$pagamentos[indice] / Juros$periodo)
    }
  }
  
  # if (soZero) { 0.0 }
  if (acumulador <= 0) { 0.0 }
  (pesoTotal / acumulador - 1) * 100
}

# calcula os juros a partir de acréscimo e parcelas
acrescimoParaJuros = function(acrescimo, precisao, maximoIteracoes, maximoJuros) {
  if (maximoIteracoes < 1 | Juros$quantidade < 1 | precisao < 1 | Juros$periodo <= 0 | acrescimo <= 0) { 0.0 }
  minimoJuros <- 0.0
  medioJuros <- maximoJuros / 2
  minimaDiferenca <- 0.1 ** precisao
  pesoTotal <- getPesoTotal()
  if (pesoTotal <= 0) { 0.0 }
  
  for (indice in 1:maximoIteracoes) {
    medioJuros <- (minimoJuros + maximoJuros) / 2
    if ((maximoJuros - minimoJuros) < minimaDiferenca) { medioJuros }
    if(jurosParaAcrescimo(medioJuros) <= acrescimo) {
      minimoJuros <- medioJuros 
    } else {
      maximoJuros <- medioJuros
    }
  }
  
  medioJuros
}
  
# Testes
Juros$quantidade <- 3
Juros$composto <- TRUE
Juros$periodo <- 30

Juros$pagamentos[1] <- 30
Juros$pagamentos[2] <- 60
Juros$pagamentos[3] <- 90

Juros$pesos[1] <- 1
Juros$pesos[2] <- 1
Juros$pesos[3] <- 1

getPesoTotal()
jurosParaAcrescimo(3)
acrescimoParaJuros(jurosParaAcrescimo(3), 15, 100, 50)
