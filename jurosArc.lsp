; Calculo do juros, sendo que precisa de arrays pra isso
; Versao 0.1: 30/03/2025: versao sem muito conhecimento de Arc
;             22/10/2026: listas escaladas, recursoes preparadas para Tail Call Optimization (TCO), adicionadas validacoes como nas solucoes iterativas

; variaveis globais para simplificar as chamadas as funcoes (escalares)
(= Quantidade 3)
(= Composto #t)
(= Periodo 30.0)

; funcao recursiva que gera a lista de pagamentos
(def _criaPagamentos (indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPagamentos (+ indice 1) (cons (* indice Periodo) acumulador))
  )
)

; funcao acucar que gera a lista de pagamentos
(def criaPagamentos ()
  (_criaPagamentos 1 '())
)

; funcao recursiva que gera a lista de pesos
(def _criaPesos (indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPesos (+ indice 1) (cons 1.0 acumulador))
  )
)

; funcao acucar que gera a lista de pesos
(def criaPesos ()
  (_criaPesos 1 '())
)

; variaveis globais para simplificar as chamadas as funcoes (listas)
(= Pagamentos (criaPagamentos))
(= Pesos (criaPesos))

; funcao recursiva que calcula a somatoria de Pesos
(def _getPesoTotal (pesos acumulador)
  (if (no pesos)
    acumulador
    (_getPesoTotal (cdr pesos) (+ (car pesos) acumulador))
  )
)

; funcao acucar que calcula a somatoria de Pesos
(def getPesoTotal ()
  (_getPesoTotal Pesos 0.0)
)

; fumcao recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(def _jurosCompostos (juros pagamentos pesos acumulador)
  (if (no pesos)
    acumulador
    (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

; funcao recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(def _jurosSimples (juros pagamentos pesos acumulador)
  (if (no pesos)
    acumulador
    (_jurosSimples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(def jurosParaAcrescimo (juros)
  (let pesoTotal (getPesoTotal)
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= juros 0.0))
      0.0
      (let acumulador
        (if Composto
          (_jurosCompostos juros Pagamentos Pesos 0.0)
          (_jurosSimples juros Pagamentos Pesos 0.0)
        )
        (if (<= acumulador 0.0)
          0.0
          (* (- (/ pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

; funcao recursiva no que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(def _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (< (- maxJuros minJuros) minDiferenca) (<= iteracaoAtual 0))
    medJuros
    (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )
)

; funcao acucar calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(def acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (let pesoTotal (getPesoTotal)
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0.0))
      0.0
      (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
    )
  )
)

; testes
(def teste ()
  ; calcula e guarda os retornos das funcoes
  (= pesoTotal (getPesoTotal))
  (= acrescimoCalculado (jurosParaAcrescimo 3.0))
  (= jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50.0))

  ; imprime os resultados
  (prn "Peso total = " pesoTotal)
  (prn "Acréscimo = " acrescimoCalculado)
  (prn "Juros = " jurosCalculado)
)
