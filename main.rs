mod juros;

/// versão: 0.1 13/03/2024: com juros em main
///         0.2 19/03/2024: com juros em juros
///         0.3 19/03/2024: com chamadas por referência em pagamentos e pesos
///         0.4 04/04/2024: trocada avaliação soZero por acumulador == 0
///         0.4 11/04/2024: melhorados comentários e colocadas legendas nos testes
///         0.5 18/07/2025: para mais de três parcelas, com preenchimento dinâmico
///         0.6 31/05/2026: fork em que não existem vetores em main, apenas em juros; construtor apenas aloca vetores
///                         também criadas variáveis e melhorados os comentários; usando indice para calcular pagamentos
///         0.7 06/06/2026: precisao agora é im i64 que é convertido em f64, Vec::with_capacity(quantidade) no construtor e push no laço
fn main() {
    // valores para os atributos escalares
    let quantidade: usize = 300000;
    let composto: bool = true;
    let periodo: f64 = 30.0;

    // dessa vez, criamos um objeto juros mutável, para permitir que o laço abaixo inicialize os vetores
    let mut juros = juros::Juros::novo(quantidade, composto, periodo);

    // inicializamos os elementos dos atributos vetores
    for indice in 0..quantidade {
        juros.pagamentos.push(periodo * ((indice + 1) as f64));
        juros.pesos.push(1.0);
    }
    
    // calcula e guarda os resultados dos métodos
    let peso_total: f64 = juros.get_peso_total();
    let acrescimo_calculado: f64 = juros.juros_para_acrescimo(3.0);
    let juros_calculado: f64 = juros.acrescimo_para_juros(acrescimo_calculado, 15, 65, 50.0);

    // imprime os resultados
    println!("Peso total = {}", peso_total);
    println!("Acréscimo = {}", acrescimo_calculado);
    println!("Juros = {}", juros_calculado);
}
