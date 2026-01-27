// jurosQML.js compatível com QML
// a conversão de classe para protótipos foi feita com a ajuda do ChatGPT, mas segue a lógica original em JavaScript

function Juros(quantidade, composto, periodo) {
    this.Quantidade = quantidade || 0;
    this.Composto = !!composto;
    this.Periodo = periodo || 30.0;
    this.Pagamentos = [];
    this.Pesos = [];
}

// define os pagamentosd
Juros.prototype.setPagamentos = function(delimitador, pagamentos) {
    delimitador = delimitador || ",";
    pagamentos = pagamentos || "";
    if (pagamentos === "") {
        for (var c = 0; c < this.Quantidade; c++) {
            this.Pagamentos[c] = (1.0 + c) * this.Periodo;
        }
    } else {
        var temp = pagamentos.split(delimitador);
        for (var c = 0; c < this.Quantidade; c++) {
            if (isNaN(Number(temp[c]))) return false;
            this.Pagamentos[c] = Number(temp[c]);
        }
    }
    return true;
};

// define os pesos
Juros.prototype.setPesos = function(delimitador, pesos) {
    delimitador = delimitador || ",";
    pesos = pesos || "";
    if (pesos === "") {
        for (var c = 0; c < this.Quantidade; c++) {
            this.Pesos[c] = 1.0;
        }
    } else {
        var temp = pesos.split(delimitador);
        for (var c = 0; c < this.Quantidade; c++) {
            if (isNaN(Number(temp[c]))) return false;
            this.Pesos[c] = Number(temp[c]);
        }
    }
    return true;
};

// retorna a soma total dos pesos
Juros.prototype.getPesoTotal = function() {
    var total = 0.0;
    for (var c = 0; c < this.Quantidade; c++) {
        total += this.Pesos[c];
    }
    return total;
};

// calcula o acréscimo a partir dos juros e parcelas
Juros.prototype.jurosParaAcrescimo = function(juros) {
    juros = juros || 0.0;
    var pesoTotal = this.getPesoTotal();
    if (juros <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;

    var acum = 0.0;
    for (var i = 0; i < this.Quantidade; i++) {
        if (this.Composto) {
            acum += this.Pesos[i] / Math.pow(1.0 + juros / 100.0, this.Pagamentos[i] / this.Periodo);
        } else {
            acum += this.Pesos[i] / (1.0 + juros / 100.0 * this.Pagamentos[i] / this.Periodo);
        }
    }
    if (acum <= 0.0) return 0.0;
    return (pesoTotal / acum - 1.0) * 100.0;
};

// calcula os juros a partir do acréscimo e parcelas
Juros.prototype.acrescimoParaJuros = function(acrescimo, precisao, maxIter, maxJuros) {
    acrescimo = acrescimo || 0.0;
    precisao = precisao || 15;
    maxIter = maxIter || 100;
    maxJuros = maxJuros || 50.0;

    var pesoTotal = this.getPesoTotal();
    if (acrescimo <= 0.0 || precisao < 1 || maxIter < 1 || maxJuros <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;

    var minJuros = 0.0;
    var medJuros = maxJuros / 2.0;
    var minDiferenca = Math.pow(0.1, precisao);

    for (var i = 0; i < maxIter; i++) {
        if ((maxJuros - minJuros) < minDiferenca) return medJuros;
        if (this.jurosParaAcrescimo(medJuros) < acrescimo) {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
        medJuros = (minJuros + maxJuros) / 2.0;
    }
    return medJuros;
};
