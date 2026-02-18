// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 17/02/2026: a partir da solução para C, sem saber muito sobre Embedded C, com orientação do ChatGPT (principalmente no processo de compilação e execução em ambiente Embedded)
//        0.2: 18/02/2026: melhoradas validações e atribuições em pesoTotal nas funções
// COMPILAR COM: arm-none-eabi-gcc -mcpu=cortex-m3 -mthumb -O2 -Wall -Wextra -Wpedantic startup.c jurosELF.c -T linker.ld -specs=rdimon.specs -lc -lrdimon -lm -nostartfiles -o jurosELF.elf
// RODAR COM: qemu-system-arm -M lm3s6965evb -kernel jurosELF.elf -nographic -semihosting
// deve estar claro que arm-none-eabi-gcc e qemu-system-arm precisam estar instalados via sudo apt install

#include <math.h>      // para usar pow()
#include <stdio.h>     // para usar printf() e gets()
#include <stdlib.h>    // para usar malloc() e free()
#include <stdbool.h>   // para usar o tipo booleano
#include <locale.h>    // para usar setlocale()

// função que inicializa o handler do monitor para poder ter saída com printf()s
extern void initialise_monitor_handles(void);

// estrutura básica de propriedades para simplificar as chamadas
struct Juros {
	int Quantidade;
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
bool setQuantidade(struct Juros *juros, int quantidade) {
	if(quantidade < 0) return false;
	if(quantidade == juros->Quantidade) return true;
	juros->Pagamentos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pagamentos == NULL) { juros->Quantidade = 0; return false; }
	juros->Pesos = (double *) malloc(sizeof(double) * quantidade);
	if(quantidade > 0 && juros->Pesos == NULL) { free(juros->Pagamentos); juros->Quantidade = 0; return false; }
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
	double pesoTotal = getPesoTotal(juros);
	if(valor <= 0 || juros->Quantidade <= 0 || juros->Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
	double acumulador = 0; 
	int indice;
	
	for(indice = 0; indice < juros->Quantidade; indice++) {
		if(juros->Composto) acumulador += juros->Pesos[indice] / pow(1 + valor / 100, juros->Pagamentos[indice] / juros->Periodo);
			else acumulador += juros->Pesos[indice] / (1 + valor / 100 * juros->Pagamentos[indice] / juros->Periodo);
	}
	
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1) * 100;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(struct Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0, medJuros = 0, minDiferenca = 0;
	short indice = 0;
	double pesoTotal = getPesoTotal(juros);
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
    // inicializa o handler do monitor para poder ter saída com printf()s
    initialise_monitor_handles();

    // define os valores de juros
	struct Juros juros;
	double pesoTotal = 0, acrescimoCalculado = 0, jurosCalculado = 0;
	int indice;

	setlocale( LC_ALL, "");	

	if(!setValores(&juros, 3, true, 30.0)) {
		printf("Erro ao definir os valores da estrutura juros!");
		return -1;
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

    // libera a memória e fica em laço
	liberaMemoria(&juros);
    while (1) {}
}
