// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1:  26/02/2025: versão feita sem muito conhecimento de Scilab

// limpa o console, retirar se quiser manter os resultados entre chamadas
clc

format(17)
funcprot(0)

// variáveis globais para simplificar as chamadas
Quantidade = 3
Composto = %T
Periodo = 30.0
Pagamentos = []
Pesos = []

// inicialização dos arrays
for indice = 1 : Quantidade
    Pagamentos(indice) = 30.0 * indice
    Pesos(indice) = 1.0
end

// calcula a somatória de Pesos()
function acumulador = getPesoTotal()
    acumulador = 0.0
    for indice = 1 : Quantidade
        acumulador = acumulador + Pesos(indice)
    end
endfunction

// calcula o acréscimo a partir dos juros e parcelas
function resultado = jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal()
    if pesoTotal <= 0.0 | Quantidade < 1 | Periodo <= 0.0 | juros <= 0.0 then
        resultado = 0.0
    else
        acumulador = 0.0
        for indice = 1 : Quantidade
            if Composto then
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
            else
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
            end
        end
        resultado = (pesoTotal / acumulador - 1.0) * 100.0
    end
endfunction

// calcula os juros a partir do acréscimo e parcelas
function medJuros = acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = getPesoTotal()
    if pesoTotal <= 0.0 | Quantidade < 1 | Periodo <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0 then
        medJuros = 0.0
    else
        indice = 0
        minJuros = 0.0
        minDiferenca = 0.1 ^ precisao
        while indice < maxIteracoes
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca then
                indice = maxIteracoes
            else
                if jurosParaAcrescimo(medJuros) < acrescimo then
                    minJuros = medJuros
                else
                    maxJuros = medJuros
                end
                indice = indice + 1
            end
        end
    end
endfunction

// calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
disp("Peso total = " + string(pesoTotal))
disp("Acréscimo = " + string(acrescimoCalculado))
disp("Juros = " + string(jurosCalculado))
