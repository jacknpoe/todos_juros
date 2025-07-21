#!/bin/csh

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 21/07/2025: versão feita sem muito conhecimento de csh
#             No Debian bare metal levou 0,8752 segundos com 120 parcelas

# variáveis (os arrays são outros scripts)
set Quantidade = 3
set Composto = true
set Periodo = 30.0
set Juros = 3.0

# calcula e guarda os resultados dos .csh
set pesoTotal = `./getPesoTotal.csh $Quantidade`
set acrescimoCalculado = `./jurosParaAcrescimo.csh $Quantidade $Composto $Periodo $Juros`
set jurosCalculado = `./acrescimoParaJuros.csh $Quantidade $Composto $Periodo $acrescimoCalculado 20 75 50.0`

# imprime os resultados
echo "Peso total = $pesoTotal"
echo "Acréscimo = $acrescimoCalculado"
echo "Juros = $jurosCalculado"
