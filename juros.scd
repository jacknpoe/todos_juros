// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 31/01/2025: versão feita sem muito conhecimento de SuperCollider

// variáveis globais (leia-se quantidade, composto, periodo, pagamentos e pesos
q = 3;
c = true;
p = 30.0;
a = [30.0, 60.0, 90.0];
e = [1.0, 1.0, 1.0];

// calcula a somatória de e[] (pesos)
~getPesoTotal = {
	var acumulador = 0.0;
	for(0, q-1, { arg indice;
		acumulador = acumulador + e[indice];
	});
	acumulador;
};

// calcula o acréscimo a partir dos juros e parcelas
~jurosParaAcrescimo = { arg juros;
	var pesoTotal = ~getPesoTotal.value();
	if((q < 1) || (p <= 0.0) || (juros <= 0.0) || (pesoTotal <= 0.0),
	{
		0.0;
	},{
		var acumulador = 0.0;

		for(0, q-1, { arg indice;
			if(c,
			{
				acumulador = acumulador + (e[indice] / ((1.0 + (juros / 100.0)) ** (a[indice] / p)));
			},{
				acumulador = acumulador + (e[indice] / (1.0 + (juros / 100.0 * a[indice] / p)));
			});
		});

		if(acumulador <= 0.0,
		{
			0.0;
		},{
			((pesoTotal / acumulador) - 1.0) * 100.0;
		});
	});
};

// calcula os juros a partir do acréscimo e parcelas
~acrescimoParaJuros = { arg acrescimo, precisao, maxIteracoes, maxJuros;
	var pesoTotal = ~getPesoTotal.value();
	if((q < 1) || (p <= 0.0) || (acrescimo <= 0.0) || (pesoTotal <= 0.0) || (precisao < 1) || (maxIteracoes < 1) || (maxJuros <= 0.0),
	{
		0.0;
	},{
		var minJuros = 0.0;
		var medJuros = maxJuros / 2.0;
		var minDiferenca = 0.1 ** precisao;
		var indice = 0;

		while({indice < maxIteracoes}, {
			medJuros = (minJuros + maxJuros) / 2.0;
			if((maxJuros - minJuros) < minDiferenca,
			{
				indice = maxIteracoes;
			},{
				if(~jurosParaAcrescimo.value(medJuros) < acrescimo,
				{
					minJuros = medJuros;
				},{
					maxJuros = medJuros;
				});
				indice = indice + 1;
			});
		});

		medJuros;
	});
};

// função de testes
~teste = {
	// calcula e guarda os resultados das funções
	var pesoTotal = ~getPesoTotal.value();
	var acrescimoCalculado = ~jurosParaAcrescimo.value(3.0);
	var jurosCalculado = ~acrescimoParaJuros.value( acrescimoCalculado, 15, 100, 50.0);

	// imprime os resultados
	("Peso total =" + pesoTotal.asString).postln;
	("Acréscimo =" + acrescimoCalculado.asString).postln;
	("Juros =" + jurosCalculado.asString).postln;
};

// executa a função de testes
~teste.value();

//var potencia = base ** expoente;
// ("Potência =" + potencia.asString).postln;
