-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 08/06/2024: versão feita sem muito conhecimento de Elm
--             10/11/2026: melhorados comentários; arrays escaláveis criados dinamicamente; colocados tipos; alterado de 0.19.1 para 0.19.3; acento em "Acréscimo"
--                         retirados casos especiais; validados variáveis, parâmetros e cálculos; recursivas alteradas para permitir Tail Call Optimization (TCO)

module Juros.Juros exposing (main)

import Html exposing (pre, text)
import Array
-- import Time

-- variáveis escalares globais para simplificar as chamadas
quantidade : Int
quantidade = 3
composto : Bool
composto = True
periodo : Float
periodo = 30.0

-- função recursiva que cria o array Pagamentos[]
rCriaPagamentos : Int -> Array.Array Float -> Array.Array Float
rCriaPagamentos indice acumulador=
    if indice > quantidade
    then acumulador
    else rCriaPagamentos (indice + 1) (Array.push (toFloat indice * periodo) acumulador)

-- função açúcar que cria o array Pagamentos[]
criaPagamentos : Array.Array Float
criaPagamentos = rCriaPagamentos 1 Array.empty

-- função recursiva que cria o array Pesos[]
rCriaPesos : Int -> Array.Array Float -> Array.Array Float
rCriaPesos indice acumulador =
    if indice > quantidade
    then acumulador
    else rCriaPesos (indice + 1) (Array.push 1.0 acumulador)

-- função açúcar que cria o array Pesos[]
criaPesos : Array.Array Float
criaPesos = rCriaPesos 1  Array.empty

-- arrays globais para simplificar as chamadas
pagamentos : Array.Array Float
pagamentos = criaPagamentos
pesos : Array.Array Float
pesos = criaPesos

-- função recursiva que calcula a somatória de Pesos[]
rGetPesoTotal : Int -> Float -> Float
rGetPesoTotal indice acumulador =
    if indice < 0
    then acumulador
    else rGetPesoTotal (indice - 1) ((Maybe.withDefault 0.0 (Array.get indice pesos)) + acumulador)

-- função açúcar que calcula a somatória de Pesos[]
getPesoTotal : Float
getPesoTotal = rGetPesoTotal (quantidade - 1) 0.0

-- função recursiva que calcula o amortecimento das parcelas em juros compostos
rJurosCompostos : Int -> Float -> Float -> Float
rJurosCompostos indice juros acumulador = 
    if indice < 0
    then acumulador
    else rJurosCompostos (indice - 1) juros
        ((Maybe.withDefault 0.0 (Array.get indice pesos)) / (1.0 + juros / 100.0) ^ ((Maybe.withDefault 0.0 (Array.get indice pagamentos)) / periodo) + acumulador)

-- função recursiva que calcula o amortecimento das parcelas em juros simples
rJurosSimples : Int -> Float -> Float -> Float
rJurosSimples indice juros acumulador =
    if indice < 0
    then acumulador
    else rJurosSimples (indice - 1) juros
        ((Maybe.withDefault 0.0 (Array.get indice pesos)) / (1.0 + juros / 100.0 * (Maybe.withDefault 0.0 (Array.get indice pagamentos)) / periodo) + acumulador)

-- função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo : Float -> Float
jurosParaAcrescimo juros =
    let
        lPesoTotal : Float
        lPesoTotal = getPesoTotal
    in
        if quantidade < 1 || periodo <= 0.0 || lPesoTotal <= 0.0 || juros <= 0.0
        then 0.0
        else
            let
                acumulador : Float
                acumulador = if composto
                             then rJurosCompostos (quantidade - 1) juros 0.0
                             else rJurosSimples (quantidade - 1) juros 0.0
            in
                if acumulador <= 0.0
                then 0.0
                else (lPesoTotal / acumulador - 1.0) * 100.0

-- função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros : Float -> Float -> Int -> Float -> Float -> Float -> Float
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if iteracaoAtual == 0 || (maxJuros - minJuros) < minDiferenca
    then medJuros
    else if (jurosParaAcrescimo medJuros) < acrescimo
         then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
         else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros : Float -> Int -> Int -> Float -> Float
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    let
        lPesoTotal : Float
        lPesoTotal = getPesoTotal
    in
        if quantidade < 1 || periodo <= 0.0 || lPesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0
        then 0.0
        else rAcrescimoParaJuros acrescimo (0.1 ^ toFloat(precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- calcula e guarda os retornos das funções
pesoTotal : Float
pesoTotal = getPesoTotal
acrescimoCalculado : Float
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado : Float
jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0

-- imprime o resultado
main : Html.Html msg
main =
    pre []
    [ text( "Peso total = " ++ (String.fromFloat pesoTotal) ++ "\n" ++
            "Acréscimo = " ++ (String.fromFloat acrescimoCalculado) ++ "\n" ++
            "Juros = " ++ (String.fromFloat jurosCalculado) ++ "\n" )
    ]
