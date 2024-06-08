-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 08/06/2024: versão feita sem muito conhecimento de Elm
module Juros.Juros exposing (main)

import Html exposing (pre, text)
import Array
-- import String

-- estrutura básica para simplificar as chamadas
quantidade = 3
composto = True
periodo = 30.0
pagamentos = Array.fromList [ 30.0, 60.0, 90.0 ]
pesos = Array.fromList [ 1.0, 1.0, 1.0 ]

-- função recursiva que realmente calcula a somatória de Pesos[]
rGetPesoTotal : Int -> Float
rGetPesoTotal indice =
    if indice == 0 then (Maybe.withDefault 0.0 (Array.get 0 pesos)) else (Maybe.withDefault 0.0 (Array.get indice pesos)) + rGetPesoTotal (indice-1)

-- perfume que calcula a somatória de Pesos[]
getPesoTotal : Float
getPesoTotal = 
    rGetPesoTotal (quantidade - 1)

-- função recursiva que calcula o amortecimento das parcelas em juros compostos
rJurosCompostos : Int -> Float -> Float
rJurosCompostos indice juros = 
    if indice == 0 then
        (Maybe.withDefault 0.0 (Array.get 0 pesos)) / (1.0 + juros / 100.0) ^ ((Maybe.withDefault 0.0 (Array.get 0 pagamentos)) / periodo)
    else
        (Maybe.withDefault 0.0 (Array.get indice pesos)) / (1.0 + juros / 100.0) ^ ((Maybe.withDefault 0.0 (Array.get indice pagamentos)) / periodo) + rJurosCompostos (indice-1) juros

-- função recursiva que calcula o amortecimento das parcelas em juros simples
rJurosSimples : Int -> Float -> Float
rJurosSimples indice juros = 
    if indice == 0 then
        (Maybe.withDefault 0.0 (Array.get 0 pesos)) / (1.0 + juros / 100.0 * (Maybe.withDefault 0.0 (Array.get 0 pagamentos)) / periodo)
    else
        (Maybe.withDefault 0.0 (Array.get indice pesos)) / (1.0 + juros / 100.0 * (Maybe.withDefault 0.0 (Array.get indice pagamentos)) / periodo) + rJurosSimples (indice-1) juros

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo : Float -> Float
jurosParaAcrescimo juros =
    if composto then (getPesoTotal / rJurosCompostos (quantidade - 1) juros - 1.0) * 100.0
    else (getPesoTotal / rJurosSimples (quantidade - 1) juros - 1.0) * 100.0

-- função recursiva no lugar de um for que realmente calcula os juros
rAcrescimoParaJuros : Float -> Float -> Int -> Float -> Float -> Float -> Float
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if iteracaoAtual == 0 || (maxJuros - minJuros) < minDiferenca then medJuros
    else if (jurosParaAcrescimo medJuros) < acrescimo
        then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
        else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros : Float -> Int -> Int -> Float -> Float
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    rAcrescimoParaJuros acrescimo (0.1 ^ toFloat(precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- potencia = base ^ expoente

-- calcula e guarda os retornos das funções
pesoTotal = getPesoTotal
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0

main =
    -- imprime o resultado
    pre []
    [ text("Peso total = " ++ (String.fromFloat pesoTotal) ++ "\n" ++
        "Acrescimo = " ++ (String.fromFloat acrescimoCalculado) ++ "\n" ++
        "Juros = " ++ (String.fromFloat jurosCalculado)) ]
