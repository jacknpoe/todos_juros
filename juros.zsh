#!/usr/bin/env zsh

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 11/07/2025: versão feita sem muito conhecimento de zsh

# variáveis globais para simplificar as chamadas às funções
(( Quantidade=3 ))
(( Composto=1 ))    # 1 = true
(( Periodo=30 ))

for (( indice=1; indice<=$(( Quantidade )); indice++)); do
    (( Pagamentos[indice]=indice*Periodo ))
    (( Pesos[indice]=1.0 ))
done

# variáveis de retorno
(( pesoTotal=0.0 ))
(( acrescimoCalculado=0.0 ))
(( jurosCalculado=0.0 ))

# calcula a somatória de Pesos[]
getPesoTotal() {
    (( acumulador=0.0 ))
    for (( indice=1; indice<=$(( Quantidade )); indice++)); do
        (( acumulador=acumulador+Pesos[indice] ))
    done
    (( pesoTotal=acumulador ))
}

# calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo() {
    (( juros = $1 ))
    getPesoTotal
    if (( Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 )); then
        (( acrescimoCalculado=0.0 ))
        return
    fi

    (( acumulador=0.0 ))
    for (( indice=1; indice<=$(( Quantidade )); indice++)); do
        if (( Composto == 1 )); then
            (( acumulador=acumulador+Pesos[indice]/(1.0+juros/100.0)**(Pagamentos[indice]/Periodo)  ))
        else
            (( acumulador=acumulador+Pesos[indice]/(1.0+juros/100.0*Pagamentos[indice]/Periodo)  ))
        fi
    done

    if (( acumulador <= 0.0 )); then
        (( acrescimoCalculado=0.0 ))
        return
    fi
    (( acrescimoCalculado=(pesoTotal/acumulador-1.0)*100.0 ))
}


# calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros() {
    (( acrescimo = $1 ))
    (( precisao = $2 ))
    (( maxIteracoes = $3 ))
    (( maxJuros = $4 ))
    getPesoTotal
    if (( Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 )); then
        (( jurosCalculado=0.0 ))
        return
    fi

    (( minJuros=0.0 ))
    (( medJuros=maxJuros/2.0 ))
    (( minDiferenca=0.1**precisao ))
    for (( iteracao=0; iteracao<$(( maxIteracoes )); iteracao++)); do
        if (( maxJuros - minJuros < minDiferenca )); then
            (( jurosCalculado=medJuros ))
            return
        fi
        jurosParaAcrescimo $medJuros
        if (( acrescimoCalculado < acrescimo )); then
            (( minJuros=medJuros))
        else
            (( maxJuros=medJuros))
        fi
        (( medJuros=(minJuros+maxJuros)/2.0 ))
    done
    (( jurosCalculado=medJuros ))
}

# calcula e imprime os resultados das funções
getPesoTotal
printf "Peso total = %2.15f\\n" $(( pesoTotal ))
jurosParaAcrescimo 3.0
printf "Acréscimo = %2.15f\\n" $(( acrescimoCalculado ))
acrescimoParaJuros $acrescimoCalculado 15 100 50.0
printf "Juros = %2.15f\\n" $(( jurosCalculado ))