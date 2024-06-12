% Cálculo do juros, sendo que precisa de arrays para isso
% Versão: 0.1: 12/06/2024: primeira versão, sem saber muito de S-Lang

% variáveis globais para simplificar as chamadas
variable Quantidade = 3;
variable Composto = 1;
variable Periodo = 30.0;
variable Pagamentos = [30.0, 60.0, 90.0];
variable Pesos = [1.0, 1.0, 1.0];

% calcula a somatória de Pesos[]
define getPesoTotal () {
	variable acumulador = 0.0;
    variable indice = 0;
    for (indice = 0; indice < Quantidade; indice++){
        acumulador += Pesos[indice];
    }
    return acumulador;
}

% calcula o acréscimo a partir dos juros e prestações
define jurosParaAcrescimo (juros) {
    variable pesoTotal = getPesoTotal();
    if ((juros <= 0.0) or (Quantidade < 1) or (Periodo <= 0.0) or (pesoTotal <= 0.0))
        return 0.0;
    variable acumulador = 0.0;
    variable indice = 0;

    for (indice = 0; indice < Quantidade; indice++) {
        if (Composto == 1) {
            acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo);
        } else {
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        }
    }

    return (pesoTotal / acumulador - 1.0) * 100.0;
}

% calcula os juros a partir do acréscimo e prestações
define acrescimoParaJuros (acrescimo, precisao, maxIteracoes, maxJuros) {
    variable pesoTotal = getPesoTotal();
    if ((acrescimo <= 0.0) or (Quantidade < 1) or (Periodo <= 0.0) or (pesoTotal <= 0.0) or (precisao < 1) or (maxIteracoes < 1) or (maxJuros <= 0.0))
        return 0.0;
    variable minJuros = 0.0;
    variable medJuros = maxJuros / 2.0;
    variable minDiferenca = 0.1 ^ precisao;
    variable indice = 0;

    for (indice = 0; indice < maxIteracoes; indice++) {
        medJuros = (minJuros + maxJuros) / 2.0;
        if ((maxJuros - minJuros) < minDiferenca) return medJuros;
        if (jurosParaAcrescimo(medJuros) < acrescimo) {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
    }

    return medJuros;
}

% guarda os resultados dos cálculos
variable pesoTotal = getPesoTotal();
variable acrescimoCalculado = jurosParaAcrescimo(3.0);
variable jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

% imprime os resultados
message(strcat("Peso total = ", string(pesoTotal)));
message(strcat("Acréscimo = ", string(acrescimoCalculado)));
message(strcat("Juros = ", string(jurosCalculado)));