// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 14/04/2024: versão feita sem muito conhecimento de Dart

// para a função pow()
import "dart:math";

// classe para agrupar os valores comuns
class Juros {
  int Quantidade;
  bool Composto;
  double Periodo;
  List<double> Pagamentos;
  List<double> Pesos;

  // construtor
  Juros(this.Quantidade, this.Composto, this.Periodo, this.Pagamentos, this.Pesos);

  // calcula a somatória de Pesos[]
  double getPesoTotal() {
    double acumulador = 0.0;
    for(int indice = 0; indice < this.Quantidade; indice++) {
      acumulador += this.Pesos[indice];
    }
    return acumulador;
  }

  // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
  double jurosParaAcrescimo(double juros) {
    double pesoTotal;
    double acumulador = 0.0;
    if(juros <= 0.0 || this.Quantidade <= 0 || this.Periodo <= 0.0) { return 0.0; }
    pesoTotal = this.getPesoTotal();
    if(pesoTotal <= 0.0) { return 0.0; }

    for(int indice = 0; indice < this.Quantidade; indice++) {
      if(this.Composto) {
        acumulador += this.Pesos[indice] / pow(1.0 + juros / 100.0, this.Pagamentos[indice] / this.Periodo);
      } else {
        acumulador += this.Pesos[indice] / (1.0 + juros / 100.0 * this.Pagamentos[indice] / this.Periodo);
      }
    }

    if(acumulador <= 0.0) { return 0.0; }
    return (pesoTotal / acumulador - 1.0) * 100.0;
  }
  
  // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
  double acrescimoParaJuros(double acrescimo, {int precisao = 15, int maxIteracoes = 100, double maxJuros = 50.0}) {
    double pesoTotal;
    double minJuros = 0.0;
    double medJuros = maxJuros / 2.0;
    double minDiferenca = pow(0.1, precisao).toDouble();
    if(maxIteracoes < 1 || this.Quantidade <= 0 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0) { return 0.0; }
    pesoTotal = this.getPesoTotal();
    if(pesoTotal <= 0.0) { return 0.0; }

    for(int indice = 0; indice < maxIteracoes; indice++) {
      medJuros = (minJuros + maxJuros) / 2.0;
      if((maxJuros - minJuros) <minDiferenca) { return medJuros; }
      if(this.jurosParaAcrescimo(medJuros) < acrescimo) {
        minJuros = medJuros;
      } else {
        maxJuros = medJuros;
      }
    }

    return medJuros;
  }
}

void main () {
  // define os valores de juros
  int quantidade = 3;
  Juros juros = new Juros(quantidade, true, 30.0, [], []);
  for (int indice = 0; indice < quantidade; indice++) {
    juros.Pagamentos.add((indice + 1) * 30.0);
    juros.Pesos.add(1.0);
  }

  // testa os métodos
  print('Peso total = ${juros.getPesoTotal()}');
  print('Acréscimo = ${juros.jurosParaAcrescimo(3.0)}');
  print('Juros = ${juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), precisao: 18, maxIteracoes: 200, maxJuros: 100.0)}');
}