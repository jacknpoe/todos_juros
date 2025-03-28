# coding: latin1
# esse código Python demonstra o uso da classe Juros criada em Ć

import juros  # esse deve ser o arquivo juros.py criado pelo Ć

# para melhorar a leitura
Quantidade = 3
Composto = True
Periodo = 30.0

# cria o objeto juros do tipo Juros e inicializa escalares
juros = juros.Juros();
juros.init(Quantidade, Composto, Periodo)

# inicializa os arrays dinamicamente
for i in range(3):
    juros.set_pagamentos(i, (i + 1.0) * Periodo)
    juros.set_pesos(i, 1.0)

# calcula e guarda os retornos das funções
pesoTotal = juros.get_peso_total()
acrescimoCalculado = juros.juros_para_acrescimo(3.0)
jurosCalculado = juros.acrescimo_para_juros(acrescimoCalculado, 15, 100, 50.0)

# imprime os resultados
print("Peso total = " + str(pesoTotal))
print("Acréscimo = " + str(acrescimoCalculado))
print("Juros = " + str(jurosCalculado))
