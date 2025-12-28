-- Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
-- Versões: 0.1: 07/08/2024: versão só para MariaDB
--          0.2: 28/12/2025: para MySQL também, feita a partir de MariaDB, sem muito conhecimento de MySQL

CREATE DATABASE IF NOT EXISTS juros;

USE juros;

-- se existe a tabela, apaga, porque iremos criar e popular
DROP TABLE IF EXISTS parcela;

-- cria a tabela parcela com os campos pagamento e peso e popula com dados iniciais para testes
CREATE TABLE parcela ( pagamento double NOT NULL, peso double NOT NULL );

-- popuia a tabela parcela com três parcelamentos
INSERT INTO parcela (pagamento, peso) VALUES (30, 1), (60, 1), (90, 1);

DROP FUNCTION IF EXISTS getPesoTotal;

-- soma o total dos valores do campo peso
DELIMITER //
CREATE FUNCTION getPesoTotal() RETURNS DOUBLE DETERMINISTIC
BEGIN
    DECLARE done BOOL DEFAULT false;
    DECLARE acumulador DOUBLE DEFAULT 0.0;
    DECLARE vpeso DOUBLE;
    DECLARE vcursor CURSOR FOR SELECT peso FROM parcela;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

    OPEN vcursor;
    vloop: LOOP
        FETCH vcursor INTO vpeso;
        IF done THEN
            LEAVE vloop;
        END IF;
        SET acumulador = acumulador + vpeso;
    END LOOP;
    CLOSE vcursor;

    RETURN acumulador;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS jurosParaAcrescimo;

-- calcula o acréscimo equivalente a uma taxa de juros informada
DELIMITER //
CREATE FUNCTION jurosParaAcrescimo(juros DOUBLE, composto BOOL, periodo DOUBLE) RETURNS DOUBLE DETERMINISTIC
BEGIN
    DECLARE done BOOL DEFAULT false;
    DECLARE acumulador DOUBLE DEFAULT 0.0;
    DECLARE vpagamento, vpeso, pesoTotal DOUBLE;
    DECLARE vcursor CURSOR FOR SELECT pagamento, peso FROM parcela;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

    SET pesoTotal = getPesoTotal();

    IF juros <= 0.0 OR periodo <= 0.0 OR pesoTotal <= 0.0 THEN
        RETURN 0.0;
    END IF;

    OPEN vcursor;
    vloop: LOOP
        FETCH vcursor INTO vpagamento, vpeso;
        IF done THEN
            LEAVE vloop;
        END IF;
        IF composto THEN
            SET acumulador = acumulador + vpeso / POW(1.0 + juros / 100.0, vpagamento / periodo);
        ELSE
            SET acumulador = acumulador + vpeso / (1.0 + juros / 100.0 * vpagamento / periodo);
        END IF;
    END LOOP;
    CLOSE vcursor;

    IF acumulador <= 0.0 THEN
        RETURN 0.0;
    END IF;

    RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS acrescimoParaJuros;

-- calcula os juros equivalentes a um acréscimo informado
DELIMITER //
CREATE FUNCTION acrescimoParaJuros(acrescimo DOUBLE, composto BOOL, periodo DOUBLE, precisao INT, maxIteracoes INT, maxJuros DOUBLE) RETURNS DOUBLE DETERMINISTIC
BEGIN
    DECLARE minJuros, medJuros, minDiferenca, pesoTotal DOUBLE;
    DECLARE indice INT DEFAULT 0;

    SET pesoTotal = getPesoTotal();

    IF acrescimo <= 0.0 OR periodo <= 0.0 OR pesoTotal <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN
        RETURN 0.0;
    END IF;

    SET minJuros = 0.0;
    SET medJuros = maxJuros / 2.0;
    SET minDiferenca = POW(0.1, precisao);

    vloop: WHILE indice < maxIteracoes DO
        SET medJuros = (minJuros + maxJuros) / 2.0;
        IF (maxJuros - minJuros) < minDiferenca THEN
            RETURN medJuros;
        END IF;
        IF jurosParaAcrescimo(medJuros, composto, periodo) < acrescimo THEN
            SET minJuros = medJuros;
        ELSE
            SET maxJuros = medJuros;
        END IF;
        SET indice = indice + 1;
    END WHILE;

    RETURN medJuros;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS TestaJuros;

-- testa as funções getPesoTotal, jurosParaAcrescimo e acrescimoParaJuros
DELIMITER //
CREATE PROCEDURE TestaJuros()
BEGIN
    DECLARE pesoTotal, acrescimoCalculado, jurosCalculado DOUBLE;

    SET pesoTotal = getPesoTotal();
    SET acrescimoCalculado = jurosParaAcrescimo(3.0, true, 30.0);
    SET jurosCalculado = acrescimoParaJuros(acrescimoCalculado, true, 30, 15, 100, 50);

    SELECT pesoTotal, acrescimoCalculado, jurosCalculado;
END //
DELIMITER ;
