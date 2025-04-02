// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 02/04/2025: versão feita sem muito conhecimento de Wren

// classe com atributos para simplificar as chamadas aos métodos
class cJuros {
    // os atributos escalares são inicializados no construtor
    construct new(quantidade, composto, periodo) {
        _quantidade = quantidade
        _composto = composto
        _periodo = periodo
        _pagamentos = []
        _pesos = []
    }

    // acesso (gets e sets) aos atributos escalares
    quantidade { _quantidade }
    quantidade = (valor) { _quantidade = valor }

    composto { _composto }
    composto = (valor) { _composto = valor }

    periodo { _periodo }
    periodo = (valor) { _periodo = valor }

    // inserir, definir e consultar atributos listas
    putPagamento(valor) { _pagamentos.add(valor) }
    setPagamento(indice, valor) { _pagamentos[indice] = valor }
    getPagamento(indice) { _pagamentos[indice] }

    putPeso(valor) { _pesos.add(valor) }
    setPeso(indice, valor) { _pesos[indice] = valor }
    getPeso(indice) { _pesos[indice] }

    // calcula a somatória de Pesos[]
    getPesoTotal() {
        var acumulador = 0.0
        var indice
        for(indice in 0.._quantidade-1) acumulador = acumulador + _pesos[indice]
        return acumulador
    }

    // calcula o acréscimo a partir dos juros e parcelas
    jurosParaAcrescimo(juros) {
        var pesoTotal = this.getPesoTotal()
        if(_quantidade < 1 || _periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) return 0.0

        var acumulador = 0.0
        var indice
        for(indice in 0.._quantidade-1) {
            if(_composto) {
                acumulador = acumulador + _pesos[indice] / (1.0 + juros / 100.0).pow(_pagamentos[indice] / _periodo)
            } else {
                acumulador = acumulador + _pesos[indice] / (1.0 + juros / 100.0 * _pagamentos[indice] / _periodo)
            }
        }
        if(acumulador <= 0.0) return 0.0
        return (pesoTotal / acumulador - 1.0) * 100.0
    }

    // calcula os juros a partir do acréscimo e parcelas
    acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
        var pesoTotal = this.getPesoTotal()
        if(_quantidade < 1 || _periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0

        var minJuros = 0.0
        var medJuros = maxJuros / 2.0
        var minDiferenca = (0.1).pow(precisao)
        var indice
        for(indice in 1..maxIteracoes) {
            if(maxJuros - minJuros < minDiferenca) return medJuros
            if(this.jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros else maxJuros = medJuros
            medJuros = (minJuros + maxJuros) / 2.0
        }
        return medJuros
    }
}

// cria um objeto juros da classe cJuros e inicializa os valores
var juros = cJuros.new(3, true, 30.0)

// as listas são inicializadas de forma dinâmica
var indice
for(indice in 0..juros.quantidade-1) {
    juros.putPagamento((indice + 1) * juros.periodo)
    juros.putPeso(1)
}

// calcula e guarda os resultados dos métodos
var pesoTotal = juros.getPesoTotal()
var acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
var jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
System.print("Peso total =  %(pesoTotal)")
System.print("Acrescimo =  %(acrescimoCalculado)")
System.print("Juros =  %(jurosCalculado)")