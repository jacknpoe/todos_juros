// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 11/06/2024: versão feita sem muito conhecimento de V

import math	// para pow()

// estrutura para simplificar as chamadas
struct Juros {
	quantidade int
	composto bool
	periodo f64
	pagamentos []f64
	pesos []f64
}

// calcula a somatória de Pesos[]
fn get_peso_total(ojuros Juros) f64 {
	mut acumulador := 0.0
	for indice in 0 .. ojuros.quantidade {
		acumulador += ojuros.pesos[indice]
	}
	return acumulador
}

// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
fn juros_para_acrescimo(ojuros Juros, juros f64) f64 {
	peso_total := get_peso_total(ojuros)
	if juros <= 0.0 || ojuros.quantidade < 1 || ojuros.periodo <= 0.0 || peso_total <= 0.0 {
		return 0.0
	}
	mut acumulador := 0.0

	for indice in 0 .. ojuros.quantidade {
		if ojuros.composto {
			acumulador += ojuros.pesos[indice] / math.pow(1.0 + juros / 100.0, ojuros.pagamentos[indice] / ojuros.periodo)
		} else {
			acumulador += ojuros.pesos[indice] / (1.0 + juros / 100.0 * ojuros.pagamentos[indice] / ojuros.periodo)
		}
	}

	return (peso_total / acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
fn acrescimo_para_juros(ojuros Juros, acrescimo f64, precisao int, max_iteracoes int, maximo_juros f64) f64 {
	peso_total := get_peso_total(ojuros)
	if acrescimo <= 0.0 || ojuros.quantidade < 1 || ojuros.periodo <= 0.0 || peso_total <= 0.0 || precisao < 1 || max_iteracoes < 1 || maximo_juros <= 0.0 {
		return 0.0
	}
	mut min_juros := 0.0
	mut med_juros := maximo_juros / 2.0
	mut max_juros := maximo_juros
	min_diferenca := math.pow(0.1, precisao)

	for _ in 0 .. max_iteracoes {
		med_juros = (min_juros + max_juros) / 2.0
		if (max_juros - min_juros) < min_diferenca {
			return med_juros
		}
		if juros_para_acrescimo(ojuros, med_juros) < acrescimo {
			min_juros = med_juros
		} else {
			max_juros = med_juros
		}
	}

	return med_juros
}

fn main() {
	// cria uma variável do tipo Juros e define seus valores
	mut ojuros := Juros {
		quantidade: 3
		composto: true
		periodo: 30.0
		pagamentos: [30.0, 60.0, 90.0]
		pesos: [1.0, 1.0, 1.0]
	}

	// calcula e guarda os retornos das funções
	peso_total := get_peso_total(ojuros)
	acrescimo_calculado := juros_para_acrescimo(ojuros, 3.0)
	juros_calculado := acrescimo_para_juros(ojuros, acrescimo_calculado, 15, 100, 50.0)

	// imprime os resultados
	C.printf(c'Peso total = %3.15f\n', peso_total)
	C.printf(c'Acréscimo = %3.15f\n', acrescimo_calculado)
	C.printf(c'Juros = %3.15f\n', juros_calculado)
}