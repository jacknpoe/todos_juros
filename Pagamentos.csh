#!/bin/csh

# retorna Pagamento[$argv[1]] para Periodo $argv[2]

set indice = "$argv[1]"
set Periodo = "$argv[2]"

echo `echo "$indice * $Periodo" | bc`
exit 0
