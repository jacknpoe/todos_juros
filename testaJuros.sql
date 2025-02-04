-- =============================================
-- Author:		Ricardo Erick Reb�lo
-- Create date: 04/02/2025
-- Description:	testa as fun��es de Juros
-- =============================================
CREATE OR ALTER PROCEDURE testaJuros
AS
BEGIN
	DECLARE @PesoTotal float, @AcrescimoCalculado float, @JurosCalculado float

	-- chama e guarda os resultados das fun��es
	SET @PesoTotal = dbo.getPesoTotal()
	SET @AcrescimoCalculado = dbo.jurosParaAcrescimo(3.0, 1, 30.0)
	SET @JurosCalculado = dbo.acrescimoParaJuros(@AcrescimoCalculado, 1, 30.0, 15, 100, 50.0)

	-- imprime os resultados
	PRINT 'Peso total = ' + LTRIM(STR(@PesoTotal,17, 15))
	PRINT 'Acr�scimo = ' + LTRIM(STR(@AcrescimoCalculado, 17, 15))
	PRINT 'Juros = ' + LTRIM(STR(@JurosCalculado, 17, 15))
END
GO
