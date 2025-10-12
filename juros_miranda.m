|| Cálculo dos juros, sendo que precisa de parcelas para isso
|| Versão 0.1: 21/06/2024: versão feita sem muito conhecimento de Miranda

|| estrutura básica de propriedades para simplificar as camadas
quantidade = 3
composto = True
periodo = 30.0
pagamentos = [30.0, 60.0, 90.0]
pesos = [1.0, 1.0, 1.0]

|| função recursiva que realmente calcula a somatória de Pesos[]
rGetPesoTotal 0 = pesos!0
rGetPesoTotal indice = pesos!indice + rGetPesoTotal (indice - 1)

|| perfume que calcula a somatória de Pesos[]
getPesoTotal () = rGetPesoTotal (quantidade - 1)

|| função recursiva que calcula o amortecimento das parcelas em juros compostos
rJurosCompostos (0, juros) = (pesos!0) / (1.0 + juros / 100.0) ^ ((pagamentos!0) / periodo)
rJurosCompostos (indice, juros) = (pesos!indice) / (1.0 + juros / 100.0) ^ ((pagamentos!indice) / periodo) + rJurosCompostos (indice - 1, juros)

|| função recursiva que calcula o amortecimento das parcelas em juros simples
rJurosSimples (0, juros) = (pesos!0) / (1.0 + juros / 100.0 * (pagamentos!0) / periodo)
rJurosSimples (indice, juros) = (pesos!indice) / (1.0 + juros / 100.0 * (pagamentos!indice) / periodo) + rJurosSimples (indice - 1, juros)

|| calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo juros = (getPesoTotal() / rJurosCompostos(quantidade - 1, juros) - 1.0) * 100.0, if composto
                         = (getPesoTotal() / rJurosSimples(quantidade - 1, juros) - 1.0) * 100.0, if ~ composto

|| função recursiva no lugar de um for que realmente calcula os juros
rAcrescimoParaJuros (acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros)
    = medJuros, if iteracaoAtual = 0
    = medJuros, if (maxJuros - minJuros) < minDiferenca
    = rAcrescimoParaJuros (acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0), if jurosParaAcrescimo (medJuros) < acrescimo
    = rAcrescimoParaJuros (acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0), if jurosParaAcrescimo (medJuros) >= acrescimo

|| calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros (acrescimo, precisao, maxIteracoes, maxJuros) =
    rAcrescimoParaJuros (acrescimo, 0.1 ^ precisao, maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

|| calcula os resultados das funções e imprime
main :: [sys_message]
main = [ Stdout ( "Peso total = " ++ (show (getPesoTotal())) ++
                  "\nAcréscimo = " ++ (show (jurosParaAcrescimo (3.0))) ++
                  "\nJuros = " ++ (show (acrescimoParaJuros (jurosParaAcrescimo (3.0), 15, 100, 50.0)))) ]
