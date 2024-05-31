<html>
    <head>
        <meta charset="ISO 8859-1">
        <link rel="stylesheet" href="base.css" type="text/css"/>
    </head>
    <body>
        <!--- Cálculo do juros, sendo que precisa de arrays pra isso --->
        <!--- Versão 0.1: 30/05/2024: versão feita sem muito conhecimento de ColdfFusion --->
        <cfscript>
            oJuros = StructNew();
            oJuros.quantidade = 3;
            oJuros.composto = True;
            oJuros.periodo = 30.0;
            oJuros.pagamentos = [30.0, 60.0, 90.0];
            oJuros.pesos = [1.0, 1.0, 1.0];

            function getPesoTotal(){
                acumulador = 0.0;
                for (indice = 1; indice <= oJuros.quantidade; indice++) {
                    acumulador += oJuros.pesos[indice];
                }
                return acumulador;
            }

            function jurosParaAcrescimo(required juros) {
                pesoTotal = getPesoTotal();
                if (juros <= 0.0 || oJuros.quantidade < 1 || oJuros.periodo <= 0.0 || pesoTotal <= 0.0) {
                    return 0.0;
                }
                acumulador = 0.0;

                for (indice = 1; indice <= oJuros.quantidade; indice++) {
                    if (oJuros.composto) {
                        acumulador += oJuros.pesos[indice] / (1.0 + juros / 100.0) ^ (oJuros.pagamentos[indice] / oJuros.periodo);
                    } else {
                        acumulador += oJuros.pesos[indice] / (1.0 + juros / 100.0 * oJuros.pagamentos[indice] / oJuros.periodo);
                    }
                }

                return (pesoTotal / acumulador - 1.0) * 100.0;
            }

            function acrescimoParaJuros(required acrescimo, required precisao, required maxIteracoes, required maxJuros) {
                pesoTotal = getPesoTotal();
                if (acrescimo <= 0.0 || oJuros.quantidade < 1 || oJuros.periodo <= 0.0 || pesoTotal <= 0.0 || maxIteracoes < 1 || precisao < 1 || maxJuros <= 0.0) {
                    return 0.0;
                }
                minJuros = 0.0;
                medJuros = maxJuros / 2.0;
                minDiferenca = 0.1 ^ precisao;

                for (indice = 1; indice <= maxIteracoes; indice++) {
                    medJuros = (minJuros + maxJuros) / 2.0;
                    if ((maxJuros - minJuros) < minDiferenca) {
                        return medJuros;
                    }
                    if(jurosParaAcrescimo(medJuros) < acrescimo) {
                        minJuros = medJuros;
                    } else {
                        maxJuros = medJuros;
                    }
                }

                return medJuros;
            }
        </cfscript>
        <cfoutput>
            <strong>Peso total = </strong>#getPesoTotal()#<br>
            <strong>Acréscimo = </strong>#jurosParaAcrescimo(3.0)#<br>
            <strong>Juros = </strong>#acrescimoParaJuros(jurosParaAcrescimo(3.0), 15, 100, 50.0)#<br>
        </cfoutput>
    </body>
</html>