VERSION 5.00
Begin VB.Form Formulario 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Juros"
   ClientHeight    =   1830
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   3135
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1830
   ScaleWidth      =   3135
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Botao 
      Caption         =   "Clique aqui!"
      Height          =   495
      Left            =   1440
      TabIndex        =   0
      Top             =   1080
      Width           =   1455
   End
End
Attribute VB_Name = "Formulario"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 13/02/2025: versão feita sem muito conhecimento de Visual Basic 6.0

' variáveis <globais> para simplificar as chamadas
Private Quantidade As Integer
Private Composto As Boolean
Private Periodo As Double
Private Pagamentos() As Double
Private Pesos() As Double

' calcula a somatória de Pesos()
Private Function getPesoTotal() As Double
    Dim acumulador As Double
    For indice = 0 To Quantidade - 1
        acumulador = acumulador + Pesos(indice)
    Next
    getPesoTotal = acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Private Function jurosParaAcrescimo(juros As Double) As Double
    Dim pesoTotal As Double
    Dim acumulador As Double
    pesoTotal = getPesoTotal()
    
    
    
    
    If pesoTotal <= 0# Or Quantidade < 1 Or Periodo <= 0# Or juros <= 0# Then
        jurosParaAcrescimo = 0#
        Return
    End If
    
    For indice = 0 To Quantidade - 1
        If Composto Then
            acumulador = acumulador + Pesos(indice) / (1# + juros / 100#) ^ (Pagamentos(indice) / Periodo)
        Else
            acumulador = acumulador + Pesos(indice) / (1# + juros / 100# * Pagamentos(indice) / Periodo)
        End If
    Next
    
    jurosParaAcrescimo = (pesoTotal / acumulador - 1#) * 100#
End Function

' calcula os juros a partir do acréscimo e parcelas
Private Function acrescimoParaJuros(acrescimo As Double, precisao As Integer, maxIteracoes As Integer, maxJuros As Double) As Double
    Dim pesoTotal As Double
    Dim minJuros As Double
    Dim medJuros As Double
    Dim minDiferenca As Double
    pesoTotal = getPesoTotal()
    If pesoTotal <= 0# Or Quantidade < 1 Or Periodo <= 0# Or acrescimo <= 0# Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0# Then
        acrescimoParaJuros = 0#
        Return
    End If
    
    minJuros = 0#
    minDiferenca = 0.1 ^ precisao
    
    For indice = 1 To maxIteracoes
        medJuros = (minJuros + maxJuros) / 2#
        If (maxJuros - minJuros) < minDiferenca Then
            Exit For
        End If
        If jurosParaAcrescimo(medJuros) < acrescimo Then
            minJuros = medJuros
        Else
            maxJuros = medJuros
        End If
    Next
    
    acrescimoParaJuros = medJuros
End Function


Private Sub Botao_Click()
    ' inicializa as variáveis <globais>
    Quantidade = 3
    Composto = True
    Periodo = 30#
    ReDim Pagamentos(0 To Quantidade - 1)
    ReDim Pesos(0 To Quantidade - 1)
    For indice = 0 To Quantidade - 1
        Pagamentos(indice) = 30# * (indice + 1#)
        Pesos(indice) = 1#
    Next

    ' calcula e guarda os resultados das funções
    Dim pesoTotal As Double
    Dim acrescimoCalculado As Double
    Dim jurosCalculado As Double
    pesoTotal = getPesoTotal()
    acrescimoCalculado = jurosParaAcrescimo(3#)
    jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50#)

    ' imprime os resultados
    MsgBox ("Peso total = " & pesoTotal & ", acréscimo = " & acrescimoCalculado & ", juros = " & jurosCalculado)
End Sub
