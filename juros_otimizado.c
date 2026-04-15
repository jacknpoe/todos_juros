// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 15/04/2026: versão pesadamente e estaticamente otimizada copiada da versão normal em C

#include <math.h>      // para usar pow()
#include <stdio.h>     // para usar printf() e gets()
#include <stdlib.h>    // para usar malloc() e free()

#define true 1
#define false 0

// variáveis para simplificar as chamadas
int Quantidade;
int Composto;
double Periodo;
double *Pagamentos;
double *Pesos;

// para liberar a memória alocada aos ponteiros no final
void liberaMemoria(void) {
	if(Quantidade != 0) {
		free(Pagamentos);
		free(Pesos);
	}
}

// define a quantidade de parcelas
int setQuantidade(int quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == Quantidade) return true;
	Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && Pagamentos == NULL) { Quantidade = 0; return false; }
	Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && Pesos == NULL) { free(Pagamentos); Quantidade = 0; return false; }
	Quantidade = quantidade; return true;
}

// define os valores escalares da estrutura (automaticamente, também chama setQuantidade)
int setValores(int quantidade, int composto, double periodo) {
	if(!setQuantidade(quantidade)) return false;
	Composto = composto;
	Periodo = periodo;
	return true;
}

// calcula a somatória do array Pesos[]
double getPesoTotal(void) {
	double acumulador = 0.0;
	int indice;
	for(indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas // adicionado parâmetro pesoTotal que, se 0.0, é calculado, senão é usado o parâmetro
double jurosParaAcrescimo(double valor, double pesoTotal) {
	if(pesoTotal == 0.0) pesoTotal = getPesoTotal();
	if(valor <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
	double acumulador = 0.0, fator; 
	int indice;

    // essa tentativa de inverter o for com if/else dentro por um if/else com dois for dentro não resultou no ganho de eficiêncoa esperado
    if(Composto) {
        fator = log(1.0 + valor / 100.0) / Periodo;   // parte fixa do cálculo de juros compostos
	    for(indice = 0; indice < Quantidade; indice++)
		     acumulador += Pesos[indice] / exp(fator * Pagamentos[indice]);
    } else {
        fator = valor / 100.0 / Periodo;   // parte fixa do cálculo de juros simples
        for(indice = 0; indice < Quantidade; indice++) 
            acumulador += Pesos[indice] / (1.0 + fator * Pagamentos[indice]);
    }
	
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas // adicionado parâmetro pesoTotal que, se 0.0, é calculado, senão é usado o parâmetro
double acrescimoParaJuros(double valor, double pesoTotal, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = (minJuros + maxJuros) / 2.0, minDiferenca = pow(0.1, precisao);
	short indice;
	if(pesoTotal == 0.0) pesoTotal = getPesoTotal();
	if(maxIteracoes < 1 || Quantidade < 1 || precisao < 1 || valor <= 0.0 || Periodo <= 0.0 || pesoTotal <= 0.0 || maxJuros <= 0.0) return 0.0;

	for(indice = 0; indice < maxIteracoes; indice++) {
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(jurosParaAcrescimo(medJuros, pesoTotal) <= valor)
			minJuros = medJuros; else maxJuros = medJuros;
		medJuros = (minJuros + maxJuros) / 2.0;
	}
	
	return medJuros;
}

int main() {
    // variáveis que guardarão os resultados das funções
	double pesoTotal, acrescimoCalculado, jurosCalculado;
	int indice;

	if(!setValores(300000, true, 30.0)) {  // essa versão otimizada precisa ser rodada com muitas parcelas para ter a eficiência medida adequadamente
		printf("Erro ao definir os valores da estrutura juros!");
		return -1;
	}

	for(indice = 0; indice < Quantidade; indice++) {
		Pagamentos[indice] = (indice + 1) * Periodo;
		Pesos[indice] = 1.0;
	}

    // calcula, guarda e imprime os resultados
	pesoTotal = getPesoTotal();
	printf("Peso total: %3.15f\n", pesoTotal);
	acrescimoCalculado = jurosParaAcrescimo(3.0, pesoTotal);
	printf("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(acrescimoCalculado, pesoTotal, 15, 65, 50.0);  // ainda se pode diminuir 50.0 para outros máximos conhecidos de antemão
	printf("Juros calculado: %3.15f\n", jurosCalculado);

    // libera a memória e finaliza
	liberaMemoria();
	return 0;
}
