' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1:  09/07/2025: versão feita sem muito conhecimento de SmallBASIC

' variáveis globais para simplificar as chamadas
Quantidade = 3
Composto = true
Periodo = 30.0
dim Pagamentos(Quantidade-1)
dim Pesos(Quantidade-1)

for indice = 0 to Quantidade-1
  Pagamentos(indice) = (indice + 1.0) * Periodo
  Pesos(indice) = 1.0
next

' calcula a somatória de Pesos()
func getPesoTotal()
  local acumulador, indice
  acumulador = 0.0
  for indice = 0 to Quantidade-1
    acumulador += Pesos(imdice)
  next
  return acumulador
end

' calcula o acréscimo a partir dos juros e parcelas
func jurosParaAcrescimo(juros)
  local pesoTotal, acumulador, indice
  pesoTotal = getPesoTotal()
  if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then
    return 0.0
  endif
  
  acumulador = 0.0
  for indice = 0 to Quantidade-1
    if Composto then
      acumulador += Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
    else
      acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
    endif
  next
  
  if acumulador <= 0.0 then
    return 0.0
  endif
  return (pesoTotal / acumulador - 1.0) * 100.0
end

' calcula os juros a partir do acréscimo e parcelas
func acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
  local pesoTotal, minJuros, medJuros, minDiferenca, indice
  pesoTotal = getPesoTotal()
  if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then
    return 0.0
  endif

  minJuros = 0.0
  medJuros = maxJuros / 2.0
  minDiferenca = 0.1 ^ precisao
  for indice = 1 to maxIteracoes
    if maxJuros - minJuros < minDiferenca then
      return medJuros
    endif
    if jurosParaAcrescimo(medJuros) < acrescimo then
      minJuros = medJuros
    else
      maxJuros = medJuros
    endif
    medJuros = (minJuros + maxJuros) / 2.0
  next
  return medJuros
end

' calcula e guarda o retorno das funçṍes
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
print "Peso total = "; pesoTotal
print "Acrescimo = "; acrescimoCalculado
print "Juros = "; jurosCalculado