/// classe jurosXB
CLASS jurosXB
   EXPORTED:
   VAR Quantidade, Composto, Periodo, Pagamentos, Pesos
   METHOD init, getPesoTotal, jurosParaAcrescimo, acrescimoParaJuros
ENDCLASS

/// o construtor inicializa todos os atributos
METHOD jurosXB:init(nQuantidade, bComposto, nPeriodo, aPagamentos, aPesos)
   ::Quantidade := nQuantidade
   ::Composto := bComposto
   ::Periodo := nPeriodo
   ::Pagamentos := aPagamentos
   ::Pesos := aPesos
RETURN self

/// calcula a somatória de Pesos[]
METHOD jurosXB:getPesoTotal()
   LOCAL acumulador := 0.0, indice
   FOR indice := 1 TO ::Quantidade
      acumulador := acumulador + ::Pesos[indice]
   NEXT
RETURN acumulador

/// calcula o acréscimo a partir dos juros e parcelas
METHOD jurosXB:jurosParaAcrescimo(nJuros)
   LOCAL pesoTotal, acumulador, indice
   pesoTotal := ::getPesoTotal()
   IF ::Quantidade < 1 .OR. ::Periodo <= 0.0 .OR. pesoTotal <= 0.0 .OR. nJuros <= 0.0
      RETURN 0.0
   ENDIF

   acumulador := 0.0
   FOR indice := 1 TO ::Quantidade
      IF ::Composto
         acumulador = acumulador + ::Pesos[indice] / (1.0 + nJuros / 100.0) ** (::Pagamentos[indice] / ::Periodo)
      ELSE
         acumulador = acumulador + ::Pesos[indice] / (1.0 + nJuros / 100.0 * ::Pagamentos[indice] / ::Periodo)
      ENDIF
   NEXT

   IF acumulador <= 0.0
      RETURN 0.0
   ENDIF
RETURN (pesoTotal / acumulador - 1.0) * 100.0

/// calcula os juros a partir do acréscimo e parcelas
METHOD jurosXB:acrescimoParaJuros(nAcrescimo, nPrecisao, nMaxIteracoes, nMaxJuros)
   LOCAL pesoTotal, minJuros, medJuros, minDiferenca, indice
   pesoTotal := ::getPesoTotal()
   IF ::Quantidade < 1 .OR. ::Periodo <= 0.0 .OR. pesoTotal <= 0.0 .OR. nAcrescimo <= 0.0 .OR. nPrecisao < 1 .OR. nMaxIteracoes < 1 .OR. nMaxJuros <= 0.0
      RETURN 0.0
   ENDIF

   minJuros := 0.0
   medJuros := nMaxJuros / 2.0
   minDiferenca := 0.1 ** nPrecisao
   FOR indice := 1 TO nMaxIteracoes
      IF nMaxJuros - minJuros < minDiferenca
         RETURN medJuros
      ENDIF
      IF ::jurosParaAcrescimo(medJuros) < nAcrescimo
         minJuros := medJuros
      ELSE
         nMaxJuros := medJuros
      ENDIF
      medJuros := (nMaxJuros + minJuros) / 2.0
   NEXT
RETURN medJuros

