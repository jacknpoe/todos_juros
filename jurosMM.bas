' Cálculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 01/01/2026: versão feita sem muito conhecimento de MMBasic

' variáveis globais para simplificar o código
quantidade% = 3
composto% = 1
periodo = 30.0
Dim pagamentos(quantidade% - 1)
Dim pesos(quantidade% - 1)

' calcula a somatória dos pesos
Function getPesoTotal()
    acumulador = 0.0
    For indice% = 0 To quantidade% - 1
        acumulador = acumulador + pesos(indice%)
    Next
    getPesoTotal = acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal()
    If juros <= 0.0 Or periodo <= 0.0 Or pesoTotal <= 0.0 Or quantidade% < 1 Then
        jurosParaAcrescimo
    Else
        acumulador = 0.0
        For indice% = 0 To quantidade% - 1
            If composto% = 1 Then
                acumulador = acumulador + pesos(indice%) / (1 + juros / 100.0) ^ (pagamentos(indice%) / periodo)
            Else
                acumulador = acumulador + pesos(indice%) / (1 + juros / 100.0 * pagamentos(indice%) / periodo)
            End If
        Next

        If acumulador <= 0 Then
            jurosParaAcrescimo = 0.0
        Else
            jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
        End If
    End If
End Function

' calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros(acrescimo, precisao%, maxIteracoes%, maxJuros)
    pesoTotal = getPesoTotal()
    If acrescimo <= 0.0 Or periodo <= 0.0 Or maxJuros <= 0.0 Or pesoTotal <= 0.0 Or quantidade% < 1 Or precisao% < 1 Or maxIteracoes% < 1 Then
        acrescimoParaJuros = 0.0
    Else
        minJuros = 0.0
        minDiferenca = 0.1 ^ precisao%
        medJuros = (minJuros + maxJuros) / 2.0

        For indice% = 1 To maxIteracoes%
            if maxJuros - minJuros < minDiferenca Then
                Exit For
            End If
            if jurosParaAcrescimo(medJuros) < acrescimo Then
                minJuros = medJuros
            Else
                maxJuros = medJuros
            End If
            medJuros = (minJuros + maxJuros) / 2.0
        Next

        acrescimoParaJuros = medJuros
    End If
End Function

' inicializa os elementos dos arrays
For indice% = 0 To quantidade% - 1
    pagamentos(indice%) = periodo * (indice% + 1)
    pesos(indice%) = 1.0
Next

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

' imprime os resultados
Print "Peso total: "; Str$(pesoTotal, 1, 15)
Print "Acrescimo: "; Str$(acrescimoCalculado, 1, 15)
Print "Juros: "; Str$(jurosCalculado, 1, 15)
