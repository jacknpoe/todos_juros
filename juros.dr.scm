#lang scheme
;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 31/01/2025: a partir da versão em Scheme, alterados os IFs para não terem return-from
;;        0.2: 03/11/2026: listas dinâmicas escaláveis, car/cdr, alterações nas funções recursivas para permitir Tail Call Optimization (TCO)
;;                         adicionadas variáveis `pesoTotal` e validações de variáveis, argumentos e cálculos

;; Variáveis globais para simplificar as chamadas
(define Quantidade 3)
(define Composto 1)
(define Periodo 30.0d0)

;; função recursiva que realmente monta Pagamentos[]
(define (_criaPagamentos indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPagamentos (- indice 1) (cons (* (- Quantidade indice) Periodo) acumulador))
  )
)

;; função açúcar que monta Pagamentos[]
(define (criaPagamentos)
  (_criaPagamentos (- Quantidade 1) '())
)

;; função recursiva que realmente monta Pesos[]
(define (_criaPesos indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPesos (- indice 1) (cons 1.0d0 acumulador))
  )
)

;; função açúcar que monta Pesos[]
(define (criaPesos)
  (_criaPesos (- Quantidade 1) '())
)

;; dados gerais listas
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função recursiva no lugar de um for que realmente calcula a somatória de Pesos[]
(define (_getPesoTotal pesos acumulador)
  (if (null? pesos)
    acumulador
    (_getPesoTotal (cdr pesos) (+ (car pesos) acumulador))
  )
)

;; função açúcar que calcula a somatória de Pesos[]
(define (getPesoTotal)
  (_getPesoTotal Pesos 0.0d0)
)

;; função recursiva no lugar de um for que calcula a soma do amortecimento  de todas as parcelas para juros compostos
(define (_jurosCompostos juros pagamentos pesos acumulador)
  (if (null? pagamentos)
    acumulador
    (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

;; função recursiva no lugar de um for que calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_jurosSimples juros pagamentos pesos acumulador)
  (if (null? pagamentos)
    acumulador
    (_jurosSimples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ 1.0d0 (* (/ juros 100.0d0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula o acréscimo a partir dos juros e dados comuns
(define (jurosParaAcrescimo juros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (<= juros 0.0d0) (< Quantidade 1) (<= Periodo 0.0d0) (<= pesoTotal 0.0d0))
       0.0d0
      (let
        ((acumulador
          (if (= Composto 1)
            (_jurosCompostos juros Pagamentos Pesos 0.0d0)
            (_jurosSimples juros Pagamentos Pesos 0.0d0)
          )
        ))
        (if (<= acumulador 0.0d0)
          0.0d0
          (* (- (/ pesoTotal acumulador) 1.0d0) 100.0d0)
        )
      )
    )
  )    
)

;; função recursiva no lugar de um for que realmente calcula os juros
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0d0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0d0))
    )
  )
)

;; função açúcar que calcula os juros a partir do acréscimo
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (<= acrescimo 0.0d0) (< Quantidade 1) (<= Periodo 0.0d0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0d0) (<= pesoTotal 0.0d0))
      0.0d0
      (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0d0 maxJuros (/ maxJuros 2.0d0))
    )
  )
)

;; testes
(display "Peso total = ")
(display (getPesoTotal))
(newline)
(display "Acréscimo = ")
(define acrescimo (jurosParaAcrescimo 3.0d0))
(display acrescimo)
(newline)
(display "Juros = ")
(define juros (acrescimoParaJuros acrescimo 15 65 50.0d0))
(display juros)
(newline)
