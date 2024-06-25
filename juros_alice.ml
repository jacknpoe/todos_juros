(* Calculo do juros, sendo que precisa de listas pra isso
  Versao 0.1: 31/05/2024: versao sem saber muito sobre Alice *)

(*) variaveis basicas para simplificar as chamadas
val quantidade = 3;
val composto = true;
val periodo = 30.0;
val pagamentos = [30.0, 60.0, 90.0];
val pesos = [1.0, 1.0, 1.0];

(*) funcao recursiva que realmente calcula a somatoria de Pesos[]
fun rGetPesoTotal indice = if indice = 0 then List.nth(pesos, 0) else rGetPesoTotal (indice - 1) + List.nth(pesos, indice) ;
    
(*) perfume que calcula a somatoria de Pesos[]
fun getPesoTotal () = rGetPesoTotal (quantidade - 1);

(*) calcula a soma do amortecimento de todas as parcelas para juros compostos
fun rJurosCompostos indice juros =
    if indice = 0 then List.nth( pesos, 0) / Math.pow(1.0 + juros / 100.0, List.nth(pagamentos, 0) / periodo)
    else rJurosCompostos (indice - 1) juros + List.nth(pesos, indice) / Math.pow(1.0 + juros / 100.0, List.nth(pagamentos, indice) / periodo);

(*) calcula a soma do amortecimento de todas as parcelas para juros simples
fun rJurosSimples indice juros =
    if indice = 0 then List.nth(pesos, 0) / (1.0 + juros / 100.0 * List.nth(pagamentos, 0) / periodo)
    else rJurosSimples (indice - 1) juros + List.nth(pesos, indice) / (1.0 + juros / 100.0 * List.nth(pagamentos, indice) / periodo);

(*) calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
fun jurosParaAcrescimo juros =
    if composto then (getPesoTotal() / rJurosCompostos (quantidade - 1) juros - 1.0) * 100.0
    else (getPesoTotal() / rJurosSimples (quantidade - 1) juros - 1.0) * 100.0;

(*) funcaoo recursiva no lugar de um for que realmente calcula os juros
fun rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if (iteracaoAtual = 0) orelse ((maxJuros - minJuros) < minDiferenca) then medJuros
    else if (jurosParaAcrescimo medJuros) < acrescimo
         then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
         else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0);

(*) calcula os juros a partir do acrescimo e dados comuns (como parcelas)
fun acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    rAcrescimoParaJuros acrescimo (Math.pow(0.1, Real.fromInt(precisao))) maxIteracoes 0.0 maxJuros (maxJuros / 2.0);

(*) faz os calculos para testes
val pesoTotal = getPesoTotal();
val acrescimoCalculado = jurosParaAcrescimo 3.0;
val jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0;

(*) imprime as variaveis calculadas
print ("Peso total = " ^ Real.toString(pesoTotal) ^ "\n");
print ("Acrescimo = " ^ Real.toString(acrescimoCalculado) ^ "\n");
print ("Juros = " ^ Real.toString(jurosCalculado) ^ "\n");
