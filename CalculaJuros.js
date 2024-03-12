// Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso
// Versão 1.0: ??/??/????: versão inclusa no HTML
// Versão 1.1: 26/09/2023: versão separada no arquivo CalculaJuros.js
// Versão 1.2: 03/03/2024: correção (não aceitava acréscimo menor que 1%)
// TODO: colocar a classe em um arquivo separado (como com aula93.js e cursos2.js)

class CalculaJuros{
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
		let soZero = true

		for(let i = 0; i < this.Quantidade; i++){
			if(this.Pagamentos[i] > 0 && this.Pesos[i] > 0) soZero = false
			if(this.Composto){
				acumulador += this.Pesos[i] / ((1 + juros / 100) ** (this.Pagamentos[i] / this.Periodo))
			} else{
				acumulador += this.Pesos[i] / (1 + juros / 100 * this.Pagamentos[i] / this.Periodo)
			}
		}

		if(soZero) return 0
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

function calcular(){
	let quantidade = Number(window.document.getElementById("quantidade").value)
	let tipo = window.document.getElementsByName("tipo")
	tipo = ! tipo[0].checked
	let periodo = Number(window.document.getElementById("periodo").value)
	let pesos = window.document.getElementById("pesos").value
	let pagamentos = window.document.getElementById("pagamentos").value
	let calculo = window.document.getElementsByName("calculo")
	calculo = calculo[0].checked
	let percentual = Number(window.document.getElementById("valor").value.replace(",", "."))
	let resultado = window.document.getElementById("resultado")

	let juros = new CalculaJuros(quantidade, tipo, periodo)
	if(! juros.setPesos(",", pesos)){
		window.alert(`Você deve informar ${quantidade} pesos numéricos ou vazio!`)
		window.document.getElementById("pesos").focus()
		return
	}
	if(! juros.setPagamentos(",", pagamentos)){
		window.alert(`Você deve informar ${quantidade} pagamentos numéricos ou vazio!`)
		window.document.getElementById("pagamentos").focus()
		return
	}

	let res_numb = ""
	if(calculo){
		res_numb = "" + juros.jurosParaAcrescimo(percentual)
	} else{
		res_numb = "" + juros.acrescimoParaJuros(percentual, 18)
	}
	res_numb = res_numb.replace(".", ",")
	resultado.innerText = "Resultado: " + res_numb + "%"
}
