// Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
// Versão: 0.1: 17/03/2026: feita sem muito conhecimento de Hare

use fmt;
use math;

// variáveis globais para simplificar as chamadas às funções e inicialização de escalares
let Quantidade: i64 = 3;
let Composto: bool = true;
let Periodo: f64 = 30.0;
let Pagamentos: []f64 = [];
let Pesos: []f64 = [];

// calcula a somatória dos elementos no slice Pesos[]
fn getPesoTotal() f64 = {
    let acumulador: f64 = 0.0;
    for(let indice: i64 = 0; indice < Quantidade; indice += 1) {
        acumulador += Pesos[indice];
    };
    return acumulador;
};

// calcula o acréscimo a partir dos juros e parcelas
fn jurosParaAcrescimo(juros: f64) f64 = {
    let pesoTotal: f64 = getPesoTotal();
    if(Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) return 0.0;
    let acumulador: f64 = 0.0;

    for(let indice: i64 = 0; indice < Quantidade; indice += 1) {
        if (Composto) 
            acumulador += Pesos[indice] / math::powf64(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
        else
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
    };

    if(acumulador <= 0.0) return 0.0;
    return (pesoTotal / acumulador - 1.0) * 100.0;
};

// calcula os juros a partir do acréscimo e parcelas
fn acrescimoParaJuros(acrescimo: f64, precisao: i64, maxIteracoes: i64, maxJuros: f64) f64 = {
    let pesoTotal: f64 = getPesoTotal();
    if(Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
    let minJuros: f64 = 0.0;
    let medJuros: f64 = maxJuros / 2.0;
    let minDiferenca: f64 = math::powf64(0.1, precisao: f64);

    for(let iteracao: i64 = 0; iteracao < maxIteracoes; iteracao += 1) {
        if(maxJuros - minJuros < minDiferenca) return medJuros;
        if(jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros else maxJuros = medJuros;
        medJuros = (minJuros + maxJuros) / 2.0;
    };

    return medJuros;
};

export fn main() void = {
    // inicialização dos slices Pagamentos[] e Pesos[]
    for(let indice: i64 = 1; indice <= Quantidade; indice += 1) {
        append(Pagamentos, (indice :f64) * Periodo);
        append(Pesos, 1.0);
    };

    // calcula e guarda os resultados das funções
    let pesoTotal: f64 = getPesoTotal();
    let acrescimoCalculado: f64 = jurosParaAcrescimo(3.0);
    let jurosCalculado: f64 = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);

    // imnprime os resultados
    fmt::println("Peso total =", pesoTotal)!;
    fmt::println("Acréscimo =", acrescimoCalculado)!;
    fmt::println("Juros =", jurosCalculado)!;
};
