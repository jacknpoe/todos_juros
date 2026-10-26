// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 18/03/2025: feito sem muito conhecinento de Gleam
//        0.2: 25/10/2026: listas escaladas e car/cdr no lugar de first e rest, validações de argumentos, acumuladores e variáveis
//                         funções recursivas alteradas para permitir Tail Call Optimization (TCO)
// COMPATIBILIDADE: Gleam 1.9.1, acrescentar: gleam add gleam_erlang@0.34.0

import gleam/io
import gleam/float
import gleam/result
import gleam/int
import gleam/list
import gleam/erlang
// import gleam/bool
// import gleam/string

// variáveis globais para simplificar as chamadas às funções
const quantidade: Int = 3 // agora que escalamos as listas, quantidade pode ter significado real
const composto: Bool = True
const periodo: Float = 30.0

// função recursiva que cria a lista pagamentos
fn rcriapagamentos(indice: Int, acumulador: List(Float)) -> List(Float) {
  case indice > quantidade {
    True -> acumulador
    _ -> rcriapagamentos(indice + 1, list.prepend(to: acumulador, this: int.to_float(indice) *. periodo))
  }
}

// função açúcar que cria a lista pagamentos
fn criapagamentos() -> List(Float) {
  rcriapagamentos(1, [])
}

// função recursiva que cria a lista pesos
fn rcriapesos(indice: Int, acumulador: List(Float)) -> List(Float) {
  case indice > quantidade {
    True -> acumulador
    _ -> rcriapesos(indice + 1, list.prepend(to: acumulador, this: 1.0))
  }
}

// função açúcar que cria a lista pesos
fn criapesos() -> List(Float) {
  rcriapesos(1, [])
}

// calcula recursivamente a somatória de Pesos[]
fn rgetpesototal(pesos: List(Float), acumulador: Float) -> Float {
  case pesos {
    [] -> acumulador
    [primeiro, ..resto] -> rgetpesototal(resto, primeiro +. acumulador)
  }
}

// perfume que calcula a somatória de Pesos[]
fn getpesototal(pesos: List(Float)) -> Float {
  rgetpesototal(pesos, 0.0)
}

// calcula recursivamente a soma do amortecimento de todas as parcelas para juros compostos
fn rjuroscompostos(pagamentos: List(Float), pesos: List(Float), juros: Float, acumulador: Float) -> Float {
  case pagamentos, pesos {
    [], [] -> acumulador
    [ppag, ..rpag], [ppes, ..rpes] -> case erlang.rescue(fn() { float.power(1.0 +. juros /. 100.0, ppag /. periodo) }) {
      Error(_) -> rjuroscompostos(rpag, rpes, juros, acumulador)
      Ok(Ok(fator)) -> rjuroscompostos(rpag, rpes, juros, ppes /. fator +. acumulador)
      Ok(Error(_)) -> rjuroscompostos(rpag, rpes, juros, acumulador)
    }
    _, _ -> acumulador
  }
}

// calcula recursivamente a soma do amortecimento de todas as parcelas para juros simples
fn rjurossimples(pagamentos: List(Float), pesos: List(Float), juros: Float, acumulador: Float) -> Float {
  case pagamentos, pesos {
    [], [] -> acumulador
    [ppag, ..rpag], [ppes, ..rpes] -> rjurossimples(rpag, rpes, juros, ppes /. {1.0 +. juros /. 100.0 *. ppag /. periodo} +. acumulador)
    _, _ -> acumulador
  }
}

// calcula o acréscimo a partir dos juros e parcelas
fn jurosparaacrescimo(pagamentos: List(Float), pesos: List(Float),juros : Float) -> Float {
  let pesototal = getpesototal(pesos)

  case quantidade < 1 || periodo <=. 0.0 || pesototal <=. 0.0 || juros <=. 0.0 {
    True -> 0.0
    _ -> { 
      let acumulador = case composto {
          True -> rjuroscompostos(pagamentos, pesos, juros, 0.0)
        _ -> rjurossimples(pagamentos, pesos, juros, 0.0)
      }
      case acumulador <=. 0.0 {
        True -> 0.0
        _ -> {pesototal /. acumulador -. 1.0} *. 100.0
      }
    }
  }
}

// calcula recursivamente os juros a partir do acréscimo e parcelas
fn racrescimoparajuros(pagamentos: List(Float), pesos: List(Float), acrescimo: Float, mindiferenca: Float, iteracaoatual: Int, minjuros: Float, maxjuros: Float, medjuros: Float) -> Float {
  case iteracaoatual == 0 || {maxjuros -. minjuros} <=. mindiferenca {
    True -> medjuros
    _ -> case jurosparaacrescimo(pagamentos, pesos, medjuros) <. acrescimo {
      True -> racrescimoparajuros(pagamentos, pesos, acrescimo, mindiferenca, iteracaoatual - 1, medjuros, maxjuros, {medjuros +. maxjuros} /. 2.0)
      _ -> racrescimoparajuros(pagamentos, pesos, acrescimo, mindiferenca, iteracaoatual - 1, minjuros, medjuros, {minjuros +. medjuros} /. 2.0)
    }
  }
}

// perfume que calcula os juros a partir do acréscimo e parcelas
fn acrescimoparajuros(pagamentos: List(Float), pesos: List(Float), acrescimo: Float, precisao: Int, maxiteracoes: Int, maxjuros : Float) -> Float {
  let pesototal = getpesototal(pesos)

  case quantidade < 1 || periodo <=. 0.0 || pesototal <=. 0.0 || acrescimo <=. 0.0 || precisao < 1 || maxiteracoes < 1 || maxjuros <=. 0.0 {
    True -> 0.0
    _ -> racrescimoparajuros(pagamentos, pesos, acrescimo, result.unwrap(float.power(0.1, int.to_float(precisao)), 0.0), maxiteracoes, 0.0, maxjuros, maxjuros /. 2.0)
  }
}

pub fn main() {
  // listas que não podem ser constantes nem variáveis
  let pagamentos: List(Float) = criapagamentos()
  let pesos: List(Float) = criapesos()

  // calcula e guarda os resultados das funções
  let pesototal = getpesototal(pesos)
  let acrescimocalculado = jurosparaacrescimo(pagamentos, pesos, 3.0)
  let juroscalculado = acrescimoparajuros(pagamentos, pesos, acrescimocalculado, 15, 100, 50.0)

  // imprime os resultados
  io.println("Peso total = " <> float.to_string(pesototal))
  io.println("Acréscimo = " <> float.to_string(acrescimocalculado))
  io.println("Juros = " <> float.to_string(juroscalculado))
}
