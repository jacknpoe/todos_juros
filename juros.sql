-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 08/08/2024 às 03:27
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `juros`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `TestaJuros` ()   BEGIN
    DECLARE pesoTotal, acrescimoCalculado, jurosCalculado DOUBLE;

    SET pesoTotal = getPesoTotal();
    SET acrescimoCalculado = jurosParaAcrescimo(3.0, true, 30.0);
    SET jurosCalculado = acrescimoParaJuros(acrescimoCalculado, true, 30, 15, 100, 50);

    SELECT pesoTotal, acrescimoCalculado, jurosCalculado;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `acrescimoParaJuros` (`acrescimo` DOUBLE, `composto` INT, `periodo` DOUBLE, `precisao` INT, `maxIteracoes` INT, `maxJuros` DOUBLE) RETURNS DOUBLE DETERMINISTIC BEGIN
    DECLARE minJuros, medJuros, minDiferenca, pesoTotal DOUBLE;
    DECLARE indice INT DEFAULT 0;

    SET pesoTotal = getPesoTotal();

    IF acrescimo <= 0.0 || periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 THEN
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
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getPesoTotal` () RETURNS DOUBLE DETERMINISTIC READS SQL DATA BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `jurosParaAcrescimo` (`juros` DOUBLE, `composto` INT, `periodo` DOUBLE) RETURNS DOUBLE DETERMINISTIC BEGIN
    DECLARE done BOOL DEFAULT false;
    DECLARE acumulador DOUBLE DEFAULT 0.0;
    DECLARE vpagamento, vpeso, pesoTotal DOUBLE;
    DECLARE vcursor CURSOR FOR SELECT pagamento, peso FROM parcela;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

    SET pesoTotal = getPesoTotal();

    IF juros <= 0.0 || periodo <= 0.0 || pesoTotal <= 0.0 THEN
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `parcela`
--

CREATE TABLE `parcela` (
  `pagamento` double NOT NULL,
  `peso` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `parcela`
--

INSERT INTO `parcela` (`pagamento`, `peso`) VALUES
(30, 1),
(60, 1),
(90, 1);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
