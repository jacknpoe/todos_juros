-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 26/03/2024: versão feita sem muito conhecimento de Lua
--        0.2: 01/04/2024: corrigidos os acentos dos comentários
--        0.3: 15/05/2024: acrescentadas legendas para os valores

-- estrutura básica para simplificar as chamadas
Juros = {
	Quantidade = 0,
	Composto = false,
	Periodo = 0,
	Pagamentos = {},
	Pesos = {}
}

-- calcula a somatória de Pesos[]
function getPesoTotal()
	acumulador = 0
	for indice = 1, Juros.Quantidade do
		acumulador = acumulador + Juros.Pesos[indice]
	end
	return acumulador
end

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
function jurosParaAcrescimo(juros)
	if (juros <= 0 or Juros.Quantidade <= 0 or Juros.Periodo <= 0) then
		return 0
	end
	pesoTotal = getPesoTotal()
	if (pesoTotal <= 0.0) then
		return 0
	end
	acumulador = 0
	-- soZero = true
	
	for indice = 1, Juros.Quantidade do
		-- if (Juros.Pagamentos[indice] > 0 and Juros.Pesos[indice] > 0) then
		--  	soZero = false
		-- end
		if (Juros.Composto) then
			acumulador = acumulador + Juros.Pesos[indice] / (1 + juros / 100) ^ (Juros.Pagamentos[indice] / Juros.Periodo)
		else
			acumulador = acumulador + Juros.Pesos[indice] / (1 + juros / 100 * Juros.Pagamentos[indice] / Juros.Periodo)
		end
	end
	
	-- if (soZero) then
	if acumulador <= 0.0 then
		return 0
	end
	return (pesoTotal / acumulador - 1) * 100
end

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	if (maxIteracoes < 1 or Juros.Quantidade <= 0 or precisao < 1 or Juros.Periodo <= 0 or acrescimo <= 0 or maxJuros <= 0) then
		return 0
	end
	pesoTotal = getPesoTotal()
	if (pesoTotal <= 0.0) then
		return 0
	end
	minJuros = 0
	medJuros = maxJuros / 2
	minDiferenca = 0.1 ^ precisao
	
	for indice = 1, maxIteracoes do
		medJuros = (minJuros + maxJuros) / 2
		if ((maxJuros - minJuros) < minDiferenca) then
			return medJuros
		end
		if (jurosParaAcrescimo(medJuros)< acrescimo) then
			minJuros = medJuros
		else
			maxJuros = medJuros
		end
	end
	return medJuros
end

-- define os valores de Juros
Juros.Quantidade = 3
Juros.Composto = true
Juros.Periodo = 30
Juros.Pagamentos[1] = 30
Juros.Pagamentos[2] = 60
Juros.Pagamentos[3] = 90
Juros.Pesos[1] = 1
Juros.Pesos[2] = 1
Juros.Pesos[3] = 1

-- testa as funções
print("Peso total =", getPesoTotal())
print("Acréscimo =", jurosParaAcrescimo(3))
print("Juros =", acrescimoParaJuros(jurosParaAcrescimo(3), 15, 100, 50))
