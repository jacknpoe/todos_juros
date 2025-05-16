' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 16/05/2025: versão feita sem muito conhecimento de OpenOffice Basic

' declara variáveis globais para simplificar as chamadas
Global Quantidade
Global Composto
Global Periodo
Global Pagamentos
Global Pesos

Sub Main
	' inicializa globais, os arrys de forma dinâmica
	Quantidade = 3
	Composto = True
	Periodo = 30.0
	ReDim Pagamentos(Quantidade-1)
	ReDim Pesos(Quantidade-1)
	
	For indice = 0 To Quantidade - 1
		Pagamentos(indice) = (indice + 1) * Periodo
		Pesos(indice) = 1.0
	Next indice

	' calcula e guarda os retornos das funções
	pesoTotal = getPesoTotal()
	acrescimoCalculado = jurosParaAcrescimo(3)
	jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

	' imprime os resultados
	MsgBox "Peso total = " + pesoTotal + Chr(13) + "Acréscimo = " + acrescimoCalculado + Chr(13) + "Juros = " + jurosCalculado, 0, "Juros"
End Sub

' calcula a somatória de pesos()
Function getPesoTotal()
	acumulador = 0.0
	For indice = 0 To Quantidade - 1
		acumulador = acumulador + Pesos(indice)
	Next indice
	getPesoTotal = acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo(juros)
	pesoTotal = getPesoTotal()
	jurosParaAcrescimo = 0.0
	if Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0 Then Exit Function
	acumulador = 0.0
	For indice = 0 To Quantidade - 1
		If Composto Then
			acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
		Else
			acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
		End If
	Next indice
	If acumulador <= 0.0 Then Exit Function
	jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
End Function

' calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
	pesoTotal = getPesoTotal()
	acrescimoParaJuros = 0.0
	if Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0 Then Exit Function
	minJuros = 0.0
	medJuros = maxJuros / 2.0
	minDiferenca = 0.1 ^ precisao
	For indice = 1 To maxIteracoes
		if maxJuros - minJuros < minDiferenca Then Exit For
		if jurosParaAcrescimo(medJuros) < acrescimo Then minJuros = medJuros Else maxJuros = medJuros
		medJuros = (minJuros + maxJuros) / 2.0
	Next indice
	acrescimoParaJuros = medJuros
End Function