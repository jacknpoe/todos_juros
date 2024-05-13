using System;
// using Juros;

class TesteJuros {
    static void Main()
    {
        Juros juros = new Juros(3, true, 30.0);

        juros.Pesos[0] = 1;
        juros.Pesos[1] = 1;
        juros.Pesos[2] = 1;

        juros.Pagamentos[0] = 30.0;
        juros.Pagamentos[1] = 60.0;
        juros.Pagamentos[2] = 90.0;

        double pesoTotal = juros.getPesoTotal();
        double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado);

        System.Console.Write("Peso total = ");
        System.Console.WriteLine(pesoTotal);
        System.Console.Write("Acréscimo = ");
        System.Console.WriteLine(acrescimoCalculado);
        System.Console.Write("Juros = ");
        System.Console.WriteLine(jurosCalculado);
        System.Console.ReadLine();
    }
}
