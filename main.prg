/// <summary>
/// Cálculo dos juros, sendo que precisa de parcelas pra isso
/// Versão 0.1: 02/04/2025: versão feita sem muito conhecimento de Xbase++
/// </summary>
///
/// <copyright>
/// Jacknpoe
/// </copyright>

// #include "Common.ch"

PROCEDURE Main
   // variáveis públicas para simplificar as chamadas às funções
   LOCAL Quantidade := 3, Composto := .T., Periodo := 30.0, Pagamentos := {}, Pesos := {}
   LOCAL juros, indice, pesoTotal, acrescimoCalculado, jurosCalculado

   // os arrays são criados dinamicamente
   FOR indice := 1 TO Quantidade
      AAdd( Pagamentos, indice * Periodo)
      AAdd( Pesos, 1.0)
   NEXT

   // cria um objeto juros da classe jurosXB e inicializa os atributos
   juros := jurosXB():New(Quantidade, Composto, Periodo, Pagamentos, Pesos)

   // calcula e guarda os retornos dos métodos
   pesoTotal := juros:getPesoTotal()
   acrescimoCalculado := juros:jurosParaAcrescimo(3.0)
   jurosCalculado := juros:acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

   // imprime os resultados
   ? "Peso total = " + Transform( pesoTotal, "9.999999999999999")
   ? "Acresicmo = " + Transform( acrescimoCalculado, "9.999999999999999")
   ? "Juros = " + Transform( jurosCalculado, "9.999999999999999")
   WAIT
RETURN
