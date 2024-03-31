% limpa o ambiente e fecha tudo o que está aberto
clear all;
close all;

% juros.Quantidade = 3;
% juros.Composto = true;
% juros.Periodo = 30;
% juros.Pagamentos = [30, 60, 90];
% juros.Pesos = [1, 1, 1];

% essa linha cria juros e faz o que as cinco linhas comentdas acima fazem
juros = Juros(3, true, 30, [30,60,90], [1,1,1]);

% testes
pesoTotal = juros.getPesoTotal;
acrescimo = juros.jurosParaAcrescimo(3.0);
juroscalc = juros.acrescimoParaJuros(acrescimo, 15, 100, 50.0);
fprintf("O peso total é = %d!\n", pesoTotal);
fprintf("O acréscimo é = %d!\n", acrescimo);
fprintf("Os juros são = %d!\n", juroscalc);