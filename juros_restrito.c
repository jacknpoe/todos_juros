// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 23/07/2026: versão restrita e ainda mais otimizada do que juros_otomizado.c em C

// RESTRIÇÕES: acrescimoParaJuros tem todas as parcelas com peso 1.0, Quantidade funciona como o peso total,
//             os prazos dos parcelamentos são uma progressão aritmética crescente
//             (exatamente 1.0, 2.0, 3.0...), seguindo o indice do laço.

//  MECANISMO: quando a diferença do valor acumulado, entre duas iterações seguidas do laço que acumula as amortizações, for
//             zero (porque a representação de um double não tem precisão suficiente), o laço será terminado, já que nenhuma
//             iteração posterior irá alterar o resultado final, pois os parcelamentos são uma progressão aritmética 
//             crescente, o que gera termos adicionados exponencialmente decrescentes.

// RESULTADOS: para juros de 3.0%, no cálculo de juros compostos, o laço acumulador para na parcela número 1126,
//             ~1/266 do número de parcelas; nessa iteração, o valor de 1.0 / exp(fator * indice), com indice = 1126.0,
//             é tão pequeno que não consegue mais alterar acumulador; já no cálculo dos juros simples,
//             os valores não chegam a esse limiar.

//   OBJETIVO: esta implementação demonstra quanto desempenho pode ser obtido quando se restringe o problema a um
//             caso específico, sacrificando a generalidade da implementação original; não deve ser, de forma alguma,
//             utilizada como medida para avaliar compiladores ou os cálculos per se, pois ela se aproveita de uma
//             propriedade do algoritmo que torna as iterações restantes insignificantes para o resultado final.

//   MAXJUROS: maxJuros foi reduzido para 10.0, pois sabemos que os juros não serão maiores do que isso,
//             mas essa alteração é menor e não precisa de maiores explicações.

// PARA UMA PERSPECTIVA MATEMÁTICA: 1,03 ^ 1126 = 2,849148057 * 10^14  /  1 + 0,03 × 300000 = 900001

// COMPILAR: /opt/intel/oneapi/compiler/2026.0/bin/icx -O3 -ffast-math -march=native juros_restrito.c -o juros_restrito -lm

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
	
    if(Composto) {
        fator = log(1.0 + valor / 100.0);   // parte fixa do cálculo de juros compostos
	    for(indice = 1.0; indice <= Quantidade; indice++){
		    acumulador += 1.0 / exp(fator * indice);
            if(acumulador == anterior) break;
            anterior = acumulador;
        }
        // printf("Parcelas: %f\n", indice);
    } else {
        fator = valor / 100.0;   // parte fixa do cálculo de juros simples
        for(indice = 1.0; indice <= Quantidade; indice++)
            acumulador += 1.0 / (1.0 + fator * indice); 
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
	jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 10.0);  // ainda se pode diminuir 50.0 para outros máximos conhecidos de antemão
	printf("Juros calculado: %3.15f\n", jurosCalculado);

	return 0;
}
