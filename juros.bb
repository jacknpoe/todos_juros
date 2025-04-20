; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 20/04/2025: versão feita sem muito conhecimento de Blitz3D

; variáveis globais para simplificar as chamadas  COMPOSTO: 0 = False, outros = True
Const QUANTIDADE = 3 
Global Composto=1, Periodo#=30.0, Pagamentos[QUANTIDADE], Pesos[QUANTIDADE]

; calcula a somatória de Pesos[]
Function getPesoTotal#()
	acumulador# = 0.0
	For indice = 0 To QUANTIDADE - 1
		acumulador# = acumulador# + Pesos[indice]
	Next
	Return acumulador#
End Function

; calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo#(juros#)
	pesoTotal# = getPesoTotal()
	If QUANTIDADE < 1 Or Periodo# <= 0.0 Or pesoTotal# <= 0.0 Or juros# <= 0.0 Then Return 0.0
	acumulador# = 0.0
	For indice = 0 To QUANTIDADE - 1
		If Composto
			acumulador# = acumulador# + Pesos[indice] / (1.0 + juros# / 100.0) ^ (Pagamentos[indice] / Periodo#)
		Else
			acumulador# = acumulador# + Pesos[indice] / (1.0 + juros# / 100.0 * Pagamentos[indice] / Periodo#)
		End If
	Next
	If acumulador# <= 0.0 Then Return 0.0
	Return (pesoTotal# / acumulador# - 1.0) * 100.0
End Function

; calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros#(acrescimo#, precisao, maxIteracoes, maxJuros#)
	pesoTotal# = getPesoTotal()
	If QUANTIDADE < 1 Or Periodo# <= 0.0 Or pesoTotal# <= 0.0 Or acrescimo# <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros# <= 0.0 Then Return 0.0
	minJuros# = 0.0
	medJuros# = maxJuros / 2.0
	minDiferenca# = 0.1 ^ precisao
	For indice = 1 To maxIteracoes
		If maxJuros# - minJuros# < minDiferenca# Then Return medJuros#
		If jurosParaAcrescimo(medJuros#) < acrescimo# Then minJuros# = medJuros# Else maxJuros# = medJuros#
		medJuros# = (minJuros# + maxJuros#) / 2.0
	Next
	Return medJuros#
End Function

; inicializa dinamicamente os arrays
For indice = 0 To QUANTIDADE - 1
	Pagamentos[indice] = (indice + 1.0) * Periodo#
	Pesos[indice] = 1.0
Next

; calcula e guarda os resultados dos métodos
pesoTotal# = getPesoTotal#()
acrescimoCalculado# = jurosParaAcrescimo#(3.0)
jurosCalculado# = acrescimoParaJuros#(acrescimoCalculado#, 15, 100, 50.0)

; imprime os resultados
Print "Peso total  = " + pesoTotal#
Print "Acréscimo  = " + acrescimoCalculado#
Print "Juros  = " + jurosCalculado#