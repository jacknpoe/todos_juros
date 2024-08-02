// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 02/08/2024: versão feita sem muito conhecimento de X10

import x10.io.Console;

// classe com atributos para simplificar as chamadas
class Juros {
  public var Quantidade: Long;
  public var Composto: Boolean;
  public var Periodo: Double;
  public var Pagamentos: Rail[Double];
  public var Pesos: Rail[Double];

  // o construtor inicializa as variáveis (os arrays com 0.0s e 1.0s)
  public def this(qtd: Long, cmp: Boolean, prd: Double) {
    Pagamentos = new Rail[Double](qtd, 0.0);
    Pesos = new Rail[Double](qtd, 1.0);
    Quantidade = qtd;
    Composto = cmp;
    Periodo = prd;
  }

  // calcula a somatória de Pesos()
  public def getPesoTotal(): Double {
    var acumulador: Double = 0.0;
    for(indice in 0L..(Quantidade-1)) { acumulador += Pesos(indice); }
    return acumulador;
  }

  // calcula o acréscimo a partir dos juros e parcelas
  public def jurosParaAcrescimo(juros: Double): Double {
    var pesoTotal: Double = getPesoTotal();
    if(juros <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
    var acumulador: Double = 0.0;

    for(indice in 0L..(Quantidade-1)) {
      if(Composto) {
        acumulador += Pesos(indice) / Math.pow(1.0 + juros / 100.0, Pagamentos(indice) / Periodo);
      } else {
        acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo);
      }
    }

    return (pesoTotal / acumulador - 1.0) * 100.0;
  }

  // calcula os juros a partir do acréscimo e parcelas
  public def acrescimoParaJuros(acrescimo: Double, precisao: Long, maxIteracoes: Long, maximoJuros: Double): Double {
    var pesoTotal: Double = getPesoTotal();
    if(acrescimo <= 0.0 || Quantidade < 1 || Periodo <= 0.0 || pesoTotal <= 0.0 || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0) return 0.0;
    var minJuros: Double = 0.0;
    var medJuros: Double = maximoJuros / 2.0;
    var maxJuros: Double = maximoJuros;
    var minDiferenca: Double = Math.pow(0.1, precisao);

    for(indice in 1L..maxIteracoes) {
      medJuros = (minJuros + maxJuros) / 2.0;
      if((maxJuros - minJuros) < minDiferenca) return medJuros;
      if(jurosParaAcrescimo(medJuros) < acrescimo) {
        minJuros = medJuros;
      } else {
        maxJuros = medJuros;
      }
    }

    return medJuros;
  }
}

public class TestaJuros {
  public static def main(args:Rail[String]):void {
    // cria um objeto juros da classe Juros e inicializa os atributos
    var juros: Juros = new Juros(3L, true, 30.0);
    for(indice in 0L..(juros.Quantidade-1)) { juros.Pagamentos(indice) = (indice + 1.0) * 30.0; }

    // calcula e guarda os resultados dos métodos
    var pesoTotal: Double = juros.getPesoTotal();
    var acrescimoCalculado: Double = juros.jurosParaAcrescimo(3.0);
    var jurosCalculado: Double = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

    // imprime os resultados
    Console.OUT.println("Peso total = " + pesoTotal);
    Console.OUT.println("Acréscimo = " + acrescimoCalculado);
    Console.OUT.println("Juros = " + jurosCalculado);
    return;
  }
}