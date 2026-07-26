// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 26/07/2026: versão recursiva com as séries de Taylor recursivas e normalizadas
// COMPILAR: g++ -Ofast -march=native -DNDEBUG -std=c++17 juros_rec_taylor.cpp -o juros_rec_taylor
// PREPARAR PARA MUITAS PARCELAS (TESTADO ATÉ 300.000): ulimit -s 65536

#include <vector>  // vector
#include <iomanip>  // setprecision
#include <iostream>  // couts

#define LN2 0.69314718055994530

// essa função é especial para expoentes inteiros (usada por exp)
double rpowint(double base, long expoente) {
	if (expoente < 0) return rpowint(1.0 / base, -expoente);
	if (expoente == 0) return 1.0;
	if (expoente % 2 == 0) return rpowint(base * base, expoente / 2);
	return base * rpowint(base * base, (expoente - 1) / 2);
}

// função recursiva que calcula ln()
double rln(double indice, double soma, double termo, double yy) {
    if(soma + termo == soma) return soma; else return rln(indice + 1.0, soma + termo / (2.0 * indice - 1.0), termo * yy, yy);
}

// função que calcula ajuste quando valor >= 2.0
double raddajuste(double valor) {
    if(valor >= 2.0) return 1.0 + raddajuste(valor / 2.0); else return 0.0;
}

// função que calcula ajuste quando valor <> 1.0
double rsubajuste(double valor) {
    if(valor < 1.0) return -1.0 + rsubajuste(valor * 2.0); else return 0.0;
}

// função ln() açúcar normalizada, de uso geral
double ln(double valor) {
    double ajuste, x, termo, yy;

    // normaliza
    if(valor >= 2.0) {
        ajuste = raddajuste(valor);
        x = valor / rpowint(2.0, ajuste);
    } else {
        if(valor < 1.0) {
            ajuste = rsubajuste(valor);
            x = valor / rpowint(2.0, ajuste);
        } else {
            x = valor;
            ajuste = 0.0;
        }
    }

    termo = (x - 1.0) / (x + 1.0);
    yy = termo * termo;

    return 2.0 * rln(1.0, 0.0, termo, yy) + ajuste * LN2;
}

// função recursiva que calcula exp()
double rexp(double indice, double soma, double termo, double valor) {
    if(soma + termo == soma) return soma; else return rexp(indice + 1.0, soma + termo, termo * valor / (indice + 1), valor);
}

// função exp() açúcar normalizada, de uso geral
double exp(double valor) {
    long ajuste;
    double x;

    ajuste = (long)(valor / LN2) - (valor < 0.0 ? 1 : 0);
    x = valor - ajuste * LN2;

    return rexp(1.0, 1.0, x, x) * rpowint(2.0, ajuste);
}

// pown() é calculado pela equação clássica expn(lnn(base) * expoente)
double pow(double base, double expoente) {
    return exp(ln(base) * expoente);
}

// variáveis globais para simplificar as chamadas de função
int Quantidade;
bool Composto;
double Periodo;
std::vector<double> Pagamentos;
std::vector<double> Pesos;

// função recursiva que cria Pagamentos
std::vector<double> rGeraPagamentos(int indice) {
    if (indice <= 0) return {};
    std::vector<double> resultado = rGeraPagamentos(indice - 1); resultado.push_back(indice * Periodo); return resultado;
}

// açúcar que cria Pagamentos
std::vector<double> geraPagamentos() { return rGeraPagamentos(Quantidade); }

// função recursiva que cria Pesos
std::vector<double> rGeraPesos(int indice) {
    if (indice <= 0) return {};
    std::vector<double> resultado = rGeraPesos(indice - 1); resultado.push_back(1.0); return resultado;
}

// açúcar que cria Pesos
std::vector<double> geraPesos() { return rGeraPesos(Quantidade); }

// função recursiva que calcula a somatória de Pesos
double rGetPesoTotal(int indice) { if (indice < 0) return 0.0; else return Pesos[indice] + rGetPesoTotal(indice - 1);}

// açúcar que calcula a somatória de Pesos
double getPesoTotal() { return rGetPesoTotal(Quantidade - 1); }

// função recursiva que calcula a somatória dos amortecimentos de juros compostos
double rJurosCompostos(double juros, int indice) {
    if (indice < 0) return 0.0; else return Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo) + rJurosCompostos(juros, indice - 1);
}

// função recursiva que calcula a somatória dos amortecimentos de juros simples
double rJurosSimples(double juros, int indice) {
    if (indice < 0) return 0.0; else return Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo) + rJurosSimples(juros, indice - 1);
}

// calcula o acréscimo a partir dos juros e parcelas (com algum açúcar)
double jurosParaAcrescimo(double juros) {
    if (Composto) return (getPesoTotal() / rJurosCompostos(juros, Quantidade - 1) - 1.0) * 100.0;
             else return (getPesoTotal() / rJurosSimples(juros, Quantidade - 1) - 1.0) * 100.0;
}

// função recursiva que calcula os juros a partir do acréscimo e parcelas
double rAcrescimoParaJuros(double acrescimo, double minDiferenca, int iteracao, double minJuros, double maxJuros, double medJuros) {
    if (iteracao <= 0 || maxJuros - minJuros < minDiferenca) return medJuros;
    else if (jurosParaAcrescimo(medJuros) < acrescimo)
        return rAcrescimoParaJuros(acrescimo, minDiferenca, (iteracao - 1), medJuros, maxJuros, (medJuros + maxJuros) / 2.0);
        else return rAcrescimoParaJuros(acrescimo, minDiferenca, (iteracao - 1), minJuros, medJuros, (minJuros + medJuros) / 2.0);
}

// açúcar que calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
    return rAcrescimoParaJuros(acrescimo, pow(0.1, precisao), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0);
}

// função principal
int main() {
    // define como padrão 15 casas decimais depois da vírgula
    std::cout << std::fixed << std::setprecision(15);

    // inicializa as variáveis escalares globais
    Quantidade = 300000;
    Composto = true;
    Periodo = 30.0;

    // inicializam recursivamente os vetores globais
    Pagamentos = geraPagamentos();
    Pesos = geraPesos();

    // calcula e guarda os resultados das funções
    double pesoTotal = getPesoTotal();
    double acrescimoCalculado = jurosParaAcrescimo(3.0);
    double jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);

    // imprime os resultados
    std::cout << "Peso total = " << pesoTotal << std::endl;
    std::cout << "Acréscimo = " << acrescimoCalculado << std::endl;
    std::cout << "Juros = " << jurosCalculado << std::endl;

    // retorna sucesso
    return 0;
}
