from collections import List

# classe com os atributos, estrutura básica para simplificar as chamadas
struct Juros:
    var Quantidade: Int16
    var Composto: Bool
    var Periodo: Float64
    var Pagamentos: List[Float64]
    var Pesos: List[Float64]

    # método construtor, que inicializa os atributos
    fn __init__(inout self, quantidade: Int16, composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64]):
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo
        self.Pagamentos = pagamentos
        self.Pesos = pesos

    # retorna a somatória de Pesos[]
    fn getPesoTotal(inout self) -> Float64:
        var acumulador: Float64 = 0.0
        for indice in range(self.Quantidade):
            acumulador += self.Pesos[indice]
        return acumulador
    
    # calcula o acréscimo a partir dos juros e prestações
    fn jurosParaAcrescimo(inout self, juros: Float64) -> Float64:
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
    fn acrescimoParaJuros(inout self, acrescimo: Float64, precisao: Int, maxIteracoes: Int16, maximoJuros: Float64) -> Float64:
        var pesoTotal: Float64 = self.getPesoTotal()
        if maxIteracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0 or acrescimo <= 0.0 or maximoJuros <= 0.0 or pesoTotal <= 0.0:
            return 0.0
        var minJuros: Float64 = 0.0
        var medJuros: Float64 = maximoJuros / 2.0
        var maxJuros: Float64 = maximoJuros
        var minDiferenca: Float64 = 0.1 ** precisao
        
        for indice in range(maxIteracoes):
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca:
                return medJuros
            if self.jurosParaAcrescimo(medJuros) < acrescimo:
                minJuros = medJuros
            else:
                maxJuros = medJuros

        return medJuros


fn main():
    # cria o objeto com os dados
    var juros = Juros(3, True, 30.0, List[Float64](30.0, 60.0, 90.0), List[Float64](1.0, 1.0, 1.0))

    # testa os retornos das funções
    print("Peso total =", juros.getPesoTotal())
    print("Acréscimo =", juros.jurosParaAcrescimo(3.0))
    print("Juros =", juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15, 100, 50.0))