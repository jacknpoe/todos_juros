namespace Juros;

interface

type
  // classe com as propriedades que simplificam as chamadas
  JurosOxygene = public class
  private
    fQuantidade: Int16;
  public
    // propriedades (veja que só protegemos Quantidade, porque ela altera os arrays
    property Quantidade: Int16 read getQuantidade write setQuantidade;
    property Composto: Boolean read write;
    property Periodo: Real read write;
    property Pagamentos: array of Real read write;
    property Pesos: array of Real read write;

    // métodos para Quantidade e cálculos
    method setQuantidade(valor: Int16);
    method getQuantidade: Int16;
    method getPesoTotal: Real;
    method jurosParaAcrescimo(juros: Real): Real;
    method acrescimoParaJuros(acrescimo: Real; precisao: Int16 := 15; maxIteracoes: Int16 := 100; maxJuros: Real := 50.0): Real;
  end;

implementation
  // write da propriedade Quantidade, que altera os arrays
  method JurosOxygene.setQuantidade(valor: Int16);
  begin
    fQuantidade := valor;
    Pagamentos := new Real[valor];
    Pesos := new Real[valor];
  end;

  // read da propriedade Quantidade, acesso direto simples
  method JurosOxygene.getQuantidade: Int16;
  begin
    exit fQuantidade;
  end;

  // calcula a somatória de Pesos[]
  method JurosOxygene.getPesoTotal: Real;
  var
    acumulador: Real := 0.0;
  begin
    for indice: Int16 := 0 to fQuantidade - 1 do acumulador := acumulador + Pesos[indice];
    exit acumulador;
  end;

  // calcula o acréscimo a partir dos juros e parcelas
  method JurosOxygene.jurosParaAcrescimo(juros: Real): Real;
  var
    pesoTotal: Real; acumulador: Real := 0.0;
  begin
    pesoTotal := getPesoTotal;
    if (juros ≤ 0.0) or (fQuantidade < 1) or (Periodo ≤ 0.0) or (pesoTotal ≤ 0.0) then exit 0.0;

    for indice: Int16 := 0 to fQuantidade - 1 do
      if Composto then
        acumulador := acumulador + Pesos[indice] / Math.Pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
      else
        acumulador := acumulador + Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo);

    exit (pesoTotal / acumulador - 1.0) * 100.0;
  end;

  // calcula os juros a partir do acréscimo e parcelas
  method JurosOxygene.acrescimoParaJuros(acrescimo: Real; precisao: Int16 := 15; maxIteracoes: Int16 := 100; maxJuros: Real := 50.0): Real;
  var
    minJuros: Real := 0.0; medJuros, minDiferenca, pesoTotal: Real;
  begin
    pesoTotal := getPesoTotal;
    if (acrescimo ≤ 0.0) or (fQuantidade < 1) or (Periodo ≤ 0.0) or (pesoTotal ≤ 0.0) or (precisao < 1) or (maxIteracoes < 1) or (maxJuros ≤ 0.0) then exit 0.0;
    medJuros := maxJuros / 2.0;
    minDiferenca := Math.Pow(0.1, precisao);

    for indice: Int16 := 1 to maxIteracoes do
    begin
       medJuros := (minJuros + maxJuros) / 2.0;
       if (maxJuros - minJuros) < minDiferenca then exit medJuros;
       if jurosParaAcrescimo(medJuros) < acrescimo then minJuros := medJuros else maxJuros := medJuros;
    end;

    exit medJuros;
  end;
end.