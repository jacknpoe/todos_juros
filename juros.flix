// Cálculo do juros, sendo que precisa de listas pra isso
// Versão 0.1: 20/03/2025: versão sem saber muito sobre Alice Flix

/// calcula a somatória de qualquer lista com Float64, mas vai ser usada com Pesos[]
def getTotal(lista: List[Float64]): Float64 =
	match lista {
		case Nil          => 0.0
		case head :: tail => head + getTotal(tail)
	}

/// calcula a soma do amortecimento de todas as parcelas para juros compostos
 def rJurosCompostos(periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64): Float64 \ IO =
    match (pagamentos, pesos) {
        case (Nil, Nil)          => 0.0
        case (Nil, Cons(_, _))   => 0.0
        case (Cons(_, _), Nil)   => 0.0
        case (hpag :: tpag, hpes :: tpes) => hpes / Float64.pow(1.0 + juros / 100.0, hpag / periodo) + rJurosCompostos(periodo, tpag, tpes, juros)
    }

/// calcula a soma do amortecimento de todas as parcelas para juros simples
 def rJurosSimples(periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64): Float64 \ IO =
    match (pagamentos, pesos) {
        case (Nil, Nil)          => 0.0
        case (Nil, Cons(_, _))   => 0.0
        case (Cons(_, _), Nil)   => 0.0
        case (hpag :: tpag, hpes :: tpes) => hpes / (1.0 + juros / 100.0 * hpag / periodo) + rJurosSimples(periodo, tpag, tpes, juros)
    }

// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo (composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64): Float64 \ IO =
    match composto {
        case true  => (getTotal(pesos) / rJurosCompostos(periodo, pagamentos, pesos, juros) - 1.0) * 100.0
        case false => (getTotal(pesos) / rJurosSimples(periodo, pagamentos, pesos, juros) - 1.0) * 100.0
    }

// função recursiva no lugar de um laço que realmente calcula os juros
def rAcrescimoParaJuros(composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], acrescimo: Float64, minDiferenca: Float64, iteracaoAtual: Int32, minJuros: Float64, maxJuros: Float64, medJuros: Float64): Float64 \ IO =
    match (iteracaoAtual == 0) or ((maxJuros - minJuros) < minDiferenca) {
        case true  => medJuros
        case false => match jurosParaAcrescimo(composto, periodo, pagamentos, pesos, medJuros) < acrescimo {
            case true  => rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
            case false => rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)
        }
    }

// calcula os juros a partir do acrescimo e dados comuns (como parcelas)
def acrescimoParaJuros(composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], acrescimo: Float64, precisao: Int32, maxIteracoes: Int32, maxJuros: Float64): Float64 \ IO =
    rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, Float64.pow(0.1, Int32.toFloat64(precisao)), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

def main(): Unit \ IO = 
    // variáveis (invariantes)
    let composto = true;
    let periodo = 30.0;
    let pagamentos = (30.0 :: 60.0 :: 90.0 :: Nil);
    let pesos = (1.0 :: 1.0 :: 1.0 :: Nil);

    // calcula e guarda os retornos das funções
    let pesoTotal = getTotal(pesos);
    let acrescimoCalculado = jurosParaAcrescimo(composto, periodo, pagamentos, pesos, 3.0);
    let jurosCalculado = acrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimoCalculado, 15, 100, 50.0);

    // imprime os resultados
    println("Peso total = ${pesoTotal}");
    println("Acréscimo = ${acrescimoCalculado}");
    println("Juros = ${jurosCalculado}")