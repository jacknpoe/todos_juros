module juros;

// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 22/06/2024: versão feita sem muito conhecimento de D

// classe com a estrutura básica para simplificar as chamadas
class Juros {
	int Quantidade;
	bool Composto;
	double Periodo;
	double[] Pagamentos;
	double[] Pesos;

	// construtor que recebe todos os valores dos atributos como parâmetros
	this(int quantidade, bool composto, double periodo, double[] pagamentos, double[] pesos){
		Quantidade = quantidade;
		Composto = composto;
		Periodo = periodo;
		Pagamentos = pagamentos;
		Pesos = pesos;
	}
	// calcula a somatória de Pesos[]
	double getPesoTotal() {
		double acumulador = 0.0;
		for(int indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
		return acumulador;
	}

	// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	double jurosParaAcrescimo(double juros){
		double pesoTotal = getPesoTotal();
		double acumulador = 0.0;
		if(juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0) return 0.0;

		for(int indice = 0; indice < Quantidade; indice++)
			if(Composto) { acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^^ (Pagamentos[indice] / Periodo); }
				else { acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo); }

		return (pesoTotal / acumulador - 1.0) * 100.0;
	}

	// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros){
		double pesoTotal = getPesoTotal();
		if(acrescimo <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
		double minJuros = 0.0;
		double medJuros;
		double minDiferenca = 0.1 ^^ precisao;

		for(int indice = 0; indice < maxIteracoes; indice++) {
			medJuros = (minJuros + maxJuros) / 2.0;
			if((maxJuros - minJuros) < minDiferenca) return medJuros;
			if(jurosParaAcrescimo(medJuros) < acrescimo) { minJuros = medJuros; } else { maxJuros = medJuros; }
		}

		return medJuros;
	}
}

int main()
{
	// cria juros com os dados
	Juros juros = new Juros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0]);

	// testa as funções, imprimindo os resultados
	import std.stdio : writefln;
	writefln("Peso Total = %.*g!", 15, juros.getPesoTotal());
	writefln("Acrescimo = %.*g!", 15, juros.jurosParaAcrescimo(3.0));
	writefln("Juros = %.*g!", 15, juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15, 100, 50.0));

    return 0;
}
