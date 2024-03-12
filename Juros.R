Juros <- list(quantidade = 0, composto = FALSE, periodo = 30, pagamentos = c(), pesos = c())

getPesoTotal = function() {
  acumulador <- 0.0
  for (indice in 1:Juros$quantidade) {
    acumulador <- acumulador + Juros$pesos[indice]
  }
  acumulador
}

jurosParaAcrescimo = function(juros) {
  if (juros <= 0 | Juros$quantidade <= 0 | Juros$periodo <= 0) { 0.0 }
  pesoTotal <- getPesoTotal()
  if (pesoTotal <= 0) { 0.0 }
  
  acumulador <- 0.0
  soZero <- TRUE
  
  for (indice in 1:Juros$quantidade) {
    if (Juros$pagamentos[indice] > 0 & Juros$pesos[indice] > 0) { soZero = FALSE}
    if (Juros$composto) {
      acumulador = acumulador + Juros$pesos[indice] / (1 + juros / 100) ** (Juros$pagamentos[indice] / Juros$periodo)
    } else {
      acumulador = acumulador + Juros$pesos[indice] / ((1 + juros / 100) * Juros$pagamentos[imdice] / Juros$periodo)
    }
  }
  
  if (soZero) { 0.0 }
  (pesoTotal / acumulador - 1) * 100
}

# Testes

Juros$quantidade = 3
Juros$composto = TRUE
Juros$periodo = 30

Juros$pagamentos[1] = 30
Juros$pagamentos[2] = 60
Juros$pagamentos[3] = 90

Juros$pesos[1] = 1
Juros$pesos[2] = 1
Juros$pesos[3] = 1

getPesoTotal()

jurosParaAcrescimo(3)
