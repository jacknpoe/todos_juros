fun main() {
    val juros = Juros(3, true, 30)
    juros.setPagamento(0, 30)
    juros.setPagamento(1, 60)
    juros.setPagamento(2, 90)
    juros.setPeso(0, 1.0)
    juros.setPeso(1, 1.0)
    juros.setPeso(2, 1.0)
    val acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
    val jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado)
    println(juros.getPesoTotal())
    println(acrescimoCalculado)
    println(jurosCalculado)
}