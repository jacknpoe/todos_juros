// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 14/03/2025: versão de testes a partir da de JScript

// classe com os valores globais para simplificar as chamadas
class Juros {
	var Quantidade
	var Composto
	var Periodo
	var Pagamentos
	var Pesos
	
	function Juros(quantidade, composto, periodo) {
		this.Quantidade = quantidade
		this.Composto = composto
		this.Periodo = periodo
		this.Pagamentos = new Array(quantidade)
		this.Pesos = new Array(quantidade)
	}

	// Retorna a soma total de todos os pesos
	function getPesoTotal() {
		var acumulador = 0
		for(var c = 0; c < this.Quantidade; c++) {
			acumulador += this.Pesos[c]
		}
		return acumulador
	}

	// Calcula o acréscimo a partir dos juros
	function jurosParaAcrescimo(juros) {
		if(juros == 0 || this.Quantidade == 0 || this.Periodo == 0) return 0

		var total = this.getPesoTotal()
		var acumulador = 0

		for(var i = 0; i < this.Quantidade; i++) {
			if(this.Composto) {
				acumulador += this.Pesos[i] / Math.pow(1 + juros / 100, this.Pagamentos[i] / this.Periodo)
			} else {
				acumulador += this.Pesos[i] / (1 + juros / 100 * this.Pagamentos[i] / this.Periodo)
			}
		}

		if (acumulador <= 0) return 0
		return (total / acumulador - 1) * 100
	}

	// Calcula os juros a partir do acréscimo
	function acrescimoParaJuros(acrescimo, precisao, maximoInteracoes, maximoJuros, acrescimoComoValorOriginal) {
		if(maximoInteracoes < 1 || this.Quantidade < 1 || precisao < 1 || this.Periodo < 1 || acrescimo <= 0 ) return 0

		var minimoJuros = 0
		var medioJuros = 0
		var total = this.getPesoTotal()

		if(total == 0) return 0

		if(acrescimoComoValorOriginal) {
			acrescimo = 100 * (total / acrescimo - 1)
			if(acrescimo <= 0) return 0
		}

		var minimaDiferenca = Math.pow(0.1, precisao)

		for(var i = 0; i < maximoInteracoes; i++) {
			medioJuros = (minimoJuros + maximoJuros) / 2
			if((maximoJuros - minimoJuros) < minimaDiferenca) return medioJuros
			if(this.jurosParaAcrescimo(medioJuros) <= acrescimo) {
				minimoJuros = medioJuros
			} else {
				maximoJuros = medioJuros
			}
		}

		return medioJuros
	}
}

// cria o objeto juros da classe Juros e define os valores
var juros = new Juros(3, true, 30.0)
for(var indice = 0; indice < juros.Quantidade; indice++) {
	juros.Pagamentos[indice] = (1.0 + indice) * 30.0
	juros.Pesos[indice] = 1.0
}

// caLcula e guarda os resultados das funções
var pesoTotal = juros.getPesoTotal()
var acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
var jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 18, 100, 50.0, false)

// imprime os resultados
print( "Peso total = " + pesoTotal)
print( "Acréscimo = " + acrescimoCalculado)
print( "Juros = " + jurosCalculado)