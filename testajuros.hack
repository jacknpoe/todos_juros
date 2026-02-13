use namespace jacknpoe;

<<__EntryPoint>>
function main(): void {
    require_once 'juros.hack';

    // cria um objeto juros da classe CalculaJuros com 3 parcelas, composto e juros sobre o período de 30 dias
    $juros = new \jacknpoe\Juros(3, true, 30.0);
    $juros->setPagamentos();
    $juros->setPesos();

    // calcula e guarda os retornos dos métodos
    $pesoTotal = $juros->getPesoTotal();
    $acrescimoCalculado = $juros->jurosParaAcrescimo(3.0);
    $jurosCalculado = $juros->acrescimoParaJuros($acrescimoCalculado, 15, 65, 50.0, false);

    // imprime os resultados
    printf("Peso total = %.15f\n", $pesoTotal);
    printf("Acréscimo = %.15f\n", $acrescimoCalculado);
    printf("Juros = %.15f\n", $jurosCalculado);
}
