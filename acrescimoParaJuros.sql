-- =============================================
-- Author:		Ricardo Erick Rebêlo
-- Create date: 04/02/2025
-- Description:	calcula os juros a partir do acréscimo e parcelas
-- =============================================
CREATE OR ALTER FUNCTION acrescimoParaJuros (@Acrescimo float, @Composto int, @Periodo float, @Precisao int, @MaxIteracoes int, @MaxJuros float)
RETURNS float
AS
BEGIN
	DECLARE @Contador int, @PesoTotal float, @MinJuros float, @MedJuros float, @MinDiferenca float
	SET @Contador = 1

	SET @PesoTotal = dbo.getPesoTotal()

	IF @Acrescimo <= 0.0 OR @Periodo <= 0.0 OR @PesoTotal <= 0.0 OR @Precisao < 1 OR @MaxIteracoes < 1 OR @MaxJuros <= 0.0
	BEGIN
		RETURN 0.0
	END

	SET @MinJuros = 0.0
	SET @MinDiferenca = POWER(0.1, @Precisao)

	WHILE @Contador <= @MaxIteracoes
	BEGIN
		SET @MedJuros = (@MinJuros + @MaxJuros) / 2.0
		IF (@MaxJuros - @MinJuros) < @MinDiferenca
		BEGIN
			RETURN @MedJuros
		END

		IF dbo.jurosParaAcrescimo(@MedJuros, @Composto, @Periodo) < @Acrescimo
		BEGIN
			SET @MinJuros = @MedJuros
		END ELSE BEGIN
			SET @MaxJuros = @MedJuros
		END

		SET @Contador = @Contador + 1
	END

	RETURN @MedJuros
END
GO