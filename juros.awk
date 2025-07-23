# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 19/06/2024: versão feita sem muito conhecimento de AWK
#             23/07/2025: retirados "!' e comentário sem importância de um teste inicial

# calcula a somatória de Pesos[]
function getPesoTotal() {
    acumulador = 0.0;
    for(indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
    return acumulador;
}

# calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros) {
    pesoTotal = getPesoTotal();
    if(juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
    acumulador = 0.0;

    for(indice = 0; indice < Quantidade; indice++) {
        if(Composto == 1){
            acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo);
        } else {
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        }
    }
    return (pesoTotal / acumulador - 1.0) * 100.0;
}

# calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
    pesoTotal = getPesoTotal();
    if(acrescimo <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
    minJuros = 0.0;
    medJuros = maxJuros / 2.0;
    minDiferenca = 0.1 ^ precisao;

    for(indice = 0; indice < maxIteracoes; indice++) {
        medJuros = (minJuros + maxJuros) / 2.0;
        if((maxJuros - minJuros) < minDiferenca) return medJuros;
        if(jurosParaAcrescimo(medJuros) < acrescimo) {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
    }

    return medJuros;
}

BEGIN {
    # variáveis básicas para simplificar as chamadas
    Quantidade = 3;
    Composto = 1;
    Periodo = 30.0;

    # arrays para simplificar as chamadas
    for(indice = 0; indice < Quantidade; indice++) {
        Pagamentos[indice] = (indice + 1.0) * 30.0;
        Pesos[indice] = 1.0;
    }

    # calcula e guarda os resultados das funções
    pesoTotal = getPesoTotal();
    acrescimoCalculado = jurosParaAcrescimo(3.0);
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

    # imprime os resultados
    printf("Peso total = %.15f\n", pesoTotal);
    printf("Acrescimo = %.15f\n", acrescimoCalculado);
    printf("Juros = %.15f\n", jurosCalculado);
    exit
}