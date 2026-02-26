-- Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
-- Versão: 0.1: 26/02/2026: feita sem muito conhecimento de Firebird

-- use dentro do isql, estando conectado a um banco, ou inclua a linha de conexão abaixo:
-- CONNECT '<caminho>/<banco>.fdb' USER '<usuário' PASSWORD 'senha';
-- os usos de cada procedure ou função são exemplificados na procedure testaJuros()

-- ####################################################################################################################################################

-- cria a tabela juros, que será populada na função preencheJuros()

SET TERM !! ;

CREATE OR ALTER PROCEDURE criaJuros ()
AS
    DECLARE VARIABLE existe INTEGER;
BEGIN
    -- verifica se a tabela JUROS existe
    SELECT COUNT(*) FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = 'JUROS' AND RDB$SYSTEM_FLAG = 0 INTO :existe;

    IF (existe > 0) THEN
    BEGIN
        EXECUTE STATEMENT 'DROP TABLE JUROS';
    END

    -- cria a tabela novamente
    EXECUTE STATEMENT 'CREATE TABLE JUROS ( PAGAMENTO DOUBLE PRECISION NOT NULL, PESO DOUBLE PRECISION NOT NULL )';
END!!

SET TERM ; !!

-- ####################################################################################################################################################

-- preenche juros com uma `quantidade` de parcelas com indice * `periodo` de `pagamento` e 1.0 de `peso`

SET TERM !! ;

CREATE OR ALTER PROCEDURE preencheJuros (
  quantidade INTEGER,
  periodo    DOUBLE PRECISION
)
AS
  DECLARE VARIABLE indice INTEGER;
BEGIN
  -- deleta todas as parcelas existentes, evitando acúmulo de mais de um parcelamento
  DELETE FROM juros;

  -- cria as parcelas (ajuste o algoritmo para o parcelamento desejado)
  indice = 1;
  WHILE (indice <= quantidade) DO
  BEGIN
    INSERT INTO JUROS (PAGAMENTO, PESO) VALUES (:indice * :periodo, 1.0);

    indice = indice + 1;
  END
END!!

SET TERM ; !!

-- ####################################################################################################################################################

-- calcula a somatória dos valores no campo peso

SET TERM !! ;

CREATE OR ALTER FUNCTION getPesoTotal ()
RETURNS DOUBLE PRECISION
AS
  DECLARE VARIABLE acumulador DOUBLE PRECISION;
  DECLARE VARIABLE peso DOUBLE PRECISION;
BEGIN
  acumulador = 0.0;

  FOR
    SELECT PESO
    FROM JUROS
    INTO :peso
  DO
  BEGIN
    acumulador = acumulador + peso;
  END

  RETURN acumulador;
END!!

SET TERM ; !!

-- ####################################################################################################################################################

-- calcula o acréscimo a partir dos juros e parcelas

SET TERM !! ;

CREATE OR ALTER FUNCTION jurosParaAcrescimo (
    composto BOOLEAN,
    periodo DOUBLE PRECISION,
    juros DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
AS
    DECLARE VARIABLE pesoTotal DOUBLE PRECISION;
    DECLARE VARIABLE acumulador DOUBLE PRECISION;
    DECLARE VARIABLE pagamento DOUBLE PRECISION;
    DECLARE VARIABLE peso DOUBLE PRECISION;
BEGIN
    SELECT getPesoTotal() FROM RDB$DATABASE INTO :pesoTotal;

    IF (periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0) THEN
    BEGIN
        RETURN 0.0;
    END

    acumulador = 0.0;

    FOR
        SELECT PAGAMENTO, PESO FROM JUROS INTO :pagamento, :peso
    DO
    BEGIN
        IF (composto) THEN
        BEGIN
            acumulador = acumulador + peso / POWER(1.0 + juros / 100, pagamento / periodo);
        END
        ELSE
        BEGIN
            acumulador = acumulador + peso / (1.0 + juros / 100 * pagamento / periodo);
        END
    END

    IF (acumulador <= 0.0) THEN
    BEGIN
        RETURN 0.0;
    END

    RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END!!

SET TERM ; !!

-- ####################################################################################################################################################

-- calcula os juros a partir do acréscimo e parcelas

SET TERM !! ;

CREATE OR ALTER FUNCTION acrescimoParaJuros (
    composto BOOLEAN,
    periodo DOUBLE PRECISION,
    acrescimo DOUBLE PRECISION,
    precisao INTEGER,
    maxIteracoes INTEGER,
    maxJuros DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
AS
    DECLARE VARIABLE pesoTotal DOUBLE PRECISION;
    DECLARE VARIABLE minJuros DOUBLE PRECISION;
    DECLARE VARIABLE medJuros DOUBLE PRECISION;
    DECLARE VARIABLE minDiferenca DOUBLE PRECISION;
    DECLARE VARIABLE calculado DOUBLE PRECISION;
    DECLARE VARIABLE indice INTEGER;
BEGIN
    SELECT getPesoTotal() FROM RDB$DATABASE INTO :pesoTotal;

    IF (periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0) THEN
    BEGIN
        RETURN 0.0;
    END

    minJuros = 0.0;
    medJuros = maxJuros / 2.0;
    minDiferenca = POWER(0.1, precisao);

    indice = 0;
    WHILE (indice < maxIteracoes) DO
    BEGIN
        IF (maxJuros - minJuros < minDiferenca) THEN
        BEGIN
            RETURN medJuros;
        END

        SELECT jurosParaAcrescimo(:composto, :periodo, :medJuros) FROM RDB$DATABASE INTO :calculado;

        IF (calculado < acrescimo) THEN
        BEGIN
            minJuros = medJuros;
        END
        ELSE
        BEGIN
            maxJuros = medJuros;
        END

        medJuros = (minJuros + maxJuros) / 2.0;
        indice = indice + 1;
    END

    RETURN medJuros;
END!!

SET TERM ; !!

-- ####################################################################################################################################################

-- faz os testes das funções; executar com: SELECT * FROM testaJuros;
-- aqui tem exemplos de como usar criaJuros, preencheJuros(), getPesoTotal(), jurosParaAcrescimo() e acrescimoParaJuros()

SET TERM !! ;

CREATE OR ALTER PROCEDURE testaJuros ()
RETURNS (
    pesoTotal DOUBLE PRECISION,
    acrescimoCalculado DOUBLE PRECISION,
    jurosCalculado DOUBLE PRECISION
)
AS
    DECLARE VARIABLE quantidade INTEGER;
    DECLARE VARIABLE composto BOOLEAN;
    DECLARE VARIABLE periodo DOUBLE PRECISION;
    DECLARE VARIABLE juros DOUBLE PRECISION;
BEGIN
    -- defina aqui as variáveis estáticas para os testes
    quantidade = 3;
    composto = TRUE;
    periodo = 30.0;
    juros = 3.0;

    -- começa criando JUROS, populando a tabela juros com pagamentos 
    EXECUTE PROCEDURE criaJuros;
    EXECUTE PROCEDURE preencheJuros(quantidade, periodo);

    -- calcula os resultados das funções
    SELECT getPesoTotal() FROM RDB$DATABASE INTO :pesoTotal;
    SELECT jurosParaAcrescimo(:composto, :periodo, :juros) FROM RDB$DATABASE INTO :acrescimoCalculado;
    SELECT acrescimoParaJuros(:composto, :periodo, :acrescimoCalculado, 15, 65, 50.0) FROM RDB$DATABASE INTO :jurosCalculado;

    SUSPEND;
END!!

SET TERM ; !!
