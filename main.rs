mod juros;

/// versão: 0.1 13/03/2024: com juros em main
///         0.2 19/03/2024: com juros em juros
///         0.3 19/03/2024: com chamadas por referência em pagamentos e pesos
///         0.4 04/04/2024: trocada avaliação soZero por acumulador == 0
///         0.4 11/04/2024: melhorados comentários e colocadas legendas nos testes
///         0.5 18/07/2025: para mais de três parcelas, com preenchimento dinâmico

fn main() {
    // testes das funções
    let quantidade: usize = 3;
    let composto: bool = true;
    let periodo: f64 = 30.0;
    let mut pagamentos: Vec<f64> = vec![0.0; quantidade];
    let mut pesos: Vec<f64> = vec![0.0; quantidade];

    let mut prox_pag: f64 = periodo;
    for indice in 0..quantidade {
        pagamentos[indice] = prox_pag;
        pesos[indice] = 1.0;
        prox_pag = prox_pag + periodo;
    }

    let juros = juros::Juros::novo(quantidade, composto, periodo, &pagamentos, &pesos);
    println!("Peso total = {}", juros.get_peso_total());
    println!("Acréscimo = {}", juros.juros_para_acrescimo(3.0));
    println!("Juros = {}", juros.acrescimo_para_juros(juros.juros_para_acrescimo(3.0), 15.0, 100, 50.0));
}
