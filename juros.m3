(* Calculo do juros, sendo que precisa de arrays pra isso
   Versao 0.1: 08/03/2025: adaptado de Modula-2, sem ter como testar em Modula-3
          0.2: 24/01/2026: código corrigido, compilado, testado e conforme *)

MODULE juros EXPORTS Main;
FROM IO IMPORT Put;  (* , PutReal; *)
FROM Fmt IMPORT LongReal, Style;
FROM Math IMPORT pow;

TYPE
    Vetor = REF ARRAY OF LONGREAL;

(* estrutura basica para simplificar as chamadas *)
VAR
  Quantidade: INTEGER;
  Composto: BOOLEAN;
  Periodo: LONGREAL;
  Pagamentos, Pesos: Vetor;

  (* variaveis do programa principal *)
  PesoTotal, Acrescimo, Juros: LONGREAL;

(* calcula a somatoria de Pesos[] *)
PROCEDURE getPesoTotal(): LONGREAL =
VAR acumulador: LONGREAL;
BEGIN
  acumulador := 0.0D0;
  FOR indice := 0 TO Quantidade - 1 DO
    acumulador := acumulador + Pesos^[indice];
  END;
  RETURN acumulador;
END getPesoTotal;

(* calcula o acrescimo a partir dos juros e dados comuns (como parcelas) *)
PROCEDURE jurosParaAcrescimo(juros: LONGREAL): LONGREAL =
VAR pesoTotal, acumulador: LONGREAL;
BEGIN
  pesoTotal := getPesoTotal();
  IF (juros <= 0.0D0) OR (Quantidade < 1) OR (Periodo <= 0.0D0) OR (pesoTotal <= 0.0D0) THEN
    RETURN 0.0D0;
  END;

  acumulador := 0.0D0;
  FOR indice := 0 TO Quantidade -1 DO
    IF Composto THEN
      acumulador := acumulador + Pesos^[indice] / pow(1.0D0 + juros / 100.0D0, Pagamentos^[indice] / Periodo);
    ELSE
      acumulador := acumulador + Pesos^[indice] / (1.0D0 + juros / 100.0D0 * Pagamentos^[indice] / Periodo);
    END;
  END;
  RETURN (pesoTotal / acumulador - 1.0D0) * 100.0D0;
END jurosParaAcrescimo; 

(* calcula os juros a partir do acrescimo e dados comuns (como parcelas) *)
PROCEDURE acrescimoParaJuros(acrescimo: LONGREAL; precisao, maxIteracoes: INTEGER; maxJuros: LONGREAL): LONGREAL =
VAR pesoTotal, minJuros, medJuros, minDiferenca: LONGREAL;
BEGIN
  pesoTotal := getPesoTotal();
  IF (maxIteracoes < 1) OR (Quantidade < 1) OR (precisao < 1) OR (Periodo <= 0.0D0) OR (acrescimo <= 0.0D0) OR (maxJuros <= 0.0D0) OR (pesoTotal <= 0.0D0) THEN
    RETURN 0.0D0;
  END;

  minJuros := 0.0D0;
  minDiferenca := pow(0.1D0, FLOAT(precisao, LONGREAL));
  medJuros := maxJuros / 2.0D0;
   
  FOR indice := 1 TO maxIteracoes DO
    IF (maxJuros - minJuros) < minDiferenca THEN
      RETURN medJuros;
    END; 
    IF jurosParaAcrescimo(medJuros) < acrescimo THEN
      minJuros := medJuros;
    ELSE
      maxJuros := medJuros;
    END;
    medJuros := (minJuros + maxJuros) / 2.0D0;
  END;
  RETURN medJuros;
END acrescimoParaJuros;

BEGIN (* programa principal *)
  (* define os valores da estrutura basica *)
  Quantidade := 3;
  Composto := TRUE;
  Periodo := 30.0D0;

  (* aloca os arrays dinamicamente *)
  Pagamentos := NEW(Vetor, Quantidade);
  Pesos := NEW(Vetor, Quantidade);

  (* define os valores dos arrays *)
  FOR indice := 0 TO Quantidade - 1 DO
    Pagamentos^[indice] := 30.0D0 * FLOAT(indice + 1, LONGREAL);
    Pesos^[indice] := 1.0D0;
  END;

  (* testa, executando as procedures *)
  PesoTotal := getPesoTotal();
  Acrescimo := jurosParaAcrescimo( 3.0D0);
  Juros := acrescimoParaJuros( Acrescimo, 15, 65, 50.0D0);

  (* imprime os resultados *)
  Put("Peso Total = ");
  Put(LongReal(PesoTotal, Style.Fix, 15));
  Put("\nAcrescimo = ");
  Put(LongReal(Acrescimo, Style.Fix, 15));
  Put("\nJuros = ");
  Put(LongReal(Juros, Style.Fix, 15));
  Put("\n");
END juros.