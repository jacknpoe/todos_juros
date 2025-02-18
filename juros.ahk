#Requires AutoHotkey v2.0

; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 18/02/2025: versão feita sem muito conhecimento de AutoHotKey

; variáveis globais para simplificar as chamadas
Quantidade := 3
Composto := true
Periodo := 30.0
Pagamentos := []
Pesos := []

; inicializa os arrays
loop Quantidade {
    Pagamentos.Push(30.0 * A_Index)
    Pesos.Push(1.0)
}

; calcula a somatória de Pesos[]
getPesoTotal() {
    global Quantidade, Pesos
    acumulador := 0.0
    loop Quantidade
        acumulador += Pesos[A_Index]
    return acumulador
}

; calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo(juros) {
    global Quantidade, Pesos, Periodo, Pagamentos, Pesos
    pesoTotal := getPesoTotal()
    if juros <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0
        return 0.0

    acumulador := 0.0
    loop Quantidade
        if Composto
            acumulador += Pesos[A_Index] / (1.0 + juros / 100.0) ** (Pagamentos[A_Index] / Periodo)
        else acumulador += Pesos[A_Index] / (1.0 + juros / 100.0 * Pagamentos[A_Index] / Periodo)

    if acumulador <= 0.0
        return 0.0
    return (pesoTotal / acumulador - 1.0) * 100.0
}

; calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros(acrescimo, precisao := 15, maxIteracoes := 100, maxJuros := 50.0) {
    global Quantidade, Periodo
    pesoTotal := getPesoTotal()
    if acrescimo <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0
        return 0.0

    minJuros := 0.0
    minDiferenca := 0.1 ** precisao
    loop maxIteracoes {
        medJuros := (minJuros + maxJuros) / 2.0
        if (maxJuros - minJuros) < minDiferenca
            return medJuros
        if jurosParaAcrescimo(medJuros) < acrescimo
            minJuros := medJuros
        else maxJuros := medJuros
    }

    return medJuros
}

; calcula e guarda os resultados das funções
pesoTotal := getPesoTotal()
acrescimoCalculado := jurosParaAcrescimo(3.0)
jurosCalculado := acrescimoParaJuros(acrescimoCalculado)

; mostra os resultados
MsgBox "Peso total = " . pesoTotal . ".`nAcréscimo = " . acrescimoCalculado . ".`nJuros = " . jurosCalculado . ".", "Juros", 64
