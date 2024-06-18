# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 18/06/2024: versão feita sem muito conhecimento de Ring

# define a impressão de quinze casas decimais depois da vírgula
decimals(15)

# define os atributos para a "classe" Juros para simplificar as chamadas
eval("class Juros quantidade composto periodo pagamentos pesos")

# calcula a somatória do array pesos[]
func getPesoTotal pJuros
    acumulador = 0.0
    for indice = 1 to pJuros.quantidade
        acumulador += pJuros.pesos[indice]
    next
    return acumulador

# calcula o acréscimo a partir dos juros e parcelas
func jurosParaAcrescimo pJuros, juros
    pesoTotal = getPesoTotal(pJuros)
    if juros <= 0.0 or pJuros.quantidade < 1 or pJuros.periodo <= 0.0 or pesoTotal <= 0.0
        return 0.0
    ok
    acumulador = 0.0

    for indice = 1 to pJuros.quantidade
        if pJuros.composto
            acumulador += pJuros.pesos[indice] / (1.0 + juros / 100.0) ** (pJuros.pagamentos[indice] / pJuros.periodo)
        else
            acumulador += pJuros.pesos[indice] / (1.0 + juros / 100.0 * pJuros.pagamentos[indice] / pJuros.periodo)
        ok
    next

    return (pesoTotal / acumulador - 1.0) * 100.0

# calcula os juros a partir do acréscimo e parcelas
func acrescimoParaJuros pJuros, acrescimo, precisao, maxIteracoes, maxJuros
    pesoTotal = getPesoTotal(pJuros)
    if acrescimo <= 0.0 or pJuros.quantidade < 1 or pJuros.periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0
        return 0.0
    ok
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = 0.1 ** precisao

    for indice = 1 to maxIteracoes
        medJuros = (minJuros + maxJuros) / 2.0
        if (maxJuros - minJuros) < minDiferenca
            return medJuros
        ok
        if jurosParaAcrescimo(pJuros, medJuros) < acrescimo
            minJuros = medJuros
        else
            maxJuros = medJuros
        ok
    next

    return medJuros

func main
    # cria um objeto oJuros da classe Juros e define suas propriedades
    oJuros = new Juros {quantidade=3 composto=true periodo=30.0 pagamentos=[30.0,60.0,90.0] pesos=[1.0,1.0,1.0]}

    # calcula e guarda os resultados dos métodos
    pesoTotal = getPesoTotal(oJuros)
    acrescimoCalculado = jurosParaAcrescimo(oJuros, 3.0)
    jurosCalculado = acrescimoParaJuros(oJuros, acrescimoCalculado, 15, 100, 50.0)

    # imprime os resultados
    see "Peso total = " + string(pesoTotal) + "!" + nl
    see "Acrescimo = " + string(acrescimoCalculado) + "!" + nl
    see "Juros = " + string(jurosCalculado) + "!" + nl
