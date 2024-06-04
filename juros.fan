// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 04/06/2024: versão feita sem muito conhecimento de Fantom

// classe com atributos para simplificar as chamadas
class Juros {
    Int quantidade
    Bool composto
    Float periodo
    Float[] pagamentos
    Float[] pesos
    
    // construtor, que inicializa todos os atributos
    new make(Int quantidade, Bool composto, Float periodo, Float[] pagamentos, Float[] pesos) {
        this.quantidade = quantidade
        this.composto = composto
        this.periodo = periodo
        this.pagamentos = pagamentos
        this.pesos = pesos
    }

    // calcula a somatória de Pesos[]
    Float getPesoTotal() {
        Float acumulador := 0.0f
        for (indice := 0; indice < this.quantidade; indice++) acumulador += this.pesos[indice]
        return acumulador
    }

    // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    Float jurosParaAcrescimo(Float juros) {
        Float pesoTotal := this.getPesoTotal()
        if (juros <= 0.0f || this.quantidade < 1 || this.periodo <= 0.0f || pesoTotal <= 0.0f) return 0.0f
        Float acumulador := 0.0f

        for (indice := 0; indice < this.quantidade; indice++)
            if (this.composto) acumulador += this.pesos[indice] / (1.0f + juros / 100.0f).pow(this.pagamentos[indice] / this.periodo)
                else acumulador += this.pesos[indice] / (1.0f + juros / 100.0f * this.pagamentos[indice] / this.periodo)

        return (pesoTotal / acumulador - 1.0f) * 100.0f
    }

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    Float acrescimoParaJuros(Float acrescimo, Float precisao, Int maxIteracoes, Float maxJuros) {
        Float pesoTotal := this.getPesoTotal()
        if (maxIteracoes < 1 || this.quantidade < 1 || precisao <= 0.0f || this.periodo <= 0.0f || acrescimo <= 0.0f || maxJuros <= 0.0f || pesoTotal <= 0.0f) return 0.0f
        Float minJuros := 0.0f
        Float medJuros := maxJuros / 2.0f
        Float minDiferenca := (0.1f).pow(precisao)

        for (indice := 0; indice < maxIteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2.0f
            if ((maxJuros - minJuros) < minDiferenca) return medJuros
            if(this.jurosParaAcrescimo(medJuros) < acrescimo) minJuros = medJuros
                else maxJuros = medJuros
        }

        return medJuros
    }
}

class Principal
{
  static Void main()
  {
    // cria o objeto juros da classe Juros e inicializa os atributos
    juros := Juros(3, true, 30.0f, [30.0f, 60.0f, 90.0f], [1.0f, 1.0f, 1.0f])

    // chama as funções para testes
    Float pesoTotal := juros.getPesoTotal()
    Float acrescimoCalculado := juros.jurosParaAcrescimo(3.0f)
    Float jurosCalculado := juros.acrescimoParaJuros(acrescimoCalculado, 15.0f, 100, 50.0f)

    // imprime os testes
    echo("Peso total = " + pesoTotal)
    echo("Acrescimo = " + acrescimoCalculado)
    echo("Juros = " + jurosCalculado)
  }
}