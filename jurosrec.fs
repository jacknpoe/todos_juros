// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 09/08/2026: a partir da versão iterativa de F#, imutável (exceto arrrays) e recursiva
//        0.2: 15/08/2026: alterada para propiciar Tail Call Optimization

// classe com atributos básicos para simplificar as chamadas
type Juros(quantidade: int, composto: bool, periodo: double, pagamentos: double[], pesos: double[]) =
    class
        member this.Quantidade = quantidade
        member this.Composto = composto
        member this.Periodo = periodo
        member this.Pagamentos = pagamentos
        member this.Pesos = pesos

        // método recursivo que calcula a somatória de Pesos[]
        member this.rGetPesoTotal(indice: int, acumulador: double): double =
            if indice = this.Quantidade then
                acumulador
            else
                 this.rGetPesoTotal(indice + 1, acumulador + this.Pesos.[indice])

        // método açúcar que calcula a somatória de Pesos[]
        member this.getPesoTotal(): double =
            this.rGetPesoTotal(0, 0.0)

        // método recursivo que calcula a somatória das amortizações de juros compostos
        member this.rJurosCompostos(juros: double, indice: int, acumulador: double): double =
            if indice = this.Quantidade then
                acumulador
            else
                this.rJurosCompostos(juros, indice + 1, acumulador + this.Pesos.[indice] / (1.0 + juros / 100.0) ** (this.Pagamentos.[indice] / this.Periodo))

        // método recursivo que calcula a somatória das amortizações de juros simples
        member this.rJurosSimples(juros: double, indice: int, acumulador: double): double =
            if indice = this.Quantidade then
                acumulador
            else
                this.rJurosSimples(juros, indice + 1, acumulador + this.Pesos.[indice] / (1.0 + juros / 100.0 * this.Pagamentos.[indice] / this.Periodo))

        // método que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
        member this.jurosParaAcrescimo(juros: double): double =
            let pesoTotal: double = this.rGetPesoTotal(0, 0.0)
            if juros <= 0.0 || this.Quantidade < 1 || this.Periodo < 0.0 || pesoTotal <= 0 then
                0.0
            else
                (pesoTotal / (if this.Composto then this.rJurosCompostos(juros, 0, 0.0) else this.rJurosSimples(juros, 0, 0.0)) - 1.0) * 100.0

        // método recursivo que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
        member this.rAcrescimoParaJuros(acrescimo: double, minDiferenca: double, iteracao: int, minJuros: double, maxJuros: double, medJuros: double) =
            if iteracao < 1 || maxJuros - minJuros <= minDiferenca then
                medJuros
            else
                if this.jurosParaAcrescimo(medJuros) < acrescimo then
                    this.rAcrescimoParaJuros(acrescimo, minDiferenca, iteracao - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
                else
                    this.rAcrescimoParaJuros(acrescimo, minDiferenca, iteracao - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

        // método açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
        member this.acrescimoParaJuros(acrescimo: double, precisao: int, maxIteracoes: int, maxJuros: double): double =
            if acrescimo <= 0.0 || this.Quantidade < 1 || this.Periodo < 0.0 || this.rGetPesoTotal(0, 0.0) <= 0.0 || maxIteracoes < 1 || precisao < 1 || maxJuros <= 0.0 then
                0.0
            else
                this.rAcrescimoParaJuros(acrescimo, 0.1 ** double precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)
    end

// função recursiva que inicializa o array Pagamentos
let rec rSetPagamentos(juros: Juros, indice: int) =
    if indice < juros.Quantidade then
        juros.Pagamentos.[indice] <- double (indice + 1) * juros.Periodo
        rSetPagamentos(juros, indice + 1)

// função açúcar que inicializa o array Pagamentos
let setPagamentos(juros: Juros) =
    rSetPagamentos(juros, 0)

// função recursiva que inicializa o array Pesos
let rec rSetPesos(juros: Juros, indice: int) =
    if indice < juros.Quantidade then
        juros.Pesos.[indice] <- 1.0
        rSetPesos(juros, indice + 1)

// função açúcar que inicializa o array Pagamentos
let setPesos(juros: Juros) =
    rSetPesos(juros, 0)

[<EntryPoint>]
let main argv =
    // variáveis para legibilidade e inicialização de escalares; altere aqui os parâmetros para criar juros
    let Quantidade: int = 3
    let Composto: bool = true
    let Periodo: double = 30.0
    let Pagamentos : double[] = Array.zeroCreate Quantidade
    let Pesos : double[] = Array.zeroCreate Quantidade

    // cria o objeto juros da classe Juros e define os valores escalares
    let juros = Juros(Quantidade, Composto, Periodo, Pagamentos, Pesos)

    // define os valores para os elementos dos arrays Pagamentos e Pesos
    setPagamentos(juros)
    setPesos(juros)

    // calcula e guarda os resultados das funções
    let pesoTotal = juros.getPesoTotal()
    let acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
    let jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

    // testa as funções
    printfn "Peso total = %2.14f" pesoTotal
    printfn "Acréscimo = %2.14f" acrescimoCalculado
    printfn "Juros = %2.14f" jurosCalculado
    0
