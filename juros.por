// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 13/04/2024: versão feita sem muito conhecimento de Portugol

programa {
	// necessário para usar potencia()
	inclua biblioteca Matematica --> mat

	// dados globais, já que a linguagem não tem estruturas
	inteiro Quantidade = 0
	logico Composto = falso
	real Periodo = 0.0
	real Pagamentos[1000]
	real Pesos[1000]
	
	// calcula a somatória de Pesos[]
	funcao real getPesoTotal()  {
		real acumulador = 0.0

		para(inteiro indice = 0; indice < Quantidade; indice++){
			acumulador += Pesos[indice]
		}

		retorne acumulador
	}

	// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	funcao real jurosParaAcrescimo(real juros) {
		real pesoTotal
		real acumulador = 0.0

		se(juros <= 0.0 ou Quantidade <= 0 ou Periodo <= 0.0) { retorne 0.0 }
		pesoTotal = getPesoTotal()
		se(pesoTotal <= 0.0) { retorne 0.0 }

		para(inteiro indice = 0; indice < Quantidade; indice++) {
			se(Composto) {
				acumulador += Pesos[indice] / mat.potencia( 1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
			} senao {
				acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
			}
		}

		se(acumulador <= 0.0) { retorne 0.0 }
		retorne (pesoTotal / acumulador - 1.0) * 100.0
	}

	// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	funcao real acrescimoParaJuros(real acrescimo, real precisao, inteiro maxIteracoes, real maxJuros) {
		real pesoTotal
		real minJuros = 0.0
		real medJuros = maxJuros / 2.0
		real minDiferenca = mat.potencia(0.1, precisao)

		se(maxIteracoes < 1 ou Quantidade < 1 ou precisao < 1.0 ou Periodo <= 0.0 ou acrescimo <= 0.0 ou maxJuros <= 0.0) { retorne 0.0 }
		pesoTotal = getPesoTotal()
		se(pesoTotal <= 0.0) { retorne 0.0 }

		para(inteiro indice = 0; indice < maxIteracoes; indice++) {
			medJuros = (minJuros + maxJuros) / 2.0
			se((maxJuros - medJuros) < minDiferenca) { retorne medJuros }
			se(jurosParaAcrescimo(medJuros) < acrescimo) {
				minJuros = medJuros
			} senao {
				maxJuros = medJuros
			}
		}

		retorne medJuros
	}

	funcao inicio() {
		// define os valores para as variáveis globais
		Quantidade = 3
		Composto = verdadeiro
		Periodo = 30.0
		para(inteiro indice = 0; indice < 3; indice++) {
			Pagamentos[indice] = (indice + 1.0) * 30.0
			Pesos[indice] = 1.0
		}

		// testa as funções
		escreva("Peso Total = ", getPesoTotal(), "\n")
		escreva("Acréscimo = ", jurosParaAcrescimo(3.0), "\n")
		escreva("Juros = ", acrescimoParaJuros(jurosParaAcrescimo(3.0), 15.0, 100, 50.0), "\n")
	}
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 2242; 
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = ;
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */