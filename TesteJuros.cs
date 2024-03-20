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

        double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado);

        System.Console.WriteLine(acrescimoCalculado);
        System.Console.WriteLine(jurosCalculado);
        System.Console.ReadLine();
    }
}
