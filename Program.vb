' Cálculo do juros, sendo que precisa de arrays pra isso
' Versão 0.1: 02/03/2024: versão feita sem muito conhecimento de Visual Basic .NET
'        0.2: 04/04/2024: mudada a lógica de soZero para acumulador <= 0.0
'        0.3: 09/08/2026: feito projeto, comentários, tornada escalável

' Classe juros com atributos para simplificar as chamadas aos métodos
Public Class Juros
    Private PQuantidade As Integer
    Public Composto As Boolean
    Public Periodo as Double
    Public Pagamentos() as Double
    Public Pesos() As Double

    ' a propriedade Quantidade deve alterar os tamanhos dos arrays
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

    ' construtor que inicializa atributos escalares
    Sub New(ByVal quant As Integer, ByVal comp As Boolean, ByVal period As Double)
        Quantidade = quant
        Composto = comp
        Periodo = period
    End Sub

    ' calcula a somatória dos elementos no array Pesos
    Public Function GetPesoTotal As Double
        Dim Acumulador As Double = 0.0
        For Indice As Integer = 0 to Quantidade - 1
            Acumulador = Acumulador + Pesos(Indice)
        Next Indice
        Return Acumulador
    End Function

    ' calcula o acréscimo a partir dos juros e parcelas
    Public Function JurosParaAcrescimo(ByVal juros As Double) As Double
        Dim pesoTotal As Double
        Dim acumulador As Double = 0.0
        If juros <= 0.0 Or Quantidade <= 0 Or Periodo <= 0.0 Then Return 0.0
        pesoTotal = GetPesoTotal
        If pesoTotal <= 0.0 Then Return 0.0

        For Indice As Integer = 0 to Quantidade - 1
            If Composto Then
                acumulador = acumulador + Pesos(Indice) / (1 + juros / 100) ^ (Pagamentos(Indice) / Periodo)
            Else
                acumulador = acumulador + Pesos(Indice) / (1 + juros / 100 * Pagamentos(Indice) / Periodo)
            End If
        Next Indice

        If acumulador <= 0.0 Then Return 0.0
        Return (pesoTotal / acumulador - 1) * 100
    End Function

    ' calcula os juros a partir do acréscimo e parcelas
    Public Function AcrescimoParaJuros(ByVal acrescimo As Double, ByVal precisao As Integer, ByVal maxIteracoes As Integer, ByVal maxJuros As Double) As Double
        Dim minJuros As Double = 0.0
        Dim medJuros As Double
        Dim minDiferenca As Double
        Dim PesoTotal As Double
        If maxIteracoes < 1 Or Quantidade < 1 Or precisao < 1 Or Periodo <= 0.0 Or acrescimo <= 0 Or maxJuros <= 0 Then Return 0.0
        PesoTotal = GetPesoTotal()
        If PesoTotal <= 0.0 Then Return 0.0
        minDiferenca = 0.1 ^ precisao

        For Indice As Integer = 0 To maxIteracoes - 1
            medJuros = (minJuros + maxJuros) / 2
            If (maxJuros - minJuros) < minDiferenca Then Return medJuros
            If JurosParaAcrescimo(medJuros) <= acrescimo Then
                minJuros = medJuros
            Else
                maxJuros = medJuros
            End If
        Next Indice

        Return medJuros
    End Function
End Class

' programa de testes
Public Class Program
    ' método de testes
    Public Shared Sub Main()
        ' variáveis para configurar os atributos escalares
        Dim Quantidade As Integer = 3
        Dim Composto As Boolean = true
        Dim Periodo As Double = 30.0

        ' variáveis que guardam os retornos dos métodos
        Dim pesoTotal As Double
        Dim acrescimoCalculado As Double
        Dim jurosCalculado as Double

        ' objeto meuJuros do tipo Juros, inicializa escalares
        Dim meuJuros As Juros = New Juros(Quantidade, Composto, Periodo)

        ' inicializa os elementos dos arrays Pagamentos e Pesos
        For Indice As Integer = 0 To Quantidade - 1
            meuJuros.Pagamentos(Indice) = (Indice + 1) * Periodo
            meuJuros.Pesos(Indice) = 1.0
        Next Indice

        ' calcula e guarda os resultados
        pesoTotal = meuJuros.GetPesoTotal()
        acrescimoCalculado = meuJuros.JurosParaAcrescimo(3.0)
        jurosCalculado = meuJuros.AcrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

        ' imprime os resultados
        Console.WriteLine("Peso total = " & pesoTotal)
        Console.WriteLine("Acréscimo = " & acrescimoCalculado)
        Console.WriteLine("Juros = " & jurosCalculado)
    End Sub
End Class
