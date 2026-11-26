;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 21/03/2025: criado a partir da versão em Common Lisp sem muito conhecimento de Emacs Lisp
;;        0.2: 16/04/2025: retirada variável medJuros
;;        0.3: 14/10/2026: alterado geradores de listas, uso de car e cdr
;;                         recursivas alteradas para permitir Tail Call Optimoization (TCO) embora ainda estoure a pilha e o desempenho não melhore muito
;;                         nos testes, o número máximo de parcelas calculadas com sucesso foram 333 (o mesmo que não TCO)
;;        0.5: 26/11/2026: Composto t; validações de variáveis, parâmetros e cálculos; pesoTotal e acumulador; + medJuros

;; inicializa as variáveis escalares globais
(defvar Quantidade 3)
(defvar Composto t)  ;; t = true; nil = false
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

;; função que calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos acumulador)
  (if (null pesos)
    acumulador
    (_jurosCompostos juros (cdr pagamentos) (cdr pesos) (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) acumulador))
  )
)

;; função que calcula a soma do amortecimento de todas as parcelas para juros simples
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

;; testes
(message "Peso total = %2.15f" pesoTotal)
(message "Acrécimo = %2.15f" acrescimoCalculado)
(message "Juros = %2.15f" jurosCalculado)
