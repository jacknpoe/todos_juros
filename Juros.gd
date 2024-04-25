# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 08/04/2024: versão feita sem muito conhecimento de Godot
# Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0

extends Node2D

# estrutura básica para simplificar as chamadas 
class Juros:
	var Quantidade : int
	var Composto : bool
	var Periodo : float
	var Pagamentos : Array = Array()
	var Pesos : Array = Array()

	# calcula a somatória de Pesos[]
	func getPesoTotal() -> float:
		var acumulador = 0.0
		for indice in range(Quantidade):
			acumulador += Pesos[indice]
		return acumulador

	# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	func jurosParaAcrescimo(juros: float) -> float:
		if 	juros <= 0.0 or Quantidade <= 0 or Periodo <= 0:
			return 0.0
		var pesoTotal : float = getPesoTotal()
		if pesoTotal <= 0.0:
			return 0.0
		var acumulador : float = 0.0
		
		for indice in range(Quantidade):
			if Composto:
				acumulador += Pesos[indice] / pow(1 + juros / 100, Pagamentos[indice] / Periodo)
			else:
				acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo)

		if acumulador <= 0.0:
			return 0.0
		return (pesoTotal / acumulador - 1) * 100

	# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	func acrescimoParaJuros(acrescimo: float, precisao: int, maxIteracoes: int, maxJuros: float) -> float:
		if maxIteracoes < 1 or Quantidade <= 0 or precisao < 1 or Periodo <= 0.0 or acrescimo <= 0.0 or maxJuros <= 0:
			return 0.0
		var pesoTotal : float = getPesoTotal()
		if pesoTotal <= 0.0:
			return 0.0
		var minJuros : float = 0.0
		var medJuros : float = maxJuros / 2.0
		var minDiferenca : float = pow(0.1, precisao)
		
		for indice in range(maxIteracoes):
			medJuros = (minJuros + maxJuros) / 2.0
			if (maxJuros - minJuros) < minDiferenca:
				return medJuros
			if jurosParaAcrescimo(medJuros) < acrescimo:
				minJuros = medJuros
			else:
				maxJuros = medJuros

		return medJuros

func _ready():
	# define os valores de juros
	var juros = Juros.new()
	juros.Quantidade = 3
	juros.Composto = true
	juros.Periodo = 30.0
	juros.Pagamentos = [30.0, 60.0, 90.0]
	juros.Pesos = [1.0, 1.0, 1.0]
	
	# testa as funções
	print("Peso total = ", juros.getPesoTotal())
	print("Acréscimo = ", juros.jurosParaAcrescimo(3.0))
	print("Juros  = ", juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), 15, 100, 50.0))

func _process(delta):
	pass
