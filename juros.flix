// Cálculo do juros, sendo que precisa de listas pra isso
// Versão 0.1: 20/03/2025: versão sem saber muito sobre Flix
//        0.2: 17/10/2026: Flix 0.78.0, listas escaláveis, recursiva alteradas para permitir Tail Call Optimization (TCO)

// função recursiva que gera a lista pagamentos
def rGeraPagamentos(quantidade: Int32, periodo: Float64, indice: Int32, acumulador: List[Float64]): List[Float64] =
    match indice > quantidade {
        case true   => acumulador
        case false  => rGeraPagamentos(quantidade, periodo, indice + 1, (Int32.toFloat64(indice) * periodo) :: acumulador)
    }

/// função açúcar que gera a lista pagamentos
def geraPagamentos(quantidade: Int32, periodo: Float64): List[Float64] =
    rGeraPagamentos(quantidade, periodo, 1, Nil)

// função recursiva que gera a lista pagamentos
def rGeraPesos(quantidade: Int32, indice: Int32, acumulador: List[Float64]): List[Float64] =
    match indice > quantidade {
        case true   => acumulador
        case false  => rGeraPesos(quantidade, indice + 1, 1.0 :: acumulador)
    }

/// função açúcar que gera a lista pagamentos
def geraPesos(quantidade: Int32): List[Float64] =
    rGeraPesos(quantidade, 1, Nil)

/// calcula a somatória de qualquer lista com Float64, mas vai ser usada com Pesos[]
def rGetTotal(lista: List[Float64], acumulador: Float64): Float64 =
	match lista {
		case Nil          => acumulador
		case head :: tail => rGetTotal(tail, acumulador + head)
	}

/// calcula a somatória de qualquer lista com Float64, mas vai ser usada com Pesos[]
def getTotal(lista: List[Float64]): Float64 =
	rGetTotal(lista, 0.0)

/// função recursiva que calcula a soma da amortização de todas as parcelas para juros compostos
 def rJurosCompostos(periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64, acumulador: Float64): Float64 \ IO =
    match (pagamentos, pesos) {
        case (Nil, Nil)         => acumulador
        case (Nil, Cons(_, _))  => acumulador
        case (Cons(_, _), Nil)  => acumulador
        case (hpag :: tpag, hpes :: tpes) => rJurosCompostos(periodo, tpag, tpes, juros, acumulador + hpes / Float64.pow(base = 1.0 + juros / 100.0, hpag / periodo))
    }

/// função recursiva que calcula a soma da amortização de todas as parcelas para juros simples
 def rJurosSimples(periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64, acumulador: Float64): Float64 \ IO =
    match (pagamentos, pesos) {
        case (Nil, Nil)         => acumulador
        case (Nil, Cons(_, _))  => acumulador
        case (Cons(_, _), Nil)  => acumulador
        case (hpag :: tpag, hpes :: tpes) => rJurosSimples(periodo, tpag, tpes, juros, acumulador + hpes / (1.0 + juros / 100.0 * hpag / periodo))
    }

// função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo (composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], juros: Float64): Float64 \ IO =
    match composto {
        case true  => (getTotal(pesos) / rJurosCompostos(periodo, pagamentos, pesos, juros, 0.0) - 1.0) * 100.0
        case false => (getTotal(pesos) / rJurosSimples(periodo, pagamentos, pesos, juros, 0.0) - 1.0) * 100.0
    }

// função recursiva que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
def rAcrescimoParaJuros(composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], acrescimo: Float64, minDiferenca: Float64, iteracaoAtual: Int32, minJuros: Float64, maxJuros: Float64, medJuros: Float64): Float64 \ IO =
    match (iteracaoAtual == 0) or ((maxJuros - minJuros) < minDiferenca) {
        case true  => medJuros
        case false => match jurosParaAcrescimo(composto, periodo, pagamentos, pesos, medJuros) < acrescimo {
            case true  => rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros + maxJuros) / 2.0)
            case false => rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros + medJuros) / 2.0)
        }
    }

// função açúcar que calcula os juros a partir do acrescimo e dados comuns (como parcelas)
def acrescimoParaJuros(composto: Bool, periodo: Float64, pagamentos: List[Float64], pesos: List[Float64], acrescimo: Float64, precisao: Int32, maxIteracoes: Int32, maxJuros: Float64): Float64 \ IO =
    rAcrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimo, Float64.pow(base = 0.1, Int32.toFloat64(precisao)), maxIteracoes, 0.0, maxJuros, maxJuros / 2.0)

def main(): Unit \ IO = 
    // variáveis (invariantes)
    let quantidade = 3;
    let composto: Bool = true;
    let periodo: Float64 = 30.0;
    let pagamentos = geraPagamentos(quantidade, periodo);
    let pesos = geraPesos(quantidade);

    // calcula e guarda os retornos das funções
    let pesoTotal = getTotal(pesos);
    let acrescimoCalculado = jurosParaAcrescimo(composto, periodo, pagamentos, pesos, 3.0);
    let jurosCalculado = acrescimoParaJuros(composto, periodo, pagamentos, pesos, acrescimoCalculado, 15, 100, 50.0);

    // imprime os resultados
    println("Peso total = ${pesoTotal}");
    println("Acréscimo = ${acrescimoCalculado}");
    println("Juros = ${jurosCalculado}")