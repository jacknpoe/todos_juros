# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 27/05/2024: versão feita sem muito conhecimento de CoffeeScript

# classe com os atributos de uma estutura básica para simplificar as chamadas
class Juros
    # construtor (recebe os valores de cinco atributos)
    constructor: (@Quantidade, @Composto, @Periodo, @Pagamentos, @Pesos) ->

    # calcula a somatória de Pesos[]
    getPesoTotal: ->
        acumulador = 0.0
        for indice in [0..@Quantidade - 1]
            acumulador += @Pesos[indice]
        return acumulador

    # calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    jurosParaAcrescimo: (juros) ->
        pesoTotal = @getPesoTotal()
        if juros <= 0.0 || @Quantidade < 1 || @Periodo <= 0.0 || pesoTotal <= 0.0
            return 0.0

        acumulador = 0.0
        for indice in [0..@Quantidade - 1]
            if @Composto
                acumulador += @Pesos[indice] / \
                    Math.pow(1.0 + juros / 100.0, @Pagamentos[indice] / @Periodo)
            else
                acumulador += @Pesos[indice] / \
                    (1.0 + juros / 100.0 * @Pagamentos[indice] / @Periodo)

        return (pesoTotal / acumulador - 1.0) * 100.0

    # calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    acrescimoParaJuros: (acrescimo, precisao, maxIteracoes, maxJuros) ->
        pesoTotal = @getPesoTotal()
        if acrescimo <= 0.0 || @Quantidade < 1 || @Periodo <= 0.0 || pesoTotal <= 0.0 \
            || maxIteracoes < 1 || precisao < 1 || maxJuros <= 0.0
            return 0.0

        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = Math.pow(0.1, precisao)

        for indice in [1..maxIteracoes]
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca
                return medJuros
            if @jurosParaAcrescimo(medJuros) < acrescimo
                minJuros = medJuros
            else
                maxJuros = medJuros
        
        return medJuros

# cria o objeto juros da classe Juros e define os valores básicos
juros = new Juros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0])

# testa os valores resultado dos métodos
console.log("Peso total = #{juros.getPesoTotal()}")
console.log("Acréscimo = #{juros.jurosParaAcrescimo(3.0)}")
console.log("Juros = #{juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15, 100, 50.0)}")