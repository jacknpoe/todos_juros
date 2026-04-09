' Cálculo dos juros, sendo que precisa de arrays para isso
' Versao 0.1: 09/04/2026: feito sem muito conhecimento de my_basic

' converte valor (real) em string com casas decimais
' se você alterar o compilador para usar double, pode usar mais de 7 casas
def numtostr(valor, casas)
    valor = valor + 0.5 * 0.1 ^ casas;
    inteiro = floor(valor);
    valor = valor - inteiro;
    cadeia = str(inteiro) + ",";

    for indice = 1 to casas
        valor = valor * 10;
        inteiro = floor(valor);
        cadeia = cadeia + str(inteiro);
        valor = valor - inteiro;
    next indice

    return cadeia
enddef

' globais para simplificar as chamadas às funções e inicialização das escalares
Quantidade = 3;
Composto = 1;  ' 1 = TRUE
Periodo = 30.0;
dim Pagamentos(Quantidade);
dim Pesos(Quantidade);

' calcula a somatória dos elementos de Pesos()
def getPesoTotal()
    acumulador = 0.0 ;

    for indice = 0 to Quantidade - 1
        acumulador = acumulador + Pesos(indice);
    next indice

    return acumulador;
enddef

' calcula o acréscimo a partir dos juros e parcelas
def jurosParaAcrescimo(juros)
    pesoTotal = getPesoTotal();
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or juros <= 0.0 then return 0.0;
    acumulador = 0.0;

    for indice = 0 to Quantidade - 1
        if Composto then
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0) ^ (Pagamentos(indice) / Periodo);
        else
            acumulador = acumulador + Pesos(indice) / (1.0 + juros / 100.0 * Pagamentos(indice) / Periodo);
        endif
    next indice

    if acumulador <= 0.0 then return 0.0;
    return (pesoTotal / acumulador - 1.0) * 100.0;
enddef

' calcula os juros a partir do acréscimo e parcelas
def acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros)
    pesoTotal = getPesoTotal();
    if Quantidade < 1 or Periodo <= 0.0 or pesoTotal <= 0.0 or acrescimo <= 0.0 or precisao < 1 or maxIteracoes < 1 or maxJuros <= 0.0 then return 0.0;
    minJuros = 0.0;
    medJuros = maxJuros / 2.0;
    minDiferenca = 0.1 ^ precisao;

    for iteracao = 1 to maxIteracoes
        if maxJuros - minJuros < minDiferenca then return medJuros;
        if jurosParaAcrescimo(medJuros) < acrescimo then minJuros = medJuros; else maxJuros = medJuros;
        medJuros = (minJuros + maxJuros) / 2.0
    next iteracao

    return medJuros;
enddef

' inicialização de arrays Pagamentos() e Pesos()
for indice = 0 to Quantidade - 1
    Pagamentos(indice) = (indice + 1) * Periodo;
    Pesos(indice) = 1.0;
next indice

' calcula e guarda os resultados das funções
pesoTotal = getPesoTotal();
acrescimoCalculado = jurosParaAcrescimo(3.0);
jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 7, 30, 50.0);

' imprime os resultados
print "Peso total = ", numtostr(pesoTotal, 5);
print "Acréscimo = ", numtostr(acrescimoCalculado, 5);
print "Juros = ", numtostr(jurosCalculado, 5);
