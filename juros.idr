-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 27/06/2024: versão sem muito conhecimento de Idris
--        0.2: 08/08/2024: corrigidos comentários de versões
--        0.3: 08/08/2026: solução escalabilizada e compatibilizada com Idris 1.3.4 e Idris 2
--        0.4: 13/08/2026: reescritas funções rGetPesoTotal, rJurosCompostos e rJurosSimples para terem Tail Call Optimizations
-- TESTES: os testes de benchmark foram realizados em um Debian 12 com 20 GB de memória RAM
--         as medidas foram feitas utilizando o comando: ulimit -s 65536
-- ATÉ VERSÃO 0.3: para Idris 1.3.4, o limite é de 292.570 parcelas, acima levanta o erro "Falha de segmentação"
-- APÓS VERSÃO 0.3: o limite para parcelas é 1.023.990 em Idris 1.3.4, por causa de TCO
--                  o limite para Idris 2 supera as 70.000.000 de parcelas, quando o sistema começa a ficar instável demais
module Main

-- estrutura básica para simplificar as chamadas
quantidade : Int
quantidade = 70_000_000  -- quantidade = 1023990  -- máximo para Idris 1.3.4
composto : Bool
composto = True
periodo : Double
periodo = 30.0
pagamentos : List Double
pesos : List Double
pesoTotal : Double
acrescimoCalculado : Double
jurosCalculado : Double

-- função recursiva que cria a lista Pagamentos
rGeraPagamentos : Int -> List Double
rGeraPagamentos indice = if indice < 1 then []
                         else (cast indice * periodo) :: rGeraPagamentos (indice - 1)

-- função açúcar que cria a lista Pagamentos
geraPagamentos : List Double
geraPagamentos = rGeraPagamentos(quantidade)

-- função recursiva que cria a lista Pesos
rGeraPesos : Int -> List Double
rGeraPesos indice = if indice < 1 then []
                    else 1.0 :: rGeraPesos (indice - 1)

-- função açúcar que cria a lista Pesos
geraPesos : List Double
geraPesos = rGeraPesos(quantidade)

-- atribui às listas Pagamentos e Pesos os resultados das geradoras de listas
pagamentos = geraPagamentos
pesos = geraPesos

-- função recursiva que realmente calcula a somatória de pesos[]
rGetPesoTotal : List Double -> Double -> Double
rGetPesoTotal [] acumulador = acumulador
rGetPesoTotal (h::t) acumulador = rGetPesoTotal t (acumulador + h)

-- açúcar que calcula a somatória do array Pesos[]
getPesoTotal : Double
getPesoTotal = rGetPesoTotal pesos 0.0

-- calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos : List Double -> List Double -> Double -> Double -> Double
rJurosCompostos [] (_ :: _) _ acumulador = acumulador
rJurosCompostos (_ :: _) [] _ acumulador = acumulador
rJurosCompostos [] [] _  acumulador = acumulador
rJurosCompostos (paH::paT) (peH::peT) juros acumulador = rJurosCompostos paT peT juros (acumulador + peH / (pow (1.0 + juros / 100.0) (paH / periodo)))
-- a versão abaixo também funciona, mas só em Idris 1
-- rJurosCompostos (paH::paT) (peH::peT) juros acumulador = rJurosCompostos paT peT juros (acumulador + peH / (Prelude.Doubles.pow (1.0 + juros / 100.0) (paH / periodo)))

-- calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples : List Double -> List Double -> Double -> Double -> Double
rJurosSimples [] (_ :: _) _ acumulador = acumulador
rJurosSimples (_ :: _) [] _ acumulador = acumulador
rJurosSimples [] [] _ acumulador = acumulador
rJurosSimples (paH::paT) (peH::peT) juros acumulador = rJurosSimples paT peT juros (acumulador + peH / (1.0 + juros / 100.0 * paH / periodo))

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo : Double ->  Double
jurosParaAcrescimo juros = if composto then (getPesoTotal / (rJurosCompostos pagamentos pesos juros 0.0) - 1.0) * 100.0
                                       else (getPesoTotal / (rJurosSimples pagamentos pesos juros 0.0) - 1.0) * 100.0

-- função recursiva no lugar de um for que realmente calcula o acréscimo
rAcrescimoParaJuros : Double -> Double -> Int -> Double -> Double -> Double -> Double
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if (iteracaoAtual == 0) || ((maxJuros - minJuros) < minDiferenca) then medJuros
    else if jurosParaAcrescimo medJuros < acrescimo then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
         else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros : Double -> Int -> Int -> Double -> Double
acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros = rAcrescimoParaJuros acrescimo (Prelude.pow 0.1 (cast precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)
-- as versões abaixo não rodam
-- acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros = rAcrescimoParaJuros acrescimo (Prelude.Doubles.pow 0.1 (cast precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)
-- acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros = rAcrescimoParaJuros acrescimo (pow 0.1 (cast precisao)) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

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
