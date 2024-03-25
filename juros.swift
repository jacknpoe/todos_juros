// Classe de cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 23/03/2024: versão feita no Online Swift Playground

import Foundation
// import UIKit

// Classe Juros, que contém os dados comuns, como Parcelas
class Juros {
    var Quantidade : Int = 0
    var Composto : Bool = false
    var Periodo : Double = 0.0
    var Pagamentos : [Double] = []
    var Pesos : [Double] = []

    // construtor com os dados comuns
    init (quantidade : Int, composto : Bool, periodo : Double, pagamentos : [Double], pesos : [Double]) {
        Quantidade = quantidade
        Composto = composto
        Periodo = periodo
        Pagamentos = pagamentos
        Pesos = pesos
    }

    // calcula a soma de todos os pesos
    func getPesoTotal() -> Double {
        var acumulador : Double = 0.0
        for indice in 0 ..< Quantidade {
            acumulador += Pesos[indice]
        }
        return acumulador
    }

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    func jurosParaAcrescimo(juros : Double) -> Double {
        if (juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0) {
            return 0.0
        }
        let pesoTotal = getPesoTotal()
        if (pesoTotal <= 0.0) {
            return 0.0
        }
        var acumulador : Double = 0.0
        var soZero : Bool = true

        for indice in 0 ..< Quantidade {
            if (Pagamentos[indice] > 0.0 && Pesos[indice] > 0.0) {
                soZero = false
            }
            if (Composto) {
                acumulador += Pesos[indice] / pow(1 + juros / 100, Pagamentos[indice] / Periodo)
            } else {
                acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo)
            }
        }

        if (soZero) {
            return 0.0
        }
        return (pesoTotal / acumulador - 1) * 100
    }

    // calcula os acréscimo a partir dos juros e dados comuns (como parcelas)
    func acrescimoParaJuros(acrescimo : Double, precisao : Int = 15, maxIteracoes : Int = 100, pMaxJuros : Double = 50.0) -> Double {
        if (maxIteracoes < 1 || Quantidade < 1 || precisao < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || pMaxJuros <= 0.0) {
            return 0.0
        }
        let pesoTotal = getPesoTotal()
        if (pesoTotal <= 0.0) {
            return 0.0
        }
        var minJuros : Double = 0.0
        var medJuros : Double = pMaxJuros / 2
        var maxJuros : Double = pMaxJuros
        var minDiferenca : Double = pow(0.1, Double(precisao))

        for indice in 1 ... maxIteracoes {
            medJuros = (minJuros + maxJuros) / 2
            if ((maxJuros - minJuros) < minDiferenca) {
                return medJuros
            }
            if (jurosParaAcrescimo(juros : medJuros) < acrescimo) {
                minJuros = medJuros
            } else {
                maxJuros = medJuros
            }
        }

        return medJuros
    }
}

// testa Juros
let juros : Juros = Juros(quantidade : 3, composto : true, periodo : 30.0, pagamentos : [30.0, 60.0, 90.0], pesos : [1.0, 1.0, 1.0])
print(juros.getPesoTotal())
print(juros.jurosParaAcrescimo(juros : 3.0))
print(juros.acrescimoParaJuros(acrescimo : juros.jurosParaAcrescimo(juros : 3.0), precisao : 15, maxIteracoes : 100, pMaxJuros : 50.0))
