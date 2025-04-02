function acumulador = getPesoTotalFM(ojuros)
    acumulador = 0
    for indice = 1 : ojuros.quantidade
        acumulador = acumulador + ojuros.pesos(indice);
    end