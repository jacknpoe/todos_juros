// #! csharp
// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 19/03/2025: versão feita sem muito conhecimento de RhinoC#

using System;
using Rhino;

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

        for(int indice = 0; indice < Quantidade; indice ++) {
            if(Composto) {
                acumulador += Pesos[indice] / Math.Pow(1 + juros / 100, Pagamentos[indice] / Periodo);
            } else {
                acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo);
            }
        }

        if (acumulador <= 0 ) return 0;
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

Juros juros = new Juros(3, true, 30.0);

for(int indice = 0; indice < juros.Quantidade; indice ++) {
    juros.Pagamentos[indice] = (indice + 1.0) * juros.Periodo;
    juros.Pesos[indice] = 1.0;
}

double pesoTotal = juros.getPesoTotal();
double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado);

Console.WriteLine($"Peso total = {pesoTotal}");
Console.WriteLine($"Acréscimo = {acrescimoCalculado}");
Console.WriteLine($"Juros = {jurosCalculado}");