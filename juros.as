-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 30/07/2026: versão feita sem muito conhecimento de Aldor

#include "aldor"
#include "aldorio"

import from Boolean, MachineInteger;

-- variáveis globais para simplificar as chamadas às funções
Quantidade: MachineInteger := 3;
Composto: Boolean := true;
Periodo: DoubleFloat := 30.0;
Pagamentos: Array DoubleFloat := new(Quantidade, 0.0);
Pesos: Array DoubleFloat := new(Quantidade, 0.0);

-- as listas são inicializadas dinamicamente
for indice: MachineInteger in 0..Quantidade-1 repeat {
    Pagamentos(indice) := (indice::DoubleFloat + 1.0) * Periodo;
    Pesos(indice) := 1.0;
}

-- calcula a somatória de Pesos()
getPesoTotal(): DoubleFloat == {
    acumulador: DoubleFloat := 0.0;
    for indice: MachineInteger in 0..Quantidade-1 repeat acumulador := acumulador + Pesos(indice);
    return acumulador;
}

-- calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo(juros: DoubleFloat): DoubleFloat == {
    local pesoTotal: DoubleFloat := getPesoTotal();
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then return 0.0;

    local acumulador: DoubleFloat := 0.0;
    for indice: MachineInteger in 0..Quantidade-1 repeat {
        if Composto then acumulador := acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
                    else acumulador := acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo);
    }

    if acumulador <= 0.0 then return 0.0;
    return (pesoTotal / acumulador - 1.0) * 100.0;
}

-- calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros(acrescimo: DoubleFloat, precisao: MachineInteger, maxIteracoes: MachineInteger, maxJuros: DoubleFloat): DoubleFloat == {
    local pesoTotal: DoubleFloat := getPesoTotal();
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then return 0.0;

    minJuros: DoubleFloat := 0.0;
    medJuros: DoubleFloat := medJuros / 2.0;
    minDiferenca: DoubleFloat := 0.1 ^ precisao;
    for indice: MachineInteger in 1..maxIteracoes repeat {
        if maxJuros - minJuros < minDiferenca then return medJuros;
        if jurosParaAcrescimo(medJuros) < acrescimo then minJuros := medJuros else maxJuros := medJuros;
        medJuros := (minJuros + maxJuros) / 2.0;
    }
    return medJuros;
}

-- calcula e guarda os resultados das funções
pesoTotal: DoubleFloat := getPesoTotal();
acrescimoCalculado: DoubleFloat := jurosParaAcrescimo(3.0);
jurosCalculado: DoubleFloat := acrescimoParaJuros(acrescimoCalculado, 15, 56, 50.0);

-- imprime os resultados
stdout << "Peso total = " << pesoTotal << newline;
stdout << "Acrescimo = " << acrescimoCalculado << newline;
stdout << "Juros = " << jurosCalculado << newline;