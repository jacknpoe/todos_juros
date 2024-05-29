// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 29/05/2024: versão feita sem muito conhecimento de Haxe

// classe com a estrutura básica para simplificar as chamadas
class TJuros {
    var Quantidade: Int;
    var Composto: Bool;
    var Periodo: Float;
    var Pagamentos: Array<Float> = [];
    var Pesos: Array<Float> = [];

    // construtor que recebe todos os valores para todos os atriburos
    public function new(quantidade, composto, periodo, pagamentos, pesos) {
        this.Quantidade = quantidade;
        this.Composto = composto;
        this.Periodo = periodo;
        for (indice in 0...quantidade) {
            this.Pagamentos.push(pagamentos[indice]);
            this.Pesos.push(pesos[indice]);
        }
    }

    // retorna a somatória de Pesos[]
    public function getPesoTotal() {
        var acumulador: Float = 0.0;
        for (indice in 0...this.Quantidade) {
            acumulador += this.Pesos[indice];
        }
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
    public function jurosParaAcrescimo(juros) {
        var pesoTotal: Float = this.getPesoTotal();
        if (juros <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0 || pesoTotal <= 0.0) return 0.0;
        var acumulador: Float = 0.0;

        for (indice in 0...this.Quantidade) {
            if (this.Composto) {
                acumulador += this.Pesos[indice] / Math.pow(1.0 + juros / 100.0, this.Pagamentos[indice] / this.Periodo);
            } else {
                acumulador += this.Pesos[indice] / (1.0 + juros / 100.0 * this.Pagamentos[indice] / this.Periodo);
            }
        }

        return (pesoTotal / acumulador - 1.0 ) * 100.0;
    }

    // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
    public function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
        var pesoTotal: Float = this.getPesoTotal();
        if (acrescimo <= 0.0 || this.Quantidade < 1 || this.Periodo <= 0 || pesoTotal <= 0.0 || maxIteracoes < 1 || precisao < 1 || maxJuros <= 0.0) return 0.0;
        var minJuros: Float = 0.0;
        var medJuros: Float = maxJuros / 2.0;
        var minDiferenca: Float = Math.pow(0.1, precisao);

        for (indice in 0...maxIteracoes) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if ((maxJuros - minJuros) < minDiferenca) return medJuros;
            if (this.jurosParaAcrescimo(medJuros) < acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }
        }

        return medJuros;
    }
}

class Juros {
    static function main() {
        // cria o objeto juros da classe TJuros e inicializa os valores
        var juros = new TJuros(3, true, 30.0, [30.0, 60.0, 90.0], [1.0, 1.0, 1.0]);

        // variáveis que testam os retornos das funções e impressão
        var pesoTotal: Float = juros.getPesoTotal();
        var acrescimoCalculado: Float = juros.jurosParaAcrescimo(3.0);
        var jurosCalculado: Float = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);
        Sys.print("Peso total = " + pesoTotal + "\n");
        Sys.print("Acréscimo = " + acrescimoCalculado + "\n");
        Sys.print("Juros = " + jurosCalculado + "\n");
    }
}