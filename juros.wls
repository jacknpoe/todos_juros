#!/usr/bin/env wolframscript
(* ::Package:: *)

(* C\[AAcute]lculo dos juros, sendo que precisa de parcelas pra isso *)
(* Vers\[ATilde]o 0.1: 22/07/2024: in\[IAcute]cio da vers\[ATilde]o feita sem muito conhecimento de WolframScript *)

(* dados globais para a simplifica\[CCedilla]\[ATilde]o das chamadas *)
Quantidade = 3;
Composto = True;
Periodo = 30.0;
Pagamentos = {30.0, 60.0, 90.0};
Pesos = {1.0, 1.0, 1.0};


(* calcula a somat\[OAcute]ria do array Pesos[] *)
getPesoTotal[] := (
	acumulador = 0.0;
	For[indice = 1, indice <= Quantidade, indice++, acumulador += Pesos[[indice]]];
	Return[acumulador];
)


(* calcula o acr\[EAcute]scimo a partir dos juros e parcelas *)
jurosParaAcrescimo[juros_] := (
	pesoTotal = getPesoTotal[];
	If[juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0, 0.0,
		acumulador = 0.0;
		For[indice = 1, indice <= Quantidade, indice++,
			If[Composto,
				acumulador += Pesos[[indice]] / Power[1.0 + juros / 100.0, Pagamentos[[indice]] / Periodo],
				acumulador += Pesos[[indice]] / (1.0 + juros / 100.0 * Pagamentos[[indice]] / Periodo)
			];
		];
		(pesoTotal / acumulador - 1.0) * 100.0
	]
)


(* calcula os juros a partir do acr\[EAcute]scimo e parcelas *)
acrescimoParaJuros[acrescimo_, precisao_, maxIteracoes_, maximoJuros_] := (
  	pesoTotal = getPesoTotal[];
  	If[acrescimo <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0, return  0.0, minJuros = 0.0];
  	medJuros = maximoJuros / 2.0;
  	maxJuros = maximoJuros;
  	minDiferenca = Power[0.1, precisao];
  	For[indice = 0, indice < maxIteracoes, indice++,
   		medJuros = (minJuros + maxJuros) / 2.0;
   		If[(maxJuros - minJuros) < minDiferenca, return medJuros,
   			If[jurosParaAcrescimo[medJuros] < acrescimo, minJuros = medJuros, maxJuros = medJuros]
   		];
   	];
  	medJuros
  )


(* calcula e guarda os resultados das fun\[CCedilla]\[OTilde]es *)
pesoTotal = getPesoTotal[];
acrescimoCalculado = jurosParaAcrescimo[3.0];
jurosCalculado = acrescimoParaJuros[acrescimoCalculado, 15.0, 100, 50.0];


(* imprime os resultados *)
Print["Peso total = ", NumberForm[pesoTotal, {17, 15}]];
Print["Acr\[EAcute]scimo = ", NumberForm[acrescimoCalculado, {17, 15}]];
Print["Juros = ", NumberForm[jurosCalculado, {17, 15}]];



