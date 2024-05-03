;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 28/04/2024: variáveis, getPesosTotal, jurosParaAcrescimo
;;        0.2: 29/04/2024: acrescimoParaJuros

;; Variáveis
(define Quantidade 3)
(define Composto 1)
(define Periodo 30.0d0)
(define Pagamentos '(30.0d0 60.0d0 90.0d0))
(define Pesos '(1.0d0 1.0d0 1.0d0))

;; calcula a somatória de Pesos[]
(define (getPesoTotal)
  (_getPesoTotal(- Quantidade 1))
)

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(define (_getPesoTotal valor)
  (if (= valor 0)
    (list-ref Pesos 0)
    (+ (list-ref Pesos valor) (_getPesoTotal(- valor 1)))
  )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (if (or (or (<= juros 0.0) (<= Quantidade 0)) (<= Periodo 0.0)) (return-from jurosParaAcrescimo 0.0))
  (if (<= (getPesoTotal) 0.0) (return-from jurosParaAcrescimo 0.0))
  (if (= Composto 1)
      (* (- (/ (getPesoTotal) (_jurosCompostos (- Quantidade 1) juros)) 1.0d0) 10.0d00)
      (* (- (/ (getPesoTotal) (_jurosSimples (- Quantidade 1) juros)) 1.0d0) 100.0d0)
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_jurosCompostos valor juros)
  (if (= valor 0)
    (/ (list-ref Pesos 0) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (list-ref Pagamentos 0) Periodo)))
    (+ (/ (list-ref Pesos valor) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (list-ref Pagamentos valor) Periodo))) (_jurosCompostos (- valor 1) juros))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_jurosSimples valor juros)
  (if (= valor 0)
    (/ (list-ref Pesos 0) (+ 1.0d0 (* (/ juros 100.0d0) (/ (list-ref Pagamentos 0) Periodo))))
    (+ (/ (list-ref Pesos valor) (+ 1.0d0 (* (/ juros 100.0d0) (/ (list-ref Pagamentos valor) Periodo)))) (_jurosSimples (- valor 1) juros))
  )
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (or (or (or (or (<= acrescimo 0.0) (<= Quantidade 0)) (<= Periodo 0.0)) (< maxIteracoes 1)) (< precisao 1)) (<= maxJuros 0.0)) (return-from acrescimoParaJuros 0.0))
  (if (<= (getPesoTotal) 0.0) (return-from acrescimoParaJuros 0.0))
  (_acrescimoParaJuros acrescimo (expt 0.1d0 precisao) maxIteracoes 0.0d0 maxJuros (/ maxJuros 2.0d0))
)

;; função recursiva no lugar de um for que realmente calcula o acréscimo
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0d0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0d0))
    )
  )  
)

;; testes
(display "Pagamentos = ")
(display Pagamentos)
(newline)
(display "Peso total = ")
(display (getPesoTotal))
(newline)
(display "Acrescimo = ")
(define acrescimo (jurosParaAcrescimo 3.0d0))
(display acrescimo)
(newline)
(display "Juros = ")
(define juros (acrescimoParaJuros acrescimo 15 100 50.0d0))
(display juros)
