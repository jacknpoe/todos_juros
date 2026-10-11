/ Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
/ Versão: 0.1: 04/03/2026: feita sem muito conhecimento de q
/         0.2 (iterativa): 11/10/2026: agora com funções identadas corretamente e com medição de tempo, alteração para usar sum e while
/ VERSÃO 0.1: com 1937 parcelas, ou mais, estoura a pilha
/ VERSÃO 0.2 (iterativa): testada com pelo menos 300.000 parcelas (7,015 s)

\P 0  / todas as casas decimais válidas

/ variáveis globais para simplificar as chamadas de função e inicialização
Quantidade: 3
Composto: 1  / trze
Periodo: 30.0
Pagamentos: (1 + til Quantidade) * Periodo  / como está, [30.0 60.0 90.0]
Pesos: Quantidade # 1.0  / como está, [1.0 1.0 1.0]

/ calcula a somatória dos elementos em Pesos
getPesoTotal: {
    sum Pesos
    }

/ calcula o acréscimo a partir dos juros e parcelas (é um pouco açúcar)
jurosParaAcrescimo: {
    [juros]
    indice: count Pesos;
    acumulador: 0.0;
    $[
        Composto = 1;
        while[
            indice > 0;
            indice-:1;
            acumulador+: Pesos[indice] % ((1 + (juros % 100)) xexp (Pagamentos[indice] % Periodo))
        ];
        while[
            indice > 0;
            indice-:1;
            acumulador+: Pesos[indice] % (1 + ((juros % 100) * (Pagamentos[indice] % Periodo)))
        ]
    ];
    ((getPesoTotal[] % acumulador) - 1.0) * 100.0
    }

/ calcula os juros a partir do acréscimo e parcelas (açúcar)
acrescimoParaJuros: {
    [acrescimo; precisao; maxIteracoes; maxJuros]
    minJuros: 0.0;
    medJuros: maxJuros % 2;
    minDiferenca: 0.1 xexp precisao;
    while[
        (maxIteracoes > 0) and ((maxJuros - minJuros) > minDiferenca);
        maxIteracoes-:1;
        $[
            jurosParaAcrescimo[medJuros] < acrescimo;
            minJuros: medJuros;
            maxJuros: medJuros
        ];
        medJuros:(minJuros + maxJuros) % 2
    ];
    medJuros
    }

/ executa código aqui, para poder ser medido por \t
executa: {
    / calcula e guarda os retornos das funções
    pesoTotal: getPesoTotal[];
    acrescimoCalculado: jurosParaAcrescimo[3.0];
    jurosCalculado: acrescimoParaJuros[acrescimoCalculado; 15; 65; 50.0];

    / imprime os resultados
    show "Peso total = ", string pesoTotal;
    show "Acrescimo = ", string acrescimoCalculado;
    show "Juros = ", string jurosCalculado
    }

/ mostra o tempo que leva para executar executa[]
\t executa[]
