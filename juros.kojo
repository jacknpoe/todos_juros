// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 14/03/2025: versão feita sem muito conhecimento de Kojo

// variáveis globais para simplificar as chamadas
val Quantidade = 3
val Composto = true
val Periodo = 30.0
var Pagamentos = Seq.empty[Double]
var Pesos = Seq.empty[Double]

// inicializa os arrays dinamicamente
repeatFor(1 to Quantidade) { indice =>
  Pagamentos = Pagamentos :+ 30.0 * indice
  Pesos = Pesos :+ 1.0
}

// calcula a somatória de Pesos()
def getPesoTotal(): Double = {
    var acumulador = 0.0
    repeatFor(0 to Quantidade - 1) { indice =>
        acumulador += Pesos(indice)
    }
    return acumulador
}

// calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo(juros: Double): Double = {
    val pesoTotal = getPesoTotal()
    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || juros <= 0.0) return 0.0

    var acumulador = 0.0
    repeatFor(0 to Quantidade - 1) { indice =>
        if(Composto) {
            acumulador += Pesos(indice) / math.pow(1.0 + juros / 100.0, Pagamentos(indice) / Periodo)
        } else {
            acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
        }
    }

    if(acumulador <= 0.0) return 0.0
    return (pesoTotal / acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros(acrescimo: Double, precisao: Int, maxIteracoes: Int, maximoJuros: Double): Double = {
    val pesoTotal = getPesoTotal()
    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0) return 0.0

    var minJuros = 0.0
    var medJuros = maximoJuros / 2.0
    var maxJuros = maximoJuros
    var minDiferenca = math.pow(0.1, precisao)
    repeatFor(1 to maxIteracoes) { indice =>
        medJuros = (minJuros + maxJuros) / 2.0
        if((maxJuros - minJuros) < minDiferenca) return medJuros
        if(jurosParaAcrescimo(medJuros) < acrescimo) { minJuros = medJuros } else { maxJuros = medJuros }
    }
    return medJuros
}

// apaga o painel de saída
clearOutput()

// calcula e guarda os resultados das funções
val pesoTotal = getPesoTotal()
val acrescimoCalculado = jurosParaAcrescimo(3.0)
val jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
println(s"Peso total = $pesoTotal")
println(s"Acréscimo = $acrescimoCalculado")
println(s"Juros = $jurosCalculado")
