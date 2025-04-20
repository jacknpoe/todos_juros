' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 19/04/2025: versão feita sem muito conhecimento de Blitz BASIC

' esse tipo é, na prática, uma classe, com atributos para simplificar as chamadas aos métodos
Type TJuros
	Field Quantidade:Int
	Field Composto:Int
	Field Periodo:Double
	Field Pagamentos:Double[]
	Field Pesos:Double[]

	' construtor, que inicializa as variáveis escalares e aloca os arrays
	Method New(quantidade:Int, composto:Int, periodo:Double)
		Self.Quantidade = quantidade
		Self.Composto = composto
		Self.periodo = periodo
		Self.Pagamentos = New Double[quantidade]
		Self.Pesos = New Double[quantidade]
	End Method

	' calcula a somatória de Pesos[]
	Method getPesoTotal:Double()
		Local acumulador:Double = 0.0, indice:Int
		For indice = 0 To Self.Quantidade - 1
			acumulador :+ Self.Pesos[indice]
		Next indice
		Return acumulador
	End Method

	' calcula o acréscimo a partir dos juros e parcelas
	Method jurosParaAcrescimo:Double(juros:Double)
		Local pesoTotal:Double = Self.getPesoTotal()
		If Self.Quantidade < 1 Or Self.Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0 Then Return 0.0
		Local acumulador:Double = 0.0, indice:Int
		For indice = 0 To Self.Quantidade - 1
			If Self.Composto
				acumulador :+ Self.Pesos[indice] / (1.0 + juros / 100.0) ^ (Self.Pagamentos[indice] / Self.Periodo)
			Else
				acumulador :+ Self.Pesos[indice] / (1.0 + juros / 100.0 * Self.Pagamentos[indice] / Self.Periodo)
			End If
		Next indice
		If acumulador <= 0.0 Then Return 0.0
		Return (pesoTotal / acumulador - 1.0) * 100.0
	End Method

	' calcula os juros a partir do acréscimo e parcelas
	Method acrescimoParaJuros:Double(acrescimo:Double, precisao:Int, maxIteracoes:Int, maxJuros:Double)
		Local pesoTotal:Double = Self.getPesoTotal()
		If Self.Quantidade < 1 Or Self.Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0 Then Return 0.0
		Local minJuros:Double = 0.0, medJuros:Double = maxJuros / 2.0, minDiferenca:Double = 0.1 ^ precisao, indice:Int
		For indice = 1 To maxIteracoes
			If maxJuros - minJuros < minDiferenca Then Return medJuros
			If Self.jurosParaAcrescimo(medJuros) < acrescimo Then minJuros = medJuros Else maxJuros = medJuros
			medJuros = (minJuros + maxJuros) / 2.0
		Next indice
		Return medJuros
	End Method
End Type

' cria um objeto Juros do tipo TJuros e inicializa os atributos
Local Juros:TJuros = New TJuros(3, 1, 30.0)

' inicializa dinamicamente os arrays
Local indice:Int
For indice = 0 To Juros.Quantidade - 1
	Juros.Pagamentos[indice] = (indice + 1.0) * Juros.Periodo
	Juros.Pesos[indice] = 1.0
Next indice

' calcula e guarda os resultados dos métodos
Local pesoTotal:Double = Juros.getPesoTotal()
Local acrescimoCalculado:Double = Juros.jurosParaAcrescimo(3.0)
Local jurosCalculado:Double = Juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
Print "Peso total  = " + pesoTotal
Print "Acréscimo  = " + acrescimoCalculado
Print "Juros  = " + jurosCalculado