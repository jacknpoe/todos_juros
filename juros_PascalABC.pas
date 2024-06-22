// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 22/06/2024: versão feita sem muito conhecimento de PascalABC

program juros_PascalABC;

type
	// estrutura dos dados comuns
	rJuros = record
		Quantidade: integer;
		Composto: boolean;
		Periodo: real;
		Pagamentos: array of real;
		Pesos: array of real;
	end;

// calcula a somatoria de pesos[]
function getPesoTotal(sJuros: rJuros): real;
var
 	acumulador: real;
begin
	acumulador := 0.0;
	for var indice := 0 to (sJuros.Quantidade - 1) do
		acumulador := acumulador + sJuros.Pesos[indice];
	getPesoTotal := acumulador;
end;

// calcula o acrescimo a partir dos juros e dos dados comuns (como parcelas)
function jurosParaAcrescimo(sJuros: rJuros; juros: real): real;
var
    pesoTotal: real;
    acumulador: real;
begin
    if (((juros <= 0) or (sJuros.Quantidade <= 0)) or (sJuros.Periodo <= 0.0)) then
    begin
      jurosParaAcrescimo := 0.0;
      exit;
    end;
    pesoTotal := getPesoTotal(sJuros);
    if (pesoTotal <= 0.0) then
    begin
      jurosParaAcrescimo := 0.0;
      exit;
    end;
    acumulador := 0.0;

    for var indice := 0 to (sJuros.Quantidade - 1) do
    begin
        if (sJuros.Composto)
        then acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100) ** (sJuros.Pagamentos[indice] / sJuros.Periodo)
        else acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100 * sJuros.Pagamentos[indice] / sJuros.Periodo);
    end;

    if (acumulador <= 0.0) then
    begin
      jurosParaAcrescimo := 0.0;
      exit;
    end;
    jurosParaAcrescimo := (pesoTotal / acumulador - 1) * 100;
end;

// calcula os juros a partir do acrescimo e dos dados comuns (como parcelas)
function acrescimoParaJuros(sJuros: rJuros; acrescimo: real; precisao, maxIteracoes: integer; maxJuros: real): real;
var
    pesoTotal, minJuros, medJuros, minDiferenca: real;
begin
    if ((maxIteracoes < 1) or (sJuros.Quantidade <= 0) or (precisao < 1) or (sJuros.Periodo <= 0) or (acrescimo <= 0.0) or (maxJuros <= 0.0)) then
    begin
      acrescimoParaJuros := 0.0;
      exit;
    end;
    pesoTotal := getPesoTotal(sJuros);
    if (pesoTotal <= 0.0) then
    begin
      acrescimoParaJuros := 0.0;
      exit;
    end;
    minJuros := 0.0;
    medJuros := maxJuros / 2;
    minDiferenca := 0.1 ** precisao;

    for var indice := 1 to maxIteracoes do
    begin
        medJuros := (minJuros + maxJuros) / 2;
        if ((maxJuros - minJuros) < minDiferenca) then
        begin
          acrescimoParaJuros := medJuros;
          exit;
        end;
        if (jurosParaAcrescimo(sJuros, medJuros) < acrescimo)
            then minJuros := medJuros
            else maxJuros := medJuros;
    end;
    acrescimoParaJuros := medJuros;
end;

var
	juros: rJuros;

begin
	// definicao dos dados
	juros.Quantidade := 3;
	juros.Composto := true;
	juros.Periodo := 30.0;
	setlength(juros.Pagamentos, 3);
	juros.Pagamentos[0] := 30.0;
	juros.Pagamentos[1] := 60.0;
	juros.Pagamentos[2] := 90.0;
	setlength(juros.Pesos, 3);
	juros.Pesos[0] := 1.0;
	juros.Pesos[1] := 1.0;
	juros.Pesos[2] := 1.0;

	// testes
	writeln('Soma dos pesos = ', getPesoTotal(juros));
	writeln('Acrescimo = ', jurosParaAcrescimo(juros, 3.0));
	writeln('Juros = ', acrescimoParaJuros(juros, jurosParaAcrescimo(juros, 3.0), 15, 100, 50.0));
end.
