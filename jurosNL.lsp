;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 07/03/2025: versão feita sem saber newLISP
;;        0.2: 28/10/2026: listas escaladas, variáveis em vez de funções, first e rest em vez de nth, separados cálculos e impressão,
;;                         validações como nas soluções iterativas, encerramento explícito com (exit)
;;                         funções recursivas alteradas para permitir Tail Call Optimization (TCO)
;;                         estoura a pilha com 933 parcelas na pilha padrão (use a opção -s para aumentar a pilha; testado com sucesso até 5.000 parcelas)

;; Variáveis escalares
(set 'Quantidade 3)
(set 'Composto 1)  ;; 1 = true, 0 = false
(set 'Periodo 30,0)

;; função açúcar que gera a lista de pagamentos
(define (criaPagamentos)
  (_criaPagamentos(- Quantidade 1) '())
)

;; função recursiva que gera a lista de pagamentos
(define (_criaPagamentos indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPagamentos(- indice 1) (cons (mul (- Quantidade indice) Periodo) acumulador))
  )
)

;; função açúcar que gera a lista de pesos
(define (criaPesos)
  (_criaPesos(- Quantidade 1) '())
)

;; função recursiva que gera a lista de pesos
(define (_criaPesos indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPesos(- indice 1) (cons 1,0 acumulador))
  )
)

;; variáveis listas
(set 'Pagamentos (criaPagamentos))
(set 'Pesos (criaPesos))

;; função açúcar que calcula a somatória de Pesos
(define (getPesoTotal)
  (_getPesoTotal Pesos 0,0)
)

;; função recursiva que calcula a somatória de Pesos
(define (_getPesoTotal pesos acumulador)
  (if (empty? pesos)
    acumulador
    (_getPesoTotal(rest pesos) (add (first pesos) acumulador))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (let (pesoTotal (getPesoTotal))
    (if (or (< Quantidade 1) (<= Periodo 0,0) (<= pesoTotal 0,0) (<= juros 0,0))
      0,0
      (let (acumulador
          (if (= Composto 1)
              (_jurosCompostos juros Pagamentos Pesos 0,0)
              (_jurosSimples juros Pagamentos Pesos 0,0)
          )
        )
        (if (<= acumulador 0,0)
          0,0
          (mul (sub (div pesoTotal acumulador) 1,0) 100,0)
        )
      )
    )
  )
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_jurosCompostos juros pagamentos pesos acumulador)
  (if (empty? pesos)
    acumulador
    (_jurosCompostos juros (rest pagamentos) (rest pesos) (add (div (first pesos) (pow (add 1,0 (div juros 100,0)) (div (first pagamentos) Periodo))) acumulador))
  )
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_jurosSimples juros pagamentos acumulador)
  (if (empty? pesos)
    acumulador
    (_jurosSimples juros (rest pagamentos) (rest pesos) (add (div (first pesos) (add 1,0 (mul (div juros 100,0) (div (first pagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (let (pesoTotal (getPesoTotal))
    (if (or (< Quantidade 1) (<= Periodo 0,0) (<= pesoTotal 0,0) (<= acrescimo 0,0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0,0))
      0,0
      (_acrescimoParaJuros acrescimo (pow 0,1 precisao) maxIteracoes 0 maxJuros (div maxJuros 2,0))
    )
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (< (sub maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (div (add medJuros maxJuros) 2,0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (div (add minJuros medJuros) 2,0))
    )
  )
)

;; calcula e guarda os resultados
(set 'pesoTotal (getPesoTotal))
(set 'acrescimoCalculado (jurosParaAcrescimo 3,0))
(set 'jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50,0))

;; imprime os resultados
(println "Peso total = " pesoTotal)
(println "Acrescimo = " acrescimoCalculado)
(println "Juros = " jurosCalculado)
(exit)
