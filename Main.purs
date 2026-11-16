-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 25/01/2025: versão feita sem muito conhecimento de PureScript
--        0.2: 15/11/2026: melhores comentários; listas escaláveis criadas dinamicamente; removidos casos especiais; avaliados variáveis, parâmetros e cálculos
--                         funções recursivas alteradas para permitir Tail Call Optimization (TCO)

-- INSTALAR: spago install numbers lists integers
-- COMPILAR: sudo npm install -g esbuild  &&  spago bundle --bundle-type app --platform node --minify --outfile juros.js  &&  node juros.js

module Main where  -- então, a solução, dessa vez, está em Main

import Prelude  -- fornece os fundamentos, como operadores
import Effect (Effect)  -- tipo de retorno da função main
import Effect.Class.Console (log)  -- para imprimir 
import Data.Number (pow)  -- para fazer exponenciação
import Data.Number.Format (toStringWith, fixed)  -- para formatar números para string com dígitos fixos
import Data.List ((:), List(..))  -- para declaração de listas e listas
import Data.Int (toNumber)  -- para converter pPrecisao de Int para Number

-- variáveis globais evitam excesso de parâmetros nas chamadas
quantidade :: Int
quantidade = 3
composto :: Boolean
composto = true
periodo :: Number
periodo = 30.0
pagamentos :: List Number
pagamentos = criaPagamentos
pesos :: List Number
pesos = criaPesos

-- função açúcar que cria a lista pagamentos
criaPagamentos :: List Number 
criaPagamentos = rCriaPagamentos 1 Nil

-- função recursiva que cria a lista pagamentos
rCriaPagamentos :: Int -> List Number -> List Number
rCriaPagamentos indice acumulador
  | indice > quantidade = acumulador
  | otherwise = rCriaPagamentos (indice + 1) ((toNumber indice) * periodo : acumulador)

-- função açúcar que cria a lista pagamentos
criaPesos :: List Number 
criaPesos = rCriaPesos 1 Nil

-- função recursiva que cria a lista pesos
rCriaPesos :: Int -> List Number -> List Number
rCriaPesos indice acumulador
  | indice > quantidade = acumulador
  | otherwise = rCriaPesos (indice + 1) (1.0 : acumulador)

-- função açúcar que calcula a somatória de pesos
getPesoTotal :: Number
getPesoTotal = rGetPesoTotal pesos 0.0

-- função recursiva que calcula a somatória de pesos
rGetPesoTotal :: List Number -> Number -> Number
rGetPesoTotal Nil acumulador = acumulador
rGetPesoTotal (hPes:tPes) acumulador = rGetPesoTotal tPes (hPes + acumulador)

-- função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo :: Number -> Number
jurosParaAcrescimo pJuros =
  if quantidade < 1 || periodo <= 0.0 || pJuros <= 0.0
  then 0.0
  else let
      pesoTotal = getPesoTotal
    in
      if pesoTotal <= 0.0
      then 0.0
      else let
        acumulador = if composto
        then rJurosCompostos pagamentos pesos pJuros 0.0
        else rJurosSimples pagamentos pesos pJuros 0.0
      in
        if acumulador <= 0.0
        then 0.0
        else (pesoTotal / acumulador - 1.0) * 100.0

-- função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
rJurosCompostos :: List Number -> List Number -> Number -> Number -> Number
rJurosCompostos _ Nil _ acumulador = acumulador
rJurosCompostos Nil _ _ acumulador = acumulador
rJurosCompostos (hPag:tPag) (hPes:tPes) pJuros acumulador = rJurosCompostos tPag tPes pJuros (hPes / pow (1.0 + pJuros / 100.0) (hPag / periodo) + acumulador)

-- função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
rJurosSimples :: List Number -> List Number -> Number -> Number -> Number
rJurosSimples _ Nil _ acumulador = acumulador
rJurosSimples Nil _ _ acumulador = acumulador
rJurosSimples (hPag:tPag) (hPes:tPes) pJuros acumulador = rJurosSimples tPag tPes pJuros (hPes / (1.0 + pJuros / 100.0 * hPag / periodo) + acumulador)

-- função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros :: Number -> Int -> Int -> Number -> Number
acrescimoParaJuros pAcrescimo pPrecisao pMaxIteracoes pMaxJuros =
  if quantidade < 1 || periodo <= 0.0 || pAcrescimo <= 0.0 || pPrecisao < 1 || pMaxIteracoes < 1 || pMaxJuros <= 0.0 || getPesoTotal <= 0.0
  then 0.0
  else rAcrescimoParaJuros pAcrescimo (pow 0.1 (toNumber pPrecisao)) pMaxIteracoes 0.0 pMaxJuros (pMaxJuros / 2.0)

-- função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros :: Number -> Number -> Int -> Number -> Number -> Number -> Number
rAcrescimoParaJuros pAcrescimo pMinDiferenca pIteracaoAtual pMinJuros pMaxJuros pMedJuros
  | pIteracaoAtual == 0 = pMedJuros
  | (pMaxJuros - pMinJuros) < pMinDiferenca = pMedJuros
  | jurosParaAcrescimo pMedJuros < pAcrescimo = rAcrescimoParaJuros pAcrescimo pMinDiferenca (pIteracaoAtual - 1) pMedJuros pMaxJuros ((pMedJuros + pMaxJuros) / 2.0)
  | otherwise = rAcrescimoParaJuros pAcrescimo pMinDiferenca (pIteracaoAtual - 1) pMinJuros pMedJuros ((pMinJuros + pMedJuros) / 2.0)

main :: Effect Unit
main = do
  -- calcula e guarda os resultados das funções principais
  let pesoTotal = getPesoTotal
  let acrescimoCalculado = jurosParaAcrescimo 3.0
  let jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0

  -- imprime os resultados
  log ("Peso total = " <> toStringWith (fixed 15) pesoTotal)
  log ("Acréscimo = " <> toStringWith (fixed 15) acrescimoCalculado)
  log ("Juros = " <> toStringWith (fixed 15) jurosCalculado)
