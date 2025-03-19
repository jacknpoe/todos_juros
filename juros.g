# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 18/03/2025: versão feita sem muito conhecimento de GAP

# variáveis globais para simplificar as chamadas
Quantidade := 3;
Composto := true;
Periodo := 30.0;
Pagamentos := [];
Pesos := [];

# inicializa os arrays de forma dinâmica
for indice in [1..Quantidade] do
    Append(Pagamentos, [indice * Periodo]);
    Append(Pesos, [1.0]);
od;

# calcula a somatória de Pesos[]
getPesoTotal := function()
    local acumulador;
    acumulador := 0.0;
    for indice in [1..Quantidade] do
        acumulador := acumulador + Pesos[indice];
    od;
    return acumulador;
end;

# calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo := function(juros)
    local pesoTotal, acumulador;
    pesoTotal := getPesoTotal();
    if pesoTotal <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or juros <= 0.0 then return 0.0; fi;

    acumulador := 0.0;
    for indice in [1..Quantidade] do
        if Composto then
            acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0) ^ (Pagamentos[indice] / Periodo);
        else
            acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        fi;
    od;
    if acumulador <= 0.0 then return 0.0; fi;
    return (pesoTotal / acumulador - 1.0) * 100.0;
end;

# calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros := function(acrescimo, precisao, maxIteracoes, maxJuros)
    local pesoTotal, minJuros, medJuros, minDiferenca;
    pesoTotal := getPesoTotal();
    if pesoTotal <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros < 0.0 then return 0.0; fi;

    minJuros := 0.0;
    minDiferenca := 0.1 ^ precisao;
    for indice in [1..maxIteracoes] do
        medJuros := (minJuros + maxJuros) / 2.0;
        if (maxJuros - minJuros) < minDiferenca then return medJuros; fi;
        if jurosParaAcrescimo(medJuros) < acrescimo then minJuros := medJuros; else maxJuros := medJuros; fi;
    od;
    return medJuros;
end;

# calcula e guarda os resultados das funções
pesoTotal := getPesoTotal();
acrescimoCalculado := jurosParaAcrescimo(3.0);
jurosCalculado := acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

# imprime os resultados
Print("Peso total = ", pesoTotal, "\n");
Print("Acréscimo = ", acrescimoCalculado, "\n");
Print("Juros = ", jurosCalculado, "\n");