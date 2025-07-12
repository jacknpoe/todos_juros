// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 11/07/2025: versão feita sem muito conhecimento de Yorick

// variáveis globais para simplificar as chamadas às funções
Quantidade = 3;
Composto = 1;  // 1 = true
Periodo = 30.0;

// imitações de arrays
func Pagamentos(indice) { return indice * Periodo; }
func Pesos(indice) { return 1.0; }

// calcula a somatória de Pesos()
func getPesoTotal(foo) {
    acumulador = 0.0;
    for(indice = 1; indice <= Quantidade; indice++) {
        acumulador += Pesos(indice);
    }
    return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
func jurosParaAcrescimo(juros) {
    pesoTotal = getPesoTotal(1);
    if (Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) return 0.0;
    
    acumulador = 0.0;
    for(indice = 1; indice <= Quantidade; indice++) {
        if (Composto == 1) acumulador += Pesos(indice) / (1.0 + juros / 100) ^ (Pagamentos(indice) / Periodo);
            else acumulador += Pesos(indice) / (1.0 + juros / 100 * Pagamentos(indice) / Periodo);
    }

    if (acumulador <= 0.0) return 0.0;

    return (pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acrésimo e parcelas
func acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
    pesoTotal = getPesoTotal(1);
    if (Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 ) return 0.0;

    minJuros = 0.0;
    medJuros = maxJuros / 2.0;
    minDiferenca = 0.1 ^ precisao;
    for(indice = 0; indice < maxIteracoes; indice++) {
        if (maxJuros - minJuros < minDiferenca) return medJuros;
        if (jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros;
            else maxJuros = medJuros;
        medJuros = (minJuros + maxJuros) / 2.0;
    }
    return medJuros;
}

// calcula e guarda os resultados das funçõwa
pesoTotal = getPesoTotal(1);
acrescimoCalculado = jurosParaAcrescimo(3.0);
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

// imprime os resultados
write, format = "Peso total = %2.15f\n", pesoTotal;
write, format = "Acréscimo = %2.15f\n", acrescimoCalculado;
write, format = "Juros = %2.15f\n", jurosCalculado;