# Generated automatically with "cito". Do not edit.
import array
import math

class Juros:

	def __init__(self):
		pass

	def init(self, quant, comp, per):
		"""define escalares e aloca arrays"""
		self._quantidade = quant
		self._composto = comp
		self._periodo = per
		self._pagamentos = array.array("d", [ 0 ]) * quant
		self._pesos = array.array("d", [ 0 ]) * quant

	def set_pagamentos(self, indice, valor):
		"""define Pagamentos[indice] como valor"""
		self._pagamentos[indice] = valor

	def set_pesos(self, indice, valor):
		"""define Pesos[indice] como valor"""
		self._pesos[indice] = valor

	def get_peso_total(self):
		"""calcula a somnatória de Pesos[]"""
		acumulador = 0.0
		indice = 0
		while indice < self._quantidade:
			acumulador += self._pesos[indice]
			indice += 1
		return acumulador

	def juros_para_acrescimo(self, juros):
		"""calcula o acréscimo a partir dos juros e parcelas"""
		peso_total = self.get_peso_total()
		if self._quantidade < 1 or self._periodo <= 0.0 or juros <= 0.0 or peso_total <= 0.0:
			return 0.0
		acumulador = 0.0
		indice = 0
		while indice < self._quantidade:
			if self._composto:
				acumulador += self._pesos[indice] / math.pow(1.0 + juros / 100.0, self._pagamentos[indice] / self._periodo)
			else:
				acumulador += self._pesos[indice] / (1.0 + juros / 100.0 * self._pagamentos[indice] / self._periodo)
			indice += 1
		if acumulador <= 0.0:
			return 0.0
		return (peso_total / acumulador - 1.0) * 100.0

	def acrescimo_para_juros(self, acrescimo, precisao, max_iteracoes, max_juros):
		"""calcula os juros a partir do acréscimo e parcelas"""
		peso_total = self.get_peso_total()
		if self._quantidade < 1 or self._periodo <= 0.0 or acrescimo <= 0.0 or peso_total <= 0.0 or precisao < 1 or max_iteracoes < 1 or max_juros <= 0.0:
			return 0.0
		min_juros = 0.0
		med_juros = max_juros / 2.0
		min_diferenca = math.pow(0.1, precisao)
		for _ in range(max_iteracoes):
			if max_juros - min_juros < min_diferenca:
				return med_juros
			if self.juros_para_acrescimo(med_juros) < acrescimo:
				min_juros = med_juros
			else:
				max_juros = med_juros
			med_juros = (min_juros + max_juros) / 2.0
		return med_juros

	@staticmethod
	def testa():
		quantidade = 3
		composto = True
		periodo = 30.0
		juros = Juros()
		juros.init(quantidade, composto, periodo)
		for indice in range(quantidade):
			juros.set_pagamentos(indice, (indice + 1.0) * periodo)
			juros.set_pesos(indice, 1.0)
		peso_total = juros.get_peso_total()
		acrescimo_calculado = juros.juros_para_acrescimo(3.0)
		juros_calculado = juros.acrescimo_para_juros(acrescimo_calculado, 15, 100, 50.0)
		print(f"Peso total = {peso_total}")
		print(f"Acrescimo = {acrescimo_calculado}")
		print(f"Juros = {juros_calculado}")
