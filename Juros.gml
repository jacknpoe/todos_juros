// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1:  27/01/2025: versão feita sem muito conhecimento de GML

// essa função converte um Real em String, respeitando o númnero de casas depois da vírgula
function toString(valor, casas) {
	valor *= round(power(10, casas));
	acumulador = "";
	
	while (valor > 0 || string_length(acumulador) < casas) {
		if (string_length(acumulador) == casas) { acumulador = "," + acumulador; }
		temp = valor % 10;
		valor = floor(valor / 10);
		acumulador = string("{0}", temp) + acumulador;
	}
	return acumulador;
}

// calcula a somatória do array Pesos[]
function getPesoTotal() {
	var acumulador = 0.0;
	for(var indice = 0; indice < global.Quantidade; indice++) {
		acumulador += global.Pesos[indice];
	}
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros) {
	var pesoTotal = getPesoTotal();
	if (juros <= 0 || global.Quantidade < 1 || global.Periodo <= 0.0 || pesoTotal <= 0.0) { return 0.0; }
	
	var acumulador = 0.0;
	
	for(var indice = 0; indice < global.Quantidade; indice++) {
		if (global.Composto) {
			acumulador += global.Pesos[indice] / power(1.0 + juros / 100.0, global.Pagamentos[indice] / global.Periodo);
		} else {
			acumulador += global.Pesos[indice] / (1.0 + juros / 100.0 * global.Pagamentos[indice] / global.Periodo);
		}
	}
	
	if (acumulador <= 0.0) { return 0.0; }
	return (pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
	var pesoTotal = getPesoTotal();
	if (acrescimo <= 0 || global.Quantidade < 1 || global.Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) { return 0.0; }

	var minJuros = 0.0, medJuros = maxJuros / 2.0, minDiferenca = power(0.1, precisao);
	
	for(var indice = 0; indice < maxIteracoes; indice++) {
		medJuros = (minJuros + maxJuros) / 2.0;
		if ((maxJuros - minJuros) < minDiferenca) {return medJuros; }
		if (jurosParaAcrescimo(medJuros) < acrescimo) {
			minJuros = medJuros;
		} else {
			maxJuros = medJuros;
		}
	}
	
	return medJuros;
}

function Juros(){
	// variáveis globais, para simplificar as chamadas
	global.Quantidade = 3;
	global.Composto = true;
	global.Periodo = 30.0;
	global.Pagamentos = [30.0, 60.0, 90.0];
	global.Pesos = [1.0, 1.0, 1.0];

	// calcula e guarda os resultados das funções
	var pesoTotal = getPesoTotal();
	var acrescimoCalculado = jurosParaAcrescimo(3.0);
	var jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

	// mostra os resultados
	show_message("Peso total = " + toString(pesoTotal, 15));
	show_message("Acréscimo = " + toString(acrescimoCalculado, 15));
	show_message("Juros = " + toString(jurosCalculado, 15));
}