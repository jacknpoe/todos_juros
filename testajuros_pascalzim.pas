program testajuros ;

uses
    math;   // para ** funcionar

type
	// estrutura dos dados comuns
	rJuros = record
		Quantidade: integer;
		Composto: boolean;
		Periodo: real;
		Pagamentos: array [0..999] of real;
		Pesos: array [0..999] of real;
	end;

// calcula a somat�ria de pesos[]
function getPesoTotal(sJuros: rJuros): real;
var
 	acumulador: real;
 	indice: integer;
begin
	acumulador := 0.0;
	for indice := 0 to (sJuros.Quantidade - 1) do
		acumulador := acumulador + sJuros.Pesos[indice];
	getPesoTotal := acumulador;
end;

// calcula o acr�scimo a partir dos juros e dos dados comuns (como parcelas)
function jurosParaAcrescimo(sJuros: rJuros; juros: real): real;
var
    pesoTotal: real;
    acumulador: real;
    soZero: boolean;
    indice: integer;
begin
    if ((juros <= 0) or (sJuros.Quantidade <= 0) or (sJuros.Periodo <= 0.0)) then
    begin
	    jurosParaAcrescimo := 0.0;
			exit();
		end;
    pesoTotal := getPesoTotal(sJuros);
    if (pesoTotal <= 0.0) then
    begin
	    jurosParaAcrescimo := 0.0;
			exit();
		end;

    acumulador := 0.0;
    // soZero := true;

    for indice := 0 to (sJuros.Quantidade - 1) do
    begin
        // if ((sJuros.Pagamentos[indice] > 0.0) and (sJuros.Pesos[indice] > 0.0)) then soZero := false;
        if (sJuros.Composto)
        then acumulador := acumulador + sJuros.Pesos[indice] / exp((sJuros.Pagamentos[indice] / sJuros.Periodo) * ln(1 + juros / 100))
        else acumulador := acumulador + sJuros.Pesos[indice] / (1 + juros / 100 * sJuros.Pagamentos[indice] / sJuros.Periodo);
    end;

    // if (soZero) then exit(0.0);
    if (acumulador <= 0.0) then
    begin
	    jurosParaAcrescimo := 0.0;
			exit();
		end;

    jurosParaAcrescimo := (pesoTotal / acumulador - 1) * 100;
end;

// calcula os juros a partir do acr�scimo e dos dados comuns (como parcelas)
function acrescimoParaJuros(sJuros: rJuros; acrescimo: real; precisao, maxIteracoes: integer; maxJuros: real): real;
var
    pesoTotal, minJuros, medJuros, minDiferenca: real;
    indice: integer;
begin
    if ((maxIteracoes < 1) or (sJuros.Quantidade <= 0) or (precisao < 1) or (sJuros.Periodo <= 0) or (acrescimo <= 0.0) or (maxJuros <= 0.0)) then
    begin
	    acrescimoParaJuros := 0.0;
			exit();
		end;
    pesoTotal := getPesoTotal(sJuros);
    if (pesoTotal <= 0.0) then
    begin
	    acrescimoParaJuros := 0.0;
			exit();
		end;
    
    minJuros := 0.0;
    medJuros := maxJuros / 2;
    minDiferenca := exp( precisao * ln(0.1)) ;

    for indice := 1 to maxIteracoes do
    begin
        medJuros := (minJuros + maxJuros) / 2;
        if ((maxJuros - minJuros) < minDiferenca) then
  		  begin
		  	  acrescimoParaJuros := medJuros;
					exit();
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
	// defini��o dos dados
	juros.Quantidade := 3;
	juros.Composto := true;
	juros.Periodo := 30.0;
	// setlength(juros.Pagamentos, 3);
	juros.Pagamentos[0] := 30.0;
	juros.Pagamentos[1] := 60.0;
	juros.Pagamentos[2] := 90.0;
	// setlength(juros.Pesos, 3);
	juros.Pesos[0] := 1.0;
	juros.Pesos[1] := 1.0;
	juros.Pesos[2] := 1.0;

	// testes
	writeln('Soma dos pesos = ', getPesoTotal(juros));
	writeln('Acr�scimo = ', jurosParaAcrescimo(juros, 3.0));
	writeln('Juros = ', acrescimoParaJuros(juros, jurosParaAcrescimo(juros, 3.0), 15, 100, 50.0));
end.
