# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 08/08/2024: versão feita sem muito conhecimento de Bend
#        0.2: 21/03/2026: versão com mapeamento por funções

# função que mapeia pagamentos como um array
def pagamentos(indice, periodo):
  return u24/to_f24(indice) * periodo

# função que mapeia pesos como um array
def pesos(indice):
  return 1.0

# calcula, recursivamente, a somatória de pesos
def getPesoTotal(iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos(iteracao) + getPesoTotal(iteracao - 1)

# calcula a soma do amortecimento de todas as parcelas para juros compostos
def rJurosCompostos(periodo, juros, iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos(iteracao) / ((1.0 + juros / 100.0) ** (pagamentos(iteracao, periodo) / periodo)) + rJurosCompostos(periodo, juros, iteracao - 1)

# calcula a soma do amortecimento de todas as parcelas para juros simples
def rJurosSimples(periodo, juros, iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos(iteracao) / (1.0 + juros / 100.0 * pagamentos(iteracao, periodo) / periodo) + rJurosSimples(periodo, juros, iteracao - 1)

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo(composto, periodo, quantidade, juros):
  pesoTotal = getPesoTotal(quantidade)
  if composto == 1:
    return (pesoTotal / rJurosCompostos(periodo, juros, quantidade) - 1.0) * 100.0
  else:
    return (pesoTotal / rJurosSimples(periodo, juros, quantidade) - 1.0) * 100.0

# função recursiva no lugar de um for que realmente calcula o acréscimo
def rAcrescimoParaJuros(composto, periodo, quantidade, acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros):
  if iteracaoAtual == 0:
    return medJuros
  else:
    if (maxJuros - minJuros) < minDiferenca:
      return medJuros
    else:
      if jurosParaAcrescimo(composto, periodo, quantidade, medJuros) < acrescimo:
        return rAcrescimoParaJuros(composto, periodo, quantidade, acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
      else:
        return rAcrescimoParaJuros(composto, periodo, quantidade, acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def acrescimoParaJuros(composto, periodo, quantidade, acrescimo, precisao, maxIteracoes, maxJuros):
  return rAcrescimoParaJuros(composto, periodo, quantidade, acrescimo, 0.1 ** precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

def main:
  # variáveis globais, definidas por questão de leitura
  quantidade = 3
  composto = 1  # 1 = true
  periodo = 30.0

  # calcula e guarda os resultados das funções
  pesoTotal = getPesoTotal(quantidade)
  acrescimoCalculado = jurosParaAcrescimo(composto, periodo, quantidade, 3.0)
  jurosCalculado = acrescimoParaJuros(composto, periodo, quantidade, acrescimoCalculado, 15, 65, 50.0)

  # imprime os resultads
  return ("Peso total = ", pesoTotal, "Acréscimo = ", acrescimoCalculado, "Juros = ", jurosCalculado)
