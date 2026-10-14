;; C�lculo do juros, sendo que precisa de arrays pra isso
;; Vers�o 0.1: 21/03/2025: criado a partir da vers�o em Common Lisp sem muito conhecimento de Emacs Lisp
;;         0.2: 16/04/2025: retirada variável medJuros

;; Vari�veis
(defvar Quantidade 3)
(defvar Composto 1)
(defvar Periodo 30.0)
(defvar Pagamentos '(30.0 60.0 90.0))
(defvar Pesos '(1.0 1.0 1.0))
(defvar pesoTotal 0.0)

;; calcula a somat�ria de Pesos[]
(defun getPesoTotal()
  (_getPesoTotal(- Quantidade 1))
)

;; fun��o recursiva no lugar de um for com acumulador que realmente calcula a somat�ria de Pesos[]
(defun _getPesoTotal(valor)
  (if (= valor 0)
    (nth 0 Pesos)
    (+ (nth valor Pesos) (_getPesoTotal(- valor 1)))
  )
)

;; calcula o acr�scimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo(juros)
  (setq pesoTotal (getPesoTotal))
  (if (= Composto 1)
      (* (- (/ pesoTotal (_jurosCompostos(- Quantidade 1) juros)) 1.0) 100.0)
      (* (- (/ pesoTotal (_jurosSimples(- Quantidade 1) juros)) 1.0) 100.0)
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos(valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (nth 0 Pagamentos) Periodo)))
    (+ (/ (nth valor Pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (nth valor Pagamentos) Periodo))) (_jurosCompostos (- valor 1) juros))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples(valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (+ 1.0 (* (/ juros 100.0) (/ (nth 0 Pagamentos) Periodo))))
    (+ (/ (nth valor Pesos) (+ 1.0 (* (/ juros 100.0) (/ (nth valor Pagamentos) Periodo)))) (_jurosSimples (- valor 1) juros))
  )
)

;; calcula os juros a partir do acr�scimo e dados comuns (como parcelas)
(defun acrescimoParaJuros(acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

;; fun��o recursiva no lugar de um for que realmente calcula os juros
(defun _acrescimoParaJuros(acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (or (< (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    (/ (+ minJuros maxJuros) 2.0)
    (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0))
    )
  )
)

;; testes
(message "Peso total = %2.15f" (getPesoTotal))
(message "Acrescimo = %2.15f" (jurosParaAcrescimo 3.0))
(message "Juros = %2.15f" (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 100 50.0)
)
