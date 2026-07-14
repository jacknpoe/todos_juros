import numpy as np

# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
class JurosNP:
    """Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso"""
    Quantidade = 0
    Composto = False
    Periodo = 30.0
    Pagamentos = np.array([])
    Pesos = np.array([])

    def __init__(self, quantidade=0, composto=False, periodo=30.0):
        """O construtor inicializa os atributos escalares"""
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo
        self.Pagamentos = np.empty(quantidade)
        self.Pesos = np.empty(quantidade)

    def setpagamentos(self, delimitador=",", pagamentos=""):
        """Define as datas de pagamento a partir de uma string separada pelo delimitador"""
        if pagamentos == "":
            for i in range(self.Quantidade):
                self.Pagamentos[i] = (i + 1) * self.Periodo
        else:
            temporaria = pagamentos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pagamentos[i] = float(temporaria[i])

    def setpesos(self, delimitador=",", pesos=""):
        """Define os pesos a partir de uma string separada pelo delimitador"""
        if pesos == "":
            for i in range(self.Quantidade):
                self.Pesos[i] = 1.0
        else:
            temporaria = pesos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pesos[i] = float(temporaria[i])

    def getpesototal(self):
        """Retorna a soma total de todos os pesos"""
        return self.Pesos.sum()

    def jurosparaacrescimo(self, juros=0.0):
        """Calcula o acréscimo a partir dos juros"""
        pesototal = self.getpesototal()

        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or pesototal <= 0.0:
            return 0.0

        try:
            if self.Composto:
                with np.errstate(over='ignore'):
#                try:
                    acumulador = np.sum(self.Pesos / np.power(1.0 + juros / 100.0, self.Pagamentos / self.Periodo))
#                except OverflowError:
#                    pass
            else:
                acumulador = np.sum(self.Pesos / (1.0 + juros / 100.0 * self.Pagamentos / self.Periodo))
        except ZeroDivisionError:
            return 0.0

        if acumulador <= 0.0:
            return 0.0

        return (pesototal / acumulador - 1.0) * 100.0

    def acrescimoparajuros(self, acrescimo=0.0, precisao=15, maximointeracoes=65, maximojuros=50.0):
        """Calcula os juros a partir do acréscimo"""
        pesototal = self.getpesototal()

        if ( maximointeracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0
             or acrescimo <= 0.0 or pesototal <= 0.0 or maximojuros <= 0.0 ):
            return 0.0

        minimojuros = 0.0
        mediojuros = maximojuros / 2.0

        minimadiferenca = 0.1 ** precisao

        for i in range(maximointeracoes):
            if (maximojuros - minimojuros) < minimadiferenca:
                return mediojuros
            if self.jurosparaacrescimo(mediojuros) <= acrescimo:  # bisseção
                minimojuros = mediojuros
            else:
                maximojuros = mediojuros
            mediojuros = (minimojuros + maximojuros) / 2.0

        return mediojuros
