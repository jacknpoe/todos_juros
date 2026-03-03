# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 03/03/2026: feita sem muito conhecimento de Janet

# variáveis escalares globais para simplificar as chamadas e inicialização
(var Quantidade 3)
(var Composto true)
(var Periodo 30.0)

# cria um array para definir Pagamentos[]
(defn criaPagamentos []
    (var pagamentos @[])
    (for indice 1 (+ Quantidade 1) (array/push pagamentos (* indice Periodo)))
    pagamentos
)

# cria um array para definir Pesos[]
(defn criaPesos []
    (var pesos @[])
    (for indice 0 Quantidade (array/push pesos 1.0))
    pesos
)

# arrays globais para simplificar as chamadas e inicialização
(var Pagamentos (criaPagamentos))
(var Pesos (criaPesos))

# calcula a somatória dos elementos de Pesos[]
(defn getPesoTotal []
    (var acumulador 0.0)
    (for indice 0 Quantidade (set acumulador (+ acumulador (get Pesos indice))))
    acumulador
)

# calcula o acréscimo a partir dos juros e parcelas
(defn jurosParaAcrescimo [juros]
    (def pesoTotal (getPesoTotal))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= juros 0.0)) (return 0.0))
    (var acumulador 0.0)

    (for indice 0 Quantidade
       (if Composto
            (set acumulador (+ acumulador (/ (get Pesos indice) (math/pow (+ 1.0 (/ juros 100.0)) (/ (get Pagamentos indice) Periodo)))))
            (set acumulador (+ acumulador (/ (get Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (get Pagamentos indice) Periodo))))))
        )
    )

    (if (<= acumulador 0.0) (return 0.0))
    (* (- (/ pesoTotal acumulador) 1.0) 100.0)
)

# calcula os juros a partir do acréscimo e parcelas
(defn acrescimoParaJuros (acrescimo precisao maxIteracoes maximoJuros)
    (def pesoTotal (getPesoTotal))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= pesoTotal 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maximoJuros 0.0)) (return 0.0))
    (var minJuros 0.0)
    (var medJuros (/ maximoJuros 2.0))
    (var maxJuros maximoJuros)
    (def minDiferenca(math/pow 0.1 precisao ))

    (for iteracao 0 maxIteracoes
        (if (< (- maxJuros minJuros) minDiferenca) (break))
        (if (< (jurosParaAcrescimo medJuros) acrescimo)
            (set minJuros medJuros)
            (set maxJuros medJuros)
        )
        (set medJuros (/ (+ minJuros maxJuros) 2.0))
    )
    medJuros
)

# calcula e guarda os returnos das funções
(def pesoTotal (getPesoTotal))
(def acrescimoCalculado (jurosParaAcrescimo 3.0))
(def jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

# imprime os resultados
(print (string/format "Peso total = %.15f" pesoTotal))
(print (string/format "Acréscimo = %.15f" acrescimoCalculado))
(print (string/format "Juros = %.15f" jurosCalculado))
