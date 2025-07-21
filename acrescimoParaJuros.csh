#!/bin/csh

# calcula os juros a partir do acréscimo e parcelas

set Quantidade = "$argv[1]"
set Composto = "$argv[2]"
set Periodo = "$argv[3]"
set acrescimo = "$argv[4]"
set precisao = "$argv[5]"
set maxIteracoes = "$argv[6]"
set maxJuros = "$argv[7]"
set pesoTotal = `./getPesoTotal.csh $Quantidade`

if ( `echo "$Quantidade < 1 || $Periodo <= 0.0 || $pesoTotal <= 0.0 || $acrescimo <= 0.0 || $precisao < 1 || $maxIteracoes < 1 || $maxJuros <= 0.0" | bc -l` ) then
    echo 0.0
    exit 1
endif

set minJuros = 0.0
set medJuros = `echo "$maxJuros / 2.0" | bc -l`
set minDiferenca = `echo "e(l(0.1) * $precisao)" | bc -l`

foreach indice ( `seq 1 $maxIteracoes` )
    if ( `echo "$maxJuros - $minJuros < $minDiferenca" | bc -l` ) then
        echo $medJuros
        exit 0
    endif
    set calculado = `./jurosParaAcrescimo.csh $Quantidade $Composto $Periodo $medJuros`
    if ( `echo "$calculado < $acrescimo" | bc -l` ) then
        set minJuros = $medJuros
    else
        set maxJuros = $medJuros
    endif
    set medJuros = `echo "($minJuros + $maxJuros) / 2.0" | bc -l`
end

echo $medJuros
exit 0
