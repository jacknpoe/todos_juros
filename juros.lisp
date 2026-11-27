;; Cálculo do juros, sendo que precisa de listas pra isso
;; Versão 0.1: 26/04/2024: variáveis
;;        0.2: 27/04/2024: implementação das funções
;;        0.3: 28/04/2024: valores envolvidos em cálculos mudados para double para maior precisão
;;        0.4: 10/07/2025: colocado um último terpri e alterados caracteres especiais
;;        0.5: 19/11/2026: comentários melhores; Composto = t; de nth para car e cdr; validações melhores; retirado uso de medJuros e pesoTotal globais dentro das funções
;;                         adicionado parâmetro medJuros ;; listas escaláveis criadas dinamicamente; variáveis resultado; melhorias no layout das impressões;
;;                         retirados return-from; let para variáveis locais; alteradas funções recursivas para permitir Tail Call Optimization (TCO); + declaim

(declaim (optimize (speed 3) (safety 0) (debug 0) (space 0) (compilation-speed 0)))

;; variáveis escalares globais para simplificar chamadas
(defvar Quantidade 3)
(defvar Composto t)
(defvar Periodo 30.0d0)

;; função açúcar que cria a lista Pagamentos
(defun criaPagamentos () (_criaPagamentos 1 nil))

;; função recursiva que cria a lista Pagamentos
(defun _criaPagamentos (indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPagamentos (+ indice 1) (cons (* indice Periodo) acumulador))
  )
)

;; função açúcar que cria a lista Pesos
(defun criaPesos () (_criaPesos 1 nil))

;; função recursiva que cria a lista Pesos
(defun _criaPesos (indice acumulador)
  (if (> indice Quantidade)
    acumulador
    (_criaPesos (+ indice 1) (cons 1.0d0 acumulador))
  )
)

;; listas globais para simplificar chamadas
(defvar Pagamentos (criaPagamentos))
(defvar Pesos (criaPesos))

;; função açúcar que calcula a somatória de Pesos
(defun getPesoTotal() (_getPesoTotal Pesos 0.0d0))

;; função recursiva que calcula a somatória de Pesos
(defun _getPesoTotal (ppesos acumulador)
  (if (null ppesos)
    acumulador
    (_getPesoTotal (cdr ppesos) (+ (car ppesos) acumulador))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (if (or (<= juros 0.0d0) (<= Quantidade 0) (<= Periodo 0.0d0))
    0.0d0
    (let ((lpesoTotal (getPesoTotal)))
      (if (<= lpesoTotal 0.0d0)
        0.0d0
        (let (( acumulador
          (if Composto
            (_jurosCompostos Pagamentos Pesos juros 0.0d0)
            (_jurosSimples Pagamentos Pesos juros 0.0d0)
          )
          ))
          (if (<= acumulador 0.0d0)
            0.0d0
            (* (- (/ lpesoTotal acumulador) 1.0d0) 100.0d0)
          )
        )
      )
    )
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
(defun _jurosCompostos (ppagamentos ppesos juros acumulador)
  (if (null ppesos)
    acumulador
    (_jurosCompostos (cdr ppagamentos) (cdr ppesos) juros (+ (* (car ppesos) (expt (+ 1.0d0 (/ juros 100.0d0)) (- (/ (car ppagamentos) Periodo)))) acumulador))
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
(defun _jurosSimples (ppagamentos ppesos juros acumulador)
  (if (null ppesos)
    acumulador
    (_jurosSimples (cdr ppagamentos) (cdr ppesos) juros (+ (/ (car ppesos) (+ 1.0d0 (* (/ juros 100.0d0) (/ (car ppagamentos) Periodo)))) acumulador))
  )
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (if (or (<= acrescimo 0.0d0) (<= Quantidade 0) (<= Periodo 0.0d0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0d0) (<= (getPesoTotal) 0.0d0))
    0.0d0
    (_acrescimoParaJuros acrescimo (expt 0.1d0 precisao) maxIteracoes 0.0d0 maxJuros (/ maxJuros 2.0d0))
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (= iteracaoAtual 0)  (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0d0))
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (/ (+ minJuros medJuros) 2.0d0))  
    )
  )
)

;; calcula e guarda os resultados das funções
(defvar pesoTotal (getPesoTotal))
(defvar acrescimoCalculado (jurosParaAcrescimo 3.0d0))
(defvar jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0d0))

;; imprime os resultados
(princ "Peso total = ") (write pesoTotal) (terpri)
(princ "Acrescimo = ") (write acrescimoCalculado) (terpri)
(princ "Juros = ") (write jurosCalculado) (terpri)
