# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 17/03/2025: versão feita sem muito conhecimento de Hamilton C Shell

# define variáveis globais para simplificar as chamadas das funções
@ Quantidade = 3
@ Composto = 1   # 1 = TRUE
@ Periodo = 30.0

# define dinamicamente os arrays
unset Pagamentos
unset Pesos
for indice = 0 to (Quantidade - 1) do
    @ Pagamentos[indice] = (indice + 1.0) * Periodo
    @ Pesos[indice] = 1.0
end

# calcula a somatória de Pesos[]
proc getPesoTotal()
    local acumulador, indice
    @ acumulador = 0.0
    for indice = 0 to (Quantidade - 1) do
        @ acumulador += Pesos[indice]
    end
    return acumulador
end

# calcula o acréscimo a partir dos juros e parcelas
proc jurosParaAcrescimo(juros)
    local pesoTotal, acumulador, indice
    @ pesoTotal = getPesoTotal()
    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || juros <= 0.0) return 0.0

    @ acumulador = 0.0
    for indice = 0 to (Quantidade - 1) do
        if(Composto == 1) then
            @ acumulador += Pesos[indice] / (1.0 + juros / 100.0) ** (Pagamentos[indice] / Periodo)
        else
            @ acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
        end
    end

    if(acumulador <= 0.0) return 0.0
    return (pesoTotal / acumulador - 1.0) * 100.0
end

# calcula os juros a partir do acréscimo e parcelas
proc acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    local pesoTotal, indice, minJuros, medJuros, minDiferenca
    @ pesoTotal = getPesoTotal()
    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0

    @ minJuros = 0.0
    @ minDiferenca = 0.1 ** precisao
    for indice = 1 to maxIteracoes do
        @ medJuros = (minJuros + maxJuros) / 2.0
        if((maxJuros - minJuros) < minDiferenca) return medJuros
        if(jurosParaAcrescimo(medJuros) < acrescimo) then
            @ minJuros = medJuros
        else
            @ maxJuros = medJuros
        end
    end

    return medJuros
end

# calcula e guarda os resultados das funções
@ pesoTotal = getPesoTotal()
@ acrescimoCalculado = jurosParaAcrescimo(3.0)
@ jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

# imprime os resultados
echo Peso total = ${pesoTotal}
echo Acrescimo = ${acrescimoCalculado}
echo Juros = ${jurosCalculado}