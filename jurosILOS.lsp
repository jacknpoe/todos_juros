;; Cálculo dos juros, sendo que precisa de parcelas pra isso
;; Versão 0.1: 26/04/2025: versão feita sem muito conhecimento de ILOS
;;        0.2: 26/04/2025: trocados temporariamente "setq" por "defglobal" porque dava erro unbound variable no interpretador

;; classe cJuros com propriedades para simplificar as chamadas aos metodos
(defclass <cJuros> ()
    (
        (composto   :accessor composto   :initform 0    :initarg composto)
        (periodo    :accessor periodo    :initform 30.0 :initarg periodo)
        (pagamentos :accessor pagamentos :initform '()  :initarg pagamentos)
        (pesos      :accessor pesos      :initform '()  :initarg pesos)
    )
)

; construtor
(defun cJuros (cmp per pag pes)
    (create (class <cJuros>) 'composto cmp 'periodo per 'pagamentos pag 'pesos pes)
)

; funcao recursiva no lugar de um for com acumulador que realmente calcula a somatoria de Pesos[]
(defun _getPesoTotal (pesos)
  (if (= (length(cdr pesos)) 0)
    (car pesos)
    (+ (car pesos) (_getPesoTotal(cdr pesos)))
  )
)

; calcula a somatoria de Pesos[]
(defun getPesoTotal (ojuros)
  (_getPesoTotal (slot-value ojuros 'pesos))
)

; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos periodo)
  (if (= (length(cdr pesos)) 0)
    (quotient (car pesos) (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) periodo)))
    (+ (quotient (car pesos) (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) periodo))) (_jurosCompostos juros (cdr pagamentos) (cdr pesos) periodo))
  )
)

; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples (juros pagamentos pesos periodo)
  (if (= (length(cdr pesos)) 0)
    (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) periodo))))
    (+ (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) periodo)))) (_jurosSimples juros (cdr pagamentos) (cdr pesos) periodo))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (ojuros juros)
  (if (= (slot-value ojuros 'composto) 1)
    (* (- (quotient (getPesoTotal ojuros) (_jurosCompostos juros (slot-value ojuros 'pagamentos) (slot-value ojuros 'pesos) (slot-value ojuros 'periodo))) 1.0) 100.0)
    (* (- (quotient (getPesoTotal ojuros) (_jurosSimples juros (slot-value ojuros 'pagamentos) (slot-value ojuros 'pesos) (slot-value ojuros 'periodo))) 1.0) 100.0)
  )
)

; funcao recursiva no lugar de um for que realmente calcula os juros
(defun _acrescimoParaJuros (ojuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (< (- maxJuros minJuros) minDiferenca)
    (quotient (+ minJuros maxJuros) 2.0)
    (if (= iteracaoAtual 0)
      (/ (+ minJuros maxJuros) 2.0)
      (if (< (jurosParaAcrescimo ojuros (quotient (+ minJuros maxJuros) 2.0)) acrescimo)
        (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) (quotient (+ minJuros maxJuros) 2.0) maxJuros)
        (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (quotient (+ minJuros maxJuros) 2.0))
      )
    )
  )
)

; calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (ojuros acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros ojuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

;; cria instância
(defglobal juros (cJuros 1 30.0 (list 30.0 60.0 90.0) (list 1.0 1.0 1.0)))

;; testes
(defglobal pesoTotal (getPesoTotal juros))
(format (standard-output) "Peso total = ~G~%" pesoTotal)
(defglobal acrescimoCalculado (jurosParaAcrescimo juros 3.0))
(format (standard-output) "Acréscimo = ~G~%" acrescimoCalculado)
(defglobal jurosCalculado (acrescimoParaJuros juros acrescimoCalculado 15 100 50.0))
(format (standard-output) "Juros = ~G~%" jurosCalculado)