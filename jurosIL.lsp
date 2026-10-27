; Cálculo do juros, sendo que precisa de listas pra isso
; Versao 0.1: 12/03/2025: versão sem muito conhecimento de ISLISP
;        0.2: 11/07/2026: substituído / por quotient em (if (= iteracaoAtual 0) (quotient (+ minJuros maxJuros) 2.0); o motivo de o interpretador aceitar / não ficou claro
;        0.3: 27/10/2026: listas escaladas com geradoras, proteção de expt infinito e medJuros em _acrescimoParaJuros
;                         funções recursivas agora permitem Tail Call Optimization (TCO), mas o ganho é marginal, ainda não alcança 40.000 parcelas

; COMO RODAR E MEDIR:
; eisl -c
; (compile-file "jurosIL.lsp")
; (load "jurosIL.o")

; criado um valor máximo para evitar o erro Floating number underflow at QUOTIENT (1.0 4.8898e+307)
(defglobal MaxValue 1.0e+100)

; variáveis globais para simplificar as chamadas às funções
(defglobal Quantidade 3)
(defglobal Composto 1)  ; 1 = true; 0 = false
(defglobal Periodo 30.0)

; função recursiva que gera a lista de pagamentos
(defun _criaPagamentos (indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPagamentos (- indice 1) (cons (* (- Quantidade indice) Periodo) acumulador))
  )
)

; função açúcar que gera a lista de pagamentos
(defun criaPagamentos ()
  (_criaPagamentos (- Quantidade 1) nil)
)

; função recursiva que gera a lista de pesos
(defun _criaPesos (indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPesos (- indice 1) (cons 1.0 acumulador))
  )
)

; função açúcar que gera a lista de pesos
(defun criaPesos ()
  (_criaPesos (- Quantidade 1) nil)
)

(defglobal Pagamentos (criaPagamentos))
(defglobal Pesos (criaPesos))

; função recursiva que calcula a somatória de Pesos
(defun _getPesoTotal (pesos acumulador)
  (if (null pesos)
    acumulador
    (_getPesoTotal(cdr pesos)(+ (car pesos) acumulador))
  )
)

; função açúcar que calcula a somatória de Pesos
(defun getPesoTotal ()
  (_getPesoTotal Pesos 0.0)
)

; função que calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos acumulador)
  (if (null pesos)
    acumulador
    (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (quotient (car pesos) (min (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) Periodo)) MaxValue)) acumulador))
  )
)

; função que calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples (juros pagamentos pesos acumulador)
  (if (null pesos)
    acumulador
    (_jurosSimples juros (cdr pagamentos) (cdr pesos) (+ (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) Periodo)))) acumulador))
  )
)

; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= juros 0.0))
      0.0
      (let ((acumulador
        (if (= Composto 1)
          (_jurosCompostos juros Pagamentos Pesos 0.0)
          (_jurosSimples juros Pagamentos Pesos 0.0)
        )
        ))
        (if (<= acumulador 0.0)
          0.0
          (* (- (quotient pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (< (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (quotient (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (quotient (+ minJuros medJuros) 2.0))
    )
  )
)

; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0.0))
      0.0
      (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (quotient maxJuros 2.0))
    )
  )
)

; testes
(defglobal pesoTotal (getPesoTotal))
(format (standard-output) "Peso total = ~G~%" pesoTotal)
(defglobal acrescimoCalculado (jurosParaAcrescimo 3.0))
(format (standard-output) "Acrescimo = ~G~%" acrescimoCalculado)
(defglobal jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50.0))
(format (standard-output) "Juros = ~G~%" jurosCalculado)
