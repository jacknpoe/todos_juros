-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 12/07/2024: versão feita sem muito conhecimento de MoonScript

-- estrutura básica global para simplificar as chamadas (não funcionava estrutura)
export Quantidade = 0
export Composto = false
export Periodo = 0.0
export Pagamentos = {}
export Pesos = {}

-- calcula a somatória do array Pesos[]
getPesoTotal = ->
	acumulador = 0.0
	for indice = 1, Quantidade
		acumulador += Pesos[indice]
	return acumulador

-- calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo = (juros) ->
	pesoTotal = getPesoTotal!
	if juros <= 0.0 or Quantidade <= 0 or Periodo <= 0.0 or pesoTotal <= 0.0
		return 0.0

    acumulador = 0.0
	
	for indice = 1, Quantidade
		if Composto
			acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
		else
			acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
	
	if acumulador <= 0.0
	    return 0.0
	return (pesoTotal / acumulador - 1.0) * 100.0

-- calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros = (acrescimo, precisao=15, maxIteracoes=100, maxJuros=50.0) ->
	pesoTotal = getPesoTotal!
	if maxIteracoes < 1 or Quantidade <= 0 or precisao < 1 or Periodo <= 0.0 or acrescimo <= 0.0 or maxJuros <= 0.0 or pesoTotal <= 0.0
		return 0.0
	minJuros = 0.0
	medJuros = maxJuros / 2.0
	minDiferenca = 0.1 ^ precisao
	
	for indice = 1, maxIteracoes
		medJuros = (minJuros + maxJuros) / 2.0
		if (maxJuros - minJuros) < minDiferenca
			return medJuros
		if (jurosParaAcrescimo medJuros) < acrescimo
			minJuros = medJuros
		else
			maxJuros = medJuros
	return medJuros

-- define os valores
Quantidade = 3
Composto = true
Periodo = 30.0
for indice = 1, Quantidade
	Pagamentos[indice] = indice * 30.0
	Pesos[indice] = 1.0

-- calcula e guarda os resultados das funções
pesoTotal = getPesoTotal!
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado = acrescimoParaJuros acrescimoCalculado -- , 15, 100, 50.0

-- imprime os resultados
print "Peso total = " .. tostring(pesoTotal)
print "Acrescimo = " .. tostring(acrescimoCalculado)
print "Juros = " .. tostring(jurosCalculado)