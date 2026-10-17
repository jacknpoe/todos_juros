# Cálculo do juros, sendo que precisa de listas pra isso
# Versão 0.1: 20/05/2024: versão em Mojo antigo, com literais atribuídas às listas
#        0.2: 16/10/2026: em Mojo 1.2.0rc2, listas escaláveis

from std.collections import List

# classe com os atributos, estrutura básica para simplificar as chamadas
struct Juros:
    var Quantidade: Int32
    var Composto: Bool
    var Periodo: Float64
    var Pagamentos: List[Float64]
    var Pesos: List[Float64]

    # método construtor, que inicializa os atributos
    def __init__(out self, quantidade: Int32, composto: Bool, periodo: Float64):
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo
        self.Pagamentos = List[Float64]()
        self.Pesos = List[Float64]()

    # retorna a somatória de Pesos[]
    def getPesoTotal(self) -> Float64:
        var acumulador: Float64 = 0.0
        for indice in range(self.Quantidade):
            acumulador += self.Pesos[indice]
        return acumulador
    
    # calcula o acréscimo a partir dos juros e prestações
    def jurosParaAcrescimo(self, juros: Float64) -> Float64:
        var pesoTotal: Float64 = self.getPesoTotal()
        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or pesoTotal <= 0.0:
            return 0.0
        var acumulador: Float64 = 0.0

        for indice in range(self.Quantidade):
            if self.Composto:
                acumulador += self.Pesos[indice] / (1.0 + juros / 100.0) ** (self.Pagamentos[indice] / self.Periodo)
            else:
                acumulador += self.Pesos[indice] / (1.0 + juros / 100.0 * self.Pagamentos[indice] / self.Periodo)

        return (pesoTotal / acumulador - 1.0) * 100.0

    # calcula os juros a partir do acréscimo e prestações
    def acrescimoParaJuros(self, acrescimo: Float64, precisao: Int, maxIteracoes: Int16, maximoJuros: Float64) -> Float64:
        var pesoTotal: Float64 = self.getPesoTotal()
        if maxIteracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0 or acrescimo <= 0.0 or maximoJuros <= 0.0 or pesoTotal <= 0.0:
            return 0.0
        var minJuros: Float64 = 0.0
        var medJuros: Float64 = maximoJuros / 2.0
        var maxJuros: Float64 = maximoJuros
        var minDiferenca: Float64 = 0.1 ** precisao
        
        for _ in range(maxIteracoes):
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca:
                return medJuros
            if self.jurosParaAcrescimo(medJuros) < acrescimo:
                minJuros = medJuros
            else:
                maxJuros = medJuros

        return medJuros

def main():
    # variáveis usadas na criação de juros
    var Quantidade: Int32 = 300000
    var Composto: Bool = True
    var Periodo: Float64 = 30.0

    # cria o objeto com as variáveis escalares
    var juros = Juros(Quantidade, Composto, Periodo)

    # acrescenta elementos nas listas Pagamentos e Pesos
    for indice in range(Quantidade):
        juros.Pagamentos.append((Float64(indice) + 1.0) * Periodo)
        juros.Pesos.append(1.0)

    # calcula e guarda os resultados das funções
    var pesoTotal: Float64 = juros.getPesoTotal()
    var acrescimoCalculado: Float64 = juros.jurosParaAcrescimo(3.0)
    var jurosCalculado: Float64 = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65,  50.0)

    # testa os retornos das funções
    print("Peso total =", pesoTotal)
    print("Acréscimo =", acrescimoCalculado)
    print("Juros =", jurosCalculado)
