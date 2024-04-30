%%%-------------------------------------------------------------------
%%% @author Ricardo Erick Rebêlo
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% Cálculo do juros, sendo que precisa de listas pra isso
%%% Versão 0.1: 29/04/2024: completo, mas sem saber muito sobre Erlang
%%% @end
%%% Created : 29. abr. 2024 16:37
%%%-------------------------------------------------------------------
-module(juros).
-author("Ricardo Erick Rebêlo").
-import(math, [pow/2]).
-import(lists,[nth/2]).

%% API
-export([testajuros/0]).

%% registro básico para simplificar as chamadas
-record( juros, {
  quantidade,
  composto,
  periodo,
  pagamentos,
  pesos
} ).

%% calcula a somatória de pesos[]
getPesoTotal(OJuros) ->
  rGetPesoTotal(OJuros, OJuros#juros.quantidade).

%% função recursiva que realmente calcula a somatória de pesos[]
rGetPesoTotal(OJuros, Indice) ->
  if Indice == 1 ->
    nth(Indice, OJuros#juros.pesos);
  true ->
    nth(Indice, OJuros#juros.pesos) + rGetPesoTotal(OJuros, Indice-1)
  end.

%% calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo(OJuros, Juros) ->
  if (Juros =< 0.0) or (OJuros#juros.quantidade < 1) or (OJuros#juros.periodo =< 0.0) ->
    0.0;
  true ->
    PesoTotal = getPesoTotal(OJuros),
    if PesoTotal =< 0.0 ->
      0.0;
    true ->
      if OJuros#juros.composto ->
        (PesoTotal / rJurosCompostos(OJuros, OJuros#juros.quantidade, Juros) - 1.0) * 100.0;
      true ->
        (PesoTotal / rJurosSimples(OJuros, OJuros#juros.quantidade, Juros) - 1.0) * 100.0
      end
    end
  end.

%% calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos(OJuros, Indice, Juros) ->
  if Indice == 1 ->
    nth(Indice, OJuros#juros.pesos) / pow( 1.0 + Juros / 100.0, nth(Indice, OJuros#juros.pagamentos) / OJuros#juros.periodo);
  true ->
    nth(Indice, OJuros#juros.pesos) / pow( 1.0 + Juros / 100.0, nth(Indice, OJuros#juros.pagamentos) / OJuros#juros.periodo) + rJurosCompostos(OJuros, Indice - 1, Juros)
  end.

%% calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples(OJuros, Indice, Juros) ->
  if Indice == 1 ->
    nth(Indice, OJuros#juros.pesos) / (1.0 + Juros / 100.0 * nth(Indice, OJuros#juros.pagamentos) / OJuros#juros.periodo);
  true ->
    nth(Indice, OJuros#juros.pesos) / (1.0 + Juros / 100.0 * nth(Indice, OJuros#juros.pagamentos) / OJuros#juros.periodo) + rJurosSimples(OJuros, Indice - 1, Juros)
  end.

%% calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros(OJuros, Acrescimo, Precisao, MaxIteracoes, MaxJuros) ->
  if (Acrescimo =< 0.0) or (OJuros#juros.quantidade < 1) or (OJuros#juros.periodo =< 0.0) or (MaxIteracoes < 1) or (Precisao < 1) or (MaxJuros =< 0.0) ->
    0.0;
  true ->
    PesoTotal = getPesoTotal(OJuros),
    if PesoTotal =< 0.0 ->
      0.0;
    true ->
      rAcrescimoParaJuros(OJuros, Acrescimo, pow(0.1, Precisao), MaxIteracoes, 0.0, MaxJuros, MaxJuros / 2.0)
    end
  end.

%% função recursiva no lugar de um for que realmente calcula o acréscimo
rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual, MinJuros, MaxJuros, MedJuros) ->
  if (IteracaoAtual == 0) or ((MaxJuros - MinJuros) < MinDiferenca) ->
    MedJuros;
  true ->
    Calculado = jurosParaAcrescimo(OJuros, MedJuros),
    if Calculado < Acrescimo->
      rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual - 1, MedJuros, MaxJuros, (MedJuros + MaxJuros) / 2.0);
    true ->
      rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual - 1, MinJuros, MedJuros, (MinJuros + MedJuros) / 2.0)
    end
  end.

testajuros() ->
  %% cria o objeto OJuros para simplificar as chamadas
  OJuros = #juros{quantidade = 3, composto = true, periodo = 30.0, pagamentos = [30.0, 60.0, 90.0], pesos = [1.0, 1.0, 1.0]},

  %% testes
  PesoTotal = getPesoTotal(OJuros),
  io:fwrite("Peso Total = ~f~n", [PesoTotal]),
  Acrescimo = jurosParaAcrescimo(OJuros, 3.0),
  io:fwrite("Acréscimo = ~20.18f~n", [Acrescimo]),
  Juros = acrescimoParaJuros(OJuros, Acrescimo, 18, 100, 50),
  io:fwrite("Juros = ~20.18f~n", [Juros]).
