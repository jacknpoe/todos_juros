defmodule Juros do
  @moduledoc """
  Cálculo do juros, sendo que precisa de listas pra isso
  Versão 0.1: 05/04/2024: começo sem conhecer muita coisa necessária, como índices (apenas estrutura e construtor)
         0.2: 29/04/2024: as três funções e as recursivas (ou seja, todoo cálculo)
  """

  # estrutura básica para simplificar as chamadas
  defstruct quantidade: 0, composto: false, periodo: 0.0, pagamentos: [0.0], pesos: [0.0]

  # "Construtor"
  def novo(pquantidade, pcomposto, pperiodo, ppagamentos, ppesos) do
    %__MODULE__{
      quantidade: pquantidade,
      composto: pcomposto,
      periodo: pperiodo,
      pagamentos: ppagamentos,
      pesos: ppesos
    }
  end

  # calcula a somatória de Pesos[]
  def getPesoTotal(ojuros) do
    rGetPesoTotal(ojuros, ojuros.quantidade-1)
  end

  # cálculo real da somatória de Pesos[]
  def rGetPesoTotal(ojuros, indice) do
    if indice == 0 do
      Enum.at(ojuros.pesos, 0)
    else
      Enum.at(ojuros.pesos, indice) + rGetPesoTotal(ojuros, indice - 1)
    end
  end

  # calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
  def jurosParaAcrescimo(ojuros, juros) do
    if juros <= 0.0 || ojuros.quantidade <= 0 || ojuros.periodo <= 0.0 do
      0.0
    else
      pesoTotal = getPesoTotal(ojuros)
      if pesoTotal <= 0.0 do
        0.0
      else
        if ojuros.composto do
          (pesoTotal / rJurosCompostos(ojuros, ojuros.quantidade - 1, juros) - 1.0) * 100.0
        else
          (pesoTotal / rJurosSimples(ojuros, ojuros.quantidade - 1, juros) - 1.0) * 100.0
        end
      end
    end
  end

  # calcula a soma do amortecimento de todas as parcelas para juros compostos
  def rJurosCompostos(ojuros, indice, juros) do
    if indice == 0 do
      Enum.at(ojuros.pesos, 0) / :math.pow(1.0 + juros / 100.0, Enum.at(ojuros.pagamentos, 0) / ojuros.periodo)
    else
      Enum.at(ojuros.pesos, indice) / :math.pow(1.0 + juros / 100.0, Enum.at(ojuros.pagamentos, indice) / ojuros.periodo) + rJurosCompostos(ojuros, indice - 1, juros)
    end
  end

  # calcula a soma do amortecimento de todas as parcelas para juros simples
  def rJurosSimples(ojuros, indice, juros) do
    if indice == 0 do
      Enum.at(ojuros.pesos, 0) / (1.0 + juros / 100.0 * Enum.at(ojuros.pagamentos, 0) / ojuros.periodo)
    else
      Enum.at(ojuros.pesos, indice) / (1.0 + juros / 100.0 * Enum.at(ojuros.pagamentos, indice) / ojuros.periodo) + rJurosSimples(ojuros, indice - 1, juros)
    end
  end

  # calcula os juros a partir do acréscimo e dados comuns (como parcelas)
  def acrescimoParaJuros(ojuros, acrescimo, precisao, maxIteracoes, maxJuros) do
    if acrescimo <= 0.0 || ojuros.quantidade < 1 || ojuros.periodo <= 0.0 || maxIteracoes < 1 || precisao < 1 || maxJuros <= 0.0 do
      0.0
    else
      if getPesoTotal(ojuros) <= 0.0 do
        0.0
      else
        rAcrescimoParaJuros(ojuros, acrescimo, :math.pow(0.1, precisao), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)
      end
    end
  end

  # função recursiva no lugar de um for que realmente calcula o acréscimo
  def rAcrescimoParaJuros(ojuros, acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) do
    if iteracaoAtual == 0 || (maxJuros - minJuros) < minDiferenca do
      medJuros
    else
      if jurosParaAcrescimo(ojuros, medJuros) < acrescimo do
        rAcrescimoParaJuros(ojuros, acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
      else
        rAcrescimoParaJuros(ojuros, acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)
      end
    end
  end
end

defmodule Main do
  def main do
    # define os valores de ojuros
    ojuros = Juros.novo(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0])

    # testa as funções
    pesoTotal = Juros.getPesoTotal(ojuros)
    IO.puts("Peso total = #{pesoTotal}")
    acrescimo = Juros.jurosParaAcrescimo(ojuros, 3.0)
    IO.puts("Acréscimo = #{acrescimo}")
    juros = Juros.acrescimoParaJuros(ojuros, acrescimo, 15, 100, 50.0)
    IO.puts("Juros = #{juros}")
  end
end

Main.main()
