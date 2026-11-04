;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 30/01/2025: versão feita a partir de Clojure, alterados os prints
;;        0.2: 03/11/2026: melhorias nos comentários, listas agora dinâmicas e escaladas, variáveis em jurosParaAcrescimo
;;                         rGetPesoTotal, rJurosCompostos e rJurosSimples (somatórias) convertidos para usar reduces e maps

;; namespace
(ns jacknpoe.juros (:gen-class))

;; variáveis escalares globais
(def Quantidade 3)
(def Composto true)
(def Periodo 30.0)

;; função recursiva que gera a lista Pagamentos
(defn rCriaPagamentos [indice acumulador]
  (if (> indice Quantidade)
    acumulador
    (rCriaPagamentos (inc indice) (cons (* indice Periodo) acumulador))
  )
)

;; função recursiva que gera a lista Pesos
(defn criaPagamentos []
  (rCriaPagamentos 1 ())
)

;; função recursiva que gera a lista Pesos
(defn rCriaPesos [indice acumulador]
  (if (> indice Quantidade)
    acumulador
    (rCriaPesos (inc indice) (cons 1.0 acumulador))
  )
)

;; função recursiva que gera a lista Pesos
(defn criaPesos []
  (rCriaPesos 1 ())
)

;; listas globais
(def Pagamentos (criaPagamentos))
(def Pesos (criaPesos))

;; função que calcula a somatória de todos os pesos
(defn getPesoTotal []
  (reduce + 0.0 Pesos)
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defn jurosParaAcrescimo [juros]
  (let [pesoTotal (getPesoTotal)]
    (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0))
      0.0
      (let [acumulador
          (if Composto
            (reduce + 0.0 (map (fn [peso pagamento] (/ peso (Math/pow (+ 1.0 (/ juros 100.0)) (/ pagamento Periodo)))) Pesos Pagamentos))
            (reduce + 0.0 (map (fn [peso pagamento] (/ peso (+ 1.0 (* (/ juros 100.0) (/ pagamento Periodo))))) Pesos Pagamentos))
          )
        ]
        (if (<= acumulador 0.0)
          0.0
          (* (- (/ pesoTotal acumulador) 1.0) 100.0)
        )
      )
    )
  )
)

;; função recursiva no lugar de um for que realmente calcula os juros
(defn rAcrescimoParaJuros [acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros]
  (if (or (= iteracaoAtual 0) (< (- maxJuros minJuros) minDiferenca))
    medJuros
    (if (< (jurosParaAcrescimo medJuros) acrescimo)
      (rAcrescimoParaJuros acrescimo minDiferenca (dec iteracaoAtual) medJuros maxJuros (/ (+ medJuros maxJuros) 2.0))
      (rAcrescimoParaJuros acrescimo minDiferenca (dec iteracaoAtual) minJuros medJuros (/ (+ minJuros medJuros) 2.0))
    )
  )  
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defn acrescimoParaJuros [acrescimo precisao maxIteracoes maxJuros]
  (if (or (<= acrescimo 0.0) (< Quantidade 1) (<= Periodo 0.0) (< maxIteracoes 1) (< precisao 1) (<= maxJuros 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (rAcrescimoParaJuros acrescimo (Math/pow 0.1 precisao) maxIteracoes 0.0 maxJuros (/ maxJuros 2.0))
  )
)

;; testa os valores de retorno das funções
(println (str "Peso total = " (getPesoTotal)))
(println (str "Acréscimo = " (jurosParaAcrescimo 3.0)))
(println (str "Juros = " (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 65 50.0)))
