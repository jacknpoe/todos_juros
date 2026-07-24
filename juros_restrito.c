// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 23/07/2026: versão restrita e ainda mais otimizada doque juros_otomizado.c em C
// COMPILAR COM O COMPILADOR MAIS RÁPIDO (C)
// /opt/intel/oneapi/compiler/2026.0/bin/compiler/clang -O3 -ffast-math -march=native juros_restrito.c -o juros_restrito -lm
// TESTAR PARA VER SE ESSE COMPILADOR É MAIS RÁPIDO (C++)
// /opt/intel/oneapi/compiler/2026.0/bin/icpx -O3 -ffast-math -march=native -std=c++20 arquivo.cpp -o arquivo -lm

#include <math.h>      // para usar exp(), log(), pow()
#include <stdio.h>     // para usar printf()

#define true 1
#define false 0

// variáveis para simplificar as chamadas
double Quantidade;
int Composto;

// calcula o acréscimo a partir dos juros e parcelas
double jurosParaAcrescimo(double valor) {
	if(valor <= 0.0 || Quantidade < 1.0) return 0.0;
	double acumulador = 0.0, anterior = 0.0, indice, fator;
	
    // essa tentativa de inverter o for com if/else dentro por um if/else com dois for dentro não resultou no ganho de eficiêncoa esperado
    if(Composto) {
        fator = log(1.0 + valor / 100.0);   // parte fixa do cálculo de juros compostos
	    for(indice = 1.0; indice <= Quantidade; indice++){
		    acumulador += 1.0 / exp(fator * indice);
            if(acumulador == anterior) break;
            anterior = acumulador;
        }
    } else {
        fator = valor / 100.0;   // parte fixa do cálculo de juros simples
        for(indice = 1.0; indice <= Quantidade; indice++) {
            acumulador += 1.0 / (1.0 + fator * indice);
        }
    }
	
	if( acumulador <= 0.0 ) return 0.0;
	return(Quantidade / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimoParaJuros(double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = (minJuros + maxJuros) / 2.0, minDiferenca = pow(0.1, precisao);
	short indice;
	if(maxIteracoes < 1 || Quantidade < 1.0 || precisao < 1 || valor <= 0.0 || maxJuros <= 0.0) return 0.0;

	for(indice = 0; indice < maxIteracoes; indice++) {
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(jurosParaAcrescimo(medJuros) <= valor)
			minJuros = medJuros; else maxJuros = medJuros;
		medJuros = (minJuros + maxJuros) / 2.0;
	}
	
	return medJuros;
}

int main() {
    // variáveis que guardarão os resultados das funções
	double acrescimoCalculado, jurosCalculado;
	int indice;

    Quantidade = 300000.0;
	Composto = true;

    // calcula, guarda e imprime os resultados
	acrescimoCalculado = jurosParaAcrescimo(3.0);
	printf("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);  // ainda se pode diminuir 50.0 para outros máximos conhecidos de antemão
	printf("Juros calculado: %3.15f\n", jurosCalculado);

	return 0;
}
