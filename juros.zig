// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 17/06/2024: versão feita sem muito conhecimento de Zig

const std = @import("std");
const math = std.math;

// estutura básica para simplificar as chamadas
const Juros = struct {
    quantidade: i16,
    composto: bool,
    periodo: f64,
    pagamentos: std.ArrayList(f64), // alterar esses valores
    pesos: std.ArrayList(f64), // para sua necessidade

    // calcula a somatória de pesos[]
    pub fn getPesoTotal(self: Juros) f64 {
        var acumulador: f64 = 0.0;
        var indice: usize = 0;
        while (indice < self.quantidade) {
            acumulador += self.pesos.items[indice];
            indice += 1;
        }
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    pub fn jurosParaAcrescimo(self: Juros, juros: f64) f64 {
        const pesoTotal = self.getPesoTotal();
        if (juros <= 0.0 or self.quantidade < 1 or self.periodo <= 0.0 or pesoTotal <= 0.0) {
            return 0.0;
        }
        var acumulador: f64 = 0.0;
        var indice: usize = 0;

        while (indice < self.quantidade) {
            if (self.composto) {
                acumulador += self.pesos.items[indice] / math.pow(f64, 1 + juros / 100.0, self.pagamentos.items[indice] / self.periodo);
            } else {
                acumulador += self.pesos.items[indice] / (1 + juros / 100.0 * self.pagamentos.items[indice] / self.periodo);
            }
            indice += 1;
        }

        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e parcelas
    pub fn acrescimoParaJuros(self: Juros, acrescimo: f64, precisao: f64, maxIteracoes: i16, maximoJuros: f64) f64 {
        const pesoTotal = self.getPesoTotal();
        if (acrescimo <= 0.0 or self.quantidade < 1 or self.periodo <= 0.0 or pesoTotal <= 0.0 or precisao < 1 or maxIteracoes < 1 or maximoJuros <= 0.0) {
            return 0.0;
        }
        var minJuros: f64 = 0.0;
        var medJuros: f64 = maximoJuros / 2.0;
        var maxJuros: f64 = maximoJuros;
        const minDiferenca: f64 = math.pow(f64, 0.1, precisao);
        var indice: usize = 0;

        while (indice < maxIteracoes) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if ((maxJuros - minJuros) < minDiferenca) {
                return medJuros;
            }
            if (self.jurosParaAcrescimo(medJuros) < acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }

            indice += 1;
        }

        return medJuros;
    }
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const alocador = std.heap.page_allocator;
    const quantidade = 3;

    // cria os arrays de pagamentos e pesos
    var pagamentos = std.ArrayList(f64).init(alocador);
    var pesos = std.ArrayList(f64).init(alocador);
    var indice: f64 = 0;
    while (indice < quantidade) {
        try pagamentos.append((indice + 1.0) * 30.0);
        try pesos.append(1.0);
        indice += 1;
    }

    // cria um objeto oJuros do tipo Juros e incializa os valores
    const oJuros = Juros{ .quantidade = quantidade, .composto = true, .periodo = 30.0, .pagamentos = pagamentos, .pesos = pesos };

    // calcula e guarda os retornos das funções
    const pesoTotal: f64 = oJuros.getPesoTotal();
    const acrescimoCalculado: f64 = oJuros.jurosParaAcrescimo(3.0);
    const jurosCalculado: f64 = oJuros.acrescimoParaJuros(acrescimoCalculado, 15.0, 100, 50);

    // imprime os resultados
    try stdout.print("Peso total = {d}\n", .{pesoTotal});
    try stdout.print("Acrescimo = {d}\n", .{acrescimoCalculado});
    try stdout.print("Juros = {d}\n", .{jurosCalculado});
}
