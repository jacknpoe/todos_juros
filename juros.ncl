# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 31/03/2026: versao feita sem muito conhecimento de Nickel
# PARA RODAR "LIMPO": printf "%b\n" "$(nickel export juros.ncl | tr -d '"')"

let
    # globais escalares para simplificar as chamadas às funções
    quantidade : Number = 3,
    composto : Bool = true,
    periodo : Number = 30.0
in let rec
    # função recursiva que inicializa pagamentos[]
    rGeraPagamentos : Number -> Array Number = fun indice =>
        if indice < 1 then
            []
        else
            std.array.append (indice * periodo) (rGeraPagamentos (indice - 1)),

    # função recursiva que inicializa pesos[]
    rGeraPesos : Number -> Array Number = fun indice =>
        if indice < 1 then
            []
        else
            std.array.append 1.0 (rGeraPesos (indice - 1))
in let
    # função açúcar que inicializa pagamentos[]
    geraPagamentos : Dyn -> Array Number = fun _ =>
        rGeraPagamentos quantidade,

    # função açúcar que inicializa pesos[]
    geraPesos : Dyn -> Array Number = fun _ =>
        rGeraPesos quantidade
in let
    # arrays globais para simplificar as chamadas às funções
    pagamentos : Array Number = geraPagamentos null,
    pesos : Array Number = geraPesos null
in let rec
    # função recursiva que calcula a somatória dos elementos de pesos[]
    rGetPesoTotal : Number -> Number = fun indice =>
        if indice < 0 then
            0.0
        else
            (std.array.at indice pesos) + rGetPesoTotal (indice - 1)
in let
    # função açúcar que calcula a somatóris dos elementos de pesos[]
    getPesoTotal : Dyn -> Number = fun _ =>
        rGetPesoTotal (quantidade - 1)
in let rec
    # função recursiva que calcula a somatória do amortização de Juros Compostos
    rJurosCompostos : Number -> Number -> Number = fun juros indice =>
        if indice < 0 then
            0.0
        else
            (std.array.at indice pesos) / (std.number.pow (1.0 + juros / 100.0) ((std.array.at indice pagamentos) / periodo)) + rJurosCompostos juros (indice - 1),
    # função recursiva que calcula a somatória do amortização de Juros Simples
    rJurosSimples : Number -> Number -> Number = fun juros indice =>
        if indice < 0 then
            0.0
        else
            (std.array.at indice pesos) / (1.0 + juros / 100.0 * (std.array.at indice pagamentos) / periodo) + rJurosSimples juros (indice - 1)
in let
    # função (um pouco açúcar) que calcula o acréscimo a partir dos juros e parcelas
    jurosParaAcrescimo : Number -> Number = fun juros =>
        if composto then
            ((getPesoTotal null) / (rJurosCompostos juros (quantidade - 1)) - 1.0) * 100.0
        else
            ((getPesoTotal null) / (rJurosSimples juros (quantidade - 1)) - 1.0) * 100.0
in let rec
    # função recursiva que calcula os juros a partir do acréscimo e parcelas
    rAcrescimoParaJuros : Number -> Number -> Number -> Number -> Number -> Number -> Number = fun acrescimo minDiferenca iteracao minJuros maxJuros medJuros =>
        if (iteracao < 1) || ((maxJuros - minJuros) < minDiferenca) then
            medJuros
        else
            if (jurosParaAcrescimo medJuros < acrescimo) then
                rAcrescimoParaJuros acrescimo minDiferenca (iteracao - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
            else
                rAcrescimoParaJuros acrescimo minDiferenca (iteracao - 1) minJuros medJuros ((minJuros + medJuros) / 2.0)
in let
    # função açúcar que calcula os juros a partir do acréscimo e parcelas
    acrescimoParaJuros : Number -> Number -> Number -> Number -> Number = fun acrescimo precisao maxIteracoes maxJuros =>
        rAcrescimoParaJuros acrescimo (std.number.pow 0.1 precisao) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)
in let
    pesoTotal : Number = getPesoTotal null,
    acrescimoCalculado : Number = jurosParaAcrescimo 3.0
in let
    jurosCalculado : Number = acrescimoParaJuros acrescimoCalculado 15 65 50.0
in
    #imprime os resultados
    "Peso total = %{pesoTotal}\nAcréscimo = %{acrescimoCalculado}\nJuros = %{jurosCalculado}"
