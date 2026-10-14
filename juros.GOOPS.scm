;; Cálculo dos juros, sendo que precisa de parcelas pra isso
;; Versão 0.1: 02/08/2025: versão feita a partir de Gauche, sem muito conhecimento de GOOPS
;;        0.2: 14/10/2026: com geradores de listas (o que tornou escalável), car e cdr, melhorias nos `or` repetitivos, pesoTotal calculada antes das validações
;;                         ao tentar alterar as funções recursivas para permitir Tail Call Optimization (TCO) houve piora de desempenho (5,4% mais lento)

;; aqui é adicionado o suporte a POO do GOOPS
(use-modules (oop goops))

;; define as varíaveis escalares que serão usadas para criar o objeto juros
(define Quantidade 3)
(define Composto 1)  ;; 0 = false; 1 = true
(define Periodo 30.0)

;; função açúcar que cria a lista de pagamentos
(define-method (criaPagamentos)
    (_criaPagamentos Quantidade '())
)

;; função recursiva que cria a lista de pagamentos
(define (_criaPagamentos indice acumulador)
    (if (<= indice 0)
        acumulador
        (_criaPagamentos (- indice 1) (cons (* indice Periodo) acumulador))
    )
)

;; função açúcar que cria a lista de pesos
(define-method (criaPesos)
    (_criaPesos Quantidade '())
)

;; função recursiva que cria a lista de pesos
(define (_criaPesos indice acumulador)
    (if (<= indice 0)
        acumulador
        (_criaPesos (- indice 1) (cons 1.0 acumulador))
    )
)

;; define as variáveis listas que serão usadas para criar o objeto juros
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; classe <cJuros> com propriedades para simplificar as chamadas aos metodos
(define-class <cJuros> ()
;;    (
        (quantidade #:init-value 0    #:init-keyword #:quantidade #:accessor quantidade)
        (composto   #:init-value 0    #:init-keyword #:composto   #:accessor composto)
        (periodo    #:init-value 30.0 #:init-keyword #:periodo    #:accessor periodo)
        (pagamentos #:init-value '()  #:init-keyword #:pagamentos #:accessor pagamentos)
        (pesos      #:init-value '()  #:init-keyword #:pesos      #:accessor pesos)
;;    )
)

;; função açúcar que calcula a somatória de pesos
(define-method (getPesoTotal (ojuros <cJuros>))
    (_getPesoTotal ojuros (pesos ojuros))
)

;; função recursiva que calcula a somatória de pesos
(define-method (_getPesoTotal (ojuros <cJuros>) pesos)
    (if (null? pesos)
        0
        (+ (car pesos) (_getPesoTotal ojuros (cdr pesos)))
    )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define-method (jurosParaAcrescimo (ojuros <cJuros>) juros)
    (define pesoTotal (getPesoTotal ojuros))
    (if (or (<= juros 0.0) (<= (quantidade ojuros) 0) (<= (periodo ojuros) 0.0) (<= pesoTotal 0.0))
        0.0
        (if (= (composto ojuros) 1)
            (* (- (/ pesoTotal (_jurosCompostos ojuros juros (pagamentos ojuros) (pesos ojuros))) 1.0) 100.0)
            (* (- (/ pesoTotal (_jurosSimples ojuros juros (pagamentos ojuros) (pesos ojuros))) 1.0) 100.0)
        )
    )
)

;; função que calcula a soma do amortecimento de todas as parcelas para juros compostos
(define-method (_jurosCompostos (ojuros <cJuros>) juros pagamentos pesos)
    (if (null? pesos)
        0.0
        (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) (periodo ojuros)))) (_jurosCompostos ojuros juros (cdr pagamentos) (cdr pesos)))
    )
)

;; função que calcula a soma do amortecimento de todas as parcelas para juros simples
(define-method (_jurosSimples (ojuros <cJuros>) juros pagamentos pesos)
    (if (null? pesos)
        0.0
        (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) (periodo ojuros))))) (_jurosSimples ojuros juros (cdr pagamentos) (cdr pesos)))
    )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define-method (acrescimoParaJuros (ojuros <cJuros>) acrescimo precisao maxIteracoes maxJuros)
    (define pesoTotal (getPesoTotal ojuros))
    (if (or (<= acrescimo 0.0) (<= (quantidade ojuros) 0) (<= (periodo ojuros) 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= pesoTotal 0.0))
        0.0
        (_acrescimoParaJuros ojuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
    )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define-method (_acrescimoParaJuros (ojuros <cJuros>) acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
    (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
        medJuros
        (if (< (jurosParaAcrescimo ojuros medJuros) acrescimo)
            (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
            (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
        )
    )
)

;; cria um objeto juros da classe <cJuros> e inicializa as propriedades
(define juros (make <cJuros> #:quantidade Quantidade #:composto Composto #:periodo Periodo #:pagamentos Pagamentos #:pesos Pesos))

;; chama e guarda os resultados dos métodos
(define pesoTotal (getPesoTotal juros))
(define acrescimoCalculado (jurosParaAcrescimo juros 3.0))
(define jurosCalculado (acrescimoParaJuros juros acrescimoCalculado 15 100 50.0))

;; imprime os resultados
(display "Peso total = ") (display pesoTotal) (newline)
(display "Acréscimo = ") (display acrescimoCalculado) (newline)
(display "Juros = ") (display jurosCalculado) (newline)
