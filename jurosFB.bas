' Cálculo do juros, sendo que precisa de arrays pra isso
' Versão 0.1: 22/02/2025: versão feita sem muito conhecimento de FreeBASIC

' declaração de funções
Declare Function getPesoTotal() As Double
Declare Function jurosParaAcrescimo(juros As Double) As Double
Declare Function acrescimoParaJuros(acrescimo As Double, precisao As Integer, maxIteracoes As Integer, maxJuros As Double) As Double

Print "JUROS"

' define os valores globais para simplificar as chamadas
Dim Shared quantidade As Integer
Dim Shared composto As Integer
Dim Shared periodo As Double
Dim Shared pagamentos(quantidade) As Double
Dim Shared pesos(quantidade) As Double

' incialização das variáveis globais
quantidade = 3
composto = 1
periodo = 30.0

Dim indice as Integer
For indice = 1 To quantidade
    pagamentos(indice) = 30.0 * indice
    pesos(indice) = 1.0
Next indice

' calcula, guarda os resultados das funções e imprime
Dim pesoTotal As Double
pesoTotal = getPesoTotal()
Print "Peso total = "; pesoTotal

Dim acrescimoCalculado As Double
acrescimoCalculado = jurosParaAcrescimo(3.0)
Print "Acrescimo = "; acrescimoCalculado

Dim jurosCalculado As Double
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)
Print "Juros = "; jurosCalculado

End

' calcula a somatória de pesos()
Function getPesoTotal() As Double
    Dim indice As Integer
    Dim acumulador As Double
    acumulador = 0.0
    For indice = 1 To quantidade
        acumulador = acumulador + pesos(indice)
    Next indice
    Return acumulador
End Function

' calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
Function jurosParaAcrescimo(juros As Double) As Double
    Dim acumulador As Double
    Dim indice As Integer
    Dim pesoTotal As Double
    pesoTotal = getPesoTotal()
    If juros <= 0.0 Or quantidade < 1 Or periodo <= 0.0 Or pesoTotal <= 0.0 Then Return 0.0
    acumulador = 0.0
    For indice = 1 To quantidade
        If composto = 1 Then
            acumulador = acumulador + pesos(indice) / (1.0 + juros / 100.0) ^ (pagamentos(indice) / periodo)
        Else
            acumulador = acumulador + pesos(indice) / (1.0 + juros / 100.0 * pagamentos(indice) / periodo)
        End If
    Next indice
    Return (pesoTotal / acumulador - 1.0) * 100.0
End Function

' calcula os juros a partir do acréscimo e dados comuns (como parcelas)
Function acrescimoParaJuros(acrescimo As Double, precisao As Integer, maxIteracoes As Integer, maxJuros As Double) As Double
    Dim minJuros As Double
    Dim minDiferenca As Double
    Dim indice As Integer
    Dim medJuros As Double
    Dim pesoTotal As Double
    pesoTotal = getPesoTotal()
    If acrescimo <= 0.0 Or quantidade < 1 Or periodo <= 0.0 Or pesoTotal <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0 Then Return 0.0
    minJuros = 0.0
    minDiferenca = 0.1 ^ precisao
    For indice = 1 To maxIteracoes
        medJuros = (minJuros + maxJuros) / 2.0
        If (maxJuros - minJuros) < minDiferenca Then Return medJuros
        If jurosParaAcrescimo(medJuros) < acrescimo Then
            minJuros = medJuros
        Else
            maxJuros = medJuros
        End If
    Next indice
    Return medJuros
End Function
