#! python 3
# coding: latin1

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 19/03/2025: versão feita sem muito conhecimento de Rhino Python

# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
class Juros:
    """Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso"""
    Quantidade = 0
    Composto = False
    Periodo = 30.0
    Pagamentos = []
    Pesos = []

    def __init__(self, quantidade=0, composto=False, periodo=30.0):
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo

    """Define as datas de pagamento a partir de uma string separada pelo delimitador"""
    def setpagamentos(self, delimitador=",", pagamentos=""):
        self.Pagamentos.clear()
        if pagamentos == "":
            for i in range(self.Quantidade):
                self.Pagamentos.append((i + 1) * self.Periodo)
        else:
            temporaria = pagamentos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pagamentos.append(float(temporaria[i]))

    """Define os pesos a partir de uma string separada pelo delimitador"""
    def setpesos(self, delimitador=",", pesos=""):
        self.Pesos.clear()
        if pesos == "":
            for i in range(self.Quantidade):
                self.Pesos.append(1)
        else:
            temporaria = pesos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pesos.append(float(temporaria[i]))

    """Retorna a soma total de todos os pesos"""
    def getpesototal(self):
        acumulador = 0.0
        for i in range(self.Quantidade):
            acumulador += self.Pesos[i]
        return acumulador

    """Calcula o acréscimo a partir dos juros"""
    def jurosparaacrescimo(self, juros=0.0):
        total = self.getpesototal()

        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or total <= 0.0:
            return 0.0

        acumulador = 0.0

        for i in range(self.Quantidade):
            if self.Composto:
                acumulador += self.Pesos[i] / ((1.0 + juros / 100.0) ** (self.Pagamentos[i] / self.Periodo))
            else:
                acumulador += self.Pesos[i] / (1.0 + juros / 100.0 * self.Pagamentos[i] / self.Periodo)

        if acumulador <= 0.0:
            return 0.0

        return (total / acumulador - 1.0) * 100.0

    """Calcula os juros a partir do acréscimo"""
    def acrescimoparajuros(self, acrescimo=0.0, precisao=12, maximointeracoes=100, maximojuros=50.0,
                           acrescimocomovalororiginal=False):
        total = self.getpesototal()

        if maximointeracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0 or acrescimo <= 0.0 or total <= 0.0 or maximojuros <= 0.0:
            return 0.0

        minimojuros = 0.0
        mediojuros = 0.0

        if acrescimocomovalororiginal:      # nesse caso, os pesos totais dão o valor cobrado e o acrescimo é o original
            acrescimo = 100.0 * (total / acrescimo - 1.0)
            if acrescimo <= 0.0:
                return 0.0

        minimadiferenca = 0.1 ** precisao

        for i in range(maximointeracoes):
            mediojuros = (minimojuros + maximojuros) / 2.0
            if (maximojuros - minimojuros) < minimadiferenca:
                return mediojuros
            if self.jurosparaacrescimo(mediojuros) <= acrescimo:       # if "mágico" da bisseção
                minimojuros = mediojuros
            else:
                maximojuros = mediojuros

        return mediojuros

juros = Juros(3, True, 30.0)
juros.setpagamentos(",", "30.0,60.0,90.0")
juros.setpesos(",", "1.0,1.0,1.0")

print("Peso total = " + str(juros.getpesototal()))
print("Acréscimo = " + str(juros.jurosparaacrescimo(3.0)))
print("Juros = " + str(juros.acrescimoparajuros(juros.jurosparaacrescimo(3.0), 18)))