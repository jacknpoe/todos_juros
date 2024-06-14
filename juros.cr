# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 14/06/2024: versão feita sem muito conhecimento de Crystal
require "math"  # para exp e log

# função power com expoente ponto flutuante não existe em Crystal
def power(base : Float64, expoente : Float64)
    Math.exp(expoente * Math.log(base))
end

class Juros
    # o construtor define todos os atributos, que existem para simplificar as chamadas
    def initialize(@quantidade : Int16, @composto : Bool, @periodo : Float64, @pagamentos : Array(Float64), @pesos : Array(Float64))
    end

    # calcula a somatória de pesos[]
    def getPesoTotal : Float64
        acumulador = 0.0
        indice = 0
        while indice < @quantidade
            acumulador += @pesos[indice]
            indice += 1
        end
        return acumulador
    end

    # calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    def jurosParaAcrescimo(juros : Float64) : Float64
        pesoTotal = getPesoTotal
        if juros <= 0.0 || @quantidade < 1 || @periodo <= 0.0 || pesoTotal <= 0.0
            return 0.0
        end
        acumulador = 0.0
        indice = 0

        while indice < @quantidade
            if @composto
                acumulador += @pesos[indice] / power(1.0 + juros / 100.0, @pagamentos[indice] / @periodo)
            else
                acumulador += @pesos[indice] / (1.0 + juros / 100.0 * @pagamentos[indice] / @periodo)
            end
            indice += 1
        end

        return (pesoTotal / acumulador - 1.0) * 100.0
    end

    # calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    def acrescimoParaJuros(acrescimo : Float64, precisao : Int8, maxIteracoes : Int16, maxJuros : Float64) : Float64
        pesoTotal = getPesoTotal
        if acrescimo <= 0.0 || @quantidade < 1 || @periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0
            return 0.0
        end
        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = power(0.1, precisao.to_f64)
        indice = 0

        while indice < maxIteracoes
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - medJuros) < minDiferenca
                return medJuros
            end
            if jurosParaAcrescimo(medJuros) < acrescimo
                minJuros = medJuros
            else
                maxJuros = medJuros
            end
            indice += 1
        end

        return medJuros
    end

end
