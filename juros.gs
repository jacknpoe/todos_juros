// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 13/06/2024: versão feita sem muito conhecimento de Genie
[indent=4]

// classe com atributos para simplificar as chamadas
class Juros
    prop Quantidade : int
    prop Composto : bool
    prop Periodo : double
    prop Pagamentos : GenericArray of double?
    prop Pesos : GenericArray of double?

    // o construtor recebe quantidade, composto e periodo
    construct(quantidade : int, composto : bool, periodo : double)
        Quantidade = quantidade
        Composto = composto
        Periodo = periodo
        Pagamentos = new GenericArray of double?()
        Pesos = new GenericArray of double?()

    // calcula a somatória de Pesos[]
    def getPesoTotal() : double
        var acumulador = 0.0
        for var indice = 0 to (Quantidade - 1)
            acumulador += Pesos[indice]
        return acumulador

    // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    def jurosParaAcrescimo(juros : double) : double
        var pesoTotal = getPesoTotal()
        if juros <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0
            return 0.0
        var acumulador = 0.0

        for var indice = 0 to (Quantidade - 1)
            if Composto
                acumulador += Pesos[indice] / Math.pow(1.0 + juros / 100.0, Pagamentos[indice] / Periodo)
            else
                acumulador += Pesos[indice] / (1.0 + juros / 100.0 * Pagamentos[indice] / Periodo)

        return (pesoTotal / acumulador - 1.0) * 100.0

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    def acrescimoParaJuros(acrescimo : double, precisao : int, maxIteracoes : int, maxJuros : double) : double
        var pesoTotal = getPesoTotal()
        if acrescimo <= 0.0 or Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0
            return 0.0
        var minJuros = 0.0
        var medJuros = maxJuros / 2.0
        var minDiferenca = Math.pow(0.1, precisao)

        for var indice = 1 to maxIteracoes
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca
                return medJuros
            if jurosParaAcrescimo(medJuros) < acrescimo
                minJuros = medJuros
            else
                maxJuros = medJuros

        return medJuros

// print "1,03 ^ 0,5 = " + Math.pow(1.03, 0.5).to_string()

init
    Intl.setlocale( LocaleCategory.ALL, "" )
    
    // cria um objeto juros da classe Juros e inicializa quantidade, composto e periodo
    var juros = new Juros(3, true, 30.0)
    
    // insere as parcelas (pagamentos e pesos)
    for var indice = 1 to juros.Quantidade
        juros.Pagamentos.add(30.0 * indice)
        juros.Pesos.add(1.0)
    
    // executa as funções e guarda os resultados
    var pesoTotal = juros.getPesoTotal()
    var acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
    var jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

    // imprime os resultados
    print "Peso total = " + pesoTotal.to_string()
    print "Acréscimo = " + acrescimoCalculado.to_string()
    print "Juros = " + jurosCalculado.to_string()
