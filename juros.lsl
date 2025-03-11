// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 11/03/2025: versão feita sem muito conhecimento de LSL

// variáveis globais para simplificar as chamadas às funções
integer Quantidade = 3;
integer Composto = TRUE;
float Periodo = 30.0;
list Pagamentos = [];
list Pesos = [];

// calcula a somatória de Pesos[]
float getPesoTotal() {
    float acumulador = 0.0; integer indice;
    for(indice = 0; indice < Quantidade; indice++) acumulador += llList2Float(Pesos, indice);
    return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
float jurosParaAcrescimo(float juros) {
    float pesoTotal = getPesoTotal();; float acumulador = 0.0; integer indice;

    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || juros <= 0.0) return 0.0;
    
    for(indice = 0; indice < Quantidade; indice++)
        if(Composto) acumulador += llList2Float(Pesos, indice) / llPow(1.0 + juros / 100.0, llList2Float(Pagamentos, indice) / Periodo);
            else acumulador += llList2Float(Pesos, indice) / (1.0 + juros / 100.0 * llList2Float(Pagamentos, indice) / Periodo);

    if(acumulador <= 0.0) return 0.0;
    return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
float acrescimoParaJuros(float acrescimo, integer precisao, integer maxIteracoes, float maxJuros) {
    float pesoTotal = getPesoTotal(); float minJuros = 0.0; float medJuros; integer indice; float minDiferenca = llPow(0.1, precisao);

    if(pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
    
    for(indice = 0; indice < maxIteracoes; indice++) {
        medJuros = (minJuros + maxJuros) / 2.0;
        if((maxJuros - minJuros) < minDiferenca) return medJuros;
        if(jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros; else maxJuros = medJuros;
    }
    return medJuros;
}

default {
    state_entry() {
        integer indice;

        // inicializa os arrays
        for(indice = 1; indice <= Quantidade; indice++) {
            Pagamentos += 30.0 * indice;
            Pesos += 1.0;
        }

        llSay(0, "Olá, Avatar!");
    }

    touch_start(integer total_number) {
        float pesoTotal; float acrescimoCalculado; float jurosCalculado;

        // calcula e guarda os resultados das funções 
        pesoTotal = getPesoTotal();
        acrescimoCalculado = jurosParaAcrescimo(3.0);
        jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

        // imprime os resultados 
        llSay(0, "Peso total = " + (string) pesoTotal);
        llSay(0, "Acréscimo = " + (string) acrescimoCalculado);
        llSay(0, "Juros = " + (string) jurosCalculado);
    }
}