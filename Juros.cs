using System;

public class Juros
{
    private int _quantidade;
    public bool Composto;
    public double Periodo;
    public double[] Pagamentos;
    public double[] Pesos;

    public int Quantidade{
        get { return _quantidade; }
        set {
            int quantidade = (value > 0) ? value : 0;
            _quantidade = quantidade;
            Pagamentos = new double[quantidade];
            Pesos = new double[quantidade];
        }
    }

    public Juros(int quantidade = 0, bool composto = false, double periodo = 30.0) {
        Quantidade = quantidade;    // perceba que irá usar o método SET para definir os arrays também
        Composto = composto;
        Periodo = periodo;
    }

    public double getPesoTotal(){
        double acumulador = 0;
        for(int indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
        return acumulador;
    }

    public double jurosParaAcrescimo(double juros) {
        if(juros == 0 || Quantidade == 0 || Periodo <= 0.0) return 0;
        double pesoTotal = getPesoTotal();
        if(pesoTotal == 0) return 0;
        double acumulador = 0;
        bool soZero = true;

        for(int indice = 0; indice < Quantidade; indice ++) {
            if(Pagamentos[indice] > 0.0 && Pesos[indice] > 0) soZero = false;
            if(Composto) {
                acumulador += Pesos[indice] / Math.Pow(1 + juros / 100, Pagamentos[indice] / Periodo);
            } else {
                acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo);
            }
        }

        if(soZero) return 0;
        return (pesoTotal / acumulador - 1) * 100;
    }

    public double acrescimoParaJuros(double acrescimo, int precisao = 15, int maxInteracoes = 100, double maxJuros = 50) {
        if(maxInteracoes < 1 || Quantidade == 0 || precisao < 1 || Periodo <= 0.0 || acrescimo <= 0 || maxJuros <= 0) return 0;
        double minJuros = 0, medJuros = 0, minDiferenca = Math.Pow(0.1, precisao), pesoTotal = getPesoTotal();
        if(pesoTotal == 0) return 0;

        for(int indice = 0; indice < maxInteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2;
            if((maxJuros - minJuros) < minDiferenca) break;
            if(jurosParaAcrescimo(medJuros) <= acrescimo){
                minJuros = medJuros; 
            } else {
                maxJuros = medJuros;
            }
        }

        return medJuros;
    }
}