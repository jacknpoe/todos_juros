// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 14/06/2024: versão feita sem muito conhecimento de X#

// USING System
// USING System.Collections.Generic

// atributos para simplificar as chamadas
CLASS Juros
	PUBLIC Quantidade AS INT
	PUBLIC Composto AS LOGIC
	PUBLIC Periodo AS FLOAT
	PUBLIC Pagamentos AS ARRAY
	PUBLIC Pesos AS ARRAY

	// construtor que inicializa Quantidade, Composto e Periodo
	PUBLIC METHOD Init(qtd AS INT, cmp AS LOGIC, prd AS FLOAT, pag AS ARRAY, pes AS ARRAY) CLASS Juros
		Quantidade := qtd
		Composto := cmp
		Periodo := prd
		Pagamentos := pag
		Pesos := pes
		RETURN SELF

	// calcula a somatória de Pesos[]
	PUBLIC METHOD getPesoTotal() CLASS Juros
		LOCAL acumulador := 0.0 AS FLOAT, indice := 1 AS INT
		FOR indice := 1 TO Quantidade
			acumulador += Pesos[indice]
		NEXT
		RETURN acumulador
	
	// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	PUBLIC METHOD jurosParaAcrescimo(juros AS FLOAT) CLASS Juros
		LOCAL pesoTotal := getPesoTotal() AS FLOAT, acumulador := 0.0 AS FLOAT, indice := 1 AS INT
		IF juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0
			RETURN 0.0
		ENDIF
		
		FOR indice := 1 TO Quantidade
			IF Composto
				acumulador += Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
			ELSE
				acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
			ENDIF
		NEXT
		
		RETURN (pesoTotal / acumulador - 1.0) * 100.0

	// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	PUBLIC METHOD acrescimoParaJuros(acrescimo AS FLOAT, precisao AS INT, maxIteracoes AS INT, maxJuros AS FLOAT) CLASS Juros
		LOCAL pesoTotal := getPesoTotal() AS FLOAT
		IF acrescimo <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0
			RETURN 0.0
		ENDIF
		LOCAL indice := 1 AS INT, minJuros := 0.0 AS FLOAT, medJuros := maxJuros / 2.0 AS FLOAT, minDiferenca := 0.1 ^ precisao AS FLOAT

		FOR indice := 1 TO maxIteracoes
			medJuros := (minJuros + maxJuros) / 2.0
			IF (maxJuros - minJuros) < minDiferenca
				RETURN medJuros
			ENDIF
			IF jurosParaAcrescimo(medJuros) < acrescimo
				minJuros:= medJuros
			ELSE
				maxJuros := medJuros
			ENDIF
		NEXT

		RETURN medJuros	
		
END CLASS


