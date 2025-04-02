function acrescimo = jurosParaAcrescimoFM(ojuros, juros)
    pesoTotal = getPesoTotalFM(ojuros);
    if(ojuros.quantidade < 1 | ojuros.periodo <= 0.0 | pesoTotal <= 0.0 | juros <= 0.0)
        acrescimo = 0.0;
        return;
    end
    
    acumulador = 0.0;
    for indice = 1 : ojuros.quantidade
        if(ojuros.composto)
            acumulador = acumulador + ojuros.pesos(indice) / (1.0 + juros / 100.0) ^ (ojuros.pagamentos(indice) / ojuros.periodo);
        else
            acumulador = acumulador + ojuros.pesos(indice) / (1.0 + juros / 100.0 * ojuros.pagamentos(indice) / ojuros.periodo);
        end
    end
    
    if(acumulador <= 0.0)
        acrescimo = 0.0;
        return;
    end
    acrescimo = (pesoTotal / acumulador - 1.0) * 100.0;