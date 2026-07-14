# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 14/07/2026: copiada a solução em NumPy e adaptada para PyTorch
#
# NOTA IMPORTANTE: no benchmark com 300.000 parcelas:
#                  • Python puro = ~ 16 s
#                  • com PyTorch = 2,018 s
#                  relação = 1 / 7,928642...
#                  • com NumPy = 0,330 s
#                  relação = 1 / 48,48484848...

import JurosPT

# cria um objeto juros da classe jurosPT, inicializa escalares e seta arrays
juros = JurosPT.JurosPT(3, True, 30.0)
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
