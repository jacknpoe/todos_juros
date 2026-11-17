' Cálculo dos juros, sendo que precisa de arrays pra isso
' Versão 0.1: 16/11/2026: versão feita sem muito conhecimento de BazzBasic

' declarações de globais e inicializações
LET Quantidade$ = 3
LET Composto$ = TRUE
LET Periodo$ = 30.0
DIM Pagamentos$, Pesos$

' inicialização dos elementos nos arrays Pagamentos$() e Pesos$()
FOR indice$ = 0 TO Quantidade$ - 1
    Pagamentos$(indice$) = (indice$ + 1) * Periodo$
    Pesos$(indice$) = 1.0
NEXT indice$

' calcula a somatória dos elementos do array Pesos$()
DEF FN getPesoTotal$(Quantidade$, jPesos$)
    DIM Pesos$
    LET count$ = ASARRAY(Pesos$, jPesos$)
    LET acumulador$ = 0.0
    FOR indice$ = 0 TO Quantidade$ - 1
        acumulador$ = acumulador$ + Pesos$(indice$)
    NEXT indice$
    RETURN acumulador$
END DEF

' calcula o acréscimo a partir dos juros e parcelas
DEF FN jurosParaAcrescimo$(Quantidade$, Composto$, Periodo$, jPagamentos$, jPesos$, Juros$)
    DIM Pagamentos$, Pesos$
    LET pesoTotal$ = FN getPesoTotal$(Quantidade$, jPesos$)
    IF Quantidade$ < 1 OR Periodo$ <= 0.0 OR pesoTotal$ <= 0.0 OR Juros$ <= 0.0 THEN
        RETURN 0.0
    END IF
    LET count$ = ASARRAY(Pesos$, jPesos$)
    LET count$ = ASARRAY(Pagamentos$, jPagamentos$)
    LET acumulador$ = 0.0
    FOR indice$ = 0 TO Quantidade$ - 1
        IF Composto$ THEN
            acumulador$ = acumulador$ + Pesos$(indice$) / POW(1.0 + Juros$ / 100.0, Pagamentos$(indice$) / Periodo$)
        ELSE
            acumulador$ = acumulador$ + Pesos$(indice$) / (1.0 + Juros$ / 100.0 * Pagamentos$(indice$) / Periodo$)
        END IF
    NEXT indice$
    IF acumulador$ <= 0.0 THEN
        RETURN 0.0
    ELSE
        RETURN (pesoTotal$ / acumulador$ - 1.0) * 100.0
    END IF
END DEF

' calcula os juros a partir do acréscimo e parcelas
DEF FN acrescimoParaJuros$(Quantidade$, Composto$, Periodo$, jPagamentos$, jPesos$, Acrescimo$, Precisao$, MaxIteracoes$, MaxJuros$)
    LET pesoTotal$ = FN getPesoTotal$(Quantidade$, jPesos$)
    IF Quantidade$ < 1 OR Periodo$ <= 0.0 OR pesoTotal$ <= 0.0 OR Acrescimo$ <= 0.0 OR Precisao$ < 1 OR MaxIteracoes$ < 1 OR MaxJuros$ <= 0.0 THEN
        RETURN 0.0
    END IF
    LET minJuros$ = 0.0
    LET medJuros$ = MaxJuros$ / 2.0
    LET minDiferenca$ = POW(0.1, Precisao$)
    FOR iteracao$ = 1 TO MaxIteracoes$
        IF MaxJuros$ - minJuros$ <= minDiferenca$ THEN
            RETURN medJuros$
        END IF
        IF FN jurosParaAcrescimo$(Quantidade$, Composto$, Periodo$, jPagamentos$, jPesos$, medJuros$) < Acrescimo$ THEN
            minJuros$ = medJuros$
        ELSE
            MaxJuros$ = medJuros$
        END IF
        medJuros$ = (minJuros$ + MaxJuros$) / 2.0
    NEXT iteracao$
    RETURN medJuros$
END DEF

' calcula e guarda os resultados das funções
LET pesoTotal$ = FN getPesoTotal$(Quantidade$, ASJSON(Pesos$))
LET acrescimoCalculado$  = FN jurosParaAcrescimo$(Quantidade$, Composto$, Periodo$, ASJSON(Pagamentos$), ASJSON(Pesos$), 3.0)
LET jurosCalculado$  = FN acrescimoParaJuros$(Quantidade$, Composto$, Periodo$, ASJSON(Pagamentos$), ASJSON(Pesos$), acrescimoCalculado$, 15, 65, 50.0)

' imprime os resultados
PRINT "Peso total = "; pesoTotal$
PRINT "Acréscimo = "; acrescimoCalculado$
PRINT "Juros = "; jurosCalculado$

END
