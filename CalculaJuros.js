// Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso
// Versão 1.0: ??/??/????: versão inclusa no HTML
//        1.1: 26/09/2023: versão separada no arquivo CalculaJuros.js
//        1.2: 03/03/2024: correção (não aceitava acréscimo menor que 1%)
//        1.3: 16/10/2024: adicionado botão "Valores Exemplo"
//        1.4: 23/02/2025: separando a classe das funções (+ ; e .0)
//        1.5: 24/02/2025: (+ ; e .0)
//        1.6: 12/02/2026: na linha 88 estava peso em vez de pesoTotal

export class CalculaJuros{
	constructor(quantidade=0, composto=false, periodo=30.0){
		this.Quantidade = quantidade;
		this.Composto = composto;
		this.Periodo = periodo;
		this.Pagamentos = new Array(0);
		this.Pesos = new Array(0);
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPagamentos(delimitador=",", pagamentos=""){
		if( pagamentos == ""){
			for(let c = 0; c < this.Quantidade; c++){
				this.Pagamentos[c] = (1.0 + c) * this.Periodo;
			}
		} else {
			let temporaria = pagamentos.split(delimitador);
			for(let c = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false;
				this.Pagamentos[c] = Number(temporaria[c]);
			}
		}
		return true;
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPesos(delimitador=",", pesos=""){
		if( pesos == ""){
			for(let c = 0; c < this.Quantidade; c++){
				this.Pesos[c] = 1.0;
			}
		} else {
			let temporaria = pesos.split(delimitador);
			for(let c = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false;
				this.Pesos[c] = Number(temporaria[c]);
			}
		}
		return true;
	}

	// Retorna a soma total de todos os pesos
	getPesoTotal(){
		let acumulador = 0.0;
		for(let c = 0; c < this.Quantidade; c++){
			acumulador += this.Pesos[c];
		}
		return acumulador;
	}

	// Calcula o acréscimo a partir dos juros
	jurosParaAcrescimo(juros=0.0){
		let pesoTotal = this.getPesoTotal();
		if(juros <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;

		let acumulador = 0.0;

		for(let i = 0; i < this.Quantidade; i++){
			if(this.Composto){
				acumulador += this.Pesos[i] / ((1.0 + juros / 100.0) ** (this.Pagamentos[i] / this.Periodo));
			} else{
				acumulador += this.Pesos[i] / (1.0 + juros / 100.0 * this.Pagamentos[i] / this.Periodo);
			}
		}

		if (acumulador <= 0.0) return 0.0;
		return (pesoTotal / acumulador - 1.0) * 100.0;
	}

	// Calcula os juros a partir do acréscimo
	acrescimoParaJuros(acrescimo=0.0, precisao=15, maximoInteracoes=100, maximoJuros=50.0, acrescimoComoValorOriginal=false){
		let pesoTotal = this.getPesoTotal();
		if(maximoInteracoes < 1 || this.Quantidade < 1 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0.0 || maximoJuros <= 0.0 || pesoTotal <= 0.0) return 0.0;

		let minimoJuros = 0.0;
		let medioJuros = 0.0;

		if(acrescimoComoValorOriginal){
			acrescimo = 100.0 * (pesoTotal / acrescimo - 1.0);
			if(acrescimo <= 0.0) return 0.0;
		}

		var minimaDiferenca = 0.1 ** precisao;

		for(let i = 0; i < maximoInteracoes; i++){
			medioJuros = (minimoJuros + maximoJuros) / 2.0;
			if((maximoJuros - minimoJuros) < minimaDiferenca) return medioJuros;
			if(this.jurosParaAcrescimo(medioJuros) <= acrescimo){
				minimoJuros = medioJuros;
			} else{
				maximoJuros = medioJuros;
			}
		}

		return medioJuros;
	}
}
