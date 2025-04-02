function juros = acrescimoParaJuros(ojuros, acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = getPesoTotalFM(ojuros);
    if(ojuros.quantidade < 1 | ojuros.periodo <= 0.0 | pesoTotal <= 0.0 | acrescimo <= 0.0 | precisao < 1 | maxIteracoes < 1 | maxJuros <= 0.0)
        juros = 0.0;
        return;
    end
    
    minJuros = 0.0;
    juros = maxJuros / 2.0;
    minDiferenca = 0.1 ^ precisao;
    for indice = 1 : maxIteracoes
        if(maxJuros - minJuros < minDiferenca)
            return;
        end
        if(jurosParaAcrescimoFM(ojuros, juros) < acrescimo)
            minJuros = juros;
        else
            maxJuros = juros;
        end
        juros = (minJuros + maxJuros) / 2.0;
    end