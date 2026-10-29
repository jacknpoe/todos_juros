; Cálculo dos juros, sendo que precisa de listas pra isso
; Versão 0.1: 05/03/2025: versão feita sem muito conhecimento de Otus Lisp
;        0.2: 07/03/2025: no primeiro if de _pJuros, agora é verificado se iteracaoAtual = 0
;        0.3: 29/10/2026: cálculos antes de impressão, acentos, melhorias nos comentários, números pomto flutuante agora inexatos
;                         quando (null? pesos) é verdadeiro, retorna zero em vez de caso especial com (= (length(cdr pesos)) 0),
;                         incluído parâmetro medJuros em _pJuros, pois estava calculando quatro vezes,
;                         listas escaláveis de tamanho Quantidade, validações de parâmetros, variáveis e cálculos inválidos,
;                         corrigido parêntese errado na chamada a _simples em dJuros,
;                         funções recursivas alteradas para permitir Tail Call Optimization (TCO); ficou em média 12% mais rápido

; variáveis globais escalares
(setq Quantidade 3)
(setq Composto 1)  ; 1 = true, 0 = false
(setq Periodo #i30.0)

; função recursiva que gera a lista de pagamentos
(define (_cPags indice acumulador)
  (if (< indice 0)
    acumulador
    (_cPags (- indice 1) (cons (* (- Quantidade indice) Periodo) acumulador))
  )
)

; função açúcar que gera a lista de pagamentos
(define (cPags)
  (_cPags (- Quantidade 1) '())
)

; função recursiva que gera a lista de pesos
(define (_cPesos indice acumulador)
  (if (< indice 0)
    acumulador
    (_cPesos (- indice 1) (cons #i1.0 acumulador))
  )
)

; função açúcar que gera a lista de pesos
(define (cPesos)
  (_cPesos (- Quantidade 1) '())
)

; listas globais
(setq Pagamentos (cPags))
(setq Pesos (cPesos))

; função recursiva que calcula a somatória de Pesos
(define (_gPeso pesos acumulador)
  (if (null? pesos)
    acumulador
    (_gPeso (cdr pesos) (+ (car pesos) acumulador))
  )
)

; função açúcar que calcula a somatória de Pesos
(define (gPeso)
  (_gPeso Pesos #i0.0)
)

; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_compostos juros pagamentos pesos acumulador)
  (if (null? pesos)
    acumulador
    (_compostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ #i1.0 (/ juros #i100.0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_simples juros pagamentos pesos acumulador)
  (if (null? pesos)
    acumulador
    (_simples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ #i1.0 (* (/ juros #i100.0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (dJuros juros)
  (let ((pesoTotal (gPeso)))
    (if (or (< Quantidade 1) (<= Periodo #i0.0) (<= pesoTotal #i0.0) (<= juros #i0.0))
      #i0.0
      (let
        ((acumulador
          (if (= Composto 1)
            (_compostos juros Pagamentos Pesos #i0.0)
            (_simples juros Pagamentos Pesos #i0.0)
          )
        ))
        (if (<= acumulador #i0.0)
          #i0.0
          (* (- (/ pesoTotal acumulador) #i1.0) #i100.0)
        )
      )
    )
  )
)

; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (_pJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (< (sub maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    medJuros
    (if (< (dJuros medJuros) acrescimo)
      (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) #i2.0))
      (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) #i2.0))
    )
  )
)

; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (pJuros acrescimo precisao maxIteracoes maxJuros)
  (let ((pesoTotal (gPeso)))
    (if (or (< Quantidade 1) (<= Periodo #i0.0) (<= pesoTotal #i0.0) (<= acrescimo #i0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros #i0.0))
      #i0.0
      (_pJuros acrescimo (expt #i0.1 precisao) maxIteracoes #i0.0 maxJuros (/ maxJuros #i2.0))
    )
  )
)

; calcula e guarda os resultados das funções
(setq pesoC (gPeso))
(setq acrescimoC (dJuros #i3.0))
(setq jurosC (pJuros acrescimoC 15 100 #i50.0))

; imprime os resultados
(print "Peso total = " pesoC)
(print "Acréscimo = " acrescimoC)
(print "Juros = " jurosC)
