# Calcula o acrescimo a partir dos juros e os juros a partir do acrescimo
class Juros:
    """Classe que faz o calculo do juros, sendo que precisa de arrays pra isso"""
    Quantidade = 0
    Composto = False
    Periodo = 30
    Pagamentos = []
    Pesos = []

    def __init__(self, quantidade=0, composto=False, periodo=30):
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo

    def setpagamentos(self, delimitador=",", pagamentos=""):
        """Define as datas de pagamento a partir de uma string separada pelo delimitador"""
        self.Pagamentos = [] # alterado em Jython
        if pagamentos == "":
            for i in range(self.Quantidade):
                self.Pagamentos.append((i + 1) * self.Periodo)
        else:
            temporaria = pagamentos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pagamentos.append(float(temporaria[i]))

    def setpesos(self, delimitador=",", pesos=""):
        """Define os pesos a partir de uma string separada pelo delimitador"""
        self.Pesos = [] # alterado em Jython
        if pesos == "":
            for i in range(self.Quantidade):
                self.Pesos.append(1)
        else:
            temporaria = pesos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pesos.append(float(temporaria[i]))

    def getpesototal(self):
        """Retorna a soma total de todos os pesos"""
        acumulador = 0
        for i in range(self.Quantidade):
            acumulador += self.Pesos[i]
        return acumulador

    def jurosparaacrescimo(self, juros=0):
        """Calcula o acrescimo a partir dos juros"""
        if juros == 0 or self.Quantidade == 0 or self.Periodo == 0:
            return 0

        total = self.getpesototal()
        acumulador = 0
        sozero = True

        for i in range(self.Quantidade):
            if self.Pagamentos[i] > 0 and self.Pesos[i] > 0:
                sozero = False
            if self.Composto:
                acumulador += self.Pesos[i] / ((1 + juros / 100) ** (self.Pagamentos[i] / self.Periodo))
            else:
                acumulador += self.Pesos[i] / (1 + juros / 100 * self.Pagamentos[i] / self.Periodo)

        if sozero:
            return 0

        return (total / acumulador - 1) * 100

    def acrescimoparajuros(self, acrescimo=0.0, precisao=12, maximointeracoes=100, maximojuros=50.0,
                           acrescimocomovalororiginal=False):
        """Calcula os juros a partir do acrescimo"""
        if maximointeracoes < 1 or self.Quantidade <= 0 or precisao < 1 or self.Periodo <= 0 or acrescimo <= 0:
            return 0

        minimojuros = 0.0
        mediojuros = 0.0
        total = self.getpesototal()

        if total == 0:
            return 0

        if acrescimocomovalororiginal:      # nesse caso, os pesos totais dao o valor cobrado e o acrescimo eh o original
            acrescimo = 100 * (total / acrescimo - 1)
            if acrescimo <= 0:
                return 0

        minimadiferenca = 0.1 ** precisao

        for i in range(maximointeracoes):
            mediojuros = (minimojuros + maximojuros) / 2
            if (maximojuros - minimojuros) < minimadiferenca:
                return mediojuros
            if self.jurosparaacrescimo(mediojuros) <= acrescimo:       # if "magico" da bissecao
                minimojuros = mediojuros
            else:
                maximojuros = mediojuros

        return mediojuros
