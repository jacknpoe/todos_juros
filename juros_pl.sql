--------------------------------------------------------
--  Arquivo criado - terça-feira-janeiro-28-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package JUROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "SYSTEM"."JUROS" AS
    /* variáveis globais para simplificar as chamadas */
    QUANTIDADE INT := 3;
    COMPOSTO BOOLEAN := TRUE;
    PERIODO DOUBLE PRECISION := 30.0;
    TYPE PARCELA IS TABLE OF DOUBLE PRECISION;
    PAGAMENTOS PARCELA := PARCELA(30.0, 60.0, 90.0);
    PESOS PARCELA := PARCELA(1.0, 1.0, 1.0);
    /* calcula a somatória de pesos[] */
    FUNCTION getPesoTotal RETURN DOUBLE PRECISION;
    /* calcula o acréscimo a partir dos juros e parcelas */
    FUNCTION jurosParaAcrescimo(juros DOUBLE PRECISION) RETURN DOUBLE PRECISION;
    /* calcula os juros a partir do acréscimo e parcelas */
    FUNCTION acrescimoParaJuros(acrescimo DOUBLE PRECISION, precisao INT,
        maxIteracoes INT, maximoJuros DOUBLE PRECISION) RETURN DOUBLE PRECISION;
    /* calcula e imprime os resultados das funções */
    PROCEDURE testaJuros;
END JUROS;

/
