// Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
// Versão: 0.1: 08/03/2026: feita sem muito conhecimento de x-lang

// FUNÇÕES ACESSÓRIAS QUE JÁ DEVERIAM ESTAR NO DIALETO, MAS PRECISARAM SER ESCRITAS PARA SE CHEGAR AO NÍVEL "TÉRREO" DA SOLUÇÃO

// essa função é mais precisa com valores mais próximos de 1, como 1.0 a 1.1, que é a faixa em que vai ser usada
fn ln(valor: f64) -> f64 {
    let mut termo: f64 = (valor - 1.0) / (valor + 1.0);
    let mut soma: f64 = 0.0;
    let yy: f64 = termo * termo;
    let MAXLN: f64 = 21.0;

    for indice in 1.0 .. MAXLN {
        soma = soma + termo / (2.0 * indice - 1.0);
        termo = termo * yy;
    }

    2.0 * soma
}

// essa função é mais precisa com valores menores do que 5, que é a faixa em que vai ser usada
fn exp(valor: f64) -> f64 {
    let mut termo: f64 = 1.0;
    let mut soma: f64 = 1.0;
    let MAXEXP: f64 = 31.0;

    for indice in 1.0 .. MAXEXP {
        termo = termo * valor / indice;
        soma = soma + termo;
    }

    soma
}

// essa função tem a precisão boa de acordo com ln() e exp()
fn pow(base: f64, expoente: f64) -> f64 {
    exp(ln(base) * expoente)
}

// essa função é especial para expoentes inteiros (optar por inteiros pode aumentar a precisão, a base pode ser negativa)
// ela é exata para 0.1 ^ precisao, que é muito usada na regra de parada maxJuros - minJuros < minDiferenca, onde minDiferenca = powint(0.1, precisao)
fn powint(base: f64, expoente: i32) -> f64 {
    if expoente < 0 { return powint(1.0 / base, expoente * -1);  }
    if expoente == 0 { return 1.0; }
    if expoente % 2 == 0 { return powint(base * base, expoente / 2); }
    base * powint(base * base, (expoente - 1) / 2)
}

// para imprimir float na notação valor E-15
fn print_float(valor: f64) {
    let MULTIPLICADOR: f64 = powint(10.0, 15);
    print(valor * MULTIPLICADOR);
    print_str("E-15");
}

// FUNÇÕES NO DOMÍNIO DO PROBLEMA/SOLUÇÃO, AQUI É QUE SE ENCONTRA A SOLUÇÃO PARA O PROBLEMA DOS JUROS

// essa função simula um array Pagamentos[] começando em 0.0
fn Pagamentos(quantidade: f64, periodo: f64, indice: f64) -> f64 {
    if indice < 0.0 || indice >= quantidade { return 0.0; }
    (indice + 1.0) * periodo
}

// essa função simula um array Pesos[] começando em 0.0
fn Pesos(quantidade: f64, periodo: f64, indice: f64) -> f64 {
    if indice < 0.0 || indice >= quantidade { return 0.0; }
    1.0
}

// calcula a somatória dos elementos no "array" Pesos
fn getPesoTotal(quantidade: f64, periodo: f64) -> f64 {
    let mut acumulador: f64  = 0.0;
    for indice in 0 .. quantidade { acumulador = acumulador + Pesos(quantidade, periodo, indice); }
    acumulador
}

// calcula o acréscimo a partir dos juros e parcelas
fn jurosParaAcrescimo(quantidade: f64, composto: bool, periodo: f64, juros: f64) -> f64 {
    let pesoTotal: f64 = getPesoTotal(quantidade, periodo);
    if quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 { return 0.0; }
    let mut acumulador: f64 = 0.0;

    for indice in 0.0 .. quantidade {
        if composto {
            acumulador = acumulador + Pesos(quantidade, periodo, indice) / pow(1.0 + juros / 100.0, Pagamentos(quantidade, periodo, indice) / periodo);
        } else {
            acumulador = acumulador + Pesos(quantidade, periodo, indice) / (1.0 + juros / 100.0 * Pagamentos(quantidade, periodo, indice) / periodo);
        }
    }

    if acumulador <= 0.0 { return 0.0; }
    (pesoTotal / acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e parcelas
fn acrescimoParaJuros(quantidade: f64, composto: bool, periodo: f64, acrescimo: f64, precisao: i32, maxIteracoes: i32, maxJuros: f64) -> f64 {
    let pesoTotal: f64 = getPesoTotal(quantidade, periodo);
    if quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 { return 0.0; }
    let mut minJuros = 0.0;
    let mut medJuros = maxJuros / 2.0;
    let minDiferenca = powint(0.1, precisao);

    for iteracao in 0 .. maxIteracoes {
        if maxJuros - minJuros < minDiferenca { return medJuros; }
        if jurosParaAcrescimo(quantidade, composto, periodo, medJuros) < acrescimo {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
        medJuros = (minJuros + maxJuros) / 2.0;
    }

    medJuros
}

fn main() {
    // variáveis para simplificar a leitura
    let Quantidade: f64 = 3.0;
    let Composto: bool = true;
    let Periodo: f64 = 30.0;

    // calcula e guarda os resultados das funções
    let pesoTotal: f64 = getPesoTotal(Quantidade, Periodo);
    let acrescimoCalculado: f64 = jurosParaAcrescimo(Quantidade, Composto, Periodo, 3.0);
    let jurosCalculado: f64 = acrescimoParaJuros(Quantidade, Composto, Periodo, acrescimoCalculado, 15, 65, 50.0);

    // imprime os resultados
    print_str("Peso total = ");
    print_float(pesoTotal);
    print_str("Acréscimo = ");
    print_float(acrescimoCalculado);
    print_str("Juros = ");
    print_float(jurosCalculado);
}

main();
