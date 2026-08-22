;; Cálculo do juros, sendo que precisa de listas para isso
;; Versão 0.1: 16/41/2025: a partir da versão em Dr.Scheme, alterados os números para compatíveis com Steel
;;        0.2: 22/08/2026: ChatGPT: listas dinâmicas, car/cdr, alterações nas funções recursivas para permitir Tail Call Optimization

;; dados gerais escalares
(define Quantidade 3)
(define Composto 1)  ;; 1 = true, 0 = false
(define Periodo 30.0)

;; função recursiva que realmente monta Pagamentos[]
(define (rCriaPagamentos indice acumulador)
  (if (< indice 0)
    acumulador
    (rCriaPagamentos (- indice 1) (cons (* (- Quantidade indice) Periodo) acumulador))
  )
)

;; função açúcar que monta Pagamentos[]
(define (criaPagamentos)
  (rCriaPagamentos (- Quantidade 1) '())
)

;; função recursiva que realmente monta Pesos[]
(define (rCriaPesos indice acumulador)
  (if (< indice 0)
    acumulador
    (rCriaPesos (- indice 1) (cons 1.0 acumulador))
  )
)

;; função açúcar que monta Pesos[]
(define (criaPesos)
  (rCriaPesos (- Quantidade 1) '())
)

;; dados gerais listas
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função recursiva no lugar de um for que realmente calcula a somatória de Pesos[]
(define (rGetPesoTotal lista acumulador)
  (if (null? lista)
    acumulador
    (rGetPesoTotal (cdr lista) (+ (car lista) acumulador))
  )
)

;; função açúcar que calcula a somatória de Pesos[]
(define (getPesoTotal)
  (rGetPesoTotal Pesos 0.0)
)

;; função recursiva no lugar de um for que calcula a soma do amortecimento  de todas as parcelas para juros compostos
(define (rJurosCompostos juros pagamentos pesos acumulador)
  (if (null? pagamentos)
    acumulador
    (rJurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

;; função recursiva no lugar de um for que calcula a soma do amortecimento de todas as parcelas para juros simples
(define (rJurosSimples juros pagamentos pesos acumulador)
  (if (null? pagamentos)
    acumulador
    (rJurosSimples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula o acréscimo a partir dos juros e dados comuns
(define (jurosParaAcrescimo juros)
  (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (if (= Composto 1)
      (* (- (/ (getPesoTotal) (rJurosCompostos juros Pagamentos Pesos 0.0)) 1.0) 100.0)
      (* (- (/ (getPesoTotal) (rJurosSimples juros Pagamentos Pesos 0.0)) 1.0) 100.0)
    )
  )
)

;; função recursiva no lugar de um for que realmente calcula os juros
(define (rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (rAcrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (rAcrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )
)

;; função açúcar que calcula os juros a partir do acréscimo
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0) (< Quantidade 1) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (rAcrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; testes
(display "Peso total = ")
(display (getPesoTotal))
(newline)
(display "Acréscimo = ")
(define acrescimo (jurosParaAcrescimo 3.0))
(display acrescimo)
(newline)
(display "Juros = ")
(define juros (acrescimoParaJuros acrescimo 15 100 50.0))
(display juros)
(newline)
