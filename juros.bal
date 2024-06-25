// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 25/06/2024: versão feita sem muito conhecimento de Ballerina

import ballerina/io;    // para imprimir os resultados
import ballerina/lang.'float;   // para pow()

// estrutura básica de propriedades para simplificar as chamadas
type Juros record {
    int Quantidade;
    boolean Composto;
    float Periodo;
    float[] Pagamentos;
    float[] Pesos;
};

// calcula a somatória do array Pesos[]
function getPesoTotal(Juros oJuros) returns float {
    float acumulador = 0.0f;
    int indice = 0;

    while(indice < oJuros.Quantidade) {
        acumulador += oJuros.Pesos[indice];
        indice += 1;
    }

    return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
function jurosParaAcrescimo(Juros oJuros, float juros) returns float {
    float pesoTotal = getPesoTotal(oJuros);
    if juros <= 0.0f || oJuros.Quantidade < 1 || oJuros.Periodo <= 0.0f || pesoTotal <= 0.0f { return 0.0f; }
    float acumulador = 0.0f;
    int indice = 0;

    while(indice < oJuros.Quantidade) {
        if oJuros.Composto {
            acumulador += oJuros.Pesos[indice] / 'float:pow(1.0f + juros / 100.0f, oJuros.Pagamentos[indice] / oJuros.Periodo);
        } else {
            acumulador += oJuros.Pesos[indice] / (1.0f + juros / 100.0f * oJuros.Pagamentos[indice] / oJuros.Periodo);
        }
        indice += 1;
    }

    return (pesoTotal / acumulador - 1.0f) * 100.0f;
}

// calcula os juros a partir do acréscimo e parcelas
function acrescimoParaJuros(Juros oJuros, float acrescimo, int precisao, int maxIteracoes, float maximoJuros) returns float {
    float pesoTotal = getPesoTotal(oJuros);
    if acrescimo <= 0.0f || oJuros.Quantidade < 1 || oJuros.Periodo <= 0.0f || pesoTotal <= 0.0f || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0f { return 0.0f; }
    float minJuros = 0.0f;
    float medJuros = maximoJuros / 2.0f;
    float maxJuros = maximoJuros;
    float minDiferenca = 'float:pow(0.1f, <float>precisao);
    int indice = 0;

    while(indice < maxIteracoes) {
        medJuros = (minJuros + maxJuros) / 2.0f;
        if (maxJuros - minJuros) < minDiferenca { return medJuros; }
        if jurosParaAcrescimo(oJuros, medJuros) < acrescimo {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
        indice += 1;
    }

    return medJuros;
}

public function main() {
    // cria um objeto oJuros do tipo Juros e inicializa os seus atributos
    Juros oJuros = {Quantidade: 3, Composto: true, Periodo: 30.0f, Pagamentos: [30.0f, 60.0f, 90.0f], Pesos: [1.0f, 1.0f, 1.0f]};

    // calcula e guarda o resultado das funções
    float pesoTotal = getPesoTotal(oJuros);
    float acrescimoCalculado = jurosParaAcrescimo(oJuros, 3.0f);
    float jurosCalculado = acrescimoParaJuros(oJuros, acrescimoCalculado, 15, 100, 50.0f);

    // imprime os resultados
    io:println("Peso total = ", pesoTotal);
    io:println("Acréscimo = ", acrescimoCalculado);
    io:println("Juros = ", jurosCalculado);

}
