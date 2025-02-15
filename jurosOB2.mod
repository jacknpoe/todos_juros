(* Cálculo dos juros, sendo que precisa de parcelas pra isso
   Versão 0.1: 15/02/2025: versão feita sem muito conhecimento de Oberon-2 *)

MODULE jurosOB2;
    IMPORT Out, Math;
TYPE
    (* estrutura básica de propriedades para simplificar as chamadas *)
    TJUROS = RECORD
        quantidade: INTEGER;
        composto: BOOLEAN;
        periodo: REAL;
        pagamentos: ARRAY 1000 OF REAL;
        pesos: ARRAY 1000 OF REAL
    END;

VAR
    pesoTotal, acrescimoCalculado, jurosCalculado: REAL;
    rJuros: TJUROS;
    indice: INTEGER;

(* calcula a somatória do array pesos[] *)
PROCEDURE getPesoTotal(): REAL;
VAR
    acumulador: REAL;
    indice: INTEGER;
BEGIN
    acumulador := 0.0;
    FOR indice := 0 TO rJuros.quantidade-1 DO
        acumulador := acumulador + rJuros.pesos[indice];
    END;
    RETURN acumulador
END getPesoTotal;

(* calcula o acréscimo a partir dos juros e parcelas *)
PROCEDURE jurosParaAcrescimo(juros: REAL): REAL;
VAR
    acumulador, pesoTotal, resultado: REAL;
    indice: INTEGER;
BEGIN
    pesoTotal := getPesoTotal();
    IF (pesoTotal <= 0.0) OR (rJuros.quantidade < 1) OR (rJuros.periodo <= 0.0) OR (juros <= 0.0) THEN
        resultado := 0.0
    ELSE
        acumulador := 0.0;
        FOR indice := 0 TO rJuros.quantidade-1 DO
            IF rJuros.composto THEN
                acumulador := acumulador + rJuros.pesos[indice] / Math.power(1.0 + juros / 100.0, rJuros.pagamentos[indice] / rJuros.periodo)
            ELSE
                acumulador := acumulador + rJuros.pesos[indice] / (1.0 + juros / 100.0 * rJuros.pagamentos[indice] / rJuros.periodo)
            END;
        END;
        resultado := (pesoTotal / acumulador - 1.0) * 100.0
    END;
    RETURN resultado
END jurosParaAcrescimo;


(* calcula os juros a partir do acréscimo e parcelas *)
PROCEDURE acrescimoParaJuros(acrescimo: REAL; precisao, maxIteracoes: INTEGER; maxJuros: REAL): REAL;
VAR
    minJuros, medJuros, minDiferenca, pesoTotal, resultado: REAL;
    indice: INTEGER;
BEGIN
    pesoTotal := getPesoTotal();
    IF (pesoTotal <= 0.0) OR (rJuros.quantidade < 1) OR (rJuros.periodo <= 0.0) OR (acrescimo <= 0.0) OR (precisao < 1) OR (maxIteracoes < 1) OR (maxJuros <= 0.0) THEN
        resultado := 0.0
    ELSE
        minJuros := 0.0;
        minDiferenca := Math.power(0.1, FLT(precisao));
        FOR indice := 1 TO maxIteracoes DO
            medJuros := (minJuros + maxJuros) / 2.0;
            IF (maxJuros - minJuros) < minDiferenca THEN
                indice := maxIteracoes
            END;
            IF jurosParaAcrescimo(medJuros) < acrescimo THEN
                minJuros := medJuros
            ELSE
                maxJuros := medJuros
            END;
        END;
        resultado := medJuros
    END
    RETURN resultado
END acrescimoParaJuros;

BEGIN
    (* define valores para juros *)
    rJuros.quantidade := 3;
    rJuros.composto := TRUE;
    rJuros.periodo := 30.0;

    FOR indice := 0 TO rJuros.quantidade-1 DO
        rJuros.pagamentos[indice] := 30.0 * (FLT(indice) + 1.0);
        rJuros.pesos[indice] := 1.0
    END;

    (* calcula e guarda o resultado das procedures *)
    pesoTotal := getPesoTotal();
    acrescimoCalculado := jurosParaAcrescimo(3.0);
    jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

    (* imprime os resultados *)
    Out.String ("Peso total = "); Out.Real(pesoTotal, 15); Out.Ln;
    Out.String ("Acrescimo = "); Out.Real(acrescimoCalculado, 15); Out.Ln;
    Out.String ("Juros = "); Out.Real(jurosCalculado, 15); Out.Ln
END jurosOB2.