-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 05/07/2024: versão feita sem muito conhecimento de Euphoria

include std/io.e

-- propriedades globais para simplificar as chamadas
global atom Quantidade = 3
global atom Composto = 1
global atom Periodo = 30.0
global sequence Pagamentos = {30.0, 60.0, 90.0}
global sequence Pesos = {1.0, 1.0, 1.0}

-- calcula a somatória da sequência Pesos[]
function getPesoTotal()
    atom acumulador = 0.0
    for indice = 1 to Quantidade do
        acumulador += Pesos[indice]
    end for
    return acumulador
end function

-- calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(atom juros)
    atom pesoTotal = getPesoTotal()
    if juros <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 then
        return 0.0
    end if
    atom acumulador = 0.0

    for indice = 1 to Quantidade do
        if Composto > 0 then
            acumulador += Pesos[indice] / power(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
        else
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
        end if
    end for

    return (pesoTotal / acumulador - 1.0) * 100.0
end function

-- calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(atom acrescimo, atom precisao, atom maxIteracoes, atom maxJuros)
    atom pesoTotal = getPesoTotal()
    if acrescimo <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then
        return 0.0
    end if
    atom minJuros = 0.0
    atom medJuros = maxJuros / 2.0
    atom minDiferenca = power(0.1, precisao)

    for indice = 1 to maxIteracoes do
        medJuros = (minJuros + maxJuros) / 2.0
        if (maxJuros - minJuros) < minDiferenca then
            return medJuros
        end if
        if jurosParaAcrescimo(medJuros) < acrescimo then
            minJuros = medJuros
        else
            maxJuros = medJuros
        end if
    end for

    return medJuros
end function

procedure main()
    -- calcula e guarda os resultados das funções
    atom pesoTotal = getPesoTotal()
    atom acrescimoCalculado = jurosParaAcrescimo(3.0)
    atom jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

    -- imprime os resultados
    puts(STDOUT, "Peso total = ")
    printf(STDOUT, "%2.14f", pesoTotal)
    puts(STDOUT, "\n")
    puts(STDOUT, "Acréscimo = ")
    printf(STDOUT, "%2.14f", acrescimoCalculado)
    puts(STDOUT, "\n")
    puts(STDOUT, "Juros = ")
    printf(STDOUT, "%2.14f", jurosCalculado)
    puts(STDOUT, "\n")
end procedure

main()
