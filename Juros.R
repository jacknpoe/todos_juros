# Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0
#             21/03/2026: corrigidos retornos com return() nos ifs; padronização de floats (.0);
#                         uso de ^ e || (em vez de ** e |)¹; pré-alocação de vetores¹;
#                         saída formatada com cat(sprintf())¹; ¹ = sugestões do ChatGPT

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
  pesoTotal <- getPesoTotal()
  if (juros <= 0.0 || Juros$quantidade < 1 || Juros$periodo <= 0.0 || pesoTotal <= 0.0) { return(0.0) }

  acumulador <- 0.0

  for (indice in 1:Juros$quantidade) {
    if (Juros$composto) {
      acumulador <- acumulador + Juros$pesos[indice] / (1.0 + juros / 100.0) ^ (Juros$pagamentos[indice] / Juros$periodo)
    } else {
      acumulador <- acumulador + Juros$pesos[indice] / (1.0 + juros / 100.0 * Juros$pagamentos[indice] / Juros$periodo)
    }
  }
  
  if (acumulador <= 0.0) { return(0.0) }
  (pesoTotal / acumulador - 1.0) * 100.0
}

# calcula os juros a partir de acréscimo e parcelas
acrescimoParaJuros = function(acrescimo, precisao, maximoIteracoes, maximoJuros) {
  pesoTotal <- getPesoTotal()
  if (maximoIteracoes < 1 || Juros$quantidade < 1 || precisao < 1 || Juros$periodo <= 0.0 || acrescimo <= 0.0 || pesoTotal <= 0.0) { return(0.0) }
  minimoJuros <- 0.0
  medioJuros <- maximoJuros / 2.0
  minimaDiferenca <- 0.1 ^ precisao

  for (indice in 1:maximoIteracoes) {
    if ((maximoJuros - minimoJuros) < minimaDiferenca) { return(medioJuros) }
    if(jurosParaAcrescimo(medioJuros) <= acrescimo) {
      minimoJuros <- medioJuros 
    } else {
      maximoJuros <- medioJuros
    }
    medioJuros <- (minimoJuros + maximoJuros) / 2.0
  }
  
  medioJuros
}
  
# inicializa escalares
Juros$quantidade <- 3
Juros$composto <- TRUE
Juros$periodo <- 30.0

# inicializa listas
Juros$pagamentos <- numeric(Juros$quantidade)
Juros$pesos <- numeric(Juros$quantidade)

for(indice in 1:Juros$quantidade) {
  Juros$pagamentos[indice] = indice * Juros$periodo
  Juros$pesos[indice] = 1.0
}

# calcula e guarda os resultados das funções
pesoTotal <- getPesoTotal()
acrescimoCalculado <- jurosParaAcrescimo(3.0)
jurosCalculado <- acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

# imprime os resultados
cat(sprintf("Peso total = %.15f\n", pesoTotal))
cat(sprintf("Acréscimo = %.15f\n", acrescimoCalculado))
cat(sprintf("Juros = %.15f\n", jurosCalculado))
