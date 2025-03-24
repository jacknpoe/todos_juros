* Cálculo do juros, sendo que precisa de arrays pra isso
* Versão 0.1: 24/03/2025: versão feita sem muito conhecimento de Clipper

* FUNCTION Main
    * variáveis "globais"
    LOCAL Quantidade := 3
    LOCAL Composto := .T.
    LOCAL Periodo := 30.0
    LOCAL Pagamentos := {30.0, 60.0, 90.0}
    LOCAL Pesos := {1.0, 1.0, 1.0}

    * variáveis resultado
    LOCAL pesoTotal, acrescimoCalculado, jurosCalculado

    * faz os cálculos e guarda os resultados das funções
    pesoTotal := getPesoTotal(Quantidade, Pesos)
    acrescimoCalculado := jurosParaAcrescimo(Quantidade, Composto, Periodo, Pagamentos, Pesos, 3.0)
    jurosCalculado := acrescimoParaJuros(Quantidade, Composto, Periodo, Pagamentos, Pesos, acrescimoCalculado, 15, 100, 50.0)

    * imprime os resultados
    CLEAR
    @ 0, 0 SAY "Peso total = " + AllTrim(Str(pesoTotal, 17, 15))
    @ 1, 0 SAY "Acrescimo = " + AllTrim(Str(acrescimoCalculado, 17, 15))
    @ 2, 0 SAY "Juros = " + AllTrim(Str(jurosCalculado, 17, 15))
* RETURN nil

* calcula a somatória de Pesos[]
FUNCTION getPesoTotal(Quantidade, Pesos)
    LOCAL acumulador := 0.0, indice := 0
    FOR indice := 1 TO Quantidade
        acumulador = acumulador + Pesos[indice]
    NEXT
    RETURN acumulador

* calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
FUNCTION jurosParaAcrescimo(Quantidade, Composto, Periodo, Pagamentos, Pesos, Juros)
    LOCAL acumulador := 0.0, indice := 0
    LOCAL pesoTotal := getPesoTotal(Quantidade, Pesos)
    IF Juros <= 0.0 .OR. Quantidade < 1 .OR. Periodo <= 0.0 .OR. pesoTotal <= 0.0
        RETURN 0.0
    ENDIF

    FOR indice := 1 TO Quantidade
        IF Composto
            acumulador := acumulador + Pesos[indice] / (1.0 + Juros / 100.0) ^ (Pagamentos[indice] / Periodo)
        ELSE
            acumulador := acumulador + Pesos[indice] / (1.0 + Juros / 100.0 * Pagamentos[indice] / Periodo)
        ENDIF
    NEXT

    RETURN (pesoTotal / acumulador - 1.0) * 100.0

* calcula os juros a partir do acréscimo e dados comuns (como parcelas)
FUNCTION acrescimoParaJuros(Quantidade, Composto, Periodo, Pagamentos, Pesos, Acrescimo, Precisao, MaxIteracoes, MaxJuros)
    LOCAL minJuros := 0.0, medJuros := MaxJuros / 2.0, minDiferenca := 0.1 ^ Precisao, indice := 0
    LOCAL pesoTotal := getPesoTotal(Quantidade, Pesos)
    IF Acrescimo <= 0.0 .OR. Quantidade < 1 .OR. Periodo <= 0.0 .OR. pesoTotal <= 0.0 .OR. Precisao < 1 .OR. MaxIteracoes < 1 .OR. MaxJuros <= 0.0
        RETURN 0.0
    ENDIF

    FOR indice := 1 TO MaxIteracoes
        medJuros := (minJuros + MaxJuros) / 2.0
        IF (MaxJuros - minJuros) < minDiferenca
            RETURN medJuros
        END
        IF jurosParaAcrescimo(Quantidade, Composto, Periodo, Pagamentos, Pesos, medJuros) < acrescimo
            minJuros := medJuros
        ELSE
            MaxJuros := medJuros
        ENDIF
    NEXT

    RETURN medJuros
