#lang racket

;; Cálculo do juros, sendo que precisa de vetores para isso
;; Versão 0.1: 20/05/2024: completa, começando do zero, usando o Google

;; dados gerais
(define Quantidade 3)
(define Composto 1)  ;; 1 = true, 0 = false
(define Periodo 30.0)
(define Pagamentos (vector 30.0 60.0 90.0))
(define Pesos (vector 1.0 1.0 1.0))

;; função recursiva que realmente calcula a somatória de pesos[]
(define (rGetPesoTotal indice)
  (if (= indice 0)
    (vector-ref Pesos 0)
    (+ (vector-ref Pesos indice) (rGetPesoTotal (- indice 1)))
  )
)

;; perfume que chama a função recursiva que calcula a somatória de pesos[]
(define getPesoTotal
  (rGetPesoTotal (- Quantidade 1))
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (rJurosCompostos juros indice)
  (if (= indice 0)
    (/ (vector-ref Pesos 0) (expt (+ 1.0 (/ juros 100.0)) (/ (vector-ref Pagamentos 0) Periodo)))
    (+ (/ (vector-ref Pesos indice) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (vector-ref Pagamentos indice) Periodo))) (rJurosCompostos juros (- indice 1)))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(define (rJurosSimples juros indice)
  (if (= indice 0)
    (/ (vector-ref Pesos 0) (+ 1.0 (* (/ juros 100.0) (/ (vector-ref Pagamentos 0) Periodo))))
    (+ (/ (vector-ref Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (vector-ref Pagamentos indice) Periodo)))) (rJurosSimples juros (- indice 1)))
  )    
)

;; perfume que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= getPesoTotal 0.0))
    0.0
    (if (= Composto 1)
      (* (- (/ getPesoTotal (rJurosCompostos juros (- Quantidade 1))) 1.0) 100.0)
      (* (- (/ getPesoTotal (rJurosSimples juros (- Quantidade 1))) 1.0) 100.0)
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

;; perfume que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0) (< Quantidade 1) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= getPesoTotal 0.0))
    0.0
    (rAcrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; testa as funções
(display "Peso total = ")
(display getPesoTotal)
(display "\n")
(display "Acréscimo = ")
(display (jurosParaAcrescimo 3.0))
(display "\n")
(display "Juros = ")
(display (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 100 50.0))
(display "\n")