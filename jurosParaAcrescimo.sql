-- =============================================
-- Author:		Ricardo Erick Rebêlo
-- Create date: 04/02/2025
-- Description:	calcula o acréscimo a partir dos juros e parcelas
-- =============================================
CREATE OR ALTER FUNCTION jurosParaAcrescimo (@Juros float, @Composto int, @Periodo float)
RETURNS float
AS
BEGIN
	DECLARE @Contador int, @Acumulador float, @Peso float, @Pagamento float, @PesoTotal float
	SET @Contador = 1
	SET @Acumulador = 0.0

	SET @PesoTotal = dbo.getPesoTotal()

	IF @Juros <= 0.0 OR @Periodo <= 0.0 OR @PesoTotal <= 0.0
	BEGIN
		RETURN 0.0
	END

	WHILE (SELECT indice FROM parcelas WHERE indice = @Contador) > 0
	BEGIN
		SET @Peso = (SELECT peso FROM parcelas WHERE indice = @Contador)
		SET @Pagamento = (SELECT pagamento FROM parcelas WHERE indice = @Contador)

		IF @Composto = 1
		BEGIN
			SET @Acumulador = @Acumulador + @Peso / POWER(1.0 + @Juros / 100, @Pagamento / @Periodo)
		END ELSE BEGIN
			SET @Acumulador = @Acumulador + @Peso / (1.0 + @Juros / 100 * @Pagamento / @Periodo)
		END

		SET @Contador = @Contador + 1
	END

	IF @Acumulador <= 0.0
	BEGIN
		RETURN 0.0
	END
	RETURN (@PesoTotal / @Acumulador - 1.0) * 100.0
END
GO