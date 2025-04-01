//%attributes = {}
// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 01/04/2025: versão feita sem muito conhecimento de 4D

// objeto $juros da classe cs.Juros
var $juros : cs:C1710.Juros
$juros:=cs:C1710.Juros.new(3; True:C214; 30)

// arrays inicializados dinamicamente
For ($indice; 0; $juros.Quantidade-1; 1)
	$juros.Pagamentos[$indice]:=($indice+1)*$juros.Periodo
	$juros.Pesos[$indice]:=1
End for 

// calcula e guarda os resultados dos métodos
var $pesoTotal : Real:=$juros.getPesoTotal()
var $acrescimoCalculado : Real:=$juros.jurosParaAcrescimo(3)
var $jurosCalculado : Real:=$juros.acrescimoParaJuros($acrescimoCalculado; 15; 100; 50)

// mostra os resultados
ALERT:C41("Peso total = "+String:C10($pesoTotal)+Char:C90(13)+"Acréscimo = "+String:C10($acrescimoCalculado)+Char:C90(13)+"Juros = "+String:C10($jurosCalculado))