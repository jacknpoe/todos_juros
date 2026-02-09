// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 18/03/2025: feito sem muito conhecinento de Gleam

import gleam/io
import gleam/float
import gleam/result
import gleam/list
import gleam/int
// import gleam/bool
// import gleam/string

// variáveis globais para simplificar as chamadas às funções
// const quantidade : Int = 3  // não precisa de quantidade
const composto : Bool = True
const periodo : Float = 30.0
const pagamentos : List(Float) = [30.0, 60.0, 90.0]
const pesos : List(Float) = [1.0, 1.0, 1.0]

// calcula recursivamente a somatória de Pesos[]
fn rgetpesototal(lista : List(Float)) -> Float {
  let primeiro = result.unwrap(list.first(lista), 0.0)
  let resto = result.unwrap(list.rest(lista), [])

  case resto {
    [] -> primeiro
    _ -> primeiro +. rgetpesototal(resto)
  }
}

// perfume que calcula a somatória de Pesos[]
fn getpesototal() -> Float {
  rgetpesototal(pesos)
}

// calcula recursivamente a soma do amortecimento de todas as parcelas para juros compostos
fn rjuroscompostos(pag : List(Float), pes : List(Float), juros : Float) -> Float {
  let ppag = result.unwrap(list.first(pag), 0.0)
  let rpag = result.unwrap(list.rest(pag), [])
  let ppes = result.unwrap(list.first(pes), 0.0)
  let rpes = result.unwrap(list.rest(pes), [])

  case rpag {
    [] -> ppes /. {result.unwrap(float.power(1.0 +. juros /. 100.0, ppag /. periodo), 0.0)}
    _ -> ppes /. {result.unwrap(float.power(1.0 +. juros /. 100.0, ppag /. periodo), 0.0)} +. rjuroscompostos(rpag, rpes, juros)
  }
}

// calcula recursivamente a soma do amortecimento de todas as parcelas para juros simples
fn rjurossimples(pag : List(Float), pes : List(Float), juros : Float) -> Float {
  let ppag = result.unwrap(list.first(pag), 0.0)
  let rpag = result.unwrap(list.rest(pag), [])
  let ppes = result.unwrap(list.first(pes), 0.0)
  let rpes = result.unwrap(list.rest(pes), [])

  case rpag {
    [] -> ppes /. {1.0 +. juros /. 100.0 *. ppag /. periodo}
    _ -> ppes /. {1.0 +. juros /. 100.0 *. ppag /. periodo} +. rjurossimples(rpag, rpes, juros)
  }
}

// calcula o acréscimo a partir dos juros e parcelas
fn jurosparaacrescimo(juros : Float) -> Float {
  let pesototal = getpesototal()

  case composto  {
    True -> {pesototal /. rjuroscompostos(pagamentos, pesos, juros) -. 1.0} *. 100.0
    _ -> {pesototal /. rjurossimples(pagamentos, pesos, juros) -. 1.0} *. 100.0
  }
}

// calcula recursivamente os juros a partir do acréscimo e parcelas
fn racrescimoparajuros(acrescimo : Float, mindiferenca : Float, iteracaoatual : Int, minjuros : Float, maxjuros : Float, medjuros : Float) -> Float {
  case iteracaoatual == 0 || {maxjuros -. minjuros} <. mindiferenca {
    True -> medjuros
    _ -> case jurosparaacrescimo(medjuros) <. acrescimo {
      True -> racrescimoparajuros(acrescimo, mindiferenca, iteracaoatual - 1, medjuros, maxjuros, {medjuros +. maxjuros} /. 2.0)
      _ -> racrescimoparajuros(acrescimo, mindiferenca, iteracaoatual - 1, minjuros, medjuros, {minjuros +. medjuros} /. 2.0)
    }
  }
}

// perfume que calcula os juros a partir do acréscimo e parcelas
fn acrescimoparajuros(acrescimo : Float, precisao : Int, maxiteracoes : Int, maxjuros : Float) -> Float {
  racrescimoparajuros(acrescimo, result.unwrap(float.power(0.1, int.to_float(precisao)), 0.0), maxiteracoes, 0.0, maxjuros, maxjuros /. 2.0)
}

pub fn main() {
  // calcula e guarda os resultados das funções
  let pesototal = getpesototal()
  let acrescimocalculado = jurosparaacrescimo(3.0)
  let juroscalculado = acrescimoparajuros(acrescimocalculado, 15, 100, 50.0)

  // imprime os resultados
  io.println("Peso total = " <> float.to_string(pesototal))
  io.println("Acréscimo = " <> float.to_string(acrescimocalculado))
  io.println("Juros = " <> float.to_string(juroscalculado))
}