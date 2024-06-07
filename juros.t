% Calculo do juros, sendo que precisa de arrays pra isso
% Versao 0.1: 26/03/2024: versao feita sem muito conhecimento de Turing

% estrutura basica para simplificar as chamadas (inicializa Quantidade, Composto e Periodo)
var Quantidade: int := 3
var Composto: boolean := true
var Periodo: real := 30.0
var Pagamentos: array 1 .. Quantidade of real
var Pesos: array 1 .. Quantidade of real

% calcula a somatoria de Pesos()
function getPesoTotal : real
    var acumulador: real := 0.0
    for indice : 1 .. Quantidade
	acumulador += Pesos(indice)
    end for
    result acumulador
end getPesoTotal

% calcula o acrescimo a partir dos juros e parcelas
function jurosParaAcrescimo (juros: real) : real
    var pesoTotal : real := getPesoTotal
    if juros <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 then
	result 0.0
    end if
    var acumulador : real := 0.0
    
    for indice : 1 .. Quantidade
	if Composto then
	    acumulador += Pesos(indice) / (1.0 + juros / 100.0) ** (Pagamentos(indice) / Periodo)
	else
	    acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
	end if
    end for
    
    result (pesoTotal / acumulador - 1.0) * 100.0 
end jurosParaAcrescimo

% calcula os juros a partir do acrescimo e parcelas
function acrescimoParaJuros (acrescimo: real, precisao: int, maxIteracoes: int, maximoJuros: real) : real
    var pesoTotal : real := getPesoTotal
    if acrescimo <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maximoJuros <= 0.0 then
	result 0.0
    end if
    var minJuros: real := 0.0
    var medJuros: real := maximoJuros / 2.0
    var maxJuros: real := maximoJuros
    var minDiferenca: real := 0.1 ** precisao
    
    for indice : 1 .. maxIteracoes
	medJuros := (minJuros + maxJuros) / 2.0
	if (maxJuros - minJuros) < minDiferenca then
	    result medJuros
	end if
	if jurosParaAcrescimo(medJuros) < acrescimo then
	    minJuros := medJuros
	else
	    maxJuros := medJuros
	end if
    end for
    
    result medJuros
end acrescimoParaJuros

% inicializa os arrays Pagamentos() e Pesos()
for indice : 1 .. Quantidade
    Pagamentos(indice) := 30.0 * indice
    Pesos(indice) := 1.0
end for

% guarda os resultados de chamadas as funcoes
var pesoTotal := getPesoTotal
var acrescimoCalculado := jurosParaAcrescimo(3.0)
var jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

% imprime os resultados
put "Peso total = ", frealstr(pesoTotal, 17, 15)
put "Acrescimo = ", frealstr(acrescimoCalculado, 17, 15)
put "Juros = ", frealstr(jurosCalculado, 17, 15)
