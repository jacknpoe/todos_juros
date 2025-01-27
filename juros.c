// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0
//        0.3: 22/12/2024: adicionados comentários para os includes
//        0.4: 16/01/2025: adicionado cálculo de peso total
//        0.5: 26/01/2025: adicionados comentários para estrutura, funções e main

#include <math.h>      // para usar pow()
#include <stdio.h>     // para usar printf() e gets()
#include <stdlib.h>    // para usar malloc() e free()
#include <stdbool.h>   // para usar o tipo booleano
#include <locale.h>    // para usar setlocale()

// estrutura básica de propriedades para simplificar as chamadas
struct Juros {
	short Quantidade;
	bool Composto;
	double Periodo;
	double *Pagamentos;
	double *Pesos;
};

// para liberar a memória alocada aos ponteiros no final
void liberaMemoria(struct Juros *juros) {
	if(juros->Quantidade != 0) {
		free(juros->Pagamentos);
		free(juros->Pesos);
	}
}

// define a quantidade de parcelas
bool setQuantidade(struct Juros *juros, short quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == juros->Quantidade) return true;
	juros->Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pagamentos == NULL) { juros->Quantidade = 0; return false; }
	juros->Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pesos == NULL) { juros->Quantidade = 0; return false; }
	juros->Quantidade = quantidade; return true;
}

// define os valores escalares da estrutura (automaticamente, também chama setQuantidade)
bool setValores(struct Juros *juros, short quantidade, bool composto, double periodo) {
	if(!setQuantidade(juros, quantidade)) return false;
	juros->Composto = composto;
	juros->Periodo = periodo;
	return true;
}

// calcula a somatória do array Pesos[]
double getPesoTotal(struct Juros *juros) {
	double acumulador = 0.0;
	short indice;
	for(indice = 0; indice < juros->Quantidade; indice++) acumulador += juros->Pesos[indice];
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
double jurosParaAcrescimo(struct Juros *juros, double valor) {
	if(valor <= 0 || juros->Quantidade <= 0 || juros->Periodo <= 0.0) return 0.0;
	double pesoTotal = getPesoTotal(juros);
	double acumulador = 0; 
	short indice;
	
	for(indice = 0; indice < juros->Quantidade; indice++) {
		if(juros->Composto) acumulador += juros->Pesos[indice] / pow(1 + valor / 100, juros->Pagamentos[indice] / juros->Periodo);
			else acumulador += juros->Pesos[indice] / (1 + valor / 100 * juros->Pagamentos[indice] / juros->Periodo);
	}
	
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1) * 100;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(struct Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0, medJuros = 0, minDiferenca = 0, pesoTotal = 0;
	short indice = 0;
	if(maxIteracoes < 1 || juros->Quantidade <= 0 || precisao < 1 || valor <= 0 || juros->Periodo <= 0.0) return 0.0;
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
    // define os valores de juros
	struct Juros juros;
	double pesoTotal = 0, acrescimoCalculado = 0, jurosCalculado = 0;
	char buffer[256];

	setlocale( LC_ALL, "");	

	if(!setValores(&juros, 3, true, 30.0)) {
		printf("Erro ao definir os valores da estrutura juros!");
		return -1;
	}

	juros.Pesos[0] = 1;
	juros.Pesos[1] = 1;
	juros.Pesos[2] = 1;
	
	juros.Pagamentos[0] = 30.0;
	juros.Pagamentos[1] = 60.0;
	juros.Pagamentos[2] = 90.0;

    // calcula, guarda e imprime os resultados
	pesoTotal = getPesoTotal(&juros);
	printf("Peso total: %3.15f\n", pesoTotal);
	acrescimoCalculado = jurosParaAcrescimo(&juros, 3);
	printf("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(&juros, acrescimoCalculado, 15, 100, 50.0);
	printf("Juros calculado: %3.15f\n", jurosCalculado);

	// espera pressionar enter
	gets(buffer);

    // libera a memória e finaliza
	liberaMemoria(&juros);
	return 0;
}
