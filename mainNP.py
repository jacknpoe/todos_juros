# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 13/07/2026: copiada a solução em Python e adaptada para NumPy
#
# NOTA IMPORTANTE: no benchmark com 300.000 parcelas:
#                  • Python puro = ~ 16 s,
#                  • com NumPy = 0,330 s
#                  relação = 1 / 48,48484848...

import JurosNP

# cria um objeto juros da classe jurosNP, inicializa escalares e seta arrays
juros = JurosNP.JurosNP(3, True, 30.0)
juros.setpagamentos()
juros.setpesos()

# calcula e guarda os resultados dos métodos
pesototal = juros.getpesototal()
acrescimocalculado = juros.jurosparaacrescimo(3.0)
juroscalculado = juros.acrescimoparajuros(acrescimocalculado)

# imprime os resultados
print("Peso total = " + str(pesototal))
print("Acréscimo = " + str(acrescimocalculado))
print("Juros = " + str(juroscalculado))
