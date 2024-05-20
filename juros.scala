// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 20/05/2024: versão feita sem muito conhecimento de Scala

package Juros

import scala.math.pow
import scala.util.boundary, boundary.break

// classe com os valores comuns para simplificar as chamadas
class Juros( var Quantidade: Int, var Composto: Boolean, var Periodo: Double, var Pagamentos: Array[Double], var Pesos: Array[Double]) {
    // calcula a somatória de Pesos[]
    def getPesoTotal(): Double = {
        var acumulador: Double = 0.0
        for indice <- 0 to Quantidade - 1 do
            acumulador = acumulador + Pesos(indice)
        return acumulador
    }

    // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    def jurosParaAcrescimo(juros: Double): Double = {
        if(juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0) return 0.0
        val pesoTotal: Double = getPesoTotal()
        if(pesoTotal <= 0.0) return 0.0
        var acumulador: Double = 0.0

        for indice <- 0 to Quantidade - 1 do
            if(Composto) acumulador = acumulador + Pesos(indice) / pow(1.0 + juros / 100.0, Pagamentos(indice) / Periodo)
            else acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)

        if(acumulador <= 0.0) return 0.0
        return (pesoTotal / acumulador - 1.0) * 100.0
    }

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    def acrescimoParaJuros(acrescimo: Double, precisao: Int, maxIteracoes: Int, maximoJuros: Double): Double = {
        if(maxIteracoes < 1 || Quantidade <= 0.0 || precisao < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || maximoJuros <= 0.0) return 0.0
        val pesoTotal: Double = getPesoTotal()
        if(pesoTotal <= 0.0) return 0.0

        var minJuros: Double = 0.0
        var medJuros: Double = maximoJuros / 2.0
        var maxJuros: Double = maximoJuros
        var minDiferenca: Double = pow(0.1, precisao)

        boundary{
            for indice <- 1 to maxIteracoes do {
                medJuros = (minJuros + maxJuros) / 2.0
                if((maxJuros-minJuros) < minDiferenca) break()
                if(jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros else maxJuros = medJuros
            }
        }

        return medJuros
    }
}