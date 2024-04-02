% Classe para cálculo do juros, sendo que precisa de arrays pra isso
% Versão 0.1: 31/03/2024: versão feita a partir de pesquisas no Google

classdef Juros
    properties
        Quantidade uint16 = 0;
        Composto logical = false;
        Periodo double = 0.0;
        Pagamentos double = [];
        Pesos double = [];
    end

    methods
        % Construtor
        function obj = Juros(quantidade, composto, periodo, pagamentos, pesos)
            obj.Quantidade = quantidade;
            obj.Composto = composto;
            obj.Periodo = periodo;
            obj.Pagamentos = pagamentos;
            obj.Pesos = pesos;
        end

        % calcula a somatória de Pesos[]
        function pesoTotal = getPesoTotal(obj)
            acumulador = 0.0;
            for indice = 1 : obj.Quantidade
                acumulador = acumulador + obj.Pesos(indice);
            end
            pesoTotal = acumulador;
        end

        % calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
        function acrescimo = jurosParaAcrescimo(obj, juros)
            if juros <= 0.0 | obj.Quantidade <= 0 | obj.Periodo <= 0.0
                acrescimo = 0.0;
                return;
            end
            pesoTotal = obj.getPesoTotal;
            if pesoTotal <= 0.0
                acrescimo = 0.0;
                return;
            end
            acumulador = 0.0;
            soZero = true;

            for indice = 1 : obj.Quantidade
                if obj.Pagamentos(indice) >= 0 & obj.Pesos(indice) >= 0
                    soZero = false;
                end
                if obj.Composto
                    acumulador = acumulador + obj.Pesos(indice) / (1 + juros / 100) ^ (obj.Pagamentos(indice) / obj.Periodo);
                else
                    acumulador = acumulador + obj.Pesos(indice) / (1 + juros / 100 * obj.Pagamentos(indice) / obj.Periodo);
                end
            end

            if soZero
                acrescimo = 0.0;
                return;
            end
            acrescimo = (pesoTotal / acumulador - 1) * 100;
        end

        % calcula os juros a partir do acréscimo e dados comuns (como parcelas)
        function juros = acrescimoParaJuros(obj, acrescimo, precisao, maxIteracoes, maxJuros)
            if maxIteracoes < 1 | obj.Quantidade < 1 | precisao < 1 | obj.Periodo <= 0.0 | acrescimo <= 0.0 | maxJuros <= 0.0
                juros = 0.0;
                return;
            end
            pesoTotal = obj.getPesoTotal;
            if pesoTotal <= 0.0
                juros = 0.0;
                return;
            end
            minJuros = 0.0;
            medJuros = maxJuros / 2;
            minDiferenca = 0.1 ^ precisao;

            for indice = 1 : maxIteracoes
                medJuros = (minJuros + maxJuros) / 2;
                if (maxJuros - minJuros) < minDiferenca
                    juros = medJuros;
                    return;
                end
                if obj.jurosParaAcrescimo(medJuros) < acrescimo
                    minJuros = medJuros;
                else
                    maxJuros = medJuros;
                end
            end

            juros = medJuros;
        end
    end
end
