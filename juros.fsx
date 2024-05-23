// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 23/05/2024: versão feita sem muito conhecimento de F#

// classe com atributos básicos para simplificar as chamadas
type Juros(quantidade: int, composto: bool, periodo: double, pagamentos: double[], pesos: double[]) =
    class
        member this.Quantidade = quantidade
        member this.Composto = composto
        member this.Periodo = periodo
        member this.Pagamentos = pagamentos
        member this.Pesos = pesos

        // calcula a somatória de Pesos[]
        member this.getPesoTotal(): double =
            let mutable acumulador: double = 0.0
            for indice in 0 .. this.Quantidade - 1 do
                acumulador <- acumulador + this.Pesos.[indice]
            acumulador

        // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
        member this.jurosParaAcrescimo(juros: double): double =
            let pesoTotal: double = this.getPesoTotal()
            if juros <= 0.0 || this.Quantidade < 1 || this.Periodo < 0.0 || pesoTotal <= 0 then 0.0
            else
                let mutable acumulador: double = 0.0
                for indice in 0 .. this.Quantidade - 1 do
                    if this.Composto then acumulador <- acumulador + this.Pesos.[indice] / (1.0 + juros / 100.0) ** (this.Pagamentos.[indice] / this.Periodo)
                        else acumulador <- acumulador + this.Pesos.[indice] / (1.0 + juros / 100.0 * this.Pagamentos.[indice] / this.Periodo)
                (pesoTotal / acumulador - 1.0) * 100.0

        // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
        member this.acrescimoParaJuros(acrescimo: double, precisao: double, maxIteracoes: int, maximoJuros: double): double =
            let pesoTotal: double = this.getPesoTotal()
            if acrescimo <= 0.0 || this.Quantidade < 1 || this.Periodo < 0.0 || pesoTotal <= 0 || maxIteracoes < 1 || precisao < 1 || maximoJuros <= 0.0 then 0.0
            else
                let mutable minJuros: double = 0.0
                let mutable medJuros: double = maximoJuros / 2.0
                let mutable maxJuros: double = maximoJuros
                let minDiferenca: double = 0.1 ** precisao
                let mutable indice: int = 0
                while (maxJuros - minJuros) > minDiferenca && indice < maxIteracoes do
                    medJuros <- (minJuros + maxJuros) / 2.0
                    if this.jurosParaAcrescimo(medJuros) < acrescimo then minJuros <- medJuros else maxJuros <- medJuros
                    indice <- indice + 1
                medJuros 
    end

// cria o objeto juros da classe Juros e define os valores
let juros = Juros(3, true, 30.0, [|30.0; 60.0; 90.0|], [|1.0; 1.0; 1.0|])

// testa as funções
printfn "Peso total = %2.13f" (juros.getPesoTotal())
printfn "Acréscimo = %2.13f" (juros.jurosParaAcrescimo(3.0))
printfn "Juros = %2.13f" (juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15.0, 100, 50.0))