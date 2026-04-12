' Cálculo dos juros, sendo que precisa de arrays para isso
' Versão 0.1: 12/04/2026: feito sem muito conhecimento de Kaya-BASIC

Option Explicit

' pow fora do domínio do problema, para simplificar as expressões
Function pow(base As Double, expoente As Double) As Double
    Return exp(log(base) * expoente)
End Function

' classe cJuros, com atributos globais para simplificar as chamadas às funções
Class cJuros
    Public Sub inicializa(pQuantidade As Integer, pComposto As Boolean, pPeriodo As Double)
    Public Function getPesoTotal As Double
    Public Function jurosParaAcrescimo(juros As Double) As Double
    Public Function acrescimoParaJuros(acrescimo As Double, precisao As Integer, maxIteracoes As Integer, maxJuros As Double) As Double

    Public Property Quantidade As Integer

    Public Composto As Boolean
    Public Periodo As Double
    Public Pagamentos() As Double
    Public Pesos() As Double

    Private m_Quantidade As Integer
End Class

' inicializa os atributos escalares
Sub cJuros.inicializa
    Quantidade = pQuantidade
    Composto = pComposto
    Periodo = pPeriodo  
End Sub

' calcula a somatória dos elementos do atributo array Pesos()
Function cJuros.getPesoTotal
    Dim acumulador As Double = 0.0

    For indice As Integer = 0 To m_Quantidade - 1
        acumulador += Pesos(indice)
    Next

    Return acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Function cJuros.jurosParaAcrescimo
    Dim pesoTotal As Double = getPesoTotal
    If m_Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0 Then
        Return 0.0
    End If
    Dim acumulador As Double = 0.0

    For indice As Integer = 0 To m_Quantidade - 1
        If Composto Then
            acumulador += Pesos(indice) / pow(1.0 + juros / 100.0, Pagamentos(indice) / Periodo)
        Else
            acumulador += Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
        End If
    Next

    If acumulador <= 0.0 Then
        Return 0.0
    End If
    Return (pesoTotal / acumulador - 1.0) * 100.0
End Function

' calcula os juros a partir do acréscimo e parcelas
Function cJuros.acrescimoParaJuros
    Dim pesoTotal As Double = getPesoTotal
    If m_Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0 Then
        Return 0.0
    End If
    Dim minJuros As Double = 0.0
    Dim medJuros as Double = maxJuros / 2.0
    Dim minDiferenca As Double = pow(0.1, precisao)

    For iteracao As Integer = 1 To maxIteracoes
        If maxJuros - minJuros < minDiferenca Then
            Return medJuros
        End If
        If jurosParaAcrescimo(medJuros) < acrescimo Then
            minJuros = medJuros
        Else
            maxJuros = medJuros
        End If
        medJuros = (minJuros + maxJuros) / 2.0
    Next

    Return medJuros
End Function

' get de Quantidade
Property Get cJuros.Quantidade
	Value = m_Quantidade
End Property

' set de Quantidade
Property Set cJuros.Quantidade
	m_Quantidade = Value
    ReDim Pagamentos(m_Quantidade - 1)
    ReDim Pesos(m_Quantidade - 1)
End Property

' programa principal
Sub Main
    ' objeto juros da classe cJuros, inicialização dos atributos escalares
    Dim juros As cJuros = New cJuros
    juros.inicializa(3, TRUE, 30.0)

    ' inicialização dos astibutos arrays Pagamentos() e Pesos()
    For indice As Integer = 0 To juros.Quantidade - 1
        juros.Pagamentos(indice) = (indice + 1) * juros.Periodo
        juros.Pesos(indice) = 1.0
    Next

    ' calcula e guarda os resultados dos métodos
    Dim pesoTotal As Double = juros.getPesoTotal
    Dim acrescimoCalculado As Double = juros.jurosParaAcrescimo(3.0)
    Dim jurosCalculado As Double = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

    ' imprime os resultados
    Print "Peso total = " + Str(pesoTotal)
    Print "Acréscimo = " + Str(acrescimoCalculado)
    Print "Juros = " + Str(jurosCalculado)
End Sub
