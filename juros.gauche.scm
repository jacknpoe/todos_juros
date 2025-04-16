;; Cálculo dos juros, sendo que precisa de parcelas pra isso
;; Versão 0.1: 16/04/2025: versão feita sem muito conhecimento de CLOS

;; classe juros com propriedades para simplificar as chamadas aos metodos
(define-class cJuros ()
    (
        (quantidade :init-value 0    :init-keyword :quantidade :accessor quantidade)
        (composto   :init-value 0    :init-keyword :composto   :accessor composto)
        (periodo    :init-value 30.0 :init-keyword :periodo    :accessor periodo)
        (pagamentos :init-value '()  :init-keyword :pagamentos :accessor pagamentos)
        (pesos      :init-value '()  :init-keyword :pesos      :accessor pesos)
    )
)

;; calcula a somatória de pesos[]
(define-method getPesoTotal ((ojuros cJuros))
    (_getPesoTotal ojuros (- (quantidade ojuros) 1))
)

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(define-method _getPesoTotal ((ojuros cJuros) indice)
    (if (= indice 0)
        (list-ref (pesos ojuros) 0)
        (+ (list-ref (pesos ojuros) 0) (_getPesoTotal ojuros (- indice 1)))
    )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define-method jurosParaAcrescimo ((ojuros cJuros) juros)
    (if (or (or (<= juros 0.0) (<= (quantidade ojuros) 0)) (<= (periodo ojuros) 0.0))
        0.0
        (if (<= (getPesoTotal ojuros) 0.0)
            0.0
            (if (= (composto ojuros) 1)
                (* (- (/ (getPesoTotal ojuros) (_jurosCompostos ojuros (- (quantidade ojuros) 1) juros)) 1.0) 100.0)
                (* (- (/ (getPesoTotal ojuros) (_jurosSimples ojuros (- (quantidade ojuros) 1) juros)) 1.0) 100.0)
            )
        )
    )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(define-method _jurosCompostos ((ojuros cJuros) indice juros)
    (if (= indice 0)
        (/ (list-ref (pesos ojuros) 0) (expt (+ 1.0 (/ juros 100.0)) (/ (list-ref (pagamentos ojuros) 0) (periodo ojuros))))
        (+ (/ (list-ref (pesos ojuros) indice) (expt (+ 1.0 (/ juros 100.0)) (/ (list-ref (pagamentos ojuros) indice) (periodo ojuros)))) (_jurosCompostos ojuros (- indice 1) juros))
    )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(define-method _jurosSimples ((ojuros cJuros) indice juros)
    (if (= indice 0)
        (/ (list-ref (pesos ojuros) 0) (+ 1.0 (* (/ juros 100.0) (/ (list-ref (pagamentos ojuros) 0) (periodo ojuros)))))
        (+ (/ (list-ref (pesos ojuros) indice) (+ 1.0 (* (/ juros 100.0) (/ (list-ref (pagamentos ojuros) indice) (periodo ojuros))))) (_jurosSimples ojuros (- indice 1) juros))
    )
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define-method acrescimoParaJuros ((ojuros cJuros) acrescimo precisao maxIteracoes maxJuros)
    (if (or (or (or (or (or (<= acrescimo 0.0) (<= (quantidade ojuros) 0)) (<= (periodo ojuros) 0.0)) (< maxIteracoes 1)) (< precisao 1)) (<= maxJuros 0.0))
        0.0
        (if (<= (getPesoTotal ojuros) 0.0)
            0.0
            (_acrescimoParaJuros ojuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
        )
    )
)

;; função recursiva no lugar de um for que realmente calcula o acréscimo
(define-method _acrescimoParaJuros ((ojuros cJuros) acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
    (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
        medJuros
        (if (< (jurosParaAcrescimo ojuros medJuros) acrescimo)
            (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
            (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
        )
    )
)

(define (main args)
    ;; cria um objeto juros da classe cJuros e inicializa as propriedades
    (define juros (make cJuros :quantidade 3 :composto 1 :periodo 30.0 :pagamentos (list 30.0 60.0 90.0) :pesos (list 1.0 1.0 1.0)))

    ;; chama e guarda os resultados dos métodos
    (define pesoTotal (getPesoTotal juros))
    (define acrescimoCalculado (jurosParaAcrescimo juros 3.0))
    (define jurosCalculado (acrescimoParaJuros juros acrescimoCalculado 15 100 50.0))

    ;; imprime os resultados
    (display "Peso total = ") (display pesoTotal) (newline)
    (display "Acréscimo = ") (display acrescimoCalculado) (newline)
    (display "Juros = ") (display jurosCalculado) (newline)
)