# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões
# 0.1 24/08/2023 Primeiros métodos e propriedades, para testes
# 0.2 25/08/2023 Cálculos e testes com prints
import Juros

juros = Juros.Juros(3, True, 30)
juros.setpagamentos(",", "30.0,60.0,90.0")
juros.setpesos(",", "1.0,1.0,1.0")

print("Peso total = " + str(juros.getpesototal()))
print("Acrescimo = " + str(juros.jurosparaacrescimo(3.0)))
print("Juros = " + str(juros.acrescimoparajuros(juros.jurosparaacrescimo(3.0), 18)))