-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 25/01/2025: versão feita sem muito conhecimento de PureScript

module Test.Main where  -- então, a solução está em forma de teste

import Prelude  -- eu, até agora, não sei para que serve Prelude

import Effect (Effect)  -- tipo de retorno da função main
import Effect.Class.Console (log)  -- para imprimir 
import Data.Number (pow)  -- para fazer exponenciação
import Data.Number.Format (toStringWith, fixed)  -- para formatar números para string com dígitos fixos
import Data.List ((:), List(..), tail, head)  -- para declaração de listas, listas e operações de cabeça e cauda 
import Data.Maybe (isNothing, fromMaybe)  -- para usar Nothing (cauda vazia) e converter de Maybe para Number
import Data.Int (toNumber)  -- para converter pPrecisao de Int para Number

-- variáveis globais evitam excesso de parâmetros nas chamadas
composto :: Boolean
composto = true
periodo :: Number
periodo = 30.0
pagamentos :: List Number
pagamentos = 30.0 : 60.0 : 90.0 : Nil
pesos :: List Number
pesos = 1.0 : 1.0 : 1.0 : Nil

-- calcula a somatória de Pesos[]
getPesoTotal :: Number
getPesoTotal = rGetPesoTotal pesos

-- função recursiva que realmente calcula a somatória de pesos[]
rGetPesoTotal :: List Number -> Number
rGetPesoTotal pPesos
  | isNothing (tail pPesos) = fromMaybe 0.0 (head pPesos)
  | otherwise = fromMaybe 0.0 (head pPesos) + rGetPesoTotal (fromMaybe (0.0 : Nil) (tail pPesos))

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo :: Number -> Number
jurosParaAcrescimo pJuros
  | composto = (getPesoTotal / (rJurosCompostos pagamentos pesos pJuros) - 1.0) * 100.0
  | otherwise = (getPesoTotal / (rJurosSimples pagamentos pesos pJuros) - 1.0) * 100.0

-- calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos :: List Number -> List Number -> Number -> Number
rJurosCompostos pPagamentos pPesos pJuros
  | isNothing (tail pPesos) = (fromMaybe 0.0 (head pPesos)) / pow (1.0 + pJuros / 100.0) ((fromMaybe 0.0 (head pPagamentos)) / periodo)
  | otherwise = (fromMaybe 0.0 (head pPesos)) / pow (1.0 + pJuros / 100.0) ((fromMaybe 0.0 (head pPagamentos)) / periodo) + rJurosCompostos (fromMaybe (0.0 : Nil) (tail pPagamentos)) (fromMaybe (0.0 : Nil) (tail pPesos)) pJuros

-- calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples :: List Number -> List Number -> Number -> Number
rJurosSimples pPagamentos pPesos pJuros
  | isNothing (tail pPesos) = (fromMaybe 0.0 (head pPesos)) / (1.0 + pJuros / 100.0 * (fromMaybe 0.0 (head pPagamentos)) / periodo)
  | otherwise = (fromMaybe 0.0 (head pPesos)) / (1.0 + pJuros / 100.0 * (fromMaybe 0.0 (head pPagamentos)) / periodo) + rJurosSimples (fromMaybe (0.0 : Nil) (tail pPagamentos)) (fromMaybe (0.0 : Nil) (tail pPesos)) pJuros

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros :: Number -> Int -> Int -> Number -> Number
acrescimoParaJuros pAcrescimo pPrecisao pMaxIteracoes pMaxJuros =
  rAcrescimoParaJuros pAcrescimo (pow 0.1 (toNumber pPrecisao)) pMaxIteracoes 0.0 pMaxJuros (pMaxJuros / 2.0)

-- função recursiva no lugar de um for que realmente calcula o acréscimo
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
  let jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0

  -- imprime os resultados
  log ("Peso total = " <> toStringWith (fixed 15) pesoTotal)
  log ("Acréscimo = " <> toStringWith (fixed 15) acrescimoCalculado)
  log ("Juros = " <> toStringWith (fixed 15) jurosCalculado)