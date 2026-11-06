// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 30/06/2024: versão feita sem muito conhecimento de ReScript
//             06/11/2026: Js.log para Console.log; Js.Array.unsafe_get para Array.getUnsafe; removidos casos especiais; arrays escaláveis dinamicamente preenchidos
//                         tipificação explícita de funções e arrays; avaliados variáveis, parâmetros e cálculos
//                         funções recursivas agora permitem Tail Call Optimization (TCO)

// estrutura básica de propriedades para simplificar as chamadas
let quantidade: int = 300000
let composto: bool = true
let periodo: float = 30.0
let pagamentos: array<float> = Array.make(~length=quantidade, 0.0)
let pesos: array<float> = Array.make(~length=quantidade, 0.0)

// função recursiva que preenche os elementos de Pagamentos[]
let rec rPreenchePagamentos = (indice: int): unit => {
    if indice >= 0 {
        pagamentos[indice] = ((indice + 1) :> float) * periodo
        rPreenchePagamentos(indice - 1)
    }
}

// função açúcar que preenche os elementos de Pagamentos[]
let preenchePagamentos = (): unit => { rPreenchePagamentos(quantidade - 1) }

// função recursiva que preenche os elementos de Pesos[]
let rec rPreenchePesos = (indice: int): unit => {
    if indice >= 0 {
        pesos[indice] = 1.0
        rPreenchePesos(indice - 1)
    }
}

// função açúcar que preenche os elementos de Pesos[]
let preenchePesos = (): unit => { rPreenchePesos(quantidade - 1) }

// função recursiva que calcula a somatória de pesos[]
let rec rGetPesoTotal = (indice: int, acumulador: float): float => {
    if indice < 0 { acumulador }
    else { rGetPesoTotal(indice - 1, Array.getUnsafe(pesos, indice) +. acumulador) }
}

// função açúcar que calcula a somatória de pesos[]
let getPesoTotal = (): float => { rGetPesoTotal(quantidade - 1, 0.0) }

// função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
let rec rJurosCompostos = (indice: int, juros: float, acumulador: float): float => {
    if indice < 0 { acumulador }
    else { rJurosCompostos(indice - 1, juros, Array.getUnsafe(pesos, indice) /. (1.0 +. juros /. 100.0) ** (Array.getUnsafe(pagamentos, indice) /. periodo) +. acumulador) }
}

// função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
let rec rJurosSimples = (indice: int, juros: float, acumulador: float): float => {
    if indice < 0 { acumulador }
    else { rJurosSimples(indice - 1, juros, Array.getUnsafe(pesos, indice) /. (1.0 +. juros /. 100.0 *. Array.getUnsafe(pagamentos, indice) /. periodo) +. acumulador) }
}

// função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
let jurosParaAcrescimo = (juros: float): float => {
    let pesoTotal: float = getPesoTotal()
    if quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 { 0.0 }
    else {
        let acumulador: float = if composto { rJurosCompostos(quantidade - 1, juros, 0.0) }
                                else { rJurosSimples(quantidade - 1, juros, 0.0) }
        if acumulador <= 0.0 { 0.0 }
        else { (pesoTotal /. acumulador -. 1.0) *. 100.0 }
    }
}

// função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
let rec rAcrescimoParaJuros = (acrescimo: float, minDiferenca: float, iteracaoAtual: int, minJuros: float, maxJuros: float, medJuros: float): float => {
    if iteracaoAtual == 0 || (maxJuros -. minJuros) <= minDiferenca { medJuros }
    else {
        if jurosParaAcrescimo(medJuros) < acrescimo {
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros +. maxJuros) /. 2.0)
        } else {
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros +. medJuros) /. 2.0)
        }
    }
}

// função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
let acrescimoParaJuros = (acrescimo: float, precisao: int, maxIteracoes: int, maxJuros: float): float => {
    let pesoTotal: float = getPesoTotal()
    if quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 { 0.0 }
    else { rAcrescimoParaJuros(acrescimo, 0.1 ** (precisao :> float), maxIteracoes, 0.0, maxJuros, maxJuros /. 2.0) }
}

// preenche os arrays Pagamentos[] e Pesos[]
preenchePagamentos()
preenchePesos()

// calcula e guarda o resultado das funções
let pesoTotal: float  = getPesoTotal()
let acrescimoCalculado: float  = jurosParaAcrescimo(3.0)
let jurosCalculado: float  = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
Console.log(`Peso total = ${Belt.Float.toString(pesoTotal)}`)
Console.log(`Acréscimo = ${Belt.Float.toString(acrescimoCalculado)}`)
Console.log(`Juros = ${Belt.Float.toString(jurosCalculado)}`)
