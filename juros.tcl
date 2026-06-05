# Cálculo dos juros, sendo que precisa de arrays para isso
# Versão 0.1: 05/06/2024: versão feita sem muito conhecimento de Tcl
#        0.2: 18/07/2025: variáveis e arrays dinâmicos
#        0.3: 05/06/2026: melhorias nas expressões com ajuda do ChatGPT, incluindo "my" no lugar de "juros"

# importa pow para o cálculo de juros compostos e mínima diferença
namespace import ::tcl::mathfunc::pow

#estrutura básica para simplificar as chamadas
oo::class create Juros {
    variable Quantidade
    variable Composto
    variable Periodo
    variable Pagamentos
    variable Pesos

    # construtor, para inicializar os atributos
    constructor { quantidade composto periodo } {
        set Quantidade $quantidade
        set Composto $composto
        set Periodo $periodo
        array set Pagamentos {}
        array set Pesos {}
    }

    method setPagamento { indice valor } {
        set Pagamentos($indice) $valor
    }

    method setPeso { indice valor } {
        set Pesos($indice) $valor
    }

    method getQuantidade {} {
        return $Quantidade
    }

    # retorna o somatório total de Pesos[]
    method getPesoTotal {} {
        set acumulador 0.0
        for {set indice 0} {$indice < $Quantidade} {incr indice} {
            set acumulador [expr {$acumulador + $Pesos($indice)}]
        }
        return $acumulador
    }

    # calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    method jurosParaAcrescimo { juros } {
        set pesoTotal [my getPesoTotal]
        if { ($pesoTotal <= 0.0) || ($juros <= 0.0) || ($Quantidade < 1) || ($Periodo <= 0.0) } {
            return 0.0
        }
        set acumulador 0.0

        for {set indice 0} {$indice < $Quantidade} {incr indice} {
            if {$Composto} {
                set acumulador [expr {$acumulador + $Pesos($indice) / pow( 1.0 + $juros / 100.0, $Pagamentos($indice) / $Periodo)}]
            } else {
                set acumulador [expr {$acumulador + $Pesos($indice) / (1.0 + $juros / 100.0 * $Pagamentos($indice) / $Periodo)}]
            }
        }

        return [expr {($pesoTotal / $acumulador - 1.0) * 100.0}]
    }

    # calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    method acrescimoParaJuros { acrescimo precisao maxIteracoes maxJuros } {
        set pesoTotal [my getPesoTotal]
        if { ($pesoTotal <= 0.0) || ($acrescimo <= 0.0) || ($Quantidade < 1) || ($Periodo <= 0.0) || ($precisao < 1) || ($maxIteracoes < 1) || ($maxJuros <= 0.0) } {
            return 0.0
        }
        set minJuros 0.0
        set medJuros [expr {$maxJuros / 2.0}]
        set minDiferenca [expr {pow(0.1, $precisao)}]

        for {set indice 0} {$indice < $maxIteracoes} {incr indice} {
            if { ($maxJuros - $minJuros) < $minDiferenca} { return $medJuros }
            if { [my jurosParaAcrescimo $medJuros] < $acrescimo} {
                set minJuros $medJuros
            } else {
                set maxJuros $medJuros
            }
            set medJuros [expr {($minJuros + $maxJuros) / 2.0}]
        }

        return $medJuros
    }
}

# variáveis (a partir da versão 0.2) (Composto 1 = TRUE)
set Quantidade 3
set Composto 1
set Periodo 30.0

# cria um objeto juros da classe Juros e inicializa os valores
Juros create juros $Quantidade $Composto $Periodo

# define os valores dos arrays
for {set indice 0} {$indice < $Quantidade} {incr indice} {
    juros setPagamento $indice [expr {($indice + 1) * $Periodo}]
    juros setPeso $indice 1.0
}

# calcula os retornos das funções
set pesoTotal [juros getPesoTotal]
set acrescimoCalculado [juros jurosParaAcrescimo 3.0]
set jurosCalculado [juros acrescimoParaJuros $acrescimoCalculado 15 100 50.0]

# imprime os resultados
puts "Peso total = $pesoTotal"
puts "Acréscimo = $acrescimoCalculado"
puts "Juros = $jurosCalculado"

juros destroy
