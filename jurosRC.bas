' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 07/02/2026: versão feita sem muito conhecimento de RCBasic
' ATENÇÃO: RCBasic suporta apenas 127 pagamentos, se precisar de mais, use funções

' variáveis globais e inicialização de escalares
Quantidade = 3
Composto = true
Periodo = 30.0
Dim Pagamentos[Quantidade - 1]
Dim Pesos[Quantidade - 1]

' inicializa os elementos dos arrays
For indice = 0 To Quantidade - 1
	Pagamentos[indice] = (indice + 1.0) * Periodo
	Pesos[indice] = 1.0
Next

' Pagamentos() e Pesos() podem ser usadas para substituir os arrays para 128+ parcelas
' lembre-se de trocar colchetes [] por parênteses () onde encontrar chamadas aos arrays
' Pagamentos
'Function Pagamentos(indice)
'	Return (indice + 1.0) * Periodo
'End Function

' Pagamentos
'Function Pesos(indice)
'	Return 1.0
'End Function

' função que permite mais do que seis casas decimais (do ChatGPT, corrigida)
Function numToStr$(valor, casas)
    fator = 10 ^ casas
    valor = valor + 0.5 / fator
    inteiro = Int(valor)
    fracao = valor - inteiro

    cadeia$ = LTrim$(Str$(inteiro)) + "."

    For indice = 1 To casas
        fracao = fracao * 10
        digito = Int(fracao)
        cadeia$ = cadeia$ + Chr$(48 + digito)
        fracao = fracao - digito
    Next

    Return cadeia$
End Function

' imprime uma etiqueta, " = ", e o valor com 15 casas decimais
Sub imprime(legenda$, valor)
	Print legenda$; " = "; numToStr(valor, 15)
End Sub

' calcula a somatória dos elementos de Pesos[]
Function getPesoTotal()
	acumulador = 0.0
	For indice = 0 To Quantidade - 1
		acumulador = acumulador + Pesos[indice]
	Next
	Return acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo(juros)
	pesoTotal = getPesoTotal()
	If Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0 Then
		Return 0.0
	End If
	acumulador = 0.0
	
	For indice = 0 To Quantidade - 1
		If Composto Then
			acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
		Else
			acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
		End If
	Next

	If acumulador <= 0.0 Then
		Return 0.0
	End If
	Return (pesoTotal / acumulador - 1.0) * 100.0
End Function

' calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	pesoTotal = getPesoTotal()
	If Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros < 0.0 Then
		Return 0.0
	End If
	minJuros = 0.0
	medJuros = maxJuros / 2.0
	minDiferenca = 0.1 ^ precisao
	
	For iteracao = 1 To maxIteracoes
		If maxJuros - minJuros < minDiferenca Then
			Return medJuros
		End If
		If jurosParaAcrescimo(medJuros) < acrescimo Then
			minJuros = medJuros
		Else
			maxJuros = medJuros
		End If
		medJuros = (minJuros + maxJuros) / 2.0
	Next
	
	Return medJuros
End Function

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

' imprime os resultados
imprime("Peso total", pesoTotal)
imprime("Acréscimo", acrescimoCalculado)
imprime("Juros", jurosCalculado)
