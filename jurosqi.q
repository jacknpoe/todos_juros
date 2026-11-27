/ Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
/ Versão: 0.1: 04/03/2026: feita sem muito conhecimento de q
/         0.2 (iterativa): 11/10/2026: agora com funções identadas corretamente e com medição de tempo, alteração para usar sum e while
/         0.3: 26/11/2026: 16 casas decimais; avaliado acumulador; Composto: 1b; define elementos dos arrays
/ VERSÃO 0.1: com 1937 parcelas, ou mais, estoura a pilha
/ VERSÃO 0.2 (iterativa): testada com pelo menos 300.000 parcelas (7,015 s)
/ EXECUTAR: q jurosqi.q -q < /dev/null

\P 16  / 16 casas decimais

/ variáveis globais para simplificar as chamadas de função e inicialização
Quantidade: 3
Composto: 1b  / 1b = true; 0b = false
Periodo: 30.0
Pagamentos: Quantidade # 0.0  / como está, [30.0 60.0 90.0]
Pesos: Quantidade # 0.0  / como está, [1.0 1.0 1.0]

/ função que inicializa os elementos do array Pagamentos
definePagamentos: {
    indice: 0;
    while[
        indice < Quantidade;
        Pagamentos[indice]: (indice + 1) * Periodo;
        indice +: 1
    ]
    }

/ função que inicializa os elementos do array Pesos
definePesos: {
    indice: 0;
    while[
        indice < Quantidade;
        Pesos[indice]: 1.0;
        indice +: 1
    ]
    }

/ função que calcula a somatória dos elementos em Pesos
getPesoTotal: {
    indice: count Pesos;
    acumulador: 0.0;
    while[
        indice > 0;
        indice -: 1;
        acumulador +: Pesos[indice]
    ];
    acumulador
    }

/ função que calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo: {
    [juros]
    pesoTotal: getPesoTotal[];
    $[
        (Quantidade = 0) | (Periodo <= 0.0) | (pesoTotal <= 0.0) | (juros <= 0.0);
        0.0;
        [
            indice: count Pesos;
            acumulador: 0.0;
            $[
                Composto;
                while[
                    indice > 0;
                    indice -: 1;
                    acumulador +: Pesos[indice] % ((1 + (juros % 100)) xexp (Pagamentos[indice] % Periodo))
                ];
                while[
                    indice > 0;
                    indice -: 1;
                    acumulador +: Pesos[indice] % (1 + ((juros % 100) * (Pagamentos[indice] % Periodo)))
                ]
            ];
            $[
                acumulador <= 0.0;
                0.0;
                ((pesoTotal % acumulador) - 1.0) * 100.0
            ]
        ]
    ]
    }

/ função que calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros: {
    [acrescimo; precisao; maxIteracoes; maxJuros]
    minJuros: 0.0;
    medJuros: maxJuros % 2;
    minDiferenca: 0.1 xexp precisao;
    pesoTotal: getPesoTotal[];
    $[
        (Quantidade = 0) | (Periodo <= 0.0) | (pesoTotal <= 0.0) | (acrescimo <= 0.0) | (precisao < 1) | (maxIteracoes < 1) | (maxJuros <= 0.0);
        0.0;
        [
            while[
                (maxIteracoes > 0) and ((maxJuros - minJuros) > minDiferenca);
                maxIteracoes -: 1;
                $[
                    jurosParaAcrescimo[medJuros] < acrescimo;
                    minJuros: medJuros;
                    maxJuros: medJuros
                ];
                medJuros: (minJuros + maxJuros) % 2
            ];
            medJuros
        ]
    ]
    }

/ executa código aqui, para poder ser medido por \t
executa: {
    / inicializa os arrays
    definePagamentos[];
    definePesos[];

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
