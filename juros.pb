; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 29/01/2025: versão feita sem muito conhecimento de PureBasic
;        0.2: 05/04/2026: melhoras em geral, incluindo declaração de arrays

; variáveis globais para simplificar as chamadas às funções e inicialização de escalares
Global Quantidade.i = 3, Composto.b = #True, Periodo.d = 30.0
Global Dim Pagamentos.d(Quantidade-1)
Global Dim Pesos.d(Quantidade-1)

; inicializa os arrays globais Pagamentos() e Pesos()
For indice = 0 To Quantidade - 1
  Pagamentos(indice) = (indice + 1.0) * Periodo
  Pesos(indice) = 1.0
Next

; calcula a sonmatória dos elementos do array Pesos()
Procedure.d getPesoTOtal()
  Define acumulador.d = 0.0
    
  For indice = 0 To Quantidade - 1
    acumulador = acumulador + Pesos(indice)
  Next

  ProcedureReturn acumulador
EndProcedure

; calcula o acréscimo a partir dos juros e parcelas
Procedure.d jurosParaAcrescimo(juros.d)
  Define pesoTotal.d = getPesoTotal()
  If juros <= 0.0 Or Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0
    ProcedureReturn 0.0
  EndIf
  
  Define acumulador.d = 0.0

  For indice = 0 To Quantidade - 1
    If Composto
      acumulador = acumulador + Pesos(indice) / Pow(1.0 + juros / 100.0, Pagamentos(indice) / Periodo)
    Else
      acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
    EndIf
  Next
  
  If acumulador <= 0.0
    ProcedureReturn 0.0  
  EndIf
  ProcedureReturn (pesoTotal / acumulador - 1.0) * 100.0
EndProcedure

; calcula os juros a partir do acréscimo e parcelas`
Procedure.d acrescimoParaJuros(acrescimo.d, precisao.i, maxIteracoes.i, maxJuros.d)
  Define pesoTotal.d = getPesoTotal()
  If acrescimo <= 0.0 Or Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0
    ProcedureReturn 0.0
  EndIf
  
  Define minJuros.d = 0.0, medJuros.d = maxJuros / 2.0, minDiferenca.d = Pow(0.1, precisao)
  
  For indice = 1 To maxIteracoes
    medJuros = (minJuros + maxJuros) / 2.0
    If (maxJuros - minJuros) < minDiferenca
      ProcedureReturn medJuros
    EndIf
    If jurosParaAcrescimo(medJuros) < acrescimo
      minJuros = medJuros
    Else
      maxJuros = medJuros
    EndIf
  Next
  
  ProcedureReturn medJuros
EndProcedure

; calcula e guarda os resultados das funções
Define pesoTotal.d, acrescimoCalculado.d, jurosCalculado.d
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

; imprime os resultados
Debug "Peso total = " + pesoTotal
Debug "Acréscimo = " + acrescimoCalculado
Debug "Juros = " + jurosCalculado