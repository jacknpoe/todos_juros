#!/snap/bin/nu

# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versão: 0.1: 28/02/2026: feita sem muito conhecimento de Nushell

# variáveis escalares para simplificar as chamadas às funções
let Quantidade: int = 3;
let Composto: bool = true;
let Periodo: float = 30.0;

# cria Pagamentos
def criaPagamentos [] {
    mut pagamentos: list<float> = [];
    for indice in 1..$Quantidade {
        $pagamentos = ($pagamentos | append ($indice * $Periodo));
    }
    return $pagamentos;
}

# cria Pesos
def criaPesos [] {
    mut pesos: list<float> = [];
    for indice in 1..$Quantidade {
        $pesos = ($pesos | append 1.0);
    }
    return $pesos;
}

# variáveis listas para simplificar as chamadas às funções
let Pagamentos: list<float> = criaPagamentos;
let Pesos: list<float> = criaPesos;

# calcula a somatória de Pesos[]
def getPesoTotal [] {
    mut acumulador: float = 0.0;
    let maximo: int = $Quantidade - 1;
    for indice in 0..$maximo {
        $acumulador = $acumulador + ($Pesos | get $indice);
    }
    return $acumulador;
}

# calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo [juros: float] {
    let pesoTotal: float = getPesoTotal;
    if $Quantidade < 1 or $Periodo <= 0.0 or $pesoTotal <= 0.0 or $juros <= 0.0 { return 0.0; }
    mut acumulador: float = 0.0;
    let maximo: int = $Quantidade - 1;

    for indice in 0..$maximo {
        if $Composto  {
            $acumulador = $acumulador + ($Pesos | get $indice) / (1.0 + $juros / 100.0) ** (($Pagamentos | get $indice) / $Periodo);
        } else {
            $acumulador = $acumulador + ($Pesos | get $indice) / (1.0 + $juros / 100.0 * ($Pagamentos | get $indice) / $Periodo);
        }
    }

    if $acumulador <= 0.0 { return 0.0; }
    return (($pesoTotal / $acumulador - 1.0) * 100.0);
}

# calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros [acrescimo: float, precisao: int, maxIteracoes: int, maximoJuros: float] {
    let pesoTotal: float = getPesoTotal;
    if $Quantidade < 1 or $Periodo <= 0.0 or $pesoTotal <= 0.0 or $acrescimo <= 0.0 or $precisao < 1 or $maxIteracoes < 1 or $maximoJuros <= 0.0 { return 0.0; }
    mut minJuros: float = 0.0;
    mut medJuros: float = $maximoJuros / 2.0;
    mut maxJuros: float = $maximoJuros;
    let minDiferenca: float = 0.1 ** $precisao;

    for indice in 1..$maxIteracoes {
        if $maxJuros - $minJuros < $minDiferenca { return $medJuros; }
        if (jurosParaAcrescimo $medJuros) < $acrescimo {
            $minJuros = $medJuros;
        } else {
            $maxJuros = $medJuros;
        }
        $medJuros = ($minJuros + $maxJuros) / 2.0;
    }

    return $medJuros;
}

# calcula e guarda os resultados
let pesoTotal: float = getPesoTotal;
let acrescimoCalculado: float = jurosParaAcrescimo 3.0;
let jurosCalculado: float = acrescimoParaJuros $acrescimoCalculado 15 65 50.0;

# imprime os resultados
print $"Peso total = ($pesoTotal)";
print $"Acréscimo = ($acrescimoCalculado)";
print $"Juros = ($jurosCalculado)";
