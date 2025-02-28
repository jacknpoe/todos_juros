note
	description: "Classe de c�lculo do juros, sendo que precisa de arrays pra isso"
	author: "Ricardo Erick Reb�lo"
	date: "$Date$"
	revision: "$Revision$"
	-- Versao: 0.1: 06/05/2024: vers�o feita sem muito conhecimento de Eiffel
	--         0.2: 07/05/2024: vers�o com nomes em min�sculas e {ANY} onde precisa
	-- ATEN��O, falta ^ com expoente REAL_64 no compilador Liberty Eiffel, ent�o pode ser necess�rio o EiffelStudio

class JUROS

inherit	ANY

create {ANY} make

feature {ANY} -- construtor
	make (pquantidade: INTEGER; pcomposto: BOOLEAN; pperiodo: REAL_64; ppagamentos, ppesos: ARRAY[REAL_64])
	do
		quantidade := pquantidade
		composto := pcomposto
		periodo := pperiodo
		pagamentos := ppagamentos
		pesos := ppesos
	end

feature {ANY} -- m�todos
	-- calcula a somat�ria de Pesos[]
	getpesototal: REAL_64
	local
		indice: INTEGER
		acumulador: REAL_64
	do
		acumulador := 0.0
		from indice := 1 until indice > quantidade loop
			acumulador := acumulador + pesos.item(indice)
			indice := indice + 1
		end
		Result := acumulador
	end

	-- calcula o acr�scimo a partir dos juros e dados comuns (como parcelas)
	jurosparaacrescimo(juros: REAL_64): REAL_64
	require
		juros_maior_que_zero: juros > 0.0
		quantidade_maior_que_zero: quantidade > 0
		periodo_maior_que_zero: periodo > 0.0
		peso_total_maior_que_zero: getpesototal > 0.0
	local
		pesototal, acumulador: REAL_64
		indice: INTEGER
	do
		pesototal := getpesototal
		acumulador := 0.0
		from indice := 1 until indice > quantidade loop
			if composto then
				acumulador := acumulador + pesos.item(indice) / (1.0 + juros / 100.0) ^ (pagamentos.item(indice) / periodo)
			else
				acumulador := acumulador + pesos.item(indice) / (1.0 + juros / 100.0 * pagamentos.item(indice) / periodo)
			end
			indice := indice + 1
		end
		Result := ((pesototal / acumulador) - 1.0) * 100.0
	end

	-- calcula os juros a partir do acr�scimo e dados comuns (como parcelas)
	acrescimoparajuros(acrescimo: REAL_64; precisao, maxiteracoes: INTEGER; maximojuros: REAL_64): REAL_64
	require
		maxiteracoes_maior_que_zero: maxiteracoes > 1
		quantidade_maior_que_zero: quantidade > 0
		precisao_maior_que_zero: precisao > 0
		periodo_maior_que_zero: periodo > 0.0
		acrescimo_maior_que_zero: acrescimo > 0.0
		maximojuros_maior_que_zero: maximojuros > 0.0
		peso_total_maior_que_zero: getpesototal > 0.0
	local
		minjuros, medjuros, maxjuros, mindiferenca: REAL_64
		indice: INTEGER
	do
		minjuros := 0.0
		maxjuros := maximojuros
		mindiferenca := 0.1 ^ precisao

		from indice := 1 until indice > maxiteracoes loop
			medjuros := (minjuros + maxjuros) / 2.0
			if (maxjuros - minjuros) < mindiferenca then
				indice := maxiteracoes
			else
				if jurosparaacrescimo(medjuros)< acrescimo then
					minjuros := medjuros
				else
					maxjuros := medjuros
				end
			end
			indice := indice + 1
		end
		Result := medjuros
	end

feature {ANY} -- attributes
	quantidade: INTEGER
	composto: BOOLEAN
	periodo: REAL_64
	pagamentos: ARRAY [REAL_64]
	pesos: ARRAY [REAL_64]
invariant
	valid_quantidade: 0 < quantidade
	valid_periodo: 0.0 < periodo
end

