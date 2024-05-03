% Cálculo do juros, sendo que precisa de arrays para isso
% Versão 0.1: 03/05/2024: completa
% dados gerais
juros() :-
%  Quantidade is 3,  % Quantidade ficaria no caminho das três primeiras recursões
  Composto is 1,
  Periodo is 30.0,
  Pagamentos = [30.0, 60.0, 90.0],
  Pesos = [1.0, 1.0, 1.0],
  % testa as funções
  getPesoTotal(Pesos, PesoTotal),
  write("Peso total = "),
  write(PesoTotal), nl,
  jurosParaAcrescimo(Composto, Periodo, Pagamentos, Pesos, 3.0, Acrescimo),
  write("Acréscimo = "),
  write(Acrescimo), nl,
  acrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, 15, 100, 50.0, Juros),
  write("Juros = "),
  write(Juros), nl.


% função recursiva que calcula a somatória de pesos[]
getPesoTotal([PesosH|PesosT], PesoTotal) :-
  (
    (PesosT == [], PesoTotal is PesosH)
    ;
    (PesosT \= [], getPesoTotal(PesosT, PesoTotal1), PesoTotal is PesosH + PesoTotal1)
  ).

% calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo(Composto, Periodo, Pagamentos, Pesos, Juros, Acrescimo) :-
  getPesoTotal(Pesos, PesoTotal),
  (
    (Composto == 1,
      rJurosCompostos(Periodo, Pagamentos, Pesos, Juros, Amortecimento),
      Acrescimo is (PesoTotal / Amortecimento - 1.0) * 100 )
    ;
    (Composto == 0,
      rJurosSimples(Periodo, Pagamentos, Pesos, Juros, Amortecimento),
      Acrescimo is (PesoTotal / Amortecimento - 1.0) * 100 )
  ).

% calcula a soma do amortecimento de todas as parcelas para juros compostos
rJurosCompostos(Periodo, [PagamentosH|PagamentosT], [PesosH|PesosT], Juros, Amortecimento) :-
  (
    (PesosT == [], Amortecimento is PesosH / (1.0 + Juros / 100.0) ^ (PagamentosH / Periodo))
    ;
    (PesosT \= [], rJurosCompostos(Periodo, PagamentosT, PesosT, Juros, Amortecimento1),
      Amortecimento is PesosH / (1.0 + Juros / 100.0) ^ (PagamentosH / Periodo) + Amortecimento1)
  ).
  
% calcula a soma do amortecimento de todas as parcelas para juros simples
rJurosSimples(Periodo, [PagamentosH|PagamentosT], [PesosH|PesosT], Juros, Amortecimento) :-
  (
    (PesosT == [], Amortecimento is PesosH / (1.0 + Juros / 100.0 * PagamentosH / Periodo))
    ;
    (PesosT \= [], rJurosSimples(Periodo, PagamentosT, PesosT, Juros, Amortecimento1),
      Amortecimento is PesosH / (1.0 + Juros / 100.0 * PagamentosH / Periodo) + Amortecimento1)
  ).
  
% calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, Precisao, MaxIteracoes, MaxJuros, Juros) :-
  rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, 0.1 ^ Precisao, MaxIteracoes, 0.0, MaxJuros, MaxJuros / 2.0, Juros).

% função recursiva no lugar de um for que realmente calcula o acréscimo
rAcrescimoParaJuros(Composto, Periodo, Pagamentos, Pesos, Acrescimo, MinDiferenca, IteracaoAtual, MinJuros, MaxJuros, MedJuros, Juros) :-
  (
    (IteracaoAtual == 0; (MaxJuros - MinJuros) < MinDiferenca, Juros is MedJuros)
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
