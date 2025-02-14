* Cálculo dos juros, sendo que precisa de parcelas pra isso
* Versão 0.1: 14/02/2025: versão feita sem muito conhecimento de VFP 6.0

* cria um objeto oJuros da classe juros e inicializa os arrays
oJuros = CREATEOBJECT("Juros", 3, .T., 30.0)
FOR indice = 1 TO oJuros.Quantidade
	oJuros.Pagamentos[indice] = 30.0 * indice
	oJuros.Pesos[indice] = 1.0
NEXT

* calcula e guarda os resultados das funções
LOCAL pesoTotal, acrescimoCalculado, jurosCalculado
pesoTotal = oJuros.getPesoTotal()
acrescimoCalculado = oJuros.jurosParaAcrescimo(3.0)
jurosCalculado = oJuros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

* imprime os resultados
? "Peso total = ", pesoTotal
? "Acréscimo = ", acrescimoCalculado
? "Juros = ", jurosCalculado

* classe com atributos que simplificam as chamadas às funções
DEFINE CLASS Juros AS Custom
	Quantidade = 0
	Composto = .F.
	Periodo = 0.0
	DECLARE Pagamentos[1]
	DECLARE Pesos[1]
	
	* inicializa as variáveis escalaras e dimensiona os arrays
	PROCEDURE init(nQuantidade, nComposto, nPeriodo)
		THIS.Quantidade = nQuantidade
		THIS.Composto = nComposto
		THIS.Periodo = nPeriodo
		DIMENSION THIS.Pagamentos[nQuantidade]
		DIMENSION THIS.Pesos[nQuantidade]
	ENDPROC
	
	* calcula a somatória de Pesos[]
	FUNCTION getPesoTotal()
		LOCAL acumulador, indice
			acumulador = 0.0
		FOR indice = 1 TO THIS.Quantidade
			acumulador = acumulador + THIS.Pesos[indice]
		NEXT
		RETURN acumulador
	ENDFUNC
	
	* calcula o acréscimo a partir dos juros e parcelas
	FUNCTION jurosParaAcrescimo(juros)
		LOCAL pesoTotal, acumulador, indice
		pesoTotal = THIS.getPesoTotal()
		IF pesoTotal < 0.0 OR juros <= 0.0 OR THIS.Quantidade < 1 OR THIS.Periodo <= 0.0
			RETURN 0.0
		ENDIF

		acumulador = 0.0
		FOR indice = 1 TO THIS.Quantidade
			IF THIS.Composto
				acumulador = acumulador + THIS.Pesos[indice] / (1.0 + juros / 100.0) ^ (THIS.Pagamentos[indice] / THIS.Periodo)
			ELSE
				acumulador = acumulador + THIS.Pesos[indice] / (1.0 + juros / 100.0 * THIS.Pagamentos[indice] / THIS.Periodo)
			ENDIF
		NEXT
		
		RETURN (pesoTotal / acumulador - 1.0) * 100.0
	ENDFUNC
	
	* calcula os juros a partir do acréscimo e parcelas
	FUNCTION acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
		LOCAL pesoTotal, minJuros, minDiferenca, indice, medJuros
		pesoTotal = THIS.getPesoTotal()
		IF pesoTotal < 0.0 OR acrescimo <= 0.0 OR THIS.Quantidade < 1 OR THIS.Periodo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0
			RETURN 0.0
		ENDIF
		
		minJuros = 0.0
		minDiferenca = 0.1 ^ precisao
		
		FOR indice = 1 TO maxIteracoes
			medJuros = (minJuros + maxJuros) / 2.0
			IF (maxJuros - minJuros) < minDiferenca
				RETURN medJuros
			ENDIF
			IF THIS.jurosParaAcrescimo(medJuros) < acrescimo
				minJuros = medJuros
			ELSE
				maxJuros = medJuros
			ENDIF
		NEXT
		
		RETURN medJuros
	ENDFUNC
ENDDEFINE
