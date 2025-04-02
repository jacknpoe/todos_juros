% Cálculo dos juros, sendo que precisa de parcelas para isso
% Versão 0.1: 02/04/2025: versão feita sem muito conhecimento de FreeMat

% valores iniciais para melhor leitura e alterações
quantidade = 3
composto = true
periodo = 30.0
pagamentos = []
pesos = []

% inicia os arrays dinamicamente
for indice = 1 : quantidade
    pagamentos(indice) = indice * periodo;
    pesos(indice) = 1;
end

% cria um objeto juros da classe jurosFM
juros = jurosFM(quantidade, composto, periodo, pagamentos, pesos);

% calcula e guarda os resultados das funções
pesoTotal = getPesoTotalFM(juros);
acrescimoCalculado = jurosParaAcrescimoFM(juros, 3.0);
jurosCalculado = acrescimoParaJurosFM(juros, acrescimoCalculado, 15, 100, 50.0);

% imprime os resultados
printf('Peso total = %17.15f\n', pesoTotal);
printf('Acrescimo = %17.15f\n', acrescimoCalculado);
printf('Juros = %17.15f\n', jurosCalculado);