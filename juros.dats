// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 22/06/2026: versão feita sem muito conhecimento de ATS2
//        0.2: 10/07/2026: simplificado cases de rJurosCompostos e rJurosSimples, de getPamentos para getPagamentos
//        0.3: 15/08/2026: alteradas rGeraPagamentos, rGeraPesos, rGetPesoTotal, rJurosCompostos e rJurosSimples para propiciar Tail Call Optimization
// COMPILAR COM: patscc -O3 -DATS_MEMALLOC_LIBC juros.dats -o juros -lm
// a solução foi testada até 300.000 parcelas mas, ATÉ A VERSÃO 0.2, é necessário fazer ulimit -s 65536

#include "share/atspre_staload.hats"

staload "libats/ML/SATS/basis.sats"
staload "libats/libc/SATS/math.sats"
staload _ = "libats/libc/DATS/math.dats"

// variáveis escalares globais, para simplificar as chamadas às funções
val Quantidade : int = 300000
val Composto : bool = true
val Periodo : double = 30.0

// função recursiva que cria a lista Pagamentos
fun rGeraPagamentos (indice: int, acumulador : list0(double)) : list0(double) =
    if indice > 0 then rGeraPagamentos(indice - 1, cons0(g0int2float(indice) * Periodo, acumulador))
    else acumulador

// função açúcar que cria a lista Pagamentos
fun geraPagamentos () : list0(double) = rGeraPagamentos(Quantidade, nil0)

// função recursiva que cria a lista Pagamentos
fun rGeraPesos (indice: int, acumulador : list0(double)) : list0(double) =
    if indice > 0 then rGeraPesos(indice - 1, cons0(1.0, acumulador))
    else acumulador

// função açúcar que cria a lista Pagamentos
fun geraPesos () : list0(double) = rGeraPesos(Quantidade, nil0)

// listas globais, para simplificar as chamadas às funções
val Pagamentos : list0(double) = geraPagamentos()
val Pesos : list0(double) = geraPesos()

// função recursiva que calcula a somatória dos elementos em Pesos
fun rGetPesoTotal (pesos : list0(double), acumulador : double) : double =
    case+ pesos of
        | nil0 () => acumulador
        | cons0 (pesH, pesT) => rGetPesoTotal(pesT, acumulador + pesH)

// função açúcar que calcula a somatória dos elementos em Pesos
fun getPesoTotal () : double = rGetPesoTotal(Pesos, 0.0)

// função recursiva que calcula a somatória das amortizações em juros compostos
fun rJurosCompostos (juros : double, pagamentos : list0(double), pesos : list0(double), acumulador : double) : double =
    case+ (pagamentos, pesos) of
        | (cons0 (pagH, pagT), cons0 (pesH, pesT)) => rJurosCompostos(juros, pagT, pesT, acumulador + pesH / pow(1.0 + juros / 100.0, pagH / Periodo))
        | (_, _) => acumulador

// função recursiva que calcula a somatória das amortizações em juros simples
fun rJurosSimples (juros : double, pagamentos : list0(double), pesos : list0(double), acumulador : double) : double =
    case+ (pagamentos, pesos) of
        | (cons0 (pagH, pagT), cons0 (pesH, pesT)) => rJurosSimples(juros, pagT, pesT, acumulador + pesH / (1.0 + juros / 100.0 * pagH / Periodo))
        | (_, _) => acumulador

// função que calcula o acréscimo a partir dos juros e parcelas (com algum açúcar)
fun jurosParaAcrescimo (juros : double) : double =
    if Composto then (getPesoTotal() / rJurosCompostos(juros, Pagamentos, Pesos, 0.0) - 1.0) * 100.0
                else (getPesoTotal() / rJurosSimples(juros, Pagamentos, Pesos, 0.0) - 1.0) * 100.0

// função recursiva que calcula os juros a partir do acréscimo e parcelas
fun rAcrescimoParaJuros (acrescimo : double, minDiferenca : double, iteracao : int, minJuros : double, maxJuros : double, medJuros : double) : double =
    if iteracao = 0 || maxJuros - minJuros < minDiferenca then medJuros
        else if jurosParaAcrescimo(medJuros) < acrescimo
            then rAcrescimoParaJuros(acrescimo, minDiferenca, iteracao - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
            else rAcrescimoParaJuros(acrescimo, minDiferenca, iteracao - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)

// função açúcar que calcula o acréscimo a partir dos juros e parcelas
fun acrescimoParaJuros (acrescimo : double, precisao : int, maxIteracoes : int, maxJuros : double ) : double =
    rAcrescimoParaJuros (acrescimo, pow(0.1, g0int2float(precisao)), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

implement
main0 () = {
    // calcula e guarda os resultados das funções
    val pesoTotal = getPesoTotal()
    val acrescimoCalculado = jurosParaAcrescimo(3.0)
    val jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

    // imprime os resultados (usando printf para ter 15 casas decimais)
    val _ = $extfcall(int, "printf", "Peso total = %.15f\n", pesoTotal)
    val _ = $extfcall(int, "printf", "Acréscimo = %.15f\n", acrescimoCalculado)
    val _ = $extfcall(int, "printf", "Juros = %.15f\n", jurosCalculado)
}
