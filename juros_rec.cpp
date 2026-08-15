// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 03/06/2026: com vetores de C++ e globais como em juros_otimizado, versão recursiva
//        0.2: 15/08/2026: alterada para propiciar Tail Call Optimization

// Esta versão da solução em C++ é propositalmente recursiva para medir o desempenho dessa forma de implementar os algoritmos
// usando um compilador em C++ conhecido pelo seu desempenho. A média das medições (para benchmark.png) foi 0,21 s, o que é
// apenas ~ 64% mais lenta do que a versão canônica em C++ (interest.cpp). Não foram utilizados laços e todas as variáveis
// foram atribuídas somente uma vez. As funções "geradoras" de vetores foram escritas pelo ChatGPT.

// VERSÃO 0.2: agora roda a 0,130 s, ~ 1,5% mais lenta que na versão canônica de C++ porque permite Tail Call Optimization

// COMPILAR: g++ -O3 -march=native -DNDEBUG -std=c++17 juros_rec.cpp -o juros_rec

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
void rGeraPagamentos(int indice, std::vector<double>& resultado) {
    if (indice <= 0) return;
	resultado.push_back(indice * Periodo); rGeraPagamentos(indice - 1, resultado);
}

// açúcar que cria Pagamentos
void geraPagamentos(std::vector<double>& resultado) { rGeraPagamentos(Quantidade, resultado); }

// função recursiva que cria Pagamentos
void rGeraPesos(int indice, std::vector<double>& resultado) {
    if (indice <= 0) return;
	resultado.push_back(1.0); rGeraPesos(indice - 1, resultado);
}

// açúcar que cria Pesos
void geraPesos(std::vector<double>& resultado) { rGeraPesos(Quantidade, resultado); }

// função recursiva que calcula a somatória de Pesos
double rGetPesoTotal(int indice, double acumulador) { if (indice < 0) return acumulador; else return rGetPesoTotal(indice - 1, acumulador + Pesos[indice]);}

// açúcar que calcula a somatória de Pesos
double getPesoTotal() { return rGetPesoTotal(Quantidade - 1, 0.0); }

// função recursiva que calcula a somatória dos amortecimentos de juros compostos
double rJurosCompostos(double juros, int indice, double acumulador) {
    if (indice < 0) return acumulador; else return rJurosCompostos(juros, indice - 1, acumulador + Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo));
}

// função recursiva que calcula a somatória dos amortecimentos de juros simples
double rJurosSimples(double juros, int indice, double acumulador) {
    if (indice < 0) return acumulador; else return rJurosSimples(juros, indice - 1, acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo));
}

// calcula o acréscimo a partir dos juros e parcelas (com algum açúcar)
double jurosParaAcrescimo(double juros) {
    if (Composto) return (getPesoTotal() / rJurosCompostos(juros, Quantidade - 1, 0.0) - 1.0) * 100.0;
             else return (getPesoTotal() / rJurosSimples(juros, Quantidade - 1, 0.0) - 1.0) * 100.0;
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
    geraPagamentos(Pagamentos);
    geraPesos(Pesos);

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
