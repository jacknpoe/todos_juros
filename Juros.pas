unit Juros;

interface

uses
  Math;
      {, System.SysUtils}
Type
TJuros = class
  private
    fQuantidade: integer;
    fComposto: boolean;
    fPeriodo: integer;
    fPagamentos: array of integer;
    fPesos: array of double;
  public
    function GetQuantidade: integer;
    procedure SetQuantidade(valor: integer);
    function GetPagamentos(indice: integer): integer;
    procedure SetPagamentos(indice: integer; valor: integer);
    function GetPesos(indice: integer): double;
    procedure SetPesos(indice: integer; valor: double);
    constructor Create(quantidade: integer = 0; composto: boolean = false; periodo: integer = 30);
    function getPesoTotal: double;
    function jurosParaAcrescimo(juros: double): double;
    function acrescimoParaJuros(acrescimo: double; precisao: integer = 15; maxIteracoes: integer = 100; maxJuros: double = 50): double;

    property Quantidade: integer read GetQuantidade write SetQuantidade;
    property Composto: boolean read fComposto write fComposto;
    property Periodo: integer read fPeriodo write fPeriodo;
    property Pagamentos[indice: integer]: integer read GetPagamentos write SetPagamentos;
    property Pesos[indice: integer]: double read GetPesos write SetPesos;
end;

implementation

function TJuros.GetQuantidade: integer;
begin
  result := fQuantidade;
end;

procedure TJuros.SetQuantidade(valor: integer);
begin
  fQuantidade := valor;
  SetLength(fPagamentos, valor);
  SetLength(fPesos, valor);
end;

function TJuros.GetPagamentos(indice: integer): integer;
begin
  result := fPagamentos[indice];
end;

procedure TJuros.SetPagamentos(indice: integer; valor: integer);
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

constructor TJuros.Create(quantidade: integer = 0; composto: boolean = false; periodo: integer = 30);
begin
  SetQuantidade(quantidade);
  fComposto := composto;
  fPeriodo := periodo;
end;

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

function TJuros.jurosParaAcrescimo(juros: double): double;
var
  pesoTotal, acumulador: double;
  soZero: boolean;
  indice: integer;
begin
  pesoTotal := getPesoTotal;
  if (juros <= 0.0) or (Quantidade <= 0) or (Periodo <= 0) or (pesoTotal <= 0.0) then
  begin
    result := 0.0;
    exit;
  end;
  acumulador := 0.0;
  soZero := true;

  for indice := 0 to (Quantidade - 1) do
  begin
    if (Pagamentos[indice] > 0) and (Pesos[indice] > 0) then
    begin
      soZero := false;
    end;
    if Composto then
    begin
      acumulador := acumulador + Pesos[indice] / Power(1 + juros / 100, Pagamentos[indice] / Periodo);
    end else begin
      acumulador := acumulador + Pesos[indice] / ((1 + juros / 100) * Pagamentos[indice] / Periodo);
    end;
  end;
  if soZero then
  begin
    result := 0.0;
  end else begin
    result := (pesoTotal / acumulador - 1) * 100;
  end;
end;

function TJuros.acrescimoParaJuros(acrescimo: double; precisao: integer = 15; maxIteracoes: integer = 100; maxJuros: double = 50): double;
var
  minJuros, medJuros, minDiferenca, pesoTotal: double;
  indice: integer;
begin
  pesoTotal := getPesoTotal;
  if (maxIteracoes < 1) or (Quantidade <= 0) or (precisao <= 0) or (Periodo <= 0) or (acrescimo <= 0.0) or (maxJuros <= 0) or (pesoTotal <= 0) then
  begin
    result := 0.0;
    exit;
  end;
  minJuros := 0;
  medJuros := maxJuros / 2;
  minDiferenca := Power(0.1, precisao);

  for indice := 0 to (maxIteracoes - 1) do
  begin
    medJuros := (minJuros + maxJuros) / 2;
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

end.
