' Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
' Versões: 0.1.0: 29/01/2026: funções matemáticas, variáveis (arduamente globais) e getPesoTotal
' Versões: 0.1.1: 30/02/2026: jurosParaAcrescimo e acrescimoParaJuros
' ATENÇÃO: a lentidão no emulador de C64, quando está em 100% de velocidade da CPU, na prática, impede os testes, use uma velocidade maior

' estão aqui, porque precisam estar antes das funções e quantidade é const porque os arrays são definidos em tempo de compilação
CONST quantidade = 3
CONST totln = 8
CONST totexp = 12

' variáveis globais escalares (se não tivesse o GLOBAL, não seriam visíveis dentro das funções)
GLOBAL "*"
composto = 1 : ' 1 = TRUE
periodo = 30.0

' essa é uma forma para definir arrays globais; seria como, normalmente, fossem declarados globais fora de funções
PROCEDURE declaraArraysGlobais
    SHARED "*"
    DIM pagamentos(quantidade)
    DIM pesos(quantidade)
END PROC

' essa função é mais precisa com valores mais próximos de 1, como 1.0 a 1.1, que é a faixa em que vai ser usada
PROCEDURE ln[ valor AS SINGLE ]
    ip = (valor - 1.0) / (valor + 1.0)
    termo = ip
    soma = 0.0

    FOR indln = 1 TO totln
        soma = soma + termo / (2.0 * indln - 1.0)
        termo = termo * ip * ip
    NEXT

    RETURN 2.0 * soma
END PROC

' essa função é mais precisa com valores menores do que 5, que é a faixa em que vai ser usada
PROCEDURE exp[ valor AS SINGLE ]
    termo = 1.0
    soma = 1.0

    FOR indexp = 1 TO totexp
        termo = termo * valor / indexp
        soma = soma + termo
    NEXT

    RETURN soma
END PROC

' essa função tem a precisão boa de acordo com ln() e exp()
PROCEDURE pow[ base AS SINGLE, expoente AS SINGLE ]
    RETURN exp[ln[base] * expoente]
END PROC

' calcula a soma dos elementos de pesos()
PROCEDURE getPesoTotal
    acumulador = 0.0
    FOR indice = 0 TO quantidade - 1
        acumulador = acumulador + pesos(indice)
    NEXT
    RETURN acumulador
END PROC

' calcula o acréscimo a partir dos juros e parcelas
PROCEDURE jurosParaAcrescimo[ juros ]
    pesoTotal = getPesoTotal[]
    IF quantidade < 1 OR periodo <= 0.0 OR pesoTotal <= 0.0 OR juros <= 0.0 THEN : RETURN 0.0 : ENDIF
    acumulador = 0.0

    FOR indice = 0 TO quantidade - 1
        IF composto = 1 THEN
            acumulador = acumulador + pesos(indice) / pow[1.0 + juros / 100.0, pagamentos(indice) / periodo]
        ELSE
            acumulador = acumulador + pesos(indice) / (1.0 + juros / 100.0 * pagamentos(indice) / periodo)
        ENDIF
    NEXT

    IF acumulador <= 0.0 THEN : RETURN 0.0 : ENDIF
    RETURN (pesoTotal / acumulador - 1.0) * 100.0
END PROC

' calcula os juros a partir do acréscimo e parcelas
PROCEDURE acrescimoParaJuros[ acrescimo, precisao, maxIteracoes, maxJuros ]
    pesoTotal = getPesoTotal[]
    IF quantidade < 1 OR periodo <= 0.0 OR pesoTotal <= 0.0 OR acrescimo <= 0.0 OR precisao < 1 OR maxIteracoes < 1 OR maxJuros <= 0.0 THEN : RETURN 0.0 : ENDIF
    minJuros = 0.0
    medJuros = maxJuros / 2.0
    minDiferenca = 0.1 ^ precisao

    FOR iteracao = 1 TO maxIteracoes
        IF maxJuros - minJuros < minDiferenca THEN : RETURN medJuros : ENDIF
        IF jurosParaAcrescimo[medJuros] < acrescimo THEN : minJuros = medJuros : ELSE : maxJuros = medJuros : ENDIF
        medJuros = (minJuros + maxJuros) / 2.0
        PRINT "." ;
    NEXT

    RETURN medJuros
END PROC

' Formata o número com casas decimais
PROCEDURE printNumero[ valor AS SINGLE, casas AS INTEGER ]
    IF valor < 0.0 THEN
        PRINT "-";
        valor = -valor
    ENDIF
    parteInteira = INT(valor)
    parteDecimal = (valor - parteInteira) * 10^casas
    PRINT parteInteira; ".";
    FOR i = 1 TO casas
        PRINT parteDecimal MOD 10;
        parteDecimal = parteDecimal / 10
    NEXT
END PROC

' FIM DAS FUNÇÕES, ABAIXO É "MAIN"

' limpa a tela, para não ficar mostrando caracteres aleatórios, e mostra uma mensagem de aguarde
CLS
PRINT "Aguarde..."

' define os valores dos elementos dos arrays
FOR indice = 0 TO quantidade - 1
    pagamentos(indice) = periodo * (indice + 1.0)
    pesos(indice) = 1.0
NEXT

' chama e guarda o resultado das funções
pesoTotal = getPesoTotal[]
acrescimoCalculado = jurosParaAcrescimo[3.0]
jurosCalculado = acrescimoParaJuros[acrescimoCalculado, 8, 35, 50.0] : ' aqui destoa das demais soluções, pois o emulador é lento e a precisão é baixa

' imprime os resultados
CLS
PRINT "Peso total = "; pesoTotal
PRINT "Acrescimo = "; acrescimoCalculado
PRINT "Juros = "; jurosCalculado

END