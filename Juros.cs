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
        Pagamentos = new double[quantidade];    // para aplacar o compilador
        Pesos = new double[quantidade];    // para aplacar o compilador
        Quantidade = quantidade;    // perceba que irá usar o método SET para definir os arrays também
        Composto = composto;
        Periodo = periodo;
    }

    public double getPesoTotal(){
        double acumulador = 0.0;
        for(int indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
        return acumulador;
    }

    public double jurosParaAcrescimo(double juros) {
        if(juros <= 0.0 || Quantidade == 0 || Periodo <= 0.0) return 0.0;
        double pesoTotal = getPesoTotal();
        if(pesoTotal == 0) return 0.0;
        double acumulador = 0.0;

        for(int indice = 0; indice < Quantidade; indice ++) {
            if(Composto) {
                acumulador += Pesos[indice] / Math.Pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo);
            } else {
                acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);
            }
        }

        if (acumulador <= 0 ) return 0.0;
        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    public double acrescimoParaJuros(double acrescimo, int precisao = 15, int maxInteracoes = 65, double maxJuros = 50.0) {
        if(maxInteracoes < 1 || Quantidade == 0 || precisao < 1 || Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0) return 0.0;
        double minJuros = 0.0, medJuros = (minJuros + maxJuros) / 2.0, minDiferenca = Math.Pow(0.1, precisao), pesoTotal = getPesoTotal();
        if(pesoTotal == 0) return 0.0;

        for(int indice = 0; indice < maxInteracoes; indice++) {
            if((maxJuros - minJuros) < minDiferenca) break;
            if(jurosParaAcrescimo(medJuros) <= acrescimo){
                minJuros = medJuros; 
            } else {
                maxJuros = medJuros;
            }
            medJuros = (minJuros + maxJuros) / 2.0;
        }

        return medJuros;
    }
}