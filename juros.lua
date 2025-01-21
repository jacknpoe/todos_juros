-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1:  26/03/2024: versão feita sem muito conhecimento de Lua
--        0.2:  01/04/2024: corrigidos os acentos dos comentários
--        0.3:  15/05/2024: acrescentadas legendas para os valores
--        0.4:  08/06/2024: for para preencher os arrays, em vez de valores fixos
--        0.5:  18/06/2024: revisados os comentários
--        0.6:  12/07/2024: corrigido o 0 para 0.0 na linha 51
--        0.7:  12/07/2024: retirado soZero, reposicionado PesoTotal, incluídas variáveis de retorno e melhorada saída (espaços)
--        0.9:  08/01/2025: agora a verificação é Quantidade < 1
--        0.10: 21/01/2025: os nomes globais e locais agora em caixa alta e tipo na impressão de "Acréscimo"

-- estrutura básica de propriedades para simplificar as chamadas
Juros = {
	Quantidade = 0,
	Composto = false,
	Periodo = 0.0,
	Pagamentos = {},
	Pesos = {}
}

-- calcula a somatória do array Pesos[]
function GetPesoTotal()
	Acumulador = 0.0
	for indice = 1, Juros.Quantidade do
		Acumulador = Acumulador + Juros.Pesos[indice]
	end
	return Acumulador
end

-- calcula o acréscimo a partir dos juros e parcelas
function JurosParaAcrescimo(juros)
	PesoTotal = GetPesoTotal()
	if (juros <= 0.0 or Juros.Quantidade < 1 or Juros.Periodo <= 0.0 or PesoTotal <= 0.0) then
		return 0.0
	end

	Acumulador = 0.0
	
	for indice = 1, Juros.Quantidade do
		if (Juros.Composto) then
			Acumulador = Acumulador + Juros.Pesos[indice] / (1.0 + juros / 100.0) ^ (Juros.Pagamentos[indice] / Juros.Periodo)
		else
			Acumulador = Acumulador + Juros.Pesos[indice] / (1.0 + juros / 100.0 * Juros.Pagamentos[indice] / Juros.Periodo)
		end
	end
	
	if Acumulador <= 0.0 then
		return 0.0
	end
	return (PesoTotal / Acumulador - 1.0) * 100.0
end

-- calcula os juros a partir do acréscimo e parcelas
function AcrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	PesoTotal = GetPesoTotal()
	if (maxIteracoes < 1 or Juros.Quantidade < 1 or precisao < 1 or Juros.Periodo <= 0.0 or acrescimo <= 0.0 or maxJuros <= 0.0 or PesoTotal <= 0.0) then
		return 0.0
	end

	MinJuros = 0.0
	MedJuros = maxJuros / 2.0
	MinDiferenca = 0.1 ^ precisao
	
	for indice = 1, maxIteracoes do
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
	Juros.Pagamentos[indice] = indice * 30.0
	Juros.Pesos[indice] = 1.0
end

-- calcula e guarda o resultado das funções
PesoTotal = GetPesoTotal()
AcrescimoCalculado = JurosParaAcrescimo(3.0)
JurosCalculado = AcrescimoParaJuros(AcrescimoCalculado, 15, 100, 50.0)

-- testa as funções
print("Peso total = " .. tostring(PesoTotal))
print("Acrescimo = " .. tostring(AcrescimoCalculado))
print("Juros = " .. tostring(JurosCalculado))
