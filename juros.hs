-- Cálculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 04/05/2024: versão feita sem muito conhecimento de Haskell
--        0.2: 07/05/2024: corrigidos os putStr Juros e Acrescimo, que estavam invertidos
import Data.List

-- estrutura básica para simplificar as chamadas
composto = True
periodo = 30.0
pagamentos = [30.0, 60.0, 90.0]
pesos = [1.0, 1.0, 1.0]

-- calcula a somatória de Pesos[]
getPesoTotal =
   rGetPesoTotal pesos

-- função recursiva que realmente calcula a somatória de pesos[]
rGetPesoTotal (h:t)
   | t == [] = h
   | otherwise = h + rGetPesoTotal t

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo juros
  | composto = (getPesoTotal / (rJurosCompostos pagamentos pesos juros) - 1.0) * 100.0
  | otherwise = (getPesoTotal / (rJurosSimples pagamentos pesos juros) - 1.0) * 100.0

-- calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos (pagH:pagT) (pesH:pesT) juros
  | pesT == [] = pesH / (1.0 + juros / 100.0) ** (pagH / periodo)
  | otherwise = pesH / (1.0 + juros / 100.0) ** (pagH / periodo) + rJurosCompostos pagT pesT juros

-- calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples (pagH:pagT) (pesH:pesT) juros
  | pesT == [] = pesH / (1.0 + juros / 100.0 * pagH / periodo)
  | otherwise = pesH / (1.0 + juros / 100.0 * pagH / periodo) + rJurosSimples pagT pesT juros

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
  rAcrescimoParaJuros acrescimo (0.1 ** precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- função recursiva no lugar de um for que realmente calcula o acréscimo
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros
  | iteracaoAtual == 0 = medJuros
  | (maxJuros - minJuros) < minDiferenca = medJuros
  | jurosParaAcrescimo medJuros < acrescimo = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
  | otherwise = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- testa as funções
main = do
  putStr "Peso total = "
  putStrLn (show(getPesoTotal))
  putStr "Acrescimo = "
  putStrLn (show(jurosParaAcrescimo 3.0))
  putStr "Juros = "
  putStrLn (show( acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 100 50.0))  