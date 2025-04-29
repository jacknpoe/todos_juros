' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 29/04/2025: versão feita sem muito conhecimento de Monkey 2

' classse com atributos que simplificam as chamadas aos métodos
Class cJuros
	Field Quantidade:Int
	Field Composto:Bool
	Field Periodo:Float
	Field Pagamentos:Float[]
	Field Pesos:Float[]

	' construtor, que inicializa atributos escalares e aloca os arrays
	Method New(quantidade:Int, composto:Bool, periodo:Float)
		Self.Quantidade = quantidade
		Self.Composto = composto
		Self.Periodo = periodo
		Self.Pagamentos = Self.Pagamentos.Resize(quantidade)
		Self.Pesos = Self.Pesos.Resize(quantidade)
	End

	' calcula a somatória de Pesos[]
	Method getPesoTotal:Float()
		Local acumulador:Float = 0.0
		For Local indice:Int = 0 Until Self.Quantidade
			acumulador += Self.Pesos[indice]
		End
		Return acumulador
	End

	' calcula o acréscimo a partir dos juros e parcelas
	Method jurosParaAcrescimo:Float(juros:Float)
		Local pesoTotal:Float = Self.getPesoTotal()
		If Self.Quantidade < 1 Or Self.Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0
			Return 0.0
		End
		
		Local acumulador:Float = 0.0
		For Local indice:Int = 0 Until Self.Quantidade
			If Self.Composto
				acumulador += Self.Pesos[indice] / Pow(1.0 + juros / 100.0, Self.Pagamentos[indice] / Self.Periodo)
			Else
				acumulador += Self.Pesos[indice] / (1.0 + juros / 100.0 * Self.Pagamentos[indice] / Self.Periodo)
			End
		End
		If acumulador <= 0.0
			Return 0.0
		End
		Return (pesoTotal / acumulador - 1.0) * 100.0
	End

	' calcula os juros a partir do acréscimo e parcelas
	Method acrescimoParaJuros:Float(acrescimo:Float, precisao:Int, maxIteracoes:Int, maxJuros:Float)
		Local pesoTotal:Float = Self.getPesoTotal()
		If Self.Quantidade < 1 Or Self.Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0
			Return 0.0
		End

		Local minJuros:Float = 0.0
		Local medJuros:Float = maxJuros / 2.0
		Local minDiferenca:Float = Pow(0.1, precisao)
		For Local indice:Int = 1 To maxIteracoes
			If maxJuros - minJuros < minDiferenca
				Return medJuros
			Endif
			If Self.jurosParaAcrescimo(medJuros) < acrescimo
				minJuros = medJuros
			Else
				maxJuros = medJuros
			End
			medJuros = (minJuros + maxJuros) / 2.0
		End
		Return medJuros
	End
End

Function Main()
	' cria um objeto juros da classe cJuros e inicializa os atributos, os arrays dinamicamente
	Local juros:cJuros = New cJuros(3, True, 30.0)
	
	For Local indice:Int = 0 Until juros.Quantidade
		juros.Pagamentos[indice] = (indice + 1.0) * juros.Periodo
		juros.Pesos[indice] = 1.0
	End
		
	' calcula e guarda os resultados dos métodos
	Local pesoTotal:Float = juros.getPesoTotal()
	Local acrescimoCalculado:Float = juros.jurosParaAcrescimo(3.0)
	Local jurosCalculado:Float = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)
	
	' imprime os resultados
	Print("Peso total = " + pesoTotal)
	Print("Acréscimo = " + acrescimoCalculado)
	Print("Juros = " + jurosCalculado)
End