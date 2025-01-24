// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 24/01/2025: versão feita sem muito conhecimento de Pony

use "collections"

// classe com os dados para simplificar os processos
class Juros
  let composto: Bool
  let periodo: F64
  let pagamentos: Array[F64]
  let pesos: Array[F64]

  // construtor, que recebe os valores para os atributos
  new create (composto': Bool, periodo': F64, pagamentos': Array[F64], pesos': Array[F64]) =>
    composto = composto'
    periodo = periodo'
    pagamentos = pagamentos'
    pesos = pesos'

  // função que retorna a somatória do array pesos()    
  fun getPesoTotal(): F64 ? =>
    var acumulador: F64 = 0.0
    for indice in pesos.keys() do
      acumulador = acumulador + pesos(indice) ?
    end
    acumulador

  // calcula o acréscimo a partir dos juros e parcelas
  fun jurosParaAcrescimo(juros: F64): F64 ? =>
    var pesoTotal: F64 = 0.0
    try
      pesoTotal = getPesoTotal() ?
    else
      pesoTotal = 0.0
    end

    var acumulador: F64 = 0.0
  
    if (juros <= 0.0) or (pesos.size() < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) then
      return 0.0
    end

    for indice in pesos.keys() do
      if composto then
        acumulador = acumulador + (pesos(indice) ? / (1.0 + (juros / 100.0)).pow(pagamentos(indice) ? / periodo))
      else
        acumulador = acumulador + (pesos(indice) ? / (1.0 + (((juros / 100.0) * pagamentos(indice) ?) / periodo)))
      end
    end
    
    if acumulador <= 0.0 then
      return 0.0
    end
    
    ((pesoTotal / acumulador) - 1.0) * 100.0

  // calcula os juros a partir do acréscimo e parcelas
  fun acrescimoParaJuros(acrescimo: F64, precisao: F64, maxIteracoes: USize, maximoJuros: F64): F64 =>
    var pesoTotal: F64 = 0.0
    try
      pesoTotal = getPesoTotal() ?
    else
      pesoTotal = 0.0
    end

    if (maxIteracoes < 1) or (precisao < 1) or (acrescimo <= 0.0) or (pesos.size() < 1) or (periodo <= 0.0) or (maximoJuros <= 0.0) or (pesoTotal <= 0.0) then
      return 0.0
    end

    var minJuros: F64 = 0.0
    var medJuros: F64 = maximoJuros / 2.0
    var maxJuros: F64 = maximoJuros
    var decimal: F64 = 0.1
    var minDiferenca: F64 = decimal.pow(precisao)
    var resultado: F64 = 0.0
    
    for indice in Range(1, maxIteracoes) do
      medJuros = (minJuros + maxJuros) / 2.0
      if (maxJuros - minJuros) < minDiferenca then
        return medJuros
      end
      
      try
        resultado = jurosParaAcrescimo(medJuros) ?
      else
        resultado = 0.0
      end
    
      if resultado < acrescimo then
        minJuros = medJuros
      else
        maxJuros = medJuros
      end
    end
    
    medJuros

actor Main
  new create(env: Env) =>
    // cria um objeto juros do tipo Juros e inicializa os atributos
    let juros = Juros(true, 30.0, [30.0; 60.0; 90.0], [1.0; 1.0; 1.0])
    
    // calcula e guarda os resultados
    var pesoTotal: F64 = 0.0
    try
      pesoTotal = juros.getPesoTotal() ?
    else
      pesoTotal = 0.0
    end

    var acrescimoCalculado: F64 = 0.0
    try
      acrescimoCalculado = juros.jurosParaAcrescimo(3.0) ?
    else
      acrescimoCalculado = 0.0
    end

    var jurosCalculado: F64 = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

    // imprime os resultados
    env.out.print("Peso total = " + pesoTotal.string())
    env.out.print("Acréscimo = " + acrescimoCalculado.string())
    env.out.print("Juros = " + jurosCalculado.string())