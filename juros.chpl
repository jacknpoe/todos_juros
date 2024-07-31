// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 31/07/2024: versão feita sem muito conhecimento de Chapel

// para colocar 16 casas decimais
use IO.FormattedIO;

var MAXIMO: int = 1000; // infelizmente, arrays dinâmicos como atributos é impossível

// classe com atributos para simplificar as chamadas
class Juros {
    var quantidade: int;
    var composto: bool;
    var periodo: real;
    var pagamentos: [1..MAXIMO] real;
    var pesos: [1..MAXIMO] real;

    // o construtor inicializa os atributos que não são arrays
    proc Juros(quantidade: int, composto: bool, periodo: real) {
        this.quantidade = quantidade;
        this.composto = composto;
        this.periodo = periodo;
    }

    //alcula a somatória do array Pesos[]
    proc getPesoTotal() {
        var acumulador: real = 0.0;
        for indice in {1..this.quantidade} { acumulador += this.pesos[indice]; }
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    proc jurosParaAcrescimo(juros: real) {
        var pesoTotal: real = this.getPesoTotal();
        if(juros <= 0.0 || this.quantidade < 1 || this.periodo <= 0.0 || pesoTotal <= 0.0) { return 0.0; }
        var acumulador: real = 0.0;

        for indice in {1..this.quantidade} {
            if(this.composto) {
                acumulador += this.pesos[indice] / (1.0 + juros / 100.0) ** (this.pagamentos[indice] / this.periodo);
            } else {
                acumulador += this.pesos[indice] / (1.0 + juros / 100.0 * this.pagamentos[indice] / this.periodo);
            }
        }

        return (pesoTotal / acumulador - 1.0) * 100;
    }

    // calcula os juros a partir do acréscimo e parcelas
    proc acrescimoParaJuros(acrescimo: real, precisao: int, maxIteracoes: int, maximoJuros: real) {
        var pesoTotal: real = this.getPesoTotal();
        if(acrescimo <= 0.0 || this.quantidade < 1 || this.periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0) { return 0.0; }
        var minJuros: real = 0.0;
        var medJuros: real = maximoJuros / 2.0;
        var maxJuros: real = maximoJuros;
        var minDiferenca: real = 0.1 ** precisao;

        for indice in {1..maxIteracoes} {
            medJuros = (minJuros + maxJuros) / 2.0;
            if((maxJuros - minJuros) < minDiferenca) { return medJuros; }
            if(this.jurosParaAcrescimo(medJuros) < acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }
        }

        return medJuros;
    }
}

// cria um objeto juros da classe Juros e inicializa os atributos
var juros = new Juros(3, true, 30.0);
for indice in {1..3} {
    juros.pagamentos[indice] = indice * 30.0;
    juros.pesos[indice] = 1.0;
}

// calcula e guarda os resultados dos métodos
var pesoTotal: real = juros.getPesoTotal();
var acrescimoCalculado: real = juros.jurosParaAcrescimo(3.0);
var jurosCalculado: real = juros.acrescimoParaJuros(acrescimoCalculado, 16, 100, 50.0);

// imprime os resultados
writeln("Peso total = %17.16r".format(pesoTotal));
writeln("Acréscimo = %17.16r".format(acrescimoCalculado));
writeln("Juros = %17.16r".format(jurosCalculado));