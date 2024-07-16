# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 16/07/2024: cópia de Python e conversão

cdef class Juros:
    """Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso"""
    cdef int Quantidade
    cdef bint Composto
    cdef double Periodo
    cdef double[0] Pagamentos
    cdef double[0] Pesos

    """Construtor que define as propriedades que não são matrizes"""
    def __init__(Juros self, int quantidade=0, bint composto=0, double periodo=30):
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo
    
    """inclui um pagamento"""
    cpdef void addPagamento(Juros self, double valor):
        self.Pagamentos.append(valor)

    """inclui um peso"""
    cpdef void addPeso(Juros self, double valor):
        self.Pesos.append(valor)

    """Retorna a soma total de todos os pesos"""
    cpdef double getpesototal(Juros self):
        cdef double acumulador = 0.0
        cdef int indice
        for indice in range(self.Quantidade):
            acumulador += self.Pesos[indice]
        return acumulador

    """Calcula o acréscimo a partir dos juros"""
    cpdef double jurosparaacrescimo(Juros self, double juros=0.0):
        cdef double pesototal = self.getpesototal()

        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or pesototal <= 0.0:
            return 0.0

        cdef double acumulador = 0.0
        cdef int indice

        for indice in range(self.Quantidade):
            if self.Composto == 1:
                acumulador += self.Pesos[indice] / ((1.0 + juros / 100.0) ** (self.Pagamentos[indice] / self.Periodo))
            else:
                acumulador += self.Pesos[indice] / (1.0 + juros / 100.0 * self.Pagamentos[indice] / self.Periodo)

        if acumulador <= 0.0:
            return 0.0

        return (pesototal / acumulador - 1.0) * 100.0

    """Calcula os juros a partir do acréscimo"""
    cpdef double acrescimoparajuros(Juros self, double acrescimo=0, int precisao=12, int maximointeracoes=100, double maximojuros=50.0, bint acrescimocomovalororiginal=0):
        cdef double pesototal = self.getpesototal()

        if maximointeracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0 or acrescimo <= 0.0 or pesototal <= 0.0 or maximojuros <= 0.0:
            return 0.0

        cdef double minimojuros = 0.0
        cdef double mediojuros = 0.0
        cdef double minimadiferenca = 0.1 ** precisao

        if acrescimocomovalororiginal == 1:      # nesse caso, os pesos totais dão o valor cobrado e o acrescimo é o original
            acrescimo = 100.0 * (pesototal / acrescimo - 1.0)
            if acrescimo <= 0.0:
                return 0.0

        for indice in range(maximointeracoes):
            mediojuros = (minimojuros + maximojuros) / 2.0
            if (maximojuros - minimojuros) < minimadiferenca:
                return mediojuros
            if self.jurosparaacrescimo(mediojuros) <= acrescimo:       # if "mágico" da bisseção
                minimojuros = mediojuros
            else:
                maximojuros = mediojuros

        return mediojuros

# cria objeto juros da classe Juros.Juros e inicializa os atributos
cdef Juros juros = Juros(3, 1, 30.0)     # 1 = True

cdef int indice
for indice in range(3):
    juros.addPagamento(indice * 30.0)
    juros.addPeso(1.0)

# calcula e guarda os valores retornados pelos métodos
cdef double pesoTotal = juros.getpesototal()
cdef double acrescimoCalculado = juros.jurosparaacrescimo();
cdef double jurosCalculado = juros.acrescimoparajuros(acrescimoCalculado, 18)

# imprime os resultados
print("Peso total = " + str(pesoTotal))
print("Acrescimo = " + str(acrescimoCalculado))
print("Juros = " + str(jurosCalculado))
