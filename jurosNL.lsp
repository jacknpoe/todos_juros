;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 07/03/2025: versão feita sem saber newLISP

;; Variáveis
(define Quantidade 3)
(define Composto 1)
(define Periodo 30,0)
(define Pagamentos (list 30,0 60,0 90,0))
(define Pesos (list 1,0 1,0 1,0))

;; calcula a somatória de Pesos[]
(define (getPesoTotal)
  (_getPesoTotal(- Quantidade 1))
)

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(define (_getPesoTotal indice)
  (if (= indice 0)
    (nth 0 Pesos)
    (add (nth indice Pesos) (_getPesoTotal(- indice 1)))
  )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(define (jurosParaAcrescimo juros)
  (if (= Composto 1)
      (mul (sub (div (getPesoTotal) (_jurosCompostos(- Quantidade 1) juros)) 1,0) 100,0)
      (mul (sub (div (getPesoTotal) (_jurosSimples(- Quantidade 1) juros)) 1,0) 100,0)
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(define (_jurosCompostos indice juros)
  (if (= indice 0)
    (div (nth 0 Pesos) (pow (add 1,0 (div juros 100,0)) (div (nth 0 Pagamentos) Periodo)))
    (add (div (nth indice Pesos) (pow (add 1,0 (div juros 100,0)) (div (nth indice Pagamentos) Periodo))) (_jurosCompostos (- indice 1) juros))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(define (_jurosSimples indice juros)
  (if (= indice 0)
    (div (nth 0 Pesos) (add 1,0 (mul (div juros 100,0) (div (nth 0 Pagamentos) Periodo))))
    (add (div (nth indice Pesos) (add 1,0 (mul (div juros 100,0) (div (nth indice Pagamentos) Periodo)))) (_jurosSimples (- indice 1) juros))
  )
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(define (acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros acrescimo (pow 0,1 precisao) maxIteracoes 0 maxJuros)
)

;; função recursiva no lugar de um for que realmente calcula os juros
(define (_acrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (or (< (sub maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    (div (add minJuros maxJuros) 2,0)
    (if (< (jurosParaAcrescimo (div (add minJuros maxJuros) 2,0)) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (div (add minJuros maxJuros) 2,0) maxJuros)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (div (add minJuros maxJuros) 2,0))
    )
  )
)

;; testes
(define pesoTotal (getPesoTotal))
(println "Peso total = " pesoTotal)
(define acrescimoCalculado (jurosParaAcrescimo 3,0))
(println "Acrescimo = " acrescimoCalculado)
(define jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 100 50,0))
(println "Juros = " jurosCalculado)