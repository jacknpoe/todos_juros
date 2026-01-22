NB. Calculo do juros, sendo que precisa de arrays pra isso
NB. Versão 0.1: 22/01/2026: versao feita sem muito conhecimento de J

9!:11]16  NB. define precisão de impressão

NB. variáveis globais, os arrays começam vazios
quantidade =: 300000
composto =: 1   NB. TRUE
periodo =: 30.0

NB. de acordo com o ChatGPT, aumenta a previsibilidade e o acúmulo de elementos
resetArrays =: 3 : 0
  pagamentos =: i. 0
  pesos =: i. 0
)

NB. adiciona elementos nos arrays pagamentos e pesos
iniArrays =: 3 : 0
	for_indice. i. quantidade do.
		pagamentos =: pagamentos , (indice + 1) * periodo
		pesos =: pesos , 1.0
	end.
)

NB. retorna a somatória de todos os elementos em pesos
getPesoTotal =: 3 : 0
NB.	acumulador =. 0.0
NB.	for_indice. i. quantidade do.
NB.		acumulador =. acumulador + indice { pesos
NB.	end.
NB.	acumulador
	+/ pesos
)

NB. calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo =: 3 : 0
	juros =. y
	pesoTotal =. getPesoTotal ''
 	if. (quantidade < 1) +. (periodo <= 0.0) +. (juros <= 0.0) +. (pesoTotal <= 0.0) do.
		0.0
	else.
		if. composto do.
			acumulador =. +/ pesos % ((1.0 + juros % 100.0) ^ (pagamentos % periodo))
		else.
			acumulador =. +/ pesos % (1.0 + (juros % 100.0) * (pagamentos % periodo))
		end.

		if. acumulador <= 0.0 do.
			0.0
		else.
			((pesoTotal % acumulador) - 1.0) * 100.0
		end.
	end.	
)

NB. calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros =: 3 : 0
	'acrescimo precisao maxIteracoes maxJuros' =. y
	pesoTotal =. getPesoTotal ''
 	if. (quantidade < 1) +. (periodo <= 0.0) +. (acrescimo <= 0.0) +. (pesoTotal <= 0.0) +. (precisao < 1) +. (maxIteracoes < 1) +. (maxJuros <= 0.0) do.
		0.0
	else.
		minJuros =. 0.0
		medJuros =. maxJuros % 2.0
		minDiferenca =. 0.1 ^ precisao

		for_indice. i. maxIteracoes do.
			if. (maxJuros - minJuros) < minDiferenca do.
				break.
			end.
			if. (jurosParaAcrescimo medJuros) < acrescimo do.
				minJuros =. medJuros
			else.
				maxJuros =. medJuros
			end.
			medJuros =. (minJuros + maxJuros) % 2.0
		end.
		medJuros
	end.
)

NB. para inicializar os arrays
resetArrays ''
iniArrays ''

NB. calcula e guarda os resultados das funções
pesoTotal =: getPesoTotal ''
acrescimoCalculado =: jurosParaAcrescimo 3.0
jurosCalculado =: acrescimoParaJuros (acrescimoCalculado ; 15 ; 65 ; 50.0)

NB. imprime os resultados
smoutput 'Peso total = ', ": pesoTotal
smoutput 'Acréscimo = ', ": acrescimoCalculado
smoutput 'Juros = ', ": jurosCalculado

exit ''
