' Cálculo do juros, sendo que precisa de arrays pra isso
' Versão 0.1: 02/04/2026: versao feita sem muito conhecimento de bas

' variáveis globais para simplificar as chamadas às funções
Quantidade% = 3
Composto = 1  ' 0 = false
Periodo = 30.0
dim Pagamentos(Quantidade% - 1)
dim Pesos(Quantidade% - 1)

' calcula a somatória dos elementos em Pesos()
function getPesoTotal
    acumulador = 0.0
    for indice% = 0 to Quantidade% - 1
        acumulador = acumulador + Pesos(indice%)
    next
    getPesoTotal = acumulador
end function

' calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal()
    if Quantidade% < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then jurosParaAcrescimo = 0.0 : exit function
    acumulador = 0.0

    for indice% = 0 to Quantidade% - 1
        if Composto then
            acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0) ^ (Pagamentos(indice%) / Periodo)
        else
            acumulador = acumulador + Pesos(indice%) / (1.0 + juros / 100.0 * Pagamentos(indice%) / Periodo)
        end if
    next

    if acumulador <= 0.0 then jurosParaAcrescimo = 0.0 : exit function
    jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
end function

' calcula os juros a partir do acréscimo e prcelas
function acrescimoParaJuros(acrescimo, precisao%, maxIteracoes%, maxJuros)
    pesoTotal = getPesoTotal()
    if Quantidade% < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao% < 1 or maxIteracoes% < 1 or maxJuros <= 0.0 then acrescimoParaJuros = 0.0 : exit function
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = 0.1 ^ precisao%

    for iteracao% = 1 to maxIteracoes%
        if maxJuros - minJuros < minDiferenca then acrescimoParaJuros = medJuros : exit function
        if jurosParaAcrescimo(medJuros) < acrescimo then minJuros = medJuros else maxJuros = medJuros
        medJuros = (minJuros + maxJuros) / 2.0
    next
    
    acrescimoParaJuros = medJuros
end function

' inicializa os elementos em Pagamentos() e Pesos()
for indice% = 0 to Quantidade% - 1
    Pagamentos(indice%) = (indice% + 1.0) * Periodo
    Pesos(indice%) = 1.0
next

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

' imprime os resultados
print "Peso total = "; : print using "#.###############"; pesoTotal
print "Acréscimo = "; : print using "#.###############"; acrescimoCalculado
print "Juros = "; : print using "#.###############"; jurosCalculado
