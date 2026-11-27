; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 26/04/2025: versão feita sem muito conhecimento de ILOS
;        0.2: 26/04/2025: trocados temporariamente "setq" por "defglobal" porque dava erro unbound variable no interpretador
;        0.3: 27/04/2025: trocados defun por defgeneric + defmethod
;        0.4: 11/07/2026: corrigida / por quotient em (if (= iteracaoAtual 0) (quotient (+ minJuros maxJuros) 2.0)
;        0.5: 19/10/2026: escalável, recursões agora permitiriam Tail Call Optimization (TCO), mas ainda existem limites entre 3.000 e 7.000 parcelas
;        0.6: 27/11/2026: Composto t; validações de atributos, parâmetros e cálculos; + medJuros

; COMO RODAR E MEDIR:
; eisl -c
; (compile-file "jurosILOS.lsp")
; (load "jurosILOS.o")
; (time (main))

;; função açúcar que gera a lista de pagamentos
(defun criaPagamentos (quantidade periodo)
  (_criaPagamentos quantidade (- quantidade 1) periodo nil)
)

;; função recursiva que gera a lista de pagamentos
(defun _criaPagamentos (quantidade indice periodo acumulador)
  (if (< indice 0)
    acumulador
    (_criaPagamentos quantidade (- indice 1) periodo (cons (* (+ indice 1) periodo) acumulador))
  )
)

;; função açúcar que gera a lista de pesos
(defun criaPesos (quantidade)
  (_criaPesos (- quantidade 1) nil)
)

;; função recursiva que gera a lista de pesos
(defun _criaPesos (indice acumulador)
  (if (< indice 0)
    acumulador
    (_criaPesos (- indice 1) (cons 1.0 acumulador))
  )
)

; classe cJuros com propriedades para simplificar as chamadas aos métodos
(defclass <cJuros> ()
    (
        (quantidade :accessor quantidade :initform 1    :initarg quantidade)
        (composto   :accessor composto   :initform nil  :initarg composto)
        (periodo    :accessor periodo    :initform 30.0 :initarg periodo)
        (pagamentos :accessor pagamentos :initform '()  :initarg pagamentos)
        (pesos      :accessor pesos      :initform '()  :initarg pesos)
    )
)

; construtor
(defgeneric cJuros (qtd cmp per pag pes))
(defmethod cJuros (qtd cmp per pag pes)
  (create (class <cJuros>) 'quantidade qtd 'composto cmp 'periodo per 'pagamentos pag 'pesos pes)
)

; função recursiva que calcula a somatoria de pesos
(defun _getPesoTotal (pesos acumulador)
  (if (null pesos)
    acumulador
    (_getPesoTotal(cdr pesos) (+ (car pesos) acumulador))
  )
)

; função açúcar que calcula a somatoria de pesos
(defgeneric getPesoTotal (ojuros))
(defmethod getPesoTotal (ojuros)
  (_getPesoTotal (slot-value ojuros 'pesos) 0.0)
)

; função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos periodo acumulador)
  (if (null pesos)
    acumulador
   (_jurosCompostos juros (cdr pagamentos) (cdr pesos) periodo (+ (quotient (car pesos) (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) periodo))) acumulador))
  )
)

; função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
(defun _jurosSimples (juros pagamentos pesos periodo acumulador)
  (if (null pesos)
    acumulador
    (_jurosSimples juros (cdr pagamentos) (cdr pesos) periodo (+ (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) periodo)))) acumulador))
  )
)

; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defgeneric jurosParaAcrescimo (ojuros juros))
(defmethod jurosParaAcrescimo (ojuros juros)
  (let (( pesoTotal (getPesoTotal ojuros) ))
    (if (or (< (slot-value ojuros 'quantidade) 1) (<= (slot-value ojuros 'periodo) 0.0) (<= juros 0.0) (<= pesoTotal 0.0))
      0.0
      (let (( acumulador
          (if (slot-value ojuros 'composto)
            (_jurosCompostos juros (slot-value ojuros 'pagamentos) (slot-value ojuros 'pesos) (slot-value ojuros 'periodo) 0.0)
            (_jurosSimples juros (slot-value ojuros 'pagamentos) (slot-value ojuros 'pesos) (slot-value ojuros 'periodo) 0.0)
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

; função recursiva que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(defgeneric _acrescimoParaJuros (ojuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros))
(defmethod _acrescimoParaJuros (ojuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros)
  (if (or (<= (- maxJuros minJuros) minDiferenca) (<= iteracaoAtual 0))
    medJuros
    (if (< (jurosParaAcrescimo ojuros medJuros) acrescimo)
      (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) medJuros maxJuros (quotient (+ medJuros maxJuros) 2.0))
      (_acrescimoParaJuros ojuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros medJuros (quotient (+ minJuros medJuros) 2.0))
    )
  )
)

; função açúcar que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(defgeneric acrescimoParaJuros (ojuros acrescimo precisao maxIteracoes maxJuros))
(defmethod acrescimoParaJuros (ojuros acrescimo precisao maxIteracoes maxJuros)
  (if (or (< (slot-value ojuros 'quantidade) 1) (<= (slot-value ojuros 'periodo) 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maxJuros 0.0) (<= (getPesoTotal ojuros) 0.0))
    0.0
    (_acrescimoParaJuros ojuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros (quotient maxJuros 2.0))
  )
)

; corpo do programa, chamar com (time (main)) para medir o tempo
(defun main ()
  ;; parâmetros do objeto, objeto e resultados das funções
  (let* ((Quantidade 3)
         (Composto t)  ; t = true, nil = false
         (Periodo 30.0)
         (Pagamentos (criaPagamentos Quantidade Periodo))
         (Pesos (criaPesos Quantidade))
         (juros (cJuros Quantidade Composto Periodo Pagamentos Pesos))
         (pesoTotal nil)
         (acrescimoCalculado nil)
         (jurosCalculado nil))

    ;; calcula e guarda os resultados das funções
    (setq pesoTotal (getPesoTotal juros))
    (setq acrescimoCalculado (jurosParaAcrescimo juros 3.0))
    (setq jurosCalculado (acrescimoParaJuros juros acrescimoCalculado 15 65 50.0))
  
    (format (standard-output) "Peso total = ~G~%" pesoTotal)
    (format (standard-output) "Acrescimo = ~G~%" acrescimoCalculado)
    (format (standard-output) "Juros = ~G~%" jurosCalculado)
  )
)
