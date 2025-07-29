// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 29/07/2025: copiada da versão em C para Cilk e colocados cilk_fors dentro de if em jurosParaAcrescimo

#include <math.h>      // para usar pow()
#include <stdio.h>     // para usar printf() e gets()
#include <stdlib.h>    // para usar malloc() e free()
#include <stdbool.h>   // para usar o tipo bool, true e false
#include <locale.h>    // para usar setlocale()
#include </home/jacknpoe/Executáveis/cilk/lib/clang/16/include/cilk/cilk.h>  // para paralelismo, mudar para o endereço da sua instação de cilk

// estrutura básica de propriedades para simplificar as chamadas
struct Juros {
	int Quantidade;
	bool Composto;
	double Periodo;
	double *Pagamentos;
	double *Pesos;
    double *Amortecimento;
};

// para liberar a memória alocada aos ponteiros no final
void liberaMemoria(struct Juros *juros) {
	if(juros->Quantidade != 0) {
		free(juros->Pagamentos);
		free(juros->Pesos);
        free(juros->Amortecimento);
	}
}

// define a quantidade de parcelas
bool setQuantidade(struct Juros *juros, int quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == juros->Quantidade) return true;
	juros->Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pagamentos == NULL) { juros->Quantidade = 0; return false; }
	juros->Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pesos == NULL) { free(juros->Pagamentos); juros->Quantidade = 0; return false; }
	juros->Amortecimento = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Amortecimento == NULL) { free(juros->Pagamentos); free(juros->Pesos); juros->Quantidade = 0; return false; }
	juros->Quantidade = quantidade; return true;
}

// define os valores escalares da estrutura (automaticamente, também chama setQuantidade)
bool setValores(struct Juros *juros, int quantidade, bool composto, double periodo) {
	if(!setQuantidade(juros, quantidade)) return false;
	juros->Composto = composto;
	juros->Periodo = periodo;
	return true;
}

// calcula a somatória do array Pesos[]
double getPesoTotal(struct Juros *juros) {
	double acumulador = 0.0;
	int indice;
	for(indice = 0; indice < juros->Quantidade; indice++) acumulador += juros->Pesos[indice];
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
double jurosParaAcrescimo(struct Juros *juros, double valor) {
	if(valor <= 0.0 || juros->Quantidade < 1 || juros->Periodo <= 0.0) return 0.0;
	double pesoTotal = getPesoTotal(juros);
	double acumulador = 0.0; 
	
    if(juros->Composto) {  // em todas as soluções com paralelismo, Amortecimento é um array temporário que permite cálculos separados
	    cilk_for(int indice = 0; indice < juros->Quantidade; indice++)
            juros->Amortecimento[indice] = juros->Pesos[indice] / pow(1.0 + valor / 100.0, juros->Pagamentos[indice] / juros->Periodo);
    } else {
        cilk_for(int indice = 0; indice < juros->Quantidade; indice++)
			juros->Amortecimento[indice] = juros->Pesos[indice] / (1.0 + valor / 100.0 * juros->Pagamentos[indice] / juros->Periodo);
	}
    for(int indice = 0; indice < juros->Quantidade; indice++) { acumulador += juros->Amortecimento[indice]; }
	
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(struct Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = 0.0, minDiferenca = 0.0, pesoTotal = 0.0;
	short indice = 0;
	if(maxIteracoes < 1 || juros->Quantidade < 1 || precisao < 1 || valor <= 0.0 || juros->Periodo <= 0.0) return 0.0;
	pesoTotal = getPesoTotal(juros);
	if(pesoTotal <= 0) return 0.0;
	minDiferenca = pow(0.1, precisao);
	medJuros = (minJuros + maxJuros) / 2.0;

    for(indice = 0; indice < maxIteracoes; indice++) {
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(jurosParaAcrescimo(juros, medJuros) <= valor)
			minJuros = medJuros; else maxJuros = medJuros;
   		medJuros = (minJuros + maxJuros) / 2.0;
	}
	
	return medJuros;
}

int main() {
    // define os valores de juros
	struct Juros juros;
	double pesoTotal = 0.0, acrescimoCalculado = 0.0, jurosCalculado = 0.0;
	int indice;

	setlocale( LC_ALL, "");	

	if(!setValores(&juros, 3, true, 30.0)) {
		printf("Erro ao definir os valores da estrutura juros!");
		return 1;
	}

    	for(indice = 0; indice < juros.Quantidade; indice++) {
		juros.Pagamentos[indice] = (indice + 1) * juros.Periodo;
		juros.Pesos[indice] = 1;
	}

    // calcula, guarda e imprime os resultados
	pesoTotal = getPesoTotal(&juros);
	printf("Peso total: %3.15f\n", pesoTotal);
	acrescimoCalculado = jurosParaAcrescimo(&juros, 3);
	printf("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(&juros, acrescimoCalculado, 15, 100, 50.0);
	printf("Juros calculado: %3.15f\n", jurosCalculado);


    // libera a memória e finaliza
	liberaMemoria(&juros);
	return 0;
}
