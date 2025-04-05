// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 05/04/2025: versão feita sem muito conhecimento de Procesing


// essa é, basicamente, a função main() em Processing 
void setup() {
  // inicializa as variáveis globais, os arrays de forma dinâmica
  cJuros juros = new cJuros(3, true, 30.0D);
  
  for(int indice = 0; indice < juros.Quantidade; indice++) {
    juros.Pagamentos[indice] = (indice + 1.0D) * juros.Periodo;
    juros.Pesos[indice] = 1.0D;
  }
  
  // calcula e guarda os resultados das funç~eos
  double pesoTotal = juros.getPesoTotal();
  double acrescimoCalculado = juros.jurosParaAcrescimo(3.0D);
  double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0D);
  
  // imprime os resultados
  println("Peso total = " + pesoTotal);
  println("Acréscimo = " + acrescimoCalculado);
  println("Juros = " + jurosCalculado);
}

// essa função seria um looping, que não precisamos aqui
void draw() {
  noLoop();
}

class cJuros {
  int Quantidade;
  boolean Composto;
  double Periodo;
  double[] Pagamentos;
  double[] Pesos;

  cJuros(int qtd, boolean cmp, double per) {
    Quantidade = qtd;
    Composto = cmp;
    Periodo = per;
    Pagamentos = new double[qtd];
    Pesos = new double[qtd];
  }

  // calcula a somatória de Pesos[]
  double getPesoTotal() {
    double acumulador = 0.0D;
    for(int indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
    return acumulador;
  }

  // calcula o acréscimo a partir dos juros e parcelas
  double jurosParaAcrescimo(double juros) {
    double pesoTotal = getPesoTotal();
    if(Quantidade < 1 | Periodo <= 0.0D | pesoTotal <= 0.0D | juros <= 0.0) return 0.0D;
    
    double acumulador = 0.0D;
    for(int indice = 0; indice < Quantidade; indice++)
      if(Composto) acumulador += Pesos[indice] / pow((float)(1.0D + juros / 100.0D), (float)(Pagamentos[indice] / Periodo));
        else acumulador += Pesos[indice] / (1.0D + juros / 100.0D * Pagamentos[indice] / Periodo);
    if(acumulador <= 0.0D) return 0.0D;
    return (pesoTotal / acumulador - 1.0D) * 100.0D;
  }
  
  // calcula os juros a partir do acréscimo e parcelas
  double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
    double pesoTotal = getPesoTotal();
    if(Quantidade < 1 | Periodo <= 0.0D | pesoTotal <= 0.0D | acrescimo <= 0.0D | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0D) return 0.0D;

    double minJuros = 0.0D, medJuros = maxJuros / 2.0D, minDiferenca = pow(0.1, (float) precisao); 
    for(int indice = 0; indice < maxIteracoes; indice++) {
      if(maxJuros - minJuros < minDiferenca) return medJuros;
      if(jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros; else maxJuros = medJuros;
      medJuros = (minJuros + maxJuros) / 2.0D;
    }
    return medJuros;
  }
}
