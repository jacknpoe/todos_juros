// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 03/04/2025: versão feita sem muito conhecimento de Gamma

require ("Application");

// classe juros com atributos que simplificam as chamadas aos métodos
class Juros {
	quantidade;
	composto;
	periodo;
	pagamentos = [];
	pesos = [];
}

// calcula a somatória de Pesos[]
method Juros.getPesoTotal () {
	local acumulador = 0.0;
	local indice;
	for(indice = 0; indice < self.quantidade; indice++) acumulador += self.pesos[indice];
	acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
method Juros.jurosParaAcrescimo(juros) {
	local pesoTotal = self.getPesoTotal();
	if(self.quantidade < 1 || self.periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) 0.0;
	else {
		local acumulador = 0.0;
		local indice;
		for(indice = 0; indice < self.quantidade; indice++)
			if(self.composto) acumulador += self.pesos[indice] / pow(1.0 + juros / 100.0, self.pagamentos[indice] / self.periodo);
				else acumulador += self.pesos[indice] / (1.0 + juros / 100.0 * self.pagamentos[indice] / self.periodo);
		if(acumulador <= 0.0) 0.0;
		(pesoTotal / acumulador - 1.0) * 100.0;
	}
}

// calcula os juros a partir do acréscimo e parcelas
method Juros.acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
	local pesoTotal = self.getPesoTotal();
	if(self.quantidade < 1 || self.periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) 0.0;
	else {
		local minJuros = 0.0;
		local medJuros = maxJuros / 2.0;
		local minDiferenca = pow(0.1, precisao);
		local indice;
		for(indice = 0; indice < maxIteracoes; indice++) {
			if(self.jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros; else maxJuros = medJuros;
			medJuros = (minJuros + maxJuros) / 2.0;
			if(maxJuros - minJuros < minDiferenca) indice = maxIteracoes;
		}
		medJuros;
	}
}


// classe que irá rodar no DataHub
class TesteJuros Application {}

// o mesmo que main()
method TesteJuros.constructor () {
	// cria um objeto juros do tipo Juros e inicializa (os arrays dinamicamente)
	local juros = new(Juros);
	juros.quantidade = 3;
	juros.composto = t;
	juros.periodo = 30.0;
	
	for(indice = 0; indice < juros.quantidade; indice++) {
		juros.pagamentos[indice] = (indice + 1.0) * juros.periodo;
		juros.pesos[indice] = 1.0;
	}

	// calcula e guarda os resultados dos métodos
	local pesoTotal = juros.getPesoTotal();
	local acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
	local jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

	// imprime os resultados
	princ(string("Peso total = ", pesoTotal, "\n"));
	princ(string("Acréscimo = ", acrescimoCalculado, "\n"));
	princ(string("Juros = ", jurosCalculado, "\n"));
}

ApplicationSingleton (TesteJuros);