' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 11/02/2026: versão feita sem muito conhecimento de Oxygen Basic

' globais para simplificar as chamadas às funções e inicialização de escalares
dim as integer Quantidade, indice, as boolean Composto, as extended Periodo
Quantidade = 3
Composto = true
Periodo = 30.0
dim as extended Pagamentos at getmemory(Quantidade * sizeof(extended))
dim as extended Pesos at getmemory(Quantidade * sizeof(extended))

' inicialização dinâmica de arrays
for indice = 1 to Quantidade
	Pagamentos(indice) = indice * Periodo
	Pesos(indice) = 1.0
next

' calcula a soma dos elementos em Pesos()
function getPesoTotal as extended
	dim as extended acumulador, as integer indice
	for indice = 1 to Quantidade
		acumulador += Pesos(indice)
	next
	return acumulador
end function

' calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros as extended) as extended
	dim as extended pesoTotal, acumulador, base, expoente, as integer indice
	pesoTotal = getPesoTotal()
	if Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 then return 0.0
	acumulador = 0.0
	base = 1.0 + juros / 100.0

	for indice = 1 to Quantidade
		if Composto then
			expoente = Pagamentos(indice) / Periodo
			acumulador += Pesos(indice) / base ^ expoente
		else
			acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
		end if
	next

	if acumulador <= 0.0 then return 0.0
	return (pesoTotal / acumulador - 1.0) * 100.0
end function

' calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo as extended, precisao as integer, maxIteracoes as integer, maxJuros as extended) as extended
	dim as extended pesoTotal, minJuros, medJuros, minDiferenca, as integer iteracao
	pesoTotal = getPesoTotal()
	if Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 then return 0.0
	minJuros = 0.0
	medJuros = maxJuros / 2.0
	minDiferenca = 0.1 ^ precisao
	
	for iteracao = 1 to maxIteracoes
		if maxJuros - minJuros < minDiferenca then return medJuros
		if jurosParaAcrescimo(medJuros) < acrescimo then
			minJuros = medJuros
		else
			maxJuros = medJuros
		end if
		medJuros = (minJuros + maxJuros) / 2.0
	next

	return medJuros
end function

' calcula e guarda os resultadosdas funções
dim as extended pesoTotal, acrescimoCalculado, jurosCalculado
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

' imprime os resultados
print "Peso total = " + pesoTotal + " | Acréscimo = " + acrescimoCalculado + " | Juros = " + jurosCalculado

' libera a memória (só para conformar)
freememory @Pagamentos
freememory @Pesos
