' PROLOG eh a parte global da aplicacao

PROGRAM	"juros"  ' Calculo dos juros, sendo que precisa de parcelas pra isso
VERSION	"0.1"  ' Versao 0.1: 31/12/2025: versao feita sem muito conhecimento de XBasic

IMPORT	"xma"   ' biblioteca matemática para power
IMPORT	"xui"   ' GuiDesigner      : required by GuiDesigner programs

$$MAXIMO = 2  ' mudar para o numero de parcelas desejadas ($$MAXIMO = 2 = 3 parcelas)

TYPE TJUROS  ' estrutura para enviar para as funcoes
	ULONG  .quantidade
	UBYTE  .composto
	DOUBLE .periodo
	DOUBLE .pagamentos[$$MAXIMO]
	DOUBLE .pesos[$$MAXIMO]
	DOUBLE .retorno
END TYPE

DECLARE FUNCTION Entry ()
INTERNAL FUNCTION DOUBLE getPesoTotal (TJUROS ojuros)
INTERNAL FUNCTION DOUBLE jurosParaAcrescimo (TJUROS ojuros, DOUBLE juros)
INTERNAL FUNCTION DOUBLE acrescimoParaJuros (TJUROS ojuros, DOUBLE acrescimo, UBYTE precisao, ULONG maxIteracoes, DOUBLE maxJuros)

' preenchimento de dados e testes das funcoes

FUNCTION Entry ()
	TJUROS ojuros  ' objeto ojuros da estrutura TJUROS e iniciamos as escalares
	ojuros.quantidade = $$MAXIMO + 1  ' um array x[m] vai de 0 a m, sao m + 1 elementos
	ojuros.composto = 1 ' TRUE
	ojuros.periodo = 30.0

	FOR indice = 0 TO ojuros.quantidade - 1  ' iniciamos os arrays
		ojuros.pagamentos[indice] = (1.0 + indice) * ojuros.periodo
		ojuros.pesos[indice] = 1.0
	NEXT indice

	pesoTotal# = getPesoTotal (ojuros)  ' calcula e guarda os retornos das funcoes
	acrescimoCalculado# = jurosParaAcrescimo (ojuros, 3.0)
	jurosCalculado# = acrescimoParaJuros (ojuros, acrescimoCalculado#, 15, 100, 50.0)

	mensagem$ = "[juros]"  ' montamos uma string para mostrar na tela
	mensagem$ = mensagem$ + "\nPeso total: " + TRIM$ (STR$ (pesoTotal#))
	mensagem$ = mensagem$ + "\nAcrescimo: " + TRIM$ (STR$ (acrescimoCalculado#))
	mensagem$ = mensagem$ + "\nJuros: " + TRIM$ (STR$ (jurosCalculado#))

	XuiMessage (mensagem$)  ' mostramos a string
END FUNCTION

' calcula a somatoria de todos os elementos de pesos

FUNCTION DOUBLE getPesoTotal (TJUROS ojuros)
	acumulador# = 0.0

	FOR indice = 0 TO ojuros.quantidade - 1
		acumulador# = acumulador# + ojuros.pesos[indice]
	NEXT indice

	EXIT FUNCTION acumulador#
END FUNCTION

' calcula o acrescimo a partir dos juros e parcelas

FUNCTION DOUBLE jurosParaAcrescimo (TJUROS ojuros, DOUBLE juros)
	pesoTotal# = getPesoTotal (ojuros)
	IF (juros <= 0.0) OR (ojuros.quantidade < 1) OR (ojuros.periodo <= 0.0) OR (pesoTotal# <= 0.0) THEN RETURN 0.0

	acumulador# = 0.0

	FOR indice = 0 TO ojuros.quantidade - 1
		IF ojuros.composto = 1 THEN
			acumulador# = acumulador# + ojuros.pesos[indice] / POWER (1.0 + juros / 100.0, ojuros.pagamentos[indice] / ojuros.periodo)
		ELSE
			acumulador# = acumulador# + ojuros.pesos[indice] / (1.0 + juros / 100.0 * ojuros.pagamentos[indice] / ojuros.periodo)
		END IF
	NEXT indice

	IF acumulador# <= 0.0 THEN RETURN 0.0

	RETURN (pesoTotal# / acumulador# - 1.0) * 100.0
END FUNCTION

' calcula os juros a partir do acrescimo e parcelas

FUNCTION DOUBLE acrescimoParaJuros (TJUROS ojuros, DOUBLE acrescimo, UBYTE precisao, ULONG maxIteracoes, DOUBLE maxJuros)
	pesoTotal# = getPesoTotal (ojuros)
	IF (acrescimo <= 0.0) OR (ojuros.quantidade < 1) OR (ojuros.periodo <= 0.0) OR (pesoTotal# <= 0.0) OR (precisao < 1) OR (maxIteracoes < 1) OR (maxJuros <= 0.0) THEN RETURN 0.0

	minJuros# = 0.0
	minDiferenca# = POWER (0.1, precisao)

	FOR indice = 1 TO maxIteracoes
		medJuros# = (minJuros# + maxJuros) / 2.0
		IF maxJuros - minHuros# < minDiferenca# RETURN medJuros#
		IF jurosParaAcrescimo (ojuros, medJuros#) < acrescimo THEN minJuros# = medJuros# ELSE maxJuros = medJuros#
	NEXT indice

	RETURN medJuros#
END FUNCTION
END PROGRAM
