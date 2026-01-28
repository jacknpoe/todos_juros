Red [Title: "Juros"]
; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 25/01/2025: versão feita sem muito conhecimento de Red (e corrigidos acessos aos arrays)

; variáveis globais para não sobrecarregar os parâmetros das funções
quantidade: 3
composto: true
periodo: 30.0
pagamentos: [30.0 60.0 90.0]
pesos: [1.0 1.0 1.0]

; calcula a somatória do array pesos
getPesoTotal: func [return: [float!]] [
    acumulador: 0.0
    indice: 1
    while [indice <= quantidade] [
        acumulador: acumulador + pesos/:indice
        indice: indice + 1
    ]
    acumulador
]

; calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo: func[juros [float!] return: [float!]] [
    pesoTotal: getPesoTotal

    either (juros <= 0.0) or (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) [
        0.0
    ] [
        acumulador: 0.0
        indice: 1

        while [indice <= quantidade] [
            either composto [
                acumulador: acumulador + ((pesos/:indice) / (power (1.0 + (juros / 100.0)) ((pagamentos/:indice) / periodo)))
            ] [
                acumulador: acumulador + ((pesos/:indice) / (1.0 + (juros / 100.0 * (pagamentos/:indice) / periodo)))
            ]
            indice: indice + 1
        ]

        either (acumulador <= 0.0) [
            0.0
        ] [
            (((pesoTotal / acumulador) - 1.0) * 100.0)
        ]
    ]
]

; calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros: func[acrescimo [float!] precisao [integer!] maxIteracoes [integer!] maxJuros [float!] return: [float!]] [
     pesoTotal: getPesoTotal

    either (acrescimo <= 0.0) or (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) or (precisao < 1) or (maxIteracoes < 1) or (maxJuros < 0.0) [
        0.0
    ] [
        minJuros: 0.0
        medJuros: maxJuros / 2.0
        minDiferenca: power 0.1 (to float! precisao)
        indice: 1

        while [indice <= maxIteracoes] [
            medJuros: (minJuros + maxJuros) / 2.0
            if ((maxJuros - minJuros) < minDiferenca) [
                break
            ]
            either ((jurosParaAcrescimo medJuros) < acrescimo) [
                minJuros: medJuros
            ] [
                maxJuros: medJuros
            ]
        ]
        medJuros
    ]
]

; calcula e guarda os retornos das funções
pesoTotal: getPesoTotal
acrescimoCalculado: jurosParaAcrescimo 3.0
jurosCalculado: acrescimoParaJuros acrescimoCalculado 15 100 50.0

print [ "Peso total =" pesoTotal ]
print [ "Acréscimo =" acrescimoCalculado ]
print [ "Juros =" jurosCalculado ]