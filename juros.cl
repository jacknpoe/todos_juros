// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 18/04/2025: versão feita sem muito conhecimento de Claire

// variáveis globais para simplificar as chamadas
Quantidade: integer :: 3
Composto: boolean :: true
Periodo: float :: 30.0
Pagamentos: list[float] :: list<float>()
Pesos: list[float] :: list<float>()

// inclui valores nas listas dinamicamente
setListas() -> (
    let indice := 1 in
        for indice in (1 .. Quantidade) (
            add(Pagamentos, indice * Periodo),
            add(Pesos, 1.0)
        )
)

// calcula a somatória de pesos[]
getPesoTotal() -> (
    let acumulador := 0.0 in (
        for indice in (1 .. Quantidade) acumulador :+ Pesos[indice],
        acumulador
    )
)

// calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo(juros: float) -> (
    let pesoTotal := getPesoTotal(), acumulador := 0.0 in (
        if (Quantidade < 1 | Periodo <= 0.0 | pesoTotal <= 0.0 | juros <= 0.0)
            0.0
        else
            let indice := 1 in (
                for indice in (1 .. Quantidade) (
                    if (Composto)
                        acumulador :+ Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
                    else
                        acumulador :+ Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
                )
            ),
            if (acumulador <= 0.0)
                0.0
            else
                (pesoTotal / acumulador - 1.0) * 100.0
    )
)

// calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros(acrescimo: float, precisao: integer, maxIteracoes: integer, maxJuros: float) -> (
    let pesoTotal := getPesoTotal(), minJuros := 0.0, medJuros := maxJuros / 2.0, minDiferenca := 0.1 ^ float!(precisao), indice := 0 in (
        if (Quantidade < 1 | Periodo <= 0.0 | pesoTotal <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0)
            0.0
        else
            while (indice < maxIteracoes) (
                if (maxJuros - minJuros < minDiferenca) indice := maxIteracoes,
                if (jurosParaAcrescimo(medJuros) < acrescimo) minJuros := medJuros else maxJuros := medJuros,
                medJuros := (minJuros + maxJuros) / 2.0,
                indice :+ 1
            ),
            medJuros
    )
)

main() -> (
    setListas(),
    // calcula e guarda os resultados das funções
    let pesoTotal := getPesoTotal(), acrescimoCalculado := jurosParaAcrescimo(3.0),
        jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0) in (
        printf("\nPeso total = ~S\n", pesoTotal),
        printf("Acréscimo = ~S\n", acrescimoCalculado),
        printf("Juros = ~S\n", jurosCalculado)
    )
)