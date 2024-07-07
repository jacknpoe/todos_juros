module juros
import StdEnv

// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 21/06/2024: versão feita sem muito conhecimento de Clean
//        0.2: 07/07/2024: comentários de versões

// define varíáveis globais para simplificar as chamadas
quantidade :: Int
quantidade = 3
composto :: Bool
composto = True
periodo :: Real
periodo = 30.0
pagamentos :: {#Real}
pagamentos = {30.0, 60.0, 90.0}
pesos :: {#Real}
pesos = {1.0, 1.0, 1.0}

// função recursiva que realmente calcula a somatória de Pesos[]
rGetPesoTotal :: Int -> Real
rGetPesoTotal indice
	| indice == 0 = pesos.[0]
	| otherwise = pesos.[indice] + rGetPesoTotal (indice - 1)

// perfume que calcula a somatória de Pesos[]
getPesoTotal = rGetPesoTotal (quantidade - 1)

// função recursiva que calcula o amortecimento das parcelas em juros compostos
rJurosCompostos :: Int Real -> Real
rJurosCompostos indice juros
	| indice == 0 = pesos.[0] / (1.0 + juros / 100.0) ^ (pagamentos.[0] / periodo)
	| otherwise = pesos.[indice] / (1.0 + juros / 100.0) ^ (pagamentos.[indice] / periodo) + rJurosCompostos (indice - 1) juros

// função recursiva que calcula o amortecimento das parcelas em juros simples
rJurosSimples :: Int Real -> Real
rJurosSimples indice juros
	| indice == 0 = pesos.[0] / (1.0 + juros / 100.0 * pagamentos.[0] / periodo)
	| otherwise = pesos.[indice] / (1.0 + juros / 100.0 * pagamentos.[indice] / periodo) + rJurosCompostos (indice - 1) juros

// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo :: Real -> Real
jurosParaAcrescimo juros
	| composto = (getPesoTotal / rJurosCompostos (quantidade - 1) juros - 1.0) * 100.0
	| otherwise = (getPesoTotal / rJurosSimples (quantidade - 1) juros - 1.0) * 100.0

// função recursiva no lugar de um for que realmente calcula os juros
rAcrescimoParaJuros :: Real Real Int Real Real Real -> Real
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros
	| iteracaoAtual == 0 || (maxJuros - minJuros) < minDiferenca = medJuros
	| jurosParaAcrescimo medJuros < acrescimo = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
	| otherwise = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros :: Real Int Int Real -> Real
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
	rAcrescimoParaJuros acrescimo (0.1 ^ toReal precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

// calcula e guarda os resultados das funções
pesoTotal :: Real
pesoTotal = getPesoTotal
acrescimoCalculado :: Real
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0

Start = "Peso total = " +++ toString pesoTotal
	+++ "\nAcréscimo = " +++ toString acrescimoCalculado
	+++ "\nJuros = " +++ toString jurosCalculado
