// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 08/01/2025: versão feita sem muito conhecimento de Q#

import Std.Convert.*;

/// estrutura básica de propriedades para simplificar as chamadas
struct Juros {
    quantidade : Int,
    composto : Bool,
    periodo : Double,
    pagamentos : Double[],
    pesos : Double[],
}

/// calcula a somatória do array Pesos[]
function getPesoTotal (oJuros : Juros) : Double {
    mutable acumulador : Double = 0.0;
    for indice in 0..oJuros.quantidade - 1 {
        acumulador += oJuros.pesos[indice];
    }
    return acumulador;
}

/// calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(oJuros : Juros, juros : Double) : Double {
    let pesoTotal : Double = getPesoTotal(oJuros);
    if juros <= 0.0 or oJuros.quantidade < 1 or oJuros.periodo <= 0.0 or pesoTotal <= 0.0 { return 0.0; }

    mutable acumulador : Double = 0.0;

    for indice in 0..oJuros.quantidade - 1 {
        if oJuros.composto {
            acumulador += oJuros.pesos[indice] / (1.0 + juros / 100.0) ^ (oJuros.pagamentos[indice] / oJuros.periodo);
        } else {
            acumulador += oJuros.pesos[indice] / (1.0 + juros / 100.0 * oJuros.pagamentos[indice] / oJuros.periodo);
        }
    }

    if acumulador <= 0.0 { return 0.0; }
    return (pesoTotal / acumulador - 1.0) * 100.0;
}

/// calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(oJuros : Juros, acrescimo : Double, precisao : Int, maxIteracoes : Int, maximoJuros : Double) : Double {
    let pesoTotal : Double = getPesoTotal(oJuros);
    if maxIteracoes < 1  or oJuros.quantidade < 1 or precisao < 1 or oJuros.periodo <= 0.0 or acrescimo <= 0.0 or maximoJuros <= 0.0 or pesoTotal <= 0.0
        { return 0.0; }

    mutable minJuros : Double = 0.0;
    mutable medJuros : Double = maximoJuros / 2.0;
    mutable maxJuros : Double = maximoJuros;
    let minDiferenca : Double = 0.1 ^ IntAsDouble(precisao);

    for indice in 1..maxIteracoes {
        medJuros = (minJuros + maxJuros) / 2.0;
        if (maxJuros - minJuros) < minDiferenca { return medJuros; }
        if jurosParaAcrescimo(oJuros, medJuros) < acrescimo {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
    }

    return medJuros;
}

function Main () : () {
    // cria um objeto juros da estrutura Juros
    let oJuros = Juros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0]);

    // calcula e guarda os retornos das funções
    let pesoTotal : Double = getPesoTotal(oJuros);
    let acrescimo : Double = jurosParaAcrescimo(oJuros, 3.0);
    let juros : Double = acrescimoParaJuros(oJuros, acrescimo, 15, 100, 50.0);

    // imprime os resultados
    Message($"Peso total = {pesoTotal}");
    Message($"Acréscimo = {acrescimo}");
    Message($"Juros = {juros}");
}
