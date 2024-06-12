' Calculo do juros, sendo que precisa de arrays pra isso
' Versao 1.0: 12/06/2024: versao feita sem muito conhecimento de VB64
' define os valores gerais
Let quantidade% = 3
Let composto% = 1
Let periodo# = 30.0
Dim pagamentos#(quantidade%)
Dim pesos#(quantidade%)

For indice% = 1 To quantidade%
    Let pagamentos#(indice%) = 30.0 * indice%
    Let pesos#(indice%) = 1.0
Next indice%


' calcula, guarda os resultados das funcoes e imprime
GoSub getPesoTotal
Print "Peso total = "; Using "#.###############"; pesoTotal#

Let juros# = 3.0
GoSub jurosParaAcrescimo
Print "Acrescimo = "; Using "#.###############"; acrescimoCalculado#

Let acrescimo# = acrescimoCalculado#
Let precisao# = 15
Let maxIteracoes% = 100
Let maxJuros# = 50.0
GoSub acrescimoParaJuros
Print "Juros = "; Using "#.###############"; jurosCalculado#
End

' calcula a somatoria de pesos()
getPesoTotal:
Let acumulador# = 0.0
For indice% = 1 To quantidade%
    Let acumulador# = acumulador# + pesos#(indice%)
Next indice%
Let pesoTotal# = acumulador#
Return

' calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo:
Let acrescimoCalculado# = 0.0
If juros# <= 0.0 Or quantidade% < 1 Or periodo# <= 0.0 Or pesoTotal# <= 0.0 Then Return
Let acumulador# = 0.0
For indice% = 1 To quantidade%
    If composto% = 1 Then
        acumulador# = acumulador# + pesos#(indice%) / (1.0 + juros# / 100.0) ^ (pagamentos#(indice%) / periodo#)
    Else
        acumulador# = acumulador# + pesos#(indice%) / (1.0 + juros# / 100.0 * pagamentos#(indice%) / periodo#)
    End If
Next indice%
Let acrescimoCalculado# = (pesoTotal# / acumulador# - 1.0) * 100.0
Return

' calcula os juros a partir do acrescimo e dados comuns (como parcelas)
acrescimoParaJuros:
Let jurosCalculado# = 0.0
If acrescimo# <= 0.0 Or quantidade% < 1 Or periodo# <= 0.0 Or pesoTotal# <= 0.0 Or precisao# < 1 Or maxIteracoes% < 1 Or maxJuros# <= 0.0 Then Return
Let minJuros# = 0.0
Let jurosCalculado# = maxJuros# / 2.0
Let minDiferenca# = 0.1 ^ precisao#
For indice% = 1 To maxIteracoes%
    Let jurosCalculado# = (minJuros# + maxJuros#) / 2.0
    If (maxJuros# - minJuros#) < minDiferenca# Then Return
    Let juros# = jurosCalculado#
    GoSub jurosParaAcrescimo
    If acrescimoCalculado# < acrescimo# Then
        Let minJuros# = jurosCalculado#
    Else
        Let maxJuros# = jurosCalculado#
    End If
Next indice%
Return
