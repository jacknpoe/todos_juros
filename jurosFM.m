function obj = jurosFM(qtd, cmp, per, pag, pes)
    obj.quantidade = qtd;
    obj.composto = cmp;
    obj.periodo = per;
    obj.pagamentos = pag;
    obj.pesos = pes;
    obj = class(obj, 'jurosFM');