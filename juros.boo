// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 14/05/2026: feita sem muito conhecimento de Boo
// ATENÇÃO: a classe funcionou no Ubuntu 16.04.7 LTS + Mono 4.2.1

// classe com atributos para simplificar as chamadas aos métodos
class Juros:
    _quantidade as int
    _composto as bool
    _periodo as double
    _pagamentos as (double)
    _pesos as (double)

    // o consrutor inicializa os atributos escalares e aloca os arrays
    def constructor(quantidade as int, composto as bool, periodo as double):
        _quantidade = quantidade
        _composto = composto
        _periodo = periodo
        _pagamentos = array(double, quantidade)
        _pesos = array(double, quantidade)

    // propriedade Quantidade
    Quantidade as int:
        get:
            return _quantidade
        set:
            _quantidade = value
            _pagamentos = array(double, value)
            _pesos = array(double, value)

    // propriedade Composto
    Composto as bool:
        get:
            return _composto
        set:
            _composto = value

    // propriedade Periodo
    Periodo as double:
        get:
            return _periodo
        set:
            _periodo = value

    // propriedade Pagamentos
    Pagamentos[index as int] as double:
        get:
            return _pagamentos[index]
        set:
            _pagamentos[index] = value

    // propriedade Pesos
    Pesos[index as int] as double:
        get:
            return _pesos[index]
        set:
            _pesos[index] = value

    // calcula a somatória dos elementos no array Pesos[]
    def getPesoTotal() as double:
        acumulador as double = 0.0
        for indice in range(_quantidade):
            acumulador += _pesos[indice]
        return acumulador

    // calcula o acréscimo a partir dos juros e parcelas
    def jurosParaAcrescimo(juros as double) as double:
        pesoTotal as double = getPesoTotal()
        if _quantidade < 1 or _periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0:
            return 0.0
        acumulador as double = 0.0

        for indice in range(_quantidade):
            if _composto:
                acumulador += _pesos[indice] / (1.0 + juros / 100.0) ** (_pagamentos[indice] / _periodo)
            else:
                acumulador += _pesos[indice] / (1.0 + juros / 100.0 * _pagamentos[indice] / _periodo)

        if acumulador <= 0.0:
            return 0.0
        return (pesoTotal / acumulador - 1.0) * 100.0
    
    // calcula os juros a partir do acréscimo e parcelas
    def acrescimoParaJuros(acrescimo as double, precisao as int, maxIteracoes as int, maxJuros as double) as double:
        pesoTotal as double = getPesoTotal()
        if _quantidade < 1 or _periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0:
            return 0.0
        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = 0.1 ** precisao

        for indice in range(maxIteracoes):
            if maxJuros - minJuros <= minDiferenca:
                return medJuros
            if jurosParaAcrescimo(medJuros) < acrescimo:
                minJuros = medJuros
            else:
                maxJuros = medJuros
            medJuros = (minJuros + maxJuros) / 2.0
        
        return medJuros

// programa principal
def main():
    // cria um objeto juros da classe Juros e inicializa os atributos escalares
    juros = Juros(3, true, 30.0)

    // inicializa os atributos array Pagamentos[] e Pesos[]
    for indice in range(juros.Quantidade):
        juros.Pagamentos[indice] = (indice + 1.0) * juros.Periodo
        juros.Pesos[indice] = 1.0

    // calcula e guarda os resultados dos métodos
    pesoTotal as double = juros.getPesoTotal()
    acrescimoCalculado as double = juros.jurosParaAcrescimo(3.0)
    jurosCalculado as double = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

    // imprime os resultados
    print "Peso total = $(pesoTotal)"
    print "Acréscimo = $(acrescimoCalculado)"
    print "Juros = $(jurosCalculado)"

// chama o programa principal
main()
