# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 03/06/2024: versão feita sem muito conhecimento de Golo

module juros

import java.lang.Math	# para pow()

# estrutura básica para simplificar as chamadas
struct Juros = {
	quantidade,
	composto,
	periodo,
	pagamentos,
	pesos
}

# calcula a somatória de Pesos[]
function getPesoTotal = |sjuros| {
	var acumulador = 0.0
	for(var indice = 0, indice < sjuros: quantidade(), indice = indice + 1) {
		acumulador = acumulador + sjuros: pesos(): get(indice)
	}
	return acumulador
}

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
function jurosParaAcrescimo = |sjuros, juros| {
	let pesoTotal = getPesoTotal(sjuros)
	if (juros < 0.0 or sjuros: quantidade() < 1 or sjuros: periodo() <= 0.0 or pesoTotal <= 0.0) { return 0.0 }
	var acumulador = 0.0

	for(var indice = 0, indice < sjuros: quantidade(), indice = indice + 1) {
		if (sjuros: composto()){
			acumulador = acumulador + sjuros: pesos(): get(indice) / Math.pow(1.0 + juros / 100.0, sjuros: pagamentos(): get(indice) / sjuros: periodo())
		} else {
			acumulador = acumulador + sjuros: pesos(): get(indice) / (1.0 + juros / 100.0 * sjuros: pagamentos(): get(indice) / sjuros: periodo())
		}
	}

	return (pesoTotal / acumulador - 1.0) * 100.0
}

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
function acrescimoParaJuros = |sjuros, acrescimo, precisao, maxIteracoes, maximoJuros| {
	let pesoTotal = getPesoTotal(sjuros)
	if (maxIteracoes < 1 or sjuros: quantidade() < 1 or precisao <= 0.0 or sjuros: periodo() <= 0.0 or acrescimo <= 0.0 or maximoJuros <= 0.0 or pesoTotal <= 0.0) { return 0.0 }
	var minJuros = 0.0
	var medJuros = maximoJuros / 2.0
	var maxJuros = maximoJuros
	let minDiferenca = Math.pow(0.1, precisao)

	for(var indice = 0, indice < maxIteracoes, indice = indice + 1) {
		medJuros = (minJuros + maxJuros) / 2.0
		if ((maxJuros - minJuros) < minDiferenca) { return medJuros }
		if (jurosParaAcrescimo(sjuros, medJuros) < acrescimo) {
			minJuros = medJuros
		} else {
			maxJuros = medJuros
		}
	}

	return medJuros
}

function main = |args| {
	# cria o objeto juros da estrutura Juros, e inicializa os atributos
	let juros = Juros(3, true, 30.0, Array(30.0, 60.0, 90.0), Array(1.0, 1.0, 1.0))

	# testa os resultados das funções
	let pesoTotal = getPesoTotal(juros)
	let acrescimoCalculado = jurosParaAcrescimo(juros, 3.0)
	let jurosCalculado = acrescimoParaJuros(juros, acrescimoCalculado, 15.0, 100, 50.0)

	# imprime os resultados
	println("Peso total = " + pesoTotal)
	println("Acréscimo = " + acrescimoCalculado)
	println("Juros = " + jurosCalculado)
}