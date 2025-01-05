{ Calculo dos juros, sendo que precisa de parcelas pra isso
  Versao 0.1: 05/01/2025: versao feita sem muito conhecimento de MSX Turbo Pascal }

program Juros;

const { constante com a quantidade de parcelas }
    cQuantidade = 3;

type { registro para simplificar as chamadas de funcao }
    rJuros = record
        Quantidade : integer;
        Composto : boolean;
        Periodo : real;
        Pagamentos : array [1..cQuantidade] of real;
        Pesos : array [1..cQuantidade] of real;
    end;

{ calcula a somatoria de Pesos[] }
function getPesoTotal(sJuros : rJuros) : real;
var
 	acumulador : real;
 	indice : integer;
begin
	acumulador := 0.0;
	for indice := 1 to sJuros.Quantidade do
		acumulador := acumulador + sJuros.Pesos[indice];
	getPesoTotal := acumulador;
end;

{ calcula o acrescimo a partir dos juros e dos dados comuns (como parcelas) }
function jurosParaAcrescimo(sJuros : rJuros; juros : real) : real;
var
    pesoTotal, acumulador, expoente, base: real;
    indice: integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if ((juros <= 0) or (sJuros.Quantidade <= 0) or (sJuros.Periodo <= 0.0) or (pesoTotal <= 0.0)) then
    begin
        jurosParaAcrescimo := 0.0;
        exit;
    end;

    acumulador := 0.0;

    for indice := 1 to sJuros.Quantidade do
    begin
        if (sJuros.Composto) then
        begin
            base := 1 + juros / 100;
            expoente := sJuros.Pagamentos[indice] / sJuros.Periodo;
            acumulador := acumulador + sJuros.Pesos[indice] / exp(expoente * ln(base));
        end else begin
            acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100 * sJuros.Pagamentos[indice] / sJuros.Periodo);
        end;
    end;

    if (acumulador <= 0.0)
        then jurosParaAcrescimo := 0.0
        else jurosParaAcrescimo := (pesoTotal / acumulador - 1) * 100;
end;

{ calcula os juros a partir do acrescimo e dos dados comuns (como parcelas) }
function acrescimoParaJuros(sJuros : rJuros; acrescimo : real; precisao, maxIteracoes : integer; maxJuros : real) : real;
var
    pesoTotal, minJuros, medJuros, minDiferenca : real;
    indice : integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if ((maxIteracoes < 1) or (sJuros.Quantidade <= 0) or (precisao < 1) or (sJuros.Periodo <= 0)) then
    begin
        acrescimoParaJuros := 0.0;
        exit;
    end;

    if ((acrescimo <= 0.0) or (maxJuros <= 0.0) or (pesoTotal <= 0.0)) then
    begin
        acrescimoParaJuros := 0.0;
        exit;
    end;

    minJuros := 0.0;
    medJuros := maxJuros / 2;
    minDiferenca := exp(precisao * ln(0.1));

    for indice := 1 to maxIteracoes do
    begin
        medJuros := (minJuros + maxJuros) / 2;
        if ((maxJuros - minJuros) < minDiferenca) then
        begin
            acrescimoParaJuros := 0.0;
            exit;
        end;
        if (jurosParaAcrescimo(sJuros, medJuros) < acrescimo)
            then minJuros := medJuros
            else maxJuros := medJuros;
    end;
    acrescimoParaJuros := medJuros;
end;

{ "main" }
var
    juros : rJuros;
    indice : integer;
    pesoTotal, acrescimo, juroscalculado : real;

begin
    { inicializa os valores do registro juros }
    juros.Quantidade := cQuantidade;
    Juros.Composto := true;
    juros.Periodo := 30.0;

    for indice := 1 to cQuantidade do
    begin
        juros.Pagamentos[indice] := 30.0 * indice;
        juros.Pesos[indice] := 1.0;
    end;

    { testa as funções }
    pesoTotal := getPesoTotal(juros);
    acrescimo := jurosParaAcrescimo(juros, 3.0);
    juroscalculado := acrescimoParaJuros(juros, acrescimo, 15, 100, 50.0);

    { imprime os resultados }
    Writeln('Peso total: ', pesoTotal:1:10);
    Writeln('Acrescimo: ', acrescimo:1:10);
    Writeln('Juros: ', juroscalculado:1:10);
end.
