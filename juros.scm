;; Cálculo do juros, sendo que precisa de listas pra isso - originalmente em Scheme (MIT/GNU)
;; Versão 0.1: 28/04/2024: variáveis, getPesoTotal, jurosParaAcrescimo
;;        0.2: 29/04/2024: acrescimoParaJuros
;;        0.3: 17/07/2024: corrige um erro em que multiplica por 10 em vez de 100 na linha 31 e não mostra pagamentos
;;        0.4: 18/11/2026: variável pesoTotal; melhorias em comentários e impressão; de list-ref para car e cdr; validações de variáveis, parâmetros e cálculos
;;                         retirados return-from; listas escaláveis criadas dinamicamente; funções recursivas alteradas para permitir Tail Call Optimization (TCO)
;;        0.5: 19/11/2026: #t em vez de 1
;;        0.6: 25/11/2026: avalia acumulador

;; variáveis escalares globais para simplificar as chamadas
(define Quantidade 3)
(define Composto #t)
(define Periodo 30.0d0)

;; função açúcar que cria a lista Pagamentos
(define (criaPagamentos) (rCriaPagamentos 1 '()))

;; função recursiva que cria a lista Pagamentos
(define (rCriaPagamentos indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (rCriaPagamentos (+ indice 1) (cons (* indice Periodo) acumulador))
  )
)

;; função açúcar que cria a lista Pesos
(define (criaPesos) (rCriaPesos 1 '()))

;; função recursiva que cria a lista Pesos
(define (rCriaPesos indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (rCriaPesos (+ indice 1) (cons 1.0d0 acumulador))
  )
)

;; listas globais para simplificar as chamadas
(define Pagamentos (criaPagamentos))
(define Pesos (criaPesos))

;; função açúcar que calcula a somatória de Pesos
(define (getPesoTotal)
  (_getPesoTotal Pesos 0.0)
)

;; função recursiva que calcula a somatória de Pesos
(define (_getPesoTotal pesos acumulador)
  (if (null? pesos)
    acumulador
    (_getPesoTotal (cdr pesos) (+ (car pesos) acumulador))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (if (or (<= juros 0.0d0) (<= Quantidade 0) (<= Periodo 0.0d0))
    0.0d0
    (let ((pesoTotal (getPesoTotal)))
      (if (<= pesoTotal 0.0d0)
        0.0d0
        (let (( acumulador
          (if Composto
              (_jurosCompostos Pagamentos Pesos juros 0.0)
              (_jurosSimples Pagamentos Pesos juros 0.0)
          ) ))
          (if (<= acumulador 0.0)
            0.0
            (* (- (/ pesoTotal acumulador) 1.0d0) 100.0d0)
          )
        )
      )
    )
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
(define (_jurosCompostos pagamentos pesos juros acumulador)
  (if (null? pesos)
    acumulador
    (_jurosCompostos (cdr pagamentos) (cdr pesos) juros (+ (/ (car pesos) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
(define (_jurosSimples pagamentos pesos juros acumulador)
  (if (null? pesos)
    acumulador
    (_jurosSimples (cdr pagamentos) (cdr pesos) juros (+ (/ (car pesos) (+ 1.0d0 (* (/ juros 100.0d0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0d0) (<= Quantidade 0) (<= Periodo 0.0d0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0d0) (<= (getPesoTotal) 0.0d0))
    0.0d0
    (_acrescimoParaJuros acrescimo (expt 0.1d0 precisao) maxIteracoes 0.0d0 maxJuros (/ maxJuros 2.0d0))
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0d0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0d0))
    )
  )  
)

;; calcula e guarda os resultados das funções
(define pesoTotal (getPesoTotal))
(define acrescimoCalculado (jurosParaAcrescimo 3.0d0))
(define jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0d0))

;; imprime os resultados
(display "Peso total = ") (display pesoTotal) (newline)
(display "Acréscimo = ") (display acrescimoCalculado) (newline)
(display "Juros = ") (display jurosCalculado) (newline)
