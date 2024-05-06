note
	description: "Classe de cálculo do juros, sendo que precisa de arrays pra isso"
	author: "Ricardo Erick Rebêlo"
	date: "$Date$"
	revision: "$Revision$"
	-- Versao: 0.1: 06/05/2024: versão feita sem muito conhecimento de Eiffel

class JUROS

inherit	ANY

create make

feature -- construtor
	make (pquantidade: INTEGER; pcomposto: BOOLEAN; pperiodo: REAL_64; ppagamentos, ppesos: ARRAY[REAL_64])
	do
		Quantidade := pquantidade
		Composto := pcomposto
		Periodo := pperiodo
		Pagamentos := ppagamentos
		Pesos := ppesos
	end

feature -- métodos
	-- calcula a somatória de Pesos[]
	getPesoTotal: REAL_64
	local
		indice: INTEGER
		acumulador: REAL_64
	do
		acumulador := 0.0
		from indice := 1 until indice > Quantidade loop
			acumulador := acumulador + Pesos[indice]
			indice := indice + 1
		end
		Result := acumulador
	end

	-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	jurosParaAcrescimo(juros: REAL_64): REAL_64
	require
		juros_maior_que_zero: juros > 0.0
		quantidade_maior_que_zero: Quantidade > 0
		periodo_maior_que_zero: Periodo > 0.0
	local
		pesoTotal, acumulador: REAL_64
		indice: INTEGER
	do
		pesoTotal := getPesoTotal
		if pesoTotal <= 0 then
			Result := 0.0
		else
			acumulador := 0.0
			from indice := 1 until indice > Quantidade loop
				if Composto then
					acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
				else
					acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
				end
				indice := indice + 1
			end
			Result := ((pesoTotal / acumulador) - 1.0) * 100.0
		end
	end

	-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	acrescimoParaJuros(acrescimo: REAL_64; precisao, maxIteracoes: INTEGER; maximoJuros: REAL_64): REAL_64
	require
		maxiteracoes_maior_que_zero: maxIteracoes > 1
		quantidade_maior_que_zero: Quantidade > 0
		precisao_maior_que_zero: precisao > 0
		periodo_maior_que_zero: Periodo > 0.0
		acrescimo_maior_que_zero: acrescimo > 0.0
		maximojuros_maior_que_zero: maximoJuros > 0.0
	local
		pesoTotal, minJuros, medJuros, maxJuros, minDiferenca: REAL_64
		indice: INTEGER
	do
		pesoTotal := getPesoTotal
		if pesoTotal <= 0 then
			Result := 0.0
		else
			minJuros := 0.0
			maxJuros := maximoJuros
			minDiferenca := 0.1 ^ precisao

			from indice := 1 until indice > maxIteracoes loop
				medJuros := (minJuros + maxJuros) / 2.0
				if (maxJuros - minJuros) < minDiferenca then
					indice := maxIteracoes
				else
					if jurosParaAcrescimo(medJuros)< acrescimo then
						minJuros := medJuros
					else
						maxJuros := medJuros
					end
				end
				indice := indice + 1
			end
			Result := medJuros
		end
	end

feature -- attributes
	Quantidade: INTEGER
	Composto: BOOLEAN
	Periodo: REAL_64
	Pagamentos: ARRAY [REAL_64]
	Pesos: ARRAY [REAL_64]
invariant
	valid_quantidade: 0 < Quantidade
	valid_periodo: 0.0 < Periodo
end

