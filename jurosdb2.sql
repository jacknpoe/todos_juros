-- Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
-- Versões: 0.1: 23/12/2025: criado a partir do MySQL (MariaDB) conhecendo pouco de DB2

--#SET TERMINATOR @

-- cria a tabela parcela com os campos pagamento e peso e popula com dados iniciais para testes
CREATE TABLE parcela (pagamento DOUBLE NOT NULL, peso DOUBLE NOT NULL);
@

INSERT INTO parcela (pagamento, peso) VALUES (30, 1), (60, 1), (90, 1);
@

-- calcula a somatória da coluna peso
CREATE OR REPLACE PROCEDURE getPesoTotal (
    OUT pesoTotal DOUBLE
)
LANGUAGE SQL
BEGIN
    DECLARE done        SMALLINT DEFAULT 0;
    DECLARE acumulador  DOUBLE DEFAULT 0.0;
    DECLARE vpeso       DOUBLE;

    DECLARE vcursor CURSOR FOR
        SELECT peso
        FROM parcela;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = 1;

    OPEN vcursor;

    fetch_loop:
    LOOP
        FETCH vcursor INTO vpeso;

        IF done = 1 THEN
            LEAVE fetch_loop;
        END IF;

        SET acumulador = acumulador + vpeso;
    END LOOP;

    CLOSE vcursor;

    SET pesoTotal = acumulador;
END @

-- calcula o acréscimo equivalente a uma taxa de juros informada
CREATE OR REPLACE PROCEDURE jurosParaAcrescimo (
    juros    DOUBLE,
    composto SMALLINT,
    periodo  DOUBLE,
    OUT acrescimo DOUBLE
)
LANGUAGE SQL
DETERMINISTIC
BEGIN
    DECLARE done        SMALLINT DEFAULT 0;
    DECLARE acumulador  DOUBLE DEFAULT 0.0;
    DECLARE vpagamento  DOUBLE;
    DECLARE vpeso       DOUBLE;
    DECLARE pesoTotal   DOUBLE;

    DECLARE vcursor CURSOR FOR
        SELECT pagamento, peso
        FROM parcela;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = 1;

    CALL getPesoTotal(pesoTotal);

    IF juros <= 0.0
       OR periodo <= 0.0
       OR pesoTotal <= 0.0 THEN
        SET acrescimo = 0.0;
        RETURN;
    END IF;

    OPEN vcursor;

    fetch_loop:
    LOOP
        FETCH vcursor INTO vpagamento, vpeso;

        IF done = 1 THEN
            LEAVE fetch_loop;
        END IF;

        IF composto = 1 THEN
            SET acumulador =
                acumulador
                + vpeso
                  / POWER(
                        1.0 + juros / 100.0,
                        vpagamento / periodo
                    );
        ELSE
            SET acumulador =
                acumulador
                + vpeso
                  / (1.0 + juros / 100.0 * vpagamento / periodo);
        END IF;
    END LOOP;

    CLOSE vcursor;

    IF acumulador <= 0.0 THEN
        SET acrescimo = 0.0;
        RETURN;
    END IF;

    SET acrescimo = (pesoTotal / acumulador - 1.0) * 100.0;
END @

-- calcula os juros equivalentes a um acréscimo informado
CREATE OR REPLACE PROCEDURE acrescimoParaJuros (
    acrescimo     DOUBLE,
    composto      SMALLINT,
    periodo       DOUBLE,
    precisao      INTEGER,
    maxIteracoes  INTEGER,
    maxJuros      DOUBLE,
    OUT juros DOUBLE
)
LANGUAGE SQL
DETERMINISTIC
BEGIN
    DECLARE minJuros      DOUBLE;
    DECLARE medJuros      DOUBLE;
    DECLARE minDiferenca  DOUBLE;
    DECLARE pesoTotal     DOUBLE;
    DECLARE calculado     DOUBLE;
    DECLARE indice        INTEGER DEFAULT 0;

    CALL getPesoTotal(pesoTotal);

    IF acrescimo <= 0.0
       OR periodo <= 0.0
       OR pesoTotal <= 0.0
       OR precisao < 1
       OR maxIteracoes < 1
       OR maxJuros <= 0.0 THEN
        SET juros = 0.0;
        RETURN;
    END IF;

    SET minJuros = 0.0;
    SET medJuros = maxJuros / 2.0;
    SET minDiferenca = POWER(0.1, precisao);

    vloop:
    WHILE indice < maxIteracoes DO

        SET medJuros = (minJuros + maxJuros) / 2.0;

        IF (maxJuros - minJuros) < minDiferenca THEN
            SET juros = medJuros;
            RETURN;
        END IF;

        CALL jurosParaAcrescimo(
            medJuros,
            composto,
            periodo,
            calculado
        );

        IF calculado < acrescimo THEN
            SET minJuros = medJuros;
        ELSE
            SET maxJuros = medJuros;
        END IF;

        SET indice = indice + 1;

    END WHILE;

    SET juros = medJuros;
END @

-- testa as funções getPesoTotal, jurosParaAcrescimo e acrescimoParaJuros
CREATE OR REPLACE PROCEDURE TestaJuros (
    OUT pesoTotal           DOUBLE,
    OUT acrescimoCalculado  DOUBLE,
    OUT jurosCalculado      DOUBLE
)
LANGUAGE SQL
BEGIN
    CALL getPesoTotal(pesoTotal);
    CALL jurosParaAcrescimo(3.0, 1, 30.0, acrescimoCalculado);
    CALL acrescimoParaJuros(
                            acrescimoCalculado,
                            1,
                            30.0,
                            15,
                            100,
                            50.0,
                            jurosCalculado
                        );
END @
