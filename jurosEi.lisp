;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 21/03/2025: criado a partir da versão em Common Lisp sem muito conhecimento de Emacs Lisp
;;        0.2: 16/04/2025: retirada variável medJuros
;;        0.3: 14/10/2026: alterado para usar iteração
;;        0.4: 15/10/2026: agora valida variáveis e acumulador

;; inicializa as variáveis escalares globais
(defvar Quantidade 3)
(defvar Composto 1)  ;; 1 = true; 0 = false
(defvar Periodo 30.0)

;; função que gera a lista de pagamentos
(defun criaPagamentos ()
  (let ((indice 1) (acumulador nil))
    (while (<= indice Quantidade)
      (setq acumulador (cons (* indice Periodo) acumulador))
      (setq indice (+ indice 1))
    )
    acumulador
  )
)

;; função que gera a lista de pesos
(defun criaPesos ()
  (let ((indice 1) (acumulador nil))
    (while (<= indice Quantidade)
      (setq acumulador (cons 1.0 acumulador))
      (setq indice (+ indice 1))
    )
    acumulador
  )
)

;; inicializa as variáveis listas globais
(defvar Pagamentos (criaPagamentos))
(defvar Pesos (criaPesos))

;; função que calcula a somatória de Pesos
(defun getPesoTotal ()
  (let ((pesos Pesos) (acumulador 0.0))
    (while pesos
      (setq acumulador (+ acumulador (car pesos)))
      (setq pesos (cdr pesos))
    )
    acumulador
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= juros 0.0))
      0.0
      (let ((pagamentos Pagamentos) (pesos Pesos) (acumulador 0.0))
        (while pagamentos
          (if (= Composto 1)
            (setq acumulador (+ acumulador (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo)))))
            (setq acumulador (+ acumulador (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo))))))
          )
          (setq pagamentos (cdr pagamentos))
          (setq pesos (cdr pesos))
        )
        (if (<= acumulador 0.0)
          0.0
          (* (- (/ pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

;; função que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (let ((pesoTotal (getPesoTotal)))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0.0))
      0.0
      (let ( (minJuros 0.0)
             (medJuros (/ maxJuros 2.0))
             (minDiferenca (expt 0.1 precisao))
             (indice 0) )
        (while (and (< indice maxIteracoes) (> (- maxJuros minJuros) minDiferenca))
          (if (< (jurosParaAcrescimo medJuros) acrescimo)
            (setq minJuros medJuros)
            (setq maxJuros medJuros)
          )
          (setq medJuros (/ (+ minJuros maxJuros) 2.0))
          (setq indice (+ indice 1))
        )
        medJuros
      )
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
