// Classe que faz o cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 03/03/2024: cópia do código JavaScript e definição das propriedades
//        0.2: 03/03/2024: colocados tipos e ";"s

export class Juros{
    public Quantidade: number;
    public Composto: boolean;
    public Periodo: number;
    public Pagamentos: number[] = [];
    public Pesos: number[] = [];

    constructor(quantidade=0, composto=false, periodo=30){
		this.Quantidade = quantidade;
		this.Composto = composto;
		this.Periodo = periodo;
		this.Pagamentos = new Array(quantidade);
		this.Pesos = new Array(quantidade);
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPagamentos(delimitador: string = ",", pagamentos: string = "") : boolean {
		if(pagamentos == ""){
			for(let c: number = 0; c < this.Quantidade; c++){
				this.Pagamentos[c] = (1 + c) * this.Periodo;
			}
		} else {
			let temporaria: string[] = pagamentos.split(delimitador)
			for(let c: number = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false;
				this.Pagamentos[c] = Number(temporaria[c]);
			}
		}
		return true;
	}

	// "Define as datas de pagamento a partir de uma string separada pelo delimitador
	setPesos(delimitador: string = ",", pesos: string = "") : boolean {
		if(pesos == ""){
			for(let c: number = 0; c < this.Quantidade; c++){
				this.Pesos[c] = 1;
			}
		} else {
			let temporaria: string[] = pesos.split(delimitador)
			for(let c: number = 0; c < this.Quantidade; c++){
				if(isNaN(Number(temporaria[c]))) return false;
				this.Pesos[c] = Number(temporaria[c]);
			}
		}
		return true;
	}

	// "Retorna a soma total de todos os pesos
	getPesoTotal() : number {
		let acumulador: number = 0.0;
		for(let c = 0; c < this.Quantidade; c++){
			acumulador += this.Pesos[c];
		}
		return acumulador;
	}

	// "Calcula o acréscimo a partir dos juros
	jurosParaAcrescimo(juros: number = 0.0) : number {
		if(juros <= 0.0 || this.Quantidade < 1 || this.Periodo < 1) return 0.0;

		let pesoTotal : number = this.getPesoTotal();
		let acumulador: number = 0.0;
		let soZero: boolean = true;

		for(let i: number = 0; i < this.Quantidade; i++){
			if(this.Pagamentos[i] > 0 && this.Pesos[i] > 0) soZero = false;
			if(this.Composto){
				acumulador += this.Pesos[i] / ((1 + juros / 100) ** (this.Pagamentos[i] / this.Periodo));
			} else{
				acumulador += this.Pesos[i] / ((1 + juros / 100) * this.Pagamentos[i] / this.Periodo);
			}
		}

		if(soZero) return 0.0;
		return (pesoTotal / acumulador - 1) * 100;
	}

	// "Calcula os juros a partir do acréscimo
	acrescimoParaJuros(acrescimo: number = 0.0, precisao: number = 15, maximoInteracoes: number = 100, maximoJuros: number = 50.0, acrescimoComoValorOriginal: boolean = false) : number {
		if(maximoInteracoes < 1 || this.Quantidade < 1 || precisao < 1 || this.Periodo < 1 || acrescimo <= 0 ) return 0.0;

		let minimoJuros: number = 0.0;
		let medioJuros: number = 0.0;
		let pesoTotal: number = this.getPesoTotal();

		if(pesoTotal <= 0) return 0.0;

		if(acrescimoComoValorOriginal){
			acrescimo = 100 * (pesoTotal / acrescimo - 1);
			if(acrescimo <= 0) return 0.0;
		}

		var minimaDiferenca: number = 0.1 ** precisao;

		for(let i = 0; i < maximoInteracoes; i++){
			medioJuros = (minimoJuros + maximoJuros) / 2;
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
