module juros
import StdEnv

// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 21/06/2024: versão feita sem muito conhecimento de Clean
//        0.2: 07/07/2024: comentários de versões
//        0.3: 09/11/2026: melhoria de comentários; retirados casos especiais; listas escaláveis criadas dinamicamente; cabeça e cauda em vez de indice
//                         avaliados de variáveis, parâmetros e cálculos; correção onde rJurosSimples chamava rJurosCompostos
//        0.4: 10/11/2026: funções recursivas alteradas para permitir Tail Call Optimization (TCO)

// PARA COMPILAR: cpm project juros create && cpm project juros.prj set -h 64M -s 2M && cpm project juros.prj build

// variáveis escalares globais para simplificar as chamadas
quantidade :: Int
quantidade = 300000
composto :: Bool
composto = True
periodo :: Real
periodo = 30.0

// função recursiva que cria a lista pagamentos
rCriaPagamentos :: Int [Real] -> [Real]
rCriaPagamentos indice acumulador
    | indice > quantidade = acumulador
    | otherwise = rCriaPagamentos (indice + 1) [toReal indice * periodo : acumulador]

// função açúcar que cria a lista pagamentos
criaPagamentos :: [Real]
criaPagamentos = rCriaPagamentos 1 []
    
// função recursiva que cria a lista pesos
rCriaPesos :: Int [Real] -> [Real]
rCriaPesos indice acumulador
    | indice > quantidade = acumulador
    | otherwise = rCriaPesos (indice + 1) [1.0 : acumulador]

// função açúcar que cria a lista pesos
criaPesos :: [Real]
criaPesos = rCriaPesos 1 []

// listas globais para simplificar as chamadas
pagamentos :: [Real]
pagamentos = criaPagamentos
pesos :: [Real]
pesos = criaPesos

// função recursiva que calcula a somatória de Pesos[]
rGetPesoTotal :: [Real] Real -> Real
rGetPesoTotal [] acumulador = acumulador
rGetPesoTotal [hpes:tpes] acumulador = rGetPesoTotal tpes (hpes + acumulador)

// função açúcar que calcula a somatória de Pesos[]
getPesoTotal :: Real
getPesoTotal = rGetPesoTotal pesos 0.0

// função recursiva que calcula o amortecimento das parcelas em juros compostos
rJurosCompostos :: [Real] [Real] Real Real -> Real
rJurosCompostos [] [] _ acumulador = acumulador
rJurosCompostos [hpag:tpag] [hpes:tpes] juros acumulador = rJurosCompostos tpag tpes juros (hpes / (1.0 + juros / 100.0) ^ (hpag / periodo) + acumulador)

// função recursiva que calcula o amortecimento das parcelas em juros simples
rJurosSimples :: [Real] [Real] Real Real -> Real
rJurosSimples [] [] _ acumulador = acumulador
rJurosSimples [hpag:tpag] [hpes:tpes] juros acumulador = rJurosSimples tpag tpes juros (hpes / (1.0 + juros / 100.0 * hpag / periodo) + acumulador)

// função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo :: Real -> Real
jurosParaAcrescimo juros =
    let
        pesoTotal = getPesoTotal
    in
        if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0)
            0.0
            (
                let
                    acumulador = if composto
                        (rJurosCompostos pagamentos pesos juros 0.0)
                        (rJurosSimples pagamentos pesos juros 0.0)
                in
                    if (acumulador <= 0.0)
                        0.0
                        ((pesoTotal / acumulador - 1.0) * 100.0)
            )

// função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros :: Real Real Int Real Real Real -> Real
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros
	| iteracaoAtual == 0 || (maxJuros - minJuros) < minDiferenca = medJuros
	| jurosParaAcrescimo medJuros < acrescimo = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
	| otherwise = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

// função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros :: Real Int Int Real -> Real
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    let
        pesoTotal = getPesoTotal
    in
        if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0)
            0.0
            (rAcrescimoParaJuros acrescimo (0.1 ^ toReal precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0))

// calcula e guarda os resultados das funções
pesoTotal :: Real
pesoTotal = getPesoTotal
acrescimoCalculado :: Real
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado :: Real
jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0

// imprime os resultados
Start = "Peso total = " +++ toString pesoTotal
	+++ "\nAcréscimo = " +++ toString acrescimoCalculado
	+++ "\nJuros = " +++ toString jurosCalculado
