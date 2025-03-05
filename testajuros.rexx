/* cria um objeto oJuros da classe juros e inicializa os atributos */
oJuros = .juros~new(3, .true, 30.0)

loop indice = 1 to oJuros~Quantidade
    oJuros~Pagamentos[indice] = 30.0 * indice
    oJuros~Pesos[indice] = 1.0
end

/* calcula e guarda os resultados dos métodos */
pesoTotal = oJuros~getPesoTotal()
acrescimoCalculado = oJuros~jurosParaAcrescimo(3.0)
jurosCalculado = oJuros~acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

/* imprime os resultados */
say 'Peso total =' pesoTotal
say 'Acrescimo =' acrescimoCalculado
say 'Juros =' jurosCalculado

::requires juros.rexx  /* para ter acesso à classe juros */