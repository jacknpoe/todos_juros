% limpa o ambiente e fecha tudo o que está aberto
clear all;
close all;

% juros.Quantidade = 3;
% juros.Composto = true;
% juros.Periodo = 30;
% juros.Pagamentos = [30, 60, 90];
% juros.Pesos = [1, 1, 1];

% essa linha cria juros e faz o que as cinco linhas comentadas acima fazem
juros = Juros(3, true, 30, [30,60,90], [1,1,1]);

% testes
pesoTotal = juros.getPesoTotal;
acrescimo = juros.jurosParaAcrescimo(3.0);
juroscalc = juros.acrescimoParaJuros(acrescimo, 15, 100, 50.0);
fprintf("O peso total é = %18.15d!\n", pesoTotal);
fprintf("O acréscimo é = %18.15d!\n", acrescimo);
fprintf("Os juros são = %18.15d!\n", juroscalc);