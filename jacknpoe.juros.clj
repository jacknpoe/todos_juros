;; Cálculo do juros, sendo que precisa de arrays pra isso
;; ver também: http://quil.info/sketches/local/b713344d3290c888e5e3c39d5ab707db54d283938ecc971c5a1d9f32a1baffc0
;; Versão 0.1: 16/05/2024: versão feita sem muito conhecimento de Clojure: completa
;;        0.2: 17/05/2024: versão com os ifs que retornam 0.0 na mesma linha (+ getPesoTotal)
;;        0.3: 17/05/2024: versão com vetores no lugar de listas
;;        0.4: 17/05/2024: dec no lugar de - 1

;; namespace
(ns jacknpoe.juros (:gen-class))

;; variáveis globais
(def Quantidade 3)
(def Composto true)
(def Periodo 30.0)
(def Pagamentos [30.0 60.0 90.0])
(def Pesos [1.0 1.0 1.0])
;;(def Pagamentos '(30.0 60.0 90.0))  ;; se quiser listas, descomentar essas linhas comentadas para pagamentos e pesos
;;(def Pesos '(1.0 1.0 1.0))  ;; e comentar as duas acima com vetores

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(defn rGetPesoTotal [valor]
  (if (= valor 0)
    (nth Pesos 0) 
    (+ (nth Pesos valor) (rGetPesoTotal (dec valor)))
  )
)

;; calcula a somatória de todos os pesos
(defn getPesoTotal []
  (rGetPesoTotal(dec Quantidade))
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defn rJurosCompostos [valor juros]
  (if (= valor 0)
    (/ (nth Pesos 0) (Math/pow (+ 1.0 (/ juros 100.0)) (/ (nth Pagamentos 0) Periodo)))
    (+ (/ (nth Pesos valor) (Math/pow (+ 1.0 (/ juros 100.0)) (/ (nth Pagamentos valor) Periodo))) (rJurosCompostos (dec valor) juros))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(defn rJurosSimples [valor juros]
  (if (= valor 0)
    (/ (nth Pesos 0) (+ 1.0 (* (/ juros 100.0) (/ (nth Pagamentos 0) Periodo))))
    (+ (/ (nth Pesos valor) (+ 1.0 (* (/ juros 100.0) (/ (nth Pagamentos valor) Periodo)))) (rJurosSimples (dec valor) juros))
  )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defn jurosParaAcrescimo [juros]
  (if (or (<= juros 0.0) (< Quantidade 1) (<= Periodo 0.0) (<= (getPesoTotal) 0.0))
    0.0
    (if Composto
      (* (- (/ (getPesoTotal) (rJurosCompostos (dec Quantidade) juros)) 1.0) 100.0)
      (* (- (/ (getPesoTotal) (rJurosSimples (dec Quantidade) juros)) 1.0) 100.0)
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
(print "Peso total = ")
(println(getPesoTotal))
(print "Acréscimo = ")
(println(jurosParaAcrescimo 3.0))
(print "Juros = ")
(println (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 100 50.0))
