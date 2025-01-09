# Calculo dos juros, sendo que precisa de parcelas pra isso
# Versao 0.1: 08/01/2025: versao feita sem muito conhecimento de Windows PowerShell

# variaveis globais
[int]$Quantidade = 3
[bool]$Composto = $true
[double]$Periodo = 30.0
$Pagamentos = 30.0, 60.0, 90.0
$Pesos = 1.0, 1.0, 1.0

# calcula a somatoria do array Pesos[]
function getPesoTotal {
    [double]$acumulador = 0.0
    for($indice = 0; $indice -lt $Quantidade; $indice++) {
        $acumulador += $Pesos[$indice]
    }
    return $acumulador
}

# calcula o acrescimo a partir dos juros e parcelas
function jurosParaAcrescimo ( [double]$juros ) {

    [double]$pesoTotal = getPesoTotal
    if (($juros -le 0.0) -or ($Quantidade -lt 1) -or ($Periodo -le 0.0) -or ($pesoTotal -le 0.0)) {
        return 0.0
    }

    [double]$acumulador = 0.0

    for($indice = 0; $indice -lt $Quantidade; $indice++) {
        if ($Composto) {
            $acumulador += $Pesos[$indice] / [Math]::Pow(1.0 + $juros / 100.0, $Pagamentos[$indice] / $Periodo)
        } else {
            $acumulador += $Pesos[$indice] / (1.0 + $juros / 100.0 * $Pagamentos[$indice] / $Periodo)
        }
    }

    if ($acumulador -le 0.0 ) {
        return 0.0
    }

    return (($pesoTotal / $acumulador - 1.0) * 100.0)
}

# calcula os juros a partir do acrescimo e parcelas
function acrescimoParaJuros ( [double]$acrescimo, [int]$precisao, [int]$maxIteracoes, [double]$maximoJuros ) {
    [double]$pesoTotal = getPesoTotal
    if (($maxIteracoes -lt 1) -or ($Quantidade -lt 1) -or ($precisao -lt 1) -or ($Periodo -le 0.0) -or ($acrescimo -le 0.0) -or ($maximoJuros -le 0.0) -or ($pesoTotal -le 0.0)) {
        return 0.0
    }

    [double]$minJuros = 0.0
    [double]$medJuros = $maximoJuros / 2.0
    [double]$maxJuros = $maximoJuros
    [double]$minDiferenca = [Math]::Pow(0.1, $precisao)

    for($indice = 0; $indice -lt $maxIteracoes; $indice++) {
        $medJuros = ($minJuros + $maxJuros) / 2.0
        if (($maxJuros - $minJuros) -lt $minDiferenca) {
            return $medJuros
        }
        if ((jurosParaAcrescimo $medJuros) -lt $acrescimo) {
            $minJuros = $medJuros
        } else {
            $maxJuros = $medJuros
        }
    }

    return $medJuros
}

# calcula e guarda os retornos das funcoes

[double]$cPesoTotal = getPesoTotal
[double]$cAcrescimo = jurosParaAcrescimo 3.0
[double]$cJuros = acrescimoParaJuros $cAcrescimo 15 100 50.0

# cria as strings de saida

[string]$sPesoTotal = "Peso total = " + $cPesoTotal
[string]$sAcrescimo = "Acrescimo = " + $cAcrescimo
[string]$sJuros = "Juros = " + $cJuros

# imprime os resultados

Write-Output $sPesoTotal
Write-Output $sAcrescimo
Write-Output $sJuros
