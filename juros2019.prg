// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 22/03/2025: versão feita sem muito conhecimento de dBase

SET DECIMALS TO 10  // para resultados com dez casas após a vírgula

// cria um objeto oJuros da classe Juros e inicializa as propriedades
oJuros = NEW Juros(3, .T., 30.0)

// as inicializações dos arrays são dinâmicas
FOR indice = 1 TO oJuros.Quantidade
	oJuros.Pagamentos[indice] = indice * oJuros.Periodo
	oJuros.Pesos[indice] = 1.0
NEXT

// calcula e guarda os resultados dos métodos
pesoTotal = oJuros.getPesoTotal()
acrescimoCalculado = oJuros.jurosParaAcrescimo(3.0)
jurosCalculado = oJuros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

// imprime os resultados
? "Peso total = " + pesoTotal
? "Acrescimo = " + acrescimoCalculado
? "Juros = " + jurosCalculado

// a classe Juros contêm propriedades para simplificar chamada a métodos
CLASS Juros(quant, comp, per)  // inicializa escalares e aloca arrays
	this.Quantidade = quant
	this.Composto = comp
	this.Periodo = per
	this.Pagamentos = NEW ARRAY(quant)
	this.Pesos = NEW ARRAY(quant)
	
	// calcula a somatória de Pesos[]
	FUNCTION getPesoTotal()
		acumulador = 0.0
		FOR indice = 1 TO this.Quantidade
			acumulador += this.Pesos[indice]
		NEXT
		RETURN acumulador

	// calcula o acréscimo a partir dos juros e parcelas
	FUNCTION jurosParaAcrescimo(juros)
		pesoTotal = this.getPesoTotal()
		IF pesoTotal <= 0.0 OR this.Quantidade < 1 OR this.Periodo <= 0.0 OR juros <= 0.0
			RETURN 0.0
		ENDIF

		acumulador = 0.0
		FOR indice = 1 TO this.Quantidade
			IF this.Composto
				acumulador += this.Pesos[indice] / (1.0 + juros / 100.0) ^ (this.Pagamentos[indice] / this.Periodo)
			ELSE
				acumulador += this.Pesos[indice] / (1.0 + juros / 100.0 * this.Pagamentos[indice] / this.Periodo)
			ENDIF
		NEXT

		IF acumulador <= 0.0
			RETURN 0.0
		ENDIF
		RETURN (pesoTotal / acumulador - 1.0) * 100.0

	// calcula os juros a partir do acréscimo e parcelas
	FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maximoJuros)
		pesoTotal = this.getPesoTotal()
		IF pesoTotal <= 0.0 OR this.Quantidade < 1 OR this.Periodo <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maximoJuros <= 0.0
			RETURN 0.0
		ENDIF

		minJuros = 0.0
		maxJuros = maximoJuros
		minDiferenca = 0.1 ^ precisao
		medJuros = (maximoJuros) / 2.0

		FOR iteracao = 1 TO maxIteracoes
			IF (maxJuros - minJuros) < minDiferenca
				RETURN medJuros
			ENDIF
			IF this.jurosParaAcrescimo(medJuros) < acrescimo
				minJuros = medJuros
			ELSE
				maxJuros = medJuros
			ENDIF
			medJuros = (minJuros + maxJuros) / 2.0
		NEXT
		
		RETURN medJuros
ENDCLASS
