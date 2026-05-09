# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 08/05/2026: feita sem muito conhecimento de Blade

# variáveis globais para simplificar as chamadas às funções e inicialização das escalares
var Quantidade = 3
var Composto = true
var Periodo = 30.0
var Pagamentos = []
var Pesos = []

# calcula a somatória dos elementos na lista Pesos[]
def getPesoTotal() {
    var acumulador = 0.0
    for indice in 0..Quantidade {
        acumulador += Pesos[indice]
    }
    return acumulador
}

# calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo(juros) {
    var pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 {
        return 0.0
    }
    var acumulador = 0.0

    for indice in 0..Quantidade {
        if Composto {
            acumulador += Pesos[indice] / ((1.0 + juros / 100.0) ** (Pagamentos[indice] / Periodo))
        } else {
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
        }
    }

    if acumulador <= 0.0 {
        return 0.0
    }
    return (pesoTotal / acumulador - 1.0) * 100.0
}

# calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
    var pesoTotal = getPesoTotal()
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 {
        return 0.0
    }
    var minJuros = 0.0
    var medJuros = maxJuros / 2.0
    var minDiferenca = 0.1 ** precisao

    for indice in 0..maxIteracoes {
        if maxJuros - minJuros <= minDiferenca {
            return medJuros
        }
        if jurosParaAcrescimo(medJuros) < acrescimo {
            minJuros = medJuros
        } else {
            maxJuros = medJuros
        }
        medJuros = (minJuros + maxJuros) / 2.0
    }

    return medJuros
}

#var potencia = base ** expoente

# inicialização dos elementos nas listas globais
for indice in 0..Quantidade {
    Pagamentos.append((indice + 1.0) * Periodo)
    Pesos.append(1.0)
}

# calcula e guarda os resultados das funções
var pesoTotal = getPesoTotal()
var acrescimoCalculado = jurosParaAcrescimo(3.0)
var jurosAcumulador = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

# imprime os resultados
echo "Peso total = ${pesoTotal}"
echo "Acréscimo = ${acrescimoCalculado}"
echo "Juros = ${jurosAcumulador}"
