// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 13/04/2026: feita sem muito conhecicmento de JADE

#include <jade.hpp>
#include <math.h>
#include <iomanip>
#include <sstream>

// algumas constantes para deixar o estilo um pouco mais coerente
#define POW pow
#define DOUBLE double
#define BOOL bool

// essa função é extremamente C++, mas é porque PRINT só imprime 5 casas, e não encontrei como resolver isso
SUB IMPRIME(STRING legenda, DOUBLE valor) DO
    std::ostringstream temp;
    temp << std::fixed << std::setprecision(15) << valor;
    PRINT(legenda, temp.str());
END

// variáveis globais, para simplificar as chamadas às funções e incializa escalares
INTEGER Quantidade = 3;
BOOL Composto = TRUE;
DOUBLE Periodo = 30.0;
ARRAY <DOUBLE> Pagamentos(Quantidade);
ARRAY <DOUBLE> Pesos(Quantidade);

// calcula a somatória dos elementos do array Pèsos[]
FUNCTION DOUBLE getPesoTotal() DO
    VAR acumulador = 0.0;

    FOR(VAR indice IN RANGE(0, Quantidade)) DO
        acumulador += Pesos[indice];
    NEXT

    RETURN acumulador;
END

// calcula o acréscimo a partir dos juros e parcelas
FUNCTION DOUBLE jurosParaAcrescimo(DOUBLE juros) DO
    VAR pesoTotal = getPesoTotal();
    IF (Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0) THEN RETURN 0.0; END
    VAR acumulador = 0.0;

    FOR(VAR indice IN RANGE(0, Quantidade)) DO
        IF (Composto) THEN
            acumulador += Pesos[indice] / POW(1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
        ELSE
            acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        END
    NEXT

    IF (acumulador <= 0.0) THEN RETURN 0.0; END
    RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END

// calcula os juros a partir do acréscimo e parcelas
FUNCTION DOUBLE acrescimoParaJuros(DOUBLE acrescimo, INTEGER precisao, INTEGER maxIteracoes, DOUBLE maxJuros) DO
    VAR pesoTotal = getPesoTotal();
    IF (Quantidade < 1 OR Periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0) THEN RETURN 0.0; END
    VAR minJuros = 0.0, medJuros = maxJuros / 2.0, minDiferenca = POW(0.1, precisao);

    FOR(VAR iteracao IN RANGE(0, maxIteracoes)) DO
        IF (maxJuros - minJuros < minDiferenca) THEN RETURN medJuros; END
        IF (jurosParaAcrescimo(medJuros) < acrescimo) THEN minJuros = medJuros; ELSE maxJuros = medJuros; END
        medJuros = (minJuros + maxJuros) / 2.0;
    NEXT

    RETURN medJuros;
END

// função principal
MAIN
    // inicializa os elementos dos arrays Pagamentos[] e Pesos[]
    FOR(VAR indice IN RANGE(0, Quantidade)) DO
        Pagamentos[indice] = (indice + 1) * Periodo;
        Pesos[indice] = 1.0;
    NEXT

    // calcula e guarda os resultados das funções
    VAR pesoTotal = getPesoTotal();
    VAR acrescimoCalculado = jurosParaAcrescimo(3.0);
    VAR jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);

    // imprime os resultados
    IMPRIME("Peso total = ", pesoTotal);
    IMPRIME("Acréscimo = ", acrescimoCalculado);
    IMPRIME("Juros = ", jurosCalculado);
END
