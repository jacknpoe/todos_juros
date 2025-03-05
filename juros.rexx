/* Cálculo dos juros, sendo que precisa de parcelas pra isso */
/* Versão 0.1: 05/06/2025: versão feita sem muito conhecimento de Object Rexx */

::class juros public
    /* atributos simplificam as chamadas aos métodos */
    ::attribute Quantidade
    ::attribute Composto
    ::attribute Periodo
    ::attribute Pagamentos
    ::attribute Pesos
    
    /* o construtor inicializa os atributos escalares e aloca memória para os arrays */
    ::method init
        use arg quantidade, composto, periodo
        self~Quantidade = quantidade
        self~Composto = composto
        self~Periodo = periodo
        self~Pagamentos = .array~new(quantidade)
        self~Pesos = .array~new(quantidade)

    /* calcula a somatória de Pesos[] */
    ::method getPesoTotal
        acumulador = 0.0
        loop indice = 1 to self~Quantidade
            acumulador += self~Pesos[indice]
        end
        return acumulador

    /* calcula o acréscimo a partir dos juros e parcelas */
    ::method jurosParaAcrescimo
        use arg juros
        pesoTotal = self~getPesoTotal()
        if self~Quantidade < 1 | self~Periodo <= 0.0 | juros <= 0.0 | pesoTotal <= 0.0 then return 0.0

        acumulador = 0.0
        loop indice = 1 to self~Quantidade
            if self~Composto then acumulador += self~Pesos[indice] / RxCalcPower(1.0 + juros / 100.0, self~Pagamentos[indice] / self~Periodo)
            else acumulador += self~Pesos[indice] / (1.0 + juros / 100.0 * self~Pagamentos[indice] / self~Periodo)
        end

        if acumulador <= 0.0 then return 0.0
        return (pesoTotal / acumulador - 1.0) * 100.0

    /* calcula os juros a partir do acréscimo e parcelas */
    ::method acrescimoParaJuros
        use arg acrescimo, precisao, maxIteracoes, maxJuros
        pesoTotal = self~getPesoTotal()
        if self~Quantidade < 1 | self~Periodo <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0 | pesoTotal <= 0.0 then return 0.0

        minJuros = 0.0
        minDiferenca = RxCalcPower(0.1, precisao)
        loop indice = 1 to maxIteracoes
            medJuros = (minJuros + maxJuros) / 2.0
            if (maxJuros - minJuros) < minDiferenca then return medJuros
            if self~jurosParaAcrescimo(medJuros) < acrescimo then minJuros = medJuros
            else maxJuros = medJuros
        end

        return medJuros

::requires 'rxmath' library  /* para RxCalcPower() */