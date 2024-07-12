-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 26/03/2024: versão feita sem muito conhecimento de Lua
--        0.2: 01/04/2024: corrigidos os acentos dos comentários
--        0.3: 15/05/2024: acrescentadas legendas para os valores
--        0.4: 08/06/2024: for para preencher os arrays, em vez de valores fixos
--        0.5: 18/06/2024: revisados os comentários
--        0.6: 12/07/2024: corrigido o 0 para 0.0 na linha 51
--        0.7: 12/07/2024: retirado soZero, reposicionado pesoTotal, incluídas variáveis de retorno e melhorada saída (espaços)

-- estrutura básica de propriedades para simplificar as chamadas
Juros = {
	Quantidade = 0,
	Composto = false,
	Periodo = 0.0,
	Pagamentos = {},
	Pesos = {}
}

-- calcula a somatória do array Pesos[]
function getPesoTotal()
	acumulador = 0.0
	for indice = 1, Juros.Quantidade do
		acumulador = acumulador + Juros.Pesos[indice]
	end
	return acumulador
end

-- calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros)
	pesoTotal = getPesoTotal()
	if (juros <= 0.0 or Juros.Quantidade <= 0 or Juros.Periodo <= 0.0 or pesoTotal <= 0.0) then
		return 0.0
	end

	acumulador = 0.0
	
	for indice = 1, Juros.Quantidade do
		if (Juros.Composto) then
			acumulador = acumulador + Juros.Pesos[indice] / (1.0 + juros / 100.0) ^ (Juros.Pagamentos[indice] / Juros.Periodo)
		else
			acumulador = acumulador + Juros.Pesos[indice] / (1.0 + juros / 100.0 * Juros.Pagamentos[indice] / Juros.Periodo)
		end
	end
	
	if acumulador <= 0.0 then
		return 0.0
	end
	return (pesoTotal / acumulador - 1.0) * 100.0
end

-- calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	pesoTotal = getPesoTotal()
	if (maxIteracoes < 1 or Juros.Quantidade <= 0 or precisao < 1 or Juros.Periodo <= 0.0 or acrescimo <= 0.0 or maxJuros <= 0.0 or pesoTotal <= 0.0) then
		return 0.0
	end

	minJuros = 0.0
	medJuros = maxJuros / 2.0
	minDiferenca = 0.1 ^ precisao
	
	for indice = 1, maxIteracoes do
		medJuros = (minJuros + maxJuros) / 2.0
		if ((maxJuros - minJuros) < minDiferenca) then
			return medJuros
		end
		if (jurosParaAcrescimo(medJuros) < acrescimo) then
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
Juros.Periodo = 30.0
for indice = 1, Juros.Quantidade do
	Juros.Pagamentos[indice] = indice * 30.0
	Juros.Pesos[indice] = 1.0
end

-- calcula e guarda o resultado das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

-- testa as funções
print("Peso total = " .. tostring(pesoTotal))
print("Acréscimo = " .. tostring(acrescimoCalculado))
print("Juros = " .. tostring(jurosCalculado))
