# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 18/03/2026: feita sem muito conhecimento de Starlark

# "constantes" para as iterações em ln() e exp()
TOTLN = 20
TOTEXP = 30

# globais para a simplificação das chamadas às funções e inicialização das escalares
Quantidade = 3
Composto = True
Periodo = 30.0
Pagamentos = []
Pesos = []

def ln(x):
    """essa função é mais precisa com valores mais próximos de 1, como 1.0 a 1.1, que é a faixa em que vai ser usada"""
    termo = (x - 1.0) / (x + 1.0)
    yy = termo * termo
    soma = 0.0

    for indice in range(TOTLN):
        soma = soma + termo / (2.0 * (indice + 1.0) - 1.0)
        termo = termo * yy

    return 2.0 * soma

def exp(x):
    """essa função é mais precisa com valores menores do que 5, que é a faixa em que vai ser usada"""
    termo = 1.0
    soma = 1.0

    for indice in range(TOTEXP):
        termo = termo * x / (indice + 1.0)
        soma = soma + termo

    return soma

def pow(base, expoente):
    """essa função tem a precisão boa de acordo com ln() e exp()"""
    return exp(ln(base) * expoente)

def powint(base, expoente):
    """essa função é especial para expoentes inteiros (optar por inteiros pode aumentar a precisão, a base pode ser negativa)
    ela é exata para 0.1 ^ precisao, que é muito usada na regra de parada maxJuros - minJuros < minDiferenca, onde minDiferenca = powint(0.1, precisao)"""
    produto = 1.0

    for indice in range(expoente):
        produto = produto * base

    return produto

def getPesoTotal():
    """calcula a somatória dos elementos do array Pesos[]"""
    acumulador = 0.0

    for indice in range(Quantidade):
        acumulador = acumulador + Pesos[indice]
    
    return acumulador

def jurosParaAcrescimo(juros):
    """calcula o acréscimo a partir dos juros e parcelas"""
    pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0:
        return 0.0
    acumulador = 0.0

    for indice in range(Quantidade):
        if Composto:
            acumulador = acumulador + Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
        else:
            acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
    
    if acumulador <= 0.0:
        return 0.0
    return (pesoTotal / acumulador - 1.0) * 100.0

def acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros):
    """calcula os juros a partir do acréscimo e parcelas"""
    pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0:
        return 0.0
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = powint(0.1, precisao)

    for iteracao in range(maxIteracoes):
        if maxJuros - minJuros < minDiferenca:
            return medJuros
        if jurosParaAcrescimo(medJuros) < acrescimo:
            minJuros = medJuros
        else:
            maxJuros = medJuros
        medJuros = (minJuros + maxJuros) / 2.0

    return medJuros

def main():
    """a lógica só está em main porque Sgtarlark não aceita for fora de função"""
    # preenche os arrays Pagamentos[] e Pesos[]
    for indice in range(Quantidade):
        Pagamentos.append((indice + 1.0) * Periodo)
        Pesos.append(1.0)

    # calcula e guarda os resultados das funções
    pesoTotal = getPesoTotal()
    acrescimoCalculado = jurosParaAcrescimo(3.0)
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

    # imprime os resultados
    print("Peso total = " + str(pesoTotal))
    print("Acréscimo = " + str(acrescimoCalculado))
    print("Juros = " + str(jurosCalculado))

main()
