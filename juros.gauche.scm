;; Cálculo dos juros, sendo que precisa de parcelas pra isso
;; Versão 0.1: 16/04/2025: versão feita a partir de Steel sem muito conhecimento de Gauche
;;        0.2: 21/10/2026: listas escaladas e substituição de list-ref por car e cdr
;;                         funções recursivas agora permitem Tail Call Optimization (TCO) com melhora média de 1,72x

;; variáveis escalares para atributos
(define Quantidade 3)
(define Composto 1)  ;; 1 = true, 0 = false
(define Periodo 30.0)

;; função açúcar que monta Pagamentos[]
(define (criaPagamentos)
  (rCriaPagamentos Quantidade '())
)

;; função recursiva que realmente monta Pagamentos[]
(define (rCriaPagamentos indice acumulador)
  (if (< indice 1)
    acumulador
    (rCriaPagamentos (- indice 1) (cons (* indice Periodo) acumulador))
  )
)

;; função açúcar que monta Pesos[]
(define (criaPesos)
  (rCriaPesos Quantidade '())
)

;; função recursiva que realmente monta Pesos[]
(define (rCriaPesos indice acumulador)
  (if (< indice 1)
    acumulador
    (rCriaPesos (- indice 1) (cons 1.0 acumulador))
  )
)

;; variáveis listas para atributos
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; classe cJuros com propriedades para simplificar as chamadas aos metodos
(define-class cJuros ()
    (
        (quantidade :init-value 0    :init-keyword :quantidade :accessor quantidade)
        (composto   :init-value 0    :init-keyword :composto   :accessor composto)
        (periodo    :init-value 30.0 :init-keyword :periodo    :accessor periodo)
        (pagamentos :init-value '()  :init-keyword :pagamentos :accessor pagamentos)
        (pesos      :init-value '()  :init-keyword :pesos      :accessor pesos)
    )
)

;; função açúcar que calcula a somatória de pesos
(define-method getPesoTotal ((ojuros cJuros))
    (_getPesoTotal ojuros (pesos ojuros) 0.0)
)

;; função recursiva que calcula a somatória de pesos
(define-method _getPesoTotal ((ojuros cJuros) pesos acumulador)
    (if (null? pesos)
        acumulador
        (_getPesoTotal ojuros (cdr pesos) (+ (car pesos) acumulador))
    )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define-method jurosParaAcrescimo ((ojuros cJuros) juros)
    (let ((pesoTotal (getPesoTotal ojuros)))
        (if (or (<= juros 0.0) (<= (quantidade ojuros) 0) (<= (periodo ojuros) 0.0) (<= pesoTotal 0.0))
            0.0
            (if (= (composto ojuros) 1)
                (* (- (/ pesoTotal (_jurosCompostos ojuros (pagamentos ojuros) (pesos ojuros) juros 0.0)) 1.0) 100.0)
                (* (- (/ pesoTotal (_jurosSimples ojuros (pagamentos ojuros) (pesos ojuros) juros 0.0)) 1.0) 100.0)
            )
        )
    )
)

;; função que calcula a soma do amortecimento de todas as parcelas para juros compostos
(define-method _jurosCompostos ((ojuros cJuros) pagamentos pesos juros acumulador)
    (if (null? pagamentos)
        acumulador
        (_jurosCompostos ojuros (cdr pagamentos) (cdr pesos) juros (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) (periodo ojuros)))) acumulador))
    )
)

;; função que calcula a soma do amortecimento de todas as parcelas para juros simples
(define-method _jurosSimples ((ojuros cJuros) pagamentos pesos juros acumulador)
    (if (null? pagamentos)
        acumulador
        (_jurosSimples ojuros (cdr pagamentos) (cdr pesos) juros (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) (periodo ojuros))))) acumulador))
    )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define-method acrescimoParaJuros ((ojuros cJuros) acrescimo precisao maxIteracoes maxJuros)
    (let ((pesoTotal (getPesoTotal ojuros)))
        (if (or (<= acrescimo 0.0) (<= (quantidade ojuros) 0) (<= (periodo ojuros) 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= pesoTotal 0.0))
            0.0
            (_acrescimoParaJuros ojuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
        )
    )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
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
    (define juros (make cJuros :quantidade Quantidade :composto Composto :periodo Periodo :pagamentos Pagamentos :pesos Pesos))

    ;; chama e guarda os resultados dos métodos
    (define pesoTotal (getPesoTotal juros))
    (define acrescimoCalculado (jurosParaAcrescimo juros 3.0))
    (define jurosCalculado (acrescimoParaJuros juros acrescimoCalculado 15 65 50.0))

    ;; imprime os resultados
    (display "Peso total = ") (display pesoTotal) (newline)
    (display "Acréscimo = ") (display acrescimoCalculado) (newline)
    (display "Juros = ") (display jurosCalculado) (newline)
)
