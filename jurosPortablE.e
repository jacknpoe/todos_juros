-> Cálculo dos juros, sendo que precisa de parcelas pra isso
-> Versão 0.1: 28/02/2025: versão feita sem muito conhecimento de PortablE

-> globais para simplificar as chamadas às procedures
DEF Quantidade:INT, Composto:BOOL, Periodo:FLOAT, Pagamentos:ARRAY OF FLOAT, Pesos:ARRAY OF FLOAT

-> calcula a somatória de Pesos[]
PROC getPesoTotal() RETURNS acumulador:FLOAT
    DEF indice:INT
    acumulador := 0.0
    FOR indice := 0 TO Quantidade - 1 DO acumulador := acumulador + Pesos[indice]
ENDPROC

-> calcula o acréscimo a partir dos juros e parcelas
PROC jurosParaAcrescimo(juros:FLOAT) RETURNS resultado:FLOAT
    DEF pesoTotal:FLOAT, acumulador:FLOAT, indice:INT
    pesoTotal := getPesoTotal()
    IF (juros <= 0.0) OR (Quantidade < 1) OR (Periodo <= 0.0) OR (pesoTotal <= 0.0)
        resultado := 0.0
    ELSE
        acumulador := 0.0
        FOR indice := 0 TO Quantidade - 1
            IF Composto
                acumulador := acumulador + (Pesos[indice] / Fpow(1.0 + (juros / 100.0), Pagamentos[indice] / Periodo))
            ELSE
                acumulador := acumulador + (Pesos[indice] / (1.0 + (juros / 100.0 * Pagamentos[indice] / Periodo)))
            ENDIF
        ENDFOR
        IF acumulador <= 0.0
            resultado := 0.0
        ELSE
            resultado := (pesoTotal / acumulador - 1.0) * 100.0
        ENDIF
    ENDIF
ENDPROC

-> calcula os juros a partir do acréscimo e parcelas
PROC acrescimoParaJuros(acrescimo:FLOAT, precisao:INT, maxIteracoes:INT, maxJuros:FLOAT) RETURNS medJuros:FLOAT
    DEF pesoTotal:FLOAT, minJuros:FLOAT, minDiferenca:FLOAT, indice:INT
    pesoTotal := getPesoTotal()
    IF (acrescimo <= 0.0) OR (Quantidade < 1) OR (Periodo <= 0.0) OR (pesoTotal <= 0.0) OR (precisao < 1) OR (maxIteracoes < 1) OR (maxJuros <= 0.0)
        medJuros := 0.0
    ELSE
        minJuros := 0.0
        minDiferenca := Fpow(0.1, precisao)
        FOR indice := 1 TO maxIteracoes
            medJuros := (minJuros + maxJuros) / 2.0
            IF jurosParaAcrescimo(medJuros) < acrescimo THEN minJuros := medJuros ELSE maxJuros := medJuros
        ENDFOR IF (maxJuros - minJuros) < minDiferenca
    ENDIF
ENDPROC

->resultado := Fpow(base, expoente)

PROC main()
    DEF indice:INT, pesoTotal:FLOAT, acrescimoCalculado:FLOAT, jurosCalculado:FLOAT, s[8]:STRING

    -> inicializa as variáveis globais
    Quantidade := 3
    Composto := TRUE
    Periodo := 30.0
    NEW Pagamentos[Quantidade]
    NEW Pesos[Quantidade]
    FOR indice := 0 TO Quantidade - 1
        Pagamentos[indice] := 30.0 * (indice + 1.0)
        Pesos[indice] := 1.0
    ENDFOR

    -> calcula e guarda os retornos das procedures
    pesoTotal := getPesoTotal()
    acrescimoCalculado := jurosParaAcrescimo(3.0)
    jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

    -> imprime os resultados
    Print('Peso total = \s\n', RealF(s, pesoTotal, 5))
    Print('Acrescimo = \s\n', RealF(s, acrescimoCalculado, 5))
    Print('Juros = \s\n', RealF(s, jurosCalculado, 5))

    END Pagamentos
    END Pesos
ENDPROC