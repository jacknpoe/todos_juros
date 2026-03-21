// Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
// Versão: 0.1: 21/03/2026: feita sem muito conhecimento de ooc
// Não está sendo feita com orientação a objetos porque deixaria pagamento e peso fixos na classe.
// Não foi possível criar um atributo coleção, pois o tamanho continuava zero ou dava falha de segmentação,
// ou não era possível declarar atributo ou parâmetro como função do tipo func(Int) -> Double.
// São falhas da linguagem ou compilador, que não aceitam declarar e atribuir separadamente variáveis funções
// nem alocam ou dimensionam corretamente arrays C, arrays ooc, listas ou arraylistas.

import math

// variáveis globais, altere aqui quando quiser mudar quantidade, composto (ou simples) e periodo
quantidade: Int = 3
composto: Bool = true
periodo: Double = 30.0

// função que mapeia pagamentos (começa por 0)
pagamento: func (indice: Int) -> Double {
    return (indice + 1) * periodo
}

// função que mapeia pesos (começa por 0)
peso: func (indice: Int) -> Double {
    return 1.0
}

// calcula a somatória dos "elementos" em "pesos"
getPesoTotal: func -> Double {
   acumulador: Double = 0.0
   for (indice in 0 .. quantidade) {
      acumulador += peso(indice)
   }
   return acumulador
}

// calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo: func (juros: Double) -> Double {
   pesoTotal: Double = getPesoTotal()   
   if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) return 0.0
   acumulador: Double = 0.0

   for (indice in 0 .. quantidade)
      if (composto) {
         acumulador += peso(indice) / (1.0 + juros / 100.0) pow (pagamento(indice) / periodo)
      } else {
         acumulador += peso(indice) / (1.0 + juros / 100.0 * pagamento(indice) / periodo)
      }
   
   if (acumulador <= 0.0) return 0.0
   return (pesoTotal / acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros: func (acrescimo: Double, precisao: Int, maxIteracoes: Int, maxJuros: Double) -> Double {
   pesoTotal: Double = getPesoTotal()   
   if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) return 0.0
   minJuros: Double = 0.0
   medJuros: Double = maxJuros / 2.0
   minDiferenca: Double = 0.1 pow (precisao as Double)

   for (iteracao in 0 .. maxIteracoes) {
      if (maxJuros - minJuros < minDiferenca) return medJuros
      if (jurosParaAcrescimo(medJuros) < acrescimo) {
         minJuros = medJuros
      } else {
         maxJuros = medJuros
      }
      medJuros = (minJuros + maxJuros) / 2.0
   }

   return medJuros
}

// calcula e guarda os resultados dos métodos
pesoTotal: Double = getPesoTotal()
acrescimoCalculado: Double = jurosParaAcrescimo(3.0)
jurosCalculado: Double = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

// imprime os resultados
printf("Peso total = %.15f\n", pesoTotal)
printf("Acréscimo = %.15f\n", acrescimoCalculado)
printf("Juros = %.15f\n", jurosCalculado)
