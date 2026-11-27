;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 20/11/2026: a partir de Common Lisp, com expand, números sem d0, com princ, etc...

(expand 5)  ;; multiplicar pelo mesmo número ao aumentar `Quantidade`

;; variáveis escalares globais para simplificar chamadas
(defvar Quantidade 3)
(defvar Composto t)
(defvar Periodo 30.0)

;; função recursiva que cria a lista Pagamentos
(defun _criaPagamentos (indice)
  (if (> indice Quantidade)
    nil
    (cons (* indice Periodo) (_criaPagamentos (+ indice 1)))
  )
)

;; função açúcar que cria a lista Pagamentos
(defun criaPagamentos() (_criaPagamentos 1))

;; função recursiva que cria a lista Pesos
(defun _criaPesos (indice)
  (if (> indice Quantidade)
    nil
    (cons 1.0 (_criaPesos (+ indice 1)))
  )
)

;; função açúcar que cria a lista Pesos
(defun criaPesos() (_criaPesos 1))

;; listas globais para simplificar chamadas
(defvar Pagamentos (criaPagamentos))
(defvar Pesos (criaPesos))

;; função recursiva que calcula a somatória de Pesos
(defun _getPesoTotal (ppesos)
  (if (null ppesos)
    0.0
    (+ (car ppesos) (_getPesoTotal (cdr ppesos)))
  )
)

;; função açúcar que calcula a somatória de Pesos
(defun getPesoTotal() (_getPesoTotal Pesos))

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
(defun _jurosCompostos (ppagamentos ppesos juros)
  (if (null ppesos)
    0.0
    (+ (* (car ppesos) (expt (+ 1.0 (/ juros 100.0)) (- (/ (car ppagamentos) Periodo))))
       (_jurosCompostos (cdr ppagamentos) (cdr ppesos) juros))
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
(defun _jurosSimples (ppagamentos ppesos juros)
  (if (null ppesos)
    0.0
    (+ (/ (car ppesos) (+ 1.0 (* (/ juros 100.0) (/ (car ppagamentos) Periodo))))
       (_jurosSimples (cdr ppagamentos) (cdr ppesos) juros))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (if (or (<= juros 0.0) (<= Quantidade 0) (<= Periodo 0.0))
    0.0
    (let ((lpesoTotal (getPesoTotal)))
      (if (<= lpesoTotal 0.0)
        0.0
        (let ((lvalorTotal
          (if Composto
            (_jurosCompostos Pagamentos Pesos juros)
            (_jurosSimples Pagamentos Pesos juros)
          )
          ))
          (if (<= lvalorTotal 0.0)
            0.0
            (* (- (/ lpesoTotal lvalorTotal) 1.0) 100.0)
          )
        )
      )
    )
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0)  (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0))  
    )
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0) (<= Quantidade 0) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
     (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; calcula e guarda os resultados das funções
(defvar pesoTotal (getPesoTotal))
(defvar acrescimoCalculado (jurosParaAcrescimo 3.0))
(defvar jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

;; imprime os resultados
(setq *float-format* "%.15f")
(princ "Peso total = ") (princ pesoTotal) (terpri)
(princ "Acrescimo = ") (princ acrescimoCalculado) (terpri)
(princ "Juros = ") (princ jurosCalculado) (terpri)
