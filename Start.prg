FUNCTION Start() AS VOID
	SET DECIMALS TO 15
	// cria um objeto oJuros da classe Juros e inicializa os valores
	LOCAL oJuros AS Juros
	oJuros := Juros{}
	oJuros.Init(3, TRUE, 30.0, {30.0, 60.0, 90.0}, {1.0, 1.0, 1.0})
	
	// calcula e guarda os resultados dos métodos
	LOCAL pesoTotal AS FLOAT, acrescimoCalculado AS FLOAT, jurosCalculado AS FLOAT
	pesoTotal := oJuros.getPesoTotal()
	acrescimoCalculado := oJuros.jurosParaAcrescimo(3.0)
	jurosCalculado := oJuros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)
	
	// imprime os resultados
	? "Peso total = ", pesoTotal
	? "Acréscimo = ", acrescimoCalculado
	? "Juros = ", jurosCalculado
RETURN
