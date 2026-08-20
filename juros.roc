# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 18/03/2026: feita sem muito conhecimento de Roc
#         0.2: 20/08/2026: versão com head/tail e permitindo Tail Call Optimization
# compilável (por causa de Num.log em Num.pow, aparentemente) apenas com a opção --linker legacy
# a versão do compilador é a alpha4 disponível em https://github.com/roc-lang/roc/releases

app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }
import pf.Stdout

# "variáveis" globais simplificam as chamadas às funções
quantidade : U64
quantidade = 3
composto : Bool
composto = Bool.true
periodo : F64
periodo = 30.0

# função recursiva que cria a lista Pagamentos
rCriaPagamentos : U64, List F64 -> List F64
rCriaPagamentos = |indice, acumulador|
    if indice < 1 then
        acumulador
    else
         rCriaPagamentos(indice - 1, List.append(acumulador, Num.to_f64(indice) * periodo))

# função açúcar que cria a lista Pagamentos
criaPagamentos : U64 -> List F64
criaPagamentos = |_| rCriaPagamentos(quantidade, [])

# função recursiva que cria a lista Pesos
rCriaPesos : U64, List F64 -> List F64
rCriaPesos = |indice, acumulador|
    if indice < 1 then
        acumulador
    else
        rCriaPesos(indice - 1, List.append(acumulador, 1.0))

# função açúcar que cria a lista Pesos
criaPesos : U64 -> List F64
criaPesos = |_| rCriaPesos(quantidade, [])

# define as listas pagamentos e pesos
pagamentos : List F64
pagamentos = criaPagamentos(0)  # 0 = foo
pesos : List F64
pesos = criaPesos(0)  # 0 = foo

# função recursiva que calcula a somatória dos elementos da lista pesos
rGetPesoTotal : List F64, F64 -> F64
rGetPesoTotal = |lista, acumulador|
    when lista is
        [] -> acumulador
        [hLis, .. as tLis] -> rGetPesoTotal(tLis, acumulador + hLis)

# função açúcar que calcula a somatória dos elementos da lista pesos
getPesoTotal : U64 -> F64
getPesoTotal = |_| rGetPesoTotal(pesos, 0.0)

# função recursiva que calcula o acumulado do amortecimento dos juros compostos
rJurosCompostos : F64, List F64, List F64, F64 -> F64
rJurosCompostos = |juros, pag, pes, acumulador|
    when (pag, pes) is
        ([], []) -> acumulador
        ([_, ..], []) -> acumulador
        ([], [_, ..]) -> acumulador
        ([hPag, .. as tPag], [hPes, .. as tPes]) -> rJurosCompostos(juros, tPag, tPes, acumulador + hPes / Num.pow(1.0 + juros / 100.0, hPag / periodo))

# função recursiva que calcula o acumulado do amortecimento dos juros simples
# função recursiva que calcula o acumulado do amortecimento dos juros compostos
rJurosSimples : F64, List F64, List F64, F64 -> F64
rJurosSimples = |juros, pag, pes, acumulador|
    when (pag, pes) is
        ([], []) -> acumulador
        ([_, ..], []) -> acumulador
        ([], [_, ..]) -> acumulador
        ([hPag, .. as tPag], [hPes, .. as tPes]) -> rJurosSimples(juros, tPag, tPes, acumulador + hPes / (1.0 + juros / 100.0 * hPag / periodo))

# função açúcar que calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo : F64 -> F64
jurosParaAcrescimo = |juros|
    if composto then
        (getPesoTotal(0) / rJurosCompostos(juros, pagamentos, pesos, 0.0) - 1.0) * 100.0
    else
        (getPesoTotal(0) / rJurosSimples(juros, pagamentos, pesos, 0.0) - 1.0) * 100.0

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
