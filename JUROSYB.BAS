' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 30/01/2025: versão feita sem muito conhecimento de Yabasic

' calcula a somatória do array Pesos()
sub getPesoTotal()
    local acumulador, indice
    acumulador = 0.0
    for indice = 1 to Quantidade
        acumulador = acumulador + Pesos(indice)
    next indice
    return acumulador
end sub

' calcula o acréscimo a partir dos juros e parcelas
sub jurosParaAcrescimo(juros)
    local pesoTotal, acumulador, indice
    pesoTotal = getPesoTotal()
    if (juros <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0) then
        return 0.0
    endif

    acumulador = 0.0
    for indice = 1 to Quantidade
        if (Composto) then
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
        else
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
        endif
    next indice

    if (acumulador <= 0.0) then
        return 0.0
    endif
    return (pesoTotal / acumulador - 1.0) * 100.0
end sub

' calcula os juros a partir do acréscimo e parcelas
sub acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    local pesoTotal, minJuros, medJuros, minDiferenca, indice
    pesoTotal = getPesoTotal()
    if (acrescimo <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0) then
        return 0.0
    endif

    minJuros = 0.0
    minDiferenca = 0.1 ^ precisao
    for indice = 1 to maxIteracoes
        medJuros = (minJuros + maxJuros) / 2.0
        if ((maxJuros - minJuros) < minDiferenca) then
            return medJuros
        endif
        if (jurosParaAcrescimo(medJuros) < acrescimo) then
            minJuros = medJuros
        else
            maxJuros = medJuros
        endif
    next indice

    return medJuros
end sub

' cria e inicia variáveis locais
Quantidade = 3
Composto = true
Periodo = 30.0
Dim Pagamentos(Quantidade)
Dim Pesos(Quantidade)

for indice = 1 to Quantidade
    Pagamentos(indice) = 30.0 * indice
    Pesos(indice) = 1.0
next indice

' calcula e guarda os resultados das subrotinas
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
print "Peso total = ", pesoTotal using "#.###############"
print "Acrescimo = ", acrescimoCalculado using "#.###############"
print "Juros = ", jurosCalculado using "#.###############"