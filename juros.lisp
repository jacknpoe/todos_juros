;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 26/04/2024: variáveis
;;        0.2: 27/04/2024: implementação das funções
;;        0.3: 28/04/2024: valores envolvidos em cálculos mudados para double para maior precisão
;;        0.4: 10/07/2025: colocado um último terpri e alterados caracteres especiais

;; Variáveis
(defvar Quantidade 3)
(defvar Composto 1)
(defvar Periodo 30.0d0)
(defvar Pagamentos '(30.0d0 60.0d0 90.0d0))
(defvar Pesos '(1.0d0 1.0d0 1.0d0))
(defvar pesoTotal 0.0d0)
(defvar medJuros 0.0d0)

;; calcula a somatória de Pesos[]
(defun getPesoTotal()
  (_getPesoTotal(- Quantidade 1))
)

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(defun _getPesoTotal(valor)
  (if (= valor 0)
    (nth 0 Pesos)
    (+ (nth valor Pesos) (_getPesoTotal(- valor 1)))
  )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo(juros)
  (if (or (or (<= juros 0.0) (<= Quantidade 0)) (<= Periodo 0.0)) (return-from jurosParaAcrescimo 0.0))
  (setq pesoTotal (getPesoTotal))
  (if (<= pesoTotal 0.0) (return-from jurosParaAcrescimo 0.0))
  (if (= Composto 1)
      (* (- (/ pesoTotal (_jurosCompostos(- Quantidade 1) juros)) 1.0d0) 100.0d0)
      (* (- (/ pesoTotal (_jurosSimples(- Quantidade 1) juros)) 1.0d0) 100.0d0)
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos(valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (nth 0 Pagamentos) Periodo)))
    (+ (/ (nth valor Pesos) (expt (+ 1.0d0 (/ juros 100.0d0)) (/ (nth valor Pagamentos) Periodo))) (_jurosCompostos (- valor 1) juros))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples(valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (+ 1.0d0 (* (/ juros 100.0d0) (/ (nth 0 Pagamentos) Periodo))))
    (+ (/ (nth valor Pesos) (+ 1.0d0 (* (/ juros 100.0d0) (/ (nth valor Pagamentos) Periodo)))) (_jurosSimples (- valor 1) juros))
  )
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros(acrescimo precisao maxIteracoes maxJuros)
  (if (or (or (or (or (or (<= acrescimo 0.0) (<= Quantidade 0)) (<= Periodo 0.0)) (< maxIteracoes 1)) (< precisao 1)) (<= maxJuros 0.0)) (return-from acrescimoParaJuros 0.0))
  (setq pesoTotal (getPesoTotal))
  (if (<= pesoTotal 0.0) (return-from acrescimoParaJuros 0.0))
  (_acrescimoParaJuros acrescimo (expt 0.1d0 precisao) maxIteracoes 0.0d0 maxJuros)
)

;; função recursiva no lugar de um for que realmente calcula os juros
(defun _acrescimoParaJuros(acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (setq medJuros (/ (+ minJuros maxJuros) 2.0d0))
  (if (= iteracaoAtual 0) (return-from _acrescimoParaJuros medJuros ))
  (if (< (- maxJuros minJuros) minDiferenca) (return-from _acrescimoParaJuros medJuros))
  (if (< (jurosParaAcrescimo medJuros) acrescimo)
    (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros)
    (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros)  
  )
)

;; testes
(princ "Peso total = ")
(write (getPesoTotal))
(terpri)
(princ "Acrescimo = ")
(write (jurosParaAcrescimo 3.0d0))
(terpri)
(princ "Juros = ")
(write (acrescimoParaJuros (jurosParaAcrescimo 3.0d0) 15 100 50.0d0))
(terpri)
