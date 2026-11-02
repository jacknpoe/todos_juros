% Cálculo do juros, sendo que precisa de arrays para isso
% Versão 0.1: 03/05/2024: completa
%        0.2: 03/02/2026: com initialization para swipl e halt em juros()
%        0.3: 03/02/2026: agora, com a ajuda do ChatGPT, roda também em Scryer Prolog
%                         alterações como tirar () de funções sem parênteses e troca de aspas duplas por aspas simples em strings
%                         para fazer rodar também em Scryer Prolog (rodava em SWI-Prolog porque ele era permissivo além da norma ISO)
%        0.4: 02/11/2026: corrigido AND (,) por OR (;) e colocados parênteses e acréscimo com acento
%                         corrigido acrescimoParaJuros, listas escaladas, casos especiais retirados, validações de parâmetros e cálculos
%                         funções recursivas alteradas para permitir Tail Call Optimization (TCO); desempenho pior em Scryer Prolog e melhor em SWI-Prolog

% dados gerais
juros :-
  Quantidade is 3,
  Composto is 1,
  Periodo is 30.0,
  criaPagamentos(Quantidade, Periodo, Pagamentos),
  criaPesos(Quantidade, Pesos),

  % testa as funções
  getPesoTotal(Pesos, PesoTotal),
  write('Peso total = '),
  write(PesoTotal), nl,
  jurosParaAcrescimo(Composto, Periodo, Pagamentos, Pesos, 3.0, Acrescimo),
  write('Acréscimo = '),
  write(Acrescimo), nl,
  acrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, 15, 100, 50.0, Juros),
  write('Juros = '),
  write(Juros), nl,
  halt.

% função açúcar que cria a lista Pagamentos
criaPagamentos(Indice, Periodo, Pagamentos) :- 
  rCriaPagamentos(Indice, Periodo, Pagamentos, []).

% função recursiva que cria a lista Pagamentos
rCriaPagamentos(Indice, Periodo, Pagamentos, Acumulador) :-
(
  (Indice == 0,
    Pagamentos = Acumulador)
  ;
  (Indice \= 0,
    Prazo is Indice * Periodo,
    NovoIndice is Indice - 1,
    NovoAcumulador = [Prazo|Acumulador],
    rCriaPagamentos(NovoIndice, Periodo, Pagamentos, NovoAcumulador)
  )
).

% função açúcar que cria a lista Pesos
criaPesos(Indice, Pesos) :-
  rCriaPesos(Indice, Pesos, []).

% função recursiva que cria a lista Pesos
rCriaPesos(Indice, Pesos, Acumulador) :-
(
  (Indice == 0,
    Pesos = Acumulador)
  ;
  (Indice \= 0,
    NovoIndice is Indice - 1,
    NovoAcumulador = [1.0|Acumulador],
    rCriaPesos(NovoIndice, Pesos, NovoAcumulador)
  )
).

% função açúcar que calcula a somatória de Pesos
getPesoTotal(Pesos, PesoTotal) :-
  rGetPesoTotal(Pesos, PesoTotal, 0.0).

% função recursiva que calcula a somatória de Pesos
rGetPesoTotal([], Acumulador, Acumulador).
rGetPesoTotal([PesosH|PesosT], PesoTotal, Acumulador) :-
  NovoAcumulador is PesosH + Acumulador,
  rGetPesoTotal(PesosT, PesoTotal, NovoAcumulador).

% função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo(Composto, Periodo, Pagamentos, Pesos, Juros, Acrescimo) :-
  getPesoTotal(Pesos, PesoTotal),
  (
    ((Periodo =< 0.0; PesoTotal =< 0.0; Juros =< 0.0),
      Acrescimo is 0.0)
    ;
    (
      (
        (Composto == 1,
          rJurosCompostos(Periodo, Pagamentos, Pesos, Juros, Amortecimento, 0.0))
        ;
        (Composto == 0,
          rJurosSimples(Periodo, Pagamentos, Pesos, Juros, Amortecimento, 0.0))
      ),
      (
        (Amortecimento =< 0.0,
          Acrescimo is 0.0)
        ;
        (Amortecimento > 0.0,
          Acrescimo is (PesoTotal / Amortecimento - 1.0) * 100)
      )
    )
  ).

% função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos(_, [], [], _, Acumulador, Acumulador).
rJurosCompostos(Periodo, [PagamentosH|PagamentosT], [PesosH|PesosT], Juros, Amortecimento, Acumulador) :-
(
  % NovoAcumulador is PesosH / (1.0 + Juros / 100.0) ** (PagamentosH / Periodo) + Acumulador,
  NovoAcumulador is PesosH * (1.0 + Juros / 100.0) ** (-(PagamentosH / Periodo)) + Acumulador,  
  rJurosCompostos(Periodo, PagamentosT, PesosT, Juros, Amortecimento, NovoAcumulador)
).
  
% função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples(_, [], [], _, Acumulador, Acumulador).
rJurosSimples(Periodo, [PagamentosH|PagamentosT], [PesosH|PesosT], Juros, Amortecimento, Acumulador) :-
(
  NovoAcumulador is PesosH / (1.0 + Juros / 100.0 * PagamentosH / Periodo) + Acumulador,
  rJurosSimples(Periodo, PagamentosT, PesosT, Juros, Amortecimento, NovoAcumulador)
).
  
% função açúcar que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
acrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, Precisao, MaxIteracoes, MaxJuros, Juros) :-
  getPesoTotal(Pesos, PesoTotal),
  (
    ((Periodo =< 0.0; PesoTotal =< 0.0; Acrescimo =< 0.0; Precisao < 1; MaxIteracoes < 1; MaxJuros =< 0.0),
      Juros is 0.0)
    ;
    (
      MinDiferenca is 0.1 ** Precisao,
      MedJuros is MaxJuros / 2.0,
      rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, MinDiferenca, MaxIteracoes, 0.0, MaxJuros, MedJuros, Juros)
    )
  ).

% função recursiva que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, MinDiferenca, IteracaoAtual, MinJuros, MaxJuros, MedJuros, Juros) :-
(
  ((IteracaoAtual == 0; (MaxJuros - MinJuros) =< MinDiferenca),
    Juros is MedJuros)
  ;
  (
    ProximaIteracao is IteracaoAtual - 1,
    jurosParaAcrescimo(Composto, Periodo, Pagamentos, Pesos, MedJuros, Calculado),
    (
      (Calculado < Acrescimo,
        NovoMedJuros is (MedJuros + MaxJuros) / 2.0,
        rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, MinDiferenca, ProximaIteracao, MedJuros, MaxJuros, NovoMedJuros, Juros))
      ;
      (Calculado >= Acrescimo,
        NovoMedJuros is (MinJuros + MedJuros) / 2.0,
        rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, MinDiferenca, ProximaIteracao, MinJuros, MedJuros, NovoMedJuros, Juros))
    )
  )
).

% executa com scryer-prolog juros.pl
% executa com swipl -q juros.pl
:- initialization(juros).
