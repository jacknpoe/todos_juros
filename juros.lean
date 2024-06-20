-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 20/06/2024: versão feita sem muito conhecimento de Lean

-- estrutura básica de propriedades para simplificar as chamadas
structure Juros :=
  quantidade : Nat
  composto : Bool
  periodo : Float
  pagamentos : Array Float
  pesos : Array Float

-- função recursiva que realmente calcula a somatória de Pesos[]
def rGetPesoTotal (oJuros : Juros) (indice : Nat) : Float :=
  if indice = 0 then
    oJuros.pesos[0]!
  else
    oJuros.pesos[indice]! + rGetPesoTotal oJuros (indice - 1)

-- perfume que calcula a somatória de Pesos[]
def getPesoTotal (oJuros : Juros) : Float :=
  rGetPesoTotal oJuros (oJuros.quantidade - 1)

-- função recursiva que calcula o amortecimento das parcelas em juros compostos
def rJurosCompostos (oJuros : Juros) (indice : Nat) (juros : Float) : Float :=
  if indice = 0 then
    oJuros.pesos[0]! / (1.0 + juros / 100.0) ^ (oJuros.pagamentos[0]! / oJuros.periodo)
  else
    oJuros.pesos[indice]! / (1.0 + juros / 100.0) ^ (oJuros.pagamentos[indice]! / oJuros.periodo) + rJurosCompostos oJuros (indice - 1) juros

-- função recursiva que calcula o amortecimento das parcelas em juros simples
def rJurosSimples (oJuros : Juros) (indice : Nat) (juros : Float) : Float :=
  if indice = 0 then
    oJuros.pesos[0]! / (1.0 + juros / 100.0 * oJuros.pagamentos[0]! / oJuros.periodo)
  else
    oJuros.pesos[indice]! / (1.0 + juros / 100.0 * oJuros.pagamentos[indice]! / oJuros.periodo) + rJurosSimples oJuros (indice - 1) juros

-- calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
def jurosParaAcrescimo (oJuros : Juros) (juros : Float) : Float :=
  if oJuros.composto then
    (getPesoTotal oJuros / (rJurosCompostos oJuros (oJuros.quantidade - 1) juros) - 1.0) * 100.0
  else
    (getPesoTotal oJuros / (rJurosSimples oJuros (oJuros.quantidade - 1) juros) - 1.0) * 100.0

-- função recursiva no lugar de um for que realmente calcula os juros
def rAcrescimoParaJuros (oJuros : Juros) (acrescimo : Float) (minDiferenca : Float) (iteracaoAtual : Nat) (minJuros : Float) (maxJuros : Float) (medJuros : Float) : Float :=
  if iteracaoAtual = 0 then
    medJuros
  else
    if (maxJuros - minJuros) < minDiferenca  then
      medJuros
    else
      if jurosParaAcrescimo oJuros medJuros < acrescimo then
        rAcrescimoParaJuros oJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
      else
        rAcrescimoParaJuros oJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)

-- calcula os juros a partir do acréscimo e dados comuns (como parcelas)
def acrescimoParaJuros (oJuros : Juros) (acrescimo : Float) (precisao : Float) (maxIteracoes : Nat) (maxJuros : Float) : Float :=
  rAcrescimoParaJuros oJuros acrescimo (0.1 ^ precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)

def main : IO Unit := do
  let stdout ← IO.getStdout

  -- cria um objeto oJuros da estrutura e inicializa as propriedades
  let oJuros : Juros := { quantidade := 3, composto := true, periodo := 30.0, pagamentos := #[30.0, 60.0, 90.0], pesos := #[1.0, 1.0, 1.0] }

  -- calcula e guarda os resultados das funções
  let pesoTotal : Float := getPesoTotal oJuros
  let acrescimoCalculado : Float := jurosParaAcrescimo oJuros 3.0
  let jurosCalculado : Float := acrescimoParaJuros oJuros acrescimoCalculado 15.0 100 50.0

  -- imprime os resultados
  stdout.putStrLn s!"Peso total = {pesoTotal}!"
  stdout.putStrLn s!"Acrescimo = {acrescimoCalculado}!"
  stdout.putStrLn s!"Juros = {jurosCalculado}!"
