#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <locale.h>

struct Juros {
	short Quantidade;
	bool Composto;
	short Periodo;
	short *Pagamentos;
	double *Pesos;
};

void liberaMemoria(struct Juros *juros) {
	if(juros->Quantidade != 0) {
		free(juros->Pagamentos);
		free(juros->Pesos);
	}
}

bool setQuantidade(struct Juros *juros, short quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == juros->Quantidade) return true;
	juros->Pagamentos = (short *) malloc(sizeof(short) * quantidade);
	if(quantidade > 0 && juros->Pagamentos == NULL) { juros->Quantidade = 0; return false; }
	juros->Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pesos == NULL) { juros->Quantidade = 0; return false; }
	juros->Quantidade = quantidade; return true;
}

bool setValores(struct Juros *juros, short quantidade, bool composto, short periodo) {
	if(!setQuantidade(juros, quantidade)) return false;
	juros->Composto = composto;
	juros->Periodo = periodo;
	return true;
}

double getPesoTotal(struct Juros *juros) {
	double acumulador = 0.0;
	short indice;
	for(indice = 0; indice < juros->Quantidade; indice++) acumulador += juros->Pesos[indice];
	return acumulador;
}

double jurosParaAcrescimo(struct Juros *juros, double valor) {
	if(valor <= 0 || juros->Quantidade <= 0 || juros->Periodo <= 0) return 0.0;
	double pesoTotal = getPesoTotal(juros);
	double acumulador = 0; bool soZero = true;
	short indice;
	
	for(indice = 0; indice < juros->Quantidade; indice++) {
		if(juros->Pagamentos[indice] > 0 && juros->Pesos[indice] > 0) soZero = false;
		if(juros->Composto) acumulador += juros->Pesos[indice] / pow(1 + valor / 100, juros->Pagamentos[indice] / juros->Periodo);
			else acumulador += juros->Pesos[indice] / (1 + valor / 100 * juros->Pagamentos[indice] / juros->Periodo);
	}
	
	if(soZero) return 0.0;
	return(pesoTotal / acumulador - 1) * 100;
}

double acrescimoParaJuros(struct Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0, medJuros = 0, minDiferenca = 0, pesoTotal = 0;
	short indice = 0;
	if(maxIteracoes < 1 || juros->Quantidade <= 0 || precisao < 1 || valor <= 0 || juros->Periodo <= 0) return 0.0;
	pesoTotal = getPesoTotal(juros);
	if(pesoTotal <= 0) return 0.0;
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
	double acrescimoCalculado = 0, jurosCalculado = 0;
	char buffer[256];

	setlocale( LC_ALL, "");	

	if(!setValores(&juros, 3, true, 30)) {
		printf("Erro ao definir os valores da estrutura juros!");
		return -1;
	}

	juros.Pesos[0] = 1;
	juros.Pesos[1] = 1;
	juros.Pesos[2] = 1;
	
	juros.Pagamentos[0] = 30;
	juros.Pagamentos[1] = 60;
	juros.Pagamentos[2] = 90;
	
	acrescimoCalculado = jurosParaAcrescimo(&juros, 3);
	printf("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(&juros, acrescimoCalculado, 15, 100, 50.0);
	printf("Juros calculado: %3.15f\n", jurosCalculado);
	gets(buffer);

	liberaMemoria(&juros);
	
	return 0;
}
