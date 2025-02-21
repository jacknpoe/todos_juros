# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 21/02/2025: versão feita sem muito conhecimento de Visual DialogScript

# para usar os labels como função
#DEFINE FUNCTION,GetPesoTotal
#DEFINE FUNCTION,JurosParaAcrescimo
#DEFINE FUNCTION,AcrescimoParaJuros

# para usar o "." como "separador de decimal" para os números ponto flutuante
option decimalsep,.

# variávels globais para simplificar as chamadas
%%Quantidade = 3
%%Composto = true
%%Periodo = 30.0
%%Pagamentos = @new(list)
%%Pesos = @new(list)

# inicializa as listas
%%Indice = 0
While @greater(%%Quantidade, %%Indice)
  list add, %%Pagamentos, @fmul(30.0, @fadd(%%Indice, 1.0))
  list add, %%Pesos, 1.0
  %%Indice = @fadd(%%Indice, 1)
Wend

# calcula e guarda os retornos das funções
%%PesoTotal = @GetPesoTotal()
%%AcrescimoCalculado = @JurosParaAcrescimo(3.0)
%%JurosCalculado = @AcrescimoParaJuros(%%AcrescimoCalculado, 15, 100, 50.0)

# imprime os resultados
Info "Peso total =" %%PesoTotal ", Acréscimo =" %%AcrescimoCalculado ", Juros =" %%JurosCalculado

Exit

# calcula a somatória de %%Pesos
:GetPesoTotal
  %%Acumulador = 0.0
  %%Indice = 0
  While @greater(%%Quantidade, %%Indice)
    %%Acumulador = @fadd(%%Acumulador, @item(%%Pesos, %%Indice))
    %%Indice = @fadd(%%Indice, 1)
  Wend
Exit %%Acumulador

# calcula o acréscimo a partir dos juros e parcelas
:JurosParaAcrescimo
  %%PesoTotal = @GetPesoTotal()
  If @not(@both(@both(@both(@greater(%%Quantidade, 0), @greater(%%Periodo, 0.0)), @greater(%%PesoTotal, 0.0)), @greater(%1, 0.0)))
    Exit 0.0
  End
  
  %%Acumulador = 0.0
  %%Indice = 0
  While @greater(%%Quantidade, %%Indice)
    If @equal(%%Composto, true)
	  %%Acumulador = @fadd(%%Acumulador, @fdiv(@item(%%Pesos, %%Indice), @fexp(@fmul(@fdiv(@item(%%Pagamentos, %%Indice), %%Periodo), @fln(@fadd( 1.0, @fdiv(%1, 100.0)))))))
	Else
	  %%Acumulador = @fadd(%%Acumulador, @fdiv(@item(%%Pesos, %%Indice), @fadd(1.0, @fdiv(@fmul(@fdiv(%1, 100.0), @item(%%Pagamentos, %%Indice)), %%Periodo))))
	End
    %%Indice = @fadd(%%Indice, 1)
  Wend
  
  If @not(@greater(%%Acumulador, 0.0))
    Exit 0.0
  End
Exit @fmul(@fsub(@fdiv(%%PesoTotal, %%Acumulador), 1.0), 100.0)

# calcula os juros a partir do acréscimo e parcelas
:AcrescimoParaJuros
  %%PesoTotal = @GetPesoTotal()
  If @not(@both(@both(@both(@both(@both(@both(@greater(%%Quantidade, 0), @greater(%%Periodo, 0.0)), @greater(%%PesoTotal, 0.0)), @greater(%1, 0.0)), @greater(%2, 0)), @greater(%3, 0)), @greater(%4, 0.0)))
    Exit 0.0
  End

  %%Iteracao = 0
  %%MinJuros = 0.0
  %%MinDiferenca = @fexp(@fmul(%2, @fln(0.1)))
  While @greater(%3, %%Iteracao)
    %%MedJuros = @fdiv(@fadd(%%MinJuros, %4), 2.0)
	If @greater(%%MinDiferenca,@fsub(%4, %%MinJuros))
	  Exit %%MedJuros
	End
	If @greater(%1, @JurosParaAcrescimo(%%MedJuros))
	  %%MinJuros = %%MedJuros
	Else
	  %4 = %%MedJuros
	End
    %%Iteracao = @fadd(%%Iteracao, 1)
  Wend

Exit %%MedJuros
# If @not(@both(@both(@both(@both(@both(@both(@greater(%%Quantidade, 0), @greater(%%Periodo, 0.0)), @greater(1, 0)), @greater(3, 2)), @greater(4, 3)), @greater(5, 4)), @greater(6, 5)))
