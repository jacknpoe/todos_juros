; Calculo do juros, sendo que precisa de arrays pra isso
; Versao 0.1: 13/02/2025: versao sem muito conhecimento de AutoLisp
;        0.2: 07/03/2025: na linha 48 verificado se iteracaoAtual = 0
; AVISO: algumas verificacoes foram retiradas, entao os calculos sao indefinidos para valores incorretos

; variaveis
(setq Quantidade 3 Composto 1 Periodo 30.0 Pagamentos (list 30.0 60.0 90.0) Pesos (list 1.0 1.0 1.0))

; funcao recursiva no lugar de um for com acumulador que realmente calcula a somatoria de Pesos[]
(defun _gPeso (valor)
  (if (= valor 0)
    (nth 0 Pesos)
    (+ (nth valor Pesos) (_gPeso(- valor 1)))
  )
)

; calcula a somatoria de Pesos[]
(defun gPeso ()
  (_gPeso (- Quantidade 1))
)

; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _compostos (valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (nth 0 Pagamentos) Periodo)))
    (+ (/ (nth valor Pesos) (expt (+ 1.0 (/ juros 100.0)) (/ (nth valor Pagamentos) Periodo))) (_compostos (- valor 1) juros))
  )
)

; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _simples (valor juros)
  (if (= valor 0)
    (/ (nth 0 Pesos) (+ 1.0 (* (/ juros 100.0) (/ (nth 0 Pagamentos) Periodo))))
    (+ (/ (nth valor Pesos) (+ 1.0 (* (/ juros 100.0) (/ (nth valor Pagamentos) Periodo)))) (_simples (- valor 1) juros))
  )
)

; calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
(defun dJuros (juros)
  (if (= Composto 1)
    (* (- (/ (gPeso) (_compostos (- Quantidade 1) juros)) 1.0) 100.0)
    (* (- (/ (gPeso) (_simples (- Quantidade 1) juros)) 1.0) 100.0)
  )
)

; funcao recursiva no lugar de um for que realmente calcula os juros
(defun _pJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (< (- maxJuros minJuros) minDiferenca)
    (/ (+ minJuros maxJuros) 2.0)
    (if (= iteracaoAtual 0)
      (/ (+ minJuros maxJuros) 2.0)
      (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
        (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros)
        (_pJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0))
      )
    )
  )
)

; calcula os juros a partir do acrescimo e dados comuns (como parcelas)
(defun pJuros (acrescimo precisao maxIteracoes maxJuros)
  (_pJuros acrescimo (expt 0.1 precisao) maxIteracoes 0.0 maxJuros)
)

; testes
(defun c:TestaJuros (/ pesoC acrescimoC jurosC)
  (setq pesoC (gPeso))
  (princ (strcat "\nPeso total = " (rtos pesoC 2 15)))
  (setq acrescimoC (dJuros 3.0))
  (princ (strcat ", Acrescimo = " (rtos acrescimoC 2 15)))
  (setq jurosC (pJuros acrescimoC 15 100 50.0))
  (princ (strcat ", Juros = " (rtos jurosC 2 15) "\n"))
  (princ)
)
