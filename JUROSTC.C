// Calculo dos juros, sendo que precisa de parcelas pra isso
// Versao 0.1: 03/02/2024: adaptado do C

#include <math.h>      // para usar pow()
#include <stdio.h>     // para usar printf() e gets()
#include <stdlib.h>    // para usar malloc() e free()

// estrutura basica de propriedades para simplificar as chamadas
short Quantidade;
short Composto;
double Periodo;
double *Pagamentos;
double *Pesos;

// para liberar a memoria alocada aos ponteiros no final
void liberaMemoria(void) {
	if(Quantidade != 0) {
		free(Pagamentos);
		free(Pesos);
	}
}

// define a quantidade de parcelas
short setQuantidade(short quantidade) {
	if(quantidade < 0) return 0;
	if(quantidade == Quantidade) return 1;
	Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && Pagamentos == NULL) { Quantidade = 0; return 0; }
	Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && Pesos == NULL) { Quantidade = 0; return 0; }
	Quantidade = quantidade; return 1;
}

// define os valores escalares da estrutura (automaticamente, tambem chama setQuantidade)
short setValores(short quantidade, short composto, double periodo) {
	if(!setQuantidade(quantidade)) return 0;
	Composto = composto;
	Periodo = periodo;
	return 1;
}

// calcula a somatoria do array Pesos[]
double getPesoTotal(void) {
	double acumulador = 0.0;
	short indice;
	for(indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
	return acumulador;
}

// calcula o acrescimo a partir dos juros e parcelas
double jurosParaAcrescimo(double juros) {
	double pesoTotal = getPesoTotal(), acumulador = 0.0;
	short indice;
	if(juros <= 0.0 || Quantidade <= 0 || Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;

	for(indice = 0; indice < Quantidade; indice++) {
		if(Composto) acumulador += Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
			else acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
	}

	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acrescimo e parcelas
double acrescimoParaJuros(double acrescimo, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = maxJuros / 2.0, minDiferenca = pow(0.1, precisao), pesoTotal = getPesoTotal();
	short indice = 0;
	if(maxIteracoes < 1 || Quantidade <= 0.0 || precisao < 1 || acrescimo <= 0.0 || Periodo <= 0.0 || maxJuros <= 0.0 || pesoTotal <= 0.0) return 0.0;

	for(indice = 0; indice < maxIteracoes; indice++) {
		medJuros = (minJuros + maxJuros) / 2;
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(jurosParaAcrescimo(medJuros) <= acrescimo)
			minJuros = medJuros; else maxJuros = medJuros;
	}

	return medJuros;
}

int main() {
	double pesoTotal, acrescimoCalculado, jurosCalculado;
	short indice;
	char buffer[256];

	 // define os valores de juros
	if(!setValores(3, 1, 30.0)) {
		printf("Erro ao definir os valores!");
		return -1;
	}

	for(indice = 0; indice < Quantidade; indice++) {
		Pesos[indice] = 1.0;
		Pagamentos[indice] = 30.0 * (indice + 1.0);
	}

	 // calcula, guarda e imprime os resultados
	pesoTotal = getPesoTotal();
	printf("Peso total: %3.15f\n", pesoTotal);
	acrescimoCalculado = jurosParaAcrescimo(3.0);
	printf("Acrescimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);
	printf("Juros calculado: %3.15f\n", jurosCalculado);

	// espera pressionar enter
	gets(buffer);

	 // libera a memoria e finaliza
	liberaMemoria();
	return 0;
}
