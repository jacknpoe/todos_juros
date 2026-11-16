;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 16/05/2024: versão feita sem muito conhecimento de Clojure: completa
;;        0.2: 17/05/2024: versão com os ifs que retornam 0.0 na mesma linha (+ getPesoTotal)
;;        0.3: 17/05/2024: versão com vetores no lugar de listas
;;        0.4: 17/05/2024: dec no lugar de - 1
;;        0.5: 15/11/2024: melhorias nos comentários; trocados vetores por arrays escaláveis dimanicamente preenchidos; removidos casos especiais
;;                         validados variáveis, parâmetros e cálculos; variáveis antes de imprimir evitando recálculo;

;; namespace
(ns jacknpoe.juros (:gen-class))

;; variáveis globais
(def Quantidade 1000)
(def Composto true)
(def Periodo 30.0)
(def Pagamentos (double-array Quantidade))
(def Pesos (double-array Quantidade))

;; função recursiva que define os elementos do array Pagamentos[]
(defn rDefinePagamentos [indice]
  (if (< indice Quantidade)
    (do (rDefinePagamentos (inc indice))
        (aset-double Pagamentos indice (* Periodo (inc indice)))
    )
  )
)

;; função açúcar que define os elementos do array Pagamentos[]
(defn definePagamentos [] (rDefinePagamentos 0))

;; função recursiva que define os elementos do array Pesos[]
(defn rDefinePesos [indice]
  (if (< indice Quantidade)
    (do (rDefinePesos (inc indice))
        (aset-double Pesos indice 1.0)
    )
  )
)

;; função açúcar que define os elementos do array Pesos[]
(defn definePesos [] (rDefinePesos 0))

;; função recursiva que calcula a somatória dos elementos em Pesos[]
(defn rGetPesoTotal [indice]
  (if (>= indice Quantidade)
    0.0
    (+ (aget Pesos indice) (rGetPesoTotal (inc indice)))
  )
)

;; função açúcar que calcula a somatória dos elementos em Pesos[]
(defn getPesoTotal []
  (rGetPesoTotal 0)
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
(defn rJurosCompostos [indice juros]
  (if (< indice 0)
    0.0
    (+ (/ (aget Pesos indice) (Math/pow (+ 1.0 (/ juros 100.0)) (/ (aget Pagamentos indice) Periodo))) (rJurosCompostos (dec indice) juros))
  )
)

;; função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
(defn rJurosSimples [indice juros]
  (if (< indice 0)
    0.0
    (+ (/ (aget Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (aget Pagamentos indice) Periodo)))) (rJurosSimples (dec indice) juros))
  )
)

;; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defn jurosParaAcrescimo [juros]
  (let [pesoTotal (getPesoTotal)]
    (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0))
      0.0
      (let [acumulador
        (if Composto
          (rJurosCompostos (dec Quantidade) juros)
          (rJurosSimples (dec Quantidade) juros)
        )]
        (if (< acumulador 0.0)
          0.0
          (* (- (/ pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

;; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defn rAcrescimoParaJuros [acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros]
  (if (or (= iteracaoAtual 0) (<= (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (rAcrescimoParaJuros acrescimo minDiferenca (dec iteracaoAtual) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (rAcrescimoParaJuros acrescimo minDiferenca (dec iteracaoAtual) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )  
)

;; função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defn acrescimoParaJuros [acrescimo precisao maxIteracoes maxJuros]
  (if (or (<= acrescimo 0.0) (< Quantidade 1) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (rAcrescimoParaJuros acrescimo (Math/pow 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; define os elementos dos arrays Pagamentos[] e Pesos[]
(definePagamentos)
(definePesos)

;; calcula e guarda os retornos das funções
(def pesoTotal (getPesoTotal))
(def acrescimoCalculado (jurosParaAcrescimo 3.0))
(def jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

;; imprime os resultados
(print "Peso total = ")
(println pesoTotal)
(print "Acréscimo = ")
(println acrescimoCalculado)
(print "Juros = ")
(println jurosCalculado)
