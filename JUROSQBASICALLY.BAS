' Cálculo do juros, sendo que precisa de arrays pra isso
' Versão 0.1: 24/11/2026: versão feita a partir de QB 64, sem muito conhecimento de QBasically; retirados USING e espaços depois de "="
'        0.2: 24/11/2026: proteção para expoentes maiores do que 200
' RODAR EM: https://www.qbasically.com/

' define os valores globais
LET quantidade& = 300000
LET composto% = 1
LET periodo# = 30.0
DIM pagamentos#(quantidade&)
DIM pesos#(quantidade&)

' define os elementos nos arrays
FOR indice& = 1 TO quantidade&
    LET pagamentos#(indice&) = 30.0 * indice&
    LET pesos#(indice&) = 1.0
NEXT indice&

' calcula, guarda os resultados das funções e imprime
GOSUB getPesoTotal
PRINT "Peso total ="; pesoTotal#

LET juros# = 3.0
GOSUB jurosParaAcrescimo
PRINT "Acréscimo ="; acrescimoCalculado#

LET acrescimo# = acrescimoCalculado#
LET precisao# = 15
LET maxIteracoes% = 65
LET maxJuros# = 50.0
GOSUB acrescimoParaJuros
PRINT "Juros ="; jurosCalculado#

END

' calcula a somatória de pesos()
getPesoTotal:
LET pesoTotal# = 0.0
FOR indice& = 1 TO quantidade&
    LET pesoTotal# = pesoTotal# + pesos#(indice&)
NEXT indice&
RETURN

' calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
jurosParaAcrescimo:
LET acrescimoCalculado# = 0.0
IF juros# <= 0.0 OR quantidade& < 1 OR periodo# <= 0.0 OR pesoTotal# <= 0.0 THEN RETURN
LET acumulador# = 0.0
FOR indice& = 1 TO quantidade&
    IF composto% = 1 THEN
        LET expoente# = LOG(1.0 + juros# / 100.0) * (pagamentos#(indice&) / periodo#)
        IF expoente# < 200 THEN
            LET acumulador# = acumulador# + pesos#(indice&) / EXP(expoente#)
        END IF
    ELSE
        LET acumulador# = acumulador# + pesos#(indice&) / (1.0 + juros# / 100.0 * pagamentos#(indice&) / periodo#)
    END IF
NEXT indice&
LET acrescimoCalculado# = (pesoTotal# / acumulador# - 1.0) * 100.0
RETURN

' calcula os juros a partir do acréscimo e dados comuns (como parcelas)
acrescimoParaJuros:
LET jurosCalculado# = 0.0
IF acrescimo# <= 0.0 OR quantidade& < 1 OR periodo# <= 0.0 OR pesoTotal# <= 0.0 OR precisao# < 1 OR maxIteracoes% < 1 OR maxJuros# <= 0.0 THEN RETURN
LET minJuros# = 0.0
LET jurosCalculado# = maxJuros# / 2.0
LET minDiferenca# = 0.1 ^ precisao#
LET jurosCalculado# = (minJuros# + maxJuros#) / 2.0
FOR iteracao% = 1 TO maxIteracoes%
    IF (maxJuros# - minJuros#) < minDiferenca# THEN RETURN
    LET juros# = jurosCalculado#
    GOSUB jurosParaAcrescimo
    IF acrescimoCalculado# < acrescimo# THEN
        LET minJuros# = jurosCalculado#
    ELSE
        LET maxJuros# = jurosCalculado#
    END IF
    LET jurosCalculado# = (minJuros# + maxJuros#) / 2.0
NEXT iteracao%
RETURN
