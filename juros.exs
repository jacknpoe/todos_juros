# Cálculo do juros, sendo que precisa de listas pra isso
# Versão 0.1: 05/04/2024: começo sem conhecer muita coisa necessária, como índices (apenas estrutura e construtor)
#        0.2: 29/04/2024: as três funções e as recursivas (ou seja, todo o cálculo)
#        0.3: 16/11/2026: melhorados comentários; variáveis separadas dos IO.puts; avaliação de acumulador; troca de Enum.at por cabeça e cauda; variáveis para configuração
#                         listas escaláveis criadas dinamicamente; removidos casos especiais; funções recursivas alteradas para permitir Tail Call Optimization (TCO)

# módulo da "classe" Juros
defmodule Juros do
  @moduledoc """
  Estrutura e funções de cálculos entre acréscimo e juros
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

  # função açúcar que calcula a somatória de pesos
  def getPesoTotal(ojuros) do rGetPesoTotal(ojuros.pesos, 0.0) end

  # função recursiva que calcula a somatória de pesos
  def rGetPesoTotal(pesos, acumulador) do
    case pesos do
      [] -> acumulador
      [hPes|tPes] -> rGetPesoTotal(tPes, hPes + acumulador)
    end
  end

  # função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
  def jurosParaAcrescimo(ojuros, juros) do
    if juros <= 0.0 || ojuros.quantidade <= 0 || ojuros.periodo <= 0.0 do
      0.0
    else
      pesoTotal = getPesoTotal(ojuros)
      if pesoTotal <= 0.0 do
        0.0
      else
        acumulador = if ojuros.composto do
          rJurosCompostos(ojuros, ojuros.pagamentos, ojuros.pesos, juros, 0.0)
        else
          rJurosSimples(ojuros, ojuros.pagamentos, ojuros.pesos, juros, 0.0)
        end
        if acumulador <= 0.0 do
          0.0
        else
          (pesoTotal / acumulador - 1.0) * 100.0
        end
      end
    end
  end

  # função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
  def rJurosCompostos(ojuros, pagamentos, pesos, juros, acumulador) do
    case {pagamentos, pesos} do
      {[], []} -> acumulador
      {[], [_|_]} -> acumulador
      {[_|_], []} -> acumulador
      {[hPag|tPag], [hPes|tPes]} -> rJurosCompostos(ojuros, tPag, tPes, juros, hPes * :math.pow(1.0 + juros / 100.0, -hPag / ojuros.periodo) + acumulador)
    end
  end

  # função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
  def rJurosSimples(ojuros, pagamentos, pesos, juros, acumulador) do
    case {pagamentos, pesos} do
      {[], []} -> acumulador
      {[], [_|_]} -> acumulador
      {[_|_], []} -> acumulador
      {[hPag|tPag], [hPes|tPes]} -> rJurosSimples(ojuros, tPag, tPes, juros, hPes / (1.0 + juros / 100.0 * hPag / ojuros.periodo) + acumulador)
    end
  end

  # função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
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

  # função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
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

# módulo de funções de listas
defmodule Listas do
  @moduledoc """
  Funções de criação dinâmica de listas escaláveis
  """
  # função açúcar que cria a lista pagamentos
  def criaPagamentos(quantidade, periodo) do rCriaPagamentos(quantidade, periodo, 1, []) end

  # função recursiva que cria a lista pagamentos
  def rCriaPagamentos(quantidade, periodo, indice, acumulador) do
    if indice > quantidade do
      acumulador
    else
      rCriaPagamentos(quantidade, periodo, indice + 1, [indice * periodo | acumulador])
    end
  end

  # função açúcar que cria a lista pesos
  def criaPesos(quantidade) do rCriaPesos(quantidade, 1, []) end

  # função recursiva que cria a lista pesos
  def rCriaPesos(quantidade, indice, acumulador) do
    if indice > quantidade do
      acumulador
    else
      rCriaPesos(quantidade, indice + 1, [1.0 | acumulador])
    end
  end
end

# módulo de testes
defmodule Main do
  def main do
    # para os valores de ojuros
    quantidade = 3
    composto = true
    periodo = 30.0
    pagamentos = Listas.criaPagamentos(quantidade, periodo)
    pesos = Listas.criaPesos(quantidade)

    # define os valores de ojuros
    ojuros = Juros.novo(quantidade, composto, periodo, pagamentos, pesos)

    # calcula e guarda os resultados das funções
    pesoTotal = Juros.getPesoTotal(ojuros)
    acrescimoCalculado = Juros.jurosParaAcrescimo(ojuros, 3.0)
    jurosCalculado = Juros.acrescimoParaJuros(ojuros, acrescimoCalculado, 15, 65, 50.0)

    # imprime os resultados
    IO.puts("Peso total = #{pesoTotal}")
    IO.puts("Acréscimo = #{acrescimoCalculado}")
    IO.puts("Juros = #{jurosCalculado}")
  end
end

Main.main()
