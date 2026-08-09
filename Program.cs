using System;
// using Juros;

class TesteJuros {
    static void Main()
    {
        Juros juros = new Juros(3, true, 30.0);

        for(int i = 0; i < juros.Quantidade; i++) {
            juros.Pagamentos[i] = juros.Periodo * (i + 1);
            juros.Pesos[i] = 1.0;
        }

        double pesoTotal = juros.getPesoTotal();
        double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado);

        System.Console.Write("Peso total = ");
        System.Console.WriteLine(pesoTotal);
        System.Console.Write("Acréscimo = ");
        System.Console.WriteLine(acrescimoCalculado);
        System.Console.Write("Juros = ");
        System.Console.WriteLine(jurosCalculado);
    }
}
