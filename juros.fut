-- Cálculo dos juros, sendo que precisa de parcelas pra isso
-- Versão 0.1: 18/07/2025: versão feita sem muito conhecimento de Futhark
--                         compile com   futhark c juros.fut   e rode com   echo 3.0 | ./juros   (troque 3.0 pelos juros, mensais no caso)

-- variáveis globais e funções que mapeiam o equivalente aos arrays em outras linguagens, para simplificar as chamadas
let Quantidade : i32 = 300000
let Composto : bool = true
let Periodo : f64 = 30.0
def Pesos (_ : i32) : f64 = 1.0  -- colocar o parâmetro para, por exemplo, a primeira parceka maior que as demais (o índice começa por zero)
def Pagamentos (indice : i32) : f64 = Periodo * ((r64 indice) + 1)  -- o + 1 é porque o índice começa por zero, então será uma progração aritmética: 30, 60, 90 ...

-- calcula a somatória de pesos[] para a quantidade de parcelas
def getPesoTotal : f64 = loop acumulador = 0.0 for indice < Quantidade do acumulador + Pesos indice

-- calcula o amortecimento total dos juros compostos
def jurosCompostos (juros : f64) : f64 = loop acumulador = 0.0 for indice < Quantidade do acumulador + (Pesos indice) / (1.0 + juros / 100.0) ** ((Pagamentos indice) / Periodo)

-- calcula o amortecimento total dos juros simples
def jurosSimples (juros : f64) : f64 = loop acumulador = 0.0 for indice < Quantidade do acumulador + (Pesos indice) / (1.0 + juros / 100.0 * (Pagamentos indice) / Periodo)

-- calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo (juros : f64) : f64 = if Composto then (getPesoTotal / (jurosCompostos juros) - 1.0) * 100.0 else (getPesoTotal / (jurosSimples juros) - 1.0) * 100.0

-- calcula os juros a partir do acréscimo e parcelas (precisa de minDiferenca pré-calculada)
def pAcrescimoParaJuros (acrescimo : f64, minDiferenca : f64, maxIteracoes : i32, mJuros : f64) : (i32, f64, f64, f64) =
    loop (indice, minJuros, medJuros, maxJuros) = (0, 0.0, mJuros / 2.0, mJuros) while (indice < maxIteracoes) && (maxJuros - minJuros > minDiferenca) do
        if (jurosParaAcrescimo medJuros) < acrescimo then (indice + 1, medJuros, (medJuros + maxJuros) / 2.0, maxJuros)
            else (indice + 1, minJuros, (minJuros + medJuros) / 2.0, medJuros)

def acrescimoParaJuros (acrescimo : f64, precisao : i32, maxIteracoes : i32, mJuros : f64) : (f64) =
    let (_, _, medJuros, _) = pAcrescimoParaJuros (acrescimo, 0.1 ** r64 precisao, maxIteracoes, mJuros) in medJuros

def main (juros : f64) : (f64, f64, f64) =
    let pesoTotal = getPesoTotal
    let acrescimoCalculado = jurosParaAcrescimo juros
    let jurosCalculado = acrescimoParaJuros (acrescimoCalculado, 15, 100, 50.0)
    in (pesoTotal, acrescimoCalculado, jurosCalculado)