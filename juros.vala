// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 14/06/2024: versão feita sem muito conhecimento de Vala
// PARA COMPILAR: valac --pkg gee-0.8 juros.vala

// classe com os astributos com a estrutura básica para simplificar as chamadas
public class Juros {
    int Quantidade = 0;
    bool Composto = false;
    double Periodo = 0.0;
    double[] Pagamentos;
    double[] Pesos;

    // construtor que inicializa os atributos
    public Juros(int quantidade, bool composto, double periodo, double[] pagamentos, double[] pesos) {
        this.Quantidade = quantidade;
        this.Composto = composto;
        this.Periodo = periodo;
        this.Pagamentos = pagamentos;
        this.Pesos = pesos;
    }

    // calcula a somatória de Pesos[]
    public double getPesoTotal() {
        double acumulador = 0.0;
        for (var indice = 0; indice < this.Quantidade; indice++) acumulador += this.Pesos[indice];
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    public double jurosParaAcrescimo(double juros) {
        double pesoTotal = this.getPesoTotal();
        if(juros <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
        double acumulador = 0.0;

        for (var indice = 0; indice < this.Quantidade; indice++) {
            if (this.Composto) {
                acumulador += this.Pesos[indice] / Math.pow(1.0 + juros / 100.0, this.Pagamentos[indice] / this.Periodo);
            } else {
                acumulador += this.Pesos[indice] / (1.0 + juros / 100.0 * this.Pagamentos[indice] / this.Periodo);
            }
        }

        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    public double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
        double pesoTotal = this.getPesoTotal();
        if(acrescimo <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0;
        double minJuros = 0.0;
        double medJuros = maxJuros / 2.0;
        double minDiferenca = Math.pow(0.1, precisao);

        for (var indice = 0; indice < maxIteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if((maxJuros - minJuros) < minDiferenca) return medJuros;
            if(this.jurosParaAcrescimo(medJuros) < acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }
        }

        return medJuros;
    }
}

void main (string[] args) {
	Intl.setlocale( LocaleCategory.ALL, "");

    // cria os arrays para enviar ao construtor
    double[] pagamentos = { 30.0, 60.0, 90.0 };
    double[] pesos = { 1.0, 1.0, 1.0 };

    // cria um objeto juros da classe Juros e inicializa os atributos
    Juros juros = new Juros(3, true, 30.0, pagamentos, pesos);

    // calcula e guarda os resultados dos métodos
    double pesoTotal = juros.getPesoTotal();
    double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
    double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

    // imprime os resultados
    print(@"Peso total = $(pesoTotal)\n");
    print(@"Acréscimo = $(acrescimoCalculado)\n");
    print(@"Juros = $(jurosCalculado)\n");
}