import Juros.Juros

object TestaJuros {
    def main(args: Array[String]): Integer = {
        // define os valores para meuJuros
        val meuJuros: Juros = new Juros(3, true, 30.0, Array[Double](30.0, 60.0, 90.0), Array[Double](1.0, 1.0, 1.0))

        // testa as funções
        println("Peso total = " + meuJuros.getPesoTotal())
        println("Acréscimo = " + meuJuros.jurosParaAcrescimo(3.0))
        println("Juros = " + meuJuros.acrescimoParaJuros(meuJuros.jurosParaAcrescimo(3.0), 15, 100, 50.0))

        return 0
    }
}