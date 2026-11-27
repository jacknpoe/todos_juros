/ Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
/ Versão: 0.1: 04/03/2026: feita sem muito conhecimento de q
/         0.2 (recursiva): 11/10/2026: agora com funções identadas corretamente e com medição de tempo
/         0.3: 26/11/2026: 16 casas decimais; valiados variáveis, parâmetros e cálculos; Composto: 1b; define elementos dos arrays; getPesoTotal
/ converter rGetPesoTotal, rJurosCompostos e rJurosSimples para permitir Tail Call Optimization (TCO) não alterou desempenho nem mudou o comportamento da pilha
/ ATENÇÃO: com 1937 parcelas, ou mais, estoura a pilha
/ EXECUTAR: q jurosq.q -q < /dev/null

\P 16  / 16 casas decimais

/ variáveis globais para simplificar as chamadas de função e inicialização
Quantidade: 3
Composto: 1b  / 1b = true; 0b = false
Periodo: 30.0
Pagamentos: Quantidade # 0.0
Pesos: Quantidade # 0.0

/ função recursiva que inicializa os elementosw do array Pagamentos
rDefinePagamentos: {
    [indice]
    $[
        indice < Quantidade;
        [
            Pagamentos[indice]: (indice + 1) * Periodo;
            rDefinePagamentos[indice + 1]
        ];
        ::
    ]
    }

/ função açúcar que inicializa os elementosw do array Pagamentos
definePagamentos: {
    rDefinePagamentos[0];
    }

/ função recursiva que inicializa os elementosw do array Pesos
rDefinePesos: {
    [indice]
    $[
        indice < Quantidade;
        [
            Pesos[indice]: 1.0;
            rDefinePesos[indice + 1]
        ];
        ::
    ]
    }

/ função açúcar que inicializa os elementosw do array Pagamentos
definePesos: {
    rDefinePesos[0];
    }

/ função recursiva que calcula a somatória dos elementos em Pesos
rGetPesoTotal: {
    [indice]
    $[
        indice < 0;
        0.0; 
        Pesos[indice] + rGetPesoTotal[indice - 1]
    ]
    }

/ função açúcar que calcula a somatória dos elementos em Pesos
getPesoTotal: {
    rGetPesoTotal[Quantidade - 1]
    }

/ função que acumula o total de amortizações para juros compostos (parte recursiva interna)
rJurosCompostos: {
    [indice; juros]
    $[
        indice < 0;
        0.0;
        (Pesos[indice] % ((1 + (juros % 100)) xexp (Pagamentos[indice] % Periodo))) + rJurosCompostos[indice - 1; juros]
    ]
    }

/ função que acumula o total de amortizações para juros simples (parte recursiva interna)
rJurosSimples: {
    [indice; juros]
    $[
        indice < 0;
        0.0;
        (Pesos[indice] % ((1 + ((juros % 100) * (Pagamentos[indice] % Periodo))))) + rJurosSimples[indice - 1; juros]
    ]
    }

/ função que calcula amortização
calculaAmortizacao: {
    [juros]
    $[
        Composto;
        rJurosCompostos[Quantidade - 1; juros];
        rJurosSimples[Quantidade - 1; juros]
    ]
 }

/ função que calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo: {
    [juros]
    pesoTotal: getPesoTotal[];
    $[
        (Quantidade = 0) | (Periodo <= 0.0) | (juros <= 0.0 | (pesoTotal <= 0.0));
        0.0;
        [
            acumulador: calculaAmortizacao[juros];
            $[
                acumulador <= 0.0;
                0.0;
                ((pesoTotal % acumulador) - 1.0) * 100.0
            ]
        ]
    ]
    }

/ função recursiva que calcula os juros a partir do acréscimo e parcelas
rAcrescimoParaJuros: {
    [acrescimo; iteracao; minDiferenca; minJuros; maxJuros; medJuros]
    $[
        (iteracao = 0) | ((maxJuros - minJuros) < minDiferenca);
        medJuros;
        $[
            jurosParaAcrescimo[medJuros] < acrescimo;
            rAcrescimoParaJuros[acrescimo; iteracao - 1; minDiferenca; medJuros; maxJuros; (medJuros + maxJuros) % 2];
            rAcrescimoParaJuros[acrescimo; iteracao - 1; minDiferenca; minJuros; medJuros; (minJuros + medJuros) % 2]
        ]
    ]
    }

/ função açúcar que calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros: {
    [acrescimo; precisao; maxIteracoes; maxJuros]
    $[
        (Quantidade = 0) | (Periodo <= 0.0) | (acrescimo <= 0.0) | (precisao < 1) | (maxIteracoes < 1) | (maxJuros <= 0.0 | (getPesoTotal[] <= 0.0));
        0.0;
        rAcrescimoParaJuros[acrescimo; maxIteracoes; 0.1 xexp precisao; 0.0; maxJuros; (maxJuros % 2.0)]
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
