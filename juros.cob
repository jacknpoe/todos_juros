       *> Cálculo dos juros, sendo que precisa de parcelas pra isso
       *> Versão 0.1: 08/02/2025: versão feita sem muito conhecimento
       *>                         de GnuCOBOL

       *> programa principal
       IDENTIFICATION DIVISION.
       PROGRAM-ID. JUROS.
       AUTHOR. Ricardo Erick Rebêlo.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION GET-PESO-TOTAL
           FUNCTION JUROS-PARA-ACRESCIMO
           FUNCTION ACRESCIMO-PARA-JUROS.

       DATA DIVISION.
       LOCAL-STORAGE SECTION.
       *> variáveis para simplificarem as chamadas
       01 RJUROS.
           05 QUANTIDADE PICTURE 9(9) VALUE 3.
           05 COMPOSTO PICTURE 9(1) VALUE 1. *> 1 é TRUE, outro é FALSE
           05 PERIODO COMP-2 VALUE 30.0.
           05 PAGAMENTOS COMP-2 OCCURS 3 TIMES.
           05 PESOS COMP-2 OCCURS 3 TIMES.
       *> variáveis do corpo do programa
       01 INDICE PICTURE 9(9).
       01 PESO-TOTAL COMP-2.
       01 JUROS COMP-2 VALUE 3.0.
       01 ACRESCIMO-CALCULADO COMP-2.
       01 PRECISAO PICTURE 9(9) VALUE 15.
       01 MAX-ITERACOES PICTURE 9(9) VALUE 100.
       01 MAX-JUROS COMP-2 VALUE 50.0.
       01 JUROS-CALCULADO COMP-2.

       PROCEDURE DIVISION.
           *> incializa os arrays PAGAMENTOS E PESOS
           PERFORM VARYING INDICE FROM 1 BY 1
               UNTIL INDICE = QUANTIDADE + 1
               COMPUTE PAGAMENTOS (INDICE) = INDICE * 30.0
               COMPUTE PESOS (INDICE) = 1.0
           END-PERFORM

           *> calcula e guarda os valores das funções
           MOVE GET-PESO-TOTAL(RJUROS) TO PESO-TOTAL.
           MOVE JUROS-PARA-ACRESCIMO(RJUROS, JUROS)
               TO ACRESCIMO-CALCULADO.
           MOVE ACRESCIMO-PARA-JUROS(RJUROS, ACRESCIMO-CALCULADO,
               PRECISAO, MAX-ITERACOES, MAX-JUROS) TO JUROS-CALCULADO.

           *> imprime os resultados
           DISPLAY "Peso total = " PESO-TOTAL.
           DISPLAY "Acrescimo = " ACRESCIMO-CALCULADO.
           DISPLAY "Juros = " JUROS-CALCULADO.
           GOBACK.
       END PROGRAM JUROS.

       *> calcula a somatória de PESOS
       IDENTIFICATION DIVISION.
       FUNCTION-ID. GET-PESO-TOTAL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 INDICE PICTURE 9(9).
       LINKAGE SECTION.
       01 RJUROS.
           05 QUANTIDADE PICTURE 9(9) VALUE 3.
           05 COMPOSTO PICTURE 9(1) VALUE 1.
           05 PERIODO COMP-2 VALUE 30.0.
           05 PAGAMENTOS COMP-2 OCCURS 3 TIMES.
           05 PESOS COMP-2 OCCURS 3 TIMES.
       01 ACUMULADOR COMP-2.

       PROCEDURE DIVISION USING RJUROS RETURNING ACUMULADOR.
           MOVE 0.0 TO ACUMULADOR.
           PERFORM VARYING INDICE FROM 1 BY 1
               UNTIL INDICE = QUANTIDADE + 1
               COMPUTE ACUMULADOR = ACUMULADOR + PESOS (INDICE)
           END-PERFORM.
           GOBACK.
       END FUNCTION GET-PESO-TOTAL.

       *> calcula o acréscimo a partir dos juros e parcelas
       IDENTIFICATION DIVISION.
       FUNCTION-ID. JUROS-PARA-ACRESCIMO.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION GET-PESO-TOTAL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 INDICE PICTURE 9(9).
       01 ACUMULADOR COMP-2.
       01 PESO-TOTAL COMP-2.
       LINKAGE SECTION.
       01 RJUROS.
           05 QUANTIDADE PICTURE 9(9) VALUE 3.
           05 COMPOSTO PICTURE 9(1) VALUE 1.
           05 PERIODO COMP-2 VALUE 30.0.
           05 PAGAMENTOS COMP-2 OCCURS 3 TIMES.
           05 PESOS COMP-2 OCCURS 3 TIMES.
       01 JUROS COMP-2.
       01 RESULTADO COMP-2.

       PROCEDURE DIVISION USING RJUROS, JUROS RETURNING RESULTADO.
           MOVE GET-PESO-TOTAL(RJUROS) TO PESO-TOTAL.
           MOVE 0.0 TO ACUMULADOR.
           IF (JUROS <= 0.0) OR (QUANTIDADE < 1)
               OR (PERIODO <= 0.0) OR (PESO-TOTAL <= 0.0) THEN
               MOVE 0.0 TO RESULTADO
           ELSE
               PERFORM VARYING INDICE FROM 1 BY 1
                   UNTIL INDICE = QUANTIDADE + 1
                   IF COMPOSTO = 1 THEN
                       COMPUTE ACUMULADOR = ACUMULADOR + PESOS (INDICE)
                       / (1.0 + JUROS / 100.0)
                       ** (PAGAMENTOS (INDICE) / PERIODO)
                   ELSE
                       COMPUTE ACUMULADOR = ACUMULADOR + PESOS (INDICE)
                       / (1.0 + JUROS / 100.0
                       * PAGAMENTOS (INDICE) / PERIODO)
                   END-IF
               END-PERFORM
               COMPUTE RESULTADO = 
                   (PESO-TOTAL / ACUMULADOR - 1.0) * 100.0
           END-IF
           GOBACK.
       END FUNCTION JUROS-PARA-ACRESCIMO.

       *> calcula os juros a partir do acréscimo e parcelas
       IDENTIFICATION DIVISION.
       FUNCTION-ID. ACRESCIMO-PARA-JUROS.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION GET-PESO-TOTAL
           FUNCTION JUROS-PARA-ACRESCIMO.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 PESO-TOTAL COMP-2.
       01 MIN-JUROS COMP-2 VALUE 0.0.
       01 MED-JUROS COMP-2.
       01 MIN-DIFERENCA COMP-2.
       01 ACRESCIMO-CALCULADO COMP-2.
       LINKAGE SECTION.
       01 RJUROS.
           05 QUANTIDADE PICTURE 9(9) VALUE 3.
           05 COMPOSTO PICTURE 9(1) VALUE 1.
           05 PERIODO COMP-2 VALUE 30.0.
           05 PAGAMENTOS COMP-2 OCCURS 3 TIMES.
           05 PESOS COMP-2 OCCURS 3 TIMES.
       01 ACRESCIMO COMP-2.
       01 PRECISAO PICTURE 9(9) VALUE 15.
       01 MAX-ITERACOES PICTURE 9(9) VALUE 100.
       01 MAX-JUROS COMP-2 VALUE 50.0.
       01 RESULTADO COMP-2.

       PROCEDURE DIVISION USING RJUROS, ACRESCIMO, PRECISAO,
           MAX-ITERACOES, MAX-JUROS RETURNING RESULTADO.
           MOVE GET-PESO-TOTAL(RJUROS) TO PESO-TOTAL.
           IF (ACRESCIMO <= 0.0) OR (QUANTIDADE < 1)
               OR (PERIODO <= 0.0) OR (PESO-TOTAL <= 0.0)
               OR (PRECISAO < 1) OR (MAX-ITERACOES < 1 )
               OR (MAX-JUROS <= 0.0) THEN
               MOVE 0.0 TO RESULTADO
           ELSE
               COMPUTE MIN-DIFERENCA = 0.1 ** PRECISAO
               PERFORM MAX-ITERACOES TIMES
                   COMPUTE MED-JUROS = (MIN-JUROS + MAX-JUROS) / 2.0
                   IF (MAX-JUROS - MIN-JUROS) < MIN-DIFERENCA THEN
                       EXIT PERFORM
                   END-IF
                   MOVE JUROS-PARA-ACRESCIMO(RJUROS, MED-JUROS)
                       TO ACRESCIMO-CALCULADO
                   IF ACRESCIMO-CALCULADO < ACRESCIMO THEN
                       MOVE MED-JUROS TO MIN-JUROS
                   ELSE
                       MOVE MED-JUROS TO MAX-JUROS
                   END-IF
               END-PERFORM
               MOVE MED-JUROS TO RESULTADO
           END-IF
           GOBACK.
       END FUNCTION ACRESCIMO-PARA-JUROS.
