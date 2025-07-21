#!/bin/csh

# calcula o acréscimo a partir dos juros e parcelas

set Quantidade = "$argv[1]"
set Composto = "$argv[2]"
set Periodo = "$argv[3]"
set juros = "$argv[4]"
set pesoTotal = `./getPesoTotal.csh $Quantidade`

if ( `echo "$Quantidade < 1 || $Periodo <= 0.0 || $pesoTotal <= 0.0 || $juros <= 0.0" | bc -l` ) then
    echo 0.0
    exit 1
endif

set acumulador = 0.0

foreach indice ( `seq 1 $Quantidade` )
    set peso = `./Pesos.csh $indice`
    set pagamento = `./Pagamentos.csh $indice $Periodo`
    if ( $Composto == true ) then
        set acumulador = `echo "$acumulador + $peso / e(l(1.0 + $juros / 100.0) * $pagamento / $Periodo)" | bc -l`
    else
        set acumulador = `echo "$acumulador + $peso / (1.0 + $juros / 100.0 * $pagamento / $Periodo)" | bc -l`
    endif
end

if ( `echo "$acumulador <= 0.0" | bc -l` ) then
    echo 0.0
    exit 1
endif

echo `echo "($pesoTotal / $acumulador - 1.0) * 100.0" | bc -l`
exit 0
