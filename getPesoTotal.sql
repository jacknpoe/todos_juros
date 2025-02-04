-- =============================================
-- Author:		Ricardo Erick Rebêlo
-- Create date: 04/02/2025
-- Description:	calcula a soma dos pesos
-- =============================================
CREATE OR ALTER FUNCTION getPesoTotal ()
RETURNS float
AS
BEGIN
	DECLARE @Contador int, @Acumulador float, @Peso float
	SET @Contador = 1
	SET @Acumulador = 0.0

	WHILE (SELECT indice FROM parcelas WHERE indice = @Contador) > 0
	BEGIN
		SET @Peso = (SELECT peso FROM parcelas WHERE indice = @Contador)
		SET @Acumulador = @Acumulador + @Peso
		SET @Contador = @Contador + 1
	END

	RETURN @Acumulador
END
GO
