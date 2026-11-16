-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 04/05/2024: versão feita sem muito conhecimento de Haskell
--        0.2: 07/05/2024: corrigidos os putStr Juros e Acrescimo que estavam invertidos
--        0.3: 15/08/2024: adicionadas "assinaturas explícitas"
--        0.4: 15/08/2024: trocados tipos de "Float" para "Double"
--        0.5: 16/08/2024: trocado o código que calcula o peso total "à mão" por "sum"
--        0.6: 15/11/2026: variáveis para guardar cálculos separados de putStrs; removidos casos especiais; reabilitado rGetPesoTotal; melhorados comentários
--                         listas escaláveis criadas dinamicamente; validados variáveis, parâmetros e cálculos
--                         funções recursivas alteradas para permitir Tail Call Optimization (TCO)

-- COMPILAR COM: ghc -O2 juros.hs -o juros

import Data.List

-- estrutura básica para simplificar as chamadas
quantidade :: Int
quantidade = 3
composto :: Bool
composto = True
periodo :: Double
periodo = 30.0
pagamentos :: [Double]
pagamentos = criaPagamentos
pesos :: [Double]
pesos = criaPesos

-- função açúcar que cria a lista pagamentos
criaPagamentos :: [Double]
criaPagamentos = rCriaPagamentos quantidade []

-- função recursiva que cria a lista pagamentos
rCriaPagamentos :: Int -> [Double] -> [Double]
rCriaPagamentos indice acumulador
  | indice < 1 = acumulador
  | otherwise = rCriaPagamentos (indice - 1) (fromIntegral indice * periodo : acumulador)

-- função açúcar que cria a lista pesos
criaPesos :: [Double]
criaPesos = rCriaPesos quantidade []

-- função recursiva que cria a lista pesos
rCriaPesos :: Int -> [Double] -> [Double]
rCriaPesos indice acumulador
  | indice < 1 = acumulador
  | otherwise = rCriaPesos (indice - 1) (1.0 : acumulador)

-- função açúcar que calcula a somatória de pesos
getPesoTotal :: Double
getPesoTotal = rGetPesoTotal pesos 0.0
-- sum pesos

-- função recursiva que calcula a somatória de pesos
rGetPesoTotal :: [Double] -> Double -> Double
rGetPesoTotal [] acumulador = acumulador
rGetPesoTotal (hPes:tPes) acumulador = rGetPesoTotal tPes (hPes + acumulador)

-- função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo :: Double -> Double
jurosParaAcrescimo juros =
  let
    pesoTotal = getPesoTotal
  in
    if pesoTotal <= 0.0
      then 0.0
      else
        let acumulador = if composto
            then rJurosCompostos pagamentos pesos juros 0.0
            else rJurosSimples pagamentos pesos juros 0.0
        in
          if acumulador <= 0.0
            then 0.0
            else (pesoTotal / acumulador - 1.0) * 100.0

-- função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
rJurosCompostos :: [Double] -> [Double] -> Double -> Double -> Double
rJurosCompostos [] [] _ acumulador = acumulador
rJurosCompostos (pagH:pagT) (pesH:pesT) juros acumulador = rJurosCompostos pagT pesT juros (pesH / (1.0 + juros / 100.0) ** (pagH / periodo) + acumulador)

-- função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
rJurosSimples :: [Double] -> [Double] -> Double -> Double -> Double
rJurosSimples [] [] juros acumulador = acumulador
rJurosSimples (pagH:pagT) (pesH:pesT) juros acumulador = rJurosSimples pagT pesT juros (pesH / (1.0 + juros / 100.0 * pagH / periodo) + acumulador)

-- função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros :: Double -> Int -> Int -> Double -> Double
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros
  | quantidade < 1 || periodo <= 0.0 || getPesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 = 0.0
  | otherwise = rAcrescimoParaJuros acrescimo (0.1 ** fromIntegral precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros :: Double -> Double -> Int -> Double -> Double -> Double -> Double
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros
  | iteracaoAtual == 0 = medJuros
  | (maxJuros - minJuros) <= minDiferenca = medJuros
  | jurosParaAcrescimo medJuros < acrescimo = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
  | otherwise = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- testa as funções
main = do
  -- calcula e guarda os resultados das funções
  let pesoTotal = getPesoTotal
  let acrescimoCalculado = jurosParaAcrescimo 3.0
  let jurosCalculado =  acrescimoParaJuros acrescimoCalculado 15 65 50.0

  -- imprime os resultados
  putStr "Peso total = "
  putStrLn (show pesoTotal)
  putStr "Acrescimo = "
  putStrLn (show acrescimoCalculado)
  putStr "Juros = "
  putStrLn (show jurosCalculado)
