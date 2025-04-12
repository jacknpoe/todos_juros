' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 12/04/2025: versão feita sem muito conhecimento de Liberty BASIC

' as variáveis globais simplificam as chamadas às funções (arrays são sempre globais)
global true, false, Quantidade, Composto, Periodo
true = 1
false = 0
Quantidade = 3
Composto = true
Periodo = 30.0
dim Pagamentos(Quantidade)
dim Pesos(Quantidade)

' os arrays são iniciados dinamicamente
for indice = 1 to Quantidade
    Pagamentos(indice) = indice * Periodo
    Pesos(indice) = 1.0
next indice

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
print "Peso total = "; pesoTotal
print "Acréscimo = "; acrescimoCalculado
print "Juros = "; jurosCalculado

end

' calcula a somatória de Pesos()
function getPesoTotal()
    acumulador = 0.0
    for indice = 1 to Quantidade
        acumulador = acumulador + Pesos(indice)
    next indice
    getPesoTotal = acumulador
end function

' calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then
        jurosParaAcrescimo = 0.0
    else
        acumulador = 0.0
        for indice = 1 to Quantidade
            if Composto then
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
            else
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
            end if
        next indice

        if acumulador <= 0.0 then
            jurosParaAcrescimo = 0.0
        else
            jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
        end if
    end if
end function

' calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then
        acrescimoParaJuros = 3.0
    else
        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = 0.1 ^ precisao
        indice = 0
        while indice < maxIteracoes
            if maxJuros - minJuros < minDiferenca then
                indice = maxIteracoes
            end if
            if jurosParaAcrescimo(medJuros) < acrescimo then
                minJuros = medJuros
            else
                maxJuros = medJuros
            end if
            medJuros = (minJuros + maxJuros) / 2.0
            indice = indice + 1
        wend
        acrescimoParaJuros = medJuros
    end if
end function         
