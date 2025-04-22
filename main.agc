// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 22/04/2025: versão feita sem muito conhecimento de AppGameKit

// propriedades da janela
SetWindowTitle("Juros")
SetWindowSize(640, 480, 0)

// variáveis globais para simplificar as chamadas
global Quantidade as integer = 3
global Composto as integer = 1  // 1 = true, outros = false
global Periodo as float = 30.0
global Pagamentos as float[]
global Pesos as float[]

// os arrays são populados dinamicamente
for indice = 0 to Quantidade - 1
	Pagamentos.insert((indice + 1.0) * Periodo)
	Pesos.insert(1.0)
next indice

// calcula e guarda os resultados
pesoTotal as float
pesoTotal = getPesoTotal()
acrescimoCalculado as float
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado as float
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 6, 40, 50.0)

do
	// mostra os resultados
	Print("Peso total = " + STR(pesoTotal))
	Print("Acréscimo = " + STR(acrescimoCalculado))
	Print("Juros = " + STR(jurosCalculado))
    Sync()
loop

// calcula a somatória de Pesos()
function getPesoTotal()
	acumulador as float = 0.0
 	for indice = 0 to Quantidade - 1
 		acumulador = acumulador + Pesos[indice]
 	next indice
endfunction acumulador

// calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(juros as float)
	pesoTotal as float
	pesoTotal = getPesoTotal()
	if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then exitfunction 0.0
	acumulador as float = 0.0
	for indice = 0 to Quantidade - 1
		if Composto = 1
			acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo)
		else
			acumulador = acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)
		endif
	next indice
	if acumulador <= 0.0 then exitfunction 0.0
endfunction (pesoTotal / acumulador - 1.0) * 100.0

// calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(acrescimo as float, precisao as integer, maxIteracoes as integer, maxJuros as float)
	pesoTotal as float
	pesoTotal = getPesoTotal()
	if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then exitfunction 0.0
	minJuros as float = 0.0
	medJuros as float
	medJuros = maxJuros / 2.0
	minDifereca as float
	minDiferenca = 0.1 ^ precisao
	for indice = 1 to maxIteracoes
		if maxJuros - minJuros < minDiferenca then exitfunction medJuros
		if jurosParaAcrescimo(medJuros) < acrescimo then minJuros = medJuros else maxJuros = medJuros
		medJuros = (minJuros + maxJuros) / 2.0
	next indice
endfunction medJuros
