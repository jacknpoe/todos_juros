; Cálculo do juros, sendo que precisa de arrays pra isso
; Versão 0.1: 27/05/2024: versão feita sem muito conhecimento de AutoIt (globais)
;        0.2: 28/05/2024: funções e testes

; variáveis globais para simplificar o código
Global $Quantidade = 3
Global $Composto = True
Global $Periodo = 30.0
Global $Pagamentos = [30.0, 60.0, 90.0]
Global $Pesos = [1.0, 1.0, 1.0]

; calcula a somatória de Pesos[]
Func getPesoTotal()
    Local $acumulador = 0.0
    For $indice = 0 To $Quantidade - 1
        $acumulador += $Pesos[$indice]
    Next
    Return $acumulador
EndFunc

; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
Func jurosParaAcrescimo($juros)
    Local $pesoTotal = getPesoTotal()
    If $juros <= 0.0 Or $Quantidade < 1 Or $Periodo <= 0.0 Or $pesoTotal <= 0.0 Then
        Return 0.0
    EndIf
    Local $acumulador = 0.0

    For $indice = 0 To $Quantidade - 1
        If $Composto Then
            $acumulador += $Pesos[$indice] / (1.0 + $juros / 100.0) ^ ($Pagamentos[$indice] / $Periodo)
        Else
            $acumulador += $Pesos[$indice] / (1.0 + $juros / 100.0 * $Pagamentos[$indice] / $Periodo)
        EndIF
    Next

    Return ($pesoTotal / $acumulador - 1.0) * 100.0
EndFunc

; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
Func acrescimoParaJuros($acrescimo, $precisao, $maxIteracoes, $maxJuros)
    Local $pesoTotal = getPesoTotal()
    If $maxIteracoes < 1 Or $Quantidade < 1 Or $precisao < 1 Or $Periodo <= 0.0 Or $acrescimo <= 0.0 Or $maxJuros <= 0.0 Or $pesoTotal <= 0.0 Then
        Return 0.0
    EndIf
    Local $minJuros = 0.0
    Local $medJuros = $maxJuros / 2.0
    Local $minDiferenca = 0.1 ^ $precisao

    for $indice = 1 to $maxIteracoes
        $medJuros = ($minJuros + $maxJuros) / 2.0
        If ($maxJuros - $minJuros) < $minDiferenca Then
            Return $medJuros
        EndIF
        If jurosParaAcrescimo($medJuros) < $acrescimo Then
            $minJuros = $medJuros
        Else
            $maxJuros = $medJuros
        EndIf
    Next

    return $medJuros
EndFunc

; testa os valores das funções
ConsoleWrite("Peso total = " & getPesoTotal() & @CRLF)
ConsoleWrite("Acrescimo = " & jurosParaAcrescimo(3.0) & @CRLF)
ConsoleWrite("Juros = " & acrescimoParaJuros(jurosParaAcrescimo(3.0), 15, 100, 50.0) & @CRLF)