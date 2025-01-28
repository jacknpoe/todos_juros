--------------------------------------------------------
--  Arquivo criado - terça-feira-janeiro-28-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body JUROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "SYSTEM"."JUROS" AS
    /* calcula a somatória de pesos[] */
    FUNCTION getPesoTotal RETURN DOUBLE PRECISION IS
        acumulador DOUBLE PRECISION := 0.0;
    BEGIN
        FOR indice IN 1..QUANTIDADE LOOP
            acumulador := acumulador + PESOS(indice);
        END LOOP;
        RETURN acumulador;
    END getPesoTotal;

    /* calcula o acréscimo a partir dos juros e parcelas */
    FUNCTION jurosParaAcrescimo(juros DOUBLE PRECISION) RETURN DOUBLE PRECISION IS
        pesoTotal DOUBLE PRECISION;
        acumulador DOUBLE PRECISION := 0.0;
    BEGIN
        pesoTotal := getPesoTotal();
        IF pesoTotal <= 0.0 OR juros <= 0.0 OR QUANTIDADE < 1 OR PERIODO <= 0.0 THEN
            RETURN 0.0;
        END IF;

        FOR indice IN 1..QUANTIDADE LOOP
            IF COMPOSTO THEN
                acumulador := acumulador + PESOS(indice) / (1.0 + juros / 100.0) ** (PAGAMENTOS(indice) / PERIODO);
            ELSE
                acumulador := acumulador + PESOS(indice) / (1.0 + juros / 100.0 * PAGAMENTOS(indice) / PERIODO);
            END IF;
        END LOOP;

        IF acumulador <= 0.0 THEN
            RETURN 0.0;
        END IF;
        RETURN (pesoTotal / acumulador - 1.0) * 100.0;
    END jurosParaAcrescimo;

    /* calcula os juros a partir do acréscimo e parcelas */
    FUNCTION acrescimoParaJuros(acrescimo DOUBLE PRECISION, precisao INT,
        maxIteracoes INT, maximoJuros DOUBLE PRECISION) RETURN DOUBLE PRECISION IS
        pesoTotal DOUBLE PRECISION;
        minJuros DOUBLE PRECISION := 0.0;
        medJuros DOUBLE PRECISION;
        maxJuros DOUBLE PRECISION;
        minDiferenca DOUBLE PRECISION;
    BEGIN
        pesoTotal := getPesoTotal();
        IF pesoTotal <= 0.0 OR acrescimo <= 0.0 OR QUANTIDADE < 1 OR PERIODO <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maximoJuros <= 0.0 THEN
            RETURN 0.0;
        END IF;
        
        minDiferenca := 0.1 ** precisao;
        maxJuros := maximoJuros;
        
        FOR indice IN 1..maxIteracoes LOOP
            medJuros := (minJuros + maxJuros) / 2.0;
            IF (maxJuros - minJuros) < minDiferenca THEN
                RETURN medJuros;
            END IF;
            IF jurosParaAcrescimo(medJuros) < acrescimo THEN
                minJuros := medJuros;
            ELSE
                maxJuros := medJuros;
            END IF;
        END LOOP;
        RETURN medJuros;
    END acrescimoParaJuros;

    /* calcula e imprime os resultados das funções */
    PROCEDURE testaJuros IS
        pesoTotal DOUBLE PRECISION;
        acrescimoCalculado DOUBLE PRECISION;
        jurosCalculado DOUBLE PRECISION;
    BEGIN
        pesoTotal := getPesoTotal();
        acrescimoCalculado := jurosParaAcrescimo(3.0);
        jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 35, 200, 50.0);

        DBMS_Output.PUT_LINE ('Peso total =  ' || pesoTotal);
        DBMS_Output.PUT_LINE ('Acréscimo =  ' || acrescimoCalculado);
        DBMS_Output.PUT_LINE ('Juros =  ' || jurosCalculado);
    END testaJuros;
END JUROS;

/
