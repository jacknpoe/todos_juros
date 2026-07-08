# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
class Juros:
    """Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso"""
    Quantidade = 0
    Composto = False
    Periodo = 30.0
    Pagamentos = []
    Pesos = []

    def __init__(self, quantidade=0, composto=False, periodo=30.0):
        """O construtor inicializa os atributos escalares"""
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo

    def setpagamentos(self, delimitador=",", pagamentos=""):
        """Define as datas de pagamento a partir de uma string separada pelo delimitador"""
        self.Pagamentos.clear()
        if pagamentos == "":
            for i in range(self.Quantidade):
                self.Pagamentos.append((i + 1) * self.Periodo)
        else:
            temporaria = pagamentos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pagamentos.append(float(temporaria[i]))

    def setpesos(self, delimitador=",", pesos=""):
        """Define os pesos a partir de uma string separada pelo delimitador"""
        self.Pesos.clear()
        if pesos == "":
            for i in range(self.Quantidade):
                self.Pesos.append(1.0)
        else:
            temporaria = pesos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pesos.append(float(temporaria[i]))

    def getpesototal(self):
        """Retorna a soma total de todos os pesos"""
        acumulador = 0.0
        for i in range(self.Quantidade):
            acumulador += self.Pesos[i]
        return acumulador

    def jurosparaacrescimo(self, juros=0.0):
        """Calcula o acréscimo a partir dos juros"""
        pesototal = self.getpesototal()

        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or pesototal <= 0.0:
            return 0.0

        acumulador = 0.0

        for i in range(self.Quantidade):
            try:
                if self.Composto:
                    acumulador += self.Pesos[i] / ((1.0 + juros / 100.0) ** (self.Pagamentos[i] / self.Periodo))
                else:
                    acumulador += self.Pesos[i] / (1.0 + juros / 100.0 * self.Pagamentos[i] / self.Periodo)
            except (OverflowError, ZeroDivisionError):
                pass

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
