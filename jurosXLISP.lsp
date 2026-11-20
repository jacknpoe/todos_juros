;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 20/11/2026: a partir de Scheme, trocados 0d0 para 0 e funções açúcar viraram lambdas para poder rodar em XLISP 3.3

;; variáveis escalares globais para simplificar chamadas
(define Quantidade 3)
(define Composto #t)
(define Periodo 30.0)

;; função açúcar que cria a lista Pagamentos
(define criaPagamentos (lambda () (_criaPagamentos 1 '())))

;; função recursiva que cria a lista Pagamentos
(define (_criaPagamentos indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPagamentos (+ indice 1) (cons (* indice Periodo) acumulador))
  )
)

;; função açúcar que cria a lista Pesos
(define criaPesos (lambda () (_criaPesos 1 '())))

;; função recursiva que cria a lista Pesos
(define (_criaPesos indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPesos (+ indice 1) (cons 1.0 acumulador))
  )
)
;; listas globais para simplificar chamadas
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função açúcar que calcula a somatória de Pesos
(define getPesoTotal (lambda () (_getPesoTotal Pesos 0.0)))

;; função recursiva que calcula a somatória de Pesos
(define (_getPesoTotal ppesos acumulador)
  (if (null? ppesos)
    acumulador
    (_getPesoTotal (cdr ppesos) (+ (car ppesos) acumulador))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (if (or (<= juros 0.0) (<= Quantidade 0) (<= Periodo 0.0))
    0.0
    (let ((lpesoTotal (getPesoTotal)))
      (if (<= lpesoTotal 0.0)
        0.0
        (let (( acumulador
          (if Composto
            (_jurosCompostos Pagamentos Pesos juros 0.0)
            (_jurosSimples Pagamentos Pesos juros 0.0)
          )
          ))
          (if (<= acumulador 0.0)
            0.0
            (* (- (/ lpesoTotal acumulador) 1.0) 100.0)
          )
        )
      )
    )
  )
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_jurosCompostos ppagamentos ppesos juros acumulador)
  (if (null? ppesos)
    acumulador
    (_jurosCompostos (cdr ppagamentos) (cdr ppesos) juros (+ (* (car ppesos) (expt (+ 1.0 (/ juros 100.0)) (- 0.0 (/ (car ppagamentos) Periodo)))) acumulador))
  )
)

;; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_jurosSimples ppagamentos ppesos juros acumulador)
  (if (null? ppesos)
    acumulador
    (_jurosSimples (cdr ppagamentos) (cdr ppesos) juros (+ (/ (car ppesos) (+ 1.0 (* (/ juros 100.0) (/ (car ppagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0) (<= Quantidade 0) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0)  (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))  
    )
  )
)

;; calcula e guarda os resultados das funções
(define pesoTotal (getPesoTotal))
(define acrescimoCalculado (jurosParaAcrescimo 3.0))
(define jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

;; testes
(display "Peso total = ") (write pesoTotal) (newline)
(display "Acrescimo = ") (write acrescimoCalculado) (newline)
(display "Juros = ") (write jurosCalculado) (newline)
