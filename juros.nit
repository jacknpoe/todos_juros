# módulo da classe Juros

module juros

# classe Juros tem atributos para simplificar a chamada aos métodos
class Juros
    var quantidade : Int
    var composto : Bool
    var periodo : Float
    var pagamentos : Array[Float] = new Array[Float]
    var pesos : Array[Float] = new Array[Float]

    # calcula a somatória dos elementos do array pesos[]
    fun getPesoTotal : Float do
        var acumulador : Float = 0.0

        for indice in [0..self.quantidade[ do
            acumulador += self.pesos[indice]
        end

        return acumulador
    end

    # calcula o acréscimo a partir dos juros e parcelas
    fun jurosParaAcrescimo(juros : Float) : Float do
        var pesoTotal : Float = self.getPesoTotal
        if self.quantidade < 1 or self.periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then return 0.0
        var acumulador : Float = 0.0

        for indice in [0..self.quantidade[ do
            if self.composto then
                acumulador += self.pesos[indice] / (1.0 + juros / 100.0).pow(self.pagamentos[indice] / self.periodo)
            else
                acumulador += self.pesos[indice] / (1.0 + juros / 100.0 * self.pagamentos[indice] / self.periodo)
            end
        end

        if acumulador <= 0.0 then return 0.0
        return (pesoTotal / acumulador - 1.0) * 100.0
    end

    # calcula os juros a partir do acréscimo e parcelas
    fun acrescimoParaJuros(acrescimo : Float, precisao : Int, maxIteracoes : Int, maxJuros : Float) : Float do
        var pesoTotal : Float = self.getPesoTotal
        if self.quantidade < 1 or self.periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then return 0.0
        var minJuros : Float = 0.0
        var medJuros : Float = maxJuros / 2.0
        var minDiferenca : Float = 0.1.pow(precisao.to_f)

        for iteracao in [1..maxIteracoes] do
            if maxJuros - minJuros < minDiferenca then return medJuros
            if self.jurosParaAcrescimo(medJuros) < acrescimo then minJuros = medJuros else maxJuros = medJuros
            medJuros = (minJuros + maxJuros) / 2.0
        end

        return medJuros
    end
end
