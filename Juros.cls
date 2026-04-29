Class User.Juros Extends %RegisteredObject {

// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 29/04/2026: feita sem muito conhecimento de ObjectScript
// DO $SYSTEM.OBJ.Load("/irisdev/app/Juros.cls","ck")
// DO $SYSTEM.OBJ.Load("/irisdev/app/testajuros.mac","ck")
// DO ^testajuros

    // atributos escalares para simplificar as chamadas
    Property Quantidade As %Integer;
    Property Composto As %Boolean;
    Property Periodo As %Double;
    // atributos arrrays para simplificar as chamadas
    Property Pagamentos as %Double [ MultiDimensional ];
    Property Pesos as %Double [ MultiDimensional ];

    // construtor, inicializa os atributos escalares
    Method %OnNew(pQuantidade, pComposto, pPeriodo) As %Status
    {
        SET ..Quantidade = pQuantidade
        SET ..Composto = pComposto
        SET ..Periodo = pPeriodo

        QUIT $$$OK
    }

    // calcula a somatória dos elementos do array Pesos
    Method getPesoTotal() As %Double {
        SET acumulador = 0.0
        FOR indice = 1:1:..Quantidade { SET acumulador = acumulador + ..Pesos(indice) }
        QUIT acumulador
    }

    // calcula o acréscimo a partir dos juros e parcelas
    Method jurosParaAcrescimo(juros As %Double) As %Double {
        SET pesoTotal = ..getPesoTotal()
        IF ..Quantidade < 1 || ..Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0 { QUIT 0.0 }
        SET acumulador = 0.0

        FOR indice = 1:1:..Quantidade {
            IF ..Composto {
                SET acumulador = acumulador + (..Pesos(indice) / ((1.0 + (juros / 100.0)) ** (..Pagamentos(indice) / ..Periodo)))
            } ELSE {
                SET acumulador = acumulador + (..Pesos(indice) / (1.0 + ((juros / 100.0) * (..Pagamentos(indice) / ..Periodo))))
            }
        }

        IF acumulador <= 0.0 { QUIT 0.0 }
        QUIT (pesoTotal / acumulador - 1.0) * 100.0
    }

    // calcula os juros a partir do acréscimo e parcelas
    Method acrescimoParaJuros(acrescimo As %Double, precisao As %Integer, maxIteracoes As %Integer, maxJuros As %Double) As %Double {
        SET pesoTotal = ..getPesoTotal()
        IF ..Quantidade < 1 || ..Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0 { QUIT 0.0 }
        SET minJuros = 0.0
        SET medJuros = maxJuros / 2.0
        SET minDiferenca = 0.1 ** precisao
        SET iteracao = 0

        WHILE (iteracao < maxIteracoes) && ((maxJuros - minJuros) > minDiferenca) {
            IF ..jurosParaAcrescimo(medJuros) < acrescimo { SET minJuros = medJuros } ELSE { SET maxJuros = medJuros }
            SET medJuros = (minJuros + maxJuros) / 2.0
            SET iteracao = iteracao + 1
        }

        QUIT medJuros
    }
}
