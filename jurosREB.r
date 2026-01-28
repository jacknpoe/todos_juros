REBOL [
  Title: "Juros Rebol"
  Date: 27-Jan-2026
  Version: 0.1.0
  Author: "Ricardo Erick Rebêlo"
  Purpose: "Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo"

  History: [
    0.1.0 "27-Jan-2026" "início da implementação, sem muito conhecimento de Rebol, até get-peso-total"
    0.1.1 "28-Jan-2026" "funções juros-para-acrescimo e acrescimo-para-juros"
  ]
]

; variáveis globais
quantidade: 3
composto: true
periodo: 30.0
pagamentos: []
pesos: []

; inicializa os arrays
repeat indice quantidade [
  append pagamentos indice * periodo
  append pesos 1.0
]

; calcula a somatória dos elementos do array pesos
get-peso-total: func [ /local acumulador indice ] [
  acumulador: 0.0
  repeat indice quantidade [
    acumulador: acumulador + pick pesos indice
  ]
  return acumulador
]

; calcula o acréscimo a partir dos juros e parcelas
juros-para-acrescimo: func [ juros /local peso-total acumulador indice ] [
  peso-total: get-peso-total[]
  if (quantidade < 1) or (periodo <= 0.0) or (peso-total <= 0.0) or (juros <= 0.0) [ return 0.0 ]
  acumulador: 0.0

  repeat indice quantidade [
    either composto [
      acumulador: acumulador + ((pick pesos indice) / (power (1.0 + (juros / 100.0)) ((pick pagamentos indice) / periodo)))
    ] [
      acumulador: acumulador + ((pick pesos indice) / (1.0 + (juros / 100.0 * (pick pagamentos indice) / periodo)))
    ]
  ]

  if (acumulador <= 0.0) [ return 0.0 ]
  return (peso-total / acumulador - 1.0) * 100.0
]

; calcula os juros a partir do acréscimo e parcelas
acrescimo-para-juros: func [ acrescimo precisao max-iteracoes max-juros /local min-juros med-juros min-diferenca indice ] [
  peso-total: get-peso-total[]
  if (quantidade < 1) or (periodo <= 0.0) or (peso-total <= 0.0) or (acrescimo <= 0.0) or (precisao < 1) or (max-iteracoes < 1) or (max-juros <= 0.0) [ return 0.0 ]
  min-juros: 0.0
  med-juros: max-juros / 2.0
  min-diferenca: power 0.1 precisao

  repeat indice max-iteracoes [
    if max-juros - min-juros < min-diferenca [ return med-juros ]
    either (juros-para-acrescimo med-juros) < acrescimo [
      min-juros: med-juros
    ] [
      max-juros: med-juros
    ]
    med-juros: (min-juros + max-juros) / 2.0
  ]
  return med-juros
]

; calcula e guarda o resultado das funções
peso-total: get-peso-total[]
acrescimo-calculado: juros-para-acrescimo 3.0
juros-calculado: acrescimo-para-juros acrescimo-calculado 15 65 50.0

; imprime os resultados
print ["Peso total =" peso-total]
print ["Acréscimo =" acrescimo-calculado]
print ["Juros =" juros-calculado]
