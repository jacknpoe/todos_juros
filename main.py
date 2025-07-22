# coding: latin1

# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 24/08/2023: Primeiros métodos e propriedades, para testes
#          0.2: 25/08/2023: Cálculos e testes com prints
#          0.3: 10/07/2024: melhorados alguns ifs (depois de total) e números ponto flutuantes com .0
#          0.4: 12/07/2024: corrigido o soZero, que não deveria existir
#          0.5: 16/07/2024: corrigidos alguns valores padrão que não estavam em ponto flutuante
#          0.6: 20/12/2024: com acentuação (Latin1)
#          0.7: 22/07/2025: não enviadas as três primeiras parcelas nas linhas 15 e 16

import Juros

juros = Juros.Juros(3, True, 30.0)
juros.setpagamentos(",", "")
juros.setpesos(",", "")

print("Peso total = " + str(juros.getpesototal()))
print("Acrescimo = " + str(juros.jurosparaacrescimo(3.0)))
print("Juros = " + str(juros.acrescimoparajuros(juros.jurosparaacrescimo(3.0), 18)))