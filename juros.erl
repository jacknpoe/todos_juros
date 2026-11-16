%% -*- coding: utf-8 -*-

-module(juros).

-moduledoc """
Cálculo dos juros, sendo que precisa de listas para isso.
Versão 0.1: 29/04/2024: completo, mas sem saber muito sobre Erlang
Versão 0.2: 07/05/2024: agora roda diretamente na linha de comando (main)
Versão 0.3: 16/11/2026: variáveis antes de fwrite; variáveis para configuração; acumulador em jurosParaAcrescimo; removidos casos especiais; cabeça e cauda no lugar de nth
                        Unicode; listas escaláveis criadas dinamicamente; funções recursivas alteradas para permitir Tail Call Optimization (TCO)
""".

-author("Ricardo Erick Rebêlo").
-import(math, [pow/2]).

%% API
-export([main/1]).

%% registro básico para simplificar as chamadas
-record( juros, {
  quantidade,
  composto,
  periodo,
  pagamentos,
  pesos
} ).

%% função açúcar que cria a lista pagamentos
criaPagamentos(Quantidade, Periodo) -> rCriaPagamentos(1, Quantidade, Periodo, []).

%% função recursiva que cria a lista pagamentos
rCriaPagamentos(Indice, Quantidade, Periodo, Acumulador) ->
  if Indice > Quantidade ->
    Acumulador;
  true ->
    rCriaPagamentos(Indice + 1, Quantidade, Periodo, [Indice * Periodo | Acumulador])
  end.

%% função açúcar que cria a lista pesos
criaPesos(Quantidade) -> rCriaPesos(1, Quantidade, []).

%% função recursiva que cria a lista pesos
rCriaPesos(Indice, Quantidade, Acumulador) ->
  if Indice > Quantidade ->
    Acumulador;
  true ->
    rCriaPesos(Indice + 1, Quantidade, [1.0 | Acumulador])
  end.

%% função açúcar que calcula a somatória de pesos
getPesoTotal(OJuros) -> rGetPesoTotal(OJuros#juros.pesos, 0.0).

%% função recursiva que calcula a somatória de pesos
rGetPesoTotal([], Acumulador) -> Acumulador;
rGetPesoTotal([HPes|TPes], Acumulador) -> rGetPesoTotal(TPes, HPes + Acumulador).

%% função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo(OJuros, Juros) ->
  if (Juros =< 0.0) orelse (OJuros#juros.quantidade < 1) orelse (OJuros#juros.periodo =< 0.0) ->
    0.0;
  true ->
    PesoTotal = getPesoTotal(OJuros),
    if PesoTotal =< 0.0 ->
      0.0;
    true ->
      Acumulador = if OJuros#juros.composto ->
        rJurosCompostos(OJuros, OJuros#juros.pagamentos, OJuros#juros.pesos, Juros, 0.0);
      true ->
        rJurosSimples(OJuros, OJuros#juros.pagamentos, OJuros#juros.pesos, Juros, 0.0)
      end,
      if Acumulador < 0.0 ->
        0.0;
      true ->
        (PesoTotal / Acumulador - 1.0) * 100.0
      end
    end
  end.

%% função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
rJurosCompostos(_, [], [], _, Acumulador) -> Acumulador;
rJurosCompostos(OJuros, [HPag|TPag], [HPes|TPes], Juros, Acumulador) ->
  rJurosCompostos(OJuros, TPag, TPes, Juros,HPes * pow(1.0 / (1.0 + Juros / 100.0), HPag / OJuros#juros.periodo) + Acumulador).

%% função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
rJurosSimples(_, [], [], _, Acumulador) -> Acumulador;
rJurosSimples(OJuros, [HPag|TPag], [HPes|TPes], Juros, Acumulador) ->
  rJurosSimples(OJuros, TPag, TPes, Juros, HPes / (1.0 + Juros / 100.0 * HPag / OJuros#juros.periodo) + Acumulador).

%% função açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros(OJuros, Acrescimo, Precisao, MaxIteracoes, MaxJuros) ->
  if (Acrescimo =< 0.0) orelse (OJuros#juros.quantidade < 1) orelse (OJuros#juros.periodo =< 0.0) orelse (MaxIteracoes < 1) orelse (Precisao < 1) orelse (MaxJuros =< 0.0) ->
    0.0;
  true ->
    PesoTotal = getPesoTotal(OJuros),
    if PesoTotal =< 0.0 ->
      0.0;
    true ->
      rAcrescimoParaJuros(OJuros, Acrescimo, pow(0.1, Precisao), MaxIteracoes, 0.0, MaxJuros, MaxJuros / 2.0)
    end
  end.

%% função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual, MinJuros, MaxJuros, MedJuros) ->
  if (IteracaoAtual == 0) orelse ((MaxJuros - MinJuros) =< MinDiferenca) ->
    MedJuros;
  true ->
    Calculado = jurosParaAcrescimo(OJuros, MedJuros),
    if Calculado < Acrescimo ->
      rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual - 1, MedJuros, MaxJuros, (MedJuros + MaxJuros) / 2.0);
    true ->
      rAcrescimoParaJuros(OJuros, Acrescimo, MinDiferenca, IteracaoAtual - 1, MinJuros, MedJuros, (MinJuros + MedJuros) / 2.0)
    end
  end.

main(_) ->
  %% configura o encoding como unicode (UTF-8)
  io:setopts(standard_io, [{encoding, unicode}]),

  %% variáveis para configurar o parcelamento
  Quantidade = 300000,
  Composto = true,
  Periodo = 30.0,
  Pagamentos = criaPagamentos(Quantidade, Periodo),
  Pesos = criaPesos(Quantidade),

  %% cria o objeto OJuros para simplificar as chamadas
  OJuros = #juros{quantidade = Quantidade, composto = Composto, periodo = Periodo, pagamentos = Pagamentos, pesos = Pesos},

  %% calcula e guarda os resultados das funções
  PesoTotal = getPesoTotal(OJuros),
  AcrescimoCalculado = jurosParaAcrescimo(OJuros, 3.0),
  JurosCalculado = acrescimoParaJuros(OJuros, AcrescimoCalculado, 18, 65, 50),

  %% imprime os resultados
  io:fwrite("Peso Total = ~f~n", [PesoTotal]),
  io:fwrite("Acréscimo = ~.18f~n", [AcrescimoCalculado]),
  io:fwrite("Juros = ~.18f~n", [JurosCalculado]).
