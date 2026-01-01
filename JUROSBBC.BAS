      REM  Calculo dos juros, sendo que precisa de arrays para isso
      REM  Versao 0.1: 07/01/2025: traduzido automaticamente de GW-BASIC, depois corrigidos erros
      REM  variaveis globais e atribuicao de valores
      QUANTIDADE% = 3
      COMPOSTO% = 1
      PERIODO# = 30
      DIM PAGAMENTOS#(QUANTIDADE%)
      DIM PESOS#(QUANTIDADE%)
      FOR INDICE% = 1 TO QUANTIDADE%
        PAGAMENTOS#(INDICE%) = 30 * INDICE%
        PESOS#(INDICE%) = 1
      NEXT INDICE%
      REM  testa os retornos das funcoes
      @%=&21012
      GOSUB 500
      PRINT "Peso total = "; PESOTOTAL#
      JUROS# = 3
      GOSUB 1000
      PRINT "Acrescimo = "; ACRESCIMO#
      PRECISAO% = 15
      MAXITERACOES% = 100
      MAXJUROS# = 50
      ACRESCIMOPARAM# = ACRESCIMO#
      GOSUB 1500
      PRINT "Juros = "; JUROS#
      END
      REM  calcula a somatoria dos pesos
  500 PESOTOTAL# = 0
      FOR INDICE% = 1 TO QUANTIDADE%
        PESOTOTAL# = PESOTOTAL# + PESOS#(INDICE%)
      NEXT INDICE%
      RETURN
      REM  calcula o acrescimo a partir dos juros e parcelas
 1000 ACRESCIMO# = 0
      IF JUROS# <= 0 THEN RETURN
      IF QUANTIDADE% < 1 THEN RETURN
      IF PERIODO# <= 0 THEN RETURN
      GOSUB 500
      IF PESOTOTAL# <= 0 THEN RETURN
      ACUMULADOR# = 0
      FOR INDICE% = 1 TO QUANTIDADE%
        IF COMPOSTO% = 1 THEN
          ACUMULADOR# = ACUMULADOR# + PESOS#(INDICE%) / (1 + JUROS# / 100) ^ (PAGAMENTOS#(INDICE%) / PERIODO#)
        ELSE
          ACUMULADOR# = ACUMULADOR# + PESOS#(INDICE%) / (1 + JUROS# / 100 * PAGAMENTOS#(INDICE%) / PERIODO#)
        ENDIF
      NEXT INDICE%
      ACRESCIMO# = (PESOTOTAL# / ACUMULADOR# - 1) * 100
      RETURN
      REM  calcula os juros a partir do acrescimo e parcelas
 1500 JUROS# = 0
      IF MAXITERACOES% < 1 THEN RETURN
      IF QUANTIDADE% < 1 THEN RETURN
      IF PRECISAO% < 1 THEN RETURN
      IF PERIODO# <= 0 THEN RETURN
      IF ACRESCIMOPARAM# <= 0 THEN RETURN
      IF MAXJUROS# <= 0 THEN RETURN
      GOSUB 500
      IF PESOTOTAL# <= 0 THEN RETURN
      MINJUROS# = 0
      MINDIFERENCA# = .1 ^ PRECISAO%
      FOR INDICE% = 1 TO MAXITERACOES%
        JUROS# = (MINJUROS# + MAXJUROS#) / 2
        IF (MAXJUROS# - MINJUROS#) < MINDIFERENCA# THEN RETURN
        GOSUB 1000
        IF ACRESCIMO# < ACRESCIMOPARAM# THEN MINJUROS# = JUROS# ELSE MAXJUROS# = JUROS#
      NEXT INDICE%
      RETURN
      
