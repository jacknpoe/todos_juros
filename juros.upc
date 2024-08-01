// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 01/08/2024: versão feita sem muito conhecimento de Unified Parallel C

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <locale.h>

// estrutura para simplificar as chamadas
struct Juros {
	short Quantidade;
	bool Composto;
	double Periodo;
	double *Pagamentos;
	double *Pesos;
};

// libera a memória dos ponteiros da estrutura
void liberaMemoria(struct Juros *juros) {
	if(juros->Quantidade != 0) {
		free(juros->Pagamentos);
		free(juros->Pesos);
	}
}

// determinar uma quantidade implica em alocar memória para as estruturas
bool setQuantidade(struct Juros *juros, short quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == juros->Quantidade) return true;
	juros->Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pagamentos == NULL) { juros->Quantidade = 0; return false; }
	juros->Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pesos == NULL) { juros->Quantidade = 0; return false; }
	juros->Quantidade = quantidade; return true;
}

// determina valores para as variáveis não ponteiro da estrutura
bool setValores(struct Juros *juros, short quantidade, bool composto, double periodo) {
	if(!setQuantidade(juros, quantidade)) return false;
	juros->Composto = composto;
	juros->Periodo = periodo;
	return true;
}

// retorna a somatória dos pesos
double getPesoTotal(struct Juros *juros) {
	double acumulador = 0.0;
	short indice;
	for(indice = 0; indice < juros->Quantidade; indice++) acumulador += juros->Pesos[indice];
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
double jurosParaAcrescimo(struct Juros *juros, double valor) {
	double pesoTotal = getPesoTotal(juros);
	if(valor <= 0.0 || juros->Quantidade <= 0 || juros->Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
	double acumulador = 0.0; // bool soZero = true;
	short indice;
	
	for(indice = 0; indice < juros->Quantidade; indice++) {
		// if(juros->Pagamentos[indice] > 0.0 && juros->Pesos[indice] > 0) soZero = false;
		if(juros->Composto) acumulador += juros->Pesos[indice] / pow(1 + valor / 100, juros->Pagamentos[indice] / juros->Periodo);
			else acumulador += juros->Pesos[indice] / (1 + valor / 100 * juros->Pagamentos[indice] / juros->Periodo);
	}
	
	// if(soZero) return 0.0;
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(struct Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = maxJuros / 2.0, minDiferenca = 0.0, pesoTotal = 0.0;
	short indice = 0;
	pesoTotal = getPesoTotal(juros);
	if(maxIteracoes < 1 || juros->Quantidade <= 0 || precisao < 1 || valor <= 0 || juros->Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
	minDiferenca = pow(0.1, precisao);

	for(indice = 0; indice < maxIteracoes; indice++) {
		medJuros = (minJuros + maxJuros) / 2;
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(jurosParaAcrescimo(juros, medJuros) <= valor)
			minJuros = medJuros; else maxJuros = medJuros;
	}
	
	return medJuros;
}

int main() {
	struct Juros juros;
	double pesoTotal = 0.0, acrescimoCalculado = 0.0, jurosCalculado = 0.0;
    int indice;

	setlocale( LC_ALL, "");	

    // determina valores para as variáveis da estrutura juros do tipo Juros
	if(!setValores(&juros, 3, true, 30.0)) {
		printf("Erro ao definir os valores da estrutura juros!");
		return -1;
	}

    // determina valores para a memória alocada nos ponteiros de juros
    for(indice = 0; indice < 3; indice++) {
        juros.Pagamentos[indice] = (indice + 1.0) * 30.0;
        juros.Pesos[indice] = 1.0;
    }

    // calcula e guarda o resultado das funções
	pesoTotal = getPesoTotal(&juros);
	acrescimoCalculado = jurosParaAcrescimo(&juros, 3);
	jurosCalculado = acrescimoParaJuros(&juros, acrescimoCalculado, 16, 100, 50.0);

    // imprime os resultados
	printf("Peso total: %1.13f\n", pesoTotal);
	printf("Acréscimo calculado: %1.13f\n", acrescimoCalculado);
	printf("Juros calculado: %1.13f\n", jurosCalculado);

	liberaMemoria(&juros);
	
	return 0;
}