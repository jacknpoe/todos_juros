program TesteJuros;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Juros;
var
  juros: TJuros;
  acrescimoCalculado, jurosCalculado: double;
begin
  try
    juros := TJuros.Create(3, true, 30.0);

    juros.Pesos[0] := 1.0;
    juros.Pesos[1] := 1.0;
    juros.Pesos[2] := 1.0;

    juros.Pagamentos[0] := 30.0;
    juros.Pagamentos[1] := 60.0;
    juros.Pagamentos[2] := 90.0;

    acrescimoCalculado := juros.jurosParaAcrescimo(3.0);
    jurosCalculado := juros.acrescimoParaJuros(acrescimoCalculado);
    writeln(acrescimoCalculado);
    writeln(jurosCalculado);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
