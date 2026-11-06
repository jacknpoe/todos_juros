// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 30/06/2024: versão feita sem muito conhecimento de ReScript

// estrutura básica de propriedades para simplificar as chamadas
let quantidade: int = 3
let composto: bool = true
let periodo: float = 30.0
let pagamentos = [30.0, 60.0, 90.0]
let pesos = [1.0, 1.0, 1.0]

// função recursiva que realmente calcula a somatória de pesos[]
let rec rGetPesoTotal = (indice: int) => {
    if indice == 0 { Js.Array.unsafe_get(pesos, indice) }
        else { Js.Array.unsafe_get(pesos, indice) +. rGetPesoTotal(indice - 1) }
}

// perfume que calcula a somatória de pesos[]
let getPesoTotal = () => {
    rGetPesoTotal(quantidade - 1)
}

// calcula a soma do amortecimento de todas as parcelas para juros compostos
let rec rJurosCompostos = (indice: int, juros: float) => {
    if indice == 0 { Js.Array.unsafe_get(pesos, indice) /. (1.0 +. juros /. 100.0) ** (Js.Array.unsafe_get(pagamentos, indice) /. periodo) }
        else { Js.Array.unsafe_get(pesos, indice) /. (1.0 +. juros /. 100.0) ** (Js.Array.unsafe_get(pagamentos, indice) /. periodo) +. rJurosCompostos(indice - 1, juros) }
}

// calcula a soma do amortecimento de todas as parcelas para juros simples
let rec rJurosSimples = (indice: int, juros: float) => {
    if indice == 0 { Js.Array.unsafe_get(pesos, indice) /. (1.0 +. juros /. 100.0 *. Js.Array.unsafe_get(pagamentos, indice) /. periodo) }
        else { Js.Array.unsafe_get(pesos, indice) /. (1.0 +. juros /. 100.0 *. Js.Array.unsafe_get(pagamentos, indice) /. periodo) +. rJurosSimples(indice - 1, juros) }
}

// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
let jurosParaAcrescimo = (juros: float) => {
    if composto { (getPesoTotal() /. rJurosCompostos(quantidade - 1, juros) -. 1.0) *. 100.0 }
        else { (getPesoTotal() /. rJurosSimples(quantidade - 1, juros) -. 1.0) *. 100.0 }
}

// função recursiva no lugar de um for que realmente calcula os juros
let rec rAcrescimoParaJuros = (acrescimo: float, minDiferenca: float, iteracaoAtual: int, minJuros: float, maxJuros: float, medJuros: float) => {
    if iteracaoAtual == 0 || (maxJuros -. minJuros) < minDiferenca { medJuros }
        else {
            if jurosParaAcrescimo(medJuros) < acrescimo {
                rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros +. maxJuros) /. 2.0)
            } else {
                rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros +. medJuros) /. 2.0)
            }
        }
}

// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
let acrescimoParaJuros = (acrescimo: float, precisao: int, maxIteracoes: int, maxJuros: float) => {
    rAcrescimoParaJuros(acrescimo, 0.1 ** (precisao :> float), maxIteracoes, 0.0, maxJuros, maxJuros /. 2.0)
}

// calcula e guarda o resultado das funções
let pesoTotal = getPesoTotal()
let acrescimoCalculado = jurosParaAcrescimo(3.0)
let jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
Js.log(`Peso total = ${Belt.Float.toString(pesoTotal)}`)
Js.log(`Acréscimo = ${Belt.Float.toString(acrescimoCalculado)}`)
Js.log(`Juros = ${Belt.Float.toString(jurosCalculado)}`)