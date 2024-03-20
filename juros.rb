class Juros
  attr_accessor :quantidade, :composto, :periodo, :pagamentos, :pesos

  # construtor (perceba que o padrão de quantidade quebra a lógica dos cálculos)
  def initialize(quantidade = 0, composto = false, periodo = 30.0)
    @quantidade = quantidade
    @composto = composto
    @periodo = periodo
    @pagamentos = []
    @pesos = []
  end

  # retorna a soma de todos os pesos totais (obrigatório maior que zero para não dividir por zero)
  def getPesoTotal()
    acumulador = 0.0
    for indice in 0..@quantidade-1
      acumulador += @pesos[indice]
    end
    return acumulador
  end

  # calcula o acréscimo a partir dos juros e parcelas
  def jurosParaAcrescimo(juros)
    if juros <= 0 or @quantidade <= 0 or @periodo <= 0
      return 0.0
    end
    pesoTotal = getPesoTotal()
    if pesoTotal <= 0
      return 0.0
    end

    acumulador = 0.0
    soZero = true

    for indice in 0..@quantidade-1
      if @pagamentos[indice] > 0 and @pesos[indice] > 0
        soZero = false
      end
      if @composto
        acumulador += ( @pesos[indice] / (1.0 + juros / 100.0) ** (@pagamentos[indice] / @periodo) )
      else
        acumulador += ( @pesos[indice] / (1.0 + juros / 100.0 * @pagamentos[indice] / @periodo) )
      end
    end

    if soZero
      return 0.0
    end
    return (pesoTotal / acumulador - 1) * 100
  end

  # calcula os juros a partir do acréscimo e parcelas
  def acrescimoParaJuros(acrescimo, precisao = 15, maxIteracoes = 100, maxJuros = 50.0)
    if maxIteracoes < 1 or @quantidade <= 0 or precisao < 1 or @periodo <= 0 or acrescimo <= 0 or maxJuros <= 0
      return 0.0
    end
    minJuros = 0.0
    medJuros = maxJuros / 2
    minDiferenca = 0.1 ** precisao
    pesoTotal = getPesoTotal()
    if pesoTotal <= 0
      return 0.0
    end

    for indice in 1..maxIteracoes
      medJuros = (minJuros + maxJuros) / 2
      if (maxJuros - minJuros) < minDiferenca
        return medJuros
      end
      if jurosParaAcrescimo(medJuros) <= acrescimo
        minJuros = medJuros
      else
        maxJuros = medJuros
      end
    end

    return medJuros
  end
end

#testes
juros = Juros.new(3, true, 30.0)
juros.pagamentos[0] = 30.0
juros.pagamentos[1] = 60.0
juros.pagamentos[2] = 90.0
juros.pesos[0] = 1.0
juros.pesos[1] = 1.0
juros.pesos[2] = 1.0

puts(juros.getPesoTotal())
puts(juros.jurosParaAcrescimo(3.0))
puts(juros.acrescimoParaJuros( juros.jurosParaAcrescimo(3.0)))
