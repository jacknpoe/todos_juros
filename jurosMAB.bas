' C�lculo dos juros, sendo que precisa de parcelas pra isso
' Vers�o 0.1: 08/04/2025: vers�o feita sem muito conhecimento de micro(A)

' vari�veis globais para simplificar as chamadas
var quantidade, TRUE, FALSE, composto, periodo
quantidade = 3 : TRUE = -1 : FALSE = 0 : composto = TRUE : periodo = 30
var pagamentos[quantidade], pesos[quantidade]

' as chamadas de fun��o ir�o alterar essas vari�veis
var pesoTotal, acrescimoCalculado, jurosCalculado

' os arrays s�o definidos dinamicamente
var indice
while indice < quantidade
	pagamentos[indice] = (indice + 1) * periodo
	pesos[indice] = 1
	indice = indice + 1
wend


' calcula a somat�ria de Pesos()
func getPesoTotal()
	var indice, acumulador
	indice = 0 : acumulador = 0
	while indice < quantidade
		acumulador = acumulador + Pesos[indice]
		indice = indice + 1
	wend
	pesoTotal = acumulador
endfn

' calcula o acr�scimo a partir dos juros e parcelas (o interpretador n�o consegue fazer os ifs de < 0)
func jurosParaAcrescimo(var juros)
	var indice, acumulador
	getPesoTotal()
	indice = 0 : acumulador = 0
	while indice < quantidade
		if composto = TRUE
			acumulador = acumulador + pesos[indice] / (1 + juros / 100) ^ (pagamentos[indice] / periodo)
		else
			acumulador = acumulador + pesos[indice] / (1 + juros / 100 * pagamentos[indice] / periodo)
		endif
		indice = indice + 1
	wend
	acrescimoCalculado = (pesoTotal / acumulador - 1) * 100
endfn

' calcula os juros a partir do acr�scimo e parcelas
func acrescimoParaJuros(var acrescimo, var maxiteracoes, var maximojuros)
	var iteracao, minjuros, maxjuros, medjuros
	iteracao = 0 : minjuros = 0 : maxjuros = maximojuros : medjuros = (maxjuros / 2)
	while iteracao < maxiteracoes
		jurosParaAcrescimo(medjuros)
		if acrescimoCalculado < acrescimo
			minjuros = medjuros
		else
			maxjuros = medjuros
		endif
		medjuros = ((minjuros + maxjuros) / 2)
		iteracao = iteracao + 1
	wend
	jurosCalculado = medjuros
endfn

mode 1 : wcolor 0,0,0 : fcolor 128,128,255
' por conta da forma de retorno das fun��es, tem que chamar e imprimir o valor logo em seguida
getPesoTotal()
print 10,10,"Peso total = " : print 114,10,pesoTotal : swap

jurosParaAcrescimo( 3)
print 10,30,"Acr�scimo = " : print 106,30,acrescimoCalculado : swap

acrescimoParaJuros(acrescimoCalculado, acrescimoCalculado, 100, 50)   'aqui, essa gambierra dribla um bug do interpretador
print 10,50,"Juros = " : print 74,50,jurosCalculado : swap