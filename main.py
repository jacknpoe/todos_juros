# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 24/08/2023: Primeiros métodos e propriedades, para testes
#          0.2: 25/08/2023: Cálculos e testes com prints
#          0.3: 10/07/2024: melhorados alguns ifs (depois de total) e números ponto flutuantes com .0
#          0.4: 12/07/2024: corrigido o soZero, que não deveria existir
#          0.5: 16/07/2024: corrigidos alguns valores padrão que não estavam em ponto flutuante
#          0.6: 20/12/2024: com acentuação (Latin1)
#          0.7: 22/07/2025: não enviadas as três primeiras parcelas nas linhas 15 e 16
#          0.8: 17/02/2026: corrigidas posições da documentação dos métodos
#          0.9: 18/03/2026: except pass para o infinito em **
#          1.0: 28/06/2026: preparado para novo artigo no blog, alterado de "total" para "pesototal" nos métodos,
#                           removido acrescimocomovalororiginal, mais comentários, restaurada a acentuação e removida a diretiva de codificação
#          1.1: 07/07/2026: finalizada preparação para publicação, agora no repositório, quebra de linha no primeiro if de acrescimoparajuros

import Juros

# cria um objeto juros da classe juros, inicializa escalares e seta arrays
juros = Juros.Juros(3, True, 30.0)
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
