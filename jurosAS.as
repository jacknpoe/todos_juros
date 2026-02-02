// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 02/02/2026: versão feita sem muito conhecimento de AngelScript

// classe com atriburos para simplificar as fumções
class Juros {
    int quantidade;
    bool composto;
    double periodo;
    array<double> pagamentos;
    array<double> pesos;

    // calcula a somatória dos elementos de pesos[]
    double getPesoTotal() {
        double acumulador = 0.0;

        for (int indice = 0; indice < quantidade; indice++) acumulador += pesos[indice];
        
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    double jurosParaAcrescimo(double juros) {
        double pesoTotal = getPesoTotal();
        if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) return 0.0;
        double acumulador = 0.0;

        for (int indice = 0; indice < quantidade; indice++)
            if (composto) {
                acumulador += pesos[indice] / pow(1.0 + juros / 100.0, pagamentos[indice] / periodo);
            } else {
                acumulador += pesos[indice] / (1.0 + juros / 100.0 * pagamentos[indice] / periodo);
            }
        
        if (acumulador <= 0.0) return 0.0;
        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e parcelas
    double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
        double pesoTotal = getPesoTotal();
        if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
        double minJuros = 0.0;
        double medJuros = maxJuros / 2.0;
        double minDiferenca = pow(0.1, precisao);

        for (int indice = 0; indice < maxIteracoes; indice++) {
            if (maxJuros - minJuros < minDiferenca) return medJuros;
            if (jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros; else maxJuros = medJuros;
            medJuros = (minJuros + maxJuros) / 2.0;
        }

        return medJuros;
    }
};

void main() {
     Juros juros;  // Juros é um objeto da classe juros

    // inicializa os atributos escalares
    juros.quantidade = 3;
    juros.composto = true;
    juros.periodo = 30.0;

    // inicializa dinamicamente os arrays
    for (int indice = 0; indice < juros.quantidade; indice++) {
        juros.pagamentos.insertLast(juros.periodo * double(indice + 1.0));
        juros.pesos.insertLast(1.0);
    }

    // chama e guarda os resultados dos métodos
    double pesoTotal = juros.getPesoTotal();
    double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
    double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 7, 35, 50.0);

    // imprime os resultados
    print("Peso total = "); printDouble(pesoTotal); print("\n");
    print("Acréscimo = "); printDouble(acrescimoCalculado); print("\n");
    print("Juros = "); printDouble(jurosCalculado); print("\n");
}
