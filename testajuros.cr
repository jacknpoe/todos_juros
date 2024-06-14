# importa a classe juros
require "./juros.cr"

# cria um objeto e define seus atributos
oJuros = Juros.new(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0])

# calcula e guarda os retornos dos métodos
pesoTotal = oJuros.getPesoTotal
acrescimoCalculado = oJuros.jurosParaAcrescimo(3.0)
jurosCalculado = oJuros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

# imprime os resultados
puts "Peso total = #{pesoTotal}"
puts "Acréscimo = #{acrescimoCalculado}"
puts "Juros = #{jurosCalculado}"