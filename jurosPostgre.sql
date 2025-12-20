-- Cacula o acréscimo a partir dos juros e os juros a partir do acréscimo
-- Versões: 0.1: 20/12/2025: versão sem muito conhecimento de PostgreSQL

-- calcula o total dos valores do array de pesos
CREATE OR REPLACE FUNCTION getPesoTotal(pesos NUMERIC[]) RETURNS NUMERIC AS $$
DECLARE
    acumulador NUMERIC := 0.0;
BEGIN
    FOR indice IN 1..array_length(pesos, 1) LOOP
        acumulador := acumulador + pesos[indice];
    END LOOP;
    RETURN acumulador;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- calcula o acréscimo a partir dos juros e parcelas
CREATE OR REPLACE FUNCTION jurosParaAcrescimo(composto BOOLEAN, periodo NUMERIC, pagamentos NUMERIC[], pesos NUMERIC[], juros NUMERIC) RETURNS NUMERIC AS $$
DECLARE
    pesoTotal NUMERIC;
    acumulador NUMERIC := 0.0;
BEGIN
    SELECT getPesoTotal(pesos) INTO pesoTotal;
    IF pesoTotal <= 0.0 OR periodo <= 0.0 OR juros <= 0.0 THEN
        RETURN 0.0;
    END IF;

    FOR indice IN 1..array_length(pagamentos, 1) LOOP
        IF composto THEN
            acumulador := acumulador + pesos[indice] / (1.0 + juros / 100.0) ^ (pagamentos[indice] / periodo);
        ELSE
            acumulador := acumulador + pesos[indice] / (1.0 + juros / 100.0 * pagamentos[indice] / periodo);
        END IF;
    END LOOP;

    IF acumulador <= 0.0 THEN
        RETURN 0.0;
    END IF;

    RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- calcula os juros a partir do acréscimo e parcelas
CREATE OR REPLACE FUNCTION acrescimoParaJuros(composto BOOLEAN, periodo NUMERIC, pagamentos NUMERIC[], pesos NUMERIC[], acrescimo NUMERIC, precisao INTEGER, maxIteracoes INTEGER, maxJuros NUMERIC) RETURNS NUMERIC AS $$
DECLARE
    pesoTotal NUMERIC;
    minJuros NUMERIC; medJuros NUMERIC; minDiferenca NUMERIC; calculado NUMERIC;
BEGIN
    SELECT getPesoTotal(pesos) INTO pesoTotal;
    IF pesoTotal <= 0.0 OR periodo <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN
        RETURN 0.0;
    END IF;

    minJuros := 0.0;
    minDiferenca := 0.1 ^ precisao;

    FOR indice IN 1..maxIteracoes LOOP
        medJuros := (maxJuros + minJuros) / 2.0;

        if maxJuros - minJuros < minDiferenca THEN
            RETURN medJuros;
        END IF;

        SELECT jurosParaAcrescimo(composto, periodo, pagamentos, pesos, medJuros) INTO calculado;
        
        IF calculado < acrescimo THEN
            minJuros := medJuros;
        ELSE
            maxJuros := medJuros;
        END IF;
    END LOOP;

    RETURN medJuros;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- testa as funções de cálculo de juros e acréscimo, teste fazendo: SELECT testaJuros();
CREATE OR REPLACE FUNCTION testaJuros() RETURNS VARCHAR AS $$
DECLARE
    quantidade INTEGER := 3;
    composto BOOLEAN := TRUE;
    periodo NUMERIC := 30;
    pagamentos NUMERIC[]; pesos NUMERIC[]; 
    pesoTotal NUMERIC; acrescimoCalculado NUMERIC; jurosCalculado NUMERIC;
    resposta VARCHAR;
BEGIN
    -- inicializa os arrays de pesos e pagamentos
    FOR indice IN 1..quantidade LOOP
        pagamentos[indice] := indice * periodo;
        pesos[indice] := 1.0;
    END LOOP;

    -- calcula e guarda os resultados das funções
    SELECT getPesoTotal(pesos) INTO pesoTotal;
    SELECT jurosParaAcrescimo(composto, periodo, pagamentos, pesos, 3.0) INTO acrescimoCalculado;
    SELECT acrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimoCalculado, 15, 100, 50.0) INTO jurosCalculado;

    -- aqui, acumulamos os resultados em uma string para retornar
    resposta := 'Peso total: ' || pesoTotal;
    resposta := resposta || ' / Acréscimo calculado: ' || acrescimoCalculado;
    resposta := resposta || ' / Juros calculado: ' || jurosCalculado;

    RETURN resposta; 
END;
$$ LANGUAGE plpgsql;
