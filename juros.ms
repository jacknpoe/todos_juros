// Cálculo dos juros, sendo que precisa de parcelas pra isso
//  Versão 0.1: 14/02/2026: versão feita sem muito conhecimento de MiniScript

// estrutura dos atributos da classe Juros, para simplificar os chamados aos métodos
Juros = { "Quantidade": 0, "Composto": 0, "Periodo": 0.0, "Pagamentos": [], "Pesos": [] }

// para poder mostrar 15 casas decimais (o print só mostrava 6)
formatFloat = function (x, casas)
    sinal = ""
    if x < 0 then
        sinal = "-"
        x = -x
    end if

    inteiro = floor(x)
    fracao = x - inteiro + 0.5 * .1 ^ casas

    cadeia = sinal + inteiro

    if casas > 0 then
        cadeia = cadeia + "."
        for indice in range(1, casas)
            fracao = fracao * 10
            dig = floor(fracao)
            cadeia = cadeia + char(48 + dig)
            fracao = fracao - dig
        end for
    end if

    return cadeia
end function

// calcula a somatória dos elementos da lista Pesos[]
Juros.getPesoTotal = function()
    acumulador = 0.0
    for indice in range(0, self.Quantidade - 1)
        acumulador = acumulador + self.Pesos[indice]
    end for
    return acumulador
end function

// calcula o acréscimo a partir dos juros e parcelas
Juros.jurosParaAcrescimo = function(juros)
    pesoTotal = self.getPesoTotal()
    if self.Quantidade < 1 or self.Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then
        return 0.0
    end if
    acumulador = 0.0
    for indice in range(0, self.Quantidade - 1)
        if self.Composto == 1 then
            acumulador = acumulador + self.Pesos[indice] / (1.0 + juros / 100.0) ^ (self.Pagamentos[indice] / self.Periodo)
        else
            acumulador = acumulador + self.Pesos[indice] / (1.0 + juros / 100.0 * self.Pagamentos[indice] / self.Periodo)
        end if
    end for

    if acumulador <= 0.0 then
        return 0.0
    end if
    return (pesoTotal / acumulador - 1.0) * 100.0
end function

// calcula os juros a partir do acréscimo e parcelas
Juros.acrescimoParaJuros = function(acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = self.getPesoTotal()
    if self.Quantidade < 1 or self.Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then
        return 0.0
    end if
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = 0.1 ^ precisao

    for iteracao in range(1, maxIteracoes)
        if maxJuros - minJuros < minDiferenca then
            return medJuros
        end if
        if self.jurosParaAcrescimo(medJuros) < acrescimo then
            minJuros = medJuros
        else
            maxJuros = medJuros
        end if
        medJuros = (minJuros + maxJuros) / 2.0
    end for
    return medJuros
end function

// cria um objeto juros da classe Juros e inicializa os atributos escalares
juros = new Juros
juros.Quantidade = 3
juros.Composto = 1  // 0 para juros simples, 1 para juros compostos
juros.Periodo = 30.0

// acrescenta elementos aos atributos que são listas
for indice in range(0, juros.Quantidade - 1)
    juros.Pagamentos.push((indice + 1.0) * juros.Periodo)
    juros.Pesos.push(1.0)
end for

// calcula e guarda os resultados
pesoTotal = juros.getPesoTotal()
acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

// imprime os resultados
print "Peso total = " + formatFloat(pesoTotal, 15)
print "Acréscimo = " + formatFloat(acrescimoCalculado, 15)
print "Juros = " + formatFloat(jurosCalculado, 15)
