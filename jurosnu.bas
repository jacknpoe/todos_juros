' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 10/07/2025: versão feita sem muito conhecimento de nuBASIC

' variáveis globais para simplificar as chamadas
Quantidade% = 3
Composto# = true
Periodo! = 30.0
dim Pagamentos!(Quantidade%)
dim Pesos!(Quantidade%)

for indice% = 0 to Quantidade%-1
    Pagamentos!(indice%) = (indice% + 1.0) * Periodo!
    Pesos!(indice%) = 1.0
next

' calcula a somatória de Pesos()
function getPesoTotal() as double
    acumulador! = 0.0
    for indice% = 0 to Quantidade%-1
        acumulador! = acumulador! + Pesos!(indice%)
    next
    getPesoTotal = acumulador!
end function

' calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros!) as double
    pesoTotal! = getPesoTotal()
    if Quantidade% < 1 or Periodo! <= 0.0 or pesoTotal! <= 0.0 or juros! <= 0.0 then
        jurosParaAcrescimo = 0.0
        exit function
    end if

    acumulador! = 0.0
    for indice% = 0 to Quantidade%-1
        if Composto# then
            acumulador! = acumulador! + (Pesos!(indice%) / ((1.0 + (juros! / 100.0)) ^ (Pagamentos!(indice%) / Periodo!)))
        else
            acumulador! = acumulador! + (Pesos!(indice%) / (1.0 + (juros! / 100.0 * Pagamentos!(indice%) / Periodo!)))
        end if
    next

    if acumulador! <= 0.0 then
        jurosParaAcrescimo = 0.0
        exit function
    end if
    jurosParaAcrescimo = (pesoTotal! / acumulador! - 1.0) * 100.0
end function

' calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo!, precisao%, maxIteracoes%, maxJuros!) as double
    pesoTotal! = getPesoTotal()
    if Quantidade% < 1 or Periodo! <= 0.0 or pesoTotal! <= 0.0 or acrescimo! <= 0.0 or precisao% < 1 or maxIteracoes% < 1 or maxJuros! <= 0.0 then
        jurosParaAcrescimo = 0.0
        exit function
    end if

    minJuros! = 0.0
    medJuros! = maxJuros! / 2.0
    minDiferenca! = 0.1 ^ precisao%
    iteracao% = 0
    while iteracao% < maxIteracoes%
        if maxJuros! - minJuros! < minDiferenca! then
            iteracao% = maxIteracoes%
        end if
        if jurosParaAcrescimo(medJuros!) < acrescimo! then
            minJuros! = medJuros!
        else
            maxJuros! = medJuros!
        end if
        medJuros! = (minJuros! + maxJuros!) / 2.0
        iteracao% = iteracao% + 1
    end while
    acrescimoParaJuros = medJuros!
end function

' calcula e guarda os resultados das funções
pesoTotal! = getPesoTotal()
acrescimoCalculado! = jurosParaAcrescimo(3.0)
jurosCalculado! = acrescimoParaJuros(acrescimoCalculado!, 15, 100, 50.0)

' imprime os resultados
print "Peso total = "; StrP$(pesoTotal!, 15)
print "Acrescimo = "; StrP$(acrescimoCalculado!, 15)
print "Juros = "; StrP$(jurosCalculado!, 15)