-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 27/06/2024: versão sem muito conhecimento de Idris
--        0.2: 08/08/2024: corrigidos comentários de versões
module Main

-- estrutura básica para simplificar as chamadas
quantidade : Int
quantidade = 3
composto : Bool
composto = True
periodo : Double
periodo = 30.0
pagamentos : List Double
pagamentos = [30.0, 60.0, 90.0]
pesos : List Double
pesos = [1.0, 1.0, 1.0]
pesoTotal : Double
acrescimoCalculado : Double
jurosCalculado : Double

-- função recursiva que realmente calcula a somatória de pesos[]
rGetPesoTotal : List Double -> Double
rGetPesoTotal [] = 0.0
rGetPesoTotal (h::t) = h + rGetPesoTotal t

-- perfume que calcula a somatória do array Pesos[]
getPesoTotal : Double
getPesoTotal = rGetPesoTotal pesos

-- calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos : List Double -> List Double -> Double -> Double
rJurosCompostos [] [] juros = 0.0
rJurosCompostos (paH::paT) (peH::peT) juros = peH / (pow (1.0 + juros / 100.0) (paH / periodo)) + rJurosCompostos paT peT juros

-- calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples : List Double -> List Double -> Double -> Double
rJurosSimples [] [] juros = 0.0
rJurosSimples (paH::paT) (peH::peT) juros = peH / (1.0 + juros / 100.0 * paH / periodo) + rJurosSimples paT peT juros

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo : Double ->  Double
jurosParaAcrescimo juros = if composto then (getPesoTotal / (rJurosCompostos pagamentos pesos juros) - 1.0) * 100.0
                     else (getPesoTotal / (rJurosSimples pagamentos pesos juros) - 1.0) * 100.0

-- função recursiva no lugar de um for que realmente calcula o acréscimo
rAcrescimoParaJuros : Double -> Double -> Int -> Double -> Double -> Double -> Double
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if (iteracaoAtual == 0) || ((maxJuros - minJuros) < minDiferenca) then medJuros
    else if jurosParaAcrescimo medJuros < acrescimo then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
         else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros : Double -> Int -> Int -> Double -> Double
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros = rAcrescimoParaJuros acrescimo (Prelude.pow 0.1 (cast precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- calcula e guarda o resultado das funções
pesoTotal = getPesoTotal
acrescimoCalculado = jurosParaAcrescimo 3.0
jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0

main : IO ()
main = do
    -- imprime os resultados
    putStr "Peso total = "
    putStrLn (show pesoTotal)
    putStr "Acrescimo = "
    putStrLn (show acrescimoCalculado)
    putStr "Juros = "
    putStrLn (show jurosCalculado)
