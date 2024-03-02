Public Class Juros
    Private PQuantidade As Integer
    Public Composto As Boolean
    Public Periodo as Integer
    Public Pagamentos() as Integer
    Public Pesos() As Double

    Public Property Quantidade() As Integer
        Get
            Return PQuantidade
        End Get
        Set(ByVal Valor As Integer)
            PQuantidade = Valor
            ReDim Preserve Pagamentos(Valor-1)
            ReDim Preserve Pesos(Valor-1)
        End Set
    End Property

    Sub New(ByVal quant As Integer, ByVal comp As Boolean, ByVal period As Integer)
        Quantidade = quant
        Composto = comp
        Periodo = period
    End Sub

    Public Function GetPesoTotal As Double
        Dim Acumulador As Double = 0.0
        For Indice As Integer = 0 to Quantidade - 1
            Acumulador = Acumulador + Pesos(Indice)
        Next Indice
        Return Acumulador
    End Function

    Public Function JurosParaAcrescimo(ByVal juros As Double) As Double
        Dim pesoTotal As Double
        Dim acumulador As Double = 0.0
        Dim soZero As Boolean = True
        If juros <= 0.0 Or Quantidade <= 0 Or Periodo <= 0 Then Return 0.0
        pesoTotal = GetPesoTotal
        If pesoTotal <= 0.0 Then Return 0.0

        For Indice As Integer = 0 to Quantidade - 1
            If Pagamentos(Indice) > 0 And Pesos(Indice) > 0.0 Then soZero = False
            If Composto Then
                acumulador = acumulador + Pesos(Indice) / (1 + juros / 100) ^ (Pagamentos(Indice) / Periodo)
            Else
                acumulador = acumulador + Pesos(Indice) / (1 + juros / 100 * Pagamentos(Indice) / Periodo)
            End If
        Next Indice

        If soZero Then Return 0.0
        Return (pesoTotal / acumulador - 1) * 100
    End Function

    Public Function AcrescimoParaJuros(ByVal acrescimo As Double, ByVal precisao As Integer, ByVal maxIteracoes As Integer, ByVal maxJuros As Double)
        Dim minJuros As Double = 0.0
        Dim medJuros As Double
        DIm minDiferenca As Double
        Dim PesoTotal As Double
        If maxIteracoes < 1 Or Quantidade < 1 Or precisao < 1 Or Periodo < 1 Or acrescimo <= 0 Or maxJuros <= 0 Then Return 0.0
        pesoTotal = GetPesoTotal
        If pesoTotal <= 0.0 Then Return 0.0
        minDiferenca = 0.1 ^ precisao

        For Indice as Integer = 0 to maxIteracoes - 1
            medJuros = (minJuros + maxJuros) / 2
            If (maxJuros - minJuros) < minDiferenca Then Return medJuros
            if JurosParaAcrescimo(medJuros) <= acrescimo Then
                minJuros = medJuros
            Else
                maxJuros = medJuros
            End If
        Next Indice

        Return medJuros
    End Function
End Class

Public Class Program
    Public Shared Sub Main()
        Dim meuJuros As Juros = New Juros(3, True, 30)
        meuJuros.Pagamentos(0) = 30
        meuJuros.Pagamentos(1) = 60
        meuJuros.Pagamentos(2) = 90
        meuJuros.Pesos(0) = 1.0
        meuJuros.Pesos(1) = 1.0
        meuJuros.Pesos(2) = 1.0

        Console.WriteLine(meuJuros.JurosParaAcrescimo(3))
        Console.WriteLine(meuJuros.AcrescimoParaJuros(meuJuros.JurosParaAcrescimo(3), 15, 100, 50))
    End Sub
End Class