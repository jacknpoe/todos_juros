# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 18/03/2026: alternativa que usa funções no lugar de listas para benchmark
#         0.2: 20/08/2026: versão com head/tail e permitindo Tail Call Optimization
# compilável (por causa de Num.log em Num.pow, aparentemente) apenas com a opção --linker legacy
# a versão do compilador é a alpha4 disponível em https://github.com/roc-lang/roc/releases

app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }
import pf.Stdout

# "variáveis" globais simplificam as chamadas às funções
quantidade : U64
quantidade = 300000
composto : Bool
composto = Bool.true
periodo : F64
periodo = 30.0

# função que retorna pagamentos[indice]
pagamentos : U64 -> F64
pagamentos = |indice|
    Num.to_f64(indice + 1) * periodo

# função que retorna pesos[indice]
pesos : U64 -> F64
pesos = |_|
    1.0

# função recursiva que calcula a somatória dos elementos da lista pesos
rGetPesoTotal : U64, F64 -> F64
rGetPesoTotal = |indice, acumulador|
    if indice < 1 then
        acumulador
    else
        rGetPesoTotal(indice - 1, acumulador + pesos(indice - 1))

# função açúcar que calcula a somatória dos elementos da lista pesos
getPesoTotal : U64 -> F64
getPesoTotal = |_| rGetPesoTotal(quantidade, 0.0)

# função recursiva que calcula o acumulado do amortecimento dos juros compostos
rJurosCompostos : F64, U64, F64 -> F64
rJurosCompostos = |juros, indice, acumulador|
    if indice < 1 then
        acumulador
    else
        rJurosCompostos(juros, indice - 1, acumulador + pesos(indice - 1) / Num.pow(1.0 + juros / 100.0, pagamentos(indice - 1) / periodo))

# função recursiva que calcula o acumulado do amortecimento dos juros simples
rJurosSimples : F64, U64, F64 -> F64
rJurosSimples = |juros, indice, acumulador|
    if indice < 1 then
        acumulador
    else
        rJurosSimples(juros, indice - 1, acumulador + pesos(indice - 1) / (1.0 + juros / 100.0 * pagamentos(indice - 1) / periodo))

# função açúcar que calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo : F64 -> F64
jurosParaAcrescimo = |juros|
    if composto then
        (getPesoTotal(0) / rJurosCompostos(juros, quantidade, 0.0) - 1.0) * 100.0
    else
        (getPesoTotal(0) / rJurosSimples(juros, quantidade, 0.0) - 1.0) * 100.0

# função recursiva que calcula os juros a partir do acréscimo e parcelas
rAcrescimoParaJuros : F64, F64, U64, F64, F64, F64 -> F64
rAcrescimoParaJuros = |acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros|
    if iteracaoAtual < 1 || maxJuros - minJuros < minDiferenca then
        medJuros
    else
        if jurosParaAcrescimo(medJuros) < acrescimo then
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
        else
            rAcrescimoParaJuros(acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

# função açúcar que calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros : F64, U64, U64, F64 -> F64
acrescimoParaJuros = |acrescimo, precisao, maxIteracoes, maxJuros|
    rAcrescimoParaJuros(acrescimo, Num.pow(0.1, Num.to_f64(precisao)), maxIteracoes, 0.0, maxJuros,maxJuros / 2.0)

# definição das "varíaveis" dos retornos das funções
pesoTotal : F64
pesoTotal = getPesoTotal(0)  # 0 = foo
acrescimoCalculado : F64
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado : F64
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

main! = |_args|
    when Stdout.line!("Peso total = ${Num.to_str(pesoTotal)}") is
        Ok(_) -> when Stdout.line!("Acréscimo = ${Num.to_str(acrescimoCalculado)}") is
            Ok(_) -> Stdout.line!("Juros = ${Num.to_str(jurosCalculado)}")
            Err(_) -> Stdout.line!("erro")
        Err(_) -> Stdout.line!("erro")
