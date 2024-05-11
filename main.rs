mod juros;

/// versão: 0.1 13/03/2024: com juros em main
///         0.2 19/03/2024: com juros em juros
///         0.3 19/03/2024: com chamadas por referência em pagamentos e pesos
///         0.4 04/04/2024: trocada avaliação soZero por acumulador == 0
///         0.4 11/04/2024: melhorados comentários e colocadas legendas nos testes
fn main() {
    /// testes das funções
    let pagamentos: Vec<f64> = vec![30.0, 60.0, 90.0];
    let pesos: Vec<f64> = vec![1.0, 1.0, 1.0];
    let juros = juros::Juros::novo(3, true, 30.0, &pagamentos, &pesos);
    println!("Peso total = {}", juros.get_peso_total());
    println!("Acréscimo = {}", juros.juros_para_acrescimo(3.0));
    println!("Juros = {}", juros.acrescimo_para_juros(juros.juros_para_acrescimo(3.0), 15.0, 100, 50.0));
}
