; Calculo do juros, sendo que precisa de arrays pra isso
; Versao 0.1: 12/03/2025: versao sem muito conhecimento de ISLisp
; AVISO: algumas verificacoes foram retiradas, entao os calculos sao indefinidos para valores incorretos

; variaveis globais para simplificar as chamadas as funcoes
(defglobal Quantidade 3)
(defglobal Composto 1)
(defglobal Periodo 30.0)
(defglobal Pagamentos (list 30.0 60.0 90.0))
(defglobal Pesos (list 1.0 1.0 1.0))

; funcao recursiva no lugar de um for com acumulador que realmente calcula a somatoria de Pesos[]
(defun _getPesoTotal (pesos)
  (if (= (length(cdr pesos)) 0)
    (car pesos)
    (+ (car pesos) (_getPesoTotal(cdr pesos)))
  )
)

; calcula a somatoria de Pesos[]
(defun getPesoTotal ()
  (_getPesoTotal Pesos)
)

; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos (juros pagamentos pesos)
  (if (= (length(cdr pesos)) 0)
    (quotient (car pesos) (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) Periodo)))
    (+ (quotient (car pesos) (expt (+ 1.0 (quotient juros 100.0)) (quotient (car pagamentos) Periodo))) (_jurosCompostos juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples (juros pagamentos pesos)
  (if (= (length(cdr pesos)) 0)
    (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) Periodo))))
    (+ (quotient (car pesos) (+ 1.0 (* (quotient juros 100.0) (quotient (car pagamentos) Periodo)))) (_jurosSimples juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo (juros)
  (if (= Composto 1)
    (* (- (quotient (getPesoTotal) (_jurosCompostos juros Pagamentos Pesos)) 1.0) 100.0)
    (* (- (quotient (getPesoTotal) (_jurosSimples juros Pagamentos Pesos)) 1.0) 100.0)
  )
)

; funcao recursiva no lugar de um for que realmente calcula os juros
(defun _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (or (< (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    (quotient (+ minJuros maxJuros) 2.0)
    (if (< (jurosParaAcrescimo (quotient (+ minJuros maxJuros) 2.0)) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (quotient (+ minJuros maxJuros) 2.0) maxJuros)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (quotient (+ minJuros maxJuros) 2.0))
    )
  )
)

; calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(defun acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

; testes
(defglobal pesoTotal (getPesoTotal))
(format (standard-output) "Peso total = ~G~%" pesoTotal)
(defglobal acrescimoCalculado (jurosParaAcrescimo 3.0))
(format (standard-output) "Acrescimo = ~G~%" acrescimoCalculado)
(defglobal jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50.0))
(format (standard-output) "Juros = ~G~%" jurosCalculado)