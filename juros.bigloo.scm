;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 02/08/2025: a partir da versão em Steel, incluindo módulo e trocados prints para Bigloo
;;        0.2: 13/10/2026: melhorias gerais nas validações, geradoras de listas para escalabilidade, correção de recursões infinitas,
;;                         funções recursivas alteradas para permitir Tail Call Optimization (TCO)

(module juros)

;; Variáveis globais para simplificar as chamadas
(define Quantidade 3)
(define Composto 1)  ;; 1 = true, 0 = false
(define Periodo 30.0)
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função açúcar que monta a lista Pagamentos
(define (criaPagamentos)
    (_criaPagamentos (- Quantidade 1) '())
)

;; função recursiva que monta a lista Pagamentos
(define (_criaPagamentos indice acumulador)
    (if (< indice 0)
        acumulador
        (_criaPagamentos (- indice 1) (cons (* (- Quantidade indice) Periodo) acumulador))
    )
)

;; função açúcar que monta a lista Pesos
(define (criaPesos)
    (_criaPesos (- Quantidade 1) '())
)

;; função recursiva que monta a lista Pesos
(define (_criaPesos indice acumulador)
    (if (< indice 0)
        acumulador
        (_criaPesos (- indice 1) (cons 1.0 acumulador))
    )
)

;; função açúcar que calcula a somatória de Pesos
(define (getPesoTotal)
     (_getPesoTotal Pesos 0.0)
)

;; função recursiva que calcula a somatória de Pesos
(define (_getPesoTotal pesos acumulador)
    (if (null? pesos)
        acumulador
        (_getPesoTotal (cdr pesos) (+ acumulador (car pesos)))
    )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
    (define pesoTotal (getPesoTotal))
    (if (or (<= juros 0.0) (<= Quantidade 0) (<= Periodo 0.0) (<= pesoTotal 0.0))
        0.0
        (if (= Composto 1)
            (* (- (/ pesoTotal (_jurosCompostos juros Pagamentos Pesos 0.0)) 1.0) 100.0)
            (* (- (/ pesoTotal (_jurosSimples juros Pagamentos Pesos 0.0)) 1.0) 100.0)
        )
    )
)

;; função recursiva que calcula a soma do amortecimento das parcelas para juros compostos
(define (_jurosCompostos juros pagamentos pesos acumulador)
    (if (null? pesos)
        acumulador
        (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ ( car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) acumulador))
    )
)

;; função recursiva que calcula a soma do amortecimento das parcelas para juros simples
(define (_jurosSimples juros pagamentos pesos acumulador)
    (if (null? pesos)
        acumulador
        (_jurosSimples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) acumulador))
    )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
    (define pesoTotal (getPesoTotal))
    (if (or (<= acrescimo 0.0) (<= Quantidade 0) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= pesoTotal 0.0))
        0.0
        (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
    )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
    (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
        medJuros
        (if (< (jurosParaAcrescimo medJuros) acrescimo)
            (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
            (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
        )
    )
)

;; testes
(define peso (getPesoTotal))
(print "Peso total = " peso)
(define acrescimo (jurosParaAcrescimo 3.0))
(print "Acréscimo = " acrescimo)
(define juros (acrescimoParaJuros acrescimo 15 65 50.0))
(print "Juros = " juros)
