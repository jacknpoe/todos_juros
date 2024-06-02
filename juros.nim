# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 02/06/2024: versão feita sem muito conhecimento de Nim

import std/math, strformat

# classe com os atributos com a estrutura básica para simplificar as chamadas
type
    Juros = object
        quantidade*: int
        composto*: bool
        periodo*: float64
        pagamentos*: seq[float64]
        pesos*: seq[float64]

# calcula a somatória de Pesos[]
proc getPesoTotal(self: Juros): float64 =
    var acumulador: float64 = 0.0
    for indice in countup(0, self.quantidade - 1):
        acumulador += self.pesos[indice]
    return acumulador

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
proc jurosParaAcrescimo(self: Juros, juros: float64): float64 =
    var pesoTotal: float64 = self.getPesoTotal()
    if juros <= 0.0 or self.quantidade < 1 or self.periodo <= 0.0 or pesoTotal <= 0.0:
        return 0.0
    var acumulador: float64 = 0.0

    for indice in countup(0, self.quantidade - 1):
        if self.composto:
            acumulador += self.pesos[indice] / pow(1.0 + juros / 100.0, self.pagamentos[indice] / self.periodo)
        else:
            acumulador += self.pesos[indice] / (1.0 + juros / 100.0 * self.pagamentos[indice] / self.periodo)
    
    return (pesoTotal / acumulador - 1.0) * 100.0

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
proc acrescimoParaJuros(self: Juros, acrescimo: float64, precisao: int, maxIteracoes: int, maximoJuros: float64): float64 =
    var pesoTotal: float64 = self.getPesoTotal()
    if maxIteracoes < 1 or self.quantidade < 1 or precisao < 1 or self.periodo <= 0.0 or acrescimo <= 0.0 or maximoJuros <= 0.0 or pesoTotal <= 0.0:
        return 0.0
    var minJuros: float64 = 0.0
    var medJuros: float64 = maximoJuros / 2.0
    var maxJuros: float64 = maximoJuros
    var minDiferenca: float64 = pow(0.1, toFloat(precisao))

    for indice in countup(1, maxIteracoes):
        medJuros = (minJuros + maxJuros) / 2.0
        if (maxJuros - minJuros) < minDiferenca:
            return medJuros
        if self.jurosParaAcrescimo(medJuros) < acrescimo:
            minJuros = medJuros
        else:
            maxJuros = medJuros

    return medJuros

# cria objeto juros da classe Juros e define os valores
var juros = Juros(quantidade: 3, composto: true, periodo: 30.0, pagamentos: @[30.0, 60.0, 90.0], pesos: @[1.0, 1.0, 1.0])

# testa os resultados das funções
echo &"Peso total = {juros.getPesoTotal()}!"
echo &"Acréscimo = {juros.jurosParaAcrescimo(3.0)}!"
echo &"Juros = {juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15, 100, 50.0)}!"