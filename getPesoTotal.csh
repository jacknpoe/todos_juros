#!/bin/csh

# calcula a somatória de Pesos[] (o único parâmetro é quantidade porque para pesos só vale o índice e, mesmo assim, nessa versão nem isso)

set Quantidade = "$argv[1]"
set acumulador = 0.0

foreach indice ( `seq 1 $Quantidade` )
    set peso = `./Pesos.csh $indice`
    set acumulador = `echo "$acumulador + $peso" | bc`
end

echo $acumulador
exit 0
