// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 26/01/2025: versão de testes a partir da de JavaScript

// classe com os valores globais para simplificar as chamadas
class Juros{
	constructor(quantidade=0, composto=false, periodo=30){
		this.Quantidade = quantidade
		this.Composto = composto
		this.Periodo = periodo
		this.Pagamentos = new Array(0)
		this.Pesos = new Array(0)
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPagamentos(delimitador=",", pagamentos=""){
		if( pagamentos == ""){
			for(let c = 0; c < this.Quantidade; c++){
				this.Pagamentos[c] = (1 + c) * this.Periodo
			}
		} else {
			let temporaria = pagamentos.split(delimitador)
			for(let c = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false
				this.Pagamentos[c] = Number(temporaria[c])
			}
		}
		return true
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPesos(delimitador=",", pesos=""){
		if( pesos == ""){
			for(let c = 0; c < this.Quantidade; c++){
				this.Pesos[c] = 1
			}
		} else {
			let temporaria = pesos.split(delimitador)
			for(let c = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false
				this.Pesos[c] = Number(temporaria[c])
			}
		}
		return true
	}

	// Retorna a soma total de todos os pesos
	getPesoTotal(){
		let acumulador = 0
		for(let c = 0; c < this.Quantidade; c++){
			acumulador += this.Pesos[c]
		}
		return acumulador
	}

	// Calcula o acréscimo a partir dos juros
	jurosParaAcrescimo(juros=0){
		if(juros == 0 || this.Quantidade == 0 || this.Periodo == 0) return 0

		let total = this.getPesoTotal()
		let acumulador = 0

		for(let i = 0; i < this.Quantidade; i++){
			if(this.Composto){
				acumulador += this.Pesos[i] / ((1 + juros / 100) ** (this.Pagamentos[i] / this.Periodo))
			} else{
				acumulador += this.Pesos[i] / (1 + juros / 100 * this.Pagamentos[i] / this.Periodo)
			}
		}

		if (acumulador <= 0) return 0
		return (total / acumulador - 1) * 100
	}

	// Calcula os juros a partir do acréscimo
	acrescimoParaJuros(acrescimo=0, precisao=15, maximoInteracoes=100, maximoJuros=50, acrescimoComoValorOriginal=false){
		if(maximoInteracoes < 1 || this.Quantidade < 1 || precisao < 1 || this.Periodo < 1 || acrescimo <= 0 ) return 0

		let minimoJuros = 0
		let medioJuros = 0
		let total = this.getPesoTotal()

		if(total == 0) return 0

		if(acrescimoComoValorOriginal){
			acrescimo = 100 * (total / acrescimo - 1)
			if(acrescimo <= 0) return 0
		}

		var minimaDiferenca = 0.1 ** precisao

		for(let i = 0; i < maximoInteracoes; i++){
			medioJuros = (minimoJuros + maximoJuros) / 2
			if((maximoJuros - minimoJuros) < minimaDiferenca) return medioJuros
			if(this.jurosParaAcrescimo(medioJuros) <= acrescimo){
				minimoJuros = medioJuros
			} else{
				maximoJuros = medioJuros
			}
		}

		return medioJuros
	}
}

// cria o objeto juros da classe Juros e define os valores
let juros = new Juros(3, true, 30.0)
juros.setPagamentos(",", "30,60,90")
juros.setPesos(",", "1,1,1")

// calcula e guarda os resultados das funções
let pesoTotal = juros.getPesoTotal()
let acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
let jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 18, 100, 50.0, false)

// imprime os resultados
console.log( "Peso total = " + pesoTotal)
console.log( "Acréscimo = " + acrescimoCalculado)
console.log( "Juros = " + jurosCalculado)