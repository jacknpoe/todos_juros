-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 02/06/2026: feita sem muito conhecimento de Curry KICS2

import Numeric

-- variáveis globais esclarares com inicialização para simplificar as chamadas às funções
quantidade :: Int
quantidade = 3
composto :: Bool
composto = True
periodo :: Float
periodo = 30.0

-- recursão que gera uma lista para pagamentos
rGeraPagamentos :: Int -> [Float]
rGeraPagamentos indice = if indice <= 0 then [] else ((toFloat indice) * periodo) : rGeraPagamentos (indice - 1)

-- açúcar que gera uma lista para pagamentos
geraPagamentos :: [Float]
geraPagamentos = rGeraPagamentos quantidade

-- recursão que gera uma lista para pesos
rGeraPesos :: Int -> [Float]
rGeraPesos indice = if indice <= 0 then [] else 1.0 : rGeraPesos (indice - 1)

-- açúcar que gera uma lista para pesos
geraPesos :: [Float]
geraPesos = rGeraPesos quantidade

-- listas globais com inicialização para simplificar as chamadas às funções
pagamentos :: [Float]
pagamentos = geraPagamentos
pesos :: [Float]
pesos = geraPesos

-- recursão que calcula a somatória de pesos
rGetPesoTotal :: [Float] -> Float
rGetPesoTotal [] = 0.0
rGetPesoTotal (hPes:tPes) = hPes + rGetPesoTotal tPes

-- açúcar que calcula a somatória de pesos
getPesoTotal :: Float
getPesoTotal = rGetPesoTotal pesos

-- recursão que calcula a somatória da amortização dos juros compostos
rJurosCompostos :: [Float] -> [Float] -> Float -> Float
rJurosCompostos [] [] _ = 0.0
rJurosCompostos [] (_:_) _ = 0.0
rJurosCompostos (_:_) [] _ = 0.0
rJurosCompostos (hPag:tPag) (hPes:tPes) juros = hPes / (1.00 + juros / 100.0) ** (hPag / periodo) + rJurosCompostos tPag tPes juros

-- recursão que calcula a somatória da amortização dos juros simples
rJurosSimples :: [Float] -> [Float] -> Float -> Float
rJurosSimples [] [] _ = 0.0
rJurosSimples [] (_:_) _ = 0.0
rJurosSimples (_:_) [] _ = 0.0
rJurosSimples (hPag:tPag) (hPes:tPes) juros = hPes / (1.00 + juros / 100.0 * hPag / periodo) + rJurosSimples tPag tPes juros

-- calcula o acréscimo a partir dos juros e parcelas (com algum açúcar)
jurosParaAcrescimo :: Float -> Float
jurosParaAcrescimo juros = if composto then (getPesoTotal / rJurosCompostos pagamentos pesos juros - 1.0) * 100.0
                                       else (getPesoTotal / rJurosSimples pagamentos pesos juros - 1.0) * 100.0

-- recursão que calcula os juros a partir do acréscimo e parcelas
rAcrescimoParaJuros :: Float -> Float -> Int -> Float -> Float -> Float -> Float
rAcrescimoParaJuros acrescimo minDiferenca iteracao minJuros maxJuros medJuros =
    if (iteracao <= 0) || (maxJuros - minJuros < minDiferenca) then medJuros
        else if jurosParaAcrescimo medJuros < acrescimo
            then rAcrescimoParaJuros acrescimo minDiferenca (iteracao - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
            else rAcrescimoParaJuros acrescimo minDiferenca (iteracao - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- açúcar que calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros :: Float -> Int -> Int -> Float -> Float
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    rAcrescimoParaJuros acrescimo (0.1 ** (toFloat precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

-- execute main no REPL de KICS2
main :: IO ()
main = do
    -- calcula e guarda os resultados das funções
    let pesoTotal = getPesoTotal
    let acrescimoCalculado = jurosParaAcrescimo 3.0
    let jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0

    -- imprime os resultados
    putStr "Peso total = "
    putStrLn (show pesoTotal)
    putStr "Acréscimo = "
    putStrLn (show acrescimoCalculado)
    putStr "Juros = "
    putStrLn (show jurosCalculado)
