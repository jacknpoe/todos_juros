; Calculo do juros, sendo que precisa de arrays pra isso
; Versao 0.1: 30/03/2025: versao sem muito conhecimento de Arc
; AVISO: algumas verificacoes foram retiradas, entao os calculos sao indefinidos para valores incorretos

; variaveis globais para simplificar as chamadas as funcoes
(= Quantidade 3)
(= Composto 1)
(= Periodo 30.0)
(= Pagamentos (list 30.0 60.0 90.0))
(= Pesos (list 1.0 1.0 1.0))

; funcao recursiva no lugar de um for com acumulador que realmente calcula a somatoria de Pesos[]
(def _getPesoTotal (pesos)
  (if (no (cdr pesos))
    (car pesos)
    (+ (car pesos) (_getPesoTotal(cdr pesos)))
  )
)

; calcula a somatoria de Pesos[]
(def getPesoTotal ()
  (_getPesoTotal Pesos)
)

; calcula a soma do amortecimento de todas as parcelas para juros compostos
(def _jurosCompostos (juros pagamentos pesos)
  (if (no (cdr pesos))
    (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo)))
    (+ (/ (car pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (car pagamentos) Periodo))) (_jurosCompostos juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula a soma do amortecimento de todas as parcelas para juros simples
(def _jurosSimples (juros pagamentos pesos)
  (if (no (cdr pesos))
    (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo))))
    (+ (/ (car pesos) (+ 1.0 (* (/ juros 100.0) (/ (car pagamentos) Periodo)))) (_jurosSimples juros (cdr pagamentos) (cdr pesos)))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(def jurosParaAcrescimo (juros)
  (if (> Composto 0)
    (* (- (/ (getPesoTotal) (_jurosCompostos juros Pagamentos Pesos)) 1.0) 100.0)
    (* (- (/ (getPesoTotal) (_jurosSimples juros Pagamentos Pesos)) 1.0) 100.0)
  )
)

; funcao recursiva no lugar de um for que realmente calcula os juros
(def _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (< (- maxJuros minJuros) minDiferenca)
    (/ (+ minJuros maxJuros) 2.0)
    (if (> iteracaoAtual 0)
      (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
        (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros)
        (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0))
      )
      (/ (+ minJuros maxJuros) 2.0)
    )
  )
)

; calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(def acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

; testes
(def teste ()
  (= pesoTotal (getPesoTotal))
  (prn "Peso total = " pesoTotal)
  (= acrescimoCalculado (jurosParaAcrescimo 3.0))
  (prn "Acréscimo = " acrescimoCalculado)
  (= jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50.0))
  (prn "Juros = " jurosCalculado)
)
