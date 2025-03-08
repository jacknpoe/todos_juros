// Calculo dos juros, sendo que precisa de parcelas pra isso
// Versao 0.1: 08/03/2025: versao feita sem muito conhecimento de MPL

// uses MATH;   // para ** funcionar

type
  // estrutura dos dados comuns
  rJuros = record
    Quantidade: integer;
    Composto: boolean;
    Periodo: real;
    Pagamentos: array[0..999] of real;
    Pesos: array[0..999] of real;
  end;

// calcula a somatoria de pesos[]
function getPesoTotal(sJuros: rJuros): real;
var
   acumulador: real;
   indice: integer;
begin
  acumulador := 0.0;
  for indice := 0 to sJuros.Quantidade - 1 do
    acumulador := acumulador + sJuros.Pesos[indice];
  getPesoTotal := acumulador;
end;

// calcula o acrescimo a partir dos juros e dos dados comuns (como parcelas)
function jurosParaAcrescimo(sJuros: rJuros; juros: real): real;
var
    pesoTotal: real;
    acumulador: real;
    indice: integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if juros <= 0 or sJuros.Quantidade <= 0 or sJuros.Periodo <= 0.0 or pesoTotal <= 0.0 then begin
        jurosParaAcrescimo := 0.0;
    end else begin
        acumulador := 0.0;

        for indice := 0 to sJuros.Quantidade - 1 do
        begin
            if (sJuros.Composto)
            then acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100) ^ (sJuros.Pagamentos[indice] / sJuros.Periodo)
            else acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100 * sJuros.Pagamentos[indice] / sJuros.Periodo);
        end;

        if (acumulador <= 0.0) then begin
            jurosParaAcrescimo := 0.0;
        end else begin
            jurosParaAcrescimo := (pesoTotal / acumulador - 1) * 100;
        end;
    end;
end;

// calcula os juros a partir do acrescimo e dos dados comuns (como parcelas)
function acrescimoParaJuros(sJuros: rJuros; acrescimo: real; precisao, maxIteracoes: integer; maxJuros: real): real;
var
    pesoTotal, minJuros, medJuros, minDiferenca: real;
    indice: integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if maxIteracoes < 1 or sJuros.Quantidade <= 0 or precisao < 1 or sJuros.Periodo <= 0 or acrescimo <= 0.0 or maxJuros <= 0.0 or pesoTotal <= 0.0 then begin
        acrescimoParaJuros := 0.0;
    end else begin
        minJuros := 0.0;
        medJuros := maxJuros / 2.0;
        minDiferenca := 0.1 ** precisao;

        indice := 0;
        while indice < maxIteracoes do
        begin
            medJuros := (minJuros + maxJuros) / 2.0;
            if maxJuros - minJuros < minDiferenca then indice := maxIteracoes;
            if (jurosParaAcrescimo(sJuros, medJuros) < acrescimo)
                then minJuros := medJuros
                else maxJuros := medJuros;
            indice := indice + 1;
        end;
        acrescimoParaJuros := medJuros;
    end;
end;

var
  juros: rJuros;
    indice: integer;
    pesoTotal, acrescimoCalculado, jurosCalculado: real;
begin
  // definicao dos dados
  juros.Quantidade := 3;
  juros.Composto := true;
  juros.Periodo := 30.0;

  for indice := 0 to juros.Quantidade - 1 do
  begin
    juros.Pagamentos[indice]:= 30.0 * (indice + 1.0);
    juros.Pesos[indice] := 1.0;
  end;

    // calcula e guarda os resultados das funcoes
    pesoTotal := getPesoTotal(juros);
    acrescimoCalculado := jurosParaAcrescimo(juros, 3.0);
    jurosCalculado := acrescimoParaJuros(juros, acrescimoCalculado, 15, 100, 50.0);

  // testes
  writeln('Soma dos pesos = ' + real2str(pesoTotal, 15));
  writeln('Acrescimo = ' + real2str(acrescimoCalculado, 15));
  writeln('Juros = ' + real2str(jurosCalculado, 15));
end.
