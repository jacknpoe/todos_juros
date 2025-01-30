; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1:  29/01/2025: versão feita sem muito conhecimento de PureBasic

; estrutura básica de propriedades para simplificar as chamadas
Global Quantidade.i = 3
Global Composto.b = #True
Global Periodo.d = 30.0
Global Dim Pagamentos.d(1000)
Global Dim Pesos.d(1000)

; calcula a somatória do Array Pesos()
Procedure.d getPesoTotal()
  acumulador.d = 0.0
  For indice = 1 To Quantidade
    acumulador = acumulador + Pesos(indice)
  Next
  ProcedureReturn acumulador
EndProcedure

; calcula o acréscimo a partir dos juros e parcelas
Procedure.d jurosParaAcrescimo(juros.d)
  pesoTotal.d = getPesoTotal()
  If juros <= 0.0 Or Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0
    ProcedureReturn 0.0
  EndIf
  
  acumulador.d = 0.0

  For indice = 1 To Quantidade
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
  pesoTotal.d = getPesoTotal()
  If acrescimo <= 0.0 Or Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0
    ProcedureReturn 0.0
  EndIf
  
  minJuros.d = 0.0
  medJuros.d = maxJuros / 2.0
  minDiferenca.d = Pow(0.1, precisao)
  
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

; define os valores para os arrays
For indice = 1 To Quantidade
  Pagamentos(indice) = indice * 30.0
  Pesos(indice) = 1.0
Next

; calcula e guarda os resultados das funções
pesoTotal.d = getPesoTotal()
acrescimoCalculado.d = jurosParaAcrescimo(3.0)
jurosCalculado.d = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

; imprime os resultados
Debug "Peso total = " + pesoTotal
Debug "Acréscimo = " + acrescimoCalculado
Debug "Juros = " + jurosCalculado

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 62
; FirstLine = 37
; Folding = -
; EnableXP
; DPIAware