// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 06/04/2025: versão feita sem muito conhecimento de Odin

package main

import "core:fmt"  // para fmt.println
import "core:math/linalg"  // para lingalg.pow()

// variáveis globais para simplificar as chamadas
quantidade: int;
composto: bool;
periodo: f64;
pagamentos: [dynamic]f64;
pesos: [dynamic]f64;

// calcula a somatória de pesos[]
get_peso_total :: proc() -> f64 {
    acumulador: f64 = 0.0
    for indice in 0..<quantidade { acumulador += pesos[indice] }
    return acumulador
}

// calcula o acréscimo a partir dos juros e parcelas
juros_para_acrescimo :: proc(juros: f64) -> f64 {
    peso_total: f64 = get_peso_total()
    if quantidade < 1 || periodo <= 0.0 || peso_total <= 0.0 || juros <= 0.0 { return 0.0 }

    acumulador: f64 = 0.0
    for indice in 0..<quantidade {
        if composto { acumulador += pesos[indice] / linalg.pow(1.0 + juros / 100.0, pagamentos[indice] / periodo) }
            else { acumulador += pesos[indice] / (1.0 + juros / 100.0 * pagamentos[indice] / periodo) }
    }
    if acumulador <= 0.0 { return 0.0 }
    return (peso_total / acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e parcelas
acrescimo_para_juros :: proc(acrescimo: f64, precisao: int, max_iteracoes: int, maximo_juros: f64) -> f64 {
    peso_total: f64 = get_peso_total()
    if quantidade < 1 || periodo <= 0.0 || peso_total <= 0.0 || acrescimo <= 0.0 || precisao < 1 || max_iteracoes < 1 || maximo_juros <= 0.0 { return 0.0 }

    min_juros: f64 = 0.0
    med_juros: f64 = maximo_juros / 2.0
    max_juros: f64 = maximo_juros
    min_diferenca: f64 = linalg.pow(0.1, f64(precisao))
    for indice in 0..<max_iteracoes {
        if max_juros - min_juros < min_diferenca { return med_juros }
        if juros_para_acrescimo(med_juros) < acrescimo { min_juros = med_juros} else { max_juros = med_juros }
        med_juros = (min_juros + max_juros) / 2.0
    }
    return med_juros
}

main :: proc() {
    // inicia as variáveis globais, os arrays dinamicamente
    quantidade = 3;
    composto = true;
    periodo = 30.0;

    for indice in 0..<quantidade {
        append(&pagamentos, (f64(indice) + 1.0) * periodo)
        append(&pesos, 1.0)
    }

    // calcula e guarda os resultados das funções
    peso_total: f64 = get_peso_total()
    acrescimo_calculado: f64 = juros_para_acrescimo(3.0)
    juros_calculado: f64 = acrescimo_para_juros(acrescimo_calculado, 15, 100, 50.0)

    // imprime os resultados
    fmt.println("Peso total = ", peso_total)
    fmt.println("Acrescimo = ", acrescimo_calculado)
    fmt.println("Juros = ", juros_calculado)
}