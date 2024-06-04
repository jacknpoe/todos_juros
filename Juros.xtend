// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 03/06/2024: versão feita sem muito conhecimento de Xtend

package org.xtext.example.mydsl

// classe com atributos para simplificar as chamadas
class Juros {
	var int quantidade = 0
	var boolean composto = false
	var double periodo = 0.0
	var double[] pagamentos = #[]
	var double[] pesos = #[]
	
	// construtor que inicializa os atriburos
	new(int quantidade, boolean composto, double periodo, double[] pagamentos, double[] pesos) {
		this.quantidade = quantidade
		this.composto = composto
		this.periodo = periodo
		this.pagamentos = pagamentos
		this.pesos = pesos
	}
	
	// calcula a somatória de Pesos[]
	def double getPesoTotal() {
		var double acumulador = 0.0
		for(var int indice = 0; indice < this.quantidade; indice++) {
			acumulador  += this.pesos.get(indice)
		}
		return acumulador
	}

	// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	def double jurosParaAcrescimo(double juros) {
		var pesoTotal = this.getPesoTotal()
		if (juros <= 0.0 || this.quantidade < 1 || this.periodo <= 0.0 || pesoTotal <= 0.0) { return 0.0 }
		var double acumulador = 0.0
		
		for(var int indice = 0; indice < this.quantidade; indice++) {
			if (this.composto) {
				acumulador += this.pesos.get(indice) / (1.0 + juros / 100.0) ** (this.pagamentos.get(indice) / this.periodo)
			} else {
				acumulador += this.pesos.get(indice) / (1.0 + juros / 100.0 * this.pagamentos.get(indice) / this.periodo)
			}
		}
		
		return (pesoTotal / acumulador - 1.0) * 100.0
	}

	// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	def double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maximoJuros) {
		var pesoTotal = this.getPesoTotal()
		if (maxIteracoes < 1 || this.quantidade <= 0.0 || precisao < 1 || this.periodo <= 0.0 || acrescimo <= 0.0 || maximoJuros <= 0.0 || pesoTotal <= 0.0) { return 0.0 }
		var double minJuros = 0.0
		var double medJuros = maximoJuros / 2.0
		var double maxJuros = maximoJuros
		var double minDiferenca = 0.1 ** precisao
		
		for(var int indice = 0; indice < maxIteracoes; indice++) {
			medJuros = (minJuros + maxJuros) / 2.0
			if ((maxJuros - minJuros) < minDiferenca) { return medJuros }
			if (this.jurosParaAcrescimo(medJuros) < acrescimo) {
				minJuros = medJuros
			} else {
				maxJuros = medJuros
			}
		}
		
		return medJuros		
	}


	def static void main(String[] args) {
		// cria um objeto juros da classe Juros e inicializa os atributos
		var Juros juros = new Juros(3, true, 30.0, #[30.0, 60.0, 90,0], #[1.0, 1.0, 1.0])
		
		// guarda o resultado dos métodos
		var double pesoTotal = juros.getPesoTotal()
		var double acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
		var double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)
		
		// imprime os resultados
		print("Peso total = ")
		println(pesoTotal.toString)
		print("Acréscimo = ")
		println(acrescimoCalculado.toString)
		print("Juros = ")
		println(jurosCalculado.toString)
	}
}