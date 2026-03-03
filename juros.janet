# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 03/03/2026: feita sem muito conhecimento de Janet

# variáveis escalares globais para simplificar as chamadas e inicialização
(var Quantidade 3)
(var Composto true)
(var Periodo 30.0)

# cria um array para definir Pagamentos[]
(defn cria-pagamentos []
    (var pagamentos @[])
    (for indice 1 (+ Quantidade 1) (array/push pagamentos (* indice Periodo)))
    pagamentos
)

# cria um array para definir Pesos[]
(defn cria-pesos []
    (var pesos @[])
    (for indice 0 Quantidade (array/push pesos 1.0))
    pesos
)

# arrays globais para simplificar as chamadas e inicialização
(var Pagamentos (cria-pagamentos))
(var Pesos (cria-pesos))

# calcula a somatória dos elementos de Pesos[]
(defn get-peso-total []
    (var acumulador 0.0)
    (for indice 0 Quantidade (set acumulador (+ acumulador (get Pesos indice))))
    acumulador
)

# calcula o acréscimo a partir dos juros e parcelas
(defn juros-para-acrescimo [juros]
    (def peso-total (get-peso-total))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= peso-total 0.0) (<= juros 0.0)) (return 0.0))
    (var acumulador 0.0)

    (for indice 0 Quantidade
       (if Composto
            (set acumulador (+ acumulador (/ (get Pesos indice) (math/pow (+ 1.0 (/ juros 100.0)) (/ (get Pagamentos indice) Periodo)))))
            (set acumulador (+ acumulador (/ (get Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (get Pagamentos indice) Periodo))))))
        )
    )

    (if (<= acumulador 0.0) (return 0.0))
    (* (- (/ peso-total acumulador) 1.0) 100.0)
)

# calcula os juros a partir do acréscimo e parcelas
(defn acrescimo-para-juros [acrescimo precisao max-iteracoes maximo-juros]
    (def peso-total (get-peso-total))
    (if (or (< Quantidade 1) (<= Periodo 0.0) (<= peso-total 0.0) (<= acrescimo 0.0) (< precisao 1) (< max-iteracoes 1) (<= maximo-juros 0.0)) (return 0.0))
    (var min-juros 0.0)
    (var med-juros (/ maximo-juros 2.0))
    (var max-juros maximo-juros)
    (def min-diferenca(math/pow 0.1 precisao ))

    (for iteracao 0 max-iteracoes
        (if (< (- max-juros min-juros) min-diferenca) (break))
        (if (< (juros-para-acrescimo med-juros) acrescimo)
            (set min-juros med-juros)
            (set max-juros med-juros)
        )
        (set med-juros (/ (+ min-juros max-juros) 2.0))
    )
    med-juros
)

# calcula e guarda os returnos das funções
(def peso-total (get-peso-total))
(def acrescimoCalculado (juros-para-acrescimo 3.0))
(def jurosCalculado (acrescimo-para-juros acrescimoCalculado 15 65 50.0))

# imprime os resultados
(print (string/format "Peso total = %.15f" peso-total))
(print (string/format "Acréscimo = %.15f" acrescimoCalculado))
(print (string/format "Juros = %.15f" jurosCalculado))
