#lang typed/racket

;; Cálculo do juros, sendo que precisa de listas para isso
;; Versão 0.1: 17/06/2026: copiada da versão de Racket (padrão) para adicionar os tipos sob supervisão do ChatGPT

;; dados gerais escalares
(define Quantidade 3)
(define Composto 1)  ;; 1 = true, 0 = false
(define Periodo 30.0)

;; função recursiva que realmente monta Pagamentos[]
(: rCriaPagamentos (-> Integer (Listof Real)))
(define (rCriaPagamentos indice)
  (if (< indice 0)
    '()
    (cons (* (- Quantidade indice) Periodo)
          (rCriaPagamentos (- indice 1)))
  )
)

;; função açúcar que monta Pagamentos[]
(define (criaPagamentos)
  (rCriaPagamentos (- Quantidade 1))
)

(: rCriaPesos (-> Integer (Listof Real)))
;; função recursiva que realmente monta Pesos[]
(define (rCriaPesos indice)
  (if (< indice 0)
    '()
    (cons 1.0
          (rCriaPesos (- indice 1)))
  )
)

;; função açúcar que monta Pesos[]
(define (criaPesos)
  (rCriaPesos (- Quantidade 1))
)

;; dados gerais listas
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função recursiva que realmente calcula a somatória de pesos[]
(: rGetPesoTotal (-> (Listof Real) Real))
(define (rGetPesoTotal lista)
  (if (null? lista)
    0.0
    (+ (car lista) (rGetPesoTotal (cdr lista)))
  )
)

;; função açúcar que chama a função recursiva que calcula a somatória de pesos[]
(define (getPesoTotal)
  (rGetPesoTotal Pesos)
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(: rJurosCompostos (-> Real (Listof Real) (Listof Real) Real))
(define (rJurosCompostos juros pagamentos pesos)
  (if (null? pagamentos)
    0.0
    (+ (/ (car pesos) (real-part (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo)))) (rJurosCompostos juros (cdr pagamentos) (cdr pesos)))
  )
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(: rJurosSimples (-> Real (Listof Real) (Listof Real) Real))
(define (rJurosSimples juros pagamentos pesos)
  (if (null? pagamentos)
    0.0
    (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) (rJurosSimples juros (cdr pagamentos) (cdr pesos)))
  )
)

;; função açúcar que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(: jurosParaAcrescimo (-> Real Real))
(define (jurosParaAcrescimo juros)
  (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (if (= Composto 1)
      (* (- (/ (getPesoTotal) (rJurosCompostos juros Pagamentos Pesos)) 1.0) 100.0)
      (* (- (/ (getPesoTotal) (rJurosSimples juros Pagamentos Pesos)) 1.0) 100.0)
    )
  )
)

;; função recursiva no lugar de um for que realmente calcula os juros
(: rAcrescimoParaJuros (-> Real Real Integer Real Real Real Real))
(define (rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (rAcrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (rAcrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(: acrescimoParaJuros (-> Real Integer Integer Real Real))
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0) (< Quantidade 1) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (rAcrescimoParaJuros acrescimo (real-part (expt 0.1 precisao)) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; testa as funções
(display "Peso total = ")
(display (getPesoTotal))
(display "\n")
(display "Acréscimo = ")
(display (jurosParaAcrescimo 3.0))
(display "\n")
(display "Juros = ")
(display (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 65 50.0))
(display "\n")
