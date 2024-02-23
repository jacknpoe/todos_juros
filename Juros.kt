import kotlin.math.pow

class Juros (pQuantidade: Int, pComposto: Boolean, pPeriodo: Int) {
    private var quantidade: Int = 0
        set(value) {
            field = value
            pagamentos = Array(value){0}
            pesos = Array(value){0.0}
        }
    private var composto: Boolean = false
    private var periodo: Int = 30
    private var pagamentos: Array<Int> = emptyArray()
    private var pesos: Array<Double> = emptyArray()

    fun setValores(pQuantidade: Int, pComposto: Boolean, pPeriodo: Int) {
        quantidade = pQuantidade
        composto = pComposto
        periodo = pPeriodo
    }

    init {
        setValores(pQuantidade, pComposto, pPeriodo)
    }

    fun setPagamento(indice: Int, valor: Int) {
        pagamentos[indice] = valor
    }

    fun setPeso(indice: Int, valor: Double) {
        pesos[indice] = valor
    }

    fun getPesoTotal() : Double {
        var acumulador = 0.0
        for(valor in pesos) acumulador += valor
        return acumulador
    }

    fun jurosParaAcrescimo(juros: Double) : Double {
        if(juros <= 0 || quantidade <= 0 || periodo <= 0) return 0.0
        val pesoTotal = getPesoTotal()
        if(pesoTotal <= 0) return 0.0
        var acumulador = 0.0
        var soZero = true

        for(indice in 0..<quantidade) {
            if(pagamentos[indice] > 0 && pesos[indice] > 0) soZero = false
            acumulador += if(composto) {
                pesos[indice] / (1 + juros / 100).pow(pagamentos[indice] / periodo)
            } else {
                pesos[indice] / (1 + juros / 100 * pagamentos[indice] / periodo)
            }
        }

        if(soZero) return 0.0
        return(pesoTotal / acumulador - 1) * 100
    }

    fun acrescimoParaJuros(acrescimo: Double, precisao: Int = 15, maxIteracoes: Int = 100, topJuros: Double = 50.0) : Double {
        if(maxIteracoes < 1 || quantidade <= 0 || precisao < 1 || periodo <= 0 || acrescimo <=0 || topJuros <= 0) return 0.0
        var minJuros = 0.0
        var maxJuros = topJuros
        var medJuros = 0.0
        val minDiferenca = (0.1).pow(precisao)
        val pesoTotal = getPesoTotal()
        if(pesoTotal <= 0) return 0.0

        for(indice in 1..maxIteracoes) {
            medJuros = (minJuros + maxJuros) / 2
            if((maxJuros - minJuros) < minDiferenca) break
            if(jurosParaAcrescimo(medJuros) <= acrescimo) {
                minJuros = medJuros
            } else {
                maxJuros = medJuros
            }
        }
        return medJuros
    }
}