|| Cálculo dos juros, sendo que precisa de parcelas para isso
|| Versão 0.1: 21/06/2024: versão feita sem muito conhecimento de Miranda
||        0.2: 08/11/2026: retirados casos especiais; melhorados comentários; validados variáveis, parâmetros e cálculos; arrays escaláveis criados dinamicamente
||                         funções recursivas agora permitem Tail Call Optimization (TCO); usado head e tail no lugar de indice

|| variáveis escalares globais para simplificar as chamadas
quantidade = 300000
composto = True
periodo = 30.0

|| função recursiva que gera o array Pagamentos[]
rGeraPagamentos indice acumulador
    = acumulador, if indice > quantidade
    = rGeraPagamentos (indice + 1) ((indice * periodo) : acumulador), otherwise

|| função açúcar que gera o array Pagamentos[]
geraPagamentos = rGeraPagamentos 1 []

|| função recursiva que gera o array Pesos[]
rGeraPesos indice acumulador
    = acumulador, if indice > quantidade
    = rGeraPesos (indice + 1) (1.0 : acumulador), otherwise

|| função açúcar que gera o array Pesos[]
geraPesos = rGeraPesos 1 []

|| arrays globais para simplificar as chamadas
pagamentos = geraPagamentos
pesos = geraPesos

|| função recursiva que calcula a somatória de Pesos[]
rGetPesoTotal [] acumulador = acumulador
rGetPesoTotal (hpes:tpes) acumulador = rGetPesoTotal tpes (hpes + acumulador), otherwise

|| função açúcar que calcula a somatória de Pesos[]
getPesoTotal = rGetPesoTotal pesos 0.0

|| função recursiva que calcula a amortização das parcelas em juros compostos
rJurosCompostos [] [] juros acumulador = acumulador
rJurosCompostos (hpag:tpag) (hpes:tpes) juros acumulador
    = rJurosCompostos tpag tpes juros acumulador, if fixo > 93
    = rJurosCompostos tpag tpes juros (hpes / (exp fixo) + acumulador), otherwise
      where
      base = 1.0 + juros / 100.0
      expoente = hpag / periodo
      fixo = expoente * log base

|| função recursiva que calcula a amortização das parcelas em juros simples
rJurosSimples [] [] juros acumulador = acumulador
rJurosSimples (hpag:tpag) (hpes:tpes) juros acumulador
    = rJurosSimples tpag tpes juros (hpes / (1.0 + juros / 100.0 * hpag / periodo) + acumulador), otherwise

|| função que calcula a amortização das parcelas, considerando `composto`
calculaAmortizacao juros
    = rJurosCompostos pagamentos pesos juros 0.0, if composto
    = rJurosSimples pagamentos pesos juros 0.0, otherwise

|| segunda função que calcula os resultados de juros para acréscimo, zerando se acumulador <= 0.0
calculaJurosParaAcrescimo2 pesoTotal acumulador
    = 0.0, if acumulador <= 0.0
    = (pesoTotal / acumulador - 1.0) * 100.0, otherwise

|| primeira função que calcula os resultados de juros para acréscimo, zerando se pesoTotal <= 0.0
calculaJurosParaAcrescimo1 pesoTotal juros
    = 0.0, if pesoTotal <= 0.0
    = calculaJurosParaAcrescimo2 pesoTotal (calculaAmortizacao juros), otherwise

|| função açúcar que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo juros
    = 0.0, if quantidade < 1
    = 0.0, if periodo <= 0.0
    = 0.0, if juros <= 0.0
    = calculaJurosParaAcrescimo1 getPesoTotal juros, otherwise

|| função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros
    = medJuros, if iteracaoAtual = 0
    = medJuros, if (maxJuros - minJuros) < minDiferenca
    = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0), if jurosParaAcrescimo (medJuros) < acrescimo
    = rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0), otherwise

|| função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros  acrescimo  precisao  maxIteracoes  maxJuros
    = 0.0, if quantidade < 1
    = 0.0, if periodo <= 0.0
    = 0.0, if acrescimo <= 0.0
    = 0.0, if precisao < 1
    = 0.0, if maxIteracoes < 1
    = 0.0, if maxJuros <= 0.0
    = 0.0, if getPesoTotal <= 0.0
    = rAcrescimoParaJuros acrescimo (0.1 ^ precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0), otherwise

|| calcula os resultados das funções e imprime
main :: [sys_message]
main = [ Stdout ( "Peso total = " ++ (show pesoTotal) ++
                "\nAcréscimo = " ++ (show acrescimoCalculado) ++
                "\nJuros = " ++ (show jurosCalculado)) ]
       where
       pesoTotal = getPesoTotal
       acrescimoCalculado = jurosParaAcrescimo 3.0
       jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0
