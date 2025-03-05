; Calculo do juros, sendo que precisa de arrays pra isso
; Versao 0.1: 05/03/2025: versao sem muito conhecimento de Otus Lisp
; AVISO: algumas verificacoes foram retiradas, entao os calculos sao indefinidos para valores incorretos

; variaveis
(setq Quantidade 3)
(setq Composto 1)
(setq Periodo 30.0)
(setq Pagamentos (list 30.0 60.0 90.0))
(setq Pesos (list 1.0 1.0 1.0))

; funcao recursiva no lugar de um for com acumulador que realmente calcula a somatoria de Pesos[]
(define (_gPeso pesos)
  (if (= (length(cdr pesos)) 0)
    (car pesos)
    (+ (car pesos) (_gPeso(cdr pesos)))
  )
)

; calcula a somatoria de Pesos[]
(define (gPeso)
  (_gPeso Pesos)
)

; calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_compostos juros pagamentos pesos)
  (if (= (length(cdr pesos)) 0)
    (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo)))
    (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) (_compostos juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_simples juros pagamentos pesos)
  (if (= (length(cdr pesos)) 0)
    (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo))))
    (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) (_simples juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(define (dJuros juros)
  (if (= Composto 1)
    (* (- (/ (gPeso) (_compostos juros Pagamentos Pesos)) 1.0) 100.0)
    (* (- (/ (gPeso) (_simples juros) Pagamentos Pesos) 1.0) 100.0)
  )
)

; funcao recursiva no lugar de um for que realmente calcula os juros
(define (_pJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (< (- maxJuros minJuros) minDiferenca)
    (/ (+ minJuros maxJuros) 2.0)
    (if (< (dJuros (/ (+ minJuros maxJuros) 2.0)) acrescimo)
      (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros)
      (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0))
    )
  )
)

; calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(define (pJuros acrescimo precisao maxIteracoes maxJuros)
  (_pJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

; testes
(setq pesoC (gPeso))
(print "Peso total = " pesoC)
(setq acrescimoC (dJuros 3.0))
(print "Acrescimo = " acrescimoC)
(setq jurosC (pJuros acrescimoC 15 100 50.0))
(print "Juros = " jurosC)