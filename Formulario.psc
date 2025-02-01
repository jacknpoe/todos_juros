{$FORM TFormulario, Formulario.sfm}                                                

{ Cálculo dos juros, sendo que precisa de parcelas pra isso
  Versão 0.1: 01/02/2025: versão feita sem muito conhecimento de ESPL }

uses
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls;

const { constante com a quantidade de parcelas }
    cQuantidade = 3;

var { para simplificar as chamadas de função }
  iQuantidade: Integer;
  bComposto: Boolean;
  rPeriodo: Real;
  aPagamentos: TArray;
  aPesos: TArray;

{ calcula a somatória do array Pesos[] }
function getPesoTotal: Real;
var
  rAcumulador: Real;
  iIndice: Integer;
begin                
  rAcumulador := 0.0;
  for iIndice := 1 to iQuantidade do rAcumulador := rAcumulador + aPesos.Values[iIndice];
  result := rAcumulador;
end;                    

{ calcula o acréscimo a partir dos juros e parcelas }                 
function jurosParaAcrescimo(rJuros: Real): Real;
var
  rPesoTotal, rAcumulador: Real;     
  iIndice: Integer;                            
begin
  rPesoTotal := getPesoTotal;
  if (rJuros <= 0.0) or (iQuantidade < 1) or (rPeriodo <= 0.0) or (rPesoTotal <= 0.0) then
  begin
    result := 0.0; exit;     
  end;      
  
  rAcumulador := 0.0;
  for iIndice := 1 to iQuantidade do
  begin
    if bComposto then
      rAcumulador := rAcumulador + aPesos.Values[iIndice] / Power(1.0 + rJuros / 100.0, aPagamentos.Values[iIndice] / rPeriodo)
    else
      rAcumulador := rAcumulador + aPesos.Values[iIndice] / (1.0 + rJuros / 100.0 * aPagamentos.Values[iIndice] / rPeriodo);   
  end;

  if rAcumulador <= 0.0 then result := 0.0
  else result := (rPesoTotal / rAcumulador - 1.0) * 100.0;
end;

{ calcula os juros a partir do acréscimo e parcelas }
function acrescimoParaJuros(rAcrescimo: Real; iPrecisao, iMaxIteracoes: Integer; rMaxJuros: Real): Real;
var
  rPesoTotal, rMinJuros, rMedJuros, rMinDiferenca: Real;
  iIndice: Integer;
begin   
  rPesoTotal := getPesoTotal;
  if (rAcrescimo <= 0.0) or (iQuantidade < 1) or (rPeriodo <= 0.0) or (rPesoTotal <= 0.0) or (iPrecisao < 1) or (iMaxIteracoes < 1) or (rMaxJuros <= 0.0) then
  begin
    result := 0.0; exit;     
  end;

  rMinJuros := 0.0;
  rMinDiferenca := Power(0.1, iPrecisao);
  
  for iIndice := 1 to iMaxIteracoes do
  begin  
    rMedJuros := (rMinJuros + rMaxJuros) / 2.0;
    if (rMaxJuros - rMinJuros) < rMinDiferenca then
    begin
      result := rMedJuros; exit;
    end;
    
    if jurosParaAcrescimo(rMedJuros) < rAcrescimo then rMinJuros := rMedJuros else rMaxJuros := rMedJuros;
  end;
  result := rMedJuros;
end;

procedure CalcularClick(Sender: TObject);    
var                                          
  resultado, rPesoTotal, rAcrescimoCalculado, rJurosCalculado: Real;
  iIndice: Integer;  
begin { inicializa as variáveis globais }
  iQuantidade := 3;        
  bComposto := true;
  rPeriodo := 30.0;
  aPagamentos := TArray.Create;
  aPesos := TArray.Create;

  for iIndice := 1 to iQuantidade do  { preenche os arrays }
  begin                                    
    aPagamentos.Values[iIndice] := 30.0 * iIndice;
    aPesos.Values[iIndice] := 1.0; 
  end;

  { calcula e guarda os retornos das funções }
  rPesoTotal := getPesoTotal;   
  rAcrescimoCalculado := jurosParaAcrescimo(3.0);
  rJurosCalculado := acrescimoParaJuros(rAcrescimoCalculado, 15, 100, 50.0);
                                   
  { imprime os resultados }  
  write('Peso total = '); writeln(rPesoTotal);  
  write('Acréscimo = '); writeln(rAcrescimoCalculado);
  write('Juros = '); writeln(rJurosCalculado);   
end;                                

begin    
end;                                     
