Algoritmo "juros"
// C�lculo do juros, sendo que precisa de arrays pra isso
// Vers�o 0.1: 01/05/2024: vers�o feita sem muito conhecimento de VisualG
//        0.2: 01/05/2024: vers�o com os par�metros completos em acrescimoParaJuros

Var
   // vari�veis globais para simplificar as chamadas
  Quantidade: inteiro
  Composto: logico
  Periodo: real
  Pagamentos: vetor [1..1000] de real
  Pesos: vetor [1..1000] de real

  Acrescimo: real
  Juros: real
  PesoTotal: real
  indice: inteiro

  // calcula a somat�ria de Pesos[]
  Funcao getPesoTotal(): real
  Var
    acumulador: real
    indice: inteiro
  Inicio
    acumulador <- 0.0
    Para indice de 1 ate Quantidade faca
      acumulador <- acumulador + Pesos[indice]
    Fimpara
    Retorne acumulador
  Fimfuncao
  
  // calcula o acr�scimo a partir dos juros e dados comuns (como parcelas)
  Funcao jurosParaAcrescimo( juros: real) : real
  Var
    pesoTotal, acumulador: real
    indice: inteiro
  Inicio
    Se (juros <= 0.0) ou (Quantidade < 1) ou (Periodo <= 0.0) entao
      Retorne 0.0
    Fimse
    pesoTotal <- getPesoTotal()
    Se pesoTotal <= 0.0 entao
      Retorne 0.0
    Fimse
    acumulador <- 0.0
    
    Para indice de 1 ate Quantidade faca
      Se Composto entao
        acumulador <- acumulador + Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
      Senao
        acumulador <- acumulador + Pesos[indice] / (1.0 + juros / 100 * Pagamentos[indice] / Periodo)
      Fimse
    Fimpara
    
    Retorne (pesoTotal / acumulador - 1.0) * 100.0
  Fimfuncao

  // calcula os juros a partir do acr�scimo e dados comuns (como parcelas)
  Funcao acrescimoParaJuros( acrescimo: real; precisao: inteiro; maxIteracao: inteiro; maxJuros: real) : real
  Var
    pesoTotal, minJuros, medJuros, minDiferenca: real
    indice: inteiro
  Inicio
    Se (Quantidade < 1) ou (Periodo <= 0.0) ou (acrescimo <= 0.0) ou (precisao < 1) ou (maxIteracao < 1) ou (maxJuros <= 0.0) entao
      Retorne 0.0
    Fimse
    pesoTotal <- getPesoTotal()
    Se pesoTotal <= 0.0 entao
      Retorne 0.0
    Fimse
    minJuros <- 0.0
    minDiferenca <- 0.1 ^ precisao
    
    Para indice de 1 ate 100 faca
      medJuros <- (minJuros + maxJuros) / 2.0
      Se (maxJuros - minJuros) < minDiferenca entao
        Retorne medJuros
      Fimse
      Se jurosParaAcrescimo(medJuros) < acrescimo entao
        minJuros <- medJuros
      Senao
        maxJuros <- medJuros
      Fimse
    Fimpara
    Retorne medJuros
  Fimfuncao
  
Inicio
  // determinados os valores globais
  Quantidade <- 3
  Composto <- verdadeiro
  Periodo <- 30.0

  Para indice de 1 ate Quantidade faca
    Pagamentos[indice] <- 30.0 * indice
    Pesos[indice] <- 1.0
  Fimpara

  // testa as fun��es
  PesoTotal <- getPesoTotal()
  Escreval( "Peso total = ", PesoTotal)
  Acrescimo <- jurosParaAcrescimo(3.0)
  Escreval( "Acr�scimo = ", Acrescimo)
  Juros <- acrescimoParaJuros(Acrescimo, 15, 100, 50.0)
  Escreval( "Juros = ", Juros)
Fimalgoritmo