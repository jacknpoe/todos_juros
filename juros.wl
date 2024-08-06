// JUROS

// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 06/08/2024: versão feita sem muito conhecimento de WLanguage

// cria um objeto OJuros da classe CJuros e inicializa as propriedades
OJuros is CJuros(3, True, 30.0)
FOR indice = 1 _TO_ OJuros.Quantidade
	OJuros.Pagamentos.Add(indice * 30.0)
	OJuros.Pesos.Add(1.0)
END

// calcula e guarda os resultados dos métodos
pesoTotalCalculado is real = OJuros.getPesoTotal()
acrescimoCalculado is real = OJuros.jurosParaAcrescimo(3.0)
jurosCalculado is real = OJuros.acrescimoParaJuros(acrescimoCalculado)

// imprime os resultados
Trace("Peso total = " + pesoTotalCalculado)
Trace("Acréscimo = " + acrescimoCalculado)
Trace("Juros = " + jurosCalculado)

// CJUROS

// classe juros, com propriedades para simplificar as chamadas
CJuros is a Class
PUBLIC
	Quantidade is int
	Composto is boolean
	Periodo is real
	Pagamentos is array of real
	Pesos is array of real
END

// construtor, que inicializa as variáveis não arrays
PROCEDURE Constructor(qtd is int, cmp is boolean, prd is real)
Quantidade = qtd
Composto = cmp
Periodo = prd

// calcula a somatória do array Pesos[]
PROCEDURE getPesoTotal(): real
acumulador is real = 0.0
FOR indice = 1 _TO_ Quantidade
	acumulador += Pesos[indice]
END
RETURN acumulador

// calcula o acréscimo a partir dos juros e parcelas
PROCEDURE jurosParaAcrescimo(juros is real): real
pesoTotal is real = getPesoTotal()
IF juros <= 0.0 OR Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 THEN RETURN 0.0
acumulador is real = 0.0
	
FOR indice = 1 _TO_ Quantidade
	IF Composto THEN
		acumulador += Pesos[indice] / Power(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
	ELSE
		acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
	END
END
	
RETURN (pesoTotal / acumulador - 1.0) * 100.0

// calcula os juros a partir do acréscimo e parcelas
PROCEDURE acrescimoParaJuros(acrescimo is real, precisao is int = 15, maxIteracoes is int = 100, maxJuros is real = 50.0): real
pesoTotal is real = getPesoTotal()
IF acrescimo <= 0.0 OR Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN RETURN 0.0
minJuros is real = 0.0
medJuros is real = maxJuros / 2.0
minDiferenca is real = Power(0.1, precisao)

FOR indice = 1 _TO_ maxIteracoes
	medJuros = (minJuros + maxJuros) / 2.0
	IF (maxJuros - minJuros) < minDiferenca THEN RETURN medJuros
	IF jurosParaAcrescimo(medJuros) < acrescimo THEN
		minJuros = medJuros
	ELSE
		maxJuros = medJuros
	END
END

RETURN medJuros

