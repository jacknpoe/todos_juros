# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 08/08/2024: versão feita sem muito conhecimento de Bend

# junta duas listas a, b, em uma lista de pares (a, b)
def zip(a, b):
  match a:
    case List/Cons:
      match b:
        case List/Cons:
          return List/Cons((a.head, b.head)
        case List/Nil:
          return []
    case List/Nil:
      return []

# calcula, recursivamente, a somatória de pesos
def getPesoTotal(pesos):
  fold pesos:
    case List/Cons:
      return pesos.head + pesos.tail
    case List/Nil:
      return 0.0

# calcula a soma do amortecimento de todas as parcelas para juros compostos
def rJurosCompostos(periodo, pagamentos, pesos, juros):
  fold p = zip(pagamentos, pesos):
    case List/Cons:
      (pagamento, peso) = p.head
      return peso / ((1.0 + juros / 100.0) ** (pagamento / periodo)) + p.tail
    case List/Nil:
      return 0.0

# calcula a soma do amortecimento de todas as parcelas para juros simples
def rJurosSimples(periodo, pagamentos, pesos, juros, iteracao):
  fold p = zip(pagamentos, pesos):
    case List/Cons:
      (pagamento, peso) = p.head
      return peso / (1.0 + juros / 100.0 * pagamento / periodo) + p.tail
    case List/Nil:
      return 0.0

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, juros):
  pesoTotal = getPesoTotal(pesos, quantidade)
  if composto == 1:
    return (pesoTotal / rJurosCompostos(periodo, pagamentos, pesos, juros, quantidade) - 1.0) * 100.0
  else:
    return (pesoTotal / rJurosSimples(periodo, pagamentos, pesos, juros, quantidade) - 1.0) * 100.0

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def acrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimo, precisao, maxIteracoes, maxJuros):
  minJuros = 0.0
  medJustos = maxJuros / 2.0
  minDiferenca = 0.1 ** precisao

  bend iteracaoAtual=maxIteracoes with medJuros:
    when iteracaoAtual != 0:
      if (maxJuros - minJuros) < minDiferenca:
        return medJuros
      elif jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, medJuros) < acrescimo:
        return fork(iteracaoAtual - 1, (medJuros + maxJuros) / 2.0)
      else:
        return fork(iteracaoAtual - 1, (minJuros + medJuros) / 2.0)
    else:
      return medJuros

def main:
  # variáveis globais, definidas por questão de leitura
  quantidade = 3
  composto = 1  # 1 = true
  periodo = 30.0
  pagamentos = [30.0, 60.0, 90.0]
  pesos = [1.0, 1.0, 1.0]

  # calcula e guarda os resultados das funções
  pesoTotal = getPesoTotal(pesos, quantidade)
  acrescimoCalculado = jurosParaAcrescimo(composto, periodo, pagamentos, pesos, quantidade, 3.0)
  jurosCalculado = acrescimoParaJuros(composto, periodo, pagamentos, pesos, quantidade, acrescimoCalculado, 5, 50, 50.0)

  # imprime os resultads
  return ("Peso total = ", pesoTotal, "Acréscimo = ", acrescimoCalculado, "Juros = ", jurosCalculado)
