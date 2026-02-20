/* Calculo dos juros, sendo que precisa de parcelas pra isso
   Versão 0.1: 19/02/2026: ate o momento, a matematica de fixed points, globais, inicializacao e getPesoTotal()
          0.2: 20/02/2026: jurosParaAcrecimo() e a acrescimoParaJuros() */

main() {
    extrn printf, p5dec, acrescimoParaJuros, jurosParaAcrescimo, getPesoTotal, inttofp, QUANTIDADE, PERIODO, PAGAMENTOS, PESOS, UM;
    auto indice, pesoTotal, acrescimoCalculado, jurosCalculado;

    /* inicializa os arrays PAGAMENTOS[] e PESOS[] */
    indice = 0;
    while (indice < QUANTIDADE) {
        PAGAMENTOS[indice] = PERIODO * (indice + 1);
        PESOS[indice] = UM;
        indice = indice + 1;
    }

    /* calcula e guarda os resultados das funcoes */
    pesoTotal = getPesoTotal();
    acrescimoCalculado = jurosParaAcrescimo(inttofp(3));
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 8, 35, inttofp(50));

    /* imprime os resultados */
    printf("Peso total = %d.E-5*n", p5dec(pesoTotal));
    printf("Acrescimo = %d.E-5*n", p5dec(acrescimoCalculado));
    printf("Juros = %d.E-5*n", p5dec(jurosCalculado));
}

/* para cinco casas decimais (retira três das oito por questão de precisão) */
p5dec(valor) {
    extrn MIL;
    return ((valor + MIL / 2) / MIL);
}

/* calcula os juros a partir do acrescimo e parcelas */
acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
    extrn printf, jurosParaAcrescimo, getPesoTotal, prectomind, divfp, DOIS, QUANTIDADE, PERIODO;
    auto pesoTotal, minJuros, medJuros, minDiferenca, iteracao;
    pesoTotal = getPesoTotal();
    if (QUANTIDADE < 1 | PERIODO < 1 | pesoTotal < 1 | acrescimo < 1 | precisao < 1 | maxIteracoes < 1 | maxJuros < 1) return (0);
    minJuros = 0;
    medJuros = divfp(maxJuros, DOIS);
    minDiferenca = prectomind(precisao);
    iteracao = 0;


    while (iteracao < maxIteracoes) {
        if (maxJuros - minJuros < minDiferenca) return (medJuros);
        if (jurosParaAcrescimo(medJuros) < acrescimo) {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
        medJuros = divfp(minJuros + maxJuros, DOIS);
        iteracao = iteracao + 1;
    }

    return (medJuros);
}

/* calcula o acrescimo partir dos juros e parcelas */
jurosParaAcrescimo(juros) {
    extrn getPesoTotal, mulfp, divfp, UM, CEM, QUANTIDADE, COMPOSTO, PERIODO, PAGAMENTOS, PESOS;
    auto pesoTotal, acumulador, indice;
    pesoTotal = getPesoTotal();
    if (QUANTIDADE < 1 | PERIODO < 1 | pesoTotal < 1 | juros < 1) return (0);
    acumulador = 0;
    indice = 0;

    while (indice < QUANTIDADE) {
        if (COMPOSTO) {
            acumulador = acumulador + divfp(PESOS[indice], powfp(UM + divfp(juros, CEM), divfp(PAGAMENTOS[indice], PERIODO)));
        } else {
            acumulador = acumulador + divfp(PESOS[indice], UM + mulfp(divfp(juros, CEM), divfp(PAGAMENTOS[indice], PERIODO)));
        }
        indice = indice + 1;
    }

    if (acumulador < 1) return (0);
    return ((divfp(pesoTotal, acumulador) - UM) * 100);
}

/* calcula a somatoria dos elementos do array PESOS[] */
getPesoTotal() {
    extrn QUANTIDADE, PESOS;
    auto acumulador, indice;
    acumulador = 0;
    indice = 0;

    while (indice < QUANTIDADE) {
        acumulador = acumulador + PESOS[indice];
        indice = indice + 1;
    }

    return (acumulador);
}

/* calcula a minima diferenca a partir do número de digitos da precisao (inteiro para fixed point) */
prectomind(x) {
    extrn DIGITOS;
    auto produto, indice;
    produto = 1;
    indice = 0;

    while (indice < DIGITOS - x) {
        produto = produto * 10;
        indice = indice + 1;
    }

    return (produto);
}

/* todas as funcoes matematicas de fixed point, exponenciacoes e logaritmos sao precisas (ou mesmo estaveis)
   somente dentro do dominio do problema (converter entre acrescimo e juros a partir de parcelas com datas e pesos ajustaveis) */

/* potencia em fixed point calculada como expfp( lnfp(base) * expoente ); valida no dominio do problema de matematica financeira;
   herda as limitacoes numericas de lnfp() e expfp() */
powfp(b, e) {
    extrn expfp, lnfp, mulfp;
    return (expfp(mulfp(e, lnfp(b))));
}

/* exponencial em fixed point usando serie de Taylor; precisa e estavel no dominio do problema (expoentes pequenos,
   tipicamente derivados de lnfp em matematica financeira); a precisao depende de TOTEXP e da escala fixa adotada */
expfp(x) {
    extrn mulfp, divfp, inttofp, TOTEXP, UM;
    auto termo, soma, indice;
    termo = UM;
    soma = UM;
    indice = 1;

    while (indice <= TOTEXP) {
        termo = mulfp(termo, divfp(x, inttofp(indice)));
        soma = soma + termo;
        indice = indice + 1;
    }
    return (soma);
}

/* logaritmo natural em fixed point usando serie via (x-1)/(x+1); preciso e estavel no dominio do problema de matematica financeira;
   apresenta melhor convergencia para valores proximos de 1; a precisao depende de TOTLN e da escala fixa adotada */
lnfp(x) {
    extrn mulfp, divfp, inttofp, TOTLN, UM;
    auto yy, termo, soma, indice;
    termo = divfp(x - UM, x + UM);
    yy = mulfp(termo, termo);
    soma = 0;
    indice = 1;

    while (indice <= TOTLN) {
        soma = soma + divfp(termo, inttofp(2 * indice - 1));
        termo = mulfp(termo, yy);
        indice = indice + 1;
    }

    return (2 * soma);
}

/* operacao * de dois fixed points */
mulfp(a, b) {
    extrn ESCALA;

    if (a * b < 0) {
        return ((a * b - ESCALA / 2) / ESCALA);
    } else {
        return ((a * b + ESCALA / 2) / ESCALA);
    }
}

/* operacao * de dois fixed points */
divfp(a, b) {
    extrn ESCALA, INFINITO;

    if (b == 0) return (INFINITO);  /* divisao por zero retorna valor fora do dominio do problema (ou nao trate aqui, se preferir) */
    if (a * b < 0) {
        return ((a * ESCALA - b / 2) / b);
    } else {
        return ((a * ESCALA + b / 2) / b);
    }
}

/* torna um integer em fixed point com DIGITOS de digitos (usando ESCALA que ja esta computada) */
inttofp(x) {
    extrn ESCALA;

    return (x * ESCALA);
}

/* CONSTANTES DE FIXED POINTS PARA LEGIBILIDADE (NUMEROS GRANDES ESTAO NO FORMATO FIXED POINT) E ITERACOES EM SERIES DE TAYLOR */
DIGITOS 8;
ESCALA 100000000;
TOTLN 16;
TOTEXP 24;
UM 100000000;
CEM 10000000000;
MIL 1000;
DOIS 200000000;
INFINITO 10000000000000000;

/* CONSTANTES PARA SIMPLIFICAR AS CHAMADAS (NOTE QUE OS ARRAYS NÃO TÊM OS ELEMENTOS CONSTANTES) */
QUANTIDADE 3;
COMPOSTO 1;
PERIODO 3000000000;
PAGAMENTOS[3];
PESOS[3];
