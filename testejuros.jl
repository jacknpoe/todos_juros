include("juros.jl")

# testes de juros.jl
juros = Juros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0])
println(getPesoTotal(juros))
println(jurosParaAcrescimo(juros, 3.0))
println(acrescimoParaJuros(juros, jurosParaAcrescimo(juros, 3.0), 15, 100, 50.0))