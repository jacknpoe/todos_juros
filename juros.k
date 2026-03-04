/ Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
/ Versão: 0.1: 04/03/2026: feita sem muito conhecimento de K

/ variáveis globais para simplificar as chamadas de função e inicialização
Quantidade: 3
Composto: 1  / true
Periodo: 30.0
Pagamentos: (1 + !Quantidade) * Periodo
Pesos: Quantidade # 1.0

/ calcula a somatória dos elementos em Pesos (parte recursiva interna)
rGetPesoTotal: { [indice]
    if[indice < 0; :0.0];
    :(Pesos@indice) + rGetPesoTotal[indice - 1]
}

/ calcula a somatória dos elementos em Pesos (açúcar)
getPesoTotal: {
    :rGetPesoTotal[Quantidade - 1]
}

/ acumula o total de amortecimentos para juros compostos (parte recursiva interna)
rJurosCompostos: { [indice; juros]
    if[indice < 0; :0.0];
    :((Pesos@indice) % ((1 + (juros % 100)) ^ ((Pagamentos@indice) % Periodo))) + rJurosCompostos[indice - 1; juros]
}

/ acumula o total de amortecimentos para juros simples (parte recursiva interna)
rJurosSimples: { [indice; juros]
    if[indice < 0; :0.0]
    :((Pesos@indice) % ((1 + ((juros % 100) * ((Pagamentos@indice) % Periodo))))) + rJurosSimples[indice - 1; juros]
}

/ calcula o acréscimo a partir dos juros e parcelas (é um pouco açúcar)
jurosParaAcrescimo: { [juros]
    if[ Composto = 1; :((getPesoTotal[] % rJurosCompostos[Quantidade - 1; juros]) - 1.0) * 100.0];
    :((getPesoTotal[] % rJurosSimples[Quantidade - 1; juros]) - 1.0) * 100.0
}

/ calcula os juros a partir do acréscimo e parcelas (parte recursiva interna)
rAcrescimoParaJuros: { [acrescimo; iteracao; minDiferenca; minJuros; maxJuros; medJuros]
    if[ (iteracao = 0) | ((maxJuros - minJuros) < minDiferenca); :medJuros];
    if[ jurosParaAcrescimo[medJuros] < acrescimo; :rAcrescimoParaJuros[acrescimo; iteracao - 1; minDiferenca; medJuros; maxJuros; (medJuros + maxJuros) % 2]];
    :rAcrescimoParaJuros[acrescimo; iteracao - 1; minDiferenca; minJuros; medJuros; (minJuros + medJuros) % 2]
}

/ calcula os juros a partir do acréscimo e parcelas (açúcar)
acrescimoParaJuros: { [acrescimo; precisao; maxIteracoes; maxJuros]
    :rAcrescimoParaJuros[acrescimo; maxIteracoes; 0.1 ^ precisao; 0.0; maxJuros; (maxJuros % 2.0)]
}

/ calcula e guarda os resultados das funções
pesoTotal: getPesoTotal[]
acrescimoCalculado: jurosParaAcrescimo[3.0]
jurosCalculado: acrescimoParaJuros[acrescimoCalculado; 15; 65; 50.0]

/ imprime os resultados
"Peso total = ", $pesoTotal
"Acrescimo = ", $acrescimoCalculado
"Juros = ", $jurosCalculado

\\
