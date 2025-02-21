" Cálculo dos juros, sendo que precisa de parcelas pra isso
" Versão 0.1: 20/02/2025: versão feita sem muito conhecimento de Vim script

" variáveis globais para simplificar as chamadas
let Quantidade = 3
let Composto = v:true
let Periodo = 30.0
let Pagamentos = []
let Pesos = []

" calcula a somatória de Pesos[]
function GetPesoTotal()
    let acumulador = 0.0
    for indice in range(0, g:Quantidade - 1)
        let l:acumulador += g:Pesos[l:indice]
    endfor
    return l:acumulador
endfunction

" calcula o acréscimo a partir dos juros e parcelas
function JurosParaAcrescimo(juros)
    let pesoTotal = GetPesoTotal()
    if l:pesoTotal <= 0.0 || g:Quantidade <= 1 || g:Periodo <= 0.0 || a:juros <= 0.0
        return 0.0
    endif

    let acumulador = 0.0
    for indice in range(0, g:Quantidade - 1)
        if g:Composto
            let l:acumulador += g:Pesos[l:indice] / pow(1.0 + a:juros / 100.0, g:Pagamentos[l:indice] / g:Periodo)
        else
            let l:acumulador += g:Pesos[l:indice] / (1.0 + a:juros / 100.0 * g:Pagamentos[l:indice] / g:Periodo)
        endif
    endfor

    if l:acumulador <= 0.0
        return 0.0
    endif
    return (l:pesoTotal / l:acumulador - 1.0) * 100.0
endfunction

" calcula os juros a partir do acréscimo e parcelas
function AcrescimoParaJuros(acrescimo, precisao = 15, maxIteracoes = 100, maximoJuros = 50.0)
    let pesoTotal = GetPesoTotal()
    if l:pesoTotal <= 0.0 || g:Quantidade <= 1 || g:Periodo <= 0.0 || a:acrescimo <= 0.0 || a:precisao < 1 || a:maxIteracoes < 1 || a:maximoJuros <= 0.0
        return 0.0
    endif

    let minJuros = 0.0
    let medJuros = a:maximoJuros / 2.0
    let maxJuros = a:maximoJuros
    let minDiferenca = pow(0.1, a:precisao)
    for indice in range(1, a:maxIteracoes)
        let l:medJuros = (l:minJuros + l:maxJuros) / 2.0
        if (l:maxJuros - l:minJuros) < l:minDiferenca
            return l:medJuros
        endif
        if JurosParaAcrescimo(l:medJuros) < a:acrescimo
            let l:minJuros = l:medJuros
        else
            let l:maxJuros = l:medJuros
        endif
    endfor

    return l:medJuros
endfunction

" inicializa os arrays Pagamentos[] e Pesos[]
for indice in range(0, Quantidade - 1)
    call insert(Pagamentos, 30.0 * (indice + 1.0))
    call insert(Pesos, 1.0)
endfor

" calcula e guarda os retornos das funções
let pesoTotal = GetPesoTotal()
let acrescimoCalculado = JurosParaAcrescimo(3.0)
let jurosCalculado = AcrescimoParaJuros(acrescimoCalculado)

" imprime os resultados
echo "Peso total = " .. pesoTotal
echo "Acréscimo = " .. acrescimoCalculado
echo "Juros = " .. jurosCalculado
quit!