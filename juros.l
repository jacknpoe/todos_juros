;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 23/07/2025: copiado de Common Lisp para EusLisp e alterado para definir as funções em ordem e a impressão dos resultados
;;        0.2: 14/10/2026: a partir de Emacs Lisp, alterada impressão, geradores de listas, uso de car e cdr
;;                         recursivas alteradas para permitir Tail Call Optimoization (TCO) embora ainda estoure a pilha e o desempenho não melhore muito
;;        0.3: 26/11/2026: Composto T; validados variáveis, parâmetros e cálculos; pesoTotal e acumulador; + medJuros; 12 dígitos em vez de 15

;; inicializa as variáveis escalares globais
(defvar Quantidade 3)
(defvar Composto T)  ;; T = true; NIL = false
(defvar Periodo 30.0)

;; função açúcar que gera a lista de pagamentos
(defun criaPagamentos ()
  (_criaPagamentos Quantidade '())
)

;; função recursiva que gera a lista de pagamentos
(defun _criaPagamentos (indice acumulador)
  (if (<= indice 0)
    acumulador
    (_criaPagamentos (- indice 1) (cons (* indice Periodo) acumulador))
  )
)

;; função açúcar que gera a lista de pesos
(defun criaPesos ()
  (_criaPesos Quantidade '())
)

;; função recursiva que gera a lista de pesos
(defun _criaPesos (indice acumulador)
  (if (<= indice 0)
    acumulador
    (_criaPesos (- indice 1) (cons 1.0 acumulador))
  )
)

;; inicializa as variáveis listas globais
(defvar Pagamentos (criaPagamentos))
(defvar Pesos (criaPesos))

;; função açúcar que calcula a somatória de Pesos
(defun getPesoTotal ()
  (_getPesoTotal Pesos 0.0)
)

;; função recursiva que calcula a somat?ria de Pesos
(defun _getPesoTotal (pesos acumulador)
  (if (null pesos)
    acumulador
    (_getPesoTotal (cdr pesos) (+ (car pesos) acumulador))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (let (( pesoTotal (getPesoTotal) ))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= juros 0.0) (<= pesoTotal 0.0))
      0.0
      (let (( acumulador
          (if Composto
            (_jurosCompostos juros Pagamentos Pesos 0.0)
            (_jurosSimples juros Pagamentos Pesos 0.0)
          )
        ))
        (if (<= acumulador 0.0)
          0.0
          (* (- (/ pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

;; função que calcula a soma da amortização de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos acumulador)
  (if (null pesos)
    acumulador
    (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

;; função que calcula a soma da amortização de todas as parcelas para juros simples
(defun _jurosSimples (juros pagamentos pesos acumulador)
  (if (null pesos)
    acumulador
    (_jurosSimples juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (if (or (< Quantidade 1) (<= Periodo 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;;função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (<= (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )
)

;; testes
(defvar pesoTotal (getPesoTotal))
(defvar acrescimoCalculado (jurosParaAcrescimo 3.0))
(defvar jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

(format t "Peso total = ~2,12F~%" pesoTotal)
(format t "Acréscimo = ~2,12F~%" acrescimoCalculado)
(format t "Juros = ~2,12F~%" jurosCalculado)
(exit)
