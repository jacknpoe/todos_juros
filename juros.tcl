# Cálculo dos juros, sendo que precisa de arrays para isso
# Versão 0.1: 05/06/2024: versão feita sem muito conhecimento de Tcl

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
    constructor { quantidade composto periodo pagamentos pesos } {
        set Quantidade $quantidade
        set Composto $composto
        set Periodo $periodo
        set Pagamentos $pagamentos
        set Pesos $pesos
    }

    method getQuantidade {} {
        return $Quantidade
    }

    # retorna o somatório total de Pesos[]
    method getPesoTotal {} {
        set acumulador 0.0
        for {set indice 0} {$indice < $Quantidade} {set indice [expr $indice + 1]} {
            set acumulador [expr {$acumulador + [lindex $Pesos $indice]}]
        }
        return $acumulador
    }

    # calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    method jurosParaAcrescimo { juros } {
        set pesoTotal [juros getPesoTotal]
        if { ($pesoTotal <= 0.0) || ($juros <= 0.0) || ($Quantidade < 1) || ($Periodo <= 0.0) } {
            return 0.0
        }
        set acumulador 0.0

        for {set indice 0} {$indice < $Quantidade} {set indice [expr $indice + 1]} {
            if { $Composto == 1 } {
                set acumulador [expr {$acumulador + [lindex $Pesos $indice] / [pow [expr 1.0 + $juros / 100.0] [expr [lindex $Pagamentos $indice] / $Periodo] ]}]
            } else {
                set acumulador [expr {$acumulador + [lindex $Pesos $indice] / (1.0 + $juros / 100.0 * [lindex $Pagamentos $indice] / $Periodo)}]
            }
        }

        return [expr ($pesoTotal / $acumulador - 1.0) * 100.0 ]
    }

    # calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    method acrescimoParaJuros { acrescimo precisao maxIteracoes maxJuros } {
        set pesoTotal [juros getPesoTotal]
        if { ($pesoTotal <= 0.0) || ($acrescimo <= 0.0) || ($Quantidade < 1) || ($Periodo <= 0.0) || ($precisao < 1) || ($maxIteracoes < 1) || ($maxJuros <= 0.0) } {
            return 0.0
        }
        set minJuros 0.0
        set medJuros [expr $maxJuros / 2.0]
        set minDiferenca [pow 0.1 $precisao]

        for {set indice 0} {$indice < $maxIteracoes} {set indice [expr $indice + 1]} {
            set medJuros [expr ($minJuros + $maxJuros) / 2.0]
            if { ($maxJuros - $minJuros) < $minDiferenca} { return $medJuros }
            if { [juros jurosParaAcrescimo $medJuros] < $acrescimo} {
                set minJuros $medJuros
            } else {
                set maxJuros $medJuros
            }
        }

        return $medJuros
    }
}

# cria um objeto juros da classe Juros e inicializa os valores
Juros create juros 3 1 30.0 { 30.0 60.0 90.0 } { 1.0 1.0 1.0 }

# calcula os retornos das funções
set pesoTotal [juros getPesoTotal]
set acrescimoCalculado [juros jurosParaAcrescimo 3.0]
set jurosCalculado [juros acrescimoParaJuros $acrescimoCalculado 15 100 50.0]

# imprime os resultados
puts "Peso total = $pesoTotal"
puts "Acréscimo = $acrescimoCalculado"
puts "Juros = $jurosCalculado"

juros destroy
