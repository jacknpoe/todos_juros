#!/usr/bin/elvish

# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 01/03/2026: feita sem muito conhecimento de Elvish

use math

# inicialização de variáveis globais escalares para simplificar as chamadas
var Quantidade = 3
var Composto = $true
var Periodo = 30.0

# cria a lista Pagamentos
fn criaPagamentos {
    var indice = 1
    while (<= $indice $Quantidade) {
        put (* $indice $Periodo)
        set indice = (+ $indice 1)
    }
}

# cria a lista Pesos
fn criaPesos {
    var indice = 1
    while (<= $indice $Quantidade) {
        put 1.0
        set indice = (+ $indice 1)
    }
}

# inicialização dinâmica de listas globais para simplificar as chamadas
var Pagamentos = [(criaPagamentos)]
var Pesos = [(criaPesos)]

# calcula a somatória dos elementos de Pesos[]
fn getPesoTotal {
    var indice = 0
    var acumulador = 0.0
    while (< $indice $Quantidade) {
        set acumulador = (+ $acumulador $Pesos[$indice])
        set indice = (+ $indice 1)
    }
    put $acumulador
}

# calcula o acréscimo a partir dos juros e parcelas
fn jurosParaAcrescimo { |juros|
    var pesoTotal = (getPesoTotal)
    if (or (< $Quantidade 1) (or (<= $Periodo 0.0) (or (<= $pesoTotal 0.0) (<= $juros 0.0)))) {
        put 0.0
    } else {
        var indice = 0
        var acumulador = 0.0

        while (< $indice $Quantidade) {
            if $Composto {
                set acumulador = (+ $acumulador (/ $Pesos[$indice] (math:pow (+ 1.0 (/ $juros 100.0)) (/ $Pagamentos[$indice] $Periodo))))
            } else {
                set acumulador = (+ $acumulador (/ $Pesos[$indice] (+ 1.0 (* (/ $juros 100.0) (/ $Pagamentos[$indice] $Periodo)))))
            }
            set indice = (+ $indice 1)
        }

        if (<= $acumulador 0.0) {
            put 0.0
        } else {
            put (* (- (/ $pesoTotal $acumulador) 1.0) 100.0)
        }
    }
}

# calcula os juros a partir do acréscimo e parcelas
fn acrescimoParaJuros { |acrescimo precisao maxIteracoes maxJuros|
    var pesoTotal = (getPesoTotal)
    if (or (< $Quantidade 1) (or (<= $Periodo 0.0) (or (<= $pesoTotal 0.0) (or (<= $acrescimo 0.0) (or (< $precisao 1) (or (< $maxIteracoes 1) (<= $maxJuros 0.0))))))) {
        put 0.0
    } else {
        var indice = 0
        var minJuros = 0.0
        var medJuros = (/ $maxJuros 2.0)
        var minDiferenca = (math:pow 0.1 $precisao)

        while (< $indice $maxIteracoes) {
            if (< (- $maxJuros $minJuros) $minDiferenca) { set indice = $maxIteracoes } else {
                if (< (jurosParaAcrescimo $medJuros) $acrescimo) {
                    set minJuros = $medJuros
                } else {
                    set maxJuros = $medJuros
                }
                set medJuros = (/ (+ $minJuros $maxJuros) 2.0)
            }
            set indice = (+ $indice 1)
        }

        put $medJuros
    }
}

# calcula e guarda os valores retornados das funções
var pesoTotal = (getPesoTotal)
var acrescimoCalculado = (jurosParaAcrescimo 3.0)
var jurosCalculado = (acrescimoParaJuros $acrescimoCalculado 15 65 50.0)

# imprime os resultados
echo 'Peso total =' $pesoTotal
echo 'Acréscimo =' $acrescimoCalculado
echo 'Juros =' $jurosCalculado
