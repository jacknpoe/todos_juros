-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 20/06/2024: versão feita sem muito conhecimento de Lean
--        0.2: 10/11/2026: comentários melhorados; variáveis para inicializar a estrutura; agora é iterativo; impressão de float com 15 decimais
--                         avaliados variáveis, parâmetros e cálculos; criada forma de imprimir mais decimais

-- estrutura básica de propriedades para simplificar as chamadas
structure Juros where
  quantidade : Nat
  composto : Bool
  periodo : Float
  pagamentos : Array Float
  pesos : Array Float

-- função que formata um número com até 15 casas decimais (adaptado do ChatGPT)
def formataReal (valor : Float) : String := Id.run do
  let digitos : Nat := 15 - (Float.log valor / Float.log 10.0).toInt64.toNatClampNeg
  let escala : Int64 := 10 ^ digitos
  let arredondado : Int64 := (valor.abs * escala.toFloat + 0.5).toInt64
  let inteiro : Int64 := arredondado / escala
  let decimal : Int64 := arredondado % escala
  let sinal : String := if valor < 0.0 then "-" else ""
  let fracao : String := toString decimal
  let zeros : String := String.ofList (List.replicate (digitos - fracao.length) '0')
  return sinal ++ toString inteiro ++ "." ++ zeros ++ fracao

-- função que calcula a somatória de Pesos[]
def getPesoTotal (oJuros : Juros) : Float := Id.run do
  let mut acumulador := 0.0
  for indice in [:oJuros.quantidade] do
    acumulador := acumulador + oJuros.pesos[indice]!
  return acumulador

-- função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo (oJuros : Juros) (juros : Float) : Float := Id.run do
  let pesoTotal : Float := getPesoTotal oJuros

  if oJuros.quantidade < 1 || oJuros.periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 then
    return 0.0

  let mut acumulador : Float := 0.0

  for indice in [:oJuros.quantidade] do
    if oJuros.composto then
      acumulador := acumulador + oJuros.pesos[indice]! / (1.0 + juros / 100.0) ^ (oJuros.pagamentos[indice]! / oJuros.periodo)
    else
      acumulador := acumulador + oJuros.pesos[indice]! / (1.0 + juros / 100.0 * oJuros.pagamentos[indice]! / oJuros.periodo)

  if acumulador <= 0.0 then
    return 0.0

  return (pesoTotal / acumulador - 1.0) * 100.0

-- função que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def acrescimoParaJuros (oJuros : Juros) (acrescimo : Float) (precisao : Nat) (maxIteracoes : Nat) (maximoJuros : Float) : Float := Id.run do
  let pesoTotal : Float := getPesoTotal oJuros

  if oJuros.quantidade < 1 || oJuros.periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maximoJuros <= 0.0 then
    return 0.0

  let mut minJuros : Float := 0.0
  let mut medJuros : Float := maximoJuros / 2.0
  let mut maxJuros : Float := maximoJuros
  let mut minDiferenca : Float := (0.1 ^ precisao.toFloat)

  for _ in [:maxIteracoes] do
    if (maxJuros - minJuros) <= minDiferenca then
      break
    if (  jurosParaAcrescimo oJuros medJuros) < acrescimo then
      minJuros := medJuros
    else
      maxJuros := medJuros
    medJuros := (minJuros + maxJuros) / 2.0

  return medJuros

-- função principal
def main : IO Unit := do
  let stdout ← IO.getStdout

  -- variáveis para a criação da estrutura (alterer os parâmetros aqui)
  let Quantidade : Nat := 3
  let Composto : Bool := true
  let Periodo : Float := 30.0
  let mut Pagamentos : Array Float := Array.replicate Quantidade 0.0
  let mut Pesos : Array Float := Array.replicate Quantidade 0.0

  -- inicializa os elementos dos arrays Pagamentos[] e Pesos[]
  for indice in [:Quantidade] do
    Pagamentos := Pagamentos.set! indice ((indice.toFloat + 1.0) * Periodo)
    Pesos := Pesos.set! indice 1.0

  -- cria um objeto oJuros da estrutura e inicializa as propriedades
  let oJuros : Juros := { quantidade := Quantidade, composto := Composto, periodo := Periodo, pagamentos := Pagamentos, pesos := Pesos }

  -- calcula e guarda os resultados das funções
  let pesoTotal : Float := getPesoTotal oJuros
  let acrescimoCalculado : Float := jurosParaAcrescimo oJuros 3.0
  let jurosCalculado : Float := acrescimoParaJuros oJuros acrescimoCalculado 15 100 50.0

  -- imprime os resultados
  stdout.putStrLn ("Peso total = " ++ formataReal pesoTotal)
  stdout.putStrLn ("Acrescimo = " ++ formataReal acrescimoCalculado)
  stdout.putStrLn ("Juros = " ++ formataReal jurosCalculado)
