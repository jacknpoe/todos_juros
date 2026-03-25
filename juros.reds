Red/System [Title: "Juros"]

; Cálculo do juros, sendo que precisa de arrays pra isso
; Versão 0.1: 25/03/2026: versao feita sem muito conhecimento de Red/System

; variáveis globais para não sobrecarregar os parâmetros das funções
quantidade: 300000
composto: true
periodo: as float! 30.0
pagamentos: declare float-ptr!
pesos: declare float-ptr!

; calcula a somatória dos elementos do array pesos
getPesoTotal: func[return: [float!]
    /local acumulador [float!] indice [integer!]
] [
    acumulador: 0.0
    indice: 1

    while [indice <= quantidade] [
        acumulador: acumulador + pesos/indice
        indice: indice + 1
    ]

    return acumulador
]

; calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo: func[juros [float!] return: [float!]
    /local pesoTotal acumulador [float!] indice [integer!]
] [
    pesoTotal: getPesoTotal
    if (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) or (juros <= 0.0) [return 0.0]
    acumulador: 0.0
    indice: 1

    while [indice <= quantidade] [
        either composto [acumulador: acumulador + ((pesos/indice) / (pow (1.0 + (juros / 100.0)) ((pagamentos/indice) / periodo)))]
                        [acumulador: acumulador + ((pesos/indice) / (1.0 + (juros / 100.0 * (pagamentos/indice) / periodo)))]
        indice: indice + 1
    ]

    if acumulador <= 0.0 [return 0.0]
    return (((pesoTotal / acumulador) - 1.0) * 100.0)
]

; calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros: func[acrescimo [float!] precisao [integer!] maxIteracoes [integer!] maxJuros [float!] return: [float!]
    /local pesoTotal minJuros medJuros minDiferenca [float!] indice [integer!]
] [
    pesoTotal: getPesoTotal
    if (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) or (acrescimo <= 0.0) or (precisao < 1) or (maxIteracoes < 1) or (maxJuros < 0.0) [return 0.0]
    minJuros: 0.0
    medJuros: maxJuros / 2.0
    minDiferenca: pow 0.1 (as float! precisao)
    indice: 1

    while [indice <= maxIteracoes] [
        if ((maxJuros - minJuros) < minDiferenca) [return medJuros]
        either ((jurosParaAcrescimo medJuros) < acrescimo) [minJuros: medJuros] [maxJuros: medJuros]
        medJuros: (minJuros + maxJuros) / 2.0
    ]
    return medJuros
]

; aloca o número de elementos quantidade nos arrays
pagamentos: as float-ptr! allocate quantidade * size? float!
pesos: as float-ptr! allocate quantidade * size? float!

; inicializa os elementos dos arrays
indice: 1

while [indice <= quantidade] [
    pagamentos/indice: (as float! indice) * periodo
    pesos/indice: 1.0
    indice: indice + 1
]

; calcula e guarda os resultados das funções
pesoTotal: as float! getPesoTotal
acrescimoCalculado: as float! jurosParaAcrescimo 3.0
jurosCalculado: as float! acrescimoParaJuros acrescimoCalculado 15 65 50.0

; imprime os resultados
print-line ["Peso total = " pesoTotal]
print-line ["Acréscimo = " acrescimoCalculado]
print-line ["Juros = " jurosCalculado]

; desaloca os arrays
free as byte-ptr! pagamentos
free as byte-ptr! pesos
