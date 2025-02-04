USE [master]
GO

/****** Object:  Table [dbo].[parcelas]    Script Date: 04/02/2025 20:13:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[parcelas](
	[pagamento] [float] NOT NULL,
	[peso] [float] NOT NULL,
	[indice] [int] NOT NULL,
 CONSTRAINT [PK_parcelas_1] PRIMARY KEY CLUSTERED 
(
	[indice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'períodos de pagamentos e pesos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'parcelas'
GO
