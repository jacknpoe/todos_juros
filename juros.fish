#!/usr/bin/fish

# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 20/07/2025: versão feita sem muito conhecimento de fish-shell
#                         em testes no Debian bare metal, cada parcela levou 0.0032 segundos em 300 parcelas

# variáveis globais para simplificar as chamadas às funções
set -g Quantidade 3
set -g Composto true
set -g Periodo 30.0
set -g Pagamentos
set -g Pesos

# arrays inicializados dinamicamente
for indice in (seq $Quantidade);
    set -a Pagamentos ( math --scale=max "$indice * $Periodo" )
    set -a Pesos 1.0
end

# calcula a somatória de Pesos[]
function getPesoTotal
   set --local acumulador 0.0
   for indice in (seq $Quantidade);
       set acumulador ( math --scale=max $acumulador + $Pesos[$indice] )
   end
   echo $acumulador
   return 0
end

# calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo -a juros
   set --local pesoTotal (getPesoTotal)
   if [ $Quantidade -lt 1 ] || [ $Periodo -le 0.0 ] || [ $pesoTotal -le 0.0 ] || [ $juros -le 0.0 ]
      echo 0.0
      return 1
   end

   set --local acumulador 0.0
   for indice in (seq $Quantidade);
      if $Composto
         set acumulador ( math --scale=max "$acumulador + $Pesos[$indice] / (1.0 + $juros / 100.0) ^ ($Pagamentos[$indice] / $Periodo)" )
      else
         set acumulador ( math --scale=max "$acumulador + $Pesos[$indice] / ( 1.0 + $juros / 100.0 * $Pagamentos[$indice] / $Periodo )" )
      end
   end

   if [ $acumulador -le 0.0 ]
      echo 0.0
      return 1
   end

   echo ( math --scale=max "($pesoTotal / $acumulador - 1.0) * 100.0" )
   return 0
end

# calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros -a acrescimo precisao maxIteracoes maxJuros
   set --local pesoTotal (getPesoTotal)
   if [ $Quantidade -lt 1 ] || [ $Periodo -le 0.0 ] || [ $pesoTotal -le 0.0 ] || [ $acrescimo -le 0.0 ] || [ $precisao -lt 1 ] || [ $maxIteracoes -lt 1 ] || [ $maxJuros -le 0.0 ]
      echo 0.0
      return 1
   end

   set --local minJuros 0.0
   set --local medJuros ( math --scale=max $maxJuros / 2.0 )
   set --local minDiferenca ( math --scale=max 0.1 ^ $precisao )
   for indice in (seq $maxIteracoes);
      if [ ( math --scale=max $maxJuros - $minJuros ) -lt $minDiferenca ]
         echo $medJuros
         return 0
      end
      if [ ( jurosParaAcrescimo $medJuros ) -lt $acrescimo ]
         set minJuros $medJuros
      else
         set maxJuros $medJuros
      end
      set medJuros ( math --scale=max "($minJuros + $maxJuros) / 2.0" )
   end

   echo $medJuros
   return 0
end

# calcula e guarda os resultados das funções
set pesoTotal (getPesoTotal)
set acrescimoCalculado (jurosParaAcrescimo 3.0)
set jurosCalculado (acrescimoParaJuros $acrescimoCalculado 15 56 50.0)
''
# imprime os resultados
echo "Peso total = $pesoTotal"
echo "Acréscimo = $acrescimoCalculado"
echo "Juros = " $jurosCalculado