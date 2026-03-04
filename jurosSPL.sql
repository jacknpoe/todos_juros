-- Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
-- Versão: 0.1: 03/03/2026: feita sem muito conhecimento de Informix SPL
-- execute os seis CREATEs e dê um EXECUTE PROCEDURE testaJuros();

------------------------------------------------------------------------------------------------------------------------------------------------------

-- cria a tabela parcelas, com os períodos de "pagamento" e os "pesos"

CREATE PROCEDURE criaParcelas()

    ON EXCEPTION IN (-310)
        -- tabela já existe, ignora
    END EXCEPTION

    CREATE TABLE parcelas ( pagamento FLOAT NOT NULL, peso FLOAT NOT NULL );

END PROCEDURE;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- preenche a tabela "parcelas" com "quantidade" parcelas de "pagamento" "indice" * "periodo" e "peso" 1.0

CREATE PROCEDURE preencheParcelas(quantidade INT, periodo FLOAT)
    DEFINE indice INT;
    LET indice = 1;

    DELETE FROM parcelas;  -- para que possam ser testados mais parcelamentos, apagamos o anterior

    WHILE indice <= quantidade
        INSERT INTO parcelas(pagamento, peso) VALUES (indice * periodo, 1.0);
        LET indice = indice + 1;
    END WHILE;
END PROCEDURE;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- retorna a somatória da coluna "peso" da tabela "parcelas"

CREATE FUNCTION getPesoTotal() RETURNING FLOAT;
    DEFINE acumulador FLOAT;
    DEFINE vpeso FLOAT;

    LET acumulador = 0.0;

    FOREACH
        SELECT peso INTO vpeso FROM parcelas
        LET acumulador = acumulador + vpeso;
    END FOREACH;

    RETURN acumulador;
END FUNCTION;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- calcula o acréscimo a partir de juros e parcelas

CREATE FUNCTION jurosParaAcrescimo(composto SMALLINT, periodo FLOAT, juros FLOAT) RETURNING FLOAT;
    DEFINE pesoTotal FLOAT;
    DEFINE acumulador FLOAT;
    DEFINE vpagamento FLOAT;
    DEFINE vpeso FLOAT;

    LET pesoTotal = getPesoTotal();

    IF periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0 THEN
        RETURN 0.0;
    END IF;

    LET acumulador = 0.0;

    FOREACH
        SELECT pagamento, peso INTO vpagamento, vpeso FROM parcelas
        IF composto <> 0 THEN
            LET acumulador = acumulador + vpeso / POWER(1.0 + juros / 100.0, vpagamento / periodo);
        ELSE
            LET acumulador = acumulador + vpeso / (1.0 + juros / 100.0 * vpagamento / periodo);
        END IF
    END FOREACH;

    IF acumulador <= 0.0 THEN
        RETURN 0.0;
    END IF;

    RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END FUNCTION;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- calcula os juros a partir do acréscimo e parcelas

CREATE FUNCTION acrescimoParaJuros(composto SMALLINT, periodo FLOAT, acrescimo FLOAT, precisao INT, maxIteracoes INT, maxJuros FLOAT) RETURNING FLOAT;

DEFINE pesoTotal FLOAT;
DEFINE minJuros FLOAT;
DEFINE medJuros FLOAT;
DEFINE minDiferenca FLOAT;
DEFINE indice INT;

LET pesoTotal = getPesoTotal();

IF periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN
    RETURN 0.0;
END IF;

LET minJuros = 0.0;
LET medJuros = maxJuros / 2.0;
LET minDiferenca = POWER(0.1, precisao);
LET indice = 0;

WHILE indice < maxIteracoes
    IF maxJuros - minJuros < minDiferenca THEN
        RETURN medJuros;
    END IF;
    IF jurosParaAcrescimo(composto, periodo, medJuros) < acrescimo THEN
        LET minJuros = medJuros;
    ELSE
        LET maxJuros = medJuros;
    END IF;
    LET medJuros = (minJuros + maxJuros) / 2.0;
    LET indice = indice + 1;
END WHILE;

RETURN medJuros;
END FUNCTION;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- testa todas as funções de juros, execute somente ela, que inclusive cria as parcelas e preenche

CREATE PROCEDURE testaJuros()
    RETURNING FLOAT, FLOAT, FLOAT;

    DEFINE quantidade INT;
    DEFINE composto SMALLINT;
    DEFINE periodo FLOAT;

    DEFINE pesoTotal FLOAT;
    DEFINE acrescimoCalculado FLOAT;
    DEFINE jurosCalculado FLOAT;

    LET quantidade = 3;
    LET composto = 1;  -- 0 = simples, !0 = compostos
    LET periodo = 30.0;

    EXECUTE PROCEDURE criaParcelas();
    EXECUTE PROCEDURE preencheParcelas(quantidade, periodo);

    LET pesoTotal = getPesoTotal();
    LET acrescimoCalculado = jurosParaAcrescimo(composto, periodo, 3.0);
    LET jurosCalculado = acrescimoParaJuros(composto, periodo, acrescimoCalculado, 15, 65, 50.0);

    RETURN pesoTotal, acrescimoCalculado, jurosCalculado;
END PROCEDURE;

------------------------------------------------------------------------------------------------------------------------------------------------------
