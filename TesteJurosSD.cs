using JurosSD;

class TesteJurosSD
{
    static void Main()
    {
        JurosSD.JurosSD juros = new(3, true, 30.0);

        for (int indice = 0; indice < juros.Quantidade; indice++)
        {
            juros.Pagamentos[indice] = (indice + 1.0) * juros.Periodo;
            juros.Pesos[indice] = 1.0;
        }

        double pesoTotal = juros.GetPesoTotal();
        double acrescimoCalculado = juros.JurosParaAcrescimo(3.0);
        double jurosCalculado = juros.AcrescimoParaJuros(acrescimoCalculado);

        Console.Write("Peso total = ");
        Console.WriteLine(pesoTotal);
        Console.Write("Acréscimo = ");
        Console.WriteLine(acrescimoCalculado);
        Console.Write("Juros = ");
        Console.WriteLine(jurosCalculado);
        Console.ReadLine();
    }
}