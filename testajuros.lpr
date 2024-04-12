program TesteJuros;

{$APPTYPE CONSOLE}

uses
 Juros;
var
  ojuros: TJuros;
  acrescimoCalculado, jurosCalculado: double;
begin
  ojuros := TJuros.Create(3, true, 30);

  ojuros.Pesos[0] := 1.0;
  ojuros.Pesos[1] := 1.0;
  ojuros.Pesos[2] := 1.0;

  ojuros.Pagamentos[0] := 30;
  ojuros.Pagamentos[1] := 60;
  ojuros.Pagamentos[2] := 90;

  acrescimoCalculado := ojuros.jurosParaAcrescimo(3.0);
  jurosCalculado := ojuros.acrescimoParaJuros(acrescimoCalculado);
  writeln(acrescimoCalculado);
  writeln(jurosCalculado);
end.


