# Calcula o acrescimo a partir dos juros e os juros a partir do acrescimo
# Versoes 0.1 24/08/2023 Primeiros metodos e propriedades, para testes
#         0.2 25/08/2023 Calculos e testes com prints
#         0.3 04/06/2024 apenas ASCII para Jython
import Juros_jython

juros = Juros_jython.Juros(3, True, 30.0)
juros.setpagamentos(",", "30.0,60.0,90.0")
juros.setpesos(",", "1.0,1.0,1.0")

print("Peso total = " + str(juros.getpesototal()))
print("Acrescimo = " + str(juros.jurosparaacrescimo(3.0)))
print("Juros = " + str(juros.acrescimoparajuros(juros.jurosparaacrescimo(3.0), 18)))
