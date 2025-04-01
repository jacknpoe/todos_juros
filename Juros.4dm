// as propriedades simplificam as chamadas aos métodos
property Quantidade : Integer
property Composto : Boolean
property Periodo : Real
property Pagamentos; Pesos : Collection

// Classe Juros
Class constructor($quantidade : Integer; $composto : Boolean; $periodo : Real)
	This:C1470.Quantidade:=$quantidade
	This:C1470.Composto:=$composto
	This:C1470.Periodo:=$periodo
	This:C1470.Pagamentos:=New collection:C1472
	This:C1470.Pesos:=New collection:C1472
	
	// calcula a somatória de Pesos[]
Function getPesoTotal() : Real
	var $acumulador : Real:=0
	For ($indice; 0; This:C1470.Quantidade-1; 1)
		$acumulador:=$acumulador+This:C1470.Pesos[$indice]
	End for 
	return $acumulador
	
	// calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo($juros : Real) : Real
	var $acumulador; $pesoTotal : Real
	$pesoTotal:=This:C1470.getPesoTotal()
	If (This:C1470.Quantidade<1 || This:C1470.Periodo<=0 || $juros<=0 || $pesoTotal<=0)
		return 0
	End if 
	$acumulador:=0
	For ($indice; 0; This:C1470.Quantidade-1; 1)
		If (This:C1470.Composto)
			$acumulador:=$acumulador+(This:C1470.Pesos[$indice]/((1+($juros/100))^(This:C1470.Pagamentos[$indice]/This:C1470.Periodo)))
		Else 
			$acumulador:=$acumulador+(This:C1470.Pesos[$indice]/(1+($juros/100*This:C1470.Pagamentos[$indice]/This:C1470.Periodo)))
		End if 
	End for 
	If ($acumulador<=0)
		return 0
	End if 
	return ($pesoTotal/$acumulador-1)*100
	
	// calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros($acrescimo : Real; $precisao : Integer; $maxIteracoes : Integer; $maxJuros : Real) : Real
	var $pesoTotal; $minJuros; $medJuros; $minDiferenca : Real
	$pesoTotal:=This:C1470.getPesoTotal()
	If (This:C1470.Quantidade<1 || This:C1470.Periodo<=0 || $acrescimo<=0 || $pesoTotal<=0 || $precisao<1 || $maxIteracoes<1 || $maxJuros<=0)
		return 0
	End if 
	$minJuros:=0
	$medJuros:=$maxJuros/2
	$minDiferenca:=0.1^$precisao
	For ($indice; 1; $maxIteracoes; 1)
		If ($maxJuros-$minJuros<$minDiferenca)
			return $medJuros
		End if 
		If (This:C1470.jurosParaAcrescimo($medJuros)<$acrescimo)
			$minJuros:=$medJuros
		Else 
			$maxJuros:=$medJuros
		End if 
		$medJuros:=($minJuros+$maxJuros)/2
	End for 
	
	return $medJuros
	