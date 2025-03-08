(* Calculo do juros, sendo que precisa de arrays pra isso
   Versao 0.1: 01/05/2024: somente variaveis e testes sem conhecimento de Modula-2
          0.2: 02/05/2024: funcoes e testes
          0.3: 02/05/2024: com arrays dinamicos
          0.4: 03/05/2024: com QUANTIDADETOTAL para quantidade
          0.5: 08/03/2025: correção de um RETURN que faltava na linha 83
*)
MODULE juros;
FROM InOut IMPORT WriteString, WriteLn;
FROM SLongIO IMPORT WriteFloat;
FROM LongMath IMPORT power;

CONST QUANTIDADETOTAL = 3;

    (* estrutura basica para simplificar as chamadas *)
VAR Quantidade: INTEGER;
    Composto: BOOLEAN;
    Periodo: LONGREAL;
    Pagamentos, Pesos: ARRAY[1..QUANTIDADETOTAL] OF LONGREAL;

    (* variaveis do programa principal *)
    PesoTotal, Acrescimo, Juros: LONGREAL;
    indice: INTEGER;    

(* calcula a somatoria de Pesos[] *)
PROCEDURE getPesoTotal(): LONGREAL;
VAR indice: INTEGER;
    acumulador: LONGREAL;
BEGIN
  acumulador := 0.0;
  FOR indice := 1 TO Quantidade DO
    acumulador := acumulador + Pesos[indice];
(*    acumulador := acumulador + (ADDADR(Pesos, CARDINAL(indice * TamLong)))^; *)
  END;
  RETURN acumulador;
END getPesoTotal;

(* calcula o acrescimo a partir dos juros e dados comuns (como parcelas) *)
PROCEDURE jurosParaAcrescimo(juros: LONGREAL): LONGREAL;
VAR indice: INTEGER;
    pesoTotal, acumulador: LONGREAL;
BEGIN
  pesoTotal := getPesoTotal();
  IF (juros <= 0.0) OR (Quantidade < 1) OR (Periodo <= 0.0) OR (pesoTotal <= 0.0) THEN
    RETURN 0.0;
  END;

  acumulador := 0.0;
  FOR indice := 1 TO Quantidade DO
    IF Composto THEN
      acumulador := acumulador + Pesos[indice] / power (1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
    ELSE
      acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
    END;
  END;
  RETURN (pesoTotal / acumulador - 1.0) * 100.0;
END jurosParaAcrescimo; 

(* calcula os juros a partir do acrescimo e dados comuns (como parcelas) *)
PROCEDURE acrescimoParaJuros(acrescimo: LONGREAL; precisao, maxIteracoes: INTEGER; maxJuros: LONGREAL): LONGREAL;
VAR indice: INTEGER;
  pesoTotal, minJuros, medJuros, minDiferenca: LONGREAL;
BEGIN
  pesoTotal := getPesoTotal();
  IF (maxIteracoes < 1) OR (Quantidade < 1) OR (precisao < 1) OR (Periodo <= 0.0) OR (acrescimo <= 0.0) OR (maxJuros <= 0.0) OR (pesoTotal <= 0.0) THEN
    RETURN 0.0;
  END;

  minJuros := 0.0;
  minDiferenca := power(0.1, LFLOAT(precisao));
   
  FOR indice := 1 TO maxIteracoes DO
    medJuros := (minJuros + maxJuros) / 2.0;
    IF (maxJuros - minJuros) < minDiferenca THEN
      RETURN medJuros;
    END; 
    IF jurosParaAcrescimo(medJuros) < acrescimo THEN
      minJuros := medJuros;
    ELSE
      maxJuros := medJuros;
    END;
  END;
  RETURN medJuros;  (* correção 08/03/2025 *)
END acrescimoParaJuros;

BEGIN (* programa principal *)

  (* define os valores da estrutura basica *)  
  Quantidade := QUANTIDADETOTAL;
  Composto := TRUE;
  Periodo := 30.0;
  
  FOR indice := 1 TO Quantidade DO
    Pagamentos[indice] := 30.0 * LFLOAT(indice);
    Pesos[indice] := 1.0;
  END;  
  
  (* testa, executando as procedures *)
  PesoTotal := getPesoTotal();
  Acrescimo := jurosParaAcrescimo( 3.0);
  Juros := acrescimoParaJuros( Acrescimo, 15, 100, 50.0);
  
  (* imprime os resultados *)
  WriteString("Peso Total = ");
  WriteFloat(PesoTotal, 14, 12);
  WriteLn;
  WriteString("Acrescimo = ");
  WriteFloat(Acrescimo, 14, 12);
  WriteLn;
  WriteString("Juros = ");
  WriteFloat(Juros, 14, 12);
  WriteLn;
END juros.