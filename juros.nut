// Cálculo dos juros, sendo que precisa de arrays com as parcelas para isso
// Versão 0.1: 18/06/2024: versão feita sem muito conhecimento de Squirrel

// a função pow() de Squirrel só aceita bases inteiras.
function power(pbase, pexpoente) {
    return exp(pexpoente * log(pbase));
}

// classe com a estrutura básica para simplificar as camadas
class Juros {
    quantidade = null;
    composto = null;
    periodo = null;
    pagamentos = null;
    pesos = null;

    // o construtor inicializa todos os atributos
    constructor(qtd, cmp, per, pag, pes) {
        quantidade = qtd;
        composto = cmp;
        periodo = per;
        pagamentos = pag;
        pesos = pes;
    }

    // calcula a somatória de pesos[]
    function getPesoTotal() {
        local acumulador = 0.0
        for (local indice = 0; indice < quantidade; indice += 1) {
            acumulador += pesos[indice];
        }
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    function jurosParaAcrescimo(juros) {
        local pesoTotal = getPesoTotal();
        if (juros <= 0.0 || quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0) {
            return 0.0;
        }
        local acumulador = 0.0

        for (local indice = 0; indice < quantidade; indice += 1) {
            if (composto) {
                acumulador += pesos[indice] / power(1.0 + juros / 100.0, pagamentos[indice] / periodo);
            } else {
                acumulador += pesos[indice] / (1.0 + juros / 100.0 * pagamentos[indice] / periodo);
            }
        }

        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e parcelas
    function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
        local pesoTotal = getPesoTotal();
        if (acrescimo <= 0.0 || quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) {
            return 0.0;
        }
        local minJuros = 0.0;
        local medJuros = maxJuros / 2.0;
        local minDiferenca = power(0.1, precisao);

        for (local indice = 0; indice < maxIteracoes; indice += 1) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if((maxJuros - minJuros) < minDiferenca) {
                return medJuros;
            }
            if(jurosParaAcrescimo(medJuros) < acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }
        }

        return medJuros;
    }
}

// cria um objeto local juros da classe Juros e inicializa as propriedades
local juros = Juros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0]);

// calcula e guarda os resultados dos métodos
local pesoTotal = juros.getPesoTotal();
local acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
local jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

// imprime os resultados
print(format("Peso total = %.15f!\n", pesoTotal));
print(format("Acréscimo = %.15f!\n", acrescimoCalculado));
print(format("Juros = %.15f!\n", jurosCalculado));
