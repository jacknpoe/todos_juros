-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 01/04/2025: versão feita sem muito conhecimento de Solar2D

-- estrutura básica de propriedades para simplificar as chamadas
local Juros = {
	Quantidade = 0,
	Composto = false,
	Periodo = 0.0,
	Pagamentos = {},
	Pesos = {}
}

-- calcula a somatória do array Pesos[]
function GetPesoTotal()
	local Acumulador = 0.0
	for Indice = 1, Juros.Quantidade do
		Acumulador = Acumulador + Juros.Pesos[Indice]
	end
	return Acumulador
end

-- calcula o acréscimo a partir dos juros e parcelas
function JurosParaAcrescimo(juros)
	local PesoTotal = GetPesoTotal()
	if (juros <= 0.0 or Juros.Quantidade < 1 or Juros.Periodo <= 0.0 or PesoTotal <= 0.0) then
		return 0.0
	end

	local Acumulador = 0.0

	for Indice = 1, Juros.Quantidade do
		if (Juros.Composto) then
			Acumulador = Acumulador + Juros.Pesos[Indice] / (1.0 + juros / 100.0) ^ (Juros.Pagamentos[Indice] / Juros.Periodo)
		else
			Acumulador = Acumulador + Juros.Pesos[Indice] / (1.0 + juros / 100.0 * Juros.Pagamentos[Indice] / Juros.Periodo)
		end
	end

	if Acumulador <= 0.0 then
		return 0.0
	end
	return (PesoTotal / Acumulador - 1.0) * 100.0
end

-- calcula os juros a partir do acréscimo e parcelas
function AcrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	local PesoTotal = GetPesoTotal()
	if (maxIteracoes < 1 or Juros.Quantidade < 1 or precisao < 1 or Juros.Periodo <= 0.0 or acrescimo <= 0.0 or maxJuros <= 0.0 or PesoTotal <= 0.0) then
		return 0.0
	end

	local MinJuros = 0.0
	local MedJuros = maxJuros / 2.0
	local MinDiferenca = 0.1 ^ precisao

	for Indice = 1, maxIteracoes do
		MedJuros = (MinJuros + maxJuros) / 2.0
		if ((maxJuros - MinJuros) < MinDiferenca) then
			return MedJuros
		end
		if (JurosParaAcrescimo(MedJuros) < acrescimo) then
			MinJuros = MedJuros
		else
			maxJuros = MedJuros
		end
	end
	return MedJuros
end

-- define os valores de Juros
Juros.Quantidade = 3
Juros.Composto = true
Juros.Periodo = 30.0
for indice = 1, Juros.Quantidade do
	Juros.Pagamentos[indice] = indice * Juros.Periodo
	Juros.Pesos[indice] = 1.0
end

-- calcula e guarda o resultado das funções
local PesoTotal = GetPesoTotal()
local AcrescimoCalculado = JurosParaAcrescimo(3.0)
local JurosCalculado = AcrescimoParaJuros(AcrescimoCalculado, 15, 100, 50.0)

-- monta as strings resultado
local sPesoTotal = "Peso total = " .. tostring(PesoTotal)
local sAcrescimoCalculado = "Acrescimo = " .. tostring(AcrescimoCalculado)
local sJurosCalculado = "Juros = " .. tostring(JurosCalculado)

-- cria os textos na tela
local Text1 = display.newText(sPesoTotal, display.contentCenterX, 10, native.systemFont, 20)
Text1:setFillColor(255, 255, 255)
local Text2 = display.newText(sAcrescimoCalculado, display.contentCenterX, 40, native.systemFont, 20)
Text2:setFillColor(255, 255, 255)
local Text3 = display.newText(sJurosCalculado, display.contentCenterX, 70, native.systemFont, 20)
Text3:setFillColor(255, 255, 255)