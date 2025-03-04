// C†lculo dos juros, sendo que precisa de parcelas pra isso
// Vers∆o 0.1: 04/03/2025: a partir da vers∆o em Delphi, tentando compilar em Free Pascal com classe
{$MODE OBJFPC}

program tesJurosOP;

uses
  Math;

Type
  TJuros = class
    private  // estrutura b†sica de propriedades para simplificar as chamadas
      fQuantidade: integer;
      fComposto: boolean;
      fPeriodo: double;
      fPagamentos: array of double;
      fPesos: array of double;
    public
      function GetQuantidade: integer;
      procedure SetQuantidade(valor: integer);
      function GetPagamentos(indice: integer): double;
      procedure SetPagamentos(indice: integer; valor: double);
      function GetPesos(indice: integer): double;
      procedure SetPesos(indice: integer; valor: double);
      constructor Create(quantidade: integer = 0; composto: boolean = false; periodo: double = 30.0);
      function getPesoTotal: double;
      function jurosParaAcrescimo(juros: double): double;
      function acrescimoParaJuros(acrescimo: double; precisao: integer = 15; maxIteracoes: integer = 100; maxJuros: double = 50.0): double;

      property Quantidade: integer read GetQuantidade write SetQuantidade;
      property Composto: boolean read fComposto write fComposto;
      property Periodo: double read fPeriodo write fPeriodo;
      property Pagamentos[indice: integer]: double read GetPagamentos write SetPagamentos;
      property Pesos[indice: integer]: double read GetPesos write SetPesos;
  end;

  function TJuros.GetQuantidade: integer;
  begin
    result := fQuantidade;
  end;

  // sets e gets determinam as propriedades
  procedure TJuros.SetQuantidade(valor: integer);
  begin
    fQuantidade := valor;
    SetLength(fPagamentos, valor);
    SetLength(fPesos, valor);
  end;

  function TJuros.GetPagamentos(indice: integer): double;
  begin
    result := fPagamentos[indice];
  end;

  procedure TJuros.SetPagamentos(indice: integer; valor: double);
  begin
    fPagamentos[indice] := valor;
  end;

  function TJuros.GetPesos(indice: integer): double;
  begin
    result := fPesos[indice];
  end;

  procedure TJuros.SetPesos(indice: integer; valor: double);
  begin
    fPesos[indice] := valor;
  end;

  // construtor recebe valores para as vari†veis escalares
  constructor TJuros.Create(quantidade: integer = 0; composto: boolean = false; periodo: double = 30.0);
  begin
    SetQuantidade(quantidade);
    fComposto := composto;
    fPeriodo := periodo;
  end;

  // calcula a somat¢ria de Pesos[]
  function TJuros.getPesoTotal: double;
  var
    acumulador: double;
    indice: integer;
  begin
    acumulador := 0.0;
    for indice := 0 to (Quantidade - 1) do
    begin
      acumulador := acumulador + Pesos[indice];
    end;
    result := acumulador;
  end;

  // calcula o acrÇscimo a partir dos juros e parcelas
  function TJuros.jurosParaAcrescimo(juros: double): double;
  var
    pesoTotal, acumulador: double;
    indice: integer;
  begin
    pesoTotal := getPesoTotal;
    if (juros <= 0.0) or (Quantidade <= 0) or (Periodo <= 0.0) or (pesoTotal <= 0.0) then
    begin
      result := 0.0;
      exit;
    end;
    acumulador := 0.0;

    for indice := 0 to (Quantidade - 1) do
    begin
      if Composto then
      begin
        acumulador := acumulador + Pesos[indice] / Power(1 + juros / 100, Pagamentos[indice] / Periodo);
      end else begin
        acumulador := acumulador + Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo);
      end;
    end;
    if acumulador <= 0.0 then
    begin
      result := 0.0;
    end else begin
      result := (pesoTotal / acumulador - 1) * 100;
    end;
  end;

  // calcula os juros a partir do acrÇscimo e parcelas
  function TJuros.acrescimoParaJuros(acrescimo: double; precisao: integer = 15; maxIteracoes: integer = 100; maxJuros: double = 50.0): double;
  var
    minJuros, medJuros, minDiferenca, pesoTotal: double;
    indice: integer;
  begin
    pesoTotal := getPesoTotal;
    if (maxIteracoes < 1) or (Quantidade <= 0) or (precisao <= 0) or (Periodo <= 0.0) or (acrescimo <= 0.0) or (maxJuros <= 0.0) or (pesoTotal <= 0.0) then
    begin
      result := 0.0;
      exit;
    end;
    minJuros := 0.0;
    medJuros := maxJuros / 2.0;
    minDiferenca := Power(0.1, precisao);

    for indice := 0 to (maxIteracoes - 1) do
    begin
      medJuros := (minJuros + maxJuros) / 2.0;
      if (maxJuros - minJuros) < minDiferenca then
      begin
        result := medJuros;
        exit;
      end;
      if jurosParaAcrescimo(medJuros) <= acrescimo then
      begin
        minJuros := medJuros;
      end else begin
        maxJuros := medJuros;
      end;
    end;

    result := medJuros;
  end;

var
  juros: TJuros;
  pesoTotal, acrescimoCalculado, jurosCalculado: double;
  indice: integer;
begin
  // inicializa os valores no objeto juros da classe TJuros
  juros := TJuros.Create(3, true, 30.0);

  for indice := 0 to (juros.Quantidade - 1) do
  begin
    juros.Pagamentos[indice] := 30.0 * (indice + 1.0);
    juros.Pesos[indice] := 1.0;
  end;

  // calcula e guarda os resultados das funá‰es
  pesoTotal := juros.getPesoTotal;
  acrescimoCalculado := juros.jurosParaAcrescimo(3.0);
  jurosCalculado := juros.acrescimoParaJuros(acrescimoCalculado);

  // imprime os resultados
  writeln('Peso total =', pesoTotal);
  writeln('AcrÇscimo =', acrescimoCalculado);
  writeln('Juros =', jurosCalculado);
end.
