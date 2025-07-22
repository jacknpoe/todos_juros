#!/bin/dash

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 05/07/2025: versão feita sem muito conhecimento de Dash
# ATENÇÃO: Não funciona no Linux do Windows, porque bc retorna um carriage return (^M) que o Dash não trata,
#          Testes (Ubuntu 23.10 e Debian 12.0.0 em VirtualBox) executaram em cerca de um segundo por parcela.

# variáveis globais para simplificar as chamadas
Quantidade=3
Periodo="30.0"
Composto=1  # 1 = TRUE

# Dash não tem arrays então Pagamentos e Pesos serão funções
Pagamentos() {
    echo "($1 + 1) * $Periodo" | bc -l
}
Pesos() {
    echo "1.0"
}

# calcula a somatória do array Pesos
getPesoTotal() {
    local acumulador="0.0"
    for indice in $(seq 0 $((Quantidade-1))); do
        acumulador=$(echo "$acumulador + $(Pesos $indice)" | bc -l)
    done
    echo "$acumulador"
    return 0
}

# calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo() {
    local juros=$1
    local pesoTotal=$(getPesoTotal)
    local errado=$(echo "$Quantidade < 1 || $Periodo <= 0.0 || $pesoTotal <= 0.0 || $juros <= 0.0" | bc -l)
    if [ "$errado" = "1" ] ; then
        echo "0.0"
        return 1
    fi

    local acumulador="0.0"
    for indice in $(seq 0 $((Quantidade-1))); do
        if [ "$Composto" -eq 1 ]; then
            acumulador=$(echo "$acumulador + $(Pesos $indice) / e($(Pagamentos $indice) / $Periodo * l(1.0 + $juros / 100.0))" | bc -l)
        else
            acumulador=$(echo "$acumulador + $(Pesos $indice) / (1.0 + $juros / 100.0 * $(Pagamentos $indice) / $Periodo)" | bc -l)
        fi
    done

    errado=$(echo "$acumulador <= 0.0" | bc -l)
    if [ "$errado" = "1" ] ; then
        echo "0.0"
        return 1
    fi

    echo "($pesoTotal / $acumulador - 1.0) * 100.0" | bc -l
    return 0
}

# calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros() {
    local acrescimo=$1
    local precisao=$2
    local maxIteracoes=$3
    local maxJuros=$4
    local pesoTotal=$(getPesoTotal)
    local errado=$(echo "$Quantidade < 1 || $Periodo <= 0.0 || $pesoTotal <= 0.0 || $acrescimo <= 0.0 || $precisao < 1 || $maxIteracoes < 1 || $maxJuros <= 0.0" | bc -l) 
    if [ "$errado" = "1" ] ; then
        echo "0.0"
        return 1
    fi

    local resultado
    local minJuros="0.0"
    local medJuros=$(echo "$maxJuros / 2.0" | bc -l)
    local minDiferenca=$(echo "e($precisao * l(0.1))" | bc -l)

    for indice in $(seq 1 $maxIteracoes); do
        voltar=$(echo "$maxJuros - $minJuros < $minDiferenca" | bc -l)
        if [ "$voltar" = "1" ]; then
            echo "$medJuros"
            return 0
        fi

        resultado=$(jurosParaAcrescimo "$medJuros")
        menor=$(echo "$resultado < $acrescimo" | bc -l) 
        if [ "$menor" = "1" ] ; then
            minJuros="$medJuros"
        else
            maxJuros="$medJuros"
        fi

        medJuros=$(echo "($minJuros + $maxJuros) / 2.0" | bc -l)
    done

    echo "$medJuros"
    return 0
}

# calcula e guarda os retornos das funções
pesoTotal=$(getPesoTotal)
acrescimoCalculado=$(jurosParaAcrescimo "3.0")
jurosCalculado=$(acrescimoParaJuros "$acrescimoCalculado" 20 75 "50.0")

# imprime os resultados
echo "Peso total = $pesoTotal"
echo "Acréscimo = $acrescimoCalculado"
echo "Juros = $jurosCalculado"
