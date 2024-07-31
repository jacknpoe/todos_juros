// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 31/07/2024: versão feita sem muito conhecimento de Io

// objeto com uma estrutura básica para simplificar as chamadas
Juros := Object clone
Juros quantidade := 3
Juros composto := true
Juros periodo := 30.0
Juros pagamentos := list(30.0, 60.0, 90.0)
Juros pesos := list(1.0, 1.0, 1.0)

// calcula a somatória da lista pesos()
Juros getPesoTotal := method(
    acumulador := 0.0
    for(indice, 0, quantidade - 1, acumulador := acumulador + pesos at(indice))
    return acumulador
)

// calcula o acréscimo a partir dos juros e parcelas
Juros jurosParaAcrescimo := method( juros,
    pesoTotal := getPesoTotal
    if(juros <= 0.0 or quantidade < 1 or periodo <= 0.0 or pesoTotal <= 0.0, return 0.0)
    acumulador := 0.0

    for(indice, 0, quantidade - 1,
        if(composto,
            acumulador := acumulador + pesos at(indice) / (1.0 + juros / 100.0) pow(pagamentos at(indice) / periodo),
            acumulador := acumulador + pesos at(indice) / (1.0 + juros / 100.0 * pagamentos at(indice) / periodo)
        )
    )

    return (pesoTotal / acumulador - 1.0) * 100.0
)

// calcula os juros a partir do acréscimo e parcelas
Juros acrescimoParaJuros := method( acrescimo, precisao, maxIteracoes, maxJuros,
    pesoTotal := getPesoTotal
    if(acrescimo <= 0.0 or quantidade < 1 or periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0, return 0.0)
    minJuros := 0.0
    medJuros := maxJuros / 2.0
    minDiferenca := 0.1 pow(precisao)

    for(indice, 1, maxIteracoes,
        medJuros := (minJuros + maxJuros) / 2.0
        if((maxJuros - minJuros) < minDiferenca, return medJuros)
        if(jurosParaAcrescimo(medJuros) < acrescimo, minJuros := medJuros, maxJuros := medJuros)
    )
    return medJuros
)

// calcula e guarda os retornos dos métodos
pesoTotal := Juros getPesoTotal
acrescimoCalculado := Juros jurosParaAcrescimo(3.0)
jurosCalculado := Juros acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
"Peso total = " print
pesoTotal println
"Acrescimo = " print
acrescimoCalculado println
"Juros = " print
jurosCalculado println