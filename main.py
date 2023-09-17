# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões
# 0.1 24/08/2023 Primeiros métodos e propriedades, para testes
# 0.2 25/08/2023 Cálculos e testes com prints
import Juros

juros = Juros.Juros(10, True, 30)
juros.setpagamentos(",", "0,30,60,90,120,150,180,210,240,270")
juros.setpesos(",", "2,1,1,1,1,1,1,1,1,1")

print(juros.Quantidade)
print(juros.Composto)
print(juros.Periodo)
for i in range(juros.Quantidade):
    print(str(juros.Pagamentos[i])+ " / " + str(juros.Pesos[i]))
print(juros.getpesototal())
print(juros.jurosparaacrescimo(30))
print(juros.acrescimoparajuros(acrescimo=juros.jurosparaacrescimo(juros=30), precisao=18))
