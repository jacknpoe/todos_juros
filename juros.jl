# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 20/03/2024: versão feita a partir de pesquisas no Google
# Versão 0.2: 21/03/2024: versão com testejuros separado
# Versão 0.3: 21/03/2024: versão com os tipos nos parâmetros

# Estrutura com os dados comuns (como parcelas)
struct Juros
    Quantidade::Integer
    Composto::Bool
    Periodo::Real
    Pagamentos::Array{Real}
    Pesos::Array{Real}
end #Juros

# calcula a somatória de Pesos[]
function getPesoTotal(sJuros::Juros)::Real
    acumulador = 0.0
    for indice = 1:sJuros.Quantidade
        acumulador += sJuros.Pesos[indice]
    end
    acumulador
end

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
function jurosParaAcrescimo(sJuros::Juros, juros::Real)::Real
    if juros <= 0 || sJuros.Quantidade <= 0 || sJuros.Periodo <= 0
        return 0.0
    end
    pesoTotal = getPesoTotal(sJuros)
    if pesoTotal <= 0
        return 0.0
    end
    acumulador = 0.0
    # soZero = true

    for indice = 1:sJuros.Quantidade
        # if sJuros.Pagamentos[indice] > 0.0 && sJuros.Pesos[indice] > 0.0
        #     soZero = false
        # end
        if sJuros.Composto
            acumulador += sJuros.Pesos[indice] / (1 + juros / 100) ^ (sJuros.Pagamentos[indice] / sJuros.Periodo)
        else
            acumulador += sJuros.Pesos[indice] / (1 + juros / 100 * sJuros.Pagamentos[indice] / sJuros.Periodo)
        end
    end

    # if soZero
    if acumulador <= 0
        return 0.0
    end
    (pesoTotal / acumulador - 1) * 100
end

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
function acrescimoParaJuros(sJuros::Juros, acrescimo::Real, precisao::Integer, maxIteracoes::Integer, maxJuros::Real)::Real
    if maxIteracoes < 1 || sJuros.Quantidade< 1 || precisao < 1 || sJuros.Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0
        return 0.0
    end
    pesoTotal = getPesoTotal(sJuros)
    if pesoTotal <= 0.0
        return 0.0
    end
    minJuros = 0.0
    medJuros = maxJuros / 2
    minDiferenca = 0.1 ^ precisao

    for indice = 1:maxIteracoes
        medJuros = (minJuros + maxJuros) / 2
        if (maxJuros - minJuros) < minDiferenca
            return medJuros
        end
        if jurosParaAcrescimo(sJuros, medJuros) < acrescimo
            minJuros = medJuros
        else
            maxJuros = medJuros
        end
    end

    medJuros
end
