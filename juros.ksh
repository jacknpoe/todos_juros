#!/bin/ksh

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 16/07/2025: versão feita sem muito conhecimento de POSIX ksh
#          Testes (Debian 12) executaram em cerca de 0.00036 segundo por parcela.

LC_NUMERIC=C

# variáveis globais para simplificar as chamadas
Quantidade=3
Periodo=30.0
Composto=1  # 1 = TRUE

# inicializa os arrays Pagamentos e Pesos
for ((indice=0; indice<$Quantidade; indice++)) do
    let Pagamentos[indice]="($indice+1)*$Periodo"
    let Pesos[indice]=1.0
done

# calcula a somatória do array Pesos
getPesoTotal() {
    acumulador=0.0
    for ((indice=0; indice<$Quantidade; indice++)) do
        let acumulador+=${Pesos[$indice]}
    done
    echo "$acumulador"
    return 0
}

# calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo() {
    juros=$1
    pesoTotal=$(getPesoTotal)
    if [ $Quantidade -lt 1 ] || [ $Periodo -le 0.0 ] || [ $pesoTotal -le 0.0 ] || [ $juros -le 0.0 ] ; then
        echo "0.0"
        return 1
    fi

    acumulador=0.0
    for ((indice=0; indice<$Quantidade; indice++)) do
        if [ $Composto -eq 1 ] ; then
            let acumulador="$acumulador + ${Pesos[$indice]} / (1.0 + $juros / 100.0) ** (${Pagamentos[$indice]} / $Periodo)"
        else
            let acumulador="$acumulador + ${Pesos[$indice]} / (1.0 + $juros / 100.0 * ${Pagamentos[$indice]} / $Periodo)"
        fi
    done

    if [ $acumulador -le 0.0 ] ; then
        echo "0.0"
        return 1
    fi

    let temp="($pesoTotal / $acumulador - 1.0) * 100.0"
    echo "$temp"
    return 0
}

# calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros() {
    acrescimo=$1
    precisao=$2
    maxIteracoes=$3
    maxJuros=$4
    pesoTotal=$(getPesoTotal)
    if [ $Quantidade -lt 1 ] || [ $Periodo -le 0.0 ] || [ $pesoTotal -le 0.0 ] || [ $acrescimo -le 0.0 ] || [ $precisao -lt 1 ] || [ $maxIteracoes -lt 1 ] || [ $maxJuros -le 0.0 ] ; then
        echo "0.0"
        return 1
    fi

    minJuros=0.0
    let medJuros="$maxJuros / 2.0"
    let minDiferenca="0.1 ** $precisao"

    for ((indice=0; indice<$maxIteracoes; indice++)) do
        let diferenca="$maxJuros - $minJuros"
        if [ $diferenca -lt $minDiferenca ] ; then
            echo "$medJuros"
            return 0
        fi

        resultado=$(jurosParaAcrescimo "$medJuros")
        if [ $resultado -lt $acrescimo ] ; then
            minJuros="$medJuros"
        else
            maxJuros="$medJuros"
        fi

        let medJuros="($minJuros + $maxJuros) / 2.0"
    done

    echo "$medJuros"
    return 0
}

# calcula e guarda os retornos das funções
pesoTotal=$(getPesoTotal)
acrescimoCalculado=$(jurosParaAcrescimo "3.0")
jurosCalculado=$(acrescimoParaJuros "$acrescimoCalculado" 15 56 "10.0")

# imprime os resultados
echo "Peso total = $pesoTotal"
echo "Acréscimo = $acrescimoCalculado"
echo "Juros = $jurosCalculado"
