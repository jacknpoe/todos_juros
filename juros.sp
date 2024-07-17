{ Cálculo do juros, sendo que precisa de arrays pra isso
  Versão 0.1: 16/07/2024: versão feita sem muito conhecimento de SuperPascal }
program juros(input, output);
const
	QUANT = 1000;
type
	{ estrutura dos dados comuns }
	parcelas = array [1..QUANT] of real;
	rJuros = record
		Quantidade: integer;
		Composto: boolean;
		Periodo: real;
		Pagamentos: parcelas;
		Pesos: parcelas;
	end;
var
	juros: rJuros;
    pesoTotal, acrescimoCalculado, jurosCalculado: real;

{ calcula a somatória de pesos[] }
function getPesoTotal(sJuros: rJuros): real;
var
 	acumulador: real;
 	indice: integer;
begin
	acumulador := 0.0;
	for indice := 1 to (sJuros.Quantidade) do acumulador := acumulador + sJuros.Pesos[indice];
	getPesoTotal := acumulador;
end;

{ calcula o acréscimo a partir dos juros e dos dados comuns (como parcelas) }
function jurosParaAcrescimo(sJuros: rJuros; juros: real): real;
var
    pesoTotal: real;
    acumulador: real;
    indice: integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if ((juros <= 0.0) or (sJuros.Quantidade <= 0) or (sJuros.Periodo <= 0.0) or (pesoTotal <= 0.0)) then
	    jurosParaAcrescimo := 0.0
	else begin
		acumulador := 0.0;

		for indice := 1 to (sJuros.Quantidade) do
			if (sJuros.Composto) then acumulador := acumulador + sJuros.Pesos[indice] / exp((sJuros.Pagamentos[indice] / sJuros.Periodo) * ln(1.0 + juros / 100.0))
			else acumulador := acumulador + sJuros.Pesos[indice] / (1.0 + juros / 100.0 * sJuros.Pagamentos[indice] / sJuros.Periodo);

		jurosParaAcrescimo := (pesoTotal / acumulador - 1.0) * 100.0;
	end;
end;

{ calcula os juros a partir do acréscimo e dos dados comuns (como parcelas) }
function acrescimoParaJuros(sJuros: rJuros; acrescimo: real; precisao, maxIteracoes: integer; maxJuros: real): real;
var
    pesoTotal, minJuros, medJuros, minDiferenca: real;
    indice: integer;
begin
    pesoTotal := getPesoTotal(sJuros);
    if ((maxIteracoes < 1) or (sJuros.Quantidade <= 0) or (precisao < 1) or (sJuros.Periodo <= 0) or (acrescimo <= 0.0) or (maxJuros <= 0.0) or (pesoTotal <= 0.0)) then
	    acrescimoParaJuros := 0.0
	else begin
		minJuros := 0.0;
		medJuros := maxJuros / 2.0;
		minDiferenca := exp( precisao * ln(0.1));
		indice := 0;

		while indice < maxIteracoes do
		begin
			medJuros := (minJuros + maxJuros) / 2.0;
			if ((maxJuros - minJuros) < minDiferenca) then indice := maxIteracoes;
			if (jurosParaAcrescimo(sJuros, medJuros) < acrescimo) then minJuros := medJuros
			else maxJuros := medJuros;
			indice := indice + 1;
		end;
		acrescimoParaJuros := medJuros;
	end;
end;

begin
	{ definição dos dados }
	juros.Quantidade := 3;
	juros.Composto := true;
	juros.Periodo := 30.0;
	{setlength(juros.Pagamentos, 3);}
	juros.Pagamentos[1] := 30.0;
	juros.Pagamentos[2] := 60.0;
	juros.Pagamentos[3] := 90.0;
	{setlength(juros.Pesos, 3);}
	juros.Pesos[1] := 1.0;
	juros.Pesos[2] := 1.0;
	juros.Pesos[3] := 1.0;

	{ calcula e guarda os resultados das funções }
    pesoTotal := getPesoTotal(juros);
    acrescimoCalculado := jurosParaAcrescimo(juros, 3.0);
    jurosCalculado := acrescimoParaJuros(juros, acrescimoCalculado, 15, 100, 50.0);

    { testes e impressão }
	writeln('Soma dos pesos = ', pesoTotal:1:15);
	writeln('Acrescimo = ', acrescimoCalculado:1:15);
	writeln('Juros = ', jurosCalculado:1:15);
end.