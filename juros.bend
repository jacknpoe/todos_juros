# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 08/08/2024: versão feita sem muito conhecimento de Bend
#        0.2: 04/11/2026: melhorias nos comentários; validações de parâmetros e cálculos; geração dinâmica de mapas escaláveis
#                         as funções geradoras de mapas usam Tail Call Optimization (TCO) porque ficam mais naturais assim e até menores
#                         as funções acumuladoras permanecem sem TCO porque ficam mais naturais sem acumuladores como parâmetros
#                         nos testes realizados, não foram observadas diferenças significativas de desempenho entre as versões apenas com TCO e apenas sem TCO
# ATENÇÃO: ESTA SOLUÇÃO APRESENTA ERRO DE APROX. 0.02 PARA MENOS NOS JUROS

# função recursiva que gera o mapa pagamentos
def rGeraPagamentos(indice, quantidade, periodo, pagamentos):
  if indice > quantidade:
    return pagamentos
  else:
    pagamentos[indice] = u24/to_f24(indice) * periodo
    return rGeraPagamentos(indice + 1, quantidade, periodo, pagamentos)

# função açúcar que gera o mapa pagamentos
def geraPagamentos(quantidade, periodo):
  return rGeraPagamentos(1, quantidade, periodo, {})

# função recursiva que gera o mapa pesos
def rGeraPesos(indice, quantidade, pesos):
  if indice > quantidade:
    return pesos
  else:
    pesos[indice] = 1.0
    return rGeraPesos(indice + 1, quantidade, pesos)

# função açúcar que gera o mapa pesos
def geraPesos(quantidade):
  return rGeraPesos(1, quantidade, {})

# função recursiva que calcula a somatória de pesos
def getPesoTotal(pesos, iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos[iteracao] + getPesoTotal(pesos, iteracao - 1)

# função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
def rJurosCompostos(periodo, pagamentos, pesos, juros, iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos[iteracao] / ((1.0 + juros / 100.0) ** (pagamentos[iteracao] / periodo)) + rJurosCompostos(periodo, pagamentos, pesos, juros, iteracao - 1)

# função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
def rJurosSimples(periodo, pagamentos, pesos, juros, iteracao):
  if iteracao == 0:
    return 0.0
  else:
    return pesos[iteracao] / (1.0 + juros / 100.0 * pagamentos[iteracao] / periodo) + rJurosSimples(periodo, pagamentos, pesos, juros, iteracao - 1)

# função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, juros):
  pesoTotal = getPesoTotal(pesos, quantidade)
  if quantidade < 1 | periodo <= 0.0 | pesoTotal <= 0.0 | juros <= 0.0:
    return 0.0
  else:
    if composto == 1:
      acumulador = rJurosCompostos(periodo, pagamentos, pesos, juros, quantidade)
    else:
      acumulador = rJurosSimples(periodo, pagamentos, pesos, juros, quantidade)
    if acumulador <= 0.0:
      return 0.0
    else:
      return (pesoTotal / acumulador - 1.0) * 100.0

# função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros):
  if iteracaoAtual == 0:
    return medJuros
  else:
    if (maxJuros - minJuros) <= minDiferenca:
      return medJuros
    else:
      if jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, medJuros) < acrescimo:
        return rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
      else:
        return rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

# função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def acrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, precisao, maxIteracoes, maxJuros):
  pesoTotal = getPesoTotal(pesos, quantidade)
  if quantidade < 1 | periodo <= 0.0 | pesoTotal <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0:
    return 0.0
  else:
    return rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, 0.1 ** precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

def main:
  # variáveis definidas por questão de leitura
  quantidade = 3
  composto = 1  # 1 = true
  periodo = 30.0
  pagamentos = geraPagamentos(quantidade, periodo)
  pesos = geraPesos(quantidade)

  # calcula e guarda os resultados das funções
  pesoTotal = getPesoTotal(pesos, quantidade)
  acrescimoCalculado = jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, 3.0)
  jurosCalculado = acrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimoCalculado, 15, 65, 50.0)

  # imprime os resultados
  return ("Peso total = ", pesoTotal, "Acréscimo = ", acrescimoCalculado, "Juros = ", jurosCalculado)
