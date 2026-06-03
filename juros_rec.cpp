// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 03/06/2026: com vetores de C++ e globais como em juros_otimizado, versão recursiva

#include <vector>  // vector
#include <math.h>	// pow
#include <iomanip>  // setprecision
#include <iostream>  // couts

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
    Quantidade = 3;
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
