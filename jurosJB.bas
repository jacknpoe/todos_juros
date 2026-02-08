' Cáculo dos juros, sendo que precisa de parcelas pra isso
' Versão 0.1: 07/02/2026: versão feita sem muito conhecimento de Just BASIC
'        0.2: 08/02/2026: agora usa Using() no lugar da função imprime()

' variáveis globais para simplificar as chamadas às funções e inicialização das escalares (arrays são globais)
Global true, false, Quantidade, Composto, Periodo
true = 1
false = 0
Quantidade = 3
Composto = true
Periodo = 30.0
Dim Pagamentos(Quantidade - 1)
Dim Pesos(Quantidade - 1)

' inicializa os elementos dos arrays globais
For indice = 0 To Quantidade - 1
    Pagamentos(indice) = (indice + 1.0) * Periodo
    Pesos(indice) = 1.0
Next

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal()
acrescimoCalculado = jurosParaAcrescimo(3.0)
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

' imprime os resultados
Print "Peso total = "; Using("#.###############", pesoTotal)
Print "Acréscimo = "; Using("#.###############", acrescimoCalculado)
Print "Juros = "; Using("#.###############", jurosCalculado)

' calcula a somatória dos elementos do array Pesos()
Function getPesoTotal()
    acumulador = 0.0
    For indice = 0 To Quantidade - 1
        acumulador = acumulador + Pesos(indice)
    Next
    getPesoTotal = acumulador
End Function

' calcula o acréscimo a partir dos juros e parcelas
Function jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal()
    If Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or juros <= 0.0 Then
        jurosParaAcrescimo = 0.0
    Else
        acumulador = 0.0

        For indice = 0 To Quantidade - 1
            If Composto Then
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo)
            Else
                acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo)
            End If
        Next

        If acumulador <= 0.0 Then
            jurosParaAcrescimo = 0.0
        Else
            jurosParaAcrescimo = (pesoTotal / acumulador - 1.0) * 100.0
        End If
    End If
End Function

' calcula os juros a partir do acréscimo e parcelas
Function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = getPesoTotal()
    If Quantidade < 1 Or Periodo <= 0.0 Or pesoTotal <= 0.0 Or acrescimo <= 0.0 Or precisao < 1 Or maxIteracoes < 1 Or maxJuros <= 0.0 Then
        acrescimoParaJuros = 0.0
    Else
        minJuros = 0.0
        medJuros = maxJuros / 2.0
        minDiferenca = 0.1 ^ precisao

        For iteracao = 1 To maxIteracoes
            If maxJuros - minJuros < minDiferenca Then
                Exit For
            End If
            If jurosParaAcrescimo(medJuros) < acrescimo Then
                minJuros = medJuros
            Else
                maxJuros = medJuros
            End If
            medJuros = (minJuros + maxJuros) / 2.0
        Next

        acrescimoParaJuros = medJuros
    End If
End Function

