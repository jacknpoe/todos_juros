// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 06/05/2026: feita sobre a versão de desenvolvimento v1.0.7 de Sapphire (foxzyt)

// ########## funções matemáticas, além das quatro operações básicas, necessárias para a solução, #############
// ########## mas ausentes na versão atual da linguagem, embora não façam parte do domínio do problema ########

// variáveis que funcionam como constantes, para evitar números mágicos em ln() e exp()
int MAXLN = 15;
int MAXEXP = 20;

// essa função é mais precisa com valores mais próximos de 1, como 1.0 a 1.1, que é a faixa do domínio do problema
function ln(double x) double {
    double termo = (x - 1.0) / (x + 1.0);
    double yy = termo * termo;
    double soma = 0.0;

    int indice = 1;
    while(indice <= MAXLN) {
        soma= soma + termo / (2.0 * indice - 1.0);
        termo = termo * yy;
        if(soma + termo == soma){ indice = MAXLN; }
        indice = indice + 1;
    }

    return 2.0 * soma;
}

// essa função é mais precisa com valores menores do que 5, que é a faixa do domínio do problema
function exp(double x) double {
    double termo = 1.0;
    double soma = 1.0;

    int indice = 1;
    while(indice <= MAXEXP) {
        termo = termo * x / indice;
        soma = soma + termo;
        if(soma + termo == soma) { indice = MAXEXP; }
        indice = indice + 1;
    }

    return soma;
}

// essa função tem a precisão boa de acordo com ln() e exp()
function pow(double base, double expoente) double {
    return exp(ln(base) * expoente);
}

// essa função é especial para expoentes inteiros, usada para calcular 0.1 ^ precisao ; como % não existe em Sapphire, a solução é iterativa
function powint(double base, int expoente) double {
    double produto = 1.0;

    int indice = 0;
    while(indice < expoente) {
        produto = produto * base;
        indice = indice + 1;
    }

    return produto;
}

// ########## a partir daqui, as variáveis e funções fazem parte do domínio do problema ##########

// variáveis globais para simplificar as chamadas às funções e inicialização das escalares
int Quantidade = 3;
bool Composto = true;
double Periodo = 30.0;
class Pagamentos = ListUtil.create();
class Pesos = ListUtil.create();

// calcula a somatória dos elementos da lista Pesos
function getPesoTotal() double {
    double acumulador = 0.0;

    int indice = 0;
    while(indice < Quantidade) {
        acumulador = acumulador + Pesos[indice];
        indice = indice + 1;
    }

    return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(double juros) double {
    double pesoTotal = getPesoTotal();
    if(Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0) { return 0.0; }
    double acumulador = 0.0;

    int indice = 0;
    while(indice < Quantidade) {
        if(Composto) {
            acumulador = acumulador + Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
        } else {
            acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        }
        indice = indice + 1;
    }

    if(acumulador <= 0.0) { return 0.0; }
    return (pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) double {
    double pesoTotal = getPesoTotal();
    if(Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0) { return 0.0; }
    double minJuros = 0.0;
    double medJuros = maxJuros / 2.0;
    double minDiferenca = powint(0.1, precisao);

    int iteracao = 0;
    while(iteracao < maxIteracoes) {
        if(maxJuros - minJuros <= minDiferenca) { return medJuros; }
        if(jurosParaAcrescimo(medJuros) < acrescimo) { minJuros = medJuros; } else { maxJuros = medJuros; }
        medJuros = (minJuros + maxJuros) / 2.0;
        iteracao = iteracao + 1;
    }

    return medJuros;
}

// a função principal é usada na documentação, e vamos manter esse padrão
function main() void {
    // inicialização dos elementos das listas Pagamentos e Pesos
    int indice = 0;
    while(indice < Quantidade) {
        ListUtil.append(Pagamentos, (indice + 1.0) * Periodo);
        ListUtil.append(Pesos, 1.0);
        indice = indice + 1;
    }

    // calcula e guarda os resultados das funções
    double pesoTotal = getPesoTotal();
    double acrescimoCalculado = jurosParaAcrescimo(3.0);
    double jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);

    // imprime os resultados
    print "Peso total = " + valueToString(pesoTotal);
    print "Acréscimo = " + valueToString(acrescimoCalculado);
    print "Juros = " + valueToString(jurosCalculado);
}

main();
