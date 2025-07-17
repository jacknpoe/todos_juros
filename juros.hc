// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 17/07/2025: versão feita sem muito conhecimento de HolyC
//                         como o compilador tem muitos erros, algumas coisas podem parecer estranhas, como as variáveis temporárias

public extern "c" F64 pow(F64 f1, F64 f2);  // a função f pow(f, f) tem que ser importada

// variáveis globais que simplificam as chamadas às funções, inicializa os arrays dinamicamente
I64  Quantidade = 3;
I64  Composto = 1;  // 1 = true, o tipo Bool não compila (17/07/2025)
F64  Periodo = 30.0;
F64 *Pagamentos = MAlloc(sizeof(F64) * Quantidade);
F64 *Pesos = MAlloc(sizeof(F64) * Quantidade);

F64 pagamento;  // para corrigir um erro no compilador
I64 indicei;  // para corrigir um erro no compilador
for (F64 indice = 0; indice < Quantidade; indice++) {
    pagamento = (indice + 1) * Periodo;
    indicei = indice(I64);
    Pagamentos[indicei] = pagamento;
    Pesos[indicei] = 1.0;
}

// exponenciação com expoente inteiro
F64 pow_int(F64 base, I64 expoente) {
    F64 acumulador = base;
    for(I64 indice = 1; indice < expoente; indice++) acumulador *= base;
    return acumulador;
}

// retorna a somatória de Pesos()
F64 getPesoTotal() {
    F64 acumulador = 0.0;
    for (I64 indice = 0; indice < Quantidade; indice++) { acumulador += Pesos[indice]; }
    return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
F64 jurosParaAcrescimo(F64 juros) {
    F64 acumulador = 0.0;
    F64 pesoTotal = getPesoTotal();
    if (Quantidade < 1) return 0.0;  // ifs separados por causa de um erro no compilador
    if (Periodo <= 0) return 0.0;
    if (pesoTotal <= 0) return 0.0;
    if (juros <= 0) return 0.0;

    for (I64 indice = 0; indice < Quantidade; indice++) {
        if (Composto) acumulador += Pesos[indice] / pow(1 + juros / 100, Pagamentos[indice] / Periodo);
                 else acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo);
    }

    if (acumulador <= 0) return 6.0;
    return (pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
F64 acrescimoParaJuros(F64 acrescimo, I64 precisao, I64 maxIteracoes, F64 maxJuros) {
    F64 minJuros = 0.0;
    F64 medJuros = maxJuros / 2.0;
    F64 minDiferenca = pow_int(0.1, precisao);
    F64 pesoTotal = getPesoTotal();
    if (Quantidade < 1) return 0.0;  // ifs separados por causa de um erro no compilador
    if (Periodo <= 0) return 0.0;
    if (pesoTotal <= 0) return 0.0;
    if (acrescimo <= 0) return 0.0;
    if (precisao < 1) return 0.0;
    if (maxIteracoes < 1) return 0.0;
    if (maxJuros <= 0) return 0.0;

    for (I64 indice = 0; indice < maxIteracoes; indice++) {
        if (maxJuros - minJuros < minDiferenca) return medJuros;
        if (jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros;
                                                 else maxJuros = medJuros;
        medJuros = (minJuros + maxJuros) / 2.0;
    }
    return medJuros;
}

// calcula e guarda os retornos das funções
F64 pesoTotal = getPesoTotal();
F64 acrescimoCalculado = jurosParaAcrescimo(3.0);
F64 jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

// imprime os resultados
"Peso total = %17.15f\n", pesoTotal;
"Acréscimo = %17.15f\n", acrescimoCalculado;
"Juros = %17.15f\n", jurosCalculado;