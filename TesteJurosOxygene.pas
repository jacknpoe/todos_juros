namespace Juros;

interface

type
  TesteJurosOxygene = class
  public
    class method Main(args: array of String): Int32;
  end;

implementation

  class method TesteJurosOxygene.Main(args: array of String): Int32;
  var
    juros: JurosOxygene;
    pesoTotal, acrescimoCalculado, jurosCalculado: Real;
  begin
    // cria um objeto juros da classe JurosOxygene e define valores para Quantidade, Composto e Periodo
    juros := new JurosOxygene(Quantidade := 3, Composto := true, Periodo := 30.0);

    // define valores para os arrays Pagamentos[] e Pesos[]
    for indice: Int16 := 0 to juros.Quantidade - 1 do
    begin
      juros.Pagamentos[indice] := (indice + 1.0) * 30.0;
      juros.Pesos[indice] := 1.0;
    end;

    // calcula e guarda os resultados de retorno dos métodos
    pesoTotal := juros.getPesoTotal;
    acrescimoCalculado := juros.jurosParaAcrescimo(3.0);
    jurosCalculado := juros.acrescimoParaJuros(acrescimoCalculado);

    // imprime os resultados
    write("Peso total = "); writeLn(pesoTotal);
    write("Acrescimo = "); writeLn(acrescimoCalculado);
    write("Juros = "); writeLn(jurosCalculado);

    exit 0;
  end;
end.