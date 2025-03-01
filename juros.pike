// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 01/03/2025: versão feita sem muito conhecimento de Pike

// a classe tem propriedades para simplificar as chamadas às funções
class juros {
    int Quantidade;
    bool Composto;
    float Periodo;
    array(float) Pagamentos;
    array(float) Pesos;

    // o construtor inicializa as variáveis escalares e aloca os arrays
    void create(int q, bool c, float p) {
        Quantidade = q;
        Composto = c;
        Periodo = p;
        Pagamentos = allocate(q);
        Pesos = allocate(q);
    }

    // calcula a somatória de Pesos[]
    float getPesoTotal() {
        float acumulador = 0.0; int indice;
        for(indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    float jurosParaAcrescimo(float juros) {
        float pesoTotal = getPesoTotal(), acumulador = 0.0; int indice;
        if (pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || juros <= 0.0) return 0.0;

        for(indice = 0; indice < Quantidade; indice++) {
            if (Composto) acumulador += Pesos[indice] / pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
            else acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
        }

        if (acumulador <= 0.0) return 0.0;
        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e parcelas
    float acrescimoParaJuros(float acrescimo, int precisao, int maxIteracoes, float maxJuros) {
        float pesoTotal = getPesoTotal(), minJuros = 0.0, medJuros, minDiferenca = pow(0.1, precisao); int indice;
        if (pesoTotal <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;

        for(indice = 0; indice < maxIteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if ((maxJuros - minJuros) < minDiferenca) return medJuros;
            if (jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros; else maxJuros = medJuros;
        }

        return medJuros;
    }
}

int main()
{
    int indice; float pesoTotal, acrescimoCalculado, jurosCalculado;

    // cria um objeto oJuros da classe juros e inicializa as propriedades
    juros oJuros = juros(3, true, 30.0);
    for(indice = 0; indice < oJuros.Quantidade; indice++) {
        oJuros.Pagamentos[indice] = 30 * (indice + 1.0);
        oJuros.Pesos[indice] = 1.0;
    }

    // calcula e guarda os resultados dos métodos
    pesoTotal = oJuros.getPesoTotal();
    acrescimoCalculado = oJuros.jurosParaAcrescimo(3.0);
    jurosCalculado = oJuros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

    // imprime os resultados
    write(sprintf("Peso total = %2.5f\n", pesoTotal));
    write(sprintf("Acrescimo = %2.5f\n", acrescimoCalculado));
    write(sprintf("Juros = %2.5f\n", jurosCalculado));

    return 0;
}